local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local Workspace = cloneref(game:GetService("Workspace"))
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

local daunNetwork = nil
local function getDaunNetwork()
    if daunNetwork then
        return daunNetwork
    end
    local ok, network = pcall(function()
        return require(ReplicatedStorage:WaitForChild("Network", 15))
    end)
    if ok and type(network) == "table" then
        daunNetwork = network
        return network
    end
    return nil
end

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", "mountain")

    local SUMMIT_ARRIVAL_RADIUS = 80
    local DEFAULT_TELEPORT_DURATION_SEC = 5
    local MIN_ROUTE_DELAY_SEC = 5
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
        entry.delay = math.max(MIN_ROUTE_DELAY_SEC, tonumber(entry.delay) or DEFAULT_TELEPORT_DURATION_SEC)
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
            return math.max(MIN_ROUTE_DELAY_SEC, d)
        end
        return math.max(MIN_ROUTE_DELAY_SEC, tonumber(teleportDurationSec) or DEFAULT_TELEPORT_DURATION_SEC)
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

    -- Updated by Auto Carry (CarrySlots). Used when LocalPlayer Checkpoint does not advance.
    local carriedProgressIds = {}

    local function getCheckpointInstanceForPlayer(player)
        if not player then
            return nil
        end
        local leaderstats = player:FindFirstChild("leaderstats")
        if not leaderstats then
            return nil
        end
        return leaderstats:FindFirstChild("Checkpoint")
    end

    local function getCheckpointInstance()
        return getCheckpointInstanceForPlayer(Players.LocalPlayer)
    end

    local function getCheckpointLabelForPlayer(player)
        return readValueInstance(getCheckpointInstanceForPlayer(player))
    end

    local function getCheckpointLabel()
        return getCheckpointLabelForPlayer(Players.LocalPlayer)
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

    local function carryOtherPlayerDisplayName(player)
        if not player then
            return "?"
        end
        local dn = player.DisplayName
        if dn and dn ~= "" then
            return dn
        end
        return player.Name
    end

    -- Prefer LocalPlayer; if their Checkpoint is behind, use the furthest carried player.
    local function getEffectiveCheckpointRouteIndex()
        local maxIdx = checkpointRouteIndex(getCheckpointLabel())
        local lp = Players.LocalPlayer
        for userId in pairs(carriedProgressIds) do
            local plr = Players:GetPlayerByUserId(userId)
            if plr and plr ~= lp then
                maxIdx = math.max(maxIdx, checkpointRouteIndex(getCheckpointLabelForPlayer(plr)))
            end
        end
        return maxIdx
    end

    local function nextRouteIndexFromCheckpoint()
        local idx = getEffectiveCheckpointRouteIndex()
        if idx >= #summitRoute then
            return #summitRoute + 1
        end
        return idx + 1
    end

    -- Returns matched, label, viaName (nil = LocalPlayer).
    local function checkpointMatchesAnyProgress(entry)
        local localLabel = getCheckpointLabel()
        if checkpointMatchesRouteEntry(localLabel, entry) then
            return true, localLabel, nil
        end
        local lp = Players.LocalPlayer
        for userId in pairs(carriedProgressIds) do
            local plr = Players:GetPlayerByUserId(userId)
            if plr and plr ~= lp then
                local label = getCheckpointLabelForPlayer(plr)
                if checkpointMatchesRouteEntry(label, entry) then
                    return true, label, carryOtherPlayerDisplayName(plr)
                end
            end
        end
        return false, localLabel, nil
    end

    local function formatCheckpointStatusLabel(label, viaName)
        local shown = displayCheckpointLabel(label)
        if viaName then
            return shown .. " (via " .. viaName .. ")"
        end
        return shown
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
            local cpOk, checkpointNow, viaName = checkpointMatchesAnyProgress(routeEntry)
            local posOk = isNearRouteEntry(routeEntry, SUMMIT_ARRIVAL_RADIUS)
            if cpOk and posOk then
                return true
            end
            if isSummitStep and posOk then
                return true
            end
            if os.clock() >= retryDeadline then
                return false
            end
            setStatusContent(string.format(
                "Confirming %s…\nCheckpoint: %s\nExpected: %s",
                routeEntry.name,
                formatCheckpointStatusLabel(checkpointNow, viaName),
                expectedCheckpointName(routeEntry)
            ))
            task.wait(POST_TELEPORT_POLL_SEC)
        end
        return false
    end

    local function isAtRouteCheckpoint(entry)
        if not entry then
            return false
        end
        local cpOk = checkpointMatchesAnyProgress(entry)
        local posOk = isNearRouteEntry(entry, SUMMIT_ARRIVAL_RADIUS)
        return cpOk and posOk
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

    -- Before teleporting to the next CP, confirm the current one registered.
    -- If leaderstats or position still do not match this CP, retry that teleport.
    local function ensureCurrentCheckpointBeforeNext(token, nextIndex)
        if nextIndex <= 1 then
            return true
        end
        local currentEntry = summitRoute[nextIndex - 1]
        if not currentEntry then
            return true
        end
        if isAtRouteCheckpoint(currentEntry) then
            return true
        end
        setStatusContent(string.format(
            "Current CP not confirmed — retrying %s…\nCheckpoint: %s",
            currentEntry.name,
            displayCheckpointLabel(getCheckpointLabel())
        ))
        return moveUntilCheckpointRegistered(token, currentEntry, currentEntry.name == "Summit")
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

            if not ensureCurrentCheckpointBeforeNext(token, nextIndex) then
                break
            end
            nextIndex = nextRouteIndexFromCheckpoint()
            if resumeFromStart then
                resumeFromStart = false
                nextIndex = 1
            end
            if nextIndex > #summitRoute then
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
            Range = { MIN_ROUTE_DELAY_SEC, 50 },
            Increment = 0.5,
            Suffix = "s",
            CurrentValue = getRouteDelaySec(entry),
            Callback = function(value)
                entry.delay = math.max(MIN_ROUTE_DELAY_SEC, tonumber(value) or DEFAULT_TELEPORT_DURATION_SEC)
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
        local network = getDaunNetwork()
        if network and network.ContextMenuAction and network.CarryRespond and network.CarryRequestPrompt then
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
        carriedProgressIds = newSet
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

