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
    
    for i = 1, 5 do
        local btn = CreateFrame("Button", nil, f)
        btn:SetSize(30, 30)
        btn:SetPoint("LEFT", f, "LEFT", 10 + (i-1)*35, 0)
        
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
    
    if LURA.summaryResetBtn then
        LURA.summaryResetBtn:SetPoint("TOPLEFT", LUraSummaryFrame, "TOPLEFT", 10 + 5 * 35, -45)
    end
    
    LUraSummaryFrame:SetWidth(230)
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
