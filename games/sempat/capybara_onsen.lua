local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local VirtualUser = game:GetService("VirtualUser")

local LocalPlayer = Players.LocalPlayer

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
            assert(okGet and type(source) == "string", "[sempat/capybara_onsen] failed to load sempat_library")
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
        notifyFn({ Title = "Recording", Content = "Failed to load Recording Tab module" })
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
    Name = "sempatpanick | Capybara Onsen",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Sempat UI • Capybara Onsen",
    ToggleUIKeybind = "K",
    WindowTransparency = 30,
    Icon = "https://dadang.id/sempatpanick-icon.png",
    ConfigurationSaving = {
        Enabled = true,
        AutoSave = false,
        AutoLoad = false,
        FolderName = "sempatpanick",
        FileName = "capybara_onsen",
    },
})

-- */  Local Player Tab  /* --
createLocalPlayerTab(Window, mountNotify, { flagsPrefix = "lp", tabIcon = "user" })

-- ====================================================================
--                          CAPYBARA ONSEN
-- ====================================================================
local Remotes

local function resolveRemotes()
    if Remotes and Remotes.Parent then
        return Remotes
    end
    local folder = ReplicatedStorage:FindFirstChild("Remotes")
    if folder then
        Remotes = folder
    end
    return Remotes
end

local function getRemote(name)
    local folder = resolveRemotes()
    if not folder then
        return nil
    end
    local remote = folder:FindFirstChild(name)
    return remote
end

local function fireServer(name, ...)
    local remote = getRemote(name)
    if not remote then
        return false, "remote not found: " .. name
    end
    local args = { ... }
    local ok, err = pcall(function()
        remote:FireServer(table.unpack(args))
    end)
    if not ok then
        return false, tostring(err)
    end
    return true
end

local function invokeGetData()
    local remote = getRemote("GetData")
    if not remote then
        return nil
    end
    local ok, result = pcall(function()
        return remote:InvokeServer()
    end)
    if ok and type(result) == "table" then
        return result
    end
    return nil
end

local function numberOr(value, fallback)
    if type(value) == "number" then
        return value
    end
    return fallback
end

local function formatNumber(n)
    n = math.floor(numberOr(n, 0) + 0.5)
    local formatted = tostring(n)
    while true do
        local replaced
        formatted, replaced = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
        if replaced == 0 then
            break
        end
    end
    return formatted
end

-- */  Source config modules (PlotConfig / ChestTier / SettingsSpec / NumberFormat)  /* --
local function getSourceChild(name)
    local src = ReplicatedStorage:FindFirstChild("Source")
    if not src then
        return nil
    end
    local child = src:FindFirstChild(name)
    if not child then
        return nil
    end
    local ok, mod = pcall(require, child)
    if ok then
        return mod
    end
    return nil
end

local function makeSourceGetter(name)
    local cached = nil
    return function()
        if cached ~= nil then
            return cached
        end
        local mod = getSourceChild(name)
        if mod ~= nil then
            cached = mod
        end
        return mod
    end
end

local getPlotConfig = makeSourceGetter("PlotConfig")
local getChestTier = makeSourceGetter("ChestTier")
local getSettingsSpec = makeSourceGetter("SettingsSpec")
local getUnitMath = makeSourceGetter("UnitMath")
local getUnitPricing = makeSourceGetter("UnitPricing")

-- */  Plot / part resolution  /* --
local function resolvePlot()
    local plotName = LocalPlayer:GetAttribute("Plot")
    if type(plotName) ~= "string" or plotName == "" then
        return nil
    end
    local cfg = getPlotConfig()
    if not (cfg and type(cfg.WorkspacePaths) == "table" and type(cfg.WorkspacePaths.Tycoons) == "table") then
        return nil
    end
    local node = Workspace
    for _, seg in ipairs(cfg.WorkspacePaths.Tycoons) do
        node = node and node:FindFirstChild(seg)
    end
    if not node then
        return nil
    end
    return node:FindFirstChild(plotName)
end

local function getCashierPart()
    local cfg = getPlotConfig()
    local plot = resolvePlot()
    if not (cfg and plot) then
        return nil
    end
    local partName = cfg.CashierStack and cfg.CashierStack.PartName
    if type(partName) ~= "string" then
        return nil
    end
    local essentials = plot:FindFirstChild("Essentials")
    local part = (essentials and essentials:FindFirstChild(partName, true)) or plot:FindFirstChild(partName, true)
    if part and part:IsA("BasePart") then
        return part
    end
    return nil
end

-- Find a named pad ("Deposit" / "Cashier") on the plot and return its BasePart.
local function getPlotPad(name)
    local plot = resolvePlot()
    if not plot then
        return nil
    end
    local found = plot:FindFirstChild(name, true)
    if not found then
        return nil
    end
    if found:IsA("BasePart") then
        return found
    end
    return found:FindFirstChildWhichIsA("BasePart", true)
end

local function getButtonsFolder()
    local plot = resolvePlot()
    if not plot then
        return nil
    end
    local cfg = getPlotConfig()
    local buttonsName = (cfg and cfg.TycoonChildren and cfg.TycoonChildren.Buttons) or "Buttons"
    return plot:FindFirstChild(buttonsName)
end

-- Plot buy pads live under Buttons/<name>/Head (PlotConfig.ButtonHeadChild).
local function getButtonHead(buttonName)
    local buttons = getButtonsFolder()
    if not buttons then
        return nil
    end
    local button = buttons:FindFirstChild(buttonName)
    if not button then
        return nil
    end
    local cfg = getPlotConfig()
    local headName = (cfg and cfg.ButtonHeadChild) or "Head"
    local head = button:FindFirstChild(headName)
    if head and head:IsA("BasePart") then
        return head
    end
    if button:IsA("BasePart") then
        return button
    end
    return button:FindFirstChildWhichIsA("BasePart", true)
end

-- The "Deposit" pad converts carried Yuzu -> PendingCash at the current market rate.
local function getDepositPad()
    return getButtonHead("Deposit") or getPlotPad("Deposit") or getCashierPart()
end

-- The "Cashier" pad banks accumulated PendingCash -> spendable Cash.
local function getCashierPad()
    return getButtonHead("Cashier") or getPlotPad("Cashier") or getCashierPart()
end

-- Yuzu Market rate lives on the DropBonus map node as a "Multiplier" attribute
-- (fluctuates between DropBonus.MinMultiplier..MaxMultiplier, cycles every CycleSec).
local function getDropBonusNode()
    local cfg = getPlotConfig()
    local path = cfg and cfg.DropBonus and cfg.DropBonus.InstancePath
    if type(path) == "table" then
        local node = Workspace
        for _, seg in ipairs(path) do
            node = node and node:FindFirstChild(seg)
        end
        if node then
            return node
        end
    end
    local maps = Workspace:FindFirstChild("Maps")
    return maps and maps:FindFirstChild("DropBonus")
end

local function getMarketRate()
    local node = getDropBonusNode()
    if not node then
        return nil
    end
    local mult = node:GetAttribute("Multiplier")
    if typeof(mult) == "number" then
        return mult
    end
    return nil
end

local function getMarketRateBounds()
    local cfg = getPlotConfig()
    local minMult = (cfg and cfg.DropBonus and tonumber(cfg.DropBonus.MinMultiplier)) or 0.5
    local maxMult = (cfg and cfg.DropBonus and tonumber(cfg.DropBonus.MaxMultiplier)) or 1.5
    if maxMult <= minMult then
        maxMult = minMult + 1
    end
    return minMult, maxMult
end

local function getTowerPart()
    local plot = resolvePlot()
    if not plot then
        return nil
    end
    for _, candidate in ipairs({ "Tower", "Base", "MoneyStackBase" }) do
        local found = plot:FindFirstChild(candidate, true)
        if found and found:IsA("BasePart") then
            return found
        end
    end
    return nil
end

local function getWorkspaceFolderByConfig(subKey)
    local cfg = getPlotConfig()
    if not cfg then
        return nil
    end
    local sub = cfg[subKey]
    local folderName = sub and sub.DropsFolderName
    if type(folderName) ~= "string" then
        return nil
    end
    return Workspace:FindFirstChild(folderName)
end

-- The game removes drop/chest models CLIENT-SIDE on pickup (its playLocalPickup);
-- firing the pickup remote directly skips that, so we destroy the model ourselves.
-- Drop models are named "Drop_<id>", chests "Chest_<id>", under their config folder.
local function removeSpawnModel(folderKey, prefix, id)
    local folder = getWorkspaceFolderByConfig(folderKey)
    if not folder then
        return
    end
    local model = folder:FindFirstChild(prefix .. tostring(id))
    if model then
        pcall(function()
            model:Destroy()
        end)
    end
end

-- */  Local character / teleport helpers  /* --
local function getLocalRoot()
    local char = LocalPlayer.Character
    if not char then
        return nil
    end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root and root:IsA("BasePart") then
        return root
    end
    return nil
end

local function restoreCFrame(cframe)
    local root = getLocalRoot()
    if root and cframe then
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = cframe
        return true
    end
    return false
end

local function teleportToPosition(pos, yOffset)
    local root = getLocalRoot()
    if not (root and typeof(pos) == "Vector3") then
        return false
    end
    root.AssemblyLinearVelocity = Vector3.zero
    root.AssemblyAngularVelocity = Vector3.zero
    root.CFrame = CFrame.new(pos + Vector3.new(0, yOffset or 3, 0))
    return true
end

local function teleportToPart(part, yOffset)
    if not (part and part:IsA("BasePart")) then
        return false
    end
    return teleportToPosition(part.Position, yOffset)
end

local function resolveFireTouchInterest()
    local fn = rawget(_G, "firetouchinterest")
    if type(fn) == "function" then
        return fn
    end
    local syn = rawget(_G, "syn")
    if type(syn) == "table" and type(syn.firetouchinterest) == "function" then
        return syn.firetouchinterest
    end
    local getgenvFn = rawget(_G, "getgenv")
    if type(getgenvFn) == "function" then
        local ok, genv = pcall(getgenvFn)
        if ok and type(genv) == "table" then
            fn = rawget(genv, "firetouchinterest")
            if type(fn) == "function" then
                return fn
            end
        end
    end
    return nil
end

-- Simulate touching a pad without moving the character (executor API).
local function fireTouchPart(targetPart)
    local root = getLocalRoot()
    local fireTouch = resolveFireTouchInterest()
    if not (root and targetPart and targetPart:IsA("BasePart") and fireTouch) then
        return false
    end
    local ok = pcall(function()
        fireTouch(root, targetPart, 0)
        task.wait(0.05)
        fireTouch(root, targetPart, 1)
    end)
    return ok
end

-- Serialize travel features: each job saves position, runs, restores, then next job.
local travelQueue = {}
local travelBusy = false
local travelDepth = 0

local function pumpTravelQueue()
    if travelBusy then
        return
    end
    if #travelQueue == 0 then
        return
    end
    travelBusy = true
    task.spawn(function()
        local job = table.remove(travelQueue, 1)
        if job then
            travelDepth += 1

            local savedCFrame = nil
            if job.restoreAfter then
                local root = getLocalRoot()
                if root then
                    savedCFrame = root.CFrame
                end
            end

            local ok, a, b, c, d = pcall(job.fn)

            if job.restoreAfter and savedCFrame then
                restoreCFrame(savedCFrame)
            end

            travelDepth -= 1
            if ok then
                job.results = table.pack(a, b, c, d)
            else
                job.results = table.pack(false, tostring(a))
            end
            job.finished = true
        end
        travelBusy = false
        pumpTravelQueue()
    end)
end

local function runExclusiveTravel(fn, opts)
    if type(fn) ~= "function" then
        return false, "invalid travel fn"
    end
    opts = type(opts) == "table" and opts or {}
    if travelDepth > 0 then
        return fn()
    end

    local job = {
        fn = fn,
        restoreAfter = opts.restoreAfter ~= false,
        finished = false,
        results = nil,
    }
    table.insert(travelQueue, job)
    pumpTravelQueue()
    while not job.finished do
        task.wait()
    end
    local results = job.results or table.pack(false, "travel queue failed")
    return table.unpack(results, 1, results.n)
end

-- */  Chest reward log (populated from ChestOpenResult)  /* --
local chestRewardLog = { entries = {}, count = 0, totalValue = 0, bestRarity = 0 }

local function chestRarityName(rarity)
    local chestTier = getChestTier()
    if chestTier and type(chestTier.displayName) == "function" then
        local ok, name = pcall(chestTier.displayName, rarity)
        if ok and type(name) == "string" then
            return name
        end
    end
    return "Rarity " .. tostring(rarity)
end

local function pushChestReward(rarity, value)
    rarity = numberOr(rarity, 0)
    value = numberOr(value, 0)
    chestRewardLog.count += 1
    chestRewardLog.totalValue += value
    if rarity > chestRewardLog.bestRarity then
        chestRewardLog.bestRarity = rarity
    end
    table.insert(chestRewardLog.entries, 1, { rarity = rarity, value = value })
    for i = #chestRewardLog.entries, 6, -1 do
        chestRewardLog.entries[i] = nil
    end
end

-- */  Drop / Chest live tracking  /* --
local activeDrops = {} -- [dropId] = { pos = Vector3, firedAt = number }
local activeChests = {} -- [chestId] = { pos = Vector3, firedAt = number }
local trackingBound = false

local function bindDropChestTracking()
    if trackingBound then
        return
    end
    if not resolveRemotes() then
        return
    end

    local dropSpawned = getRemote("DropSpawned")
    local dropExpired = getRemote("DropExpired")
    local chestSpawn = getRemote("ChestSpawn")

    if not (dropSpawned and dropExpired) then
        return
    end

    dropSpawned.OnClientEvent:Connect(function(dropId, _name, pos)
        if type(dropId) == "number" then
            activeDrops[dropId] = { pos = (typeof(pos) == "Vector3") and pos or nil, firedAt = 0 }
        end
    end)

    dropExpired.OnClientEvent:Connect(function(dropId)
        if type(dropId) == "number" then
            activeDrops[dropId] = nil
        end
    end)

    if chestSpawn then
        chestSpawn.OnClientEvent:Connect(function(chestId, _tier, pos)
            if type(chestId) == "number" then
                activeChests[chestId] = { pos = (typeof(pos) == "Vector3") and pos or nil, firedAt = 0 }
            end
        end)
    end

    local chestOpenResult = getRemote("ChestOpenResult")
    if chestOpenResult then
        chestOpenResult.OnClientEvent:Connect(function(rarity, value)
            if type(rarity) == "number" and type(value) == "number" then
                pushChestReward(rarity, value)
            end
        end)
    end

    trackingBound = true
end

local function countTable(t)
    local n = 0
    for _ in pairs(t) do
        n += 1
    end
    return n
end

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", "coins")

    local statusParagraph

    local autoLootEnabled = false
    local autoLootToken = 0
    local autoLootDelaySec = 0.2
    local autoLootDelaySlider = nil

    local autoChestPickupEnabled = false
    local autoChestPickupToken = 0

    local autoOpenChestEnabled = false
    local autoOpenChestToken = 0

    local autoClaimOfflineEnabled = false
    local autoClaimOfflineToken = 0

    -- R1 Auto Deposit Carry
    local autoDepositEnabled = false
    local autoDepositToken = 0
    local autoDepositIntervalSec = 3
    local autoDepositReturn = true
    local minDepositRate = 1.0
    local gateDepositByRate = true

    -- Auto Collect Cash (touch the "Cashier" pad — the game's "Collect money!")
    local autoCollectCashEnabled = false
    local autoCollectCashToken = 0
    local autoCollectCashIntervalSec = 2
    local autoCollectCashReturn = true
    local autoCollectCashUseTeleport = false

    -- R2 Smart chest opening
    local minOpenRarity = 0

    -- A1 Auto Buy Tiers
    local autoBuyEnabled = false
    local autoBuyToken = 0
    local autoBuyIntervalSec = 2
    local autoBuyReturn = true

    -- Auto Buy Capybara (Add1 / Add5 / Add25 / Add100)
    local CAPYBARA_BUY_OPTIONS = {
        { label = "100", count = 100, button = "Add100" },
        { label = "25", count = 25, button = "Add25" },
        { label = "5", count = 5, button = "Add5" },
        { label = "1", count = 1, button = "Add1" },
    }
    local autoBuyCapybaraEnabled = false
    local autoBuyCapybaraToken = 0
    local autoBuyCapybaraIntervalSec = 0.5
    local autoBuyCapybaraReturn = true
    local autoBuyCapybaraSelected = { ["1"] = true } -- label -> enabled

    -- A2 Rejoin farm
    local autoRejoinEnabled = false
    local autoRejoinToken = 0
    local autoRejoinIntervalSec = 300

    -- Prevent idle rejoin (game IdleClient teleports after ~16m of no input)
    local preventRejoinEnabled = false
    local allowIntentionalRejoin = false
    local teleportHooksInstalled = false
    local disabledIdleScripts = {}
    local idledConn = nil

    -- R4 ESP
    local dropEspEnabled = false
    local chestEspEnabled = false
    local espState = {}
    local espRenderConn = nil

    -- paragraph refs
    local rewardParagraph
    local leaderboardParagraph

    local lastData = nil

    local function getAutoLootDelaySec()
        local fromSlider = autoLootDelaySlider and tonumber(autoLootDelaySlider.CurrentValue)
        local delaySec = fromSlider or tonumber(autoLootDelaySec) or 0.2
        if delaySec ~= delaySec or delaySec < 0 then
            delaySec = 0.2
        end
        return math.clamp(delaySec, 0.05, 30)
    end

    local function waitToken(token, tokenRef, enabledRef, delaySec)
        local deadline = os.clock() + delaySec
        while enabledRef() and token == tokenRef() do
            local remaining = deadline - os.clock()
            if remaining <= 0 then
                return true
            end
            task.wait(math.min(0.1, remaining))
        end
        return false
    end

    local function refreshStatus()
        if not statusParagraph or not statusParagraph.Set then
            return
        end
        local data = lastData
        local remotesReady = resolveRemotes() ~= nil
        if not data then
            statusParagraph:Set({
                Content = string.format(
                    "Remotes: %s · Tracking: %s\nData: waiting…\nDrops: %d · Chests: %d",
                    remotesReady and "ready" or "waiting",
                    trackingBound and "on" or "off",
                    countTable(activeDrops),
                    countTable(activeChests)
                ),
            })
            return
        end

        local cash = numberOr(data.Cash, 0)
        local totalEarned = numberOr(data.TotalEarned, 0)
        local moneyMult = 1
        if type(data.Multipliers) == "table" then
            moneyMult = numberOr(data.Multipliers.Money, 1)
        end
        local carry = 0
        local heldChest = 0
        local pendingOffline = 0
        local pendingCash = 0
        if type(data.Tycoon) == "table" then
            carry = numberOr(data.Tycoon.Carry, 0)
            heldChest = numberOr(data.Tycoon.HeldChestRarity, 0)
            pendingOffline = numberOr(data.Tycoon.PendingOfflineReward, 0)
            if type(data.Tycoon.Shop) == "table" then
                pendingCash = numberOr(data.Tycoon.Shop.PendingCash, 0)
            end
        end

        local premiumBonus = ""
        local cfg = getPlotConfig()
        if
            cfg
            and type(cfg.Boost) == "table"
            and type(cfg.Boost.PremiumMoneyBonusPct) == "number"
            and LocalPlayer.MembershipType == Enum.MembershipType.Premium
        then
            premiumBonus = string.format(" +%d%% premium", math.floor(cfg.Boost.PremiumMoneyBonusPct))
        end
        local plotStatus = resolvePlot() and "found" or "?"
        local marketRate = getMarketRate()
        local rateStr = marketRate and string.format("%.2fx", marketRate) or "closed"

        statusParagraph:Set({
            Content = string.format(
                "Cash: %s · Earned: %s\nPending Cash: %s · Money x%.2f%s · Carry: %s\nYuzu Market: %s (min %.2fx%s) · Held Chest: %d\nOffline Pending: %s · Drops: %d · Chests: %d\nTracking: %s · Plot: %s",
                formatNumber(cash),
                formatNumber(totalEarned),
                formatNumber(pendingCash),
                moneyMult,
                premiumBonus,
                formatNumber(carry),
                rateStr,
                minDepositRate,
                gateDepositByRate and "" or ", off",
                heldChest,
                formatNumber(pendingOffline),
                countTable(activeDrops),
                countTable(activeChests),
                trackingBound and "on" or "off",
                plotStatus
            ),
        })
    end

    local function refreshData()
        local data = invokeGetData()
        if data then
            lastData = data
        end
        refreshStatus()
        return lastData
    end

    -- Fire pickup for every tracked drop; honor a small refire cooldown.
    -- On success we also destroy the local "Drop_<id>" model (the game does this
    -- client-side on a normal pickup; the pickup remote does not) and drop it from
    -- tracking so counts stay accurate.
    local function lootAllDrops()
        local fired = 0
        local now = os.clock()
        for dropId, info in pairs(activeDrops) do
            if now - (info.firedAt or 0) >= 0.75 then
                info.firedAt = now
                local ok = fireServer("DropPickup", dropId)
                if ok then
                    fired += 1
                    removeSpawnModel("Drop", "Drop_", dropId)
                    activeDrops[dropId] = nil
                end
            end
        end
        return fired
    end

    local function pickupAllChests()
        local fired = 0
        local now = os.clock()
        for chestId, info in pairs(activeChests) do
            if now - (info.firedAt or 0) >= 0.75 then
                info.firedAt = now
                local ok = fireServer("ChestPickup", chestId)
                if ok then
                    fired += 1
                    removeSpawnModel("Chest", "Chest_", chestId)
                    activeChests[chestId] = nil
                end
            end
        end
        return fired
    end

    local function runAutoLootLoop(token)
        while autoLootEnabled and token == autoLootToken do
            bindDropChestTracking()
            lootAllDrops()
            if not waitToken(token, function() return autoLootToken end, function() return autoLootEnabled end, getAutoLootDelaySec()) then
                break
            end
        end
    end

    local function runAutoChestPickupLoop(token)
        while autoChestPickupEnabled and token == autoChestPickupToken do
            bindDropChestTracking()
            pickupAllChests()
            if not waitToken(token, function() return autoChestPickupToken end, function() return autoChestPickupEnabled end, 0.5) then
                break
            end
        end
    end

    local function getTycoonNum(key)
        local data = lastData
        if data and type(data.Tycoon) == "table" then
            return numberOr(data.Tycoon[key], 0)
        end
        return 0
    end

    local function getCash()
        local data = lastData
        return data and numberOr(data.Cash, 0) or 0
    end

    local function getPendingCash()
        local data = lastData
        if data and type(data.Tycoon) == "table" and type(data.Tycoon.Shop) == "table" then
            return numberOr(data.Tycoon.Shop.PendingCash, 0)
        end
        return 0
    end

    local function getBuyTier()
        local data = lastData
        if data and type(data.Tycoon) == "table" and type(data.Tycoon.Shop) == "table" then
            return numberOr(data.Tycoon.Shop.BuyTier, 1)
        end
        return 1
    end

    local function getUnitsOnTower()
        local data = lastData
        if data and type(data.Tycoon) == "table" and type(data.Tycoon.UnitsOnTower) == "table" then
            return data.Tycoon.UnitsOnTower
        end
        return {}
    end

    local function getNextTierUpgradeInfo()
        local cfg = getPlotConfig()
        local tierUpgrader = cfg and cfg.TierUpgrader
        if not tierUpgrader then
            return nil, "TierUpgrader config unavailable"
        end

        local buyTier = getBuyTier()
        local maxTier = numberOr(tierUpgrader.MaxTier, 10)
        if buyTier >= maxTier then
            return nil, "max tier reached"
        end

        local nextTier = buyTier + 1
        local upgrades = tierUpgrader.Upgrades
        if type(upgrades) ~= "table" then
            return nil, "upgrade table unavailable"
        end

        local upgrade = upgrades[nextTier]
        if type(upgrade) ~= "table" then
            return nil, "no upgrade defined for tier " .. tostring(nextTier)
        end

        return {
            nextTier = nextTier,
            cost = numberOr(upgrade.cost, 0),
            requiredEquiv = numberOr(upgrade.requiredEquiv, 0),
            buttonName = tierUpgrader.ButtonName or "TierUpgrader",
        }
    end

    local function getTierUpgradeAffordability()
        refreshData()

        local info, err = getNextTierUpgradeInfo()
        if not info then
            return false, err
        end

        local unitMath = getUnitMath()
        if not (unitMath and type(unitMath.tierOneEquivalent) == "function") then
            return false, "UnitMath unavailable"
        end

        local okEquiv, equiv = pcall(unitMath.tierOneEquivalent, getUnitsOnTower())
        if not okEquiv or type(equiv) ~= "number" then
            return false, "failed to read unit count"
        end

        if equiv < info.requiredEquiv then
            return false, string.format(
                "need %s units (have %s)",
                formatNumber(info.requiredEquiv),
                formatNumber(equiv)
            )
        end

        local cash = getCash()
        if cash < info.cost then
            return false, string.format(
                "need %s cash (have %s)",
                formatNumber(info.cost),
                formatNumber(cash)
            )
        end

        return true, info
    end

    -- Best-effort unlock cost; arity of ChestTier.unlockCost is unconfirmed, so a
    -- nil result means "cost unknown" and the caller does NOT block opening.
    local function chestUnlockCost(rarity)
        local chestTier = getChestTier()
        if chestTier and type(chestTier.unlockCost) == "function" then
            local ok, cost = pcall(chestTier.unlockCost, rarity, rarity)
            if ok and type(cost) == "number" then
                return cost
            end
        end
        return nil
    end

    local function tryOpenHeldChest(force)
        local held = getTycoonNum("HeldChestRarity")
        if held <= 0 then
            return false, "no chest held"
        end
        if not force then
            if held < minOpenRarity then
                return false, "below min rarity"
            end
            local cost = chestUnlockCost(held)
            if cost and getCash() < cost then
                return false, "not affordable"
            end
        end
        return fireServer("ChestOpen")
    end

    local function runAutoOpenChestLoop(token)
        while autoOpenChestEnabled and token == autoOpenChestToken do
            tryOpenHeldChest(false)
            if not waitToken(token, function() return autoOpenChestToken end, function() return autoOpenChestEnabled end, 1.0) then
                break
            end
        end
    end

    local function runAutoClaimOfflineLoop(token)
        while autoClaimOfflineEnabled and token == autoClaimOfflineToken do
            local data = lastData or refreshData()
            local pending = 0
            if data and type(data.Tycoon) == "table" then
                pending = numberOr(data.Tycoon.PendingOfflineReward, 0)
            end
            if pending > 0 then
                fireServer("ClaimOfflineReward")
            end
            if not waitToken(token, function() return autoClaimOfflineToken end, function() return autoClaimOfflineEnabled end, 3.0) then
                break
            end
        end
    end

    -- R1 — deposit carried Yuzu at the market pad (rate applies), then bank at cashier.
    -- Unless `force`, the deposit is skipped while the market rate is below minDepositRate,
    -- so Yuzu is only sold when the Yuzu Market multiplier is favorable.
    local function depositCarryOnce(doReturn, force)
        return runExclusiveTravel(function()
            local depositPad = getDepositPad()
            local cashierPad = getCashierPad()
            if not (depositPad or cashierPad) then
                return false, "pads not found (plot not resolved)"
            end

            local rate = getMarketRate()
            if not force and gateDepositByRate then
                if rate == nil then
                    return false, "market closed / rate unknown"
                end
                if rate < minDepositRate then
                    return false, string.format("rate %.2f < min %.2f", rate, minDepositRate)
                end
            end

            if getLocalRoot() == nil then
                return false, "character not loaded"
            end
            if depositPad then
                teleportToPart(depositPad, 3)
                task.wait(0.4)
            end
            if cashierPad and cashierPad ~= depositPad then
                teleportToPart(cashierPad, 3)
                task.wait(0.35)
            end
            return true, rate
        end, { restoreAfter = doReturn ~= false })
    end

    local function runAutoDepositLoop(token)
        while autoDepositEnabled and token == autoDepositToken do
            if getTycoonNum("Carry") > 0 then
                depositCarryOnce(autoDepositReturn, false)
            end
            if not waitToken(token, function() return autoDepositToken end, function() return autoDepositEnabled end, math.max(0.5, autoDepositIntervalSec)) then
                break
            end
        end
    end

    -- Auto Collect Cash — touch the plot's "Cashier" button Head to bank PendingCash -> Cash.
    -- Uses firetouchinterest when available; falls back to teleport if not.
    local function collectCashOnce(doReturn, force)
        return runExclusiveTravel(function()
            if not force and getPendingCash() <= 0 then
                return false, "no pending cash"
            end
            local pad = getCashierPad()
            if not pad then
                return false, "cashier pad not found (plot not resolved)"
            end
            if getLocalRoot() == nil then
                return false, "character not loaded"
            end

            if not autoCollectCashUseTeleport and fireTouchPart(pad) then
                task.wait(0.2)
                return true
            end

            if not autoCollectCashUseTeleport and resolveFireTouchInterest() == nil then
                return false, "firetouchinterest unavailable — enable Teleport To Collect"
            end

            teleportToPart(pad, 3)
            task.wait(0.45)
            return true
        end, { restoreAfter = doReturn ~= false })
    end

    local function runAutoCollectCashLoop(token)
        while autoCollectCashEnabled and token == autoCollectCashToken do
            if getPendingCash() > 0 then
                collectCashOnce(autoCollectCashReturn, false)
            end
            if not waitToken(token, function() return autoCollectCashToken end, function() return autoCollectCashEnabled end, math.max(0.5, autoCollectCashIntervalSec)) then
                break
            end
        end
    end

    -- Upgrade BuyTier via the TierUpgrader pad when cash + unit requirements are met.
    local function tryUpgradeTierOnce(doReturn, force)
        return runExclusiveTravel(function()
            local affordable, infoOrReason = getTierUpgradeAffordability()
            if not affordable then
                return false, infoOrReason
            end

            local info = infoOrReason
            local pad = getButtonHead(info.buttonName)
            if not pad then
                return false, "TierUpgrader pad not found"
            end
            if getLocalRoot() == nil then
                return false, "character not loaded"
            end

            if fireTouchPart(pad) then
                task.wait(0.25)
                return true, info.nextTier
            end

            teleportToPart(pad, 2)
            task.wait(0.35)
            return true, info.nextTier
        end, { restoreAfter = doReturn ~= false })
    end

    local function runAutoBuyLoop(token)
        while autoBuyEnabled and token == autoBuyToken do
            local affordable = select(1, getTierUpgradeAffordability())
            if affordable then
                tryUpgradeTierOnce(autoBuyReturn, false)
            end
            if not waitToken(token, function() return autoBuyToken end, function() return autoBuyEnabled end, math.max(0.5, autoBuyIntervalSec)) then
                break
            end
        end
    end

    local function getCapybaraBuySelectionsSorted()
        local selected = {}
        for _, opt in ipairs(CAPYBARA_BUY_OPTIONS) do
            if autoBuyCapybaraSelected[opt.label] then
                table.insert(selected, opt)
            end
        end
        -- CAPYBARA_BUY_OPTIONS is already highest-first (100 → 1).
        return selected
    end

    local function getAddBuyCost(count)
        local pricing = getUnitPricing()
        local unitMath = getUnitMath()
        local cfg = getPlotConfig()
        if not (pricing and type(pricing.GetAddCost) == "function") then
            return nil, "UnitPricing unavailable"
        end
        if not (unitMath and type(unitMath.tierOneEquivalent) == "function") then
            return nil, "UnitMath unavailable"
        end

        local okEquiv, equiv = pcall(unitMath.tierOneEquivalent, getUnitsOnTower())
        if not okEquiv or type(equiv) ~= "number" then
            return nil, "failed to read unit count"
        end

        local buyTier = getBuyTier()
        local mergeRatio = (cfg and tonumber(cfg.MergeRatio)) or 3
        local okCost, cost = pcall(pricing.GetAddCost, equiv, count, buyTier, mergeRatio)
        if not okCost or type(cost) ~= "number" then
            return nil, "failed to compute buy cost"
        end
        return cost, equiv
    end

    -- Prefer the highest selected amount that cash can afford.
    local function pickAffordableCapybaraBuy()
        local selected = getCapybaraBuySelectionsSorted()
        if #selected == 0 then
            return nil, "no amounts selected"
        end

        refreshData()
        local cash = getCash()
        local lastReason = nil
        for _, opt in ipairs(selected) do
            local cost, reason = getAddBuyCost(opt.count)
            if type(cost) ~= "number" then
                lastReason = reason
            elseif cash >= cost then
                return {
                    label = opt.label,
                    count = opt.count,
                    button = opt.button,
                    cost = cost,
                }
            else
                lastReason = string.format(
                    "Buy %s needs %s cash (have %s)",
                    opt.label,
                    formatNumber(cost),
                    formatNumber(cash)
                )
            end
        end
        return nil, lastReason or "not affordable"
    end

    local function tryBuyCapybaraOnce(doReturn)
        return runExclusiveTravel(function()
            local info, reason = pickAffordableCapybaraBuy()
            if not info then
                return false, reason
            end
            if getLocalRoot() == nil then
                return false, "character not loaded"
            end

            local pad = getButtonHead(info.button)
            if not pad then
                return false, info.button .. " pad not found"
            end

            if fireTouchPart(pad) then
                task.wait(0.15)
                return true, info
            end

            teleportToPart(pad, 2)
            task.wait(0.25)
            return true, info
        end, { restoreAfter = doReturn ~= false })
    end

    local function runAutoBuyCapybaraLoop(token)
        while autoBuyCapybaraEnabled and token == autoBuyCapybaraToken do
            if next(autoBuyCapybaraSelected) ~= nil then
                local info = select(1, pickAffordableCapybaraBuy())
                if info then
                    tryBuyCapybaraOnce(autoBuyCapybaraReturn)
                end
            end
            if not waitToken(
                token,
                function()
                    return autoBuyCapybaraToken
                end,
                function()
                    return autoBuyCapybaraEnabled
                end,
                math.max(0.1, autoBuyCapybaraIntervalSec)
            ) then
                break
            end
        end
    end

    -- A2 — rejoin farm / prevent idle rejoin
    local function resolveHookFunction()
        local fn = rawget(_G, "hookfunction")
        if type(fn) == "function" then
            return fn
        end
        local syn = rawget(_G, "syn")
        if type(syn) == "table" and type(syn.hook_function) == "function" then
            return syn.hook_function
        end
        local getgenvFn = rawget(_G, "getgenv")
        if type(getgenvFn) == "function" then
            local ok, genv = pcall(getgenvFn)
            if ok and type(genv) == "table" and type(rawget(genv, "hookfunction")) == "function" then
                return rawget(genv, "hookfunction")
            end
        end
        return nil
    end

    local function resolveHookMetaMethod()
        local fn = rawget(_G, "hookmetamethod")
        if type(fn) == "function" then
            return fn
        end
        local getgenvFn = rawget(_G, "getgenv")
        if type(getgenvFn) == "function" then
            local ok, genv = pcall(getgenvFn)
            if ok and type(genv) == "table" and type(rawget(genv, "hookmetamethod")) == "function" then
                return rawget(genv, "hookmetamethod")
            end
        end
        return nil
    end

    local function shouldBlockTeleport(placeId)
        if not preventRejoinEnabled or allowIntentionalRejoin then
            return false
        end
        return placeId == nil or placeId == game.PlaceId
    end

    local function installTeleportHooks()
        if teleportHooksInstalled then
            return true
        end

        local hooked = false
        local hookFn = resolveHookFunction()
        if hookFn then
            local okTeleport = pcall(function()
                local original
                original = hookFn(TeleportService.Teleport, function(self, placeId, ...)
                    if shouldBlockTeleport(placeId) then
                        return
                    end
                    return original(self, placeId, ...)
                end)
            end)
            hooked = hooked or okTeleport

            local okAsync = pcall(function()
                if type(TeleportService.TeleportAsync) ~= "function" then
                    return
                end
                local original
                original = hookFn(TeleportService.TeleportAsync, function(self, placeId, ...)
                    if shouldBlockTeleport(placeId) then
                        return
                    end
                    return original(self, placeId, ...)
                end)
            end)
            hooked = hooked or okAsync
        end

        local hookMeta = resolveHookMetaMethod()
        local getNamecall = rawget(_G, "getnamecallmethod")
        if hookMeta and type(getNamecall) == "function" then
            local okMeta = pcall(function()
                local oldNamecall
                oldNamecall = hookMeta(game, "__namecall", function(self, ...)
                    if self == TeleportService and preventRejoinEnabled and not allowIntentionalRejoin then
                        local method = string.lower(tostring(getNamecall()))
                        if method == "teleport" or method == "teleportasync" or method == "teleporttoplaceinstance" then
                            local placeId = ...
                            if shouldBlockTeleport(placeId) then
                                return
                            end
                        end
                    end
                    return oldNamecall(self, ...)
                end)
            end)
            hooked = hooked or okMeta
        end

        teleportHooksInstalled = hooked
        return hooked
    end

    local function setIdleClientDisabled(disabled)
        local roots = {
            LocalPlayer:FindFirstChild("PlayerScripts"),
            LocalPlayer:FindFirstChild("PlayerGui"),
        }
        for _, root in ipairs(roots) do
            if root then
                for _, descendant in ipairs(root:GetDescendants()) do
                    if descendant:IsA("LocalScript") and descendant.Name == "IdleClient" then
                        if disabled then
                            if disabledIdleScripts[descendant] == nil then
                                disabledIdleScripts[descendant] = descendant.Disabled
                            end
                            descendant.Disabled = true
                        elseif disabledIdleScripts[descendant] ~= nil then
                            descendant.Disabled = disabledIdleScripts[descendant]
                            disabledIdleScripts[descendant] = nil
                        end
                    end
                end
            end
        end
    end

    local function bindAntiIdleKick(enabled)
        if idledConn then
            idledConn:Disconnect()
            idledConn = nil
        end
        if not enabled then
            return
        end
        idledConn = LocalPlayer.Idled:Connect(function()
            if not preventRejoinEnabled then
                return
            end
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.new())
            end)
        end)
    end

    local function setPreventRejoinEnabled(enabled)
        preventRejoinEnabled = enabled == true
        if preventRejoinEnabled then
            installTeleportHooks()
            setIdleClientDisabled(true)
            bindAntiIdleKick(true)
            if autoRejoinEnabled then
                autoRejoinEnabled = false
                autoRejoinToken += 1
            end
        else
            setIdleClientDisabled(false)
            bindAntiIdleKick(false)
        end
    end

    local function doRejoin()
        if preventRejoinEnabled then
            return false, "blocked by Prevent Rejoin"
        end
        allowIntentionalRejoin = true
        local ok, err = pcall(function()
            TeleportService:Teleport(game.PlaceId, LocalPlayer)
        end)
        allowIntentionalRejoin = false
        return ok, err
    end

    local function runAutoRejoinLoop(token)
        while autoRejoinEnabled and token == autoRejoinToken do
            if preventRejoinEnabled then
                break
            end
            if not waitToken(token, function() return autoRejoinToken end, function() return autoRejoinEnabled end, math.max(60, autoRejoinIntervalSec)) then
                break
            end
            if autoRejoinEnabled and token == autoRejoinToken and not preventRejoinEnabled then
                doRejoin()
            end
        end
    end

    -- R4 — Drop / Chest ESP (highlights + distance labels)
    local function destroyEspEntry(st)
        if st.highlight then
            pcall(function() st.highlight:Destroy() end)
        end
        if st.label then
            pcall(function() st.label:Destroy() end)
        end
    end

    local function clearEsp()
        for inst, st in pairs(espState) do
            destroyEspEntry(st)
            espState[inst] = nil
        end
    end

    local function ensureEsp(inst, color, kind)
        if espState[inst] then
            return
        end
        local adornee = inst:IsA("BasePart") and inst or inst:FindFirstChildWhichIsA("BasePart", true)
        if not adornee then
            return
        end
        local hl = Instance.new("Highlight")
        hl.Name = "SempatPanickOnsenESP"
        hl.FillColor = color
        hl.FillTransparency = 0.4
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = inst
        hl.Parent = inst

        local gui = Instance.new("BillboardGui")
        gui.Name = "SempatPanickOnsenESP"
        gui.Size = UDim2.fromOffset(160, 34)
        gui.StudsOffset = Vector3.new(0, 2.5, 0)
        gui.AlwaysOnTop = true
        gui.Adornee = adornee
        local lbl = Instance.new("TextLabel")
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.fromScale(1, 1)
        lbl.Font = Enum.Font.GothamBold
        lbl.TextColor3 = color
        lbl.TextStrokeTransparency = 0
        lbl.TextScaled = true
        lbl.Text = kind
        lbl.Parent = gui
        gui.Parent = adornee

        espState[inst] = { highlight = hl, label = gui, adornee = adornee, kind = kind }
    end

    local function syncEsp()
        local active = {}
        local function scan(folder, color, kind)
            if not folder then
                return
            end
            for _, child in ipairs(folder:GetChildren()) do
                active[child] = true
                ensureEsp(child, color, kind)
            end
        end
        if dropEspEnabled then
            scan(getWorkspaceFolderByConfig("Drop"), Color3.fromRGB(120, 220, 120), "Drop")
        end
        if chestEspEnabled then
            scan(getWorkspaceFolderByConfig("Chest"), Color3.fromRGB(255, 200, 80), "Chest")
        end
        for inst, st in pairs(espState) do
            if not active[inst] or not inst.Parent then
                destroyEspEntry(st)
                espState[inst] = nil
            end
        end
    end

    local function updateEspDistances()
        local root = getLocalRoot()
        for _, st in pairs(espState) do
            local lbl = st.label and st.label:FindFirstChildWhichIsA("TextLabel")
            if lbl and st.adornee and st.adornee.Parent then
                if root then
                    lbl.Text = string.format("%s · %.0fm", st.kind, (root.Position - st.adornee.Position).Magnitude)
                else
                    lbl.Text = st.kind
                end
            end
        end
    end

    local lastEspSync = 0
    local function setEspRender()
        if dropEspEnabled or chestEspEnabled then
            if not espRenderConn then
                lastEspSync = 0
                espRenderConn = RunService.RenderStepped:Connect(function()
                    updateEspDistances()
                    local now = os.clock()
                    if now - lastEspSync >= 0.5 then
                        lastEspSync = now
                        syncEsp()
                    end
                end)
            end
        else
            if espRenderConn then
                espRenderConn:Disconnect()
                espRenderConn = nil
            end
            clearEsp()
        end
    end

    -- R3 — chest reward log paragraph
    local function refreshRewardLog()
        if not (rewardParagraph and rewardParagraph.Set) then
            return
        end
        local lines = {}
        table.insert(
            lines,
            string.format(
                "Opened: %d · Total: %s · Best: %s",
                chestRewardLog.count,
                formatNumber(chestRewardLog.totalValue),
                chestRewardLog.count > 0 and chestRarityName(chestRewardLog.bestRarity) or "—"
            )
        )
        if #chestRewardLog.entries == 0 then
            table.insert(lines, "No chests opened this session yet.")
        else
            for _, e in ipairs(chestRewardLog.entries) do
                table.insert(lines, string.format("• %s — %s", chestRarityName(e.rarity), formatNumber(e.value)))
            end
        end
        rewardParagraph:Set({ Content = table.concat(lines, "\n") })
    end

    -- I1 — global leaderboard
    local function refreshLeaderboard()
        if not (leaderboardParagraph and leaderboardParagraph.Set) then
            return
        end
        local remote = getRemote("GetGlobalLeaderboard")
        if not remote then
            leaderboardParagraph:Set({ Content = "Leaderboard remote not ready…" })
            return
        end
        local ok, result = pcall(function()
            return remote:InvokeServer()
        end)
        if not ok or type(result) ~= "table" then
            leaderboardParagraph:Set({ Content = "Leaderboard unavailable." })
            return
        end
        local lines = {}
        for i, entry in ipairs(result) do
            if i > 10 then
                break
            end
            local name = "?"
            local value = 0
            if type(entry) == "table" then
                name = entry.Name or entry.name or entry.DisplayName or "?"
                value = entry.Value or entry.value or entry.Amount or entry.TotalEarned or 0
            end
            table.insert(lines, string.format("%d. %s — %s", i, tostring(name), formatNumber(value)))
        end
        if #lines == 0 then
            leaderboardParagraph:Set({ Content = "Leaderboard is empty." })
        else
            leaderboardParagraph:Set({ Content = table.concat(lines, "\n") })
        end
    end

    MainTab:CreateSection("Status")

    statusParagraph = MainTab:CreateParagraph({
        Title = "Onsen",
        Content = "Loading game data…",
    })

    MainTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            bindDropChestTracking()
            refreshData()
            mountNotify({ Title = "Capybara Onsen", Content = "Refreshed" })
        end,
    })

    MainTab:CreateSection("Yuzu Market / Deposit")

    MainTab:CreateButton({
        Name = "Deposit Now (ignore rate)",
        Callback = function()
            local ok, info = depositCarryOnce(autoDepositReturn, true)
            if ok then
                mountNotify({ Title = "Deposit", Content = info and string.format("Deposited at rate %.2f", info) or "Deposited" })
            else
                mountNotify({ Title = "Deposit", Content = "Failed: " .. tostring(info) })
            end
        end,
    })

    MainTab:CreateButton({
        Name = "Check Market Rate",
        Callback = function()
            local rate = getMarketRate()
            mountNotify({
                Title = "Yuzu Market",
                Content = rate and string.format("Current rate: %.2f (min %.2f)", rate, minDepositRate) or "Market closed / rate unknown",
            })
        end,
    })

    MainTab:CreateToggle({
        Name = "Only Deposit When Rate >= Min",
        Flag = "co_gate_deposit_rate",
        CurrentValue = true,
        Callback = function(enabled)
            gateDepositByRate = enabled == true
        end,
    })

    do
        local minMult, maxMult = getMarketRateBounds()
        if minDepositRate < minMult then
            minDepositRate = minMult
        elseif minDepositRate > maxMult then
            minDepositRate = maxMult
        end
        MainTab:CreateSlider({
            Name = "Min Deposit Rate",
            Flag = "co_min_deposit_rate",
            Range = { minMult, maxMult },
            Increment = 0.05,
            Suffix = "x",
            CurrentValue = minDepositRate,
            Callback = function(value)
                local parsed = tonumber(value) or (type(value) == "table" and tonumber(value[1]))
                if parsed then
                    minDepositRate = math.clamp(parsed, minMult, maxMult)
                end
            end,
        })
    end

    MainTab:CreateSlider({
        Name = "Auto Deposit Interval",
        Flag = "co_deposit_interval",
        Range = { 0.5, 30 },
        Increment = 0.5,
        Suffix = "s",
        CurrentValue = autoDepositIntervalSec,
        Callback = function(value)
            local parsed = tonumber(value) or (type(value) == "table" and tonumber(value[1]))
            if parsed then
                autoDepositIntervalSec = math.clamp(parsed, 0.5, 30)
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Return After Deposit",
        Flag = "co_deposit_return",
        CurrentValue = true,
        Callback = function(enabled)
            autoDepositReturn = enabled == true
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Deposit Carry",
        Flag = "co_auto_deposit",
        CurrentValue = false,
        Callback = function(enabled)
            autoDepositEnabled = enabled == true
            autoDepositToken += 1
            if not autoDepositEnabled then
                return
            end
            local myToken = autoDepositToken
            task.spawn(function()
                runAutoDepositLoop(myToken)
            end)
            mountNotify({ Title = "Auto Deposit", Content = "Started" })
        end,
    })

    MainTab:CreateSection("Collect Cash")

    MainTab:CreateButton({
        Name = "Collect Cash Now",
        Callback = function()
            refreshData()
            local ok, info = collectCashOnce(autoCollectCashReturn, true)
            if ok then
                mountNotify({ Title = "Collect Cash", Content = "Collected pending cash" })
            else
                mountNotify({ Title = "Collect Cash", Content = "Failed: " .. tostring(info) })
            end
        end,
    })

    MainTab:CreateSlider({
        Name = "Auto Collect Interval",
        Flag = "co_collect_cash_interval",
        Range = { 0.5, 30 },
        Increment = 0.5,
        Suffix = "s",
        CurrentValue = autoCollectCashIntervalSec,
        Callback = function(value)
            local parsed = tonumber(value) or (type(value) == "table" and tonumber(value[1]))
            if parsed then
                autoCollectCashIntervalSec = math.clamp(parsed, 0.5, 30)
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Teleport To Collect",
        Flag = "co_collect_cash_teleport",
        CurrentValue = false,
        Callback = function(enabled)
            autoCollectCashUseTeleport = enabled == true
        end,
    })

    MainTab:CreateToggle({
        Name = "Return After Collect",
        Flag = "co_collect_cash_return",
        CurrentValue = true,
        Callback = function(enabled)
            autoCollectCashReturn = enabled == true
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Collect Cash",
        Flag = "co_auto_collect_cash",
        CurrentValue = false,
        Callback = function(enabled)
            autoCollectCashEnabled = enabled == true
            autoCollectCashToken += 1
            if not autoCollectCashEnabled then
                return
            end
            local myToken = autoCollectCashToken
            task.spawn(function()
                runAutoCollectCashLoop(myToken)
            end)
            mountNotify({ Title = "Auto Collect Cash", Content = "Started (touch Cashier pad when pending > 0)" })
        end,
    })

    MainTab:CreateSection("Cash Drops")

    autoLootDelaySlider = MainTab:CreateSlider({
        Name = "Auto Loot Delay",
        Flag = "co_auto_loot_delay",
        Range = { 0.05, 30 },
        Increment = 0.05,
        Suffix = "s",
        CurrentValue = autoLootDelaySec,
        Callback = function(value)
            local parsed = tonumber(value)
            if not parsed and type(value) == "table" then
                parsed = tonumber(value[1])
            end
            if parsed then
                autoLootDelaySec = math.clamp(parsed, 0.05, 30)
            end
        end,
    })

    MainTab:CreateButton({
        Name = "Loot All Drops Now",
        Callback = function()
            bindDropChestTracking()
            local fired = lootAllDrops()
            mountNotify({ Title = "Loot", Content = "Fired pickup on " .. tostring(fired) .. " drop(s)" })
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Loot Drops",
        Flag = "co_auto_loot",
        CurrentValue = false,
        Callback = function(enabled)
            autoLootEnabled = enabled == true
            autoLootToken += 1
            if not autoLootEnabled then
                return
            end
            bindDropChestTracking()
            local myToken = autoLootToken
            task.spawn(function()
                runAutoLootLoop(myToken)
            end)
            mountNotify({ Title = "Auto Loot", Content = "Started" })
        end,
    })

    MainTab:CreateSection("Chests")

    MainTab:CreateButton({
        Name = "Pickup All Chests Now",
        Callback = function()
            bindDropChestTracking()
            local fired = pickupAllChests()
            mountNotify({ Title = "Chests", Content = "Fired pickup on " .. tostring(fired) .. " chest(s)" })
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Pickup Chests",
        Flag = "co_auto_chest_pickup",
        CurrentValue = false,
        Callback = function(enabled)
            autoChestPickupEnabled = enabled == true
            autoChestPickupToken += 1
            if not autoChestPickupEnabled then
                return
            end
            bindDropChestTracking()
            local myToken = autoChestPickupToken
            task.spawn(function()
                runAutoChestPickupLoop(myToken)
            end)
            mountNotify({ Title = "Auto Chest", Content = "Started" })
        end,
    })

    MainTab:CreateButton({
        Name = "Open Held Chest Now",
        Callback = function()
            local ok, err = fireServer("ChestOpen")
            mountNotify({ Title = "Chest", Content = ok and "Open requested" or ("Failed: " .. tostring(err)) })
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Open Held Chest",
        Flag = "co_auto_open_chest",
        CurrentValue = false,
        Callback = function(enabled)
            autoOpenChestEnabled = enabled == true
            autoOpenChestToken += 1
            if not autoOpenChestEnabled then
                return
            end
            local myToken = autoOpenChestToken
            task.spawn(function()
                runAutoOpenChestLoop(myToken)
            end)
            mountNotify({ Title = "Auto Open", Content = "Started (opens when a chest is held)" })
        end,
    })

    MainTab:CreateButton({
        Name = "Discard Held Chest",
        Callback = function()
            local ok, err = fireServer("ChestDiscard")
            mountNotify({ Title = "Chest", Content = ok and "Discard requested" or ("Failed: " .. tostring(err)) })
        end,
    })

    MainTab:CreateSlider({
        Name = "Min Rarity To Auto-Open",
        Flag = "co_min_open_rarity",
        Range = { 0, 20 },
        Increment = 1,
        Suffix = "",
        CurrentValue = minOpenRarity,
        Callback = function(value)
            local parsed = tonumber(value) or (type(value) == "table" and tonumber(value[1]))
            if parsed then
                minOpenRarity = math.max(0, math.floor(parsed))
            end
        end,
    })

    MainTab:CreateButton({
        Name = "Open Until Empty (affordable)",
        Callback = function()
            task.spawn(function()
                local opened = 0
                for _ = 1, 50 do
                    refreshData()
                    local ok = tryOpenHeldChest(false)
                    if not ok then
                        break
                    end
                    opened += 1
                    task.wait(0.35)
                end
                mountNotify({ Title = "Chest", Content = "Opened " .. tostring(opened) .. " chest(s)" })
            end)
        end,
    })

    rewardParagraph = MainTab:CreateParagraph({
        Title = "Chest Rewards (session)",
        Content = "No chests opened this session yet.",
    })

    MainTab:CreateSection("Offline Reward")

    MainTab:CreateButton({
        Name = "Claim Offline Reward Now",
        Callback = function()
            local ok, err = fireServer("ClaimOfflineReward")
            mountNotify({ Title = "Offline", Content = ok and "Claim requested" or ("Failed: " .. tostring(err)) })
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Claim Offline Reward",
        Flag = "co_auto_claim_offline",
        CurrentValue = false,
        Callback = function(enabled)
            autoClaimOfflineEnabled = enabled == true
            autoClaimOfflineToken += 1
            if not autoClaimOfflineEnabled then
                return
            end
            local myToken = autoClaimOfflineToken
            task.spawn(function()
                runAutoClaimOfflineLoop(myToken)
            end)
            mountNotify({ Title = "Auto Offline", Content = "Started" })
        end,
    })

    MainTab:CreateSection("Auto Buy Capybara")

    MainTab:CreateDropdown({
        Name = "Buy Amounts",
        Flag = "co_buy_capybara_amounts",
        Options = { "1", "5", "25", "100" },
        CurrentOption = { "1" },
        MultipleOptions = true,
        Callback = function(value)
            local selected = {}
            if type(value) == "table" then
                for _, entry in ipairs(value) do
                    local label = tostring(entry)
                    if label == "1" or label == "5" or label == "25" or label == "100" then
                        selected[label] = true
                    end
                end
            elseif type(value) == "string" then
                if value == "1" or value == "5" or value == "25" or value == "100" then
                    selected[value] = true
                end
            end
            autoBuyCapybaraSelected = selected
        end,
    })

    MainTab:CreateButton({
        Name = "Buy Capybara Now",
        Callback = function()
            local ok, info = tryBuyCapybaraOnce(autoBuyCapybaraReturn)
            if ok then
                mountNotify({
                    Title = "Buy Capybara",
                    Content = string.format("Bought %s (cost %s)", info.label, formatNumber(info.cost)),
                })
            else
                mountNotify({ Title = "Buy Capybara", Content = tostring(info) })
            end
        end,
    })

    MainTab:CreateSlider({
        Name = "Auto Buy Interval",
        Flag = "co_buy_capybara_interval",
        Range = { 0.1, 10 },
        Increment = 0.1,
        Suffix = "s",
        CurrentValue = autoBuyCapybaraIntervalSec,
        Callback = function(value)
            local parsed = tonumber(value) or (type(value) == "table" and tonumber(value[1]))
            if parsed then
                autoBuyCapybaraIntervalSec = math.clamp(parsed, 0.1, 10)
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Return After Buy",
        Flag = "co_buy_capybara_return",
        CurrentValue = true,
        Callback = function(enabled)
            autoBuyCapybaraReturn = enabled == true
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Buy Capybara",
        Flag = "co_auto_buy_capybara",
        CurrentValue = false,
        Callback = function(enabled)
            autoBuyCapybaraEnabled = enabled == true
            autoBuyCapybaraToken += 1
            if not autoBuyCapybaraEnabled then
                return
            end
            if next(autoBuyCapybaraSelected) == nil then
                mountNotify({ Title = "Auto Buy Capybara", Content = "Select at least one amount first" })
                return
            end
            local myToken = autoBuyCapybaraToken
            task.spawn(function()
                runAutoBuyCapybaraLoop(myToken)
            end)
            mountNotify({ Title = "Auto Buy Capybara", Content = "Started (highest affordable amount first)" })
        end,
    })

    MainTab:CreateSection("Auto Buy Tiers")

    MainTab:CreateButton({
        Name = "Upgrade Tier Now",
        Callback = function()
            local ok, info = tryUpgradeTierOnce(autoBuyReturn, true)
            if ok then
                mountNotify({ Title = "Tier Upgrade", Content = "Requested upgrade to tier " .. tostring(info) })
            else
                mountNotify({ Title = "Tier Upgrade", Content = tostring(info) })
            end
        end,
    })

    MainTab:CreateSlider({
        Name = "Auto Buy Interval",
        Flag = "co_buy_interval",
        Range = { 0.5, 30 },
        Increment = 0.5,
        Suffix = "s",
        CurrentValue = autoBuyIntervalSec,
        Callback = function(value)
            local parsed = tonumber(value) or (type(value) == "table" and tonumber(value[1]))
            if parsed then
                autoBuyIntervalSec = math.clamp(parsed, 0.5, 30)
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Return After Upgrade",
        Flag = "co_buy_return",
        CurrentValue = true,
        Callback = function(enabled)
            autoBuyReturn = enabled == true
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Upgrade Tier",
        Flag = "co_auto_buy",
        CurrentValue = false,
        Callback = function(enabled)
            autoBuyEnabled = enabled == true
            autoBuyToken += 1
            if not autoBuyEnabled then
                return
            end
            local myToken = autoBuyToken
            task.spawn(function()
                runAutoBuyLoop(myToken)
            end)
            mountNotify({ Title = "Auto Upgrade", Content = "Started (upgrades when affordable)" })
        end,
    })

    MainTab:CreateSection("ESP")

    MainTab:CreateToggle({
        Name = "ESP Drops",
        Flag = "co_esp_drops",
        CurrentValue = false,
        Callback = function(enabled)
            dropEspEnabled = enabled == true
            setEspRender()
        end,
    })

    MainTab:CreateToggle({
        Name = "ESP Chests",
        Flag = "co_esp_chests",
        CurrentValue = false,
        Callback = function(enabled)
            chestEspEnabled = enabled == true
            setEspRender()
        end,
    })

    MainTab:CreateSection("Teleports")

    local function teleportToNearest(map, kindLabel)
        return runExclusiveTravel(function()
            local root = getLocalRoot()
            if not root then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
                return false
            end
            local bestPos, bestDist = nil, math.huge
            for _, info in pairs(map) do
                local pos = info.pos
                if typeof(pos) == "Vector3" then
                    local d = (root.Position - pos).Magnitude
                    if d < bestDist then
                        bestDist = d
                        bestPos = pos
                    end
                end
            end
            if bestPos then
                teleportToPosition(bestPos, 3)
                mountNotify({ Title = "Teleport", Content = "To nearest " .. kindLabel })
                return true
            end
            mountNotify({ Title = "Teleport", Content = "No " .. kindLabel .. " tracked" })
            return false
        end, { restoreAfter = false })
    end

    MainTab:CreateButton({
        Name = "To Cashier",
        Callback = function()
            local ok = runExclusiveTravel(function()
                return teleportToPart(getCashierPad(), 3)
            end, { restoreAfter = false })
            mountNotify({ Title = "Teleport", Content = ok and "To cashier" or "Cashier not found" })
        end,
    })

    MainTab:CreateButton({
        Name = "To Tower",
        Callback = function()
            local ok = runExclusiveTravel(function()
                return teleportToPart(getTowerPart(), 4)
            end, { restoreAfter = false })
            mountNotify({ Title = "Teleport", Content = ok and "To tower" or "Tower not found" })
        end,
    })

    MainTab:CreateButton({
        Name = "To Plot Center",
        Callback = function()
            local ok = runExclusiveTravel(function()
                local plot = resolvePlot()
                if not plot then
                    return false
                end
                local okPivot, pivot = pcall(function()
                    return plot:GetPivot()
                end)
                if not (okPivot and pivot) then
                    return false
                end
                return teleportToPosition(pivot.Position, 5)
            end, { restoreAfter = false })
            mountNotify({ Title = "Teleport", Content = ok and "To plot center" or "Plot not found" })
        end,
    })

    MainTab:CreateButton({
        Name = "To Nearest Drop",
        Callback = function()
            teleportToNearest(activeDrops, "drop")
        end,
    })

    MainTab:CreateButton({
        Name = "To Nearest Chest",
        Callback = function()
            teleportToNearest(activeChests, "chest")
        end,
    })

    MainTab:CreateSection("Game Settings")

    local settingsBuilt = false
    local function buildSettingsControls()
        if settingsBuilt then
            return true
        end
        local spec = getSettingsSpec()
        if not (spec and type(spec.Order) == "table" and type(spec.Items) == "table") then
            return false
        end
        settingsBuilt = true
        local data = lastData or refreshData()
        local current = (data and type(data.Settings) == "table") and data.Settings or {}
        for _, key in ipairs(spec.Order) do
            local item = spec.Items[key]
            if type(item) == "table" then
                local label = tostring(item.label or item.Label or item.name or key)
                if item.kind == "audio" then
                    MainTab:CreateSlider({
                        Name = label,
                        Flag = "co_set_" .. tostring(key),
                        Range = { 0, 1 },
                        Increment = 0.05,
                        Suffix = "",
                        CurrentValue = tonumber(current[key]) or 0.5,
                        Callback = function(value)
                            local parsed = tonumber(value) or (type(value) == "table" and tonumber(value[1]))
                            if parsed then
                                fireServer("SetSetting", key, parsed)
                            end
                        end,
                    })
                else
                    MainTab:CreateToggle({
                        Name = label,
                        Flag = "co_set_" .. tostring(key),
                        CurrentValue = current[key] == true,
                        Callback = function(enabled)
                            fireServer("SetSetting", key, enabled == true)
                        end,
                    })
                end
            end
        end
        return true
    end

    MainTab:CreateButton({
        Name = "Load Settings Controls",
        Callback = function()
            if buildSettingsControls() then
                mountNotify({ Title = "Settings", Content = "Loaded in-game settings" })
            else
                mountNotify({ Title = "Settings", Content = "SettingsSpec not ready yet" })
            end
        end,
    })

    MainTab:CreateSection("Leaderboard")

    leaderboardParagraph = MainTab:CreateParagraph({
        Title = "Global Leaderboard",
        Content = "Press Refresh to load…",
    })

    MainTab:CreateButton({
        Name = "Refresh Leaderboard",
        Callback = function()
            refreshLeaderboard()
        end,
    })

    MainTab:CreateSection("Tutorial")

    MainTab:CreateButton({
        Name = "Advance Tutorial Step",
        Callback = function()
            local ok, err = fireServer("TutorialRequestProgress")
            mountNotify({ Title = "Tutorial", Content = ok and "Requested next step" or ("Failed: " .. tostring(err)) })
        end,
    })

    MainTab:CreateSection("Rejoin Farm (offline reward)")

    MainTab:CreateToggle({
        Name = "Prevent Rejoin",
        Flag = "co_prevent_rejoin",
        CurrentValue = false,
        Callback = function(enabled)
            setPreventRejoinEnabled(enabled == true)
            mountNotify({
                Title = "Prevent Rejoin",
                Content = preventRejoinEnabled and "Idle rejoin blocked" or "Idle rejoin allowed",
            })
        end,
    })

    MainTab:CreateButton({
        Name = "Rejoin Now",
        Callback = function()
            if preventRejoinEnabled then
                mountNotify({ Title = "Rejoin", Content = "Disable Prevent Rejoin first" })
                return
            end
            mountNotify({ Title = "Rejoin", Content = "Rejoining…" })
            doRejoin()
        end,
    })

    MainTab:CreateSlider({
        Name = "Auto Rejoin Interval",
        Flag = "co_rejoin_interval",
        Range = { 60, 3600 },
        Increment = 30,
        Suffix = "s",
        CurrentValue = autoRejoinIntervalSec,
        Callback = function(value)
            local parsed = tonumber(value) or (type(value) == "table" and tonumber(value[1]))
            if parsed then
                autoRejoinIntervalSec = math.clamp(parsed, 60, 3600)
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Rejoin",
        Flag = "co_auto_rejoin",
        CurrentValue = false,
        Callback = function(enabled)
            if enabled and preventRejoinEnabled then
                mountNotify({ Title = "Auto Rejoin", Content = "Disable Prevent Rejoin first" })
                return
            end
            autoRejoinEnabled = enabled == true
            autoRejoinToken += 1
            if not autoRejoinEnabled then
                return
            end
            local myToken = autoRejoinToken
            task.spawn(function()
                runAutoRejoinLoop(myToken)
            end)
            mountNotify({ Title = "Auto Rejoin", Content = "Started (verify offline reward accrues!)" })
        end,
    })

    MainTab:CreateSection("Misc")

    MainTab:CreateButton({
        Name = "Go Home (Teleport To Plot)",
        Callback = function()
            local ok, err = fireServer("GoHome")
            mountNotify({ Title = "Go Home", Content = ok and "Teleporting home" or ("Failed: " .. tostring(err)) })
        end,
    })

    -- */  Init  /* --
    task.spawn(function()
        local deadline = os.clock() + 20
        while os.clock() < deadline do
            if resolveRemotes() then
                break
            end
            task.wait(0.25)
        end
        bindDropChestTracking()
        refreshData()
        refreshRewardLog()
        -- Try to auto-build in-game settings controls once SettingsSpec is available.
        for _ = 1, 20 do
            if buildSettingsControls() then
                break
            end
            task.wait(0.5)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(2)
            bindDropChestTracking()
            refreshData()
            refreshRewardLog()
        end
    end)
end

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "capybara_onsen", tabIcon = "map-pin" })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, {
    replicatedStorage = ReplicatedStorage,
    tabIcon = "boxes",
})

-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, {
    gamePath = "sempatpanick/capybara_onsen",
    tabIcon = "video",
})

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/capybara_onsen",
    rayfieldLibrary = SempatLibrary,
    tabIcon = "settings",
})
