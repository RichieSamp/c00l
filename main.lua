--=== Services ===--
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

--=== Rayfield UI ===--
local Executor = identifyexecutor and identifyexecutor() or "Unknown"
local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
task.wait(0.5) -- Jeda supaya Rayfield benar-benar siap

local MainUI = Rayfield:CreateWindow({
	Name = "Learzy Hub | " .. Executor,
	Theme = "Amethyst",
	ToggleUIKeybind = "K",
})

--=== Tabs ===--
local tabPlayer = MainUI:CreateTab("Player") -- Tanpa icon untuk stabilitas
local tabVisual

--=== Fly Feature ===--
local Fly_Enabled = false
local Fly_Speed = 60
local BodyGyro, BodyVelocity, FlyConnection
local character, humanoidRootPart
local noclippedParts = {}

local function EnableNoclip()
	table.clear(noclippedParts)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") and part.CanCollide then
			noclippedParts[part] = true
			part.CanCollide = false
		end
	end
end

local function RestoreCollision()
	for part in pairs(noclippedParts) do
		if part and part:IsA("BasePart") then
			part.CanCollide = true
		end
	end
	table.clear(noclippedParts)
end

local function GetInputDirection()
	local direction = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += Vector3.new(0, 0, -1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction += Vector3.new(0, 0, 1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction += Vector3.new(-1, 0, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += Vector3.new(1, 0, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction += Vector3.new(0, -1, 0) end
	return direction
end

local function StartFly()
	character = LocalPlayer.Character
	if not character then return end
	humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	if not humanoidRootPart then return end

	EnableNoclip()

	BodyGyro = Instance.new("BodyGyro")
	BodyGyro.P = 9e4
	BodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
	BodyGyro.CFrame = humanoidRootPart.CFrame
	BodyGyro.Parent = humanoidRootPart

	BodyVelocity = Instance.new("BodyVelocity")
	BodyVelocity.Velocity = Vector3.zero
	BodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
	BodyVelocity.Parent = humanoidRootPart

	FlyConnection = RunService.RenderStepped:Connect(function()
		if not Fly_Enabled then return end
		local cameraCF = Camera.CFrame
		local moveVec = GetInputDirection()
		if moveVec.Magnitude == 0 then
			local hum = character:FindFirstChildOfClass("Humanoid")
			moveVec = hum and hum.MoveDirection or Vector3.zero
		end
		BodyVelocity.Velocity = moveVec.Magnitude > 0 and cameraCF:VectorToWorldSpace(moveVec).Unit * Fly_Speed or Vector3.zero
		BodyGyro.CFrame = cameraCF
		EnableNoclip()
	end)
end

local function StopFly()
	Fly_Enabled = false
	if FlyConnection then FlyConnection:Disconnect() end
	if BodyGyro then BodyGyro:Destroy() end
	if BodyVelocity then BodyVelocity:Destroy() end
	RestoreCollision()
end

tabPlayer:CreateToggle({
	Name = "Fly",
	CurrentValue = false,
	Callback = function(state)
		Fly_Enabled = state
		if state then StartFly() else StopFly() end
	end
})

tabPlayer:CreateSlider({
	Name = "Fly Speed",
	Range = {16, 200},
	Increment = 1,
	Suffix = " studs/s",
	CurrentValue = Fly_Speed,
	Callback = function(value)
		Fly_Speed = value
	end
})

--=== ESP Integration ===--
task.spawn(function()
	tabVisual = MainUI:CreateTab("Visual") -- Dijalankan setelah Rayfield siap

	local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/RichieSamp/c00l/main/ESP.lua"))()
	ESP:Init()

	tabVisual:CreateColorPicker({
		Name = "ESP Color",
		Color = Color3.fromRGB(255, 255, 255),
		Callback = function(color)
			ESP:UpdateConfig({ Color = color })
			ESP:Refresh()
		end
	})

	tabVisual:CreateToggle({
		Name = "Username ESP",
		CurrentValue = false,
		Callback = function(state)
			ESP:UpdateConfig({ Username = state })
			ESP:Refresh()
		end
	})

	tabVisual:CreateToggle({
		Name = "Box ESP",
		CurrentValue = false,
		Callback = function(state)
			ESP:UpdateConfig({ Box = state })
			ESP:Refresh()
		end
	})

	tabVisual:CreateToggle({
		Name = "Chams",
		CurrentValue = false,
		Callback = function(state)
			ESP:UpdateConfig({ Chams = state })
			ESP:Refresh()
		end
	})

	tabVisual:CreateToggle({
		Name = "Distance ESP",
		CurrentValue = false,
		Callback = function(state)
			ESP:UpdateConfig({ Distance = state })
			ESP:Refresh()
		end
	})

	tabVisual:CreateToggle({
		Name = "Health Bar",
		CurrentValue = false,
		Callback = function(state)
			ESP:UpdateConfig({ Health = state })
			ESP:Refresh()
		end
	})
end)
