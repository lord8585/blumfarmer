-- Services
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-- Configuration
local TOGGLE_KEYBIND = Enum.KeyCode.B 
local isThermalActive = false
local currentDarknessPercent = 0.5
local activeHighlights = {}
local workspaceConnections = {} -- Holds live event listeners

-- Min/Max Brightness values for the slider math
local MIN_BRIGHTNESS = 0     
local MAX_BRIGHTNESS = -0.5  

-- 1. Create Main UI Elements
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ThermalVisionUI"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = playerGui

-- Main Container Frame (Draggable)
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 110)
mainFrame.Position = UDim2.new(0.5, -90, 0, 20)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Active = true 
mainFrame.Parent = screenGui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8)
uiCorner.Parent = mainFrame

-- Toggle Button
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, 0, 0, 40)
toggleButton.BackgroundTransparency = 1
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "THERMAL: OFF"
toggleButton.TextColor3 = Color3.fromRGB(200, 200, 200)
toggleButton.TextSize = 14
toggleButton.Parent = mainFrame

-- Keybind Label Indicator
local keybindLabel = Instance.new("TextLabel")
keybindLabel.Size = UDim2.new(1, 0, 0, 15)
keybindLabel.Position = UDim2.new(0, 0, 0, 35)
keybindLabel.BackgroundTransparency = 1
keybindLabel.Font = Enum.Font.Gotham
keybindLabel.Text = "[Keybind: " .. TOGGLE_KEYBIND.Name .. "]"
keybindLabel.TextColor3 = Color3.fromRGB(120, 120, 125)
keybindLabel.TextSize = 10
keybindLabel.Parent = mainFrame

-- 2. Create Slider UI Elements (Darkness Control)
local sliderFrame = Instance.new("Frame")
sliderFrame.Size = UDim2.new(0, 150, 0, 6)
sliderFrame.Position = UDim2.new(0.5, -75, 0, 75)
sliderFrame.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
sliderFrame.BorderSizePixel = 0
sliderFrame.Parent = mainFrame

local sliderCorner = Instance.new("UICorner")
sliderCorner.CornerRadius = UDim.new(1, 0)
sliderCorner.Parent = sliderFrame

local sliderButton = Instance.new("ImageButton")
sliderButton.Size = UDim2.new(0, 16, 0, 16)
sliderButton.Position = UDim2.new(0.5, -8, 0.5, -8) 
sliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderButton.BorderSizePixel = 0
sliderButton.Parent = sliderFrame

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(1, 0)
buttonCorner.Parent = sliderButton

local sliderLabel = Instance.new("TextLabel")
sliderLabel.Size = UDim2.new(1, 0, 0, 15)
sliderLabel.Position = UDim2.new(0, 0, 0, 88)
sliderLabel.BackgroundTransparency = 1
sliderLabel.Font = Enum.Font.Gotham
sliderLabel.Text = "Darkness: 50%"
sliderLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
sliderLabel.TextSize = 10
sliderLabel.Parent = mainFrame

-- 3. Visual Environment Setup
local thermalOverlay = Instance.new("Frame")
thermalOverlay.Size = UDim2.new(1, 0, 1, 0)
thermalOverlay.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
thermalOverlay.BackgroundTransparency = 1 
thermalOverlay.ZIndex = -10
thermalOverlay.Parent = screenGui

local colorCorrection = Instance.new("ColorCorrectionEffect")
colorCorrection.Brightness = 0
colorCorrection.Contrast = 0
colorCorrection.Saturation = 0
colorCorrection.Parent = Lighting

-- Math helper for calculating brightness levels
local function getTargetBrightness()
	return MIN_BRIGHTNESS + (currentDarknessPercent * (MAX_BRIGHTNESS - MIN_BRIGHTNESS))
end

-- 4. Thermal Live Targeting Logic
local function applyThermalGlow(model)
	if not model or model == localPlayer.Character or activeHighlights[model] then return end
	
	local highlight = Instance.new("Highlight")
	highlight.Name = "ThermalGlow"
	highlight.FillColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0                         
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255) 
	highlight.OutlineTransparency = 0
	highlight.DepthMode = Enum.HighlightDepthMode.Occluded 
	
	highlight.Adornee = model
	highlight.Parent = model
	
	activeHighlights[model] = highlight
end

