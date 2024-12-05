local functions = {}

local isFlying = false
local isNoclip = false
local flySpeed = 50
local sprintSpeedMultiplier = 1.5
local player = game.Players.LocalPlayer
local character = workspace:WaitForChild(player.Name)
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
local userInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FlyBodyGyro
local FlyBodyVelocity
local flyConnection
local noclipConnection
local CONTROL = {F = 0, B = 0, L = 0, R = 0, Q = 0, E = 0}
local SPEED = 0
local originalFDMGName = "FDMG"

local function renameFallDamageEvent(rename)
    local ACS_Engine = ReplicatedStorage:WaitForChild("ACS_Engine")
    local Events = ACS_Engine:WaitForChild("Events")
    local FDMG = Events:FindFirstChild(originalFDMGName)

    if FDMG then
        if rename then
            FDMG.Name = "FDMG_Disabled"
        else
            FDMG.Name = originalFDMGName
        end
    end
end

function functions.noclip(value)
    if value and not isNoclip then
        isNoclip = true
        noclipConnection = RunService.Stepped:Connect(function()
            for _, part in ipairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end)
    elseif not value and isNoclip then
        isNoclip = false
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

function functions.fly(value)
    if value and not isFlying then
        isFlying = true

        humanoid.PlatformStand = true
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
        functions.noclip(true)
        renameFallDamageEvent(true)

        FlyBodyGyro = Instance.new("BodyGyro")
        FlyBodyGyro.P = 9e4
        FlyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyGyro.CFrame = humanoidRootPart.CFrame
        FlyBodyGyro.Parent = humanoidRootPart

        FlyBodyVelocity = Instance.new("BodyVelocity")
        FlyBodyVelocity.Velocity = Vector3.zero
        FlyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        FlyBodyVelocity.Parent = humanoidRootPart

        flyConnection = RunService.RenderStepped:Connect(function()
            local direction = Vector3.zero

            if userInputService:IsKeyDown(Enum.KeyCode.W) then
                direction += camera.CFrame.LookVector
            end
            if userInputService:IsKeyDown(Enum.KeyCode.S) then
                direction -= camera.CFrame.LookVector
            end
            if userInputService:IsKeyDown(Enum.KeyCode.A) then
                direction -= camera.CFrame.RightVector
            end
            if userInputService:IsKeyDown(Enum.KeyCode.D) then
                direction += camera.CFrame.RightVector
            end
            if userInputService:IsKeyDown(Enum.KeyCode.Space) then
                direction += Vector3.new(0, 1, 0)
            end

            local newSpeed = flySpeed
            if userInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                newSpeed = flySpeed * sprintSpeedMultiplier
            end

            if direction.Magnitude > 0 then
                FlyBodyVelocity.Velocity = direction.Unit * newSpeed
            else
                FlyBodyVelocity.Velocity = Vector3.zero
            end
            FlyBodyGyro.CFrame = camera.CFrame
        end)
    elseif not value and isFlying then
        isFlying = false

        humanoid.PlatformStand = false
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        functions.noclip(false)
        renameFallDamageEvent(false)

        if FlyBodyGyro then FlyBodyGyro:Destroy() FlyBodyGyro = nil end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() FlyBodyVelocity = nil end
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end

        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

function functions.adjustflyspeed(speed)
    if type(speed) == "number" and speed > 0 then
        flySpeed = speed
    else
        warn("ERROR: Invalid speed value.")
    end
end

return functions
