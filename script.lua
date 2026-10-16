--[[
    YBA Dark Ice - standalone executor script
    Version: 1.2.0 - startup/UI diagnostics
    UI: native Roblox instances; no external UI library / HttpGet dependency.

    Compatibility note:
    This is a client-side script. YBA server validation and executor differences
    may prevent or reset some effects. The script does not include anti-cheat bypasses.
]]


local function bootDarkIce()
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

-- Xeno may execute before LocalPlayer/PlayerGui are fully available.
local LocalPlayer = Players.LocalPlayer
local deadline = os.clock() + 15
while not LocalPlayer and os.clock() < deadline do
    task.wait(0.1)
    LocalPlayer = Players.LocalPlayer
end
if not LocalPlayer then
    error("LocalPlayer was not ready after 15 seconds. Execute again after fully joining YBA.")
end

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui", 15)
if not PlayerGui then
    error("PlayerGui did not load. Execute again after the game has finished loading.")
end

-- Prefer the executor UI container when available, then fall back to PlayerGui.
local GuiParent = PlayerGui
if type(gethui) == "function" then
    local ok, container = pcall(gethui)
    if ok and typeof(container) == "Instance" then
        GuiParent = container
    end
end

for _, container in ipairs({PlayerGui, GuiParent}) do
    local old = container:FindFirstChild("DarkIceUI")
    if old then pcall(function() old:Destroy() end) end
end

local Theme = {
    Background = Color3.fromRGB(11, 16, 27),
    Panel = Color3.fromRGB(20, 29, 44),
    Panel2 = Color3.fromRGB(29, 41, 59),
    Ice = Color3.fromRGB(104, 220, 255),
    Text = Color3.fromRGB(231, 243, 255),
    Muted = Color3.fromRGB(139, 159, 184),
    Red = Color3.fromRGB(255, 75, 85),
    Green = Color3.fromRGB(119, 255, 205),
}

local State = {
    speed = false,
    speedValue = 50,
    noclip = false,
    hitbox = false,
    playerESP = false,
    itemESP = false,
    autoPickup = false,
    itemTweenSpeed = 150,
    visible = true,
    destroyed = false,
}

local Connections = {}
local PlayerHighlights = {}
local ItemVisuals = {}
local OriginalCollision = {}
local OriginalHitboxes = {}
local CurrentTween = nil
local BusyPickup = false

local function safeCall(fn, ...)
    local ok, result = pcall(fn, ...)
    if not ok then warn("[Dark Ice]", result) end
    return ok, result
end

local function getCharacter()
    return LocalPlayer.Character
end

local function getHumanoid(character)
    character = character or getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid") or nil
end

local function getRoot(character)
    character = character or getCharacter()
    return character and (character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso")) or nil
end

local function addCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = instance
    return corner
end

local Gui = Instance.new("ScreenGui")
Gui.Name = "DarkIceUI"
Gui.ResetOnSpawn = false
Gui.IgnoreGuiInset = true
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Gui.DisplayOrder = 100000
Gui.Enabled = true
Gui.Parent = GuiParent

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Size = UDim2.fromOffset(350, 500)
Main.Position = UDim2.new(0.5, -175, 0.5, -250)
Main.BackgroundColor3 = Theme.Background
Main.BorderSizePixel = 0
Main.Parent = Gui
addCorner(Main, 13)

local Outline = Instance.new("UIStroke")
Outline.Color = Theme.Ice
Outline.Transparency = 0.28
Outline.Thickness = 1.25
Outline.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 62)
Header.BackgroundColor3 = Theme.Panel
Header.BorderSizePixel = 0
Header.Parent = Main
addCorner(Header, 13)

