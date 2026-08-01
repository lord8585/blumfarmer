for _, v in ipairs(game:GetService("CoreGui"):GetChildren()) do 
    if v.Name == "SvoGui_V17" then v:Destroy() end 
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local ToggleBtn = Instance.new("TextButton")
local NpcBtn = Instance.new("TextButton")
local NameBtn = Instance.new("TextButton")
local TracerBtn = Instance.new("TextButton")
local DistBtn = Instance.new("TextButton")
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
MainFrame.Size = UDim2.new(0, 185, 0, 470)
MainFrame.Visible = false
MainFrame.Active = true
MainFrame.Draggable = true

Title.Parent = MainFrame
Title.Size = UDim2.new(1, 0, 0.06, 0)
Title.BackgroundTransparency = 1
Title.Text = "svocheats v17"
Title.TextColor3 = Color3.fromRGB(230, 230, 230)
Title.TextSize = 13
Title.Font = Enum.Font.Code

local function makeBtn(btn, text, pos, color)
    btn.Parent = MainFrame
    btn.Position = pos
    btn.Size = UDim2.new(0.9, 0, 0.06, 0)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 1
    btn.BorderColor3 = Color3.fromRGB(0, 0, 0)
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Code
end

makeBtn(ToggleBtn, "Players Chams: OFF", UDim2.new(0.05, 0, 0.07, 0), Color3.fromRGB(140, 30, 30))
makeBtn(NpcBtn, "NPC Chams: OFF", UDim2.new(0.05, 0, 0.14, 0), Color3.fromRGB(140, 30, 30))
makeBtn(NameBtn, "Name ESP: OFF", UDim2.new(0.05, 0, 0.21, 0), Color3.fromRGB(140, 30, 30))
makeBtn(TracerBtn, "Tracers: OFF", UDim2.new(0.05, 0, 0.28, 0), Color3.fromRGB(140, 30, 30))
makeBtn(DistBtn, "Distance: OFF", UDim2.new(0.05, 0, 0.35, 0), Color3.fromRGB(140, 30, 30))
makeBtn(FbBtn, "Fullbright: OFF", UDim2.new(0.05, 0, 0.42, 0), Color3.fromRGB(140, 30, 30))
makeBtn(FogBtn, "No Fog: OFF", UDim2.new(0.05, 0, 0.49, 0), Color3.fromRGB(140, 30, 30))
makeBtn(AimBtn, "Aimbot Head: OFF", UDim2.new(0.05, 0, 0.56, 0), Color3.fromRGB(140, 30, 30))
makeBtn(AimFovBtn, "Aim FOV: 60px", UDim2.new(0.05, 0, 0.63, 0), Color3.fromRGB(40, 40, 40))

local SmoothLabel = Instance.new("TextLabel")
SmoothLabel.Parent = MainFrame
SmoothLabel.Size = UDim2.new(0.9, 0, 0.04, 0)
SmoothLabel.Position = UDim2.new(0.05, 0, 0.70, 0)
SmoothLabel.BackgroundTransparency = 1
SmoothLabel.Text = "Smoothness: 20"
SmoothLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SmoothLabel.Font = Enum.Font.Code
SmoothLabel.TextSize = 11

local SmoothBar = Instance.new("Frame")
SmoothBar.Parent = MainFrame
SmoothBar.Size = UDim2.new(0.9, 0, 0.02, 0)
SmoothBar.Position = UDim2.new(0.05, 0, 0.74, 0)
SmoothBar.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
SmoothBar.BorderSizePixel = 0

local SmoothFill = Instance.new("Frame")
SmoothFill.Parent = SmoothBar
SmoothFill.Size = UDim2.new(0.2, 0, 1, 0)
SmoothFill.BackgroundColor3 = Color3.fromRGB(114, 47, 240)
SmoothFill.BorderSizePixel = 0

local SmoothKnob = Instance.new("TextButton")
SmoothKnob.Parent = SmoothBar
SmoothKnob.Size = UDim2.new(0, 8, 0, 14)
SmoothKnob.Position = UDim2.new(0.2, -4, 0.5, -7)
SmoothKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SmoothKnob.BorderSizePixel = 0
SmoothKnob.Text = ""

makeBtn(UnloadBtn, "UNLOAD", UDim2.new(0.05, 0, 0.79, 0), Color3.fromRGB(45, 45, 50))

ToggleWindowBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

