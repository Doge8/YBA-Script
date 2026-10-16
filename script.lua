--[[
    YBA Dark Ice - Movement build
    Version: 1.3.0
    Features: WalkSpeed toggle, JumpPower toggle, Noclip toggle
    Native Roblox UI; no external UI libraries or HttpGet dependencies.

    Note: Client-side changes may be reset or rejected by the game server.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    warn("[Dark Ice] LocalPlayer is not ready. Run the script again after joining the game.")
    return
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)
if not PlayerGui then
    warn("[Dark Ice] PlayerGui is not ready. Run the script again after the game has loaded.")
    return
end

local COLORS = {
    Background = Color3.fromRGB(12, 17, 29),
    Panel = Color3.fromRGB(22, 31, 47),
    PanelHover = Color3.fromRGB(35, 49, 70),
    Ice = Color3.fromRGB(105, 220, 255),
    Text = Color3.fromRGB(231, 243, 255),
    Muted = Color3.fromRGB(139, 159, 184),
    Off = Color3.fromRGB(52, 63, 81),
}

local state = {
    speedEnabled = false,
    speedValue = 50,
    jumpEnabled = false,
    jumpValue = 100,
    noclipEnabled = false,
    visible = true,
    destroyed = false,
}

local connections = {}
local originalCollision = {}
local savedMovement = setmetatable({}, { __mode = "k" })

local function track(connection)
    connections[#connections + 1] = connection
    return connection
end

local function safeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[Dark Ice]", err)
    end
    return ok
end

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid()
    local character = getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid") or nil
end

local function saveMovement(humanoid)
    if humanoid and not savedMovement[humanoid] then
        savedMovement[humanoid] = {
            WalkSpeed = humanoid.WalkSpeed,
            UseJumpPower = humanoid.UseJumpPower,
            JumpPower = humanoid.JumpPower,
            JumpHeight = humanoid.JumpHeight,
        }
    end
end

local function restoreWalkSpeed()
    local humanoid = getHumanoid()
    if humanoid then
        local original = savedMovement[humanoid]
        if original then
            safeCall(function() humanoid.WalkSpeed = original.WalkSpeed end)
        end
    end
end

local function restoreJump()
    local humanoid = getHumanoid()
    if humanoid then
        local original = savedMovement[humanoid]
        if original then
            safeCall(function()
                humanoid.UseJumpPower = original.UseJumpPower
                humanoid.JumpPower = original.JumpPower
                humanoid.JumpHeight = original.JumpHeight
            end)
        end
    end
end

-- Try executor GUI container first, then PlayerGui. Never download external code.
local guiParent = nil
if type(gethui) == "function" then
    local ok, result = pcall(gethui)
    if ok and typeof(result) == "Instance" then
        guiParent = result
    end
end

do
    local oldParents = { PlayerGui }
    if guiParent then
        oldParents[#oldParents + 1] = guiParent
    end
    for _, parent in ipairs(oldParents) do
        local old = parent:FindFirstChild("DarkIceUI")
        if old then
            pcall(function() old:Destroy() end)
        end
    end
end

local GUI = Instance.new("ScreenGui")
GUI.Name = "DarkIceUI"
GUI.ResetOnSpawn = false
GUI.IgnoreGuiInset = true
GUI.DisplayOrder = 999999
GUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parented = false
if guiParent then
    parented = pcall(function() GUI.Parent = guiParent end)
end
if not parented then
    local ok = pcall(function() GUI.Parent = PlayerGui end)
    if not ok then
        warn("[Dark Ice] Could not parent the UI to PlayerGui.")
        GUI:Destroy()
        return
    end
end

local function addCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = instance
    return corner
end

local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.new(0.5, 0, 0.5, 0)
main.Size = UDim2.fromOffset(330, 390)
main.BackgroundColor3 = COLORS.Background
main.BorderSizePixel = 0
main.Parent = GUI
addCorner(main, 13)

local outline = Instance.new("UIStroke")
outline.Color = COLORS.Ice
outline.Transparency = 0.28
outline.Thickness = 1.3
outline.Parent = main

local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 61)
header.BackgroundColor3 = COLORS.Panel
header.BorderSizePixel = 0
header.Parent = main
addCorner(header, 13)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(15, 7)
title.Size = UDim2.new(1, -64, 0, 27)
title.Font = Enum.Font.GothamBold
title.Text = "DARK ICE"
title.TextColor3 = COLORS.Ice
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(16, 34)
subtitle.Size = UDim2.new(1, -70, 0, 16)
subtitle.Font = Enum.Font.Gotham
subtitle.Text = "YBA  /  MOVEMENT ONLY  /  v1.3"
subtitle.TextColor3 = COLORS.Muted
subtitle.TextSize = 9
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local closeButton = Instance.new("TextButton")
closeButton.Name = "Hide"
closeButton.Size = UDim2.fromOffset(32, 32)
closeButton.Position = UDim2.new(1, -42, 0, 14)
closeButton.BackgroundColor3 = COLORS.PanelHover
closeButton.BorderSizePixel = 0
closeButton.Text = "X"
closeButton.TextColor3 = COLORS.Text
closeButton.Font = Enum.Font.GothamBold
closeButton.TextSize = 14
closeButton.Parent = header
addCorner(closeButton, 8)

local scroller = Instance.new("ScrollingFrame")
scroller.Name = "Controls"
scroller.Position = UDim2.fromOffset(12, 73)
scroller.Size = UDim2.new(1, -24, 1, -84)
scroller.BackgroundTransparency = 1
scroller.BorderSizePixel = 0
scroller.ScrollBarThickness = 3
scroller.ScrollBarImageColor3 = COLORS.Ice
scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
scroller.CanvasSize = UDim2.new()
scroller.Parent = main

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = scroller

local bottomPadding = Instance.new("UIPadding")
bottomPadding.PaddingBottom = UDim.new(0, 5)
bottomPadding.Parent = scroller

local function newRow(height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -5, 0, height)
    row.BackgroundColor3 = COLORS.Panel
    row.BorderSizePixel = 0
    row.Parent = scroller
    addCorner(row, 9)
    return row
end

local function makeToggle(labelText, initialValue, callback)
    local row = newRow(44)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(12, 0)
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = labelText
    label.TextColor3 = COLORS.Text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(48, 24)
    button.Position = UDim2.new(1, -60, 0.5, -12)
    button.BackgroundColor3 = initialValue and COLORS.Ice or COLORS.Off
    button.BorderSizePixel = 0
    button.Text = initialValue and "ON" or "OFF"
    button.TextColor3 = initialValue and COLORS.Background or COLORS.Text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.Parent = row
    addCorner(button, 99)

    local enabled = initialValue == true
    local function update(value)
        enabled = value == true
        button.Text = enabled and "ON" or "OFF"
        button.TextColor3 = enabled and COLORS.Background or COLORS.Text
        TweenService:Create(button, TweenInfo.new(0.12), {
            BackgroundColor3 = enabled and COLORS.Ice or COLORS.Off,
        }):Play()
        if callback then
            safeCall(callback, enabled)
        end
    end

    track(button.Activated:Connect(function()
        update(not enabled)
    end))

    return function() return enabled end
end

local function makeSlider(labelText, minValue, maxValue, defaultValue, callback)
    local row = newRow(65)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(12, 4)
    label.Size = UDim2.new(1, -75, 0, 20)
    label.Font = Enum.Font.GothamMedium
    label.Text = labelText
    label.TextColor3 = COLORS.Text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1, -60, 0, 4)
    valueLabel.Size = UDim2.fromOffset(48, 20)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextColor3 = COLORS.Ice
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = row

    local trackButton = Instance.new("TextButton")
    trackButton.Name = "SliderTrack"
    trackButton.AutoButtonColor = false
    trackButton.Text = ""
    trackButton.Position = UDim2.new(0, 12, 0, 39)
    trackButton.Size = UDim2.new(1, -24, 0, 7)
    trackButton.BackgroundColor3 = COLORS.Off
    trackButton.BorderSizePixel = 0
    trackButton.Parent = row
    addCorner(trackButton, 99)

    local ratio = (defaultValue - minValue) / (maxValue - minValue)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = COLORS.Ice
    fill.BorderSizePixel = 0
    fill.Parent = trackButton
    addCorner(fill, 99)

    local dragging = false
    local value = defaultValue
    local function updateFromX(x)
        local width = math.max(trackButton.AbsoluteSize.X, 1)
        local pct = math.clamp((x - trackButton.AbsolutePosition.X) / width, 0, 1)
        value = math.floor(minValue + pct * (maxValue - minValue) + 0.5)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        valueLabel.Text = tostring(value)
        if callback then
            safeCall(callback, value)
        end
    end

    track(trackButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end))

    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end))

    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

