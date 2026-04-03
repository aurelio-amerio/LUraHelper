local _, LURA = ...

-- Base64 Encode / Decode Helpers
local b64chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

local function Base64Encode(data)
    return ((data:gsub('.', function(x) 
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b64chars:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

local function Base64Decode(data)
    data = string.gsub(data, '[^'..b64chars..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r,f='',(b64chars:find(x)-1)
        for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
        if (#x ~= 8) then return '' end
        local c=0
        for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- Export Config (includes profile name)
function LURA:ExportConfig()
    local sp1, _, sp2, sx, sy = LUraSummaryFrame:GetPoint()
    local ip1, _, ip2, ix, iy = LUraInteractiveFrame:GetPoint()
    
    local xml = "<LUraConfig>\n"
    xml = xml .. string.format("  <profileName>%s</profileName>\n", LUraHelperDB.activeProfile)
    xml = xml .. string.format("  <markers>%s</markers>\n", table.concat(LURA.db.markers, ","))
    xml = xml .. string.format("  <locked>%s</locked>\n", tostring(LURA.db.locked))
    xml = xml .. string.format("  <hidden>%s</hidden>\n", tostring(LURA.db.hidden))
    xml = xml .. string.format("  <summaryPos>%s,%s,%s,%s</summaryPos>\n", sp1 or "CENTER", sp2 or "CENTER", sx or 496, sy or 49)
    xml = xml .. string.format("  <interactivePos>%s,%s,%s,%s</interactivePos>\n", ip1 or "CENTER", ip2 or "CENTER", ix or 496, iy or -22)
    xml = xml .. "</LUraConfig>"
    
    return Base64Encode(xml)
end

-- Apply imported config to a target profile
function LURA:ApplyImportedConfig(xml, targetProfileName)
    local profileData = {}
    
    local markersStr = string.match(xml, "<markers>(.-)</markers>")
    if markersStr then
        local m = {}
        for val in string.gmatch(markersStr, "[^,]+") do
            table.insert(m, tonumber(val) or 1)
        end
        if #m == 5 then
            profileData.markers = m
        else
            profileData.markers = {1, 2, 3, 4, 5}
        end
    else
        profileData.markers = {1, 2, 3, 4, 5}
    end
    
    local lockedStr = string.match(xml, "<locked>(.-)</locked>")
    profileData.locked = lockedStr and (lockedStr == "true" or lockedStr == "1") or false
    
    local hiddenStr = string.match(xml, "<hidden>(.-)</hidden>")
    profileData.hidden = hiddenStr and (hiddenStr == "true" or hiddenStr == "1") or false
    
    -- Save profile and switch
    LUraHelperDB.profiles[targetProfileName] = profileData
    LURA:SwitchProfile(targetProfileName)
    
    -- Apply frame positions
    local summaryPosStr = string.match(xml, "<summaryPos>(.-)</summaryPos>")
    if summaryPosStr then
        local p1, p2, x, y = string.match(summaryPosStr, "([^,]+),([^,]+),([^,]+),([^,]+)")
        if p1 and p2 and x and y then
            LUraSummaryFrame:ClearAllPoints()
            LUraSummaryFrame:SetPoint(p1, UIParent, p2, tonumber(x), tonumber(y))
        end
    end
    
    local interactivePosStr = string.match(xml, "<interactivePos>(.-)</interactivePos>")
    if interactivePosStr then
        local p1, p2, x, y = string.match(interactivePosStr, "([^,]+),([^,]+),([^,]+),([^,]+)")
        if p1 and p2 and x and y then
            LUraInteractiveFrame:ClearAllPoints()
            LUraInteractiveFrame:SetPoint(p1, UIParent, p2, tonumber(x), tonumber(y))
        end
    end
    
    print("LUra: Imported profile '" .. targetProfileName .. "'.")
end

-- Import Config (extracts profile name, prompts for naming/overwrite)
function LURA:ImportConfig(encodedXML)
    local xml = Base64Decode(encodedXML)
    
    -- Extract embedded profile name (default to "Imported" if absent)
    local embeddedName = string.match(xml, "<profileName>(.-)</profileName>") or "Imported"
    
    -- Ask the user for the target profile name
    LURA:ShowProfileNameDialog(function(targetName)
        if LUraHelperDB.profiles[targetName] then
            -- Profile exists — ask for overwrite confirmation
            LURA:ShowOverwriteConfirmDialog(targetName, function()
                LURA:ApplyImportedConfig(xml, targetName)
            end)
        else
            LURA:ApplyImportedConfig(xml, targetName)
        end
    end, embeddedName)
end

-- Import/Export Window
function LURA:ShowImportExportWindow(isExport)
    if not LUraImportExportFrame then
        local f = CreateFrame("Frame", "LUraImportExportFrame", UIParent, "BasicFrameTemplateWithInset")
        f:SetSize(400, 350)
        f:SetPoint("CENTER")
        f:SetFrameStrata("DIALOG")
        
        f.title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        f.title:SetPoint("TOP", f, "TOP", 0, -5)
        
        local scrollFrame = CreateFrame("ScrollFrame", "LUraIEScrollFrame", f, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -35)
        scrollFrame:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -30, 45)
        
        local editBox = CreateFrame("EditBox", "LUraIEEditBox", scrollFrame)
        editBox:SetSize(350, 250)
        editBox:SetMultiLine(true)
        editBox:SetFontObject("ChatFontNormal")
        editBox:SetMaxLetters(99999)
        editBox:SetAutoFocus(true)
        editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() f:Hide() end)
        scrollFrame:SetScrollChild(editBox)
        f.editBox = editBox
        
        local actionBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        actionBtn:SetSize(100, 22)
        actionBtn:SetPoint("BOTTOM", f, "BOTTOM", 0, 12)
        f.actionBtn = actionBtn
    end
    
    local f = LUraImportExportFrame
    f.editBox:SetText("")
    
    if isExport then
        f.title:SetText("Export Configuration")
        f.editBox:SetText(LURA:ExportConfig())
        f.editBox:HighlightText()
        f.actionBtn:SetText("Close")
        f.actionBtn:SetScript("OnClick", function() f:Hide() end)
    else
        f.title:SetText("Import Configuration")
        f.editBox:SetText("")
        f.actionBtn:SetText("Import")
        f.actionBtn:SetScript("OnClick", function()
            LURA:ImportConfig(f.editBox:GetText())
            f:Hide()
        end)
    end
    
    f:Show()
end
