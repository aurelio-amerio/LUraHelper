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
        if not LUraMemoryGameDB then
            LUraMemoryGameDB = {
                markers = {1, 2, 3, 4, 5} -- Default to first 5 markers
            }
        end
        LURA.db = LUraMemoryGameDB
        
        -- Task 2: Create Options
        LURA:CreateOptionsPanel()
        
        -- Task 3: Create Interactive Panel
        LURA:CreateInteractivePanel()
        
        -- Task 4 Setup (Placeholder)
        -- LURA:CreateSummaryPanel()
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

    SLASH_LURA1 = "/lura"
    SlashCmdList["LURA"] = function(msg)
        Settings.OpenToCategory(category:GetID())
    end
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
