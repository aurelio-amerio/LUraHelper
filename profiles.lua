local _, LURA = ...

-- Profile Management

function LURA:GetProfileNames()
    local names = {}
    for name in pairs(LUraHelperDB.profiles) do
        table.insert(names, name)
    end
    table.sort(names, function(a, b)
        if a == "Default" then return true end
        if b == "Default" then return false end
        return a < b
    end)
    return names
end

function LURA:DeepCopyProfile(src)
    local copy = {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            copy[k] = {}
            for k2, v2 in pairs(v) do
                copy[k][k2] = v2
            end
        else
            copy[k] = v
        end
    end
    return copy
end

function LURA:SaveCurrentPositions()
    if LUraSummaryFrame and LURA.db then
        local p, _, _, x, y = LUraSummaryFrame:GetPoint()
        LURA.db.summaryPos = { point = p or "CENTER", x = x or 496, y = y or 49 }
    end
    if LUraInteractiveFrame and LURA.db then
        local p, _, _, x, y = LUraInteractiveFrame:GetPoint()
        LURA.db.interactivePos = { point = p or "CENTER", x = x or 496, y = y or -22 }
    end
end

function LURA:ApplyProfilePositions()
    if not LURA.db then return end
    if LUraSummaryFrame and LURA.db.summaryPos then
        LUraSummaryFrame:ClearAllPoints()
        LUraSummaryFrame:SetPoint(LURA.db.summaryPos.point, UIParent, LURA.db.summaryPos.point, LURA.db.summaryPos.x, LURA.db.summaryPos.y)
    end
    if LUraInteractiveFrame and LURA.db.interactivePos then
        LUraInteractiveFrame:ClearAllPoints()
        LUraInteractiveFrame:SetPoint(LURA.db.interactivePos.point, UIParent, LURA.db.interactivePos.point, LURA.db.interactivePos.x, LURA.db.interactivePos.y)
    end
end

function LURA:SwitchProfile(name)
    if not LUraHelperDB.profiles[name] then return end
    -- Save current frame positions before switching
    LURA:SaveCurrentPositions()
    LUraHelperDB.activeProfile = name
    LURA.db = LUraHelperDB.profiles[name]
    LURA:ApplyProfilePositions()
    LURA:RefreshAllUI()
end

function LURA:CreateNewProfile(name)
    if not name or name == "" then return false end
    -- Capture current positions before copying
    LURA:SaveCurrentPositions()
    LUraHelperDB.profiles[name] = LURA:DeepCopyProfile(LURA.db)
    LURA:SwitchProfile(name)
    return true
end

function LURA:DeleteProfile(name)
    if name == "Default" then
        print("LUra: Cannot delete the Default profile.")
        return false
    end
    if not LUraHelperDB.profiles[name] then return false end
    LUraHelperDB.profiles[name] = nil
    if LUraHelperDB.activeProfile == name then
        LURA:SwitchProfile("Default")
    end
    return true
end

function LURA:RefreshAllUI()
    LURA:UpdateOptionsPanel()
    LURA:ApplyLockState()
    LURA:ApplyVisibility()
    if LURA.UpdateSummaryPanelMarkers then
        LURA:UpdateSummaryPanelMarkers()
    end
    for i = 1, 5 do
        local dropdown = _G["LUraMarkerDropdown" .. i]
        if dropdown then
            UIDropDownMenu_SetSelectedID(dropdown, LURA.db.markers[i])
            UIDropDownMenu_SetText(dropdown, LURA.MARKER_NAMES[LURA.db.markers[i]])
        end
    end
end

-- Profile Name Input Dialog
function LURA:ShowProfileNameDialog(callback, defaultName)
    if not LUraProfileNameDialog then
        local f = CreateFrame("Frame", "LUraProfileNameDialog", UIParent, "BasicFrameTemplateWithInset")
        f:SetSize(320, 140)
        f:SetPoint("CENTER")
        f:SetFrameStrata("DIALOG")
        f:SetFrameLevel(100)
        
        f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        f.title:SetPoint("TOP", f, "TOP", 0, -5)
        f.title:SetText("Profile Name")
        
        local label = f:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetPoint("TOPLEFT", f, "TOPLEFT", 20, -35)
        label:SetText("Enter profile name:")
        
        local editBox = CreateFrame("EditBox", "LUraProfileNameEditBox", f, "InputBoxTemplate")
        editBox:SetSize(270, 22)
        editBox:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 5, -8)
        editBox:SetAutoFocus(true)
        editBox:SetMaxLetters(50)
        f.editBox = editBox
        
        local okBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        okBtn:SetSize(80, 22)
        okBtn:SetPoint("BOTTOMRIGHT", f, "BOTTOM", -5, 12)
        okBtn:SetText("OK")
        f.okBtn = okBtn
        
        local cancelBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        cancelBtn:SetSize(80, 22)
        cancelBtn:SetPoint("BOTTOMLEFT", f, "BOTTOM", 5, 12)
        cancelBtn:SetText("Cancel")
        cancelBtn:SetScript("OnClick", function() f:Hide() end)
        
        editBox:SetScript("OnEscapePressed", function() f:Hide() end)
    end
    
    local f = LUraProfileNameDialog
    f.editBox:SetText(defaultName or "")
    f.editBox:HighlightText()
    f.okBtn:SetScript("OnClick", function()
        local name = strtrim(f.editBox:GetText())
        if name ~= "" then
            callback(name)
        end
        f:Hide()
    end)
    f.editBox:SetScript("OnEnterPressed", function(self)
        local name = strtrim(self:GetText())
        if name ~= "" then
            callback(name)
        end
        f:Hide()
    end)
    f:Show()
end

-- Overwrite Confirmation Dialog
function LURA:ShowOverwriteConfirmDialog(profileName, onAccept)
    StaticPopupDialogs["LURA_OVERWRITE_PROFILE"] = {
        text = "Profile '%s' already exists. Overwrite it?",
        button1 = "Overwrite",
        button2 = "Cancel",
        OnAccept = function()
            onAccept()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("LURA_OVERWRITE_PROFILE", profileName)
end
