local createui = {}
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local functions = loadstring(game:HttpGet("https://raw.githubusercontent.com/DOMARICU/wartycoon/refs/heads/main/functions.lua"))()

function createui.start()
  local Window = Rayfield:CreateWindow({
    Name = "War Tycoon Script",
    Icon = 0,
    LoadingTitle = "1.2.5",
    LoadingSubtitle = "by Furabyte",
    Theme = "Default",
  
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = true,
  
    ConfigurationSaving = {
       Enabled = true,
       FolderName = "furabyte",
       FileName = "WarTycoon"
    },
  
    Discord = {
       Enabled = false,
       Invite = "noinvitelink",
       RememberJoins = true
    },
  
    KeySystem = false,
    KeySettings = {
       Title = "Untitled",
       Subtitle = "Key System",
       Note = "No method of obtaining the key is provided",
       FileName = "Key",
       SaveKey = true,
       GrabKeyFromSite = false,
       Key = {"Hello"}
    }
  }) 
  createui.addelements(Window)
end

function createui.addelements(Window)
  local MAINTAB = Window:CreateTab("MAIN", "warehouse")
  local VISUALSTAB = Window:CreateTab("VISUALS", "crosshair")
  local RAGETAB = Window:CreateTab("RAGE", "swords")
  local INFOTAB = Window:CreateTab("INFO", "info")

  local Toggle = MAINTAB:CreateToggle({
    Name = "Fly",
    CurrentValue = false,
    Flag = "flytgl",
    Callback = function(Value)
      functions.fly(Value)
    end,
  })

  local Slider = MAINTAB:CreateSlider({
    Name = "Fly Speed",
    Range = {5, 100},
    Increment = 2,
    Suffix = "Fly Speed",
    CurrentValue = 50,
    Flag = "flyslider",
    Callback = function(Value)
      functions.adjustflyspeed(Value)
    end,
 })
end

return createui