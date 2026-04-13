local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

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
        Content = opts.Content or "",
        Image = img,
        Duration = opts.Duration or 4,
    })
end

-- */  Window  /* --
local Window = RayfieldLibrary:CreateWindow({
    Name = "sempatpanick | Expedition Antartica",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Expedition Antartica",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "sempatpanick",
        FileName = "expedition_antartica",
    },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
})

-- */  Shared helpers (reusable)  /* --
local function parsePositionString(posStr)
    if not posStr or type(posStr) ~= "string" then return nil end
    local s = posStr:gsub(",", " "):gsub("%s+", " ")
    local parts = {}
    for part in string.gmatch(s, "[%d%.%-]+") do
        table.insert(parts, tonumber(part))
    end
    if #parts < 3 then return nil end
    return Vector3.new(parts[1], parts[2], parts[3])
end

local function getLocalCharacterParts()
    local character = Players.LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    return character, rootPart, humanoid
end

local function notify(title, content, icon)
    mountNotify({ Title = title, Content = content or "", Icon = icon or "check" })
end

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
        Ext = true,
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
        Ext = true,
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
        Ext = true,
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
        Ext = true,
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
        Ext = true,
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
        Ext = true,
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
        local character, _, humanoid = getLocalCharacterParts()
        if not character then
            return nil, "Character not loaded"
        end
        if not humanoid then
            return nil, "Humanoid not found"
        end
        return humanoid.WalkSpeed
    end

    local currentWalkSpeed = getCurrentCharacterWalkSpeed()
    local walkSpeedValue = tostring(currentWalkSpeed or defaultWalkSpeed)

    local WalkSpeedInput = LocalPlayerTab:CreateInput({
        Ext = true,
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
                notify("Walk Speed", errMessage, "x")
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
            notify("Walk Speed", "Current speed: " .. speedText)
        end
        return true
    end
    LocalPlayerTab:CreateButton({
        Name = "Get Current Walk Speed",
        Ext = true,
        Callback = function()
            syncWalkSpeedInputFromCharacter(true)
        end
    })

    -- Keep the input defaulted to current character speed when available.
    syncWalkSpeedInputFromCharacter(false)
    LocalPlayerTab:CreateButton({
        Name = "Apply",
        Ext = true,
        Callback = function()
            local character, _, humanoid = getLocalCharacterParts()
            if not character then
                notify("Walk Speed", "Character not loaded", "x")
                return
            end
            if not humanoid then
                notify("Walk Speed", "Humanoid not found", "x")
                return
            end
            local speed = tonumber(walkSpeedValue) or defaultWalkSpeed
            humanoid.WalkSpeed = math.max(0, speed)
            notify("Walk Speed", "Set to " .. tostring(humanoid.WalkSpeed))
        end
    })
    LocalPlayerTab:CreateButton({
        Name = "Reset",
        Ext = true,
        Callback = function()
            local character, _, humanoid = getLocalCharacterParts()
            if not character then
                notify("Walk Speed", "Character not loaded", "x")
                return
            end
            if not humanoid then
                notify("Walk Speed", "Humanoid not found", "x")
                return
            end
            humanoid.WalkSpeed = defaultWalkSpeed
            walkSpeedValue = tostring(defaultWalkSpeed)
            notify("Walk Speed", "Reset to " .. tostring(defaultWalkSpeed))
        end
    })
    LocalPlayerTab:CreateSection("Jump Height")
    local defaultJumpHeight = 7.2

    local function getCurrentCharacterJumpHeight()
        local character, _, humanoid = getLocalCharacterParts()
        if not character then
            return nil, "Character not loaded"
        end
        if not humanoid then
            return nil, "Humanoid not found"
        end
        return humanoid.JumpHeight
    end

    local currentJumpHeight = getCurrentCharacterJumpHeight()
    local jumpHeightValue = tostring(currentJumpHeight or defaultJumpHeight)

    local JumpHeightInput = LocalPlayerTab:CreateInput({
        Ext = true,
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
                notify("Jump Height", errMessage, "x")
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
            notify("Jump Height", "Current jump height: " .. jumpHeightText)
        end
        return true
    end
    LocalPlayerTab:CreateButton({
        Name = "Get Current Jump Height",
        Ext = true,
        Callback = function()
            syncJumpHeightInputFromCharacter(true)
        end
    })

    -- Keep the input defaulted to current character jump height when available.
    syncJumpHeightInputFromCharacter(false)
    LocalPlayerTab:CreateButton({
        Name = "Apply",
        Ext = true,
        Callback = function()
            local character, _, humanoid = getLocalCharacterParts()
            if not character then
                notify("Jump Height", "Character not loaded", "x")
                return
            end
            if not humanoid then
                notify("Jump Height", "Humanoid not found", "x")
                return
            end
            local jumpHeight = tonumber(jumpHeightValue) or defaultJumpHeight
            humanoid.JumpHeight = math.max(0, jumpHeight)
            notify("Jump Height", "Set to " .. tostring(humanoid.JumpHeight))
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
        if not character then
            return nil
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            return root
        end
        return nil
    end

    local function espGetState(player: Player)
        local state = espPlayerState[player]
        if not state then
            state = {}
            espPlayerState[player] = state
        end
        return state
    end

    local function espClearVisualsForPlayer(player: Player)
        local state = espPlayerState[player]
        if not state then
            return
        end
        if state.highlight then state.highlight:Destroy() state.highlight = nil end
        if state.nameGui then state.nameGui:Destroy() state.nameGui = nil end
        if state.lineBeam then state.lineBeam:Destroy() state.lineBeam = nil end
        if state.lineFrom then state.lineFrom:Destroy() state.lineFrom = nil end
        if state.lineTo then state.lineTo:Destroy() state.lineTo = nil end
    end

    local function espApplyForPlayer(player: Player)
        if player == Players.LocalPlayer then
            return
        end
        local character = player.Character
        local root = espGetPlayerRoot(player)
        if not character or not root then
            espClearVisualsForPlayer(player)
            return
        end
        local state = espGetState(player)
        local localRoot = espGetPlayerRoot(Players.LocalPlayer)
        local distToLocal: number? = nil
        if localRoot then
            distToLocal = (localRoot.Position - root.Position).Magnitude
        end
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
        for _, p in ipairs(Players:GetPlayers()) do
            espApplyForPlayer(p)
        end
    end

    local function espAnyEnabled(): boolean
        return espNamesEnabled or espDistanceEnabled or espCharacterEnabled or espLinesEnabled
    end

    LocalPlayerTab:CreateInput({
        Ext = true,
        Name = "ESP Max Distance",
        PlaceholderText = "0 = unlimited, e.g. 10000",
        CurrentValue = tostring(espMaxDistance),
        Callback = function(value)
            local n = tonumber(value)
            if not n then return end
            espMaxDistance = math.max(0, n)
            if espAnyEnabled() then
                espApplyForAllPlayers()
            end
        end
    })
    local function espOnRenderStep()
        if not espAnyEnabled() then
            return
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Players.LocalPlayer then
                espApplyForPlayer(p)
            end
        end
    end

    local function espSetRuntimeEnabled(enabled: boolean)
        if enabled then
            if not espPlayerAddedConn then
                espPlayerAddedConn = Players.PlayerAdded:Connect(function(player)
                    player.CharacterAdded:Connect(function()
                        task.wait(0.15)
                        espApplyForPlayer(player)
                    end)
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
        for player in pairs(espPlayerState) do
            espClearVisualsForPlayer(player)
            espPlayerState[player] = nil
        end
    end

    LocalPlayerTab:CreateToggle({
        Ext = true,
        Name = "ESP Player Names",
        CurrentValue = false,
        Callback = function(enabled)
            espNamesEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })

    LocalPlayerTab:CreateToggle({
        Ext = true,
        Name = "ESP Player Distance",
        CurrentValue = false,
        Callback = function(enabled)
            espDistanceEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })

    LocalPlayerTab:CreateToggle({
        Ext = true,
        Name = "ESP Player Character",
        CurrentValue = false,
        Callback = function(enabled)
            espCharacterEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })

    LocalPlayerTab:CreateToggle({
        Ext = true,
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

    local INFO_PLAYER_NONE = "(None)"
    local PLAYERS_INFO_PAR_TITLE = "Details"

    local function playersInfoDropdownOptions()
        local opts = { INFO_PLAYER_NONE }
        for _, n in ipairs(infoPlayerDisplayNames) do
            table.insert(opts, n)
        end
        return opts
    end

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
            notify("Players Info", "Player list refreshed (" .. #infoPlayerList .. ")")
        end
    end

    PlayersInfoDropdown = LocalPlayerTab:CreateDropdown({
        Ext = true,
        Name = "Player",
        Search = true,
        Options = playersInfoDropdownOptions(),
        CurrentOption = { INFO_PLAYER_NONE },
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
                notify("Players Info", "Select a player first", "x")
                return
            end
            updatePlayersInfoParagraph()
            notify("Players Info", "Details updated")
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
                    notify("Rejoin", "Failed: " .. tostring(err), "close")
                end
            else
                notify("Rejoin", "Cannot rejoin (missing PlaceId or JobId)", "close")
            end
        end,
    })

    LocalPlayerTab:CreateButton({
        Name = "Copy game ID",
        Ext = true,
        Callback = function()
            local paste = setclipboard or toclipboard
            if not paste then
                notify("Server", "Clipboard not supported in this environment", "x")
                return
            end
            local id = tostring(game.PlaceId)
            paste(id)
            notify("Server", "Copied PlaceId " .. id, "check")
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
            notify("Animation", "R6 character parts not ready", "x")
            return
        end
        local rightShoulder = torso:FindFirstChild("Right Shoulder")
        local neck = torso:FindFirstChild("Neck")
        if not (rightShoulder and rightShoulder:IsA("Motor6D") and neck and neck:IsA("Motor6D")) then
            animationRunning = false
            notify("Animation", "R6 joints not found", "x")
            return
        end
        local _, hairHandle = findHairAccessory(character)
        if not hairHandle then
            animationRunning = false
            notify("Animation", "No hair accessory found", "x")
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
        Ext = true,
        Name = "Animation list",
        Options = animationOptions,
        CurrentOption = { selectedAnimationName },
        Search = false,
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
            notify("Animation", "Unknown animation selected", "x")
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
            notify("Console", cleared and "Console cleared" or "Clear not available (try clearconsole)", cleared and "check" or "x")
        end
    })
end

-- */  Automation Tab  /* --
do
    local AutomationTab = Window:CreateTab("Automation", 4483362458)

    AutomationTab:CreateSection("Auto Camp")
    -- mode per position: "tween" | "teleport" | "walk"
    local campList = {
        {
            id = "Camp1",
            name = "Camp 1",
            defaultDuration = 110, -- 110 = 1 minute 50 seconds
            waterRefillObject = "WaterRefill_Camp1",
            positions = {
                { position = "-4007.86, 55.13, -575.04", mode = "tween", isDelay = true },
                { position = "-3747.10, 215.14, -6.94", mode = "tween", isDelay = true },
                { position = "-3718.86, 240.00, 235.13", mode = "tween", isDelay = true },
            },
        },
        {
            id = "Camp2",
            name = "Camp 2",
            defaultDuration = 180, -- 180 = 3 minutes
            waterRefillObject = "WaterRefill_Camp2",
            positions = {
                { position = "-3041.40, 312.49, 2.24", mode = "tween", isDelay = true },
                { position = "-2740.04, 268.76, -341.26", mode = "tween", isDelay = true },
                { position = "-2591.64, 244.66, -329.08", mode = "tween", isDelay = true },
                { position = "-2472.79, 193.05, -368.09", mode = "walk", isDelay = true },
                { position = "-2361.14, 167.89, -283.53", mode = "walk", isDelay = true },
                { position = "-2319.45, 120.66, -157.36", mode = "walk", isDelay = true },
                { position = "-2278.87, 101.00, -71.63", mode = "walk", isDelay = true },
                { position = "-1394.26, 111.32, -77.06", mode = "tween", isDelay = true },
                { position = "-578.56, 86.65, -167.99", mode = "tween", isDelay = true },
                { position = "882.79, 77.73, -266.99", mode = "tween", isDelay = true },
                { position = "1534.47, 75.19, -170.83", mode = "tween", isDelay = true },
                { position = "1685.07, 105.46, -112.99", mode = "walk", isDelay = true },
                { position = "1789.92, 110.44, -137.28", mode = "walk", isDelay = true },
            },
        },
        {
            id = "Camp3",
            name = "Camp 3",
            defaultDuration = 250, -- 250 = 4 minutes 10 seconds
            waterRefillObject = "WaterRefill_Camp3",
            positions = {
                { position = "3136.70, 850.61, -201.02", mode = "tween", isDelay = true, walkWithJump = false },
                { position = "3231.51, 992.40, 5.27", mode = "tween", isDelay = true, walkWithJump = false },
                { position = "3349.81, 1025.13, 279.19", mode = "teleport", isDelay = true, walkWithJump = false },
                { position = "3338.75, 1030.70, 337.18", mode = "tween", isDelay = true, walkWithJump = false },
                { position = "3365.01, 1036.87, 395.82", mode = "walk", isDelay = true, walkWithJump = false },
                { position = "3389.80, 1132.63, 359.09", mode = "tween", isDelay = true, walkWithJump = false },
                { position = "3631.94, 1366.45, 192.92", mode = "tween", isDelay = true, walkWithJump = false },
                { position = "3732.79, 1508.77, -183.32", mode = "tween", isDelay = true, walkWithJump = false }, -- mount vinson
                { position = "3829.39, 1419.69, -339.77", mode = "walk", isDelay = true, walkWithJump = false },
                { position = "3908.43, 1361.83, -404.79", mode = "walk", isDelay = true, walkWithJump = false },
                { position = "4069.67, 1203.41, -376.51", mode = "walk", isDelay = true, walkWithJump = false },
                { position = "4079.11, 1197.26, -372.15", mode = "walk", isDelay = true, walkWithJump = false },
                { position = "4185.05, 1169.44, -330.00", mode = "tween", isDelay = true, walkWithJump = false },
                { position = "4328.11, 1164.36, -211.04", mode = "walk", isDelay = true, walkWithJump = false },
                { position = "4463.34, 1127.75, -98.33", mode = "walk", isDelay = true, walkWithJump = false },
                { position = "4485.26, 1114.58, -81.75", mode = "walk", isDelay = true, walkWithJump = false },
                { position = "4529.68, 1107.42, -63.48", mode = "tween", isDelay = true, walkWithJump = false },
                { position = "4570.83, 1097.78, -6.35", mode = "tween", isDelay = true, walkWithJump = false },
                { position = "4633.24, 1101.93, 130.08", mode = "tween", isDelay = true, walkWithJump = false },
                { position = "4661.15, 1004.77, 218.85", mode = "walk", isDelay = false, walkWithJump = false },
                { position = "4669.85, 968.70, 246.51", mode = "walk", isDelay = false, walkWithJump = false },
                { position = "4710.12, 890.76, 270.32", mode = "walk", isDelay = false, walkWithJump = false },
                { position = "4703.68, 837.62, 334.12", mode = "walk", isDelay = false, walkWithJump = false },
                { position = "5021.11, 770.58, 295.28", mode = "tween", isDelay = true, walkWithJump = false },
                { position = "5123.25, 739.04, 249.49", mode = "teleport", isDelay = true, walkWithJump = false },
                { position = "5384.25, 753.53, 9.69", mode = "tween", isDelay = true, walkWithJump = false },
                { position = "5425.06, 435.53, -3.71", mode = "teleport", isDelay = false, walkWithJump = false },
                { position = "5500.40, 342.59, -57.53", mode = "walk", isDelay = true, walkWithJump = false },
                { position = "5636.13, 341.10, -51.81", mode = "walk", isDelay = true, walkWithJump = false },
                { position = "5767.25, 321.00, -46.29", mode = "walk", isDelay = true, walkWithJump = false },
                { position = "5864.60, 321.00, -42.19", mode = "walk", isDelay = true, walkWithJump = false },
                { position = "5892.31, 320.00, -19.92", mode = "walk", isDelay = true, walkWithJump = false },
            },
        },
        {
            id = "Camp4",
            name = "Camp 4",
            defaultDuration = 160, -- 160 = 2 minutes 40 seconds
            waterRefillObject = "WaterRefill_Camp4",
            positions = {
                { position = "6424.29, 377.47, 223.09", mode = "tween", isDelay = true },
                { position = "6480.56, 358.37, 261.93", mode = "tween", isDelay = true },
                { position = "6567.11, 332.93, 284.24", mode = "tween", isDelay = true },
                { position = "6643.09, 352.60, 296.53", mode = "tween", isDelay = true },
                { position = "6735.76, 346.51, 337.65", mode = "tween", isDelay = true },
                { position = "6857.57, 354.17, 350.07", mode = "tween", isDelay = true },
                { position = "6882.65, 333.54, 335.85", mode = "tween", isDelay = true },
                { position = "7205.48, 322.91, 330.44", mode = "teleport", isDelay = true },
                { position = "7598.63, 334.01, 190.40", mode = "teleport", isDelay = true },
                { position = "8202.02, 365.93, 802.10", mode = "teleport", isDelay = true },
                { position = "8210.81, 420.96, 997.76", mode = "tween", isDelay = true },
                { position = "8418.93, 495.82, 1016.79", mode = "tween", isDelay = true },
                { position = "8991.70, 600.60, 103.15", mode = "tween", isDelay = true },
            },
        },
        {
            id = "SouthPole",
            name = "South Pole",
            defaultDuration = 90, -- 90 = 1 minute 30 seconds
            waterRefillObject = nil,
            positions = {
                { position = "9378.94, 591.41, 29.68", mode = "tween", isDelay = true },
                { position = "9488.41, 595.76, 92.29", mode = "tween", isDelay = true },
                { position = "9568.12, 596.17, 116.95", mode = "tween", isDelay = true },
                { position = "9627.23, 597.33, 70.38", mode = "tween", isDelay = true },
                { position = "9674.66, 591.93, 17.96", mode = "tween", isDelay = true },
                { position = "9867.68, 592.70, 41.00", mode = "tween", isDelay = true },
                { position = "9917.79, 598.46, -27.52", mode = "tween", isDelay = true },
                { position = "10048.08, 583.07, -20.66", mode = "tween", isDelay = true },
                { position = "10066.99, 563.36, -16.42", mode = "teleport", isDelay = false },
                { position = "10097.70, 549.33, -15.57", mode = "teleport", isDelay = false },
                { position = "10989.81, 569.12, 106.85", mode = "tween", isDelay = true },
            },
        },
    }

    local campNames = {}
    for _, camp in ipairs(campList) do
        table.insert(campNames, camp.name)
    end

    local selectedCampName = (#campNames > 0) and campNames[1] or nil
    local function getDefaultDurationForCamp(campName)
        for _, camp in ipairs(campList) do
            if camp.name == campName then
                return tostring(camp.defaultDuration or 5)
            end
        end
        return "5"
    end
    local tweenDurationSeconds = getDefaultDurationForCamp(selectedCampName or campNames[1])

    local activeSummitTween = nil
    local function runCampRoute(camp, rootPart, totalDurationSeconds, cancelCheckFn, tweenRef)
        local positionsList = camp.positions
        if not positionsList or #positionsList == 0 then return end
        local waypoints = {}
        local tweenCount = 0
        for _, entry in ipairs(positionsList) do
            local posStr = type(entry) == "string" and entry or entry.position
            -- mode: "tween" | "teleport" | "walk" (single field)
            local mode = (type(entry) == "table" and (entry.mode == "teleport" or entry.mode == "walk")) and entry.mode or "tween"
            local isDelay = true
            if type(entry) == "table" and entry.isDelay == false then isDelay = false end
            local v = parsePositionString(posStr)
            if v then
                local walkWithJump = type(entry) == "table" and entry.walkWithJump == true
                table.insert(waypoints, { pos = v, mode = mode, isDelay = isDelay, walkWithJump = walkWithJump })
                if mode == "tween" then tweenCount = tweenCount + 1 end
            end
        end
        if #waypoints == 0 then return end
        local totalDuration = tonumber(totalDurationSeconds) or 5
        if totalDuration < 0.1 then totalDuration = 0.1 end
        local durationPerTween = (tweenCount > 0) and (totalDuration / tweenCount) or totalDuration
        if durationPerTween < 0.05 then durationPerTween = 0.05 end
        for i = 1, #waypoints do
            if type(cancelCheckFn) == "function" and cancelCheckFn() then return end
            local wp = waypoints[i]
            local targetPos = wp.pos
            local tweenDuration = wp.isDelay and durationPerTween or 1
            local delayAfter = wp.isDelay and durationPerTween or 1
            if wp.mode == "tween" then
                local tweenInfo = TweenInfo.new(tweenDuration)
                local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = CFrame.new(targetPos) })
                if cancelCheckFn then if tweenRef then tweenRef.tween = tween else activeSummitTween = tween end end
                tween:Play()
                tween.Completed:Wait()
                if cancelCheckFn then if tweenRef then tweenRef.tween = nil else activeSummitTween = nil end end
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
        if type(cancelCheckFn) == "function" and cancelCheckFn() then return end
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
                if type(cancelCheckFn) == "function" and cancelCheckFn() then return end
                local Event = ReplicatedStorage:FindFirstChild("Events") and ReplicatedStorage.Events:FindFirstChild("EnergyHydration")
                if Event and camp.id then
                    Event:FireServer("FillBottle", camp.id, "Water")
                end
            end
        end
    end

    local DurationInput = AutomationTab:CreateInput({
        Ext = true,
        Name = "Tween Duration (seconds)",
        PlaceholderText = "e.g. 5",
        CurrentValue = tweenDurationSeconds,
        Callback = function(value)
            tweenDurationSeconds = value
        end
    })

    AutomationTab:CreateDropdown({
        Ext = true,
        Name = "Camp",
        Options = campNames,
        CurrentOption = { selectedCampName },
        Callback = function(opts)
            local value = type(opts) == "table" and opts[1] or opts
            selectedCampName = value
            local defaultDur = getDefaultDurationForCamp(value)
            tweenDurationSeconds = defaultDur
            if DurationInput then
                if DurationInput.Set then DurationInput:Set(defaultDur) end
                if DurationInput.SetValue then DurationInput:SetValue(defaultDur) end
            end
        end,
    })
    local autoCampTweenRef = { tween = nil }
    local autoCampCancelRequested = false

    AutomationTab:CreateButton({
        Name = "Auto Teleport",
        Ext = true,
        Callback = function()
            local _, rootPart = getLocalCharacterParts()
            if not rootPart then
                notify("Auto Camp", "Character not loaded", "x")
                return
            end
            if not selectedCampName then
                notify("Auto Camp", "Select a camp first", "x")
                return
            end
            local selectedCamp = nil
            for _, camp in ipairs(campList) do
                if camp.name == selectedCampName then
                    selectedCamp = camp
                    break
                end
            end
            if not selectedCamp then
                notify("Auto Camp", "Camp not found", "x")
                return
            end
            autoCampCancelRequested = false
            notify("Auto Camp", "Moving to " .. selectedCampName .. "...")
            task.spawn(function()
                runCampRoute(selectedCamp, rootPart, tonumber(tweenDurationSeconds) or 5, function() return autoCampCancelRequested end, autoCampTweenRef)
            end)
        end
    })
    AutomationTab:CreateButton({
        Name = "Stop Auto Camp",
        Ext = true,
        Callback = function()
            autoCampCancelRequested = true
            if autoCampTweenRef.tween then
                autoCampTweenRef.tween:Cancel()
                autoCampTweenRef.tween = nil
            end
            notify("Auto Camp", "Stopped", "x")
        end
    })
    -- */  Auto Summit: checkpoint / camp detection (Expedition Antarctica)  /* --
    -- Place file refs:
    --   PlayerScripts.Modules.Game_Modes.playerGameModesInfo.PreviousSessionSpawnLocation (synced from server;
    --   updated when ReplicatedStorage.Events.ClientModuleCommander fires "Games_Modes_updatePlayerGameModesInfo").
    --   ReplicatedStorage.Events.LivesHealth "Display_Rejoin_Message" (third arg) = rejoin checkpoint string.
    --   player "Expedition Data" may include checkpoint values at runtime.
    -- No leaderstats LastCheckpoint in this place (unlike Yahayuk); we still read it if present.
    local lpAutoSummit = Players.LocalPlayer
    local cachedRejoinCheckpointStr = nil
    pcall(function()
        local ev = ReplicatedStorage:FindFirstChild("Events")
        ev = ev and ev:FindFirstChild("LivesHealth")
        if ev and ev:IsA("RemoteEvent") then
            ev.OnClientEvent:Connect(function(msg, ...)
                if msg == "Display_Rejoin_Message" then
                    local a, b, c = ...
                    if typeof(c) == "string" and c ~= "" then
                        cachedRejoinCheckpointStr = c
                    end
                end
            end)
        end
    end)

    -- Ordered route names from client CCTV_Main / LocationCamerasMod (place rbxlx); maps to Auto Summit progress
    -- (0 = next leg Camp 1 … 5 = expedition complete / South Pole).
    local EXPEDITION_ROUTE_LOCATION_PROGRESS = {
        ["base camp"] = 0,
        ["camp 1"] = 1,
        ["waterfall"] = 1,
        ["broken bridges"] = 1,
        ["mount kirkpatrick"] = 1,
        ["beardmore glacier"] = 1,
        ["ross ice shelf"] = 1,
        ["camp 2"] = 2,
        ["vertical ladder jump"] = 2,
        ["mount vinson"] = 2,
        ["icy ladder"] = 2,
        ["ellsworth mountains"] = 2,
        ["death wall"] = 2,
        ["camp 3"] = 3,
        ["cracking ice"] = 3,
        ["canada glacier"] = 3,
        ["camp 4"] = 4,
        ["shackleton glacier"] = 4,
        ["south pole"] = 5,
    }

    local function readGameModesPreviousSessionSpawn(player)
        if not player then
            return nil, nil
        end
        local ok, info = pcall(function()
            local ps = player:FindFirstChild("PlayerScripts")
            if not ps then
                return nil
            end
            local mods = ps:FindFirstChild("Modules")
            if not mods then
                return nil
            end
            local gmScript = mods:FindFirstChild("Game_Modes")
            if not gmScript then
                return nil
            end
            local gm = require(gmScript)
            return gm and gm.playerGameModesInfo
        end)
        if not ok or type(info) ~= "table" then
            return nil, nil
        end
        local loc = info.PreviousSessionSpawnLocation
        local mode = info.PreviousSessionMode
        if typeof(loc) == "string" and loc ~= "" then
            return loc, mode
        end
        return nil, mode
    end

    local function checkpointStringToProgress(s)
        if not s or type(s) ~= "string" then
            return nil
        end
        local low = string.lower((string.gsub(s, "^%s*(.-)%s*$", "%1")))
        local direct = EXPEDITION_ROUTE_LOCATION_PROGRESS[low]
        if direct ~= nil then
            return direct
        end
        local bestK, bestLen = nil, 0
        for k in pairs(EXPEDITION_ROUTE_LOCATION_PROGRESS) do
            if #k > bestLen and low:find(k, 1, true) then
                bestK, bestLen = k, #k
            end
        end
        if bestK then
            return EXPEDITION_ROUTE_LOCATION_PROGRESS[bestK]
        end
        if low:find("south pole", 1, true) or low:find("southpole", 1, true) or low == "sp" then
            return 5
        end
        if low:find("camp 4", 1, true) or low:find("camp4", 1, true) then
            return 4
        end
        if low:find("camp 3", 1, true) or low:find("camp3", 1, true) or low:find("mount vinson", 1, true) then
            return 3
        end
        if low:find("camp 2", 1, true) or low:find("camp2", 1, true) then
            return 2
        end
        if low:find("camp 1", 1, true) or low:find("camp1", 1, true) then
            return 1
        end
        if low:find("basecamp", 1, true) or low:find("base camp", 1, true) then
            return 0
        end
        if low == "base" then
            return 0
        end
        if low:find("practice", 1, true) or low:find("practise", 1, true) then
            return 0
        end
        local d = string.match(s, "(%d+)")
        if d then
            local n = tonumber(d)
            if n and n >= 1 and n <= 4 then
                return n
            end
        end
        return nil
    end

    local function valueToProgress(v)
        if v == nil then
            return nil
        end
        if typeof(v) == "number" then
            local n = math.floor(v)
            if n < 0 then
                n = 0
            end
            if n > #campList then
                n = #campList
            end
            return n
        end
        if typeof(v) == "string" then
            return checkpointStringToProgress(v)
        end
        return nil
    end

    local function readValueBaseProgress(inst)
        if not inst or not inst:IsA("ValueBase") then
            return nil
        end
        local ok, val = pcall(function()
            return inst.Value
        end)
        if not ok then
            return nil
        end
        return valueToProgress(val)
    end

    local function getCheckpointProgressFromPlayer(player)
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            local n = ls:FindFirstChild("LastCheckpoint")
            if n and n:IsA("IntValue") then
                local p = valueToProgress(n.Value)
                if p ~= nil then
                    return p
                end
            end
            local s = ls:FindFirstChild("Checkpoint")
            if s and (s:IsA("StringValue") or s:IsA("IntValue")) then
                local p = readValueBaseProgress(s)
                if p ~= nil then
                    return p
                end
            end
        end
        local a = player:GetAttribute("LastCheckpoint")
        if a ~= nil then
            local p = valueToProgress(a)
            if p ~= nil then
                return p
            end
        end
        local gmLoc = select(1, readGameModesPreviousSessionSpawn(player))
        if gmLoc then
            local p = checkpointStringToProgress(gmLoc)
            if p ~= nil then
                return p
            end
        end
        local ed = player:FindFirstChild("Expedition Data")
        if ed then
            for _, name in ipairs({ "LastCheckpoint", "Checkpoint", "CurrentCheckpoint", "SpawnCheckpoint", "RespawnCheckpoint" }) do
                local ch = ed:FindFirstChild(name)
                if ch then
                    local p = readValueBaseProgress(ch)
                    if p ~= nil then
                        return p
                    end
                end
            end
        end
        if cachedRejoinCheckpointStr then
            local p = checkpointStringToProgress(cachedRejoinCheckpointStr)
            if p ~= nil then
                return p
            end
        end
        return 0
    end

    local function getCheckpointLabelString(player)
        local gmLoc, gmMode = readGameModesPreviousSessionSpawn(player)
        if gmLoc then
            if typeof(gmMode) == "string" and gmMode ~= "" then
                return gmLoc .. " (" .. gmMode .. ")"
            end
            return gmLoc
        end
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            local sv = ls:FindFirstChild("Checkpoint")
            if sv and sv:IsA("StringValue") and sv.Value ~= "" then
                return sv.Value
            end
            local iv = ls:FindFirstChild("LastCheckpoint")
            if iv and iv:IsA("IntValue") then
                return tostring(iv.Value)
            end
        end
        local attr = player:GetAttribute("LastCheckpoint")
        if attr ~= nil and tostring(attr) ~= "" then
            return tostring(attr)
        end
        local ed = player:FindFirstChild("Expedition Data")
        if ed then
            for _, name in ipairs({ "Checkpoint", "LastCheckpoint", "CurrentCheckpoint" }) do
                local ch = ed:FindFirstChild(name)
                if ch and ch:IsA("StringValue") and ch.Value ~= "" then
                    return ch.Value
                end
            end
        end
        if cachedRejoinCheckpointStr and cachedRejoinCheckpointStr ~= "" then
            return cachedRejoinCheckpointStr
        end
        return "Start / Basecamp"
    end

    local function routeLabelForProgress(idx)
        local n = #campList
        if idx <= 0 then
            return "Start → " .. (campList[1] and campList[1].name or "Camp 1")
        end
        if idx >= n then
            return campList[n] and campList[n].name or "South Pole"
        end
        return campList[idx + 1] and campList[idx + 1].name or ("Leg " .. tostring(idx + 1))
    end

    -- progress 0 = next leg is campList[1]; progress >= #campList = nothing left to run
    local function getFirstCampListIndexFromProgress(progress)
        local routeN = #campList
        local p = math.floor(tonumber(progress) or 0)
        if p < 0 then
            p = 0
        end
        if p >= routeN then
            return nil, p
        end
        return p + 1, p
    end

    local AutoSummitCpParagraph
    local function updateAutoSummitCpParagraph()
        if not AutoSummitCpParagraph then
            return
        end
        local label = getCheckpointLabelString(lpAutoSummit)
        local idx = getCheckpointProgressFromPlayer(lpAutoSummit)
        local nextName = routeLabelForProgress(idx)
        local desc = string.format("CHECKPOINT: %s\nProgress #%d · Next leg: %s", string.upper(label), idx, nextName)
        if AutoSummitCpParagraph and AutoSummitCpParagraph.Set then
            AutoSummitCpParagraph:Set({
                Title = "Current camp / checkpoint",
                Content = desc,
            })
        end
    end

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

    local function attachExpeditionDataForCp(ed)
        local function onCheckpointValueChanged()
            updateAutoSummitCpParagraph()
        end
        for _, name in ipairs({ "LastCheckpoint", "Checkpoint", "CurrentCheckpoint", "SpawnCheckpoint", "RespawnCheckpoint" }) do
            local ch = ed:FindFirstChild(name)
            if ch and ch:IsA("ValueBase") then
                ch:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
            end
        end
        ed.ChildAdded:Connect(function(ch)
            if ch:IsA("ValueBase") then
                for _, name in ipairs({ "LastCheckpoint", "Checkpoint", "CurrentCheckpoint", "SpawnCheckpoint", "RespawnCheckpoint" }) do
                    if ch.Name == name then
                        ch:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
                        onCheckpointValueChanged()
                        break
                    end
                end
            end
        end)
    end

    lpAutoSummit:GetAttributeChangedSignal("LastCheckpoint"):Connect(updateAutoSummitCpParagraph)
    local lsCp = lpAutoSummit:FindFirstChild("leaderstats")
    if lsCp then
        attachLeaderstatsForCp(lsCp)
    end
    lpAutoSummit.ChildAdded:Connect(function(ch)
        if ch.Name == "leaderstats" then
            attachLeaderstatsForCp(ch)
            updateAutoSummitCpParagraph()
        elseif ch.Name == "Expedition Data" then
            attachExpeditionDataForCp(ch)
            updateAutoSummitCpParagraph()
        end
    end)
    local edCp = lpAutoSummit:FindFirstChild("Expedition Data")
    if edCp then
        attachExpeditionDataForCp(edCp)
    end

    pcall(function()
        local evFolder = ReplicatedStorage:FindFirstChild("Events")
        local cmd = evFolder and evFolder:FindFirstChild("ClientModuleCommander")
        if cmd and (cmd:IsA("RemoteEvent") or cmd:IsA("UnreliableRemoteEvent")) then
            cmd.OnClientEvent:Connect(function(kind, _)
                if kind == "Games_Modes_updatePlayerGameModesInfo" then
                    task.defer(updateAutoSummitCpParagraph)
                end
            end)
        end
    end)

    -- */  Auto Summit Section  /* --
    local autoSummitEnabled = false
    local summitQty = ""
    local SUMMIT_DELAY_SECONDS = 15
    local autoSummitRestartFromDeath = false  -- set by death listener; loop re-reads checkpoint after respawn
    AutomationTab:CreateSection("Auto Summit")
    AutoSummitCpParagraph = AutomationTab:CreateParagraph({
        Title = "Current camp / checkpoint",
        Content = "CHECKPOINT: —\nProgress #0 · Next leg: Camp 1",
    })
    task.defer(updateAutoSummitCpParagraph)

    local SummitQtyInput = AutomationTab:CreateInput({
        Ext = true,
        Name = "Qty of summit",
        PlaceholderText = "Empty = unlimited",
        CurrentValue = "",
        Callback = function(value)
            summitQty = value
        end
    })

    -- Character death: real-time Heartbeat poll while Auto Summit is on (game may fire Died only once or reuse character)
    local lp = Players.LocalPlayer
    local autoSummitDeathCheckConn = nil
    local function onDeath()
        autoSummitRestartFromDeath = true
        if activeSummitTween then activeSummitTween:Cancel() activeSummitTween = nil end
    end
    local function connectCharacterDied(character)
        if not character then return end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then return end
        humanoid.Died:Connect(onDeath)
        humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then onDeath() end
        end)
    end
    if lp.Character then connectCharacterDied(lp.Character) end
    lp.CharacterAdded:Connect(connectCharacterDied)

    AutomationTab:CreateToggle({
        Ext = true,
        Name = "Auto Summit",
        CurrentValue = false,
        Callback = function(enabled)
            autoSummitEnabled = enabled
            if not enabled then
                if activeSummitTween then
                    activeSummitTween:Cancel()
                    activeSummitTween = nil
                end
                if autoSummitDeathCheckConn then
                    autoSummitDeathCheckConn:Disconnect()
                    autoSummitDeathCheckConn = nil
                end
                return
            end
            autoSummitRestartFromDeath = false
            -- Real-time death check every frame (in case game only fires Died once or reuses character)
            if autoSummitDeathCheckConn then autoSummitDeathCheckConn:Disconnect() end
            autoSummitDeathCheckConn = RunService.Heartbeat:Connect(function()
                if not autoSummitEnabled then return end
                local char = lp.Character
                if not char then return end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then onDeath() end
            end)
            local function getRootPart(timeoutSec)
                local pl = Players.LocalPlayer
                local char = pl.Character
                if not char then
                    char = pl.CharacterAdded:Wait()
                end
                return char:WaitForChild("HumanoidRootPart", timeoutSec or 15)
            end
            local rootPart = getRootPart()
            if not rootPart then
                notify("Auto Summit", "Character not loaded", "x")
                return
            end
            task.spawn(function()
                local qtyNum = tonumber(summitQty and summitQty:gsub("%s+", "") or "")  -- nil/empty = unlimited
                local runCount = 0
                local remaining = qtyNum  -- nil = unlimited (never decreased), else runs left
                local skipNextCpResumeNotify = false
                repeat
                    if not autoSummitEnabled then break end
                    rootPart = getRootPart()
                    if not rootPart then
                        local pl = Players.LocalPlayer
                        local char = pl.Character
                        if char then
                            char:WaitForChild("HumanoidRootPart", 10)
                        else
                            char = pl.CharacterAdded:Wait()
                            char:WaitForChild("HumanoidRootPart", 10)
                        end
                        task.wait(1)
                        rootPart = getRootPart()
                        if not rootPart then
                            notify("Auto Summit", "Could not get character after respawn", "x")
                            break
                        end
                    end
                    local routeCompleted = true
                    local cpNow = getCheckpointProgressFromPlayer(lp)
                    local firstLegIndex, cpClamped = getFirstCampListIndexFromProgress(cpNow)
                    local skippedLegs = firstLegIndex == nil
                    if skippedLegs then
                        skipNextCpResumeNotify = false
                    elseif not skipNextCpResumeNotify then
                        notify(
                            "Auto Summit",
                            ("Progress #%d (%s) — continuing from %s…"):format(
                                cpClamped,
                                routeLabelForProgress(cpClamped),
                                campList[firstLegIndex].name
                            )
                        )
                    else
                        skipNextCpResumeNotify = false
                    end
                    if not skippedLegs then
                        for ci = firstLegIndex, #campList do
                            if not autoSummitEnabled or autoSummitRestartFromDeath then
                                routeCompleted = false
                                break
                            end
                            rootPart = getRootPart()
                            if not rootPart then
                                routeCompleted = false
                                break
                            end
                            local camp = campList[ci]
                            notify("Auto Summit", "Moving to " .. camp.name .. "...")
                            runCampRoute(camp, rootPart, camp.defaultDuration or 5, function()
                                return not autoSummitEnabled or autoSummitRestartFromDeath
                            end)
                            if autoSummitRestartFromDeath then
                                routeCompleted = false
                                break
                            end
                        end
                    end
                    if autoSummitRestartFromDeath then
                        notify("Auto Summit", "Character died — waiting for respawn…")
                        local pl = Players.LocalPlayer
                        local char = pl.Character
                        if not char then
                            char = pl.CharacterAdded:Wait()
                        else
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health <= 0 then
                                char = pl.CharacterAdded:Wait()
                            end
                        end
                        if char then
                            char:WaitForChild("HumanoidRootPart", 15)
                            task.wait(0.5)
                        end
                        for _ = 1, 15 do
                            if pl:FindFirstChild("leaderstats") or pl:FindFirstChild("Expedition Data") then
                                break
                            end
                            task.wait(0.1)
                        end
                        task.wait(0.35)
                        local cpRespawn = getCheckpointProgressFromPlayer(pl)
                        local firstRespawn, cpRespawnClamped = getFirstCampListIndexFromProgress(cpRespawn)
                        task.defer(updateAutoSummitCpParagraph)
                        autoSummitRestartFromDeath = false
                        skipNextCpResumeNotify = true
                        if firstRespawn == nil then
                            notify(
                                "Auto Summit",
                                ("Respawned — progress #%d (%s). Next: count run / summit step (no route legs)."):format(
                                    cpRespawnClamped,
                                    routeLabelForProgress(cpRespawnClamped)
                                )
                            )
                        else
                            notify(
                                "Auto Summit",
                                ("Respawned — progress #%d (%s); resuming from %s."):format(
                                    cpRespawnClamped,
                                    routeLabelForProgress(cpRespawnClamped),
                                    campList[firstRespawn].name
                                )
                            )
                        end
                    elseif routeCompleted and autoSummitEnabled then
                        if skippedLegs then
                            notify(
                                "Auto Summit",
                                ("Already past route legs (progress #%d) — run %d."):format(cpClamped, runCount + 1)
                            )
                        else
                            notify("Auto Summit", "Reached summit! (Run " .. (runCount + 1) .. ")")
                        end
                        runCount = runCount + 1
                        if remaining then
                            remaining = remaining - 1
                            summitQty = tostring(remaining)
                            task.defer(function()
                                if SummitQtyInput then
                                    if SummitQtyInput.Set then SummitQtyInput:Set(summitQty) end
                                    if SummitQtyInput.SetValue then SummitQtyInput:SetValue(summitQty) end
                                end
                            end)
                        end
                        if autoSummitEnabled and (not qtyNum or remaining > 0) then
                            task.wait(SUMMIT_DELAY_SECONDS / 3)
                            local Event = ReplicatedStorage.Events.CharacterHandler
                            Event:FireServer("Died")
                            task.wait(SUMMIT_DELAY_SECONDS)
                        end
                    end
                until not autoSummitEnabled or (qtyNum and remaining <= 0)
                if autoSummitDeathCheckConn then
                    autoSummitDeathCheckConn:Disconnect()
                    autoSummitDeathCheckConn = nil
                end
                if autoSummitEnabled and qtyNum and remaining <= 0 then
                    notify("Auto Summit", "All camps completed (" .. runCount .. " run(s))")
                elseif not autoSummitEnabled then
                    notify("Auto Summit", "Stopped", "x")
                end
            end)
        end
    })
    -- */  Auto Drink Section  /* --
    local HYDRATION_MAX = 100
    AutomationTab:CreateSection("Auto Drink")
    local minHydration = 50
    local autoDrinkEnabled = false
    local autoDrinkConnection = nil
    local refillingHydration = false  -- once we start (hydration <= min), keep drinking until >= targetMax

    local function getHydration()
        local lp = Players.LocalPlayer
        local v = lp:GetAttribute("Hydration")
        if v == nil then return nil end
        return tonumber(v) or v
    end

    local function fireDrink()
        local lp = Players.LocalPlayer
        local backpack = lp:FindFirstChild("Backpack")
        local character = lp:FindFirstChild("Character")
        local waterBottle = (backpack and backpack:FindFirstChild("Water Bottle")) or (character and character:FindFirstChild("Water Bottle"))
        if not waterBottle then return false end
        local event = waterBottle:FindFirstChild("RemoteEvent")
        if not event then return false end
        pcall(function() event:FireServer() end)
        return true
    end

    local function stopAutoDrink()
        if autoDrinkConnection then
            autoDrinkConnection:Disconnect()
            autoDrinkConnection = nil
        end
        autoDrinkEnabled = false
    end

    local function startAutoDrink()
        stopAutoDrink()
        autoDrinkEnabled = true
        refillingHydration = false
        local lastDrinkTime = 0
        local DRINK_INTERVAL = 1.0
        autoDrinkConnection = RunService.Heartbeat:Connect(function()
            if not autoDrinkEnabled then return end
            local hydration = getHydration()
            if hydration == nil then return end
            local minVal = tonumber(minHydration) or 50
            local targetMax = HYDRATION_MAX - 10
            if hydration <= minVal then
                refillingHydration = true
            end
            if hydration >= targetMax then
                refillingHydration = false
            end
            if refillingHydration and hydration < targetMax then
                local now = tick()
                if now - lastDrinkTime >= DRINK_INTERVAL then
                    if fireDrink() then
                        lastDrinkTime = now
                    end
                end
            end
        end)
    end

    AutomationTab:CreateInput({
        Ext = true,
        Name = "Minimum Hydration",
        PlaceholderText = "50",
        CurrentValue = "50",
        Callback = function(value)
            minHydration = value
        end
    })

    AutomationTab:CreateToggle({
        Ext = true,
        Name = "Auto Drink",
        CurrentValue = false,
        Callback = function(enabled)
            autoDrinkEnabled = enabled
            if enabled then
                startAutoDrink()
            else
                stopAutoDrink()
            end
        end
    })
end


-- */  Teleport Tab  /* --
do
    local TeleportTab = Window:CreateTab("Teleport", 4483362458)

    TeleportTab:CreateSection("Teleport")
    local teleportInputValue = ""
    local teleportLookInputValue = ""

    local function teleportCFrameFromInputs(posStr, lookStr)
        local pos = parsePositionString(posStr)
        if not pos then
            return nil
        end
        local s = (lookStr or ""):gsub(",", " "):gsub("%s+", " ")
        local parts = {}
        for part in string.gmatch(s, "[%d%.%-]+") do
            table.insert(parts, tonumber(part))
        end
        if #parts < 3 then
            return CFrame.new(pos)
        end
        local dir = Vector3.new(parts[1], parts[2], parts[3])
        if dir.Magnitude < 1e-5 then
            return CFrame.new(pos)
        end
        return CFrame.lookAt(pos, pos + dir.Unit)
    end

    local TeleportInput = TeleportTab:CreateInput({
        Ext = true,
        Name = "Location",
        PlaceholderText = "e.g. 100, 5, 200 or 100 5 200",
        CurrentValue = teleportInputValue,
        Callback = function(value)
            teleportInputValue = value
        end
    })

    local TeleportLookInput = TeleportTab:CreateInput({
        Ext = true,
        Name = "Look direction",
        PlaceholderText = "e.g. 0, 0, -1 or leave empty",
        CurrentValue = teleportLookInputValue,
        Callback = function(value)
            teleportLookInputValue = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Get Current Location",
        Ext = true,
        Callback = function()
            local _, rootPart = getLocalCharacterParts()
            if not rootPart then
                notify("Teleport", "Character not loaded", "x")
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
            notify("Location", "Position: " .. text .. " · Look: " .. lookText)
        end
    })
    TeleportTab:CreateButton({
        Name = "Teleport",
        Ext = true,
        Callback = function()
            local _, rootPart = getLocalCharacterParts()
            if not rootPart then
                notify("Teleport", "Character not loaded", "x")
                return
            end
            local cf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not cf then
                notify("Teleport", "Enter position as X, Y, Z (e.g. 100, 5, 200)", "x")
                return
            end
            rootPart.CFrame = cf
            local p = cf.Position
            notify("Teleport", string.format("Teleported to %.1f, %.1f, %.1f", p.X, p.Y, p.Z))
        end
    })
    local tweenDurationValue = "5"
    TeleportTab:CreateInput({
        Ext = true,
        Name = "Tween Duration",
        PlaceholderText = "e.g. 5",
        CurrentValue = tweenDurationValue,
        Callback = function(value)
            tweenDurationValue = value
        end
    })

    TeleportTab:CreateButton({
        Name = "Tween to Location",
        Ext = true,
        Callback = function()
            local _, rootPart = getLocalCharacterParts()
            if not rootPart then
                notify("Teleport", "Character not loaded", "x")
                return
            end
            local targetCf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not targetCf then
                notify("Teleport", "Enter position as X, Y, Z (e.g. 100, 5, 200)", "x")
                return
            end
            local duration = tonumber(tweenDurationValue) or 5
            if duration < 0.1 then duration = 0.1 end
            local tweenInfo = TweenInfo.new(duration)
            local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = targetCf })
            tween:Play()
            local p = targetCf.Position
            notify("Teleport", string.format("Tweening to %.1f, %.1f, %.1f (%.1fs)", p.X, p.Y, p.Z, duration))
        end
    })
    TeleportTab:CreateButton({
        Name = "Walk to Location",
        Ext = true,
        Callback = function()
            local _, rootPart, humanoid = getLocalCharacterParts()
            if not rootPart or not humanoid then
                notify("Teleport", "Character not loaded", "x")
                return
            end
            local targetPos = parsePositionString(teleportInputValue)
            if not targetPos then
                notify("Teleport", "Enter position as X, Y, Z (e.g. 100, 5, 200)", "x")
                return
            end
            humanoid:MoveTo(targetPos)
            notify("Teleport", string.format("Walking to %.1f, %.1f, %.1f", targetPos.X, targetPos.Y, targetPos.Z))
        end
    })
    -- */  Teleport to Camp  /* --
    local campTeleportList = {
        { name = "Camp 1", position = "-3718.86, 240.00, 235.13" },
        { name = "Camp 2", position = "1789.92, 110.44, -137.28" },
        { name = "Camp 3", position = "5892.31, 320.00, -19.92" },
        { name = "Camp 4", position = "8991.70, 600.60, 103.15" },
        { name = "South Pole", position = "10989.81, 569.12, 106.85" },
    }

    local campTeleportNames = {}
    for _, camp in ipairs(campTeleportList) do
        table.insert(campTeleportNames, camp.name)
    end

    local selectedCampTeleport = (#campTeleportNames > 0) and campTeleportNames[1] or nil

    TeleportTab:CreateSection("Teleport to Camp")
    TeleportTab:CreateDropdown({
        Ext = true,
        Name = "Camp",
        Options = campTeleportNames,
        CurrentOption = { selectedCampTeleport or campTeleportNames[1] },
        Callback = function(opts)
            local value = type(opts) == "table" and opts[1] or opts
            selectedCampTeleport = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Teleport",
        Ext = true,
        Callback = function()
            local _, rootPart = getLocalCharacterParts()
            if not rootPart then
                notify("Teleport to Camp", "Character not loaded", "x")
                return
            end
            if not selectedCampTeleport then
                notify("Teleport to Camp", "Select a camp first", "x")
                return
            end
            local posStr = nil
            for _, camp in ipairs(campTeleportList) do
                if camp.name == selectedCampTeleport then
                    posStr = camp.position
                    break
                end
            end
            if not posStr then
                notify("Teleport to Camp", "Camp not found", "x")
                return
            end
            local targetPos = parsePositionString(posStr)
            if not targetPos then
                notify("Teleport to Camp", "Invalid position", "x")
                return
            end
            rootPart.CFrame = CFrame.new(targetPos)
            notify("Teleport to Camp", "Teleported to " .. selectedCampTeleport)
        end
    })

    -- */  Teleport to Players  /* --
    TeleportTab:CreateSection("Teleport to Players")
    local playerDisplayNames = {}
    local playerList = {}
    local selectedTeleportPlayer = nil
    local PlayerTeleportDropdown

    local TELEPORT_PLAYER_NONE = "(None)"

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
            notify("Teleport", "Player list refreshed (" .. #playerList .. " players)")
        end
    end

    PlayerTeleportDropdown = TeleportTab:CreateDropdown({
        Ext = true,
        Name = "Player",
        Search = true,
        Options = teleportPlayerDropdownOptions(),
        CurrentOption = { TELEPORT_PLAYER_NONE },
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
        end
    })
    TeleportTab:CreateButton({
        Name = "Teleport",
        Ext = true,
        Callback = function()
            if not selectedTeleportPlayer then
                notify("Teleport", "Select a player first", "x")
                return
            end
            local _, rootPart = getLocalCharacterParts()
            if not rootPart then
                notify("Teleport", "Character not loaded", "x")
                return
            end
            local targetChar = selectedTeleportPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then
                notify("Teleport", "Target player has no character", "x")
                return
            end
            rootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0, 3))
            notify("Teleport", "Teleported to " .. (selectedTeleportPlayer.DisplayName or selectedTeleportPlayer.Name))
        end
    })
end

-- */  Objects Tab  /* --
do
    local ObjectsTab = Window:CreateTab("Objects", 4483362458)

    -- Nested tree only under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (recursive); other instances are one line.
    local OBJECTS_TREE_MAX_DEPTH = 14
    local OBJECTS_TREE_MAX_LINES = 600

    local OBJECTS_NONE = "(None)"
    local NESTED_CHILDREN_TITLE = "Children (nested)"

    local function objectDropdownOptions(items: { string }): { string }
        local o = { OBJECTS_NONE }
        for _, x in ipairs(items) do
            table.insert(o, x)
        end
        return o
    end

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
            ReplicatedStorageDropdown:Refresh(objectDropdownOptions(rsDisplayList))
        end
        notify("ReplicatedStorage", "Listed " .. #rsDisplayList .. " objects", "check")
    end

    ReplicatedStorageDropdown = ObjectsTab:CreateDropdown({
        Ext = true,
        Name = "ReplicatedStorage (key = value)",
        Search = true,
        Options = objectDropdownOptions(rsDisplayList),
        CurrentOption = { OBJECTS_NONE },
        Callback = function(opts)
            local selectedDisplay = type(opts) == "table" and opts[1] or opts
            if not selectedDisplay or selectedDisplay == OBJECTS_NONE then
                if ReplicatedStorageChildrenParagraph and ReplicatedStorageChildrenParagraph.Set then
                    ReplicatedStorageChildrenParagraph:Set({
                        Title = NESTED_CHILDREN_TITLE,
                        Content = "Select an object above to list its children",
                    })
                end
                return
            end
            local entry = rsKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local text = buildNestedObjectChildrenListText(entry.instance)
            if ReplicatedStorageChildrenParagraph and ReplicatedStorageChildrenParagraph.Set then
                ReplicatedStorageChildrenParagraph:Set({
                    Title = NESTED_CHILDREN_TITLE,
                    Content = text,
                })
            end
        end,
    })

    ReplicatedStorageChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = NESTED_CHILDREN_TITLE,
        Content = "Nested under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (name sort; max depth " .. OBJECTS_TREE_MAX_DEPTH .. ", max " .. OBJECTS_TREE_MAX_LINES .. " lines)",
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Ext = true,
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
            PlayersServiceDropdown:Refresh(objectDropdownOptions(plrsDisplayList))
        end
        notify("Players", "Listed " .. #plrsDisplayList .. " players", "check")
    end

    PlayersServiceDropdown = ObjectsTab:CreateDropdown({
        Ext = true,
        Name = "Players (key = value)",
        Search = true,
        Options = objectDropdownOptions(plrsDisplayList),
        CurrentOption = { OBJECTS_NONE },
        Callback = function(opts)
            local selectedDisplay = type(opts) == "table" and opts[1] or opts
            if not selectedDisplay or selectedDisplay == OBJECTS_NONE then
                if PlayersServiceChildrenParagraph and PlayersServiceChildrenParagraph.Set then
                    PlayersServiceChildrenParagraph:Set({
                        Title = NESTED_CHILDREN_TITLE,
                        Content = "Select a player above to list their children",
                    })
                end
                return
            end
            local entry = plrsKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local text = buildNestedObjectChildrenListText(entry.instance)
            if PlayersServiceChildrenParagraph and PlayersServiceChildrenParagraph.Set then
                PlayersServiceChildrenParagraph:Set({
                    Title = NESTED_CHILDREN_TITLE,
                    Content = text,
                })
            end
        end,
    })

    PlayersServiceChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = NESTED_CHILDREN_TITLE,
        Content = "Nested under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (name sort; max depth " .. OBJECTS_TREE_MAX_DEPTH .. ", max " .. OBJECTS_TREE_MAX_LINES .. " lines)",
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Ext = true,
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
            LocalPlayerDropdown:Refresh(objectDropdownOptions(lpDisplayList))
        end
        notify("Local Player", "Listed " .. #lpDisplayList .. " objects", "check")
    end

    LocalPlayerDropdown = ObjectsTab:CreateDropdown({
        Ext = true,
        Name = "Local Player (key = value)",
        Search = true,
        Options = objectDropdownOptions(lpDisplayList),
        CurrentOption = { OBJECTS_NONE },
        Callback = function(opts)
            local selectedDisplay = type(opts) == "table" and opts[1] or opts
            if not selectedDisplay or selectedDisplay == OBJECTS_NONE then
                if LocalPlayerChildrenParagraph and LocalPlayerChildrenParagraph.Set then
                    LocalPlayerChildrenParagraph:Set({
                        Title = NESTED_CHILDREN_TITLE,
                        Content = "Select an object above to list its children",
                    })
                end
                return
            end
            local entry = lpKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local text = buildNestedObjectChildrenListText(entry.instance)
            if LocalPlayerChildrenParagraph and LocalPlayerChildrenParagraph.Set then
                LocalPlayerChildrenParagraph:Set({
                    Title = NESTED_CHILDREN_TITLE,
                    Content = text,
                })
            end
        end,
    })

    LocalPlayerChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = NESTED_CHILDREN_TITLE,
        Content = "Nested under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (name sort; max depth " .. OBJECTS_TREE_MAX_DEPTH .. ", max " .. OBJECTS_TREE_MAX_LINES .. " lines)",
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Ext = true,
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
            WorkspaceDropdown:Refresh(objectDropdownOptions(wsDisplayList))
        end
        notify("Workspace", "Listed " .. #wsDisplayList .. " objects", "check")
    end

    WorkspaceDropdown = ObjectsTab:CreateDropdown({
        Ext = true,
        Name = "Workspace (key = value)",
        Search = true,
        Options = objectDropdownOptions(wsDisplayList),
        CurrentOption = { OBJECTS_NONE },
        Callback = function(opts)
            local selectedDisplay = type(opts) == "table" and opts[1] or opts
            if not selectedDisplay or selectedDisplay == OBJECTS_NONE then
                if WorkspaceChildrenParagraph and WorkspaceChildrenParagraph.Set then
                    WorkspaceChildrenParagraph:Set({
                        Title = NESTED_CHILDREN_TITLE,
                        Content = "Select an object above to list its children",
                    })
                end
                return
            end
            local entry = wsKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local text = buildNestedObjectChildrenListText(entry.instance)
            if WorkspaceChildrenParagraph and WorkspaceChildrenParagraph.Set then
                WorkspaceChildrenParagraph:Set({
                    Title = NESTED_CHILDREN_TITLE,
                    Content = text,
                })
            end
        end,
    })

    WorkspaceChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = NESTED_CHILDREN_TITLE,
        Content = "Nested under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (name sort; max depth " .. OBJECTS_TREE_MAX_DEPTH .. ", max " .. OBJECTS_TREE_MAX_LINES .. " lines)",
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Ext = true,
        Callback = function()
            refreshWorkspaceList()
        end
    })

end

