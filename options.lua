local _, LURA = ...

-- Helper: create a scale slider with a paired numeric input field
local function CreateScaleControl(parent, label, anchorTo, dbKey)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(400, 40)
    container:SetPoint("TOPLEFT", anchorTo, "BOTTOMLEFT", 0, -16)

    local sliderLabel = container:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    sliderLabel:SetPoint("TOPLEFT", 0, 0)
    sliderLabel:SetText(label)

    local slider = CreateFrame("Slider", nil, container, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", sliderLabel, "BOTTOMLEFT", 0, -4)
    slider:SetSize(200, 16)
    slider:SetMinMaxValues(0.01, 5)
    slider:SetValueStep(0.01)
    slider:SetObeyStepOnDrag(true)
    slider.Low:SetText("0.01")
    slider.High:SetText("5")

    local editBox = CreateFrame("EditBox", nil, container, "InputBoxTemplate")
    editBox:SetSize(50, 20)
    editBox:SetPoint("LEFT", slider, "RIGHT", 15, 0)
    editBox:SetAutoFocus(false)
    editBox:SetMaxLetters(5)

    -- Slider drives editBox
    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value * 100 + 0.5) / 100
        LURA.db[dbKey] = value
        editBox:SetText(string.format("%.2f", value))
        LURA:ApplyScale()
    end)

    -- EditBox drives slider
    editBox:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then
            val = math.max(0.01, math.min(5, val))
            slider:SetValue(val)
        end
        self:ClearFocus()
    end)
    editBox:SetScript("OnEscapePressed", function(self)
        self:SetText(string.format("%.2f", LURA.db[dbKey] or 1.0))
        self:ClearFocus()
    end)

    container.slider = slider
    container.editBox = editBox

    -- Set initial value from DB
    local initVal = LURA.db[dbKey] or 1.0
    slider:SetValue(initVal)
    editBox:SetText(string.format("%.2f", initVal))

    return container
end

