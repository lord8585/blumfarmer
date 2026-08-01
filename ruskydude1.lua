-- Cleanup previous instances
for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do 
    if v.Name == "SvoGui_V17" then v:Destroy() end 
end

-- Services
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local NpcBtn = Instance.new("TextButton")
local NameBtn = Instance.new("TextButton")
local TracerBtn = Instance.new("TextButton")
local FbBtn = Instance.new("TextButton")
local FogBtn = Instance.new("TextButton")
local AimBtn = Instance.new("TextButton")
local AimFovBtn = Instance.new("TextButton")
local UnloadBtn = Instance.new("TextButton")
local ToggleWindowBtn = Instance.new("TextButton")

ScreenGui.Name = "SvoGui_V17"
ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ResetOnSpawn = false

ToggleWindowBtn.Parent = ScreenGui
ToggleWindowBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
ToggleWindowBtn.Size = UDim2.new(0, 35, 0, 35)
ToggleWindowBtn.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
ToggleWindowBtn.BorderSizePixel = 1
ToggleWindowBtn.BorderColor3 = Color3.fromRGB(90, 90, 90)
ToggleWindowBtn.Text = "S"
ToggleWindowBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleWindowBtn.Font = Enum.Font.Code
ToggleWindowBtn.Active = true
ToggleWindowBtn.Draggable = true

MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(50, 50, 50)
MainFrame.Position = UDim2.new(0.02, 0, 0.26, 0)
MainFrame.Size = UDim2.new(0, 185, 0, 410)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0.07, 0)
Title.BackgroundTransparency = 1
Title.Text = "svocheats v17"
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.TextSize = 13
Title.Font = Enum.Font.Code

local function makeBtn(btn, text, pos, color)
    btn.Parent = MainFrame
    btn.Position = pos
    btn.Size = UDim2.new(0.9, 0, 0.07, 0)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Code
end

makeBtn(ToggleBtn, "Players Chams: OFF", UDim2.new(0.05, 0, 0.08, 0), Color3.fromRGB(140, 30, 30))
makeBtn(NpcBtn, "NPC Chams: OFF", UDim2.new(0.05, 0, 0.16, 0), Color3.fromRGB(140, 30, 30))
makeBtn(NameBtn, "Name ESP: OFF", UDim2.new(0.05, 0, 0.24, 0), Color3.fromRGB(140, 30, 30))
makeBtn(TracerBtn, "Tracers: OFF", UDim2.new(0.05, 0, 0.32, 0), Color3.fromRGB(140, 30, 30))
makeBtn(FbBtn, "Fullbright: OFF", UDim2.new(0.05, 0, 0.40, 0), Color3.fromRGB(140, 30, 30))
makeBtn(FogBtn, "No Fog: OFF", UDim2.new(0.05, 0, 0.48, 0), Color3.fromRGB(140, 30, 30))
makeBtn(AimBtn, "Aimbot Head: OFF", UDim2.new(0.05, 0, 0.56, 0), Color3.fromRGB(140, 30, 30))
makeBtn(AimFovBtn, "Aim FOV: 60px", UDim2.new(0.05, 0, 0.64, 0), Color3.fromRGB(40, 40, 40))
makeBtn(UnloadBtn, "UNLOAD", UDim2.new(0.05, 0, 0.72, 0), Color3.fromRGB(45, 45, 50))

ToggleWindowBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- State Variables
local WH_Active, NPC_Active, Name_Active, Tracers_Active, FB_Active, Fog_Active, AIM_Active = false, false, false, false, false, false, false
local fovValues = {60, 120, 200}
local fovIdx = 1
local ScriptRunning = true
local AimKey = Enum.UserInputType.MouseButton2
local IsAimKeyDown = false

-- Original Lighting Cache
local origAmbient, origColorShift, origGlobalShadows, origTime = Lighting.Ambient, Lighting.ColorShift_Top, Lighting.GlobalShadows, Lighting.ClockTime
local origFogStart, origFogEnd = Lighting.FogStart, Lighting.FogEnd
local atmCache = {}
for _, v in ipairs(Lighting:GetChildren()) do
    if v:IsA("Atmosphere") then
        atmCache[v] = {Density = v.Density, Offset = v.Offset}
    end
end

-- Target Caching
local cachedPlrs, cachedNpcs = {}, {}
local chamCache = {}

-- Optimization: Reuse RaycastParams to prevent memory leaks and lag
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Exclude

local function isVisible(model)
    local head = model:FindFirstChild("Head")
    if not head or not LocalPlayer.Character then return false end
    
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character, model, Camera}
    
    local origin = Camera.CFrame.Position
    local hit = workspace:Raycast(origin, (head.Position - origin), raycastParams)
    return not hit
end