UserInputService.InputBegan:Connect(function(i)
    if i.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

local WH_Active, NPC_Active, Name_Active, Tracers_Active, Dist_Active, FB_Active, Fog_Active, AIM_Active = false, false, false, false, false, false, false, false
local fovValues = {60, 120, 200}
local fovIdx = 1
local ScriptRunning = true
local AimKey = Enum.UserInputType.MouseButton2
local IsAimKeyDown = false
local Smoothness = 20
local draggingSmooth = false

SmoothKnob.MouseButton1Down:Connect(function()
    draggingSmooth = true
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSmooth = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSmooth and input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local barPos = SmoothBar.AbsolutePosition
        local barSize = SmoothBar.AbsoluteSize
        
        local percent = math.clamp((mousePos.X - barPos.X) / barSize.X, 0, 1)
        Smoothness = math.floor(percent * 100)
        
        SmoothFill.Size = UDim2.new(percent, 0, 1, 0)
        SmoothKnob.Position = UDim2.new(percent, -4, 0.5, -7)
        SmoothLabel.Text = "Smoothness: " .. Smoothness
    end
end)

local origAmbient, origColorShift, origGlobalShadows, origTime = Lighting.Ambient, Lighting.ColorShift_Top, Lighting.GlobalShadows, Lighting.ClockTime
local origFogStart, origFogEnd = Lighting.FogStart, Lighting.FogEnd
local atmCache = {}
for _, v in ipairs(Lighting:GetChildren()) do
    if v:IsA("Atmosphere") then
        atmCache[v] = {Density = v.Density, Offset = v.Offset}
    end
end

local cachedPlrs, cachedNpcs = {}, {}
local chamCache = {}

local function isVisible(model)
    local head = model:FindFirstChild("Head")
    if not head or not LocalPlayer.Character then return false end
    local origin = Camera.CFrame.Position
    local dir = (head.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, model, Camera}
    local hit = workspace:Raycast(origin, dir, params)
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

for _, v in ipairs(workspace:GetDescendants()) do
    checkAndCacheModel(v)
end

workspace.DescendantAdded:Connect(checkAndCacheModel)

workspace.DescendantRemoving:Connect(function(obj)
    cachedPlrs[obj] = nil
    cachedNpcs[obj] = nil
    if chamCache[obj] then
        chamCache[obj]:Destroy()
        chamCache[obj] = nil
    end
end)

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

local TracerPool, NamePool, DistPool = {}, {}, {}
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

    local dtxt = Drawing.new("Text")
    dtxt.Visible = false
    dtxt.Color = Color3.fromRGB(255, 255, 255)
    dtxt.Center = true
    dtxt.Outline = true
    dtxt.Size = 13
    dtxt.Font = 2
    DistPool[i] = dtxt
end

local function doAimbot()
    if not AIM_Active or not IsAimKeyDown then return end
    local maxDist = fovValues[fovIdx]
    local closestHeadPart = nil
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    
    local function check(char)
        if not isVisible(char) then return end
        
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
        local alpha = Smoothness == 0 and 1 or (1 - (Smoothness / 100))
        alpha = math.clamp(alpha, 0.01, 1)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, closestHeadPart.Position), alpha)
    end
end

RunService.RenderStepped:Connect(function()
    if not ScriptRunning then return end
    
    doAimbot()
    
    local drawIdx = 1
    local bottomStart = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
    local camPos = Camera.CFrame.Position
    
    if WH_Active or NPC_Active or Tracers_Active or Name_Active or Dist_Active then
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
                    
                    if (Tracers_Active or Name_Active or Dist_Active) and drawIdx <= MAX_DRAWINGS then
                        if Tracers_Active then
                            local line = TracerPool[drawIdx]
                            line.Visible = true
                            line.From = bottomStart
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

                        if Dist_Active then
                            local dist = math.floor((camPos - root.Position).Magnitude)
                            local dtxt = DistPool[drawIdx]
                            dtxt.Visible = true
                            dtxt.Text = dist .. " studs"
                            dtxt.Position = Vector2.new(sPos.X, sPos.Y + 15)
                            dtxt.Color = color
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
        if DistPool[i].Visible then DistPool[i].Visible = false end
    end
end)

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

DistBtn.MouseButton1Click:Connect(function()
    Dist_Active = not Dist_Active
    if Dist_Active then
        DistBtn.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
        DistBtn.Text = "Distance: ON"
    else
        DistBtn.BackgroundColor3 = Color3.fromRGB(140, 30, 30)
        DistBtn.Text = "Distance: OFF"
        for i = 1, MAX_DRAWINGS do DistPool[i].Visible = false end
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
        if DistPool[i] then DistPool[i]:Remove() end
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
