repeat wait() until game:IsLoaded()

-- Players
local Players = game:GetService("Players");
local Plr = Players.LocalPlayer

-- Wally's Lib
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/UILibs/WallyUI.lua", true))()

-- Main Window
local a = library:CreateWindow("Bloxton Mystery")

-- Buttons
local ESP_Toggle = a:Toggle("Role ESP", {flag = "RoleESP"})

-- Credit Tag
a:Section("Created by HamstaGang");

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

-- Clear Player ESP
function ClearESP(espname)
    for _,v in pairs(game.CoreGui:GetChildren()) do
        if v.Name == espname and v:isA('BillboardGui') then
            v:Destroy()
        end
    end
end

-- AC Remote
local ACRemote = game:GetService("ReplicatedStorage").Remotes.FinishAudio

-- AC Bypass
local ACBypass
ACBypass = hookmetamethod(game, "__namecall", function(...)
    local method = getnamecallmethod();
    local args = ...;

    if not checkcaller() then
        if typeof(self) == "Instance" and self == ACRemote and method == "FireServer" then
            return wait(9e9);
        end
    end

    return ACBypass(...)
end)

-- [[ ESP Loops ]] --

-- ESP Team Colors
local Town = {"Bodyguard", "Bounty Hunter", "Distractor", "Doctor", "Investigator", "Jailor", "Lookout", "Medium", "Retributionist", "Sheriff", "Trapper", "Veteran", "Vigilante"}
local Mafia = {"Assassin", "Blackmailer", "Consigliere", "Framer", "Godfather", "Janitor", "Mafioso", "Toxicologist"}
local Special = {["Amnesiac"] = Color3.new(0, 170, 255), ["Arsonist"] = Color3.new(255, 85, 0), ["Executioner"] = Color3.new(135, 135, 135), ["Vampire"] = Color3.new(108, 108, 108), ["Jester"] = Color3.new(255, 170, 255), ["Serial Killer"] = Color3.new(0, 85, 255)}

-- ESPPlayers
spawn(function()
    while wait(0.3) do
        if a.flags.RoleESP then
            pcall(function()
                local _Players = Players:GetChildren()
                ClearESP("playertracker")
                for _,v in pairs(_Players) do
                    if v ~= Plr then
                        local temp_plr = Players.LocalPlayer
                        local studs = temp_plr:DistanceFromCharacter(v.Character.PrimaryPart.Position)
                        if studs <= 5000 then
                            local TeamColor = Color3.new(255,255,255);

                            if table.find(Town, v.PlayerData.Role.Value) then
                                TeamColor = Color3.new(3, 179, 0);
                            elseif table.find(Mafia, v.PlayerData.Role.Value) then
                                TeamColor = Color3.new(170, 0, 0);
                            elseif Special[v.PlayerData.Role.Value] then
                                TeamColor = Special[v.PlayerData.Role.Value];
                            end

                            Create(v.Character.Head, false, v.PlayerData.DisplayName.Value .. " | " .. v.PlayerData.Role.Value, "playertracker", TeamColor, math.floor(studs + 0.5))
                        end
                    end
                end
            end)
        else
            ClearESP("playertracker");
        end
    end
end)
