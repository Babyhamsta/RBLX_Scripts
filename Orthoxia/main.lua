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

-- Steal Drops (Credit: Fuu - https://v3rmillion.net/member.php?action=profile&uid=1262238)
function stealDrop()
   local store = game.ReplicatedStorage.Events.Storage
   local drops = game:GetService("Workspace").Drops:GetChildren()
   
   if (#drops >= 1) then
       store:InvokeServer(drops[1], "Store")
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

-- Infi Dash Button (Credit: Fuu - https://v3rmillion.net/member.php?action=profile&uid=1262238)
local Infidash = a:Button('Infi Dash', function()
    local CharRemote = Char:FindFirstChild("Remote")
    
    local InfiDashHook
    InfiDashHook = hookmetamethod(game, "__namecall", newcclosure(function(...)
        local args = {...}
        local method = getnamecallmethod()
       
        if (args[1] == CharRemote and args[2] == 'Q' and method == "InvokeServer") then
            return(true)
        end
       
        return mt(...)
    end))
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

-- Toggle Auto Collect / Steal drops
local AutoStealDrops = a:Toggle('Auto Collect Drops', {flag = "AutoStealDrops"})

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

-- Auto Steal / Collect Drops
spawn(function()
    while wait() do
        if a.flags.AutoStealDrops then
            stealDrop()
        end
    end
end)