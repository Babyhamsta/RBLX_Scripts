-- This is a WIP so it doesn't have much.. game is garb.

-- Wally's Lib
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/UILibs/WallyUI.lua", true))()

-- Anti-AFK
for i,v in pairs(getconnections(game.Players.LocalPlayer.Idled)) do
    v:Disable()
end

-- Plr
local Plr = game:GetService("Players").LocalPlayer
local Plr_GUI = Plr.PlayerGui
local Char = Plr.Character

-- Rand Locals
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Players = game:GetService("Players")
local maxplayerdistance = 500;
local maxboxdistance = 500;
local maxdummydistance = 500;

-- Anti Cheat
local anticheat
anticheat = hookmetamethod(game, "__index", newcclosure(function(...)
    local self, k = ...
    
    if not checkcaller() and k == "WalkSpeed" and self.Name == "Humanoid" and self:IsA("Humanoid") and self.Parent == Char then
        return 16;
    elseif not checkcaller() and k == "JumpPower" and self.Name == "Humanoid" and self:IsA("Humanoid") and self.Parent == Char then
        return 50;
    elseif not checkcaller() and k == "Gravity" and self.Name == "Workspace" and self:IsA("Humanoid") and self.Parent == Char then
        return 196.2;
    end
    
    return anticheat(...)
end))

-- Part of Anti Cheat Bypass
local antikick
antikick = hookmetamethod(game, "__namecall", function(...)
    local self, k = ...

    if not checkcaller() and self == Plr and k == "Kick" then
        return;
    end
    
    return antikick(...)
end)

-- Main Window
local a = library:CreateWindow("Sakura Stand")

local AutoFarmBoxes = a:Toggle("Boxes Farm", {flag = "FarmBoxes"})
local AutoDummyFarm = a:Toggle("Dummy Farm", {flag = "FarmDummy"})
local AutoPlrFarm = a:Toggle("Player Farm", {flag = "FarmPlrs"})

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

-- Storage Window
local d = library:CreateWindow("Storage")

local Slot1
Slot1 = d:Button('Slot 1', function()
    game:GetService("ReplicatedStorage").StorageRemote.Slot1:FireServer()
    wait(3)
    pcall(function()
        local Storage = Plr_GUI:WaitForChild("StandStorage", 10).Outer.Inner.Inner;
        Slot1:Refresh(Storage["Slot1"].Text);
    end)
end)

local Slot2
Slot2 = d:Button('Slot 2', function()
    game:GetService("ReplicatedStorage").StorageRemote.Slot2:FireServer()
    wait(3)
    pcall(function()
        local Storage = Plr_GUI:WaitForChild("StandStorage", 10).Outer.Inner.Inner;
        Slot2:Refresh(Storage["Slot2"].Text);
    end)
end)

local Slot3
Slot3 = d:Button('Slot 3', function()
    game:GetService("ReplicatedStorage").StorageRemote.Slot3:FireServer()
    wait(3)
    pcall(function()
        local Storage = Plr_GUI:WaitForChild("StandStorage", 10).Outer.Inner.Inner;
        Slot3:Refresh(Storage["Slot3"].Text);
    end)
end)

local Slot4
Slot4 = d:Button('Slot 4', function()
    game:GetService("ReplicatedStorage").StorageRemote.Slot4:FireServer()
    wait(3)
    pcall(function()
        local Storage = Plr_GUI:WaitForChild("StandStorage", 10).Outer.Inner.Inner;
        Slot4:Refresh(Storage["Slot4"].Text);
    end)
end)

local Slot5
Slot5 = d:Button('Slot 5', function()
    game:GetService("ReplicatedStorage").StorageRemote.Slot5:FireServer()
    wait(3)
    pcall(function()
        local Storage = Plr_GUI:WaitForChild("StandStorage", 10).Outer.Inner.Inner;
        Slot5:Refresh(Storage["Slot5"].Text);
    end)
end)

local Slot6
Slot6 = d:Button('Slot 6', function()
    game:GetService("ReplicatedStorage").StorageRemote.Slot6:FireServer()
    wait(3)
    pcall(function()
        local Storage = Plr_GUI:WaitForChild("StandStorage", 10).Outer.Inner.Inner;
        Slot6:Refresh(Storage["Slot6"].Text);
    end)
end)

-- Quick Update All..
local Storage = Plr_GUI:WaitForChild("StandStorage", 10).Outer.Inner.Inner;
Slot1:Refresh(Storage["Slot1"].Text);
Slot2:Refresh(Storage["Slot2"].Text);
Slot3:Refresh(Storage["Slot3"].Text);
Slot4:Refresh(Storage["Slot4"].Text);
Slot5:Refresh(Storage["Slot5"].Text);
Slot6:Refresh(Storage["Slot6"].Text);

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

-- [[ Auto Farm Functions ]] --

local function KeySpam()
    pcall(function()
        VirtualUser:CaptureController();
        
        -- T Key
        VirtualInputManager:SendKeyEvent(true, "T", false, game)
        wait(0.3)
            
        -- Y Key
        VirtualInputManager:SendKeyEvent(true, "Y", false, game)
        wait(0.3)
            
        -- R Key
        VirtualInputManager:SendKeyEvent(true, "R", false, game)
        wait(0.3)
    end)
end

-- Dummy Attack Func
local function AttkDummy(dummy)
    pcall(function()
        local RootPart = Plr.Character.HumanoidRootPart
        RootPart.CFrame = dummy.PrimaryPart.CFrame + dummy.PrimaryPart.CFrame.lookVector * -3;
        VirtualUser:CaptureController();
        VirtualUser:ClickButton1(Vector2.new(0,0));
    end)
    
    spawn(function()
        KeySpam();
    end)
    task.wait()
end

-- Box Farm
spawn(function()
   while task.wait() do
        if a.flags.FarmBoxes and not a.flags.FarmDummy and not a.flags.FarmPlrs then
            local Boxes = game:GetService("Workspace").Item
            
            for _,v in pairs(Boxes:GetChildren()) do
                if a.flags.FarmBoxes then -- Double check
                    local RootPart = Char.HumanoidRootPart
                    RootPart.CFrame = v.PrimaryPart.CFrame;
                    wait(1.5)
                    fireclickdetector(v:FindFirstChildOfClass("ClickDetector"));
                end
            end
        end
   end
end)

-- Dummy Farm
spawn(function()
   while task.wait() do
        if a.flags.FarmDummy and not a.flags.FarmBoxes and not a.flags.FarmPlrs then
            local Living = game:GetService("Workspace").Living
            
            for _,v in pairs(Living:GetChildren()) do
                if a.flags.FarmDummy and v.Name == "Dummy" then -- Double check
                    repeat AttkDummy(v) until (v.Humanoid.Health <= 0 or not a.flags.FarmDummy)
                end
            end
        end
   end
end)

-- Plr Farm
spawn(function()
   while task.wait() do
        if a.flags.FarmPlrs and not a.flags.FarmBoxes and not a.flags.FarmDummy then
            local Players = game:GetService("Players")
            for _,v in pairs(Players:GetChildren()) do
                if a.flags.FarmPlrs and v ~= Plr then -- Double check
                    repeat AttkDummy(v.Character) until (v.Character.Humanoid.Health <= 0 or not a.flags.FarmPlrs)
                end
            end
        end
   end
end)
