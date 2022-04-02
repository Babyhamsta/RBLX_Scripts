-- This is a WIP so it doesn't have much.. game it garb.

-- Wally's Lib
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/UILibs/WallyUI.lua", true))()

-- Anti-AFK
for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
    v:Disable()
end

-- Plr
local Plr = game:GetService("Players").LocalPlayer
local Char = Plr.Character

-- Anti Cheat
local anticheat
anticheat = hookmetamethod(game, "__index", newcclosure(function(...)
    local self, k = ...
    
    if not checkcaller() and k == "WalkSpeed" and self.Name == "Humanoid" then
        return 16;
    elseif not checkcaller() and k == "JumpPower" and self.Name == "Humanoid" then
        return 16;
    elseif not checkcaller() and k == "Gravity" and self.Name == "Workspace" then
        return 196.2;
    end
    
    return anticheat(...)
end))

-- Part of Anti Cheat Bypass
local antikick
antikick = hookmetamethod(game, "__namecall", newcclosure(function(...)
    local self, k = ...
    
    if not checkcaller() and k == "Kick" then
        return;
    end
    
    return antikick(...)
end))

-- Main Window
local a = library:CreateWindow("Sakura Stand")

-- Credit Tag
a:Section("Created by HamstaGang");


-- Plr Mods Window
local b = library:CreateWindow("Plr Mods")

-- No Jump Cooldown
local Jump_Cooldown = b:Button('Anti Jump Cooldown', function()
    local antifloor
    antifloor = hookmetamethod(game, "__index", newcclosure(function(...)
        local self, k = ...
        
        if not checkcaller() and k == "FloorMaterial" and self.Name == "Humanoid" then
            return "Plasic";
        end
        
        return antifloor(...)
    end))
end)
