local functions = {}

local isFlying = false
local flySpeed = 50
local sprintSpeedMultiplier = 1.5
local player = game.Players.LocalPlayer
local character = workspace:WaitForChild(player.Name)
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
local userInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local freefallSetting = character:FindFirstChild("Freefall")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FlyBodyGyro
local FlyBodyVelocity
local originalFDMGName = "FDMG"
local updateConnection

local function renameFallDamageEvent(rename)
    local ACS_Engine = ReplicatedStorage:WaitForChild("ACS_Engine")
    local Events = ACS_Engine:WaitForChild("Events")
    local FDMG = Events:FindFirstChild(originalFDMGName)

    if FDMG then
        if rename then
            FDMG.Name = "FDMG "
        else
            FDMG.Name = originalFDMGName
        end
    end
end

local function onCharacterAdded(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
    freefallSetting = character:FindFirstChild("Freefall")
end
player.CharacterAdded:Connect(onCharacterAdded)

function functions.fly(value)
    if value and not isFlying then
        isFlying = true

        renameFallDamageEvent(true)
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
        FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyGyro.CFrame = camera.CFrame
        FlyBodyGyro.Parent = humanoidRootPart

        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.Velocity = Vector3.zero
        FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyVelocity.Parent = humanoidRootPart

        updateConnection = RunService.RenderStepped:Connect(function()
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

            local currentFlySpeed = flySpeed
            if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                currentFlySpeed = flySpeed * sprintSpeedMultiplier
            end

            if direction.Magnitude > 0 then
                FlyBodyVelocity.Velocity = direction.Unit * currentFlySpeed
            else
                FlyBodyVelocity.Velocity = Vector3.zero
            end
            FlyBodyGyro.CFrame = camera.CFrame

            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end)
    elseif not value and isFlying then
        isFlying = false

        renameFallDamageEvent(false)
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
        if updateConnection then updateConnection:Disconnect() end

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
        warn("ERROR! API reports: Speed ​​invalid")
    end
end

return functions
