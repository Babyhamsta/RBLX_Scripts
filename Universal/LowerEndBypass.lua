-- Pretty much just a bunch of know detection bypasses. (Big thanks to Lego Hacker, Modulus, Bluwu, and I guess Iris or something)

-- GCInfo/CollectGarbage Bypass (Realistic by Lego - Amazing work!)
task.spawn(function()
    repeat task.wait() until game:IsLoaded()

    local Amplitude = 200
    local RandomValue = {-200,200}
    local RandomTime = {.1, 1}

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
    local function getreturn()
        local Formula = ((acos(cos(pi * (tick)))/pi * (Amplitude * 2)) + -Amplitude )
        return floor(OldGcInfo + Formula);
    end

    local Old; Old = hookfunction(getrenv().gcinfo, function(...)
        return getreturn();
    end)
    local Old2; Old2 = hookfunction(getrenv().collectgarbage, function(arg, ...)
        local suc, err = pcall(Old2, arg, ...)
        if suc and arg == "count" then
            return getreturn();
        end
        return Old2(arg, ...);
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
task.spawn(function()
    repeat task.wait() until game:IsLoaded()

    local RunService = cloneref(game:GetService("RunService"))
    local Stats = cloneref(game:GetService("Stats"))

    local CurrMem = Stats:GetTotalMemoryUsageMb();
    local Rand = 0

    RunService.Stepped:Connect(function()
        Rand = math.random(-10,10)
    end)

    local function GetReturn()
        return CurrMem + Rand;
    end

    local _MemBypass
    _MemBypass = hookmetamethod(game, "__namecall", function(self,...)
        local method = getnamecallmethod();

        if not checkcaller() then
            if typeof(self) == "Instance" and (method == "GetTotalMemoryUsageMb" or method == "getTotalMemoryUsageMb") and self.ClassName == "Stats" then
                return GetReturn();
            end
        end

        return _MemBypass(self,...)
    end)

    -- Indexed Versions
    local _MemBypassIndex; _MemBypassIndex = hookfunction(Stats.GetTotalMemoryUsageMb, function(self, ...)
        if not checkcaller() then
            if typeof(self) == "Instance" and self.ClassName == "Stats" then
                return GetReturn();
            end
        end
    end)
end)

--Newproxy Bypass (Stolen from Lego Hacker (V3RM))
local TableNumbaor001 = {}
local SomethingOld;
SomethingOld = hookfunction(getrenv().newproxy, function(...)
    local proxy = SomethingOld(...)
    table.insert(TableNumbaor001, proxy)
    return proxy
end)

local RunService = cloneref(game:GetService("RunService"))
RunService.Stepped:Connect(function()
    for i,v in pairs(TableNumbaor001) do
        if v == nil then end
    end
end)
