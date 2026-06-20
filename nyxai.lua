print([[ 
███╗   ██╗██╗   ██╗██╗  ██╗██████╗ ███████╗██╗   ██╗███████╗
████╗  ██║╚██╗ ██╔╝╚██╗██╔╝██╔══██╗██╔════╝██║   ██║██╔════╝
██╔██╗ ██║ ╚████╔╝  ╚███╔╝ ██║  ██║█████╗  ██║   ██║███████╗
██║╚██╗██║  ╚██╔╝   ██╔██╗ ██║  ██║██╔══╝  ╚██╗ ██╔╝╚════██║
██║ ╚████║   ██║   ██╔╝ ██╗██████╔╝███████╗ ╚████╔╝ ███████║
╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═════╝ ╚══════╝  ╚═══╝  ╚══════╝

       ██████╗      ██╗██████╗
       ██╔══██╗     ██║██╔══██╗
       ██████╔╝     ██║██║  ██║
       ██╔═══╝ ██   ██║██║  ██║
       ██║     ╚█████╔╝██████╔╝
       ╚═╝      ╚════╝ ╚═════╝
]])

-- =============== LINORIA LIB ===============
local repo = "https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local LP = Players.LocalPlayer

local function safeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    if not ok then warn("[NyxPJD] " .. tostring(err)) end
end

-- Anti-AFK
safeCall(function()
    local vu = game:GetService("VirtualUser")
    LP.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    end)
end)

-- Basic Anti-Detection
safeCall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then return end
        return oldNamecall(self, ...)
    end)

    setreadonly(mt, true)
end)

-- =============== ESP VARIABLES ===============
_G.ESPEnabled = false
_G.BoxESPEnabled = false
_G.BoxFillEnabled = false
_G.HealthBarEnabled = false
_G.NameESPEnabled = false
_G.DistanceEnabled = false
_G.TracersEnabled = false
_G.LookDirectionEnabled = false
_G.ItemESPEnabled = false

_G.MaxDistance = 1000
_G.ItemMaxDistance = 500

-- =============== DRAWING HELPERS ===============
local BoxDrawings = {}
local ItemDrawings = {}

local function newLine(thick, color)
    local l = Drawing.new("Line")
    l.Thickness = thick or 1
    l.Color = color or Color3.new(1,1,1)
    l.Visible = false
    return l
end

local function newSquare(color, filled, trans)
    local s = Drawing.new("Square")
    s.Color = color
    s.Filled = filled
    s.Transparency = trans or 1
    s.Visible = false
    return s
end

local function newText(color, size)
    local t = Drawing.new("Text")
    t.Color = color
    t.Size = size or 16
    t.Center = true
    t.Outline = true
    t.Visible = false
    return t
end

-- =============== CLEANUP ===============
local function cleanupESP(char)
    if BoxDrawings[char] then
        for _, v in pairs(BoxDrawings[char]) do pcall(function() v:Remove() end) end
        BoxDrawings[char] = nil
    end
end

-- =============== PLAYER BOX ESP ===============
local function createBoxESP(character)
    if BoxDrawings[character] then return end

    local player = Players:GetPlayerFromCharacter(character)
    if not player then return end

    local drawings = {
        top = newLine(2), bottom = newLine(2), left = newLine(2), right = newLine(2),
        fill = newSquare(Color3.new(1,1,1), true, 0.3),
        hBG = newSquare(Color3.new(0,0,0), true, 0.5),
        hBar = newSquare(Color3.new(0,1,0), true, 1),
        name = newText(Color3.new(1,1,1), 16),
        dist = newText(Color3.new(1,1,1), 14),
        tracer = newLine(1)
    }

    BoxDrawings[character] = drawings

    RS.RenderStepped:Connect(function()
        if not _G.ESPEnabled or not _G.BoxESPEnabled then
            for _, d in pairs(drawings) do d.Visible = false end
            return
        end

        local root = character:FindFirstChild("HumanoidRootPart")
        local hum = character:FindFirstChildOfClass("Humanoid")
        if not root or not hum then
            cleanupESP(character)
            return
        end

        local lRoot = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not lRoot then return end

        local dist = (root.Position - lRoot.Position).Magnitude
        if dist > _G.MaxDistance then
            for _, d in pairs(drawings) do d.Visible = false end
            return
        end

        local cam = workspace.CurrentCamera
        local rp, onScreen = cam:WorldToViewportPoint(root.Position)
        if not onScreen then
            for _, d in pairs(drawings) do d.Visible = false end
            return
        end

        local top = cam:WorldToViewportPoint(root.Position + Vector3.new(0, 3, 0))
        local bottom = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
        local h = math.abs(top.Y - bottom.Y)
        local w = h / 2
        local x = rp.X

        -- Box
        drawings.top.From = Vector2.new(x - w/2, top.Y)
        drawings.top.To = Vector2.new(x + w/2, top.Y)
        drawings.bottom.From = Vector2.new(x - w/2, bottom.Y)
        drawings.bottom.To = Vector2.new(x + w/2, bottom.Y)
        drawings.left.From = Vector2.new(x - w/2, top.Y)
        drawings.left.To = Vector2.new(x - w/2, bottom.Y)
        drawings.right.From = Vector2.new(x + w/2, top.Y)
        drawings.right.To = Vector2.new(x + w/2, bottom.Y)

        for _, line in pairs({drawings.top, drawings.bottom, drawings.left, drawings.right}) do
            line.Visible = true
        end

        drawings.name.Text = player.DisplayName
        drawings.name.Position = Vector2.new(x, top.Y - 25)
        drawings.name.Visible = _G.NameESPEnabled

        drawings.dist.Text = math.floor(dist) .. " studs"
        drawings.dist.Position = Vector2.new(x, bottom.Y + 15)
        drawings.dist.Visible = _G.DistanceEnabled
    end)
