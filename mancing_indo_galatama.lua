local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TeleportService = game:GetService("TeleportService")

local RayfieldLibrary

do
    local ok, result = pcall(function()
        return require("./rayfield_library")
    end)

    if ok then
        RayfieldLibrary = result
    else
        if cloneref(RunService):IsStudio() then
            RayfieldLibrary = require(cloneref(ReplicatedStorage):WaitForChild("rayfield_library"))
        else
            RayfieldLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/rayfield_library.lua"))()
        end
    end
end

local function mountNotify(opts)
    local img
    local ic = opts.Icon
    if ic == "check" then
        img = 4483362748
    elseif ic == "x" or ic == "close" then
        img = 4384402990
    end
    RayfieldLibrary:Notify({
        Title = opts.Title,
        Content = opts.Content,
        Image = img,
        Duration = opts.Duration or 4,
    })
end

local function rayfieldDropdownFirst(opts)
    return type(opts) == "table" and opts[1] or opts
end

-- */  Window  /* --
local Window = RayfieldLibrary:CreateWindow({
    Name = "sempatpanick | Mancing Indo Galatama",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Mancing Indo Galatama",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "sempatpanick",
        FileName = "mancing_indo_galatama",
    },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
})
-- */  Global: format any Luau value for inspector text (Instance uses Name, same as ValueBase lines in formatInstanceDisplay)  /* --
function formatValueForDisplay(val)
    if val == nil then
        return "nil"
    end
    if typeof(val) == "Instance" then
        return val.Name or tostring(val)
    end
    return tostring(val)
end

-- */  Text from TextLabel / TextButton / TextBox for inspector lines (truncated, single-line)  /* --
function formatGuiInstanceTextForDisplay(inst)
    if not (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then
        return nil
    end
    local okT, txt = pcall(function()
        return inst.Text
    end)
    local display = (okT and type(txt) == "string") and txt or ""
    if display == "" then
        local okC, ct = pcall(function()
            return inst.ContentText
        end)
        if okC and type(ct) == "string" then
            display = ct
        end
    end
    if display == "" then
        return nil
    end
    display = string.gsub(display, "\r\n", " ")
    display = string.gsub(display, "\n", " ")
    if #display > 120 then
        display = string.sub(display, 1, 120) .. "..."
    end
    display = string.gsub(display, '"', "'")
    return display
end

-- */  Global: format instance for display (Key = Value); isShowDataType == false => Name = Value only; isShowLocation => show Position for BaseParts  /* --
function formatInstanceDisplay(inst, isShowDataType, isShowLocation)
    if isShowDataType == false then
        local ok, val = pcall(function() return inst.Value end)
        if ok and val ~= nil then
            return inst.Name .. " = " .. formatValueForDisplay(val)
        end
        local guiText = formatGuiInstanceTextForDisplay(inst)
        if guiText then
            return inst.Name .. ' = "' .. guiText .. '"'
        end
        return inst.Name .. " = "
    end
    local base = inst.Name .. " = " .. inst.ClassName
    local ok, val = pcall(function() return inst.Value end)
    if ok and val ~= nil then
        base = base .. " (" .. formatValueForDisplay(val) .. ")"
    end
    local guiText = formatGuiInstanceTextForDisplay(inst)
    if guiText then
        base = base .. ' ("' .. guiText .. '")'
    end
    if isShowLocation and inst:IsA("BasePart") then
        local p = inst.Position
        base = base .. " [" .. string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z) .. "]"
    end
    return base
end

-- */  Local Player Tab  /* --
do
    local LocalPlayerTab = Window:CreateTab("Local Player", 4483362458)

    LocalPlayerTab:CreateSection("Misc")
    local infiniteJumpConnection = nil
    local antiAfkConnection = nil
    local noClipEnabled = false
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

    LocalPlayerTab:CreateToggle({
        Name = "Anti AFK",
        Flag = "galatama_lp_antiAfk",
        CurrentValue = true,
        Callback = function(enabled)
            if enabled then
                startAntiAfk()
            else
                stopAntiAfk()
            end
        end
    })

    LocalPlayerTab:CreateToggle({
        Name = "Infinite Jump",
        Flag = "galatama_lp_infiniteJump",
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
    })

    LocalPlayerTab:CreateToggle({
        Name = "No Clip",
        Flag = "galatama_lp_noClip",
        Callback = function(enabled)
            noClipEnabled = enabled
            local character = Players.LocalPlayer.Character
            applyNoClip(character, enabled)
        end
    })

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

    LocalPlayerTab:CreateToggle({
        Name = "Fly",
        Flag = "galatama_lp_fly",
        Callback = function(enabled)
            flyEnabled = enabled
            if enabled then
                startFly()
            else
                stopFly()
            end
        end
    })

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

    LocalPlayerTab:CreateToggle({
        Name = "Free Camera",
        Flag = "galatama_lp_freeCamera",
        Callback = function(enabled)
            freeCameraEnabled = enabled
            if enabled then
                startFreeCamera()
            else
                stopFreeCamera()
            end
        end
    })

    LocalPlayerTab:CreateToggle({
        Name = "Camera Penetrate",
        Flag = "galatama_lp_cameraPenetrate",
        Callback = function(enabled)
            cameraPenetrateEnabled = enabled
            local lp = Players.LocalPlayer
            if cameraPenetrateEnabled then
                lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
            else
                lp.DevCameraOcclusionMode = defaultCameraOcclusionMode
            end
        end
    })

    do
        Players.LocalPlayer.CharacterAdded:Connect(function(character)
            if flyEnabled then
                task.defer(function() startFly() end)
            end
            if noClipEnabled then
                applyNoClip(character, true)
                character.DescendantAdded:Connect(function(part)
                    if noClipEnabled and part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end)
            end
        end)
        if noClipEnabled and Players.LocalPlayer.Character then
            applyNoClip(Players.LocalPlayer.Character, true)
        end
    end
    LocalPlayerTab:CreateSection("Walk Speed")
    local defaultWalkSpeed = 16

    local function getCurrentCharacterWalkSpeed()
        local character = Players.LocalPlayer.Character
        if not character then
            return nil, "Character not loaded"
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return nil, "Humanoid not found"
        end
        return humanoid.WalkSpeed
    end

    local currentWalkSpeed = getCurrentCharacterWalkSpeed()
    local walkSpeedCurrentValue = tostring(currentWalkSpeed or defaultWalkSpeed)

    local WalkSpeedInput = LocalPlayerTab:CreateInput({
        Name = "Speed",
        PlaceholderText = "e.g. 16 or 100",
        Flag = "galatama_lp_walkSpeed",
        CurrentValue = walkSpeedCurrentValue,
        Callback = function(value)
            walkSpeedCurrentValue = value
        end
    })

    local function syncWalkSpeedInputFromCharacter(showNotify)
        local speed, errMessage = getCurrentCharacterWalkSpeed()
        if not speed then
            if showNotify then
                mountNotify({ Title = "Walk Speed", Content = errMessage })
            end
            return false
        end

        local speedText = tostring(speed)
        walkSpeedCurrentValue = speedText
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
            local speed = tonumber(walkSpeedCurrentValue) or defaultWalkSpeed
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
            walkSpeedCurrentValue = tostring(defaultWalkSpeed)
            mountNotify({ Title = "Walk Speed", Content = "Reset to " .. tostring(defaultWalkSpeed) })
        end
    })
    LocalPlayerTab:CreateSection("Jump Height")
    local defaultJumpHeight = 7.2

    local function getCurrentCharacterJumpHeight()
        local character = Players.LocalPlayer.Character
        if not character then
            return nil, "Character not loaded"
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return nil, "Humanoid not found"
        end
        return humanoid.JumpHeight
    end

    local currentJumpHeight = getCurrentCharacterJumpHeight()
    local jumpHeightValue = tostring(currentJumpHeight or defaultJumpHeight)

    local JumpHeightInput = LocalPlayerTab:CreateInput({
        Name = "Height",
        PlaceholderText = "e.g. 7.2 or 50",
        Flag = "galatama_lp_jumpHeight",
        CurrentValue = jumpHeightValue,
        Callback = function(value)
            jumpHeightValue = value
        end
    })

    local function syncJumpHeightInputFromCharacter(showNotify)
        local jumpHeight, errMessage = getCurrentCharacterJumpHeight()
        if not jumpHeight then
            if showNotify then
                mountNotify({ Title = "Jump Height", Content = errMessage })
            end
            return false
        end

        local jumpHeightText = tostring(jumpHeight)
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
    local espMaxDistance = 10000
    local espPlayerState: { [Player]: { highlight: Highlight?, nameGui: BillboardGui?, lineBeam: Beam?, lineFrom: Attachment?, lineTo: Attachment? } } = {}
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

    local function espAnyEnabled(): boolean
        return espNamesEnabled or espDistanceEnabled or espCharacterEnabled or espLinesEnabled
    end

    LocalPlayerTab:CreateInput({
        Name = "ESP Max Distance",
        PlaceholderText = "0 = unlimited, e.g. 10000",
        CurrentValue = tostring(espMaxDistance),
        Callback = function(value)
            local n = tonumber(value)
            if not n then return end
            espMaxDistance = math.max(0, n)
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })
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
            return
        end
        if espPlayerAddedConn then espPlayerAddedConn:Disconnect() espPlayerAddedConn = nil end
        if espPlayerRemovingConn then espPlayerRemovingConn:Disconnect() espPlayerRemovingConn = nil end
        if espLocalCharacterConn then espLocalCharacterConn:Disconnect() espLocalCharacterConn = nil end
        if espRenderStepConn then espRenderStepConn:Disconnect() espRenderStepConn = nil end
        for player in pairs(espPlayerState) do espClearVisualsForPlayer(player) espPlayerState[player] = nil end
    end

    LocalPlayerTab:CreateToggle({
        Name = "ESP Player Names",
        CurrentValue = false,
        Callback = function(enabled)
            espNamesEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })
    LocalPlayerTab:CreateToggle({
        Name = "ESP Player Distance",
        CurrentValue = false,
        Callback = function(enabled)
            espDistanceEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })
    LocalPlayerTab:CreateToggle({
        Name = "ESP Player Character",
        CurrentValue = false,
        Callback = function(enabled)
            espCharacterEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })
    LocalPlayerTab:CreateToggle({
        Name = "ESP Player Lines",
        CurrentValue = false,
        Callback = function(enabled)
            espLinesEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })
    LocalPlayerTab:CreateSection("Players Info")
    local infoPlayerList = {}
    local infoPlayerDisplayNames = {}
    local selectedInfoPlayer = nil
    local PlayersInfoDropdown
    local PlayersInfoParagraph

    local function playerInfoLabel(player)
        if not player then return "" end
        local dn = player.DisplayName
        if dn and dn ~= "" and dn ~= player.Name then
            return string.format("%s (@%s)", dn, player.Name)
        end
        return player.Name
    end

    local function formatHumanoidChildLine(child)
        if child:IsA("ValueBase") then
            local ok, val = pcall(function()
                return child.Value
            end)
            if not ok then
                return "  " .. child.Name .. " (" .. child.ClassName .. ") = ?"
            end
            return "  " .. child.Name .. " (" .. child.ClassName .. ") = " .. formatValueForDisplay(val)
        end
        return "  " .. child.Name .. " = " .. child.ClassName
    end

    -- Fallback fields if runtime property discovery is unavailable.
    local HUMANOID_INSPECT_PROPERTIES_FALLBACK = {
        "AutoJumpEnabled",
        "AutoRotate",
        "BreakJointsOnDeath",
        "CameraOffset",
        "DisplayDistanceType",
        "EvaluateStateMachine",
        "FloorMaterial",
        "Health",
        "HealthDisplayType",
        "HipHeight",
        "Jump",
        "JumpHeight",
        "JumpPower",
        "MaxHealth",
        "MaxSlopeAngle",
        "MeshHeadScale",
        "MoveDirection",
        "NameDisplayDistance",
        "RequiresNeck",
        "RigType",
        "RootPart",
        "SeatPart",
        "Sit",
        "TargetPoint",
        "UseJumpPower",
        "WalkSpeed",
        "WalkToPart",
        "WalkToPoint",
    }

    local PLAYER_INSPECT_PROPERTIES_FALLBACK = {
        "AccountAge",
        "AutoJumpEnabled",
        "CanLoadCharacterAppearance",
        "CharacterAppearanceId",
        "DataComplexity",
        "DataReady",
        "DevComputerCameraMode",
        "DevComputerMovementMode",
        "DevEnableMouseLock",
        "DevTouchCameraMode",
        "DevTouchMovementMode",
        "DisplayName",
        "FollowUserId",
        "GameplayPaused",
        "HasVerifiedBadge",
        "HealthDisplayDistance",
        "LocaleId",
        "MembershipType",
        "Name",
        "Neutral",
        "RespawnLocation",
        "SimulationRadius",
        "Team",
        "TeamColor",
        "UserId",
    }

    local function getReadablePropertyNames(instance: Instance, fallbackList: { string }): { string }
        local names = {}
        local seen = {}
        local function addName(name: string)
            if name == "" or seen[name] then
                return
            end
            seen[name] = true
            table.insert(names, name)
        end

        local getPropertiesFn = rawget(_G, "getproperties")
        if type(getPropertiesFn) == "function" then
            local ok = pcall(function()
                local discovered = getPropertiesFn(instance)
                if type(discovered) == "table" then
                    for _, name in ipairs(discovered) do
                        if type(name) == "string" then
                            addName(name)
                        end
                    end
                end
            end)
            if not ok then
                -- Ignore and fall back to static property lists below.
            end
        end

        if #names == 0 then
            for _, name in ipairs(fallbackList) do
                addName(name)
            end
        end

        table.sort(names, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return names
    end

    local function buildPlayersInfoText(player)
        if not player then
            return "Select a player from the list."
        end
        local lines = {}
        table.insert(lines, "Username: " .. player.Name)
        local dn = player.DisplayName
        table.insert(lines, "Display name: " .. ((dn and dn ~= "") and dn or "(same as username)"))
        table.insert(lines, "")
        table.insert(lines, "LocalPlayer attributes:")
        local localPlayer = Players.LocalPlayer
        if localPlayer then
            local attrs = localPlayer:GetAttributes()
            local attrRows = {}
            for key, val in pairs(attrs) do
                table.insert(attrRows, {
                    key = tostring(key),
                    text = "  " .. tostring(key) .. " = " .. formatValueForDisplay(val),
                })
            end
            table.sort(attrRows, function(a, b)
                return string.lower(a.key) < string.lower(b.key)
            end)
            if #attrRows == 0 then
                table.insert(lines, "  (none)")
            else
                for _, row in ipairs(attrRows) do
                    table.insert(lines, row.text)
                end
            end
        else
            table.insert(lines, "  (LocalPlayer not found)")
        end
        table.insert(lines, "")
        table.insert(lines, "LocalPlayer properties:")
        if localPlayer then
            local propRows = {}
            for _, propName in ipairs(getReadablePropertyNames(localPlayer, PLAYER_INSPECT_PROPERTIES_FALLBACK)) do
                local ok, val = pcall(function()
                    return localPlayer[propName]
                end)
                if ok then
                    table.insert(propRows, {
                        key = propName,
                        text = "  " .. propName .. " = " .. formatValueForDisplay(val),
                    })
                end
            end
            table.sort(propRows, function(a, b)
                return string.lower(a.key) < string.lower(b.key)
            end)
            if #propRows == 0 then
                table.insert(lines, "  (none readable)")
            else
                for _, row in ipairs(propRows) do
                    table.insert(lines, row.text)
                end
            end
        else
            table.insert(lines, "  (LocalPlayer not found)")
        end
        local character = player.Character
        if not character then
            table.insert(lines, "Character: not loaded")
            table.insert(lines, "Location: â€”")
            table.insert(lines, "")
            table.insert(lines, "Humanoid properties: â€”")
            table.insert(lines, "Inside Humanoid (children): â€”")
            return table.concat(lines, "\n")
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
        if root then
            local p = root.Position
            table.insert(lines, string.format("Location: %.2f, %.2f, %.2f", p.X, p.Y, p.Z))
            local okVel, velMag = pcall(function()
                return root.AssemblyLinearVelocity.Magnitude
            end)
            if okVel and velMag then
                table.insert(lines, string.format("Velocity (mag): %.2f", velMag))
            end
        else
            table.insert(lines, "Location: (no HumanoidRootPart / PrimaryPart)")
        end
        table.insert(lines, "")
        table.insert(lines, "Humanoid attributes:")
        if humanoid then
            local humAttrs = humanoid:GetAttributes()
            local humAttrRows = {}
            for key, val in pairs(humAttrs) do
                table.insert(humAttrRows, {
                    key = tostring(key),
                    text = "  " .. tostring(key) .. " = " .. formatValueForDisplay(val),
                })
            end
            table.sort(humAttrRows, function(a, b)
                return string.lower(a.key) < string.lower(b.key)
            end)
            if #humAttrRows == 0 then
                table.insert(lines, "  (none)")
            else
                for _, row in ipairs(humAttrRows) do
                    table.insert(lines, row.text)
                end
            end
        else
            table.insert(lines, "  (no Humanoid)")
        end
        table.insert(lines, "")
        if humanoid then
            table.insert(lines, "Humanoid properties:")
            local propRows = {}
            for _, propName in ipairs(getReadablePropertyNames(humanoid, HUMANOID_INSPECT_PROPERTIES_FALLBACK)) do
                local ok, val = pcall(function()
                    return humanoid[propName]
                end)
                if ok then
                    table.insert(propRows, {
                        key = propName,
                        text = "  "
                            .. propName
                            .. " = "
                            .. formatValueForDisplay(val),
                    })
                end
            end
            table.sort(propRows, function(a, b)
                return string.lower(a.key) < string.lower(b.key)
            end)
            for _, row in ipairs(propRows) do
                table.insert(lines, row.text)
            end
        else
            table.insert(lines, "Humanoid properties: (no Humanoid)")
        end
        table.insert(lines, "")
        table.insert(lines, "Inside Humanoid (children):")
        if humanoid then
            local children = humanoid:GetChildren()
            table.sort(children, function(a, b)
                return string.lower(a.Name) < string.lower(b.Name)
            end)
            if #children == 0 then
                table.insert(lines, "  (none)")
            else
                for _, child in ipairs(children) do
                    table.insert(lines, formatHumanoidChildLine(child))
                end
            end
        else
            table.insert(lines, "  (no Humanoid)")
        end
        return table.concat(lines, "\n")
    end

    local function updatePlayersInfoParagraph()
        if not (PlayersInfoParagraph and PlayersInfoParagraph.Set) then
            return
        end
        local detailText = buildPlayersInfoText(selectedInfoPlayer)
        PlayersInfoParagraph:Set({
            Title = "Details",
            Content = detailText,
        })
    end

    local function refreshPlayersInfoList(showNotify)
        infoPlayerList = {}
        infoPlayerDisplayNames = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.ClassName == "Player" then
                table.insert(infoPlayerList, plr)
                table.insert(infoPlayerDisplayNames, playerInfoLabel(plr))
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

    PlayersInfoDropdown = LocalPlayerTab:CreateDropdown({
        Name = "Player",
        Options = infoPlayerDisplayNames,
        CurrentOption = {},
        Search = true,
        Callback = function(opts)
            local value = rayfieldDropdownFirst(opts)
            selectedInfoPlayer = nil
            if value then
                local idx = table.find(infoPlayerDisplayNames, value)
                if idx and infoPlayerList[idx] then
                    selectedInfoPlayer = infoPlayerList[idx]
                end
            end
            updatePlayersInfoParagraph()
        end,
    })

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

    refreshPlayersInfoList(false)

    Players.PlayerAdded:Connect(function()
        refreshPlayersInfoList(false)
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

    CarryPlayerDropdown = LocalPlayerTab:CreateDropdown({
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
    })

    LocalPlayerTab:CreateToggle({
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
    })

    refreshCarryPlayers()
    Players.PlayerAdded:Connect(refreshCarryPlayers)
    Players.PlayerRemoving:Connect(function()
        task.defer(refreshCarryPlayers)
    end)

    LocalPlayerTab:CreateSection("Server")
    LocalPlayerTab:CreateButton({
        Name = "Rejoin server",
        Callback = function()
            local placeId = game.PlaceId
            local jobId = game.JobId
            if placeId and jobId and #jobId > 0 then
                local ok, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, jobId)
                end)
                if not ok then
                    mountNotify({
                        Title = "Rejoin",
                        Content = "Failed: " .. tostring(err),
                    })
                end
            else
                mountNotify({
                    Title = "Rejoin",
                    Content = "Cannot rejoin (missing PlaceId or JobId)",
                })
            end
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
            if child:IsA("Accessory") then
                table.insert(accessories, child)
            end
        end

        for _, accessory in ipairs(accessories) do
            local okType, accType = pcall(function()
                return accessory.AccessoryType
            end)
            if okType and accType == Enum.AccessoryType.Hair then
                local handle = accessory:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    return accessory, handle
                end
            end
        end

        for _, accessory in ipairs(accessories) do
            if string.find(string.lower(accessory.Name), "hair", 1, true) then
                local handle = accessory:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    return accessory, handle
                end
            end
        end

        return nil, nil
    end

    local function playHairGrabAnimationR6()
        if animationRunning then
            return
        end
        animationRunning = true

        local player = Players.LocalPlayer
        local character = player.Character
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

        local accessory, hairHandle = findHairAccessory(character)
        if not accessory or not hairHandle then
            animationRunning = false
            mountNotify({ Title = "Animation", Content = "No hair accessory found" })
            return
        end

        local originalShoulderC0 = rightShoulder.C0
        local originalNeckC0 = neck.C0
        local originalHairCFrame = hairHandle.CFrame
        local originalWeld = hairHandle:FindFirstChild("AccessoryWeld")
        if not (originalWeld and originalWeld:IsA("JointInstance")) then
            originalWeld = hairHandle:FindFirstChildOfClass("JointInstance")
        end

        local grabWeld = nil
        local restoreDone = false
        local function restoreAll()
            if restoreDone then
                return
            end
            restoreDone = true
            pcall(function()
                if grabWeld then
                    grabWeld:Destroy()
                    grabWeld = nil
                end
                hairHandle.CFrame = originalHairCFrame
                if originalWeld and originalWeld.Parent then
                    originalWeld.Enabled = true
                end
                rightShoulder.C0 = originalShoulderC0
                neck.C0 = originalNeckC0
            end)
            animationRunning = false
        end

        local moveInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local backInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local targetShoulderC0 = originalShoulderC0
            * CFrame.Angles(math.rad(-95), math.rad(8), math.rad(28))
        local targetNeckC0 = originalNeckC0
            * CFrame.Angles(math.rad(8), math.rad(-16), 0)

        local shoulderTween = TweenService:Create(rightShoulder, moveInfo, { C0 = targetShoulderC0 })
        local neckTween = TweenService:Create(neck, moveInfo, { C0 = targetNeckC0 })

        pcall(function()
            if originalWeld and originalWeld.Parent then
                originalWeld.Enabled = false
            end
            hairHandle.CanCollide = false
            hairHandle.Massless = true
            grabWeld = Instance.new("Weld")
            grabWeld.Name = "HairGrabWeld"
            grabWeld.Part0 = rightArm
            grabWeld.Part1 = hairHandle
            grabWeld.C0 = CFrame.new(0, -1.05, -0.1) * CFrame.Angles(math.rad(80), math.rad(0), math.rad(6))
            grabWeld.Parent = rightArm
        end)

        shoulderTween:Play()
        neckTween:Play()

        task.spawn(function()
            task.wait(0.95)
            if not character.Parent then
                restoreAll()
                return
            end
            local shoulderBack = TweenService:Create(rightShoulder, backInfo, { C0 = originalShoulderC0 })
            local neckBack = TweenService:Create(neck, backInfo, { C0 = originalNeckC0 })
            shoulderBack:Play()
            neckBack:Play()
            task.wait(0.24)
            restoreAll()
        end)
    end
    LocalPlayerTab:CreateSection("Animation")
    LocalPlayerTab:CreateDropdown({
        Name = "Animation list",
        Options = animationOptions,
        CurrentOption = { selectedAnimationName },
        Callback = function(opts)
            local value = rayfieldDropdownFirst(opts)
            if value then
                selectedAnimationName = value
            end
        end,
    })

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
end

-- */  Main Tab (Auto Fishing â€” Reel only, same flow as mancing_indo.lua reel mode)  /* --
do
    local MainTab = Window:CreateTab("Main", 4483362458)

    MainTab:CreateSection("Look Direction")
    local POOL_CORNERS = {
        Vector3.new(563.48, 4.20, 346.40),
        Vector3.new(563.54, 4.03, 473.97),
        Vector3.new(752.70, 4.06, 473.99),
        Vector3.new(752.90, 4.34, 346.39),
    }
    local autoLookPoolEnabled = false
    local autoLookPoolConnection = nil

    local function nearestPointOnSegmentXZ(pointPos, a, b)
        local ap = Vector3.new(pointPos.X - a.X, 0, pointPos.Z - a.Z)
        local ab = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
        local abLenSq = ab.X * ab.X + ab.Z * ab.Z
        if abLenSq <= 1e-8 then
            return Vector3.new(a.X, pointPos.Y, a.Z)
        end
        local t = (ap.X * ab.X + ap.Z * ab.Z) / abLenSq
        t = math.clamp(t, 0, 1)
        return Vector3.new(a.X + ab.X * t, pointPos.Y, a.Z + ab.Z * t)
    end

    local function getNearestPoolSidePoint(pointPos)
        local bestPoint = nil
        local bestDistSq = math.huge
        for i = 1, #POOL_CORNERS do
            local a = POOL_CORNERS[i]
            local b = POOL_CORNERS[(i % #POOL_CORNERS) + 1]
            local candidate = nearestPointOnSegmentXZ(pointPos, a, b)
            local dx = candidate.X - pointPos.X
            local dz = candidate.Z - pointPos.Z
            local distSq = dx * dx + dz * dz
            if distSq < bestDistSq then
                bestDistSq = distSq
                bestPoint = candidate
            end
        end
        return bestPoint
    end

    local function stopAutoLookPool()
        if autoLookPoolConnection then
            autoLookPoolConnection:Disconnect()
            autoLookPoolConnection = nil
        end
    end

    local function startAutoLookPool()
        stopAutoLookPool()
        autoLookPoolConnection = RunService.Heartbeat:Connect(function()
            if not autoLookPoolEnabled then
                stopAutoLookPool()
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                return
            end
            local target = getNearestPoolSidePoint(rootPart.Position)
            if not target then
                return
            end
            if (target - rootPart.Position).Magnitude < 0.05 then
                return
            end
            rootPart.CFrame = CFrame.lookAt(rootPart.Position, target)
        end)
    end

    MainTab:CreateToggle({
        Name = "Auto Look to Pool",
        Flag = "galatama_main_autoLookPool",
        CurrentValue = false,
        Callback = function(enabled)
            autoLookPoolEnabled = enabled
            if enabled then
                startAutoLookPool()
            else
                stopAutoLookPool()
            end
        end,
    })
    MainTab:CreateSection("Auto Fishing")
    local autoFishingEnabled = false
    local autoFishingLoopRunning = false
    local instantFishingEnabled = false
    local instantFishingLoopRunning = false
    local instantFishingDelaySec = 4
    local instantFishingArmSeq = 0
    local randomCastCmgrEnabled = false
    local randomCastCmgrSync = false
    local RandomCastCmgrToggleAuto
    local RandomCastCmgrToggleInstant

    local function setBothRandomCastCmgrToggles(enabled, skipInstance)
        randomCastCmgrSync = true
        randomCastCmgrEnabled = enabled
        if RandomCastCmgrToggleAuto and RandomCastCmgrToggleAuto ~= skipInstance then
            pcall(function()
                RandomCastCmgrToggleAuto:Set(enabled)
            end)
        end
        if RandomCastCmgrToggleInstant and RandomCastCmgrToggleInstant ~= skipInstance then
            pcall(function()
                RandomCastCmgrToggleInstant:Set(enabled)
            end)
        end
        randomCastCmgrSync = false
    end

    local minigameAutoSolveConn = nil
    local minigameCycleSeq = 0
    local MINIGAME_SESSION_TIMEOUT = 20
    local REEL_AUTOPLAY_START_DELAY = 0.06
    local REEL_AUTOPLAY_TIMEOUT = 55
    local REEL_DEEP_NUKE_AFTER = 0.45
    local REEL_AUTOPLAY_RS_HOOK_NAME = "MancingIndoGalatamaReelDeepHack"
    local REEL_TRY_FAST_REMOTE_COMPLETE = true
    local reelAutoplayLoopRunning = false
    local mgrReelPendingToken = nil
    local autoFishDelay2sAfterPreEnableDrain = false
    local minigameSessionWait = nil
    local AutoFishStatusParagraph

    local function fishingAutomationActive()
        return autoFishingEnabled or instantFishingEnabled
    end

    local function ensureMinigamePreferenceIsReel()
        -- Galatama match is reel-only; no SettingsGui minigame switch.
    end

    local function releaseMinigameSessionWait()
        local pending = minigameSessionWait
        if not pending then
            return
        end
        minigameSessionWait = nil
        pending.done:Fire()
    end

    local function getMinigamesMgArea()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return nil
        end
        local mg = pg:FindFirstChild("Minigames")
        if not (mg and mg:IsA("ScreenGui")) then
            return nil
        end
        local canvas = mg:FindFirstChild("Canvas")
        local area = canvas and canvas:FindFirstChild("MgArea")
        if area and area:IsA("GuiObject") then
            return area
        end
        return nil
    end

    local function isFishingMinigameCircleActive()
        local area = getMinigamesMgArea()
        if not area then
            return false
        end
        local tClick = area:FindFirstChild("Click")
        local tHold = area:FindFirstChild("Hold")
        for _, child in area:GetChildren() do
            if child ~= tClick and child ~= tHold and child:IsA("GuiObject") and child.Visible then
                return true
            end
        end
        return false
    end

    local function countReelUiScreenGuis(pg)
        local n = 0
        for _, ch in pg:GetChildren() do
            if ch.Name == "ReelUI" and ch:IsA("ScreenGui") then
                n = n + 1
            end
        end
        return n
    end

    -- Galatama: minigame is active when PlayerGui has more than one ReelUI (e.g. template + live instance).
    local function isReelMinigameActive()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return false
        end
        return countReelUiScreenGuis(pg) > 1
    end

    -- Status / reel parts: only when multiple ReelUIs (minigame active); use the last sibling named ReelUI.
    local function getReelUiScreenGuiForResolve()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return nil
        end
        local lastReel = nil
        for _, ch in pg:GetChildren() do
            if ch.Name == "ReelUI" and ch:IsA("ScreenGui") then
                lastReel = ch
            end
        end
        if not lastReel then
            return nil
        end
        if countReelUiScreenGuis(pg) > 1 then
            return lastReel
        end
        return nil
    end

    local function mancingFindNamedDescendant(root, name)
        local direct = root:FindFirstChild(name)
        if direct then
            return direct
        end
        for _, d in root:GetDescendants() do
            if d.Name == name then
                return d
            end
        end
        return nil
    end

    local function mancingVimKey(isDown, keyCode)
        local ok = pcall(function()
            VirtualInputManager:SendKeyEvent(isDown, keyCode, false, game)
        end)
        return ok
    end

    local function mancingResolveReelParts()
        local reelUi = getReelUiScreenGuiForResolve()
        if not (reelUi and reelUi:IsA("ScreenGui") and reelUi.Enabled) then
            return nil, nil, nil, nil
        end
        local canvas = mancingFindNamedDescendant(reelUi, "Canvas")
        if not canvas then
            return reelUi, nil, nil, nil
        end
        local bar = mancingFindNamedDescendant(canvas, "Bar")
        local fill = bar and mancingFindNamedDescendant(bar, "Fill")
        local status = mancingFindNamedDescendant(canvas, "Status")
        if status and not (status:IsA("TextLabel") or status:IsA("TextButton")) then
            status = nil
        end
        local f = (fill and fill:IsA("GuiObject")) and fill or nil
        local sgui = (status and status:IsA("GuiObject")) and status or nil
        return reelUi, sgui, nil, f
    end

    local function mancingGetReelStatusText(statusGui)
        if not statusGui then
            return ""
        end
        local t = ""
        if statusGui:IsA("TextLabel") then
            t = statusGui.Text
            if t == "" then
                local okCt, ct = pcall(function()
                    return statusGui.ContentText
                end)
                if okCt and type(ct) == "string" then
                    t = ct
                end
            end
        elseif statusGui:IsA("TextButton") then
            t = statusGui.Text
            if t == "" then
                local okCt, ct = pcall(function()
                    return statusGui.ContentText
                end)
                if okCt and type(ct) == "string" then
                    t = ct
                end
            end
        end
        return t
    end

    local function mancingReelStatusRequiresNoKnobSpin(st)
        if st == "" then
            return false
        end
        if string.find(st, "ULUR", 1, true) then
            return true
        end
        if string.find(st, "TAHAN", 1, true) then
            return true
        end
        if string.find(st, "MELAWAN", 1, true) or string.find(st, "IKANNYA", 1, true) then
            return true
        end
        return false
    end

    local function mancingClassifyReelPhase(st)
        if string.find(st, "ULUR", 1, true) then
            return "reel_out"
        end
        if string.find(st, "TAHAN", 1, true) then
            return "idle"
        end
        if string.find(st, "MELAWAN", 1, true) or string.find(st, "IKANNYA", 1, true) then
            return "idle"
        end
        if string.find(st, "TERTANGKAP", 1, true) or string.find(st, "KABUR", 1, true) then
            return "idle"
        end
        if string.find(st, "PUTAR", 1, true) then
            return "spin"
        end
        if string.find(st, "SIAP", 1, true) then
            return "spin"
        end
        return "spin"
    end

    local function mancingResolveReelPhase(st)
        if st ~= "" then
            return mancingClassifyReelPhase(st)
        end
        return "spin"
    end

    -- Instant fishing only: getconnections + debug.setupvalue; optional fast MGR Complete.
    local reelDeepHookCachedRenderFns = {}
    local reelDeepHookCachedConns = {}

    local function mancingExploitGetConnections(sig)
        local g = rawget(_G, "getconnections")
        local synTbl = rawget(_G, "syn")
        if type(g) ~= "function" and type(synTbl) == "table" then
            g = synTbl.getconnections
        end
        if type(g) ~= "function" and type(getgenv) == "function" then
            g = rawget(getgenv(), "getconnections")
        end
        if type(g) ~= "function" then
            return nil
        end
        local ok, res = pcall(g, sig)
        if ok and type(res) == "table" then
            return res
        end
        return nil
    end

    local function mancingExploitConnFunction(conn)
        if type(conn) ~= "table" then
            return nil
        end
        return conn.Function or rawget(conn, "f")
    end

    local function mancingFnReferencesInstance(fn, inst)
        if type(fn) ~= "function" or type(debug) ~= "table" or type(debug.getupvalue) ~= "function" then
            return false
        end
        local ok, found = pcall(function()
            local i = 1
            while true do
                local name, val = debug.getupvalue(fn, i)
                if name == nil then
                    break
                end
                if val == inst then
                    return true
                end
                i = i + 1
            end
            return false
        end)
        return ok and found == true
    end

    local function mancingReelDeepHackBuildCache(mgr)
        table.clear(reelDeepHookCachedRenderFns)
        table.clear(reelDeepHookCachedConns)
        local list = mancingExploitGetConnections(RunService.RenderStepped)
        if not list then
            return false
        end
        for _, c in list do
            local fn = mancingExploitConnFunction(c)
            if type(fn) == "function" and mancingFnReferencesInstance(fn, mgr) then
                table.insert(reelDeepHookCachedRenderFns, fn)
                table.insert(reelDeepHookCachedConns, c)
            end
        end
        return #reelDeepHookCachedRenderFns > 0
    end

    local function mancingReelDeepHackEnsureCache(mgr)
        if #reelDeepHookCachedRenderFns > 0 then
            local f0 = reelDeepHookCachedRenderFns[1]
            if type(f0) == "function" and mancingFnReferencesInstance(f0, mgr) then
                return true
            end
        end
        return mancingReelDeepHackBuildCache(mgr)
    end

    local function mancingReelDeepHackTrySetupvalueU32(fn)
        if type(debug) ~= "table" or type(debug.getupvalue) ~= "function" or type(debug.setupvalue) ~= "function" then
            return false
        end
        local candidates = {}
        local okSet, did = pcall(function()
            local i = 1
            while true do
                local name, val = debug.getupvalue(fn, i)
                if name == nil then
                    break
                end
                if name == "u32" and type(val) == "number" then
                    debug.setupvalue(fn, i, 1)
                    return true
                end
                if type(val) == "number" and val >= 0 and val <= 1 then
                    table.insert(candidates, i)
                end
                i = i + 1
            end
            if #candidates == 1 then
                debug.setupvalue(fn, candidates[1], 1)
                return true
            end
            if #candidates > 1 then
                local _, _, _, fill = mancingResolveReelParts()
                if fill then
                    local target = fill.Size.X.Scale
                    local bestIdx = nil
                    local bestD = math.huge
                    for _, idx in candidates do
                        local _, v = debug.getupvalue(fn, idx)
                        if type(v) == "number" then
                            local d = math.abs(v - target)
                            if d < bestD then
                                bestD = d
                                bestIdx = idx
                            end
                        end
                    end
                    if bestIdx and bestD < 0.55 then
                        debug.setupvalue(fn, bestIdx, 1)
                        return true
                    end
                end
                local maxIdx = nil
                local maxV = -math.huge
                for _, idx in candidates do
                    local _, v = debug.getupvalue(fn, idx)
                    if type(v) == "number" and v >= 0 and v <= 1 and v > maxV then
                        maxV = v
                        maxIdx = idx
                    end
                end
                if maxIdx ~= nil then
                    debug.setupvalue(fn, maxIdx, 1)
                    return true
                end
            end
            return false
        end)
        return okSet and did == true
    end

    local function mancingReelDeepHackTryDisableAndComplete(mgr, token)
        if token == nil then
            return false
        end
        mancingReelDeepHackEnsureCache(mgr)
        for _, c in reelDeepHookCachedConns do
            if type(c) == "table" and type(c.Disable) == "function" and type(c.Enable) == "function" then
                local ok = pcall(function()
                    c:Disable()
                    mgr:FireServer("Complete", token)
                    task.wait(0.04)
                    c:Enable()
                end)
                if ok then
                    return true
                end
            end
        end
        return false
    end

    local function mancingReelDeepHackTrySetupvalueWin(mgr)
        mancingReelDeepHackEnsureCache(mgr)
        for _, fn in reelDeepHookCachedRenderFns do
            if mancingReelDeepHackTrySetupvalueU32(fn) then
                return true
            end
        end
        return false
    end

    local function mancingReelDeepHackTryNukeComplete(mgr)
        return mancingReelDeepHackTryDisableAndComplete(mgr, mgrReelPendingToken)
    end

    local function mancingReelDeepHookClearCache()
        table.clear(reelDeepHookCachedRenderFns)
        table.clear(reelDeepHookCachedConns)
    end

    local function updateAutoFishStatusParagraphs()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")

        local reelBits = {}
        if not pg then
            table.insert(reelBits, "PlayerGui: missing")
        else
            local n = countReelUiScreenGuis(pg)
            table.insert(reelBits, (n > 1) and "Minigame: active" or "Minigame: not active")
            local _, statusGui, _, fill = mancingResolveReelParts()
            local st = mancingGetReelStatusText(statusGui)
            if st ~= "" then
                local phase = mancingResolveReelPhase(st)
                table.insert(reelBits, "Status: " .. st)
                table.insert(reelBits, "Phase: " .. phase)
            else
                table.insert(reelBits, "Status: â€”")
            end
            if fill then
                table.insert(
                    reelBits,
                    string.format("Fill: %.0f%%", math.clamp(fill.Size.X.Scale, 0, 1) * 100)
                )
            else
                table.insert(reelBits, "Fill: â€”")
            end
        end
        local reelText = table.concat(reelBits, "\n")

        if AutoFishStatusParagraph and AutoFishStatusParagraph.Set then
            AutoFishStatusParagraph:Set({ Content = reelText })
        end
    end

    -- Auto: VIM E/Q only. Instant: deep hack + optional fast MGR Complete + E/Q loop.
    local function runMancingReelAutoplayLoop()
        local useReelDeepHack = instantFishingEnabled
        local keysWork = true
        local eHeld, qHeld = false, false
        local rem = ReplicatedStorage:FindFirstChild("Remotes")
        local mgrEv = rem and rem:FindFirstChild("MGR")
        local deepNukeDone = false

        if useReelDeepHack and REEL_TRY_FAST_REMOTE_COMPLETE and mgrEv and mgrEv:IsA("RemoteEvent") and mgrReelPendingToken ~= nil then
            task.delay(math.max(0, instantFishingDelaySec), function()
                if not fishingAutomationActive() or not isReelMinigameActive() then
                    return
                end
                local tok = mgrReelPendingToken
                if tok == nil then
                    return
                end
                pcall(function()
                    mgrEv:FireServer("Complete", tok)
                end)
            end)
        end

        local function releaseKeys()
            if eHeld then
                mancingVimKey(false, Enum.KeyCode.E)
                eHeld = false
            end
            if qHeld then
                mancingVimKey(false, Enum.KeyCode.Q)
                qHeld = false
            end
        end

        local function setE(want)
            if want == eHeld or not keysWork then
                return
            end
            if not mancingVimKey(want, Enum.KeyCode.E) then
                keysWork = false
                releaseKeys()
                return
            end
            eHeld = want
        end

        local function setQ(want)
            if want == qHeld or not keysWork then
                return
            end
            if not mancingVimKey(want, Enum.KeyCode.Q) then
                keysWork = false
                releaseKeys()
                return
            end
            qHeld = want
        end

        local t0 = os.clock()
        local rsBound = false
        if useReelDeepHack and mgrEv and mgrEv:IsA("RemoteEvent") then
            rsBound = pcall(function()
                RunService:BindToRenderStep(
                    REEL_AUTOPLAY_RS_HOOK_NAME,
                    Enum.RenderPriority.Last.Value,
                    function()
                        if not fishingAutomationActive() or not isReelMinigameActive() then
                            return
                        end
                        mancingReelDeepHackTrySetupvalueWin(mgrEv)
                        task.defer(function()
                            if fishingAutomationActive() and isReelMinigameActive() then
                                mancingReelDeepHackTrySetupvalueWin(mgrEv)
                            end
                        end)
                    end
                )
            end)
        end

        while isReelMinigameActive() and fishingAutomationActive() and os.clock() - t0 < REEL_AUTOPLAY_TIMEOUT do
            RunService.Heartbeat:Wait()
            if useReelDeepHack and mgrEv and mgrEv:IsA("RemoteEvent") then
                if not rsBound then
                    mancingReelDeepHackTrySetupvalueWin(mgrEv)
                end
                if not deepNukeDone and os.clock() - t0 > REEL_DEEP_NUKE_AFTER then
                    deepNukeDone = true
                    mancingReelDeepHackTryNukeComplete(mgrEv)
                end
            end
            local _, status, _, fill = mancingResolveReelParts()
            if fill then
                local fillScale = fill.Size.X.Scale
                if fillScale >= 0.998 then
                    break
                end
            end

            local st = mancingGetReelStatusText(status)
            local phase = mancingResolveReelPhase(st)
            if mancingReelStatusRequiresNoKnobSpin(st) then
                if string.find(st, "ULUR", 1, true) then
                    phase = "reel_out"
                else
                    phase = "idle"
                end
            end

            if phase == "idle" then
                releaseKeys()
            elseif phase == "reel_out" then
                setE(false)
                setQ(true)
            else
                setQ(false)
                setE(true)
            end
        end

        releaseKeys()
        if rsBound then
            pcall(function()
                RunService:UnbindFromRenderStep(REEL_AUTOPLAY_RS_HOOK_NAME)
            end)
        end
        mancingReelDeepHookClearCache()

        if fishingAutomationActive() and os.clock() - t0 >= REEL_AUTOPLAY_TIMEOUT and isReelMinigameActive() then
            warn(
                "[Fishing] reel autoplay timed out â€” VirtualInputManager E/Q, getconnections/debug, or MGR Complete token."
            )
        end
    end

    local function scheduleMancingReelAutoplayIfNeeded()
        if reelAutoplayLoopRunning or not fishingAutomationActive() then
            return
        end
        reelAutoplayLoopRunning = true
        task.spawn(function()
            task.wait(REEL_AUTOPLAY_START_DELAY)
            if not fishingAutomationActive() or not isReelMinigameActive() then
                reelAutoplayLoopRunning = false
                return
            end
            local ok, err = pcall(function()
                runMancingReelAutoplayLoop()
            end)
            reelAutoplayLoopRunning = false
            if not ok then
                warn("[Fishing] reel autoplay error: ", err)
            end
        end)
    end

    local function tryActivateMinigameChallengeUi()
        local area = getMinigamesMgArea()
        if not area then
            return false
        end
        local mg = area:FindFirstAncestorWhichIsA("ScreenGui")
        local hadToEnableScreenGui = false
        if mg and not mg.Enabled then
            hadToEnableScreenGui = true
            mg.Enabled = true
        end
        local anyOk = false
        local tClick = area:FindFirstChild("Click")
        local tHold = area:FindFirstChild("Hold")
        for _, ch in area:GetChildren() do
            if ch ~= tClick and ch ~= tHold and ch:IsA("GuiObject") and ch.Visible then
                if ch:IsA("GuiButton") then
                    local ok = pcall(function()
                        ch:Activate()
                    end)
                    if ok then
                        anyOk = true
                        break
                    end
                end
                local btn = ch:FindFirstChildWhichIsA("GuiButton", true)
                if btn and btn:IsA("GuiButton") and btn.Visible then
                    local ok = pcall(function()
                        btn:Activate()
                    end)
                    if ok then
                        anyOk = true
                        break
                    end
                end
            end
        end
        if not anyOk then
            for _, d in area:GetDescendants() do
                local underTemplate = (tClick ~= nil and d:IsDescendantOf(tClick)) or (tHold ~= nil and d:IsDescendantOf(tHold))
                if not underTemplate and d:IsA("GuiButton") and d.Visible then
                    local ok = pcall(function()
                        d:Activate()
                    end)
                    if ok then
                        anyOk = true
                        break
                    end
                end
            end
        end
        if hadToEnableScreenGui and mg then
            mg.Enabled = false
        end
        return anyOk
    end

    local function ensureMinigameAutoSolve()
        if minigameAutoSolveConn then
            return
        end
        local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotesFolder then
            return
        end
        local MGR = remotesFolder:FindFirstChild("MGR")
        if not (MGR and MGR:IsA("RemoteEvent")) then
            return
        end
        -- Galatama: "Start" + table { Token }; main game may use "StartReel" + table.
        minigameAutoSolveConn = MGR.OnClientEvent:Connect(function(action, a2, _a3, _a4, _a5)
            if action == "StartReel" then
                if type(a2) == "table" and a2.Token ~= nil then
                    mgrReelPendingToken = a2.Token
                end
            elseif action == "Start" then
                if type(a2) == "table" and a2.Token ~= nil then
                    mgrReelPendingToken = a2.Token
                else
                    mgrReelPendingToken = nil
                end
            elseif action == "Stop" then
                mgrReelPendingToken = nil
            end

            if not fishingAutomationActive() then
                if action == "Stop" then
                    releaseMinigameSessionWait()
                end
                return
            end
            if action == "Stop" then
                releaseMinigameSessionWait()
                return
            end
            if action == "StartReel" then
                task.defer(scheduleMancingReelAutoplayIfNeeded)
                return
            end
            if action == "Start" and type(a2) == "table" and a2.Token ~= nil then
                task.defer(scheduleMancingReelAutoplayIfNeeded)
            end
        end)
    end

    local function waitForMinigameCleared(reason)
        local t0 = os.clock()
        while
            (isFishingMinigameCircleActive() or mgrReelPendingToken ~= nil or isReelMinigameActive())
            and fishingAutomationActive()
            and os.clock() - t0 < MINIGAME_SESSION_TIMEOUT
        do
            task.wait(0.05)
        end
        if
            fishingAutomationActive()
            and os.clock() - t0 >= MINIGAME_SESSION_TIMEOUT
            and (isFishingMinigameCircleActive() or mgrReelPendingToken ~= nil or isReelMinigameActive())
        then
            warn("[Fishing] timed out waiting for minigame to end (" .. reason .. ")")
            mgrReelPendingToken = nil
        end
        if fishingAutomationActive() then
            task.wait(0.2)
        end
    end

    local function completeOrWaitMinigameBeforeCast()
        if not fishingAutomationActive() then
            return false
        end
        ensureMinigameAutoSolve()

        if mgrReelPendingToken ~= nil or isReelMinigameActive() then
            task.defer(scheduleMancingReelAutoplayIfNeeded)
            waitForMinigameCleared("reel E/Q autoplay drain")
            return true
        end

        if isFishingMinigameCircleActive() then
            task.wait(0.05)
            if not fishingAutomationActive() then
                return false
            end
            tryActivateMinigameChallengeUi()
            local tManual = os.clock()
            while isFishingMinigameCircleActive() and fishingAutomationActive() and os.clock() - tManual < 0.35 do
                task.wait(0.05)
            end
            if isFishingMinigameCircleActive() then
                waitForMinigameCleared("after UI Activate fallback")
            else
                if fishingAutomationActive() then
                    task.wait(0.2)
                end
            end
            return true
        end

        return false
    end

    local function getFishingRemotes()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then
            return nil
        end
        local equipRod = remotes:FindFirstChild("EquipRod")
        local castRod = remotes:FindFirstChild("CastRod")
        local cmgr = remotes:FindFirstChild("CMGR")
        if equipRod and castRod and cmgr then
            return equipRod, castRod, cmgr
        end
        return nil
    end

    local function playerHasFishingRodEquipped()
        local character = Players.LocalPlayer.Character
        if not character then
            return false
        end
        for _, child in character:GetChildren() do
            if child:IsA("Tool") and child:GetAttribute("FishingRod") ~= nil then
                return true
            end
        end
        return false
    end

    local function equipFishingRodRemote()
        local EquipRod = select(1, getFishingRemotes())
        if not EquipRod then
            return
        end
        pcall(function()
            EquipRod:FireServer(true, false)
        end)
    end

    local function castFishingRodRemote()
        local _, CastRod = getFishingRemotes()
        if not CastRod then
            return
        end
        pcall(function()
            CastRod:FireServer()
        end)
    end

    local function setFishingCastResultRemote()
        local _, _, CMGR = getFishingRemotes()
        if not CMGR then
            return
        end
        local resultValue = 1
        if randomCastCmgrEnabled then
            resultValue = math.random(500, 1000) / 1000
        end
        pcall(function()
            CMGR:FireServer("Result", resultValue)
        end)
    end

    local function runFishingCycleImpl(equipWait, castToCmgrWait, afterMinigameWait, afterDrainWait)
        local wantPostPreEnableDelay = autoFishDelay2sAfterPreEnableDrain
        local drainedExistingMinigame = completeOrWaitMinigameBeforeCast()
        if wantPostPreEnableDelay then
            autoFishDelay2sAfterPreEnableDrain = false
        end
        if wantPostPreEnableDelay and drainedExistingMinigame and fishingAutomationActive() then
            task.wait(afterDrainWait)
        end
        if not fishingAutomationActive() then
            return false
        end
        if not select(1, getFishingRemotes()) then
            return false
        end
        minigameCycleSeq = minigameCycleSeq + 1
        local cycleSeq = minigameCycleSeq

        if not playerHasFishingRodEquipped() then
            equipFishingRodRemote()
            task.wait(equipWait)
        end
        castFishingRodRemote()
        task.wait(castToCmgrWait)
        setFishingCastResultRemote()
        task.defer(function()
            task.wait(0.12)
            if fishingAutomationActive() and isReelMinigameActive() then
                scheduleMancingReelAutoplayIfNeeded()
            end
        end)

        local waitDone = Instance.new("BindableEvent")
        minigameSessionWait = { seq = cycleSeq, done = waitDone }
        task.delay(MINIGAME_SESSION_TIMEOUT, function()
            if minigameSessionWait and minigameSessionWait.seq == cycleSeq then
                releaseMinigameSessionWait()
            end
        end)
        waitDone.Event:Wait()
        waitDone:Destroy()

        if not fishingAutomationActive() then
            return false
        end
        task.wait(afterMinigameWait)
        return true
    end

    local function runAutoFishingCycleImpl()
        return runFishingCycleImpl(0.2, 1, 2.5, 2)
    end

    local function runAutoFishingCycle()
        local ok, res = pcall(runAutoFishingCycleImpl)
        if not ok then
            warn("[Auto fishing] cycle error: ", res)
            return false
        end
        return res
    end

    local function runAutoFishingLoop()
        while autoFishingEnabled do
            if not runAutoFishingCycle() then
                task.wait(0.5)
            end
        end
        autoFishingLoopRunning = false
    end

    local function runInstantFishingCycleImpl()
        return runFishingCycleImpl(0.12, 0.18, 2, 0.25)
    end

    local function runInstantFishingCycle()
        instantFishingCycleRunning = true
        local ok, res = pcall(runInstantFishingCycleImpl)
        instantFishingCycleRunning = false
        if not ok then
            warn("[Instant fishing] cycle error: ", res)
            return false
        end
        return res
    end

    local function runInstantFishingLoop()
        while instantFishingEnabled do
            if not runInstantFishingCycle() then
                task.wait(0.25)
            end
        end
        instantFishingLoopRunning = false
    end

    AutoFishStatusParagraph = MainTab:CreateParagraph({
        Title = "Status",
        Content = "â€¦",
    })

    RandomCastCmgrToggleAuto = MainTab:CreateToggle({
        Name = "Random Cast",
        Flag = "galatama_main_randomCastCmgr",
        CurrentValue = false,
        Callback = function(enabled)
            if randomCastCmgrSync then
                randomCastCmgrEnabled = enabled
                return
            end
            setBothRandomCastCmgrToggles(enabled, RandomCastCmgrToggleAuto)
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Fishing",
        Flag = "galatama_main_autoFishing",
        CurrentValue = false,
        Callback = function(enabled)
            autoFishingEnabled = enabled
            if enabled then
                instantFishingArmSeq = instantFishingArmSeq + 1
                instantFishingEnabled = false
                releaseMinigameSessionWait()
                ensureMinigameAutoSolve()
                autoFishDelay2sAfterPreEnableDrain = isFishingMinigameCircleActive()
                    or mgrReelPendingToken ~= nil
                    or isReelMinigameActive()
            else
                releaseMinigameSessionWait()
                autoFishDelay2sAfterPreEnableDrain = false
            end
            if not enabled then
                return
            end
            if autoFishingLoopRunning then
                return
            end
            autoFishingLoopRunning = true
            task.spawn(runAutoFishingLoop)
        end,
    })
    MainTab:CreateSection("Instant fishing")
    MainTab:CreateInput({
        Name = "Delay (seconds)",
        PlaceholderText = "e.g. 4",
        Flag = "galatama_main_instantFishingDelaySec",
        CurrentValue = tostring(instantFishingDelaySec),
        Callback = function(value)
            local n = tonumber(value)
            if n and n >= 0 then
                instantFishingDelaySec = n
            end
        end,
    })

    RandomCastCmgrToggleInstant = MainTab:CreateToggle({
        Name = "Random Cast",
        Flag = "galatama_main_randomCastCmgr",
        CurrentValue = false,
        Callback = function(enabled)
            if randomCastCmgrSync then
                randomCastCmgrEnabled = enabled
                return
            end
            setBothRandomCastCmgrToggles(enabled, RandomCastCmgrToggleInstant)
        end,
    })

    MainTab:CreateToggle({
        Name = "Instant fishing",
        Flag = "galatama_main_instantFishing",
        CurrentValue = false,
        Callback = function(enabled)
            if enabled then
                autoFishingEnabled = false
                releaseMinigameSessionWait()
                instantFishingArmSeq = instantFishingArmSeq + 1
                local armSeq = instantFishingArmSeq
                task.spawn(function()
                    ensureMinigamePreferenceIsReel()
                    task.wait(0.15)
                    if armSeq ~= instantFishingArmSeq then
                        return
                    end
                    instantFishingEnabled = true
                    ensureMinigameAutoSolve()
                    autoFishDelay2sAfterPreEnableDrain = isFishingMinigameCircleActive()
                        or mgrReelPendingToken ~= nil
                        or isReelMinigameActive()
                    if instantFishingLoopRunning then
                        return
                    end
                    instantFishingLoopRunning = true
                    runInstantFishingLoop()
                end)
            else
                instantFishingArmSeq = instantFishingArmSeq + 1
                instantFishingEnabled = false
                releaseMinigameSessionWait()
                autoFishDelay2sAfterPreEnableDrain = false
            end
        end,
    })

    task.defer(updateAutoFishStatusParagraphs)
    task.spawn(function()
        while true do
            task.wait(0.25)
            pcall(updateAutoFishStatusParagraphs)
        end
    end)

    task.defer(ensureMinigameAutoSolve)
end
-- */  Teleport Tab  /* --
do
    local TeleportTab = Window:CreateTab("Teleport", 4483362458)

    TeleportTab:CreateSection("Teleport")
    local teleportInputValue = ""
    local teleportLookInputValue = ""

    local function teleportParseNumberTriple(str)
        local s = str:gsub(",", " "):gsub("%s+", " ")
        local parts = {}
        for part in string.gmatch(s, "[%d%.%-]+") do
            table.insert(parts, tonumber(part))
        end
        return parts
    end

    local function teleportCFrameFromInputs(posStr, lookStr)
        local posParts = teleportParseNumberTriple(posStr)
        if #posParts < 3 then
            return nil
        end
        local pos = Vector3.new(posParts[1], posParts[2], posParts[3])
        local lookParts = teleportParseNumberTriple(lookStr)
        if #lookParts < 3 then
            return CFrame.new(pos)
        end
        local dir = Vector3.new(lookParts[1], lookParts[2], lookParts[3])
        if dir.Magnitude < 1e-5 then
            return CFrame.new(pos)
        end
        return CFrame.lookAt(pos, pos + dir.Unit)
    end

    local TeleportInput = TeleportTab:CreateInput({
        Name = "Location",
        PlaceholderText = "e.g. 100, 5, 200 or 100 5 200",
        Flag = "galatama_tp_location",
        CurrentValue = teleportInputValue,
        Callback = function(value)
            teleportInputValue = value
        end,
    })

    local TeleportLookInput = TeleportTab:CreateInput({
        Name = "Look direction",
        PlaceholderText = "e.g. 0, 0, -1 or leave empty for position only",
        Flag = "galatama_tp_lookDirection",
        CurrentValue = teleportLookInputValue,
        Callback = function(value)
            teleportLookInputValue = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Get Current Location",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
                return
            end
            local pos = rootPart.Position
            local text = string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
            teleportInputValue = text
            if TeleportInput and TeleportInput.Set then
                TeleportInput:Set(text)
            elseif TeleportInput and TeleportInput.SetValue then
                TeleportInput:SetValue(text)
            end
            local look = rootPart.CFrame.LookVector
            local lookText = string.format("%.4f, %.4f, %.4f", look.X, look.Y, look.Z)
            teleportLookInputValue = lookText
            if TeleportLookInput and TeleportLookInput.Set then
                TeleportLookInput:Set(lookText)
            elseif TeleportLookInput and TeleportLookInput.SetValue then
                TeleportLookInput:SetValue(lookText)
            end
            mountNotify({
                Title = "Location",
                Content = "Position: " .. text .. " Â· Look: " .. lookText,
            })
        end,
    })
    TeleportTab:CreateButton({
        Name = "Teleport",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
                return
            end
            local cf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not cf then
                mountNotify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                })
                return
            end
            rootPart.CFrame = cf
            local p = cf.Position
            mountNotify({
                Title = "Teleport",
                Content = string.format("Teleported to %.1f, %.1f, %.1f", p.X, p.Y, p.Z),
            })
        end,
    })
    local tweenDurationValue = "5"
    TeleportTab:CreateInput({
        Name = "Tween Duration",
        PlaceholderText = "e.g. 5",
        Flag = "galatama_tp_tweenDurationSec",
        CurrentValue = tweenDurationValue,
        Callback = function(value)
            tweenDurationValue = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Tween to Location",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
                return
            end
            local targetCf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not targetCf then
                mountNotify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                })
                return
            end
            local duration = tonumber(tweenDurationValue) or 5
            if duration < 0.1 then duration = 0.1 end
            local tweenInfo = TweenInfo.new(duration)
            local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = targetCf })
            tween:Play()
            local p = targetCf.Position
            mountNotify({
                Title = "Teleport",
                Content = string.format("Tweening to %.1f, %.1f, %.1f (%.1fs)", p.X, p.Y, p.Z, duration),
            })
        end,
    })

    -- */  Teleport to Players  /* --
    TeleportTab:CreateSection("Teleport to Players")
    local playerDisplayNames = {}
    local playerList = {}
    local selectedTeleportPlayer = nil
    local PlayerTeleportDropdown

    local function refreshPlayerList(showNotify)
        playerList = {}
        playerDisplayNames = {}
        local localPlayer = Players.LocalPlayer
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.ClassName == "Player" then
                table.insert(playerList, player)
                table.insert(playerDisplayNames, player.DisplayName or player.Name)
            end
        end
        if PlayerTeleportDropdown and PlayerTeleportDropdown.Refresh then
            PlayerTeleportDropdown:Refresh(playerDisplayNames)
        end
        if selectedTeleportPlayer then
            if not table.find(playerList, selectedTeleportPlayer) then
                selectedTeleportPlayer = nil
                if PlayerTeleportDropdown and PlayerTeleportDropdown.Select then PlayerTeleportDropdown:Select(nil) end
                if PlayerTeleportDropdown and PlayerTeleportDropdown.Set then PlayerTeleportDropdown:Set({}) end
            end
        end
        if showNotify then
            mountNotify({ Title = "Teleport", Content = "Player list refreshed (" .. #playerList .. " players)" })
        end
    end

    PlayerTeleportDropdown = TeleportTab:CreateDropdown({
        Name = "Player",
        Flag = "galatama_tp_playerPick",
        Options = playerDisplayNames,
        CurrentOption = {},
        Callback = function(opts)
            local value = rayfieldDropdownFirst(opts)
            selectedTeleportPlayer = nil
            if value then
                local idx = table.find(playerDisplayNames, value)
                if idx and playerList[idx] then
                    selectedTeleportPlayer = playerList[idx]
                end
            end
        end
    })

    TeleportTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshPlayerList(true)
        end
    })
    TeleportTab:CreateButton({
        Name = "Teleport",
        Callback = function()
            if not selectedTeleportPlayer then
                mountNotify({ Title = "Teleport", Content = "Select a player first" })
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
                return
            end
            local targetChar = selectedTeleportPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then
                mountNotify({ Title = "Teleport", Content = "Target player has no character" })
                return
            end
            rootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0, 3))
            mountNotify({ Title = "Teleport", Content = "Teleported to " .. (selectedTeleportPlayer.DisplayName or selectedTeleportPlayer.Name) })
        end
    })
end

-- */  Objects Tab  /* --
do
    local ObjectsTab = Window:CreateTab("Objects", 4483362458)

    -- Nested tree only under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (recursive); other instances are one line.
    local OBJECTS_TREE_MAX_DEPTH = 14
    local OBJECTS_TREE_MAX_LINES = 600

    local function shouldNestChildrenInObjectsTree(inst: Instance): boolean
        return inst:IsA("Folder")
            or inst:IsA("Backpack")
            or inst:IsA("StarterGear")
            or inst:IsA("PlayerGui")
            or inst:IsA("ScreenGui")
            or inst:IsA("Frame")
    end

    local function buildNestedObjectChildrenListText(root: Instance): string
        local lines = {}

        local function appendChildren(parent: Instance, depth: number, indentStr: string)
            if #lines >= OBJECTS_TREE_MAX_LINES or depth >= OBJECTS_TREE_MAX_DEPTH then
                return
            end
            local children = parent:GetChildren()
            table.sort(children, function(a, b)
                return string.lower(a.Name) < string.lower(b.Name)
            end)
            for _, child in ipairs(children) do
                if #lines >= OBJECTS_TREE_MAX_LINES then
                    table.insert(lines, indentStr .. "... (truncated, max " .. OBJECTS_TREE_MAX_LINES .. " lines)")
                    return
                end
                table.insert(lines, indentStr .. formatInstanceDisplay(child, nil, true))
                local sub = child:GetChildren()
                if #sub > 0 and shouldNestChildrenInObjectsTree(child) then
                    if depth + 1 < OBJECTS_TREE_MAX_DEPTH then
                        appendChildren(child, depth + 1, indentStr .. "  ")
                    else
                        table.insert(lines, indentStr .. "  ... (" .. #sub .. " children, max depth " .. OBJECTS_TREE_MAX_DEPTH .. ")")
                    end
                end
            end
        end

        appendChildren(root, 0, "")
        if #lines == 0 then
            return "(no children)"
        end
        return table.concat(lines, "\n")
    end

    ObjectsTab:CreateSection("ReplicatedStorage")
    local rsDisplayList = {}
    local rsKeyValueList = {}
    local ReplicatedStorageDropdown
    local ReplicatedStorageChildrenParagraph

    local function refreshReplicatedStorageList()
        rsDisplayList = {}
        rsKeyValueList = {}
        for _, child in ipairs(ReplicatedStorage:GetChildren()) do
            local display = formatInstanceDisplay(child, nil, true)
            table.insert(rsDisplayList, display)
            rsKeyValueList[display] = { key = child.Name, value = child.ClassName, instance = child }
        end
        if ReplicatedStorageDropdown and ReplicatedStorageDropdown.Refresh then
            ReplicatedStorageDropdown:Refresh(rsDisplayList)
        end
        mountNotify({ Title = "ReplicatedStorage", Content = "Listed " .. #rsDisplayList .. " objects" })
    end

    ReplicatedStorageDropdown = ObjectsTab:CreateDropdown({
        Name = "ReplicatedStorage (key = value)",
        Options = rsDisplayList,
        CurrentOption = {},
        Search = true,
        Callback = function(selectedDisplay)
            selectedDisplay = rayfieldDropdownFirst(selectedDisplay)
            if not selectedDisplay then
                if ReplicatedStorageChildrenParagraph and ReplicatedStorageChildrenParagraph.Set then
                    ReplicatedStorageChildrenParagraph:Set({ Title = "Children (nested)", Content = "Select an object above to list its children" })
                end
                return
            end
            local entry = rsKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local text = buildNestedObjectChildrenListText(entry.instance)
            if ReplicatedStorageChildrenParagraph and ReplicatedStorageChildrenParagraph.Set then
                ReplicatedStorageChildrenParagraph:Set({ Title = "Children (nested)", Content = text })
            end
        end
    })

    ReplicatedStorageChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = "Children (nested)",
        Content = "Nested under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (name sort; max depth " .. OBJECTS_TREE_MAX_DEPTH .. ", max " .. OBJECTS_TREE_MAX_LINES .. " lines)",
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshReplicatedStorageList()
        end
    })
    ObjectsTab:CreateSection("Players")
    local plrsDisplayList = {}
    local plrsKeyValueList = {}
    local PlayersServiceDropdown
    local PlayersServiceChildrenParagraph

    local function refreshPlayersServiceList()
        plrsDisplayList = {}
        plrsKeyValueList = {}
        for _, child in ipairs(Players:GetChildren()) do
            local display = formatInstanceDisplay(child, nil, true)
            table.insert(plrsDisplayList, display)
            plrsKeyValueList[display] = { key = child.Name, value = child.ClassName, instance = child }
        end
        if PlayersServiceDropdown and PlayersServiceDropdown.Refresh then
            PlayersServiceDropdown:Refresh(plrsDisplayList)
        end
        mountNotify({ Title = "Players", Content = "Listed " .. #plrsDisplayList .. " players" })
    end

    PlayersServiceDropdown = ObjectsTab:CreateDropdown({
        Name = "Players (key = value)",
        Options = plrsDisplayList,
        CurrentOption = {},
        Search = true,
        Callback = function(selectedDisplay)
            selectedDisplay = rayfieldDropdownFirst(selectedDisplay)
            if not selectedDisplay then
                if PlayersServiceChildrenParagraph and PlayersServiceChildrenParagraph.Set then
                    PlayersServiceChildrenParagraph:Set({ Title = "Children (nested)", Content = "Select a player above to list their children" })
                end
                return
            end
            local entry = plrsKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local text = buildNestedObjectChildrenListText(entry.instance)
            if PlayersServiceChildrenParagraph and PlayersServiceChildrenParagraph.Set then
                PlayersServiceChildrenParagraph:Set({ Title = "Children (nested)", Content = text })
            end
        end
    })

    PlayersServiceChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = "Children (nested)",
        Content = "Nested under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (name sort; max depth " .. OBJECTS_TREE_MAX_DEPTH .. ", max " .. OBJECTS_TREE_MAX_LINES .. " lines)",
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshPlayersServiceList()
        end
    })
    ObjectsTab:CreateSection("Local Player")
    local lpDisplayList = {}
    local lpKeyValueList = {}
    local LocalPlayerDropdown
    local LocalPlayerChildrenParagraph

    local function refreshLocalPlayerList()
        lpDisplayList = {}
        lpKeyValueList = {}
        local localPlayer = Players.LocalPlayer
        for _, child in ipairs(localPlayer:GetChildren()) do
            local display = formatInstanceDisplay(child, nil, true)
            table.insert(lpDisplayList, display)
            lpKeyValueList[display] = { key = child.Name, value = child.ClassName, instance = child }
        end
        if LocalPlayerDropdown and LocalPlayerDropdown.Refresh then
            LocalPlayerDropdown:Refresh(lpDisplayList)
        end
        mountNotify({ Title = "Local Player", Content = "Listed " .. #lpDisplayList .. " objects" })
    end

    LocalPlayerDropdown = ObjectsTab:CreateDropdown({
        Name = "Local Player (key = value)",
        Options = lpDisplayList,
        CurrentOption = {},
        Search = true,
        Callback = function(selectedDisplay)
            selectedDisplay = rayfieldDropdownFirst(selectedDisplay)
            if not selectedDisplay then
                if LocalPlayerChildrenParagraph and LocalPlayerChildrenParagraph.Set then
                    LocalPlayerChildrenParagraph:Set({ Title = "Children (nested)", Content = "Select an object above to list its children" })
                end
                return
            end
            local entry = lpKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local text = buildNestedObjectChildrenListText(entry.instance)
            if LocalPlayerChildrenParagraph and LocalPlayerChildrenParagraph.Set then
                LocalPlayerChildrenParagraph:Set({ Title = "Children (nested)", Content = text })
            end
        end
    })

    LocalPlayerChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = "Children (nested)",
        Content = "Nested under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (name sort; max depth " .. OBJECTS_TREE_MAX_DEPTH .. ", max " .. OBJECTS_TREE_MAX_LINES .. " lines)",
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshLocalPlayerList()
        end
    })
    ObjectsTab:CreateSection("Workspace")
    local wsDisplayList = {}
    local wsKeyValueList = {}
    local WorkspaceDropdown
    local WorkspaceChildrenParagraph

    local function refreshWorkspaceList()
        wsDisplayList = {}
        wsKeyValueList = {}
        for _, child in ipairs(Workspace:GetChildren()) do
            local display = formatInstanceDisplay(child, nil, true)
            table.insert(wsDisplayList, display)
            wsKeyValueList[display] = { key = child.Name, value = child.ClassName, instance = child }
        end
        if WorkspaceDropdown and WorkspaceDropdown.Refresh then
            WorkspaceDropdown:Refresh(wsDisplayList)
        end
        mountNotify({ Title = "Workspace", Content = "Listed " .. #wsDisplayList .. " objects" })
    end

    WorkspaceDropdown = ObjectsTab:CreateDropdown({
        Name = "Workspace (key = value)",
        Options = wsDisplayList,
        CurrentOption = {},
        Search = true,
        Callback = function(selectedDisplay)
            selectedDisplay = rayfieldDropdownFirst(selectedDisplay)
            if not selectedDisplay then
                if WorkspaceChildrenParagraph and WorkspaceChildrenParagraph.Set then
                    WorkspaceChildrenParagraph:Set({ Title = "Children (nested)", Content = "Select an object above to list its children" })
                end
                return
            end
            local entry = wsKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local text = buildNestedObjectChildrenListText(entry.instance)
            if WorkspaceChildrenParagraph and WorkspaceChildrenParagraph.Set then
                WorkspaceChildrenParagraph:Set({ Title = "Children (nested)", Content = text })
            end
        end
    })

    WorkspaceChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = "Children (nested)",
        Content = "Nested under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (name sort; max depth " .. OBJECTS_TREE_MAX_DEPTH .. ", max " .. OBJECTS_TREE_MAX_LINES .. " lines)",
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshWorkspaceList()
        end
    })

end

-- */  Config Tab  /* --
do
    local ConfigTab = Window:CreateTab("Config", 4483362458)

    ConfigTab:CreateSection("Config management")
    local CONFIG_DIR = "sempatpanick/mancing_indo_galatama"
    local configMgmtName = ""
    local savedConfigList = {}
    local selectedSavedConfigName = nil
    local SavedConfigsDropdown
    local ConfigNameInput
    local autoLoadPickerSelection = nil
    local AutoLoadSavedDropdown
    local CONFIG_SEQ_FLAG_AUTO_FISH = "galatama_main_autoFishing"
    local CONFIG_SEQ_FLAG_INSTANT_FISH = "galatama_main_instantFishing"

    local function sanitizeConfigName(raw)
        local s = tostring(raw or ""):gsub("^%s+", ""):gsub("%s+$", "")
        s = s:gsub("[/\\]", "")
        return s
    end

    local function ensureConfigFolder()
        if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(CONFIG_DIR) then
            pcall(function()
                makefolder("sempatpanick")
            end)
            pcall(function()
                makefolder(CONFIG_DIR)
            end)
        end
    end

    local function profilePath(name)
        return CONFIG_DIR .. "/" .. sanitizeConfigName(name) .. ".json"
    end

    local function encodeColor3(c)
        return {
            __type = "Color3",
            R = math.floor(c.R * 255 + 0.5),
            G = math.floor(c.G * 255 + 0.5),
            B = math.floor(c.B * 255 + 0.5),
        }
    end

    local function decodeColor3(v)
        if type(v) == "table" and v.__type == "Color3" then
            return Color3.fromRGB(tonumber(v.R) or 255, tonumber(v.G) or 255, tonumber(v.B) or 255)
        end
        return nil
    end

    local function collectCurrentConfigData()
        local data = {}
        for flagName, flagObj in pairs(RayfieldLibrary.Flags or {}) do
            local value
            if flagObj.Type == "ColorPicker" and flagObj.Color then
                value = encodeColor3(flagObj.Color)
            else
                value = flagObj.CurrentValue
                if value == nil then value = flagObj.CurrentKeybind end
                if value == nil then value = flagObj.CurrentOption end
                if value == nil then value = flagObj.Color end
                if typeof(value) == "Color3" then
                    value = encodeColor3(value)
                end
            end
            data[flagName] = value
        end
        return data
    end

    local function applyConfigData(data)
        if type(data) ~= "table" then
            return false
        end
        local seqOrder = {
            CONFIG_SEQ_FLAG_AUTO_FISH,
            CONFIG_SEQ_FLAG_INSTANT_FISH,
        }
        local seqSet = {}
        for _, f in ipairs(seqOrder) do
            seqSet[f] = true
        end

        local function applyFlag(flagName)
            local flagObj = RayfieldLibrary.Flags and RayfieldLibrary.Flags[flagName]
            if not flagObj or type(flagObj.Set) ~= "function" then
                return
            end
            local saved = data[flagName]
            if saved == nil then
                return
            end
            local c = decodeColor3(saved)
            pcall(function()
                flagObj:Set(c or saved)
            end)
        end

        for flagName, _ in pairs(data) do
            if not seqSet[flagName] then
                applyFlag(flagName)
            end
        end
        for _, flagName in ipairs(seqOrder) do
            applyFlag(flagName)
        end
        return true
    end

    local function listProfiles()
        local names = {}
        if type(listfiles) ~= "function" then
            return names
        end
        ensureConfigFolder()
        local ok, files = pcall(function()
            return listfiles(CONFIG_DIR)
        end)
        if not ok or type(files) ~= "table" then
            return names
        end
        for _, filePath in ipairs(files) do
            local normalized = tostring(filePath):gsub("\\", "/")
            local base = normalized:match("([^/]+)$")
            if base and base:sub(-5) == ".json" and base ~= "mancing_indo_galatama_autoload.json" then
                table.insert(names, base:sub(1, -6))
            end
        end
        table.sort(names)
        return names
    end

    local function createConfigObject(name)
        local trimmed = sanitizeConfigName(name)
        return {
            Save = function()
                ensureConfigFolder()
                if type(writefile) ~= "function" then
                    error("writefile is not available")
                end
                writefile(profilePath(trimmed), HttpService:JSONEncode(collectCurrentConfigData()))
            end,
            Load = function()
                if type(isfile) ~= "function" or type(readfile) ~= "function" then
                    return false, "Config system unavailable (missing file APIs)"
                end
                local path = profilePath(trimmed)
                if not isfile(path) then
                    return false, "Config file not found or invalid"
                end
                local okRead, rawOrErr = pcall(function()
                    return readfile(path)
                end)
                if not okRead then
                    return false, tostring(rawOrErr)
                end
                local okDecode, decoded = pcall(function()
                    return HttpService:JSONDecode(rawOrErr)
                end)
                if not okDecode then
                    return false, "Config file not found or invalid"
                end
                applyConfigData(decoded)
                return true
            end,
        }
    end

    local function getConfigManager()
        if type(writefile) ~= "function" and type(readfile) ~= "function" then
            return nil
        end
        ensureConfigFolder()
        return {
            Path = CONFIG_DIR .. "/",
            AllConfigs = function()
                return listProfiles()
            end,
            GetConfig = function(_, _)
                return nil
            end,
            Config = function(_, name, _)
                return createConfigObject(name)
            end,
            DeleteConfig = function(_, name)
                if type(delfile) ~= "function" or type(isfile) ~= "function" then
                    return false, "Delete is unavailable (missing file APIs)"
                end
                local path = profilePath(name)
                if not isfile(path) then
                    return false, "Config file not found"
                end
                local ok, err = pcall(function()
                    delfile(path)
                end)
                if not ok then
                    return false, tostring(err)
                end
                return true, "Deleted \"" .. sanitizeConfigName(name) .. "\""
            end,
        }
    end

    local function autoLoadMetaPath(cm)
        return (cm.Path or "") .. "mancing_indo_galatama_autoload.json"
    end

    local function readAutoLoadPersistedName()
        local cm = getConfigManager()
        if not cm or type(isfile) ~= "function" or type(readfile) ~= "function" then
            return ""
        end
        local path = autoLoadMetaPath(cm)
        if not isfile(path) then
            return ""
        end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if ok and type(data) == "table" then
            return sanitizeConfigName(tostring(data.name or data.profile or ""))
        end
        return ""
    end

    local function writeAutoLoadPersistedName(name)
        local cm = getConfigManager()
        if not cm or type(writefile) ~= "function" then
            return false
        end
        local path = autoLoadMetaPath(cm)
        local trimmed = sanitizeConfigName(name)
        if trimmed == "" then
            if type(delfile) == "function" and type(isfile) == "function" and isfile(path) then
                pcall(function()
                    delfile(path)
                end)
            end
            return true
        end
        local ok = pcall(function()
            writefile(path, HttpService:JSONEncode({ name = trimmed }))
        end)
        return ok
    end

    local function refreshSavedConfigDropdowns(showNotify)
        local cm = getConfigManager()
        if not cm then
            if showNotify then
                mountNotify({
                    Title = "Config",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                })
            end
            return
        end
        savedConfigList = cm:AllConfigs() or {}
        table.sort(savedConfigList)
        if SavedConfigsDropdown and SavedConfigsDropdown.Refresh then
            SavedConfigsDropdown:Refresh(savedConfigList)
        end
        if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Refresh then
            AutoLoadSavedDropdown:Refresh(savedConfigList)
        end
        if autoLoadPickerSelection and not table.find(savedConfigList, autoLoadPickerSelection) then
            autoLoadPickerSelection = nil
            if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Select then
                AutoLoadSavedDropdown:Select(nil)
            end
            if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Set then
                AutoLoadSavedDropdown:Set({})
            end
        end
        if selectedSavedConfigName and not table.find(savedConfigList, selectedSavedConfigName) then
            selectedSavedConfigName = nil
            if SavedConfigsDropdown and SavedConfigsDropdown.Select then
                SavedConfigsDropdown:Select(nil)
            end
            if SavedConfigsDropdown and SavedConfigsDropdown.Set then
                SavedConfigsDropdown:Set({})
            end
        end
        if showNotify then
            mountNotify({
                Title = "Config",
                Content = "Found " .. tostring(#savedConfigList) .. " saved profile(s).",
            })
        end
    end

    local function syncPersistedAutoLoadToUi()
        if not AutoLoadSavedDropdown then
            return
        end
        local persisted = readAutoLoadPersistedName()
        if persisted == "" or not table.find(savedConfigList, persisted) then
            return
        end
        autoLoadPickerSelection = persisted
        if AutoLoadSavedDropdown.Set then
            AutoLoadSavedDropdown:Set({ persisted })
        elseif AutoLoadSavedDropdown.Select then
            AutoLoadSavedDropdown:Select(persisted)
        end
    end

    local function runStartupAutoLoadProfile()
        local cm = getConfigManager()
        if not cm or type(isfile) ~= "function" then
            return
        end
        local name = readAutoLoadPersistedName()
        if name == "" then
            return
        end
        if not isfile(cm.Path .. name .. ".json") then
            return
        end
        local cfg = createConfigObject(name)
        local pok, loadResult, loadErr = pcall(function()
            return cfg:Load()
        end)
        if not pok then
            warn("[Mancing Indo Galatama] Auto-load failed: ", loadResult)
            return
        end
        if loadResult == false then
            warn("[Mancing Indo Galatama] Auto-load: ", loadErr)
            return
        end
        mountNotify({
            Title = "Config",
            Content = "Auto-loaded \"" .. name .. "\"",
        })
    end

    ConfigNameInput = ConfigTab:CreateInput({
        Name = "Config name",
        PlaceholderText = "e.g. main or pvp",
        CurrentValue = configMgmtName,
        Callback = function(value)
            configMgmtName = sanitizeConfigName(value)
        end,
    })

    SavedConfigsDropdown = ConfigTab:CreateDropdown({
        Name = "Config Saved",
        Options = savedConfigList,
        CurrentOption = {},
        Search = true,
        Callback = function(opts)
            local value = rayfieldDropdownFirst(opts)
            selectedSavedConfigName = (value and value ~= "") and value or nil
            if value and value ~= "" then
                configMgmtName = sanitizeConfigName(value)
                if ConfigNameInput and ConfigNameInput.Set then
                    ConfigNameInput:Set(configMgmtName)
                elseif ConfigNameInput and ConfigNameInput.SetValue then
                    ConfigNameInput:SetValue(configMgmtName)
                end
            end
        end,
    })

    ConfigTab:CreateButton({
        Name = "Refresh Config",
        Callback = function()
            refreshSavedConfigDropdowns(true)
        end,
    })
    ConfigTab:CreateButton({
        Name = "Save Config",
        Callback = function()
            local cm = getConfigManager()
            if not cm then
                mountNotify({
                    Title = "Config",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                })
                return
            end
            local name = sanitizeConfigName(configMgmtName)
            if name == "" then
                mountNotify({ Title = "Config", Content = "Enter a config name first" })
                return
            end
            local cfg = createConfigObject(name)
            local cfgPath = cm.Path .. name .. ".json"
            if type(isfile) == "function" and isfile(cfgPath) and type(delfile) == "function" then
                pcall(function()
                    delfile(cfgPath)
                end)
            end
            local ok, err = pcall(function()
                cfg:Save()
            end)
            if not ok then
                mountNotify({ Title = "Config", Content = "Save failed: " .. tostring(err) })
                return
            end
            refreshSavedConfigDropdowns(false)
            mountNotify({ Title = "Config", Content = "Saved \"" .. name .. "\"" })
        end,
    })

    ConfigTab:CreateButton({
        Name = "Load Config",
        Callback = function()
            local cm = getConfigManager()
            if not cm then
                mountNotify({
                    Title = "Config",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                })
                return
            end
            local name = sanitizeConfigName(configMgmtName)
            if name == "" then
                mountNotify({ Title = "Config", Content = "Enter or select a config name first" })
                return
            end
            local cfg = createConfigObject(name)
            local pok, loadResult, loadErr = pcall(function()
                return cfg:Load()
            end)
            if not pok then
                mountNotify({ Title = "Config", Content = "Load failed: " .. tostring(loadResult) })
                return
            end
            if loadResult == false then
                mountNotify({
                    Title = "Config",
                    Content = type(loadErr) == "string" and loadErr or "Config file not found or invalid",
                })
                return
            end
            mountNotify({ Title = "Config", Content = "Loaded \"" .. name .. "\"" })
        end,
    })
    ConfigTab:CreateButton({
        Name = "Delete Config",
        Callback = function()
            local cm = getConfigManager()
            if not cm then
                mountNotify({
                    Title = "Config",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                })
                return
            end
            if not selectedSavedConfigName or selectedSavedConfigName == "" then
                mountNotify({
                    Title = "Config",
                    Content = "Select a config to delete",
                })
                return
            end
            local name = sanitizeConfigName(selectedSavedConfigName)
            if name == "" then
                mountNotify({
                    Title = "Config",
                    Content = "Select a config to delete",
                })
                return
            end
            local okDel, msg = cm:DeleteConfig(name)
            refreshSavedConfigDropdowns(false)
            if okDel then
                if readAutoLoadPersistedName() == name then
                    writeAutoLoadPersistedName("")
                    autoLoadPickerSelection = nil
                    if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Select then
                        AutoLoadSavedDropdown:Select(nil)
                    end
                    if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Set then
                        AutoLoadSavedDropdown:Set({})
                    end
                end
                selectedSavedConfigName = nil
                if SavedConfigsDropdown and SavedConfigsDropdown.Select then
                    SavedConfigsDropdown:Select(nil)
                end
                if SavedConfigsDropdown and SavedConfigsDropdown.Set then
                    SavedConfigsDropdown:Set({})
                end
                if sanitizeConfigName(configMgmtName) == name then
                    configMgmtName = ""
                    if ConfigNameInput and ConfigNameInput.Set then
                        ConfigNameInput:Set("")
                    elseif ConfigNameInput and ConfigNameInput.SetValue then
                        ConfigNameInput:SetValue("")
                    end
                end
                mountNotify({
                    Title = "Config",
                    Content = type(msg) == "string" and msg or ("Deleted \"" .. name .. "\""),
                })
            else
                mountNotify({
                    Title = "Config",
                    Content = type(msg) == "string" and msg or "Delete failed",
                })
            end
        end,
    })
    ConfigTab:CreateSection("Auto Load")
    AutoLoadSavedDropdown = ConfigTab:CreateDropdown({
        Name = "Config Saved",
        Options = savedConfigList,
        CurrentOption = {},
        Search = true,
        Callback = function(opts)
            local value = rayfieldDropdownFirst(opts)
            autoLoadPickerSelection = (value and value ~= "") and value or nil
        end,
    })
    ConfigTab:CreateButton({
        Name = "Set",
        Callback = function()
            if not autoLoadPickerSelection or autoLoadPickerSelection == "" then
                mountNotify({
                    Title = "Auto Load",
                    Content = "Select a config in Config Saved first",
                })
                return
            end
            local cm = getConfigManager()
            if not cm then
                mountNotify({
                    Title = "Auto Load",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                })
                return
            end
            local pick = sanitizeConfigName(autoLoadPickerSelection)
            if pick == "" or not table.find(savedConfigList, pick) then
                mountNotify({
                    Title = "Auto Load",
                    Content = "Selected profile is not in the list (try Refresh Config)",
                })
                return
            end
            if not isfile or not isfile(cm.Path .. pick .. ".json") then
                mountNotify({
                    Title = "Auto Load",
                    Content = "That config file is not on disk yet (Save Config first)",
                })
                return
            end
            if not writeAutoLoadPersistedName(pick) then
                mountNotify({ Title = "Auto Load", Content = "Failed to write autoload file" })
                return
            end
            mountNotify({
                Title = "Auto Load",
                Content = "Next run will load \"" .. pick .. "\"",
            })
        end,
    })
    ConfigTab:CreateButton({
        Name = "Reset",
        Callback = function()
            writeAutoLoadPersistedName("")
            autoLoadPickerSelection = nil
            if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Select then
                AutoLoadSavedDropdown:Select(nil)
            end
            if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Set then
                AutoLoadSavedDropdown:Set({})
            end
            mountNotify({
                Title = "Auto Load",
                Content = "Auto-load on startup disabled",
            })
        end,
    })

    refreshSavedConfigDropdowns(false)
    syncPersistedAutoLoadToUi()

    task.defer(function()
        task.wait(0.45)
        runStartupAutoLoadProfile()
    end)
end
