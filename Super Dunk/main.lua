--[[ 
    Created by HamstaGang on V3RM
    
    This is a prime example of a game of focusing on remote security without protecting functions.
    Why attempt to figure out remote security when you can just abuse the function directly?
    It's much faster this way anyways :troll:
]]--

-- Game Modules
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Modules = ReplicatedStorage:WaitForChild("Modules", 9e9)

-- Game Functions (from Modules)
local Network = require(Modules.Core.Network);
local StateManager = require(Modules.StateManager);
local Monetization_Client = require(Modules.Monetization_Client);
local Button_Settings = require(Modules.Interface.PrimaryButtons.Settings);

-- UI LIB
local SolarisLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/sol"))();

local MainWindow = SolarisLib:New({
   Name = "Super Dunk | (HamstaGang)",
   FolderToSave = "SolarisLibStuff"
})

-- UI Tabs
local AutoFarm_tab = MainWindow:Tab("Auto Farm");
local AutoFarm = AutoFarm_tab:Section("Farming");
local Other = AutoFarm_tab:Section("Other");

-- Auto Dunk Toggle
AutoFarm:Toggle("Auto Dunk", false, "AutoDunk_Toggle", function(bool)
    AutoDunk_Toggle = bool;
    if AutoDunk_Toggle then
        task.spawn(pcall(function()
            while AutoDunk_Toggle and task.wait(0.3) do
                Network:InvokeServer("Jump.Jumped", StateManager.GetStateValue("Hoop"));
            end
        end))
    end
end)

-- Auto Dribble Toggle
AutoFarm:Toggle("Auto Dribble", false, "AutoDribble_Toggle", function(bool)
    AutoDribble_Toggle = bool;
    if AutoDribble_Toggle then
        task.spawn(pcall(function()
            while AutoDribble_Toggle and task.wait(0.3) do
                Network:FireServer("Jump.Dribbled");
            end
        end))
    end
end)

-- Auto Purchase Power Toggle
AutoFarm:Toggle("Auto Power Upgrade", false, "AutoPowerPurchase_Toggle", function(bool)
    AutoPowerPurchase_Toggle = bool;
    if AutoPowerPurchase_Toggle then
        task.spawn(pcall(function()
            while AutoPowerPurchase_Toggle and task.wait(3) do
                Network:InvokeServer("Upgrades.Purchase");
            end
        end))
    end
end)

-- Auto Rebirth Toggle
AutoFarm:Toggle("Auto Rebirth", false, "AutoRebirth_Toggle", function(bool)
    AutoRebirth_Toggle = bool;
    if AutoRebirth_Toggle then
        task.spawn(pcall(function()
            while AutoRebirth_Toggle and task.wait(5) do
                Network:FireServer("Rebirth.Confirm");
            end
        end))
    end
end)

-- Free Gamepasses
Other:Button("Free Gamepasses (ONLY SOME)", function()
    -- Spoof Gamepass Check
    Monetization_Client.CheckOwnsPass = function() return true; end
end)
