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

local function rayfieldDropdownFirst(valueOrTable)
    if type(valueOrTable) == "table" then
        return valueOrTable[1]
    end
    return valueOrTable
end

local function clearRayfieldDropdown(dropdown)
    if not dropdown then
        return
    end
    if dropdown.Set then
        local ok = pcall(function()
            dropdown:Set({})
        end)
        if ok then
            return
        end
    end
    if type(dropdown.CurrentOption) == "table" then
        table.clear(dropdown.CurrentOption)
    end
end

-- */  Window  /* --
local Window = RayfieldLibrary:CreateWindow({
    Name = "sempatpanick | Slime RNG",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Slime RNG",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "sempatpanick",
        FileName = "slime_rng",
    },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
})

-- */  Window  /* --
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
        Flag = "lp_anti_afk",
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
        Flag = "lp_infinite_jump",
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
        Flag = "lp_no_clip",
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
        Flag = "lp_fly",
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
        Flag = "lp_free_camera",
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
        Flag = "lp_camera_penetrate",
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
    local walkSpeedValue = tostring(currentWalkSpeed or defaultWalkSpeed)

    local WalkSpeedInput = LocalPlayerTab:CreateInput({
        Name = "Speed",
        PlaceholderText = "e.g. 16 or 100",
        Flag = "lp_walk_speed",
        CurrentValue = walkSpeedValue,
        Callback = function(value)
            walkSpeedValue = value
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
        Flag = "lp_walk_speed_get",
        Callback = function()
            syncWalkSpeedInputFromCharacter(true)
        end
    })

    -- Keep the input defaulted to current character speed when available.
    syncWalkSpeedInputFromCharacter(false)
    LocalPlayerTab:CreateButton({
        Name = "Apply",
        Flag = "lp_walk_speed_apply",
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
        Flag = "lp_walk_speed_reset",
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
        Flag = "lp_jump_height",
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
        Flag = "lp_jump_height_get",
        Callback = function()
            syncJumpHeightInputFromCharacter(true)
        end
    })

    -- Keep the input defaulted to current character jump height when available.
    syncJumpHeightInputFromCharacter(false)
    LocalPlayerTab:CreateButton({
        Name = "Apply",
        Flag = "lp_jump_height_apply",
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

    LocalPlayerTab:CreateInput({
        Name = "ESP Max Distance",
        PlaceholderText = "0 = unlimited, e.g. 10000",
        Flag = "lp_esp_max_distance",
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

    LocalPlayerTab:CreateToggle({
        Name = "ESP Player Names",
        Flag = "lp_esp_player_names",
        CurrentValue = false,
        Callback = function(enabled)
            espNamesEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })
    LocalPlayerTab:CreateToggle({
        Name = "ESP Player Distance",
        Flag = "lp_esp_player_distance",
        CurrentValue = false,
        Callback = function(enabled)
            espDistanceEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })
    LocalPlayerTab:CreateToggle({
        Name = "ESP Player Character",
        Flag = "lp_esp_player_character",
        CurrentValue = false,
        Callback = function(enabled)
            espCharacterEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })
    LocalPlayerTab:CreateToggle({
        Name = "ESP Player Lines",
        Flag = "lp_esp_player_lines",
        CurrentValue = false,
        Callback = function(enabled)
            espLinesEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })
    LocalPlayerTab:CreateToggle({
        Name = "ESP All Object",
        Flag = "lp_esp_all_objects",
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
        table.insert(lines, "Player attributes:")
        if player.Parent then
            local attrs = player:GetAttributes()
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
            table.insert(lines, "  (player left)")
        end
        table.insert(lines, "")
        table.insert(lines, "Player properties:")
        if player.Parent then
            local propRows = {}
            for _, propName in ipairs(getReadablePropertyNames(player, PLAYER_INSPECT_PROPERTIES_FALLBACK)) do
                local ok, val = pcall(function()
                    return player[propName]
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
            table.insert(lines, "  (player left)")
        end
        local character = player.Character
        if not character then
            table.insert(lines, "Character: not loaded")
            table.insert(lines, "Location: —")
            table.insert(lines, "")
            table.insert(lines, "Humanoid properties: —")
            table.insert(lines, "Inside Humanoid (children): —")
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
        if PlayersInfoParagraph and PlayersInfoParagraph.Set then
            PlayersInfoParagraph:Set({
                Title = "Details",
                Content = buildPlayersInfoText(selectedInfoPlayer),
            })
        end
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
        Flag = "lp_players_info_player",
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
    })

    PlayersInfoParagraph = LocalPlayerTab:CreateParagraph({
        Title = "Details",
        Content = "Select a player from the list.",
    })

    LocalPlayerTab:CreateButton({
        Name = "Refresh list",
        Flag = "lp_players_info_refresh_list",
        Callback = function()
            refreshPlayersInfoList(true)
        end,
    })
    LocalPlayerTab:CreateButton({
        Name = "Refresh details",
        Flag = "lp_players_info_refresh_details",
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
        Flag = "lp_carry_player",
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
        Flag = "lp_carry_nearby",
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
                                    -- Keep target close to the local player's side while toggle is enabled.
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
        Flag = "lp_server_rejoin",
        Callback = function()
            local TeleportService = game:GetService("TeleportService")
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
        Flag = "lp_server_copy_placeid",
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
    LocalPlayerTab:CreateDropdown({
        Name = "Animation list",
        Flag = "lp_animation_list",
        Options = animationOptions,
        CurrentOption = { selectedAnimationName },
        Search = false,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            if picked then selectedAnimationName = picked end
        end,
    })
    LocalPlayerTab:CreateButton({
        Name = "Animate",
        Flag = "lp_animation_play",
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
        Flag = "lp_console_clear",
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

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", 4483362458)

    MainTab:CreateSection("Auto Collect Loot")

    local function mainTryProximityInteractOnInstance(root: Instance)
        local prompt = root:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not prompt then
            return
        end
        local usedFire = false
        pcall(function()
            local fp = rawget(_G, "fireproximityprompt")
            if type(fp) ~= "function" then
                local ge = rawget(_G, "getgenv")
                if type(ge) == "function" then
                    local g = ge()
                    if type(g) == "table" then
                        fp = rawget(g, "fireproximityprompt")
                    end
                end
            end
            if type(fp) == "function" then
                fp(prompt)
                usedFire = true
            end
        end)
        if usedFire then
            task.wait(0.35)
            return
        end
        pcall(function()
            prompt:InputHoldBegin()
        end)
        local hold = 0.2
        pcall(function()
            hold = math.clamp((prompt :: ProximityPrompt).HoldDuration + 0.08, 0.15, 3)
        end)
        task.wait(hold)
        pcall(function()
            prompt:InputHoldEnd()
        end)
    end

    local autoCollectLootEnabled = false
    local autoCollectLootLoopToken = 0
    type LootQueueEntry = { uid: string, label: string }
    local lootProcessQueue: { LootQueueEntry } = {}
    local lootChildAddedConn: RBXScriptConnection? = nil
    local lootFolderChildAddedConn: RBXScriptConnection? = nil
    local lootFolderDescendantAddedConn: RBXScriptConnection? = nil
    local lootFolderDestroyingConn: RBXScriptConnection? = nil
    local lastBoundLootFolder: Folder? = nil
    local lootServiceEventConn: RBXScriptConnection? = nil
    local lootPendingAck: { [string]: boolean } = {}
    local collectedLootLines: { string } = {}
    local COLLECTED_LOOT_MAX_LINES = 50
    -- `Packages._Index` leifstout_networker versions (newest first for generic remotes).
    local LEIFSTOUT_NETWORKER_VERSIONS: { string } = {
        "leifstout_networker@0.3.1",
        "leifstout_networker@0.2.1",
    }
    -- DataService `specialRollProgression` is only fired on this package version.
    local LEIFSTOUT_NETWORKER_DATA_SERVICE_VERSION = "leifstout_networker@0.2.1"
    -- RollService `requestSetSpecialRollPaused` must use this package version.
    local LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION = "leifstout_networker@0.3.1"

    local LootCollectedParagraph = MainTab:CreateParagraph({
        Title = "Collected loot",
        Content = "None",
    })

    local function getNetworkerRemotesRoot(indexFolderName: string): Instance?
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        if not packages then
            return nil
        end
        local idx = packages:FindFirstChild("_Index")
        if not idx then
            return nil
        end
        local pkg = idx:FindFirstChild(indexFolderName)
        if not pkg then
            return nil
        end
        local net = pkg:FindFirstChild("networker")
        if not net then
            return nil
        end
        local rem = net:FindFirstChild("_remotes")
        if not rem then
            return nil
        end
        return rem
    end

    local function findNetworkerServiceRemotesFolder(serviceFolderName: string, indexFolderName: string?): Instance?
        local versions: { string }
        if indexFolderName then
            versions = { indexFolderName }
        else
            versions = LEIFSTOUT_NETWORKER_VERSIONS
        end
        for _, folderName in ipairs(versions) do
            local rem = getNetworkerRemotesRoot(folderName)
            if rem then
                local svc = rem:FindFirstChild(serviceFolderName)
                if svc then
                    return svc
                end
            end
        end
        return nil
    end

    local function findNetworkerRemoteInService(
        serviceFolderName: string,
        remoteChildName: string,
        remoteClass: string,
        indexFolderName: string?
    ): Instance?
        local svc = findNetworkerServiceRemotesFolder(serviceFolderName, indexFolderName)
        if not svc then
            return nil
        end
        local remote = svc:FindFirstChild(remoteChildName)
        if remote and remote:IsA(remoteClass) then
            return remote
        end
        return nil
    end

    local function resolveNetworkerRemoteFunction(
        serviceFolderName: string,
        indexFolderName: string?
    ): RemoteFunction?
        local rf = findNetworkerRemoteInService(serviceFolderName, "RemoteFunction", "RemoteFunction", indexFolderName)
        if rf and rf:IsA("RemoteFunction") then
            return rf
        end
        return nil
    end

    local function resolveNetworkerRemoteEvent(
        serviceFolderName: string,
        indexFolderName: string?
    ): RemoteEvent?
        local ev = findNetworkerRemoteInService(serviceFolderName, "RemoteEvent", "RemoteEvent", indexFolderName)
        if ev and ev:IsA("RemoteEvent") then
            return ev
        end
        return nil
    end

    local function findLootServiceRemotesFolder(): Instance?
        return findNetworkerServiceRemotesFolder("LootService")
    end

    local function disconnectLootRemoteListener()
        if lootServiceEventConn then
            lootServiceEventConn:Disconnect()
            lootServiceEventConn = nil
        end
        table.clear(lootPendingAck)
    end

    local function ensureLootRemoteListener(): boolean
        if lootServiceEventConn then
            return true
        end
        local fold = findLootServiceRemotesFolder()
        if not fold then
            return false
        end
        local ev = fold:FindFirstChild("RemoteEvent")
        if not ev or not ev:IsA("RemoteEvent") then
            return false
        end
        lootServiceEventConn = ev.OnClientEvent:Connect(function(a1, a2)
            if a1 == "lootRemoved" and type(a2) == "string" then
                lootPendingAck[a2] = true
            end
        end)
        return true
    end

    local function looksLikeLootUid(s: string): boolean
        if #s ~= 36 then
            return false
        end
        return string.match(s, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
    end

    local function lootUidFromInstance(child: Instance): string?
        if looksLikeLootUid(child.Name) then
            return child.Name
        end
        for _, attrName in ipairs({ "Uid", "uid", "UID", "Id", "id" }) do
            local v = child:GetAttribute(attrName)
            if type(v) == "string" and looksLikeLootUid(v) then
                return v
            end
        end
        for _, childName in ipairs({ "Uid", "uid", "UID", "Id" }) do
            local sv = child:FindFirstChild(childName)
            if sv and sv:IsA("StringValue") and looksLikeLootUid(sv.Value) then
                return sv.Value
            end
        end
        -- Some UIs only store the id on arbitrary StringValues / custom attributes (not named "Uid").
        local okAttrs, attrs = pcall(function()
            return (child :: any).GetAttributes and (child :: any):GetAttributes()
        end)
        if okAttrs and type(attrs) == "table" then
            for _, v in pairs(attrs) do
                if type(v) == "string" and looksLikeLootUid(v) then
                    return v
                end
            end
        end
        if child:IsA("StringValue") and looksLikeLootUid(child.Value) then
            return child.Value
        end
        return nil
    end

    local function lootGetBillboardTextLabel(lootTop: Instance): TextLabel?
        for _, inst in ipairs(lootTop:GetDescendants()) do
            if inst.Name == "Root" then
                local bb = inst:FindFirstChild("LootBillboard")
                if bb then
                    local tl = bb:FindFirstChild("TextLabel")
                    if tl and tl:IsA("TextLabel") then
                        return tl
                    end
                    local any = bb:FindFirstChildWhichIsA("TextLabel", false)
                    if any then
                        return any
                    end
                end
            end
        end
        return nil
    end

    local function lootDisplayName(lootTop: Instance): string
        local tl = lootGetBillboardTextLabel(lootTop)
        if tl then
            local ok, txt = pcall(function()
                return tl.Text
            end)
            if ok and type(txt) == "string" and txt ~= "" then
                txt = string.gsub(txt, "\r\n", " ")
                txt = string.gsub(txt, "\n", " ")
                if #txt > 80 then
                    txt = string.sub(txt, 1, 80) .. "..."
                end
                return txt
            end
        end
        return lootTop.Name
    end

    local function lootEnqueueEntry(uid: string, label: string)
        for _, e in ipairs(lootProcessQueue) do
            if e.uid == uid then
                return
            end
        end
        table.insert(lootProcessQueue, { uid = uid, label = label })
    end

    local function lootEnqueueChild(child: Instance)
        if not child or not child.Parent then
            return
        end
        local uid = lootUidFromInstance(child)
        if not uid then
            return
        end
        lootEnqueueEntry(uid, lootDisplayName(child))
    end

    local function pushCollectedLootLine(displayName: string)
        table.insert(collectedLootLines, "• " .. displayName)
        while #collectedLootLines > COLLECTED_LOOT_MAX_LINES do
            table.remove(collectedLootLines, 1)
        end
        LootCollectedParagraph:Set({
            Title = "Collected loot",
            Content = #collectedLootLines > 0 and table.concat(collectedLootLines, "\n") or "(None yet)",
        })
    end

    local function disconnectLootFolderListener()
        if lootFolderChildAddedConn then
            lootFolderChildAddedConn:Disconnect()
            lootFolderChildAddedConn = nil
        end
        if lootFolderDescendantAddedConn then
            lootFolderDescendantAddedConn:Disconnect()
            lootFolderDescendantAddedConn = nil
        end
        if lootFolderDestroyingConn then
            lootFolderDestroyingConn:Disconnect()
            lootFolderDestroyingConn = nil
        end
        lastBoundLootFolder = nil
    end

    local connectLootFolder: (Folder) -> ()

    local function attachLootListenerToWorkspaceLoot()
        if lootChildAddedConn then
            lootChildAddedConn:Disconnect()
            lootChildAddedConn = nil
        end
        disconnectLootFolderListener()
        local existing = Workspace:FindFirstChild("Loot")
        if existing and existing:IsA("Folder") then
            connectLootFolder(existing)
            return
        end
        lootChildAddedConn = Workspace.ChildAdded:Connect(function(child)
            if child.Name == "Loot" and child:IsA("Folder") then
                connectLootFolder(child)
                if lootChildAddedConn then
                    lootChildAddedConn:Disconnect()
                    lootChildAddedConn = nil
                end
            end
        end)
    end

    connectLootFolder = function(folder: Folder)
        disconnectLootFolderListener()
        lastBoundLootFolder = folder
        lootFolderChildAddedConn = folder.ChildAdded:Connect(function(child)
            if autoCollectLootEnabled then
                lootEnqueueChild(child)
            end
        end)
        lootFolderDescendantAddedConn = folder.DescendantAdded:Connect(function(inst)
            if autoCollectLootEnabled and looksLikeLootUid(inst.Name) then
                lootEnqueueChild(inst)
            end
        end)
        lootFolderDestroyingConn = folder.Destroying:Connect(function()
            if lastBoundLootFolder == folder then
                lastBoundLootFolder = nil
            end
            disconnectLootFolderListener()
            task.defer(attachLootListenerToWorkspaceLoot)
        end)
        if autoCollectLootEnabled then
            for _, c in ipairs(folder:GetDescendants()) do
                lootEnqueueChild(c)
            end
        end
    end

    attachLootListenerToWorkspaceLoot()

    local function seedExistingLootChildren()
        local folder = Workspace:FindFirstChild("Loot")
        if not folder or not folder:IsA("Folder") then
            return
        end
        for _, child in ipairs(folder:GetDescendants()) do
            lootEnqueueChild(child)
        end
    end

    MainTab:CreateToggle({
        Name = "Auto Collect Loot",
        Flag = "main_auto_collect_loot",
        CurrentValue = false,
        Callback = function(enabled)
            autoCollectLootEnabled = enabled == true
            autoCollectLootLoopToken = autoCollectLootLoopToken + 1
            local myToken = autoCollectLootLoopToken

            if not autoCollectLootEnabled then
                lootProcessQueue = {}
                disconnectLootRemoteListener()
                return
            end

            if not ensureLootRemoteListener() then
                mountNotify({
                    Title = "Auto Collect Loot",
                    Content = "LootService remotes not found under ReplicatedStorage.Packages._Index (leifstout_networker@…).",
                    Icon = "x",
                })
            end

            local folder = Workspace:FindFirstChild("Loot")
            if not folder or not folder:IsA("Folder") then
                mountNotify({
                    Title = "Auto Collect Loot",
                    Content = "Workspace.Loot folder not found yet — waiting. Toggle stays on.",
                    Icon = "x",
                })
            else
                connectLootFolder(folder)
                seedExistingLootChildren()
            end

            task.spawn(function()
                while myToken == autoCollectLootLoopToken and autoCollectLootEnabled do
                    if #lootProcessQueue == 0 then
                        task.wait(0.2)
                    else
                        local entry = lootProcessQueue[1]
                        local fold = findLootServiceRemotesFolder()
                        local rf = fold and fold:FindFirstChild("RemoteFunction")
                        if not fold or not rf or not rf:IsA("RemoteFunction") then
                            ensureLootRemoteListener()
                            task.wait(0.35)
                        else
                            table.remove(lootProcessQueue, 1)
                            lootPendingAck[entry.uid] = nil
                            pcall(function()
                                (rf :: RemoteFunction):InvokeServer("requestCollect", entry.uid)
                            end)
                            local deadline = os.clock() + 6
                            local confirmed = false
                            while os.clock() < deadline do
                                if myToken ~= autoCollectLootLoopToken or not autoCollectLootEnabled then
                                    break
                                end
                                if lootPendingAck[entry.uid] then
                                    lootPendingAck[entry.uid] = nil
                                    confirmed = true
                                    break
                                end
                                task.wait(0.05)
                            end
                            if confirmed then
                                pushCollectedLootLine(entry.label)
                            else
                                local lootFolder = Workspace:FindFirstChild("Loot")
                                if lootFolder and lootFolder:IsA("Folder") then
                                    for _, ch in ipairs(lootFolder:GetChildren()) do
                                        if lootUidFromInstance(ch) == entry.uid then
                                            lootEnqueueEntry(entry.uid, entry.label)
                                            break
                                        end
                                    end
                                end
                            end
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end,
    })

    MainTab:CreateSection("Auto Collect Recipe")

    local autoCollectRecipeEnabled = false
    local autoCollectRecipeLoopToken = 0

    local function getWorkspaceZonesRoot(): Instance?
        local z = Workspace:FindFirstChild("Zones")
        if z and (z:IsA("Folder") or z:IsA("Model")) then
            return z
        end
        return nil
    end

    local function recipeMeshIsShowing(mesh: MeshPart): boolean
        if mesh.Transparency >= 0.999 then
            return false
        end
        if mesh.LocalTransparencyModifier >= 0.999 then
            return false
        end
        return true
    end

    local function findFirstInteractableRecipeInZones(): MeshPart?
        local zones = getWorkspaceZonesRoot()
        if not zones then
            return nil
        end
        for _, inst in ipairs(zones:GetDescendants()) do
            if inst:IsA("MeshPart") and string.sub(inst.Name, 1, 6) == "Recipe" then
                local prompt = inst:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and prompt:IsA("ProximityPrompt") then
                    if prompt.Enabled and recipeMeshIsShowing(inst) then
                        return inst
                    end
                end
            end
        end
        return nil
    end

    MainTab:CreateToggle({
        Name = "Auto Collect",
        Flag = "main_auto_collect_recipe",
        CurrentValue = false,
        Callback = function(enabled)
            autoCollectRecipeEnabled = enabled == true
            autoCollectRecipeLoopToken = autoCollectRecipeLoopToken + 1
            local myToken = autoCollectRecipeLoopToken

            if not autoCollectRecipeEnabled then
                return
            end

            local zones = getWorkspaceZonesRoot()
            if not zones then
                mountNotify({
                    Title = "Auto Collect Recipe",
                    Content = 'Workspace child "Zones" (Folder or Model) not found — idle until it exists.',
                    Icon = "x",
                })
            end

            task.spawn(function()
                while myToken == autoCollectRecipeLoopToken and autoCollectRecipeEnabled do
                    local lp = Players.LocalPlayer
                    local character = lp.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
                    if not hrp then
                        task.wait(0.35)
                    else
                        local zonesNow = getWorkspaceZonesRoot()
                        if not zonesNow then
                            task.wait(1)
                        else
                            local recipeMesh = findFirstInteractableRecipeInZones()
                            if not recipeMesh then
                                task.wait(0.35)
                            else
                                local savedCf = hrp.CFrame
                                local targetPos = recipeMesh.Position
                                hrp.AssemblyLinearVelocity = Vector3.zero
                                local stand = targetPos + Vector3.new(0, 3, 0)
                                hrp.CFrame = CFrame.lookAt(stand, targetPos)
                                task.wait(0.1)
                                mainTryProximityInteractOnInstance(recipeMesh)
                                task.wait(0.2)
                                if hrp.Parent then
                                    hrp.AssemblyLinearVelocity = Vector3.zero
                                    hrp.CFrame = savedCf
                                end
                                task.wait(0.55)
                            end
                        end
                    end
                end
            end)
        end,
    })

    MainTab:CreateSection("Auto Gun")

    local autoGunShotDelaySec = 0.1
    local autoGunEnabled = false
    local autoGunLoopToken = 0
    local autoGunEnemyListenerConns: { RBXScriptConnection } = {}
    local autoGunEnemyRefreshScheduled = false

    local EnemiesListParagraph = MainTab:CreateParagraph({
        Title = "Enemies",
        Content = 'No enemies under Workspace → Gameplay* → Enemies.',
    })

    type GameplayEnemiesEntry = {
        gameplayName: string,
        enemiesFolder: Instance,
    }

    local function mainFindWorkspaceGameplayEnemies(): { GameplayEnemiesEntry }
        local out: { GameplayEnemiesEntry } = {}
        for _, ch in ipairs(Workspace:GetChildren()) do
            if string.sub(ch.Name, 1, #"Gameplay") == "Gameplay" then
                local enemies = ch:FindFirstChild("Enemies")
                if enemies then
                    table.insert(out, {
                        gameplayName = ch.Name,
                        enemiesFolder = enemies,
                    })
                end
            end
        end
        return out
    end

    local function mainFindWorkspaceEnemiesFolders(): { Instance }
        local out: { Instance } = {}
        for _, entry in ipairs(mainFindWorkspaceGameplayEnemies()) do
            table.insert(out, entry.enemiesFolder)
        end
        return out
    end

    local function mainEnemyNumericUid(enemy: Instance): number?
        local fromName = tonumber(enemy.Name)
        if fromName then
            return fromName
        end
        for _, attrName in ipairs({ "Uid", "uid", "UID", "Id", "id" }) do
            local v = enemy:GetAttribute(attrName)
            if type(v) == "number" then
                return v
            end
            if type(v) == "string" then
                local n = tonumber(v)
                if n then
                    return n
                end
            end
        end
        for _, childName in ipairs({ "Uid", "uid", "UID", "Id", "id" }) do
            local sv = enemy:FindFirstChild(childName)
            if sv then
                if sv:IsA("IntValue") or sv:IsA("NumberValue") then
                    return (sv :: any).Value
                end
                if sv:IsA("StringValue") then
                    local n = tonumber((sv :: StringValue).Value)
                    if n then
                        return n
                    end
                end
            end
        end
        return nil
    end

    local function mainEnemyGuiTextFromNode(node: Instance?): string
        if not node then
            return ""
        end
        local function textFromGui(inst: Instance): string
            if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                local fromFmt = formatGuiInstanceTextForDisplay(inst)
                if fromFmt and fromFmt ~= "" then
                    return fromFmt
                end
                if inst:IsA("TextLabel") then
                    return (inst :: TextLabel).Text
                end
                if inst:IsA("TextButton") then
                    return (inst :: TextButton).Text
                end
                return (inst :: TextBox).Text
            end
            return ""
        end
        local direct = textFromGui(node)
        if direct ~= "" then
            return direct
        end
        local tl = node:FindFirstChildWhichIsA("TextLabel", true)
        if tl then
            return textFromGui(tl)
        end
        return ""
    end

    local function mainEnemyHpDisplay(enemy: Instance): string
        local bb = enemy:FindFirstChild("HealthBarBillboardGui", true)
        if not bb then
            return "?"
        end
        local hpNode = bb:FindFirstChild("Hp", true)
        if not hpNode then
            return "?"
        end
        local hp = mainEnemyGuiTextFromNode(hpNode)
        return hp ~= "" and hp or "?"
    end

    local function mainEnemyMutationLabel(enemy: Instance): string?
        local bb = enemy:FindFirstChild("MutationBillboard", true)
        if not bb then
            return nil
        end
        local labelNode = bb:FindFirstChild("MutationLabel", true)
        if not labelNode then
            return nil
        end
        local text = mainEnemyGuiTextFromNode(labelNode)
        if text == "" then
            return nil
        end
        return text
    end

    local MUTATION_SHOT_PRIORITY_NAMES: { string } = {
        "Inverted",
        "Shiny",
        "HUGE",
        "Big",
    }

    local function mainMutationNameMatches(a: string, b: string): boolean
        return string.lower(a) == string.lower(b)
    end

    -- 1–4 named mutations, 5 = other mutation, 6 = no MutationBillboard / no label.
    local function mainEnemyMutationShotPriority(mutation: string?): number
        if not mutation or mutation == "" then
            return 6
        end
        for i, priorityName in ipairs(MUTATION_SHOT_PRIORITY_NAMES) do
            if mainMutationNameMatches(mutation, priorityName) then
                return i
            end
        end
        return 5
    end

    type EnemyListRow = {
        uid: number,
        hp: string,
        mutation: string?,
        shotPriority: number,
        listOrder: number,
        gameplayName: string,
    }

    local function mainCollectEnemyListRows(): { EnemyListRow }
        local rows: { EnemyListRow } = {}
        local seenUid: { [number]: boolean } = {}
        local listOrder = 0
        for _, entry in ipairs(mainFindWorkspaceGameplayEnemies()) do
            for _, enemy in ipairs(entry.enemiesFolder:GetChildren()) do
                local uid = mainEnemyNumericUid(enemy)
                if uid and not seenUid[uid] then
                    seenUid[uid] = true
                    listOrder = listOrder + 1
                    local mutation = mainEnemyMutationLabel(enemy)
                    table.insert(rows, {
                        uid = uid,
                        hp = mainEnemyHpDisplay(enemy),
                        mutation = mutation,
                        shotPriority = mainEnemyMutationShotPriority(mutation),
                        listOrder = listOrder,
                        gameplayName = entry.gameplayName,
                    })
                end
            end
        end
        table.sort(rows, function(a, b)
            if a.shotPriority ~= b.shotPriority then
                return a.shotPriority < b.shotPriority
            end
            if a.listOrder ~= b.listOrder then
                return a.listOrder < b.listOrder
            end
            return a.uid < b.uid
        end)
        return rows
    end

    local function mainFormatEnemyListLine(row: EnemyListRow): string
        if row.mutation and row.mutation ~= "" then
            return ("%d - %s (%s)"):format(row.uid, row.hp, row.mutation)
        end
        return ("%d - %s"):format(row.uid, row.hp)
    end

    local function mainPickGameplayEnemyTarget(): (number?, string?)
        local rows = mainCollectEnemyListRows()
        local first = rows[1]
        if first then
            return first.uid, first.gameplayName
        end
        return nil, nil
    end

    local function mainPickGameplayEnemyUid(): number?
        local uid = mainPickGameplayEnemyTarget()
        return uid
    end

    local function mainBuildEnemiesListParagraphBody(): string
        local enemyFolders = mainFindWorkspaceEnemiesFolders()
        if #enemyFolders == 0 then
            return 'No enemies under Workspace → Gameplay* → Enemies.'
        end
        local rows = mainCollectEnemyListRows()
        if #rows == 0 then
            return "Enemies folder(s) found, but no numeric enemy uids yet."
        end
        local lines: { string } = {}
        for _, row in ipairs(rows) do
            table.insert(lines, mainFormatEnemyListLine(row))
        end
        return table.concat(lines, "\n")
    end

    local function refreshEnemiesListParagraph()
        if EnemiesListParagraph and EnemiesListParagraph.Set then
            EnemiesListParagraph:Set({
                Title = "Enemies",
                Content = mainBuildEnemiesListParagraphBody(),
            })
        end
    end

    local function disconnectAutoGunEnemyListeners()
        for _, conn in ipairs(autoGunEnemyListenerConns) do
            conn:Disconnect()
        end
        table.clear(autoGunEnemyListenerConns)
    end

    local function scheduleRefreshEnemiesListParagraph()
        if autoGunEnemyRefreshScheduled then
            return
        end
        autoGunEnemyRefreshScheduled = true
        task.defer(function()
            autoGunEnemyRefreshScheduled = false
            refreshEnemiesListParagraph()
        end)
    end

    local function bindAutoGunEnemyListeners()
        disconnectAutoGunEnemyListeners()
        local function hookFolder(folder: Instance)
            table.insert(autoGunEnemyListenerConns, folder.ChildAdded:Connect(scheduleRefreshEnemiesListParagraph))
            table.insert(autoGunEnemyListenerConns, folder.ChildRemoved:Connect(scheduleRefreshEnemiesListParagraph))
            for _, enemy in ipairs(folder:GetChildren()) do
                table.insert(
                    autoGunEnemyListenerConns,
                    enemy.DescendantAdded:Connect(scheduleRefreshEnemiesListParagraph)
                )
            end
        end
        for _, folder in ipairs(mainFindWorkspaceEnemiesFolders()) do
            hookFolder(folder)
        end
        table.insert(autoGunEnemyListenerConns, Workspace.ChildAdded:Connect(function(child)
            if string.sub(child.Name, 1, #"Gameplay") == "Gameplay" then
                local enemies = child:WaitForChild("Enemies", 8)
                if enemies then
                    hookFolder(enemies)
                    scheduleRefreshEnemiesListParagraph()
                end
            end
        end))
    end

    bindAutoGunEnemyListeners()
    refreshEnemiesListParagraph()
    task.spawn(function()
        while true do
            task.wait(1.25)
            refreshEnemiesListParagraph()
        end
    end)

    local slimeGunTryFireRemote: RemoteFunction? = resolveNetworkerRemoteFunction("SlimeGunService")

    local function mainTryFireSlimeGun(uid: number)
        if not slimeGunTryFireRemote then
            return
        end
        pcall(function()
            slimeGunTryFireRemote:InvokeServer("tryFireSlimeGun", uid)
        end)
    end

    MainTab:CreateSlider({
        Name = "Shot interval",
        Flag = "main_auto_gun_shot_interval",
        Range = { 0.001, 2 },
        Increment = 0.05,
        Suffix = "sec",
        CurrentValue = autoGunShotDelaySec,
        Callback = function(value)
            if type(value) == "number" and value == value then
                autoGunShotDelaySec = math.clamp(value, 0.05, 3)
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Shot",
        Flag = "main_auto_gun_shot",
        CurrentValue = false,
        Callback = function(enabled)
            autoGunEnabled = enabled == true
            autoGunLoopToken = autoGunLoopToken + 1
            local myToken = autoGunLoopToken

            if not autoGunEnabled then
                return
            end

            task.spawn(function()
                while myToken == autoGunLoopToken and autoGunEnabled do
                    local uid = mainPickGameplayEnemyUid()
                    if not uid then
                        task.wait(math.max(autoGunShotDelaySec, 0.35))
                    else
                        mainTryFireSlimeGun(uid)
                        task.wait(autoGunShotDelaySec)
                    end
                end
            end)
        end,
    })

    MainTab:CreateSection("Burst Attack")

    local burstAttackDamage = 8406
    local burstAttackEnabled = false
    local burstAttackLoopToken = 0
    local burstAttackDelaySec = 0.1
    local gameplayConfirmHitRemote: RemoteEvent? = nil
    local gameplayConfirmHitRemoteServiceName: string? = nil

    local function mainTryConfirmHit(damage: number, uid: number, gameplayServiceName: string?)
        if not gameplayServiceName or gameplayServiceName == "" then
            return
        end
        if gameplayConfirmHitRemoteServiceName ~= gameplayServiceName then
            gameplayConfirmHitRemoteServiceName = gameplayServiceName
            gameplayConfirmHitRemote = resolveNetworkerRemoteEvent(
                gameplayServiceName,
                LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION
            )
        elseif not gameplayConfirmHitRemote or not gameplayConfirmHitRemote.Parent then
            gameplayConfirmHitRemote = resolveNetworkerRemoteEvent(
                gameplayServiceName,
                LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION
            )
        end
        if not gameplayConfirmHitRemote then
            return
        end
        pcall(function()
            gameplayConfirmHitRemote:FireServer("confirmHit", damage, uid)
        end)
    end

    MainTab:CreateInput({
        Name = "Damage",
        PlaceholderText = "e.g. 8406",
        Flag = "slimeAttack",
        CurrentValue = tostring(burstAttackDamage),
        Callback = function(value)
            local n = tonumber(value)
            if n and n == n then
                burstAttackDamage = math.floor(n)
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Attack",
        Flag = "main_burst_attack",
        CurrentValue = false,
        Callback = function(enabled)
            burstAttackEnabled = enabled == true
            burstAttackLoopToken = burstAttackLoopToken + 1
            local myToken = burstAttackLoopToken

            if not burstAttackEnabled then
                return
            end

            task.spawn(function()
                while myToken == burstAttackLoopToken and burstAttackEnabled do
                    local uid, gameplayName = mainPickGameplayEnemyTarget()
                    if not uid or not gameplayName then
                        task.wait(math.max(burstAttackDelaySec, 0.35))
                    else
                        mainTryConfirmHit(burstAttackDamage, uid, gameplayName)
                        task.wait(burstAttackDelaySec)
                    end
                end
            end)
        end,
    })

    local upgradeServiceUtils: any = nil
    local upgradeUtilsLoadError: string? = nil
    local playerUpgradesSave: { [string]: any } = {}
    local SPECIAL_ROLL_UPGRADE_KEY_BY_KIND: { [string]: string } = {
        golden = "goldenRolls",
        diamond = "diamondRolls",
        void = "voidRolls",
        galaxy = "galaxyRolls",
    }
    local UPGRADE_LUCK_ROLL_KINDS: { string } = { "golden", "diamond", "void", "galaxy" }

    local function cloneUpgradesTable(src: any): { [string]: any }
        local out: { [string]: any } = {}
        if type(src) ~= "table" then
            return out
        end
        for k, v in pairs(src) do
            if type(k) == "string" then
                out[k] = v
            end
        end
        return out
    end

    local function getDataServiceClient(): any?
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        local dsMod = packages and packages:FindFirstChild("DataService")
        if not dsMod or not dsMod:IsA("ModuleScript") then
            return nil
        end
        local okPkg, ds = pcall(require, dsMod)
        if not okPkg or type(ds) ~= "table" then
            return nil
        end
        local client = ds.client
        if type(client) ~= "table" or type(client.get) ~= "function" then
            return nil
        end
        return client
    end

    local function tryLoadUpgradeServiceUtils(): boolean
        if upgradeServiceUtils then
            return true
        end
        local src = ReplicatedStorage:FindFirstChild("Source")
        local upgradesFolder = src and src:FindFirstChild("Features")
        upgradesFolder = upgradesFolder and upgradesFolder:FindFirstChild("Upgrades")
        local mod = upgradesFolder and upgradesFolder:FindFirstChild("UpgradeServiceUtils")
        if not mod or not mod:IsA("ModuleScript") then
            upgradeUtilsLoadError = "UpgradeServiceUtils ModuleScript not found under ReplicatedStorage.Source.Features.Upgrades"
            return false
        end
        local ok, result = pcall(require, mod)
        if not ok or type(result) ~= "table" then
            upgradeUtilsLoadError = tostring(result)
            return false
        end
        upgradeServiceUtils = result
        upgradeUtilsLoadError = nil
        return true
    end

    local function luckRollCadenceEveryN(utils: any, kind: string, save: { [string]: any }): (number?, number)
        local upgradeKey = SPECIAL_ROLL_UPGRADE_KEY_BY_KIND[kind]
        if not upgradeKey then
            return nil, 0
        end
        local lvl = utils.getUpgradeLevel(upgradeKey, save)
        if lvl <= 0 then
            return nil, lvl
        end
        local luckRolls = utils.enums and utils.enums.luckRolls
        local cadence = luckRolls and luckRolls[kind]
        if type(cadence) ~= "table" then
            return nil, lvl
        end
        local everyN = cadence[math.min(lvl, 3)] or cadence[1]
        return everyN, lvl
    end

    local function tryPullPlayerUpgradesFromDataService(): boolean
        local client = getDataServiceClient()
        if not client then
            return false
        end
        local okGet, data = pcall(function()
            return client:get("upgrades")
        end)
        if okGet and type(data) == "table" then
            playerUpgradesSave = cloneUpgradesTable(data)
            return true
        end
        return false
    end

    MainTab:CreateSection("Special Roll")

    -- Highest → lowest priority (galaxy first).
    local SPECIAL_ROLL_TIER_ORDER: { string } = { "galaxy", "void", "diamond", "golden" }

    type SpecialRollTierSnapshot = {
        paused: boolean,
        rollsUntilNext: number,
    }

    local specialRollProgressionByTier: { [string]: SpecialRollTierSnapshot } = {}
    local specialRollDisplayToTier: { [string]: string } = {}
    local selectedSpecialRollTierKeys: { string } = {}
    local lastSelectedSpecialRollTier: string? = nil
    local specialRollPreviousSelectedSet: { [string]: boolean } = {}
    local specialRollDropdownSeededAll = false
    local specialRollParagraphRefreshScheduled = false
    local SpecialRollDropdown: any = nil
    local autoCombineSpecialRollEnabled = false
    local specialRollCombineInvokePending: { [string]: boolean } = {}
    local runAutoCombineSpecialRollPass: () -> ()

    local function specialRollTierDisplayName(tierKey: string): string
        return string.sub(tierKey, 1, 1):upper() .. string.sub(tierKey, 2)
    end

    local function specialRollNormalizeTierKey(rawKey: any): string?
        if type(rawKey) ~= "string" then
            return nil
        end
        local lower = string.lower(rawKey)
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            if lower == tier then
                return tier
            end
        end
        return nil
    end

    local function specialRollParseTierEntry(entry: any): SpecialRollTierSnapshot?
        if type(entry) ~= "table" then
            return nil
        end
        local rolls = entry.rollsUntilNext
        if type(rolls) ~= "number" then
            rolls = tonumber(rolls) or 0
        end
        return {
            paused = entry.paused == true,
            rollsUntilNext = math.max(0, math.floor(rolls)),
        }
    end

    local SpecialRollParagraph = MainTab:CreateParagraph({
        Title = "Special rolls",
        Content = "—\n\nPick: none",
    })

    local function buildSpecialRollSelectedLine(): string
        local names: { string } = {}
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            if table.find(selectedSpecialRollTierKeys, tier) then
                table.insert(names, specialRollTierDisplayName(tier))
            end
        end
        if #names == 0 then
            return "Pick: none"
        end
        return "Pick: " .. table.concat(names, ", ")
    end

    local function formatSpecialRollTierLine(kind: string): string
        local label = specialRollTierDisplayName(kind)
        local prog = specialRollProgressionByTier[kind]
        local left = if prog then tostring(prog.rollsUntilNext) else "—"
        local pauseTag = if prog and prog.paused then " (paused)" else " (running)"

        if tryLoadUpgradeServiceUtils() and upgradeServiceUtils then
            local everyN = luckRollCadenceEveryN(upgradeServiceUtils, kind, playerUpgradesSave)
            if everyN then
                return ("%s: max = %d remaining = %s%s"):format(label, everyN, left, pauseTag)
            end
            return ("%s: locked%s"):format(label, pauseTag)
        end
        if prog then
            return ("%s: %s%s"):format(label, left, pauseTag)
        end
        return ("%s: —"):format(label)
    end

    local function buildSpecialRollParagraphBody(): string
        local selectedLine = buildSpecialRollSelectedLine()
        local progressionLines: { string } = {}
        local anyProgression = false
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            table.insert(progressionLines, formatSpecialRollTierLine(tier))
            if specialRollProgressionByTier[tier] then
                anyProgression = true
            end
        end
        local body = table.concat(progressionLines, "\n") .. "\n\n" .. selectedLine
        if not anyProgression then
            body = body .. "\n\n(no progression yet)"
        end
        return body
    end

    local function refreshSpecialRollParagraph()
        tryPullPlayerUpgradesFromDataService()
        if SpecialRollParagraph and SpecialRollParagraph.Set then
            SpecialRollParagraph:Set({
                Title = "Special rolls",
                Content = buildSpecialRollParagraphBody(),
            })
        end
    end

    local function scheduleRefreshSpecialRollParagraph()
        if specialRollParagraphRefreshScheduled then
            return
        end
        specialRollParagraphRefreshScheduled = true
        task.defer(function()
            specialRollParagraphRefreshScheduled = false
            refreshSpecialRollParagraph()
        end)
    end

    local function specialRollSetSelectedTierKeysFromDisplayOptions(value: any)
        local nextKeys: { string } = {}
        local function addDisplay(opt: string)
            local tier = specialRollDisplayToTier[opt]
            if tier and not table.find(nextKeys, tier) then
                table.insert(nextKeys, tier)
            end
        end
        if type(value) == "table" then
            for _, opt in ipairs(value) do
                if type(opt) == "string" then
                    addDisplay(opt)
                end
            end
        elseif type(value) == "string" then
            addDisplay(value)
        end

        for _, tier in ipairs(nextKeys) do
            if not specialRollPreviousSelectedSet[tier] then
                lastSelectedSpecialRollTier = tier
            end
        end
        if #nextKeys == 1 then
            lastSelectedSpecialRollTier = nextKeys[1]
        elseif #nextKeys == 0 then
            lastSelectedSpecialRollTier = nil
        elseif lastSelectedSpecialRollTier and not table.find(nextKeys, lastSelectedSpecialRollTier) then
            lastSelectedSpecialRollTier = nextKeys[#nextKeys]
        end

        table.clear(selectedSpecialRollTierKeys)
        for _, tier in ipairs(nextKeys) do
            table.insert(selectedSpecialRollTierKeys, tier)
        end
        table.clear(specialRollPreviousSelectedSet)
        for _, tier in ipairs(nextKeys) do
            specialRollPreviousSelectedSet[tier] = true
        end

        table.clear(specialRollCombineInvokePending)

        refreshSpecialRollParagraph()
        if autoCombineSpecialRollEnabled then
            runAutoCombineSpecialRollPass()
        end
    end

    local function refreshSpecialRollDropdownFromProgression()
        table.clear(specialRollDisplayToTier)
        local opts: { string } = {}
        local tierKeysAvailable: { string } = {}
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            local display = specialRollTierDisplayName(tier)
            specialRollDisplayToTier[display] = tier
            table.insert(opts, display)
            table.insert(tierKeysAvailable, tier)
        end
        if SpecialRollDropdown and SpecialRollDropdown.Refresh then
            SpecialRollDropdown:Refresh(opts)
        end
        if not specialRollDropdownSeededAll then
            selectedSpecialRollTierKeys = table.clone(tierKeysAvailable)
            lastSelectedSpecialRollTier = tierKeysAvailable[#tierKeysAvailable]
            table.clear(specialRollPreviousSelectedSet)
            for _, tier in ipairs(selectedSpecialRollTierKeys) do
                specialRollPreviousSelectedSet[tier] = true
            end
            specialRollDropdownSeededAll = true
            if SpecialRollDropdown and SpecialRollDropdown.Set then
                SpecialRollDropdown:Set(opts)
            end
            refreshSpecialRollParagraph()
            return
        end
        local kept: { string } = {}
        for _, tier in ipairs(selectedSpecialRollTierKeys) do
            if specialRollProgressionByTier[tier] and not table.find(kept, tier) then
                table.insert(kept, tier)
            end
        end
        if #kept == 0 then
            kept = table.clone(tierKeysAvailable)
        end
        selectedSpecialRollTierKeys = kept
        if lastSelectedSpecialRollTier and not table.find(selectedSpecialRollTierKeys, lastSelectedSpecialRollTier) then
            lastSelectedSpecialRollTier = selectedSpecialRollTierKeys[#selectedSpecialRollTierKeys]
        end
        local displaySelected: { string } = {}
        for _, tier in ipairs(selectedSpecialRollTierKeys) do
            table.insert(displaySelected, specialRollTierDisplayName(tier))
        end
        if SpecialRollDropdown and SpecialRollDropdown.Set then
            SpecialRollDropdown:Set(displaySelected)
        end
        refreshSpecialRollParagraph()
        if autoCombineSpecialRollEnabled then
            runAutoCombineSpecialRollPass()
        end
    end

    local rollSetSpecialPausedRemote: RemoteFunction? = nil
    local dataServiceProgressRemoteEvent: RemoteEvent? = nil

    local function getRollSetSpecialPausedRemote(): RemoteFunction?
        if rollSetSpecialPausedRemote and rollSetSpecialPausedRemote.Parent then
            return rollSetSpecialPausedRemote
        end
        rollSetSpecialPausedRemote =
            resolveNetworkerRemoteFunction("RollService", LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION)
        if rollSetSpecialPausedRemote then
            return rollSetSpecialPausedRemote
        end
        local packages = ReplicatedStorage:FindFirstChild("Packages")
            or ReplicatedStorage:WaitForChild("Packages", 12)
        if not packages then
            return nil
        end
        local idx = packages:FindFirstChild("_Index") or packages:WaitForChild("_Index", 12)
        if not idx then
            return nil
        end
        local pkg = idx:FindFirstChild(LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION)
            or idx:WaitForChild(LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION, 12)
        if not pkg then
            return nil
        end
        local net = pkg:FindFirstChild("networker") or pkg:WaitForChild("networker", 12)
        local rem = net and (net:FindFirstChild("_remotes") or net:WaitForChild("_remotes", 12))
        local rollSvc = rem and rem:FindFirstChild("RollService")
        local rollRf = rollSvc and rollSvc:FindFirstChild("RemoteFunction")
        if rollRf and rollRf:IsA("RemoteFunction") then
            rollSetSpecialPausedRemote = rollRf
        end
        return rollSetSpecialPausedRemote
    end

    local function mainRequestSetSpecialRollPaused(tierKey: string, pausedFlag: boolean): boolean
        local rf = getRollSetSpecialPausedRemote()
        if not rf then
            return false
        end
        local ok = pcall(function()
            rf:InvokeServer("requestSetSpecialRollPaused", tierKey, pausedFlag)
        end)
        return ok == true
    end

    -- Game API: true = pause, false = resume.
    local SPECIAL_ROLL_REMOTE_PAUSE = true
    local SPECIAL_ROLL_REMOTE_RESUME = false

    local function pauseSelectedSpecialRollTiers(): (number, number)
        local okCount = 0
        local failCount = 0
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            if table.find(selectedSpecialRollTierKeys, tier) then
                local st = specialRollProgressionByTier[tier]
                if st and not st.paused then
                    if mainRequestSetSpecialRollPaused(tier, SPECIAL_ROLL_REMOTE_PAUSE) then
                        okCount = okCount + 1
                    else
                        failCount = failCount + 1
                    end
                end
            end
        end
        return okCount, failCount
    end

    local function anySelectedSpecialTierHasProgression(): boolean
        for _, tier in ipairs(selectedSpecialRollTierKeys) do
            if specialRollProgressionByTier[tier] then
                return true
            end
        end
        return false
    end

    local function allSelectedSpecialTiersAtOneRemaining(): boolean
        if #selectedSpecialRollTierKeys < 2 then
            return false
        end
        for _, tier in ipairs(selectedSpecialRollTierKeys) do
            local st = specialRollProgressionByTier[tier]
            if not st or st.rollsUntilNext ~= 1 then
                return false
            end
        end
        return true
    end

    -- Count selected tiers that are currently running (not paused) and still
    -- have more than one roll left before their next special roll.
    local function selectedUnpausedSpecialTiersAboveOne(): number
        local count = 0
        for _, tier in ipairs(selectedSpecialRollTierKeys) do
            local st = specialRollProgressionByTier[tier]
            if st and not st.paused and (st.rollsUntilNext or 0) > 1 then
                count += 1
            end
        end
        return count
    end

    local function specialRollTierCadenceMax(tier: string): number?
        if tryLoadUpgradeServiceUtils() and upgradeServiceUtils then
            local everyN = luckRollCadenceEveryN(upgradeServiceUtils, tier, playerUpgradesSave)
            if everyN then
                return everyN
            end
        end
        return nil
    end

    -- Do not pause a tier at 1 while a higher-priority selected tier is still
    -- running above that tier's cadence max (e.g. void 150, diamond max 100).
    local function shouldAutoCombinePauseTierAtOne(tier: string): boolean
        local tierMax = specialRollTierCadenceMax(tier)
        if not tierMax then
            return true
        end
        for _, higherTier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            if higherTier == tier then
                break
            end
            if not table.find(selectedSpecialRollTierKeys, higherTier) then
                continue
            end
            local st = specialRollProgressionByTier[higherTier]
            if st and not st.paused and st.rollsUntilNext > 1 then
                if st.rollsUntilNext > tierMax then
                    return false
                end
            end
        end
        return true
    end

    -- Selected tiers currently sitting at rollsUntilNext == 1 and not paused.
    local function selectedSpecialTiersAtOneNotPaused(): { string }
        local out: { string } = {}
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            if table.find(selectedSpecialRollTierKeys, tier) then
                local st = specialRollProgressionByTier[tier]
                if st and not st.paused and st.rollsUntilNext == 1 and shouldAutoCombinePauseTierAtOne(tier) then
                    table.insert(out, tier)
                end
            end
        end
        return out
    end

    -- Selected tiers that are paused; used for resume-all.
    local function selectedSpecialTiersPaused(): { string }
        local out: { string } = {}
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            if table.find(selectedSpecialRollTierKeys, tier) then
                local st = specialRollProgressionByTier[tier]
                if st and st.paused then
                    table.insert(out, tier)
                end
            end
        end
        return out
    end

    function runAutoCombineSpecialRollPass()
        if not autoCombineSpecialRollEnabled or #selectedSpecialRollTierKeys < 2 then
            return
        end
        if not getRollSetSpecialPausedRemote() then
            return
        end

        if not anySelectedSpecialTierHasProgression() then
            return
        end

        local unpausedAboveOne = selectedUnpausedSpecialTiersAboveOne()

        if unpausedAboveOne >= 1 then
            -- Pause every selected tier that has hit 1 while another selected
            -- tier is still running with more than one roll to go.
            for _, tier in ipairs(selectedSpecialTiersAtOneNotPaused()) do
                if not specialRollCombineInvokePending[tier] then
                    if mainRequestSetSpecialRollPaused(tier, SPECIAL_ROLL_REMOTE_PAUSE) then
                        specialRollCombineInvokePending[tier] = true
                    end
                end
            end
        else
            -- No selected tier is left running above 1, so every still-paused
            -- selected tier can be resumed together for the combined roll.
            if allSelectedSpecialTiersAtOneRemaining() then
                for _, tier in ipairs(selectedSpecialTiersPaused()) do
                    if not specialRollCombineInvokePending[tier] then
                        if mainRequestSetSpecialRollPaused(tier, SPECIAL_ROLL_REMOTE_RESUME) then
                            specialRollCombineInvokePending[tier] = true
                        end
                    end
                end
            end
        end

        for tier, _ in pairs(specialRollCombineInvokePending) do
            if not table.find(selectedSpecialRollTierKeys, tier) then
                specialRollCombineInvokePending[tier] = nil
                continue
            end
            local st = specialRollProgressionByTier[tier]
            if not st then
                specialRollCombineInvokePending[tier] = nil
                continue
            end
            if unpausedAboveOne >= 1 then
                -- We just asked this tier to pause; clear pending once paused
                -- or once it no longer sits at 1 (state changed under us).
                if st.paused or st.rollsUntilNext ~= 1 then
                    specialRollCombineInvokePending[tier] = nil
                end
            else
                -- Resume branch: clear pending once the tier is actually running.
                if not st.paused then
                    specialRollCombineInvokePending[tier] = nil
                end
            end
        end
    end

    local function specialRollApplyProgressionPayload(payload: any)
        if type(payload) ~= "table" then
            return
        end
        local changed = false
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            local parsed = specialRollParseTierEntry(payload[tier])
            if parsed then
                specialRollProgressionByTier[tier] = parsed
                changed = true
            end
        end
        for rawKey, entry in pairs(payload) do
            local tier = specialRollNormalizeTierKey(rawKey)
            if tier then
                local parsed = specialRollParseTierEntry(entry)
                if parsed then
                    specialRollProgressionByTier[tier] = parsed
                    changed = true
                end
            end
        end
        if not changed then
            return
        end
        scheduleRefreshSpecialRollParagraph()
        refreshSpecialRollDropdownFromProgression()
        runAutoCombineSpecialRollPass()
    end

    local specialRollDataServiceConn: RBXScriptConnection? = nil

    local function specialRollProgressionEventMatches(a1: any, a2: any): boolean
        local key = if type(a2) == "string" then a2 elseif type(a1) == "string" then a1 else nil
        return key == "specialRollProgression"
    end

    local function specialRollExtractProgressionPayload(a1: any, a2: any, a3: any): any
        if specialRollProgressionEventMatches(a1, a2) then
            return a3
        end
        if type(a1) == "table" then
            return a1
        end
        return nil
    end

    local function ensureSpecialRollDataServiceListener(): boolean
        if specialRollDataServiceConn then
            return dataServiceProgressRemoteEvent ~= nil
        end
        for _, version in ipairs(LEIFSTOUT_NETWORKER_VERSIONS) do
            local dataEv = findNetworkerRemoteInService(
                "DataService",
                "RemoteEvent",
                "RemoteEvent",
                version
            )
            if dataEv and dataEv:IsA("RemoteEvent") then
                dataServiceProgressRemoteEvent = dataEv
                specialRollDataServiceConn = dataEv.OnClientEvent:Connect(function(a1, a2, a3)
                    local payload = specialRollExtractProgressionPayload(a1, a2, a3)
                    if payload then
                        specialRollApplyProgressionPayload(payload)
                    end
                end)
                return true
            end
        end
        return false
    end

    local function tryPullSpecialRollProgressionFromDataService(): boolean
        local client = getDataServiceClient()
        if not client then
            return false
        end
        local okGet, prog = pcall(function()
            return client:get("specialRollProgression")
        end)
        if not okGet or type(prog) ~= "table" then
            return false
        end
        specialRollApplyProgressionPayload(prog)
        return true
    end

    local function bootstrapSpecialRollSection()
        ensureSpecialRollDataServiceListener()
        refreshSpecialRollDropdownFromProgression()
        tryPullSpecialRollProgressionFromDataService()
        refreshSpecialRollParagraph()
    end

    SpecialRollDropdown = MainTab:CreateDropdown({
        Name = "Special Roll",
        Flag = "main_auto_adjust_special_roll_dropdown",
        Options = {},
        CurrentOption = {},
        MultipleOptions = true,
        Search = true,
        Callback = function(value)
            specialRollSetSelectedTierKeysFromDisplayOptions(value)
        end,
    })

    task.defer(function()
        bootstrapSpecialRollSection()
    end)

    task.spawn(function()
        for _ = 1, 60 do
            if tryPullSpecialRollProgressionFromDataService() then
                break
            end
            ensureSpecialRollDataServiceListener()
            local packages = ReplicatedStorage:FindFirstChild("Packages")
            if not packages then
                packages = ReplicatedStorage:WaitForChild("Packages", 2)
            end
            task.wait(0.5)
        end
        refreshSpecialRollDropdownFromProgression()
        refreshSpecialRollParagraph()
    end)

    MainTab:CreateButton({
        Name = "Pause Selected Special Roll",
        Flag = "main_pause_selected_special_roll",
        Callback = function()
            if #selectedSpecialRollTierKeys == 0 then
                mountNotify({
                    Title = "Special Roll",
                    Content = "Select at least one special roll tier.",
                    Icon = "x",
                })
                return
            end

            if not getRollSetSpecialPausedRemote() then
                mountNotify({
                    Title = "Special Roll",
                    Content = "RollService RemoteFunction not found under "
                        .. LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION
                        .. ".",
                    Icon = "x",
                })
                return
            end

            local okCount, failCount = pauseSelectedSpecialRollTiers()
            if okCount == 0 and failCount == 0 then
                mountNotify({
                    Title = "Special Roll",
                    Content = "Selected tiers are already paused or have no progression data yet.",
                    Icon = "x",
                })
                return
            end
            if failCount > 0 then
                mountNotify({
                    Title = "Special Roll",
                    Content = ("Paused %d tier(s); %d request(s) failed."):format(okCount, failCount),
                    Icon = "x",
                })
                return
            end
            mountNotify({
                Title = "Special Roll",
                Content = ("Paused %d special roll tier(s)."):format(okCount),
                Icon = "check",
            })
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Combine Special Roll",
        Flag = "main_auto_combine_special_roll",
        CurrentValue = false,
        Callback = function(enabled)
            autoCombineSpecialRollEnabled = enabled == true

            if not autoCombineSpecialRollEnabled then
                table.clear(specialRollCombineInvokePending)
                return
            end

            if #selectedSpecialRollTierKeys < 2 then
                mountNotify({
                    Title = "Special Roll",
                    Content = "Pick at least two tiers to combine.",
                    Icon = "x",
                })
                return
            end

            if not getRollSetSpecialPausedRemote() then
                mountNotify({
                    Title = "Special Roll",
                    Content = "RollService RemoteFunction not found under "
                        .. LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION
                        .. ".",
                    Icon = "x",
                })
                return
            end

            runAutoCombineSpecialRollPass()
        end,
    })

    MainTab:CreateSection("Auto Feed")

    local AUTO_FEED_NONE = "(None)"
    local AUTO_FEED_SYSTEM_FOODS: { { id: string, name: string, xp: number } } = {
        { id = "apple", name = "Cheese", xp = 75 },
        { id = "carrot", name = "Egg", xp = 100 },
        { id = "cherries", name = "Fries", xp = 125 },
        { id = "grapes", name = "Taco", xp = 150 },
        { id = "banana", name = "Hotdog", xp = 175 },
        { id = "watermelon", name = "Burger", xp = 200 },
        { id = "pizza", name = "Pizza", xp = 225 },
        { id = "chicken", name = "Chicken", xp = 250 },
        { id = "drumstick", name = "Drumstick", xp = 275 },
    }
    local AUTO_FEED_FOOD_BY_ID: { [string]: { id: string, name: string, xp: number } } = {}
    for _, food in ipairs(AUTO_FEED_SYSTEM_FOODS) do
        AUTO_FEED_FOOD_BY_ID[food.id] = food
    end
    local autoFeedFoodOptionToId: { [string]: string } = {}
    local selectedAutoFeedFoodIds: { string } = {}
    local AutoFeedFoodDropdown: any = nil
    local autoFeedFoodCycleIndex = 0
    local lastConsumablesList: Instance? = nil
    local consumablesListConns: { RBXScriptConnection } = {}
    local autoFeedOptionToUid: { [string]: string } = {}
    local selectedAutoFeedUid: string? = nil
    local selectedAutoFeedOption: string? = nil
    local AutoFeedSlimeDropdown: any = nil
    local autoFeedEnabled = false
    local autoFeedLoopToken = 0
    local AUTO_FEED_INTERVAL_SEC = 2.5

    local function mainTrimGuiText(s: string): string
        local t = string.gsub(s or "", "^%s+", "")
        t = string.gsub(t, "%s+$", "")
        t = string.gsub(t, "\r\n", " ")
        t = string.gsub(t, "\n", " ")
        return t
    end

    local function mainGuiInstanceTextContent(d: Instance): string
        if d:IsA("TextLabel") then
            return (d :: TextLabel).Text
        end
        if d:IsA("TextButton") then
            return (d :: TextButton).Text
        end
        if d:IsA("TextBox") then
            return (d :: TextBox).Text
        end
        return ""
    end

    -- …PlayerGui.Root.Inventory…DefaultItemsView.ConsumablesPanel.ConsumablesList
    local CONSUMABLES_LIST_PATH = {
        "Root",
        "Inventory",
        "PageItemsContent",
        "ItemsInventoryPage",
        "DefaultItemsView",
        "ConsumablesPanel",
        "ConsumablesList",
    }

    local function mainFindConsumablesList(): Instance?
        local lp = Players.LocalPlayer
        local pg = lp and lp:FindFirstChild("PlayerGui")
        if not pg then
            return nil
        end
        local cur: Instance? = pg
        for _, seg in ipairs(CONSUMABLES_LIST_PATH) do
            local nextInst = cur and cur:FindFirstChild(seg)
            if not nextInst then
                cur = nil
                break
            end
            cur = nextInst
        end
        if cur then
            return cur
        end
        return pg:FindFirstChild("ConsumablesList", true)
    end

    local function mainParseConsumableAmountText(s: string): number
        local t = mainTrimGuiText(s or "")
        local n = string.match(t, "[xX](%d+)")
        if n then
            return tonumber(n) or 0
        end
        n = string.match(t, "(%d+)")
        return tonumber(n) or 0
    end

    local function mainScanOwnedFoodByDisplayName(): { [string]: number }
        local out: { [string]: number } = {}
        local list = mainFindConsumablesList()
        if not list then
            return out
        end
        for _, ch in ipairs(list:GetChildren()) do
            if ch:IsA("GuiObject") and string.match(ch.Name, "ItemButton$") then
                local displayName = ""
                local nameFrame = ch:FindFirstChild("TextLabelFrame")
                if nameFrame then
                    local tl = nameFrame:FindFirstChild("TextLabel")
                    if tl and (tl:IsA("TextLabel") or tl:IsA("TextButton") or tl:IsA("TextBox")) then
                        displayName = mainTrimGuiText(mainGuiInstanceTextContent(tl))
                    end
                end
                local amt = 0
                local amtFrame = ch:FindFirstChild("Amount")
                if amtFrame then
                    local atl = amtFrame:FindFirstChild("TextLabel")
                    if atl and (atl:IsA("TextLabel") or atl:IsA("TextButton") or atl:IsA("TextBox")) then
                        amt = mainParseConsumableAmountText(mainGuiInstanceTextContent(atl))
                    end
                end
                if displayName ~= "" then
                    out[displayName] = (out[displayName] or 0) + amt
                end
            end
        end
        return out
    end

    local function mainFoodDropdownOptionLabel(displayName: string, xp: number, count: number): string
        if count > 0 then
            return ('%s  %d XP  x%d'):format(displayName, xp, count)
        end
        return ('%s  %d XP  x0'):format(displayName, xp)
    end

    local function mainBuildFoodDropdownOptions(): { string }
        local owned = mainScanOwnedFoodByDisplayName()
        table.clear(autoFeedFoodOptionToId)
        local foods: { { id: string, name: string, xp: number } } = {}
        for _, food in ipairs(AUTO_FEED_SYSTEM_FOODS) do
            table.insert(foods, food)
        end
        table.sort(foods, function(a, b)
            if a.xp ~= b.xp then
                return a.xp > b.xp
            end
            return a.name < b.name
        end)
        local opts: { string } = {}
        for _, food in ipairs(foods) do
            local count = owned[food.name] or 0
            local option = mainFoodDropdownOptionLabel(food.name, food.xp, count)
            autoFeedFoodOptionToId[option] = food.id
            table.insert(opts, option)
        end
        return opts
    end

    local function mainFoodDropdownOptionsForIds(ids: { string }): { string }
        local opts = mainBuildFoodDropdownOptions()
        local picked: { string } = {}
        for _, opt in ipairs(opts) do
            local id = autoFeedFoodOptionToId[opt]
            if id and table.find(ids, id) then
                table.insert(picked, opt)
            end
        end
        return picked
    end

    local function mainDisconnectConsumablesListeners()
        for _, c in ipairs(consumablesListConns) do
            c:Disconnect()
        end
        table.clear(consumablesListConns)
        lastConsumablesList = nil
    end

    local function refreshAutoFeedFoodDropdown(showNotify: boolean)
        local prevIds: { string } = {}
        for _, id in ipairs(selectedAutoFeedFoodIds) do
            table.insert(prevIds, id)
        end
        local opts = mainBuildFoodDropdownOptions()
        local newSelection = mainFoodDropdownOptionsForIds(prevIds)
        if AutoFeedFoodDropdown and AutoFeedFoodDropdown.Refresh then
            AutoFeedFoodDropdown:Refresh(opts)
        end
        selectedAutoFeedFoodIds = {}
        for _, opt in ipairs(newSelection) do
            local id = autoFeedFoodOptionToId[opt]
            if id then
                table.insert(selectedAutoFeedFoodIds, id)
            end
        end
        if AutoFeedFoodDropdown and AutoFeedFoodDropdown.Set then
            AutoFeedFoodDropdown:Set(newSelection)
        end
        if showNotify then
            mountNotify({
                Title = "Auto Feed",
                Content = "Food list updated (" .. tostring(#opts) .. " types, amounts from inventory).",
            })
        end
    end

    local function mainHookConsumableItemButton(btn: Instance)
        local amtFrame = btn:FindFirstChild("Amount")
        if not amtFrame then
            return
        end
        local atl = amtFrame:FindFirstChild("TextLabel")
        if atl and (atl:IsA("TextLabel") or atl:IsA("TextButton") or atl:IsA("TextBox")) then
            table.insert(consumablesListConns, atl:GetPropertyChangedSignal("Text"):Connect(function()
                refreshAutoFeedFoodDropdown(false)
            end))
        end
    end

    local function mainBindConsumablesListeners()
        mainDisconnectConsumablesListeners()
        local list = mainFindConsumablesList()
        if not list then
            return
        end
        lastConsumablesList = list
        local function bump()
            refreshAutoFeedFoodDropdown(false)
        end
        table.insert(consumablesListConns, list.ChildAdded:Connect(function(ch)
            mainHookConsumableItemButton(ch)
            bump()
        end))
        table.insert(consumablesListConns, list.ChildRemoved:Connect(bump))
        for _, ch in ipairs(list:GetChildren()) do
            mainHookConsumableItemButton(ch)
        end
    end

    local function mainEnsureConsumablesWatch()
        local list = mainFindConsumablesList()
        if list and list ~= lastConsumablesList then
            mainBindConsumablesListeners()
            refreshAutoFeedFoodDropdown(false)
        end
    end

    local function mainAutoFeedActiveFoodIds(): { string }
        local owned = mainScanOwnedFoodByDisplayName()
        local out: { string } = {}
        for _, id in ipairs(selectedAutoFeedFoodIds) do
            local def = AUTO_FEED_FOOD_BY_ID[id]
            if def and (owned[def.name] or 0) > 0 then
                table.insert(out, id)
            end
        end
        return out
    end

    local function mainAutoFeedNextFoodId(): string?
        local ids = mainAutoFeedActiveFoodIds()
        if #ids == 0 then
            return nil
        end
        autoFeedFoodCycleIndex = (autoFeedFoodCycleIndex % #ids) + 1
        return ids[autoFeedFoodCycleIndex]
    end

    local function mainAutoFeedOwnedAmountForFoodId(foodId: string): number
        local def = AUTO_FEED_FOOD_BY_ID[foodId]
        if not def then
            return 0
        end
        local owned = mainScanOwnedFoodByDisplayName()
        return math.clamp(math.floor(owned[def.name] or 0), 0, 9999)
    end

    local ODDS_SUFFIX_MULT: { [string]: number } = {
        K = 1e3,
        M = 1e6,
        B = 1e9,
        T = 1e12,
        Qd = 1e15,
        Qn = 1e18,
        Sx = 1e21,
        Sp = 1e24,
        O = 1e27,
        N = 1e30,
        De = 1e33,
        Ud = 1e36,
        Dd = 1e39,
        TdD = 1e42,
        QdD = 1e45,
        QnD = 1e48,
        SxD = 1e51,
        SpD = 1e54,
        OcD = 1e57,
        NvD = 1e60,
   
    }

    local function mainOddsSuffixMultiplier(suf: string): number
        if suf == "" then
            return 1
        end
        local lower = string.lower(suf)
        for key, mult in pairs(ODDS_SUFFIX_MULT) do
            if string.lower(key) == lower then
                return mult
            end
        end
        return 1
    end

    -- "1 / 119B" → numeric denominator for sort (higher = rarer).
    local function mainParseOddsSortKey(oddsText: string): number
        local t = mainTrimGuiText(oddsText or "")
        if t == "" then
            return 0
        end
        local rhs = string.match(t, "1%s*/%s*(.+)")
        if not rhs then
            rhs = t
        end
        rhs = mainTrimGuiText(rhs)
        local numStr, suf = string.match(rhs, "^([%d%.]+)%s*([%a]*)$")
        if not numStr then
            return 0
        end
        local n = tonumber(numStr)
        if type(n) ~= "number" or n ~= n then
            return 0
        end
        return n * mainOddsSuffixMultiplier(suf or "")
    end

    local function mainFindWorkspaceSlimesFolders(): { Instance }
        local out: { Instance } = {}
        for _, ch in ipairs(Workspace:GetChildren()) do
            if string.sub(ch.Name, 1, #"Gameplay") == "Gameplay" then
                local slimes = ch:FindFirstChild("Slimes")
                if slimes then
                    table.insert(out, slimes)
                end
            end
        end
        return out
    end

    local function mainGuiTextFromContentChild(content: Instance, childName: string): string
        local node = content:FindFirstChild(childName)
        if not node then
            return ""
        end
        if node:IsA("TextLabel") or node:IsA("TextButton") or node:IsA("TextBox") then
            local fromFmt = formatGuiInstanceTextForDisplay(node)
            if fromFmt then
                return mainTrimGuiText(fromFmt)
            end
            return mainTrimGuiText(mainGuiInstanceTextContent(node))
        end
        local tl = node:FindFirstChildWhichIsA("TextLabel", true)
        if tl then
            local fromFmt = formatGuiInstanceTextForDisplay(tl)
            if fromFmt then
                return mainTrimGuiText(fromFmt)
            end
            return mainTrimGuiText(mainGuiInstanceTextContent(tl))
        end
        return ""
    end

    local function mainSlimeBillboardNameAndOdds(slime: Instance): (string, string)
        local bb = slime:FindFirstChild("SlimeInfoBillboard", true)
        if not bb then
            return "", ""
        end
        local content = bb:FindFirstChild("Content")
        if not content then
            return "", ""
        end
        local name = mainGuiTextFromContentChild(content, "Name")
        local odds = ""
        local oddsFolder = content:FindFirstChild("Odds")
        if oddsFolder then
            local tl = oddsFolder:FindFirstChild("TextLabel")
            if tl and (tl:IsA("TextLabel") or tl:IsA("TextButton") or tl:IsA("TextBox")) then
                local fromFmt = formatGuiInstanceTextForDisplay(tl)
                odds = mainTrimGuiText(fromFmt or mainGuiInstanceTextContent(tl))
            else
                local any = oddsFolder:FindFirstChildWhichIsA("TextLabel", true)
                if any then
                    local fromFmt = formatGuiInstanceTextForDisplay(any)
                    odds = mainTrimGuiText(fromFmt or mainGuiInstanceTextContent(any))
                end
            end
        end
        return name, odds
    end

    local function mainNormalizeWorkspaceSlimeUid(uid: string): string
        return string.gsub(uid, "#%d+$", "")
    end

    local function mainScanFeedableSlimeOptions(): { string }
        table.clear(autoFeedOptionToUid)
        local slimeFolders = mainFindWorkspaceSlimesFolders()
        if #slimeFolders == 0 then
            return { AUTO_FEED_NONE }
        end
        type SlimeFeedRow = { uid: string, name: string, odds: string, sortKey: number }
        local rows: { SlimeFeedRow } = {}
        local seenUid: { [string]: boolean } = {}
        for _, folder in ipairs(slimeFolders) do
            for _, slime in ipairs(folder:GetChildren()) do
                local uid = mainNormalizeWorkspaceSlimeUid(lootUidFromInstance(slime) or slime.Name)
                if uid == "" or seenUid[uid] then
                    continue
                end
                seenUid[uid] = true
                local name, odds = mainSlimeBillboardNameAndOdds(slime)
                if name == "" then
                    name = slime.Name
                end
                table.insert(rows, {
                    uid = uid,
                    name = name,
                    odds = odds,
                    sortKey = mainParseOddsSortKey(odds),
                })
            end
        end
        table.sort(rows, function(a, b)
            if a.sortKey ~= b.sortKey then
                return a.sortKey > b.sortKey
            end
            if a.name ~= b.name then
                return a.name < b.name
            end
            return a.uid < b.uid
        end)
        local opts: { string } = { AUTO_FEED_NONE }
        for _, row in ipairs(rows) do
            local option: string
            if row.odds ~= "" then
                option = ('%s  %s'):format(row.name, row.odds)
            else
                option = ('%s'):format(row.name)
            end
            if #option > 190 then
                option = string.sub(option, 1, 187) .. "..."
            end
            if not autoFeedOptionToUid[option] then
                autoFeedOptionToUid[option] = row.uid
                table.insert(opts, option)
            end
        end
        if #opts == 1 then
            return { AUTO_FEED_NONE }
        end
        return opts
    end

    local function refreshAutoFeedSlimeDropdown(showNotify: boolean)
        local opts = mainScanFeedableSlimeOptions()
        if AutoFeedSlimeDropdown and AutoFeedSlimeDropdown.Refresh then
            AutoFeedSlimeDropdown:Refresh(opts)
        end
        if selectedAutoFeedOption and not table.find(opts, selectedAutoFeedOption) then
            selectedAutoFeedOption = nil
            selectedAutoFeedUid = nil
            if AutoFeedSlimeDropdown and AutoFeedSlimeDropdown.Select then
                AutoFeedSlimeDropdown:Select(nil)
            end
            if AutoFeedSlimeDropdown and AutoFeedSlimeDropdown.Set then
                AutoFeedSlimeDropdown:Set({ AUTO_FEED_NONE })
            end
        end
        if showNotify then
            mountNotify({
                Title = "Auto Feed",
                Content = #opts > 1 and ("Slime list updated (" .. tostring(#opts - 1) .. ", sorted rarest first).") or 'No slimes under Workspace → Gameplay* → Slimes (with SlimeInfoBillboard).',
            })
        end
    end

    AutoFeedFoodDropdown = MainTab:CreateDropdown({
        Name = "Foods",
        Flag = "main_auto_feed_food_dropdown",
        Options = mainBuildFoodDropdownOptions(),
        CurrentOption = {},
        MultipleOptions = true,
        Search = true,
        Callback = function(value)
            selectedAutoFeedFoodIds = {}
            if type(value) == "table" then
                for _, opt in ipairs(value) do
                    if type(opt) == "string" then
                        local id = autoFeedFoodOptionToId[opt]
                        if id and not table.find(selectedAutoFeedFoodIds, id) then
                            table.insert(selectedAutoFeedFoodIds, id)
                        end
                    end
                end
            elseif type(value) == "string" then
                local id = autoFeedFoodOptionToId[value]
                if id then
                    selectedAutoFeedFoodIds = { id }
                end
            end
        end,
    })

    AutoFeedSlimeDropdown = MainTab:CreateDropdown({
        Name = "Slime",
        Flag = "main_auto_feed_slime_dropdown",
        Options = mainScanFeedableSlimeOptions(),
        CurrentOption = { AUTO_FEED_NONE },
        Search = true,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            selectedAutoFeedOption = if type(picked) == "string" then picked else nil
            if not selectedAutoFeedOption or selectedAutoFeedOption == AUTO_FEED_NONE then
                selectedAutoFeedUid = nil
                return
            end
            selectedAutoFeedUid = autoFeedOptionToUid[selectedAutoFeedOption]
        end,
    })

    MainTab:CreateButton({
        Name = "Refresh slime list",
        Flag = "main_auto_feed_refresh_slimes",
        Callback = function()
            refreshAutoFeedSlimeDropdown(true)
        end,
    })

    task.defer(function()
        mainEnsureConsumablesWatch()
        refreshAutoFeedFoodDropdown(false)
    end)

    local lpForConsumables = Players.LocalPlayer
    if lpForConsumables then
        local pgWatch = lpForConsumables:FindFirstChild("PlayerGui") or lpForConsumables:WaitForChild("PlayerGui", 30)
        if pgWatch then
            pgWatch.DescendantAdded:Connect(function()
                mainEnsureConsumablesWatch()
            end)
        end
    end

    MainTab:CreateToggle({
        Name = "Auto Feed",
        Flag = "main_auto_feed_enabled",
        CurrentValue = false,
        Callback = function(enabled)
            autoFeedEnabled = enabled == true
            autoFeedLoopToken = autoFeedLoopToken + 1
            local myToken = autoFeedLoopToken

            if not autoFeedEnabled then
                return
            end

            mainEnsureConsumablesWatch()
            refreshAutoFeedFoodDropdown(false)
            refreshAutoFeedSlimeDropdown(false)

            task.spawn(function()
                while myToken == autoFeedLoopToken and autoFeedEnabled do
                    local foodId = mainAutoFeedNextFoodId()
                    if not foodId then
                        task.wait(AUTO_FEED_INTERVAL_SEC)
                    else
                        local useUid = selectedAutoFeedUid
                        if not useUid then
                            task.wait(AUTO_FEED_INTERVAL_SEC)
                        else
                            local inv = findNetworkerServiceRemotesFolder("InventoryService")
                            local rf = inv and inv:FindFirstChild("RemoteFunction")
                            if not rf or not rf:IsA("RemoteFunction") then
                                task.wait(AUTO_FEED_INTERVAL_SEC)
                            else
                                if mainAutoFeedOwnedAmountForFoodId(foodId) > 0 then
                                    pcall(function()
                                        (rf :: RemoteFunction):InvokeServer("requestUseFood", foodId, useUid, 1)
                                    end)
                                end
                                task.wait(AUTO_FEED_INTERVAL_SEC)
                            end
                        end
                    end
                end
            end)
        end,
    })

    MainTab:CreateSection("Auto Equip Slimes")

    local autoEquipBestEnabled = false
    local autoEquipBestLoopToken = 0
    local AUTO_EQUIP_BEST_INTERVAL_SEC = 30

    MainTab:CreateToggle({
        Name = "Auto Equip Best",
        Flag = "main_auto_equip_best",
        CurrentValue = false,
        Callback = function(enabled)
            autoEquipBestEnabled = enabled == true
            autoEquipBestLoopToken = autoEquipBestLoopToken + 1
            local myToken = autoEquipBestLoopToken

            if not autoEquipBestEnabled then
                return
            end

            task.spawn(function()
                while myToken == autoEquipBestLoopToken and autoEquipBestEnabled do
                    local inv = findNetworkerServiceRemotesFolder("InventoryService")
                    local rf = inv and inv:FindFirstChild("RemoteFunction")
                    if inv and rf and rf:IsA("RemoteFunction") then
                        pcall(function()
                            (rf :: RemoteFunction):InvokeServer("requestEquipBest")
                        end)
                    end
                    task.wait(AUTO_EQUIP_BEST_INTERVAL_SEC)
                end
            end)
        end,
    })

    MainTab:CreateSection("Upgrades")

    local UPGRADE_LEVEL_STAT_KEYS: { string } = {
        "rollSpeed",
        "luck",
        "walkSpeed",
        "coinIncome",
        "enemySpawnSpeed",
        "slimeTargetRange",
        "magnetRadius",
        "goopDropRate",
        "doubleGoop",
        "overkill",
        "slimeGunDamage",
        "slimeGunFireRate",
        "slimeGunRange",
        "extraRollChance",
        "bonusRolls",
        "cloverRolls",
    }
    local UPGRADE_MUTATION_KINDS: { string } = { "big", "huge", "shiny", "inverted" }
    local UPGRADE_OWNED_DISPLAY_MAX = 40

    local UpgradeUtilsParagraph = MainTab:CreateParagraph({
        Title = "UpgradeServiceUtils",
        Content = "Loading…",
    })
    local UpgradeLuckRollsParagraph = MainTab:CreateParagraph({
        Title = "Luck roll cadence",
        Content = "Loading…",
    })
    local UpgradeOwnedParagraph = MainTab:CreateParagraph({
        Title = "Owned upgrades",
        Content = "Waiting for upgrades data…",
    })
    local UpgradeStatsParagraph = MainTab:CreateParagraph({
        Title = "Computed stats",
        Content = "Loading…",
    })

    local function setUpgradeParagraph(paragraph: any, title: string, content: string)
        if paragraph and paragraph.Set then
            paragraph:Set({ Title = title, Content = content })
        end
    end

    local function formatUpgradePercentFromMultiplier(mult: number): string
        return ("%d%%"):format(math.round((mult - 1) * 100))
    end

    local function buildUpgradeUtilsParagraphBody(): string
        local loaded = tryLoadUpgradeServiceUtils()
        if not loaded then
            return upgradeUtilsLoadError or "Failed to load UpgradeServiceUtils."
        end
        local saveKeyCount = 0
        for _ in pairs(playerUpgradesSave) do
            saveKeyCount = saveKeyCount + 1
        end
        local lines: { string } = {
            "Module: loaded",
            ("Keys in upgrades save: %d"):format(saveKeyCount),
        }
        local enums = upgradeServiceUtils.enums
        if type(enums) == "table" and type(enums.levelBasedUpgrades) == "table" then
            local statCount = 0
            for _ in pairs(enums.levelBasedUpgrades) do
                statCount = statCount + 1
            end
            table.insert(lines, ("Level-based stat tables: %d"):format(statCount))
        end
        return table.concat(lines, "\n")
    end

    local function buildUpgradeLuckRollsParagraphBody(): string
        if not tryLoadUpgradeServiceUtils() then
            return upgradeUtilsLoadError or "UpgradeServiceUtils not loaded."
        end
        local enums = upgradeServiceUtils.enums
        local luckRolls = enums and enums.luckRolls
        if type(luckRolls) ~= "table" then
            return "enums.luckRolls not available."
        end
        local lines: { string } = {}
        for _, kind in ipairs(UPGRADE_LUCK_ROLL_KINDS) do
            local cadence = luckRolls[kind]
            if type(cadence) == "table" then
                table.insert(
                    lines,
                    ("%s: every %s / %s / %s rolls (tiers 1–3)"):format(
                        kind:sub(1, 1):upper() .. kind:sub(2),
                        tostring(cadence[1] or "?"),
                        tostring(cadence[2] or "?"),
                        tostring(cadence[3] or "?")
                    )
                )
            end
        end
        if #lines == 0 then
            return "No luck roll cadence data."
        end
        return table.concat(lines, "\n")
    end

    function buildUpgradeOwnedParagraphBody(): string
        local keys: { string } = {}
        for id, owned in pairs(playerUpgradesSave) do
            if owned == true then
                table.insert(keys, id)
            end
        end
        table.sort(keys)
        if #keys == 0 then
            if next(playerUpgradesSave) == nil then
                return 'No upgrades save yet. Listen for DataService (1, "upgrades", …) or open the upgrades UI in-game.'
            end
            return "No upgrade flags set to true in save table."
        end
        local lines: { string } = { ("Total owned: %d"):format(#keys) }
        local show = math.min(#keys, UPGRADE_OWNED_DISPLAY_MAX)
        for i = 1, show do
            table.insert(lines, keys[i])
        end
        if #keys > show then
            table.insert(lines, ("… and %d more"):format(#keys - show))
        end
        return table.concat(lines, "\n")
    end

    function buildUpgradeStatsParagraphBody(): string
        if not tryLoadUpgradeServiceUtils() then
            return upgradeUtilsLoadError or "UpgradeServiceUtils not loaded."
        end
        local utils = upgradeServiceUtils
        local save = playerUpgradesSave
        local lines: { string } = {}

        for _, statKey in ipairs(UPGRADE_LEVEL_STAT_KEYS) do
            local lvl = utils.getUpgradeLevel(statKey, save)
            local val = utils.getUpgradeValue(statKey, lvl)
            if type(val) == "number" then
                if statKey == "extraRollChance" or statKey == "doubleGoop" or statKey == "goopDropRate" then
                    table.insert(lines, ("%s: level %d → %d%%"):format(statKey, lvl, math.round(val * 100)))
                elseif val >= 0.05 and val <= 50 and statKey ~= "magnetRadius" and statKey ~= "slimeGunRange" then
                    table.insert(
                        lines,
                        ("%s: level %d → %s (%s)"):format(statKey, lvl, tostring(val), formatUpgradePercentFromMultiplier(val))
                    )
                else
                    table.insert(lines, ("%s: level %d → %s"):format(statKey, lvl, tostring(val)))
                end
            end
        end

        if type(utils.getGoopDropRate) == "function" then
            table.insert(lines, ("goopDropRate (computed): %d%%"):format(math.round(utils.getGoopDropRate(save) * 100)))
        end
        if type(utils.getDoubleGoopChance) == "function" then
            table.insert(
                lines,
                ("doubleGoop (computed): %d%%"):format(math.round(utils.getDoubleGoopChance(save) * 100))
            )
        end

        table.insert(lines, "")
        table.insert(lines, "Mutations unlocked:")
        for _, kind in ipairs(UPGRADE_MUTATION_KINDS) do
            local unlocked = false
            if type(utils.isMutationUnlocked) == "function" then
                unlocked = utils.isMutationUnlocked(kind, save) == true
            end
            table.insert(lines, ("  %s: %s"):format(kind, unlocked and "yes" or "no"))
        end

        if type(utils.getUnlockedMutations) == "function" then
            local muts = utils.getUnlockedMutations(save)
            if type(muts) == "table" then
                local names: { string } = {}
                for name, on in pairs(muts) do
                    if on == true then
                        table.insert(names, tostring(name))
                    end
                end
                table.sort(names)
                if #names > 0 then
                    table.insert(lines, "  active: " .. table.concat(names, ", "))
                end
            end
        end

        return table.concat(lines, "\n")
    end

    function refreshUpgradeParagraphs()
        setUpgradeParagraph(UpgradeUtilsParagraph, "UpgradeServiceUtils", buildUpgradeUtilsParagraphBody())
        setUpgradeParagraph(UpgradeLuckRollsParagraph, "Luck roll cadence", buildUpgradeLuckRollsParagraphBody())
        setUpgradeParagraph(UpgradeOwnedParagraph, "Owned upgrades", buildUpgradeOwnedParagraphBody())
        setUpgradeParagraph(UpgradeStatsParagraph, "Computed stats", buildUpgradeStatsParagraphBody())
    end

    function runUpgradesSectionRefresh()
        tryLoadUpgradeServiceUtils()
        tryPullPlayerUpgradesFromDataService()
        tryPullSpecialRollProgressionFromDataService()
        refreshUpgradeParagraphs()
    end

    MainTab:CreateButton({
        Name = "Refresh upgrades",
        Flag = "main_upgrades_refresh",
        Callback = function()
            runUpgradesSectionRefresh()
        end,
    })

    task.defer(runUpgradesSectionRefresh)
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
        Flag = "others_tp_location",
        CurrentValue = teleportInputValue,
        Callback = function(value)
            teleportInputValue = value
        end,
    })

    local TeleportLookInput = TeleportTab:CreateInput({
        Name = "Look direction",
        PlaceholderText = "e.g. 0, 0, -1 or leave empty for position only",
        Flag = "others_tp_lookDirection",
        CurrentValue = teleportLookInputValue,
        Callback = function(value)
            teleportLookInputValue = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Get Current Location",
        Flag = "tp_get_current_location",
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
                Content = "Position: " .. text .. " · Look: " .. lookText,
            })
        end,
    })
    TeleportTab:CreateButton({
        Name = "Teleport",
        Flag = "tp_teleport_to_coords",
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
        Flag = "tp_tween_duration",
        CurrentValue = tweenDurationValue,
        Callback = function(value)
            tweenDurationValue = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Tween to Location",
        Flag = "tp_tween_to_location",
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
        Flag = "tp_player_dropdown",
        Options = playerDisplayNames,
        CurrentOption = {},
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            selectedTeleportPlayer = nil
            if picked then
                local idx = table.find(playerDisplayNames, picked)
                if idx and playerList[idx] then
                    selectedTeleportPlayer = playerList[idx]
                end
            end
        end
    })

    TeleportTab:CreateButton({
        Name = "Refresh",
        Flag = "tp_players_refresh",
        Callback = function()
            refreshPlayerList(true)
        end
    })
    TeleportTab:CreateButton({
        Name = "Teleport",
        Flag = "tp_teleport_to_player",
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

    -- Nested tree: only under Instance types selected in Show Children (see section at top of this tab).
    local OBJECTS_TREE_MAX_DEPTH = 14
    local OBJECTS_TREE_MAX_LINES = 3000
    -- WindUI / Roblox TextLabel can clip very long descriptions; split across extra Paragraphs.
    local OBJECTS_CHILDREN_DESC_MAX_CHARS = 4000
    local OBJECTS_CHILDREN_PARAGRAPH_DESC = "Nested under the types you enable in Show Children (name sort; max depth "
        .. OBJECTS_TREE_MAX_DEPTH
        .. ", max "
        .. OBJECTS_TREE_MAX_LINES
        .. " lines). Long output splits into extra paragraphs (~"
        .. OBJECTS_CHILDREN_DESC_MAX_CHARS
        .. " chars each)."

    -- Multi-select: which ClassNames recurse when listing children (IsA match).
    local OBJECTS_NEST_CLASS_OPTIONS: { string } = {
        "Accessory",
        "Actor",
        "Attachment",
        "Backpack",
        "BillboardGui",
        "BodyColors",
        "Camera",
        "CanvasGroup",
        "Configuration",
        "CornerWedgePart",
        "Folder",
        "Frame",
        "Humanoid",
        "ImageButton",
        "ImageLabel",
        "MeshPart",
        "Model",
        "ModuleScript",
        "Part",
        "PlayerGui",
        "ProximityPrompt",
        "ScreenGui",
        "ScrollingFrame",
        "StarterGear",
        "StarterPack",
        "SurfaceGui",
        "Terrain",
        "TextBox",
        "TextButton",
        "TextLabel",
        "Tool",
        "TrussPart",
        "UIGradient",
        "UIScale",
        "UnionOperation",
        "VehicleSeat",
        "WedgePart",
    }
    local OBJECTS_NEST_EXPAND_DEFAULT: { string } = {
        "Backpack",
        "BillboardGui",
        "Frame",
        "Folder",
        "PlayerGui",
        "ScreenGui",
    }
    local objectsNestExpandClassSet: { [string]: boolean } = {}

    local function syncObjectsNestExpandClassSetFromDropdownValue(value: any)
        local s: { [string]: boolean } = {}
        if type(value) == "table" then
            for _, item in ipairs(value) do
                local name = (type(item) == "table" and item.Title) or item
                if type(name) == "string" and name ~= "" then
                    s[name] = true
                end
            end
        elseif type(value) == "string" and value ~= "" then
            s[value] = true
        end
        objectsNestExpandClassSet = s
    end

    syncObjectsNestExpandClassSetFromDropdownValue(OBJECTS_NEST_EXPAND_DEFAULT)
    local OBJECTS_NONE = "(None)"
    local NESTED_CHILDREN_TITLE = "Children (nested)"

    local function objectDropdownOptions(items)
        local o = { OBJECTS_NONE }
        for _, x in ipairs(items) do
            table.insert(o, x)
        end
        return o
    end


    local function splitStringForParagraphChunks(s: string, maxChunk: number): { string }
        if maxChunk < 256 then
            maxChunk = 256
        end
        if s == nil or s == "" then
            return { "" }
        end
        if #s <= maxChunk then
            return { s }
        end
        local chunks: { string } = {}
        local pos = 1
        local n = #s
        while pos <= n do
            local endPos = math.min(pos + maxChunk - 1, n)
            if endPos < n then
                local searchStart = math.max(pos, endPos - 500)
                local cut = 0
                for i = endPos, searchStart, -1 do
                    if string.byte(s, i) == 10 then
                        cut = i
                        break
                    end
                end
                if cut > pos then
                    endPos = cut
                end
            end
            table.insert(chunks, string.sub(s, pos, endPos))
            pos = endPos + 1
        end
        if #chunks == 0 then
            return { s }
        end
        return chunks
    end

    local function clearObjectsTabOverflowParagraphs(refs: { any })
        for i = #refs, 1, -1 do
            local p = refs[i]
            if p then
                pcall(function()
                    if type(p.Destroy) == "function" then
                        p:Destroy()
                    end
                end)
            end
            table.remove(refs, i)
        end
    end

    local function setNestedChildrenParagraphsWithOverflow(
        section,
        primaryParagraph,
        overflowParagraphRefs: { any },
        text: string?,
        continuationTitleBase: string,
        emptyPlaceholder: string
    )
        clearObjectsTabOverflowParagraphs(overflowParagraphRefs)
        if not (primaryParagraph and primaryParagraph.Set) then
            return
        end
        local body = (text and text ~= "") and text or emptyPlaceholder
        local chunks = splitStringForParagraphChunks(body, OBJECTS_CHILDREN_DESC_MAX_CHARS)
        primaryParagraph:Set({
            Title = continuationTitleBase,
            Content = chunks[1] or body,
        })
        for ci = 2, #chunks do
            local newP = section:CreateParagraph({
                Title = continuationTitleBase .. " (part " .. tostring(ci) .. ")",
                Content = chunks[ci],
            })
            table.insert(overflowParagraphRefs, newP)
        end
    end

    local function shouldNestChildrenInObjectsTree(inst: Instance): boolean
        if next(objectsNestExpandClassSet) == nil then
            return false
        end
        for className, _ in pairs(objectsNestExpandClassSet) do
            if inst:IsA(className) then
                return true
            end
        end
        return false
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

    -- WindUI passes the selected entry from Values as-is. Duplicate display strings
    -- would collide on a string-keyed map and break selection; use { Title, Instance }.
    local function buildObjectsServiceDropdownValues(children: { Instance }): { any }
        local displayCounts: { [string]: number } = {}
        local values: { any } = {}
        for _, child in ipairs(children) do
            local display = formatInstanceDisplay(child, nil, true)
            local c = (displayCounts[display] or 0) + 1
            displayCounts[display] = c
            local title = display
            if c > 1 then
                title = display .. "  [" .. child:GetDebugId() .. "]"
            end
            table.insert(values, { Title = title, Instance = child })
        end
        return values
    end

    local function buildInstancePathUnderAncestor(inst: Instance, ancestor: Instance): string
        if not ancestor or not inst then
            return inst and inst.Name or ""
        end
        if not inst:IsDescendantOf(ancestor) then
            return inst.Name
        end
        local parts = {}
        local cur: Instance? = inst
        while cur and cur ~= ancestor do
            table.insert(parts, 1, cur.Name)
            cur = cur.Parent
        end
        return table.concat(parts, ".")
    end

    local function runObjectsTabFindInstanceByName(
        root: Instance?,
        primaryParagraph: any,
        overflowParagraphRefs: { any },
        emptyPlaceholder: string,
        queryRaw: string,
        underDescription: string
    )
        if not root then
            mountNotify({ Title = underDescription, Content = "Root not available.", Icon = "x" })
            return
        end
        local raw = tostring(queryRaw or "")
        local q = string.gsub(string.gsub(raw, "^%s+", ""), "%s+$", "")
        if q == "" then
            mountNotify({
                Title = "Find (" .. underDescription .. ")",
                Content = "Enter text to match Instance.Name.",
                Icon = "x",
            })
            return
        end
        local ql = string.lower(q)
        local matches: { Instance } = {}
        for _, d in ipairs(root:GetDescendants()) do
            if string.find(string.lower(d.Name), ql, 1, true) then
                table.insert(matches, d)
            end
        end
        table.sort(matches, function(a, b)
            return string.lower(buildInstancePathUnderAncestor(a, root))
                < string.lower(buildInstancePathUnderAncestor(b, root))
        end)
        if #matches == 0 then
            setNestedChildrenParagraphsWithOverflow(
                ObjectsTab,
                primaryParagraph,
                overflowParagraphRefs,
                "No matches for \"" .. q .. "\" under " .. underDescription .. ".",
                NESTED_CHILDREN_TITLE,
                emptyPlaceholder
            )
            mountNotify({
                Title = "Find (" .. underDescription .. ")",
                Content = "No matching instances.",
                Icon = "x",
            })
            return
        end
        local pathLines: { string } = {}
        for _, m in ipairs(matches) do
            table.insert(pathLines, buildInstancePathUnderAncestor(m, root))
        end
        local pathsBlock = (#matches == 1) and ("Found:\n" .. pathLines[1])
            or ("Matches (" .. tostring(#matches) .. "):\n" .. table.concat(pathLines, "\n"))
        local target = matches[1]
        local tree = buildNestedObjectChildrenListText(target)
        local note = (#matches > 1) and "\n\n(Showing nested children for the first match; narrow the name to disambiguate.)\n\n" or "\n\n"
        local combined = pathsBlock .. note .. tree
        setNestedChildrenParagraphsWithOverflow(
            ObjectsTab,
            primaryParagraph,
            overflowParagraphRefs,
            combined,
            NESTED_CHILDREN_TITLE,
            emptyPlaceholder
        )
        mountNotify({
            Title = "Find (" .. underDescription .. ")",
            Content = (#matches == 1) and "1 match."
                or (tostring(#matches) .. " matches; nested tree is for the first."),
            Icon = "check",
        })
    end

    ObjectsTab:CreateSection("Show Children")
    local ObjectsNestClassesDropdown
    do
        local nestDefaultCopy: { string } = {}
        for _, v in ipairs(OBJECTS_NEST_EXPAND_DEFAULT) do
            table.insert(nestDefaultCopy, v)
        end
        ObjectsNestClassesDropdown = ObjectsTab:CreateDropdown({
            Name = "Types to expand in nested tree",
            Options = OBJECTS_NEST_CLASS_OPTIONS,
            CurrentOption = nestDefaultCopy,
            MultipleOptions = true, Search = true, Ext = true,
            Callback = function(value)
                syncObjectsNestExpandClassSetFromDropdownValue(value)
            end,
        })
    end
    if ObjectsNestClassesDropdown and ObjectsNestClassesDropdown.Value ~= nil then
        syncObjectsNestExpandClassSetFromDropdownValue(ObjectsNestClassesDropdown.Value)
    end
    ObjectsTab:CreateParagraph({
        Title = "Why some rows have no nested lines",
        Content = "Indented children only continue under ClassNames enabled in the dropdown (IsA match). Defaults include Frame and ScreenGui but not ImageLabel or ImageButton, so those nodes appear as one line until you enable those types—on purpose, so large PlayerGui dumps stay smaller.",
    })
    ObjectsTab:CreateSection("ReplicatedStorage")
    local ReplicatedStorageDropdown
    local ReplicatedStorageChildrenParagraph
    local rsChildrenOverflowParagraphs = {}
    local rsFindByNameQuery = ""

    local rsTitleList = {}
    local rsTitleToInstance = {}

    local function refreshReplicatedStorageList()
        local rows = buildObjectsServiceDropdownValues(ReplicatedStorage:GetChildren())
        rsTitleList = {}
        rsTitleToInstance = {}
        for _, row in ipairs(rows) do
            table.insert(rsTitleList, row.Title)
            rsTitleToInstance[row.Title] = row.Instance
        end
        if ReplicatedStorageDropdown and ReplicatedStorageDropdown.Refresh then
            ReplicatedStorageDropdown:Refresh(objectDropdownOptions(rsTitleList))
        end
        mountNotify({ Title = "ReplicatedStorage", Content = "Listed " .. #rsTitleList .. " objects", Icon = "check" })
    end

    ReplicatedStorageDropdown = ObjectsTab:CreateDropdown({
        Name = "ReplicatedStorage (key = value)",
        Options = objectDropdownOptions(rsTitleList),
        CurrentOption = { OBJECTS_NONE },
        Search = true,
        Ext = true,
        Callback = function(opts)
            local selectedDisplay = type(opts) == "table" and opts[1] or opts
            if not selectedDisplay or selectedDisplay == OBJECTS_NONE then
                setNestedChildrenParagraphsWithOverflow(
                    ObjectsTab,
                    ReplicatedStorageChildrenParagraph,
                    rsChildrenOverflowParagraphs,
                    nil,
                    NESTED_CHILDREN_TITLE,
                    "Select an object above to list its children"
                )
                return
            end
            local inst = rsTitleToInstance[selectedDisplay]
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                ObjectsTab,
                ReplicatedStorageChildrenParagraph,
                rsChildrenOverflowParagraphs,
                text,
                NESTED_CHILDREN_TITLE,
                "Select an object above to list its children"
            )
        end,
    })

    ReplicatedStorageChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = NESTED_CHILDREN_TITLE,
        Content = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Ext = true,
        Callback = function()
            refreshReplicatedStorageList()
        end,
    })

    ObjectsTab:CreateInput({
        Name = "Find instance by name (under ReplicatedStorage)",
        PlaceholderText = "Substring match on Instance.Name",
        Ext = true,
        CurrentValue = rsFindByNameQuery,
        Callback = function(value)
            rsFindByNameQuery = value
        end,
    })

    ObjectsTab:CreateButton({
        Name = "Find",
        Ext = true,
        Callback = function()
            runObjectsTabFindInstanceByName(
                ReplicatedStorage,
                ReplicatedStorageChildrenParagraph,
                rsChildrenOverflowParagraphs,
                "Select an object above to list its children",
                rsFindByNameQuery,
                "ReplicatedStorage"
            )
        end,
    })

    ObjectsTab:CreateSection("Players")
    local PlayersServiceDropdown
    local PlayersServiceChildrenParagraph
    local plrsChildrenOverflowParagraphs = {}
    local plrsFindByNameQuery = ""

    local plrsTitleList = {}
    local plrsTitleToInstance = {}

    local function refreshPlayersServiceList()
        local rows = buildObjectsServiceDropdownValues(Players:GetChildren())
        plrsTitleList = {}
        plrsTitleToInstance = {}
        for _, row in ipairs(rows) do
            table.insert(plrsTitleList, row.Title)
            plrsTitleToInstance[row.Title] = row.Instance
        end
        if PlayersServiceDropdown and PlayersServiceDropdown.Refresh then
            PlayersServiceDropdown:Refresh(objectDropdownOptions(plrsTitleList))
        end
        mountNotify({ Title = "Players", Content = "Listed " .. #plrsTitleList .. " players", Icon = "check" })
    end

    PlayersServiceDropdown = ObjectsTab:CreateDropdown({
        Name = "Players (key = value)",
        Options = objectDropdownOptions(plrsTitleList),
        CurrentOption = { OBJECTS_NONE },
        Search = true,
        Ext = true,
        Callback = function(opts)
            local selectedDisplay = type(opts) == "table" and opts[1] or opts
            if not selectedDisplay or selectedDisplay == OBJECTS_NONE then
                setNestedChildrenParagraphsWithOverflow(
                    ObjectsTab,
                    PlayersServiceChildrenParagraph,
                    plrsChildrenOverflowParagraphs,
                    nil,
                    NESTED_CHILDREN_TITLE,
                    "Select a player above to list their children"
                )
                return
            end
            local inst = plrsTitleToInstance[selectedDisplay]
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                ObjectsTab,
                PlayersServiceChildrenParagraph,
                plrsChildrenOverflowParagraphs,
                text,
                NESTED_CHILDREN_TITLE,
                "Select a player above to list their children"
            )
        end,
    })

    PlayersServiceChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = NESTED_CHILDREN_TITLE,
        Content = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Ext = true,
        Callback = function()
            refreshPlayersServiceList()
        end,
    })

    ObjectsTab:CreateInput({
        Name = "Find instance by name (under Players)",
        PlaceholderText = "Substring match on Instance.Name",
        Ext = true,
        CurrentValue = plrsFindByNameQuery,
        Callback = function(value)
            plrsFindByNameQuery = value
        end,
    })

    ObjectsTab:CreateButton({
        Name = "Find",
        Ext = true,
        Callback = function()
            runObjectsTabFindInstanceByName(
                Players,
                PlayersServiceChildrenParagraph,
                plrsChildrenOverflowParagraphs,
                "Select a player above to list their children",
                plrsFindByNameQuery,
                "Players"
            )
        end,
    })

    ObjectsTab:CreateSection("Local Player")
    local LocalPlayerDropdown
    local LocalPlayerChildrenParagraph
    local lpChildrenOverflowParagraphs = {}
    local localPlayerFindByNameQuery = ""

    local lpTitleList = {}
    local lpTitleToInstance = {}

    local function refreshLocalPlayerList()
        local localPlayer = Players.LocalPlayer
        local rows = buildObjectsServiceDropdownValues(localPlayer:GetChildren())
        lpTitleList = {}
        lpTitleToInstance = {}
        for _, row in ipairs(rows) do
            table.insert(lpTitleList, row.Title)
            lpTitleToInstance[row.Title] = row.Instance
        end
        if LocalPlayerDropdown and LocalPlayerDropdown.Refresh then
            LocalPlayerDropdown:Refresh(objectDropdownOptions(lpTitleList))
        end
        mountNotify({ Title = "Local Player", Content = "Listed " .. #lpTitleList .. " objects", Icon = "check" })
    end

    LocalPlayerDropdown = ObjectsTab:CreateDropdown({
        Name = "Local Player (key = value)",
        Options = objectDropdownOptions(lpTitleList),
        CurrentOption = { OBJECTS_NONE },
        Search = true,
        Ext = true,
        Callback = function(opts)
            local selectedDisplay = type(opts) == "table" and opts[1] or opts
            if not selectedDisplay or selectedDisplay == OBJECTS_NONE then
                setNestedChildrenParagraphsWithOverflow(
                    ObjectsTab,
                    LocalPlayerChildrenParagraph,
                    lpChildrenOverflowParagraphs,
                    nil,
                    NESTED_CHILDREN_TITLE,
                    "Select an object above to list its children"
                )
                return
            end
            local inst = lpTitleToInstance[selectedDisplay]
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                ObjectsTab,
                LocalPlayerChildrenParagraph,
                lpChildrenOverflowParagraphs,
                text,
                NESTED_CHILDREN_TITLE,
                "Select an object above to list its children"
            )
        end,
    })

    LocalPlayerChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = NESTED_CHILDREN_TITLE,
        Content = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Ext = true,
        Callback = function()
            refreshLocalPlayerList()
        end,
    })

    ObjectsTab:CreateInput({
        Name = "Find instance by name (under LocalPlayer)",
        PlaceholderText = "Substring match on Instance.Name",
        Ext = true,
        CurrentValue = localPlayerFindByNameQuery,
        Callback = function(value)
            localPlayerFindByNameQuery = value
        end,
    })

    ObjectsTab:CreateButton({
        Name = "Find",
        Ext = true,
        Callback = function()
            runObjectsTabFindInstanceByName(
                Players.LocalPlayer,
                LocalPlayerChildrenParagraph,
                lpChildrenOverflowParagraphs,
                "Select an object above to list its children",
                localPlayerFindByNameQuery,
                "LocalPlayer"
            )
        end,
    })

    ObjectsTab:CreateSection("Workspace")
    local WorkspaceDropdown
    local WorkspaceChildrenParagraph
    local wsChildrenOverflowParagraphs = {}
    local wsFindByNameQuery = ""

    local wsTitleList = {}
    local wsTitleToInstance = {}

    local function refreshWorkspaceList()
        local rows = buildObjectsServiceDropdownValues(Workspace:GetChildren())
        wsTitleList = {}
        wsTitleToInstance = {}
        for _, row in ipairs(rows) do
            table.insert(wsTitleList, row.Title)
            wsTitleToInstance[row.Title] = row.Instance
        end
        if WorkspaceDropdown and WorkspaceDropdown.Refresh then
            WorkspaceDropdown:Refresh(objectDropdownOptions(wsTitleList))
        end
        mountNotify({ Title = "Workspace", Content = "Listed " .. #wsTitleList .. " objects", Icon = "check" })
    end

    WorkspaceDropdown = ObjectsTab:CreateDropdown({
        Name = "Workspace (key = value)",
        Options = objectDropdownOptions(wsTitleList),
        CurrentOption = { OBJECTS_NONE },
        Search = true,
        Ext = true,
        Callback = function(opts)
            local selectedDisplay = type(opts) == "table" and opts[1] or opts
            if not selectedDisplay or selectedDisplay == OBJECTS_NONE then
                setNestedChildrenParagraphsWithOverflow(
                    ObjectsTab,
                    WorkspaceChildrenParagraph,
                    wsChildrenOverflowParagraphs,
                    nil,
                    NESTED_CHILDREN_TITLE,
                    "Select an object above to list its children"
                )
                return
            end
            local inst = wsTitleToInstance[selectedDisplay]
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                ObjectsTab,
                WorkspaceChildrenParagraph,
                wsChildrenOverflowParagraphs,
                text,
                NESTED_CHILDREN_TITLE,
                "Select an object above to list its children"
            )
        end,
    })

    WorkspaceChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = NESTED_CHILDREN_TITLE,
        Content = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Ext = true,
        Callback = function()
            refreshWorkspaceList()
        end,
    })

    ObjectsTab:CreateInput({
        Name = "Find instance by name (under Workspace)",
        PlaceholderText = "Substring match on Instance.Name",
        Ext = true,
        CurrentValue = wsFindByNameQuery,
        Callback = function(value)
            wsFindByNameQuery = value
        end,
    })

    ObjectsTab:CreateButton({
        Name = "Find",
        Ext = true,
        Callback = function()
            runObjectsTabFindInstanceByName(
                Workspace,
                WorkspaceChildrenParagraph,
                wsChildrenOverflowParagraphs,
                "Select an object above to list its children",
                wsFindByNameQuery,
                "Workspace"
            )
        end,
    })

    ObjectsTab:CreateButton({
        Name = "Clear overflow paragraphs",
        Ext = true,
        Callback = function()
            clearObjectsTabOverflowParagraphs(rsChildrenOverflowParagraphs)
            clearObjectsTabOverflowParagraphs(plrsChildrenOverflowParagraphs)
            clearObjectsTabOverflowParagraphs(lpChildrenOverflowParagraphs)
            clearObjectsTabOverflowParagraphs(wsChildrenOverflowParagraphs)
            mountNotify({ Title = "Objects", Content = "Removed extra child-list paragraphs (part 2+).", Icon = "check" })
        end,
    })

end

-- */  Config Tab  /* --
do
    local ConfigTab = Window:CreateTab("Config", 4483362458)

    ConfigTab:CreateSection("Config management")
    local CONFIG_DIR = "sempatpanick/slime_rng"
    local configMgmtName = ""
    local savedConfigList = {}
    local selectedSavedConfigName = nil
    local SavedConfigsDropdown
    local ConfigNameInput
    local autoLoadPickerSelection = nil
    local AutoLoadSavedDropdown

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
        for flagName, _ in pairs(data) do
            local flagObj = RayfieldLibrary.Flags and RayfieldLibrary.Flags[flagName]
            if flagObj and type(flagObj.Set) == "function" then
                local saved = data[flagName]
                if saved ~= nil then
                    local c = decodeColor3(saved)
                    pcall(function()
                        flagObj:Set(c or saved)
                    end)
                end
            end
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
            if base and base:sub(-5) == ".json" and base ~= "slime_rng_autoload.json" then
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
        return (cm.Path or "") .. "slime_rng_autoload.json"
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
            clearRayfieldDropdown(AutoLoadSavedDropdown)
        end
        if selectedSavedConfigName and not table.find(savedConfigList, selectedSavedConfigName) then
            selectedSavedConfigName = nil
            clearRayfieldDropdown(SavedConfigsDropdown)
        end
        if showNotify then
            mountNotify({
                Title = "Config",
                Content = "Found " .. tostring(#savedConfigList) .. " saved profile(s).",
            })
        end
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
        CurrentOption = {}, Search = true,
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

    local function isWindUIConfigObject(v)
        return type(v) == "table" and type(v.Save) == "function" and type(v.Load) == "function"
    end

    local function getConfigObject(cm, name)
        local existing = cm:GetConfig(name)
        if isWindUIConfigObject(existing) then
            return existing
        end
        return cm:Config(name, false)
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
        local cfg = getConfigObject(cm, name)
        if Window.SetCurrentConfig then
            Window:SetCurrentConfig(cfg)
        end
        local pok, loadResult, loadErr = pcall(function()
            return cfg:Load()
        end)
        if not pok then
            warn("[Slime RNG] Auto-load failed: ", loadResult)
            return
        end
        if loadResult == false then
            warn("[Slime RNG] Auto-load: ", loadErr)
            return
        end
        mountNotify({
            Title = "Config",
            Content = "Auto-loaded \"" .. name .. "\"",
        })
    end

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
            local cfg = getConfigObject(cm, name)
            if Window.SetCurrentConfig then
                Window:SetCurrentConfig(cfg)
            end
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
            local cfg = getConfigObject(cm, name)
            if Window.SetCurrentConfig then
                Window:SetCurrentConfig(cfg)
            end
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
                    clearRayfieldDropdown(AutoLoadSavedDropdown)
                end
                selectedSavedConfigName = nil
                clearRayfieldDropdown(SavedConfigsDropdown)
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
        CurrentOption = {}, Search = true,
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
            clearRayfieldDropdown(AutoLoadSavedDropdown)
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
