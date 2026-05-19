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
local CoreGui = cloneref(game:GetService("CoreGui"))
local VirtualInputManager = game:GetService("VirtualInputManager")

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

local function getExecutorFireSignal()
    local fire = rawget(_G, "firesignal")
    if type(fire) == "function" then
        return fire
    end
    local syn = rawget(_G, "syn")
    if type(syn) == "table" and type(syn.fire_signal) == "function" then
        return syn.fire_signal
    end
    local getgenv = rawget(_G, "getgenv")
    if type(getgenv) == "function" then
        local g = getgenv()
        if type(g) == "table" then
            fire = rawget(g, "firesignal")
            if type(fire) == "function" then
                return fire
            end
        end
    end
    return nil
end

local function getExecutorGetConnections()
    local getconns = rawget(_G, "getconnections")
    if type(getconns) == "function" then
        return getconns
    end
    local syn = rawget(_G, "syn")
    if type(syn) == "table" and type(syn.getconnections) == "function" then
        return syn.getconnections
    end
    local getgenv = rawget(_G, "getgenv")
    if type(getgenv) == "function" then
        local g = getgenv()
        if type(g) == "table" then
            getconns = rawget(g, "getconnections")
            if type(getconns) == "function" then
                return getconns
            end
        end
    end
    return nil
end

local function activateGuiButton(button: GuiButton): boolean
    if not button or not button:IsA("GuiButton") then
        return false
    end
    local fireSignal = getExecutorFireSignal()
    if fireSignal then
        local ok = pcall(function()
            fireSignal(button.MouseButton1Click)
        end)
        if ok then
            return true
        end
    end
    local getconns = getExecutorGetConnections()
    if getconns then
        local ok = pcall(function()
            for _, conn in ipairs(getconns(button.MouseButton1Click)) do
                if conn.Enabled then
                    conn:Fire()
                end
            end
        end)
        if ok then
            return true
        end
    end
    pcall(function()
        if button.Activate then
            button:Activate()
        end
    end)
    if VirtualInputManager then
        pcall(function()
            local pos = button.AbsolutePosition + (button.AbsoluteSize / 2)
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
            task.wait()
            VirtualInputManager:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
        end)
    end
    return true
end

local PURCHASE_PROMPT_CLOSE_NAMES = { "CloseButton", "closeButton", "Close", "Exit", "Dismiss", "CancelButton" }

local function findPurchasePromptCloseButton(root: Instance): GuiButton?
    for _, name in ipairs(PURCHASE_PROMPT_CLOSE_NAMES) do
        local btn = root:FindFirstChild(name, true)
        if btn and btn:IsA("GuiButton") and btn.Visible then
            return btn
        end
    end
    for _, desc in ipairs(root:GetDescendants()) do
        if desc:IsA("GuiButton") and desc.Visible then
            local n = string.lower(desc.Name)
            if string.find(n, "close", 1, true) or n == "x" then
                return desc
            end
        end
    end
    return nil
end

local function tryClosePurchasePromptInstance(promptRoot: Instance): boolean
    if not (promptRoot:IsA("GuiObject") and promptRoot.Visible) then
        return false
    end
    local closeBtn = findPurchasePromptCloseButton(promptRoot)
    if closeBtn then
        activateGuiButton(closeBtn)
        task.wait(0.12)
        if not promptRoot.Parent or not promptRoot.Visible then
            return true
        end
    end
    pcall(function()
        promptRoot.Visible = false
        promptRoot:Destroy()
    end)
    return true
end

