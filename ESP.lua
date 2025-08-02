local ESP = {}
ESP.Drawings = {}
ESP.Color = Color3.new(1, 1, 1)
ESP.UsernameESP = false
ESP.BoxESP = false
ESP.ChamsESP = false
ESP.HealthESP = false
ESP.DistanceESP = false

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
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

function ESP:ApplyToPlayer(player)
	if player == LocalPlayer then return end
	clearESP(player)
	ESP.Drawings[player] = {}
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		local hum = char:FindFirstChildOfClass("Humanoid")
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hum or not hrp then return end

		if self.UsernameESP and char:FindFirstChild("Head") then
			local gui = Instance.new("BillboardGui")
			gui.Adornee = char.Head
			gui.AlwaysOnTop = true
			gui.Size = UDim2.new(0, 100, 0, 20)
			gui.StudsOffset = Vector3.new(0, 3, 0)
			gui.Parent = char.Head
			local label = Instance.new("TextLabel", gui)
			label.Text = player.Name
			label.TextColor3 = self.Color
			label.BackgroundTransparency = 1
			label.Size = UDim2.fromScale(1,1)
			label.TextScaled = true
			local stroke = Instance.new("UIStroke", label)
			stroke.Thickness = 1
			stroke.Color = Color3.new(0,0,0)
			ESP.Drawings[player].Name = gui
		end

		if self.ChamsESP then
			local highlight = Instance.new("Highlight")
			highlight.Adornee = char
			highlight.FillColor = self.Color
			highlight.OutlineColor = Color3.new(0,0,0)
			highlight.FillTransparency = 0.6
			highlight.OutlineTransparency = 0.3
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = Workspace
			ESP.Drawings[player].Highlight = highlight
		end
	end)
end

function ESP:ProcessRender()
	for player, tbl in pairs(self.Drawings) do
		local char = player.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp or not hum or hum.Health <= 0 then
			if tbl.Box then tbl.Box.Visible = false end
			if tbl.Distance then tbl.Distance.Visible = false end
			if tbl.HealthBar then tbl.HealthBar.Visible = false end
			continue
		end
		local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

		if self.BoxESP then
			if not tbl.Box then
				local box = Drawing.new("Square")
				box.Thickness = 1
				box.Filled = false
				box.Transparency = 1
				box.Color = self.Color
				tbl.Box = box
			end
			local sizeY = 5
			local sizeX = sizeY * 0.5
			local p1 = Camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, sizeY/2, 0))
			local p2 = Camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, sizeY/2, 0))
			local x = (p1.X + p2.X)/2 - sizeX*5
			local y = (p1.Y + p2.Y)/2 - sizeY*5
			tbl.Box.Position = Vector2.new(x, y)
			tbl.Box.Size = Vector2.new(sizeX*10, sizeY*10)
			tbl.Box.Color = self.Color
			tbl.Box.Visible = onScreen
		elseif tbl.Box then
			tbl.Box.Visible = false
		end

		if self.DistanceESP then
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
			tbl.Distance.Color = self.Color
			tbl.Distance.Visible = onScreen
		elseif tbl.Distance then
			tbl.Distance.Visible = false
		end

		if self.HealthESP then
			if not tbl.HealthBar then
				local bar = Drawing.new("Square") bar.Filled = true bar.Thickness = 1
				local outline = Drawing.new("Square") outline.Filled = false outline.Thickness = 1 outline.Color = Color3.new(0,0,0)
				tbl.HealthBar = bar tbl.HealthOutline = outline
			end
			local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
			local h = 50
			tbl.HealthBar.Size = Vector2.new(4, h * pct)
			tbl.HealthBar.Position = Vector2.new(screenPos.X - 45, screenPos.Y + 25 - h * pct)
			tbl.HealthBar.Color = Color3.fromRGB(255,0,0):Lerp(Color3.fromRGB(0,255,0), pct)
			tbl.HealthBar.Visible = onScreen
			tbl.HealthOutline.Size = Vector2.new(4, h)
			tbl.HealthOutline.Position = Vector2.new(screenPos.X - 45, screenPos.Y + 25 - h)
			tbl.HealthOutline.Visible = onScreen
		elseif tbl.HealthBar then
			tbl.HealthBar.Visible = false
			tbl.HealthOutline.Visible = false
		end
	end
end

function ESP:Init()
	for _, p in ipairs(Players:GetPlayers()) do
		self:ApplyToPlayer(p)
	end
	Players.PlayerAdded:Connect(function(p) self:ApplyToPlayer(p) end)
	Players.PlayerRemoving:Connect(clearESP)
	RunService.RenderStepped:Connect(function() self:ProcessRender() end)
end

return ESP
