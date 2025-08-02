local Fly = {}
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

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
	local dir = Vector3.zero
	if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += Vector3.new(0, 0, -1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir += Vector3.new(0, 0, 1) end
	if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir += Vector3.new(-1, 0, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += Vector3.new(1, 0, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
	if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir += Vector3.new(0, -1, 0) end
	return dir
end

function Fly:SetSpeed(value)
	Fly_Speed = value
end

function Fly:Toggle(state)
	Fly_Enabled = state
	if state then
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
			local moveVec = GetInputDirection()
			local camCF = Camera.CFrame
			BodyVelocity.Velocity = moveVec.Magnitude > 0 and camCF:VectorToWorldSpace(moveVec).Unit * Fly_Speed or Vector3.zero
			BodyGyro.CFrame = camCF
			EnableNoclip()
		end)
	else
		if FlyConnection then FlyConnection:Disconnect() end
		if BodyGyro then BodyGyro:Destroy() end
		if BodyVelocity then BodyVelocity:Destroy() end
		RestoreCollision()
	end
end

return Fly
