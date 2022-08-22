-- [[ HamstaGang on V3RM | Last updated 08/21/2022 ]] --

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local CoreGui = game:GetService("CoreGui");
local Players = game:GetService("Players");
local Workspace = game:GetService("Workspace");
local Lighting = game:GetService("Lighting");
local VirtualInputManager = game:GetService("VirtualInputManager");

-- Remote Stuff
local Events = ReplicatedStorage:WaitForChild("Events", 1337)

-- Local Player
local Player = Players.LocalPlayer;
local Character = Player.Character or Player.CharacterAdded:Wait()

-- UI Lib (Fluxus Lib because I like to shuffle them and they support WEAO <3)
local lib = loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/UILibs/FluxusUI.lua"))()

-- ESP support
local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/SimpleHighlightESP.lua"))()

-- Main Window
local Window = lib:CreateWindow("Evade Gui")

-- Create Pages
local MainPage = Window:NewTab("Main")
local ServerPage = Window:NewTab("Server")
local ESPPage = Window:NewTab("ESP")

-- Create Sections
local MainSection = MainPage:AddSection("Main")
local BhopSection = MainPage:AddSection("Bhop")
local ServerSection = ServerPage:AddSection("Server")
local ESPSection = ESPPage:AddSection("ESP")

-- GUI Toggles / Settings
local Highlights_Active = false;
local AI_ESP = false;
local GodMode_Enabled = false;
local Bhop_Enabled = false;
local Bhop_Cooldown = 0.9;

-- Simple Text ESP
function Simple_Create(base, name, trackername, studs)
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
    frame.BackgroundColor3 = Color3.fromRGB(255, 0, 0)

    local txtlbl = Instance.new('TextLabel', bb)
    txtlbl.ZIndex = 10
    txtlbl.BackgroundTransparency = 1
    txtlbl.Position = UDim2.new(0,0,0,-48)
    txtlbl.Size = UDim2.new(1,0,10,0)
    txtlbl.Font = 'ArialBold'
    txtlbl.FontSize = 'Size12'
    txtlbl.Text = name
    txtlbl.TextStrokeTransparency = 0.5
    txtlbl.TextColor3 = Color3.fromRGB(255, 0, 0)

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

-- Clear ESP
function ClearESP(espname)
    for _,v in pairs(game.CoreGui:GetChildren()) do
        if v.Name == espname and v:isA('BillboardGui') then
            v:Destroy()
        end
    end
end

-- God Mode (Credits to Egg Salad)
MainSection:AddButton("God Mode", "Gives you god mode", function()
    local Hum = Character:WaitForChild("Humanoid")
    Hum.Parent = nil;
    Hum.Parent = Character;
end)

MainSection:AddToggle("Loop God Mode", "Keeps god mode on", false, function(bool)
    GodMode_Enabled = bool;
end)

-- Auto Bhop (Credits to Egg Salad)
BhopSection:AddToggle("Auto Bhop", "Simply enable and jump once to start auto hopping", false, function(bool)
    Bhop_Enabled = bool;

    if bool then
        Character.Humanoid.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Landed then
                task.wait(Bhop_Cooldown)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait()
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end
        end)
    end
end)

BhopSection:AddSlider("Bhop cooldown", "Adjust to higher number if bhop stops jumping randomly (default 0.9 secs).", 0, 1.3, 0.9, true, function(val)
    Bhop_Cooldown = tonumber(val);
end)

-- Alpha Skin Giver
MainSection:AddButton("Alpha Skin", "Gives you the private alpha skin", function()
    Events.UI.Purchase:InvokeServer("Skins", "AlphaTester")
end)

-- Make server all bright so your eye balls can see
MainSection:AddButton("Full Bright", "For users who are scared of the dark :(", function()
    local light = Instance.new("PointLight", Character.HumanoidRootPart)
    light.Brightness = .3
    light.Range = 10000

    Lighting.TimeOfDay = "14:00:00"
    Lighting.FogEnd = 10000;
    Lighting.Brightness = 2;
    Lighting.Ambient = Color3.fromRGB(255,255,255)
    Lighting.FogColor = Color3.fromRGB(255,255,255)
end)


-- Crash Server (Credits to FeIix (V3RM) <3)
ServerSection:AddButton("Crash Server", "Crashes the server", function()
    local Respawn = Events:FindFirstChild("Respawn")
    while task.wait() do
        if Respawn then
            Respawn:FireServer()
        end
    end
end)


-- Character Highlights
ESPSection:AddButton("Character Highlights", "Highlights all characters to make them easier to see.", function()
    ESP:ClearESP();
    Highlights_Active = true;

    for i, v in ipairs(Players:GetPlayers()) do
        if v ~= Player then
            v.CharacterAdded:Connect(function(Char)
                ESP:AddOutline(Char)
                ESP:AddNameTag(Char)
            end)

            if v.Character then
                ESP:AddOutline(v.Character)
                ESP:AddNameTag(v.Character)
            end
        end
    end
end)

-- AI Text ESP
ESPSection:AddToggle("AI ESP", "Adds text ESP to AI to make them easier to see.", false, function(bool)
    AI_ESP = bool;
end)

-- Highlight helper
game:GetService("Players").PlayerAdded:Connect(function(Player)
    Player.CharacterAdded:Connect(function(Char)
        if Highlights_Active then
            ESP:AddOutline(Char)
            ESP:AddNameTag(Char)
        end
    end)
end)

Player.CharacterAdded:Connect(function(Char)
    -- Godmode helper (Credits to Egg Salad)
    if GodMode_Enabled then
        local Hum = Char:WaitForChild("Humanoid")
        Hum.Parent = nil;
        Hum.Parent = Char;
    end
    -- Auto Bhop (Credits to Egg Salad)
    if Bhop_Enabled then
        Char.Humanoid.StateChanged:Connect(function(oldState, newState)
            if newState == Enum.HumanoidStateType.Landed then
                task.wait(Bhop_Cooldown)
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait()
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end
        end)
    end
end)


-- [[ LOOPS ]] --

-- ESP AI
task.spawn(function()
    while wait(0.3) do
        if AI_ESP then
            pcall(function()
                ClearESP("AI_Tracker")
                local GamePlayers = Workspace:WaitForChild("Game", 1337).Players;
                for i,v in pairs(GamePlayers:GetChildren()) do
                    if not game.Players:FindFirstChild(v.Name) then -- Is AI
                        local studs = Player:DistanceFromCharacter(v.PrimaryPart.Position)
                        Simple_Create(v.HumanoidRootPart, v.Name, "AI_Tracker", math.floor(studs + 0.5))
                    end
                end
            end)
        else
            ClearESP("AI_Tracker");
        end
    end
end)
