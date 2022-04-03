-- This is a WIP so it doesn't have much.. game is garb.

-- Wally's Lib
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/UILibs/WallyUI.lua", true))()

-- Anti-AFK
for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
    v:Disable()
end

-- Plr
local Plr = game:GetService("Players").LocalPlayer
local Char = Plr.Character

-- Rand Locals
local Players = game:GetService("Players")
local maxplayerdistance = 500;
local maxboxdistance = 500;
local maxdummydistance = 500;

-- Anti Cheat
local anticheat
anticheat = hookmetamethod(game, "__index", newcclosure(function(...)
    local self, k = ...
    
    if not checkcaller() and k == "WalkSpeed" and self.Name == "Humanoid" then
        return 16;
    elseif not checkcaller() and k == "JumpPower" and self.Name == "Humanoid" then
        return 50;
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

local WalkSpeed = b:Slider("WalkSpeed", {min = 16; max = 150; flag = "WalkSpeed"}, function(WalkSpeed)
    pcall(function()
        while task.wait() do
            local Char = Plr.Character
            Char.Humanoid.WalkSpeed = WalkSpeed;
        end
    end)
end)

local JumpPower = b:Slider("JumpPower", {min = 50; max = 350; flag = "JumpPower"}, function(JumpPower)
    pcall(function()
        while task.wait() do
            local Char = Plr.Character
            Char.Humanoid.JumpPower = JumpPower;
        end
    end)
end)

local Gravity = b:Slider("Gravity", {min = 1; max = 196.2; flag = "WPGrav"}, function(Gravity)
    pcall(function()
        while task.wait() do
            Workspace.Gravity = Gravity;
        end
    end)
end)


-- ESP Window
local c = library:CreateWindow("ESP")

-- GUI Items (ESP Window)
c:Section("ESP Players");
local ESPPlayers = c:Toggle("Esp Players", {flag = "ESPPlayers"})
local ESPPlayers_MAX = c:Slider("Max Studs", {min = 1; default = 500; max = 3000; flag = "ESPPlayers_MAX"}, function(studs)
  maxplayerdistance = studs;
end)

c:Section("ESP Boxes");
local ESPBoxes = c:Toggle("Esp Boxes", {flag = "ESPBoxes"})
local ESPBoxes_MAX = c:Slider("Max Studs", {min = 1; default = 500; max = 3000; flag = "ESPBoxes_MAX"}, function(studs)
  maxboxdistance = studs;
end)

c:Section("ESP Dummys");
local ESPDummy = c:Toggle("Esp Dummys", {flag = "ESPDummy"})
local ESPDummy_MAX = c:Slider("Max Studs", {min = 1; default = 500; max = 3000; flag = "ESPDummy_MAX"}, function(studs)
  maxdummydistance = studs;
end)


-- [[ ESP Function (Very Basic) ]] --

function Create(base, team, name, trackername, color, studs)
   local bb = Instance.new('BillboardGui', game.CoreGui)
   bb.Adornee = base
   bb.ExtentsOffset = Vector3.new(0,1,0)
   bb.AlwaysOnTop = true
   bb.Size = UDim2.new(0,6,0,6)
   bb.StudsOffset = Vector3.new(0,1,0)
   bb.Name = trackername
   
   local frame = Instance.new('Frame', bb)
   frame.ZIndex = 10
   frame.BackgroundTransparency = 0.3
   frame.Size = UDim2.new(1,0,1,0)
   frame.BackgroundColor3 = color
   
   local txtlbl = Instance.new('TextLabel', bb)
   txtlbl.ZIndex = 10
   txtlbl.BackgroundTransparency = 1
   txtlbl.Position = UDim2.new(0,0,0,-48)
   txtlbl.Size = UDim2.new(1,0,10,0)
   txtlbl.Font = 'ArialBold'
   txtlbl.FontSize = 'Size12'
   txtlbl.Text = name
   txtlbl.TextStrokeTransparency = 0.5
   txtlbl.TextColor3 = color
   
   local txtlblstud = Instance.new('TextLabel', bb)
   txtlblstud.ZIndex = 10
   txtlblstud.BackgroundTransparency = 1
   txtlblstud.Position = UDim2.new(0,0,0,-35)
   txtlblstud.Size = UDim2.new(1,0,10,0)
   txtlblstud.Font = 'ArialBold'
   txtlblstud.FontSize = 'Size12'
   txtlblstud.Text = tostring(studs) .. " Studs"
   txtlblstud.TextStrokeTransparency = 0.5
   txtlblstud.TextColor3 = Color3.new(255,255,255)
end

function CreateNonPlrESP(WPItem, espname, maxdistance)
    pcall(function()
        local WrkspaceItem = game:GetService("Workspace"):FindFirstChild(WPItem)
        ClearESP(espname)
        for _,v in pairs(WrkspaceItem:GetChildren()) do
            if WPItem == "Living" then
                if not Players:FindFirstChild(v.Name) then
                    local temp_plr = Players.LocalPlayer
                    local studs = temp_plr:DistanceFromCharacter(v.PrimaryPart.Position)
                    
                    if studs <= maxdistance then
                        Create(v.Head, false, v.Name, espname, Color3.new(0,250,0), math.floor(studs + 0.5))
                    end
                end
            else 
                local temp_plr = Players.LocalPlayer
                local studs = temp_plr:DistanceFromCharacter(v.PrimaryPart.Position)
                if studs <= maxdistance then
                    Create(v.PrimaryPart, false, v.Name, espname, Color3.new(0,0,250), math.floor(studs + 0.5))
                end
            end
        end
    end)
end

-- Clear Player ESP
function ClearESP(espname)
   for _,v in pairs(game.CoreGui:GetChildren()) do
       if v.Name == espname and v:isA('BillboardGui') then
           v:Destroy()
       end
   end
end


-- ESPPlayers
spawn(function()
   while wait(0.3) do
       if c.flags.ESPPlayers then
          pcall(function()
               local _Players = Players:GetChildren()
               ClearESP("playertracker")
               for _,v in pairs(_Players) do
                   if v ~= Plr then
                       local temp_plr = Players.LocalPlayer
                       local studs = temp_plr:DistanceFromCharacter(v.Character.PrimaryPart.Position)
                       if studs <= maxplayerdistance then
                           Create(v.Character.Head, false, v.Name, "playertracker", Color3.new(250,0,0), math.floor(studs + 0.5))
                       end
                   end
               end
           end)
       else
           ClearESP("playertracker");
       end
   end
end)

-- ESPBoxes
spawn(function()
   while wait(0.3) do
        if c.flags.ESPBoxes then
            CreateNonPlrESP("Item", "boxtracker", maxboxdistance)
        else
           ClearESP("boxtracker");
        end
   end
end)

-- ESP Dummy / Chariot
spawn(function()
   while wait(0.3) do
        if c.flags.ESPDummy then
            CreateNonPlrESP("Living", "dummytracker", maxdummydistance)
        else
           ClearESP("dummytracker");
        end
   end
end)