local function checkAndCacheModel(model)
    if not model:IsA("Model") or chamCache[model] then return end
    if not model:FindFirstChildOfClass("Humanoid") then return end
    
    local p = Players:GetPlayerFromCharacter(model)
    if p then
        if p ~= LocalPlayer then cachedPlrs[model] = true end
    else
        cachedNpcs[model] = true
    end
end

-- Initial Scan
for _, v in ipairs(workspace:GetDescendants()) do
    checkAndCacheModel(v)
end

-- Event Listeners for dynamic caching
workspace.DescendantAdded:Connect(checkAndCacheModel)

workspace.DescendantRemoving:Connect(function(obj)
    cachedPlrs[obj] = nil
    cachedNpcs[obj] = nil
    if chamCache[obj] then
        chamCache[obj]:Destroy()
        chamCache[obj] = nil
    end
end)

-- Chams Logic
local function drawChams(model, name, defaultColor)
    if not model then return end
    local highlight = chamCache[model]
    
    if not highlight then
        highlight = Instance.new("Highlight")
        highlight.Name = name
        highlight.FillTransparency = 0.3
        highlight.OutlineTransparency = 1
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = model
        chamCache[model] = highlight
        highlight.FillColor = defaultColor
    end
end

-- Input Handling
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.UserInputType == AimKey or input.KeyCode == AimKey then
        IsAimKeyDown = true
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AimKey or input.KeyCode == AimKey then
        IsAimKeyDown = false
    end
end)

-- Tracer & Name Pools
local TracerPool = {}
local NamePool = {}
local MAX_DRAWINGS = 100

for i = 1, MAX_DRAWINGS do
    local line = Drawing.new("Line")
    line.Visible = false
    line.Color = Color3.fromRGB(255, 255, 255)
    line.Thickness = 1
    line.Transparency = 1
    TracerPool[i] = line
    
    local txt = Drawing.new("Text")
    txt.Visible = false
    txt.Color = Color3.fromRGB(255, 255, 255)
    txt.Center = true
    txt.Outline = true
    txt.Size = 13
    txt.Font = 2
    NamePool[i] = txt
end

-- Untouched Aimbot Logic
local function doAimbot()
    if not AIM_Active or not IsAimKeyDown then return end
    local maxDist = fovValues[fovIdx]
    local closestHeadPart = nil
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    local function check(char)
        local head = char:FindFirstChild("Head")
        local hum = char:FindFirstChildOfClass("Humanoid")
        if head and hum and hum.Health > 0 then
            local sPos, onScreen = Camera:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(sPos.X, sPos.Y) - center).Magnitude
                if dist < maxDist then
                    maxDist = dist
                    closestHeadPart = head
                end
            end
        end
    end
    
    for c in pairs(cachedPlrs) do check(c) end
    for c in pairs(cachedNpcs) do check(c) end
    
    if closestHeadPart then
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closestHeadPart.Position), 0.2)
    end
end

-- Main Render Loop
RunService.RenderStepped:Connect(function()
    if not ScriptRunning then return end
    
    doAimbot()
    
    local drawIdx = 1
    
    if Tracers_Active or Name_Active or WH_Active or NPC_Active then
        local start = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
        local function processEntity(char, isPlayer)
            local root = char:FindFirstChild("HumanoidRootPart")
            local head = char:FindFirstChild("Head")
            
            if root and head then
                local sPos, onScreen = Camera:WorldToViewportPoint(root.Position)
                
                if onScreen then
                    local visible = isVisible(char)
                    local color = visible and Color3.fromRGB(0, 255, 0) or (isPlayer and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 120, 255))
                    
                    if (isPlayer and WH_Active) or (not isPlayer and NPC_Active) then
                        local hl = chamCache[char]
                        if hl then hl.FillColor = color end
                    end
                    
                    if (Tracers_Active or Name_Active) and drawIdx <= MAX_DRAWINGS then
                        if Tracers_Active then
                            local line = TracerPool[drawIdx]
                            line.Visible = true
                            line.From = start
                            line.To = Vector2.new(sPos.X, sPos.Y)
                            line.Color = color
                        end
                        
                        if Name_Active then
                            local hPos = Camera:WorldToViewportPoint(head.Position)
                            local txt = NamePool[drawIdx]
                            txt.Visible = true
                            txt.Text = char.Name
                            txt.Position = Vector2.new(hPos.X, hPos.Y - 15)
                            txt.Color = color
                        end
                        drawIdx = drawIdx + 1
                    end
                end
            end
        end
        
        for c in pairs(cachedPlrs) do processEntity(c, true) end
        for c in pairs(cachedNpcs) do processEntity(c, false) end
    end
    
    for i = drawIdx, MAX_DRAWINGS do
        if TracerPool[i].Visible then TracerPool[i].Visible = false end
        if NamePool[i].Visible then NamePool[i].Visible = false end
    end
end)

