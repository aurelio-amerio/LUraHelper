local addonName, LURA = ...
_G.LUraGame = LURA

-- Utility symbols for our UI
local SYMBOL_TEXTURES = {
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2", -- Circle
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7", -- Cross / X
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4", -- Delta / Triangle
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6", -- Tau / Square
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3", -- Diamond
}
local RESET_TEXTURE = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8" -- Skull as reset for now

local MARKER_TEXTURES = {
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1", -- Star
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2", -- Circle
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3", -- Diamond
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4", -- Triangle
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5", -- Moon
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6", -- Square
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7", -- Cross
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8", -- Skull
}

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        -- Task 1: Init Database
        if type(LUraMemoryGameDB) ~= "table" then
            LUraMemoryGameDB = {
                markers = {1, 2, 3, 4, 5},
                locked = false,
                hidden = false
            }
        end
        if LUraMemoryGameDB.locked == nil then LUraMemoryGameDB.locked = false end
        if LUraMemoryGameDB.hidden == nil then LUraMemoryGameDB.hidden = false end
        LURA.db = LUraMemoryGameDB
        
        -- Task 2: Create Options
        LURA:CreateOptionsPanel()
        
        -- Task 3: Create Interactive Panel
        LURA:CreateInteractivePanel()
        
        -- Task 4 Setup
        LURA:CreateSummaryPanel()
        
        LURA:ApplyVisibility()
        LURA:ApplyLockState()
    end
end)

-- Task 2: Options Panel
function LURA:CreateOptionsPanel()
    local panel = CreateFrame("Frame", "LUraMemoryOptionsPanel", InterfaceOptionsFramePanelContainer)
    panel.name = "L'Ura Memory Game"
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("L'Ura Memory Game Options")
    
    local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    desc:SetText("Options for configuring target markers will go here.")
    
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
    LURA.optionsCategory = category

    local lockBtn = CreateFrame("CheckButton", "LUraLockCheck", panel, "UICheckButtonTemplate")
    lockBtn:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -16)
    _G[lockBtn:GetName().."Text"]:SetText("Lock Addon Frames")
    lockBtn:SetScript("OnClick", function(self)
        LURA.db.locked = self:GetChecked()
        LURA:ApplyLockState()
    end)
    LURA.lockBtn = lockBtn
    
    local hideBtn = CreateFrame("CheckButton", "LUraHideCheck", panel, "UICheckButtonTemplate")
    hideBtn:SetPoint("TOPLEFT", lockBtn, "BOTTOMLEFT", 0, -8)
    _G[hideBtn:GetName().."Text"]:SetText("Hide Addon Panels")
    hideBtn:SetScript("OnClick", function(self)
        LURA.db.hidden = self:GetChecked()
        LURA:ApplyVisibility()
    end)
    LURA.hideBtn = hideBtn

    LURA:UpdateOptionsPanel()

    SLASH_LURA1 = "/lura"
    SlashCmdList["LURA"] = function(msg)
        local cmd = string.lower(strtrim(msg or ""))
        if cmd == "toggle" then
            LURA.db.hidden = not LURA.db.hidden
            LURA:ApplyVisibility()
            LURA:UpdateOptionsPanel()
        elseif cmd == "lock" then
            LURA.db.locked = true
            LURA:ApplyLockState()
            LURA:UpdateOptionsPanel()
        elseif cmd == "unlock" then
            LURA.db.locked = false
            LURA:ApplyLockState()
            LURA:UpdateOptionsPanel()
        else
            Settings.OpenToCategory(category:GetID())
        end
    end
end

function LURA:UpdateOptionsPanel()
    if LURA.lockBtn then LURA.lockBtn:SetChecked(LURA.db.locked) end
    if LURA.hideBtn then LURA.hideBtn:SetChecked(LURA.db.hidden) end
end

