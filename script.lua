-- =======================================================
-- ❄️ CIRNO HUB V2 | YBA (PURE UI - NO EXTERNAL LIB) ❄️
-- Created by: Doge8 / Cirno Hub
-- Toggle Key: Right Shift (Shift Phải)
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Xóa GUI cũ nếu đã tồn tại
if CoreGui:FindFirstChild("CirnoHubV2Pure") then
    CoreGui.CirnoHubV2Pure:Destroy()
end

-- 1. SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CirnoHubV2Pure"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- 2. MAIN FRAME (BẢNG MENU CHÍNH)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 340, 0, 310)
MainFrame.Position = UDim2.new(0.5, -170, 0.35, -155)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 22, 30) -- Màu xanh đen Cirno
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Giữ chuột kéo đi toàn màn hình
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- 3. TITLE BAR
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 42)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 130, 215)
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.Text = "❄️ CIRNO HUB V2 | YBA ❄️"
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.TextSize = 17
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Subtitle hướng dẫn
local SubTitle = Instance.new("TextLabel")
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 1, -20)
SubTitle.BackgroundTransparency = 1
SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
SubTitle.Text = "Bấm 'Right Shift' để Ẩn/Hiện Menu"
SubTitle.Font = Enum.Font.SourceSans
SubTitle.TextSize = 12
SubTitle.Parent = MainFrame

-- 4. BIẾN QUẢN LÝ
local currentSpeed = 16
local currentJump = 50
local isNoclip = false
local isMagnet = false
local noclipConnection = nil

-- HÀM TẠO NÚT BẤM
local function createButton(text, posY, color, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 38)
    btn.Position = UDim2.new(0.05, 0, 0, posY)
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = MainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn

    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

-- 5. NÚT CHỈNH TỐC ĐỘ (SPEED)
createButton("⚡ Tốc Độ: Mặc Định (16)", 50, Color3.fromRGB(0, 140, 220), function(btn)
    if currentSpeed == 16 then
        currentSpeed = 50
        btn.Text = "⚡ Tốc Độ: Nhanh (50)"
        btn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    elseif currentSpeed == 50 then
        currentSpeed = 100
        btn.Text = "⚡ Tốc Độ: Siêu Nhanh (100)"
        btn.BackgroundColor3 = Color3.fromRGB(140, 0, 255)
    else
        currentSpeed = 16
        btn.Text = "⚡ Tốc Độ: Mặc Định (16)"
        btn.BackgroundColor3 = Color3.fromRGB(0, 140, 220)
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
    end
end)

-- 6. NÚT CHỈNH LỰC NHẢY (JUMP)
createButton("🦘 Nhảy Cao: Mặc Định (50)", 100, Color3.fromRGB(220, 130, 0), function(btn)
    if currentJump == 50 then
        currentJump = 120
        btn.Text = "🦘 Nhảy Cao: Cao (120)"
    elseif currentJump == 120 then
        currentJump = 200
        btn.Text = "🦘 Nhảy Cao: Siêu Cao (200)"
    else
        currentJump = 50
        btn.Text = "🦘 Nhảy Cao: Mặc Định (50)"
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.UseJumpPower = true
        LocalPlayer.Character.Humanoid.JumpPower = currentJump
    end
end)

-- 7. NÚT NOCLIP
createButton("👻 Đi Xuyên Tường: TẮT", 150, Color3.fromRGB(180, 50, 50), function(btn)
    isNoclip = not isNoclip
    if isNoclip then
        btn.Text = "👻 Đi Xuyên Tường: ĐANG BẬT"
        btn.BackgroundColor3 = Color3.fromRGB(40, 180, 70)
        
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
        btn.Text = "👻 Đi Xuyên Tường: TẮT"
        btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
        
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end)

-- 8. NÚT HÚT ITEM (ITEM MAGNET)
createButton("🧲 Tự Động Hút Item (Arrow, Roka...): TẮT", 200, Color3.fromRGB(180, 50, 50), function(btn)
    isMagnet = not isMagnet
    if isMagnet then
        btn.Text = "🧲 Tự Động Hút Item: ĐANG BẬT"
        btn.BackgroundColor3 = Color3.fromRGB(40, 180, 70)
        
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
    else
        btn.Text = "🧲 Tự Động Hút Item: TẮT"
        btn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
    end
end)

-- NÚT ĐÓNG HOÀN TOÀN
createButton("❌ Tắt Hẳn Cirno Hub", 250, Color3.fromRGB(60, 60, 70), function()
    ScreenGui:Destroy()
end)

-- 9. PHÍM TRẮT RIGHT SHIFT
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- TỰ GIỮ THÔNG SỐ KHI RESET/CHẾT
LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    task.wait(0.5)
    humanoid.WalkSpeed = currentSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = currentJump
end)

print("❄️ Cirno Hub V2 Loaded Successfully!")
