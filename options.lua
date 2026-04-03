local _, LURA = ...

-- Options Panel
function LURA:CreateOptionsPanel()
    local panel = CreateFrame("Frame", "LUraMemoryOptionsPanel", InterfaceOptionsFramePanelContainer)
    panel.name = "L'Ura Memory Game"
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("L'Ura Memory Game Options")
    
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
    LURA.optionsCategory = category

    local generalTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    generalTitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -20)
    generalTitle:SetText("General Settings")

    local lockBtn = CreateFrame("CheckButton", "LUraLockCheck", panel, "UICheckButtonTemplate")
    lockBtn:SetPoint("TOPLEFT", generalTitle, "BOTTOMLEFT", 0, -12)
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

    local testCheck = CreateFrame("CheckButton", "LUraTestCheck", panel, "UICheckButtonTemplate")
    testCheck:SetPoint("TOPLEFT", hideBtn, "BOTTOMLEFT", 0, -8)
    _G[testCheck:GetName().."Text"]:SetText("Test Mode (Force Display)")
    testCheck:SetScript("OnClick", function(self)
        LURA.testMode = self:GetChecked()
        LURA:ApplyVisibility()
    end)
    LURA.testCheck = testCheck

    local profileTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    profileTitle:SetPoint("TOPLEFT", testCheck, "BOTTOMLEFT", 0, -20)
    profileTitle:SetText("Profile & Tools")

    -- Profile dropdown
    local profileDropdown = CreateFrame("Frame", "LUraProfileDropdown", panel, "UIDropDownMenuTemplate")
    profileDropdown:SetPoint("TOPLEFT", profileTitle, "BOTTOMLEFT", -15, -4)
    UIDropDownMenu_SetWidth(profileDropdown, 140)
    UIDropDownMenu_Initialize(profileDropdown, function(self, level, menuList)
        local names = LURA:GetProfileNames()
        for _, name in ipairs(names) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = name
            info.arg1 = name
            info.func = function(self, arg1)
                LURA:SwitchProfile(arg1)
            end
            info.checked = (LUraMemoryGameDB.activeProfile == name)
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(profileDropdown, LUraMemoryGameDB.activeProfile)
    LURA.profileDropdown = profileDropdown

    -- New Profile button
    local newProfileBtn = CreateFrame("Button", "LUraNewProfileBtn", panel, "UIPanelButtonTemplate")
    newProfileBtn:SetSize(60, 22)
    newProfileBtn:SetPoint("LEFT", profileDropdown, "RIGHT", -10, 2)
    newProfileBtn:SetText("New")
    newProfileBtn:SetScript("OnClick", function()
        LURA:ShowProfileNameDialog(function(name)
            if LUraMemoryGameDB.profiles[name] then
                LURA:ShowOverwriteConfirmDialog(name, function()
                    LURA:CreateNewProfile(name)
                end)
            else
                LURA:CreateNewProfile(name)
            end
        end, "")
    end)

    -- Delete Profile button
    local delProfileBtn = CreateFrame("Button", "LUraDelProfileBtn", panel, "UIPanelButtonTemplate")
    delProfileBtn:SetSize(60, 22)
    delProfileBtn:SetPoint("LEFT", newProfileBtn, "RIGHT", 5, 0)
    delProfileBtn:SetText("Delete")
    delProfileBtn:SetScript("OnClick", function()
        local current = LUraMemoryGameDB.activeProfile
        if current == "Default" then
            print("LUra: Cannot delete the Default profile.")
            return
        end
        StaticPopupDialogs["LURA_DELETE_PROFILE"] = {
            text = "Delete profile '%s'?",
            button1 = "Delete",
            button2 = "Cancel",
            OnAccept = function()
                LURA:DeleteProfile(current)
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("LURA_DELETE_PROFILE", current)
    end)

    local resetPosBtn = CreateFrame("Button", "LUraResetPosBtn", panel, "UIPanelButtonTemplate")
    resetPosBtn:SetSize(120, 22)
    resetPosBtn:SetPoint("TOPLEFT", profileDropdown, "BOTTOMLEFT", 15, -8)
    resetPosBtn:SetText("Reset Position")
    resetPosBtn:SetScript("OnClick", function()
        if LUraSummaryFrame then
            LUraSummaryFrame:ClearAllPoints()
            LUraSummaryFrame:SetPoint("CENTER", 496, 49)
            LUraSummaryFrame:SetUserPlaced(false)
        end
        if LUraInteractiveFrame then
            LUraInteractiveFrame:ClearAllPoints()
            LUraInteractiveFrame:SetPoint("CENTER", 496, -22)
            LUraInteractiveFrame:SetUserPlaced(false)
        end
        LURA.db.summaryPos = { point = "CENTER", x = 496, y = 49 }
        LURA.db.interactivePos = { point = "CENTER", x = 496, y = -22 }
    end)

    local defaultsBtn = CreateFrame("Button", "LUraRestoreDefaultsBtn", panel, "UIPanelButtonTemplate")
    defaultsBtn:SetSize(130, 22)
    defaultsBtn:SetPoint("LEFT", resetPosBtn, "RIGHT", 15, 0)
    defaultsBtn:SetText("Restore Defaults")
    defaultsBtn:SetScript("OnClick", function()
        LURA.db.markers = {1, 2, 3, 4, 5}
        LURA.db.locked = false
        LURA.db.hidden = false
        LURA.testMode = false
        
        if LUraSummaryFrame then
            LUraSummaryFrame:ClearAllPoints()
            LUraSummaryFrame:SetPoint("CENTER", 496, 49)
            LUraSummaryFrame:SetUserPlaced(false)
        end
        if LUraInteractiveFrame then
            LUraInteractiveFrame:ClearAllPoints()
            LUraInteractiveFrame:SetPoint("CENTER", 496, -22)
            LUraInteractiveFrame:SetUserPlaced(false)
        end
        LURA.db.summaryPos = { point = "CENTER", x = 496, y = 49 }
        LURA.db.interactivePos = { point = "CENTER", x = 496, y = -22 }
        
        LURA:RefreshAllUI()
    end)

    local exportBtn = CreateFrame("Button", "LUraExportBtn", panel, "UIPanelButtonTemplate")
    exportBtn:SetSize(100, 22)
    exportBtn:SetPoint("LEFT", defaultsBtn, "RIGHT", 15, 0)
    exportBtn:SetText("Export")
    exportBtn:SetScript("OnClick", function()
        LURA:ShowImportExportWindow(true)
    end)

    local importBtn = CreateFrame("Button", "LUraImportBtn", panel, "UIPanelButtonTemplate")
    importBtn:SetSize(100, 22)
    importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 15, 0)
    importBtn:SetText("Import")
    importBtn:SetScript("OnClick", function()
        LURA:ShowImportExportWindow(false)
    end)

    local markerTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    markerTitle:SetPoint("TOPLEFT", resetPosBtn, "BOTTOMLEFT", 0, -24)
    markerTitle:SetText("Marker Sequence Configuration")

    local markerLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    markerLabel:SetPoint("TOPLEFT", markerTitle, "BOTTOMLEFT", 0, -8)
    markerLabel:SetText("Select the corresponding raid markers from left to right:")


    for i = 1, 5 do
        local dropdown = CreateFrame("Frame", "LUraMarkerDropdown" .. i, panel, "UIDropDownMenuTemplate")
        if i == 1 then
            dropdown:SetPoint("TOPLEFT", markerLabel, "BOTTOMLEFT", -15, -10)
        else
            dropdown:SetPoint("LEFT", _G["LUraMarkerDropdown" .. (i - 1)], "RIGHT", -15, 0)
        end
        
        UIDropDownMenu_SetWidth(dropdown, 75)
        UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            for k, v in ipairs(LURA.MARKER_NAMES) do
                info.text = v
                info.arg1 = k
                info.func = function(self, arg1)
                    LURA.db.markers[i] = arg1
                    UIDropDownMenu_SetSelectedID(dropdown, arg1)
                    UIDropDownMenu_SetText(dropdown, LURA.MARKER_NAMES[arg1])
                    if LURA.UpdateSummaryPanelMarkers then
                        LURA:UpdateSummaryPanelMarkers()
                    end
                end
                info.checked = LURA.db.markers[i] == k
                info.icon = LURA.MARKER_TEXTURES[k]
                UIDropDownMenu_AddButton(info)
            end
        end)
        UIDropDownMenu_SetSelectedID(dropdown, LURA.db.markers[i])
        UIDropDownMenu_SetText(dropdown, LURA.MARKER_NAMES[LURA.db.markers[i]])
    end

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
        elseif cmd == "test" then
            LURA.testMode = not LURA.testMode
            LURA:ApplyVisibility()
            LURA:UpdateOptionsPanel()
            print("LUra: Test Mode is now " .. (LURA.testMode and "ON" or "OFF"))
        elseif cmd == "pos" then
            if LUraSummaryFrame then
                local point, _, _, xOfs, yOfs = LUraSummaryFrame:GetPoint()
                print("LUra: SummaryFrame position: " .. tostring(point) .. " " .. tostring(xOfs) .. " " .. tostring(yOfs))
            end
            if LUraInteractiveFrame then
                local point, _, _, xOfs, yOfs = LUraInteractiveFrame:GetPoint()
                print("LUra: InteractiveFrame position: " .. tostring(point) .. " " .. tostring(xOfs) .. " " .. tostring(yOfs))
            end
        elseif cmd == "info" then
            local _, _, _, _, _, _, _, instanceMapId = GetInstanceInfo()
            print("LUra: Current Instance Map ID: " .. tostring(instanceMapId))
            if LURA.currentEncounter then
                print("LUra: Current Encounter ID: " .. tostring(LURA.currentEncounter))
            else
                print("LUra: No encounter in progress.")
            end
        else
            Settings.OpenToCategory(category:GetID())
        end
    end
end

function LURA:UpdateOptionsPanel()
    if LURA.lockBtn then LURA.lockBtn:SetChecked(LURA.db.locked) end
    if LURA.hideBtn then LURA.hideBtn:SetChecked(LURA.db.hidden) end
    if LURA.testCheck then LURA.testCheck:SetChecked(LURA.testMode) end
    if LURA.profileDropdown then
        UIDropDownMenu_SetText(LURA.profileDropdown, LUraMemoryGameDB.activeProfile)
    end
end
