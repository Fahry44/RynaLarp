--[[\
    Project RynaLarp v1.0 - Client-Side Avatar Customization Suite
    Target Environment: Solara V3 Executor (Luau)
    Execution: Single-File Loadstring Architecture
]]--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local InsertService = game:GetService("InsertService")

local LocalPlayer = Players.LocalPlayer

-- Cleanup UI lama jika ada
if CoreGui:FindFirstChild("RynaLarpUI") then
    CoreGui.RynaLarpUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RynaLarpUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

-- State Management
local activeStates = {
    HeadlessSelf = false,
    HeadlessAll = false,
    KorbloxSelf = false,
    KorbloxAll = false,
    Accessories = {}
}

local accessoryCatalog = {
    ["8-Bit Royal Crown"] = 114421272,
    ["Fiery Horns"] = 13919316,
    ["Frozen Horns"] = 14354243,
    ["Black Iron Horns"] = 11442145
}

-- === UI CONTAINER ===
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 480, 0, 360)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(16, 18, 26)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(45, 50, 75)
UIStroke.Thickness = 1.5
UIStroke.Parent = MainFrame

-- TopBar (Draggable)
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 42)
TopBar.BackgroundColor3 = Color3.fromRGB(22, 26, 36)
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local TopBarCorner = Instance.new("UICorner")
TopBarCorner.CornerRadius = UDim.new(0, 10)
TopBarCorner.Parent = TopBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -20, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "RYNALARP // SOLARA V3 SUITE"
TitleLabel.TextColor3 = Color3.fromRGB(230, 235, 255)
TitleLabel.TextSize = 13
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TopBar

-- Dragging Logic
local dragging, dragInput, dragStart, startPos
TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

TopBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- === TAB SYSTEM ===
local ContentContainer = Instance.new("Folder")
ContentContainer.Parent = MainFrame

local function createPanel(name)
    local frame = Instance.new("ScrollingFrame")
    frame.Name = name .. "Panel"
    frame.Size = UDim2.new(1, -20, 1, -90)
    frame.Position = UDim2.new(0, 10, 0, 80)
    frame.BackgroundTransparency = 1
    frame.BorderSizePixel = 0
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    frame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    frame.ScrollBarThickness = 4
    frame.Visible = false
    frame.Parent = ContentContainer
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 8)
    layout.Parent = frame
    
    return frame
end

local panelMods = createPanel("Mods")
local panelAccessories = createPanel("Accessories")
local panelSettings = createPanel("Settings")

-- === LOGIC CORE ===
local function applyHeadless(character, state)
    if not character then return end
    local head = character:FindFirstChild("Head")
    if head then
        head.Transparency = state and 1 or 0
        local face = head:FindFirstChildOfClass("Decal")
        if face then
            face.Transparency = state and 1 or 0
        end
    end
end

local function applyKorblox(character, state)
    if not character then return end
    local rightLeg = character:FindFirstChild("RightLowerLeg") or character:FindFirstChild("Right Leg")
    if rightLeg and rightLeg:IsA("MeshPart") then
        rightLeg.MeshId = state and "rbxassetid://90114275" or ""
    end
end

local function updateTargets()
    for _, player in ipairs(Players:GetPlayers()) do
        local char = player.Character
        if char then
            if player == LocalPlayer then
                applyHeadless(char, activeStates.HeadlessSelf)
                applyKorblox(char, activeStates.KorbloxSelf)
            else
                applyHeadless(char, activeStates.HeadlessAll)
                applyKorblox(char, activeStates.KorbloxAll)
            end
        end
    end
end

