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

local function clearRayfieldDropdown(dropdown)
    if not dropdown then
        return
    end
    if dropdown.Set then
        local ok = pcall(function()
            dropdown:Set({})
        end)
        if ok then
            return
        end
    end
    if type(dropdown.CurrentOption) == "table" then
        table.clear(dropdown.CurrentOption)
    end
end

-- DataService / network callbacks may run off the main thread; Rayfield Refresh touches Instances.
local uiFlushQueued = false
local uiFlushConn: RBXScriptConnection? = nil
local uiJobsByKey: { [string]: () -> () } = {}
local uiJobsList: { () -> () } = {}

local function flushUiJobs()
    if uiFlushConn then
        uiFlushConn:Disconnect()
        uiFlushConn = nil
    end
    uiFlushQueued = false
    local keyed = uiJobsByKey
    local list = uiJobsList
    uiJobsByKey = {}
    uiJobsList = {}
    for _, job in pairs(keyed) do
        pcall(job)
    end
    for _, job in ipairs(list) do
        pcall(job)
    end
end

local function deferUiOnHeartbeat(fn: () -> (), jobKey: string?)
    if type(fn) ~= "function" then
        return
    end
    if jobKey then
        uiJobsByKey[jobKey] = fn
    else
        table.insert(uiJobsList, fn)
    end
    if uiFlushQueued then
        return
    end
    uiFlushQueued = true
    uiFlushConn = RunService.Heartbeat:Connect(flushUiJobs)
end

local HEARTBEAT_POLL_SEC = 1

local function schedulePeriodicOnHeartbeat(intervalSec: number, fn: () -> ()): RBXScriptConnection
    local lastAt = 0.0
    return RunService.Heartbeat:Connect(function()
        local now = os.clock()
        if now - lastAt < intervalSec then
            return
        end
        lastAt = now
        fn()
    end)
end

SlimeRngUtil = SlimeRngUtil or {}
SlimeRngUtil.numberSuffixMult = {
    K = 1e3,
    M = 1e6,
    B = 1e9,
    T = 1e12,
    Qd = 1e15,
    Qn = 1e18,
    Sx = 1e21,
    Sp = 1e24,
    O = 1e27,
    N = 1e30,
    De = 1e33,
    Ud = 1e36,
    Dd = 1e39,
    TdD = 1e42,
    QdD = 1e45,
    QnD = 1e48,
    SxD = 1e51,
    SpD = 1e54,
    OcD = 1e57,
    NvD = 1e60,
}
SlimeRngUtil.numberSuffixOrder = {}
do
    for suffix, mult in pairs(SlimeRngUtil.numberSuffixMult) do
        table.insert(SlimeRngUtil.numberSuffixOrder, { suffix = suffix, mult = mult })
    end
    table.sort(SlimeRngUtil.numberSuffixOrder, function(a, b)
        return a.mult > b.mult
    end)
end

function SlimeRngUtil.trimFormattedNumberZeros(text: string): string
    text = string.gsub(text, "(%.%d-)0+$", "%1")
    return string.gsub(text, "%.$", "")
end

function SlimeRngUtil.formatSuffixNumber(value: number): string
    if type(value) ~= "number" or value ~= value then
        return tostring(value)
    end
    if math.abs(value) < 1000 then
        return tostring(math.floor(value))
    end
    for _, entry in ipairs(SlimeRngUtil.numberSuffixOrder) do
        if math.abs(value) >= entry.mult then
            local scaled = value / entry.mult
            local absScaled = math.abs(scaled)
            if absScaled >= 100 then
                return SlimeRngUtil.trimFormattedNumberZeros(("%.0f%s"):format(scaled, entry.suffix))
            elseif absScaled >= 10 then
                return SlimeRngUtil.trimFormattedNumberZeros(("%.1f%s"):format(scaled, entry.suffix))
            end
            return SlimeRngUtil.trimFormattedNumberZeros(("%.2f%s"):format(scaled, entry.suffix))
        end
    end
    return tostring(math.floor(value))
end

function SlimeRngUtil.readDataServiceNumber(client: any, key: string): number?
    if not client or type(client.get) ~= "function" then
        return nil
    end
    local ok, val = pcall(function()
        return client:get(key)
    end)
    if not ok then
        return nil
    end
    if type(val) == "number" then
        return val
    end
    if type(val) == "string" then
        return tonumber(val)
    end
    return nil
end

function SlimeRngUtil.zonesModuleGetZone(zonesMod: any, zoneId: number): any?
    if not zonesMod or type(zonesMod.getZone) ~= "function" then
        return nil
    end
    local ok, def = pcall(zonesMod.getZone, zoneId)
    if ok and type(def) == "table" then
        return def
    end
    return nil
end

function SlimeRngUtil.zonesModuleHasZone(zonesMod: any, zoneId: number): boolean
    if not zonesMod or type(zonesMod.hasZone) ~= "function" then
        return false
    end
    local ok, yes = pcall(zonesMod.hasZone, zoneId)
    return ok and yes == true
end

-- Set by Auto Feed; used when loading configs (stable food labels, legacy qty strings).
local normalizeAutoFeedFoodConfigValue: ((any) -> any)? = nil
local syncAutoFeedFoodAfterConfigLoad: (() -> ())? = nil

