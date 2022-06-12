-- Services
local PathfindingService = game:GetService("PathfindingService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService('TweenService');
local VIM = game:GetService("VirtualInputManager")
local UserInputService = game:GetService("UserInputService")

-- Local Plr
local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Head = Char:WaitForChild("Head", 1337)
local Root = Char:WaitForChild("HumanoidRootPart", 1337)
local Humanoid = Char:WaitForChild("Humanoid", 1337)

-- error bypass
for i,v in pairs(getconnections(game:GetService("ScriptContext").Error)) do v:Disable() end

-- Simple ESP
loadstring(game:HttpGet("https://raw.githubusercontent.com/Babyhamsta/RBLX_Scripts/main/Universal/SimpleESP.lua", true))()

-- Aimbot Vars
local Camera = workspace.CurrentCamera;

-- Mouse
local Mouse = Plr:GetMouse()

-- Temp Vars
local RayIgnore = workspace:WaitForChild("Ray_Ignore", 1337)
local ClosestPlr;
local IsAiming;
local InitialPosition;

-- Get Closest plr
local function getClosestPlr()
	local nearestPlayer, nearestDistance
	for _, player in pairs(Players:GetPlayers()) do
		if player.TeamColor ~= Plr.TeamColor and player ~= Plr then
			local character = player.Character
			if character then
				local nroot = character:FindFirstChild("HumanoidRootPart")
				if character and nroot and character:FindFirstChild("Spawned") then
					local distance = Plr:DistanceFromCharacter(nroot.Position)
					if (nearestDistance and distance >= nearestDistance) then continue end
					nearestDistance = distance
					nearestPlayer = player
				end
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
				if IsBehindWall(v.Position,{Camera,Char,ClosestPlr.Character,RayIgnore}) then -- is visible
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
		for i = 0, 1, 1/40 do
			if not aimpart then break; end
			if aimpart.Position.Y < 2 then break; end -- Stop bot from aiming at the ground
			Camera.CFrame = tcamcframe:Lerp(CFrame.new(Camera.CFrame.p, aimpart.Position), i)
			task.wait(0)
		end
		
		-- Mouse down and back up
		VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, true, game, 1)
		task.wait(0.4)
		VIM:SendMouseButtonEvent(Mouse.X, Mouse.Y, 0, false, game, 1)
	end
	
	IsAiming = false;
end

-- Pathfinding function
local function WalkToObject()
	if ClosestPlr and ClosestPlr.Character then
		-- RootPart
		local CRoot = ClosestPlr.Character:FindFirstChild("HumanoidRootPart")
		if CRoot then
			-- Get start position
			InitialPosition = CRoot.Position;
			
			-- Calculate path and waypoints
			local currpath = PathfindingService:CreatePath({WaypointSpacing = 5});
			local success, errorMessage = pcall(function()
				currpath:ComputeAsync(Root.Position, CRoot.Position)
			end)
			if success and currpath.Status == Enum.PathStatus.Success then
				local waypoints = currpath:GetWaypoints();
				
				-- Navigate to each waypoint
				for i, wap in pairs(waypoints) do
					-- Catcher
					if ClosestPlr ~= getClosestPlr() or not ClosestPlr.Character:FindFirstChild("Spawned") or not Char:FindFirstChild("Spawned") then
						ClosestPlr = nil;
						return;
					elseif (InitialPosition - CRoot.Position).Magnitude > 20  then -- moved too far from start
						WalkToObject(); -- restart
						return;
					end

					-- Detect if needing to jump
					if wap.Action == Enum.PathWaypointAction.Jump then
						Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
					end

					-- Aim at waypoint (look where we're walking)
					task.spawn(function()
						local tcamcframe = Camera.CFrame;
						for i = 0, 1, 1/65 do
							if IsAiming then break; end
							if Char:FindFirstChild("Head") then
								Camera.CFrame = tcamcframe:Lerp(CFrame.new(Camera.CFrame.p, Vector3.new(wap.Position.X,Char.Head.Position.Y,wap.Position.Z)), i)
							end
							task.wait(0)
						end
					end)
					
					-- Move to Waypoint
					Humanoid:MoveTo(wap.Position);
					Humanoid.MoveToFinished:Wait(); -- Wait for us to get to Waypoint
				end
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
			
			-- Auto Reload (if next plr is far enough and out of site)
			if math.floor(studs + 0.5) > 100 and not IsBehindWall(ClosestPlr.Character.HumanoidRootPart.Position, {Camera,Char,ClosestPlr.Character,RayIgnore}) then
				VIM:SendKeyEvent(true, Enum.KeyCode.R, false, game)
			end
			
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
		if stuckamt >= 8 then
			stuckamt = 0;
			SESP_Clear("TempTrack");
			WalkToPlr();
			task.wait(5)
		end
	end
end)