-- Options Panel
function LURA:CreateOptionsPanel()
    local panel = CreateFrame("Frame", "LUraMemoryOptionsPanel", InterfaceOptionsFramePanelContainer)
    panel.name = "L'Ura Helper"
    
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("L'Ura Helper Options")
    
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

    local chatChannelLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    chatChannelLabel:SetPoint("TOPLEFT", hideBtn, "BOTTOMLEFT", 0, -12)
    chatChannelLabel:SetText("Listen Channel Number:")

    local chatChannelEditBox = CreateFrame("EditBox", "LUraChatChannelEditBox", panel, "InputBoxTemplate")
    chatChannelEditBox:SetSize(40, 20)
    chatChannelEditBox:SetPoint("LEFT", chatChannelLabel, "RIGHT", 10, 0)
    chatChannelEditBox:SetAutoFocus(false)
    chatChannelEditBox:SetNumeric(true)
    chatChannelEditBox:SetMaxLetters(2)
    chatChannelEditBox:SetScript("OnTextChanged", function(self, isUserInput)
        if isUserInput then
            local val = tonumber(self:GetText())
            if val then
                LURA.db.chatChannel = val
                if LURA.chatFrame and LURA.chatFrame.UpdateTitle then
                    LURA.chatFrame:UpdateTitle()
                end
            end
        end
    end)
    LURA.chatChannelEditBox = chatChannelEditBox

    -- TODO: Re-enable Test Mode once zone-based visibility is working
    -- local testCheck = CreateFrame("CheckButton", "LUraTestCheck", panel, "UICheckButtonTemplate")
    -- testCheck:SetPoint("TOPLEFT", hideBtn, "BOTTOMLEFT", 0, -8)
    -- _G[testCheck:GetName().."Text"]:SetText("Test Mode (Force Display)")
    -- testCheck:SetScript("OnClick", function(self)
    --     LURA.testMode = self:GetChecked()
    --     LURA:ApplyVisibility()
    -- end)
    -- LURA.testCheck = testCheck

    local profileTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    profileTitle:SetPoint("TOPLEFT", chatChannelLabel, "BOTTOMLEFT", 0, -20)
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
            info.checked = (LUraHelperDB.activeProfile == name)
            UIDropDownMenu_AddButton(info)
        end
    end)
    UIDropDownMenu_SetText(profileDropdown, LUraHelperDB.activeProfile)
    LURA.profileDropdown = profileDropdown

    -- New Profile button
    local newProfileBtn = CreateFrame("Button", "LUraNewProfileBtn", panel, "UIPanelButtonTemplate")
    newProfileBtn:SetSize(60, 22)
    newProfileBtn:SetPoint("LEFT", profileDropdown, "RIGHT", -10, 2)
    newProfileBtn:SetText("New")
    newProfileBtn:SetScript("OnClick", function()
        LURA:ShowProfileNameDialog(function(name)
            if LUraHelperDB.profiles[name] then
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
        local current = LUraHelperDB.activeProfile
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

    local defaultsBtn = CreateFrame("Button", "LUraRestoreDefaultsBtn", panel, "UIPanelButtonTemplate")
    defaultsBtn:SetSize(130, 22)
    defaultsBtn:SetPoint("TOPLEFT", profileDropdown, "BOTTOMLEFT", 15, -8)
    defaultsBtn:SetText("Restore Defaults")
    defaultsBtn:SetScript("OnClick", function()
        LURA.db.markers = {1, 2, 3, 4, 5}
        LURA.db.locked = false
        LURA.db.hidden = false
        LURA.db.chatChannel = 4
        LURA.db.summaryScale = 1.0
        LURA.db.interactiveScale = 1.0
        LURA.db.boxSpacing = 36
        LURA.db.boxPadding = 6
        LURA.db.chatOffsetX = -212
        LURA.db.chatOffsetY = -40
        LURA.db.chatFontSize = 29
        LURA.testMode = false
        
        if LUraSpaceSlider then LUraSpaceSlider:SetValue(36) end
        if LUraPadSlider then LUraPadSlider:SetValue(6) end
        if LUraChatSlider then LUraChatSlider:SetValue(-212) end
        if LUraChatYSlider then LUraChatYSlider:SetValue(-40) end
        if LUraFontSlider then LUraFontSlider:SetValue(29) end
        if LURA.ApplyBoxSpacing then LURA:ApplyBoxSpacing() end
        if LURA.ApplyChatOffset then LURA:ApplyChatOffset() end
        if LURA.ApplyChatFont then LURA:ApplyChatFont() end
        
        -- Reset scale first (direct SetScale to avoid center-compensation)
        if LUraSummaryFrame then LUraSummaryFrame:SetScale(1.0) end
        if LUraInteractiveFrame then LUraInteractiveFrame:SetScale(1.0) end
        
        -- Then reset positions
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
        
        LURA:ApplyScale()
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
    markerTitle:SetPoint("TOPLEFT", defaultsBtn, "BOTTOMLEFT", 0, -24)
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

    -- Scale Controls
    local scaleTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    scaleTitle:SetPoint("TOPLEFT", _G["LUraMarkerDropdown1"], "BOTTOMLEFT", 15, -16)
    scaleTitle:SetText("Panel Scale")

    local summaryScaleCtrl = CreateScaleControl(panel, "Summary Panel Scale", scaleTitle, "summaryScale")
    LURA.summaryScaleCtrl = summaryScaleCtrl

    local interactiveScaleCtrl = CreateScaleControl(panel, "Interactive Panel Scale", summaryScaleCtrl, "interactiveScale")
    LURA.interactiveScaleCtrl = interactiveScaleCtrl

    local credits = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    credits:SetPoint("BOTTOMRIGHT", -16, 16)
    credits:SetText("Made by Deino for Poetic Justice - Ravencrest")

    LURA:UpdateOptionsPanel()

    SLASH_LURA1 = "/lura"
    SlashCmdList["LURA"] = function(msg)
        local raw = strtrim(msg or "")
        local cmd, arg = string.match(string.lower(raw), "^(%S+)%s*(.*)$")
        if not cmd then cmd = string.lower(raw) end
        
        if cmd == "help" then
            print("|cff00ccffL'Ura Helper|r — Slash Commands:")
            print("  |cff66ff66/lura|r — Open the options panel")
            print("  |cff66ff66/lura help|r — Show this help message")
            print("  |cff66ff66/lura toggle|r — Toggle panel visibility (hide/show)")
            print("  |cff66ff66/lura lock|r — Lock panel positions")
            print("  |cff66ff66/lura unlock|r — Unlock panel positions")
            print("  |cff66ff66/lura font <size>|r — Sets the chat font size (e.g. /lura font 24)")
            print("  |cff66ff66/lura spacing|r — Open the panel to tune symbols spacing")
            -- TODO: Re-enable once zone-based visibility is working
            -- print("  |cff66ff66/lura test|r — Toggle Test Mode (force display outside encounter)")
        elseif cmd == "toggle" then
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
        elseif cmd == "send" then
            if LURA.SendSequence then LURA:SendSequence() end
        -- TODO: Re-enable once zone-based visibility is working
        -- elseif cmd == "test" then
        --     LURA.testMode = not LURA.testMode
        --     LURA:ApplyVisibility()
        --     LURA:UpdateOptionsPanel()
        --     print("LUra: Test Mode is now " .. (LURA.testMode and "ON" or "OFF"))
        elseif cmd == "font" then
            local size = tonumber(arg)
            if size and size > 0 then
                LURA.db.chatFontSize = size
                if LURA.ApplyChatFont then LURA:ApplyChatFont() end
                print("|cff00ccffL'Ura Helper|r — Chat font size set to " .. size)
            else
                print("|cff00ccffL'Ura Helper|r — Usage: /lura font <size>")
            end
        elseif cmd == "spacing" then
            if LURA.spacingPanel then
                if LURA.spacingPanel:IsShown() then
                    LURA.spacingPanel:Hide()
                else
                    LURA.spacingPanel:Show()
                end
            end
        else
            Settings.OpenToCategory(category:GetID())
        end
    end
end

function LURA:UpdateOptionsPanel()
    if LURA.lockBtn then LURA.lockBtn:SetChecked(LURA.db.locked) end
    if LURA.hideBtn then LURA.hideBtn:SetChecked(LURA.db.hidden) end
    if LURA.chatChannelEditBox then
        LURA.chatChannelEditBox:SetText(tostring(LURA.db.chatChannel or 4))
    end
    -- if LURA.testCheck then LURA.testCheck:SetChecked(LURA.testMode) end
    if LURA.profileDropdown then
        UIDropDownMenu_SetText(LURA.profileDropdown, LUraHelperDB.activeProfile)
    end
    if LURA.summaryScaleCtrl then
        local val = LURA.db.summaryScale or 1.0
        LURA.summaryScaleCtrl.slider:SetValue(val)
        LURA.summaryScaleCtrl.editBox:SetText(string.format("%.2f", val))
    end
    if LURA.interactiveScaleCtrl then
        local val = LURA.db.interactiveScale or 1.0
        LURA.interactiveScaleCtrl.slider:SetValue(val)
        LURA.interactiveScaleCtrl.editBox:SetText(string.format("%.2f", val))
    end
end

