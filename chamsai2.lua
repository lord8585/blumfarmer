--// Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Settings
local ESP_ENABLED = false
local ITEM_ESP_ENABLED = false
local NPC_ESP_ENABLED = false
local NO_GRASS_ENABLED = false
local NO_LEAVES_ENABLED = false
local ANTI_RECOIL_ENABLED = false
local UI_VISIBLE = true

--// Storage
local playerHighlights = {}
local itemHighlights = {}
local npcHighlights = {}
local originalLeafTransparencies = {}

local connections = {}
local startTime = os.time()

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
--// PLAYER ESP
-------------------------------------------------------

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

local function removeHighlight(tbl, obj)
    if tbl[obj] then
        tbl[obj]:Destroy()
        tbl[obj] = nil
    end
end

local function setupPlayer(player)
    if player == LocalPlayer then return end
    player.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        if ESP_ENABLED then addHighlight(player, char) end
    end)

    if player.Character then
        if ESP_ENABLED then addHighlight(player, player.Character) end
    end
end

for _, player in ipairs(Players:GetPlayers()) do setupPlayer(player) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(function(p) removeHighlight(playerHighlights, p) end)

local function toggleESP(state)
    ESP_ENABLED = state
    if not state then
        for _, h in pairs(playerHighlights) do h:Destroy() end
        table.clear(playerHighlights)
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then addHighlight(player, player.Character) end
        end
    end
end

-------------------------------------------------------
--// NPC & ITEM ESP
-------------------------------------------------------

local function isValidNPC(obj)
    return obj:IsA("Model") and not isPlayerCharacter(obj) and 
           obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart")
end

local function addNpcHighlight(obj)
    if npcHighlights[obj] or obj:FindFirstChild("NpcHighlight") then return end
    if not isValidNPC(obj) then return end

    local hl = Instance.new("Highlight")
    hl.Name = "NpcHighlight"
    hl.FillColor = Color3.fromRGB(0, 120, 255)
    hl.OutlineColor = Color3.fromRGB(0, 200, 255)
    hl.FillTransparency = 0.3
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = obj
    hl.Parent = obj
    npcHighlights[obj] = hl
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

