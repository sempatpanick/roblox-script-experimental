--[[
  Recording tab module for Rayfield scripts.
  Loaded from: https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/tabs/rayfield/recording_tab.lua

  Usage:
    createRecordingTab(Window, mountNotify, "sempatpanick/<script_name>/recordings")
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local loadFunctionModule
do
    local ok, loader = pcall(require, "../../functions/load_module")
    if ok and type(loader) == "function" then
        loadFunctionModule = loader
    else
        local baseURL = shared.sempatpanick_baseURL
        assert(type(baseURL) == "string", "[tabs] baseURL not set")
        local okGet, source = pcall(function()
            return game:HttpGet(baseURL .. "/functions/load_module.lua")
        end)
        assert(okGet and type(source) == "string", "[tabs] failed to load functions/load_module")
        local chunk = (loadstring or load)(source, "functions/load_module")
        loadFunctionModule = chunk()
    end
end

local executorMod = loadFunctionModule("executor/resolve")
local pathMod = loadFunctionModule("string/path")
local jsonMod = loadFunctionModule("json/ordered_encode")
local playerMod = loadFunctionModule("player/character")
local recordingCaptureMod = loadFunctionModule("recording/capture")
local playbackMod = loadFunctionModule("recording/playback")

local resolveExecutorFn = executorMod.resolveExecutorFn
local ensureFolderPath = executorMod.ensureFolderPath
local normalizePath = pathMod.normalizePath
local baseNameFromPath = pathMod.baseNameFromPath
local isJsonPath = pathMod.isJsonPath
local encodeRecordingJsonValue = jsonMod.encodeRecordingJsonValue
local getCharacterHumanoidAndRoot = playerMod.getCharacterHumanoidAndRoot

local function createRecordingTab(windowRef, notifyFn, recordingsDir)
    local RecordingTab = windowRef:CreateTab("Recording", 4483362458)

    RecordingTab:CreateSection("Record Roblox Activities")

    local RECORDINGS_DIR = recordingsDir
    local DEFAULT_RECORDING_MOVEMENT_HZ = 30
    local MIN_RECORDING_MOVEMENT_HZ = 10
    local MAX_RECORDING_MOVEMENT_HZ = 60
    local recordingMovementHz = DEFAULT_RECORDING_MOVEMENT_HZ

    local function getRecordingSampleInterval()
        return recordingCaptureMod.getRecordingSampleInterval(
            recordingMovementHz,
            MIN_RECORDING_MOVEMENT_HZ,
            MAX_RECORDING_MOVEMENT_HZ,
            DEFAULT_RECORDING_MOVEMENT_HZ
        )
    end

    local function captureAvatarProfileForCharacter(character)
        return recordingCaptureMod.captureAvatarProfileForCharacter(character, getCharacterHumanoidAndRoot)
    end

    local makeFolderFn = resolveExecutorFn("makefolder")
    local isFolderFn = resolveExecutorFn("isfolder")
    local writeFileFn = resolveExecutorFn("writefile")
    local listFilesFn = resolveExecutorFn("listfiles")
    local readFileFn = resolveExecutorFn("readfile")
    local delFileFn = resolveExecutorFn("delfile")
    local isFileFn = resolveExecutorFn("isfile")
    local setClipboardFn = resolveExecutorFn("setclipboard") or resolveExecutorFn("toclipboard")

    local recordingStatusParagraph
    local recordingInProgress = false
    local recordingToggleControl
    local recordingHotkeyConnection = nil
    local recordingToggleHotkey = Enum.KeyCode.Q
    local recordingStartedAt = 0
    local recordingEvents = {}
    local recordingConnections = {}
    local lastMovementSignature = nil
    local lastMovementCaptureAt = 0
    local lastSavedRecordingPath = ""
    local recordingPlayersDropdown
    local RECORDING_PLAYER_NONE = "(Select player)"
    local recordingPlayerOptions = { RECORDING_PLAYER_NONE }
    local recordingPlayerDisplayToUserId = {}
    local selectedRecordingPlayerUserId = nil
    local selectedRecordingPlayerName = nil
    local savedRecordingsDropdown
    local savedRecordingStatusParagraph
    local selectedSavedRecordingPath = nil
    local playbackToken = 0
    local playbackInProgress = false
    local playbackStartedAt = 0
    local playbackHumanoid = nil
    local playbackAutoRotateRestore = nil
    local playbackKeysDown = {}
    local playbackMovementConnection = nil
    local SAVED_RECORDING_NONE = "(None)"
    local refreshRecordingPlayersDropdown = function() end
    local refreshSavedRecordingsDropdown = function(_showNotify) end

    local VirtualInputManager = nil
    pcall(function()
        VirtualInputManager = game:GetService("VirtualInputManager")
    end)

    local function disconnectRecordingConnections()
        for i = #recordingConnections, 1, -1 do
            local conn = recordingConnections[i]
            if conn then
                pcall(function()
                    conn:Disconnect()
                end)
            end
            recordingConnections[i] = nil
        end
    end

    local function recordingNow()
        return math.max(0, os.clock() - recordingStartedAt)
    end

    local function updateRecordingParagraph(extraLine)
        if not (recordingStatusParagraph and recordingStatusParagraph.Set) then
            return
        end
        local stateText = recordingInProgress and "Recording: ON" or "Recording: OFF"
        local targetText = selectedRecordingPlayerName or "(not selected)"
        local content = stateText
            .. "\nTarget: " .. targetText
            .. "\nSample rate: " .. tostring(recordingMovementHz) .. " Hz"
            .. "\nEvents: " .. tostring(#recordingEvents)
            .. "\nLast file: " .. (lastSavedRecordingPath ~= "" and lastSavedRecordingPath or "(none)")
        if extraLine and extraLine ~= "" then
            content = content .. "\n" .. extraLine
        end
        recordingStatusParagraph:Set({
            Title = "Status",
            Content = content,
        })
    end

    local function appendRecordingEvent(kind, data)
        if not recordingInProgress then
            return
        end
        table.insert(recordingEvents, {
            t = tonumber(string.format("%.3f", recordingNow())),
            kind = kind,
            data = data or {},
        })
    end

    local function updateSavedRecordingStatus(text)
        if not (savedRecordingStatusParagraph and savedRecordingStatusParagraph.Set) then
            return
        end
        savedRecordingStatusParagraph:Set({
            Title = "Saved Recording Status",
            Content = text,
        })
    end

    -- Release virtual keys, clear walk intent, and kill residual momentum (key_up alone does not).
    local function releaseSavedRecordingInputAndMotion()
        if VirtualInputManager then
            for keyCode, isDown in pairs(playbackKeysDown) do
                if isDown then
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                    end)
                end
                playbackKeysDown[keyCode] = nil
            end
        else
            playbackKeysDown = {}
        end

        if playbackHumanoid then
            pcall(function()
                playbackHumanoid:Move(Vector3.new(0, 0, 0))
            end)
        end

        local localChar = Players.LocalPlayer and Players.LocalPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if localRoot then
            pcall(function()
                localRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                localRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end)
        end
    end

    local function stopSavedRecordingPlayback(reason, shouldNotify)
        releaseSavedRecordingInputAndMotion()

        if playbackMovementConnection then
            pcall(function()
                playbackMovementConnection:Disconnect()
            end)
            playbackMovementConnection = nil
        end

        if playbackHumanoid and playbackAutoRotateRestore ~= nil then
            pcall(function()
                playbackHumanoid.AutoRotate = playbackAutoRotateRestore
            end)
        end
        playbackHumanoid = nil
        playbackAutoRotateRestore = nil
        playbackToken = playbackToken + 1
        if playbackInProgress then
            playbackInProgress = false
            local elapsed = math.max(0, os.clock() - playbackStartedAt)
            local elapsedText = string.format("%.2fs", elapsed)
            local note = reason or ("Stopped after " .. elapsedText)
            updateSavedRecordingStatus(note)
            if shouldNotify then
                notifyFn({ Title = "Recording Playback", Content = note, Icon = "info" })
            end
        elseif shouldNotify then
            notifyFn({ Title = "Recording Playback", Content = "No playback is running", Icon = "info" })
        end
    end

    local function getSelectedRecordingPlayer()
        if type(selectedRecordingPlayerUserId) ~= "number" then
            return nil
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player.UserId == selectedRecordingPlayerUserId then
                return player
            end
        end
        return nil
    end

    local function saveRecordingAsJson()
        writeFileFn = writeFileFn or resolveExecutorFn("writefile")
        if type(writeFileFn) ~= "function" then
            return nil, "writefile() is not available in this executor"
        end
        local okDir, dirErr = ensureFolderPath(RECORDINGS_DIR, makeFolderFn, isFolderFn)
        if not okDir then
            return nil, dirErr or "Unable to create recordings folder"
        end

        local fileName = string.format(
            "recording_%s_%s.json",
            tostring(game.PlaceId or 0),
            os.date("!%Y%m%d_%H%M%S")
        )
        local path = RECORDINGS_DIR .. "/" .. fileName
        local targetPlayer = getSelectedRecordingPlayer()
        local payload = {
            meta = {
                recorderName = Players.LocalPlayer and Players.LocalPlayer.Name or "unknown",
                playerName = selectedRecordingPlayerName or "unknown",
                avatarProfile = captureAvatarProfileForCharacter(targetPlayer and targetPlayer.Character),
                totalEvents = #recordingEvents,
                durationSeconds = tonumber(string.format("%.3f", math.max(0, recordingNow()))),
                movementSampleHz = recordingMovementHz,
                startedAtUtc = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                gameId = game.GameId,
                placeId = game.PlaceId,
                jobId = game.JobId,
            },
            events = recordingEvents,
        }
        local okEncode, jsonText = pcall(function()
            return encodeRecordingJsonValue(payload, nil, true, 0)
        end)
        if not okEncode then
            return nil, "JSON encode failed"
        end
        local okWrite, writeErr = pcall(function()
            writeFileFn(path, jsonText)
        end)
        if not okWrite then
            return nil, tostring(writeErr)
        end
        return path, nil
    end

    local function recordMovementSample(targetPlayer)
        local character = targetPlayer and targetPlayer.Character
        local humanoid, rootPart = getCharacterHumanoidAndRoot(character)
        if not humanoid or not rootPart then
            return
        end
        local sampleData = recordingCaptureMod.buildMovementSampleData(humanoid, rootPart)
        local signature = recordingCaptureMod.buildMovementSampleSignature(sampleData)
        if signature == lastMovementSignature then
            return
        end
        lastMovementSignature = signature
        appendRecordingEvent("movement", sampleData)
    end

    local function attachCharacterRecordingHooks(character)
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            appendRecordingEvent("character_missing_humanoid", {})
            return
        end
        appendRecordingEvent("character_hooked", {
            characterName = (character and character.Name) or "unknown",
        })
        table.insert(recordingConnections, humanoid.StateChanged:Connect(function(_, newState)
            if not recordingInProgress then
                return
            end
            if newState == Enum.HumanoidStateType.Jumping
                or newState == Enum.HumanoidStateType.Freefall
                or newState == Enum.HumanoidStateType.Landed
            then
                appendRecordingEvent("humanoid_state", {
                    state = tostring(newState),
                })
            end
        end))
    end

    local function startRecording()
        if recordingInProgress then
            notifyFn({ Title = "Recording", Content = "Already recording", Icon = "info" })
            return false
        end

        local targetPlayer = getSelectedRecordingPlayer()
        if not targetPlayer then
            updateRecordingParagraph("Select a player first")
            notifyFn({ Title = "Recording", Content = "Select a player before recording", Icon = "x" })
            return false
        end
        local recordLocalInputs = targetPlayer == Players.LocalPlayer

        disconnectRecordingConnections()
        recordingEvents = {}
        recordingStartedAt = os.clock()
        lastMovementSignature = nil
        lastMovementCaptureAt = 0
        recordingInProgress = true

        appendRecordingEvent("recording_started", {
            placeId = game.PlaceId,
            playerName = targetPlayer.Name,
            playerUserId = targetPlayer.UserId,
            recorderName = Players.LocalPlayer and Players.LocalPlayer.Name or "unknown",
            recordKeyboardInputs = recordLocalInputs,
            movementSampleHz = recordingMovementHz,
            avatarProfile = captureAvatarProfileForCharacter(targetPlayer.Character),
        })

        table.insert(recordingConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not recordingInProgress then
                return
            end
            if not recordLocalInputs then
                return
            end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                if input.KeyCode == recordingToggleHotkey then
                    return
                end
                appendRecordingEvent("key_down", {
                    keyCode = tostring(input.KeyCode),
                    gameProcessed = gameProcessed == true,
                })
            end
        end))

        table.insert(recordingConnections, UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if not recordingInProgress then
                return
            end
            if not recordLocalInputs then
                return
            end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                if input.KeyCode == recordingToggleHotkey then
                    return
                end
                appendRecordingEvent("key_up", {
                    keyCode = tostring(input.KeyCode),
                    gameProcessed = gameProcessed == true,
                })
            end
        end))

        table.insert(recordingConnections, UserInputService.JumpRequest:Connect(function()
            if not recordLocalInputs then
                return
            end
            appendRecordingEvent("jump_request", {})
        end))

        table.insert(recordingConnections, targetPlayer.CharacterAdded:Connect(function(newCharacter)
            appendRecordingEvent("character_added", {
                characterName = newCharacter and newCharacter.Name or "unknown",
            })
            attachCharacterRecordingHooks(newCharacter)
        end))

        attachCharacterRecordingHooks(targetPlayer.Character)

        table.insert(recordingConnections, RunService.PostSimulation:Connect(function()
            if not recordingInProgress then
                return
            end
            local now = recordingNow()
            if (now - lastMovementCaptureAt) < getRecordingSampleInterval() then
                return
            end
            lastMovementCaptureAt = now
            recordMovementSample(targetPlayer)
        end))

        updateRecordingParagraph("Capture started")
        notifyFn({ Title = "Recording", Content = "Recording started for " .. targetPlayer.Name, Icon = "check" })
        return true
    end

    local function stopRecording()
        if not recordingInProgress then
            notifyFn({ Title = "Recording", Content = "No active recording", Icon = "info" })
            return
        end

        appendRecordingEvent("recording_stopped", {
            totalEvents = #recordingEvents,
        })

        recordingInProgress = false
        disconnectRecordingConnections()

        local savedPath, saveErr = saveRecordingAsJson()
        if savedPath then
            lastSavedRecordingPath = savedPath
            notifyFn({
                Title = "Recording",
                Content = "Saved " .. tostring(#recordingEvents) .. " events to " .. savedPath,
                Icon = "check",
            })
            updateRecordingParagraph("Saved to " .. savedPath)
            refreshSavedRecordingsDropdown(false)
        else
            notifyFn({
                Title = "Recording",
                Content = "Failed to save: " .. tostring(saveErr),
                Icon = "x",
            })
            updateRecordingParagraph("Save failed: " .. tostring(saveErr))
        end
    end

    recordingStatusParagraph = RecordingTab:CreateParagraph({
        Title = "Status",
        Content = "Recording: OFF\nTarget: (not selected)\nEvents: 0\nLast file: (none)",
    })

    refreshRecordingPlayersDropdown = function()
        recordingPlayerOptions = { RECORDING_PLAYER_NONE }
        recordingPlayerDisplayToUserId = {}

        local localPlayer = Players.LocalPlayer
        local playersList = Players:GetPlayers()
        table.sort(playersList, function(a, b)
            local aDisplay = string.lower(a.DisplayName or a.Name or "")
            local bDisplay = string.lower(b.DisplayName or b.Name or "")
            if aDisplay == bDisplay then
                return string.lower(a.Name) < string.lower(b.Name)
            end
            return aDisplay < bDisplay
        end)
        local displayLabelCount = {}

        for _, player in ipairs(playersList) do
            local displayName = player.DisplayName or player.Name
            if localPlayer and player == localPlayer then
                displayName = displayName .. " (me)"
            end
            local count = (displayLabelCount[displayName] or 0) + 1
            displayLabelCount[displayName] = count
            if count > 1 then
                displayName = displayName .. " [" .. tostring(count) .. "]"
            end
            table.insert(recordingPlayerOptions, displayName)
            recordingPlayerDisplayToUserId[displayName] = player.UserId
        end

        if recordingPlayersDropdown and recordingPlayersDropdown.Refresh then
            recordingPlayersDropdown:Refresh(recordingPlayerOptions)
        end

        if type(selectedRecordingPlayerUserId) == "number" then
            local selectedStillExists = false
            for _, player in ipairs(playersList) do
                if player.UserId == selectedRecordingPlayerUserId then
                    selectedStillExists = true
                    selectedRecordingPlayerName = player.Name
                    break
                end
            end
            if not selectedStillExists then
                selectedRecordingPlayerUserId = nil
                selectedRecordingPlayerName = nil
                if recordingPlayersDropdown and recordingPlayersDropdown.Set then
                    recordingPlayersDropdown:Set({ RECORDING_PLAYER_NONE })
                end
            end
        end

        updateRecordingParagraph()
    end

    recordingPlayersDropdown = RecordingTab:CreateDropdown({
        Name = "Players",
        Options = recordingPlayerOptions,
        CurrentOption = { RECORDING_PLAYER_NONE },
        Search = true,
        Callback = function(value)
            local picked = (type(value) == "table" and value[1]) or value
            if type(picked) ~= "string" or picked == "" or picked == RECORDING_PLAYER_NONE then
                selectedRecordingPlayerUserId = nil
                selectedRecordingPlayerName = nil
                updateRecordingParagraph("Select a player to start recording")
                return
            end
            local pickedUserId = recordingPlayerDisplayToUserId[picked]
            if type(pickedUserId) == "number" then
                selectedRecordingPlayerUserId = pickedUserId
                local selectedPlayer = getSelectedRecordingPlayer()
                selectedRecordingPlayerName = selectedPlayer and selectedPlayer.Name or nil
                updateRecordingParagraph()
            else
                selectedRecordingPlayerUserId = nil
                selectedRecordingPlayerName = nil
                updateRecordingParagraph("Selected player is unavailable")
            end
        end,
    })
    refreshRecordingPlayersDropdown()

    RecordingTab:CreateSlider({
        Name = "Movement sample rate",
        Flag = "recording_movement_hz",
        Range = { MIN_RECORDING_MOVEMENT_HZ, MAX_RECORDING_MOVEMENT_HZ },
        Increment = 5,
        Suffix = "Hz",
        CurrentValue = DEFAULT_RECORDING_MOVEMENT_HZ,
        Callback = function(value)
            recordingMovementHz = math.clamp(math.floor(tonumber(value) or DEFAULT_RECORDING_MOVEMENT_HZ), MIN_RECORDING_MOVEMENT_HZ, MAX_RECORDING_MOVEMENT_HZ)
            updateRecordingParagraph()
        end,
    })

    RecordingTab:CreateParagraph({
        Title = "Sample rate",
        Content = "Higher Hz = smoother playback and larger JSON files.\n10 Hz (compact) · 30 Hz (default) · 60 Hz (smoothest)",
    })

    Players.PlayerAdded:Connect(function()
        refreshRecordingPlayersDropdown()
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(function()
            refreshRecordingPlayersDropdown()
        end)
    end)

    local function setRecordingEnabled(enabled)
        if enabled then
            if not recordingInProgress then
                return startRecording()
            end
            return true
        else
            if recordingInProgress then
                stopRecording()
            end
            return true
        end
    end

    local function syncRecordingToggleUi(enabled)
        if not recordingToggleControl then
            return
        end
        if recordingToggleControl.Set then
            pcall(function()
                recordingToggleControl:Set(enabled)
            end)
            return
        end
        if recordingToggleControl.SetValue then
            pcall(function()
                recordingToggleControl:SetValue(enabled)
            end)
        end
    end

    RecordingTab:CreateParagraph({
        Title = "Keybind",
        Content = "Press Q to toggle recording ON/OFF",
    })

    recordingToggleControl = RecordingTab:CreateToggle({
        Name = "Recording (toggle ON/OFF)",
        CurrentValue = false,
        Callback = function(enabled)
            local shouldEnable = enabled == true
            local ok = setRecordingEnabled(shouldEnable)
            if shouldEnable and not ok then
                syncRecordingToggleUi(false)
            end
        end,
    })

    if recordingHotkeyConnection then
        pcall(function()
            recordingHotkeyConnection:Disconnect()
        end)
    end
    recordingHotkeyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if UserInputService:GetFocusedTextBox() then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.Keyboard or input.KeyCode ~= recordingToggleHotkey then
            return
        end
        local nextEnabled = not recordingInProgress
        local ok = setRecordingEnabled(nextEnabled)
        if nextEnabled and not ok then
            nextEnabled = false
        end
        syncRecordingToggleUi(nextEnabled)
    end)

    RecordingTab:CreateSection("Saved Recording")

    local savedDisplayToPath = {}
    local savedDisplayOptions = { SAVED_RECORDING_NONE }

    refreshSavedRecordingsDropdown = function(showNotify)
        selectedSavedRecordingPath = nil
        savedDisplayToPath = {}
        savedDisplayOptions = { SAVED_RECORDING_NONE }

        if type(listFilesFn) ~= "function" then
            listFilesFn = listFilesFn or resolveExecutorFn("listfiles")
        end
        if type(listFilesFn) ~= "function" then
            updateSavedRecordingStatus("listfiles() is not available in this executor")
            if showNotify then
                notifyFn({ Title = "Saved Recording", Content = "listfiles() is not available", Icon = "x" })
            end
            if savedRecordingsDropdown and savedRecordingsDropdown.Refresh then
                savedRecordingsDropdown:Refresh(savedDisplayOptions)
            end
            return
        end

        ensureFolderPath(RECORDINGS_DIR, makeFolderFn, isFolderFn)
        local okList, filesOrErr = pcall(function()
            return listFilesFn(RECORDINGS_DIR)
        end)
        if not okList or type(filesOrErr) ~= "table" then
            updateSavedRecordingStatus("Failed to list recordings")
            if showNotify then
                notifyFn({
                    Title = "Saved Recording",
                    Content = "Failed to list recordings: " .. tostring(filesOrErr),
                    Icon = "x",
                })
            end
            if savedRecordingsDropdown and savedRecordingsDropdown.Refresh then
                savedRecordingsDropdown:Refresh(savedDisplayOptions)
            end
            return
        end

        local candidates = {}
        for _, item in ipairs(filesOrErr) do
            if type(item) == "string" then
                local normalized = normalizePath(item)
                if isJsonPath(normalized) then
                    table.insert(candidates, item)
                end
            end
        end
        table.sort(candidates, function(a, b)
            return string.lower(normalizePath(a)) > string.lower(normalizePath(b))
        end)

        local displayCount = {}
        for _, path in ipairs(candidates) do
            local display = baseNameFromPath(path)
            local count = (displayCount[display] or 0) + 1
            displayCount[display] = count
            if count > 1 then
                display = display .. " [" .. tostring(count) .. "]"
            end
            table.insert(savedDisplayOptions, display)
            savedDisplayToPath[display] = path
        end

        if savedRecordingsDropdown and savedRecordingsDropdown.Refresh then
            savedRecordingsDropdown:Refresh(savedDisplayOptions)
        end

        updateSavedRecordingStatus("Loaded " .. tostring(#candidates) .. " recording file(s)")
        if showNotify then
            notifyFn({
                Title = "Saved Recording",
                Content = "Loaded " .. tostring(#candidates) .. " recording file(s)",
                Icon = "check",
            })
        end
    end

    savedRecordingsDropdown = RecordingTab:CreateDropdown({
        Name = "Saved recordings",
        Options = savedDisplayOptions,
        CurrentOption = { SAVED_RECORDING_NONE },
        Search = true,
        Ext = true,
        Callback = function(value)
            selectedSavedRecordingPath = playbackMod.refreshSelectionFromDropdownValue(value, SAVED_RECORDING_NONE, savedDisplayToPath)
            if selectedSavedRecordingPath then
                updateSavedRecordingStatus("Selected: " .. baseNameFromPath(selectedSavedRecordingPath))
            else
                updateSavedRecordingStatus("Select a recording file")
            end
        end,
    })

    savedRecordingStatusParagraph = RecordingTab:CreateParagraph({
        Title = "Saved Recording Status",
        Content = "Select a recording file",
    })

    RecordingTab:CreateButton({
        Name = "Play",
        Ext = true,
        Callback = function()
            if not selectedSavedRecordingPath then
                notifyFn({ Title = "Recording Playback", Content = "Select a saved recording first", Icon = "x" })
                return
            end
            readFileFn = readFileFn or resolveExecutorFn("readfile")
            isFileFn = isFileFn or resolveExecutorFn("isfile")
            if type(readFileFn) ~= "function" then
                notifyFn({ Title = "Recording Playback", Content = "readfile() is not available", Icon = "x" })
                return
            end
            if type(isFileFn) == "function" then
                local okFile, exists = pcall(function()
                    return isFileFn(selectedSavedRecordingPath)
                end)
                if okFile and not exists then
                    notifyFn({ Title = "Recording Playback", Content = "Selected file no longer exists", Icon = "x" })
                    refreshSavedRecordingsDropdown(false)
                    return
                end
            end

            local okRead, jsonText = pcall(function()
                return readFileFn(selectedSavedRecordingPath)
            end)
            if not okRead then
                notifyFn({ Title = "Recording Playback", Content = "Failed to read file", Icon = "x" })
                return
            end
            local okDecode, payload = pcall(function()
                return HttpService:JSONDecode(jsonText)
            end)
            if not okDecode or type(payload) ~= "table" then
                notifyFn({ Title = "Recording Playback", Content = "Invalid recording JSON", Icon = "x" })
                return
            end
            local events = payload.events
            if type(events) ~= "table" or #events == 0 then
                notifyFn({ Title = "Recording Playback", Content = "Recording has no events", Icon = "x" })
                return
            end

            stopSavedRecordingPlayback(nil, false)
            playbackToken = playbackToken + 1
            local token = playbackToken
            playbackInProgress = true
            playbackStartedAt = os.clock()
            playbackHumanoid = nil
            playbackAutoRotateRestore = nil
            playbackKeysDown = {}

            local movementTrack = {}
            for _, ev in ipairs(events) do
                if ev.kind == "movement" then
                    table.insert(movementTrack, ev)
                end
            end

            local selectedName = baseNameFromPath(selectedSavedRecordingPath)
            updateSavedRecordingStatus("Playing: " .. selectedName)
            notifyFn({
                Title = "Recording Playback",
                Content = "Playing " .. selectedName .. " (" .. tostring(#events) .. " events)",
                Icon = "check",
            })

            task.spawn(function()
                local recordedAvatarProfile = playbackMod.extractRecordedAvatarProfile(payload, events)
                local localCharacter = Players.LocalPlayer and Players.LocalPlayer.Character
                local playbackAvatarAdjust = playbackMod.buildPlaybackAvatarAdjustment(
                    recordedAvatarProfile,
                    captureAvatarProfileForCharacter(localCharacter)
                )
                if playbackAvatarAdjust and playbackAvatarAdjust.detail then
                    updateSavedRecordingStatus("Playing: " .. selectedName .. "\n" .. playbackAvatarAdjust.detail)
                end

                local started = os.clock()

                if #movementTrack > 0 then
                    if playbackMovementConnection then
                        pcall(function()
                            playbackMovementConnection:Disconnect()
                        end)
                        playbackMovementConnection = nil
                    end
                    playbackMovementConnection = RunService.RenderStepped:Connect(function()
                        if token ~= playbackToken then
                            return
                        end
                        local elapsed = os.clock() - started
                        local character = Players.LocalPlayer and Players.LocalPlayer.Character
                        local humanoid, rootPart = getCharacterHumanoidAndRoot(character)
                        if not rootPart then
                            return
                        end

                        if humanoid and playbackHumanoid ~= humanoid then
                            if playbackHumanoid and playbackAutoRotateRestore ~= nil then
                                pcall(function()
                                    playbackHumanoid.AutoRotate = playbackAutoRotateRestore
                                end)
                            end
                            playbackHumanoid = humanoid
                            playbackAutoRotateRestore = humanoid.AutoRotate
                            pcall(function()
                                humanoid.AutoRotate = false
                            end)
                        end

                        local segIdx = playbackMod.findMovementSegmentIndex(movementTrack, elapsed)
                        if not segIdx then
                            return
                        end

                        local evA = movementTrack[segIdx]
                        local evB = movementTrack[math.min(segIdx + 1, #movementTrack)]
                        local tA = tonumber(evA.t) or 0
                        local tB = tonumber(evB.t) or tA
                        local dataA = type(evA.data) == "table" and evA.data or {}
                        local dataB = type(evB.data) == "table" and evB.data or {}
                        local cfA = playbackMod.buildMovementTargetCFrame(rootPart, dataA, playbackAvatarAdjust)
                        local cfB = playbackMod.buildMovementTargetCFrame(rootPart, dataB, playbackAvatarAdjust)
                        if not (cfA and cfB) then
                            return
                        end

                        local alpha = 1
                        if evB ~= evA and tB > tA then
                            alpha = math.clamp((elapsed - tA) / (tB - tA), 0, 1)
                        elseif elapsed < tA then
                            alpha = 0
                        end

                        pcall(function()
                            rootPart.CFrame = cfA:Lerp(cfB, alpha)
                        end)
                    end)
                end

                for _, event in ipairs(events) do
                    if token ~= playbackToken then
                        return
                    end

                    local kind = event.kind
                    if kind == "movement" then
                        continue
                    end

                    local targetT = tonumber(event.t) or 0
                    while token == playbackToken and (os.clock() - started) < targetT do
                        task.wait(0.01)
                    end
                    if token ~= playbackToken then
                        return
                    end

                    local data = type(event.data) == "table" and event.data or {}
                    local character = Players.LocalPlayer and Players.LocalPlayer.Character
                    local humanoid = select(1, getCharacterHumanoidAndRoot(character))

                    if kind == "jump_request" then
                        if humanoid then
                            pcall(function()
                                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end)
                        end
                    elseif (kind == "key_down" or kind == "key_up") and VirtualInputManager then
                        local keyCodeName = type(data.keyCode) == "string" and data.keyCode or ""
                        local enumName = string.match(keyCodeName, "Enum%.KeyCode%.(.+)")
                        local keyCode = enumName and Enum.KeyCode[enumName]
                        if keyCode then
                            local isDown = kind == "key_down"
                            pcall(function()
                                VirtualInputManager:SendKeyEvent(isDown, keyCode, false, game)
                            end)
                            playbackKeysDown[keyCode] = isDown or nil
                        end
                    end
                end

                if token == playbackToken then
                    if playbackMovementConnection then
                        pcall(function()
                            playbackMovementConnection:Disconnect()
                        end)
                        playbackMovementConnection = nil
                    end
                    releaseSavedRecordingInputAndMotion()
                    if playbackHumanoid and playbackAutoRotateRestore ~= nil then
                        pcall(function()
                            playbackHumanoid.AutoRotate = playbackAutoRotateRestore
                        end)
                    end
                    playbackHumanoid = nil
                    playbackAutoRotateRestore = nil
                    playbackInProgress = false
                    updateSavedRecordingStatus("Playback finished: " .. selectedName)
                    notifyFn({
                        Title = "Recording Playback",
                        Content = "Finished " .. selectedName,
                        Icon = "check",
                    })
                end
            end)
        end,
    })

    RecordingTab:CreateButton({
        Name = "Stop",
        Ext = true,
        Callback = function()
            stopSavedRecordingPlayback("Playback stopped", true)
        end,
    })

    RecordingTab:CreateButton({
        Name = "Export",
        Ext = true,
        Callback = function()
            if not selectedSavedRecordingPath then
                notifyFn({ Title = "Saved Recording", Content = "Select a saved recording first", Icon = "x" })
                return
            end
            readFileFn = readFileFn or resolveExecutorFn("readfile")
            setClipboardFn = setClipboardFn or resolveExecutorFn("setclipboard") or resolveExecutorFn("toclipboard")
            if type(readFileFn) ~= "function" then
                notifyFn({ Title = "Saved Recording", Content = "readfile() is not available", Icon = "x" })
                return
            end
            if type(setClipboardFn) ~= "function" then
                notifyFn({ Title = "Saved Recording", Content = "Clipboard is not available", Icon = "x" })
                return
            end

            local okRead, jsonText = pcall(function()
                return readFileFn(selectedSavedRecordingPath)
            end)
            if not okRead then
                notifyFn({ Title = "Saved Recording", Content = "Failed to read selected file", Icon = "x" })
                return
            end

            local okCopy, copyErr = pcall(function()
                setClipboardFn(jsonText)
            end)
            if not okCopy then
                notifyFn({
                    Title = "Saved Recording",
                    Content = "Failed to copy JSON: " .. tostring(copyErr),
                    Icon = "x",
                })
                return
            end

            notifyFn({
                Title = "Saved Recording",
                Content = "JSON copied from " .. baseNameFromPath(selectedSavedRecordingPath),
                Icon = "check",
            })
            updateSavedRecordingStatus("Exported JSON to clipboard")
        end,
    })

    RecordingTab:CreateButton({
        Name = "Remove",
        Ext = true,
        Callback = function()
            if not selectedSavedRecordingPath then
                notifyFn({ Title = "Saved Recording", Content = "Select a saved recording first", Icon = "x" })
                return
            end
            delFileFn = delFileFn or resolveExecutorFn("delfile")
            if type(delFileFn) ~= "function" then
                notifyFn({ Title = "Saved Recording", Content = "delfile() is not available", Icon = "x" })
                return
            end

            stopSavedRecordingPlayback(nil, false)
            local removedName = baseNameFromPath(selectedSavedRecordingPath)
            local okDelete, deleteErr = pcall(function()
                delFileFn(selectedSavedRecordingPath)
            end)
            if not okDelete then
                notifyFn({
                    Title = "Saved Recording",
                    Content = "Failed to remove file: " .. tostring(deleteErr),
                    Icon = "x",
                })
                return
            end

            notifyFn({
                Title = "Saved Recording",
                Content = "Removed " .. removedName,
                Icon = "check",
            })
            refreshSavedRecordingsDropdown(false)
            updateSavedRecordingStatus("Removed " .. removedName)
        end,
    })

    RecordingTab:CreateButton({
        Name = "Refresh Saved List",
        Ext = true,
        Callback = function()
            refreshSavedRecordingsDropdown(true)
        end,
    })

    refreshSavedRecordingsDropdown(false)
end

return createRecordingTab
