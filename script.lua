-- =======================================================
-- ❄️ CIRNO HUB V2 - YBA EDITION (RAYFIELD UI) ❄️
-- Created for: Cirno Hub / Doge8
-- =======================================================

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "❄️ CIRNO HUB | YBA EDITION ❄️",
   LoadingTitle = "Cirno Hub V2",
   LoadingSubtitle = "by Doge8",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "CirnoHubConfig",
      FileName = "YBAConfig"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvite",
      RememberJoins = true
   },
   KeySystem = false,
})

-- TẠO CÁC TAB CHỨC NĂNG
local MainTab = Window:CreateTab("⚡ Nhân Vật & Combat", 4483345998)
local ItemTab = Window:CreateTab("🧲 Item & Tự Động", 4483345998)

-- KHO BIẾN HỆ THỐNG
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

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

Rayfield:Notify({
   Title = "Cirno Hub Loaded!",
   Content = "Script đã tải thành công, chiến game thôi!",
   Duration = 5,
   Image = 4483345998,
})

-- =======================================================
-- TAB 1: NHÂN VẬT & COMBAT
-- =======================================================

MainTab:CreateToggle({
   Name = "Bật Tốc Độ (Speed Hack)",
   CurrentValue = false,
   Flag = "SpeedToggle",
   Callback = function(Value)
      speedEnabled = Value
   end,
})

MainTab:CreateSlider({
   Name = "Mức Tốc Độ Chạy",
   Range = {16, 200},
   Increment = 1,
   Suffix = "Speed",
   CurrentValue = 16,
   Flag = "SpeedSlider",
   Callback = function(Value)
      customSpeed = Value
   end,
})

RunService.Heartbeat:Connect(function()
    if speedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = customSpeed
    end
end)

MainTab:CreateSlider({
   Name = "Lực Nhảy (JumpPower)",
   Range = {50, 300},
   Increment = 5,
   Suffix = "Jump",
   CurrentValue = 50,
   Flag = "JumpSlider",
   Callback = function(Value)
      customJump = Value
      if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
          LocalPlayer.Character.Humanoid.UseJumpPower = true
          LocalPlayer.Character.Humanoid.JumpPower = Value
      end
   end,
})

MainTab:CreateToggle({
   Name = "Đi Xuyên Tường (Noclip)",
   CurrentValue = false,
   Flag = "NoclipToggle",
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
   end,
})

MainTab:CreateToggle({
   Name = "Hitbox Expander (Mở rộng tầm đánh)",
   CurrentValue = false,
   Flag = "HitboxToggle",
   Callback = function(Value)
      hitboxEnabled = Value
   end,
})

MainTab:CreateSlider({
   Name = "Kích thước Hitbox",
   Range = {2, 15},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = 5,
   Flag = "HitboxSlider",
   Callback = function(Value)
      hitboxSize = Value
   end,
})

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

MainTab:CreateToggle({
   Name = "Player ESP (Nhìn xuyên tường người chơi)",
   CurrentValue = false,
   Flag = "PlayerEspToggle",
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
   end,
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
-- TAB 2: ITEM & TỰ ĐỘNG
-- =======================================================

ItemTab:CreateToggle({
   Name = "Item ESP (Nhìn thấy Arrow, Roka xuyên tường)",
   CurrentValue = false,
   Flag = "ItemEspToggle",
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
   end,
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

ItemTab:CreateSlider({
   Name = "Tốc độ bay tới Item (Tween Speed)",
   Range = {50, 400},
   Increment = 10,
   Suffix = "Studs/s",
   CurrentValue = 150,
   Flag = "TweenSpeedSlider",
   Callback = function(Value)
      itemTweenSpeed = Value
   end,
})

ItemTab:CreateToggle({
   Name = "Auto Tween & Pickup Item (Tự bay & Lượm đồ)",
   CurrentValue = false,
   Flag = "ItemTweenToggle",
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
                                      local tween = TweenService:Create(hrp, info, {CFrame = handle.CFrame + Vector3.new(0, 2, 0)})
                                      tween:Play()
                                      tween.Completed:Wait()
                                      
                                      task.wait(0.1)
                                      local cd = obj:FindFirstChildOfClass("ClickDetector") or handle:FindFirstChildOfClass("ClickDetector")
                                      if cd and fireclickdetector then
                                          fireclickdetector(cd)
                                      end
                                      
                                      local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or handle:FindFirstChildOfClass("ProximityPrompt")
                                      if prompt and fireproximityprompt then
                                          fireproximityprompt(prompt)
                                      end
                                      
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
   end,
})

-- GIỮ CHỈ SỐ KHI RESET
LocalPlayer.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    task.wait(0.5)
    humanoid.UseJumpPower = true
    humanoid.JumpPower = customJump
end)
