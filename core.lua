local addonName, LURA = ...
_G.LUraGame = LURA

-- Shared constants (used by other files via LURA namespace)
LURA.SYMBOL_TEXTURES = {
    "Interface\\AddOns\\LUraHelper\\textures\\O",
    "Interface\\AddOns\\LUraHelper\\textures\\X",
    "Interface\\AddOns\\LUraHelper\\textures\\Delta",
    "Interface\\AddOns\\LUraHelper\\textures\\T",
    "Interface\\AddOns\\LUraHelper\\textures\\Diamond",
}
LURA.RESET_TEXTURE = "Interface\\AddOns\\LUraHelper\\textures\\Cancel"

LURA.MARKER_TEXTURES = {
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1", -- Star
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2", -- Circle
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3", -- Diamond
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4", -- Triangle
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5", -- Moon
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6", -- Square
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7", -- Cross
    "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8", -- Skull
    nil, -- None
}

LURA.MARKER_NAMES = {
    "Star", "Circle", "Diamond", "Triangle", "Moon", "Square", "Cross", "Skull", "None"
}

-- Event Handling & Initialization
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
frame:RegisterEvent("ENCOUNTER_START")
frame:RegisterEvent("ENCOUNTER_END")
frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        LURA.testMode = false
        -- Init Database (with profile migration)
        if type(LUraHelperDB) ~= "table" then
            LUraHelperDB = {}
        end
        -- Migrate flat DB → profiles structure
        if not LUraHelperDB.profiles then
            local oldData = {
                markers = LUraHelperDB.markers or {1, 2, 3, 4, 5},
                locked = LUraHelperDB.locked or false,
                hidden = LUraHelperDB.hidden or false,
                summaryPos = { point = "CENTER", x = 496, y = 49 },
                interactivePos = { point = "CENTER", x = 496, y = -22 },
            }
            LUraHelperDB = {
                activeProfile = "Default",
                profiles = {
                    ["Default"] = oldData,
                },
            }
        end
        if not LUraHelperDB.activeProfile then
            LUraHelperDB.activeProfile = "Default"
        end
        if not LUraHelperDB.profiles[LUraHelperDB.activeProfile] then
            LUraHelperDB.activeProfile = "Default"
        end
        if not LUraHelperDB.profiles["Default"] then
            LUraHelperDB.profiles["Default"] = {
                markers = {1, 2, 3, 4, 5},
                locked = false,
                hidden = false,
                summaryPos = { point = "CENTER", x = 496, y = 49 },
                interactivePos = { point = "CENTER", x = 496, y = -22 },
            }
        end
        local profile = LUraHelperDB.profiles[LUraHelperDB.activeProfile]
        if profile.locked == nil then profile.locked = false end
        if profile.hidden == nil then profile.hidden = false end
        if not profile.summaryPos then profile.summaryPos = { point = "CENTER", x = 496, y = 49 } end
        if not profile.interactivePos then profile.interactivePos = { point = "CENTER", x = 496, y = -22 } end
        LURA.db = profile
        
        -- Create UI
        LURA:CreateOptionsPanel()
        LURA:CreateInteractivePanel()
        LURA:CreateSummaryPanel()
        
        LURA:ApplyVisibility()
        LURA:ApplyLockState()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        if LURA.db then
            LURA:ApplyVisibility()
        end
    elseif event == "ENCOUNTER_START" then
        LURA.currentEncounter = arg1
        if LURA.db then LURA:ApplyVisibility() end
    elseif event == "ENCOUNTER_END" then
        LURA.currentEncounter = nil
        if LURA.db then LURA:ApplyVisibility() end
    end
end)

-- Zone & Visibility Logic
function LURA:IsInValidZone()
    local _, _, _, _, _, _, _, instanceMapId = GetInstanceInfo()
    
    -- Valid only during the Midnight Falls L'ura fight
    local TARGET_MAP_ID = 2913
    local TARGET_ENCOUNTER_ID = 2740
    
    if instanceMapId == TARGET_MAP_ID and LURA.currentEncounter == TARGET_ENCOUNTER_ID then
        return true
    end
    
    return false
end

function LURA:ApplyVisibility()
    if not LUraInteractiveFrame or not LUraSummaryFrame then return end
    
    local inValidZone = LURA:IsInValidZone()
    local shouldShow = ((inValidZone or LURA.testMode) and not LURA.db.hidden)
    
    if shouldShow then
        LURA:UpdateSummaryPanel()
        LUraInteractiveFrame:Show()
        LUraSummaryFrame:Show()
    else
        LUraInteractiveFrame:Hide()
        LUraSummaryFrame:Hide()
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
