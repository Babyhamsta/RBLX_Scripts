--//Services
local PathFindingService = game:GetService("PathfindingService")
local TweenService = game:GetService("TweenService")

--//OOP
local Path = {}
Path.__index = Path

--//Variables
local AgentRadius1, AgentHeight1, AgentCanJump1 = 5, 10, true
local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, 0, false, 0)

--//Functions
function OnPathBlocked(blockedWaypointIndex, Target, Endpoint, CurrentWaypointIndex)
	--@ Path is blocked so create a new path.
	pcall(function()
		if blockedWaypointIndex > CurrentWaypointIndex then
			local path = Path.new(Target, Endpoint)
			path:Move()
		end
	end)
end

function onWaypointReached(Reached, self, Target, Index, Waypoints)
	--@ Waypoint is reached; move to next waypoint.
	local humanoid = Target:FindFirstChildOfClass("Humanoid")

	if Reached and Index < #Waypoints then
		self:IncreaseIndex(1)
		Index = Index + 1
		
		humanoid:MoveTo(Waypoints[Index].Position)
		
		if Waypoints[Index + 1] == nil then
			if self["Finished"] and typeof(self["Finished"]) == "function" then
				self["Finished"]()
			end
		end
	end
end

function Path.CalculateTimeRaw(Target, End)
	--@ Simulate path calculations without active path.
	if Target:FindFirstChildOfClass("Humanoid") then
		if typeof(End) == "Instance" then
			local Humanoid = Target:FindFirstChildOfClass("Humanoid")
			local Root = Target:FindFirstChild("HumanoidRootPart");
			local Magnitude = (Root.Position - End.Position).Magnitude
			
			local Calculation = Magnitude / Humanoid.WalkSpeed

			return Calculation
		elseif typeof(End) == "Vector3" then
			local Humanoid = Target:FindFirstChildOfClass("Humanoid")
			local Root = Target:FindFirstChild("HumanoidRootPart");
			local Magnitude = (Root.Position - End).Magnitude

			local Calculation = Magnitude / Humanoid.WalkSpeed

			return Calculation
		end
	end
end

function Path:CalculateTime()
	--@ Calculate time based on path data.
	local Data = self
	local Target = Data["Target"]
	local End = Data["Endpoint"]
	
	if Target:FindFirstChildOfClass("Humanoid") then
		if typeof(End) == "Instance" then
			local Humanoid = Target:FindFirstChildOfClass("Humanoid")
			local Root = Target:FindFirstChild("HumanoidRootPart");
			local Magnitude = (Root.Position - End.Position).Magnitude

			local Calculation = Magnitude / Humanoid.WalkSpeed

			return Calculation
		elseif typeof(End) == "Vector3" then
			local Humanoid = Target:FindFirstChildOfClass("Humanoid")
			local Root = Target:FindFirstChild("HumanoidRootPart");
			local Magnitude = (Root.Position - End).Magnitude

			local Calculation = Magnitude / Humanoid.WalkSpeed

			return Calculation
		end
	end
end

function Path:IncreaseIndex(amount)
	--@ Increase current waypoint index by x (amount).
	self["CurrentWaypointIndex"] += amount
end

function Path:ResetIndex()
	--@ Resets path waypoint data.
	self["CurrentWaypointIndex"] = 1
end

function Path:DecreaseIndex(amount)
	--@ Decrease current waypoint index by x (amount).
	self["CurrentWaypointIndex"] -= amount
end

function ArrayNext(Target, Array, Index)
	--@ Find next value in array; used for array movement.
	Index = Index + 1
	
	if Array[Index] then
		local value = Array[Index]
		
		repeat
			local NewPath = Path.new(Target, Array[Index])
			NewPath:Play()
			Index = Index + 1
		until Array[Index] == nil
		
		--@ Return Success
		return true
	else
		--@ Return Fail
		return false
	end
end

function Path:CheckFor(name, callback)
	self[name] = callback
end

function Path.new(Target, Endpoint)
	--@ Creates a new path.
	local params = {AgentRadius = AgentRadius1, AgentHeight = AgentHeight1, AgentCanJump = AgentCanJump1}
	local path = PathFindingService:CreatePath(params)
	
	local self = {
		["Target"] = Target;
		["Time"] = Path.CalculateTimeRaw(Target, Endpoint);
		["Endpoint"] = Endpoint;
		["CurrentWaypointIndex"] = 1;
		["Walkspeed"] = 16;
		["JumpPower"] = 100;
	};
	
	if Target then
		self["Path"] = path
		
		if Target:FindFirstChildOfClass("Humanoid") then
			--@ Target is a rig
			self["Humanoid"] = Target:FindFirstChildOfClass("Humanoid")
			
			local RootPart = Target:WaitForChild("HumanoidRootPart")
			
			if typeof(Endpoint) == "Vector3" or typeof(Endpoint) == "Instance" then
				path:ComputeAsync(RootPart.Position, Endpoint.Position)
				path.Blocked:Connect(OnPathBlocked, Target, Endpoint, self["CurrentWaypointIndex"])
				
				self["Humanoid"].MoveToFinished:Connect(function(status)
					onWaypointReached(status, self, Target, self["CurrentWaypointIndex"], path:GetWaypoints())
				end)
			end
		else
			--@ Target class is not a rig
			if typeof(Endpoint) == "Vector3" or typeof(Endpoint) == "Instance" then
				path:ComputeAsync(Target.Position, Endpoint.Position)
			end
			
			self["TweenPause"] = false
			self["TweenStop"] = false
		end
	end
	
	return setmetatable(self, Path)
