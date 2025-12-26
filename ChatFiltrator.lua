print("|cffff0000[ChatFiltrator]|r Lua loaded")

local addonFrame = CreateFrame("Frame")
local chatFrame
local CHAT_FRAME_NAME = "ChatFiltrator"
local initialized = false

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
    print("|cffff0000[ChatFiltrator]|r Trying to create chat window...")

    -- Ensure ChatFrame1 exists
    if not ChatFrame1 then
        print("|cffff0000[ChatFiltrator]|r ChatFrame1 not ready")
        return false
    end

    -- Look for existing window
    for i = 1, NUM_CHAT_WINDOWS do
        local name = GetChatWindowInfo(i)
        if name == CHAT_FRAME_NAME then
            chatFrame = _G["ChatFrame" .. i]
            print("|cffff0000[ChatFiltrator]|r Found existing chat window")
            return true
        end
    end

    -- Create new window
    print("|cffff0000[ChatFiltrator]|r Creating new window")
    chatFrame = FCF_OpenNewWindow(CHAT_FRAME_NAME)
    if not chatFrame then
        return false
    else
        ChatFrame_RemoveAllMessageGroups(chatFrame)
	    ChatFrame_RemoveAllChannels(chatFrame) 
        FCF_SetLocked(chatFrame, false)
        print("|cffff0000[ChatFiltrator]|r Chat window created successfully")
        return true
    end
end

addonFrame:SetScript("OnEvent", function(self, event, ...)

    if event == "PLAYER_LOGIN" and not initialized then
           print("|cffff0000[ChatFiltrator]|r Event:", event)
         if TryCreateChatWindow() then
            initialized = true

            for _, e in ipairs(chatEvents) do
                self:RegisterEvent(e)
            end

            print("|cffff0000[ChatFiltrator]|r Initialization COMPLETE")
        else
            -- Retry shortly if chat system still not ready
            print("|cffff0000[ChatFiltrator]|r Retrying in 1 second...")
            C_Timer.After(1, function()
                addonFrame:GetScript("OnEvent")(addonFrame, "PLAYER_LOGIN")
            end)
        end
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
        -- Sound notification (Classic-safe)
    	PlaySound(SOUNDKIT.RAID_WARNING)

    	-- On-screen message
	    ShowAlert("ChatFiltrator: matching message detected!")
    end
end)

addonFrame:RegisterEvent("PLAYER_LOGIN")
