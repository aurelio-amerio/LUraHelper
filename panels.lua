local _, LURA = ...

-- Interactive Panel
function LURA:CreateInteractivePanel()
    local f = CreateFrame("Frame", "LUraInteractiveFrame", UIParent)
    f:SetSize(230, 40)
    f:SetPoint("CENTER", 496, -22)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    local tex = f:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetColorTexture(0, 0, 0, 0.7)
    
    LURA.interactiveBtns = {}
    for i = 1, 5 do
        local btn = CreateFrame("Button", nil, f)
        btn:SetSize(30, 30)
        btn:SetPoint("LEFT", f, "LEFT", 10 + (i-1)*35, 0)
        LURA.interactiveBtns[i] = btn
        
        local icon = btn:CreateTexture(nil, "BACKGROUND")
        icon:SetAllPoints()
        icon:SetTexture(LURA.SYMBOL_TEXTURES[i])
        
        btn:SetScript("OnClick", function()
            if LURA.AddSymbolToSequence then
                LURA:AddSymbolToSequence(i)
            end
        end)
    end
    
    -- Reset / Cancel Button
    local resetBtn = CreateFrame("Button", nil, f)
    resetBtn:SetSize(30, 30)
    resetBtn:SetPoint("LEFT", f, "LEFT", 10 + 5*35, 0)
    LURA.interactiveResetBtn = resetBtn
    
    local resetIcon = resetBtn:CreateTexture(nil, "BACKGROUND")
    resetIcon:SetAllPoints()
    resetIcon:SetTexture(LURA.RESET_TEXTURE)
    
    resetBtn:SetScript("OnClick", function()
        if LURA.ResetSequence then
            LURA:ResetSequence()
        end
    end)
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
    LURA:UpdateSummaryPanel()
end

function LURA:CreateSummaryPanel()
    local f = CreateFrame("Frame", "LUraSummaryFrame", UIParent)
    f:SetSize(230, 80)
    f:SetPoint("CENTER", 496, 49)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    local tex = f:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetColorTexture(0, 0, 0, 0.7)
    
    LURA.summaryTopSlotTextures = {}
    LURA.summaryBottomSlotTextures = {}
    
    for i = 1, 5 do
        local topIcon = f:CreateTexture(nil, "ARTWORK")
        topIcon:SetSize(30, 30)
        topIcon:SetPoint("TOPLEFT", f, "TOPLEFT", 10 + (i-1)*35, -10)
        local dbMarkerIndex = LURA.db.markers[i] or i
        topIcon:SetTexture(LURA.MARKER_TEXTURES[dbMarkerIndex])
        LURA.summaryTopSlotTextures[i] = topIcon
    end
    
    LURA.summaryBottomSlotTextures = {}
    
    for i = 1, 5 do
        local btmIcon = f:CreateTexture(nil, "ARTWORK")
        btmIcon:SetSize(30, 30)
        btmIcon:SetPoint("TOPLEFT", f, "TOPLEFT", 10 + (i-1)*35, -45)
        btmIcon:SetColorTexture(0.2, 0.2, 0.2, 1)
        LURA.summaryBottomSlotTextures[i] = btmIcon
    end
    
    local resetBtn = CreateFrame("Button", nil, f)
    resetBtn:SetSize(30, 30)
    resetBtn:SetPoint("TOPLEFT", f, "TOPLEFT", 10 + 5*35, -45)
    LURA.summaryResetBtn = resetBtn
    
    local resetIcon = resetBtn:CreateTexture(nil, "ARTWORK")
    resetIcon:SetAllPoints()
    resetIcon:SetTexture(LURA.RESET_TEXTURE)
    
    resetBtn:SetScript("OnClick", function()
        if LURA.ResetSequence then
            LURA:ResetSequence()
        end
    end)
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
        if LURA.db.markers[i] == 9 then
            LURA.summaryTopSlotTextures[i]:Hide()
            LURA.summaryBottomSlotTextures[i]:Hide()
        else
            LURA.summaryTopSlotTextures[i]:Show()
            LURA.summaryBottomSlotTextures[i]:Show()
            
            local sequenceIndex = nil
            for idx, activeIndex in ipairs(activeIndices) do
                if activeIndex == i then
                    sequenceIndex = idx
                    break
                end
            end
            
            if sequenceIndex and LURA.currentSequence[sequenceIndex] then
                local symIdx = LURA.currentSequence[sequenceIndex]
                LURA.summaryBottomSlotTextures[i]:SetTexture(LURA.SYMBOL_TEXTURES[symIdx])
                LURA.summaryBottomSlotTextures[i]:SetVertexColor(1, 1, 1, 1)
            else
                LURA.summaryBottomSlotTextures[i]:SetTexture(nil)
                LURA.summaryBottomSlotTextures[i]:SetColorTexture(0.2, 0.2, 0.2, 1)
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
    
    local width = padding + 5 * spacing + 30 + padding
    
    if LUraInteractiveFrame and LURA.interactiveBtns then
        LUraInteractiveFrame:SetWidth(width)
        for i = 1, 5 do
            LURA.interactiveBtns[i]:SetPoint("LEFT", LUraInteractiveFrame, "LEFT", padding + (i-1)*spacing, 0)
        end
        if LURA.interactiveResetBtn then
            LURA.interactiveResetBtn:SetPoint("LEFT", LUraInteractiveFrame, "LEFT", padding + 5*spacing, 0)
        end
    end
    
    if LUraSummaryFrame and LURA.summaryTopSlotTextures then
        LUraSummaryFrame:SetWidth(width)
        for i = 1, 5 do
            LURA.summaryTopSlotTextures[i]:SetPoint("TOPLEFT", LUraSummaryFrame, "TOPLEFT", padding + (i-1)*spacing, -10)
            LURA.summaryBottomSlotTextures[i]:SetPoint("TOPLEFT", LUraSummaryFrame, "TOPLEFT", padding + (i-1)*spacing, -45)
        end
        if LURA.summaryResetBtn then
            LURA.summaryResetBtn:SetPoint("TOPLEFT", LUraSummaryFrame, "TOPLEFT", padding + 5*spacing, -45)
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
    chatYSlider:SetValue(LURA.db.chatOffsetY or -40)

    local chatEditY = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    chatEditY:SetSize(40, 20)
    chatEditY:SetPoint("LEFT", chatYSlider, "RIGHT", 15, 0)
    chatEditY:SetAutoFocus(false)
    chatEditY:SetText(tostring(LURA.db.chatOffsetY or -40))
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
    fontSlider:SetValue(LURA.db.chatFontSize or 29.5)

    local fontEdit = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    fontEdit:SetSize(40, 20)
    fontEdit:SetPoint("LEFT", fontSlider, "RIGHT", 15, 0)
    fontEdit:SetAutoFocus(false)
    fontEdit:SetText(tostring(LURA.db.chatFontSize or 29.5))
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
    
    f:Show()
    LURA.spacingPanel = f
