-- Dex Bypasses
loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/Bypasses.lua", true))()

-- Dex with CloneRef Support (made as global)
getgenv().Bypassed_Dex = game:GetObjects("rbxassetid://10194917640")[1]; -- swapped to non-beta lazy dex

-- Special GetServices Cache
local CachedServices = {};
local function GhettoGetServices(RequestedService)
    if not CachedServices[RequestedService] then
        local temp = cloneref(game:GetService(tostring(RequestedService)))
        if temp then
            CachedServices[RequestedService] = temp;
            return CachedServices[RequestedService];
        end
    else
        return CachedServices[RequestedService];
    end
end
getgenv().GetServices = GhettoGetServices;

local charset = {}
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end
local function RandomCharacters(length)
    if length > 0 then
        return RandomCharacters(length - 1) .. charset[math.random(#charset)]
    else
        return ""
    end
end

Bypassed_Dex.Name = RandomCharacters(math.random(5, 20))
if gethui then
    Bypassed_Dex.Parent = gethui();
elseif syn and syn.protect_gui then
    syn.protect_gui(Bypassed_Dex);
    Bypassed_Dex.Parent = GetServices("CoreGui");
else
    Bypassed_Dex.Parent = GetServices("CoreGui");
end

local function Load(Obj, Url)
    local function GiveOwnGlobals(Func, Script)
        local Fenv = {}
        local RealFenv = {script = Script}
        local FenvMt = {}
        function FenvMt:__index(b)
            if RealFenv[b] == nil then
                return getfenv()[b]
            else
                return RealFenv[b]
            end
        end
        function FenvMt:__newindex(b, c)
            if RealFenv[b] == nil then
                getfenv()[b] = c
            else
                RealFenv[b] = c
            end
        end
        setmetatable(Fenv, FenvMt)
        setfenv(Func, Fenv)
        return Func
    end

    local function LoadScripts(Script)
        if Script.ClassName == "Script" or Script.ClassName == "LocalScript" then
            task.spawn(GiveOwnGlobals(loadstring(Script.Source, "=" .. Script:GetFullName()), Script))
        end
        for _,v in ipairs(Script:GetChildren()) do
            LoadScripts(v)
        end
    end

    LoadScripts(Obj)
end

Load(Bypassed_Dex)