local Title = Instance.new("TextLabel")
Title.BackgroundTransparency = 1
Title.Position = UDim2.fromOffset(15, 8)
Title.Size = UDim2.new(1, -65, 0, 27)
Title.Font = Enum.Font.GothamBold
Title.Text = "DARK ICE"
Title.TextColor3 = Theme.Ice
Title.TextSize = 20
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Subtitle = Instance.new("TextLabel")
Subtitle.BackgroundTransparency = 1
Subtitle.Position = UDim2.fromOffset(16, 34)
Subtitle.Size = UDim2.new(1, -70, 0, 17)
Subtitle.Font = Enum.Font.Gotham
Subtitle.Text = "YBA  /  EXECUTOR BUILD  /  v1.1"
Subtitle.TextColor3 = Theme.Muted
Subtitle.TextSize = 10
Subtitle.TextXAlignment = Enum.TextXAlignment.Left
Subtitle.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Name = "Close"
CloseButton.Size = UDim2.fromOffset(34, 34)
CloseButton.Position = UDim2.new(1, -44, 0, 14)
CloseButton.BackgroundColor3 = Theme.Panel2
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Theme.Text
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 14
CloseButton.Parent = Header
addCorner(CloseButton, 8)

local Scroller = Instance.new("ScrollingFrame")
Scroller.Name = "Options"
Scroller.Position = UDim2.fromOffset(12, 74)
Scroller.Size = UDim2.new(1, -24, 1, -87)
Scroller.BackgroundTransparency = 1
Scroller.BorderSizePixel = 0
Scroller.ScrollBarThickness = 3
Scroller.ScrollBarImageColor3 = Theme.Ice
Scroller.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroller.CanvasSize = UDim2.new()
Scroller.Parent = Main

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 8)
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.Parent = Scroller

local Pad = Instance.new("UIPadding")
Pad.PaddingBottom = UDim.new(0, 7)
Pad.Parent = Scroller

local function newRow(height)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, -5, 0, height)
    row.BackgroundColor3 = Theme.Panel
    row.BorderSizePixel = 0
    row.Parent = Scroller
    addCorner(row, 9)
    return row
end

local function makeToggle(labelText, initial, callback)
    local row = newRow(45)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(12, 0)
    label.Size = UDim2.new(1, -82, 1, 0)
    label.Font = Enum.Font.GothamMedium
    label.Text = labelText
    label.TextColor3 = Theme.Text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local button = Instance.new("TextButton")
    button.Size = UDim2.fromOffset(49, 25)
    button.Position = UDim2.new(1, -61, 0.5, -12)
    button.BackgroundColor3 = initial and Theme.Ice or Theme.Panel2
    button.BorderSizePixel = 0
    button.Text = initial and "ON" or "OFF"
    button.TextColor3 = initial and Theme.Background or Theme.Text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 10
    button.Parent = row
    addCorner(button, 99)

    local enabled = initial == true
    local function update(value)
        enabled = value
        button.Text = enabled and "ON" or "OFF"
        button.TextColor3 = enabled and Theme.Background or Theme.Text
        TweenService:Create(button, TweenInfo.new(0.12), {
            BackgroundColor3 = enabled and Theme.Ice or Theme.Panel2
        }):Play()
        if callback then safeCall(callback, enabled) end
    end
    button.Activated:Connect(function() update(not enabled) end)
    return function() return enabled end, update
end

