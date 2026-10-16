-- =======================================================
-- ❄️ CIRNO HUB V2 - NATIVE UI EDITION (NO EXTERNAL LIB) ❄️
-- Created for: Cirno Hub / Doge8
-- Anti-Crash & Fully Supported on Xeno / Mobile / PC
-- =======================================================

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Xóa ScreenGui cũ nếu có
if CoreGui:FindFirstChild("CirnoHubNative") then
    CoreGui.CirnoHubNative:Destroy()
end

-- TẠO SCREENGUI CHÍNH
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CirnoHubNative"
ScreenGui.ResetOnSpawn = false
pcall(function() ScreenGui.Parent = CoreGui end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

-- KHUNG CỬA SỔ MAIN
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 360, 0, 280)
MainFrame.Position = UDim2.new(0.5, -180, 0.4, -140)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainUICorner = Instance.new("UICorner")
MainUICorner.CornerRadius = UDim.new(0, 8)
MainUICorner.Parent = MainFrame

-- TIÊU ĐỀ MENU
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -10, 0, 35)
TitleLabel.Position = UDim2.new(0, 10, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "❄️ CIRNO HUB V2 | YBA EDITION ❄️"
TitleLabel.TextColor3 = Color3.fromRGB(0, 220, 255)
TitleLabel.TextSize = 15
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = MainFrame

-- NÚT ĐÓN/ẨN QUICK TOGGLE
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 25, 0, 25)
CloseBtn.Position = UDim2.new(1, -30, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 14
CloseBtn.Parent = MainFrame

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 4)
CloseCorner.Parent = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- VÙNG CHỨA CÁC NÚT (SCROLL)
local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -45)
Container.Position = UDim2.new(0, 10, 0, 40)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 4
Container.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)
UIListLayout.Parent = Container

-- KHO BIẾN HỆ THỐNG
local speedEnabled = false
local customSpeed = 50
local isNoclip = false
local isItemTween = false
local itemTweenSpeed = 150
local playerEspEnabled = false
local itemEspEnabled = false
local hitboxEnabled = false

-- HAM TẠO NÚT TOGGLE
local function CreateToggle(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 32)
    btn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
    btn.Text = "[ OFF ]  " .. text
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14
    btn.Parent = Container

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        if state then
            btn.BackgroundColor3 = Color3.fromRGB(0, 150, 220)
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            btn.Text = "[ ON ]  " .. text
        else
            btn.BackgroundColor3 = Color3.fromRGB(40, 45, 60)
            btn.TextColor3 = Color3.fromRGB(200, 200, 200)
            btn.Text = "[ OFF ]  " .. text
        end
        callback(state)
    end)
    return btn
end

-- =======================================================
-- TẠO CÁC NÚT CHỨC NĂNG
-- =======================================================

-- 1. SPEED HACK
CreateToggle("Bật Speed Hack (Tốc Độ 50)", function(val)
    speedEnabled = val
end)

RunService.Heartbeat:Connect(function()
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = customSpeed
    end
end)

-- 2. NOCLIP
local noclipConn = nil
CreateToggle("Đi Xuyên Tường (Noclip)", function(val)
    isNoclip = val
    if isNoclip then
        noclipConn = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, p in pairs(LocalPlayer.Character:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    else
        if noclipConn then noclipConn:Disconnect() noclipConn = nil end
    end
end)

-- 3. HITBOX EXPANDER
CreateToggle("Hitbox Expander (Mở Rộng Tầm Đánh)", function(val)
    hitboxEnabled = val
end)

RunService.Heartbeat:Connect(function()
    if hitboxEnabled then
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local hrp = p.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(10, 10, 10)
                    hrp.Transparency = 0.6
                    hrp.CanCollide = false
                end
            end
        end)
    end
end)

-- 4. PLAYER ESP
CreateToggle("Player ESP (Nhìn Xuyên Tường Người)", function(val)
    playerEspEnabled = val
    if not playerEspEnabled then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
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
                if p ~= LocalPlayer and p.Character then
                    if not p.Character:FindFirstChild("CirnoPlayerESP") then
                        local hl = Instance.new("Highlight")
                        hl.Name = "CirnoPlayerESP"
                        hl.FillColor = Color3.fromRGB(255, 50, 50)
                        hl.Parent = p.Character
                    end
                end
            end
        end)
    end
end)

-- 5. ITEM ESP
CreateToggle("Item ESP (Nhìn Xuyên Tường Item)", function(val)
    itemEspEnabled = val
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
                            hl.FillColor = Color3.fromRGB(0, 255, 255)
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
                            txt.TextColor3 = Color3.fromRGB(0, 255, 255)
                            txt.Text = "📦 " .. obj.Name
                            txt.TextSize = 12
                            txt.Font = Enum.Font.SourceSansBold
                            txt.Parent = bg
                        end
                    end
                end
            end)
        end
    end
end)

-- 6. AUTO TWEEN & PICKUP ITEM
CreateToggle("Auto Tween & Pickup Item (Tự Bay Lượm)", function(val)
    isItemTween = val
    if isItemTween then
        task.spawn(function()
            while isItemTween do
                pcall(function()
                    local char = LocalPlayer.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        for _, obj in pairs(Workspace:GetChildren()) do
                            if not isItemTween then break end
                            if obj
