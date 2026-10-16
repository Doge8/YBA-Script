-- =======================================================
-- ❄️ CIRNO HUB V2 - YBA EDITION (FIXED MENU DISPLAY) ❄️
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

local ItemTab = Window:MakeTab({
    Name = "🧲 Item & Tự Động",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- KHO BIẾN HỆ THỐNG
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Biến chức năng
local speedEnabled = false
local customSpeed = 16
local customJump = 50
local isNoclip = false
local isItemTween = false
local itemTweenSpeed = 150

local playerEspEnabled = false
local itemEspEnabled = false
local hitboxEnabled = false
local hitboxSize = 5

local noclipConnection = nil

-- Thông báo khi load
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

RunService.
