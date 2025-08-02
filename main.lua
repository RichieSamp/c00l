local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Load UI Library dari GitHub
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/RichieSamp/c00l/main/lib.lua"))()
local Window = Library:CreateWindow("Learzy Hub", Vector2.new(500, 550), Enum.KeyCode.K)
local Tab1 = Window:CreateTab("Player")
local Tab2 = Window:CreateTab("Visual")

-- ESP config
local ESP = {
	Drawings = {},
	Color = Color3.fromRGB(255, 255, 255),
	UsernameESP = false,
	BoxESP = false,
	ChamsESP = false,
	HealthESP = false,
	DistanceESP = false
}

-- Clear ESP
local function clearESP(p)
	if ESP.Drawings[p] then
		for _, v in pairs(ESP.Drawings[p]) do
			if typeof(v) == "Instance" then v:Destroy()
			elseif typeof(v) == "table" and v.Remove then v:Remove()
			elseif typeof(v) == "function" then v() end
		end
		ESP.Drawings[p] = nil
	end
end

-- Apply ESP
local function applyESP(p)
	if p == LocalPlayer then return end
	clearESP(p)
	ESP.Drawings[p] = {}

	p.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		local hrp = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end

		if ESP.UsernameESP and char:FindFirstChild("Head") then
			local gui = Instance.new("BillboardGui")
			gui.Adornee = char.Head
			gui.AlwaysOnTop = true
			gui.Size = UDim2.new(0, 100, 0, 20)
			gui.StudsOffset = Vector3.new(0, 3, 0)
			gui.Parent = char.Head
			local label = Instance.new("TextLabel", gui)
			label.Text = p.Name
			label.TextColor3 = ESP.Color
			label.BackgroundTransparency = 1
			label.Size = UDim2.fromScale(1, 1)
			label.TextScaled = true
			local stroke = Instance.new("UIStroke", label)
			stroke.Thickness = 1
			stroke.Color = Color3.new(0, 0, 0)
			ESP.Drawings[p].Name = gui
		end

		if ESP.ChamsESP then
			local h = Instance.new("Highlight")
			h.Adornee = char
			h.FillColor = ESP.Color
			h.OutlineColor = Color3.new(0, 0, 0)
			h.FillTransparency = 0.6
			h.OutlineTransparency = 0.3
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.Parent = Workspace
			ESP.Drawings[p].Highlight = h
		end
	end)
end

-- ESP update loop
function ESP:Init()
	for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
	Players.PlayerAdded:Connect(applyESP)
	Players.PlayerRemoving:Connect(clearESP)
	RunService.RenderStepped:Connect(function()
		for player, tbl in pairs(ESP.Drawings) do
			local char = player.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if not hrp or not hum or hum.Health <= 0 then
				if tbl.Box then tbl.Box.Visible = false end
				if tbl.Distance then tbl.Distance.Visible = false end
				if tbl.HealthBar then tbl.HealthBar.Visible = false end
				continue
			end
			local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)

			if ESP.BoxESP then
				if not tbl.Box then
					local box = Drawing.new("Square")
					box.Thickness = 1
					box.Filled = false
					box.Transparency = 1
					box.Color = ESP.Color
					tbl.Box = box
				end
				local sizeY, sizeX = 5, 2.5
				local top = hrp.Position + Vector3.new(0, sizeY / 2, 0)
				local bottom = hrp.Position - Vector3.new(0, sizeY / 2, 0)
				local p1 = Camera:WorldToViewportPoint(top)
				local p2 = Camera:WorldToViewportPoint(bottom)
				local x = (p1.X + p2.X) / 2 - sizeX * 5
				local y = (p1.Y + p2.Y) / 2 - sizeY * 5
				tbl.Box.Position = Vector2.new(x, y)
				tbl.Box.Size = Vector2.new(sizeX * 10, sizeY * 10)
				tbl.Box.Color = ESP.Color
				tbl.Box.Visible = onScreen
			elseif tbl.Box then
				tbl.Box.Visible = false
			end

			if ESP.DistanceESP then
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
				tbl.Distance.Color = ESP.Color
				tbl.Distance.Visible = onScreen
			elseif tbl.Distance then
				tbl.Distance.Visible = false
			end

			if ESP.HealthESP then
				if not tbl.HealthBar then
					local bar = Drawing.new("Square")
					bar.Filled = true
					bar.Thickness = 1
					local outline = Drawing.new("Square")
					outline.Filled = false
					outline.Thickness = 1
					outline.Color = Color3.new(0, 0, 0)
					tbl.HealthBar = bar
					tbl.HealthOutline = outline
				end
				local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
				local h = 50
				tbl.HealthBar.Size = Vector2.new(4, h * pct)
				tbl.HealthBar.Position = Vector2.new(screenPos.X - 45, screenPos.Y + 25 - h * pct)
				tbl.HealthBar.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), pct)
				tbl.HealthBar.Visible = onScreen
				tbl.HealthOutline.Size = Vector2.new(4, h)
				tbl.HealthOutline.Position = Vector2.new(screenPos.X - 45, screenPos.Y + 25 - h)
				tbl.HealthOutline.Visible = onScreen
			elseif tbl.HealthBar then
				tbl.HealthBar.Visible = false
				tbl.HealthOutline.Visible = false
			end
		end
	end)
