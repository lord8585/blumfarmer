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
local NO_SWAY_ENABLED = false
local ANTI_RECOIL_ENABLED = false
local AIMLOCK_ENABLED = false
local UI_VISIBLE = true

local AIMLOCK_KEY = Enum.UserInputType.MouseButton2 -- Default Right Click
local AIMLOCK_SMOOTHNESS = 0.2 -- Smoothing factor for tracking transition

--// Storage
local playerHighlights = {}
local itemHighlights = {}
local npcHighlights = {}
local originalLeafTransparencies = {}
local cameraRenderConnection = nil
local recoilRenderConnection = nil
local aimlockRenderConnection = nil
local isAiming = false
local startTime = os.time()

-------------------------------------------------------
--// HELPER FUNCTIONS
-------------------------------------------------------

local function isPlayerCharacter(model)
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character == model then
            return true
        end
    end
    return false
end

local function isLeafPart(obj)
    if obj:IsA("BasePart") and (obj.Name:lower():match("leaf") or obj.Name:lower():match("leaves") or obj.Name:lower():match("foliage")) then
        return true
    end
    return false
end

-- Calculates the player closest to the screen center
local function getClosestPlayerToCenter()
    local closestPlayer = nil
    local shortestDistance = math.huge
    local screenCenter = Camera.ViewportSize / 2

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChildOfClass("Humanoid") then
            if player.Character.Humanoid.Health > 0 then
                local head = player.Character.Head
                local vector, onScreen = Camera:WorldToViewportPoint(head.Position)

                if onScreen then
                    local distance = (Vector2.new(vector.X, vector.Y) - screenCenter).Magnitude
                    if distance < shortestDistance then
                        shortestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

-------------------------------------------------------
--// PLAYER ESP
-------------------------------------------------------

local function addHighlight(player, character)
    if player == LocalPlayer then return end
    if not character then return end
    
    if character:FindFirstChild("PlayerHighlight") then return end

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

local function removePlayerHighlight(player)
    if playerHighlights[player] then
        playerHighlights[player]:Destroy()
        playerHighlights[player] = nil
    end
end

local function setupPlayer(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(0.3)
        if ESP_ENABLED then
            addHighlight(player, char)
        end
    end)

    player.CharacterRemoving:Connect(function()
        removePlayerHighlight(player)
    end)

    if player.Character then
        if ESP_ENABLED then
            addHighlight(player, player.Character)
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    setupPlayer(player)
end

Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(removePlayerHighlight)

local function toggleESP(state)
    ESP_ENABLED = state

    if not state then
        for _, h in pairs(playerHighlights) do
            h:Destroy()
        end
        table.clear(playerHighlights)
    else
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                addHighlight(player, player.Character)
            end
        end
    end
end

-------------------------------------------------------
--// NPC ESP
---------------------------------------

local function isValidNPC(obj)
    if not obj:IsA("Model") then return false end
    if isPlayerCharacter(obj) then return false end
    
    if obj:FindFirstChildOfClass("Humanoid") and obj:FindFirstChild("HumanoidRootPart") then
        return true
    end
    
    return false
end

local function addNpcHighlight(obj)
    if npcHighlights[obj] or obj:FindFirstChild("NpcHighlight") then return end
    if not isValidNPC(obj) then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "NpcHighlight"
    highlight.FillColor = Color3.fromRGB(0, 120, 255)
    highlight.OutlineColor = Color3.fromRGB(0, 200, 255)
    highlight.FillTransparency = 0.3
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = obj
    highlight.Parent = obj

    npcHighlights[obj] = highlight
end

local function removeNpcHighlight(obj)
    if npcHighlights[obj] then
        npcHighlights[obj]:Destroy()
        npcHighlights[obj] = nil
    end
end

local function scanNpcs()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if NPC_ESP_ENABLED and isValidNPC(obj) then
            addNpcHighlight(obj)
        end
    end
end

local function toggleNpcESP(state)
    NPC_ESP_ENABLED = state

    if not state then
        for _, h in pairs(npcHighlights) do
            h:Destroy()
        end
        table.clear(npcHighlights)
    else
        scanNpcs()
    end
end

-------------------------------------------------------
--// ITEM ESP
-------------------------------------------------------

