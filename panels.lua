local _, LURA = ...

-- Interactive Panel
function LURA:CreateInteractivePanel()
    local f = CreateFrame("Frame", "LUraInteractiveFrame", UIParent)
    f:SetSize(230, 115)
    f:SetPoint("CENTER", 496, -22)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    local tex = f:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetColorTexture(0, 0, 0, 0.7)
    
    local copyBg = f:CreateTexture(nil, "BACKGROUND")
    copyBg:SetColorTexture(0.05, 0.05, 0.05, 1)
    LURA.interactiveCopyBg = copyBg

    local copyBox = CreateFrame("EditBox", nil, f)
    copyBox:SetFont("Interface\\AddOns\\LUraHelper\\font\\dejavu-sans-mono-bold.TTF", 16, "OUTLINE")
    copyBox:SetAutoFocus(false)
    copyBox:SetTextInsets(5, 5, 0, 0)
    copyBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    copyBox:SetScript("OnEnterPressed", function(self) self:ClearFocus() end)
    copyBox:SetScript("OnTextChanged", function(self, isUserInput)
        if isUserInput then
            self:SetText(self.targetText or "")
            self:HighlightText()
        end
    end)
    copyBox:SetScript("OnEditFocusGained", function(self) self:HighlightText() end)
    copyBox.targetText = ""
    LURA.interactiveCopyBox = copyBox

    LURA.interactiveBtns = {}
    LURA.interactiveBottomSlotBgs = {}
    LURA.interactiveBottomSlotTexts = {}
    
    for i = 1, 5 do
        -- Row 1: Clickable buttons
        local btn = CreateFrame("Button", nil, f)
        btn:SetSize(30, 30)
        LURA.interactiveBtns[i] = btn
        
        local btnBg = btn:CreateTexture(nil, "BACKGROUND")
        btnBg:SetAllPoints()
        btnBg:SetColorTexture(0.1, 0.1, 0.1, 1)
        
        local text = btn:CreateFontString(nil, "OVERLAY")
        text:SetFont("Interface\\AddOns\\LUraHelper\\font\\dejavu-sans-mono-bold.TTF", 22, "OUTLINE")
        text:SetAllPoints()
        text:SetText(LURA.SYMBOL_TEXTS[i])
        text:SetTextColor(0.4, 0.6, 1)
        
        btn:SetScript("OnClick", function()
            if LURA.AddSymbolToSequence then
                LURA:AddSymbolToSequence(i)
            end
        end)
        btn:SetScript("OnEnter", function() btnBg:SetColorTexture(0.3, 0.3, 0.3, 1) end)
        btn:SetScript("OnLeave", function() btnBg:SetColorTexture(0.1, 0.1, 0.1, 1) end)
        
        -- Row 2: Sequence display slots
        local btmBg = f:CreateTexture(nil, "BACKGROUND")
        btmBg:SetSize(30, 30)
        btmBg:SetColorTexture(0.1, 0.1, 0.1, 1)
        LURA.interactiveBottomSlotBgs[i] = btmBg

        local btmText = f:CreateFontString(nil, "OVERLAY")
        btmText:SetFont("Interface\\AddOns\\LUraHelper\\font\\dejavu-sans-mono-bold.TTF", 22, "OUTLINE")
        btmText:SetAllPoints(btmBg)
        btmText:SetTextColor(0.4, 0.6, 1)
        btmText:SetText(".")
        LURA.interactiveBottomSlotTexts[i] = btmText
    end
    
    -- Reset / Cancel Button
    local resetBtn = CreateFrame("Button", nil, f)
    local resetBg = resetBtn:CreateTexture(nil, "BACKGROUND")
    resetBg:SetAllPoints()
    resetBg:SetColorTexture(0.1, 0.1, 0.1, 1)
    LURA.interactiveResetBtn = resetBtn
    
    local resetText = resetBtn:CreateFontString(nil, "OVERLAY")
    resetText:SetFont("Interface\\AddOns\\LUraHelper\\font\\dejavu-sans-mono-bold.TTF", 22, "OUTLINE")
    resetText:SetAllPoints()
    resetText:SetText("|cffff0000Ø|r")
    
    resetBtn:SetScript("OnClick", function()
        if LURA.ResetSequence then
            LURA:ResetSequence()
        end
    end)
    resetBtn:SetScript("OnEnter", function() resetBg:SetColorTexture(0.3, 0.3, 0.3, 1) end)
    resetBtn:SetScript("OnLeave", function() resetBg:SetColorTexture(0.1, 0.1, 0.1, 1) end)
    
    -- Row 3: Send to Chat Button
    local sendBtn = CreateFrame("Button", nil, f)
    local sendBg = sendBtn:CreateTexture(nil, "BACKGROUND")
    sendBg:SetAllPoints()
    sendBg:SetColorTexture(0.1, 0.1, 0.1, 1)
    
    local sendText = sendBtn:CreateFontString(nil, "OVERLAY")
    sendText:SetFont("Interface\\AddOns\\LUraHelper\\font\\dejavu-sans-mono-bold.TTF", 22, "OUTLINE")
    sendText:SetAllPoints()
    sendText:SetText("➤")
    sendText:SetTextColor(1, 1, 1)
    
    sendBtn:SetScript("OnClick", function()
        if LURA.SendSequence then LURA:SendSequence() end
    end)
    sendBtn:SetScript("OnEnter", function() sendBg:SetColorTexture(0.3, 0.3, 0.3, 1) end)
    sendBtn:SetScript("OnLeave", function() sendBg:SetColorTexture(0.1, 0.1, 0.1, 1) end)
    LURA.sendToChatBtn = sendBtn
