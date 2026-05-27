--[[
  Recording tab module for Rayfield scripts.
  Loaded from: https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/tabs/recording_tab.lua

  Usage:
    createRecordingTab(Window, mountNotify, "sempatpanick/<script_name>/recordings")
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")

local function createRecordingTab(windowRef, notifyFn, recordingsDir)
    local RecordingTab = windowRef:CreateTab("Recording", 4483362458)

    RecordingTab:CreateSection("Record Roblox Activities")

    local RECORDINGS_DIR = recordingsDir
    local DEFAULT_RECORDING_MOVEMENT_HZ = 30
    local MIN_RECORDING_MOVEMENT_HZ = 10
    local MAX_RECORDING_MOVEMENT_HZ = 60
    local recordingMovementHz = DEFAULT_RECORDING_MOVEMENT_HZ

    local function getRecordingSampleInterval()
        local hz = tonumber(recordingMovementHz) or DEFAULT_RECORDING_MOVEMENT_HZ
        hz = math.clamp(hz, MIN_RECORDING_MOVEMENT_HZ, MAX_RECORDING_MOVEMENT_HZ)
        return 1 / hz
    end
    local function resolveExecutorFn(name)
        local v = rawget(_G, name)
        if type(v) == "function" then
            return v
        end
        local getGenvFn = rawget(_G, "getgenv")
        local okGenv, genv = pcall(function()
            return type(getGenvFn) == "function" and getGenvFn() or nil
        end)
        if okGenv and type(genv) == "table" then
            local gv = rawget(genv, name) or genv[name]
            if type(gv) == "function" then
                return gv
            end
        end
        local okFenv, fenv = pcall(function()
            return getfenv and getfenv()
        end)
        if okFenv and type(fenv) == "table" then
            local fv = rawget(fenv, name) or fenv[name]
            if type(fv) == "function" then
                return fv
            end
        end
        return nil
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

    local function splitPathSegments(path)        local segments = {}
        for piece in string.gmatch(path, "[^/]+") do
            if piece ~= "" and piece ~= "." then
                table.insert(segments, piece)
            end
        end
        return segments
    end

    local function normalizePath(path)
        return string.gsub(path or "", "\\", "/")
    end

    local function baseNameFromPath(path)
        local normalized = normalizePath(path)
        local idx = string.match(normalized, "^.*()/")
        if idx then
            return string.sub(normalized, idx + 1)
        end
        return normalized
    end

    local function isJsonPath(path)
        return string.sub(string.lower(path), -5) == ".json"
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

    local function refreshSelectionFromDropdownValue(value, pathMap)
        local picked = (type(value) == "table" and value[1]) or value
        if type(picked) ~= "string" or picked == "" or picked == SAVED_RECORDING_NONE then
            selectedSavedRecordingPath = nil
            return
        end
        selectedSavedRecordingPath = pathMap[picked]
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

    local function ensureRecordingsDirectory()
        makeFolderFn = makeFolderFn or resolveExecutorFn("makefolder")
        isFolderFn = isFolderFn or resolveExecutorFn("isfolder")
        if type(makeFolderFn) ~= "function" then
            return false, "makefolder() is not available in this executor"
        end
        local segments = splitPathSegments(RECORDINGS_DIR)
        local current = ""
        for _, seg in ipairs(segments) do
            current = (current == "") and seg or (current .. "/" .. seg)
            local exists = false
            if type(isFolderFn) == "function" then
                local okExists, result = pcall(function()
                    return isFolderFn(current)
                end)
                exists = okExists and result or false
            end
            if not exists then
                local okMake, errMake = pcall(function()
                    makeFolderFn(current)
                end)
                if not okMake then
                    if type(isFolderFn) == "function" then
                        local okRetry, retryExists = pcall(function()
                            return isFolderFn(current)
                        end)
                        if okRetry and retryExists then
                            exists = true
                        else
                            return false, tostring(errMake)
                        end
                    else
                        return false, tostring(errMake)
                    end
                end
            end
        end
        return true, nil
    end

    local captureAvatarProfileForCharacter

    local META_FIELD_ORDER = {
        "recorderName",
        "playerName",
        "avatarProfile",
        "totalEvents",
        "durationSeconds",
        "movementSampleHz",
        "startedAtUtc",
        "gameId",
        "placeId",
        "jobId",
    }

    local function isSequentialArray(tbl)
        local maxIndex = 0
        local count = 0
        for k, _ in pairs(tbl) do
            if type(k) ~= "number" or k < 1 or k % 1 ~= 0 then
                return false
            end
            if k > maxIndex then
                maxIndex = k
            end
            count = count + 1
        end
        return maxIndex == count
    end

    local function orderedObjectKeys(tbl, parentKey)
        local keys = {}
        for k, _ in pairs(tbl) do
            if type(k) == "string" then
                table.insert(keys, k)
            end
        end

        local ordered = {}
        local used = {}
        local preferredOrder = {}

        if tbl.meta ~= nil and tbl.events ~= nil then
            preferredOrder = { "meta", "events" }
        elseif tbl.t ~= nil and tbl.kind ~= nil and tbl.data ~= nil then
            preferredOrder = { "t", "kind", "data" }
        elseif tbl.isGrounded ~= nil
            and tbl.walkSpeed ~= nil
            and tbl.jumpHeight ~= nil
            and tbl.jumpPower ~= nil
            and tbl.position ~= nil
            and tbl.lookDirection ~= nil
            and tbl.moveDirection ~= nil
            and tbl.velocity ~= nil
        then
            preferredOrder = {
                "isGrounded",
                "walkSpeed",
                "jumpHeight",
                "jumpPower",
                "position",
                "lookDirection",
                "moveDirection",
                "velocity",
            }
        elseif parentKey == "meta" then
            preferredOrder = META_FIELD_ORDER
        elseif tbl.x ~= nil and tbl.y ~= nil and tbl.z ~= nil then
            preferredOrder = { "x", "y", "z" }
        end

        for _, k in ipairs(preferredOrder) do
            if tbl[k] ~= nil and not used[k] then
                table.insert(ordered, k)
                used[k] = true
            end
        end

        local remaining = {}
        for _, k in ipairs(keys) do
            if not used[k] then
                table.insert(remaining, k)
            end
        end
        table.sort(remaining, function(a, b)
            return a < b
        end)
        for _, k in ipairs(remaining) do
            table.insert(ordered, k)
        end
        return ordered
    end

    local function encodeRecordingJsonValue(value, parentKey, pretty, depth)
        local level = depth or 0
        local valueType = type(value)
        if value == nil then
            return "null"
        elseif valueType == "string" then
            return HttpService:JSONEncode(value)
        elseif valueType == "boolean" then
            return value and "true" or "false"
        elseif valueType == "number" then
            if value ~= value or value == math.huge or value == -math.huge then
                return "null"
            end
            return tostring(value)
        elseif valueType ~= "table" then
            return HttpService:JSONEncode(tostring(value))
        end

        if isSequentialArray(value) then
            local parts = {}
            for i = 1, #value do
                local encoded = encodeRecordingJsonValue(value[i], nil, pretty, level + 1)
                if pretty then
                    local indent = string.rep("  ", level + 1)
                    parts[i] = indent .. encoded
                else
                    parts[i] = encoded
                end
            end
            if pretty then
                if #parts == 0 then
                    return "[]"
                end
                local closingIndent = string.rep("  ", level)
                return "[\n" .. table.concat(parts, ",\n") .. "\n" .. closingIndent .. "]"
            end
            return "[" .. table.concat(parts, ",") .. "]"
        end

        local objectParts = {}
        local keys = orderedObjectKeys(value, parentKey)
        for _, k in ipairs(keys) do
            local encodedKey = HttpService:JSONEncode(k)
            local encodedValue = encodeRecordingJsonValue(value[k], k, pretty, level + 1)
            if pretty then
                local indent = string.rep("  ", level + 1)
                table.insert(objectParts, indent .. encodedKey .. ": " .. encodedValue)
            else
                table.insert(objectParts, encodedKey .. ":" .. encodedValue)
            end
        end
        if pretty then
            if #objectParts == 0 then
                return "{}"
            end
            local closingIndent = string.rep("  ", level)
            return "{\n" .. table.concat(objectParts, ",\n") .. "\n" .. closingIndent .. "}"
        end
        return "{" .. table.concat(objectParts, ",") .. "}"
    end

    local function saveRecordingAsJson()
        writeFileFn = writeFileFn or resolveExecutorFn("writefile")
        if type(writeFileFn) ~= "function" then
            return nil, "writefile() is not available in this executor"
        end
        local okDir, dirErr = ensureRecordingsDirectory()
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

    local function getCharacterHumanoidAndRoot(character)
        if not character then
            return nil, nil
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        return humanoid, rootPart
    end

    captureAvatarProfileForCharacter = function(character)
        local profile = {
            capturedAtUtc = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        }
        local humanoid, rootPart = getCharacterHumanoidAndRoot(character)
        if humanoid then
            profile.rigType = tostring(humanoid.RigType)
            profile.hipHeight = tonumber(string.format("%.3f", humanoid.HipHeight))
            profile.walkSpeed = tonumber(string.format("%.3f", humanoid.WalkSpeed))
            profile.jumpPower = tonumber(string.format("%.3f", humanoid.JumpPower))
            profile.jumpHeight = tonumber(string.format("%.3f", humanoid.JumpHeight))
            local bodyHeightScaleObj = humanoid:FindFirstChild("BodyHeightScale")
            local bodyWidthScaleObj = humanoid:FindFirstChild("BodyWidthScale")
            local bodyDepthScaleObj = humanoid:FindFirstChild("BodyDepthScale")
            local bodyTypeScaleObj = humanoid:FindFirstChild("BodyTypeScale")
            local headScaleObj = humanoid:FindFirstChild("HeadScale")
            if bodyHeightScaleObj and bodyHeightScaleObj:IsA("NumberValue") then
                profile.bodyHeightScale = tonumber(string.format("%.3f", bodyHeightScaleObj.Value))
            end
            if bodyWidthScaleObj and bodyWidthScaleObj:IsA("NumberValue") then
                profile.bodyWidthScale = tonumber(string.format("%.3f", bodyWidthScaleObj.Value))
            end
            if bodyDepthScaleObj and bodyDepthScaleObj:IsA("NumberValue") then
                profile.bodyDepthScale = tonumber(string.format("%.3f", bodyDepthScaleObj.Value))
            end
            if bodyTypeScaleObj and bodyTypeScaleObj:IsA("NumberValue") then
                profile.bodyTypeScale = tonumber(string.format("%.3f", bodyTypeScaleObj.Value))
            end
            if headScaleObj and headScaleObj:IsA("NumberValue") then
                profile.headScale = tonumber(string.format("%.3f", headScaleObj.Value))
            end
        end
        if rootPart then
            profile.rootPartSize = {
                x = tonumber(string.format("%.3f", rootPart.Size.X)),
                y = tonumber(string.format("%.3f", rootPart.Size.Y)),
                z = tonumber(string.format("%.3f", rootPart.Size.Z)),
            }
        end
        local rootSizeY = (rootPart and rootPart.Size and rootPart.Size.Y) or 0
        local hipHeight = (humanoid and humanoid.HipHeight) or 0
        profile.rootToFeetHeight = tonumber(string.format("%.3f", (rootSizeY * 0.5) + hipHeight))
        return profile
    end

    local function recordMovementSample(targetPlayer)
        local character = targetPlayer and targetPlayer.Character
        local humanoid, rootPart = getCharacterHumanoidAndRoot(character)
        if not humanoid or not rootPart then
            return
        end
        local moveDir = humanoid.MoveDirection
        local pos = rootPart.Position
        local vel = rootPart.AssemblyLinearVelocity
        local look = rootPart.CFrame.LookVector
        local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
        local signature = string.format(
            "%.2f|%.2f|%.2f|%.3f|%.3f|%.3f|%.3f|%.3f|%.3f|%.2f|%.2f|%.2f|%s",
            moveDir.X, moveDir.Y, moveDir.Z,
            pos.X, pos.Y, pos.Z,
            vel.X, vel.Y, vel.Z,
            look.X, look.Y, look.Z,
            grounded and "1" or "0"
        )
        if signature == lastMovementSignature then
            return
        end
        lastMovementSignature = signature
        appendRecordingEvent("movement", {
            moveDirection = {
                x = tonumber(string.format("%.3f", moveDir.X)),
                y = tonumber(string.format("%.3f", moveDir.Y)),
                z = tonumber(string.format("%.3f", moveDir.Z)),
            },
            position = {
                x = tonumber(string.format("%.3f", pos.X)),
                y = tonumber(string.format("%.3f", pos.Y)),
                z = tonumber(string.format("%.3f", pos.Z)),
            },
            velocity = {
                x = tonumber(string.format("%.3f", vel.X)),
                y = tonumber(string.format("%.3f", vel.Y)),
                z = tonumber(string.format("%.3f", vel.Z)),
            },
            lookDirection = {
                x = tonumber(string.format("%.3f", look.X)),
                y = tonumber(string.format("%.3f", look.Y)),
                z = tonumber(string.format("%.3f", look.Z)),
            },
            isGrounded = grounded,
            walkSpeed = tonumber(string.format("%.3f", humanoid.WalkSpeed)),
            jumpPower = tonumber(string.format("%.3f", humanoid.JumpPower)),
            jumpHeight = tonumber(string.format("%.3f", humanoid.JumpHeight)),
        })
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

        ensureRecordingsDirectory()
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
            refreshSelectionFromDropdownValue(value, savedDisplayToPath)
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
                local function extractRecordedAvatarProfile(payloadTable, eventsTable)
                    if type(payloadTable) == "table" and type(payloadTable.meta) == "table" and type(payloadTable.meta.avatarProfile) == "table" then
                        return payloadTable.meta.avatarProfile
                    end
                    if type(eventsTable) == "table" then
                        for _, ev in ipairs(eventsTable) do
                            if type(ev) == "table" and ev.kind == "recording_started" and type(ev.data) == "table" and type(ev.data.avatarProfile) == "table" then
                                return ev.data.avatarProfile
                            end
                        end
                    end
                    return nil
                end

                local function buildPlaybackAvatarAdjustment(recordedAvatarProfile, localCharacter)
                    if type(recordedAvatarProfile) ~= "table" then
                        return {
                            yOffset = 0,
                            detail = "No avatar profile in recording",
                        }
                    end
                    local currentAvatarProfile = captureAvatarProfileForCharacter(localCharacter)
                    local recordedRootToFeet = tonumber(recordedAvatarProfile.rootToFeetHeight)
                    local currentRootToFeet = tonumber(currentAvatarProfile.rootToFeetHeight)
                    if not (recordedRootToFeet and currentRootToFeet) then
                        return {
                            yOffset = 0,
                            detail = "Avatar profile missing root height",
                        }
                    end
                    local yOffset = currentRootToFeet - recordedRootToFeet
                    return {
                        yOffset = yOffset,
                        detail = string.format(
                            "Avatar-adjusted Y %.2f (recorded %.2f -> current %.2f)",
                            yOffset,
                            recordedRootToFeet,
                            currentRootToFeet
                        ),
                    }
                end

                local recordedAvatarProfile = extractRecordedAvatarProfile(payload, events)
                local localCharacter = Players.LocalPlayer and Players.LocalPlayer.Character
                local playbackAvatarAdjust = buildPlaybackAvatarAdjustment(recordedAvatarProfile, localCharacter)
                if playbackAvatarAdjust and playbackAvatarAdjust.detail then
                    updateSavedRecordingStatus("Playing: " .. selectedName .. "\n" .. playbackAvatarAdjust.detail)
                end

                local function buildMovementTargetCFrame(rootPart, dataTable)
                    local pos = dataTable.position
                    if not rootPart or type(pos) ~= "table" then
                        return nil
                    end
                    local x = tonumber(pos.x)
                    local y = tonumber(pos.y)
                    local z = tonumber(pos.z)
                    if not (x and y and z) then
                        return nil
                    end

                    local basePos = Vector3.new(x, y, z)
                    if type(playbackAvatarAdjust) == "table" and type(playbackAvatarAdjust.yOffset) == "number" then
                        basePos = basePos + Vector3.new(0, playbackAvatarAdjust.yOffset, 0)
                    end
                    local lookData = dataTable.lookDirection
                    local lx, ly, lz = nil, nil, nil
                    if type(lookData) == "table" then
                        lx = tonumber(lookData.x)
                        ly = tonumber(lookData.y)
                        lz = tonumber(lookData.z)
                    end
                    if lx and ly and lz then
                        local lookVec = Vector3.new(lx, ly, lz)
                        if lookVec.Magnitude > 1e-4 then
                            local planar = Vector3.new(lookVec.X, 0, lookVec.Z)
                            if planar.Magnitude > 1e-4 then
                                return CFrame.lookAt(basePos, basePos + planar.Unit)
                            end
                        end
                    end

                    local fallback = rootPart.CFrame.LookVector
                    local fallbackPlanar = Vector3.new(fallback.X, 0, fallback.Z)
                    if fallbackPlanar.Magnitude > 1e-4 then
                        return CFrame.lookAt(basePos, basePos + fallbackPlanar.Unit)
                    end
                    return CFrame.new(basePos)
                end

                local function findMovementSegmentIndex(track, elapsed)
                    if #track == 0 then
                        return nil
                    end
                    local idx = 1
                    while idx < #track do
                        local nextT = tonumber(track[idx + 1].t) or 0
                        if nextT > elapsed then
                            break
                        end
                        idx = idx + 1
                    end
                    return idx
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

                        local segIdx = findMovementSegmentIndex(movementTrack, elapsed)
                        if not segIdx then
                            return
                        end

                        local evA = movementTrack[segIdx]
                        local evB = movementTrack[math.min(segIdx + 1, #movementTrack)]
                        local tA = tonumber(evA.t) or 0
                        local tB = tonumber(evB.t) or tA
                        local dataA = type(evA.data) == "table" and evA.data or {}
                        local dataB = type(evB.data) == "table" and evB.data or {}
                        local cfA = buildMovementTargetCFrame(rootPart, dataA)
                        local cfB = buildMovementTargetCFrame(rootPart, dataB)
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
