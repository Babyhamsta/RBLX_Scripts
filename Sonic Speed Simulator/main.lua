-- Wait until fully loaded.
repeat wait() until game:IsLoaded();

-- Global toggles
getrenv().AutoStep = false;
getrenv().AutoRebirth = false;
getrenv().AutoCollect = false;
getrenv().AutoBankRewards = false;
getrenv().AutoRaceWin = false;
getrenv().AutoCollectShards = false;

-- Services
local Players = game:GetService("Players");
local TweenService = game:GetService("TweenService");
local RunService = game:GetService("RunService");
local Knit = require(game:GetService("ReplicatedStorage").Knit)

-- Random Locals
local RootPart = Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart");
local TweenData = TweenInfo.new(math.random(1,99), Enum.EasingStyle.Linear);
local Rand = math.random(1,999999999);

-- Teleport Func
function TP()
    local TPCFrame = CFrame.new(Rand,Rand,Rand);
    local tween,err = pcall(function()
        local tween = TweenService:Create(RootPart, TweenData, {CFrame=TPCFrame});
        tween:Play();
    end)
end

-- UI Lib
local Luminosity = loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/UILibs/LuminosityV1.lua"))()

-- Main UI Stuff
local Window = Luminosity.new("Sonic Speed Sim", "By HamstaGang", 1290583218)
local AutoFarm = Window.Tab("Auto Farm")
local Other = Window.Tab("Unlocks")

-- Auto Steps
local Auto_Steps = AutoFarm.Cheat("Auto Step", "Auto increase steps", function(boolean)
    if boolean then
        AutoStep = boolean;
    else
        AutoStep = boolean;
        Players.LocalPlayer.Character.Head:Destroy(); -- reset
    end
end)

-- Auto Rebirth
local Auto_Rebirth = AutoFarm.Cheat("Auto Rebirth", "Auto rebirth at max level", function(boolean)
    AutoRebirth = boolean;
end)

-- Auto Collect
local Auto_Collect = AutoFarm.Cheat("Auto Collect", "Auto collect all rings/orbs", function(boolean)
    AutoCollect = boolean;
end)

-- Auto Bank Rewards
local Auto_Bank_Rewards = AutoFarm.Cheat("Auto Bank Rewards", "Auto collects bank rewards (every 6 hours)", function(boolean)
    AutoBankRewards = boolean;
end)

-- Auto Race Win
local Auto_Race_Win = AutoFarm.Cheat("Auto Race Win", "Auto joins and wins races.", function(boolean)
    AutoRaceWin = boolean;
end)

-- Auto Collect Shards
local Auto_Collect_Shards = AutoFarm.Cheat("Auto Collect Shards", "Teleports all Shards (aka Character Fragments) to you upon their spawning.", function(boolean)
    AutoCollectShards = boolean;
end)


-- [[ Other Tab ]] --
local UnlockWorlds = Other.Folder("Unlock Worlds", "Unlock all the worlds.")
local UnlockCharacters = Other.Folder("Unlock Characters", "Unlock all the characters.")


-- Unlock All Worlds
local World_Unlock_All = UnlockWorlds.Button("", "Unlock Worlds", function()
    local Knit = game:GetService("ReplicatedStorage").Knit;
    local RequestTeleportToZone = Knit.Services.ZoneService.RF.RequestTeleportToZone;
    local CompleteZoneObby = Knit.Services.ZoneService.RF.CompleteZoneObby;
    
    RequestTeleportToZone:InvokeServer("Lost Valley Obby", "Green Hill Exit")
    CompleteZoneObby:InvokeServer()
    wait(0.3)
    
    RequestTeleportToZone:InvokeServer("Emerald Hill Obby", "Lost Valley Exit")
    CompleteZoneObby:InvokeServer()
    wait(0.3)
    
    RequestTeleportToZone:InvokeServer("Snow Valley Obby", "Emerald Hill Exit")
    CompleteZoneObby:InvokeServer()
end)

