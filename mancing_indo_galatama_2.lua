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
local TeleportService = game:GetService("TeleportService")

local RayfieldLibrary

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
            RayfieldLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/rayfield_library.lua"))()
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

local function rayfieldDropdownFirst(opts)
    return type(opts) == "table" and opts[1] or opts
end

-- */  Recording Tab (module)  /* --
local RECORDING_TAB_REPO = "https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/tabs/recording_tab.lua"
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

local createRecordingTab = loadCreateRecordingTab(RECORDING_TAB_REPO)
if not createRecordingTab then
    createRecordingTab = function(_windowRef, notifyFn, _recordingsDir)
        notifyFn({ Title = "Recording", Content = "Failed to load recording tab module", Icon = "x" })
    end
end

-- */  Local Player Tab (module)  /* --
local LOCAL_PLAYER_TAB_REPO = "https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/tabs/local_player_tab.lua"
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
local OBJECTS_TAB_REPO = "https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/tabs/objects_tab.lua"
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
-- */  Window  /* --
local Window = RayfieldLibrary:CreateWindow({
    Name = "sempatpanick | Mancing Indo Galatama",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Mancing Indo Galatama",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "sempatpanick",
        FileName = "mancing_indo_galatama",
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
createLocalPlayerTab(Window, mountNotify)

-- */  Main Tab (Auto Fishing â€” Reel only, same flow as mancing_indo.lua reel mode)  /* --
do
    local MainTab = Window:CreateTab("Main", 4483362458)

    MainTab:CreateSection("Look Direction")
    local POOL_CORNERS = {
        Vector3.new(563.48, 4.20, 346.40),
        Vector3.new(563.54, 4.03, 473.97),
        Vector3.new(752.70, 4.06, 473.99),
        Vector3.new(752.90, 4.34, 346.39),
    }
    local autoLookPoolEnabled = false
    local autoLookPoolConnection = nil

    local function nearestPointOnSegmentXZ(pointPos, a, b)
        local ap = Vector3.new(pointPos.X - a.X, 0, pointPos.Z - a.Z)
        local ab = Vector3.new(b.X - a.X, 0, b.Z - a.Z)
        local abLenSq = ab.X * ab.X + ab.Z * ab.Z
        if abLenSq <= 1e-8 then
            return Vector3.new(a.X, pointPos.Y, a.Z)
        end
        local t = (ap.X * ab.X + ap.Z * ab.Z) / abLenSq
        t = math.clamp(t, 0, 1)
        return Vector3.new(a.X + ab.X * t, pointPos.Y, a.Z + ab.Z * t)
    end

    local function getNearestPoolSidePoint(pointPos)
        local bestPoint = nil
        local bestDistSq = math.huge
        for i = 1, #POOL_CORNERS do
            local a = POOL_CORNERS[i]
            local b = POOL_CORNERS[(i % #POOL_CORNERS) + 1]
            local candidate = nearestPointOnSegmentXZ(pointPos, a, b)
            local dx = candidate.X - pointPos.X
            local dz = candidate.Z - pointPos.Z
            local distSq = dx * dx + dz * dz
            if distSq < bestDistSq then
                bestDistSq = distSq
                bestPoint = candidate
            end
        end
        return bestPoint
    end

    local function stopAutoLookPool()
        if autoLookPoolConnection then
            autoLookPoolConnection:Disconnect()
            autoLookPoolConnection = nil
        end
    end

    local function startAutoLookPool()
        stopAutoLookPool()
        autoLookPoolConnection = RunService.Heartbeat:Connect(function()
            if not autoLookPoolEnabled then
                stopAutoLookPool()
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                return
            end
            local target = getNearestPoolSidePoint(rootPart.Position)
            if not target then
                return
            end
            if (target - rootPart.Position).Magnitude < 0.05 then
                return
            end
            rootPart.CFrame = CFrame.lookAt(rootPart.Position, target)
        end)
    end

    MainTab:CreateToggle({
        Name = "Auto Look to Pool",
        Flag = "galatama_main_autoLookPool",
        CurrentValue = false,
        Callback = function(enabled)
            autoLookPoolEnabled = enabled
            if enabled then
                startAutoLookPool()
            else
                stopAutoLookPool()
            end
        end,
    })
    MainTab:CreateSection("Auto Fishing")
    local autoFishingEnabled = false
    local autoFishingLoopRunning = false
    local instantFishingEnabled = false
    local instantFishingLoopRunning = false
    local instantFishingDelaySec = 4
    local instantFishingArmSeq = 0
    local randomCastCmgrEnabled = false
    local randomCastCmgrSync = false
    local RandomCastCmgrToggleAuto
    local RandomCastCmgrToggleInstant

    local function setBothRandomCastCmgrToggles(enabled, skipInstance)
        randomCastCmgrSync = true
        randomCastCmgrEnabled = enabled
        if RandomCastCmgrToggleAuto and RandomCastCmgrToggleAuto ~= skipInstance then
            pcall(function()
                RandomCastCmgrToggleAuto:Set(enabled)
            end)
        end
        if RandomCastCmgrToggleInstant and RandomCastCmgrToggleInstant ~= skipInstance then
            pcall(function()
                RandomCastCmgrToggleInstant:Set(enabled)
            end)
        end
        randomCastCmgrSync = false
    end

    local minigameAutoSolveConn = nil
    local minigameCycleSeq = 0
    local MINIGAME_SESSION_TIMEOUT = 20
    local REEL_AUTOPLAY_START_DELAY = 0.06
    local REEL_AUTOPLAY_TIMEOUT = 55
    local REEL_DEEP_NUKE_AFTER = 0.45
    local REEL_AUTOPLAY_RS_HOOK_NAME = "MancingIndoGalatamaReelDeepHack"
    local REEL_TRY_FAST_REMOTE_COMPLETE = true
    local reelAutoplayLoopRunning = false
    local mgrReelPendingToken = nil
    local autoFishDelay2sAfterPreEnableDrain = false
    local minigameSessionWait = nil
    local AutoFishStatusParagraph

    local function fishingAutomationActive()
        return autoFishingEnabled or instantFishingEnabled
    end

    local function ensureMinigamePreferenceIsReel()
        -- Galatama match is reel-only; no SettingsGui minigame switch.
    end

    local function releaseMinigameSessionWait()
        local pending = minigameSessionWait
        if not pending then
            return
        end
        minigameSessionWait = nil
        pending.done:Fire()
    end

    local function getMinigamesMgArea()
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

    local function isFishingMinigameCircleActive()
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

    local function countReelUiScreenGuis(pg)
        local n = 0
        for _, ch in pg:GetChildren() do
            if ch.Name == "ReelUI" and ch:IsA("ScreenGui") then
                n = n + 1
            end
        end
        return n
    end

    -- Galatama: minigame is active when PlayerGui has more than one ReelUI (e.g. template + live instance).
    local function isReelMinigameActive()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return false
        end
        return countReelUiScreenGuis(pg) > 1
    end

    -- Status / reel parts: only when multiple ReelUIs (minigame active); use the last sibling named ReelUI.
    local function getReelUiScreenGuiForResolve()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return nil
        end
        local lastReel = nil
        for _, ch in pg:GetChildren() do
            if ch.Name == "ReelUI" and ch:IsA("ScreenGui") then
                lastReel = ch
            end
        end
        if not lastReel then
            return nil
        end
        if countReelUiScreenGuis(pg) > 1 then
            return lastReel
        end
        return nil
    end

    local function mancingFindNamedDescendant(root, name)
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

    local function mancingVimKey(isDown, keyCode)
        local ok = pcall(function()
            VirtualInputManager:SendKeyEvent(isDown, keyCode, false, game)
        end)
        return ok
    end

    local function mancingResolveReelParts()
        local reelUi = getReelUiScreenGuiForResolve()
        if not (reelUi and reelUi:IsA("ScreenGui") and reelUi.Enabled) then
            return nil, nil, nil, nil
        end
        local canvas = mancingFindNamedDescendant(reelUi, "Canvas")
        if not canvas then
            return reelUi, nil, nil, nil
        end
        local bar = mancingFindNamedDescendant(canvas, "Bar")
        local fill = bar and mancingFindNamedDescendant(bar, "Fill")
        local status = mancingFindNamedDescendant(canvas, "Status")
        if status and not (status:IsA("TextLabel") or status:IsA("TextButton")) then
            status = nil
        end
        local f = (fill and fill:IsA("GuiObject")) and fill or nil
        local sgui = (status and status:IsA("GuiObject")) and status or nil
        return reelUi, sgui, nil, f
    end

    local function mancingGetReelStatusText(statusGui)
        if not statusGui then
            return ""
        end
        local t = ""
        if statusGui:IsA("TextLabel") then
            t = statusGui.Text
            if t == "" then
                local okCt, ct = pcall(function()
                    return statusGui.ContentText
                end)
                if okCt and type(ct) == "string" then
                    t = ct
                end
            end
        elseif statusGui:IsA("TextButton") then
            t = statusGui.Text
            if t == "" then
                local okCt, ct = pcall(function()
                    return statusGui.ContentText
                end)
                if okCt and type(ct) == "string" then
                    t = ct
                end
            end
        end
        return t
    end

    local function mancingReelStatusRequiresNoKnobSpin(st)
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

    local function mancingClassifyReelPhase(st)
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

    local function mancingResolveReelPhase(st)
        if st ~= "" then
            return mancingClassifyReelPhase(st)
        end
        return "spin"
    end

    -- Instant fishing only: getconnections + debug.setupvalue; optional fast MGR Complete.
    local reelDeepHookCachedRenderFns = {}
    local reelDeepHookCachedConns = {}

    local function mancingExploitGetConnections(sig)
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

    local function mancingExploitConnFunction(conn)
        if type(conn) ~= "table" then
            return nil
        end
        return conn.Function or rawget(conn, "f")
    end

    local function mancingFnReferencesInstance(fn, inst)
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
                i = i + 1
            end
            return false
        end)
        return ok and found == true
    end

    local function mancingReelDeepHackBuildCache(mgr)
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

    local function mancingReelDeepHackEnsureCache(mgr)
        if #reelDeepHookCachedRenderFns > 0 then
            local f0 = reelDeepHookCachedRenderFns[1]
            if type(f0) == "function" and mancingFnReferencesInstance(f0, mgr) then
                return true
            end
        end
        return mancingReelDeepHackBuildCache(mgr)
    end

    local function mancingReelDeepHackTrySetupvalueU32(fn)
        if type(debug) ~= "table" or type(debug.getupvalue) ~= "function" or type(debug.setupvalue) ~= "function" then
            return false
        end
        local candidates = {}
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
                i = i + 1
            end
            if #candidates == 1 then
                debug.setupvalue(fn, candidates[1], 1)
                return true
            end
            if #candidates > 1 then
                local _, _, _, fill = mancingResolveReelParts()
                if fill then
                    local target = fill.Size.X.Scale
                    local bestIdx = nil
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
                local maxIdx = nil
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

    local function mancingReelDeepHackTryDisableAndComplete(mgr, token)
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

    local function mancingReelDeepHackTrySetupvalueWin(mgr)
        mancingReelDeepHackEnsureCache(mgr)
        for _, fn in reelDeepHookCachedRenderFns do
            if mancingReelDeepHackTrySetupvalueU32(fn) then
                return true
            end
        end
        return false
    end

    local function mancingReelDeepHackTryNukeComplete(mgr)
        return mancingReelDeepHackTryDisableAndComplete(mgr, mgrReelPendingToken)
    end

    local function mancingReelDeepHookClearCache()
        table.clear(reelDeepHookCachedRenderFns)
        table.clear(reelDeepHookCachedConns)
    end

    local function updateAutoFishStatusParagraphs()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")

        local reelBits = {}
        if not pg then
            table.insert(reelBits, "PlayerGui: missing")
        else
            local n = countReelUiScreenGuis(pg)
            table.insert(reelBits, (n > 1) and "Minigame: active" or "Minigame: not active")
            local _, statusGui, _, fill = mancingResolveReelParts()
            local st = mancingGetReelStatusText(statusGui)
            if st ~= "" then
                local phase = mancingResolveReelPhase(st)
                table.insert(reelBits, "Status: " .. st)
                table.insert(reelBits, "Phase: " .. phase)
            else
                table.insert(reelBits, "Status: â€”")
            end
            if fill then
                table.insert(
                    reelBits,
                    string.format("Fill: %.0f%%", math.clamp(fill.Size.X.Scale, 0, 1) * 100)
                )
            else
                table.insert(reelBits, "Fill: â€”")
            end
        end
        local reelText = table.concat(reelBits, "\n")

        if AutoFishStatusParagraph and AutoFishStatusParagraph.Set then
            AutoFishStatusParagraph:Set({ Content = reelText })
        end
    end

    -- Auto: VIM E/Q only. Instant: deep hack + optional fast MGR Complete + E/Q loop.
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

        local function setE(want)
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

        local function setQ(want)
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

        if fishingAutomationActive() and os.clock() - t0 >= REEL_AUTOPLAY_TIMEOUT and isReelMinigameActive() then
            warn(
                "[Fishing] reel autoplay timed out â€” VirtualInputManager E/Q, getconnections/debug, or MGR Complete token."
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
                warn("[Fishing] reel autoplay error: ", err)
            end
        end)
    end

    local function tryActivateMinigameChallengeUi()
        local area = getMinigamesMgArea()
        if not area then
            return false
        end
        local mg = area:FindFirstAncestorWhichIsA("ScreenGui")
        local hadToEnableScreenGui = false
        if mg and not mg.Enabled then
            hadToEnableScreenGui = true
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
            mg.Enabled = false
        end
        return anyOk
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
        -- Galatama: "Start" + table { Token }; main game may use "StartReel" + table.
        minigameAutoSolveConn = MGR.OnClientEvent:Connect(function(action, a2, _a3, _a4, _a5)
            if action == "StartReel" then
                if type(a2) == "table" and a2.Token ~= nil then
                    mgrReelPendingToken = a2.Token
                end
            elseif action == "Start" then
                if type(a2) == "table" and a2.Token ~= nil then
                    mgrReelPendingToken = a2.Token
                else
                    mgrReelPendingToken = nil
                end
            elseif action == "Stop" then
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
            if action == "StartReel" then
                task.defer(scheduleMancingReelAutoplayIfNeeded)
                return
            end
            if action == "Start" and type(a2) == "table" and a2.Token ~= nil then
                task.defer(scheduleMancingReelAutoplayIfNeeded)
            end
        end)
    end

    local function waitForMinigameCleared(reason)
        local t0 = os.clock()
        while
            (isFishingMinigameCircleActive() or mgrReelPendingToken ~= nil or isReelMinigameActive())
            and fishingAutomationActive()
            and os.clock() - t0 < MINIGAME_SESSION_TIMEOUT
        do
            task.wait(0.05)
        end
        if
            fishingAutomationActive()
            and os.clock() - t0 >= MINIGAME_SESSION_TIMEOUT
            and (isFishingMinigameCircleActive() or mgrReelPendingToken ~= nil or isReelMinigameActive())
        then
            warn("[Fishing] timed out waiting for minigame to end (" .. reason .. ")")
            mgrReelPendingToken = nil
        end
        if fishingAutomationActive() then
            task.wait(0.2)
        end
    end

    local function completeOrWaitMinigameBeforeCast()
        if not fishingAutomationActive() then
            return false
        end
        ensureMinigameAutoSolve()

        if mgrReelPendingToken ~= nil or isReelMinigameActive() then
            task.defer(scheduleMancingReelAutoplayIfNeeded)
            waitForMinigameCleared("reel E/Q autoplay drain")
            return true
        end

        if isFishingMinigameCircleActive() then
            task.wait(0.05)
            if not fishingAutomationActive() then
                return false
            end
            tryActivateMinigameChallengeUi()
            local tManual = os.clock()
            while isFishingMinigameCircleActive() and fishingAutomationActive() and os.clock() - tManual < 0.35 do
                task.wait(0.05)
            end
            if isFishingMinigameCircleActive() then
                waitForMinigameCleared("after UI Activate fallback")
            else
                if fishingAutomationActive() then
                    task.wait(0.2)
                end
            end
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

    local function playerHasFishingRodEquipped()
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
        local resultValue = 1
        if randomCastCmgrEnabled then
            resultValue = math.random(500, 1000) / 1000
        end
        pcall(function()
            CMGR:FireServer("Result", resultValue)
        end)
    end

    local function runFishingCycleImpl(equipWait, castToCmgrWait, afterMinigameWait, afterDrainWait)
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
        minigameCycleSeq = minigameCycleSeq + 1
        local cycleSeq = minigameCycleSeq

        if not playerHasFishingRodEquipped() then
            equipFishingRodRemote()
            task.wait(equipWait)
        end
        castFishingRodRemote()
        task.wait(castToCmgrWait)
        setFishingCastResultRemote()
        task.defer(function()
            task.wait(0.12)
            if fishingAutomationActive() and isReelMinigameActive() then
                scheduleMancingReelAutoplayIfNeeded()
            end
        end)

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

    local function runAutoFishingCycleImpl()
        return runFishingCycleImpl(0.2, 1, 2.5, 2)
    end

    local function runAutoFishingCycle()
        local ok, res = pcall(runAutoFishingCycleImpl)
        if not ok then
            warn("[Auto fishing] cycle error: ", res)
            return false
        end
        return res
    end

    local function runAutoFishingLoop()
        while autoFishingEnabled do
            if not runAutoFishingCycle() then
                task.wait(0.5)
            end
        end
        autoFishingLoopRunning = false
    end

    local function runInstantFishingCycleImpl()
        return runFishingCycleImpl(0.12, 0.18, 2, 0.25)
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

    local function runInstantFishingLoop()
        while instantFishingEnabled do
            if not runInstantFishingCycle() then
                task.wait(0.25)
            end
        end
        instantFishingLoopRunning = false
    end

    AutoFishStatusParagraph = MainTab:CreateParagraph({
        Title = "Status",
        Content = "â€¦",
    })

    RandomCastCmgrToggleAuto = MainTab:CreateToggle({
        Name = "Random Cast",
        Flag = "galatama_main_randomCastCmgr",
        CurrentValue = false,
        Callback = function(enabled)
            if randomCastCmgrSync then
                randomCastCmgrEnabled = enabled
                return
            end
            setBothRandomCastCmgrToggles(enabled, RandomCastCmgrToggleAuto)
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Fishing",
        Flag = "galatama_main_autoFishing",
        CurrentValue = false,
        Callback = function(enabled)
            autoFishingEnabled = enabled
            if enabled then
                instantFishingArmSeq = instantFishingArmSeq + 1
                instantFishingEnabled = false
                releaseMinigameSessionWait()
                ensureMinigameAutoSolve()
                autoFishDelay2sAfterPreEnableDrain = isFishingMinigameCircleActive()
                    or mgrReelPendingToken ~= nil
                    or isReelMinigameActive()
            else
                releaseMinigameSessionWait()
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
    MainTab:CreateSection("Instant fishing")
    MainTab:CreateInput({
        Name = "Delay (seconds)",
        PlaceholderText = "e.g. 4",
        Flag = "galatama_main_instantFishingDelaySec",
        CurrentValue = tostring(instantFishingDelaySec),
        Callback = function(value)
            local n = tonumber(value)
            if n and n >= 0 then
                instantFishingDelaySec = n
            end
        end,
    })

    RandomCastCmgrToggleInstant = MainTab:CreateToggle({
        Name = "Random Cast",
        Flag = "galatama_main_randomCastCmgr",
        CurrentValue = false,
        Callback = function(enabled)
            if randomCastCmgrSync then
                randomCastCmgrEnabled = enabled
                return
            end
            setBothRandomCastCmgrToggles(enabled, RandomCastCmgrToggleInstant)
        end,
    })

    MainTab:CreateToggle({
        Name = "Instant fishing",
        Flag = "galatama_main_instantFishing",
        CurrentValue = false,
        Callback = function(enabled)
            if enabled then
                autoFishingEnabled = false
                releaseMinigameSessionWait()
                instantFishingArmSeq = instantFishingArmSeq + 1
                local armSeq = instantFishingArmSeq
                task.spawn(function()
                    ensureMinigamePreferenceIsReel()
                    task.wait(0.15)
                    if armSeq ~= instantFishingArmSeq then
                        return
                    end
                    instantFishingEnabled = true
                    ensureMinigameAutoSolve()
                    autoFishDelay2sAfterPreEnableDrain = isFishingMinigameCircleActive()
                        or mgrReelPendingToken ~= nil
                        or isReelMinigameActive()
                    if instantFishingLoopRunning then
                        return
                    end
                    instantFishingLoopRunning = true
                    runInstantFishingLoop()
                end)
            else
                instantFishingArmSeq = instantFishingArmSeq + 1
                instantFishingEnabled = false
                releaseMinigameSessionWait()
                autoFishDelay2sAfterPreEnableDrain = false
            end
        end,
    })

    task.defer(updateAutoFishStatusParagraphs)
    task.spawn(function()
        while true do
            task.wait(0.25)
            pcall(updateAutoFishStatusParagraphs)
        end
    end)

    task.defer(ensureMinigameAutoSolve)
end
-- */  Teleport Tab  /* --
do
    local TeleportTab = Window:CreateTab("Teleport", 4483362458)

    TeleportTab:CreateSection("Teleport")
    local teleportInputValue = ""
    local teleportLookInputValue = ""

    local function teleportParseNumberTriple(str)
        local s = str:gsub(",", " "):gsub("%s+", " ")
        local parts = {}
        for part in string.gmatch(s, "[%d%.%-]+") do
            table.insert(parts, tonumber(part))
        end
        return parts
    end

    local function teleportCFrameFromInputs(posStr, lookStr)
        local posParts = teleportParseNumberTriple(posStr)
        if #posParts < 3 then
            return nil
        end
        local pos = Vector3.new(posParts[1], posParts[2], posParts[3])
        local lookParts = teleportParseNumberTriple(lookStr)
        if #lookParts < 3 then
            return CFrame.new(pos)
        end
        local dir = Vector3.new(lookParts[1], lookParts[2], lookParts[3])
        if dir.Magnitude < 1e-5 then
            return CFrame.new(pos)
        end
        return CFrame.lookAt(pos, pos + dir.Unit)
    end

    local TeleportInput = TeleportTab:CreateInput({
        Name = "Location",
        PlaceholderText = "e.g. 100, 5, 200 or 100 5 200",
        Flag = "galatama_tp_location",
        CurrentValue = teleportInputValue,
        Callback = function(value)
            teleportInputValue = value
        end,
    })

    local TeleportLookInput = TeleportTab:CreateInput({
        Name = "Look direction",
        PlaceholderText = "e.g. 0, 0, -1 or leave empty for position only",
        Flag = "galatama_tp_lookDirection",
        CurrentValue = teleportLookInputValue,
        Callback = function(value)
            teleportLookInputValue = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Get Current Location",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
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
            local look = rootPart.CFrame.LookVector
            local lookText = string.format("%.4f, %.4f, %.4f", look.X, look.Y, look.Z)
            teleportLookInputValue = lookText
            if TeleportLookInput and TeleportLookInput.Set then
                TeleportLookInput:Set(lookText)
            elseif TeleportLookInput and TeleportLookInput.SetValue then
                TeleportLookInput:SetValue(lookText)
            end
            mountNotify({
                Title = "Location",
                Content = "Position: " .. text .. " Â· Look: " .. lookText,
            })
        end,
    })
    TeleportTab:CreateButton({
        Name = "Teleport",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
                return
            end
            local cf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not cf then
                mountNotify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                })
                return
            end
            rootPart.CFrame = cf
            local p = cf.Position
            mountNotify({
                Title = "Teleport",
                Content = string.format("Teleported to %.1f, %.1f, %.1f", p.X, p.Y, p.Z),
            })
        end,
    })
    local tweenDurationValue = "5"
    TeleportTab:CreateInput({
        Name = "Tween Duration",
        PlaceholderText = "e.g. 5",
        Flag = "galatama_tp_tweenDurationSec",
        CurrentValue = tweenDurationValue,
        Callback = function(value)
            tweenDurationValue = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Tween to Location",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
                return
            end
            local targetCf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not targetCf then
                mountNotify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                })
                return
            end
            local duration = tonumber(tweenDurationValue) or 5
            if duration < 0.1 then duration = 0.1 end
            local tweenInfo = TweenInfo.new(duration)
            local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = targetCf })
            tween:Play()
            local p = targetCf.Position
            mountNotify({
                Title = "Teleport",
                Content = string.format("Tweening to %.1f, %.1f, %.1f (%.1fs)", p.X, p.Y, p.Z, duration),
            })
        end,
    })

    -- */  Teleport to Players  /* --
    TeleportTab:CreateSection("Teleport to Players")
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
                if PlayerTeleportDropdown and PlayerTeleportDropdown.Set then PlayerTeleportDropdown:Set({}) end
            end
        end
        if showNotify then
            mountNotify({ Title = "Teleport", Content = "Player list refreshed (" .. #playerList .. " players)" })
        end
    end

    PlayerTeleportDropdown = TeleportTab:CreateDropdown({
        Name = "Player",
        Flag = "galatama_tp_playerPick",
        Options = playerDisplayNames,
        CurrentOption = {},
        Callback = function(opts)
            local value = rayfieldDropdownFirst(opts)
            selectedTeleportPlayer = nil
            if value then
                local idx = table.find(playerDisplayNames, value)
                if idx and playerList[idx] then
                    selectedTeleportPlayer = playerList[idx]
                end
            end
        end
    })

    TeleportTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshPlayerList(true)
        end
    })
    TeleportTab:CreateButton({
        Name = "Teleport",
        Callback = function()
            if not selectedTeleportPlayer then
                mountNotify({ Title = "Teleport", Content = "Select a player first" })
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
                return
            end
            local targetChar = selectedTeleportPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then
                mountNotify({ Title = "Teleport", Content = "Target player has no character" })
                return
            end
            rootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0, 3))
            mountNotify({ Title = "Teleport", Content = "Teleported to " .. (selectedTeleportPlayer.DisplayName or selectedTeleportPlayer.Name) })
        end
    })
end

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, { replicatedStorage = ReplicatedStorage })

createRecordingTab(Window, mountNotify, "sempatpanick/mancing_indo_galatama/recordings")

