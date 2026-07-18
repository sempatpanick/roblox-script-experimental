local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace = game:GetService("Workspace")
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
            assert(okGet and type(source) == "string", "[sempat/fish_and_monsters] failed to load sempat_library")
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
    Name = "sempatpanick | Fish and Monsters",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Sempat UI • Fish and Monsters",
    ToggleUIKeybind = "K",
    WindowTransparency = 30,
    Icon = "https://dadang.id/sempatpanick-icon.png",
    ConfigurationSaving = {
        Enabled = true,
        AutoSave = false,
        AutoLoad = false,
        FolderName = "sempatpanick",
        FileName = "fish_and_monsters",
    },
})

local function rayfieldDropdownFirst(valueOrTable)
    if type(valueOrTable) == "table" then
        return valueOrTable[1]
    end
    return valueOrTable
end

-- ====================================================================
--                     FISH AND MONSTERS (Knit)
-- ====================================================================
local Knit
local knitRemoteBridge
local remoteCache = {}

local ISLAND_TELEPORTS = {
    { Name = "Bamboo Island", Position = Vector3.new(-1549, 167, 255) },
    { Name = "Iceberg Island", Position = Vector3.new(-518, 163, -253) },
    { Name = "Lost Whale Island", Position = Vector3.new(-2812, 168, -129) },
    { Name = "Bora Reef", Position = Vector3.new(-4118, 188, 2061) },
    { Name = "Volcano Summit", Position = Vector3.new(-1969, 294, 5515) },
    { Name = "Crystal Tide", Position = Vector3.new(-583, 167, -542) },
    { Name = "Seabreeze Peak", Position = Vector3.new(-3256, 275, -4364) },
    { Name = "Lavafin Shore", Position = Vector3.new(-815, 195, 4261) },
    { Name = "Crimson Lava", Position = Vector3.new(1658, 259, 3121) },
    { Name = "Redhook Outpost", Position = Vector3.new(-4118, 165, 2055) },
}

local RARITY_ORDER = {
    Common = 1,
    Uncommon = 2,
    Rare = 3,
    Epic = 4,
    Legendary = 5,
    Mythic = 6,
    Secret = 7,
    Monster = 8,
}

local function unwrapKnitResult(...)
    local first = ...
    if type(first) == "table" and type(first.await) == "function" then
        local packed = table.pack(first:await())
        if packed[1] == false then
            error(tostring(packed[2]), 2)
        end
        if packed.n <= 2 then
            return packed[2]
        end
        return table.unpack(packed, 2, packed.n)
    end
    return ...
end

local function ensureKnit()
    if Knit then
        return Knit
    end
    local packages = ReplicatedStorage:FindFirstChild("Packages")
    local knitModule = packages and packages:FindFirstChild("Knit")
    if not knitModule then
        knitModule = ReplicatedStorage:FindFirstChild("Knit", true)
    end
    if not knitModule then
        return nil
    end
    local ok, result = pcall(require, knitModule)
    if ok and result then
        Knit = result
        return Knit
    end
    return nil
end

local function ensureKnitRemoteBridge()
    if knitRemoteBridge then
        return knitRemoteBridge
    end
    local moduleScript = ReplicatedStorage:FindFirstChild("KnitRemoteBridge", true)
    if not moduleScript then
        local playerScripts = LocalPlayer:FindFirstChild("PlayerScripts")
        moduleScript = playerScripts and playerScripts:FindFirstChild("KnitRemoteBridge", true)
    end
    if not moduleScript then
        return nil
    end
    local ok, result = pcall(require, moduleScript)
    if ok and type(result) == "table" then
        knitRemoteBridge = result
        return knitRemoteBridge
    end
    return nil
end

local function getKnitService(serviceName)
    if not ensureKnit() then
        return nil
    end
    local ok, service = pcall(function()
        return Knit.GetService(serviceName)
    end)
    if ok and service then
        return service
    end
    return nil
end

local function callService(serviceName, methodName, ...)
    local service = getKnitService(serviceName)
    if not service then
        return false, "Knit service unavailable: " .. tostring(serviceName)
    end
    local method = service[methodName]
    if type(method) ~= "function" then
        return false, "Missing method: " .. tostring(serviceName) .. "." .. tostring(methodName)
    end
    local args = table.pack(...)
    local ok, result = pcall(function()
        return unwrapKnitResult(method(service, table.unpack(args, 1, args.n)))
    end)
    if not ok then
        return false, tostring(result)
    end
    return true, result
end

local function getBridgeRemote(folderName, remoteName)
    local key = tostring(folderName) .. "/" .. tostring(remoteName)
    if remoteCache[key] ~= nil then
        return remoteCache[key]
    end
    local bridge = ensureKnitRemoteBridge()
    if not bridge then
        remoteCache[key] = false
        return nil
    end
    local remote
    if folderName then
        local folder = bridge.GetFolder and bridge.GetFolder(folderName)
        remote = folder and folder:FindFirstChild(remoteName)
    else
        remote = bridge.GetGlobal and bridge.GetGlobal(remoteName)
    end
    remoteCache[key] = remote or false
    return remote
end

local function fireRemote(folderName, remoteName, ...)
    local remote = getBridgeRemote(folderName, remoteName)
    if remote and type(remote.FireServer) == "function" then
        local ok, err = pcall(remote.FireServer, remote, ...)
        if ok then
            return true
        end
        return false, tostring(err)
    end
    -- Fall back to Knit service method using registry naming conventions.
    local serviceMap = {
        StartFishing = { "FishingReplicationService", "StartFishing" },
        ThrowFloater = { "FishingReplicationService", "ThrowFloater" },
        ConfirmFloatingCast = { "FishingReplicationService", "ConfirmFloatingCast" },
        StartPulling = { "FishingReplicationService", "StartPulling" },
        StopFishing = { "FishingReplicationService", "StopFishing" },
        SetAfkMode = { "FishingRewardService", "SetAfkMode" },
        FishingPullInput = { "FishingRewardService", "FishingPullInput" },
        SellAllFish = { "FishermanShopService", "SellAllFish" },
        SellSelectedFish = { "FishermanShopService", "SellSelectedFish" },
        SellFish = { "FishermanShopService", "SellFish" },
        EquipRod = { "RodShopService", "EquipRod" },
        BuyRod = { "RodShopService", "BuyRod" },
        BuyFloater = { "RodShopService", "BuyFloater" },
        EquipFloater = { "RodShopService", "EquipFloater" },
        BuyPotion = { "PotionShopService", "BuyPotion" },
        SpawnBoat = { "BoatSpawnService", "SpawnBoat" },
        RespawnBoat = { "BoatSpawnService", "RespawnBoat" },
        RequestSeaLobby = { "SeaLobbyService", "RequestSea" },
        ReturnToBase = { "SeaLobbyService", "ReturnToBase" },
        UpgradeAquarium = { "AquariumSystemService", "UpgradeAquarium" },
    }
    local mapped = serviceMap[remoteName]
    if mapped then
        return callService(mapped[1], mapped[2], ...)
    end
    return false, "Remote unavailable: " .. tostring(remoteName)
end

local function invokeRemote(folderName, remoteName, ...)
    local remote = getBridgeRemote(folderName, remoteName)
    if remote and type(remote.InvokeServer) == "function" then
        local ok, result = pcall(remote.InvokeServer, remote, ...)
        if ok then
            return true, unwrapKnitResult(result)
        end
        return false, tostring(result)
    end
    local serviceMap = {
        RequestFishBite = { "FishingRewardService", "RequestFishBite" },
        GetFishInventory = { "FishermanShopService", "GetFishInventory" },
        GetDiscoveredFish = { "FishermanShopService", "GetDiscoveredFish" },
        GetShopData = folderName == "PotionShopRemotes" and { "PotionShopService", "GetShopData" }
            or folderName == "RodShopRemotes" and { "RodShopService", "GetShopData" }
            or { "ShopService", "GetShopData" },
        GetOwnedItems = { "RodShopService", "GetOwnedItems" },
        GetRewardData = { "RewardService", "GetRewardData" },
        ClaimDaily = { "RewardService", "ClaimDaily" },
        ClaimTime = { "RewardService", "ClaimTime" },
        GetBoatData = { "BoatSpawnService", "GetBoatData" },
        GetSeaLobbyInfo = { "SeaLobbyService", "GetInfo" },
        GetActiveEvents = { "BossFishEventService", "GetActiveEvents" },
    }
    local mapped = serviceMap[remoteName]
    if mapped then
        return callService(mapped[1], mapped[2], ...)
    end
    return false, "Remote unavailable: " .. tostring(remoteName)
