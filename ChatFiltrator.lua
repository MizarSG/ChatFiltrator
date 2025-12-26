ChatFiltratorDB = ChatFiltratorDB
local addonFrame = CreateFrame("Frame")
local chatFrame
local CHAT_FRAME_NAME = "ChatFiltrator"
local initialized = false
local notificationsEnabled

local chatEvents = {
    "CHAT_MSG_SAY",
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

        notificationsEnabled = ChatFiltratorDB.notificationsEnabled
        return
    end
    if not initialized then return end

    local message, sender = ...

    if not message then return end

    local msg = string.lower(message)

    if msg:find("msg1") and msg:find("msg2") and not msg:find("msg3") then
        chatFrame:AddMessage(
            string.format("|cff00ff00[%s]|r %s", sender or "?", message)
        )

        if notificationsEnabled then
            -- Sound
            PlaySound(SOUNDKIT.RAID_WARNING)

            -- On-screen message
	        ShowAlert("ChatFiltrator: matching message detected!")
        end
    end
end)

addonFrame:RegisterEvent("PLAYER_LOGIN")
addonFrame:RegisterEvent("ADDON_LOADED")

SLASH_CHATFILTRATOR1 = "/cf"
SlashCmdList["CHATFILTRATOR"] = function(msg)
    msg = msg and msg:lower() or ""

    if msg == "notify" then
        notificationsEnabled = not notificationsEnabled
        ChatFiltratorDB.notificationsEnabled = notificationsEnabled

        if notificationsEnabled then
            print("|cff00ff00[ChatFiltrator]|r Notifications ENABLED")
        else
            print("|cffff0000[ChatFiltrator]|r Notifications DISABLED")
        end
        return
    end

    print("|cffffff00ChatFiltrator commands:|r")
    print("  /cf notify  - toggle sound & flash")
end