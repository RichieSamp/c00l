--=== ESP Module Script (ESP.lua) ===--
local ESP = {}
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local settings = {
	Color = Color3.fromRGB(255, 255, 255),
	Username = false,
	Box = false,
	Chams = false,
	HealthBar = false,
	Distance = false
}

local ESP_Drawings = {}

function ESP:UpdateConfig(cfg)
	for k, v in pairs(cfg) do
		if settings[k] ~= nil then
			settings[k] = v
		end
	end
end

local function clearESP(player)
	if ESP_Drawings[player] then
		for _, v in pairs(ESP_Drawings[player]) do
			if typeof(v) == "Instance" then v:Destroy()
			elseif typeof(v) == "table" and v.Remove then v:Remove()
			elseif typeof(v) == "function" then v() end
		end
		ESP_Drawings[player] = nil
	end
end

local function applyESP(player)
	if player == LocalPlayer then return end
	ESP_Drawings[player] = {}

	player.CharacterAdded:Connect(function(char)
		task.wait(0.4)
		if not char:FindFirstChild("HumanoidRootPart") then return end

		-- Username
		if settings.Username then
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
				label.TextColor3 = settings.Color
				label.BackgroundTransparency = 1
				label.TextScaled = true
				label.Size = UDim2.new(1, 0, 1, 0)

				local stroke = Instance.new("UIStroke", label)
				stroke.Thickness = 0.75
				stroke.Color = Color3.new(0, 0, 0)

				ESP_Drawings[player].Name = gui
			end
		end

		-- Chams
		if settings.Chams then
			local hl = Instance.new("Highlight")
			hl.FillColor = settings.Color
			hl.OutlineColor = Color3.new(0, 0, 0)
			hl.FillTransparency = 0.5
			hl.OutlineTransparency = 0.3
			hl.Adornee = char
			hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			hl.Parent = char
			ESP_Drawings[player].Highlight = hl
		end
	end)
end

function ESP:Init()
	for _, p in ipairs(Players:GetPlayers()) do
		applyESP(p)
	end
	Players.PlayerAdded:Connect(applyESP)
	Players.PlayerRemoving:Connect(clearESP)

	RunService.RenderStepped:Connect(function()
		for player, tbl in pairs(ESP_Drawings) do
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
			if settings.Box then
				if not tbl.Box then
					tbl.Box = Drawing.new("Square")
					tbl.Box.Thickness = 1
					tbl.Box.Color = settings.Color
					tbl.Box.Filled = false
					tbl.Box.Transparency = 1
					tbl.Box.Visible = false
				end

				local height = 5
				local width = 2.5
				local top = hrp.Position + Vector3.new(0, height / 2, 0)
				local bottom = hrp.Position - Vector3.new(0, height / 2, 0)
				local left = Camera.CFrame.RightVector * -width / 2
				local right = Camera.CFrame.RightVector * width / 2

				local tl = Camera:WorldToViewportPoint(top + left)
				local br = Camera:WorldToViewportPoint(bottom + right)

				tbl.Box.Position = Vector2.new(tl.X, tl.Y)
				tbl.Box.Size = Vector2.new(br.X - tl.X, br.Y - tl.Y)
				tbl.Box.Visible = onScreen
				tbl.Box.Color = settings.Color
			elseif tbl.Box then
				tbl.Box.Visible = false
			end

			-- Distance
			if settings.Distance then
				if not tbl.Distance then
					tbl.Distance = Drawing.new("Text")
					tbl.Distance.Size = 14
					tbl.Distance.Center = true
					tbl.Distance.Outline = true
					tbl.Distance.Font = 2
					tbl.Distance.Visible = false
				end
				local dist = math.floor((LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and (LocalPlayer.Character.HumanoidRootPart.Position - hrp.Position).Magnitude) or 0)
				tbl.Distance.Text = tostring(dist) .. "m"
				tbl.Distance.Position = Vector2.new(screenPos.X, screenPos.Y - 30)
				tbl.Distance.Color = settings.Color
				tbl.Distance.Visible = onScreen
			elseif tbl.Distance then
				tbl.Distance.Visible = false
			end

			-- Health Bar
			if settings.HealthBar then
				if not tbl.HealthBar then
					tbl.HealthBar = Drawing.new("Square")
					tbl.HealthBar.Filled = true
					tbl.HealthBar.Visible = false

					tbl.HealthOutline = Drawing.new("Square")
					tbl.HealthOutline.Filled = false
					tbl.HealthOutline.Thickness = 1
					tbl.HealthOutline.Color = Color3.new(0, 0, 0)
					tbl.HealthOutline.Visible = false
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

return ESP
