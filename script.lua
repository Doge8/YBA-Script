--[[
    YBA Dark Ice - Demo Menu
    Native ScreenGui only; no external UI library.
    Includes demo toggles and a demo slider only.
    RightShift toggles visibility; X hides the menu.
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
if not player then
    warn("[Dark Ice Demo] LocalPlayer was not available.")
    return
end

local ok, err = pcall(function()
    local playerGui = player:WaitForChild("PlayerGui", 10)
    assert(playerGui, "PlayerGui did not load within 10 seconds")

    local previous = playerGui:FindFirstChild("DarkIceDemoMenu")
    if previous then previous:Destroy() end

    local BG = Color3.fromRGB(13, 18, 29)
    local PANEL = Color3.fromRGB(21, 29, 44)
    local ICE = Color3.fromRGB(90, 210, 255)
    local WHITE = Color3.fromRGB(225, 240, 255)
    local MUTED = Color3.fromRGB(125, 145, 170)

    local gui = Instance.new("ScreenGui")
    gui.Name = "DarkIceDemoMenu"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = false
    gui.DisplayOrder = 9999
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.fromOffset(330, 365)
    main.Position = UDim2.new(0.5, -165, 0.5, -182)
    main.BackgroundColor3 = BG
    main.BorderSizePixel = 0
    main.Parent = gui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = main

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = ICE
    mainStroke.Transparency = 0.35
    mainStroke.Thickness = 1.3
    mainStroke.Parent = main

    -- Header
    local header = Instance.new("Frame")
    header.Name = "Header"
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
    subtitle.Text = "DEMO MENU  /  NATIVE UI"
    subtitle.TextColor3 = MUTED
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 10
    subtitle.TextXAlignment = Enum.TextXAlignment.Left
    subtitle.Parent = header

    local close = Instance.new("TextButton")
    close.Name = "Close"
    close.Size = UDim2.fromOffset(34, 34)
    close.Position = UDim2.new(1, -44, 0, 12)
    close.BackgroundColor3 = Color3.fromRGB(45, 58, 77)
    close.Text = "X"
    close.TextColor3 = WHITE
    close.Font = Enum.Font.GothamBold
    close.TextSize = 15
    close.AutoButtonColor = true
    close.Parent = header
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 8)
    closeCorner.Parent = close

    -- Scrolling content
    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.Position = UDim2.fromOffset(12, 70)
    content.Size = UDim2.new(1, -24, 1, -82)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ScrollBarThickness = 3
    content.ScrollBarImageColor3 = ICE
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.CanvasSize = UDim2.new()
    content.Parent = main

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 9)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = content

    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingBottom = UDim.new(0, 6)
    contentPadding.Parent = content

    local function makeRow(height)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, -5, 0, height)
        row.BackgroundColor3 = PANEL
        row.BorderSizePixel = 0
        row.Parent = content
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = row
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

        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(1, 0)
        buttonCorner.Parent = button

        local enabled = false
        button.Activated:Connect(function()
            enabled = not enabled
            local targetColor = enabled and ICE or Color3.fromRGB(48, 57, 73)
            TweenService:Create(button, TweenInfo.new(0.15), {
                BackgroundColor3 = targetColor
            }):Play()
            button.Text = enabled and "ON" or "OFF"
            if callback then
                local callbackOk, callbackErr = pcall(callback, enabled)
                if not callbackOk then
                    warn("[Dark Ice Demo] Toggle callback error:", callbackErr)
                end
            end
        end)

        return function() return enabled end
    end

    local function makeSlider(labelText, minValue, maxValue, defaultValue, callback)
        local row = makeRow(67)

        local label = Instance.new("TextLabel")
        label.Position = UDim2.fromOffset(12, 5)
        label.Size = UDim2.new(1, -75, 0, 20)
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

        local track = Instance.new("TextButton")
        track.Name = "Track"
        track.Text = ""
        track.AutoButtonColor = false
        track.Position = UDim2.new(0, 12, 0, 39)
        track.Size = UDim2.new(1, -24, 0, 10)
        track.BackgroundColor3 = Color3.fromRGB(48, 57, 73)
        track.BorderSizePixel = 0
        track.Parent = row
        local trackCorner = Instance.new("UICorner")
        trackCorner.CornerRadius = UDim.new(1, 0)
        trackCorner.Parent = track

        local fill = Instance.new("Frame")
        fill.Name = "Fill"
        fill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
        fill.BackgroundColor3 = ICE
        fill.BorderSizePixel = 0
        fill.Parent = track
        local fillCorner = Instance.new("UICorner")
        fillCorner.CornerRadius = UDim.new(1, 0)
        fillCorner.Parent = fill

        local dragging = false
        local function update(inputX)
            local width = track.AbsoluteSize.X
            if width <= 0 then return end
            local ratio = math.clamp((inputX - track.AbsolutePosition.X) / width, 0, 1)
            local value = math.floor(minValue + ratio * (maxValue - minValue) + 0.5)
            fill.Size = UDim2.new(ratio, 0, 1, 0)
            valueLabel.Text = tostring(value)
            if callback then
                local callbackOk, callbackErr = pcall(callback, value)
                if not callbackOk then
                    warn("[Dark Ice Demo] Slider callback error:", callbackErr)
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
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
                or input.UserInputType == Enum.UserInputType.Touch) then
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

    -- Demo controls only; they print values and do not alter game movement.
    makeToggle("Demo Toggle", function(enabled)
        print("[Dark Ice Demo] Demo Toggle:", enabled)
    end)

    makeSlider("Demo Slider", 1, 100, 50, function(value)
        print("[Dark Ice Demo] Demo Slider:", value)
    end)

    makeToggle("UI Animation Demo", function(enabled)
        print("[Dark Ice Demo] UI Animation:", enabled)
    end)

    close.Activated:Connect(function()
        main.Visible = false
    end)

    UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            main.Visible = not main.Visible
        end
    end)

    -- Make the menu draggable from the header.
    local dragging = false
    local dragStart, startPosition
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    gui.Parent = playerGui
    print("[Dark Ice Demo] Menu created successfully. Press RightShift to toggle.")
end)

if not ok then
    warn("[Dark Ice Demo] STARTUP FAILED:", err)
end
