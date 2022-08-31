-- This is just AimmyAI with custom path finding

-- Bot Settings
getgenv().AimSens = 1/35; -- Aimbot sens
getgenv().LookSens = 1/60; -- Aim while walking sens
getgenv().PreAimDis = 45; -- if within 45 Studs then preaim
getgenv().KnifeOutDis = 85; -- if within 85 Studs then swap back to gun
getgenv().ReloadDis = 30; -- if over 30 Studs away then reload
getgenv().RecalDis = 15; -- if player moves over this many studs then recalculate path to them

-- Services
local PathfindingService = game:GetService("PathfindingService");
local Players = game:GetService("Players");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local RunService = game:GetService("RunService");
local TweenService = game:GetService('TweenService');
local VIM = game:GetService("VirtualInputManager");
local UserInputService = game:GetService("UserInputService");

-- Local Plr
local Plr = Players.LocalPlayer;
local Char = Plr.Character or Plr.CharacterAdded:Wait();
local Head = Char:WaitForChild("Head", 1337);
local Root = Char:WaitForChild("HumanoidRootPart", 1337);
local Humanoid = Char:WaitForChild("Humanoid", 1337);
local AliveStat = Plr:WaitForChild("Status", 1337):WaitForChild("Alive").Value;

-- GUI Stuff
local MainMenu = Plr.PlayerGui:WaitForChild("Menew", 1337);
local PlayButton = MainMenu:WaitForChild("Main", 1337).Play;
local MainHUD = Plr.PlayerGui:WaitForChild("GUI", 1337);
local TeamSelection = MainHUD:WaitForChild("TeamSelection", 1337);
local Events = ReplicatedStorage:WaitForChild("Events", 1337);

-- Team/Spawn Stuff
local buttonColors = {"Blu", "Rd", "Ylw", "Grn"};

-- error bypass
for i,v in pairs(getconnections(game:GetService("ScriptContext").Error)) do v:Disable() end

-- Simple ESP
loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/SimpleESP.lua", true))()

-- Aimbot Vars
local Camera = workspace.CurrentCamera;

-- Mouse
local Mouse = Plr:GetMouse();

-- Map Spawns
local Map = workspace:WaitForChild("Map", 1337)
local Spawns = workspace:WaitForChild("Map", 1337):WaitForChild("Spawns", 1337)

-- Ignore
local RayIgnore = workspace:WaitForChild("Ray_Ignore", 1337)
local MapIgnore = Map:WaitForChild("Ignore", 1337)

-- Temp Vars
local CurrentEquipped = "Gun";
local ClosestPlr;
local IsAiming;
local InitialPosition;
local WalkToObject;

-- Get Closest plr
local function getClosestPlr()
	local nearestPlayer, nearestDistance
	for _, player in pairs(Players:GetPlayers()) do
		if player.TeamColor ~= Plr.TeamColor and player ~= Plr then
			local character = player.Character
			if character then
				local nroot = character:FindFirstChild("HumanoidRootPart")
				if nroot and player:FindFirstChild("Status").Alive.Value then
					if character.Humanoid and (character.Humanoid:GetState() ~= Enum.HumanoidStateType.Climbing and character.Humanoid:GetState() ~= Enum.HumanoidStateType.Freefall) then
						local distance = Plr:DistanceFromCharacter(nroot.Position)
						if (nearestDistance and distance >= nearestDistance) then continue end
						nearestDistance = distance
						nearestPlayer = player
					end
				end
			end
		end
	end
	return nearestPlayer
end

-- Wallcheck / Visible Check
local function IsVisible(target, ignorelist)
	local obsParts = Camera:GetPartsObscuringTarget({target}, ignorelist);

	if #obsParts == 0 then
		return true;
	else
		return false;
	end
end

