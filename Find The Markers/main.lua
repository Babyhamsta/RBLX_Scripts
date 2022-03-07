-- Plr Vars
local Plr = game:GetService("Players").LocalPlayer
local Char = Plr.Character

-- UI Lib
local lib = loadstring(game:HttpGet"https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/UILibs/FluxusUI.lua")()

-- Main Window
local window = lib:CreateWindow("Find The Markers")

-- Main Section
local page = window:NewTab("Main")
local AutoSection = page:AddSection("Auto Collect")
local TPSection = page:AddSection("TPs")
 
AutoSection:AddButton("Collect Markers", "Auto collects all markers on the map", function()
    local Children = workspace:GetDescendants()
    local MarkerGUI = Plr.PlayerGui.Menu.AllMarkers.Markers
    
    for index, child in pairs(Children) do
        pcall(function()
            if (child.Name == "Color 1" and MarkerGUI[child.Parent.Name].BackgroundColor3 == Color3.fromRGB(0, 0, 0) and (child.Parent.Name ~= "Catzo Marker" and child:FindFirstChildWhichIsA("TouchTransmitter"))) then
                local i = tick()
                while Char.HumanoidRootPart.CFrame ~= child.CFrame do
                    Char.HumanoidRootPart.CFrame = child.CFrame
                    Char.Humanoid.Jump = true
                    wait();
                        
                    -- Wait 7 seconds then continue
                    if tick() - i >= 7 then
                        i = tick()
                        break;
                    end
                end
            end
        end)
    end
end)

if game.PlaceId == 7896264844 then
    TPSection:AddButton("Teleport To Medieval Game", "Teleports you to the Medieval game to collect more markers.", function()
        local TP = game:GetService("Workspace").MedievalTP
        repeat wait(); Char.HumanoidRootPart.CFrame = TP.CFrame  until false; -- never stop
    end)
    
    AutoSection:AddButton("Collect Special Markers/Badges", "Auto collects special markers and badges.", function()
        -- Remotes
        local Replicated = game:GetService("ReplicatedStorage")
        local Get = Replicated.Get
        local Hi = Replicated.Hi
        local Technical = Replicated.Technical
        local Stack = Replicated.Stack
        local Pray = Replicated.Pray
        
        -- Collect some remote markers
        Hi:FireServer();
        Technical:FireServer();
        Stack:FireServer();
        Pray:FireServer();
        
        local winningbutton = game:GetService("Workspace")["Winning Marker"]["Color 1"]
        Char.HumanoidRootPart.CFrame = winningbutton.CFrame
        wait(0.1)
        Get:FireServer(game.ReplicatedStorage.Markers["Winning Marker"]);
        wait(2)
        
        local invertedbttn = game:GetService("Workspace")["Inverted Marker Button"]
        Char.HumanoidRootPart.CFrame = invertedbttn.CFrame
        wait(2)
        
        -- collect inverted
        local invertedmarker = game:GetService("Workspace")["Inverted Marker"]["Color 1"]
        Get:FireServer(game.ReplicatedStorage.Markers["Inverted Marker"]);
        wait(2)
        
        local Explode = game:GetService("Workspace").ExplodeButton.Button;
        Char.HumanoidRootPart.CFrame = Explode.CFrame
        fireclickdetector(Explode.ClickDetector);
    end)
elseif game.PlaceId == 8506260179 then
    game.ReplicatedStorage.Merchant:FireServer();
    TPSection:AddButton("Teleport To Main Game", "Teleports you back to the main game.", function()
        local TP = game:GetService("Workspace").Medieval.Go
        repeat wait(); Char.HumanoidRootPart.CFrame = TP.CFrame  until false; -- never stop
    end)
end
