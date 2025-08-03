local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP_Drawings = {}
local Settings = {
    Username = false,
    Box = false,
    Chams = false,
    Health = false,
    Distance = false,
    Color = Color3.fromRGB(255, 255, 255)
}

function ESP:UpdateConfig(cfg)
    for k, v in pairs(cfg) do
        if Settings[k] ~= nil then
            Settings[k] = v
        end
    end
end

function ESP:clear(player)
    if ESP_Drawings[player] then
        for _, v in pairs(ESP_Drawings[player]) do
            if typeof(v) == "Instance" then
                v:Destroy()
            elseif typeof(v) == "table" and v.Remove then
                v:Remove()
            elseif typeof(v) == "function" then
                v()
            end
        end
        ESP_Drawings[player] = nil
    end
end

function ESP:apply(player)
    if player == LocalPlayer then return end
    self:clear(player)
    ESP_Drawings[player] = {}

    local function setupESP(char)
        task.wait(0.4)
        if Settings.Username then
            local head = char:FindFirstChild("Head")
            if head then
                local gui = Instance.new("BillboardGui", char)
                gui.Name = "UsernameESP"
                gui.Adornee = head
                gui.AlwaysOnTop = true
                gui.Size = UDim2.new(0, 100, 0, 20)
                gui.StudsOffset = Vector3.new(0, 3, 0)

                local label = Instance.new("TextLabel", gui)
                label.Text = player.Name
                label.Font = Enum.Font.SourceSansBold
                label.TextColor3 = Settings.Color
                label.BackgroundTransparency = 1
                label.TextScaled = true
                label.Size = UDim2.new(1, 0, 1, 0)

                local stroke = Instance.new("UIStroke", label)
                stroke.Thickness = 0.75
                stroke.Color = Color3.new(0, 0, 0)

                ESP_Drawings[player].Name = gui
            end
        end

        if Settings.Chams then
            local hl = Instance.new("Highlight", char)
            hl.FillColor = Settings.Color
            hl.OutlineColor = Color3.new(0, 0, 0)
            hl.FillTransparency = 0.5
            hl.OutlineTransparency = 0.3
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = char
            ESP_Drawings[player].Highlight = hl
        end
    end

    player.CharacterAdded:Connect(setupESP)

    if player.Character then
        setupESP(player.Character)
    end
end

function ESP:Refresh()
    for _, p in ipairs(Players:GetPlayers()) do
        self:clear(p)
        self:apply(p)
    end
end

function ESP:Init()
    for _, p in ipairs(Players:GetPlayers()) do self:apply(p) end
    Players.PlayerAdded:Connect(function(p) self:apply(p) end)
    Players.PlayerRemoving:Connect(function(p) self:clear(p) end)

    RunService.RenderStepped:Connect(function()
        for player, tbl in pairs(ESP_Drawings) do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then
                if tbl.Box then tbl.Box.Visible = false end
                if tbl.Distance then tbl.Distance.Visible = false end
                if tbl.Health then tbl.Health.Visible = false end
                if tbl.HealthOutline then tbl.HealthOutline.Visible = false end
                continue
            end

            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            if Settings.Box then
                if not tbl.Box then
                    local box = Drawing.new("Square")
                    box.Thickness = 1
                    box.Color = Settings.Color
                    box.Filled = false
                    box.Transparency = 1
                    tbl.Box = box
                end
                local height, width = 5, 2.5
                local top = hrp.Position + Vector3.new(0, height / 2, 0)
                local bottom = hrp.Position - Vector3.new(0, height / 2, 0)
                local left = Camera.CFrame.RightVector * -width / 2
                local right = Camera.CFrame.RightVector * width / 2

                local tl = Camera:WorldToViewportPoint(top + left)
                local br = Camera:WorldToViewportPoint(bottom + right)

                tbl.Box.Position = Vector2.new(tl.X, tl.Y)
                tbl.Box.Size = Vector2.new(br.X - tl.X, br.Y - tl.Y)
                tbl.Box.Visible = onScreen
                tbl.Box.Color = Settings.Color
            elseif tbl.Box then tbl.Box.Visible = false end

            if Settings.Distance then
                if not tbl.Distance then
                    local txt = Drawing.new("Text")
                    txt.Size = 14
                    txt.Center = true
                    txt.Outline = true
                    txt.Font = 2
                    tbl.Distance = txt
                end
                local dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0)
                tbl.Distance.Text = dist .. "m"
                tbl.Distance.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                tbl.Distance.Color = Settings.Color
                tbl.Distance.Visible = onScreen
            elseif tbl.Distance then tbl.Distance.Visible = false end

            if Settings.Health then
                if not tbl.Health then
                    local bar = Drawing.new("Square")
                    local outline = Drawing.new("Square")
                    outline.Filled = false
                    outline.Thickness = 1
                    outline.Color = Color3.new(0, 0, 0)
                    tbl.HealthOutline = outline
                    tbl.Health = bar
                end
                local healthPerc = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local barHeight = 100
                local barSize = barHeight * healthPerc

                tbl.Health.Size = Vector2.new(4, barSize)
                tbl.Health.Position = Vector2.new(screenPos.X - 45, screenPos.Y + 50 - barSize)
                tbl.Health.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), healthPerc)
                tbl.Health.Visible = onScreen

                tbl.HealthOutline.Size = Vector2.new(4, barHeight)
                tbl.HealthOutline.Position = Vector2.new(screenPos.X - 45, screenPos.Y - barHeight / 2)
                tbl.HealthOutline.Visible = onScreen
            else
                if tbl.Health then tbl.Health.Visible = false end
                if tbl.HealthOutline then tbl.HealthOutline.Visible = false end
            end
        end
    end)
end

return ESP