end

-- Summary Panel & Sequence Logic
LURA.currentSequence = {}

function LURA:GetAvailableSlots()
    local count = 0
    for i = 1, 5 do
        if LURA.db.markers[i] ~= 9 then
            count = count + 1
        end
    end
    return count
end

function LURA:AddSymbolToSequence(symbolIndex)
    local activeCount = LURA:GetAvailableSlots()
    if #LURA.currentSequence >= activeCount then return end
    table.insert(LURA.currentSequence, symbolIndex)
    LURA:UpdateSummaryPanel()
end

function LURA:ResetSequence()
    LURA.currentSequence = {}
    if LURA.interactiveCopyBox then
        local activeCount = LURA:GetAvailableSlots()
        local msg = ""
        for i = 1, activeCount do
            msg = msg .. "." .. (i < activeCount and " " or "")
        end
        local channel = tonumber(LURA.db.chatChannel) or 4
        local fullMsg = "/" .. channel .. " " .. msg
        
        LURA.interactiveCopyBox.targetText = fullMsg
        LURA.interactiveCopyBox:SetText(fullMsg)
        LURA.interactiveCopyBox:SetCursorPosition(0)
        LURA.interactiveCopyBox:SetFocus()
        LURA.interactiveCopyBox:HighlightText()
    end
    LURA:UpdateSummaryPanel()
end

function LURA:CreateSummaryPanel()
    local f = CreateFrame("Frame", "LUraSummaryFrame", UIParent)
    f:SetSize(230, 80)
    f:SetPoint("CENTER", 0, 200)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    local tex = f:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetColorTexture(0, 0, 0, 0.7)
    
    LURA.summaryTopSlotTextures = {}
    LURA.summaryBottomSlotBgs = {}
    
    for i = 1, 5 do
        local topIcon = f:CreateTexture(nil, "ARTWORK")
        topIcon:SetSize(30, 30)
        local dbMarkerIndex = LURA.db.markers[i] or i
        topIcon:SetTexture(LURA.MARKER_TEXTURES[dbMarkerIndex])
        LURA.summaryTopSlotTextures[i] = topIcon
        
        local btmBg = f:CreateTexture(nil, "BACKGROUND")
        btmBg:SetSize(30, 30)
        btmBg:SetColorTexture(0.1, 0.1, 0.1, 1)
        LURA.summaryBottomSlotBgs[i] = btmBg
    end
end

function LURA:UpdateSummaryPanel()
    if not LUraSummaryFrame then return end
    
    local activeIndices = {}
    for i = 1, 5 do
        if LURA.db.markers[i] ~= 9 then
            table.insert(activeIndices, i)
        end
    end
    
    for i = 1, 5 do
        -- Update Summary Panel Marker Visibility
        if LURA.db.markers[i] == 9 then
            LURA.summaryTopSlotTextures[i]:Hide()
            if LURA.summaryBottomSlotBgs and LURA.summaryBottomSlotBgs[i] then LURA.summaryBottomSlotBgs[i]:Hide() end
        else
            LURA.summaryTopSlotTextures[i]:Show()
            if LURA.summaryBottomSlotBgs and LURA.summaryBottomSlotBgs[i] then LURA.summaryBottomSlotBgs[i]:Show() end
        end
        
        -- Update Interactive Panel Visibility & Sequence
        if LURA.interactiveBottomSlotBgs then
            if LURA.db.markers[i] == 9 then
                LURA.interactiveBtns[i]:Hide()
                LURA.interactiveBottomSlotBgs[i]:Hide()
                LURA.interactiveBottomSlotTexts[i]:Hide()
            else
                LURA.interactiveBtns[i]:Show()
                LURA.interactiveBottomSlotBgs[i]:Show()
                LURA.interactiveBottomSlotTexts[i]:Show()
                
                local sequenceIndex = nil
                for idx, activeIndex in ipairs(activeIndices) do
                    if activeIndex == i then
                        sequenceIndex = idx
                        break
                    end
                end
                
                if sequenceIndex and LURA.currentSequence[sequenceIndex] then
                    local symIdx = LURA.currentSequence[sequenceIndex]
                    LURA.interactiveBottomSlotTexts[i]:SetText(LURA.SYMBOL_TEXTS[symIdx])
                    LURA.interactiveBottomSlotTexts[i]:SetTextColor(0.4, 0.6, 1)
                else
                    LURA.interactiveBottomSlotTexts[i]:SetText(".")
                    LURA.interactiveBottomSlotTexts[i]:SetTextColor(1, 1, 1)
                end
            end
        end
    end
    
    if LURA.ApplyBoxSpacing then
        LURA:ApplyBoxSpacing()
    end
