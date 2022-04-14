-- Pretty much just a bunch of know detection bypasses.

-- GCInfo Bypass (Inspired by Lego)
spawn(function()
    repeat wait() until game:IsLoaded()

    local CurrGC = gcinfo();
    local Rand = 0
    local RunService = cloneref(game:GetService("RunService"))

    RunService.Stepped:Connect(function()
        Rand = math.random(-200,200)
    end)

    local GCINFO_Hook;
    GCINFO_Hook = hookfunction(gcinfo, function(...)
        if not checkcaller() then
            return CurrGC + Rand;
        end
        return GCINFO_Hook(...)
    end)
end)

-- Memory Bypass
spawn(function()
    repeat wait() until game:IsLoaded()

    local RunService = cloneref(game:GetService("RunService"))
    
    local Stats = cloneref(game:GetService("Stats"))
    local CurrMem = Stats:GetTotalMemoryUsageMb();
    local Rand = 0

    RunService.Stepped:Connect(function()
        Rand = math.random(-3,3)
    end)

    local _MemBypass
    _MemBypass = hookmetamethod(game, "__namecall", function(self,...)
        local method = getnamecallmethod();
    
        if not checkcaller() and method == "GetTotalMemoryUsageMb" then
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
local ContentProvider = cloneref(game:GetService("ContentProvider"))
local ContentProviderBypass
ContentProviderBypass = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod();

    if not checkcaller() and (method == "preloadAsync" or method == "PreloadAsync") and self == ContentProvider then
        return wait();
    end

    return ContentProviderBypass(self, ...)
end))

-- GetFocusedTextBox Bypass (Inspired by Lego Hacker)
local UserInputService = cloneref(game:GetService("UserInputService"))
local CoreGUI = cloneref(game:GetService("CoreGui"));
local TextboxBypass
TextboxBypass = hookmetamethod(game, "__namecall", newcclosure(function(self,...)
    local Method = getnamecallmethod();
    if Method == "GetFocusedTextBox" and self == UserInputService then
        local Value = TextboxBypass(self,...)
        if Value and typeof(Value) == "Instance" then
            if Value:IsDescendantOf(CoreGUI) then
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

local RunService = cloneref(game:GetService("RunService"))
RunService.Stepped:Connect(function()
    for i,v in pairs(TableNumbaor001) do
        if v == nil then end
    end
end)
