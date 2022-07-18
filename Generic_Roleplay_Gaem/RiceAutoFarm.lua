-- Credit to Egg Salad for initial release.

--// Script Settings \\--
getgenv().ScriptPaused = false;

--// Services \\--
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

--// Variables \\--
local Player = Players.LocalPlayer
local Hunger = Player:WaitForChild("stats"):WaitForChild("Hunger")
local BuyKart = Workspace:WaitForChild("BarbStores"):WaitForChild("FarmKart"):WaitForChild("CustomerSeat")
local BuyFood = Workspace:WaitForChild("Stores"):WaitForChild("Food"):WaitForChild("CustomerSeats")
local Karts = Workspace:WaitForChild("Karts")
local RiceFolder = Workspace:WaitForChild("Rice")
local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")

--// Anti AFK \\--
for i,v in pairs(getconnections(game:GetService("Players").LocalPlayer.Idled)) do v:Disable() end

--// Remove Tags \\--
function RemoveTags()
    if Player.Character then
        local proot = Player.Character:FindFirstChild("HumanoidRootPart");
        if proot then
            local HeadGui = proot:FindFirstChild("HeadGui");
            if HeadGui then
            	if HeadGui:FindFirstChild("Title") and HeadGui:FindFirstChild("Team") then
		    HeadGui:FindFirstChild("Title"):Destroy();
		    HeadGui:FindFirstChild("Team"):Destroy();
		end
            end
        end
        
        for i,v in pairs(Player.Character:GetChildren()) do
            if v:IsA("Part") then
                v.CanCollide = false;
            end
        end
    end
end

--// Get Tool \\--
function GetTool(Name)
    local Tool = Player.Character and Player.Character:FindFirstChild(Name) or Player.Backpack:FindFirstChild(Name)
    if Tool and Player.Character and Player.Character.Humanoid then
        Player.Character.Humanoid:UnequipTools()
        Player.Character.Humanoid:EquipTool(Tool)
        task.wait()
        return Tool
    end
end

--// Get/Eat Food \\--
function AutoEat()
    task.wait();
    local CurrSeat = nil;
    local FoodTb = {"Basic Food", "Good Food", "Best Food"}
    
    if Player.Character:FindFirstChild("Humanoid") then
        if BuyFood:FindFirstChild("3") then
            BuyFood["3"]:Sit(Player.Character.Humanoid)
            CurrSeat = 3;
        elseif BuyFood:FindFirstChild("2") then
            BuyFood["2"]:Sit(Player.Character.Humanoid)
            CurrSeat = 2;
        elseif BuyFood:FindFirstChild("1") then
            BuyFood["1"]:Sit(Player.Character.Humanoid)
            CurrSeat = 1;
        end
    
        local Tool = GetTool(tostring(FoodTb[CurrSeat]));
        if Tool then
           Tool:Activate()
        end
    else -- ded
	RemoteEvent:FireServer("Respawn");
        ScriptPaused = false;
    end
end

--// Get Rice \\--
function GetRice()
    for _, Rice in next, RiceFolder:GetChildren() do
        local Model = Rice:FindFirstChildOfClass("Model")
        if Model and Model.PrimaryPart and Rice:FindFirstChild("Health") and Rice.Health.Value > 0 and Rice:FindFirstChild("Reward") and Rice.Reward.Value > 0 then
            return Rice, Model.PrimaryPart
        end
    end
end

--// Use Kart \\--
function UseKart(Kart)
    if Kart.Name == Player.Name then
        -- Sickles
        local Sickles = {Kart:WaitForChild("LeftSickle"), Kart:WaitForChild("RightSickle")}
        -- Farm Rice
        while Kart.Parent == Karts and task.wait() and not ScriptPaused do
            -- Sit
            if Kart:FindFirstChild("VehicleSeat") and Kart.VehicleSeat.Occupant ~= Player.Character.Humanoid then
                Kart.VehicleSeat:Sit(Player.Character.Humanoid)
            end
            -- Rice
            local Rice, Part = GetRice()
            if Rice and Kart.PrimaryPart then
                Kart:SetPrimaryPartCFrame(Part.CFrame * CFrame.new(0, -8.5, -3))
                task.wait(0.1);
                for _, Sickle in next, Sickles do
                    firetouchinterest(Sickle, Part, 0)
                    firetouchinterest(Sickle, Part, 1)
                end
            end
        end
    end
end

--// Auto Eat \\--
task.spawn(function()
    while task.wait() do
        if Hunger.Value < 10 then
            if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                ScriptPaused = true;
                if Karts:FindFirstChild(Player.Name) then
                    Karts:FindFirstChild(Player.Name):FindFirstChild("VehicleSeat"):Destroy()
                end
                repeat AutoEat() until Hunger.Value > 90;
                ScriptPaused = false;
            end
        end
    end
end)

--// Anti-Flood / Drown \\--
task.spawn(function()
    while task.wait() do
        if Player.Character then
            if Player.Character:FindFirstChild("Float") then
                Player.Character.Float.Disabled = true;
                Player.Character.Float:Destroy();
            end
        end
    end
end)

-- // Loop Tag Removal \\--
task.spawn(function()
    while task.wait() do
        RemoveTags();
    end
end)

--// Get Kart \\--
while true do
    if not Karts:FindFirstChild(Player.Name) and not ScriptPaused then
        local Tool = GetTool("FarmKart")
        local Humanoid = Player.Character and Player.Character:FindFirstChild("Humanoid")
        if Humanoid and Humanoid.Health <= 0 then
            RemoteEvent:FireServer("Respawn")
        elseif Tool then
            Tool:Activate()
        else
            BuyKart:Sit(Player.Character.Humanoid)
        end
    else
        if Karts:FindFirstChild(Player.Name) then
            for i,v in pairs(Karts[Player.Name]:GetDescendants()) do
                if v:IsA("Part") then
                    v.CanCollide = false;
                end
            end
            UseKart(Karts[Player.Name])
        end
    end
    task.wait(2.3)
end
