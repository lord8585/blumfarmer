local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local SafeGui = LocalPlayer:WaitForChild("PlayerGui")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")

local ESP_Cache = {}
local Thickness = 0.35

local MaxDistanceESP = 2000

local COLOR_ENEMY_HEAD = Color3.fromRGB(255, 0, 0)
local COLOR_TEAM_HEAD = Color3.fromRGB(0, 255, 0)
local COLOR_BOT_HEAD = Color3.fromRGB(0, 100, 255)
local COLOR_DEAD_BODY = Color3.fromRGB(255, 0, 150)

local BIND_CORPSES = Enum.KeyCode.H
local BIND_NVG = Enum.KeyCode.X

local COLOR_HEAD = Color3.fromRGB(255, 0, 0)
local COLOR_BODY = Color3.fromRGB(255, 165, 0)
local DOT_SIZE = UDim2.new(0, 8, 0, 8)

local espEnabled = false
local nvgEnabled = false

local allCorpses = {}
local activeVisuals = {}

local defaultLighting = {
    Ambient = Lighting.Ambient,
    OutdoorAmbient = Lighting.OutdoorAmbient,
    Brightness = Lighting.Brightness,
    ClockTime = Lighting.ClockTime
}

local function GetRandomName()
    return "UI_Asset_" .. tostring(math.random(1000, 9999))
end

local function GetEntityData(model)
    local player = Players:GetPlayerFromCharacter(model)
    if player then
        if player == LocalPlayer then return nil, nil end
        if player.Team and LocalPlayer.Team and player.Team == LocalPlayer.Team then
            return COLOR_TEAM_HEAD, "[TEAM] " .. player.Name
        else
            return COLOR_ENEMY_HEAD, player.Name
        end
    else
        if model:FindFirstChild("Humanoid") and model.Name ~= "HumanoidRootPart" then
            return COLOR_BOT_HEAD, "[BOT] " .. model.Name
        end
        return nil, nil
    end
end

local function CreateESP(model, headColor, displayName)
    if ESP_Cache[model] then return end
    local head = model:FindFirstChild("Head")
    local root = model:FindFirstChild("HumanoidRootPart")
    local hum = model:FindFirstChild("Humanoid")
    local torso = model:FindFirstChild("Torso") or model:FindFirstChild("UpperTorso")
    if not head or not root or not hum then return end

    local container = Instance.new("Folder")
    container.Name = GetRandomName()
    container.Parent = SafeGui

    local bg = Instance.new("BillboardGui")
    bg.Adornee = head
    bg.Size = UDim2.new(6, 0, 2, 0)
    bg.AlwaysOnTop = true
    bg.MaxDistance = MaxDistanceESP
    bg.ExtentsOffsetWorldSpace = Vector3.new(0, 2.5, 0)
    bg.Parent = container

    local txt = Instance.new("TextLabel")
    txt.Text = displayName
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.TextColor3 = Color3.fromRGB(255, 255, 255)
    txt.TextStrokeTransparency = 0
    txt.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    txt.TextScaled = true
    txt.Font = Enum.Font.SourceSansBold
    txt.Parent = bg

    local headBg = Instance.new("BillboardGui")
    headBg.Adornee = head
    headBg.Size = UDim2.new(1.4, 0, 1.4, 0)
    headBg.AlwaysOnTop = true
    headBg.MaxDistance = MaxDistanceESP
    headBg.Parent = container

    local headDot = Instance.new("Frame")
    headDot.Size = UDim2.new(1, 0, 1, 0)
    headDot.BackgroundColor3 = headColor
    headDot.BorderSizePixel = 0
    headDot.Parent = headBg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = headDot

    local skeletonParts = {}
    if torso then
        local spine = Instance.new("BoxHandleAdornment")
        spine.Adornee = torso
        spine.AlwaysOnTop = true
        spine.ZIndex = 10
        spine.Size = Vector3.new(Thickness * 1.5, torso.Size.Y * 1.4, Thickness * 1.5)
        spine.Transparency = 0.1
        spine.Color = BrickColor.new(headColor)
        spine.Parent = container
        table.insert(skeletonParts, spine)
    end

    for _, part in pairs(model:GetChildren()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Head" and part.Name ~= "Torso" and part.Name ~= "UpperTorso" then
            local bone = Instance.new("BoxHandleAdornment")
            bone.Adornee = part
            bone.AlwaysOnTop = true
            bone.ZIndex = 10
            bone.Size = Vector3.new(Thickness, part.Size.Y * 1.05, Thickness)
            bone.Transparency = 0.1
            bone.Color = BrickColor.new(headColor)
            bone.Parent = container
            table.insert(skeletonParts, bone)
        end
    end

    ESP_Cache[model] = {
        Folder = container,
        Root = root,
        Head = head,
        Humanoid = hum,
        TextLabel = txt,
        HeadDotContainer = headBg,
        Bones = skeletonParts,
        Color = headColor,
        DisplayName = displayName,
        IsDead = false
    }
end

local function ConvertToDeadBody(data)
    data.IsDead = true
    data.DisplayName = "[DEAD BODY]"
    data.TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)

    if data.HeadDotContainer then pcall(function() data.HeadDotContainer:Destroy() end) end
    for _, bone in pairs(data.Bones) do pcall(function() bone:Destroy() end) end
    data.Bones = {}

    if data.Root then
        local deadBox = Instance.new("BoxHandleAdornment")
        deadBox.Adornee = data.Root
        deadBox.AlwaysOnTop = true
        deadBox.ZIndex = 9
        deadBox.Size = Vector3.new(3.5, 3.5, 3.5)
        deadBox.Transparency = 0.4
        deadBox.Color = BrickColor.new(COLOR_DEAD_BODY)
        deadBox.Parent = data.Folder
        table.insert(data.Bones, deadBox)
    end
