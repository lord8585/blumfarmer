-- Initialize Linoria Library & Addons
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
 
-- Create Linoria Window
local Window = Library:CreateWindow({
    Title = "Credit's To W99D - LuaCore",
    Center = true,
    AutoShow = true,
    TabPadding = 8,
    MenuFadeTime = 0.2
})
 
-- Authorized Keys Database
local AllowedKeys = {
    ["LC-KEY-7A9B-2F4X-910D"] = true,
    ["LC-KEY-3M8K-9V1Z-447P"] = true,
    ["LC-KEY-6Q2W-8E4R-110T"] = true,
    ["LC-KEY-5Y7U-2I9O-883P"] = true,
    ["LC-KEY-1A4S-7D3F-559G"] = true,
    ["LC-KEY-9H2J-6K8L-401Z"] = true,
    ["LC-KEY-2X4C-8V3B-772N"] = true,
    ["LC-KEY-8M1N-5B9V-334C"] = true,
    ["LC-KEY-4X7Z-2Q8W-991E"] = true,
    ["LC-KEY-6R3T-1Y9U-552I"] = true,
    ["LC-KEY-3O7P-8A2S-441D"] = true,
    ["LC-KEY-5F9G-1H3J-882K"] = true
}

-- Create Verification Tab
local LockTab = Window:AddTab('Lock Screen')
local LockBox = LockTab:AddLeftGroupbox('Key Verification')

LockBox:AddInput('KeyInput', {
    Default = '',
    Numeric = false,
    Finished = false, -- Updated to update state on every keystroke
    Text = 'Enter Key',
    Tooltip = 'Paste one of your generated product keys here',
    Placeholder = 'LC-KEY-...',
})

-- Placeholder variable for the render connection
local ScriptConnection

-- Forward Declarations for UI elements to build upon unlock
local MainTab, VisualsBox, MovementBox, AimlockBox, EnvironmentBox, SettingsBox

-- Core Configuration & State
local Camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
 
local ESP_Enabled = false
local Names_Enabled = false
local Distance_Enabled = false
local WeaponChams_Enabled = false
local Max_Render_Distance = 1000
 
local AdminCheck_Enabled = false
local LookAlert_Enabled = false
 
local Aimlock_Enabled = false
local Crosshair_Enabled = false
local FOV_Enabled = false
local FOV_Radius = 100
local Skeletons = {}
local ScriptStart = os.time()
 
local Speed_Enabled = false
local Speed_Value = 16
local Fly_Enabled = false
local Fly_Speed = 50
local Fly_BodyVelocity = nil
local Fly_BodyGyro = nil
 
local NoGrass_Enabled = false
local NoLeaves_Enabled = false
local Ambience_Enabled = false
local Ambience_Value = 128
local Sky_Enabled = false
 
local Original_Ambient = Lighting.Ambient
local Original_OutdoorAmbient = Lighting.OutdoorAmbient
local Original_ClockTime = Lighting.ClockTime
local Original_GeographicLatitude = Lighting.GeographicLatitude
 
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(255, 255, 255)
FOVCircle.Thickness = 1
FOVCircle.NumSides = 64
FOVCircle.Filled = false
FOVCircle.Visible = false
 
local CrossLines = {
    Vertical = Drawing.new("Line"),
    Horizontal = Drawing.new("Line")
}
for _, line in pairs(CrossLines) do
    line.Color = Color3.fromRGB(255, 255, 255)
    line.Thickness = 1
    line.Visible = false
end
 
local Hud_Pos = Vector2.new(40, 60)
local Hud_Size = Vector2.new(180, 100)
 
local PerformancePanel = Drawing.new("Square")
PerformancePanel.Size = Hud_Size
PerformancePanel.Position = Hud_Pos
PerformancePanel.Color = Color3.fromRGB(15, 15, 20)
PerformancePanel.Filled = true
PerformancePanel.Thickness = 0
PerformancePanel.Visible = false
 
