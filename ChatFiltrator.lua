print("|cffff0000[ChatFiltrator]|r Lua loaded")

local addonFrame = CreateFrame("Frame")
local chatFrame
local CHAT_FRAME_NAME = "ChatFiltrator"
local initialized = false

local chatEvents = {
    "CHAT_MSG_SAY",
    "CHAT_MSG_CHANNEL",
}

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
    local id = FCF_OpenNewWindow(CHAT_FRAME_NAME)
    print("|cffff0000[ChatFiltrator]|r New window created")
    if not id then
        print("|cffff0000[ChatFiltrator]|r FCF_OpenNewWindow failed")
        return false
    end

    chatFrame = _G["ChatFrame" .. id]
     print("|cffff0000[ChatFiltrator]|r Chat frame received")
    FCF_SetWindowColor(chatFrame, 0, 0, 0)
         print("|cffff0000[ChatFiltrator]|r Color set")
    FCF_SetWindowAlpha(chatFrame, 1)
         print("|cffff0000[ChatFiltrator]|r Alpha set")
    FCF_SetLocked(chatFrame, false)
         print("|cffff0000[ChatFiltrator]|r Locked set")

    print("|cffff0000[ChatFiltrator]|r Chat window created successfully")
    return true
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
    end
end)

addonFrame:RegisterEvent("PLAYER_LOGIN")
