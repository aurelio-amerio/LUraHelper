local addonName, LURA = ...
_G.LUraGame = LURA

-- Shared constants (used by other files via LURA namespace)
LURA.SYMBOL_TEXTURES = {
    "Interface\\AddOns\\LUraHelper\\textures\\O",
    "Interface\\AddOns\\LUraHelper\\textures\\X",
    "Interface\\AddOns\\LUraHelper\\textures\\Delta",
    "Interface\\AddOns\\LUraHelper\\textures\\T",
}
LURA.SYMBOL_TEXTS = {
    "●",
    "x",
    "▼",
    "T",
    "◆",
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
-- Listen on multiple channels as fallback (Midnight combat restrictions)
frame:RegisterEvent("CHAT_MSG_RAID_WARNING")
frame:RegisterEvent("CHAT_MSG_RAID")
frame:RegisterEvent("CHAT_MSG_RAID_LEADER")
frame:RegisterEvent("CHAT_MSG_INSTANCE_CHAT")
frame:RegisterEvent("CHAT_MSG_INSTANCE_CHAT_LEADER")
frame:RegisterEvent("CHAT_MSG_SAY")
frame:RegisterEvent("CHAT_MSG_YELL")
-- TODO: Re-enable zone-based visibility once encounter detection is working
-- frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
-- frame:RegisterEvent("ENCOUNTER_START")
-- frame:RegisterEvent("ENCOUNTER_END")

-- Chat events that carry "L'Ura Order:" messages
local CHAT_EVENTS = {
    CHAT_MSG_RAID_WARNING = true,
    CHAT_MSG_RAID = true,
    CHAT_MSG_RAID_LEADER = true,
    CHAT_MSG_INSTANCE_CHAT = true,
    CHAT_MSG_INSTANCE_CHAT_LEADER = true,
    CHAT_MSG_SAY = true,
    CHAT_MSG_YELL = true,
}

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
                showRLTools = false,
                chatChannel = 4,
                chatFontSize = 29,
                boxSpacing = 36,
                boxPadding = 6,
                chatOffsetX = -175,
                chatOffsetY = -35,
                summaryPos = { point = "CENTER", x = 0, y = 200 },
                interactivePos = { point = "CENTER", x = 496, y = -22 },
                summaryScale = 1.0,
                interactiveScale = 1.0,
            }
        end
        local profile = LUraHelperDB.profiles[LUraHelperDB.activeProfile]
        if profile.locked == nil then profile.locked = false end
        if profile.hidden == nil then profile.hidden = false end
        if profile.showRLTools == nil then profile.showRLTools = false end
        if profile.chatChannel == nil then profile.chatChannel = 4 end
        if profile.chatFontSize == nil then profile.chatFontSize = 29 end
        if profile.boxSpacing == nil then profile.boxSpacing = 36 end
        if profile.boxPadding == nil then profile.boxPadding = 6 end
        if profile.chatOffsetX == nil then profile.chatOffsetX = -175 end
        if profile.chatOffsetY == nil then profile.chatOffsetY = -35 end
        if not profile.summaryPos then profile.summaryPos = { point = "CENTER", x = 0, y = 200 } end
        if not profile.interactivePos then profile.interactivePos = { point = "CENTER", x = 496, y = -22 } end
        if not profile.summaryScale then profile.summaryScale = 1.0 end
        if not profile.interactiveScale then profile.interactiveScale = 1.0 end
        LURA.db = profile
        
        -- Create UI
        LURA:CreateOptionsPanel()
        LURA:CreateInteractivePanel()
        LURA:CreateSummaryPanel()
        LURA:CreateChatPanel()
        LURA:CreateSpacingPanel()
        
        LURA:ApplyVisibility()
        LURA:ApplyLockState()
        LURA:ApplyScale()
    elseif event == "PLAYER_ENTERING_WORLD" then
        if LURA.db then
            LURA:ApplyVisibility()
        end
    elseif CHAT_EVENTS[event] then
        if type(arg1) == "string" and arg1:match("^L'Ura Order:") then
            print("|cff00ff00LUra:|r Received order via " .. event)
            if LURA.ProcessChatCommand then
                LURA:ProcessChatCommand(arg1)
            end
        end
    -- TODO: Re-enable zone-based visibility once encounter detection is working
    -- elseif event == "ZONE_CHANGED_NEW_AREA" then
    --     if LURA.db then
    --         LURA:ApplyVisibility()
    --     end
    -- elseif event == "ENCOUNTER_START" then
    --     LURA.currentEncounter = arg1
    --     if LURA.db then LURA:ApplyVisibility() end
    -- elseif event == "ENCOUNTER_END" then
    --     LURA.currentEncounter = nil
    --     if LURA.db then LURA:ApplyVisibility() end
    end