local function isValidItem(obj)
    if obj:IsDescendantOf(Workspace:FindFirstChild("Characters") or {}) then
        return false
    end

    if obj:FindFirstChildOfClass("Humanoid") or obj.Parent:FindFirstChildOfClass("Humanoid") then
        return false
    end

    if obj:IsA("Tool") then
        return true
    end

    if obj:IsA("Model") and obj:FindFirstChildWhichIsA("BasePart") then
        return true
    end

    if obj:IsA("BasePart") and not obj:IsDescendantOf(LocalPlayer.Character or {}) then
        return true
    end

    return false
end

local function addItemHighlight(obj)
    if itemHighlights[obj] or obj:FindFirstChild("ItemHighlight") then return end
    if not isValidItem(obj) then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "ItemHighlight"
    highlight.FillColor = Color3.fromRGB(255, 255, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 0)
    highlight.FillTransparency = 0.25
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = obj
    highlight.Parent = obj

    itemHighlights[obj] = highlight
end

local function removeItemHighlight(obj)
    if itemHighlights[obj] then
        itemHighlights[obj]:Destroy()
        itemHighlights[obj] = nil
    end
end

local function scanItems()
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if ITEM_ESP_ENABLED and isValidItem(obj) then
            addItemHighlight(obj)
        end
    end
end

local function toggleItemESP(state)
    ITEM_ESP_ENABLED = state

    if not state then
        for _, h in pairs(itemHighlights) do
            h:Destroy()
        end
        table.clear(itemHighlights)
    else
        scanItems()
    end
end

-------------------------------------------------------
--// NO GRASS & NO LEAVES LOGIC
-------------------------------------------------------

local function updateGrass()
    sethiddenproperty(Workspace.Terrain, "Decoration", not NO_GRASS_ENABLED)
end

local function handleLeaf(obj, hide)
    if isLeafPart(obj) then
        if hide then
            if not originalLeafTransparencies[obj] then
                originalLeafTransparencies[obj] = obj.Transparency
            end
            obj.Transparency = 1
        else
            if originalLeafTransparencies[obj] then
                obj.Transparency = originalLeafTransparencies[obj]
                originalLeafTransparencies[obj] = nil
            else
                obj.Transparency = 0
            end
        end
    end
end

local function toggleNoGrass(state)
    NO_GRASS_ENABLED = state
    updateGrass()
end

local function toggleNoLeaves(state)
    NO_LEAVES_ENABLED = state
    for _, obj in ipairs(Workspace:GetDescendants()) do
        handleLeaf(obj, state)
    end
end

-------------------------------------------------------
--// NO SWAY ADS LOGIC
-------------------------------------------------------

local function toggleNoSway(state)
    NO_SWAY_ENABLED = state
    
    if state then
        cameraRenderConnection = RunService.RenderStepped:Connect(function()
            for _, v in ipairs(LocalPlayer:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("Vector3Value") then
                    if v.Name:lower():match("sway") or v.Name:lower():match("bob") then
                        if v:IsA("NumberValue") then v.Value = 0 end
                        if v:IsA("Vector3Value") then v.Value = Vector3.new(0,0,0) end
                    end
                end
            end
        end)
    else
        if cameraRenderConnection then
            cameraRenderConnection:Disconnect()
            cameraRenderConnection = nil
        end
    end
end

-------------------------------------------------------
--// ANTI RECOIL LOGIC
-------------------------------------------------------

local function toggleAntiRecoil(state)
    ANTI_RECOIL_ENABLED = state
    
    if state then
        recoilRenderConnection = RunService.RenderStepped:Connect(function()
            local camera = Workspace.CurrentCamera
            if camera then
                for _, v in ipairs(camera:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("Vector3Value") then
                        if v.Name:lower():match("recoil") or v.Name:lower():match("kick") then
                            if v:IsA("NumberValue") then v.Value = 0 end
                            if v:IsA("Vector3Value") then v.Value = Vector3.new(0,0,0) end
                        end
                    end
                end
            end
            
            if LocalPlayer.Character then
                for _, tool in ipairs(LocalPlayer.Character:GetChildren()) do
                    if tool:IsA("Tool") then
                        for _, v in ipairs(tool:GetDescendants()) do
							if v:IsA("NumberValue") or v:IsA("Vector3Value") or v:IsA("DoubleConstrainedValue") then
                                local name = v.Name:lower()
                                if name:match("recoil") or name:match("kick") or name:match("climb") then
                                    if v:IsA("NumberValue") or v:IsA("DoubleConstrainedValue") then v.Value = 0 end
                                    if v:IsA("Vector3Value") then v.Value = Vector3.new(0,0,0) end
                                end
                            end
                        end
                    end
                end
            end
        end)
    else
        if recoilRenderConnection then
            recoilRenderConnection:Disconnect()
            recoilRenderConnection = nil
        end
    end
end

-------------------------------------------------------
--// AIMLOCK LOGIC
-------------------------------------------------------

local function toggleAimlock(state)
    AIMLOCK_ENABLED = state
    
    if state then
        aimlockRenderConnection = RunService.RenderStepped:Connect(function()
            if isAiming then
                local targetPlayer = getClosestPlayerToCenter()
                if targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("Head") then
                    local targetPosition = targetPlayer.Character.Head.Position
                    local currentCFrame = Camera.CFrame
                    local targetCFrame = CFrame.new(currentCFrame.Position, targetPosition)
                    
                    -- Smoothly interpolate current camera matrix toward target head position
                    Camera.CFrame = currentCFrame:Lerp(targetCFrame, AIMLOCK_SMOOTHNESS)
                end
            end
        end)
    else
        if aimlockRenderConnection then
            aimlockRenderConnection:Disconnect()
            aimlockRenderConnection = nil
        end
        isAiming = false
    end
end

-- Input handlers to track hold execution states
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if AIMLOCK_ENABLED and (input.UserInputType == AIMLOCK_KEY or input.KeyCode == AIMLOCK_KEY) then
        isAiming = true
    end
end)

-- Input handlers to track release states
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == AIMLOCK_KEY or input.KeyCode == AIMLOCK_KEY then
        isAiming = false
    end
end)