end

-- =============== ITEM ESP ===============
local RareItems = {"EDF","Military","Armor","Helmet","Vest","AK","M4","Sniper","Rifle","Core","Medical","Stimulant"}

local function isRare(name)
    name = name:upper()
    for _, v in ipairs(RareItems) do
        if name:find(v) then return true end
    end
    return false
end

local function createItemESP(item)
    if ItemDrawings[item] then return end

    local nameText = newText(isRare(item.Name) and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255,255,255), 14)
    local distText = newText(Color3.fromRGB(200,200,200), 12)

    nameText.Text = item.Name
    ItemDrawings[item] = {nameText, distText}

    task.spawn(function()
        while item.Parent and ItemDrawings[item] do
            task.wait(0.1)
            if not _G.ItemESPEnabled then
                nameText.Visible = false
                distText.Visible = false
                continue
            end

            local root = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
            if not root then continue end

            local pos = (item.PrimaryPart and item.PrimaryPart.Position) or (item:FindFirstChild("Handle") and item.Handle.Position)
            if not pos then continue end

            local dist = (pos - root.Position).Magnitude
            if dist > _G.ItemMaxDistance then
                nameText.Visible = false
                distText.Visible = false
                continue
            end

            local cam = workspace.CurrentCamera
            local vp, onScreen = cam:WorldToViewportPoint(pos)
            if not onScreen then
                nameText.Visible = false
                distText.Visible = false
                continue
            end

            nameText.Position = Vector2.new(vp.X, vp.Y - 10)
            distText.Position = Vector2.new(vp.X, vp.Y + 10)
            distText.Text = math.floor(dist) .. " studs"

            nameText.Visible = true
            distText.Visible = true
        end
    end)
end

-- =============== CONNECTIONS ===============
Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function(char)
        task.wait(1)
        createBoxESP(char)
    end)
end)

for _, plr in ipairs(Players:GetPlayers()) do
    if plr.Character then createBoxESP(plr.Character) end
    plr.CharacterAdded:Connect(function(char)
        task.wait(1)
        createBoxESP(char)
    end)
end

workspace.DescendantAdded:Connect(function(obj)
    if _G.ItemESPEnabled and (obj:IsA("Tool") or (obj:IsA("Model") and obj:FindFirstChild("Handle"))) then
        task.wait(0.3)
        createItemESP(obj)
    end
end)

-- =============== UI ===============
local Window = Library:CreateWindow({
    Title = "NyxDevs — Project Delta V3.0",
    Center = true,
    AutoShow = true
})

local Tabs = {
    Visual = Window:AddTab("Visual"),
    Aimbot = Window:AddTab("Aimbot"),
    Misc = Window:AddTab("Misc"),
    ["UI Settings"] = Window:AddTab("UI Settings")
}

local VisualTab = Tabs.Visual:AddLeftGroupbox("ESP Settings")

VisualTab:AddToggle("ESPEnabled", {Text = "Master ESP Toggle", Default = false, Callback = function(v) _G.ESPEnabled = v end})
VisualTab:AddToggle("BoxESP", {Text = "Box ESP", Default = false, Callback = function(v) _G.BoxESPEnabled = v end})
VisualTab:AddToggle("NameESP", {Text = "Name ESP", Default = false, Callback = function(v) _G.NameESPEnabled = v end})
VisualTab:AddToggle("DistanceESP", {Text = "Distance ESP", Default = false, Callback = function(v) _G.DistanceEnabled = v end})
VisualTab:AddToggle("ItemESP", {Text = "Item ESP", Default = false, Callback = function(v) _G.ItemESPEnabled = v end})

Library:Notify("NyxPJD V3.0 Loaded Successfully!", 5)
