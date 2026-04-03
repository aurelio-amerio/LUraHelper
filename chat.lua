local _, LURA = ...

function LURA:CreateChatPanel()
    local f = CreateFrame("Frame", "LUraChatFrame", UIParent, "BasicFrameTemplate")
    f:SetSize(400, 100)
    f:SetPoint("CENTER", 0, -200)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)

    f.TitleText:SetText("Latest Channel /" .. (LURA.db.chatChannel or 4) .. " Message")

    local MessageDisplay = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    MessageDisplay:SetPoint("TOPLEFT", f, "TOPLEFT", 15, -40)
    MessageDisplay:SetWidth(370) 
    MessageDisplay:SetJustifyH("LEFT")
    MessageDisplay:SetWordWrap(true)
    MessageDisplay:SetText("Waiting for message...")

    local ListenerFrame = CreateFrame("Frame")
    ListenerFrame:RegisterEvent("CHAT_MSG_CHANNEL")

    ListenerFrame:SetScript("OnEvent", function(self, event, ...)
        if event == "CHAT_MSG_CHANNEL" then
            local text = select(1, ...)
            local channelNumber = select(8, ...)
            local channelName = select(9, ...)
            
            local targetChannel = tonumber(LURA.db.chatChannel) or 4
            
            if channelNumber == targetChannel then
                if channelName and channelName ~= "" then
                    f.TitleText:SetText("Latest Message: " .. channelName)
                end
                pcall(function()
                    MessageDisplay:SetText(text)
                end)
            end
        end
    end)
    
    f.UpdateTitle = function(self)
        self.TitleText:SetText("Listening to Channel /" .. (LURA.db.chatChannel or 4))
    end
    
    LURA.chatFrame = f
end
