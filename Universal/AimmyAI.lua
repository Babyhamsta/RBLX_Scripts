-- Services
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local VIM = game:GetService("VirtualInputManager")

-- Local Plr
local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Head = Char:WaitForChild("Head", 1337)
local Root = Char:WaitForChild("HumanoidRootPart", 1337)
local Humanoid = Char:WaitForChild("Humanoid", 1337)

-- Aimbot Vars
local Camera = workspace.CurrentCamera;
--local Predict = 2;

-- Mouse
local Mouse = Plr:GetMouse()

-- Temp Vars
local IsWalking = false;
local ClosestPlr;

-- Wallcheck (inspired by kinx)
local function IsBehindWall(target, ignorelist)
	if ClosestPlr and ClosestPlr.Character and ClosestPlr.Character.Head then
		local CurrCam = Camera.CFrame.p
		local CurrRay = Ray.new(CurrCam, target - CurrCam)
		local RayHit = workspace:FindPartOnRayWithIgnoreList(CurrRay, ignorelist)
		return RayHit == nil
	end
	return false;
end

-- Aimlock (temp)
local function Aimlock()
	if ClosestPlr and ClosestPlr.Character and ClosestPlr.Character.Head then
		-- Aim at player
		Camera.CFrame = CFrame.new(Camera.CFrame.p, ClosestPlr.Character["Head"].Position) --+ ClosestPlr.Character["Head"].Velocity/Predict)

		-- Trigger Bot
		if IsBehindWall(ClosestPlr.Character["Head"].Position,{Char,ClosestPlr.Character}) then
			-- Mouse down and back up
			VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
			task.wait()
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
				if not IsWalking or not object or not ClosestPlr.Character or ClosestPlr.Character.Humanoid.Health <= 0 or Humanoid.Health <= 0 then
					rconsoleprint("[Aimmy] - Breaking waypoint loop..\n");
					IsWalking = false;
					break;
				end

				-- Detect if needing to jump
				if wap.Action == Enum.PathWaypointAction.Jump then
					Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end

				-- Move to Waypoint
				Humanoid:MoveTo(wap.Position);
				Humanoid.MoveToFinished:Wait(); -- Wait for us to get to Waypoint
			end
			rconsoleprint("[Aimmy] - Finished waypoints (is done walking)\n");
			IsWalking = false;
		else
			IsWalking = false;
		end
	end
end

-- Get Closest plr
local function getClosestPlr()
	local nearestPlayer, nearestDistance
	for _, player in pairs(Players:GetPlayers()) do
		if player.TeamColor ~= Plr.TeamColor then
			local character = player.Character
			local nroot = character:FindFirstChild("HumanoidRootPart")
			if character and nroot then
				local distance = player:DistanceFromCharacter(nroot.Position)
				if (nearestDistance and distance >= nearestDistance) then continue end
				nearestDistance = distance
				nearestPlayer = player
			end
		end
	end
	return nearestPlayer
end

-- Walk to the Plr
local function WalkToPlr()
	IsWalking = false;

	-- Get Closest Plr
	ClosestPlr = getClosestPlr();

	-- Walk to Plr
	if ClosestPlr and ClosestPlr.Character and ClosestPlr.Character:FindFirstChild("HumanoidRootPart") then
		IsWalking = true;
		WalkToObject(ClosestPlr.Character:FindFirstChild("HumanoidRootPart"));
		rconsoleprint("[Aimmy] - Starting walk to " .. tostring(ClosestPlr.Name) ..  "\n");
	end
end

-- Loop Pathfind
task.spawn(function()
	while task.wait() do
		if (not IsWalking or ClosestPlr ~= getClosestPlr()) and Humanoid.Health > 0 and Humanoid.WalkSpeed > 0 then
			WalkToPlr();
		end
	end
end)

-- Loop Aimlock
task.spawn(function()
	while task.wait() do
		if ClosestPlr ~= nil and Camera and Humanoid.Health > 0 then
			Aimlock();
		end
	end
end)

-- Detect Stuck Bot
local stuckamt = 0;
Humanoid.Running:Connect(function(speed)
	if speed < 3 and Humanoid.Health > 0 and Humanoid.WalkSpeed > 0 then
		stuckamt = stuckamt + 1;
		if stuckamt >= 5 then
			rconsoleprint("[Aimmy] - Got stuck, recalculating path..\n");
			stuckamt = 0;
			WalkToPlr();
			task.wait(1.5)
		end
	end
end)

-- Reset on Death
Plr.CharacterAdded:Connect(function(charmod)
	charmod:WaitForChild("Humanoid").Died:Connect(function()
		Plr.CharacterAdded:Wait()
		rconsoleprint("[Aimmy] - Died, recalculating path..\n");
		WalkToPlr();
	end)
end)