end

function Path:Play()
	--@ Simulate path.
	local Data = self
	local Path2 = Data["Path"]
	local Target = Data["Target"]
	local Humanoid = Data["Humanoid"]
	local CurrentWaypointIndex = Data["CurrentWaypointIndex"]
	
	local Waypoints = Path2:GetWaypoints()
	
	if Path2 then
		if Humanoid then
			if Path2.Status == Enum.PathStatus.Success then
				if Waypoints[CurrentWaypointIndex] then
					local pos = Waypoints[CurrentWaypointIndex].Position
					
					Humanoid:MoveTo(pos)
					Humanoid.MoveToFinished:Wait()
					
					if Path["WaypointReached"] and typeof(Path["WaypointReached"]) == "function" then
						Path["WaypointReached"]()
					end
				end
			end
		else
			local TweenIndex = 1
			local Continue = true

			for i,v in pairs(Waypoints) do
				local TweenPause = self["TweenPause"]
				local TweenStop = self["TweenStop"]
				
				if Continue == true then
					if TweenStop == true then
						Continue = false
					end
					
					if v then
						local Tween = TweenService:Create(Target, tweenInfo, {Position = v.Position})
						Tween:Play()
						TweenIndex = TweenIndex + 1

						if TweenPause == true then
							Tween:Pause()
							
							repeat
								wait()
							until self["TweenPause"] == false
							
							Tween:Play()
						end
						
						Tween.Completed:Wait()
						
						if Path["WaypointReached"] and typeof(Path["WaypointReached"]) == "function" then
							Path["WaypointReached"]()
						end
					else
						if Path["Finished"] and typeof(Path["Finished"]) == "function" then
							Path["Finished"]()
						end
						
						return
					end
				end
			end
		end
	end
end

function Path:Pause()
	--@ Pauses desired path.
	local Data = self
	local Target = Data["Target"]
	local Humanoid = Data["Humanoid"]
	
	if Humanoid then
		local Root = Target:FindFirstChild("HumanoidRootPart")
		Root.Anchored = true
	else
		self["TweenPause"] = true
	end
end

function Path:Resume()
	--@ Resumes desired path.
	local Data = self
	local Target = Data["Target"]
	local Humanoid = Data["Humanoid"]

	if Humanoid then
		local Root = Target:FindFirstChild("HumanoidRootPart")
		Root.Anchored = false
	else
		self["TweenPause"] = false
	end
end

function Path:Destroy()
	--@ Destroys desired path.
	local Data = self
	local Target = Data["Target"]
	
	if Target:FindFirstChildOfClass("Humanoid") then
		local Humanoid = Data["Humanoid"]
		local Root = Target:FindFirstChild("HumanoidRootPart")
		
		Humanoid:MoveTo(Root.Position)
	else
		Data["TweenStop"] = true
	end
end

function Path:ArrayMovement()
	--@ Moves agent to parts in order.
	local Data = self
	local Target = Data["Target"]
	local End = Data["Endpoint"]
	local Humanoid = Data["Humanoid"]

	local ArrayIndex = 1
	
	if End[ArrayIndex] then
		local NewPath = Path.new(Target, End[ArrayIndex])
		NewPath:Play()
			
		local Finished = ArrayNext(Target, End, ArrayIndex)

		if Finished == true then
			return "Success"
		end
	end
end

function Path:Jump()
	--@ Simulates a "jumping" action.
	local Data = self
	local Target = Data["Target"]
	local Humanoid = Data["Humanoid"]
	local JumpPower = Data["JumpPower"]
	
	if Target then
		if Humanoid then
			Humanoid:Jump()
		else
			self["TweenPause"] = true
			Target.Anchored = false
			Target.Velocity = Vector3.new(0, JumpPower, 0)
			wait(JumpPower/75)
			self["TweenPause"] = false
			Target.Anchored = true
		end
	end
end

function Path:SetSettings(Data, Type)
	--@ Set path settings.
	local Target = self["Target"]
	local HasHumanoid = nil
	
	if Target:FindFirstChildOfClass("Humanoid") then
		HasHumanoid = Target:FindFirstChildOfClass("Humanoid")
	end
	
	if Type == "TweenInfo" then
		tweenInfo = Data
	elseif Type == "JumpPower" then
		self["JumpPower"] = Data;
		
		if HasHumanoid then
			HasHumanoid.JumpPower = Data;
		end
	elseif Type == "WalkSpeed" then
		self["WalkSpeed"] = Data;
		
		if HasHumanoid then
			HasHumanoid.WalkSpeed = Data;
		end
	end
end

return Path
