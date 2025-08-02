-- Load Obsidian UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/deividcomsono/Obsidian/main/Library.lua"))()
local Window = Library:Window("Swift UI", "Fly + NoClip", Color3.fromRGB(44, 120, 224), Enum.KeyCode.RightControl)
local MainTab = Window:Tab("Main")

-- Services
local userinput = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- Fly variables
local flying = false
local flySpeed = 50

-- Fly Function
local function toggleFly(state)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    if state then
        flying = true

        local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
        bodyGyro.P = 9e4
        bodyGyro.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bodyGyro.cframe = humanoidRootPart.CFrame

        local bodyVelocity = Instance.new("BodyVelocity", humanoidRootPart)
        bodyVelocity.velocity = Vector3.new(0, 0, 0)
        bodyVelocity.maxForce = Vector3.new(9e9, 9e9, 9e9)

        -- NoClip + Fly Movement Loop
        coroutine.wrap(function()
            while flying and character and character:FindFirstChild("HumanoidRootPart") do
                local cam = workspace.CurrentCamera
                local moveDirection = Vector3.zero

                -- Handle WASD + Space + Ctrl
                if userinput:IsKeyDown(Enum.KeyCode.W) then moveDirection += cam.CFrame.LookVector end
                if userinput:IsKeyDown(Enum.KeyCode.S) then moveDirection -= cam.CFrame.LookVector end
                if userinput:IsKeyDown(Enum.KeyCode.A) then moveDirection -= cam.CFrame.RightVector end
                if userinput:IsKeyDown(Enum.KeyCode.D) then moveDirection += cam.CFrame.RightVector end
                if userinput:IsKeyDown(Enum.KeyCode.Space) then moveDirection += cam.CFrame.UpVector end
                if userinput:IsKeyDown(Enum.KeyCode.LeftControl) then moveDirection -= cam.CFrame.UpVector end

                -- Apply movement
                bodyVelocity.Velocity = moveDirection.Unit * flySpeed
                bodyGyro.CFrame = cam.CFrame

                -- NoClip (disable collisions)
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide == true then
                        part.CanCollide = false
                    end
                end

                task.wait()
            end

            -- Cleanup: Remove fly + restore collisions
            for _, obj in pairs(humanoidRootPart:GetChildren()) do
                if obj:IsA("BodyGyro") or obj:IsA("BodyVelocity") then
                    obj:Destroy()
                end
            end
            -- Restore collision
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end)()
    else
        flying = false
    end
end

-- UI: Toggle Fly
MainTab:Toggle("Fly Mode", false, function(state)
    toggleFly(state)
end)

-- UI: Slider Speed
MainTab:Slider("Fly Speed", 10, 200, 50, function(value)
    flySpeed = value
end)