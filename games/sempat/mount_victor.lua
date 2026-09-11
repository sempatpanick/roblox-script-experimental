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
            assert(okGet and type(source) == "string", "[sempat/mount_victor] failed to load sempat_library")
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
    Name = "sempatpanick | Mount Victor",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Sempat UI • Mount Victor",
    ToggleUIKeybind = "K",
    WindowTransparency = 30,
    Icon = "https://dadang.id/sempatpanick-icon.png",
    ConfigurationSaving = {
        Enabled = true,
        AutoSave = false,
        AutoLoad = false,
        FolderName = "sempatpanick",
        FileName = "mount_victor",
    },
})

-- */  Local Player Tab  /* --
createLocalPlayerTab(Window, mountNotify, { flagsPrefix = "lp", tabIcon = "user" })

-- Set by Config Tab when applying victor_auto_summit_enabled = true (manual toggle skips delay).
local autoSummitConfigBridge = {
    pendingStartDelay = false,
}

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
    -- Teleport mode: teleport to pos[1], then tween to pos[2] (checkpoint pad).
    local summitRoute = {
        { name = "CP1", pos = { "230.87, 86.75, -278.01", "324.18, 86.56, -280.45" }, modePos = "tween", delay = 20 },
        { name = "CP2", pos = { "1110.49, 120.82, -244.93", "1197.48, 120.63, -246.37" }, modePos = "tween", delay = 20 },
        { name = "CP3", pos = { "1929.96, 298.00, -225.90", "1996.60, 298.63, -229.07" }, modePos = "tween", delay = 20 },
        { name = "CP4", pos = { "2783.62, 388.00, -239.66", "2854.73, 388.00, -238.42" }, modePos = "tween", delay = 20 },
        { name = "CP5", pos = { "3730.50, 393.00, -243.12", "3806.50, 393.00, -241.13" }, modePos = "tween", delay = 20 },
        { name = "CP6", pos = { "4526.70, 527.19, -229.96", "4600.94, 527.19, -229.96" }, modePos = "tween", delay = 20 },
        { name = "CP7", pos = { "5366.15, 653.99, -224.83", "5488.26, 653.17, -226.60" }, modePos = "tween", delay = 20 },
        { name = "CP8", pos = { "6213.55, 694.44, -52.54", "6333.95, 693.62, -56.95" }, modePos = "tween", delay = 20 },
        { name = "CP9", pos = { "7027.09, 864.03, 137.87", "7141.88, 863.22, 131.71" }, modePos = "tween", delay = 20 },
        { name = "CP10", pos = { "7898.99, 1064.74, 127.31", "8014.62, 1064.48, 124.28" }, modePos = "tween", delay = 20 },
        { name = "CP11", pos = { "8722.68, 1348.73, 123.60", "8832.59, 1348.46, 122.10" }, modePos = "tween", delay = 20 },
        { name = "CP12", pos = { "9516.20, 1471.31, 140.13", "9626.46, 1470.51, 134.86" }, modePos = "tween", delay = 20 },
        { name = "CP13", pos = { "10418.18, 1607.31, 128.12", "10526.37, 1606.51, 126.65" }, modePos = "tween", delay = 20 },
        { name = "CP14", pos = { "11291.63, 1932.31, 130.62", "11403.26, 1931.87, 132.57" }, modePos = "tween", delay = 20 },
        { name = "CP15", pos = { "12213.19, 2095.31, 134.86", "12326.86, 2095.38, 131.91" }, modePos = "tween", delay = 20 },
        { name = "CP16", pos = { "12748.25, 2190.31, 747.69", "12748.89, 2189.51, 851.69" }, modePos = "tween", delay = 20 },
        { name = "CP17", pos = { "12753.07, 2252.31, 1669.07", "12757.11, 2252.37, 1784.02" }, modePos = "tween", delay = 20 },
        { name = "CP18", pos = { "12761.07, 2515.33, 2576.39", "12762.14, 2514.56, 2682.99" }, modePos = "tween", delay = 20 },
        { name = "CP19", pos = { "12757.32, 2679.31, 3517.92", "12755.63, 2678.87, 3625.85" }, modePos = "tween", delay = 20 },
        { name = "CP20", pos = { "12647.49, 2820.84, 4450.23", "12649.47, 2820.87, 4558.58" }, modePos = "tween", delay = 20 },
        { name = "CP21", pos = { "11974.90, 3425.39, 4905.02", "11865.13, 3424.95, 4908.86" }, modePos = "tween", delay = 20 },
        { name = "CP22", pos = { "11004.54, 3844.19, 4866.83", "10897.24, 3843.41, 4868.87" }, modePos = "tween", delay = 20 },
        { name = "Summit", pos = { "9261.77, 4334.37, 4636.06", "9170.12, 4334.99, 4630.06" }, modePos = "tween", delay = 30 },
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

    local function normalizePosisiLabel(value)
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
            return normalizePosisiLabel(inst.Value)
        end
        local nested = inst:FindFirstChild("Value") or inst:FindFirstChildWhichIsA("StringValue")
            or inst:FindFirstChildWhichIsA("IntValue")
        if nested then
            return readValueInstance(nested)
        end
        local attr = inst.GetAttribute and (inst:GetAttribute("Value") or inst:GetAttribute("Posisi"))
        if attr ~= nil then
            return normalizePosisiLabel(attr)
        end
        return ""
    end

    -- Updated by Auto Carry (CarrierList). Retry waits for LocalPlayer and every carried player.
    local carriedProgressIds = {}

    local function getPosisiInstanceForPlayer(player)
        if not player then
            return nil
        end
        local leaderstats = player:FindFirstChild("leaderstats")
        if not leaderstats then
            return nil
        end
        return leaderstats:FindFirstChild("Posisi")
    end

    local function getPosisiInstance()
        return getPosisiInstanceForPlayer(Players.LocalPlayer)
    end

    local function getPosisiLabelForPlayer(player)
        return readValueInstance(getPosisiInstanceForPlayer(player))
    end

    local function getPosisiLabel()
        return getPosisiLabelForPlayer(Players.LocalPlayer)
    end

    local function displayPosisiLabel(label)
        if label == nil or label == "" then
            return "Start"
        end
        return label
    end

    local function posisiRouteIndex(label)
        local raw = normalizePosisiLabel(label)
        if raw == "" then
            return 0
        end
        local low = string.lower(raw)
        if string.find(low, "summit", 1, true) then
            return #summitRoute
        end
        if low == "start" or low == "basecamp" or low == "base" then
            return 0
        end
        local cpNum = tonumber(string.match(raw, "^%s*CP%s*(%d+)%s*$") or string.match(raw, "(%d+)"))
        if cpNum and cpNum >= 1 then
            return math.min(cpNum, #summitRoute - 1)
        end
        return 0
    end

    local function posisiMatchesRouteEntry(label, entry)
        local raw = normalizePosisiLabel(label)
        if raw == "" or not entry then
            return false
        end
        if string.lower(raw) == string.lower(entry.name) then
            return true
        end
        if entry.name == "Summit" then
            return string.find(string.lower(raw), "summit", 1, true) ~= nil
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

    local function getEffectivePosisiRouteIndex()
        local minIdx = posisiRouteIndex(getPosisiLabel())
        local lp = Players.LocalPlayer
        for userId in pairs(carriedProgressIds) do
            local plr = Players:GetPlayerByUserId(userId)
            if plr and plr ~= lp then
                minIdx = math.min(minIdx, posisiRouteIndex(getPosisiLabelForPlayer(plr)))
            end
        end
        return minIdx
    end

    local function nextRouteIndexFromPosisi()
        local idx = getEffectivePosisiRouteIndex()
        if idx >= #summitRoute then
            return #summitRoute + 1
        end
        return idx + 1
    end

    -- LocalPlayer first, then every in-server carried player. viaName is nil for LocalPlayer.
    local function posisiMatchesAllProgress(entry)
        local lp = Players.LocalPlayer
        local localLabel = getPosisiLabel()
        if not posisiMatchesRouteEntry(localLabel, entry) then
            return false, localLabel, nil
        end
        for userId in pairs(carriedProgressIds) do
            local plr = Players:GetPlayerByUserId(userId)
            if plr and plr ~= lp then
                local label = getPosisiLabelForPlayer(plr)
                if not posisiMatchesRouteEntry(label, entry) then
                    return false, label, carryOtherPlayerDisplayName(plr)
                end
            end
        end
        return true, localLabel, nil
    end

    local function carriedPlayersMatchRouteEntry(entry)
        local lp = Players.LocalPlayer
        for userId in pairs(carriedProgressIds) do
            local plr = Players:GetPlayerByUserId(userId)
            if plr and plr ~= lp then
                if not posisiMatchesRouteEntry(getPosisiLabelForPlayer(plr), entry) then
                    return false
                end
            end
        end
        return true
    end

    local function formatPosisiStatusLabel(label, viaName)
        local shown = displayPosisiLabel(label)
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
            local Event = ReplicatedStorage.Shared.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.CheckpointService.RF.ResetCheckpoint
            Event:InvokeServer()
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
        local posisi = getPosisiLabel()
        local nextIndex = math.min(nextRouteIndexFromPosisi(), #summitRoute)
        local nextEntry = summitRoute[nextIndex]
        local nextName = nextEntry and nextEntry.name or "—"
        local nextDelay = getRouteDelaySec(nextEntry)
        if autoSummitEnabled then
            setStatusContent(string.format(
                "Current: %s\nNext: %s\nDelay: %.1fs  Tween: %.1fs\nWaiting to continue…",
                displayPosisiLabel(posisi),
                nextName,
                nextDelay,
                tweenDurationSec
            ))
        else
            setStatusContent(string.format(
                "Auto Summit is off.\nCurrent: %s\nNext: %s\nDelay: %.1fs  Tween: %.1fs",
                displayPosisiLabel(posisi),
                nextName,
                nextDelay,
                tweenDurationSec
            ))
        end
    end

    local function waitForPosisiConfirm(token, routeEntry, isSummitStep)
        local retryDeadline = os.clock() + CHECKPOINT_TELEPORT_RETRY_SEC
        while autoSummitEnabled and token == autoSummitLoopToken do
            local matched, posisiNow, viaName = posisiMatchesAllProgress(routeEntry)
            if matched then
                return true
            end
            if isSummitStep and isNearRouteEntry(routeEntry, SUMMIT_ARRIVAL_RADIUS) and carriedPlayersMatchRouteEntry(routeEntry) then
                return true
            end
            if os.clock() >= retryDeadline then
                return false
            end
            setStatusContent(string.format(
                "Confirming %s…\nPosisi: %s\nExpected: %s",
                routeEntry.name,
                formatPosisiStatusLabel(posisiNow, viaName),
                routeEntry.name
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

            if waitForPosisiConfirm(token, routeEntry, isSummitStep) then
                return true
            end
            if shouldStopRoute(token) then
                return false
            end
            local _, lagLabel, lagVia = posisiMatchesAllProgress(routeEntry)
            setStatusContent(string.format(
                "Retrying route to %s…\nPosisi: %s",
                routeEntry.name,
                formatPosisiStatusLabel(lagLabel, lagVia)
            ))
        end
        return false
    end

    local function waitAfterCheckpoint(token, routeEntry)
        return waitWithCountdown(token, getRouteDelaySec(routeEntry), function(remaining)
            setStatusContent(string.format(
                "At %s\nPosisi: %s\nNext teleport in %.1fs",
                routeEntry.name,
                displayPosisiLabel(getPosisiLabel()),
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
                "ResetCheckpoint sent — waiting %.0fs…\nPosisi: %s",
                math.ceil(math.max(remaining, 0)),
                displayPosisiLabel(getPosisiLabel())
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

            local nextIndex = nextRouteIndexFromPosisi()
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
        Flag = "victor_auto_summit_mode",
        Options = { "Teleport" },
        CurrentOption = { "Teleport" },
        Callback = function(value)
            autoSummitMode = rayfieldDropdownFirst(value) or "Teleport"
        end,
    })

    summitQtyInput = MainTab:CreateInput({
        Name = "Qty of summit",
        Flag = "victor_auto_summit_qty",
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
            Flag = "victor_auto_summit_delay_" .. tostring(entry.name),
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
        Flag = "victor_auto_summit_tweenDuration",
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
        Flag = "victor_auto_summit_enabled",
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
        Flag = "victor_checkpoint_select",
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
    -- Place uses Knit CarryService.RE.CarryEvent (same Request/Response protocol as CarryRemote).
    local function createAutoCarrySections()
    MainTab:CreateSection("Auto Carry")

    local SendRequestCarryCarrierListParagraph
    local sendRequestCarryUpdateCarrierListParagraph
    local lpCarry = Players.LocalPlayer

    SendRequestCarryCarrierListParagraph = MainTab:CreateParagraph({
        Title = "Carrier list",
        Content = "(no data yet — updates when the server sends CarrierList)",
    })

    local sendRequestCarrySelected = {}
    local sendRequestCarryAdditionalPlayersText = ""
    local SendRequestCarryPlayersDropdown
    local sendRequestCarryAutoLoopToken = 0
    local sendRequestCarryAutoNearbyLoopToken = 0
    local sendRequestCarryAutoEnabled = false
    local sendRequestCarryAutoNearbyEnabled = false

    local SEND_REQUEST_CARRY_DELAY_PER_TARGET = 4
    local SEND_REQUEST_CARRY_CYCLE_GAP = 6
    local SEND_REQUEST_CARRY_MAX_DISTANCE_STUDS = 20
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
        carriedProgressIds = newSet
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
        local myRoot = sendRequestCarryGetRootPart(lpCarry and lpCarry.Character)
        if not myRoot then
            return false
        end
        local tgtPlr = Players:GetPlayerByUserId(targetUserId)
        if not tgtPlr or tgtPlr == lpCarry then
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
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lpCarry and plr.ClassName == "Player" then
                table.insert(opts, sendRequestCarryOtherPlayerLabel(plr))
            end
        end
        table.sort(opts, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return opts
    end

    local function sendRequestCarryFindPlayerByLabel(label)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lpCarry and sendRequestCarryOtherPlayerLabel(plr) == label then
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
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lpCarry and plr.ClassName == "Player" then
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

    local function sendRequestCarryCollectAllOtherIds()
        local ids = {}
        local seen = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lpCarry and plr.ClassName == "Player" then
                local uid = plr.UserId
                if typeof(uid) == "number" and uid > 0 and not seen[uid] then
                    seen[uid] = true
                    if not sendRequestCarryIsDeclinedCooldownActive(uid) and not sendRequestCarryIsOnCarrierList(uid) then
                        table.insert(ids, uid)
                    end
                end
            end
        end
        return ids
    end

    local function sendRequestCarryGetCarryRemote()
        local ok, carryRemote = pcall(function()
            return ReplicatedStorage.Shared.Packages._Index["sleitnick_knit@1.7.0"].knit.Services.CarryService.RE.CarryEvent
        end)
        if ok and carryRemote then
            return carryRemote
        end
        return nil
    end

    local function sendRequestCarrySpawnAutoLoop(carryRemote, startToken, getToken, getTargets, noTargetMsg)
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
                            Icon = "x",
                        })
                    end
                    task.wait(5)
                else
                    warnedNoTargets = false
                    for _, targetId in ipairs(targets) do
                        if startToken ~= getToken() then
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
        Name = "To",
        Flag = "victor_main_send_carry_to",
        Options = sendRequestCarryDropdownOptions(),
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
        Flag = "victor_main_send_carry_by_name",
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
        Flag = "victor_main_send_carry_auto",
        CurrentValue = false,
        Callback = function(enabled)
            sendRequestCarryAutoEnabled = enabled
            sendRequestCarryAutoLoopToken = sendRequestCarryAutoLoopToken + 1
            if not enabled then
                return
            end

            if sendRequestCarryAutoNearbyEnabled and SendRequestCarryAutoNearbyToggle and SendRequestCarryAutoNearbyToggle.Set then
                SendRequestCarryAutoNearbyToggle:Set(false)
            end

            local carryRemote = sendRequestCarryGetCarryRemote()
            if not carryRemote then
                mountNotify({
                    Title = "Auto Carry",
                    Content = "CarryEvent not found (CarryService)",
                    Icon = "x",
                })
                if SendRequestCarryAutoToggle and SendRequestCarryAutoToggle.Set then
                    SendRequestCarryAutoToggle:Set(false)
                end
                return
            end

            sendRequestCarrySpawnAutoLoop(
                carryRemote,
                sendRequestCarryAutoLoopToken,
                function()
                    return sendRequestCarryAutoLoopToken
                end,
                sendRequestCarryCollectTargetIds,
                "No targets — select players and/or add names that match someone in the server"
            )

            mountNotify({
                Title = "Auto Carry",
                Content = "Auto send started",
                Icon = "check",
            })
        end,
    })

    SendRequestCarryAutoNearbyToggle = MainTab:CreateToggle({
        Name = "Auto Send Nearby",
        Flag = "victor_main_send_carry_auto_nearby",
        CurrentValue = false,
        Callback = function(enabled)
            sendRequestCarryAutoNearbyEnabled = enabled
            sendRequestCarryAutoNearbyLoopToken = sendRequestCarryAutoNearbyLoopToken + 1
            if not enabled then
                return
            end

            if sendRequestCarryAutoEnabled and SendRequestCarryAutoToggle and SendRequestCarryAutoToggle.Set then
                SendRequestCarryAutoToggle:Set(false)
            end

            local carryRemote = sendRequestCarryGetCarryRemote()
            if not carryRemote then
                mountNotify({
                    Title = "Auto Carry",
                    Content = "CarryEvent not found (CarryService)",
                    Icon = "x",
                })
                if SendRequestCarryAutoNearbyToggle and SendRequestCarryAutoNearbyToggle.Set then
                    SendRequestCarryAutoNearbyToggle:Set(false)
                end
                return
            end

            sendRequestCarrySpawnAutoLoop(
                carryRemote,
                sendRequestCarryAutoNearbyLoopToken,
                function()
                    return sendRequestCarryAutoNearbyLoopToken
                end,
                sendRequestCarryCollectAllOtherIds,
                "No nearby players (not on the carrier list) to send to"
            )

            mountNotify({
                Title = "Auto Carry",
                Content = "Auto send nearby started",
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
        local carryRemote = sendRequestCarryGetCarryRemote()
        if not carryRemote then
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

    -- */  Auto Accept Carry  /* --
    MainTab:CreateSection("Auto Accept Carry")

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
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lpCarry and plr.ClassName == "Player" then
                table.insert(opts, acceptIncomingCarryOtherPlayerLabel(plr))
            end
        end
        table.sort(opts, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return opts
    end

    local function acceptIncomingCarryFindPlayerByLabel(label)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lpCarry and acceptIncomingCarryOtherPlayerLabel(plr) == label then
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
        Name = "From",
        Flag = "victor_main_accept_carry_from",
        Options = acceptIncomingCarryDropdownOptions(),
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
        Flag = "victor_main_accept_carry_auto",
        CurrentValue = false,
        Callback = function(enabled)
            if acceptIncomingCarryRemoteConn then
                acceptIncomingCarryRemoteConn:Disconnect()
                acceptIncomingCarryRemoteConn = nil
            end
            if not enabled then
                return
            end
            local carryRemote = sendRequestCarryGetCarryRemote()
            if not carryRemote then
                mountNotify({
                    Title = "Auto Accept Carry",
                    Content = "CarryEvent not found (CarryService)",
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
                Title = "Auto Accept Carry",
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

    end
    createAutoCarrySections()

    local function hookPosisiInstance(inst)
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
        hookPosisiInstance(leaderstats:FindFirstChild("Posisi"))
        leaderstats.ChildAdded:Connect(function(child)
            if child.Name == "Posisi" then
                hookPosisiInstance(child)
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
createTeleportTab(Window, mountNotify, { flagsPrefix = "victor", tabIcon = "map-pin" })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, {
    replicatedStorage = ReplicatedStorage,
    tabIcon = "boxes",
})


-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, {
    gamePath = "sempatpanick/mount_victor",
    tabIcon = "video",
})

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/mount_victor",
    rayfieldLibrary = SempatLibrary,
    tabIcon = "settings",
    applyLastFlags = { "victor_auto_summit_enabled" },
    onApplyFlag = function(flagName, saved)
        if flagName == "victor_auto_summit_enabled" then
            autoSummitConfigBridge.pendingStartDelay = saved == true
        end
        return saved
    end,
})
