local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))

local SempatLibrary

local baseURL = shared.sempatpanick_baseURL
assert(type(baseURL) == "string" and #baseURL > 0, "[sempatpanick] baseURL not set - load via sempatpanick.lua or sempatpanick_local.lua")

local function stripSourceBom(source)
    if type(source) == "string" and source:byte(1) == 0xEF and source:byte(2) == 0xBB and source:byte(3) == 0xBF then
        return source:sub(4)
    end
    return source
end

do
    local ok, result = pcall(function()
        return require("../../sempat_library")
    end)

    if ok then
        SempatLibrary = result
    else
        if cloneref(RunService):IsStudio() then
            SempatLibrary = require(cloneref(ReplicatedStorage):WaitForChild("sempat_library"))
        else
            local okGet, source = pcall(function()
                return game:HttpGet(baseURL .. "/sempat_library.lua")
            end)
            assert(okGet and type(source) == "string", "[sempat/mount_velora] failed to load sempat_library")
            source = stripSourceBom(source)
            SempatLibrary = (loadstring or load)(source, "sempat_library")()
        end
    end
end

local function mountNotify(opts)
    SempatLibrary:Notify({
        Title = opts.Title,
        Content = opts.Content,
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
        notifyFn({ Title = "Recording", Content = "Failed to load recording tab module" })
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
        notifyFn({ Title = "Local Player", Content = "Failed to load Local Player Tab tab module" })
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
        notifyFn({ Title = "Objects", Content = "Failed to load Objects Tab tab module" })
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
        notifyFn({ Title = "Teleport", Content = "Failed to load Teleport Tab module" })
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
        notifyFn({ Title = "Config", Content = "Failed to load Config Tab module" })
    end
end

-- */  Window  /* --
local Window = SempatLibrary:CreateWindow({
    Name = "sempatpanick | Mount Velora",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Sempat UI • Mount Velora",
    ToggleUIKeybind = "K",
    WindowTransparency = 30,
    Icon = "https://dadang.id/sempatpanick-icon.png",
    ConfigurationSaving = {
        Enabled = true,
        AutoSave = false,
        AutoLoad = false,
        FolderName = "sempatpanick",
        FileName = "mount_velora",
    },
})

-- */  Local Player Tab  /* --
createLocalPlayerTab(Window, mountNotify, { flagsPrefix = "lp", tabIcon = "user" })

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", "mountain")

    local SUMMIT_ARRIVAL_RADIUS = 80
    local DEFAULT_MIN_DELAY_SEC = 30
    local DEFAULT_MAX_DELAY_SEC = 60
    local CHECKPOINT_TELEPORT_RETRY_SEC = 5
    local PRE_RESET_DELAY_SEC = 5
    local POST_TELEPORT_POLL_SEC = 0.15
    local WALK_ARRIVAL_RADIUS = 6
    local WALK_TIMEOUT_SEC = 120
    local TWEEN_STUDS_PER_SEC = 80

    local function parsePositionStr(posStr)
        local s = posStr:gsub(",", " "):gsub("%s+", " ")
        local parts = {}
        for part in string.gmatch(s, "[%d%.%-]+") do
            table.insert(parts, tonumber(part))
        end
        if #parts < 3 then
            return nil
        end
        return Vector3.new(parts[1], parts[2], parts[3])
    end

    local function getRoutePosList(entry)
        if type(entry.pos) == "table" then
            return entry.pos
        end
        if type(entry.pos) == "string" then
            return { entry.pos }
        end
        return {}
    end

    local function getRouteFinalPosStr(entry)
        local posList = getRoutePosList(entry)
        return posList[#posList]
    end

    local function normalizeRouteEntryPos(entry)
        if type(entry.pos) == "string" then
            entry.pos = { entry.pos }
        end
        entry.modePos = entry.modePos or "teleport"
    end

    local summitRoute = {
        { name = "CP1", pos = { "14.77, 681.08, -2094.88" }, modePos = "teleport", minDelay = 5, maxDelay = 10 },
        { name = "CP2", pos = { "217.10, 681.19, -2790.15" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP3", pos = { "1799.51, 870.22, -2530.90" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP4", pos = { "575.10, 953.22, -2385.76" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP5", pos = { "-495.08, 1041.22, -2548.59" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP6", pos = { "-358.81, 861.22, -3472.24" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP7", pos = { "981.50, 708.38, -3904.00" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP8", pos = { "2418.64, 692.38, -4037.31" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP9", pos = { "1532.31, 940.38, -5087.82" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP10", pos = { "605.53, 1244.38, -5802.47" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP11", pos = { "442.30, 1572.37, -6576.43" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP12", pos = { "2562.72, 1451.43, -6272.23" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP13", pos = { "1174.00, 988.31, -7085.65" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP14", pos = { "324.35, 1321.49, -7993.00" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP15", pos = { "-661.10, 1653.49, -7641.02" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP16", pos = { "-1090.38, 1817.49, -8879.72" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP17", pos = { "-1391.11, 2580.38, -9757.35" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP18", pos = { "-1195.93, 2536.38, -10381.83" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP19", pos = { "-446.99, 2377.45, -9727.15" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP20", pos = { "599.00, 2276.37, -9483.09" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP21", pos = { "1842.77, 2753.49, -9768.78" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP22", pos = { "1064.08, 1924.58, -11086.57" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP23", pos = { "241.29, 2265.49, -12126.01" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP24", pos = { "-56.82, 2605.44, -11045.96" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP25", pos = { "1709.36, 2713.53, -12269.61" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP26", pos = { "1056.82, 2729.49, -13021.20" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP27", pos = { "708.86, 2921.49, -14055.06" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP28", pos = { "552.74, 3017.49, -14759.24" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP29", pos = { "279.23, 3497.18, -14311.25" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP30", pos = { "1240.11, 3489.18, -14460.85" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP31", pos = { "-583.09, 3513.49, -15158.50" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP32", pos = { "-1815.31, 3729.49, -15519.32" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP33", pos = { "-2210.07, 3513.49, -16548.21" }, modePos = "teleport", minDelay = 34, maxDelay = 60 },
        { name = "CP34", pos = { "-958.65, 3749.66, -16879.93" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP35", pos = { "234.19, 3249.49, -17321.96" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP36", pos = { "1128.89, 3513.65, -16504.36" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP37", pos = { "1212.00, 3754.30, -18149.90" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP38", pos = { "470.32, 3685.49, -19430.16" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP39", pos = { "-1581.70, 3576.87, -19348.67" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP40", pos = { "-1510.98, 3889.49, -18116.72" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP41", pos = { "-446.02, 2820.32, -18724.53" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP42", pos = { "1189.07, 3485.65, -20704.41" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP43", pos = { "602.39, 3737.38, -21430.04" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP44", pos = { "-452.24, 4015.40, -20523.57" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP45", pos = { "-1127.65, 4121.47, -21513.53" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP46", pos = { "72.67, 3945.49, -22653.11" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP47", pos = { "647.02, 4172.38, -23170.12" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP48", pos = { "-1101.14, 4141.05, -23377.83" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP49", pos = { "79.99, 3945.49, -24442.58" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP50", pos = { "1240.25, 4309.83, -24353.39" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "CP51", pos = { "-236.28, 4139.49, -26187.95" }, modePos = "teleport", minDelay = 35, maxDelay = 60 },
        { name = "Summit", pos = { "-157.16, 4202.91, -27249.49", "-164.90, 4208.38, -27312.80" }, modePos = "walk", minDelay = 35, maxDelay = 60 },
    }

    for i, entry in ipairs(summitRoute) do
        normalizeRouteEntryPos(entry)
        if not entry.label then
            if entry.name == "Summit" then
                entry.label = "Summit"
            else
                local cpNum = entry.name:match("^CP(%d+)$")
                entry.label = cpNum and ("Checkpoint " .. cpNum) or ("Checkpoint " .. tostring(i))
            end
        end
    end

    local checkpointByLabel = {}
    local checkpointDropdownLabels = {}
    for _, entry in ipairs(summitRoute) do
        checkpointByLabel[entry.label] = entry
        table.insert(checkpointDropdownLabels, entry.label)
    end

    local selectedCheckpointLabel = summitRoute[1] and summitRoute[1].label

    local autoSummitEnabled = false
    local autoSummitLoopToken = 0
    local autoSummitMode = "Teleport"
    local randomizeDelayEnabled = false
    local summitCount = 0
    local lastSummitDurationSec = nil
    local summitRunStartedAt = nil
    local summitLogLines = {}

    local statusParagraph
    local logParagraph

    local function getCheckpointValue()
        local player = Players.LocalPlayer
        local ls = player and player:FindFirstChild("leaderstats")
        local cp = ls and ls:FindFirstChild("Checkpoint")
        if cp and (cp:IsA("IntValue") or cp:IsA("NumberValue")) then
            return math.floor(cp.Value)
        end
        return 0
    end

    local function checkpointDisplayLabel(cpValue)
        if cpValue <= 0 then
            return "Start"
        end
        return "CP" .. tostring(cpValue)
    end

    local function formatDurationSec(totalSec)
        local sec = math.max(0, math.floor(totalSec + 0.5))
        local h = math.floor(sec / 3600)
        local m = math.floor((sec % 3600) / 60)
        local s = sec % 60
        if h > 0 then
            return string.format("%dh %dm %ds", h, m, s)
        end
        if m > 0 then
            return string.format("%dm %ds", m, s)
        end
        return string.format("%ds", s)
    end

    local function computeDelaySec(routeEntry)
        local minD = routeEntry.minDelay or DEFAULT_MIN_DELAY_SEC
        local maxD = routeEntry.maxDelay or DEFAULT_MAX_DELAY_SEC
        if maxD < minD then
            minD, maxD = maxD, minD
        end
        if randomizeDelayEnabled then
            return math.random(minD, maxD)
        end
        return minD
    end

    local function getLocalCharacterParts()
        local character = Players.LocalPlayer.Character
        if not character then
            return nil, nil, nil
        end
        return character, character:FindFirstChild("HumanoidRootPart"), character:FindFirstChildOfClass("Humanoid")
    end

    local function getLocalRootPart()
        local _, rootPart = getLocalCharacterParts()
        return rootPart
    end

    local function isNearPosition(posStr, radius)
        local targetPos = parsePositionStr(posStr)
        local rootPart = getLocalRootPart()
        if not targetPos or not rootPart then
            return false
        end
        return (rootPart.Position - targetPos).Magnitude <= radius
    end

    local function isNearRouteEntry(entry, radius)
        local finalPos = getRouteFinalPosStr(entry)
        if not finalPos then
            return false
        end
        return isNearPosition(finalPos, radius)
    end

    local function shouldStopRoute(token)
        if token == nil then
            return false
        end
        return not autoSummitEnabled or token ~= autoSummitLoopToken
    end

    local function moveToPositionStr(posStr, mode)
        local moveMode = string.lower(mode or "teleport")
        local targetPos = parsePositionStr(posStr)
        local _, rootPart, humanoid = getLocalCharacterParts()
        if not targetPos or not rootPart then
            return false
        end

        if moveMode == "teleport" then
            rootPart.AssemblyLinearVelocity = Vector3.zero
            rootPart.AssemblyAngularVelocity = Vector3.zero
            rootPart.CFrame = CFrame.new(targetPos)
            return true
        end

        if moveMode == "tween" then
            rootPart.AssemblyLinearVelocity = Vector3.zero
            rootPart.AssemblyAngularVelocity = Vector3.zero
            local dist = (rootPart.Position - targetPos).Magnitude
            local dur = math.clamp(dist / TWEEN_STUDS_PER_SEC, 0.35, 12)
            local tween = TweenService:Create(rootPart, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(targetPos),
            })
            tween:Play()
            tween.Completed:Wait()
            return true
        end

        if moveMode == "walk" then
            if not humanoid then
                return false
            end
            humanoid:MoveTo(targetPos)
            local deadline = os.clock() + WALK_TIMEOUT_SEC
            while os.clock() < deadline do
                if (rootPart.Position - targetPos).Magnitude <= WALK_ARRIVAL_RADIUS then
                    return true
                end
                task.wait(0.1)
            end
            return (rootPart.Position - targetPos).Magnitude <= WALK_ARRIVAL_RADIUS * 2
        end

        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
        rootPart.CFrame = CFrame.new(targetPos)
        return true
    end

    local function traverseRoutePositions(token, entry)
        local posList = getRoutePosList(entry)
        if #posList == 0 then
            return false
        end

        local betweenMode = string.lower(entry.modePos or "teleport")

        if not moveToPositionStr(posList[1], "teleport") then
            return false
        end
        if shouldStopRoute(token) then
            return false
        end

        for i = 2, #posList do
            if shouldStopRoute(token) then
                return false
            end
            if not moveToPositionStr(posList[i], betweenMode) then
                return false
            end
        end

        return true
    end

    local function teleportToPos(posStr)
        return moveToPositionStr(posStr, "teleport")
    end

    local function fireResetCheckpoint()
        local folder = ReplicatedStorage:FindFirstChild("CheckpointRemotes")
        local resetEvent = folder and folder:FindFirstChild("ResetCheckpoint")
        if resetEvent and resetEvent:IsA("RemoteEvent") then
            resetEvent:FireServer()
            return true
        end
        return false
    end

    local function setStatusContent(content)
        if statusParagraph and statusParagraph.Set then
            statusParagraph:Set({ Content = content })
        end
    end

    local function waitBeforeResetCheckpoint(token)
        local deadline = os.clock() + PRE_RESET_DELAY_SEC
        while autoSummitEnabled and token == autoSummitLoopToken do
            local remaining = deadline - os.clock()
            if remaining <= 0 then
                return true
            end
            setStatusContent(string.format(
                "Summit reached — resetting in %ds…",
                math.ceil(math.max(remaining, 0))
            ))
            task.wait(math.min(remaining, 0.25))
        end
        return false
    end

    local function refreshLogParagraph()
        if not logParagraph or not logParagraph.Set then
            return
        end
        local lines = {}
        table.insert(lines, "Total summits: " .. tostring(summitCount))
        if lastSummitDurationSec then
            table.insert(lines, "Last run: " .. formatDurationSec(lastSummitDurationSec))
        else
            table.insert(lines, "Last run: —")
        end
        if #summitLogLines > 0 then
            table.insert(lines, "")
            for _, line in ipairs(summitLogLines) do
                table.insert(lines, line)
            end
        end
        logParagraph:Set({ Content = table.concat(lines, "\n") })
    end

    local function refreshIdleStatus()
        local cp = getCheckpointValue()
        local nextIndex = math.min(cp + 1, #summitRoute)
        local nextEntry = summitRoute[nextIndex]
        local minD = nextEntry.minDelay or DEFAULT_MIN_DELAY_SEC
        local maxD = nextEntry.maxDelay or DEFAULT_MAX_DELAY_SEC
        if autoSummitEnabled then
            setStatusContent(string.format(
                "Current: %s (%d)\nNext: %s\nWaiting to continue…",
                checkpointDisplayLabel(cp),
                cp,
                nextEntry.name
            ))
        else
            setStatusContent(string.format(
                "Auto Summit is off.\nCurrent: %s (%d)\nNext: %s\nDelay: %d–%ds",
                checkpointDisplayLabel(cp),
                cp,
                nextEntry.name,
                minD,
                maxD
            ))
        end
    end

    local function waitWithCountdown(token, routeEntry, delaySec)
        local minD = routeEntry.minDelay or DEFAULT_MIN_DELAY_SEC
        local maxD = routeEntry.maxDelay or DEFAULT_MAX_DELAY_SEC
        local deadline = os.clock() + delaySec
        while autoSummitEnabled and token == autoSummitLoopToken do
            local remaining = deadline - os.clock()
            if remaining <= 0 then
                break
            end
            local cp = getCheckpointValue()
            setStatusContent(string.format(
                "Current: %s (%d)\nNext: %s\nDelay: %ds remaining (%d–%ds)",
                checkpointDisplayLabel(cp),
                cp,
                routeEntry.name,
                math.ceil(math.max(remaining, 0)),
                minD,
                maxD
            ))
            task.wait(math.min(remaining, 0.25))
        end
    end

    local function moveUntilCheckpointRegistered(token, expectedCp, routeEntry, isSummitStep)
        while autoSummitEnabled and token == autoSummitLoopToken do
            if not traverseRoutePositions(token, routeEntry) then
                setStatusContent("Character not loaded — retrying…")
                task.wait(1)
                continue
            end

            local retryDeadline = os.clock() + CHECKPOINT_TELEPORT_RETRY_SEC
            local registered = false
            while autoSummitEnabled and token == autoSummitLoopToken do
                local cpNow = getCheckpointValue()
                if isSummitStep then
                    if isNearRouteEntry(routeEntry, SUMMIT_ARRIVAL_RADIUS) then
                        registered = true
                        break
                    end
                elseif cpNow >= expectedCp then
                    registered = true
                    break
                end

                if os.clock() >= retryDeadline then
                    setStatusContent(string.format(
                        "Retrying route to %s…\nCurrent stat: %s (%d)\nExpected: %d",
                        routeEntry.name,
                        checkpointDisplayLabel(cpNow),
                        cpNow,
                        expectedCp
                    ))
                    break
                end

                setStatusContent(string.format(
                    "Confirming %s…\nCurrent stat: %s (%d)\nExpected: %d",
                    routeEntry.name,
                    checkpointDisplayLabel(cpNow),
                    cpNow,
                    expectedCp
                ))
                task.wait(POST_TELEPORT_POLL_SEC)
            end

            if registered then
                return true
            end
        end
        return false
    end

    local function recordSummitCompletion()
        local elapsed = summitRunStartedAt and (os.clock() - summitRunStartedAt) or 0
        summitCount += 1
        lastSummitDurationSec = elapsed
        local line = string.format("Summit #%d — %s", summitCount, formatDurationSec(elapsed))
        table.insert(summitLogLines, 1, line)
        while #summitLogLines > 5 do
            table.remove(summitLogLines)
        end
        refreshLogParagraph()
        summitRunStartedAt = os.clock()
    end

    local function runAutoSummitLoop(token)
        summitRunStartedAt = os.clock()
        while autoSummitEnabled and token == autoSummitLoopToken do
            if autoSummitMode ~= "Teleport" then
                task.wait(0.5)
                continue
            end

            local cp = getCheckpointValue()
            local nextIndex = cp + 1
            if nextIndex > #summitRoute then
                if waitBeforeResetCheckpoint(token) and fireResetCheckpoint() then
                    task.wait(0.5)
                end
                refreshIdleStatus()
                task.wait(0.5)
                continue
            end

            local routeEntry = summitRoute[nextIndex]
            local isSummitStep = nextIndex == #summitRoute
            local delaySec = computeDelaySec(routeEntry)

            waitWithCountdown(token, routeEntry, delaySec)
            if not autoSummitEnabled or token ~= autoSummitLoopToken then
                break
            end

            if not moveUntilCheckpointRegistered(token, nextIndex, routeEntry, isSummitStep) then
                break
            end

            if isSummitStep then
                if waitBeforeResetCheckpoint(token) then
                    fireResetCheckpoint()
                    recordSummitCompletion()
                    task.wait(0.5)
                end
            end

            refreshIdleStatus()
        end

        if token == autoSummitLoopToken then
            refreshIdleStatus()
        end
    end

    MainTab:CreateSection("Auto Summit")

    statusParagraph = MainTab:CreateParagraph({
        Title = "Checkpoint Status",
        Content = "(loading…)",
    })

    logParagraph = MainTab:CreateParagraph({
        Title = "Summit Log",
        Content = "Total summits: 0\nLast run: —",
    })

    MainTab:CreateDropdown({
        Name = "Mode",
        Flag = "velora_auto_summit_mode",
        Options = { "Teleport" },
        CurrentOption = { "Teleport" },
        Callback = function(value)
            autoSummitMode = rayfieldDropdownFirst(value) or "Teleport"
        end,
    })

    MainTab:CreateToggle({
        Name = "Randomize Delay",
        Flag = "velora_auto_summit_randomDelay",
        CurrentValue = false,
        Callback = function(enabled)
            randomizeDelayEnabled = enabled == true
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Summit",
        Flag = "velora_auto_summit_enabled",
        CurrentValue = false,
        Callback = function(enabled)
            autoSummitEnabled = enabled == true
            if not autoSummitEnabled then
                autoSummitLoopToken += 1
                refreshIdleStatus()
                return
            end
            autoSummitLoopToken += 1
            local myToken = autoSummitLoopToken
            task.spawn(function()
                runAutoSummitLoop(myToken)
            end)
            mountNotify({ Title = "Auto Summit", Content = "Auto Summit started" })
        end,
    })

    MainTab:CreateSection("Checkpoint")

    MainTab:CreateDropdown({
        Name = "Checkpoint",
        Flag = "velora_checkpoint_select",
        Options = checkpointDropdownLabels,
        CurrentOption = { selectedCheckpointLabel },
        Search = true,
        Callback = function(value)
            selectedCheckpointLabel = rayfieldDropdownFirst(value)
        end,
    })

    MainTab:CreateButton({
        Name = "Teleport",
        Callback = function()
            local entry = selectedCheckpointLabel and checkpointByLabel[selectedCheckpointLabel]
            if not entry then
                mountNotify({ Title = "Checkpoint", Content = "Select a checkpoint first" })
                return
            end
            if traverseRoutePositions(nil, entry) then
                mountNotify({ Title = "Checkpoint", Content = "Moved to " .. entry.label })
            else
                mountNotify({ Title = "Checkpoint", Content = "Character not loaded" })
            end
        end,
    })

    task.defer(refreshIdleStatus)
end

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "velora", tabIcon = "map-pin" })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, {
    replicatedStorage = ReplicatedStorage,
    tabIcon = "boxes",
})

-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, "sempatpanick/mount_velora/recordings", { tabIcon = "video" })

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/mount_velora",
    rayfieldLibrary = SempatLibrary,
    tabIcon = "settings",
})