-- Allow dragging the window by its header.
do
    local dragging = false
    local dragStart
    local startPosition

    track(header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
        end
    end))

    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end))

    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

local function setSpeedEnabled(enabled)
    state.speedEnabled = enabled
    local humanoid = getHumanoid()
    if humanoid then saveMovement(humanoid) end
    if not enabled then restoreWalkSpeed() end
end

local function setJumpEnabled(enabled)
    state.jumpEnabled = enabled
    local humanoid = getHumanoid()
    if humanoid then saveMovement(humanoid) end
    if not enabled then restoreJump() end
end

local function setNoclipEnabled(enabled)
    state.noclipEnabled = enabled
    if not enabled then
        for part, originalCanCollide in pairs(originalCollision) do
            if part and part.Parent then
                safeCall(function() part.CanCollide = originalCanCollide end)
            end
        end
        table.clear(originalCollision)
    end
end

-- Reapply movement settings while toggles are enabled; this is client-side only.
track(RunService.Heartbeat:Connect(function()
    if state.destroyed then return end
    safeCall(function()
        local humanoid = getHumanoid()
        if not humanoid or humanoid.Health <= 0 then return end
        saveMovement(humanoid)

        if state.speedEnabled then
            humanoid.WalkSpeed = state.speedValue
        end
        if state.jumpEnabled then
            humanoid.UseJumpPower = true
            humanoid.JumpPower = state.jumpValue
        end
    end)
end))

