local functions = {}

local isFlying = false
local isNoclip = false
local hitboxEnabled = false
local autocratefarm = false

local hitboxConnection

local flySpeed = 12
local sprintSpeedMultiplier = 1.5
local hitboxSize = 10

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local player = game.Players.LocalPlayer
local character = player.Character or workspace:WaitForChild(player.Name)
local humanoid = character:WaitForChild("Humanoid")
local humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
local userInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CONTROL = {F = 0, B = 0, L = 0, R = 0}
local lCONTROL = {F = 0, B = 0, L = 0, R = 0}
local SPEED = 0
local flyConnection, flyKeyDown, flyKeyUp, noclipConnection
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

local function resetCharacter()
    if noclipConnection then
        noclipConnection:Disconnect()
        noclipConnection = nil
    end
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = true
        end
    end
    humanoid.PlatformStand = false
    humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)
    renameFallDamageEvent(false)

    if humanoidRootPart then
        humanoidRootPart.Velocity = Vector3.zero
        humanoidRootPart.Anchored = false
    end
end

function functions.fly(value)
    if value and not isFlying then
        isFlying = true

        humanoid.PlatformStand = true
        renameFallDamageEvent(true)

        noclipConnection = RunService.Stepped:Connect(function()
            if character and character.Parent then
                for _, part in ipairs(character:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)

        local BG = Instance.new("BodyGyro")
        local BV = Instance.new("BodyVelocity")
        BG.P = 9e4
        BG.Parent = humanoidRootPart
        BV.Parent = humanoidRootPart
        BG.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        BG.CFrame = humanoidRootPart.CFrame
        BV.Velocity = Vector3.new(0, 0, 0)
        BV.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        flyConnection = RunService.RenderStepped:Connect(function()
            if CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0 then
                SPEED = flySpeed
            elseif not (CONTROL.L + CONTROL.R ~= 0 or CONTROL.F + CONTROL.B ~= 0) and SPEED ~= 0 then
                SPEED = 0
            end
            if (CONTROL.L + CONTROL.R) ~= 0 or (CONTROL.F + CONTROL.B ~= 0) then
                BV.Velocity = ((camera.CFrame.LookVector * (CONTROL.F + CONTROL.B)) + ((camera.CFrame * CFrame.new(CONTROL.L + CONTROL.R, (CONTROL.F + CONTROL.B) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
                lCONTROL = {F = CONTROL.F, B = CONTROL.B, L = CONTROL.L, R = CONTROL.R}
            elseif (CONTROL.L + CONTROL.R) == 0 and (CONTROL.F + CONTROL.B) == 0 and SPEED ~= 0 then
                BV.Velocity = ((camera.CFrame.LookVector * (lCONTROL.F + lCONTROL.B)) + ((camera.CFrame * CFrame.new(lCONTROL.L + lCONTROL.R, (lCONTROL.F + lCONTROL.B) * 0.2, 0).p) - camera.CFrame.p)) * SPEED
            else
                BV.Velocity = Vector3.new(0, 0, 0)
            end
            BG.CFrame = camera.CFrame
        end)

        flyKeyDown = userInputService.InputBegan:Connect(function(input)
            local KEY = input.KeyCode
            if KEY == Enum.KeyCode.W then
                CONTROL.F = flySpeed
            elseif KEY == Enum.KeyCode.S then
                CONTROL.B = -flySpeed
            elseif KEY == Enum.KeyCode.A then
                CONTROL.L = -flySpeed
            elseif KEY == Enum.KeyCode.D then
                CONTROL.R = flySpeed
            end
        end)

        flyKeyUp = userInputService.InputEnded:Connect(function(input)
            local KEY = input.KeyCode
            if KEY == Enum.KeyCode.W then
                CONTROL.F = 0
            elseif KEY == Enum.KeyCode.S then
                CONTROL.B = 0
            elseif KEY == Enum.KeyCode.A then
                CONTROL.L = 0
            elseif KEY == Enum.KeyCode.D then
                CONTROL.R = 0
            end
        end)

    elseif not value and isFlying then
        isFlying = false

        resetCharacter()
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
        if flyKeyDown then flyKeyDown:Disconnect() flyKeyDown = nil end
        if flyKeyUp then flyKeyUp:Disconnect() flyKeyUp = nil end
        
        for _, instance in ipairs(humanoidRootPart:GetChildren()) do
            if instance:IsA("BodyGyro") or instance:IsA("BodyVelocity") then
                instance:Destroy()
            end
        end
    end
end

player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    humanoidRootPart = character:FindFirstChild("HumanoidRootPart") or character:WaitForChild("HumanoidRootPart")
    resetCharacter()
    isFlying = false
end)

function functions.adjustflyspeed(speed)
    if type(speed) == "number" and speed > 0 then
        flySpeed = speed
    else
        warn("ERROR: Invalid speed value.")
    end
end

-----------------------Hitboxes--------------------------

function functions.hitbox(value)
    if value and not hitboxEnabled then
        hitboxEnabled = true

        hitboxConnection = RunService.Heartbeat:Connect(function()
            for _, otherPlayer in ipairs(Players:GetPlayers()) do
                if otherPlayer ~= player and otherPlayer.Character then
                    local character = otherPlayer.Character
                    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                    if humanoidRootPart then
                        humanoidRootPart.Size = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
                        humanoidRootPart.Transparency = 0.5
                        humanoidRootPart.CanCollide = false
                    end
                end
            end
        end)

    elseif not value and hitboxEnabled then
        hitboxEnabled = false

        if hitboxConnection then
            hitboxConnection:Disconnect()
            hitboxConnection = nil
        end

        for _, otherPlayer in ipairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local character = otherPlayer.Character
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                if humanoidRootPart then
                    humanoidRootPart.Size = Vector3.new(2, 2, 1)
                    humanoidRootPart.Transparency = 0
                    humanoidRootPart.CanCollide = true
                end
            end
        end
    end
end

-------------------FARMING--------------
function functions.cratefarming(value)
    local Workspace = game:GetService("Workspace")
    local Players = game:GetService("Players")

    local player = Players.LocalPlayer
    local farmingEnabled = value

    local function teleportTo(position)
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
            wait(1)
        else
            warn("Player HumanoidRootPart not found.")
        end
    end

    local function activatePrompt(prompt)
        if prompt and prompt:IsA("ProximityPrompt") then
            print("Activating ProximityPrompt: " .. prompt.Name)
            prompt:InputHoldBegin()
            wait(prompt.HoldDuration or 0.5)
            prompt:InputHoldEnd()
        else
            warn("Invalid or missing ProximityPrompt.")
        end
    end

    local function processTankCrate(crate)
        if crate then
            local stealPrompt = crate:FindFirstChild("StealPrompt")
            if stealPrompt then
                print("Processing Tank Crate at position: " .. tostring(crate.Position))
                teleportTo(crate.Position)
                activatePrompt(stealPrompt)
            else
                warn("StealPrompt not found in Tank Crate.")
            end
        else
            warn("Tank Crate is nil.")
        end
    end

    local function sellCrate()
        local teamValue = player:WaitForChild("leaderstats"):WaitForChild("Team").Value
        local tycoon = Workspace:WaitForChild("Tycoon"):WaitForChild("Tycoons"):FindFirstChild(teamValue)

        if tycoon then
            local collectorPart = tycoon:WaitForChild("Essentials"):WaitForChild("Oil Collector"):WaitForChild("Crate Collector"):FindFirstChild("DiamondPlate")
            if collectorPart then
                local sellPrompt = tycoon:WaitForChild("Essentials"):WaitForChild("Oil Collector"):WaitForChild("CratePromptPart"):FindFirstChild("SellPrompt")
                if sellPrompt then
                    print("Teleporting to Crate Collector.")
                    teleportTo(collectorPart.Position)
                    activatePrompt(sellPrompt)
                else
                    warn("SellPrompt not found in Crate Collector.")
                end
            else
                warn("Collector part not found for team: " .. tostring(teamValue))
            end
        else
            warn("Tycoon not found for team: " .. tostring(teamValue))
        end
    end

    print("Crate farming enabled.")
    while farmingEnabled do
        local crateFolder = Workspace:WaitForChild("Game Systems"):WaitForChild("Crate Workspace")
        local crates = {}

        for _, object in ipairs(crateFolder:GetDescendants()) do
            if object:IsA("MeshPart") and object.Name == "Tank Crate" then
                table.insert(crates, object)
            end
        end

        if #crates == 0 then
            print("No Tank Crates available. Waiting...")
            wait(2)
        else
            for index, crate in ipairs(crates) do
                if not farmingEnabled then
                    print("Farming disabled mid-process. Stopping...")
                    return
                end

                print("Starting process for Tank Crate #" .. index)
                processTankCrate(crate)
                sellCrate()
            end
        end
    end

    print("Farming disabled. Returning to origin position.")
    teleportTo(player.Character.HumanoidRootPart.Position)
end

------------------------------------LOGGER-------------------------------

function functions.debugmode(val)
    if val then
        
    end
end

function functions.logger(type, err)
    if type == "warn" then
        elseif type == "print" then
        elseif type == "Success" then
    end
end

return functions