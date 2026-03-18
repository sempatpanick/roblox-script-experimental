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
    Title = "sempatpanick | Others",
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