-- Aimbot/Triggerbot
local function Aimlock()
	-- Temp Holder
	local aimpart = nil;

	-- Detect first visible part
	if ClosestPlr and ClosestPlr.Character then
		for i,v in ipairs(ClosestPlr.Character:GetChildren()) do
			if v and v:IsA("Part") then -- is part
				if IsVisible(v.Position,{Camera,Char,ClosestPlr.Character,RayIgnore,MapIgnore}) then -- is visible
					aimpart = v;
					break;
				end
			end
		end
	end

	-- If visible aim and shoot
	if aimpart then
		IsAiming = true;
		-- Aim at player
		local tcamcframe = Camera.CFrame;
		for i = 0, 1, AimSens do
			if not aimpart then break; end
			if (Head.Position.Y + aimpart.Position.Y) < 0 then break; end -- Stop bot from aiming at the ground
			Camera.CFrame = tcamcframe:Lerp(CFrame.new(Camera.CFrame.p, aimpart.Position), i)
			task.wait(0)
		end

		-- Mouse down and back up
		VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
		task.wait(0.25)
		VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
	end

	IsAiming = false;
end

-- Auto Spawn
local function AutoSpawn()
	if MainMenu.Enabled then
		-- Fire play button
		firesignal(PlayButton.MouseButton1Down);

		-- Wait for GUI to change
		repeat task.wait(0.5) until TeamSelection.Visible;

		-- Buttons check and auto team select
		if TeamSelection:FindFirstChild("Buttons").Visible then -- normal
			for i, teamButton in pairs(TeamSelection:FindFirstChild("Buttons"):GetChildren()) do
				if table.find(buttonColors, teamButton.Name) and not teamButton.lock.Visible then
					firesignal(teamButton.MouseButton1Down);
					break;
				end
			end
		elseif TeamSelection:FindFirstChild("ButtonsFFA").Visible then -- FFA
			firesignal(TeamSelection:FindFirstChild("ButtonsFFA").FFA.MouseButton1Down);
		end
	end
end

