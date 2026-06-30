--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Settings
local ESP_Enabled = false
local Names_Enabled = false
local Distance_Enabled = false
local WeaponChams_Enabled = false
local BodyChams_Enabled = false
local Max_Render_Distance = 1200

local NoGrass_Enabled = false
local NoLeaves_Enabled = false
local Ambience_Enabled = false
local Ambience_Value = 128
local Sky_Enabled = false

local Skeletons = {}

-------------------------------------------------------
--// ESP Functions
-------------------------------------------------------

local function createDrawing(class, props)
    local d = Drawing.new(class)
    for k, v in pairs(props) do d[k] = v end
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
    local linesPool = {}
    for i = 1, 14 do
        linesPool[i] = createDrawing("Line", {Color = Color3.fromRGB(255, 0, 0), Thickness = 1.5, Visible = false})
    end
    Skeletons[player] = {
        Lines = linesPool,
        NameText = createDrawing("Text", {Text = player.Name, Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(255,255,255), Visible = false}),
        DistanceText = createDrawing("Text", {Text = "", Size = 13, Center = true, Outline = true, Color = Color3.fromRGB(255,255,255), Visible = false})
    }
end

local function updateESP()
    for player, data in pairs(Skeletons) do
        local char = player.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not hum or hum.Health <= 0 then
            removeESP(player)
            continue
        end

        local root = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
        if not root then continue end

        local distance = (Camera.CFrame.Position - root.Position).Magnitude
        if distance > Max_Render_Distance then
            for _, line in pairs(data.Lines) do line.Visible = false end
            data.NameText.Visible = false
            data.DistanceText.Visible = false
            continue
        end

        -- Check if player is in front of camera (not behind)
        local _, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            for _, line in pairs(data.Lines) do line.Visible = false end
            data.NameText.Visible = false
            data.DistanceText.Visible = false
            continue
        end

        -- Skeletons
        local bones = {
            {"UpperTorso","Head"}, {"UpperTorso","LeftUpperArm"}, {"LeftUpperArm","LeftLowerArm"},
            {"LeftLowerArm","LeftHand"}, {"UpperTorso","RightUpperArm"}, {"RightUpperArm","RightLowerArm"},
            {"RightLowerArm","RightHand"}, {"UpperTorso","LowerTorso"}, {"LowerTorso","LeftUpperLeg"},
            {"LeftUpperLeg","LeftLowerLeg"}, {"LeftLowerLeg","LeftFoot"}, {"LowerTorso","RightUpperLeg"},
            {"RightUpperLeg","RightLowerLeg"}, {"RightLowerLeg","RightFoot"}
        }

        for i, bone in ipairs(bones) do
            local partA = char:FindFirstChild(bone[1])
            local partB = char:FindFirstChild(bone[2])
            local line = data.Lines[i]
            if partA and partB then
                local posA = Camera:WorldToViewportPoint(partA.Position)
                local posB = Camera:WorldToViewportPoint(partB.Position)
                line.From = Vector2.new(posA.X, posA.Y)
                line.To = Vector2.new(posB.X, posB.Y)
                line.Visible = ESP_Enabled
            end
        end

        -- Name & Distance
        local head = char:FindFirstChild("Head")
        if head and Names_Enabled then
            local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
            data.NameText.Position = Vector2.new(headPos.X, headPos.Y)
            data.NameText.Visible = true
        else
            data.NameText.Visible = false
        end

        if Distance_Enabled then
            data.DistanceText.Text = tostring(math.round(distance)) .. " studs"
            local feetPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            data.DistanceText.Position = Vector2.new(feetPos.X, feetPos.Y)
            data.DistanceText.Visible = true
        else
            data.DistanceText.Visible = false
        end
    end
end

-------------------------------------------------------
--// BODY CHAMS
-------------------------------------------------------

local function updateBodyChams()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if char then
            local highlight = char:FindFirstChild("BodyCham")
            if BodyChams_Enabled then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "BodyCham"
                    highlight.FillColor = Color3.fromRGB(255, 200, 0)
                    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                    highlight.FillTransparency = 0.4
                    highlight.OutlineTransparency = 0
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Adornee = char
                    highlight.Parent = char
                end
            elseif highlight then
                highlight:Destroy()
            end
        end
    end
end

-------------------------------------------------------
--// VISUAL MODS
-------------------------------------------------------

local function toggleNoGrass(state)
    NoGrass_Enabled = state
    local terrain = Workspace:FindFirstChild("Terrain")
    if terrain then terrain.Decoration = not state end
end

local function toggleNoLeaves(state)
    NoLeaves_Enabled = state
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and (obj.Name:lower():find("leaf") or obj.Name:lower():find("leaves")) then
            pcall(function()
                obj.Transparency = state and 1 or 0
            end)
        end
    end
end

-------------------------------------------------------
--// Linoria GUI
-------------------------------------------------------

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = "Project Delta - Fixed ESP",
    Center = true,
    AutoShow = true,
})

local MainTab = Window:AddTab('Main')
local VisualsBox = MainTab:AddLeftGroupbox('ESP')
local EnvironmentBox = MainTab:AddRightGroupbox('World')

VisualsBox:AddToggle('ESP', { Text = 'Skeletons', Default = false, Callback = function(v) ESP_Enabled = v end })
VisualsBox:AddToggle('Names', { Text = 'Names', Default = false, Callback = function(v) Names_Enabled = v end })
VisualsBox:AddToggle('Distance', { Text = 'Distance', Default = false, Callback = function(v) Distance_Enabled = v end })
VisualsBox:AddSlider('RenderDist', { Text = 'Max Render Distance', Default = 1200, Min = 100, Max = 5000, Rounding = 0, Callback = function(v) Max_Render_Distance = v end })
VisualsBox:AddToggle('WeaponChams', { Text = 'Weapon Chams', Default = false, Callback = function(v) WeaponChams_Enabled = v end })
VisualsBox:AddToggle('BodyChams', { Text = 'Full Body Chams', Default = false, Callback = function(v) BodyChams_Enabled = v end })

EnvironmentBox:AddToggle('NoGrass', { Text = 'No Grass', Default = false, Callback = toggleNoGrass })
EnvironmentBox:AddToggle('NoLeaves', { Text = 'No Leaves', Default = false, Callback = toggleNoLeaves })
EnvironmentBox:AddToggle('Ambience', { Text = 'Custom Ambience', Default = false, Callback = function(v) Ambience_Enabled = v end })
EnvironmentBox:AddSlider('AmbienceVal', { Text = 'Ambience Value', Default = 128, Min = 0, Max = 255, Rounding = 0, Callback = function(v) Ambience_Value = v end })
EnvironmentBox:AddToggle('FullBright', { Text = 'Full Bright Sky', Default = false, Callback = function(v) Sky_Enabled = v end })

-- Main Loop
RunService.RenderStepped:Connect(function()
    updateESP()
    updateBodyChams()
end)

-- Player Join
Players.PlayerAdded:Connect(createESP)
for _, plr in ipairs(Players:GetPlayers()) do createESP(plr) end

print("✅")