end

local function getCharacter()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function getHumanoidRootPart()
    local character = getCharacter()
    return character and character:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
    local character = getCharacter()
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function teleportToPosition(position)
    local hrp = getHumanoidRootPart()
    if not hrp then
        return false, "No HumanoidRootPart"
    end
    local ok, err = pcall(function()
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CFrame.new(position + Vector3.new(0, 4, 0))
    end)
    if not ok then
        return false, tostring(err)
    end
    return true
end

local function antiAfkKick()
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end

local function equipAnyRod()
    local character = getCharacter()
    local humanoid = getHumanoid()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not (character and humanoid and backpack) then
        return false
    end

    local equipped = character:FindFirstChildOfClass("Tool")
    if equipped and (equipped.Name:find("Rod") or equipped.Name:find("Fishing")) then
        return true, equipped
    end

    for _, child in ipairs(backpack:GetChildren()) do
        if child:IsA("Tool") and (child.Name:find("Rod") or child.Name:find("Fishing") or child:GetAttribute("IsRod")) then
            humanoid:EquipTool(child)
            return true, child
        end
    end

    -- Fallback: equip first tool.
    for _, child in ipairs(backpack:GetChildren()) do
        if child:IsA("Tool") then
            humanoid:EquipTool(child)
            return true, child
        end
    end
    return false
end

local function collectFishIds(inventory, opts)
    opts = opts or {}
    local minRarity = opts.MinRarityRank or 0
    local maxRarity = opts.MaxRarityRank or 99
    local skipFavorites = opts.SkipFavorites ~= false
    local ids = {}

    local function consider(entry)
        if type(entry) ~= "table" then
            return
        end
        if skipFavorites and (entry.Favorite == true or entry.IsFavorite == true) then
            return
        end
        local rarity = entry.Rarity or entry.rarity
        local rank = RARITY_ORDER[rarity] or 1
        if rank < minRarity or rank > maxRarity then
            return
        end
        local id = entry.Id or entry.UID or entry.Uuid or entry.uuid or entry.FishUid or entry.UniqueId
        if id ~= nil then
            table.insert(ids, id)
        end
    end

    if type(inventory) ~= "table" then
        return ids
    end

    if inventory.Fish and type(inventory.Fish) == "table" then
        for _, entry in pairs(inventory.Fish) do
            consider(entry)
        end
        return ids
    end

    if inventory.Items and type(inventory.Items) == "table" then
        for _, entry in pairs(inventory.Items) do
            consider(entry)
        end
        return ids
    end

    for _, entry in pairs(inventory) do
        consider(entry)
    end
    return ids
end

local function countTable(t)
    if type(t) ~= "table" then
        return 0
    end
    local n = 0
    for _ in pairs(t) do
        n += 1
    end
    return n
end

