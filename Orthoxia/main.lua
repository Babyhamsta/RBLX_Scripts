-- Wally's Lib
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/UILibs/WallyUI.lua", true))()

-- Plr
local Plr = game:GetService("Players").LocalPlayer
local Char = Plr.Character

-- Virtual Keyboard
local virtualUser = game:GetService('VirtualUser')
virtualUser:CaptureController()

-- Anti-AFK
for i,v in pairs(getconnections(Plr.Idled)) do
   v:Disable()
end

-- Zones Array
local Zones_Arr = {};
local Selected_Zone = "Yaron Village"

function Setup_Zones()
    -- Zones
    local Zones = game:GetService("Workspace").Map.Zones

    -- Add all zones to array
    for i, Zone in pairs(Zones:GetChildren()) do
        table.insert(Zones_Arr, Zone.Name);
    end
end

-- Teleport Bypass (Via Tween)
function TP(Object) -- Object = part teleporting to.
    local tweenService, tweenInfo = game:GetService("TweenService"), TweenInfo.new(4, Enum.EasingStyle.Quad) -- change the number to a higher number if you get kicked for TP.
    local tween = tweenService:Create(game:GetService("Players")["LocalPlayer"].Character.HumanoidRootPart, tweenInfo, {CFrame = CFrame.new(Object.Position + Vector3.new(0,5,0))})
    tween:Play()  
end

-- Main Window
local a = library:CreateWindow("Orthoxia")

-- God Mode Button
local GodMode = a:Button('God Mode', function()
    -- God Mode
    local gOdMoDe
    gOdMoDe = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        local args = {...}
    
        if not checkcaller() and self.Name == "Damage" and method == "FireServer" then
            return wait(9e9);
        end
    
        return gOdMoDe(self, ...)
    end)
end)

-- Collect Chests Button
local ChestCollect = a:Button('Collect Chests', function()
    local Chests = game:GetService("Workspace").Chests:GetChildren()
    for i, chest in ipairs(Chests) do
        if chest:FindFirstChild("Hitbox") then
            TP(chest:FindFirstChild("Hitbox"));
            repeat wait() until (Char.HumanoidRootPart.Position - chest:FindFirstChild("Hitbox").Position).Magnitude < 5
            
            -- Press and release E key
            keypress(0x45)
            keyrelease(0x45)
        end
    end
end)

-- Credit Tag
a:Section("Created by HamstaGang");

-- Zones Window
local b = library:CreateWindow("Zones TP")

-- Zone selection
Setup_Zones();
local FarmZones = b:Dropdown('Select Zone', {flag = "Zones"; list = Zones_Arr;}, function(v)
    Selected_Zone = v;
end)

-- Zone Teleport Button
local ZoneTP = b:Button('Teleport to Zone', function()
    local Zones = game:GetService("Workspace").Map.Zones
    TP(Zones[Selected_Zone])
end)
