local functions = {}

local isFlying = false
local flySpeed = 50
local player = game.Players.LocalPlayer
local character = workspace:WaitForChild(player.Name)
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("Humanoid")
local userInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local freefallSetting = character:FindFirstChild("Freefall")
local RunService = game:GetService("RunService")

local FlyBodyGyro
local FlyBodyVelocity

function functions.fly(value)
    if value and not isFlying then
        isFlying = true

        if freefallSetting then
            freefallSetting.Disabled = true
        end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end

        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.P = 9e4
        FlyBodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
        FlyBodyGyro.CFrame = camera.CFrame
        FlyBodyGyro.Parent = humanoidRootPart

        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.Velocity = Vector3.zero
        FlyBodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
        FlyBodyVelocity.Parent = humanoidRootPart

        local function updateFly()
            if not isFlying then return end

            local direction = Vector3.zero

            if userInputService:IsKeyDown(Enum.KeyCode.W) then
                direction = direction + camera.CFrame.LookVector
            end
            if userInputService:IsKeyDown(Enum.KeyCode.S) then
                direction = direction - camera.CFrame.LookVector
            end
            if userInputService:IsKeyDown(Enum.KeyCode.A) then
                direction = direction - camera.CFrame.RightVector
            end
            if userInputService:IsKeyDown(Enum.KeyCode.D) then
                direction = direction + camera.CFrame.RightVector
            end
            if userInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction = direction + Vector3.new(0, 1, 0)
            end
            if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                direction = direction - Vector3.new(0, 1, 0)
            end

            if direction.Magnitude > 0 then
                FlyBodyVelocity.Velocity = direction.Unit * flySpeed
            else
                FlyBodyVelocity.Velocity = Vector3.zero
            end
            FlyBodyGyro.CFrame = camera.CFrame

            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end

        RunService:BindToRenderStep("Fly", Enum.RenderPriority.Character.Value, updateFly)
    else
        isFlying = false

        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end

        if freefallSetting then
            freefallSetting.Disabled = false
        end

        RunService:UnbindFromRenderStep("Fly")
    end
end

function functions.adjustflyspeed(speed)
    if type(speed) == "number" and speed > 0 then
        flySpeed = speed
    else
        warn("Ungültige Geschwindigkeit. Bitte eine positive Zahl eingeben.")
    end
end

return functions