end

-- Fly
local Fly = {}
local Fly_Speed = 60
local Fly_Enabled = false
local BodyGyro, BodyVelocity, FlyConnection
local noclippedParts = {}

local function EnableNoclip()
	table.clear(noclippedParts)
	for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
		if part:IsA("BasePart") and part.CanCollide then
			noclippedParts[part] = true
			part.CanCollide = false
		end
	end
end

local function RestoreCollision()
	for part in pairs(noclippedParts) do
		if part:IsA("BasePart") then
			part.CanCollide = true
		end
	end
	table.clear(noclippedParts)
end

local function GetInputDirection()
	local v = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then v += Vector3.new(0, 0, -1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then v += Vector3.new(0, 0, 1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then v += Vector3.new(-1, 0, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then v += Vector3.new(1, 0, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then v += Vector3.new(0, 1, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then v += Vector3.new(0, -1, 0) end
	return v
end

function Fly:SetSpeed(s) Fly_Speed = s end

function Fly:Toggle(state)
	Fly_Enabled = state
	if state then
		local char = LocalPlayer.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end

		EnableNoclip()
		BodyGyro = Instance.new("BodyGyro", hrp)
		BodyGyro.P = 9e4
		BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
		BodyGyro.CFrame = hrp.CFrame

		BodyVelocity = Instance.new("BodyVelocity", hrp)
		BodyVelocity.Velocity = Vector3.zero
		BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

		FlyConnection = RunService.RenderStepped:Connect(function()
			if not Fly_Enabled then return end
			local dir = GetInputDirection()
			local cam = Camera.CFrame
			BodyVelocity.Velocity = dir.Magnitude > 0 and cam:VectorToWorldSpace(dir).Unit * Fly_Speed or Vector3.zero
			BodyGyro.CFrame = cam
			EnableNoclip()
		end)
	else
		if FlyConnection then FlyConnection:Disconnect() end
		if BodyGyro then BodyGyro:Destroy() end
		if BodyVelocity then BodyVelocity:Destroy() end
		RestoreCollision()
	end
end

-- UI Binding
Tab1:CreateToggle("Fly", function(state) Fly:Toggle(state) end)
Tab1:CreateSlider("Fly Speed", 16, 200, function(val) Fly:SetSpeed(val) end, 60)

Tab2:CreateToggle("Username ESP", function(state) ESP.UsernameESP = state end)
Tab2:CreateToggle("Box ESP", function(state) ESP.BoxESP = state end)
Tab2:CreateToggle("Chams", function(state) ESP.ChamsESP = state end)
Tab2:CreateToggle("Health ESP", function(state) ESP.HealthESP = state end)
Tab2:CreateToggle("Distance ESP", function(state) ESP.DistanceESP = state end)

ESP:Init()