local function makeSlider(labelText, minValue, maxValue, defaultValue, callback)
    local row = newRow(68)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(12, 4)
    label.Size = UDim2.new(1, -74, 0, 22)
    label.Font = Enum.Font.GothamMedium
    label.Text = labelText
    label.TextColor3 = Theme.Text
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(1, -61, 0, 4)
    valueLabel.Size = UDim2.fromOffset(48, 22)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextColor3 = Theme.Ice
    valueLabel.TextSize = 12
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = row

    local track = Instance.new("TextButton")
    track.Name = "Track"
    track.AutoButtonColor = false
    track.Text = ""
    track.Position = UDim2.new(0, 12, 0, 43)
    track.Size = UDim2.new(1, -24, 0, 7)
    track.BackgroundColor3 = Theme.Panel2
    track.BorderSizePixel = 0
    track.Parent = row
    addCorner(track, 99)

    local ratio = (defaultValue - minValue) / (maxValue - minValue)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Ice
    fill.BorderSizePixel = 0
    fill.Parent = track
    addCorner(fill, 99)

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(ratio, 0, 0.5, 0)
    knob.Size = UDim2.fromOffset(13, 13)
    knob.BackgroundColor3 = Theme.Text
    knob.BorderSizePixel = 0
    knob.Parent = track
    addCorner(knob, 99)

    local dragging = false
    local value = defaultValue
    local function updateFromX(x)
        local width = math.max(track.AbsoluteSize.X, 1)
        local pct = math.clamp((x - track.AbsolutePosition.X) / width, 0, 1)
        value = math.floor(minValue + pct * (maxValue - minValue) + 0.5)
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, 0, 0.5, 0)
        valueLabel.Text = tostring(value)
        if callback then safeCall(callback, value) end
    end
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromX(input.Position.X)
        end
    end)
    Connections[#Connections + 1] = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromX(input.Position.X)
        end
    end)
    Connections[#Connections + 1] = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Drag the window by its title/header.
do
    local dragging, dragStart, startPosition
    Header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPosition = Main.Position
        end
    end)
    Connections[#Connections + 1] = UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X,
                startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
        end
    end)
    Connections[#Connections + 1] = UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- Speed: client-side WalkSpeed / jump values are reapplied while enabled.
local function setSpeed(enabled)
    State.speed = enabled
end

-- Noclip: remember collision values before changing them so toggling off can restore them.
local function setNoclip(enabled)
    State.noclip = enabled
    if not enabled then
        for part, oldValue in pairs(OriginalCollision) do
            if part and part.Parent then safeCall(function() part.CanCollide = oldValue end) end
        end
        table.clear(OriginalCollision)
    end
end

local function setHitbox(enabled)
    State.hitbox = enabled
    if not enabled then
        for part, original in pairs(OriginalHitboxes) do
            if part and part.Parent then
                safeCall(function()
                    part.Size = original.Size
                    part.Transparency = original.Transparency
                    part.CanCollide = original.CanCollide
                end)
            end
        end
        table.clear(OriginalHitboxes)
    end
end

local function removePlayerHighlight(player)
    local h = PlayerHighlights[player]
    if h then safeCall(function() h:Destroy() end) end
    PlayerHighlights[player] = nil
end

local function addPlayerHighlight(player)
    if player == LocalPlayer or not State.playerESP then return end
    local character = player.Character
    if not character or not character.Parent then return end
    local existing = PlayerHighlights[player]
    if existing and existing.Parent and existing.Adornee == character then return end
    removePlayerHighlight(player)
    local highlight = Instance.new("Highlight")
    highlight.Name = "DarkIcePlayerESP"
    highlight.Adornee = character
    highlight.FillColor = Theme.Red
    highlight.OutlineColor = Color3.fromRGB(255, 225, 225)
    highlight.FillTransparency = 0.55
    highlight.OutlineTransparency = 0.05
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    PlayerHighlights[player] = highlight
end

local function setPlayerESP(enabled)
    State.playerESP = enabled
    if enabled then
        for _, player in ipairs(Players:GetPlayers()) do safeCall(addPlayerHighlight, player) end
    else
        for player in pairs(PlayerHighlights) do removePlayerHighlight(player) end
    end
end

local function isItemName(name)
    local lower = string.lower(name or "")
    return lower:find("arrow", 1, true) ~= nil
        or lower:find("rokakaka", 1, true) ~= nil
        or lower:find("diary", 1, true) ~= nil
end

local function isCandidateItem(inst)
    if not inst or not inst.Parent or not isItemName(inst.Name) then return false end
    return inst:IsA("Model") or inst:IsA("Tool") or inst:IsA("BasePart")
end

local function itemPart(inst)
    if not inst then return nil end
    if inst:IsA("BasePart") then return inst end
    if inst:IsA("Tool") then
        return inst:FindFirstChild("Handle") or inst:FindFirstChildWhichIsA("BasePart", true)
    end
    if inst:IsA("Model") then
        return inst.PrimaryPart or inst:FindFirstChildWhichIsA("BasePart", true)
    end
    return nil
end

local function itemPosition(inst)
    local part = itemPart(inst)
    if part then return part.Position end
    return nil
end

local function removeItemVisual(inst)
    local visual = ItemVisuals[inst]
    if not visual then return end
    if visual.Highlight then safeCall(function() visual.Highlight:Destroy() end) end
    if visual.Billboard then safeCall(function() visual.Billboard:Destroy() end) end
    ItemVisuals[inst] = nil
end

local function addItemVisual(inst)
    if not State.itemESP or ItemVisuals[inst] or not isCandidateItem(inst) then return end
    local adornee = itemPart(inst)
    if not adornee then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "DarkIceItemESP"
    highlight.Adornee = inst
    highlight.FillColor = Theme.Green
    highlight.OutlineColor = Theme.Ice
    highlight.FillTransparency = 0.58
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = Workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "DarkIceItemLabel"
    billboard.Adornee = adornee
    billboard.Size = UDim2.fromOffset(180, 30)
    billboard.StudsOffset = Vector3.new(0, 2.4, 0)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Parent = PlayerGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.fromScale(1, 1)
    label.BackgroundColor3 = Theme.Background
    label.BackgroundTransparency = 0.18
    label.BorderSizePixel = 0
    label.Text = inst.Name
    label.TextColor3 = Theme.Green
    label.TextStrokeTransparency = 0.6
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = billboard
    addCorner(label, 6)

    ItemVisuals[inst] = { Highlight = highlight, Billboard = billboard }
end

local function collectItems()
    local found = {}
    for _, inst in ipairs(Workspace:GetDescendants()) do
        if isCandidateItem(inst) then
            -- Prefer the highest matching object in the item's own hierarchy to reduce duplicate labels.
            local parent = inst.Parent
            local nestedUnderCandidate = false
            while parent and parent ~= Workspace do
                if isCandidateItem(parent) then
                    nestedUnderCandidate = true
                    break
                end
                parent = parent.Parent
            end
            if not nestedUnderCandidate then found[#found + 1] = inst end
        end
    end
    return found
end

local function refreshItemESP()
    local found = collectItems()
    local present = {}
    for _, item in ipairs(found) do
        present[item] = true
        addItemVisual(item)
    end
    for item in pairs(ItemVisuals) do
        if not present[item] or not item.Parent then removeItemVisual(item) end
    end
end

local function setItemESP(enabled)
    State.itemESP = enabled
    if enabled then
        safeCall(refreshItemESP)
    else
        for item in pairs(ItemVisuals) do removeItemVisual(item) end
    end
end

local function tryPickup(item)
    if not item or not item.Parent then return false end
    local descendants = { item }
    for _, child in ipairs(item:GetDescendants()) do descendants[#descendants + 1] = child end

    -- Executor-provided interaction functions differ by executor/version.
    for _, inst in ipairs(descendants) do
        if inst:IsA("ClickDetector") and type(fireclickdetector) == "function" then
            local ok = pcall(fireclickdetector, inst)
            if ok then return true end
        elseif inst:IsA("ProximityPrompt") and type(fireproximityprompt) == "function" then
            local ok = pcall(fireproximityprompt, inst)
            if ok then return true end
        end
    end
    return false
end

local function setAutoPickup(enabled)
    State.autoPickup = enabled
    if not enabled and CurrentTween then
        safeCall(function() CurrentTween:Cancel() end)
        CurrentTween = nil
    end
end

-- Central Heartbeat loop: small work only, with all operations protected.
Connections[#Connections + 1] = RunService.Heartbeat:Connect(function()
    if State.destroyed then return end
    safeCall(function()
        local character = getCharacter()
        local humanoid = getHumanoid(character)
        if State.speed and humanoid and humanoid.Health > 0 then
            humanoid.WalkSpeed = State.speedValue
            humanoid.UseJumpPower = true
            humanoid.JumpPower = 50
        end

        if State.hitbox then
            for _, other in ipairs(Players:GetPlayers()) do
                if other ~= LocalPlayer then
                    local root = getRoot(other.Character)
                    if root and root:IsA("BasePart") then
                        if not OriginalHitboxes[root] then
                            OriginalHitboxes[root] = {
                                Size = root.Size,
                                Transparency = root.Transparency,
                                CanCollide = root.CanCollide,
                            }
                        end
                        root.Size = Vector3.new(10, 10, 10)
                        root.Transparency = 0.6
                        root.CanCollide = false
                    end
                end
            end
        end

        if State.noclip and character then
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if OriginalCollision[part] == nil then OriginalCollision[part] = part.CanCollide end
                    part.CanCollide = false
                end
            end
        end
    end)
end)

Connections[#Connections + 1] = RunService.Stepped:Connect(function()
    if not State.noclip or State.destroyed then return end
    safeCall(function()
        local character = getCharacter()
        if not character then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                if OriginalCollision[part] == nil then OriginalCollision[part] = part.CanCollide end
                part.CanCollide = false
            end
        end
    end)
end)

-- Refresh player ESP as players respawn/join/leave.
Connections[#Connections + 1] = Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.75)
        if State.playerESP then safeCall(addPlayerHighlight, player) end
    end)
end)
Connections[#Connections + 1] = Players.PlayerRemoving:Connect(function(player)
    removePlayerHighlight(player)
end)
for _, player in ipairs(Players:GetPlayers()) do
    player.CharacterAdded:Connect(function()
        task.wait(0.75)
        if State.playerESP then safeCall(addPlayerHighlight, player) end
    end)
end

-- Background item scanner, enabled only while Item ESP is on.
task.spawn(function()
    while not State.destroyed do
        if State.itemESP then safeCall(refreshItemESP) end
        task.wait(1.25)
    end
end)

-- Auto-tween to nearest eligible item and try the available interaction API.
task.spawn(function()
    while not State.destroyed do
        if State.autoPickup and not BusyPickup then
            safeCall(function()
                local root = getRoot()
                local humanoid = getHumanoid()
                if not root or not humanoid or humanoid.Health <= 0 then return end

                local nearest, nearestDistance
                for _, item in ipairs(collectItems()) do
                    local pos = itemPosition(item)
                    if pos then
                        local distance = (root.Position - pos).Magnitude
                        if not nearestDistance or distance < nearestDistance then
                            nearest, nearestDistance = item, distance
                        end
                    end
                end

                if nearest and nearestDistance then
                    BusyPickup = true
                    if nearestDistance > 7 then
                        local pos = itemPosition(nearest)
                        if pos then
                            local destination = CFrame.new(pos + Vector3.new(0, 3, 0))
                            local duration = math.max(nearestDistance / math.max(State.itemTweenSpeed, 1), 0.08)
                            CurrentTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
                                CFrame = destination
                            })
                            CurrentTween:Play()
                            local playbackState = CurrentTween.Completed:Wait()
                            CurrentTween = nil
                            if not State.autoPickup then BusyPickup = false; return end
                            if playbackState == Enum.PlaybackState.Completed then
                                task.wait(0.15)
                                tryPickup(nearest)
                            end
                        end
                    else
                        tryPickup(nearest)
                        task.wait(0.25)
                    end
                    BusyPickup = false
                end
            end)
            BusyPickup = false
        end
        task.wait(0.15)
    end
end)