-- */  Fishing Tab  /* --
do
    local FishingTab = Window:CreateTab("Fishing", "fish")

    local FISH_INVENTORY_MAX = 500
    local FISH_FORCE_MODES = { "Fish", "Rarity", "WeightOnly", "Clear" }
    local FISH_HOTSPOT_ZONES = { "danau", "pantai" }
    local FISH_RARITY_OPTIONS = {
        "Common",
        "Shockingly Common",
        "Uncommon",
        "Shockingly Rare",
        "Rare",
        "Shockingly Epic",
        "Epic",
        "Shockingly Legendary",
        "Legendary",
        "Shockingly Mythic",
        "Mythical",
        "Exotic",
        "Special",
        "Divine",
        "Cosmic",
        "Celestial",
        "Event",
        "Abyssal",
        "Ethereal",
    }

    local lpFish = Players.LocalPlayer
    local fishingStatusParagraph
    local fishIndexParagraph
    local pityParagraph
    local fishNameDropdown
    local rodNameDropdown
    local autoFishToggle

    local autoFishEnabled = false
    local autoFishLoopToken = 0
    local MIN_INSTANT_FISH_DELAY_SEC = 3
    local autoFishDelaySec = MIN_INSTANT_FISH_DELAY_SEC
    local instantAfterCastSec = MIN_INSTANT_FISH_DELAY_SEC
    local autoFishPower = 100
    local autoSellWhenFull = false
    local autoFavoriteEnabled = false
    local autoFavoriteRarities = {}
    local autoFavoriteNames = {}
    local autoFavoriteRaritySet = {}
    local autoFavoriteNameSet = {}
    local autoFavoriteNamesDropdown

    local inventoryFish = {}
    local lastCatchName = nil
    local lastCatchRarity = nil
    local lastCatchWeight = nil
    local lastCatchMessage = nil
    local lastCatchSuccess = nil
    local lastFishId = nil
    local selectedFishName = nil
    local selectedRodName = "Wooden Rod"
    local grantWeight = 5
    local grantCount = 1
    local forceNextMode = "Fish"
    local forceNextRarity = "Common"
    local biteOverrideSec = 0
    local adminCoinsAmount = 1000
    local adminLuckMultiplier = 1
    local adminLuckDurationSec = 60
    local adminSellMultiplier = 1
    local selectedHotspotZone = "danau"
    local fishById = {}
    local fishIndexEntries = {}
    local fishIndexDiscovered = 0

    local function getFishingNetwork()
        local network = getDaunNetwork()
        if network and network.FishCatchRequest then
            return network
        end
        return nil
    end

    local function fireNetwork(remote, payload)
        if type(remote) ~= "table" or type(remote.Fire) ~= "function" then
            return false
        end
        local ok = pcall(function()
            if payload == nil then
                remote.Fire()
            else
                remote.Fire(payload)
            end
        end)
        return ok
    end

    local function callNetwork(remote, payload)
        if type(remote) ~= "table" or type(remote.Call) ~= "function" then
            return nil, "Call missing"
        end
        local ok, result = pcall(function()
            return remote.Call(payload)
        end)
        if not ok then
            return nil, result
        end
        return result
    end

    local function notifyAdminFail(content)
        mountNotify({
            Title = "Fishing",
            Content = content or "Admin action failed (likely not admin).",
        })
    end

    local function fishVec(pos)
        if typeof(pos) == "Vector3" then
            return { x = pos.X, y = pos.Y, z = pos.Z }
        end
        return nil
    end

    local function getEquippedRod()
        local character = lpFish and lpFish.Character
        if not character then
            return nil
        end
        local fallback = nil
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Tool") then
                local tagged = false
                pcall(function()
                    tagged = CollectionService:HasTag(child, "Rod")
                end)
                if tagged then
                    return child
                end
                if not fallback and child:FindFirstChild("Part") and not child:FindFirstChild("FishId") then
                    fallback = child
                end
            end
        end
        return fallback
    end

    local function getEquippedRodName()
        local rod = getEquippedRod()
        if rod then
            return rod.Name
        end
        return nil
    end

    local function getRodPart(rod)
        if not rod then
            return nil
        end
        local part = rod:FindFirstChild("Part")
        if part and part:IsA("BasePart") then
            return part
        end
        return rod:FindFirstChildWhichIsA("BasePart", true)
    end

    local function getLocalRootPart()
        local character = lpFish and lpFish.Character
        if not character then
            return nil
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            return root
        end
        return character.PrimaryPart
    end

    local function getHookPosition(rod)
        local part = getRodPart(rod)
        if part then
            return part.Position
        end
        local root = getLocalRootPart()
        if root then
            return root.Position
        end
        return nil
    end

    local function getCastVelocity(root, power)
        if not root then
            return Vector3.new(0, 20, 40)
        end
        local look = root.CFrame.LookVector
        local p = math.clamp(tonumber(power) or 100, 0, 100)
        return look * (18 + p * 0.55) + Vector3.new(0, 12 + p * 0.12, 0)
    end

    local function loadRodNames()
        local names = {}
        local seen = {}
        local ok, config = pcall(function()
            local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
            local fishingConfig = fishingSystem and fishingSystem:FindFirstChild("FishingConfig")
            if not fishingConfig then
                return nil
            end
            return require(fishingConfig)
        end)
        if ok and type(config) == "table" and type(config.RodConfig) == "table" then
            for rodName in pairs(config.RodConfig) do
                if type(rodName) == "string" and rodName ~= "default" and not seen[rodName] then
                    seen[rodName] = true
                    table.insert(names, rodName)
                end
            end
        end
        table.sort(names)
        if #names == 0 then
            names = { "Wooden Rod" }
        end
        return names
    end

    local function loadFishNames()
        local names = {}
        local seen = {}
        fishById = {}
        local ok, fishData = pcall(function()
            local fishingSystem = ReplicatedStorage:FindFirstChild("FishingSystem")
            local modules = fishingSystem and fishingSystem:FindFirstChild("FishModules")
            local fishDataModule = modules and modules:FindFirstChild("FishData")
            if not fishDataModule then
                return nil
            end
            return require(fishDataModule)
        end)
        if ok and type(fishData) == "table" and type(fishData.List) == "table" then
            for _, entry in ipairs(fishData.List) do
                local data = entry and entry.Data
                local name = data and data.Name
                local id = data and tonumber(data.Id)
                if type(name) == "string" and name ~= "" then
                    if id and id ~= 0 then
                        fishById[id] = {
                            name = name,
                            rarity = entry.Rarity or "Common",
                        }
                    end
                    if not seen[name] then
                        seen[name] = true
                        table.insert(names, name)
                    end
                end
            end
        end
        table.sort(names)
        if #names == 0 then
            names = { "(none)" }
        end
        return names
    end

    local function inventoryCount()
        return #inventoryFish
    end

    local function findFishIdByName(name)
        if type(name) ~= "string" or name == "" then
            return nil
        end
        for i = #inventoryFish, 1, -1 do
            local item = inventoryFish[i]
            if type(item) == "table" and item.name == name and type(item.id) == "string" then
                return item.id
            end
        end
        return nil
    end

    local function setSelectedLookup(list, set)
        table.clear(set)
        if type(list) ~= "table" then
            return
        end
        for _, value in ipairs(list) do
            if type(value) == "string" and value ~= "" and value ~= "(none)" then
                set[value] = true
            end
        end
    end

    local function normalizeMultiSelect(selected)
        if type(selected) == "table" then
            return selected
        end
        if selected then
            return { selected }
        end
        return {}
    end

    local function maybeAutoFavorite(change)
        if not autoFavoriteEnabled or type(change) ~= "table" or change.removed or change.favorite then
            return
        end
        local fishId = change.id
        if type(fishId) ~= "string" or fishId == "" then
            return
        end
        local rarityMatch = type(change.rarity) == "string" and autoFavoriteRaritySet[change.rarity] == true
        local nameMatch = type(change.name) == "string" and autoFavoriteNameSet[change.name] == true
        if not (rarityMatch or nameMatch) then
            return
        end
        local network = getFishingNetwork()
        if not network then
            return
        end
        fireNetwork(network.FishInventoryFavoriteToggle, {
            fishId = fishId,
            favorite = true,
        })
    end

    local function refreshFishingStatus()
        if not fishingStatusParagraph or not fishingStatusParagraph.Set then
            return
        end
        local network = getFishingNetwork()
        local rodName = getEquippedRodName() or selectedRodName or "—"
        local lastLine = "—"
        if lastCatchName then
            lastLine = string.format(
                "%s %.1fkg %s",
                tostring(lastCatchRarity or "?"),
                tonumber(lastCatchWeight) or 0,
                lastCatchName
            )
        elseif lastCatchMessage and lastCatchMessage ~= "" then
            lastLine = lastCatchMessage
        end
        local catchNote = "untested"
        if lastCatchSuccess == true then
            catchNote = "last catch ok"
        elseif lastCatchSuccess == false then
            catchNote = "last catch failed"
        end
        fishingStatusParagraph:Set({
            Content = string.format(
                "Network: %s\nRod: %s\nInventory: %d/%d\nLast catch: %s\n%s",
                network and "ok" or "missing",
                rodName,
                inventoryCount(),
                FISH_INVENTORY_MAX,
                lastLine,
                catchNote
            ),
        })
    end

    local function requestInventory(network)
        network = network or getFishingNetwork()
        if not network then
            return
        end
        fireNetwork(network.FishInventoryRequest, {})
    end

    local function requestFishIndex(network)
        network = network or getFishingNetwork()
        if not network then
            return
        end
        fireNetwork(network.FishIndexRequest, {})
    end

    local function fishNameFromIndexId(id)
        local info = fishById[tonumber(id)]
        if info and info.name then
            return info.name
        end
        return "id " .. tostring(id)
    end
    local function refreshFishIndexParagraph()
        if not fishIndexParagraph or not fishIndexParagraph.Set then
            return
        end
        local totalKnown = 0
        for _ in pairs(fishById) do
            totalKnown += 1
        end
        if #fishIndexEntries == 0 then
            fishIndexParagraph:Set({
                Content = string.format("Discovered: 0 / %d\nRefresh to load index.", math.max(totalKnown, 0)),
            })
            return
        end
        local lines = {
            string.format("Discovered: %d / %d", fishIndexDiscovered, math.max(totalKnown, #fishIndexEntries)),
        }
        local shown = 0
        for _, entry in ipairs(fishIndexEntries) do
            if shown >= 12 then
                table.insert(lines, "…")
                break
            end
            local name = fishNameFromIndexId(entry.id)
            table.insert(lines, string.format(
                "%s  x%d  %.1fkg",
                name,
                tonumber(entry.count) or 0,
                tonumber(entry.heaviest) or 0
            ))
            shown += 1
        end
        fishIndexParagraph:Set({ Content = table.concat(lines, "\n") })
    end

    local function applyIndexEntries(entries)
        fishIndexEntries = {}
        fishIndexDiscovered = 0
        if type(entries) ~= "table" then
            refreshFishIndexParagraph()
            return
        end
        for _, entry in ipairs(entries) do
            table.insert(fishIndexEntries, entry)
            if (tonumber(entry.count) or 0) > 0 then
                fishIndexDiscovered += 1
            end
        end
        table.sort(fishIndexEntries, function(a, b)
            return (tonumber(a.id) or 0) < (tonumber(b.id) or 0)
        end)
        refreshFishIndexParagraph()
    end

    local function tryCatchOnce()
        local network = getFishingNetwork()
        if not network then
            return false, "Network module not found"
        end
        local rod = getEquippedRod()
        local rodName = (rod and rod.Name) or selectedRodName
        if type(rodName) ~= "string" or rodName == "" then
            return false, "Select or equip a rod first"
        end
        local hookPos = getHookPosition(rod)
        if not hookPos then
            return false, "Character not loaded"
        end
        local power = math.clamp(math.floor(tonumber(autoFishPower) or 100), 0, 100)
        local root = getLocalRootPart()
        local rodPart = getRodPart(rod)
        local rodPos = rodPart and rodPart.Position or hookPos
        local velocity = getCastVelocity(root, power)

        fireNetwork(network.CastReplication, {
            rodPos = fishVec(rodPos),
            velocity = fishVec(velocity),
            rodName = rodName,
        })
        task.wait(math.max(MIN_INSTANT_FISH_DELAY_SEC, tonumber(instantAfterCastSec) or MIN_INSTANT_FISH_DELAY_SEC))

        local ok = fireNetwork(network.FishCatchRequest, {
            rodName = rodName,
            power = power,
            hookPosition = fishVec(hookPos),
        })
        if not ok then
            return false, "FishCatchRequest failed"
        end
        return true
    end

    local function spawnFishTimes(fishName, weight, count)
        local network = getFishingNetwork()
        if not network or not network.AdminSpawnFish then
            return false, "AdminSpawnFish missing"
        end
        if type(fishName) ~= "string" or fishName == "" or fishName == "(none)" then
            return false, "Select a fish first"
        end
        local userId = lpFish and lpFish.UserId
        if not userId then
            return false, "Local player missing"
        end
        local n = math.max(1, math.floor(tonumber(count) or 1))
        local w = tonumber(weight) or 5
        local fired = 0
        for _ = 1, n do
            if fireNetwork(network.AdminSpawnFish, {
                targetUserId = userId,
                fishName = fishName,
                weight = w,
            }) then
                fired += 1
            end
        end
        if fired == 0 then
            return false, "AdminSpawnFish failed (likely not admin). Use Auto Fish."
        end
        return true, fired
    end

    local function bindFishingNetwork(network)
        if not network then
            return
        end
        if network.FishCaught and type(network.FishCaught.On) == "function" then
            pcall(function()
                network.FishCaught.On(function(payload)
                    if type(payload) ~= "table" then
                        return
                    end
                    lastCatchSuccess = payload.success == true
                    lastCatchName = payload.name
                    lastCatchRarity = payload.rarity
                    lastCatchWeight = payload.weight
                    lastCatchMessage = payload.message
                    if payload.success == true then
                        mountNotify({
                            Title = "Fishing",
                            Content = string.format(
                                "Caught %s %.1fkg %s",
                                tostring(payload.rarity or "?"),
                                tonumber(payload.weight) or 0,
                                tostring(payload.name or "?")
                            ),
                        })
                    else
                        local message = payload.message
                        if type(message) ~= "string" or message == "" then
                            message = "Could not catch fish."
                        end
                        mountNotify({ Title = "Fishing", Content = message })
                        if autoFishEnabled and (string.find(string.lower(message), "full", 1, true) or inventoryCount() >= FISH_INVENTORY_MAX) then
                            if autoSellWhenFull then
                                fireNetwork(network.SellFishRequest, { mode = "all" })
                            else
                                autoFishEnabled = false
                                autoFishLoopToken += 1
                                if autoFishToggle and autoFishToggle.Set then
                                    autoFishToggle:Set(false)
                                end
                            end
                        end
                    end
                    refreshFishingStatus()
                end)
            end)
        end
        if network.FishInventoryLoaded and type(network.FishInventoryLoaded.On) == "function" then
            pcall(function()
                network.FishInventoryLoaded.On(function(payload)
                    if type(payload) == "table" and type(payload.fish) == "table" then
                        inventoryFish = payload.fish
                        lastFishId = findFishIdByName(lastCatchName) or lastFishId
                    end
                    refreshFishingStatus()
                end)
            end)
        end
        if network.FishInventoryItemChanged and type(network.FishInventoryItemChanged.On) == "function" then
            pcall(function()
                network.FishInventoryItemChanged.On(function(change)
                    if type(change) ~= "table" then
                        return
                    end
                    if change.removed then
                        for i = #inventoryFish, 1, -1 do
                            if inventoryFish[i].id == change.id then
                                table.remove(inventoryFish, i)
                            end
                        end
                    else
                        lastFishId = change.id or lastFishId
                        local found = false
                        for i, item in ipairs(inventoryFish) do
                            if item.id == change.id then
                                inventoryFish[i] = change
                                found = true
                                break
                            end
                        end
                        if not found then
                            table.insert(inventoryFish, change)
                        end
                        maybeAutoFavorite(change)
                    end
                    refreshFishingStatus()
                end)
            end)
        end
        if network.AdminActionResult and type(network.AdminActionResult.On) == "function" then
            pcall(function()
                network.AdminActionResult.On(function(result)
                    if type(result) ~= "table" then
                        return
                    end
                    local ok = result.ok
                    if ok == nil then
                        ok = result.success
                    end
                    local message = result.message or result.error or result.reason
                    if ok == false then
                        mountNotify({
                            Title = "Fishing",
                            Content = type(message) == "string" and message ~= "" and message
                                or "Admin action failed (likely not admin). Use Auto Fish.",
                        })
                    elseif type(message) == "string" and message ~= "" then
                        mountNotify({ Title = "Fishing", Content = message })
                    end
                    requestInventory(network)
                    requestFishIndex(network)
                    refreshFishingStatus()
                end)
            end)
        end
        if network.RodPurchaseResult and type(network.RodPurchaseResult.On) == "function" then
            pcall(function()
                network.RodPurchaseResult.On(function(result)
                    if type(result) ~= "table" then
                        return
                    end
                    if result.success then
                        mountNotify({
                            Title = "Fishing",
                            Content = result.message or ("Bought " .. tostring(result.rodName or "rod")),
                        })
                    else
                        mountNotify({
                            Title = "Fishing",
                            Content = result.message or "Rod purchase failed",
                        })
                    end
                    refreshFishingStatus()
                end)
            end)
        end
        if network.FishIndexLoaded and type(network.FishIndexLoaded.On) == "function" then
            pcall(function()
                network.FishIndexLoaded.On(function(payload)
                    if type(payload) == "table" then
                        applyIndexEntries(payload.entries)
                    end
                end)
            end)
        end
        if network.FishIndexChanged and type(network.FishIndexChanged.On) == "function" then
            pcall(function()
                network.FishIndexChanged.On(function(change)
                    if type(change) ~= "table" then
                        return
                    end
                    local found = false
                    for i, entry in ipairs(fishIndexEntries) do
                        if entry.id == change.id then
                            fishIndexEntries[i] = change
                            found = true
                            break
                        end
                    end
                    if not found then
                        table.insert(fishIndexEntries, change)
                    end
                    fishIndexDiscovered = 0
                    for _, entry in ipairs(fishIndexEntries) do
                        if (tonumber(entry.count) or 0) > 0 then
                            fishIndexDiscovered += 1
                        end
                    end
                    refreshFishIndexParagraph()
                end)
            end)
        end
        if network.Notification and type(network.Notification.On) == "function" then
            pcall(function()
                network.Notification.On(function(note)
                    if type(note) ~= "table" then
                        return
                    end
                    if note.kind == "Error" or note.kind == "Warning" then
                        local content = note.message or note.title
                        if type(content) == "string" and content ~= "" then
                            mountNotify({ Title = note.title or "Fishing", Content = content })
                        end
                    end
                end)
            end)
        end
        requestInventory(network)
        requestFishIndex(network)
    end

    local rodNames = loadRodNames()
    selectedRodName = rodNames[1] or "Wooden Rod"
    local fishNames = loadFishNames()
    selectedFishName = fishNames[1]

    FishingTab:CreateSection("Status")
    fishingStatusParagraph = FishingTab:CreateParagraph({
        Title = "Fishing",
        Content = "Loading...",
    })
    FishingTab:CreateButton({
        Name = "Refresh status",
        Callback = function()
            requestInventory()
            refreshFishingStatus()
        end,
    })

    FishingTab:CreateSection("Auto Fish")
    FishingTab:CreateSlider({
        Name = "Delay",
        Flag = "daun_fish_delay",
        Range = { MIN_INSTANT_FISH_DELAY_SEC, 5 },
        Increment = 0.05,
        Suffix = "s",
        CurrentValue = autoFishDelaySec,
        Callback = function(value)
            autoFishDelaySec = math.max(MIN_INSTANT_FISH_DELAY_SEC, tonumber(value) or MIN_INSTANT_FISH_DELAY_SEC)
        end,
    })
    FishingTab:CreateSlider({
        Name = "Delay after cast",
        Flag = "daun_fish_instant_after_cast",
        Range = { MIN_INSTANT_FISH_DELAY_SEC, 5 },
        Increment = 0.05,
        Suffix = "s",
        CurrentValue = instantAfterCastSec,
        Callback = function(value)
            instantAfterCastSec = math.max(MIN_INSTANT_FISH_DELAY_SEC, tonumber(value) or MIN_INSTANT_FISH_DELAY_SEC)
        end,
    })
    FishingTab:CreateSlider({
        Name = "Power",
        Flag = "daun_fish_power",
        Range = { 0, 100 },
        Increment = 1,
        CurrentValue = autoFishPower,
        Callback = function(value)
            autoFishPower = math.clamp(math.floor(tonumber(value) or 100), 0, 100)
        end,
    })
    FishingTab:CreateToggle({
        Name = "Auto sell when full",
        Flag = "daun_fish_auto_sell_full",
        CurrentValue = false,
        Callback = function(value)
            autoSellWhenFull = value == true
        end,
    })
    autoFishToggle = FishingTab:CreateToggle({
        Name = "Auto Fish",
        Flag = "daun_fish_auto",
        CurrentValue = false,
        Callback = function(value)
            autoFishEnabled = value == true
            autoFishLoopToken += 1
            local token = autoFishLoopToken
            if not autoFishEnabled then
                return
            end
            local network = getFishingNetwork()
            if not network then
                autoFishEnabled = false
                if autoFishToggle and autoFishToggle.Set then
                    autoFishToggle:Set(false)
                end
                mountNotify({ Title = "Fishing", Content = "Network module not found" })
                return
            end
            task.spawn(function()
                local lastFailNotifyAt = 0
                while autoFishEnabled and token == autoFishLoopToken do
                    local ok, err = tryCatchOnce()
                    if not ok then
                        local now = os.clock()
                        if now - lastFailNotifyAt >= 4 then
                            lastFailNotifyAt = now
                            mountNotify({ Title = "Fishing", Content = tostring(err or "Catch failed") })
                        end
                    end
                    refreshFishingStatus()
                    task.wait(math.max(MIN_INSTANT_FISH_DELAY_SEC, tonumber(autoFishDelaySec) or MIN_INSTANT_FISH_DELAY_SEC))
                end
            end)
        end,
    })
    FishingTab:CreateButton({
        Name = "Catch once",
        Callback = function()
            local ok, err = tryCatchOnce()
            mountNotify({ Title = "Fishing", Content = ok and "Catch sent" or tostring(err or "Failed") })
            refreshFishingStatus()
        end,
    })

    FishingTab:CreateSection("Inventory")
    FishingTab:CreateButton({
        Name = "Refresh inventory",
        Callback = function()
            requestInventory()
            refreshFishingStatus()
        end,
    })
    FishingTab:CreateButton({
        Name = "Sell all",
        Callback = function()
            local network = getFishingNetwork()
            if not network then
                mountNotify({ Title = "Fishing", Content = "Network module not found" })
                return
            end
            if fireNetwork(network.SellFishRequest, { mode = "all" }) then
                mountNotify({ Title = "Fishing", Content = "Sell all sent" })
            else
                mountNotify({ Title = "Fishing", Content = "Sell all failed" })
            end
            task.delay(0.4, function()
                requestInventory(network)
            end)
        end,
    })
    FishingTab:CreateButton({
        Name = "Sell hand",
        Callback = function()
            local network = getFishingNetwork()
            if not network then
                mountNotify({ Title = "Fishing", Content = "Network module not found" })
                return
            end
            if fireNetwork(network.SellFishRequest, { mode = "hand" }) then
                mountNotify({ Title = "Fishing", Content = "Sell hand sent" })
            else
                mountNotify({ Title = "Fishing", Content = "Sell hand failed" })
            end
            task.delay(0.4, function()
                requestInventory(network)
            end)
        end,
    })
    FishingTab:CreateToggle({
        Name = "Auto favorite",
        Flag = "daun_fish_auto_fav",
        CurrentValue = false,
        Callback = function(value)
            autoFavoriteEnabled = value == true
        end,
    })
    FishingTab:CreateDropdown({
        Name = "Favorite rarities",
        Flag = "daun_fish_auto_fav_rarities",
        Options = FISH_RARITY_OPTIONS,
        CurrentOption = {},
        MultipleOptions = true,
        Search = true,
        Callback = function(selected)
            autoFavoriteRarities = normalizeMultiSelect(selected)
            setSelectedLookup(autoFavoriteRarities, autoFavoriteRaritySet)
        end,
    })
    autoFavoriteNamesDropdown = FishingTab:CreateDropdown({
        Name = "Favorite names",
        Flag = "daun_fish_auto_fav_names",
        Options = fishNames,
        CurrentOption = {},
        MultipleOptions = true,
        Search = true,
        Callback = function(selected)
            autoFavoriteNames = normalizeMultiSelect(selected)
            setSelectedLookup(autoFavoriteNames, autoFavoriteNameSet)
        end,
    })
    FishingTab:CreateButton({
        Name = "Favorite last",
        Callback = function()
            local network = getFishingNetwork()
            local fishId = lastFishId or findFishIdByName(lastCatchName)
            if not network then
                mountNotify({ Title = "Fishing", Content = "Network module not found" })
                return
            end
            if type(fishId) ~= "string" or fishId == "" then
                mountNotify({ Title = "Fishing", Content = "No last fish id" })
                return
            end
            lastFishId = fishId
            if fireNetwork(network.FishInventoryFavoriteToggle, { fishId = fishId, favorite = true }) then
                mountNotify({ Title = "Fishing", Content = "Favorite sent" })
            else
                mountNotify({ Title = "Fishing", Content = "Favorite failed" })
            end
        end,
    })
    FishingTab:CreateButton({
        Name = "Toggle last as tool",
        Callback = function()
            local network = getFishingNetwork()
            local fishId = lastFishId or findFishIdByName(lastCatchName)
            if not network then
                mountNotify({ Title = "Fishing", Content = "Network module not found" })
                return
            end
            if type(fishId) ~= "string" or fishId == "" then
                mountNotify({ Title = "Fishing", Content = "No last fish id" })
                return
            end
            lastFishId = fishId
            if fireNetwork(network.FishInventoryToggleTool, { fishId = fishId }) then
                mountNotify({ Title = "Fishing", Content = "Toggle tool sent" })
            else
                mountNotify({ Title = "Fishing", Content = "Toggle tool failed" })
            end
        end,
    })

    FishingTab:CreateSection("Rods")
    rodNameDropdown = FishingTab:CreateDropdown({
        Name = "Rod",
        Flag = "daun_fish_rod",
        Options = rodNames,
        CurrentOption = { selectedRodName },
        Search = true,
        Callback = function(value)
            selectedRodName = rayfieldDropdownFirst(value) or selectedRodName
        end,
    })
    FishingTab:CreateButton({
        Name = "Equip rod",
        Callback = function()
            local network = getFishingNetwork()
            if not network then
                mountNotify({ Title = "Fishing", Content = "Network module not found" })
                return
            end
            if type(selectedRodName) ~= "string" or selectedRodName == "" then
                mountNotify({ Title = "Fishing", Content = "Select a rod first" })
                return
            end
            if fireNetwork(network.RodEquipRequest, { rodName = selectedRodName }) then
                mountNotify({ Title = "Fishing", Content = "Equip sent: " .. selectedRodName })
            else
                mountNotify({ Title = "Fishing", Content = "Equip failed" })
            end
            task.delay(0.3, refreshFishingStatus)
        end,
    })
    FishingTab:CreateButton({
        Name = "Purchase rod",
        Callback = function()
            local network = getFishingNetwork()
            if not network then
                mountNotify({ Title = "Fishing", Content = "Network module not found" })
                return
            end
            if type(selectedRodName) ~= "string" or selectedRodName == "" then
                mountNotify({ Title = "Fishing", Content = "Select a rod first" })
                return
            end
            if fireNetwork(network.RodPurchaseRequest, { rodName = selectedRodName }) then
                mountNotify({ Title = "Fishing", Content = "Purchase sent: " .. selectedRodName })
            else
                mountNotify({ Title = "Fishing", Content = "Purchase failed" })
            end
        end,
    })

    FishingTab:CreateSection("Index")
    fishIndexParagraph = FishingTab:CreateParagraph({
        Title = "Fish index",
        Content = "Refresh to load index.",
    })
    FishingTab:CreateButton({
        Name = "Refresh index",
        Callback = function()
            requestFishIndex()
            refreshFishIndexParagraph()
        end,
    })
    FishingTab:CreateButton({
        Name = "Reset index (admin)",
        Callback = function()
            local network = getFishingNetwork()
            local userId = lpFish and lpFish.UserId
            if not network or not network.AdminResetFishIndex then
                notifyAdminFail("AdminResetFishIndex missing")
                return
            end
            if not userId then
                mountNotify({ Title = "Fishing", Content = "Local player missing" })
                return
            end
            if fireNetwork(network.AdminResetFishIndex, { targetUserId = userId }) then
                mountNotify({ Title = "Fishing", Content = "Reset index sent" })
            else
                notifyAdminFail()
            end
        end,
    })

    FishingTab:CreateSection("Grant / Duplicate")
    fishNameDropdown = FishingTab:CreateDropdown({
        Name = "Fish",
        Flag = "daun_fish_grant_name",
        Options = fishNames,
        CurrentOption = { selectedFishName },
        Search = true,
        Callback = function(value)
            selectedFishName = rayfieldDropdownFirst(value) or selectedFishName
        end,
    })
    FishingTab:CreateSlider({
        Name = "Weight",
        Flag = "daun_fish_grant_weight",
        Range = { 0.1, 500 },
        Increment = 0.1,
        Suffix = "kg",
        CurrentValue = grantWeight,
        Callback = function(value)
            grantWeight = tonumber(value) or 5
        end,
    })
    FishingTab:CreateSlider({
        Name = "Count",
        Flag = "daun_fish_grant_count",
        Range = { 1, 25 },
        Increment = 1,
        CurrentValue = grantCount,
        Callback = function(value)
            grantCount = math.max(1, math.floor(tonumber(value) or 1))
        end,
    })
    FishingTab:CreateButton({
        Name = "Give fish",
        Callback = function()
            local ok, result = spawnFishTimes(selectedFishName, grantWeight, grantCount)
            if ok then
                mountNotify({ Title = "Fishing", Content = "Spawned " .. tostring(result) .. "x " .. tostring(selectedFishName) })
            else
                mountNotify({ Title = "Fishing", Content = tostring(result) })
            end
            task.delay(0.4, function()
                requestInventory()
                refreshFishingStatus()
            end)
        end,
    })
    FishingTab:CreateButton({
        Name = "Duplicate last",
        Callback = function()
            if type(lastCatchName) ~= "string" or lastCatchName == "" then
                mountNotify({ Title = "Fishing", Content = "No last catch. Use Auto Fish." })
                return
            end
            local weight = tonumber(lastCatchWeight) or grantWeight
            local ok, result = spawnFishTimes(lastCatchName, weight, grantCount)
            if ok then
                mountNotify({ Title = "Fishing", Content = "Duplicated " .. tostring(result) .. "x " .. lastCatchName })
            else
                mountNotify({ Title = "Fishing", Content = tostring(result) })
            end
            task.delay(0.4, function()
                requestInventory()
                refreshFishingStatus()
            end)
        end,
    })
    FishingTab:CreateDropdown({
        Name = "Force next mode",
        Flag = "daun_fish_force_mode",
        Options = FISH_FORCE_MODES,
        CurrentOption = { forceNextMode },
        Callback = function(value)
            forceNextMode = rayfieldDropdownFirst(value) or "Fish"
        end,
    })
    FishingTab:CreateDropdown({
        Name = "Force rarity",
        Flag = "daun_fish_force_rarity",
        Options = FISH_RARITY_OPTIONS,
        CurrentOption = { forceNextRarity },
        Search = true,
        Callback = function(value)
            forceNextRarity = rayfieldDropdownFirst(value) or "Common"
        end,
    })
    FishingTab:CreateButton({
        Name = "Force next catch",
        Callback = function()
            local network = getFishingNetwork()
            if not network or not network.AdminForceNextCatch then
                mountNotify({ Title = "Fishing", Content = "AdminForceNextCatch missing" })
                return
            end
            local userId = lpFish and lpFish.UserId
            if not userId then
                mountNotify({ Title = "Fishing", Content = "Local player missing" })
                return
            end
            local ok = fireNetwork(network.AdminForceNextCatch, {
                targetUserId = userId,
                mode = forceNextMode,
                rarity = forceNextRarity or "",
                fishName = selectedFishName or "",
                weight = grantWeight,
            })
            if ok then
                mountNotify({ Title = "Fishing", Content = "Force next sent (" .. tostring(forceNextMode) .. ")" })
            else
                mountNotify({ Title = "Fishing", Content = "Force next failed (likely not admin). Use Auto Fish." })
            end
        end,
    })

    FishingTab:CreateSection("Admin")
    FishingTab:CreateSlider({
        Name = "Bite wait override",
        Flag = "daun_fish_bite_override",
        Range = { 0, 15 },
        Increment = 0.1,
        Suffix = "s",
        CurrentValue = biteOverrideSec,
        Callback = function(value)
            biteOverrideSec = math.max(0, tonumber(value) or 0)
        end,
    })
    FishingTab:CreateButton({
        Name = "Apply bite override",
        Callback = function()
            local network = getFishingNetwork()
            if not network or not network.AdminSetBiteOverride then
                notifyAdminFail("AdminSetBiteOverride missing")
                return
            end
            if fireNetwork(network.AdminSetBiteOverride, { seconds = biteOverrideSec }) then
                mountNotify({ Title = "Fishing", Content = "Bite override sent: " .. tostring(biteOverrideSec) .. "s" })
            else
                notifyAdminFail()
            end
        end,
    })
    FishingTab:CreateSlider({
        Name = "Give coins",
        Flag = "daun_fish_admin_coins",
        Range = { 100, 100000 },
        Increment = 100,
        CurrentValue = adminCoinsAmount,
        Callback = function(value)
            adminCoinsAmount = math.floor(tonumber(value) or 1000)
        end,
    })
    FishingTab:CreateButton({
        Name = "Give coins to self",
        Callback = function()
            local network = getFishingNetwork()
            local userId = lpFish and lpFish.UserId
            if not network or not network.AdminGiveCoins then
                notifyAdminFail("AdminGiveCoins missing")
                return
            end
            if not userId then
                mountNotify({ Title = "Fishing", Content = "Local player missing" })
                return
            end
            if fireNetwork(network.AdminGiveCoins, { targetUserId = userId, amount = adminCoinsAmount }) then
                mountNotify({ Title = "Fishing", Content = "Give coins sent: " .. tostring(adminCoinsAmount) })
            else
                notifyAdminFail()
            end
        end,
    })
    FishingTab:CreateButton({
        Name = "Give selected rod",
        Callback = function()
            local network = getFishingNetwork()
            local userId = lpFish and lpFish.UserId
            if not network or not network.AdminGiveRod then
                notifyAdminFail("AdminGiveRod missing")
                return
            end
            if type(selectedRodName) ~= "string" or selectedRodName == "" then
                mountNotify({ Title = "Fishing", Content = "Select a rod first" })
                return
            end
            if not userId then
                mountNotify({ Title = "Fishing", Content = "Local player missing" })
                return
            end
            if fireNetwork(network.AdminGiveRod, { targetUserId = userId, rodName = selectedRodName }) then
                mountNotify({ Title = "Fishing", Content = "Give rod sent: " .. selectedRodName })
            else
                notifyAdminFail()
            end
        end,
    })
    FishingTab:CreateSlider({
        Name = "Luck multiplier",
        Flag = "daun_fish_admin_luck",
        Range = { 0.1, 20 },
        Increment = 0.1,
        CurrentValue = adminLuckMultiplier,
        Callback = function(value)
            adminLuckMultiplier = tonumber(value) or 1
        end,
    })
    FishingTab:CreateSlider({
        Name = "Global luck duration",
        Flag = "daun_fish_admin_luck_duration",
        Range = { 1, 3600 },
        Increment = 1,
        Suffix = "s",
        CurrentValue = adminLuckDurationSec,
        Callback = function(value)
            adminLuckDurationSec = math.max(1, math.floor(tonumber(value) or 60))
        end,
    })
    FishingTab:CreateButton({
        Name = "Set player luck",
        Callback = function()
            local network = getFishingNetwork()
            local userId = lpFish and lpFish.UserId
            if not network or not network.AdminSetPlayerLuck then
                notifyAdminFail("AdminSetPlayerLuck missing")
                return
            end
            if not userId then
                mountNotify({ Title = "Fishing", Content = "Local player missing" })
                return
            end
            if fireNetwork(network.AdminSetPlayerLuck, { targetUserId = userId, multiplier = adminLuckMultiplier }) then
                mountNotify({ Title = "Fishing", Content = "Player luck sent x" .. tostring(adminLuckMultiplier) })
            else
                notifyAdminFail()
            end
        end,
    })
    FishingTab:CreateButton({
        Name = "Set global luck",
        Callback = function()
            local network = getFishingNetwork()
            if not network or not network.AdminSetGlobalLuck then
                notifyAdminFail("AdminSetGlobalLuck missing")
                return
            end
            if fireNetwork(network.AdminSetGlobalLuck, {
                multiplier = adminLuckMultiplier,
                durationSeconds = adminLuckDurationSec,
            }) then
                mountNotify({
                    Title = "Fishing",
                    Content = "Global luck sent x" .. tostring(adminLuckMultiplier) .. " for " .. tostring(adminLuckDurationSec) .. "s",
                })
            else
                notifyAdminFail()
            end
        end,
    })
    FishingTab:CreateSlider({
        Name = "Sell multiplier",
        Flag = "daun_fish_admin_sell_mult",
        Range = { 0.1, 20 },
        Increment = 0.1,
        CurrentValue = adminSellMultiplier,
        Callback = function(value)
            adminSellMultiplier = tonumber(value) or 1
        end,
    })
    FishingTab:CreateButton({
        Name = "Set sell multiplier",
        Callback = function()
            local network = getFishingNetwork()
            if not network or not network.AdminSetSellMultiplier then
                notifyAdminFail("AdminSetSellMultiplier missing")
                return
            end
            if fireNetwork(network.AdminSetSellMultiplier, { multiplier = adminSellMultiplier }) then
                mountNotify({ Title = "Fishing", Content = "Sell multiplier sent x" .. tostring(adminSellMultiplier) })
            else
                notifyAdminFail()
            end
        end,
    })
    pityParagraph = FishingTab:CreateParagraph({
        Title = "Pity",
        Content = "Refresh pity to load.",
    })
    FishingTab:CreateButton({
        Name = "Refresh pity",
        Callback = function()
            local network = getFishingNetwork()
            local userId = lpFish and lpFish.UserId
            if not network or not network.AdminGetPity then
                notifyAdminFail("AdminGetPity missing")
                return
            end
            if not userId then
                mountNotify({ Title = "Fishing", Content = "Local player missing" })
                return
            end
            task.spawn(function()
                local result, err = callNetwork(network.AdminGetPity, { targetUserId = userId })
                if type(result) ~= "table" or result.ok ~= true then
                    notifyAdminFail(type(err) == "string" and err or "Pity unavailable (likely not admin).")
                    return
                end
                local lines = { "Pity loaded:" }
                if type(result.rarities) == "table" then
                    for _, row in ipairs(result.rarities) do
                        table.insert(lines, string.format("%s  %d", tostring(row.name or "?"), tonumber(row.count) or 0))
                    end
                end
                if pityParagraph and pityParagraph.Set then
                    pityParagraph:Set({ Content = table.concat(lines, "\n") })
                end
                mountNotify({ Title = "Fishing", Content = "Pity loaded" })
            end)
        end,
    })
    FishingTab:CreateButton({
        Name = "Reset pity",
        Callback = function()
            local network = getFishingNetwork()
            local userId = lpFish and lpFish.UserId
            if not network or not network.AdminResetPity then
                notifyAdminFail("AdminResetPity missing")
                return
            end
            if not userId then
                mountNotify({ Title = "Fishing", Content = "Local player missing" })
                return
            end
            if fireNetwork(network.AdminResetPity, { targetUserId = userId }) then
                mountNotify({ Title = "Fishing", Content = "Reset pity sent" })
            else
                notifyAdminFail()
            end
        end,
    })

    FishingTab:CreateSection("Spots")
    local function teleportToHotspot(zoneName)
        local folder = Workspace:FindFirstChild("DaunHotSpots")
        local model = folder and folder:FindFirstChild("HotSpot_" .. zoneName)
        if not model then
            model = Workspace:FindFirstChild("HotSpot_" .. zoneName)
        end
        if not model then
            mountNotify({ Title = "Fishing", Content = "Hotspot not found: " .. zoneName })
            return
        end
        local cf
        pcall(function()
            cf = model:GetPivot()
        end)
        if not cf then
            local part = model:IsA("BasePart") and model or model:FindFirstChildWhichIsA("BasePart", true)
            if part then
                cf = part.CFrame
            end
        end
        local root = getLocalRootPart()
        if not cf or not root then
            mountNotify({ Title = "Fishing", Content = "Character not loaded" })
            return
        end
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = CFrame.new(cf.Position + Vector3.new(0, 4, 0))
        mountNotify({ Title = "Fishing", Content = "Moved to " .. zoneName })
    end
    FishingTab:CreateButton({
        Name = "Teleport Danau",
        Callback = function()
            teleportToHotspot("danau")
        end,
    })
    FishingTab:CreateButton({
        Name = "Teleport Pantai",
        Callback = function()
            teleportToHotspot("pantai")
        end,
    })
    FishingTab:CreateDropdown({
        Name = "Hotspot zone",
        Flag = "daun_fish_hotspot_zone",
        Options = FISH_HOTSPOT_ZONES,
        CurrentOption = { selectedHotspotZone },
        Callback = function(value)
            selectedHotspotZone = rayfieldDropdownFirst(value) or "danau"
        end,
    })
    FishingTab:CreateButton({
        Name = "Reroll hotspot",
        Callback = function()
            local network = getFishingNetwork()
            if not network or not network.AdminRerollHotSpot then
                notifyAdminFail("AdminRerollHotSpot missing")
                return
            end
            local zoneId = selectedHotspotZone or "danau"
            if fireNetwork(network.AdminRerollHotSpot, { zoneId = zoneId }) then
                mountNotify({ Title = "Fishing", Content = "Reroll hotspot sent: " .. zoneId })
            else
                notifyAdminFail()
            end
        end,
    })

    task.defer(function()
        local fishingNetwork = getFishingNetwork()
        if fishingNetwork then
            bindFishingNetwork(fishingNetwork)
        end
        local nextRods = loadRodNames()
        if rodNameDropdown and rodNameDropdown.Refresh then
            rodNameDropdown:Refresh(nextRods)
        end
        local nextFish = loadFishNames()
        if fishNameDropdown and fishNameDropdown.Refresh then
            fishNameDropdown:Refresh(nextFish)
        end
        if autoFavoriteNamesDropdown and autoFavoriteNamesDropdown.Refresh then
            autoFavoriteNamesDropdown:Refresh(nextFish)
        end
        if not selectedRodName or selectedRodName == "" then
            selectedRodName = nextRods[1] or "Wooden Rod"
        end
        if not selectedFishName or selectedFishName == "(none)" then
            selectedFishName = nextFish[1]
        end
        refreshFishingStatus()
        refreshFishIndexParagraph()
    end)
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