end

local function ProcessEntity(model, headColor, displayName)
    pcall(function()
        local hum = model:FindFirstChild("Humanoid")
        local root = model:FindFirstChild("HumanoidRootPart")
        if not hum or not root then return end

        local data = ESP_Cache[model]
        if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then return end
        local distance = math.round((LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude)

        if distance > MaxDistanceESP then
            if data then data.Folder:Destroy() ESP_Cache[model] = nil end
            return
        end

        if hum.Health > 0 then
            if not data then
                CreateESP(model, headColor, displayName)
            else
                if data.IsDead then return end
                data.TextLabel.Text = data.DisplayName .. " [" .. tostring(distance) .. "m]"
            end
        else
            if data and not data.IsDead then ConvertToDeadBody(data) end
            if data then data.TextLabel.Text = "[DEAD BODY] [" .. tostring(distance) .. "m]" end
        end
    end)
end

local function ScanEntities()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then
            local headColor, displayName = GetEntityData(p.Character)
            if headColor then ProcessEntity(p.Character, headColor, displayName) end
        end
    end
    for _, obj in pairs(Workspace:GetChildren()) do
        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
            ProcessEntity(obj, COLOR_BOT_HEAD, "[BOT] " .. obj.Name)
        end
    end
end

Workspace.DescendantRemoving:Connect(function(obj)
    if ESP_Cache[obj] then
        pcall(function() ESP_Cache[obj].Folder:Destroy() end)
        ESP_Cache[obj] = nil
    end
end)

task.spawn(function()
    while task.wait(0.12) do
        ScanEntities()
    end
end)

local function isCorpse(obj)
    if not obj or not obj:IsA("Model") then return false end
    if obj.Name == "DeadBody" or obj.Name == "Corpse" then return true end
    local hum = obj:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health == 0 then return true end
    return false
end

local function createJointDot(part, color)
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "SkeletonDot"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 40, 0, 40)
    billboard.Adornee = part
    billboard.Parent = CoreGui

    local dot = Instance.new("Frame")
    dot.Size = DOT_SIZE
    dot.Position = UDim2.new(0.5, -DOT_SIZE.X.Offset/2, 0.5, -DOT_SIZE.Y.Offset/2)
    dot.BackgroundColor3 = color
    dot.BorderSizePixel = 0
    dot.Parent = billboard

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = dot

    return billboard
end

local function buildSkeleton(corpse)
    if not espEnabled or activeVisuals[corpse] then return end
    
    local partsToTrack = {
        {"Head", COLOR_HEAD},
        {"HumanoidRootPart", COLOR_BODY},
        {"Torso", COLOR_BODY},
        {"UpperTorso", COLOR_BODY},
        {"Left Arm", COLOR_BODY},
        {"Right Arm", COLOR_BODY},
        {"Left Leg", COLOR_BODY},
        {"Right Leg", COLOR_BODY}
    }
    
    local corpseDots = {}
    
    for _, info in pairs(partsToTrack) do
        local partName = info[1]
        local partColor = info[2]
        local part = corpse:FindFirstChild(partName)
        
        if part and part:IsA("BasePart") then
            local dot = createJointDot(part, partColor)
            table.insert(corpseDots, dot)
        end
    end
    
    if #corpseDots > 0 then
        activeVisuals[corpse] = corpseDots
    end
end

local function enableESP()
    espEnabled = true
    for obj, _ in pairs(allCorpses) do
        if obj and obj.Parent then
            buildSkeleton(obj)
        else
            allCorpses[obj] = nil
        end
    end
end

local function disableESP()
    espEnabled = false
    for obj, dots in pairs(activeVisuals) do
        for _, dot in pairs(dots) do
            if dot then dot:Destroy() end
        end
    end
    activeVisuals = {}
end

Workspace.DescendantAdded:Connect(function(descendant)
    task.wait(0.5)
    if isCorpse(descendant) then
        allCorpses[descendant] = true
        if espEnabled then
            buildSkeleton(descendant)
        end
    end
end)

task.spawn(function()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if isCorpse(obj) then
            allCorpses[obj] = true
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    if input.KeyCode == BIND_CORPSES then
        if espEnabled then
            disableESP()
            print("Corpse Skeletons: DISABLED")
        else
            enableESP()
            print("Corpse Skeletons: ENABLED")
        end
    end

    if input.KeyCode == BIND_NVG then
        nvgEnabled = not nvgEnabled
        if nvgEnabled then
            Lighting.Ambient = Color3.fromRGB(180, 255, 180)
            Lighting.OutdoorAmbient = Color3.fromRGB(150, 200, 150)
            Lighting.Brightness = 3.5
            Lighting.ClockTime = 14
            print("Night Vision: ENABLED")
        else
            Lighting.Ambient = defaultLighting.Ambient
            Lighting.OutdoorAmbient = defaultLighting.OutdoorAmbient
            Lighting.Brightness = defaultLighting.Brightness
            Lighting.ClockTime = defaultLighting.ClockTime
            print("Night Vision: DISABLED")
        end
    end
end)
