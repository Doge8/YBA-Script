-- =======================================================
-- ❄️ CIRNO HUB V2 - WIND UI EDITION (MONHUB STYLE) ❄️
-- Created for: Cirno Hub / Doge8
-- Toggle Key: Right Shift (Shift Phải)
-- =======================================================

-- Tải Thư viện WindUI (Thư viện UI siêu mượt của MonHub)
local WindUI = loadstring(game:HttpGet("https://tree-hub.vercel.app/api/UI/WindUI"))()

-- 1. TẠO CỬA SỔ CHÍNH
local Window = WindUI:CreateWindow({
    Title = "❄️ CIRNO HUB | YBA ❄️",
    Icon = "snowflake",
    Author = "Doge8",
    Folder = "CirnoHubConfig",
    Size = UDim2.fromOffset(550, 360),
    Transparent = true,
    Theme = "Dark",
    SideBarWidth = 170,
    HasOutline = true,
})

-- 2. TẠO CÁC TAB
local MainTab = Window:Tab({
    Title = "Trang Bị Nhân Vật",
    Icon = "user",
})

local ItemTab = Window:Tab({
    Title = "Item & Tự Động",
    Icon = "box",
})

-- KHO BIẾN HỆ THỐNG
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

local currentSpeed = 16
local currentJump = 50
local isNoclip = false
local isMagnet = false
local noclipConnection = nil

-- =======================================================
-- TAB 1: PLAYER (TỐC ĐỘ, NHẢY, NOCLIP)
-- =======================================================

MainTab:Slider({
    Title = "Tốc Độ Chạy (WalkSpeed)",
    Desc = "Kéo để chỉnh tốc độ di chuyển nhân vật",
    Default = 16,
    Min = 16,
    Max = 200,
    Callback = function(Value)
        currentSpeed = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

MainTab:Slider({
    Title = "Lực Nhảy (JumpPower)",
    Desc = "Kéo để chỉnh độ cao khi nhảy",
    Default = 50,
    Min = 50,
    Max = 300,
    Callback = function(Value)
        currentJump = Value
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid.UseJumpPower = true
            LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end
})

MainTab:Toggle({
    Title = "Đi Xuyên Tường (Noclip)",
    Desc = "Cho phép nhân vật đi xuyên qua vật thể & tường",
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

-- =======================================================
-- TAB 2: ITEM & TỰ ĐỘNG (HÚT ITEM VỀ CHÂN)
-- =======================================================

ItemTab:Toggle({
    Title = "Tự Động Hút Item (Item Magnet)",
    Desc = "Tự động kéo Arrow, Rokakaka, Diary... quanh map về chân",
    Default = false,
    Callback = function(Value)
        isMagnet = Value
        if isMagnet then
            task.spawn(function()
                while isMagnet do
                    pcall(function()
                        local char = LocalPlayer.Character
                        if char and char:FindFirstChild("HumanoidRootPart") then
                            local hrp = char.HumanoidRootPart
                            for _, obj in pairs(Workspace:GetChildren()) do
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

-- TỰ DÙNG LẠI CHỈ SỐ KHI CHẾT / RESET
LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    task.wait(0.5)
    humanoid.WalkSpeed = currentSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = currentJump
end)

-- BẤM RIGHT SHIFT ĐỂ ẨN / HIỆN MENU
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        Window:Toggle()
    end
end)

print("❄️ Cirno Hub WindUI Version Loaded!")
