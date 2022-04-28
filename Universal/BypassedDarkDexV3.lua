--[[ Dex Loader by cirmolddry#2299 || Modded by HamstaGang ]]

--[[
This script has many bypasses to keep DEX secured.
NewProxy Bypass
GetGC Spoof
Memory Spoof
ContentProvider Bypass
GetFocusedTextBox Bypass
DecendantAdded Disabler
CloneRef (Overall protection of Instances and other UserData)
]]

-- Dex Bypasses
loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/Bypasses.lua", true))()

-- Dex with CloneRef Support
getgenv().Bypassed_Dex = game:GetObjects("rbxassetid://9352453730")[1]
math.randomseed(tick())

-- CoreGui
local CoreGui = cloneref(game:GetService("CoreGui"))

local charset = {}
for i = 48,  57 do table.insert(charset, string.char(i)) end
for i = 65,  90 do table.insert(charset, string.char(i)) end
for i = 97, 122 do table.insert(charset, string.char(i)) end
function RandomCharacters(length)
  if length > 0 then
    return RandomCharacters(length - 1) .. charset[math.random(1, #charset)]
  else
    return ""
  end
end

Bypassed_Dex.Name = RandomCharacters(math.random(5, 20))
Bypassed_Dex.Parent = CoreGui

getcustomasset = getsynasset or getcustomasset
base64decode = syn_crypt_b64_decode or (crypt and crypt.base64decode)
if getcustomasset and readfile then
	local s,res = pcall(readfile,"\67\77\68\45\88\46\108\117\97")
	if s and res and res ~= "" then
		pcall(function()
			local o = base64decode(game:GetObjects("rbxassetid://6325145856")[1].x.Source)
			writefile("cx.ogg",o)
			local s = Instance.new("Sound", CoreGui)
			s.Name = game:GetService("HttpService"):GenerateGUID()
			s.SoundId = getcustomasset("cx.ogg")
			s.Volume = 2
			s.PlayOnRemove = true
			wait()
			s:Destroy()
		end)
	end
end

local function Load(Obj, Url)
	local function GiveOwnGlobals(Func, Script)
		local Fenv = {}
		local RealFenv = {script = Script}
		local FenvMt = {}
		FenvMt.__index = function(a,b)
			if RealFenv[b] == nil then
				return getfenv()[b]
			else
				return RealFenv[b]
			end
		end
		FenvMt.__newindex = function(a, b, c)
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
			spawn(GiveOwnGlobals(loadstring(Script.Source, "=" .. Script:GetFullName()), Script))
		end
		for i,v in pairs(Script:GetChildren()) do
			LoadScripts(v)
		end
	end
	
	LoadScripts(Obj)
end

Load(Bypassed_Dex)