-------------------------------------------------------
--// PERSISTENT RE-STREAMING LOOP
-------------------------------------------------------
task.spawn(function()
    while task.wait(0.3) do
        if ESP_ENABLED then
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and not player.Character:FindFirstChild("PlayerHighlight") then
                    addHighlight(player, player.Character)
                end
            end
        end
        if NPC_ESP_ENABLED then scanNpcs() end
        if ITEM_ESP_ENABLED then scanItems() end
    end
end)

-------------------------------------------------------
--// WORKSPACE LISTENERS
-------------------------------------------------------

Workspace.DescendantAdded:Connect(function(obj)
    task.wait(0.1)
    if ITEM_ESP_ENABLED and isValidItem(obj) then addItemHighlight(obj) end
    if NPC_ESP_ENABLED and isValidNPC(obj) then addNpcHighlight(obj) end
    if NO_LEAVES_ENABLED then handleLeaf(obj, true) end
end)

Workspace.DescendantRemoving:Connect(function(obj)
    removeItemHighlight(obj)
    removeNpcHighlight(obj)
    originalLeafTransparencies[obj] = nil
end)

-------------------------------------------------------
--// PURPLE, BLACK & GRAY UI ASSEMBLY
-------------------------------------------------------

local gui = Instance.new("ScreenGui")
gui.Name = "VapeV4_UI"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

-- Main Panel Frame (Height updated to 480 to fit the bottom status elements)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 210, 0, 480)
frame.Position = UDim2.new(0.1, 0, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Pure dark black background
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

-- Top Header Accent Line (Vibrant Purple Accent Line)
local topBarLine = Instance.new("Frame")
topBarLine.Size = UDim2.new(1, 0, 0, 3)
topBarLine.BackgroundColor3 = Color3.fromRGB(130, 45, 230) -- Dark-Purple accent theme
topBarLine.BorderSizePixel = 0
topBarLine.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -14, 0, 32)
title.Position = UDim2.new(0, 14, 0, 3)
title.BackgroundTransparency = 1
title.Text = "PD-CHAMS-LITE"
title.TextColor3 = Color3.fromRGB(245, 245, 245)
title.TextSize = 15
title.Font = Enum.Font.SourceSansBold
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

-- Uptime Counter Display in the top right corner
local uptimeLabel = Instance.new("TextLabel")
uptimeLabel.Size = UDim2.new(0, 80, 0, 32)
uptimeLabel.Position = UDim2.new(1, -94, 0, 3)
uptimeLabel.BackgroundTransparency = 1
uptimeLabel.Text = "00:00:00"
uptimeLabel.TextColor3 = Color3.fromRGB(170, 170, 175)
uptimeLabel.TextSize = 12
uptimeLabel.Font = Enum.Font.SourceSansSemibold
uptimeLabel.TextXAlignment = Enum.TextXAlignment.Right
uptimeLabel.Parent = frame

