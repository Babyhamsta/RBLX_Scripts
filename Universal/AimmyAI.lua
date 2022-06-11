-- Services
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService('TweenService');
local VIM = game:GetService("VirtualInputManager")

-- Local Plr
local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Head = Char:WaitForChild("Head", 1337)
local Root = Char:WaitForChild("HumanoidRootPart", 1337)
local Humanoid = Char:WaitForChild("Humanoid", 1337)

-- Simple ESP
loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/SimpleESP.lua", true))()

-- Aimbot Vars
local Camera = workspace.CurrentCamera;

-- Mouse
local Mouse = Plr:GetMouse()

-- Temp Vars
local ClosestPlr;
local IsAiming;
local InitialPosition;

-- Get Closest plr
local function getClosestPlr()
	local nearestPlayer, nearestDistance
	for _, player in pairs(Players:GetPlayers()) do
		if player.TeamColor ~= Plr.TeamColor and player ~= Plr then
			local character = player.Character
			local nroot = character:FindFirstChild("HumanoidRootPart")
			if character and nroot and character:FindFirstChild("Spawned") then
				local distance = Plr:DistanceFromCharacter(nroot.Position)
				if (nearestDistance and distance >= nearestDistance) then continue end
				nearestDistance = distance
				nearestPlayer = player
			end
		end
	end
	return nearestPlayer
end

-- Wallcheck
local function IsBehindWall(target, ignorelist)
	local CurrCam = Camera.CFrame.p
	local CurrRay = Ray.new(CurrCam, target - CurrCam)
	local RayHit = workspace:FindPartOnRayWithIgnoreList(CurrRay, ignorelist)
	return RayHit == nil
end

-- Aimlock/Triggerbot (temp)
local function Aimlock()
	-- Temp Holder
	local aimpart = nil;
	
	-- Detect first visible part
	if ClosestPlr and ClosestPlr.Character then
		for i,v in ipairs(ClosestPlr.Character:GetChildren()) do
			if v and v:IsA("Part") then -- is part
				if IsBehindWall(v.Position,{Camera,Char,ClosestPlr.Character}) then -- is visible
					aimpart = v;
					break;
				end
			end
		end
	end
	
	-- If visible aim and shoot
	if aimpart then
		-- Aim at player
		for i = 0, 1, 0.1 do
			Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.p, aimpart.Position), i)
			task.wait(0.01)
		end
		
		-- Mouse down and back up
		VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
		task.wait(0.05)
		VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
	end
end

-- Pathfinding function
local function WalkToObject()
	if ClosestPlr and ClosestPlr.Character then
		-- RootPart
		local CRoot = ClosestPlr.Character:FindFirstChild("HumanoidRootPart")
		if CRoot then
			-- Calculate path and waypoints
			local currpath = PathfindingService:CreatePath();
			currpath:ComputeAsync(Root.Position, CRoot.Position)
			local waypoints = currpath:GetWaypoints();
			
			-- Navigate to each waypoint
			for i, wap in pairs(waypoints) do
				-- Catcher
				if ClosestPlr ~= getClosestPlr() or not ClosestPlr.Character:FindFirstChild("Spawned") or not Char:FindFirstChild("Spawned") then
					ClosestPlr = nil;
					return;
				end

				-- Detect if needing to jump
				if wap.Action == Enum.PathWaypointAction.Jump then
					Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end

				-- Aim at waypoint (look where we're walking)
				--for i = 0, 1, 0.1 do
					--Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.p, (wap.Position + Vector3.new(0,4,0))), i)
					--task.wait(0.01)
				--end
				
				-- Move to Waypoint
				Humanoid:MoveTo(wap.Position);
				Humanoid.MoveToFinished:Wait(); -- Wait for us to get to Waypoint
			end
		end
	end
end

-- Walk to the Plr
local function WalkToPlr()
	-- Get Closest Plr
	ClosestPlr = getClosestPlr();
	
	-- Walk to Plr
	if ClosestPlr and ClosestPlr.Character and ClosestPlr.Character:FindFirstChild("HumanoidRootPart") then
		if Humanoid.WalkSpeed > 0 and Char:FindFirstChild("Spawned") and ClosestPlr.Character:FindFirstChild("Spawned") then
			--Create ESP
			local studs = Plr:DistanceFromCharacter(ClosestPlr.Character.PrimaryPart.Position)
			SESP_Create(ClosestPlr.Character.Head, ClosestPlr.Name, "TempTrack", Color3.new(1, 0, 0), math.floor(studs + 0.5));
			
			-- AI Walk to Plr
			WalkToObject(ClosestPlr.Character.HumanoidRootPart);
		end
	end
end

-- Loop Pathfind
task.spawn(function()
	while task.wait() do
		if (ClosestPlr == nil or ClosestPlr ~= getClosestPlr()) then
			SESP_Clear("TempTrack");
			WalkToPlr();
		end
	end
end)

-- Loop Aimlock
task.spawn(function()
	while task.wait() do
		if ClosestPlr ~= nil and Camera then
			if Char:FindFirstChild("Spawned") and Humanoid.WalkSpeed > 0 then
				Aimlock();
			end
		end
	end
end)

-- Detect Stuck Bot
local stuckamt = 0;
Humanoid.Running:Connect(function(speed)
	if speed < 3 and Char:FindFirstChild("Spawned") and Humanoid.WalkSpeed > 0 then
		stuckamt = stuckamt + 1;
		if stuckamt >= 5 then
			stuckamt = 0;
			ClosestPlr = nil;
			task.wait(5)
		end
	end
end)