-- Unlock All Characters
local Character_Unlock_All = UnlockCharacters.Button("", "Unlock Characters", function()
    local Knit = game:GetService("ReplicatedStorage").Knit;
    local RequestUnlockCharacter = Knit.Services.CharacterService.RE.RequestUnlockCharacter;
    local RequestTeleportToZone = Knit.Services.ZoneService.RF.RequestTeleportToZone;
    local RedeemCode = Knit.Services.RedeemService.RF.RedeemCode;
    
    RequestTeleportToZone:InvokeServer("Green Hill")
    RequestUnlockCharacter:FireServer("sonic")
    wait(0.3)
    
    RequestTeleportToZone:InvokeServer("Lost Valley")
    RequestUnlockCharacter:FireServer("tails")
    wait(0.3)
    
    RequestTeleportToZone:InvokeServer("Emerald Hill")
    RequestUnlockCharacter:FireServer("knuckles")
    wait(0.3)
    
    RedeemCode:InvokeServer("riders")
end)

-- Menu Closing Function
game:GetService("UserInputService").InputBegan:Connect(function(Input)
    if Input.KeyCode == Enum.KeyCode.RightControl then
        Window:Toggle()
    end
end)

-- Anti AFK
for i,v in pairs(getconnections(Players.LocalPlayer.Idled)) do
    v:Disable()
end

-- [[ Auto Farm Functions ]] --

-- Auto Step
spawn(function()
    RunService.RenderStepped:Connect(function()
        if AutoStep then
            pcall(function() TP(); end)
        end
    end)
end)

-- Auto Rebirth
spawn(function()
    while wait(3) do
        if AutoRebirth then
            local Knit = game:GetService("ReplicatedStorage").Knit;
            local AttemptRebirth = Knit.Services.LevelingService.RF.AttemptRebirth;
            AttemptRebirth:InvokeServer();
        end
    end
end)

-- Auto Collect All
spawn(function()
    while wait(5) do -- They respawn every 60 seconds so no need to spam.
        if AutoCollect then
            local ReplicatedStorage = game:GetService("ReplicatedStorage");
            local PickupCurrency = ReplicatedStorage.Knit.Services.WorldCurrencyService.RE.PickupCurrency;
            local Objects = game:GetService("Workspace").Map.Objects;
        
            for i,v in pairs(Objects:GetChildren()) do
            	if v:IsA("Model") then 
            		PickupCurrency:FireServer(v.Name)
            	end
            end
        end
    end
end)

-- Auto Bank Rewards
spawn(function()
    while wait(5) do -- You have to wait 6 hours until you can collect again so we check every 10 mins.
        if AutoBankRewards then
            local Plr = game:GetService("Players").LocalPlayer;
            local RewardsBanks = game:GetService("Workspace").Map.Collision.RewardBanks;
            local v1 = require(game:GetService("ReplicatedStorage").Knit);
            
            for i,v in pairs(RewardsBanks:GetChildren()) do
                if v:IsA("Model") then
                    v1.GetService("RewardService").GiveRewardInBank(Plr, v.Name); -- Directly call Knit func.
                end
            end
        end
    end
end)

-- Auto Race Win (We use the in-game funcs *troll*)
local CharacterService = Knit.GetService("CharacterService");
local RaceService = Knit.GetService("RaceService");
local RaceController = Knit.GetController("RaceController");

RaceService.RaceStarting:Connect(function(GUID)
    if AutoRaceWin then
        local RaceEnd = game:GetService("Workspace").Map.Triggers:WaitForChild("RaceEndZone")
        wait(6.5) -- Wait for race to start
        CharacterService.CharacterTouchedTrigger:Fire(tostring(RaceEnd:GetAttribute("GUID")));
    end
end);

RaceService.PromptRace:Connect(function(idek, GUID)
    if AutoRaceWin then
        RaceService.JoinRace:Fire(GUID);
    end
end)

-- Auto Collect Shards
local CharacterShardService = Knit.GetService("CharacterShardService");

CharacterShardService.SpawnCharacterShards:Connect(function(ShardData, Shards)
    if AutoCollectShards then
        local ShardName = ShardData["ShardName"];
        local CurrentZone = ShardData["CurrentZone"];
        
    	for _,Shard in pairs(Shards) do
    	    local Objects = game:GetService("Workspace"):WaitForChild("Map").Objects;
            local GUID = Shard["GUID"];
            --local UnlockZone = Shard["UnlockZone"];
            
            pcall(function()
                Objects[GUID].Card.CFrame = RootPart.CFrame;
            end)
    	end
    end
end);