-- Small text credits component updated to bright white
local credit = Instance.new("TextLabel")
credit.Size = UDim2.new(1, -14, 0, 16)
credit.Position = UDim2.new(0, 14, 0, 30)
credit.BackgroundTransparency = 1
credit.Text = "Credits To Python"
credit.TextColor3 = Color3.fromRGB(255, 255, 255) -- Bright White
credit.TextSize = 10.5
credit.Font = Enum.Font.SourceSansItalic
credit.TextXAlignment = Enum.TextXAlignment.Left
credit.Parent = frame

-- Button Generator styled to match specific custom layout
local function makeVapeButton(text, pos)
    local btnContainer = Instance.new("Frame")
    btnContainer.Size = UDim2.new(1, -20, 0, 32)
    btnContainer.Position = pos
    btnContainer.BackgroundColor3 = Color3.fromRGB(26, 26, 28) -- Sleek Dark Gray base plate
    btnContainer.BorderSizePixel = 0
    btnContainer.Parent = frame
    
    local statusIndicator = Instance.new("Frame")
    statusIndicator.Size = UDim2.new(0, 4, 1, 0)
    statusIndicator.Position = UDim2.new(0, 0, 0, 0)
    statusIndicator.BackgroundColor3 = Color3.fromRGB(45, 45, 48) -- Inactive Flat Gray indicator
    statusIndicator.BorderSizePixel = 0
    statusIndicator.Parent = btnContainer

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -14, 1, 0)
    btn.Position = UDim2.new(0, 10, 0, 0)
    btn.BackgroundTransparency = 1
    btn.TextColor3 = Color3.fromRGB(170, 170, 175) -- Muted Gray Text
    btn.Text = text
    btn.TextSize = 13
    btn.Font = Enum.Font.SourceSansSemibold
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.Parent = btnContainer

    return btn, statusIndicator
end

-- Assemble Module Controls Layout
local toggleBtn, playerInd = makeVapeButton("Player ESP", UDim2.new(0, 10, 0, 58))
local itemBtn, itemInd = makeVapeButton("Item ESP", UDim2.new(0, 10, 0, 96))
local npcBtn, npcInd = makeVapeButton("NPC ESP", UDim2.new(0, 10, 0, 134))
local grassBtn, grassInd = makeVapeButton("No Grass", UDim2.new(0, 10, 0, 172))
local leavesBtn, leavesInd = makeVapeButton("No Leaves", UDim2.new(0, 10, 0, 210))
local swayBtn, swayInd = makeVapeButton("No Sway ADS", UDim2.new(0, 10, 0, 248))
local recoilBtn, recoilInd = makeVapeButton("Anti Recoil", UDim2.new(0, 10, 0, 286))
local aimlockBtn, aimlockInd = makeVapeButton("Aimlock", UDim2.new(0, 10, 0, 324)) -- Integrated Aimlock Button

-------------------------------------------------------
--// WORLD AMBIENCE SLIDER ASSEMBLY
-------------------------------------------------------

local ambienceLabel = Instance.new("TextLabel")
ambienceLabel.Size = UDim2.new(1, -20, 0, 20)
ambienceLabel.Position = UDim2.new(0, 14, 0, 363) -- Shifted coordinates safely downward
ambienceLabel.BackgroundTransparency = 1
ambienceLabel.Text = "Ambience: " .. string.format("%.1f", Lighting.ClockTime) .. "h"
ambienceLabel.TextColor3 = Color3.fromRGB(140, 140, 145)
ambienceLabel.TextSize = 12
ambienceLabel.Font = Enum.Font.SourceSansSemibold
ambienceLabel.TextXAlignment = Enum.TextXAlignment.Left
ambienceLabel.Parent = frame

