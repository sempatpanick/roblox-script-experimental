--[[
  Local Player tab module for Rayfield scripts.
  Loaded from: https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/tabs/rayfield/local_player_tab.lua

  Usage:
    createLocalPlayerTab(Window, mountNotify, options)

  options (optional table):
    centerShiftLockCamera = true
    shiftLockRenderStepId = "MountYahayukCenterShiftLockCamera"
    persistNoClip = true
    flagsPrefix = "lp"  -- Rayfield/Sempat ConfigurationSaving flags -> lp_<suffix>
    tabIcon = "user"  -- optional; Lucide name or rbx asset id (Sempat UI)
    autoSellTripAssist = {}  -- mancing_indo: table receives .begin function

  Flag suffixes (when flagsPrefix is set):
    antiAfk, infiniteJump, noClip, fly, freeCamera, cameraPenetrate, centerShiftLock,
    walkSpeed, jumpHeight, espMaxDistance, espPlayerNames, espPlayerDistance,
    espPlayerCharacter, espPlayerLines, espAllObjects, playersInfoPlayer, carryPlayer,
    carryNearby, rejoinMessage, animationSelection, screenOrientation
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local MarketplaceService = game:GetService("MarketplaceService")

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

local dropdownMod = loadFunctionModule("rayfield/dropdown")
local formatMod = loadFunctionModule("instance/format")
local playerMod = loadFunctionModule("player/character")
local inspectMod = loadFunctionModule("player/inspect")
local serverMod = loadFunctionModule("server/info")
local teleportFlagsMod = loadFunctionModule("teleport/flags")

local rayfieldDropdownFirst = dropdownMod.rayfieldDropdownFirst
local formatValueForDisplay = formatMod.formatValueForDisplay
local formatGuiInstanceTextForDisplay = formatMod.formatGuiInstanceTextForDisplay
local formatInstanceDisplay = formatMod.formatInstanceDisplay

local function createLocalPlayerTab(windowRef, notifyFn, options)
    options = options or {}
    local mountNotify = notifyFn

    local function withUiFlag(props, suffix)
        local flag = teleportFlagsMod.resolveUiFlagPrefix(options, suffix)
        if flag then
            props.Flag = flag
        end
        return props
    end

    local tabIcon = options.tabIcon or 4483362458
    local LocalPlayerTab = windowRef:CreateTab("Local Player", tabIcon)

    LocalPlayerTab:CreateSection("Misc")
    local infiniteJumpConnection = nil
    local antiAfkConnection = nil
    local noClipEnabled = false
    local noClipConnection = nil
    local cameraPenetrateEnabled = false
    local defaultCameraOcclusionMode = Players.LocalPlayer.DevCameraOcclusionMode
    local flyEnabled = false
    local flySpeed = 50
    local flyBV, flyBG = nil, nil
    local flyConnection = nil
    local flyKeys = {}
    local freeCameraEnabled = false
    local freeCameraConnection = nil
    local freeCameraDragBeganConn = nil
    local freeCameraDragEndedConn = nil
    local freeCameraDragging = false
    local freeCameraSpeed = 50
    local freeCameraSensitivity = 0.5
    local freeCameraCf = nil
    local centerShiftLockCameraEnabled = false
    local CENTER_SHIFTLOCK_RENDERSTEP_ID = options.shiftLockRenderStepId or "SempatPanickCenterShiftLockCamera"

    local SCREEN_ORIENTATION_OPTIONS = {
        "Sensor",
        "Portrait",
        "Landscape Left",
        "Landscape Right",
        "Landscape Sensor",
    }
    local SCREEN_ORIENTATION_BY_NAME = {
        ["Sensor"] = Enum.ScreenOrientation.Sensor,
        ["Portrait"] = Enum.ScreenOrientation.Portrait,
        ["Landscape Left"] = Enum.ScreenOrientation.LandscapeLeft,
        ["Landscape Right"] = Enum.ScreenOrientation.LandscapeRight,
        ["Landscape Sensor"] = Enum.ScreenOrientation.LandscapeSensor,
    }
    local SCREEN_ORIENTATION_NAME_BY_VALUE = {
        [Enum.ScreenOrientation.Sensor] = "Sensor",
        [Enum.ScreenOrientation.Portrait] = "Portrait",
        [Enum.ScreenOrientation.LandscapeLeft] = "Landscape Left",
        [Enum.ScreenOrientation.LandscapeRight] = "Landscape Right",
        [Enum.ScreenOrientation.LandscapeSensor] = "Landscape Sensor",
    }

    local function getCurrentScreenOrientationName()
        local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if playerGui then
            return SCREEN_ORIENTATION_NAME_BY_VALUE[playerGui.ScreenOrientation] or "Sensor"
        end
        return "Sensor"
    end

    local function applyScreenOrientation(optionName)
        local orientation = SCREEN_ORIENTATION_BY_NAME[optionName]
        if not orientation then
            return false
        end

        local playerGui = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then
            return false
        end

        local ok = pcall(function()
            playerGui.ScreenOrientation = orientation
        end)
        return ok
    end

    local function stopCenterShiftLockCamera()
        RunService:UnbindFromRenderStep(CENTER_SHIFTLOCK_RENDERSTEP_ID)
    end

    local function startCenterShiftLockCamera()
        stopCenterShiftLockCamera()
        RunService:BindToRenderStep(CENTER_SHIFTLOCK_RENDERSTEP_ID, Enum.RenderPriority.Camera.Value + 1, function()
            if not centerShiftLockCameraEnabled then
                return
            end

            if UserInputService.MouseBehavior ~= Enum.MouseBehavior.LockCenter then
                return
            end

            local cam = Workspace.CurrentCamera
            if not cam or cam.CameraType ~= Enum.CameraType.Custom then
                return
            end

            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                return
            end

            local focusHeight = 1.5
            local desiredFocus = rootPart.Position + Vector3.new(0, focusHeight, 0)
            local distance = (cam.CFrame.Position - cam.Focus.Position).Magnitude

            if distance <= 0.05 then
                return
            end

            local lookVector = cam.CFrame.LookVector
            local desiredPosition = desiredFocus - lookVector * distance
            cam.CFrame = CFrame.lookAt(desiredPosition, desiredFocus)
        end)
    end

    local function stopFly()
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
        local character = Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
    end

    local function startFly()
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not rootPart or not humanoid then return end
        stopFly()
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.Parent = rootPart
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.P = 9e4
        flyBG.D = 500
        flyBG.Parent = rootPart
        humanoid.PlatformStand = true
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not rootPart or not rootPart.Parent then
                stopFly()
                return
            end
            local cam = Workspace.CurrentCamera
            if not cam then return end
            local look = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            local move = Vector3.new(0, 0, 0)
            if flyKeys[Enum.KeyCode.W] then move = move + look end
            if flyKeys[Enum.KeyCode.S] then move = move - look end
            if flyKeys[Enum.KeyCode.D] then move = move + right end
            if flyKeys[Enum.KeyCode.A] then move = move - right end
            if flyKeys[Enum.KeyCode.Space] then move = move + Vector3.new(0, 1, 0) end
            if flyKeys[Enum.KeyCode.LeftControl] or flyKeys[Enum.KeyCode.RightControl] then move = move - Vector3.new(0, 1, 0) end
            if move.Magnitude > 0 then
                move = move.Unit * flySpeed
            end
            flyBV.Velocity = move
            flyBG.CFrame = cam.CFrame
        end)
    end

    local function applyNoClip(character, enabled)
        if not character then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
    end

    local function setNoClipActive(enabled)
        noClipEnabled = enabled
        if noClipConnection then
            noClipConnection:Disconnect()
            noClipConnection = nil
        end
        local character = Players.LocalPlayer.Character
        applyNoClip(character, enabled)
        if enabled then
            noClipConnection = RunService.Stepped:Connect(function()
                if not noClipEnabled then
                    return
                end
                local ch = Players.LocalPlayer.Character
                if ch then
                    applyNoClip(ch, true)
                end
            end)
        end
    end

    local function startAntiAfk()
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
        local localPlayer = Players.LocalPlayer
        antiAfkConnection = localPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end

    local function stopAntiAfk()
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
    end

    startAntiAfk()

    LocalPlayerTab:CreateToggle(withUiFlag({
        Name = "Anti AFK",
        CurrentValue = true,
        Callback = function(enabled)
            if enabled then
                startAntiAfk()
            else
                stopAntiAfk()
            end
        end
    }, "antiAfk"))

    LocalPlayerTab:CreateToggle(withUiFlag({
        Name = "Infinite Jump",
        Callback = function(enabled)
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
            if enabled then
                infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                    local character = Players.LocalPlayer.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end)
            end
        end
    }, "infiniteJump"))

    LocalPlayerTab:CreateToggle(withUiFlag({
        Name = "No Clip",
        Callback = function(enabled)
            if options.persistNoClip then
                setNoClipActive(enabled)
            else
                noClipEnabled = enabled
                local character = Players.LocalPlayer.Character
                applyNoClip(character, enabled)
            end
        end
    }, "noClip"))

    do
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
                flyKeys[input.KeyCode] = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
                flyKeys[input.KeyCode] = false
            end
        end)
    end

    LocalPlayerTab:CreateToggle(withUiFlag({
        Name = "Fly",
        Callback = function(enabled)
            flyEnabled = enabled
            if enabled then
                startFly()
            else
                stopFly()
            end
        end
    }, "fly"))

    local savedMouseBehavior = nil
    local savedMouseIconEnabled = nil

    local function stopFreeCamera()
        if freeCameraConnection then
            freeCameraConnection:Disconnect()
            freeCameraConnection = nil
        end
        if freeCameraDragBeganConn then
            freeCameraDragBeganConn:Disconnect()
            freeCameraDragBeganConn = nil
        end
        if freeCameraDragEndedConn then
            freeCameraDragEndedConn:Disconnect()
            freeCameraDragEndedConn = nil
        end
        freeCameraDragging = false
        if savedMouseBehavior ~= nil then
            UserInputService.MouseBehavior = savedMouseBehavior
            savedMouseBehavior = nil
        end
        if savedMouseIconEnabled ~= nil then
            UserInputService.MouseIconEnabled = savedMouseIconEnabled
            savedMouseIconEnabled = nil
        end
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then rootPart.Anchored = false end
        local cam = Workspace.CurrentCamera
        if cam then
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = character and character:FindFirstChildOfClass("Humanoid")
        end
    end

    local function startFreeCamera()
        stopFreeCamera()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then rootPart.Anchored = true end
        savedMouseBehavior = UserInputService.MouseBehavior
        savedMouseIconEnabled = UserInputService.MouseIconEnabled
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        freeCameraCf = cam.CFrame
        cam.CameraType = Enum.CameraType.Scriptable
        freeCameraDragBeganConn = UserInputService.InputBegan:Connect(function(input)
            if freeCameraEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2) then
                freeCameraDragging = true
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                UserInputService.MouseIconEnabled = false
            end
        end)
        freeCameraDragEndedConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                freeCameraDragging = false
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                UserInputService.MouseIconEnabled = true
            end
        end)
        freeCameraConnection = RunService.RenderStepped:Connect(function()
            if not freeCameraEnabled or not freeCameraCf then
                stopFreeCamera()
                return
            end
            if freeCameraDragging then
                local delta = UserInputService:GetMouseDelta()
                local pos = freeCameraCf.Position
                local look = freeCameraCf.LookVector
                local right = freeCameraCf.RightVector
                -- Yaw: rotate around world Y so horizontal mouse is level
                local yaw = math.rad(delta.X * freeCameraSensitivity)
                local cy, sy = math.cos(yaw), math.sin(yaw)
                look = Vector3.new(look.X * cy - look.Z * sy, look.Y, look.X * sy + look.Z * cy).Unit
                right = Vector3.new(right.X * cy - right.Z * sy, right.Y, right.X * sy + right.Z * cy).Unit
                -- Pitch: rotate look around right so vertical mouse is straight up/down
                local up = right:Cross(look).Unit
                local pitch = math.rad(-delta.Y * freeCameraSensitivity)
                look = (look * math.cos(pitch) + up * math.sin(pitch)).Unit
                freeCameraCf = CFrame.fromMatrix(pos, right, right:Cross(look))
            end
            local look = freeCameraCf.LookVector
            local right = freeCameraCf.RightVector
            local move = Vector3.new(0, 0, 0)
            if flyKeys[Enum.KeyCode.W] then move = move + look end
            if flyKeys[Enum.KeyCode.S] then move = move - look end
            if flyKeys[Enum.KeyCode.D] then move = move + right end
            if flyKeys[Enum.KeyCode.A] then move = move - right end
            if flyKeys[Enum.KeyCode.Space] then move = move + Vector3.new(0, 1, 0) end
            if flyKeys[Enum.KeyCode.LeftControl] or flyKeys[Enum.KeyCode.RightControl] then move = move - Vector3.new(0, 1, 0) end
            if move.Magnitude > 0 then
                move = move.Unit * freeCameraSpeed * 0.016
            end
            freeCameraCf = freeCameraCf + move
            cam.CFrame = freeCameraCf
        end)
    end

    LocalPlayerTab:CreateToggle(withUiFlag({
        Name = "Free Camera",
        Callback = function(enabled)
            freeCameraEnabled = enabled
            if enabled then
                startFreeCamera()
            else
                stopFreeCamera()
            end
        end
    }, "freeCamera"))

    LocalPlayerTab:CreateToggle(withUiFlag({
        Name = "Camera Penetrate",
        Callback = function(enabled)
            cameraPenetrateEnabled = enabled
            local lp = Players.LocalPlayer
            if cameraPenetrateEnabled then
                lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
            else
                lp.DevCameraOcclusionMode = defaultCameraOcclusionMode
            end
        end
    }, "cameraPenetrate"))

    if options.centerShiftLockCamera then
        LocalPlayerTab:CreateToggle(withUiFlag({
            Name = "Centering Shift Lock Camera",
            CurrentValue = false,
            Callback = function(enabled)
                centerShiftLockCameraEnabled = enabled
                if enabled then
                    startCenterShiftLockCamera()
                else
                    stopCenterShiftLockCamera()
                end
            end
        }, "centerShiftLock"))
    end

    do
        Players.LocalPlayer.CharacterAdded:Connect(function(character)
            if flyEnabled then
                task.defer(function() startFly() end)
            end
            if noClipEnabled then
                applyNoClip(character, true)
                if not options.persistNoClip then
                    character.DescendantAdded:Connect(function(part)
                        if noClipEnabled and part:IsA("BasePart") then
                            part.CanCollide = false
                        end
                    end)
                end
            end
            if centerShiftLockCameraEnabled then
                task.defer(function()
                    startCenterShiftLockCamera()
                end)
            end
        end)
        if noClipEnabled and Players.LocalPlayer.Character then
            applyNoClip(Players.LocalPlayer.Character, true)
        end
    end

    LocalPlayerTab:CreateDropdown(withUiFlag({
        Name = "Screen orientation",
        Options = SCREEN_ORIENTATION_OPTIONS,
        CurrentOption = { getCurrentScreenOrientationName() },
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            if not picked then
                return
            end
            if not applyScreenOrientation(picked) then
                mountNotify({
                    Title = "Screen orientation",
                    Content = "Could not change orientation (mobile only)",
                    Icon = "x",
                })
            end
        end,
    }, "screenOrientation"))

    LocalPlayerTab:CreateSection("Walk Speed")
    local defaultWalkSpeed = 16

    local function getCurrentCharacterWalkSpeed()
        return playerMod.getCurrentCharacterWalkSpeed(Players, defaultWalkSpeed)
    end

    local walkSpeedValue = tostring(getCurrentCharacterWalkSpeed())

    local WalkSpeedInput = LocalPlayerTab:CreateInput(withUiFlag({
        Name = "Speed",
        PlaceholderText = "e.g. 16 or 100",
        CurrentValue = walkSpeedValue,
        Callback = function(value)
            walkSpeedValue = value
        end
    }, "walkSpeed"))

    local function syncWalkSpeedInputFromCharacter(showNotify)
        local character = Players.LocalPlayer.Character
        if not character then
            if showNotify then
                mountNotify({ Title = "Walk Speed", Content = "Character not loaded" })
            end
            return false
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            if showNotify then
                mountNotify({ Title = "Walk Speed", Content = "Humanoid not found" })
            end
            return false
        end

        local speedText = tostring(getCurrentCharacterWalkSpeed())
        walkSpeedValue = speedText
        if WalkSpeedInput and WalkSpeedInput.Set then
            WalkSpeedInput:Set(speedText)
        elseif WalkSpeedInput and WalkSpeedInput.SetValue then
            WalkSpeedInput:SetValue(speedText)
        end

        if showNotify then
            mountNotify({ Title = "Walk Speed", Content = "Current speed: " .. speedText })
        end
        return true
    end
    LocalPlayerTab:CreateButton({
        Name = "Get Current Walk Speed",
        Callback = function()
            syncWalkSpeedInputFromCharacter(true)
        end
    })

    -- Keep the input defaulted to current character speed when available.
    syncWalkSpeedInputFromCharacter(false)
    LocalPlayerTab:CreateButton({
        Name = "Apply",
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                mountNotify({ Title = "Walk Speed", Content = "Character not loaded" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                mountNotify({ Title = "Walk Speed", Content = "Humanoid not found" })
                return
            end
            local speed = tonumber(walkSpeedValue) or defaultWalkSpeed
            humanoid.WalkSpeed = math.max(0, speed)
            mountNotify({ Title = "Walk Speed", Content = "Set to " .. tostring(humanoid.WalkSpeed) })
        end
    })
    LocalPlayerTab:CreateButton({
        Name = "Reset",
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                mountNotify({ Title = "Walk Speed", Content = "Character not loaded" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                mountNotify({ Title = "Walk Speed", Content = "Humanoid not found" })
                return
            end
            humanoid.WalkSpeed = defaultWalkSpeed
            walkSpeedValue = tostring(defaultWalkSpeed)
            mountNotify({ Title = "Walk Speed", Content = "Reset to " .. tostring(defaultWalkSpeed) })
        end
    })
    LocalPlayerTab:CreateSection("Jump Height")
    local defaultJumpHeight = 7.2

    local function getCurrentCharacterJumpHeight()
        return playerMod.getCurrentCharacterJumpHeight(Players, defaultJumpHeight)
    end

    local jumpHeightValue = tostring(getCurrentCharacterJumpHeight())

    local JumpHeightInput = LocalPlayerTab:CreateInput(withUiFlag({
        Name = "Height",
        PlaceholderText = "e.g. 7.2 or 50",
        CurrentValue = jumpHeightValue,
        Callback = function(value)
            jumpHeightValue = value
        end
    }, "jumpHeight"))

    local function syncJumpHeightInputFromCharacter(showNotify)
        local character = Players.LocalPlayer.Character
        if not character then
            if showNotify then
                mountNotify({ Title = "Jump Height", Content = "Character not loaded" })
            end
            return false
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            if showNotify then
                mountNotify({ Title = "Jump Height", Content = "Humanoid not found" })
            end
            return false
        end

        local jumpHeightText = tostring(getCurrentCharacterJumpHeight())
        jumpHeightValue = jumpHeightText
        if JumpHeightInput and JumpHeightInput.Set then
            JumpHeightInput:Set(jumpHeightText)
        elseif JumpHeightInput and JumpHeightInput.SetValue then
            JumpHeightInput:SetValue(jumpHeightText)
        end

        if showNotify then
            mountNotify({ Title = "Jump Height", Content = "Current jump height: " .. jumpHeightText })
        end
        return true
    end
    LocalPlayerTab:CreateButton({
        Name = "Get Current Jump Height",
        Callback = function()
            syncJumpHeightInputFromCharacter(true)
        end
    })

    -- Keep the input defaulted to current character jump height when available.
    syncJumpHeightInputFromCharacter(false)
    LocalPlayerTab:CreateButton({
        Name = "Apply",
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                mountNotify({ Title = "Jump Height", Content = "Character not loaded" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                mountNotify({ Title = "Jump Height", Content = "Humanoid not found" })
                return
            end
            local jumpHeight = tonumber(jumpHeightValue) or defaultJumpHeight
            humanoid.JumpHeight = math.max(0, jumpHeight)
            mountNotify({ Title = "Jump Height", Content = "Set to " .. tostring(humanoid.JumpHeight) })
        end
    })
    LocalPlayerTab:CreateSection("ESP")
    local espNamesEnabled = false
    local espDistanceEnabled = false
    local espCharacterEnabled = false
    local espLinesEnabled = false
    local espAllObjectsEnabled = false
    local espMaxDistance = 10000
    local espPlayerState: { [Player]: { highlight: Highlight?, nameGui: BillboardGui?, lineBeam: Beam?, lineFrom: Attachment?, lineTo: Attachment? } } = {}
    local espObjectState: { [Instance]: BillboardGui } = {}
    local espPlayerAddedConn: RBXScriptConnection? = nil
    local espPlayerRemovingConn: RBXScriptConnection? = nil
    local espLocalCharacterConn: RBXScriptConnection? = nil
    local espRenderStepConn: RBXScriptConnection? = nil

    local function espGetPlayerRoot(player: Player): BasePart?
        local character = player.Character
        if not character then return nil end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then return root end
        return nil
    end

    local function espGetState(player: Player)
        local state = espPlayerState[player]
        if not state then state = {} espPlayerState[player] = state end
        return state
    end

    local function espClearVisualsForPlayer(player: Player)
        local state = espPlayerState[player]
        if not state then return end
        if state.highlight then state.highlight:Destroy() state.highlight = nil end
        if state.nameGui then state.nameGui:Destroy() state.nameGui = nil end
        if state.lineBeam then state.lineBeam:Destroy() state.lineBeam = nil end
        if state.lineFrom then state.lineFrom:Destroy() state.lineFrom = nil end
        if state.lineTo then state.lineTo:Destroy() state.lineTo = nil end
    end

    local function espApplyForPlayer(player: Player)
        if player == Players.LocalPlayer then return end
        local character = player.Character
        local root = espGetPlayerRoot(player)
        if not character or not root then
            espClearVisualsForPlayer(player)
            return
        end
        local state = espGetState(player)
        local localRoot = espGetPlayerRoot(Players.LocalPlayer)
        local distToLocal: number? = nil
        if localRoot then distToLocal = (localRoot.Position - root.Position).Magnitude end
        local withinMaxDistance = (espMaxDistance <= 0) or (distToLocal ~= nil and distToLocal <= espMaxDistance)

        if espCharacterEnabled and withinMaxDistance then
            if not state.highlight then
                local h = Instance.new("Highlight")
                h.Name = "SempatPanickESPHighlight"
                h.FillColor = Color3.fromRGB(16, 197, 80)
                h.FillTransparency = 0.7
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.OutlineTransparency = 0
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = character
                state.highlight = h
            end
            state.highlight.Adornee = character
            state.highlight.Enabled = true
        elseif state.highlight then
            state.highlight:Destroy()
            state.highlight = nil
        end

        if (espNamesEnabled or espDistanceEnabled) and withinMaxDistance then
            if not state.nameGui then
                local nameGui = Instance.new("BillboardGui")
                nameGui.Name = "SempatPanickESPName"
                nameGui.Size = UDim2.fromOffset(220, 44)
                nameGui.StudsOffset = Vector3.new(0, 3.5, 0)
                nameGui.AlwaysOnTop = true
                nameGui.MaxDistance = espMaxDistance
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.BackgroundTransparency = 1
                label.Size = UDim2.fromScale(1, 1)
                label.Font = Enum.Font.GothamBold
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextStrokeTransparency = 0
                label.TextScaled = true
                label.TextWrapped = true
                label.Parent = nameGui
                state.nameGui = nameGui
            end
            state.nameGui.MaxDistance = espMaxDistance
            local label = state.nameGui:FindFirstChild("Label")
            if label and label:IsA("TextLabel") then
                local baseName = player.DisplayName and player.DisplayName ~= "" and player.DisplayName or player.Name
                if espDistanceEnabled and distToLocal then
                    label.Text = string.format("%s\n[%.0fm]", baseName, distToLocal)
                else
                    label.Text = baseName
                end
            end
            state.nameGui.Adornee = root
            state.nameGui.Parent = root
            state.nameGui.Enabled = true
        elseif state.nameGui then
            state.nameGui:Destroy()
            state.nameGui = nil
        end

        if espLinesEnabled then
            if localRoot then
                if not state.lineFrom then
                    local a0 = Instance.new("Attachment")
                    a0.Name = "SempatPanickESPFrom"
                    a0.Parent = localRoot
                    state.lineFrom = a0
                elseif state.lineFrom.Parent ~= localRoot then
                    state.lineFrom.Parent = localRoot
                end
                if not state.lineTo then
                    local a1 = Instance.new("Attachment")
                    a1.Name = "SempatPanickESPTo"
                    a1.Parent = root
                    state.lineTo = a1
                elseif state.lineTo.Parent ~= root then
                    state.lineTo.Parent = root
                end
                if not state.lineBeam then
                    local beam = Instance.new("Beam")
                    beam.Name = "SempatPanickESPLine"
                    beam.FaceCamera = true
                    beam.Width0 = 0.06
                    beam.Width1 = 0.06
                    beam.Color = ColorSequence.new(Color3.fromRGB(16, 197, 80))
                    beam.Transparency = NumberSequence.new(0.2)
                    beam.LightEmission = 1
                    beam.Parent = Workspace.Terrain
                    state.lineBeam = beam
                end
                if withinMaxDistance then
                    state.lineBeam.Attachment0 = state.lineFrom
                    state.lineBeam.Attachment1 = state.lineTo
                    state.lineBeam.Enabled = true
                else
                    state.lineBeam.Enabled = false
                end
            elseif state.lineBeam then
                state.lineBeam.Enabled = false
            end
        else
            if state.lineBeam then state.lineBeam:Destroy() state.lineBeam = nil end
            if state.lineFrom then state.lineFrom:Destroy() state.lineFrom = nil end
            if state.lineTo then state.lineTo:Destroy() state.lineTo = nil end
        end
    end

    local function espApplyForAllPlayers()
        for _, p in ipairs(Players:GetPlayers()) do espApplyForPlayer(p) end
    end

    local function espObjectDebugId(inst: Instance): string
        local ok, id = pcall(function()
            return inst:GetDebugId(0)
        end)
        if ok and type(id) == "string" and id ~= "" then
            return id
        end
        return tostring(inst)
    end

    local function espObjectIsPlayerCharacterDescendant(inst: Instance): boolean
        local current = inst
        while current and current ~= Workspace do
            if current:IsA("Model") then
                local plr = Players:GetPlayerFromCharacter(current)
                if plr then
                    return true
                end
            end
            current = current.Parent
        end
        return false
    end

    local function espObjectGetAdornee(inst: Instance): BasePart?
        if inst:IsA("BasePart") then
            return inst
        end
        if inst:IsA("Model") then
            local root = inst.PrimaryPart
            if root then
                return root
            end
            return inst:FindFirstChildWhichIsA("BasePart", true)
        end
        return nil
    end

    local function espClearVisualForObject(inst: Instance)
        local gui = espObjectState[inst]
        if gui then
            gui:Destroy()
            espObjectState[inst] = nil
        end
    end

    local function espApplyForObject(inst: Instance)
        if not espAllObjectsEnabled then
            espClearVisualForObject(inst)
            return
        end
        if not inst.Parent then
            espClearVisualForObject(inst)
            return
        end
        if not (inst:IsA("BasePart") or inst:IsA("Model")) then
            espClearVisualForObject(inst)
            return
        end
        if espObjectIsPlayerCharacterDescendant(inst) then
            espClearVisualForObject(inst)
            return
        end

        local adornee = espObjectGetAdornee(inst)
        if not adornee then
            espClearVisualForObject(inst)
            return
        end

        local gui = espObjectState[inst]
        if not gui then
            gui = Instance.new("BillboardGui")
            gui.Name = "SempatPanickESPObject"
            gui.Size = UDim2.fromOffset(320, 58)
            gui.StudsOffset = Vector3.new(0, 3, 0)
            gui.AlwaysOnTop = true
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.BackgroundTransparency = 1
            label.Size = UDim2.fromScale(1, 1)
            label.Font = Enum.Font.GothamBold
            label.TextColor3 = Color3.fromRGB(255, 230, 120)
            label.TextStrokeTransparency = 0
            label.TextScaled = true
            label.TextWrapped = true
            label.Parent = gui
            espObjectState[inst] = gui
        end

        gui.Adornee = adornee
        gui.MaxDistance = espMaxDistance
        gui.Parent = adornee
        gui.Enabled = true

        local label = gui:FindFirstChild("Label")
        if label and label:IsA("TextLabel") then
            label.Text = string.format("%s\n%s", espObjectDebugId(inst), inst.Name)
        end
    end

    local function espApplyForAllObjects()
        for _, inst in ipairs(Workspace:GetDescendants()) do
            if inst:IsA("BasePart") or inst:IsA("Model") then
                espApplyForObject(inst)
            end
        end
    end

    local function espClearAllObjects()
        for inst, gui in pairs(espObjectState) do
            if gui then
                gui:Destroy()
            end
            espObjectState[inst] = nil
        end
    end

    local function espAnyEnabled(): boolean
        return espNamesEnabled or espDistanceEnabled or espCharacterEnabled or espLinesEnabled or espAllObjectsEnabled
    end

    LocalPlayerTab:CreateInput(withUiFlag({
        Name = "ESP Max Distance",
        PlaceholderText = "0 = unlimited, e.g. 10000",
        CurrentValue = tostring(espMaxDistance),
        Callback = function(value)
            local n = tonumber(value)
            if not n then return end
            espMaxDistance = math.max(0, n)
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    }, "espMaxDistance"))
    local function espOnRenderStep()
        if not espAnyEnabled() then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Players.LocalPlayer then espApplyForPlayer(p) end
        end
    end

    local function espSetRuntimeEnabled(enabled: boolean)
        if enabled then
            if not espPlayerAddedConn then
                espPlayerAddedConn = Players.PlayerAdded:Connect(function(player)
                    player.CharacterAdded:Connect(function() task.wait(0.15) espApplyForPlayer(player) end)
                    espApplyForPlayer(player)
                end)
            end
            if not espPlayerRemovingConn then
                espPlayerRemovingConn = Players.PlayerRemoving:Connect(function(player)
                    espClearVisualsForPlayer(player)
                    espPlayerState[player] = nil
                end)
            end
            if not espLocalCharacterConn then
                espLocalCharacterConn = Players.LocalPlayer.CharacterAdded:Connect(function()
                    task.wait(0.2)
                    espApplyForAllPlayers()
                end)
            end
            if not espRenderStepConn then
                espRenderStepConn = RunService.RenderStepped:Connect(espOnRenderStep)
            end
            espApplyForAllPlayers()
            if espAllObjectsEnabled then
                espApplyForAllObjects()
            else
                espClearAllObjects()
            end
            return
        end
        if espPlayerAddedConn then espPlayerAddedConn:Disconnect() espPlayerAddedConn = nil end
        if espPlayerRemovingConn then espPlayerRemovingConn:Disconnect() espPlayerRemovingConn = nil end
        if espLocalCharacterConn then espLocalCharacterConn:Disconnect() espLocalCharacterConn = nil end
        if espRenderStepConn then espRenderStepConn:Disconnect() espRenderStepConn = nil end
        for player in pairs(espPlayerState) do espClearVisualsForPlayer(player) espPlayerState[player] = nil end
        espClearAllObjects()
    end

    LocalPlayerTab:CreateToggle(withUiFlag({
        Name = "ESP Player Names",
        CurrentValue = false,
        Callback = function(enabled)
            espNamesEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    }, "espPlayerNames"))
    LocalPlayerTab:CreateToggle(withUiFlag({
        Name = "ESP Player Distance",
        CurrentValue = false,
        Callback = function(enabled)
            espDistanceEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    }, "espPlayerDistance"))
    LocalPlayerTab:CreateToggle(withUiFlag({
        Name = "ESP Player Character",
        CurrentValue = false,
        Callback = function(enabled)
            espCharacterEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    }, "espPlayerCharacter"))
    LocalPlayerTab:CreateToggle(withUiFlag({
        Name = "ESP Player Lines",
        CurrentValue = false,
        Callback = function(enabled)
            espLinesEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    }, "espPlayerLines"))
    LocalPlayerTab:CreateToggle(withUiFlag({
        Name = "ESP All Object",
        CurrentValue = false,
        Callback = function(enabled)
            espAllObjectsEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAllObjectsEnabled then
                espApplyForAllObjects()
            else
                espClearAllObjects()
            end
        end
    }, "espAllObjects"))
    LocalPlayerTab:CreateSection("Players Info")
    local infoPlayerList = {}
    local infoPlayerDisplayNames = {}
    local selectedInfoPlayer = nil
    local PlayersInfoDropdown
    local PlayersInfoParagraph

    local function updatePlayersInfoParagraph()
        if PlayersInfoParagraph and PlayersInfoParagraph.Set then
            PlayersInfoParagraph:Set({
                Title = "Details",
                Content = inspectMod.buildPlayersInfoText(selectedInfoPlayer, formatValueForDisplay),
            })
        end
    end

    local function refreshPlayersInfoList(showNotify)
        infoPlayerList = {}
        infoPlayerDisplayNames = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.ClassName == "Player" then
                table.insert(infoPlayerList, plr)
                table.insert(infoPlayerDisplayNames, playerMod.playerInfoLabel(plr))
            end
        end
        if PlayersInfoDropdown and PlayersInfoDropdown.Refresh then
            PlayersInfoDropdown:Refresh(infoPlayerDisplayNames)
        end
        if selectedInfoPlayer then
            if not table.find(infoPlayerList, selectedInfoPlayer) then
                selectedInfoPlayer = nil
                if PlayersInfoDropdown and PlayersInfoDropdown.Select then PlayersInfoDropdown:Select(nil) end
                if PlayersInfoDropdown and PlayersInfoDropdown.Set then PlayersInfoDropdown:Set({}) end
            end
        end
        updatePlayersInfoParagraph()
        if showNotify then
            mountNotify({ Title = "Players Info", Content = "Player list refreshed (" .. #infoPlayerList .. ")" })
        end
    end

    PlayersInfoDropdown = LocalPlayerTab:CreateDropdown(withUiFlag({
        Name = "Player",
        Options = infoPlayerDisplayNames,
        CurrentOption = {}, Search = true,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            selectedInfoPlayer = nil
            if picked then
                local idx = table.find(infoPlayerDisplayNames, picked)
                if idx and infoPlayerList[idx] then
                    selectedInfoPlayer = infoPlayerList[idx]
                end
            end
            updatePlayersInfoParagraph()
        end,
    }, "playersInfoPlayer"))

    PlayersInfoParagraph = LocalPlayerTab:CreateParagraph({
        Title = "Details",
        Content = "Select a player from the list.",
    })

    LocalPlayerTab:CreateButton({
        Name = "Refresh list",
        Callback = function()
            refreshPlayersInfoList(true)
        end,
    })
    LocalPlayerTab:CreateButton({
        Name = "Refresh details",
        Callback = function()
            if not selectedInfoPlayer then
                mountNotify({ Title = "Players Info", Content = "Select a player first" })
                return
            end
            updatePlayersInfoParagraph()
            mountNotify({ Title = "Players Info", Content = "Details updated" })
        end,
    })

    task.defer(function()
        refreshPlayersInfoList(false)
    end)

    Players.PlayerAdded:Connect(function()
        task.defer(function()
            refreshPlayersInfoList(false)
        end)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(function()
            refreshPlayersInfoList(false)
        end)
    end)

    LocalPlayerTab:CreateSection("Carry")
    local CARRY_NONE = "(None)"
    local carryPlayerNames = {}
    local selectedCarryPlayerName = nil
    local CarryPlayerDropdown
    local carryEnabled = false
    local carryLoopToken = 0
    local CARRY_NEARBY_DISTANCE = 20

    local function carryDropdownOptions()
        local opts = { CARRY_NONE }
        for _, n in ipairs(carryPlayerNames) do
            table.insert(opts, n)
        end
        return opts
    end

    local function refreshCarryPlayers()
        carryPlayerNames = {}
        local localPlayer = Players.LocalPlayer
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.ClassName == "Player" then
                table.insert(carryPlayerNames, player.Name)
            end
        end
        table.sort(carryPlayerNames, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        if CarryPlayerDropdown and CarryPlayerDropdown.Refresh then
            CarryPlayerDropdown:Refresh(carryDropdownOptions())
        end
        if selectedCarryPlayerName and not table.find(carryPlayerNames, selectedCarryPlayerName) then
            selectedCarryPlayerName = nil
            if CarryPlayerDropdown and CarryPlayerDropdown.Set then
                CarryPlayerDropdown:Set({ CARRY_NONE })
            end
        end
    end

    CarryPlayerDropdown = LocalPlayerTab:CreateDropdown(withUiFlag({
        Name = "Player",
        Options = carryDropdownOptions(),
        CurrentOption = { CARRY_NONE },
        Search = true,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            if picked and picked ~= CARRY_NONE then
                selectedCarryPlayerName = picked
            else
                selectedCarryPlayerName = nil
            end
        end,
    }, "carryPlayer"))

    LocalPlayerTab:CreateToggle(withUiFlag({
        Name = "Carry nearby selected player",
        CurrentValue = false,
        Callback = function(enabled)
            carryEnabled = enabled == true
            carryLoopToken = carryLoopToken + 1
            local myToken = carryLoopToken

            if not carryEnabled then
                mountNotify({
                    Title = "Carry",
                    Content = "Carry disabled",
                })
                return
            end

            mountNotify({
                Title = "Carry",
                Content = "Carry enabled",
            })

            task.spawn(function()
                while carryEnabled and myToken == carryLoopToken do
                    if selectedCarryPlayerName and selectedCarryPlayerName ~= "" then
                        local localCharacter = Players.LocalPlayer.Character
                        local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
                        local targetPlayer = Players:FindFirstChild(selectedCarryPlayerName)
                        local targetCharacter = targetPlayer and targetPlayer.Character
                        local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")

                        if localRoot and targetRoot then
                            local dist = (localRoot.Position - targetRoot.Position).Magnitude
                            if dist <= CARRY_NEARBY_DISTANCE then
                                pcall(function()
                                    targetRoot.CFrame = localRoot.CFrame * CFrame.new(1.8, 0, 0)
                                end)
                            end
                        end
                    end
                    task.wait(0.12)
                end
            end)
        end,
    }, "carryNearby"))

    task.defer(refreshCarryPlayers)
    Players.PlayerAdded:Connect(function()
        task.defer(refreshCarryPlayers)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(refreshCarryPlayers)
    end)

    local rejoinTeleporting = false
    local rejoinDisconnectMessage = "Rejoining server..."

    local function beginRejoinViaDisconnect(placeId, jobId, isPrivateServer, accessCode, disconnectMessage)
        local TeleportService = game:GetService("TeleportService")
        local GuiService = game:GetService("GuiService")
        local CoreGui = game:GetService("CoreGui")
        local player = Players.LocalPlayer
        local reconnecting = false
        local conns = {}

        local function cleanupListeners()
            if conns.error then
                conns.error:Disconnect()
                conns.error = nil
            end
            if conns.prompt then
                conns.prompt:Disconnect()
                conns.prompt = nil
            end
        end

        local function reconnect()
            if reconnecting then
                return
            end
            reconnecting = true
            cleanupListeners()

            task.spawn(function()
                task.wait(0.5)
                local ok, err = pcall(function()
                    if isPrivateServer and accessCode then
                        TeleportService:TeleportToPrivateServer(placeId, accessCode, { player })
                    elseif jobId and #jobId > 0 then
                        TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
                    else
                        TeleportService:Teleport(placeId, player)
                    end
                end)
                if not ok then
                    mountNotify({
                        Title = "Rejoin",
                        Content = "Failed: " .. tostring(err),
                    })
                    task.delay(3, function()
                        rejoinTeleporting = false
                    end)
                end
            end)
        end

        conns.error = GuiService.ErrorMessageChanged:Connect(function(message)
            if message and message ~= "" then
                reconnect()
            end
        end)

        local robloxPrompt = CoreGui:FindFirstChild("RobloxPromptGui")
        local overlay = robloxPrompt and robloxPrompt:FindFirstChild("promptOverlay")
        if overlay then
            conns.prompt = overlay.ChildAdded:Connect(function(child)
                if child.Name == "ErrorPrompt" then
                    reconnect()
                end
            end)
        end

        task.delay(15, function()
            if not reconnecting then
                cleanupListeners()
                rejoinTeleporting = false
            end
        end)

        local kickOk, kickErr = pcall(function()
            player:Kick(disconnectMessage or "Rejoining server...")
        end)
        if not kickOk then
            cleanupListeners()
            rejoinTeleporting = false
            mountNotify({
                Title = "Rejoin",
                Content = "Failed to disconnect: " .. tostring(kickErr),
            })
        end
    end

    local placeProductInfoCache = {}
    local ServerInfoParagraph
    local ServerLiveParagraph
    local serverLiveHeartbeatConnection = nil
    local lastServerLivePingMs = nil
    local lastServerLivePlayerCount = nil

    local function getPlaceProductInfo()
        return serverMod.getPlaceProductInfo(MarketplaceService, game.PlaceId, placeProductInfoCache)
    end

    local function buildServerInfoText()
        return serverMod.buildServerInfoText(getPlaceProductInfo(), {
            placeId = game.PlaceId,
            gameId = game.GameId,
            creatorId = game.CreatorId,
            jobId = game.JobId,
            privateServerId = game.PrivateServerId,
            vipServerOwnerId = game.VIPServerOwnerId,
        })
    end

    local function buildServerLiveText()
        return serverMod.buildServerLiveText(Players, Players.LocalPlayer)
    end

    local function updateServerInfoParagraph()
        if ServerInfoParagraph and ServerInfoParagraph.Set then
            ServerInfoParagraph:Set({
                Title = "Game & Server",
                Content = buildServerInfoText(),
            })
        end
    end

    local function updateServerLiveParagraph(force)
        if not (ServerLiveParagraph and ServerLiveParagraph.Set) then
            return
        end

        local playerCount = #Players:GetPlayers()
        local pingMs = nil
        local localPlayer = Players.LocalPlayer
        if localPlayer then
            local okPing, ping = pcall(function()
                return localPlayer:GetNetworkPing()
            end)
            if okPing and ping then
                pingMs = math.floor(ping * 1000 + 0.5)
            end
        end

        if not force and playerCount == lastServerLivePlayerCount and pingMs == lastServerLivePingMs then
            return
        end

        lastServerLivePlayerCount = playerCount
        lastServerLivePingMs = pingMs

        ServerLiveParagraph:Set({
            Title = "Live",
            Content = buildServerLiveText(),
        })
    end

    local function startServerLiveUpdates()
        if serverLiveHeartbeatConnection then
            return
        end

        updateServerLiveParagraph(true)

        serverLiveHeartbeatConnection = RunService.Heartbeat:Connect(function()
            updateServerLiveParagraph(false)
        end)
    end

    LocalPlayerTab:CreateSection("Server")
    ServerInfoParagraph = LocalPlayerTab:CreateParagraph({
        Title = "Game & Server",
        Content = "Loading game and server info…",
    })

    ServerLiveParagraph = LocalPlayerTab:CreateParagraph({
        Title = "Live",
        Content = "Players: …\nPing: …",
    })

    task.spawn(function()
        getPlaceProductInfo()
        updateServerInfoParagraph()
    end)

    startServerLiveUpdates()

    Players.PlayerAdded:Connect(function()
        updateServerLiveParagraph(true)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(function()
            updateServerLiveParagraph(true)
        end)
    end)

    LocalPlayerTab:CreateInput(withUiFlag({
        Name = "Rejoin disconnect message",
        PlaceholderText = "Rejoining server...",
        CurrentValue = rejoinDisconnectMessage,
        Callback = function(value)
            if type(value) == "string" and value ~= "" then
                rejoinDisconnectMessage = value
            end
        end,
    }, "rejoinMessage"))

    LocalPlayerTab:CreateButton({
        Name = "Rejoin server",
        Callback = function()
            if rejoinTeleporting then
                return
            end

            local TeleportService = game:GetService("TeleportService")
            local placeId = game.PlaceId
            local jobId = game.JobId

            local isPrivateServer = game.PrivateServerId ~= "" and game.PrivateServerId ~= nil
            local accessCode = nil
            local teleportData = TeleportService:GetLocalPlayerTeleportData()

            if teleportData and type(teleportData) == "table" then
                accessCode = teleportData.AccessCode
            end

            if not placeId then
                mountNotify({
                    Title = "Rejoin",
                    Content = "Cannot rejoin (missing PlaceId)",
                })
                return
            end

            if not (isPrivateServer and accessCode) and (not jobId or #jobId == 0) then
                mountNotify({
                    Title = "Rejoin",
                    Content = "Cannot rejoin (missing JobId)",
                })
                return
            end

            rejoinTeleporting = true
            beginRejoinViaDisconnect(
                placeId,
                jobId,
                isPrivateServer,
                accessCode,
                rejoinDisconnectMessage
            )
        end,
    })

    LocalPlayerTab:CreateButton({
        Name = "Copy game ID",
        Callback = function()
            local paste = setclipboard or toclipboard
            if not paste then
                mountNotify({
                    Title = "Server",
                    Content = "Clipboard not supported in this environment",
                })
                return
            end
            local id = tostring(game.PlaceId)
            paste(id)
            mountNotify({
                Title = "Server",
                Content = "Copied PlaceId " .. id,
            })
        end,
    })
    local animationOptions = { "Hair Grab (R6)" }
    local selectedAnimationName = animationOptions[1]
    local animationRunning = false
    local function findHairAccessory(character)
        local accessories = {}
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Accessory") then table.insert(accessories, child) end
        end
        for _, accessory in ipairs(accessories) do
            local okType, accType = pcall(function() return accessory.AccessoryType end)
            if okType and accType == Enum.AccessoryType.Hair then
                local handle = accessory:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then return accessory, handle end
            end
        end
        for _, accessory in ipairs(accessories) do
            if string.find(string.lower(accessory.Name), "hair", 1, true) then
                local handle = accessory:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then return accessory, handle end
            end
        end
        return nil, nil
    end
    local function playHairGrabAnimationR6()
        if animationRunning then return end
        animationRunning = true
        local character = Players.LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local torso = character and character:FindFirstChild("Torso")
        local rightArm = character and character:FindFirstChild("Right Arm")
        local head = character and character:FindFirstChild("Head")
        if not character or not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 or not torso or not rightArm or not head then
            animationRunning = false
            mountNotify({ Title = "Animation", Content = "R6 character parts not ready" })
            return
        end
        local rightShoulder = torso:FindFirstChild("Right Shoulder")
        local neck = torso:FindFirstChild("Neck")
        if not (rightShoulder and rightShoulder:IsA("Motor6D") and neck and neck:IsA("Motor6D")) then
            animationRunning = false
            mountNotify({ Title = "Animation", Content = "R6 joints not found" })
            return
        end
        local _, hairHandle = findHairAccessory(character)
        if not hairHandle then
            animationRunning = false
            mountNotify({ Title = "Animation", Content = "No hair accessory found" })
            return
        end
        local originalShoulderC0, originalNeckC0 = rightShoulder.C0, neck.C0
        local originalHairCFrame = hairHandle.CFrame
        local originalWeld = hairHandle:FindFirstChild("AccessoryWeld")
        if not (originalWeld and originalWeld:IsA("JointInstance")) then originalWeld = hairHandle:FindFirstChildOfClass("JointInstance") end
        local grabWeld
        local function restoreAll()
            pcall(function()
                if grabWeld then grabWeld:Destroy() end
                hairHandle.CFrame = originalHairCFrame
                if originalWeld and originalWeld.Parent then originalWeld.Enabled = true end
                rightShoulder.C0 = originalShoulderC0
                neck.C0 = originalNeckC0
            end)
            animationRunning = false
        end
        local moveInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local backInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(rightShoulder, moveInfo, { C0 = originalShoulderC0 * CFrame.Angles(math.rad(-95), math.rad(8), math.rad(28)) }):Play()
        TweenService:Create(neck, moveInfo, { C0 = originalNeckC0 * CFrame.Angles(math.rad(8), math.rad(-16), 0) }):Play()
        pcall(function()
            if originalWeld and originalWeld.Parent then originalWeld.Enabled = false end
            hairHandle.CanCollide = false
            hairHandle.Massless = true
            grabWeld = Instance.new("Weld")
            grabWeld.Name = "HairGrabWeld"
            grabWeld.Part0 = rightArm
            grabWeld.Part1 = hairHandle
            grabWeld.C0 = CFrame.new(0, -1.05, -0.1) * CFrame.Angles(math.rad(80), 0, math.rad(6))
            grabWeld.Parent = rightArm
        end)
        task.spawn(function()
            task.wait(0.95)
            if not character.Parent then restoreAll() return end
            TweenService:Create(rightShoulder, backInfo, { C0 = originalShoulderC0 }):Play()
            TweenService:Create(neck, backInfo, { C0 = originalNeckC0 }):Play()
            task.wait(0.24)
            restoreAll()
        end)
    end
    LocalPlayerTab:CreateSection("Animation")
    LocalPlayerTab:CreateDropdown(withUiFlag({
        Name = "Animation list",
        Options = animationOptions,
        CurrentOption = { selectedAnimationName },
        Search = true,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            if picked then selectedAnimationName = picked end
        end,
    }, "animationSelection"))
    LocalPlayerTab:CreateButton({
        Name = "Animate",
        Callback = function()
            if selectedAnimationName == "Hair Grab (R6)" then
                playHairGrabAnimationR6()
                return
            end
            mountNotify({ Title = "Animation", Content = "Unknown animation selected" })
        end,
    })
    LocalPlayerTab:CreateButton({
        Name = "Clear Console",
        Callback = function()
            local cleared = false
            local clearFn = rawget(_G, "clearconsole") or rawget(_G, "rconsoleclear")
            if type(clearFn) == "function" then
                clearFn()
                cleared = true
            end
            mountNotify({
                Title = "Console",
                Content = cleared and "Console cleared" or "Clear not available (try clearconsole)",
                Icon = cleared and "check" or "x",
            })
        end
    })

    if type(options.autoSellTripAssist) == "table" then
        options.autoSellTripAssist.begin = function()
            local savedFly = flyEnabled
            local savedNoClip = noClipEnabled
            local savedOcclusionMode = Players.LocalPlayer.DevCameraOcclusionMode
            flyEnabled = true
            local lp = Players.LocalPlayer
            local ch = lp.Character
            local tripNoClipConnection = nil
            lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
            if ch then
                applyNoClip(ch, true)
            end
            if not savedNoClip then
                tripNoClipConnection = RunService.Stepped:Connect(function()
                    local chNow = lp.Character
                    if chNow then
                        applyNoClip(chNow, true)
                    end
                end)
            end
            startFly()
            return function()
                flyEnabled = savedFly
                if tripNoClipConnection then
                    tripNoClipConnection:Disconnect()
                    tripNoClipConnection = nil
                end
                if cameraPenetrateEnabled then
                    lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
                elseif savedOcclusionMode ~= nil then
                    lp.DevCameraOcclusionMode = savedOcclusionMode
                else
                    lp.DevCameraOcclusionMode = defaultCameraOcclusionMode
                end
                local ch2 = lp.Character
                if ch2 then
                    if savedNoClip then
                        applyNoClip(ch2, true)
                    else
                        applyNoClip(ch2, false)
                    end
                end
                if savedFly then
                    task.defer(function()
                        startFly()
                    end)
                else
                    stopFly()
                end
            end
        end
    end
end

return createLocalPlayerTab
