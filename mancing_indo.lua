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
local MarketplaceService = game:GetService("MarketplaceService")

local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        WindUI = result
    else 
        if cloneref(RunService):IsStudio() then
            WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

-- */  Window  /* --
local Window = WindUI:CreateWindow({
    Title = "sempatpanick | Mancing Indo",
    Folder = "ftgshub",
    Icon = "solar:folder-2-bold-duotone",
    NewElements = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "Open SempatPanick UI",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"), 
            Color3.fromHex("#e7ff2f")
        )
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

-- */  Colors  /* --
local Green = Color3.fromHex("#10C550")

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

-- */  Elements Section  /* --
local ElementsSection = Window:Section({
    Title = "Elements",
    Opened = true,
})

-- Bridged from Local Player tab: temporary fly + no clip for underground auto-sell (Main tab).
local autoSellTripAssist = {}

-- */  Local Player Tab  /* --
do
    local LocalPlayerTab = ElementsSection:Tab({
        Title = "Local Player",
        Icon = "solar:folder-2-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    local MiscSection = LocalPlayerTab:Section({
        Title = "Misc",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local infiniteJumpConnection = nil
    local antiAfkConnection = nil
    local noClipEnabled = false
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

    MiscSection:Toggle({
        Title = "Anti AFK",
        Desc = "Prevent kick for inactivity (resets idle when Roblox detects AFK)",
        Value = true,
        Callback = function(enabled)
            if enabled then
                startAntiAfk()
            else
                stopAntiAfk()
            end
        end
    })

    MiscSection:Toggle({
        Title = "Infinite Jump",
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

    MiscSection:Toggle({
        Title = "No Clip",
        Desc = "Pass through walls (disables character collision)",
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

    MiscSection:Toggle({
        Title = "Fly",
        Desc = "WASD + Space (up) / Ctrl (down), camera direction",
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

    MiscSection:Toggle({
        Title = "Free Camera",
        Desc = "Detach camera. Hold LMB/RMB + drag to look; WASD + Space/Ctrl to move. Character stays in place; cursor visible when not dragging.",
        Callback = function(enabled)
            freeCameraEnabled = enabled
            if enabled then
                startFreeCamera()
            else
                stopFreeCamera()
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

    LocalPlayerTab:Space()

    local WalkSpeedSection = LocalPlayerTab:Section({
        Title = "Walk Speed",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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

    local WalkSpeedInput = WalkSpeedSection:Input({
        Title = "Speed",
        Placeholder = "e.g. 16 or 100",
        Value = walkSpeedValue,
        Callback = function(value)
            walkSpeedValue = value
        end
    })

    local function syncWalkSpeedInputFromCharacter(showNotify)
        local speed, errMessage = getCurrentCharacterWalkSpeed()
        if not speed then
            if showNotify then
                WindUI:Notify({ Title = "Walk Speed", Content = errMessage, Icon = "x" })
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
            WindUI:Notify({ Title = "Walk Speed", Content = "Current speed: " .. speedText, Icon = "check" })
        end
        return true
    end

    WalkSpeedSection:Space()

    WalkSpeedSection:Button({
        Title = "Get Current Walk Speed",
        Justify = "Center",
        Icon = "",
        Callback = function()
            syncWalkSpeedInputFromCharacter(true)
        end
    })

    -- Keep the input defaulted to current character speed when available.
    syncWalkSpeedInputFromCharacter(false)

    WalkSpeedSection:Space()

    WalkSpeedSection:Button({
        Title = "Apply",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                WindUI:Notify({ Title = "Walk Speed", Content = "Character not loaded", Icon = "x" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                WindUI:Notify({ Title = "Walk Speed", Content = "Humanoid not found", Icon = "x" })
                return
            end
            local speed = tonumber(walkSpeedValue) or defaultWalkSpeed
            humanoid.WalkSpeed = math.max(0, speed)
            WindUI:Notify({ Title = "Walk Speed", Content = "Set to " .. tostring(humanoid.WalkSpeed), Icon = "check" })
        end
    })

    WalkSpeedSection:Space()

    WalkSpeedSection:Button({
        Title = "Reset",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                WindUI:Notify({ Title = "Walk Speed", Content = "Character not loaded", Icon = "x" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                WindUI:Notify({ Title = "Walk Speed", Content = "Humanoid not found", Icon = "x" })
                return
            end
            humanoid.WalkSpeed = defaultWalkSpeed
            walkSpeedValue = tostring(defaultWalkSpeed)
            WindUI:Notify({ Title = "Walk Speed", Content = "Reset to " .. tostring(defaultWalkSpeed), Icon = "check" })
        end
    })

    LocalPlayerTab:Space()

    local JumpHeightSection = LocalPlayerTab:Section({
        Title = "Jump Height",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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

    local JumpHeightInput = JumpHeightSection:Input({
        Title = "Height",
        Placeholder = "e.g. 7.2 or 50",
        Value = jumpHeightValue,
        Callback = function(value)
            jumpHeightValue = value
        end
    })

    local function syncJumpHeightInputFromCharacter(showNotify)
        local jumpHeight, errMessage = getCurrentCharacterJumpHeight()
        if not jumpHeight then
            if showNotify then
                WindUI:Notify({ Title = "Jump Height", Content = errMessage, Icon = "x" })
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
            WindUI:Notify({ Title = "Jump Height", Content = "Current jump height: " .. jumpHeightText, Icon = "check" })
        end
        return true
    end

    JumpHeightSection:Space()

    JumpHeightSection:Button({
        Title = "Get Current Jump Height",
        Justify = "Center",
        Icon = "",
        Callback = function()
            syncJumpHeightInputFromCharacter(true)
        end
    })

    -- Keep the input defaulted to current character jump height when available.
    syncJumpHeightInputFromCharacter(false)

    JumpHeightSection:Space()

    JumpHeightSection:Button({
        Title = "Apply",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                WindUI:Notify({ Title = "Jump Height", Content = "Character not loaded", Icon = "x" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                WindUI:Notify({ Title = "Jump Height", Content = "Humanoid not found", Icon = "x" })
                return
            end
            local jumpHeight = tonumber(jumpHeightValue) or defaultJumpHeight
            humanoid.JumpHeight = math.max(0, jumpHeight)
            WindUI:Notify({ Title = "Jump Height", Content = "Set to " .. tostring(humanoid.JumpHeight), Icon = "check" })
        end
    })

    LocalPlayerTab:Space()

    local PlayersInfoSection = LocalPlayerTab:Section({
        Title = "Players Info",
        Desc = "Pick a player to view username, display name, speed, location, Humanoid properties, and Humanoid children",
        Box = true,
        BoxBorder = true,
        Opened = true,
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

    -- Humanoid fields to read via pcall (some may not exist on older clients).
    local HUMANOID_INSPECT_PROPERTIES = {
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

    local function buildPlayersInfoText(player)
        if not player then
            return "Select a player from the list."
        end
        local lines = {}
        table.insert(lines, "Username: " .. player.Name)
        local dn = player.DisplayName
        table.insert(lines, "Display name: " .. ((dn and dn ~= "") and dn or "(same as username)"))
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
        if humanoid then
            table.insert(lines, "Humanoid properties:")
            local propRows = {}
            for _, propName in ipairs(HUMANOID_INSPECT_PROPERTIES) do
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
        if PlayersInfoParagraph and PlayersInfoParagraph.SetDesc then
            PlayersInfoParagraph:SetDesc(buildPlayersInfoText(selectedInfoPlayer))
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
                if PlayersInfoDropdown and PlayersInfoDropdown.Set then PlayersInfoDropdown:Set(nil) end
            end
        end
        updatePlayersInfoParagraph()
        if showNotify then
            WindUI:Notify({ Title = "Players Info", Content = "Player list refreshed (" .. #infoPlayerList .. ")", Icon = "check" })
        end
    end

    PlayersInfoDropdown = PlayersInfoSection:Dropdown({
        Title = "Player",
        Desc = "All players in this server",
        Values = infoPlayerDisplayNames,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(value)
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

    PlayersInfoParagraph = PlayersInfoSection:Paragraph({
        Title = "Details",
        Desc = "Select a player from the list.",
    })

    PlayersInfoSection:Button({
        Title = "Refresh list",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshPlayersInfoList(true)
        end,
    })

    PlayersInfoSection:Space()

    PlayersInfoSection:Button({
        Title = "Refresh details",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedInfoPlayer then
                WindUI:Notify({ Title = "Players Info", Content = "Select a player first", Icon = "x" })
                return
            end
            updatePlayersInfoParagraph()
            WindUI:Notify({ Title = "Players Info", Content = "Details updated", Icon = "check" })
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

    LocalPlayerTab:Space()

    local ServerSection = LocalPlayerTab:Section({
        Title = "Server",
        Desc = "Server-related actions",
        Box = true,
        BoxBorder = true,
    })

    ServerSection:Button({
        Title = "Rejoin server",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local TeleportService = game:GetService("TeleportService")
            local placeId = game.PlaceId
            local jobId = game.JobId
            if placeId and jobId and #jobId > 0 then
                local ok, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, jobId)
                end)
                if not ok then
                    WindUI:Notify({
                        Title = "Rejoin",
                        Content = "Failed: " .. tostring(err),
                        Icon = "close",
                    })
                end
            else
                WindUI:Notify({
                    Title = "Rejoin",
                    Content = "Cannot rejoin (missing PlaceId or JobId)",
                    Icon = "close",
                })
            end
        end,
    })

    ServerSection:Button({
        Title = "Copy game ID",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local paste = setclipboard or toclipboard
            if not paste then
                WindUI:Notify({
                    Title = "Server",
                    Content = "Clipboard not supported in this environment",
                    Icon = "x",
                })
                return
            end
            local id = tostring(game.PlaceId)
            paste(id)
            WindUI:Notify({
                Title = "Server",
                Content = "Copied PlaceId " .. id,
                Icon = "check",
            })
        end,
    })

    LocalPlayerTab:Space()

    LocalPlayerTab:Button({
        Title = "Clear Console",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local cleared = false
            local clearFn = rawget(_G, "clearconsole") or rawget(_G, "rconsoleclear")
            if type(clearFn) == "function" then
                clearFn()
                cleared = true
            end
            WindUI:Notify({
                Title = "Console",
                Content = cleared and "Console cleared" or "Clear not available (try clearconsole)",
                Icon = cleared and "check" or "x",
            })
        end
    })

    autoSellTripAssist.begin = function()
        local savedFly = flyEnabled
        local savedNoClip = noClipEnabled
        flyEnabled = true
        noClipEnabled = true
        local lp = Players.LocalPlayer
        local ch = lp.Character
        if ch then
            applyNoClip(ch, true)
        end
        startFly()
        return function()
            flyEnabled = savedFly
            noClipEnabled = savedNoClip
            local ch2 = lp.Character
            if ch2 then
                applyNoClip(ch2, savedNoClip)
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

-- */  Main Tab  /* --
do
    local MainTab = ElementsSection:Tab({
        Title = "Main",
        Icon = "solar:home-2-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    local AutoFishingSection = MainTab:Section({
        Title = "Auto fishing",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local AutoFishStatusParagraph
    local AutoFishMinigameSwitchButton

    local autoFishingEnabled = false
    local autoFishingLoopRunning = false
    local autoFishingPausedForSell = false
    local autoFishingCycleRunning = false
    local instantFishingEnabled = false
    local instantFishingLoopRunning = false
    local instantFishingCycleRunning = false
    local instantFishingDelaySec = 0.5
    local instantFishingArmSeq = 0
    local minigameAutoSolveConn = nil

    local function fishingAutomationActive(): boolean
        return autoFishingEnabled or instantFishingEnabled
    end
    -- Set after CMGR Result; cleared when MGR "Stop" fires or timeout (next cast waits for minigame end).
    local minigameSessionWait = nil :: { seq: number, done: BindableEvent }?
    local minigameCycleSeq = 0
    local MINIGAME_SESSION_TIMEOUT = 20
    -- Reel: deep hack + fast Complete are Instant fishing only. Auto fishing uses VIM E/Q only.
    local REEL_AUTOPLAY_START_DELAY = 0.06
    local REEL_AUTOPLAY_TIMEOUT = 55
    local REEL_DEEP_NUKE_AFTER = 0.45
    local REEL_AUTOPLAY_RS_HOOK_NAME = "MancingIndoReelDeepHack"
    -- Fastest path when server accepts it (often feels instant vs. setupvalue/VIM). Delay uses Instant fishing "Delay (seconds)".
    local REEL_TRY_FAST_REMOTE_COMPLETE = true
    local reelAutoplayLoopRunning = false
    -- MGR Spawn payload (challenge id lives only in the game's Minigames module, not on instances).
    local mgrPendingChallenge = nil :: { id: any, mode: string, hold: number }?
    local mgrReelPendingToken: any = nil
    -- After enabling auto fishing while already in minigame: extra pause once that minigame finishes.
    local autoFishDelay2sAfterPreEnableDrain = false

    -- Last MGR minigame branch seen (StartReel / StartTap); settings UI overrides when available.
    local lastMinigamePreferenceFromMGR: string? = nil
    local settingsMinigameTextConn: RBXScriptConnection? = nil
    local watchedSettingsMinigameLabel: TextLabel? = nil
    local settingsGuiDescendantConn: RBXScriptConnection? = nil

    local function findSettingsMinigamesActionLabel(): TextLabel?
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return nil
        end
        local settingsGui = pg:FindFirstChild("SettingsGui")
        if not (settingsGui and settingsGui:IsA("ScreenGui")) then
            return nil
        end
        local canvas = settingsGui:FindFirstChild("Canvas")
        if not canvas then
            return nil
        end
        local container = canvas:FindFirstChild("Container")
        if not container then
            return nil
        end
        local body = container:FindFirstChild("Body")
        if not body then
            return nil
        end
        local scroll = body:FindFirstChild("ScrollingFrame")
        if not (scroll and scroll:IsA("ScrollingFrame")) then
            return nil
        end
        local minigames = scroll:FindFirstChild("Minigames")
        if not minigames then
            return nil
        end
        local actionBtn = minigames:FindFirstChild("ActionButton")
        if not (actionBtn and actionBtn:IsA("GuiButton")) then
            return nil
        end
        local tl = actionBtn:FindFirstChildOfClass("TextLabel")
        if tl and tl:IsA("TextLabel") then
            return tl
        end
        return nil
    end

    local function tryGetSettingsMinigameLabelText(): string?
        local tl = findSettingsMinigamesActionLabel()
        if not tl then
            return nil
        end
        local t = formatGuiInstanceTextForDisplay(tl)
        return t
    end

    local function classifyMinigameLabel(primary: string): "reel" | "tap" | nil
        local p = string.lower(primary)
        if string.find(p, "tap", 1, true) then
            return "tap"
        end
        if string.find(p, "reel", 1, true) then
            return "reel"
        end
        return nil
    end

    local function getMinigameKindResolved(): "reel" | "tap" | nil
        local guiText = tryGetSettingsMinigameLabelText()
        if guiText and guiText ~= "" then
            local k = classifyMinigameLabel(guiText)
            if k then
                return k
            end
        end
        if lastMinigamePreferenceFromMGR and lastMinigamePreferenceFromMGR ~= "" then
            return classifyMinigameLabel(lastMinigamePreferenceFromMGR)
        end
        return nil
    end

    local function getMinigameKindForAutoSolve(): "reel" | "tap"
        if instantFishingEnabled then
            return "reel"
        end
        return getMinigameKindResolved() or "tap"
    end

    local function disconnectSettingsMinigameLabelWatcher()
        if settingsMinigameTextConn then
            settingsMinigameTextConn:Disconnect()
            settingsMinigameTextConn = nil
        end
        watchedSettingsMinigameLabel = nil
    end

    local function updateAutoFishStatusParagraph()
        local pgRoot = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if pgRoot then
            local sg = pgRoot:FindFirstChild("SettingsGui")
            if sg and sg:IsA("ScreenGui") and not settingsGuiDescendantConn then
                settingsGuiDescendantConn = sg.DescendantAdded:Connect(function()
                    task.defer(updateAutoFishStatusParagraph)
                end)
            end
        end

        local guiText = tryGetSettingsMinigameLabelText()
        local tl = findSettingsMinigamesActionLabel()
        if tl and tl ~= watchedSettingsMinigameLabel then
            disconnectSettingsMinigameLabelWatcher()
            watchedSettingsMinigameLabel = tl
            settingsMinigameTextConn = tl:GetPropertyChangedSignal("Text"):Connect(updateAutoFishStatusParagraph)
        elseif not tl and watchedSettingsMinigameLabel then
            disconnectSettingsMinigameLabelWatcher()
        end

        local primary = (guiText and guiText ~= "") and guiText or nil
        if not primary and lastMinigamePreferenceFromMGR then
            primary = lastMinigamePreferenceFromMGR
        end
        if not primary then
            primary = "Unknown — open SettingsGui (Minigames row) or wait for a bite"
        end
        if AutoFishStatusParagraph and AutoFishStatusParagraph.SetDesc then
            AutoFishStatusParagraph:SetDesc("Minigame: " .. primary)
        end

        local kind = getMinigameKindResolved()
        if AutoFishMinigameSwitchButton and AutoFishMinigameSwitchButton.SetTitle then
            if kind == "reel" then
                AutoFishMinigameSwitchButton:SetTitle("Change Minigame to Tap & Hold")
            elseif kind == "tap" then
                AutoFishMinigameSwitchButton:SetTitle("Change Minigame to Reel")
            else
                AutoFishMinigameSwitchButton:SetTitle("Change Minigame to Reel")
            end
        end
    end

    AutoFishStatusParagraph = AutoFishingSection:Paragraph({
        Title = "Status",
        Desc = "Minigame: …",
    })

    AutoFishMinigameSwitchButton = AutoFishingSection:Button({
        Title = "Change Minigame to Reel",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local k = getMinigameKindResolved()
            local targetRemote = (k == "reel") and "Tap" or "Reel"
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local cp = remotes and remotes:FindFirstChild("ChangePreference")
            if cp and cp:IsA("RemoteEvent") then
                pcall(function()
                    (cp :: RemoteEvent):FireServer(targetRemote)
                end)
            end
            local tl = findSettingsMinigamesActionLabel()
            if tl then
                tl.Text = targetRemote == "Reel" and "Reel" or "Tap & Hold"
            end
            lastMinigamePreferenceFromMGR = targetRemote == "Reel" and "Reel" or "Tap & Hold"
            updateAutoFishStatusParagraph()
        end,
    })

    task.defer(updateAutoFishStatusParagraph)

    local pgForMinigamePref = Players.LocalPlayer:FindFirstChild("PlayerGui")
    if pgForMinigamePref and pgForMinigamePref:IsA("PlayerGui") then
        pgForMinigamePref.ChildAdded:Connect(function()
            task.defer(updateAutoFishStatusParagraph)
        end)
    else
        task.defer(function()
            local pg = Players.LocalPlayer:WaitForChild("PlayerGui", 30)
            if pg and pg:IsA("PlayerGui") then
                pg.ChildAdded:Connect(function()
                    task.defer(updateAutoFishStatusParagraph)
                end)
                updateAutoFishStatusParagraph()
            end
        end)
    end

    task.spawn(function()
        for _ = 1, 8 do
            task.wait(1)
            updateAutoFishStatusParagraph()
        end
    end)

    -- Cosmetic: hide Minigames ScreenGui while still firing MGR (see ensureMinigameAutoSolve).
    local hideMinigameUi = false
    local minigameUiRestoreEnabled = true
    local minigameUiEnforceConn: RBXScriptConnection? = nil
    local minigameUiPlayerGuiConn: RBXScriptConnection? = nil

    local function disconnectMinigameUiEnforce()
        if minigameUiEnforceConn then
            minigameUiEnforceConn:Disconnect()
            minigameUiEnforceConn = nil
        end
    end

    local function disconnectMinigameUiPlayerGui()
        if minigameUiPlayerGuiConn then
            minigameUiPlayerGuiConn:Disconnect()
            minigameUiPlayerGuiConn = nil
        end
    end

    local function applyHideToMinigameScreenGui(mg: ScreenGui)
        disconnectMinigameUiEnforce()
        if not hideMinigameUi then
            return
        end
        minigameUiRestoreEnabled = mg.Enabled
        mg.Enabled = false
        minigameUiEnforceConn = mg:GetPropertyChangedSignal("Enabled"):Connect(function()
            if hideMinigameUi and mg.Parent and mg.Enabled then
                mg.Enabled = false
            end
        end)
    end

    local function refreshMinigameUiHide()
        if not hideMinigameUi then
            return
        end
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return
        end
        local mg = pg:FindFirstChild("Minigames")
        if mg and mg:IsA("ScreenGui") then
            applyHideToMinigameScreenGui(mg)
        end
    end

    local function setMinigameUiHidden(hidden: boolean)
        hideMinigameUi = hidden
        if hidden then
            disconnectMinigameUiPlayerGui()
            local function armPlayerGuiListener(): boolean
                local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
                if not (pg and pg:IsA("PlayerGui")) then
                    return false
                end
                minigameUiPlayerGuiConn = pg.ChildAdded:Connect(function(child)
                    if child.Name == "Minigames" and child:IsA("ScreenGui") then
                        applyHideToMinigameScreenGui(child)
                    end
                end)
                refreshMinigameUiHide()
                return true
            end
            if not armPlayerGuiListener() then
                task.defer(function()
                    if hideMinigameUi then
                        armPlayerGuiListener()
                    end
                end)
            end
            return
        end
        disconnectMinigameUiPlayerGui()
        disconnectMinigameUiEnforce()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if pg then
            local mg = pg:FindFirstChild("Minigames")
            if mg and mg:IsA("ScreenGui") then
                mg.Enabled = minigameUiRestoreEnabled
            end
        end
    end

    -- Tap minigame: MGR "Spawn" then FireServer("Click", challengeId). Reel: VirtualInput E/Q drives
    -- MinigamesReel (same status phases as galatama script; no remote Complete).
    local function releaseMinigameSessionWait()
        local pending = minigameSessionWait
        if not pending then
            return
        end
        minigameSessionWait = nil
        pending.done:Fire()
    end

    local function getMinigamesMgArea(): GuiObject?
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

    -- True when MgArea has a visible challenge clone (siblings of Click/Hold templates).
    local function isFishingMinigameCircleActive(): boolean
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

    local function isReelMinigameActive(): boolean
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return false
        end
        local ru = pg:FindFirstChild("ReelUI")
        if not (ru and ru:IsA("ScreenGui")) then
            return false
        end
        return ru.Enabled
    end

    local function mancingFindNamedDescendant(root: Instance, name: string): Instance?
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

    local function mancingVimKey(isDown: boolean, keyCode: Enum.KeyCode): boolean
        local ok = pcall(function()
            VirtualInputManager:SendKeyEvent(isDown, keyCode, false, game)
        end)
        return ok
    end

    -- Main game: one PlayerGui.ReelUI (Canvas → Bar/Fill, Reel/Handle/Knob, Status).
    local function mancingResolveReelParts(): (ScreenGui?, GuiObject?, GuiObject?, GuiObject?)
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return nil, nil, nil, nil
        end
        local reelUi = pg:FindFirstChild("ReelUI")
        if not (reelUi and reelUi:IsA("ScreenGui") and reelUi.Enabled) then
            return nil, nil, nil, nil
        end
        local canvas = mancingFindNamedDescendant(reelUi, "Canvas")
        if not canvas then
            return reelUi, nil, nil, nil
        end
        local reelFrame = mancingFindNamedDescendant(canvas, "Reel")
        local inner = reelFrame and mancingFindNamedDescendant(reelFrame, "Reel")
        local _handle = inner and mancingFindNamedDescendant(inner, "Handle")
        local bar = mancingFindNamedDescendant(canvas, "Bar")
        local fill = bar and mancingFindNamedDescendant(bar, "Fill")
        local status = mancingFindNamedDescendant(canvas, "Status")
        if status and not (status:IsA("TextLabel") or status:IsA("TextButton")) then
            status = nil
        end
        local f = (fill and fill:IsA("GuiObject")) and (fill :: GuiObject) or nil
        local sgui = (status and status:IsA("GuiObject")) and (status :: GuiObject) or nil
        return reelUi, sgui, nil, f
    end

    -- Executor-only: getconnections + debug. All RenderStepped closures that close over MGR (not only first).
    local reelDeepHookCachedRenderFns: { any } = {}
    local reelDeepHookCachedConns: { any } = {}

    local function mancingExploitGetConnections(sig: RBXScriptSignal): { any }?
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

    local function mancingExploitConnFunction(conn: any): any
        if type(conn) ~= "table" then
            return nil
        end
        return conn.Function or rawget(conn, "f")
    end

    local function mancingFnReferencesInstance(fn: any, inst: Instance): boolean
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
                i += 1
            end
            return false
        end)
        return ok and found == true
    end

    local function mancingReelDeepHackBuildCache(mgr: RemoteEvent): boolean
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

    local function mancingReelDeepHackEnsureCache(mgr: RemoteEvent): boolean
        if #reelDeepHookCachedRenderFns > 0 then
            local f0 = reelDeepHookCachedRenderFns[1]
            if type(f0) == "function" and mancingFnReferencesInstance(f0, mgr) then
                return true
            end
        end
        return mancingReelDeepHackBuildCache(mgr)
    end

    local function mancingReelDeepHackTrySetupvalueU32(fn: any): boolean
        if type(debug) ~= "table" or type(debug.getupvalue) ~= "function" or type(debug.setupvalue) ~= "function" then
            return false
        end
        local candidates: { number } = {}
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
                i += 1
            end
            if #candidates == 1 then
                debug.setupvalue(fn, candidates[1], 1)
                return true
            end
            if #candidates > 1 then
                local _, _, _, fill = mancingResolveReelParts()
                if fill then
                    local target = fill.Size.X.Scale
                    local bestIdx: number? = nil
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
                local maxIdx: number? = nil
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

    local function mancingReelDeepHackTryDisableAndComplete(mgr: RemoteEvent, token: any): boolean
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

    local function mancingReelDeepHackTrySetupvalueWin(mgr: RemoteEvent): boolean
        mancingReelDeepHackEnsureCache(mgr)
        for _, fn in reelDeepHookCachedRenderFns do
            if mancingReelDeepHackTrySetupvalueU32(fn) then
                return true
            end
        end
        return false
    end

    local function mancingReelDeepHackTryNukeComplete(mgr: RemoteEvent): boolean
        return mancingReelDeepHackTryDisableAndComplete(mgr, mgrReelPendingToken)
    end

    local function mancingReelDeepHookClearCache()
        table.clear(reelDeepHookCachedRenderFns)
        table.clear(reelDeepHookCachedConns)
    end

    local function mancingGetReelStatusText(statusGui: GuiObject?): string
        if not statusGui then
            return ""
        end
        local t = ""
        if statusGui:IsA("TextLabel") then
            local lbl = statusGui :: TextLabel
            t = lbl.Text
            if t == "" then
                local okCt, ct = pcall(function()
                    return lbl.ContentText
                end)
                if okCt and type(ct) == "string" then
                    t = ct
                end
            end
        elseif statusGui:IsA("TextButton") then
            local btn = statusGui :: TextButton
            t = btn.Text
            if t == "" then
                local okCt, ct = pcall(function()
                    return btn.ContentText
                end)
                if okCt and type(ct) == "string" then
                    t = ct
                end
            end
        end
        return t
    end

    local function mancingReelStatusRequiresNoKnobSpin(st: string): boolean
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

    local function mancingClassifyReelPhase(st: string): "idle" | "reel_out" | "spin"
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

    local function mancingResolveReelPhase(st: string): "idle" | "reel_out" | "spin"
        if st ~= "" then
            return mancingClassifyReelPhase(st)
        end
        return "spin"
    end

    -- Instant: deep hack (getconnections + debug) + optional fast Complete; always E/Q phase loop. Auto: E/Q only.
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

        local function setE(want: boolean)
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

        local function setQ(want: boolean)
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

        if
            fishingAutomationActive()
            and os.clock() - t0 >= REEL_AUTOPLAY_TIMEOUT
            and isReelMinigameActive()
        then
            warn(
                "[Auto fishing] reel autoplay timed out — need getconnections + debug, VirtualInputManager E/Q, or valid MGR token for nuke Complete."
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
                warn("[Auto fishing] reel autoplay error: ", err)
            end
        end)
    end

    -- Triggers the game's own MGR:FireServer("Click", id) via its GuiButton connections (works when we missed Spawn args).
    local function tryActivateMinigameChallengeUi(): boolean
        local area = getMinigamesMgArea()
        if not area then
            return false
        end
        local mg = area:FindFirstAncestorWhichIsA("ScreenGui")
        local hadToEnableScreenGui = false
        if mg and not mg.Enabled then
            hadToEnableScreenGui = true
            if hideMinigameUi then
                disconnectMinigameUiEnforce()
            end
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
            if hideMinigameUi then
                applyHideToMinigameScreenGui(mg)
            else
                mg.Enabled = false
            end
        end
        return anyOk
    end

    -- Module uses u61(sizeOrFirst, challengeId, mode, hold); server may omit UDim2 and send id as 2nd arg.
    local function parseMgrSpawnPayload(a2: any, a3: any, a4: any, a5: any): (any?, string, number)
        if typeof(a2) == "UDim2" then
            local id = a3
            local mode = typeof(a4) == "string" and a4 or "Click"
            local hold = typeof(a5) == "number" and a5 or 0
            return id, mode, hold
        end
        local id = a2
        local mode = typeof(a3) == "string" and a3 or "Click"
        local hold = typeof(a4) == "number" and a4 or 0
        return id, mode, hold
    end

    local function isValidChallengeId(v: any): boolean
        return typeof(v) == "string" or typeof(v) == "number"
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
        minigameAutoSolveConn = MGR.OnClientEvent:Connect(function(action, a2, a3, a4, a5)
            if action == "StartReel" then
                lastMinigamePreferenceFromMGR = "Reel"
                task.defer(updateAutoFishStatusParagraph)
                if type(a2) == "table" and a2.Token ~= nil then
                    mgrReelPendingToken = a2.Token
                end
            elseif action == "StartTap" then
                lastMinigamePreferenceFromMGR = "Tap & Hold"
                task.defer(updateAutoFishStatusParagraph)
            end

            if action == "Start" then
                mgrPendingChallenge = nil
                mgrReelPendingToken = nil
            elseif action == "Spawn" then
                if getMinigameKindForAutoSolve() ~= "reel" then
                    local challengeId, mode, hold = parseMgrSpawnPayload(a2, a3, a4, a5)
                    if isValidChallengeId(challengeId) then
                        mgrPendingChallenge = {
                            id = challengeId,
                            mode = mode,
                            hold = hold,
                        }
                    end
                end
            elseif action == "Stop" then
                mgrPendingChallenge = nil
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
            if action == "StartReel" and getMinigameKindForAutoSolve() == "reel" then
                task.defer(scheduleMancingReelAutoplayIfNeeded)
                return
            end
            if action ~= "Spawn" then
                return
            end
            if getMinigameKindForAutoSolve() == "reel" then
                return
            end
            local challengeId, mode, hold = parseMgrSpawnPayload(a2, a3, a4, a5)
            if not isValidChallengeId(challengeId) then
                return
            end
            local m = mode
            local holdSec = hold
            task.spawn(function()
                if m == "Hold" and holdSec > 0 then
                    task.wait(holdSec + 0.03)
                else
                    task.wait(0.08)
                end
                if not fishingAutomationActive() then
                    return
                end
                pcall(function()
                    MGR:FireServer("Click", challengeId)
                end)
            end)
        end)
    end

    local function waitForMinigameCleared(reason: string)
        local t0 = os.clock()
        while
            (
                mgrPendingChallenge ~= nil
                or isFishingMinigameCircleActive()
                or mgrReelPendingToken ~= nil
                or isReelMinigameActive()
            )
            and fishingAutomationActive()
            and os.clock() - t0 < MINIGAME_SESSION_TIMEOUT
        do
            task.wait(0.05)
        end
        if
            fishingAutomationActive()
            and os.clock() - t0 >= MINIGAME_SESSION_TIMEOUT
            and (
                mgrPendingChallenge ~= nil
                or mgrReelPendingToken ~= nil
                or isFishingMinigameCircleActive()
                or isReelMinigameActive()
            )
        then
            warn("[Auto fishing] timed out waiting for minigame to end (" .. reason .. ")")
            mgrPendingChallenge = nil
            mgrReelPendingToken = nil
        end
        if fishingAutomationActive() then
            task.wait(0.2)
        end
    end

    local function completeOrWaitMinigameBeforeCast(): boolean
        if not fishingAutomationActive() then
            return false
        end
        ensureMinigameAutoSolve()
        local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
        local MGR = remotesFolder and remotesFolder:FindFirstChild("MGR")
        if not (MGR and MGR:IsA("RemoteEvent")) then
            return false
        end

        if getMinigameKindForAutoSolve() == "reel" then
            if mgrReelPendingToken ~= nil or isReelMinigameActive() then
                task.defer(scheduleMancingReelAutoplayIfNeeded)
                waitForMinigameCleared("reel E/Q autoplay drain")
                return true
            end
        end

        local pending = mgrPendingChallenge
        if pending then
            local m = pending.mode
            local holdSec = pending.hold
            if m == "Hold" and holdSec > 0 then
                task.wait(holdSec + 0.03)
            else
                task.wait(0.08)
            end
            if not fishingAutomationActive() then
                return false
            end
            pcall(function()
                MGR:FireServer("Click", pending.id)
            end)
            waitForMinigameCleared("after MGR Click (snapshot)")
            return true
        end

        if isFishingMinigameCircleActive() then
            task.wait(0.05)
            if not fishingAutomationActive() then
                return false
            end
            tryActivateMinigameChallengeUi()
            local tManual = os.clock()
            while isFishingMinigameCircleActive() and mgrPendingChallenge == nil and fishingAutomationActive() and os.clock() - tManual < 0.35 do
                task.wait(0.05)
            end
            if isFishingMinigameCircleActive() or mgrPendingChallenge ~= nil then
                waitForMinigameCleared("after UI Activate fallback")
            else
                if fishingAutomationActive() then
                    task.wait(0.2)
                end
            end
            return true
        end

        if mgrPendingChallenge ~= nil then
            waitForMinigameCleared("pending without circle")
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

    local function playerHasFishingRodEquipped(): boolean
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
        pcall(function()
            CMGR:FireServer("Result", 1)
        end)
    end

    local function runFishingCycleImpl(
        equipWait: number,
        castToCmgrWait: number,
        afterMinigameWait: number,
        afterDrainWait: number
    ): boolean
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
        minigameCycleSeq += 1
        local cycleSeq = minigameCycleSeq

        if not playerHasFishingRodEquipped() then
            equipFishingRodRemote()
            task.wait(equipWait)
        end
        castFishingRodRemote()
        task.wait(castToCmgrWait)
        setFishingCastResultRemote()

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

    local function runAutoFishingCycleImpl(): boolean
        return runFishingCycleImpl(0.2, 1, 2.5, 2)
    end

    local function runInstantFishingCycleImpl(): boolean
        return runFishingCycleImpl(0.12, 0.18, 2, 0.25)
    end

    local function runAutoFishingCycle()
        autoFishingCycleRunning = true
        local ok, res = pcall(runAutoFishingCycleImpl)
        autoFishingCycleRunning = false
        if not ok then
            warn("[Auto fishing] cycle error: ", res)
            return false
        end
        return res
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

    local function runAutoFishingLoop()
        while autoFishingEnabled do
            while autoFishingPausedForSell and autoFishingEnabled do
                task.wait(0.05)
            end
            if not autoFishingEnabled then
                break
            end
            if not runAutoFishingCycle() then
                task.wait(0.5)
            end
        end
        autoFishingLoopRunning = false
    end

    local function runInstantFishingLoop()
        while instantFishingEnabled do
            while autoFishingPausedForSell and instantFishingEnabled do
                task.wait(0.05)
            end
            if not instantFishingEnabled then
                break
            end
            if not runInstantFishingCycle() then
                task.wait(0.25)
            end
        end
        instantFishingLoopRunning = false
    end

    local function ensureMinigamePreferenceIsReel()
        if getMinigameKindResolved() == "reel" then
            return
        end
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local cp = remotes and remotes:FindFirstChild("ChangePreference")
        if cp and cp:IsA("RemoteEvent") then
            pcall(function()
                (cp :: RemoteEvent):FireServer("Reel")
            end)
        end
        local tl = findSettingsMinigamesActionLabel()
        if tl then
            tl.Text = "Reel"
        end
        lastMinigamePreferenceFromMGR = "Reel"
        task.defer(updateAutoFishStatusParagraph)
    end

    AutoFishingSection:Toggle({
        Title = "Auto fishing",
        Desc = "Finishes an in-progress MGR minigame first if needed, then equip/cast/CMGR/MGR as usual",
        Value = false,
        Callback = function(enabled)
            autoFishingEnabled = enabled
            if enabled then
                instantFishingArmSeq += 1
                instantFishingEnabled = false
                releaseMinigameSessionWait()
                ensureMinigameAutoSolve()
                autoFishDelay2sAfterPreEnableDrain = mgrPendingChallenge ~= nil
                    or isFishingMinigameCircleActive()
                    or mgrReelPendingToken ~= nil
                    or isReelMinigameActive()
            else
                releaseMinigameSessionWait()
                autoFishingPausedForSell = false
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

    AutoFishingSection:Toggle({
        Title = "Hide minigame UI",
        Desc = "Hides PlayerGui Minigames (circle still runs; MGR auto-solve unchanged)",
        Value = false,
        Callback = function(enabled)
            setMinigameUiHidden(enabled)
        end,
    })

    MainTab:Space()

    local InstantFishingSection = MainTab:Section({
        Title = "Instant fishing",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    InstantFishingSection:Input({
        Title = "Delay (seconds)",
        Placeholder = "e.g. 0.5",
        Value = tostring(instantFishingDelaySec),
        Callback = function(value)
            local n = tonumber(value)
            if n and n >= 0 then
                instantFishingDelaySec = n
            end
        end,
    })

    InstantFishingSection:Toggle({
        Title = "Instant fishing",
        Desc = "If minigame is not Reel, switches to Reel first; then fast cast/reel loop. Turns off Auto fishing. Delay is the wait after each minigame.",
        Value = false,
        Callback = function(enabled)
            if enabled then
                autoFishingEnabled = false
                releaseMinigameSessionWait()
                instantFishingArmSeq += 1
                local armSeq = instantFishingArmSeq
                task.spawn(function()
                    ensureMinigamePreferenceIsReel()
                    task.wait(0.15)
                    if armSeq ~= instantFishingArmSeq then
                        return
                    end
                    instantFishingEnabled = true
                    ensureMinigameAutoSolve()
                    autoFishDelay2sAfterPreEnableDrain = mgrPendingChallenge ~= nil
                        or isFishingMinigameCircleActive()
                        or mgrReelPendingToken ~= nil
                        or isReelMinigameActive()
                    if instantFishingLoopRunning then
                        return
                    end
                    instantFishingLoopRunning = true
                    runInstantFishingLoop()
                end)
            else
                instantFishingArmSeq += 1
                instantFishingEnabled = false
                releaseMinigameSessionWait()
                autoFishDelay2sAfterPreEnableDrain = false
                if not autoFishingEnabled then
                    autoFishingPausedForSell = false
                end
            end
        end,
    })

    task.defer(ensureMinigameAutoSolve)
    
    MainTab:Space()

    local SellSection = MainTab:Section({
        Title = "Sell",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local sellMode = "Loop"
    local sellIntervalSeconds = 60
    local autoSellEnabled = false
    local autoSellLoopRunning = false
    local SELL_TELEPORT_CFRAME = CFrame.new(2621.24, -0.11, -911.08)

    -- Fish sell tools use attribute UID (see in-game buyer dialog); rods use FishingRod.
    local function playerBackpackHasFish()
        local lp = Players.LocalPlayer
        local bp = lp:FindFirstChild("Backpack")
        if not (bp and bp:IsA("Backpack")) then
            return false
        end
        for _, child in ipairs(bp:GetChildren()) do
            if child:IsA("Tool") and child:GetAttribute("FishingRod") == nil and child:GetAttribute("UID") ~= nil then
                return true
            end
        end
        return false
    end

    local function fireSellFishAll()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then
            return
        end
        local sellFish = remotes:FindFirstChild("SellFish")
        if not (sellFish and sellFish:IsA("RemoteEvent")) then
            return
        end
        pcall(function()
            sellFish:FireServer("All")
        end)
    end

    local function runAutoSellTeleportSellAndReturn()
        if not playerBackpackHasFish() then
            return
        end
        local character = Players.LocalPlayer.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        local previousCFrame = nil
        local restoreAssist = nil
        if type(autoSellTripAssist.begin) == "function" then
            restoreAssist = autoSellTripAssist.begin()
        end
        pcall(function()
            if root then
                previousCFrame = root.CFrame
                root.CFrame = SELL_TELEPORT_CFRAME
                task.wait(1)
            end
            fireSellFishAll()
            task.wait(1)
            if root and previousCFrame and root.Parent then
                root.CFrame = previousCFrame
            end
        end)
        if restoreAssist then
            pcall(restoreAssist)
        end
    end

    -- If auto fishing is on: wait for current cycle (including MGR minigame) to finish, pause fishing, sell, resume.
    local function runAutoSellWithFishingCoordination()
        local pauseRequested = false
        if autoFishingEnabled or instantFishingEnabled then
            autoFishingPausedForSell = true
            pauseRequested = true
            while autoFishingCycleRunning or instantFishingCycleRunning do
                if not autoSellEnabled then
                    autoFishingPausedForSell = false
                    return
                end
                task.wait(0.05)
            end
        end
        if not autoSellEnabled then
            if pauseRequested then
                autoFishingPausedForSell = false
            end
            return
        end
        runAutoSellTeleportSellAndReturn()
        if pauseRequested then
            task.wait(1)
            autoFishingPausedForSell = false
        end
    end

    SellSection:Dropdown({
        Title = "Sell type",
        Desc = "More modes can be added later",
        Values = { "Loop" },
        Value = "Loop",
        Callback = function(value)
            sellMode = value or "Loop"
        end,
    })

    SellSection:Input({
        Title = "Duration (seconds)",
        Placeholder = "e.g. 60",
        Value = tostring(sellIntervalSeconds),
        Callback = function(value)
            local n = tonumber(value)
            if n and n >= 0 then
                sellIntervalSeconds = n
            end
        end,
    })

    SellSection:Toggle({
        Title = "Auto Sell",
        Desc = "If Backpack has no fish (fish Tool with UID), skips. Else enables fly + no clip for the trip, teleports underground to sell, SellFish \"All\", returns and restores prior fly/no clip. Auto fishing: waits for minigame, pauses, sells, 1s after return resumes",
        Value = false,
        Callback = function(enabled)
            autoSellEnabled = enabled
            if not enabled then
                return
            end
            if autoSellLoopRunning then
                return
            end
            autoSellLoopRunning = true
            task.spawn(function()
                while autoSellEnabled do
                    if sellMode == "Loop" then
                        runAutoSellWithFishingCoordination()
                    end
                    local dur = math.max(sellIntervalSeconds, 0.05)
                    task.wait(dur)
                end
                autoSellLoopRunning = false
            end)
        end,
    })
    
    MainTab:Space()

    local SpawnBoatSection = MainTab:Section({
        Title = "Spawn Boat",
        Desc = "Owned boats are rows in the boat shop whose Price label is Owned. Spawn uses Remotes.SpawnBoat.",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local spawnBoatOwnedIds = {}
    local spawnBoatDisplayList = {}
    local spawnBoatIdList = {}
    local selectedSpawnBoatId = nil
    local SpawnBoatDropdown

    local function getSpawnBoatShopScrollingFrame()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return nil
        end
        local gui = pg:FindFirstChild("BoatUI")
        if not gui then
            return nil
        end
        local canvas = gui:FindFirstChild("Canvas")
        local container = canvas and canvas:FindFirstChild("Container")
        local body = container and container:FindFirstChild("Body")
        return body and body:FindFirstChild("ScrollingFrame")
    end

    local function spawnBoatPriceLabelPlainText(priceLab)
        if not (priceLab and priceLab:IsA("TextLabel")) then
            return ""
        end
        local t = priceLab.Text
        local ok, ct = pcall(function()
            return priceLab.ContentText
        end)
        if ok and typeof(ct) == "string" and ct ~= "" then
            t = ct
        end
        t = t:gsub("\r\n", " "):gsub("\n", " ")
        return (t:match("^%s*(.-)%s*$") or t)
    end

    local function isSpawnBoatShopRowOwned(row)
        local price = row:FindFirstChild("Price")
        return string.lower(spawnBoatPriceLabelPlainText(price)) == "owned"
    end

    local function collectOwnedBoatIdsFromShop()
        spawnBoatOwnedIds = {}
        local scroll = getSpawnBoatShopScrollingFrame()
        if not scroll then
            return
        end
        for _, child in ipairs(scroll:GetChildren()) do
            if (child:IsA("Frame") or child:IsA("TextButton")) and not child.Name:match("_Information$") then
                if isSpawnBoatShopRowOwned(child) then
                    table.insert(spawnBoatOwnedIds, child.Name)
                end
            end
        end
    end

    local function spawnBoatDisplayNameForId(boatId)
        if not boatId or boatId == "" then
            return boatId
        end
        local scroll = getSpawnBoatShopScrollingFrame()
        if not scroll then
            return boatId
        end
        local row = scroll:FindFirstChild(boatId)
        if row and (row:IsA("Frame") or row:IsA("TextButton")) then
            local nm = row:FindFirstChild("BoatName")
            if nm and nm:IsA("TextLabel") and nm.Text ~= "" then
                return nm.Text
            end
        end
        return boatId
    end

    local function refreshSpawnBoatDropdown()
        collectOwnedBoatIdsFromShop()
        spawnBoatDisplayList = {}
        spawnBoatIdList = {}
        local sorted = {}
        for _, id in ipairs(spawnBoatOwnedIds) do
            table.insert(sorted, id)
        end
        table.sort(sorted)
        for _, id in ipairs(sorted) do
            if typeof(id) == "string" and id ~= "" then
                local disp = spawnBoatDisplayNameForId(id)
                table.insert(spawnBoatIdList, id)
                table.insert(spawnBoatDisplayList, disp .. " — " .. id)
            end
        end
        if SpawnBoatDropdown and SpawnBoatDropdown.Refresh then
            SpawnBoatDropdown:Refresh(spawnBoatDisplayList)
        end
        if selectedSpawnBoatId and not table.find(spawnBoatIdList, selectedSpawnBoatId) then
            selectedSpawnBoatId = nil
            if SpawnBoatDropdown and SpawnBoatDropdown.Select then
                SpawnBoatDropdown:Select(nil)
            end
            if SpawnBoatDropdown and SpawnBoatDropdown.Set then
                SpawnBoatDropdown:Set(nil)
            end
        end
    end

    SpawnBoatDropdown = SpawnBoatSection:Dropdown({
        Title = "Owned boat",
        Desc = "Only boats whose shop row Price is Owned (BoatUI Body.ScrollingFrame)",
        Values = spawnBoatDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(value)
            selectedSpawnBoatId = nil
            if value then
                local idx = table.find(spawnBoatDisplayList, value)
                if idx and spawnBoatIdList[idx] then
                    selectedSpawnBoatId = spawnBoatIdList[idx]
                end
            end
        end,
    })

    SpawnBoatSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshSpawnBoatDropdown()
            local n = #spawnBoatIdList
            WindUI:Notify({
                Title = "Spawn Boat",
                Content = (n == 0) and "No rows with Price = Owned (open BoatUI shop so templates load, then Refresh)"
                    or ("Updated list (" .. n .. " owned)"),
                Icon = (n == 0) and "x" or "check",
            })
        end,
    })

    SpawnBoatSection:Button({
        Title = "Spawn",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedSpawnBoatId or selectedSpawnBoatId == "" then
                WindUI:Notify({ Title = "Spawn Boat", Content = "Select an owned boat from the dropdown first", Icon = "x" })
                return
            end
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if not remotes then
                WindUI:Notify({ Title = "Spawn Boat", Content = "Remotes folder not found", Icon = "x" })
                return
            end
            local spawnBoat = remotes:FindFirstChild("SpawnBoat")
            if not (spawnBoat and spawnBoat:IsA("RemoteFunction")) then
                WindUI:Notify({ Title = "Spawn Boat", Content = "Remotes.SpawnBoat not found", Icon = "x" })
                return
            end
            local ok, success, errMsg = pcall(function()
                return spawnBoat:InvokeServer(selectedSpawnBoatId)
            end)
            if not ok then
                WindUI:Notify({ Title = "Spawn Boat", Content = "Invoke failed: " .. tostring(success), Icon = "x" })
                return
            end
            if success then
                WindUI:Notify({ Title = "Spawn Boat", Content = "Spawn requested", Icon = "check" })
            else
                WindUI:Notify({
                    Title = "Spawn Boat",
                    Content = (typeof(errMsg) == "string" and errMsg ~= "" and errMsg) or "Spawn failed",
                    Icon = "x",
                })
            end
        end,
    })

    task.defer(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:WaitForChild("Remotes", 30)
        if remotes then
            local ownedBoats = remotes:FindFirstChild("OwnedBoats")
            if ownedBoats and ownedBoats:IsA("RemoteEvent") then
                ownedBoats.OnClientEvent:Connect(function()
                    task.defer(refreshSpawnBoatDropdown)
                end)
            end
        end
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui") or Players.LocalPlayer:WaitForChild("PlayerGui", 15)
        if pg then
            pg.ChildAdded:Connect(function(child)
                if child.Name == "BoatUI" then
                    refreshSpawnBoatDropdown()
                end
            end)
        end
    end)
end

-- */  Event Tab  /* --
do
    local EventTab = ElementsSection:Tab({
        Title = "Event",
        Icon = "solar:calendar-mark-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    local GalatamaSection = EventTab:Section({
        Title = "Galatama",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    GalatamaSection:Button({
        Title = "Join Queue",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if not remotes then
                WindUI:Notify({ Title = "Galatama", Content = "Remotes folder not found", Icon = "x" })
                return
            end
            local evt = remotes:FindFirstChild("JoinGalatamaQueue")
            if not (evt and evt:IsA("RemoteEvent")) then
                WindUI:Notify({ Title = "Galatama", Content = "JoinGalatamaQueue remote not found", Icon = "x" })
                return
            end
            local ok, err = pcall(function()
                evt:FireServer()
            end)
            if not ok then
                WindUI:Notify({ Title = "Galatama", Content = "FireServer failed: " .. tostring(err), Icon = "x" })
            end
        end,
    })
    
    GalatamaSection:Space()

    GalatamaSection:Button({
        Title = "Leave Queue",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if not remotes then
                WindUI:Notify({ Title = "Galatama", Content = "Remotes folder not found", Icon = "x" })
                return
            end
            local evt = remotes:FindFirstChild("LeaveGalatamaQueue")
            if not (evt and evt:IsA("RemoteEvent")) then
                WindUI:Notify({ Title = "Galatama", Content = "LeaveGalatamaQueue remote not found", Icon = "x" })
                return
            end
            local ok, err = pcall(function()
                evt:FireServer()
            end)
            if not ok then
                WindUI:Notify({ Title = "Galatama", Content = "FireServer failed: " .. tostring(err), Icon = "x" })
            end
        end,
    })
end

-- */  Shop Tab  /* --
do
    local ShopTab = ElementsSection:Tab({
        Title = "Shop",
        Icon = "solar:shop-2-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    local BuyRodSection = ShopTab:Section({
        Title = "Buy Rod",
        Desc = "Rods are read from FishingRodShopGui. Use Refresh if the list is empty.",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    -- Parallel lists: dropdown shows rodDisplayList; Buy uses rodIdList[index].
    local rodDisplayList = {}
    local rodIdList = {}
    local selectedRodId = nil
    local BuyRodDropdown
    local BuyRodDetailParagraph

    local function getRodShopScrollingFrame()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return nil
        end
        local gui = pg:FindFirstChild("FishingRodShopGui")
        if not gui then
            return nil
        end
        local canvas = gui:FindFirstChild("Canvas")
        local container = canvas and canvas:FindFirstChild("Container")
        local body = container and container:FindFirstChild("Body")
        return body and body:FindFirstChild("ScrollingFrame")
    end

    local function findRodFrame(rodId)
        if not rodId or rodId == "" then
            return nil
        end
        local scroll = getRodShopScrollingFrame()
        if not scroll then
            return nil
        end
        local f = scroll:FindFirstChild(rodId)
        if f and f:IsA("Frame") then
            return f
        end
        return nil
    end

    local function priceLabelForRodFrame(frame)
        local attr = frame:GetAttribute("PriceLabel")
        if typeof(attr) == "string" and attr ~= "" then
            return attr
        end
        local purchaseBtn = frame:FindFirstChild("PurchaseButton")
        if purchaseBtn then
            local tl = purchaseBtn:FindFirstChildOfClass("TextLabel")
            if tl and tl.Text ~= "" and tl.Text ~= "..." then
                return tl.Text
            end
            if purchaseBtn:IsA("TextButton") and purchaseBtn.Text ~= "" and purchaseBtn.Text ~= "..." then
                return purchaseBtn.Text
            end
        end
        return "?"
    end

    local function textLabelPlainText(lab)
        if lab:IsA("TextLabel") then
            local ok, ct = pcall(function()
                return lab.ContentText
            end)
            if ok and typeof(ct) == "string" and ct ~= "" then
                return ct
            end
        end
        return lab.Text
    end

    -- Avoid "TopSpeed: Top Speed: 54" or "Speed: Speed 6%"; keep "Rarity: Uncommon".
    local function formatShopStatLine(instanceName, rawText)
        if typeof(rawText) ~= "string" then
            return nil
        end
        local text = rawText:gsub("\r\n", " "):gsub("\n", " ")
        text = text:match("^%s*(.-)%s*$") or text
        if text == "" or text == "..." then
            return nil
        end
        local nm = instanceName
        if nm == "TextLabel" or nm == "Label" then
            return "  • " .. text
        end
        if text:find(":") then
            return "  • " .. text
        end
        local lowerNm = string.lower(nm)
        local lowerText = string.lower(text)
        local escaped = lowerNm:gsub("%%", "%%%%"):gsub("(%W)", "%%%1")
        if lowerText:match("^" .. escaped .. "%s+") or lowerText == escaped then
            return "  • " .. text
        end
        if nm == "Rarity" then
            return "  • Rarity: " .. text
        end
        return "  " .. nm .. ": " .. text
    end

    local function buildRodDetailText(rodId)
        if not rodId or rodId == "" then
            return "Select a rod from the dropdown to see name, price, and statistics."
        end
        local frame = findRodFrame(rodId)
        if not frame then
            return "Rod row \"" .. rodId .. "\" was not found. Use Refresh or open the in-game rod shop."
        end
        local price = priceLabelForRodFrame(frame)
        local lines = {}
        table.insert(lines, "Rod name: " .. rodId)
        table.insert(lines, "Price: " .. price)
        table.insert(lines, "")

        local purchaseBtn = frame:FindFirstChild("PurchaseButton")

        local function appendAttributes(inst, prefix)
            local attrs = {}
            pcall(function()
                attrs = inst:GetAttributes()
            end)
            local keys = {}
            for k in pairs(attrs) do
                table.insert(keys, k)
            end
            table.sort(keys)
            local out = {}
            for _, k in ipairs(keys) do
                table.insert(out, { key = prefix .. k, val = tostring(attrs[k]) })
            end
            return out
        end

        local attrRows = {}
        for _, row in ipairs(appendAttributes(frame, "")) do
            table.insert(attrRows, row)
        end
        if purchaseBtn then
            for _, row in ipairs(appendAttributes(purchaseBtn, "purchase.")) do
                table.insert(attrRows, row)
            end
        end
        if #attrRows > 0 then
            table.insert(lines, "Attributes:")
            for _, row in ipairs(attrRows) do
                table.insert(lines, "  " .. row.key .. ": " .. row.val)
            end
            table.insert(lines, "")
        end

        local seenLabel = {}
        local statLines = {}
        for _, desc in ipairs(frame:GetDescendants()) do
            if desc:IsA("TextLabel") then
                if purchaseBtn and desc:IsDescendantOf(purchaseBtn) then
                    continue
                end
                local nm = desc.Name
                if nm == "FishingRodName" then
                    continue
                end
                local t = textLabelPlainText(desc)
                local line = formatShopStatLine(nm, t)
                if not line then
                    continue
                end
                local key = nm .. "\0" .. line
                if seenLabel[key] then
                    continue
                end
                seenLabel[key] = true
                table.insert(statLines, line)
            end
        end
        if #statLines > 0 then
            table.insert(lines, "Statistics:")
            for _, L in ipairs(statLines) do
                table.insert(lines, L)
            end
        elseif #attrRows == 0 then
            table.insert(lines, "No stat labels or extra attributes on this row.")
        end

        return table.concat(lines, "\n")
    end

    local function updateBuyRodDetailParagraph()
        if BuyRodDetailParagraph and BuyRodDetailParagraph.SetDesc then
            BuyRodDetailParagraph:SetDesc(buildRodDetailText(selectedRodId))
        end
    end

    local function getRodRowsFromShopGui()
        local scroll = getRodShopScrollingFrame()
        if not scroll then
            return {}
        end
        local rows = {}
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") then
                local id = child.Name
                local price = priceLabelForRodFrame(child)
                table.insert(rows, {
                    id = id,
                    display = id .. " (" .. price .. ")",
                })
            end
        end
        table.sort(rows, function(a, b)
            return a.id < b.id
        end)
        return rows
    end

    local function refreshRodList(showNotify)
        local rows = getRodRowsFromShopGui()
        rodDisplayList = {}
        rodIdList = {}
        for _, r in ipairs(rows) do
            table.insert(rodDisplayList, r.display)
            table.insert(rodIdList, r.id)
        end
        if BuyRodDropdown and BuyRodDropdown.Refresh then
            BuyRodDropdown:Refresh(rodDisplayList)
        end
        if selectedRodId and not table.find(rodIdList, selectedRodId) then
            selectedRodId = nil
            if BuyRodDropdown and BuyRodDropdown.Select then
                BuyRodDropdown:Select(nil)
            end
            if BuyRodDropdown and BuyRodDropdown.Set then
                BuyRodDropdown:Set(nil)
            end
        end
        updateBuyRodDetailParagraph()
        if showNotify then
            WindUI:Notify({
                Title = "Buy Rod",
                Content = (#rodIdList == 0) and "No rods found (open the in-game rod shop once or wait for UI to load)" or ("Found " .. #rodIdList .. " rod(s)"),
                Icon = (#rodIdList == 0) and "x" or "check",
            })
        end
    end

    BuyRodDropdown = BuyRodSection:Dropdown({
        Title = "Rod",
        Desc = "Name and price from the rod shop row (PriceLabel or button text)",
        Values = rodDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(value)
            selectedRodId = nil
            if value then
                local idx = table.find(rodDisplayList, value)
                if idx and rodIdList[idx] then
                    selectedRodId = rodIdList[idx]
                end
            end
            updateBuyRodDetailParagraph()
        end,
    })

    BuyRodDetailParagraph = BuyRodSection:Paragraph({
        Title = "Rod details",
        Desc = "Select a rod from the dropdown to see name, price, and statistics.",
    })

    BuyRodSection:Button({
        Title = "Buy",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedRodId or selectedRodId == "" then
                WindUI:Notify({ Title = "Buy Rod", Content = "Select a rod from the dropdown first", Icon = "x" })
                return
            end
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local purchaseRod = remotes and remotes:FindFirstChild("PurchaseRod")
            if not (purchaseRod and purchaseRod:IsA("RemoteFunction")) then
                WindUI:Notify({ Title = "Buy Rod", Content = "Remotes.PurchaseRod not found", Icon = "x" })
                return
            end
            local ok, result = pcall(function()
                return purchaseRod:InvokeServer(selectedRodId)
            end)
            if not ok then
                WindUI:Notify({ Title = "Buy Rod", Content = "Invoke failed: " .. tostring(result), Icon = "x" })
                return
            end
            if result and result.IsGamepass and result.GamepassId then
                pcall(function()
                    MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, result.GamepassId)
                end)
                WindUI:Notify({ Title = "Buy Rod", Content = "Game pass purchase prompted", Icon = "check" })
            elseif result and result.Success then
                WindUI:Notify({ Title = "Buy Rod", Content = "Purchase successful", Icon = "check" })
            else
                WindUI:Notify({
                    Title = "Buy Rod",
                    Content = (result and result.Message) or "Purchase failed",
                    Icon = "x",
                })
            end
            task.defer(updateBuyRodDetailParagraph)
        end,
    })

    BuyRodSection:Space()

    BuyRodSection:Button({
        Title = "Refresh rod list",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshRodList(true)
        end,
    })

    ShopTab:Space()

    local BuyBoatSection = ShopTab:Section({
        Title = "Buy Boat",
        Desc = "Boats are read from BoatUI (Body.ScrollingFrame). Use Refresh if the list is empty.",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local boatDisplayList = {}
    local boatIdList = {}
    local selectedBoatId = nil
    local BuyBoatDropdown
    local BuyBoatDetailParagraph

    local function getBoatShopBody()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return nil
        end
        local gui = pg:FindFirstChild("BoatUI")
        if not gui then
            return nil
        end
        local canvas = gui:FindFirstChild("Canvas")
        local container = canvas and canvas:FindFirstChild("Container")
        return container and container:FindFirstChild("Body")
    end

    local function getBoatShopScrollingFrame()
        local body = getBoatShopBody()
        return body and body:FindFirstChild("ScrollingFrame")
    end

    local function findBoatRow(boatId)
        if not boatId or boatId == "" then
            return nil
        end
        local scroll = getBoatShopScrollingFrame()
        if not scroll then
            return nil
        end
        local row = scroll:FindFirstChild(boatId)
        if row and (row:IsA("Frame") or row:IsA("TextButton")) then
            return row
        end
        return nil
    end

    local function boatDisplayNameForRow(row)
        local nm = row:FindFirstChild("BoatName")
        if nm and nm:IsA("TextLabel") and nm.Text ~= "" then
            return nm.Text
        end
        return row.Name
    end

    local function priceLabelForBoatRow(row)
        local price = row:FindFirstChild("Price")
        if price and price:IsA("TextLabel") and price.Text ~= "" and price.Text ~= "..." then
            return price.Text
        end
        return "?"
    end

    local function buildBoatDetailText(boatId)
        if not boatId or boatId == "" then
            return "Select a boat from the dropdown to see name, price, and statistics."
        end
        local row = findBoatRow(boatId)
        if not row then
            return "Boat row \"" .. boatId .. "\" was not found. Use Refresh or open the in-game boat shop."
        end
        local displayName = boatDisplayNameForRow(row)
        local price = priceLabelForBoatRow(row)
        local lines = {}
        table.insert(lines, "Display name: " .. displayName)
        table.insert(lines, "Boat id: " .. boatId)
        table.insert(lines, "Price: " .. price)
        table.insert(lines, "")

        local body = getBoatShopBody()
        local infoFrame = body and body:FindFirstChild(boatId .. "_Information")
        local purchaseBtn = infoFrame and (infoFrame:FindFirstChild("PurchaseButton") or infoFrame:FindFirstChild("ActionButton"))

        local statNames = { "Rarity", "Passengers", "TopSpeed", "Acceleration", "Handling" }
        local namedStats = {}
        for _, statName in ipairs(statNames) do
            local lab = row:FindFirstChild(statName)
            if not (lab and lab:IsA("TextLabel")) then
                lab = row:FindFirstChild(statName, true)
            end
            if not (lab and lab:IsA("TextLabel")) and infoFrame then
                lab = infoFrame:FindFirstChild(statName)
                if not (lab and lab:IsA("TextLabel")) then
                    lab = infoFrame:FindFirstChild(statName, true)
                end
            end
            if lab and lab:IsA("TextLabel") then
                local t = textLabelPlainText(lab)
                local line = formatShopStatLine(statName, t)
                if line then
                    table.insert(namedStats, line)
                end
            end
        end
        if #namedStats > 0 then
            table.insert(lines, "Statistics:")
            for _, L in ipairs(namedStats) do
                table.insert(lines, L)
            end
            table.insert(lines, "")
        end

        local function appendAttributes(inst, prefix)
            local attrs = {}
            pcall(function()
                attrs = inst:GetAttributes()
            end)
            local keys = {}
            for k in pairs(attrs) do
                table.insert(keys, k)
            end
            table.sort(keys)
            local out = {}
            for _, k in ipairs(keys) do
                table.insert(out, { key = prefix .. k, val = tostring(attrs[k]) })
            end
            return out
        end

        local attrRows = {}
        for _, ar in ipairs(appendAttributes(row, "row.")) do
            table.insert(attrRows, ar)
        end
        if infoFrame then
            for _, ar in ipairs(appendAttributes(infoFrame, "info.")) do
                table.insert(attrRows, ar)
            end
        end
        if purchaseBtn then
            for _, ar in ipairs(appendAttributes(purchaseBtn, "purchase.")) do
                table.insert(attrRows, ar)
            end
        end
        if #attrRows > 0 then
            table.insert(lines, "Attributes:")
            for _, ar in ipairs(attrRows) do
                table.insert(lines, "  " .. ar.key .. ": " .. ar.val)
            end
            table.insert(lines, "")
        end

        if #namedStats == 0 and #attrRows == 0 then
            table.insert(lines, "No statistics or attributes on this boat.")
        end

        return table.concat(lines, "\n")
    end

    local function updateBuyBoatDetailParagraph()
        if BuyBoatDetailParagraph and BuyBoatDetailParagraph.SetDesc then
            BuyBoatDetailParagraph:SetDesc(buildBoatDetailText(selectedBoatId))
        end
    end

    local function getBoatRowsFromShopGui()
        local scroll = getBoatShopScrollingFrame()
        if not scroll then
            return {}
        end
        local rows = {}
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                local id = child.Name
                if not id:match("_Information$") then
                    local disp = boatDisplayNameForRow(child)
                    local price = priceLabelForBoatRow(child)
                    table.insert(rows, {
                        id = id,
                        display = disp .. " — " .. id .. " (" .. price .. ")",
                    })
                end
            end
        end
        table.sort(rows, function(a, b)
            return a.id < b.id
        end)
        return rows
    end

    local function refreshBoatList(showNotify)
        local rows = getBoatRowsFromShopGui()
        boatDisplayList = {}
        boatIdList = {}
        for _, r in ipairs(rows) do
            table.insert(boatDisplayList, r.display)
            table.insert(boatIdList, r.id)
        end
        if BuyBoatDropdown and BuyBoatDropdown.Refresh then
            BuyBoatDropdown:Refresh(boatDisplayList)
        end
        if selectedBoatId and not table.find(boatIdList, selectedBoatId) then
            selectedBoatId = nil
            if BuyBoatDropdown and BuyBoatDropdown.Select then
                BuyBoatDropdown:Select(nil)
            end
            if BuyBoatDropdown and BuyBoatDropdown.Set then
                BuyBoatDropdown:Set(nil)
            end
        end
        updateBuyBoatDetailParagraph()
        if showNotify then
            WindUI:Notify({
                Title = "Buy Boat",
                Content = (#boatIdList == 0) and "No boats found (open the in-game boat shop once or wait for UI to load)" or ("Found " .. #boatIdList .. " boat(s)"),
                Icon = (#boatIdList == 0) and "x" or "check",
            })
        end
    end

    BuyBoatDropdown = BuyBoatSection:Dropdown({
        Title = "Boat",
        Desc = "Display name, id, and price from the boat shop row (BoatName / Price labels)",
        Values = boatDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(value)
            selectedBoatId = nil
            if value then
                local idx = table.find(boatDisplayList, value)
                if idx and boatIdList[idx] then
                    selectedBoatId = boatIdList[idx]
                end
            end
            updateBuyBoatDetailParagraph()
        end,
    })

    BuyBoatDetailParagraph = BuyBoatSection:Paragraph({
        Title = "Boat details",
        Desc = "Select a boat from the dropdown to see name, price, and statistics.",
    })

    BuyBoatSection:Button({
        Title = "Buy",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedBoatId or selectedBoatId == "" then
                WindUI:Notify({ Title = "Buy Boat", Content = "Select a boat from the dropdown first", Icon = "x" })
                return
            end
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local purchaseBoat = remotes and remotes:FindFirstChild("PurchaseBoat")
            if not (purchaseBoat and purchaseBoat:IsA("RemoteFunction")) then
                WindUI:Notify({ Title = "Buy Boat", Content = "Remotes.PurchaseBoat not found", Icon = "x" })
                return
            end
            local ok, result = pcall(function()
                return purchaseBoat:InvokeServer(selectedBoatId)
            end)
            if not ok then
                WindUI:Notify({ Title = "Buy Boat", Content = "Invoke failed: " .. tostring(result), Icon = "x" })
                return
            end
            if result and result.IsGamepass and result.GamepassId then
                pcall(function()
                    MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, result.GamepassId)
                end)
                WindUI:Notify({ Title = "Buy Boat", Content = "Game pass purchase prompted", Icon = "check" })
            elseif result and result.Success then
                WindUI:Notify({ Title = "Buy Boat", Content = "Purchase successful", Icon = "check" })
            else
                WindUI:Notify({
                    Title = "Buy Boat",
                    Content = (result and result.Message) or "Purchase failed",
                    Icon = "x",
                })
            end
            task.defer(updateBuyBoatDetailParagraph)
        end,
    })

    BuyBoatSection:Space()

    BuyBoatSection:Button({
        Title = "Refresh boat list",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshBoatList(true)
        end,
    })

    refreshRodList(false)
    refreshBoatList(false)
end

-- */  Teleport Tab  /* --
do
    local TeleportTab = ElementsSection:Tab({
        Title = "Teleport",
        Icon = "solar:folder-2-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    local TeleportSection = TeleportTab:Section({
        Title = "Teleport",
        Desc = "Enter position as X, Y, Z or use Get current location",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local teleportInputValue = ""

    local TeleportInput = TeleportSection:Input({
        Title = "Location",
        Placeholder = "e.g. 100, 5, 200 or 100 5 200",
        Value = teleportInputValue,
        Callback = function(value)
            teleportInputValue = value
        end
    })

    TeleportSection:Button({
        Title = "Get Current Location",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                WindUI:Notify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
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
            WindUI:Notify({
                Title = "Location",
                Content = "Position: " .. text,
                Icon = "check",
            })
        end
    })

    TeleportSection:Space()

    TeleportSection:Button({
        Title = "Teleport",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                WindUI:Notify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local s = teleportInputValue:gsub(",", " "):gsub("%s+", " ")
            local parts = {}
            for part in string.gmatch(s, "[%d%.%-]+") do
                table.insert(parts, tonumber(part))
            end
            if #parts < 3 then
                WindUI:Notify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                    Icon = "x",
                })
                return
            end
            local x, y, z = parts[1], parts[2], parts[3]
            rootPart.CFrame = CFrame.new(x, y, z)
            WindUI:Notify({
                Title = "Teleport",
                Content = string.format("Teleported to %.1f, %.1f, %.1f", x, y, z),
                Icon = "check",
            })
        end
    })

    TeleportSection:Space()

    local tweenDurationValue = "5"
    TeleportSection:Input({
        Title = "Tween Duration",
        Placeholder = "e.g. 5",
        Value = tweenDurationValue,
        Callback = function(value)
            tweenDurationValue = value
        end
    })

    TeleportSection:Button({
        Title = "Tween to Location",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                WindUI:Notify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local s = teleportInputValue:gsub(",", " "):gsub("%s+", " ")
            local parts = {}
            for part in string.gmatch(s, "[%d%.%-]+") do
                table.insert(parts, tonumber(part))
            end
            if #parts < 3 then
                WindUI:Notify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                    Icon = "x",
                })
                return
            end
            local x, y, z = parts[1], parts[2], parts[3]
            local targetPos = Vector3.new(x, y, z)
            local duration = tonumber(tweenDurationValue) or 5
            if duration < 0.1 then duration = 0.1 end
            local tweenInfo = TweenInfo.new(duration)
            local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = CFrame.new(targetPos) })
            tween:Play()
            WindUI:Notify({
                Title = "Teleport",
                Content = string.format("Tweening to %.1f, %.1f, %.1f (%.1fs)", x, y, z, duration),
                Icon = "check",
            })
        end
    })

    -- */  Teleport to Players  /* --
    TeleportTab:Space()

    local TeleportToPlayersSection = TeleportTab:Section({
        Title = "Teleport to Players",
        Desc = "Select a player and teleport to their character",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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
                if PlayerTeleportDropdown and PlayerTeleportDropdown.Set then PlayerTeleportDropdown:Set(nil) end
            end
        end
        if showNotify then
            WindUI:Notify({ Title = "Teleport", Content = "Player list refreshed (" .. #playerList .. " players)", Icon = "check" })
        end
    end

    PlayerTeleportDropdown = TeleportToPlayersSection:Dropdown({
        Title = "Player",
        Desc = "Select player to teleport to",
        Values = playerDisplayNames,
        Value = nil,
        AllowNone = true,
        Callback = function(value)
            selectedTeleportPlayer = nil
            if value then
                local idx = table.find(playerDisplayNames, value)
                if idx and playerList[idx] then
                    selectedTeleportPlayer = playerList[idx]
                end
            end
        end
    })

    TeleportToPlayersSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshPlayerList(true)
        end
    })

    TeleportToPlayersSection:Space()

    TeleportToPlayersSection:Button({
        Title = "Teleport",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedTeleportPlayer then
                WindUI:Notify({ Title = "Teleport", Content = "Select a player first", Icon = "x" })
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                WindUI:Notify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local targetChar = selectedTeleportPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then
                WindUI:Notify({ Title = "Teleport", Content = "Target player has no character", Icon = "x" })
                return
            end
            rootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0, 3))
            WindUI:Notify({ Title = "Teleport", Content = "Teleported to " .. (selectedTeleportPlayer.DisplayName or selectedTeleportPlayer.Name), Icon = "check" })
        end
    })
end

-- */  Objects Tab  /* --
do
    local ObjectsTab = ElementsSection:Tab({
        Title = "Objects",
        Icon = "solar:folder-2-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

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

    local ReplicatedStorageSection = ObjectsTab:Section({
        Title = "ReplicatedStorage",
        Desc = "All direct children of ReplicatedStorage (key = Name, value = ClassName)",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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
        WindUI:Notify({ Title = "ReplicatedStorage", Content = "Listed " .. #rsDisplayList .. " objects", Icon = "check" })
    end

    ReplicatedStorageDropdown = ReplicatedStorageSection:Dropdown({
        Title = "ReplicatedStorage (key = value)",
        Desc = "Select an object to see its children listed below",
        Values = rsDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(selectedDisplay)
            if not selectedDisplay then
                if ReplicatedStorageChildrenParagraph and ReplicatedStorageChildrenParagraph.SetDesc then
                    ReplicatedStorageChildrenParagraph:SetDesc("Select an object above to list its children")
                end
                return
            end
            local entry = rsKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local text = buildNestedObjectChildrenListText(entry.instance)
            if ReplicatedStorageChildrenParagraph and ReplicatedStorageChildrenParagraph.SetDesc then
                ReplicatedStorageChildrenParagraph:SetDesc(text)
            end
        end
    })

    ReplicatedStorageChildrenParagraph = ReplicatedStorageSection:Paragraph({
        Title = "Children (nested)",
        Desc = "Nested under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (name sort; max depth " .. OBJECTS_TREE_MAX_DEPTH .. ", max " .. OBJECTS_TREE_MAX_LINES .. " lines)",
    })

    ReplicatedStorageSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshReplicatedStorageList()
        end
    })

    ObjectsTab:Space()

    local PlayersServiceSection = ObjectsTab:Section({
        Title = "Players",
        Desc = "Players service: all Player instances (key = Name, value = ClassName)",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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
        WindUI:Notify({ Title = "Players", Content = "Listed " .. #plrsDisplayList .. " players", Icon = "check" })
    end

    PlayersServiceDropdown = PlayersServiceSection:Dropdown({
        Title = "Players (key = value)",
        Desc = "Select a player to see their top-level children listed below",
        Values = plrsDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(selectedDisplay)
            if not selectedDisplay then
                if PlayersServiceChildrenParagraph and PlayersServiceChildrenParagraph.SetDesc then
                    PlayersServiceChildrenParagraph:SetDesc("Select a player above to list their children")
                end
                return
            end
            local entry = plrsKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local text = buildNestedObjectChildrenListText(entry.instance)
            if PlayersServiceChildrenParagraph and PlayersServiceChildrenParagraph.SetDesc then
                PlayersServiceChildrenParagraph:SetDesc(text)
            end
        end
    })

    PlayersServiceChildrenParagraph = PlayersServiceSection:Paragraph({
        Title = "Children (nested)",
        Desc = "Nested under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (name sort; max depth " .. OBJECTS_TREE_MAX_DEPTH .. ", max " .. OBJECTS_TREE_MAX_LINES .. " lines)",
    })

    PlayersServiceSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshPlayersServiceList()
        end
    })

    ObjectsTab:Space()

    local LocalPlayerSection = ObjectsTab:Section({
        Title = "Local Player",
        Desc = "All direct children of Players.LocalPlayer (key = Name, value = ClassName)",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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
        WindUI:Notify({ Title = "Local Player", Content = "Listed " .. #lpDisplayList .. " objects", Icon = "check" })
    end

    LocalPlayerDropdown = LocalPlayerSection:Dropdown({
        Title = "Local Player (key = value)",
        Desc = "Select an object to see its children listed below",
        Values = lpDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(selectedDisplay)
            if not selectedDisplay then
                if LocalPlayerChildrenParagraph and LocalPlayerChildrenParagraph.SetDesc then
                    LocalPlayerChildrenParagraph:SetDesc("Select an object above to list its children")
                end
                return
            end
            local entry = lpKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local text = buildNestedObjectChildrenListText(entry.instance)
            if LocalPlayerChildrenParagraph and LocalPlayerChildrenParagraph.SetDesc then
                LocalPlayerChildrenParagraph:SetDesc(text)
            end
        end
    })

    LocalPlayerChildrenParagraph = LocalPlayerSection:Paragraph({
        Title = "Children (nested)",
        Desc = "Nested under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (name sort; max depth " .. OBJECTS_TREE_MAX_DEPTH .. ", max " .. OBJECTS_TREE_MAX_LINES .. " lines)",
    })

    LocalPlayerSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshLocalPlayerList()
        end
    })

    ObjectsTab:Space()

    local WorkspaceSection = ObjectsTab:Section({
        Title = "Workspace",
        Desc = "All direct children of Workspace (key = Name, value = ClassName)",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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
        WindUI:Notify({ Title = "Workspace", Content = "Listed " .. #wsDisplayList .. " objects", Icon = "check" })
    end

    WorkspaceDropdown = WorkspaceSection:Dropdown({
        Title = "Workspace (key = value)",
        Desc = "Select an object to see its children listed below",
        Values = wsDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(selectedDisplay)
            if not selectedDisplay then
                if WorkspaceChildrenParagraph and WorkspaceChildrenParagraph.SetDesc then
                    WorkspaceChildrenParagraph:SetDesc("Select an object above to list its children")
                end
                return
            end
            local entry = wsKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local text = buildNestedObjectChildrenListText(entry.instance)
            if WorkspaceChildrenParagraph and WorkspaceChildrenParagraph.SetDesc then
                WorkspaceChildrenParagraph:SetDesc(text)
            end
        end
    })

    WorkspaceChildrenParagraph = WorkspaceSection:Paragraph({
        Title = "Children (nested)",
        Desc = "Nested under Folder, Backpack, StarterGear, PlayerGui, ScreenGui, Frame (name sort; max depth " .. OBJECTS_TREE_MAX_DEPTH .. ", max " .. OBJECTS_TREE_MAX_LINES .. " lines)",
    })

    WorkspaceSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshWorkspaceList()
        end
    })

end
