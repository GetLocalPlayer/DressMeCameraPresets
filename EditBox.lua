local addon, ns = ...


local editboxBackdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = true, edgeSize = 1, tileSize = 5,
}


local function onEditFocusGained(self)
    self:HighlightText()
end


function ns:CreateEditBox(name, parent, labelText)
    local editBox = CreateFrame("EditBox", name, parent)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(GameFontHighlightSmall)
    editBox:SetHeight(15)
    editBox:SetWidth(64)
    editBox:SetJustifyH("CENTER")
    editBox:EnableMouse(true)
    editBox:SetBackdrop(editboxBackdrop)
    editBox:SetBackdropColor(0, 0, 0, 0.5)
    editBox:SetBackdropBorderColor(0.3, 0.3, 0.30, 0.80)
    editBox:SetScript("OnEditFocusGained", onEditFocusGained)

    local label = nil
    if labelText ~= nil then
        label = editBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetJustifyH("LEFT")
        label:SetHeight(15)
        label:SetText(labelText)
    end
    return editBox, label
end