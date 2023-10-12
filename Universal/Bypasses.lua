--[[
    so this is basically updating the bypasses to go against the accumulation of semi-known techniques of detecting the bypasses over the course of a year
    hopefully, some, if not all, of these are accepted and taken into account so secure dex can remain secure for almost every game

    list of things added:
        gcinfo anti-immediate detection
        memory index default returns that weren't previously there (and notices to :NextNumber() returns)
        very minor changes to preloadasync (tostring)
        addition of an index hook for getfocusedtextbox
        changes to method check so getFocusedTextBox is included
        getfocusedtextbox update for new security context update
]]



-- Pretty much just a bunch of known detection bypasses. (Big thanks to Lego Hacker, Modulus, Bluwu, and I guess Iris or something)

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

    -- checkcaller() additions
    local Old; Old = hookfunction(getrenv().gcinfo, function(...)
        return if not checkcaller() then getreturn() else Old(...);
    end)
            
    -- removal of (arg, ...) to be replaced as (...) instead (see https://youtu.be/a_seAGktcFk)
    local Old2; Old2 = hookfunction(getrenv().collectgarbage, function(...)
        local arg = ...
        local suc, err = pcall(Old2, ...) -- keeping this here just because
        if not checkcaller() and suc and (type(arg) == "string" and arg:split("\0")[1] == "count") then
            return getreturn();
        end
        return Old2(...);
    end)


    game:GetService("RunService").Stepped:Connect(function()
        local Formula = ((acos(cos(pi * (tick)))/pi * (Amplitude * 2)) + -Amplitude )
        if Formula > ((acos(cos(pi * (tick)+.01))/pi * (Amplitude * 2)) + -Amplitude ) then
            tick = tick + .07
        else
            tick = tick + .01
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
        local random = Random.new()
    	Rand = random:NextNumber(-10, 10); --[[
            no changes here, HOWEVER...
            if someone were to theoretically do a check for the last digit of the memory being equal to 5
            (because NextNumber would return something like 1010.512329123912 compared to a normal memory return, like 1010.51375)
            then this would be detected.
        ]]
    end)

    local function GetReturn()
        return CurrMem + Rand;
    end

    local _MemBypass
    _MemBypass = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod();

        if not checkcaller() then
            if (typeof(self) == "Instance" and self.ClassName == "Stats") and (method == "GetTotalMemoryUsageMb" or method == "getTotalMemoryUsageMb") then
                return GetReturn();
            end
        end

        return _MemBypass(self, ...)
    end)

    -- Indexed Versions
    local _MemBypassIndex; _MemBypassIndex = hookfunction(Stats.GetTotalMemoryUsageMb, function(self, ...)
        if not checkcaller() then
            if typeof(self) == "Instance" and self.ClassName == "Stats" then
                return GetReturn();
            end
        end
        -- this should have been here but human error can be a thing
        return _MemBypassIndex(self, ...)
    end)
end)

-- Memory Bypass X2 (Newer Method / Func)
task.spawn(function()
    repeat task.wait() until game:IsLoaded()

    local RunService = cloneref(game:GetService("RunService"))
    local Stats = cloneref(game:GetService("Stats"))

    local CurrMem = Stats:GetMemoryUsageMbForTag(Enum.DeveloperMemoryTag.Gui);
    local Rand = 0

    RunService.Stepped:Connect(function()
    	local random = Random.new()
    	Rand = random:NextNumber(-0.1, 0.1); -- probably the same case as the previous memory hook
    end)

    local function GetReturn()
        return CurrMem + Rand;
    end

    local _MemBypass
    _MemBypass = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod();

        if not checkcaller() then
            if typeof(self) == "Instance" and (method == "GetMemoryUsageMbForTag" or method == "getMemoryUsageMbForTag") and self.ClassName == "Stats" then
                return GetReturn();
            end
        end

        return _MemBypass(self, ...)
    end)

    -- Indexed Versions
    local _MemBypassIndex; _MemBypassIndex = hookfunction(Stats.GetMemoryUsageMbForTag, function(self, ...)
        if not checkcaller() then
            if typeof(self) == "Instance" and self.ClassName == "Stats" then
                return GetReturn();
            end
        end
        -- also same thing as previous
        return _MemBypassIndex(self, ...)
    end)
end)

-- ContentProvider Bypasses
local Content = cloneref(game:GetService("ContentProvider"));
local CoreGui = cloneref(game:GetService("CoreGui"));
local randomizedCoreGuiTable;
local randomizedGameTable;

