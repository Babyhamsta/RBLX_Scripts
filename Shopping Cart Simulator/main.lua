repeat wait() until game:IsLoaded(); -- ensure game is loaded.

-- Wally's Lib
local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/UILibs/WallyUI.lua", true))()

-- Plr
local Plr = game:GetService("Players").LocalPlayer;
local Char = Plr.Character;

-- Remotes Folder
local RemoteFunctions = game:GetService("ReplicatedStorage").RemoteFunctions;
local Events = game:GetService("ReplicatedStorage").Events;

-- Main Window
local a = library:CreateWindow("Shopping Cart")

local InfiMoney1 = a:Toggle("Infi Money #1", {flag = "Money1"})
local InfiMoney2 = a:Toggle("Infi Money #2", {flag = "Money2"})
local InfiMoney3 = a:Toggle("Infi Money #3", {flag = "Money3"})
local InfiMoney4 = a:Toggle("Infi Money #4", {flag = "Money4"})
local InfiCoffee = a:Toggle("Infi Coffee", {flag = "InfiCoffee"})

local AllRewards = a:Button('100% Achivements', function()
    local abc = {A="A",B="B",C="C",D="D",E="E",F="F",G="G",H="H",I="I",J="J",K="K",L="L",M="M",N="N",O="O",P="P",Q="Q",R="R",S="S",T="T",U="U",V="V",W="W",X="X",Y="Y",Z="Z"}
    
    for i,k in pairs(abc) do
        Events["Update_Achievements"]:FireServer(k, 1000)
    end
end)

-- Credit Tag
a:Section("Created by HamstaGang");

-- Money #1
spawn(function()
    while task.wait() do
        if a.flags.Money1 then
            task.spawn(function()
                local EndTable = { ["Did Crash"] = false, ["Distance"] = 500, ["Friends Counter"] = 0, ["Tricks"] = 1337, ["Launch Speed"] = 10, ["Style"] = 9999, ["Height"] = 500, ["Max Trick Time Length"] = 10, ["Max Trick Multiplier"] = 0, ["Trick Counter"] = 100 }
                RemoteFunctions["End_Round_Update"]:InvokeServer(EndTable)
            end)
        end
    end
end)

-- Money #2
spawn(function()
    while task.wait() do
        if a.flags.Money2 then
            task.spawn(function()
                local carttable={["Stats"]={["Launch Speed"]=100,["Tip Power"]=40},["Name"]="Basic Cart",["Cost"]=-999999999,["Key"]="B",["Level Unlock"]=0,["Asset"]=game:GetService("Workspace")["Upgrades_F"].Carts["Main Cart"],["Description"]="Basic Shopping Cart!"}
                RemoteFunctions["Upgrade_Cart"]:InvokeServer(carttable, "C")
            end)
        end
    end
end)

-- Money #3
spawn(function()
    while task.wait() do
        if a.flags.Money3 then
            Events["Boost_Coins"]:FireServer("Coins")
        end
    end
end)

-- Money #4
spawn(function()
    while task.wait() do
        if a.flags.Money4 then
            Events["Update_Reward_Streak"]:FireServer(1)
        end
    end
end)

-- Infi Coffee
spawn(function()
    while task.wait() do
        if a.flags.InfiCoffee then
            Events["Use_Coffee"]:FireServer(-5000000);
        end
    end
end)
