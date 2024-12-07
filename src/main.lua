local functions = {}

local isFlying = false
local isNoclip = false
local hitboxEnabled = false
local autocratefarm = false
local autobuy = false
local aimbotEnabled = false
local dbger = false

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
local userInputService = game:GetService("UserInputService")

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
            FDMG.Name = "FDMG"
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
    functions.debugmode("print", "TEST!")
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

------------------AIMBOT---------------

function functions.aimhelper(value)
    local aimbotEnabled = false
    local userInputService = game:GetService("UserInputService")
    local players = game:GetService("Players")
    local localPlayer = players.LocalPlayer

    local function getNearestPlayer()
        local localCharacter = localPlayer.Character
        local localHumanoidRootPart = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart") --HumanoidRootPart

        if not localHumanoidRootPart then
            return nil
        end

        local nearestPlayer = nil
        local shortestDistance = math.huge

        for _, player in pairs(players:GetPlayers()) do
            if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") then
                local targetHumanoidRootPart = player.Character.HumanoidRootPart
                
                if targetHumanoidRootPart:IsDescendantOf(workspace) then
                    local distance = (localHumanoidRootPart.Position - targetHumanoidRootPart.Position).Magnitude

                    if distance < shortestDistance then
                        shortestDistance = distance
                        nearestPlayer = targetHumanoidRootPart
                    end
                end
            end
        end

        return nearestPlayer
    end

    local function isFirstPerson()
        local camera = workspace.CurrentCamera
        return (camera.CFrame.Position - camera.Focus.Position).Magnitude < 1
    end

    if value and not aimbotEnabled then
        aimbotEnabled = true
        print("Aimbot activated.")

        userInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end

            if input.UserInputType == Enum.UserInputType.MouseButton2 then
                while aimbotEnabled and userInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) do
                    if isFirstPerson() then 
                        local nearestTarget = getNearestPlayer()

                        if nearestTarget then
                            local camera = workspace.CurrentCamera
                            camera.CFrame = CFrame.new(camera.CFrame.Position, nearestTarget.Position)
                        end
                    end

                    wait(0.03)
                end
            end
        end)

    elseif not value and aimbotEnabled then
        aimbotEnabled = false
        print("Aimbot deactivated.")
    end
end

-------------------FARMING--------------
function functions.cratefarming(value)
    if value and not autocratefarm then
        autocratefarm = true

        --[[ local function teleportTo(position)
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(position)
                wait(1)
            else
                functions.debugmode("warn", "Player HumanoidRootPart not found.")
            end
        end *]]

        local function calculateOffset(objectPosition, playerPosition)
            local direction = (playerPosition - objectPosition).Unit -- Richtung vom Objekt zum Spieler
            return direction * 3 -- Versatz um 5 Studs in Richtung weg vom Objekt
        end

        local function teleportTo(position)
            local playerPosition = player.Character and player.Character.PrimaryPart and player.Character.PrimaryPart.Position
            local offset = calculateOffset(position, playerPosition)
            local targetPosition = position + offset
        
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(targetPosition)
                wait(1)
            else
                functions.debugmode("warn", "Player HumanoidRootPart not found.")
            end
        end

        local function activatePrompt(prompt)
            if prompt and prompt:IsA("ProximityPrompt") then
                print("Activating ProximityPrompt: " .. prompt.Name)
                prompt:InputHoldBegin()
                wait(prompt.HoldDuration or 0.8)
                prompt:InputHoldEnd()
            else
                functions.debugmode("warn", "Invalid or missing ProximityPrompt.")
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
                    functions.debugmode("warn", "StealPrompt not found in Tank Crate.")
                end
            else
                functions.debugmode("warn", "Tank Crate is nil.")
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
                        functions.debugmode("print", "Teleporting to Crate Collector.")
                        teleportTo(collectorPart.Position)
                        activatePrompt(sellPrompt)
                    else
                        functions.debugmode("warn", "SellPrompt not found in Crate Collector.")
                    end
                else
                    functions.debugmode("warn", "Collector part not found for team: " .. tostring(teamValue))
                end
            else
                functions.debugmode("warn", "Tycoon not found for team: " .. tostring(teamValue))
            end
        end

        functions.debugmode("print", "Crate farming enabled.")

        while autocratefarm do
            local crateFolder = Workspace:WaitForChild("Game Systems"):WaitForChild("Crate Workspace")
            local crates = {}

            for _, object in ipairs(crateFolder:GetDescendants()) do
                if object:IsA("MeshPart") and object.Name == "Tank Crate" then
                    table.insert(crates, object)
                end
            end

            if #crates == 0 then
                functions.debugmode("print", "No Tank Crates available. Waiting...")
                wait(2)
            else
                for index, crate in ipairs(crates) do
                    if not autocratefarm then
                        functions.debugmode("print", "Farming disabled mid-process. Stopping...")
                        break
                    end

                    functions.debugmode("print", "Starting process for Tank Crate #" .. index)
                    processTankCrate(crate)
                    sellCrate()
                end
            end
        end

        functions.debugmode("print", "Farming disabled. Returning to origin position.")
        teleportTo(player.Character.HumanoidRootPart.Position)

    elseif not value and autocratefarm then
        autocratefarm = false
        functions.debugmode("print", "Crate farming disabled.")
    end
  end

  ---------------------------------AUTOBUILD----------------------------
  local exceptions = {
    --GAMEPASSES
    "2x Cash Gamepass",
    "2x Health Armor",
    "MP7 Giver",
    "USP 45 Giver",
    "AK12 Giver",
    "Saiga-12k Giver",
    "Explosive Sniper Giver",
    "FAL Heavy Giver",
    "Desert Eagle Giver",
    "AWP Giver",
    "Remington ACR Giver",
    "FAMAS Group Gun",
    "Speedy Oil Extractor",
    "Auto Collect Gamepass",
    "10k Shield Health Gamepass",
    "Speedy Humvee",
    "VCAC Mephisto",
    "BTR-80",
    "A-10 Air Strike Giver",
    "JLTV",
    "Mi28 Havoc",
    "Barrett M82",
    "GTE Shirt",

    --OPERATION
    "Boxer CRV",
    "LAV-AD",
    "M1117 Guardian",
    "Pantsir S1",
    "M142 HIMARS",
    "Lazar 3 APC",
    "Patriot AA",
    "Gunship",
    "UH-60 Black Hawk",
    "Super Stallion",
    "AH-64 Apache",
    "KA-52 Alligator",
    "Eurocopter Tiger",
    "Invictus",
    "AH-1Z Viper",
    "Raider X",
    "Fairmile",
    "PG-02",
    "USS Douglas",
    "Pr. 206",
    "KSG 12 Giver",
    "PP19 Bizon Giver",
    "Javelin Giver",
}