end

function LURA:CreateDebugPanel()
    local f = CreateFrame("Frame", "LUraDebugFrame", UIParent)
    f:SetSize(130, 40)
    f:SetPoint("CENTER", 496, -70)
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    
    local tex = f:CreateTexture(nil, "BACKGROUND")
    tex:SetAllPoints()
    tex:SetColorTexture(0, 0, 0, 0.7)
    
    local btn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    btn:SetSize(110, 22)
    btn:SetPoint("CENTER", f, "CENTER", 0, 0)
    btn:SetText("Copy Warning")
    
    btn:SetScript("OnClick", function()
        if LURA.SendSequence then LURA:SendSequence() end
    end)
    
    LURA.debugFrame = f
end

function LURA:SendSequence()
    if not LURA.currentSequence or #LURA.currentSequence == 0 then
        print("LUra: Sequence is empty.")
        return
    end
    
    local symbolTextMap = {
        [1] = "O",
        [2] = "X",
        [3] = "V",
        [4] = "T",
        [5] = "^",
    }
    
    local msg = ""
    for i, symIdx in ipairs(LURA.currentSequence) do
        local symStr = symbolTextMap[symIdx] or "?"
        msg = msg .. symStr .. (i < #LURA.currentSequence and " " or "")
    end
    
    local fullMsg = "/rw L'Ura Order: " .. msg
    
    LURA:ShowCopyWindow(fullMsg)
end

function LURA:ShowCopyWindow(text)
    if not LUraCopyFrame then
        local f = CreateFrame("Frame", "LUraCopyFrame", UIParent, "BasicFrameTemplateWithInset")
        f:SetSize(300, 100)
        f:SetPoint("CENTER", 0, 100)
        f:SetFrameStrata("DIALOG")
        
        f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        f.title:SetPoint("TOP", f, "TOP", 0, -5)
        f.title:SetText("Copy Raid Warning (Press Ctrl+C)")
        
        local scrollFrame = CreateFrame("ScrollFrame", "LUraCopyScrollFrame", f)
        scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -35)
        scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, 45)
        
        local editBox = CreateFrame("EditBox", "LUraCopyEditBox", scrollFrame)
        editBox:SetSize(276, 30)
        editBox:SetMultiLine(true)
        editBox:SetFontObject("ChatFontNormal")
        editBox:SetMaxLetters(999)
        editBox:SetAutoFocus(true)
        editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() f:Hide() end)
        scrollFrame:SetScrollChild(editBox)
        f.editBox = editBox
        
        local actionBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        actionBtn:SetSize(80, 22)
        actionBtn:SetPoint("BOTTOM", f, "BOTTOM", 0, 12)
        actionBtn:SetText("Close")
        actionBtn:SetScript("OnClick", function() f:Hide() end)
    end
    
    LUraCopyFrame.editBox:SetText(text)
    LUraCopyFrame.editBox:HighlightText()
    LUraCopyFrame:Show()
end
