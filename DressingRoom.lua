local addon, ns = ...

local initWidth = 200
local initHeight = 200

local xStep = 0.1 -- per wheel step
local yStep = 0.005 -- per pixel
local zStep = 0.003 -- per pixel
local facingStep = math.rad(0.75) -- per pixel

local modelX = {min = 0, max = 5}
local modelY = {min = -1, max = 1}
local modelZ = {min = -5, max = 5}


local frameBackdrop = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
}


local function Model_OnMouseWheel(self, delta)
    local x, y, z = self:GetPosition()
    x = x + delta * xStep
    local max, min = modelX.max, modelX.min
    x = x > max and max or x
    x = x < min and min or x
    self:SetPosition(x, y ,z)
end


function ns:CreateDressingRoom(name, parent)
    local frame = CreateFrame("Frame", name, parent)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    frame:EnableMouse(false)
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetSize(initWidth, initHeight)
    frame:SetMinResize(initWidth, initHeight)
    frame:SetMaxResize(initWidth, initHeight)
    frame:SetFrameStrata("FULLSCREEN_DIALOG")
    frame:SetBackdrop(frameBackdrop)
    frame:SetBackdropColor(0.15, 0.15, 0.15, 1)

    local model = CreateFrame("DressUpModel", nil, frame)
    model:SetPoint("TOPLEFT", frameBackdrop.insets.left * 2, -frameBackdrop.insets.top * 2)
    model:SetPoint("BOTTOMRIGHT", -frameBackdrop.insets.right * 2, frameBackdrop.insets.bottom * 2)
    model:EnableMouse(false)
    model:EnableMouseWheel(true)
    model:SetUnit("player")
    model:SetScript("OnMouseWheel", Model_OnMouseWheel)

    local draggingDummy = CreateFrame("Frame", nil, model)
    draggingDummy:SetPoint("TOPLEFT")
    draggingDummy:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 24)
    draggingDummy:EnableMouse(true)
    --draggingDummy:SetBackdrop(bacgroundBackdrop)
    draggingDummy:RegisterForDrag("LeftButton", "RightButton")
    draggingDummy:SetMovable(true)

    draggingDummy:SetScript("OnDragStart", function(self, button)
        self:StartMoving()
        local cursorX, cursorY = GetCursorPosition()
        if button == "LeftButton" then
            draggingDummy:RegisterForDrag("LeftButton")
            self:SetScript("OnUpdate", function(self, elapsed)
                local newX, newY = GetCursorPosition()
                local deltaX = newX - cursorX
                model:SetFacing(model:GetFacing() + deltaX * facingStep)
                cursorX, cursorY = newX, newY
                local x, y, z = model:GetPosition()
            end)
        elseif button == "RightButton" and not IsShiftKeyDown() then
            draggingDummy:RegisterForDrag("RightButton")
            self:SetScript("OnUpdate", function(self, elapsed)
                local newX, newY = GetCursorPosition()
                local deltaY = newY - cursorY
                local x, y, z = model:GetPosition()
                local zOffset = zStep * deltaY
                z = z + zOffset
                local max, min = modelZ.max, modelZ.min
                z = z > max and max or z
                z = z < min and min or z
                model:SetPosition(x, y, z)
                cursorX, cursorY = newX, newY
            end)
        elseif button == "RightButton" and IsShiftKeyDown() then
            draggingDummy:RegisterForDrag("RightButton")
            self:SetScript("OnUpdate", function(self, elapsed)
                local newX, newY = GetCursorPosition()
                local deltaX = newX - cursorX
                local x, y, z = model:GetPosition()
                local yOffset = yStep * deltaX
                y = y + yOffset
                local max, min = modelY.max, modelY.min
                y = y > max and max or y
                y = y < min and min or y
                model:SetPosition(x, y, z)
                cursorX, cursorY = newX, newY
            end)
        end
        self:SetScript("OnReceiveDrag", function(self) 
            self:StopMovingOrSizing()
            self:SetScript("OnUpdate", nil)
            self:SetAllPoints()
            draggingDummy:RegisterForDrag("LeftButton", "RightButton")
        end)
    end)

    local dbgFrame = CreateFrame("Frame", nil, model)
    dbgFrame:Hide()
    dbgFrame:EnableMouse(false)
    dbgFrame:EnableMouseWheel(false)
    dbgFrame:SetAllPoints()
    local dbgInfo = dbgFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dbgInfo:SetAllPoints()
    dbgInfo:SetJustifyH("LEFT")
    dbgInfo:SetJustifyV("BOTTOM")

    local minimalDress = {}
    -- Clothes that will be pulled on the
    -- character after pressing undressing.
    function frame:SetMinimalDress(dress)
        minimalDress = dress
    end

    function frame:Undress()
        model:Undress()
        for i = 1, #minimalDress do
            model:TryOn(minimalDress[i])
        end
    end

    function frame:Reset()
        local x, y, z = model:GetPosition()
        local facing = model:GetFacing()
        model:SetPosition(0, 0, 0)
        model:SetFacing(0)
        model:ClearModel()
        model:SetUnit("player")
        model:SetPosition(x, y, z)
        model:SetFacing(facing)
    end

    function frame:TryOn(...)
        model:TryOn(...)
    end

    function frame:ShowDebug()
        dbgFrame:Show()
        dbgFrame:SetScript("OnUpdate", function(self, elapsed)
            local facing = model:GetFacing()
            local x, y, z = model:GetPosition()
            dbgInfo:SetFormattedText("Facing = %f\nX = %f\nY = %f\nZ = %f", facing, x, y, z)
        end)
    end

    function frame:HideDebug()
        dbgFrame:Hide()
        dbgFrame:SetScript("OnUpdate", nil)
    end

    function frame:SetSequence(...)
        model:SetSequence(...)
    end

    function frame:SetPosition(...)
        local x, y, z = ...
        x = (x > modelX.max and modelX.min) or (x < modelX.min and modelX.min) or x
        y = (y > modelY.max and modelY.min) or (y < modelY.min and modelY.min) or y
        z = (z > modelZ.max and modelZ.min) or (z < modelZ.min and modelZ.min) or z
        model:SetPosition(x, y, z)
    end

    function frame:GetPosition()
        return model:GetPosition()
    end

    function frame:SetFacing(...)
        model:SetFacing(...)
    end

    function frame:GetFacing()
        return model:GetFacing()
    end

    local oldSetScript = frame.SetScript

    function frame:SetScript(event, ...)
        if event == "OnUpdateModel" then
            local func = ...
            model:SetScript(event, function(self) func(frame) end)
        else
            oldSetScript(self, event, ...)
        end
    end

    model:SetScript("OnShow", function(self) frame:Reset() end)
    return frame
end