local function isValidItem(obj)
    if obj:IsDescendantOf(LocalPlayer.Character or {}) then return false end
    if isPlayerCharacter(obj) or obj:FindFirstChildOfClass("Humanoid") then return false end
    return obj:IsA("Tool") or (obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart")) or obj:IsA("BasePart")
end

local function addItemHighlight(obj)
    if itemHighlights[obj] or obj:FindFirstChild("ItemHighlight") then return end
    if not isValidItem(obj) then return end

    local hl = Instance.new("Highlight")
    hl.Name = "ItemHighlight"
    hl.FillColor = Color3.fromRGB(255, 255, 0)
    hl.OutlineColor = Color3.fromRGB(255, 255, 0)
    hl.FillTransparency = 0.25
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Adornee = obj
    hl.Parent = obj
    itemHighlights[obj] = hl
end

local function toggleItemESP(state)
    ITEM_ESP_ENABLED = state
    if not state then
        for _, h in pairs(itemHighlights) do h:Destroy() end
        table.clear(itemHighlights)
    else
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if isValidItem(obj) then addItemHighlight(obj) end
        end
    end
end

-------------------------------------------------------
--// VISUAL MODS
-------------------------------------------------------

local function toggleNoGrass(state)
    NO_GRASS_ENABLED = state
    local terrain = Workspace:FindFirstChild("Terrain")
    if terrain then terrain.Decoration = not state end
end

local function toggleNoLeaves(state)
    NO_LEAVES_ENABLED = state
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if isLeafPart(obj) then
            if state then
                if not originalLeafTransparencies[obj] then
                    originalLeafTransparencies[obj] = obj.Transparency
                end
                obj.Transparency = 1
            elseif originalLeafTransparencies[obj] then
                obj.Transparency = originalLeafTransparencies[obj]
                originalLeafTransparencies[obj] = nil
            end
        end
    end
end

local function toggleAntiRecoil(state)
    ANTI_RECOIL_ENABLED = state
    if connections.recoil then connections.recoil:Disconnect() end

    if state then
        connections.recoil = RunService.RenderStepped:Connect(function()
            for _, v in ipairs(Camera:GetDescendants()) do
                if (v:IsA("NumberValue") or v:IsA("Vector3Value")) and
                   (v.Name:lower():find("recoil") or v.Name:lower():find("kick")) then
                    if v:IsA("NumberValue") then v.Value = 0 end
                    if v:IsA("Vector3Value") then v.Value = Vector3.zero end
                end
            end

            if LocalPlayer.Character then
                for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, v in ipairs(tool:GetDescendants()) do
                            if v:IsA("NumberValue") or v:IsA("Vector3Value") or v:IsA("DoubleConstrainedValue") then
                                local name = v.Name:lower()
                                if name:find("recoil") or name:find("kick") or name:find("climb") then
                                    if v:IsA("NumberValue") or v:IsA("DoubleConstrainedValue") then v.Value = 0 end
                                    if v:IsA("Vector3Value") then v.Value = Vector3.zero end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-------------------------------------------------------
--// GUI
-------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "PD_CHAMS_LITE"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 520)  -- Increased height for slider
frame.Position = UDim2.new(0.1, 0, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

-- Top accent
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

local uptimeLabel = Instance.new("TextLabel")
uptimeLabel.Size = UDim2.new(0, 90, 0, 30)
uptimeLabel.Position = UDim2.new(1, -104, 0, 8)
uptimeLabel.BackgroundTransparency = 1
uptimeLabel.Text = "00:00:00"
uptimeLabel.TextColor3 = Color3.fromRGB(170, 170, 175)
uptimeLabel.TextSize = 13
uptimeLabel.Font = Enum.Font.SourceSansSemibold
uptimeLabel.TextXAlignment = Enum.TextXAlignment.Right
uptimeLabel.Parent = frame

local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -20, 0, 16)
credit.Position = UDim2.new(0, 14, 0, 38)
credit.BackgroundTransparency = 1
credit.Text = "Made with ❤️"
credit.TextColor3 = Color3.fromRGB(200, 200, 200)
credit.TextSize = 11
credit.Font = Enum.Font.SourceSansItalic
credit.TextXAlignment = Enum.TextXAlignment.Left
credit.Parent = frame

-- Button Creator
local function makeButton(text, yOffset)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -20, 0, 36)
    container.Position = UDim2.new(0, 10, 0, yOffset)
    container.BackgroundColor3 = Color3.fromRGB(26, 26, 28)
    container.BorderSizePixel = 0
    container.Parent = frame

    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 4, 1, 0)
    indicator.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
    indicator.BorderSizePixel = 0
    indicator.Parent = container

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -14, 1, 0)
    btn.Position = UDim2.new(0, 10, 0, 0)
    btn.BackgroundTransparency = 1
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(170, 170, 175)
    btn.TextSize = 14
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = container

    return btn, indicator
end

-- Create Toggle Buttons
local toggles = {}
local y = 70
for _, data in ipairs({
    {"Player ESP", toggleESP},
    {"Item ESP", toggleItemESP},
    {"NPC ESP", toggleNpcESP},
    {"No Grass", toggleNoGrass},
    {"No Leaves", toggleNoLeaves},
    {"Anti Recoil", toggleAntiRecoil},
}) do
    local btn, ind = makeButton(data[1], y)
    toggles[data[1]] = {button = btn, indicator = ind, toggleFunc = data[2]}
    y += 42
end

-------------------------------------------------------
--// WORLD AMBIENCE SLIDER
-------------------------------------------------------

