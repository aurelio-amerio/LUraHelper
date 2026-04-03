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

    ListenerFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "CHAT_MSG_CHANNEL" then
            local text = select(1, ...)
            local channelNumber = select(8, ...)
            local targetChannel = tonumber(LURA.db.chatChannel) or 4
            
            if channelNumber == targetChannel then
                pcall(function()
                    MessageDisplay:SetText(text)
                end)
            end
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
