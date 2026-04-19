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
    Name = "sempatpanick | Mount Yahayuk",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Mount Yahayuk",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "sempatpanick",
        FileName = "mount_yahayuk",
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
        CurrentValue = false,
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
        CurrentValue = false,
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
        CurrentValue = false,
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
        CurrentValue = false,
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
        CurrentValue = false,
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
        CurrentValue = walkSpeedValue,
        Ext = true,
        Callback = function(value)
            walkSpeedValue = value
        end,
    })

    local function syncWalkSpeedInputFromCharacter(showNotify)
        local speed, errMessage = getCurrentCharacterWalkSpeed()
        if not speed then
            if showNotify then
                mountNotify({ Title = "Walk Speed", Content = errMessage, Icon = "x" })
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
            mountNotify({ Title = "Walk Speed", Content = "Current speed: " .. speedText, Icon = "check" })
        end
        return true
    end

    LocalPlayerTab:CreateButton({
        Name = "Get Current Walk Speed",
        Ext = true,
        Callback = function()
            syncWalkSpeedInputFromCharacter(true)
        end,
    })

    -- Keep the input defaulted to current character speed when available.
    syncWalkSpeedInputFromCharacter(false)

    LocalPlayerTab:CreateButton({
        Name = "Apply",
        Ext = true,
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                mountNotify({ Title = "Walk Speed", Content = "Character not loaded", Icon = "x" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                mountNotify({ Title = "Walk Speed", Content = "Humanoid not found", Icon = "x" })
                return
            end
            local speed = tonumber(walkSpeedValue) or defaultWalkSpeed
            humanoid.WalkSpeed = math.max(0, speed)
            mountNotify({ Title = "Walk Speed", Content = "Set to " .. tostring(humanoid.WalkSpeed), Icon = "check" })
        end
    })

    LocalPlayerTab:CreateButton({
        Name = "Reset",
        Ext = true,
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                mountNotify({ Title = "Walk Speed", Content = "Character not loaded", Icon = "x" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                mountNotify({ Title = "Walk Speed", Content = "Humanoid not found", Icon = "x" })
                return
            end
            humanoid.WalkSpeed = defaultWalkSpeed
            walkSpeedValue = tostring(defaultWalkSpeed)
            mountNotify({ Title = "Walk Speed", Content = "Reset to " .. tostring(defaultWalkSpeed), Icon = "check" })
        end,
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
        Ext = true,
        Callback = function(value)
            jumpHeightValue = value
        end,
    })

    local function syncJumpHeightInputFromCharacter(showNotify)
        local jumpHeight, errMessage = getCurrentCharacterJumpHeight()
        if not jumpHeight then
            if showNotify then
                mountNotify({ Title = "Jump Height", Content = errMessage, Icon = "x" })
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
            mountNotify({ Title = "Jump Height", Content = "Current jump height: " .. jumpHeightText, Icon = "check" })
        end
        return true
    end

    LocalPlayerTab:CreateButton({
        Name = "Get Current Jump Height",
        Ext = true,
        Callback = function()
            syncJumpHeightInputFromCharacter(true)
        end,
    })

    -- Keep the input defaulted to current character jump height when available.
    syncJumpHeightInputFromCharacter(false)

    LocalPlayerTab:CreateButton({
        Name = "Apply",
        Ext = true,
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                mountNotify({ Title = "Jump Height", Content = "Character not loaded", Icon = "x" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                mountNotify({ Title = "Jump Height", Content = "Humanoid not found", Icon = "x" })
                return
            end
            local jumpHeight = tonumber(jumpHeightValue) or defaultJumpHeight
            humanoid.JumpHeight = math.max(0, jumpHeight)
            mountNotify({ Title = "Jump Height", Content = "Set to " .. tostring(humanoid.JumpHeight), Icon = "check" })
        end,
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
    local espObjectAddedConn: RBXScriptConnection? = nil
    local espObjectRemovingConn: RBXScriptConnection? = nil

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
        Ext = true,
        Callback = function(value)
            local n = tonumber(value)
            if not n then return end
            espMaxDistance = math.max(0, n)
            if espAnyEnabled() then espApplyForAllPlayers() end
        end,
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
            if espAllObjectsEnabled and not espObjectAddedConn then
                espObjectAddedConn = Workspace.DescendantAdded:Connect(function(inst)
                    if inst:IsA("BasePart") or inst:IsA("Model") then
                        task.defer(function()
                            espApplyForObject(inst)
                        end)
                    end
                end)
            end
            if espAllObjectsEnabled and not espObjectRemovingConn then
                espObjectRemovingConn = Workspace.DescendantRemoving:Connect(function(inst)
                    espClearVisualForObject(inst)
                end)
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
        if espObjectAddedConn then espObjectAddedConn:Disconnect() espObjectAddedConn = nil end
        if espObjectRemovingConn then espObjectRemovingConn:Disconnect() espObjectRemovingConn = nil end
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

    local PLAYERS_INFO_PAR_TITLE = "Details"
    local INFO_PLAYER_NONE = "(None)"

    local function playersInfoDropdownOptions()
        local opts = { INFO_PLAYER_NONE }
        for _, n in ipairs(infoPlayerDisplayNames) do
            table.insert(opts, n)
        end
        return opts
    end

    local function updatePlayersInfoParagraph()
        if PlayersInfoParagraph and PlayersInfoParagraph.Set then
            PlayersInfoParagraph:Set({
                Title = PLAYERS_INFO_PAR_TITLE,
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
            PlayersInfoDropdown:Refresh(playersInfoDropdownOptions())
        end
        if selectedInfoPlayer then
            if not table.find(infoPlayerList, selectedInfoPlayer) then
                selectedInfoPlayer = nil
                if PlayersInfoDropdown and PlayersInfoDropdown.Set then
                    PlayersInfoDropdown:Set(INFO_PLAYER_NONE)
                end
            end
        end
        updatePlayersInfoParagraph()
        if showNotify then
            mountNotify({ Title = "Players Info", Content = "Player list refreshed (" .. #infoPlayerList .. ")", Icon = "check" })
        end
    end

    LocalPlayerTab:CreateSection("Players Info")

    PlayersInfoDropdown = LocalPlayerTab:CreateDropdown({
        Name = "Player",
        Search = true,
        Options = playersInfoDropdownOptions(),
        CurrentOption = { INFO_PLAYER_NONE },
        Ext = true,
        Callback = function(opts)
            local value = type(opts) == "table" and opts[1] or opts
            selectedInfoPlayer = nil
            if value and value ~= INFO_PLAYER_NONE then
                local idx = table.find(infoPlayerDisplayNames, value)
                if idx and infoPlayerList[idx] then
                    selectedInfoPlayer = infoPlayerList[idx]
                end
            end
            updatePlayersInfoParagraph()
        end,
    })

    PlayersInfoParagraph = LocalPlayerTab:CreateParagraph({
        Title = PLAYERS_INFO_PAR_TITLE,
        Content = "Select a player from the list.",
    })

    LocalPlayerTab:CreateButton({
        Name = "Refresh list",
        Ext = true,
        Callback = function()
            refreshPlayersInfoList(true)
        end,
    })

    LocalPlayerTab:CreateButton({
        Name = "Refresh details",
        Ext = true,
        Callback = function()
            if not selectedInfoPlayer then
                mountNotify({ Title = "Players Info", Content = "Select a player first", Icon = "x" })
                return
            end
            updatePlayersInfoParagraph()
            mountNotify({ Title = "Players Info", Content = "Details updated", Icon = "check" })
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
        Ext = true,
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
                        Icon = "close",
                    })
                end
            else
                mountNotify({
                    Title = "Rejoin",
                    Content = "Cannot rejoin (missing PlaceId or JobId)",
                    Icon = "close",
                })
            end
        end,
    })

    LocalPlayerTab:CreateButton({
        Name = "Copy game ID",
        Ext = true,
        Callback = function()
            local paste = setclipboard or toclipboard
            if not paste then
                mountNotify({
                    Title = "Server",
                    Content = "Clipboard not supported in this environment",
                    Icon = "x",
                })
                return
            end
            local id = tostring(game.PlaceId)
            paste(id)
            mountNotify({
                Title = "Server",
                Content = "Copied PlaceId " .. id,
                Icon = "check",
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
            mountNotify({ Title = "Animation", Content = "R6 character parts not ready", Icon = "x" })
            return
        end
        local rightShoulder = torso:FindFirstChild("Right Shoulder")
        local neck = torso:FindFirstChild("Neck")
        if not (rightShoulder and rightShoulder:IsA("Motor6D") and neck and neck:IsA("Motor6D")) then
            animationRunning = false
            mountNotify({ Title = "Animation", Content = "R6 joints not found", Icon = "x" })
            return
        end
        local _, hairHandle = findHairAccessory(character)
        if not hairHandle then
            animationRunning = false
            mountNotify({ Title = "Animation", Content = "No hair accessory found", Icon = "x" })
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
        Options = animationOptions,
        CurrentOption = { selectedAnimationName },
        Ext = true,
        Callback = function(opts)
            local value = type(opts) == "table" and opts[1] or opts
            if value then
                selectedAnimationName = value
            end
        end,
    })
    LocalPlayerTab:CreateButton({
        Name = "Animate",
        Ext = true,
        Callback = function()
            if selectedAnimationName == "Hair Grab (R6)" then
                playHairGrabAnimationR6()
                return
            end
            mountNotify({ Title = "Animation", Content = "Unknown animation selected", Icon = "x" })
        end,
    })

    LocalPlayerTab:CreateButton({
        Name = "Clear Console",
        Ext = true,
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

    local autoSummitEnabled = false
    local summitQty = ""
    local autoSummitRandomizeTeleportDuration = false
    local autoSummitRestartFromDeath = false
    local autoSummitMode = "Teleport"
    local AUTO_SUMMIT_MODE_OPTIONS = { "Teleport" }
    local BETWEEN_RUN_DELAY = 10

    local summitTeleportRoute = {
        { name = "Start", position = "-922.94, 169.22, 856.29", delay = 20 },
        { name = "Camp 1", position = "-407.77, 248.20, 794.09", delay = 20 },
        { name = "Camp 2", position = "-337.77, 388.27, 522.16", delay = 20 },
        { name = "Camp 3", position = "294.19, 430.33, 494.17", delay = 20 },
        { name = "Camp 4", position = "323.46, 490.24, 348.33", delay = 28 },
        { name = "Camp 5", position = "226.70, 314.21, -143.64", delay = 45 },
        { name = "Summit", position = "-613.51, 905.28, -533.45", delay = 1 },
    }

    local function parsePositionString(positionText)
        if typeof(positionText) ~= "string" then
            return nil
        end
        local xStr, yStr, zStr = string.match(positionText, "^%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*$")
        local x, y, z = tonumber(xStr), tonumber(yStr), tonumber(zStr)
        if not x or not y or not z then
            return nil
        end
        return Vector3.new(x, y, z)
    end

    local function notifyAutoSummit(content, icon)
        mountNotify({ Title = "Auto Summit", Content = content, Icon = icon or "check" })
    end

    local function waitWithCancel(seconds, shouldCancel)
        local elapsed = 0
        local step = 0.25
        while elapsed < seconds do
            if shouldCancel() then
                return false
            end
            task.wait(math.min(step, seconds - elapsed))
            elapsed = elapsed + step
        end
        return true
    end

    MainTab:CreateSection("Auto Summit")

    MainTab:CreateDropdown({
        Name = "Mode",
        Options = AUTO_SUMMIT_MODE_OPTIONS,
        CurrentOption = { autoSummitMode },
        Ext = true,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            if picked and table.find(AUTO_SUMMIT_MODE_OPTIONS, picked) then
                autoSummitMode = picked
            end
        end,
    })

    local lpAutoSummit = Players.LocalPlayer

    local function getCheckpointIndexFromPlayer(player)
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            local n = ls:FindFirstChild("LastCheckpoint")
            if n and n:IsA("IntValue") then
                return n.Value
            end
            local s = ls:FindFirstChild("Checkpoint")
            if s and s:IsA("StringValue") then
                local v = s.Value
                if v and v ~= "" then
                    if v:lower() == "start" then
                        return 0
                    end
                    local d = string.match(v, "%d+")
                    return (d and tonumber(d)) or 0
                end
            end
        end
        local a = player:GetAttribute("LastCheckpoint")
        if typeof(a) == "number" then
            return a
        end
        if typeof(a) == "string" and a ~= "" then
            if a:lower() == "start" then
                return 0
            end
            local d = string.match(a, "%d+")
            return (d and tonumber(d)) or 0
        end
        return 0
    end

    local function getCheckpointLabelString(player)
        local attr = player:GetAttribute("LastCheckpoint")
        if typeof(attr) == "string" and attr ~= "" then
            return attr
        end
        if typeof(attr) == "number" then
            return tostring(attr)
        end
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            local iv = ls:FindFirstChild("LastCheckpoint")
            if iv and iv:IsA("IntValue") then
                return tostring(iv.Value)
            end
            local sv = ls:FindFirstChild("Checkpoint")
            if sv and sv:IsA("StringValue") and sv.Value ~= "" then
                return sv.Value
            end
        end
        return "Start"
    end

    local function routeLabelForCpIndex(idx)
        local wp = summitTeleportRoute[idx + 1]
        if wp then
            return wp.name
        end
        return "CP " .. tostring(idx)
    end

    -- CP 0 = Start â€¦ CP (#route-1) = Summit. Next teleport is route[cp+2] (1-based); at/past Summit nothing to skip.
    local function getFirstSummitRouteIndexFromCp(cpIdx)
        local routeN = #summitTeleportRoute
        local summitCpIndex = routeN - 1
        local cp = cpIdx
        if typeof(cp) ~= "number" then
            cp = 0
        end
        cp = math.floor(cp)
        if cp < 0 then
            cp = 0
        end
        if cp >= summitCpIndex then
            return nil, cp
        end
        local first = cp + 2
        if first < 1 then
            first = 1
        end
        if first > routeN then
            return nil, cp
        end
        return first, cp
    end

    local autoSummitRunTimes = {}

    local function formatAutoSummitDuration(sec)
        if typeof(sec) ~= "number" or sec ~= sec or sec < 0 then
            return "—"
        end
        if sec < 60 then
            return string.format("%.1fs", sec)
        end
        local m = math.floor(sec / 60)
        local s = sec - m * 60
        return string.format("%dm %.1fs", m, s)
    end

    local AUTO_SUMMIT_TIMES_TITLE = "Time per summit (this session)"
    local AutoSummitTimesParagraph
    local function updateAutoSummitTimesParagraph()
        if not AutoSummitTimesParagraph then
            return
        end
        local lines = {}
        local n = #autoSummitRunTimes
        local startIdx = 1
        local maxLines = 20
        if n > maxLines then
            startIdx = n - maxLines + 1
            table.insert(lines, "(Showing last " .. maxLines .. " runs)")
        end
        for i = startIdx, n do
            table.insert(
                lines,
                string.format("Run %d: %s", i, formatAutoSummitDuration(autoSummitRunTimes[i]))
            )
        end
        local desc = #lines > 0 and table.concat(lines, "\n") or "No completed runs yet."
        if AutoSummitTimesParagraph.Set then
            AutoSummitTimesParagraph:Set({
                Title = AUTO_SUMMIT_TIMES_TITLE,
                Content = desc,
            })
        end
    end

    local AUTO_SUMMIT_CP_TITLE = "Current camp / CP"
    local AutoSummitCpParagraph
    local function updateAutoSummitCpParagraph()
        if not autoSummitEnabled then
            return
        end
        if not AutoSummitCpParagraph then
            return
        end
        local posisi = getCheckpointLabelString(lpAutoSummit)
        local idx = getCheckpointIndexFromPlayer(lpAutoSummit)
        local routeName = routeLabelForCpIndex(idx)
        local desc = string.format("POSISI: %s\nCP #%d Â· %s", string.upper(posisi), idx, routeName)
        if AutoSummitCpParagraph.Set then
            AutoSummitCpParagraph:Set({
                Title = AUTO_SUMMIT_CP_TITLE,
                Content = desc,
            })
        end
    end

    AutoSummitCpParagraph = MainTab:CreateParagraph({
        Title = AUTO_SUMMIT_CP_TITLE,
        Content = "POSISI: â€”\nCP #0 Â· Start",
    })

    AutoSummitTimesParagraph = MainTab:CreateParagraph({
        Title = AUTO_SUMMIT_TIMES_TITLE,
        Content = "No completed runs yet.",
    })

    local function attachLeaderstatsForCp(ls)
        local function onCheckpointValueChanged()
            updateAutoSummitCpParagraph()
        end
        local n = ls:FindFirstChild("LastCheckpoint")
        if n and n:IsA("IntValue") then
            n:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
        end
        local s = ls:FindFirstChild("Checkpoint")
        if s and s:IsA("StringValue") then
            s:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
        end
        ls.ChildAdded:Connect(function(ch)
            if ch.Name == "LastCheckpoint" and ch:IsA("IntValue") then
                ch:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
                onCheckpointValueChanged()
            elseif ch.Name == "Checkpoint" and ch:IsA("StringValue") then
                ch:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
                onCheckpointValueChanged()
            end
        end)
    end

    lpAutoSummit:GetAttributeChangedSignal("LastCheckpoint"):Connect(updateAutoSummitCpParagraph)
    local lsSummitCp = lpAutoSummit:FindFirstChild("leaderstats")
    if lsSummitCp then
        attachLeaderstatsForCp(lsSummitCp)
    end
    lpAutoSummit.ChildAdded:Connect(function(ch)
        if ch.Name == "leaderstats" then
            attachLeaderstatsForCp(ch)
            updateAutoSummitCpParagraph()
        end
    end)
    task.defer(updateAutoSummitCpParagraph)

    local SummitQtyInput = MainTab:CreateInput({
        Name = "Qty of summit",
        PlaceholderText = "Empty = unlimited",
        CurrentValue = "",
        Ext = true,
        Callback = function(value)
            summitQty = value
        end,
    })

    MainTab:CreateToggle({
        Name = "Randomize duration (teleport mode)",
        CurrentValue = false,
        Ext = true,
        Callback = function(enabled)
            autoSummitRandomizeTeleportDuration = enabled
        end,
    })

    local autoSummitDeathCheckConn = nil

    local function onAutoSummitDeath()
        autoSummitRestartFromDeath = true
    end

    local function connectAutoSummitCharacterDied(character)
        if not character then
            return
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return
        end
        humanoid.Died:Connect(onAutoSummitDeath)
        humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then
                onAutoSummitDeath()
            end
        end)
    end

    if lpAutoSummit.Character then
        connectAutoSummitCharacterDied(lpAutoSummit.Character)
    end
    lpAutoSummit.CharacterAdded:Connect(connectAutoSummitCharacterDied)

    MainTab:CreateToggle({
        Name = "Auto Summit",
        CurrentValue = false,
        Ext = true,
        Callback = function(enabled)
            autoSummitEnabled = enabled
            if not enabled then
                if autoSummitDeathCheckConn then
                    autoSummitDeathCheckConn:Disconnect()
                    autoSummitDeathCheckConn = nil
                end
                return
            end

            autoSummitRestartFromDeath = false
            autoSummitRunTimes = {}
            updateAutoSummitTimesParagraph()
            updateAutoSummitCpParagraph()

            if autoSummitDeathCheckConn then
                autoSummitDeathCheckConn:Disconnect()
            end
            autoSummitDeathCheckConn = RunService.Heartbeat:Connect(function()
                if not autoSummitEnabled then
                    return
                end
                local char = lpAutoSummit.Character
                if not char then
                    return
                end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    onAutoSummitDeath()
                end
            end)

            local function getRootPart(timeoutSec)
                local char = lpAutoSummit.Character
                if not char then
                    char = lpAutoSummit.CharacterAdded:Wait()
                end
                return char:WaitForChild("HumanoidRootPart", timeoutSec or 15)
            end

            local rootPart = getRootPart()
            if not rootPart then
                notifyAutoSummit("Character not loaded", "x")
                return
            end

            local function shouldAbort()
                return not autoSummitEnabled or autoSummitRestartFromDeath
            end

            task.spawn(function()
                local qtyNum = tonumber(summitQty and summitQty:gsub("%s+", "") or "")
                local runCount = 0
                local remaining = qtyNum
                local skipNextCpResumeNotify = false
                repeat
                    if not autoSummitEnabled then
                        break
                    end
                    local runStartTime = os.clock()
                    rootPart = getRootPart()
                    if not rootPart then
                        local char = lpAutoSummit.Character
                        if char then
                            char:WaitForChild("HumanoidRootPart", 10)
                        else
                            char = lpAutoSummit.CharacterAdded:Wait()
                            char:WaitForChild("HumanoidRootPart", 10)
                        end
                        task.wait(1)
                        rootPart = getRootPart()
                        if not rootPart then
                            notifyAutoSummit("Could not get character after respawn", "x")
                            break
                        end
                    end

                    local routeCompleted = true
                    local cpNow = getCheckpointIndexFromPlayer(lpAutoSummit)
                    local firstWpIndex, cpClamped = getFirstSummitRouteIndexFromCp(cpNow)
                    local skippedSummitTeleports = firstWpIndex == nil
                    if skippedSummitTeleports then
                        skipNextCpResumeNotify = false
                    elseif not skipNextCpResumeNotify then
                        notifyAutoSummit(
                            ("CP #%d (%s) â€” continuing from %sâ€¦"):format(
                                cpClamped,
                                routeLabelForCpIndex(cpClamped),
                                summitTeleportRoute[firstWpIndex].name
                            )
                        )
                    else
                        skipNextCpResumeNotify = false
                    end
                    if not skippedSummitTeleports then
                        for wi = firstWpIndex, #summitTeleportRoute do
                            local wp = summitTeleportRoute[wi]
                            if not autoSummitEnabled or autoSummitRestartFromDeath then
                                routeCompleted = false
                                break
                            end
                            rootPart = getRootPart()
                            if not rootPart then
                                routeCompleted = false
                                break
                            end
                            local targetPosition = parsePositionString(wp.position)
                            if not targetPosition then
                                routeCompleted = false
                                notifyAutoSummit("Invalid position for " .. wp.name, "x")
                                break
                            end
                            rootPart.CFrame = CFrame.new(targetPosition)
                            notifyAutoSummit("Teleported to " .. wp.name .. "â€¦")
                            local waitSec = wp.delay
                            if
                                autoSummitMode == "Teleport"
                                and autoSummitRandomizeTeleportDuration
                                and wp.name ~= "Summit"
                            then
                                waitSec = math.max(0.5, wp.delay + math.random(-15, 15))
                            end
                            if not waitWithCancel(waitSec, shouldAbort) then
                                routeCompleted = false
                                break
                            end
                        end
                    end

                    if autoSummitRestartFromDeath then
                        notifyAutoSummit("Character died â€” waiting for respawnâ€¦")
                        local char = lpAutoSummit.Character
                        if not char then
                            char = lpAutoSummit.CharacterAdded:Wait()
                        else
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health <= 0 then
                                char = lpAutoSummit.CharacterAdded:Wait()
                            end
                        end
                        if char then
                            char:WaitForChild("HumanoidRootPart", 15)
                            task.wait(0.5)
                        end
                        for _ = 1, 15 do
                            if lpAutoSummit:FindFirstChild("leaderstats") then
                                break
                            end
                            task.wait(0.1)
                        end
                        task.wait(0.35)
                        local cpRespawn = getCheckpointIndexFromPlayer(lpAutoSummit)
                        local firstRespawn, cpRespawnClamped = getFirstSummitRouteIndexFromCp(cpRespawn)
                        task.defer(updateAutoSummitCpParagraph)
                        autoSummitRestartFromDeath = false
                        skipNextCpResumeNotify = true
                        if firstRespawn == nil then
                            notifyAutoSummit(
                                ("Respawned â€” CP #%d (%s). Next leg: Summit / count run (no teleports)."):format(
                                    cpRespawnClamped,
                                    routeLabelForCpIndex(cpRespawnClamped)
                                )
                            )
                        else
                            notifyAutoSummit(
                                ("Respawned â€” CP #%d (%s); resuming from %s."):format(
                                    cpRespawnClamped,
                                    routeLabelForCpIndex(cpRespawnClamped),
                                    summitTeleportRoute[firstRespawn].name
                                )
                            )
                        end
                    elseif routeCompleted and autoSummitEnabled then
                        if skippedSummitTeleports then
                            notifyAutoSummit(
                                ("Already at Summit (CP #%d) â€” run %d."):format(cpClamped, runCount + 1)
                            )
                        else
                            notifyAutoSummit("Reached Summit! (Run " .. (runCount + 1) .. ")")
                        end
                        local elapsedRun = os.clock() - runStartTime
                        table.insert(autoSummitRunTimes, elapsedRun)
                        task.defer(updateAutoSummitTimesParagraph)
                        runCount = runCount + 1
                        if remaining then
                            remaining = remaining - 1
                            summitQty = tostring(remaining)
                            task.defer(function()
                                if SummitQtyInput then
                                    if SummitQtyInput.Set then
                                        SummitQtyInput:Set(summitQty)
                                    end
                                    if SummitQtyInput.SetValue then
                                        SummitQtyInput:SetValue(summitQty)
                                    end
                                end
                            end)
                        end
                        if autoSummitEnabled and (not qtyNum or remaining > 0) then
                            if not waitWithCancel(BETWEEN_RUN_DELAY, function()
                                return not autoSummitEnabled
                            end) then
                                break
                            end
                        end
                    end
                until not autoSummitEnabled or (qtyNum and remaining and remaining <= 0)

                if autoSummitEnabled and qtyNum and remaining and remaining <= 0 then
                    notifyAutoSummit("All runs completed (" .. runCount .. " run(s))")
                elseif not autoSummitEnabled then
                    notifyAutoSummit("Stopped", "x")
                end

                if autoSummitDeathCheckConn then
                    autoSummitDeathCheckConn:Disconnect()
                    autoSummitDeathCheckConn = nil
                end
            end)
        end,
    })

    MainTab:CreateSection("Send Request Carry")

    MainTab:CreateParagraph({
        Title = "How it works",
        Content = "Pick players from the list and/or type additional names (comma, semicolon, or line — same visible name as in-game / dropdown). Before each send, names are matched to players currently in the server; unmatched names are skipped. A request is only sent if your character and the target’s HumanoidRootPart are within 18 studs.\n\nCarryRemote.OnClientEvent: \"CarrierList\" keeps current carriers — those user ids are skipped; \"RequestExpired\" notifies; \"Declined\" excludes that targetId for 5 minutes.",
    })

    local SendRequestCarryCarrierListParagraph
    local sendRequestCarryUpdateCarrierListParagraph

    SendRequestCarryCarrierListParagraph = MainTab:CreateParagraph({
        Title = "Carrier list",
        Content = "(no data yet — updates when the server sends CarrierList)",
    })

    local sendRequestCarrySelected = {}
    local sendRequestCarryAdditionalPlayersText = ""
    local SendRequestCarryPlayersDropdown
    local sendRequestCarryAutoLoopToken = 0

    local SEND_REQUEST_CARRY_DELAY_PER_TARGET = 4
    local SEND_REQUEST_CARRY_CYCLE_GAP = 6
    local SEND_REQUEST_CARRY_MAX_DISTANCE_STUDS = 18
    local SEND_REQUEST_CARRY_DECLINED_COOLDOWN_SEC = 5 * 60
    local sendRequestCarryDeclinedUntilByUserId = {}
    local sendRequestCarryCarrierListIds = {}
    local sendRequestCarryCarrierListEntries = {}

    local function sendRequestCarryApplyCarrierList(data)
        local newSet = {}
        local entries = {}
        if type(data) == "table" then
            local list = data.list
            if type(list) == "table" then
                for _, entry in ipairs(list) do
                    if type(entry) == "table" then
                        local eid = entry.id
                        if typeof(eid) ~= "number" then
                            eid = tonumber(tostring(eid))
                        end
                        local ename = entry.name
                        if typeof(ename) ~= "string" then
                            ename = ename ~= nil and tostring(ename) or ""
                        end
                        if eid and eid > 0 then
                            newSet[eid] = true
                            local ufrom = entry.username
                            if typeof(ufrom) ~= "string" or ufrom == "" then
                                ufrom = entry.userName
                            end
                            if typeof(ufrom) ~= "string" then
                                ufrom = nil
                            elseif ufrom == "" then
                                ufrom = nil
                            end
                            table.insert(entries, {
                                name = ename,
                                id = eid,
                                username = ufrom,
                            })
                        end
                    end
                end
            end
        end
        sendRequestCarryCarrierListIds = newSet
        sendRequestCarryCarrierListEntries = entries
        if sendRequestCarryUpdateCarrierListParagraph then
            sendRequestCarryUpdateCarrierListParagraph()
        end
    end

    sendRequestCarryUpdateCarrierListParagraph = function()
        if not SendRequestCarryCarrierListParagraph then
            return
        end
        local content
        if #sendRequestCarryCarrierListEntries == 0 then
            content = "(empty)"
        else
            local lines = {}
            for _, e in ipairs(sendRequestCarryCarrierListEntries) do
                local nm = e.name
                if not nm or nm == "" then
                    nm = "?"
                end
                local usernameStr = e.username
                local plr = Players:GetPlayerByUserId(e.id)
                if plr then
                    usernameStr = plr.Name
                elseif typeof(usernameStr) ~= "string" or usernameStr == "" then
                    usernameStr = nil
                end
                local line = "• " .. nm
                if usernameStr then
                    line = line .. "  [" .. usernameStr .. "]"
                end
                line = line .. "  [" .. tostring(e.id) .. "]"
                table.insert(lines, line)
            end
            content = table.concat(lines, "\n")
        end
        if SendRequestCarryCarrierListParagraph.Set then
            SendRequestCarryCarrierListParagraph:Set({
                Title = "Carrier list",
                Content = content,
            })
        end
    end

    local function sendRequestCarryIsOnCarrierList(userId)
        if typeof(userId) ~= "number" then
            userId = tonumber(tostring(userId))
        end
        if not userId then
            return false
        end
        return sendRequestCarryCarrierListIds[userId] == true
    end

    local function sendRequestCarryIsDeclinedCooldownActive(userId)
        if typeof(userId) ~= "number" then
            userId = tonumber(tostring(userId))
        end
        if not userId then
            return false
        end
        local untilT = sendRequestCarryDeclinedUntilByUserId[userId]
        if not untilT then
            return false
        end
        if tick() >= untilT then
            sendRequestCarryDeclinedUntilByUserId[userId] = nil
            return false
        end
        return true
    end

    local function sendRequestCarryMarkDeclined(userId)
        if typeof(userId) ~= "number" then
            userId = tonumber(tostring(userId))
        end
        if not userId then
            return
        end
        sendRequestCarryDeclinedUntilByUserId[userId] = tick() + SEND_REQUEST_CARRY_DECLINED_COOLDOWN_SEC
    end

    local function sendRequestCarryGetRootPart(character)
        if not character then
            return nil
        end
        local r = character:FindFirstChild("HumanoidRootPart")
        if r and r:IsA("BasePart") then
            return r
        end
        local pp = character.PrimaryPart
        if pp and pp:IsA("BasePart") then
            return pp
        end
        return nil
    end

    local function sendRequestCarryIsTargetWithinRange(targetUserId, maxDist)
        if typeof(targetUserId) ~= "number" then
            targetUserId = tonumber(tostring(targetUserId))
        end
        if not targetUserId then
            return false
        end
        local lp = lpAutoSummit
        local myRoot = sendRequestCarryGetRootPart(lp.Character)
        if not myRoot then
            return false
        end
        local tgtPlr = Players:GetPlayerByUserId(targetUserId)
        if not tgtPlr or tgtPlr == lp then
            return false
        end
        local tRoot = sendRequestCarryGetRootPart(tgtPlr.Character)
        if not tRoot then
            return false
        end
        return (myRoot.Position - tRoot.Position).Magnitude <= maxDist
    end

    local function sendRequestCarryOtherPlayerLabel(player)
        if not player then
            return ""
        end
        local dn = player.DisplayName
        if dn and dn ~= "" then
            return dn
        end
        return player.Name
    end

    local function sendRequestCarryDropdownOptions()
        local opts = {}
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.ClassName == "Player" then
                table.insert(opts, sendRequestCarryOtherPlayerLabel(plr))
            end
        end
        table.sort(opts, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return opts
    end

    local function sendRequestCarryFindPlayerByLabel(label)
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and sendRequestCarryOtherPlayerLabel(plr) == label then
                return plr
            end
        end
        return nil
    end

    local function sendRequestCarryTrim(s)
        if typeof(s) ~= "string" then
            return ""
        end
        return (s:gsub("^%s+", ""):gsub("%s+$", ""))
    end

    local function sendRequestCarryFindOtherPlayerByVisibleName(nameQuery)
        local q = sendRequestCarryTrim(nameQuery)
        if q == "" then
            return nil
        end
        local lowerQ = string.lower(q)
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.ClassName == "Player" then
                local label = sendRequestCarryOtherPlayerLabel(plr)
                if label == q or string.lower(label) == lowerQ then
                    return plr
                end
            end
        end
        return nil
    end

    local function sendRequestCarryResolveAdditionalPlayersToUserIds(str)
        local out = {}
        local seen = {}
        if typeof(str) ~= "string" or str == "" then
            return out
        end
        for segment in string.gmatch(str, "([^,;\n]+)") do
            local plr = sendRequestCarryFindOtherPlayerByVisibleName(segment)
            if plr then
                local uid = plr.UserId
                if typeof(uid) == "number" and uid > 0 and not seen[uid] then
                    seen[uid] = true
                    table.insert(out, uid)
                end
            end
        end
        return out
    end

    local function sendRequestCarryCollectTargetIds()
        local ids = {}
        local seen = {}
        local function addId(id)
            if typeof(id) == "number" and id > 0 and not seen[id] then
                seen[id] = true
                table.insert(ids, id)
            end
        end
        for _, label in ipairs(sendRequestCarrySelected) do
            local plr = sendRequestCarryFindPlayerByLabel(label)
            if plr then
                addId(plr.UserId)
            end
        end
        for _, n in ipairs(sendRequestCarryResolveAdditionalPlayersToUserIds(sendRequestCarryAdditionalPlayersText)) do
            addId(n)
        end
        local filtered = {}
        for _, id in ipairs(ids) do
            if not sendRequestCarryIsDeclinedCooldownActive(id) and not sendRequestCarryIsOnCarrierList(id) then
                table.insert(filtered, id)
            end
        end
        return filtered
    end

    local function sendRequestCarryPurgeStaleSelections()
        local opts = sendRequestCarryDropdownOptions()
        local valid = {}
        for _, sel in ipairs(sendRequestCarrySelected) do
            if table.find(opts, sel) then
                table.insert(valid, sel)
            end
        end
        local removed = #valid ~= #sendRequestCarrySelected
        sendRequestCarrySelected = valid
        if removed and SendRequestCarryPlayersDropdown and SendRequestCarryPlayersDropdown.Set then
            SendRequestCarryPlayersDropdown:Set(valid)
        end
    end

    local function sendRequestCarryRefreshList()
        local opts = sendRequestCarryDropdownOptions()
        if SendRequestCarryPlayersDropdown and SendRequestCarryPlayersDropdown.Refresh then
            SendRequestCarryPlayersDropdown:Refresh(opts)
        end
        sendRequestCarryPurgeStaleSelections()
    end

    SendRequestCarryPlayersDropdown = MainTab:CreateDropdown({
        Name = "Players (multi-select)",
        Options = sendRequestCarryDropdownOptions(),
        CurrentOption = {},
        MultipleOptions = true,
        Search = true,
        Ext = true,
        Callback = function(selected)
            if type(selected) == "table" then
                sendRequestCarrySelected = selected
            elseif selected then
                sendRequestCarrySelected = { selected }
            else
                sendRequestCarrySelected = {}
            end
        end,
    })

    MainTab:CreateInput({
        Name = "Additional players",
        PlaceholderText = "Display names, e.g. kyazuramoe, FriendName",
        CurrentValue = "",
        Ext = true,
        Callback = function(value)
            sendRequestCarryAdditionalPlayersText = value or ""
        end,
    })

    local SendRequestCarryAutoToggle
    SendRequestCarryAutoToggle = MainTab:CreateToggle({
        Name = "Auto Send Request",
        CurrentValue = false,
        Ext = true,
        Callback = function(enabled)
            sendRequestCarryAutoLoopToken = sendRequestCarryAutoLoopToken + 1
            if not enabled then
                return
            end

            local ok, carryRemote = pcall(function()
                return ReplicatedStorage:WaitForChild("CarryRemote", 10)
            end)
            if not ok or not carryRemote then
                mountNotify({
                    Title = "Send Request Carry",
                    Content = "CarryRemote not found in ReplicatedStorage",
                    Icon = "x",
                })
                if SendRequestCarryAutoToggle and SendRequestCarryAutoToggle.Set then
                    SendRequestCarryAutoToggle:Set(false)
                end
                return
            end

            local loopId = sendRequestCarryAutoLoopToken
            local warnedNoTargets = false

            task.spawn(function()
                while loopId == sendRequestCarryAutoLoopToken do
                    local targets = sendRequestCarryCollectTargetIds()
                    if #targets == 0 then
                        if not warnedNoTargets then
                            warnedNoTargets = true
                            mountNotify({
                                Title = "Send Request Carry",
                                Content = "No targets — select players and/or add names that match someone in the server",
                                Icon = "x",
                            })
                        end
                        task.wait(5)
                    else
                        warnedNoTargets = false
                        for _, targetId in ipairs(targets) do
                            if loopId ~= sendRequestCarryAutoLoopToken then
                                break
                            end
                            if sendRequestCarryIsTargetWithinRange(targetId, SEND_REQUEST_CARRY_MAX_DISTANCE_STUDS) then
                                pcall(function()
                                    carryRemote:FireServer("Request", {
                                        targetId = targetId,
                                    })
                                end)
                                task.wait(SEND_REQUEST_CARRY_DELAY_PER_TARGET)
                            end
                        end
                        task.wait(SEND_REQUEST_CARRY_CYCLE_GAP)
                    end
                end
            end)

            mountNotify({
                Title = "Send Request Carry",
                Content = "Auto send started",
                Icon = "check",
            })
        end,
    })

    Players.PlayerAdded:Connect(function()
        task.defer(sendRequestCarryRefreshList)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(sendRequestCarryRefreshList)
    end)
    task.defer(sendRequestCarryRefreshList)

    task.defer(function()
        local ok, carryRemote = pcall(function()
            return ReplicatedStorage:WaitForChild("CarryRemote", 60)
        end)
        if not ok or not carryRemote then
            return
        end
        carryRemote.OnClientEvent:Connect(function(kind, data)
            if type(data) ~= "table" then
                return
            end
            local tid = data.targetId
            if typeof(tid) ~= "number" then
                tid = tonumber(tostring(tid))
            end
            if kind == "RequestExpired" then
                mountNotify({
                    Title = "Carry request",
                    Content = "RequestExpired for targetId " .. tostring(tid),
                    Icon = "x",
                })
            elseif kind == "Declined" and tid then
                sendRequestCarryMarkDeclined(tid)
                mountNotify({
                    Title = "Carry request",
                    Content = "Declined — targetId "
                        .. tostring(tid)
                        .. " excluded from auto-send for "
                        .. tostring(SEND_REQUEST_CARRY_DECLINED_COOLDOWN_SEC / 60)
                        .. " min",
                    Icon = "x",
                })
            elseif kind == "CarrierList" then
                sendRequestCarryApplyCarrierList(data)
            end
        end)
    end)

    MainTab:CreateSection("Accept Incoming Carry")

    MainTab:CreateParagraph({
        Title = "How it works",
        Content = "If you select specific players below, only carry requests from those players are accepted. If nothing is selected, requests from everyone are accepted.\n\nUse the toggle to listen on ReplicatedStorage.CarryRemote for the \"Prompt\" action and reply with \"Response\" (accept = true).",
    })

    local acceptIncomingCarrySelected = {}
    local AcceptIncomingCarryPlayersDropdown
    local acceptIncomingCarryRemoteConn = nil

    local function acceptIncomingCarryOtherPlayerLabel(player)
        if not player then
            return ""
        end
        local dn = player.DisplayName
        if dn and dn ~= "" then
            return dn
        end
        return player.Name
    end

    local function acceptIncomingCarryDropdownOptions()
        local opts = {}
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.ClassName == "Player" then
                table.insert(opts, acceptIncomingCarryOtherPlayerLabel(plr))
            end
        end
        table.sort(opts, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return opts
    end

    local function acceptIncomingCarryFindPlayerByLabel(label)
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and acceptIncomingCarryOtherPlayerLabel(plr) == label then
                return plr
            end
        end
        return nil
    end

    local function acceptIncomingCarryFromNameMatchesOption(fromName, optionLabel)
        if fromName == optionLabel then
            return true
        end
        local plr = acceptIncomingCarryFindPlayerByLabel(optionLabel)
        if plr then
            if fromName == plr.Name or (plr.DisplayName and fromName == plr.DisplayName) then
                return true
            end
        end
        return false
    end

    local function acceptIncomingCarryShouldAccept(fromName)
        if not acceptIncomingCarrySelected or #acceptIncomingCarrySelected == 0 then
            return true
        end
        for _, opt in ipairs(acceptIncomingCarrySelected) do
            if acceptIncomingCarryFromNameMatchesOption(fromName, opt) then
                return true
            end
        end
        return false
    end

    local function acceptIncomingCarryPurgeStaleSelections()
        local opts = acceptIncomingCarryDropdownOptions()
        local valid = {}
        for _, sel in ipairs(acceptIncomingCarrySelected) do
            if table.find(opts, sel) then
                table.insert(valid, sel)
            end
        end
        local removed = #valid ~= #acceptIncomingCarrySelected
        acceptIncomingCarrySelected = valid
        if removed and AcceptIncomingCarryPlayersDropdown and AcceptIncomingCarryPlayersDropdown.Set then
            AcceptIncomingCarryPlayersDropdown:Set(valid)
        end
    end

    local function acceptIncomingCarryRefreshList()
        local opts = acceptIncomingCarryDropdownOptions()
        if AcceptIncomingCarryPlayersDropdown and AcceptIncomingCarryPlayersDropdown.Refresh then
            AcceptIncomingCarryPlayersDropdown:Refresh(opts)
        end
        acceptIncomingCarryPurgeStaleSelections()
    end

    AcceptIncomingCarryPlayersDropdown = MainTab:CreateDropdown({
        Name = "Other players (display name)",
        Options = acceptIncomingCarryDropdownOptions(),
        CurrentOption = {},
        MultipleOptions = true,
        Search = true,
        Ext = true,
        Callback = function(selected)
            if type(selected) == "table" then
                acceptIncomingCarrySelected = selected
            elseif selected then
                acceptIncomingCarrySelected = { selected }
            else
                acceptIncomingCarrySelected = {}
            end
        end,
    })

    local AcceptIncomingCarryListenToggle
    AcceptIncomingCarryListenToggle = MainTab:CreateToggle({
        Name = "Listen for \"Prompt\" (auto-accept incoming carry)",
        CurrentValue = false,
        Ext = true,
        Callback = function(enabled)
            if acceptIncomingCarryRemoteConn then
                acceptIncomingCarryRemoteConn:Disconnect()
                acceptIncomingCarryRemoteConn = nil
            end
            if not enabled then
                return
            end
            local ok, carryRemote = pcall(function()
                return ReplicatedStorage:WaitForChild("CarryRemote", 10)
            end)
            if not ok or not carryRemote then
                mountNotify({
                    Title = "Accept Incoming Carry",
                    Content = "CarryRemote not found in ReplicatedStorage",
                    Icon = "x",
                })
                if AcceptIncomingCarryListenToggle and AcceptIncomingCarryListenToggle.Set then
                    AcceptIncomingCarryListenToggle:Set(false)
                end
                return
            end
            acceptIncomingCarryRemoteConn = carryRemote.OnClientEvent:Connect(function(kind, data)
                if kind ~= "Prompt" or type(data) ~= "table" then
                    return
                end
                local fromName = data.fromName
                local fromId = data.fromId
                if fromName == nil or fromId == nil then
                    return
                end
                fromName = tostring(fromName)
                if typeof(fromId) ~= "number" then
                    fromId = tonumber(tostring(fromId))
                end
                if not fromId then
                    return
                end
                if not acceptIncomingCarryShouldAccept(fromName) then
                    return
                end
                pcall(function()
                    carryRemote:FireServer("Response", {
                        requesterId = fromId,
                        accept = true,
                    })
                end)
            end)
            mountNotify({
                Title = "Accept Incoming Carry",
                Content = "Listening for carry prompts",
                Icon = "check",
            })
        end,
    })

    Players.PlayerAdded:Connect(function()
        task.defer(acceptIncomingCarryRefreshList)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(acceptIncomingCarryRefreshList)
    end)
    task.defer(acceptIncomingCarryRefreshList)

    MainTab:CreateSection("Transfer Cash")

    local transferCashAmountText = ""
    local transferCashSelectedPlayer: Player? = nil
    local TransferCashPlayersDropdown

    local function transferCashPlayerLabel(player: Player)
        local lp = Players.LocalPlayer
        local dn = player.DisplayName
        local base: string
        if dn and dn ~= "" and dn ~= player.Name then
            base = string.format("%s (@%s)", dn, player.Name)
        else
            base = player.Name
        end
        if player == lp then
            return base .. " (you)"
        end
        return base
    end

    local function transferCashDropdownOptions()
        local opts = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.ClassName == "Player" then
                table.insert(opts, transferCashPlayerLabel(plr))
            end
        end
        table.sort(opts, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return opts
    end

    local function transferCashFindPlayerByLabel(label: string)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.ClassName == "Player" and transferCashPlayerLabel(plr) == label then
                return plr
            end
        end
        return nil
    end

    local function transferCashRefreshList()
        local opts = transferCashDropdownOptions()
        if transferCashSelectedPlayer then
            if Players:GetPlayerByUserId(transferCashSelectedPlayer.UserId) ~= transferCashSelectedPlayer then
                transferCashSelectedPlayer = nil
            end
        end
        if TransferCashPlayersDropdown and TransferCashPlayersDropdown.Refresh then
            TransferCashPlayersDropdown:Refresh(opts)
        end
        if transferCashSelectedPlayer then
            local lbl = transferCashPlayerLabel(transferCashSelectedPlayer)
            if table.find(opts, lbl) and TransferCashPlayersDropdown and TransferCashPlayersDropdown.Set then
                TransferCashPlayersDropdown:Set({ lbl })
            end
        end
    end

    local transferCashInitialOpts = transferCashDropdownOptions()
    local transferCashInitialCurrent = {}
    if #transferCashInitialOpts > 0 then
        transferCashInitialCurrent = { transferCashInitialOpts[1] }
        transferCashSelectedPlayer = transferCashFindPlayerByLabel(transferCashInitialOpts[1])
    end

    TransferCashPlayersDropdown = MainTab:CreateDropdown({
        Name = "Player",
        Options = transferCashInitialOpts,
        CurrentOption = transferCashInitialCurrent,
        Search = true,
        Ext = true,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            transferCashSelectedPlayer = picked and transferCashFindPlayerByLabel(picked) or nil
        end,
    })

    MainTab:CreateInput({
        Name = "Amount",
        PlaceholderText = "e.g. 100",
        CurrentValue = "",
        Ext = true,
        Callback = function(value)
            transferCashAmountText = value or ""
        end,
    })

    MainTab:CreateButton({
        Name = "Give Cash",
        Ext = true,
        Callback = function()
            if not transferCashSelectedPlayer then
                mountNotify({ Title = "Transfer Cash", Content = "Select a player first", Icon = "x" })
                return
            end
            local amtStr = (transferCashAmountText or ""):gsub(",", ""):gsub("%s+", "")
            local amountNum = tonumber(amtStr)
            local amountPayload
            if amountNum ~= nil then
                amountPayload = amountNum
            else
                amountPayload = amtStr
            end
            local targetId = transferCashSelectedPlayer.UserId
            local okFire, errFire = pcall(function()
                local tax = ReplicatedStorage:FindFirstChild("CashTransferTax")
                if not tax then
                    tax = ReplicatedStorage:WaitForChild("CashTransferTax", 5)
                end
                if tax then
                    if tax:IsA("IntValue") or tax:IsA("NumberValue") then
                        tax.Value = 0
                    elseif tax:IsA("StringValue") then
                        tax.Value = "0"
                    end
                end
                local ev = ReplicatedStorage:FindFirstChild("CashTransferRemote")
                if not ev then
                    ev = ReplicatedStorage:WaitForChild("CashTransferRemote", 10)
                end
                if not ev then
                    error("CashTransferRemote not found in ReplicatedStorage")
                end
                ev:FireServer("RequestTransfer", {
                    targetId = targetId,
                    amount = amountPayload,
                })
            end)
            if not okFire then
                mountNotify({
                    Title = "Transfer Cash",
                    Content = tostring(errFire),
                    Icon = "x",
                })
            end
        end,
    })

    task.defer(function()
        local ok, ackRemote = pcall(function()
            return ReplicatedStorage:WaitForChild("CashTransferAck", 60)
        end)
        if not ok or not ackRemote or not ackRemote:IsA("RemoteEvent") then
            return
        end
        ackRemote.OnClientEvent:Connect(function(data)
            local msg: string?
            local okFlag: boolean?
            if type(data) == "table" then
                local m = data.message
                msg = typeof(m) == "string" and m or nil
                okFlag = data.ok
            elseif type(data) == "string" then
                msg = data
                okFlag = true
            else
                return
            end
            if not msg or msg == "" then
                msg = okFlag == false and "Transfer failed." or "Transfer acknowledged."
            end
            mountNotify({
                Title = "Transfer Cash",
                Content = msg,
                Icon = okFlag == false and "x" or "check",
            })
        end)
    end)

    Players.PlayerAdded:Connect(function()
        task.defer(transferCashRefreshList)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(transferCashRefreshList)
    end)
    task.defer(transferCashRefreshList)
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
        CurrentValue = teleportInputValue,
        Ext = true,
        Callback = function(value)
            teleportInputValue = value
        end,
    })

    local TeleportLookInput = TeleportTab:CreateInput({
        Name = "Look direction",
        PlaceholderText = "e.g. 0, 0, -1 or leave empty for position only",
        CurrentValue = teleportLookInputValue,
        Ext = true,
        Callback = function(value)
            teleportLookInputValue = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Get Current Location",
        Ext = true,
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
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
                Icon = "check",
            })
        end,
    })

    TeleportTab:CreateButton({
        Name = "Teleport",
        Ext = true,
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local cf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not cf then
                mountNotify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                    Icon = "x",
                })
                return
            end
            rootPart.CFrame = cf
            local p = cf.Position
            mountNotify({
                Title = "Teleport",
                Content = string.format("Teleported to %.1f, %.1f, %.1f", p.X, p.Y, p.Z),
                Icon = "check",
            })
        end,
    })

    local tweenDurationValue = "5"
    TeleportTab:CreateInput({
        Name = "Tween Duration",
        PlaceholderText = "e.g. 5",
        CurrentValue = tweenDurationValue,
        Ext = true,
        Callback = function(value)
            tweenDurationValue = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Tween to Location",
        Ext = true,
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local targetCf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not targetCf then
                mountNotify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                    Icon = "x",
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
                Icon = "check",
            })
        end,
    })

    TeleportTab:CreateSection("Teleport to camp")

    local function teleportToCampCoords(x, y, z, placeName)
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            mountNotify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
            return
        end
        rootPart.CFrame = CFrame.new(x, y, z)
        mountNotify({
            Title = "Teleport",
            Content = "Teleported to " .. placeName,
            Icon = "check",
        })
    end

    local campLocations = {
        { label = "Camp 1", x = -407.77, y = 248.20, z = 794.09 },
        { label = "Camp 2", x = -337.77, y = 388.27, z = 522.16 },
        { label = "Camp 3", x = 294.19, y = 430.33, z = 494.17 },
        { label = "Camp 4", x = 323.46, y = 490.24, z = 348.33 },
        { label = "Camp 5", x = 226.70, y = 314.21, z = -143.64 },
        { label = "Summit", x = -613.51, y = 905.28, z = -533.45 },
    }

    for _, loc in ipairs(campLocations) do
        local label, cx, cy, cz = loc.label, loc.x, loc.y, loc.z
        TeleportTab:CreateButton({
            Name = label,
            Ext = true,
            Callback = function()
                teleportToCampCoords(cx, cy, cz, label)
            end,
        })
    end

    -- */  Teleport to Players  /* --
    TeleportTab:CreateSection("Teleport to Players")

    local TELEPORT_PLAYER_NONE = "(None)"
    local playerDisplayNames = {}
    local playerList = {}
    local selectedTeleportPlayer = nil
    local PlayerTeleportDropdown

    local function teleportPlayerDropdownOptions()
        local opts = { TELEPORT_PLAYER_NONE }
        for _, n in ipairs(playerDisplayNames) do
            table.insert(opts, n)
        end
        return opts
    end

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
            PlayerTeleportDropdown:Refresh(teleportPlayerDropdownOptions())
        end
        if selectedTeleportPlayer then
            if not table.find(playerList, selectedTeleportPlayer) then
                selectedTeleportPlayer = nil
                if PlayerTeleportDropdown and PlayerTeleportDropdown.Set then
                    PlayerTeleportDropdown:Set(TELEPORT_PLAYER_NONE)
                end
            end
        end
        if showNotify then
            mountNotify({ Title = "Teleport", Content = "Player list refreshed (" .. #playerList .. " players)", Icon = "check" })
        end
    end

    PlayerTeleportDropdown = TeleportTab:CreateDropdown({
        Name = "Player",
        Search = true,
        Options = teleportPlayerDropdownOptions(),
        CurrentOption = { TELEPORT_PLAYER_NONE },
        Ext = true,
        Callback = function(opts)
            local value = type(opts) == "table" and opts[1] or opts
            selectedTeleportPlayer = nil
            if value and value ~= TELEPORT_PLAYER_NONE then
                local idx = table.find(playerDisplayNames, value)
                if idx and playerList[idx] then
                    selectedTeleportPlayer = playerList[idx]
                end
            end
        end,
    })

    TeleportTab:CreateButton({
        Name = "Refresh",
        Ext = true,
        Callback = function()
            refreshPlayerList(true)
        end,
    })

    TeleportTab:CreateButton({
        Name = "Teleport",
        Ext = true,
        Callback = function()
            if not selectedTeleportPlayer then
                mountNotify({ Title = "Teleport", Content = "Select a player first", Icon = "x" })
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local targetChar = selectedTeleportPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then
                mountNotify({ Title = "Teleport", Content = "Target player has no character", Icon = "x" })
                return
            end
            rootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0, 3))
            mountNotify({ Title = "Teleport", Content = "Teleported to " .. (selectedTeleportPlayer.DisplayName or selectedTeleportPlayer.Name), Icon = "check" })
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
            if p and p.Destroy then
                pcall(function()
                    p:Destroy()
                end)
            end
            refs[i] = nil
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
    ObjectsTab:CreateSection("ReplicatedStorage")
    local ReplicatedStorageDropdown
    local ReplicatedStorageChildrenParagraph
    local rsChildrenOverflowParagraphs = {}

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

    ObjectsTab:CreateSection("Players")
    local PlayersServiceDropdown
    local PlayersServiceChildrenParagraph
    local plrsChildrenOverflowParagraphs = {}

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

    ObjectsTab:CreateSection("Local Player")
    local LocalPlayerDropdown
    local LocalPlayerChildrenParagraph
    local lpChildrenOverflowParagraphs = {}

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

    ObjectsTab:CreateSection("Workspace")
    local WorkspaceDropdown
    local WorkspaceChildrenParagraph
    local wsChildrenOverflowParagraphs = {}

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

end
