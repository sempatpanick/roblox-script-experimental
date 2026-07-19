--[[
	Route player: replays a recording-v2 data table on the local character.

	Blocking port of the playback engine in tabs/rayfield/recording_tab.lua
	(startPlayback, lines ~652-858) so game scripts can replay route
	recordings outside the Recording tab UI. Recording format:
	  frames: { {t, x, y, z, rx, ry, rz, mx, mz}, ... }
	  events: { {t, kind, data?}, ... }
	  rootOffset: recorder's root-center-to-ground distance (grounds the
	  path for the avatar playing it back), duration: seconds.

	Position is interpolated with a Catmull-Rom spline across four recorded
	frames (rotation via CFrame lerp); respawn/teleport-sized gaps snap
	instead of sweeping. Bind ids are distinct from the Recording tab's so
	both modules can coexist (though only one should play at a time).
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local TELEPORT_SNAP_DISTANCE = 15 -- gaps larger than this snap instead of interpolating
local MAX_STEP_DELTA = 0.1 -- clamp per-frame playback advance so hitches don't cause jumps
local POSE_BIND_ID = "SempatPanickRoutePlayerPose"
local MOVE_BIND_ID = "SempatPanickRoutePlayerMove"

-- Distance from the root part's center to the ground for this avatar.
-- R15 keeps it in HipHeight; R6 ignores HipHeight and stands on 2-stud legs.
local function characterRootOffset(humanoid, rootPart)
	local offset = rootPart.Size.Y / 2
	if humanoid.RigType == Enum.HumanoidRigType.R6 then
		offset = offset + 2
	else
		offset = offset + humanoid.HipHeight
	end
	return offset
end

local function framePosition(frame)
	return Vector3.new(frame[2], frame[3], frame[4])
end

local function frameRotation(frame)
	return CFrame.fromOrientation(frame[5], frame[6], frame[7])
end

local function frameToCFrame(frame)
	return CFrame.new(frame[2], frame[3], frame[4]) * frameRotation(frame)
end

-- Catmull-Rom position through p1..p2 with neighbors p0/p3; clamping
-- neighbors across teleport-sized gaps so splines never sweep through them.
local function splinePosition(frames, cursor, alpha)
	local f1 = frames[cursor]
	local f2 = frames[math.min(cursor + 1, #frames)]
	local p1 = framePosition(f1)
	local p2 = framePosition(f2)

	if (p2 - p1).Magnitude > TELEPORT_SNAP_DISTANCE then
		if alpha < 1 then
			return p1, true
		end
		return p2, true
	end

	local f0 = frames[math.max(cursor - 1, 1)]
	local f3 = frames[math.min(cursor + 2, #frames)]
	local p0 = framePosition(f0)
	local p3 = framePosition(f3)
	if (p1 - p0).Magnitude > TELEPORT_SNAP_DISTANCE then
		p0 = p1
	end
	if (p3 - p2).Magnitude > TELEPORT_SNAP_DISTANCE then
		p3 = p2
	end

	local a2 = alpha * alpha
	local a3 = a2 * alpha
	local pos = (p1 * 2
		+ (p2 - p0) * alpha
		+ (p0 * 2 - p1 * 5 + p2 * 4 - p3) * a2
		+ (p1 * 3 - p0 - p2 * 3 + p3) * a3) * 0.5
	return pos, false
end

local playbackActive = false
local playToken = 0
local playHeartbeatConn = nil
local playCollideStates = nil
local playSavedAutoRotate = nil
local playerControlsCache = nil
local playerControlsTried = false
local externalStopRequested = false

local function getPlayerControls()
	if playerControlsTried then
		return playerControlsCache
	end
	playerControlsTried = true
	pcall(function()
		local playerScripts = Players.LocalPlayer:FindFirstChild("PlayerScripts")
		local playerModule = playerScripts and playerScripts:FindFirstChild("PlayerModule")
		if playerModule then
			playerControlsCache = require(playerModule):GetControls()
		end
	end)
	return playerControlsCache
end

local function applyNoClip(character)
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") and playCollideStates[part] == nil then
			playCollideStates[part] = part.CanCollide
			part.CanCollide = false
		end
	end
end

-- Unbind everything and restore controls, collisions and AutoRotate.
local function teardownPlayback()
	playToken = playToken + 1
	pcall(function()
		RunService:UnbindFromRenderStep(POSE_BIND_ID)
	end)
	pcall(function()
		RunService:UnbindFromRenderStep(MOVE_BIND_ID)
	end)
	if playHeartbeatConn then
		playHeartbeatConn:Disconnect()
		playHeartbeatConn = nil
	end
	if not playbackActive then
		return
	end
	playbackActive = false

	local controls = getPlayerControls()
	if controls then
		pcall(function()
			controls:Enable()
		end)
	end

	if playCollideStates then
		for part, wasCollidable in pairs(playCollideStates) do
			pcall(function()
				if part.Parent then
					part.CanCollide = wasCollidable
				end
			end)
		end
		playCollideStates = nil
	end

	local character = Players.LocalPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		pcall(function()
			if playSavedAutoRotate ~= nil then
				humanoid.AutoRotate = playSavedAutoRotate
			end
			humanoid:Move(Vector3.new(0, 0, 0), false)
		end)
	end
	playSavedAutoRotate = nil
end

local function stop()
	externalStopRequested = true
	teardownPlayback()
end

local function isPlaying()
	return playbackActive
end

-- Blocking. Replays a recording-v2 data table on the local character.
-- opts: {
--   shouldCancel: (() -> boolean)?  -- polled every Heartbeat
--   noClip: boolean?                -- default false (real collisions)
--   onProgress: ((elapsed: number, duration: number) -> ())?  -- ~4/s
--   blendInSeconds: number?         -- glide from the current pose into the
--                                      first frame instead of snapping (default 0)
-- }
-- returns completed: boolean, reason:
--   "finished" | "cancelled" | "died" | "character_lost" | "busy" | "bad_data"
local function playRouteData(data, opts)
	opts = opts or {}
	if playbackActive then
		return false, "busy"
	end
	if type(data) ~= "table" or type(data.frames) ~= "table" or #data.frames < 2 then
		return false, "bad_data"
	end

	local character = Players.LocalPlayer.Character
	local rootPart = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not rootPart or not humanoid or humanoid.Health <= 0 then
		return false, "character_lost"
	end

	local frames = data.frames
	local events = type(data.events) == "table" and data.events or {}
	local duration = tonumber(data.duration) or frames[#frames][1]
	local noClip = opts.noClip == true
	local shouldCancel = opts.shouldCancel
	local onProgress = opts.onProgress
	local blendInSeconds = tonumber(opts.blendInSeconds) or 0

	-- Ground the path for the avatar playing it back: recordings made on a
	-- tall avatar would float on a small one (and vice versa) otherwise.
	local recordedOffset = tonumber(data.rootOffset)
	local function currentYShift(root, hum)
		if not recordedOffset then
			return 0
		end
		return characterRootOffset(hum, root) - recordedOffset
	end

	playbackActive = true
	externalStopRequested = false
	playToken = playToken + 1
	local myToken = playToken

	local frameCursor = 1
	local eventCursor = 1
	local playElapsed = 0
	local lastProgressUpdate = 0
	local currentMoveDir = Vector3.new(0, 0, 0)
	local finished = false
	local finishReason = nil

	playSavedAutoRotate = humanoid.AutoRotate
	humanoid.AutoRotate = false
	playCollideStates = {}
	if noClip then
		applyNoClip(character)
	end
	local controls = getPlayerControls()
	if controls then
		pcall(function()
			controls:Disable()
		end)
	end

	local startCFrame = frameToCFrame(frames[1]) + Vector3.new(0, currentYShift(rootPart, humanoid), 0)

	-- Smoothly glide from wherever the walk-connect left the character into the
	-- exact first-frame pose, so entering a route doesn't snap position/facing.
	if blendInSeconds > 0 then
		local fromCFrame = rootPart.CFrame
		local blendElapsed = 0
		while blendElapsed < blendInSeconds do
			local dt = RunService.Heartbeat:Wait()
			if externalStopRequested or myToken ~= playToken then
				teardownPlayback()
				return false, "cancelled"
			end
			local ch = Players.LocalPlayer.Character
			local root = ch and ch:FindFirstChild("HumanoidRootPart")
			local hum = ch and ch:FindFirstChildOfClass("Humanoid")
			if not root or not hum or hum.Health <= 0 then
				teardownPlayback()
				return false, hum and "died" or "character_lost"
			end
			if shouldCancel and shouldCancel() then
				teardownPlayback()
				return false, "cancelled"
			end
			blendElapsed = blendElapsed + dt
			local a = math.clamp(blendElapsed / blendInSeconds, 0, 1)
			root.CFrame = fromCFrame:Lerp(startCFrame, a)
			root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
			rootPart = root
		end
	end

	rootPart.CFrame = startCFrame
	rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
	rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

	-- Computes the pose for the current playback time and writes it to the
	-- root. Called both before the camera update and after physics, so the
	-- rendered pose is always exactly the interpolated recording pose.
	local function applyPose()
		local ch = Players.LocalPlayer.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if not root or not hum then
			return false
		end

		while frameCursor < #frames and frames[frameCursor + 1][1] <= playElapsed do
			frameCursor = frameCursor + 1
		end

		local f0 = frames[frameCursor]
		local f1 = frames[math.min(frameCursor + 1, #frames)]
		local dt = f1[1] - f0[1]
		local alpha = 0
		if dt > 0 then
			alpha = math.clamp((playElapsed - f0[1]) / dt, 0, 1)
		end

		local pos, snapped = splinePosition(frames, frameCursor, alpha)
		local rot = frameRotation(f0):Lerp(frameRotation(f1), alpha)
		root.CFrame = CFrame.new(pos.X, pos.Y + currentYShift(root, hum), pos.Z) * rot

		local velocity = Vector3.new(0, 0, 0)
		if dt > 0 and not snapped then
			velocity = (framePosition(f1) - framePosition(f0)) / dt
		end
		root.AssemblyLinearVelocity = velocity
		root.AssemblyAngularVelocity = Vector3.new(0, 0, 0)

		local mx = (f0[8] or 0) + ((f1[8] or 0) - (f0[8] or 0)) * alpha
		local mz = (f0[9] or 0) + ((f1[9] or 0) - (f0[9] or 0)) * alpha
		currentMoveDir = Vector3.new(mx, 0, mz)
		return true
	end

	local function finishPlayback(reason)
		if finished then
			return
		end
		finished = true
		finishReason = reason
		teardownPlayback()
	end

	-- Advance the timeline and write the pose just before the camera
	-- update, so the camera always follows the freshly-written pose.
	RunService:BindToRenderStep(POSE_BIND_ID, Enum.RenderPriority.Camera.Value - 1, function(deltaTime)
		if not playbackActive or myToken ~= playToken then
			return
		end

		playElapsed = playElapsed + math.min(deltaTime, MAX_STEP_DELTA)

		local ch = Players.LocalPlayer.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then
			finishPlayback(hum and "died" or "character_lost")
			return
		end

		if playElapsed >= duration then
			local root = ch and ch:FindFirstChild("HumanoidRootPart")
			if root then
				root.CFrame = frameToCFrame(frames[#frames]) + Vector3.new(0, currentYShift(root, hum), 0)
				root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			end
			finishPlayback("finished")
			return
		end

		if not applyPose() then
			finishPlayback("character_lost")
			return
		end

		while eventCursor <= #events and events[eventCursor][1] <= playElapsed do
			local kind = events[eventCursor][2]
			if kind == "jump" then
				pcall(function()
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end)
			end
			eventCursor = eventCursor + 1
		end

		if onProgress and playElapsed - lastProgressUpdate >= 0.25 then
			lastProgressUpdate = playElapsed
			pcall(onProgress, playElapsed, duration)
		end
	end)

	-- Drive walk animation after the character control scripts have run,
	-- so nothing overwrites our move direction within the frame.
	RunService:BindToRenderStep(MOVE_BIND_ID, Enum.RenderPriority.Character.Value + 1, function()
		if not playbackActive or myToken ~= playToken then
			return
		end
		local ch = Players.LocalPlayer.Character
		local hum = ch and ch:FindFirstChildOfClass("Humanoid")
		if hum then
			pcall(function()
				hum:Move(currentMoveDir, false)
			end)
		end
	end)

	-- Re-assert the pose after each physics step so simulation (gravity,
	-- collisions, humanoid controller) can never fight the playback path.
	playHeartbeatConn = RunService.Heartbeat:Connect(function()
		if not playbackActive or myToken ~= playToken then
			return
		end
		applyPose()
		if noClip then
			local ch = Players.LocalPlayer.Character
			if ch and playCollideStates then
				applyNoClip(ch)
			end
		end
	end)

	-- Block the calling thread until the playback resolves.
	while not finished do
		RunService.Heartbeat:Wait()
		if finished then
			break
		end
		if externalStopRequested or myToken ~= playToken or not playbackActive then
			finished = true
			finishReason = finishReason or "cancelled"
			teardownPlayback()
			break
		end
		if shouldCancel and shouldCancel() then
			finishPlayback("cancelled")
			break
		end
	end

	return finishReason == "finished", finishReason or "cancelled"
end

return {
	playRouteData = playRouteData,
	stop = stop,
	isPlaying = isPlaying,
	characterRootOffset = characterRootOffset,
}
