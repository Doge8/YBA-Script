--[[
    Cirno Hub V2 - Dark Ice Ultimate Edition
    Target: Your Bizarre Adventure (YBA)
    UI Framework: Native Dark Ice UI (Massive Feature Set)
    Toggle Key: Right Shift
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- XÓA UI CŨ TRÁNH TRÙNG LẶP
pcall(function()
    if CoreGui:FindFirstChild("DarkIceUI") then CoreGui.DarkIceUI:Destroy() end
    if playerGui:FindFirstChild("DarkIceUI") then playerGui.DarkIceUI:Destroy() end
end)

-- BẢNG MÀU THEME DARK ICE
local BG = Color3.fromRGB(13, 18, 29)
local PANEL = Color3.fromRGB(21, 29, 44)
local ICE = Color3.fromRGB(90, 210, 255)
local WHITE = Color3.fromRGB(225, 240, 255)
local MUTED = Color3.fromRGB(125, 145, 170)

-- TẠO SCREENGUI AN TOÀN CHO XENO
local gui = Instance.new("ScreenGui")
gui.Name = "DarkIceUI"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true

local success = pcall(function()
    gui.Parent = CoreGui
end)
if not success then
    gui.Parent = playerGui
end

-- TẠO KHUNG CỬA SỔ CHÍNH (MAIN)
local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(360, 460)
main.Position = UDim2.new(0.5, -180, 0.4, -230)
main.BackgroundColor3 = BG
main.BorderSizePixel = 0
main.Active = true
main.Draggable = true
main.Visible = true
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
title.Text = "CIRNO HUB V2 [ULTIMATE]"
title.TextColor3 = ICE
title.Font = Enum.Font.GothamBold
title.TextSize = 17
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -65, 0, 18)
subtitle.Position = UDim2.fromOffset(16, 32)
subtitle.BackgroundTransparency = 1
subtitle.Text = "YBA EDITION  /  RIGHT SHIFT"
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

-- CONTENT LIST (SCROLLING)
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

-- HÀM TẠO TIÊU ĐỀ PHÂN LOẠI (SECTION LABEL)
local function makeSection(text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -5, 0, 24)
    lbl.BackgroundTransparency = 1
    lbl.Text = "  📌 " .. string.upper(text)
    lbl.TextColor3 = ICE
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = content
end

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
    local row = makeRow(42)

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
    button.Size = UDim2.fromOffset(48, 24)
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
        if callback then pcall(callback, enabled) end
    end)

    return function() return enabled end
end

local function makeSlider(labelText, minValue, maxValue, defaultValue, callback)
    local row = makeRow(62)

    local label = Instance.new("TextLabel")
    label.Position = UDim2.fromOffset(12, 4)
    label.Size = UDim2.new(1, -24, 0, 18)
    label.BackgroundTransparency = 1
    label.TextColor3 = WHITE
    label.Text = labelText
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.fromOffset(50, 18)
    valueLabel.Position = UDim2.new(1, -62, 0, 4)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextColor3 = ICE
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 12
    valueLabel.Text = tostring(defaultValue)
    valueLabel.Parent = row

    local track = Instance.new("Frame")
    track.Position = UDim2.new(0, 12, 0, 34)
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
    local function update(inputX)
        local ratio = math.clamp((inputX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local value = math.floor(minValue + ratio * (maxValue - minValue))
        fill.Size = UDim2.new(ratio, 0, 1, 0)
        valueLabel.Text = tostring(value)
        if callback then pcall(callback, value) end
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

local function makeButton(buttonText, callback)
    local row = makeRow(38)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 1, -8)
    btn.Position = UDim2.fromOffset(8, 4)
    btn.BackgroundColor3 = Color3.fromRGB(35, 45, 65)
    btn.Text = buttonText
    btn.TextColor3 = ICE
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.Parent = row

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

    btn.Activated:Connect(function()
        if callback then pcall(callback) end
    end)
end

-- =======================================================
-- TÍCH HỢP TẤT CẢ TÍNH NĂNG KHỦNG CHO YBA
-- =======================================================

makeSection("1. Nhân Vật & Combat")

local speedEnabled = false
local customSpeed = 50
local customJump = 50
local isNoclip = false
local hitboxEnabled = false
local hitboxSize = 10

makeToggle("Bật Speed Hack", function(enabled) speedEnabled = enabled end)
makeSlider("WalkSpeed (Tốc Độ)", 16, 200, 50, function(val) customSpeed = val end)

RunService.Heartbeat:Connect(function()
    if speedEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = customSpeed
    end
end)

makeSlider("JumpPower (Lực Nhảy)", 50, 300, 50, function(val)
    customJump = val
    if player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.UseJumpPower = true
        player.Character.Humanoid.JumpPower = val
    end
end)

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

makeToggle("Hitbox Expander (Mở Rộng Đánh)", function(enabled) hitboxEnabled = enabled end)
makeSlider("Kích Thước Hitbox", 2, 20, 10, function(val) hitboxSize = val end)

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

makeSection("2. ESP & Nhìn Xuyên Tường")

local playerEspEnabled = false
local itemEspEnabled = false

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
                        hl.Name = "CirnoPlayerESP"
                        hl.FillColor = Color3.fromRGB(255, 60, 60)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Parent = p.Character
                    end
                end
            end
        end)
    end
