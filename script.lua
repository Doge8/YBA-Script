--[[
    Cirno Hub V2 - Dark Ice Edition (Fixed String Concatenation)
    Target: Your Bizarre Adventure (YBA)
    Toggle Key: Right Shift
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- XÓA UI CŨ TRÁNH BỊ TRÙNG
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
main.Size = UDim2.fromOffset(340, 420)
main.Position = UDim2.new(0.5, -170, 0.4, -210)
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
title.Text = "CIRNO HUB V2"
title.TextColor3 = ICE
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local subtitle = Instance.new("TextLabel")
subtitle.Size = UDim2.new(1, -65, 0, 18)
subtitle.Position = UDim2.fromOffset(16, 32)
subtitle.BackgroundTransparency
