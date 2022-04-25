-- Credit to Unordinary for the orginal chams.

local Players = game:GetService("Players");
local Plr = Players.LocalPlayer;

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

-- ESP Team Colors
local Town = {"Bodyguard", "Bounty Hunter", "Distractor", "Doctor", "Investigator", "Jailor", "Lookout", "Medium", "Retributionist", "Sheriff", "Trapper", "Veteran", "Vigilante"}
local Mafia = {"Assassin", "Blackmailer", "Consigliere", "Framer", "Godfather", "Janitor", "Mafioso", "Toxicologist"}
local Special = {["Amnesiac"] = Color3.new(0, 170, 255), ["Arsonist"] = Color3.new(255, 85, 0), ["Executioner"] = Color3.new(135, 135, 135), ["Vampire"] = Color3.new(108, 108, 108), ["Jester"] = Color3.new(255, 170, 255), ["Serial Killer"] = Color3.new(0, 85, 255)}

local function CreateCham(Part, TeamColor)
    local cham = Instance.new("BoxHandleAdornment", Part)
    cham.ZIndex = 10
    cham.Adornee = Part
    cham.AlwaysOnTop = true
    cham.Size = Part.Size
    cham.Transparency = 0
    cham.Color3 = TeamColor
    cham.Name = "TotallyNotACham"
end

for i,v in pairs(game:GetService("Players"):GetPlayers()) do
    if v ~= Plr then
        for i,b in pairs(v.Character:GetDescendants()) do
            if b.ClassName == "Part" then
                local TeamColor = Color3.new(255,255,255);

                if table.find(Town, v.PlayerData.Role.Value) then
                    TeamColor = Color3.new(3, 179, 0);
                elseif table.find(Mafia, v.PlayerData.Role.Value) then
                    TeamColor = Color3.new(170, 0, 0);
                elseif Special[v.PlayerData.Role.Value] then
                    TeamColor = Special[v.PlayerData.Role.Value];
                end
                
                CreateCham(b, TeamColor);
            end
        end
    end
end
