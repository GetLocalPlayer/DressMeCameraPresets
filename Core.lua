local previewMaxWidth, previewMaxHeight = 500, 500
local previewMinWidth, previewMinHeight = 50, 50
local windowWidth, windowHeight = 1024, 600
local minimalDress = {2568, 4343}

local addon, ns = ...

local cameraPresets = nil
local selectedPreset = nil

local sex = UnitSex("player")
local race, raceFileName = UnitRace("player")

local windowBackdrop  = {
	bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
	edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
	tile = true, tileSize = 32, edgeSize = 32,
	insets = { left = 8, right = 8, top = 8, bottom = 8 }
}

local editboxBackdrop = {
	bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
	tile = true, edgeSize = 1, tileSize = 5,
}


local window = CreateFrame("Frame", nil, UIParent)
window:Hide()
window:SetFrameStrata("MEDIUM")
window:EnableMouse(true)
window:SetMovable(true)
window:SetBackdrop(windowBackdrop)
window:SetPoint("CENTER")
window:SetSize(windowWidth, windowHeight)
window:RegisterForDrag("LeftButton")
window:SetScript("OnDragStart", function(self) self:StartMoving() end)
window:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

local btnClose = CreateFrame("Button", "DressMeSetupCloseButton", window, "UIPanelButtonTemplate2")
btnClose:SetSize(128, 24)
btnClose:SetText(CLOSE)
btnClose:SetPoint("BOTTOMRIGHT", -16, 16)
btnClose:SetScript("OnClick", function(self) window:Hide() end)

local previewFrame = CreateFrame("Frame", nil, window)
previewFrame:SetPoint("CENTER")
previewFrame:SetSize(previewMaxWidth, previewMaxHeight)

local preview = ns:CreateDressingRoom(nil, previewFrame)
preview:SetPoint("CENTER")
preview:SetSize(previewMinWidth, previewMinHeight)
preview:Reset()

local xEditBox, xLabel = ns:CreateEditBox(nil, window, "X = ")
xEditBox:SetMaxLetters(6)
xEditBox:SetPoint("TOPRIGHT", -16, -256)
xEditBox:SetScript("OnEnterPressed", function(self)
    local value = tonumber(self:GetText())
    if value == nil then
        self:SetText(tostring(selectedPreset.x))
    else
        local x, y, z = preview:GetPosition()
        preview:SetPosition(value, y, z)
        x, y, z = preview:GetPosition()
        selectedPreset.x = x
        self:SetText(tostring(x))
    end
    self:ClearFocus()
end)
xEditBox:SetScript("OnEscapePressed", function(self)
    self:SetText(tostring(selectedPreset.x))
    self:ClearFocus()
end)

xLabel:SetPoint("RIGHT", xLabel:GetParent(), "LEFT", -5, 0)

local yEditBox, yLabel = ns:CreateEditBox(nil, window, "Y = ")
yEditBox:SetMaxLetters(6)
yEditBox:SetPoint("TOPRIGHT", xEditBox, "BOTTOMRIGHT", 0, -5)
yEditBox:SetScript("OnEnterPressed", function(self)
    local value = tonumber(self:GetText())
    if value == nil then
        self:SetText(tostring(selectedPreset.y))
    else
        local x, y, z = preview:GetPosition()
        preview:SetPosition(x, value, z)
        x, y, z = preview:GetPosition()
        selectedPreset.y = y
        self:SetText(tostring(y))
    end
    self:ClearFocus()
end)
yEditBox:SetScript("OnEscapePressed", function(self)
    self:SetText(tostring(selectedPreset.y))
    self:ClearFocus()
end)

yLabel:SetPoint("RIGHT", yLabel:GetParent(), "LEFT", -5, 0)