-- Task 3: Interactive Panel
function LURA:CreateInteractivePanel()
    local f = CreateFrame("Frame", "LUraInteractiveFrame", UIParent)
    f:SetSize(230, 40)
    f:SetPoint("CENTER", 0, -150)
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
        icon:SetTexture(SYMBOL_TEXTURES[i])
        
        btn:SetScript("OnClick", function()
            if LURA.AddSymbolToSequence then
                LURA:AddSymbolToSequence(i)
            end
        end)
    end
    
    -- Reset Button
    local resetBtn = CreateFrame("Button", nil, f)
    resetBtn:SetSize(30, 30)
    resetBtn:SetPoint("LEFT", f, "LEFT", 10 + 5*35, 0)
    
    local resetIcon = resetBtn:CreateTexture(nil, "BACKGROUND")
    resetIcon:SetAllPoints()
    resetIcon:SetTexture(RESET_TEXTURE)
    
    resetBtn:SetScript("OnClick", function()
        if LURA.ResetSequence then
            LURA:ResetSequence()
        end
    end)
end

-- Task 4: Summary Panel & Logic
LURA.currentSequence = {}

function LURA:AddSymbolToSequence(symbolIndex)
    if #LURA.currentSequence >= 5 then return end
    table.insert(LURA.currentSequence, SYMBOL_TEXTURES[symbolIndex])
    LURA:UpdateSummaryPanel()
end

function LURA:ResetSequence()
    LURA.currentSequence = {}
    LURA:UpdateSummaryPanel()
end

function LURA:CreateSummaryPanel()
    local f = CreateFrame("Frame", "LUraSummaryFrame", UIParent)
    f:SetSize(230, 80)
    f:SetPoint("CENTER", 0, -50)
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
        topIcon:SetTexture(MARKER_TEXTURES[dbMarkerIndex])
        LURA.summaryTopSlotTextures[i] = topIcon
    end
    
    for i = 1, 5 do
        local btmIcon = f:CreateTexture(nil, "ARTWORK")
        btmIcon:SetSize(30, 30)
        btmIcon:SetPoint("TOPLEFT", f, "TOPLEFT", 10 + (i-1)*35, -45)
        btmIcon:SetColorTexture(0.2, 0.2, 0.2, 1)
        LURA.summaryBottomSlotTextures[i] = btmIcon
    end
end

function LURA:UpdateSummaryPanel()
    if not LUraSummaryFrame then return end
    for i = 1, 5 do
        if LURA.currentSequence[i] then
            LURA.summaryBottomSlotTextures[i]:SetTexture(LURA.currentSequence[i])
            LURA.summaryBottomSlotTextures[i]:SetColorTexture(1, 1, 1, 1)
        else
            LURA.summaryBottomSlotTextures[i]:SetTexture(nil)
            LURA.summaryBottomSlotTextures[i]:SetColorTexture(0.2, 0.2, 0.2, 1)
        end
    end
end

function LURA:ApplyVisibility()
    if not LUraInteractiveFrame or not LUraSummaryFrame then return end
    if LURA.db.hidden then
        LUraInteractiveFrame:Hide()
        LUraSummaryFrame:Hide()
    else
        LUraInteractiveFrame:Show()
        LUraSummaryFrame:Show()
    end
end

function LURA:ApplyLockState()
    if not LUraInteractiveFrame or not LUraSummaryFrame then return end
    local locked = LURA.db.locked
    
    if locked then
        LUraInteractiveFrame:SetScript("OnDragStart", nil)
        LUraInteractiveFrame:SetScript("OnDragStop", nil)
        LUraSummaryFrame:SetScript("OnDragStart", nil)
        LUraSummaryFrame:SetScript("OnDragStop", nil)
    else
        LUraInteractiveFrame:SetScript("OnDragStart", LUraInteractiveFrame.StartMoving)
        LUraInteractiveFrame:SetScript("OnDragStop", LUraInteractiveFrame.StopMovingOrSizing)
        LUraSummaryFrame:SetScript("OnDragStart", LUraSummaryFrame.StartMoving)
        LUraSummaryFrame:SetScript("OnDragStop", LUraSummaryFrame.StopMovingOrSizing)
    end
end
