local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/ESPModule.lua"))()
local Fly = loadstring(game:HttpGet("https://raw.githubusercontent.com/USERNAME/REPO/main/FlyModule.lua"))()

local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()
local MainUI = Rayfield:CreateWindow({
	Name = "Learzy Hub | " .. (identifyexecutor and identifyexecutor() or "Unknown"),
	Theme = "Amethyst",
	ToggleUIKeybind = "K",
})

local tabPlayer = MainUI:CreateTab("Player", 4483362458)
local tabVisual = MainUI:CreateTab("Visual", 4483362458)

tabPlayer:CreateToggle({
	Name = "Fly",
	CurrentValue = false,
	Callback = function(state)
		Fly:Toggle(state)
	end
})

tabPlayer:CreateSlider({
	Name = "Fly Speed",
	Range = {16, 200},
	Increment = 1,
	Suffix = " studs/s",
	CurrentValue = 60,
	Callback = function(value)
		Fly:SetSpeed(value)
	end
})

tabVisual:CreateColorPicker({Name = "ESP Color", Color = ESP.Color, Callback = function(c) ESP.Color = c end})
tabVisual:CreateToggle({Name = "Username ESP", CurrentValue = false, Callback = function(v) ESP.UsernameESP = v end})
tabVisual:CreateToggle({Name = "Box ESP", CurrentValue = false, Callback = function(v) ESP.BoxESP = v end})
tabVisual:CreateToggle({Name = "Chams (Highlight)", CurrentValue = false, Callback = function(v) ESP.ChamsESP = v end})
tabVisual:CreateToggle({Name = "Health Bar ESP", CurrentValue = false, Callback = function(v) ESP.HealthESP = v end})
tabVisual:CreateToggle({Name = "Distance ESP", CurrentValue = false, Callback = function(v) ESP.DistanceESP = v end})

ESP:Init()
