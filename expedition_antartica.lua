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
    Title = "sempatpanick | Expedition Antartica",
    Folder = "ftgshub",
    Icon = "solar:folder-2-bold-duotone",
    NewElements = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "Open Others UI",
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
    if WindUI and WindUI.Notify then
        WindUI:Notify({ Title = title, Content = content, Icon = icon or "check" })
    end
end

-- */  Global: format instance for display (Key = Value); isShowDataType == false => Name = Value only; isShowLocation => show Position for BaseParts  /* --
function formatInstanceDisplay(inst, isShowDataType, isShowLocation)
    if isShowDataType == false then
        local ok, val = pcall(function() return inst.Value end)
        if ok and val ~= nil then
            if typeof(val) == "Instance" then
                return inst.Name .. " = " .. (val.Name or tostring(val))
            else
                return inst.Name .. " = " .. tostring(val)
            end
        else
            return inst.Name .. " = "
        end
    end
    local base = inst.Name .. " = " .. inst.ClassName
    local ok, val = pcall(function() return inst.Value end)
    if ok and val ~= nil then
        if typeof(val) == "Instance" then
            base = base .. " (" .. (val.Name or tostring(val)) .. ")"
        else
            base = base .. " (" .. tostring(val) .. ")"
        end
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
    local walkSpeedValue = tostring(defaultWalkSpeed)

    WalkSpeedSection:Input({
        Title = "Speed",
        Placeholder = "e.g. 16 or 100",
        Value = walkSpeedValue,
        Callback = function(value)
            walkSpeedValue = value
        end
    })

    WalkSpeedSection:Space()

    WalkSpeedSection:Button({
        Title = "Apply",
        Justify = "Center",
        Icon = "",
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

    WalkSpeedSection:Space()

    WalkSpeedSection:Button({
        Title = "Reset",
        Justify = "Center",
        Icon = "",
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
                    notify("Rejoin", "Failed: " .. tostring(err), "close")
                end
            else
                notify("Rejoin", "Cannot rejoin (missing PlaceId or JobId)", "close")
            end
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
            notify("Console", cleared and "Console cleared" or "Clear not available (try clearconsole)", cleared and "check" or "x")
        end
    })
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
            notify("Location", "Position: " .. text)
        end
    })

    TeleportSection:Space()

    TeleportSection:Button({
        Title = "Teleport",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local _, rootPart = getLocalCharacterParts()
            if not rootPart then
                notify("Teleport", "Character not loaded", "x")
                return
            end
            local targetPos = parsePositionString(teleportInputValue)
            if not targetPos then
                notify("Teleport", "Enter position as X, Y, Z (e.g. 100, 5, 200)", "x")
                return
            end
            rootPart.CFrame = CFrame.new(targetPos)
            notify("Teleport", string.format("Teleported to %.1f, %.1f, %.1f", targetPos.X, targetPos.Y, targetPos.Z))
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
            local _, rootPart = getLocalCharacterParts()
            if not rootPart then
                notify("Teleport", "Character not loaded", "x")
                return
            end
            local targetPos = parsePositionString(teleportInputValue)
            if not targetPos then
                notify("Teleport", "Enter position as X, Y, Z (e.g. 100, 5, 200)", "x")
                return
            end
            local duration = tonumber(tweenDurationValue) or 5
            if duration < 0.1 then duration = 0.1 end
            local tweenInfo = TweenInfo.new(duration)
            local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = CFrame.new(targetPos) })
            tween:Play()
            notify("Teleport", string.format("Tweening to %.1f, %.1f, %.1f (%.1fs)", targetPos.X, targetPos.Y, targetPos.Z, duration))
        end
    })

    TeleportSection:Space()

    TeleportSection:Button({
        Title = "Walk to Location",
        Justify = "Center",
        Icon = "",
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

    TeleportSection:Space()

    -- */  Teleport to Camp  /* --
    TeleportTab:Space()

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

    local TeleportToCampSection = TeleportTab:Section({
        Title = "Teleport to Camp",
        Desc = "Select a camp and teleport instantly",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    TeleportToCampSection:Dropdown({
        Title = "Camp",
        Desc = "Select camp to teleport to",
        Values = campTeleportNames,
        Value = selectedCampTeleport,
        AllowNone = false,
        Callback = function(value)
            selectedCampTeleport = value
        end
    })

    TeleportToCampSection:Button({
        Title = "Teleport",
        Justify = "Center",
        Icon = "",
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
            notify("Teleport", "Player list refreshed (" .. #playerList .. " players)")
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

-- */  Automation Tab  /* --
do
    local AutomationTab = ElementsSection:Tab({
        Title = "Automation",
        Icon = "solar:folder-2-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    local AutoCampSection = AutomationTab:Section({
        Title = "Auto Camp",
        Desc = "Select a camp and tween to it",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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

    local DurationInput = AutoCampSection:Input({
        Title = "Tween Duration (seconds)",
        Placeholder = "e.g. 5",
        Value = tweenDurationSeconds,
        Callback = function(value)
            tweenDurationSeconds = value
        end
    })

    AutoCampSection:Dropdown({
        Title = "Camp",
        Desc = "Select camp to tween to",
        Values = campNames,
        Value = selectedCampName,
        AllowNone = false,
        Callback = function(value)
            selectedCampName = value
            local defaultDur = getDefaultDurationForCamp(value)
            tweenDurationSeconds = defaultDur
            if DurationInput then
                if DurationInput.Set then DurationInput:Set(defaultDur) end
                if DurationInput.SetValue then DurationInput:SetValue(defaultDur) end
            end
        end
    })

    AutoCampSection:Space()

    local autoCampTweenRef = { tween = nil }
    local autoCampCancelRequested = false

    AutoCampSection:Button({
        Title = "Auto Teleport",
        Justify = "Center",
        Icon = "",
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
    
    AutoCampSection:Space()

    AutoCampSection:Button({
        Title = "Stop Auto Camp",
        Justify = "Center",
        Icon = "",
        Callback = function()
            autoCampCancelRequested = true
            if autoCampTweenRef.tween then
                autoCampTweenRef.tween:Cancel()
                autoCampTweenRef.tween = nil
            end
            notify("Auto Camp", "Stopped", "x")
        end
    })

    AutoCampSection:Space()

    AutomationTab:Space()

    -- */  Auto Summit Section  /* --
    local autoSummitEnabled = false
    local summitQty = ""
    local SUMMIT_DELAY_SECONDS = 15
    local autoSummitRestartFromDeath = false  -- set by death listener; when true, loop restarts from camp 1
    local AutoSummitSection = AutomationTab:Section({
        Title = "Auto Summit",
        Desc = "Process all camps from start to end (Camp 1 → South Pole)",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local SummitQtyInput = AutoSummitSection:Input({
        Title = "Qty of summit",
        Placeholder = "Empty = unlimited",
        Value = "",
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

    AutoSummitSection:Toggle({
        Title = "Auto Summit",
        Desc = "Process all camps from start to end (Camp 1 → South Pole) within the quantity of summit. Empty qty = never end until disabled.",
        Value = false,
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
                local lp = Players.LocalPlayer
                local char = lp.Character
                if not char then
                    char = lp.CharacterAdded:Wait()
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
                repeat
                    if not autoSummitEnabled then break end
                    -- Refresh character/rootPart each iteration (survives respawn after "Died" or death)
                    rootPart = getRootPart()
                    if not rootPart then
                        -- Wait for respawn
                        local lp = Players.LocalPlayer
                        local char = lp.Character
                        if char then
                            char:WaitForChild("HumanoidRootPart", 10)
                        else
                            char = lp.CharacterAdded:Wait()
                            char:WaitForChild("HumanoidRootPart", 10)
                        end
                        task.wait(1)
                        rootPart = getRootPart()
                        if not rootPart then
                            notify("Auto Summit", "Could not get character after respawn", "x")
                            break
                        end
                    end
                    for _, camp in ipairs(campList) do
                        if not autoSummitEnabled then break end
                        if autoSummitRestartFromDeath then break end
                        rootPart = getRootPart()
                        if not rootPart then break end
                        notify("Auto Summit", "Moving to " .. camp.name .. "...")
                        runCampRoute(camp, rootPart, camp.defaultDuration or 5, function() return not autoSummitEnabled or autoSummitRestartFromDeath end)
                        if autoSummitRestartFromDeath then break end
                    end
                    if autoSummitRestartFromDeath then
                        notify("Auto Summit", "Character died — waiting for respawn, then restarting from start...")
                        -- Wait for new character (respawn); don't use dead body's rootPart
                        local lp = Players.LocalPlayer
                        local char = lp.Character
                        if not char then
                            char = lp.CharacterAdded:Wait()
                        else
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health <= 0 then
                                char = lp.CharacterAdded:Wait()
                            end
                        end
                        if char then
                            char:WaitForChild("HumanoidRootPart", 15)
                            task.wait(1)
                        end
                        autoSummitRestartFromDeath = false
                    else
                        notify("Auto Summit", "Reached summit! (Run " .. (runCount + 1) .. ")")
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
                            task.wait(SUMMIT_DELAY_SECONDS/3)
                            local Event = game:GetService("ReplicatedStorage").Events.CharacterHandler
                            Event:FireServer(
                                "Died"
                            )
                            task.wait(SUMMIT_DELAY_SECONDS)
                        end
                    end
                until not autoSummitEnabled or (qtyNum and remaining <= 0)
                if autoSummitEnabled and qtyNum and remaining <= 0 then
                    notify("Auto Summit", "All camps completed (" .. runCount .. " run(s))")
                elseif not autoSummitEnabled then
                    notify("Auto Summit", "Stopped", "x")
                end
            end)
        end
    })

    AutoSummitSection:Space()

    AutomationTab:Space()

    -- */  Auto Drink Section  /* --
    local HYDRATION_MAX = 100
    local AutoDrinkSection = AutomationTab:Section({
        Title = "Auto Drink",
        Desc = "Drink from Water Bottle when hydration is at or below minimum until nearly full",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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

    AutoDrinkSection:Input({
        Title = "Minimum Hydration",
        Placeholder = "50",
        Value = "50",
        Callback = function(value)
            minHydration = value
        end
    })

    AutoDrinkSection:Toggle({
        Title = "Auto Drink",
        Desc = "When hydration <= minimum, drink until hydration >= " .. tostring(HYDRATION_MAX - 10),
        Value = false,
        Callback = function(enabled)
            autoDrinkEnabled = enabled
            if enabled then
                startAutoDrink()
            else
                stopAutoDrink()
            end
        end
    })
    
    AutoDrinkSection:Space()
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
            local lines = {}
            for _, child in ipairs(entry.instance:GetChildren()) do
                table.insert(lines, formatInstanceDisplay(child, nil, true))
                if child.ClassName == "Folder" then
                    for _, sub in ipairs(child:GetChildren()) do
                        table.insert(lines, "  " .. formatInstanceDisplay(sub, nil, true))
                    end
                end
            end
            local text = table.concat(lines, "\n")
            if #lines == 0 then
                text = "(no children)"
            end
            if ReplicatedStorageChildrenParagraph and ReplicatedStorageChildrenParagraph.SetDesc then
                ReplicatedStorageChildrenParagraph:SetDesc(text)
            end
        end
    })

    ReplicatedStorageChildrenParagraph = ReplicatedStorageSection:Paragraph({
        Title = "Children (key = value)",
        Desc = "Select an object above to list its children",
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
            local lines = {}
            for _, child in ipairs(entry.instance:GetChildren()) do
                table.insert(lines, formatInstanceDisplay(child, nil, true))
                if child.ClassName == "Folder" then
                    for _, sub in ipairs(child:GetChildren()) do
                        table.insert(lines, "  " .. formatInstanceDisplay(sub, nil, true))
                    end
                end
            end
            local text = table.concat(lines, "\n")
            if #lines == 0 then
                text = "(no children)"
            end
            if LocalPlayerChildrenParagraph and LocalPlayerChildrenParagraph.SetDesc then
                LocalPlayerChildrenParagraph:SetDesc(text)
            end
        end
    })

    LocalPlayerChildrenParagraph = LocalPlayerSection:Paragraph({
        Title = "Children (key = value)",
        Desc = "Select an object above to list its children",
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
            local lines = {}
            for _, child in ipairs(entry.instance:GetChildren()) do
                table.insert(lines, formatInstanceDisplay(child, nil, true))
                if child.ClassName == "Folder" then
                    for _, sub in ipairs(child:GetChildren()) do
                        table.insert(lines, "  " .. formatInstanceDisplay(sub, nil, true))
                    end
                end
            end
            local text = table.concat(lines, "\n")
            if #lines == 0 then
                text = "(no children)"
            end
            if WorkspaceChildrenParagraph and WorkspaceChildrenParagraph.SetDesc then
                WorkspaceChildrenParagraph:SetDesc(text)
            end
        end
    })

    WorkspaceChildrenParagraph = WorkspaceSection:Paragraph({
        Title = "Children (key = value)",
        Desc = "Select an object above to list its children",
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