local ambienceLabel = Instance.new("TextLabel")
ambienceLabel.Size = UDim2.new(1, -20, 0, 20)
ambienceLabel.Position = UDim2.new(0, 14, 0, y + 10)
ambienceLabel.BackgroundTransparency = 1
ambienceLabel.Text = "Ambience: " .. string.format("%.1f", Lighting.ClockTime) .. "h"
ambienceLabel.TextColor3 = Color3.fromRGB(140, 140, 145)
ambienceLabel.TextSize = 13
ambienceLabel.Font = Enum.Font.SourceSansSemibold
ambienceLabel.TextXAlignment = Enum.TextXAlignment.Left
ambienceLabel.Parent = frame

local sliderBackground = Instance.new("Frame")
sliderBackground.Size = UDim2.new(1, -28, 0, 6)
sliderBackground.Position = UDim2.new(0, 14, 0, y + 38)
sliderBackground.BackgroundColor3 = Color3.fromRGB(35, 35, 38)
sliderBackground.BorderSizePixel = 0
sliderBackground.Parent = frame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(Lighting.ClockTime / 24, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(130, 45, 230)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBackground

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 12, 0, 12)
sliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
sliderButton.Position = UDim2.new(Lighting.ClockTime / 24, 0, 0.5, 0)
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.BorderSizePixel = 0
sliderButton.Text = ""
sliderButton.Parent = sliderBackground

local sliderDragging = false

local function updateSlider(inputPosition)
    local relativeX = inputPosition.X - sliderBackground.AbsolutePosition.X
    local percentage = math.clamp(relativeX / sliderBackground.AbsoluteSize.X, 0, 1)
    
    sliderButton.Position = UDim2.new(percentage, 0, 0.5, 0)
    sliderFill.Size = UDim2.new(percentage, 0, 1, 0)
    
    local targetTime = percentage * 24
    Lighting.ClockTime = targetTime
    ambienceLabel.Text = "Ambience: " .. string.format("%.1f", targetTime) .. "h"
end

sliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateSlider(input.Position)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = false
    end
end)

-------------------------------------------------------
--// STATUS + BUTTON LOGIC + DRAGGING
-------------------------------------------------------

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -28, 0, 26)
statusLabel.Position = UDim2.new(0, 14, 1, -40)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Undetectable"
statusLabel.TextColor3 = Color3.fromRGB(0, 230, 115)
statusLabel.TextSize = 13
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

local function updateIndicator(btnData, state)
    if state then
        btnData.indicator.BackgroundColor3 = Color3.fromRGB(130, 45, 230)
        btnData.button.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        btnData.indicator.BackgroundColor3 = Color3.fromRGB(45, 45, 48)
        btnData.button.TextColor3 = Color3.fromRGB(170, 170, 175)
    end
end

for name, data in pairs(toggles) do
    data.button.MouseButton1Click:Connect(function()
        local newState = not (name == "Player ESP" and ESP_ENABLED or
                            name == "Item ESP" and ITEM_ESP_ENABLED or
                            name == "NPC ESP" and NPC_ESP_ENABLED or
                            name == "No Grass" and NO_GRASS_ENABLED or
                            name == "No Leaves" and NO_LEAVES_ENABLED or
                            name == "Anti Recoil" and ANTI_RECOIL_ENABLED)

        data.toggleFunc(newState)
        updateIndicator(data, newState)
    end)
end

-- Dragging
local dragging, dragStart, startPos
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
end)

-- M to toggle UI
UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.M then
        UI_VISIBLE = not UI_VISIBLE
        gui.Enabled = UI_VISIBLE
    end
end)

-- Uptime
RunService.RenderStepped:Connect(function()
    local diff = os.time() - startTime
    uptimeLabel.Text = string.format("%02d:%02d:%02d", 
        math.floor(diff/3600), math.floor((diff%3600)/60), diff%60)
end)

print("✅ PD-CHAMS-LITE Loaded")