local zEditBox, zLabel = ns:CreateEditBox(nil, window, "Z = ")
zEditBox:SetMaxLetters(6)
zEditBox:SetPoint("TOPRIGHT", yEditBox, "BOTTOMRIGHT", 0, -5)
zEditBox:SetScript("OnEnterPressed", function(self)
    local value = tonumber(self:GetText())
    if value == nil then
        self:SetText(tostring(selectedPreset.z))
    else
        local x, y, z = preview:GetPosition()
        preview:SetPosition(x, y, value)
        x, y, z = preview:GetPosition()
        selectedPreset.z = z
        self:SetText(tostring(z))
    end
    self:ClearFocus()
end)
zEditBox:SetScript("OnEscapePressed", function(self)
    self:SetText(tostring(selectedPreset.z))
    self:ClearFocus()
end)

zLabel:SetPoint("RIGHT", zLabel:GetParent(), "LEFT", -5, 0)

local facingEditBox, facingLabel = ns:CreateEditBox(nil, window, "Facing =")
facingEditBox:SetMaxLetters(6)
facingEditBox:SetPoint("TOPRIGHT", zEditBox, "BOTTOMRIGHT", 0, -5)
facingEditBox:SetScript("OnEnterPressed", function(self)
    local value = tonumber(self:GetText())
    if value == nil then
        self:SetText(tostring(math.floor(math.deg(selectedPreset.facing))))
    else
        value = math.rad(value)
        selectedPreset.facing = value
        preview:SetFacing(value)
    end
    self:ClearFocus()
end)
facingEditBox:SetScript("OnEscapePressed", function(self)
    facingEditBox:SetText(tostring(math.floor(math.deg(selectedPreset.facing))))
    self:ClearFocus()
end)

facingLabel:SetPoint("RIGHT", facingLabel:GetParent(), "LEFT", -5, 0)

local sequenceEditBox, sequenceLabel = ns:CreateEditBox(nil, window, "Sequence id = ")
sequenceEditBox:SetNumeric(true)
sequenceEditBox:SetPoint("TOPRIGHT", facingEditBox, "BOTTOMRIGHT", 0, -5)
sequenceEditBox:SetScript("OnEnterPressed", function(self)
    selectedPreset.sequence = self:GetNumber()
    self:ClearFocus()
end)
sequenceEditBox:SetScript("OnEscapePressed", function(self)
    self:SetNumber(selectedPreset.sequence)
    self:ClearFocus()
end)

sequenceLabel:SetPoint("RIGHT", sequenceLabel:GetParent(), "LEFT", -5, 0)

preview:SetScript("OnSizeChanged", function(self, width, height)
    selectedPreset.width = width
    selectedPreset.height = height
end)
preview:SetScript("OnUpdateModel", function(self)
    local x, y, z = self:GetPosition()
    local facing = self:GetFacing()
    selectedPreset.x, selectedPreset.y, selectedPreset.z = x, y, z
    selectedPreset.facing = facing
    if not xEditBox:HasFocus() then xEditBox:SetText(tostring(x)) end
    if not yEditBox:HasFocus() then yEditBox:SetText(tostring(y)) end
    if not zEditBox:HasFocus() then zEditBox:SetText(tostring(z)) end
    if not facingEditBox:HasFocus() then facingEditBox:SetText(math.floor(math.deg(facing))) end
    if not sequenceEditBox:HasFocus() then self:SetSequence(sequenceEditBox:GetNumber()) end
end)

local btnUnderss = CreateFrame("Button", "DressMeSetupUndressButton", window, "UIPanelButtonTemplate2")
btnUnderss:SetPoint("BOTTOMLEFT", previewFrame, "TOPLEFT", 0, 5)
btnUnderss:SetSize(128, 24)
btnUnderss:SetText("Undress")
btnUnderss:SetScript("OnClick", function(self)
    preview:Undress()
    table.foreach(minimalDress, function(_, v) preview:TryOn(v) end)
end)

local btnReset = CreateFrame("Button", "DressMeSetupResetButton", window, "UIPanelButtonTemplate2")
btnReset:SetPoint("LEFT", btnUnderss, "RIGHT", 15, 0)
btnReset:SetSize(128, 24)
btnReset:SetText("Reset")
btnReset:SetScript("OnClick", function(self) preview:Reset() end)

