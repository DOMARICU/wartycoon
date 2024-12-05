local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local elementCustomizations = {
    Chat = function(element)
        local chatFrame = element:FindFirstChild("Chat")
        local lbl = game:GetService("Players").LocalPlayer.PlayerGui.Chat.Chat.CLS["bb9f9a6f-7f26-4038-92d9-0023227e7a1f"].Text
        if chatFrame and chatFrame:IsA("Frame") then
            chatFrame.BackgroundTransparency = 0.8
            chatFrame.BackgroundColor3 = Color3.fromRGB(255, 80, 80)

            local uiCorner = Instance.new("UICorner")
            uiCorner.CornerRadius = UDim.new(0, 20)
            uiCorner.Parent = chatFrame
        end

        if lbl and lbl:IsA("TextLabel") then
            lbl.Text = "BY VORTEX" else warn(lbl .." not found!")
        end
    end
}

local function checkAndCustomizeElements()
    for elementName, customizeFunc in pairs(elementCustomizations) do
        local element = playerGui:FindFirstChild(elementName)
        if element then
            print("UI-Element gefunden: " .. elementName)
            customizeFunc(element)
        else
            warn("UI-Element fehlt: " .. elementName)
        end
    end
end

checkAndCustomizeElements()

-- Server Script

-- ReplicatedStorage
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local skdaily = ReplicatedStorage:WaitForChild("SkipDaily")

-- Main

-- This is gonna fire whenever a Player invokes the Server
-- Let's say when they invoke the RemoteFunction (Client → Server)
-- They're requesting the value.

skdaily.OnServerInvoke = function(Player)
	-- Assuming the Player has a Leaderboard folder...
	return Player.Leaderboard.Level.Value
end