local function removeThermalGlow(model)
	if activeHighlights[model] then
		activeHighlights[model]:Destroy()
		activeHighlights[model] = nil
	end
end

local function clearAllGlows()
	for model, highlight in pairs(activeHighlights) do
		if highlight then highlight:Destroy() end
	end
	activeHighlights = {}
end

local function updateAtmosphere(smooth)
	if not isThermalActive then return end
	
	local targetBrightness = getTargetBrightness()
	if smooth then
		TweenService:Create(colorCorrection, TweenInfo.new(0.1), {
			Brightness = targetBrightness,
			Contrast = 0.55,
			Saturation = -1
		}):Play()
	else
		colorCorrection.Brightness = targetBrightness
		colorCorrection.Contrast = 0.55
		colorCorrection.Saturation = -1
	end
end

-- Live Listeners for Workspace Changes
local function startLiveTracking()
	-- Scan existing objects
	for _, desc in ipairs(Workspace:GetDescendants()) do
		if desc:IsA("Humanoid") then
			applyThermalGlow(desc.Parent)
		end
	end

	-- Listen for new objects spawning live
	workspaceConnections.Added = Workspace.DescendantAdded:Connect(function(desc)
		if desc:IsA("Humanoid") then
			-- Brief delay ensures the model fully initializes before drawing the highlight
			task.wait(0.05)
			if isThermalActive then
				applyThermalGlow(desc.Parent)
			end
		end
	end)

	-- Clean up if an entity leaves workspace/despawns
	workspaceConnections.Removing = Workspace.DescendantRemoving:Connect(function(desc)
		if desc:IsA("Humanoid") then
			removeThermalGlow(desc.Parent)
		end
	end)
end

local function stopLiveTracking()
	for _, connection in pairs(workspaceConnections) do
		if connection then connection:Disconnect() end
	end
	workspaceConnections = {}
end

-- 5. Toggle Mechanics
local function setThermalState(active)
	isThermalActive = active
	
	if isThermalActive then
		toggleButton.Text = "THERMAL: ON"
		toggleButton.TextColor3 = Color3.fromRGB(255, 100, 100)
		
		TweenService:Create(thermalOverlay, TweenInfo.new(0.15), {BackgroundTransparency = 0.45}):Play()
		updateAtmosphere(true)
		
		startLiveTracking()
	else
		toggleButton.Text = "THERMAL: OFF"
		toggleButton.TextColor3 = Color3.fromRGB(200, 200, 200)
		
		TweenService:Create(thermalOverlay, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
		TweenService:Create(colorCorrection, TweenInfo.new(0.15), {
			Brightness = 0,
			Contrast = 0,
			Saturation = 0
		}):Play()
		
		stopLiveTracking()
		clearAllGlows()
	end
end

-- 6. Dragging Logic for the UI Frame
local dragToggle, dragStart, startPos
local function updateDragInput(input)
	local delta = input.Position - dragStart
	local targetPosition = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	TweenService:Create(mainFrame, TweenInfo.new(0.05), {Position = targetPosition}):Play()
end

mainFrame.InputBegan:Connect(function(input)
	if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
		dragToggle = true
		dragStart = input.Position
		startPos = mainFrame.Position
		
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragToggle = false
			end
		end)
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		updateDragInput(input)
	end
end)

-- 7. Slider Dragging Logic
local sliderDragging = false

sliderButton.MouseButton1Down:Connect(function()
	sliderDragging = true
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		sliderDragging = false
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local sliderWidth = sliderFrame.AbsoluteSize.X
		local mouseX = input.Position.X
		local relativeX = mouseX - sliderFrame.AbsolutePosition.X
		
		local percentage = math.clamp(relativeX / sliderWidth, 0, 1)
		currentDarknessPercent = percentage
		
		sliderButton.Position = UDim2.new(percentage, -8, 0.5, -8)
		sliderLabel.Text = "Darkness: " .. math.round(percentage * 100) .. "%"
		
		updateAtmosphere(false)
	end
end)

-- 8. Event Connections
toggleButton.MouseButton1Click:Connect(function()
	setThermalState(not isThermalActive)
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if not gameProcessed and input.KeyCode == TOGGLE_KEYBIND then
		setThermalState(not isThermalActive)
	end
end)

localPlayer.CharacterRemoving:Connect(function()
	if isThermalActive then
		setThermalState(false)
	end
end)
