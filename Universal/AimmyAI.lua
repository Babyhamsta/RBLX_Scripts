-- Services
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Local Plr
local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Head = Char:WaitForChild("Head", 1337)
local Root = Char:WaitForChild("HumanoidRootPart", 1337)
local Humanoid = Char:WaitForChild("Humanoid", 1337)

-- Aimbot Vars
local Camera = workspace.CurrentCamera;
--local Predict = 2;

-- Temp Vars
local IsWalking = false;
local ClosestPlr;

-- Aimlock (temp)
local function Aimlock()
	if ClosestPlr and ClosestPlr.Character and ClosestPlr.Character.Head then
		Camera.CFrame = CFrame.new(Camera.CFrame.p, ClosestPlr.Character["Head"].Position) --+ ClosestPlr.Character["Head"].Velocity/Predict)
	end
end

-- Pathfinding function
local function WalkToObject(object)
	if object then
		local path = PathfindingService:CreatePath();
		path:ComputeAsync(Root.Position, object.Position)
		local waypoints = path:GetWaypoints();

		for i, wap in pairs(waypoints) do
			-- Catcher
			if not IsWalking or object == nil or Humanoid.Health <= 0 then
				print("[HG_Bot] - Breaking waypoint loop..") 
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
		IsWalking = false;
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
			print("[HG_Bot] - Got stuck, recalculating path..")
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
		print("[HG_Bot] - Died, recalculating path..")
		WalkToPlr();
	end)
end)