local btnTryOn = CreateFrame("Button", "DressMeSetupTryOnButton", window, "UIPanelButtonTemplate2")
btnTryOn:SetPoint("LEFT", btnReset, "RIGHT", 15, 0)
btnTryOn:SetSize(96, 24)
btnTryOn:SetText("Try on")

local tryOnEditBox, tryOnLabel = ns:CreateEditBox(nil, window, "by id:")
tryOnEditBox:SetNumeric(true)
tryOnEditBox:SetPoint("LEFT", btnTryOn, "RIGHT", tryOnLabel:GetWidth() + 5, 0)
tryOnEditBox:SetScript("OnEnterPressed", function(self)
    self:ClearFocus()
    self:HighlightText(0, 0)
    btnTryOn:Click("LeftButton", true)
end)
tryOnEditBox:SetScript("OnEscapePressed", function(self)
    self:ClearFocus()
    self:HighlightText(0, 0)
end)

tryOnLabel:SetPoint("RIGHT", tryOnEditBox, "LEFT", -2, 0)

btnTryOn:SetScript("OnClick", function(self)preview:TryOn(tryOnEditBox:GetNumber()) end)

-- Sliders

local sliderBackdrop  = {
	bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
	edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
	tile = true, tileSize = 8, edgeSize = 8,
	insets = { left = 3, right = 3, top = 3, bottom = 3 }
}


-- Width slider

local widthSlider = CreateFrame("Slider", nil, window)
widthSlider:SetOrientation("HORIZONTAL")
widthSlider:SetHeight(15)
widthSlider:SetBackdrop(sliderBackdrop)
widthSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
widthSlider:SetPoint("TOPLEFT", previewFrame, "BOTTOMLEFT")
widthSlider:SetPoint("TOPRIGHT", previewFrame, "BOTTOMRIGHT")
widthSlider:SetMinMaxValues(previewMinWidth, previewMaxWidth)
widthSlider:SetValue(previewMinWidth)
widthSlider:SetValueStep(1)

local widthEditBox, widthLabel = ns:CreateEditBox(nil, widthSlider, "Width")
widthEditBox:SetNumeric(true)
widthEditBox:SetNumber(widthSlider:GetValue())
widthEditBox:SetPoint("TOPLEFT", widthEditBox:GetParent(), "BOTTOM", 5, 0)

widthEditBox:SetScript("OnEnterPressed", function(self)
    local value = self:GetNumber()
    local min, max = widthSlider:GetMinMaxValues()
    value = (value < min and min) or (value > max and max) or value
    widthSlider:SetValue(value)
    self:SetNumber(value)
    self:ClearFocus()
end)

widthEditBox:SetScript("OnEscapePressed", function(self)
    self:SetNumber(widthSlider:GetValue())
    self:ClearFocus()
end)

widthLabel:SetPoint("RIGHT", widthEditBox, "LEFT", -2, 0)

widthSlider:SetScript("OnValueChanged", function(self, value)
    preview:SetWidth(value)
    widthEditBox:SetNumber(value)
end)

-- Height slider

local heightSlider = CreateFrame("Slider", nil, window)
heightSlider:SetOrientation("VERTICAL")
heightSlider:SetWidth(10)
heightSlider:SetBackdrop(sliderBackdrop)
heightSlider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
heightSlider:SetPoint("TOPLEFT", previewFrame, "TOPRIGHT")
heightSlider:SetPoint("BOTTOMLEFT", previewFrame, "BOTTOMRIGHT")
heightSlider:SetMinMaxValues(previewMinHeight, previewMaxHeight)
heightSlider:SetValue(previewMaxHeight)
heightSlider:SetValueStep(1)

local heightEditBox, heightLabel = ns:CreateEditBox(nil, heightSlider, "Height")
heightEditBox:SetNumeric(true)
heightEditBox:SetNumber(previewMaxHeight - heightSlider:GetValue() + previewMinHeight)
heightEditBox:SetPoint("TOPLEFT", heightSlider, "RIGHT", 5, -5)

