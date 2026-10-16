-- =======================================================
-- ❄️ CIRNO HUB V2 - YBA EDITION (TWEEN ITEM & COMBAT) ❄️
-- Created for: Cirno Hub / Doge8
-- Toggle Key: Right Shift (Shift Phải)
-- =======================================================

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- 1. TẠO CỬA SỔ CHÍNH
local Window = OrionLib:MakeWindow({
    Name = "❄️ CIRNO HUB | YBA EDITION ❄️", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "CirnoHubConfig",
    IntroText = "Loading Cirno Hub V2..."
})

-- 2. TẠO CÁC TAB CHỨC NĂNG
local MainTab = Window:MakeTab({
    Name = "⚡ Nhân Vật & Combat",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local ItemTab = Window:Tab({
    Name = "🧲 Item & Tự Động",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- KHO BIẾN HỆ THỐNG
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- Biến chức năng
local speedEnabled = false
local customSpeed = 16
local customJump = 50
local isNoclip = false
local isItemTween = false
local itemTweenSpeed = 150 -- Tốc độ bay mặc định (Studs/s)

local playerEspEnabled = false
local itemEspEnabled = false
local hitboxEnabled = false
local hitboxSize = 5

local noclipConnection = nil

-- Thông báo khi load xong
OrionLib:MakeNotification({
    Name = "Cirno Hub Loaded!",
    Content = "Bấm phím 'Right Shift' để Ẩn/Hiện Menu.",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- =======================================================
-- TAB 1: NHÂN VẬT & COMBAT (SPEED, NOCLIP, HITBOX, ESP)
-- =======================================================

MainTab:AddToggle({
    Name = "Bật Tốc Độ (Speed Hack)",
    Default = false,
    Callback = function(Value)
        speedEnabled = Value
    end
})

MainTab:AddSlider({
    Name = "Mức Tốc Độ Chạy",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(0, 180, 255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        customSpeed = Value
    end    
})

-- Khóa cứng tốc độ chống YBA tự reset
RunService.Heartbeat:Connect(function()
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = customSpeed
    end
end)

MainTab:AddSlider({
    Name = "Lực Nhảy (JumpPower)",
    Min = 50,
    Max = 300,
    Default = 50,
    Color = Color3.fromRGB(0, 220, 255),
    Increment = 5,
    ValueName = "Jump",
    Callback = function(Value)
        customJump = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end    
})

MainTab:AddToggle({
    Name = "Đi Xuyên Tường (Noclip)",
    Default = false,
    Callback = function(Value)
        isNoclip = Value
        if isNoclip then
            noclipConnection = RunService.Stepped:Connect(function()
                if LocalPlayer.Character then
                    for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end
                end
            end)
        else
            if noclipConnection then
                noclipConnection:Disconnect()
                noclipConnection = nil
            end
        end
    end    
})

MainTab:AddToggle({
    Name = "Hitbox Expander (Mở rộng tầm đánh đối thủ)",
    Default = false,
    Callback = function(Value)
        hitboxEnabled = Value
    end
})

MainTab:AddSlider({
    Name = "Kích thước Hitbox",
    Min = 2,
    Max = 15,
    Default = 5,
    Increment = 1,
    Callback = function(Value)
        hitboxSize = Value
    end
})

-- Vòng lặp Hitbox
RunService.Heartbeat:Connect(function()
    if hitboxEnabled then
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                    hrp.Transparency = 0.6
                    hrp.CanCollide = false
                end
            end
        end)
    end
end)

MainTab:AddToggle({
    Name = "Player ESP (Nhìn xuyên tường người chơi)",
    Default = false,
    Callback = function(Value)
        playerEspEnabled = Value
        if not playerEspEnabled then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hl = p.Character:FindFirstChild("CirnoPlayerESP")
                    if hl then hl:Destroy() end
                end
            end
        end
    end
})

RunService.Heartbeat:Connect(function()
    if playerEspEnabled then
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local char = p.Character
                    if not char:FindFirstChild("CirnoPlayerESP") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "CirnoPlayerESP"
                        hl.FillColor = Color3.fromRGB(255, 60, 60)
                        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                        hl.Parent = char
                    end
                end
            end
        end)
    end
end)

-- =======================================================
-- TAB 2: ITEM & TỰ ĐỘNG (TWEEN TỚI ITEM & ESP)
-- =======================================================

ItemTab:AddToggle({
    Name = "Item ESP (Nhìn thấy Arrow, Roka xuyên tường)",
    Default = false,
    Callback = function(Value)
        itemEspEnabled = Value
        if not itemEspEnabled then
            for _, obj in pairs(Workspace:GetChildren()) do
                local hl = obj:FindFirstChild("CirnoItemESP")
                if hl then hl:Destroy() end
                local bg = obj:FindFirstChild("CirnoItemTag")
                if bg then bg:Destroy() end
            end
        end
    end
})

task.spawn(function()
    while task.wait(1) do
        if itemEspEnabled then
            pcall(function()
                for _, obj in pairs(Workspace:GetChildren()) do
                    if obj.Name == "Arrow" or obj.Name == "Rokakaka" or obj.Name == "Mysterious Arrow" or obj.Name == "RIP Diary" or obj.Name == "Pure Rokakaka" then
                        if not obj:FindFirstChild("CirnoItemESP") then
                            local hl = Instance.new("Highlight")
                            hl.Name = "CirnoItemESP"
                            hl.FillColor = Color3.fromRGB(0, 255, 255)
                            hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                            hl.Parent = obj
                            
                            local bg = Instance.new("BillboardGui")
                            bg.Name = "CirnoItemTag"
                            bg.Size = UDim2.new(0, 120, 0, 40)
                            bg.StudsOffset = Vector3.new(0, 2, 0)
                            bg.AlwaysOnTop = true
                            bg.Parent = obj
                            
                            local txt = Instance.new("TextLabel")
                            txt.Size = UDim2.new(1, 0, 1, 0)
                            txt.BackgroundTransparency = 1
                            txt.TextColor3 = Color3.fromRGB(0, 255, 255)
                            txt.TextStrokeTransparency = 0
                            txt.Text = "📦 " .. obj.Name
                            txt.TextSize = 13
                            txt.Font = Enum.Font.SourceSansBold
                            txt.Parent = bg
                        end
                    end
                end
            end)
        end
    end
end)

ItemTab:AddSlider({
    Name = "Tốc độ bay tới Item (Tween Speed)",
    Min = 50,
    Max = 400,
    Default = 150,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 10,
    ValueName = "Studs/s",
    Callback = function(Value)
        itemTweenSpeed = Value
    end
})

ItemTab:AddToggle({
    Name = "Auto Teleport / Tween lượm Item (Smooth)",
    Default = false,
    Callback = function(Value)
        isItemTween = Value
        if isItemTween then
            task.spawn(function()
                while isItemTween do
                    pcall(function()
                        local char = LocalPlayer.Character
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
                                        local tween = TweenService:Create(hrp, info, {CFrame = handle.CFrame + Vector3.new(0, 3, 0)})
                                        tween:Play()
                                        tween.Completed:Wait()
                                        task.wait(0.3)
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(1)
                end
            end)
        end
    end
})

-- TỰ GIỮ CHỈ SỐ KHI RESET / CHẾT
LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    task.wait(0.5)
    humanoid.UseJumpPower = true
    humanoid.JumpPower = customJump
end)

OrionLib:Init()