end)

-- TODO: Re-enable zone-based visibility once encounter detection is working
-- Zone & Visibility Logic
-- function LURA:IsInValidZone()
--     local _, _, _, _, _, _, _, instanceMapId = GetInstanceInfo()
--     
--     -- Valid only during the Midnight Falls L'ura fight
--     local TARGET_MAP_ID = 2913
--     local TARGET_ENCOUNTER_ID = 2740
--     
--     if instanceMapId == TARGET_MAP_ID and LURA.currentEncounter == TARGET_ENCOUNTER_ID then
--         return true
--     end
--     
--     return false
-- end

function LURA:ApplyVisibility()
    if not LUraInteractiveFrame or not LUraSummaryFrame then return end
    
    local shouldShow = not LURA.db.hidden
    
    if shouldShow then
        LURA:UpdateSummaryPanel()
        LUraSummaryFrame:Show()
        if LUraChatFrame then LUraChatFrame:Show() end
        if LURA.db.showRLTools then
            LUraInteractiveFrame:Show()
        else
            LUraInteractiveFrame:Hide()
        end
    else
        LUraInteractiveFrame:Hide()
        LUraSummaryFrame:Hide()
        if LUraChatFrame then LUraChatFrame:Hide() end
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
        if LUraChatFrame and LUraChatFrame.dragHandle then
            LUraChatFrame.dragHandle:Hide()
        end
    else
        LUraInteractiveFrame:SetScript("OnDragStart", LUraInteractiveFrame.StartMoving)
        LUraInteractiveFrame:SetScript("OnDragStop", LUraInteractiveFrame.StopMovingOrSizing)
        LUraSummaryFrame:SetScript("OnDragStart", LUraSummaryFrame.StartMoving)
        LUraSummaryFrame:SetScript("OnDragStop", LUraSummaryFrame.StopMovingOrSizing)
    end
end
-- Helper: apply scale to a frame while keeping its visual center position
local function SetScaleFromCenter(frame, newScale)
    local oldScale = frame:GetScale()
    local point, relativeTo, relativePoint, xOfs, yOfs = frame:GetPoint()
    if not point then return end
    
    local width = frame:GetWidth()
    local height = frame:GetHeight()
    
    -- Compute the old center in screen space
    local oldCenterX = xOfs * oldScale + (width * oldScale) / 2
    local oldCenterY = yOfs * oldScale + (height * oldScale) / 2
    
    -- Compute new offsets so the center stays in the same screen position
    local newXOfs = (oldCenterX - (width * newScale) / 2) / newScale
    local newYOfs = (oldCenterY - (height * newScale) / 2) / newScale
    
    frame:SetScale(newScale)
    frame:ClearAllPoints()
    frame:SetPoint(point, relativeTo, relativePoint, newXOfs, newYOfs)
end

function LURA:ApplyScale()
    if not LUraInteractiveFrame or not LUraSummaryFrame then return end
    local summaryScale = LURA.db.summaryScale or 1.0
    local interactiveScale = LURA.db.interactiveScale or 1.0
    SetScaleFromCenter(LUraSummaryFrame, summaryScale)
    SetScaleFromCenter(LUraInteractiveFrame, interactiveScale)
end
