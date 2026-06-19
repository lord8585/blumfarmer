--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Settings
local MAIN_ESP_ENABLED = false
local PLAYER_ESP_ENABLED = true
local ITEM_ESP_ENABLED = false
local NPC_ESP_ENABLED = false
local TRACERS_ENABLED = false
local NO_GRASS_ENABLED = false
local NO_LEAVES_ENABLED = false
local ANTI_RECOIL_ENABLED = false
local UI_VISIBLE = true

--// Storage
local playerHighlights = {}
local itemHighlights = {}
local npcHighlights = {}
local tracerLines = {}
local originalLeafTransparencies = {}
local connections = {}
local startTime = os.time()

local espSubMenuOpen = false

-------------------------------------------------------
--// HELPER FUNCTIONS
-------------------------------------------------------

local function isPlayerCharacter(model)
    return model and Players:GetPlayerFromCharacter(model) ~= nil
end

local function isLeafPart(obj)
    if not obj:IsA("BasePart") then return false end
    local name = obj.Name:lower()
    return name:find("leaf") or name:find("foliage") or name:find("leaves")
end

-------------------------------------------------------
--// ESP + TRACERS
-------------------------------------------------------

local function createTracer(player)
    if tracerLines[player] then tracerLines[player]:Destroy() end
    
    local line = Drawing.new("Line")
    line.Thickness = 1.5
    line.Color = Color3.fromRGB(255, 50, 50)
    line.Transparency = 1
    tracerLines[player] = line
end

local function updateTracers()
    for player, line in pairs(tracerLines) do
        if player and player.Character and player.Character:FindFirstChild("Head") and 
           PLAYER_ESP_ENABLED and TRACERS_ENABLED then
            local head = player.Character.Head
            local vector, onScreen = Camera:WorldToViewportPoint(head.Position)
            
            if onScreen then
                line.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                line.To = Vector2.new(vector.X, vector.Y)
                line.Visible = true
            else
                line.Visible = false
            end
        else
            if line then line.Visible = false end
        end
    end
end

local function addHighlight(player, character)
    if player == LocalPlayer or not character or character:FindFirstChild("PlayerHighlight") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "PlayerHighlight"
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = character
    highlight.Parent = character
    playerHighlights[player] = highlight
end

local function togglePlayerESP(state)
    PLAYER_ESP_ENABLED = state
    if not state then
        for _, h in pairs(playerHighlights) do h:Destroy() end
        table.clear(playerHighlights)
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then addHighlight(player, player.Character) end
        end
    end
end

local function toggleItemESP(state)
    ITEM_ESP_ENABLED = state
    -- (same logic as before)
    if not state then
        for _, h in pairs(itemHighlights) do h:Destroy() end
        table.clear(itemHighlights)
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if isValidItem(obj) then addItemHighlight(obj) end
        end
    end
end

local function toggleNpcESP(state)
    NPC_ESP_ENABLED = state
    if not state then
        for _, h in pairs(npcHighlights) do h:Destroy() end
        table.clear(npcHighlights)
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if isValidNPC(obj) then addNpcHighlight(obj) end
        end
    end
end

local function toggleTracers(state)
    TRACERS_ENABLED = state
    if not state then
        for _, line in pairs(tracerLines) do line:Destroy() end
        table.clear(tracerLines)
    end
end

-------------------------------------------------------
--// GUI (With Expandable ESP)
-------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "PD_CHAMS_LITE"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 560)
frame.Position = UDim2.new(0.1, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 4)
topBar.BackgroundColor3 = Color3.fromRGB(130, 45, 230)
topBar.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 35)
title.Position = UDim2.new(0, 14, 0, 6)
title.BackgroundTransparency = 1
title.Text = "PD-CHAMS-LITE"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 16
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Main ESP Button
local espContainer = Instance.new("Frame")
espContainer.Size = UDim2.new(1, -20, 0, 40)
espContainer.Position = UDim2.new(0, 10, 0, 70)
espContainer.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
espContainer.Parent = frame

local espBtn = Instance.new("TextButton")
espBtn.Size = UDim2.new(1, 0, 1, 0)
espBtn.BackgroundTransparency = 1
espBtn.Text = "ESP"
espBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
espBtn.TextSize = 15
espBtn.Font = Enum.Font.SourceSansBold
espBtn.TextXAlignment = Enum.TextXAlignment.Left
espBtn.Parent = espContainer

-- Submenu Frame
local subMenu = Instance.new("Frame")
subMenu.Size = UDim2.new(1, -20, 0, 160)
subMenu.Position = UDim2.new(0, 10, 0, 115)
subMenu.BackgroundColor3 = Color3.fromRGB(20, 20, 22)
subMenu.Visible = false
subMenu.Parent = frame

-- Sub Options with Checkboxes
local function createSubOption(text, yPos, toggleFunc)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 30)
    container.Position = UDim2.new(0, 10, 0, yPos)
    container.BackgroundTransparency = 1
    container.Parent = subMenu

    local checkbox = Instance.new("TextButton")
    checkbox.Size = UDim2.new(0, 20, 0, 20)
    checkbox.Position = UDim2.new(0, 0, 0.5, -10)
    checkbox.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
    checkbox.Text = "✓"
    checkbox.TextColor3 = Color3.fromRGB(130, 45, 230)
    checkbox.TextScaled = true
    checkbox.Parent = container

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Position = UDim2.new(0, 30, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container

    checkbox.MouseButton1Click:Connect(function()
        local newState = not (checkbox.Text == "✓")
        checkbox.Text = newState and "✓" or ""
        toggleFunc(newState)
    end)

    return checkbox
end

local playerCheck = createSubOption("Player ESP", 5, togglePlayerESP)
local itemCheck   = createSubOption("Item ESP", 40, toggleItemESP)
local npcCheck    = createSubOption("NPC ESP", 75, toggleNpcESP)
local tracerCheck = createSubOption("Tracers", 110, toggleTracers)

-- Right Click to Expand
espBtn.MouseButton1Click:Connect(function()
    MAIN_ESP_ENABLED = not MAIN_ESP_ENABLED
    togglePlayerESP(MAIN_ESP_ENABLED)
end)

espBtn.MouseButton2Click:Connect(function()
    espSubMenuOpen = not espSubMenuOpen
    subMenu.Visible = espSubMenuOpen
end)

-- Other Buttons (No Grass, No Leaves, Anti Recoil, Slider, Self Destruct) remain below...

print("✅ PD-CHAMS-LITE Loaded ")
