local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function loadCoordsMod()
	local ok, mod = pcall(require, "../../string/coords")
	if ok then
		return mod
	end
	ok, mod = pcall(require, "../string/coords")
	if ok then
		return mod
	end
	local okLoader, loadFunctionModule = pcall(require, "../../load_module")
	if okLoader then
		return loadFunctionModule("string/coords")
	end
	okLoader, loadFunctionModule = pcall(require, "../load_module")
	if okLoader then
		return loadFunctionModule("string/coords")
	end
	error("[expedition_antartica/routes] failed to load string/coords")
end

local parsePositionString = loadCoordsMod().parsePositionString

local function runCampRoute(camp, rootPart, totalDurationSeconds, cancelCheckFn, tweenRef)
	local positionsList = camp.positions
	if not positionsList or #positionsList == 0 then
		return
	end

	local waypoints = {}
	local tweenCount = 0
	for _, entry in ipairs(positionsList) do
		local posStr = type(entry) == "string" and entry or entry.position
		local mode = (type(entry) == "table" and (entry.mode == "teleport" or entry.mode == "walk")) and entry.mode or "tween"
		local isDelay = true
		if type(entry) == "table" and entry.isDelay == false then
			isDelay = false
		end
		local v = parsePositionString(posStr)
		if v then
			local walkWithJump = type(entry) == "table" and entry.walkWithJump == true
			table.insert(waypoints, { pos = v, mode = mode, isDelay = isDelay, walkWithJump = walkWithJump })
			if mode == "tween" then
				tweenCount = tweenCount + 1
			end
		end
	end
	if #waypoints == 0 then
		return
	end

	local totalDuration = tonumber(totalDurationSeconds) or 5
	if totalDuration < 0.1 then
		totalDuration = 0.1
	end
	local durationPerTween = (tweenCount > 0) and (totalDuration / tweenCount) or totalDuration
	if durationPerTween < 0.05 then
		durationPerTween = 0.05
	end

	for i = 1, #waypoints do
		if type(cancelCheckFn) == "function" and cancelCheckFn() then
			return
		end
		local wp = waypoints[i]
		local targetPos = wp.pos
		local tweenDuration = wp.isDelay and durationPerTween or 1
		local delayAfter = wp.isDelay and durationPerTween or 1
		if wp.mode == "tween" then
			local tweenInfo = TweenInfo.new(tweenDuration)
			local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = CFrame.new(targetPos) })
			if tweenRef then
				tweenRef.tween = tween
			end
			tween:Play()
			tween.Completed:Wait()
			if tweenRef then
				tweenRef.tween = nil
			end
		elseif wp.mode == "walk" then
			local character = rootPart and rootPart.Parent
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				local walkWaypointDone = false
				if wp.walkWithJump then
					task.spawn(function()
						while not walkWaypointDone do
							humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
							task.wait(0.8)
						end
					end)
				end
				humanoid:MoveTo(targetPos)
				humanoid.MoveToFinished:Wait()
				walkWaypointDone = true
			else
				rootPart.CFrame = CFrame.new(targetPos)
				task.wait(delayAfter)
			end
		else
			rootPart.CFrame = CFrame.new(targetPos)
			task.wait(delayAfter)
		end
	end

	if type(cancelCheckFn) == "function" and cancelCheckFn() then
		return
	end

	if camp.waterRefillObject and rootPart and rootPart.Parent then
		local refillParent = Workspace:FindFirstChild("Locally_Imported_Parts")
		local refillObj = refillParent and refillParent:FindFirstChild(camp.waterRefillObject)
		if refillObj then
			local refillPos
			if refillObj:IsA("BasePart") then
				refillPos = refillObj.Position
			elseif refillObj:IsA("Model") then
				refillPos = (refillObj.PrimaryPart and refillObj.PrimaryPart.CFrame or refillObj:GetPivot()).Position
			else
				refillPos = refillObj:GetPivot().Position
			end
			local character = rootPart and rootPart.Parent
			local humanoid = character and character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid:MoveTo(refillPos)
				humanoid.MoveToFinished:Wait()
				local dist = (rootPart.Position - refillPos).Magnitude
				if dist > 15 then
					rootPart.CFrame = CFrame.new(refillPos)
				end
			else
				rootPart.CFrame = CFrame.new(refillPos)
			end
			if type(cancelCheckFn) == "function" and cancelCheckFn() then
				return
			end
			local Event = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("EnergyHydration")
			if Event and camp.id then
				Event:FireServer("FillBottle", camp.id, "Water")
			end
		end
	end
end

return {
	runCampRoute = runCampRoute,
}
