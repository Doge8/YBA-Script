
--[[
    YBA Dark Ice UI
    Version: 1.0.0
    Description: Lightweight native Roblox UI template
    No external UI libraries required.

    Note:
    This is a UI template for use in Roblox experiences
    you own or have permission to test.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remove previous UI
local old = playerGui:FindFirstChild("DarkIceUI")
if old then
    old:Destroy()
end

-- Theme
local BG = Color3.fromRGB(13, 18, 29)
local PANEL = Color3.fromRGB(21, 29, 44)
local ICE = Color3.fromRGB(90, 210, 255)
local WHITE = Color3.fromRGB(225, 240, 255)
local MUTED = Color3.fromRGB(125, 145, 170)

local gui = Instance.new("ScreenGui")
gui.Name = "DarkIceUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(330, 365)
main.Position = UDim2.new(0.5, -165, 0.5, -182)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = ICE
stroke.Transparency = 0.35
stroke.Thickness = 1.3
stroke.Parent = main

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 58)
header.BackgroundColor3 = PANEL
header.BorderSizePixel = 0
header.Parent = main

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 12)
headerCorner.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -65, 0, 27)
title.Position = UDim2.fromOffset(15, 7)
title.BackgroundTransparency = 1
title.Text = "DARK ICE"
title.TextColor3 = ICE
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -65, 0, 18)
subtitle.Position = UDim2.fromOffset(16, 32)
subtitle.BackgroundTransparency = 1
subtitle.Text = "YBA  /  NATIVE INTERFACE"
subtitle.TextColor3 = MUTED
subtitle.Font = Enum.Font.Gotham
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = header

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(34, 34)
close.Position = UDim2.new(1, -44, 0, 12)
close.BackgroundColor3 = Color3.fromRGB(45, 58, 77)
close.Text = "X"
close.TextColor3 = WHITE
close.Font = Enum.Font.GothamBold
close.TextSize = 15
close.Parent = header

Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

-- Content list
local content = Instance.new("ScrollingFrame")
content.Name = "Content"
content.Position = UDim2.fromOffset(12, 70)
content.Size = UDim2.new(1, -24, 1, -82)
content.BackgroundTransparency = 1
content.BorderSizePixel = 0
content.ScrollBarThickness = 3
content.ScrollBarImageColor3 = ICE
content.CanvasSize = UDim2.new()
content.AutomaticCanvasSize = Enum.AutomaticSize.Y
content.Parent = main

local list = Instance.new("UIListLayout")
list.Padding = UDim.new(0, 9)
list.SortOrder = Enum.SortOrder.LayoutOrder
list.Parent = content

local padding = Instance.new("UIPadding")
padding.PaddingBottom = UDim.new(0, 6)
padding.Parent = content

local function makeRow(height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -5, 0, height)
    row.BackgroundColor3 = PANEL
    row.BorderSizePixel = 0
    row.Parent = content

    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    return row
end

local function makeToggle(labelText, callback)
    local row = makeRow(45)

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(12, 0)
    label.Size = UDim2.new(1, -80, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextColor3 = WHITE
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(48, 25)
    button.Position = UDim2.new(1, -60, 0.5, -12)
    button.BackgroundColor3 = Color3.fromRGB(48, 57, 73)
    button.Text = "OFF"
    button.TextColor3 = WHITE
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.Parent = row

    Instance.new("UICorner", button).CornerRadius = UDim.new(1, 0)

    local enabled = false

    button.Activated:Connect(function()
        enabled = not enabled

        local target = enabled and ICE
            or Color3.fromRGB(48, 57, 73)

        TweenService:Create(
            button,
            TweenInfo.new(0.15),
            {BackgroundColor3 = target}
        ):Play()

        button.Text = enabled and "ON" or "OFF"

        if callback then
            local ok, err = pcall(callback, enabled)
            if not ok then
                warn("[Dark Ice] Toggle error:", err)
            end
        end
    end)

    return function()
        return enabled
    end
end

local function makeSlider(labelText, minValue, maxValue, defaultValue, callback)
    local row = makeRow(67)

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(12, 5)
    label.Size = UDim2.new(1, -24, 0, 20)
    label.BackgroundTransparency = 1
    label.TextColor3 = WHITE
    label.Text = labelText
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.fromOffset(50, 20)
    valueLabel.Position = UDim2.new(1, -62, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = ICE
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 12
    valueLabel.Text = tostring(defaultValue)
    valueLabel.Parent = row

    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, 12, 0, 39)
    track.Size = UDim2.new(1, -24, 0, 6)
    track.BackgroundColor3 = Color3.fromRGB(48, 57, 73)
    track.BorderSizePixel = 0
    track.Parent = row

    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(
        (defaultValue - minValue) / (maxValue - minValue), 0, 1, 0
    )
    fill.BackgroundColor3 = ICE
    fill.BorderSizePixel = 0
    fill.Parent = track

    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local value = defaultValue

    local function update(inputX)
        local ratio = math.clamp(
            (inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X,
            0, 1
        )

        value = math.floor(minValue + ratio * (maxValue - minValue))
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        valueLabel.Text = tostring(value)

        if callback then
            local ok, err = pcall(callback, value)
            if not ok then
                warn("[Dark Ice] Slider error:", err)
            end
        end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (
            input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch
        ) then
            update(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Demo controls: callbacks are placeholders for your own experience.
makeToggle("Demo Toggle", function(enabled)
    print("[Dark Ice] Demo Toggle:", enabled)
end)

makeSlider("Demo Slider", 1, 100, 50, function(value)
    -- Example setting value; no movement exploit is applied.
end)

makeToggle("UI Animation", function(enabled)
    print("[Dark Ice] UI Animation:", enabled)
end)

local function setVisible(visible)
    main.Visible = visible
end

close.Activated:Connect(function()
    setVisible(false)
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.RightShift then
        setVisible(not main.Visible)
    end
end)

print("[Dark Ice] UI loaded successfully.")