end)

makeToggle("Item ESP (Nhìn Item Xung Quanh)", function(enabled)
    itemEspEnabled = enabled
    if not itemEspEnabled then
        for _, obj in pairs(Workspace:GetChildren()) do
            local hl = obj:FindFirstChild("CirnoItemESP")
            if hl then hl:Destroy() end
            local bg = obj:FindFirstChild("CirnoItemTag")
            if bg then bg:Destroy() end
        end
    end
end)

task.spawn(function()
    while task.wait(1) do
        if itemEspEnabled then
            pcall(function()
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj.Name == "Arrow" or obj.Name == "Rokakaka" or obj.Name == "Mysterious Arrow" or obj.Name == "RIP Diary" or obj.Name == "Pure Rokakaka" then
                        if not obj:FindFirstChild("CirnoItemESP") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "CirnoItemESP"
                            hl.FillColor = ICE
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.Parent = obj

                            local bg = Instance.new("BillboardGui")
                            bg.Name = "CirnoItemTag"
                            bg.Size = UDim2.new(0, 100, 0, 30)
                            bg.StudsOffset = Vector3.new(0, 2, 0)
                            bg.AlwaysOnTop = true
                            bg.Parent = obj

                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.TextColor3 = ICE
                            txt.Text = "📦 " .. obj.Name
                            txt.TextSize = 12
                            txt.Font = Enum.Font.GothamBold
                            txt.Parent = bg
                        end
                    end
                end
            end)
        end
    end
end)

makeSection("3. Săn Item Tự Động")

local isItemTween = false
local itemTweenSpeed = 150

makeSlider("Tốc Độ Bay Lượm Item", 50, 300, 150, function(val) itemTweenSpeed = val end)

makeToggle("Auto Tween & Pickup Item", function(enabled)
    isItemTween = enabled
    if isItemTween then
        task.spawn(function()
            while isItemTween do
                pcall(function()
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        for _, obj in pairs(Workspace:GetChildren()) do
                            if not isItemTween then break end
                            if obj.Name == "Arrow" or obj.Name == "Rokakaka" or obj.Name == "Mysterious Arrow" or obj.Name == "RIP Diary" or obj.Name == "Pure Rokakaka" then
                                local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
                                if handle then
                                    local distance = (hrp.Position - handle.Position).Magnitude
                                    local time = distance / itemTweenSpeed
                                    local info = TweenInfo.new(time, Enum.EasingStyle.Linear)
                                    local tween = TweenService:Create(hrp, info, {CFrame = handle.CFrame + Vector3.new(0, 2, 0)})
                                    tween:Play()
                                    tween.Completed:Wait()

                                    task.wait(0.1)
                                    local cd = obj:FindFirstChildOfClass("ClickDetector") or handle:FindFirstChildOfClass("ClickDetector")
                                    if cd and fireclickdetector then fireclickdetector(cd