local coreguiTable = {}

game:GetService("ContentProvider"):PreloadAsync({CoreGui}, function(assetId) --use preloadasync to patch preloadasync :troll:
    if not assetId:find("rbxassetid://") then
        table.insert(coreguiTable, assetId);
end
end)
local gameTable = {}

for i, v in pairs(game:GetDescendants()) do
    if v:IsA("ImageLabel") then
        if v.Image:find('rbxassetid://') and v:IsDescendantOf(CoreGui) then else
            table.insert(gameTable, v.Image)
        end
    end
end

function randomizeTable(t)
    local n = #t
    while n > 0 do
        local k = math.random(n)
        t[n], t[k] = t[k], t[n]
        n = n - 1
    end
    return t
end

local ContentProviderBypass
ContentProviderBypass = hookmetamethod(game, "__namecall", function(self, Instances, ...)
    local method = getnamecallmethod();
    local args = ...;

    if not checkcaller() and (method == "preloadAsync" or method == "PreloadAsync") then
        if Instances and Instances[1] and self.ClassName == "ContentProvider" then --
            if Instances ~= nil then
                if typeof(Instances[1]) == "Instance" and (table.find(Instances, CoreGui) or table.find(Instances, game)) then
                    if Instances[1] == CoreGui then
                        randomizedCoreGuiTable = randomizeTable(coreguiTable)
                        return ContentProviderBypass(self, randomizedCoreGuiTable, ...)
                    end

                    if Instances[1] == game then
                        randomizedGameTable = randomizeTable(gameTable)
                        return ContentProviderBypass(self, randomizedGameTable, ...)
                    end
                end
            end
        end
    end

    return ContentProviderBypass(self, Instances, ...)
end)

local preloadBypass; preloadBypass = hookfunction(Content.PreloadAsync, function(a, b, c)
    if not checkcaller() then
        if typeof(a) == "Instance" and a.ClassName == "ContentProvider" and typeof(b) == "table" then -- tostring(a) would return the name of the instance (from testing), so changed to .ClassName check
            if (table.find(b, CoreGui) or table.find(b, game)) and not (table.find(b, true) or table.find(b, false)) then
                if b[1] == CoreGui then -- Double Check
                    randomizedCoreGuiTable = randomizeTable(coreguiTable)
                    return preloadBypass(a, randomizedCoreGuiTable, c)
                end
                if b[1] == game then -- Triple Check
                    randomizedGameTable = randomizeTable(gameTable)
                    return preloadBypass(a, randomizedGameTable, c)
                end
            end
        end
    end

    return preloadBypass(a, b, c)
end)

-- GetFocusedTextBox Bypass
local _IsDescendantOf = game.IsDescendantOf
local UserInputService = cloneref(game:GetService("UserInputService"))

local TextboxBypass
TextboxBypass = hookmetamethod(game, "__namecall", function(self,...)
    local method = getnamecallmethod();
    local args = ...;

    if not checkcaller() then
        if (method == "GetFocusedTextBox" or method == "getFocusedTextBox") and (typeof(self) == "Instance" and self.ClassName == "UserInputService") then -- changes to method check
            local Textbox = TextboxBypass(self,...);
            if Textbox and typeof(Textbox) == "Instance" then
                local succ,err = pcall(function() _IsDescendantOf(Textbox, Bypassed_Dex) end)

                if err and err:match("The current") then -- identity was excluded from match check due to new security context update
                    return nil;
                end
            end
        end
    end

    return TextboxBypass(self,...);
end)

-- as no index version was found i decided to add one pretty similar to the namecall one above
-- hopefully no human errors in here
local TextboxBypassIndex
TextboxBypassIndex = hookfunction(UserInputService.GetFocusedTextBox, function(self,...)
    --local args = ...;
    if not checkcaller() and (typeof(self) == "Instance" and self.ClassName == "UserInputService") then
        local _,Textbox = TextboxBypassIndex(self, ...);
        if Textbox and typeof(Textbox) == "Instance" then
            local succ,err = pcall(function() _IsDescendantOf(Textbox, Bypassed_Dex) end)

            if err and err:match("The current") then -- identity was excluded from match check due to new security context update
                return nil;
            end
        end
    end

    return TextboxBypassIndex(self,...);
end)

-- Newproxy Bypass (Stolen from Lego Hacker (V3RM))
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