local sliderBackground = Instance.new("Frame")
sliderBackground.Size = UDim2.new(1, -24, 0, 4)
sliderBackground.Position = UDim2.new(0, 12, 0, 389) -- Shifted coordinates safely downward
sliderBackground.BackgroundColor3 = Color3.fromRGB(35, 35, 38) -- Mid-Gray slider track
sliderBackground.BorderSizePixel = 0
sliderBackground.Parent = frame

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(Lighting.ClockTime / 24, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(130, 45, 230) -- Purple bar tracking line
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBackground

local sliderButton = Instance.new("TextButton")
sliderButton.Size = UDim2.new(0, 10, 0, 10)
sliderButton.AnchorPoint = Vector2.new(0.5, 0.5)
sliderButton.Position = UDim2.new(Lighting.ClockTime / 24, 0, 0.5, 0)
sliderButton.BackgroundColor3 = Color3.fromRGB(180, 180, 185)
sliderButton.BorderSizePixel = 0
sliderButton.Text = ""
sliderButton.Parent = sliderBackground

-- Slider Control Logic
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
--// UNDETECTABLE STATUS ASSEMBLY
-------------------------------------------------------

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, -28, 0, 24)
statusLabel.Position = UDim2.new(0, 14, 1, -34)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Status: Undetectable"
statusLabel.TextColor3 = Color3.fromRGB(0, 230, 115) -- Vibrant Green status line
statusLabel.TextSize = 12
statusLabel.Font = Enum.Font.SourceSansBold
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.Parent = frame

-------------------------------------------------------
--// Dragging Engine
-------------------------------------------------------

local dragging = false
local dragStart, startPos

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
        frame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

-------------------------------------------------------
--// BUTTON CONNECTIONS & COLOR INDICATORS
-------------------------------------------------------

local function updateButtonIndicator(indicator, label, state)
    if state then
        indicator.BackgroundColor3 = Color3.fromRGB(130, 45, 230) -- Active Purple glow indicator strip
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
        indicator.BackgroundColor3 = Color3.fromRGB(45, 45, 48) -- Muted Off-Gray indicator strip
        label.TextColor3 = Color3.fromRGB(170, 170, 175)
    end
end

toggleBtn.MouseButton1Click:Connect(function()
    ESP_ENABLED = not ESP_ENABLED
    toggleESP(ESP_ENABLED)
    updateButtonIndicator(playerInd, toggleBtn, ESP_ENABLED)
end)

itemBtn.MouseButton1Click:Connect(function()
    ITEM_ESP_ENABLED = not ITEM_ESP_ENABLED
    toggleItemESP(ITEM_ESP_ENABLED)
    updateButtonIndicator(itemInd, itemBtn, ITEM_ESP_ENABLED)
end)

npcBtn.MouseButton1Click:Connect(function()
    NPC_ESP_ENABLED = not NPC_ESP_ENABLED
    toggleNpcESP(NPC_ESP_ENABLED)
    updateButtonIndicator(npcInd, npcBtn, NPC_ESP_ENABLED)
end)

grassBtn.MouseButton1Click:Connect(function()
    toggleNoGrass(not NO_GRASS_ENABLED)
    updateButtonIndicator(grassInd, grassBtn, NO_GRASS_ENABLED)
end)

leavesBtn.MouseButton1Click:Connect(function()
    toggleNoLeaves(not NO_LEAVES_ENABLED)
    updateButtonIndicator(leavesInd, leavesBtn, NO_LEAVES_ENABLED)
end)

swayBtn.MouseButton1Click:Connect(function()
    toggleNoSway(not NO_SWAY_ENABLED)
    updateButtonIndicator(swayInd, swayBtn, NO_SWAY_ENABLED)
end)

recoilBtn.MouseButton1Click:Connect(function()
    toggleAntiRecoil(not ANTI_RECOIL_ENABLED)
    updateButtonIndicator(recoilInd, recoilBtn, ANTI_RECOIL_ENABLED)
end)

aimlockBtn.MouseButton1Click:Connect(function()
    toggleAimlock(not AIMLOCK_ENABLED)
    updateButtonIndicator(aimlockInd, aimlockBtn, AIMLOCK_ENABLED)
end)

-------------------------------------------------------
--// CORE RUNTIME CLOCK CONNECTION
-------------------------------------------------------

RunService.RenderStepped:Connect(function()
    local diff = os.time() - startTime
    local hours = math.floor(diff / 3600)
    local minutes = math.floor((diff % 3600) / 60)
    local seconds = diff % 60
    uptimeLabel.Text = string.format("%02d:%02d:%02d", hours, minutes, seconds)
end)

-------------------------------------------------------
--// M KEY TO TOGGLE UI
-------------------------------------------------------

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.M then
        UI_VISIBLE = not UI_VISIBLE
        gui.Enabled = UI_VISIBLE
    end
end)
