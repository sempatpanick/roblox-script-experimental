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
            assert(okGet and type(source) == "string", "[sempat/mount_yahayuk] failed to load sempat_library")
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

-- */  Route Player (module)  /* --
local ROUTE_PLAYER_REPO = baseURL .. "/functions/player/route_player.lua"
local function loadRoutePlayerModule(repoUrl)
    local okReq, mod = pcall(function()
        return require("../../functions/player/route_player")
    end)
    if okReq and type(mod) == "table" then
        return mod
    end

    local okHttp, source = pcall(function()
        return game:HttpGet(repoUrl)
    end)
    if not okHttp or type(source) ~= "string" or #source < 64 then
        warn("[Route Player] HttpGet failed:", tostring(source))
        return nil
    end

    local chunk, compileErr
    if type(load) == "function" then
        local okLoad
        okLoad, chunk = pcall(function()
            return load(source, "route_player")
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
        warn("[Route Player] compile failed:", tostring(compileErr))
        return nil
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        warn("[Route Player] module execute failed:", tostring(result))
        return nil
    end
    if type(result) ~= "table" then
        warn("[Route Player] module must return a table, got", type(result))
        return nil
    end
    return result
end

local RoutePlayer = loadRoutePlayerModule(ROUTE_PLAYER_REPO)

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
local Window = SempatLibrary:CreateWindow({
    Name = "sempatpanick | Mount Yahayuk",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Sempat UI • Mount Yahayuk",
    ToggleUIKeybind = "K",
    WindowTransparency = 30,
    Icon = "https://dadang.id/sempatpanick-icon.png",
    ConfigurationSaving = {
        Enabled = true,
        AutoSave = false,
        AutoLoad = false,
        FolderName = "sempatpanick",
        FileName = "mount_yahayuk",
    },
})

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
createLocalPlayerTab(Window, mountNotify, {
    centerShiftLockCamera = true,
    shiftLockRenderStepId = "MountYahayukCenterShiftLockCamera",
    flagsPrefix = "lp",
    tabIcon = "user",
})

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", "mountain")

    autoSummitEnabled = false
    local autoSummitMainToggle: any = nil
    autoSummitSkipFinalStoppedNotify = false
    summitQty = ""
    autoSummitRandomizeTeleportDelay = false
    autoSummitRestartFromDeath = false
    autoSummitMode = "Walk" -- "Walk" | "Teleport"
    autoSummitIncludeFailedRoutes = true
    local syncRoutesFromRepo: ((boolean?) -> ())? = nil
    local AutoSummitRoutesParagraph: any = nil
    routeSyncActive = false
    local routePossibilities: any = nil
    local updateAutoSummitRouteSequenceParagraph: () -> ()
    BETWEEN_RUN_DELAY_MIN = 0
    BETWEEN_RUN_DELAY_MAX = 1
    autoSummitRng = Random.new()

    local function humanoidWalkToWorldPosition(
        humanoid: Humanoid,
        rootPart: BasePart,
        targetPos: Vector3,
        shouldCancel: () -> boolean,
        arrivalDist: number?
    ): boolean
        local thresh = arrivalDist or 8
        humanoid:MoveTo(targetPos)
        local dist0 = (rootPart.Position - targetPos).Magnitude
        local timeout = math.clamp(dist0 / math.max(4, humanoid.WalkSpeed) * 2.8, 15, 200)
        local start = os.clock()
        local moveDone = false
        local conn = humanoid.MoveToFinished:Connect(function()
            moveDone = true
        end)
        while not shouldCancel() do
            if (rootPart.Position - targetPos).Magnitude <= thresh then
                conn:Disconnect()
                return true
            end
            if moveDone then
                conn:Disconnect()
                return (rootPart.Position - targetPos).Magnitude <= thresh + 10
            end
            if os.clock() - start >= timeout then
                conn:Disconnect()
                return (rootPart.Position - targetPos).Magnitude <= thresh + 12
            end
            task.wait(0.1)
        end
        conn:Disconnect()
        pcall(function()
            humanoid:Move(Vector3.new(0, 0, 0))
        end)
        return false
    end

    local summitRoute = {
        {
            name = "Start",
            teleportPosition = "-922.94, 169.22, 856.29",
            teleportDelay = 3,
            teleportDelayRandomMin = 0,
            teleportDelayRandomMax = 0,
            teleportWalkTo = nil,
            teleportWalkToRadius = nil,
            teleportWalkToWithJump = false,
        },
        {
            name = "Camp 1",
            teleportPosition = "-423.65, 248.26, 788.96",
            teleportDelay = 5,
            teleportDelayRandomMin = 0,
            teleportDelayRandomMax = 5,
            teleportWalkTo = nil,
            teleportWalkToRadius = nil,
            teleportWalkToWithJump = false,
        },
        {
            name = "Camp 2",
            teleportPosition = "-337.77, 388.27, 522.16",
            teleportDelay = 5,
            teleportDelayRandomMin = 0,
            teleportDelayRandomMax = 5,
            teleportWalkTo = nil,
            teleportWalkToRadius = nil,
            teleportWalkToWithJump = false,
        },
        {
            name = "Camp 3",
            teleportPosition = "294.19, 430.33, 494.17",
            teleportDelay = 5,
            teleportDelayRandomMin = 0,
            teleportDelayRandomMax = 5,
            teleportWalkTo = nil,
            teleportWalkToRadius = nil,
            teleportWalkToWithJump = false,
        },
        {
            name = "Camp 4",
            teleportPosition = "323.46, 490.24, 348.33",
            teleportDelay = 15,
            teleportDelayRandomMin = 0,
            teleportDelayRandomMax = 10,
            teleportWalkTo = nil,
            teleportWalkToRadius = nil,
            teleportWalkToWithJump = false,
        },
        {
            name = "Camp 5",
            teleportPosition = "226.70, 314.21, -143.64",
            teleportDelay = 25,
            teleportDelayRandomMin = 0,
            teleportDelayRandomMax = 10,
            teleportWalkTo = nil,
            teleportWalkToRadius = nil,
            teleportWalkToWithJump = false,
        },
        {
            name = "Summit",
            teleportPosition = "-613.51, 905.28, -533.45",
            teleportDelay = 5,
            teleportDelayRandomMin = 0,
            teleportDelayRandomMax = 5,
            teleportWalkTo = "-621.35, 905.13, -495.14",
            teleportWalkToRadius = 1.5,
            teleportWalkToWithJump = true,
        },
    }

    local function normalizeSummitCheckpointLabel(s: any): string
        if typeof(s) ~= "string" then
            s = tostring(s or "")
        end
        s = string.lower(s)
        s = string.gsub(s, "^%s+", "")
        s = string.gsub(s, "%s+$", "")
        return s
    end

    local function checkpointLabelLooksLikeSummit(labelValue: any): boolean
        if typeof(labelValue) ~= "string" or labelValue == "" then
            return false
        end
        local low = string.lower(labelValue)
        return string.find(low, "summit", 1, true) ~= nil
    end

    local function summitRouteStepIndexFromLabel(labelValue: any): number?
        local raw = typeof(labelValue) == "string" and labelValue or tostring(labelValue or "")
        local norm = normalizeSummitCheckpointLabel(raw)

        for i, wp in ipairs(summitRoute) do
            if normalizeSummitCheckpointLabel(wp.name) == norm then
                return i
            end
        end

        if norm == "start" then
            return 1
        end

        local onlyNum = tonumber(string.match(raw, "^%s*(%d+)%s*$"))
        if onlyNum ~= nil then
            if onlyNum == 0 then
                return 1
            end
            if onlyNum >= 1 and onlyNum <= 5 then
                return onlyNum + 1
            end
            if onlyNum == 6 then
                return #summitRoute
            end
        end

        local d = string.match(raw, "(%d+)")
        if d then
            local n = tonumber(d)
            if n == 0 then
                return 1
            end
            if n >= 1 and n <= 5 then
                return n + 1
            end
            if n == 6 then
                return #summitRoute
            end
        end

        if checkpointLabelLooksLikeSummit(raw) then
            return #summitRoute
        end

        return nil
    end

    local function notifyAutoSummit(content, icon)
        mountNotify({ Title = "Auto Summit", Content = content, Icon = icon or "check" })
    end

    local function waitWithCancel(seconds, shouldCancel)
        local elapsed = 0
        local step = 0.25
        while elapsed < seconds do
            if shouldCancel() then
                return false
            end
            task.wait(math.min(step, seconds - elapsed))
            elapsed = elapsed + step
        end
        return true
    end

    MainTab:CreateSection("Auto Summit")

    MainTab:CreateButton({
        Name = "Refresh Routes",
        Callback = function()
            if syncRoutesFromRepo then
                task.spawn(syncRoutesFromRepo, true)
            end
        end,
    })

    AutoSummitRoutesParagraph = MainTab:CreateParagraph({
        Title = "Walk routes",
        Content = "Not synced yet.",
    })

    local lpAutoSummit = Players.LocalPlayer

    -- Periodic jumps during post-teleport MoveTo when summitRoute[*].teleportWalkToWithJump is true.
    local function startWalkJumpAssistForLeg(shouldCancel: () -> boolean): () -> ()
        local stopFlag = false
        task.spawn(function()
            while not stopFlag and not shouldCancel() do
                local char = lpAutoSummit.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                if hum then
                    pcall(function()
                        hum:ChangeState(Enum.HumanoidStateType.Jumping)
                    end)
                end
                local elapsed = 0
                while elapsed < 0.47 and not stopFlag and not shouldCancel() do
                    task.wait(0.05)
                    elapsed = elapsed + 0.05
                end
            end
        end)
        return function()
            stopFlag = true
        end
    end

    local function getCheckpointLabelString(player)
        local attr = player:GetAttribute("LastCheckpoint")
        if typeof(attr) == "string" and attr ~= "" then
            return attr
        end
        if typeof(attr) == "number" then
            return tostring(attr)
        end
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            local iv = ls:FindFirstChild("LastCheckpoint")
            if iv and iv:IsA("IntValue") then
                return tostring(iv.Value)
            end
            local sv = ls:FindFirstChild("Checkpoint")
            if sv and sv:IsA("StringValue") and sv.Value ~= "" then
                return sv.Value
            end
        end
        return "Start"
    end

    local autoSummitDeathCheckConn: any = nil

    local autoSummitTeleportStepDisplay = "—" -- teleport mode: current waypoint name

    -- Walk mode route sequence display (filenames).
    local ROUTE_SEQUENCE_TITLE = "Route sequence"
    local NEXT_ROUTE_PENDING = "(choosing on arrival)"
    local autoSummitPrevRouteFile = "—"
    local autoSummitCurrentRouteFile = "—"
    local autoSummitNextRouteFile = "—"

    local function resetAutoSummitRouteSequence()
        autoSummitPrevRouteFile = "—"
        autoSummitCurrentRouteFile = "—"
        autoSummitNextRouteFile = "—"
    end

    -- A route was just chosen and is about to be walked into (shown as "Next").
    local function markRoutePicked(file: string)
        autoSummitNextRouteFile = file
        task.defer(updateAutoSummitRouteSequenceParagraph)
    end

    -- Playback of a route is starting: it becomes "Current", the old current
    -- shifts to "Previous", and "Next" reverts to pending until the next pick.
    local function markRoutePlaying(file: string)
        autoSummitPrevRouteFile = autoSummitCurrentRouteFile
        autoSummitCurrentRouteFile = file
        autoSummitNextRouteFile = NEXT_ROUTE_PENDING
        task.defer(updateAutoSummitRouteSequenceParagraph)
    end

    -- Route tracker: draws the current route's path in the world as a neon trail.
    local autoSummitShowTracker = false
    local autoSummitTrackerSensitivity = 1.8 -- thickness growth per extra overlap
    local autoSummitTrackerCellSize = 4 -- studs; how close two passes count as the same position
    local routeTrackerFolder: Instance? = nil
    local routeTrackerCurrentFrames: { any }? = nil
    local ROUTE_TRACKER_FOLDER_NAME = "SempatPanickRouteTracker"
    local ROUTE_TRACKER_MIN_SPACING = 3 -- studs between sampled path points

    local function clearRouteTracker()
        if routeTrackerFolder then
            pcall(function()
                routeTrackerFolder:Destroy()
            end)
            routeTrackerFolder = nil
        end
    end

    -- Sample frame positions so points are at least ROUTE_TRACKER_MIN_SPACING
    -- apart (keeps part count sane on long routes); always keep first and last.
    local function sampleRouteTrackerPoints(frames: { any }): { Vector3 }
        local pts = {}
        local last: Vector3? = nil
        for i, f in ipairs(frames) do
            local p = Vector3.new(f[2], f[3], f[4])
            if not last or (p - last).Magnitude >= ROUTE_TRACKER_MIN_SPACING then
                table.insert(pts, p)
                last = p
            end
        end
        local lastFrame = frames[#frames]
        if lastFrame then
            local lp = Vector3.new(lastFrame[2], lastFrame[3], lastFrame[4])
            if not last or (lp - last).Magnitude > 0.01 then
                table.insert(pts, lp)
            end
        end
        return pts
    end

    -- Current UI accent color, falling back to neon blue if unavailable.
    local function getRouteTrackerColor(): Color3
        local ok, color = pcall(function()
            return Window:GetAccentColor()
        end)
        if ok and typeof(color) == "Color3" then
            return color
        end
        return Color3.fromRGB(0, 200, 255)
    end

    local function drawRouteTracker(frames: { any }?)
        clearRouteTracker()
        if not autoSummitShowTracker or type(frames) ~= "table" or #frames < 2 then
            return
        end
        local pts = sampleRouteTrackerPoints(frames)
        if #pts < 2 then
            return
        end
        local trackerColor = getRouteTrackerColor()

        -- Count how many separate times the path enters each spatial cell, so
        -- stretches where the route overlaps itself can be drawn thicker/bolder.
        local CELL = autoSummitTrackerCellSize
        local function cellKey(p: Vector3): string
            return math.floor(p.X / CELL) .. "_" .. math.floor(p.Y / CELL) .. "_" .. math.floor(p.Z / CELL)
        end
        local visits: { [string]: number } = {}
        local lastKey: string? = nil
        for _, p in ipairs(pts) do
            local k = cellKey(p)
            if k ~= lastKey then
                visits[k] = (visits[k] or 0) + 1
                lastKey = k
            end
        end

        local BASE_THICKNESS = 0.35
        local folder = Instance.new("Folder")
        folder.Name = ROUTE_TRACKER_FOLDER_NAME
        for i = 1, #pts - 1 do
            local a, b = pts[i], pts[i + 1]
            local dist = (b - a).Magnitude
            if dist > 0.01 then
                local overlap = math.max(visits[cellKey(a)] or 1, visits[cellKey(b)] or 1)
                local thickness = math.min(BASE_THICKNESS * (1 + (overlap - 1) * autoSummitTrackerSensitivity), BASE_THICKNESS * 6)
                local seg = Instance.new("Part")
                seg.Anchored = true
                seg.CanCollide = false
                seg.CanQuery = false
                seg.CanTouch = false
                seg.Massless = true
                seg.CastShadow = false
                seg.Material = Enum.Material.Neon
                seg.Color = trackerColor
                seg.Transparency = math.max(0.3 - (overlap - 1) * 0.08, 0.05)
                seg.Size = Vector3.new(thickness, thickness, dist)
                seg.CFrame = CFrame.lookAt((a + b) / 2, b)
                seg.Parent = folder
            end
        end
        folder.Parent = workspace
        routeTrackerFolder = folder
    end

    local AutoSummitRouteSequenceParagraph: any = nil
    updateAutoSummitRouteSequenceParagraph = function()
        if not AutoSummitRouteSequenceParagraph or not AutoSummitRouteSequenceParagraph.Set then
            return
        end
        local content
        if not autoSummitEnabled then
            content = "Auto Summit is off."
        elseif autoSummitMode == "Walk" then
            content = ("Previous: %s\nCurrent: %s\nNext: %s"):format(
                autoSummitPrevRouteFile,
                autoSummitCurrentRouteFile,
                autoSummitNextRouteFile
            )
        else
            content = "Step: " .. autoSummitTeleportStepDisplay
        end
        AutoSummitRouteSequenceParagraph:Set({
            Title = ROUTE_SEQUENCE_TITLE,
            Content = content,
        })
    end

    local function disableAutoSummit(reason: string)
        autoSummitSkipFinalStoppedNotify = true
        autoSummitEnabled = false
        notifyAutoSummit(reason, "x")
        local tgl = autoSummitMainToggle
        if tgl then
            pcall(function()
                if tgl.Set then
                    tgl:Set(false)
                elseif tgl.SetValue then
                    tgl:SetValue(false)
                end
            end)
        end
        if autoSummitDeathCheckConn then
            autoSummitDeathCheckConn:Disconnect()
            autoSummitDeathCheckConn = nil
        end
    end

    local autoSummitRunTimes = {}

    local function formatAutoSummitDuration(sec)
        if typeof(sec) ~= "number" or sec ~= sec or sec < 0 then
            return "—"
        end
        if sec < 60 then
            return string.format("%.1fs", sec)
        end
        local m = math.floor(sec / 60)
        local s = sec - m * 60
        return string.format("%dm %.1fs", m, s)
    end

    local AUTO_SUMMIT_TIMES_TITLE = "Time per summit (this session)"
    local AutoSummitTimesParagraph
    local function updateAutoSummitTimesParagraph()
        if not AutoSummitTimesParagraph then
            return
        end
        local lines = {}
        local n = #autoSummitRunTimes
        local startIdx = 1
        local maxLines = 20
        if n > maxLines then
            startIdx = n - maxLines + 1
            table.insert(lines, "(Showing last " .. maxLines .. " runs)")
        end
        for i = startIdx, n do
            table.insert(
                lines,
                string.format("Run %d: %s", i, formatAutoSummitDuration(autoSummitRunTimes[i]))
            )
        end
        local desc = #lines > 0 and table.concat(lines, "\n") or "No completed runs yet."
        if AutoSummitTimesParagraph.Set then
            AutoSummitTimesParagraph:Set({
                Title = AUTO_SUMMIT_TIMES_TITLE,
                Content = desc,
            })
        end
    end

    local AUTO_SUMMIT_CP_TITLE = "Current camp / CP"
    local AutoSummitCpParagraph
    local autoSummitCurrentCpLabel = "Start"
    local function syncAutoSummitCurrentCheckpointSnapshot()
        autoSummitCurrentCpLabel = getCheckpointLabelString(lpAutoSummit)
    end

    local function parseSummitTeleportPositionString(posStr: any): Vector3?
        if typeof(posStr) ~= "string" then
            return nil
        end
        local s = posStr:gsub(",", " "):gsub("%s+", " ")
        local parts = {}
        for part in string.gmatch(s, "[%d%.%-]+") do
            local n = tonumber(part)
            if n ~= nil then
                table.insert(parts, n)
            end
        end
        if #parts < 3 then
            return nil
        end
        return Vector3.new(parts[1], parts[2], parts[3])
    end

    local function teleportAutoSummitRootToWorld(rootPart: BasePart, pos: Vector3)
        pcall(function()
            rootPart.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
            rootPart.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
        end)
        rootPart.CFrame = CFrame.new(pos)
    end

    local CP_NOTIFY_OK_SUFFIX = "tersimpan."
    local CP_WARN_TOO_FAST_PREFIX = "Terlalu cepat"
    local CP_NOTIFY_REMOTE_WAIT_SEC = 8
    local TELEPORT_ACK_POLL_TIMEOUT_SEC = 10
    local TELEPORT_SUMMIT_POST_WALK_SETTLE_SEC = 2

    local function getCpNotifyPayloadKindText(payload: any): (string?, string?)
        if type(payload) ~= "table" then
            return nil, nil
        end
        local kind = payload.kind
        local text = payload.text
        if typeof(text) ~= "string" or text == "" then
            text = payload.message
        end
        if typeof(text) ~= "string" or text == "" then
            text = payload.msg
        end
        if typeof(text) ~= "string" then
            return nil, nil
        end
        local ks = kind ~= nil and string.lower(tostring(kind)) or nil
        return ks, text
    end

    local function cpNotifyPayloadIsOkSaved(payload: any): boolean
        local kind, text = getCpNotifyPayloadKindText(payload)
        if not kind or kind ~= "ok" or not text then
            return false
        end
        local suf = string.lower(CP_NOTIFY_OK_SUFFIX)
        local low = string.lower(text)
        if string.len(low) < string.len(suf) then
            return false
        end
        return string.sub(low, -string.len(suf)) == suf
    end

    local function cpNotifyPayloadIsTerlaluCepat(payload: any): boolean
        local kind, text = getCpNotifyPayloadKindText(payload)
        if not kind or kind ~= "warn" or not text then
            return false
        end
        local lowText = string.lower(text)
        local lowPre = string.lower(CP_WARN_TOO_FAST_PREFIX)
        if string.len(lowText) < string.len(lowPre) then
            return false
        end
        return string.sub(lowText, 1, string.len(lowPre)) == lowPre
    end

    local cpNotifyEventCached: Instance? = nil
    local function getCpNotifyRemoteEvent(): Instance?
        if cpNotifyEventCached and cpNotifyEventCached.Parent then
            return cpNotifyEventCached
        end
        local inst = ReplicatedStorage:FindFirstChild("CP_Notify")
            or ReplicatedStorage:WaitForChild("CP_Notify", CP_NOTIFY_REMOTE_WAIT_SEC)
        if
            inst
            and (
                inst:IsA("RemoteEvent")
                or inst:IsA("UnreliableRemoteEvent")
            )
        then
            cpNotifyEventCached = inst
            return inst
        end
        return nil
    end

    -- Realtime buffer: one listener for the whole teleport cycle so warns are never missed (connect-before-teleport race).
    local cpNotifyRealtimeQueue: { any } = {}
    local cpNotifyRealtimeConn: RBXScriptConnection? = nil

    local function flushCpNotifyRealtimeQueue()
        cpNotifyRealtimeQueue = {}
    end

    local function ensureCpNotifyRealtimeListener()
        local ev = getCpNotifyRemoteEvent()
        if not ev then
            return
        end
        if cpNotifyRealtimeConn then
            return
        end
        cpNotifyRealtimeConn = ev.OnClientEvent:Connect(function(payload)
            table.insert(cpNotifyRealtimeQueue, payload)
        end)
    end

    local function stopCpNotifyRealtimeListener()
        if cpNotifyRealtimeConn then
            cpNotifyRealtimeConn:Disconnect()
            cpNotifyRealtimeConn = nil
        end
        flushCpNotifyRealtimeQueue()
    end

    -- After each teleport, success when LastCheckpoint changes OR CP_Notify ok + text ends with "tersimpan.".
    -- kind=warn + "Terlalu cepat..." => retry same teleport within 5 seconds.
    local function waitForTeleportCpNotifyOrCheckpointAdvance(
        cpLabelBefore: string,
        shouldAbort: () -> boolean
    ): "confirmed" | "abort" | "too_fast"
        local waitStart = os.clock()
        while not shouldAbort() do
            if os.clock() - waitStart > TELEPORT_ACK_POLL_TIMEOUT_SEC then
                notifyAutoSummit("Teleport: no CP change / CP_Notify ok within " .. tostring(TELEPORT_ACK_POLL_TIMEOUT_SEC) .. "s", "x")
                return "abort"
            end

            syncAutoSummitCurrentCheckpointSnapshot()
            if autoSummitCurrentCpLabel ~= cpLabelBefore then
                return "confirmed"
            end

            while #cpNotifyRealtimeQueue > 0 do
                local payload = table.remove(cpNotifyRealtimeQueue, 1)
                if cpNotifyPayloadIsOkSaved(payload) then
                    return "confirmed"
                end
                if cpNotifyPayloadIsTerlaluCepat(payload) then
                    return "too_fast"
                end
            end

            RunService.Heartbeat:Wait()
        end

        return "abort"
    end

    -- Final leg: after teleportWalkTo, give CP / CP_Notify time; always ~2s unless ok arrives first. Still honor Terlalu cepat.
    local function waitForTeleportSummitLegSettle(shouldAbort: () -> boolean): "confirmed" | "abort" | "too_fast"
        local waitStart = os.clock()
        while not shouldAbort() do
            while #cpNotifyRealtimeQueue > 0 do
                local payload = table.remove(cpNotifyRealtimeQueue, 1)
                if cpNotifyPayloadIsOkSaved(payload) then
                    return "confirmed"
                end
                if cpNotifyPayloadIsTerlaluCepat(payload) then
                    return "too_fast"
                end
            end

            if os.clock() - waitStart >= TELEPORT_SUMMIT_POST_WALK_SETTLE_SEC then
                return "confirmed"
            end

            RunService.Heartbeat:Wait()
        end
        return "abort"
    end

    local function runAutoSummitTeleportCycle(
        shouldAbort: () -> boolean,
        getRootPart: (number?) -> BasePart?,
        skipNextCpResumeNotify: boolean
    ): (boolean, boolean, boolean)
        -- Subscribe before any teleport so CP_Notify (especially warn) cannot fire before we listen.
        ensureCpNotifyRealtimeListener()

        local function teleportCycleImpl(): (boolean, boolean, boolean)
            local routeCompleted = true
            syncAutoSummitCurrentCheckpointSnapshot()
            local routeStepNow = summitRouteStepIndexFromLabel(autoSummitCurrentCpLabel)
            local teleportReachedSummitThisCycle = false
            local skippedSummitLegs = routeStepNow == nil
            if skippedSummitLegs then
                skipNextCpResumeNotify = false
                disableAutoSummit(
                    "Unknown checkpoint label (not on summit route): " .. tostring(autoSummitCurrentCpLabel)
                )
                return false, false, skipNextCpResumeNotify
            end

            if not skipNextCpResumeNotify then
                local canonical = summitRoute[routeStepNow].name or autoSummitCurrentCpLabel
                notifyAutoSummit(("%s — teleport mode..."):format(canonical))
            else
                skipNextCpResumeNotify = false
            end

            local routeN = #summitRoute
            local loopStartIdx = routeStepNow + 1
            if routeStepNow >= routeN then
                loopStartIdx = routeN
            end
            if loopStartIdx > routeN then
                return true, false, skipNextCpResumeNotify
            end

            local TELEPORT_TOO_FAST_RETRY_SEC = 5

            for nextIdx = loopStartIdx, routeN do
            if not autoSummitEnabled or shouldAbort() then
                return false, teleportReachedSummitThisCycle, skipNextCpResumeNotify
            end

            local wp = summitRoute[nextIdx]
            if not wp then
                return false, teleportReachedSummitThisCycle, skipNextCpResumeNotify
            end

            local telePos = parseSummitTeleportPositionString(wp.teleportPosition)
            if not telePos then
                disableAutoSummit(
                    ("Teleport mode: invalid teleportPosition for %s"):format(tostring(wp.name))
                )
                return false, teleportReachedSummitThisCycle, skipNextCpResumeNotify
            end

            autoSummitTeleportStepDisplay = wp.name
            task.defer(updateAutoSummitRouteSequenceParagraph)

            syncAutoSummitCurrentCheckpointSnapshot()
            local cpBeforeStep = autoSummitCurrentCpLabel
            local tooFastWindowEnd: number? = nil
            local firstTeleportAttempt = true

            while true do
                if not autoSummitEnabled or shouldAbort() then
                    return false, teleportReachedSummitThisCycle, skipNextCpResumeNotify
                end

                if firstTeleportAttempt then
                    notifyAutoSummit(("Teleport -> %s"):format(wp.name))
                    firstTeleportAttempt = false
                end

                local rootPart = getRootPart()
                if not rootPart then
                    notifyAutoSummit("Teleport mode: HumanoidRootPart missing", "x")
                    return false, teleportReachedSummitThisCycle, skipNextCpResumeNotify
                end

                flushCpNotifyRealtimeQueue()
                teleportAutoSummitRootToWorld(rootPart, telePos)

                local character = lpAutoSummit.Character
                local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                local walkDest = wp.teleportWalkTo
                if typeof(walkDest) == "string" and walkDest ~= "" then
                    local wtPos = parseSummitTeleportPositionString(walkDest)
                    if wtPos and humanoid and rootPart:IsA("BasePart") then
                        local arrivalDist = tonumber(wp.teleportWalkToRadius) or 8
                        local jumpAssistStop = wp.teleportWalkToWithJump and startWalkJumpAssistForLeg(shouldAbort)
                            or nil
                        humanoidWalkToWorldPosition(humanoid, rootPart, wtPos, shouldAbort, arrivalDist)
                        if jumpAssistStop then
                            jumpAssistStop()
                        end
                    end
                end

                if shouldAbort() or not autoSummitEnabled then
                    return false, teleportReachedSummitThisCycle, skipNextCpResumeNotify
                end

                local ack: "confirmed" | "abort" | "too_fast"
                if nextIdx == routeN then
                    ack = waitForTeleportSummitLegSettle(shouldAbort)
                else
                    ack = waitForTeleportCpNotifyOrCheckpointAdvance(cpBeforeStep, shouldAbort)
                end
                if ack == "abort" then
                    return false, teleportReachedSummitThisCycle, skipNextCpResumeNotify
                end
                if ack == "confirmed" then
                    break
                end

                if not tooFastWindowEnd then
                    tooFastWindowEnd = os.clock() + TELEPORT_TOO_FAST_RETRY_SEC
                end
                if os.clock() >= tooFastWindowEnd then
                    notifyAutoSummit("Teleport: Terlalu cepat — gave up after 5s", "x")
                    return false, teleportReachedSummitThisCycle, skipNextCpResumeNotify
                end
                notifyAutoSummit("Teleport: Terlalu cepat — retrying...", "x")
                task.wait(TELEPORT_TOO_FAST_RETRY_SEC)
            end

            local baseDelay = tonumber(wp.teleportDelay) or 0
            local delaySec = baseDelay
            if autoSummitRandomizeTeleportDelay then
                local ra = tonumber(wp.teleportDelayRandomMin)
                local rb = tonumber(wp.teleportDelayRandomMax)
                if ra ~= nil and rb ~= nil then
                    delaySec = baseDelay + autoSummitRng:NextNumber(math.min(ra, rb), math.max(ra, rb))
                end
            end
            if delaySec < 0 then
                delaySec = 0
            end
            if delaySec > 0 then
                if not waitWithCancel(delaySec, shouldAbort) then
                    return false, teleportReachedSummitThisCycle, skipNextCpResumeNotify
                end
            end

            if nextIdx == routeN then
                teleportReachedSummitThisCycle = true
            end
            end

            return routeCompleted, teleportReachedSummitThisCycle, skipNextCpResumeNotify
        end

        local tr, ts, tu = teleportCycleImpl()
        stopCpNotifyRealtimeListener()
        return tr, ts, tu
    end

    -- */  Walk mode: replay recorded routes fetched from the repo  /* --
    local ROUTES_DIR = "sempatpanick/mount_yahayuk/routes"
    local POSSIBILITIES_FILE = ROUTES_DIR .. "/possibilities.json"
    local POSSIBILITIES_REMOTE_URL = baseURL .. "/mount_yahayuk/possibilities.json"
    local ROUTES_REMOTE_DIR = baseURL .. "/mount_yahayuk/routes/"
    local WALK_CONNECT_ARRIVAL_DIST = 2
    local WALK_CONNECT_GIVE_UP_DIST = 25
    local WALK_START_BLEND_SEC = 0.1 -- glide into a route's first frame instead of snapping
    local WALK_MAX_LEG_ATTEMPTS = 6
    local FALL_SETTLE_TIMEOUT_SEC = 25
    local WALK_CP_ACK_TIMEOUT_SEC = 12
    local WALK_PLAYBACK_NOCLIP = false -- real collisions so CP / fall triggers fire naturally

    -- summitRoute step index (the camp we are AT) -> the leg that climbs out of it.
    local WALK_LEG_BY_STEP = { "start-cp1", "cp1-cp2", "cp2-cp3", "cp3-cp4", "cp4-cp5", "cp5-summit" }
    local WALK_DESCENT_LEG = "summit-start"

    -- From mount_yahayuk/fallspawns.json (Workspace.SpawnLocation / Workspace.Checkpoints.CPn.FallSpawn).
    -- Index matches the summitRoute step index of the camp a failed route falls back to.
    local WALK_FALL_SPAWNS = {
        [1] = Vector3.new(-922.9354, 166.3552, 856.2858), -- Start
        [2] = Vector3.new(-433, 245.3983, 793), -- Camp 1
        [3] = Vector3.new(-357.8944, 385.4008, 544.6857), -- Camp 2
        [4] = Vector3.new(276.1503, 426.5, 510.5456), -- Camp 3
        [5] = Vector3.new(343.7578, 481.3751, 378.8087), -- Camp 4
        [6] = Vector3.new(235.9059, 310.4505, -203.1223), -- Camp 5
    }

    local hasWalkFileApi = type(writefile) == "function"
        and type(readfile) == "function"
        and type(isfile) == "function"
        and type(isfolder) == "function"
        and type(makefolder) == "function"

    local function ensureRoutesFolder()
        local acc = nil
        for part in string.gmatch(ROUTES_DIR, "[^/]+") do
            acc = acc and (acc .. "/" .. part) or part
            if not isfolder(acc) then
                makefolder(acc)
            end
        end
    end

    local function setRoutesParagraph(content: string)
        local p = AutoSummitRoutesParagraph
        if p and p.Set then
            pcall(function()
                p:Set({ Title = "Walk routes", Content = content })
            end)
        end
    end

    local function loadLocalPossibilities(): boolean
        if not hasWalkFileApi or not isfile(POSSIBILITIES_FILE) then
            return false
        end
        local okRead, raw = pcall(readfile, POSSIBILITIES_FILE)
        if not okRead or type(raw) ~= "string" then
            return false
        end
        local okDec, decoded = pcall(function()
            return HttpService:JSONDecode(raw)
        end)
        if not okDec or type(decoded) ~= "table" or type(decoded.legs) ~= "table" or #decoded.legs == 0 then
            return false
        end
        routePossibilities = decoded
        return true
    end

    local function loadRouteData(fileName: string): (any, string?)
        local path = ROUTES_DIR .. "/" .. fileName
        local okRead, raw = pcall(readfile, path)
        if not okRead or type(raw) ~= "string" then
            return nil, "cannot read " .. path
        end
        local okDec, data = pcall(function()
            return HttpService:JSONDecode(raw)
        end)
        if not okDec or type(data) ~= "table" or type(data.frames) ~= "table" or #data.frames < 2 then
            return nil, "invalid route file " .. fileName
        end
        return data, nil
    end

    local function findLegEntry(legName: string): any
        if type(routePossibilities) ~= "table" or type(routePossibilities.legs) ~= "table" then
            return nil
        end
        for _, leg in ipairs(routePossibilities.legs) do
            if leg.leg == legName then
                return leg
            end
        end
        return nil
    end

    syncRoutesFromRepo = function(fromButton: boolean?)
        if routeSyncActive then
            if fromButton then
                notifyAutoSummit("Route sync already running", "x")
            end
            return
        end
        if not hasWalkFileApi then
            setRoutesParagraph("Executor has no file API — Walk mode unavailable.")
            if fromButton then
                notifyAutoSummit("Executor has no file API — Walk mode unavailable", "x")
            end
            return
        end
        routeSyncActive = true
        local okAll, syncErr = pcall(function()
            ensureRoutesFolder()
            setRoutesParagraph("Fetching possibilities…")

            local okHttp, raw = pcall(function()
                return game:HttpGet(POSSIBILITIES_REMOTE_URL)
            end)
            if not okHttp or type(raw) ~= "string" or #raw < 16 then
                error("possibilities.json fetch failed", 0)
            end
            local okDec, decoded = pcall(function()
                return HttpService:JSONDecode(raw)
            end)
            if not okDec or type(decoded) ~= "table" or type(decoded.legs) ~= "table" or #decoded.legs == 0 then
                error("possibilities.json invalid", 0)
            end
            writefile(POSSIBILITIES_FILE, raw)
            routePossibilities = decoded

            local fileList = {}
            for _, leg in ipairs(decoded.legs) do
                if type(leg.routes) == "table" then
                    for _, r in ipairs(leg.routes) do
                        if type(r.file) == "string" and r.file ~= "" then
                            table.insert(fileList, r.file)
                        end
                    end
                end
            end

            local total = #fileList
            local synced = 0
            local failed = 0
            for i, fileName in ipairs(fileList) do
                local okGet, src = pcall(function()
                    return game:HttpGet(ROUTES_REMOTE_DIR .. fileName)
                end)
                if okGet and type(src) == "string" and #src > 64 and string.sub(src, 1, 1) == "{" then
                    local okWrite = pcall(function()
                        writefile(ROUTES_DIR .. "/" .. fileName, src)
                    end)
                    if okWrite then
                        synced = synced + 1
                    else
                        failed = failed + 1
                    end
                else
                    failed = failed + 1
                end
                setRoutesParagraph(("Syncing routes… %d/%d (%d failed)"):format(i, total, failed))
                if i % 4 == 0 then
                    task.wait()
                end
            end

            setRoutesParagraph(("Routes: %d/%d synced (%d failed)."):format(synced, total, failed))
            if fromButton or failed > 0 then
                notifyAutoSummit(
                    ("Routes synced: %d/%d (%d failed)"):format(synced, total, failed),
                    failed > 0 and "x" or "check"
                )
            end
        end)
        routeSyncActive = false
        if not okAll then
            setRoutesParagraph("Route sync failed: " .. tostring(syncErr))
            if fromButton then
                notifyAutoSummit("Route sync failed: " .. tostring(syncErr), "x")
            end
        end
    end

    -- Outcome by recorded success chance, then weighted roulette over the
    -- outcome's routes with the recorded per-route chance scaled by closeness
    -- of the route's start to the character ("chance + closest start").
    local function pickRouteForLeg(legEntry: any, includeFailed: boolean, currentPos: Vector3?): any
        local routes = type(legEntry.routes) == "table" and legEntry.routes or {}
        local wantOutcome = "success"
        if includeFailed and (tonumber(legEntry.failedCount) or 0) > 0 then
            if (tonumber(legEntry.successCount) or 0) <= 0 then
                wantOutcome = "failed"
            elseif autoSummitRng:NextNumber(0, 100) >= (tonumber(legEntry.successChancePercent) or 100) then
                wantOutcome = "failed"
            end
        end

        local function candidatesFor(outcome)
            local out = {}
            for _, r in ipairs(routes) do
                if r.outcome == outcome and type(r.file) == "string" and isfile(ROUTES_DIR .. "/" .. r.file) then
                    table.insert(out, r)
                end
            end
            return out
        end

        local candidates = candidatesFor(wantOutcome)
        if #candidates == 0 then
            candidates = candidatesFor(wantOutcome == "success" and "failed" or "success")
        end
        if #candidates == 0 then
            return nil
        end

        local weights = {}
        local total = 0
        for i, r in ipairs(candidates) do
            local w = tonumber(r.chancePercent) or 1
            local s = r.start
            if currentPos and type(s) == "table" and #s >= 3 then
                local d = (currentPos - Vector3.new(s[1], s[2], s[3])).Magnitude
                w = w / (1 + d)
            end
            weights[i] = w
            total = total + w
        end
        local roll = autoSummitRng:NextNumber(0, total)
        local acc = 0
        for i, r in ipairs(candidates) do
            acc = acc + weights[i]
            if roll <= acc then
                return r
            end
        end
        return candidates[#candidates]
    end

    -- Walk (never teleport) from wherever the character is to the route's
    -- first frame; playback's frame-1 snap covers the last few studs.
    local function walkConnectToRouteStart(targetPos: Vector3, shouldAbort: () -> boolean): boolean
        local char = lpAutoSummit.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not root or not hum then
            return false
        end
        if (root.Position - targetPos).Magnitude <= WALK_CONNECT_ARRIVAL_DIST then
            return true
        end
        local arrived = humanoidWalkToWorldPosition(hum, root, targetPos, shouldAbort, WALK_CONNECT_ARRIVAL_DIST)
        if shouldAbort() then
            return false
        end
        if not arrived then
            arrived = humanoidWalkToWorldPosition(hum, root, targetPos, shouldAbort, WALK_CONNECT_ARRIVAL_DIST)
            if shouldAbort() then
                return false
            end
        end
        local ch = lpAutoSummit.Character
        local newRoot = ch and ch:FindFirstChild("HumanoidRootPart")
        if not newRoot then
            return false
        end
        return (newRoot.Position - targetPos).Magnitude <= WALK_CONNECT_GIVE_UP_DIST
    end

    -- After a failed route the character keeps falling until the game CFrames
    -- it back to the camp's FallSpawn; resume the moment we are back on the
    -- ground there — no extra settle delay, the next route starts immediately.
    local function waitForFallRespawnSettle(
        shouldAbort: () -> boolean,
        campStepIdx: number
    ): "settled" | "died" | "abort" | "timeout"
        local spawnPos = WALK_FALL_SPAWNS[campStepIdx]
        local waitStart = os.clock()
        local lastPos: Vector3? = nil
        local respawnSeen = false
        while true do
            if shouldAbort() then
                return autoSummitRestartFromDeath and "died" or "abort"
            end
            if os.clock() - waitStart > FALL_SETTLE_TIMEOUT_SEC then
                return "timeout"
            end
            local char = lpAutoSummit.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if root and hum then
                local pos = root.Position
                if not respawnSeen then
                    if spawnPos and (pos - spawnPos).Magnitude < 40 then
                        respawnSeen = true
                    elseif lastPos and (pos - lastPos).Magnitude > 50 then
                        respawnSeen = true -- teleport-sized jump = the game respawned us
                    end
                end
                lastPos = pos
                if respawnSeen and hum.FloorMaterial ~= Enum.Material.Air then
                    return "settled"
                end
            end
            RunService.Heartbeat:Wait()
        end
    end

    -- Success when LastCheckpoint changes OR CP_Notify ok arrives; unlike the
    -- teleport variant, a timeout is returned to the caller (walk mode retries
    -- the leg instead of aborting the run) and "Terlalu cepat" is ignored.
    local function walkWaitForCpAdvance(
        cpLabelBefore: string,
        shouldAbort: () -> boolean
    ): "confirmed" | "abort" | "timeout"
        local waitStart = os.clock()
        while not shouldAbort() do
            if os.clock() - waitStart > WALK_CP_ACK_TIMEOUT_SEC then
                return "timeout"
            end

            syncAutoSummitCurrentCheckpointSnapshot()
            if autoSummitCurrentCpLabel ~= cpLabelBefore then
                return "confirmed"
            end

            while #cpNotifyRealtimeQueue > 0 do
                local payload = table.remove(cpNotifyRealtimeQueue, 1)
                if cpNotifyPayloadIsOkSaved(payload) then
                    return "confirmed"
                end
            end

            RunService.Heartbeat:Wait()
        end
        return "abort"
    end

    local function runAutoSummitWalkCycle(
        shouldAbort: () -> boolean,
        getRootPart: (number?) -> BasePart?,
        skipNextCpResumeNotify: boolean
    ): (boolean, boolean, boolean)
        if not RoutePlayer then
            skipNextCpResumeNotify = false
            disableAutoSummit("Walk mode: Route Player module failed to load")
            return false, false, skipNextCpResumeNotify
        end
        if not hasWalkFileApi then
            skipNextCpResumeNotify = false
            disableAutoSummit("Walk mode: executor has no file API — use Teleport mode")
            return false, false, skipNextCpResumeNotify
        end
        while routeSyncActive do
            if shouldAbort() then
                return false, false, skipNextCpResumeNotify
            end
            task.wait(0.25)
        end
        if not routePossibilities and not loadLocalPossibilities() then
            skipNextCpResumeNotify = false
            disableAutoSummit("Walk mode: routes not downloaded — press Refresh Routes")
            return false, false, skipNextCpResumeNotify
        end

        -- Subscribe for the whole cycle so CPs that fire mid-playback are never missed.
        ensureCpNotifyRealtimeListener()

        local function walkCycleImpl(): (boolean, boolean, boolean)
            local reachedSummitThisCycle = false
            local descendedThisCycle = false
            local ascendedLegThisCycle = false
            local legAttempts: { [string]: number } = {}
            local legFailedOnce: { [string]: boolean } = {}
            local stepOverride: number? = nil

            syncAutoSummitCurrentCheckpointSnapshot()
            local routeStepNow = summitRouteStepIndexFromLabel(autoSummitCurrentCpLabel)
            if routeStepNow == nil then
                skipNextCpResumeNotify = false
                disableAutoSummit(
                    "Unknown checkpoint label (not on summit route): " .. tostring(autoSummitCurrentCpLabel)
                )
                return false, false, skipNextCpResumeNotify
            end

            if not skipNextCpResumeNotify then
                local canonical = summitRoute[routeStepNow].name or autoSummitCurrentCpLabel
                notifyAutoSummit(("%s — walk mode..."):format(canonical))
            else
                skipNextCpResumeNotify = false
            end

            while true do
                if not autoSummitEnabled or shouldAbort() then
                    return false, reachedSummitThisCycle, skipNextCpResumeNotify
                end

                syncAutoSummitCurrentCheckpointSnapshot()
                local step = stepOverride or summitRouteStepIndexFromLabel(autoSummitCurrentCpLabel)
                stepOverride = nil
                if step == nil then
                    disableAutoSummit(
                        "Unknown checkpoint label (not on summit route): " .. tostring(autoSummitCurrentCpLabel)
                    )
                    return false, reachedSummitThisCycle, skipNextCpResumeNotify
                end

                if step >= #summitRoute then
                    if ascendedLegThisCycle then
                        reachedSummitThisCycle = true
                        return true, reachedSummitThisCycle, skipNextCpResumeNotify
                    end
                    if descendedThisCycle then
                        -- Descended but the label still reads Summit and we are not
                        -- near Start: bail out instead of looping forever.
                        disableAutoSummit("Walk mode: descent finished but current camp unknown")
                        return false, reachedSummitThisCycle, skipNextCpResumeNotify
                    end

                    -- Cycle started at Summit: walk back down before the next ascent.
                    local legEntry = findLegEntry(WALK_DESCENT_LEG)
                    local rootPart = getRootPart()
                    local route = legEntry and rootPart and pickRouteForLeg(legEntry, false, rootPart.Position)
                    if not route then
                        disableAutoSummit("Walk mode: no descent route — press Refresh Routes")
                        return false, reachedSummitThisCycle, skipNextCpResumeNotify
                    end
                    local data, loadErr = loadRouteData(route.file)
                    if not data then
                        disableAutoSummit("Walk mode: " .. tostring(loadErr))
                        return false, reachedSummitThisCycle, skipNextCpResumeNotify
                    end

                    notifyAutoSummit("Walking down to Start...")
                    markRoutePicked(route.file)

                    local startPos = Vector3.new(route.start[1], route.start[2], route.start[3])
                    if not walkConnectToRouteStart(startPos, shouldAbort) then
                        return false, reachedSummitThisCycle, skipNextCpResumeNotify
                    end
                    markRoutePlaying(route.file)
                    routeTrackerCurrentFrames = data.frames
                    drawRouteTracker(data.frames)
                    local completed = RoutePlayer.playRouteData(data, {
                        shouldCancel = shouldAbort,
                        noClip = WALK_PLAYBACK_NOCLIP,
                        blendInSeconds = WALK_START_BLEND_SEC,
                    })
                    if not completed or autoSummitRestartFromDeath then
                        return false, reachedSummitThisCycle, skipNextCpResumeNotify
                    end
                    descendedThisCycle = true

                    syncAutoSummitCurrentCheckpointSnapshot()
                    local stepAfter = summitRouteStepIndexFromLabel(autoSummitCurrentCpLabel)
                    if stepAfter == nil or stepAfter >= #summitRoute then
                        local rp = getRootPart()
                        if rp and (rp.Position - WALK_FALL_SPAWNS[1]).Magnitude < 80 then
                            stepOverride = 1
                        end
                        -- else: loop re-enters the summit branch and bails out above.
                    end
                else
                    local legName = WALK_LEG_BY_STEP[step]
                    local legEntry = findLegEntry(legName)
                    if not legEntry then
                        disableAutoSummit("Walk mode: possibilities.json is missing leg " .. legName)
                        return false, reachedSummitThisCycle, skipNextCpResumeNotify
                    end

                    legAttempts[legName] = (legAttempts[legName] or 0) + 1
                    if legAttempts[legName] > WALK_MAX_LEG_ATTEMPTS then
                        disableAutoSummit(
                            ("Walk mode: leg %s did not advance after %d attempts"):format(legName, WALK_MAX_LEG_ATTEMPTS)
                        )
                        return false, reachedSummitThisCycle, skipNextCpResumeNotify
                    end

                    local rootPart = getRootPart()
                    if not rootPart then
                        notifyAutoSummit("Walk mode: HumanoidRootPart missing", "x")
                        return false, reachedSummitThisCycle, skipNextCpResumeNotify
                    end

                    -- Once this leg has already run a failed route this cycle, force a
                    -- success route on the retry so the same cp is not failed repeatedly.
                    local includeFailedThisPick = autoSummitIncludeFailedRoutes and not legFailedOnce[legName]
                    local route = pickRouteForLeg(legEntry, includeFailedThisPick, rootPart.Position)
                    if not route then
                        disableAutoSummit(
                            ("Walk mode: no local routes for %s — press Refresh Routes"):format(legName)
                        )
                        return false, reachedSummitThisCycle, skipNextCpResumeNotify
                    end

                    local data, loadErr = loadRouteData(route.file)
                    if not data then
                        notifyAutoSummit("Walk mode: " .. tostring(loadErr), "x")
                    else
                        markRoutePicked(route.file)

                        local startPos = Vector3.new(route.start[1], route.start[2], route.start[3])
                        if not walkConnectToRouteStart(startPos, shouldAbort) then
                            if shouldAbort() then
                                return false, reachedSummitThisCycle, skipNextCpResumeNotify
                            end
                            notifyAutoSummit(
                                ("Walk mode: could not reach start of %s — retrying"):format(route.file),
                                "x"
                            )
                        else
                            syncAutoSummitCurrentCheckpointSnapshot()
                            local cpBefore = autoSummitCurrentCpLabel
                            flushCpNotifyRealtimeQueue()
                            markRoutePlaying(route.file)
                            routeTrackerCurrentFrames = data.frames
                            drawRouteTracker(data.frames)
                            local completed, reason = RoutePlayer.playRouteData(data, {
                                shouldCancel = shouldAbort,
                                noClip = WALK_PLAYBACK_NOCLIP,
                                blendInSeconds = WALK_START_BLEND_SEC,
                            })
                            if reason == "died" or autoSummitRestartFromDeath then
                                return false, reachedSummitThisCycle, skipNextCpResumeNotify
                            end
                            if not completed then
                                return false, reachedSummitThisCycle, skipNextCpResumeNotify
                            end

                            if route.outcome == "success" then
                                local ack = walkWaitForCpAdvance(cpBefore, shouldAbort)
                                if ack == "confirmed" then
                                    legAttempts[legName] = 0
                                    ascendedLegThisCycle = true
                                elseif ack == "abort" then
                                    return false, reachedSummitThisCycle, skipNextCpResumeNotify
                                else
                                    notifyAutoSummit(
                                        ("Walk mode: %s ended without CP register — retrying leg"):format(route.file),
                                        "x"
                                    )
                                end
                            else
                                -- Failed route ran on this leg: the retry is forced to success.
                                legFailedOnce[legName] = true
                                local settle = waitForFallRespawnSettle(shouldAbort, step)
                                if settle == "died" or settle == "abort" then
                                    return false, reachedSummitThisCycle, skipNextCpResumeNotify
                                end
                                -- settled / timeout: loop re-picks the same leg (now success-only).
                            end
                        end
                    end
                end
            end
        end

        local wr, ws, wu = walkCycleImpl()
        stopCpNotifyRealtimeListener()
        return wr, ws, wu
    end

    local function getAutoSummitBetweenRunDelay()
        return autoSummitRng:NextNumber(BETWEEN_RUN_DELAY_MIN, BETWEEN_RUN_DELAY_MAX)
    end

    local function updateAutoSummitCpParagraph()
        syncAutoSummitCurrentCheckpointSnapshot()
        if not autoSummitEnabled then
            return
        end
        if not AutoSummitCpParagraph then
            return
        end
        local posisi = autoSummitCurrentCpLabel
        local routeStep = summitRouteStepIndexFromLabel(posisi)
        local routeName = routeStep and summitRoute[routeStep].name or "—"
        local desc = string.format("POSISI: %s\nRoute: %s", string.upper(posisi), routeName)
        if AutoSummitCpParagraph.Set then
            AutoSummitCpParagraph:Set({
                Title = AUTO_SUMMIT_CP_TITLE,
                Content = desc,
            })
        end
        task.defer(updateAutoSummitRouteSequenceParagraph)
    end

    AutoSummitCpParagraph = MainTab:CreateParagraph({
        Title = AUTO_SUMMIT_CP_TITLE,
        Content = "POSISI: —\nRoute: Start",
    })

    AutoSummitRouteSequenceParagraph = MainTab:CreateParagraph({
        Title = ROUTE_SEQUENCE_TITLE,
        Content = "Auto Summit is off.",
    })
    task.defer(updateAutoSummitRouteSequenceParagraph)

    AutoSummitTimesParagraph = MainTab:CreateParagraph({
        Title = AUTO_SUMMIT_TIMES_TITLE,
        Content = "No completed runs yet.",
    })

    local function attachLeaderstatsForCp(ls)
        local function onCheckpointValueChanged()
            syncAutoSummitCurrentCheckpointSnapshot()
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

    lpAutoSummit:GetAttributeChangedSignal("LastCheckpoint"):Connect(function()
        syncAutoSummitCurrentCheckpointSnapshot()
        updateAutoSummitCpParagraph()
    end)
    local lsSummitCp = lpAutoSummit:FindFirstChild("leaderstats")
    if lsSummitCp then
        attachLeaderstatsForCp(lsSummitCp)
    end
    lpAutoSummit.ChildAdded:Connect(function(ch)
        if ch.Name == "leaderstats" then
            attachLeaderstatsForCp(ch)
            updateAutoSummitCpParagraph()
        end
    end)
    task.defer(updateAutoSummitCpParagraph)

    MainTab:CreateDropdown({
        Name = "Auto Summit Mode",
        Flag = "yahayuk_main_auto_summit_mode",
        Options = { "Walk", "Teleport" },
        CurrentOption = { "Walk" },
        Callback = function(value)
            local mode = rayfieldDropdownFirst(value)
            if mode == "Walk" or mode == "Teleport" then
                autoSummitMode = mode
            end
        end,
    })

    local SummitQtyInput = MainTab:CreateInput({
        Name = "Qty of summit",
        Flag = "yahayuk_main_summit_qty",
        PlaceholderText = "Empty = unlimited",
        CurrentValue = "",
        Callback = function(value)
            summitQty = value
        end,
    })

    MainTab:CreateToggle({
        Name = "Randomize Teleport",
        Flag = "yahayuk_main_randomize_teleport",
        CurrentValue = false,
        Callback = function(enabled)
            autoSummitRandomizeTeleportDelay = enabled
        end,
    })

    MainTab:CreateToggle({
        Name = "Include failed routes (Walk mode)",
        Flag = "yahayuk_main_include_failed_routes",
        CurrentValue = true,
        Callback = function(enabled)
            autoSummitIncludeFailedRoutes = enabled
        end,
    })

    MainTab:CreateToggle({
        Name = "Show Tracker (Walk mode)",
        Flag = "yahayuk_main_show_tracker",
        CurrentValue = false,
        Callback = function(enabled)
            autoSummitShowTracker = enabled
            if enabled then
                if autoSummitEnabled and routeTrackerCurrentFrames then
                    drawRouteTracker(routeTrackerCurrentFrames)
                end
            else
                clearRouteTracker()
            end
        end,
    })

    MainTab:CreateSlider({
        Name = "Tracker Overlap Sensitivity",
        Flag = "yahayuk_main_tracker_sensitivity",
        Range = { 0, 5 },
        Increment = 0.1,
        Suffix = "x",
        CurrentValue = autoSummitTrackerSensitivity,
        Callback = function(value)
            autoSummitTrackerSensitivity = tonumber(value) or autoSummitTrackerSensitivity
            if autoSummitShowTracker and routeTrackerCurrentFrames then
                drawRouteTracker(routeTrackerCurrentFrames)
            end
        end,
    })

    MainTab:CreateSlider({
        Name = "Tracker Overlap Detect Distance",
        Flag = "yahayuk_main_tracker_cell_size",
        Range = { 1, 15 },
        Increment = 0.5,
        Suffix = "studs",
        CurrentValue = autoSummitTrackerCellSize,
        Callback = function(value)
            autoSummitTrackerCellSize = tonumber(value) or autoSummitTrackerCellSize
            if autoSummitShowTracker and routeTrackerCurrentFrames then
                drawRouteTracker(routeTrackerCurrentFrames)
            end
        end,
    })

    local function onAutoSummitDeath()
        autoSummitRestartFromDeath = true
    end

    local function connectAutoSummitCharacterDied(character)
        if not character then
            return
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return
        end
        humanoid.Died:Connect(onAutoSummitDeath)
        humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then
                onAutoSummitDeath()
            end
        end)
    end

    if lpAutoSummit.Character then
        connectAutoSummitCharacterDied(lpAutoSummit.Character)
    end
    lpAutoSummit.CharacterAdded:Connect(connectAutoSummitCharacterDied)

    autoSummitMainToggle = MainTab:CreateToggle({
        Name = "Auto Summit",
        Flag = "yahayuk_main_auto_summit",
        CurrentValue = false,
        Callback = function(enabled)
            autoSummitEnabled = enabled
            if not enabled then
                if autoSummitDeathCheckConn then
                    autoSummitDeathCheckConn:Disconnect()
                    autoSummitDeathCheckConn = nil
                end
                if RoutePlayer then
                    pcall(function()
                        RoutePlayer.stop()
                    end)
                end
                autoSummitTeleportStepDisplay = "—"
                resetAutoSummitRouteSequence()
                routeTrackerCurrentFrames = nil
                clearRouteTracker()
                task.defer(updateAutoSummitRouteSequenceParagraph)
                return
            end

            autoSummitRestartFromDeath = false
            autoSummitRunTimes = {}
            updateAutoSummitTimesParagraph()
            updateAutoSummitCpParagraph()
            updateAutoSummitRouteSequenceParagraph()

            if autoSummitDeathCheckConn then
                autoSummitDeathCheckConn:Disconnect()
            end
            autoSummitDeathCheckConn = RunService.Heartbeat:Connect(function()
                if not autoSummitEnabled then
                    return
                end
                local char = lpAutoSummit.Character
                if not char then
                    return
                end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    onAutoSummitDeath()
                end
            end)

            local function getRootPart(timeoutSec)
                local char = lpAutoSummit.Character
                if not char then
                    char = lpAutoSummit.CharacterAdded:Wait()
                end
                return char:WaitForChild("HumanoidRootPart", timeoutSec or 15)
            end

            local rootPart = getRootPart()
            if not rootPart then
                notifyAutoSummit("Character not loaded", "x")
                return
            end

            task.spawn(function()
                local qtyNum = tonumber(summitQty and summitQty:gsub("%s+", "") or "")
                local runCount = 0
                local remaining = qtyNum
                local skipNextCpResumeNotify = false
                repeat
                    if not autoSummitEnabled then
                        break
                    end
                    local function shouldAbort()
                        return not autoSummitEnabled or autoSummitRestartFromDeath
                    end
                    autoSummitTeleportStepDisplay = "—"
                    resetAutoSummitRouteSequence()
                    updateAutoSummitRouteSequenceParagraph()
                    local runStartTime = os.clock()
                    rootPart = getRootPart()
                    if not rootPart then
                        local char = lpAutoSummit.Character
                        if char then
                            char:WaitForChild("HumanoidRootPart", 10)
                        else
                            char = lpAutoSummit.CharacterAdded:Wait()
                            char:WaitForChild("HumanoidRootPart", 10)
                        end
                        task.wait(1)
                        rootPart = getRootPart()
                        if not rootPart then
                            notifyAutoSummit("Could not get character after respawn", "x")
                            break
                        end
                    end

                    local routeCompleted, reachedSummitThisCycle
                    if autoSummitMode == "Walk" then
                        routeCompleted, reachedSummitThisCycle, skipNextCpResumeNotify =
                            runAutoSummitWalkCycle(shouldAbort, getRootPart, skipNextCpResumeNotify)
                    else
                        routeCompleted, reachedSummitThisCycle, skipNextCpResumeNotify =
                            runAutoSummitTeleportCycle(shouldAbort, getRootPart, skipNextCpResumeNotify)
                    end

                    if autoSummitRestartFromDeath then
                        notifyAutoSummit("Character died â€” waiting for respawnâ€¦")
                        local char = lpAutoSummit.Character
                        if not char then
                            char = lpAutoSummit.CharacterAdded:Wait()
                        else
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health <= 0 then
                                char = lpAutoSummit.CharacterAdded:Wait()
                            end
                        end
                        if char then
                            char:WaitForChild("HumanoidRootPart", 15)
                            task.wait(0.5)
                        end
                        for _ = 1, 15 do
                            if lpAutoSummit:FindFirstChild("leaderstats") then
                                break
                            end
                            task.wait(0.1)
                        end
                        task.wait(0.35)
                        syncAutoSummitCurrentCheckpointSnapshot()
                        local stepRespawn = summitRouteStepIndexFromLabel(autoSummitCurrentCpLabel)
                        local nextResumeIdx = (stepRespawn and stepRespawn < #summitRoute) and (stepRespawn + 1)
                            or nil
                        task.defer(updateAutoSummitCpParagraph)
                        autoSummitRestartFromDeath = false
                        skipNextCpResumeNotify = true
                        if nextResumeIdx == nil then
                            notifyAutoSummit(
                                ("Respawned — %s. Next leg: Summit / count run."):format(autoSummitCurrentCpLabel)
                            )
                        else
                            notifyAutoSummit(
                                ("Respawned — %s; resuming from %s."):format(
                                    autoSummitCurrentCpLabel,
                                    summitRoute[nextResumeIdx].name
                                )
                            )
                        end
                    elseif routeCompleted and autoSummitEnabled then
                        syncAutoSummitCurrentCheckpointSnapshot()
                        local stepAfterRun = summitRouteStepIndexFromLabel(autoSummitCurrentCpLabel)
                        local atSummitNow = stepAfterRun == #summitRoute
                        local nameAfterRun = stepAfterRun and summitRoute[stepAfterRun].name
                            or autoSummitCurrentCpLabel
                        local reachedSummitThisRun = reachedSummitThisCycle

                        if reachedSummitThisRun then
                            notifyAutoSummit("Reached Summit! (Run " .. (runCount + 1) .. ")")
                            local elapsedRun = os.clock() - runStartTime
                            table.insert(autoSummitRunTimes, elapsedRun)
                            task.defer(updateAutoSummitTimesParagraph)
                            runCount = runCount + 1
                            if remaining then
                                remaining = remaining - 1
                                summitQty = tostring(remaining)
                                task.defer(function()
                                    if SummitQtyInput then
                                        if SummitQtyInput.Set then
                                            SummitQtyInput:Set(summitQty)
                                        end
                                        if SummitQtyInput.SetValue then
                                            SummitQtyInput:SetValue(summitQty)
                                        end
                                    end
                                end)
                            end
                            -- Walk mode runs back-to-back with no between-run delay.
                            if autoSummitEnabled and autoSummitMode ~= "Walk" and (not qtyNum or remaining > 0) then
                                local betweenRunDelay = getAutoSummitBetweenRunDelay()
                                if not waitWithCancel(betweenRunDelay, shouldAbort) then
                                    if not autoSummitEnabled then
                                        break
                                    end
                                end
                            end
                        elseif atSummitNow then
                            notifyAutoSummit(
                                ("At Summit (%s), waiting for camp change before counting next run."):format(
                                    autoSummitCurrentCpLabel
                                )
                            )
                            -- Teleport mode pauses ~1s for the camp label to change; Walk mode does not.
                            if autoSummitMode ~= "Walk" then
                                if not waitWithCancel(1, shouldAbort) and not autoSummitEnabled then
                                    break
                                end
                            end
                        else
                            notifyAutoSummit(
                                ("Route ended at %s — continuing from current camp."):format(nameAfterRun)
                            )
                        end
                    end
                until not autoSummitEnabled or (qtyNum and remaining and remaining <= 0)

                if autoSummitEnabled and qtyNum and remaining and remaining <= 0 then
                    notifyAutoSummit("All runs completed (" .. runCount .. " run(s))")
                elseif not autoSummitEnabled then
                    if autoSummitSkipFinalStoppedNotify then
                        autoSummitSkipFinalStoppedNotify = false
                    else
                        notifyAutoSummit("Stopped", "x")
                    end
                end

                if autoSummitDeathCheckConn then
                    autoSummitDeathCheckConn:Disconnect()
                    autoSummitDeathCheckConn = nil
                end
            end)
        end,
    })

    -- Sync walk routes in the background at startup so the UI never blocks;
    -- show whatever is already on disk immediately.
    if hasWalkFileApi then
        task.spawn(function()
            if loadLocalPossibilities() then
                setRoutesParagraph("Routes loaded from disk — refreshing in background…")
            end
            if syncRoutesFromRepo then
                syncRoutesFromRepo(false)
            end
        end)
    end

    MainTab:CreateSection("Send Request Carry")

    local SendRequestCarryCarrierListParagraph
    local sendRequestCarryUpdateCarrierListParagraph

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
        local lp = lpAutoSummit
        local myRoot = sendRequestCarryGetRootPart(lp.Character)
        if not myRoot then
            return false
        end
        local tgtPlr = Players:GetPlayerByUserId(targetUserId)
        if not tgtPlr or tgtPlr == lp then
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
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.ClassName == "Player" then
                table.insert(opts, sendRequestCarryOtherPlayerLabel(plr))
            end
        end
        table.sort(opts, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return opts
    end

    local function sendRequestCarryFindPlayerByLabel(label)
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and sendRequestCarryOtherPlayerLabel(plr) == label then
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
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.ClassName == "Player" then
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

    -- Every other player in the server that is not on the carrier list and not
    -- on the declined cooldown (used by Auto Send Nearby). The in-range check
    -- happens later in the send loop, so "nearby" is enforced there.
    local function sendRequestCarryCollectAllOtherIds()
        local ids = {}
        local seen = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lpAutoSummit and plr.ClassName == "Player" then
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
            return ReplicatedStorage:WaitForChild("CarryRemote", 10)
        end)
        if ok and carryRemote then
            return carryRemote
        end
        return nil
    end

    -- Shared send loop: fires "Request" to in-range targets from getTargets()
    -- until getToken() no longer matches startToken (i.e. the toggle changed).
    local function sendRequestCarrySpawnAutoLoop(carryRemote, startToken, getToken, getTargets, noTargetMsg)
        local warnedNoTargets = false
        task.spawn(function()
            while startToken == getToken() do
                local targets = getTargets()
                if #targets == 0 then
                    if not warnedNoTargets and noTargetMsg then
                        warnedNoTargets = true
                        mountNotify({
                            Title = "Send Request Carry",
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
        Flag = "yahayuk_main_send_carry_to",
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
        Flag = "yahayuk_main_send_carry_by_name",
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
        Flag = "yahayuk_main_send_carry_auto",
        CurrentValue = false,
        Callback = function(enabled)
            sendRequestCarryAutoEnabled = enabled
            sendRequestCarryAutoLoopToken = sendRequestCarryAutoLoopToken + 1
            if not enabled then
                return
            end

            -- Only one auto-send mode runs at a time so nobody is double-sent.
            if sendRequestCarryAutoNearbyEnabled and SendRequestCarryAutoNearbyToggle and SendRequestCarryAutoNearbyToggle.Set then
                SendRequestCarryAutoNearbyToggle:Set(false)
            end

            local carryRemote = sendRequestCarryGetCarryRemote()
            if not carryRemote then
                mountNotify({
                    Title = "Send Request Carry",
                    Content = "CarryRemote not found in ReplicatedStorage",
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
                Title = "Send Request Carry",
                Content = "Auto send started",
                Icon = "check",
            })
        end,
    })

    SendRequestCarryAutoNearbyToggle = MainTab:CreateToggle({
        Name = "Auto Send Nearby",
        Flag = "yahayuk_main_send_carry_auto_nearby",
        CurrentValue = false,
        Callback = function(enabled)
            sendRequestCarryAutoNearbyEnabled = enabled
            sendRequestCarryAutoNearbyLoopToken = sendRequestCarryAutoNearbyLoopToken + 1
            if not enabled then
                return
            end

            -- Only one auto-send mode runs at a time so nobody is double-sent.
            if sendRequestCarryAutoEnabled and SendRequestCarryAutoToggle and SendRequestCarryAutoToggle.Set then
                SendRequestCarryAutoToggle:Set(false)
            end

            local carryRemote = sendRequestCarryGetCarryRemote()
            if not carryRemote then
                mountNotify({
                    Title = "Send Request Carry",
                    Content = "CarryRemote not found in ReplicatedStorage",
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
                Title = "Send Request Carry",
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
        local ok, carryRemote = pcall(function()
            return ReplicatedStorage:WaitForChild("CarryRemote", 60)
        end)
        if not ok or not carryRemote then
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

    MainTab:CreateSection("Accept Incoming Carry")

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
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.ClassName == "Player" then
                table.insert(opts, acceptIncomingCarryOtherPlayerLabel(plr))
            end
        end
        table.sort(opts, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return opts
    end

    local function acceptIncomingCarryFindPlayerByLabel(label)
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and acceptIncomingCarryOtherPlayerLabel(plr) == label then
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
        Flag = "yahayuk_main_accept_carry_from",
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
        Flag = "yahayuk_main_accept_carry_auto",
        CurrentValue = false,
        Callback = function(enabled)
            if acceptIncomingCarryRemoteConn then
                acceptIncomingCarryRemoteConn:Disconnect()
                acceptIncomingCarryRemoteConn = nil
            end
            if not enabled then
                return
            end
            local ok, carryRemote = pcall(function()
                return ReplicatedStorage:WaitForChild("CarryRemote", 10)
            end)
            if not ok or not carryRemote then
                mountNotify({
                    Title = "Accept Incoming Carry",
                    Content = "CarryRemote not found in ReplicatedStorage",
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
                Title = "Accept Incoming Carry",
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

    MainTab:CreateSection("Transfer Cash")

    local transferCashAmountText = ""
    local transferCashSelectedPlayer: Player? = nil
    local TransferCashPlayersDropdown

    local function transferCashPlayerLabel(player: Player)
        local lp = Players.LocalPlayer
        local dn = player.DisplayName
        local base: string
        if dn and dn ~= "" and dn ~= player.Name then
            base = string.format("%s (@%s)", dn, player.Name)
        else
            base = player.Name
        end
        if player == lp then
            return base .. " (you)"
        end
        return base
    end

    local function transferCashDropdownOptions()
        local opts = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.ClassName == "Player" then
                table.insert(opts, transferCashPlayerLabel(plr))
            end
        end
        table.sort(opts, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return opts
    end

    local function transferCashFindPlayerByLabel(label: string)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.ClassName == "Player" and transferCashPlayerLabel(plr) == label then
                return plr
            end
        end
        return nil
    end

    local function transferCashRefreshList()
        local opts = transferCashDropdownOptions()
        if transferCashSelectedPlayer then
            if Players:GetPlayerByUserId(transferCashSelectedPlayer.UserId) ~= transferCashSelectedPlayer then
                transferCashSelectedPlayer = nil
            end
        end
        if TransferCashPlayersDropdown and TransferCashPlayersDropdown.Refresh then
            TransferCashPlayersDropdown:Refresh(opts)
        end
        if transferCashSelectedPlayer then
            local lbl = transferCashPlayerLabel(transferCashSelectedPlayer)
            if table.find(opts, lbl) and TransferCashPlayersDropdown and TransferCashPlayersDropdown.Set then
                TransferCashPlayersDropdown:Set({ lbl })
            end
        end
    end

    local transferCashInitialOpts = transferCashDropdownOptions()
    local transferCashInitialCurrent = {}
    if #transferCashInitialOpts > 0 then
        transferCashInitialCurrent = { transferCashInitialOpts[1] }
        transferCashSelectedPlayer = transferCashFindPlayerByLabel(transferCashInitialOpts[1])
    end

    TransferCashPlayersDropdown = MainTab:CreateDropdown({
        Name = "Player",
        Flag = "yahayuk_main_transfer_cash_player",
        Options = transferCashInitialOpts,
        CurrentOption = transferCashInitialCurrent,
        Search = true,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            transferCashSelectedPlayer = picked and transferCashFindPlayerByLabel(picked) or nil
        end,
    })

    MainTab:CreateInput({
        Name = "Amount",
        Flag = "yahayuk_main_transfer_cash_amount",
        PlaceholderText = "e.g. 100",
        CurrentValue = "",
        Callback = function(value)
            transferCashAmountText = value or ""
        end,
    })

    MainTab:CreateButton({
        Name = "Give Cash",
        Flag = "yahayuk_main_transfer_cash_give",
        Callback = function()
            if not transferCashSelectedPlayer then
                mountNotify({ Title = "Transfer Cash", Content = "Select a player first", Icon = "x" })
                return
            end
            local amtStr = (transferCashAmountText or ""):gsub(",", ""):gsub("%s+", "")
            local amountNum = tonumber(amtStr)
            local amountPayload
            if amountNum ~= nil then
                amountPayload = amountNum
            else
                amountPayload = amtStr
            end
            local targetId = transferCashSelectedPlayer.UserId
            local okFire, errFire = pcall(function()
                local tax = ReplicatedStorage:FindFirstChild("CashTransferTax")
                if not tax then
                    tax = ReplicatedStorage:WaitForChild("CashTransferTax", 5)
                end
                if tax then
                    if tax:IsA("IntValue") or tax:IsA("NumberValue") then
                        tax.Value = 0
                    elseif tax:IsA("StringValue") then
                        tax.Value = "0"
                    end
                end
                local ev = ReplicatedStorage:FindFirstChild("CashTransferRemote")
                if not ev then
                    ev = ReplicatedStorage:WaitForChild("CashTransferRemote", 10)
                end
                if not ev then
                    error("CashTransferRemote not found in ReplicatedStorage")
                end
                ev:FireServer("RequestTransfer", {
                    targetId = targetId,
                    amount = amountPayload,
                })
            end)
            if not okFire then
                mountNotify({
                    Title = "Transfer Cash",
                    Content = tostring(errFire),
                    Icon = "x",
                })
            end
        end,
    })

    task.defer(function()
        local ok, ackRemote = pcall(function()
            return ReplicatedStorage:WaitForChild("CashTransferAck", 60)
        end)
        if not ok or not ackRemote or not ackRemote:IsA("RemoteEvent") then
            return
        end
        ackRemote.OnClientEvent:Connect(function(data)
            local msg: string?
            local okFlag: boolean?
            if type(data) == "table" then
                local m = data.message
                msg = typeof(m) == "string" and m or nil
                okFlag = data.ok
            elseif type(data) == "string" then
                msg = data
                okFlag = true
            else
                return
            end
            if not msg or msg == "" then
                msg = okFlag == false and "Transfer failed." or "Transfer acknowledged."
            end
            mountNotify({
                Title = "Transfer Cash",
                Content = msg,
                Icon = okFlag == false and "x" or "check",
            })
        end)
    end)

    Players.PlayerAdded:Connect(function()
        task.defer(transferCashRefreshList)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(transferCashRefreshList)
    end)
    task.defer(transferCashRefreshList)

    MainTab:CreateSection("Teleport to camp")

    local function teleportToCampCoords(x, y, z, placeName)
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            mountNotify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
            return
        end
        rootPart.CFrame = CFrame.new(x, y, z)
        mountNotify({
            Title = "Teleport",
            Content = "Teleported to " .. placeName,
            Icon = "check",
        })
    end

    for _, wp in ipairs(summitRoute) do
        local label = wp.name
        local telePos = parseSummitTeleportPositionString(wp.teleportPosition)
        if not label or not telePos then
            continue
        end
        local campSlug = string.gsub(label, "%s+", "_")
        local campFlag = "yahayuk_main_teleport_" .. string.lower(campSlug)
        MainTab:CreateButton({
            Name = label,
            Flag = campFlag,
            Callback = function()
                teleportToCampCoords(telePos.X, telePos.Y, telePos.Z, label)
            end,
        })
    end
end

-- */  Map Tab  /* --
do
    local MapTab = Window:CreateTab("Map", "map")
    local LightingService = game:GetService("Lighting")
    local Terrain = Workspace:FindFirstChildOfClass("Terrain")

    MapTab:CreateSection("Map / Performance")

    local MAP_PERF_DESC_BATCH = 400
    local MAP_PERF_SYNC_DESCENDANT_MAX = 800
    local mapPerfJobGeneration = 0

    local function bumpMapPerfJobGeneration(): number
        mapPerfJobGeneration += 1
        return mapPerfJobGeneration
    end

    local fpsBoostEnabled = false
    local fpsBoostPartMaterialsEnabled = false
    local fpsBoostState = {
        cachedEffects = {} :: { [Instance]: boolean },
        cachedVfx = {} :: { [Instance]: boolean },
        cachedPartProps = {} :: { [BasePart]: { Material: Enum.Material, CastShadow: boolean, Reflectance: number } },
        lighting = nil :: { GlobalShadows: boolean }?,
        terrainDecoration = nil :: boolean?,
    }

    local function safeSet(instance: any, propertyName: string, value: any)
        pcall(function()
            instance[propertyName] = value
        end)
    end

    local function applyFpsBoostLightingTerrainPosts()
        if not fpsBoostState.lighting then
            local okLightRead, lightData = pcall(function()
                return {
                    GlobalShadows = LightingService.GlobalShadows,
                }
            end)
            if okLightRead and type(lightData) == "table" then
                fpsBoostState.lighting = lightData
            end
        end
        safeSet(LightingService, "GlobalShadows", false)

        if Terrain then
            if fpsBoostState.terrainDecoration == nil then
                local okDecoration, decoration = pcall(function()
                    return Terrain.Decoration
                end)
                if okDecoration then
                    fpsBoostState.terrainDecoration = decoration
                end
            end
            safeSet(Terrain, "Decoration", false)
        end

        for _, effect in ipairs(LightingService:GetChildren()) do
            if effect:IsA("PostEffect") then
                if fpsBoostState.cachedEffects[effect] == nil then
                    local okEnabled, enabledValue = pcall(function()
                        return effect.Enabled
                    end)
                    if okEnabled then
                        fpsBoostState.cachedEffects[effect] = enabledValue
                    end
                end
                safeSet(effect, "Enabled", false)
            end
        end
    end

    local function applyFpsBoostWorkspaceInst(inst: Instance)
        if inst:IsA("ParticleEmitter")
            or inst:IsA("Trail")
            or inst:IsA("Smoke")
            or inst:IsA("Fire")
            or inst:IsA("Sparkles")
        then
            if fpsBoostState.cachedVfx[inst] == nil then
                local okEnabled, enabledValue = pcall(function()
                    return (inst :: any).Enabled
                end)
                if okEnabled then
                    fpsBoostState.cachedVfx[inst] = enabledValue
                end
            end
            safeSet(inst, "Enabled", false)
        elseif fpsBoostPartMaterialsEnabled and inst:IsA("BasePart") then
            if fpsBoostState.cachedPartProps[inst] == nil then
                local okPartRead, partData = pcall(function()
                    return {
                        Material = inst.Material,
                        CastShadow = inst.CastShadow,
                        Reflectance = inst.Reflectance,
                    }
                end)
                if okPartRead and type(partData) == "table" then
                    fpsBoostState.cachedPartProps[inst] = partData
                end
            end
            safeSet(inst, "Material", Enum.Material.SmoothPlastic)
            safeSet(inst, "CastShadow", false)
            safeSet(inst, "Reflectance", 0)
        end
    end

    local function applyFpsBoostWorkspaceDescendants(descendants: { Instance }, jobGen: number, onDone: (() -> ())?)
        for i = 1, #descendants do
            if jobGen ~= mapPerfJobGeneration or not fpsBoostEnabled then
                return
            end
            applyFpsBoostWorkspaceInst(descendants[i])
            if i % MAP_PERF_DESC_BATCH == 0 then
                RunService.Heartbeat:Wait()
            end
        end
        if jobGen == mapPerfJobGeneration and fpsBoostEnabled and onDone then
            onDone()
        end
    end

    local function applyFpsBoost(onDone: (() -> ())?)
        local jobGen = bumpMapPerfJobGeneration()
        applyFpsBoostLightingTerrainPosts()
        local descendants = Workspace:GetDescendants()
        if #descendants <= MAP_PERF_SYNC_DESCENDANT_MAX then
            applyFpsBoostWorkspaceDescendants(descendants, jobGen, onDone)
            return
        end
        task.spawn(function()
            applyFpsBoostWorkspaceDescendants(descendants, jobGen, onDone)
        end)
    end

    local function restoreFpsBoostWorkspaceCaches(jobGen: number, onDone: (() -> ())?)
        local vfxList = {}
        for inst, wasEnabled in pairs(fpsBoostState.cachedVfx) do
            table.insert(vfxList, { inst, wasEnabled })
        end
        local partList = {}
        for part, props in pairs(fpsBoostState.cachedPartProps) do
            table.insert(partList, { part, props })
        end

        local i = 1
        while i <= #vfxList do
            if jobGen ~= mapPerfJobGeneration then
                return
            end
            local n = math.min(i + MAP_PERF_DESC_BATCH - 1, #vfxList)
            for j = i, n do
                local row = vfxList[j]
                local inst = row[1] :: Instance
                local wasEnabled = row[2] :: boolean
                if inst and inst.Parent then
                    safeSet(inst, "Enabled", wasEnabled)
                end
            end
            i = n + 1
            if i <= #vfxList then
                RunService.Heartbeat:Wait()
            end
        end

        i = 1
        while i <= #partList do
            if jobGen ~= mapPerfJobGeneration then
                return
            end
            local n = math.min(i + MAP_PERF_DESC_BATCH - 1, #partList)
            for j = i, n do
                local row = partList[j]
                local part = row[1] :: BasePart
                local props = row[2] :: { Material: Enum.Material, CastShadow: boolean, Reflectance: number }
                if part and part.Parent then
                    safeSet(part, "Material", props.Material)
                    safeSet(part, "CastShadow", props.CastShadow)
                    safeSet(part, "Reflectance", props.Reflectance)
                end
            end
            i = n + 1
            if i <= #partList then
                RunService.Heartbeat:Wait()
            end
        end

        if jobGen == mapPerfJobGeneration and onDone then
            fpsBoostState.cachedVfx = {}
            fpsBoostState.cachedPartProps = {}
            onDone()
        end
    end

    local function restoreFpsBoostLightingPostsAndEffects(jobGen: number, onDone: (() -> ())?)
        if jobGen ~= mapPerfJobGeneration then
            return
        end
        if fpsBoostState.lighting then
            safeSet(LightingService, "GlobalShadows", fpsBoostState.lighting.GlobalShadows)
            fpsBoostState.lighting = nil
        end

        if Terrain and fpsBoostState.terrainDecoration ~= nil then
            safeSet(Terrain, "Decoration", fpsBoostState.terrainDecoration)
            fpsBoostState.terrainDecoration = nil
        end

        local effList = {}
        for inst, wasEnabled in pairs(fpsBoostState.cachedEffects) do
            table.insert(effList, { inst, wasEnabled })
        end
        fpsBoostState.cachedEffects = {}
        if #effList <= MAP_PERF_SYNC_DESCENDANT_MAX then
            for _, row in ipairs(effList) do
                local inst = row[1] :: Instance
                local wasEnabled = row[2] :: boolean
                if inst and inst.Parent then
                    safeSet(inst, "Enabled", wasEnabled)
                end
            end
            if jobGen == mapPerfJobGeneration and onDone then
                onDone()
            end
            return
        end
        task.spawn(function()
            local i = 1
            while i <= #effList do
                if jobGen ~= mapPerfJobGeneration then
                    return
                end
                local n = math.min(i + MAP_PERF_DESC_BATCH - 1, #effList)
                for j = i, n do
                    local row = effList[j]
                    local inst = row[1] :: Instance
                    local wasEnabled = row[2] :: boolean
                    if inst and inst.Parent then
                        safeSet(inst, "Enabled", wasEnabled)
                    end
                end
                i = n + 1
                if i <= #effList then
                    RunService.Heartbeat:Wait()
                end
            end
            if jobGen == mapPerfJobGeneration and onDone then
                onDone()
            end
        end)
    end

    local function restoreFpsBoost(onDone: (() -> ())?)
        local jobGen = bumpMapPerfJobGeneration()
        restoreFpsBoostLightingPostsAndEffects(jobGen, function()
            if jobGen ~= mapPerfJobGeneration then
                return
            end
            local vfxCount = 0
            for _ in pairs(fpsBoostState.cachedVfx) do
                vfxCount += 1
            end
            local partCount = 0
            for _ in pairs(fpsBoostState.cachedPartProps) do
                partCount += 1
            end
            if vfxCount + partCount == 0 then
                if onDone then
                    onDone()
                end
                return
            end
            if vfxCount + partCount <= MAP_PERF_SYNC_DESCENDANT_MAX then
                restoreFpsBoostWorkspaceCaches(jobGen, onDone)
                return
            end
            task.spawn(function()
                restoreFpsBoostWorkspaceCaches(jobGen, onDone)
            end)
        end)
    end

    local function applyFpsBoostPartsOnly(onDone: (() -> ())?)
        if not fpsBoostEnabled or not fpsBoostPartMaterialsEnabled then
            if onDone then
                onDone()
            end
            return
        end
        local jobGen = bumpMapPerfJobGeneration()
        local descendants = Workspace:GetDescendants()
        local function runList(list: { Instance })
            for i = 1, #list do
                if jobGen ~= mapPerfJobGeneration or not fpsBoostEnabled or not fpsBoostPartMaterialsEnabled then
                    return
                end
                local inst = list[i]
                if inst:IsA("BasePart") then
                    if fpsBoostState.cachedPartProps[inst] == nil then
                        local okPartRead, partData = pcall(function()
                            return {
                                Material = inst.Material,
                                CastShadow = inst.CastShadow,
                                Reflectance = inst.Reflectance,
                            }
                        end)
                        if okPartRead and type(partData) == "table" then
                            fpsBoostState.cachedPartProps[inst] = partData
                        end
                    end
                    safeSet(inst, "Material", Enum.Material.SmoothPlastic)
                    safeSet(inst, "CastShadow", false)
                    safeSet(inst, "Reflectance", 0)
                end
                if i % MAP_PERF_DESC_BATCH == 0 then
                    RunService.Heartbeat:Wait()
                end
            end
            if jobGen == mapPerfJobGeneration and fpsBoostEnabled and onDone then
                onDone()
            end
        end
        if #descendants <= MAP_PERF_SYNC_DESCENDANT_MAX then
            runList(descendants)
            return
        end
        task.spawn(function()
            runList(descendants)
        end)
    end

    local function restoreFpsBoostPartsOnly(onDone: (() -> ())?)
        local jobGen = bumpMapPerfJobGeneration()
        local partList = {}
        for part, props in pairs(fpsBoostState.cachedPartProps) do
            table.insert(partList, { part, props })
        end
        if #partList == 0 then
            if onDone then
                onDone()
            end
            return
        end
        local function runRestore()
            local i = 1
            while i <= #partList do
                if jobGen ~= mapPerfJobGeneration then
                    return
                end
                local n = math.min(i + MAP_PERF_DESC_BATCH - 1, #partList)
                for j = i, n do
                    local row = partList[j]
                    local part = row[1] :: BasePart
                    local props = row[2] :: { Material: Enum.Material, CastShadow: boolean, Reflectance: number }
                    if part and part.Parent then
                        safeSet(part, "Material", props.Material)
                        safeSet(part, "CastShadow", props.CastShadow)
                        safeSet(part, "Reflectance", props.Reflectance)
                    end
                end
                i = n + 1
                if i <= #partList then
                    RunService.Heartbeat:Wait()
                end
            end
            if jobGen == mapPerfJobGeneration and onDone then
                for _, row in ipairs(partList) do
                    fpsBoostState.cachedPartProps[row[1] :: BasePart] = nil
                end
                onDone()
            end
        end
        if #partList <= MAP_PERF_SYNC_DESCENDANT_MAX then
            runRestore()
            return
        end
        task.spawn(function()
            runRestore()
        end)
    end

    MapTab:CreateToggle({
        Name = "Boost FPS",
        Flag = "yahayuk_map_boost_fps",
        CurrentValue = false,
        Callback = function(value)
            local enabled = value == true or (type(value) == "table" and value[1] == true)
            if enabled == fpsBoostEnabled then
                return
            end
            local ok, err = pcall(function()
                if enabled then
                    fpsBoostEnabled = true
                    applyFpsBoost(function()
                        mountNotify({ Title = "Map", Content = "Boost FPS enabled", Icon = "check" })
                    end)
                else
                    fpsBoostEnabled = false
                    restoreFpsBoost(function()
                        mountNotify({ Title = "Map", Content = "Boost FPS disabled (restored)", Icon = "check" })
                    end)
                end
            end)
            if not ok then
                fpsBoostEnabled = false
                bumpMapPerfJobGeneration()
                mountNotify({ Title = "Map", Content = "Boost FPS failed: " .. tostring(err), Icon = "x" })
            end
        end,
    })

    MapTab:CreateToggle({
        Name = "Boost FPS: part materials (heavy)",
        Flag = "yahayuk_map_boost_fps_materials",
        CurrentValue = false,
        Callback = function(value)
            local enabled = value == true or (type(value) == "table" and value[1] == true)
            if enabled == fpsBoostPartMaterialsEnabled then
                return
            end
            local ok, err = pcall(function()
                fpsBoostPartMaterialsEnabled = enabled
                if not fpsBoostEnabled then
                    mountNotify({
                        Title = "Map",
                        Content = enabled and "Part materials will apply when Boost FPS is on"
                            or "Part materials boost off",
                        Icon = "check",
                    })
                    return
                end
                if enabled then
                    applyFpsBoostPartsOnly(function()
                        mountNotify({
                            Title = "Map",
                            Content = "Part material optimizations applied (SmoothPlastic, no shadows)",
                            Icon = "check",
                        })
                    end)
                else
                    restoreFpsBoostPartsOnly(function()
                        mountNotify({ Title = "Map", Content = "Part materials restored", Icon = "check" })
                    end)
                end
            end)
            if not ok then
                fpsBoostPartMaterialsEnabled = not enabled
                mountNotify({ Title = "Map", Content = "Part materials toggle failed: " .. tostring(err), Icon = "x" })
            end
        end,
    })

    local mapVfxHideEnabled = false
    local mapVfxState = {
        enabledByInstance = {} :: { [Instance]: boolean },
    }
    local ensureMapWatchers: () -> ()
    local MAP_VFX_HIDE_CLASS_SET = {
        ParticleEmitter = true,
        Trail = true,
        Beam = true,
        Smoke = true,
        Fire = true,
        Sparkles = true,
        PointLight = true,
        SpotLight = true,
        SurfaceLight = true,
    }
    local mapWatcherDescAddedConn: RBXScriptConnection? = nil
    local mapWatcherCharacterAddedConn: RBXScriptConnection? = nil
    local mapDescendantFlushConn: RBXScriptConnection? = nil
    local mapDescendantPending = {} :: { Instance }
    local mapDescQHead = 1
    local mapDescQTail = 0
    local MAP_DESC_FLUSH_BUDGET_PER_HEARTBEAT = 320

    local function applyMapSpecificVfxHideToInstance(inst: Instance)
        if MAP_VFX_HIDE_CLASS_SET[inst.ClassName] ~= true then
            return
        end
        local obj: any = inst
        if mapVfxState.enabledByInstance[inst] == nil then
            local okEnabled, enabledValue = pcall(function()
                return obj.Enabled
            end)
            if okEnabled then
                mapVfxState.enabledByInstance[inst] = enabledValue
            end
        end
        safeSet(inst, "Enabled", false)
    end

    local function applyMapBlurEffectsHide()
        for _, effect in ipairs(LightingService:GetChildren()) do
            if effect:IsA("BlurEffect") then
                if mapVfxState.enabledByInstance[effect] == nil then
                    local okEnabled, enabledValue = pcall(function()
                        return effect.Enabled
                    end)
                    if okEnabled then
                        mapVfxState.enabledByInstance[effect] = enabledValue
                    end
                end
                safeSet(effect, "Enabled", false)
            end
        end
    end

    local applyWorkspaceMapHidesCombined: (onDone: (() -> ())?) -> () = function(_onDone: (() -> ())?) end

    local function restoreMapSpecificVfxHide(onDone: (() -> ())?)
        bumpMapPerfJobGeneration()
        local entries = {}
        for inst, wasEnabled in pairs(mapVfxState.enabledByInstance) do
            table.insert(entries, { inst, wasEnabled })
        end
        if #entries == 0 then
            mapVfxState.enabledByInstance = {}
            if onDone then
                onDone()
            end
            return
        end
        local jobGen = mapPerfJobGeneration
        local function runRestoreRows(rows)
            local i = 1
            while i <= #rows do
                if jobGen ~= mapPerfJobGeneration then
                    return
                end
                local n = math.min(i + MAP_PERF_DESC_BATCH - 1, #rows)
                for j = i, n do
                    local row = rows[j]
                    local inst = row[1] :: Instance
                    local wasEnabled = row[2] :: boolean
                    if inst and inst.Parent then
                        safeSet(inst, "Enabled", wasEnabled)
                    end
                    mapVfxState.enabledByInstance[inst] = nil
                end
                i = n + 1
                if i <= #rows then
                    RunService.Heartbeat:Wait()
                end
            end
            if jobGen == mapPerfJobGeneration then
                mapVfxState.enabledByInstance = {}
                if onDone then
                    onDone()
                end
            end
        end
        if #entries <= MAP_PERF_SYNC_DESCENDANT_MAX then
            runRestoreRows(entries)
            return
        end
        task.spawn(function()
            runRestoreRows(entries)
        end)
    end

    MapTab:CreateToggle({
        Name = "Hide Heavy VFX (Map-specific)",
        Flag = "yahayuk_map_hide_heavy_vfx",
        CurrentValue = false,
        Callback = function(value)
            local enabled = value == true or (type(value) == "table" and value[1] == true)
            if enabled == mapVfxHideEnabled then
                return
            end
            local ok, err = pcall(function()
                mapVfxHideEnabled = enabled
                if enabled then
                    ensureMapWatchers()
                    applyWorkspaceMapHidesCombined(function()
                        mountNotify({
                            Title = "Map",
                            Content = "Heavy VFX hidden (particles, beams, trails, lights, blur)",
                            Icon = "check",
                        })
                    end)
                else
                    restoreMapSpecificVfxHide(function()
                        ensureMapWatchers()
                        mountNotify({
                            Title = "Map",
                            Content = "Heavy VFX restored",
                            Icon = "check",
                        })
                    end)
                end
            end)
            if not ok then
                mapVfxHideEnabled = false
                ensureMapWatchers()
                mountNotify({ Title = "Map", Content = "Hide Heavy VFX failed: " .. tostring(err), Icon = "x" })
            end
        end,
    })

    local hideMapDecorEnabled = false
    local hideMapDecorState = {
        originalParentByInstance = {} :: { [Instance]: Instance? },
    }
    local MAP_DECOR_HIDE_EXACT_NAME_SET = {
        ["roadbarrier"] = true,
        ["middle rail"] = true,
        ["bottom rail"] = true,
        ["right side support"] = true,
        ["left side support"] = true,
        ["street batop rail"] = true,
        ["trash"] = true,
        ["trashcan"] = true,
        ["wood"] = true,
        ["effectcp"] = true,
        ["trunk"] = true,
        ["sun"] = true,
        ["mountain"] = true,
        ["jungle tree"] = true,
        ["leaf"] = true,
        ["leafs"] = true,
        ["fire"] = true,
        ["torso"] = true,
        ["main wire"] = true,
        ["extra barbs"] = true,
        ["threedtextboundingbox"] = true,
        ["stand"] = true,
        ["seat"] = true,
        ["clover patch"] = true,
        ["obby stair"] = true,
        ["top rail"] = true,
        ["qqq"] = true,
        ["meshes/a"] = true,
        ["meshpart"] = true,
        ["board"] = true,
        ["updateboardpart"] = true,
        ["updateboardtimer"] = true,
        ["scoreblock"] = true,
        ["lightsource"] = true,
        ["side rail"] = true,
        ["localleaderboard"] = true,
        ["globalleaderboard"] = true,
        ["besttimeleaderboard"] = true,
        ["timeplayedleaderboard"] = true,
        ["waterfall"] = true,
        ["street barrier police sign"] = true,
        ["oak tree"] = true,
        ["dragon"] = true,
        ["barbed wire"] = true,
        ["bonfire"] = true,
        ["clock aura"] = true,
        ["realistic tree"] = true,
        ["tree3"] = true,
        -- ["rightupperarm"] = true,
        -- ["leftupperarm"] = true,
        -- ["rightlowerarm"] = true,
        -- ["righthand"] = true,
        -- ["lefthand"] = true,
        -- ["leftlowerarm"] = true,
        -- ["lowertorso"] = true,
        -- ["uppertorso"] = true,
        -- ["rightupperleg"] = true,
        -- ["leftupperleg"] = true,
        -- ["rightlowerleg"] = true,
        -- ["leftlowerleg"] = true,
        -- ["rightfoot"] = true,
        -- ["leftfoot"] = true,
        ["kaimenduzy"] = true,
        ["swingmesh1"] = true,
        ["swingmesh2"] = true,
        ["swingseat1"] = true,
        ["swingseat2"] = true,
        ["ropeshaftroundsmoothbase"] = true,
        ["ropesupport1"] = true,
        ["ropesupport2"] = true,
        ["ropesupport3"] = true,
        ["ropesupport4"] = true,
        ["rope1"] = true,
        ["rope2"] = true,
        ["rope3"] = true,
        ["rope4"] = true,
        ["hook1"] = true,
        ["hook2"] = true,
        ["hook3"] = true,
        ["hook4"] = true,
        ["chaos glow"] = true,
        ["group15585"] = true,
        ["group40649"] = true,
        ["group30024"] = true,
        ["group14682"] = true,
        ["group25145"] = true,
        ["group6034"] = true,
    }
    local MAP_DECOR_HIDE_PREFIX_LIST = {
        "flower",
        "vine",
        "leaves",
        "cherry",
        "cube.071",
        "waterlily",
        "plant",
        "dead",
        "lamp",
        "street light",
        "beechwoodtree",
        "jungletree",
        "donation board",
    }

    local function mapDecorNameShouldHide(name: string): boolean
        local n = string.lower(name or "")
        if MAP_DECOR_HIDE_EXACT_NAME_SET[n] == true then
            return true
        end
        for _, prefix in ipairs(MAP_DECOR_HIDE_PREFIX_LIST) do
            if string.sub(n, 1, #prefix) == prefix then
                return true
            end
        end
        return false
    end

    local function applyMapDecorHideToInstance(inst: Instance)
        if not mapDecorNameShouldHide(inst.Name) then
            return
        end
        if hideMapDecorState.originalParentByInstance[inst] == nil then
            hideMapDecorState.originalParentByInstance[inst] = inst.Parent
        end
        pcall(function()
            inst.Parent = nil
        end)
    end

    applyWorkspaceMapHidesCombined = function(onDone: (() -> ())?)
        if not mapVfxHideEnabled and not hideMapDecorEnabled then
            if onDone then
                onDone()
            end
            return
        end
        local jobGen = bumpMapPerfJobGeneration()
        local descendants = Workspace:GetDescendants()
        local function finishWorkspaceMapHides()
            if jobGen ~= mapPerfJobGeneration then
                return
            end
            if mapVfxHideEnabled then
                applyMapBlurEffectsHide()
            end
            if onDone then
                onDone()
            end
        end
        if #descendants <= MAP_PERF_SYNC_DESCENDANT_MAX then
            for _, inst in ipairs(descendants) do
                if not mapVfxHideEnabled and not hideMapDecorEnabled then
                    break
                end
                if mapVfxHideEnabled then
                    applyMapSpecificVfxHideToInstance(inst)
                end
                if hideMapDecorEnabled then
                    applyMapDecorHideToInstance(inst)
                end
            end
            finishWorkspaceMapHides()
            return
        end
        task.spawn(function()
            for i = 1, #descendants do
                if jobGen ~= mapPerfJobGeneration then
                    return
                end
                if not mapVfxHideEnabled and not hideMapDecorEnabled then
                    break
                end
                local inst = descendants[i]
                if mapVfxHideEnabled then
                    applyMapSpecificVfxHideToInstance(inst)
                end
                if hideMapDecorEnabled then
                    applyMapDecorHideToInstance(inst)
                end
                if i % MAP_PERF_DESC_BATCH == 0 then
                    RunService.Heartbeat:Wait()
                end
            end
            finishWorkspaceMapHides()
        end)
    end

    local function restoreMapDecorHide(onDone: (() -> ())?)
        bumpMapPerfJobGeneration()
        local entries = {}
        for inst, originalParent in pairs(hideMapDecorState.originalParentByInstance) do
            table.insert(entries, { inst, originalParent })
        end
        if #entries == 0 then
            hideMapDecorState.originalParentByInstance = {}
            if onDone then
                onDone()
            end
            return
        end
        local jobGen = mapPerfJobGeneration
        local function runDecorRestore(rows)
            local i = 1
            while i <= #rows do
                if jobGen ~= mapPerfJobGeneration then
                    return
                end
                local n = math.min(i + MAP_PERF_DESC_BATCH - 1, #rows)
                for j = i, n do
                    local row = rows[j]
                    local inst = row[1] :: Instance
                    local originalParent = row[2] :: Instance?
                    if inst and originalParent then
                        pcall(function()
                            inst.Parent = originalParent
                        end)
                    end
                    hideMapDecorState.originalParentByInstance[inst] = nil
                end
                i = n + 1
                if i <= #rows then
                    RunService.Heartbeat:Wait()
                end
            end
            if jobGen == mapPerfJobGeneration then
                hideMapDecorState.originalParentByInstance = {}
                if onDone then
                    onDone()
                end
            end
        end
        if #entries <= MAP_PERF_SYNC_DESCENDANT_MAX then
            runDecorRestore(entries)
            return
        end
        task.spawn(function()
            runDecorRestore(entries)
        end)
    end

    local function mapWatcherNeeded(): boolean
        return mapVfxHideEnabled or hideMapDecorEnabled
    end

    local function ensureMapDescendantFlushLoop()
        if mapDescendantFlushConn then
            return
        end
        mapDescendantFlushConn = RunService.Heartbeat:Connect(function()
            if not mapWatcherNeeded() then
                if mapDescendantFlushConn then
                    mapDescendantFlushConn:Disconnect()
                    mapDescendantFlushConn = nil
                end
                mapDescQHead = 1
                mapDescQTail = 0
                mapDescendantPending = {}
                return
            end
            local budget = 0
            while budget < MAP_DESC_FLUSH_BUDGET_PER_HEARTBEAT and mapDescQHead <= mapDescQTail do
                local inst = mapDescendantPending[mapDescQHead]
                mapDescendantPending[mapDescQHead] = nil
                mapDescQHead += 1
                if inst and inst.Parent then
                    if mapVfxHideEnabled then
                        applyMapSpecificVfxHideToInstance(inst)
                    end
                    if hideMapDecorEnabled then
                        applyMapDecorHideToInstance(inst)
                    end
                end
                budget += 1
            end
            if mapDescQHead > mapDescQTail then
                mapDescQHead = 1
                mapDescQTail = 0
            end
        end)
    end

    local function enqueueMapDescendantForHide(inst: Instance)
        mapDescQTail += 1
        mapDescendantPending[mapDescQTail] = inst
        ensureMapDescendantFlushLoop()
    end

    local function stopMapWatchers()
        if mapWatcherDescAddedConn then
            mapWatcherDescAddedConn:Disconnect()
            mapWatcherDescAddedConn = nil
        end
        if mapWatcherCharacterAddedConn then
            mapWatcherCharacterAddedConn:Disconnect()
            mapWatcherCharacterAddedConn = nil
        end
        if mapDescendantFlushConn then
            mapDescendantFlushConn:Disconnect()
            mapDescendantFlushConn = nil
        end
        mapDescQHead = 1
        mapDescQTail = 0
        mapDescendantPending = {}
    end

    local function reapplyActiveMapHides()
        applyWorkspaceMapHidesCombined(nil)
    end

    function ensureMapWatchers()
        if not mapWatcherNeeded() then
            stopMapWatchers()
            return
        end
        if not mapWatcherDescAddedConn then
            mapWatcherDescAddedConn = Workspace.DescendantAdded:Connect(function(inst)
                enqueueMapDescendantForHide(inst)
            end)
        end
        ensureMapDescendantFlushLoop()
        if not mapWatcherCharacterAddedConn then
            mapWatcherCharacterAddedConn = Players.LocalPlayer.CharacterAdded:Connect(function()
                task.defer(reapplyActiveMapHides)
            end)
        end
    end

    MapTab:CreateToggle({
        Name = "Hide Map Decor (Road/Flower/Vine/Leaves/Trashcan)",
        Flag = "yahayuk_map_hide_decor",
        CurrentValue = false,
        Callback = function(value)
            local enabled = value == true or (type(value) == "table" and value[1] == true)
            if enabled == hideMapDecorEnabled then
                return
            end
            local ok, err = pcall(function()
                hideMapDecorEnabled = enabled
                if enabled then
                    ensureMapWatchers()
                    applyWorkspaceMapHidesCombined(function()
                        mountNotify({
                            Title = "Map",
                            Content = "Map decor hidden (RoadBarrier, rails, supports, Flower*, Vine*, Leaves*, Trashcan)",
                            Icon = "check",
                        })
                    end)
                else
                    restoreMapDecorHide(function()
                        ensureMapWatchers()
                        mountNotify({
                            Title = "Map",
                            Content = "Map decor restored",
                            Icon = "check",
                        })
                    end)
                end
            end)
            if not ok then
                hideMapDecorEnabled = false
                ensureMapWatchers()
                mountNotify({ Title = "Map", Content = "Hide Map Decor failed: " .. tostring(err), Icon = "x" })
            end
        end,
    })

    MapTab:CreateSection("FPS Analyzer")
    local analyzerParagraph = MapTab:CreateParagraph({
        Title = "Scan Result",
        Content = "Press Scan FPS Analyzer.",
    })

    local function formatAnalyzerSummary(stats)
        local lines = {
            string.format("Workspace descendants: %d", stats.totalDescendants),
            string.format("Parts: %d (MeshParts: %d)", stats.baseParts, stats.meshParts),
            string.format("Textures/Decals: %d", stats.decals + stats.textures),
            string.format("Particles: %d (emitters: %d, trails: %d, beams: %d)", stats.totalParticles, stats.emitters, stats.trails, stats.beams),
            string.format("Lights: %d", stats.lights),
            string.format("Post effects: %d", stats.postEffects),
            string.format("Auras (name match): %d", stats.auras),
        }
        return table.concat(lines, "\n")
    end

    MapTab:CreateButton({
        Name = "Scan FPS Analyzer",
        Flag = "yahayuk_map_fps_analyzer_scan",
        Callback = function()
            local ok, err = pcall(function()
                local jobGen = bumpMapPerfJobGeneration()
                local stats = {
                    totalDescendants = 0,
                    baseParts = 0,
                    meshParts = 0,
                    decals = 0,
                    textures = 0,
                    emitters = 0,
                    trails = 0,
                    beams = 0,
                    smoke = 0,
                    fire = 0,
                    sparkles = 0,
                    totalParticles = 0,
                    lights = 0,
                    postEffects = 0,
                    auras = 0,
                }

                local function tallyInstance(inst: Instance)
                    stats.totalDescendants += 1
                    if inst:IsA("BasePart") then
                        stats.baseParts += 1
                    end
                    if inst:IsA("MeshPart") then
                        stats.meshParts += 1
                    elseif inst:IsA("Decal") then
                        stats.decals += 1
                    elseif inst:IsA("Texture") then
                        stats.textures += 1
                    elseif inst:IsA("ParticleEmitter") then
                        stats.emitters += 1
                    elseif inst:IsA("Trail") then
                        stats.trails += 1
                    elseif inst:IsA("Beam") then
                        stats.beams += 1
                    elseif inst:IsA("Smoke") then
                        stats.smoke += 1
                    elseif inst:IsA("Fire") then
                        stats.fire += 1
                    elseif inst:IsA("Sparkles") then
                        stats.sparkles += 1
                    elseif inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight") then
                        stats.lights += 1
                    end

                    local instName = string.lower(inst.Name or "")
                    if string.find(instName, "aura", 1, true) or string.find(instName, "fx", 1, true) then
                        stats.auras += 1
                    end
                end

                local function finalizeAnalyzerResults()
                    if jobGen ~= mapPerfJobGeneration then
                        return
                    end
                    stats.totalParticles = stats.emitters
                        + stats.trails
                        + stats.beams
                        + stats.smoke
                        + stats.fire
                        + stats.sparkles

                    for _, effect in ipairs(LightingService:GetChildren()) do
                        if effect:IsA("PostEffect") then
                            stats.postEffects += 1
                        end
                    end

                    local summary = formatAnalyzerSummary(stats)
                    if analyzerParagraph and analyzerParagraph.Set then
                        analyzerParagraph:Set({
                            Title = "Scan Result",
                            Content = summary,
                        })
                    end

                    mountNotify({
                        Title = "FPS Analyzer",
                        Content = string.format(
                            "Scan done. Particles=%d, Lights=%d, PostEffects=%d",
                            stats.totalParticles,
                            stats.lights,
                            stats.postEffects
                        ),
                        Icon = "check",
                    })
                end

                local descendants = Workspace:GetDescendants()
                if #descendants <= MAP_PERF_SYNC_DESCENDANT_MAX then
                    for _, inst in ipairs(descendants) do
                        tallyInstance(inst)
                    end
                    finalizeAnalyzerResults()
                    return
                end

                task.spawn(function()
                    local i = 1
                    while i <= #descendants do
                        if jobGen ~= mapPerfJobGeneration then
                            return
                        end
                        local n = math.min(i + MAP_PERF_DESC_BATCH - 1, #descendants)
                        for j = i, n do
                            tallyInstance(descendants[j])
                        end
                        i = n + 1
                        if i <= #descendants then
                            RunService.Heartbeat:Wait()
                        end
                    end
                    finalizeAnalyzerResults()
                end)
            end)
            if not ok then
                mountNotify({ Title = "FPS Analyzer", Content = "Scan failed: " .. tostring(err), Icon = "x" })
            end
        end,
    })
end
-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, {
    ext = true,
    notifyIcons = true,
    playerSearch = true,
    playerNoneOption = true,
    tabIcon = "map-pin",
})

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, {
    replicatedStorage = ReplicatedStorage,
    tabIcon = "boxes",
})


-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, {
    gamePath = "sempatpanick/mount_yahayuk",
    tabIcon = "video",
})

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/mount_yahayuk",
    rayfieldLibrary = SempatLibrary,
    tabIcon = "settings",
})
