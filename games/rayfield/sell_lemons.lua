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
        Content = opts.Content,
        Image = img,
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
local Window = RayfieldLibrary:CreateWindow({
    Name = "sempatpanick | Sell Lemons",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Sell Lemons",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "sempatpanick",
        FileName = "sell_lemons",
    },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
})


-- */  Local Player Tab  /* --
createLocalPlayerTab(Window, mountNotify)

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", 4483362458)

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

    local autoPickFruitRunning = false
    local autoPickFruitLoopId = 0
    local autoPickFruitDelaySec = 5
    local autoPickFruitMode = "Normal"
    local AUTO_PICK_FRUIT_MODES = { "Normal" }

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
                            mountNotify({
                                Title = "Auto Claim Cash",
                                Content = "Claimed " .. getEarnerDisplayName(entity, instance),
                                Icon = "check",
                            })
                        end
                    end
                end
            end
        end

        return claimedAny
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

        table.insert(lines, string.format(
            "Ready to Evolve: %s",
            if progressInfo.ready then "Yes" else "No"
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
        if not progressInfo or not progressInfo.ready then
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
                    "Evolved at %s progress.",
                    formatEvolutionProgressPercent(progressInfo.progress)
                ),
                Icon = "check",
            })
        end
        return ok
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

    task.spawn(function()
        requestUpgradeListRefresh(false)
        while upgradeListParagraph do
            task.wait(upgradeListAutoRefreshSec)
            requestUpgradeListRefresh(false)
        end
    end)

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

    local fireClickDetectorFn = (typeof(fireclickdetector) == "function" and fireclickdetector)
        or (typeof(clickdetector) == "function" and clickdetector)
        or nil

    local function isUnderWorkspaceTycoon(instance)
        local current = instance
        while current and current ~= Workspace do
            local parent = current.Parent
            if parent == Workspace then
                local numberPart = string.sub(current.Name, 7)
                return string.sub(current.Name, 1, 6) == "Tycoon"
                    and numberPart ~= ""
                    and tonumber(numberPart) ~= nil
            end
            current = parent
        end
        return false
    end

    local function pickFruitNormalOnce()
        if not fireClickDetectorFn then
            return false
        end

        local picked = 0
        for _, fruit in CollectionService:GetTagged("ClickFruit") do
            if isUnderWorkspaceTycoon(fruit) then
                local detector = fruit:FindFirstChildWhichIsA("ClickDetector", true)
                if detector then
                    pcall(function()
                        fireClickDetectorFn(detector, 1, "MouseClick")
                    end)
                    picked += 1
                end
            end
        end
        mountNotify({
            Title = "Auto Pick Fruit",
            Content = "Picked " .. picked .. " fruits",
            Icon = "check",
        })
        return true, picked
    end

    local function runAutoPickFruitOnce()
        if autoPickFruitMode == "Normal" then
            return pickFruitNormalOnce()
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

    MainTab:CreateSection("Auto")

    local function getLocalHumanoidRootPart()
        local player = Players.LocalPlayer
        local character = player and player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            return root
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

    local function collectCashDrops()
        local folder = Workspace:FindFirstChild("CashDrops")
        if not folder then
            return {}
        end

        local drops = {}
        for _, child in folder:GetChildren() do
            if child.Name == "CashDrop" and child.Parent then
                table.insert(drops, child)
            end
        end
        return drops
    end

    local function pickCashDropsOnce()
        local root = getLocalHumanoidRootPart()
        if not root then
            return false
        end

        local drops = collectCashDrops()
        if #drops == 0 then
            return false
        end

        local savedCFrame = root.CFrame
        for _, cashDrop in ipairs(drops) do
            if not autoPickCashDropRunning then
                break
            end

            local dropPos = getCashDropPosition(cashDrop)
            if dropPos then
                root.CFrame = CFrame.new(dropPos + Vector3.new(0, 2, 0))
                task.wait(2)
                root.CFrame = savedCFrame
            end
        end

        return true
    end

    MainTab:CreateToggle({
        Name = "Auto Pick Cash Drop",
        Flag = "main_auto_pick_cash_drop",
        CurrentValue = false,
        Callback = function(enabled)
            autoPickCashDropRunning = enabled == true
            if not autoPickCashDropRunning then
                return
            end

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
end

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "sell_lemons" })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, { replicatedStorage = ReplicatedStorage })

-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, "sempatpanick/sell_lemons/recordings")

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/sell_lemons",
    rayfieldLibrary = RayfieldLibrary,
})

