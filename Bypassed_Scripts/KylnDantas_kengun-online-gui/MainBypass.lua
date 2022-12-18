-- Bypass
local oof
oof = hookfunction(game.HttpGet, function(self, url, ...)
	if url == "https://kylndantas-key-system.kylndantas.repl.co/verify" then
		print("WL detected, spoofing key..")
		return "HamstaGang-w-Here"
	elseif url == "https://raw.githubusercontent.com/KylnDantas/Valiant-UI/main/mainFile.lua" then
		url = "https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Bypassed_Scripts/KylnDantas_kengun-online-gui/Valiant-UI.lua";
		return oof(self, url, ...);
	end
	return oof(self, url, ...)
end)

getgenv().isPermanent = false;
getgenv().key = "HamstaGang-w-Here"
loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Bypassed_Scripts/KylnDantas_kengun-online-gui/main.lua", true))()