local PerformanceOutline = Drawing.new("Square")
PerformanceOutline.Size = Hud_Size
PerformanceOutline.Position = Hud_Pos
PerformanceOutline.Color = Color3.fromRGB(114, 47, 240)
PerformanceOutline.Filled = false
PerformanceOutline.Thickness = 1
PerformanceOutline.Visible = false
 
local PerfText = Drawing.new("Text")
PerfText.Position = Hud_Pos + Vector2.new(14, 12)
PerfText.Size = 13
PerfText.Font = 2
PerfText.Color = Color3.fromRGB(255, 255, 255)
PerfText.Outline = true
PerfText.OutlineColor = Color3.fromRGB(0, 0, 0)
PerfText.Visible = false
 
local LookWarningText = Drawing.new("Text")
LookWarningText.Size = 20
LookWarningText.Font = 2
LookWarningText.Color = Color3.fromRGB(255, 30, 30)
LookWarningText.Center = true
LookWarningText.Outline = true
LookWarningText.OutlineColor = Color3.fromRGB(0, 0, 0)
LookWarningText.Visible = false
 
local IsDragging = false
local DragOffset = Vector2.new(0, 0)
 
local R15_Bones = {
    {"UpperTorso", "Head"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"},
    {"LeftLowerArm", "LeftHand"}, {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"},
    {"RightLowerArm", "RightHand"}, {"UpperTorso", "LowerTorso"}, {"LowerTorso", "LeftUpperLeg"},
    {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"},
    {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
}
 
local R6_Bones = {
    {"Torso", "Head"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
    {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
}
 
local StaffRanks = {"mod", "admin", "owner", "crea", "staff", "intern", "developer", "com", "man"}
 
local function createDrawing(class, properties)
    local d = Drawing.new(class)
    for prop, val in pairs(properties) do d[prop] = val end
    return d
end
 
local function removeESP(player)
    if Skeletons[player] then
        for _, line in pairs(Skeletons[player].Lines) do line:Remove() end
        if Skeletons[player].NameText then Skeletons[player].NameText:Remove() end
        if Skeletons[player].DistanceText then Skeletons[player].DistanceText:Remove() end
        Skeletons[player] = nil
    end
end
 
local function createESP(player)
    if player == LocalPlayer then return end
    local maxLines = #R15_Bones
    local linesPool = {}
    for i = 1, maxLines do
        linesPool[i] = createDrawing("Line", {Color = Color3.fromRGB(255, 0, 0), Thickness = 1.5, Visible = false})
    end
    Skeletons[player] = {
        Lines = linesPool,
        NameText = createDrawing("Text", {Text = player.Name, Size = 13, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0,0,0), Color = Color3.fromRGB(255,255,255), Visible = false}),
        DistanceText = createDrawing("Text", {Text = "", Size = 13, Center = true, Outline = true, OutlineColor = Color3.fromRGB(0,0,0), Color = Color3.fromRGB(255,255,255), Visible = false})
    }
end
 
local function toggleVisibility(drawingObject, visibleState)
    if typeof(drawingObject) == "table" or drawingObject.Remove then
        pcall(function() drawingObject.Visible = visibleState end)
    end
end
 
local function getClosestPlayerToCenter()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
 
    for player, _ in pairs(Skeletons) do
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not character or not humanoid or humanoid.Health <= 0 then continue end
        local head = character:FindFirstChild("Head")
        if not head then continue end
 
        local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
        if onScreen then
            local distanceToCenter = (Vector2.new(screenPos.X, screenPos.Y) - viewportCenter).Magnitude
            if distanceToCenter <= FOV_Radius and distanceToCenter < shortestDistance then
                shortestDistance = distanceToCenter
                closestPlayer = head
            end
        end
    end
    return closestPlayer
end
 
local function verifyStaffPresence(player)
    if not AdminCheck_Enabled then return end
    local rankMatch = false
    pcall(function()
        if player:GetRankInGroup(player.PrimaryGroupId or 0) >= 200 then rankMatch = true end
    end)
    for _, rankWord in ipairs(StaffRanks) do
        if player.Name:lower():find(rankWord) or (player.DisplayName and player.DisplayName:lower():find(rankWord)) then
            rankMatch = true
        end
    end
    if rankMatch then
        Library:Notify(string.format("[ALERT] Staff Member Spotted: %s (@%s)", player.DisplayName, player.Name), 8)
    end
end
 
local function getUptimeString()
    local totalSeconds = os.time() - ScriptStart
    local hours = math.floor(totalSeconds / 3600)
    local minutes = math.floor((totalSeconds % 3600) / 60)
    local seconds = totalSeconds % 60
    return string.format("%02dh %02dm %02ds", hours, minutes, seconds)
end
 
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessed then
        local mousePos = UserInputService:GetMouseLocation()
        if mousePos.X >= Hud_Pos.X and mousePos.X <= (Hud_Pos.X + Hud_Size.X) then
            if mousePos.Y >= Hud_Pos.Y and mousePos.Y <= (Hud_Pos.Y + Hud_Size.Y) then
                IsDragging = true
                DragOffset = Hud_Pos - mousePos
            end
        end
    end
end)
 
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then IsDragging = false end
end)
 
local function updateESP()
    local viewportCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    FOVCircle.Position = viewportCenter
    FOVCircle.Radius = FOV_Radius
    toggleVisibility(FOVCircle, FOV_Enabled)
 
    local crosshairSize = 6
    CrossLines.Horizontal.From = viewportCenter - Vector2.new(crosshairSize, 0)
    CrossLines.Horizontal.To = viewportCenter + Vector2.new(crosshairSize, 0)
    CrossLines.Vertical.From = viewportCenter - Vector2.new(0, crosshairSize)
    CrossLines.Vertical.To = viewportCenter + Vector2.new(0, crosshairSize)
 
    for _, line in pairs(CrossLines) do toggleVisibility(line, Crosshair_Enabled) end
 
    if IsDragging then
        local currentMouse = UserInputService:GetMouseLocation()
        Hud_Pos = currentMouse + DragOffset
        PerformancePanel.Position = Hud_Pos
        PerformanceOutline.Position = Hud_Pos
    end
 
    local currentFps = math.round(1 / RunService.RenderStepped:Wait())
    local currentPing = math.round(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
 
    PerfText.Position = Hud_Pos + Vector2.new(14, 12)
    PerfText.Text = string.format("FPS    :  %d\nPing   :  %d ms\nUptime :  %s\nStatus :  Active", currentFps, currentPing, getUptimeString())
 
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
 
    if character and rootPart and humanoid then
        if Speed_Enabled then humanoid.WalkSpeed = Speed_Value end
        if Fly_Enabled then
            if not Fly_BodyVelocity or not Fly_BodyVelocity.Parent then
                Fly_BodyVelocity = Instance.new("BodyVelocity")
                Fly_BodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                Fly_BodyVelocity.Velocity = Vector3.new(0, 0, 0)
                Fly_BodyVelocity.Parent = rootPart
 
                Fly_BodyGyro = Instance.new("BodyGyro")
                Fly_BodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
                Fly_BodyGyro.CFrame = rootPart.CFrame
                Fly_BodyGyro.Parent = rootPart
            end
            local flyVelocity = Vector3.new(0, 0, 0)
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then flyVelocity = flyVelocity + Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then flyVelocity = flyVelocity - Camera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then flyVelocity = flyVelocity - Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then flyVelocity = flyVelocity + Camera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then flyVelocity = flyVelocity + Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then flyVelocity = flyVelocity - Vector3.new(0, 1, 0) end
 
            Fly_BodyVelocity.Velocity = flyVelocity.Unit * Fly_Speed
            if flyVelocity == Vector3.new(0,0,0) then Fly_BodyVelocity.Velocity = Vector3.new(0,0,0) end
            Fly_BodyGyro.CFrame = Camera.CFrame
        else
            if Fly_BodyVelocity then Fly_BodyVelocity:Destroy() Fly_BodyVelocity = nil end
            if Fly_BodyGyro then Fly_BodyGyro:Destroy() Fly_BodyGyro = nil end
        end
    end
 
    local currentLookingThreat = nil
    for player, data in pairs(Skeletons) do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum or hum.Health <= 0 then
            for _, line in pairs(data.Lines) do toggleVisibility(line, false) end
            toggleVisibility(data.NameText, false)
            toggleVisibility(data.DistanceText, false)
            continue
        end
 
        local pRoot = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        local pHead = char:FindFirstChild("Head")
        if not pRoot or not pHead then continue end
 
        local distance = math.round((Camera.CFrame.Position - pRoot.Position).Magnitude)
        local _, onScreen = Camera:WorldToViewportPoint(pRoot.Position)
 
        if LookAlert_Enabled and rootPart then
            local enemyLookDirection = pHead.CFrame.LookVector
            local vectorToMe = (rootPart.Position - pHead.Position).Unit
            local lookDot = enemyLookDirection:Dot(vectorToMe)
            if lookDot > 0.97 then
                local rayParameters = RaycastParams.new()
                rayParameters.FilterType = Enum.RaycastFilterType.Exclude
                rayParameters.FilterDescendantsInstances = {char, character}
                local hitTest = workspace:Raycast(pHead.Position, (rootPart.Position - pHead.Position), rayParameters)
                if hitTest and hitTest.Instance and hitTest.Instance:IsA("BasePart") then
                    currentLookingThreat = player.DisplayName
                end
            end
        end
 
        if onScreen and distance <= Max_Render_Distance then
            local activeBones = (hum.RigType == Enum.HumanoidRigType.R15) and R15_Bones or R6_Bones
            local dynamicFontSize = math.clamp(math.round(14 * (120 / distance)), 9, 13)
            data.NameText.Size = dynamicFontSize
            data.DistanceText.Size = dynamicFontSize
 
            for _, line in pairs(data.Lines) do toggleVisibility(line, false) end
            if ESP_Enabled then
                for i, bone in ipairs(activeBones) do
                    local partA = char:FindFirstChild(bone[1])
                    local partB = char:FindFirstChild(bone[2])
                    local line = data.Lines[i]
                    if partA and partB then
                        local posA, screenA = Camera:WorldToViewportPoint(partA.Position)
                        local posB, screenB = Camera:WorldToViewportPoint(partB.Position)
                        if screenA and screenB then
                            line.From = Vector2.new(posA.X, posA.Y)
                            line.To = Vector2.new(posB.X, posB.Y)
                            toggleVisibility(line, true)
                        end
                    end
                end
            end
 
            local dynamicTopGap = math.clamp(1.2 + (distance / 150), 1.2, 2.2)
            local headPos, headOnScreen = Camera:WorldToViewportPoint(pHead.Position + Vector3.new(0, dynamicTopGap, 0))
            local bottomOffset = (hum.RigType == Enum.HumanoidRigType.R15) and -3.4 or -3.1
            local feetPos, feetOnScreen = Camera:WorldToViewportPoint(pRoot.Position + Vector3.new(0, bottomOffset, 0))
 
            if Names_Enabled and headOnScreen then
                data.NameText.Position = Vector2.new(headPos.X, headPos.Y)
                toggleVisibility(data.NameText, true)
            else
                toggleVisibility(data.NameText, false)
            end
 
            if Distance_Enabled and feetOnScreen then
                data.DistanceText.Text = tostring(distance) .. " studs"
                data.DistanceText.Position = Vector2.new(feetPos.X, feetPos.Y)
                toggleVisibility(data.DistanceText, true)
            else
                toggleVisibility(data.DistanceText, false)
            end
        else
            for _, line in pairs(data.Lines) do toggleVisibility(line, false) end
            toggleVisibility(data.NameText, false)
            toggleVisibility(data.DistanceText, false)
        end
    end
 
    if currentLookingThreat then
        LookWarningText.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y * 0.25)
        LookWarningText.Text = string.format("[WARNING] %s is tracking you through the wall!", currentLookingThreat)
        toggleVisibility(LookWarningText, true)
    else
        toggleVisibility(LookWarningText, false)
    end
 
    local localCharacter = LocalPlayer.Character
    if WeaponChams_Enabled then
        if localCharacter then
            for _, item in ipairs(localCharacter:GetChildren()) do
                if item:IsA("Tool") or item.Name:lower():find("weapon") or item.Name:lower():find("gun") then
                    local highlight = item:FindFirstChild("LuaCoreCham")
                    if not highlight then
                        highlight = Instance.new("Highlight")
                        highlight.Name = "LuaCoreCham"
                        highlight.FillColor = Color3.fromRGB(255, 255, 0)
                        highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                        highlight.Adornee = item
                        highlight.Parent = item
                    end
                end
            end
        end
        for _, item in ipairs(Camera:GetChildren()) do
            if item:IsA("Model") or item.Name:lower():find("viewmodel") or item.Name:lower():find("weapon") or item.Name:lower():find("arms") then
                local highlight = item:FindFirstChild("LuaCoreCham")
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "LuaCoreCham"
                    highlight.FillColor = Color3.fromRGB(255, 255, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
                    highlight.Adornee = item
                    highlight.Parent = item
                end
            end
        end
    else
        if localCharacter then
            for _, item in ipairs(localCharacter:GetChildren()) do
                local h = item:FindFirstChild("LuaCoreCham")
                if h then h:Destroy() end
            end
        end
        for _, item in ipairs(Camera:GetChildren()) do
            local h = item:FindFirstChild("LuaCoreCham")
            if h then h:Destroy() end
        end
    end
 
    if Aimlock_Enabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local targetHead = getClosestPlayerToCenter()
        if targetHead then Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetHead.Position) end
    end
 
    if NoGrass_Enabled and workspace:FindFirstChildOfClass("Terrain") then
        workspace:FindFirstChildOfClass("Terrain").Decoration = false
    end
 
    if NoLeaves_Enabled then
        for _, object in ipairs(workspace:GetDescendants()) do
            if object:IsA("MeshPart") and (object.Name:lower():find("leaf") or object.Name:lower():find("leaves")) then
                object.Transparency = 1
            elseif object:IsA("Decal") and (object.Name:lower():find("leaf") or object.Name:lower():find("leaves") or object.Texture:find("rbxassetid://314120")) then
                object.Transparency = 1
            end
        end
    end
 
    if Ambience_Enabled then
        local rgbVal = Ambience_Value
        Lighting.Ambient = Color3.fromRGB(rgbVal, rgbVal, rgbVal)
        Lighting.OutdoorAmbient = Color3.fromRGB(rgbVal, rgbVal, rgbVal)
    end
 
    if Sky_Enabled then
        Lighting.ClockTime = 12
        Lighting.GeographicLatitude = 0
        for _, object in ipairs(Lighting:GetChildren()) do
            if object:IsA("Sky") or object:IsA("Atmosphere") or object:IsA("Clouds") then object:Destroy() end
        end
        Lighting.FogEnd = 999999
        pcall(function()
            local screenSky = workspace.CurrentCamera:FindFirstChildOfClass("Sky") or Lighting:FindFirstChildOfClass("Sky")
            if not screenSky then
                local whiteSky = Instance.new("Sky", Lighting)
                whiteSky.SkyboxBk = "rbxassetid://10134812234"; whiteSky.SkyboxDn = "rbxassetid://10134812234"
                whiteSky.SkyboxFt = "rbxassetid://10134812234"; whiteSky.SkyboxLf = "rbxassetid://10134812234"
                whiteSky.SkyboxRt = "rbxassetid://10134812234"; whiteSky.SkyboxUp = "rbxassetid://10134812234"
                whiteSky.SunTextureId = ""; whiteSky.MoonTextureId = ""
            end
        end)
    end
end

-- Initialize Core Functionality after safe Key Verification
local function UnlockScript()
    Library:Notify("Key Validated! Loading Interface...", 4)
    
    PerformancePanel.Visible = true
    PerformanceOutline.Visible = true
    PerfText.Visible = true

    MainTab = Window:AddTab('Main')
    VisualsBox = MainTab:AddLeftGroupbox('Enemy ESP')
    MovementBox = MainTab:AddLeftGroupbox('Movement Controls')
    AimlockBox = MainTab:AddLeftGroupbox('Aimlock Configuration')
    EnvironmentBox = MainTab:AddRightGroupbox('Environment Controls')
    SettingsBox = MainTab:AddRightGroupbox('Menu Settings')

    VisualsBox:AddToggle('SkeletonESP', { Text = 'Skeletons', Default = false, Tooltip = 'Draws clean, flat-line skeletons on players', Callback = function(Value) ESP_Enabled = Value end })
    VisualsBox:AddToggle('NameESP', { Text = 'Names', Default = false, Tooltip = 'Displays clean text names above player structures', Callback = function(Value) Names_Enabled = Value end })
    VisualsBox:AddToggle('DistanceESP', { Text = 'Display Distance', Default = false, Tooltip = 'Displays absolute distance values under player structures', Callback = function(Value) Distance_Enabled = Value end })
    VisualsBox:AddSlider('RenderDistanceSlider', { Text = 'Render Distance Max', Default = 1000, Min = 100, Max = 5000, Rounding = 0, Compact = false, Callback = function(Value) Max_Render_Distance = Value end })
    VisualsBox:AddToggle('WeaponChams', { Text = 'Weapon Chams', Default = false, Tooltip = 'Turns your equipped held weapons a bright solid yellow color', Callback = function(Value) WeaponChams_Enabled = Value end })
    VisualsBox:AddToggle('AdminJoinCheck', { Text = 'Admin/Mod Check Alert', Default = false, Tooltip = 'Notifies you immediately when a player logs in', Callback = function(Value) AdminCheck_Enabled = Value if Value then for _, p in ipairs(Players:GetPlayers()) do verifyStaffPresence(p) end end end })
    VisualsBox:AddToggle('LookWarningToggle', { Text = 'Wall Look Warning Alert', Default = false, Tooltip = 'Triggers on-screen warning text', Callback = function(Value) LookAlert_Enabled = Value end })

    MovementBox:AddToggle('SpeedExploitToggle', { Text = 'Enable Speed', Default = false, Tooltip = 'Enforces structural custom walking velocities', Callback = function(Value) Speed_Enabled = Value if not Value and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = 16 end end })
    MovementBox:AddSlider('SpeedExploitValue', { Text = 'Speed Multiplier', Default = 16, Min = 16, Max = 150, Rounding = 0, Compact = false, Callback = function(Value) Speed_Value = Value end })
    MovementBox:AddToggle('FlyExploitToggle', { Text = 'Enable Fly', Default = false, Tooltip = 'Bypasses ground collision arrays', Callback = function(Value) Fly_Enabled = Value end })
    MovementBox:AddSlider('FlyExploitValue', { Text = 'Fly Velocity Speed', Default = 50, Min = 20, Max = 300, Rounding = 0, Compact = false, Callback = function(Value) Fly_Speed = Value end })

    AimlockBox:AddToggle('AimlockToggle', { Text = 'Enable Aimlock', Default = false, Tooltip = 'Locks your center camera view onto target heads on Right Click hold', Callback = function(Value) Aimlock_Enabled = Value end })
    AimlockBox:AddToggle('ShowCrosshair', { Text = 'Show Crosshair', Default = false, Tooltip = 'Toggles a tiny, centered gapless technical crosshair cross', Callback = function(Value) Crosshair_Enabled = Value end })
    AimlockBox:AddToggle('ShowFOVCircle', { Text = 'Show FOV Circle', Default = false, Tooltip = 'Toggles visual white circle boundaries on the screen center', Callback = function(Value) FOV_Enabled = Value end })
    AimlockBox:AddSlider('FOVSliderRadius', { Text = 'FOV Radius Size', Default = 100, Min = 20, Max = 600, Rounding = 0, Compact = false, Callback = function(Value) FOV_Radius = Value end })

    EnvironmentBox:AddToggle('DisableGrass', { Text = 'No Grass', Default = false, Tooltip = 'Removes 3D terrain layered grass structures completely', Callback = function(Value) NoGrass_Enabled = Value if not Value and workspace:FindFirstChildOfClass("Terrain") then workspace:FindFirstChildOfClass("Terrain").Decoration = true end end })
    EnvironmentBox:AddToggle('DisableLeaves', { Text = 'No Leaves', Default = false, Tooltip = 'Forces rendering updates transparency overrides on map foliage models', Callback = function(Value) NoLeaves_Enabled = Value if not Value then for _, object in ipairs(workspace:GetDescendants()) do if object:IsA("MeshPart") and (object.Name:lower():find("leaf") or object.Name:lower():find("leaves")) then object.Transparency = 0 elseif object:IsA("Decal") and (object.Name:lower():find("leaf") or object.Name:lower():find("leaves")) then object.Transparency = 0 end end end end })
    EnvironmentBox:AddToggle('OverrideAmbience', { Text = 'Custom Ambience', Default = false, Tooltip = 'Enables structural illumination level changes across map cells', Callback = function(Value) Ambience_Enabled = Value if not Value then Lighting.Ambient = Original_Ambient; Lighting.OutdoorAmbient = Original_OutdoorAmbient end end })
    EnvironmentBox:AddSlider('AmbienceIntensityValue', { Text = 'Ambience Shading Bar', Default = 128, Min = 0, Max = 255, Rounding = 0, Compact = false, Callback = function(Value) Ambience_Value = Value end })
    EnvironmentBox:AddToggle('WhiteSkyFullBright', { Text = 'Full Bright White Sky', Default = false, Tooltip = 'Sky projections with bright white filters', Callback = function(Value) Sky_Enabled = Value if not Value then Lighting.ClockTime = Original_ClockTime; Lighting.GeographicLatitude = Original_GeographicLatitude; local whiteSky = Lighting:FindFirstChildOfClass("Sky") if whiteSky and whiteSky.Name == "Sky" then whiteSky:Destroy() end end end })

    SettingsBox:AddButton('Unload Script', function()
        FOVCircle:Remove()
        PerformancePanel:Remove()
        PerformanceOutline:Remove()
        PerfText:Remove()
        LookWarningText:Remove()
        for _, line in pairs(CrossLines) do line:Remove() end
        if Fly_BodyVelocity then Fly_BodyVelocity:Destroy() end
        if Fly_BodyGyro then Fly_BodyGyro:Destroy() end
        if workspace:FindFirstChildOfClass("Terrain") then workspace:FindFirstChildOfClass("Terrain").Decoration = true end
        if ScriptConnection then ScriptConnection:Disconnect() end
        Lighting.Ambient = Original_Ambient
        Lighting.OutdoorAmbient = Original_OutdoorAmbient
        Lighting.ClockTime = Original_ClockTime
        Lighting.GeographicLatitude = Original_GeographicLatitude
        Library:Unload()
    end)

    SettingsBox:AddLabel('Menu Keybind'):AddKeyPicker('MenuKeybind', { Default = 'End', NoUI = true, Text = 'Menu Keybind' })
    Library.ToggleKeybind = Options.MenuKeybind

    for _, player in ipairs(Players:GetPlayers()) do createESP(player) end
    Players.PlayerAdded:Connect(function(player) createESP(player) verifyStaffPresence(player) end)
    Players.PlayerRemoving:Connect(function(player) removeESP(player) end)

    ScriptConnection = RunService.RenderStepped:Connect(updateESP)

    ThemeManager:SetLibrary(Library)
    SaveManager:SetLibrary(Library)
    ThemeManager:SetFolder('LuaCore')
    SaveManager:SetFolder('LuaCore/configs')
    SaveManager:BuildContextMenu(SettingsBox)
    ThemeManager:ApplyTheme('Default')
    
    MainTab:Show()
end

LockBox:AddButton('Submit Key', function()
    -- Pull directly from the UI registry state to completely avoid evaluation errors
    local InputValue = Options.KeyInput.Value
    if AllowedKeys[InputValue] then
        UnlockScript()
    else
        Library:Notify("Invalid Key Entered! Please check and try again.", 4)
    end
end)