-- Noclip loop: remember each part's original collision state, then restore it on OFF.
track(RunService.Stepped:Connect(function()
    if state.destroyed or not state.noclipEnabled then return end
    safeCall(function()
        local character = getCharacter()
        if not character then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if originalCollision[part] == nil then
                    originalCollision[part] = part.CanCollide
                end
                part.CanCollide = false
            end
        end
    end)
end))

makeToggle("Speed Hack", false, setSpeedEnabled)
makeSlider("WalkSpeed", 16, 100, state.speedValue, function(value)
    state.speedValue = value
end)
makeToggle("Jump Power", false, setJumpEnabled)
makeSlider("JumpPower", 50, 150, state.jumpValue, function(value)
    state.jumpValue = value
end)
makeToggle("Noclip", false, setNoclipEnabled)

track(closeButton.Activated:Connect(function()
    state.visible = false
    main.Visible = false
end))

track(UserInputService.InputBegan:Connect(function(input, processed)
    if processed or state.destroyed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        state.visible = not state.visible
        main.Visible = state.visible
    end
end))

-- If this UI is destroyed manually, disconnect loops and restore local changes.
track(GUI.AncestryChanged:Connect(function(_, parent)
    if parent == nil and not state.destroyed then
        state.destroyed = true
        for _, connection in ipairs(connections) do
            pcall(function() connection:Disconnect() end)
        end
        setSpeedEnabled(false)
        setJumpEnabled(false)
        setNoclipEnabled(false)
    end
end))

print("[Dark Ice] Movement UI loaded. Toggle with RightShift; X hides the menu.")
