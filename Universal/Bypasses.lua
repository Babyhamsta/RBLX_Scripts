-- Pretty much just a bunch of know detection bypasses.

-- GCInfo Bypass
hookfunction(gcinfo, function(...)
    return math.random(73,150)
end)

-- Memory Bypass
hookfunction(game:GetService("Stats").GetTotalMemoryUsageMb, function(Stats)
    return math.random(1,5);
end)

-- DecendantAdded Bypass
for i,v in next, getconnections(game.DescendantAdded) do
    v:Disable()
end

-- LogService Bypass
for i,v in next, getconnections(game:GetService("LogService").MessageOut) do
    v:Disable()
end

--Setmetatable Bypass (Stolen from Lego Hacker (V3RM))
local smt_hook; smt_hook = hookfunction(setmetatable, function(self, method, ...)
   if method["__mode"] then method["__mode"] = nil end
   return smt_hook(self, method, ...)    
end)

-- ContentProvider Bypass
local ContentProvider = game:GetService("ContentProvider")
local ContentProviderBypass
ContentProviderBypass = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod();
    local args = ...;

    if not checkcaller() and method == "preloadAsync" and self == ContentProvider then
        return wait();
    end

    return ContentProviderBypass(self, ...)
end))

-- GetFocusedTextBox Bypass (Inspired by Lego Hacker)
local UserInputService = game:GetService("UserInputService")
local TextboxBypass
TextboxBypass = hookmetamethod(game, "__namecall", newcclosure(function(self,...)
    local Method = getnamecallmethod();
    if Method == "GetFocusedTextBox" and self == UserInputService then
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

game:GetService("RunService").Stepped:Connect(function()
    for i,v in pairs(TableNumbaor001) do
        if v == nil then end
    end
end)
