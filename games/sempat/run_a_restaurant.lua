local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local RunService = game:GetService("RunService")
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
            assert(okGet and type(source) == "string", "[sempat/run_a_restaurant] failed to load sempat_library")
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
    Name = "sempatpanick | Run a Restaurant",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Sempat UI • Run a Restaurant",
    ToggleUIKeybind = "K",
    WindowTransparency = 30,
    Icon = "https://dadang.id/sempatpanick-icon.png",
    ConfigurationSaving = {
        Enabled = true,
        AutoSave = false,
        AutoLoad = false,
        FolderName = "sempatpanick",
        FileName = "run_a_restaurant",
    },
})


-- */  Local Player Tab  /* --
createLocalPlayerTab(Window, mountNotify, { flagsPrefix = "lp", tabIcon = "user" })

-- */  Game helpers (Framework)  /* --
local LocalPlayer = Players.LocalPlayer
local CollectionService = game:GetService("CollectionService")

local KNOWN_CODES = { "FISHIES", "RAR4EVER" }

local MODULE_PATHS = {
    CurrencyCmds = { "Framework", "Client", "CurrencyCmds" },
    CodesCmds = { "Framework", "Client", "CodesCmds" },
    DailyLoginCmds = { "Framework", "Client", "DailyLoginCmds" },
    EffectsCmds = { "Framework", "Client", "EffectsCmds" },
    ClientFishing = { "Framework", "Client", "ClientFishing" },
    ClientRestaurant = { "Framework", "Client", "ClientRestaurant" },
    ClientFishingBox = { "Framework", "Client", "ClientEntity", "ClientFishingBox" },
    ClientCrop = { "Framework", "Client", "ClientEntity", "ClientCrop" },
    ClientFeeder = { "Framework", "Client", "ClientEntity", "ClientFeeder" },
    ClientAnimal = { "Framework", "Client", "ClientEntity", "ClientAnimal" },
    ClientMeatHouse = { "Framework", "Client", "ClientEntity", "ClientMeatHouse" },
    MerchantsCmds = { "Framework", "Client", "MerchantsCmds" },
    RecipeCmds = { "Framework", "Client", "RecipeCmds" },
    InventoryCmds = { "Framework", "Client", "InventoryCmds" },
    ShopCmds = { "Framework", "Client", "ShopCmds" },
    Network = { "Framework", "Client", "Network" },
    Saving = { "Framework", "Client", "Saving" },
    FishingTypes = { "Framework", "Types", "FishingTypes" },
    FishingRod = { "Framework", "Directory", "FishingRod" },
    Fish = { "Framework", "Directory", "Fish" },
    Currency = { "Framework", "Directory", "Currency" },
    Recipe = { "Framework", "Directory", "Recipe" },
    Effect = { "Framework", "Directory", "Effect" },
    Item = { "Framework", "Directory", "Item" },
    EntityPackage = { "Framework", "Directory", "EntityPackage" },
    InventoryUtil = { "Framework", "Universal", "InventoryUtil" },
    EntityUtil = { "Framework", "Universal", "EntityUtil" },
    ProgressionUtil = { "Framework", "Universal", "ProgressionUtil" },
    QuestsUtil = { "Framework", "Universal", "QuestsUtil" },
    QuestCmds = { "Framework", "Client", "QuestCmds" },
    GoalCmds = { "Framework", "Client", "GoalCmds" },
    StaffLevelingCmds = { "Framework", "Client", "StaffLevelingCmds" },
    StaffLevelingTypes = { "Framework", "Types", "StaffLevelingTypes" },
    PerkCmds = { "Framework", "Client", "PerkCmds" },
    ClientPet = { "Framework", "Client", "ClientPet" },
    ClientPetMerchant = { "Framework", "Client", "ClientPetMerchant" },
    PetTypes = { "Framework", "Types", "PetTypes" },
    Pet = { "Framework", "Directory", "Pet" },
    Product = { "Framework", "Directory", "Product" },
    Quest = { "Framework", "Directory", "Quest" },
    SkillsCmds = { "Framework", "Client", "SkillsCmds" },
    Skill = { "Framework", "Directory", "Skill" },
}

local moduleCache = {}

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
    local key = table.concat(pathParts, "/")
    if moduleCache[key] ~= nil then
        return moduleCache[key] or nil
    end
    local moduleScript = resolveModuleScript(pathParts)
    if not moduleScript then
        moduleCache[key] = false
        return nil
    end
    local ok, result = pcall(require, moduleScript)
    if ok then
        moduleCache[key] = result
        return result
    end
    moduleCache[key] = false
    return nil
end

local function getGameCtx()
    return {
        CurrencyCmds = tryRequirePath(MODULE_PATHS.CurrencyCmds),
        CodesCmds = tryRequirePath(MODULE_PATHS.CodesCmds),
        DailyLoginCmds = tryRequirePath(MODULE_PATHS.DailyLoginCmds),
        EffectsCmds = tryRequirePath(MODULE_PATHS.EffectsCmds),
        ClientFishing = tryRequirePath(MODULE_PATHS.ClientFishing),
        ClientRestaurant = tryRequirePath(MODULE_PATHS.ClientRestaurant),
        ClientFishingBox = tryRequirePath(MODULE_PATHS.ClientFishingBox),
        ClientCrop = tryRequirePath(MODULE_PATHS.ClientCrop),
        ClientFeeder = tryRequirePath(MODULE_PATHS.ClientFeeder),
        ClientAnimal = tryRequirePath(MODULE_PATHS.ClientAnimal),
        ClientMeatHouse = tryRequirePath(MODULE_PATHS.ClientMeatHouse),
        MerchantsCmds = tryRequirePath(MODULE_PATHS.MerchantsCmds),
        RecipeCmds = tryRequirePath(MODULE_PATHS.RecipeCmds),
        InventoryCmds = tryRequirePath(MODULE_PATHS.InventoryCmds),
        ShopCmds = tryRequirePath(MODULE_PATHS.ShopCmds),
        Network = tryRequirePath(MODULE_PATHS.Network),
        Saving = tryRequirePath(MODULE_PATHS.Saving),
        FishingTypes = tryRequirePath(MODULE_PATHS.FishingTypes),
        FishingRod = tryRequirePath(MODULE_PATHS.FishingRod),
        Fish = tryRequirePath(MODULE_PATHS.Fish),
        Currency = tryRequirePath(MODULE_PATHS.Currency),
        Recipe = tryRequirePath(MODULE_PATHS.Recipe),
        Effect = tryRequirePath(MODULE_PATHS.Effect),
        Item = tryRequirePath(MODULE_PATHS.Item),
        EntityPackage = tryRequirePath(MODULE_PATHS.EntityPackage),
        InventoryUtil = tryRequirePath(MODULE_PATHS.InventoryUtil),
        EntityUtil = tryRequirePath(MODULE_PATHS.EntityUtil),
        ProgressionUtil = tryRequirePath(MODULE_PATHS.ProgressionUtil),
        QuestsUtil = tryRequirePath(MODULE_PATHS.QuestsUtil),
        QuestCmds = tryRequirePath(MODULE_PATHS.QuestCmds),
        GoalCmds = tryRequirePath(MODULE_PATHS.GoalCmds),
        StaffLevelingCmds = tryRequirePath(MODULE_PATHS.StaffLevelingCmds),
        StaffLevelingTypes = tryRequirePath(MODULE_PATHS.StaffLevelingTypes),
        PerkCmds = tryRequirePath(MODULE_PATHS.PerkCmds),
        ClientPet = tryRequirePath(MODULE_PATHS.ClientPet),
        ClientPetMerchant = tryRequirePath(MODULE_PATHS.ClientPetMerchant),
        PetTypes = tryRequirePath(MODULE_PATHS.PetTypes),
        Pet = tryRequirePath(MODULE_PATHS.Pet),
        Product = tryRequirePath(MODULE_PATHS.Product),
        Quest = tryRequirePath(MODULE_PATHS.Quest),
        SkillsCmds = tryRequirePath(MODULE_PATHS.SkillsCmds),
        Skill = tryRequirePath(MODULE_PATHS.Skill),
    }
end

local function formatAmount(n)
    n = tonumber(n) or 0
    local abs = math.abs(n)
    if abs >= 1e12 then
        return string.format("%.2fT", n / 1e12)
    elseif abs >= 1e9 then
        return string.format("%.2fB", n / 1e9)
    elseif abs >= 1e6 then
        return string.format("%.2fM", n / 1e6)
    elseif abs >= 1e3 then
        return string.format("%.2fK", n / 1e3)
    end
    return tostring(math.floor(n + 0.5))
end

local function getLocalRestaurant(ctx)
    ctx = ctx or getGameCtx()
    local ClientRestaurant = ctx.ClientRestaurant
    if not ClientRestaurant or type(ClientRestaurant.GetLocal) ~= "function" then
        return nil
    end
    local ok, rest = pcall(function()
        return ClientRestaurant.GetLocal()
    end)
    if ok then
        return rest
    end
    return nil
end

local function collectLocalSubclass(rest, subclassName)
    if not rest or type(rest.CollectSubclass) ~= "function" then
        return {}
    end
    local ok, list = pcall(function()
        return rest:CollectSubclass(subclassName)
    end)
    if not ok or type(list) ~= "table" then
        return {}
    end
    local out = {}
    for _, entity in ipairs(list) do
        local isLocal = true
        if type(entity.IsLocal) == "function" then
            local okLocal, result = pcall(function()
                return entity:IsLocal()
            end)
            isLocal = okLocal and result == true
        end
        if isLocal then
            table.insert(out, entity)
        end
    end
    return out
end

local function safeInvokeEntity(entity, methodName, ...)
    if not entity or type(entity.Invoke) ~= "function" then
        return false, "No Invoke"
    end
    local args = table.pack(...)
    local ok, a, b = pcall(function()
        return entity:Invoke(methodName, table.unpack(args, 1, args.n))
    end)
    if not ok then
        return false, tostring(a)
    end
    return a, b
end

local function safeFireEntity(entity, methodName, ...)
    if not entity or type(entity.Fire) ~= "function" then
        return false, "No Fire"
    end
    local args = table.pack(...)
    local ok, err = pcall(function()
        entity:Fire(methodName, table.unpack(args, 1, args.n))
    end)
    if not ok then
        return false, tostring(err)
    end
    return true
end

local function networkFire(remoteName, ...)
    local Network = tryRequirePath(MODULE_PATHS.Network)
    if not Network or type(Network.Fire) ~= "function" then
        return false, "Network not loaded"
    end
    local args = table.pack(...)
    local ok, err = pcall(function()
        Network.Fire(remoteName, table.unpack(args, 1, args.n))
    end)
    if not ok then
        return false, tostring(err)
    end
    return true
end

local function networkInvoke(remoteName, ...)
    local Network = tryRequirePath(MODULE_PATHS.Network)
    if not Network or type(Network.Invoke) ~= "function" then
        return false, "Network not loaded"
    end
    local args = table.pack(...)
    local ok, a, b = pcall(function()
        return Network.Invoke(remoteName, table.unpack(args, 1, args.n))
    end)
    if not ok then
        return false, tostring(a)
    end
    return a, b
end

local function inventoryCount(ctx, itemId)
    if not ctx or not ctx.Item or not ctx.InventoryCmds or type(ctx.InventoryCmds.Count) ~= "function" then
        return 0
    end
    local dir = ctx.Item[itemId]
    if not dir then
        return 0
    end
    local ok, n = pcall(function()
        return ctx.InventoryCmds.Count(dir)
    end)
    return (ok and tonumber(n)) or 0
end

local function getCharacterRoot()
    local character = LocalPlayer.Character
    if not character then
        return nil
    end
    return character:FindFirstChild("HumanoidRootPart")
end

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", "wallet")

    local infoParagraph
    local effectsParagraph
    local autoSellRunning = false
    local autoSellLoopId = 0
    local autoSellDelaySec = 2
    local autoClaimDailyRunning = false
    local autoClaimDailyLoopId = 0
    local autoClaimDailyDelaySec = 5

    local function buildCurrencyInfo(ctx)
        local CurrencyCmds = ctx.CurrencyCmds
        if not CurrencyCmds or type(CurrencyCmds.Get) ~= "function" then
            return "CurrencyCmds not loaded."
        end
        local cash = CurrencyCmds.Get("Cash") or 0
        local diamonds = CurrencyCmds.Get("Diamonds") or 0
        local lines = {
            "Cash: $" .. formatAmount(cash),
            "Diamonds: " .. formatAmount(diamonds),
        }
        local Currency = ctx.Currency
        if type(Currency) == "table" then
            local extras = {}
            for id, dir in pairs(Currency) do
                if type(id) == "string" and id ~= "Cash" and id ~= "Diamonds" and type(dir) == "table" then
                    local amount = CurrencyCmds.Get(id) or 0
                    if amount > 0 then
                        table.insert(extras, { id = id, amount = amount })
                    end
                end
            end
            table.sort(extras, function(a, b)
                return a.amount > b.amount
            end)
            for i = 1, math.min(8, #extras) do
                table.insert(lines, extras[i].id .. ": " .. formatAmount(extras[i].amount))
            end
            if #extras > 8 then
                table.insert(lines, "... +" .. (#extras - 8) .. " more")
            end
        end
        local DailyLoginCmds = ctx.DailyLoginCmds
        if DailyLoginCmds then
            local streak = type(DailyLoginCmds.GetStreak) == "function" and DailyLoginCmds.GetStreak() or "?"
            local nextDay = type(DailyLoginCmds.GetNextClaimableDay) == "function" and DailyLoginCmds.GetNextClaimableDay() or nil
            table.insert(lines, "Login streak: " .. tostring(streak))
            table.insert(lines, "Daily claimable: " .. (nextDay and ("day " .. tostring(nextDay)) or "none"))
        end
        return table.concat(lines, "\n")
    end

    local function buildEffectsInfo(ctx)
        local EffectsCmds = ctx.EffectsCmds
        if not EffectsCmds or type(EffectsCmds.GetEffects) ~= "function" then
            return "EffectsCmds not loaded."
        end
        local effects = EffectsCmds.GetEffects()
        if type(effects) ~= "table" then
            return "No active effects."
        end
        local lines = {}
        for effectId, _ in pairs(effects) do
            local power = type(EffectsCmds.GetPower) == "function" and EffectsCmds.GetPower(effectId) or 0
            local uses = type(EffectsCmds.GetUses) == "function" and EffectsCmds.GetUses(effectId) or 0
            if power > 0 or uses > 0 then
                table.insert(lines, string.format("%s  power=%s  uses=%s", tostring(effectId), tostring(power), tostring(uses)))
            end
        end
        table.sort(lines)
        if #lines == 0 then
            return "No active boosts/bait."
        end
        return table.concat(lines, "\n")
    end

    local function refreshMainInfo()
        local ctx = getGameCtx()
        if infoParagraph then
            infoParagraph:Set({ Title = "Balances", Content = buildCurrencyInfo(ctx) })
        end
        if effectsParagraph then
            effectsParagraph:Set({ Title = "Boosts / Bait", Content = buildEffectsInfo(ctx) })
        end
    end

    MainTab:CreateSection("Status")
    infoParagraph = MainTab:CreateParagraph({
        Title = "Balances",
        Content = "Loading...",
    })
    effectsParagraph = MainTab:CreateParagraph({
        Title = "Boosts / Bait",
        Content = "Loading...",
    })
    MainTab:CreateButton({
        Name = "Refresh Info",
        Callback = function()
            refreshMainInfo()
            mountNotify({ Title = "Main", Content = "Refreshed" })
        end,
    })

    local codeInputValue = ""

    MainTab:CreateSection("Codes")
    MainTab:CreateInput({
        Name = "Code",
        CurrentValue = "",
        PlaceholderText = "Enter code",
        Flag = "rar_code_input",
        Callback = function(value)
            if type(value) == "table" then
                value = value[1]
            end
            codeInputValue = tostring(value or "")
        end,
    })
    MainTab:CreateButton({
        Name = "Redeem Code",
        Callback = function()
            local ctx = getGameCtx()
            if not ctx.CodesCmds or type(ctx.CodesCmds.Redeem) ~= "function" then
                mountNotify({ Title = "Codes", Content = "CodesCmds not loaded" })
                return
            end
            local code = tostring(codeInputValue or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if code == "" then
                mountNotify({ Title = "Codes", Content = "Enter a code first" })
                return
            end
            local ok, success, err = pcall(function()
                return ctx.CodesCmds.Redeem(code)
            end)
            if not ok then
                mountNotify({ Title = "Codes", Content = tostring(success) })
                return
            end
            if success then
                mountNotify({ Title = "Codes", Content = "Redeemed: " .. code })
                refreshMainInfo()
            else
                mountNotify({ Title = "Codes", Content = tostring(err or "Invalid code") })
            end
        end,
    })
    MainTab:CreateButton({
        Name = "Redeem Known Codes",
        Callback = function()
            local ctx = getGameCtx()
            if not ctx.CodesCmds or type(ctx.CodesCmds.Redeem) ~= "function" then
                mountNotify({ Title = "Codes", Content = "CodesCmds not loaded" })
                return
            end
            local redeemed = 0
            for _, code in ipairs(KNOWN_CODES) do
                local ok, success = pcall(function()
                    return ctx.CodesCmds.Redeem(code)
                end)
                if ok and success then
                    redeemed += 1
                end
                task.wait(0.35)
            end
            mountNotify({ Title = "Codes", Content = "Redeemed " .. redeemed .. "/" .. #KNOWN_CODES })
            refreshMainInfo()
        end,
    })

    MainTab:CreateSection("Daily Login")
    MainTab:CreateButton({
        Name = "Claim Daily Once",
        Callback = function()
            local ctx = getGameCtx()
            local DailyLoginCmds = ctx.DailyLoginCmds
            if not DailyLoginCmds or type(DailyLoginCmds.Claim) ~= "function" then
                mountNotify({ Title = "Daily", Content = "DailyLoginCmds not loaded" })
                return
            end
            local day = DailyLoginCmds.GetNextClaimableDay and DailyLoginCmds.GetNextClaimableDay()
            if not day then
                mountNotify({ Title = "Daily", Content = "Nothing to claim" })
                return
            end
            local ok, success, err = pcall(function()
                return DailyLoginCmds.Claim(day)
            end)
            if ok and success then
                mountNotify({ Title = "Daily", Content = "Claimed day " .. tostring(day) })
                refreshMainInfo()
            else
                mountNotify({ Title = "Daily", Content = tostring(err or success or "Claim failed") })
            end
        end,
    })
    MainTab:CreateToggle({
        Name = "Auto Claim Daily",
        CurrentValue = false,
        Flag = "rar_auto_claim_daily",
        Callback = function(value)
            autoClaimDailyRunning = value == true
            autoClaimDailyLoopId += 1
            local loopId = autoClaimDailyLoopId
            if not autoClaimDailyRunning then
                return
            end
            task.spawn(function()
                while autoClaimDailyRunning and loopId == autoClaimDailyLoopId do
                    local ctx = getGameCtx()
                    local DailyLoginCmds = ctx.DailyLoginCmds
                    if DailyLoginCmds and type(DailyLoginCmds.GetNextClaimableDay) == "function" then
                        local day = DailyLoginCmds.GetNextClaimableDay()
                        if day and type(DailyLoginCmds.Claim) == "function" then
                            pcall(function()
                                DailyLoginCmds.Claim(day)
                            end)
                            refreshMainInfo()
                        end
                    end
                    task.wait(autoClaimDailyDelaySec)
                end
            end)
        end,
    })

    MainTab:CreateSection("Sell")
    MainTab:CreateButton({
        Name = "Sell All Currency",
        Callback = function()
            local ctx = getGameCtx()
            if not ctx.CurrencyCmds or type(ctx.CurrencyCmds.SellAll) ~= "function" then
                mountNotify({ Title = "Sell", Content = "CurrencyCmds not loaded" })
                return
            end
            local ok, success, err = pcall(function()
                return ctx.CurrencyCmds.SellAll()
            end)
            if ok and success then
                mountNotify({ Title = "Sell", Content = "Sold currencies" })
                refreshMainInfo()
            else
                mountNotify({ Title = "Sell", Content = tostring(err or success or "Sell failed") })
            end
        end,
    })
    MainTab:CreateInput({
        Name = "Auto Sell Delay (s)",
        CurrentValue = "2",
        Flag = "rar_auto_sell_delay",
        Callback = function(value)
            local n = tonumber(type(value) == "table" and value[1] or value)
            if n and n > 0.2 then
                autoSellDelaySec = n
            end
        end,
    })
    MainTab:CreateToggle({
        Name = "Auto Sell Currency",
        CurrentValue = false,
        Flag = "rar_auto_sell_currency",
        Callback = function(value)
            autoSellRunning = value == true
            autoSellLoopId += 1
            local loopId = autoSellLoopId
            if not autoSellRunning then
                return
            end
            task.spawn(function()
                while autoSellRunning and loopId == autoSellLoopId do
                    local ctx = getGameCtx()
                    if ctx.CurrencyCmds and type(ctx.CurrencyCmds.HasNonCashCurrency) == "function" then
                        local has = false
                        pcall(function()
                            has = ctx.CurrencyCmds.HasNonCashCurrency()
                        end)
                        if has and type(ctx.CurrencyCmds.SellAll) == "function" then
                            pcall(function()
                                ctx.CurrencyCmds.SellAll()
                            end)
                        end
                    end
                    task.wait(autoSellDelaySec)
                end
            end)
        end,
    })

    task.spawn(function()
        task.wait(1)
        refreshMainInfo()
        while task.wait(3) do
            if infoParagraph then
                refreshMainInfo()
            end
        end
    end)
end

-- */  Fishing Tab  /* --
do
    local FishingTab = Window:CreateTab("Fishing", "fish")

    local fishingInfoParagraph
    local autoFishRunning = false
    local autoFishLoopId = 0
    local autoFishDelaySec = 0.75
    local autoReelEnabled = true
    local autoBuyBaitRunning = false
    local autoBuyBaitLoopId = 0
    local autoBuyBaitDelaySec = 8
    local sessionReelHooked = false

    local function hasFishingBoxSpace(ctx, rest)
        if not rest or not ctx.ClientFishingBox then
            return true
        end
        local boxes = collectLocalSubclass(rest, "FishingBox")
        if #boxes == 0 then
            return true
        end
        for _, box in ipairs(boxes) do
            local capacity = 0
            local count = 0
            local reserved = 0
            pcall(function()
                capacity = ctx.ClientFishingBox.GetCapacity(box) or 0
                count = ctx.ClientFishingBox.GetCount(box) or 0
                reserved = box:GetSession("ReservedCount") or 0
            end)
            if capacity - count - reserved > 0 then
                return true
            end
        end
        return false
    end

    local function findForwardCastPoint(ctx)
        local FishingTypes = ctx.FishingTypes
        if not FishingTypes or type(FishingTypes.FindWaterCast) ~= "function" then
            return nil
        end
        local root = getCharacterRoot()
        local camera = Workspace.CurrentCamera
        if not (root and camera) then
            return nil
        end
        local look = camera.CFrame.LookVector
        local flat = Vector3.new(look.X, 0, look.Z)
        if flat.Magnitude < 0.001 then
            return nil
        end
        flat = flat.Unit
        local maxDist = FishingTypes.PlayerCastDistance or 40
        local probe = FishingTypes.WaterProbeHeight or 25
        for dist = 6, maxDist, 2 do
            local origin = root.Position + flat * dist + Vector3.new(0, probe, 0)
            local hit = FishingTypes.FindWaterCast(origin, Vector3.new(0, -1, 0))
            if hit and (root.Position - hit).Magnitude <= maxDist then
                return hit
            end
        end
        local best, bestDist = nil, math.huge
        for _, part in ipairs(CollectionService:GetTagged("FishingWater")) do
            if part:IsA("BasePart") then
                local top = part.Position + Vector3.new(0, part.Size.Y / 2, 0)
                local d = (root.Position - top).Magnitude
                if d < bestDist and d <= maxDist then
                    bestDist = d
                    best = top
                end
            end
        end
        return best
    end

    local function equipBestRod(ctx)
        local ClientFishing = ctx.ClientFishing
        local FishingRod = ctx.FishingRod
        local FishingTypes = ctx.FishingTypes
        local InventoryCmds = ctx.InventoryCmds
        if not (ClientFishing and FishingRod and FishingTypes and InventoryCmds) then
            return false
        end
        if type(ClientFishing.GetRod) == "function" then
            local current = nil
            pcall(function()
                current = ClientFishing.GetRod()
            end)
            if current then
                return true
            end
        end
        local candidates = {}
        for id, rod in pairs(FishingRod) do
            if type(id) == "string" and type(rod) == "table" then
                local item = nil
                pcall(function()
                    item = FishingTypes.ItemFromRod(rod)
                end)
                local owned = false
                if item and type(InventoryCmds.Has) == "function" then
                    pcall(function()
                        owned = InventoryCmds.Has(LocalPlayer, item, 1) == true
                    end)
                    if not owned and type(InventoryCmds.Count) == "function" then
                        pcall(function()
                            owned = (InventoryCmds.Count(item) or 0) > 0
                        end)
                    end
                end
                if owned or rod == FishingTypes.StartingRod or id == "Basic Fishing Rod" then
                    table.insert(candidates, rod)
                end
            end
        end
        if #candidates == 0 and FishingTypes.StartingRod then
            table.insert(candidates, FishingTypes.StartingRod)
        end
        local best = candidates[1]
        if not best then
            return false
        end
        -- Prefer higher rarity / name order as weak heuristic: Carbon Fiber / Golden last alphabetically often better
        table.sort(candidates, function(a, b)
            local an = tostring(a._id or a.Name or "")
            local bn = tostring(b._id or b.Name or "")
            return an > bn
        end)
        best = candidates[1]
        local rodId = best._id or best.Name
        if type(ClientFishing.Equip) == "function" and rodId then
            local ok = pcall(function()
                ClientFishing.Equip(rodId)
            end)
            return ok
        end
        return false
    end

    local function scheduleReelFromSession(ctx, session)
        if not autoReelEnabled or not autoFishRunning then
            return
        end
        if not session or session.Player ~= LocalPlayer then
            return
        end
        local ClientFishing = ctx.ClientFishing
        if not ClientFishing or type(ClientFishing.Reel) ~= "function" then
            return
        end
        local windows = session.BobberWindows
        local duration = session.BobberDuration or 0.75
        local now = Workspace:GetServerTimeNow()
        local waitSec = nil
        if type(windows) == "table" then
            for _, windowStart in ipairs(windows) do
                if type(windowStart) == "number" and windowStart + duration > now then
                    local w = math.max(0, windowStart - now) + 0.08
                    if not waitSec or w < waitSec then
                        waitSec = w
                    end
                end
            end
        end
        if not waitSec then
            waitSec = 5.25
        end
        task.delay(waitSec, function()
            if autoFishRunning and autoReelEnabled then
                pcall(function()
                    ClientFishing.Reel()
                end)
            end
        end)
    end

    local function ensureSessionHook(ctx)
        if sessionReelHooked then
            return
        end
        local ClientFishing = ctx.ClientFishing
        if not ClientFishing or not ClientFishing.SessionStarted then
            return
        end
        local ok = pcall(function()
            ClientFishing.SessionStarted:Connect(function(session)
                scheduleReelFromSession(getGameCtx(), session)
            end)
        end)
        sessionReelHooked = ok
    end

    local function buildFishingInfo(ctx)
        local lines = {}
        local rest = getLocalRestaurant(ctx)
        if not rest then
            table.insert(lines, "Restaurant: waiting...")
        else
            table.insert(lines, "Restaurant: ready")
            local boxes = collectLocalSubclass(rest, "FishingBox")
            local fishers = collectLocalSubclass(rest, "Fisherman")
            local used, cap = 0, 0
            for _, box in ipairs(boxes) do
                pcall(function()
                    used += ctx.ClientFishingBox and ctx.ClientFishingBox.GetCount(box) or 0
                    cap += ctx.ClientFishingBox and ctx.ClientFishingBox.GetCapacity(box) or 0
                end)
            end
            table.insert(lines, string.format("Fish boxes: %d  (%s/%s)", #boxes, formatAmount(used), formatAmount(cap)))
            table.insert(lines, "Fishermen: " .. #fishers)
            table.insert(lines, "Box space: " .. (hasFishingBoxSpace(ctx, rest) and "yes" or "full"))
        end
        if ctx.ClientFishing and type(ctx.ClientFishing.GetRod) == "function" then
            local rod = nil
            pcall(function()
                rod = ctx.ClientFishing.GetRod()
            end)
            table.insert(lines, "Rod: " .. (rod and tostring(rod._id or rod.Name or "equipped") or "none"))
        end
        if ctx.CurrencyCmds then
            for _, fishId in ipairs({ "Cod", "Salmon", "Tuna", "Shrimp", "Lobster" }) do
                local amount = 0
                pcall(function()
                    amount = ctx.CurrencyCmds.Get(fishId) or 0
                end)
                if amount > 0 then
                    table.insert(lines, fishId .. ": " .. formatAmount(amount))
                end
            end
        end
        return table.concat(lines, "\n")
    end

    local function refreshFishingInfo()
        if fishingInfoParagraph then
            fishingInfoParagraph:Set({ Title = "Fishing Status", Content = buildFishingInfo(getGameCtx()) })
        end
    end

    local function tryCastOnce()
        local ctx = getGameCtx()
        ensureSessionHook(ctx)
        local ClientFishing = ctx.ClientFishing
        if not ClientFishing or type(ClientFishing.Begin) ~= "function" then
            return false, "ClientFishing missing"
        end
        local rest = getLocalRestaurant(ctx)
        if not hasFishingBoxSpace(ctx, rest) then
            return false, "Fish box full"
        end
        equipBestRod(ctx)
        local point = findForwardCastPoint(ctx)
        if not point then
            return false, "No water in range"
        end
        pcall(function()
            if type(ClientFishing.Cancel) == "function" then
                ClientFishing.Cancel()
            end
        end)
        local ok, success, err = pcall(function()
            return ClientFishing.Begin(CFrame.new(point))
        end)
        if not ok then
            return false, tostring(success)
        end
        if success == false then
            return false, tostring(err or "Cast failed")
        end
        return true
    end

    FishingTab:CreateSection("Status")
    fishingInfoParagraph = FishingTab:CreateParagraph({
        Title = "Fishing Status",
        Content = "Loading...",
    })
    FishingTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshFishingInfo()
        end,
    })

    FishingTab:CreateSection("Auto Fish")
    FishingTab:CreateInput({
        Name = "Cast Delay (s)",
        CurrentValue = "0.75",
        Flag = "rar_auto_fish_delay",
        Callback = function(value)
            local n = tonumber(type(value) == "table" and value[1] or value)
            if n and n >= 0.2 then
                autoFishDelaySec = n
            end
        end,
    })
    FishingTab:CreateToggle({
        Name = "Auto Reel",
        CurrentValue = true,
        Flag = "rar_auto_reel",
        Callback = function(value)
            autoReelEnabled = value == true
            ensureSessionHook(getGameCtx())
        end,
    })
    FishingTab:CreateToggle({
        Name = "Auto Fish",
        CurrentValue = false,
        Flag = "rar_auto_fish",
        Callback = function(value)
            autoFishRunning = value == true
            autoFishLoopId += 1
            local loopId = autoFishLoopId
            ensureSessionHook(getGameCtx())
            if not autoFishRunning then
                return
            end
            task.spawn(function()
                while autoFishRunning and loopId == autoFishLoopId do
                    tryCastOnce()
                    refreshFishingInfo()
                    task.wait(autoFishDelaySec)
                end
            end)
        end,
    })
    FishingTab:CreateButton({
        Name = "Cast Once",
        Callback = function()
            ensureSessionHook(getGameCtx())
            local ok, err = tryCastOnce()
            mountNotify({ Title = "Fishing", Content = ok and "Casted" or tostring(err or "Failed") })
            refreshFishingInfo()
        end,
    })
    FishingTab:CreateButton({
        Name = "Reel Once",
        Callback = function()
            local ctx = getGameCtx()
            if not ctx.ClientFishing or type(ctx.ClientFishing.Reel) ~= "function" then
                mountNotify({ Title = "Fishing", Content = "ClientFishing missing" })
                return
            end
            pcall(function()
                ctx.ClientFishing.Reel()
            end)
        end,
    })
    FishingTab:CreateButton({
        Name = "Equip Best Rod",
        Callback = function()
            local ok = equipBestRod(getGameCtx())
            mountNotify({ Title = "Fishing", Content = ok and "Rod equipped" or "Could not equip rod" })
            refreshFishingInfo()
        end,
    })

    FishingTab:CreateSection("Bait Merchant")
    FishingTab:CreateButton({
        Name = "Buy Best Available Bait",
        Callback = function()
            local ctx = getGameCtx()
            if not ctx.MerchantsCmds or type(ctx.MerchantsCmds.GetState) ~= "function" then
                mountNotify({ Title = "Bait", Content = "MerchantsCmds not loaded" })
                return
            end
            local state = nil
            pcall(function()
                state = ctx.MerchantsCmds.GetState("Bait Merchant")
            end)
            local offers = state and state.Roll and state.Roll.Offers
            if type(state) ~= "table" or type(offers) ~= "table" or #offers == 0 then
                mountNotify({ Title = "Bait", Content = "No bait offers" })
                return
            end
            local bestOffer, bestRank = nil, -1
            local rankByName = {
                ["Premium Bait"] = 4,
                ["Rare Bait"] = 3,
                ["Uncommon Bait"] = 2,
                ["Common Bait"] = 1,
            }
            for _, offer in ipairs(offers) do
                if type(offer) == "table" and offer.Id then
                    local purchases = (state.Purchases and state.Purchases[offer.Id]) or 0
                    local qty = (offer.Quantity or 0) - purchases
                    if qty > 0 then
                        local rank = rankByName[tostring(offer.Id)] or 0
                        if rank >= bestRank then
                            bestRank = rank
                            bestOffer = offer
                        end
                    end
                end
            end
            if not bestOffer then
                mountNotify({ Title = "Bait", Content = "No stock left" })
                return
            end
            local ok, success, err = pcall(function()
                return ctx.MerchantsCmds.Purchase("Bait Merchant", bestOffer.Id, 1)
            end)
            if ok and success then
                mountNotify({ Title = "Bait", Content = "Bought " .. tostring(bestOffer.Id) })
            else
                mountNotify({ Title = "Bait", Content = tostring(err or success or "Purchase failed") })
            end
        end,
    })
    FishingTab:CreateToggle({
        Name = "Auto Buy Bait",
        CurrentValue = false,
        Flag = "rar_auto_buy_bait",
        Callback = function(value)
            autoBuyBaitRunning = value == true
            autoBuyBaitLoopId += 1
            local loopId = autoBuyBaitLoopId
            if not autoBuyBaitRunning then
                return
            end
            task.spawn(function()
                while autoBuyBaitRunning and loopId == autoBuyBaitLoopId do
                    local ctx = getGameCtx()
                    if ctx.MerchantsCmds and type(ctx.MerchantsCmds.GetState) == "function" then
                        local state = nil
                        pcall(function()
                            state = ctx.MerchantsCmds.GetState("Bait Merchant")
                        end)
                        local offers = state and state.Roll and state.Roll.Offers
                        if type(state) == "table" and type(offers) == "table" then
                            for _, offer in ipairs(offers) do
                                if type(offer) == "table" and offer.Id then
                                    local purchases = (state.Purchases and state.Purchases[offer.Id]) or 0
                                    local qty = (offer.Quantity or 0) - purchases
                                    if qty > 0 then
                                        pcall(function()
                                            ctx.MerchantsCmds.Purchase("Bait Merchant", offer.Id, 1)
                                        end)
                                        break
                                    end
                                end
                            end
                        end
                    end
                    task.wait(autoBuyBaitDelaySec)
                end
            end)
        end,
    })

    task.spawn(function()
        task.wait(1.2)
        refreshFishingInfo()
        while task.wait(3) do
            if fishingInfoParagraph then
                refreshFishingInfo()
            end
        end
    end)
end

-- */  Kitchen Tab  /* --
do
    local KitchenTab = Window:CreateTab("Kitchen", "chef-hat")

    local kitchenInfoParagraph
    local autoClaimCashRunning = false
    local autoClaimCashLoopId = 0
    local autoClaimCashDelaySec = 0.75
    local autoTakeDropsRunning = false
    local autoTakeDropsLoopId = 0
    local autoTakeDropsDelaySec = 0.75
    local autoEnableRecipesRunning = false
    local autoEnableRecipesLoopId = 0
    local autoCookRunning = false
    local autoCookLoopId = 0
    local autoCookDelaySec = 0.35
    local autoServeRunning = false
    local autoServeLoopId = 0
    local autoServeDelaySec = 0.35
    local autoWashRunning = false
    local autoWashLoopId = 0
    local autoWashDelaySec = 0.5

    local function buildKitchenInfo(ctx)
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return "Waiting for local restaurant..."
        end
        local cooks = collectLocalSubclass(rest, "Cook")
        local waiters = collectLocalSubclass(rest, "Waiter")
        local cleaners = collectLocalSubclass(rest, "Cleaner")
        local customers = collectLocalSubclass(rest, "Customer")
        local stoves = collectLocalSubclass(rest, "Stove")
        local registers = collectLocalSubclass(rest, "CashRegister")
        local tipJars = collectLocalSubclass(rest, "TipJar")
        local ground = collectLocalSubclass(rest, "GroundCurrency")
        local orderStands = collectLocalSubclass(rest, "OrderStand")

        local registerCash = 0
        for _, reg in ipairs(registers) do
            pcall(function()
                registerCash += (reg:GetSave("Cash") or 0) + (reg:GetSave("CashOffline") or 0)
            end)
        end
        local tipCash = 0
        for _, jar in ipairs(tipJars) do
            pcall(function()
                tipCash += jar:GetSave("Cash") or 0
            end)
        end

        local pendingOrders, readyOrders = 0, 0
        for _, stand in ipairs(orderStands) do
            pcall(function()
                local orderList = stand:GetSession("OrderList")
                local readyList = stand:GetSession("ReadyList")
                if type(orderList) == "table" then
                    pendingOrders += #orderList
                end
                if type(readyList) == "table" then
                    readyOrders += #readyList
                end
            end)
        end

        local targetStove = LocalPlayer:GetAttribute("TargetStoveId")
        local targetCustomer = LocalPlayer:GetAttribute("TargetCustomerId")
        local targetDishwasher = LocalPlayer:GetAttribute("TargetDishwasherId")
        local holdingDirty = LocalPlayer:GetAttribute("HoldingDirtyDish") == true
        local holdingRecipe = LocalPlayer:GetAttribute("TargetCustomerRecipeId")

        local dirtySeats = 0
        for _, seat in ipairs(collectLocalSubclass(rest, "Seat")) do
            local dirty = nil
            pcall(function()
                dirty = seat:GetSession("DirtyDish")
            end)
            if dirty then
                dirtySeats += 1
            end
        end
        local dishwashers = collectLocalSubclass(rest, "Dishwasher")

        local recipeDisabled = 0
        local recipeTotal = 0
        if ctx.Recipe and ctx.RecipeCmds then
            for id, _ in pairs(ctx.Recipe) do
                if type(id) == "string" then
                    recipeTotal += 1
                    local disabled = false
                    pcall(function()
                        disabled = ctx.RecipeCmds.IsDisabled(id) == true
                    end)
                    if disabled then
                        recipeDisabled += 1
                    end
                end
            end
        end

        return table.concat({
            "Cooks: " .. #cooks,
            "Waiters: " .. #waiters,
            "Cleaners: " .. #cleaners,
            "Customers: " .. #customers,
            "Stoves: " .. #stoves,
            "Order stands: " .. #orderStands,
            "Pending tickets: " .. pendingOrders,
            "Ready plates: " .. readyOrders,
            "Dirty seats: " .. dirtySeats,
            "Dishwashers/sinks: " .. #dishwashers,
            "Target stove: " .. (targetStove and tostring(targetStove) or "none"),
            "Holding recipe: " .. (holdingRecipe and tostring(holdingRecipe) or "none"),
            "Target customer: " .. (targetCustomer and tostring(targetCustomer) or "none"),
            "Holding dirty dish: " .. (holdingDirty and "yes" or "no"),
            "Target dishwasher: " .. (targetDishwasher and tostring(targetDishwasher) or "none"),
            "Registers: " .. #registers .. "  cash=" .. formatAmount(registerCash),
            "Tip jars: " .. #tipJars .. "  cash=" .. formatAmount(tipCash),
            "Ground drops: " .. #ground,
            "Recipes disabled: " .. recipeDisabled .. "/" .. recipeTotal,
        }, "\n")
    end

    local function refreshKitchenInfo()
        if kitchenInfoParagraph then
            kitchenInfoParagraph:Set({ Title = "Kitchen Status", Content = buildKitchenInfo(getGameCtx()) })
        end
    end

    local function claimRegistersAndTips()
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return 0
        end
        local claimed = 0
        for _, reg in ipairs(collectLocalSubclass(rest, "CashRegister")) do
            local cash = 0
            pcall(function()
                cash = (reg:GetSave("Cash") or 0) + (reg:GetSave("CashOffline") or 0)
            end)
            if cash > 0 then
                local ok = safeInvokeEntity(reg, "CashRegisterClaim")
                if ok then
                    claimed += 1
                end
            end
        end
        for _, jar in ipairs(collectLocalSubclass(rest, "TipJar")) do
            local cash = 0
            pcall(function()
                cash = jar:GetSave("Cash") or 0
            end)
            if cash > 0 then
                local ok = safeInvokeEntity(jar, "TipJarClaim")
                if ok then
                    claimed += 1
                end
            end
        end
        return claimed
    end

    local function takeGroundDrops()
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return 0
        end
        local taken = 0
        for _, drop in ipairs(collectLocalSubclass(rest, "GroundCurrency")) do
            local ok = safeInvokeEntity(drop, "Take")
            if ok then
                taken += 1
            end
        end
        return taken
    end

    local function enableAllRecipes()
        local ctx = getGameCtx()
        if not ctx.Recipe or not ctx.RecipeCmds or type(ctx.RecipeCmds.ToggleEnabled) ~= "function" then
            return 0
        end
        local fixed = 0
        for id, _ in pairs(ctx.Recipe) do
            if type(id) == "string" then
                local disabled = false
                pcall(function()
                    disabled = ctx.RecipeCmds.IsDisabled(id) == true
                end)
                if disabled then
                    pcall(function()
                        ctx.RecipeCmds.ToggleEnabled(id)
                    end)
                    fixed += 1
                    task.wait(0.05)
                end
            end
        end
        return fixed
    end

    -- Player cook loop: TakeTicketPlayer -> ActivateStovePlayer
    local function tryAutoCookOnce()
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return false
        end

        local targetStoveId = LocalPlayer:GetAttribute("TargetStoveId")
        if targetStoveId then
            local stove = nil
            pcall(function()
                stove = rest:GetEntity(targetStoveId)
            end)
            if stove then
                local ok = safeInvokeEntity(stove, "ActivateStovePlayer")
                if ok then
                    return true
                end
            end
        end

        -- Grab next ticket from order stand if we aren't already cooking
        if not targetStoveId then
            for _, stand in ipairs(collectLocalSubclass(rest, "OrderStand")) do
                local orderList = nil
                pcall(function()
                    orderList = stand:GetSession("OrderList")
                end)
                if type(orderList) == "table" and #orderList > 0 and type(orderList[1]) == "table" then
                    local orderId = orderList[1][1]
                    if orderId ~= nil then
                        local ok = false
                        pcall(function()
                            ok = stand:Invoke("TakeTicketPlayer", orderId) == true
                        end)
                        if ok then
                            return true
                        end
                    end
                end
            end
        end

        -- Fallback: poke every stove (server rejects if not assigned)
        for _, stove in ipairs(collectLocalSubclass(rest, "Stove")) do
            local ok = safeInvokeEntity(stove, "ActivateStovePlayer")
            if ok then
                return true
            end
        end
        return false
    end

    -- Take ready plate + serve customer
    local function tryAutoServeOnce()
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return false
        end

        local targetCustomerId = LocalPlayer:GetAttribute("TargetCustomerId")
        local targetRecipeId = LocalPlayer:GetAttribute("TargetCustomerRecipeId")
        if targetCustomerId and targetRecipeId then
            local customer = nil
            pcall(function()
                customer = rest:GetEntity(targetCustomerId)
            end)
            if customer then
                local ok = safeInvokeEntity(customer, "PlaceDeliveryPlayer")
                if ok then
                    return true
                end
            end
        end

        if not targetRecipeId then
            for _, stand in ipairs(collectLocalSubclass(rest, "OrderStand")) do
                local readyList = nil
                pcall(function()
                    readyList = stand:GetSession("ReadyList")
                end)
                if type(readyList) == "table" and #readyList > 0 and type(readyList[1]) == "table" then
                    local readyId = readyList[1][1]
                    if readyId ~= nil then
                        local ok = false
                        pcall(function()
                            ok = stand:Invoke("TakeDeliveryPlayer", readyId) == true
                        end)
                        if ok then
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    local function tryAutoWashOnce()
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return false, "no restaurant"
        end

        -- Deposit first if already holding a dirty dish.
        -- Server assigns TargetDishwasherId after pickup (same as Player Dishwasher UI).
        if LocalPlayer:GetAttribute("HoldingDirtyDish") == true then
            local targetDishwasherId = LocalPlayer:GetAttribute("TargetDishwasherId")
            if targetDishwasherId then
                local washer = nil
                pcall(function()
                    washer = rest:GetEntity(targetDishwasherId)
                end)
                if washer then
                    local ok, err = safeInvokeEntity(washer, "DepositDishPlayer")
                    if ok then
                        return true, "deposited"
                    end
                    return false, tostring(err or "deposit failed")
                end
            end
            -- Fallback if attribute is late: try every dishwasher/sink.
            for _, washer in ipairs(collectLocalSubclass(rest, "Dishwasher")) do
                local ok = safeInvokeEntity(washer, "DepositDishPlayer")
                if ok then
                    return true, "deposited"
                end
            end
            return false, "holding dish, waiting for dishwasher"
        end

        -- Dirty plates are tracked on Seat entities (Customer Plates script), not Customer.
        local seats = collectLocalSubclass(rest, "Seat")
        for _, seat in ipairs(seats) do
            local dirty = nil
            pcall(function()
                dirty = seat:GetSession("DirtyDish")
            end)
            if dirty then
                local ok, err = safeInvokeEntity(seat, "TakeDirtyDishPlayer")
                if ok then
                    return true, "picked up"
                end
                -- Keep trying other seats; one may be out of range / claimed.
                if err and tostring(err) ~= "" then
                    -- continue
                end
            end
        end
        return false, "no dirty dishes"
    end

    KitchenTab:CreateSection("Status")
    kitchenInfoParagraph = KitchenTab:CreateParagraph({
        Title = "Kitchen Status",
        Content = "Loading...",
    })
    KitchenTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshKitchenInfo()
        end,
    })

    KitchenTab:CreateSection("Auto Cook / Serve")
    KitchenTab:CreateParagraph({
        Title = "How cooking works",
        Content = "1) Take ticket from Order Stand\n2) Activate stove (ActivateStovePlayer)\n3) Take ready plate + serve customer\nStaff cooks do this automatically if hired.",
    })
    KitchenTab:CreateInput({
        Name = "Cook Delay (s)",
        CurrentValue = "0.35",
        Flag = "rar_auto_cook_delay",
        Callback = function(value)
            local n = tonumber(type(value) == "table" and value[1] or value)
            if n and n >= 0.1 then
                autoCookDelaySec = n
            end
        end,
    })
    KitchenTab:CreateButton({
        Name = "Cook Once",
        Callback = function()
            local ok = tryAutoCookOnce()
            mountNotify({ Title = "Cook", Content = ok and "Cook action sent" or "Nothing to cook" })
            refreshKitchenInfo()
        end,
    })
    KitchenTab:CreateToggle({
        Name = "Auto Cook",
        CurrentValue = false,
        Flag = "rar_auto_cook",
        Callback = function(value)
            autoCookRunning = value == true
            autoCookLoopId += 1
            local loopId = autoCookLoopId
            if not autoCookRunning then
                return
            end
            task.spawn(function()
                while autoCookRunning and loopId == autoCookLoopId do
                    tryAutoCookOnce()
                    task.wait(autoCookDelaySec)
                end
            end)
        end,
    })
    KitchenTab:CreateToggle({
        Name = "Auto Serve",
        CurrentValue = false,
        Flag = "rar_auto_serve",
        Callback = function(value)
            autoServeRunning = value == true
            autoServeLoopId += 1
            local loopId = autoServeLoopId
            if not autoServeRunning then
                return
            end
            task.spawn(function()
                while autoServeRunning and loopId == autoServeLoopId do
                    tryAutoServeOnce()
                    task.wait(autoServeDelaySec)
                end
            end)
        end,
    })
    KitchenTab:CreateButton({
        Name = "Wash Once",
        Callback = function()
            local ok, detail = tryAutoWashOnce()
            mountNotify({
                Title = "Wash",
                Content = ok and tostring(detail or "ok") or tostring(detail or "nothing to wash"),
            })
            refreshKitchenInfo()
        end,
    })
    KitchenTab:CreateToggle({
        Name = "Auto Wash Dishes",
        CurrentValue = false,
        Flag = "rar_auto_wash",
        Callback = function(value)
            autoWashRunning = value == true
            autoWashLoopId += 1
            local loopId = autoWashLoopId
            if not autoWashRunning then
                return
            end
            task.spawn(function()
                while autoWashRunning and loopId == autoWashLoopId do
                    tryAutoWashOnce()
                    refreshKitchenInfo()
                    task.wait(autoWashDelaySec)
                end
            end)
        end,
    })

    KitchenTab:CreateSection("Collect")
    KitchenTab:CreateButton({
        Name = "Claim Registers + Tip Jars",
        Callback = function()
            local n = claimRegistersAndTips()
            mountNotify({ Title = "Kitchen", Content = "Claimed " .. n .. " source(s)" })
            refreshKitchenInfo()
        end,
    })
    KitchenTab:CreateToggle({
        Name = "Auto Claim Cash",
        CurrentValue = false,
        Flag = "rar_auto_claim_cash",
        Callback = function(value)
            autoClaimCashRunning = value == true
            autoClaimCashLoopId += 1
            local loopId = autoClaimCashLoopId
            if not autoClaimCashRunning then
                return
            end
            task.spawn(function()
                while autoClaimCashRunning and loopId == autoClaimCashLoopId do
                    claimRegistersAndTips()
                    task.wait(autoClaimCashDelaySec)
                end
            end)
        end,
    })
    KitchenTab:CreateButton({
        Name = "Take Ground Drops",
        Callback = function()
            local n = takeGroundDrops()
            mountNotify({ Title = "Kitchen", Content = "Took " .. n .. " drop(s)" })
            refreshKitchenInfo()
        end,
    })
    KitchenTab:CreateToggle({
        Name = "Auto Take Drops",
        CurrentValue = false,
        Flag = "rar_auto_take_drops",
        Callback = function(value)
            autoTakeDropsRunning = value == true
            autoTakeDropsLoopId += 1
            local loopId = autoTakeDropsLoopId
            if not autoTakeDropsRunning then
                return
            end
            task.spawn(function()
                while autoTakeDropsRunning and loopId == autoTakeDropsLoopId do
                    takeGroundDrops()
                    task.wait(autoTakeDropsDelaySec)
                end
            end)
        end,
    })

    KitchenTab:CreateSection("Recipes")
    KitchenTab:CreateButton({
        Name = "Enable All Recipes",
        Callback = function()
            local n = enableAllRecipes()
            mountNotify({ Title = "Recipes", Content = "Enabled " .. n .. " recipe(s)" })
            refreshKitchenInfo()
        end,
    })
    KitchenTab:CreateToggle({
        Name = "Keep Recipes Enabled",
        CurrentValue = false,
        Flag = "rar_auto_enable_recipes",
        Callback = function(value)
            autoEnableRecipesRunning = value == true
            autoEnableRecipesLoopId += 1
            local loopId = autoEnableRecipesLoopId
            if not autoEnableRecipesRunning then
                return
            end
            task.spawn(function()
                while autoEnableRecipesRunning and loopId == autoEnableRecipesLoopId do
                    enableAllRecipes()
                    task.wait(5)
                end
            end)
        end,
    })

    KitchenTab:CreateSection("Note")
    KitchenTab:CreateParagraph({
        Title = "Staff vs player",
        Content = "Hired cooks/waiters/cleaners run the kitchen on the server. Auto Cook/Serve/Wash drive the player actions when you have no staff (or help alongside them).",
    })

    task.spawn(function()
        task.wait(1.4)
        refreshKitchenInfo()
        while task.wait(2) do
            if kitchenInfoParagraph then
                refreshKitchenInfo()
            end
        end
    end)
end

-- */  Farm Tab  /* --
do
    local FarmTab = Window:CreateTab("Farm", "sprout")

    local farmInfoParagraph
    local selectedPlantId = "Wheat Plant"
    local autoHarvestRunning = false
    local autoHarvestLoopId = 0
    local autoHarvestDelaySec = 0.4
    local autoPlantRunning = false
    local autoPlantLoopId = 0
    local autoPlantDelaySec = 0.6
    local autoFertilizerRunning = false
    local autoFertilizerLoopId = 0
    local autoFertilizerDelaySec = 30
    local autoBuyPlantRunning = false
    local autoBuyPlantLoopId = 0
    local plantStockTarget = 10

    local FALLBACK_PLANTS = {
        "Wheat Plant",
        "Tomato Plant",
        "Potato Plant",
        "Lettuce Plant",
        "Corn Plant",
        "Carrot Plant",
        "Pumpkin Plant",
        "Watermelon Plant",
        "Pineapple Plant",
        "Sugar Cane Plant",
        "Coconut Tree",
    }

    local function listFarmPlantOptions(ctx)
        local options = {}
        local seen = {}
        if ctx and type(ctx.Item) == "table" then
            for id, dir in pairs(ctx.Item) do
                if type(id) == "string" and type(dir) == "table" then
                    local cat = dir.ShopCategory
                    local linked = dir.LinkedEntityId
                    local isPlant = cat == "Farming"
                        or (type(linked) == "string" and linked:find("Crop", 1, true))
                        or id:find("Plant", 1, true)
                    if isPlant and dir.ShopCost and not seen[id] then
                        seen[id] = true
                        table.insert(options, id)
                    end
                end
            end
        end
        if #options == 0 then
            for _, id in ipairs(FALLBACK_PLANTS) do
                table.insert(options, id)
            end
        end
        table.sort(options)
        return options
    end

    local function cropIsReady(ctx, crop)
        if ctx.ClientCrop and type(ctx.ClientCrop.IsReady) == "function" then
            local ok, ready = pcall(function()
                return ctx.ClientCrop.IsReady(crop)
            end)
            if ok then
                return ready == true
            end
        end
        local cropId, progress = nil, 0
        pcall(function()
            cropId = crop:GetSave("CropId")
            progress = crop:GetSession("GrowthProgress") or 0
        end)
        return cropId ~= nil and progress >= 1
    end

    local function cropIsEmpty(crop)
        local cropId = nil
        pcall(function()
            cropId = crop:GetSave("CropId")
        end)
        return cropId == nil
    end

    local function buildFarmInfo(ctx)
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return "Waiting for local restaurant..."
        end
        local crops = collectLocalSubclass(rest, "Crop")
        local sprinklers = collectLocalSubclass(rest, "Sprinkler")
        local farmers = collectLocalSubclass(rest, "Farmer")
        local ready, growing, empty = 0, 0, 0
        for _, crop in ipairs(crops) do
            if cropIsEmpty(crop) then
                empty += 1
            elseif cropIsReady(ctx, crop) then
                ready += 1
            else
                growing += 1
            end
        end
        local fertActive = false
        if ctx.EffectsCmds and type(ctx.EffectsCmds.GetPower) == "function" then
            pcall(function()
                fertActive = (ctx.EffectsCmds.GetPower("Fertilizer", LocalPlayer) or 0) > 0
            end)
        end
        local plantStock = inventoryCount(ctx, selectedPlantId)
        local sprinklerStock = inventoryCount(ctx, "Basic Sprinkler") + inventoryCount(ctx, "Large Sprinkler")
        return table.concat({
            "Crops: " .. #crops,
            "Ready: " .. ready,
            "Growing: " .. growing,
            "Empty plots: " .. empty,
            "Sprinklers placed: " .. #sprinklers,
            "Farmers: " .. #farmers,
            "Selected plant: " .. selectedPlantId,
            "Plant stock: " .. plantStock,
            "Sprinkler stock: " .. sprinklerStock,
            "Fertilizer boost: " .. (fertActive and "active" or "off"),
        }, "\n")
    end

    local function refreshFarmInfo()
        if farmInfoParagraph then
            farmInfoParagraph:Set({ Title = "Farm Status", Content = buildFarmInfo(getGameCtx()) })
        end
    end

    local function harvestReadyCrops()
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return 0
        end
        local harvested = 0
        for _, crop in ipairs(collectLocalSubclass(rest, "Crop")) do
            if cropIsReady(ctx, crop) then
                local ok = false
                if ctx.ClientCrop and type(ctx.ClientCrop.HarvestPlayer) == "function" then
                    local success, a = pcall(function()
                        return ctx.ClientCrop.HarvestPlayer(crop)
                    end)
                    ok = success and a == true
                end
                if not ok then
                    ok = safeInvokeEntity(crop, "Harvest") == true
                end
                if ok then
                    harvested += 1
                end
            end
        end
        return harvested
    end

    local function buyPlantStock(targetCount)
        local ctx = getGameCtx()
        if not ctx.ShopCmds or type(ctx.ShopCmds.Purchase) ~= "function" then
            return 0, "ShopCmds not loaded"
        end
        local bought = 0
        local stock = inventoryCount(ctx, selectedPlantId)
        while stock < targetCount do
            local ok, success, err = pcall(function()
                return ctx.ShopCmds.Purchase(selectedPlantId)
            end)
            if not ok or not success then
                return bought, tostring(err or success or "Purchase failed")
            end
            bought += 1
            task.wait(0.12)
            stock = inventoryCount(ctx, selectedPlantId)
            if bought >= 25 then
                break
            end
        end
        return bought
    end

    local function findFreePlantVoxels(rest, limit)
        limit = limit or 8
        local free = {}
        local walkable = {}
        pcall(function()
            walkable = rest:GetWalkableVoxels() or {}
        end)
        for _, voxel in ipairs(walkable) do
            if #free >= limit then
                break
            end
            local occupied = false
            for floor = 1, 3 do
                local ent = nil
                pcall(function()
                    ent = rest:GetEntityByVoxel(voxel, nil, floor)
                end)
                if ent then
                    occupied = true
                    break
                end
            end
            if not occupied then
                table.insert(free, { x = voxel.X, y = voxel.Y, floor = 1 })
            end
        end
        return free
    end

    local function placePlants(maxPlaces)
        maxPlaces = maxPlaces or 6
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return 0, "No restaurant"
        end
        local stock = inventoryCount(ctx, selectedPlantId)
        if stock <= 0 then
            local bought = buyPlantStock(math.max(1, plantStockTarget))
            stock = inventoryCount(ctx, selectedPlantId)
            if stock <= 0 then
                return 0, "No " .. selectedPlantId .. " in inventory (bought " .. tostring(bought) .. ")"
            end
        end
        local free = findFreePlantVoxels(rest, maxPlaces)
        local placed = 0
        for _, spot in ipairs(free) do
            if placed >= maxPlaces or stock <= 0 then
                break
            end
            local ok = networkFire("Build_Place", selectedPlantId, spot.x, spot.y, 0, spot.floor)
            if ok then
                placed += 1
                stock -= 1
                task.wait(0.15)
            end
        end
        return placed
    end

    local function placeSprinklers(maxPlaces)
        maxPlaces = maxPlaces or 4
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return 0
        end
        local itemId = nil
        if inventoryCount(ctx, "Large Sprinkler") > 0 then
            itemId = "Large Sprinkler"
        elseif inventoryCount(ctx, "Basic Sprinkler") > 0 then
            itemId = "Basic Sprinkler"
        else
            if ctx.ShopCmds and type(ctx.ShopCmds.Purchase) == "function" then
                pcall(function()
                    ctx.ShopCmds.Purchase("Basic Sprinkler")
                end)
                task.wait(0.2)
            end
            if inventoryCount(ctx, "Basic Sprinkler") > 0 then
                itemId = "Basic Sprinkler"
            end
        end
        if not itemId then
            return 0
        end
        local crops = collectLocalSubclass(rest, "Crop")
        local placed = 0
        local stock = inventoryCount(ctx, itemId)
        for _, crop in ipairs(crops) do
            if placed >= maxPlaces or stock <= 0 then
                break
            end
            local voxel = nil
            local floor = 1
            pcall(function()
                voxel = crop:GetVoxel()
                floor = crop:GetFloor() or 1
            end)
            if voxel then
                local offsets = {
                    Vector2.new(1, 0),
                    Vector2.new(-1, 0),
                    Vector2.new(0, 1),
                    Vector2.new(0, -1),
                }
                for _, off in ipairs(offsets) do
                    if placed >= maxPlaces or stock <= 0 then
                        break
                    end
                    local target = voxel + off
                    local existing = nil
                    pcall(function()
                        existing = rest:GetEntityByVoxel(target, nil, floor)
                    end)
                    if not existing then
                        local ok = networkFire("Build_Place", itemId, target.X, target.Y, 0, floor)
                        if ok then
                            placed += 1
                            stock -= 1
                            task.wait(0.15)
                        end
                    end
                end
            end
        end
        return placed
    end

    local function activateFertilizer()
        local ctx = getGameCtx()
        if ctx.EffectsCmds and type(ctx.EffectsCmds.GetPower) == "function" then
            local power = 0
            pcall(function()
                power = ctx.EffectsCmds.GetPower("Fertilizer", LocalPlayer) or 0
            end)
            if power > 0 then
                return false, "already active"
            end
        end
        local diamonds = 0
        if ctx.CurrencyCmds and type(ctx.CurrencyCmds.Get) == "function" then
            diamonds = ctx.CurrencyCmds.Get("Diamonds") or 0
        end
        if diamonds < 150 then
            return false, "Need 150 Diamonds"
        end
        return networkFire("PseudoProducts_RequestPurchase", "Fertilizer")
    end

    FarmTab:CreateSection("Status")
    farmInfoParagraph = FarmTab:CreateParagraph({
        Title = "Farm Status",
        Content = "Loading...",
    })
    FarmTab:CreateButton({
        Name = "Refresh Farm Status",
        Callback = function()
            refreshFarmInfo()
        end,
    })

    FarmTab:CreateSection("Harvest")
    FarmTab:CreateInput({
        Name = "Harvest Delay (s)",
        CurrentValue = "0.4",
        Flag = "rar_farm_harvest_delay",
        Callback = function(value)
            local n = tonumber(type(value) == "table" and value[1] or value)
            if n and n > 0.1 then
                autoHarvestDelaySec = n
            end
        end,
    })
    FarmTab:CreateButton({
        Name = "Harvest Ready Crops",
        Callback = function()
            local n = harvestReadyCrops()
            mountNotify({ Title = "Farm", Content = "Harvested " .. n .. " crop(s)" })
            refreshFarmInfo()
        end,
    })
    FarmTab:CreateToggle({
        Name = "Auto Harvest",
        CurrentValue = false,
        Flag = "rar_farm_auto_harvest",
        Callback = function(value)
            autoHarvestRunning = value == true
            autoHarvestLoopId += 1
            local loopId = autoHarvestLoopId
            if not autoHarvestRunning then
                return
            end
            task.spawn(function()
                while autoHarvestRunning and loopId == autoHarvestLoopId do
                    harvestReadyCrops()
                    task.wait(autoHarvestDelaySec)
                end
            end)
        end,
    })

    FarmTab:CreateSection("Plant")
    do
        local plantOptions = listFarmPlantOptions(getGameCtx())
        if not table.find(plantOptions, selectedPlantId) and plantOptions[1] then
            selectedPlantId = plantOptions[1]
        end
        FarmTab:CreateDropdown({
            Name = "Plant Item",
            Options = plantOptions,
            CurrentOption = { selectedPlantId },
            MultipleOptions = false,
            Flag = "rar_farm_plant_item",
            Callback = function(option)
                local value = type(option) == "table" and option[1] or option
                if type(value) == "string" and #value > 0 then
                    selectedPlantId = value
                    refreshFarmInfo()
                end
            end,
        })
    end
    FarmTab:CreateInput({
        Name = "Keep Plant Stock",
        CurrentValue = "10",
        Flag = "rar_farm_plant_stock",
        Callback = function(value)
            local n = tonumber(type(value) == "table" and value[1] or value)
            if n and n >= 0 then
                plantStockTarget = math.floor(n)
            end
        end,
    })
    FarmTab:CreateButton({
        Name = "Buy Selected Plant",
        Callback = function()
            local n, err = buyPlantStock(math.max(plantStockTarget, inventoryCount(getGameCtx(), selectedPlantId) + 1))
            if n > 0 then
                mountNotify({ Title = "Farm", Content = "Bought " .. n .. "x " .. selectedPlantId })
            else
                mountNotify({ Title = "Farm", Content = tostring(err or "Buy failed") })
            end
            refreshFarmInfo()
        end,
    })
    FarmTab:CreateButton({
        Name = "Place Plants (free tiles)",
        Callback = function()
            local n, err = placePlants(8)
            mountNotify({ Title = "Farm", Content = n > 0 and ("Placed " .. n) or tostring(err or "Nothing placed") })
            refreshFarmInfo()
        end,
    })
    FarmTab:CreateToggle({
        Name = "Auto Buy Plants",
        CurrentValue = false,
        Flag = "rar_farm_auto_buy_plant",
        Callback = function(value)
            autoBuyPlantRunning = value == true
            autoBuyPlantLoopId += 1
            local loopId = autoBuyPlantLoopId
            if not autoBuyPlantRunning then
                return
            end
            task.spawn(function()
                while autoBuyPlantRunning and loopId == autoBuyPlantLoopId do
                    buyPlantStock(plantStockTarget)
                    task.wait(2)
                end
            end)
        end,
    })
    FarmTab:CreateToggle({
        Name = "Auto Plant",
        CurrentValue = false,
        Flag = "rar_farm_auto_plant",
        Callback = function(value)
            autoPlantRunning = value == true
            autoPlantLoopId += 1
            local loopId = autoPlantLoopId
            if not autoPlantRunning then
                return
            end
            task.spawn(function()
                while autoPlantRunning and loopId == autoPlantLoopId do
                    placePlants(4)
                    task.wait(autoPlantDelaySec)
                end
            end)
        end,
    })

    FarmTab:CreateSection("Sprinkler / Fertilizer")
    FarmTab:CreateParagraph({
        Title = "How it works",
        Content = "Sprinklers are passive once built. Fertilizer is a 5-min diamond boost (150 Diamonds). Place sprinklers next to crops for growth speed.",
    })
    FarmTab:CreateButton({
        Name = "Buy Fertilizer Boost",
        Callback = function()
            local ok, err = activateFertilizer()
            mountNotify({ Title = "Farm", Content = ok and "Fertilizer requested" or tostring(err or "Failed") })
            refreshFarmInfo()
        end,
    })
    FarmTab:CreateToggle({
        Name = "Auto Fertilizer",
        CurrentValue = false,
        Flag = "rar_farm_auto_fertilizer",
        Callback = function(value)
            autoFertilizerRunning = value == true
            autoFertilizerLoopId += 1
            local loopId = autoFertilizerLoopId
            if not autoFertilizerRunning then
                return
            end
            task.spawn(function()
                while autoFertilizerRunning and loopId == autoFertilizerLoopId do
                    activateFertilizer()
                    task.wait(autoFertilizerDelaySec)
                end
            end)
        end,
    })
    FarmTab:CreateButton({
        Name = "Place Sprinklers Near Crops",
        Callback = function()
            local n = placeSprinklers(6)
            mountNotify({ Title = "Farm", Content = "Placed " .. n .. " sprinkler(s)" })
            refreshFarmInfo()
        end,
    })

    task.spawn(function()
        task.wait(1.5)
        refreshFarmInfo()
        while task.wait(2) do
            if farmInfoParagraph then
                refreshFarmInfo()
            end
        end
    end)
end

-- */  Ranch Tab  /* --
do
    local RanchTab = Window:CreateTab("Ranch", "beef")

    local ranchInfoParagraph
    local autoFeedRunning = false
    local autoFeedLoopId = 0
    local autoFeedDelaySec = 0.75
    local autoCollectRunning = false
    local autoCollectLoopId = 0
    local autoCollectDelaySec = 0.6
    local autoProcessRunning = false
    local autoProcessLoopId = 0
    local autoProcessDelaySec = 0.45
    local autoProcessorRunning = false
    local autoProcessorLoopId = 0
    local autoProcessorDelaySec = 0.8

    local PICKUP_STATUSES = {
        [1] = true, -- Idle
        [2] = true, -- Wandering
        [3] = true, -- WalkingToFeeder
    }

    local function animalIsMeatReady(ctx, animal)
        if ctx.ClientAnimal and type(ctx.ClientAnimal.IsMeatReady) == "function" then
            local ok, ready = pcall(function()
                return ctx.ClientAnimal.IsMeatReady(animal)
            end)
            if ok then
                return ready == true
            end
        end
        local fat, cap = 0, nil
        pcall(function()
            fat = animal:GetSave("Fat") or 0
            local dir = animal:GetDirectory()
            cap = dir and dir.AnimalComponent and dir.AnimalComponent.FatCapacity
        end)
        return type(cap) == "number" and fat >= cap
    end

    local function buildRanchInfo(ctx)
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return "Waiting for local restaurant..."
        end
        local animals = collectLocalSubclass(rest, "Animal")
        local feeders = collectLocalSubclass(rest, "Feeder")
        local meatHouses = collectLocalSubclass(rest, "MeatHouse")
        local hives = collectLocalSubclass(rest, "BeeHive")
        local processors = collectLocalSubclass(rest, "ProcessingStation")
        local ranchers = collectLocalSubclass(rest, "Rancher")
        local ground = collectLocalSubclass(rest, "GroundCurrency")
        local meatReady, honeyReady = 0, 0
        for _, animal in ipairs(animals) do
            if animalIsMeatReady(ctx, animal) then
                meatReady += 1
            end
        end
        for _, hive in ipairs(hives) do
            local honey = 0
            pcall(function()
                honey = hive:GetSave("Honey") or 0
            end)
            if honey >= 1 then
                honeyReady += 1
            end
        end
        local feederLines = {}
        for _, feeder in ipairs(feeders) do
            local amount, capacity, inputId = 0, 0, "?"
            pcall(function()
                amount = feeder:GetSave("Amount") or 0
                local dir = feeder:GetDirectory()
                capacity = dir and dir.FeederComponent and dir.FeederComponent.Capacity or 0
                inputId = dir and dir.FeederComponent and dir.FeederComponent.InputCurrency or "?"
            end)
            local have = 0
            if ctx.CurrencyCmds and type(ctx.CurrencyCmds.Get) == "function" then
                have = ctx.CurrencyCmds.Get(inputId) or 0
            end
            local name = "Feeder"
            pcall(function()
                local dir = feeder:GetDirectory()
                name = (dir and (dir.DisplayName or dir._id)) or name
            end)
            table.insert(feederLines, string.format("%s %s/%s (have %s %s)", name, formatAmount(amount), formatAmount(capacity), formatAmount(have), tostring(inputId)))
            if #feederLines >= 6 then
                break
            end
        end
        local carrying = LocalPlayer:GetAttribute("TargetMeatHouseAnimalId")
        local targetHouse = LocalPlayer:GetAttribute("TargetMeatHouseId")
        return table.concat({
            "Animals: " .. #animals .. "  meat-ready=" .. meatReady,
            "Feeders: " .. #feeders,
            "Meat houses: " .. #meatHouses,
            "Bee hives: " .. #hives .. "  honey-ready=" .. honeyReady,
            "Processors: " .. #processors,
            "Ranchers: " .. #ranchers,
            "Ground drops: " .. #ground,
            "Carrying animal: " .. (carrying and tostring(carrying) or "no"),
            "Target meat house: " .. (targetHouse and tostring(targetHouse) or "none"),
            #feederLines > 0 and ("Feeders:\n" .. table.concat(feederLines, "\n")) or "No feeders",
        }, "\n")
    end

    local function refreshRanchInfo()
        if ranchInfoParagraph then
            ranchInfoParagraph:Set({ Title = "Ranch Status", Content = buildRanchInfo(getGameCtx()) })
        end
    end

    local function fillFeeders()
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return 0
        end
        local filled = 0
        for _, feeder in ipairs(collectLocalSubclass(rest, "Feeder")) do
            local amount, capacity, inputId = 0, 0, nil
            pcall(function()
                amount = feeder:GetSave("Amount") or 0
                local dir = feeder:GetDirectory()
                capacity = dir and dir.FeederComponent and dir.FeederComponent.Capacity or 0
                inputId = dir and dir.FeederComponent and dir.FeederComponent.InputCurrency
            end)
            if capacity > 0 and amount < capacity and inputId then
                local have = 0
                if ctx.CurrencyCmds and type(ctx.CurrencyCmds.Get) == "function" then
                    have = ctx.CurrencyCmds.Get(inputId) or 0
                end
                if have > 0 then
                    if safeFireEntity(feeder, "Fill") then
                        filled += 1
                    end
                end
            end
        end
        return filled
    end

    local function collectHoneyAndDrops()
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return 0
        end
        local n = 0
        for _, hive in ipairs(collectLocalSubclass(rest, "BeeHive")) do
            local honey = 0
            pcall(function()
                honey = hive:GetSave("Honey") or 0
            end)
            if honey >= 1 and safeInvokeEntity(hive, "CollectHoney") then
                n += 1
            end
        end
        for _, drop in ipairs(collectLocalSubclass(rest, "GroundCurrency")) do
            if safeInvokeEntity(drop, "Take") then
                n += 1
            end
        end
        return n
    end

    local function processMeatStep()
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return 0
        end
        local actions = 0
        local carryingId = LocalPlayer:GetAttribute("TargetMeatHouseAnimalId")
        local houseId = LocalPlayer:GetAttribute("TargetMeatHouseId")
        if carryingId and houseId then
            local house = nil
            pcall(function()
                house = rest:GetEntity(houseId)
            end)
            if house and safeInvokeEntity(house, "DepositAnimalPlayer") then
                actions += 1
            end
        elseif not carryingId then
            for _, animal in ipairs(collectLocalSubclass(rest, "Animal")) do
                if animalIsMeatReady(ctx, animal) then
                    local status = nil
                    pcall(function()
                        status = animal:GetSession("Status")
                    end)
                    if PICKUP_STATUSES[status or 1] then
                        if safeInvokeEntity(animal, "PickupAnimalPlayer") then
                            actions += 1
                            break
                        end
                    end
                end
            end
        end
        for _, house in ipairs(collectLocalSubclass(rest, "MeatHouse")) do
            local queue = nil
            if ctx.ClientMeatHouse and type(ctx.ClientMeatHouse.GetQueue) == "function" then
                pcall(function()
                    queue = ctx.ClientMeatHouse.GetQueue(house)
                end)
            else
                pcall(function()
                    queue = house:GetSession("OutputQueue")
                end)
            end
            if type(queue) == "table" and #queue > 0 then
                if safeInvokeEntity(house, "ClaimCurrency") then
                    actions += 1
                end
            end
        end
        return actions
    end

    local function fillProcessors()
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return 0
        end
        local n = 0
        for _, station in ipairs(collectLocalSubclass(rest, "ProcessingStation")) do
            if safeInvokeEntity(station, "ProcessingStation_Fill") then
                n += 1
            end
        end
        return n
    end

    RanchTab:CreateSection("Status")
    ranchInfoParagraph = RanchTab:CreateParagraph({
        Title = "Ranch Status",
        Content = "Loading...",
    })
    RanchTab:CreateButton({
        Name = "Refresh Ranch Status",
        Callback = function()
            refreshRanchInfo()
        end,
    })

    RanchTab:CreateSection("Feed")
    RanchTab:CreateInput({
        Name = "Feed Delay (s)",
        CurrentValue = "0.75",
        Flag = "rar_ranch_feed_delay",
        Callback = function(value)
            local n = tonumber(type(value) == "table" and value[1] or value)
            if n and n > 0.1 then
                autoFeedDelaySec = n
            end
        end,
    })
    RanchTab:CreateButton({
        Name = "Fill All Feeders",
        Callback = function()
            local n = fillFeeders()
            mountNotify({ Title = "Ranch", Content = "Filled " .. n .. " feeder(s)" })
            refreshRanchInfo()
        end,
    })
    RanchTab:CreateToggle({
        Name = "Auto Fill Feeders",
        CurrentValue = false,
        Flag = "rar_ranch_auto_feed",
        Callback = function(value)
            autoFeedRunning = value == true
            autoFeedLoopId += 1
            local loopId = autoFeedLoopId
            if not autoFeedRunning then
                return
            end
            task.spawn(function()
                while autoFeedRunning and loopId == autoFeedLoopId do
                    fillFeeders()
                    task.wait(autoFeedDelaySec)
                end
            end)
        end,
    })

    RanchTab:CreateSection("Collect")
    RanchTab:CreateButton({
        Name = "Collect Honey + Ground Drops",
        Callback = function()
            local n = collectHoneyAndDrops()
            mountNotify({ Title = "Ranch", Content = "Collected " .. n })
            refreshRanchInfo()
        end,
    })
    RanchTab:CreateToggle({
        Name = "Auto Collect",
        CurrentValue = false,
        Flag = "rar_ranch_auto_collect",
        Callback = function(value)
            autoCollectRunning = value == true
            autoCollectLoopId += 1
            local loopId = autoCollectLoopId
            if not autoCollectRunning then
                return
            end
            task.spawn(function()
                while autoCollectRunning and loopId == autoCollectLoopId do
                    collectHoneyAndDrops()
                    task.wait(autoCollectDelaySec)
                end
            end)
        end,
    })

    RanchTab:CreateSection("Process Animals")
    RanchTab:CreateParagraph({
        Title = "Meat flow",
        Content = "Pickup fat animals → deposit at meat house → claim output. Needs a meat house built.",
    })
    RanchTab:CreateButton({
        Name = "Process Meat Step",
        Callback = function()
            local n = processMeatStep()
            mountNotify({ Title = "Ranch", Content = "Actions: " .. n })
            refreshRanchInfo()
        end,
    })
    RanchTab:CreateToggle({
        Name = "Auto Process Meat",
        CurrentValue = false,
        Flag = "rar_ranch_auto_process",
        Callback = function(value)
            autoProcessRunning = value == true
            autoProcessLoopId += 1
            local loopId = autoProcessLoopId
            if not autoProcessRunning then
                return
            end
            task.spawn(function()
                while autoProcessRunning and loopId == autoProcessLoopId do
                    processMeatStep()
                    task.wait(autoProcessDelaySec)
                end
            end)
        end,
    })

    RanchTab:CreateSection("Processing Station")
    RanchTab:CreateButton({
        Name = "Fill Processors",
        Callback = function()
            local n = fillProcessors()
            mountNotify({ Title = "Ranch", Content = "Filled " .. n .. " processor(s)" })
            refreshRanchInfo()
        end,
    })
    RanchTab:CreateToggle({
        Name = "Auto Fill Processors",
        CurrentValue = false,
        Flag = "rar_ranch_auto_processor",
        Callback = function(value)
            autoProcessorRunning = value == true
            autoProcessorLoopId += 1
            local loopId = autoProcessorLoopId
            if not autoProcessorRunning then
                return
            end
            task.spawn(function()
                while autoProcessorRunning and loopId == autoProcessorLoopId do
                    fillProcessors()
                    task.wait(autoProcessorDelaySec)
                end
            end)
        end,
    })

    task.spawn(function()
        task.wait(1.6)
        refreshRanchInfo()
        while task.wait(2) do
            if ranchInfoParagraph then
                refreshRanchInfo()
            end
        end
    end)
end

-- */  Shop Tab  /* --
do
    local ShopTab = Window:CreateTab("Shop", "shopping-bag")

    local shopInfoParagraph
    local selectedShopItemId = "Wheat Plant"
    local selectedPackageId = "Farm"
    local autoBuyRunning = false
    local autoBuyLoopId = 0
    local autoBuyDelaySec = 1.5
    local autoBuyTargetStock = 5
    local autoSellRunning = false
    local autoSellLoopId = 0
    local autoSellDelaySec = 3
    local autoUnlockRunning = false
    local autoUnlockLoopId = 0
    local autoUnlockDelaySec = 4

    local function listShopBuyOptions(ctx)
        local options = {}
        if ctx and type(ctx.Item) == "table" then
            for id, dir in pairs(ctx.Item) do
                if type(id) == "string" and type(dir) == "table" and dir.ShopCost then
                    table.insert(options, id)
                end
            end
        end
        table.sort(options)
        if #options == 0 then
            options = { "Wheat Plant", "Basic Sprinkler", "Wooden Chair" }
        end
        return options
    end

    local function listPackageOptions(ctx)
        local options = {}
        if ctx and type(ctx.EntityPackage) == "table" then
            local rows = {}
            for id, dir in pairs(ctx.EntityPackage) do
                if type(id) == "string" and type(dir) == "table" then
                    table.insert(rows, { id = id, order = tonumber(dir.Order) or 999 })
                end
            end
            table.sort(rows, function(a, b)
                return a.order < b.order
            end)
            for _, row in ipairs(rows) do
                table.insert(options, row.id)
            end
        end
        if #options == 0 then
            options = { "Farm", "Animals", "Land Plot 1", "Land Plot 2", "Land Plot 3", "Land Plot 4", "Land Plot 5" }
        end
        return options
    end

    local function buildShopInfo(ctx)
        local rest = getLocalRestaurant(ctx)
        local cash = 0
        local diamonds = 0
        if ctx.CurrencyCmds and type(ctx.CurrencyCmds.Get) == "function" then
            cash = ctx.CurrencyCmds.Get("Cash") or 0
            diamonds = ctx.CurrencyCmds.Get("Diamonds") or 0
        end
        local lines = {
            "Cash: $" .. formatAmount(cash),
            "Diamonds: " .. formatAmount(diamonds),
            "Selected item: " .. selectedShopItemId,
            "Item stock: " .. inventoryCount(ctx, selectedShopItemId),
            "Selected package: " .. selectedPackageId,
        }
        if rest and type(ctx.EntityPackage) == "table" then
            local owned, total = 0, 0
            local nextPkg = nil
            local rows = {}
            for id, dir in pairs(ctx.EntityPackage) do
                if type(id) == "string" and type(dir) == "table" and not dir.GamepassRequired then
                    total += 1
                    local purchased = false
                    pcall(function()
                        purchased = rest:IsPackagePurchased(dir) == true
                    end)
                    if purchased then
                        owned += 1
                    else
                        table.insert(rows, { id = id, order = tonumber(dir.Order) or 999, dir = dir })
                    end
                end
            end
            table.sort(rows, function(a, b)
                return a.order < b.order
            end)
            if rows[1] then
                nextPkg = rows[1]
            end
            table.insert(lines, "Packages owned: " .. owned .. "/" .. total)
            if nextPkg then
                local cost = tostring(nextPkg.dir.CurrencyAmount or "?")
                local currency = tostring(nextPkg.dir.CurrencyId or "Cash")
                table.insert(lines, "Next package: " .. nextPkg.id .. " (" .. cost .. " " .. currency .. ")")
            else
                table.insert(lines, "Next package: none")
            end
        else
            table.insert(lines, "Restaurant/packages unavailable")
        end
        return table.concat(lines, "\n")
    end

    local function refreshShopInfo()
        if shopInfoParagraph then
            shopInfoParagraph:Set({ Title = "Shop Status", Content = buildShopInfo(getGameCtx()) })
        end
    end

    local function buyShopItem(itemId, times)
        local ctx = getGameCtx()
        if not ctx.ShopCmds or type(ctx.ShopCmds.Purchase) ~= "function" then
            return 0, "ShopCmds not loaded"
        end
        times = times or 1
        local bought = 0
        for _ = 1, times do
            local ok, success, err = pcall(function()
                return ctx.ShopCmds.Purchase(itemId)
            end)
            if not ok or not success then
                return bought, tostring(err or success or "Purchase failed")
            end
            bought += 1
            task.wait(0.12)
        end
        return bought
    end

    local function sellEverything()
        local ctx = getGameCtx()
        local soldCurrency, soldItems = false, false
        if ctx.CurrencyCmds and type(ctx.CurrencyCmds.SellAll) == "function" then
            local ok, success = pcall(function()
                return ctx.CurrencyCmds.SellAll()
            end)
            soldCurrency = ok and success == true
        end
        if ctx.Item and ctx.InventoryCmds and type(ctx.InventoryCmds.Sell) == "function" then
            local bag = {}
            for _, dir in pairs(ctx.Item) do
                if type(dir) == "table" then
                    local price = nil
                    if ctx.InventoryUtil and type(ctx.InventoryUtil.ComputeCashSalePrice) == "function" then
                        pcall(function()
                            price = ctx.InventoryUtil.ComputeCashSalePrice(dir)
                        end)
                    end
                    if price then
                        local count = 0
                        pcall(function()
                            count = ctx.InventoryCmds.Count(dir) or 0
                        end)
                        if count > 0 then
                            bag[dir] = count
                        end
                    end
                end
            end
            if next(bag) ~= nil then
                local ok, success = pcall(function()
                    return ctx.InventoryCmds.Sell(bag)
                end)
                soldItems = ok and success == true
            end
        end
        return soldCurrency, soldItems
    end

    local function getNextPackage(ctx, rest)
        if not rest or type(ctx.EntityPackage) ~= "table" then
            return nil
        end
        local rows = {}
        for id, dir in pairs(ctx.EntityPackage) do
            if type(id) == "string" and type(dir) == "table" and not dir.GamepassRequired then
                local purchased = false
                pcall(function()
                    purchased = rest:IsPackagePurchased(dir) == true
                end)
                if not purchased then
                    table.insert(rows, { id = id, order = tonumber(dir.Order) or 999, dir = dir })
                end
            end
        end
        table.sort(rows, function(a, b)
            return a.order < b.order
        end)
        return rows[1]
    end

    local function purchasePackage(packageId)
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return false, "No restaurant"
        end
        local dir = ctx.EntityPackage and ctx.EntityPackage[packageId]
        local id = (dir and dir._id) or packageId
        local ok, err = networkInvoke("Restaurant_PurchasePackage", id)
        if ok then
            return true
        end
        return false, tostring(err or "Purchase failed")
    end

    ShopTab:CreateSection("Status")
    shopInfoParagraph = ShopTab:CreateParagraph({
        Title = "Shop Status",
        Content = "Loading...",
    })
    ShopTab:CreateButton({
        Name = "Refresh Shop Status",
        Callback = function()
            refreshShopInfo()
        end,
    })

    ShopTab:CreateSection("Auto Buy")
    do
        local options = listShopBuyOptions(getGameCtx())
        if not table.find(options, selectedShopItemId) and options[1] then
            selectedShopItemId = options[1]
        end
        ShopTab:CreateDropdown({
            Name = "Shop Item",
            Options = options,
            CurrentOption = { selectedShopItemId },
            MultipleOptions = false,
            Flag = "rar_shop_item",
            Callback = function(option)
                local value = type(option) == "table" and option[1] or option
                if type(value) == "string" and #value > 0 then
                    selectedShopItemId = value
                    refreshShopInfo()
                end
            end,
        })
    end
    ShopTab:CreateInput({
        Name = "Target Stock",
        CurrentValue = "5",
        Flag = "rar_shop_target_stock",
        Callback = function(value)
            local n = tonumber(type(value) == "table" and value[1] or value)
            if n and n >= 0 then
                autoBuyTargetStock = math.floor(n)
            end
        end,
    })
    ShopTab:CreateButton({
        Name = "Buy Selected Item x1",
        Callback = function()
            local n, err = buyShopItem(selectedShopItemId, 1)
            mountNotify({ Title = "Shop", Content = n > 0 and ("Bought " .. selectedShopItemId) or tostring(err or "Failed") })
            refreshShopInfo()
        end,
    })
    ShopTab:CreateToggle({
        Name = "Auto Buy Selected",
        CurrentValue = false,
        Flag = "rar_shop_auto_buy",
        Callback = function(value)
            autoBuyRunning = value == true
            autoBuyLoopId += 1
            local loopId = autoBuyLoopId
            if not autoBuyRunning then
                return
            end
            task.spawn(function()
                while autoBuyRunning and loopId == autoBuyLoopId do
                    local stock = inventoryCount(getGameCtx(), selectedShopItemId)
                    if stock < autoBuyTargetStock then
                        buyShopItem(selectedShopItemId, 1)
                    end
                    task.wait(autoBuyDelaySec)
                end
            end)
        end,
    })

    ShopTab:CreateSection("Auto Sell")
    ShopTab:CreateButton({
        Name = "Sell All Currency + Inventory",
        Callback = function()
            local soldCurrency, soldItems = sellEverything()
            mountNotify({
                Title = "Shop",
                Content = string.format("Currency=%s Items=%s", tostring(soldCurrency), tostring(soldItems)),
            })
            refreshShopInfo()
        end,
    })
    ShopTab:CreateToggle({
        Name = "Auto Sell All",
        CurrentValue = false,
        Flag = "rar_shop_auto_sell",
        Callback = function(value)
            autoSellRunning = value == true
            autoSellLoopId += 1
            local loopId = autoSellLoopId
            if not autoSellRunning then
                return
            end
            task.spawn(function()
                while autoSellRunning and loopId == autoSellLoopId do
                    sellEverything()
                    task.wait(autoSellDelaySec)
                end
            end)
        end,
    })

    ShopTab:CreateSection("Plot / Package Unlock")
    do
        local options = listPackageOptions(getGameCtx())
        if not table.find(options, selectedPackageId) and options[1] then
            selectedPackageId = options[1]
        end
        ShopTab:CreateDropdown({
            Name = "Package",
            Options = options,
            CurrentOption = { selectedPackageId },
            MultipleOptions = false,
            Flag = "rar_shop_package",
            Callback = function(option)
                local value = type(option) == "table" and option[1] or option
                if type(value) == "string" and #value > 0 then
                    selectedPackageId = value
                    refreshShopInfo()
                end
            end,
        })
    end
    ShopTab:CreateButton({
        Name = "Buy Selected Package",
        Callback = function()
            local ok, err = purchasePackage(selectedPackageId)
            mountNotify({ Title = "Shop", Content = ok and ("Purchased " .. selectedPackageId) or tostring(err or "Failed") })
            refreshShopInfo()
        end,
    })
    ShopTab:CreateButton({
        Name = "Buy Next Package",
        Callback = function()
            local ctx = getGameCtx()
            local rest = getLocalRestaurant(ctx)
            local nextPkg = getNextPackage(ctx, rest)
            if not nextPkg then
                mountNotify({ Title = "Shop", Content = "No package left" })
                return
            end
            local ok, err = purchasePackage(nextPkg.id)
            mountNotify({ Title = "Shop", Content = ok and ("Purchased " .. nextPkg.id) or tostring(err or "Failed") })
            refreshShopInfo()
        end,
    })
    ShopTab:CreateToggle({
        Name = "Auto Unlock Next Package",
        CurrentValue = false,
        Flag = "rar_shop_auto_unlock",
        Callback = function(value)
            autoUnlockRunning = value == true
            autoUnlockLoopId += 1
            local loopId = autoUnlockLoopId
            if not autoUnlockRunning then
                return
            end
            task.spawn(function()
                while autoUnlockRunning and loopId == autoUnlockLoopId do
                    local ctx = getGameCtx()
                    local rest = getLocalRestaurant(ctx)
                    local nextPkg = getNextPackage(ctx, rest)
                    if nextPkg then
                        purchasePackage(nextPkg.id)
                    end
                    task.wait(autoUnlockDelaySec)
                end
            end)
        end,
    })

    task.spawn(function()
        task.wait(1.7)
        refreshShopInfo()
        while task.wait(2) do
            if shopInfoParagraph then
                refreshShopInfo()
            end
        end
    end)
end

-- */  Staff Tab  /* --
do
    local StaffTab = Window:CreateTab("Staff", "users")

    local staffInfoParagraph
    local selectedEmployeeId = ""
    local autoHireRunning = false
    local autoHireLoopId = 0
    local autoHireDelaySec = 2
    local autoTrainRunning = false
    local autoTrainLoopId = 0
    local autoTrainDelaySec = 3

    local EMPLOYEE_SUBCLASSES = { "Cook", "Waiter", "Farmer", "Cleaner", "Rancher", "Manager", "Fisherman" }

    local function getEmployeeDirs(ctx)
        local list = {}
        if ctx.EntityUtil and type(ctx.EntityUtil.Employees) == "table" then
            for id, dir in pairs(ctx.EntityUtil.Employees) do
                if type(id) == "string" and type(dir) == "table" then
                    table.insert(list, { id = id, dir = dir })
                end
            end
        end
        table.sort(list, function(a, b)
            local pa = tonumber(a.dir.Price) or 1e18
            local pb = tonumber(b.dir.Price) or 1e18
            if pa ~= pb then
                return pa < pb
            end
            return a.id < b.id
        end)
        return list
    end

    local function isEmployeeOwned(ctx, rest, employeeDir)
        if not rest or not employeeDir then
            return false
        end
        local subclass = employeeDir.Subclass
        if type(subclass) ~= "string" then
            return false
        end
        -- Subclass may be "Appliance Cook" style; CollectSubclass uses leaf names
        local leaf = subclass
        for _, name in ipairs(EMPLOYEE_SUBCLASSES) do
            if subclass:find(name, 1, true) then
                leaf = name
                break
            end
        end
        for _, entity in ipairs(collectLocalSubclass(rest, leaf)) do
            local same = false
            pcall(function()
                same = entity:GetDirectory() == employeeDir
            end)
            if same then
                return true, entity
            end
        end
        return false, nil
    end

    local function isEmployeeUnlocked(ctx, employeeId)
        if ctx.ProgressionUtil and type(ctx.ProgressionUtil.IsEmployeeUnlocked) == "function" then
            local ok, unlocked = pcall(function()
                return ctx.ProgressionUtil.IsEmployeeUnlocked(LocalPlayer, employeeId)
            end)
            if ok then
                return unlocked == true
            end
        end
        local save = ctx.Saving and ctx.Saving.Get and ctx.Saving.Get()
        return save and save.EmployeeUnlocks and save.EmployeeUnlocks[employeeId] == true
    end

    local function buildStaffInfo(ctx)
        local rest = getLocalRestaurant(ctx)
        if not rest then
            return "Waiting for local restaurant..."
        end
        local lines = {}
        local hiredTotal = 0
        for _, subclass in ipairs(EMPLOYEE_SUBCLASSES) do
            local staff = collectLocalSubclass(rest, subclass)
            hiredTotal += #staff
            if #staff > 0 then
                local bits = {}
                for _, entity in ipairs(staff) do
                    local name, level, training = "?", 1, false
                    pcall(function()
                        local dir = entity:GetDirectory()
                        name = (dir and (dir.DisplayName or dir._id)) or name
                    end)
                    if ctx.StaffLevelingCmds then
                        pcall(function()
                            level = ctx.StaffLevelingCmds.GetLevel(entity) or 1
                            training = ctx.StaffLevelingCmds.IsTraining(entity) == true
                        end)
                    else
                        pcall(function()
                            level = entity:GetSave("Level") or 1
                            training = entity:GetSave("TrainingEndTime") ~= nil
                        end)
                    end
                    table.insert(bits, string.format("%s L%d%s", tostring(name), level, training and "*" or ""))
                end
                table.insert(lines, subclass .. ": " .. table.concat(bits, ", "))
            else
                table.insert(lines, subclass .. ": none")
            end
        end

        local hireable = 0
        local ownedDirs = 0
        for _, row in ipairs(getEmployeeDirs(ctx)) do
            local owned = isEmployeeOwned(ctx, rest, row.dir)
            if owned then
                ownedDirs += 1
            elseif isEmployeeUnlocked(ctx, row.id) and row.dir.Price and not row.dir.ProductId then
                hireable += 1
            end
        end

        local training = 0
        if ctx.StaffLevelingCmds and type(ctx.StaffLevelingCmds.CountTraining) == "function" then
            pcall(function()
                training = ctx.StaffLevelingCmds.CountTraining() or 0
            end)
        end

        local perkLines = {}
        if ctx.PerkCmds and type(ctx.PerkCmds.GetPowerRaw) == "function" then
            local known = {
                "CookSpeed",
                "FarmerScythe",
                "FarmerBackpackCapacity",
                "CropGrowthSpeed",
                "RancherBackpackCapacity",
                "DishwashingSpeed",
                "StaffSpeed",
            }
            for _, perkId in ipairs(known) do
                local power = 0
                pcall(function()
                    power = ctx.PerkCmds.GetPowerRaw(perkId) or 0
                end)
                if power > 0 then
                    table.insert(perkLines, perkId .. "=" .. tostring(power))
                end
            end
        end

        table.insert(lines, 1, "Hired entities: " .. hiredTotal .. "  slots=" .. ownedDirs)
        table.insert(lines, 2, "Hireable unlocked: " .. hireable)
        table.insert(lines, 3, "Training now: " .. training .. (selectedEmployeeId ~= "" and ("  selected=" .. selectedEmployeeId) or ""))
        if #perkLines > 0 then
            table.insert(lines, "Skill perks: " .. table.concat(perkLines, ", "))
        else
            table.insert(lines, "Skill perks: none active")
        end
        return table.concat(lines, "\n")
    end

    local function refreshStaffInfo()
        if staffInfoParagraph then
            staffInfoParagraph:Set({ Title = "Staff Status", Content = buildStaffInfo(getGameCtx()) })
        end
    end

    local function listHireOptions(ctx)
        local options = {}
        local rest = getLocalRestaurant(ctx)
        for _, row in ipairs(getEmployeeDirs(ctx)) do
            if not row.dir.ProductId and row.dir.Price and isEmployeeUnlocked(ctx, row.id) then
                local owned = isEmployeeOwned(ctx, rest, row.dir)
                if not owned then
                    table.insert(options, row.id)
                end
            end
        end
        if #options == 0 then
            for _, row in ipairs(getEmployeeDirs(ctx)) do
                if not row.dir.ProductId then
                    table.insert(options, row.id)
                end
            end
        end
        if #options == 0 then
            options = { "Cook1", "Waiter1", "Farmer1", "Cleaner1" }
        end
        return options
    end

    local function hireEmployee(employeeId)
        local success, err = networkInvoke("Employee_Purchase", employeeId)
        if success then
            return true
        end
        return false, tostring(err or "Hire failed")
    end

    local function hireAllAvailable()
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        local hired = 0
        local lastErr = nil
        for _, row in ipairs(getEmployeeDirs(ctx)) do
            if not row.dir.ProductId and row.dir.Price and isEmployeeUnlocked(ctx, row.id) then
                local owned = isEmployeeOwned(ctx, rest, row.dir)
                if not owned then
                    local cash = 0
                    if ctx.CurrencyCmds and type(ctx.CurrencyCmds.Get) == "function" then
                        cash = ctx.CurrencyCmds.Get("Cash") or 0
                    end
                    if cash >= (row.dir.Price or 0) then
                        local ok, err = hireEmployee(row.id)
                        if ok then
                            hired += 1
                            task.wait(0.2)
                            rest = getLocalRestaurant(ctx)
                        else
                            lastErr = err
                        end
                    end
                end
            end
        end
        return hired, lastErr
    end

    local function trainStaff(limit)
        limit = limit or 8
        local ctx = getGameCtx()
        local rest = getLocalRestaurant(ctx)
        if not rest or not ctx.StaffLevelingCmds then
            return 0, "StaffLevelingCmds not loaded"
        end
        local trained = 0
        local lastErr = nil
        for _, subclass in ipairs(EMPLOYEE_SUBCLASSES) do
            for _, entity in ipairs(collectLocalSubclass(rest, subclass)) do
                if trained >= limit then
                    break
                end
                local can, why = false, nil
                pcall(function()
                    can, why = ctx.StaffLevelingCmds.CanTrain(entity)
                end)
                if can then
                    local id = nil
                    pcall(function()
                        id = entity:GetId()
                    end)
                    if id then
                        local ok, success, err = pcall(function()
                            return ctx.StaffLevelingCmds.StartTraining(id)
                        end)
                        if ok and success then
                            trained += 1
                            task.wait(0.15)
                        else
                            lastErr = tostring(err or success or "Train failed")
                        end
                    end
                else
                    lastErr = why or lastErr
                end
            end
        end
        return trained, lastErr
    end

    StaffTab:CreateSection("Status")
    staffInfoParagraph = StaffTab:CreateParagraph({
        Title = "Staff Status",
        Content = "Loading...",
    })
    StaffTab:CreateButton({
        Name = "Refresh Staff Status",
        Callback = function()
            refreshStaffInfo()
        end,
    })

    StaffTab:CreateSection("Hire")
    do
        local options = listHireOptions(getGameCtx())
        selectedEmployeeId = options[1] or ""
        StaffTab:CreateDropdown({
            Name = "Employee",
            Options = options,
            CurrentOption = { selectedEmployeeId },
            MultipleOptions = false,
            Flag = "rar_staff_employee",
            Callback = function(option)
                local value = type(option) == "table" and option[1] or option
                if type(value) == "string" and #value > 0 then
                    selectedEmployeeId = value
                    refreshStaffInfo()
                end
            end,
        })
    end
    StaffTab:CreateButton({
        Name = "Hire Selected",
        Callback = function()
            if selectedEmployeeId == "" then
                mountNotify({ Title = "Staff", Content = "No employee selected" })
                return
            end
            local ok, err = hireEmployee(selectedEmployeeId)
            mountNotify({ Title = "Staff", Content = ok and ("Hired " .. selectedEmployeeId) or tostring(err or "Failed") })
            refreshStaffInfo()
        end,
    })
    StaffTab:CreateButton({
        Name = "Hire All Affordable",
        Callback = function()
            local n, err = hireAllAvailable()
            mountNotify({ Title = "Staff", Content = n > 0 and ("Hired " .. n) or tostring(err or "Nothing hired") })
            refreshStaffInfo()
        end,
    })
    StaffTab:CreateToggle({
        Name = "Auto Hire",
        CurrentValue = false,
        Flag = "rar_staff_auto_hire",
        Callback = function(value)
            autoHireRunning = value == true
            autoHireLoopId += 1
            local loopId = autoHireLoopId
            if not autoHireRunning then
                return
            end
            task.spawn(function()
                while autoHireRunning and loopId == autoHireLoopId do
                    hireAllAvailable()
                    task.wait(autoHireDelaySec)
                end
            end)
        end,
    })

    StaffTab:CreateSection("Level / Train")
    StaffTab:CreateParagraph({
        Title = "Training",
        Content = "Starts cash training toward the next staff level (cook/waiter/etc up to 10). Staff can't work while training.",
    })
    StaffTab:CreateButton({
        Name = "Train Eligible Staff",
        Callback = function()
            local n, err = trainStaff(8)
            mountNotify({ Title = "Staff", Content = n > 0 and ("Started " .. n .. " training") or tostring(err or "None trainable") })
            refreshStaffInfo()
        end,
    })
    StaffTab:CreateToggle({
        Name = "Auto Train",
        CurrentValue = false,
        Flag = "rar_staff_auto_train",
        Callback = function(value)
            autoTrainRunning = value == true
            autoTrainLoopId += 1
            local loopId = autoTrainLoopId
            if not autoTrainRunning then
                return
            end
            task.spawn(function()
                while autoTrainRunning and loopId == autoTrainLoopId do
                    trainStaff(4)
                    task.wait(autoTrainDelaySec)
                end
            end)
        end,
    })

    StaffTab:CreateSection("Perks")
    StaffTab:CreateParagraph({
        Title = "Perk note",
        Content = "Skill perks come from skill/quest rewards. Staff-level perks unlock as you train each employee (Walkspeed, CookSpeed, DoubleHarvest, etc).",
    })

    task.spawn(function()
        task.wait(1.8)
        refreshStaffInfo()
        while task.wait(2.5) do
            if staffInfoParagraph then
                refreshStaffInfo()
            end
        end
    end)
end

-- */  Quests Tab  /* --
do
    local QuestsTab = Window:CreateTab("Quests", "scroll-text")

    local questInfoParagraph
    local autoClaimRunning = false
    local autoClaimLoopId = 0
    local autoClaimDelaySec = 1.5
    local autoAcceptRunning = false
    local autoAcceptLoopId = 0
    local autoAcceptDelaySec = 2

    local function buildQuestInfo(ctx)
        if not ctx.QuestCmds then
            return "QuestCmds not loaded."
        end
        local completed = 0
        pcall(function()
            completed = ctx.QuestCmds.GetCompletedCount() or 0
        end)
        local claimable = false
        pcall(function()
            claimable = ctx.QuestCmds.HasClaimable() == true
        end)
        local lines = {
            "Completed: " .. tostring(completed),
            "Has claimable: " .. (claimable and "yes" or "no"),
        }
        local active = {}
        pcall(function()
            active = ctx.QuestCmds.GetActiveQuests() or {}
        end)
        local count = 0
        for goalId, goal in pairs(active) do
            count += 1
            if count <= 10 then
                local quest = nil
                pcall(function()
                    quest = ctx.QuestCmds.QuestFromGoal(goal)
                end)
                local name = quest and (quest.DisplayName or quest._id) or tostring(goal.Tag2 or goalId)
                local progress = tonumber(goal.Progress) or 0
                local amount = goal.Goal and tonumber(goal.Goal.Amount) or 0
                local done = progress >= amount
                table.insert(lines, string.format("%s%s %s/%s", done and "[READY] " or "", tostring(name), formatAmount(progress), formatAmount(amount)))
            end
        end
        if count == 0 then
            table.insert(lines, "No active quest goals")
        elseif count > 10 then
            table.insert(lines, "... +" .. (count - 10) .. " more")
        end

        local available = nil
        if ctx.QuestsUtil and type(ctx.QuestsUtil.GetAvailableQuests) == "function" then
            pcall(function()
                available = ctx.QuestsUtil.GetAvailableQuests(LocalPlayer)
            end)
        end
        if type(available) == "table" and #available > 0 then
            local names = {}
            for i = 1, math.min(5, #available) do
                table.insert(names, available[i].DisplayName or available[i]._id)
            end
            table.insert(lines, "Available to accept: " .. table.concat(names, ", "))
        else
            table.insert(lines, "Available to accept: none")
        end
        return table.concat(lines, "\n")
    end

    local function refreshQuestInfo()
        if questInfoParagraph then
            questInfoParagraph:Set({ Title = "Quest Tracker", Content = buildQuestInfo(getGameCtx()) })
        end
    end

    local function claimAllQuests()
        local ctx = getGameCtx()
        if not ctx.QuestCmds then
            return 0, "QuestCmds not loaded"
        end
        local claimed = 0
        local active = {}
        pcall(function()
            active = ctx.QuestCmds.GetActiveQuests() or {}
        end)
        for goalId, goal in pairs(active) do
            local progress = tonumber(goal.Progress) or 0
            local amount = goal.Goal and tonumber(goal.Goal.Amount) or 0
            if progress >= amount and amount > 0 then
                local quest = nil
                pcall(function()
                    quest = ctx.QuestCmds.QuestFromGoal(goal)
                end)
                if quest and type(ctx.QuestCmds.ClaimReward) == "function" then
                    local ok, success = pcall(function()
                        return ctx.QuestCmds.ClaimReward(quest, goalId)
                    end)
                    if ok and success then
                        claimed += 1
                        task.wait(0.12)
                    end
                end
            end
        end
        -- event / misc goals
        if ctx.GoalCmds and type(ctx.GoalCmds.GetGoals) == "function" then
            local all = {}
            pcall(function()
                all = ctx.GoalCmds.GetGoals() or {}
            end)
            for goalId, goal in pairs(all) do
                local progress = tonumber(goal.Progress) or 0
                local amount = goal.Goal and tonumber(goal.Goal.Amount) or 0
                local isQuest = false
                pcall(function()
                    isQuest = ctx.QuestCmds.QuestFromGoal(goal) ~= nil
                end)
                if not isQuest and progress >= amount and amount > 0 then
                    local success = networkInvoke("Goals_Claim", goalId)
                    if success then
                        claimed += 1
                        task.wait(0.12)
                    end
                end
            end
        end
        return claimed
    end

    local function acceptAvailableQuests()
        local ctx = getGameCtx()
        if not ctx.QuestCmds or not ctx.QuestsUtil then
            return 0, "Quest modules not loaded"
        end
        local available = nil
        pcall(function()
            available = ctx.QuestsUtil.GetAvailableQuests(LocalPlayer)
        end)
        if type(available) ~= "table" then
            return 0, "None available"
        end
        local accepted = 0
        for _, quest in ipairs(available) do
            local ok, success = pcall(function()
                return ctx.QuestCmds.Accept(quest)
            end)
            if ok and success then
                accepted += 1
                task.wait(0.12)
            end
        end
        return accepted
    end

    QuestsTab:CreateSection("Track")
    questInfoParagraph = QuestsTab:CreateParagraph({
        Title = "Quest Tracker",
        Content = "Loading...",
    })
    QuestsTab:CreateButton({
        Name = "Refresh Quests",
        Callback = function()
            refreshQuestInfo()
        end,
    })

    QuestsTab:CreateSection("Claim")
    QuestsTab:CreateButton({
        Name = "Claim All Ready",
        Callback = function()
            local n = claimAllQuests()
            mountNotify({ Title = "Quests", Content = "Claimed " .. n })
            refreshQuestInfo()
        end,
    })
    QuestsTab:CreateToggle({
        Name = "Auto Claim",
        CurrentValue = false,
        Flag = "rar_quest_auto_claim",
        Callback = function(value)
            autoClaimRunning = value == true
            autoClaimLoopId += 1
            local loopId = autoClaimLoopId
            if not autoClaimRunning then
                return
            end
            task.spawn(function()
                while autoClaimRunning and loopId == autoClaimLoopId do
                    claimAllQuests()
                    task.wait(autoClaimDelaySec)
                end
            end)
        end,
    })

    QuestsTab:CreateSection("Accept")
    QuestsTab:CreateButton({
        Name = "Accept Available",
        Callback = function()
            local n, err = acceptAvailableQuests()
            mountNotify({ Title = "Quests", Content = n > 0 and ("Accepted " .. n) or tostring(err or "None") })
            refreshQuestInfo()
        end,
    })
    QuestsTab:CreateToggle({
        Name = "Auto Accept",
        CurrentValue = false,
        Flag = "rar_quest_auto_accept",
        Callback = function(value)
            autoAcceptRunning = value == true
            autoAcceptLoopId += 1
            local loopId = autoAcceptLoopId
            if not autoAcceptRunning then
                return
            end
            task.spawn(function()
                while autoAcceptRunning and loopId == autoAcceptLoopId do
                    acceptAvailableQuests()
                    task.wait(autoAcceptDelaySec)
                end
            end)
        end,
    })

    task.spawn(function()
        task.wait(1.9)
        refreshQuestInfo()
        while task.wait(2) do
            if questInfoParagraph then
                refreshQuestInfo()
            end
        end
    end)
end

-- */  Pets Tab  /* --
do
    local PetsTab = Window:CreateTab("Pets", "paw-print")

    local petInfoParagraph
    local selectedPetId = ""
    local autoEquipRunning = false
    local autoEquipLoopId = 0
    local autoMerchantRunning = false
    local autoMerchantLoopId = 0
    local autoMerchantDelaySec = 3

    local function getPetInventory(ctx)
        local save = nil
        if ctx.Saving and type(ctx.Saving.Get) == "function" then
            pcall(function()
                save = ctx.Saving.Get()
            end)
        end
        return (save and save.PetInventory) or {}
    end

    local function petScore(petData)
        if type(petData) ~= "table" then
            return 0
        end
        local score = 0
        if type(petData.Perks) == "table" then
            for _, perk in pairs(petData.Perks) do
                score += (tonumber(perk.CurrentLevel) or 0) * 10
                score += (6 - (tonumber(perk.Grade) or 6))
            end
        end
        return score
    end

    local function buildPetInfo(ctx)
        local inv = getPetInventory(ctx)
        local invCount = 0
        for _ in pairs(inv) do
            invCount += 1
        end
        local limit = 25
        if ctx.PetTypes and ctx.PetTypes.InventoryLimit then
            limit = ctx.PetTypes.InventoryLimit
        end
        local equipped = {}
        if ctx.ClientPet and type(ctx.ClientPet.GetAll) == "function" then
            pcall(function()
                for _, pet in ipairs(ctx.ClientPet.GetAll() or {}) do
                    if pet.IsLocal then
                        table.insert(equipped, pet)
                    end
                end
            end)
        end
        local lines = {
            "Inventory: " .. invCount .. "/" .. limit,
            "Equipped: " .. #equipped,
            "Selected: " .. (selectedPetId ~= "" and selectedPetId or "none"),
        }
        local ranked = {}
        for id, data in pairs(inv) do
            table.insert(ranked, { id = id, data = data, score = petScore(data) })
        end
        table.sort(ranked, function(a, b)
            return a.score > b.score
        end)
        for i = 1, math.min(8, #ranked) do
            local row = ranked[i]
            local dirId = row.data and row.data.DirId or "?"
            local name = dirId
            if ctx.Pet and ctx.Pet[dirId] then
                name = ctx.Pet[dirId].DisplayName or dirId
            end
            local eq = false
            if ctx.ClientPet and type(ctx.ClientPet.IsEquipped) == "function" then
                pcall(function()
                    eq = ctx.ClientPet.IsEquipped(row.id) == true
                end)
            end
            table.insert(lines, string.format("%s%s (%s) score=%d", eq and "[E] " or "", tostring(name), tostring(row.id):sub(1, 8), row.score))
        end

        if ctx.ClientPetMerchant and type(ctx.ClientPetMerchant.GetState) == "function" then
            local state = nil
            pcall(function()
                state = ctx.ClientPetMerchant.GetState()
            end)
            if type(state) == "table" and type(state.Offers) == "table" then
                local open = 0
                for _, offer in ipairs(state.Offers) do
                    if type(offer) == "table" and not offer.Purchased then
                        open += 1
                    end
                end
                table.insert(lines, "Merchant offers left: " .. open)
            else
                table.insert(lines, "Merchant: unavailable")
            end
        end
        return table.concat(lines, "\n")
    end

    local function refreshPetInfo()
        if petInfoParagraph then
            petInfoParagraph:Set({ Title = "Pet Status", Content = buildPetInfo(getGameCtx()) })
        end
    end

    local function listPetOptions(ctx)
        local options = {}
        local inv = getPetInventory(ctx)
        local ranked = {}
        for id, data in pairs(inv) do
            table.insert(ranked, { id = id, score = petScore(data), dirId = data and data.DirId })
        end
        table.sort(ranked, function(a, b)
            return a.score > b.score
        end)
        for _, row in ipairs(ranked) do
            local label = row.id
            if row.dirId then
                label = tostring(row.dirId) .. " | " .. tostring(row.id)
            end
            table.insert(options, label)
        end
        if #options == 0 then
            options = { "(no pets)" }
        end
        return options
    end

    local function parsePetId(option)
        if type(option) ~= "string" then
            return nil
        end
        local id = option:match("|%s*(.+)$")
        if id and #id > 0 then
            return id
        end
        if option ~= "(no pets)" then
            return option
        end
        return nil
    end

    local function equipPet(petId)
        local success, err = networkInvoke("Pets_Equip", petId)
        if success then
            return true
        end
        return false, tostring(err or "Equip failed")
    end

    local function unequipPet(petId)
        local success, err = networkInvoke("Pets_Unequip", petId)
        if success then
            return true
        end
        return false, tostring(err or "Unequip failed")
    end

    local function unequipAll()
        local ctx = getGameCtx()
        local n = 0
        if ctx.ClientPet and type(ctx.ClientPet.GetAll) == "function" then
            local pets = {}
            pcall(function()
                pets = ctx.ClientPet.GetAll() or {}
            end)
            for _, pet in ipairs(pets) do
                if pet.IsLocal and pet.PetId then
                    if unequipPet(pet.PetId) then
                        n += 1
                        task.wait(0.1)
                    end
                end
            end
        end
        return n
    end

    local function equipBest(count)
        count = count or 3
        local ctx = getGameCtx()
        local inv = getPetInventory(ctx)
        local ranked = {}
        for id, data in pairs(inv) do
            table.insert(ranked, { id = id, score = petScore(data) })
        end
        table.sort(ranked, function(a, b)
            return a.score > b.score
        end)
        local equipped = 0
        for i = 1, math.min(count, #ranked) do
            local already = false
            if ctx.ClientPet and type(ctx.ClientPet.IsEquipped) == "function" then
                pcall(function()
                    already = ctx.ClientPet.IsEquipped(ranked[i].id) == true
                end)
            end
            if not already then
                if equipPet(ranked[i].id) then
                    equipped += 1
                    task.wait(0.12)
                end
            else
                equipped += 1
            end
        end
        return equipped
    end

    local function buyMerchantOffers()
        local ctx = getGameCtx()
        if not ctx.ClientPetMerchant or type(ctx.ClientPetMerchant.Purchase) ~= "function" then
            return 0, "Pet merchant not loaded"
        end
        local state = nil
        pcall(function()
            state = ctx.ClientPetMerchant.GetState()
        end)
        if type(state) ~= "table" or type(state.Offers) ~= "table" then
            return 0, "No merchant state"
        end
        local bought = 0
        local lastErr = nil
        for _, offer in ipairs(state.Offers) do
            if type(offer) == "table" and not offer.Purchased and offer.Slot ~= nil then
                local price = tonumber(offer.Price) or 0
                local cash = 0
                if ctx.CurrencyCmds then
                    cash = ctx.CurrencyCmds.Get("Cash") or 0
                end
                if cash >= price then
                    local ok, success, err = pcall(function()
                        return ctx.ClientPetMerchant.Purchase(offer.Slot)
                    end)
                    if ok and success then
                        bought += 1
                        task.wait(0.2)
                    else
                        lastErr = tostring(err or success or "Purchase failed")
                    end
                end
            end
        end
        return bought, lastErr
    end

    local function openPetCrate(productKey)
        local ctx = getGameCtx()
        productKey = productKey or "Pet Crate x1"
        local product = ctx.Product and ctx.Product[productKey]
        local productId = product and product.ProductId
        if not productId then
            -- fallback known ids from dump
            local fallback = {
                ["Pet Crate x1"] = 3606612660,
                ["Pet Crate x3"] = nil,
                ["Pet Crate x10"] = nil,
            }
            productId = fallback[productKey]
        end
        if not productId then
            return false, "Product id missing"
        end
        return networkFire("Products_RequestPurchase", productId)
    end

    PetsTab:CreateSection("Status")
    petInfoParagraph = PetsTab:CreateParagraph({
        Title = "Pet Status",
        Content = "Loading...",
    })
    PetsTab:CreateButton({
        Name = "Refresh Pets",
        Callback = function()
            refreshPetInfo()
        end,
    })

    PetsTab:CreateSection("Equip")
    do
        local options = listPetOptions(getGameCtx())
        selectedPetId = parsePetId(options[1]) or ""
        PetsTab:CreateDropdown({
            Name = "Pet",
            Options = options,
            CurrentOption = { options[1] },
            MultipleOptions = false,
            Flag = "rar_pet_selected",
            Callback = function(option)
                local value = type(option) == "table" and option[1] or option
                selectedPetId = parsePetId(value) or ""
                refreshPetInfo()
            end,
        })
    end
    PetsTab:CreateButton({
        Name = "Equip Selected",
        Callback = function()
            if selectedPetId == "" then
                mountNotify({ Title = "Pets", Content = "No pet selected" })
                return
            end
            local ok, err = equipPet(selectedPetId)
            mountNotify({ Title = "Pets", Content = ok and "Equipped" or tostring(err or "Failed") })
            refreshPetInfo()
        end,
    })
    PetsTab:CreateButton({
        Name = "Unequip Selected",
        Callback = function()
            if selectedPetId == "" then
                mountNotify({ Title = "Pets", Content = "No pet selected" })
                return
            end
            local ok, err = unequipPet(selectedPetId)
            mountNotify({ Title = "Pets", Content = ok and "Unequipped" or tostring(err or "Failed") })
            refreshPetInfo()
        end,
    })
    PetsTab:CreateButton({
        Name = "Equip Best (3)",
        Callback = function()
            local n = equipBest(3)
            mountNotify({ Title = "Pets", Content = "Equipped " .. n })
            refreshPetInfo()
        end,
    })
    PetsTab:CreateButton({
        Name = "Unequip All",
        Callback = function()
            local n = unequipAll()
            mountNotify({ Title = "Pets", Content = "Unequipped " .. n })
            refreshPetInfo()
        end,
    })
    PetsTab:CreateToggle({
        Name = "Keep Best Equipped",
        CurrentValue = false,
        Flag = "rar_pet_auto_equip",
        Callback = function(value)
            autoEquipRunning = value == true
            autoEquipLoopId += 1
            local loopId = autoEquipLoopId
            if not autoEquipRunning then
                return
            end
            task.spawn(function()
                while autoEquipRunning and loopId == autoEquipLoopId do
                    equipBest(3)
                    task.wait(5)
                end
            end)
        end,
    })

    PetsTab:CreateSection("Crates / Merchant")
    PetsTab:CreateParagraph({
        Title = "Note",
        Content = "Pet Crates are Robux products (prompts purchase). Merchant offers are cash pets that restock on a timer.",
    })
    PetsTab:CreateButton({
        Name = "Open Pet Crate x1 (Robux)",
        Callback = function()
            local ok, err = openPetCrate("Pet Crate x1")
            mountNotify({ Title = "Pets", Content = ok and "Purchase prompted" or tostring(err or "Failed") })
        end,
    })
    PetsTab:CreateButton({
        Name = "Open Pet Crate x3 (Robux)",
        Callback = function()
            local ok, err = openPetCrate("Pet Crate x3")
            mountNotify({ Title = "Pets", Content = ok and "Purchase prompted" or tostring(err or "Failed") })
        end,
    })
    PetsTab:CreateButton({
        Name = "Buy Merchant Offers",
        Callback = function()
            local n, err = buyMerchantOffers()
            mountNotify({ Title = "Pets", Content = n > 0 and ("Bought " .. n) or tostring(err or "Nothing bought") })
            refreshPetInfo()
        end,
    })
    PetsTab:CreateToggle({
        Name = "Auto Buy Merchant",
        CurrentValue = false,
        Flag = "rar_pet_auto_merchant",
        Callback = function(value)
            autoMerchantRunning = value == true
            autoMerchantLoopId += 1
            local loopId = autoMerchantLoopId
            if not autoMerchantRunning then
                return
            end
            task.spawn(function()
                while autoMerchantRunning and loopId == autoMerchantLoopId do
                    buyMerchantOffers()
                    task.wait(autoMerchantDelaySec)
                end
            end)
        end,
    })

    task.spawn(function()
        task.wait(2)
        refreshPetInfo()
        while task.wait(2.5) do
            if petInfoParagraph then
                refreshPetInfo()
            end
        end
    end)
end

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "run_a_restaurant", tabIcon = "map-pin" })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, {
    replicatedStorage = ReplicatedStorage,
    tabIcon = "boxes",
})


-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, {
    gamePath = "sempatpanick/run_a_restaurant",
    tabIcon = "video",
})

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/run_a_restaurant",
    rayfieldLibrary = SempatLibrary,
    tabIcon = "settings",
})
