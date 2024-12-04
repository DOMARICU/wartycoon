local functions = {}

local isFlying = false
local flySpeed = 50
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local bodyVelocity
local bodyGyro
local userInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local freefallSetting = workspace:WaitForChild(player.Name):WaitForChild("Freefall")

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

        bodyVelocity = Instance.new("BodyVelocity", humanoidRootPart)
        bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        bodyVelocity.Velocity = Vector3.zero
        
        bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
        bodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
        bodyGyro.CFrame = humanoidRootPart.CFrame

        game:GetService("RunService").RenderStepped:Connect(function()
            if isFlying then
                local moveDirection = Vector3.zero

                if userInputService:IsKeyDown(Enum.KeyCode.W) then
                    moveDirection = moveDirection + camera.CFrame.LookVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.S) then
                    moveDirection = moveDirection - camera.CFrame.LookVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.A) then
                    moveDirection = moveDirection - camera.CFrame.RightVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.D) then
                    moveDirection = moveDirection + camera.CFrame.RightVector
                end
                if userInputService:IsKeyDown(Enum.KeyCode.Space) then
                    moveDirection = moveDirection + Vector3.new(0, 1, 0)
                end
                if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                    moveDirection = moveDirection - Vector3.new(0, 1, 0)
                end

                bodyVelocity.Velocity = moveDirection.Unit * flySpeed
            end
        end)

    elseif not value and isFlying then
        isFlying = false

        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end

        if freefallSetting then
            freefallSetting.Disabled = false
        end
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
