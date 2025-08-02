-- ESP.lua - External ESP Module

local ESP = {}
ESP.Drawings = {}
ESP.Color = Color3.fromRGB(255, 255, 255)
ESP.Enabled = {
    Username = false,
    Box = false,
    Chams = false,
    HealthBar = false,
    Distance = false
}

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local function clearESP(player)
    if ESP.Drawings[player] then
        for _, v in pairs(ESP.Drawings[player]) do
            if typeof(v) == "Instance" then v:Destroy()
            elseif typeof(v) == "table" and v.Remove then v:Remove()
            elseif typeof(v) == "function" then v() end
        end
        ESP.Drawings[player] = nil
    end
end

local function applyESP(player)
    if player == LocalPlayer then return end
    clearESP(player)
    ESP.Drawings[player] = {}

    player.CharacterAdded:Connect(function(char)
        task.wait(0.3)

        -- Username
        if ESP.Enabled.Username then
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
                label.TextColor3 = ESP.Color
                label.BackgroundTransparency = 1
                label.TextScaled = true
                label.Size = UDim2.new(1, 0, 1, 0)

                local stroke = Instance.new("UIStroke", label)
                stroke.Thickness = 0.75
                stroke.Color = Color3.new(0, 0, 0)

                ESP.Drawings[player].Name = gui
            end
        end

        -- Chams
        if ESP.Enabled.Chams then
            local highlight = Instance.new("Highlight")
            highlight.FillColor = ESP.Color
            highlight.OutlineColor = Color3.new(0, 0, 0)
            highlight.FillTransparency = 0.5
            highlight.OutlineTransparency = 0.3
            highlight.Adornee = char
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Parent = char
            ESP.Drawings[player].Highlight = highlight
        end
    end)
end

local function updateRender()
    RunService.RenderStepped:Connect(function()
        for player, tbl in pairs(ESP.Drawings) do
            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not hrp or not hum or hum.Health <= 0 then
                if tbl.Box then tbl.Box.Visible = false end
                if tbl.Distance then tbl.Distance.Visible = false end
                if tbl.HealthBar then tbl.HealthBar.Visible = false end
                if tbl.HealthOutline then tbl.HealthOutline.Visible = false end
                continue
            end

            local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

            -- Box
            if ESP.Enabled.Box then
                if not tbl.Box then
                    local box = Drawing.new("Square")
                    box.Thickness = 1
                    box.Filled = false
                    box.Transparency = 1
                    box.Visible = false
                    box.Color = ESP.Color
                    tbl.Box = box
                end

                local height, width = 5, 2.5
                local top = hrp.Position + Vector3.new(0, height/2, 0)
                local bottom = hrp.Position - Vector3.new(0, height/2, 0)
                local left = Camera.CFrame.RightVector * -width / 2
                local right = Camera.CFrame.RightVector * width / 2
                local tl = Camera:WorldToViewportPoint(top + left)
                local br = Camera:WorldToViewportPoint(bottom + right)

                tbl.Box.Position = Vector2.new(tl.X, tl.Y)
                tbl.Box.Size = Vector2.new(br.X - tl.X, br.Y - tl.Y)
                tbl.Box.Color = ESP.Color
                tbl.Box.Visible = onScreen
            elseif tbl.Box then
                tbl.Box.Visible = false
            end

            -- Distance
            if ESP.Enabled.Distance then
                if not tbl.Distance then
                    local txt = Drawing.new("Text")
                    txt.Size = 14
                    txt.Center = true
                    txt.Outline = true
                    txt.Font = 2
                    txt.Visible = false
                    tbl.Distance = txt
                end

                local dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0)
                tbl.Distance.Text = tostring(dist) .. "m"
                tbl.Distance.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
                tbl.Distance.Color = ESP.Color
                tbl.Distance.Visible = onScreen
            elseif tbl.Distance then
                tbl.Distance.Visible = false
            end

            -- Health Bar
            if ESP.Enabled.HealthBar then
                if not tbl.HealthBar then
                    local bar = Drawing.new("Square")
                    bar.Filled = true
                    bar.Visible = false
                    tbl.HealthBar = bar

                    local outline = Drawing.new("Square")
                    outline.Filled = false
                    outline.Thickness = 1
                    outline.Color = Color3.new(0, 0, 0)
                    outline.Visible = false
                    tbl.HealthOutline = outline
                end

                local healthPerc = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                local barHeight = 100
                local barSize = barHeight * healthPerc

                tbl.HealthBar.Size = Vector2.new(4, barSize)
                tbl.HealthBar.Position = Vector2.new(screenPos.X - 45, screenPos.Y + 50 - barSize)
                tbl.HealthBar.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), healthPerc)
                tbl.HealthBar.Visible = onScreen

                tbl.HealthOutline.Size = Vector2.new(4, barHeight)
                tbl.HealthOutline.Position = Vector2.new(screenPos.X - 45, screenPos.Y - barHeight / 2)
                tbl.HealthOutline.Visible = onScreen
            else
                if tbl.HealthBar then tbl.HealthBar.Visible = false end
                if tbl.HealthOutline then tbl.HealthOutline.Visible = false end
            end
        end
    end)
end

function ESP:Init()
    for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
    Players.PlayerAdded:Connect(applyESP)
    Players.PlayerRemoving:Connect(clearESP)
    updateRender()
end

function ESP:UpdateConfig(optTable)
    for k, v in pairs(optTable) do
        if self.Enabled[k] ~= nil then
            self.Enabled[k] = v
        elseif k == "Color" then
            self.Color = v
        end
    end
end

return ESP