end

function LURA:UpdateSummaryPanelMarkers()
    if not LUraSummaryFrame then return end
    for i = 1, 5 do
        local dbMarkerIndex = LURA.db.markers[i] or i
        if LURA.summaryTopSlotTextures and LURA.summaryTopSlotTextures[i] then
            LURA.summaryTopSlotTextures[i]:SetTexture(LURA.MARKER_TEXTURES[dbMarkerIndex])
        end
    end
    LURA:UpdateSummaryPanel()
end

function LURA:ProcessChatCommand(msg)
    local prefix = "L'Ura Order:"
    local startIndex = msg:find(prefix, 1, true)
    if startIndex then
        local symbolsStr = msg:sub(startIndex + #prefix)
        
        local textSymbolMap = {
            ["O"] = 1,
            ["X"] = 2,
            ["V"] = 3,
            ["T"] = 4,
            ["^"] = 5,
        }
        
        local newSequence = {}
        for char in symbolsStr:gmatch(".") do
            local symIdx = textSymbolMap[char]
            if symIdx then
                table.insert(newSequence, symIdx)
            end
        end
        
        if #newSequence > 0 then
            LURA.currentSequence = newSequence
            LURA:UpdateSummaryPanel()
        end
    end
end

function LURA:ApplyBoxSpacing()
    local spacing = LURA.db.boxSpacing or 35
    local padding = LURA.db.boxPadding or 10
    
    -- Both panels span exactly 5 slots
    local panelWidth = padding + 4 * spacing + 30 + padding
    
    local summaryHeight = padding + 30 + 5 + 30 + padding -- 2 rows of 30, with 5 spacing between
    local interactiveHeight = padding + 30 + 5 + 30 + 5 + 30 + 5 + 30 + padding -- 4 rows of 30, with 5 spacing between
    
    if LUraInteractiveFrame and LURA.interactiveBtns then
        LUraInteractiveFrame:SetSize(panelWidth, interactiveHeight)
        
        if LURA.interactiveCopyBg then
            LURA.interactiveCopyBg:SetPoint("TOPLEFT", LUraInteractiveFrame, "TOPLEFT", padding, -padding)
            LURA.interactiveCopyBg:SetSize(panelWidth - 2 * padding, 30)
        end
        if LURA.interactiveCopyBox then
            LURA.interactiveCopyBox:SetPoint("TOPLEFT", LUraInteractiveFrame, "TOPLEFT", padding, -padding)
            LURA.interactiveCopyBox:SetSize(panelWidth - 2 * padding, 30)
        end

        for i = 1, 5 do
            -- The sequence slots (non-clickable) go on the second row (-(padding + 35))
            if LURA.interactiveBottomSlotBgs[i] then
                LURA.interactiveBottomSlotBgs[i]:SetPoint("TOPLEFT", LUraInteractiveFrame, "TOPLEFT", padding + (i-1)*spacing, -(padding + 35))
            end
            -- The clickable buttons go on the third row (-(padding + 70))
            LURA.interactiveBtns[i]:SetPoint("TOPLEFT", LUraInteractiveFrame, "TOPLEFT", padding + (i-1)*spacing, -(padding + 70))
        end
        
        local spanWidth = 4 * spacing + 30
        local gap = 5
        local halfWidth = (spanWidth - gap) / 2
        
        if LURA.sendToChatBtn then
            LURA.sendToChatBtn:SetSize(halfWidth, 30)
            LURA.sendToChatBtn:SetPoint("TOPLEFT", LUraInteractiveFrame, "TOPLEFT", padding, -(padding + 105))
        end
        if LURA.interactiveResetBtn then
            LURA.interactiveResetBtn:SetSize(halfWidth, 30)
            LURA.interactiveResetBtn:SetPoint("TOPLEFT", LUraInteractiveFrame, "TOPLEFT", padding + halfWidth + gap, -(padding + 105))
        end
    end
    
    if LUraSummaryFrame and LURA.summaryTopSlotTextures then
        LUraSummaryFrame:SetSize(panelWidth, summaryHeight)
        for i = 1, 5 do
            LURA.summaryTopSlotTextures[i]:SetPoint("TOPLEFT", LUraSummaryFrame, "TOPLEFT", padding + (i-1)*spacing, -padding)
            if LURA.summaryBottomSlotBgs and LURA.summaryBottomSlotBgs[i] then
                LURA.summaryBottomSlotBgs[i]:SetPoint("TOPLEFT", LUraSummaryFrame, "TOPLEFT", padding + (i-1)*spacing, -(padding + 35))
            end
        end
    end
end

function LURA:CreateSpacingPanel()
    local f = CreateFrame("Frame", "LUraSpacingPanel", UIParent, "BasicFrameTemplate")
    f:SetSize(300, 350)
    f:SetPoint("CENTER", 0, 100)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    f.TitleText:SetText("Tune Panel Spacing")
    
    local function UpdateLayout()
        if LURA.ApplyBoxSpacing then LURA:ApplyBoxSpacing() end
    end
    
    -- Spacing Slider
    local spaceSlider = CreateFrame("Slider", "LUraSpaceSlider", f, "OptionsSliderTemplate")
    spaceSlider:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -45)
    spaceSlider:SetMinMaxValues(20, 100)
    spaceSlider:SetValueStep(1)
    spaceSlider:SetObeyStepOnDrag(true)
    spaceSlider.Low:SetText("20")
    spaceSlider.High:SetText("100")
    _G[spaceSlider:GetName() .. "Text"]:SetText("Spacing (Width)")
    spaceSlider:SetValue(LURA.db.boxSpacing or 35)

    local spaceEditX = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    spaceEditX:SetSize(40, 20)
    spaceEditX:SetPoint("LEFT", spaceSlider, "RIGHT", 15, 0)
    spaceEditX:SetAutoFocus(false)
    spaceEditX:SetText(tostring(LURA.db.boxSpacing or 35))
    spaceEditX:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then spaceSlider:SetValue(val) end
        self:ClearFocus()
    end)
    spaceSlider:SetScript("OnValueChanged", function(self, value)
        spaceEditX:SetText(tostring(math.floor(value + 0.5)))
        LURA.db.boxSpacing = math.floor(value + 0.5)
        UpdateLayout()
    end)
    
    -- Padding Slider
    local padSlider = CreateFrame("Slider", "LUraPadSlider", f, "OptionsSliderTemplate")
    padSlider:SetPoint("TOPLEFT", spaceSlider, "BOTTOMLEFT", 0, -30)
    padSlider:SetMinMaxValues(0, 50)
    padSlider:SetValueStep(1)
    padSlider:SetObeyStepOnDrag(true)
    padSlider.Low:SetText("0")
    padSlider.High:SetText("50")
    _G[padSlider:GetName() .. "Text"]:SetText("Edge Padding")
    padSlider:SetValue(LURA.db.boxPadding or 10)

    local padEditX = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    padEditX:SetSize(40, 20)
    padEditX:SetPoint("LEFT", padSlider, "RIGHT", 15, 0)
    padEditX:SetAutoFocus(false)
    padEditX:SetText(tostring(LURA.db.boxPadding or 10))
    padEditX:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then padSlider:SetValue(val) end
        self:ClearFocus()
    end)
    padSlider:SetScript("OnValueChanged", function(self, value)
        padEditX:SetText(tostring(math.floor(value + 0.5)))
        LURA.db.boxPadding = math.floor(value + 0.5)
        UpdateLayout()
    end)
    
    -- Chat Offset X Slider
    local chatSlider = CreateFrame("Slider", "LUraChatSlider", f, "OptionsSliderTemplate")
    chatSlider:SetPoint("TOPLEFT", padSlider, "BOTTOMLEFT", 0, -30)
    chatSlider:SetMinMaxValues(-300, 300)
    chatSlider:SetValueStep(1)
    chatSlider:SetObeyStepOnDrag(true)
    chatSlider.Low:SetText("-300")
    chatSlider.High:SetText("300")
    _G[chatSlider:GetName() .. "Text"]:SetText("Chat X Offset")
    chatSlider:SetValue(LURA.db.chatOffsetX or 0)

    local chatEditX = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    chatEditX:SetSize(40, 20)
    chatEditX:SetPoint("LEFT", chatSlider, "RIGHT", 15, 0)
    chatEditX:SetAutoFocus(false)
    chatEditX:SetText(tostring(LURA.db.chatOffsetX or 0))
    chatEditX:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then chatSlider:SetValue(val) end
        self:ClearFocus()
    end)
    chatSlider:SetScript("OnValueChanged", function(self, value)
        chatEditX:SetText(tostring(math.floor(value + 0.5)))
        LURA.db.chatOffsetX = math.floor(value + 0.5)
        if LURA.ApplyChatOffset then LURA:ApplyChatOffset() end
    end)
    
    -- Chat Offset Y Slider
    local chatYSlider = CreateFrame("Slider", "LUraChatYSlider", f, "OptionsSliderTemplate")
    chatYSlider:SetPoint("TOPLEFT", chatSlider, "BOTTOMLEFT", 0, -30)
    chatYSlider:SetMinMaxValues(-100, 100)
    chatYSlider:SetValueStep(0.1)
    chatYSlider:SetObeyStepOnDrag(true)
    chatYSlider.Low:SetText("-100")
    chatYSlider.High:SetText("100")
    _G[chatYSlider:GetName() .. "Text"]:SetText("Chat Y Offset")
    chatYSlider:SetValue(LURA.db.chatOffsetY or -35)

    local chatEditY = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    chatEditY:SetSize(40, 20)
    chatEditY:SetPoint("LEFT", chatYSlider, "RIGHT", 15, 0)
    chatEditY:SetAutoFocus(false)
    chatEditY:SetText(tostring(LURA.db.chatOffsetY or -35))
    chatEditY:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then chatYSlider:SetValue(val) end
        self:ClearFocus()
    end)
    chatYSlider:SetScript("OnValueChanged", function(self, value)
        local formatted = math.floor(value * 10 + 0.5) / 10
        chatEditY:SetText(tostring(formatted))
        LURA.db.chatOffsetY = formatted
        if LURA.ApplyChatOffset then LURA:ApplyChatOffset() end
    end)
    
    -- Chat Font Size Slider
    local fontSlider = CreateFrame("Slider", "LUraFontSlider", f, "OptionsSliderTemplate")
    fontSlider:SetPoint("TOPLEFT", chatYSlider, "BOTTOMLEFT", 0, -30)
    fontSlider:SetMinMaxValues(10, 50)
    fontSlider:SetValueStep(0.1)
    fontSlider:SetObeyStepOnDrag(true)
    fontSlider.Low:SetText("10")
    fontSlider.High:SetText("50")
    _G[fontSlider:GetName() .. "Text"]:SetText("Chat Font Size")
    fontSlider:SetValue(LURA.db.chatFontSize or 29)

    local fontEdit = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    fontEdit:SetSize(40, 20)
    fontEdit:SetPoint("LEFT", fontSlider, "RIGHT", 15, 0)
    fontEdit:SetAutoFocus(false)
    fontEdit:SetText(tostring(LURA.db.chatFontSize or 29))
    fontEdit:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then fontSlider:SetValue(val) end
        self:ClearFocus()
    end)
    fontSlider:SetScript("OnValueChanged", function(self, value)
        local formatted = math.floor(value * 10 + 0.5) / 10
        fontEdit:SetText(tostring(formatted))
        LURA.db.chatFontSize = formatted
        if LURA.ApplyChatFont then LURA:ApplyChatFont() end
    end)
    
    f:Hide()
    LURA.spacingPanel = f
end



function LURA:SendSequence()
    if not LURA.currentSequence or #LURA.currentSequence == 0 then
        print("LUra: Sequence is empty.")
        return
    end
    
    local msg = ""
    for i, symIdx in ipairs(LURA.currentSequence) do
        local symStr = LURA.SYMBOL_TEXTS[symIdx] or "?"
        msg = msg .. symStr .. (i < #LURA.currentSequence and " " or "")
    end
    
    local channel = tonumber(LURA.db.chatChannel) or 4
    local fullMsg = "/" .. channel .. " " .. msg
    
    if LURA.interactiveCopyBox then
        LURA.interactiveCopyBox.targetText = fullMsg
        LURA.interactiveCopyBox:SetText(fullMsg)
        LURA.interactiveCopyBox:SetCursorPosition(0)
        LURA.interactiveCopyBox:SetFocus()
        LURA.interactiveCopyBox:HighlightText()
    end
end
