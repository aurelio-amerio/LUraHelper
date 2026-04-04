local _, LURA = ...

function LURA:CreateChatPanel()
    local f = CreateFrame("Frame", "LUraChatFrame", LUraSummaryFrame)
    f:SetSize(400, 40)
    
    f:SetMovable(false)
    f:EnableMouse(false)

    local MessageDisplay = f:CreateFontString(nil, "OVERLAY")
    f.MessageDisplay = MessageDisplay
    
    local size = LURA.db.chatFontSize or 29
    MessageDisplay:SetFont("Interface\\AddOns\\LUraHelper\\font\\dejavu-sans-mono-bold.TTF", size, "MONOCHROME, OUTLINE")
    -- Left edge since the drag handle is gone
    MessageDisplay:SetPoint("LEFT", f, "LEFT", 0, 0)
    MessageDisplay:SetPoint("RIGHT", f, "RIGHT", 0, 0)
    MessageDisplay:SetJustifyH("LEFT")
    MessageDisplay:SetWordWrap(false)
    MessageDisplay:SetText(".")

    local ListenerFrame = CreateFrame("Frame")
    ListenerFrame:RegisterEvent("CHAT_MSG_CHANNEL")
    ListenerFrame:RegisterEvent("CHAT_MSG_SAY")
    ListenerFrame:RegisterEvent("CHAT_MSG_RAID_WARNING")
    ListenerFrame:RegisterEvent("CHAT_MSG_COMMUNITIES_CHANNEL")

    ListenerFrame:SetScript("OnEvent", function(self, event, ...)
        local ctype = LURA.db.chatType or "channel_numbered"
        local text = select(1, ...)
        
        local shouldDisplay = false
        if event == "CHAT_MSG_SAY" and ctype == "say" then
            shouldDisplay = true
        elseif event == "CHAT_MSG_RAID_WARNING" and ctype == "rw" then
            shouldDisplay = true
        elseif event == "CHAT_MSG_CHANNEL" or event == "CHAT_MSG_COMMUNITIES_CHANNEL" then
            local _, _, _, channelName, _, _, _, channelNumber = ...
            
            if ctype == "channel_numbered" and event == "CHAT_MSG_CHANNEL" then
                local targetChannel = tonumber(LURA.db.chatChannel) or 4
                if channelNumber == targetChannel then
                    shouldDisplay = true
                end
            elseif ctype == "channel_named" then
                local targetName = string.lower(LURA.db.chatChannelName or "")
                if targetName ~= "" and channelName and string.find(string.lower(channelName), targetName, 1, true) then
                    shouldDisplay = true
                end
            end
        end
        
        if shouldDisplay then
            pcall(function()
                MessageDisplay:SetText(text)
            end)
        end
    end)
    
    LURA.chatFrame = f
    
    if LURA.ApplyChatOffset then LURA:ApplyChatOffset() end
end

function LURA:ApplyChatOffset()
    if LUraChatFrame and LUraSummaryFrame then
        local x = LURA.db.chatOffsetX or -175
        local y = LURA.db.chatOffsetY or -35
        LUraChatFrame:ClearAllPoints()
        LUraChatFrame:SetPoint("TOPLEFT", LUraSummaryFrame, "TOPRIGHT", x, y)
    end
end

function LURA:ApplyChatFont()
    if not LURA.chatFrame or not LURA.chatFrame.MessageDisplay then return end
    local size = LURA.db.chatFontSize or 29
    LURA.chatFrame.MessageDisplay:SetFont("Interface\\AddOns\\LUraHelper\\font\\dejavu-sans-mono-bold.TTF", size, "MONOCHROME, OUTLINE")
end