-- UI callbacks are connected after handlers are defined.
makeToggle("Speed Hack (WalkSpeed + Jump)", false, setSpeed)
makeSlider("WalkSpeed", 16, 100, State.speedValue, function(value)
    State.speedValue = value
end)
makeToggle("Noclip", false, setNoclip)
makeToggle("Hitbox Expander (10 studs)", false, setHitbox)
makeToggle("Player ESP (Red / Through Walls)", false, setPlayerESP)
makeToggle("Item ESP (Ice Labels)", false, setItemESP)
makeToggle("Auto Tween + Pickup", false, setAutoPickup)
makeSlider("Item Tween Speed (studs/s)", 25, 300, State.itemTweenSpeed, function(value)
    State.itemTweenSpeed = value
end)

CloseButton.Activated:Connect(function()
    State.visible = false
    Main.Visible = false
end)

Connections[#Connections + 1] = UserInputService.InputBegan:Connect(function(input, processed)
    if processed or State.destroyed then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        State.visible = not State.visible
        Main.Visible = State.visible
    end
end)

-- Cleanup if the GUI is manually removed.
Gui.AncestryChanged:Connect(function(_, parent)
    if parent == nil and not State.destroyed then
        State.destroyed = true
        if CurrentTween then safeCall(function() CurrentTween:Cancel() end) end
        for _, connection in ipairs(Connections) do safeCall(function() connection:Disconnect() end) end
        for player in pairs(PlayerHighlights) do removePlayerHighlight(player) end
        for item in pairs(ItemVisuals) do removeItemVisual(item) end
        setNoclip(false)
        setHitbox(false)
    end
end)

