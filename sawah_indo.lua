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

-- */  Window  /* --
local Window = RayfieldLibrary:CreateWindow({
    Name = "sempatpanick | Sawah Indo",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Sawah Indo",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "sempatpanick",
        FileName = "sawah_indo",
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
    LocalPlayerTab:CreateToggle({
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

    --[[ Equipment section: dropdown of Backpack tools + Equip button (commented out)
    local function getBackpackToolsInOrder()
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return {} end
        local tools = {}
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") then
                table.insert(tools, child)
            end
        end
        return tools
    end

    LocalPlayerTab:CreateSection("Equipment")
    local function getEquippedToolName()
        local character = Players.LocalPlayer.Character
        if not character then return nil end
        for _, c in ipairs(character:GetChildren()) do
            if c:IsA("Tool") then return c.Name end
        end
        return nil
    end

    LocalPlayerTab:CreateSection("Equipped: (none)")
    local function updateEquippedLabel()
        local name = getEquippedToolName()
        local text = "Equipped: " .. (name or "(none)")
        if EquippedLabel and EquippedLabel.Set then
            LocalPlayerTab:Set(text)
        elseif EquippedLabel and EquippedLabel.SetTitle then
            LocalPlayerTab:SetTitle(text)
        end
    end

    local equipmentItems = {}
    local selectedEquipment = nil

    local EquipmentDropdown = LocalPlayerTab:CreateDropdown({
        Name = "Item",
        Options = equipmentItems,
        CurrentOption = {},
        Callback = function(value)
            selectedEquipment = rayfieldDropdownFirst(value)
        end
    })

    local function refreshEquipmentList(showNotify)
        local tools = getBackpackToolsInOrder()
        equipmentItems = {}
        for _, tool in ipairs(tools) do
            table.insert(equipmentItems, tool.Name)
        end
        EquipmentDropdown:Refresh(equipmentItems)
        if selectedEquipment and not table.find(equipmentItems, selectedEquipment) then
            selectedEquipment = nil
            if EquipmentDropdown.Select then
                EquipmentDropdown:Select(nil)
            elseif EquipmentDropdown.Set then
                EquipmentDropdown:Set({})
            end
        end
        updateEquippedLabel()
        if showNotify then
            mountNotify({ Title = "Equipment", Content = "List refreshed (" .. #equipmentItems .. " items)" })
        end
    end

    refreshEquipmentList(false)

    local function onCharacterToolChanged()
        updateEquippedLabel()
    end
    local function onCharacterChanged(character)
        if character then
            character.ChildAdded:Connect(function(c) if c:IsA("Tool") then onCharacterToolChanged() end end)
            character.ChildRemoved:Connect(function(c) if c:IsA("Tool") then onCharacterToolChanged() end end)
            onCharacterToolChanged()
        end
    end
    Players.LocalPlayer.CharacterAdded:Connect(onCharacterChanged)
    if Players.LocalPlayer.Character then
        onCharacterChanged(Players.LocalPlayer.Character)
    end

    do
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            backpack.ChildAdded:Connect(function(c)
                if c:IsA("Tool") then refreshEquipmentList(false) end
            end)
            backpack.ChildRemoved:Connect(function(c)
                if c:IsA("Tool") then refreshEquipmentList(false) end
            end)
        end
    end

    LocalPlayerTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshEquipmentList(true)
        end
    })
    LocalPlayerTab:CreateButton({
        Name = "Equip",
        Callback = function()
            if not selectedEquipment or selectedEquipment == "" then
                mountNotify({ Title = "Equipment", Content = "No item selected" })
                return
            end
            local character = Players.LocalPlayer.Character
            if not character then
                mountNotify({ Title = "Equipment", Content = "Character not loaded" })
                return
            end
            local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
            if not backpack then
                mountNotify({ Title = "Equipment", Content = "Backpack not found" })
                return
            end
            local tool = backpack:FindFirstChild(selectedEquipment)
            if not tool or not tool:IsA("Tool") then
                mountNotify({ Title = "Equipment", Content = "Item not in backpack: " .. tostring(selectedEquipment) })
                return
            end
            for _, c in ipairs(character:GetChildren()) do
                if c:IsA("Tool") then
                    c.Parent = backpack
                    break
                end
            end
            tool.Parent = character
            selectedEquipment = nil
            refreshEquipmentList(false)
            if EquipmentDropdown.Select then
                EquipmentDropdown:Select(nil)
            end
            mountNotify({ Title = "Equipment", Content = "Equipped: " .. tostring(tool.Name) })
        end
    })
    --]]
    LocalPlayerTab:CreateSection("Server")
    LocalPlayerTab:CreateButton({
        Name = "Rejoin server",
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
        if not (originalWeld and originalWeld:IsA("JointInstance")) then
            originalWeld = hairHandle:FindFirstChildOfClass("JointInstance")
        end
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
        local shoulderTween = TweenService:Create(rightShoulder, moveInfo, { C0 = originalShoulderC0 * CFrame.Angles(math.rad(-95), math.rad(8), math.rad(28)) })
        local neckTween = TweenService:Create(neck, moveInfo, { C0 = originalNeckC0 * CFrame.Angles(math.rad(8), math.rad(-16), 0) })
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
        shoulderTween:Play()
        neckTween:Play()
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

-- */  Farm Tab  /* --
do
    local FarmTab = Window:CreateTab("Farm", 4483362458)

    local Workspace = game:GetService("Workspace")
    local localPlayerCropsList = {}

    local function getCropNumber(crop, key)
        local v = crop:GetAttribute(key)
        if v ~= nil and type(v) == "number" then return v end
        local c = crop:FindFirstChild(key)
        if c and (c:IsA("NumberValue") or c:IsA("IntValue") or c:IsA("DoubleConstrainedValue")) then return c.Value end
        return nil
    end

    local function refreshAllCropsByLocalPlayer()
        local list = {}
        local activeCrops = Workspace:FindFirstChild("ActiveCrops")
        if not activeCrops then
            localPlayerCropsList = list
            return list
        end
        local myUserId = Players.LocalPlayer.UserId
        for _, crop in ipairs(activeCrops:GetChildren()) do
            local ownerId = getCropNumber(crop, "OwnerId")
            if ownerId == nil then ownerId = crop:GetAttribute("OwnerId") end
            if type(ownerId) ~= "number" or ownerId ~= myUserId then continue end
            local posX = getCropNumber(crop, "PosX")
            local posZ = getCropNumber(crop, "PosZ")
            local groundY = getCropNumber(crop, "GroundY")
            table.insert(list, {
                crop = crop,
                position = Vector3.new(posX or 0, groundY or 0, posZ or 0),
            })
        end
        localPlayerCropsList = list
        return list
    end

    local function getAllCropsByLocalPlayer()
        refreshAllCropsByLocalPlayer()
        return localPlayerCropsList
    end

    local function getReadyCropsForLocalPlayer()
        refreshAllCropsByLocalPlayer()
        local list = {}
        for _, entry in ipairs(localPlayerCropsList) do
            local scaleEnd = getCropNumber(entry.crop, "ScaleEnd")
            local scaleStart = getCropNumber(entry.crop, "ScaleStart")
            if scaleEnd ~= nil and scaleStart ~= nil and scaleEnd == scaleStart then
                table.insert(list, entry)
            end
        end
        return list
    end

    do
        local activeCrops = Workspace:FindFirstChild("ActiveCrops")
        if activeCrops then
            activeCrops.ChildAdded:Connect(function() refreshAllCropsByLocalPlayer() end)
            activeCrops.ChildRemoved:Connect(function() refreshAllCropsByLocalPlayer() end)
        end
        refreshAllCropsByLocalPlayer()
    end

    FarmTab:CreateSection("Plant Crops")
    -- Farm position: default until user sets current position
    local DEFAULT_FARM_POSITION = Vector3.new(-169.41416931152, 39.296875, -287.59017944336)
    local farmPosition = DEFAULT_FARM_POSITION

    local function getFarmPosition()
        return farmPosition
    end

    local function farmPositionLabelText()
        return string.format("Current farm position: %.1f, %.1f, %.1f", farmPosition.X, farmPosition.Y, farmPosition.Z)
    end

    FarmTab:CreateSection("Section")
    FarmTab:CreateButton({
        Name = "Set current position as farm position",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local origin = rootPart.Position
                local rayDir = Vector3.new(0, -1, 0)
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = { character }
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                local result = Workspace:Raycast(origin, rayDir * 20, raycastParams)
                if result and result.Position then
                    farmPosition = result.Position
                else
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    local footYOffset = (humanoid and (humanoid.HipHeight + rootPart.Size.Y * 0.5) or 3)
                    farmPosition = origin - Vector3.new(0, footYOffset, 0)
                end
                local text = farmPositionLabelText()
                if FarmPositionLabel and FarmPositionLabel.Set then
                    FarmTab:Set(text)
                elseif FarmPositionLabel and FarmPositionLabel.SetTitle then
                    FarmTab:SetTitle(text)
                end
                mountNotify({
                    Title = "Farm position",
                    Content = string.format("Set to ground: %.1f, %.1f, %.1f", farmPosition.X, farmPosition.Y, farmPosition.Z),
                })
            else
                mountNotify({
                    Title = "Farm position",
                    Content = "No character. Respawn or wait and try again.",
                })
            end
        end,
    })
    local function getBackpackToolsForPlants()
        local tools = {}
        local seen = {}
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, child in ipairs(backpack:GetChildren()) do
                if child:IsA("Tool") then
                    table.insert(tools, child)
                    seen[child.Name] = true
                end
            end
        end
        local character = Players.LocalPlayer.Character
        if character then
            for _, child in ipairs(character:GetChildren()) do
                if child:IsA("Tool") and not seen[child.Name] then
                    table.insert(tools, child)
                    seen[child.Name] = true
                end
            end
        end
        return tools
    end

    local plantItems = {}
    local selectedPlant = nil

    local PlantDropdown = FarmTab:CreateDropdown({
        Name = "Plant",
        Options = plantItems,
        CurrentOption = {},
        Callback = function(value)
            selectedPlant = rayfieldDropdownFirst(value)
        end
    })

    local function refreshPlantList()
        local tools = getBackpackToolsForPlants()
        plantItems = {}
        for _, tool in ipairs(tools) do
            table.insert(plantItems, tool.Name)
        end
        PlantDropdown:Refresh(plantItems)
        if selectedPlant and not table.find(plantItems, selectedPlant) then
            selectedPlant = nil
            if PlantDropdown.Select then PlantDropdown:Select(nil) end
            if PlantDropdown.Set then PlantDropdown:Set({}) end
        end
    end

    refreshPlantList()

    do
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            backpack.ChildAdded:Connect(function(c)
                if c:IsA("Tool") then refreshPlantList() end
            end)
            backpack.ChildRemoved:Connect(function(c)
                if c:IsA("Tool") then refreshPlantList() end
            end)
        end
        local function onCharChanged(char)
            if not char then return end
            char.ChildAdded:Connect(function(c)
                if c:IsA("Tool") then refreshPlantList() end
            end)
            char.ChildRemoved:Connect(function(c)
                if c:IsA("Tool") then refreshPlantList() end
            end)
            refreshPlantList()
        end
        Players.LocalPlayer.CharacterAdded:Connect(onCharChanged)
        if Players.LocalPlayer.Character then
            onCharChanged(Players.LocalPlayer.Character)
        end
    end
    local FarmQuantity = "1"

    FarmTab:CreateInput({
        Name = "Quantity",
        PlaceholderText = "Enter quantity",
        CurrentValue = FarmQuantity,
        Callback = function(value)
            FarmQuantity = value
        end
    })

    FarmTab:CreateButton({
        Name = "Start Farm",
        Callback = function()
            if selectedPlant and selectedPlant ~= "" then
                local character = Players.LocalPlayer.Character
                local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
                if character and backpack then
                    local tool = backpack:FindFirstChild(selectedPlant)
                    if not tool or not tool:IsA("Tool") then
                        tool = character:FindFirstChild(selectedPlant)
                    end
                    if tool and tool:IsA("Tool") and tool.Parent == backpack then
                        for _, c in ipairs(character:GetChildren()) do
                            if c:IsA("Tool") then
                                c.Parent = backpack
                                break
                            end
                        end
                        tool.Parent = character
                    end
                end
            end

            local qty = tonumber(FarmQuantity) or 1
            local PlantCropEvent = ReplicatedStorage.Remotes.TutorialRemotes.PlantCrop
            local NotificationEvent = ReplicatedStorage.Remotes.TutorialRemotes.Notification
            local position = getFarmPosition()

            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(position)
                task.wait(0.5)
            end

            local stopRequested = false
            local connection = NotificationEvent.OnClientEvent:Connect(function(message)
                if message == "Maximum 15 crops!" then
                    stopRequested = true
                end
            end)

            local planted = 0
            for i = 1, qty do
                if stopRequested then break end
                print("Planting crop " .. i .. " of " .. qty)
                PlantCropEvent:FireServer(position)
                planted = i
                task.wait(1)
            end

            connection:Disconnect()

            mountNotify({
                Title = "Farm",
                Content = "Planted " .. tostring(planted) .. " crop(s)" .. (stopRequested and " (stopped: max crops)" or ""),
            })
        end
    })
    local autoFarmRunning = false
    local autoFarmConnection = nil
    local autoFarmTeleportEnabled = false

    FarmTab:CreateToggle({
        Name = "Teleport",
        Callback = function(enabled)
            autoFarmTeleportEnabled = enabled
        end
    })

    FarmTab:CreateToggle({
        Name = "Auto Farm",
        Callback = function(enabled)
            autoFarmRunning = enabled
            if autoFarmConnection then
                autoFarmConnection:Disconnect()
                autoFarmConnection = nil
            end
            if not enabled then return end

            local PlantCropEvent = ReplicatedStorage.Remotes.TutorialRemotes.PlantCrop
            local NotificationEvent = ReplicatedStorage.Remotes.TutorialRemotes.Notification
            local position = getFarmPosition()
            local gotMaxCrops = false

            autoFarmConnection = NotificationEvent.OnClientEvent:Connect(function(message)
                if message == "Maximum 15 crops!" then
                    gotMaxCrops = true
                end
            end)

            task.spawn(function()
                while autoFarmRunning do
                    if selectedPlant and selectedPlant ~= "" then
                        local character = Players.LocalPlayer.Character
                        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
                        if character and backpack then
                            local plantTool = backpack:FindFirstChild(selectedPlant) or character:FindFirstChild(selectedPlant)
                            if plantTool and plantTool:IsA("Tool") then
                                local currentTool = nil
                                for _, c in ipairs(character:GetChildren()) do
                                    if c:IsA("Tool") then
                                        currentTool = c
                                        break
                                    end
                                end
                                if currentTool ~= plantTool then
                                    if currentTool then
                                        currentTool.Parent = backpack
                                        task.wait()
                                    end
                                    plantTool.Parent = character
                                end
                            end
                        end
                    end

                    if autoFarmTeleportEnabled then
                        local char = Players.LocalPlayer.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root and (root.Position - position).Magnitude > 5 then
                            root.CFrame = CFrame.new(position)
                            task.wait(0.5)
                        end
                    end
                    local cropCount = #getAllCropsByLocalPlayer()
                    if cropCount >= 15 then
                        task.wait(1)
                    else
                        PlantCropEvent:FireServer(position)
                        task.wait(1)
                    end
                    if gotMaxCrops then
                        gotMaxCrops = false
                        task.wait(9)
                    end
                end
            end)
        end
    })
    FarmTab:CreateSection("Harvest Plant")
    local harvestPlantRunning = false
    local harvestTeleportEnabled = false

    local function findHarvestPromptInCrop(crop)
        for _, d in ipairs(crop:GetDescendants()) do
            if d:IsA("ProximityPrompt") then return d end
        end
        return nil
    end

    FarmTab:CreateToggle({
        Name = "Teleport",
        Callback = function(enabled)
            harvestTeleportEnabled = enabled
        end
    })

    FarmTab:CreateToggle({
        Name = "Harvest Plant",
        Callback = function(enabled)
            harvestPlantRunning = enabled
            if not enabled then return end
            task.spawn(function()
                while harvestPlantRunning do
                    local character = Players.LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then
                        task.wait(2)
                        continue
                    end

                    local readyCrops = getReadyCropsForLocalPlayer()
                    if #readyCrops == 0 then
                        task.wait(2)
                        continue
                    end

                    local playerPos = rootPart.Position
                    local nearest = nil
                    local nearestDist = math.huge
                    for _, entry in ipairs(readyCrops) do
                        local dist = (entry.position - playerPos).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearest = entry
                        end
                    end

                    if not nearest then
                        task.wait(2)
                        continue
                    end

                    local cropPos = nearest.position
                    local maxDist = 5
                    if nearestDist >= maxDist then
                        if harvestTeleportEnabled then
                            rootPart.CFrame = CFrame.new(cropPos)
                            task.wait(0.5)
                        else
                            task.wait(2)
                            continue
                        end
                    end

                    local prompt = findHarvestPromptInCrop(nearest.crop)
                    if prompt and prompt:IsA("ProximityPrompt") then
                        local originalHold = prompt.HoldDuration
                        prompt.HoldDuration = 0
                        prompt:InputHoldBegin()
                        prompt:InputHoldEnd()
                        prompt.HoldDuration = originalHold
                    end

                    task.wait(2)
                end
            end)
        end
    })
    -- Palm land (owned) â€“ LahanConfig.AreaPrefix = "AreaTanamBesar", areas in Workspace
    local LahanConfig
    do
        local ok, mod = pcall(function()
            return require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("LahanConfig", 5))
        end)
        LahanConfig = (ok and mod) and mod or nil
    end
    local areaPrefix = (LahanConfig and LahanConfig.AreaPrefix) or "AreaTanamBesar"

    local function getOwnerIdFromInstance(obj)
        local v = obj:GetAttribute("OwnerId")
        if v ~= nil and type(v) == "number" then return v end
        local c = obj:FindFirstChild("OwnerId")
        if c and (c:IsA("NumberValue") or c:IsA("IntValue") or c:IsA("DoubleConstrainedValue")) then
            return c.Value
        end
        return nil
    end

    local function getPalmLandMapText()
        local myUserId = Players.LocalPlayer.UserId
        local lines = {}
        local function add(s)
            table.insert(lines, s)
        end
        add("Palm land (prefix: " .. areaPrefix .. ")")
        add("")
        local allList = {}
        for _, child in ipairs(Workspace:GetChildren()) do
            local name = child.Name
            if name and (string.sub(name, 1, #areaPrefix) == areaPrefix or string.sub(name, 1, 9) == "AreaTanam") then
                table.insert(allList, { name = name, obj = child })
            end
        end
        table.sort(allList, function(a, b) return a.name < b.name end)
        if #allList == 0 then
            add("  (no AreaTanam* found in Workspace)")
        else
            for _, entry in ipairs(allList) do
                local ownerId = getOwnerIdFromInstance(entry.obj)
                local ownerStr = ownerId ~= nil and tostring(ownerId) or "(none)"
                local youTag = (ownerId == myUserId) and "  [you]" or ""
                add("  " .. entry.name .. "  OwnerId: " .. ownerStr .. youTag)
            end
            add("")
            local ownedCount = 0
            for _, entry in ipairs(allList) do
                if getOwnerIdFromInstance(entry.obj) == myUserId then
                    ownedCount = ownedCount + 1
                end
            end
            add("Owned by you: " .. ownedCount .. " / " .. #allList)
        end
        return table.concat(lines, "\n")
    end

    FarmTab:CreateSection("Palm land")
    local palmLandResultLabel = FarmTab:CreateParagraph({
        Title = "Palm land result",
        Content = "(tap Refresh to load)",
    })
    FarmTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            local text = getPalmLandMapText()
            if palmLandResultLabel and palmLandResultLabel.Set then
                palmLandResultLabel:Set({
                    Title = "Palm land result",
                    Content = text,
                })
            end
        end,
    })
    FarmTab:CreateSection("Plant Growth Duration (Test)")
    local lp = Players.LocalPlayer
    FarmTab:CreateSection("Owner ID: " .. tostring(lp.UserId) .. " | " .. tostring(lp.Name))

    FarmTab:CreateSection("Result: (not run)")
    local function tryGetGrowthDurationInfo()
        local out = {}
        local function add(line)
            table.insert(out, line)
        end

        local TutorialRemotes = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("TutorialRemotes")
        if not TutorialRemotes then
            add("TutorialRemotes not found")
        else
            add("TutorialRemotes children:")
            for _, child in ipairs(TutorialRemotes:GetChildren()) do
                local nameLower = child.Name:lower()
                if nameLower:find("plant") or nameLower:find("crop") or nameLower:find("growth") or nameLower:find("farm") then
                    add("  " .. child.Name .. " [" .. child.ClassName .. "]")
                end
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    local ok, ret = pcall(function()
                        if child:IsA("RemoteFunction") and (nameLower:find("plant") or nameLower:find("crop") or nameLower:find("get")) then
                            return child:InvokeServer()
                        end
                    end)
                    if ok and ret ~= nil then
                        add("    InvokeServer() -> " .. tostring(ret))
                        if type(ret) == "table" then
                            for k, v in pairs(ret) do
                                add("      " .. tostring(k) .. " = " .. tostring(v))
                            end
                        end
                    end
                end
            end
        end

        local function scanForValues(parent, depth, path)
            if depth > 3 then return end
            path = path or "ReplicatedStorage"
            for _, child in ipairs(parent:GetChildren()) do
                local nameLower = child.Name:lower()
                if child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("DoubleConstrainedValue") then
                    if nameLower:find("growth") or nameLower:find("duration") or nameLower:find("time") or nameLower:find("plant") then
                        add(path .. "/" .. child.Name .. " = " .. tostring(child.Value))
                    end
                end
                if child:IsA("Configuration") or child:IsA("Folder") then
                    if nameLower:find("plant") or nameLower:find("crop") or nameLower:find("farm") or nameLower:find("config") or depth == 0 then
                        scanForValues(child, depth + 1, path .. "/" .. child.Name)
                    end
                end
            end
        end
        add("")
        add("ReplicatedStorage values (growth/duration/time/plant):")
        scanForValues(ReplicatedStorage, 0)

        local Workspace = game:GetService("Workspace")
        add("")
        add("Workspace models (root/plant/crop) attributes:")
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("Model") then
                local nameLower = desc.Name:lower()
                if nameLower:find("root") or nameLower:find("plant") or nameLower:find("crop") then
                    local attrs = desc:GetAttributes()
                    if next(attrs) then
                        add("  " .. desc:GetFullName() .. ":")
                        for k, v in pairs(attrs) do
                            if type(k) == "string" and (k:lower():find("growth") or k:lower():find("duration") or k:lower():find("time")) or type(v) == "number" then
                                add("    " .. tostring(k) .. " = " .. tostring(v))
                            end
                        end
                    end
                end
            end
        end

        if #out == 0 then
            add("No obvious growth/duration keys found in scan.")
        end
        return table.concat(out, "\n")
    end

    FarmTab:CreateButton({
        Name = "Inspect for growth duration",
        Callback = function()
            local text = tryGetGrowthDurationInfo()
            if growthDurationResultLabel and growthDurationResultLabel.Set then
                FarmTab:Set(text)
            elseif growthDurationResultLabel and growthDurationResultLabel.SetTitle then
                FarmTab:SetTitle(text)
            end
            mountNotify({
                Title = "Growth Duration (Test)",
                Content = #text > 200 and (text:sub(1, 200) .. "...") or text,
            })
        end
    })
end

-- */  Automation Tab  /* --
do
    local AutomationTab = Window:CreateTab("Automation", 4483362458)

    AutomationTab:CreateSection("Auto Payung")
    local isRaining = false
    local autoPayungRunning = false

    local function equipPayung()
        local character = Players.LocalPlayer.Character
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        if not character or not backpack then return false end
        local payung = backpack:FindFirstChild("Payung")
        if not payung or not payung:IsA("Tool") then return false end
        for _, c in ipairs(character:GetChildren()) do
            if c:IsA("Tool") then
                c.Parent = backpack
                break
            end
        end
        payung.Parent = character
        return true
    end

    do
        local RainSync = ReplicatedStorage.Remotes.TutorialRemotes:FindFirstChild("RainSync")
        if RainSync then
            rainSyncConnection = RainSync.OnClientEvent:Connect(function(raining, _)
                isRaining = (raining == true)
            end)
        end
    end

    AutomationTab:CreateToggle({
        Name = "Auto equip Payung when raining",
        Callback = function(enabled)
            autoPayungRunning = enabled
            if not enabled then return end
            task.spawn(function()
                while autoPayungRunning do
                    if isRaining then
                        equipPayung()
                    end
                    local elapsed = 0
                    while elapsed < 2 and autoPayungRunning do
                        task.wait(1)
                        elapsed = elapsed + 1
                    end
                end
            end)
        end
    })
    AutomationTab:CreateSection("Auto Shower")
    local hygieneSyncConnection = nil

    local function findMandiObjects()
        local list = {}
        local function scan(parent)
            for _, child in ipairs(parent:GetDescendants()) do
                if child:IsA("ProximityPrompt") then
                    local name = (child.Parent and child.Parent.Name or ""):lower()
                    if name:find("mandi") then
                        table.insert(list, child)
                    end
                end
            end
        end
        scan(game:GetService("Workspace"))
        return list
    end

    local function getPosition(obj)
        if obj:IsA("BasePart") then
            return obj.Position
        end
        if obj:IsA("Model") and obj.PrimaryPart then
            return obj.PrimaryPart.Position
        end
        if obj:IsA("Model") then
            local p, _ = obj:GetBoundingBox()
            return p.Position
        end
        if obj.Parent and obj.Parent:IsA("BasePart") then
            return obj.Parent.Position
        end
        if obj.Parent and obj.Parent:IsA("Model") and obj.Parent.PrimaryPart then
            return obj.Parent.PrimaryPart.Position
        end
        return nil
    end

    local function interactWithMandi(promptOrObj)
        local prompt = promptOrObj:IsA("ProximityPrompt") and promptOrObj or nil
        if not prompt then
            prompt = promptOrObj:FindFirstChildOfClass("ProximityPrompt") or promptOrObj:FindFirstChild("ProximityPrompt")
        end
        if not prompt then
            for _, d in ipairs(promptOrObj:GetDescendants()) do
                if d:IsA("ProximityPrompt") then
                    prompt = d
                    break
                end
            end
        end
        if prompt and prompt:IsA("ProximityPrompt") then
            local originalHold = prompt.HoldDuration
            prompt.HoldDuration = 0
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
            prompt.HoldDuration = originalHold
            return true
        end
        return false
    end

    AutomationTab:CreateToggle({
        Name = "Auto Shower (hygiene <= 50)",
        Callback = function(enabled)
            if hygieneSyncConnection then
                hygieneSyncConnection:Disconnect()
                hygieneSyncConnection = nil
            end
            if enabled then
                local HygieneSync = ReplicatedStorage.Remotes.TutorialRemotes:FindFirstChild("HygieneSync")
                if HygieneSync then
                    hygieneSyncConnection = HygieneSync.OnClientEvent:Connect(function(value)
                        local hygiene = type(value) == "number" and value or tonumber(value)
                        if hygiene ~= nil and hygiene <= 50 then
                            local character = Players.LocalPlayer.Character
                            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                            if not rootPart then return end
                            local mandiList = findMandiObjects()
                            if #mandiList == 0 then return end
                            local playerPos = rootPart.Position
                            local nearest, nearestDist = nil, math.huge
                            for _, obj in ipairs(mandiList) do
                                local pos = getPosition(obj)
                                if pos then
                                    local dist = (pos - playerPos).Magnitude
                                    if dist < nearestDist then
                                        nearestDist = dist
                                        nearest = obj
                                    end
                                end
                            end
                            if not nearest then return end
                            local pos = getPosition(nearest)
                            if pos then
                                local positionBeforeShower = rootPart.CFrame
                                rootPart.CFrame = CFrame.new(pos + Vector3.new(0, 0, 3))
                                task.wait(1)
                                interactWithMandi(nearest)
                                task.wait(3)
                                if rootPart and rootPart.Parent then
                                    rootPart.CFrame = positionBeforeShower
                                end
                            end
                        end
                    end)
                end
            end
        end
    })
end

local ShopTabShared = Window:CreateTab("Shop", 4483362458)

-- */  Teleport Tab  /* --
do
    local TeleportTab = Window:CreateTab("Teleport", 4483362458)

    TeleportTab:CreateSection("Coordinates")
    local coordTeleportInputCurrentValue = ""
    local coordTeleportLookInputValue = ""

    local function coordTeleportParseNumberTriple(str)
        local s = str:gsub(",", " "):gsub("%s+", " ")
        local parts = {}
        for part in string.gmatch(s, "[%d%.%-]+") do
            table.insert(parts, tonumber(part))
        end
        return parts
    end

    local function coordTeleportCFrameFromInputs(posStr, lookStr)
        local posParts = coordTeleportParseNumberTriple(posStr)
        if #posParts < 3 then
            return nil
        end
        local pos = Vector3.new(posParts[1], posParts[2], posParts[3])
        local lookParts = coordTeleportParseNumberTriple(lookStr)
        if #lookParts < 3 then
            return CFrame.new(pos)
        end
        local dir = Vector3.new(lookParts[1], lookParts[2], lookParts[3])
        if dir.Magnitude < 1e-5 then
            return CFrame.new(pos)
        end
        return CFrame.lookAt(pos, pos + dir.Unit)
    end

    local CoordTeleportInput = TeleportTab:CreateInput({
        Name = "Location",
        PlaceholderText = "e.g. 100, 5, 200",
        Flag = "sawah_tp_location",
        CurrentValue = coordTeleportInputValue,
        Callback = function(value)
            coordTeleportInputValue = value
        end,
    })

    local CoordTeleportLookInput = TeleportTab:CreateInput({
        Name = "Look direction",
        PlaceholderText = "e.g. 0, 0, -1 or empty",
        Flag = "sawah_tp_lookDirection",
        CurrentValue = coordTeleportLookInputValue,
        Callback = function(value)
            coordTeleportLookInputValue = value
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
            coordTeleportInputValue = text
            if CoordTeleportInput and CoordTeleportInput.Set then
                CoordTeleportInput:Set(text)
            elseif CoordTeleportInput and CoordTeleportInput.SetValue then
                CoordTeleportInput:SetValue(text)
            end
            local look = rootPart.CFrame.LookVector
            local lookText = string.format("%.4f, %.4f, %.4f", look.X, look.Y, look.Z)
            coordTeleportLookInputValue = lookText
            if CoordTeleportLookInput and CoordTeleportLookInput.Set then
                CoordTeleportLookInput:Set(lookText)
            elseif CoordTeleportLookInput and CoordTeleportLookInput.SetValue then
                CoordTeleportLookInput:SetValue(lookText)
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
            local cf = coordTeleportCFrameFromInputs(coordTeleportInputValue, coordTeleportLookInputValue)
            if not cf then
                mountNotify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z",
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
    local coordTweenDurationValue = "5"
    TeleportTab:CreateInput({
        Name = "Tween Duration",
        PlaceholderText = "e.g. 5",
        CurrentValue = coordTweenDurationValue,
        Callback = function(value)
            coordTweenDurationValue = value
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
            local targetCf = coordTeleportCFrameFromInputs(coordTeleportInputValue, coordTeleportLookInputValue)
            if not targetCf then
                mountNotify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z",
                })
                return
            end
            local duration = tonumber(coordTweenDurationValue) or 5
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
    TeleportTab:CreateSection("Teleport to Object")
    local promptDisplayNames = {}
    local promptList = {}
    local selectedTeleportPrompt = nil
    local TeleportDropdown

    local function getPromptPosition(prompt)
        if prompt.Parent and prompt.Parent:IsA("BasePart") then
            return prompt.Parent.Position
        end
        if prompt.Parent and prompt.Parent:IsA("Model") and prompt.Parent.PrimaryPart then
            return prompt.Parent.PrimaryPart.Position
        end
        if prompt.Parent and prompt.Parent:IsA("Model") then
            local p, _ = prompt.Parent:GetBoundingBox()
            return p.Position
        end
        return nil
    end

    local function refreshTeleportList(showNotify)
        local prompts = {}
        for _, child in ipairs(game:GetService("Workspace"):GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                table.insert(prompts, child)
            end
        end
        promptList = prompts
        promptDisplayNames = {}
        local count = {}
        for _, p in ipairs(prompts) do
            local label = (p.ObjectText and #p.ObjectText > 0) and p.ObjectText or (p.Parent and p.Parent.Name or "ProximityPrompt")
            count[label] = (count[label] or 0) + 1
            local display = count[label] > 1 and (label .. " (" .. count[label] .. ")") or label
            table.insert(promptDisplayNames, display)
        end
        TeleportDropdown:Refresh(promptDisplayNames)
        if selectedTeleportPrompt then
            local idx = table.find(promptList, selectedTeleportPrompt)
            if not idx then
                selectedTeleportPrompt = nil
                if TeleportDropdown.Select then TeleportDropdown:Select(nil) end
                if TeleportDropdown.Set then TeleportDropdown:Set({}) end
            end
        end
        if showNotify then
            mountNotify({ Title = "Teleport", Content = "List refreshed (" .. #promptList .. " objects)" })
        end
    end

    TeleportDropdown = TeleportTab:CreateDropdown({
        Name = "Object",
        Options = promptDisplayNames,
        CurrentOption = {},
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            selectedTeleportPrompt = nil
            if picked then
                local idx = table.find(promptDisplayNames, picked)
                if idx and promptList[idx] then
                    selectedTeleportPrompt = promptList[idx]
                end
            end
        end
    })

    TeleportTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshTeleportList(true)
        end
    })
    TeleportTab:CreateButton({
        Name = "Teleport",
        Callback = function()
            if not selectedTeleportPrompt then
                mountNotify({ Title = "Teleport", Content = "Select an object first" })
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
                return
            end
            local pos = getPromptPosition(selectedTeleportPrompt)
            if not pos then
                mountNotify({ Title = "Teleport", Content = "Could not get object position" })
                return
            end
            rootPart.CFrame = CFrame.new(pos + Vector3.new(0, 0, 3))
            mountNotify({ Title = "Teleport", Content = "Teleported to object" })
        end
    })
    local tweenDurationValue = "5"
    TeleportTab:CreateInput({
        Name = "Tween Duration",
        PlaceholderText = "e.g. 5",
        CurrentValue = tweenDurationValue,
        Callback = function(value)
            tweenDurationValue = value
        end
    })

    TeleportTab:CreateButton({
        Name = "Tween to Location",
        Callback = function()
            if not selectedTeleportPrompt then
                mountNotify({ Title = "Teleport", Content = "Select an object first" })
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
                return
            end
            local pos = getPromptPosition(selectedTeleportPrompt)
            if not pos then
                mountNotify({ Title = "Teleport", Content = "Could not get object position" })
                return
            end
            local targetPos = pos + Vector3.new(0, 0, 3)
            local duration = tonumber(tweenDurationValue) or 5
            if duration < 0.1 then duration = 0.1 end
            local tweenInfo = TweenInfo.new(duration)
            local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = CFrame.new(targetPos) })
            tween:Play()
            mountNotify({ Title = "Teleport", Content = "Tweening to object (" .. tostring(duration) .. "s)" })
        end
    })
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
        PlayerTeleportDropdown:Refresh(playerDisplayNames)
        if selectedTeleportPlayer then
            if not table.find(playerList, selectedTeleportPlayer) then
                selectedTeleportPlayer = nil
                if PlayerTeleportDropdown.Select then PlayerTeleportDropdown:Select(nil) end
                if PlayerTeleportDropdown.Set then PlayerTeleportDropdown:Set({}) end
            end
        end
        if showNotify then
            mountNotify({ Title = "Teleport", Content = "Player list refreshed (" .. #playerList .. " players)" })
        end
    end

    PlayerTeleportDropdown = TeleportTab:CreateDropdown({
        Name = "Player",
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

-- */  Shop Tab  /* --
do
    local ShopTab = ShopTabShared

    -- */  Buy Section  /* --
    ShopTab:CreateSection("Buy")
    local buyItems = {}
    local buyItemData = {}
    local selectedBuyItem = nil
    local buyQty = "1"
    local buyDelaySeconds = "1"
    local autoBuyRunning = false

    local BuyDropdown = ShopTab:CreateDropdown({
        Name = "Item",
        Options = buyItems,
        CurrentOption = {},
        Callback = function(value)
            selectedBuyItem = rayfieldDropdownFirst(value)
        end
    })

    ShopTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestShop
            local Result = Event:InvokeServer("GET_LIST")
            local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
            if ExpectedResult and ExpectedResult.Seeds and type(ExpectedResult.Seeds) == "table" then
                buyItemData = {}
                buyItems = {}
                for _, item in ipairs(ExpectedResult.Seeds) do
                    if not item.Locked then
                        table.insert(buyItemData, item)
                        table.insert(buyItems, item.DisplayName or item.Name or tostring(item))
                    end
                end
                BuyDropdown:Refresh(buyItems)
            end
            mountNotify({
                Title = "Buy",
                Content = ExpectedResult and ExpectedResult.Success and ("List refreshed" .. (ExpectedResult.Coins and (" â€¢ Coins: " .. tostring(ExpectedResult.Coins)) or "")) or "List refreshed",
            })
        end
    })
    ShopTab:CreateInput({
        Name = "Quantity",
        PlaceholderText = "Enter quantity",
        CurrentValue = buyQty,
        Callback = function(value)
            buyQty = value
        end
    })
    ShopTab:CreateButton({
        Name = "Buy",
        Callback = function()
            if selectedBuyItem == nil then
                mountNotify({ Title = "Buy", Content = "No item selected" })
                return
            end
            local selectedData = nil
            for _, item in ipairs(buyItemData) do
                if (item.DisplayName or item.Name) == selectedBuyItem then
                    selectedData = item
                    break
                end
            end
            if not selectedData then
                mountNotify({ Title = "Buy", Content = "Item not found" })
                return
            end
            local name = selectedData.Name
            local qty = tonumber(buyQty) or 1
            local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestShop
            local Result = Event:InvokeServer("BUY", name, qty)
            local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
            mountNotify({
                Title = ExpectedResult and ExpectedResult.Success and "Success" or "Failed",
                Content = ExpectedResult and ExpectedResult.Message or "Unknown error",
                Icon = ExpectedResult and ExpectedResult.Success and "check" or "x",
            })
        end
    })
    ShopTab:CreateInput({
        Name = "Delay (seconds)",
        PlaceholderText = "Seconds between auto buys",
        CurrentValue = buyDelaySeconds,
        Callback = function(value)
            buyDelaySeconds = value
        end
    })

    ShopTab:CreateToggle({
        Name = "Auto Buy",
        Callback = function(enabled)
            autoBuyRunning = enabled
            if not enabled then return end
            task.spawn(function()
                local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestShop
                while autoBuyRunning do
                    if selectedBuyItem then
                        local selectedData = nil
                        for _, item in ipairs(buyItemData) do
                            if (item.DisplayName or item.Name) == selectedBuyItem then
                                selectedData = item
                                break
                            end
                        end
                        if selectedData then
                            local name = selectedData.Name
                            local qty = tonumber(buyQty) or 1
                            local Result = Event:InvokeServer("BUY", name, qty)
                            local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
                            mountNotify({
                                Title = ExpectedResult and ExpectedResult.Success and "Auto Buy" or "Auto Buy Failed",
                                Content = ExpectedResult and ExpectedResult.Message or "Unknown error",
                                Icon = ExpectedResult and ExpectedResult.Success and "check" or "x",
                            })
                        end
                    end
                    local delay = tonumber(buyDelaySeconds) or 1
                    delay = math.max(0.1, delay)
                    task.wait(delay)
                end
            end)
        end
    })
    -- */  Sell Section  /* --
    ShopTab:CreateSection("Sell")
    local sellItems = {}
    local sellItemData = {}
    local selectedSellItems = {}

    ShopTab:CreateSection("Selected: (none)")
    local SellDropdown = ShopTab:CreateDropdown({
        Name = "Item",
        Options = sellItems,
        CurrentOption = {},
        Multi = true,
        Callback = function(selected)
            selectedSellItems = type(selected) == "table" and selected or (selected and { selected } or {})
            local text = #selectedSellItems == 0 and "(none)" or table.concat(selectedSellItems, ", ")
            if SelectedLabel and SelectedLabel.Set then
                ShopTab:Set("Selected: " .. text)
            elseif SelectedLabel and SelectedLabel.SetTitle then
                ShopTab:SetTitle("Selected: " .. text)
            end
        end
    })

    ShopTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
            local Result = Event:InvokeServer("GET_LIST")
            local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
            if ExpectedResult and ExpectedResult.Items and type(ExpectedResult.Items) == "table" then
                sellItemData = {}
                sellItems = {}
                for _, item in ipairs(ExpectedResult.Items) do
                    local owned = type(item.Owned) == "number" and item.Owned or 0
                    if owned > 0 then
                        table.insert(sellItemData, item)
                        table.insert(sellItems, (item.DisplayName or item.Name or tostring(item)) .. " (x" .. tostring(owned) .. ")")
                    end
                end
                SellDropdown:Refresh(sellItems)
            end
            mountNotify({
                Title = "Sell",
                Content = ExpectedResult and ExpectedResult.Success and ("List refreshed" .. (ExpectedResult.Coins and (" â€¢ Coins: " .. tostring(ExpectedResult.Coins)) or "")) or "List refreshed",
            })
        end
    })
    ShopTab:CreateButton({
        Name = "Sell",
        Callback = function()
            if not selectedSellItems or #selectedSellItems == 0 then
                mountNotify({ Title = "Sell", Content = "No item selected" })
                return
            end
            local selectedDataList = {}
            for _, item in ipairs(sellItemData) do
                local owned = type(item.Owned) == "number" and item.Owned or 0
                local displayStr = (item.DisplayName or item.Name or tostring(item)) .. " (x" .. tostring(owned) .. ")"
                for _, sel in ipairs(selectedSellItems) do
                    if displayStr == sel then
                        table.insert(selectedDataList, item)
                        break
                    end
                end
            end

            local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
            for i, item in ipairs(selectedDataList) do
                local name = item.Name
                local qty = type(item.Owned) == "number" and item.Owned or 0
                local Result = Event:InvokeServer("SELL", name, qty)
                local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
                if ExpectedResult and ExpectedResult.Message then
                    mountNotify({
                        Title = "Sell",
                        Content = ExpectedResult.Message,
                        Icon = ExpectedResult.Success and "check" or "x",
                    })
                    if ExpectedResult.Success then
                        local owned = type(item.Owned) == "number" and item.Owned or 0
                        local displayStr = (item.DisplayName or item.Name or tostring(item)) .. " (x" .. tostring(owned) .. ")"
                        for j = #sellItems, 1, -1 do
                            if sellItems[j] == displayStr then
                                table.remove(sellItems, j)
                                break
                            end
                        end
                        for j = #sellItemData, 1, -1 do
                            if sellItemData[j].Name == item.Name then
                                table.remove(sellItemData, j)
                                break
                            end
                        end
                        for j = #selectedSellItems, 1, -1 do
                            if selectedSellItems[j] == displayStr then
                                table.remove(selectedSellItems, j)
                                break
                            end
                        end
                        SellDropdown:Refresh(sellItems)
                        if SellDropdown.Select then
                            SellDropdown:Select(selectedSellItems)
                        end
                        local text = #selectedSellItems == 0 and "(none)" or table.concat(selectedSellItems, ", ")
                        if SelectedLabel and SelectedLabel.Set then
                            ShopTab:Set("Selected: " .. text)
                        elseif SelectedLabel and SelectedLabel.SetTitle then
                            ShopTab:SetTitle("Selected: " .. text)
                        end
                    end
                end
                if i < #selectedDataList then
                    task.wait(1)
                end
            end
        end
    })
    -- */  Auto Sell Section  /* --
    ShopTab:CreateSection("Auto Sell")
    local autoSellItems = {}
    local autoSellItemData = {}
    local selectedAutoSellItems = {}
    ShopTab:CreateSection("Selected: (none)")
    local AutoSellDropdown = ShopTab:CreateDropdown({
        Name = "Item",
        Options = autoSellItems,
        CurrentOption = {},
        Multi = true,
        Callback = function(selected)
            selectedAutoSellItems = type(selected) == "table" and selected or (selected and { selected } or {})
            local parts = {}
            for _, s in ipairs(selectedAutoSellItems) do
                parts[#parts + 1] = s:match("^(.+) %(x%d+%)$") or s
            end
            local text = #parts == 0 and "(none)" or table.concat(parts, ", ")
            if AutoSellSelectedLabel and AutoSellSelectedLabel.Set then
                ShopTab:Set("Selected: " .. text)
            elseif AutoSellSelectedLabel and AutoSellSelectedLabel.SetTitle then
                ShopTab:SetTitle("Selected: " .. text)
            end
        end
    })

    local function getAutoSellItemBaseName(item)
        return item.DisplayName or item.Name or tostring(item)
    end

    -- Reusable refresh: updates autoSellItemData and autoSellItems. Returns true if refresh succeeded.
    local function refreshAutoSellList(showNotify)
        local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
        local Result = Event:InvokeServer("GET_LIST")
        local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
        if not (ExpectedResult and ExpectedResult.Items and type(ExpectedResult.Items) == "table") then
            if showNotify then
                mountNotify({ Title = "Auto Sell", Content = "List refreshed" })
            end
            return false
        end
        local refreshByName = {}
        for _, item in ipairs(ExpectedResult.Items) do
            if item.Name then
                refreshByName[item.Name] = item
            end
        end
        for _, item in ipairs(autoSellItemData) do
            local fromRefresh = item.Name and refreshByName[item.Name]
            if fromRefresh then
                item.Owned = type(fromRefresh.Owned) == "number" and fromRefresh.Owned or 0
            else
                item.Owned = 0
            end
        end
        local existingNames = {}
        for _, item in ipairs(autoSellItemData) do
            existingNames[item.Name] = true
        end
        for _, item in ipairs(ExpectedResult.Items) do
            if item.Name and not existingNames[item.Name] then
                existingNames[item.Name] = true
                table.insert(autoSellItemData, item)
                table.insert(autoSellItems, getAutoSellItemBaseName(item))
            end
        end
        AutoSellDropdown:Refresh(autoSellItems)
        if showNotify then
            mountNotify({
                Title = "Auto Sell",
                Content = ExpectedResult and ExpectedResult.Success and ("List refreshed" .. (ExpectedResult.Coins and (" â€¢ Coins: " .. tostring(ExpectedResult.Coins)) or "")) or "List refreshed",
            })
        end
        return true
    end

    ShopTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshAutoSellList(true)
        end
    })
    local autoSellDelaySeconds = "1"
    local autoSellRunning = false

    ShopTab:CreateInput({
        Name = "Delay (seconds)",
        PlaceholderText = "Seconds between auto sell actions",
        CurrentValue = autoSellDelaySeconds,
        Callback = function(value)
            autoSellDelaySeconds = value
        end
    })

    ShopTab:CreateToggle({
        Name = "Auto Sell",
        Callback = function(enabled)
            autoSellRunning = enabled
            if not enabled then return end
            task.spawn(function()
                local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
                while autoSellRunning do
                    refreshAutoSellList(false)
                    local toSell = {}
                    for _, displayStr in ipairs(selectedAutoSellItems) do
                        local baseName = displayStr:match("^(.+) %(x%d+%)$") or displayStr
                        for _, item in ipairs(autoSellItemData) do
                            if getAutoSellItemBaseName(item) == baseName then
                                local owned = type(item.Owned) == "number" and item.Owned or 0
                                if owned > 0 then
                                    table.insert(toSell, { name = item.Name, owned = owned, item = item })
                                end
                                break
                            end
                        end
                    end
                    for _, entry in ipairs(toSell) do
                        if not autoSellRunning then break end
                        local Result = Event:InvokeServer("SELL", entry.name, entry.owned)
                        local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
                        local success = ExpectedResult and ExpectedResult.Success
                        local message = (ExpectedResult and ExpectedResult.Message) or (success and "Sold" or "Failed")
                        mountNotify({
                            Title = "Auto Sell",
                            Content = message,
                            Icon = success and "check" or "x",
                        })
                        if ExpectedResult and ExpectedResult.Success and entry.item then
                            entry.item.Owned = 0
                            for i, dataItem in ipairs(autoSellItemData) do
                                if dataItem == entry.item and autoSellItems[i] then
                                    autoSellItems[i] = getAutoSellItemBaseName(entry.item)
                                    AutoSellDropdown:Refresh(autoSellItems)
                                    break
                                end
                            end
                        end
                        if autoSellRunning and entry ~= toSell[#toSell] then
                            task.wait(1)
                        end
                    end
                    local delay = math.max(0.1, tonumber(autoSellDelaySeconds) or 1)
                    task.wait(delay)
                end
            end)
        end
    })
end
-- */  Objects Tab  /* --
do
    local ObjectsTab = Window:CreateTab("Objects", 4483362458)

    local function shouldNestOneLevelInObjectsList(inst)
        return inst:IsA("Folder") or inst:IsA("Backpack") or inst:IsA("StarterGear")
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
        CurrentOption = {}, Search = true,
        Callback = function(selectedDisplay)
            local picked = rayfieldDropdownFirst(selectedDisplay)
            if not picked then
                if ReplicatedStorageChildrenParagraph and ReplicatedStorageChildrenParagraph.Set then
                    ReplicatedStorageChildrenParagraph:Set({ Title = "Children (key = value)", Content = "Select an object above to list its children" })
                end
                return
            end
            local entry = rsKeyValueList[picked]
            if not entry or not entry.instance then return end
            local lines = {}
            for _, child in ipairs(entry.instance:GetChildren()) do
                table.insert(lines, formatInstanceDisplay(child, nil, true))
                if shouldNestOneLevelInObjectsList(child) then
                    for _, sub in ipairs(child:GetChildren()) do
                        table.insert(lines, "  " .. formatInstanceDisplay(sub, nil, true))
                    end
                end
            end
            local text = table.concat(lines, "\n")
            if #lines == 0 then
                text = "(no children)"
            end
            if ReplicatedStorageChildrenParagraph and ReplicatedStorageChildrenParagraph.Set then
                ReplicatedStorageChildrenParagraph:Set({ Title = "Children (key = value)", Content = text })
            end
        end
    })

    ReplicatedStorageChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = "Children (key = value)",
        Content = "Select an object above to list its children",
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
        CurrentOption = {}, Search = true,
        Callback = function(selectedDisplay)
            local picked = rayfieldDropdownFirst(selectedDisplay)
            if not picked then
                if PlayersServiceChildrenParagraph and PlayersServiceChildrenParagraph.Set then
                    PlayersServiceChildrenParagraph:Set({ Title = "Children (key = value)", Content = "Select a player above to list their children" })
                end
                return
            end
            local entry = plrsKeyValueList[picked]
            if not entry or not entry.instance then return end
            local lines = {}
            for _, child in ipairs(entry.instance:GetChildren()) do
                table.insert(lines, formatInstanceDisplay(child, nil, true))
                if shouldNestOneLevelInObjectsList(child) then
                    for _, sub in ipairs(child:GetChildren()) do
                        table.insert(lines, "  " .. formatInstanceDisplay(sub, nil, true))
                    end
                end
            end
            local text = table.concat(lines, "\n")
            if #lines == 0 then
                text = "(no children)"
            end
            if PlayersServiceChildrenParagraph and PlayersServiceChildrenParagraph.Set then
                PlayersServiceChildrenParagraph:Set({ Title = "Children (key = value)", Content = text })
            end
        end
    })

    PlayersServiceChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = "Children (key = value)",
        Content = "Select a player above to list their children",
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
        CurrentOption = {}, Search = true,
        Callback = function(selectedDisplay)
            local picked = rayfieldDropdownFirst(selectedDisplay)
            if not picked then
                if LocalPlayerChildrenParagraph and LocalPlayerChildrenParagraph.Set then
                    LocalPlayerChildrenParagraph:Set({ Title = "Children (key = value)", Content = "Select an object above to list its children" })
                end
                return
            end
            local entry = lpKeyValueList[picked]
            if not entry or not entry.instance then return end
            local lines = {}
            for _, child in ipairs(entry.instance:GetChildren()) do
                table.insert(lines, formatInstanceDisplay(child, nil, true))
                if shouldNestOneLevelInObjectsList(child) then
                    for _, sub in ipairs(child:GetChildren()) do
                        table.insert(lines, "  " .. formatInstanceDisplay(sub, nil, true))
                    end
                end
            end
            local text = table.concat(lines, "\n")
            if #lines == 0 then
                text = "(no children)"
            end
            if LocalPlayerChildrenParagraph and LocalPlayerChildrenParagraph.Set then
                LocalPlayerChildrenParagraph:Set({ Title = "Children (key = value)", Content = text })
            end
        end
    })

    LocalPlayerChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = "Children (key = value)",
        Content = "Select an object above to list its children",
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
        CurrentOption = {}, Search = true,
        Callback = function(selectedDisplay)
            local picked = rayfieldDropdownFirst(selectedDisplay)
            if not picked then
                if WorkspaceChildrenParagraph and WorkspaceChildrenParagraph.Set then
                    WorkspaceChildrenParagraph:Set({ Title = "Children (key = value)", Content = "Select an object above to list its children" })
                end
                return
            end
            local entry = wsKeyValueList[picked]
            if not entry or not entry.instance then return end
            local lines = {}
            for _, child in ipairs(entry.instance:GetChildren()) do
                table.insert(lines, formatInstanceDisplay(child, nil, true))
                if shouldNestOneLevelInObjectsList(child) then
                    for _, sub in ipairs(child:GetChildren()) do
                        table.insert(lines, "  " .. formatInstanceDisplay(sub, nil, true))
                    end
                end
            end
            local text = table.concat(lines, "\n")
            if #lines == 0 then
                text = "(no children)"
            end
            if WorkspaceChildrenParagraph and WorkspaceChildrenParagraph.Set then
                WorkspaceChildrenParagraph:Set({ Title = "Children (key = value)", Content = text })
            end
        end
    })

    WorkspaceChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = "Children (key = value)",
        Content = "Select an object above to list its children",
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshWorkspaceList()
        end
    })

end