-- Pathfinding to Plr function (Ty Duck#1337 for the custom path finding source, I'm glad I was able to modify it for Aimmy)
local BFS = {}
local Heap = loadstring(game.HttpGet(game, "https://raw.githubusercontent.com/Roblox/Wiki-Lua-Libraries/master/StandardLibraries/Heap.lua"))()

if not workspace:FindFirstChild("Pathfinding") then
	local folder = Instance.new('Folder', workspace);
	folder.Name = "Pathfinding"; 
end

function BFS:Reconstruct(cameFrom, Current)
	local totalPath = {Current}
	while cameFrom[Current] do
		Current = cameFrom[Current]
		table.insert(totalPath, 1, Current)
		task.wait()
	end
	return totalPath
end

local params = RaycastParams.new()
params.FilterType = Enum.RaycastFilterType.Blacklist

function BFS:Raycast(position, direction)
	local ignorelist = {workspace.Pathfinding, Camera, Char, RayIgnore}
	params.FilterDescendantsInstances = ignorelist
	return workspace:Raycast(position, direction, params)
end

function BFS:GetNeighbours(position, studs, raycastDistance)
	local neighbours = {}
	local studs = studs or 10
	local raycastDistance = raycastDistance or studs

	for x = -1, 1 do
		for y = 1, -1, -1 do
			for z = 1, -1, -1 do
				local dir = Vector3.new(x, y, z);
				if dir.Magnitude == 1 then
					dir = dir.Unit * studs
					if not BFS:Raycast(position, dir) then
						neighbours[#neighbours+1] = position + dir
					end
				end
			end
		end
	end
	local positions = {
		position + Vector3.new(studs, 0, 0),
		position + Vector3.new(0, studs, 0),
		position + Vector3.new(0, 0, studs),
		position + Vector3.new(-studs, 0, 0),
		position + Vector3.new(0, -studs, 0),
		position + Vector3.new(0, 0, -studs)
	}

	local raycasts = {
		BFS:Raycast(position, Vector3.new(raycastDistance, 0, 0)),
		BFS:Raycast(position, Vector3.new(0, raycastDistance, 0)),
		BFS:Raycast(position, Vector3.new(0, 0, raycastDistance)),
		BFS:Raycast(position, Vector3.new(-raycastDistance, 0, 0)),
		BFS:Raycast(position, Vector3.new(0, -raycastDistance, 0)),
		BFS:Raycast(position, Vector3.new(0, 0, -raycastDistance)), 
	}
	for pos = 1, #positions do
		if not raycasts[pos] then
			neighbours[#neighbours+1] = positions[pos]
		end
	end
	return neighbours
end


function BFS:Pathfind(start, goal, studs, raycastDistance)
	local giveUpTime = 0.5
	local giveUpTick = tick()
	local studs = studs or 8

	local cameFrom = {}
	local visited = {}

	local hScore = {}
	hScore[start] = (start - goal).Magnitude

	local openSet = Heap.new(function(a, b)
		return hScore[a] > hScore[b]
	end)

	openSet:Insert(start)

	while openSet:Size() ~= 0 do
		task.wait()
		if (tick() - giveUpTick) >= giveUpTime then
			print("Given up.")
			openSet:Clear()
			return
		end
		local current = openSet:Pop()
		if (current == goal) or ((current - goal).Magnitude < studs) then
			return BFS:Reconstruct(cameFrom, current)
		end
		visited[current] = true

		local neighbours = BFS:GetNeighbours(current, studs, raycastDistance)

		for i = 1, #neighbours do
			local neighbour = neighbours[i]
			if not visited[neighbour] then
				visited[neighbour] = true
				cameFrom[neighbour] = current
				hScore[neighbour] = (neighbour - goal).Magnitude
				openSet:Insert(neighbour)
			end
		end
	end
end

local curr_path_finished = true
local curr_path_exit_time = 1
local curr_path_tick = tick()

WalkToObject = function()
	if not curr_path_finished then
		if (tick() - curr_path_tick) >= curr_path_exit_time then
			curr_path_finished = true
			curr_path_tick = tick()
		end
	end
	if AliveStat and curr_path_finished then
		if ClosestPlr and ClosestPlr.Character and ClosestPlr.Character:FindFirstChild("HumanoidRootPart") and Root then -- yes a bit over kill on checks..
			local CRoot = ClosestPlr.Character:FindFirstChild("HumanoidRootPart");

			local path = BFS:Pathfind(Root.Position, CRoot.Position, 10)
			curr_path_finished = false

			if path then--and reversed then
				print("Path found with " .. tostring(#path) .. " steps.")

				-- Get start position
				InitialPosition = CRoot.Position;

				for i = 1, #path do
					-- Catcher
					--if i == 1 then continue end -- skip first waypoint
					if not ClosestPlr or not ClosestPlr.Character or ClosestPlr ~= getClosestPlr() or not ClosestPlr:FindFirstChild("Status").Alive.Value or not Plr:FindFirstChild("Status").Alive.Value then
						print("New closest player found.");
						curr_path_finished = true;
						ClosestPlr = nil;
						return;
					elseif (InitialPosition - CRoot.Position).Magnitude > RecalDis  then -- moved too far from start
						print("Player moved too far from start position.");
						curr_path_finished = true;
						WalkToObject(); -- restart
						return;
					end

					-- Aim while walking (either path or plr)
					task.spawn(function()
						local primary = ClosestPlr.Character.PrimaryPart.Position;
						local studs = Plr:DistanceFromCharacter(primary)

						local tcamcframe = Camera.CFrame;
						for m = 0, 1, LookSens do
							if IsAiming then break; end
							if primary and studs then
								-- If close aim at player
								if math.floor(studs + 0.5) < PreAimDis then
									if ClosestPlr and ClosestPlr.Character then
										local CChar = ClosestPlr.Character;
										if Head and CChar and CChar:FindFirstChild("Head") then
											local MiddleAim = (Vector3.new(path[i].X, Char.Head.Position.Y, path[i].Z) + Vector3.new(CChar.Head.Position.X, CChar.Head.Position.Y, CChar.Head.Position.Z))/2;
											Camera.CFrame = tcamcframe:Lerp(CFrame.new(Camera.CFrame.p, MiddleAim), m);
										end
									end
								else -- else aim at waypoint
									local mixedaim = (Camera.CFrame.p.Y + Char.Head.Position.Y)/2;
									Camera.CFrame = tcamcframe:Lerp(CFrame.new(Camera.CFrame.p, Vector3.new(path[i].X, mixedaim, path[i].Z)), m);
								end
							end
							task.wait(0)
						end
					end)

					-- Auto Knife out (for faster running and realism)
					task.spawn(function()
						local primary = ClosestPlr.Character.PrimaryPart.Position;
						local studs = Plr:DistanceFromCharacter(primary)

						if primary and studs then
							local arms = Camera:FindFirstChild("Arms");
							if arms then
								arms = arms:FindFirstChild("Real");
								if math.floor(studs + 0.5) > KnifeOutDis and not IsVisible(primary, {Camera,Char,ClosestPlr.Character,RayIgnore,MapIgnore}) then
									if arms.Value ~= "Knife" and CurrentEquipped == "Gun" then
										VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game);
										CurrentEquipped = "Knife";
									end
								elseif arms.Value == "Knife" and CurrentEquipped ~= "Gun" then
									VIM:SendKeyEvent(true, Enum.KeyCode.Q, false, game);
									CurrentEquipped = "Gun";
								end
							end
						end
					end)

					-- Move to Waypoint
					if Humanoid then
						Humanoid:MoveTo(path[i]);
						Humanoid.MoveToFinished:Wait(); -- Wait for us to get to Waypoint
					end
				end
			end
			curr_path_finished = true
		else
			print("There no path calculated, restarting.")
			curr_path_finished = true;
			WalkToObject(); -- restart
			return;
		end
	end
end

-- Walk to the Plr
local function WalkToPlr()
	-- Get Closest Plr
	ClosestPlr = getClosestPlr();

	-- Walk to Plr
	if ClosestPlr and ClosestPlr.Character and ClosestPlr.Character:FindFirstChild("HumanoidRootPart") then
		if Humanoid.WalkSpeed > 0 and AliveStat and ClosestPlr:FindFirstChild("Status").Alive.Value then
			--Create ESP
			local studs = Plr:DistanceFromCharacter(ClosestPlr.Character.PrimaryPart.Position)
			SESP_Create(ClosestPlr.Character.Head, ClosestPlr.Name, "TempTrack", Color3.new(1, 0, 0), math.floor(studs + 0.5));

			-- Auto Reload (if next plr is far enough and out of site)
			if math.floor(studs + 0.5) > ReloadDis and not IsVisible(ClosestPlr.Character.HumanoidRootPart.Position, {Camera,Char,ClosestPlr.Character,RayIgnore,MapIgnore}) then
				VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
			end

			-- AI Walk to Plr
			WalkToObject(ClosestPlr.Character.HumanoidRootPart);
		end
	end
end

-- Loop Auto Spawn
task.spawn(function()
	while task.wait(0.5) do
		AutoSpawn();
	end
end)

-- Loop Pathfind
task.spawn(function()
	while task.wait() do
		if (ClosestPlr == nil or ClosestPlr ~= getClosestPlr() or not AliveStat) then
			SESP_Clear("TempTrack");
			WalkToPlr();
		end
	end
end)

-- Loop Aimlock
task.spawn(function()
	while task.wait() do
		if ClosestPlr ~= nil and Camera then
			if Plr:FindFirstChild("Status").Alive.Value and Humanoid.WalkSpeed > 0 then
				Aimlock();
			end
		end
	end
end)


-- Detect Stuck Bot
local stuckamt = 0;
task.spawn(function()
	while task.wait(0.5) do
		if Humanoid then
			if Humanoid.MoveDirection.Magnitude == 0 then
				if stuckamt == 5 then
					-- Double jump
					Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					warn("[AimmyAI] - Attempting to jump out of stuck position..");
					stuckamt = 0;
				elseif stuckamt >= 10 then
					SESP_Clear("TempTrack");
					WalkToPlr();
					warn("[AimmyAI] - Max stuck count, recalculating..");
					stuckamt = 0;
				end
			end
		end
	end
end)
