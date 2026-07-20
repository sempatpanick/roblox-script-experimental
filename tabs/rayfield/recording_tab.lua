--[[
  Recording tab module for Rayfield scripts.
  Loaded from: https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/tabs/rayfield/recording_tab.lua

  Usage:
    createRecordingTab(Window, mountNotify, options)

  options (optional table):
    gamePath = "sempatpanick/<game_name>"  -- recordings saved to <gamePath>/recordings
    tabIcon = "video"  -- optional; Lucide name or rbx asset id (Sempat UI)
    recordHotkey = "Q"  -- KeyCode name toggling record on/off
    playbackNoClip = true  -- default true; disable character collisions while playing back

  Recording file format (JSON, version 2):
    frames: { {t, x, y, z, rx, ry, rz, mx, mz}, ... }  -- root CFrame + move direction, sampled every Heartbeat
    events: { {t, kind, data?}, ... }  -- jump / fall / land / seated / died / respawn / keydown / keyup
    rootOffset: number  -- v2: recorder's root-center-to-ground distance; playback
                        -- shifts Y by the current avatar's offset minus this, so
                        -- recordings replay grounded on any avatar size/rig

  Smoothness notes:
    - Capture and playback timelines accumulate the engine's own frame deltas
      (Heartbeat/RenderStep dt), never wall-clock reads, so callback scheduling
      jitter cannot creep into the timing.
    - Playback pose is written in a render-step binding just before the camera
      update (so the camera always sees the fresh pose), re-asserted after
      physics on Heartbeat (so simulation can never fight the pose), with the
      player's control module disabled and Humanoid:Move() driven from a binding
      that runs after the character controls (so walk animations play cleanly).
    - Position is interpolated with a Catmull-Rom spline across four recorded
      frames (rotation via CFrame lerp), so motion stays fluid even if the
      recording dropped frames; respawn/teleport jumps snap instead of sweeping.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local RECORDING_VERSION = 2
local IDLE_FRAME_INTERVAL = 0.25 -- store a frame at least this often while standing still
local MIN_POSITION_DELTA = 0.002
local MIN_ROTATION_DELTA = 0.0005
local TELEPORT_SNAP_DISTANCE = 15 -- gaps larger than this snap instead of interpolating
local MAX_STEP_DELTA = 0.1 -- clamp per-frame playback advance so hitches don't cause jumps
local POSE_BIND_ID = "SempatPanickRecordingPlaybackPose"
local MOVE_BIND_ID = "SempatPanickRecordingPlaybackMove"

local RECORDED_KEYS = {
    [Enum.KeyCode.W] = "W",
    [Enum.KeyCode.A] = "A",
    [Enum.KeyCode.S] = "S",
    [Enum.KeyCode.D] = "D",
    [Enum.KeyCode.Space] = "Space",
    [Enum.KeyCode.LeftControl] = "LeftControl",
    [Enum.KeyCode.RightControl] = "RightControl",
    [Enum.KeyCode.LeftShift] = "LeftShift",
}

local function round(n, decimals)
    local m = 10 ^ (decimals or 0)
    return math.floor(n * m + 0.5) / m
end

-- Re-indent a compact JSON string into a 4-space pretty-printed form
-- (matching Python's json.dump(indent=4)): each object/array element on its
-- own line, ": " after keys, empty {} / [] kept inline. Only inserts
-- whitespace, so numbers/strings serialize exactly as JSONEncode produced them.
local function prettyPrintJson(s)
    local INDENT = "    "
    local out = {}
    local indent = 0
    local inStr = false
    local esc = false
    local n = #s
    local i = 1
    while i <= n do
        local c = string.sub(s, i, i)
        if inStr then
            out[#out + 1] = c
            if esc then
                esc = false
            elseif c == "\\" then
                esc = true
            elseif c == '"' then
                inStr = false
            end
        elseif c == '"' then
            inStr = true
            out[#out + 1] = c
        elseif c == "{" or c == "[" then
            local nxt = string.sub(s, i + 1, i + 1)
            if (c == "{" and nxt == "}") or (c == "[" and nxt == "]") then
                out[#out + 1] = c .. nxt
                i = i + 1
            else
                indent = indent + 1
                out[#out + 1] = c .. "\n" .. string.rep(INDENT, indent)
            end
        elseif c == "}" or c == "]" then
            indent = indent - 1
            out[#out + 1] = "\n" .. string.rep(INDENT, indent) .. c
        elseif c == "," then
            out[#out + 1] = ",\n" .. string.rep(INDENT, indent)
        elseif c == ":" then
            out[#out + 1] = ": "
        else
            out[#out + 1] = c
        end
        i = i + 1
    end
    return table.concat(out)
end

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

local function createRecordingTab(windowRef, notifyFn, options)
    options = options or {}
    local mountNotify = notifyFn

    -- Engine-invoked callback threads (RenderStep/Heartbeat/Input) may lack the
    -- executor's capabilities and cannot touch the UI library's Instances
    -- ("lacking capability plugin"). All UI mutations are queued and executed by
    -- this worker thread, created from the fully-capable executor thread.
    local pendingUiJobs = {}
    local function runOnUiThread(job)
        table.insert(pendingUiJobs, job)
    end
    task.spawn(function()
        while true do
            if #pendingUiJobs > 0 then
                local jobs = pendingUiJobs
                pendingUiJobs = {}
                for _, job in ipairs(jobs) do
                    pcall(job)
                end
            end
            task.wait()
        end
    end)
    local function safeNotify(opts)
        runOnUiThread(function()
            mountNotify(opts)
        end)
    end

    local gamePath = options.gamePath or "sempatpanick/unknown_game"
    local recordingsDir = gamePath .. "/recordings"
    local recordHotkey = Enum.KeyCode[options.recordHotkey or "Q"]
    local playbackNoClip = options.playbackNoClip ~= false

    local hasFileApi = type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfolder) == "function"
        and type(makefolder) == "function"
        and type(listfiles) == "function"
    local hasDelFile = type(delfile) == "function"
    local hasIsFile = type(isfile) == "function"

    local function ensureRecordingsFolder()
        if not hasFileApi then
            return false
        end
        local built = nil
        for segment in string.gmatch(recordingsDir, "[^/\\]+") do
            built = built and (built .. "/" .. segment) or segment
            local okIs, exists = pcall(isfolder, built)
            if not okIs or not exists then
                pcall(makefolder, built)
            end
        end
        local okIs, exists = pcall(isfolder, recordingsDir)
        return okIs and exists == true
    end

    local function recordingFilePath(name)
        return recordingsDir .. "/" .. name .. ".json"
    end

    local function fileExists(path)
        if hasIsFile then
            local ok, exists = pcall(isfile, path)
            return ok and exists == true
        end
        local ok, content = pcall(readfile, path)
        return ok and type(content) == "string"
    end

    local function sanitizeRecordingName(name)
        name = string.gsub(name or "", "%s+", "_")
        name = string.gsub(name, "[^%w%-_]", "")
        return name
    end

    local RecordingTab = windowRef:CreateTab("Recording", options.tabIcon or 4483362458)

    -- ============================ Record ============================
    RecordingTab:CreateSection("Record")

    local RecordToggle = nil
    local RecordStatusParagraph = nil

    local recordingActive = false
    local recordingNameValue = ""
    local recFrames = {}
    local recEvents = {}
    local recElapsed = 0
    local recLastStoredT = -math.huge
    local recLastPos = nil
    local recLastRot = nil
    local recLastMove = nil
    local recRootOffset = nil
    local recConns = {}

    local playbackActive = false
    local stopPlayback -- forward declaration
    local refreshRecordingsList -- forward declaration

    local function disconnectRecConns()
        for _, conn in ipairs(recConns) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        recConns = {}
    end

    local function pushRecEvent(kind, data)
        local t = round(recElapsed, 3)
        if data ~= nil then
            table.insert(recEvents, { t, kind, data })
        else
            table.insert(recEvents, { t, kind })
        end
    end

    local function captureFrame(force)
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not rootPart or not humanoid then
            return
        end

        local t = recElapsed
        local pos = rootPart.Position
        local rx, ry, rz = rootPart.CFrame:ToOrientation()
        local move = humanoid.MoveDirection

        if not force then
            local moved = true
            if recLastPos then
                local posDelta = (pos - recLastPos).Magnitude
                local rotDelta = math.abs(rx - recLastRot.X) + math.abs(ry - recLastRot.Y) + math.abs(rz - recLastRot.Z)
                local moveDelta = (move - recLastMove).Magnitude
                moved = posDelta > MIN_POSITION_DELTA or rotDelta > MIN_ROTATION_DELTA or moveDelta > 0.01
            end
            if not moved and (t - recLastStoredT) < IDLE_FRAME_INTERVAL then
                return
            end
        end

        recLastStoredT = t
        recLastPos = pos
        recLastRot = Vector3.new(rx, ry, rz)
        recLastMove = move

        table.insert(recFrames, {
            round(t, 4),
            round(pos.X, 3), round(pos.Y, 3), round(pos.Z, 3),
            round(rx, 4), round(ry, 4), round(rz, 4),
            round(move.X, 2), round(move.Z, 2),
        })
    end

    local function bindRecordingCharacter(character)
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            humanoid = character:WaitForChild("Humanoid", 5)
        end
        if not humanoid then
            return
        end
        table.insert(recConns, humanoid.StateChanged:Connect(function(_, newState)
            if not recordingActive then
                return
            end
            if newState == Enum.HumanoidStateType.Jumping then
                pushRecEvent("jump")
            elseif newState == Enum.HumanoidStateType.Freefall then
                pushRecEvent("fall")
            elseif newState == Enum.HumanoidStateType.Landed then
                pushRecEvent("land")
            elseif newState == Enum.HumanoidStateType.Seated then
                pushRecEvent("seated")
            elseif newState == Enum.HumanoidStateType.Dead then
                pushRecEvent("died")
            end
        end))
    end

    local function updateRecordStatus(text)
        runOnUiThread(function()
            if RecordStatusParagraph and RecordStatusParagraph.Set then
                RecordStatusParagraph:Set({ Title = "Status", Content = text })
            end
        end)
    end

    local function saveRecording()
        if #recFrames < 2 then
            safeNotify({ Title = "Recording", Content = "Nothing recorded (too short)", Icon = "x" })
            return
        end
        if not hasFileApi then
            safeNotify({ Title = "Recording", Content = "Executor has no file API; cannot save", Icon = "x" })
            return
        end
        if not ensureRecordingsFolder() then
            safeNotify({ Title = "Recording", Content = "Could not create " .. recordingsDir, Icon = "x" })
            return
        end

        local name = sanitizeRecordingName(recordingNameValue)
        if name == "" then
            name = os.date("rec_%Y%m%d_%H%M%S")
        end
        local finalName = name
        local suffix = 2
        while fileExists(recordingFilePath(finalName)) do
            finalName = name .. "_" .. suffix
            suffix = suffix + 1
        end

        local duration = recFrames[#recFrames][1]
        local payload = {
            version = RECORDING_VERSION,
            name = finalName,
            createdAt = os.time(),
            placeId = game.PlaceId,
            duration = duration,
            frameCount = #recFrames,
            rootOffset = recRootOffset and round(recRootOffset, 3) or nil,
            frames = recFrames,
            events = recEvents,
        }

        local okEncode, encoded = pcall(function()
            return HttpService:JSONEncode(payload)
        end)
        if not okEncode then
            safeNotify({ Title = "Recording", Content = "Encode failed: " .. tostring(encoded), Icon = "x" })
            return
        end

        -- Save in pretty-printed form; fall back to the compact string on any error.
        local okPretty, pretty = pcall(prettyPrintJson, encoded)
        if okPretty and type(pretty) == "string" then
            encoded = pretty
        end

        local okWrite, writeErr = pcall(writefile, recordingFilePath(finalName), encoded)
        if not okWrite then
            safeNotify({ Title = "Recording", Content = "Save failed: " .. tostring(writeErr), Icon = "x" })
            return
        end

        safeNotify({
            Title = "Recording",
            Content = string.format("Saved %s (%.1fs, %d frames)", finalName, duration, #recFrames),
            Icon = "check",
        })
        if refreshRecordingsList then
            refreshRecordingsList(false)
        end
    end

    local function stopRecording(save)
        if not recordingActive then
            return
        end
        captureFrame(true)
        recordingActive = false
        disconnectRecConns()
        if save then
            saveRecording()
        end
        updateRecordStatus("Idle")
    end

    local function startRecording()
        if recordingActive then
            return true
        end
        if playbackActive then
            stopPlayback(false)
        end

        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not character or not rootPart or not humanoid then
            safeNotify({ Title = "Recording", Content = "Character not loaded", Icon = "x" })
            return false
        end

        recFrames = {}
        recEvents = {}
        recElapsed = 0
        recLastStoredT = -math.huge
        recLastPos = nil
        recLastRot = nil
        recLastMove = nil
        recRootOffset = characterRootOffset(humanoid, rootPart)
        recordingActive = true

        bindRecordingCharacter(character)

        table.insert(recConns, Players.LocalPlayer.CharacterAdded:Connect(function(newCharacter)
            if not recordingActive then
                return
            end
            pushRecEvent("respawn")
            task.defer(function()
                if recordingActive then
                    bindRecordingCharacter(newCharacter)
                end
            end)
        end))

        table.insert(recConns, UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or not recordingActive then
                return
            end
            local keyName = RECORDED_KEYS[input.KeyCode]
            if keyName then
                pushRecEvent("keydown", keyName)
            end
        end))
        table.insert(recConns, UserInputService.InputEnded:Connect(function(input, _gameProcessed)
            if not recordingActive then
                return
            end
            local keyName = RECORDED_KEYS[input.KeyCode]
            if keyName then
                pushRecEvent("keyup", keyName)
            end
        end))

        -- Timeline advances by the engine's own frame delta, not wall clock,
        -- so callback scheduling jitter never distorts frame timing.
        table.insert(recConns, RunService.Heartbeat:Connect(function(deltaTime)
            if recordingActive then
                recElapsed = recElapsed + deltaTime
                captureFrame(false)
            end
        end))

        captureFrame(true)

        task.spawn(function()
            while recordingActive do
                updateRecordStatus(string.format(
                    "Recording... %.1fs | %d frames | %d events",
                    recElapsed, #recFrames, #recEvents
                ))
                task.wait(0.25)
            end
        end)

        safeNotify({ Title = "Recording", Content = "Recording started", Icon = "circle-dot" })
        return true
    end

    local function setRecordToggleUi(enabled)
        runOnUiThread(function()
            if RecordToggle and RecordToggle.Set then
                RecordToggle:Set(enabled)
            end
        end)
    end

    RecordingTab:CreateInput({
        Name = "Recording name",
        PlaceholderText = "(blank = rec_YYYYMMDD_HHMMSS)",
        CurrentValue = "",
        Callback = function(value)
            recordingNameValue = tostring(value or "")
        end,
    })

    RecordToggle = RecordingTab:CreateToggle({
        Name = "Record [" .. (options.recordHotkey or "Q") .. "]",
        CurrentValue = false,
        Callback = function(enabled)
            if enabled == recordingActive then
                return
            end
            if enabled then
                if not startRecording() then
                    task.defer(function()
                        setRecordToggleUi(false)
                    end)
                end
            else
                stopRecording(true)
            end
        end,
    })

    RecordStatusParagraph = RecordingTab:CreateParagraph({
        Title = "Status",
        Content = "Idle",
    })

    if recordHotkey then
        UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed or input.KeyCode ~= recordHotkey then
                return
            end
            if recordingActive then
                stopRecording(true)
                setRecordToggleUi(false)
            else
                if startRecording() then
                    setRecordToggleUi(true)
                end
            end
        end)
    end

    -- ============================= Play =============================
    RecordingTab:CreateSection("Play")

    local RecordingsDropdown = nil
    local PlayStatusParagraph = nil
    local recordingNames = {}
    local selectedRecordingName = nil
    local playToken = 0
    local playHeartbeatConn = nil
    local playSavedAutoRotate = nil
    local playCollideStates = nil
    local playerControlsCache = nil
    local playerControlsTried = false
    local showRecordingTracker = false
    local recordingTrackerSensitivity = 1.8 -- thickness growth per extra overlap
    local recordingTrackerCellSize = 4 -- studs; how close two passes count as the same position
    local recordingTrackerFolder = nil

    local function updatePlayStatus(text)
        runOnUiThread(function()
            if PlayStatusParagraph and PlayStatusParagraph.Set then
                PlayStatusParagraph:Set({ Title = "Playback", Content = text })
            end
        end)
    end

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

    local function applyPlaybackNoClip(character)
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") and playCollideStates[part] == nil then
                playCollideStates[part] = part.CanCollide
                part.CanCollide = false
            end
        end
    end

    stopPlayback = function(notifyUser)
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
        updatePlayStatus("Idle")
        if notifyUser then
            safeNotify({ Title = "Recording", Content = "Playback stopped" })
        end
    end

    local function loadRecording(name)
        if not hasFileApi then
            return nil, "Executor has no file API"
        end
        local path = recordingFilePath(name)
        local okRead, content = pcall(readfile, path)
        if not okRead or type(content) ~= "string" then
            return nil, "Cannot read " .. path
        end
        local okDecode, data = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        if not okDecode or type(data) ~= "table" then
            return nil, "Invalid recording file"
        end
        if type(data.frames) ~= "table" or #data.frames < 2 then
            return nil, "Recording has no frames"
        end
        return data, nil
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

    local function startPlayback()
        if playbackActive then
            safeNotify({ Title = "Recording", Content = "Playback already running" })
            return
        end
        if recordingActive then
            safeNotify({ Title = "Recording", Content = "Stop recording first", Icon = "x" })
            return
        end
        if not selectedRecordingName then
            safeNotify({ Title = "Recording", Content = "Select a recording first", Icon = "x" })
            return
        end

        local data, loadErr = loadRecording(selectedRecordingName)
        if not data then
            safeNotify({ Title = "Recording", Content = loadErr, Icon = "x" })
            return
        end

        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not rootPart or not humanoid then
            safeNotify({ Title = "Recording", Content = "Character not loaded", Icon = "x" })
            return
        end

        local frames = data.frames
        local events = type(data.events) == "table" and data.events or {}
        local duration = tonumber(data.duration) or frames[#frames][1]

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
        playToken = playToken + 1
        local myToken = playToken

        local frameCursor = 1
        local eventCursor = 1
        local playElapsed = 0
        local lastStatusUpdate = 0
        local currentMoveDir = Vector3.new(0, 0, 0)
        local finished = false

        playSavedAutoRotate = humanoid.AutoRotate
        humanoid.AutoRotate = false
        playCollideStates = {}
        if playbackNoClip then
            applyPlaybackNoClip(character)
        end
        local controls = getPlayerControls()
        if controls then
            pcall(function()
                controls:Disable()
            end)
        end

        rootPart.CFrame = frameToCFrame(frames[1]) + Vector3.new(0, currentYShift(rootPart, humanoid), 0)
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

        local function finishPlayback(message, icon)
            if finished then
                return
            end
            finished = true
            stopPlayback(false)
            if message then
                safeNotify({ Title = "Recording", Content = message, Icon = icon })
            end
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
                finishPlayback("Playback aborted (character lost)", "x")
                return
            end

            if playElapsed >= duration then
                local root = ch and ch:FindFirstChild("HumanoidRootPart")
                if root then
                    root.CFrame = frameToCFrame(frames[#frames]) + Vector3.new(0, currentYShift(root, hum), 0)
                    root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                end
                finishPlayback("Playback finished", "check")
                return
            end

            if not applyPose() then
                finishPlayback("Playback aborted (character lost)", "x")
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

            if playElapsed - lastStatusUpdate >= 0.25 then
                lastStatusUpdate = playElapsed
                updatePlayStatus(string.format(
                    "Playing %s... %.1fs / %.1fs",
                    tostring(selectedRecordingName), playElapsed, duration
                ))
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
            if playbackNoClip then
                local ch = Players.LocalPlayer.Character
                if ch and playCollideStates then
                    applyPlaybackNoClip(ch)
                end
            end
        end)

        safeNotify({
            Title = "Recording",
            Content = string.format("Playing %s (%.1fs)", selectedRecordingName, duration),
            Icon = "play",
        })
    end

    local function listSavedRecordingNames()
        local names = {}
        if not hasFileApi then
            return names
        end
        local okFolder, folderExists = pcall(isfolder, recordingsDir)
        if not okFolder or not folderExists then
            return names
        end
        local okList, files = pcall(listfiles, recordingsDir)
        if not okList or type(files) ~= "table" then
            return names
        end
        for _, filePath in ipairs(files) do
            local name = string.match(tostring(filePath), "([^/\\]+)%.json$")
            if name then
                table.insert(names, name)
            end
        end
        table.sort(names, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return names
    end

    -- Route tracker: draws the selected recording's path in the world as a neon
    -- trail (colored by the UI accent), so you can preview where it goes.
    local RECORDING_TRACKER_FOLDER_NAME = "SempatPanickRecordingTracker"
    local RECORDING_TRACKER_MIN_SPACING = 3 -- studs between sampled path points

    local function clearRecordingTracker()
        if recordingTrackerFolder then
            pcall(function()
                recordingTrackerFolder:Destroy()
            end)
            recordingTrackerFolder = nil
        end
    end

    local function recordingTrackerColor()
        local ok, color = pcall(function()
            return windowRef:GetAccentColor()
        end)
        if ok and typeof(color) == "Color3" then
            return color
        end
        return Color3.fromRGB(0, 200, 255)
    end

    local function drawRecordingTracker()
        clearRecordingTracker()
        if not showRecordingTracker or not selectedRecordingName then
            return
        end
        local data = loadRecording(selectedRecordingName)
        if not data or type(data.frames) ~= "table" or #data.frames < 2 then
            return
        end
        local frames = data.frames
        local pts = {}
        local last = nil
        for _, f in ipairs(frames) do
            local p = Vector3.new(f[2], f[3], f[4])
            if not last or (p - last).Magnitude >= RECORDING_TRACKER_MIN_SPACING then
                table.insert(pts, p)
                last = p
            end
        end
        local lastFrame = frames[#frames]
        local lp = Vector3.new(lastFrame[2], lastFrame[3], lastFrame[4])
        if not last or (lp - last).Magnitude > 0.01 then
            table.insert(pts, lp)
        end
        if #pts < 2 then
            return
        end
        local color = recordingTrackerColor()

        -- Count how many separate times the path enters each spatial cell, so
        -- stretches where the route overlaps itself can be drawn thicker/bolder.
        local CELL = recordingTrackerCellSize
        local function cellKey(p)
            return math.floor(p.X / CELL) .. "_" .. math.floor(p.Y / CELL) .. "_" .. math.floor(p.Z / CELL)
        end
        local visits = {}
        local lastKey = nil
        for _, p in ipairs(pts) do
            local k = cellKey(p)
            if k ~= lastKey then
                visits[k] = (visits[k] or 0) + 1
                lastKey = k
            end
        end

        local BASE_THICKNESS = 0.18
        local folder = Instance.new("Folder")
        folder.Name = RECORDING_TRACKER_FOLDER_NAME
        for i = 1, #pts - 1 do
            local a, b = pts[i], pts[i + 1]
            local dist = (b - a).Magnitude
            if dist > 0.01 then
                local overlap = math.max(visits[cellKey(a)] or 1, visits[cellKey(b)] or 1)
                local thickness = math.min(BASE_THICKNESS * (1 + (overlap - 1) * recordingTrackerSensitivity), BASE_THICKNESS * 6)
                local seg = Instance.new("Part")
                seg.Anchored = true
                seg.CanCollide = false
                seg.CanQuery = false
                seg.CanTouch = false
                seg.Massless = true
                seg.CastShadow = false
                seg.Material = Enum.Material.Neon
                seg.Color = color
                seg.Transparency = math.max(0.3 - (overlap - 1) * 0.08, 0.05)
                seg.Size = Vector3.new(thickness, thickness, dist)
                seg.CFrame = CFrame.lookAt((a + b) / 2, b)
                seg.Parent = folder
            end
        end
        folder.Parent = workspace
        recordingTrackerFolder = folder
    end

    refreshRecordingsList = function(showNotify)
        recordingNames = listSavedRecordingNames()
        local names = recordingNames
        runOnUiThread(function()
            if RecordingsDropdown and RecordingsDropdown.Refresh then
                RecordingsDropdown:Refresh(names)
            end
        end)
        if selectedRecordingName and not table.find(recordingNames, selectedRecordingName) then
            selectedRecordingName = nil
            runOnUiThread(function()
                if RecordingsDropdown and RecordingsDropdown.Set then
                    RecordingsDropdown:Set({})
                end
            end)
        end
        if showNotify then
            safeNotify({
                Title = "Recording",
                Content = "Found " .. #recordingNames .. " recording(s)",
            })
        end
        drawRecordingTracker()
    end

    RecordingsDropdown = RecordingTab:CreateDropdown({
        Name = "Recording",
        Options = recordingNames,
        CurrentOption = {},
        Search = true,
        Callback = function(value)
            local picked = value
            if type(value) == "table" then
                picked = value[1]
            end
            if picked and picked ~= "" then
                selectedRecordingName = picked
                local data = loadRecording(picked)
                if data then
                    updatePlayStatus(string.format(
                        "%s | %.1fs | %d frames | %s",
                        tostring(data.name or picked),
                        tonumber(data.duration) or 0,
                        tonumber(data.frameCount) or (type(data.frames) == "table" and #data.frames or 0),
                        data.createdAt and os.date("%Y-%m-%d %H:%M", data.createdAt) or "?"
                    ))
                end
            else
                selectedRecordingName = nil
            end
            drawRecordingTracker()
        end,
    })

    PlayStatusParagraph = RecordingTab:CreateParagraph({
        Title = "Playback",
        Content = "Idle",
    })

    RecordingTab:CreateToggle({
        Name = "Show Tracker",
        CurrentValue = false,
        Callback = function(enabled)
            showRecordingTracker = enabled
            drawRecordingTracker()
        end,
    })

    RecordingTab:CreateSlider({
        Name = "Tracker Overlap Sensitivity",
        Range = { 0, 5 },
        Increment = 0.1,
        Suffix = "x",
        CurrentValue = recordingTrackerSensitivity,
        Callback = function(value)
            recordingTrackerSensitivity = tonumber(value) or recordingTrackerSensitivity
            if showRecordingTracker then
                drawRecordingTracker()
            end
        end,
    })

    RecordingTab:CreateSlider({
        Name = "Tracker Overlap Detect Distance",
        Range = { 1, 15 },
        Increment = 0.5,
        Suffix = "studs",
        CurrentValue = recordingTrackerCellSize,
        Callback = function(value)
            recordingTrackerCellSize = tonumber(value) or recordingTrackerCellSize
            if showRecordingTracker then
                drawRecordingTracker()
            end
        end,
    })

    RecordingTab:CreateButton({
        Name = "Play",
        Callback = function()
            startPlayback()
        end,
    })

    RecordingTab:CreateButton({
        Name = "Stop",
        Callback = function()
            if playbackActive then
                stopPlayback(true)
            else
                safeNotify({ Title = "Recording", Content = "No playback running" })
            end
        end,
    })

    RecordingTab:CreateButton({
        Name = "Refresh list",
        Callback = function()
            refreshRecordingsList(true)
        end,
    })

    RecordingTab:CreateButton({
        Name = "Delete selected",
        Callback = function()
            if not selectedRecordingName then
                safeNotify({ Title = "Recording", Content = "Select a recording first", Icon = "x" })
                return
            end
            if not hasDelFile then
                safeNotify({ Title = "Recording", Content = "Executor has no delfile; cannot delete", Icon = "x" })
                return
            end
            if playbackActive then
                stopPlayback(false)
            end
            local deletedName = selectedRecordingName
            local okDel, delErr = pcall(delfile, recordingFilePath(deletedName))
            if okDel then
                safeNotify({ Title = "Recording", Content = "Deleted " .. deletedName, Icon = "trash" })
            else
                safeNotify({ Title = "Recording", Content = "Delete failed: " .. tostring(delErr), Icon = "x" })
            end
            refreshRecordingsList(false)
            updatePlayStatus("Idle")
        end,
    })

    task.defer(function()
        refreshRecordingsList(false)
    end)
end

return createRecordingTab
