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
            assert(okGet and type(source) == "string", "[sempat/mount_daun] failed to load sempat_library")
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
    createRecordingTab = function(_windowRef, notifyFn, _options)
        notifyFn({ Title = "Recording", Content = "Failed to load Recording Tab module", Icon = "x" })
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
    Name = "sempatpanick | Mount Daun",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Sempat UI • Mount Daun",
    ToggleUIKeybind = "K",
    WindowTransparency = 30,
    Icon = "https://dadang.id/sempatpanick-icon.png",
    ConfigurationSaving = {
        Enabled = true,
        AutoSave = false,
        AutoLoad = false,
        FolderName = "sempatpanick",
        FileName = "mount_daun",
    },
})

-- */  Local Player Tab  /* --
createLocalPlayerTab(Window, mountNotify, { flagsPrefix = "lp", tabIcon = "user" })

-- Set by Config Tab when applying daun_auto_summit_enabled = true (manual toggle skips delay).
local autoSummitConfigBridge = {
    pendingStartDelay = false,
}

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", "mountain")

    local SUMMIT_ARRIVAL_RADIUS = 80
    local DEFAULT_TELEPORT_DURATION_SEC = 5
    local DEFAULT_TWEEN_DURATION_SEC = 0.5
    local CHECKPOINT_TELEPORT_RETRY_SEC = 5
    local PRE_RESET_DELAY_SEC = 1
    local POST_TELEPORT_POLL_SEC = 0.15
    local POST_RESET_WAIT_SEC = 5
    local AUTO_SUMMIT_CONFIG_START_DELAY_SEC = 5
    local GAMEPLAY_PAUSE_APPEAR_SEC = 0.75

    local function parsePositionStr(posStr)
        if type(posStr) ~= "string" then
            return nil
        end
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
        entry.modePos = entry.modePos or "tween"
        if entry.delay == nil then
            entry.delay = DEFAULT_TELEPORT_DURATION_SEC
        end
    end

    -- delay = wait after this CP before the next teleport (seconds).
    -- 1 position = teleport only; 2+ positions = teleport to pos[1], then tween remaining.
    local summitRoute = {
        { name = "CP1", pos = { "-622.54, 250.33, -383.30" }, modePos = "tween", delay = 20 },
        { name = "CP2", pos = { "-1203.06, 261.69, -486.73" }, modePos = "tween", delay = 20 },
        { name = "CP3", pos = { "-1399.34, 578.44, -950.07" }, modePos = "tween", delay = 20 },
        { name = "CP4", pos = { "-1700.81, 816.68, -1399.42" }, modePos = "tween", delay = 20 },
        { name = "Summit", pos = { "-3208.45, 1720.33, -2613.27", "-3241.28, 1713.15, -2557.37" }, modePos = "tween", delay = 30 },
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
    local teleportDurationSec = DEFAULT_TELEPORT_DURATION_SEC
    local tweenDurationSec = DEFAULT_TWEEN_DURATION_SEC
    local summitQty = ""
    local summitCount = 0
    local lastSummitDurationSec = nil
    local summitRunStartedAt = nil
    local summitLogLines = {}
    local activeTween = nil
    local resumeFromStart = false

    local statusParagraph
    local logParagraph
    local autoSummitMainToggle
    local summitQtyInput

    local function getRouteDelaySec(entry)
        local d = entry and tonumber(entry.delay)
        if d ~= nil then
            return math.max(0, d)
        end
        return math.max(0, tonumber(teleportDurationSec) or DEFAULT_TELEPORT_DURATION_SEC)
    end

    local function normalizeCheckpointLabel(value)
        if typeof(value) ~= "string" then
            value = tostring(value or "")
        end
        value = string.gsub(value, "^%s+", "")
        value = string.gsub(value, "%s+$", "")
        return value
    end

    local function readValueInstance(inst)
        if not inst then
            return ""
        end
        if inst:IsA("StringValue") or inst:IsA("IntValue") or inst:IsA("NumberValue") then
            return normalizeCheckpointLabel(inst.Value)
        end
        local nested = inst:FindFirstChild("Value") or inst:FindFirstChildWhichIsA("StringValue")
            or inst:FindFirstChildWhichIsA("IntValue")
        if nested then
            return readValueInstance(nested)
        end
        local attr = inst.GetAttribute and (inst:GetAttribute("Value") or inst:GetAttribute("Checkpoint"))
        if attr ~= nil then
            return normalizeCheckpointLabel(attr)
        end
        return ""
    end

    local function getCheckpointInstance()
        local player = Players.LocalPlayer
        if not player then
            return nil
        end
        local leaderstats = player:FindFirstChild("leaderstats")
        if not leaderstats then
            return nil
        end
        return leaderstats:FindFirstChild("Checkpoint")
    end

    local function getCheckpointLabel()
        return readValueInstance(getCheckpointInstance())
    end

    local function displayCheckpointLabel(label)
        if label == nil or label == "" then
            return "Start"
        end
        return label
    end

    local function expectedCheckpointName(entry)
        if not entry then
            return "—"
        end
        if entry.name == "Summit" then
            return "CP0"
        end
        return entry.name
    end

    -- CP0 = start (and the value written after summit). CP1–CP4 map to those route steps.
    local function checkpointRouteIndex(label)
        local raw = normalizeCheckpointLabel(label)
        if raw == "" then
            return 0
        end
        local low = string.lower(raw)
        if low == "cp0" or low == "start" or low == "basecamp" or low == "base" then
            return 0
        end
        if string.find(low, "summit", 1, true) then
            return #summitRoute
        end
        local cpNum = tonumber(string.match(raw, "^%s*CP%s*(%d+)%s*$") or string.match(raw, "(%d+)"))
        if cpNum and cpNum >= 1 then
            return math.min(cpNum, #summitRoute - 1)
        end
        return 0
    end

    local function nextRouteIndexFromCheckpoint()
        local idx = checkpointRouteIndex(getCheckpointLabel())
        if idx >= #summitRoute then
            return #summitRoute + 1
        end
        return idx + 1
    end

    local function checkpointMatchesRouteEntry(label, entry)
        local raw = normalizeCheckpointLabel(label)
        if raw == "" or not entry then
            return false
        end
        local low = string.lower(raw)
        if low == string.lower(entry.name) then
            return true
        end
        if entry.name == "Summit" then
            return low == "cp0" or string.find(low, "summit", 1, true) ~= nil
        end
        local labelNum = tonumber(string.match(raw, "(%d+)"))
        local entryNum = tonumber(string.match(entry.name, "^CP(%d+)$"))
        return labelNum ~= nil and entryNum ~= nil and labelNum == entryNum
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

    local function cancelActiveTween()
        if activeTween then
            pcall(function()
                activeTween:Cancel()
            end)
            activeTween = nil
        end
    end

    local function shouldStopRoute(token)
        if token == nil then
            return false
        end
        return not autoSummitEnabled or token ~= autoSummitLoopToken
    end

    local function isGameplayPaused()
        local lp = Players.LocalPlayer
        if not lp then
            return false
        end
        local paused = false
        pcall(function()
            paused = lp.GameplayPaused == true
        end)
        return paused
    end

    -- Far teleports can set Player.GameplayPaused while streaming loads the destination.
    local function waitWhileGameplayPaused(token)
        local appearDeadline = os.clock() + GAMEPLAY_PAUSE_APPEAR_SEC
        while not shouldStopRoute(token) do
            if isGameplayPaused() then
                break
            end
            if os.clock() >= appearDeadline then
                break
            end
            task.wait(0.05)
        end
        if shouldStopRoute(token) then
            return false
        end

        while isGameplayPaused() do
            if shouldStopRoute(token) then
                return false
            end
            if statusParagraph and statusParagraph.Set then
                statusParagraph:Set({
                    Content = "Game paused (streaming) — waiting to resume…",
                })
            end
            task.wait(0.1)
        end

        return not shouldStopRoute(token)
    end

    local function moveToPositionStr(posStr, mode, token)
        local moveMode = string.lower(mode or "teleport")
        local targetPos = parsePositionStr(posStr)
        local _, rootPart = getLocalCharacterParts()
        if not targetPos or not rootPart then
            return false
        end

        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero

        if moveMode == "teleport" then
            rootPart.CFrame = CFrame.new(targetPos)
            return true
        end

        if moveMode == "tween" then
            local dur = math.max(0, tonumber(tweenDurationSec) or DEFAULT_TWEEN_DURATION_SEC)
            if dur <= 0 then
                rootPart.CFrame = CFrame.new(targetPos)
                return true
            end
            cancelActiveTween()
            local tween = TweenService:Create(rootPart, TweenInfo.new(dur, Enum.EasingStyle.Linear), {
                CFrame = CFrame.new(targetPos),
            })
            activeTween = tween
            tween:Play()
            local deadline = os.clock() + dur + 0.35
            while tween.PlaybackState == Enum.PlaybackState.Playing do
                if shouldStopRoute(token) then
                    cancelActiveTween()
                    return false
                end
                if os.clock() >= deadline then
                    break
                end
                task.wait()
            end
            if activeTween == tween then
                activeTween = nil
            end
            return not shouldStopRoute(token)
        end

        rootPart.CFrame = CFrame.new(targetPos)
        return true
    end

    local function traverseRoutePositions(token, entry)
        local posList = getRoutePosList(entry)
        if #posList == 0 then
            return false
        end

        local betweenMode = string.lower(entry.modePos or "tween")

        if not moveToPositionStr(posList[1], "teleport", token) then
            return false
        end
        if shouldStopRoute(token) then
            return false
        end
        if not waitWhileGameplayPaused(token) then
            return false
        end

        for i = 2, #posList do
            if shouldStopRoute(token) then
                return false
            end
            if not moveToPositionStr(posList[i], betweenMode, token) then
                return false
            end
        end

        return true
    end

    local function fireResetProgress()
        local ok = pcall(function()
            ReplicatedStorage.CheckpointRemotes.ResetProgress:FireServer()
        end)
        return ok == true
    end

    local function setStatusContent(content)
        if statusParagraph and statusParagraph.Set then
            statusParagraph:Set({ Content = content })
        end
    end

    local function waitWithCountdown(token, seconds, statusFn)
        local delaySec = math.max(0, tonumber(seconds) or 0)
        if delaySec <= 0 then
            return true
        end
        local deadline = os.clock() + delaySec
        while autoSummitEnabled and token == autoSummitLoopToken do
            local remaining = deadline - os.clock()
            if remaining <= 0 then
                return true
            end
            if statusFn then
                statusFn(remaining)
            end
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
        local checkpoint = getCheckpointLabel()
        local nextIndex = math.min(nextRouteIndexFromCheckpoint(), #summitRoute)
        local nextEntry = summitRoute[nextIndex]
        local nextName = nextEntry and nextEntry.name or "—"
        local nextDelay = getRouteDelaySec(nextEntry)
        if autoSummitEnabled then
            setStatusContent(string.format(
                "Current: %s\nNext: %s\nDelay: %.1fs  Tween: %.1fs\nWaiting to continue…",
                displayCheckpointLabel(checkpoint),
                nextName,
                nextDelay,
                tweenDurationSec
            ))
        else
            setStatusContent(string.format(
                "Auto Summit is off.\nCurrent: %s\nNext: %s\nDelay: %.1fs  Tween: %.1fs",
                displayCheckpointLabel(checkpoint),
                nextName,
                nextDelay,
                tweenDurationSec
            ))
        end
    end

    local function waitForCheckpointConfirm(token, routeEntry, isSummitStep)
        local retryDeadline = os.clock() + CHECKPOINT_TELEPORT_RETRY_SEC
        while autoSummitEnabled and token == autoSummitLoopToken do
            local checkpointNow = getCheckpointLabel()
            if checkpointMatchesRouteEntry(checkpointNow, routeEntry) then
                return true
            end
            if isSummitStep and isNearRouteEntry(routeEntry, SUMMIT_ARRIVAL_RADIUS) then
                return true
            end
            if os.clock() >= retryDeadline then
                return false
            end
            setStatusContent(string.format(
                "Confirming %s…\nCheckpoint: %s\nExpected: %s",
                routeEntry.name,
                displayCheckpointLabel(checkpointNow),
                expectedCheckpointName(routeEntry)
            ))
            task.wait(POST_TELEPORT_POLL_SEC)
        end
        return false
    end

    local function moveUntilCheckpointRegistered(token, routeEntry, isSummitStep)
        while autoSummitEnabled and token == autoSummitLoopToken do
            setStatusContent(string.format(
                "Teleport → %s\nTween: %.1fs",
                routeEntry.name,
                tweenDurationSec
            ))
            if not traverseRoutePositions(token, routeEntry) then
                if shouldStopRoute(token) then
                    return false
                end
                setStatusContent("Character not loaded — retrying…")
                task.wait(1)
                continue
            end

            if waitForCheckpointConfirm(token, routeEntry, isSummitStep) then
                return true
            end
            if shouldStopRoute(token) then
                return false
            end
            setStatusContent(string.format(
                "Retrying route to %s…\nCheckpoint: %s",
                routeEntry.name,
                displayCheckpointLabel(getCheckpointLabel())
            ))
        end
        return false
    end

    local function waitAfterCheckpoint(token, routeEntry)
        return waitWithCountdown(token, getRouteDelaySec(routeEntry), function(remaining)
            setStatusContent(string.format(
                "At %s\nCheckpoint: %s\nNext teleport in %.1fs",
                routeEntry.name,
                displayCheckpointLabel(getCheckpointLabel()),
                remaining
            ))
        end)
    end

    local function waitBeforeResetProgress(token)
        return waitWithCountdown(token, PRE_RESET_DELAY_SEC, function(remaining)
            setStatusContent(string.format(
                "Summit reached — resetting in %ds…",
                math.ceil(math.max(remaining, 0))
            ))
        end)
    end

    local function waitAfterResetProgress(token)
        return waitWithCountdown(token, POST_RESET_WAIT_SEC, function(remaining)
            setStatusContent(string.format(
                "ResetProgress sent — waiting %.0fs…\nCheckpoint: %s",
                math.ceil(math.max(remaining, 0)),
                displayCheckpointLabel(getCheckpointLabel())
            ))
        end)
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

    local function parseSummitQty(value)
        local text = typeof(value) == "string" and value or tostring(value or "")
        text = text:gsub("%s+", "")
        if text == "" then
            return nil
        end
        return tonumber(text)
    end

    local function setSummitQtyDisplay(value)
        summitQty = tostring(value or "")
        if summitQtyInput then
            if summitQtyInput.Set then
                summitQtyInput:Set(summitQty, true)
            elseif summitQtyInput.SetValue then
                summitQtyInput:SetValue(summitQty, true)
            end
        end
    end

    local function runAutoSummitLoop(token)
        local qtyNum = parseSummitQty(summitQty)
        local remaining = qtyNum
        resumeFromStart = false

        if autoSummitConfigBridge.pendingStartDelay then
            autoSummitConfigBridge.pendingStartDelay = false
            mountNotify({
                Title = "Auto Summit",
                Content = "Config load — starting in " .. tostring(AUTO_SUMMIT_CONFIG_START_DELAY_SEC) .. "s",
            })
            if not waitWithCountdown(token, AUTO_SUMMIT_CONFIG_START_DELAY_SEC, function(remain)
                setStatusContent(string.format("Config load delay…\nStarting Auto Summit in %.1fs", remain))
            end) then
                refreshIdleStatus()
                return
            end
        end

        summitRunStartedAt = os.clock()

        while autoSummitEnabled and token == autoSummitLoopToken do
            if autoSummitMode ~= "Teleport" then
                task.wait(0.5)
                continue
            end

            local nextIndex = nextRouteIndexFromCheckpoint()
            if resumeFromStart then
                resumeFromStart = false
                nextIndex = 1
            end
            if nextIndex > #summitRoute then
                if waitBeforeResetProgress(token) and fireResetProgress() then
                    waitAfterResetProgress(token)
                    resumeFromStart = true
                end
                refreshIdleStatus()
                task.wait(0.5)
                continue
            end

            local routeEntry = summitRoute[nextIndex]
            local isSummitStep = nextIndex == #summitRoute

            if not moveUntilCheckpointRegistered(token, routeEntry, isSummitStep) then
                break
            end
            if not waitAfterCheckpoint(token, routeEntry) then
                break
            end

            if isSummitStep then
                fireResetProgress()
                recordSummitCompletion()
                waitAfterResetProgress(token)
                resumeFromStart = true
                if remaining then
                    remaining -= 1
                    setSummitQtyDisplay(remaining)
                end
                if remaining and remaining <= 0 then
                    mountNotify({
                        Title = "Auto Summit",
                        Content = "All runs completed (" .. tostring(summitCount) .. " run(s))",
                    })
                    autoSummitEnabled = false
                    autoSummitLoopToken += 1
                    if autoSummitMainToggle then
                        autoSummitMainToggle:Set(false, true)
                    end
                    break
                end
            end

            refreshIdleStatus()
        end

        cancelActiveTween()
        refreshIdleStatus()
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
        Flag = "daun_auto_summit_mode",
        Options = { "Teleport" },
        CurrentOption = { "Teleport" },
        Callback = function(value)
            autoSummitMode = rayfieldDropdownFirst(value) or "Teleport"
        end,
    })

    summitQtyInput = MainTab:CreateInput({
        Name = "Qty of summit",
        Flag = "daun_auto_summit_qty",
        PlaceholderText = "Empty = unlimited",
        CurrentValue = "",
        Callback = function(value)
            summitQty = value
        end,
    })

    local checkpointDelayPopup = Window:CreatePopup({
        Title = "Checkpoint delays",
        Content = "Wait after each checkpoint before the next teleport",
        Height = 400,
    })
    checkpointDelayPopup:CreateSection("Delay")
    for _, entry in ipairs(summitRoute) do
        checkpointDelayPopup:CreateSlider({
            Name = entry.label or entry.name,
            Flag = "daun_auto_summit_delay_" .. tostring(entry.name),
            Range = { 0, 50 },
            Increment = 0.5,
            Suffix = "s",
            CurrentValue = getRouteDelaySec(entry),
            Callback = function(value)
                entry.delay = tonumber(value) or DEFAULT_TELEPORT_DURATION_SEC
                refreshIdleStatus()
            end,
        })
    end

    MainTab:CreateButton({
        Name = "Checkpoint delays",
        Callback = function()
            checkpointDelayPopup:Open()
        end,
    })

    MainTab:CreateSlider({
        Name = "Tween Duration",
        Flag = "daun_auto_summit_tweenDuration",
        Range = { 0, 5 },
        Increment = 0.1,
        Suffix = "s",
        CurrentValue = DEFAULT_TWEEN_DURATION_SEC,
        Callback = function(value)
            tweenDurationSec = tonumber(value) or DEFAULT_TWEEN_DURATION_SEC
            refreshIdleStatus()
        end,
    })

    autoSummitMainToggle = MainTab:CreateToggle({
        Name = "Auto Summit",
        Flag = "daun_auto_summit_enabled",
        CurrentValue = false,
        Callback = function(enabled)
            autoSummitEnabled = enabled == true
            if not autoSummitEnabled then
                autoSummitConfigBridge.pendingStartDelay = false
                autoSummitLoopToken += 1
                cancelActiveTween()
                refreshIdleStatus()
                return
            end
            autoSummitLoopToken += 1
            local myToken = autoSummitLoopToken
            local fromConfig = autoSummitConfigBridge.pendingStartDelay
            task.spawn(function()
                runAutoSummitLoop(myToken)
            end)
            if not fromConfig then
                mountNotify({ Title = "Auto Summit", Content = "Auto Summit started" })
            end
        end,
    })

    MainTab:CreateSection("Checkpoint")

    MainTab:CreateDropdown({
        Name = "Checkpoint",
        Flag = "daun_checkpoint_select",
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

    -- */  Auto Carry  /* --
    -- Place uses Zap Network: ContextMenuAction.Fire to request, CarryRespond.Fire to accept.
    MainTab:CreateSection("Auto Carry")

    local CARRY_ACTIONS = {
        ["Head Carry"] = "HeadCarry",
        ["Piggyback Carry"] = "PiggybackCarry",
        ["Drag Carry"] = "DragCarry",
    }
    local CARRY_TYPE_OPTIONS = { "Head Carry", "Piggyback Carry", "Drag Carry" }
    local SEND_REQUEST_CARRY_DELAY_PER_TARGET = 4
    local SEND_REQUEST_CARRY_CYCLE_GAP = 6
    local SEND_REQUEST_CARRY_MAX_DISTANCE_STUDS = 20

    local lpCarry = Players.LocalPlayer
    local carryNetwork = nil
    local carryTypeLabel = "Head Carry"
    local sendRequestCarrySelected = {}
    local sendRequestCarryAdditionalPlayersText = ""
    local sendRequestCarryAutoLoopToken = 0
    local sendRequestCarryAutoNearbyLoopToken = 0
    local sendRequestCarryAutoEnabled = false
    local sendRequestCarryAutoNearbyEnabled = false
    local carriedSlotIds = {}
    local carriedSlotEntries = {}
    local acceptIncomingCarrySelected = {}
    local acceptIncomingCarryEnabled = false
    local acceptIncomingCarryDisconnect = nil

    local SendRequestCarryCarrierListParagraph
    local SendRequestCarryPlayersDropdown
    local AcceptIncomingCarryPlayersDropdown

    local function getCarryNetwork()
        if carryNetwork then
            return carryNetwork
        end
        local ok, network = pcall(function()
            return require(ReplicatedStorage:WaitForChild("Network", 15))
        end)
        if ok and type(network) == "table" and network.ContextMenuAction and network.CarryRespond and network.CarryRequestPrompt then
            carryNetwork = network
            return network
        end
        return nil
    end

    local function carryActionFromLabel(label)
        return CARRY_ACTIONS[label] or "HeadCarry"
    end

    local function carryNormalizeUserId(userId)
        if typeof(userId) ~= "number" then
            userId = tonumber(tostring(userId))
        end
        if not userId or userId <= 0 then
            return nil
        end
        return userId
    end

    local function carryOtherPlayerLabel(player)
        if not player then
            return ""
        end
        local dn = player.DisplayName
        if dn and dn ~= "" then
            return dn
        end
        return player.Name
    end

    local function carryDropdownOptions()
        local opts = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lpCarry and plr.ClassName == "Player" then
                table.insert(opts, carryOtherPlayerLabel(plr))
            end
        end
        table.sort(opts, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return opts
    end

    local function carryFindPlayerByLabel(label)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lpCarry and carryOtherPlayerLabel(plr) == label then
                return plr
            end
        end
        return nil
    end

    local function carryTrim(s)
        if typeof(s) ~= "string" then
            return ""
        end
        return (s:gsub("^%s+", ""):gsub("%s+$", ""))
    end

    local function carryFindOtherPlayerByVisibleName(nameQuery)
        local q = carryTrim(nameQuery)
        if q == "" then
            return nil
        end
        local lowerQ = string.lower(q)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lpCarry and plr.ClassName == "Player" then
                local label = carryOtherPlayerLabel(plr)
                if label == q or string.lower(label) == lowerQ or string.lower(plr.Name) == lowerQ then
                    return plr
                end
            end
        end
        return nil
    end

    local function carryResolveAdditionalPlayersToUserIds(str)
        local out = {}
        local seen = {}
        if typeof(str) ~= "string" or str == "" then
            return out
        end
        for segment in string.gmatch(str, "([^,;\n]+)") do
            local plr = carryFindOtherPlayerByVisibleName(segment)
            if plr then
                local uid = carryNormalizeUserId(plr.UserId)
                if uid and not seen[uid] then
                    seen[uid] = true
                    table.insert(out, uid)
                end
            end
        end
        return out
    end

    local function carryGetRootPart(character)
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

    local function carryIsTargetWithinRange(targetUserId, maxDist)
        local uid = carryNormalizeUserId(targetUserId)
        if not uid then
            return false
        end
        local myRoot = carryGetRootPart(lpCarry and lpCarry.Character)
        if not myRoot then
            return false
        end
        local tgtPlr = Players:GetPlayerByUserId(uid)
        if not tgtPlr or tgtPlr == lpCarry then
            return false
        end
        local tRoot = carryGetRootPart(tgtPlr.Character)
        if not tRoot then
            return false
        end
        return (myRoot.Position - tRoot.Position).Magnitude <= maxDist
    end

    local function carryIsAlreadyCarrying(userId)
        local uid = carryNormalizeUserId(userId)
        return uid ~= nil and carriedSlotIds[uid] == true
    end

    local function carryUpdateCarrierListParagraph()
        if not SendRequestCarryCarrierListParagraph or not SendRequestCarryCarrierListParagraph.Set then
            return
        end
        local content
        if #carriedSlotEntries == 0 then
            content = "(not carrying anyone)"
        else
            local lines = {}
            for _, e in ipairs(carriedSlotEntries) do
                local nm = e.name
                if not nm or nm == "" then
                    nm = "?"
                end
                local line = "• " .. nm .. "  [" .. tostring(e.id) .. "]"
                if e.carryType and e.carryType ~= "" then
                    line = line .. "  (" .. e.carryType .. ")"
                end
                table.insert(lines, line)
            end
            content = table.concat(lines, "\n")
        end
        SendRequestCarryCarrierListParagraph:Set({
            Title = "Carrying",
            Content = content,
        })
    end

    local function carryApplySlots(data)
        local newSet = {}
        local entries = {}
        local slots = type(data) == "table" and data.slots or nil
        if type(slots) == "table" then
            for _, entry in ipairs(slots) do
                if type(entry) == "table" then
                    local eid = carryNormalizeUserId(entry.userId)
                    if eid then
                        newSet[eid] = true
                        local ename = entry.name
                        if typeof(ename) ~= "string" or ename == "" then
                            local plr = Players:GetPlayerByUserId(eid)
                            ename = plr and carryOtherPlayerLabel(plr) or "?"
                        end
                        table.insert(entries, {
                            name = ename,
                            id = eid,
                            carryType = typeof(entry.carryType) == "string" and entry.carryType or "",
                        })
                    end
                end
            end
        end
        carriedSlotIds = newSet
        carriedSlotEntries = entries
        carryUpdateCarrierListParagraph()
    end

    local function carryFireRequest(network, targetUserId)
        local uid = carryNormalizeUserId(targetUserId)
        if not network or not uid then
            return false
        end
        local ok = pcall(function()
            network.ContextMenuAction.Fire({
                action = carryActionFromLabel(carryTypeLabel),
                targetUserId = uid,
                amount = 0,
            })
        end)
        return ok
    end

    local function carryCollectTargetIds()
        local ids = {}
        local seen = {}
        local function addId(id)
            local uid = carryNormalizeUserId(id)
            if uid and not seen[uid] and not carryIsAlreadyCarrying(uid) then
                seen[uid] = true
                table.insert(ids, uid)
            end
        end
        for _, label in ipairs(sendRequestCarrySelected) do
            local plr = carryFindPlayerByLabel(label)
            if plr then
                addId(plr.UserId)
            end
        end
        for _, n in ipairs(carryResolveAdditionalPlayersToUserIds(sendRequestCarryAdditionalPlayersText)) do
            addId(n)
        end
        return ids
    end

    local function carryCollectAllOtherIds()
        local ids = {}
        local seen = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lpCarry and plr.ClassName == "Player" then
                local uid = carryNormalizeUserId(plr.UserId)
                if uid and not seen[uid] and not carryIsAlreadyCarrying(uid) then
                    seen[uid] = true
                    table.insert(ids, uid)
                end
            end
        end
        return ids
    end

    local function carrySpawnAutoLoop(network, startToken, getToken, getTargets, noTargetMsg)
        local warnedNoTargets = false
        task.spawn(function()
            while startToken == getToken() do
                local targets = getTargets()
                if #targets == 0 then
                    if not warnedNoTargets and noTargetMsg then
                        warnedNoTargets = true
                        mountNotify({
                            Title = "Auto Carry",
                            Content = noTargetMsg,
                        })
                    end
                    task.wait(5)
                else
                    warnedNoTargets = false
                    for _, targetId in ipairs(targets) do
                        if startToken ~= getToken() then
                            break
                        end
                        if carryIsTargetWithinRange(targetId, SEND_REQUEST_CARRY_MAX_DISTANCE_STUDS) then
                            carryFireRequest(network, targetId)
                            task.wait(SEND_REQUEST_CARRY_DELAY_PER_TARGET)
                        end
                    end
                    task.wait(SEND_REQUEST_CARRY_CYCLE_GAP)
                end
            end
        end)
    end

    local function carryPurgeStaleSelections(selected, dropdown)
        local opts = carryDropdownOptions()
        local valid = {}
        for _, sel in ipairs(selected) do
            if table.find(opts, sel) then
                table.insert(valid, sel)
            end
        end
        if #valid ~= #selected and dropdown and dropdown.Set then
            dropdown:Set(valid)
        end
        return valid
    end

    local function carryRefreshPlayerLists()
        local opts = carryDropdownOptions()
        if SendRequestCarryPlayersDropdown and SendRequestCarryPlayersDropdown.Refresh then
            SendRequestCarryPlayersDropdown:Refresh(opts)
        end
        if AcceptIncomingCarryPlayersDropdown and AcceptIncomingCarryPlayersDropdown.Refresh then
            AcceptIncomingCarryPlayersDropdown:Refresh(opts)
        end
        sendRequestCarrySelected = carryPurgeStaleSelections(sendRequestCarrySelected, SendRequestCarryPlayersDropdown)
        acceptIncomingCarrySelected = carryPurgeStaleSelections(acceptIncomingCarrySelected, AcceptIncomingCarryPlayersDropdown)
    end

    local function acceptIncomingCarryShouldAccept(prompt)
        if not acceptIncomingCarrySelected or #acceptIncomingCarrySelected == 0 then
            return true
        end
        local fromName = prompt and tostring(prompt.requesterName or "") or ""
        local fromId = carryNormalizeUserId(prompt and prompt.requesterUserId)
        for _, opt in ipairs(acceptIncomingCarrySelected) do
            if fromName ~= "" and fromName == opt then
                return true
            end
            local plr = carryFindPlayerByLabel(opt)
            if plr then
                if fromId and carryNormalizeUserId(plr.UserId) == fromId then
                    return true
                end
                if fromName == plr.Name or fromName == plr.DisplayName or fromName == carryOtherPlayerLabel(plr) then
                    return true
                end
            end
        end
        return false
    end

    local function acceptIncomingCarryOnPrompt(prompt)
        if not acceptIncomingCarryEnabled or type(prompt) ~= "table" then
            return
        end
        if not acceptIncomingCarryShouldAccept(prompt) then
            return
        end
        local requestId = prompt.requestId
        if typeof(requestId) ~= "number" then
            requestId = tonumber(tostring(requestId))
        end
        if not requestId then
            return
        end
        local network = getCarryNetwork()
        if not network then
            return
        end
        pcall(function()
            network.CarryRespond.Fire({
                requestId = requestId,
                accepted = true,
            })
        end)
    end

    SendRequestCarryCarrierListParagraph = MainTab:CreateParagraph({
        Title = "Carrying",
        Content = "(not carrying anyone)",
    })

    MainTab:CreateDropdown({
        Name = "Carry Type",
        Flag = "daun_carry_type",
        Options = CARRY_TYPE_OPTIONS,
        CurrentOption = { carryTypeLabel },
        Callback = function(value)
            carryTypeLabel = rayfieldDropdownFirst(value) or "Head Carry"
        end,
    })

    SendRequestCarryPlayersDropdown = MainTab:CreateDropdown({
        Name = "To",
        Flag = "daun_main_send_carry_to",
        Options = carryDropdownOptions(),
        CurrentOption = {},
        MultipleOptions = true,
        Search = true,
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
        Name = "By Name (additional)",
        Flag = "daun_main_send_carry_by_name",
        PlaceholderText = "Display names, e.g. kyazuramoe, FriendName",
        CurrentValue = "",
        Callback = function(value)
            sendRequestCarryAdditionalPlayersText = value or ""
        end,
    })

    local SendRequestCarryAutoToggle
    local SendRequestCarryAutoNearbyToggle
    SendRequestCarryAutoToggle = MainTab:CreateToggle({
        Name = "Auto Send",
        Flag = "daun_main_send_carry_auto",
        CurrentValue = false,
        Callback = function(enabled)
            sendRequestCarryAutoEnabled = enabled == true
            sendRequestCarryAutoLoopToken += 1
            if not sendRequestCarryAutoEnabled then
                return
            end

            if sendRequestCarryAutoNearbyEnabled and SendRequestCarryAutoNearbyToggle and SendRequestCarryAutoNearbyToggle.Set then
                SendRequestCarryAutoNearbyToggle:Set(false)
            end

            local network = getCarryNetwork()
            if not network then
                mountNotify({
                    Title = "Auto Carry",
                    Content = "Network module not found",
                })
                if SendRequestCarryAutoToggle and SendRequestCarryAutoToggle.Set then
                    SendRequestCarryAutoToggle:Set(false)
                end
                return
            end

            carrySpawnAutoLoop(
                network,
                sendRequestCarryAutoLoopToken,
                function()
                    return sendRequestCarryAutoLoopToken
                end,
                carryCollectTargetIds,
                "No targets — select players and/or add names that match someone in the server"
            )

            mountNotify({
                Title = "Auto Carry",
                Content = "Auto send started (" .. carryTypeLabel .. ")",
            })
        end,
    })

    SendRequestCarryAutoNearbyToggle = MainTab:CreateToggle({
        Name = "Auto Send Nearby",
        Flag = "daun_main_send_carry_auto_nearby",
        CurrentValue = false,
        Callback = function(enabled)
            sendRequestCarryAutoNearbyEnabled = enabled == true
            sendRequestCarryAutoNearbyLoopToken += 1
            if not sendRequestCarryAutoNearbyEnabled then
                return
            end

            if sendRequestCarryAutoEnabled and SendRequestCarryAutoToggle and SendRequestCarryAutoToggle.Set then
                SendRequestCarryAutoToggle:Set(false)
            end

            local network = getCarryNetwork()
            if not network then
                mountNotify({
                    Title = "Auto Carry",
                    Content = "Network module not found",
                })
                if SendRequestCarryAutoNearbyToggle and SendRequestCarryAutoNearbyToggle.Set then
                    SendRequestCarryAutoNearbyToggle:Set(false)
                end
                return
            end

            carrySpawnAutoLoop(
                network,
                sendRequestCarryAutoNearbyLoopToken,
                function()
                    return sendRequestCarryAutoNearbyLoopToken
                end,
                carryCollectAllOtherIds,
                "No nearby players to send to"
            )

            mountNotify({
                Title = "Auto Carry",
                Content = "Auto send nearby started (" .. carryTypeLabel .. ")",
            })
        end,
    })

    -- */  Auto Accept Carry  /* --
    MainTab:CreateSection("Auto Accept Carry")

    AcceptIncomingCarryPlayersDropdown = MainTab:CreateDropdown({
        Name = "From",
        Flag = "daun_main_accept_carry_from",
        Options = carryDropdownOptions(),
        CurrentOption = {},
        MultipleOptions = true,
        Search = true,
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
        Name = "Auto Accept",
        Flag = "daun_main_accept_carry_auto",
        CurrentValue = false,
        Callback = function(enabled)
            acceptIncomingCarryEnabled = enabled == true
            if acceptIncomingCarryDisconnect then
                pcall(acceptIncomingCarryDisconnect)
                acceptIncomingCarryDisconnect = nil
            end
            if not acceptIncomingCarryEnabled then
                return
            end
            local network = getCarryNetwork()
            if not network or not network.CarryRequestPrompt or not network.CarryRequestPrompt.On then
                mountNotify({
                    Title = "Auto Accept Carry",
                    Content = "Network module not found",
                })
                if AcceptIncomingCarryListenToggle and AcceptIncomingCarryListenToggle.Set then
                    AcceptIncomingCarryListenToggle:Set(false)
                end
                return
            end
            local ok, disconnect = pcall(function()
                return network.CarryRequestPrompt.On(acceptIncomingCarryOnPrompt)
            end)
            if ok and type(disconnect) == "function" then
                acceptIncomingCarryDisconnect = disconnect
            end
            mountNotify({
                Title = "Auto Accept Carry",
                Content = "Listening for carry prompts",
            })
        end,
    })

    Players.PlayerAdded:Connect(function()
        task.defer(carryRefreshPlayerLists)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(carryRefreshPlayerLists)
    end)
    task.defer(carryRefreshPlayerLists)

    task.defer(function()
        local network = getCarryNetwork()
        if not network or not network.CarrySlots or not network.CarrySlots.On then
            return
        end
        pcall(function()
            network.CarrySlots.On(carryApplySlots)
        end)
    end)

    local function hookCheckpointInstance(inst)
        if not inst then
            return
        end
        if inst:IsA("StringValue") or inst:IsA("IntValue") or inst:IsA("NumberValue") then
            inst:GetPropertyChangedSignal("Value"):Connect(refreshIdleStatus)
        end
        local nested = inst:FindFirstChild("Value") or inst:FindFirstChildWhichIsA("StringValue")
            or inst:FindFirstChildWhichIsA("IntValue")
        if nested and nested ~= inst then
            nested:GetPropertyChangedSignal("Value"):Connect(refreshIdleStatus)
        end
    end

    local function hookLeaderstats(leaderstats)
        if not leaderstats then
            return
        end
        hookCheckpointInstance(leaderstats:FindFirstChild("Checkpoint"))
        leaderstats.ChildAdded:Connect(function(child)
            if child.Name == "Checkpoint" then
                hookCheckpointInstance(child)
                refreshIdleStatus()
            end
        end)
    end

    local lp = Players.LocalPlayer
    if lp then
        local leaderstats = lp:FindFirstChild("leaderstats")
        if leaderstats then
            hookLeaderstats(leaderstats)
        end
        lp.ChildAdded:Connect(function(child)
            if child.Name == "leaderstats" then
                hookLeaderstats(child)
                refreshIdleStatus()
            end
        end)
    end

    task.defer(refreshIdleStatus)
end

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "daun", tabIcon = "map-pin" })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, {
    replicatedStorage = ReplicatedStorage,
    tabIcon = "boxes",
})


-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, {
    gamePath = "sempatpanick/mount_daun",
    tabIcon = "video",
})

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/mount_daun",
    rayfieldLibrary = SempatLibrary,
    tabIcon = "settings",
    applyLastFlags = { "daun_auto_summit_enabled" },
    onApplyFlag = function(flagName, saved)
        if flagName == "daun_auto_summit_enabled" then
            autoSummitConfigBridge.pendingStartDelay = saved == true
        end
        return saved
    end,
})