-- */  Recording Tab (module)  /* --
local RECORDING_TAB_REPO = baseURL .. "/tabs/recording_tab.lua"
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
    Name = "sempatpanick | Slime RNG",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Slime RNG",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "sempatpanick",
        FileName = "slime_rng",
    },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
})

-- */  Window  /* --
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

local sharedInventoryItemUtils: any = nil

local function tryGetInventoryItemUtils(): any?
    if sharedInventoryItemUtils then
        return sharedInventoryItemUtils
    end
    local src = ReplicatedStorage:FindFirstChild("Source")
    local folder = src and src:FindFirstChild("Features")
    folder = folder and folder:FindFirstChild("Inventory")
    local mod = folder and folder:FindFirstChild("InventoryItemUtils")
    if not mod or not mod:IsA("ModuleScript") then
        return nil
    end
    local ok, result = pcall(require, mod)
    if ok and type(result) == "table" then
        sharedInventoryItemUtils = result
        return result
    end
    return nil
end

local function createMainTabSpecialDiceController(deps: {
    mainTab: any,
    getDataServiceClient: () -> any?,
    cloneTable: (any) -> { [string]: any },
    resolveInventoryRemote: () -> RemoteFunction?,
    onParagraphDirty: () -> (),
})
    local NONE = "(None)"
    local CATALOG: { { id: string, name: string } } = {
        { id = "jackpotSpin", name = "Jackpot Spin" },
        { id = "bigDice", name = "Big Dice" },
        { id = "hugeDice", name = "Huge Dice" },
        { id = "shinyDice", name = "Shiny Dice" },
        { id = "invertedDice", name = "Inverted Dice" },
    }
    local displayToId: { [string]: string } = {}
    local itemsSave: { [string]: any } = {}
    local selectedId: string? = nil
    local selectedName: string? = nil
    local autoUsePending = false
    local dropdown: any = nil
    local suppressDropdownCallback = false

    local function nameForId(diceId: string): string
        for _, dice in ipairs(CATALOG) do
            if dice.id == diceId then
                return dice.name
            end
        end
        return diceId
    end

    local function pullItems(): boolean
        local client = deps.getDataServiceClient()
        if not client then
            return false
        end
        local ok, items = pcall(function()
            return client:get("items")
        end)
        if ok and type(items) == "table" then
            itemsSave = deps.cloneTable(items)
            return true
        end
        return false
    end

    local function qtyForId(diceId: string): number
        local utils = tryGetInventoryItemUtils()
        if utils and type(utils.getAmountOwned) == "function" then
            return utils.getAmountOwned(diceId, {}, itemsSave)
        end
        local raw = itemsSave[diceId]
        if type(raw) == "number" then
            return math.max(0, math.floor(raw))
        end
        return 0
    end

    local function buildOptions(): { string }
        table.clear(displayToId)
        tryGetInventoryItemUtils()
        pullItems()
        local opts: { string } = { NONE }
        displayToId[NONE] = ""
        for _, dice in ipairs(CATALOG) do
            local label = ("%s x%d"):format(dice.name, qtyForId(dice.id))
            displayToId[label] = dice.id
            table.insert(opts, label)
        end
        return opts
    end

    local function refreshDropdownImpl()
        suppressDropdownCallback = true
        local opts = buildOptions()
        if dropdown and dropdown.Refresh then
            dropdown:Refresh(opts)
        end
        if selectedId then
            for _, dice in ipairs(CATALOG) do
                if dice.id == selectedId then
                    local label = ("%s x%d"):format(dice.name, qtyForId(dice.id))
                    if dropdown and dropdown.Set then
                        dropdown:Set(label)
                    end
                    suppressDropdownCallback = false
                    return
                end
            end
        end
        if dropdown and dropdown.Set then
            dropdown:Set(NONE)
        end
        suppressDropdownCallback = false
    end

    local function refreshDropdown()
        deferUiOnHeartbeat(refreshDropdownImpl, "mainSpecialDiceDropdown")
    end

    local function requestUseItem(itemId: string): boolean
        local rf = deps.resolveInventoryRemote()
        if not rf then
            return false
        end
        local ok, result = pcall(function()
            return rf:InvokeServer("requestUseItem", itemId)
        end)
        return ok == true and result == true
    end

    local function tryAutoUseWhenAllSelectedAtZero(selectedTierKeys: { string }, progressionByTier: { [string]: any })
        if not selectedId or autoUsePending or #selectedTierKeys == 0 then
            return
        end
        for _, tier in ipairs(selectedTierKeys) do
            local st = progressionByTier[tier]
            if not st or st.rollsUntilNext ~= 0 then
                return
            end
        end
        if qtyForId(selectedId) <= 0 then
            return
        end
        if requestUseItem(selectedId) then
            autoUsePending = true
            refreshDropdown()
        end
    end

    local itemsListenerConn: RBXScriptConnection? = nil
    local function ensureItemsDataListener()
        if itemsListenerConn then
            return
        end
        local client = deps.getDataServiceClient()
        if not client or type(client.getChangedSignal) ~= "function" then
            return
        end
        local ok, signal = pcall(function()
            return client:getChangedSignal("items")
        end)
        if not ok or not signal or type(signal.Connect) ~= "function" then
            return
        end
        itemsListenerConn = signal:Connect(function(newItems)
            if type(newItems) == "table" then
                itemsSave = deps.cloneTable(newItems)
                refreshDropdown()
            end
        end)
    end
    local function mountDropdown()
        if dropdown then
            return
        end
        ensureItemsDataListener()
        pullItems()
        dropdown = deps.mainTab:CreateDropdown({
            Name = "Special Dice",
            Flag = "main_special_dice_dropdown",
            Options = buildOptions(),
            CurrentOption = NONE,
            Search = true,
            Callback = function(value)
                if suppressDropdownCallback then
                    return
                end
                local picked = rayfieldDropdownFirst(value)
                if type(picked) ~= "string" or picked == NONE then
                    selectedId = nil
                    selectedName = nil
                    autoUsePending = false
                    deps.onParagraphDirty()
                    refreshDropdown()
                    return
                end
                local diceId = displayToId[picked]
                if not diceId or diceId == "" then
                    for _, dice in ipairs(CATALOG) do
                        local prefix = dice.name .. " x"
                        if string.sub(picked, 1, #prefix) == prefix then
                            diceId = dice.id
                            break
                        end
                    end
                end
                if not diceId or diceId == "" then
                    return
                end
                selectedId = diceId
                selectedName = nameForId(diceId)
                autoUsePending = false
                local used = requestUseItem(diceId)
                deps.onParagraphDirty()
                refreshDropdown()
                if not used then
                    mountNotify({
                        Title = "Special Dice",
                        Content = ("requestUseItem failed for %s."):format(selectedName or diceId),
                        Icon = "x",
                    })
                end
            end,
        })
    end

    return {
        footerLine = function(): string
            if selectedName then
                return ("Special dice: %s"):format(selectedName)
            end
            return "Special dice: none"
        end,
        mountDropdown = mountDropdown,
        refreshDropdown = refreshDropdown,
        tryAutoUseWhenAllSelectedAtZero = tryAutoUseWhenAllSelectedAtZero,
        clearAutoUsePending = function()
            autoUsePending = false
        end,
    }
end

local function mountItemsInventoryPageSection(
    mainTab: any,
    getDataServiceClientFn: () -> any?,
    cloneTableFn: (any) -> { [string]: any }
)
    mainTab:CreateSection("Inventory (items page)")

    local inv = {
        itemUtils = nil :: any,
        svcUtils = nil :: any,
        itemErr = nil :: string?,
        svcErr = nil :: string?,
        boosts = {} :: any,
        items = {} :: { [string]: any },
        inventory = {} :: { [string]: any },
        maxLines = 40,
    }

    local function requireInventoryMod(modName: string): boolean
        if modName == "InventoryItemUtils" and inv.itemUtils then
            return true
        end
        if modName == "InventoryServiceUtils" and inv.svcUtils then
            return true
        end
        if modName == "InventoryItemUtils" then
            local utils = tryGetInventoryItemUtils()
            if utils then
                inv.itemUtils = utils
                inv.itemErr = nil
                return true
            end
            inv.itemErr = "InventoryItemUtils not found under ReplicatedStorage.Source.Features.Inventory"
            return false
        end
        local src = ReplicatedStorage:FindFirstChild("Source")
        local folder = src and src:FindFirstChild("Features")
        folder = folder and folder:FindFirstChild("Inventory")
        local mod = folder and folder:FindFirstChild(modName)
        if not mod or not mod:IsA("ModuleScript") then
            inv.svcErr = modName .. " not found under ReplicatedStorage.Source.Features.Inventory"
            return false
        end
        local ok, result = pcall(require, mod)
        if not ok or type(result) ~= "table" then
            inv.svcErr = tostring(result)
            return false
        end
        inv.svcUtils = result
        inv.svcErr = nil
        return true
    end

    local function pullInventoryData(): boolean
        local client = getDataServiceClientFn()
        if not client then
            return false
        end
        local pulled = false
        local okB, boosts = pcall(function()
            return client:get("boosts")
        end)
        if okB and boosts ~= nil then
            inv.boosts = boosts
            pulled = true
        end
        local okI, items = pcall(function()
            return client:get("items")
        end)
        if okI and type(items) == "table" then
            inv.items = cloneTableFn(items)
            pulled = true
        end
        local okV, save = pcall(function()
            return client:get("inventory")
        end)
        if okV and type(save) == "table" then
            inv.inventory = cloneTableFn(save)
            pulled = true
        end
        return pulled
    end

    local function consumablesBody(): string
        if not requireInventoryMod("InventoryItemUtils") then
            return inv.itemErr or "Failed to load InventoryItemUtils."
        end
        local entries = inv.itemUtils.getConsumableEntries(inv.boosts, inv.items)
        if type(entries) ~= "table" or next(entries) == nil then
            if next(inv.items) == nil and (type(inv.boosts) ~= "table" or next(inv.boosts) == nil) then
                return 'No items data yet. Refresh or open Inventory (DataService "items" / "boosts").'
            end
            return "No owned consumables in current snapshot."
        end
        local rows = {}
        for id, entry in pairs(entries) do
            if type(entry) == "table" and type(entry.definition) == "table" then
                local def = entry.definition
                table.insert(rows, {
                    id = tostring(def.id or id),
                    name = tostring(def.name or id),
                    kind = tostring(def.kind or "?"),
                    amount = tonumber(entry.amountOwned) or 0,
                    order = tonumber(def.layoutOrder) or 0,
                })
            end
        end
        table.sort(rows, function(a, b)
            if a.order ~= b.order then
                return a.order < b.order
            end
            return a.name < b.name
        end)
        local lines = { ("ConsumablesList (%d)"):format(#rows) }
        local n = math.min(#rows, inv.maxLines)
        for i = 1, n do
            local r = rows[i]
            table.insert(lines, ("  %s (%s)  [%s]  x%d"):format(r.name, r.id, r.kind, r.amount))
        end
        if #rows > n then
            table.insert(lines, ("… and %d more"):format(#rows - n))
        end
        return table.concat(lines, "\n")
    end

    local function slimesBody(): string
        if not requireInventoryMod("InventoryServiceUtils") then
            return inv.svcErr or "Failed to load InventoryServiceUtils."
        end
        local feedable = {}
        for uid, value in pairs(inv.inventory) do
            local count = if type(value) == "number" then value else 1
            if count > 0 then
                feedable[uid] = if type(value) == "number" then value else value
            end
        end
        if next(feedable) == nil then
            if next(inv.inventory) == nil then
                return 'No inventory data yet. Refresh or open Inventory (DataService "inventory").'
            end
            return "No feedable slimes (count > 0)."
        end
        local rows = {}
        for uid, value in pairs(feedable) do
            local data = inv.svcUtils.getSlimeData(uid, value)
            local lvl = if type(data) == "table" then tonumber(data.level) or 1 else 1
            local sid = if type(data) == "table" then tostring(data.id or "?") else "?"
            local order = 0
            if type(data) == "table" and type(inv.svcUtils.getLayoutOrder) == "function" then
                order = tonumber(inv.svcUtils.getLayoutOrder(data)) or 0
            end
            local odds = ""
            if type(data) == "table" and type(inv.svcUtils.getVisualOdds) == "function" then
                local o = inv.svcUtils.getVisualOdds(data)
                if type(o) == "number" and o > 0 then
                    odds = ("1/%d"):format(math.max(1, math.round(1 / o)))
                end
            end
            table.insert(rows, {
                uid = uid,
                id = sid,
                lvl = lvl,
                stack = if type(value) == "number" then value else nil,
                odds = odds,
                order = order,
            })
        end
        table.sort(rows, function(a, b)
            if a.order ~= b.order then
                return a.order > b.order
            end
            return a.uid < b.uid
        end)
        local lines = { ("FeedableSlimesList (%d)"):format(#rows) }
        local n = math.min(#rows, inv.maxLines)
        for i = 1, n do
            local r = rows[i]
            local stack = if r.stack and r.stack > 1 then ("  x%d"):format(r.stack) else ""
            local odd = if r.odds ~= "" then ("  %s"):format(r.odds) else ""
            table.insert(lines, ("  %s  Lv%d%s%s"):format(r.id, r.lvl, stack, odd))
            table.insert(lines, ("    uid: %s"):format(#r.uid > 36 and string.sub(r.uid, 1, 33) .. "…" or r.uid))
        end
        if #rows > n then
            table.insert(lines, ("… and %d more"):format(#rows - n))
        end
        return table.concat(lines, "\n")
    end

    local paraConsumables = mainTab:CreateParagraph({ Title = "ConsumablesList", Content = "Loading…" })
    local paraSlimes = mainTab:CreateParagraph({ Title = "FeedableSlimesList", Content = "Loading…" })

    local function refresh()
        requireInventoryMod("InventoryItemUtils")
        requireInventoryMod("InventoryServiceUtils")
        pullInventoryData()
        if paraConsumables and paraConsumables.Set then
            paraConsumables:Set({ Title = "ConsumablesList", Content = consumablesBody() })
        end
        if paraSlimes and paraSlimes.Set then
            paraSlimes:Set({ Title = "FeedableSlimesList", Content = slimesBody() })
        end
    end

    mainTab:CreateButton({
        Name = "Refresh inventory data",
        Flag = "main_inventory_refresh",
        Callback = function()
            deferUiOnHeartbeat(refresh, "inventoryPageRefresh")
        end,
    })
    deferUiOnHeartbeat(refresh, "inventoryPageRefresh")
end

local function mountAutoFeedSection(
    mainTab: any,
    findNetworkerServiceRemotesFolderFn: (string, string?) -> Instance?,
    lootUidFromInstanceFn: (Instance) -> string?
)
    mainTab:CreateSection("Auto Feed")

    local s = {
        none = "(None)",
        systemFoods = {
            { id = "apple", name = "Cheese", xp = 75 },
            { id = "carrot", name = "Egg", xp = 100 },
            { id = "cherries", name = "Fries", xp = 125 },
            { id = "grapes", name = "Taco", xp = 150 },
            { id = "banana", name = "Hotdog", xp = 175 },
            { id = "watermelon", name = "Burger", xp = 200 },
            { id = "pizza", name = "Pizza", xp = 225 },
            { id = "chicken", name = "Chicken", xp = 250 },
            { id = "drumstick", name = "Drumstick", xp = 275 },
        } :: { { id: string, name: string, xp: number } },
        foodById = {} :: { [string]: { id: string, name: string, xp: number } },
        foodOptionToId = {} :: { [string]: string },
        selectedFoodIds = {} :: { string },
        foodDropdown = nil :: any,
        foodCycleIndex = 0,
        lastConsumablesList = nil :: Instance?,
        consumablesConns = {} :: { RBXScriptConnection },
        optionToUid = {} :: { [string]: string },
        selectedUid = nil :: string?,
        selectedOption = nil :: string?,
        slimeDropdown = nil :: any,
        enabled = false,
        useAllFood = false,
        loopToken = 0,
        intervalSec = 2.5,
        consumablesListPath = {
            "Root",
            "Inventory",
            "PageItemsContent",
            "ItemsInventoryPage",
            "DefaultItemsView",
            "ConsumablesPanel",
            "ConsumablesList",
        },
    }
    for _, food in ipairs(s.systemFoods) do
        s.foodById[food.id] = food
    end

    local function trimGuiText(text: string): string
        local t = string.gsub(text or "", "^%s+", "")
        t = string.gsub(t, "%s+$", "")
        t = string.gsub(t, "\r\n", " ")
        t = string.gsub(t, "\n", " ")
        return t
    end

    local function guiInstanceTextContent(d: Instance): string
        if d:IsA("TextLabel") then
            return (d :: TextLabel).Text
        end
        if d:IsA("TextButton") then
            return (d :: TextButton).Text
        end
        if d:IsA("TextBox") then
            return (d :: TextBox).Text
        end
        return ""
    end

    local function findConsumablesList(): Instance?
        local lp = Players.LocalPlayer
        local pg = lp and lp:FindFirstChild("PlayerGui")
        if not pg then
            return nil
        end
        local cur: Instance? = pg
        for _, seg in ipairs(s.consumablesListPath) do
            local nextInst = cur and cur:FindFirstChild(seg)
            if not nextInst then
                cur = nil
                break
            end
            cur = nextInst
        end
        if cur then
            return cur
        end
        return pg:FindFirstChild("ConsumablesList", true)
    end

    local function parseConsumableAmountText(text: string): number
        local t = trimGuiText(text or "")
        local n = string.match(t, "[xX](%d+)")
        if n then
            return tonumber(n) or 0
        end
        n = string.match(t, "(%d+)")
        return tonumber(n) or 0
    end

    local function scanOwnedFoodByDisplayName(): { [string]: number }
        local out: { [string]: number } = {}
        local list = findConsumablesList()
        if not list then
            return out
        end
        for _, ch in ipairs(list:GetChildren()) do
            if ch:IsA("GuiObject") and string.match(ch.Name, "ItemButton$") then
                local displayName = ""
                local nameFrame = ch:FindFirstChild("TextLabelFrame")
                if nameFrame then
                    local tl = nameFrame:FindFirstChild("TextLabel")
                    if tl and (tl:IsA("TextLabel") or tl:IsA("TextButton") or tl:IsA("TextBox")) then
                        displayName = trimGuiText(guiInstanceTextContent(tl))
                    end
                end
                local amt = 0
                local amtFrame = ch:FindFirstChild("Amount")
                if amtFrame then
                    local atl = amtFrame:FindFirstChild("TextLabel")
                    if atl and (atl:IsA("TextLabel") or atl:IsA("TextButton") or atl:IsA("TextBox")) then
                        amt = parseConsumableAmountText(guiInstanceTextContent(atl))
                    end
                end
                if displayName ~= "" then
                    out[displayName] = (out[displayName] or 0) + amt
                end
            end
        end
        return out
    end

    local function foodDropdownOptionLabel(displayName: string, xp: number): string
        return ('%s  %d XP'):format(displayName, xp)
    end

    local function foodNameFromOptionLabel(opt: string): string
        local trimmed = trimGuiText(opt)
        local name = string.match(trimmed, "^(.-)%s+%d+%s+XP")
        if name then
            return trimGuiText(name)
        end
        local withoutQty = string.match(trimmed, "^(.-)%s+x%d+$")
        if withoutQty then
            return foodNameFromOptionLabel(withoutQty)
        end
        return trimmed
    end

    local function buildFoodDropdownOptions(): { string }
        table.clear(s.foodOptionToId)
        local foods: { { id: string, name: string, xp: number } } = {}
        for _, food in ipairs(s.systemFoods) do
            table.insert(foods, food)
        end
        table.sort(foods, function(a, b)
            if a.xp ~= b.xp then
                return a.xp > b.xp
            end
            return a.name < b.name
        end)
        local opts: { string } = {}
        for _, food in ipairs(foods) do
            local option = foodDropdownOptionLabel(food.name, food.xp)
            s.foodOptionToId[option] = food.id
            table.insert(opts, option)
        end
        return opts
    end

    local function normalizeAutoFeedFoodConfigValueImpl(saved: any): any
        if saved == nil then
            return saved
        end
        buildFoodDropdownOptions()
        local nameToOption: { [string]: string } = {}
        for _, food in ipairs(s.systemFoods) do
            nameToOption[food.name] = foodDropdownOptionLabel(food.name, food.xp)
        end
        local function mapOne(raw: any): string?
            if type(raw) ~= "string" or raw == "" then
                return nil
            end
            if s.foodOptionToId[raw] then
                return raw
            end
            local name = foodNameFromOptionLabel(raw)
            return nameToOption[name]
        end
        if type(saved) == "table" then
            local out: { string } = {}
            for _, v in ipairs(saved) do
                local mapped = mapOne(v)
                if mapped and not table.find(out, mapped) then
                    table.insert(out, mapped)
                end
            end
            return out
        end
        if type(saved) == "string" then
            local mapped = mapOne(saved)
            return mapped or saved
        end
        return saved
    end

    local function syncAutoFeedFoodFromConfig(saved: any)
        local normalized = normalizeAutoFeedFoodConfigValueImpl(saved)
        s.selectedFoodIds = {}
        local picked: { string } = {}
        if type(normalized) == "table" then
            picked = normalized
        elseif type(normalized) == "string" and normalized ~= "" then
            picked = { normalized }
        end
        for _, opt in ipairs(picked) do
            local id = s.foodOptionToId[opt]
            if id and not table.find(s.selectedFoodIds, id) then
                table.insert(s.selectedFoodIds, id)
            end
        end
    end

    normalizeAutoFeedFoodConfigValue = normalizeAutoFeedFoodConfigValueImpl

    local function foodDropdownOptionsForIds(ids: { string }): { string }
        local opts = buildFoodDropdownOptions()
        local picked: { string } = {}
        for _, opt in ipairs(opts) do
            local id = s.foodOptionToId[opt]
            if id and table.find(ids, id) then
                table.insert(picked, opt)
            end
        end
        return picked
    end

    local function disconnectConsumablesListeners()
        for _, c in ipairs(s.consumablesConns) do
            c:Disconnect()
        end
        table.clear(s.consumablesConns)
        s.lastConsumablesList = nil
    end

    local function refreshFoodDropdownImpl(showNotify: boolean)
        local prevIds: { string } = {}
        for _, id in ipairs(s.selectedFoodIds) do
            table.insert(prevIds, id)
        end
        local opts = buildFoodDropdownOptions()
        local newSelection = foodDropdownOptionsForIds(prevIds)
        if s.foodDropdown and s.foodDropdown.Refresh then
            s.foodDropdown:Refresh(opts)
        end
        s.selectedFoodIds = {}
        for _, opt in ipairs(newSelection) do
            local id = s.foodOptionToId[opt]
            if id then
                table.insert(s.selectedFoodIds, id)
            end
        end
        if s.foodDropdown and s.foodDropdown.Set then
            s.foodDropdown:Set(newSelection)
        end
        if showNotify then
            mountNotify({
                Title = "Auto Feed",
                Content = "Food list updated (" .. tostring(#opts) .. " types).",
            })
        end
    end

    local function refreshFoodDropdown(showNotify: boolean)
        deferUiOnHeartbeat(function()
            refreshFoodDropdownImpl(showNotify)
        end, "autoFeedFoodDropdown")
    end

    syncAutoFeedFoodAfterConfigLoad = function()
        local flagObj = RayfieldLibrary.Flags and RayfieldLibrary.Flags["main_auto_feed_food_dropdown"]
        if flagObj then
            local saved = flagObj.CurrentValue
            if saved == nil then
                saved = flagObj.CurrentOption
            end
            syncAutoFeedFoodFromConfig(saved)
        end
        refreshFoodDropdown(false)
    end

    local function hookConsumableItemButton(btn: Instance)
        local amtFrame = btn:FindFirstChild("Amount")
        if not amtFrame then
            return
        end
        local atl = amtFrame:FindFirstChild("TextLabel")
        if atl and (atl:IsA("TextLabel") or atl:IsA("TextButton") or atl:IsA("TextBox")) then
            table.insert(s.consumablesConns, atl:GetPropertyChangedSignal("Text"):Connect(function()
                refreshFoodDropdown(false)
            end))
        end
    end

    local function bindConsumablesListeners()
        disconnectConsumablesListeners()
        local list = findConsumablesList()
        if not list then
            return
        end
        s.lastConsumablesList = list
        local function bump()
            refreshFoodDropdown(false)
        end
        table.insert(s.consumablesConns, list.ChildAdded:Connect(function(ch)
            hookConsumableItemButton(ch)
            bump()
        end))
        table.insert(s.consumablesConns, list.ChildRemoved:Connect(bump))
        for _, ch in ipairs(list:GetChildren()) do
            hookConsumableItemButton(ch)
        end
    end

    local function ensureConsumablesWatch()
        local list = findConsumablesList()
        if list and list ~= s.lastConsumablesList then
            bindConsumablesListeners()
            refreshFoodDropdown(false)
        end
    end

    local function activeFoodIds(): { string }
        local owned = scanOwnedFoodByDisplayName()
        local out: { string } = {}
        for _, id in ipairs(s.selectedFoodIds) do
            local def = s.foodById[id]
            if def and (owned[def.name] or 0) > 0 then
                table.insert(out, id)
            end
        end
        return out
    end

    local function nextFoodId(): string?
        local ids = activeFoodIds()
        if #ids == 0 then
            return nil
        end
        s.foodCycleIndex = (s.foodCycleIndex % #ids) + 1
        return ids[s.foodCycleIndex]
    end

    local function ownedAmountForFoodId(foodId: string): number
        local def = s.foodById[foodId]
        if not def then
            return 0
        end
        local owned = scanOwnedFoodByDisplayName()
        return math.clamp(math.floor(owned[def.name] or 0), 0, 9999)
    end

    local function oddsSuffixMultiplier(suf: string): number
        if suf == "" then
            return 1
        end
        local lower = string.lower(suf)
        for key, mult in pairs(SlimeRngUtil.numberSuffixMult) do
            if string.lower(key) == lower then
                return mult
            end
        end
        return 1
    end

    local function parseOddsSortKey(oddsText: string): number
        local t = trimGuiText(oddsText or "")
        if t == "" then
            return 0
        end
        local rhs = string.match(t, "1%s*/%s*(.+)")
        if not rhs then
            rhs = t
        end
        rhs = trimGuiText(rhs)
        local numStr, suf = string.match(rhs, "^([%d%.]+)%s*([%a]*)$")
        if not numStr then
            return 0
        end
        local n = tonumber(numStr)
        if type(n) ~= "number" or n ~= n then
            return 0
        end
        return n * oddsSuffixMultiplier(suf or "")
    end

    local function findWorkspaceSlimesFolders(): { Instance }
        local out: { Instance } = {}
        for _, ch in ipairs(Workspace:GetChildren()) do
            if string.sub(ch.Name, 1, #"Gameplay") == "Gameplay" then
                local slimes = ch:FindFirstChild("Slimes")
                if slimes then
                    table.insert(out, slimes)
                end
            end
        end
        return out
    end

    local function guiTextFromContentChild(content: Instance, childName: string): string
        local node = content:FindFirstChild(childName)
        if not node then
            return ""
        end
        if node:IsA("TextLabel") or node:IsA("TextButton") or node:IsA("TextBox") then
            local fromFmt = formatGuiInstanceTextForDisplay(node)
            if fromFmt then
                return trimGuiText(fromFmt)
            end
            return trimGuiText(guiInstanceTextContent(node))
        end
        local tl = node:FindFirstChildWhichIsA("TextLabel", true)
        if tl then
            local fromFmt = formatGuiInstanceTextForDisplay(tl)
            if fromFmt then
                return trimGuiText(fromFmt)
            end
            return trimGuiText(guiInstanceTextContent(tl))
        end
        return ""
    end

    local function slimeBillboardNameAndOdds(slime: Instance): (string, string)
        local bb = slime:FindFirstChild("SlimeInfoBillboard", true)
        if not bb then
            return "", ""
        end
        local content = bb:FindFirstChild("Content")
        if not content then
            return "", ""
        end
        local name = guiTextFromContentChild(content, "Name")
        local odds = ""
        local oddsFolder = content:FindFirstChild("Odds")
        if oddsFolder then
            local tl = oddsFolder:FindFirstChild("TextLabel")
            if tl and (tl:IsA("TextLabel") or tl:IsA("TextButton") or tl:IsA("TextBox")) then
                local fromFmt = formatGuiInstanceTextForDisplay(tl)
                odds = trimGuiText(fromFmt or guiInstanceTextContent(tl))
            else
                local any = oddsFolder:FindFirstChildWhichIsA("TextLabel", true)
                if any then
                    local fromFmt = formatGuiInstanceTextForDisplay(any)
                    odds = trimGuiText(fromFmt or guiInstanceTextContent(any))
                end
            end
        end
        return name, odds
    end

    local function normalizeWorkspaceSlimeUid(uid: string): string
        return string.gsub(uid, "#%d+$", "")
    end

    local function scanFeedableSlimeOptions(): { string }
        table.clear(s.optionToUid)
        local slimeFolders = findWorkspaceSlimesFolders()
        if #slimeFolders == 0 then
            return { s.none }
        end
        type SlimeFeedRow = { uid: string, name: string, odds: string, sortKey: number }
        local rows: { SlimeFeedRow } = {}
        local seenUid: { [string]: boolean } = {}
        for _, folder in ipairs(slimeFolders) do
            for _, slime in ipairs(folder:GetChildren()) do
                local uid = normalizeWorkspaceSlimeUid(lootUidFromInstanceFn(slime) or slime.Name)
                if uid == "" or seenUid[uid] then
                    continue
                end
                seenUid[uid] = true
                local name, odds = slimeBillboardNameAndOdds(slime)
                if name == "" then
                    name = slime.Name
                end
                table.insert(rows, {
                    uid = uid,
                    name = name,
                    odds = odds,
                    sortKey = parseOddsSortKey(odds),
                })
            end
        end
        table.sort(rows, function(a, b)
            if a.sortKey ~= b.sortKey then
                return a.sortKey > b.sortKey
            end
            if a.name ~= b.name then
                return a.name < b.name
            end
            return a.uid < b.uid
        end)
        local opts: { string } = { s.none }
        for _, row in ipairs(rows) do
            local option: string
            if row.odds ~= "" then
                option = ('%s  %s'):format(row.name, row.odds)
            else
                option = ('%s'):format(row.name)
            end
            if #option > 190 then
                option = string.sub(option, 1, 187) .. "..."
            end
            if not s.optionToUid[option] then
                s.optionToUid[option] = row.uid
                table.insert(opts, option)
            end
        end
        if #opts == 1 then
            return { s.none }
        end
        return opts
    end

    local function refreshSlimeDropdownImpl(showNotify: boolean)
        local opts = scanFeedableSlimeOptions()
        if s.slimeDropdown and s.slimeDropdown.Refresh then
            s.slimeDropdown:Refresh(opts)
        end
        if s.selectedOption and not table.find(opts, s.selectedOption) then
            s.selectedOption = nil
            s.selectedUid = nil
            if s.slimeDropdown and s.slimeDropdown.Select then
                s.slimeDropdown:Select(nil)
            end
            if s.slimeDropdown and s.slimeDropdown.Set then
                s.slimeDropdown:Set({ s.none })
            end
        end
        if showNotify then
            mountNotify({
                Title = "Auto Feed",
                Content = #opts > 1 and ("Slime list updated (" .. tostring(#opts - 1) .. ", sorted rarest first).") or 'No slimes under Workspace → Gameplay* → Slimes (with SlimeInfoBillboard).',
            })
        end
    end

    local function refreshSlimeDropdown(showNotify: boolean)
        deferUiOnHeartbeat(function()
            refreshSlimeDropdownImpl(showNotify)
        end, "autoFeedSlimeDropdown")
    end

    s.foodDropdown = mainTab:CreateDropdown({
        Name = "Foods",
        Flag = "main_auto_feed_food_dropdown",
        Options = buildFoodDropdownOptions(),
        CurrentOption = {},
        MultipleOptions = true,
        Search = true,
        Callback = function(value)
            s.selectedFoodIds = {}
            if type(value) == "table" then
                for _, opt in ipairs(value) do
                    if type(opt) == "string" then
                        local id = s.foodOptionToId[opt]
                        if id and not table.find(s.selectedFoodIds, id) then
                            table.insert(s.selectedFoodIds, id)
                        end
                    end
                end
            elseif type(value) == "string" then
                local id = s.foodOptionToId[value]
                if id then
                    s.selectedFoodIds = { id }
                end
            end
        end,
    })

    mainTab:CreateToggle({
        Name = "Use All Food",
        Flag = "main_auto_feed_use_all_food",
        CurrentValue = false,
        Callback = function(enabled)
            s.useAllFood = enabled == true
        end,
    })

    s.slimeDropdown = mainTab:CreateDropdown({
        Name = "Slime",
        Flag = "main_auto_feed_slime_dropdown",
        Options = scanFeedableSlimeOptions(),
        CurrentOption = { s.none },
        Search = true,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            s.selectedOption = if type(picked) == "string" then picked else nil
            if not s.selectedOption or s.selectedOption == s.none then
                s.selectedUid = nil
                return
            end
            s.selectedUid = s.optionToUid[s.selectedOption]
        end,
    })

    mainTab:CreateButton({
        Name = "Refresh slime list",
        Flag = "main_auto_feed_refresh_slimes",
        Callback = function()
            refreshSlimeDropdown(true)
        end,
    })

    task.defer(function()
        ensureConsumablesWatch()
        deferUiOnHeartbeat(function()
            refreshFoodDropdownImpl(false)
        end, "autoFeedFoodDropdown")
    end)

    local lpForConsumables = Players.LocalPlayer
    if lpForConsumables then
        local pgWatch = lpForConsumables:FindFirstChild("PlayerGui") or lpForConsumables:WaitForChild("PlayerGui", 30)
        if pgWatch then
            pgWatch.DescendantAdded:Connect(function()
                ensureConsumablesWatch()
            end)
        end
    end

    mainTab:CreateToggle({
        Name = "Auto Feed",
        Flag = "main_auto_feed_enabled",
        CurrentValue = false,
        Callback = function(enabled)
            s.enabled = enabled == true
            s.loopToken = s.loopToken + 1
            local myToken = s.loopToken

            if not s.enabled then
                return
            end

            ensureConsumablesWatch()
            refreshFoodDropdown(false)
            refreshSlimeDropdown(false)

            task.spawn(function()
                while myToken == s.loopToken and s.enabled do
                    local foodId = nextFoodId()
                    if not foodId then
                        task.wait(s.intervalSec)
                    else
                        local useUid = s.selectedUid
                        if not useUid then
                            task.wait(s.intervalSec)
                        else
                            local inv = findNetworkerServiceRemotesFolderFn("InventoryService")
                            local rf = inv and inv:FindFirstChild("RemoteFunction")
                            if not rf or not rf:IsA("RemoteFunction") then
                                task.wait(s.intervalSec)
                            else
                                local ownedAmt = ownedAmountForFoodId(foodId)
                                if ownedAmt > 0 then
                                    local useQty = if s.useAllFood then ownedAmt else 1
                                    pcall(function()
                                        (rf :: RemoteFunction):InvokeServer("requestUseFood", foodId, useUid, useQty)
                                    end)
                                end
                                task.wait(s.intervalSec)
                            end
                        end
                    end
                end
            end)
        end,
    })
end

local function mountUfoEventSection(
    mainTab: any,
    findNetworkerServiceRemotesFolderFn: (string, string?) -> Instance?
)
    mainTab:CreateSection("UFO Event")

    local s = {
        paragraph = nil :: any,
        zonesMod = nil :: any,
        zonesClient = nil :: any,
        ufoClient = nil :: any,
        autoTeleportEnabled = false,
        savedReturnCframe = nil :: CFrame?,
        lastAutoTeleportZoneId = nil :: number?,
    }

    local function tryLoadGameModules(): boolean
        if s.zonesMod then
            return true
        end
        local src = ReplicatedStorage:FindFirstChild("Source")
        if not src then
            return false
        end
        local features = src:FindFirstChild("Features")
        local gameFolder = src:FindFirstChild("Game")
        local zonesItems = gameFolder and gameFolder:FindFirstChild("Items")
        zonesItems = zonesItems and zonesItems:FindFirstChild("Zones")
        local zonesClientMod = features and features:FindFirstChild("Zones")
        zonesClientMod = zonesClientMod and zonesClientMod:FindFirstChild("ZonesServiceClient")
        local ufoFolder = features and features:FindFirstChild("UfoEvent")
        local ufoMod = ufoFolder and (
            ufoFolder:FindFirstChild("UfoEventServiceClient") or ufoFolder:FindFirstChild("UfoEvent")
        )
        if zonesItems and zonesItems:IsA("ModuleScript") then
            local ok, result = pcall(require, zonesItems)
            if ok and type(result) == "table" then
                s.zonesMod = result
            end
        end
        if zonesClientMod and zonesClientMod:IsA("ModuleScript") then
            local ok, result = pcall(require, zonesClientMod)
            if ok and type(result) == "table" then
                s.zonesClient = result
            end
        end
        if ufoMod and ufoMod:IsA("ModuleScript") then
            local ok, result = pcall(require, ufoMod)
            if ok and type(result) == "table" then
                s.ufoClient = result
            end
        end
        return s.zonesMod ~= nil
    end

    local function fetchUfoState(): any?
        if s.ufoClient and type(s.ufoClient.getStateSource) == "function" then
            local ok, stateSource = pcall(s.ufoClient.getStateSource, s.ufoClient)
            if ok and type(stateSource) == "function" then
                local okRead, state = pcall(stateSource)
                if okRead and type(state) == "table" then
                    return state
                end
            end
        end
        local fold = findNetworkerServiceRemotesFolderFn("UfoEventService")
        local rf = fold and fold:FindFirstChild("RemoteFunction")
        if rf and rf:IsA("RemoteFunction") then
            local ok, state = pcall(function()
                return (rf :: RemoteFunction):InvokeServer("getState")
            end)
            if ok and type(state) == "table" then
                return state
            end
        end
        return nil
    end

    local function formatCountdown(nextStart: number): string
        local remain = math.max(0, math.round(nextStart - Workspace:GetServerTimeNow()))
        local mins = math.floor(remain / 60)
        local secs = remain - mins * 60
        if mins > 0 then
            return ("%02d:%02d"):format(mins, secs)
        end
        return tostring(secs) .. "s"
    end

    local function zoneLabel(zoneId: any): string
        local id = tonumber(zoneId)
        if not id or not s.zonesMod or type(s.zonesMod.getZone) ~= "function" then
            return tostring(zoneId or "?")
        end
        def = SlimeRngUtil.zonesModuleGetZone(s.zonesMod, id)
        if type(def) == "table" and type(def.name) == "string" then
            return ('%s (#%d)'):format(def.name, id)
        end
        return ("Zone #%d"):format(id)
    end

    local function liveUfoPosition(): Vector3?
        local folder = Workspace:FindFirstChild("UfoEvent")
        if not folder then
            return nil
        end
        local model = folder:FindFirstChildWhichIsA("Model", true)
        if model then
            return model:GetPivot().Position
        end
        return nil
    end

    local function findZoneHitbox(zoneId: any): BasePart?
        local id = tonumber(zoneId) or zoneId
        if s.zonesClient and type(s.zonesClient.findZoneHitbox) == "function" then
            local ok, hitbox = pcall(s.zonesClient.findZoneHitbox, s.zonesClient, id)
            if ok and hitbox and hitbox:IsA("BasePart") then
                return hitbox
            end
        end
        local zones = Workspace:FindFirstChild("Zones")
        local zoneFolder = zones and zones:FindFirstChild(tostring(id))
        local poi = zoneFolder and zoneFolder:FindFirstChild("POI")
        local hitbox = poi and poi:FindFirstChild("Hitbox")
        if hitbox and hitbox:IsA("BasePart") then
            return hitbox
        end
        return nil
    end

    local function getHumanoidRootPart(): BasePart?
        local lp = Players.LocalPlayer
        local character = lp and lp.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:IsA("BasePart") then
            return hrp
        end
        return nil
    end

    local function zoneExists(zoneId: number): boolean
        if s.zonesMod and type(s.zonesMod.hasZone) == "function" then
            if SlimeRngUtil.zonesModuleHasZone(s.zonesMod, zoneId) then
                return true
            end
        end
        return findZoneHitbox(zoneId) ~= nil
    end

    local function getPlayerZoneId(): number?
        packages = ReplicatedStorage:FindFirstChild("Packages")
        dsMod = packages and packages:FindFirstChild("DataService")
        if dsMod and dsMod:IsA("ModuleScript") then
            ok, ds = pcall(require, dsMod)
            if ok and type(ds) == "table" and type(ds.client) == "table" then
                zone = SlimeRngUtil.readDataServiceNumber(ds.client, "zone")
                if zone then
                    return math.max(math.floor(zone), 1)
                end
            end
        end
        return nil
    end

    local function workspaceUfoZoneId(): number?
        zonesFolder = Workspace:FindFirstChild("Zones")
        if not zonesFolder then
            return nil
        end
        for _, child in ipairs(zonesFolder:GetChildren()) do
            zid = tonumber(child.Name)
            if zid then
                for _, inst in ipairs(child:GetDescendants()) do
                    if inst.Name == "UFO" or inst.Name == "GoldUFO" then
                        return zid
                    end
                end
            end
        end
        return nil
    end

    local function isUfoEventActive(state: any?): boolean
        return type(state) == "table" and type(state.phase) == "string" and state.phase ~= "idle"
    end

    local function activeUfoZoneId(state: any): number?
        if not isUfoEventActive(state) then
            return nil
        end
        id = tonumber(state.zoneId)
        if id and zoneExists(id) then
            return id
        end
        return workspaceUfoZoneId()
    end

    local ZONES_NETWORKER_VERSION = "leifstout_networker@0.3.1"

    local function requestTeleportZone(zoneId: number): boolean
        fold = findNetworkerServiceRemotesFolderFn("ZonesService", ZONES_NETWORKER_VERSION)
        rf = fold and fold:FindFirstChild("RemoteFunction")
        if not rf or not rf:IsA("RemoteFunction") then
            return false
        end
        ok, success = pcall(function()
            return (rf :: RemoteFunction):InvokeServer("requestTeleportZone", zoneId)
        end)
        return ok and success == true
    end

    local function saveReturnPosition()
        local hrp = getHumanoidRootPart()
        if hrp then
            s.savedReturnCframe = hrp.CFrame
        end
    end

    local function restoreReturnPosition()
        if not s.savedReturnCframe then
            return
        end
        local hrp = getHumanoidRootPart()
        if hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = s.savedReturnCframe
        end
        s.savedReturnCframe = nil
    end

    local function teleportToZoneId(zoneId: number, showNotify: boolean): boolean
        if requestTeleportZone(zoneId) then
            if showNotify then
                mountNotify({
                    Title = "UFO",
                    Content = "Teleported to " .. zoneLabel(zoneId) .. ".",
                    Icon = "check",
                })
            end
            return true
        end
        hitbox = findZoneHitbox(zoneId)
        hrp = getHumanoidRootPart()
        if hitbox and hrp then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(hitbox.Position + Vector3.new(0, 5, 0))
            if showNotify then
                mountNotify({
                    Title = "UFO",
                    Content = "Teleported near " .. zoneLabel(zoneId) .. " POI.",
                    Icon = "check",
                })
            end
            return true
        end
        if showNotify then
            mountNotify({
                Title = "UFO",
                Content = "Could not teleport to that zone.",
                Icon = "x",
            })
        end
        return false
    end

    local function processAutoTeleport()
        if not s.autoTeleportEnabled then
            return
        end
        tryLoadGameModules()
        local state = fetchUfoState()
        if not state then
            return
        end
        if isUfoEventActive(state) then
            activeZone = activeUfoZoneId(state)
            if not activeZone then
                return
            end
            if s.lastAutoTeleportZoneId == activeZone then
                return
            end
            if not s.savedReturnCframe then
                saveReturnPosition()
            end
            s.lastAutoTeleportZoneId = activeZone
            if teleportToZoneId(activeZone, false) then
                mountNotify({
                    Title = "UFO",
                    Content = "Auto teleported to " .. zoneLabel(activeZone) .. " (following UFO).",
                    Icon = "check",
                })
            else
                s.lastAutoTeleportZoneId = nil
            end
        elseif s.savedReturnCframe then
            restoreReturnPosition()
            s.lastAutoTeleportZoneId = nil
            mountNotify({
                Title = "UFO",
                Content = "UFO event ended — returned to saved position.",
                Icon = "check",
            })
        else
            s.lastAutoTeleportZoneId = nil
        end
    end

    local function formatVector3(pos: Vector3): string
        return ("%.0f, %.0f, %.0f"):format(pos.X, pos.Y, pos.Z)
    end

    local function buildBody(): string
        tryLoadGameModules()
        local state = fetchUfoState()
        local lines: { string } = {}
        if not state then
            local live = liveUfoPosition()
            if live then
                table.insert(lines, "Phase: (model only)")
                table.insert(lines, "Position: " .. formatVector3(live))
            else
                table.insert(lines, "No UFO state yet.")
                table.insert(lines, "Wait for game modules or an active event.")
            end
            return table.concat(lines, "\n")
        end
        local phase = tostring(state.phase or "?")
        if phase == "idle" then
            table.insert(lines, "Status: Idle")
            if type(state.nextEventStartTime) == "number" then
                table.insert(lines, "Next UFO: " .. formatCountdown(state.nextEventStartTime))
            else
                table.insert(lines, "Next UFO: unknown")
            end
        else
            table.insert(lines, "Status: ACTIVE (" .. phase .. ")")
            activeZone = activeUfoZoneId(state)
            if activeZone then
                table.insert(lines, "Active UFO zone: " .. zoneLabel(activeZone))
            elseif state.zoneId ~= nil then
                table.insert(lines, "Active UFO zone: " .. zoneLabel(state.zoneId))
            else
                table.insert(lines, "Active UFO zone: unknown")
            end
            playerZone = getPlayerZoneId()
            if playerZone then
                table.insert(lines, "Your zone: " .. zoneLabel(playerZone))
            end
            if typeof(state.hoverPosition) == "Vector3" then
                table.insert(lines, "Hover: " .. formatVector3(state.hoverPosition))
            end
            local live = liveUfoPosition()
            if live then
                table.insert(lines, "Model: " .. formatVector3(live))
            end
        end
        if s.autoTeleportEnabled then
            table.insert(lines, "Auto teleport: ON")
            table.insert(lines, "Route: save → zone 1 → zone 2 → zone 3 → return")
            if s.savedReturnCframe then
                table.insert(lines, "Return position: saved")
            end
        end
        return table.concat(lines, "\n")
    end

    local function refreshParagraph()
        if s.paragraph and s.paragraph.Set then
            s.paragraph:Set({ Title = "UFO", Content = buildBody() })
        end
    end

    local function scheduleUfoUiRefresh()
        deferUiOnHeartbeat(refreshParagraph, "ufoParagraph")
    end

    local function scheduleUfoAutoTeleport()
        deferUiOnHeartbeat(processAutoTeleport, "ufoAutoTeleport")
    end

    s.paragraph = mainTab:CreateParagraph({
        Title = "UFO",
        Content = "Loading…",
    })

    mainTab:CreateButton({
        Name = "Teleport to UFO zone",
        Flag = "main_ufo_teleport_zone",
        Callback = function()
            tryLoadGameModules()
            local state = fetchUfoState()
            if not state or not isUfoEventActive(state) then
                mountNotify({
                    Title = "UFO",
                    Content = "No active UFO zone right now.",
                    Icon = "x",
                })
                return
            end
            zoneId = activeUfoZoneId(state)
            if not zoneId then
                mountNotify({
                    Title = "UFO",
                    Content = "No active UFO zone found.",
                    Icon = "x",
                })
                return
            end
            playerZone = getPlayerZoneId()
            if playerZone and playerZone == zoneId then
                mountNotify({
                    Title = "UFO",
                    Content = "Already in " .. zoneLabel(zoneId) .. ".",
                    Icon = "info",
                })
                return
            end
            teleportToZoneId(zoneId, true)
        end,
    })

    mainTab:CreateButton({
        Name = "Teleport to UFO",
        Flag = "main_ufo_teleport_model",
        Callback = function()
            tryLoadGameModules()
            local state = fetchUfoState()
            local target = liveUfoPosition()
            if not target and state and typeof(state.hoverPosition) == "Vector3" then
                target = state.hoverPosition
            end
            if not target then
                mountNotify({
                    Title = "UFO",
                    Content = "UFO is not in the world right now.",
                    Icon = "x",
                })
                return
            end
            local lp = Players.LocalPlayer
            local hrp = lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") :: BasePart?
            if not hrp then
                return
            end
            hrp.CFrame = CFrame.new(target + Vector3.new(0, 6, 0))
            mountNotify({
                Title = "UFO",
                Content = "Teleported under the UFO.",
                Icon = "check",
            })
        end,
    })

    mainTab:CreateToggle({
        Name = "Auto Teleport UFO",
        Flag = "main_ufo_auto_teleport",
        CurrentValue = false,
        Callback = function(enabled)
            s.autoTeleportEnabled = enabled == true
            if not s.autoTeleportEnabled then
                if s.savedReturnCframe then
                    restoreReturnPosition()
                end
                s.lastAutoTeleportZoneId = nil
            end
        end,
    })

    scheduleUfoUiRefresh()
    schedulePeriodicOnHeartbeat(HEARTBEAT_POLL_SEC, function()
        scheduleUfoUiRefresh()
        scheduleUfoAutoTeleport()
    end)
end

local REBIRTH_NETWORKER_VERSION = "leifstout_networker@0.3.1"

local function mountAutoRebirthSection(
    mainTab: any,
    findNetworkerServiceRemotesFolderFn: (string, string?) -> Instance?,
    getDataServiceClientFn: () -> any?
)
    mainTab:CreateSection("Auto Rebirth")

    AutoRebirthSection = {
        paragraph = nil :: any,
        rebirthUtils = nil :: any,
        enabled = false,
        findNetworkerServiceRemotesFolderFn = findNetworkerServiceRemotesFolderFn,
        getDataServiceClientFn = getDataServiceClientFn,
    }

    function AutoRebirthSection.tryLoadRebirthUtils(): boolean
        if AutoRebirthSection.rebirthUtils then
            return true
        end
        src = ReplicatedStorage:FindFirstChild("Source")
        rebirthFolder = src and src:FindFirstChild("Features")
        rebirthFolder = rebirthFolder and rebirthFolder:FindFirstChild("Rebirth")
        mod = rebirthFolder and rebirthFolder:FindFirstChild("RebirthServiceUtils")
        if mod and mod:IsA("ModuleScript") then
            ok, result = pcall(require, mod)
            if ok and type(result) == "table" then
                AutoRebirthSection.rebirthUtils = result
                return true
            end
        end
        return false
    end

    function AutoRebirthSection.getGoopAndRebirths(): (number?, number?)
        client = AutoRebirthSection.getDataServiceClientFn()
        if not client then
            return nil, nil
        end
        return SlimeRngUtil.readDataServiceNumber(client, "goop"), SlimeRngUtil.readDataServiceNumber(client, "rebirths")
    end

    function AutoRebirthSection.rebirthCost(rebirthCount: number): number?
        if not AutoRebirthSection.tryLoadRebirthUtils() or type(AutoRebirthSection.rebirthUtils.getCost) ~= "function" then
            return nil
        end
        ok, cost = pcall(AutoRebirthSection.rebirthUtils.getCost, rebirthCount)
        if ok and type(cost) == "number" then
            return cost
        end
        return nil
    end

    function AutoRebirthSection.hasEnoughGoopForRebirth(): boolean
        if not AutoRebirthSection.tryLoadRebirthUtils() then
            return false
        end
        goop, rebirths = AutoRebirthSection.getGoopAndRebirths()
        if goop == nil or rebirths == nil then
            return false
        end
        if type(AutoRebirthSection.rebirthUtils.canAffordRebirth) == "function" then
            ok, yes = pcall(AutoRebirthSection.rebirthUtils.canAffordRebirth, rebirths, goop)
            return ok and yes == true
        end
        cost = AutoRebirthSection.rebirthCost(rebirths)
        return cost ~= nil and goop >= cost
    end

    function AutoRebirthSection.getRebirthRemote(): RemoteFunction?
        fold = AutoRebirthSection.findNetworkerServiceRemotesFolderFn("RebirthService", REBIRTH_NETWORKER_VERSION)
        rf = fold and fold:FindFirstChild("RemoteFunction")
        if rf and rf:IsA("RemoteFunction") then
            return rf
        end
        return nil
    end

    function AutoRebirthSection.requestRebirth(): (boolean, string?)
        rf = AutoRebirthSection.getRebirthRemote()
        if not rf then
            return false, "RebirthService RemoteFunction not found"
        end
        ok, success, errMsg = pcall(function()
            return (rf :: RemoteFunction):InvokeServer("requestRebirth")
        end)
        if not ok then
            return false, tostring(success)
        end
        if success == true then
            return true, nil
        end
        if type(errMsg) == "string" and errMsg ~= "" then
            return false, errMsg
        end
        return false, "Rebirth failed"
    end

    function AutoRebirthSection.rebirthGoopNeeded(rebirthCount: number): number
        cost = AutoRebirthSection.rebirthCost(rebirthCount)
        if cost then
            return cost
        end
        return 2 ^ math.max(math.floor(rebirthCount), 0) * 500
    end

    function AutoRebirthSection.buildBody(): string
        AutoRebirthSection.tryLoadRebirthUtils()
        goop, rebirths = AutoRebirthSection.getGoopAndRebirths()
        if goop == nil or rebirths == nil then
            return "Waiting for goop / rebirths data (DataService)."
        end
        goopNeeded = AutoRebirthSection.rebirthGoopNeeded(rebirths)
        lines = {
            ("Goop: %s / %s"):format(SlimeRngUtil.formatSuffixNumber(goop), SlimeRngUtil.formatSuffixNumber(goopNeeded)),
            ("Rebirths: %d"):format(math.floor(rebirths)),
            ("Ready: %s"):format(AutoRebirthSection.hasEnoughGoopForRebirth() and "yes" or "no"),
        }
        if AutoRebirthSection.enabled then
            table.insert(lines, "Auto rebirth: ON")
        end
        return table.concat(lines, "\n")
    end

    function AutoRebirthSection.refreshParagraph()
        if AutoRebirthSection.paragraph and AutoRebirthSection.paragraph.Set then
            AutoRebirthSection.paragraph:Set({ Title = "Rebirth", Content = AutoRebirthSection.buildBody() })
        end
    end

    function AutoRebirthSection.tryAutoRebirthPass()
        if not AutoRebirthSection.enabled or not AutoRebirthSection.hasEnoughGoopForRebirth() then
            return
        end
        ok, errMsg = AutoRebirthSection.requestRebirth()
        if ok then
            mountNotify({
                Title = "Auto Rebirth",
                Content = "Rebirth successful.",
                Icon = "check",
            })
        elseif errMsg and errMsg ~= "Not enough goop" then
            mountNotify({
                Title = "Auto Rebirth",
                Content = errMsg,
                Icon = "x",
            })
        end
    end

    AutoRebirthSection.paragraph = mainTab:CreateParagraph({
        Title = "Rebirth",
        Content = "Loading…",
    })

    mainTab:CreateToggle({
        Name = "Auto Rebirth",
        Flag = "main_auto_rebirth",
        CurrentValue = false,
        Callback = function(enabled)
            AutoRebirthSection.enabled = enabled == true
        end,
    })

    deferUiOnHeartbeat(AutoRebirthSection.refreshParagraph)
    schedulePeriodicOnHeartbeat(HEARTBEAT_POLL_SEC, function()
        AutoRebirthSection.refreshParagraph()
        AutoRebirthSection.tryAutoRebirthPass()
    end)
end

local function mountAutoOpenZoneSection(
    mainTab: any,
    findNetworkerServiceRemotesFolderFn: (string, string?) -> Instance?,
    getDataServiceClientFn: () -> any?
)
    mainTab:CreateSection("Auto Open Zone")

    AutoOpenZoneSection = {
        paragraph = nil :: any,
        zonesMod = nil :: any,
        enabled = false,
        findNetworkerServiceRemotesFolderFn = findNetworkerServiceRemotesFolderFn,
        getDataServiceClientFn = getDataServiceClientFn,
    }

    function AutoOpenZoneSection.tryLoadZonesMod(): boolean
        if AutoOpenZoneSection.zonesMod then
            return true
        end
        src = ReplicatedStorage:FindFirstChild("Source")
        gameFolder = src and src:FindFirstChild("Game")
        zonesItems = gameFolder and gameFolder:FindFirstChild("Items")
        zonesItems = zonesItems and zonesItems:FindFirstChild("Zones")
        if zonesItems and zonesItems:IsA("ModuleScript") then
            ok, result = pcall(require, zonesItems)
            if ok and type(result) == "table" and type(result.getZone) == "function" then
                AutoOpenZoneSection.zonesMod = result
                return true
            end
        end
        return false
    end

    function AutoOpenZoneSection.getCoinsAndMaxZone(): (number?, number?)
        client = AutoOpenZoneSection.getDataServiceClientFn()
        if not client then
            return nil, nil
        end
        coins = SlimeRngUtil.readDataServiceNumber(client, "coins")
        maxZone = SlimeRngUtil.readDataServiceNumber(client, "maxZone")
        if maxZone then
            maxZone = math.max(math.floor(maxZone), 1)
        end
        return coins, maxZone
    end

    function AutoOpenZoneSection.zoneHasId(zoneId: number): boolean
        if not AutoOpenZoneSection.tryLoadZonesMod() then
            return false
        end
        return SlimeRngUtil.zonesModuleHasZone(AutoOpenZoneSection.zonesMod, zoneId)
    end

    function AutoOpenZoneSection.zoneDef(zoneId: number): any?
        if not AutoOpenZoneSection.tryLoadZonesMod() then
            return nil
        end
        return SlimeRngUtil.zonesModuleGetZone(AutoOpenZoneSection.zonesMod, zoneId)
    end

    function AutoOpenZoneSection.zoneLabel(zoneId: number): string
        def = AutoOpenZoneSection.zoneDef(zoneId)
        name = type(def) == "table" and type(def.name) == "string" and def.name or "?"
        return ("%d (%s)"):format(zoneId, name)
    end

    function AutoOpenZoneSection.nextZoneId(maxZone: number): number?
        id = math.floor(maxZone) + 1
        if AutoOpenZoneSection.zoneHasId(id) then
            return id
        end
        return nil
    end

    function AutoOpenZoneSection.nextZonePrice(nextId: number): number?
        def = AutoOpenZoneSection.zoneDef(nextId)
        if type(def) == "table" and type(def.price) == "number" then
            return def.price
        end
        return nil
    end

    function AutoOpenZoneSection.hasEnoughCoinsForNextZone(): boolean
        coins, maxZone = AutoOpenZoneSection.getCoinsAndMaxZone()
        if coins == nil or maxZone == nil then
            return false
        end
        nextId = AutoOpenZoneSection.nextZoneId(maxZone)
        if not nextId then
            return false
        end
        price = AutoOpenZoneSection.nextZonePrice(nextId)
        if price == nil then
            return false
        end
        return coins >= price
    end

    function AutoOpenZoneSection.getZonesRemote(): RemoteFunction?
        fold = AutoOpenZoneSection.findNetworkerServiceRemotesFolderFn("ZonesService", REBIRTH_NETWORKER_VERSION)
        rf = fold and fold:FindFirstChild("RemoteFunction")
        if rf and rf:IsA("RemoteFunction") then
            return rf
        end
        return nil
    end

    function AutoOpenZoneSection.requestPurchaseZone(): (boolean, string?)
        rf = AutoOpenZoneSection.getZonesRemote()
        if not rf then
            return false, "ZonesService RemoteFunction not found"
        end
        ok, success, errMsg = pcall(function()
            return (rf :: RemoteFunction):InvokeServer("requestPurchaseZone")
        end)
        if not ok then
            return false, tostring(success)
        end
        if success == true then
            return true, nil
        end
        if type(errMsg) == "string" and errMsg ~= "" then
            return false, errMsg
        end
        return false, "Failed to purchase zone"
    end

    function AutoOpenZoneSection.requestTeleportZone(zoneId: number): boolean
        rf = AutoOpenZoneSection.getZonesRemote()
        if not rf then
            return false
        end
        ok, success = pcall(function()
            return (rf :: RemoteFunction):InvokeServer("requestTeleportZone", zoneId)
        end)
        return ok and success == true
    end

    function AutoOpenZoneSection.findZoneHitbox(zoneId: number): BasePart?
        zones = Workspace:FindFirstChild("Zones")
        zoneFolder = zones and zones:FindFirstChild(tostring(zoneId))
        poi = zoneFolder and zoneFolder:FindFirstChild("POI")
        hitbox = poi and poi:FindFirstChild("Hitbox")
        if hitbox and hitbox:IsA("BasePart") then
            return hitbox
        end
        return nil
    end

    function AutoOpenZoneSection.teleportToZoneId(zoneId: number): boolean
        if AutoOpenZoneSection.requestTeleportZone(zoneId) then
            return true
        end
        hitbox = AutoOpenZoneSection.findZoneHitbox(zoneId)
        lp = Players.LocalPlayer
        hrp = lp and lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hitbox and hrp and hrp:IsA("BasePart") then
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.CFrame = CFrame.new(hitbox.Position + Vector3.new(0, 5, 0))
            return true
        end
        return false
    end

    function AutoOpenZoneSection.teleportToHighestZone(): boolean
        _, maxZone = AutoOpenZoneSection.getCoinsAndMaxZone()
        if not maxZone then
            return false
        end
        return AutoOpenZoneSection.teleportToZoneId(math.floor(maxZone))
    end

    function AutoOpenZoneSection.buildBody(): string
        AutoOpenZoneSection.tryLoadZonesMod()
        coins, maxZone = AutoOpenZoneSection.getCoinsAndMaxZone()
        if coins == nil or maxZone == nil then
            return "Waiting for coin / zone data (DataService)."
        end
        if not AutoOpenZoneSection.tryLoadZonesMod() then
            return "Waiting for zone definitions (Source.Game.Items.Zones)."
        end
        currentHighest = AutoOpenZoneSection.zoneLabel(maxZone)
        nextId = AutoOpenZoneSection.nextZoneId(maxZone)
        lines = {}
        if not nextId then
            table.insert(lines, ("Coin: %s / MAXED"):format(SlimeRngUtil.formatSuffixNumber(coins)))
            table.insert(lines, "Current Highest Zone: " .. currentHighest)
            table.insert(lines, "Next Zone: MAXED")
            table.insert(lines, "Ready: no")
        else
            price = AutoOpenZoneSection.nextZonePrice(nextId) or 0
            table.insert(lines, ("Coin: %s / %s"):format(
                SlimeRngUtil.formatSuffixNumber(coins),
                SlimeRngUtil.formatSuffixNumber(price)
            ))
            table.insert(lines, "Current Highest Zone: " .. currentHighest)
            table.insert(lines, "Next Zone: " .. AutoOpenZoneSection.zoneLabel(nextId))
            table.insert(lines, ("Ready: %s"):format(AutoOpenZoneSection.hasEnoughCoinsForNextZone() and "yes" or "no"))
        end
        if AutoOpenZoneSection.enabled then
            table.insert(lines, "Auto open zone: ON")
        end
        return table.concat(lines, "\n")
    end

    function AutoOpenZoneSection.refreshParagraph()
        if AutoOpenZoneSection.paragraph and AutoOpenZoneSection.paragraph.Set then
            AutoOpenZoneSection.paragraph:Set({ Title = "Zone", Content = AutoOpenZoneSection.buildBody() })
        end
    end

    function AutoOpenZoneSection.tryAutoOpenZonePass()
        if not AutoOpenZoneSection.enabled or not AutoOpenZoneSection.hasEnoughCoinsForNextZone() then
            return
        end
        _, maxZone = AutoOpenZoneSection.getCoinsAndMaxZone()
        purchasedZoneId = maxZone and AutoOpenZoneSection.nextZoneId(maxZone)
        ok, errMsg = AutoOpenZoneSection.requestPurchaseZone()
        if ok then
            teleported = false
            if purchasedZoneId then
                teleported = AutoOpenZoneSection.teleportToZoneId(purchasedZoneId)
            end
            if not teleported then
                teleported = AutoOpenZoneSection.teleportToHighestZone()
            end
            notifyContent = "Zone unlocked."
            if purchasedZoneId then
                notifyContent = notifyContent .. " Teleported to " .. AutoOpenZoneSection.zoneLabel(purchasedZoneId) .. "."
            elseif teleported then
                notifyContent = notifyContent .. " Teleported to highest zone."
            end
            mountNotify({
                Title = "Auto Open Zone",
                Content = notifyContent,
                Icon = "check",
            })
        elseif errMsg and errMsg ~= "Not enough coins" then
            mountNotify({
                Title = "Auto Open Zone",
                Content = errMsg,
                Icon = "x",
            })
        end
    end

    AutoOpenZoneSection.paragraph = mainTab:CreateParagraph({
        Title = "Zone",
        Content = "Loading…",
    })

    mainTab:CreateToggle({
        Name = "Auto Open Zone",
        Flag = "main_auto_open_zone",
        CurrentValue = false,
        Callback = function(enabled)
            AutoOpenZoneSection.enabled = enabled == true
        end,
    })

    deferUiOnHeartbeat(AutoOpenZoneSection.refreshParagraph)
    schedulePeriodicOnHeartbeat(HEARTBEAT_POLL_SEC, function()
        AutoOpenZoneSection.refreshParagraph()
        AutoOpenZoneSection.tryAutoOpenZonePass()
    end)
end

local function mountAutoUpgradesSection(
    mainTab: any,
    findNetworkerServiceRemotesFolderFn: (string, string?) -> Instance?,
    getDataServiceClientFn: () -> any?
)
    mainTab:CreateSection("Auto Upgrades")

    AutoUpgradesSection = {
        paragraph = nil :: any,
        upgradeTreeMod = nil :: any,
        upgradeCounterUtils = nil :: any,
        upgradeServiceUtils = nil :: any,
        enabled = false,
        findNetworkerServiceRemotesFolderFn = findNetworkerServiceRemotesFolderFn,
        getDataServiceClientFn = getDataServiceClientFn,
    }

    function AutoUpgradesSection.tryLoadUpgradeModules(): boolean
        if AutoUpgradesSection.upgradeTreeMod
            and AutoUpgradesSection.upgradeCounterUtils
            and AutoUpgradesSection.upgradeServiceUtils then
            return true
        end
        src = ReplicatedStorage:FindFirstChild("Source")
        upgradesFolder = src and src:FindFirstChild("Features")
        upgradesFolder = upgradesFolder and upgradesFolder:FindFirstChild("Upgrades")
        treeMod = upgradesFolder and upgradesFolder:FindFirstChild("UpgradeTree")
        counterMod = upgradesFolder and upgradesFolder:FindFirstChild("UpgradeCounterUtils")
        utilsMod = upgradesFolder and upgradesFolder:FindFirstChild("UpgradeServiceUtils")
        if treeMod and treeMod:IsA("ModuleScript") then
            ok, result = pcall(require, treeMod)
            if ok and type(result) == "table" then
                AutoUpgradesSection.upgradeTreeMod = result
            end
        end
        if counterMod and counterMod:IsA("ModuleScript") then
            ok, result = pcall(require, counterMod)
            if ok and type(result) == "table" then
                AutoUpgradesSection.upgradeCounterUtils = result
            end
        end
        if utilsMod and utilsMod:IsA("ModuleScript") then
            ok, result = pcall(require, utilsMod)
            if ok and type(result) == "table" then
                AutoUpgradesSection.upgradeServiceUtils = result
            end
        end
        return AutoUpgradesSection.upgradeTreeMod ~= nil
            and AutoUpgradesSection.upgradeCounterUtils ~= nil
            and AutoUpgradesSection.upgradeServiceUtils ~= nil
    end

    function AutoUpgradesSection.getUpgradesSave(): { [string]: any }
        client = AutoUpgradesSection.getDataServiceClientFn()
        if not client then
            return {}
        end
        ok, data = pcall(function()
            return client:get("upgrades")
        end)
        if ok and type(data) == "table" then
            return data
        end
        return {}
    end

    function AutoUpgradesSection.getCurrencyAmount(currencyPath: string): number
        client = AutoUpgradesSection.getDataServiceClientFn()
        if not client then
            return 0
        end
        amount = SlimeRngUtil.readDataServiceNumber(client, currencyPath)
        if amount then
            return amount
        end
        return 0
    end

    function AutoUpgradesSection.canPurchaseUpgrade(upgradeDef: any, upgradesSave: { [string]: any }): boolean
        counter = AutoUpgradesSection.upgradeCounterUtils
        if not counter or type(counter.canPurchase) ~= "function" then
            return false
        end
        ok, yes = pcall(counter.canPurchase, upgradeDef, upgradesSave, function(currencyPath: string): number
            return AutoUpgradesSection.getCurrencyAmount(currencyPath)
        end)
        return ok and yes == true
    end

    function AutoUpgradesSection.collectPurchasableUpgrades(): { any }
        if not AutoUpgradesSection.tryLoadUpgradeModules() then
            return {}
        end
        tree = AutoUpgradesSection.upgradeTreeMod
        upgradesSave = AutoUpgradesSection.getUpgradesSave()
        purchasable = {}
        for _, treeDef in tree do
            if type(treeDef) == "table" then
                for upgradeId, upgradeDef in treeDef do
                    if type(upgradeDef) == "table" and type(upgradeDef.cost) == "table" then
                        if type(upgradeDef.id) ~= "string" then
                            upgradeDef.id = upgradeId
                        end
                        if AutoUpgradesSection.canPurchaseUpgrade(upgradeDef, upgradesSave) then
                            table.insert(purchasable, upgradeDef)
                        end
                    end
                end
            end
        end
        table.sort(purchasable, function(a, b)
            costA = type(a.cost) == "table" and tonumber(a.cost.amount) or math.huge
            costB = type(b.cost) == "table" and tonumber(b.cost.amount) or math.huge
            if costA ~= costB then
                return costA < costB
            end
            return tostring(a.id or "") < tostring(b.id or "")
        end)
        return purchasable
    end

    function AutoUpgradesSection.cheapestPurchasableUpgrade(): any?
        purchasable = AutoUpgradesSection.collectPurchasableUpgrades()
        return purchasable[1]
    end

    function AutoUpgradesSection.upgradeLabel(upgradeDef: any): string
        if type(upgradeDef) ~= "table" then
            return "?"
        end
        name = type(upgradeDef.name) == "string" and upgradeDef.name or tostring(upgradeDef.id or "?")
        cost = upgradeDef.cost
        if type(cost) == "table" then
            currency = tostring(cost.currency or "?")
            amount = tonumber(cost.amount) or 0
            return ('%s (%s %s)'):format(name, SlimeRngUtil.formatSuffixNumber(amount), currency)
        end
        return name
    end

    function AutoUpgradesSection.getUpgradeRemote(): RemoteFunction?
        fold = AutoUpgradesSection.findNetworkerServiceRemotesFolderFn("UpgradeService", REBIRTH_NETWORKER_VERSION)
        rf = fold and fold:FindFirstChild("RemoteFunction")
        if rf and rf:IsA("RemoteFunction") then
            return rf
        end
        return nil
    end

    function AutoUpgradesSection.requestUnlockUpgrade(upgradeId: string): (boolean, string?)
        rf = AutoUpgradesSection.getUpgradeRemote()
        if not rf then
            return false, "UpgradeService RemoteFunction not found"
        end
        ok, success, errMsg = pcall(function()
            return (rf :: RemoteFunction):InvokeServer("requestUnlock", upgradeId)
        end)
        if not ok then
            return false, tostring(success)
        end
        if success == true then
            return true, nil
        end
        if type(errMsg) == "string" and errMsg ~= "" then
            return false, errMsg
        end
        return false, "Failed to unlock upgrade"
    end

    function AutoUpgradesSection.buildBody(): string
        if not AutoUpgradesSection.tryLoadUpgradeModules() then
            return "Waiting for upgrade modules (UpgradeTree / UpgradeCounterUtils)."
        end
        purchasable = AutoUpgradesSection.collectPurchasableUpgrades()
        nextUpgrade = purchasable[1]
        lines = {
            ("Purchasable upgrades: %d"):format(#purchasable),
        }
        if nextUpgrade then
            cost = nextUpgrade.cost
            currency = type(cost) == "table" and tostring(cost.currency or "coins") or "coins"
            price = type(cost) == "table" and tonumber(cost.amount) or 0
            balance = AutoUpgradesSection.getCurrencyAmount(currency)
            table.insert(lines, ("Next (lowest): %s"):format(AutoUpgradesSection.upgradeLabel(nextUpgrade)))
            table.insert(lines, ("Balance: %s / %s (%s)"):format(
                SlimeRngUtil.formatSuffixNumber(balance),
                SlimeRngUtil.formatSuffixNumber(price),
                currency
            ))
            table.insert(lines, ("Ready: %s"):format(balance >= price and "yes" or "no"))
        else
            table.insert(lines, "Next (lowest): none")
            table.insert(lines, "Ready: no")
        end
        if AutoUpgradesSection.enabled then
            table.insert(lines, "Auto upgrades: ON")
        end
        return table.concat(lines, "\n")
    end

    function AutoUpgradesSection.refreshParagraph()
        if AutoUpgradesSection.paragraph and AutoUpgradesSection.paragraph.Set then
            AutoUpgradesSection.paragraph:Set({ Title = "Upgrades", Content = AutoUpgradesSection.buildBody() })
        end
    end

    function AutoUpgradesSection.tryAutoUpgradesPass()
        if not AutoUpgradesSection.enabled then
            return
        end
        nextUpgrade = AutoUpgradesSection.cheapestPurchasableUpgrade()
        if not nextUpgrade or type(nextUpgrade.id) ~= "string" then
            return
        end
        ok, errMsg = AutoUpgradesSection.requestUnlockUpgrade(nextUpgrade.id)
        if ok then
            mountNotify({
                Title = "Auto Upgrades",
                Content = "Unlocked " .. AutoUpgradesSection.upgradeLabel(nextUpgrade) .. ".",
                Icon = "check",
            })
        elseif errMsg and errMsg ~= "Not enough currency" then
            mountNotify({
                Title = "Auto Upgrades",
                Content = errMsg,
                Icon = "x",
            })
        end
    end

    AutoUpgradesSection.paragraph = mainTab:CreateParagraph({
        Title = "Upgrades",
        Content = "Loading…",
    })

    mainTab:CreateToggle({
        Name = "Auto Upgrades",
        Flag = "main_auto_upgrades",
        CurrentValue = false,
        Callback = function(enabled)
            AutoUpgradesSection.enabled = enabled == true
        end,
    })

    deferUiOnHeartbeat(AutoUpgradesSection.refreshParagraph)
    schedulePeriodicOnHeartbeat(HEARTBEAT_POLL_SEC, function()
        AutoUpgradesSection.refreshParagraph()
        AutoUpgradesSection.tryAutoUpgradesPass()
    end)
end

local function mountMachineUnlockerSection(
    mainTab: any,
    findNetworkerServiceRemotesFolderFn: (string, string?) -> Instance?,
    getDataServiceClientFn: () -> any?
)
    mainTab:CreateSection("Machine Unlocker")

    MachineUnlockerSection = {
        dropdown = nil :: any,
        paragraph = nil :: any,
        machines = {} :: { any },
        optionToId = {} :: { [string]: string },
        selectedId = nil :: string?,
        findNetworkerServiceRemotesFolderFn = findNetworkerServiceRemotesFolderFn,
        getDataServiceClientFn = getDataServiceClientFn,
    }

    function MachineUnlockerSection.tryLoadMachineCatalog(): boolean
        if #MachineUnlockerSection.machines > 0 then
            return true
        end
        MachineUnlockerSection.machines = {
            {
                id = "crafting",
                label = "Crafting Machine",
                service = "CraftingService",
                unlockKey = "craftingMachine",
                price = 1000000,
                currency = "coins",
                utilsMods = { "Crafting", "CraftingServiceUtils" },
                priceField = "CRAFTING_MACHINE_UNLOCK_PRICE",
                keyField = "CRAFTING_MACHINE_UNLOCK_KEY",
            },
            {
                id = "xpTransfer",
                label = "XP Transfer Machine",
                service = "XpTransferService",
                unlockKey = "xpTransferMachine",
                price = 1000000,
                currency = "coins",
                utilsMods = { "XpTransfer", "XpTransferServiceUtils" },
                priceField = "XP_TRANSFER_MACHINE_UNLOCK_PRICE",
                keyField = "XP_TRANSFER_MACHINE_UNLOCK_KEY",
            },
            {
                id = "fruitExtractor",
                label = "Fruit Extractor Machine",
                service = "FruitExtractorService",
                unlockKey = "fruitExtractor",
                price = 2000000,
                currency = "coins",
                utilsMods = { "FruitExtractor", "FruitExtractorServiceUtils" },
                priceField = "FRUIT_EXTRACTOR_UNLOCK_PRICE",
                keyField = "FRUIT_EXTRACTOR_UNLOCK_KEY",
            },
        }
        src = ReplicatedStorage:FindFirstChild("Source")
        features = src and src:FindFirstChild("Features")
        if not features then
            return true
        end
        for _, def in ipairs(MachineUnlockerSection.machines) do
            folder = features:FindFirstChild(def.utilsMods[1])
            mod = folder and folder:FindFirstChild(def.utilsMods[2])
            if mod and mod:IsA("ModuleScript") then
                ok, utils = pcall(require, mod)
                if ok and type(utils) == "table" then
                    price = utils[def.priceField]
                    key = utils[def.keyField]
                    if type(price) == "number" then
                        def.price = price
                    end
                    if type(key) == "string" and key ~= "" then
                        def.unlockKey = key
                    end
                end
            end
        end
        return true
    end

    function MachineUnlockerSection.getUpgradesSave(): { [string]: any }
        client = MachineUnlockerSection.getDataServiceClientFn()
        if not client then
            return {}
        end
        ok, data = pcall(function()
            return client:get("upgrades")
        end)
        if ok and type(data) == "table" then
            return data
        end
        return {}
    end

    function MachineUnlockerSection.getMachineDef(machineId: string?): any?
        if not machineId then
            return nil
        end
        for _, def in ipairs(MachineUnlockerSection.machines) do
            if def.id == machineId then
                return def
            end
        end
        return nil
    end

    function MachineUnlockerSection.isMachineUnlocked(def: any): boolean
        if type(def) ~= "table" then
            return false
        end
        upgrades = MachineUnlockerSection.getUpgradesSave()
        return upgrades[def.unlockKey] == true
    end

    function MachineUnlockerSection.getCoinBalance(): number?
        client = MachineUnlockerSection.getDataServiceClientFn()
        if not client then
            return nil
        end
        return SlimeRngUtil.readDataServiceNumber(client, "coins")
    end

    function MachineUnlockerSection.dropdownOptionLabel(def: any): string
        if type(def) ~= "table" then
            return "?"
        end
        priceText = SlimeRngUtil.formatSuffixNumber(def.price or 0)
        currency = tostring(def.currency or "coins")
        owned = MachineUnlockerSection.isMachineUnlocked(def) and " [OWNED]" or ""
        return ('%s — %s %s%s'):format(def.label, priceText, currency, owned)
    end

    function MachineUnlockerSection.buildDropdownOptions(): { string }
        MachineUnlockerSection.tryLoadMachineCatalog()
        options = {}
        MachineUnlockerSection.optionToId = {}
        for _, def in ipairs(MachineUnlockerSection.machines) do
            opt = MachineUnlockerSection.dropdownOptionLabel(def)
            table.insert(options, opt)
            MachineUnlockerSection.optionToId[opt] = def.id
        end
        table.sort(options)
        return options
    end

    function MachineUnlockerSection.selectedMachineDef(): any?
        return MachineUnlockerSection.getMachineDef(MachineUnlockerSection.selectedId)
    end

    function MachineUnlockerSection.syncSelectionFromDropdown(value: any)
        picked = rayfieldDropdownFirst(value)
        if type(picked) == "string" then
            MachineUnlockerSection.selectedId = MachineUnlockerSection.optionToId[picked]
        else
            MachineUnlockerSection.selectedId = nil
        end
    end

    function MachineUnlockerSection.buildBody(): string
        MachineUnlockerSection.tryLoadMachineCatalog()
        def = MachineUnlockerSection.selectedMachineDef()
        if not def then
            return "Select a machine from the dropdown."
        end
        coins = MachineUnlockerSection.getCoinBalance()
        price = tonumber(def.price) or 0
        lines = {
            "Machine: " .. def.label,
            ("Price: %s %s"):format(SlimeRngUtil.formatSuffixNumber(price), tostring(def.currency or "coins")),
            ("Status: %s"):format(MachineUnlockerSection.isMachineUnlocked(def) and "Unlocked" or "Locked"),
        }
        if coins ~= nil then
            table.insert(lines, ("Coins: %s / %s"):format(
                SlimeRngUtil.formatSuffixNumber(coins),
                SlimeRngUtil.formatSuffixNumber(price)
            ))
            if not MachineUnlockerSection.isMachineUnlocked(def) then
                table.insert(lines, ("Ready: %s"):format(coins >= price and "yes" or "no"))
            end
        else
            table.insert(lines, "Coins: waiting for DataService")
        end
        return table.concat(lines, "\n")
    end

    function MachineUnlockerSection.refreshParagraph()
        if MachineUnlockerSection.paragraph and MachineUnlockerSection.paragraph.Set then
            MachineUnlockerSection.paragraph:Set({
                Title = "Machine",
                Content = MachineUnlockerSection.buildBody(),
            })
        end
    end

    function MachineUnlockerSection.refreshDropdown()
        options = MachineUnlockerSection.buildDropdownOptions()
        if not MachineUnlockerSection.dropdown then
            return
        end
        current = nil
        if MachineUnlockerSection.selectedId then
            for opt, id in pairs(MachineUnlockerSection.optionToId) do
                if id == MachineUnlockerSection.selectedId then
                    current = opt
                    break
                end
            end
        end
        if not current and #options > 0 then
            current = options[1]
            MachineUnlockerSection.selectedId = MachineUnlockerSection.optionToId[current]
        end
        if MachineUnlockerSection.dropdown.Set then
            pcall(function()
                MachineUnlockerSection.dropdown:Set({
                    Options = options,
                    CurrentOption = if current then { current } else {},
                })
            end)
        end
    end

    function MachineUnlockerSection.scheduleRefresh()
        deferUiOnHeartbeat(function()
            MachineUnlockerSection.refreshDropdown()
            MachineUnlockerSection.refreshParagraph()
        end, "machineUnlockerRefresh")
    end

    function MachineUnlockerSection.getServiceRemote(serviceName: string): RemoteFunction?
        fold = MachineUnlockerSection.findNetworkerServiceRemotesFolderFn(serviceName, REBIRTH_NETWORKER_VERSION)
        rf = fold and fold:FindFirstChild("RemoteFunction")
        if rf and rf:IsA("RemoteFunction") then
            return rf
        end
        return nil
    end

    function MachineUnlockerSection.requestUnlockMachine(def: any): (boolean, string?)
        if type(def) ~= "table" or type(def.service) ~= "string" then
            return false, "Invalid machine"
        end
        if MachineUnlockerSection.isMachineUnlocked(def) then
            return false, "Already unlocked"
        end
        rf = MachineUnlockerSection.getServiceRemote(def.service)
        if not rf then
            return false, def.service .. " RemoteFunction not found"
        end
        ok, success, errMsg = pcall(function()
            return (rf :: RemoteFunction):InvokeServer("requestUnlockMachine")
        end)
        if not ok then
            return false, tostring(success)
        end
        if success == true then
            return true, nil
        end
        if type(errMsg) == "string" and errMsg ~= "" then
            return false, errMsg
        end
        return false, "Failed to unlock machine"
    end

    function MachineUnlockerSection.unlockSelectedMachine()
        def = MachineUnlockerSection.selectedMachineDef()
        if not def then
            mountNotify({
                Title = "Machine Unlocker",
                Content = "Select a machine first.",
                Icon = "x",
            })
            return
        end
        if MachineUnlockerSection.isMachineUnlocked(def) then
            mountNotify({
                Title = "Machine Unlocker",
                Content = def.label .. " is already unlocked.",
            })
            return
        end
        ok, errMsg = MachineUnlockerSection.requestUnlockMachine(def)
        if ok then
            mountNotify({
                Title = "Machine Unlocker",
                Content = "Unlocked " .. def.label .. ".",
                Icon = "check",
            })
            MachineUnlockerSection.scheduleRefresh()
        else
            mountNotify({
                Title = "Machine Unlocker",
                Content = errMsg or "Unlock failed.",
                Icon = "x",
            })
        end
    end

    MachineUnlockerSection.paragraph = mainTab:CreateParagraph({
        Title = "Machine",
        Content = "Loading…",
    })

    initialOptions = MachineUnlockerSection.buildDropdownOptions()
    if #initialOptions > 0 then
        MachineUnlockerSection.selectedId = MachineUnlockerSection.optionToId[initialOptions[1]]
    end

    MachineUnlockerSection.dropdown = mainTab:CreateDropdown({
        Name = "Machine",
        Flag = "main_machine_unlocker_dropdown",
        Options = initialOptions,
        CurrentOption = if #initialOptions > 0 then { initialOptions[1] } else {},
        Search = true,
        Callback = function(value)
            MachineUnlockerSection.syncSelectionFromDropdown(value)
            MachineUnlockerSection.scheduleRefresh()
        end,
    })

    mainTab:CreateButton({
        Name = "Unlock Machine",
        Flag = "main_machine_unlock_button",
        Callback = function()
            MachineUnlockerSection.unlockSelectedMachine()
        end,
    })

    MachineUnlockerSection.scheduleRefresh()
    schedulePeriodicOnHeartbeat(HEARTBEAT_POLL_SEC, MachineUnlockerSection.scheduleRefresh)
end

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", 4483362458)

    MainTab:CreateSection("Auto Collect Loot")

    function mainTryProximityInteractOnInstance(root: Instance)
        prompt = root:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not prompt then
            return
        end
        usedFire = false
        pcall(function()
            fp = rawget(_G, "fireproximityprompt")
            if type(fp) ~= "function" then
                ge = rawget(_G, "getgenv")
                if type(ge) == "function" then
                    g = ge()
                    if type(g) == "table" then
                        fp = rawget(g, "fireproximityprompt")
                    end
                end
            end
            if type(fp) == "function" then
                fp(prompt)
                usedFire = true
            end
        end)
        if usedFire then
            task.wait(0.35)
            return
        end
        pcall(function()
            prompt:InputHoldBegin()
        end)
        local hold = 0.2
        pcall(function()
            hold = math.clamp((prompt :: ProximityPrompt).HoldDuration + 0.08, 0.15, 3)
        end)
        task.wait(hold)
        pcall(function()
            prompt:InputHoldEnd()
        end)
    end

    autoCollectLootEnabled = false
    autoCollectLootLoopToken = 0
    type LootQueueEntry = { uid: string, label: string }
    local lootProcessQueue: { LootQueueEntry } = {}
    local lootChildAddedConn: RBXScriptConnection? = nil
    local lootFolderChildAddedConn: RBXScriptConnection? = nil
    local lootFolderDescendantAddedConn: RBXScriptConnection? = nil
    local lootFolderDestroyingConn: RBXScriptConnection? = nil
    local lastBoundLootFolder: Folder? = nil
    local lootServiceEventConn: RBXScriptConnection? = nil
    local lootPendingAck: { [string]: boolean } = {}
    local collectedLootLines: { string } = {}
    COLLECTED_LOOT_MAX_LINES = 50
    -- `Packages._Index` leifstout_networker versions (newest first for generic remotes).
    LEIFSTOUT_NETWORKER_VERSIONS = {
        "leifstout_networker@0.3.1",
        "leifstout_networker@0.2.1",
    }
    -- RollService `requestSetSpecialRollPaused` must use this package version.
    LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION = "leifstout_networker@0.3.1"

    LootCollectedParagraph = MainTab:CreateParagraph({
        Title = "Collected loot",
        Content = "None",
    })

    function getNetworkerRemotesRoot(indexFolderName: string): Instance?
        packages = ReplicatedStorage:FindFirstChild("Packages")
        if not packages then
            return nil
        end
        idx = packages:FindFirstChild("_Index")
        if not idx then
            return nil
        end
        pkg = idx:FindFirstChild(indexFolderName)
        if not pkg then
            return nil
        end
        net = pkg:FindFirstChild("networker")
        if not net then
            return nil
        end
        rem = net:FindFirstChild("_remotes")
        if not rem then
            return nil
        end
        return rem
    end

    function findNetworkerServiceRemotesFolder(serviceFolderName: string, indexFolderName: string?): Instance?
        local versions: { string }
        if indexFolderName then
            versions = { indexFolderName }
        else
            versions = LEIFSTOUT_NETWORKER_VERSIONS
        end
        for _, folderName in ipairs(versions) do
            rem = getNetworkerRemotesRoot(folderName)
            if rem then
                local svc = rem:FindFirstChild(serviceFolderName)
                if svc then
                    return svc
                end
            end
        end
        return nil
    end

    function findNetworkerRemoteInService(
        serviceFolderName: string,
        remoteChildName: string,
        remoteClass: string,
        indexFolderName: string?
    ): Instance?
        local svc = findNetworkerServiceRemotesFolder(serviceFolderName, indexFolderName)
        if not svc then
            return nil
        end
        local remote = svc:FindFirstChild(remoteChildName)
        if remote and remote:IsA(remoteClass) then
            return remote
        end
        return nil
    end

    local function resolveNetworkerRemoteFunction(
        serviceFolderName: string,
        indexFolderName: string?
    ): RemoteFunction?
        local rf = findNetworkerRemoteInService(serviceFolderName, "RemoteFunction", "RemoteFunction", indexFolderName)
        if rf and rf:IsA("RemoteFunction") then
            return rf
        end
        return nil
    end

    local function resolveNetworkerRemoteEvent(
        serviceFolderName: string,
        indexFolderName: string?
    ): RemoteEvent?
        local ev = findNetworkerRemoteInService(serviceFolderName, "RemoteEvent", "RemoteEvent", indexFolderName)
        if ev and ev:IsA("RemoteEvent") then
            return ev
        end
        return nil
    end

    local function findLootServiceRemotesFolder(): Instance?
        return findNetworkerServiceRemotesFolder("LootService")
    end

    local function disconnectLootRemoteListener()
        if lootServiceEventConn then
            lootServiceEventConn:Disconnect()
            lootServiceEventConn = nil
        end
        table.clear(lootPendingAck)
    end

    local function ensureLootRemoteListener(): boolean
        if lootServiceEventConn then
            return true
        end
        local fold = findLootServiceRemotesFolder()
        if not fold then
            return false
        end
        local ev = fold:FindFirstChild("RemoteEvent")
        if not ev or not ev:IsA("RemoteEvent") then
            return false
        end
        lootServiceEventConn = ev.OnClientEvent:Connect(function(a1, a2)
            if a1 == "lootRemoved" and type(a2) == "string" then
                lootPendingAck[a2] = true
            end
        end)
        return true
    end

    local function looksLikeLootUid(s: string): boolean
        if #s ~= 36 then
            return false
        end
        return string.match(s, "^%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x$") ~= nil
    end

    local function lootUidFromInstance(child: Instance): string?
        if looksLikeLootUid(child.Name) then
            return child.Name
        end
        for _, attrName in ipairs({ "Uid", "uid", "UID", "Id", "id" }) do
            local v = child:GetAttribute(attrName)
            if type(v) == "string" and looksLikeLootUid(v) then
                return v
            end
        end
        for _, childName in ipairs({ "Uid", "uid", "UID", "Id" }) do
            local sv = child:FindFirstChild(childName)
            if sv and sv:IsA("StringValue") and looksLikeLootUid(sv.Value) then
                return sv.Value
            end
        end
        -- Some UIs only store the id on arbitrary StringValues / custom attributes (not named "Uid").
        local okAttrs, attrs = pcall(function()
            return (child :: any).GetAttributes and (child :: any):GetAttributes()
        end)
        if okAttrs and type(attrs) == "table" then
            for _, v in pairs(attrs) do
                if type(v) == "string" and looksLikeLootUid(v) then
                    return v
                end
            end
        end
        if child:IsA("StringValue") and looksLikeLootUid(child.Value) then
            return child.Value
        end
        return nil
    end

    local function lootGetBillboardTextLabel(lootTop: Instance): TextLabel?
        for _, inst in ipairs(lootTop:GetDescendants()) do
            if inst.Name == "Root" then
                local bb = inst:FindFirstChild("LootBillboard")
                if bb then
                    local tl = bb:FindFirstChild("TextLabel")
                    if tl and tl:IsA("TextLabel") then
                        return tl
                    end
                    local any = bb:FindFirstChildWhichIsA("TextLabel", false)
                    if any then
                        return any
                    end
                end
            end
        end
        return nil
    end

    local function lootDisplayName(lootTop: Instance): string
        local tl = lootGetBillboardTextLabel(lootTop)
        if tl then
            local ok, txt = pcall(function()
                return tl.Text
            end)
            if ok and type(txt) == "string" and txt ~= "" then
                txt = string.gsub(txt, "\r\n", " ")
                txt = string.gsub(txt, "\n", " ")
                if #txt > 80 then
                    txt = string.sub(txt, 1, 80) .. "..."
                end
                return txt
            end
        end
        return lootTop.Name
    end

    local function lootEnqueueEntry(uid: string, label: string)
        for _, e in ipairs(lootProcessQueue) do
            if e.uid == uid then
                return
            end
        end
        table.insert(lootProcessQueue, { uid = uid, label = label })
    end

    local function lootEnqueueChild(child: Instance)
        if not child or not child.Parent then
            return
        end
        local uid = lootUidFromInstance(child)
        if not uid then
            return
        end
        lootEnqueueEntry(uid, lootDisplayName(child))
    end

    local function pushCollectedLootLine(displayName: string)
        table.insert(collectedLootLines, "• " .. displayName)
        while #collectedLootLines > COLLECTED_LOOT_MAX_LINES do
            table.remove(collectedLootLines, 1)
        end
        LootCollectedParagraph:Set({
            Title = "Collected loot",
            Content = #collectedLootLines > 0 and table.concat(collectedLootLines, "\n") or "(None yet)",
        })
    end

    local function disconnectLootFolderListener()
        if lootFolderChildAddedConn then
            lootFolderChildAddedConn:Disconnect()
            lootFolderChildAddedConn = nil
        end
        if lootFolderDescendantAddedConn then
            lootFolderDescendantAddedConn:Disconnect()
            lootFolderDescendantAddedConn = nil
        end
        if lootFolderDestroyingConn then
            lootFolderDestroyingConn:Disconnect()
            lootFolderDestroyingConn = nil
        end
        lastBoundLootFolder = nil
    end

    local connectLootFolder: (Folder) -> ()

    local function attachLootListenerToWorkspaceLoot()
        if lootChildAddedConn then
            lootChildAddedConn:Disconnect()
            lootChildAddedConn = nil
        end
        disconnectLootFolderListener()
        local existing = Workspace:FindFirstChild("Loot")
        if existing and existing:IsA("Folder") then
            connectLootFolder(existing)
            return
        end
        lootChildAddedConn = Workspace.ChildAdded:Connect(function(child)
            if child.Name == "Loot" and child:IsA("Folder") then
                connectLootFolder(child)
                if lootChildAddedConn then
                    lootChildAddedConn:Disconnect()
                    lootChildAddedConn = nil
                end
            end
        end)
    end

    connectLootFolder = function(folder: Folder)
        disconnectLootFolderListener()
        lastBoundLootFolder = folder
        lootFolderChildAddedConn = folder.ChildAdded:Connect(function(child)
            if autoCollectLootEnabled then
                lootEnqueueChild(child)
            end
        end)
        lootFolderDescendantAddedConn = folder.DescendantAdded:Connect(function(inst)
            if autoCollectLootEnabled and looksLikeLootUid(inst.Name) then
                lootEnqueueChild(inst)
            end
        end)
        lootFolderDestroyingConn = folder.Destroying:Connect(function()
            if lastBoundLootFolder == folder then
                lastBoundLootFolder = nil
            end
            disconnectLootFolderListener()
            task.defer(attachLootListenerToWorkspaceLoot)
        end)
        if autoCollectLootEnabled then
            for _, c in ipairs(folder:GetDescendants()) do
                lootEnqueueChild(c)
            end
        end
    end

    attachLootListenerToWorkspaceLoot()

    local function seedExistingLootChildren()
        local folder = Workspace:FindFirstChild("Loot")
        if not folder or not folder:IsA("Folder") then
            return
        end
        for _, child in ipairs(folder:GetDescendants()) do
            lootEnqueueChild(child)
        end
    end

    MainTab:CreateToggle({
        Name = "Auto Collect Loot",
        Flag = "main_auto_collect_loot",
        CurrentValue = false,
        Callback = function(enabled)
            autoCollectLootEnabled = enabled == true
            autoCollectLootLoopToken = autoCollectLootLoopToken + 1
            local myToken = autoCollectLootLoopToken

            if not autoCollectLootEnabled then
                lootProcessQueue = {}
                disconnectLootRemoteListener()
                return
            end

            if not ensureLootRemoteListener() then
                mountNotify({
                    Title = "Auto Collect Loot",
                    Content = "LootService remotes not found under ReplicatedStorage.Packages._Index (leifstout_networker@…).",
                    Icon = "x",
                })
            end

            local folder = Workspace:FindFirstChild("Loot")
            if not folder or not folder:IsA("Folder") then
                mountNotify({
                    Title = "Auto Collect Loot",
                    Content = "Workspace.Loot folder not found yet — waiting. Toggle stays on.",
                    Icon = "x",
                })
            else
                connectLootFolder(folder)
                seedExistingLootChildren()
            end

            task.spawn(function()
                while myToken == autoCollectLootLoopToken and autoCollectLootEnabled do
                    if #lootProcessQueue == 0 then
                        task.wait(0.2)
                    else
                        local entry = lootProcessQueue[1]
                        local fold = findLootServiceRemotesFolder()
                        local rf = fold and fold:FindFirstChild("RemoteFunction")
                        if not fold or not rf or not rf:IsA("RemoteFunction") then
                            ensureLootRemoteListener()
                            task.wait(0.35)
                        else
                            table.remove(lootProcessQueue, 1)
                            lootPendingAck[entry.uid] = nil
                            pcall(function()
                                (rf :: RemoteFunction):InvokeServer("requestCollect", entry.uid)
                            end)
                            local deadline = os.clock() + 6
                            local confirmed = false
                            while os.clock() < deadline do
                                if myToken ~= autoCollectLootLoopToken or not autoCollectLootEnabled then
                                    break
                                end
                                if lootPendingAck[entry.uid] then
                                    lootPendingAck[entry.uid] = nil
                                    confirmed = true
                                    break
                                end
                                task.wait(0.05)
                            end
                            if confirmed then
                                pushCollectedLootLine(entry.label)
                            else
                                local lootFolder = Workspace:FindFirstChild("Loot")
                                if lootFolder and lootFolder:IsA("Folder") then
                                    for _, ch in ipairs(lootFolder:GetChildren()) do
                                        if lootUidFromInstance(ch) == entry.uid then
                                            lootEnqueueEntry(entry.uid, entry.label)
                                            break
                                        end
                                    end
                                end
                            end
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end,
    })

    MainTab:CreateSection("Auto Collect Recipe")

    local autoCollectRecipeEnabled = false
    local autoCollectRecipeLoopToken = 0

    local function getWorkspaceZonesRoot(): Instance?
        local z = Workspace:FindFirstChild("Zones")
        if z and (z:IsA("Folder") or z:IsA("Model")) then
            return z
        end
        return nil
    end

    local function recipeMeshIsShowing(mesh: MeshPart): boolean
        if mesh.Transparency >= 0.999 then
            return false
        end
        if mesh.LocalTransparencyModifier >= 0.999 then
            return false
        end
        return true
    end

    local function findFirstInteractableRecipeInZones(): MeshPart?
        local zones = getWorkspaceZonesRoot()
        if not zones then
            return nil
        end
        for _, inst in ipairs(zones:GetDescendants()) do
            if inst:IsA("MeshPart") and string.sub(inst.Name, 1, 6) == "Recipe" then
                local prompt = inst:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt and prompt:IsA("ProximityPrompt") then
                    if prompt.Enabled and recipeMeshIsShowing(inst) then
                        return inst
                    end
                end
            end
        end
        return nil
    end

    MainTab:CreateToggle({
        Name = "Auto Collect",
        Flag = "main_auto_collect_recipe",
        CurrentValue = false,
        Callback = function(enabled)
            autoCollectRecipeEnabled = enabled == true
            autoCollectRecipeLoopToken = autoCollectRecipeLoopToken + 1
            local myToken = autoCollectRecipeLoopToken

            if not autoCollectRecipeEnabled then
                return
            end

            local zones = getWorkspaceZonesRoot()
            if not zones then
                mountNotify({
                    Title = "Auto Collect Recipe",
                    Content = 'Workspace child "Zones" (Folder or Model) not found — idle until it exists.',
                    Icon = "x",
                })
            end

            task.spawn(function()
                while myToken == autoCollectRecipeLoopToken and autoCollectRecipeEnabled do
                    local lp = Players.LocalPlayer
                    local character = lp.Character
                    local hrp = character and character:FindFirstChild("HumanoidRootPart") :: BasePart?
                    if not hrp then
                        task.wait(0.35)
                    else
                        local zonesNow = getWorkspaceZonesRoot()
                        if not zonesNow then
                            task.wait(1)
                        else
                            local recipeMesh = findFirstInteractableRecipeInZones()
                            if not recipeMesh then
                                task.wait(0.35)
                            else
                                local savedCf = hrp.CFrame
                                local targetPos = recipeMesh.Position
                                hrp.AssemblyLinearVelocity = Vector3.zero
                                local stand = targetPos + Vector3.new(0, 3, 0)
                                hrp.CFrame = CFrame.lookAt(stand, targetPos)
                                task.wait(0.1)
                                mainTryProximityInteractOnInstance(recipeMesh)
                                task.wait(0.2)
                                if hrp.Parent then
                                    hrp.AssemblyLinearVelocity = Vector3.zero
                                    hrp.CFrame = savedCf
                                end
                                task.wait(0.55)
                            end
                        end
                    end
                end
            end)
        end,
    })

    MainTab:CreateSection("Auto Gun")

    local autoGunShotDelaySec = 0.1
    local autoGunEnabled = false
    local autoGunLoopToken = 0
    local autoGunEnemyListenerConns: { RBXScriptConnection } = {}
    local autoGunEnemiesListMaxLines = 0

    local EnemiesListParagraph = MainTab:CreateParagraph({
        Title = "Enemies",
        Content = 'No enemies under Workspace → Gameplay* → Enemies.',
    })

    type GameplayEnemiesEntry = {
        gameplayName: string,
        enemiesFolder: Instance,
    }

    local function mainFindWorkspaceGameplayEnemies(): { GameplayEnemiesEntry }
        local out: { GameplayEnemiesEntry } = {}
        for _, ch in ipairs(Workspace:GetChildren()) do
            if string.sub(ch.Name, 1, #"Gameplay") == "Gameplay" then
                local enemies = ch:FindFirstChild("Enemies")
                if enemies then
                    table.insert(out, {
                        gameplayName = ch.Name,
                        enemiesFolder = enemies,
                    })
                end
            end
        end
        return out
    end

    local function mainFindWorkspaceEnemiesFolders(): { Instance }
        local out: { Instance } = {}
        for _, entry in ipairs(mainFindWorkspaceGameplayEnemies()) do
            table.insert(out, entry.enemiesFolder)
        end
        return out
    end

    local function mainEnemyNumericUid(enemy: Instance): number?
        local fromName = tonumber(enemy.Name)
        if fromName then
            return fromName
        end
        for _, attrName in ipairs({ "Uid", "uid", "UID", "Id", "id" }) do
            local v = enemy:GetAttribute(attrName)
            if type(v) == "number" then
                return v
            end
            if type(v) == "string" then
                local n = tonumber(v)
                if n then
                    return n
                end
            end
        end
        for _, childName in ipairs({ "Uid", "uid", "UID", "Id", "id" }) do
            local sv = enemy:FindFirstChild(childName)
            if sv then
                if sv:IsA("IntValue") or sv:IsA("NumberValue") then
                    return (sv :: any).Value
                end
                if sv:IsA("StringValue") then
                    local n = tonumber((sv :: StringValue).Value)
                    if n then
                        return n
                    end
                end
            end
        end
        return nil
    end

    local function mainEnemyGuiTextFromNode(node: Instance?): string
        if not node then
            return ""
        end
        local function textFromGui(inst: Instance): string
            if inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox") then
                local fromFmt = formatGuiInstanceTextForDisplay(inst)
                if fromFmt and fromFmt ~= "" then
                    return fromFmt
                end
                if inst:IsA("TextLabel") then
                    return (inst :: TextLabel).Text
                end
                if inst:IsA("TextButton") then
                    return (inst :: TextButton).Text
                end
                return (inst :: TextBox).Text
            end
            return ""
        end
        local direct = textFromGui(node)
        if direct ~= "" then
            return direct
        end
        local tl = node:FindFirstChildWhichIsA("TextLabel", true)
        if tl then
            return textFromGui(tl)
        end
        return ""
    end

    local function mainEnemyHpDisplay(enemy: Instance): string
        local bb = enemy:FindFirstChild("HealthBarBillboardGui", true)
        if not bb then
            return "?"
        end
        local hpNode = bb:FindFirstChild("Hp", true)
        if not hpNode then
            return "?"
        end
        local hp = mainEnemyGuiTextFromNode(hpNode)
        return hp ~= "" and hp or "?"
    end

    local function mainEnemyMutationLabel(enemy: Instance): string?
        local bb = enemy:FindFirstChild("MutationBillboard", true)
        if not bb then
            return nil
        end
        local labelNode = bb:FindFirstChild("MutationLabel", true)
        if not labelNode then
            return nil
        end
        local text = mainEnemyGuiTextFromNode(labelNode)
        if text == "" then
            return nil
        end
        return text
    end

    local MUTATION_SHOT_PRIORITY_NAMES: { string } = {
        "Inverted",
        "Shiny",
        "HUGE",
        "Big",
    }

    local function mainMutationNameMatches(a: string, b: string): boolean
        return string.lower(a) == string.lower(b)
    end

    -- 1–4 named mutations, 5 = other mutation, 6 = no MutationBillboard / no label.
    local function mainEnemyMutationShotPriority(mutation: string?): number
        if not mutation or mutation == "" then
            return 6
        end
        for i, priorityName in ipairs(MUTATION_SHOT_PRIORITY_NAMES) do
            if mainMutationNameMatches(mutation, priorityName) then
                return i
            end
        end
        return 5
    end

    type EnemyListRow = {
        uid: number,
        hp: string,
        mutation: string?,
        shotPriority: number,
        listOrder: number,
        gameplayName: string,
    }

    local function mainCollectEnemyListRows(): { EnemyListRow }
        local rows: { EnemyListRow } = {}
        local seenUid: { [number]: boolean } = {}
        local listOrder = 0
        for _, entry in ipairs(mainFindWorkspaceGameplayEnemies()) do
            for _, enemy in ipairs(entry.enemiesFolder:GetChildren()) do
                local uid = mainEnemyNumericUid(enemy)
                if uid and not seenUid[uid] then
                    seenUid[uid] = true
                    listOrder = listOrder + 1
                    local mutation = mainEnemyMutationLabel(enemy)
                    table.insert(rows, {
                        uid = uid,
                        hp = mainEnemyHpDisplay(enemy),
                        mutation = mutation,
                        shotPriority = mainEnemyMutationShotPriority(mutation),
                        listOrder = listOrder,
                        gameplayName = entry.gameplayName,
                    })
                end
            end
        end
        table.sort(rows, function(a, b)
            if a.shotPriority ~= b.shotPriority then
                return a.shotPriority < b.shotPriority
            end
            if a.listOrder ~= b.listOrder then
                return a.listOrder < b.listOrder
            end
            return a.uid < b.uid
        end)
        return rows
    end

    local function mainFormatEnemyListLine(row: EnemyListRow): string
        if row.mutation and row.mutation ~= "" then
            return ("%d - %s (%s)"):format(row.uid, row.hp, row.mutation)
        end
        return ("%d - %s"):format(row.uid, row.hp)
    end

    local function mainPickGameplayEnemyTarget(): (number?, string?)
        local rows = mainCollectEnemyListRows()
        local first = rows[1]
        if first then
            return first.uid, first.gameplayName
        end
        return nil, nil
    end

    local function mainPickGameplayEnemyUid(): number?
        local uid = mainPickGameplayEnemyTarget()
        return uid
    end

    local function mainBuildEnemiesListParagraphBody(): string
        local enemyFolders = mainFindWorkspaceEnemiesFolders()
        if #enemyFolders == 0 then
            return 'No enemies under Workspace → Gameplay* → Enemies.'
        end
        local rows = mainCollectEnemyListRows()
        if #rows == 0 then
            return "Enemies folder(s) found, but no numeric enemy uids yet."
        end
        if #rows > autoGunEnemiesListMaxLines then
            autoGunEnemiesListMaxLines = #rows
        end
        local lines: { string } = {}
        for _, row in ipairs(rows) do
            table.insert(lines, mainFormatEnemyListLine(row))
        end
        while #lines < autoGunEnemiesListMaxLines do
            table.insert(lines, " ")
        end
        return table.concat(lines, "\n")
    end

    local function refreshEnemiesListParagraph()
        if EnemiesListParagraph and EnemiesListParagraph.Set then
            EnemiesListParagraph:Set({
                Title = "Enemies",
                Content = mainBuildEnemiesListParagraphBody(),
            })
        end
    end

    local function disconnectAutoGunEnemyListeners()
        for _, conn in ipairs(autoGunEnemyListenerConns) do
            conn:Disconnect()
        end
        table.clear(autoGunEnemyListenerConns)
    end

    local function scheduleRefreshEnemiesListParagraph()
        deferUiOnHeartbeat(refreshEnemiesListParagraph, "autoGunEnemiesParagraph")
    end

    local function bindAutoGunEnemyListeners()
        disconnectAutoGunEnemyListeners()
        local function hookFolder(folder: Instance)
            table.insert(autoGunEnemyListenerConns, folder.ChildAdded:Connect(scheduleRefreshEnemiesListParagraph))
            table.insert(autoGunEnemyListenerConns, folder.ChildRemoved:Connect(scheduleRefreshEnemiesListParagraph))
            for _, enemy in ipairs(folder:GetChildren()) do
                table.insert(
                    autoGunEnemyListenerConns,
                    enemy.DescendantAdded:Connect(scheduleRefreshEnemiesListParagraph)
                )
            end
        end
        for _, folder in ipairs(mainFindWorkspaceEnemiesFolders()) do
            hookFolder(folder)
        end
        table.insert(autoGunEnemyListenerConns, Workspace.ChildAdded:Connect(function(child)
            if string.sub(child.Name, 1, #"Gameplay") == "Gameplay" then
                local enemies = child:WaitForChild("Enemies", 8)
                if enemies then
                    hookFolder(enemies)
                    scheduleRefreshEnemiesListParagraph()
                end
            end
        end))
    end

    bindAutoGunEnemyListeners()
    refreshEnemiesListParagraph()
    task.spawn(function()
        while true do
            task.wait(1.25)
            refreshEnemiesListParagraph()
        end
    end)

    local slimeGunTryFireRemote: RemoteFunction? = resolveNetworkerRemoteFunction("SlimeGunService")

    local function mainTryFireSlimeGun(uid: number)
        if not slimeGunTryFireRemote then
            return
        end
        pcall(function()
            slimeGunTryFireRemote:InvokeServer("tryFireSlimeGun", uid)
        end)
    end

    MainTab:CreateSlider({
        Name = "Shot interval",
        Flag = "main_auto_gun_shot_interval",
        Range = { 0.001, 2 },
        Increment = 0.05,
        Suffix = "sec",
        CurrentValue = autoGunShotDelaySec,
        Callback = function(value)
            if type(value) == "number" and value == value then
                autoGunShotDelaySec = math.clamp(value, 0.05, 3)
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Shot",
        Flag = "main_auto_gun_shot",
        CurrentValue = false,
        Callback = function(enabled)
            autoGunEnabled = enabled == true
            autoGunLoopToken = autoGunLoopToken + 1
            local myToken = autoGunLoopToken

            if not autoGunEnabled then
                return
            end

            task.spawn(function()
                while myToken == autoGunLoopToken and autoGunEnabled do
                    local uid = mainPickGameplayEnemyUid()
                    if not uid then
                        task.wait(math.max(autoGunShotDelaySec, 0.35))
                    else
                        mainTryFireSlimeGun(uid)
                        task.wait(autoGunShotDelaySec)
                    end
                end
            end)
        end,
    })

    MainTab:CreateSection("Burst Attack")

    local burstAttackDamage = 8406
    local burstAttackEnabled = false
    local burstAttackLoopToken = 0
    local burstAttackDelaySec = 0.1
    local gameplayConfirmHitRemote: RemoteEvent? = nil
    local gameplayConfirmHitRemoteServiceName: string? = nil

    local function mainTryConfirmHit(damage: number, uid: number, gameplayServiceName: string?)
        if not gameplayServiceName or gameplayServiceName == "" then
            return
        end
        if gameplayConfirmHitRemoteServiceName ~= gameplayServiceName then
            gameplayConfirmHitRemoteServiceName = gameplayServiceName
            gameplayConfirmHitRemote = resolveNetworkerRemoteEvent(
                gameplayServiceName,
                LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION
            )
        elseif not gameplayConfirmHitRemote or not gameplayConfirmHitRemote.Parent then
            gameplayConfirmHitRemote = resolveNetworkerRemoteEvent(
                gameplayServiceName,
                LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION
            )
        end
        if not gameplayConfirmHitRemote then
            return
        end
        pcall(function()
            gameplayConfirmHitRemote:FireServer("confirmHit", damage, uid)
        end)
    end

    MainTab:CreateInput({
        Name = "Damage",
        PlaceholderText = "e.g. 8406",
        Flag = "slimeAttack",
        CurrentValue = tostring(burstAttackDamage),
        Callback = function(value)
            local n = tonumber(value)
            if n and n == n then
                burstAttackDamage = math.floor(n)
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Attack",
        Flag = "main_burst_attack",
        CurrentValue = false,
        Callback = function(enabled)
            burstAttackEnabled = enabled == true
            burstAttackLoopToken = burstAttackLoopToken + 1
            local myToken = burstAttackLoopToken

            if not burstAttackEnabled then
                return
            end

            task.spawn(function()
                while myToken == burstAttackLoopToken and burstAttackEnabled do
                    local uid, gameplayName = mainPickGameplayEnemyTarget()
                    if not uid or not gameplayName then
                        task.wait(math.max(burstAttackDelaySec, 0.35))
                    else
                        mainTryConfirmHit(burstAttackDamage, uid, gameplayName)
                        task.wait(burstAttackDelaySec)
                    end
                end
            end)
        end,
    })

    local upgradeServiceUtils: any = nil
    local upgradeUtilsLoadError: string? = nil
    local playerUpgradesSave: { [string]: any } = {}
    local SPECIAL_ROLL_UPGRADE_KEY_BY_KIND: { [string]: string } = {
        golden = "goldenRolls",
        diamond = "diamondRolls",
        void = "voidRolls",
        galaxy = "galaxyRolls",
    }
    local UPGRADE_LUCK_ROLL_KINDS: { string } = { "golden", "diamond", "void", "galaxy" }

    local function cloneUpgradesTable(src: any): { [string]: any }
        local out: { [string]: any } = {}
        if type(src) ~= "table" then
            return out
        end
        for k, v in pairs(src) do
            if type(k) == "string" then
                out[k] = v
            end
        end
        return out
    end

    local function getDataServiceClient(): any?
        local packages = ReplicatedStorage:FindFirstChild("Packages")
        local dsMod = packages and packages:FindFirstChild("DataService")
        if not dsMod or not dsMod:IsA("ModuleScript") then
            return nil
        end
        local okPkg, ds = pcall(require, dsMod)
        if not okPkg or type(ds) ~= "table" then
            return nil
        end
        local client = ds.client
        if type(client) ~= "table" or type(client.get) ~= "function" then
            return nil
        end
        return client
    end

    local function tryLoadUpgradeServiceUtils(): boolean
        if upgradeServiceUtils then
            return true
        end
        local src = ReplicatedStorage:FindFirstChild("Source")
        local upgradesFolder = src and src:FindFirstChild("Features")
        upgradesFolder = upgradesFolder and upgradesFolder:FindFirstChild("Upgrades")
        local mod = upgradesFolder and upgradesFolder:FindFirstChild("UpgradeServiceUtils")
        if not mod or not mod:IsA("ModuleScript") then
            upgradeUtilsLoadError = "UpgradeServiceUtils ModuleScript not found under ReplicatedStorage.Source.Features.Upgrades"
            return false
        end
        local ok, result = pcall(require, mod)
        if not ok or type(result) ~= "table" then
            upgradeUtilsLoadError = tostring(result)
            return false
        end
        upgradeServiceUtils = result
        upgradeUtilsLoadError = nil
        return true
    end

    local function luckRollCadenceEveryN(utils: any, kind: string, save: { [string]: any }): (number?, number)
        local upgradeKey = SPECIAL_ROLL_UPGRADE_KEY_BY_KIND[kind]
        if not upgradeKey then
            return nil, 0
        end
        local lvl = utils.getUpgradeLevel(upgradeKey, save)
        if lvl <= 0 then
            return nil, lvl
        end
        local luckRolls = utils.enums and utils.enums.luckRolls
        local cadence = luckRolls and luckRolls[kind]
        if type(cadence) ~= "table" then
            return nil, lvl
        end
        local everyN = cadence[math.min(lvl, 3)] or cadence[1]
        return everyN, lvl
    end

    local function tryPullPlayerUpgradesFromDataService(): boolean
        local client = getDataServiceClient()
        if not client then
            return false
        end
        local okGet, data = pcall(function()
            return client:get("upgrades")
        end)
        if okGet and type(data) == "table" then
            playerUpgradesSave = cloneUpgradesTable(data)
            return true
        end
        return false
    end

    local rollServiceRemote: RemoteFunction? = nil

    local function getRollServiceRemote(): RemoteFunction?
        if rollServiceRemote and rollServiceRemote.Parent then
            return rollServiceRemote
        end
        rollServiceRemote =
            resolveNetworkerRemoteFunction("RollService", LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION)
        if rollServiceRemote then
            return rollServiceRemote
        end
        local packages = ReplicatedStorage:FindFirstChild("Packages")
            or ReplicatedStorage:WaitForChild("Packages", 12)
        if not packages then
            return nil
        end
        local idx = packages:FindFirstChild("_Index") or packages:WaitForChild("_Index", 12)
        if not idx then
            return nil
        end
        local pkg = idx:FindFirstChild(LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION)
            or idx:WaitForChild(LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION, 12)
        if not pkg then
            return nil
        end
        local net = pkg:FindFirstChild("networker") or pkg:WaitForChild("networker", 12)
        local rem = net and (net:FindFirstChild("_remotes") or net:WaitForChild("_remotes", 12))
        local rollSvc = rem and rem:FindFirstChild("RollService")
        local rollRf = rollSvc and rollSvc:FindFirstChild("RemoteFunction")
        if rollRf and rollRf:IsA("RemoteFunction") then
            rollServiceRemote = rollRf
        end
        return rollServiceRemote
    end

    local function getRollSetSpecialPausedRemote(): RemoteFunction?
        return getRollServiceRemote()
    end

    local function tryRequestRoll(): boolean
        local rf = getRollServiceRemote()
        if not rf then
            return false
        end
        local ok, result = pcall(function()
            return rf:InvokeServer("requestRoll")
        end)
        if not ok then
            return false
        end
        return result ~= nil
    end

    MainTab:CreateSection("Auto Roll")

    local autoRollEnabled = false
    local autoRollLoopToken = 0
    local autoRollDelaySec = 2
    local autoRollSuccessCount = 0
    local autoRollFailedCount = 0

    local AutoRollStatsParagraph = MainTab:CreateParagraph({
        Title = "Roll stats",
        Content = "Success: 0\nFailed: 0",
    })

    local function refreshAutoRollStatsParagraph()
        if AutoRollStatsParagraph and AutoRollStatsParagraph.Set then
            AutoRollStatsParagraph:Set({
                Title = "Roll stats",
                Content = ("Success: %d\nFailed: %d"):format(autoRollSuccessCount, autoRollFailedCount),
            })
        end
    end

    MainTab:CreateSlider({
        Name = "Delay",
        Flag = "main_auto_roll_delay",
        Range = { 0.1, 10 },
        Increment = 0.1,
        Suffix = "sec",
        CurrentValue = autoRollDelaySec,
        Callback = function(value)
            if type(value) == "number" and value == value then
                autoRollDelaySec = math.clamp(value, 0.1, 10)
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Roll",
        Flag = "main_auto_roll",
        CurrentValue = false,
        Callback = function(enabled)
            autoRollEnabled = enabled == true
            autoRollLoopToken = autoRollLoopToken + 1
            local myToken = autoRollLoopToken

            if not autoRollEnabled then
                return
            end

            task.spawn(function()
                while myToken == autoRollLoopToken and autoRollEnabled do
                    if tryRequestRoll() then
                        autoRollSuccessCount = autoRollSuccessCount + 1
                    else
                        autoRollFailedCount = autoRollFailedCount + 1
                    end
                    refreshAutoRollStatsParagraph()
                    task.wait(autoRollDelaySec)
                end
            end)
        end,
    })

    MainTab:CreateSection("Special Roll")

    -- Highest → lowest priority (galaxy first).
    local SPECIAL_ROLL_TIER_ORDER: { string } = { "galaxy", "void", "diamond", "golden" }

    type SpecialRollTierSnapshot = {
        paused: boolean,
        rollsUntilNext: number,
    }

    local specialRollProgressionByTier: { [string]: SpecialRollTierSnapshot } = {}
    local specialRollDisplayToTier: { [string]: string } = {}
    local selectedSpecialRollTierKeys: { string } = {}
    local lastSelectedSpecialRollTier: string? = nil
    local specialRollPreviousSelectedSet: { [string]: boolean } = {}
    local specialRollDropdownSeededAll = false
    local suppressSpecialRollDropdownCallback = false
    local SpecialRollDropdown: any = nil
    local autoCombineSpecialRollEnabled = false
    local specialRollCombineInvokePending: { [string]: boolean } = {}
    local autoCombineAllZeroLog: { string } = {}
    local AUTO_COMBINE_ALL_ZERO_LOG_MAX = 25
    local autoCombineAllZeroWasActive = false
    local runAutoCombineSpecialRollPass: () -> ()
    local specialDiceCtrl: {
        footerLine: () -> string,
        mountDropdown: () -> (),
        refreshDropdown: () -> (),
        tryAutoUseWhenAllSelectedAtZero: ({ string }, { [string]: any }) -> (),
        clearAutoUsePending: () -> (),
    }

    local function specialRollTierDisplayName(tierKey: string): string
        return string.sub(tierKey, 1, 1):upper() .. string.sub(tierKey, 2)
    end

    local function specialRollNormalizeTierKey(rawKey: any): string?
        if type(rawKey) ~= "string" then
            return nil
        end
        local lower = string.lower(rawKey)
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            if lower == tier then
                return tier
            end
        end
        return nil
    end

    local function specialRollParseTierEntry(entry: any): SpecialRollTierSnapshot?
        if type(entry) ~= "table" then
            return nil
        end
        local rolls = entry.rollsUntilNext
        if type(rolls) ~= "number" then
            rolls = tonumber(rolls) or 0
        end
        return {
            paused = entry.paused == true,
            rollsUntilNext = math.max(0, math.floor(rolls)),
        }
    end

    local SpecialRollParagraph = MainTab:CreateParagraph({
        Title = "Special rolls",
        Content = "—\n\nPick: none",
    })

    local refreshSpecialRollParagraph: () -> ()

    specialDiceCtrl = createMainTabSpecialDiceController({
        mainTab = MainTab,
        getDataServiceClient = getDataServiceClient,
        cloneTable = cloneUpgradesTable,
        resolveInventoryRemote = function()
            return resolveNetworkerRemoteFunction("InventoryService", LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION)
        end,
        onParagraphDirty = function()
            deferUiOnHeartbeat(refreshSpecialRollParagraph, "specialRollParagraph")
        end,
    })

    local function buildSpecialRollSelectedLine(): string
        local names: { string } = {}
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            if table.find(selectedSpecialRollTierKeys, tier) then
                table.insert(names, specialRollTierDisplayName(tier))
            end
        end
        if #names == 0 then
            return "Pick: none"
        end
        return "Pick: " .. table.concat(names, ", ")
    end

    local function formatSpecialRollTierLine(kind: string): string
        local label = specialRollTierDisplayName(kind)
        local prog = specialRollProgressionByTier[kind]
        local left = if prog then tostring(prog.rollsUntilNext) else "—"
        local pauseTag = if prog and prog.paused then " (paused)" else " (running)"

        if tryLoadUpgradeServiceUtils() and upgradeServiceUtils then
            local everyN = luckRollCadenceEveryN(upgradeServiceUtils, kind, playerUpgradesSave)
            if everyN then
                return ("%s: max = %d remaining = %s%s"):format(label, everyN, left, pauseTag)
            end
            return ("%s: locked%s"):format(label, pauseTag)
        end
        if prog then
            return ("%s: %s%s"):format(label, left, pauseTag)
        end
        return ("%s: —"):format(label)
    end

    local function appendAutoCombineAllZeroLog()
        local tierNames: { string } = {}
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            if table.find(selectedSpecialRollTierKeys, tier) then
                table.insert(tierNames, specialRollTierDisplayName(tier))
            end
        end
        local stamp = os.date("%Y-%m-%d %H:%M:%S")
        local line = ("[%s] All selected at 0 remaining: %s"):format(stamp, table.concat(tierNames, ", "))
        table.insert(autoCombineAllZeroLog, line)
        if #autoCombineAllZeroLog > AUTO_COMBINE_ALL_ZERO_LOG_MAX then
            table.remove(autoCombineAllZeroLog, 1)
        end
    end

    local function buildAutoCombineAllZeroLogSection(): string
        if #autoCombineAllZeroLog == 0 then
            return ""
        end
        local lines: { string } = { "\n\nAuto combine log:" }
        for _, line in ipairs(autoCombineAllZeroLog) do
            table.insert(lines, line)
        end
        return table.concat(lines, "\n")
    end

    local function buildSpecialRollParagraphBody(): string
        local selectedLine = buildSpecialRollSelectedLine()
        local progressionLines: { string } = {}
        local anyProgression = false
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            table.insert(progressionLines, formatSpecialRollTierLine(tier))
            if specialRollProgressionByTier[tier] then
                anyProgression = true
            end
        end
        local body = table.concat(progressionLines, "\n")
            .. "\n\n"
            .. selectedLine
            .. "\n"
            .. specialDiceCtrl.footerLine()
            .. buildAutoCombineAllZeroLogSection()
        if not anyProgression then
            body = body .. "\n\n(no progression yet)"
        end
        return body
    end

    refreshSpecialRollParagraph = function()
        tryPullPlayerUpgradesFromDataService()
        if SpecialRollParagraph and SpecialRollParagraph.Set then
            SpecialRollParagraph:Set({
                Title = "Special rolls",
                Content = buildSpecialRollParagraphBody(),
            })
        end
    end

    local function scheduleRefreshSpecialRollParagraph()
        deferUiOnHeartbeat(refreshSpecialRollParagraph, "specialRollParagraph")
    end

    local function specialRollRebuildDisplayMap(): { string }
        table.clear(specialRollDisplayToTier)
        local opts: { string } = {}
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            local display = specialRollTierDisplayName(tier)
            specialRollDisplayToTier[display] = tier
            table.insert(opts, display)
        end
        return opts
    end

    local function specialRollSetSelectedTierKeysFromDisplayOptions(value: any)
        if suppressSpecialRollDropdownCallback then
            return
        end
        local nextKeys: { string } = {}
        local function addDisplay(opt: string)
            local tier = specialRollDisplayToTier[opt]
            if tier and not table.find(nextKeys, tier) then
                table.insert(nextKeys, tier)
            end
        end
        if type(value) == "table" then
            for _, opt in ipairs(value) do
                if type(opt) == "string" then
                    addDisplay(opt)
                end
            end
        elseif type(value) == "string" then
            addDisplay(value)
        end

        for _, tier in ipairs(nextKeys) do
            if not specialRollPreviousSelectedSet[tier] then
                lastSelectedSpecialRollTier = tier
            end
        end
        if #nextKeys == 1 then
            lastSelectedSpecialRollTier = nextKeys[1]
        elseif #nextKeys == 0 then
            lastSelectedSpecialRollTier = nil
        elseif lastSelectedSpecialRollTier and not table.find(nextKeys, lastSelectedSpecialRollTier) then
            lastSelectedSpecialRollTier = nextKeys[#nextKeys]
        end

        table.clear(selectedSpecialRollTierKeys)
        for _, tier in ipairs(nextKeys) do
            table.insert(selectedSpecialRollTierKeys, tier)
        end
        table.clear(specialRollPreviousSelectedSet)
        for _, tier in ipairs(nextKeys) do
            specialRollPreviousSelectedSet[tier] = true
        end

        table.clear(specialRollCombineInvokePending)

        deferUiOnHeartbeat(refreshSpecialRollParagraph, "specialRollParagraph")
        if autoCombineSpecialRollEnabled then
            deferUiOnHeartbeat(runAutoCombineSpecialRollPass, "specialRollAutoCombine")
        end
    end

    local function refreshSpecialRollDropdownFromProgression()
        local opts = specialRollRebuildDisplayMap()
        local tierKeysAvailable = table.clone(SPECIAL_ROLL_TIER_ORDER)

        suppressSpecialRollDropdownCallback = true
        if SpecialRollDropdown and SpecialRollDropdown.Refresh then
            pcall(function()
                SpecialRollDropdown:Refresh(opts)
            end)
        end

        local displaySelected: { string } = {}
        if not specialRollDropdownSeededAll then
            selectedSpecialRollTierKeys = table.clone(tierKeysAvailable)
            lastSelectedSpecialRollTier = tierKeysAvailable[#tierKeysAvailable]
            table.clear(specialRollPreviousSelectedSet)
            for _, tier in ipairs(selectedSpecialRollTierKeys) do
                specialRollPreviousSelectedSet[tier] = true
            end
            specialRollDropdownSeededAll = true
            displaySelected = opts
        else
            local kept: { string } = {}
            for _, tier in ipairs(selectedSpecialRollTierKeys) do
                if specialRollProgressionByTier[tier] and not table.find(kept, tier) then
                    table.insert(kept, tier)
                end
            end
            if #kept == 0 then
                kept = table.clone(tierKeysAvailable)
            end
            selectedSpecialRollTierKeys = kept
            if lastSelectedSpecialRollTier and not table.find(selectedSpecialRollTierKeys, lastSelectedSpecialRollTier) then
                lastSelectedSpecialRollTier = selectedSpecialRollTierKeys[#selectedSpecialRollTierKeys]
            end
            for _, tier in ipairs(selectedSpecialRollTierKeys) do
                table.insert(displaySelected, specialRollTierDisplayName(tier))
            end
        end

        if SpecialRollDropdown and SpecialRollDropdown.Set then
            pcall(function()
                SpecialRollDropdown:Set(displaySelected)
            end)
        end
        suppressSpecialRollDropdownCallback = false

        deferUiOnHeartbeat(refreshSpecialRollParagraph, "specialRollParagraph")
        if autoCombineSpecialRollEnabled then
            deferUiOnHeartbeat(runAutoCombineSpecialRollPass, "specialRollAutoCombine")
        end
    end

    local function scheduleRefreshSpecialRollDropdown()
        deferUiOnHeartbeat(refreshSpecialRollDropdownFromProgression, "specialRollDropdown")
    end

    local dataServiceProgressRemoteEvent: RemoteEvent? = nil

    local function mainRequestSetSpecialRollPaused(tierKey: string, pausedFlag: boolean): boolean
        local rf = getRollSetSpecialPausedRemote()
        if not rf then
            return false
        end
        local ok = pcall(function()
            rf:InvokeServer("requestSetSpecialRollPaused", tierKey, pausedFlag)
        end)
        return ok == true
    end

    -- Game API: true = pause, false = resume.
    local SPECIAL_ROLL_REMOTE_PAUSE = true
    local SPECIAL_ROLL_REMOTE_RESUME = false

    local function pauseSelectedSpecialRollTiers(): (number, number)
        local okCount = 0
        local failCount = 0
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            if table.find(selectedSpecialRollTierKeys, tier) then
                local st = specialRollProgressionByTier[tier]
                if st and not st.paused then
                    if mainRequestSetSpecialRollPaused(tier, SPECIAL_ROLL_REMOTE_PAUSE) then
                        okCount = okCount + 1
                    else
                        failCount = failCount + 1
                    end
                end
            end
        end
        return okCount, failCount
    end

    local function anySelectedSpecialTierHasProgression(): boolean
        for _, tier in ipairs(selectedSpecialRollTierKeys) do
            if specialRollProgressionByTier[tier] then
                return true
            end
        end
        return false
    end

    local function allSelectedSpecialTiersAtOneRemaining(): boolean
        if #selectedSpecialRollTierKeys < 2 then
            return false
        end
        for _, tier in ipairs(selectedSpecialRollTierKeys) do
            local st = specialRollProgressionByTier[tier]
            if not st or st.rollsUntilNext ~= 1 then
                return false
            end
        end
        return true
    end

    -- Count selected tiers that are currently running (not paused) and still
    -- have more than one roll left before their next special roll.
    local function selectedUnpausedSpecialTiersAboveOne(): number
        local count = 0
        for _, tier in ipairs(selectedSpecialRollTierKeys) do
            local st = specialRollProgressionByTier[tier]
            if st and not st.paused and (st.rollsUntilNext or 0) > 1 then
                count += 1
            end
        end
        return count
    end

    local function specialRollTierCadenceMax(tier: string): number?
        if tryLoadUpgradeServiceUtils() and upgradeServiceUtils then
            local everyN = luckRollCadenceEveryN(upgradeServiceUtils, tier, playerUpgradesSave)
            if everyN then
                return everyN
            end
        end
        return nil
    end

    -- Do not pause a tier at 1 while a higher-priority selected tier is still
    -- running above that tier's cadence max (e.g. void 150, diamond max 100).
    local function shouldAutoCombinePauseTierAtOne(tier: string): boolean
        local tierMax = specialRollTierCadenceMax(tier)
        if not tierMax then
            return true
        end
        for _, higherTier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            if higherTier == tier then
                break
            end
            if not table.find(selectedSpecialRollTierKeys, higherTier) then
                continue
            end
            local st = specialRollProgressionByTier[higherTier]
            if st and not st.paused and st.rollsUntilNext > 1 then
                if st.rollsUntilNext > tierMax then
                    return false
                end
            end
        end
        return true
    end

    -- Selected tiers currently sitting at rollsUntilNext == 1 and not paused.
    local function selectedSpecialTiersAtOneNotPaused(): { string }
        local out: { string } = {}
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            if table.find(selectedSpecialRollTierKeys, tier) then
                local st = specialRollProgressionByTier[tier]
                if st and not st.paused and st.rollsUntilNext == 1 and shouldAutoCombinePauseTierAtOne(tier) then
                    table.insert(out, tier)
                end
            end
        end
        return out
    end

    -- Selected tiers that are paused; used for resume-all.
    local function selectedSpecialTiersPaused(): { string }
        local out: { string } = {}
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            if table.find(selectedSpecialRollTierKeys, tier) then
                local st = specialRollProgressionByTier[tier]
                if st and st.paused then
                    table.insert(out, tier)
                end
            end
        end
        return out
    end

    function runAutoCombineSpecialRollPass()
        if not autoCombineSpecialRollEnabled or #selectedSpecialRollTierKeys < 2 then
            return
        end
        if not getRollSetSpecialPausedRemote() then
            return
        end

        if not anySelectedSpecialTierHasProgression() then
            return
        end

        local unpausedAboveOne = selectedUnpausedSpecialTiersAboveOne()

        if unpausedAboveOne >= 1 then
            -- Pause every selected tier that has hit 1 while another selected
            -- tier is still running with more than one roll to go.
            for _, tier in ipairs(selectedSpecialTiersAtOneNotPaused()) do
                if not specialRollCombineInvokePending[tier] then
                    if mainRequestSetSpecialRollPaused(tier, SPECIAL_ROLL_REMOTE_PAUSE) then
                        specialRollCombineInvokePending[tier] = true
                    end
                end
            end
        else
            -- No selected tier is left running above 1, so every still-paused
            -- selected tier can be resumed together for the combined roll.
            if allSelectedSpecialTiersAtOneRemaining() then
                for _, tier in ipairs(selectedSpecialTiersPaused()) do
                    if not specialRollCombineInvokePending[tier] then
                        if mainRequestSetSpecialRollPaused(tier, SPECIAL_ROLL_REMOTE_RESUME) then
                            specialRollCombineInvokePending[tier] = true
                        end
                    end
                end
            end
        end

        for tier, _ in pairs(specialRollCombineInvokePending) do
            if not table.find(selectedSpecialRollTierKeys, tier) then
                specialRollCombineInvokePending[tier] = nil
                continue
            end
            local st = specialRollProgressionByTier[tier]
            if not st then
                specialRollCombineInvokePending[tier] = nil
                continue
            end
            if unpausedAboveOne >= 1 then
                -- We just asked this tier to pause; clear pending once paused
                -- or once it no longer sits at 1 (state changed under us).
                if st.paused or st.rollsUntilNext ~= 1 then
                    specialRollCombineInvokePending[tier] = nil
                end
            else
                -- Resume branch: clear pending once the tier is actually running.
                if not st.paused then
                    specialRollCombineInvokePending[tier] = nil
                end
            end
        end

        local allSelectedAtZero = #selectedSpecialRollTierKeys > 0
        for _, tier in ipairs(selectedSpecialRollTierKeys) do
            local st = specialRollProgressionByTier[tier]
            if not st or st.rollsUntilNext ~= 0 then
                allSelectedAtZero = false
                break
            end
        end
        if allSelectedAtZero then
            if not autoCombineAllZeroWasActive then
                autoCombineAllZeroWasActive = true
                appendAutoCombineAllZeroLog()
                scheduleRefreshSpecialRollParagraph()
            end
            specialDiceCtrl.tryAutoUseWhenAllSelectedAtZero(selectedSpecialRollTierKeys, specialRollProgressionByTier)
        else
            autoCombineAllZeroWasActive = false
            specialDiceCtrl.clearAutoUsePending()
        end
    end

    local function specialRollApplyProgressionPayload(payload: any)
        if type(payload) ~= "table" then
            return
        end
        local changed = false
        for _, tier in ipairs(SPECIAL_ROLL_TIER_ORDER) do
            local parsed = specialRollParseTierEntry(payload[tier])
            if parsed then
                specialRollProgressionByTier[tier] = parsed
                changed = true
            end
        end
        for rawKey, entry in pairs(payload) do
            local tier = specialRollNormalizeTierKey(rawKey)
            if tier then
                local parsed = specialRollParseTierEntry(entry)
                if parsed then
                    specialRollProgressionByTier[tier] = parsed
                    changed = true
                end
            end
        end
        if not changed then
            return
        end
        scheduleRefreshSpecialRollParagraph()
        scheduleRefreshSpecialRollDropdown()
    end

    local specialRollDataServiceConn: RBXScriptConnection? = nil

    local function specialRollProgressionEventMatches(a1: any, a2: any): boolean
        local key = if type(a2) == "string" then a2 elseif type(a1) == "string" then a1 else nil
        return key == "specialRollProgression"
    end

    local function specialRollExtractProgressionPayload(a1: any, a2: any, a3: any): any
        if specialRollProgressionEventMatches(a1, a2) then
            return a3
        end
        if type(a1) == "table" then
            return a1
        end
        return nil
    end

    local function ensureSpecialRollDataServiceListener(): boolean
        if specialRollDataServiceConn then
            return dataServiceProgressRemoteEvent ~= nil
        end
        for _, version in ipairs(LEIFSTOUT_NETWORKER_VERSIONS) do
            local dataEv = findNetworkerRemoteInService(
                "DataService",
                "RemoteEvent",
                "RemoteEvent",
                version
            )
            if dataEv and dataEv:IsA("RemoteEvent") then
                dataServiceProgressRemoteEvent = dataEv
                specialRollDataServiceConn = dataEv.OnClientEvent:Connect(function(a1, a2, a3)
                    local payload = specialRollExtractProgressionPayload(a1, a2, a3)
                    if payload then
                        specialRollApplyProgressionPayload(payload)
                    end
                end)
                return true
            end
        end
        return false
    end

    local function tryPullSpecialRollProgressionFromDataService(): boolean
        local client = getDataServiceClient()
        if not client then
            return false
        end
        local okGet, prog = pcall(function()
            return client:get("specialRollProgression")
        end)
        if not okGet or type(prog) ~= "table" then
            return false
        end
        specialRollApplyProgressionPayload(prog)
        return true
    end

    local function bootstrapSpecialRollSection()
        ensureSpecialRollDataServiceListener()
        tryPullSpecialRollProgressionFromDataService()
        scheduleRefreshSpecialRollDropdown()
        scheduleRefreshSpecialRollParagraph()
        specialDiceCtrl.refreshDropdown()
    end

    local initialSpecialRollOpts = specialRollRebuildDisplayMap()

    SpecialRollDropdown = MainTab:CreateDropdown({
        Name = "Special Roll",
        Flag = "main_auto_adjust_special_roll_dropdown",
        Options = initialSpecialRollOpts,
        CurrentOption = {},
        MultipleOptions = true,
        Search = true,
        Callback = function(value)
            specialRollSetSelectedTierKeysFromDisplayOptions(value)
        end,
    })

    specialDiceCtrl.mountDropdown()

    deferUiOnHeartbeat(bootstrapSpecialRollSection)

    task.spawn(function()
        for _ = 1, 60 do
            if tryPullSpecialRollProgressionFromDataService() then
                break
            end
            ensureSpecialRollDataServiceListener()
            local packages = ReplicatedStorage:FindFirstChild("Packages")
            if not packages then
                packages = ReplicatedStorage:WaitForChild("Packages", 2)
            end
            task.wait(0.5)
        end
        scheduleRefreshSpecialRollDropdown()
        scheduleRefreshSpecialRollParagraph()
    end)

    MainTab:CreateButton({
        Name = "Pause Selected Special Roll",
        Flag = "main_pause_selected_special_roll",
        Callback = function()
            if #selectedSpecialRollTierKeys == 0 then
                mountNotify({
                    Title = "Special Roll",
                    Content = "Select at least one special roll tier.",
                    Icon = "x",
                })
                return
            end

            if not getRollSetSpecialPausedRemote() then
                mountNotify({
                    Title = "Special Roll",
                    Content = "RollService RemoteFunction not found under "
                        .. LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION
                        .. ".",
                    Icon = "x",
                })
                return
            end

            local okCount, failCount = pauseSelectedSpecialRollTiers()
            if okCount == 0 and failCount == 0 then
                mountNotify({
                    Title = "Special Roll",
                    Content = "Selected tiers are already paused or have no progression data yet.",
                    Icon = "x",
                })
                return
            end
            if failCount > 0 then
                mountNotify({
                    Title = "Special Roll",
                    Content = ("Paused %d tier(s); %d request(s) failed."):format(okCount, failCount),
                    Icon = "x",
                })
                return
            end
            mountNotify({
                Title = "Special Roll",
                Content = ("Paused %d special roll tier(s)."):format(okCount),
                Icon = "check",
            })
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Combine Special Roll",
        Flag = "main_auto_combine_special_roll",
        CurrentValue = false,
        Callback = function(enabled)
            autoCombineSpecialRollEnabled = enabled == true

            if not autoCombineSpecialRollEnabled then
                table.clear(specialRollCombineInvokePending)
                return
            end

            if #selectedSpecialRollTierKeys < 2 then
                mountNotify({
                    Title = "Special Roll",
                    Content = "Pick at least two tiers to combine.",
                    Icon = "x",
                })
                return
            end

            if not getRollSetSpecialPausedRemote() then
                mountNotify({
                    Title = "Special Roll",
                    Content = "RollService RemoteFunction not found under "
                        .. LEIFSTOUT_NETWORKER_ROLL_SERVICE_VERSION
                        .. ".",
                    Icon = "x",
                })
                return
            end

            runAutoCombineSpecialRollPass()
        end,
    })

    mountAutoFeedSection(MainTab, findNetworkerServiceRemotesFolder, lootUidFromInstance)

    mountAutoRebirthSection(MainTab, findNetworkerServiceRemotesFolder, getDataServiceClient)

    mountAutoOpenZoneSection(MainTab, findNetworkerServiceRemotesFolder, getDataServiceClient)

    mountAutoUpgradesSection(MainTab, findNetworkerServiceRemotesFolder, getDataServiceClient)

    mountMachineUnlockerSection(MainTab, findNetworkerServiceRemotesFolder, getDataServiceClient)

    mountUfoEventSection(MainTab, findNetworkerServiceRemotesFolder)

    MainTab:CreateSection("Auto Equip Slimes")

    autoEquipBestEnabled = false
    autoEquipBestLoopToken = 0
    AUTO_EQUIP_BEST_INTERVAL_SEC = 30

    MainTab:CreateToggle({
        Name = "Auto Equip Best",
        Flag = "main_auto_equip_best",
        CurrentValue = false,
        Callback = function(enabled)
            autoEquipBestEnabled = enabled == true
            autoEquipBestLoopToken = autoEquipBestLoopToken + 1
            local myToken = autoEquipBestLoopToken

            if not autoEquipBestEnabled then
                return
            end

            task.spawn(function()
                while myToken == autoEquipBestLoopToken and autoEquipBestEnabled do
                    local inv = findNetworkerServiceRemotesFolder("InventoryService")
                    local rf = inv and inv:FindFirstChild("RemoteFunction")
                    if inv and rf and rf:IsA("RemoteFunction") then
                        pcall(function()
                            (rf :: RemoteFunction):InvokeServer("requestEquipBest")
                        end)
                    end
                    task.wait(AUTO_EQUIP_BEST_INTERVAL_SEC)
                end
            end)
        end,
    })

    MainTab:CreateSection("Upgrades")

    UPGRADE_LEVEL_STAT_KEYS = {
        "rollSpeed",
        "luck",
        "walkSpeed",
        "coinIncome",
        "enemySpawnSpeed",
        "slimeTargetRange",
        "magnetRadius",
        "goopDropRate",
        "doubleGoop",
        "overkill",
        "slimeGunDamage",
        "slimeGunFireRate",
        "slimeGunRange",
        "extraRollChance",
        "bonusRolls",
        "cloverRolls",
    }
    UPGRADE_MUTATION_KINDS = { "big", "huge", "shiny", "inverted" }
    UPGRADE_OWNED_DISPLAY_MAX = 40

    UpgradeUtilsParagraph = MainTab:CreateParagraph({
        Title = "UpgradeServiceUtils",
        Content = "Loading…",
    })
    UpgradeLuckRollsParagraph = MainTab:CreateParagraph({
        Title = "Luck roll cadence",
        Content = "Loading…",
    })
    UpgradeOwnedParagraph = MainTab:CreateParagraph({
        Title = "Owned upgrades",
        Content = "Waiting for upgrades data…",
    })
    UpgradeStatsParagraph = MainTab:CreateParagraph({
        Title = "Computed stats",
        Content = "Loading…",
    })

    function setUpgradeParagraph(paragraph: any, title: string, content: string)
        if paragraph and paragraph.Set then
            paragraph:Set({ Title = title, Content = content })
        end
    end

    function formatUpgradePercentFromMultiplier(mult: number): string
        return ("%d%%"):format(math.round((mult - 1) * 100))
    end

    function buildUpgradeUtilsParagraphBody(): string
        local loaded = tryLoadUpgradeServiceUtils()
        if not loaded then
            return upgradeUtilsLoadError or "Failed to load UpgradeServiceUtils."
        end
        local saveKeyCount = 0
        for _ in pairs(playerUpgradesSave) do
            saveKeyCount = saveKeyCount + 1
        end
        local lines: { string } = {
            "Module: loaded",
            ("Keys in upgrades save: %d"):format(saveKeyCount),
        }
        local enums = upgradeServiceUtils.enums
        if type(enums) == "table" and type(enums.levelBasedUpgrades) == "table" then
            local statCount = 0
            for _ in pairs(enums.levelBasedUpgrades) do
                statCount = statCount + 1
            end
            table.insert(lines, ("Level-based stat tables: %d"):format(statCount))
        end
        return table.concat(lines, "\n")
    end

    function buildUpgradeLuckRollsParagraphBody(): string
        if not tryLoadUpgradeServiceUtils() then
            return upgradeUtilsLoadError or "UpgradeServiceUtils not loaded."
        end
        local enums = upgradeServiceUtils.enums
        local luckRolls = enums and enums.luckRolls
        if type(luckRolls) ~= "table" then
            return "enums.luckRolls not available."
        end
        local lines: { string } = {}
        for _, kind in ipairs(UPGRADE_LUCK_ROLL_KINDS) do
            local cadence = luckRolls[kind]
            if type(cadence) == "table" then
                table.insert(
                    lines,
                    ("%s: every %s / %s / %s rolls (tiers 1–3)"):format(
                        kind:sub(1, 1):upper() .. kind:sub(2),
                        tostring(cadence[1] or "?"),
                        tostring(cadence[2] or "?"),
                        tostring(cadence[3] or "?")
                    )
                )
            end
        end
        if #lines == 0 then
            return "No luck roll cadence data."
        end
        return table.concat(lines, "\n")
    end

    function buildUpgradeOwnedParagraphBody(): string
        local keys: { string } = {}
        for id, owned in pairs(playerUpgradesSave) do
            if owned == true then
                table.insert(keys, id)
            end
        end
        table.sort(keys)
        if #keys == 0 then
            if next(playerUpgradesSave) == nil then
                return 'No upgrades save yet. Listen for DataService (1, "upgrades", …) or open the upgrades UI in-game.'
            end
            return "No upgrade flags set to true in save table."
        end
        local lines: { string } = { ("Total owned: %d"):format(#keys) }
        local show = math.min(#keys, UPGRADE_OWNED_DISPLAY_MAX)
        for i = 1, show do
            table.insert(lines, keys[i])
        end
        if #keys > show then
            table.insert(lines, ("… and %d more"):format(#keys - show))
        end
        return table.concat(lines, "\n")
    end

    function buildUpgradeStatsParagraphBody(): string
        if not tryLoadUpgradeServiceUtils() then
            return upgradeUtilsLoadError or "UpgradeServiceUtils not loaded."
        end
        local utils = upgradeServiceUtils
        local save = playerUpgradesSave
        local lines: { string } = {}

        for _, statKey in ipairs(UPGRADE_LEVEL_STAT_KEYS) do
            local lvl = utils.getUpgradeLevel(statKey, save)
            local val = utils.getUpgradeValue(statKey, lvl)
            if type(val) == "number" then
                if statKey == "extraRollChance" or statKey == "doubleGoop" or statKey == "goopDropRate" then
                    table.insert(lines, ("%s: level %d → %d%%"):format(statKey, lvl, math.round(val * 100)))
                elseif val >= 0.05 and val <= 50 and statKey ~= "magnetRadius" and statKey ~= "slimeGunRange" then
                    table.insert(
                        lines,
                        ("%s: level %d → %s (%s)"):format(statKey, lvl, tostring(val), formatUpgradePercentFromMultiplier(val))
                    )
                else
                    table.insert(lines, ("%s: level %d → %s"):format(statKey, lvl, tostring(val)))
                end
            end
        end

        if type(utils.getGoopDropRate) == "function" then
            table.insert(lines, ("goopDropRate (computed): %d%%"):format(math.round(utils.getGoopDropRate(save) * 100)))
        end
        if type(utils.getDoubleGoopChance) == "function" then
            table.insert(
                lines,
                ("doubleGoop (computed): %d%%"):format(math.round(utils.getDoubleGoopChance(save) * 100))
            )
        end

        table.insert(lines, "")
        table.insert(lines, "Mutations unlocked:")
        for _, kind in ipairs(UPGRADE_MUTATION_KINDS) do
            local unlocked = false
            if type(utils.isMutationUnlocked) == "function" then
                unlocked = utils.isMutationUnlocked(kind, save) == true
            end
            table.insert(lines, ("  %s: %s"):format(kind, unlocked and "yes" or "no"))
        end

        if type(utils.getUnlockedMutations) == "function" then
            local muts = utils.getUnlockedMutations(save)
            if type(muts) == "table" then
                local names: { string } = {}
                for name, on in pairs(muts) do
                    if on == true then
                        table.insert(names, tostring(name))
                    end
                end
                table.sort(names)
                if #names > 0 then
                    table.insert(lines, "  active: " .. table.concat(names, ", "))
                end
            end
        end

        return table.concat(lines, "\n")
    end

    function refreshUpgradeParagraphs()
        setUpgradeParagraph(UpgradeUtilsParagraph, "UpgradeServiceUtils", buildUpgradeUtilsParagraphBody())
        setUpgradeParagraph(UpgradeLuckRollsParagraph, "Luck roll cadence", buildUpgradeLuckRollsParagraphBody())
        setUpgradeParagraph(UpgradeOwnedParagraph, "Owned upgrades", buildUpgradeOwnedParagraphBody())
        setUpgradeParagraph(UpgradeStatsParagraph, "Computed stats", buildUpgradeStatsParagraphBody())
    end

    function runUpgradesSectionRefresh()
        tryLoadUpgradeServiceUtils()
        tryPullPlayerUpgradesFromDataService()
        tryPullSpecialRollProgressionFromDataService()
        refreshUpgradeParagraphs()
    end

    MainTab:CreateButton({
        Name = "Refresh upgrades",
        Flag = "main_upgrades_refresh",
        Callback = function()
            deferUiOnHeartbeat(runUpgradesSectionRefresh, "upgradesSectionRefresh")
        end,
    })

    deferUiOnHeartbeat(runUpgradesSectionRefresh, "upgradesSectionRefresh")

    mountItemsInventoryPageSection(MainTab, getDataServiceClient, cloneUpgradesTable)
end

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "slime" })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, { replicatedStorage = ReplicatedStorage })

-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, "sempatpanick/slime_rng/recordings")

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/slime_rng",
    rayfieldLibrary = RayfieldLibrary,
    gameLabel = "Slime RNG",
    onApplyFlag = function(flagName, saved)
        if flagName == "main_auto_feed_food_dropdown" and normalizeAutoFeedFoodConfigValue then
            return normalizeAutoFeedFoodConfigValue(saved)
        end
        return saved
    end,
    onApplyAfter = function(_data)
        if syncAutoFeedFoodAfterConfigLoad then
            task.defer(syncAutoFeedFoodAfterConfigLoad)
        end
    end,
})