-- Dismiss Roblox CoreGui "Buy Robux and item" / gift purchase overlay (executor).
local function forceCloseRobloxPurchasePrompt(timeoutSeconds: number?): boolean
    local waitSeconds: number = timeoutSeconds or 6
    local robloxPrompt = CoreGui:FindFirstChild("RobloxPromptGui")
    if not robloxPrompt then
        local ok, found = pcall(function()
            return CoreGui:WaitForChild("RobloxPromptGui", waitSeconds)
        end)
        if not ok or not found then
            return false
        end
        robloxPrompt = found
    end
    local overlay = robloxPrompt:FindFirstChild("promptOverlay")
    if not overlay then
        return false
    end
    local deadline = os.clock() + waitSeconds
    while os.clock() < deadline do
        for _, child in ipairs(overlay:GetChildren()) do
            if tryClosePurchasePromptInstance(child) then
                return true
            end
        end
        task.wait(0.1)
    end
    return false
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

    local function parseMaxCropsFromNotification(message)
        if type(message) ~= "string" then return nil end
        local maxCount = message:match("^Maximum (%d+) crops!$")
        return maxCount and tonumber(maxCount) or nil
    end

    local function countLocalPlayerActiveCrops()
        return #refreshAllCropsByLocalPlayer()
    end

    -- Farm layout styles (add new curves to FarmStyleBuilders + FARM_STYLE_OPTIONS).
    local FARM_STYLE_OPTIONS = { "Default", "Random", "Heart", "Circle" }
    local farmHeartCurveScale = 0.3
    local farmCircleRadius = 4
    local farmRandomRadius = 4

    local function heartCurveOffsetXZ(t)
        local sinT = math.sin(t)
        local x = 16 * sinT * sinT * sinT
        local z = 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t)
        return x * farmHeartCurveScale, z * farmHeartCurveScale
    end

    local function seededFarmRandom(center, count)
        local seed = math.floor(center.X * 10000 + center.Z * 10000 + count * 9973) % 2147483646
        if seed < 1 then
            seed = 1
        end
        return Random.new(seed)
    end

    local FarmStyleBuilders = {
        Default = function(center, count)
            local positions = table.create(count)
            for i = 1, count do
                positions[i] = center
            end
            return positions
        end,
        Random = function(center, count)
            local positions = table.create(count)
            if count <= 0 then
                return positions
            end
            if count == 1 then
                positions[1] = center
                return positions
            end
            local rng = seededFarmRandom(center, count)
            for i = 1, count do
                local angle = rng:NextNumber(0, math.pi * 2)
                local dist = math.sqrt(rng:NextNumber()) * farmRandomRadius
                local offsetX = math.cos(angle) * dist
                local offsetZ = math.sin(angle) * dist
                positions[i] = Vector3.new(center.X + offsetX, center.Y, center.Z + offsetZ)
            end
            return positions
        end,
        Heart = function(center, count)
            local positions = table.create(count)
            if count <= 0 then
                return positions
            end
            if count == 1 then
                positions[1] = center
                return positions
            end
            for i = 1, count do
                local t = (i - 1) / count * 2 * math.pi
                local offsetX, offsetZ = heartCurveOffsetXZ(t)
                positions[i] = Vector3.new(center.X + offsetX, center.Y, center.Z + offsetZ)
            end
            return positions
        end,
        Circle = function(center, count)
            local positions = table.create(count)
            if count <= 0 then
                return positions
            end
            if count == 1 then
                positions[1] = center
                return positions
            end
            for i = 1, count do
                local t = (i - 1) / count * 2 * math.pi
                local offsetX = math.cos(t) * farmCircleRadius
                local offsetZ = math.sin(t) * farmCircleRadius
                positions[i] = Vector3.new(center.X + offsetX, center.Y, center.Z + offsetZ)
            end
            return positions
        end,
    }

    local function normalizeFarmStyle(styleName)
        if styleName and FarmStyleBuilders[styleName] then
            return styleName
        end
        return "Default"
    end

    local function buildFarmStylePositions(styleName, center, count)
        local builder = FarmStyleBuilders[normalizeFarmStyle(styleName)]
        return builder(center, count)
    end

    local function getFarmSlotOccupancy(layout, crops)
        local occupied = {}
        for _, entry in ipairs(crops) do
            local nearestIndex = nil
            local nearestDistSq = math.huge
            for slotIndex, slotPosition in ipairs(layout) do
                local dx = entry.position.X - slotPosition.X
                local dz = entry.position.Z - slotPosition.Z
                local distSq = dx * dx + dz * dz
                if distSq < nearestDistSq then
                    nearestDistSq = distSq
                    nearestIndex = slotIndex
                end
            end
            if nearestIndex then
                occupied[nearestIndex] = true
            end
        end
        return occupied
    end

    local function isCurvedFarmStyle(styleName)
        return normalizeFarmStyle(styleName) ~= "Default"
    end

    local function findNextPlantPosition(styleName, center, maxCount)
        local style = normalizeFarmStyle(styleName)
        local crops = refreshAllCropsByLocalPlayer()
        if maxCount and #crops >= maxCount then
            return nil
        end
        if style == "Default" or not maxCount then
            return center
        end
        local layout = buildFarmStylePositions(style, center, maxCount)
        local occupied = getFarmSlotOccupancy(layout, crops)
        for slotIndex = 1, maxCount do
            if not occupied[slotIndex] then
                return layout[slotIndex]
            end
        end
        local fallbackIndex = #crops + 1
        if fallbackIndex <= maxCount then
            return layout[fallbackIndex]
        end
        return nil
    end

    local function shouldContinuePlanting(styleName, plantedCount, quantity, maxCount)
        local cropCount = countLocalPlayerActiveCrops()
        if maxCount and cropCount >= maxCount then
            return false
        end
        if isCurvedFarmStyle(styleName) and maxCount then
            return cropCount < maxCount
        end
        return plantedCount < quantity
    end

    FarmTab:CreateSection("Plant Crops")
    -- Farm position: default until user sets current position
    local DEFAULT_FARM_POSITION = Vector3.new(-169.41416931152, 39.296875, -287.59017944336)
    local farmPosition = DEFAULT_FARM_POSITION
    local farmCropMaxCount = nil

    local function getFarmPosition()
        return farmPosition
    end

    local function farmInfoParagraphText()
        local lines = {
            string.format("Position: %.1f, %.1f, %.1f", farmPosition.X, farmPosition.Y, farmPosition.Z),
        }
        if farmCropMaxCount then
            table.insert(lines, string.format("Max crops: %d", farmCropMaxCount))
            table.insert(lines, string.format("Active crops: %d / %d", countLocalPlayerActiveCrops(), farmCropMaxCount))
        else
            table.insert(lines, "Max crops: (unknown)")
            table.insert(lines, string.format("Active crops: %d", countLocalPlayerActiveCrops()))
        end
        return table.concat(lines, "\n")
    end

    local farmInfoParagraph
    local function updateFarmInfoParagraph()
        if farmInfoParagraph and farmInfoParagraph.Set then
            farmInfoParagraph:Set({
                Title = "Farm info",
                Content = farmInfoParagraphText(),
            })
        end
    end

    local function setFarmCropMaxCount(maxCount)
        if type(maxCount) ~= "number" or maxCount < 1 then
            return
        end
        farmCropMaxCount = maxCount
        updateFarmInfoParagraph()
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
                updateFarmInfoParagraph()
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
    farmInfoParagraph = FarmTab:CreateParagraph({
        Title = "Farm info",
        Content = farmInfoParagraphText(),
    })

    do
        local activeCrops = Workspace:FindFirstChild("ActiveCrops")
        if activeCrops then
            activeCrops.ChildAdded:Connect(function()
                refreshAllCropsByLocalPlayer()
                updateFarmInfoParagraph()
            end)
            activeCrops.ChildRemoved:Connect(function()
                refreshAllCropsByLocalPlayer()
                updateFarmInfoParagraph()
            end)
        end
        refreshAllCropsByLocalPlayer()
        updateFarmInfoParagraph()
    end

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
    local selectedFarmStyle = "Default"

    FarmTab:CreateInput({
        Name = "Quantity",
        PlaceholderText = "Enter quantity",
        CurrentValue = FarmQuantity,
        Callback = function(value)
            FarmQuantity = value
        end
    })

    local heartScaleSlider
    local circleRadiusSlider
    local randomRadiusSlider

    local function updateFarmStyleSliderVisibility()
        local style = normalizeFarmStyle(selectedFarmStyle)
        if heartScaleSlider and heartScaleSlider.SetVisible then
            heartScaleSlider:SetVisible(style == "Heart")
        end
        if circleRadiusSlider and circleRadiusSlider.SetVisible then
            circleRadiusSlider:SetVisible(style == "Circle")
        end
        if randomRadiusSlider and randomRadiusSlider.SetVisible then
            randomRadiusSlider:SetVisible(style == "Random")
        end
    end

    FarmTab:CreateDropdown({
        Name = "Farm Style",
        Options = FARM_STYLE_OPTIONS,
        CurrentOption = { selectedFarmStyle },
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            if picked then
                selectedFarmStyle = picked
                updateFarmStyleSliderVisibility()
            end
        end,
    })

    heartScaleSlider = FarmTab:CreateSlider({
        Name = "Heart scale",
        Range = { 0.1, 2 },
        Increment = 0.05,
        CurrentValue = farmHeartCurveScale,
        Callback = function(value)
            farmHeartCurveScale = value
        end,
    })

    circleRadiusSlider = FarmTab:CreateSlider({
        Name = "Circle radius",
        Range = { 1, 25 },
        Increment = 0.5,
        Suffix = "studs",
        CurrentValue = farmCircleRadius,
        Callback = function(value)
            farmCircleRadius = value
        end,
    })

    randomRadiusSlider = FarmTab:CreateSlider({
        Name = "Random radius",
        Range = { 1, 25 },
        Increment = 0.5,
        Suffix = "studs",
        CurrentValue = farmRandomRadius,
        Callback = function(value)
            farmRandomRadius = value
        end,
    })

    updateFarmStyleSliderVisibility()

    local function equipSelectedPlantForFarm()
        if not selectedPlant or selectedPlant == "" then
            return
        end
        local character = Players.LocalPlayer.Character
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        if not character or not backpack then
            return
        end
        local plantTool = backpack:FindFirstChild(selectedPlant) or character:FindFirstChild(selectedPlant)
        if not plantTool or not plantTool:IsA("Tool") then
            return
        end
        local currentTool = nil
        for _, c in ipairs(character:GetChildren()) do
            if c:IsA("Tool") then
                currentTool = c
                break
            end
        end
        if currentTool == plantTool then
            return
        end
        if currentTool then
            currentTool.Parent = backpack
            task.wait()
        end
        plantTool.Parent = character
    end

    local function teleportCharacterNear(position, maxDistance)
        maxDistance = maxDistance or 5
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart and (rootPart.Position - position).Magnitude > maxDistance then
            rootPart.CFrame = CFrame.new(position)
            task.wait(0.5)
        end
    end

    FarmTab:CreateButton({
        Name = "Start Farm",
        Callback = function()
            equipSelectedPlantForFarm()

            local qty = tonumber(FarmQuantity) or 1
            local PlantCropEvent = ReplicatedStorage.Remotes.TutorialRemotes.PlantCrop
            local NotificationEvent = ReplicatedStorage.Remotes.TutorialRemotes.Notification
            local center = getFarmPosition()
            local cropMaxCount = nil
            local hitMaxCrops = false

            teleportCharacterNear(center)

            local connection = NotificationEvent.OnClientEvent:Connect(function(message)
                local maxFromNotify = parseMaxCropsFromNotification(message)
                if maxFromNotify then
                    cropMaxCount = maxFromNotify
                    setFarmCropMaxCount(maxFromNotify)
                end
            end)

            local planted = 0
            local safetyLimit = 500
            while shouldContinuePlanting(selectedFarmStyle, planted, qty, cropMaxCount or farmCropMaxCount) and safetyLimit > 0 do
                safetyLimit -= 1
                local plantPosition = findNextPlantPosition(selectedFarmStyle, center, cropMaxCount or farmCropMaxCount)
                if not plantPosition then
                    local maxCount = cropMaxCount or farmCropMaxCount
                    hitMaxCrops = maxCount ~= nil and countLocalPlayerActiveCrops() >= maxCount
                    break
                end
                planted += 1
                print("Planting crop " .. planted .. " (target " .. tostring(cropMaxCount or qty) .. ")")
                teleportCharacterNear(plantPosition)
                PlantCropEvent:FireServer(plantPosition)
                task.wait(1)
            end

            connection:Disconnect()

            local finalMaxCount = cropMaxCount or farmCropMaxCount
            if finalMaxCount and countLocalPlayerActiveCrops() >= finalMaxCount then
                hitMaxCrops = true
            end

            mountNotify({
                Title = "Farm",
                Content = "Planted " .. tostring(planted) .. " crop(s)" .. (hitMaxCrops and " (max crops reached)" or ""),
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

            autoFarmConnection = NotificationEvent.OnClientEvent:Connect(function(message)
                local maxFromNotify = parseMaxCropsFromNotification(message)
                if maxFromNotify then
                    setFarmCropMaxCount(maxFromNotify)
                end
            end)

            task.spawn(function()
                while autoFarmRunning do
                    equipSelectedPlantForFarm()

                    local center = getFarmPosition()
                    local plantPosition = findNextPlantPosition(selectedFarmStyle, center, farmCropMaxCount)
                    if not plantPosition then
                        task.wait(1)
                    else
                        if autoFarmTeleportEnabled then
                            teleportCharacterNear(plantPosition)
                        end
                        PlantCropEvent:FireServer(plantPosition)
                        task.wait(1)
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
    -- */  Auto Sell Crops Section  /* --
    ShopTab:CreateSection("Auto Sell Crops")
    local autoSellCropsItems = {}
    local autoSellCropsItemData = {}
    local selectedAutoSellCropsItems = {}

    local function autoSellCropsOwnedParagraphText()
        local lines = {}
        for _, item in ipairs(autoSellCropsItemData) do
            local owned = type(item.Owned) == "number" and item.Owned or 0
            if owned > 0 then
                local name = item.DisplayName or item.Name or tostring(item)
                table.insert(lines, name .. " (x" .. tostring(owned) .. ")")
            end
        end
        if #lines == 0 then
            return "No owned crops."
        end
        return table.concat(lines, "\n")
    end

    local autoSellCropsOwnedParagraph
    local function updateAutoSellCropsOwnedParagraph()
        if autoSellCropsOwnedParagraph and autoSellCropsOwnedParagraph.Set then
            autoSellCropsOwnedParagraph:Set({
                Title = "Owned Crops",
                Content = autoSellCropsOwnedParagraphText(),
            })
        end
    end

    autoSellCropsOwnedParagraph = ShopTab:CreateParagraph({
        Title = "Owned Crops",
        Content = "(tap Refresh to load)",
    })

    ShopTab:CreateSection("Selected: (none)")
    local AutoSellCropsDropdown
    local function updateAutoSellCropsSelectedSection()
        local text = #selectedAutoSellCropsItems == 0 and "(none)" or table.concat(selectedAutoSellCropsItems, ", ")
        if ShopTab.Set then
            ShopTab:Set("Selected: " .. text)
        elseif ShopTab.SetTitle then
            ShopTab:SetTitle("Selected: " .. text)
        end
    end

    local function syncSelectedAutoSellCropsItemsFromDropdown(value)
        if type(value) == "table" then
            selectedAutoSellCropsItems = {}
            for _, item in ipairs(value) do
                local name = (type(item) == "table" and item.Title) or item
                if type(name) == "string" and name ~= "" and table.find(autoSellCropsItems, name) then
                    table.insert(selectedAutoSellCropsItems, name)
                end
            end
        elseif type(value) == "string" and value ~= "" and table.find(autoSellCropsItems, value) then
            selectedAutoSellCropsItems = { value }
        else
            selectedAutoSellCropsItems = {}
        end
        updateAutoSellCropsSelectedSection()
    end

    local function applyAutoSellCropsDropdownSelection()
        local kept = {}
        for _, name in ipairs(selectedAutoSellCropsItems) do
            if table.find(autoSellCropsItems, name) then
                table.insert(kept, name)
            end
        end
        selectedAutoSellCropsItems = kept
        if AutoSellCropsDropdown and AutoSellCropsDropdown.Set then
            AutoSellCropsDropdown:Set(kept)
        end
        updateAutoSellCropsSelectedSection()
    end

    AutoSellCropsDropdown = ShopTab:CreateDropdown({
        Name = "Crop",
        Options = autoSellCropsItems,
        CurrentOption = {},
        MultipleOptions = true,
        Callback = function(value)
            syncSelectedAutoSellCropsItemsFromDropdown(value)
        end
    })

    local function getAutoSellCropsItemBaseName(item)
        return item.DisplayName or item.Name or tostring(item)
    end

    -- Reusable refresh: updates autoSellCropsItemData and autoSellCropsItems. Returns true if refresh succeeded.
    local function refreshAutoSellCropsList(showNotify)
        local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
        local Result = Event:InvokeServer("GET_LIST")
        local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
        if not (ExpectedResult and ExpectedResult.Items and type(ExpectedResult.Items) == "table") then
            if showNotify then
                mountNotify({ Title = "Auto Sell Crops", Content = "List refreshed" })
            end
            return false
        end
        local refreshByName = {}
        for _, item in ipairs(ExpectedResult.Items) do
            if item.Name then
                refreshByName[item.Name] = item
            end
        end
        for _, item in ipairs(autoSellCropsItemData) do
            local fromRefresh = item.Name and refreshByName[item.Name]
            if fromRefresh then
                item.Owned = type(fromRefresh.Owned) == "number" and fromRefresh.Owned or 0
            else
                item.Owned = 0
            end
        end
        local existingNames = {}
        for _, item in ipairs(autoSellCropsItemData) do
            existingNames[item.Name] = true
        end
        for _, item in ipairs(ExpectedResult.Items) do
            if item.Name and not existingNames[item.Name] then
                existingNames[item.Name] = true
                table.insert(autoSellCropsItemData, item)
                table.insert(autoSellCropsItems, getAutoSellCropsItemBaseName(item))
            end
        end
        AutoSellCropsDropdown:Refresh(autoSellCropsItems)
        applyAutoSellCropsDropdownSelection()
        updateAutoSellCropsOwnedParagraph()
        if showNotify then
            mountNotify({
                Title = "Auto Sell Crops",
                Content = ExpectedResult and ExpectedResult.Success and ("List refreshed" .. (ExpectedResult.Coins and (" â€¢ Coins: " .. tostring(ExpectedResult.Coins)) or "")) or "List refreshed",
            })
        end
        return true
    end

    ShopTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshAutoSellCropsList(true)
        end
    })
    local autoSellCropsDelaySeconds = "1"
    local autoSellCropsRunning = false

    ShopTab:CreateInput({
        Name = "Delay (seconds)",
        PlaceholderText = "Seconds between auto sell crop actions",
        CurrentValue = autoSellCropsDelaySeconds,
        Callback = function(value)
            autoSellCropsDelaySeconds = value
        end
    })

    ShopTab:CreateToggle({
        Name = "Auto Sell Crops",
        Callback = function(enabled)
            autoSellCropsRunning = enabled
            if not enabled then return end
            task.spawn(function()
                local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
                while autoSellCropsRunning do
                    refreshAutoSellCropsList(false)
                    local toSell = {}
                    for _, displayStr in ipairs(selectedAutoSellCropsItems) do
                        for _, item in ipairs(autoSellCropsItemData) do
                            if getAutoSellCropsItemBaseName(item) == displayStr then
                                local owned = type(item.Owned) == "number" and item.Owned or 0
                                if owned > 0 then
                                    table.insert(toSell, { name = item.Name, owned = owned, item = item })
                                end
                                break
                            end
                        end
                    end
                    for _, entry in ipairs(toSell) do
                        if not autoSellCropsRunning then break end
                        local Result = Event:InvokeServer("SELL", entry.name, entry.owned)
                        local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
                        local success = ExpectedResult and ExpectedResult.Success
                        local message = (ExpectedResult and ExpectedResult.Message) or (success and "Sold" or "Failed")
                        mountNotify({
                            Title = "Auto Sell Crops",
                            Content = message,
                            Icon = success and "check" or "x",
                        })
                        if ExpectedResult and ExpectedResult.Success and entry.item then
                            entry.item.Owned = 0
                            for i, dataItem in ipairs(autoSellCropsItemData) do
                                if dataItem == entry.item and autoSellCropsItems[i] then
                                    autoSellCropsItems[i] = getAutoSellCropsItemBaseName(entry.item)
                                    AutoSellCropsDropdown:Refresh(autoSellCropsItems)
                                    break
                                end
                            end
                            updateAutoSellCropsOwnedParagraph()
                        end
                        if autoSellCropsRunning and entry ~= toSell[#toSell] then
                            task.wait(1)
                        end
                    end
                    local delay = math.max(0.1, tonumber(autoSellCropsDelaySeconds) or 1)
                    task.wait(delay)
                end
            end)
        end
    })

    -- */  Auto Sell Egg Section  /* --
    ShopTab:CreateSection("Auto Sell Egg")
    local AUTO_SELL_EGG_RARITIES = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Celestial" }
    local AUTO_SELL_EGG_RARITY_DEFAULT = { "Common", "Uncommon", "Rare" }
    local autoSellEggData = {}
    local selectedAutoSellEggRarities = { "Common", "Uncommon", "Rare" }

    local function parseAutoSellEggResult(result)
        return type(result) == "table" and result or (select(1, result))
    end

    local function getAutoSellEggRarity(egg)
        local rarity = egg.RarityName or egg.Rarity
        if type(rarity) == "string" and rarity ~= "" then
            return rarity
        end
        return nil
    end

    local function eggMatchesAutoSellRarityFilter(egg)
        local rarity = getAutoSellEggRarity(egg)
        return rarity ~= nil and table.find(selectedAutoSellEggRarities, rarity) ~= nil
    end

    local function autoSellEggOwnedParagraphText()
        local eggList = autoSellEggData.EggFruits
        if type(eggList) ~= "table" or #eggList == 0 then
            return "No owned eggs."
        end
        local lines = {}
        local count = type(autoSellEggData.EggCount) == "number" and autoSellEggData.EggCount or #eggList
        table.insert(lines, "Eggs (" .. tostring(count) .. ")")
        for _, egg in ipairs(eggList) do
            local rarity = egg.RarityName or egg.Rarity or "?"
            local gram = type(egg.Gram) == "number" and egg.Gram or 0
            local price = type(egg.Price) == "number" and egg.Price or 0
            table.insert(lines, string.format("  %s %dg — %s", rarity, gram, tostring(price)))
        end
        return table.concat(lines, "\n")
    end

    local autoSellEggOwnedParagraph
    local function updateAutoSellEggOwnedParagraph()
        if autoSellEggOwnedParagraph and autoSellEggOwnedParagraph.Set then
            autoSellEggOwnedParagraph:Set({
                Title = "Owned Eggs",
                Content = autoSellEggOwnedParagraphText(),
            })
        end
    end

    autoSellEggOwnedParagraph = ShopTab:CreateParagraph({
        Title = "Owned Eggs",
        Content = "(tap Refresh to load)",
    })

    local AutoSellEggRarityDropdown
    local function syncSelectedAutoSellEggRaritiesFromDropdown(value)
        if type(value) == "table" then
            selectedAutoSellEggRarities = {}
            for _, item in ipairs(value) do
                local name = (type(item) == "table" and item.Title) or item
                if type(name) == "string" and name ~= "" and table.find(AUTO_SELL_EGG_RARITIES, name) then
                    table.insert(selectedAutoSellEggRarities, name)
                end
            end
        elseif type(value) == "string" and value ~= "" and table.find(AUTO_SELL_EGG_RARITIES, value) then
            selectedAutoSellEggRarities = { value }
        else
            selectedAutoSellEggRarities = {}
        end
    end

    local function applyAutoSellEggRarityDropdownSelection()
        local kept = {}
        for _, rarity in ipairs(selectedAutoSellEggRarities) do
            if table.find(AUTO_SELL_EGG_RARITIES, rarity) then
                table.insert(kept, rarity)
            end
        end
        selectedAutoSellEggRarities = kept
        if AutoSellEggRarityDropdown and AutoSellEggRarityDropdown.Set then
            AutoSellEggRarityDropdown:Set(kept)
        end
    end

    AutoSellEggRarityDropdown = ShopTab:CreateDropdown({
        Name = "Rarity",
        Options = AUTO_SELL_EGG_RARITIES,
        CurrentOption = AUTO_SELL_EGG_RARITY_DEFAULT,
        MultipleOptions = true,
        Callback = function(value)
            syncSelectedAutoSellEggRaritiesFromDropdown(value)
        end,
    })
    applyAutoSellEggRarityDropdownSelection()

    local function refreshAutoSellEggList(showNotify)
        local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
        local result = Event:InvokeServer("GET_EGG_LIST")
        local expected = parseAutoSellEggResult(result)
        local anySuccess = false
        local lastCoins = nil

        if expected and expected.Success then
            anySuccess = true
            autoSellEggData = expected
            if type(expected.Coins) == "number" then
                lastCoins = expected.Coins
            end
        elseif expected then
            autoSellEggData = expected
        else
            autoSellEggData = { EggFruits = {}, EggCount = 0 }
        end

        updateAutoSellEggOwnedParagraph()

        if showNotify then
            local content = "Egg list refreshed"
            if lastCoins then
                content = content .. " • Coins: " .. tostring(lastCoins)
            end
            mountNotify({ Title = "Auto Sell Egg", Content = content })
        end
        return anySuccess
    end

    ShopTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshAutoSellEggList(true)
        end,
    })

    local autoSellEggDelaySeconds = "1"
    local autoSellEggRunning = false

    ShopTab:CreateInput({
        Name = "Delay (seconds)",
        PlaceholderText = "Seconds between auto sell egg actions",
        CurrentValue = autoSellEggDelaySeconds,
        Callback = function(value)
            autoSellEggDelaySeconds = value
        end,
    })

    ShopTab:CreateToggle({
        Name = "Auto Sell Egg",
        Callback = function(enabled)
            autoSellEggRunning = enabled
            if not enabled then return end
            task.spawn(function()
                local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
                while autoSellEggRunning do
                    if #selectedAutoSellEggRarities == 0 then
                        task.wait(math.max(0.1, tonumber(autoSellEggDelaySeconds) or 1))
                    else
                        refreshAutoSellEggList(false)
                        local toSell = {}
                        local eggList = autoSellEggData.EggFruits
                        if type(eggList) == "table" then
                            for _, egg in ipairs(eggList) do
                                if type(egg.Id) == "string" and egg.Id ~= ""
                                    and eggMatchesAutoSellRarityFilter(egg) then
                                    table.insert(toSell, egg)
                                end
                            end
                        end
                        for _, egg in ipairs(toSell) do
                            if not autoSellEggRunning then break end
                            local result = Event:InvokeServer("SELL_EGG", egg.Id, 1)
                            local expected = parseAutoSellEggResult(result)
                            local success = expected and expected.Success
                            local message = (expected and expected.Message) or (success and "Sold" or "Failed")
                            mountNotify({
                                Title = "Auto Sell Egg",
                                Content = message,
                                Icon = success and "check" or "x",
                            })
                            if success then
                                local list = autoSellEggData.EggFruits
                                if type(list) == "table" then
                                    for i = #list, 1, -1 do
                                        if list[i].Id == egg.Id then
                                            table.remove(list, i)
                                            break
                                        end
                                    end
                                    autoSellEggData.EggCount = #list
                                end
                                updateAutoSellEggOwnedParagraph()
                            end
                            if autoSellEggRunning and egg ~= toSell[#toSell] then
                                task.wait(1)
                            end
                        end
                        local delay = math.max(0.1, tonumber(autoSellEggDelaySeconds) or 1)
                        task.wait(delay)
                    end
                end
            end)
        end,
    })

    -- */  Auto Sell Fruit Section  /* --
    ShopTab:CreateSection("Auto Sell Fruit")
    local AUTO_SELL_FRUIT_TYPES = { "Sawit", "Durian", "Alpukat" }
    local AUTO_SELL_FRUIT_RARITIES = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Celestial" }
    local AUTO_SELL_FRUIT_RARITY_DEFAULT = { "Common", "Uncommon", "Rare" }
    local autoSellFruitByType = {}
    local selectedAutoSellFruitTypes = {}
    local selectedAutoSellFruitRarities = { "Common", "Uncommon", "Rare" }

    local function parseAutoSellFruitResult(result)
        return type(result) == "table" and result or (select(1, result))
    end

    local function getAutoSellFruitRarity(fruit)
        local rarity = fruit.RarityName or fruit.Rarity
        if type(rarity) == "string" and rarity ~= "" then
            return rarity
        end
        return nil
    end

    local function fruitMatchesAutoSellRarityFilter(fruit)
        local rarity = getAutoSellFruitRarity(fruit)
        return rarity ~= nil and table.find(selectedAutoSellFruitRarities, rarity) ~= nil
    end

    local function autoSellFruitOwnedParagraphText()
        local lines = {}
        for _, fruitType in ipairs(AUTO_SELL_FRUIT_TYPES) do
            local data = autoSellFruitByType[fruitType]
            local fruitList = data and data.FruitList
            if type(fruitList) == "table" and #fruitList > 0 then
                local count = type(data.FruitCount) == "number" and data.FruitCount or #fruitList
                local header = (data.FruitDisplayName or fruitType) .. " (" .. tostring(count) .. ")"
                table.insert(lines, header)
                for _, fruit in ipairs(fruitList) do
                    local rarity = fruit.RarityName or fruit.Rarity or "?"
                    local weight = type(fruit.Weight) == "number" and fruit.Weight or 0
                    local unit = fruit.WeightUnit or "kg"
                    local price = type(fruit.Price) == "number" and fruit.Price or 0
                    table.insert(lines, string.format("  %s %.0f%s — %s", rarity, weight, unit, tostring(price)))
                end
            end
        end
        if #lines == 0 then
            return "No owned fruits."
        end
        return table.concat(lines, "\n")
    end

    local function autoSellFruitSelectedParagraphText()
        local fruitText = #selectedAutoSellFruitTypes == 0 and "(none)" or table.concat(selectedAutoSellFruitTypes, ", ")
        local rarityText = #selectedAutoSellFruitRarities == 0 and "(none)" or table.concat(selectedAutoSellFruitRarities, ", ")
        return "Fruit: " .. fruitText .. "\nRarity: " .. rarityText
    end

    local autoSellFruitOwnedParagraph
    local function updateAutoSellFruitOwnedParagraph()
        if autoSellFruitOwnedParagraph and autoSellFruitOwnedParagraph.Set then
            autoSellFruitOwnedParagraph:Set({
                Title = "Owned Fruits",
                Content = autoSellFruitOwnedParagraphText(),
            })
        end
    end

    local autoSellFruitSelectedParagraph
    local function updateAutoSellFruitSelectedParagraph()
        if autoSellFruitSelectedParagraph and autoSellFruitSelectedParagraph.Set then
            autoSellFruitSelectedParagraph:Set({
                Title = "Selected",
                Content = autoSellFruitSelectedParagraphText(),
            })
        end
    end

    autoSellFruitOwnedParagraph = ShopTab:CreateParagraph({
        Title = "Owned Fruits",
        Content = "(tap Refresh to load)",
    })

    autoSellFruitSelectedParagraph = ShopTab:CreateParagraph({
        Title = "Selected",
        Content = autoSellFruitSelectedParagraphText(),
    })

    local AutoSellFruitDropdown
    local function syncSelectedAutoSellFruitTypesFromDropdown(value)
        if type(value) == "table" then
            selectedAutoSellFruitTypes = {}
            for _, item in ipairs(value) do
                local name = (type(item) == "table" and item.Title) or item
                if type(name) == "string" and name ~= "" and table.find(AUTO_SELL_FRUIT_TYPES, name) then
                    table.insert(selectedAutoSellFruitTypes, name)
                end
            end
        elseif type(value) == "string" and value ~= "" and table.find(AUTO_SELL_FRUIT_TYPES, value) then
            selectedAutoSellFruitTypes = { value }
        else
            selectedAutoSellFruitTypes = {}
        end
        updateAutoSellFruitSelectedParagraph()
    end

    local function applyAutoSellFruitDropdownSelection()
        local kept = {}
        for _, fruitType in ipairs(selectedAutoSellFruitTypes) do
            if table.find(AUTO_SELL_FRUIT_TYPES, fruitType) then
                table.insert(kept, fruitType)
            end
        end
        selectedAutoSellFruitTypes = kept
        if AutoSellFruitDropdown and AutoSellFruitDropdown.Set then
            AutoSellFruitDropdown:Set(kept)
        end
        updateAutoSellFruitSelectedParagraph()
    end

    AutoSellFruitDropdown = ShopTab:CreateDropdown({
        Name = "Fruit",
        Options = AUTO_SELL_FRUIT_TYPES,
        CurrentOption = {},
        MultipleOptions = true,
        Callback = function(value)
            syncSelectedAutoSellFruitTypesFromDropdown(value)
        end,
    })

    local AutoSellFruitRarityDropdown
    local function syncSelectedAutoSellFruitRaritiesFromDropdown(value)
        if type(value) == "table" then
            selectedAutoSellFruitRarities = {}
            for _, item in ipairs(value) do
                local name = (type(item) == "table" and item.Title) or item
                if type(name) == "string" and name ~= "" and table.find(AUTO_SELL_FRUIT_RARITIES, name) then
                    table.insert(selectedAutoSellFruitRarities, name)
                end
            end
        elseif type(value) == "string" and value ~= "" and table.find(AUTO_SELL_FRUIT_RARITIES, value) then
            selectedAutoSellFruitRarities = { value }
        else
            selectedAutoSellFruitRarities = {}
        end
        updateAutoSellFruitSelectedParagraph()
    end

    local function applyAutoSellFruitRarityDropdownSelection()
        local kept = {}
        for _, rarity in ipairs(selectedAutoSellFruitRarities) do
            if table.find(AUTO_SELL_FRUIT_RARITIES, rarity) then
                table.insert(kept, rarity)
            end
        end
        selectedAutoSellFruitRarities = kept
        if AutoSellFruitRarityDropdown and AutoSellFruitRarityDropdown.Set then
            AutoSellFruitRarityDropdown:Set(kept)
        end
        updateAutoSellFruitSelectedParagraph()
    end

    AutoSellFruitRarityDropdown = ShopTab:CreateDropdown({
        Name = "Rarity",
        Options = AUTO_SELL_FRUIT_RARITIES,
        CurrentOption = AUTO_SELL_FRUIT_RARITY_DEFAULT,
        MultipleOptions = true,
        Callback = function(value)
            syncSelectedAutoSellFruitRaritiesFromDropdown(value)
        end,
    })
    applyAutoSellFruitRarityDropdownSelection()

    local function refreshAutoSellFruitList(showNotify, fruitTypesToFetch)
        local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
        local typesToFetch = fruitTypesToFetch or AUTO_SELL_FRUIT_TYPES
        local lastCoins = nil
        local anySuccess = false

        for _, fruitType in ipairs(typesToFetch) do
            local result = Event:InvokeServer("GET_FRUIT_LIST", fruitType)
            local expected = parseAutoSellFruitResult(result)
            if expected and expected.Success then
                anySuccess = true
                autoSellFruitByType[fruitType] = expected
                if type(expected.Coins) == "number" then
                    lastCoins = expected.Coins
                end
            elseif expected then
                autoSellFruitByType[fruitType] = expected
            else
                autoSellFruitByType[fruitType] = { FruitType = fruitType, FruitList = {}, FruitCount = 0 }
            end
        end

        updateAutoSellFruitOwnedParagraph()
        applyAutoSellFruitDropdownSelection()

        if showNotify then
            local content = "Fruit list refreshed"
            if lastCoins then
                content = content .. " • Coins: " .. tostring(lastCoins)
            end
            mountNotify({ Title = "Auto Sell Fruit", Content = content })
        end
        return anySuccess
    end

    ShopTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshAutoSellFruitList(true, AUTO_SELL_FRUIT_TYPES)
        end,
    })

    local autoSellFruitDelaySeconds = "1"
    local autoSellFruitRunning = false

    ShopTab:CreateInput({
        Name = "Delay (seconds)",
        PlaceholderText = "Seconds between auto sell fruit actions",
        CurrentValue = autoSellFruitDelaySeconds,
        Callback = function(value)
            autoSellFruitDelaySeconds = value
        end,
    })

    ShopTab:CreateToggle({
        Name = "Auto Sell Fruit",
        Callback = function(enabled)
            autoSellFruitRunning = enabled
            if not enabled then return end
            task.spawn(function()
                local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
                while autoSellFruitRunning do
                    if #selectedAutoSellFruitTypes == 0 or #selectedAutoSellFruitRarities == 0 then
                        task.wait(math.max(0.1, tonumber(autoSellFruitDelaySeconds) or 1))
                    else
                        refreshAutoSellFruitList(false, selectedAutoSellFruitTypes)
                        local toSell = {}
                        for _, fruitType in ipairs(selectedAutoSellFruitTypes) do
                            local data = autoSellFruitByType[fruitType]
                            local fruitList = data and data.FruitList
                            if type(fruitList) == "table" then
                                for _, fruit in ipairs(fruitList) do
                                    if type(fruit.Id) == "string" and fruit.Id ~= ""
                                        and fruitMatchesAutoSellRarityFilter(fruit) then
                                        table.insert(toSell, {
                                            id = fruit.Id,
                                            fruitType = fruitType,
                                            fruit = fruit,
                                        })
                                    end
                                end
                            end
                        end
                        for _, entry in ipairs(toSell) do
                            if not autoSellFruitRunning then break end
                            local result = Event:InvokeServer("SELL_FRUIT", entry.id, entry.fruitType)
                            local expected = parseAutoSellFruitResult(result)
                            local success = expected and expected.Success
                            local message = (expected and expected.Message) or (success and "Sold" or "Failed")
                            mountNotify({
                                Title = "Auto Sell Fruit",
                                Content = message,
                                Icon = success and "check" or "x",
                            })
                            if success then
                                local data = autoSellFruitByType[entry.fruitType]
                                local fruitList = data and data.FruitList
                                if type(fruitList) == "table" then
                                    for i = #fruitList, 1, -1 do
                                        if fruitList[i].Id == entry.id then
                                            table.remove(fruitList, i)
                                            break
                                        end
                                    end
                                    data.FruitCount = #fruitList
                                end
                                updateAutoSellFruitOwnedParagraph()
                            end
                            if autoSellFruitRunning and entry ~= toSell[#toSell] then
                                task.wait(1)
                            end
                        end
                        local delay = math.max(0.1, tonumber(autoSellFruitDelaySeconds) or 1)
                        task.wait(delay)
                    end
                end
            end)
        end,
    })

    -- */  Gift Game Pass Section  /* --
    ShopTab:CreateSection("Gift Game Pass")

    local giftPassCatalog = {}
    local giftPassDisplayOptions = {}
    local giftPassByDisplayOption = {}
    local selectedGiftPlayer = nil
    local selectedGiftPass = nil
    local giftPlayerList = {}
    local giftPlayerDisplayNames = {}
    local GiftPlayerDropdown
    local GiftPassDropdown
    local GiftPassDescParagraph

    local GIFT_PASSES = {
        { Name = "DoublePanen", Icon = "\240\159\140\190", Price = 50, GamepassId = 1711326948, GiftProductId = 3534985546, Category = "Farming", SortOrder = 1, Giftable = true, displayName = "2x Harvest", description = "Get 2x harvest every time!" },
        { Name = "FastGrow", Icon = "\226\154\161", Price = 75, GamepassId = 1711410899, GiftProductId = 3542169435, Category = "Farming", SortOrder = 2, Giftable = true, displayName = "Fast Grow", description = "Crops grow 50% faster!" },
        { Name = "ExtraSlots", Icon = "\240\159\147\166", Price = 99, GamepassId = 1709346337, GiftProductId = 3542169045, Category = "Farming", SortOrder = 3, Giftable = true, displayName = "Extra Slots", description = "Max crops from 15 to 25!" },
        { Name = "DoubleSell", Icon = "\240\159\146\176", Price = 99, GamepassId = 1710868999, GiftProductId = 3542168668, Category = "Farming", SortOrder = 4, Giftable = true, displayName = "2x Sell", description = "Sell price doubled!" },
        { Name = "DoubleXP", Icon = "\226\173\144", Price = 150, GamepassId = 1710737068, GiftProductId = 3542168280, Category = "Boost", SortOrder = 5, Giftable = true, displayName = "2x XP", description = "All XP (plant, harvest, sell) 2x!" },
        { Name = "RainLover", Icon = "\240\159\140\167\239\184\143", Price = 150, GamepassId = 1710551126, GiftProductId = 3542167872, Category = "Boost", SortOrder = 6, Giftable = true, displayName = "Rain Lover", description = "During rain, 3x growth boost!" },
        { Name = "AutoHarvest", Icon = "\240\159\164\150", Price = 249, GamepassId = 1708014472, GiftProductId = 3542161637, Category = "Boost", SortOrder = 7, Giftable = true, displayName = "Auto Harvest", description = "Ripe crops auto-harvested!" },
        { Name = "Boombox", Icon = "\240\159\147\187", Price = 199, GamepassId = 1709724203, GiftProductId = 3542161296, Category = "Fun", SortOrder = 8, Giftable = true, displayName = "Boombox", description = "Play your favorite music! (Tool)" },
        { Name = "VIP", Icon = "\240\159\145\145", Price = 499, GamepassId = 1708374413, GiftProductId = 3542160882, Category = "Premium", SortOrder = 9, Giftable = true, displayName = "VIP Farmer", description = "2x Harvest + 2x Sell + 2x XP + [VIP] Chat Tag" },
        { Name = "AutoFeedChicken", Icon = "\240\159\144\148", Price = 299, GamepassId = 1748076024, GiftProductId = 3556635500, Category = "Farming", SortOrder = 10, Giftable = true, displayName = "Auto Feed Chicken", description = "Hungry chickens auto-fed with Rice!" },
        { Name = "AutoFeedCow", Icon = "\240\159\144\132", Price = 299, GamepassId = 1748361543, GiftProductId = 3556635493, Category = "Farming", SortOrder = 11, Giftable = true, displayName = "Auto Feed Cow", description = "Hungry cows auto-fed with Corn!" },
        { Name = "AutoCollectEgg", Icon = "\240\159\165\154", Price = 199, GamepassId = 1748245629, GiftProductId = 3556635498, Category = "Farming", SortOrder = 12, Giftable = true, displayName = "Auto Collect Egg", description = "Ready eggs auto-collected!" },
        { Name = "AutoCollectMilk", Icon = "\240\159\165\155", Price = 199, GamepassId = 1748782304, GiftProductId = 3556635499, Category = "Farming", SortOrder = 13, Giftable = true, displayName = "Auto Collect Milk", description = "Ready milk auto-collected!" },
    }

    local function giftPassDisplayLabel(pass)
        return (pass.Icon or "") .. " " .. (pass.displayName or pass.Name)
    end

    local function rebuildGiftPassOptions()
        giftPassCatalog = {}
        giftPassDisplayOptions = {}
        giftPassByDisplayOption = {}
        for _, entry in ipairs(GIFT_PASSES) do
            if entry.Giftable ~= false then
                table.insert(giftPassCatalog, entry)
            end
        end
        table.sort(giftPassCatalog, function(a, b)
            return (a.SortOrder or 0) < (b.SortOrder or 0)
        end)
        for _, pass in ipairs(giftPassCatalog) do
            local label = giftPassDisplayLabel(pass)
            table.insert(giftPassDisplayOptions, label)
            giftPassByDisplayOption[label] = pass
        end
        if GiftPassDropdown and GiftPassDropdown.Refresh then
            GiftPassDropdown:Refresh(giftPassDisplayOptions)
        end
    end

    local function updateGiftPassDescription()
        if not (GiftPassDescParagraph and GiftPassDescParagraph.Set) then
            return
        end
        if selectedGiftPass then
            GiftPassDescParagraph:Set({
                Title = selectedGiftPass.displayName,
                Content = selectedGiftPass.description,
            })
        else
            GiftPassDescParagraph:Set({
                Title = "Description",
                Content = "Select a game pass.",
            })
        end
    end

    local function giftPlayerDropdownLabel(player)
        if not player then
            return ""
        end
        local displayName = player.DisplayName
        local username = player.Name
        if displayName and displayName ~= "" and displayName ~= username then
            return string.format("%s (%s)", displayName, username)
        end
        return username
    end

    local function refreshGiftPlayerList(showNotify)
        giftPlayerList = {}
        giftPlayerDisplayNames = {}
        local localPlayer = Players.LocalPlayer
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.ClassName == "Player" then
                table.insert(giftPlayerList, player)
            end
        end
        table.sort(giftPlayerList, function(a, b)
            local na = string.lower(giftPlayerDropdownLabel(a))
            local nb = string.lower(giftPlayerDropdownLabel(b))
            return na < nb
        end)
        for _, player in ipairs(giftPlayerList) do
            table.insert(giftPlayerDisplayNames, giftPlayerDropdownLabel(player))
        end
        if GiftPlayerDropdown and GiftPlayerDropdown.Refresh then
            GiftPlayerDropdown:Refresh(giftPlayerDisplayNames)
        end
        if selectedGiftPlayer and not table.find(giftPlayerList, selectedGiftPlayer) then
            selectedGiftPlayer = nil
            if GiftPlayerDropdown and GiftPlayerDropdown.Select then GiftPlayerDropdown:Select(nil) end
            if GiftPlayerDropdown and GiftPlayerDropdown.Set then GiftPlayerDropdown:Set({}) end
        end
        if showNotify then
            mountNotify({ Title = "Gift Game Pass", Content = "Player list refreshed (" .. #giftPlayerList .. ")" })
        end
    end

    rebuildGiftPassOptions()
    refreshGiftPlayerList(false)

    GiftPlayerDropdown = ShopTab:CreateDropdown({
        Name = "Player",
        Options = giftPlayerDisplayNames,
        CurrentOption = {},
        Search = true,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            selectedGiftPlayer = nil
            if picked then
                local idx = table.find(giftPlayerDisplayNames, picked)
                if idx and giftPlayerList[idx] then
                    selectedGiftPlayer = giftPlayerList[idx]
                end
            end
        end,
    })

    GiftPassDropdown = ShopTab:CreateDropdown({
        Name = "Passes",
        Options = giftPassDisplayOptions,
        CurrentOption = {},
        Search = true,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            selectedGiftPass = picked and giftPassByDisplayOption[picked] or nil
            updateGiftPassDescription()
        end,
    })

    GiftPassDescParagraph = ShopTab:CreateParagraph({
        Title = "Description",
        Content = "Select a game pass.",
    })

    ShopTab:CreateButton({
        Name = "Refresh Players",
        Callback = function()
            refreshGiftPlayerList(true)
        end,
    })

    local requestGiftRemote = ReplicatedStorage.Remotes.TutorialRemotes.RequestGift
    local giftDoneRemote = ReplicatedStorage.Remotes.TutorialRemotes.GiftPurchaseDone
    local giftNotificationRemote = ReplicatedStorage.Remotes.TutorialRemotes.Notification
    local GIFT_NOTIFY_TIMEOUT = 15
    local GIFT_ALL_DELAY_SECONDS = 10

    local function listenGiftPassNotification(targetPlayer, onMessage)
        local targetName = targetPlayer.DisplayName or targetPlayer.Name
        local received = false
        local conn
        conn = giftNotificationRemote.OnClientEvent:Connect(function(message)
            if received or type(message) ~= "string" then
                return
            end
            if not string.find(message, "sent to", 1, true) then
                return
            end
            if targetName ~= "" and not string.find(message, targetName, 1, true) then
                return
            end
            received = true
            if conn then
                conn:Disconnect()
                conn = nil
            end
            onMessage(message)
        end)
        task.delay(GIFT_NOTIFY_TIMEOUT, function()
            if conn then
                conn:Disconnect()
                conn = nil
            end
        end)
    end

    local function playerOwnsGiftPass(targetPlayer, pass)
        return targetPlayer:GetAttribute("GP_" .. pass.Name) == true
    end

    local function giftPassToPlayer(targetPlayer, pass, showSuccessNotify)
        if playerOwnsGiftPass(targetPlayer, pass) then
            local passLabel = pass.displayName or pass.Name
            local playerLabel = giftPlayerDropdownLabel(targetPlayer)
            mountNotify({
                Title = "Gift Game Pass",
                Content = string.format("%s already owns %s", playerLabel, passLabel),
            })
            return false, "ALREADY_OWNED"
        end

        local result = requestGiftRemote:InvokeServer("PROMPT_GIFT", targetPlayer.UserId, pass.Name)
        local expected = type(result) == "table" and result or select(1, result)

        task.spawn(function()
            task.wait(0.2)
            forceCloseRobloxPurchasePrompt(8)
        end)

        if not (expected and expected.Success) then
            return false, (expected and expected.Message) or "Could not start gift prompt"
        end

        if showSuccessNotify then
            listenGiftPassNotification(targetPlayer, function(message)
                mountNotify({
                    Title = "Gift Game Pass",
                    Content = message,
                    Icon = "check",
                })
            end)
        end

        giftDoneRemote:FireServer(pass.GiftProductId, true)
        return true
    end

    ShopTab:CreateButton({
        Name = "Gift Passes",
        Callback = function()
            if not selectedGiftPlayer then
                mountNotify({ Title = "Gift Game Pass", Content = "Select a player first" })
                return
            end
            if not selectedGiftPass then
                mountNotify({ Title = "Gift Game Pass", Content = "Select a game pass first" })
                return
            end
            local ok, err = giftPassToPlayer(selectedGiftPlayer, selectedGiftPass, true)
            if not ok and err ~= "ALREADY_OWNED" then
                mountNotify({
                    Title = "Gift Game Pass",
                    Content = err,
                    Icon = "x",
                })
            end
        end,
    })

    ShopTab:CreateButton({
        Name = "Gift All Passes to Player",
        Callback = function()
            if not selectedGiftPlayer then
                mountNotify({ Title = "Gift Game Pass", Content = "Select a player first" })
                return
            end
            local targetPlayer = selectedGiftPlayer
            local targetLabel = giftPlayerDropdownLabel(targetPlayer)
            task.spawn(function()
                local sent = 0
                local skipped = 0
                for _, pass in ipairs(giftPassCatalog) do
                    if not targetPlayer.Parent then
                        break
                    end
                    local ok, err = giftPassToPlayer(targetPlayer, pass, false)
                    if ok then
                        sent = sent + 1
                    else
                        skipped = skipped + 1
                        if err ~= "ALREADY_OWNED" then
                            mountNotify({
                                Title = "Gift All",
                                Content = (pass.displayName or pass.Name) .. ": " .. tostring(err),
                                Icon = "x",
                            })
                        end
                    end
                    task.wait(GIFT_ALL_DELAY_SECONDS)
                end
                mountNotify({
                    Title = "Gift All",
                    Content = string.format(
                        "Finished for %s: %d sent, %d skipped (of %d)",
                        targetLabel,
                        sent,
                        skipped,
                        #giftPassCatalog
                    ),
                    Icon = sent > 0 and "check" or "x",
                })
            end)
        end,
    })

    ShopTab:CreateButton({
        Name = "Gift Passes to All Players",
        Callback = function()
            if not selectedGiftPass then
                mountNotify({ Title = "Gift Game Pass", Content = "Select a game pass first" })
                return
            end
            local pass = selectedGiftPass
            local passLabel = pass.displayName or pass.Name
            task.spawn(function()
                refreshGiftPlayerList(false)
                local sent = 0
                local skipped = 0
                local total = #giftPlayerList
                if total == 0 then
                    mountNotify({ Title = "Gift to All", Content = "No other players in server", Icon = "x" })
                    return
                end
                for _, targetPlayer in ipairs(giftPlayerList) do
                    if not targetPlayer.Parent then
                        skipped = skipped + 1
                    else
                        local ok, err = giftPassToPlayer(targetPlayer, pass, false)
                        if ok then
                            sent = sent + 1
                        else
                            skipped = skipped + 1
                            if err ~= "ALREADY_OWNED" then
                                mountNotify({
                                    Title = "Gift to All",
                                    Content = giftPlayerDropdownLabel(targetPlayer) .. ": " .. tostring(err),
                                    Icon = "x",
                                })
                            end
                        end
                    end
                    task.wait(GIFT_ALL_DELAY_SECONDS)
                end
                mountNotify({
                    Title = "Gift to All",
                    Content = string.format(
                        "%s: %d sent, %d skipped (of %d players)",
                        passLabel,
                        sent,
                        skipped,
                        total
                    ),
                    Icon = sent > 0 and "check" or "x",
                })
            end)
        end,
    })

    Players.PlayerAdded:Connect(function(player)
        if player ~= Players.LocalPlayer then
            refreshGiftPlayerList(false)
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        if player == selectedGiftPlayer then
            selectedGiftPlayer = nil
        end
        refreshGiftPlayerList(false)
    end)
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