-- === UI BUILDERS ===
local function createToggle(parent, title, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 42)
    container.BackgroundColor3 = Color3.fromRGB(22, 26, 36)
    container.BorderSizePixel = 0
    container.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamMedium
    label.Text = title
    label.TextColor3 = Color3.fromRGB(200, 205, 225)
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = container
    
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Size = UDim2.new(0, 40, 0, 22)
    toggleBtn.Position = UDim2.new(1, -52, 0.5, -11)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(45, 52, 70)
    toggleBtn.Text = ""
    toggleBtn.AutoButtonColor = false
    toggleBtn.Parent = container
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = toggleBtn
    
    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(0, 16, 0, 16)
    circle.Position = UDim2.new(0, 3, 0.5, -8)
    circle.BackgroundColor3 = Color3.fromRGB(220, 225, 245)
    circle.Parent = toggleBtn
    
    local circCorner = Instance.new("UICorner")
    circCorner.CornerRadius = UDim.new(1, 0)
    circCorner.Parent = circle
    
    local active = false
    toggleBtn.MouseButton1Click:Connect(function()
        active = not active
        local targetColor = active and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(45, 52, 70)
        local targetPos = active and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
        
        TweenService:Create(toggleBtn, TweenInfo.new(0.2), {BackgroundColor3 = targetColor}):Play()
        TweenService:Create(circle, TweenInfo.new(0.2), {Position = targetPos}):Play()
        
        callback(active)
    end)
end

-- Populate Panel Mods
createToggle(panelMods, "Headless (Self)", function(state)
    activeStates.HeadlessSelf = state
    updateTargets()
end)

createToggle(panelMods, "Headless (All Players - Local)", function(state)
    activeStates.HeadlessAll = state
    updateTargets()
end)

createToggle(panelMods, "Korblox (Self)", function(state)
    activeStates.KorbloxSelf = state
    updateTargets()
end)

createToggle(panelMods, "Korblox (All Players - Local)", function(state)
    activeStates.KorbloxAll = state
    updateTargets()
end)

-- Populate Panel Accessories
for name, id in pairs(accessoryCatalog) do
    createToggle(panelAccessories, "Equip: " .. name, function(state)
        activeStates.Accessories[name] = state
        local char = LocalPlayer.Character
        if not char then return end
        
        if state then
            pcall(function()
                local asset = InsertService:LoadAsset(id)
                for _, item in ipairs(asset:GetChildren()) do
                    if item:IsA("Accessory") then
                        item.Name = "RynaLarpItem_" .. name
                        item.Parent = char
                    end
                end
            end)
        else
            for _, item in ipairs(char:GetChildren()) do
                if item.Name == "RynaLarpItem_" .. name then
                    item:Destroy()
                end
            end
        end
    end)
end

-- Settings Panel (Reset)
local resetBtn = Instance.new("TextButton")
resetBtn.Size = UDim2.new(1, 0, 0, 40)
resetBtn.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
resetBtn.Font = Enum.Font.GothamBold
resetBtn.Text = "Reset All Avatar States"
resetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
resetBtn.TextSize = 12
resetBtn.Parent = panelSettings

local resetCorner = Instance.new("UICorner")
resetCorner.CornerRadius = UDim.new(0, 6)
resetCorner.Parent = resetBtn

resetBtn.MouseButton1Click:Connect(function()
    activeStates.HeadlessSelf = false
    activeStates.HeadlessAll = false
    activeStates.KorbloxSelf = false
    activeStates.KorbloxAll = false
    activeStates.Accessories = {}
    
    local char = LocalPlayer.Character
    if char then
        applyHeadless(char, false)
        applyKorblox(char, false)
        for _, item in ipairs(char:GetChildren()) do
            if item.Name:sub(1, 13) == "RynaLarpItem_" then
                item:Destroy()
            end
        end
    end
end)

-- === NAVIGATION TABS ===
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 30)
TabBar.Position = UDim2.new(0, 10, 0, 48)
TabBar.BackgroundTransparency = 1
TabBar.Parent = MainFrame

local TabListLayout = Instance.new("UIListLayout")
TabListLayout.FillDirection = Enum.FillDirection.Horizontal
TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
TabListLayout.Padding = UDim.new(0, 6)
TabListLayout.Parent = TabBar

local function createTabButton(name, panel)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.32, 0, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(24, 28, 40)
    btn.Font = Enum.Font.GothamMedium
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(160, 170, 195)
    btn.TextSize = 11
    btn.Parent = TabBar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        panelMods.Visible = false
        panelAccessories.Visible = false
        panelSettings.Visible = false
        
        panel.Visible = true
    end)
end

createTabButton("Modifications", panelMods)
createTabButton("Accessories", panelAccessories)
createTabButton("Settings", panelSettings)
panelMods.Visible = true

-- Handle Respawns
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    if activeStates.HeadlessSelf or activeStates.HeadlessAll then
        updateTargets()
    end
end)

print("[J] RynaLarp UI Loaded via Solara V3.")
