--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Settings
local Names_Enabled = false
local Distance_Enabled = false
local WeaponChams_Enabled = false
local BodyChams_Enabled = false
local NPC_ESP_ENABLED = false
local Max_Render_Distance = 1200

local NoGrass_Enabled = false
local NoLeaves_Enabled = false
local Ambience_Enabled = false
local Ambience_Value = 128
local Sky_Enabled = false

local NameTexts = {}
local DistanceTexts = {}
local NPC_Highlights = {}

-------------------------------------------------------
--// PLAYER NAME & DISTANCE ESP
-------------------------------------------------------

local function createNameESP(player)
    if player == LocalPlayer then return end
    local nameText = Drawing.new("Text")
    nameText.Text = player.Name
    nameText.Size = 13
    nameText.Center = true
    nameText.Outline = true
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Visible = false
    NameTexts[player] = nameText
end

local function createDistanceESP(player)
    if player == LocalPlayer then return end
    local distText = Drawing.new("Text")
    distText.Size = 13
    distText.Center = true
    distText.Outline = true
    distText.Color = Color3.fromRGB(255, 255, 255)
    distText.Visible = false
    DistanceTexts[player] = distText
end

local function updatePlayerESP()
    for player, nameText in pairs(NameTexts) do
        local char = player.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not char or not root or not hum or hum.Health <= 0 then
            nameText.Visible = false
            if DistanceTexts[player] then DistanceTexts[player].Visible = false end
            continue
        end

        local distance = (Camera.CFrame.Position - root.Position).Magnitude
        if distance > Max_Render_Distance then
            nameText.Visible = false
            if DistanceTexts[player] then DistanceTexts[player].Visible = false end
            continue
        end

        local _, onScreen = Camera:WorldToViewportPoint(root.Position)
        if not onScreen then
            nameText.Visible = false
            if DistanceTexts[player] then DistanceTexts[player].Visible = false end
            continue
        end

        -- Name
        if Names_Enabled then
            local head = char:FindFirstChild("Head")
            if head then
                local headPos = Camera:WorldToViewportPoint(head.Position + Vector3.new(0, 2.5, 0))
                nameText.Position = Vector2.new(headPos.X, headPos.Y)
                nameText.Visible = true
            end
        else
            nameText.Visible = false
        end

        -- Distance
        if Distance_Enabled and DistanceTexts[player] then
            local feetPos = Camera:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
            DistanceTexts[player].Text = tostring(math.round(distance)) .. " studs"
            DistanceTexts[player].Position = Vector2.new(feetPos.X, feetPos.Y)
            DistanceTexts[player].Visible = true
        else
            if DistanceTexts[player] then DistanceTexts[player].Visible = false end
        end
    end
end

-------------------------------------------------------
--// NPC ESP
-------------------------------------------------------

local function addNpcHighlight(obj)
    if NPC_Highlights[obj] or obj:FindFirstChild("NpcHighlight") then return end
    if not (obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart")) then return end
    if Players:GetPlayerFromCharacter(obj) then return end

    local hl = Instance.new("Highlight")
    hl.Name = "NpcHighlight"
    hl.FillColor = Color3.fromRGB(0, 120, 255)
    hl.OutlineColor = Color3.fromRGB(0, 200, 255)
    hl.FillTransparency = 0.3
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = obj
    hl.Parent = obj
    NPC_Highlights[obj] = hl
end

local function toggleNpcESP(state)
    NPC_ESP_ENABLED = state
    if not state then
        for _, h in pairs(NPC_Highlights) do h:Destroy() end
        NPC_Highlights = {}
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            addNpcHighlight(obj)
        end
    end
end

-------------------------------------------------------
--// BODY & WEAPON CHAMS
-------------------------------------------------------

local function updateChams()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        local char = player.Character
        if char then
            local hl = char:FindFirstChild("BodyCham")
            if BodyChams_Enabled then
                if not hl then
                    hl = Instance.new("Highlight")
                    hl.Name = "BodyCham"
                    hl.FillColor = Color3.fromRGB(255, 200, 0)
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.FillTransparency = 0.4
                    hl.OutlineTransparency = 0
                    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    hl.Adornee = char
                    hl.Parent = char
                end
            elseif hl then
                hl:Destroy()
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
--// GUI
-------------------------------------------------------

local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()

local Window = Library:CreateWindow({
    Title = "Project Delta - Clean ESP",
    Center = true,
    AutoShow = true,
})

local MainTab = Window:AddTab('Main')
local VisualsBox = MainTab:AddLeftGroupbox('Player ESP')
local NpcBox = MainTab:AddLeftGroupbox('NPC ESP')
local EnvironmentBox = MainTab:AddRightGroupbox('World')

VisualsBox:AddToggle('Names', { Text = 'Names', Default = false, Callback = function(v) Names_Enabled = v end })
VisualsBox:AddToggle('Distance', { Text = 'Distance', Default = false, Callback = function(v) Distance_Enabled = v end })
VisualsBox:AddSlider('RenderDist', { Text = 'Max Render Distance', Default = 1200, Min = 100, Max = 5000, Rounding = 0, Callback = function(v) Max_Render_Distance = v end })
VisualsBox:AddToggle('WeaponChams', { Text = 'Weapon Chams', Default = false, Callback = function(v) WeaponChams_Enabled = v end })
VisualsBox:AddToggle('BodyChams', { Text = 'Full Body Chams', Default = false, Callback = function(v) BodyChams_Enabled = v end })

NpcBox:AddToggle('NpcESP', { Text = 'NPC ESP', Default = false, Callback = toggleNpcESP })

EnvironmentBox:AddToggle('NoGrass', { Text = 'No Grass', Default = false, Callback = toggleNoGrass })
EnvironmentBox:AddToggle('NoLeaves', { Text = 'No Leaves', Default = false, Callback = toggleNoLeaves })
EnvironmentBox:AddToggle('Ambience', { Text = 'Custom Ambience', Default = false, Callback = function(v) Ambience_Enabled = v end })
EnvironmentBox:AddSlider('AmbienceVal', { Text = 'Ambience Value', Default = 128, Min = 0, Max = 255, Rounding = 0, Callback = function(v) Ambience_Value = v end })
EnvironmentBox:AddToggle('FullBright', { Text = 'Full Bright Sky', Default = false, Callback = function(v) Sky_Enabled = v end })

-- Main Loop
RunService.RenderStepped:Connect(function()
    updatePlayerESP()
    updateChams()
end)

-- Player Join
Players.PlayerAdded:Connect(function(plr)
    createNameESP(plr)
    createDistanceESP(plr)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    createNameESP(plr)
    createDistanceESP(plr)
end

print("yuhhh!!!")
