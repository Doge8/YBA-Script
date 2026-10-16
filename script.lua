--[[
     Cirno Hub V2 - Dark Ice Edition
    Target: Your Bizarre Adventure (YBA)
    UI Framework: Native Dark Ice UI (No External Libs)
    Hotkeys: Right Shift (Toggle UI)
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Xóa UI cũ nếu có
local old = playerGui:FindFirstChild("DarkIceUI")
if old then
    old:Destroy()
end

-- BẢNG MÀU THEME DARK ICE
local BG = Color3.fromRGB(13, 18, 29)
local PANEL = Color3.fromRGB(21, 29, 44)
local ICE = Color3.fromRGB(90, 210, 255)
local WHITE = Color3.fromRGB(225, 240, 255)
local MUTED = Color3.fromRGB(125, 145, 170)

-- TẠO SCREENGUI
local gui = Instance.new("ScreenGui")
gui.Name = "DarkIceUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = playerGui

-- TẠO KHUNG CỬA SỔ CHÍNH (MAIN)
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(340, 420)
main.Position = UDim2.new(0.5, -170, 0.4, -210)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = main

local stroke = Instance.new("UIStroke")
stroke.Color = ICE
stroke.Transparency = 0.35
stroke.Thickness = 1.3
stroke.Parent = main

-- HEADER (TIÊU ĐỀ MENU)
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
title.Text = "CIRNO HUB V2"
title.TextColor3 = ICE
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -65, 0, 18)
subtitle.Position = UDim2.fromOffset(16, 32)
subtitle.BackgroundTransparency = 1
subtitle.Text = "YBA  /  RIGHT SHIFT TO TOGGLE"
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

-- CONTENT LIST (DANH SÁCH CHỨC NĂNG SCROLL)
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

-- HÀM TẠO DÒNG KHUNG UI
local function makeRow(height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -5, 0, height)
    row.BackgroundColor3 = PANEL
    row.BorderSizePixel = 0
    row.Parent = content

    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)
    return row
end

-- HÀM TẠO NÚT TOGGLE
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
        local target = enabled and ICE or Color3.fromRGB(48, 57, 73)

        TweenService:Create(button, TweenInfo.new(0.15), {BackgroundColor3 = target}):Play()
        button.Text = enabled and "ON" or "OFF"

        if callback then
            local ok, err = pcall(callback, enabled)
            if not ok then warn("[Dark Ice] Toggle error:", err) end
        end
    end)

    return function() return enabled end
end

-- HÀM TẠO THANH SLIDER
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
    fill.Size = UDim2.new((defaultValue - minValue) / (maxValue - minValue), 0, 1, 0)
    fill.BackgroundColor3 = ICE
    fill.BorderSizePixel = 0
    fill.Parent = track

    Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local value = defaultValue

    local function update(inputX)
        local ratio = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        value = math.floor(minValue + ratio * (maxValue - minValue))
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        valueLabel.Text = tostring(value)

        if callback then
            local ok, err = pcall(callback, value)
            if not ok then warn("[Dark Ice] Slider error:", err) end
        end
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position.X)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position.X)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- =======================================================
-- KHO LOGIC CHỨC NĂNG GIAO DIỆN CIRNO HUB V2
-- =======================================================

local speedEnabled = false
local customSpeed = 50
local customJump = 50
local isNoclip = false
local hitboxEnabled = false
local hitboxSize = 10
local playerEspEnabled = false
local itemEspEnabled = false
local isItemTween = false
local itemTweenSpeed = 150

-- 1. SPEED HACK (KHÓA CỨNG TỐC ĐỘ CHỐNG YBA RESET)
makeToggle("Bật Speed Hack", function(enabled)
    speedEnabled = enabled
end)

makeSlider("WalkSpeed (Tốc Độ)", 16, 200, 50, function(val)
    customSpeed = val
end)

RunService.Heartbeat:Connect(function()
    if speedEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = customSpeed
    end
end)

-- 2. JUMP POWER (LỰC NHẢY)
makeSlider("JumpPower (Lực Nhảy)", 50, 300, 50, function(val)
    customJump = val
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.UseJumpPower = true
        player.Character.Humanoid.JumpPower = val
    end
end)

-- 3. NOCLIP (ĐI XUYÊN TƯỜNG)
local noclipConn = nil
makeToggle("Đi Xuyên Tường (Noclip)", function(enabled)
    isNoclip = enabled
    if isNoclip then
        noclipConn = RunService.Stepped:Connect(function()
            if player.Character then
                for _, part in pairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    end
end)

-- 4. HITBOX EXPANDER
makeToggle("Hitbox Expander", function(enabled)
    hitboxEnabled = enabled
end)

makeSlider("Kích Thước Hitbox", 2, 20, 10, function(val)
    hitboxSize = val
end)

RunService.Heartbeat:Connect(function()
    if hitboxEnabled then
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    hrp.Transparency = 0.6
                    hrp.CanCollide = false
                end
            end
        end)
    end
end)

-- 5. PLAYER ESP
makeToggle("Player ESP (Nhìn Người)", function(enabled)
    playerEspEnabled = enabled
    if not playerEspEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local hl = p.Character:FindFirstChild("CirnoPlayerESP")
                if hl then hl:Destroy() end
            end
        end
    end
end)

RunService.Heartbeat:Connect(function()
    if playerEspEnabled then
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character then
                    if not p.Character:FindFirstChild("CirnoPlayerESP") then
                        local hl = Instance.new("Highlight")