print("[Dark Ice] UI created in " .. GuiParent:GetFullName() .. ". RightShift toggles the UI.")

end -- bootDarkIce

local ok, err = xpcall(bootDarkIce, function(message)
    local trace = (debug and debug.traceback) and debug.traceback(tostring(message), 2) or tostring(message)
    return trace
end)
if not ok then
    warn("[Dark Ice] Startup failed: " .. tostring(err))

    -- Try to show the failure on-screen instead of silently leaving no UI.
    pcall(function()
        local Players = game:GetService("Players")
        local player = Players.LocalPlayer
        local target
        if type(gethui) == "function" then
            local good, result = pcall(gethui)
            if good and typeof(result) == "Instance" then target = result end
        end
        if not target and player then target = player:FindFirstChildOfClass("PlayerGui") end
        if not target then target = game:GetService("CoreGui") end
        local old = target:FindFirstChild("DarkIceError")
        if old then old:Destroy() end

        local screen = Instance.new("ScreenGui")
        screen.Name = "DarkIceError"
        screen.ResetOnSpawn = false
        screen.DisplayOrder = 100001
        screen.IgnoreGuiInset = true
        screen.Parent = target

        local panel = Instance.new("Frame")
        panel.AnchorPoint = Vector2.new(0.5, 0.5)
        panel.Position = UDim2.fromScale(0.5, 0.5)
        panel.Size = UDim2.fromOffset(430, 150)
        panel.BackgroundColor3 = Color3.fromRGB(18, 24, 37)
        panel.BorderSizePixel = 0
        panel.Parent = screen
        Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 10)
        local stroke = Instance.new("UIStroke", panel)
        stroke.Color = Color3.fromRGB(255, 100, 110)
        stroke.Thickness = 1.5

        local title = Instance.new("TextLabel")
        title.BackgroundTransparency = 1
        title.Position = UDim2.fromOffset(14, 10)
        title.Size = UDim2.new(1, -28, 0, 28)
        title.Font = Enum.Font.GothamBold
        title.Text = "DARK ICE — STARTUP ERROR"
        title.TextColor3 = Color3.fromRGB(255, 115, 125)
        title.TextSize = 15
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = panel

        local message = Instance.new("TextLabel")
        message.BackgroundTransparency = 1
        message.Position = UDim2.fromOffset(14, 42)
        message.Size = UDim2.new(1, -28, 1, -52)
        message.Font = Enum.Font.Code
        message.Text = string.sub(tostring(err), 1, 650)
        message.TextColor3 = Color3.fromRGB(225, 238, 252)
        message.TextSize = 11
        message.TextWrapped = true
        message.TextXAlignment = Enum.TextXAlignment.Left
        message.TextYAlignment = Enum.TextYAlignment.Top
        message.Parent = panel
    end)
end
