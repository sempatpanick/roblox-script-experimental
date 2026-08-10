local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Workspace = game:GetService("Workspace")

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
            assert(okGet and type(source) == "string", "[sempat/find_the_chameleons] failed to load sempat_library")
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
    Name = "sempatpanick | Find The Chameleons",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Sempat UI • Find The Chameleons",
    ToggleUIKeybind = "K",
    WindowTransparency = 30,
    Icon = "https://dadang.id/sempatpanick-icon.png",
    ConfigurationSaving = {
        Enabled = true,
        AutoSave = false,
        AutoLoad = false,
        FolderName = "sempatpanick",
        FileName = "find_the_chameleons",
    },
})

-- */  Local Player Tab  /* --
createLocalPlayerTab(Window, mountNotify, { flagsPrefix = "lp", tabIcon = "user" })

-- ====================================================================
--                     FIND THE CHAMELEONS
-- ====================================================================
local WORLD_OPTIONS = { "Spawn", "Desert", "Lighthouse", "Snow", "Moon", "Candy", "Kraken" }
local RARITY_COLORS = {
    Easy = Color3.fromRGB(85, 255, 85),
    Normal = Color3.fromRGB(85, 170, 255),
    Hard = Color3.fromRGB(255, 170, 0),
    Legendary = Color3.fromRGB(255, 85, 255),
    Mythic = Color3.fromRGB(255, 85, 85),
}
local DEFAULT_ESP_COLOR = Color3.fromRGB(80, 220, 120)
local COLLECT_TAG = "collectible"
local TELEPORT_NEAR_STUDS = 6
local DEFAULT_REBIRTH_MIN = 200
local DEFAULT_REBIRTH_MAX = 271

local IndexUpdate
local Packets

local function tryRequire(pathParts)
    local current = pathParts[1]
    if typeof(current) ~= "Instance" then
        return nil
    end
    for i = 2, #pathParts do
        local child = current:FindFirstChild(pathParts[i])
        if not child then
            return nil
        end
        current = child
    end
    local ok, result = pcall(require, current)
    if ok then
        return result
    end
    return nil
end

local function waitRequire(timeoutSec, ...)
    local pathParts = { ... }
    local deadline = os.clock() + (timeoutSec or 10)
    while os.clock() < deadline do
        local mod = tryRequire(pathParts)
        if mod ~= nil then
            return mod
        end
        task.wait(0.2)
    end
    return tryRequire(pathParts)
end

task.spawn(function()
    IndexUpdate = waitRequire(15, ReplicatedFirst, "Modules", "Utility", "IndexUpdate")
        or waitRequire(5, ReplicatedStorage, "Modules", "Utility", "IndexUpdate")
    Packets = waitRequire(15, ReplicatedStorage, "Modules", "Networking", "Packets")
end)

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", "search")

    local statusParagraph
    local chameleonDropdown
    local selectedChameleonName = nil
    local listFilter = "Missing"
    local worldFilter = "All"
    local rarityFilter = "All"
    local chameleonOptions = { "(loading…)" }

    local espEnabled = false
    local espState = {} :: { [Instance]: { highlight: Highlight, labelGui: BillboardGui? } }
    local espRenderConn: RBXScriptConnection? = nil
    local espTagAddedConn: RBXScriptConnection? = nil
    local espTagRemovedConn: RBXScriptConnection? = nil
    local indexDataConn: RBXScriptConnection? = nil
    local lastEspRefreshAt = 0

    local autoCollectEnabled = false
    local autoCollectBusy = false
    local autoCollectToken = 0
    local autoCollectDelaySec = 0.15
    local autoCollectDelaySlider = nil
    local lastAutoCollectedName: string? = nil
    local lastAutoCollectedAt = 0

    local function getAutoCollectDelaySec(): number
        local fromSlider = autoCollectDelaySlider and tonumber(autoCollectDelaySlider.CurrentValue)
        local delaySec = fromSlider or tonumber(autoCollectDelaySec) or 0.15
        if delaySec ~= delaySec or delaySec < 0 then -- NaN / invalid
            delaySec = 0.15
        end
        return math.clamp(delaySec, 0.05, 30)
    end

    local function waitAutoCollectDelay(token: number): boolean
        local deadline = os.clock() + getAutoCollectDelaySec()
        while autoCollectEnabled and token == autoCollectToken do
            local remaining = deadline - os.clock()
            if remaining <= 0 then
                return true
            end
            task.wait(math.min(0.1, remaining))
        end
        return false
    end

    local function getLocalRootPart(): BasePart?
        local character = LocalPlayer.Character
        if not character then
            return nil
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            return root
        end
        return nil
    end

    local function getInstanceWorldPosition(inst: Instance): Vector3?
        if inst:IsA("BasePart") then
            return inst.Position
        end
        if inst:IsA("Model") then
            if inst.PrimaryPart then
                return inst.PrimaryPart.Position
            end
            local okPivot, pivot = pcall(function()
                return inst:GetPivot()
            end)
            if okPivot and pivot then
                return pivot.Position
            end
        end
        local part = inst:FindFirstChildWhichIsA("BasePart", true)
        if part then
            return part.Position
        end
        return nil
    end

    local function getCollectibleRoot(inst: Instance): BasePart?
        if inst:IsA("BasePart") then
            return inst
        end
        if inst:IsA("Model") then
            if inst.PrimaryPart then
                return inst.PrimaryPart
            end
            return inst:FindFirstChildWhichIsA("BasePart", true)
        end
        return inst:FindFirstChildWhichIsA("BasePart", true)
    end

    local function getIndexEntry(name: string)
        if not IndexUpdate or type(IndexUpdate.getData) ~= "function" then
            return nil
        end
        local ok, data = pcall(function()
            return IndexUpdate.getData(name)
        end)
        if not ok or type(data) ~= "table" then
            return nil
        end
        if data.IsFound ~= nil or data.characterId ~= nil or data.World ~= nil then
            return data
        end
        return nil
    end

    local function getAllIndexData(): { [string]: any }
        if not IndexUpdate or type(IndexUpdate.getData) ~= "function" then
            return {}
        end
        local ok, data = pcall(function()
            return IndexUpdate.getData()
        end)
        if ok and type(data) == "table" then
            return data
        end
        return {}
    end

    local function getEntryWorld(entry): string
        if type(entry) ~= "table" then
            return "?"
        end
        local world = entry.World
        if type(world) == "table" and world.value ~= nil then
            return tostring(world.value)
        end
        if type(world) == "string" then
            return world
        end
        return "?"
    end

    local function getEntryRarity(entry): string
        if type(entry) ~= "table" then
            return "?"
        end
        local rarity = entry.Rarity
        if type(rarity) == "table" and rarity.value ~= nil then
            return tostring(rarity.value)
        end
        if type(rarity) == "string" then
            return rarity
        end
        return "?"
    end

    local function getEntryColor(entry): Color3
        if type(entry) == "table" then
            local color = entry.Color
            if type(color) == "table" and typeof(color.value) == "Color3" then
                return color.value
            end
            if typeof(color) == "Color3" then
                return color
            end
            local rarityName = getEntryRarity(entry)
            if RARITY_COLORS[rarityName] then
                return RARITY_COLORS[rarityName]
            end
        end
        return DEFAULT_ESP_COLOR
    end

    local function getTaggedCollectibles(): { Instance }
        local list = {}
        local ok, tagged = pcall(function()
            return CollectionService:GetTagged(COLLECT_TAG)
        end)
        if ok and type(tagged) == "table" then
            for _, inst in ipairs(tagged) do
                if inst and inst.Parent then
                    table.insert(list, inst)
                end
            end
            return list
        end

        local folders = {
            Workspace:FindFirstChild("Characters"),
            Workspace:FindFirstChild("Statues"),
        }
        for _, folder in ipairs(folders) do
            if folder then
                for _, child in ipairs(folder:GetChildren()) do
                    if child:IsA("Model") or child:IsA("BasePart") then
                        table.insert(list, child)
                    end
                end
            end
        end
        return list
    end

    local function findCollectibleByName(name: string): Instance?
        if not name or name == "" or name == "(loading…)" or name == "(none)" then
            return nil
        end
        for _, inst in ipairs(getTaggedCollectibles()) do
            if inst.Name == name then
                return inst
            end
        end
        local characters = Workspace:FindFirstChild("Characters")
        if characters then
            local found = characters:FindFirstChild(name)
            if found then
                return found
            end
        end
        local statues = Workspace:FindFirstChild("Statues")
        if statues then
            local found = statues:FindFirstChild(name)
            if found then
                return found
            end
        end
        return nil
    end

    local function passesFilters(name: string, entry): boolean
        local isFound = entry and entry.IsFound == true
        if listFilter == "Missing" and isFound then
            return false
        end
        if listFilter == "Found" and not isFound then
            return false
        end
        if worldFilter ~= "All" then
            if string.lower(getEntryWorld(entry)) ~= string.lower(worldFilter) then
                return false
            end
        end
        if rarityFilter ~= "All" then
            if string.lower(getEntryRarity(entry)) ~= string.lower(rarityFilter) then
                return false
            end
        end
        return true
    end

    local function buildChameleonOptions(): { string }
        local options = {}
        local indexData = getAllIndexData()
        local seen = {}

        for name, entry in pairs(indexData) do
            if type(name) == "string" and type(entry) == "table" and passesFilters(name, entry) then
                table.insert(options, name)
                seen[name] = true
            end
        end

        if #options == 0 then
            for _, inst in ipairs(getTaggedCollectibles()) do
                local entry = getIndexEntry(inst.Name)
                if not seen[inst.Name] and passesFilters(inst.Name, entry) then
                    table.insert(options, inst.Name)
                    seen[inst.Name] = true
                end
            end
        end

        table.sort(options, function(a, b)
            local na = tonumber(string.match(a, "(%d+)$"))
            local nb = tonumber(string.match(b, "(%d+)$"))
            if na and nb then
                return na < nb
            end
            return a < b
        end)

        if #options == 0 then
            return { "(none)" }
        end
        return options
    end

    local function countProgress(): (number, number)
        local found, total = 0, 0
        local indexData = getAllIndexData()
        for _, entry in pairs(indexData) do
            if type(entry) == "table" and entry.IsFound ~= nil then
                total += 1
                if entry.IsFound then
                    found += 1
                end
            end
        end
        if total == 0 then
            total = #getTaggedCollectibles()
        end
        return found, total
    end

    local function refreshStatus()
        if not statusParagraph or not statusParagraph.Set then
            return
        end
        local found, total = countProgress()
        local packetsReady = Packets ~= nil
        local indexReady = IndexUpdate ~= nil
        statusParagraph:Set({
            Content = string.format(
                "Found: %d / %d\nIndex: %s · Packets: %s\nFilter: %s · World: %s · Rarity: %s",
                found,
                total,
                indexReady and "ready" or "waiting",
                packetsReady and "ready" or "waiting",
                listFilter,
                worldFilter,
                rarityFilter
            ),
        })
    end

    local function refreshChameleonDropdown()
        chameleonOptions = buildChameleonOptions()
        if chameleonDropdown and chameleonDropdown.Refresh then
            pcall(function()
                chameleonDropdown:Refresh(chameleonOptions)
            end)
        elseif chameleonDropdown and chameleonDropdown.Set then
            pcall(function()
                chameleonDropdown:Set({ Options = chameleonOptions })
            end)
        end
        if selectedChameleonName then
            local stillValid = false
            for _, name in ipairs(chameleonOptions) do
                if name == selectedChameleonName then
                    stillValid = true
                    break
                end
            end
            if not stillValid then
                selectedChameleonName = chameleonOptions[1]
            end
        else
            selectedChameleonName = chameleonOptions[1]
        end
        refreshStatus()
    end

    local function getCFrameNearTarget(target: Instance, rootPart: BasePart): CFrame?
        local targetPos = getInstanceWorldPosition(target)
        if not targetPos then
            return nil
        end
        local playerPos = rootPart.Position
        local horizontalDir = Vector3.new(playerPos.X - targetPos.X, 0, playerPos.Z - targetPos.Z)
        if horizontalDir.Magnitude < 0.5 then
            horizontalDir = Vector3.new(0, 0, TELEPORT_NEAR_STUDS)
        end
        local nearPos = targetPos + horizontalDir.Unit * TELEPORT_NEAR_STUDS + Vector3.new(0, 3, 0)
        return CFrame.lookAt(nearPos, targetPos)
    end

    local function teleportToInstance(inst: Instance): boolean
        local rootPart = getLocalRootPart()
        if not rootPart then
            mountNotify({ Title = "Teleport", Content = "Character not loaded" })
            return false
        end
        local nearCFrame = getCFrameNearTarget(inst, rootPart)
        if not nearCFrame then
            mountNotify({ Title = "Teleport", Content = "Could not resolve position" })
            return false
        end
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
        rootPart.CFrame = nearCFrame
        return true
    end

    local function fireShotSignal(inst: Instance): boolean
        local root = getCollectibleRoot(inst)
        if not root then
            return false
        end
        local signal = root:FindFirstChild("ShotSignal")
        if not (signal and signal:IsA("BindableEvent")) then
            signal = inst:FindFirstChild("ShotSignal", true)
        end
        if signal and signal:IsA("BindableEvent") then
            local ok = pcall(function()
                signal:Fire()
            end)
            return ok
        end
        return false
    end

    local function collectByPacketIds(ids: { any }): boolean
        if not Packets or not Packets.characterCollected then
            return false
        end
        if #ids == 0 then
            return false
        end
        local ok = pcall(function()
            Packets.characterCollected:Fire(ids)
        end)
        return ok
    end

    local function collectInstance(inst: Instance): boolean
        if fireShotSignal(inst) then
            return true
        end
        local entry = getIndexEntry(inst.Name)
        if entry and entry.characterId ~= nil then
            return collectByPacketIds({ entry.characterId })
        end
        return false
    end

    local function getClosestMissing(): Instance?
        local rootPart = getLocalRootPart()
        if not rootPart then
            return nil
        end
        local best, bestDist = nil, math.huge
        for _, inst in ipairs(getTaggedCollectibles()) do
            local entry = getIndexEntry(inst.Name)
            if entry and entry.IsFound then
                continue
            end
            if not passesFilters(inst.Name, entry) then
                continue
            end
            local pos = getInstanceWorldPosition(inst)
            if not pos then
                continue
            end
            local dist = (rootPart.Position - pos).Magnitude
            if dist < bestDist then
                bestDist = dist
                best = inst
            end
        end
        return best
    end

    local function collectFiltered(showNotify: boolean): number
        local collected = 0
        local packetBatch = {}
        for _, inst in ipairs(getTaggedCollectibles()) do
            local entry = getIndexEntry(inst.Name)
            if entry and entry.IsFound then
                continue
            end
            if not passesFilters(inst.Name, entry) then
                continue
            end
            if fireShotSignal(inst) then
                collected += 1
            elseif entry and entry.characterId ~= nil then
                table.insert(packetBatch, entry.characterId)
            end
        end

        for i = 1, #packetBatch, 10 do
            local chunk = {}
            for j = i, math.min(i + 9, #packetBatch) do
                table.insert(chunk, packetBatch[j])
            end
            if collectByPacketIds(chunk) then
                collected += #chunk
            end
        end

        if showNotify then
            mountNotify({
                Title = "Collect",
                Content = collected > 0 and ("Fired collect on " .. tostring(collected) .. " chameleon(s)") or "Nothing to collect (or Index not ready)",
            })
        end
        refreshStatus()
        return collected
    end

    local function clearEspFor(inst: Instance)
        local state = espState[inst]
        if not state then
            return
        end
        if state.highlight then
            pcall(function()
                state.highlight:Destroy()
            end)
        end
        if state.labelGui then
            pcall(function()
                state.labelGui:Destroy()
            end)
        end
        espState[inst] = nil
    end

    local function clearAllEsp()
        for inst in pairs(espState) do
            clearEspFor(inst)
        end
    end

    local function getEspLabelText(inst: Instance, adornee: BasePart): string
        local entry = getIndexEntry(inst.Name)
        local rarity = getEntryRarity(entry)
        local world = getEntryWorld(entry)
        local status = (entry and entry.IsFound) and "Found" or "Missing"
        local rootPart = getLocalRootPart()
        if rootPart then
            local dist = (rootPart.Position - adornee.Position).Magnitude
            return string.format("%s\n%s · %s · %s · %.0fm", inst.Name, rarity, world, status, dist)
        end
        return string.format("%s\n%s · %s · %s", inst.Name, rarity, world, status)
    end

    local function createEspLabel(inst: Instance, adornee: BasePart, color: Color3): BillboardGui
        local gui = Instance.new("BillboardGui")
        gui.Name = "SempatPanickChameleonESP"
        gui.Size = UDim2.fromOffset(240, 54)
        gui.StudsOffset = Vector3.new(0, 3, 0)
        gui.AlwaysOnTop = true
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromScale(1, 1)
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = color
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.TextWrapped = true
        label.Text = getEspLabelText(inst, adornee)
        label.Parent = gui
        gui.Adornee = adornee
        gui.Parent = adornee
        return gui
    end

    local function ensureEsp(inst: Instance)
        if espState[inst] then
            return
        end
        local entry = getIndexEntry(inst.Name)
        if not passesFilters(inst.Name, entry) then
            return
        end
        local color = getEntryColor(entry)
        local highlight = Instance.new("Highlight")
        highlight.Name = "SempatPanickChameleonESP"
        highlight.FillColor = color
        highlight.FillTransparency = 0.45
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Adornee = inst
        highlight.Parent = inst

        local labelGui: BillboardGui? = nil
        local adornee = getCollectibleRoot(inst)
        if adornee then
            labelGui = createEspLabel(inst, adornee, color)
        end

        espState[inst] = {
            highlight = highlight,
            labelGui = labelGui,
        }
    end

    local function syncEsp()
        if not espEnabled then
            clearAllEsp()
            return
        end
        local active = {}
        for _, inst in ipairs(getTaggedCollectibles()) do
            local entry = getIndexEntry(inst.Name)
            if passesFilters(inst.Name, entry) then
                active[inst] = true
                ensureEsp(inst)
            end
        end
        for inst in pairs(espState) do
            if not active[inst] or not inst.Parent then
                clearEspFor(inst)
            end
        end
    end

    local function updateEspLabels()
        if not espEnabled then
            return
        end
        for inst, state in pairs(espState) do
            local gui = state.labelGui
            if not gui then
                continue
            end
            local adornee = gui.Adornee
            if adornee and adornee:IsA("BasePart") then
                local label = gui:FindFirstChild("Label")
                if label and label:IsA("TextLabel") then
                    label.Text = getEspLabelText(inst, adornee)
                end
            end
        end
    end

    local function stopEspRender()
        if espRenderConn then
            espRenderConn:Disconnect()
            espRenderConn = nil
        end
        if espTagAddedConn then
            espTagAddedConn:Disconnect()
            espTagAddedConn = nil
        end
        if espTagRemovedConn then
            espTagRemovedConn:Disconnect()
            espTagRemovedConn = nil
        end
    end

    local function startEspRender()
        stopEspRender()
        lastEspRefreshAt = 0
        espRenderConn = RunService.RenderStepped:Connect(function()
            if not espEnabled then
                return
            end
            updateEspLabels()
            local now = os.clock()
            if now - lastEspRefreshAt >= 0.5 then
                lastEspRefreshAt = now
                syncEsp()
            end
        end)
        espTagAddedConn = CollectionService:GetInstanceAddedSignal(COLLECT_TAG):Connect(function()
            if espEnabled then
                syncEsp()
            end
        end)
        espTagRemovedConn = CollectionService:GetInstanceRemovedSignal(COLLECT_TAG):Connect(function(inst)
            clearEspFor(inst)
        end)
    end

    local function bindIndexUpdates()
        if indexDataConn or not IndexUpdate then
            return
        end
        if IndexUpdate.dataUpdated and IndexUpdate.dataUpdated.Connect then
            indexDataConn = IndexUpdate.dataUpdated:Connect(function()
                refreshChameleonDropdown()
                if espEnabled then
                    syncEsp()
                end
            end)
        end
        if IndexUpdate.characterCollected and IndexUpdate.characterCollected.Connect then
            IndexUpdate.characterCollected:Connect(function()
                refreshChameleonDropdown()
                if espEnabled then
                    syncEsp()
                end
            end)
        end
    end

    local function setEspEnabled(enabled: boolean)
        espEnabled = enabled
        if enabled then
            bindIndexUpdates()
            syncEsp()
            startEspRender()
            mountNotify({ Title = "ESP", Content = "Chameleon ESP enabled" })
            return
        end
        clearAllEsp()
        stopEspRender()
    end

    local function runAutoCollectLoop(token: number)
        while autoCollectEnabled and token == autoCollectToken do
            if autoCollectBusy then
                task.wait(0.1)
                continue
            end

            -- Scan nearest missing for this cycle
            local nearest = getClosestMissing()
            if not nearest then
                lastAutoCollectedName = nil
                refreshStatus()
                if not waitAutoCollectDelay(token) then
                    break
                end
                continue
            end

            -- Avoid hammering the same target before Index marks it found
            if nearest.Name == lastAutoCollectedName and (os.clock() - lastAutoCollectedAt) < getAutoCollectDelaySec() then
                if not waitAutoCollectDelay(token) then
                    break
                end
                continue
            end

            autoCollectBusy = true
            selectedChameleonName = nearest.Name
            teleportToInstance(nearest)

            -- Delay is the wait between teleport and collect / next cycle
            if not waitAutoCollectDelay(token) then
                autoCollectBusy = false
                break
            end

            -- Re-scan nearest right before collecting
            nearest = getClosestMissing()
            if not nearest then
                autoCollectBusy = false
                refreshStatus()
                continue
            end

            selectedChameleonName = nearest.Name
            if collectInstance(nearest) then
                lastAutoCollectedName = nearest.Name
                lastAutoCollectedAt = os.clock()
            end
            autoCollectBusy = false
            refreshStatus()
        end
    end

    local function requestWorldTeleport(worldName: string)
        if not Packets or not Packets.RequestTeleport then
            mountNotify({ Title = "World", Content = "Packets not ready yet" })
            return
        end
        local key = string.lower(worldName)
        local ok = pcall(function()
            Packets.RequestTeleport:Fire(key)
        end)
        mountNotify({
            Title = "World",
            Content = ok and ("Teleport requested: " .. worldName) or "RequestTeleport failed",
        })
    end

    MainTab:CreateSection("Status")

    statusParagraph = MainTab:CreateParagraph({
        Title = "Progress",
        Content = "Loading game modules…",
    })

    MainTab:CreateButton({
        Name = "Refresh List",
        Callback = function()
            bindIndexUpdates()
            refreshChameleonDropdown()
            mountNotify({ Title = "Chameleons", Content = "List refreshed (" .. tostring(#chameleonOptions) .. ")" })
        end,
    })

    MainTab:CreateSection("Filters")

    MainTab:CreateDropdown({
        Name = "List Filter",
        Flag = "ftc_list_filter",
        Options = { "Missing", "All", "Found" },
        CurrentOption = { "Missing" },
        Callback = function(value)
            listFilter = rayfieldDropdownFirst(value) or "Missing"
            refreshChameleonDropdown()
            if espEnabled then
                syncEsp()
            end
        end,
    })

    local worldDropdownOptions = { "All" }
    for _, world in ipairs(WORLD_OPTIONS) do
        table.insert(worldDropdownOptions, world)
    end

    MainTab:CreateDropdown({
        Name = "World Filter",
        Flag = "ftc_world_filter",
        Options = worldDropdownOptions,
        CurrentOption = { "All" },
        Callback = function(value)
            worldFilter = rayfieldDropdownFirst(value) or "All"
            refreshChameleonDropdown()
            if espEnabled then
                syncEsp()
            end
        end,
    })

    MainTab:CreateDropdown({
        Name = "Rarity Filter",
        Flag = "ftc_rarity_filter",
        Options = { "All", "Easy", "Normal", "Hard", "Legendary", "Mythic" },
        CurrentOption = { "All" },
        Callback = function(value)
            rarityFilter = rayfieldDropdownFirst(value) or "All"
            refreshChameleonDropdown()
            if espEnabled then
                syncEsp()
            end
        end,
    })

    MainTab:CreateSection("Chameleons")

    chameleonDropdown = MainTab:CreateDropdown({
        Name = "Chameleon",
        Flag = "ftc_chameleon_select",
        Options = chameleonOptions,
        CurrentOption = { chameleonOptions[1] },
        Search = true,
        Callback = function(value)
            selectedChameleonName = rayfieldDropdownFirst(value)
        end,
    })

    MainTab:CreateToggle({
        Name = "ESP Chameleons",
        Flag = "ftc_esp_enabled",
        CurrentValue = false,
        Callback = function(enabled)
            setEspEnabled(enabled == true)
        end,
    })

    MainTab:CreateButton({
        Name = "Teleport to Selected",
        Callback = function()
            local name = selectedChameleonName
            local inst = findCollectibleByName(name)
            if not inst then
                mountNotify({ Title = "Teleport", Content = "Chameleon not found: " .. tostring(name) })
                return
            end
            if teleportToInstance(inst) then
                mountNotify({ Title = "Teleport", Content = "Teleported to " .. inst.Name })
            end
        end,
    })

    MainTab:CreateButton({
        Name = "Teleport to Closest Missing",
        Callback = function()
            local inst = getClosestMissing()
            if not inst then
                mountNotify({ Title = "Teleport", Content = "No missing chameleons found" })
                return
            end
            selectedChameleonName = inst.Name
            if teleportToInstance(inst) then
                mountNotify({ Title = "Teleport", Content = "Teleported to " .. inst.Name })
            end
        end,
    })

    MainTab:CreateButton({
        Name = "Collect Selected",
        Callback = function()
            local name = selectedChameleonName
            local inst = findCollectibleByName(name)
            if not inst then
                mountNotify({ Title = "Collect", Content = "Chameleon not found: " .. tostring(name) })
                return
            end
            local entry = getIndexEntry(inst.Name)
            if entry and entry.IsFound then
                mountNotify({ Title = "Collect", Content = inst.Name .. " already found" })
                return
            end
            if collectInstance(inst) then
                mountNotify({ Title = "Collect", Content = "Collected " .. inst.Name })
                task.delay(0.3, refreshChameleonDropdown)
            else
                mountNotify({ Title = "Collect", Content = "Collect failed (ShotSignal / Index missing?)" })
            end
        end,
    })

    MainTab:CreateButton({
        Name = "Collect Closest Missing",
        Callback = function()
            local inst = getClosestMissing()
            if not inst then
                mountNotify({ Title = "Collect", Content = "No missing chameleons found" })
                return
            end
            if collectInstance(inst) then
                mountNotify({ Title = "Collect", Content = "Collected " .. inst.Name })
                task.delay(0.3, refreshChameleonDropdown)
            else
                mountNotify({ Title = "Collect", Content = "Collect failed for " .. inst.Name })
            end
        end,
    })

    MainTab:CreateButton({
        Name = "Collect All Filtered",
        Callback = function()
            collectFiltered(true)
            task.delay(0.4, refreshChameleonDropdown)
        end,
    })

    autoCollectDelaySlider = MainTab:CreateSlider({
        Name = "Auto Collect Delay",
        Flag = "ftc_auto_collect_delay",
        Range = { 0.05, 30 },
        Increment = 0.05,
        Suffix = "s",
        CurrentValue = autoCollectDelaySec,
        Callback = function(value)
            local parsed = tonumber(value)
            if not parsed and type(value) == "table" then
                parsed = tonumber(value[1])
            end
            if parsed then
                autoCollectDelaySec = math.clamp(parsed, 0.05, 30)
            end
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Collect Filtered",
        Flag = "ftc_auto_collect",
        CurrentValue = false,
        Callback = function(enabled)
            autoCollectEnabled = enabled == true
            autoCollectToken += 1
            if not autoCollectEnabled then
                return
            end
            bindIndexUpdates()
            local myToken = autoCollectToken
            task.spawn(function()
                runAutoCollectLoop(myToken)
            end)
            mountNotify({ Title = "Auto Collect", Content = "Started" })
        end,
    })

    MainTab:CreateSection("Rebirth")

    local rebirthStatusParagraph
    local rebirthMinInput
    local autoRebirthEnabled = false
    local autoRebirthToken = 0
    local autoRebirthBusy = false
    local rebirthMinTarget = DEFAULT_REBIRTH_MIN
    local cachedRebirthMinReq = DEFAULT_REBIRTH_MIN
    local cachedRebirthMaxReq = DEFAULT_REBIRTH_MAX

    local function getLeaderstatsFound(): number?
        local ls = LocalPlayer:FindFirstChild("leaderstats")
        local found = ls and ls:FindFirstChild("Found")
        if found and (found:IsA("IntValue") or found:IsA("NumberValue")) then
            return math.floor(tonumber(found.Value) or 0)
        end
        return nil
    end

    local function getFoundCount(): number
        local fromStats = getLeaderstatsFound()
        if fromStats ~= nil then
            return fromStats
        end
        local found = countProgress()
        return found
    end

    local function getRebirthRequirementBounds(): (number, number)
        local minReq = DEFAULT_REBIRTH_MIN
        local maxReq = DEFAULT_REBIRTH_MAX

        local characters = Workspace:FindFirstChild("Characters")
        if characters then
            local count = #characters:GetChildren()
            if count > 0 then
                maxReq = count
            end
        end

        local _, indexTotal = countProgress()
        if indexTotal > maxReq then
            maxReq = indexTotal
        end

        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local mainGui = playerGui and playerGui:FindFirstChild("MainGUI")
        local frames = mainGui and mainGui:FindFirstChild("Frames")

        local rebirthsFrame = frames and frames:FindFirstChild("RebirthsFrame")
        local barGroup = rebirthsFrame and rebirthsFrame:FindFirstChild("barGroup")
        local barText = barGroup and barGroup:FindFirstChild("text")
        if barText and (barText:IsA("TextLabel") or barText:IsA("TextButton") or barText:IsA("TextBox")) then
            local _, req = string.match(tostring(barText.Text), "(%d+)%s*/%s*(%d+)")
            local parsedReq = tonumber(req)
            if parsedReq and parsedReq > 0 then
                minReq = math.floor(parsedReq)
            end
        end

        local indexFrame = frames and frames:FindFirstChild("IndexFrame")
        local indexTitle = indexFrame and indexFrame:FindFirstChild("IndexTitle")
        local foundText = indexTitle and indexTitle:FindFirstChild("foundText")
        if foundText and (foundText:IsA("TextLabel") or foundText:IsA("TextButton") or foundText:IsA("TextBox")) then
            local _, total = string.match(tostring(foundText.Text), "(%d+)%s*/%s*(%d+)")
            local parsedTotal = tonumber(total)
            if parsedTotal and parsedTotal > 0 then
                maxReq = math.floor(parsedTotal)
            end
        end

        if minReq < 1 then
            minReq = DEFAULT_REBIRTH_MIN
        end
        if maxReq < minReq then
            maxReq = minReq
        end

        cachedRebirthMinReq = minReq
        cachedRebirthMaxReq = maxReq
        return minReq, maxReq
    end

    local function clampRebirthMinTarget(value: number?): number
        local minReq, maxReq = getRebirthRequirementBounds()
        local target = tonumber(value) or rebirthMinTarget or minReq
        target = math.floor(target + 0.5)
        return math.clamp(target, minReq, maxReq)
    end

    local function syncRebirthMinInput(skipCallback: boolean?)
        rebirthMinTarget = clampRebirthMinTarget(rebirthMinTarget)
        if rebirthMinInput and rebirthMinInput.Set then
            pcall(function()
                rebirthMinInput:Set(tostring(rebirthMinTarget), skipCallback == true)
            end)
        end
    end

    local function refreshRebirthStatus()
        if not rebirthStatusParagraph or not rebirthStatusParagraph.Set then
            return
        end
        local minReq, maxReq = getRebirthRequirementBounds()
        local found = getFoundCount()
        local target = clampRebirthMinTarget(rebirthMinTarget)
        rebirthStatusParagraph:Set({
            Content = string.format(
                "Found: %d\nGame requirement: %d (min) · %d (max)\nAuto rebirth at: %d%s",
                found,
                minReq,
                maxReq,
                target,
                autoRebirthEnabled and " · ON" or ""
            ),
        })
    end

    local function invokeRebirth(): (boolean, string?)
        if not Packets or not Packets.InvokeRebirth then
            return false, "Packets.InvokeRebirth not ready"
        end
        local ok, result = pcall(function()
            return Packets.InvokeRebirth:Fire()
        end)
        if not ok then
            return false, tostring(result)
        end
        if result == false then
            return false, "Server rejected rebirth"
        end
        return true, nil
    end

    local function tryAutoRebirth(showFailure: boolean?): boolean
        if autoRebirthBusy then
            return false
        end
        local found = getFoundCount()
        local target = clampRebirthMinTarget(rebirthMinTarget)
        if found < target then
            if showFailure then
                mountNotify({
                    Title = "Rebirth",
                    Content = string.format("Need %d found (have %d)", target, found),
                })
            end
            return false
        end

        autoRebirthBusy = true
        local ok, err = invokeRebirth()
        autoRebirthBusy = false
        if ok then
            mountNotify({ Title = "Rebirth", Content = string.format("Rebirthed at %d found", found) })
            task.delay(0.5, function()
                refreshChameleonDropdown()
                refreshRebirthStatus()
            end)
            return true
        end
        if showFailure then
            mountNotify({ Title = "Rebirth", Content = err or "Rebirth failed" })
        end
        return false
    end

    local function runAutoRebirthLoop(token: number)
        while autoRebirthEnabled and token == autoRebirthToken do
            rebirthMinTarget = clampRebirthMinTarget(rebirthMinTarget)
            refreshRebirthStatus()
            tryAutoRebirth(false)
            task.wait(0.5)
        end
        refreshRebirthStatus()
    end

    rebirthStatusParagraph = MainTab:CreateParagraph({
        Title = "Rebirth Status",
        Content = "Loading rebirth requirements…",
    })

    rebirthMinInput = MainTab:CreateInput({
        Name = "Min Found To Rebirth",
        Flag = "ftc_rebirth_min_found",
        PlaceholderText = tostring(DEFAULT_REBIRTH_MIN),
        CurrentValue = tostring(DEFAULT_REBIRTH_MIN),
        Callback = function(value)
            local parsed = tonumber(value)
            if not parsed then
                return
            end
            local minReq, maxReq = getRebirthRequirementBounds()
            local floored = math.floor(parsed + 0.5)
            if floored >= minReq and floored <= maxReq then
                rebirthMinTarget = floored
                refreshRebirthStatus()
            end
        end,
    })

    MainTab:CreateButton({
        Name = "Apply / Clamp Min Found",
        Callback = function()
            local raw = rebirthMinInput and (rebirthMinInput.CurrentValue or rebirthMinInput.Value) or rebirthMinTarget
            rebirthMinTarget = clampRebirthMinTarget(tonumber(raw) or rebirthMinTarget)
            syncRebirthMinInput(true)
            local minReq, maxReq = getRebirthRequirementBounds()
            mountNotify({
                Title = "Rebirth",
                Content = string.format("Min set to %d (allowed %d–%d)", rebirthMinTarget, minReq, maxReq),
            })
            refreshRebirthStatus()
        end,
    })

    MainTab:CreateButton({
        Name = "Rebirth Now",
        Callback = function()
            tryAutoRebirth(true)
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Rebirth",
        Flag = "ftc_auto_rebirth",
        CurrentValue = false,
        Callback = function(enabled)
            autoRebirthEnabled = enabled == true
            autoRebirthToken += 1
            if not autoRebirthEnabled then
                refreshRebirthStatus()
                return
            end
            syncRebirthMinInput(true)
            local myToken = autoRebirthToken
            task.spawn(function()
                runAutoRebirthLoop(myToken)
            end)
            mountNotify({
                Title = "Auto Rebirth",
                Content = string.format("Enabled · rebirth at %d+ found", clampRebirthMinTarget(rebirthMinTarget)),
            })
        end,
    })

    MainTab:CreateSection("Worlds")

    for _, worldName in ipairs(WORLD_OPTIONS) do
        MainTab:CreateButton({
            Name = "Teleport · " .. worldName,
            Callback = function()
                requestWorldTeleport(worldName)
            end,
        })
    end

    task.spawn(function()
        local deadline = os.clock() + 20
        while os.clock() < deadline do
            if IndexUpdate and Packets then
                break
            end
            task.wait(0.25)
        end
        bindIndexUpdates()
        refreshChameleonDropdown()
        syncRebirthMinInput(true)
        refreshStatus()
        refreshRebirthStatus()

        local ls = LocalPlayer:FindFirstChild("leaderstats") or LocalPlayer:WaitForChild("leaderstats", 5)
        local foundStat = ls and (ls:FindFirstChild("Found") or ls:WaitForChild("Found", 5))
        if foundStat then
            foundStat:GetPropertyChangedSignal("Value"):Connect(function()
                refreshStatus()
                refreshRebirthStatus()
                if autoRebirthEnabled then
                    tryAutoRebirth(false)
                end
            end)
        end
    end)

    task.spawn(function()
        while true do
            task.wait(2)
            refreshStatus()
            refreshRebirthStatus()
        end
    end)
end

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "find_the_chameleons", tabIcon = "map-pin" })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, {
    replicatedStorage = ReplicatedStorage,
    tabIcon = "boxes",
})

-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, {
    gamePath = "sempatpanick/find_the_chameleons",
    tabIcon = "video",
})

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/find_the_chameleons",
    rayfieldLibrary = SempatLibrary,
    tabIcon = "settings",
})