-- */  Local Player Tab  /* --
createLocalPlayerTab(Window, mountNotify, { flagsPrefix = "lp", tabIcon = "user" })

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", "fish")

    local statusParagraph
    local autoFishRunning = false
    local autoFishLoopId = 0
    local autoPullRunning = false
    local autoPullLoopId = 0
    local autoAntiAfkRunning = false
    local autoAntiAfkLoopId = 0
    local fishDelaySec = 1
    local pullTapDelaySec = 0.08
    local activePullSessionId = nil
    local lastStatus = "Idle"
    local catchCount = 0

    -- Forward decls (used by setStatus before full definitions).
    local resolveGameAfkToggle
    local getGameAfkFlag
    local getGameAfkLoopTask
    local findAfkGuiButton
    local setGameAfkMode
    local cachedGameGlobals = nil

    local function setStatus(text)
        lastStatus = text
        if statusParagraph and statusParagraph.Set then
            local toggleFn = resolveGameAfkToggle and resolveGameAfkToggle() or nil
            local gameAfk = getGameAfkFlag and getGameAfkFlag() or false
            statusParagraph:Set({
                Title = "Fishing Status",
                Content = string.format(
                    "%s\nCatches (session): %d\nGame AFK: %s\nPull session: %s\ntoggleAfkMode: %s",
                    tostring(text),
                    catchCount,
                    tostring(gameAfk == true),
                    activePullSessionId and tostring(activePullSessionId) or "none",
                    type(toggleFn) == "function" and "ready" or "waiting"
                ),
            })
        end
    end

    local function extractPullSessionId(...)
        local args = table.pack(...)
        for i = 1, args.n do
            local value = args[i]
            if type(value) == "string" and value ~= "" then
                return value
            end
            if type(value) == "table" then
                local id = value.sessionId or value.SessionId or value.SessionID
                if type(id) == "string" and id ~= "" then
                    return id
                end
            end
        end
        return nil
    end

    local function onPullStatePayload(...)
        local payload = ...
        local sessionId = extractPullSessionId(...)

        -- FishingPullState fires a single table: { type, sessionId, progress }
        if type(payload) == "table" then
            if type(sessionId) == "string" then
                activePullSessionId = sessionId
            end

            local eventType = payload.type or payload.Type
            if eventType == "resolved" or eventType == "done" or eventType == "success" or eventType == "finished" then
                catchCount += 1
                if sessionId == nil or activePullSessionId == sessionId then
                    activePullSessionId = nil
                end
                setStatus("Pull resolved")
            elseif eventType == "progress" and type(sessionId) == "string" then
                activePullSessionId = sessionId
            end
            return
        end

        if type(sessionId) == "string" then
            activePullSessionId = sessionId
        end
    end

    local function connectPullSignal(remote)
        if not remote then
            return false
        end
        if type(remote.Connect) == "function" then
            local ok = pcall(function()
                remote:Connect(onPullStatePayload)
            end)
            if ok then
                return true
            end
        end
        if remote.OnClientEvent and type(remote.OnClientEvent.Connect) == "function" then
            local ok = pcall(function()
                remote.OnClientEvent:Connect(onPullStatePayload)
            end)
            if ok then
                return true
            end
        end
        return false
    end

    local function connectPullState()
        local remote = getBridgeRemote(nil, "FishingPullState")
        if not connectPullSignal(remote) then
            local service = getKnitService("FishingRewardService")
            connectPullSignal(service and service.FishingPullState)
        end

        local caught = getBridgeRemote(nil, "FishCaughtEvent")
        if not caught then
            local service = getKnitService("FishingRewardService")
            caught = service and service.FishCaught
        end
        if caught and type(caught.Connect) == "function" then
            pcall(function()
                caught:Connect(function()
                    catchCount += 1
                    activePullSessionId = nil
                    setStatus("Fish caught")
                end)
            end)
        elseif caught and caught.OnClientEvent and type(caught.OnClientEvent.Connect) == "function" then
            pcall(function()
                caught.OnClientEvent:Connect(function()
                    catchCount += 1
                    activePullSessionId = nil
                    setStatus("Fish caught")
                end)
            end)
        end
    end

    task.defer(connectPullState)

    -- Executors often isolate _G from game LocalScripts. Prefer getrenv()._G.
    local function getGameGlobals()
        if type(cachedGameGlobals) == "table" then
            return cachedGameGlobals
        end

        local candidates = {}
        local getrenvFn = rawget(_G, "getrenv")
        if type(getrenvFn) == "function" then
            local ok, renv = pcall(getrenvFn)
            if ok and type(renv) == "table" then
                if type(renv._G) == "table" then
                    table.insert(candidates, renv._G)
                end
                table.insert(candidates, renv)
            end
        end

        local getgenvFn = rawget(_G, "getgenv")
        if type(getgenvFn) == "function" then
            local ok, genv = pcall(getgenvFn)
            if ok and type(genv) == "table" then
                table.insert(candidates, genv)
            end
        end

        table.insert(candidates, _G)
        if type(shared) == "table" then
            table.insert(candidates, shared)
        end

        for _, env in ipairs(candidates) do
            if type(env) == "table" and type(rawget(env, "toggleAfkMode")) == "function" then
                cachedGameGlobals = env
                return cachedGameGlobals
            end
        end

        -- Keep best available env even if toggle isn't ready yet.
        cachedGameGlobals = candidates[1] or _G
        return cachedGameGlobals
    end

    local function getGameGlobal(name)
        local env = getGameGlobals()
        if type(env) ~= "table" then
            return nil
        end
        local value = rawget(env, name)
        if value ~= nil then
            return value
        end
        -- Refresh cache once if missing (FishingController may load later).
        cachedGameGlobals = nil
        env = getGameGlobals()
        return type(env) == "table" and rawget(env, name) or nil
    end

    resolveGameAfkToggle = function()
        local toggle = getGameGlobal("toggleAfkMode")
        if type(toggle) == "function" then
            return toggle
        end
        return nil
    end

    getGameAfkFlag = function()
        local flag = getGameGlobal("afkMode")
        if flag ~= nil then
            return flag == true
        end
        return _G.afkMode == true or LocalPlayer:GetAttribute("AfkMode") == true
    end

    getGameAfkLoopTask = function()
        return getGameGlobal("afkLoopTask")
    end

    local function getExecutorFireSignal()
        local fire = rawget(_G, "firesignal")
        if type(fire) == "function" then
            return fire
        end
        local syn = rawget(_G, "syn")
        if type(syn) == "table" and type(syn.fire_signal) == "function" then
            return syn.fire_signal
        end
        local getgenvFn = rawget(_G, "getgenv")
        if type(getgenvFn) == "function" then
            local ok, genv = pcall(getgenvFn)
            if ok and type(genv) == "table" and type(rawget(genv, "firesignal")) == "function" then
                return rawget(genv, "firesignal")
            end
        end
        return nil
    end

    local function getExecutorGetConnections()
        local getconns = rawget(_G, "getconnections")
        if type(getconns) == "function" then
            return getconns
        end
        local syn = rawget(_G, "syn")
        if type(syn) == "table" and type(syn.getconnections) == "function" then
            return syn.getconnections
        end
        local getgenvFn = rawget(_G, "getgenv")
        if type(getgenvFn) == "function" then
            local ok, genv = pcall(getgenvFn)
            if ok and type(genv) == "table" and type(rawget(genv, "getconnections")) == "function" then
                return rawget(genv, "getconnections")
            end
        end
        return nil
    end

    local function activateGuiButton(button)
        if not (button and button:IsA("GuiButton")) then
            return false
        end
        local fireSignal = getExecutorFireSignal()
        if fireSignal then
            local ok = pcall(fireSignal, button.MouseButton1Click)
            if ok then
                return true
            end
        end
        local getconns = getExecutorGetConnections()
        if getconns then
            local ok = pcall(function()
                for _, conn in ipairs(getconns(button.MouseButton1Click)) do
                    if conn.Fire then
                        conn:Fire()
                    elseif type(conn.Function) == "function" then
                        conn.Function()
                    end
                end
            end)
            if ok then
                return true
            end
        end
        local ok = pcall(function()
            firesignal(button.Activated)
        end)
        return ok == true
    end

    findAfkGuiButton = function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        if not playerGui then
            return nil
        end

        local preferred = {
            playerGui:FindFirstChild("AfkButtonGUI", true),
            playerGui:FindFirstChild("AfkSwitchGUI", true),
            playerGui:FindFirstChild("HUD"),
        }
        for _, root in ipairs(preferred) do
            if root then
                local btn = root:FindFirstChild("AfkButton", true)
                if btn and btn:IsA("GuiButton") then
                    return btn
                end
                local image = root:FindFirstChild("ImageButton", true)
                if image and image:IsA("GuiButton") and (image.Parent and image.Parent.Name == "AfkButton") then
                    return image
                end
            end
        end

        for _, descendant in ipairs(playerGui:GetDescendants()) do
            if descendant:IsA("GuiButton") then
                local name = string.lower(descendant.Name)
                if name == "afkbutton" or name:find("afk", 1, true) then
                    return descendant
                end
                local parent = descendant.Parent
                if parent and string.lower(parent.Name) == "afkbutton" then
                    return descendant
                end
            end
        end
        return nil
    end

    local function clickAfkGuiButton()
        local button = findAfkGuiButton()
        if not button then
            return false, "AFK button not found in PlayerGui"
        end
        if activateGuiButton(button) then
            return true
        end
        return false, "Could not fire AFK button click"
    end

    local function waitForToggleAfkMode(timeoutSec)
        local deadline = tick() + (timeoutSec or 15)
        while tick() < deadline do
            cachedGameGlobals = nil
            if resolveGameAfkToggle() then
                return true
            end
            -- Button may exist even before we can see game _G.
            if findAfkGuiButton() then
                return true
            end
            task.wait(0.25)
        end
        cachedGameGlobals = nil
        return resolveGameAfkToggle() ~= nil or findAfkGuiButton() ~= nil
    end

    local function isDrivingBoat()
        local drivingGlobal = getGameGlobal("isDrivingBoat")
        if type(drivingGlobal) == "function" then
            local ok, result = pcall(drivingGlobal)
            if ok then
                return result == true
            end
        end
        return LocalPlayer:GetAttribute("DrivingBoat") == true
    end

    local function ensureFloaterEquipped()
        local ok, owned = invokeRemote("RodShopRemotes", "GetOwnedItems")
        if not ok or type(owned) ~= "table" then
            return false, owned
        end

        local equipped = owned.EquippedFloater or owned.EquippedFloaterId
        if type(equipped) == "string" and equipped ~= "" then
            return true, equipped
        end

        local bestId = nil
        local floaters = owned.OwnedFloaters or owned.Floaters or owned.Owned
        if type(floaters) == "table" then
            for _, entry in pairs(floaters) do
                if type(entry) == "string" and entry ~= "" then
                    bestId = entry
                    break
                elseif type(entry) == "table" then
                    bestId = entry.Id or entry.FloaterId or entry.Name or bestId
                elseif type(entry) == "number" then
                    bestId = tostring(entry)
                end
            end
        end

        if not bestId then
            return false, "No floater owned"
        end

        local okEquip, err = fireRemote("RodShopRemotes", "EquipFloater", bestId)
        if not okEquip then
            return false, err
        end
        return true, bestId
    end

    local function callGameAfkToggle()
        local toggle = resolveGameAfkToggle()
        if type(toggle) == "function" then
            local ok, result = pcall(toggle)
            if ok then
                return true, result
            end
            return false, tostring(result)
        end
        return false, "toggleAfkMode missing"
    end

    local function forceEnableViaGameGlobals()
        local forceEnable = getGameGlobal("forceEnableAfkModeForRestore")
        if type(forceEnable) == "function" then
            local ok, result = pcall(forceEnable)
            if ok and (result == true or getGameAfkFlag()) then
                return true
            end
        end

        local startLoop = getGameGlobal("startAfkLoop")
        local env = getGameGlobals()
        if type(env) == "table" then
            pcall(function()
                rawset(env, "afkMode", true)
            end)
        end
        pcall(function()
            fireRemote(nil, "SetAfkMode", true)
        end)
        if type(startLoop) == "function" then
            local ok = pcall(startLoop)
            if ok and getGameAfkFlag() then
                return true
            end
        end
        return getGameAfkFlag() == true
    end

    local function getEquippedRodTool()
        local character = getCharacter()
        if not character then
            return nil
        end
        local tool = character:FindFirstChildOfClass("Tool")
        if tool then
            return tool
        end
        return nil
    end

    local function getEquippedFloaterId()
        local ok, owned = invokeRemote("RodShopRemotes", "GetOwnedItems")
        if ok and type(owned) == "table" then
            local equipped = owned.EquippedFloater or owned.EquippedFloaterId
            if type(equipped) == "string" and equipped ~= "" then
                return equipped
            end
        end
        local okEquip, floaterId = ensureFloaterEquipped()
        if okEquip and type(floaterId) == "string" then
            return floaterId
        end
        return nil
    end

    local function resolveCastTarget(throwDistance)
        local hrp = getHumanoidRootPart()
        if not hrp then
            return nil, nil, "No HumanoidRootPart"
        end

        local look = hrp.CFrame.LookVector
        local flatLook = Vector3.new(look.X, 0, look.Z)
        if flatLook.Magnitude < 0.05 then
            flatLook = Vector3.new(0, 0, -1)
        else
            flatLook = flatLook.Unit
        end

        local distance = math.clamp(tonumber(throwDistance) or 35, 15, 80)
        local startPos = Vector3.new(hrp.Position.X, hrp.Position.Y + 1.5, hrp.Position.Z) + flatLook * 2
        local aimPos = startPos + flatLook * distance

        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Exclude
        local exclude = { getCharacter() }
        local boats = Workspace:FindFirstChild("Boats")
        if boats then
            table.insert(exclude, boats)
        end
        rayParams.FilterDescendantsInstances = exclude

        local endPos = aimPos
        local hitWater = false
        for drop = 0, 80, 2 do
            local origin = Vector3.new(aimPos.X, aimPos.Y + 40 - drop, aimPos.Z)
            local result = Workspace:Raycast(origin, Vector3.new(0, -120, 0), rayParams)
            if result then
                local inst = result.Instance
                local name = string.lower(inst.Name)
                local parentName = inst.Parent and string.lower(inst.Parent.Name) or ""
                local looksLikeWater = inst:IsA("Terrain")
                    or name:find("water", 1, true)
                    or name:find("sea", 1, true)
                    or name:find("ocean", 1, true)
                    or name:find("lake", 1, true)
                    or name:find("river", 1, true)
                    or parentName:find("water", 1, true)
                    or (inst:IsA("BasePart") and not inst.CanCollide and inst.Transparency > 0.3)

                if looksLikeWater then
                    endPos = Vector3.new(aimPos.X, result.Position.Y + 0.5, aimPos.Z)
                    hitWater = true
                    break
                end

                -- Keep the first solid hit as fallback landing.
                endPos = Vector3.new(aimPos.X, result.Position.Y + 0.5, aimPos.Z)
                break
            end
        end

        return startPos, endPos, hitWater and "water" or "fallback"
    end

    local lastCastAt = 0
    local castCooldownSec = 0.5
    local confirmCastDelaySec = 1
    local instantTapDelaySec = 0.03
    local instantTapCount = 35
    local instantCatchRunning = false
    local instantCatchLoopId = 0

    local function extractBiteSessionId(result)
        if type(result) == "string" and result ~= "" then
            return result
        end
        if type(result) ~= "table" then
            return nil
        end
        local id = result.SessionId or result.sessionId or result.SessionID
        if type(id) == "string" and id ~= "" then
            return id
        end
        return nil
    end

    local function finishPullSession(sessionId)
        if type(sessionId) ~= "string" or sessionId == "" then
            return false
        end

        activePullSessionId = sessionId
        fireRemote("FishingRemotes", "StartPulling")
        fireRemote(nil, "FishingPullInput", sessionId, "begin")

        local taps = math.max(5, tonumber(instantTapCount) or 35)
        local delay = math.max(0.01, tonumber(instantTapDelaySec) or 0.03)
        for _ = 1, taps do
            if type(activePullSessionId) ~= "string" or activePullSessionId ~= sessionId then
                break
            end
            fireRemote(nil, "FishingPullInput", sessionId, "tap")
            task.wait(delay)
        end

        -- Extra burst in case server needs a few more taps after progress sync.
        for _ = 1, 8 do
            if type(activePullSessionId) ~= "string" or activePullSessionId ~= sessionId then
                break
            end
            fireRemote(nil, "FishingPullInput", sessionId, "tap")
            task.wait(0.02)
        end

        return true
    end

    -- Instant catch: remote cast -> bite session -> begin + spam taps (skip AFK / throw animation).
    local function instantCatchOnce()
        if isDrivingBoat() then
            return false, "Driving boat"
        end
        if getGameGlobal("isParticipatingInBossEvent") == true then
            return false, "In boss raid"
        end

        equipAnyRod()
        local floaterId = getEquippedFloaterId()
        local rodTool = getEquippedRodTool()
        if not rodTool then
            if not equipAnyRod() then
                return false, "No rod equipped"
            end
            rodTool = getEquippedRodTool()
        end
        if not rodTool then
            return false, "No rod equipped"
        end

        local startPos, endPos, targetKind = resolveCastTarget(40)
        if not (startPos and endPos) then
            return false, tostring(targetKind)
        end

        local rodName = rodTool.Name
        local lineStyle = {
            Width = 0.16,
            Color = Color3.fromRGB(0, 255, 255),
        }
        local throwPower = 10

        fireRemote("FishingRemotes", "StartFishing", rodName, floaterId)
        task.wait(0.05)

        local okThrow, throwErr = fireRemote(
            "FishingRemotes",
            "ThrowFloater",
            startPos,
            endPos,
            rodName,
            floaterId,
            lineStyle,
            throwPower
        )
        if not okThrow then
            return false, "ThrowFloater failed: " .. tostring(throwErr)
        end

        local confirmDelay = math.max(0.15, tonumber(confirmCastDelaySec) or 1)
        task.wait(confirmDelay)
        fireRemote("FishingRemotes", "ConfirmFloatingCast", endPos)
        task.wait(0.1)

        local okBite, biteResult = invokeRemote(nil, "RequestFishBite", endPos)
        if not okBite then
            return false, "RequestFishBite failed: " .. tostring(biteResult)
        end

        if type(biteResult) == "table" and biteResult.isImpossible == true then
            return false, "Bite rejected: " .. tostring(biteResult.reason or "impossible")
        end

        local sessionId = extractBiteSessionId(biteResult)
        if not sessionId then
            return false, "No SessionId from bite"
        end

        activePullSessionId = sessionId

        -- Auto-catch bites may resolve after begin; still spam taps for normal bites.
        if type(biteResult) == "table" and biteResult.isAutoCatch == true then
            fireRemote("FishingRemotes", "StartPulling")
            fireRemote(nil, "FishingPullInput", sessionId, "begin")
            task.wait(0.25)
            for _ = 1, 10 do
                fireRemote(nil, "FishingPullInput", sessionId, "tap")
                task.wait(0.02)
            end
            return true, "autoCatch:" .. sessionId
        end

        finishPullSession(sessionId)
        return true, "instant:" .. sessionId
    end

    -- Prefer the game's throwFloater (_G.ForceBossCast). Fallback to FishingRemotes cast.
    local function castFloaterOnce()
        if isDrivingBoat() then
            return false, "Driving boat"
        end
        if getGameGlobal("isParticipatingInBossEvent") == true then
            return false, "In boss raid"
        end

        equipAnyRod()
        local floaterId = getEquippedFloaterId()
        local rodTool = getEquippedRodTool()
        if not rodTool then
            local okEquip = equipAnyRod()
            if not okEquip then
                return false, "No rod equipped"
            end
            rodTool = getEquippedRodTool()
        end
        if not rodTool then
            return false, "No rod equipped"
        end

        -- 1) Game client throw (creates local floater + fires remotes)
        local gameThrow = getGameGlobal("ForceBossCast")
        if type(gameThrow) ~= "function" then
            gameThrow = getGameGlobal("throwFloater")
        end
        if type(gameThrow) == "function" then
            local ok, result = pcall(function()
                return gameThrow(1)
            end)
            if ok and result ~= false then
                local resumeThrow = getGameGlobal("resumeAfkAutoThrow")
                if type(resumeThrow) == "function" then
                    pcall(resumeThrow)
                end
                return true, "ForceBossCast"
            end
        end

        -- 2) Remote-only cast fallback (same as instant, without finishing pull here)
        local startPos, endPos, targetKind = resolveCastTarget(40)
        if not (startPos and endPos) then
            return false, tostring(targetKind)
        end

        local rodName = rodTool.Name
        local lineStyle = {
            Width = 0.16,
            Color = Color3.fromRGB(0, 255, 255),
        }
        local throwPower = 10

        fireRemote("FishingRemotes", "StartFishing", rodName, floaterId)
        task.wait(0.05)
        local okThrow, throwErr = fireRemote(
            "FishingRemotes",
            "ThrowFloater",
            startPos,
            endPos,
            rodName,
            floaterId,
            lineStyle,
            throwPower
        )
        if not okThrow then
            return false, "ThrowFloater failed: " .. tostring(throwErr)
        end

        local confirmDelay = math.max(0.15, tonumber(confirmCastDelaySec) or 1)
        task.wait(confirmDelay)
        fireRemote("FishingRemotes", "ConfirmFloatingCast", endPos)
        task.wait(0.1)

        local okBite, biteResult = invokeRemote(nil, "RequestFishBite", endPos)
        if okBite then
            local sessionId = extractBiteSessionId(biteResult)
            if sessionId then
                activePullSessionId = sessionId
            end
        end

        return true, "remote:" .. tostring(targetKind)
    end

    local function maybeAutoCast()
        if type(activePullSessionId) == "string" and activePullSessionId ~= "" then
            return false, "pulling"
        end
        if tick() - lastCastAt < castCooldownSec then
            return false, "cooldown"
        end
        lastCastAt = tick()
        return castFloaterOnce()
    end

    -- Prefer game-env toggle; fall back to AFK GUI button / forceEnable helpers.
    setGameAfkMode = function(wantEnabled)
        wantEnabled = wantEnabled == true

        if wantEnabled and isDrivingBoat() then
            return false, "Exit the boat before enabling AFK fishing"
        end

        if wantEnabled and getGameGlobal("isParticipatingInBossEvent") == true then
            return false, "Cannot AFK while in a boss raid"
        end

        waitForToggleAfkMode(8)

        if wantEnabled then
            equipAnyRod()
            ensureFloaterEquipped()
        end

        local currentlyOn = getGameAfkFlag()
        if currentlyOn == wantEnabled then
            if wantEnabled and not getGameAfkLoopTask() then
                if not forceEnableViaGameGlobals() then
                    local toggle = resolveGameAfkToggle()
                    if toggle then
                        pcall(toggle)
                        task.wait(0.2)
                        if getGameAfkFlag() ~= true then
                            pcall(toggle)
                        end
                    else
                        clickAfkGuiButton()
                    end
                end
            end
            return true, wantEnabled
        end

        -- 1) Direct game toggle via getrenv()._G
        local toggled, toggleResult = callGameAfkToggle()
        if toggled then
            local nowOn = toggleResult == true or getGameAfkFlag()
            if nowOn == wantEnabled then
                return true, nowOn
            end
            if wantEnabled then
                task.wait(2.1)
                equipAnyRod()
                ensureFloaterEquipped()
                toggled, toggleResult = callGameAfkToggle()
                nowOn = toggleResult == true or getGameAfkFlag()
                if nowOn == wantEnabled then
                    return true, nowOn
                end
            end
        end

        -- 2) Click the in-game AFK button
        local clicked, clickErr = clickAfkGuiButton()
        if clicked then
            task.wait(0.35)
            local nowOn = getGameAfkFlag()
            if nowOn == wantEnabled then
                return true, nowOn
            end
            if wantEnabled and not nowOn then
                task.wait(2.1)
                clickAfkGuiButton()
                task.wait(0.35)
                nowOn = getGameAfkFlag()
                if nowOn == wantEnabled then
                    return true, nowOn
                end
            end
        end

        -- 3) Last resort for enable: forceEnable / startAfkLoop globals
        if wantEnabled then
            if forceEnableViaGameGlobals() then
                return true, true
            end
        else
            local stopLoop = getGameGlobal("stopAfkLoop")
            if type(stopLoop) == "function" then
                pcall(stopLoop)
            end
            fireRemote(nil, "SetAfkMode", false)
            local env = getGameGlobals()
            if type(env) == "table" then
                pcall(function()
                    rawset(env, "afkMode", false)
                end)
            end
            if getGameAfkFlag() ~= true then
                return true, false
            end
        end

        local detail = toggled and "toggle blocked" or tostring(toggleResult)
        if clickErr then
            detail = detail .. " | " .. tostring(clickErr)
        end
        return false, wantEnabled
            and ("Could not enable AFK (" .. detail .. "). Try the in-game AFK button once, then toggle again.")
            or ("Could not disable AFK (" .. detail .. ")")
    end

    local function tapPullOnce()
        if type(activePullSessionId) ~= "string" or activePullSessionId == "" then
            return false
        end
        return fireRemote(nil, "FishingPullInput", activePullSessionId, "tap")
    end

    MainTab:CreateSection("Status")

    statusParagraph = MainTab:CreateParagraph({
        Title = "Fishing Status",
        Content = "Waiting for FishingController...",
    })

    MainTab:CreateButton({
        Name = "Refresh Status",
        Callback = function()
            cachedGameGlobals = nil
            local env = getGameGlobals()
            local envLabel = "unknown"
            if env == _G then
                envLabel = "script _G"
            elseif type(rawget(_G, "getrenv")) == "function" then
                envLabel = "getrenv/_G"
            end
            setStatus(string.format(
                "Env: %s | toggle: %s | afkLoop: %s | AFK btn: %s | boat: %s",
                envLabel,
                resolveGameAfkToggle() and "ready" or "missing",
                getGameAfkLoopTask() and "running" or "none",
                findAfkGuiButton() and "found" or "missing",
                isDrivingBoat() and "yes" or "no"
            ))
        end,
    })

    MainTab:CreateSection("Automation")

    MainTab:CreateInput({
        Name = "Confirm Cast Delay (seconds)",
        PlaceholderText = "Wait after ThrowFloater before ConfirmFloatingCast",
        Flag = "fm_confirm_cast_delay",
        CurrentValue = tostring(confirmCastDelaySec),
        Callback = function(value)
            confirmCastDelaySec = math.max(0.15, tonumber(value) or 1)
        end,
    })

    MainTab:CreateInput({
        Name = "Instant Loop Delay (seconds)",
        PlaceholderText = "Delay between instant catch cycles",
        Flag = "fm_cast_cooldown",
        CurrentValue = tostring(castCooldownSec),
        Callback = function(value)
            castCooldownSec = math.max(0.2, tonumber(value) or 2.5)
        end,
    })

    MainTab:CreateInput({
        Name = "Instant Tap Delay (seconds)",
        PlaceholderText = "Delay between pull taps",
        Flag = "fm_instant_tap_delay",
        CurrentValue = tostring(instantTapDelaySec),
        Callback = function(value)
            instantTapDelaySec = math.max(0.01, tonumber(value) or 0.03)
        end,
    })

    MainTab:CreateInput({
        Name = "Instant Tap Count",
        PlaceholderText = "How many taps to finish a catch",
        Flag = "fm_instant_tap_count",
        CurrentValue = tostring(instantTapCount),
        Callback = function(value)
            instantTapCount = math.max(5, math.floor(tonumber(value) or 35))
        end,
    })

    MainTab:CreateToggle({
        Name = "Instant Catch",
        Flag = "fm_instant_catch",
        CurrentValue = false,
        Callback = function(enabled)
            instantCatchRunning = enabled == true
            autoFishRunning = false
            if not instantCatchRunning then
                if type(activePullSessionId) == "string" then
                    fireRemote(nil, "FishingPullInput", activePullSessionId, "cancel")
                    activePullSessionId = nil
                end
                fireRemote("FishingRemotes", "StopFishing")
                setStatus("Instant Catch stopped")
                return
            end

            -- Stop AFK mode if it was on — instant catch bypasses it.
            pcall(setGameAfkMode, false)

            instantCatchLoopId += 1
            local loopId = instantCatchLoopId
            setStatus("Instant Catch started")
            mountNotify({
                Title = "Instant Catch",
                Content = "Bypassing AFK — cast + instant pull",
            })

            task.spawn(function()
                while instantCatchRunning and loopId == instantCatchLoopId do
                    if isDrivingBoat() then
                        setStatus("Paused: exit boat")
                        task.wait(1)
                    else
                        local ok, result = instantCatchOnce()
                        if ok then
                            catchCount += 1
                            setStatus("Caught! " .. tostring(result))
                        else
                            setStatus("Instant catch: " .. tostring(result))
                        end
                        activePullSessionId = nil
                        task.wait(math.max(0.2, castCooldownSec))
                    end
                end
            end)
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Fish (Game AFK)",
        Flag = "fm_auto_fish",
        CurrentValue = false,
        Callback = function(enabled)
            autoFishRunning = enabled == true
            if autoFishRunning then
                instantCatchRunning = false
            end
            if not autoFishRunning then
                local ok, err = setGameAfkMode(false)
                setStatus(ok and "Auto Fish stopped" or ("Stop failed: " .. tostring(err)))
                return
            end

            autoFishLoopId += 1
            local loopId = autoFishLoopId
            setStatus("Starting game AFK fishing...")

            task.spawn(function()
                local ok, err = setGameAfkMode(true)
                if not ok then
                    setStatus("AFK toggle failed, using direct cast: " .. tostring(err))
                    mountNotify({
                        Title = "Auto Fish",
                        Content = "AFK unavailable — casting floater directly",
                    })
                else
                    setStatus("Game AFK fishing enabled")
                    mountNotify({
                        Title = "Auto Fish",
                        Content = "AFK on — also forcing floater throws",
                    })
                end

                local castOk, castMsg = castFloaterOnce()
                setStatus(castOk and ("Cast: " .. tostring(castMsg)) or ("Cast failed: " .. tostring(castMsg)))

                while autoFishRunning and loopId == autoFishLoopId do
                    cachedGameGlobals = nil
                    if isDrivingBoat() then
                        setStatus("Paused: exit boat to resume casting")
                    else
                        if getGameAfkFlag() ~= true then
                            pcall(setGameAfkMode, true)
                        end

                        local resumeThrow = getGameGlobal("resumeAfkAutoThrow")
                        if type(resumeThrow) == "function" then
                            pcall(resumeThrow)
                        end

                        local okCast, castResult = maybeAutoCast()
                        if okCast then
                            local sessionId = activePullSessionId
                            if type(sessionId) == "string" and sessionId ~= "" then
                                finishPullSession(sessionId)
                                setStatus("AFK cast + instant pull")
                            else
                                setStatus("Threw floater (" .. tostring(castResult) .. ")")
                            end
                        elseif castResult == "pulling" then
                            if type(activePullSessionId) == "string" then
                                finishPullSession(activePullSessionId)
                            end
                            setStatus("Finishing pull: " .. tostring(activePullSessionId))
                        elseif castResult ~= "cooldown" then
                            setStatus("Cast: " .. tostring(castResult))
                        else
                            setStatus(getGameAfkFlag() and "AFK active / cast cooldown" or "Cast cooldown")
                        end
                    end
                    task.wait(math.max(0.5, fishDelaySec))
                end
            end)
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Pull (Spam Tap)",
        Flag = "fm_auto_pull",
        CurrentValue = false,
        Callback = function(enabled)
            autoPullRunning = enabled == true
            if not autoPullRunning then
                setStatus("Auto Pull stopped")
                return
            end
            autoPullLoopId += 1
            local loopId = autoPullLoopId
            setStatus("Auto Pull started")
            task.spawn(function()
                while autoPullRunning and loopId == autoPullLoopId do
                    pcall(tapPullOnce)
                    task.wait(math.max(0.03, pullTapDelaySec))
                end
            end)
        end,
    })

    MainTab:CreateToggle({
        Name = "Anti AFK Kick",
        Flag = "fm_anti_afk",
        CurrentValue = false,
        Callback = function(enabled)
            autoAntiAfkRunning = enabled == true
            if not autoAntiAfkRunning then
                return
            end
            autoAntiAfkLoopId += 1
            local loopId = autoAntiAfkLoopId
            task.spawn(function()
                while autoAntiAfkRunning and loopId == autoAntiAfkLoopId do
                    antiAfkKick()
                    task.wait(60)
                end
            end)
        end,
    })

    MainTab:CreateSection("Manual")

    MainTab:CreateButton({
        Name = "Instant Catch Once",
        Callback = function()
            local ok, result = instantCatchOnce()
            mountNotify({
                Title = "Instant Catch",
                Content = ok and tostring(result) or tostring(result),
            })
            setStatus(ok and ("Caught: " .. tostring(result)) or ("Failed: " .. tostring(result)))
            if ok then
                catchCount += 1
            end
            activePullSessionId = nil
        end,
    })

    MainTab:CreateButton({
        Name = "Equip Rod",
        Callback = function()
            local ok = equipAnyRod()
            mountNotify({
                Title = "Rod",
                Content = ok and "Rod equipped" or "No rod found in backpack",
            })
        end,
    })

    MainTab:CreateButton({
        Name = "Equip Floater",
        Callback = function()
            local ok, result = ensureFloaterEquipped()
            mountNotify({
                Title = "Floater",
                Content = ok and ("Equipped " .. tostring(result)) or tostring(result),
            })
        end,
    })

    MainTab:CreateButton({
        Name = "Throw Floater / Bait",
        Callback = function()
            local ok, result = castFloaterOnce()
            mountNotify({
                Title = "Cast",
                Content = ok and ("Threw via " .. tostring(result)) or tostring(result),
            })
            setStatus(ok and ("Cast ok: " .. tostring(result)) or ("Cast failed: " .. tostring(result)))
        end,
    })

    MainTab:CreateButton({
        Name = "Toggle Game AFK",
        Callback = function()
            cachedGameGlobals = nil
            local ok, result = setGameAfkMode(not getGameAfkFlag())
            mountNotify({
                Title = "AFK",
                Content = ok and ("AFK = " .. tostring(getGameAfkFlag())) or tostring(result),
            })
            setStatus(ok and ("Toggled AFK -> " .. tostring(getGameAfkFlag())) or tostring(result))
        end,
    })

    MainTab:CreateButton({
        Name = "Click AFK Button",
        Callback = function()
            local ok, err = clickAfkGuiButton()
            task.wait(0.2)
            mountNotify({
                Title = "AFK Button",
                Content = ok and ("Clicked | AFK=" .. tostring(getGameAfkFlag())) or tostring(err),
            })
            setStatus(ok and ("Clicked AFK button | AFK=" .. tostring(getGameAfkFlag())) or tostring(err))
        end,
    })

    MainTab:CreateButton({
        Name = "Stop Fishing / AFK",
        Callback = function()
            instantCatchRunning = false
            autoFishRunning = false
            setGameAfkMode(false)
            fireRemote("FishingRemotes", "StopFishing")
            if type(activePullSessionId) == "string" and activePullSessionId ~= "" then
                fireRemote(nil, "FishingPullInput", activePullSessionId, "cancel")
                activePullSessionId = nil
            end
            setStatus("Stopped")
        end,
    })

    task.defer(function()
        waitForToggleAfkMode(25)
        setStatus("Ready — use Instant Catch")
    end)
end

-- */  Sell Tab  /* --
do
    local SellTab = Window:CreateTab("Sell", "banknote")

    local inventoryParagraph
    local autoSellRunning = false
    local autoSellLoopId = 0
    local autoSellDelaySec = 3
    local maxSellRarity = "Legendary"
    local skipFavorites = true

    local function refreshInventoryParagraph()
        local ok, inventory = invokeRemote("FishermanShopRemotes", "GetFishInventory")
        if not ok then
            ok, inventory = invokeRemote(nil, "GetFishInventory")
        end
        local content
        if not ok then
            content = "Failed: " .. tostring(inventory)
        else
            local ids = collectFishIds(inventory, {
                MaxRarityRank = RARITY_ORDER[maxSellRarity] or 5,
                SkipFavorites = skipFavorites,
            })
            content = string.format(
                "Inventory entries: %d\nSellable (filter): %d\nMax rarity: %s\nSkip favorites: %s",
                countTable(inventory and (inventory.Fish or inventory.Items or inventory)),
                #ids,
                tostring(maxSellRarity),
                tostring(skipFavorites)
            )
        end
        if inventoryParagraph and inventoryParagraph.Set then
            inventoryParagraph:Set({
                Title = "Fish Inventory",
                Content = content,
            })
        end
        return ok, inventory
    end

    local function sellAllOnce()
        local ok = fireRemote("FishermanShopRemotes", "SellAllFish")
        if ok then
            return true, "SellAllFish fired"
        end

        local okInv, inventory = invokeRemote("FishermanShopRemotes", "GetFishInventory")
        if not okInv then
            okInv, inventory = invokeRemote(nil, "GetFishInventory")
        end
        if not okInv then
            return false, inventory
        end

        local ids = collectFishIds(inventory, {
            MaxRarityRank = RARITY_ORDER[maxSellRarity] or 5,
            SkipFavorites = skipFavorites,
        })
        if #ids == 0 then
            return true, "Nothing to sell"
        end

        local okSell, err = fireRemote("FishermanShopRemotes", "SellSelectedFish", ids)
        if okSell then
            return true, string.format("Sold %d fish", #ids)
        end
        return false, err
    end

    SellTab:CreateSection("Inventory")

    inventoryParagraph = SellTab:CreateParagraph({
        Title = "Fish Inventory",
        Content = "Press Refresh",
    })

    SellTab:CreateButton({
        Name = "Refresh Inventory",
        Callback = function()
            refreshInventoryParagraph()
        end,
    })

    SellTab:CreateDropdown({
        Name = "Max Sell Rarity",
        Options = { "Common", "Uncommon", "Rare", "Epic", "Legendary", "Mythic", "Secret", "Monster" },
        CurrentOption = { "Legendary" },
        Flag = "fm_max_sell_rarity",
        Callback = function(option)
            maxSellRarity = rayfieldDropdownFirst(option) or "Legendary"
            refreshInventoryParagraph()
        end,
    })

    SellTab:CreateToggle({
        Name = "Skip Favorites",
        Flag = "fm_skip_favorites",
        CurrentValue = true,
        Callback = function(enabled)
            skipFavorites = enabled == true
            refreshInventoryParagraph()
        end,
    })

    SellTab:CreateSection("Sell")

    SellTab:CreateInput({
        Name = "Auto Sell Delay (seconds)",
        PlaceholderText = "Seconds between auto sells",
        Flag = "fm_auto_sell_delay",
        CurrentValue = tostring(autoSellDelaySec),
        Callback = function(value)
            autoSellDelaySec = math.max(0.5, tonumber(value) or 3)
        end,
    })

    SellTab:CreateButton({
        Name = "Sell Now",
        Callback = function()
            local ok, msg = sellAllOnce()
            mountNotify({
                Title = "Sell",
                Content = ok and tostring(msg) or ("Failed: " .. tostring(msg)),
            })
            refreshInventoryParagraph()
        end,
    })

    SellTab:CreateToggle({
        Name = "Auto Sell",
        Flag = "fm_auto_sell",
        CurrentValue = false,
        Callback = function(enabled)
            autoSellRunning = enabled == true
            if not autoSellRunning then
                return
            end
            autoSellLoopId += 1
            local loopId = autoSellLoopId
            task.spawn(function()
                while autoSellRunning and loopId == autoSellLoopId do
                    pcall(sellAllOnce)
                    pcall(refreshInventoryParagraph)
                    task.wait(math.max(0.5, autoSellDelaySec))
                end
            end)
        end,
    })

    task.defer(refreshInventoryParagraph)
end

-- */  World Tab  /* --
do
    local WorldTab = Window:CreateTab("World", "map")

    local islandNames = {}
    local islandByName = {}
    for _, island in ipairs(ISLAND_TELEPORTS) do
        table.insert(islandNames, island.Name)
        islandByName[island.Name] = island.Position
    end

    local selectedIsland = islandNames[1]
    local autoIslandRunning = false
    local autoIslandLoopId = 0

    WorldTab:CreateSection("Islands")

    WorldTab:CreateDropdown({
        Name = "Island",
        Options = islandNames,
        CurrentOption = { selectedIsland },
        Flag = "fm_island",
        Callback = function(option)
            selectedIsland = rayfieldDropdownFirst(option) or selectedIsland
        end,
    })

    WorldTab:CreateButton({
        Name = "Teleport to Island",
        Callback = function()
            local position = islandByName[selectedIsland]
            if not position then
                mountNotify({ Title = "Teleport", Content = "Unknown island" })
                return
            end
            local ok, err = teleportToPosition(position)
            mountNotify({
                Title = "Teleport",
                Content = ok and ("Teleported to " .. selectedIsland) or tostring(err),
            })
        end,
    })

    WorldTab:CreateSection("Sea / Base")

    WorldTab:CreateButton({
        Name = "Request Sea (Explore)",
        Callback = function()
            local ok, err = fireRemote("SeaLobbyRemotes", "RequestSeaLobby")
            mountNotify({
                Title = "Sea",
                Content = ok and "Requested sea lobby" or tostring(err),
            })
        end,
    })

    WorldTab:CreateButton({
        Name = "Return to Base",
        Callback = function()
            local ok, err = fireRemote("SeaLobbyRemotes", "ReturnToBase")
            mountNotify({
                Title = "Base",
                Content = ok and "Returning to base" or tostring(err),
            })
        end,
    })

    WorldTab:CreateSection("Boat")

    WorldTab:CreateButton({
        Name = "Spawn Boat",
        Callback = function()
            local ok, err = fireRemote("BoatRemotes", "SpawnBoat")
            mountNotify({
                Title = "Boat",
                Content = ok and "SpawnBoat fired" or tostring(err),
            })
        end,
    })

    WorldTab:CreateButton({
        Name = "Respawn Boat",
        Callback = function()
            local ok, err = fireRemote("BoatRemotes", "RespawnBoat")
            mountNotify({
                Title = "Boat",
                Content = ok and "RespawnBoat fired" or tostring(err),
            })
        end,
    })

    WorldTab:CreateSection("Events")

    WorldTab:CreateButton({
        Name = "Check Active Events",
        Callback = function()
            local ok, result = invokeRemote(nil, "GetActiveEvents")
            if not ok then
                ok, result = callService("BossFishEventService", "GetActiveEvents")
            end
            local content
            if not ok then
                content = tostring(result)
            elseif type(result) == "table" then
                content = string.format("Active events: %d", countTable(result))
            else
                content = tostring(result)
            end
            mountNotify({ Title = "Events", Content = content })
        end,
    })

    WorldTab:CreateToggle({
        Name = "Stay at Selected Island",
        Flag = "fm_stay_island",
        CurrentValue = false,
        Callback = function(enabled)
            autoIslandRunning = enabled == true
            if not autoIslandRunning then
                return
            end
            autoIslandLoopId += 1
            local loopId = autoIslandLoopId
            task.spawn(function()
                while autoIslandRunning and loopId == autoIslandLoopId do
                    local position = islandByName[selectedIsland]
                    if position then
                        local hrp = getHumanoidRootPart()
                        if hrp and (hrp.Position - position).Magnitude > 120 then
                            teleportToPosition(position)
                        end
                    end
                    task.wait(3)
                end
            end)
        end,
    })
end

-- */  Gear Tab  /* --
do
    local GearTab = Window:CreateTab("Gear", "wrench")

    local gearParagraph
    local selectedRodId = nil
    local rodOptions = { "Refresh rods first" }
    local selectedPotionId = nil
    local potionOptions = { "Refresh potions first" }

    local function setGearStatus(text)
        if gearParagraph and gearParagraph.Set then
            gearParagraph:Set({
                Title = "Gear",
                Content = text,
            })
        end
    end

    local function extractShopList(data, keyHints)
        local lists = {}
        if type(data) ~= "table" then
            return lists
        end
        for _, key in ipairs(keyHints) do
            if type(data[key]) == "table" then
                return data[key]
            end
        end
        if data[1] ~= nil then
            return data
        end
        return data
    end

    local function refreshRods()
        local ok, data = invokeRemote("RodShopRemotes", "GetOwnedItems")
        if not ok then
            ok, data = invokeRemote("RodShopRemotes", "GetShopData")
        end
        local options = {}
        local list = extractShopList(data, { "OwnedRods", "Rods", "Items", "Owned", "Equipment" })
        for key, entry in pairs(list) do
            if type(entry) == "table" then
                local id = entry.Id or entry.RodId or entry.Name or key
                local label = entry.Name or entry.DisplayName or tostring(id)
                table.insert(options, tostring(label) .. " [" .. tostring(id) .. "]")
            elseif type(entry) == "string" or type(entry) == "number" then
                table.insert(options, tostring(entry))
            elseif type(key) == "string" and (entry == true or type(entry) == "number") then
                table.insert(options, key)
            end
        end
        table.sort(options)
        if #options == 0 then
            options = { "No rods found" }
        end
        rodOptions = options
        selectedRodId = options[1]
        setGearStatus("Rods loaded: " .. tostring(#options))
        return options
    end

    local function refreshPotions()
        local ok, data = invokeRemote("PotionShopRemotes", "GetShopData")
        local options = {}
        local list = extractShopList(data, { "Potions", "Items", "Shop", "Products" })
        for key, entry in pairs(list) do
            if type(entry) == "table" then
                local id = entry.Id or entry.PotionId or entry.Name or key
                local label = entry.Name or entry.DisplayName or tostring(id)
                table.insert(options, tostring(label) .. " [" .. tostring(id) .. "]")
            elseif type(key) == "string" then
                table.insert(options, key)
            end
        end
        table.sort(options)
        if #options == 0 then
            options = { "No potions found" }
        end
        potionOptions = options
        selectedPotionId = options[1]
        setGearStatus("Potions loaded: " .. tostring(#options))
        return options
    end

    local function parseBracketId(label)
        if type(label) ~= "string" then
            return label
        end
        local id = string.match(label, "%[(.-)%]$")
        return id or label
    end

    GearTab:CreateSection("Status")

    gearParagraph = GearTab:CreateParagraph({
        Title = "Gear",
        Content = "Refresh rods / potions to load shop data",
    })

    GearTab:CreateSection("Rods")

    local rodDropdown = GearTab:CreateDropdown({
        Name = "Owned / Shop Rod",
        Options = rodOptions,
        CurrentOption = { rodOptions[1] },
        Flag = "fm_rod",
        Callback = function(option)
            selectedRodId = rayfieldDropdownFirst(option)
        end,
    })

    GearTab:CreateButton({
        Name = "Refresh Rods",
        Callback = function()
            local options = refreshRods()
            if rodDropdown and rodDropdown.Refresh then
                rodDropdown:Refresh(options)
            elseif rodDropdown and rodDropdown.Set then
                pcall(function()
                    rodDropdown:Set(options)
                end)
            end
            mountNotify({ Title = "Rods", Content = "Loaded " .. tostring(#options) })
        end,
    })

    GearTab:CreateButton({
        Name = "Equip Selected Rod",
        Callback = function()
            local rodId = parseBracketId(selectedRodId)
            local ok, err = fireRemote("RodShopRemotes", "EquipRod", rodId)
            mountNotify({
                Title = "Equip Rod",
                Content = ok and ("Equipped " .. tostring(rodId)) or tostring(err),
            })
        end,
    })

    GearTab:CreateButton({
        Name = "Buy Selected Rod",
        Callback = function()
            local rodId = parseBracketId(selectedRodId)
            local ok, err = fireRemote("RodShopRemotes", "BuyRod", rodId)
            mountNotify({
                Title = "Buy Rod",
                Content = ok and ("BuyRod " .. tostring(rodId)) or tostring(err),
            })
        end,
    })

    GearTab:CreateSection("Potions")

    local potionDropdown = GearTab:CreateDropdown({
        Name = "Potion",
        Options = potionOptions,
        CurrentOption = { potionOptions[1] },
        Flag = "fm_potion",
        Callback = function(option)
            selectedPotionId = rayfieldDropdownFirst(option)
        end,
    })

    GearTab:CreateButton({
        Name = "Refresh Potions",
        Callback = function()
            local options = refreshPotions()
            if potionDropdown and potionDropdown.Refresh then
                potionDropdown:Refresh(options)
            end
            mountNotify({ Title = "Potions", Content = "Loaded " .. tostring(#options) })
        end,
    })

    GearTab:CreateButton({
        Name = "Buy Selected Potion",
        Callback = function()
            local potionId = parseBracketId(selectedPotionId)
            local ok, err = fireRemote("PotionShopRemotes", "BuyPotion", potionId)
            mountNotify({
                Title = "Potion",
                Content = ok and ("BuyPotion " .. tostring(potionId)) or tostring(err),
            })
        end,
    })

    GearTab:CreateSection("Rewards")

    GearTab:CreateButton({
        Name = "Claim Daily",
        Callback = function()
            local ok, result = invokeRemote("RewardRemotes", "ClaimDaily")
            local success = ok and (type(result) ~= "table" or result.Success ~= false)
            mountNotify({
                Title = "Daily",
                Content = success and "Claimed daily" or tostring(result),
            })
        end,
    })

    GearTab:CreateButton({
        Name = "Claim Time Reward",
        Callback = function()
            local ok, result = invokeRemote("RewardRemotes", "ClaimTime")
            local success = ok and (type(result) ~= "table" or result.Success ~= false)
            mountNotify({
                Title = "Time Reward",
                Content = success and "Claimed time reward" or tostring(result),
            })
        end,
    })

    GearTab:CreateButton({
        Name = "Upgrade Aquarium",
        Callback = function()
            local ok, err = fireRemote("AquariumRemotes", "UpgradeAquarium")
            if not ok then
                ok, err = callService("AquariumSystemService", "UpgradeAquarium")
            end
            mountNotify({
                Title = "Aquarium",
                Content = ok and "Upgrade requested" or tostring(err),
            })
        end,
    })
end

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "fish_and_monsters", tabIcon = "map-pin" })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, {
    replicatedStorage = ReplicatedStorage,
    tabIcon = "boxes",
})


-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, {
    gamePath = "sempatpanick/fish_and_monsters",
    tabIcon = "video",
})

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/fish_and_monsters",
    rayfieldLibrary = SempatLibrary,
    tabIcon = "settings",
})
