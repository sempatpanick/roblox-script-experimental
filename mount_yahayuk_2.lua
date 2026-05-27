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

local RayfieldLibrary

local baseURL = "https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main"

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

-- */  Recording Tab (module)  /* --
local function loadCreateRecordingTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("./tabs/recording_tab")
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

local createRecordingTab = loadCreateRecordingTab(baseURL .. "/tabs/recording_tab.lua")
if not createRecordingTab then
    createRecordingTab = function(_windowRef, notifyFn, _recordingsDir)
        notifyFn({ Title = "Recording", Content = "Failed to load recording tab module", Icon = "x" })
    end
end

-- */  Local Player Tab (module)  /* --
local LOCAL_PLAYER_TAB_REPO = baseURL .. "/tabs/local_player_tab.lua"
local function loadCreateLocalPlayerTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("./tabs/local_player_tab")
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
local OBJECTS_TAB_REPO = baseURL .. "/tabs/objects_tab.lua"
local function loadCreateObjectsTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("./tabs/objects_tab")
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
local TELEPORT_TAB_REPO = baseURL .. "/tabs/teleport_tab.lua"
local function loadCreateTeleportTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("./tabs/teleport_tab")
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
local CONFIG_TAB_REPO = baseURL .. "/tabs/config_tab.lua"
local function loadCreateConfigTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("./tabs/config_tab")
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
    Name = "sempatpanick | Mount Yahayuk",
    ScriptID = "sid_oy28ga5qf82i",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Mount Yahayuk",
    Icon = 4483362458,
    Resizable = true,
    MinSize = Vector2.new(420, 280),
    MaxSize = Vector2.new(1100, 760),
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "sempatpanick",
        FileName = "mount_yahayuk",
    },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
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
})

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", 4483362458)

    local autoSummitEnabled = false
    local autoSummitMainToggle: any = nil
    local autoSummitSkipFinalStoppedNotify = false
    local summitQty = ""
    local autoSummitIncludeFailedRoute = false
    local autoSummitRandomizeTeleportDelay = false
    local autoSummitRestartFromDeath = false
    local autoSummitWalkKeysDown: { [Enum.KeyCode]: boolean } = {}
    local autoSummitWalkPlaybackHumanoid: Humanoid? = nil
    local autoSummitWalkPlaybackAutoRotateRestore: boolean? = nil
    local autoSummitMode = "Walk"
    local AUTO_SUMMIT_MODE_OPTIONS = { "Walk", "Teleport" }
    local updateAutoSummitRouteModeParagraph: () -> ()
    local getCurrentAutoSummitModeHandler: () -> any
    local WALK_BETWEEN_RUN_DELAY_MIN = 0
    local WALK_BETWEEN_RUN_DELAY_MAX = 1

    local MOUNT_ROUTES_DIR = "sempatpanick/mount_yahayuk/routes"
    local MOUNT_ROUTES_INDEX_JSON = MOUNT_ROUTES_DIR .. "/index.json"
    local MOUNT_ROUTES_REMOTE = baseURL .. "/mount_yahayuk/routes/"
    local MOUNT_FALLSPAWNS_JSON = "sempatpanick/mount_yahayuk/fallspawns.json"
    local MOUNT_FALLSPAWNS_REMOTE = baseURL .. "/mount_yahayuk/fallspawns.json"

    local DEFAULT_MOUNT_ROUTE_INDEX_FILES = {
        "index.json",
        "start-cp1_success_1.json",
        "cp1-2_success_1.json",
        "cp1-2_success_2.json",
        "cp2-3_success_1.json",
        "cp3-4_success_1.json",
        "cp4-5_success_1.json",
        "cp5-summit_success_1.json",
    }

    local function resolveExecutorFnForMain(name: string): any
        local v = rawget(_G, name)
        if type(v) == "function" then
            return v
        end
        local getGenvFn = rawget(_G, "getgenv")
        local okGenv, genv = pcall(function()
            return type(getGenvFn) == "function" and getGenvFn() or nil
        end)
        if okGenv and type(genv) == "table" then
            local gv = rawget(genv, name) or genv[name]
            if type(gv) == "function" then
                return gv
            end
        end
        local okFenv, fenv = pcall(function()
            return getfenv and getfenv()
        end)
        if okFenv and type(fenv) == "table" then
            local fv = rawget(fenv, name) or fenv[name]
            if type(fv) == "function" then
                return fv
            end
        end
        return nil
    end

    local function normalizePathMain(path: string): string
        return string.gsub(path or "", "\\", "/")
    end

    local function baseNameFromPathMain(path: string): string
        local normalized = normalizePathMain(path)
        local base = string.match(normalized, "([^/]+)$")
        return base or normalized
    end

    local function isJsonPathMain(path: string): boolean
        return string.sub(string.lower(path), -5) == ".json"
    end

    local mountRouteProbabilitiesByPrefixCache: { [string]: { [string]: number } }? = nil
    local mountRouteProbabilitiesLoadAttempted = false
    local mountFallSpawnRowsCache: { any }? = nil
    local mountFallSpawnRowsLoadAttempted = false

    local function syncMountYahayukRoutesFromRemote()
        local writeFn = resolveExecutorFnForMain("writefile")
        local makeFolderFn = resolveExecutorFnForMain("makefolder")
        local delFn = resolveExecutorFnForMain("delfile")
        local isFileFn = resolveExecutorFnForMain("isfile")
        if type(writeFn) ~= "function" then
            return false, "writefile() not available"
        end
        if type(makeFolderFn) == "function" then
            pcall(function()
                makeFolderFn("sempatpanick")
                makeFolderFn("sempatpanick/mount_yahayuk")
                makeFolderFn(MOUNT_ROUTES_DIR)
            end)
        end
        local indexUrl = MOUNT_ROUTES_REMOTE .. "index.json"
        local okIndex, indexBody = pcall(function()
            return game:HttpGet(indexUrl, true)
        end)
        local fileNames: { string } = {}
        if okIndex and type(indexBody) == "string" and #indexBody > 2 then
            local okDecode, decoded = pcall(function()
                return HttpService:JSONDecode(indexBody)
            end)
            if okDecode and type(decoded) == "table" and type(decoded.files) == "table" then
                fileNames = decoded.files
            end
        end
        if #fileNames == 0 then
            fileNames = DEFAULT_MOUNT_ROUTE_INDEX_FILES
        end
        local hasIndexJson = false
        for _, fname in ipairs(fileNames) do
            if type(fname) == "string" and string.lower(fname) == "index.json" then
                hasIndexJson = true
                break
            end
        end
        if not hasIndexJson then
            table.insert(fileNames, 1, "index.json")
        end
        for _, fname in ipairs(fileNames) do
            if type(fname) == "string" and isJsonPathMain(fname) then
                local fullPath = MOUNT_ROUTES_DIR .. "/" .. fname
                if type(delFn) == "function" then
                    local shouldTryDelete = true
                    if type(isFileFn) == "function" then
                        local okExist, exists = pcall(function()
                            return isFileFn(fullPath)
                        end)
                        shouldTryDelete = okExist and exists == true
                    end
                    if shouldTryDelete then
                        pcall(function()
                            delFn(fullPath)
                        end)
                    end
                end
                local url = MOUNT_ROUTES_REMOTE .. fname
                local okGet, content = pcall(function()
                    return game:HttpGet(url, true)
                end)
                if okGet and type(content) == "string" and #content > 2 then
                    pcall(function()
                        writeFn(fullPath, content)
                    end)
                end
            end
        end
        -- fallspawns.json lives beside routes/; re-fetch same as route files (delete then write).
        do
            local fallPath = MOUNT_FALLSPAWNS_JSON
            if type(delFn) == "function" then
                local shouldTryDeleteFall = true
                if type(isFileFn) == "function" then
                    local okExistFall, existsFall = pcall(function()
                        return isFileFn(fallPath)
                    end)
                    shouldTryDeleteFall = okExistFall and existsFall == true
                end
                if shouldTryDeleteFall then
                    pcall(function()
                        delFn(fallPath)
                    end)
                end
            end
            local okFallGet, fallContent = pcall(function()
                return game:HttpGet(MOUNT_FALLSPAWNS_REMOTE, true)
            end)
            if okFallGet and type(fallContent) == "string" and #fallContent > 2 then
                pcall(function()
                    writeFn(fallPath, fallContent)
                end)
            end
        end
        mountRouteProbabilitiesLoadAttempted = false
        mountRouteProbabilitiesByPrefixCache = nil
        mountFallSpawnRowsLoadAttempted = false
        mountFallSpawnRowsCache = nil
        return true, nil
    end

    task.defer(function()
        pcall(syncMountYahayukRoutesFromRemote)
    end)

    local WalkVirtualInputManager = nil
    pcall(function()
        WalkVirtualInputManager = game:GetService("VirtualInputManager")
    end)
    local walkRouteRng = Random.new()

    local function listRouteJsonPathsInDir(): { string }
        local listFilesFn = resolveExecutorFnForMain("listfiles")
        if type(listFilesFn) ~= "function" then
            return {}
        end
        local ok, filesOrErr = pcall(function()
            return listFilesFn(MOUNT_ROUTES_DIR)
        end)
        if not ok or type(filesOrErr) ~= "table" then
            return {}
        end
        local out: { string } = {}
        for _, item in ipairs(filesOrErr) do
            if type(item) == "string" and isJsonPathMain(item) then
                table.insert(out, item)
            end
        end
        return out
    end

    local function listRouteJsonPathsForLegPrefix(prefix: string): { string }
        local all = listRouteJsonPathsInDir()
        local matches: { string } = {}
        local prefLower = string.lower(prefix .. "_")
        for _, p in ipairs(all) do
            local bn = string.lower(baseNameFromPathMain(p))
            if string.sub(bn, 1, #prefLower) == prefLower then
                table.insert(matches, p)
            end
        end
        table.sort(matches, function(a, b)
            return string.lower(baseNameFromPathMain(a)) < string.lower(baseNameFromPathMain(b))
        end)
        return matches
    end

    local function getMountRouteProbabilitiesByPrefix(readFileFn: any): { [string]: { [string]: number } }
        if mountRouteProbabilitiesLoadAttempted then
            return mountRouteProbabilitiesByPrefixCache or {}
        end
        mountRouteProbabilitiesLoadAttempted = true
        mountRouteProbabilitiesByPrefixCache = {}
        if type(readFileFn) ~= "function" then
            return {}
        end
        local okRead, jsonText = pcall(function()
            return readFileFn(MOUNT_ROUTES_INDEX_JSON)
        end)
        if not okRead or type(jsonText) ~= "string" or #jsonText < 2 then
            return {}
        end
        local okDec, decoded = pcall(function()
            return HttpService:JSONDecode(jsonText)
        end)
        if not okDec or type(decoded) ~= "table" then
            return {}
        end
        local rawByPrefix =
            decoded.routeProbabilitiesByPrefix or decoded.route_weights_by_prefix or decoded.routeWeightsByPrefix
        if type(rawByPrefix) ~= "table" then
            return {}
        end
        local out: { [string]: { [string]: number } } = {}
        for prefixKey, mapAny in pairs(rawByPrefix) do
            if type(prefixKey) == "string" and type(mapAny) == "table" then
                local pfx = string.lower(prefixKey)
                local m: { [string]: number } = {}
                for fileKey, wAny in pairs(mapAny) do
                    local fileName = type(fileKey) == "string" and string.lower(fileKey) or nil
                    local w = tonumber(wAny)
                    if fileName and w and w >= 0 then
                        m[fileName] = w
                    end
                end
                out[pfx] = m
            end
        end
        mountRouteProbabilitiesByPrefixCache = out
        return out
    end

    local function buildWeightedRouteOrder(
        candidates: { string },
        prefix: string,
        routeProbabilitiesByPrefix: { [string]: { [string]: number } }
    ): { string }
        local remaining: { string } = {}
        for i = 1, #candidates do
            remaining[i] = candidates[i]
        end

        local out: { string } = {}
        local pfx = string.lower(prefix or "")
        local pfxWeights = routeProbabilitiesByPrefix[pfx]

        while #remaining > 0 do
            local totalW = 0
            local weights: { number } = {}
            for i, p in ipairs(remaining) do
                local bn = string.lower(baseNameFromPathMain(p))
                local w = 1
                if type(pfxWeights) == "table" and type(pfxWeights[bn]) == "number" then
                    w = math.max(0, pfxWeights[bn])
                end
                weights[i] = w
                totalW = totalW + w
            end

            local pickIdx = 1
            if totalW > 0 then
                local roll = walkRouteRng:NextNumber(0, totalW)
                local acc = 0
                for i = 1, #remaining do
                    acc = acc + weights[i]
                    if roll <= acc then
                        pickIdx = i
                        break
                    end
                end
            else
                pickIdx = walkRouteRng:NextInteger(1, #remaining)
            end

            table.insert(out, remaining[pickIdx])
            table.remove(remaining, pickIdx)
        end

        return out
    end

    local function walkRouteFileIsFailedVariant(path: string): boolean
        local bn = string.lower(baseNameFromPathMain(path))
        return string.find(bn, "_failed_", 1, true) ~= nil
    end

    -- fallspawns.json: campName + position for each camp's FallSpawn / Start SpawnLocation.
    local FALL_SPAWN_MATCH_RADIUS_STUDS = 40

    local function parseFallSpawnRowPosition(row: any): Vector3?
        if type(row) ~= "table" then
            return nil
        end
        local pos = row.position
        if type(pos) ~= "table" then
            return nil
        end
        local x = tonumber(pos.x)
        local y = tonumber(pos.y)
        local z = tonumber(pos.z)
        if not (x and y and z) then
            return nil
        end
        return Vector3.new(x, y, z)
    end

    local function fallSpawnWorldPositionForCamp(rows: { any }, campName: string): Vector3?
        if type(campName) ~= "string" or campName == "" then
            return nil
        end
        for _, row in ipairs(rows) do
            if type(row) == "table" and row.campName == campName then
                return parseFallSpawnRowPosition(row)
            end
        end
        return nil
    end

    local function rootPartNearWorldPosition(rootPart: BasePart, worldPos: Vector3, radius: number): boolean
        return (rootPart.Position - worldPos).Magnitude <= radius
    end

    local function getMountFallSpawnRows(readFileFn: any): { any }
        if mountFallSpawnRowsLoadAttempted then
            return mountFallSpawnRowsCache or {}
        end
        mountFallSpawnRowsLoadAttempted = true
        mountFallSpawnRowsCache = {}
        if type(readFileFn) ~= "function" then
            return {}
        end
        local okRead, jsonText = pcall(function()
            return readFileFn(MOUNT_FALLSPAWNS_JSON)
        end)
        if not okRead or type(jsonText) ~= "string" or #jsonText < 2 then
            return {}
        end
        local okDec, decoded = pcall(function()
            return HttpService:JSONDecode(jsonText)
        end)
        if not okDec or type(decoded) ~= "table" then
            return {}
        end
        local list = decoded.fallSpawns or decoded.fallspawns
        if type(list) ~= "table" then
            return {}
        end
        mountFallSpawnRowsCache = list
        return list
    end

    local function findFirstMovementWorldPosition(events: { any }): Vector3?
        for _, ev in ipairs(events) do
            if type(ev) == "table" and ev.kind == "movement" and type(ev.data) == "table" then
                local pos = ev.data.position
                if type(pos) == "table" then
                    local x, y, z = tonumber(pos.x), tonumber(pos.y), tonumber(pos.z)
                    if x and y and z then
                        return Vector3.new(x, y, z)
                    end
                end
            end
        end
        return nil
    end

    local function getCharacterHumanoidAndRootWalk(character: Model?): (Humanoid?, BasePart?)
        if not character then
            return nil, nil
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        return humanoid, rootPart
    end

    local function getCharacterRootToFeetHeightWalk(character: Model?): number?
        local humanoid, rootPart = getCharacterHumanoidAndRootWalk(character)
        if not humanoid or not rootPart then
            return nil
        end
        return (rootPart.Size.Y * 0.5) + humanoid.HipHeight
    end

    local function extractRecordedRootToFeetHeightWalk(payload: { [string]: any }?, events: { any }?): number?
        if type(payload) == "table" and type(payload.meta) == "table" and type(payload.meta.avatarProfile) == "table" then
            local h = tonumber(payload.meta.avatarProfile.rootToFeetHeight)
            if h then
                return h
            end
        end
        if type(events) == "table" then
            for _, ev in ipairs(events) do
                if type(ev) == "table" and ev.kind == "recording_started" and type(ev.data) == "table" then
                    local ap = ev.data.avatarProfile
                    if type(ap) == "table" then
                        local h = tonumber(ap.rootToFeetHeight)
                        if h then
                            return h
                        end
                    end
                end
            end
        end
        return nil
    end

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
            walkLegPrefix = "start-cp1",
            walkWithJump = false,
        },
        {
            name = "Camp 1",
            teleportPosition = "-407.77, 248.20, 794.09",
            teleportDelay = 5,
            teleportDelayRandomMin = 0,
            teleportDelayRandomMax = 5,
            teleportWalkTo = nil,
            teleportWalkToRadius = nil,
            teleportWalkToWithJump = false,
            walkLegPrefix = "cp1-2",
            walkWithJump = false,
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
            walkLegPrefix = "cp2-3",
            walkWithJump = false,
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
            walkLegPrefix = "cp3-4",
            walkWithJump = false,
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
            walkLegPrefix = "cp4-5",
            walkWithJump = false,
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
            walkLegPrefix = "cp5-summit",
            walkWithJump = false,
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
            walkLegPrefix = "summit-start",
            walkWithJump = true,
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

    local function campNameForWalkRouteStep(routeStepIndex: number): string?
        local wp = summitRoute[routeStepIndex]
        if not wp then
            return nil
        end
        if wp.name == "Summit" then
            return nil
        end
        return wp.name
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
        Name = "Refresh Routes (mode Walk)",
        Flag = "yahayuk_main_refresh_routes",
        Callback = function()
            task.spawn(function()
                notifyAutoSummit("Refreshing walk routes from remote...")
                local okSync, syncErr = syncMountYahayukRoutesFromRemote()
                if okSync then
                    notifyAutoSummit("Routes and fallspawns.json refreshed (delete + re-fetch + write)")
                else
                    notifyAutoSummit("Failed to refresh routes: " .. tostring(syncErr), "x")
                end
            end)
        end,
    })

    local lpAutoSummit = Players.LocalPlayer

    local function releaseAutoSummitWalkVirtualKeys()
        if WalkVirtualInputManager then
            for keyCode, isDown in pairs(autoSummitWalkKeysDown) do
                if isDown then
                    pcall(function()
                        WalkVirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                    end)
                end
                autoSummitWalkKeysDown[keyCode] = nil
            end
        else
            for k in pairs(autoSummitWalkKeysDown) do
                autoSummitWalkKeysDown[k] = nil
            end
        end
    end

    local function stopAutoSummitWalkCharacter()
        releaseAutoSummitWalkVirtualKeys()

        local char = lpAutoSummit.Character
        local humToStop = autoSummitWalkPlaybackHumanoid
        if not humToStop and char then
            humToStop = char:FindFirstChildOfClass("Humanoid")
        end
        if humToStop then
            pcall(function()
                humToStop:Move(Vector3.new(0, 0, 0))
            end)
        end

        local localRoot = char and char:FindFirstChild("HumanoidRootPart")
        if localRoot then
            pcall(function()
                localRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                localRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end)
        end

        if autoSummitWalkPlaybackHumanoid and autoSummitWalkPlaybackAutoRotateRestore ~= nil then
            pcall(function()
                autoSummitWalkPlaybackHumanoid.AutoRotate = autoSummitWalkPlaybackAutoRotateRestore
            end)
        end
        autoSummitWalkPlaybackHumanoid = nil
        autoSummitWalkPlaybackAutoRotateRestore = nil
    end

    local AutoSummitModeDropdown
    AutoSummitModeDropdown = MainTab:CreateDropdown({
        Name = "Mode",
        Flag = "yahayuk_main_auto_summit_mode",
        Options = AUTO_SUMMIT_MODE_OPTIONS,
        CurrentOption = { autoSummitMode },
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            if type(AutoSummitModeDropdown) == "table" and type(AutoSummitModeDropdown.CurrentOption) == "table" then
                local fromUi = rayfieldDropdownFirst(AutoSummitModeDropdown.CurrentOption)
                if fromUi and table.find(AUTO_SUMMIT_MODE_OPTIONS, fromUi) then
                    picked = fromUi
                end
            end
            if picked and table.find(AUTO_SUMMIT_MODE_OPTIONS, picked) and picked ~= autoSummitMode then
                local previousMode = autoSummitMode
                autoSummitMode = picked
                if autoSummitEnabled then
                    if previousMode == "Walk" or picked == "Walk" then
                        stopAutoSummitWalkCharacter()
                    end
                    notifyAutoSummit("Mode switched to " .. picked)
                end
                updateAutoSummitRouteModeParagraph()
            end
        end,
    })

    -- Periodic jumps during MoveTo + recording playback when summitRoute[*].walkWithJump is true.
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

    local function playRouteRecordingEvents(
        events: { any },
        payload: { [string]: any }?,
        shouldCancel: () -> boolean
    ): boolean
        local movementTrack: { any } = {}
        for _, ev in ipairs(events) do
            if ev.kind == "movement" then
                table.insert(movementTrack, ev)
            end
        end

        local recordedRootToFeet = extractRecordedRootToFeetHeightWalk(payload, events)
        local currentRootToFeet = getCharacterRootToFeetHeightWalk(lpAutoSummit.Character)
        local playbackAvatarYOffset = 0
        if recordedRootToFeet and currentRootToFeet then
            playbackAvatarYOffset = currentRootToFeet - recordedRootToFeet
        end

        local function buildMovementTargetCFrame(rootPart: BasePart?, dataTable: { [string]: any }): CFrame?
            local pos = dataTable.position
            if not rootPart or type(pos) ~= "table" then
                return nil
            end
            local x = tonumber(pos.x)
            local y = tonumber(pos.y)
            local z = tonumber(pos.z)
            if not (x and y and z) then
                return nil
            end
            local basePos = Vector3.new(x, y, z)
            if playbackAvatarYOffset ~= 0 then
                basePos = basePos + Vector3.new(0, playbackAvatarYOffset, 0)
            end
            local lookData = dataTable.lookDirection
            local lx, ly, lz = nil, nil, nil
            if type(lookData) == "table" then
                lx = tonumber(lookData.x)
                ly = tonumber(lookData.y)
                lz = tonumber(lookData.z)
            end
            if lx and ly and lz then
                local lookVec = Vector3.new(lx, ly, lz)
                if lookVec.Magnitude > 1e-4 then
                    local planar = Vector3.new(lookVec.X, 0, lookVec.Z)
                    if planar.Magnitude > 1e-4 then
                        return CFrame.lookAt(basePos, basePos + planar.Unit)
                    end
                end
            end
            local fallback = rootPart.CFrame.LookVector
            local fallbackPlanar = Vector3.new(fallback.X, 0, fallback.Z)
            if fallbackPlanar.Magnitude > 1e-4 then
                return CFrame.lookAt(basePos, basePos + fallbackPlanar.Unit)
            end
            return CFrame.new(basePos)
        end

        local function findMovementSegmentIndex(track: { any }, elapsed: number): number?
            if #track == 0 then
                return nil
            end
            local idx = 1
            while idx < #track do
                local nextT = tonumber(track[idx + 1].t) or 0
                if nextT > elapsed then
                    break
                end
                idx = idx + 1
            end
            return idx
        end

        local movementConnection: RBXScriptConnection? = nil
        local movementBlendInDuration = 0.12
        local movementBlendStartCFrame: CFrame? = nil
        local function cleanupPlaybackState()
            if movementConnection then
                pcall(function()
                    movementConnection:Disconnect()
                end)
                movementConnection = nil
            end
            if autoSummitWalkPlaybackHumanoid and autoSummitWalkPlaybackAutoRotateRestore ~= nil then
                pcall(function()
                    autoSummitWalkPlaybackHumanoid.AutoRotate = autoSummitWalkPlaybackAutoRotateRestore
                end)
            end
            autoSummitWalkPlaybackHumanoid = nil
            autoSummitWalkPlaybackAutoRotateRestore = nil
            releaseAutoSummitWalkVirtualKeys()
        end

        local started = os.clock()
        if #movementTrack > 0 then
            movementConnection = RunService.RenderStepped:Connect(function()
                if shouldCancel() then
                    return
                end
                local elapsed = os.clock() - started
                local character = lpAutoSummit.Character
                local humanoid, rootPart = getCharacterHumanoidAndRootWalk(character)
                if not rootPart then
                    return
                end

                if humanoid and autoSummitWalkPlaybackHumanoid ~= humanoid then
                    if autoSummitWalkPlaybackHumanoid and autoSummitWalkPlaybackAutoRotateRestore ~= nil then
                        pcall(function()
                            autoSummitWalkPlaybackHumanoid.AutoRotate = autoSummitWalkPlaybackAutoRotateRestore
                        end)
                    end
                    autoSummitWalkPlaybackHumanoid = humanoid
                    autoSummitWalkPlaybackAutoRotateRestore = humanoid.AutoRotate
                    pcall(function()
                        humanoid.AutoRotate = false
                    end)
                end

                local segIdx = findMovementSegmentIndex(movementTrack, elapsed)
                if not segIdx then
                    return
                end

                local evA = movementTrack[segIdx]
                local evB = movementTrack[math.min(segIdx + 1, #movementTrack)]
                local tA = tonumber(evA.t) or 0
                local tB = tonumber(evB.t) or tA
                local dataA = type(evA.data) == "table" and evA.data or {}
                local dataB = type(evB.data) == "table" and evB.data or {}
                local cfA = buildMovementTargetCFrame(rootPart, dataA)
                local cfB = buildMovementTargetCFrame(rootPart, dataB)
                if not (cfA and cfB) then
                    return
                end

                local alpha = 1
                if evB ~= evA and tB > tA then
                    alpha = math.clamp((elapsed - tA) / (tB - tA), 0, 1)
                elseif elapsed < tA then
                    alpha = 0
                end

                local playbackTargetCf = cfA:Lerp(cfB, alpha)
                if not movementBlendStartCFrame then
                    movementBlendStartCFrame = rootPart.CFrame
                end
                local finalCf = playbackTargetCf
                if elapsed < movementBlendInDuration and movementBlendStartCFrame then
                    local blendAlpha = math.clamp(elapsed / movementBlendInDuration, 0, 1)
                    finalCf = movementBlendStartCFrame:Lerp(playbackTargetCf, blendAlpha)
                end

                pcall(function()
                    rootPart.CFrame = finalCf
                end)

                if elapsed >= movementBlendInDuration then
                    local vel = dataA.velocity
                    if type(vel) == "table" then
                        local vx, vy, vz = tonumber(vel.x), tonumber(vel.y), tonumber(vel.z)
                        if vx and vy and vz then
                            pcall(function()
                                rootPart.AssemblyLinearVelocity = Vector3.new(vx, vy, vz)
                            end)
                        end
                    end
                end
            end)
        end

        for i, event in ipairs(events) do
            if shouldCancel() then
                cleanupPlaybackState()
                return false
            end
            local targetT = tonumber(event.t) or 0
            while not shouldCancel() and (os.clock() - started) < targetT do
                task.wait(0.01)
            end
            if shouldCancel() then
                cleanupPlaybackState()
                return false
            end
            local kind = event.kind
            if kind == "movement" then
                continue
            end
            local data = type(event.data) == "table" and event.data or {}
            local character = lpAutoSummit.Character
            local humanoid = select(1, getCharacterHumanoidAndRootWalk(character))

            if humanoid and autoSummitWalkPlaybackHumanoid ~= humanoid then
                if autoSummitWalkPlaybackHumanoid and autoSummitWalkPlaybackAutoRotateRestore ~= nil then
                    pcall(function()
                        autoSummitWalkPlaybackHumanoid.AutoRotate = autoSummitWalkPlaybackAutoRotateRestore
                    end)
                end
                autoSummitWalkPlaybackHumanoid = humanoid
                autoSummitWalkPlaybackAutoRotateRestore = humanoid.AutoRotate
                pcall(function()
                    humanoid.AutoRotate = false
                end)
            end

            if kind == "jump_request" then
                if humanoid then
                    pcall(function()
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end)
                end
            elseif (kind == "key_down" or kind == "key_up") and WalkVirtualInputManager then
                local keyCodeName = type(data.keyCode) == "string" and data.keyCode or ""
                local enumName = string.match(keyCodeName, "Enum%.KeyCode%.(.+)")
                local keyCode = enumName and Enum.KeyCode[enumName]
                if keyCode then
                    local isDown = kind == "key_down"
                    pcall(function()
                        WalkVirtualInputManager:SendKeyEvent(isDown, keyCode, false, game)
                    end)
                    autoSummitWalkKeysDown[keyCode] = isDown or nil
                end
            end
        end

        cleanupPlaybackState()
        return true
    end

    local autoSummitDeathCheckConn: any = nil

    -- Auto Summit UI: active walk route file
    local autoSummitWalkRouteFileDisplay = "—"
    local autoSummitTeleportStepDisplay = "—"

    local AutoSummitRouteModeParagraph: any = nil
    updateAutoSummitRouteModeParagraph = function()
        if not AutoSummitRouteModeParagraph or not AutoSummitRouteModeParagraph.Set then
            return
        end
        if not autoSummitEnabled then
            AutoSummitRouteModeParagraph:Set({
                Title = "Active route",
                Content = "Auto Summit is off.",
            })
            return
        end
        local modeHandler = getCurrentAutoSummitModeHandler()
        AutoSummitRouteModeParagraph:Set({
            Title = "Active route",
            Content = modeHandler.getRouteStatusContent(),
        })
    end

    local function disableAutoSummitDueToWalkFailure(reason: string)
        autoSummitSkipFinalStoppedNotify = true
        autoSummitEnabled = false
        stopAutoSummitWalkCharacter()
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

    -- After a *_failed_* recording finishes and CP is unchanged, retry using other JSONs for this leg,
    -- excluding failed files recorded in excludePaths (prefer non-failed routes first).
    -- excludePaths is reset at the start of each new leg (outer loop) in runWalkSummitLegsFromCurrentCp.
    local function rebuildWalkLegPathsAfterFailedAttempts(
        allCandidates: { string },
        excludePaths: { [string]: boolean },
        prefix: string,
        routeProbabilitiesByPrefix: { [string]: { [string]: number } }
    ): { string }
        local rest: { string } = {}
        for _, p in ipairs(allCandidates) do
            if not excludePaths[p] then
                table.insert(rest, p)
            end
        end
        local successPaths: { string } = {}
        local failedPaths: { string } = {}
        for _, p in ipairs(rest) do
            if walkRouteFileIsFailedVariant(p) then
                table.insert(failedPaths, p)
            else
                table.insert(successPaths, p)
            end
        end
        successPaths = buildWeightedRouteOrder(successPaths, prefix, routeProbabilitiesByPrefix)
        failedPaths = buildWeightedRouteOrder(failedPaths, prefix, routeProbabilitiesByPrefix)
        local out: { string } = {}
        for _, p in ipairs(successPaths) do
            table.insert(out, p)
        end
        for _, p in ipairs(failedPaths) do
            table.insert(out, p)
        end
        return out
    end

    local function tryLoadWalkRouteRecording(
        readFileFn: any,
        pickedPath: string,
        tryIdx: number,
        totalTries: number
    ): ({ any }?, Vector3?, { [string]: any }?, string?, string?)
        local baseName = baseNameFromPathMain(pickedPath)
        local label = ("(%d/%d)"):format(tryIdx, totalTries)
        local okRead, jsonText = pcall(function()
            return readFileFn(pickedPath)
        end)
        if not okRead or type(jsonText) ~= "string" then
            return nil, nil, nil, baseName, "read failed " .. label
        end
        local okDecode, payload = pcall(function()
            return HttpService:JSONDecode(jsonText)
        end)
        if not okDecode or type(payload) ~= "table" then
            return nil, nil, nil, baseName, "invalid JSON " .. label
        end
        local events = payload.events
        if type(events) ~= "table" or #events == 0 then
            return nil, nil, nil, baseName, "no events " .. label
        end
        local firstPos = findFirstMovementWorldPosition(events)
        if not firstPos then
            return nil, nil, nil, baseName, "no movement samples " .. label
        end
        return events, firstPos, payload, baseName, nil
    end

    local function runWalkSummitLegsFromCurrentCp(
        shouldCancel: () -> boolean,
        getRootPart: (number?) -> BasePart?
    ): (boolean, boolean)
        local readFileFn = resolveExecutorFnForMain("readfile")
        if type(readFileFn) ~= "function" then
            disableAutoSummitDueToWalkFailure("Walk mode needs readfile() from your executor")
            return false, false
        end
        if type(resolveExecutorFnForMain("listfiles")) ~= "function" then
            disableAutoSummitDueToWalkFailure("Walk mode needs listfiles() from your executor")
            return false, false
        end

        local routeProbabilitiesByPrefix = getMountRouteProbabilitiesByPrefix(readFileFn)
        local fallSpawnRows = getMountFallSpawnRows(readFileFn)

        autoSummitWalkRouteFileDisplay = "—"
        task.defer(updateAutoSummitRouteModeParagraph)

        local routeN = #summitRoute
        local reachedSummitInThisCycle = false

        while autoSummitEnabled and not shouldCancel() do
            local labelLeg = getCheckpointLabelString(lpAutoSummit)
            local routeStepStartOuter = summitRouteStepIndexFromLabel(labelLeg)
            if not routeStepStartOuter then
                disableAutoSummitDueToWalkFailure(
                    "Unknown checkpoint label (not on summit route): " .. tostring(labelLeg)
                )
                return false, reachedSummitInThisCycle
            end

            local prefix = summitRoute[routeStepStartOuter] and summitRoute[routeStepStartOuter].walkLegPrefix
            local runSingleLegOnly = routeStepStartOuter >= routeN
            if not prefix then
                if runSingleLegOnly then
                    return true, reachedSummitInThisCycle
                end
                disableAutoSummitDueToWalkFailure(
                    "No walk route mapping for route step " .. tostring(routeStepStartOuter)
                )
                return false, reachedSummitInThisCycle
            end

            local routeNameOuter = summitRoute[routeStepStartOuter].name
            if routeStepStartOuter == 1 then
                local startCpDelaySec = walkRouteRng:NextNumber(0, 0.5)
                if not waitWithCancel(startCpDelaySec, shouldCancel) then
                    return false, reachedSummitInThisCycle
                end
            end

            local candidates = listRouteJsonPathsForLegPrefix(prefix)
            if not autoSummitIncludeFailedRoute then
                local filtered: { string } = {}
                for _, p in ipairs(candidates) do
                    if not walkRouteFileIsFailedVariant(p) then
                        table.insert(filtered, p)
                    end
                end
                candidates = filtered
            end
            if #candidates == 0 then
                disableAutoSummitDueToWalkFailure(
                    "No JSON in " .. MOUNT_ROUTES_DIR .. " for leg " .. prefix .. "_* — Auto Summit off"
                )
                return false, reachedSummitInThisCycle
            end

            -- Cleared each outer loop: failed-route exclusions must not carry to the next camp/leg.
            local legExcludedPaths: { [string]: boolean } = {}

            local pathsToTry: { string } = {}
            for i = 1, #candidates do
                pathsToTry[i] = candidates[i]
            end
            pathsToTry = buildWeightedRouteOrder(pathsToTry, prefix, routeProbabilitiesByPrefix)

            local legAdvanced = false
            local retryLegWithFreshCandidates = false
            local tryIdx = 1
            while tryIdx <= #pathsToTry do
                if not autoSummitEnabled or shouldCancel() then
                    return false, reachedSummitInThisCycle
                end

                local pickedPath = pathsToTry[tryIdx]

                local events, firstPos, payload, baseName, loadErr = tryLoadWalkRouteRecording(
                    readFileFn,
                    pickedPath,
                    tryIdx,
                    #pathsToTry
                )
                if not events or not firstPos then
                    notifyAutoSummit(
                        ("Skip %s: %s"):format(baseName or baseNameFromPathMain(pickedPath), tostring(loadErr)),
                        "x"
                    )
                    tryIdx = tryIdx + 1
                else
                    notifyAutoSummit(
                        ("Walk leg %s -> %s (try %s/%s: %s)"):format(
                            routeNameOuter,
                            prefix,
                            tostring(tryIdx),
                            tostring(#pathsToTry),
                            baseName
                        )
                    )

                    autoSummitWalkRouteFileDisplay = baseName
                    task.defer(updateAutoSummitRouteModeParagraph)

                    local rootPart = getRootPart()
                    if not rootPart then
                        return false, reachedSummitInThisCycle
                    end
                    local character = lpAutoSummit.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if not humanoid then
                        return false, reachedSummitInThisCycle
                    end
                    local firstTargetPos = firstPos
                    local recordedRootToFeet = extractRecordedRootToFeetHeightWalk(payload, events)
                    local currentRootToFeet = getCharacterRootToFeetHeightWalk(character)
                    if recordedRootToFeet and currentRootToFeet then
                        local yOffset = currentRootToFeet - recordedRootToFeet
                        firstTargetPos = firstPos + Vector3.new(0, yOffset, 0)
                    end

                    local wpLeg = summitRoute[routeStepStartOuter]
                    local jumpAssistStop = (wpLeg and wpLeg.walkWithJump) and startWalkJumpAssistForLeg(shouldCancel)
                        or nil
                    local function endWalkJumpAssist()
                        if jumpAssistStop then
                            jumpAssistStop()
                        end
                    end

                    humanoidWalkToWorldPosition(humanoid, rootPart, firstTargetPos, shouldCancel, 7)
                    if shouldCancel() then
                        endWalkJumpAssist()
                        return false, reachedSummitInThisCycle
                    end

                    if not playRouteRecordingEvents(events, payload, shouldCancel) then
                        endWalkJumpAssist()
                        return false, reachedSummitInThisCycle
                    end
                    endWalkJumpAssist()

                    local isFailedLegRoute = walkRouteFileIsFailedVariant(pickedPath)
                    if isFailedLegRoute then
                        notifyAutoSummit(
                            ("Playback finished (%s) — watching CP / fall spawn (up to ~12s)..."):format(baseName),
                            "check"
                        )
                    end

                    -- Checkpoint label can update shortly after playback. For *_failed_* routes it often stays the same;
                    -- fallspawns.json (campName + position) detects respawn at this leg's camp so we can continue.
                    local stepAtLegStart = routeStepStartOuter
                    local advanced = false
                    local atFallSpawnForLeg = false
                    local cpPollMax = 50
                    for pollI = 1, cpPollMax do
                        if shouldCancel() then
                            return false, reachedSummitInThisCycle
                        end
                        local stepNow = summitRouteStepIndexFromLabel(getCheckpointLabelString(lpAutoSummit))
                        if stepNow and stepNow ~= stepAtLegStart then
                            advanced = true
                            break
                        end
                        if isFailedLegRoute and #fallSpawnRows > 0 then
                            local campNm = campNameForWalkRouteStep(routeStepStartOuter)
                            local spawnPos = campNm and fallSpawnWorldPositionForCamp(fallSpawnRows, campNm)
                            local charPoll = lpAutoSummit.Character
                            local rootPoll = charPoll and charPoll:FindFirstChild("HumanoidRootPart")
                            if
                                spawnPos
                                and rootPoll
                                and rootPoll:IsA("BasePart")
                                and rootPartNearWorldPosition(rootPoll, spawnPos, FALL_SPAWN_MATCH_RADIUS_STUDS)
                            then
                                atFallSpawnForLeg = true
                                break
                            end
                        end
                        if pollI < cpPollMax then
                            task.wait(0.25)
                        end
                    end
                    if advanced then
                        local stepAfterLeg = summitRouteStepIndexFromLabel(getCheckpointLabelString(lpAutoSummit))
                        if stepAfterLeg and stepAtLegStart < routeN and stepAfterLeg == routeN then
                            reachedSummitInThisCycle = true
                        end
                        if stepAfterLeg and stepAfterLeg < routeN then
                            local nextWp = summitRoute[stepAfterLeg]
                            local nextPrefix = (nextWp and nextWp.walkLegPrefix) or "unknown"
                            local afterName = summitRoute[stepAfterLeg].name
                            notifyAutoSummit(
                                ("Leg done at %s -> next route %s_*"):format(
                                    afterName,
                                    tostring(nextPrefix)
                                )
                            )
                        end
                        legAdvanced = true
                        break
                    end

                    if isFailedLegRoute then
                        legExcludedPaths[pickedPath] = true
                        local rest = rebuildWalkLegPathsAfterFailedAttempts(
                            candidates,
                            legExcludedPaths,
                            prefix,
                            routeProbabilitiesByPrefix
                        )
                        if #rest == 0 then
                            retryLegWithFreshCandidates = true
                            notifyAutoSummit(
                                ("No remaining routes for %s after %s — rechecking route list for this camp..."):format(
                                    prefix,
                                    baseName
                                ),
                                "x"
                            )
                            break
                        else
                            if atFallSpawnForLeg then
                                local cn = campNameForWalkRouteStep(routeStepStartOuter)
                                    or routeNameOuter
                                notifyAutoSummit(
                                    ("At %s fall spawn (still %s) after %s — retrying other routes (skipped this file)."):format(
                                        cn,
                                        routeNameOuter,
                                        baseName
                                    ),
                                    "x"
                                )
                            else
                                notifyAutoSummit(
                                    ("Still at %s after failed route %s — retrying other routes (skipped this file)."):format(
                                        routeNameOuter,
                                        baseName
                                    ),
                                    "x"
                                )
                            end
                            pathsToTry = rest
                            tryIdx = 1
                        end
                    else
                        notifyAutoSummit(
                            ("Checkpoint unchanged after %s — trying next route (%s/%s)"):format(
                                baseName,
                                tostring(tryIdx),
                                tostring(#pathsToTry)
                            ),
                            "x"
                        )
                        tryIdx = tryIdx + 1
                    end
                end
            end

            if not legAdvanced then
                if retryLegWithFreshCandidates then
                    task.wait(0.25)
                else
                    disableAutoSummitDueToWalkFailure(
                        "All "
                            .. tostring(#pathsToTry)
                            .. " route file(s) failed for leg "
                            .. prefix
                            .. " — Auto Summit off"
                    )
                    return false, reachedSummitInThisCycle
                end
            end
            if runSingleLegOnly then
                return true, reachedSummitInThisCycle
            end
        end

        if not autoSummitEnabled or shouldCancel() then
            return false, reachedSummitInThisCycle
        end
        local finalStep = summitRouteStepIndexFromLabel(getCheckpointLabelString(lpAutoSummit))
        return finalStep == routeN, reachedSummitInThisCycle
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

    local function runAutoSummitWalkCycle(
        shouldAbort: () -> boolean,
        getRootPart: (number?) -> BasePart?,
        skipNextCpResumeNotify: boolean
    ): (boolean, boolean, boolean)
        local routeCompleted = true
        syncAutoSummitCurrentCheckpointSnapshot()
        local routeStepNow = summitRouteStepIndexFromLabel(autoSummitCurrentCpLabel)
        local walkReachedSummitThisCycle = false
        local skippedSummitLegs = routeStepNow == nil
        if skippedSummitLegs then
            skipNextCpResumeNotify = false
        elseif not skipNextCpResumeNotify then
            local canonical = routeStepNow and summitRoute[routeStepNow].name or autoSummitCurrentCpLabel
            notifyAutoSummit(("%s — walk mode from next leg..."):format(canonical))
        else
            skipNextCpResumeNotify = false
        end
        if not skippedSummitLegs then
            local okWalk, reachedWalkSummit = runWalkSummitLegsFromCurrentCp(shouldAbort, getRootPart)
            walkReachedSummitThisCycle = reachedWalkSummit == true
            if not okWalk then
                routeCompleted = false
            end
        end
        return routeCompleted, walkReachedSummitThisCycle, skipNextCpResumeNotify
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
                disableAutoSummitDueToWalkFailure(
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
                disableAutoSummitDueToWalkFailure(
                    ("Teleport mode: invalid teleportPosition for %s"):format(tostring(wp.name))
                )
                return false, teleportReachedSummitThisCycle, skipNextCpResumeNotify
            end

            autoSummitTeleportStepDisplay = wp.name
            task.defer(updateAutoSummitRouteModeParagraph)

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
                    delaySec = baseDelay + walkRouteRng:NextNumber(math.min(ra, rb), math.max(ra, rb))
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

    local AUTO_SUMMIT_MODE_HANDLERS = {
        Walk = {
            getRouteStatusContent = function()
                return "Walk mode\nCurrent: " .. autoSummitWalkRouteFileDisplay
            end,
            resetRouteStatus = function()
                autoSummitWalkRouteFileDisplay = "—"
            end,
            runCycle = runAutoSummitWalkCycle,
            getBetweenRunDelay = function()
                return walkRouteRng:NextNumber(
                    WALK_BETWEEN_RUN_DELAY_MIN,
                    WALK_BETWEEN_RUN_DELAY_MAX
                )
            end,
        },
        Teleport = {
            getRouteStatusContent = function()
                return "Teleport mode\nStep: " .. autoSummitTeleportStepDisplay
            end,
            resetRouteStatus = function()
                autoSummitTeleportStepDisplay = "—"
            end,
            runCycle = runAutoSummitTeleportCycle,
            getBetweenRunDelay = function()
                return walkRouteRng:NextNumber(
                    WALK_BETWEEN_RUN_DELAY_MIN,
                    WALK_BETWEEN_RUN_DELAY_MAX
                )
            end,
        },
    }

    getCurrentAutoSummitModeHandler = function()
        local h = AUTO_SUMMIT_MODE_HANDLERS[autoSummitMode]
        return h or AUTO_SUMMIT_MODE_HANDLERS.Walk
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
        task.defer(updateAutoSummitRouteModeParagraph)
    end

    AutoSummitCpParagraph = MainTab:CreateParagraph({
        Title = AUTO_SUMMIT_CP_TITLE,
        Content = "POSISI: —\nRoute: Start",
    })

    AutoSummitRouteModeParagraph = MainTab:CreateParagraph({
        Title = "Active route",
        Content = "Auto Summit is off.",
    })
    task.defer(updateAutoSummitRouteModeParagraph)

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
        Name = "Include Failed Route",
        Flag = "yahayuk_main_include_failed_route",
        CurrentValue = false,
        Callback = function(enabled)
            autoSummitIncludeFailedRoute = enabled
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
                stopAutoSummitWalkCharacter()
                autoSummitWalkRouteFileDisplay = "—"
                autoSummitTeleportStepDisplay = "—"
                task.defer(updateAutoSummitRouteModeParagraph)
                return
            end

            autoSummitRestartFromDeath = false
            autoSummitRunTimes = {}
            updateAutoSummitTimesParagraph()
            updateAutoSummitCpParagraph()
            updateAutoSummitRouteModeParagraph()

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
                    local cycleMode = autoSummitMode
                    local function shouldAbort()
                        return not autoSummitEnabled
                            or autoSummitRestartFromDeath
                            or autoSummitMode ~= cycleMode
                    end
                    local modeHandler = getCurrentAutoSummitModeHandler()
                    modeHandler.resetRouteStatus()
                    updateAutoSummitRouteModeParagraph()
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
                    routeCompleted, reachedSummitThisCycle, skipNextCpResumeNotify =
                        modeHandler.runCycle(shouldAbort, getRootPart, skipNextCpResumeNotify)

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
                            if autoSummitEnabled and (not qtyNum or remaining > 0) then
                                local betweenRunDelay = modeHandler.getBetweenRunDelay()
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
                            if not waitWithCancel(1, shouldAbort) and not autoSummitEnabled then
                                break
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

    local SEND_REQUEST_CARRY_DELAY_PER_TARGET = 4
    local SEND_REQUEST_CARRY_CYCLE_GAP = 6
    local SEND_REQUEST_CARRY_MAX_DISTANCE_STUDS = 18
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
    SendRequestCarryAutoToggle = MainTab:CreateToggle({
        Name = "Auto Send",
        Flag = "yahayuk_main_send_carry_auto",
        CurrentValue = false,
        Callback = function(enabled)
            sendRequestCarryAutoLoopToken = sendRequestCarryAutoLoopToken + 1
            if not enabled then
                return
            end

            local ok, carryRemote = pcall(function()
                return ReplicatedStorage:WaitForChild("CarryRemote", 10)
            end)
            if not ok or not carryRemote then
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

            local loopId = sendRequestCarryAutoLoopToken
            local warnedNoTargets = false

            task.spawn(function()
                while loopId == sendRequestCarryAutoLoopToken do
                    local targets = sendRequestCarryCollectTargetIds()
                    if #targets == 0 then
                        if not warnedNoTargets then
                            warnedNoTargets = true
                            mountNotify({
                                Title = "Send Request Carry",
                                Content = "No targets — select players and/or add names that match someone in the server",
                                Icon = "x",
                            })
                        end
                        task.wait(5)
                    else
                        warnedNoTargets = false
                        for _, targetId in ipairs(targets) do
                            if loopId ~= sendRequestCarryAutoLoopToken then
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

            mountNotify({
                Title = "Send Request Carry",
                Content = "Auto send started",
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

    local campLocations = {
        { label = "Camp 1", x = -407.77, y = 248.20, z = 794.09 },
        { label = "Camp 2", x = -337.77, y = 388.27, z = 522.16 },
        { label = "Camp 3", x = 294.19, y = 430.33, z = 494.17 },
        { label = "Camp 4", x = 323.46, y = 490.24, z = 348.33 },
        { label = "Camp 5", x = 226.70, y = 314.21, z = -143.64 },
        { label = "Summit", x = -613.51, y = 905.28, z = -533.45 },
    }

    for _, loc in ipairs(campLocations) do
        local label, cx, cy, cz = loc.label, loc.x, loc.y, loc.z
        local campSlug = string.gsub(label, "%s+", "_")
        local campFlag = "yahayuk_main_teleport_" .. string.lower(campSlug)
        MainTab:CreateButton({
            Name = label,
            Flag = campFlag,
            Callback = function()
                teleportToCampCoords(cx, cy, cz, label)
            end,
        })
    end
end

-- */  Map Tab  /* --
do
    local MapTab = Window:CreateTab("Map", 4483362458)
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
createTeleportTab(Window, mountNotify, { ext = true, notifyIcons = true, playerSearch = true, playerNoneOption = true })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, { replicatedStorage = ReplicatedStorage })

-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, "sempatpanick/mount_yahayuk/recordings")

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/mount_yahayuk",
    rayfieldLibrary = RayfieldLibrary,
})
