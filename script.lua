-- =======================================================
-- CIRNO HUB V2 - YBA EDITION
-- Created by: Doge8 / Cirno Hub
-- Toggle Key: Right Shift
-- =======================================================

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- 1. KÍNH / GIAO DIỆN CHÍNH
local Window = OrionLib:MakeWindow({
    Name = "❄️ CIRNO HUB V2 | YBA ❄️", 
    HidePremium = false, 
    SaveConfig = true, 
    ConfigFolder = "CirnoHubConfig",
    IntroText = "Welcome to Cirno Hub V2"
})

-- TAB 1: PLAYER (TỐC ĐỘ, NHẢY, NOCLIP)
local PlayerTab = Window:MakeTab({
    Name = "Trang Bị Nhân Vật",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- TAB 2: ITEM & FARM (HÚT ĐỒ, ITEM)
local ItemTab = Window:MakeTab({
    Name = "Item & Tự Động",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local player = game.Players.LocalPlayer
local runService = game:GetService("RunService")
local workspace = game:GetService("Workspace")

local currentSpeed = 16
local currentJump = 50
local noclipEnabled = false
local magnetEnabled = false
local noclipConnection = nil
local magnetConnection = nil

-- [PLAYER TAB] 1. SLIDER TỐC ĐỘ
PlayerTab:AddSlider({
    Name = "WalkSpeed (Tốc độ chạy)",
    Min = 16,
    Max = 200,
    Default = 16,
    Color = Color3.fromRGB(0, 170, 255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        currentSpeed = Value
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.WalkSpeed = Value
        end
    end    
})

-- [PLAYER TAB] 2. SLIDER LỰC NHẢY
PlayerTab:AddSlider({
    Name = "JumpPower (Lực nhảy)",
    Min = 50,
    Max = 300,
    Default = 50,
    Color = Color3.fromRGB(0, 220, 255),
    Increment = 5,
    ValueName = "Jump",
    Callback = function(Value)
        currentJump = Value
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            player.Character.Humanoid.UseJumpPower = true
            player.Character.Humanoid.JumpPower = Value
        end
    end    
})

-- [PLAYER TAB] 3. NOCLIP
PlayerTab:AddToggle({
    Name = "Đi Xuyên Tường (Noclip)",
    Default = false,
    Callback = function(Value)
        noclipEnabled = Value
        if noclipEnabled then
            noclipConnection = runService.Stepped:Connect(function()
                if player.Character then
                    for _, part in pairs(player.Character:GetDescendants()) do
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

-- [ITEM TAB] 4. HÚT ITEM VỀ CHÂN (ITEM MAGNET)
ItemTab:AddToggle({
    Name = "Tự Động Hút Item (Arrow, Roka, Diary...)",
    Default = false,
    Callback = function(Value)
        magnetEnabled = Value
        if magnetEnabled then
            task.spawn(function()
                while magnetEnabled do
                    pcall(function()
                        local char = player.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            for _, obj in pairs(workspace:GetChildren()) do
                                -- Quét các vật phẩm phổ biến trong YBA
                                if obj.Name == "Arrow" or obj.Name == "Rokakaka" or obj.Name == "Mysterious Arrow" or obj.Name == "RIP Diary" then
                                    local handle = obj:FindFirstChild("Handle") or obj:FindFirstChildOfClass("BasePart")
                                    if handle then
                                        handle.CFrame = hrp.CFrame
                                    end
                                end
                            end
                        end
                    end)
                    task.wait(0.5)
                end
            end)
        end
    end
})

-- GIỮ NGUYÊN CHỈ SỐ KHI CHẾT/RESET
player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    task.wait(0.5)
    humanoid.WalkSpeed = currentSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = currentJump
end)

OrionLib:Init()
