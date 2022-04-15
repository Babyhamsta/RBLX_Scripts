-- Pretty much just a bunch of know detection bypasses. (Big thanks to Lego Hacker, Modulus, and Bluwu)

-- GCInfo/CollectGarbage Bypass (Realistic by Lego - Amazing work!)
spawn(function()
    repeat task.wait() until game:IsLoaded()

    local Amplitude = 200
    local RandomValue = {-15,15}
    local RandomTime = {.5, 1.5}

    local floor = math.floor
    local cos = math.cos
    local sin = math.sin
    local acos = math.acos
    local pi = math.pi

    local Maxima = 0

    --Waiting for gcinfo to decrease
    while task.wait() do
        if gcinfo() >= Maxima then
            Maxima = gcinfo()    
        else
            break    
        end    
    end

    task.wait(0.30)

    local OldGcInfo = gcinfo()+Amplitude
    local tick = 0

    --Spoofing gcinfo
    local Old; Old = hookfunction(gcinfo, function(...)
        local Formula = ((acos(cos(pi * (tick)))/pi * (Amplitude * 2)) + -Amplitude ) 
        return floor(OldGcInfo + Formula) 
    end)
    local Old2; Old2 = hookfunction(collectgarbage, function(arg, ...)
        if arg == "collect" then
            return gcinfo(...)
        end
        return Old2(arg, ...)
    end)


    game:GetService("RunService").Stepped:Connect(function()
        local Formula = ((acos(cos(pi * (tick)))/pi * (Amplitude * 2)) + -Amplitude ) 
        if Formula > ((acos(cos(pi * (tick)+.01))/pi * (Amplitude * 2)) + -Amplitude ) then
            tick = tick + .07
        else
            tick = tick + 0.01
        end
    end)

    local old1 = Amplitude
    for i,v in next, RandomTime do
        RandomTime[i] = v * 10000
    end

    local RandomTimeValue = math.random(RandomTime[1],RandomTime[2])/10000

    --I can make it 0.003 seconds faster, yea, sure
    while wait(RandomTime) do
        Amplitude = math.random(old1+RandomValue[1], old1+RandomValue[2])
        RandomTimeValue = math.random(RandomTime[1],RandomTime[2])/10000
    end
end)

-- Memory Bypass
spawn(function()
    repeat task.wait() until game:IsLoaded()

    local RunService = game:GetService("RunService")
    
    local Stats = game:GetService("Stats")
    local CurrMem = Stats:GetTotalMemoryUsageMb();
    local Rand = 0

    RunService.Stepped:Connect(function()
        Rand = math.random(-3,3)
    end)

    local _MemBypass
    _MemBypass = hookmetamethod(game, "__namecall", function(self,...)
        local method = getnamecallmethod();
    
        if not checkcaller() and method == "GetTotalMemoryUsageMb" and self:IsA("Stats") then
            return CurrMem + Rand;
        end
    
        return _MemBypass(self,...)
    end)
end)

-- DecendantAdded Bypass
for i,v in next, getconnections(game.DescendantAdded) do
    v:Disable()
end

-- LogService Bypass (Yes it disables printing and ect.. you shouldn't be printing to dev console)
for i,v in next, getconnections(game:GetService("LogService").MessageOut) do
    v:Disable()
end

-- ContentProvider Bypass
local ContentProviderBypass
ContentProviderBypass = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod();
    local args = ...;
    
    if not checkcaller() and (method == "preloadAsync" or method == "PreloadAsync") and self:IsA("ContentProvider") then
        if args[1] ~= nil then
            if type(args[1]) == "table" then
                return;
            end
        end
    end

    return ContentProviderBypass(self, ...)
end))

-- GetFocusedTextBox Bypass (Inspired by Lego Hacker)
local TextboxBypass
TextboxBypass = hookmetamethod(game, "__namecall", newcclosure(function(self,...)
    local Method = getnamecallmethod();
    if Method == "GetFocusedTextBox" and self:IsA("UserInputService") then
        local Value = TextboxBypass(self,...)
        if Value and typeof(Value) == "Instance" then
            if Value:IsDescendantOf(game:GetService("CoreGui")) then
                return nil;
            end
        end
    end
    return TextboxBypass(self,...)
end))

--Newproxy Bypass (Stolen from Lego Hacker (V3RM))
local TableNumbaor001 = {}
local SomethingOld;
SomethingOld = hookfunction(getrenv().newproxy, function(...)
    local proxy = SomethingOld(...)
    table.insert(TableNumbaor001, proxy)
    return proxy
end)

local RunService = game:GetService("RunService")
RunService.Stepped:Connect(function()
    for i,v in pairs(TableNumbaor001) do
        if v == nil then end
    end
end)
