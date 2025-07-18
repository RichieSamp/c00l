--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

--// Global containers
getgenv().ESPNames = {}
getgenv().Chams = {}

--// Cleanup Function
local function ClearESP(player)
    if ESPNames[player] then
        pcall(function() ESPNames[player]:Remove() end)
        ESPNames[player] = nil
    end
    if Chams[player] and Chams[player]:IsA("Highlight") then
        pcall(function() Chams[player]:Destroy() end)
        Chams[player] = nil
    end
end

--// Create ESP (username + chams)
local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPNames[player] then return end

    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    -- Username label
    local label = Drawing.new("Text")
    label.Text = player.Name
    label.Size = 16
    label.Center = true
    label.Outline = true
    label.Color = Color3.fromRGB(255, 255, 255)
    label.Visible = false
    ESPNames[player] = label

    -- Chams
    local highlight = Instance.new("Highlight")
    highlight.Adornee = character
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.4
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = character
    Chams[player] = highlight
end

--// Update ESP Positions
RunService.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    for player, label in pairs(ESPNames) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if char and hrp and hrp:IsDescendantOf(workspace) then
            local pos, visible = cam:WorldToViewportPoint(hrp.Position + Vector3.new(0, 2.5, 0))
            if visible then
                label.Position = Vector2.new(pos.X, pos.Y)
                label.Visible = true
            else
                label.Visible = false
            end
        else
            label.Visible = false
        end
    end
end)

--// Refresh ESP Every 5 Seconds
task.spawn(function()
    while true do
        for player in Players:GetPlayers() do
            task.spawn(function()
                ClearESP(player)
                task.wait(0.1)
                CreateESP(player)
            end)
        end
        task.wait(5)
    end
end)

--// Clean up on leave
Players.PlayerRemoving:Connect(ClearESP)

--// UNLOAD BUTTON UI (Bottom Left)
local buttonGui = Instance.new("ScreenGui", game.CoreGui)
buttonGui.Name = "ESP_Unload_GUI"

local unloadBtn = Instance.new("TextButton", buttonGui)
unloadBtn.Size = UDim2.new(0, 120, 0, 40)
unloadBtn.Position = UDim2.new(0, 10, 1, -50)
unloadBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
unloadBtn.BorderSizePixel = 0
unloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadBtn.Text = "Unload ESP"
unloadBtn.Font = Enum.Font.GothamBold
unloadBtn.TextSize = 16
unloadBtn.AutoButtonColor = true

unloadBtn.MouseButton1Click:Connect(function()
    for player in Players:GetPlayers() do
        ClearESP(player)
    end
    ESPNames = nil
    Chams = nil
    if buttonGui then buttonGui:Destroy() end
    collectgarbage("collect")
end)
