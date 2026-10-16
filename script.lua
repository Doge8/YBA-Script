-- =======================================================
-- CIRNO HUB - YBA SCRIPT (100% ORIGINAL - NO COPY)
-- Created for: Cirno Hub
-- =======================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Xóa GUI cũ nếu đã mở trước đó
local CoreGui = game:GetService("CoreGui")
if CoreGui:FindFirstChild("CirnoHubGUI") then
    CoreGui.CirnoHubGUI:Destroy()
end

-- 1. TẠO SCREEN GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CirnoHubGUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false

-- 2. TẠO FRAME CHÍNH (BẢNG MENU)
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 320, 0, 260)
MainFrame.Position = UDim2.new(0.5, -160, 0.4, -130)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 35) -- Màu xanh băng giá Cirno
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Bấm giữ chuột để kéo đi toàn màn hình
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

-- 3. TIÊU ĐỀ CIRNO HUB
local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 40)
TitleBar.BackgroundColor3 = Color3.fromRGB(0, 130, 215) -- Màu xanh đặc trưng của Cirno
TitleBar.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleBar.Text = "❄️ CIRNO HUB | YBA ❄️"
TitleBar.Font = Enum.Font.SourceSansBold
TitleBar.TextSize = 17
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- 4. QUẢN LÝ THÔNG SỐ
local currentSpeed = 16
local currentJump = 50
local isNoclip = false
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

-- 5. NÚT SPEED
local speedBtn
speedBtn = createButton("⚡ Tốc Độ: Mặc Định (16)", 50, Color3.fromRGB(0, 150, 230), function(btn)
    if currentSpeed == 16 then
        currentSpeed = 50
        btn.Text = "⚡ Tốc Độ: Nhanh (50)"
        btn.BackgroundColor3 = Color3.fromRGB(0, 190, 255)
    elseif currentSpeed == 50 then
        currentSpeed = 100
        btn.Text = "⚡ Tốc Độ: Tối Đa (100)"
        btn.BackgroundColor3 = Color3.fromRGB(140, 0, 255)
    else
        currentSpeed = 16
        btn.Text = "⚡ Tốc Độ: Mặc Định (16)"
        btn.BackgroundColor3 = Color3.fromRGB(0, 150, 230)
    end

    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
    end
end)

-- 6. NÚT JUMP
local jumpBtn
jumpBtn = createButton("🦘 Nhảy Cao: Mặc Định (50)", 100, Color3.fromRGB(230, 130, 0), function(btn)
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
createButton("👻 Noclip: TẮT", 150, Color3.fromRGB(200, 50, 50), function(btn)
    isNoclip = not isNoclip
    if isNoclip then
        btn.Text = "👻 Noclip: BẬT"
        btn.BackgroundColor3 = Color3.fromRGB(40, 190, 80)
        
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
        btn.Text = "👻 Noclip: TẮT"
        btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
    end
end)

-- NÚT ĐÓNG HUB
createButton("❌ Tắt Cirno Hub", 200, Color3.fromRGB(60, 60, 70), function()
    ScreenGui:Destroy()
end)

-- TỰ GIỮ CHỈ SỐ KHI RESET / CHẾT
LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    task.wait(0.5)
    humanoid.WalkSpeed = currentSpeed
    humanoid.UseJumpPower = true
    humanoid.JumpPower = currentJump
end)

print("❄️ Cirno Hub Loaded Successfully!")
