-- GetServices
local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");

-- Game Items
local Items = Workspace:WaitForChild("Items", 9e9);
local Events = ReplicatedStorage:WaitForChild("Events", 9e9);

-- Events
local PickupRemote = Events:WaitForChild("Pickup", 9e9)
local SwingTool = Events:WaitForChild("SwingTool", 9e9)

-- Player
local Plr = Players.LocalPlayer;
local Char = Plr.Character or Plr.CharacterAdded:Wait();
local Humanoid = Char:WaitForChild("Humanoid", 9e9);
local Root = Char:WaitForChild("HumanoidRootPart", 9e9);

-- Toggles
local NoSlowdown = false;
local AutoPickup = false;
local AutoHarvest = false;
local KillAura = false;

-- UI Lib
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/GreenDeno/Venyx-UI-Library/main/source.lua"))()
local Venyx = library.new("Booga Booga [REBORN]", 5013109572);

-- Player Page
local PlayerPage = Venyx:addPage("Player", 5012544693);
local PlSection1 = PlayerPage:addSection("Player Mods");

PlSection1:addToggle("No Slowdown/Speed Hack", nil, function(value)
NoSlowdown = value;
if (NoSlowdown) then
     -- Hook Walkspeed
     local old
     old = hookmetamethod(game, "__newindex", function(a, b, c)
     if NoSlowdown then
          if (tostring(a) == "Humanoid" and a:IsA("Humanoid")) and tostring(b) == "WalkSpeed" then
               return old(a, b, 18)
          end
     end
     return old(a, b, c)
     end)
end
end)

function ConvertToTable(Part, NoParent)
     if Part then
          if not NoParent then
               if Part.Parent then
                    Part = Part.Parent;
               end
          end

          local chd = Part:GetChildren();
          local t = {};

          for i,v in pairs(chd) do
               if v:IsA("Part") then
                    table.insert(t, v);
               end
          end

          return t;
     end

     return {}; -- empty table
end

local function GetClosestPlayer()
     local nearestPlayer, nearestDistance
     for _, player in pairs(Players:GetPlayers()) do
          if player ~= Plr then
               local character = player.Character
               if character then
                    local nroot = character:FindFirstChild("HumanoidRootPart")
                    if nroot then
                         local distance = Plr:DistanceFromCharacter(nroot.Position)
                         if (distance > 10) or (nearestDistance and distance >= nearestDistance) then continue end
                         nearestDistance = distance
                         nearestPlayer = player
                    end
               end
          end
     end
     if nearestPlayer and nearestPlayer.Character then
          return ConvertToTable(nearestPlayer.Character, true)
     else
          return {}
     end
end

PlSection1:addToggle("Player Kill Aura", nil, function(value)
KillAura = value;
if (KillAura) then
     task.spawn(function()
     while (KillAura and task.wait()) do
          local temp = GetClosestPlayer()
          if (#temp > 0) then -- avoid spamming
               SwingTool:FireServer(ReplicatedStorage:WaitForChild("RelativeTime", 9e9).Value, temp)
          end
     end
     end)
end
end)

-- Auto Page
local AutoPage = Venyx:addPage("Auto", 5012544693);
local AtSection1 = AutoPage:addSection("Auto Mods");

function GetClosestDroppedItem()
     local Closest;
     local RootPart = Char:FindFirstChild("HumanoidRootPart");
     if RootPart then
          local PlayerPosition = RootPart.Position;
          for i,v in pairs(Items:GetChildren()) do
               if v then
                    if v:IsA("Part") and v:FindFirstChild("Pickup") then
                         if Closest == nil then
                              if ((PlayerPosition - v.Position).magnitude < 15) then
                                   Closest = v
                              end
                         else
                              if (PlayerPosition - v.Position).magnitude < (Closest.Position - PlayerPosition).magnitude then
                                   Closest = v
                              end
                         end
                    end
               end
          end
     end
     return Closest;
end

AtSection1:addToggle("Auto Pickup", nil, function(value)
AutoPickup = value;
if (AutoPickup) then
     task.spawn(function()
     while (AutoPickup and task.wait()) do
          local temp = GetClosestDroppedItem();
          if (temp ~= nil) then
               PickupRemote:FireServer(temp)
          end
     end
     end)
end
end)

function GetClosestFarmItem()
     local Closest;
     local RootPart = Char:FindFirstChild("HumanoidRootPart");
     if RootPart then
          for i,v in pairs(Workspace:GetChildren()) do
               local PlayerPosition = RootPart.Position;
               local Health = v:FindFirstChild("Health");
               if Health and Health:IsA("IntValue") then
                    v = v:FindFirstChildOfClass("Part");
                    if v ~= nil and v.Position then
                         if Closest == nil then
                              if ((PlayerPosition - v.Position).magnitude < 15) then
                                   Closest = v
                              end
                         else
                              if (PlayerPosition - v.Position).magnitude < (Closest.Position - PlayerPosition).magnitude then
                                   Closest = v
                              end
                         end
                    end
               end
          end
     end
     return ConvertToTable(Closest, false);
end

AtSection1:addToggle("Auto Harvest", nil, function(value)
AutoHarvest = value;
if (AutoHarvest) then
     task.spawn(function()
     while (AutoHarvest and task.wait()) do
          local temp = GetClosestFarmItem()
          if (#temp > 0) then -- avoid spamming
               SwingTool:FireServer(ReplicatedStorage:WaitForChild("RelativeTime", 9e9).Value, temp)
          end
     end
     end)
end
end)

-- Toggle
local GUIPage = Venyx:addPage("Other", 5012544693);
local GUISection = GUIPage:addSection("GUI");

GUISection:addKeybind("Toggle UI Keybind", Enum.KeyCode.RightAlt, function()
Venyx:toggle()
end)

-- Load GUI
Venyx:SelectPage(Venyx.pages[1], true)
