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

-- Aimbot Vars
local Camera = workspace.CurrentCamera;
Camera.CameraType = Enum.CameraType.Scriptable
--local Predict = 2;

-- Mouse
local Mouse = Plr:GetMouse()

-- Temp Vars
local ClosestPlr;

-- Get Closest plr
local function getClosestPlr()
	local nearestPlayer, nearestDistance
	for _, player in pairs(Players:GetPlayers()) do
		if player.TeamColor ~= Plr.TeamColor then
			local character = player.Character
			local nroot = character:FindFirstChild("HumanoidRootPart")
			if character and nroot and character:FindFirstChild("Spawned") then
				local distance = player:DistanceFromCharacter(nroot.Position)
				if (nearestDistance and distance >= nearestDistance) then continue end
				nearestDistance = distance
				nearestPlayer = player
			end
		end
	end
	return nearestPlayer
end

-- Wallcheck (inspired by kinx)
local function IsBehindWall(target, ignorelist)
	local CurrCam = Camera.CFrame.p
	local CurrRay = Ray.new(CurrCam, target - CurrCam)
	local RayHit = workspace:FindPartOnRayWithIgnoreList(CurrRay, ignorelist)
	return RayHit == nil
end

-- Aimlock/Triggerbot (temp)
local function Aimlock()
	if ClosestPlr and ClosestPlr.Character and ClosestPlr.Character.Head then
		if IsBehindWall(ClosestPlr.Character["Head"].Position,{Char,ClosestPlr.Character}) then			
			-- Aim at player (snap aimbot)
			Camera.CFrame = CFrame.new(Camera.CFrame.p, ClosestPlr.Character["Head"].Position) --+ ClosestPlr.Character["Head"].Velocity/Predict)

			-- Mouse down and back up
			VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
			task.wait(0.05)
			VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
		end
	end
end

-- Pathfinding function
local function WalkToObject()
	if ClosestPlr and ClosestPlr.Character and ClosestPlr.Character:FindFirstChild("HumanoidRootPart") then
		-- What we're looking for
		local object = ClosestPlr.Character:FindFirstChild("HumanoidRootPart");

		if object then
			-- Calculate path and waypoints
			local path = PathfindingService:CreatePath();
			path:ComputeAsync(Root.Position, object.Position)
			local waypoints = path:GetWaypoints();

			-- Navigate to each waypoint
			for i, wap in pairs(waypoints) do
				-- Catcher
				if not object or ClosestPlr ~= getClosestPlr() or not ClosestPlr.Character or not ClosestPlr.Character:FindFirstChild("Spawned") or not Char:FindFirstChild("Spawned") then
					--rconsoleprint("[Aimmy] - Breaking waypoint loop..\n");
					ClosestPlr = nil;
					break;
				end

				-- Detect if needing to jump
				if wap.Action == Enum.PathWaypointAction.Jump then
					Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end

				-- Aim at waypoint (look where we're walking)
				Camera.CFrame = CFrame.new(Camera.CFrame.p, (wap.Position + Vector3.new(0,4,0)))

				-- Move to Waypoint
				Humanoid:MoveTo(wap.Position);
				Humanoid.MoveToFinished:Wait(); -- Wait for us to get to Waypoint
			end
			--rconsoleprint("[Aimmy] - Finished waypoints (is done walking)\n");
		end
	end
end

-- Walk to the Plr
local function WalkToPlr()
	-- Get Closest Plr
	ClosestPlr = getClosestPlr();

	-- Walk to Plr
	if ClosestPlr and ClosestPlr.Character and ClosestPlr.Character:FindFirstChild("HumanoidRootPart") and ClosestPlr.Character:FindFirstChild("Spawned") then
		WalkToObject(ClosestPlr.Character:FindFirstChild("HumanoidRootPart"));
		--rconsoleprint("[Aimmy] - Starting walk to " .. tostring(ClosestPlr.Name) ..  "\n");
	end
end

-- Loop Pathfind
task.spawn(function()
	while task.wait() do
		if (ClosestPlr == nil or ClosestPlr ~= getClosestPlr()) and Char:FindFirstChild("Spawned") and Humanoid.WalkSpeed > 0 then
			WalkToPlr();
		end
	end
end)

-- Loop Aimlock
task.spawn(function()
	while task.wait() do
		if ClosestPlr ~= nil and Camera and Char:FindFirstChild("Spawned") then
			Aimlock();
		end
	end
end)

-- Detect Stuck Bot
local stuckamt = 0;
Humanoid.Running:Connect(function(speed)
	if speed < 3 and Char:FindFirstChild("Spawned") and Humanoid.WalkSpeed > 0 then
		stuckamt = stuckamt + 1;
		if stuckamt >= 5 then
			--rconsoleprint("[Aimmy] - Got stuck, recalculating path..\n");
			stuckamt = 0;
			ClosestPlr = nil;
			WalkToPlr();
			task.wait(1.5)
		end
	end
end)

-- Reset on Death
Plr.CharacterAdded:Connect(function(charmod)
	charmod:WaitForChild("Humanoid").Died:Connect(function()
		Plr.CharacterAdded:Wait()
		--rconsoleprint("[Aimmy] - Died, recalculating path..\n");
		ClosestPlr = nil;
		WalkToPlr();
	end)
end)