-- Background Chams Loop
task.spawn(function()
    while task.wait(0.6) do
        if not ScriptRunning then break end
        
        if WH_Active then
            for c in pairs(cachedPlrs) do
                drawChams(c, "PChams", Color3.fromRGB(255, 0, 0))
            end
        end
        
        if NPC_Active then
            for c in pairs(cachedNpcs) do
                drawChams(c, "NChams", Color3.fromRGB(0, 120, 255))
            end
        end
    end
end)

-- UI Toggles
ToggleBtn.MouseButton1Click:Connect(function()
    WH_Active = not WH_Active
    if WH_Active then
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        ToggleBtn.Text = "Players Chams: ON"
    else
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
        ToggleBtn.Text = "Players Chams: OFF"
        for model, hl in pairs(chamCache) do
            if cachedPlrs[model] then hl:Destroy() chamCache[model] = nil end
        end
    end
end)

NpcBtn.MouseButton1Click:Connect(function()
    NPC_Active = not NPC_Active
    if NPC_Active then
        NpcBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        NpcBtn.Text = "NPC Chams: ON"
    else
        NpcBtn.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
        NpcBtn.Text = "NPC Chams: OFF"
        for model, hl in pairs(chamCache) do
            if cachedNpcs[model] then hl:Destroy() chamCache[model] = nil end
        end
    end
end)

NameBtn.MouseButton1Click:Connect(function()
    Name_Active = not Name_Active
    if Name_Active then
        NameBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        NameBtn.Text = "Name ESP: ON"
    else
        NameBtn.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
        NameBtn.Text = "Name ESP: OFF"
        for i = 1, MAX_DRAWINGS do NamePool[i].Visible = false end
    end
end)

TracerBtn.MouseButton1Click:Connect(function()
    Tracers_Active = not Tracers_Active
    if Tracers_Active then
        TracerBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        TracerBtn.Text = "Tracers: ON"
    else
        TracerBtn.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
        TracerBtn.Text = "Tracers: OFF"
        for i = 1, MAX_DRAWINGS do TracerPool[i].Visible = false end
    end
end)

FbBtn.MouseButton1Click:Connect(function()
    FB_Active = not FB_Active
    if FB_Active then
        FbBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        FbBtn.Text = "Fullbright: ON"
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.ColorShift_Top = Color3.fromRGB(255, 255, 255)
        Lighting.GlobalShadows = false
        Lighting.ClockTime = 12
    else
        FbBtn.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
        FbBtn.Text = "Fullbright: OFF"
        Lighting.Ambient = origAmbient
        Lighting.ColorShift_Top = origColorShift
        Lighting.GlobalShadows = origGlobalShadows
        Lighting.ClockTime = origTime
    end
end)

FogBtn.MouseButton1Click:Connect(function()
    Fog_Active = not Fog_Active
    if Fog_Active then
        FogBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        FogBtn.Text = "No Fog: ON"
        Lighting.FogStart = 0
        Lighting.FogEnd = 9e9
        for atm in pairs(atmCache) do
            pcall(function() atm.Density = 0 atm.Offset = 0 end)
        end
    else
        FogBtn.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
        FogBtn.Text = "No Fog: OFF"
        Lighting.FogStart = origFogStart
        Lighting.FogEnd = origFogEnd
        for atm, data in pairs(atmCache) do
            pcall(function() atm.Density = data.Density atm.Offset = data.Offset end)
        end
    end
end)

AimBtn.MouseButton1Click:Connect(function()
    AIM_Active = not AIM_Active
    if AIM_Active then
        AimBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        AimBtn.Text = "Aimbot Head: ON"
    else
        AimBtn.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
        AimBtn.Text = "Aimbot Head: OFF"
    end
end)

AimFovBtn.MouseButton1Click:Connect(function()
    fovIdx = fovIdx + 1
    if fovIdx > #fovValues then fovIdx = 1 end
    AimFovBtn.Text = "Aim FOV: " .. fovValues[fovIdx] .. "px"
end)

UnloadBtn.MouseButton1Click:Connect(function()
    ScriptRunning = false
    
    for i = 1, MAX_DRAWINGS do
        if TracerPool[i] then TracerPool[i]:Remove() end
        if NamePool[i] then NamePool[i]:Remove() end
    end
    
    Lighting.Ambient = origAmbient
    Lighting.ColorShift_Top = origColorShift
    Lighting.GlobalShadows = origGlobalShadows
    Lighting.ClockTime = origTime
    Lighting.FogStart = origFogStart
    Lighting.FogEnd = origFogEnd
    for atm, data in pairs(atmCache) do
        pcall(function() atm.Density = data.Density atm.Offset = data.Offset end)
    end
    
    for _, hl in pairs(chamCache) do
        if hl then hl:Destroy() end
    end
    
    ScreenGui:Destroy()
end)
