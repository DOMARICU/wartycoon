local createui = {}
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

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
end

return createui
