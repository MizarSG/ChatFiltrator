ChatFiltratorDB = ChatFiltratorDB
local addonFrame = CreateFrame("Frame")
local chatFrame
local CHAT_FRAME_NAME = "ChatFiltrator"
local initialized = false
local notificationsEnabled

local chatEvents = {
    "CHAT_MSG_SAY",    
    "CHAT_MSG_YELL",
    "CHAT_MSG_GUILD",
    "CHAT_MSG_CHANNEL",
}

-- Custom alert frame (Classic-safe)
local alertFrame = CreateFrame("Frame", nil, UIParent)
alertFrame:SetSize(400, 50)
alertFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 120)
alertFrame:Hide()

alertFrame.text = alertFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
alertFrame.text:SetAllPoints()
alertFrame.text:SetJustifyH("CENTER")
alertFrame.text:SetTextColor(1, 1, 0)

local function ShowAlert(msg)
    alertFrame.text:SetText(msg)
    alertFrame:SetAlpha(1)
    alertFrame:Show()

    UIFrameFadeOut(alertFrame, 10, 1, 0)
end

local function TryCreateChatWindow()
    -- Ensure ChatFrame1 exists
    if not ChatFrame1 then
        return false
    end

    -- Look for existing window
    for i = 1, NUM_CHAT_WINDOWS do
        local name = GetChatWindowInfo(i)
        if name == CHAT_FRAME_NAME then
            chatFrame = _G["ChatFrame" .. i]
            return true
        end
    end

    -- Create new window
    chatFrame = FCF_OpenNewWindow(CHAT_FRAME_NAME)
    if not chatFrame then
        return false
    else
        ChatFrame_RemoveAllMessageGroups(chatFrame)
	    ChatFrame_RemoveAllChannels(chatFrame) 
        FCF_SetLocked(chatFrame, false)
        return true
    end
end

------------------------------------------------------------
-- Keyword helpers
------------------------------------------------------------
local function TableContains(t, value)
    for _, v in ipairs(t) do
        if v == value then return true end
    end
    return false
end

local function RemoveFromTable(t, value)
    for i = #t, 1, -1 do
        if t[i] == value then
            table.remove(t, i)
            return true
        end
    end
    return false
end
------------------------------------------------------------
-- Keyword matching (DB-driven)
------------------------------------------------------------
local function MatchesKeywords(message)
    local msg = message:lower()
            
    -- ALL include words must match
    for _, word in ipairs(ChatFiltratorDB.includeWords) do
        if not msg:find(word, 1, true) then
            return false
        end
    end

    -- ANY exclude word blocks
    for _, word in ipairs(ChatFiltratorDB.excludeWords) do
        if msg:find(word, 1, true) then
            return false
        end
    end

    return true
end

addonFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" and not initialized then
        if TryCreateChatWindow() then
            initialized = true

            for _, e in ipairs(chatEvents) do
                self:RegisterEvent(e)
            end
        else
            -- Retry shortly if chat system still not ready
            C_Timer.After(1, function()
                addonFrame:GetScript("OnEvent")(addonFrame, "PLAYER_LOGIN")
            end)
        end
        return
    end

    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName ~= "ChatFiltrator" then return end
        -- Initialize DB ONCE
        if not ChatFiltratorDB then
            ChatFiltratorDB = {}
            ChatFiltratorDB.notificationsEnabled = true
        end

        if ChatFiltratorDB.notificationsEnabled == nil then
            ChatFiltratorDB.notificationsEnabled = true
        end

        if type(ChatFiltratorDB.includeWords) ~= "table" then
            ChatFiltratorDB.includeWords = { "msg1", "msg2" }
        end

        if type(ChatFiltratorDB.excludeWords) ~= "table" then
            ChatFiltratorDB.excludeWords = { "msg3" }
        end

        notificationsEnabled = ChatFiltratorDB.notificationsEnabled

        return
    end
    if not initialized then return end

    local message, sender = ...

    if not message then return end

    if MatchesKeywords(message) then
        chatFrame:AddMessage(
            string.format("|cff00ff00[%s]|r %s", sender or "?", message)
        )

        if notificationsEnabled then
            PlaySound(SOUNDKIT.RAID_WARNING)
            ShowAlert("ChatFiltrator: matching message detected!")
        end
    end
end)

addonFrame:RegisterEvent("PLAYER_LOGIN")
addonFrame:RegisterEvent("ADDON_LOADED")

SLASH_CHATFILTRATOR1 = "/cf"
SlashCmdList["CHATFILTRATOR"] = function(msg)
    local args = {}
    for word in string.gmatch(msg or "", "%S+") do
        table.insert(args, word:lower())
    end

    if args[1] == "notify" then
        notificationsEnabled = not notificationsEnabled
        ChatFiltratorDB.notificationsEnabled = notificationsEnabled
        print("[ChatFiltrator] Notifications " ..
            (notificationsEnabled and "ENABLED" or "DISABLED"))
        return
    end

    if args[1] == "add" and args[2] and args[3] then
        local list = (args[2] == "include" and ChatFiltratorDB.includeWords)
                  or (args[2] == "exclude" and ChatFiltratorDB.excludeWords)

        if list and not TableContains(list, args[3]) then
            table.insert(list, args[3])
            print("[ChatFiltrator] Added '" .. args[3] .. "' to " .. args[2])
        end
        return
    end

    if args[1] == "remove" and args[2] and args[3] then
        local list = (args[2] == "include" and ChatFiltratorDB.includeWords)
                  or (args[2] == "exclude" and ChatFiltratorDB.excludeWords)

        if list and RemoveFromTable(list, args[3]) then
            print("[ChatFiltrator] Removed '" .. args[3] .. "' from " .. args[2])
        end
        return
    end

    if args[1] == "status" then
        print("|cffffff00[ChatFiltrator Status]|r")
        print(" Notifications: " .. (notificationsEnabled and "ON" or "OFF"))
        print(" Include words: " .. table.concat(ChatFiltratorDB.includeWords, ", "))
        print(" Exclude words: " .. table.concat(ChatFiltratorDB.excludeWords, ", "))
        return
    end

    print("|cffffff00ChatFiltrator commands:|r")
    print(" /cf notify")
    print(" /cf status")
    print(" /cf add include <word>")
    print(" /cf add exclude <word>")
    print(" /cf remove include <word>")
    print(" /cf remove exclude <word>")
end
