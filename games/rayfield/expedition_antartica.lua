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

local baseURL = shared.sempatpanick_baseURL
assert(type(baseURL) == "string" and #baseURL > 0, "[sempatpanick] baseURL not set - load via sempatpanick.lua or sempatpanick_local.lua")

do
    local ok, result = pcall(function()
        return require("../../rayfield_library")
    end)

    if ok then
        RayfieldLibrary = result
    else
        if cloneref(RunService):IsStudio() then
            RayfieldLibrary = require(cloneref(ReplicatedStorage):WaitForChild("rayfield_library"))
        else
            RayfieldLibrary = loadstring(game:HttpGet(baseURL .. "/rayfield_library.lua"))()
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

local function rayfieldDropdownFirst(valueOrTable)
    if type(valueOrTable) == "table" then
        return valueOrTable[1]
    end
    return valueOrTable
end

-- */  Recording Tab (module)  /* --
local RECORDING_TAB_REPO = baseURL .. "/tabs/rayfield/recording_tab.lua"
local function loadCreateRecordingTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("../../tabs/rayfield/recording_tab")
    end)
    if okReq and type(mod) == "function" then
        return mod
    end

    local okHttp, source = pcall(function()
        return game:HttpGet(repoUrl)
    end)
    if not okHttp or type(source) ~= "string" or #source < 64 then
        warn("[Recording Tab] HttpGet failed:", tostring(source))
        return nil
    end

    local chunk, compileErr
    if type(load) == "function" then
        local okLoad
        okLoad, chunk = pcall(function()
            return load(source, "recording_tab")
        end)
        if not okLoad then
            compileErr = chunk
            chunk = nil
        end
    end
    if type(chunk) ~= "function" and type(loadstring) == "function" then
        chunk, compileErr = loadstring(source)
    end
    if type(chunk) ~= "function" then
        warn("[Recording Tab] compile failed:", tostring(compileErr))
        return nil
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        warn("[Recording Tab] module execute failed:", tostring(result))
        return nil
    end
    if type(result) ~= "function" then
        warn("[Recording Tab] module must return a function, got", type(result))
        return nil
    end
    return result
end

local createRecordingTab = loadCreateRecordingTab(RECORDING_TAB_REPO)
if not createRecordingTab then
    createRecordingTab = function(_windowRef, notifyFn, _recordingsDir)
        notifyFn({ Title = "Recording", Content = "Failed to load recording tab module", Icon = "x" })
    end
end

-- */  Local Player Tab (module)  /* --
local LOCAL_PLAYER_TAB_REPO = baseURL .. "/tabs/rayfield/local_player_tab.lua"
local function loadCreateLocalPlayerTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("../../tabs/rayfield/local_player_tab")
    end)
    if okReq and type(mod) == "function" then
        return mod
    end

    local okHttp, source = pcall(function()
        return game:HttpGet(repoUrl)
    end)
    if not okHttp or type(source) ~= "string" or #source < 64 then
        warn("[Local Player] HttpGet failed:", tostring(source))
        return nil
    end

    local chunk, compileErr
    if type(load) == "function" then
        local okLoad
        okLoad, chunk = pcall(function()
            return load(source, "local_player_tab")
        end)
        if not okLoad then
            compileErr = chunk
            chunk = nil
        end
    end
    if type(chunk) ~= "function" and type(loadstring) == "function" then
        chunk, compileErr = loadstring(source)
    end
    if type(chunk) ~= "function" then
        warn("[Local Player] compile failed:", tostring(compileErr))
        return nil
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        warn("[Local Player] module execute failed:", tostring(result))
        return nil
    end
    if type(result) ~= "function" then
        warn("[Local Player] module must return a function, got", type(result))
        return nil
    end
    return result
end

local createLocalPlayerTab = loadCreateLocalPlayerTab(LOCAL_PLAYER_TAB_REPO)
if not createLocalPlayerTab then
    createLocalPlayerTab = function(_windowRef, notifyFn, _options)
        notifyFn({ Title = "Local Player", Content = "Failed to load Local Player Tab tab module", Icon = "x" })
    end
end
-- */  Objects Tab (module)  /* --
local OBJECTS_TAB_REPO = baseURL .. "/tabs/rayfield/objects_tab.lua"
local function loadCreateObjectsTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("../../tabs/rayfield/objects_tab")
    end)
    if okReq and type(mod) == "function" then
        return mod
    end

    local okHttp, source = pcall(function()
        return game:HttpGet(repoUrl)
    end)
    if not okHttp or type(source) ~= "string" or #source < 64 then
        warn("[Objects] HttpGet failed:", tostring(source))
        return nil
    end

    local chunk, compileErr
    if type(load) == "function" then
        local okLoad
        okLoad, chunk = pcall(function()
            return load(source, "objects_tab")
        end)
        if not okLoad then
            compileErr = chunk
            chunk = nil
        end
    end
    if type(chunk) ~= "function" and type(loadstring) == "function" then
        chunk, compileErr = loadstring(source)
    end
    if type(chunk) ~= "function" then
        warn("[Objects] compile failed:", tostring(compileErr))
        return nil
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        warn("[Objects] module execute failed:", tostring(result))
        return nil
    end
    if type(result) ~= "function" then
        warn("[Objects] module must return a function, got", type(result))
        return nil
    end
    return result
end

local createObjectsTab = loadCreateObjectsTab(OBJECTS_TAB_REPO)
if not createObjectsTab then
    createObjectsTab = function(_windowRef, notifyFn, _options)
        notifyFn({ Title = "Objects", Content = "Failed to load Objects Tab tab module", Icon = "x" })
    end
end
-- */  Teleport Tab (module)  /* --
local TELEPORT_TAB_REPO = baseURL .. "/tabs/rayfield/teleport_tab.lua"
local function loadCreateTeleportTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("../../tabs/rayfield/teleport_tab")
    end)
    if okReq and type(mod) == "function" then
        return mod
    end

    local okHttp, source = pcall(function()
        return game:HttpGet(repoUrl)
    end)
    if not okHttp or type(source) ~= "string" or #source < 64 then
        warn("[Teleport Tab] HttpGet failed:", tostring(source))
        return nil
    end

    local chunk, compileErr
    if type(load) == "function" then
        local okLoad
        okLoad, chunk = pcall(function()
            return load(source, "teleport_tab")
        end)
        if not okLoad then
            compileErr = chunk
            chunk = nil
        end
    end
    if type(chunk) ~= "function" and type(loadstring) == "function" then
        chunk, compileErr = loadstring(source)
    end
    if type(chunk) ~= "function" then
        warn("[Teleport Tab] compile failed:", tostring(compileErr))
        return nil
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        warn("[Teleport Tab] module execute failed:", tostring(result))
        return nil
    end
    if type(result) ~= "function" then
        warn("[Teleport Tab] module must return a function, got", type(result))
        return nil
    end
    return result
end

local createTeleportTab = loadCreateTeleportTab(TELEPORT_TAB_REPO)
if not createTeleportTab then
    createTeleportTab = function(_windowRef, notifyFn, _options)
        notifyFn({ Title = "Teleport", Content = "Failed to load Teleport Tab module", Icon = "x" })
    end
end
-- */  Config Tab (module)  /* --
local CONFIG_TAB_REPO = baseURL .. "/tabs/rayfield/config_tab.lua"
local function loadCreateConfigTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("../../tabs/rayfield/config_tab")
    end)
    if okReq and type(mod) == "function" then
        return mod
    end

    local okHttp, source = pcall(function()
        return game:HttpGet(repoUrl)
    end)
    if not okHttp or type(source) ~= "string" or #source < 64 then
        warn("[Config Tab] HttpGet failed:", tostring(source))
        return nil
    end

    local chunk, compileErr
    if type(load) == "function" then
        local okLoad
        okLoad, chunk = pcall(function()
            return load(source, "config_tab")
        end)
        if not okLoad then
            compileErr = chunk
            chunk = nil
        end
    end
    if type(chunk) ~= "function" and type(loadstring) == "function" then
        chunk, compileErr = loadstring(source)
    end
    if type(chunk) ~= "function" then
        warn("[Config Tab] compile failed:", tostring(compileErr))
        return nil
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        warn("[Config Tab] module execute failed:", tostring(result))
        return nil
    end
    if type(result) ~= "function" then
        warn("[Config Tab] module must return a function, got", type(result))
        return nil
    end
    return result
end

local createConfigTab = loadCreateConfigTab(CONFIG_TAB_REPO)
if not createConfigTab then
    createConfigTab = function(_windowRef, notifyFn, _options)
        notifyFn({ Title = "Config", Content = "Failed to load Config Tab module", Icon = "x" })
    end
end
-- */  Window  /* --
local Window = RayfieldLibrary:CreateWindow({
    Name = "sempatpanick | Expedition Antartica",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Expedition Antartica",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = true,
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
createLocalPlayerTab(Window, mountNotify)

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
        Flag = "expedition_auto_camp_duration",
        CurrentValue = tweenDurationSeconds,
        Callback = function(value)
            tweenDurationSeconds = value
        end
    })

    AutomationTab:CreateDropdown({
        Ext = true,
        Name = "Camp",
        Flag = "expedition_auto_camp_select",
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
        Flag = "expedition_auto_summit_qty",
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
        Flag = "expedition_auto_summit",
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
        Flag = "expedition_auto_drink_minHydration",
        CurrentValue = "50",
        Callback = function(value)
            minHydration = value
        end
    })

    AutomationTab:CreateToggle({
        Ext = true,
        Name = "Auto Drink",
        Flag = "expedition_auto_drink",
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
createTeleportTab(Window, mountNotify, {
    ext = true,
    notifyIcons = true,
    walkToLocation = true,
    playerSearch = true,
    playerNoneOption = true,
    campTeleport = {
        sectionTitle = "Teleport to Camp",
        mode = "dropdown",
        camps = {
            { name = "Camp 1", position = "-3718.86, 240.00, 235.13" },
            { name = "Camp 2", position = "1789.92, 110.44, -137.28" },
            { name = "Camp 3", position = "5892.31, 320.00, -19.92" },
            { name = "Camp 4", position = "8991.70, 600.60, 103.15" },
            { name = "South Pole", position = "10989.81, 569.12, 106.85" },
        },
    },
})

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, { replicatedStorage = ReplicatedStorage })

-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, "sempatpanick/expedition_antartica/recordings")

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/expedition_antartica",
    rayfieldLibrary = RayfieldLibrary,
})
