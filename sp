--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--// Container
local ESPObjects = {}

--// Cleanup Old ESP
local function ClearESP(player)
    if ESPObjects[player] then
        ESPObjects[player].box:Remove()
        ESPObjects[player].name:Remove()
        ESPObjects[player] = nil
    end
end

--// Create ESP for One Player
local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end

    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local nameLabel = Drawing.new("Text")
    nameLabel.Text = player.Name
    nameLabel.Size = 16
    nameLabel.Center = true
    nameLabel.Outline = true
    nameLabel.Color = Color3.fromRGB(255, 255, 255)
    nameLabel.Visible = false

    local box = Drawing.new("Square")
    box.Color = Color3.fromRGB(255, 0, 0)
    box.Thickness = 1.5
    box.Transparency = 1
    box.Visible = false

    ESPObjects[player] = {
        name = nameLabel,
        box = box
    }
end

--// Update ESP Positions Per Frame
RunService.RenderStepped:Connect(function()
    for player, esp in pairs(ESPObjects) do
        local character = player.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if character and hrp and hrp:IsDescendantOf(workspace) then
            local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
                local scale = 1 / (distance * 0.04)
                local width = 80 * scale
                local height = 120 * scale

                esp.box.Size = Vector2.new(width, height)
                esp.box.Position = Vector2.new(pos.X - width / 2, pos.Y - height / 2)
                esp.box.Visible = true

                esp.name.Position = Vector2.new(pos.X, pos.Y - height / 2 - 14)
                esp.name.Visible = true
            else
                esp.box.Visible = false
                esp.name.Visible = false
            end
        else
            esp.box.Visible = false
            esp.name.Visible = false
        end
    end
end)

--// Refresh ESP Every 5 Seconds
task.spawn(function()
    while true do
        -- Cleanup invalid entries
        for player in pairs(ESPObjects) do
            if not Players:FindFirstChild(player.Name) then
                ClearESP(player)
            end
        end

        -- Rebuild ESP for current valid players
        for _, player in ipairs(Players:GetPlayers()) do
            task.spawn(function()
                ClearESP(player) -- Force recreate
                task.wait(0.1)
                CreateESP(player)
            end)
        end

        task.wait(5)
    end
end)

--// Auto-cleanup if player leaves
Players.PlayerRemoving:Connect(function(player)
    ClearESP(player)
end)
