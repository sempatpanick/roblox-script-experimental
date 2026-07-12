local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace = game:GetService("Workspace")

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
            assert(okGet and type(source) == "string", "[sempat/sell_lemons] failed to load sempat_library")
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
local Window = SempatLibrary:CreateWindow({
    Name = "sempatpanick | Sell Lemons",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Sempat UI • Sell Lemons",
    ToggleUIKeybind = "K",
    WindowTransparency = 30,
    Icon = "https://dadang.id/sempatpanick-icon.png",
    ConfigurationSaving = {
        Enabled = true,
        AutoSave = false,
        AutoLoad = false,
        FolderName = "sempatpanick",
        FileName = "sell_lemons",
    },
})


-- */  Local Player Tab  /* --
createLocalPlayerTab(Window, mountNotify, { flagsPrefix = "lp", tabIcon = "user" })

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", "citrus")

    local autoPurchaseRunning = false
    local autoPurchaseLoopId = 0
    local autoPurchaseDelaySec = 0.5
    local purchaseListAutoRefreshSec = 1
    local playerInfoParagraph
    local purchaseListParagraph
    local refreshInProgress = false

    local autoUpgradeRunning = false
    local autoUpgradeLoopId = 0
    local autoUpgradeDelaySec = 0.5
    local upgradeListAutoRefreshSec = 1
    local upgradeListParagraph
    local upgradeRefreshInProgress = false

    local autoClaimCashRunning = false
    local autoClaimCashLoopId = 0
    local autoClaimCashDelaySec = 0.5

    local rebirthInfoParagraph
    local rebirthTargetPercent = 1000
    local rebirthInfoAutoRefreshSec = 1
    local autoRebirthRunning = false
    local autoRebirthLoopId = 0
    local autoRebirthDelaySec = 1

    local evolutionInfoParagraph
    local evolutionInfoAutoRefreshSec = 1
    local autoEvolveRunning = false
    local autoEvolveLoopId = 0
    local autoEvolveDelaySec = 1
    local autoEvolveStartingBonusTarget = "0"

    local autoPickFruitRunning = false
    local autoPickFruitLoopId = 0
    local autoPickFruitDelaySec = 5
    local autoPickFruitMode = "Normal"
    local autoPickFruitNearbyClickDelaySec = 0.25
    local autoPickFruitTeleportStaySec = 2.5
    local autoPickFruitTeleportTreeIndex = 0
    local AUTO_PICK_FRUIT_MODES = { "Normal", "Nearby", "Nearby with Teleport" }

    local function rayfieldDropdownFirst(valueOrTable)
        if type(valueOrTable) == "table" then
            return valueOrTable[1]
        end
        return valueOrTable
    end

    local autoPickCashDropRunning = false
    local autoPickCashDropLoopId = 0
    local autoPickCashDropDelaySec = 0.5

    local autoAcceptOfferRunning = false
    local autoAcceptOfferLoopId = 0
    local autoAcceptOfferDelaySec = 0.5

    local autoBuyPowersRunning = false
    local autoBuyPowersLoopId = 0
    local autoBuyPowersDelaySec = 120

    local lastPurchaseSnapshot = {
        title = "Buyable Buttons",
        content = "Loading...",
        count = 0,
        icon = nil,
    }

    local cachedBalance = nil
    local cachedHuge = nil
    local cachedPurchaseOrderRank = nil
    local cachedLocalTycoonInstance = nil
    local cachedOptionalCtx = nil

    local MODULE_PATHS = {
        Balance = { "Balance" },
        Huge = { "Modules", "Huge" },
        Entity = { "Core", "Entity" },
        LocalTycoon = { "Modules", "Tycoon", "LocalTycoon" },
        ClientTycoonPurchase = { "Modules", "Tycoon", "Entity", "Client", "ClientTycoonPurchase" },
        ClientTycoonBalances = { "Modules", "Tycoon", "Component", "Client", "ClientTycoonBalances" },
        ClientTycoonRebirth = { "Modules", "Tycoon", "Component", "Client", "ClientTycoonRebirth" },
        ClientTycoonEvolution = { "Modules", "Tycoon", "Component", "Client", "ClientTycoonEvolution" },
        ClientTycoonAscension = { "Modules", "Tycoon", "Component", "Client", "ClientTycoonAscension" },
        ClientTycoonPowers = { "Modules", "Tycoon", "Component", "Client", "ClientTycoonPowers" },
        ClientTycoonOfflineIncome = { "Modules", "Tycoon", "Component", "Client", "ClientTycoonOfflineIncome" },
        LocalPlayer = { "Core", "LocalPlayer" },
        PremiumPurchases = { "Modules", "Player", "PremiumPurchases" },
        Config = { "Config" },
        Orchard = { "Modules", "Tycoon", "Orchard", "Orchard" },
        OrchardPlot = { "Modules", "Tycoon", "Orchard", "OrchardPlot" },
        OrchardFruits = { "Modules", "Tycoon", "Orchard", "OrchardFruits" },
        OrchardItems = { "Modules", "Tycoon", "Orchard", "OrchardItems" },
        OrchardPlots = { "Modules", "Tycoon", "Orchard", "OrchardPlots" },
        OrchardDecorations = { "Modules", "Tycoon", "Orchard", "OrchardDecorations" },
        OrchardEatFruit = { "Modules", "Tycoon", "Orchard", "OrchardEatFruit" },
        OrchardAutoEatFruitPower = { "Modules", "Tycoon", "Orchard", "OrchardAutoEatFruitPower" },
        ClientOrchard = { "Modules", "Tycoon", "Orchard", "Client", "ClientOrchard" },
        ClientOrchardPlot = { "Modules", "Tycoon", "Orchard", "Client", "ClientOrchardPlot" },
        ClientOrchardPlots = { "Modules", "Tycoon", "Orchard", "Client", "ClientOrchardPlots" },
        ClientOrchardItems = { "Modules", "Tycoon", "Orchard", "Client", "ClientOrchardItems" },
        ClientOrchardFruits = { "Modules", "Tycoon", "Orchard", "Client", "ClientOrchardFruits" },
        ClientOrchardEatFruit = { "Modules", "Tycoon", "Orchard", "Client", "ClientOrchardEatFruit" },
        ClientOrchardAutoEatFruitPower = { "Modules", "Tycoon", "Orchard", "Client", "ClientOrchardAutoEatFruitPower" },
        ClientOrchardDecorations = { "Modules", "Tycoon", "Orchard", "Client", "ClientOrchardDecorations" },
    }

    local function resolveModuleScript(pathParts)
        local cursor = ReplicatedStorage
        for _, part in ipairs(pathParts) do
            cursor = cursor and cursor:FindFirstChild(part)
        end
        if cursor and cursor:IsA("ModuleScript") then
            return cursor
        end
        return nil
    end

    local function tryRequirePath(pathParts)
        local moduleScript = resolveModuleScript(pathParts)
        if not moduleScript then
            return nil
        end
        local ok, result = pcall(require, moduleScript)
        if ok then
            return result
        end
        return nil
    end

    local function ensureBalanceLoaded()
        if cachedBalance then
            return cachedBalance
        end
        local balance = tryRequirePath(MODULE_PATHS.Balance)
        if not balance then
            return nil
        end
        cachedBalance = balance
        cachedPurchaseOrderRank = {}
        if type(balance.PurchaseOrder) == "table" then
            for index, purchaseName in ipairs(balance.PurchaseOrder) do
                cachedPurchaseOrderRank[purchaseName] = index
            end
        end
        return cachedBalance
    end

    local function ensureHugeLoaded()
        if cachedHuge then
            return cachedHuge
        end
        cachedHuge = tryRequirePath(MODULE_PATHS.Huge)
        return cachedHuge
    end

    local function ensureOptionalPurchaseCtx()
        if cachedOptionalCtx then
            return cachedOptionalCtx
        end
        cachedOptionalCtx = {
            Entity = tryRequirePath(MODULE_PATHS.Entity),
            LocalTycoon = tryRequirePath(MODULE_PATHS.LocalTycoon),
            ClientTycoonPurchase = tryRequirePath(MODULE_PATHS.ClientTycoonPurchase),
            ClientTycoonBalances = tryRequirePath(MODULE_PATHS.ClientTycoonBalances),
            ClientTycoonRebirth = tryRequirePath(MODULE_PATHS.ClientTycoonRebirth),
            ClientTycoonEvolution = tryRequirePath(MODULE_PATHS.ClientTycoonEvolution),
            ClientTycoonAscension = tryRequirePath(MODULE_PATHS.ClientTycoonAscension),
            ClientTycoonPowers = tryRequirePath(MODULE_PATHS.ClientTycoonPowers),
            ClientTycoonOfflineIncome = tryRequirePath(MODULE_PATHS.ClientTycoonOfflineIncome),
            LocalPlayer = tryRequirePath(MODULE_PATHS.LocalPlayer),
            PremiumPurchases = tryRequirePath(MODULE_PATHS.PremiumPurchases),
            Config = tryRequirePath(MODULE_PATHS.Config),
            Orchard = tryRequirePath(MODULE_PATHS.ClientOrchard) or tryRequirePath(MODULE_PATHS.Orchard),
            OrchardPlot = tryRequirePath(MODULE_PATHS.ClientOrchardPlot) or tryRequirePath(MODULE_PATHS.OrchardPlot),
            OrchardFruits = tryRequirePath(MODULE_PATHS.ClientOrchardFruits) or tryRequirePath(MODULE_PATHS.OrchardFruits),
            OrchardItems = tryRequirePath(MODULE_PATHS.ClientOrchardItems) or tryRequirePath(MODULE_PATHS.OrchardItems),
            OrchardPlots = tryRequirePath(MODULE_PATHS.ClientOrchardPlots) or tryRequirePath(MODULE_PATHS.OrchardPlots),
            OrchardDecorations = tryRequirePath(MODULE_PATHS.ClientOrchardDecorations) or tryRequirePath(MODULE_PATHS.OrchardDecorations),
            OrchardEatFruit = tryRequirePath(MODULE_PATHS.ClientOrchardEatFruit) or tryRequirePath(MODULE_PATHS.OrchardEatFruit),
            OrchardAutoEatFruitPower = tryRequirePath(MODULE_PATHS.ClientOrchardAutoEatFruitPower)
                or tryRequirePath(MODULE_PATHS.OrchardAutoEatFruitPower),
        }
        return cachedOptionalCtx
    end

    local function getSellLemonsGameContext(includeEntities)
        local balance = ensureBalanceLoaded()
        if not balance then
            return nil, "Could not load Balance module."
        end
        ensureHugeLoaded()

        local ctx = {
            Balance = balance,
            Huge = cachedHuge,
        }
        if includeEntities then
            local optional = ensureOptionalPurchaseCtx()
            ctx.Entity = optional.Entity
            ctx.LocalTycoon = optional.LocalTycoon
            ctx.ClientTycoonPurchase = optional.ClientTycoonPurchase
            ctx.ClientTycoonBalances = optional.ClientTycoonBalances
            ctx.ClientTycoonRebirth = optional.ClientTycoonRebirth
            ctx.ClientTycoonEvolution = optional.ClientTycoonEvolution
            ctx.ClientTycoonAscension = optional.ClientTycoonAscension
            ctx.ClientTycoonPowers = optional.ClientTycoonPowers
            ctx.ClientTycoonOfflineIncome = optional.ClientTycoonOfflineIncome
            ctx.LocalPlayer = optional.LocalPlayer
            ctx.PremiumPurchases = optional.PremiumPurchases
            ctx.Config = optional.Config
            ctx.Orchard = optional.Orchard
            ctx.OrchardPlot = optional.OrchardPlot
            ctx.OrchardFruits = optional.OrchardFruits
            ctx.OrchardItems = optional.OrchardItems
            ctx.OrchardPlots = optional.OrchardPlots
            ctx.OrchardDecorations = optional.OrchardDecorations
            ctx.OrchardEatFruit = optional.OrchardEatFruit
            ctx.OrchardAutoEatFruitPower = optional.OrchardAutoEatFruitPower
        end
        return ctx
    end

    local function prettifyPurchaseName(name)
        if type(name) ~= "string" or name == "" then
            return "?"
        end
        local pretty = name:gsub("(%l)(%u)", "%1 %2")
        pretty = pretty:gsub("(%a)(%d)", "%1 %2")
        return pretty
    end

    local function alphanumericName(name)
        if type(name) ~= "string" then
            return ""
        end
        return name:gsub("[^%w]", "")
    end

    local function formatPurchasePrice(ctx, price)
        if price == nil or price == 0 then
            return "Free"
        end
        if ctx.Huge and type(ctx.Huge.formatAbbreviated) == "function" then
            local ok, text = pcall(function()
                return ctx.Huge.formatAbbreviated(price, "$")
            end)
            if ok and type(text) == "string" and #text > 0 then
                return text
            end
        end
        return "$" .. tostring(price)
    end

    local function findLocalTycoonInstance()
        if cachedLocalTycoonInstance and cachedLocalTycoonInstance.Parent then
            local ownerValue = cachedLocalTycoonInstance:FindFirstChild("Owner")
            if ownerValue
                and ownerValue:IsA("ObjectValue")
                and ownerValue.Value == Players.LocalPlayer then
                return cachedLocalTycoonInstance
            end
        end

        cachedLocalTycoonInstance = nil
        for _, tycoonInstance in CollectionService:GetTagged("Tycoon") do
            local ownerValue = tycoonInstance:FindFirstChild("Owner")
            if ownerValue
                and ownerValue:IsA("ObjectValue")
                and ownerValue.Value == Players.LocalPlayer then
                cachedLocalTycoonInstance = tycoonInstance
                return tycoonInstance
            end
        end
        return nil
    end

    local function getLeaderstatsCashValue()
        local player = Players.LocalPlayer
        if not player then
            return nil
        end

        local leaderstats = player:FindFirstChild("leaderstats")
        if not leaderstats then
            return nil
        end

        local cashStat = leaderstats:FindFirstChild("Cash")
        if not (cashStat and cashStat:IsA("ValueBase")) then
            return nil
        end

        local rawValue = cashStat.Value
        ensureHugeLoaded()

        if cachedHuge and type(cachedHuge.toHuge) == "function" then
            local ok, hugeValue = pcall(function()
                return cachedHuge.toHuge(rawValue)
            end)
            if ok and hugeValue ~= nil then
                return hugeValue
            end
        end

        if type(rawValue) == "number" then
            return rawValue
        end

        return rawValue
    end

    local function getLeaderstatsCashText()
        local player = Players.LocalPlayer
        if not player then
            return "N/A"
        end

        local leaderstats = player:FindFirstChild("leaderstats")
        if not leaderstats then
            return "N/A"
        end

        local cashStat = leaderstats:FindFirstChild("Cash")
        if not cashStat then
            return "N/A"
        end

        if not cashStat:IsA("ValueBase") then
            return "N/A"
        end

        local rawValue = cashStat.Value
        ensureHugeLoaded()

        if cachedHuge then
            local ok, text = pcall(function()
                local hugeValue = rawValue
                if type(rawValue) == "number" and type(cachedHuge.toHuge) == "function" then
                    hugeValue = cachedHuge.toHuge(rawValue)
                elseif type(rawValue) == "string" and type(cachedHuge.toHuge) == "function" then
                    hugeValue = cachedHuge.toHuge(rawValue)
                end
                if type(cachedHuge.formatAbbreviated) == "function" then
                    return cachedHuge.formatAbbreviated(hugeValue, "$")
                end
                return nil
            end)
            if ok and type(text) == "string" and #text > 0 then
                return text
            end
        end

        if type(rawValue) == "number" then
            return "$" .. tostring(rawValue)
        end
        if type(rawValue) == "string" and rawValue ~= "" then
            if rawValue:sub(1, 1) == "$" then
                return rawValue
            end
            return "$" .. rawValue
        end
        return tostring(rawValue)
    end

    local function getTycoonAtText()
        local tycoonInstance = findLocalTycoonInstance()
        if not tycoonInstance then
            return "Not assigned"
        end
        return tycoonInstance:GetFullName()
    end

    local function getPlayerInfoContent()
        return string.format(
            "Tycoon at: %s\nCash: %s",
            getTycoonAtText(),
            getLeaderstatsCashText()
        )
    end

    local function applyPlayerInfoParagraph()
        if not playerInfoParagraph then
            return
        end
        playerInfoParagraph:Set({
            Title = "Player Information",
            Content = getPlayerInfoContent(),
        })
    end

    local function getLocalTycoon(ctx)
        if ctx and ctx.LocalTycoon and type(ctx.LocalTycoon.get) == "function" then
            local ok, tycoon = pcall(function()
                return ctx.LocalTycoon.get()
            end)
            if ok and tycoon and tycoon.Instance then
                cachedLocalTycoonInstance = tycoon.Instance
                return tycoon
            end
        end

        local tycoonInstance = findLocalTycoonInstance()
        if not tycoonInstance then
            return nil
        end

        return {
            Instance = tycoonInstance,
        }
    end

    local function isPurchaseBuyableInstance(instance)
        if instance:GetAttribute("Purchased") then
            return false
        end
        if not instance:GetAttribute("Shown") then
            return false
        end
        if instance:GetAttribute("Enabled") == false then
            return false
        end
        return true
    end

    local function getPurchaseEntity(ctx, instance)
        if ctx.ClientTycoonPurchase and type(ctx.ClientTycoonPurchase.getUnsafe) == "function" then
            local ok, entity = pcall(function()
                return ctx.ClientTycoonPurchase.getUnsafe(instance)
            end)
            if ok and entity then
                return entity
            end
        end
        if ctx.Entity and type(ctx.Entity.getUnsafe) == "function" then
            local ok, entity = pcall(function()
                return ctx.Entity.getUnsafe(instance)
            end)
            if ok and entity then
                return entity
            end
        end
        return nil
    end

    local function getPlayerCash(ctx, tycoon)
        if tycoon and type(tycoon.GetComponent) == "function" and ctx.ClientTycoonBalances then
            local ok, balances = pcall(function()
                return tycoon:GetComponent(ctx.ClientTycoonBalances)
            end)
            if ok and balances and type(balances.GetCash) == "function" then
                local cashOk, cash = pcall(function()
                    return balances:GetCash()
                end)
                if cashOk then
                    return cash
                end
            end
        end
        return nil
    end

    local function getPlayerCashAmount(ctx, tycoon)
        local tycoonCash = getPlayerCash(ctx, tycoon)
        if tycoonCash ~= nil then
            return tycoonCash
        end
        return getLeaderstatsCashValue()
    end

    local function canAffordPurchasePrice(cash, price)
        if cash == nil or price == nil then
            return false
        end

        local ok, affordable = pcall(function()
            return price <= cash
        end)
        return ok and affordable == true
    end

    local function getPurchaseDisplayName(instance)
        local displayAttr = instance:GetAttribute("DisplayName")
        if type(displayAttr) == "string" and displayAttr ~= "" then
            return displayAttr
        end

        local titleLabel = instance:FindFirstChild("Title", true)
        if titleLabel and (titleLabel:IsA("TextLabel") or titleLabel:IsA("TextButton")) then
            local titleText = titleLabel.Text
            if type(titleText) == "string" and titleText ~= "" then
                return titleText
            end
        end

        return prettifyPurchaseName(instance.Name)
    end

    local function lookupBalancePurchasePrice(prices, instance)
        if type(prices) ~= "table" then
            return nil, alphanumericName(instance.Name)
        end

        local nameKey = alphanumericName(instance.Name)
        if prices[nameKey] ~= nil then
            return prices[nameKey], nameKey
        end

        local displayAttr = instance:GetAttribute("DisplayName")
        if type(displayAttr) == "string" and displayAttr ~= "" then
            local displayKey = alphanumericName(displayAttr)
            if prices[displayKey] ~= nil then
                return prices[displayKey], displayKey
            end
        end

        return nil, nameKey
    end

    local function getBillboardPriceText(instance)
        for _, descendant in instance:GetDescendants() do
            if descendant:IsA("TextLabel") and descendant.Name:lower():find("price", 1, true) then
                local text = descendant.Text
                if type(text) == "string" and text ~= "" then
                    return text
                end
            end
        end

        for _, descendant in instance:GetDescendants() do
            if descendant:IsA("TextLabel") then
                local text = descendant.Text
                if type(text) == "string" and text:find("$", 1, true) then
                    return text
                end
            end
        end

        return nil
    end

    local function getPurchasePrice(ctx, entity, instance)
        if entity and type(entity.GetPrice) == "function" then
            local ok, price = pcall(function()
                return entity:GetPrice()
            end)
            if ok and price ~= nil then
                return price
            end
        end

        local prices = ctx.Balance and ctx.Balance.PurchasePrices
        local price = lookupBalancePurchasePrice(prices, instance)
        if price ~= nil then
            return price
        end

        return nil
    end

    local function getPurchasePriceText(ctx, entity, instance)
        local price = getPurchasePrice(ctx, entity, instance)
        if price ~= nil then
            return formatPurchasePrice(ctx, price)
        end

        local billboardPrice = getBillboardPriceText(instance)
        if billboardPrice then
            return billboardPrice
        end

        return "Free"
    end

    local function isPurchaseBuyable(instance, entity)
        if not isPurchaseBuyableInstance(instance) then
            return false
        end
        if entity then
            if type(entity.IsPurchased) == "function" then
                local ok, purchased = pcall(function()
                    return entity:IsPurchased() == true
                end)
                if ok and purchased then
                    return false
                end
            end
            if type(entity.IsEnabled) == "function" then
                local ok, enabled = pcall(function()
                    return entity:IsEnabled() == true
                end)
                if ok and not enabled then
                    return false
                end
            end
        end
        return true
    end

    local function findPurchaseRemote(instance, entity)
        if entity and entity.PurchaseRemote and type(entity.PurchaseRemote.InvokeServer) == "function" then
            return entity.PurchaseRemote
        end

        local direct = instance:FindFirstChild("Purchase")
        if direct and direct:IsA("RemoteFunction") then
            return direct
        end

        for _, descendant in instance:GetDescendants() do
            if descendant.Name == "Purchase" and descendant:IsA("RemoteFunction") then
                return descendant
            end
        end

        return nil
    end

    local function collectBuyablePurchases(ctx, includeEntities)
        local tycoon = getLocalTycoon(ctx)
        if not tycoon then
            return nil, "Waiting for tycoon..."
        end

        local tycoonInstance = tycoon.Instance
        local cash = includeEntities and getPlayerCashAmount(ctx, tycoon) or nil
        local orderRank = cachedPurchaseOrderRank or {}

        local byName = {}
        for _, instance in tycoonInstance:GetDescendants() do
            if instance:HasTag("Tycoon.Purchase") and isPurchaseBuyableInstance(instance) then
                local entity = includeEntities and getPurchaseEntity(ctx, instance) or nil
                if not includeEntities or isPurchaseBuyable(instance, entity) then
                    local _, balanceKey = lookupBalancePurchasePrice(ctx.Balance.PurchasePrices, instance)
                    local displayName = getPurchaseDisplayName(instance)
                    local price = getPurchasePrice(ctx, entity, instance)
                    local priceText = getPurchasePriceText(ctx, entity, instance)
                    local canAfford = canAffordPurchasePrice(cash, price)

                    byName[balanceKey] = {
                        name = balanceKey,
                        displayName = prettifyPurchaseName(displayName),
                        price = price,
                        priceText = priceText,
                        canAfford = canAfford,
                        instance = instance,
                        entity = entity,
                        order = orderRank[balanceKey] or 999999,
                    }
                end
            end
        end

        local entries = {}
        for _, entry in pairs(byName) do
            table.insert(entries, entry)
        end
        table.sort(entries, function(a, b)
            if a.order == b.order then
                return a.displayName < b.displayName
            end
            return a.order < b.order
        end)

        return entries
    end

    local function buildPurchaseListParagraphText(entries, statusText)
        if statusText then
            return statusText
        end
        if not entries or #entries == 0 then
            return "No purchasable buttons right now."
        end

        local lines = {}
        for _, entry in ipairs(entries) do
            table.insert(lines, string.format("%s — %s", entry.displayName, entry.priceText))
        end
        return table.concat(lines, "\n")
    end

    local function getPurchaseListSnapshot(includeEntities)
        local ctx, ctxErr = getSellLemonsGameContext(includeEntities == true)
        if not ctx then
            return {
                title = "Buyable Buttons",
                content = ctxErr or "Could not load game data.",
                count = 0,
                icon = "x",
            }
        end

        local entries, statusText = collectBuyablePurchases(ctx, includeEntities == true)
        if statusText then
            return {
                title = "Buyable Buttons",
                content = statusText,
                count = 0,
                icon = nil,
            }
        end

        local content = buildPurchaseListParagraphText(entries)
        return {
            title = string.format("Buyable Buttons (%d)", #entries),
            content = content,
            count = #entries,
            icon = if #entries > 0 then "check" else nil,
        }
    end

    local function applyPurchaseSnapshot(snapshot)
        lastPurchaseSnapshot = snapshot
        if purchaseListParagraph then
            purchaseListParagraph:Set({
                Title = snapshot.title,
                Content = snapshot.content,
            })
        end
    end

    local function computePurchaseListSnapshot(includeEntities)
        local ok, snapshotOrErr = pcall(function()
            return getPurchaseListSnapshot(includeEntities)
        end)
        if ok then
            return snapshotOrErr
        end
        return {
            title = "Buyable Buttons",
            content = "Refresh error: " .. tostring(snapshotOrErr),
            count = 0,
            icon = "x",
        }
    end

    local function refreshPurchaseListParagraphAsync(includeEntities, showRefreshing)
        if showRefreshing and purchaseListParagraph then
            purchaseListParagraph:Set({
                Title = "Buyable Buttons",
                Content = "Refreshing...",
            })
        end

        local snapshot = computePurchaseListSnapshot(includeEntities)
        applyPlayerInfoParagraph()
        applyPurchaseSnapshot(snapshot)
        return snapshot
    end

    local function requestPurchaseListRefresh(includeEntities, showRefreshing, onComplete)
        if refreshInProgress then
            if onComplete then
                onComplete(lastPurchaseSnapshot, true)
            end
            return
        end

        refreshInProgress = true
        applyPlayerInfoParagraph()
        if showRefreshing then
            applyPurchaseSnapshot({
                title = "Buyable Buttons",
                content = "Refreshing...",
                count = 0,
                icon = nil,
            })
        end

        task.spawn(function()
            local snapshot = computePurchaseListSnapshot(includeEntities)
            refreshInProgress = false
            applyPlayerInfoParagraph()
            applyPurchaseSnapshot(snapshot)
            if onComplete then
                onComplete(snapshot, false)
            end
        end)
    end

    local function waitForPurchaseComplete(instance, timeoutSec)
        if instance:GetAttribute("Purchased") then
            return true
        end

        local deadline = os.clock() + (timeoutSec or 3)
        while autoPurchaseRunning and os.clock() < deadline do
            if instance:GetAttribute("Purchased") then
                return true
            end
            task.wait(0.1)
        end

        return instance:GetAttribute("Purchased") == true
    end

    local function tryAutoPurchaseOnce()
        local ctx = getSellLemonsGameContext(true)
        if not ctx then
            return false
        end

        local tycoon = getLocalTycoon(ctx)
        if not tycoon then
            return false
        end

        local cash = getPlayerCashAmount(ctx, tycoon)
        if cash == nil then
            return false
        end

        -- Match the Buyable Buttons list (instance Shown/Purchased/Enabled), not entity IsEnabled.
        local entries = collectBuyablePurchases(ctx, false)
        if type(entries) ~= "table" then
            return false
        end

        for _, entry in ipairs(entries) do
            local entity = getPurchaseEntity(ctx, entry.instance)
            local price = getPurchasePrice(ctx, entity, entry.instance)
            local priceText = getPurchasePriceText(ctx, entity, entry.instance)
            if price ~= nil and canAffordPurchasePrice(cash, price) then
                local remote = findPurchaseRemote(entry.instance, entity)
                if remote then
                    local ok = pcall(function()
                        remote:InvokeServer(false)
                    end)
                    if ok then
                        waitForPurchaseComplete(entry.instance, 3)
                        mountNotify({
                            Title = "Auto Purchase",
                            Content = "Bought " .. entry.displayName .. " (" .. priceText .. ")",
                            Icon = "check",
                        })
                        return true
                    end
                end
            end
        end
        return false
    end

    local function formatUpgradePriceText(ctx, price)
        if price == nil then
            return "?"
        end
        if ctx.Huge and type(ctx.Huge.formatLong) == "function" then
            local ok, numText, magnitudeName = pcall(function()
                return ctx.Huge.formatLong(price, "$")
            end)
            if ok and type(numText) == "string" and #numText > 0 then
                if type(magnitudeName) == "string" and #magnitudeName > 0 then
                    return numText .. " " .. magnitudeName
                end
                return numText
            end
        end
        return "$" .. tostring(price)
    end

    local function getEarnerEntity(ctx, instance)
        if ctx.Entity and type(ctx.Entity.getUnsafe) == "function" then
            local ok, entity = pcall(function()
                return ctx.Entity.getUnsafe(instance)
            end)
            if ok and entity then
                return entity
            end
        end
        return nil
    end

    local function getEarnerDisplayName(entity, instance)
        if entity and type(entity.DisplayName) == "string" and entity.DisplayName ~= "" then
            return entity.DisplayName
        end
        return prettifyPurchaseName(instance.Name)
    end

    local function getEarnerUpgradeInfo(entity)
        if entity and type(entity.GetNextUpgradeInfo) == "function" then
            local ok, info = pcall(function()
                return entity:GetNextUpgradeInfo()
            end)
            if ok and type(info) == "table" then
                return info
            end
        end
        return nil
    end

    local function findUpgradeRemote(instance, entity)
        if entity and entity.UpgradeRemote and type(entity.UpgradeRemote.InvokeServer) == "function" then
            return entity.UpgradeRemote
        end

        local direct = instance:FindFirstChild("Upgrade")
        if direct and direct:IsA("RemoteFunction") then
            return direct
        end

        for _, descendant in instance:GetDescendants() do
            if descendant.Name == "Upgrade" and descendant:IsA("RemoteFunction") then
                return descendant
            end
        end

        return nil
    end

    local function collectEarnerUpgrades(ctx)
        local tycoon = getLocalTycoon(ctx)
        if not tycoon then
            return nil, "Waiting for tycoon..."
        end

        local tycoonInstance = tycoon.Instance
        local entries = {}
        for _, instance in tycoonInstance:GetDescendants() do
            if instance:HasTag("Tycoon.Earner") then
                local entity = getEarnerEntity(ctx, instance)
                local displayName = getEarnerDisplayName(entity, instance)
                local info = getEarnerUpgradeInfo(entity)

                local price, isMax, count
                if info then
                    price = info.Price
                    count = info.Count
                    isMax = info.Max == true or info.Count == 0
                end

                table.insert(entries, {
                    displayName = displayName,
                    price = price,
                    priceText = if isMax then "MAX" else formatUpgradePriceText(ctx, price),
                    count = count or 1,
                    isMax = isMax == true,
                    instance = instance,
                    entity = entity,
                })
            end
        end

        table.sort(entries, function(a, b)
            return a.displayName < b.displayName
        end)

        return entries
    end

    local function buildUpgradeListText(entries, statusText)
        if statusText then
            return statusText
        end
        if not entries or #entries == 0 then
            return "No upgradeable earners right now."
        end

        local lines = {}
        for _, entry in ipairs(entries) do
            table.insert(lines, string.format("%s — %s", entry.displayName, entry.priceText))
        end
        return table.concat(lines, "\n")
    end

    local function getUpgradeListSnapshot()
        local ctx, ctxErr = getSellLemonsGameContext(true)
        if not ctx then
            return {
                title = "Cash Earned",
                content = ctxErr or "Could not load game data.",
                count = 0,
            }
        end

        local entries, statusText = collectEarnerUpgrades(ctx)
        if statusText then
            return {
                title = "Cash Earned",
                content = statusText,
                count = 0,
            }
        end

        return {
            title = string.format("Cash Earned (%d)", #entries),
            content = buildUpgradeListText(entries),
            count = #entries,
        }
    end

    local function computeUpgradeListSnapshot()
        local ok, snapshotOrErr = pcall(function()
            return getUpgradeListSnapshot()
        end)
        if ok then
            return snapshotOrErr
        end
        return {
            title = "Cash Earned",
            content = "Refresh error: " .. tostring(snapshotOrErr),
            count = 0,
        }
    end

    local function applyUpgradeSnapshot(snapshot)
        if not upgradeListParagraph then
            return
        end
        task.defer(function()
            if not upgradeListParagraph then
                return
            end
            upgradeListParagraph:Set({
                Title = snapshot.title,
                Content = snapshot.content,
            })
        end)
    end

    local function requestUpgradeListRefresh(showRefreshing)
        if upgradeRefreshInProgress then
            return
        end
        upgradeRefreshInProgress = true
        if showRefreshing then
            applyUpgradeSnapshot({
                title = "Cash Earned",
                content = "Refreshing...",
                count = 0,
            })
        end

        task.spawn(function()
            local snapshot = computeUpgradeListSnapshot()
            upgradeRefreshInProgress = false
            applyUpgradeSnapshot(snapshot)
        end)
    end

    local function tryAutoUpgradeOnce()
        local ctx = getSellLemonsGameContext(true)
        if not ctx then
            return false
        end

        local tycoon = getLocalTycoon(ctx)
        if not tycoon then
            return false
        end

        local cash = getPlayerCashAmount(ctx, tycoon)
        if cash == nil then
            return false
        end

        local entries = collectEarnerUpgrades(ctx)
        if type(entries) ~= "table" then
            return false
        end

        for _, entry in ipairs(entries) do
            if not entry.isMax and entry.price ~= nil and canAffordPurchasePrice(cash, entry.price) then
                local remote = findUpgradeRemote(entry.instance, entry.entity)
                if remote then
                    local ok = pcall(function()
                        remote:InvokeServer(entry.count or 1)
                    end)
                    if ok then
                        mountNotify({
                            Title = "Auto Upgrade",
                            Content = "Upgraded " .. entry.displayName .. " (" .. entry.priceText .. ")",
                            Icon = "check",
                        })
                        return true
                    end
                end
            end
        end
        return false
    end

    local function findWakeIncomeStreamRemote(tycoonInstance)
        local remotes = tycoonInstance and tycoonInstance:FindFirstChild("Remotes")
        local wakeRemote = remotes and remotes:FindFirstChild("WakeIncomeStream")
        if wakeRemote and wakeRemote:IsA("RemoteFunction") then
            return wakeRemote
        end
        return nil
    end

    local function getEarnerStreamName(entity, instance)
        if entity and type(entity.Name) == "string" and entity.Name ~= "" then
            return entity.Name
        end
        return alphanumericName(instance.Name)
    end

    local function isEarnerCashClaimable(entity)
        if not entity then
            return false
        end

        if type(entity.IsEnabled) == "function" then
            local ok, enabled = pcall(function()
                return entity:IsEnabled() == true
            end)
            if ok and not enabled then
                return false
            end
        end

        if type(entity.GetEstimatedNextEarnTime) ~= "function" then
            return false
        end

        local ok, remaining = pcall(function()
            return entity:GetEstimatedNextEarnTime()
        end)
        if not ok then
            return false
        end

        -- Matches UIManageTileEarner Progress.Active: nil means cash is ready to collect.
        return remaining == nil
    end

    local function tryAutoClaimCashOnce()
        local ctx = getSellLemonsGameContext(true)
        if not ctx then
            return false
        end

        local tycoon = getLocalTycoon(ctx)
        if not tycoon then
            return false
        end

        local tycoonInstance = tycoon.Instance
        local remote = findWakeIncomeStreamRemote(tycoonInstance)
        if not remote then
            return false
        end

        local claimedAny = false
        for _, instance in tycoonInstance:GetDescendants() do
            if instance:HasTag("Tycoon.Earner") then
                local entity = getEarnerEntity(ctx, instance)
                if isEarnerCashClaimable(entity) then
                    local streamName = getEarnerStreamName(entity, instance)
                    if streamName ~= "" then
                        local ok = pcall(function()
                            remote:InvokeServer(streamName)
                        end)
                        if ok then
                            claimedAny = true
                        end
                    end
                end
            end
        end

        return claimedAny
    end

    local function installOrchardAutomation()
        local OrchardTab = Window:CreateTab("Orchard", "sprout")

        local orchardInfoParagraph
        local orchardInfoAutoRefreshSec = 1
        local orchardDelaySec = 1
        local orchardSelectedItem = "FertilizerMutate"
        local orchardItemOptions = { "FertilizerMutate" }
        local autoUnlockOrchardRunning = false
        local autoUnlockOrchardLoopId = 0
        local autoUnlockPlotsRunning = false
        local autoUnlockPlotsLoopId = 0
        local autoHarvestOrchardRunning = false
        local autoHarvestOrchardLoopId = 0
        local autoPlantOrchardRunning = false
        local autoPlantOrchardLoopId = 0
        local autoDestroyOrchardRunning = false
        local autoDestroyOrchardLoopId = 0
        local autoUseOrchardItemRunning = false
        local autoUseOrchardItemLoopId = 0
        local autoBuyOrchardItemsRunning = false
        local autoBuyOrchardItemsLoopId = 0
        local autoBuyOrchardDecorRunning = false
        local autoBuyOrchardDecorLoopId = 0
        local autoSellOrchardFruitRunning = false
        local autoSellOrchardFruitLoopId = 0
        local autoEatOrchardFruitRunning = false
        local autoEatOrchardFruitLoopId = 0
        local autoOrchardEatPowerRunning = false
        local autoOrchardEatPowerLoopId = 0
        local autoOrchardEatQueueRunning = false
        local autoOrchardEatQueueLoopId = 0

        local ORCHARD_PLOT_STATES = {
            Empty = 0,
            TreeGrowing = 1,
            FruitGrowing = 2,
            FruitReady = 3,
        }

        local function findTycoonFolderChild(tycoonInstance, folderName, childName, className)
            local folder = tycoonInstance and tycoonInstance:FindFirstChild(folderName)
            local child = folder and folder:FindFirstChild(childName)
            if child and (not className or child:IsA(className)) then
                return child
            end
            return nil
        end

        local cachedNamedRemoteFunctions = {}

        local function findNamedRemoteFunction(remoteName)
            local cached = cachedNamedRemoteFunctions[remoteName]
            if cached and cached.Parent then
                return cached
            end

            local tycoonInstance = findLocalTycoonInstance()
            for _, folderName in ipairs({ "Remotes", "Values" }) do
                local remote = findTycoonFolderChild(tycoonInstance, folderName, remoteName, "RemoteFunction")
                if remote then
                    cachedNamedRemoteFunctions[remoteName] = remote
                    return remote
                end
            end

            local rsRemote = ReplicatedStorage:FindFirstChild(remoteName, true)
            if rsRemote and rsRemote:IsA("RemoteFunction") then
                cachedNamedRemoteFunctions[remoteName] = rsRemote
                return rsRemote
            end

            return nil
        end

        local function getOrchardComponent(orchard, componentClass)
            if not orchard or not componentClass or type(orchard.GetComponent) ~= "function" then
                return nil
            end
            local ok, component = pcall(function()
                return orchard:GetComponent(componentClass)
            end)
            if ok then
                return component
            end
            return nil
        end

        local function getLocalOrchard(ctx, tycoon)
            if not tycoon then
                return nil
            end

            local orchardMod = ctx and (ctx.Orchard)
            if orchardMod and type(orchardMod.getFromTycoon) == "function" then
                local ok, orchard = pcall(function()
                    return orchardMod.getFromTycoon(tycoon)
                end)
                if ok and orchard then
                    return orchard
                end
            end

            local tycoonInstance = tycoon.Instance
            if not tycoonInstance then
                return nil
            end

            for _, child in tycoonInstance:GetChildren() do
                if child:HasTag("Tycoon.Orchard") then
                    return {
                        Instance = child,
                        Tycoon = tycoon,
                    }
                end
            end

            for _, tagged in CollectionService:GetTagged("Tycoon.Orchard") do
                if tagged:IsDescendantOf(tycoonInstance) or tagged.Parent == tycoonInstance then
                    return {
                        Instance = tagged,
                        Tycoon = tycoon,
                    }
                end
            end

            return nil
        end

        local function isOrchardUnlocked(orchard, tycoon)
            if orchard and type(orchard.IsUnlocked) == "function" then
                local ok, unlocked = pcall(function()
                    return orchard:IsUnlocked() == true
                end)
                if ok then
                    return unlocked
                end
            end

            local tycoonInstance = tycoon and tycoon.Instance
            local values = tycoonInstance and tycoonInstance:FindFirstChild("Values")
            local unlockedValue = values and values:FindFirstChild("OrchardUnlocked")
            if unlockedValue and unlockedValue:IsA("ValueBase") then
                return unlockedValue.Value == true
            end
            if values then
                local attr = values:GetAttribute("OrchardUnlocked")
                if attr ~= nil then
                    return attr == true
                end
            end
            return false
        end

        local function getOrchardPlotStates(ctx)
            if ctx and ctx.OrchardPlot and type(ctx.OrchardPlot.States) == "table" then
                return ctx.OrchardPlot.States
            end
            return ORCHARD_PLOT_STATES
        end

        local function getPlotState(plotInstance, states)
            local state = plotInstance:GetAttribute("State")
            if state == nil then
                return states.Empty or 0
            end
            return state
        end

        local function collectLocalOrchardPlots(orchard)
            local orchardInstance = orchard and orchard.Instance
            if not orchardInstance then
                return {}
            end

            local plots = {}
            for _, plotInstance in CollectionService:GetTagged("Tycoon.OrchardPlot") do
                if plotInstance.Parent and plotInstance:IsDescendantOf(orchardInstance) then
                    table.insert(plots, plotInstance)
                end
            end
            table.sort(plots, function(a, b)
                local idA = tonumber(a:GetAttribute("ID")) or 0
                local idB = tonumber(b:GetAttribute("ID")) or 0
                return idA < idB
            end)
            return plots
        end

        local function getPlotEntity(ctx, plotInstance)
            if ctx.OrchardPlot and type(ctx.OrchardPlot.getUnsafe) == "function" then
                local ok, entity = pcall(function()
                    return ctx.OrchardPlot.getUnsafe(plotInstance)
                end)
                if ok and entity then
                    return entity
                end
            end
            if ctx.Entity and type(ctx.Entity.getUnsafe) == "function" then
                local ok, entity = pcall(function()
                    return ctx.Entity.getUnsafe(plotInstance)
                end)
                if ok and entity then
                    return entity
                end
            end
            return nil
        end

        local function getOrchardTokens(ctx, tycoon)
            if tycoon and type(tycoon.GetComponent) == "function" and ctx and ctx.ClientTycoonBalances then
                local ok, balances = pcall(function()
                    return tycoon:GetComponent(ctx.ClientTycoonBalances)
                end)
                if ok and balances and type(balances.GetTokens) == "function" then
                    local tokensOk, tokens = pcall(function()
                        return balances:GetTokens()
                    end)
                    if tokensOk and tokens ~= nil then
                        return tokens
                    end
                end
            end

            local values = tycoon and tycoon.Instance and tycoon.Instance:FindFirstChild("Values")
            local tokensValue = values and values:FindFirstChild("Tokens")
            if tokensValue and tokensValue:IsA("ValueBase") then
                return tokensValue.Value
            end
            if values then
                local attr = values:GetAttribute("Tokens")
                if attr ~= nil then
                    return attr
                end
            end
            return 0
        end

        local function getOrchardItemOptions(ctx)
            local items = ctx and ctx.Config and ctx.Config.Orchard and ctx.Config.Orchard.Items
            if type(items) ~= "table" then
                return { "FertilizerMutate", "FertilizerCleanse", "FertilizerQuickGrow", "FertilizerAscend" }
            end

            local options = {}
            for itemName, info in pairs(items) do
                if type(itemName) == "string" and type(info) == "table" then
                    table.insert(options, {
                        name = itemName,
                        order = tonumber(info.Order) or 999,
                        displayName = info.DisplayName or prettifyPurchaseName(itemName),
                    })
                end
            end
            table.sort(options, function(a, b)
                if a.order == b.order then
                    return a.name < b.name
                end
                return a.order < b.order
            end)

            local names = {}
            for _, entry in ipairs(options) do
                table.insert(names, entry.name)
            end
            if #names == 0 then
                return { "FertilizerMutate" }
            end
            return names
        end

        local function getOrchardItemDisplayName(ctx, itemName)
            local info = ctx and ctx.Config and ctx.Config.Orchard and ctx.Config.Orchard.Items and ctx.Config.Orchard.Items[itemName]
            if info and type(info.DisplayName) == "string" and info.DisplayName ~= "" then
                return info.DisplayName
            end
            return prettifyPurchaseName(itemName)
        end

        local function getOrchardDecorationEntries(ctx)
            local decorations = ctx and ctx.Config and ctx.Config.Orchard and ctx.Config.Orchard.Decorations
            if type(decorations) ~= "table" then
                return {}
            end

            local entries = {}
            for name, info in pairs(decorations) do
                if type(name) == "string" and type(info) == "table" then
                    table.insert(entries, {
                        name = name,
                        displayName = info.DisplayName or prettifyPurchaseName(name),
                        price = tonumber(info.Price) or 0,
                    })
                end
            end
            table.sort(entries, function(a, b)
                if a.price == b.price then
                    return a.name < b.name
                end
                return a.price < b.price
            end)
            return entries
        end

        local function getInventoryFruitEntries(fruitsComp)
            if not fruitsComp or type(fruitsComp.GetAll) ~= "function" then
                return {}
            end
            local ok, entries = pcall(function()
                return fruitsComp:GetAll()
            end)
            if not ok or type(entries) ~= "table" then
                return {}
            end

            local result = {}
            for _, entry in pairs(entries) do
                if type(entry) == "table" and entry.Fruit then
                    local count = tonumber(entry.Count) or 0
                    if count > 0 then
                        table.insert(result, {
                            Fruit = entry.Fruit,
                            Count = count,
                        })
                    end
                end
            end
            return result
        end

        local function getOrchardInfoContent()
            local ctx, ctxErr = getSellLemonsGameContext(true)
            if not ctx then
                return ctxErr or "Could not load game data."
            end

            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return "Waiting for tycoon..."
            end

            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard then
                return "Waiting for orchard..."
            end

            local unlocked = isOrchardUnlocked(orchard, tycoon)
            local states = getOrchardPlotStates(ctx)
            local plots = collectLocalOrchardPlots(orchard)
            local counts = {
                total = #plots,
                available = 0,
                empty = 0,
                growing = 0,
                ready = 0,
                enabled = 0,
            }

            for _, plotInstance in ipairs(plots) do
                if plotInstance:GetAttribute("Enabled") then
                    counts.enabled += 1
                end
                if plotInstance:GetAttribute("Available") == true and not plotInstance:GetAttribute("Enabled") then
                    counts.available += 1
                end
                local state = getPlotState(plotInstance, states)
                if state == states.Empty then
                    counts.empty += 1
                elseif state == states.FruitReady then
                    counts.ready += 1
                elseif state == states.TreeGrowing or state == states.FruitGrowing then
                    counts.growing += 1
                end
            end

            local fruitsComp = getOrchardComponent(orchard, ctx.OrchardFruits)
            local fruitStock = 0
            local fruitKinds = 0
            for _, entry in ipairs(getInventoryFruitEntries(fruitsComp)) do
                fruitKinds += 1
                fruitStock += tonumber(entry.Count) or 0
            end

            local tokens = getOrchardTokens(ctx, tycoon)
            local lines = {
                string.format("Unlocked: %s", if unlocked then "Yes" else "No"),
                string.format("Tokens: %s", tostring(tokens)),
                string.format(
                    "Plots: %d total | %d unlocked | %d available | %d empty | %d growing | %d ready",
                    counts.total,
                    counts.enabled,
                    counts.available,
                    counts.empty,
                    counts.growing,
                    counts.ready
                ),
                string.format("Fruit Inventory: %d kinds / %d total", fruitKinds, fruitStock),
                string.format("Selected Item: %s", getOrchardItemDisplayName(ctx, orchardSelectedItem)),
            }
            return table.concat(lines, "\n")
        end

        local function applyOrchardInfoParagraph(content)
            if not orchardInfoParagraph then
                return
            end
            task.defer(function()
                if not orchardInfoParagraph then
                    return
                end
                orchardInfoParagraph:Set({
                    Title = "Orchard",
                    Content = content,
                })
            end)
        end

        local function requestOrchardInfoRefresh()
            task.spawn(function()
                local ok, contentOrErr = pcall(getOrchardInfoContent)
                applyOrchardInfoParagraph(if ok then contentOrErr else ("Refresh error: " .. tostring(contentOrErr)))
            end)
        end

        local function tryAutoUnlockOrchardOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end
            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard or isOrchardUnlocked(orchard, tycoon) then
                return false
            end

            if type(orchard.UnlockAsync) == "function" then
                local ok = pcall(function()
                    orchard:UnlockAsync()
                end)
                if ok then
                    mountNotify({
                        Title = "Orchard",
                        Content = "Unlocked orchard",
                        Icon = "check",
                    })
                end
                return ok
            end

            local remote = findTycoonFolderChild(tycoon.Instance, "Remotes", "UnlockOrchard", "RemoteFunction")
            if not remote then
                return false
            end
            local ok = pcall(function()
                remote:InvokeServer()
            end)
            if ok then
                mountNotify({
                    Title = "Orchard",
                    Content = "Unlocked orchard",
                    Icon = "check",
                })
            end
            return ok
        end

        local function tryAutoUnlockPlotsOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end
            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard or not isOrchardUnlocked(orchard, tycoon) then
                return false
            end

            local plotsComp = getOrchardComponent(orchard, ctx.OrchardPlots)

            -- Match game UI: only unlock when tokens cover GetNextPlotUnlockPrice().
            local unlockPrice = nil
            if plotsComp and type(plotsComp.GetNextPlotUnlockPrice) == "function" then
                local okPrice, price = pcall(function()
                    return plotsComp:GetNextPlotUnlockPrice()
                end)
                if okPrice then
                    unlockPrice = tonumber(price)
                end
            end
            if unlockPrice == nil then
                local orchardInstance = orchard.Instance
                local unlockedCount = tonumber(orchardInstance and orchardInstance:GetAttribute("PlotsUnlocked")) or 0
                local priceFn = ctx.Config and ctx.Config.Orchard and ctx.Config.Orchard.PlotPriceFunction
                if type(priceFn) == "function" then
                    local okPrice, price = pcall(priceFn, unlockedCount)
                    if okPrice then
                        unlockPrice = tonumber(price)
                    end
                end
            end
            if unlockPrice ~= nil and unlockPrice > 0 then
                local tokens = tonumber(getOrchardTokens(ctx, tycoon)) or 0
                if tokens < unlockPrice then
                    return false
                end
            end

            local unlockedAny = false
            for _, plotInstance in ipairs(collectLocalOrchardPlots(orchard)) do
                if plotInstance:GetAttribute("Available") == true and not plotInstance:GetAttribute("Enabled") then
                    local plotId = plotInstance:GetAttribute("ID")
                    if plotId ~= nil then
                        local ok = false
                        if plotsComp and type(plotsComp.UnlockPlotAsync) == "function" then
                            local callOk, result = pcall(function()
                                return plotsComp:UnlockPlotAsync(plotId)
                            end)
                            ok = callOk == true and result ~= false
                        else
                            local remote = findTycoonFolderChild(tycoon.Instance, "Remotes", "UnlockPlot", "RemoteFunction")
                            if remote then
                                local callOk, result = pcall(function()
                                    return remote:InvokeServer(plotId)
                                end)
                                ok = callOk == true and result ~= false
                            end
                        end
                        if ok then
                            unlockedAny = true
                            mountNotify({
                                Title = "Orchard",
                                Content = "Unlocked plot " .. tostring(plotId),
                                Icon = "check",
                            })
                            break
                        end
                    end
                end
            end
            return unlockedAny
        end

        local function tryAutoHarvestOrchardOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end
            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard or not isOrchardUnlocked(orchard, tycoon) then
                return false
            end

            local states = getOrchardPlotStates(ctx)
            local harvestRemote = findNamedRemoteFunction("OrchardPlot.Harvest")
            local harvested = 0
            for _, plotInstance in ipairs(collectLocalOrchardPlots(orchard)) do
                if plotInstance:GetAttribute("Enabled") and getPlotState(plotInstance, states) == states.FruitReady then
                    local plotEntity = getPlotEntity(ctx, plotInstance)
                    local ok = false
                    if plotEntity and type(plotEntity.HarvestAsync) == "function" then
                        ok = pcall(function()
                            plotEntity:HarvestAsync()
                        end)
                    elseif harvestRemote then
                        ok = pcall(function()
                            harvestRemote:InvokeServer(plotInstance)
                        end)
                    end
                    if ok then
                        harvested += 1
                    end
                end
            end
            if harvested > 0 then
                mountNotify({
                    Title = "Orchard",
                    Content = "Harvested " .. harvested .. " plot(s)",
                    Icon = "check",
                })
            end
            return harvested > 0
        end

        local function tryAutoPlantOrchardOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end
            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard or not isOrchardUnlocked(orchard, tycoon) then
                return false
            end

            local fruitsComp = getOrchardComponent(orchard, ctx.OrchardFruits)
            local inventory = getInventoryFruitEntries(fruitsComp)
            if #inventory == 0 then
                return false
            end

            local states = getOrchardPlotStates(ctx)
            local plantRemote = findNamedRemoteFunction("OrchardPlot.Plant")
            local planted = 0
            local fruitIndex = 1

            for _, plotInstance in ipairs(collectLocalOrchardPlots(orchard)) do
                if not (plotInstance:GetAttribute("Enabled") and getPlotState(plotInstance, states) == states.Empty) then
                    continue
                end

                while fruitIndex <= #inventory and (tonumber(inventory[fruitIndex].Count) or 0) <= 0 do
                    fruitIndex += 1
                end
                local entry = inventory[fruitIndex]
                if not entry then
                    break
                end

                local fruit = entry.Fruit
                local plotEntity = getPlotEntity(ctx, plotInstance)
                local ok = false
                if plotEntity and type(plotEntity.PlantAsync) == "function" then
                    ok = pcall(function()
                        plotEntity:PlantAsync(fruit)
                    end)
                elseif plantRemote and type(fruit.Serialize) == "function" then
                    ok = pcall(function()
                        plantRemote:InvokeServer(plotInstance, { fruit:Serialize() })
                    end)
                end

                if ok then
                    planted += 1
                    entry.Count = (tonumber(entry.Count) or 1) - 1
                end
            end

            if planted > 0 then
                mountNotify({
                    Title = "Orchard",
                    Content = "Planted " .. planted .. " plot(s)",
                    Icon = "check",
                })
            end
            return planted > 0
        end

        local function tryAutoDestroyOrchardOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end
            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard or not isOrchardUnlocked(orchard, tycoon) then
                return false
            end

            local states = getOrchardPlotStates(ctx)
            local destroyRemote = findNamedRemoteFunction("OrchardPlot.DestroyTree")
            local destroyed = 0
            for _, plotInstance in ipairs(collectLocalOrchardPlots(orchard)) do
                if not plotInstance:GetAttribute("Enabled") then
                    continue
                end
                local state = getPlotState(plotInstance, states)
                if state == states.TreeGrowing or state == states.FruitGrowing then
                    local plotEntity = getPlotEntity(ctx, plotInstance)
                    local ok = false
                    if plotEntity and type(plotEntity.DestroyTreeAsync) == "function" then
                        ok = pcall(function()
                            plotEntity:DestroyTreeAsync()
                        end)
                    elseif destroyRemote then
                        ok = pcall(function()
                            destroyRemote:InvokeServer(plotInstance)
                        end)
                    end
                    if ok then
                        destroyed += 1
                    end
                end
            end
            if destroyed > 0 then
                mountNotify({
                    Title = "Orchard",
                    Content = "Destroyed " .. destroyed .. " tree(s)",
                    Icon = "check",
                })
            end
            return destroyed > 0
        end

        local function tryAutoUseOrchardItemOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end
            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard or not isOrchardUnlocked(orchard, tycoon) then
                return false
            end

            local itemName = orchardSelectedItem
            if type(itemName) ~= "string" or itemName == "" then
                return false
            end

            local itemsComp = getOrchardComponent(orchard, ctx.OrchardItems)
            if itemsComp and type(itemsComp.GetCount) == "function" then
                local okCount, count = pcall(function()
                    return itemsComp:GetCount(itemName)
                end)
                if okCount and (tonumber(count) or 0) <= 0 then
                    return false
                end
            end

            local itemInfo = ctx.Config and ctx.Config.Orchard and ctx.Config.Orchard.Items and ctx.Config.Orchard.Items[itemName]
            local upgradeName = itemInfo and itemInfo.Upgrade
            local states = getOrchardPlotStates(ctx)
            local useRemote = findNamedRemoteFunction("OrchardPlot.UseItem")
            local used = 0

            for _, plotInstance in ipairs(collectLocalOrchardPlots(orchard)) do
                if not plotInstance:GetAttribute("Enabled") then
                    continue
                end
                local state = getPlotState(plotInstance, states)
                if not (state == states.TreeGrowing or state == states.FruitGrowing) then
                    continue
                end
                if upgradeName and plotInstance:GetAttribute(upgradeName .. "Unlocked") == true then
                    continue
                end
                -- Fertilizers can't stack while one is already pending on the plot.
                if not upgradeName and plotInstance:GetAttribute("PendingMutationItem") ~= nil then
                    continue
                end

                local plotEntity = getPlotEntity(ctx, plotInstance)
                local ok = false
                if plotEntity and type(plotEntity.UseItemAsync) == "function" then
                    ok = pcall(function()
                        plotEntity:UseItemAsync(itemName)
                    end)
                elseif useRemote then
                    ok = pcall(function()
                        useRemote:InvokeServer(plotInstance, itemName)
                    end)
                end
                if ok then
                    used += 1
                    break
                end
            end

            if used > 0 then
                mountNotify({
                    Title = "Orchard",
                    Content = "Used " .. getOrchardItemDisplayName(ctx, itemName),
                    Icon = "check",
                })
            end
            return used > 0
        end

        local function tryAutoBuyOrchardItemsOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end
            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard or not isOrchardUnlocked(orchard, tycoon) then
                return false
            end

            local itemName = orchardSelectedItem
            local itemInfo = ctx.Config and ctx.Config.Orchard and ctx.Config.Orchard.Items and ctx.Config.Orchard.Items[itemName]
            if not itemInfo then
                return false
            end

            local price = tonumber(itemInfo.Price)
            if price == nil then
                return false
            end
            local tokens = getOrchardTokens(ctx, tycoon)
            if type(tokens) == "number" and tokens < price then
                return false
            end

            local itemsComp = getOrchardComponent(orchard, ctx.OrchardItems)
            local ok = false
            if itemsComp and type(itemsComp.BuyItemsAsync) == "function" then
                ok = pcall(function()
                    itemsComp:BuyItemsAsync(itemName, 1, true)
                end)
            else
                local remote = findTycoonFolderChild(tycoon.Instance, "Remotes", "BuyOrchardItems", "RemoteFunction")
                if remote then
                    ok = pcall(function()
                        remote:InvokeServer(itemName, 1)
                    end)
                end
            end

            if ok then
                mountNotify({
                    Title = "Orchard",
                    Content = "Bought " .. getOrchardItemDisplayName(ctx, itemName),
                    Icon = "check",
                })
            end
            return ok
        end

        local function tryAutoBuyOrchardDecorOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end
            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard or not isOrchardUnlocked(orchard, tycoon) then
                return false
            end

            local decorComp = getOrchardComponent(orchard, ctx.OrchardDecorations)
            local tokens = getOrchardTokens(ctx, tycoon)
            local remote = findTycoonFolderChild(tycoon.Instance, "Values", "PurchaseOrchardDecoration", "RemoteFunction")
                or findTycoonFolderChild(tycoon.Instance, "Remotes", "PurchaseOrchardDecoration", "RemoteFunction")

            for _, entry in ipairs(getOrchardDecorationEntries(ctx)) do
                local owned = false
                if decorComp and type(decorComp.HasDecoration) == "function" then
                    local okOwned, hasDecor = pcall(function()
                        return decorComp:HasDecoration(entry.name) == true
                    end)
                    owned = okOwned and hasDecor
                end
                if owned then
                    continue
                end
                if type(tokens) == "number" and tokens < entry.price then
                    continue
                end

                local ok = false
                if decorComp and type(decorComp.PurchaseDecorationAsync) == "function" then
                    ok = pcall(function()
                        decorComp:PurchaseDecorationAsync(entry.name)
                    end)
                elseif remote then
                    ok = pcall(function()
                        remote:InvokeServer(entry.name)
                    end)
                end
                if ok then
                    mountNotify({
                        Title = "Orchard",
                        Content = "Bought decoration " .. entry.displayName,
                        Icon = "check",
                    })
                    return true
                end
            end
            return false
        end

        local function tryAutoSellOrchardFruitOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end
            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard or not isOrchardUnlocked(orchard, tycoon) then
                return false
            end

            local fruitsComp = getOrchardComponent(orchard, ctx.OrchardFruits)
            local inventory = getInventoryFruitEntries(fruitsComp)
            if #inventory == 0 then
                return false
            end

            local function sellSucceeded(ok, result)
                -- Client sell helpers return false on rejection without throwing.
                return ok == true and result ~= false
            end

            local sold = 0

            -- Game UI only uses SellFruitAsync(fruit, amount) against Values.SellFruit.
            if fruitsComp and type(fruitsComp.SellFruitAsync) == "function" then
                for _, entry in ipairs(inventory) do
                    local amount = math.max(1, math.floor(tonumber(entry.Count) or 1))
                    local ok, result = pcall(function()
                        return fruitsComp:SellFruitAsync(entry.Fruit, amount)
                    end)
                    if sellSucceeded(ok, result) then
                        sold += amount
                    end
                end
            elseif fruitsComp and type(fruitsComp.SellFruitsAsync) == "function" then
                local sellMap = {}
                local total = 0
                for _, entry in ipairs(inventory) do
                    local amount = math.max(1, math.floor(tonumber(entry.Count) or 1))
                    sellMap[entry.Fruit] = amount
                    total += amount
                end
                local ok, result = pcall(function()
                    return fruitsComp:SellFruitsAsync(sellMap)
                end)
                if sellSucceeded(ok, result) then
                    sold = total
                end
            else
                local remote = findTycoonFolderChild(tycoon.Instance, "Values", "SellFruit", "RemoteFunction")
                    or findTycoonFolderChild(tycoon.Instance, "Remotes", "SellFruit", "RemoteFunction")
                local serialization = tryRequirePath({ "Core", "SerializationService" })
                if remote and serialization and type(serialization.Serialize) == "function" then
                    for _, entry in ipairs(inventory) do
                        local amount = math.max(1, math.floor(tonumber(entry.Count) or 1))
                        local ok, result = pcall(function()
                            return remote:InvokeServer(serialization:Serialize(entry.Fruit), amount)
                        end)
                        if sellSucceeded(ok, result) then
                            sold += amount
                        end
                    end
                end
            end

            if sold > 0 then
                mountNotify({
                    Title = "Orchard",
                    Content = "Sold " .. sold .. " fruit(s)",
                    Icon = "check",
                })
            end
            return sold > 0
        end

        local function tryAutoEatOrchardFruitOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end
            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard or not isOrchardUnlocked(orchard, tycoon) then
                return false
            end

            local eatComp = getOrchardComponent(orchard, ctx.OrchardEatFruit)
            if not eatComp or type(eatComp.EatFruitAsync) ~= "function" then
                return false
            end
            if type(eatComp.GetCurrentFruit) == "function" then
                local okCurrent, current = pcall(function()
                    return eatComp:GetCurrentFruit()
                end)
                if okCurrent and current ~= nil then
                    return false
                end
            end

            local fruitsComp = getOrchardComponent(orchard, ctx.OrchardFruits)
            local inventory = getInventoryFruitEntries(fruitsComp)
            if #inventory == 0 then
                return false
            end

            local target = inventory[1].Fruit
            local ok = pcall(function()
                eatComp:EatFruitAsync(target)
            end)
            if ok then
                mountNotify({
                    Title = "Orchard",
                    Content = "Ate a fruit",
                    Icon = "check",
                })
            end
            return ok
        end

        local function tryAutoOrchardEatPowerOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end
            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard or not isOrchardUnlocked(orchard, tycoon) then
                return false
            end

            local powers = nil
            if tycoon and type(tycoon.GetComponent) == "function" and ctx.ClientTycoonPowers then
                local okPowers, component = pcall(function()
                    return tycoon:GetComponent(ctx.ClientTycoonPowers)
                end)
                if okPowers then
                    powers = component
                end
            end

            -- SelectLevel errors when the requested level exceeds the owned level,
            -- so skip until the player has actually bought the AutoFruit power.
            if powers and type(powers.GetLevel) == "function" then
                local okLevel, level = pcall(function()
                    return powers:GetLevel("AutoFruit")
                end)
                if okLevel and (tonumber(level) or 0) < 1 then
                    return false
                end
            end

            local autoEat = getOrchardComponent(orchard, ctx.OrchardAutoEatFruitPower)
            if autoEat and type(autoEat.EnableAutoEat) == "function" then
                local ok = pcall(function()
                    autoEat:EnableAutoEat(true)
                end)
                return ok
            end

            if powers and type(powers.SelectLevel) == "function" then
                local ok = pcall(function()
                    powers:SelectLevel("AutoFruit", 1)
                end)
                return ok
            end

            local remote = findTycoonFolderChild(tycoon.Instance, "Remotes", "SelectPowerLevel", "RemoteFunction")
            if not remote then
                return false
            end
            return pcall(function()
                remote:InvokeServer("AutoFruit", 1)
            end)
        end

        local function tryAutoOrchardEatQueueOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end
            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard or not isOrchardUnlocked(orchard, tycoon) then
                return false
            end

            local fruitsComp = getOrchardComponent(orchard, ctx.OrchardFruits)
            local autoEat = getOrchardComponent(orchard, ctx.OrchardAutoEatFruitPower)
            if not autoEat or type(autoEat.SetAutoEatOrderAsync) ~= "function" then
                return false
            end

            local inventory = getInventoryFruitEntries(fruitsComp)
            if #inventory == 0 then
                return false
            end

            table.sort(inventory, function(a, b)
                local valueA, valueB = 0, 0
                if type(a.Fruit.GetTokenValue) == "function" then
                    local ok, value = pcall(function()
                        return a.Fruit:GetTokenValue()
                    end)
                    if ok and type(value) == "number" then
                        valueA = value
                    end
                end
                if type(b.Fruit.GetTokenValue) == "function" then
                    local ok, value = pcall(function()
                        return b.Fruit:GetTokenValue()
                    end)
                    if ok and type(value) == "number" then
                        valueB = value
                    end
                end
                return valueA > valueB
            end)

            local maxQueue = 16
            if ctx.Config and ctx.Config.Orchard and type(ctx.Config.Orchard.MaxAutoEatQueue) == "number" then
                maxQueue = ctx.Config.Orchard.MaxAutoEatQueue
            end

            local queue = {}
            for index, entry in ipairs(inventory) do
                if index > maxQueue then
                    break
                end
                table.insert(queue, entry.Fruit)
            end

            -- Avoid re-sending an identical queue to the server every cycle.
            if type(autoEat.GetAutoEatFruitOrder) == "function" then
                local okOrder, currentOrder = pcall(function()
                    return autoEat:GetAutoEatFruitOrder()
                end)
                if okOrder and type(currentOrder) == "table" and #currentOrder == #queue then
                    local same = true
                    for index, fruit in ipairs(queue) do
                        local current = currentOrder[index]
                        local equal = current == fruit
                        if not equal and current ~= nil and type(fruit.IsEqual) == "function" then
                            local okEqual, isEqual = pcall(function()
                                return fruit:IsEqual(current)
                            end)
                            equal = okEqual and isEqual == true
                        end
                        if not equal then
                            same = false
                            break
                        end
                    end
                    if same then
                        return false
                    end
                end
            end

            local ok = pcall(function()
                autoEat:SetAutoEatOrderAsync(queue)
            end)
            if ok and type(autoEat.EnableAutoEat) == "function" then
                pcall(function()
                    autoEat:EnableAutoEat(true)
                end)
            end
            if ok then
                mountNotify({
                    Title = "Orchard",
                    Content = "Updated auto-eat queue (" .. #queue .. ")",
                    Icon = "check",
                })
            end
            return ok
        end

        local function refreshOrchardPlotFruitsOnce()
            -- Uses OrchardPlot.GetFruit / GetFruitAsync so plot fruit data stays warm for status/UI.
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end
            local orchard = getLocalOrchard(ctx, tycoon)
            if not orchard or not isOrchardUnlocked(orchard, tycoon) then
                return false
            end

            local states = getOrchardPlotStates(ctx)
            local refreshed = 0
            for _, plotInstance in ipairs(collectLocalOrchardPlots(orchard)) do
                if plotInstance:GetAttribute("Enabled") and getPlotState(plotInstance, states) ~= states.Empty then
                    local plotEntity = getPlotEntity(ctx, plotInstance)
                    if plotEntity and type(plotEntity.GetFruitAsync) == "function" then
                        local ok = pcall(function()
                            plotEntity:GetFruitAsync()
                        end)
                        if ok then
                            refreshed += 1
                        end
                    elseif plotEntity and type(plotEntity.GetFruit) == "function" then
                        local ok = pcall(function()
                            plotEntity:GetFruit()
                        end)
                        if ok then
                            refreshed += 1
                        end
                    end
                end
            end
            return refreshed > 0
        end


        OrchardTab:CreateSection("Status")

        do
            local ctxForItems = getSellLemonsGameContext(true)
            if ctxForItems then
                orchardItemOptions = getOrchardItemOptions(ctxForItems)
                if not table.find(orchardItemOptions, orchardSelectedItem) then
                    orchardSelectedItem = orchardItemOptions[1] or "FertilizerMutate"
                end
            end
        end

        orchardInfoParagraph = OrchardTab:CreateParagraph({
            Title = "Orchard",
            Content = "Loading...",
        })

        OrchardTab:CreateButton({
            Name = "Refresh",
            Callback = function()
                pcall(refreshOrchardPlotFruitsOnce)
                requestOrchardInfoRefresh()
            end,
        })

        OrchardTab:CreateInput({
            Name = "Delay (seconds)",
            PlaceholderText = "Seconds between orchard automation checks",
            Flag = "orchard_delay",
            CurrentValue = tostring(orchardDelaySec),
            Callback = function(value)
                orchardDelaySec = math.max(0.1, tonumber(value) or 1)
            end,
        })

        OrchardTab:CreateSection("Unlock")

        OrchardTab:CreateToggle({
            Name = "Auto Unlock Orchard",
            Flag = "orchard_auto_unlock",
            CurrentValue = false,
            Callback = function(enabled)
                autoUnlockOrchardRunning = enabled == true
                if not autoUnlockOrchardRunning then
                    return
                end
                autoUnlockOrchardLoopId += 1
                local loopId = autoUnlockOrchardLoopId
                task.spawn(function()
                    while autoUnlockOrchardRunning and loopId == autoUnlockOrchardLoopId do
                        local ok = pcall(function()
                            tryAutoUnlockOrchardOnce()
                            requestOrchardInfoRefresh()
                        end)
                        local delay = math.max(0.1, tonumber(orchardDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        OrchardTab:CreateToggle({
            Name = "Auto Unlock Plots",
            Flag = "orchard_auto_unlock_plots",
            CurrentValue = false,
            Callback = function(enabled)
                autoUnlockPlotsRunning = enabled == true
                if not autoUnlockPlotsRunning then
                    return
                end
                autoUnlockPlotsLoopId += 1
                local loopId = autoUnlockPlotsLoopId
                task.spawn(function()
                    while autoUnlockPlotsRunning and loopId == autoUnlockPlotsLoopId do
                        local ok = pcall(function()
                            tryAutoUnlockPlotsOnce()
                            requestOrchardInfoRefresh()
                        end)
                        local delay = math.max(0.1, tonumber(orchardDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        OrchardTab:CreateSection("Plots")

        OrchardTab:CreateToggle({
            Name = "Auto Harvest",
            Flag = "orchard_auto_harvest",
            CurrentValue = false,
            Callback = function(enabled)
                autoHarvestOrchardRunning = enabled == true
                if not autoHarvestOrchardRunning then
                    return
                end
                autoHarvestOrchardLoopId += 1
                local loopId = autoHarvestOrchardLoopId
                task.spawn(function()
                    while autoHarvestOrchardRunning and loopId == autoHarvestOrchardLoopId do
                        local ok = pcall(function()
                            tryAutoHarvestOrchardOnce()
                            requestOrchardInfoRefresh()
                        end)
                        local delay = math.max(0.1, tonumber(orchardDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        OrchardTab:CreateToggle({
            Name = "Auto Plant",
            Flag = "orchard_auto_plant",
            CurrentValue = false,
            Callback = function(enabled)
                autoPlantOrchardRunning = enabled == true
                if not autoPlantOrchardRunning then
                    return
                end
                autoPlantOrchardLoopId += 1
                local loopId = autoPlantOrchardLoopId
                task.spawn(function()
                    while autoPlantOrchardRunning and loopId == autoPlantOrchardLoopId do
                        local ok = pcall(function()
                            tryAutoPlantOrchardOnce()
                            requestOrchardInfoRefresh()
                        end)
                        local delay = math.max(0.1, tonumber(orchardDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        OrchardTab:CreateToggle({
            Name = "Auto Destroy Trees",
            Flag = "orchard_auto_destroy",
            CurrentValue = false,
            Callback = function(enabled)
                autoDestroyOrchardRunning = enabled == true
                if not autoDestroyOrchardRunning then
                    return
                end
                autoDestroyOrchardLoopId += 1
                local loopId = autoDestroyOrchardLoopId
                task.spawn(function()
                    while autoDestroyOrchardRunning and loopId == autoDestroyOrchardLoopId do
                        local ok = pcall(function()
                            tryAutoDestroyOrchardOnce()
                            requestOrchardInfoRefresh()
                        end)
                        local delay = math.max(0.1, tonumber(orchardDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        OrchardTab:CreateSection("Items")

        OrchardTab:CreateDropdown({
            Name = "Item",
            Flag = "orchard_item",
            Options = orchardItemOptions,
            CurrentOption = { orchardSelectedItem },
            Callback = function(value)
                local picked = rayfieldDropdownFirst(value)
                if picked and table.find(orchardItemOptions, picked) then
                    orchardSelectedItem = picked
                    requestOrchardInfoRefresh()
                end
            end,
        })

        OrchardTab:CreateToggle({
            Name = "Auto Use Item",
            Flag = "orchard_auto_use_item",
            CurrentValue = false,
            Callback = function(enabled)
                autoUseOrchardItemRunning = enabled == true
                if not autoUseOrchardItemRunning then
                    return
                end
                autoUseOrchardItemLoopId += 1
                local loopId = autoUseOrchardItemLoopId
                task.spawn(function()
                    while autoUseOrchardItemRunning and loopId == autoUseOrchardItemLoopId do
                        local ok = pcall(function()
                            tryAutoUseOrchardItemOnce()
                            requestOrchardInfoRefresh()
                        end)
                        local delay = math.max(0.1, tonumber(orchardDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        OrchardTab:CreateToggle({
            Name = "Auto Buy Items",
            Flag = "orchard_auto_buy_items",
            CurrentValue = false,
            Callback = function(enabled)
                autoBuyOrchardItemsRunning = enabled == true
                if not autoBuyOrchardItemsRunning then
                    return
                end
                autoBuyOrchardItemsLoopId += 1
                local loopId = autoBuyOrchardItemsLoopId
                task.spawn(function()
                    while autoBuyOrchardItemsRunning and loopId == autoBuyOrchardItemsLoopId do
                        local ok = pcall(function()
                            tryAutoBuyOrchardItemsOnce()
                            requestOrchardInfoRefresh()
                        end)
                        local delay = math.max(0.1, tonumber(orchardDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        OrchardTab:CreateSection("Decorations")

        OrchardTab:CreateToggle({
            Name = "Auto Buy Decorations",
            Flag = "orchard_auto_buy_decor",
            CurrentValue = false,
            Callback = function(enabled)
                autoBuyOrchardDecorRunning = enabled == true
                if not autoBuyOrchardDecorRunning then
                    return
                end
                autoBuyOrchardDecorLoopId += 1
                local loopId = autoBuyOrchardDecorLoopId
                task.spawn(function()
                    while autoBuyOrchardDecorRunning and loopId == autoBuyOrchardDecorLoopId do
                        local ok = pcall(function()
                            tryAutoBuyOrchardDecorOnce()
                            requestOrchardInfoRefresh()
                        end)
                        local delay = math.max(0.1, tonumber(orchardDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        OrchardTab:CreateSection("Fruit")

        OrchardTab:CreateToggle({
            Name = "Auto Sell Fruit",
            Flag = "orchard_auto_sell_fruit",
            CurrentValue = false,
            Callback = function(enabled)
                autoSellOrchardFruitRunning = enabled == true
                if not autoSellOrchardFruitRunning then
                    return
                end
                autoSellOrchardFruitLoopId += 1
                local loopId = autoSellOrchardFruitLoopId
                task.spawn(function()
                    while autoSellOrchardFruitRunning and loopId == autoSellOrchardFruitLoopId do
                        local ok = pcall(function()
                            tryAutoSellOrchardFruitOnce()
                            requestOrchardInfoRefresh()
                        end)
                        local delay = math.max(0.1, tonumber(orchardDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        OrchardTab:CreateSection("Auto Eat")

        OrchardTab:CreateToggle({
            Name = "Auto Eat Fruit",
            Flag = "orchard_auto_eat_fruit",
            CurrentValue = false,
            Callback = function(enabled)
                autoEatOrchardFruitRunning = enabled == true
                if not autoEatOrchardFruitRunning then
                    return
                end
                autoEatOrchardFruitLoopId += 1
                local loopId = autoEatOrchardFruitLoopId
                task.spawn(function()
                    while autoEatOrchardFruitRunning and loopId == autoEatOrchardFruitLoopId do
                        local ok = pcall(function()
                            tryAutoEatOrchardFruitOnce()
                            requestOrchardInfoRefresh()
                        end)
                        local delay = math.max(0.1, tonumber(orchardDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        OrchardTab:CreateToggle({
            Name = "Enable Auto Eat Power",
            Flag = "orchard_auto_eat_power",
            CurrentValue = false,
            Callback = function(enabled)
                autoOrchardEatPowerRunning = enabled == true
                if not autoOrchardEatPowerRunning then
                    return
                end
                autoOrchardEatPowerLoopId += 1
                local loopId = autoOrchardEatPowerLoopId
                task.spawn(function()
                    while autoOrchardEatPowerRunning and loopId == autoOrchardEatPowerLoopId do
                        local ok = pcall(function()
                            tryAutoOrchardEatPowerOnce()
                        end)
                        local delay = math.max(0.1, tonumber(orchardDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        OrchardTab:CreateToggle({
            Name = "Auto Fill Eat Queue",
            Flag = "orchard_auto_eat_queue",
            CurrentValue = false,
            Callback = function(enabled)
                autoOrchardEatQueueRunning = enabled == true
                if not autoOrchardEatQueueRunning then
                    return
                end
                autoOrchardEatQueueLoopId += 1
                local loopId = autoOrchardEatQueueLoopId
                task.spawn(function()
                    while autoOrchardEatQueueRunning and loopId == autoOrchardEatQueueLoopId do
                        local ok = pcall(function()
                            tryAutoOrchardEatQueueOnce()
                            requestOrchardInfoRefresh()
                        end)
                        local delay = math.max(0.1, tonumber(orchardDelaySec) or 1)
                        task.wait(if ok then math.max(delay, 2) else math.max(delay, 1))
                    end
                end)
            end,
        })

        task.spawn(function()
            pcall(refreshOrchardPlotFruitsOnce)
            requestOrchardInfoRefresh()
            while orchardInfoParagraph do
                task.wait(orchardInfoAutoRefreshSec)
                requestOrchardInfoRefresh()
            end
        end)

    end

    local function formatHugeAmount(ctx, value, prefix)
        if value == nil then
            return "?"
        end
        if ctx.Huge and type(ctx.Huge.formatAbbreviated) == "function" then
            local ok, text = pcall(function()
                return ctx.Huge.formatAbbreviated(value, prefix or "")
            end)
            if ok and type(text) == "string" and #text > 0 then
                return text
            end
        end
        return tostring(value)
    end

    local function hugeGreaterOrEqual(a, b)
        if a == nil or b == nil then
            return false
        end
        local ok, result = pcall(function()
            return a >= b
        end)
        return ok and result == true
    end

    local function hugeAdd(a, b)
        if a == nil or b == nil then
            return nil
        end
        if cachedHuge and type(cachedHuge.add) == "function" then
            local ok, sum = pcall(function()
                return cachedHuge.add(a, b)
            end)
            if ok then
                return sum
            end
        end
        if type(a) == "number" and type(b) == "number" then
            return a + b
        end
        return nil
    end

    local function hugeMultiply(a, scalar)
        if a == nil or scalar == nil then
            return nil
        end
        if cachedHuge and type(cachedHuge.multiply) == "function" and type(cachedHuge.toHuge) == "function" then
            local ok, product = pcall(function()
                return cachedHuge.multiply(a, cachedHuge.toHuge(scalar))
            end)
            if ok then
                return product
            end
        end
        if type(a) == "number" and type(scalar) == "number" then
            return a * scalar
        end
        return nil
    end

    local function parseHugeInput(value)
        if value == nil then
            return nil
        end

        local strValue = if type(value) == "string" then value:match("^%s*(.-)%s*$") else nil
        local plainNumber = tonumber(strValue or value)

        -- Plain numbers must use tonumber first; Huge.toHuge("1000") mis-parses digit strings.
        if plainNumber ~= nil and (strValue == nil or strValue:match("^[+-]?%d*%.?%d+$")) then
            ensureHugeLoaded()
            if cachedHuge and type(cachedHuge.toHuge) == "function" then
                local ok, hugeValue = pcall(function()
                    return cachedHuge.toHuge(plainNumber)
                end)
                if ok and hugeValue ~= nil then
                    return hugeValue
                end
            end
            return plainNumber
        end

        ensureHugeLoaded()
        if cachedHuge and type(cachedHuge.toHuge) == "function" then
            local ok, hugeValue = pcall(function()
                return cachedHuge.toHuge(strValue or value)
            end)
            if ok and hugeValue ~= nil then
                return hugeValue
            end
        end
        return plainNumber
    end

    local function getTycoonRebirthComponent(ctx, tycoon)
        if tycoon and type(tycoon.GetComponent) == "function" and ctx.ClientTycoonRebirth then
            local ok, component = pcall(function()
                return tycoon:GetComponent(ctx.ClientTycoonRebirth)
            end)
            if ok and component then
                return component
            end
        end
        return nil
    end

    local function getTycoonBalancesComponent(ctx, tycoon)
        if tycoon and type(tycoon.GetComponent) == "function" and ctx.ClientTycoonBalances then
            local ok, component = pcall(function()
                return tycoon:GetComponent(ctx.ClientTycoonBalances)
            end)
            if ok and component then
                return component
            end
        end
        return nil
    end

    local function getCurrentInvestors(ctx, tycoon)
        local balances = getTycoonBalancesComponent(ctx, tycoon)
        if balances and type(balances.GetInvestors) == "function" then
            local ok, investors = pcall(function()
                return balances:GetInvestors()
            end)
            if ok and investors ~= nil then
                return investors
            end
        end
        return nil
    end

    local function installAutoRebirthEvolve()
        local function getAutoEvolveStartingBonusTarget()
            local parsed = parseHugeInput(autoEvolveStartingBonusTarget)
            if parsed == nil then
                return 0
            end
            return parsed
        end

        local function shouldAutoEvolve(progressInfo, startingBonusTarget)
            if not progressInfo or not progressInfo.ready then
                return false
            end
            if progressInfo.startingBonus == nil then
                return false
            end
            if startingBonusTarget == nil then
                return true
            end
            local ok, isZeroOrLess = pcall(function()
                return startingBonusTarget <= 0
            end)
            if ok and isZeroOrLess then
                return true
            end
            return hugeGreaterOrEqual(progressInfo.startingBonus, startingBonusTarget)
        end

        local function getPotentialInvestorsFromRebirth(ctx, tycoon)
            local rebirth = getTycoonRebirthComponent(ctx, tycoon)
            if rebirth and type(rebirth.GetPotentialInvestors) == "function" then
                local ok, investors = pcall(function()
                    return rebirth:GetPotentialInvestors()
                end)
                if ok and investors ~= nil then
                    return investors
                end
            end
            return nil
        end

        local function getRequiredRebirthGain(currentInvestors, targetPercent)
            local percent = tonumber(targetPercent)
            if not currentInvestors or not percent or percent <= 0 then
                return nil
            end
            return hugeMultiply(currentInvestors, percent / 100)
        end

        local function shouldAutoRebirth(currentInvestors, potentialInvestors, targetPercent)
            local requiredGain = getRequiredRebirthGain(currentInvestors, targetPercent)
            if not requiredGain or not potentialInvestors then
                return false
            end
            return hugeGreaterOrEqual(potentialInvestors, requiredGain)
        end

        local function findRebirthRemote(tycoonInstance)
            local remotes = tycoonInstance and tycoonInstance:FindFirstChild("Remotes")
            local rebirthRemote = remotes and remotes:FindFirstChild("Rebirth")
            if rebirthRemote and rebirthRemote:IsA("RemoteFunction") then
                return rebirthRemote
            end
            return nil
        end

        local function getRebirthInfoContent()
            local ctx, ctxErr = getSellLemonsGameContext(true)
            if not ctx then
                return ctxErr or "Could not load game data."
            end

            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return "Waiting for tycoon..."
            end

            local currentInvestors = getCurrentInvestors(ctx, tycoon)
            local potentialInvestors = getPotentialInvestorsFromRebirth(ctx, tycoon)
            if currentInvestors == nil or potentialInvestors == nil then
                return "Could not read investor data."
            end

            local afterRebirth = hugeAdd(currentInvestors, potentialInvestors)
            local requiredGain = getRequiredRebirthGain(currentInvestors, rebirthTargetPercent)
            local ready = shouldAutoRebirth(currentInvestors, potentialInvestors, rebirthTargetPercent)

            local lines = {
                string.format("Own Investors: %s", formatHugeAmount(ctx, currentInvestors)),
                string.format("Gain from Rebirth: %s", formatHugeAmount(ctx, potentialInvestors)),
                string.format("After Rebirth: %s", formatHugeAmount(ctx, afterRebirth)),
                string.format(
                    "Target Gain (%s%%): %s",
                    tostring(rebirthTargetPercent),
                    formatHugeAmount(ctx, requiredGain)
                ),
                string.format("Ready to Rebirth: %s", if ready then "Yes" else "No"),
            }
            return table.concat(lines, "\n")
        end

        local function applyRebirthInfoParagraph(content)
            if not rebirthInfoParagraph then
                return
            end
            task.defer(function()
                if not rebirthInfoParagraph then
                    return
                end
                rebirthInfoParagraph:Set({
                    Title = "Investors",
                    Content = content,
                })
            end)
        end

        local function requestRebirthInfoRefresh()
            task.spawn(function()
                local ok, contentOrErr = pcall(getRebirthInfoContent)
                applyRebirthInfoParagraph(if ok then contentOrErr else ("Refresh error: " .. tostring(contentOrErr)))
            end)
        end

        local function tryAutoRebirthOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end

            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end

            local currentInvestors = getCurrentInvestors(ctx, tycoon)
            local potentialInvestors = getPotentialInvestorsFromRebirth(ctx, tycoon)
            if not shouldAutoRebirth(currentInvestors, potentialInvestors, rebirthTargetPercent) then
                return false
            end

            local remote = findRebirthRemote(tycoon.Instance)
            if not remote then
                return false
            end

            local ok = pcall(function()
                remote:InvokeServer(nil)
            end)
            if ok then
                mountNotify({
                    Title = "Auto Rebirth",
                    Content = string.format(
                        "Rebirthed with %s investors gained.",
                        formatHugeAmount(ctx, potentialInvestors)
                    ),
                    Icon = "check",
                })
            end
            return ok
        end

        local function getTycoonEvolutionComponent(ctx, tycoon)
            if tycoon and type(tycoon.GetComponent) == "function" and ctx.ClientTycoonEvolution then
                local ok, component = pcall(function()
                    return tycoon:GetComponent(ctx.ClientTycoonEvolution)
                end)
                if ok and component then
                    return component
                end
            end
            return nil
        end

        local function getEvolutionDisplayName(evolution, displayInfo)
            if type(displayInfo) == "table" and type(displayInfo.Name) == "string" and displayInfo.Name ~= "" then
                return displayInfo.Name
            end
            return tostring(evolution)
        end

        local function formatEvolutionProgressPercent(progress)
            if type(progress) ~= "number" then
                return "?"
            end
            local shown = progress
            if shown < 1 then
                shown = math.min(shown, 0.9945)
            end
            local decimals = if shown > 0.0995 then 0 else 1
            local text = string.format("%." .. tostring(decimals) .. "f", shown * 100)
            return text:gsub("%.?0+$", "") .. "%"
        end

        local function getEvolutionProgressInfo(ctx, tycoon)
            local evolution = getTycoonEvolutionComponent(ctx, tycoon)
            if not evolution or type(evolution.GetEvolutionProgress) ~= "function" then
                return nil
            end

            local ok, progress, startingBonus = pcall(function()
                return evolution:GetEvolutionProgress()
            end)
            if not ok then
                return nil
            end

            return {
                progress = progress,
                startingBonus = startingBonus,
                ready = type(progress) == "number" and progress >= 1,
            }
        end

        local function getEvolutionInfoContent()
            local ctx, ctxErr = getSellLemonsGameContext(true)
            if not ctx then
                return ctxErr or "Could not load game data."
            end

            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return "Waiting for tycoon..."
            end

            local evolution = getTycoonEvolutionComponent(ctx, tycoon)
            if not evolution then
                return "Could not read evolution data."
            end

            local currentLevel
            local currentDisplay
            local nextDisplay
            local incomeBonus
            local okLevel, levelOrErr = pcall(function()
                return evolution:GetEvolution()
            end)
            if not okLevel then
                return "Could not read evolution level."
            end
            currentLevel = levelOrErr

            local okCurrent, currentInfo = pcall(function()
                return evolution:GetEvolutionDisplayInfo()
            end)
            if okCurrent then
                currentDisplay = currentInfo
            end

            local okNext, nextInfo = pcall(function()
                return evolution:GetEvolutionDisplayInfo(currentLevel + 1)
            end)
            if okNext then
                nextDisplay = nextInfo
            end

            local okBonus, bonusOrErr = pcall(function()
                return evolution:GetEvolutionBonus()
            end)
            if okBonus and type(bonusOrErr) == "number" then
                incomeBonus = bonusOrErr
            end

            local progressInfo = getEvolutionProgressInfo(ctx, tycoon)
            if not progressInfo then
                return "Could not read evolution progress."
            end

            local lines = {
                string.format("Current Fruit: %s", getEvolutionDisplayName(currentLevel, currentDisplay)),
                string.format("Current Evolution: %s", tostring(currentLevel)),
                string.format(
                    "Next Fruit: %s",
                    getEvolutionDisplayName(currentLevel + 1, nextDisplay)
                ),
                string.format("Progress: %s", formatEvolutionProgressPercent(progressInfo.progress)),
            }

            if progressInfo.ready and progressInfo.startingBonus ~= nil then
                table.insert(lines, string.format(
                    "Starting Bonus: %s",
                    formatHugeAmount(ctx, progressInfo.startingBonus)
                ))
            end

            if incomeBonus then
                table.insert(lines, string.format(
                    "Income Bonus: x%s income speed",
                    tostring(math.round(incomeBonus))
                ))
            end

            local startingBonusTarget = getAutoEvolveStartingBonusTarget()
            local ready = shouldAutoEvolve(progressInfo, startingBonusTarget)
            table.insert(lines, string.format(
                "Target Starting Bonus: %s",
                formatHugeAmount(ctx, startingBonusTarget)
            ))

            table.insert(lines, string.format(
                "Ready to Evolve: %s",
                if ready then "Yes" else "No"
            ))

            return table.concat(lines, "\n")
        end

        local function applyEvolutionInfoParagraph(content)
            if not evolutionInfoParagraph then
                return
            end
            task.defer(function()
                if not evolutionInfoParagraph then
                    return
                end
                evolutionInfoParagraph:Set({
                    Title = "Evolution",
                    Content = content,
                })
            end)
        end

        local function requestEvolutionInfoRefresh()
            task.spawn(function()
                local ok, contentOrErr = pcall(getEvolutionInfoContent)
                applyEvolutionInfoParagraph(if ok then contentOrErr else ("Refresh error: " .. tostring(contentOrErr)))
            end)
        end

        local function findEvolveRemote(tycoonInstance)
            local remotes = tycoonInstance and tycoonInstance:FindFirstChild("Remotes")
            local evolveRemote = remotes and remotes:FindFirstChild("Evolve")
            if evolveRemote and evolveRemote:IsA("RemoteFunction") then
                return evolveRemote
            end
            return nil
        end

        local function tryAutoEvolveOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end

            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end

            local progressInfo = getEvolutionProgressInfo(ctx, tycoon)
            if not progressInfo or not shouldAutoEvolve(progressInfo, getAutoEvolveStartingBonusTarget()) then
                return false
            end

            local remote = findEvolveRemote(tycoon.Instance)
            if not remote then
                return false
            end

            local ok = pcall(function()
                remote:InvokeServer(nil)
            end)
            if ok then
                mountNotify({
                    Title = "Auto Evolve",
                    Content = string.format(
                        "Evolved at %s progress with %s starting bonus.",
                        formatEvolutionProgressPercent(progressInfo.progress),
                        formatHugeAmount(ctx, progressInfo.startingBonus)
                    ),
                    Icon = "check",
                })
            end
            return ok
        end


        MainTab:CreateSection("Auto Rebirth")

        rebirthInfoParagraph = MainTab:CreateParagraph({
            Title = "Investors",
            Content = "Loading...",
        })

        MainTab:CreateInput({
            Name = "Target Gain (%)",
            PlaceholderText = "Percent of own investors to gain before rebirth",
            Flag = "main_rebirth_target_percent",
            CurrentValue = tostring(rebirthTargetPercent),
            Callback = function(value)
                rebirthTargetPercent = math.max(0, tonumber(value) or rebirthTargetPercent)
                requestRebirthInfoRefresh()
            end,
        })

        MainTab:CreateInput({
            Name = "Delay (seconds)",
            PlaceholderText = "Seconds between auto rebirth checks",
            Flag = "main_auto_rebirth_delay",
            CurrentValue = tostring(autoRebirthDelaySec),
            Callback = function(value)
                autoRebirthDelaySec = math.max(0.1, tonumber(value) or 1)
            end,
        })

        MainTab:CreateToggle({
            Name = "Auto Rebirth",
            Flag = "main_auto_rebirth",
            CurrentValue = false,
            Callback = function(enabled)
                autoRebirthRunning = enabled == true
                if not autoRebirthRunning then
                    return
                end

                autoRebirthLoopId += 1
                local loopId = autoRebirthLoopId
                task.spawn(function()
                    while autoRebirthRunning and loopId == autoRebirthLoopId do
                        local ok = pcall(function()
                            tryAutoRebirthOnce()
                            requestRebirthInfoRefresh()
                            applyPlayerInfoParagraph()
                        end)
                        local delay = math.max(0.1, tonumber(autoRebirthDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        task.spawn(function()
            requestRebirthInfoRefresh()
            while rebirthInfoParagraph do
                task.wait(rebirthInfoAutoRefreshSec)
                requestRebirthInfoRefresh()
            end
        end)

        MainTab:CreateSection("Auto Evolve")

        evolutionInfoParagraph = MainTab:CreateParagraph({
            Title = "Evolution",
            Content = "Loading...",
        })

        MainTab:CreateInput({
            Name = "Starting Bonus",
            PlaceholderText = "Minimum starting bonus before evolve (0 = any)",
            Flag = "main_auto_evolve_starting_bonus",
            CurrentValue = tostring(autoEvolveStartingBonusTarget),
            Callback = function(value)
                if type(value) == "string" and #value > 0 then
                    autoEvolveStartingBonusTarget = value
                else
                    autoEvolveStartingBonusTarget = tostring(tonumber(value) or 0)
                end
                requestEvolutionInfoRefresh()
            end,
        })

        MainTab:CreateInput({
            Name = "Delay (seconds)",
            PlaceholderText = "Seconds between auto evolve checks",
            Flag = "main_auto_evolve_delay",
            CurrentValue = tostring(autoEvolveDelaySec),
            Callback = function(value)
                autoEvolveDelaySec = math.max(0.1, tonumber(value) or 1)
            end,
        })

        MainTab:CreateToggle({
            Name = "Auto Evolve",
            Flag = "main_auto_evolve",
            CurrentValue = false,
            Callback = function(enabled)
                autoEvolveRunning = enabled == true
                if not autoEvolveRunning then
                    return
                end

                autoEvolveLoopId += 1
                local loopId = autoEvolveLoopId
                task.spawn(function()
                    while autoEvolveRunning and loopId == autoEvolveLoopId do
                        local ok = pcall(function()
                            tryAutoEvolveOnce()
                            requestEvolutionInfoRefresh()
                            applyPlayerInfoParagraph()
                        end)
                        local delay = math.max(0.1, tonumber(autoEvolveDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        task.spawn(function()
            requestEvolutionInfoRefresh()
            while evolutionInfoParagraph do
                task.wait(evolutionInfoAutoRefreshSec)
                requestEvolutionInfoRefresh()
            end
        end)

    end

    MainTab:CreateSection("Player Information")

    playerInfoParagraph = MainTab:CreateParagraph({
        Title = "Player Information",
        Content = "Loading...",
    })

    MainTab:CreateSection("Auto Purchase")

    purchaseListParagraph = MainTab:CreateParagraph({
        Title = "Buyable Buttons",
        Content = "Loading...",
    })

    MainTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            requestPurchaseListRefresh(false, true, function(snapshot, alreadyRefreshing)
                if alreadyRefreshing then
                    mountNotify({
                        Title = "Buyable Buttons",
                        Content = "Already refreshing...",
                        Icon = "x",
                    })
                    return
                end

                mountNotify({
                    Title = snapshot.title,
                    Content = snapshot.content,
                    Icon = snapshot.icon,
                    Duration = 8,
                })
            end)
        end,
    })

    MainTab:CreateInput({
        Name = "Delay (seconds)",
        PlaceholderText = "Seconds between auto purchases",
        Flag = "main_auto_purchase_delay",
        CurrentValue = tostring(autoPurchaseDelaySec),
        Callback = function(value)
            autoPurchaseDelaySec = math.max(0.1, tonumber(value) or 0.5)
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Purchase",
        Flag = "main_auto_purchase",
        CurrentValue = false,
        Callback = function(enabled)
            autoPurchaseRunning = enabled == true
            if not autoPurchaseRunning then
                return
            end

            autoPurchaseLoopId += 1
            local loopId = autoPurchaseLoopId
            task.spawn(function()
                while autoPurchaseRunning and loopId == autoPurchaseLoopId do
                    local ok = pcall(function()
                        tryAutoPurchaseOnce()
                        applyPlayerInfoParagraph()
                        requestPurchaseListRefresh(false, false)
                    end)
                    local delay = math.max(0.1, tonumber(autoPurchaseDelaySec) or 0.5)
                    task.wait(if ok then delay else math.max(delay, 1))
                end
            end)
        end,
    })

    task.spawn(function()
        applyPlayerInfoParagraph()
        requestPurchaseListRefresh(false, false)
        while purchaseListParagraph do
            task.wait(purchaseListAutoRefreshSec)
            requestPurchaseListRefresh(false, false)
        end
    end)

    MainTab:CreateSection("Cash Earner")

    upgradeListParagraph = MainTab:CreateParagraph({
        Title = "Cash Earned",
        Content = "Loading...",
    })

    MainTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            requestUpgradeListRefresh(true)
        end,
    })

    MainTab:CreateInput({
        Name = "Delay (seconds)",
        PlaceholderText = "Seconds between auto upgrades",
        Flag = "main_auto_upgrade_delay",
        CurrentValue = tostring(autoUpgradeDelaySec),
        Callback = function(value)
            autoUpgradeDelaySec = math.max(0.1, tonumber(value) or 0.5)
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Upgrade",
        Flag = "main_auto_upgrade",
        CurrentValue = false,
        Callback = function(enabled)
            autoUpgradeRunning = enabled == true
            if not autoUpgradeRunning then
                return
            end

            autoUpgradeLoopId += 1
            local loopId = autoUpgradeLoopId
            task.spawn(function()
                while autoUpgradeRunning and loopId == autoUpgradeLoopId do
                    local ok = pcall(function()
                        tryAutoUpgradeOnce()
                        requestUpgradeListRefresh(false)
                    end)
                    local delay = math.max(0.1, tonumber(autoUpgradeDelaySec) or 0.5)
                    task.wait(if ok then delay else math.max(delay, 1))
                end
            end)
        end,
    })

    MainTab:CreateInput({
        Name = "Claim Delay (seconds)",
        PlaceholderText = "Seconds between auto cash claims",
        Flag = "main_auto_claim_cash_delay",
        CurrentValue = tostring(autoClaimCashDelaySec),
        Callback = function(value)
            autoClaimCashDelaySec = math.max(0.1, tonumber(value) or 0.5)
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Claim Cash",
        Flag = "main_auto_claim_cash",
        CurrentValue = false,
        Callback = function(enabled)
            autoClaimCashRunning = enabled == true
            if not autoClaimCashRunning then
                return
            end

            autoClaimCashLoopId += 1
            local loopId = autoClaimCashLoopId
            task.spawn(function()
                while autoClaimCashRunning and loopId == autoClaimCashLoopId do
                    local ok = pcall(function()
                        tryAutoClaimCashOnce()
                        applyPlayerInfoParagraph()
                    end)
                    local delay = math.max(0.1, tonumber(autoClaimCashDelaySec) or 0.5)
                    task.wait(if ok then delay else math.max(delay, 1))
                end
            end)
        end,
    })

    local function installAutoClaimOfflineCash()
        local autoClaimOfflineRunning = false
        local autoClaimOfflineLoopId = 0
        local autoClaimOfflineDelaySec = 1
        local autoClaimOfflineUseFreeDouble = true
        local offlineClaimedThisSession = false

        local function isPositiveAmount(value)
            if value == nil then
                return false
            end
            if type(value) == "number" then
                return value > 0
            end
            local ok, greater = pcall(function()
                return value > 0
            end)
            return ok and greater == true
        end

        local function getOfflineIncomeComponent(ctx, tycoon)
            if tycoon and type(tycoon.GetComponent) == "function" and ctx.ClientTycoonOfflineIncome then
                local ok, component = pcall(function()
                    return tycoon:GetComponent(ctx.ClientTycoonOfflineIncome)
                end)
                if ok and component then
                    return component
                end
            end
            return nil
        end

        local function getPremiumPurchasesComponent(ctx)
            if not ctx.LocalPlayer or type(ctx.LocalPlayer.get) ~= "function" or not ctx.PremiumPurchases then
                return nil
            end
            local okPlayer, playerEntity = pcall(function()
                return ctx.LocalPlayer.get()
            end)
            if not okPlayer or not playerEntity or type(playerEntity.GetComponent) ~= "function" then
                return nil
            end
            local ok, component = pcall(function()
                return playerEntity:GetComponent(ctx.PremiumPurchases)
            end)
            if ok and component then
                return component
            end
            return nil
        end

        local function getUnclaimedOfflineCash(offline, tycoon)
            if offline and type(offline.GetUnclaimedOfflineCash) == "function" then
                local ok, cash = pcall(function()
                    return offline:GetUnclaimedOfflineCash()
                end)
                if ok and cash ~= nil then
                    return cash
                end
            end
            if offline and type(offline.GetOfflineCash) == "function" then
                local ok, cash = pcall(function()
                    return offline:GetOfflineCash()
                end)
                if ok and cash ~= nil then
                    return cash
                end
            end
            local values = tycoon and tycoon.Instance and tycoon.Instance:FindFirstChild("Values")
            if values then
                local attr = values:GetAttribute("OfflineCash")
                if attr ~= nil then
                    return attr
                end
            end
            return nil
        end

        local function hasUnclaimedOfflineCash(ctx, tycoon, offline)
            local cash = getUnclaimedOfflineCash(offline, tycoon)
            if isPositiveAmount(cash) then
                return true, cash
            end
            if offline and type(offline.GetUnclaimedOfflineTime) == "function" then
                local ok, offlineTime = pcall(function()
                    return offline:GetUnclaimedOfflineTime()
                end)
                if ok and type(offlineTime) == "number" and offlineTime > 0 then
                    return true, cash
                end
            end
            -- Offline popup still open after join.
            for _, gui in CollectionService:GetTagged("UI.OfflineCash") do
                if gui:IsA("GuiObject") and gui.Visible then
                    return true, cash
                end
                local visible = gui:GetAttribute("Visible")
                if visible == true then
                    return true, cash
                end
            end
            return false, cash
        end

        local function hasFreeDoubleOfflineCharge(ctx)
            local premium = getPremiumPurchasesComponent(ctx)
            if not premium then
                return false
            end
            if type(premium.GetAvailable) == "function" then
                local ok, available = pcall(function()
                    return premium:GetAvailable("DoubleOfflineCash")
                end)
                if ok and (tonumber(available) or 0) > 0 then
                    return true
                end
            end
            if type(premium.GetCount) == "function" and type(premium.GetUses) == "function" then
                local okCount, count = pcall(function()
                    return premium:GetCount("DoubleOfflineCash")
                end)
                local okUses, uses = pcall(function()
                    return premium:GetUses("DoubleOfflineCash")
                end)
                if okCount and okUses and (tonumber(count) or 0) > (tonumber(uses) or 0) then
                    return true
                end
            end
            return false
        end

        local function hideOfflineCashUi()
            for _, gui in CollectionService:GetTagged("UI.OfflineCash") do
                pcall(function()
                    if gui:IsA("GuiObject") then
                        gui.Visible = false
                    end
                    if type(gui.SetAttribute) == "function" then
                        gui:SetAttribute("Visible", false)
                    end
                end)
            end
        end

        local function findOfflineClaimRemote(tycoonInstance)
            local remotes = tycoonInstance and tycoonInstance:FindFirstChild("Remotes")
            local remote = remotes and remotes:FindFirstChild("PlayerClaimed")
            if remote and remote:IsA("RemoteFunction") then
                return remote
            end
            return nil
        end

        local function findDoubleOfflineRemote(tycoonInstance)
            local remotes = tycoonInstance and tycoonInstance:FindFirstChild("Remotes")
            local remote = remotes and remotes:FindFirstChild("DoubleOfflineCash")
            if remote and remote:IsA("RemoteFunction") then
                return remote
            end
            return nil
        end

        local function tryAutoClaimOfflineCashOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end
            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end

            local offline = getOfflineIncomeComponent(ctx, tycoon)
            local hasUnclaimed, cash = hasUnclaimedOfflineCash(ctx, tycoon, offline)
            if not hasUnclaimed then
                return false
            end

            local usedDouble = false
            if autoClaimOfflineUseFreeDouble and hasFreeDoubleOfflineCharge(ctx) then
                if offline and type(offline.DoubleOfflineCashAsync) == "function" then
                    local okDouble = pcall(function()
                        return offline:DoubleOfflineCashAsync()
                    end)
                    usedDouble = okDouble == true
                else
                    local doubleRemote = findDoubleOfflineRemote(tycoon.Instance)
                    if doubleRemote then
                        usedDouble = pcall(function()
                            doubleRemote:InvokeServer()
                        end) == true
                    end
                end
            end

            local ok = false
            if offline and type(offline.FlagOfflineAsClaimedAsync) == "function" then
                local callOk, result = pcall(function()
                    return offline:FlagOfflineAsClaimedAsync()
                end)
                ok = callOk == true and result ~= false
            else
                local remote = findOfflineClaimRemote(tycoon.Instance)
                if remote then
                    local callOk, result = pcall(function()
                        return remote:InvokeServer()
                    end)
                    ok = callOk == true and result ~= false
                end
            end

            if ok then
                offlineClaimedThisSession = true
                hideOfflineCashUi()
                mountNotify({
                    Title = "Offline Cash",
                    Content = if usedDouble
                        then "Claimed offline cash (free double applied)."
                        else "Claimed offline cash.",
                    Icon = "check",
                })
                applyPlayerInfoParagraph()
            end
            return ok
        end

        MainTab:CreateSection("Auto Claim Offline Cash")

        MainTab:CreateInput({
            Name = "Delay (seconds)",
            PlaceholderText = "Seconds between offline cash claim checks",
            Flag = "main_auto_claim_offline_delay",
            CurrentValue = tostring(autoClaimOfflineDelaySec),
            Callback = function(value)
                autoClaimOfflineDelaySec = math.max(0.1, tonumber(value) or 1)
            end,
        })

        MainTab:CreateToggle({
            Name = "Use Free Double",
            Flag = "main_auto_claim_offline_free_double",
            CurrentValue = autoClaimOfflineUseFreeDouble,
            Callback = function(enabled)
                autoClaimOfflineUseFreeDouble = enabled == true
            end,
        })

        MainTab:CreateToggle({
            Name = "Auto Claim Offline Cash",
            Flag = "main_auto_claim_offline",
            CurrentValue = false,
            Callback = function(enabled)
                autoClaimOfflineRunning = enabled == true
                if not autoClaimOfflineRunning then
                    return
                end

                autoClaimOfflineLoopId += 1
                local loopId = autoClaimOfflineLoopId
                offlineClaimedThisSession = false
                task.spawn(function()
                    -- Offline popup/data can arrive shortly after join; retry quickly first.
                    for _ = 1, 12 do
                        if not (autoClaimOfflineRunning and loopId == autoClaimOfflineLoopId) then
                            return
                        end
                        local claimed = false
                        pcall(function()
                            claimed = tryAutoClaimOfflineCashOnce() == true
                        end)
                        if claimed or offlineClaimedThisSession then
                            break
                        end
                        task.wait(0.5)
                    end

                    while autoClaimOfflineRunning and loopId == autoClaimOfflineLoopId do
                        local ok = pcall(function()
                            tryAutoClaimOfflineCashOnce()
                        end)
                        local delay = math.max(0.1, tonumber(autoClaimOfflineDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })
    end

    installAutoClaimOfflineCash()

    task.spawn(function()
        requestUpgradeListRefresh(false)
        while upgradeListParagraph do
            task.wait(upgradeListAutoRefreshSec)
            requestUpgradeListRefresh(false)
        end
    end)

    installOrchardAutomation()

    local function installMinigamesAutomation()
        local MinigamesTab = Window:CreateTab("Minigames", "gamepad-2")

        local tradeInfoParagraph
        local raceInfoParagraph
        local minigameInfoAutoRefreshSec = 1
        local tradeDelaySec = 1
        local raceDelaySec = 1
        local autoTradeRunning = false
        local autoTradeLoopId = 0
        local autoRaceRunning = false
        local autoRaceLoopId = 0
        local tradeBusy = false
        local raceBusy = false
        local lastTradeResult = "-"
        local lastRaceResult = "-"

        local cachedMinigameRemotes = {}
        local cachedPlayerValuesComponent = false

        local function findMinigameRemote(remoteName, allowDeepSearch)
            local cached = cachedMinigameRemotes[remoteName]
            if cached and cached.Parent then
                return cached
            end

            -- Prefer shallow lookups; full RS recurse is last resort.
            local direct = ReplicatedStorage:FindFirstChild(remoteName)
            if direct and direct:IsA("RemoteFunction") then
                cachedMinigameRemotes[remoteName] = direct
                return direct
            end

            for _, folderName in ipairs({ "Remotes", "RemoteFunctions", "Networking" }) do
                local folder = ReplicatedStorage:FindFirstChild(folderName)
                local remote = folder and folder:FindFirstChild(remoteName)
                if remote and remote:IsA("RemoteFunction") then
                    cachedMinigameRemotes[remoteName] = remote
                    return remote
                end
            end

            if allowDeepSearch == false then
                return nil
            end

            local remote = ReplicatedStorage:FindFirstChild(remoteName, true)
            if remote and remote:IsA("RemoteFunction") then
                cachedMinigameRemotes[remoteName] = remote
                return remote
            end
            return nil
        end

        local function readValueFromInstance(container, key)
            if not container then
                return nil
            end
            local attr = container:GetAttribute(key)
            if attr ~= nil then
                return attr
            end
            local child = container:FindFirstChild(key)
            if child and child:IsA("ValueBase") then
                return child.Value
            end
            return nil
        end

        -- PlayerValues is an InstanceTable("Values") on the player instance.
        local function getPlayerValue(key)
            local player = Players.LocalPlayer
            if not player then
                return nil
            end

            local direct = readValueFromInstance(player, key)
            if direct ~= nil then
                return direct
            end

            local valuesFolder = player:FindFirstChild("Values")
            local fromFolder = readValueFromInstance(valuesFolder, key)
            if fromFolder ~= nil then
                return fromFolder
            end

            if cachedPlayerValuesComponent ~= false then
                local component = cachedPlayerValuesComponent
                if component and type(component.Get) == "function" then
                    local ok, value = pcall(function()
                        return component:Get(key)
                    end)
                    if ok and value ~= nil then
                        return value
                    end
                end
                return nil
            end

            -- Resolve component once; never block status UI on a hanging require.
            cachedPlayerValuesComponent = nil
            task.spawn(function()
                local playerValuesMod = tryRequirePath({ "Core", "PlayerValues" })
                local playerMod = tryRequirePath({ "Core", "Player" })
                local entity = nil
                if playerMod and type(playerMod.getLocal) == "function" then
                    local okEntity, result = pcall(function()
                        return playerMod.getLocal()
                    end)
                    if okEntity then
                        entity = result
                    end
                end
                if not entity then
                    local ctx = getSellLemonsGameContext(true)
                    if ctx and ctx.LocalPlayer and type(ctx.LocalPlayer.get) == "function" then
                        local okEntity, result = pcall(function()
                            return ctx.LocalPlayer.get()
                        end)
                        if okEntity then
                            entity = result
                        end
                    end
                end
                if playerValuesMod and entity and type(entity.GetComponent) == "function" then
                    local okComp, component = pcall(function()
                        return entity:GetComponent(playerValuesMod)
                    end)
                    if okComp and component then
                        cachedPlayerValuesComponent = component
                    end
                end
            end)

            return nil
        end

        local function formatDurationSeconds(seconds)
            local rem = math.max(0, math.floor(tonumber(seconds) or 0))
            local hours = math.floor(rem / 3600)
            local mins = math.floor((rem % 3600) / 60)
            local secs = rem % 60
            if hours > 0 then
                return string.format("%dh %dm %ds", hours, mins, secs)
            end
            if mins > 0 then
                return string.format("%dm %ds", mins, secs)
            end
            return string.format("%ds", secs)
        end

        local function getAvailabilityStatus(availableAt)
            local readyAt = tonumber(availableAt) or 0
            local now = Workspace:GetServerTimeNow()
            if readyAt <= 0 or readyAt <= now then
                return true, "Ready", 0
            end
            return false, formatDurationSeconds(readyAt - now), readyAt - now
        end

        local function formatRewardAmount(value)
            local ctx = getSellLemonsGameContext(false)
            if ctx then
                return formatHugeAmount(ctx, value, "$")
            end
            ensureHugeLoaded()
            if cachedHuge and type(cachedHuge.formatAbbreviated) == "function" then
                local ok, text = pcall(function()
                    return cachedHuge.formatAbbreviated(value, "$")
                end)
                if ok and type(text) == "string" and #text > 0 then
                    return text
                end
            end
            return tostring(value)
        end

        local function isPositiveHuge(value)
            if value == nil or value == false then
                return false
            end
            if type(value) == "number" then
                return value > 0
            end
            ensureHugeLoaded()
            if cachedHuge and cachedHuge.zero ~= nil then
                local ok, greater = pcall(function()
                    return value > cachedHuge.zero
                end)
                if ok then
                    return greater == true
                end
            end
            local ok, greater = pcall(function()
                return value > 0
            end)
            return ok and greater == true
        end

        local function getTradeInfoContent()
            local availableAt = getPlayerValue("MinigameTradeAvailable") or 0
            local played = getPlayerValue("MinigameTradePlayed") or 0
            local ready, readyText = getAvailabilityStatus(availableAt)
            -- Avoid deep RS scans on the status refresh path (can stall the UI).
            local startRemote = findMinigameRemote("MinigameTradeService.Start", false)
            local endRemote = findMinigameRemote("MinigameTradeService.End", false)
            return table.concat({
                string.format("Status: %s", if ready then "Ready" else ("Cooldown " .. readyText)),
                string.format("Times Played: %s", tostring(played)),
                string.format("Last Result: %s", lastTradeResult),
                string.format("Remotes: Start=%s End=%s", startRemote and "OK" or "?", endRemote and "OK" or "?"),
                string.format("Auto: %s", autoTradeRunning and "On" or "Off"),
            }, "\n")
        end

        local function getRaceInfoContent()
            local availableAt = getPlayerValue("MinigameRaceAvailable") or 0
            local played = getPlayerValue("MinigameRacePlayed") or 0
            local ready, readyText = getAvailabilityStatus(availableAt)
            local startRemote = findMinigameRemote("MinigameRaceService.Start", false)
            local endRemote = findMinigameRemote("MinigameRaceService.End", false)
            return table.concat({
                string.format("Status: %s", if ready then "Ready" else ("Cooldown " .. readyText)),
                string.format("Times Played: %s", tostring(played)),
                string.format("Last Result: %s", lastRaceResult),
                string.format("Remotes: Start=%s End=%s", startRemote and "OK" or "?", endRemote and "OK" or "?"),
                string.format("Auto: %s", autoRaceRunning and "On" or "Off"),
            }, "\n")
        end

        local function applyTradeInfo(content)
            if not tradeInfoParagraph then
                return
            end
            task.defer(function()
                if not tradeInfoParagraph then
                    return
                end
                tradeInfoParagraph:Set({
                    Title = "Lemon Trading",
                    Content = content,
                })
            end)
        end

        local function applyRaceInfo(content)
            if not raceInfoParagraph then
                return
            end
            task.defer(function()
                if not raceInfoParagraph then
                    return
                end
                raceInfoParagraph:Set({
                    Title = "LemonDash Race",
                    Content = content,
                })
            end)
        end

        local function refreshMinigameInfo()
            task.spawn(function()
                local okTrade, tradeContent = pcall(getTradeInfoContent)
                applyTradeInfo(if okTrade then tradeContent else ("Refresh error: " .. tostring(tradeContent)))
                local okRace, raceContent = pcall(getRaceInfoContent)
                applyRaceInfo(if okRace then raceContent else ("Refresh error: " .. tostring(raceContent)))
            end)
        end

        -- Skip the long client UI: Start then End with max reward / 1st place.
        local function playTradeOnce()
            if tradeBusy then
                return false, "busy"
            end
            tradeBusy = true
            local ok, result, detail = pcall(function()
                local availableAt = getPlayerValue("MinigameTradeAvailable") or 0
                local ready = select(1, getAvailabilityStatus(availableAt))
                if not ready then
                    return false, "not ready"
                end

                local startRemote = findMinigameRemote("MinigameTradeService.Start")
                local endRemote = findMinigameRemote("MinigameTradeService.End")
                if not startRemote or not endRemote then
                    return false, "remotes missing"
                end

                local session, startErr = startRemote:InvokeServer()
                if not session then
                    return false, tostring(startErr or "start failed")
                end

                local claimValue = session.MaxEarnings
                if claimValue == nil then
                    claimValue = session.StartingCash
                end

                local reward, endErr = endRemote:InvokeServer(claimValue)
                if isPositiveHuge(reward) then
                    return true, formatRewardAmount(reward)
                end
                return false, tostring(endErr or "no earnings")
            end)
            tradeBusy = false
            if not ok then
                lastTradeResult = "Error: " .. tostring(result)
                return false
            end
            if result then
                lastTradeResult = "Won " .. tostring(detail)
            else
                lastTradeResult = tostring(detail or "failed")
            end
            return result == true
        end

        local function playRaceOnce()
            if raceBusy then
                return false, "busy"
            end
            raceBusy = true
            local ok, result, detail = pcall(function()
                local availableAt = getPlayerValue("MinigameRaceAvailable") or 0
                local ready = select(1, getAvailabilityStatus(availableAt))
                if not ready then
                    return false, "not ready"
                end

                local startRemote = findMinigameRemote("MinigameRaceService.Start")
                local endRemote = findMinigameRemote("MinigameRaceService.End")
                if not startRemote or not endRemote then
                    return false, "remotes missing"
                end

                local baseCash, startErr = startRemote:InvokeServer()
                if not baseCash then
                    return false, tostring(startErr or "start failed")
                end

                -- Placement 1 = full MinigameRacePlacementCash reward.
                local reward, endErr = endRemote:InvokeServer(1)
                if isPositiveHuge(reward) then
                    return true, formatRewardAmount(reward)
                end
                return false, tostring(endErr or "no earnings")
            end)
            raceBusy = false
            if not ok then
                lastRaceResult = "Error: " .. tostring(result)
                return false
            end
            if result then
                lastRaceResult = "1st - " .. tostring(detail)
            else
                lastRaceResult = tostring(detail or "failed")
            end
            return result == true
        end

        MinigamesTab:CreateSection("Lemon Trading")

        tradeInfoParagraph = MinigamesTab:CreateParagraph({
            Title = "Lemon Trading",
            Content = "Loading...",
        })

        MinigamesTab:CreateButton({
            Name = "Refresh Status",
            Callback = function()
                refreshMinigameInfo()
            end,
        })

        MinigamesTab:CreateInput({
            Name = "Delay (seconds)",
            PlaceholderText = "Seconds between trade attempts",
            Flag = "minigame_trade_delay",
            CurrentValue = tostring(tradeDelaySec),
            Callback = function(value)
                tradeDelaySec = math.max(0.5, tonumber(value) or tradeDelaySec)
            end,
        })

        MinigamesTab:CreateButton({
            Name = "Play Trade Once",
            Callback = function()
                local ok = playTradeOnce()
                refreshMinigameInfo()
                mountNotify({
                    Title = "Lemon Trading",
                    Content = if ok then lastTradeResult else ("Failed: " .. lastTradeResult),
                    Icon = if ok then "check" else "x",
                })
            end,
        })

        MinigamesTab:CreateToggle({
            Name = "Auto Play Trade",
            Flag = "minigame_auto_trade",
            CurrentValue = false,
            Callback = function(enabled)
                autoTradeRunning = enabled == true
                if not autoTradeRunning then
                    return
                end

                autoTradeLoopId += 1
                local loopId = autoTradeLoopId
                task.spawn(function()
                    while autoTradeRunning and loopId == autoTradeLoopId do
                        local played = false
                        pcall(function()
                            played = playTradeOnce() == true
                        end)
                        refreshMinigameInfo()
                        local delay = math.max(0.5, tonumber(tradeDelaySec) or 1)
                        if not played then
                            local availableAt = getPlayerValue("MinigameTradeAvailable") or 0
                            local ready, _, remaining = getAvailabilityStatus(availableAt)
                            if not ready and remaining and remaining > 0 then
                                delay = math.min(math.max(delay, remaining), math.max(delay, 30))
                            else
                                delay = math.max(delay, 2)
                            end
                        end
                        task.wait(delay)
                    end
                end)
            end,
        })

        MinigamesTab:CreateSection("LemonDash Race")

        raceInfoParagraph = MinigamesTab:CreateParagraph({
            Title = "LemonDash Race",
            Content = "Loading...",
        })

        MinigamesTab:CreateButton({
            Name = "Refresh Status",
            Callback = function()
                refreshMinigameInfo()
            end,
        })

        MinigamesTab:CreateInput({
            Name = "Delay (seconds)",
            PlaceholderText = "Seconds between race attempts",
            Flag = "minigame_race_delay",
            CurrentValue = tostring(raceDelaySec),
            Callback = function(value)
                raceDelaySec = math.max(0.5, tonumber(value) or raceDelaySec)
            end,
        })

        MinigamesTab:CreateButton({
            Name = "Play Race Once",
            Callback = function()
                local ok = playRaceOnce()
                refreshMinigameInfo()
                mountNotify({
                    Title = "LemonDash Race",
                    Content = if ok then lastRaceResult else ("Failed: " .. lastRaceResult),
                    Icon = if ok then "check" else "x",
                })
            end,
        })

        MinigamesTab:CreateToggle({
            Name = "Auto Play Race",
            Flag = "minigame_auto_race",
            CurrentValue = false,
            Callback = function(enabled)
                autoRaceRunning = enabled == true
                if not autoRaceRunning then
                    return
                end

                autoRaceLoopId += 1
                local loopId = autoRaceLoopId
                task.spawn(function()
                    while autoRaceRunning and loopId == autoRaceLoopId do
                        local played = false
                        pcall(function()
                            played = playRaceOnce() == true
                        end)
                        refreshMinigameInfo()
                        local delay = math.max(0.5, tonumber(raceDelaySec) or 1)
                        if not played then
                            local availableAt = getPlayerValue("MinigameRaceAvailable") or 0
                            local ready, _, remaining = getAvailabilityStatus(availableAt)
                            if not ready and remaining and remaining > 0 then
                                delay = math.min(math.max(delay, remaining), math.max(delay, 30))
                            else
                                delay = math.max(delay, 2)
                            end
                        end
                        task.wait(delay)
                    end
                end)
            end,
        })

        task.spawn(function()
            refreshMinigameInfo()
            -- Warm remotes off the status path so deep search can't stall the paragraph.
            task.spawn(function()
                findMinigameRemote("MinigameTradeService.Start", true)
                findMinigameRemote("MinigameTradeService.End", true)
                findMinigameRemote("MinigameRaceService.Start", true)
                findMinigameRemote("MinigameRaceService.End", true)
                refreshMinigameInfo()
            end)
            while tradeInfoParagraph or raceInfoParagraph do
                task.wait(minigameInfoAutoRefreshSec)
                refreshMinigameInfo()
            end
        end)
    end
    installMinigamesAutomation()

    installAutoRebirthEvolve()

    local function installAutoAscend()
        local ascensionInfoParagraph
        local ascensionInfoAutoRefreshSec = 1
        local autoAscendRunning = false
        local autoAscendLoopId = 0
        local autoAscendDelaySec = 1
        local ascendProgressTargetPercent = 100

        local function getTycoonAscensionComponent(ctx, tycoon)
            if tycoon and type(tycoon.GetComponent) == "function" and ctx.ClientTycoonAscension then
                local ok, component = pcall(function()
                    return tycoon:GetComponent(ctx.ClientTycoonAscension)
                end)
                if ok and component then
                    return component
                end
            end
            return nil
        end

        local function formatAscensionProgressPercent(progress)
            if type(progress) ~= "number" then
                return "?"
            end
            local shown = progress
            if shown < 1 then
                shown = math.min(shown, 0.9945)
            end
            local decimals = if shown > 0.0995 then 0 else 1
            local text = string.format("%." .. tostring(decimals) .. "f", shown * 100)
            return text:gsub("%.?0+$", "") .. "%"
        end

        local function getAscensionProgressInfo(ctx, tycoon)
            local ascension = getTycoonAscensionComponent(ctx, tycoon)
            if not ascension or type(ascension.GetAscensionProgress) ~= "function" then
                return nil
            end

            local ok, progress = pcall(function()
                return ascension:GetAscensionProgress()
            end)
            if not ok or type(progress) ~= "number" then
                return nil
            end

            local cashBonus = nil
            if type(ascension.GetAscensionCashBonus) == "function" then
                local okBonus, bonus = pcall(function()
                    return ascension:GetAscensionCashBonus()
                end)
                if okBonus then
                    cashBonus = bonus
                end
            end
            if cashBonus == nil and ctx.Config then
                cashBonus = ctx.Config.AscensionMultiplier
            end

            local pricePenalty = nil
            if type(ascension.GetAscensionPricePenalty) == "function" then
                local okPenalty, penalty = pcall(function()
                    return ascension:GetAscensionPricePenalty()
                end)
                if okPenalty then
                    pricePenalty = penalty
                end
            end
            if pricePenalty == nil and ctx.Config then
                pricePenalty = ctx.Config.AscensionPenalty
            end

            local permanentRemaining = nil
            if type(ascension.GetAscensionPermanentPurchasesRemaining) == "function" then
                local okRemaining, remaining = pcall(function()
                    return ascension:GetAscensionPermanentPurchasesRemaining()
                end)
                if okRemaining then
                    permanentRemaining = remaining
                end
            end

            local currentLevel = 0
            if type(ascension.GetAscension) == "function" then
                local okLevel, level = pcall(function()
                    return ascension:GetAscension()
                end)
                if okLevel and level ~= nil then
                    currentLevel = level
                end
            end

            local targetPercent = math.max(0, tonumber(ascendProgressTargetPercent) or 100)
            local ready = progress * 100 >= targetPercent and progress >= 1

            return {
                progress = progress,
                currentLevel = currentLevel,
                cashBonus = cashBonus,
                pricePenalty = pricePenalty,
                permanentRemaining = permanentRemaining,
                ready = ready,
            }
        end

        local function shouldAutoAscend(progressInfo)
            return progressInfo ~= nil and progressInfo.ready == true
        end

        local function findAscendRemote(tycoonInstance)
            local remotes = tycoonInstance and tycoonInstance:FindFirstChild("Remotes")
            local ascendRemote = remotes and remotes:FindFirstChild("Ascend")
            if ascendRemote and ascendRemote:IsA("RemoteFunction") then
                return ascendRemote
            end
            return nil
        end

        local function getAscensionInfoContent()
            local ctx, ctxErr = getSellLemonsGameContext(true)
            if not ctx then
                return ctxErr or "Could not load game data."
            end

            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return "Waiting for tycoon..."
            end

            local progressInfo = getAscensionProgressInfo(ctx, tycoon)
            if not progressInfo then
                return "Could not read ascension data."
            end

            local lines = {
                string.format("Current Ascension: %s", tostring(progressInfo.currentLevel)),
                string.format("Progress: %s", formatAscensionProgressPercent(progressInfo.progress)),
                string.format(
                    "Target Progress: %s%%",
                    tostring(math.max(0, tonumber(ascendProgressTargetPercent) or 100))
                ),
            }

            if progressInfo.cashBonus ~= nil then
                table.insert(lines, string.format(
                    "Cash Bonus: x%s income",
                    tostring(progressInfo.cashBonus)
                ))
            end
            if progressInfo.pricePenalty ~= nil then
                table.insert(lines, string.format(
                    "Price Penalty: x%s button prices",
                    tostring(progressInfo.pricePenalty)
                ))
            end
            if progressInfo.permanentRemaining ~= nil then
                table.insert(lines, string.format(
                    "Permanent Purchases Left: %s",
                    tostring(progressInfo.permanentRemaining)
                ))
            end

            table.insert(lines, string.format(
                "Ready to Ascend: %s",
                if shouldAutoAscend(progressInfo) then "Yes" else "No"
            ))

            return table.concat(lines, "\n")
        end

        local function applyAscensionInfoParagraph(content)
            if not ascensionInfoParagraph then
                return
            end
            task.defer(function()
                if not ascensionInfoParagraph then
                    return
                end
                ascensionInfoParagraph:Set({
                    Title = "Ascension",
                    Content = content,
                })
            end)
        end

        local function requestAscensionInfoRefresh()
            task.spawn(function()
                local ok, contentOrErr = pcall(getAscensionInfoContent)
                applyAscensionInfoParagraph(if ok then contentOrErr else ("Refresh error: " .. tostring(contentOrErr)))
            end)
        end

        local function tryAutoAscendOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end

            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end

            local progressInfo = getAscensionProgressInfo(ctx, tycoon)
            if not shouldAutoAscend(progressInfo) then
                return false
            end

            local ascension = getTycoonAscensionComponent(ctx, tycoon)
            local ok = false
            local result = nil
            if ascension and type(ascension.AscendAsync) == "function" then
                local callOk, callResult = pcall(function()
                    return ascension:AscendAsync()
                end)
                ok = callOk == true and callResult ~= false
                result = callResult
            else
                local remote = findAscendRemote(tycoon.Instance)
                if not remote then
                    return false
                end
                local callOk, callResult = pcall(function()
                    return remote:InvokeServer()
                end)
                ok = callOk == true and callResult ~= false
                result = callResult
            end

            if ok then
                mountNotify({
                    Title = "Auto Ascend",
                    Content = string.format(
                        "Ascended at %s progress (now %s).",
                        formatAscensionProgressPercent(progressInfo.progress),
                        tostring((tonumber(progressInfo.currentLevel) or 0) + 1)
                    ),
                    Icon = "check",
                })
            end
            return ok
        end

        MainTab:CreateSection("Auto Ascend")

        ascensionInfoParagraph = MainTab:CreateParagraph({
            Title = "Ascension",
            Content = "Loading...",
        })

        MainTab:CreateInput({
            Name = "Target Progress (%)",
            PlaceholderText = "Progress percent required before ascend (100 = all buttons)",
            Flag = "main_ascend_target_percent",
            CurrentValue = tostring(ascendProgressTargetPercent),
            Callback = function(value)
                ascendProgressTargetPercent = math.max(0, tonumber(value) or ascendProgressTargetPercent)
                requestAscensionInfoRefresh()
            end,
        })

        MainTab:CreateInput({
            Name = "Delay (seconds)",
            PlaceholderText = "Seconds between auto ascend checks",
            Flag = "main_auto_ascend_delay",
            CurrentValue = tostring(autoAscendDelaySec),
            Callback = function(value)
                autoAscendDelaySec = math.max(0.1, tonumber(value) or 1)
            end,
        })

        MainTab:CreateToggle({
            Name = "Auto Ascend",
            Flag = "main_auto_ascend",
            CurrentValue = false,
            Callback = function(enabled)
                autoAscendRunning = enabled == true
                if not autoAscendRunning then
                    return
                end

                autoAscendLoopId += 1
                local loopId = autoAscendLoopId
                task.spawn(function()
                    while autoAscendRunning and loopId == autoAscendLoopId do
                        local ok = pcall(function()
                            tryAutoAscendOnce()
                            requestAscensionInfoRefresh()
                            applyPlayerInfoParagraph()
                        end)
                        local delay = math.max(0.1, tonumber(autoAscendDelaySec) or 1)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        task.spawn(function()
            requestAscensionInfoRefresh()
            while ascensionInfoParagraph do
                task.wait(ascensionInfoAutoRefreshSec)
                requestAscensionInfoRefresh()
            end
        end)
    end

    installAutoAscend()

    local function installWorldPickups()
        local fireClickDetectorFn = (typeof(fireclickdetector) == "function" and fireclickdetector)
            or (typeof(clickdetector) == "function" and clickdetector)
            or nil

        local function getLocalHumanoidRootPart()
            local player = Players.LocalPlayer
            local character = player and player.Character
            local root = character and character:FindFirstChild("HumanoidRootPart")
            if root and root:IsA("BasePart") then
                return root
            end
            return nil
        end

        local function getFruitPosition(fruit)
            if not fruit or not fruit.Parent then
                return nil
            end
            if fruit:IsA("Model") then
                return fruit:GetPivot().Position
            end
            if fruit:IsA("BasePart") then
                return fruit.Position
            end
            local part = fruit:FindFirstChildWhichIsA("BasePart", true)
            if part then
                return part.Position
            end
            return nil
        end

        local function getInstancePosition(instance)
            if not instance or not instance.Parent then
                return nil
            end
            if instance:IsA("Model") then
                return instance:GetPivot().Position
            end
            if instance:IsA("BasePart") then
                return instance.Position
            end
            local part = instance:FindFirstChildWhichIsA("BasePart", true)
            if part then
                return part.Position
            end
            return nil
        end

        local function findLemonTreeAncestor(instance, tycoonInstance)
            local current = instance
            while current and current ~= tycoonInstance do
                if current.Name == "LemonTree" then
                    return current
                end
                current = current.Parent
            end
            return nil
        end

        local function teleportRootToPosition(root, position)
            root.AssemblyLinearVelocity = Vector3.zero
            root.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))
        end

        local teleportActionQueue = {}
        local teleportQueueWorkerRunning = false

        local function processNextTeleportAction()
            if teleportQueueWorkerRunning then
                return
            end

            local job = table.remove(teleportActionQueue, 1)
            if not job then
                return
            end

            teleportQueueWorkerRunning = true
            task.spawn(function()
                pcall(job)
                teleportQueueWorkerRunning = false
                processNextTeleportAction()
            end)
        end

        local function enqueueTeleportAction(actionFn)
            table.insert(teleportActionQueue, actionFn)
            processNextTeleportAction()
        end

        local function runInTeleportQueue(actionFn)
            local finished = false
            enqueueTeleportAction(function()
                local ok, err = pcall(actionFn)
                if not ok then
                    warn("[Sell Lemons Teleport Queue]", err)
                end
                finished = true
            end)

            while not finished do
                task.wait()
            end
        end

        local function collectOwnTycoonLemonTreesWithFruit(tycoonInstance, originPos)
            if not tycoonInstance or not originPos then
                return {}
            end

            local trees = {}
            local seen = {}
            for _, fruit in CollectionService:GetTagged("ClickFruit") do
                if fruit.Parent and fruit:IsDescendantOf(tycoonInstance) then
                    local detector = fruit:FindFirstChildWhichIsA("ClickDetector", true)
                    if not detector then
                        continue
                    end
                    local lemonTree = findLemonTreeAncestor(fruit, tycoonInstance)
                    if lemonTree and not seen[lemonTree] then
                        seen[lemonTree] = true
                        local treePos = getInstancePosition(lemonTree)
                        if treePos then
                            table.insert(trees, {
                                tree = lemonTree,
                                position = treePos,
                                distance = (originPos - treePos).Magnitude,
                            })
                        end
                    end
                end
            end

            table.sort(trees, function(a, b)
                return a.distance < b.distance
            end)
            return trees
        end

        local function pickFruitNormalOnce()
            if not fireClickDetectorFn then
                return false
            end

            local picked = 0
            for _, fruit in CollectionService:GetTagged("ClickFruit") do
                if not fruit.Parent then
                    continue
                end
                local detector = fruit:FindFirstChildWhichIsA("ClickDetector", true)
                if detector then
                    pcall(function()
                        fireClickDetectorFn(detector, 1, "MouseClick")
                    end)
                    picked += 1
                end
            end
            mountNotify({
                Title = "Auto Pick Fruit",
                Content = "Picked " .. picked .. " fruits",
                Icon = "check",
            })
            return true, picked
        end

        local function pickFruitNearbyOnce(showNotify)
            if showNotify == nil then
                showNotify = true
            end

            if not fireClickDetectorFn then
                return false
            end

            local root = getLocalHumanoidRootPart()
            if not root then
                return false
            end

            local rootPos = root.Position
            local nearby = {}
            for _, fruit in CollectionService:GetTagged("ClickFruit") do
                if not fruit.Parent then
                    continue
                end
                local detector = fruit:FindFirstChildWhichIsA("ClickDetector", true)
                local fruitPos = getFruitPosition(fruit)
                if detector and fruitPos then
                    local distance = (rootPos - fruitPos).Magnitude
                    local maxDistance = detector.MaxActivationDistance
                    if maxDistance <= 0 then
                        maxDistance = 32
                    end
                    if distance <= maxDistance then
                        table.insert(nearby, {
                            detector = detector,
                            distance = distance,
                        })
                    end
                end
            end

            table.sort(nearby, function(a, b)
                return a.distance < b.distance
            end)

            if #nearby == 0 then
                return false, 0
            end

            local picked = 0
            local clickDelay = math.max(0.05, tonumber(autoPickFruitNearbyClickDelaySec) or 0.5)
            for index, entry in ipairs(nearby) do
                if not autoPickFruitRunning then
                    break
                end

                pcall(function()
                    fireClickDetectorFn(entry.detector, 1, "MouseClick")
                end)
                picked += 1

                if index < #nearby then
                    task.wait(clickDelay)
                end
            end

            if picked > 0 and showNotify then
                mountNotify({
                    Title = "Auto Pick Fruit",
                    Content = "Picked " .. picked .. " nearby fruits",
                    Icon = "check",
                })
            end

            return picked > 0, picked
        end

        local function pickFruitNearbyWithTeleportOnce()
            if not fireClickDetectorFn then
                return false
            end

            pickFruitNearbyOnce(false)

            if not autoPickFruitRunning then
                return false
            end

            runInTeleportQueue(function()
                local root = getLocalHumanoidRootPart()
                if not root or not autoPickFruitRunning then
                    return
                end

                local tycoonInstance = findLocalTycoonInstance()
                if not tycoonInstance then
                    return
                end

                local trees = collectOwnTycoonLemonTreesWithFruit(tycoonInstance, root.Position)
                if #trees == 0 then
                    return
                end

                autoPickFruitTeleportTreeIndex = (autoPickFruitTeleportTreeIndex % #trees) + 1
                local entry = trees[autoPickFruitTeleportTreeIndex]
                if not entry or not entry.tree.Parent then
                    return
                end

                local savedCFrame = root.CFrame
                teleportRootToPosition(root, entry.position)

                local staySec = math.max(0.05, tonumber(autoPickFruitTeleportStaySec) or 1.5)
                local clickDelay = math.max(0.05, tonumber(autoPickFruitNearbyClickDelaySec) or 0.2)
                local stayEnd = tick() + staySec
                while autoPickFruitRunning and tick() < stayEnd do
                    pickFruitNearbyOnce(false)
                    local remaining = stayEnd - tick()
                    if remaining <= 0 then
                        break
                    end
                    task.wait(math.min(clickDelay, remaining))
                end

                root = getLocalHumanoidRootPart()
                if root then
                    root.AssemblyLinearVelocity = Vector3.zero
                    root.CFrame = savedCFrame
                end
            end)

            return true
        end

        local function runAutoPickFruitOnce()
            if autoPickFruitMode == "Normal" then
                return pickFruitNormalOnce()
            end
            if autoPickFruitMode == "Nearby" then
                return pickFruitNearbyOnce()
            end
            if autoPickFruitMode == "Nearby with Teleport" then
                return pickFruitNearbyWithTeleportOnce()
            end
            return false
        end

        MainTab:CreateSection("Auto Pick Fruit")

        MainTab:CreateDropdown({
            Name = "Mode",
            Flag = "main_auto_pick_fruit_mode",
            Options = AUTO_PICK_FRUIT_MODES,
            CurrentOption = { autoPickFruitMode },
            Callback = function(value)
                local picked = rayfieldDropdownFirst(value)
                if picked and table.find(AUTO_PICK_FRUIT_MODES, picked) then
                    autoPickFruitMode = picked
                end
            end,
        })

        MainTab:CreateInput({
            Name = "Delay (seconds)",
            PlaceholderText = "Seconds between auto fruit picks",
            Flag = "main_auto_pick_fruit_delay",
            CurrentValue = tostring(autoPickFruitDelaySec),
            Callback = function(value)
                autoPickFruitDelaySec = math.max(0.05, tonumber(value) or autoPickFruitDelaySec)
            end,
        })

        MainTab:CreateToggle({
            Name = "Auto Pick Fruit",
            Flag = "main_auto_pick_fruit",
            CurrentValue = false,
            Callback = function(enabled)
                autoPickFruitRunning = enabled == true
                if not autoPickFruitRunning then
                    return
                end

                if not fireClickDetectorFn then
                    autoPickFruitRunning = false
                    mountNotify({
                        Title = "Auto Pick Fruit",
                        Content = "Your executor does not support fireclickdetector.",
                        Icon = "x",
                    })
                    return
                end

                autoPickFruitTeleportTreeIndex = 0
                autoPickFruitLoopId += 1
                local loopId = autoPickFruitLoopId
                task.spawn(function()
                    while autoPickFruitRunning and loopId == autoPickFruitLoopId do
                        local ok = pcall(runAutoPickFruitOnce)
                        local delay = math.max(0.05, tonumber(autoPickFruitDelaySec) or 5)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        local pendingCashDropIds = {}
        local cashDropNewListenerConnected = false
        local cachedCashDropRedeemRemote = nil
        local cachedCashDropNewRemote = nil
        local autoCashDropPreferRedeem = true

        local function getCashDropRedeemRemote()
            if cachedCashDropRedeemRemote and cachedCashDropRedeemRemote.Parent then
                return cachedCashDropRedeemRemote
            end
            local remote = ReplicatedStorage:FindFirstChild("CashDropService.Redeem", true)
            if remote and remote:IsA("RemoteFunction") then
                cachedCashDropRedeemRemote = remote
                return remote
            end
            return nil
        end

        local function getCashDropNewRemote()
            if cachedCashDropNewRemote and cachedCashDropNewRemote.Parent then
                return cachedCashDropNewRemote
            end
            local remote = ReplicatedStorage:FindFirstChild("CashDropService.New", true)
            if remote and (remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction")) then
                cachedCashDropNewRemote = remote
                return remote
            end
            return nil
        end

        local function getCashDropPosition(cashDrop)
            if not cashDrop or not cashDrop.Parent then
                return nil
            end

            local bag = cashDrop:FindFirstChild("Bag")
            if bag and bag:IsA("BasePart") then
                return bag.Position
            end

            if cashDrop:IsA("Model") then
                return cashDrop:GetPivot().Position
            end

            if cashDrop:IsA("BasePart") then
                return cashDrop.Position
            end

            return nil
        end

        local function getCashDropsFolder()
            return Workspace:FindFirstChild("CashDrops")
        end

        local function collectCashDrops()
            local folder = getCashDropsFolder()
            if not folder then
                return {}
            end

            local drops = {}
            for _, child in folder:GetChildren() do
                -- Prefab is usually named CashDrop; accept any child under the folder.
                if child.Parent and (child.Name == "CashDrop" or child:IsA("BasePart") or child:IsA("Model")) then
                    table.insert(drops, child)
                end
            end
            return drops
        end

        -- Redeem skips CashDropEffect:Pop(). Visual often parents AFTER New/Redeem,
        -- so queue cleanups and also catch ChildAdded.
        local pendingCashDropVisualCleanups = {}
        local cashDropFolderListenerConnected = false

        local function pruneExpiredCashDropVisualCleanups()
            local now = os.clock()
            for i = #pendingCashDropVisualCleanups, 1, -1 do
                local entry = pendingCashDropVisualCleanups[i]
                if not entry or now > (tonumber(entry.expires) or 0) then
                    table.remove(pendingCashDropVisualCleanups, i)
                end
            end
        end

        local function destroyCashDropInstance(cashDrop)
            if not cashDrop or not cashDrop.Parent then
                return false
            end
            pcall(function()
                cashDrop:Destroy()
            end)
            return true
        end

        local function matchAndDestroyCashDropVisual(preferredPosition, maxDistance)
            local drops = collectCashDrops()
            if #drops == 0 then
                return false
            end

            local target = drops[#drops]
            if typeof(preferredPosition) == "Vector3" then
                local bestDist = math.huge
                target = nil
                for _, cashDrop in ipairs(drops) do
                    local pos = getCashDropPosition(cashDrop)
                    if pos then
                        local dist = (pos - preferredPosition).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            target = cashDrop
                        end
                    end
                end
                if not target then
                    return false
                end
                if maxDistance and bestDist > maxDistance then
                    return false
                end
            end

            return destroyCashDropInstance(target)
        end

        local function flushCashDropVisualCleanups()
            pruneExpiredCashDropVisualCleanups()
            if #pendingCashDropVisualCleanups == 0 then
                return
            end

            for i = #pendingCashDropVisualCleanups, 1, -1 do
                local entry = pendingCashDropVisualCleanups[i]
                local preferredPosition = entry and entry.position or nil
                -- Prefer a nearby bag when we have a spawn position; otherwise take newest.
                local destroyed = matchAndDestroyCashDropVisual(preferredPosition, preferredPosition and 80 or nil)
                if destroyed then
                    table.remove(pendingCashDropVisualCleanups, i)
                end
            end
        end

        local function ensureCashDropFolderListener()
            if cashDropFolderListenerConnected then
                return
            end
            cashDropFolderListenerConnected = true

            local function bindFolder(folder)
                if not folder or folder:GetAttribute("CobaltCashDropBound") then
                    return
                end
                folder:SetAttribute("CobaltCashDropBound", true)
                folder.ChildAdded:Connect(function()
                    task.defer(flushCashDropVisualCleanups)
                end)
            end

            local existing = getCashDropsFolder()
            if existing then
                bindFolder(existing)
            end
            Workspace.ChildAdded:Connect(function(child)
                if child.Name == "CashDrops" then
                    bindFolder(child)
                    task.defer(flushCashDropVisualCleanups)
                end
            end)
        end

        local function destroyCashDropVisual(preferredPosition)
            ensureCashDropFolderListener()

            -- Try immediately (visual already exists).
            if matchAndDestroyCashDropVisual(preferredPosition, preferredPosition and 80 or nil) then
                return
            end

            -- Queue for ChildAdded / retries — CashDropService often parents the bag after Redeem.
            table.insert(pendingCashDropVisualCleanups, {
                position = preferredPosition,
                expires = os.clock() + 8,
            })
            flushCashDropVisualCleanups()
            if #pendingCashDropVisualCleanups == 0 then
                return
            end

            task.spawn(function()
                for attempt = 1, 40 do
                    task.wait(0.2)
                    flushCashDropVisualCleanups()
                    if #pendingCashDropVisualCleanups == 0 then
                        return
                    end
                    -- Position match can miss (Y offset / bob). After ~1s, destroy newest bag.
                    if attempt >= 5 and matchAndDestroyCashDropVisual(nil, nil) then
                        if #pendingCashDropVisualCleanups > 0 then
                            table.remove(pendingCashDropVisualCleanups)
                        end
                        return
                    end
                end
            end)
        end

        local function redeemCashDropId(dropId)
            if dropId == nil then
                return false
            end
            local remote = getCashDropRedeemRemote()
            if not remote then
                return false
            end
            local entry = pendingCashDropIds[dropId]
            local preferredPosition = type(entry) == "table" and entry.position or nil
            local ok, result = pcall(function()
                return remote:InvokeServer(dropId)
            end)
            if ok and result then
                pendingCashDropIds[dropId] = nil
                destroyCashDropVisual(preferredPosition)
                return true
            end
            if type(entry) == "table" then
                entry.fails = (tonumber(entry.fails) or 0) + 1
                if entry.fails >= 5 then
                    pendingCashDropIds[dropId] = nil
                end
            elseif entry ~= nil then
                pendingCashDropIds[dropId] = { fails = 1 }
            end
            return false
        end

        local function trackCashDropId(dropId, position)
            if dropId == nil then
                return
            end
            if pendingCashDropIds[dropId] == nil then
                pendingCashDropIds[dropId] = { fails = 0, position = position }
            elseif type(pendingCashDropIds[dropId]) == "table" and position ~= nil then
                pendingCashDropIds[dropId].position = position
            end
            if autoPickCashDropRunning and autoCashDropPreferRedeem then
                task.defer(function()
                    if autoPickCashDropRunning then
                        redeemCashDropId(dropId)
                    end
                end)
            end
        end

        local function ensureCashDropNewListener()
            ensureCashDropFolderListener()
            if cashDropNewListenerConnected then
                return
            end
            local newRemote = getCashDropNewRemote()
            if not newRemote or not newRemote:IsA("RemoteEvent") then
                return
            end
            cashDropNewListenerConnected = true
            newRemote.OnClientEvent:Connect(function(dropId, _lifetime, position)
                trackCashDropId(dropId, position)
            end)
        end

        local function redeemPendingCashDropsOnce()
            ensureCashDropNewListener()
            if not getCashDropRedeemRemote() then
                return false
            end

            local redeemed = 0
            local ids = {}
            for dropId in pairs(pendingCashDropIds) do
                table.insert(ids, dropId)
            end
            for _, dropId in ipairs(ids) do
                if not autoPickCashDropRunning then
                    break
                end
                if redeemCashDropId(dropId) then
                    redeemed += 1
                end
            end
            return redeemed > 0
        end

        local function teleportPickCashDropsOnce()
            local root = getLocalHumanoidRootPart()
            if not root then
                return false
            end

            local drops = collectCashDrops()
            if #drops == 0 then
                return false
            end

            runInTeleportQueue(function()
                root = getLocalHumanoidRootPart()
                if not root then
                    return
                end

                local savedCFrame = root.CFrame
                for _, cashDrop in ipairs(drops) do
                    if not autoPickCashDropRunning then
                        break
                    end

                    local dropPos = getCashDropPosition(cashDrop)
                    if dropPos then
                        teleportRootToPosition(root, dropPos)
                        task.wait(2)
                        root = getLocalHumanoidRootPart()
                        if not root then
                            break
                        end
                        root.AssemblyLinearVelocity = Vector3.zero
                        root.CFrame = savedCFrame
                    end
                end
            end)

            return true
        end

        local function pickCashDropsOnce()
            ensureCashDropNewListener()

            local redeemedAny = false
            if autoCashDropPreferRedeem then
                redeemedAny = redeemPendingCashDropsOnce()
                if #collectCashDrops() == 0 then
                    return redeemedAny
                end
                if getCashDropRedeemRemote() and next(pendingCashDropIds) == nil then
                    return redeemedAny
                end
            end

            local teleportedAny = teleportPickCashDropsOnce()
            return redeemedAny or teleportedAny
        end

        ensureCashDropNewListener()

        MainTab:CreateSection("Auto Pick Cash Drop")

        MainTab:CreateToggle({
            Name = "Prefer Redeem Remote",
            Flag = "main_auto_cash_drop_prefer_redeem",
            CurrentValue = true,
            Callback = function(enabled)
                autoCashDropPreferRedeem = enabled == true
                if autoCashDropPreferRedeem then
                    ensureCashDropNewListener()
                end
            end,
        })

        MainTab:CreateToggle({
            Name = "Auto Pick Cash Drop",
            Flag = "main_auto_pick_cash_drop",
            CurrentValue = false,
            Callback = function(enabled)
                autoPickCashDropRunning = enabled == true
                if not autoPickCashDropRunning then
                    return
                end

                ensureCashDropNewListener()
                autoPickCashDropLoopId += 1
                local loopId = autoPickCashDropLoopId
                task.spawn(function()
                    while autoPickCashDropRunning and loopId == autoPickCashDropLoopId do
                        local ok = pcall(pickCashDropsOnce)
                        local delay = math.max(0.1, tonumber(autoPickCashDropDelaySec) or 0.5)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

    end
    installWorldPickups()

    local function installAutoExtras()
        local function getTycoonPowersComponent(ctx, tycoon)
            if tycoon and type(tycoon.GetComponent) == "function" and ctx.ClientTycoonPowers then
                local ok, component = pcall(function()
                    return tycoon:GetComponent(ctx.ClientTycoonPowers)
                end)
                if ok and component then
                    return component
                end
            end
            return nil
        end

        local function isInvestorsDiscovered(ctx, tycoon)
            local rebirth = getTycoonRebirthComponent(ctx, tycoon)
            if not rebirth or type(rebirth.IsDiscovered) ~= "function" then
                return false
            end
            local ok, discovered = pcall(function()
                return rebirth:IsDiscovered() == true
            end)
            return ok and discovered == true
        end

        local function getPowerDisplayTitle(ctx, powerName)
            local powerConfig = ctx.Config and ctx.Config.Powers and ctx.Config.Powers[powerName]
            if powerConfig and type(powerConfig.Display) == "table" and type(powerConfig.Display.Title) == "string" then
                return powerConfig.Display.Title
            end
            return prettifyPurchaseName(powerName)
        end

        local function getPowerDisplayOrder(ctx, powerName)
            local powerConfig = ctx.Config and ctx.Config.Powers and ctx.Config.Powers[powerName]
            if powerConfig and type(powerConfig.Display) == "table" and type(powerConfig.Display.Order) == "number" then
                return powerConfig.Display.Order
            end
            return 0
        end

        local function compareHugeDescending(a, b)
            if a == nil or b == nil then
                return false
            end
            local ok, greaterOrEqual = pcall(function()
                return a >= b
            end)
            return ok and greaterOrEqual == true
        end

        local function collectAffordablePowerUpgrades(ctx, tycoon)
            local powers = getTycoonPowersComponent(ctx, tycoon)
            if not powers or not ctx.Config or type(ctx.Config.Powers) ~= "table" then
                return nil
            end
            if not isInvestorsDiscovered(ctx, tycoon) then
                return {}
            end

            local investors = getCurrentInvestors(ctx, tycoon)
            if investors == nil then
                return nil
            end

            local entries = {}
            for powerName in pairs(ctx.Config.Powers) do
                if ctx.ClientTycoonPowers and type(ctx.ClientTycoonPowers.isPower) == "function" then
                    local okPower, isPower = pcall(function()
                        return ctx.ClientTycoonPowers.isPower(powerName) == true
                    end)
                    if not okPower or not isPower then
                        continue
                    end
                end

                local okMax, maxLevel = pcall(function()
                    return powers:GetMaxLevel(powerName)
                end)
                if not okMax or not maxLevel then
                    continue
                end

                local okLevel, currentLevel = pcall(function()
                    return powers:GetLevel(powerName)
                end)
                if not okLevel or currentLevel == nil or currentLevel >= maxLevel then
                    continue
                end

                local okPrice, price = pcall(function()
                    return powers:GetUpgradePrice(powerName)
                end)
                if not okPrice or price == nil then
                    continue
                end

                if canAffordPurchasePrice(investors, price) then
                    table.insert(entries, {
                        name = powerName,
                        price = price,
                        displayOrder = getPowerDisplayOrder(ctx, powerName),
                        displayTitle = getPowerDisplayTitle(ctx, powerName),
                    })
                end
            end

            table.sort(entries, function(a, b)
                if compareHugeDescending(a.price, b.price) then
                    return true
                end
                if compareHugeDescending(b.price, a.price) then
                    return false
                end
                return a.displayOrder > b.displayOrder
            end)

            return entries
        end

        local function findUpgradePowerLevelRemote(tycoonInstance)
            local remotes = tycoonInstance and tycoonInstance:FindFirstChild("Remotes")
            local upgradeRemote = remotes and remotes:FindFirstChild("UpgradePowerLevel")
            if upgradeRemote and upgradeRemote:IsA("RemoteFunction") then
                return upgradeRemote
            end
            return nil
        end

        local function tryAutoBuyPowersOnce()
            local ctx = getSellLemonsGameContext(true)
            if not ctx then
                return false
            end

            local tycoon = getLocalTycoon(ctx)
            if not tycoon then
                return false
            end

            local entries = collectAffordablePowerUpgrades(ctx, tycoon)
            if type(entries) ~= "table" or #entries == 0 then
                return false
            end

            local target = entries[1]
            local remote = findUpgradePowerLevelRemote(tycoon.Instance)
            if not remote then
                return false
            end

            local ok = pcall(function()
                remote:InvokeServer(target.name)
            end)
            if ok then
                mountNotify({
                    Title = "Auto Buy Powers",
                    Content = string.format(
                        "Upgraded %s (%s investors).",
                        target.displayTitle,
                        formatHugeAmount(ctx, target.price)
                    ),
                    Icon = "check",
                })
            end
            return ok
        end

        local function getPhoneOfferOptionsContainer()
            local player = Players.LocalPlayer
            if not player then
                return nil
            end

            local playerGui = player:FindFirstChild("PlayerGui")
            local phone = playerGui and playerGui:FindFirstChild("Phone")
            local phoneInner = phone and phone:FindFirstChild("Phone")
            local screen = phoneInner and phoneInner:FindFirstChild("Screen")
            local footer = screen and screen:FindFirstChild("Footer")

            return footer and footer:FindFirstChild("Container")
        end

        local function hasPhoneOfferOptions(container)
            if not container then
                return false
            end

            for _, optionName in ipairs({ "Option1", "Option2", "Option3" }) do
                if container:FindFirstChild(optionName) then
                    return true
                end
            end

            return false
        end

        local function findPhoneOfferRemote()
            local tycoonInstance = findLocalTycoonInstance()
            if not tycoonInstance then
                return nil
            end

            local remotes = tycoonInstance:FindFirstChild("Remotes")
            local phoneOffer = remotes and remotes:FindFirstChild("PhoneOffer")
            if phoneOffer and phoneOffer:IsA("RemoteEvent") then
                return phoneOffer
            end

            return nil
        end

        local function tryAcceptPhoneOfferOnce()
            local container = getPhoneOfferOptionsContainer()
            if not hasPhoneOfferOptions(container) then
                return false
            end

            local remote = findPhoneOfferRemote()
            if not remote then
                return false
            end

            local ok = pcall(function()
                remote:FireServer("Accept")
            end)
            return ok
        end

        MainTab:CreateSection("Auto")

        MainTab:CreateToggle({
            Name = "Auto Accept Offer",
            Flag = "main_auto_accept_offer",
            CurrentValue = false,
            Callback = function(enabled)
                autoAcceptOfferRunning = enabled == true
                if not autoAcceptOfferRunning then
                    return
                end

                autoAcceptOfferLoopId += 1
                local loopId = autoAcceptOfferLoopId
                task.spawn(function()
                    while autoAcceptOfferRunning and loopId == autoAcceptOfferLoopId do
                        local ok = pcall(tryAcceptPhoneOfferOnce)
                        local delay = math.max(0.1, tonumber(autoAcceptOfferDelaySec) or 0.5)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })

        MainTab:CreateToggle({
            Name = "Auto Buy Powers",
            Flag = "main_auto_buy_powers",
            CurrentValue = false,
            Callback = function(enabled)
                autoBuyPowersRunning = enabled == true
                if not autoBuyPowersRunning then
                    return
                end

                autoBuyPowersLoopId += 1
                local loopId = autoBuyPowersLoopId
                task.spawn(function()
                    while autoBuyPowersRunning and loopId == autoBuyPowersLoopId do
                        local ok = pcall(tryAutoBuyPowersOnce)
                        local delay = math.max(1, tonumber(autoBuyPowersDelaySec) or 120)
                        task.wait(if ok then delay else math.max(delay, 1))
                    end
                end)
            end,
        })
    end
    installAutoExtras()
end


-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "sell_lemons", tabIcon = "map-pin" })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, {
    replicatedStorage = ReplicatedStorage,
    tabIcon = "boxes",
})

-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, "sempatpanick/sell_lemons/recordings", { tabIcon = "video" })

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/sell_lemons",
    rayfieldLibrary = SempatLibrary,
    tabIcon = "settings",
})

