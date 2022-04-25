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

        if not checkcaller() then
            if typeof(self) == "Instance" and method == "GetTotalMemoryUsageMb" and self.ClassName == "Stats" then
                return CurrMem + Rand;
            end
        end

        return _MemBypass(self,...)
    end)
end)

-- DecendantAdded Bypass
for i,v in next, getconnections(game.DescendantAdded) do
    v:Disable()
end

-- ContentProvider Bypasses
local Content = cloneref(game:GetService("ContentProvider"));
local CoreGui = cloneref(game:GetService("CoreGui"));


local coreguiTable = {}

for i,v in pairs(CoreGui:GetDescendants()) do
    if v:IsA("ImageLabel") and v.Image:find('rbxasset://') then
        table.insert(coreguiTable, v.Image)
    end
end
local gameTable = {}

for i, v in pairs(game:GetDescendants()) do
    if v:IsA("ImageLabel") then
	    if v.Image:find('rbxassetid://') and v:IsDescendantOf(game.CoreGui) then else
	            table.insert(gameTable, v.Image)
	     end
    end
end


local ContentProviderBypass
ContentProviderBypass = hookmetamethod(game, "__namecall", function(self, Instances, ...)
    local method = getnamecallmethod();
    local args = ...;
    
    if not checkcaller() and (method == "preloadAsync" or method == "PreloadAsync") then
        if self.ClassName == "ContentProvider" then
            if Instances ~= nil then
                if typeof(Instances) == "Instance"then
                    if Instances == game.CoreGui then
                        Instances = coreguiTable
                        return ContentProviderBypass(self, Instances, ...)
                    end
                    if args[1] == game then
                        Instances = gameTable
                        return ContentProviderBypass(self, unpack(args))
                    end
                end
            end
        end
    end
    
    return ContentProviderBypass(self, Instances, ...)
end)

local preloadBypass; preloadBypass = hookfunction(Content.PreloadAsync, function(a, b, c)
    if not checkcaller() then
        if typeof(a) == "Instance" and tostring(a) == "ContentProvider" and typeof(b) == "table" then
            if table.find(b, CoreGui) or table.find(b, game) then
                if b[1] == CoreGui then -- Double Check
			        return preloadBypass(a, coreguiTable, c)
                end
		        if b[1] == game then -- Triple Check
			        return preloadBypass(a, gameTable, c)
                end
            end
        end
    end

    return preloadBypass(a, b, c)
end)


-- GetFocusedTextBox Bypass
local _IsDescendantOf = game.IsDescendantOf

local TextboxBypass
TextboxBypass = hookmetamethod(game, "__namecall", function(self,...)
    local method = getnamecallmethod();
    local args = ...;

    if not checkcaller() then
        if typeof(self) == "Instance" and method == "GetFocusedTextBox" and self.ClassName == "UserInputService" then
	    	local Textbox = TextboxBypass(self,...);
	    	if Textbox and typeof(Textbox) == "Instance" then
			    local succ,err = pcall(function() _IsDescendantOf(Textbox, Bypassed_Dex) end)
			    
			    if err and err:match("The current identity") then
			    	return nil;
			    end
	    	end
        end
    end

    return TextboxBypass(self,...);
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