local rebirthstages = {
    ["Easter Egg [10 Rebirths]"] = 10,
    ["Planes [7 Rebirths]"] = 7,
    ["Tank Unlock Rebirth 6"] = 6,
    ["Drone [5 Rebirths]"] = 5,
    ["Missile Silo Start"] = 5,
    ["Unlock Bunker and Missile Silo [2 Rebirth]"] = 2,
    ["Vehicle Bay [1 Rebirth]"] = 1,
    ["Vietnam Unlock Rebirth 4"] = 4,
    ["Helicopters [3 Rebirths]"] = 3,
    ["Boats [3 Rebirths]"] = 3,
    ["Trading Hub [1 Rebirth]"] = 1,
    ["WW2 [4 Rebirths]"] = 4,
}

function functions.autobuilding(val)
    local player = game:GetService("Players").LocalPlayer
    local leaderstats = player:WaitForChild("leaderstats")
    local teamName = leaderstats:WaitForChild("Team").Value
    local cash = leaderstats:WaitForChild("Cash")
    local rebirths = leaderstats:WaitForChild("Rebirths")

    local unpurchasedButtons = workspace.Tycoon.Tycoons:FindFirstChild(teamName):FindFirstChild("UnpurchasedButtons")
    if not unpurchasedButtons then
        warn("UnpurchasedButtons folder not found for team " .. teamName)
        return
    end

    if val and not autobuy then
        autobuy = true
        local initialPosition = player.Character and player.Character.PrimaryPart and player.Character.PrimaryPart.Position

        while autobuy do
            local buttons = {}
            for _, button in ipairs(unpurchasedButtons:GetChildren()) do
                if not table.find(exceptions, button.Name) then
                    table.insert(buttons, button)
                end
            end

            if #buttons == 0 then
                print("No more buttons to purchase.")
                break
            end

            for _, button in ipairs(buttons) do
                if not autobuy then
                    print("Autobuy disabled mid-process. Stopping...")
                    break
                end

                local requiredRebirth = rebirthstages[button.Name]
                if requiredRebirth and rebirths.Value < requiredRebirth then
                    print("Skipping " .. button.Name .. " - requires rebirth level " .. requiredRebirth)
                    continue
                end

                local priceTag = button:FindFirstChild("Price")
                if priceTag and priceTag:IsA("IntValue") then
                    local price = priceTag.Value
                    if cash.Value >= price then
                        local part = button:FindFirstChild("Part")
                        if part and part:IsA("BasePart") then
                            local targetPosition = part.Position + Vector3.new(0, 7, 0)
                            if player.Character and player.Character.PrimaryPart then
                                player.Character:SetPrimaryPartCFrame(CFrame.new(targetPosition))
                                wait(0.4)
                            end
                        end
                    else
                        print("Not enough cash to buy " .. button.Name)
                    end
                else
                    print("Price not found in button " .. button.Name)
                end
                wait(0.1)
            end

            if not autobuy then
                print("Autobuy disabled mid-loop. Exiting...")
                break
            end

            wait(0.1)
        end

        if initialPosition and player.Character and player.Character.PrimaryPart then
            player.Character:SetPrimaryPartCFrame(CFrame.new(initialPosition))
        end
        autobuy = false
    else
        autobuy = false
        print("Autobuy disabled.")
    end
end

------------------------------------LOGGER-------------------------------

function functions.debugmode(type, val)
    if dbger then
        if type and val then
            if type == "warn" then
                warn("[WARN]: " .. tostring(val))
            elseif type == "success" then
                print("[SUCCESS]: " .. tostring(val))
            elseif type == "error" then
                error("[ERROR]: " .. tostring(val))
            elseif type == "print" then
                print("[LOG]: " .. tostring(val))
            else
                warn("[UNKNOWN TYPE]: " .. tostring(type) .. " with value: " .. tostring(val))
            end
        else
            print("[DEBUG]: Type or value cannot be found! Type: " .. tostring(type) .. ", Value: " .. tostring(val))
        end
    end
end


return functions