heightEditBox:SetScript("OnEnterPressed", function(self)
    local value = previewMaxHeight - self:GetNumber() + previewMinHeight
    local min, max = heightSlider:GetMinMaxValues()
    value = (value < min and min) or (value > max and max) or value
    heightSlider:SetValue(value)
    self:SetNumber(previewMaxHeight - value + previewMinHeight)
    self:ClearFocus()
end)

heightEditBox:SetScript("OnEscapePressed", function(self)
    self:SetNumber(heightSlider:GetValue())
    self:ClearFocus()
end)

heightLabel:SetPoint("BOTTOM", heightEditBox, "TOP")

heightSlider:SetScript("OnValueChanged", function(self, value)
    value = previewMaxHeight - value + previewMinHeight 
    preview:SetHeight(value)
    heightEditBox:SetNumber(value)
end)

-- Slots

local selectedClassButton = nil

-- Called on ADDON_LOADED since the buttons depend on camera preset
local function createSlotButtons()
    local slotButtons = {}
    local slotChildren = {}
    for slot, classes in pairs(cameraPresets) do
        local slotBtn = CreateFrame("Button", ("DressMeSetupSlotButton%s"):format(slot), window, "OptionsListButtonTemplate")
        slotBtn:SetText(slot)
        table.insert(slotButtons, slotBtn)
        local classButtons = {}
        local classNames = {} -- to sort class buttons
        for class, preset in pairs(classes) do
            local classBtn = CreateFrame("Button", ("DressMeSetupClassButton%s"):format(class), slotBtn, "OptionsListButtonTemplate")
            classBtn:SetParent(slotBtn)
            classBtn:SetText("|cffffffff" .. class .. FONT_COLOR_CODE_CLOSE)
            classBtn:SetScript("OnClick", function(self)
                local preset = cameraPresets[slot][class]
                widthSlider:SetValue(preset.width)
                heightSlider:SetValue(previewMaxHeight - preset.height + previewMinHeight)
                preview:SetPosition(preset.x, preset.y, preset.z)
                preview:SetFacing(preset.facing)
                sequenceEditBox:SetNumber(preset.sequence)
                if selectedClassButton ~= nil then
                    selectedClassButton:UnlockHighlight()
                end
                selectedClassButton = self
                selectedClassButton:LockHighlight()
                selectedPreset = preset
            end)
            classButtons[class] = classBtn
            table.insert(classNames, class)
        end
        table.sort(classNames)
        classButtons[classNames[1]]:SetPoint("TOPLEFT", slotBtn, "BOTTOMLEFT", 24, 0)
        slotChildren[slotBtn] = {classButtons[classNames[1]]}
        for i = 2, #classNames do
            classButtons[classNames[i]]:SetPoint("TOPLEFT", classButtons[classNames[i - 1]], "BOTTOMLEFT")
            table.insert(slotChildren[slotBtn], classButtons[classNames[i]])
        end
        classButtons[classNames[1]]:Click("LeftButton")
    end
    slotButtons[1]:SetPoint("TOPLEFT", 16, -16)
    for i = 2, #slotButtons do
        local prevChildren = slotChildren[slotButtons[i - 1]]
        slotButtons[i]:SetPoint("TOPLEFT", prevChildren[#prevChildren], "BOTTOMLEFT", - 24, 0)
    end
    for i = 1, #slotButtons do
        local slotBtn = slotButtons[i]
        slotBtn:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                slotBtn.collapsed = not slotBtn.collapsed
                local children = slotChildren[slotBtn]
                table.foreach(children, function(_, child) if slotBtn.collapsed then child:Hide() else child:Show() end end)
                if i < #slotButtons then
                    if slotBtn.collapsed then
                        slotButtons[i + 1]:ClearAllPoints()
                        slotButtons[i + 1]:SetPoint("TOPLEFT", slotBtn, "BOTTOMLEFT")
                    else
                        slotButtons[i + 1]:ClearAllPoints()
                        slotButtons[i + 1]:SetPoint("TOPLEFT", children[#children], "BOTTOMLEFT", -24, 0)
                    end
                end
            end
        end)
    end
end


local function createDefaultCameraPreset()
    local races = {"Human", "NightElf", "Dwarf", "Gnome", "Draenei", "Orc", "Troll", "Scourge", "Tauren", "BloodElf"}
    local sex = {2, 3} -- male = 2, female = 3
    local slots = {
        ["Armor"] = {"Head", "Shoulder", "Back", "Chest", "Wrist", "Gloves", "Waist", "Legs", "Feet"},
        ["Main Hand"] = {"Dagger", "Sword", "Axe", "Mace", "Polearm", "2H Sword", "2H Axe", "2H Mace"},
        ["Off-hand"] = {"Dagger", "Sword", "Axe", "Mace", "Held in Off-hand", "Shield"},
        ["Ranged"] = {"Bow", "Gun", "Wand"},
    }
    local preset = {}
    for i = 1, #races do
        local r = races[i]
        preset[r] = {}
        for k = 1, #sex do
            local s = sex[k]
            preset[r][s] = {}
            for slot, classes in pairs(slots) do
                preset[r][s][slot] = {}
                for n = 1, #classes do
                    preset[r][s][slot][classes[n]] = {width = 100, height = 120, sequence = 3, x = 0, y = 0, z = 0, facing = 0}
                end
            end
        end
    end
    return preset
end


local classicModelsCheckBox = CreateFrame("CheckButton", "myCheckButton_GlobalName", window, "ChatConfigCheckButtonTemplate")
classicModelsCheckBox:SetPoint("TOPRIGHT", -16, -16)

local classicModelsLabel = classicModelsCheckBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
classicModelsLabel:SetPoint("RIGHT", classicModelsCheckBox, "LEFT", -5, 0)
classicModelsLabel:SetJustifyH("LEFT")
classicModelsLabel:SetHeight(15)
classicModelsLabel:SetText("Classic models")

local modernModelsCheckBox = CreateFrame("CheckButton", "myCheckButton_GlobalName", window, "ChatConfigCheckButtonTemplate")
modernModelsCheckBox:SetPoint("TOP", classicModelsCheckBox, "BOTTOM", 0, -2)

local modernModelsLabel = modernModelsCheckBox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
modernModelsLabel:SetPoint("RIGHT", modernModelsCheckBox, "LEFT", -5, 0)
modernModelsLabel:SetJustifyH("LEFT")
modernModelsLabel:SetHeight(15)
modernModelsLabel:SetText("Modern models (WoD/Legion)")

classicModelsCheckBox:SetScript("OnClick", function(self)
    if not self:GetChecked() then
        self:SetChecked(true)
    else
        modernModelsCheckBox:SetChecked(false)
        cameraPresets = _G["DressMeCameraPresets"][raceFileName][sex]
        selectedClassButton:Click("LeftButton", true)
    end
end)

modernModelsCheckBox:SetScript("OnClick", function(self)
    if not self:GetChecked() then
        self:SetChecked(true)
    else
        classicModelsCheckBox:SetChecked(false)
        cameraPresets = _G["DressMeModernCameraPresets"][raceFileName][sex]
        selectedClassButton:Click("LeftButton", true)
    end
end)

SLASH_DRESSMESETUP1 = "/dmpresets"

SlashCmdList["DRESSMESETUP"] = function(msg)
    if cameraPresets == nil then
        print("DressMeSetup isn't loaded yet.")
    else
        if window:IsShown() then window:Hide() else window:Show() end
    end
end


local f = CreateFrame("Frame", nil, UIParent)
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGOUT")
f:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" and name == addon then
        if _G["DressMeCameraPresets"] == nil then
            _G["DressMeCameraPresets"] = createDefaultCameraPreset()
            _G["DressMeModernCameraPresets"] = createDefaultCameraPreset()
        end
        cameraPresets = _G["DressMeModernCameraPresets"][raceFileName][sex]
        createSlotButtons()
        modernModelsCheckBox:SetChecked(true)
    end
end)