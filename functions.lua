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
local freefallSetting = workspace:WaitForChild(player.Name):WaitForChild("Freefall")--

function functions.fly(value)
    if value and not isFlying then
        isFlying = true

        if freefallSetting then
            freefallSetting.Disabled = true
        end

        bodyVelocity = Instance.new("BodyVelocity", humanoidRootPart)
        bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        bodyVelocity.Velocity = Vector3.zero
        
        bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
        bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        bodyGyro.CFrame = humanoidRootPart.CFrame

        userInputService.InputBegan:Connect(function(input)
            if isFlying then
                if input.KeyCode == Enum.KeyCode.W then
                    bodyVelocity.Velocity = camera.CFrame.LookVector * flySpeed
                elseif input.KeyCode == Enum.KeyCode.S then
                    bodyVelocity.Velocity = -camera.CFrame.LookVector * flySpeed
                elseif input.KeyCode == Enum.KeyCode.A then
                    bodyVelocity.Velocity = -camera.CFrame.RightVector * flySpeed
                elseif input.KeyCode == Enum.KeyCode.D then
                    bodyVelocity.Velocity = camera.CFrame.RightVector * flySpeed
                elseif input.KeyCode == Enum.KeyCode.Space then
                    bodyVelocity.Velocity = Vector3.new(0, flySpeed, 0)
                elseif input.KeyCode == Enum.KeyCode.LeftShift then
                    bodyVelocity.Velocity = Vector3.new(0, -flySpeed, 0)
                end
            end
        end)

        userInputService.InputEnded:Connect(function(input)
            if isFlying then
                bodyVelocity.Velocity = Vector3.zero
            end
        end)

    elseif not value and isFlying then
        isFlying = false
        if bodyVelocity then bodyVelocity:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
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
