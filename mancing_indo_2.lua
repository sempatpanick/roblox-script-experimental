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
local MarketplaceService = game:GetService("MarketplaceService")

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
-- */  Teleport Tab (module)  /* --
local TELEPORT_TAB_REPO = "https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/tabs/teleport_tab.lua"
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
-- */  Window  /* --
local Window = RayfieldLibrary:CreateWindow({
    Name = "sempatpanick | Mancing Indo",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Mancing Indo",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "sempatpanick",
        FileName = "mancing_indo",
    },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
})
-- Shared across tabs so Backpack features can validate fishing automation state.
local fishingAutomationState = {
    instantFishingEnabled = false,
}

-- Limited Event (Event tab) ↔ Main: location pin vs Auto Sell priority.
local limitedEventState = {
    pausedForAutoSell = false,
    blocksLocationHold = false,
    -- When at the limited-event spot, Auto Sell tweens back here (duration via computeLocationArrivalDurationSec) then restores stand; cleared when the LE session ends.
    returnFromSellTweenCf = nil :: CFrame?,
}
local limitedEventBridge: {
    stopLocationHold: (() -> ())?,
    cancelMainLocationArrivalTweenOnly: (() -> ())?,
    resumeTeleportToLocationAfterLimitedEvent: (() -> ())?,
    stopLimitedEventFreezeForAutoSell: (() -> ())?,
    restartLimitedEventFreezeAfterSell: ((CFrame) -> ())?,
} = {}

-- Config tab: sequential profile apply (Auto Sell trip → Teleport → Limited Event). Filled in Main tab.
local configLoadBridge: {
    suppressNextAutoSellLoopSpawn: boolean,
    runAutoSellWithFishingCoordination: (() -> ())?,
    startAutoSellSellLoop: ((boolean?) -> ())?,
    bumpAutoSellLoopToken: (() -> ())?,
} = {
    suppressNextAutoSellLoopSpawn = false,
}

-- Distance-based tween duration (shared: Main "Go to Location", other features). Tune MANCING_LOCATION_ARRIVAL_SPEED_STUDS_PER_SEC only.
local MANCING_LOCATION_ARRIVAL_SPEED_STUDS_PER_SEC = 20

function computeLocationArrivalDurationSec(startPos: Vector3, endPos: Vector3): number
    local d = (endPos - startPos).Magnitude
    return d / MANCING_LOCATION_ARRIVAL_SPEED_STUDS_PER_SEC
end

-- 3-phase tweens (Main "Go to Location", Limited Event travel): cruise leg is anchor Y + lift (was fixed +10).
local MANCING_LOCATION_ARRIVAL_CRUISE_LIFT_MIN_STUDS = 10
local MANCING_LOCATION_ARRIVAL_CRUISE_LIFT_MAX_STUDS = 14
local MANCING_LOCATION_ARRIVAL_CRUISE_LIFT_REQUEST_STUDS = 14

local function effectiveLocationCruiseLiftStuds(): number
    return math.clamp(
        MANCING_LOCATION_ARRIVAL_CRUISE_LIFT_REQUEST_STUDS,
        MANCING_LOCATION_ARRIVAL_CRUISE_LIFT_MIN_STUDS,
        MANCING_LOCATION_ARRIVAL_CRUISE_LIFT_MAX_STUDS
    )
end

-- If HumanoidRootPart world Y is above this, tween down to this Y first (same X/Z, keep facing). Used by location 3-phase, Auto Sell, etc.
local MANCING_LOCATION_ARRIVAL_START_WORLD_Y_MAX = 14

local function tweenHumanoidRootWorldYDownToCapIfNeededSync(rootPart: BasePart)
    if not rootPart.Parent then
        return
    end
    local capY = MANCING_LOCATION_ARRIVAL_START_WORLD_Y_MAX
    local p = rootPart.Position
    if p.Y <= capY then
        return
    end
    local rot = rootPart.CFrame - rootPart.CFrame.Position
    local capCf = CFrame.new(Vector3.new(p.X, capY, p.Z)) * rot
    local durSec = computeLocationArrivalDurationSec(p, capCf.Position)
    local ok = pcall(function()
        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero
        local ti = TweenInfo.new(durSec, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tw = TweenService:Create(rootPart, ti, { CFrame = capCf })
        tw:Play()
        tw.Completed:Wait()
    end)
    if not ok and rootPart.Parent then
        rootPart.CFrame = capCf
    end
end

-- Main tab "Go to Location": optional invisible platform under preset (see locationPresetRows.spawnLocationAssist + locationAssistPartName).
local MANCING_LOCATION_ASSIST_PLATFORM_SIZE = Vector3.new(30, 1, 30)
local MANCING_LOCATION_ASSIST_STASH_Y = -5000
-- Match existing spawned parts by center position (studs).
local MANCING_LOCATION_ASSIST_POSITION_MATCH_EPS = 1

local locationAssistFolder: Folder? = nil
local locationAssistPlatformPart: Part? = nil

local function getOrCreateLocationAssistFolder(): Folder
    local folder = locationAssistFolder
    if folder and folder.Parent then
        return folder
    end
    local existing = Workspace:FindFirstChild("MancingIndoLocationAssist")
    if existing and existing:IsA("Folder") then
        locationAssistFolder = existing
        return existing
    end
    local f = Instance.new("Folder")
    f.Name = "MancingIndoLocationAssist"
    f.Parent = Workspace
    locationAssistFolder = f
    return f
end

local function computeLocationAssistPlatformCenterFromTarget(targetCf: CFrame): Vector3
    local pos = targetCf.Position
    local halfY = MANCING_LOCATION_ASSIST_PLATFORM_SIZE.Y / 2
    return Vector3.new(pos.X, pos.Y - halfY, pos.Z)
end

local function findLocationAssistPartByNameAndPosition(folder: Folder, partName: string, expectedCenter: Vector3): Part?
    for _, d in folder:GetDescendants() do
        if d:IsA("BasePart") and d.Name == partName then
            if (d.Position - expectedCenter).Magnitude <= MANCING_LOCATION_ASSIST_POSITION_MATCH_EPS then
                return d
            end
        end
    end
    return nil
end

-- Reuse our stashed platform (hideLocationAssist) so we do not stack duplicates when name+position check misses hidden Y.
local function findStashedLocationAssistPartByName(folder: Folder, partName: string): Part?
    local ch = folder:FindFirstChild(partName)
    if ch and ch:IsA("BasePart") and ch.Position.Y < (MANCING_LOCATION_ASSIST_STASH_Y + 500) then
        return ch
    end
    return nil
end

function ensureLocationAssistPlatform(assistPartName: string?, targetCf: CFrame?): Part
    local resolvedName = (typeof(assistPartName) == "string" and assistPartName ~= "") and assistPartName or "LocationAssistPlatform"

    local existing = locationAssistPlatformPart
    if existing and existing.Parent then
        if resolvedName ~= existing.Name then
            existing.Name = resolvedName
        end
        return existing
    end

    local folder = getOrCreateLocationAssistFolder()

    if targetCf then
        local expectedCenter = computeLocationAssistPlatformCenterFromTarget(targetCf)
        local found = findLocationAssistPartByNameAndPosition(folder, resolvedName, expectedCenter)
        if not found then
            found = findStashedLocationAssistPartByName(folder, resolvedName)
        end
        if found then
            locationAssistPlatformPart = found
            return found
        end
    end

    local p = Instance.new("Part")
    p.Name = resolvedName
    p.Anchored = true
    p.CanCollide = true
    p.Transparency = 1
    p.CastShadow = false
    p.CanQuery = false
    p.Material = Enum.Material.SmoothPlastic
    p.Size = MANCING_LOCATION_ASSIST_PLATFORM_SIZE
    p.CFrame = CFrame.new(0, MANCING_LOCATION_ASSIST_STASH_Y, 0)
    p.Parent = folder
    locationAssistPlatformPart = p
    return p
end

function setLocationAssistForTargetCFrame(targetCf: CFrame, assistPartName: string?)
    local p = ensureLocationAssistPlatform(assistPartName, targetCf)
    local pos = targetCf.Position
    local halfY = p.Size.Y / 2
    p.CanCollide = true
    p.CFrame = CFrame.new(pos.X, pos.Y - halfY, pos.Z)
end

function hideLocationAssist()
    local p = locationAssistPlatformPart
    if p and p.Parent then
        p.CanCollide = false
        p.CFrame = CFrame.new(0, MANCING_LOCATION_ASSIST_STASH_Y, 0)
    end
end

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

-- */  Global: wait and automatically extend while LocalPlayer.GameplayPaused is true  /* --
function waitWithGameplayPauseDetect(seconds: number, player: Player?)
    local lp = player or Players.LocalPlayer
    if not lp then
        task.wait(seconds)
        return
    end

    local pauseConn = nil
    local stillPaused = false

    local function refreshPauseState()
        pcall(function()
            stillPaused = lp.GameplayPaused == true
        end)
    end

    pcall(function()
        pauseConn = lp:GetPropertyChangedSignal("GameplayPaused"):Connect(refreshPauseState)
    end)

    refreshPauseState()
    task.wait(seconds)
    while stillPaused do
        task.wait(0.25)
        refreshPauseState()
    end

    if pauseConn then
        pauseConn:Disconnect()
    end
end

-- */  Global: bestiary fish cache/list reusable across tabs  /* --
local GLOBAL_BESTIARY_FISH_BY_NAME: { [string]: { [string]: any } } = {}
local GLOBAL_BESTIARY_FISH_LIST: { string } = {}
local GLOBAL_BESTIARY_FISH_SEED: { [number]: { [string]: any } } = {
    { IsDiscovered = true, Image = "rbxassetid://96439630667032", Name = "Cakalang", SizeRange = { 1, 8 }, BasePrice = 45, Rarity = "Common", Biome = { "Ocean", "Pulau Boomerang", "Pulau Raja Kepiting" } },
    { IsDiscovered = true, Image = "rbxassetid://77549945082818", Name = "Kembung", SizeRange = { 1, 5 }, BasePrice = 45, Rarity = "Common", Biome = { "Bagang Teluk Dalam", "Pulau Seribu", "Nusa Giri", "Pulau Raja Kepiting", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://107245285598912", Name = "Selar", SizeRange = { 1, 5 }, BasePrice = 55, Rarity = "Common", Biome = { "Bagang Luar", "Bagang Ujung", "Pulau Raja Kepiting", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://118194707470807", Name = "Kiper", SizeRange = { 1, 3 }, BasePrice = 65, Rarity = "Common", Biome = { "Bagang Teluk Dalam", "Pulau Seribu", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://99521301596467", Name = "Bibir Tebal", SizeRange = { 1, 113 }, BasePrice = 12, Rarity = "Common", Biome = { "Pulau Raja Kepiting", "Nusa Giri", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://77354390600540", Name = "Bulan Bulan", SizeRange = { 1, 150 }, BasePrice = 35, Rarity = "Common", Biome = { "Bagang Teluk Dalam", "Bagang Tengah", "Bagang Luar", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://130209972808138", Name = "Baronang", SizeRange = { 1, 4 }, BasePrice = 45, Rarity = "Common", Biome = { "Bagang Teluk Dalam", "Bagang Tengah", "Bagang Ujung", "Bagang Luar", "Pulau Raja Kepiting", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://81110496110596", Name = "Lencam", SizeRange = { 1, 34 }, BasePrice = 29, Rarity = "Common", Biome = { "Pulau Seribu", "Nusa Giri", "Pulau Raja Kepiting", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://132334397594362", Name = "Korang Korang", SizeRange = { 1, 3 }, BasePrice = 65, Rarity = "Common", Biome = { "Bagang Tengah", "Nusa Giri", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://137586672510862", Name = "Belanak", SizeRange = { 1, 6 }, BasePrice = 45, Rarity = "Common", Biome = { "Bagang Teluk Dalam", "Bagang Tengah", "Pulau Raja Kepiting", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://83906784560832", Name = "Kerapu Macan", SizeRange = { 1, 11 }, BasePrice = 69, Rarity = "Uncommon", Biome = { "Bagang Teluk Dalam", "Bagang Tengah", "Pulau Seribu", "Bagang Luar", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://100797310349970", Name = "Kue", SizeRange = { 1, 15 }, BasePrice = 67, Rarity = "Uncommon", Biome = { "Bagang Ujung", "Pulau Raja Kepiting", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://94073280009938", Name = "Manyung", SizeRange = { 1, 15 }, BasePrice = 55, Rarity = "Uncommon", Biome = { "Bagang Tengah", "Nusa Giri", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://95432263206097", Name = "Bawal", SizeRange = { 1, 8 }, BasePrice = 80, Rarity = "Uncommon", Biome = { "Pulau Seribu", "Bagang Tengah", "Pulau Raja Kepiting", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://92221883833996", Name = "Kerapu", SizeRange = { 1, 15 }, BasePrice = 65, Rarity = "Uncommon", Biome = { "Pulau Seribu", "Nusa Giri", "Bagang Luar", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://107998878019525", Name = "Kuwe Lilin", SizeRange = { 1, 10 }, BasePrice = 72, Rarity = "Uncommon", Biome = { "Pulau Boomerang", "Nusa Giri", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://139246541408150", Name = "Layur", SizeRange = { 1, 6 }, BasePrice = 80, Rarity = "Uncommon", Biome = { "Bagang Luar", "Ocean", "Pulau Raja Kepiting" } },
    { IsDiscovered = true, Image = "rbxassetid://72795767294489", Name = "Talang Talang", SizeRange = { 1, 10 }, BasePrice = 60, Rarity = "Uncommon", Biome = { "Pulau Boomerang", "Bagang Ujung", "Pulau Raja Kepiting", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://76756079077545", Name = "Kakap Merah", SizeRange = { 8, 20 }, BasePrice = 62, Rarity = "Uncommon", Biome = { "Bagang Ujung", "Pulau Raja Kepiting", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://84682284136574", Name = "Kakap Putih", SizeRange = { 2, 60 }, BasePrice = 92, Rarity = "Rare", Biome = { "Bagang Teluk Dalam", "Nusa Giri", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://88438720593196", Name = "Kuwe Gerong", SizeRange = { 20, 80 }, BasePrice = 98, Rarity = "Rare", Biome = { "Bagang Ujung", "Pulau Raja Kepiting", "Nusa Giri", "Bagang Luar", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://103462330327663", Name = "Kurau", SizeRange = { 2, 20 }, BasePrice = 85, Rarity = "Rare", Biome = { "Bagang Teluk Dalam", "Bagang Ujung", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://122444506982496", Name = "Cobia", SizeRange = { 5, 30 }, BasePrice = 95, Rarity = "Rare", Biome = { "Bagang Luar", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://77531513272128", Name = "Salem", SizeRange = { 1, 10 }, BasePrice = 88, Rarity = "Rare", Biome = { "Ocean", "Bagang Ujung", "Bagang Luar" } },
    { IsDiscovered = true, Image = "rbxassetid://111030265375847", Name = "Kakatua", SizeRange = { 1, 75 }, BasePrice = 88, Rarity = "Rare", Biome = { "Pulau Seribu", "Pulau Raja Kepiting", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://107665961587222", Name = "Tenggiri", SizeRange = { 10, 70 }, BasePrice = 95, Rarity = "Rare", Biome = { "Ocean", "Pulau Boomerang" } },
    { IsDiscovered = true, Image = "rbxassetid://112422725694591", Name = "Amberjack", SizeRange = { 5, 40 }, BasePrice = 90, Rarity = "Rare", Biome = { "Ocean", "Pulau Boomerang" } },
    { IsDiscovered = true, Image = "rbxassetid://117949774683830", Name = "Lamadang", SizeRange = { 5, 25 }, BasePrice = 100, Rarity = "Rare", Biome = { "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://115542908243987", Name = "Madidihang", SizeRange = { 60, 180 }, BasePrice = 135, Rarity = "Legendary", Biome = { "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://77378600530681", Name = "Tuna Gigi Anjing", SizeRange = { 90, 248 }, BasePrice = 225, Rarity = "Legendary", Biome = { "Bagang Ujung", "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://125391107112862", Name = "Yellowfin", SizeRange = { 40, 150 }, BasePrice = 160, Rarity = "Legendary", Biome = { "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://101533617773805", Name = "Marlin", SizeRange = { 50, 300 }, BasePrice = 180, Rarity = "Legendary", Biome = { "Ocean" } },
    { IsDiscovered = true, Image = "rbxassetid://90737568676663", Name = "Ikan Layaran", SizeRange = { 27, 90 }, BasePrice = 155, Rarity = "Legendary", Biome = { "Ocean", "Pulau Boomerang" } },
    { IsDiscovered = true, Image = "rbxassetid://96008052578435", Name = "Alu Alu", SizeRange = { 10, 46 }, BasePrice = 120, Rarity = "Legendary", Biome = { "Ocean", "Pulau Boomerang" } },
    { IsDiscovered = true, Image = "rbxassetid://139885975348132", Name = "Hiu Martil", SizeRange = { 50, 400 }, BasePrice = 200, Rarity = "Legendary", Biome = { "Ocean", "Pulau Boomerang" } },
    { IsDiscovered = true, Image = "rbxassetid://126066757807448", Name = "Ikan Napoleon", SizeRange = { 40, 113 }, BasePrice = 198, Rarity = "Legendary", Biome = { "Pulau Raja Kepiting", "Pulau Seribu", "Ocean" } },
    { IsDiscovered = false, Image = "rbxassetid://107665961587222", Name = "???", Rarity = "???", Biome = {} },
}

local function normalizeBestiaryFishName(raw: any): string?
    if type(raw) ~= "string" then
        return nil
    end
    local name = string.gsub(string.gsub(raw, "^%s+", ""), "%s+$", "")
    if name == "" then
        return nil
    end
    return name
end

local function isBestiaryUnknownToken(raw: any): boolean
    if type(raw) ~= "string" then
        return false
    end
    local s = string.gsub(string.gsub(raw, "^%s+", ""), "%s+$", "")
    return s == "???"
end

local function rebuildGlobalBestiaryFishList()
    GLOBAL_BESTIARY_FISH_LIST = {}
    for name in pairs(GLOBAL_BESTIARY_FISH_BY_NAME) do
        table.insert(GLOBAL_BESTIARY_FISH_LIST, name)
    end
    table.sort(GLOBAL_BESTIARY_FISH_LIST, function(a, b)
        return string.lower(a) < string.lower(b)
    end)
end

local function mergeFishRowIntoGlobalBestiary(entry: { [string]: any }): boolean
    local fishName = normalizeBestiaryFishName(entry.Name)
    if not fishName then
        return false
    end
    if isBestiaryUnknownToken(fishName) or isBestiaryUnknownToken(entry.Rarity) then
        return false
    end
    local existing = GLOBAL_BESTIARY_FISH_BY_NAME[fishName]
    local changed = false
    if not existing then
        existing = {}
        GLOBAL_BESTIARY_FISH_BY_NAME[fishName] = existing
        changed = true
    end
    for k, v in pairs(entry) do
        if existing[k] ~= v then
            existing[k] = v
            changed = true
        end
    end
    existing.Name = fishName
    return changed
end

local function mergeBestiaryRowsFromPayload(payload: any, depth: number?): boolean
    local d = depth or 0
    if d > 6 then
        return false
    end
    if type(payload) ~= "table" then
        return false
    end
    local changed = false
    if mergeFishRowIntoGlobalBestiary(payload) then
        changed = true
    end
    for _, child in pairs(payload) do
        if type(child) == "table" then
            if mergeBestiaryRowsFromPayload(child, d + 1) then
                changed = true
            end
        end
    end
    if changed then
        rebuildGlobalBestiaryFishList()
    end
    return changed
end

function fetchAndMergeGlobalBestiaryFish(): boolean
    -- Intentionally no InvokeServer for GetBestiary; keep this cache passive-only.
    -- Data is seeded locally and can be merged via other incoming client payloads.
    return false
end

function getGlobalBestiaryFishList(): { string }
    local out: { string } = {}
    for i, name in ipairs(GLOBAL_BESTIARY_FISH_LIST) do
        out[i] = name
    end
    return out
end

for _, fish in ipairs(GLOBAL_BESTIARY_FISH_SEED) do
    local name = normalizeBestiaryFishName(fish.Name)
    if name and (not isBestiaryUnknownToken(name)) and (not isBestiaryUnknownToken(fish.Rarity)) and not GLOBAL_BESTIARY_FISH_BY_NAME[name] then
        local row = {}
        for k, v in pairs(fish) do
            row[k] = v
        end
        GLOBAL_BESTIARY_FISH_BY_NAME[name] = row
    end
end
rebuildGlobalBestiaryFishList()

-- */  Local Player Tab  /* --
-- Bridged from Local Player tab: temporary fly + no clip for underground auto-sell (Main tab).
local autoSellTripAssist = {}

createLocalPlayerTab(Window, mountNotify, {
    persistNoClip = true,
    autoSellTripAssist = autoSellTripAssist,
})

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", 4483362458)

    local autoFishingPausedForSell = false
    local instantFishingEnabled = false
    local instantFishingLoopRunning = false
    local instantFishingCycleRunning = false
    local instantFishingDelaySec = 5
    local instantFishingArmSeq = 0
    local randomCastCmgrEnabled = false
    local randomCastCmgrSync = false
    local RandomCastCmgrToggleInstant

    local function setRandomCastCmgrToggleInstant(enabled: boolean, skipInstance: any)
        randomCastCmgrSync = true
        randomCastCmgrEnabled = enabled
        if RandomCastCmgrToggleInstant and RandomCastCmgrToggleInstant ~= skipInstance then
            pcall(function()
                RandomCastCmgrToggleInstant:Set(enabled)
            end)
        end
        randomCastCmgrSync = false
    end

    local minigameAutoSolveConn = nil
    -- Set after CMGR Result; cleared when MGR "Stop" fires or timeout (next cast waits for minigame end).
    -- `finished` avoids BindableEvent missed-signal races when MGR "Stop" fires before the waiter runs.
    local minigameSessionWait = nil :: { seq: number, finished: boolean }?
    local minigameCycleSeq = 0
    local MINIGAME_SESSION_TIMEOUT = 10
    -- Reel autoplay for Instant fishing uses VirtualInputManager E only.
    local REEL_AUTOPLAY_START_DELAY = 0.06
    local REEL_AUTOPLAY_TIMEOUT = 55
    local reelAutoplayLoopRunning = false
    -- MGR Spawn payload (challenge id lives only in the game's Minigames module, not on instances).
    local mgrPendingChallenge = nil :: { id: any, mode: string, hold: number }?
    -- After enabling auto Fishing while already in minigame: extra pause once that minigame finishes.
    local autoFishDelay2sAfterPreEnableDrain = false

    -- Tap minigame: MGR "Spawn" then FireServer("Click", challengeId). Reel: VirtualInput E drives
    -- MinigamesReel (same status phases as galatama script; no remote Complete).
    local function releaseMinigameSessionWait()
        local pending = minigameSessionWait
        if not pending then
            return
        end
        minigameSessionWait = nil
        pending.finished = true
    end

    local function isReelMinigameActive(): boolean
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return false
        end
        local ru = pg:FindFirstChild("ReelUI")
        if not (ru and ru:IsA("ScreenGui")) then
            return false
        end
        return ru.Enabled
    end

    local function mancingFindNamedDescendant(root: Instance, name: string): Instance?
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

    local function mancingVimKey(isDown: boolean, keyCode: Enum.KeyCode): boolean
        local ok = pcall(function()
            VirtualInputManager:SendKeyEvent(isDown, keyCode, false, game)
        end)
        return ok
    end

    -- Main game: one PlayerGui.ReelUI (Canvas → Bar/Fill, Reel/Handle/Knob, Status).
    local function mancingResolveReelParts(): (ScreenGui?, GuiObject?, GuiObject?, GuiObject?)
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return nil, nil, nil, nil
        end
        local reelUi = pg:FindFirstChild("ReelUI")
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
        local f = (fill and fill:IsA("GuiObject")) and (fill :: GuiObject) or nil
        local sgui = (status and status:IsA("GuiObject")) and (status :: GuiObject) or nil
        return reelUi, sgui, nil, f
    end

    local function mancingGetReelStatusText(statusGui: GuiObject?): string
        if not statusGui then
            return ""
        end
        local t = ""
        if statusGui:IsA("TextLabel") then
            local lbl = statusGui :: TextLabel
            t = lbl.Text
            if t == "" then
                local okCt, ct = pcall(function()
                    return lbl.ContentText
                end)
                if okCt and type(ct) == "string" then
                    t = ct
                end
            end
        elseif statusGui:IsA("TextButton") then
            local btn = statusGui :: TextButton
            t = btn.Text
            if t == "" then
                local okCt, ct = pcall(function()
                    return btn.ContentText
                end)
                if okCt and type(ct) == "string" then
                    t = ct
                end
            end
        end
        return t
    end

    local function mancingReelStatusRequiresNoKnobSpin(st: string): boolean
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

    local function mancingClassifyReelPhase(st: string): "idle" | "reel_out" | "spin"
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

    local function mancingResolveReelPhase(st: string): "idle" | "reel_out" | "spin"
        if st ~= "" then
            return mancingClassifyReelPhase(st)
        end
        return "spin"
    end

    local function runMancingReelAutoplayLoop()
        local keysWork = true
        local eHeld = false
        local rem = ReplicatedStorage:FindFirstChild("Remotes")
        local mgrEv = rem and rem:FindFirstChild("MGR")

        if instantFishingEnabled and mgrEv and mgrEv:IsA("RemoteEvent") then
            task.delay(math.max(0, instantFishingDelaySec), function()
                if not instantFishingEnabled or not isReelMinigameActive() then
                    return
                end
                pcall(function()
                    mgrEv:FireServer("Complete")
                end)
            end)
        end

        local function releaseKeys()
            if eHeld then
                mancingVimKey(false, Enum.KeyCode.E)
                eHeld = false
            end
        end

        local function setE(want: boolean)
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

        if instantFishingEnabled and mgrEv and mgrEv:IsA("RemoteEvent") then
            if not instantFishingEnabled or not isReelMinigameActive() then
                return
            end
        end

        local t0 = os.clock()
        while isReelMinigameActive() and instantFishingEnabled and os.clock() - t0 < REEL_AUTOPLAY_TIMEOUT do
            RunService.Heartbeat:Wait()
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
            else
                setE(true)
            end
        end

        releaseKeys()

        if
            instantFishingEnabled
            and os.clock() - t0 >= REEL_AUTOPLAY_TIMEOUT
            and isReelMinigameActive()
        then
            warn(
                "[Auto Fishing] reel autoplay timed out — Complete() + VirtualInputManager E did not finish in time."
            )
        end
    end

    local function scheduleMancingReelAutoplayIfNeeded()
        if reelAutoplayLoopRunning or not instantFishingEnabled then
            return
        end
        reelAutoplayLoopRunning = true
        task.spawn(function()
            task.wait(REEL_AUTOPLAY_START_DELAY)
            if not instantFishingEnabled or not isReelMinigameActive() then
                reelAutoplayLoopRunning = false
                return
            end
            local ok, err = pcall(function()
                runMancingReelAutoplayLoop()
            end)
            reelAutoplayLoopRunning = false
            if not ok then
                warn("[Auto Fishing] reel autoplay error: ", err)
            end
        end)
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
        minigameAutoSolveConn = MGR.OnClientEvent:Connect(function(action, a2, a3, a4, a5)
            if action == "Start" then
                mgrPendingChallenge = nil
            elseif action == "Spawn" then
                -- Reel-only mode: ignore tap-style Spawn payload handling.
            elseif action == "Stop" then
                mgrPendingChallenge = nil
            end

            if not instantFishingEnabled then
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
            if action ~= "Spawn" then
                return
            end
            -- Reel-only mode: do not run tap/click fallback on Spawn.
        end)
    end

    local function waitForMinigameCleared(reason: string)
        local t0 = os.clock()
        while
            (
                mgrPendingChallenge ~= nil
                or isReelMinigameActive()
            )
            and instantFishingEnabled
            and os.clock() - t0 < MINIGAME_SESSION_TIMEOUT
        do
            task.wait(0.05)
        end
        if
            instantFishingEnabled
            and os.clock() - t0 >= MINIGAME_SESSION_TIMEOUT
            and (
                mgrPendingChallenge ~= nil
                or isReelMinigameActive()
            )
        then
            warn("[Auto Fishing] timed out waiting for minigame to end (" .. reason .. ")")
            mgrPendingChallenge = nil
        end
        if instantFishingEnabled then
            task.wait(0.2)
        end
    end

    local function completeOrWaitMinigameBeforeCast(): boolean
        if not instantFishingEnabled then
            return false
        end
        ensureMinigameAutoSolve()
        local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
        local MGR = remotesFolder and remotesFolder:FindFirstChild("MGR")
        if not (MGR and MGR:IsA("RemoteEvent")) then
            return false
        end

        if isReelMinigameActive() then
            task.defer(scheduleMancingReelAutoplayIfNeeded)
            waitForMinigameCleared("reel E autoplay drain")
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

    local function playerHasFishingRodEquipped(): boolean
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
        local resultValue: number = 1
        if randomCastCmgrEnabled then
            resultValue = math.random(500, 1000) / 1000
        end
        pcall(function()
            CMGR:FireServer("Result", resultValue)
        end)
    end

    local function runFishingCycleImpl(
        equipWait: number,
        castToCmgrWait: number,
        afterMinigameWait: number,
        afterDrainWait: number
    ): boolean
        local wantPostPreEnableDelay = autoFishDelay2sAfterPreEnableDrain
        local drainedExistingMinigame = completeOrWaitMinigameBeforeCast()
        if wantPostPreEnableDelay then
            autoFishDelay2sAfterPreEnableDrain = false
        end
        if wantPostPreEnableDelay and drainedExistingMinigame and instantFishingEnabled then
            task.wait(afterDrainWait)
        end
        if not instantFishingEnabled then
            return false
        end
        if not select(1, getFishingRemotes()) then
            return false
        end
        minigameCycleSeq += 1
        local cycleSeq = minigameCycleSeq

        if not playerHasFishingRodEquipped() then
            equipFishingRodRemote()
            task.wait(equipWait)
        end
        castFishingRodRemote()
        task.wait(castToCmgrWait)
        setFishingCastResultRemote()

        local sessionWait = { seq = cycleSeq, finished = false }
        minigameSessionWait = sessionWait
        task.delay(MINIGAME_SESSION_TIMEOUT, function()
            if minigameSessionWait and minigameSessionWait.seq == cycleSeq then
                releaseMinigameSessionWait()
            end
        end)
        while not sessionWait.finished do
            RunService.Heartbeat:Wait()
        end

        if not instantFishingEnabled then
            return false
        end
        task.wait(afterMinigameWait)
        return true
    end

    local function runInstantFishingCycleImpl(): boolean
        return runFishingCycleImpl(0.5, 0, 0, 0)
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
            while autoFishingPausedForSell and instantFishingEnabled do
                task.wait(0.05)
            end
            if not instantFishingEnabled then
                break
            end
            -- Auto Sell sets autoFishingPausedForSell after instantFishingCycleRunning goes false;
            -- re-check here so we never start a new cycle between those two moments.
            if autoFishingPausedForSell then
                continue
            end
            if not runInstantFishingCycle() then
                task.wait(0.25)
            end
        end
        instantFishingLoopRunning = false
    end

    local function ensureMinigamePreferenceIsReel()
        local raw = Players.LocalPlayer:GetAttribute("MinigamePreference")
        if type(raw) == "string" and string.lower(raw) == "reel" then
            return
        end
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local cp = remotes and remotes:FindFirstChild("ChangePreference")
        if cp and cp:IsA("RemoteEvent") then
            pcall(function()
                (cp :: RemoteEvent):FireServer("Reel")
            end)
        end
        pcall(function()
            Players.LocalPlayer:SetAttribute("MinigamePreference", "Reel")
        end)
    end

    MainTab:CreateSection("Instant fishing")
    MainTab:CreateInput({
        Name = "Delay (seconds)",
        PlaceholderText = "e.g. 0.5",
        Flag = "mancing_main_instantFishingDelaySec",
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
        Flag = "mancing_main_randomCastCmgr",
        CurrentValue = false,
        Callback = function(enabled)
            if randomCastCmgrSync then
                randomCastCmgrEnabled = enabled
                return
            end
            setRandomCastCmgrToggleInstant(enabled, RandomCastCmgrToggleInstant)
        end,
    })

    MainTab:CreateToggle({
        Name = "Instant fishing",
        Flag = "mancing_main_instantFishing",
        CurrentValue = false,
        Callback = function(enabled)
            if enabled then
                releaseMinigameSessionWait()
                instantFishingArmSeq += 1
                local armSeq = instantFishingArmSeq
                task.spawn(function()
                    ensureMinigamePreferenceIsReel()
                    task.wait(0.15)
                    if armSeq ~= instantFishingArmSeq then
                        return
                    end
                    instantFishingEnabled = true
                    fishingAutomationState.instantFishingEnabled = true
                    ensureMinigameAutoSolve()
                    autoFishDelay2sAfterPreEnableDrain = mgrPendingChallenge ~= nil
                        or isReelMinigameActive()
                    if instantFishingLoopRunning then
                        return
                    end
                    instantFishingLoopRunning = true
                    runInstantFishingLoop()
                end)
            else
                instantFishingArmSeq += 1
                instantFishingEnabled = false
                fishingAutomationState.instantFishingEnabled = false
                releaseMinigameSessionWait()
                autoFishDelay2sAfterPreEnableDrain = false
                autoFishingPausedForSell = false
            end
        end,
    })

    task.defer(ensureMinigameAutoSolve)
    MainTab:CreateSection("Sell")
    local sellMode = "Loop"
    local sellIntervalSeconds = 60
    local sellIntervalRevision = 0
    local autoSellEnabled = false
    local autoSellLoopRunning = false
    local autoSellLoopToken = 0
    local SELL_TELEPORT_CFRAME = CFrame.new(2621.24, -0.11, -911.08)
    -- Max time at buyer position (sell attempts + waits); avoids staying stuck if BackpackRemove never fires.
    local AUTO_SELL_TRIP_TIMEOUT_SEC = 5
    local AUTO_SELL_BACKPACK_REMOVE_WAIT_SEC = 0.8
    local AUTO_SELL_RETRY_FIRE_SEC = 0.25
    local autoSellBackpackRemoveConn: RBXScriptConnection? = nil
    local autoSellBackpackRemoveSignalCount = 0

    local function ensureBackpackRemoveListener()
        if autoSellBackpackRemoveConn and autoSellBackpackRemoveConn.Connected then
            return
        end
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local backpackRemove = remotes and remotes:FindFirstChild("BackpackRemove")
        if not (backpackRemove and backpackRemove:IsA("RemoteEvent")) then
            return
        end
        autoSellBackpackRemoveConn = backpackRemove.OnClientEvent:Connect(function()
            autoSellBackpackRemoveSignalCount += 1
        end)
    end

    local function isFishToolLockedOrFavorited(tool: Instance): boolean
        local function attrTruthy(v: any): boolean
            if v == true then
                return true
            end
            if type(v) == "number" then
                return v ~= 0
            end
            if type(v) == "string" then
                local s = string.lower(v)
                return s == "true" or s == "1" or s == "yes"
            end
            return false
        end
        return attrTruthy(tool:GetAttribute("IsLocked"))
            or attrTruthy(tool:GetAttribute("Locked"))
            or attrTruthy(tool:GetAttribute("IsFavorite"))
            or attrTruthy(tool:GetAttribute("Favorite"))
    end

    -- Fish sell tools use attribute UID (see in-game buyer dialog); rods use FishingRod.
    local function playerBackpackHasFish()
        local lp = Players.LocalPlayer
        local bp = lp:FindFirstChild("Backpack")
        if not (bp and bp:IsA("Backpack")) then
            return false
        end
        for _, child in ipairs(bp:GetChildren()) do
            if child:IsA("Tool")
                and child:GetAttribute("FishingRod") == nil
                and child:GetAttribute("UID") ~= nil
                and not isFishToolLockedOrFavorited(child) then
                return true
            end
        end
        return false
    end

    local function fireSellFishAllUntilBackpackRemove(deadlineClock: number?): boolean
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then
            return false
        end
        local sellFish = remotes:FindFirstChild("SellFish")
        if not (sellFish and sellFish:IsA("RemoteEvent")) then
            return false
        end
        ensureBackpackRemoveListener()

        local function tripTimedOut(): boolean
            return deadlineClock ~= nil and os.clock() >= deadlineClock
        end

        while autoSellEnabled do
            if tripTimedOut() then
                return false
            end
            local beforeSignalCount = autoSellBackpackRemoveSignalCount
            pcall(function()
                sellFish:FireServer("All")
            end)

            local startedAt = os.clock()
            while autoSellEnabled
                and (autoSellBackpackRemoveSignalCount <= beforeSignalCount)
                and (os.clock() - startedAt) < AUTO_SELL_BACKPACK_REMOVE_WAIT_SEC do
                if tripTimedOut() then
                    return false
                end
                task.wait(0.05)
            end

            if tripTimedOut() then
                return false
            end

            if autoSellBackpackRemoveSignalCount > beforeSignalCount then
                return true
            end

            waitWithGameplayPauseDetect(AUTO_SELL_RETRY_FIRE_SEC)
        end

        return false
    end

    -- Filled in by Location section: pause/resume pin while Auto Sell travels (tween) to/from buyer.
    local locationHoldApi: { pauseForAutoSell: (() -> boolean)?, resumeAfterAutoSell: ((boolean) -> ())? } = {}

    local function runAutoSellTweenSellAndReturn()
        if not playerBackpackHasFish() then
            return
        end
        limitedEventState.pausedForAutoSell = true
        if limitedEventBridge.stopLimitedEventFreezeForAutoSell then
            pcall(limitedEventBridge.stopLimitedEventFreezeForAutoSell)
        end
        local function getCurrentRoot()
            local ch = Players.LocalPlayer.Character
            return ch and ch:FindFirstChild("HumanoidRootPart")
        end
        local function tweenRootToCFrame(rootPart: BasePart, targetCf: CFrame, failureLabel: string)
            if not rootPart.Parent then
                return
            end
            tweenHumanoidRootWorldYDownToCapIfNeededSync(rootPart)
            if not rootPart.Parent then
                return
            end
            local durSec = computeLocationArrivalDurationSec(rootPart.Position, targetCf.Position)
            local tweenOk, tweenErr = pcall(function()
                rootPart.AssemblyLinearVelocity = Vector3.zero
                rootPart.AssemblyAngularVelocity = Vector3.zero
                local ti = TweenInfo.new(durSec, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tw = TweenService:Create(rootPart, ti, { CFrame = targetCf })
                tw:Play()
                tw.Completed:Wait()
            end)
            if not tweenOk then
                mountNotify({
                    Title = "Auto Sell",
                    Content = failureLabel .. tostring(tweenErr),
                })
                if rootPart.Parent then
                    rootPart.CFrame = targetCf
                end
            end
        end
        local holdPausedForAutoSell = false
        if locationHoldApi.pauseForAutoSell then
            holdPausedForAutoSell = locationHoldApi.pauseForAutoSell()
        end
        local root = getCurrentRoot()
        local previousCFrame = nil
        local restoreAssist = nil
        if type(autoSellTripAssist.begin) == "function" then
            restoreAssist = autoSellTripAssist.begin()
        end
        pcall(function()
            if root and root:IsA("BasePart") then
                previousCFrame = root.CFrame
                tweenRootToCFrame(root, SELL_TELEPORT_CFRAME, "Trip to buyer tween failed: ")
                waitWithGameplayPauseDetect(0)
            end
            local tripDeadline = os.clock() + AUTO_SELL_TRIP_TIMEOUT_SEC
            local soldOk = fireSellFishAllUntilBackpackRemove(tripDeadline)
            if soldOk then
                root = getCurrentRoot()
                local leTweenCf = limitedEventState.returnFromSellTweenCf
                if root and root:IsA("BasePart") and root.Parent and leTweenCf then
                    tweenRootToCFrame(root, leTweenCf, "Limited event return tween failed: ")
                    if limitedEventBridge.restartLimitedEventFreezeAfterSell then
                        pcall(limitedEventBridge.restartLimitedEventFreezeAfterSell, leTweenCf)
                    end
                elseif root and root:IsA("BasePart") and previousCFrame and root.Parent then
                    tweenRootToCFrame(root, previousCFrame, "Return from buyer tween failed: ")
                elseif previousCFrame then
                    mountNotify({
                        Title = "Auto Sell",
                        Content = "Could not return to previous position (character/root changed after pause)",
                    })
                end
            else
                root = getCurrentRoot()
                if root and root:IsA("BasePart") and previousCFrame and root.Parent then
                    tweenRootToCFrame(root, previousCFrame, "Return from buyer tween failed: ")
                elseif previousCFrame then
                    mountNotify({
                        Title = "Auto Sell",
                        Content = "Could not return to previous position (character/root changed after pause)",
                    })
                end
                local leCf = limitedEventState.returnFromSellTweenCf
                if leCf and limitedEventBridge.restartLimitedEventFreezeAfterSell then
                    pcall(limitedEventBridge.restartLimitedEventFreezeAfterSell, leCf)
                end
                if autoSellEnabled and os.clock() >= tripDeadline then
                    mountNotify({
                        Title = "Auto Sell",
                        Content = "Sell timed out after "
                            .. tostring(AUTO_SELL_TRIP_TIMEOUT_SEC)
                            .. "s — returned from buyer.",
                    })
                end
            end
        end)
        if restoreAssist then
            pcall(restoreAssist)
        end
        if locationHoldApi.resumeAfterAutoSell then
            locationHoldApi.resumeAfterAutoSell(holdPausedForAutoSell)
        end
        limitedEventState.pausedForAutoSell = false
    end

    -- If instant fishing is on: wait for current cycle (including MGR minigame) to finish, pause fishing, sell, resume.
    local function runAutoSellWithFishingCoordination()
        local pauseRequested = false
        if instantFishingEnabled then
            autoFishingPausedForSell = true
            pauseRequested = true
            while instantFishingCycleRunning do
                if not autoSellEnabled then
                    autoFishingPausedForSell = false
                    return
                end
                task.wait(0.05)
            end
            -- Cycle flag cleared before the fishing loop re-reads autoFishingPausedForSell; yield so
            -- runInstantFishingLoop cannot start another cast before pausing (see continue before runInstantFishingCycle).
            RunService.Heartbeat:Wait()
            RunService.Heartbeat:Wait()
            -- Reel UI / deferred reel autoplay can outlive the CMGR session wait inside the cycle.
            local settleT0 = os.clock()
            while instantFishingEnabled and autoSellEnabled and (os.clock() - settleT0) < 45 do
                if not isReelMinigameActive() and not reelAutoplayLoopRunning then
                    break
                end
                task.wait(0.05)
            end
        end
        if not autoSellEnabled then
            if pauseRequested then
                autoFishingPausedForSell = false
            end
            return
        end
        runAutoSellTweenSellAndReturn()
        if pauseRequested then
            task.wait(1)
            autoFishingPausedForSell = false
        end
    end

    MainTab:CreateDropdown({
        Name = "Sell type",
        Flag = "mancing_main_sellType",
        Options = { "Loop" },
        CurrentOption = "Loop",
        Callback = function(value)
            sellMode = value or "Loop"
        end,
    })

    MainTab:CreateInput({
        Name = "Duration (seconds)",
        PlaceholderText = "e.g. 60",
        Flag = "mancing_main_sellIntervalSec",
        CurrentValue = tostring(sellIntervalSeconds),
        Callback = function(value)
            local n = tonumber(value)
            if n and n >= 0 then
                sellIntervalSeconds = n
                sellIntervalRevision += 1
            end
        end,
    })

    local function startAutoSellSellLoop(skipFirstCoordSell: boolean?)
        if autoSellLoopRunning then
            autoSellLoopToken += 1
        end
        local myToken = autoSellLoopToken
        autoSellLoopRunning = true
        local skipOnce = skipFirstCoordSell == true
        task.spawn(function()
            while autoSellEnabled and myToken == autoSellLoopToken do
                if not skipOnce then
                    if sellMode == "Loop" then
                        runAutoSellWithFishingCoordination()
                    end
                else
                    skipOnce = false
                end
                local cycleStartedAt = os.clock()
                local seenRevision = sellIntervalRevision
                while autoSellEnabled and myToken == autoSellLoopToken do
                    local dur = math.max(sellIntervalSeconds, 0.05)
                    local elapsed = os.clock() - cycleStartedAt
                    local remaining = dur - elapsed
                    if remaining <= 0 then
                        break
                    end
                    task.wait(math.min(remaining, 0.25))
                    if seenRevision ~= sellIntervalRevision then
                        seenRevision = sellIntervalRevision
                    end
                end
            end
            if myToken == autoSellLoopToken then
                autoSellLoopRunning = false
            end
        end)
    end

    configLoadBridge.runAutoSellWithFishingCoordination = runAutoSellWithFishingCoordination
    configLoadBridge.startAutoSellSellLoop = startAutoSellSellLoop
    configLoadBridge.bumpAutoSellLoopToken = function()
        autoSellLoopToken += 1
    end

    MainTab:CreateToggle({
        Name = "Auto Sell",
        Flag = "mancing_main_autoSell",
        CurrentValue = false,
        Callback = function(enabled)
            autoSellEnabled = enabled
            if not enabled then
                autoSellLoopToken += 1
                return
            end
            if configLoadBridge.suppressNextAutoSellLoopSpawn then
                return
            end
            startAutoSellSellLoop()
        end,
    })
    MainTab:CreateSection("Location")
    MainTab:CreateSection("Spawn Boat")
    local spawnBoatOwnedIds = {}
    local spawnBoatDisplayList = {}
    local spawnBoatIdList = {}
    local selectedSpawnBoatId = nil
    local SpawnBoatDropdown

    local function getSpawnBoatShopScrollingFrame()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return nil
        end
        local gui = pg:FindFirstChild("BoatUI")
        if not gui then
            return nil
        end
        local canvas = gui:FindFirstChild("Canvas")
        local container = canvas and canvas:FindFirstChild("Container")
        local body = container and container:FindFirstChild("Body")
        return body and body:FindFirstChild("ScrollingFrame")
    end

    local function spawnBoatPriceLabelPlainText(priceLab)
        if not (priceLab and priceLab:IsA("TextLabel")) then
            return ""
        end
        local t = priceLab.Text
        local ok, ct = pcall(function()
            return priceLab.ContentText
        end)
        if ok and typeof(ct) == "string" and ct ~= "" then
            t = ct
        end
        t = t:gsub("\r\n", " "):gsub("\n", " ")
        return (t:match("^%s*(.-)%s*$") or t)
    end

    local function isSpawnBoatShopRowOwned(row)
        local price = row:FindFirstChild("Price")
        return string.lower(spawnBoatPriceLabelPlainText(price)) == "owned"
    end

    local function collectOwnedBoatIdsFromShop()
        spawnBoatOwnedIds = {}
        local scroll = getSpawnBoatShopScrollingFrame()
        if not scroll then
            return
        end
        for _, child in ipairs(scroll:GetChildren()) do
            if (child:IsA("Frame") or child:IsA("TextButton")) and not child.Name:match("_Information$") then
                if isSpawnBoatShopRowOwned(child) then
                    table.insert(spawnBoatOwnedIds, child.Name)
                end
            end
        end
    end

    local function spawnBoatDisplayNameForId(boatId)
        if not boatId or boatId == "" then
            return boatId
        end
        local scroll = getSpawnBoatShopScrollingFrame()
        if not scroll then
            return boatId
        end
        local row = scroll:FindFirstChild(boatId)
        if row and (row:IsA("Frame") or row:IsA("TextButton")) then
            local nm = row:FindFirstChild("BoatName")
            if nm and nm:IsA("TextLabel") and nm.Text ~= "" then
                return nm.Text
            end
        end
        return boatId
    end

    local function refreshSpawnBoatDropdown()
        collectOwnedBoatIdsFromShop()
        spawnBoatDisplayList = {}
        spawnBoatIdList = {}
        local sorted = {}
        for _, id in ipairs(spawnBoatOwnedIds) do
            table.insert(sorted, id)
        end
        table.sort(sorted)
        for _, id in ipairs(sorted) do
            if typeof(id) == "string" and id ~= "" then
                local disp = spawnBoatDisplayNameForId(id)
                table.insert(spawnBoatIdList, id)
                table.insert(spawnBoatDisplayList, disp .. " — " .. id)
            end
        end
        if SpawnBoatDropdown and SpawnBoatDropdown.Refresh then
            SpawnBoatDropdown:Refresh(spawnBoatDisplayList)
        end
        if selectedSpawnBoatId and not table.find(spawnBoatIdList, selectedSpawnBoatId) then
            selectedSpawnBoatId = nil
            if SpawnBoatDropdown and SpawnBoatDropdown.Select then
                SpawnBoatDropdown:Select(nil)
            end
            if SpawnBoatDropdown and SpawnBoatDropdown.Set then
                SpawnBoatDropdown:Set({})
            end
        end
    end

    SpawnBoatDropdown = MainTab:CreateDropdown({
        Name = "Owned boat",
        Flag = "mancing_main_spawnBoatPick",
        Options = spawnBoatDisplayList,
        CurrentOption = {}, Search = true,
        Callback = function(value)
            selectedSpawnBoatId = nil
            if value then
                local idx = table.find(spawnBoatDisplayList, value)
                if idx and spawnBoatIdList[idx] then
                    selectedSpawnBoatId = spawnBoatIdList[idx]
                end
            end
        end,
    })

    MainTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshSpawnBoatDropdown()
            local n = #spawnBoatIdList
            mountNotify({
                Title = "Spawn Boat",
                Content = (n == 0) and "No rows with Price = Owned (open BoatUI shop so templates load, then Refresh)"
                    or ("Updated list (" .. n .. " owned)"),
                Icon = (n == 0) and "x" or "check",
            })
        end,
    })

    MainTab:CreateButton({
        Name = "Spawn",
        Callback = function()
            if not selectedSpawnBoatId or selectedSpawnBoatId == "" then
                mountNotify({ Title = "Spawn Boat", Content = "Select an owned boat from the dropdown first" })
                return
            end
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if not remotes then
                mountNotify({ Title = "Spawn Boat", Content = "Remotes folder not found" })
                return
            end
            local spawnBoat = remotes:FindFirstChild("SpawnBoat")
            if not (spawnBoat and spawnBoat:IsA("RemoteFunction")) then
                mountNotify({ Title = "Spawn Boat", Content = "Remotes.SpawnBoat not found" })
                return
            end
            local invokeOk, expected, errMsg = pcall(function()
                return spawnBoat:InvokeServer(selectedSpawnBoatId)
            end)
            if not invokeOk then
                mountNotify({ Title = "Spawn Boat", Content = "Invoke failed: " .. tostring(expected) })
                return
            end
            if expected then
                mountNotify({ Title = "Spawn Boat", Content = "Spawn successful" })
            else
                mountNotify({
                    Title = "Spawn Boat",
                    Content = (typeof(errMsg) == "string" and errMsg ~= "" and errMsg) or "Spawn failed",
                })
            end
        end,
    })

    local locationPresetRows = {
        { name = "Pulau Raja Kepiting", pos = Vector3.new(2212.17, 11.65, -669.38), look = Vector3.new(-0.8572, -0.0000, -0.5150), spawnLocationAssist = false },
        { name = "Bagang Teluk Dalam", pos = Vector3.new(967.70, 7.95, 1269.47), look = Vector3.new(-0.8870, -0.0000, -0.4618), spawnLocationAssist = false },
        { name = "Bagang Teluk Tengah", pos = Vector3.new(3324.97, 7.95, -4416.49), look = Vector3.new(-0.3504, -0.0000, 0.9366), spawnLocationAssist = false },
        { name = "Bagang Teluk Luar", pos = Vector3.new(-1901.70, 7.95, -1312.37), look = Vector3.new(-0.9483, -0.0000, -0.3174), spawnLocationAssist = false },
        { name = "Bagang Ujung", pos = Vector3.new(-2927.68, 7.95, 4303.74), look = Vector3.new(0.3254, -0.0000, -0.9456), spawnLocationAssist = false },
        { name = "Pulau Seribu", pos = Vector3.new(1219.55, 2.15, 3283.45), look = Vector3.new(-0.1478, -0.0000, -0.9890), spawnLocationAssist = false },
        { name = "Pulau Boomerang", pos = Vector3.new(-1474.06, 2.06, 101.86), look = Vector3.new(-0.0348, -0.0000, -0.9994), spawnLocationAssist = false },
        { name = "Pulau Batu Karang", pos = Vector3.new(-798.19, 11.92, -3331.46), look = Vector3.new(0.3664, -0.0000, 0.9304), spawnLocationAssist = false },
        {
            name = "Ocean",
            pos = Vector3.new(-3832.58, 5, -2252.42),
            look = Vector3.new(0.7629, 0.0000, 0.6465),
            spawnLocationAssist = true,
            locationAssistPartName = "OceanStand",
        },
    }

    local locationDisplayList: { string } = {}
    local locationHoldCfByName: { [string]: CFrame } = {}
    local locationSpawnAssistByName: { [string]: boolean } = {}
    local locationAssistPartNameByName: { [string]: string } = {}
    for _, row in ipairs(locationPresetRows) do
        table.insert(locationDisplayList, row.name)
        local look = row.look
        if typeof(look) == "Vector3" and look.Magnitude >= 1e-5 then
            locationHoldCfByName[row.name] = CFrame.lookAt(row.pos, row.pos + look.Unit)
        else
            locationHoldCfByName[row.name] = CFrame.new(row.pos)
        end
        locationSpawnAssistByName[row.name] = row.spawnLocationAssist == true
        if row.spawnLocationAssist == true then
            local n = row.locationAssistPartName
            locationAssistPartNameByName[row.name] = (typeof(n) == "string" and n ~= "") and n or "LocationAssistPlatform"
        end
    end

    local selectedLocationName: string? = nil
    local teleportToLocationEnabled = false
    local lastLocationArrivalTweenSec: number? = nil
    local locationArrivalTweenToken = 0
    local locationArrivalTweenActive: Tween? = nil

    local function cancelLocationArrivalTween()
        locationArrivalTweenToken += 1
        if locationArrivalTweenActive then
            pcall(function()
                locationArrivalTweenActive:Cancel()
            end)
            locationArrivalTweenActive = nil
        end
    end

    local function stopLocationHold()
        cancelLocationArrivalTween()
        hideLocationAssist()
    end

    local function startLocationArrivalTween(): boolean
        if not teleportToLocationEnabled then
            return false
        end
        if limitedEventState.blocksLocationHold then
            cancelLocationArrivalTween()
            hideLocationAssist()
            return false
        end
        if not selectedLocationName or selectedLocationName == "" then
            cancelLocationArrivalTween()
            hideLocationAssist()
            return false
        end
        local holdCf = locationHoldCfByName[selectedLocationName]
        if not holdCf then
            cancelLocationArrivalTween()
            hideLocationAssist()
            return false
        end
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart or not rootPart:IsA("BasePart") then
            hideLocationAssist()
            return false
        end

        cancelLocationArrivalTween()
        local myToken = locationArrivalTweenToken
        if locationSpawnAssistByName[selectedLocationName] then
            setLocationAssistForTargetCFrame(holdCf, locationAssistPartNameByName[selectedLocationName])
        else
            hideLocationAssist()
        end

        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero

        local function beginLiftTravelLandThreePhase()
            if myToken ~= locationArrivalTweenToken then
                return
            end
            if not rootPart.Parent then
                locationArrivalTweenActive = nil
                return
            end

            local startPos = rootPart.Position
            local rotNow = rootPart.CFrame - rootPart.CFrame.Position
            local cruiseLift = effectiveLocationCruiseLiftStuds()
            local cfLift = CFrame.new(Vector3.new(startPos.X, startPos.Y + cruiseLift, startPos.Z)) * rotNow

            local targetPos = holdCf.Position
            local rotHold = holdCf - holdCf.Position
            local cfAboveTarget = CFrame.new(Vector3.new(targetPos.X, targetPos.Y + cruiseLift, targetPos.Z)) * rotHold

            local durSec = computeLocationArrivalDurationSec(cfLift.Position, cfAboveTarget.Position)
            lastLocationArrivalTweenSec = durSec

            local ease = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local easeTravel = TweenInfo.new(durSec, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local easeLand = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            local tw1 = TweenService:Create(rootPart, ease, { CFrame = cfLift })
            locationArrivalTweenActive = tw1
            tw1.Completed:Connect(function()
                if myToken ~= locationArrivalTweenToken then
                    return
                end
                local tw2 = TweenService:Create(rootPart, easeTravel, { CFrame = cfAboveTarget })
                locationArrivalTweenActive = tw2
                tw2.Completed:Connect(function()
                    if myToken ~= locationArrivalTweenToken then
                        return
                    end
                    local tw3 = TweenService:Create(rootPart, easeLand, { CFrame = holdCf })
                    locationArrivalTweenActive = tw3
                    tw3.Completed:Connect(function()
                        if myToken ~= locationArrivalTweenToken then
                            return
                        end
                        locationArrivalTweenActive = nil
                    end)
                    tw3:Play()
                end)
                tw2:Play()
            end)
            tw1:Play()
        end

        local capY = MANCING_LOCATION_ARRIVAL_START_WORLD_Y_MAX
        local p0 = rootPart.Position
        if p0.Y > capY then
            local rotCap = rootPart.CFrame - rootPart.CFrame.Position
            local capCf = CFrame.new(Vector3.new(p0.X, capY, p0.Z)) * rotCap
            local durCap = computeLocationArrivalDurationSec(p0, capCf.Position)
            local twCap = TweenService:Create(
                rootPart,
                TweenInfo.new(durCap, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { CFrame = capCf }
            )
            locationArrivalTweenActive = twCap
            twCap.Completed:Connect(function()
                if myToken ~= locationArrivalTweenToken then
                    return
                end
                beginLiftTravelLandThreePhase()
            end)
            twCap:Play()
        else
            beginLiftTravelLandThreePhase()
        end
        return true
    end

    local function tryActivateLocationHold(showFailureNotify: boolean): boolean
        if not teleportToLocationEnabled then
            return false
        end
        if limitedEventState.blocksLocationHold then
            stopLocationHold()
            return false
        end
        if not selectedLocationName or selectedLocationName == "" then
            stopLocationHold()
            if showFailureNotify then
                mountNotify({ Title = "Location", Content = "Select a location first" })
            end
            return false
        end
        if not locationHoldCfByName[selectedLocationName] then
            stopLocationHold()
            if showFailureNotify then
                mountNotify({ Title = "Location", Content = "Unknown location" })
            end
            return false
        end
        return startLocationArrivalTween()
    end

    function locationHoldApi.pauseForAutoSell(): boolean
        if not teleportToLocationEnabled then
            return false
        end
        stopLocationHold()
        return true
    end

    function locationHoldApi.resumeAfterAutoSell(wasPaused: boolean)
        if not wasPaused then
            return
        end
        if not teleportToLocationEnabled then
            return
        end
        if limitedEventState.blocksLocationHold then
            return
        end
        if not selectedLocationName or selectedLocationName == "" then
            return
        end
        if not locationHoldCfByName[selectedLocationName] then
            return
        end
        startLocationArrivalTween()
    end

    limitedEventBridge.stopLocationHold = stopLocationHold
    function limitedEventBridge.cancelMainLocationArrivalTweenOnly()
        cancelLocationArrivalTween()
    end
    function limitedEventBridge.resumeTeleportToLocationAfterLimitedEvent()
        limitedEventState.blocksLocationHold = false
        if not teleportToLocationEnabled then
            return
        end
        if not selectedLocationName or selectedLocationName == "" then
            return
        end
        if not locationHoldCfByName[selectedLocationName] then
            return
        end
        startLocationArrivalTween()
    end

    MainTab:CreateDropdown({
        Name = "Location",
        Flag = "mancing_main_locationPick",
        Options = locationDisplayList,
        CurrentOption = {}, Search = true,
        Callback = function(value)
            selectedLocationName = (value and value ~= "") and value or nil
            if teleportToLocationEnabled then
                tryActivateLocationHold(false)
            end
        end,
    })

    local TeleportLocationToggle
    TeleportLocationToggle = MainTab:CreateToggle({
        Name = "Go to Location"
            .. tostring(MANCING_LOCATION_ARRIVAL_SPEED_STUDS_PER_SEC)
            .. " studs/s, min/max clamped), then land on preset (1s). Re-tweens if you change the dropdown.",
        Flag = "mancing_main_teleportToLocation",
        CurrentValue = false,
        Callback = function(enabled)
            teleportToLocationEnabled = enabled
            if not enabled then
                stopLocationHold()
                return
            end
            if tryActivateLocationHold(true) then
                local sec = lastLocationArrivalTweenSec
                local durText = (typeof(sec) == "number") and string.format("%.1f", sec) or "?"
                mountNotify({
                    Title = "Location",
                    Content = "Tweening to "
                        .. tostring(selectedLocationName)
                        .. " (~"
                        .. durText
                        .. "s travel + 2s vertical)",
                })
            end
        end,
    })

    task.defer(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes") or ReplicatedStorage:WaitForChild("Remotes", 30)
        if remotes then
            local ownedBoats = remotes:FindFirstChild("OwnedBoats")
            if ownedBoats and ownedBoats:IsA("RemoteEvent") then
                ownedBoats.OnClientEvent:Connect(function()
                    task.defer(refreshSpawnBoatDropdown)
                end)
            end
        end
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui") or Players.LocalPlayer:WaitForChild("PlayerGui", 15)
        if pg then
            pg.ChildAdded:Connect(function(child)
                if child.Name == "BoatUI" then
                    refreshSpawnBoatDropdown()
                end
            end)
        end
    end)
end

-- */  Backpack Tab  /* --
-- Rarity strings: game client uses these in FishCatchNotification + FishingRodGui (RodBackpackHandler);
-- live data from Remotes.OwnedRods catalog (.Rarity per rod), GetBestiary entries, and fish Tools (UID, Rarity attr).
do
    local BackpackTab = Window:CreateTab("Backpack", 4483362458)

    local MANCING_DEFAULT_RARITY_ORDER = {
        "Common",
        "Uncommon",
        "Rare",
        "Epic",
        "Legendary",
        "Mythical",
    }

    local rarityRankLookup: { [string]: number } = {}
    for i, name in ipairs(MANCING_DEFAULT_RARITY_ORDER) do
        rarityRankLookup[name] = i
    end

    local function copyStringArray(arr: { string }): { string }
        local out: { string } = {}
        for i, v in ipairs(arr) do
            out[i] = v
        end
        return out
    end

    local function compareRarityNames(a: string, b: string): boolean
        local ra = rarityRankLookup[a]
        local rb = rarityRankLookup[b]
        if ra and rb then
            return ra < rb
        end
        if ra and not rb then
            return true
        end
        if not ra and rb then
            return false
        end
        return string.lower(a) < string.lower(b)
    end

    local function sortRarityNameList(names: { string })
        table.sort(names, compareRarityNames)
    end

    local function mergeRarityString(set: { [string]: boolean }, s: string?)
        if type(s) ~= "string" then
            return
        end
        s = string.gsub(string.gsub(s, "^%s+", ""), "%s+$", "")
        if s == "" then
            return
        end
        if s == "???" then
            return
        end
        set[s] = true
    end

    local function collectRarityFromValue(value: any, depth: number, set: { [string]: boolean }, visited: { [any]: boolean })
        if depth > 6 or type(value) ~= "table" then
            return
        end
        if visited[value] then
            return
        end
        visited[value] = true
        mergeRarityString(set, value.Rarity)
        for _, child in pairs(value) do
            if type(child) == "table" then
                collectRarityFromValue(child, depth + 1, set, visited)
            end
        end
    end

    local lastOwnedRodsCatalog: { [any]: any }? = nil

    local function mergeRaritiesFromOwnedRodsCatalog(set: { [string]: boolean }, catalog: { [any]: any }?)
        if type(catalog) ~= "table" then
            return
        end
        for _, info in pairs(catalog) do
            if type(info) == "table" then
                mergeRarityString(set, info.Rarity)
            end
        end
    end

    local function mergeRaritiesFromFishTools(set: { [string]: boolean }, player: Player)
        local function scan(container: Instance?)
            if not container then
                return
            end
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("Tool") and child:GetAttribute("FishingRod") == nil and child:GetAttribute("UID") ~= nil then
                    local rAttr = child:GetAttribute("Rarity")
                    if type(rAttr) == "string" then
                        mergeRarityString(set, rAttr)
                    end
                end
            end
        end
        scan(player:FindFirstChild("Backpack"))
        local ch = player.Character
        if ch then
            scan(ch)
        end
    end

    local function mergeRaritiesFromBestiary(set: { [string]: boolean })
        fetchAndMergeGlobalBestiaryFish()
        local list = GLOBAL_BESTIARY_FISH_BY_NAME
        local visited: { [any]: boolean } = {}
        for _, entry in pairs(list) do
            if type(entry) == "table" then
                collectRarityFromValue(entry, 0, set, visited)
            end
        end
    end

    local function buildRarityValuesList(): { string }
        local set: { [string]: boolean } = {}
        for _, name in ipairs(MANCING_DEFAULT_RARITY_ORDER) do
            set[name] = true
        end
        mergeRaritiesFromOwnedRodsCatalog(set, lastOwnedRodsCatalog)
        mergeRaritiesFromBestiary(set)
        mergeRaritiesFromFishTools(set, Players.LocalPlayer)
        local names: { string } = {}
        for name in pairs(set) do
            table.insert(names, name)
        end
        sortRarityNameList(names)
        return names
    end

    -- Lowercase keys → true; favors fish whose Rarity matches any selected tier (exact, case-insensitive).
    local favoriteAutoFavoriteRarityKeys: { [string]: boolean } = {}
    local autoFavoriteEnabled = false

    local function trimRarityString(s: string): string
        return string.gsub(string.gsub(s, "^%s+", ""), "%s+$", "")
    end

    local function syncFavoriteKeysFromMultiDropdownValue(value: any)
        local keys: { [string]: boolean } = {}
        if type(value) == "table" then
            for _, item in ipairs(value) do
                local s = (type(item) == "table" and item.Title) or item
                if type(s) == "string" then
                    local t = trimRarityString(s)
                    if t ~= "" then
                        keys[string.lower(t)] = true
                    end
                end
            end
        elseif type(value) == "string" and value ~= "" then
            keys[string.lower(trimRarityString(value))] = true
        end
        favoriteAutoFavoriteRarityKeys = keys
    end

    local function fishRarityMatchesAutoFavoriteSelections(fishRarityRaw: any): boolean
        if type(fishRarityRaw) ~= "string" then
            return false
        end
        local fishR = trimRarityString(fishRarityRaw)
        if fishR == "" then
            return false
        end
        if next(favoriteAutoFavoriteRarityKeys) == nil then
            return false
        end
        return favoriteAutoFavoriteRarityKeys[string.lower(fishR)] == true
    end

    local function onBackpackAddClientPayload(payload: any)
        if not autoFavoriteEnabled then
            return
        end
        if not fishingAutomationState.instantFishingEnabled then
            return
        end
        if type(payload) ~= "table" then
            return
        end
        if not fishRarityMatchesAutoFavoriteSelections(payload.Rarity) then
            return
        end
        if payload.IsLocked == true then
            return
        end
        local uidRaw = payload.UID
        if type(uidRaw) ~= "string" then
            return
        end
        local uid = trimRarityString(uidRaw)
        if uid == "" then
            return
        end
        local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
        local toggleLock = remotesFolder and remotesFolder:FindFirstChild("ToggleLock")
        if not (toggleLock and toggleLock:IsA("RemoteEvent")) then
            return
        end
        pcall(function()
            (toggleLock :: RemoteEvent):FireServer(uid)
        end)
    end

    BackpackTab:CreateSection("Favorite")
    local FavoriteByRarityDropdown
    FavoriteByRarityDropdown = BackpackTab:CreateDropdown({
        Name = "By Rarity",
        Flag = "mancing_backpack_favoriteByRarity",
        Options = copyStringArray(MANCING_DEFAULT_RARITY_ORDER),
        CurrentOption = {},
        Multi = true,
        Callback = function(value)
            syncFavoriteKeysFromMultiDropdownValue(value)
        end,
    })

    local function applyFavoriteRarityDropdownPicks(canonicalNames: { string })
        if not FavoriteByRarityDropdown then
            return
        end
        syncFavoriteKeysFromMultiDropdownValue(canonicalNames)
        if FavoriteByRarityDropdown.Select then
            FavoriteByRarityDropdown:Select(canonicalNames)
        elseif FavoriteByRarityDropdown.Set then
            FavoriteByRarityDropdown:Set(canonicalNames)
        end
    end

    local function refreshFavoriteRarityDropdown()
        local list = buildRarityValuesList()
        if #list == 0 then
            list = copyStringArray(MANCING_DEFAULT_RARITY_ORDER)
        end
        if FavoriteByRarityDropdown and FavoriteByRarityDropdown.Refresh then
            FavoriteByRarityDropdown:Refresh(list)
        end
        local newPicks: { string } = {}
        for _, name in ipairs(list) do
            if favoriteAutoFavoriteRarityKeys[string.lower(name)] then
                table.insert(newPicks, name)
            end
        end
        applyFavoriteRarityDropdownPicks(newPicks)
    end

    BackpackTab:CreateToggle({
        Name = "Auto Favorite",
        Flag = "mancing_backpack_autoFavorite",
        CurrentValue = false,
        Callback = function(enabled)
            autoFavoriteEnabled = enabled
        end,
    })
    BackpackTab:CreateSection("Fish Information")
    local FishInformationParagraph = BackpackTab:CreateParagraph({
        Title = "Fish Description",
        Content = "Select a fish to show details from GetBestiary.",
    })
    BackpackTab:CreateSection("Fish by Place")
    local FishByPlaceParagraph = BackpackTab:CreateParagraph({
        Title = "Fish List",
        Content = "Select a location to see fish from that biome.",
    })

    local fishInfoSelectedName: string? = nil
    local fishInfoNameByDisplay: { [string]: string } = {}
    local fishByPlaceSelectedBiome: string? = nil
    local fishByPlaceOrderBy = "Rarity"
    local fishByPlaceRarityOrderRank: { [string]: number } = {
        Common = 1,
        Uncommon = 2,
        Rare = 3,
        Epic = 4,
        Legendary = 5,
        Mythic = 6,
    }
    local FishInformationDropdown
    local FishByPlaceDropdown

    local function buildFishInfoDisplay(name: string): string
        local row = GLOBAL_BESTIARY_FISH_BY_NAME[name]
        local rarity = "Unknown"
        if type(row) == "table" and type(row.Rarity) == "string" and row.Rarity ~= "" then
            rarity = row.Rarity
        end
        return string.format("%s (%s)", name, rarity)
    end

    local function fishInfoDescriptionForName(name: string?): string
        if not name or name == "" then
            return "Select a fish to show details from GetBestiary."
        end
        local row = GLOBAL_BESTIARY_FISH_BY_NAME[name]
        if type(row) ~= "table" then
            return "No details available yet. Try Refresh shortly."
        end
        local discovered = (row.IsDiscovered == true) and "Yes" or "No"
        local rarity = (type(row.Rarity) == "string" and row.Rarity ~= "") and row.Rarity or "Unknown"
        local basePrice = (type(row.BasePrice) == "number") and tostring(row.BasePrice) or "Unknown"
        local sizeRange = "Unknown"
        if type(row.SizeRange) == "table" and type(row.SizeRange[1]) == "number" and type(row.SizeRange[2]) == "number" then
            sizeRange = string.format("%s - %s", tostring(row.SizeRange[1]), tostring(row.SizeRange[2]))
        end
        local biomeText = "Unknown"
        if type(row.Biome) == "table" and #row.Biome > 0 then
            local names: { string } = {}
            for _, biomeName in ipairs(row.Biome) do
                if type(biomeName) == "string" and biomeName ~= "" then
                    table.insert(names, biomeName)
                end
            end
            if #names > 0 then
                biomeText = table.concat(names, ", ")
            end
        end
        return string.format(
            "Name: %s\nDiscovered: %s\nRarity: %s\nBase Price: %s\nSize Range: %s\nBiome: %s",
            tostring(name),
            discovered,
            rarity,
            basePrice,
            sizeRange,
            biomeText
        )
    end

    local function getDistinctBiomeValues(): { string }
        local biomeSet: { [string]: boolean } = {}
        for _, row in pairs(GLOBAL_BESTIARY_FISH_BY_NAME) do
            if type(row) == "table" and type(row.Biome) == "table" then
                for _, biomeName in ipairs(row.Biome) do
                    if type(biomeName) == "string" then
                        local b = string.gsub(string.gsub(biomeName, "^%s+", ""), "%s+$", "")
                        if b ~= "" and b ~= "???" then
                            biomeSet[b] = true
                        end
                    end
                end
            end
        end
        local out: { string } = {}
        for biomeName in pairs(biomeSet) do
            table.insert(out, biomeName)
        end
        table.sort(out, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return out
    end

    local function fishListByBiomeDescription(biomeName: string?): string
        if not biomeName or biomeName == "" then
            return "Select a location to see fish from that biome."
        end
        local matchedRows: { { name: string, rarity: string, rank: number } } = {}
        for _, fishName in ipairs(getGlobalBestiaryFishList()) do
            local row = GLOBAL_BESTIARY_FISH_BY_NAME[fishName]
            if type(row) == "table" and type(row.Biome) == "table" then
                local matches = false
                for _, b in ipairs(row.Biome) do
                    if type(b) == "string" and b == biomeName then
                        matches = true
                        break
                    end
                end
                if matches then
                    local rarity = (type(row.Rarity) == "string" and row.Rarity ~= "") and row.Rarity or "Unknown"
                    local rank = fishByPlaceRarityOrderRank[rarity] or 999
                    table.insert(matchedRows, { name = fishName, rarity = rarity, rank = rank })
                end
            end
        end
        if #matchedRows == 0 then
            return "No fish found for " .. tostring(biomeName)
        end
        if fishByPlaceOrderBy == "Name" then
            table.sort(matchedRows, function(a, b)
                return string.lower(a.name) < string.lower(b.name)
            end)
        else
            table.sort(matchedRows, function(a, b)
                if a.rank ~= b.rank then
                    return a.rank < b.rank
                end
                return string.lower(a.name) < string.lower(b.name)
            end)
        end
        local lines: { string } = {}
        for _, row in ipairs(matchedRows) do
            table.insert(lines, string.format("- %s (%s)", row.name, row.rarity))
        end
        return table.concat(lines, "\n")
    end

    local function refreshFishInformationSection(): boolean
        local changed = fetchAndMergeGlobalBestiaryFish()
        local names = getGlobalBestiaryFishList()
        fishInfoNameByDisplay = {}
        local displayValues: { string } = {}
        for _, name in ipairs(names) do
            local display = buildFishInfoDisplay(name)
            fishInfoNameByDisplay[display] = name
            table.insert(displayValues, display)
        end
        if FishInformationDropdown and FishInformationDropdown.Refresh then
            FishInformationDropdown:Refresh(displayValues)
        end
        if fishInfoSelectedName and not table.find(names, fishInfoSelectedName) then
            fishInfoSelectedName = nil
            if FishInformationDropdown and FishInformationDropdown.Select then
                FishInformationDropdown:Select(nil)
            elseif FishInformationDropdown and FishInformationDropdown.Set then
                FishInformationDropdown:Set({})
            end
        end
        if FishInformationParagraph and FishInformationParagraph.Set then
            FishInformationParagraph:Set({
                Content = fishInfoDescriptionForName(fishInfoSelectedName),
            })
        end

        local biomes = getDistinctBiomeValues()
        if FishByPlaceDropdown and FishByPlaceDropdown.Refresh then
            FishByPlaceDropdown:Refresh(biomes)
        end
        if fishByPlaceSelectedBiome and not table.find(biomes, fishByPlaceSelectedBiome) then
            fishByPlaceSelectedBiome = nil
            if FishByPlaceDropdown and FishByPlaceDropdown.Select then
                FishByPlaceDropdown:Select(nil)
            elseif FishByPlaceDropdown and FishByPlaceDropdown.Set then
                FishByPlaceDropdown:Set({})
            end
        end
        if FishByPlaceParagraph and FishByPlaceParagraph.Set then
            FishByPlaceParagraph:Set({
                Content = fishListByBiomeDescription(fishByPlaceSelectedBiome),
            })
        end
        return changed
    end

    FishInformationDropdown = BackpackTab:CreateDropdown({
        Name = "Fish",
        Flag = "mancing_backpack_fishInfoPick",
        Options = {},
        CurrentOption = {}, Search = true,
        Callback = function(value)
            fishInfoSelectedName = (type(value) == "string" and fishInfoNameByDisplay[value]) or nil
            if FishInformationParagraph and FishInformationParagraph.Set then
                FishInformationParagraph:Set({
                    Content = fishInfoDescriptionForName(fishInfoSelectedName),
                })
            end
        end,
    })

    FishByPlaceDropdown = BackpackTab:CreateDropdown({
        Name = "Location",
        Flag = "mancing_backpack_fishByPlaceBiome",
        Options = {},
        CurrentOption = {}, Search = true,
        Callback = function(value)
            fishByPlaceSelectedBiome = (type(value) == "string" and value ~= "") and value or nil
            if FishByPlaceParagraph and FishByPlaceParagraph.Set then
                FishByPlaceParagraph:Set({
                    Content = fishListByBiomeDescription(fishByPlaceSelectedBiome),
                })
            end
        end,
    })

    BackpackTab:CreateDropdown({
        Name = "Order By",
        Flag = "mancing_backpack_fishByPlaceOrderBy",
        Options = { "Name", "Rarity" },
        CurrentOption = "Rarity",
        Callback = function(value)
            if value == "Name" or value == "Rarity" then
                fishByPlaceOrderBy = value
            else
                fishByPlaceOrderBy = "Rarity"
            end
            if FishByPlaceParagraph and FishByPlaceParagraph.Set then
                FishByPlaceParagraph:Set({
                    Content = fishListByBiomeDescription(fishByPlaceSelectedBiome),
                })
            end
        end,
    })

    task.defer(function()
        local lastFishInfoRefreshAt = 0
        local fishInfoRefreshQueued = false
        local lastFavoriteRefreshAt = 0
        local favoriteRefreshQueued = false
        local function requestFishInfoRefresh()
            local now = os.clock()
            if now - lastFishInfoRefreshAt >= 0.35 then
                lastFishInfoRefreshAt = now
                task.defer(refreshFishInformationSection)
                return
            end
            if fishInfoRefreshQueued then
                return
            end
            fishInfoRefreshQueued = true
            task.delay(0.35, function()
                fishInfoRefreshQueued = false
                lastFishInfoRefreshAt = os.clock()
                refreshFishInformationSection()
            end)
        end
        local function requestFavoriteRarityRefresh()
            local now = os.clock()
            if now - lastFavoriteRefreshAt >= 0.6 then
                lastFavoriteRefreshAt = now
                task.defer(refreshFavoriteRarityDropdown)
                return
            end
            if favoriteRefreshQueued then
                return
            end
            favoriteRefreshQueued = true
            task.delay(0.6, function()
                favoriteRefreshQueued = false
                lastFavoriteRefreshAt = os.clock()
                refreshFavoriteRarityDropdown()
            end)
        end

        local remotes = ReplicatedStorage:WaitForChild("Remotes", 60)
        local function attachBestiaryIncomingListener(remoteInst: Instance)
            if not (remoteInst and remoteInst:IsA("RemoteEvent")) then
                return
            end
            if not remoteInst.Name:match("Bestiary") then
                return
            end
            remoteInst.OnClientEvent:Connect(function(payload: any)
                if mergeBestiaryRowsFromPayload(payload) then
                    requestFishInfoRefresh()
                    requestFavoriteRarityRefresh()
                end
            end)
        end
        if remotes then
            for _, child in ipairs(remotes:GetChildren()) do
                attachBestiaryIncomingListener(child)
            end
            remotes.ChildAdded:Connect(function(child)
                attachBestiaryIncomingListener(child)
            end)
            local owned = remotes:FindFirstChild("OwnedRods")
            if owned and owned:IsA("RemoteEvent") then
                owned.OnClientEvent:Connect(function(_rodNames: any, catalog: any)
                    if type(catalog) == "table" then
                        lastOwnedRodsCatalog = catalog
                        requestFavoriteRarityRefresh()
                    end
                end)
            end
            local backpackAdd = remotes:FindFirstChild("BackpackAdd") or remotes:WaitForChild("BackpackAdd", 30)
            if backpackAdd and backpackAdd:IsA("RemoteEvent") then
                backpackAdd.OnClientEvent:Connect(function(payload: any)
                    onBackpackAddClientPayload(payload)
                    requestFishInfoRefresh()
                end)
            end
        end
        refreshFishInformationSection()
        refreshFavoriteRarityDropdown()
        -- task.spawn(function()
        --     while true do
        --         task.wait(15)
        --         if refreshFishInformationSection() then
        --             refreshFavoriteRarityDropdown()
        --         end
        --     end
        -- end)
    end)
end

-- */  Event Tab  /* --
do
    local EventTab = Window:CreateTab("Event", 4483362458)

    -- Limited Event: hourly :30 (+5s delay) staging at Bagang Teluk Tengah, tween to
    -- Workspace.BiomeRegion.LimitedEvent.LimitedEvent (Y forced to 5), assist stand until :50, then return.
    local LIMITED_EVENT_STAGING_CF = CFrame.lookAt(
        Vector3.new(3324.97, 7.95, -4416.49),
        Vector3.new(3324.97, 7.95, -4416.49) + Vector3.new(-0.3504, 0, 0.9366).Unit
    )
    local LIMITED_EVENT_ASSIST_STAGING_NAME = "LimitedEventStagingStand"
    local LIMITED_EVENT_ASSIST_SPOT_NAME = "LimitedEventSpotStand"
    local LIMITED_EVENT_STAGING_DELAY_SEC = 5
    -- After teleporting to staging (Bagang Teluk Tengah), only wait this long for LimitedEvent to appear; then return home.
    local LIMITED_EVENT_STAGING_WAIT_FOR_EVENT_SEC = 5
    local LIMITED_EVENT_CLOCK_POLL_SEC = 0.5

    local function limitedEventGetHumanoidRootPart(): BasePart?
        local character = Players.LocalPlayer.Character
        if not character then
            return nil
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            return root
        end
        local pp = character.PrimaryPart
        if pp and pp:IsA("BasePart") then
            return pp
        end
        return nil
    end

    local function limitedEventGetTargetPart(): BasePart?
        local br = Workspace:FindFirstChild("BiomeRegion")
        if not br then
            return nil
        end
        local leFolder = br:FindFirstChild("LimitedEvent")
        if not leFolder then
            return nil
        end
        local node = leFolder:FindFirstChild("LimitedEvent")
        if not node then
            return nil
        end
        if node:IsA("BasePart") then
            return node
        end
        if node:IsA("ObjectValue") then
            local v = node.Value
            if v and v:IsA("BasePart") then
                return v
            end
        end
        if node:IsA("Model") then
            local pp = node.PrimaryPart
            if pp and pp:IsA("BasePart") then
                return pp
            end
            local fb = node:FindFirstChildWhichIsA("BasePart", true)
            if fb and fb:IsA("BasePart") then
                return fb
            end
        end
        return nil
    end

    local autoLimitedTeleportEnabled = false
    local limitedEventLoopToken = 0
    local limitedEventSavedReturnCf: CFrame? = nil
    local limitedEventSessionBusy = false
    local limitedEventLastHourlyBucket = -1
    local limitedEventMoveTween: Tween? = nil
    local limitedEventMoveTweenToken = 0

    local function limitedEventStopFreeze()
        -- Legacy name: previously disconnected Heartbeat freeze; spot is held by assist part only now.
    end

    function limitedEventBridge.stopLimitedEventFreezeForAutoSell()
        limitedEventStopFreeze()
        limitedEventState.blocksLocationHold = false
    end

    -- At the event spot: invisible assist platform only. Must not call stopLocationHold — it hides assist.
    local function limitedEventEnterLimitedEventSpot(cf: CFrame)
        limitedEventStopFreeze()
        limitedEventState.returnFromSellTweenCf = cf
        limitedEventState.blocksLocationHold = true
        if limitedEventBridge.cancelMainLocationArrivalTweenOnly then
            pcall(limitedEventBridge.cancelMainLocationArrivalTweenOnly)
        end
        setLocationAssistForTargetCFrame(cf, LIMITED_EVENT_ASSIST_SPOT_NAME)
    end

    function limitedEventBridge.restartLimitedEventFreezeAfterSell(cf: CFrame)
        if not autoLimitedTeleportEnabled then
            return
        end
        limitedEventStopFreeze()
        limitedEventState.returnFromSellTweenCf = cf
        limitedEventState.blocksLocationHold = true
        if limitedEventBridge.cancelMainLocationArrivalTweenOnly then
            pcall(limitedEventBridge.cancelMainLocationArrivalTweenOnly)
        end
        setLocationAssistForTargetCFrame(cf, LIMITED_EVENT_ASSIST_SPOT_NAME)
    end

    local function limitedEventCancelActiveTravelTween()
        limitedEventMoveTweenToken += 1
        if limitedEventMoveTween then
            pcall(function()
                limitedEventMoveTween:Cancel()
            end)
            limitedEventMoveTween = nil
        end
    end

    -- Same 3-phase path as Main "Go to Location": optional tween to world Y <= MANCING_LOCATION_ARRIVAL_START_WORLD_Y_MAX, then cruise Y (clamp 10–14 studs) + 1s lift, travel, 1s land.
    -- returnMode: homeward tween — only chain cancel / missing root abort (still runs if Auto Limited is off).
    local function limitedEventTweenRootThreePhase(
        root: BasePart,
        holdCf: CFrame,
        sessionToken: number,
        onDone: (boolean) -> (),
        returnMode: boolean?
    )
        if not root.Parent then
            onDone(false)
            return
        end
        limitedEventMoveTweenToken += 1
        local chainToken = limitedEventMoveTweenToken
        if limitedEventMoveTween then
            pcall(function()
                limitedEventMoveTween:Cancel()
            end)
            limitedEventMoveTween = nil
        end

        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero

        local function aborted(): boolean
            if chainToken ~= limitedEventMoveTweenToken then
                return true
            end
            if not root.Parent then
                return true
            end
            if returnMode == true then
                return false
            end
            if sessionToken ~= limitedEventLoopToken then
                return true
            end
            if not autoLimitedTeleportEnabled then
                return true
            end
            return false
        end

        local function beginLiftTravelLandThreePhase()
            if aborted() then
                onDone(false)
                return
            end

            local startPos = root.Position
            local rotNow = root.CFrame - root.CFrame.Position
            local cruiseLift = effectiveLocationCruiseLiftStuds()
            local cfLift = CFrame.new(Vector3.new(startPos.X, startPos.Y + cruiseLift, startPos.Z)) * rotNow

            local targetPos = holdCf.Position
            local rotHold = holdCf - holdCf.Position
            local cfAboveTarget = CFrame.new(Vector3.new(targetPos.X, targetPos.Y + cruiseLift, targetPos.Z)) * rotHold

            local durSec = computeLocationArrivalDurationSec(cfLift.Position, cfAboveTarget.Position)

            local ease = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local easeTravel = TweenInfo.new(durSec, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            local easeLand = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

            local tw1 = TweenService:Create(root, ease, { CFrame = cfLift })
            limitedEventMoveTween = tw1
            tw1.Completed:Connect(function()
                if aborted() then
                    onDone(false)
                    return
                end
                local tw2 = TweenService:Create(root, easeTravel, { CFrame = cfAboveTarget })
                limitedEventMoveTween = tw2
                tw2.Completed:Connect(function()
                    if aborted() then
                        onDone(false)
                        return
                    end
                    local tw3 = TweenService:Create(root, easeLand, { CFrame = holdCf })
                    limitedEventMoveTween = tw3
                    tw3.Completed:Connect(function()
                        if aborted() then
                            onDone(false)
                            return
                        end
                        limitedEventMoveTween = nil
                        onDone(true)
                    end)
                    tw3:Play()
                end)
                tw2:Play()
            end)
            tw1:Play()
        end

        local capY = MANCING_LOCATION_ARRIVAL_START_WORLD_Y_MAX
        local p0 = root.Position
        if p0.Y > capY then
            local rotCap = root.CFrame - root.CFrame.Position
            local capCf = CFrame.new(Vector3.new(p0.X, capY, p0.Z)) * rotCap
            local durCap = computeLocationArrivalDurationSec(p0, capCf.Position)
            local twCap = TweenService:Create(
                root,
                TweenInfo.new(durCap, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { CFrame = capCf }
            )
            limitedEventMoveTween = twCap
            twCap.Completed:Connect(function()
                if aborted() then
                    limitedEventMoveTween = nil
                    onDone(false)
                    return
                end
                beginLiftTravelLandThreePhase()
            end)
            twCap:Play()
        else
            beginLiftTravelLandThreePhase()
        end
    end

    local function limitedEventReturnToSavedAndRelease()
        limitedEventCancelActiveTravelTween()
        limitedEventStopFreeze()
        limitedEventState.returnFromSellTweenCf = nil
        local backCf = limitedEventSavedReturnCf
        limitedEventSavedReturnCf = nil
        limitedEventState.blocksLocationHold = false
        hideLocationAssist()

        local root = limitedEventGetHumanoidRootPart()
        if root and backCf and root.Parent then
            local returnDone = false
            local returnOk = false
            limitedEventTweenRootThreePhase(root, backCf, 0, function(ok)
                returnOk = ok
                returnDone = true
            end, true)
            while not returnDone do
                task.wait(0.05)
            end
            if not returnOk and root.Parent then
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
                root.CFrame = backCf
            end
        end
        if limitedEventBridge.resumeTeleportToLocationAfterLimitedEvent then
            pcall(limitedEventBridge.resumeTeleportToLocationAfterLimitedEvent)
        end
    end

    local function limitedEventWallMinuteSecond(): (number, number)
        local t = os.date("*t")
        return t.min, t.sec
    end

    local function limitedEventRunSession(trigger: string)
        if not autoLimitedTeleportEnabled or limitedEventSessionBusy then
            return
        end
        if limitedEventState.pausedForAutoSell then
            return
        end
        limitedEventSessionBusy = true
        local myToken = limitedEventLoopToken
        local ok, err = pcall(function()
            if not autoLimitedTeleportEnabled or myToken ~= limitedEventLoopToken then
                return
            end
            limitedEventState.returnFromSellTweenCf = nil
            while limitedEventState.pausedForAutoSell and autoLimitedTeleportEnabled and myToken == limitedEventLoopToken do
                task.wait(0.25)
            end
            if not autoLimitedTeleportEnabled or myToken ~= limitedEventLoopToken then
                return
            end

            local root = limitedEventGetHumanoidRootPart()
            if root then
                limitedEventSavedReturnCf = root.CFrame
            else
                limitedEventSavedReturnCf = nil
            end
            limitedEventState.blocksLocationHold = true
            if limitedEventBridge.stopLocationHold then
                pcall(limitedEventBridge.stopLocationHold)
            end

            if not root or not root.Parent then
                limitedEventReturnToSavedAndRelease()
                return
            end

            setLocationAssistForTargetCFrame(LIMITED_EVENT_STAGING_CF, LIMITED_EVENT_ASSIST_STAGING_NAME)

            local stagingTravelOk = false
            local stagingTravelDone = false
            limitedEventTweenRootThreePhase(root, LIMITED_EVENT_STAGING_CF, myToken, function(ok)
                stagingTravelOk = ok
                stagingTravelDone = true
            end)
            while not stagingTravelDone do
                if myToken ~= limitedEventLoopToken or not autoLimitedTeleportEnabled then
                    limitedEventCancelActiveTravelTween()
                    limitedEventReturnToSavedAndRelease()
                    return
                end
                task.wait(0.05)
            end
            if not stagingTravelOk then
                limitedEventReturnToSavedAndRelease()
                return
            end

            local foundPart: BasePart? = nil
            local stagingWaitDeadline = os.clock() + LIMITED_EVENT_STAGING_WAIT_FOR_EVENT_SEC
            while autoLimitedTeleportEnabled and myToken == limitedEventLoopToken do
                if limitedEventState.pausedForAutoSell then
                    task.wait(0.25)
                else
                    foundPart = limitedEventGetTargetPart()
                    if foundPart then
                        break
                    end
                    local m, s = limitedEventWallMinuteSecond()
                    if m > 50 or (m == 50 and s >= 0) then
                        break
                    end
                    if os.clock() >= stagingWaitDeadline then
                        break
                    end
                    task.wait(0.25)
                end
            end

            if not autoLimitedTeleportEnabled or myToken ~= limitedEventLoopToken then
                limitedEventReturnToSavedAndRelease()
                return
            end

            if not foundPart then
                limitedEventReturnToSavedAndRelease()
                return
            end

            local p = foundPart.Position
            local atCf = CFrame.new(Vector3.new(p.X, 5, p.Z))

            root = limitedEventGetHumanoidRootPart()
            if not root or not root.Parent then
                limitedEventReturnToSavedAndRelease()
                return
            end

            setLocationAssistForTargetCFrame(atCf, LIMITED_EVENT_ASSIST_SPOT_NAME)

            local spotTravelOk = false
            local spotTravelDone = false
            limitedEventTweenRootThreePhase(root, atCf, myToken, function(ok)
                spotTravelOk = ok
                spotTravelDone = true
            end)
            while not spotTravelDone do
                if myToken ~= limitedEventLoopToken or not autoLimitedTeleportEnabled then
                    limitedEventCancelActiveTravelTween()
                    limitedEventReturnToSavedAndRelease()
                    return
                end
                task.wait(0.05)
            end
            if not spotTravelOk then
                limitedEventReturnToSavedAndRelease()
                return
            end

            limitedEventEnterLimitedEventSpot(atCf)

            while autoLimitedTeleportEnabled and myToken == limitedEventLoopToken do
                if limitedEventState.pausedForAutoSell then
                    task.wait(0.25)
                else
                    local m, s = limitedEventWallMinuteSecond()
                    if m > 50 or (m == 50 and s >= 0) then
                        break
                    end
                    task.wait(LIMITED_EVENT_CLOCK_POLL_SEC)
                end
            end

            limitedEventReturnToSavedAndRelease()
        end)
        limitedEventSessionBusy = false
        if not ok then
            warn("[Limited Event] session error (" .. tostring(trigger) .. "): " .. tostring(err))
            limitedEventReturnToSavedAndRelease()
        end
    end

    local function limitedEventEnsureClockLoop()
        task.spawn(function()
            local myToken = limitedEventLoopToken
            while autoLimitedTeleportEnabled and myToken == limitedEventLoopToken do
                task.wait(1)
                if not autoLimitedTeleportEnabled or myToken ~= limitedEventLoopToken then
                    break
                end
                if limitedEventState.pausedForAutoSell or limitedEventSessionBusy then
                    continue
                end
                local t = os.date("*t")
                local bucket = math.floor(os.time() / 3600)
                if t.min == 30 and t.sec >= LIMITED_EVENT_STAGING_DELAY_SEC and t.sec <= 20 and bucket ~= limitedEventLastHourlyBucket then
                    limitedEventLastHourlyBucket = bucket
                    task.spawn(function()
                        limitedEventRunSession("hourly")
                    end)
                end
            end
        end)
    end

    EventTab:CreateSection("Limited Event")
    EventTab:CreateToggle({
        Name = "Auto Teleport",
        Flag = "mancing_event_limitedAutoTeleport",
        CurrentValue = false,
        Callback = function(enabled)
            autoLimitedTeleportEnabled = enabled
            limitedEventLoopToken += 1
            limitedEventLastHourlyBucket = -1
            if not enabled then
                limitedEventCancelActiveTravelTween()
                limitedEventStopFreeze()
                limitedEventState.returnFromSellTweenCf = nil
                limitedEventState.blocksLocationHold = false
                limitedEventSavedReturnCf = nil
                limitedEventSessionBusy = false
                if limitedEventBridge.resumeTeleportToLocationAfterLimitedEvent then
                    pcall(limitedEventBridge.resumeTeleportToLocationAfterLimitedEvent)
                end
                return
            end
            task.spawn(function()
                limitedEventRunSession("initial")
            end)
            limitedEventEnsureClockLoop()
        end,
    })
    EventTab:CreateSection("Galatama")
    local GALATAMA_QUEUE_MIN_X = 2557
    local GALATAMA_QUEUE_MAX_X = 2577.50
    local GALATAMA_QUEUE_MIN_Y = 2.7
    local GALATAMA_QUEUE_MAX_Y = 8.00
    local GALATAMA_QUEUE_MIN_Z = -801
    local GALATAMA_QUEUE_MAX_Z = -775
    local GALATAMA_SERVER_PLACE_ID = 78404864377525

    local GalatamaQueueStatusParagraph = EventTab:CreateParagraph({
        Title = "Status",
        Content = "Queue: Checking...",
    })

    local function isInsideGalatamaQueueArea(pos: Vector3): boolean
        return pos.X >= GALATAMA_QUEUE_MIN_X
            and pos.X <= GALATAMA_QUEUE_MAX_X
            and pos.Y >= GALATAMA_QUEUE_MIN_Y
            and pos.Y <= GALATAMA_QUEUE_MAX_Y
            and pos.Z >= GALATAMA_QUEUE_MIN_Z
            and pos.Z <= GALATAMA_QUEUE_MAX_Z
    end

    local function getLocalPlayerRootPart()
        local character = Players.LocalPlayer.Character
        if not character then
            return nil
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            return root
        end
        local pp = character.PrimaryPart
        if pp and pp:IsA("BasePart") then
            return pp
        end
        return nil
    end

    local function updateGalatamaQueueStatus()
        if not (GalatamaQueueStatusParagraph and GalatamaQueueStatusParagraph.Set) then
            return
        end
        local root = getLocalPlayerRootPart()
        if not root then
            GalatamaQueueStatusParagraph:Set({
                Content = "Queue: Unknown (character/root not ready)",
            })
            return
        end
        local inQueue = isInsideGalatamaQueueArea(root.Position)
        if inQueue then
            GalatamaQueueStatusParagraph:Set({ Content = "Queue: In queue" })
        else
            GalatamaQueueStatusParagraph:Set({ Content = "Queue: Not in queue" })
        end
    end

    local autoJoinGalatamaQueueEnabled = false
    local autoJoinGalatamaQueueLoopRunning = false
    local AUTO_JOIN_GALATAMA_RETRY_SEC = 1.0

    local autoJoinGalatamaServerEnabled = false
    local autoJoinGalatamaServerLoopRunning = false
    local AUTO_JOIN_GALATAMA_SERVER_RETRY_SEC = 5

    local function tryTeleportToGalatamaServer(): boolean
        local TeleportService = game:GetService("TeleportService")
        local ok, err = pcall(function()
            TeleportService:Teleport(GALATAMA_SERVER_PLACE_ID, Players.LocalPlayer)
        end)
        if not ok then
            mountNotify({
                Title = "Galatama",
                Content = "Teleport failed: " .. tostring(err),
            })
            return false
        end
        return true
    end

    local function ensureAutoJoinGalatamaServerLoop()
        if autoJoinGalatamaServerLoopRunning then
            return
        end
        autoJoinGalatamaServerLoopRunning = true
        task.spawn(function()
            while autoJoinGalatamaServerEnabled do
                if game.PlaceId == GALATAMA_SERVER_PLACE_ID then
                    break
                end
                tryTeleportToGalatamaServer()
                if not autoJoinGalatamaServerEnabled then
                    break
                end
                task.wait(AUTO_JOIN_GALATAMA_SERVER_RETRY_SEC)
            end
            autoJoinGalatamaServerLoopRunning = false
        end)
    end

    local function fireJoinGalatamaQueue(): (boolean, string?)
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        if not remotes then
            return false, "Remotes folder not found"
        end
        local evt = remotes:FindFirstChild("JoinGalatamaQueue")
        if not (evt and evt:IsA("RemoteEvent")) then
            return false, "JoinGalatamaQueue remote not found"
        end
        local ok, err = pcall(function()
            evt:FireServer()
        end)
        if not ok then
            return false, "FireServer failed: " .. tostring(err)
        end
        return true, nil
    end

    local function isLocalPlayerInGalatamaQueue(): boolean?
        local root = getLocalPlayerRootPart()
        if not root then
            return nil
        end
        return isInsideGalatamaQueueArea(root.Position)
    end

    local function ensureAutoJoinGalatamaQueueLoop()
        if autoJoinGalatamaQueueLoopRunning then
            return
        end
        autoJoinGalatamaQueueLoopRunning = true
        task.spawn(function()
            while autoJoinGalatamaQueueEnabled do
                local inQueue = isLocalPlayerInGalatamaQueue()
                if inQueue == false then
                    local ok, err = fireJoinGalatamaQueue()
                    if not ok then
                        mountNotify({ Title = "Galatama", Content = tostring(err) })
                    end
                    task.defer(updateGalatamaQueueStatus)
                end
                task.wait(AUTO_JOIN_GALATAMA_RETRY_SEC)
            end
            autoJoinGalatamaQueueLoopRunning = false
        end)
    end

    task.defer(updateGalatamaQueueStatus)

    EventTab:CreateButton({
        Name = "Join Queue",
        Callback = function()
            local ok, err = fireJoinGalatamaQueue()
            if not ok then
                mountNotify({ Title = "Galatama", Content = tostring(err) })
            else
                task.defer(updateGalatamaQueueStatus)
            end
        end,
    })

    EventTab:CreateButton({
        Name = "Leave Queue",
        Callback = function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if not remotes then
                mountNotify({ Title = "Galatama", Content = "Remotes folder not found" })
                return
            end
            local evt = remotes:FindFirstChild("LeaveGalatamaQueue")
            if not (evt and evt:IsA("RemoteEvent")) then
                mountNotify({ Title = "Galatama", Content = "LeaveGalatamaQueue remote not found" })
                return
            end
            local ok, err = pcall(function()
                evt:FireServer()
            end)
            if not ok then
                mountNotify({ Title = "Galatama", Content = "FireServer failed: " .. tostring(err) })
            else
                task.defer(updateGalatamaQueueStatus)
            end
        end,
    })
    EventTab:CreateToggle({
        Name = "Auto Join Queue",
        Flag = "mancing_event_autoJoinGalatamaQueue",
        CurrentValue = false,
        Callback = function(enabled)
            autoJoinGalatamaQueueEnabled = enabled
            if enabled then
                ensureAutoJoinGalatamaQueueLoop()
            end
        end,
    })
    EventTab:CreateButton({
        Name = "Join Galatama Server",
        Callback = function()
            tryTeleportToGalatamaServer()
        end,
    })

    EventTab:CreateToggle({
        Name = "Auto Join Galatama Server"
            .. tostring(AUTO_JOIN_GALATAMA_SERVER_RETRY_SEC)
            .. "s until you leave this game or arrive (same place id).",
        Flag = "mancing_event_autoJoinGalatamaServer",
        CurrentValue = false,
        Callback = function(enabled)
            autoJoinGalatamaServerEnabled = enabled
            if enabled then
                ensureAutoJoinGalatamaServerLoop()
            end
        end,
    })
end

-- */  Shop Tab  /* --
do
    local ShopTab = Window:CreateTab("Shop", 4483362458)

    ShopTab:CreateSection("Buy Rod")
    -- Parallel lists: dropdown shows rodDisplayList; Buy uses rodIdList[index].
    local rodDisplayList = {}
    local rodIdList = {}
    local selectedRodId = nil
    local BuyRodDropdown
    local BuyRodDetailParagraph

    local function getRodShopScrollingFrame()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return nil
        end
        local gui = pg:FindFirstChild("FishingRodShopGui")
        if not gui then
            return nil
        end
        local canvas = gui:FindFirstChild("Canvas")
        local container = canvas and canvas:FindFirstChild("Container")
        local body = container and container:FindFirstChild("Body")
        return body and body:FindFirstChild("ScrollingFrame")
    end

    local function findRodFrame(rodId)
        if not rodId or rodId == "" then
            return nil
        end
        local scroll = getRodShopScrollingFrame()
        if not scroll then
            return nil
        end
        local f = scroll:FindFirstChild(rodId)
        if f and f:IsA("Frame") then
            return f
        end
        return nil
    end

    local function priceLabelForRodFrame(frame)
        local attr = frame:GetAttribute("PriceLabel")
        if typeof(attr) == "string" and attr ~= "" then
            return attr
        end
        local purchaseBtn = frame:FindFirstChild("PurchaseButton")
        if purchaseBtn then
            local tl = purchaseBtn:FindFirstChildOfClass("TextLabel")
            if tl and tl.Text ~= "" and tl.Text ~= "..." then
                return tl.Text
            end
            if purchaseBtn:IsA("TextButton") and purchaseBtn.Text ~= "" and purchaseBtn.Text ~= "..." then
                return purchaseBtn.Text
            end
        end
        return "?"
    end

    local function textLabelPlainText(lab)
        if lab:IsA("TextLabel") then
            local ok, ct = pcall(function()
                return lab.ContentText
            end)
            if ok and typeof(ct) == "string" and ct ~= "" then
                return ct
            end
        end
        return lab.Text
    end

    -- Avoid "TopSpeed: Top Speed: 54" or "Speed: Speed 6%"; keep "Rarity: Uncommon".
    local function formatShopStatLine(instanceName, rawText)
        if typeof(rawText) ~= "string" then
            return nil
        end
        local text = rawText:gsub("\r\n", " "):gsub("\n", " ")
        text = text:match("^%s*(.-)%s*$") or text
        if text == "" or text == "..." then
            return nil
        end
        local nm = instanceName
        if nm == "TextLabel" or nm == "Label" then
            return "  • " .. text
        end
        if text:find(":") then
            return "  • " .. text
        end
        local lowerNm = string.lower(nm)
        local lowerText = string.lower(text)
        local escaped = lowerNm:gsub("%%", "%%%%"):gsub("(%W)", "%%%1")
        if lowerText:match("^" .. escaped .. "%s+") or lowerText == escaped then
            return "  • " .. text
        end
        if nm == "Rarity" then
            return "  • Rarity: " .. text
        end
        return "  " .. nm .. ": " .. text
    end

    local function buildRodDetailText(rodId)
        if not rodId or rodId == "" then
            return "Select a rod from the dropdown to see name, price, and statistics."
        end
        local frame = findRodFrame(rodId)
        if not frame then
            return "Rod row \"" .. rodId .. "\" was not found. Use Refresh or open the in-game rod shop."
        end
        local price = priceLabelForRodFrame(frame)
        local lines = {}
        table.insert(lines, "Rod name: " .. rodId)
        table.insert(lines, "Price: " .. price)
        table.insert(lines, "")

        local purchaseBtn = frame:FindFirstChild("PurchaseButton")

        local function appendAttributes(inst, prefix)
            local attrs = {}
            pcall(function()
                attrs = inst:GetAttributes()
            end)
            local keys = {}
            for k in pairs(attrs) do
                table.insert(keys, k)
            end
            table.sort(keys)
            local out = {}
            for _, k in ipairs(keys) do
                table.insert(out, { key = prefix .. k, val = tostring(attrs[k]) })
            end
            return out
        end

        local attrRows = {}
        for _, row in ipairs(appendAttributes(frame, "")) do
            table.insert(attrRows, row)
        end
        if purchaseBtn then
            for _, row in ipairs(appendAttributes(purchaseBtn, "purchase.")) do
                table.insert(attrRows, row)
            end
        end
        if #attrRows > 0 then
            table.insert(lines, "Attributes:")
            for _, row in ipairs(attrRows) do
                table.insert(lines, "  " .. row.key .. ": " .. row.val)
            end
            table.insert(lines, "")
        end

        local seenLabel = {}
        local statLines = {}
        for _, desc in ipairs(frame:GetDescendants()) do
            if desc:IsA("TextLabel") then
                if purchaseBtn and desc:IsDescendantOf(purchaseBtn) then
                    continue
                end
                local nm = desc.Name
                if nm == "FishingRodName" then
                    continue
                end
                local t = textLabelPlainText(desc)
                local line = formatShopStatLine(nm, t)
                if not line then
                    continue
                end
                local key = nm .. "\0" .. line
                if seenLabel[key] then
                    continue
                end
                seenLabel[key] = true
                table.insert(statLines, line)
            end
        end
        if #statLines > 0 then
            table.insert(lines, "Statistics:")
            for _, L in ipairs(statLines) do
                table.insert(lines, L)
            end
        elseif #attrRows == 0 then
            table.insert(lines, "No stat labels or extra attributes on this row.")
        end

        return table.concat(lines, "\n")
    end

    local function updateBuyRodDetailParagraph()
        if BuyRodDetailParagraph and BuyRodDetailParagraph.Set then
            BuyRodDetailParagraph:Set({
                Content = buildRodDetailText(selectedRodId),
            })
        end
    end

    local function getRodRowsFromShopGui()
        local scroll = getRodShopScrollingFrame()
        if not scroll then
            return {}
        end
        local rows = {}
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") then
                local id = child.Name
                local price = priceLabelForRodFrame(child)
                table.insert(rows, {
                    id = id,
                    display = id .. " (" .. price .. ")",
                })
            end
        end
        table.sort(rows, function(a, b)
            return a.id < b.id
        end)
        return rows
    end

    local function refreshRodList(showNotify)
        local rows = getRodRowsFromShopGui()
        rodDisplayList = {}
        rodIdList = {}
        for _, r in ipairs(rows) do
            table.insert(rodDisplayList, r.display)
            table.insert(rodIdList, r.id)
        end
        if BuyRodDropdown and BuyRodDropdown.Refresh then
            BuyRodDropdown:Refresh(rodDisplayList)
        end
        if selectedRodId and not table.find(rodIdList, selectedRodId) then
            selectedRodId = nil
            if BuyRodDropdown and BuyRodDropdown.Select then
                BuyRodDropdown:Select(nil)
            end
            if BuyRodDropdown and BuyRodDropdown.Set then
                BuyRodDropdown:Set({})
            end
        end
        updateBuyRodDetailParagraph()
        if showNotify then
            mountNotify({
                Title = "Buy Rod",
                Content = (#rodIdList == 0) and "No rods found (open the in-game rod shop once or wait for UI to load)" or ("Found " .. #rodIdList .. " rod(s)"),
                Icon = (#rodIdList == 0) and "x" or "check",
            })
        end
    end

    BuyRodDropdown = ShopTab:CreateDropdown({
        Name = "Rod",
        Flag = "mancing_shop_rodPick",
        Options = rodDisplayList,
        CurrentOption = {}, Search = true,
        Callback = function(value)
            selectedRodId = nil
            if value then
                local idx = table.find(rodDisplayList, value)
                if idx and rodIdList[idx] then
                    selectedRodId = rodIdList[idx]
                end
            end
            updateBuyRodDetailParagraph()
        end,
    })

    BuyRodDetailParagraph = ShopTab:CreateParagraph({
        Title = "Rod details",
        Content = "Select a rod from the dropdown to see name, price, and statistics.",
    })

    ShopTab:CreateButton({
        Name = "Buy",
        Callback = function()
            if not selectedRodId or selectedRodId == "" then
                mountNotify({ Title = "Buy Rod", Content = "Select a rod from the dropdown first" })
                return
            end
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local purchaseRod = remotes and remotes:FindFirstChild("PurchaseRod")
            if not (purchaseRod and purchaseRod:IsA("RemoteFunction")) then
                mountNotify({ Title = "Buy Rod", Content = "Remotes.PurchaseRod not found" })
                return
            end
            local ok, result = pcall(function()
                return purchaseRod:InvokeServer(selectedRodId)
            end)
            if not ok then
                mountNotify({ Title = "Buy Rod", Content = "Invoke failed: " .. tostring(result) })
                return
            end
            if result and result.IsGamepass and result.GamepassId then
                pcall(function()
                    MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, result.GamepassId)
                end)
                mountNotify({ Title = "Buy Rod", Content = "Game pass purchase prompted" })
            elseif result and result.Success then
                mountNotify({ Title = "Buy Rod", Content = "Purchase successful" })
            else
                mountNotify({
                    Title = "Buy Rod",
                    Content = (result and result.Message) or "Purchase failed",
                })
            end
            task.defer(updateBuyRodDetailParagraph)
        end,
    })
    ShopTab:CreateButton({
        Name = "Refresh rod list",
        Callback = function()
            refreshRodList(true)
        end,
    })
    ShopTab:CreateSection("Buy Boat")
    local boatDisplayList = {}
    local boatIdList = {}
    local selectedBoatId = nil
    local BuyBoatDropdown
    local BuyBoatDetailParagraph

    local function getBoatShopBody()
        local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
        if not pg then
            return nil
        end
        local gui = pg:FindFirstChild("BoatUI")
        if not gui then
            return nil
        end
        local canvas = gui:FindFirstChild("Canvas")
        local container = canvas and canvas:FindFirstChild("Container")
        return container and container:FindFirstChild("Body")
    end

    local function getBoatShopScrollingFrame()
        local body = getBoatShopBody()
        return body and body:FindFirstChild("ScrollingFrame")
    end

    local function findBoatRow(boatId)
        if not boatId or boatId == "" then
            return nil
        end
        local scroll = getBoatShopScrollingFrame()
        if not scroll then
            return nil
        end
        local row = scroll:FindFirstChild(boatId)
        if row and (row:IsA("Frame") or row:IsA("TextButton")) then
            return row
        end
        return nil
    end

    local function boatDisplayNameForRow(row)
        local nm = row:FindFirstChild("BoatName")
        if nm and nm:IsA("TextLabel") and nm.Text ~= "" then
            return nm.Text
        end
        return row.Name
    end

    local function priceLabelForBoatRow(row)
        local price = row:FindFirstChild("Price")
        if price and price:IsA("TextLabel") and price.Text ~= "" and price.Text ~= "..." then
            return price.Text
        end
        return "?"
    end

    local function buildBoatDetailText(boatId)
        if not boatId or boatId == "" then
            return "Select a boat from the dropdown to see name, price, and statistics."
        end
        local row = findBoatRow(boatId)
        if not row then
            return "Boat row \"" .. boatId .. "\" was not found. Use Refresh or open the in-game boat shop."
        end
        local displayName = boatDisplayNameForRow(row)
        local price = priceLabelForBoatRow(row)
        local lines = {}
        table.insert(lines, "Display name: " .. displayName)
        table.insert(lines, "Boat id: " .. boatId)
        table.insert(lines, "Price: " .. price)
        table.insert(lines, "")

        local body = getBoatShopBody()
        local infoFrame = body and body:FindFirstChild(boatId .. "_Information")
        local purchaseBtn = infoFrame and (infoFrame:FindFirstChild("PurchaseButton") or infoFrame:FindFirstChild("ActionButton"))

        local statNames = { "Rarity", "Passengers", "TopSpeed", "Acceleration", "Handling" }
        local namedStats = {}
        for _, statName in ipairs(statNames) do
            local lab = row:FindFirstChild(statName)
            if not (lab and lab:IsA("TextLabel")) then
                lab = row:FindFirstChild(statName, true)
            end
            if not (lab and lab:IsA("TextLabel")) and infoFrame then
                lab = infoFrame:FindFirstChild(statName)
                if not (lab and lab:IsA("TextLabel")) then
                    lab = infoFrame:FindFirstChild(statName, true)
                end
            end
            if lab and lab:IsA("TextLabel") then
                local t = textLabelPlainText(lab)
                local line = formatShopStatLine(statName, t)
                if line then
                    table.insert(namedStats, line)
                end
            end
        end
        if #namedStats > 0 then
            table.insert(lines, "Statistics:")
            for _, L in ipairs(namedStats) do
                table.insert(lines, L)
            end
            table.insert(lines, "")
        end

        local function appendAttributes(inst, prefix)
            local attrs = {}
            pcall(function()
                attrs = inst:GetAttributes()
            end)
            local keys = {}
            for k in pairs(attrs) do
                table.insert(keys, k)
            end
            table.sort(keys)
            local out = {}
            for _, k in ipairs(keys) do
                table.insert(out, { key = prefix .. k, val = tostring(attrs[k]) })
            end
            return out
        end

        local attrRows = {}
        for _, ar in ipairs(appendAttributes(row, "row.")) do
            table.insert(attrRows, ar)
        end
        if infoFrame then
            for _, ar in ipairs(appendAttributes(infoFrame, "info.")) do
                table.insert(attrRows, ar)
            end
        end
        if purchaseBtn then
            for _, ar in ipairs(appendAttributes(purchaseBtn, "purchase.")) do
                table.insert(attrRows, ar)
            end
        end
        if #attrRows > 0 then
            table.insert(lines, "Attributes:")
            for _, ar in ipairs(attrRows) do
                table.insert(lines, "  " .. ar.key .. ": " .. ar.val)
            end
            table.insert(lines, "")
        end

        if #namedStats == 0 and #attrRows == 0 then
            table.insert(lines, "No statistics or attributes on this boat.")
        end

        return table.concat(lines, "\n")
    end

    local function updateBuyBoatDetailParagraph()
        if BuyBoatDetailParagraph and BuyBoatDetailParagraph.Set then
            local ok, detail = pcall(function()
                return buildBoatDetailText(selectedBoatId)
            end)
            if not ok then
                detail = "Failed to build boat details: " .. tostring(detail)
            end
            BuyBoatDetailParagraph:Set({
                Title = "Boat details",
                Content = detail,
            })
        end
    end

    local function getBoatRowsFromShopGui()
        local scroll = getBoatShopScrollingFrame()
        if not scroll then
            return {}
        end
        local rows = {}
        for _, child in ipairs(scroll:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                local id = child.Name
                if not id:match("_Information$") then
                    local disp = boatDisplayNameForRow(child)
                    local price = priceLabelForBoatRow(child)
                    table.insert(rows, {
                        id = id,
                        display = disp .. " — " .. id .. " (" .. price .. ")",
                    })
                end
            end
        end
        table.sort(rows, function(a, b)
            return a.id < b.id
        end)
        return rows
    end

    local function refreshBoatList(showNotify)
        local rows = getBoatRowsFromShopGui()
        boatDisplayList = {}
        boatIdList = {}
        for _, r in ipairs(rows) do
            table.insert(boatDisplayList, r.display)
            table.insert(boatIdList, r.id)
        end
        if BuyBoatDropdown and BuyBoatDropdown.Refresh then
            BuyBoatDropdown:Refresh(boatDisplayList)
        end
        if selectedBoatId and not table.find(boatIdList, selectedBoatId) then
            selectedBoatId = nil
            if BuyBoatDropdown and BuyBoatDropdown.Select then
                BuyBoatDropdown:Select(nil)
            end
            if BuyBoatDropdown and BuyBoatDropdown.Set then
                BuyBoatDropdown:Set({})
            end
        end
        updateBuyBoatDetailParagraph()
        if showNotify then
            mountNotify({
                Title = "Buy Boat",
                Content = (#boatIdList == 0) and "No boats found (open the in-game boat shop once or wait for UI to load)" or ("Found " .. #boatIdList .. " boat(s)"),
                Icon = (#boatIdList == 0) and "x" or "check",
            })
        end
    end

    BuyBoatDropdown = ShopTab:CreateDropdown({
        Name = "Boat",
        Flag = "mancing_shop_boatPick",
        Options = boatDisplayList,
        CurrentOption = {}, Search = true,
        Callback = function(value)
            local selected = rayfieldDropdownFirst(value)
            selectedBoatId = nil
            if selected then
                local idx = table.find(boatDisplayList, selected)
                if idx and boatIdList[idx] then
                    selectedBoatId = boatIdList[idx]
                end
            end
            updateBuyBoatDetailParagraph()
        end,
    })

    BuyBoatDetailParagraph = ShopTab:CreateParagraph({
        Title = "Boat details",
        Content = "Select a boat from the dropdown to see name, price, and statistics.",
    })

    ShopTab:CreateButton({
        Name = "Buy",
        Callback = function()
            if not selectedBoatId or selectedBoatId == "" then
                mountNotify({ Title = "Buy Boat", Content = "Select a boat from the dropdown first" })
                return
            end
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local purchaseBoat = remotes and remotes:FindFirstChild("PurchaseBoat")
            if not (purchaseBoat and purchaseBoat:IsA("RemoteFunction")) then
                mountNotify({ Title = "Buy Boat", Content = "Remotes.PurchaseBoat not found" })
                return
            end
            local ok, result = pcall(function()
                return purchaseBoat:InvokeServer(selectedBoatId)
            end)
            if not ok then
                mountNotify({ Title = "Buy Boat", Content = "Invoke failed: " .. tostring(result) })
                return
            end
            if result and result.IsGamepass and result.GamepassId then
                pcall(function()
                    MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, result.GamepassId)
                end)
                mountNotify({ Title = "Buy Boat", Content = "Game pass purchase prompted" })
            elseif result and result.Success then
                mountNotify({ Title = "Buy Boat", Content = "Purchase successful" })
            else
                mountNotify({
                    Title = "Buy Boat",
                    Content = (result and result.Message) or "Purchase failed",
                })
            end
            task.defer(updateBuyBoatDetailParagraph)
        end,
    })
    ShopTab:CreateButton({
        Name = "Refresh boat list",
        Callback = function()
            refreshBoatList(true)
        end,
    })

    local okRod = pcall(function()
        refreshRodList(false)
    end)
    local okBoat, errBoat = pcall(function()
        refreshBoatList(false)
    end)
    if not okRod then
        mountNotify({ Title = "Buy Rod", Content = "Failed to initialize rod list", Icon = "x" })
    end
    if not okBoat then
        mountNotify({ Title = "Buy Boat", Content = "Failed to initialize boat list: " .. tostring(errBoat), Icon = "x" })
    end
end

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "mancing" })
-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, {
    replicatedStorage = ReplicatedStorage,
    nestClassesFlag = "mancing_objects_showChildrenTypes",
})

createRecordingTab(Window, mountNotify, "sempatpanick/mancing_indo/recordings")


-- */  Config Tab  /* --
do
    local ConfigTab = Window:CreateTab("Config", 4483362458)

    ConfigTab:CreateSection("Config management")
    local CONFIG_DIR = "sempatpanick/mancing_indo"
    local configMgmtName = ""
    local savedConfigList = {}
    local selectedSavedConfigName = nil
    local SavedConfigsDropdown
    local ConfigNameInput
    local autoLoadPickerSelection = nil
    local AutoLoadSavedDropdown
    local CONFIG_SEQ_FLAG_AUTO_SELL = "mancing_main_autoSell"
    local CONFIG_SEQ_FLAG_TELEPORT = "mancing_main_teleportToLocation"
    local CONFIG_SEQ_FLAG_LIMITED = "mancing_event_limitedAutoTeleport"

    local function sanitizeConfigName(raw)
        local s = tostring(raw or ""):gsub("^%s+", ""):gsub("%s+$", "")
        s = s:gsub("[/\\]", "")
        return s
    end

    local function ensureConfigFolder()
        if type(makefolder) == "function" and type(isfolder) == "function" and not isfolder(CONFIG_DIR) then
            pcall(function()
                makefolder("sempatpanick")
            end)
            pcall(function()
                makefolder(CONFIG_DIR)
            end)
        end
    end

    local function profilePath(name)
        return CONFIG_DIR .. "/" .. sanitizeConfigName(name) .. ".json"
    end

    local function encodeColor3(c)
        return {
            __type = "Color3",
            R = math.floor(c.R * 255 + 0.5),
            G = math.floor(c.G * 255 + 0.5),
            B = math.floor(c.B * 255 + 0.5),
        }
    end

    local function decodeColor3(v)
        if type(v) == "table" and v.__type == "Color3" then
            return Color3.fromRGB(tonumber(v.R) or 255, tonumber(v.G) or 255, tonumber(v.B) or 255)
        end
        return nil
    end

    local function collectCurrentConfigData()
        local data = {}
        for flagName, flagObj in pairs(RayfieldLibrary.Flags or {}) do
            local value
            if flagObj.Type == "ColorPicker" and flagObj.Color then
                value = encodeColor3(flagObj.Color)
            else
                value = flagObj.CurrentValue
                if value == nil then value = flagObj.CurrentKeybind end
                if value == nil then value = flagObj.CurrentOption end
                if value == nil then value = flagObj.Color end
                if typeof(value) == "Color3" then
                    value = encodeColor3(value)
                end
            end
            data[flagName] = value
        end
        return data
    end

    local function applyConfigData(data)
        if type(data) ~= "table" then
            return false
        end
        local seqOrder = {
            "mancing_main_autoSell",
            "mancing_main_teleportToLocation",
            "mancing_event_limitedAutoTeleport",
        }
        local seqSet = {}
        for _, f in ipairs(seqOrder) do
            seqSet[f] = true
        end

        local function applyFlag(flagName)
            local flagObj = RayfieldLibrary.Flags and RayfieldLibrary.Flags[flagName]
            if not flagObj or type(flagObj.Set) ~= "function" then
                return
            end
            local saved = data[flagName]
            if saved == nil then
                return
            end
            local c = decodeColor3(saved)
            pcall(function()
                flagObj:Set(c or saved)
            end)
        end

        for flagName, _ in pairs(data) do
            if not seqSet[flagName] then
                applyFlag(flagName)
            end
        end
        for _, flagName in ipairs(seqOrder) do
            applyFlag(flagName)
        end
        return true
    end

    local function listProfiles()
        local names = {}
        if type(listfiles) ~= "function" then
            return names
        end
        ensureConfigFolder()
        local ok, files = pcall(function()
            return listfiles(CONFIG_DIR)
        end)
        if not ok or type(files) ~= "table" then
            return names
        end
        for _, filePath in ipairs(files) do
            local normalized = tostring(filePath):gsub("\\", "/")
            local base = normalized:match("([^/]+)$")
            if base and base:sub(-5) == ".json" and base ~= "mancing_indo_autoload.json" then
                table.insert(names, base:sub(1, -6))
            end
        end
        table.sort(names)
        return names
    end

    local function createConfigObject(name)
        local trimmed = sanitizeConfigName(name)
        return {
            Save = function()
                ensureConfigFolder()
                if type(writefile) ~= "function" then
                    error("writefile is not available")
                end
                writefile(profilePath(trimmed), HttpService:JSONEncode(collectCurrentConfigData()))
            end,
            Load = function()
                if type(isfile) ~= "function" or type(readfile) ~= "function" then
                    return false, "Config system unavailable (missing file APIs)"
                end
                local path = profilePath(trimmed)
                if not isfile(path) then
                    return false, "Config file not found or invalid"
                end
                local okRead, rawOrErr = pcall(function()
                    return readfile(path)
                end)
                if not okRead then
                    return false, tostring(rawOrErr)
                end
                local okDecode, decoded = pcall(function()
                    return HttpService:JSONDecode(rawOrErr)
                end)
                if not okDecode then
                    return false, "Config file not found or invalid"
                end
                applyConfigData(decoded)
                return true
            end,
        }
    end

    local function getConfigManager()
        if type(writefile) ~= "function" and type(readfile) ~= "function" then
            return nil
        end
        ensureConfigFolder()
        return {
            Path = CONFIG_DIR .. "/",
            AllConfigs = function()
                return listProfiles()
            end,
            GetConfig = function(_, _)
                return nil
            end,
            Config = function(_, name, _)
                return createConfigObject(name)
            end,
            DeleteConfig = function(_, name)
                if type(delfile) ~= "function" or type(isfile) ~= "function" then
                    return false, "Delete is unavailable (missing file APIs)"
                end
                local path = profilePath(name)
                if not isfile(path) then
                    return false, "Config file not found"
                end
                local ok, err = pcall(function()
                    delfile(path)
                end)
                if not ok then
                    return false, tostring(err)
                end
                return true, "Deleted \"" .. sanitizeConfigName(name) .. "\""
            end,
        }
    end

    local function autoLoadMetaPath(cm)
        return (cm.Path or "") .. "mancing_indo_autoload.json"
    end

    local function readAutoLoadPersistedName()
        local cm = getConfigManager()
        if not cm or type(isfile) ~= "function" or type(readfile) ~= "function" then
            return ""
        end
        local path = autoLoadMetaPath(cm)
        if not isfile(path) then
            return ""
        end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if ok and type(data) == "table" then
            return sanitizeConfigName(tostring(data.name or data.profile or ""))
        end
        return ""
    end

    local function writeAutoLoadPersistedName(name)
        local cm = getConfigManager()
        if not cm or type(writefile) ~= "function" then
            return false
        end
        local path = autoLoadMetaPath(cm)
        local trimmed = sanitizeConfigName(name)
        if trimmed == "" then
            if type(delfile) == "function" and type(isfile) == "function" and isfile(path) then
                pcall(function()
                    delfile(path)
                end)
            end
            return true
        end
        local ok = pcall(function()
            writefile(path, HttpService:JSONEncode({ name = trimmed }))
        end)
        return ok
    end

    local function refreshSavedConfigDropdowns(showNotify)
        local cm = getConfigManager()
        if not cm then
            if showNotify then
                mountNotify({
                    Title = "Config",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                })
            end
            return
        end
        savedConfigList = cm:AllConfigs() or {}
        table.sort(savedConfigList)
        if SavedConfigsDropdown and SavedConfigsDropdown.Refresh then
            SavedConfigsDropdown:Refresh(savedConfigList)
        end
        if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Refresh then
            AutoLoadSavedDropdown:Refresh(savedConfigList)
        end
        if autoLoadPickerSelection and not table.find(savedConfigList, autoLoadPickerSelection) then
            autoLoadPickerSelection = nil
            if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Select then
                AutoLoadSavedDropdown:Select(nil)
            end
            if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Set then
                AutoLoadSavedDropdown:Set({})
            end
        end
        if selectedSavedConfigName and not table.find(savedConfigList, selectedSavedConfigName) then
            selectedSavedConfigName = nil
            if SavedConfigsDropdown and SavedConfigsDropdown.Select then
                SavedConfigsDropdown:Select(nil)
            end
            if SavedConfigsDropdown and SavedConfigsDropdown.Set then
                SavedConfigsDropdown:Set({})
            end
        end
        if showNotify then
            mountNotify({
                Title = "Config",
                Content = "Found " .. tostring(#savedConfigList) .. " saved profile(s).",
            })
        end
    end

    ConfigNameInput = ConfigTab:CreateInput({
        Name = "Config name",
        PlaceholderText = "e.g. main or pvp",
        CurrentValue = configMgmtName,
        Callback = function(value)
            configMgmtName = sanitizeConfigName(value)
        end,
    })

    SavedConfigsDropdown = ConfigTab:CreateDropdown({
        Name = "Config Saved",
        Options = savedConfigList,
        CurrentOption = {}, Search = true,
        Callback = function(opts)
            local value = rayfieldDropdownFirst(opts)
            selectedSavedConfigName = (value and value ~= "") and value or nil
            if value and value ~= "" then
                configMgmtName = sanitizeConfigName(value)
                if ConfigNameInput and ConfigNameInput.Set then
                    ConfigNameInput:Set(configMgmtName)
                elseif ConfigNameInput and ConfigNameInput.SetValue then
                    ConfigNameInput:SetValue(configMgmtName)
                end
            end
        end,
    })

    -- WindUI Init may store raw JSON in Configs[name]; only reuse a real config object so Save
    -- does not call CreateConfig again (that would replace the profile and drop element bindings).
    local function isWindUIConfigObject(v)
        return type(v) == "table" and type(v.Save) == "function" and type(v.Load) == "function"
    end

    local function getConfigObject(cm, name)
        local existing = cm:GetConfig(name)
        if isWindUIConfigObject(existing) then
            return existing
        end
        return cm:Config(name, false)
    end

    -- WindUI cfg:Load() spawns each element load in arbitrary order. After it settles, re-apply in order:
    -- (1) Auto Sell toggle + one coordinated sell trip if on, then background sell loop;
    -- (2) Teleport to Location;
    -- (3) Limited Event Auto Teleport.
    local function readProfileElementsTable(cm, profileName)
        local trimmed = sanitizeConfigName(profileName)
        if trimmed == "" or type(isfile) ~= "function" or type(readfile) ~= "function" then
            return nil
        end
        local path = cm.Path .. trimmed .. ".json"
        if not isfile(path) then
            return nil
        end
        local ok, data = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)
        if not ok or type(data) ~= "table" then
            return nil
        end
        if not data.__version then
            data = { __elements = data, __custom = {} }
        end
        return data.__elements
    end

    local function getSavedElement(elements, flag)
        if type(elements) ~= "table" then
            return nil
        end
        local s = elements[flag]
        if s == nil then
            s = elements[tostring(flag)]
        end
        return s
    end

    local function applyConfigLoadSequentialSellTeleportLimited(cm, cfg, profileName)
        if not cm or not cfg or not cm.Parser then
            return
        end
        local elements = readProfileElementsTable(cm, profileName)
        if type(elements) ~= "table" then
            return
        end
        local parser = cm.Parser
        local br = configLoadBridge

        if type(br.bumpAutoSellLoopToken) == "function" then
            br.bumpAutoSellLoopToken()
        end

        local sellSaved = getSavedElement(elements, CONFIG_SEQ_FLAG_AUTO_SELL)
        local telSaved = getSavedElement(elements, CONFIG_SEQ_FLAG_TELEPORT)
        local limSaved = getSavedElement(elements, CONFIG_SEQ_FLAG_LIMITED)

        local sellElem = cfg.Elements and cfg.Elements[CONFIG_SEQ_FLAG_AUTO_SELL]
        if sellElem and type(sellSaved) == "table" and sellSaved.__type and parser[sellSaved.__type] and parser[sellSaved.__type].Load then
            local wantSell = sellSaved.value == true
            if wantSell then
                br.suppressNextAutoSellLoopSpawn = true
            end
            local pok, err = pcall(function()
                parser[sellSaved.__type].Load(sellElem, sellSaved)
            end)
            br.suppressNextAutoSellLoopSpawn = false
            if not pok then
                warn("[Mancing Indo] Config sequential load (Auto Sell): " .. tostring(err))
            elseif wantSell then
                if type(br.runAutoSellWithFishingCoordination) == "function" then
                    pcall(br.runAutoSellWithFishingCoordination)
                end
                if type(br.startAutoSellSellLoop) == "function" then
                    br.startAutoSellSellLoop(true)
                end
            end
        end

        local telElem = cfg.Elements and cfg.Elements[CONFIG_SEQ_FLAG_TELEPORT]
        if telElem and type(telSaved) == "table" and telSaved.__type and parser[telSaved.__type] and parser[telSaved.__type].Load then
            local pok, err = pcall(function()
                parser[telSaved.__type].Load(telElem, telSaved)
            end)
            if not pok then
                warn("[Mancing Indo] Config sequential load (Teleport): " .. tostring(err))
            end
        end

        local limElem = cfg.Elements and cfg.Elements[CONFIG_SEQ_FLAG_LIMITED]
        if limElem and type(limSaved) == "table" and limSaved.__type and parser[limSaved.__type] and parser[limSaved.__type].Load then
            local pok, err = pcall(function()
                parser[limSaved.__type].Load(limElem, limSaved)
            end)
            if not pok then
                warn("[Mancing Indo] Config sequential load (Limited Event): " .. tostring(err))
            end
        end
    end

    local function scheduleSequentialConfigLoadAfterProfile(cm, cfg, profileName)
        task.defer(function()
            for _ = 1, 2 do
                RunService.Heartbeat:Wait()
            end
            applyConfigLoadSequentialSellTeleportLimited(cm, cfg, profileName)
        end)
    end

    local function syncPersistedAutoLoadToUi()
        if not AutoLoadSavedDropdown then
            return
        end
        local persisted = readAutoLoadPersistedName()
        if persisted == "" or not table.find(savedConfigList, persisted) then
            return
        end
        autoLoadPickerSelection = persisted
        if AutoLoadSavedDropdown.Set then
            AutoLoadSavedDropdown:Set({ persisted })
        elseif AutoLoadSavedDropdown.Select then
            AutoLoadSavedDropdown:Select(persisted)
        end
    end

    local function runStartupAutoLoadProfile()
        local cm = getConfigManager()
        if not cm or type(isfile) ~= "function" then
            return
        end
        local name = readAutoLoadPersistedName()
        if name == "" then
            return
        end
        if not isfile(cm.Path .. name .. ".json") then
            return
        end
        local cfg = getConfigObject(cm, name)
        if Window.SetCurrentConfig then
            Window:SetCurrentConfig(cfg)
        end
        local pok, loadResult, loadErr = pcall(function()
            return cfg:Load()
        end)
        if not pok then
            warn("[Mancing Indo] Auto-load failed: ", loadResult)
            return
        end
        if loadResult == false then
            warn("[Mancing Indo] Auto-load: ", loadErr)
            return
        end
        scheduleSequentialConfigLoadAfterProfile(cm, cfg, name)
        mountNotify({
            Title = "Config",
            Content = "Auto-loaded \"" .. name .. "\"",
        })
    end
    ConfigTab:CreateButton({
        Name = "Refresh Config",
        Callback = function()
            refreshSavedConfigDropdowns(true)
        end,
    })
    ConfigTab:CreateButton({
        Name = "Save Config",
        Callback = function()
            local cm = getConfigManager()
            if not cm then
                mountNotify({
                    Title = "Config",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                })
                return
            end
            local name = sanitizeConfigName(configMgmtName)
            if name == "" then
                mountNotify({ Title = "Config", Content = "Enter a config name first" })
                return
            end
            local cfg = getConfigObject(cm, name)
            if Window.SetCurrentConfig then
                Window:SetCurrentConfig(cfg)
            end
            local cfgPath = cm.Path .. name .. ".json"
            if type(isfile) == "function" and isfile(cfgPath) and type(delfile) == "function" then
                pcall(function()
                    delfile(cfgPath)
                end)
            end
            local ok, err = pcall(function()
                cfg:Save()
            end)
            if not ok then
                mountNotify({ Title = "Config", Content = "Save failed: " .. tostring(err) })
                return
            end
            refreshSavedConfigDropdowns(false)
            mountNotify({ Title = "Config", Content = "Saved \"" .. name .. "\"" })
        end,
    })

    ConfigTab:CreateButton({
        Name = "Load Config",
        Callback = function()
            local cm = getConfigManager()
            if not cm then
                mountNotify({
                    Title = "Config",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                })
                return
            end
            local name = sanitizeConfigName(configMgmtName)
            if name == "" then
                mountNotify({ Title = "Config", Content = "Enter or select a config name first" })
                return
            end
            local cfg = getConfigObject(cm, name)
            if Window.SetCurrentConfig then
                Window:SetCurrentConfig(cfg)
            end
            local pok, loadResult, loadErr = pcall(function()
                return cfg:Load()
            end)
            if not pok then
                mountNotify({ Title = "Config", Content = "Load failed: " .. tostring(loadResult) })
                return
            end
            if loadResult == false then
                mountNotify({
                    Title = "Config",
                    Content = type(loadErr) == "string" and loadErr or "Config file not found or invalid",
                })
                return
            end
            scheduleSequentialConfigLoadAfterProfile(cm, cfg, name)
            mountNotify({ Title = "Config", Content = "Loaded \"" .. name .. "\"" })
        end,
    })
    ConfigTab:CreateButton({
        Name = "Delete Config",
        Callback = function()
            local cm = getConfigManager()
            if not cm then
                mountNotify({
                    Title = "Config",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                })
                return
            end
            if not selectedSavedConfigName or selectedSavedConfigName == "" then
                mountNotify({
                    Title = "Config",
                    Content = "Select a config to delete",
                })
                return
            end
            local name = sanitizeConfigName(selectedSavedConfigName)
            if name == "" then
                mountNotify({
                    Title = "Config",
                    Content = "Select a config to delete",
                })
                return
            end
            local okDel, msg = cm:DeleteConfig(name)
            refreshSavedConfigDropdowns(false)
            if okDel then
                if readAutoLoadPersistedName() == name then
                    writeAutoLoadPersistedName("")
                    autoLoadPickerSelection = nil
                    if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Select then
                        AutoLoadSavedDropdown:Select(nil)
                    end
                    if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Set then
                        AutoLoadSavedDropdown:Set({})
                    end
                end
                selectedSavedConfigName = nil
                if SavedConfigsDropdown and SavedConfigsDropdown.Select then
                    SavedConfigsDropdown:Select(nil)
                end
                if SavedConfigsDropdown and SavedConfigsDropdown.Set then
                    SavedConfigsDropdown:Set({})
                end
                if sanitizeConfigName(configMgmtName) == name then
                    configMgmtName = ""
                    if ConfigNameInput and ConfigNameInput.Set then
                        ConfigNameInput:Set("")
                    elseif ConfigNameInput and ConfigNameInput.SetValue then
                        ConfigNameInput:SetValue("")
                    end
                end
                mountNotify({
                    Title = "Config",
                    Content = type(msg) == "string" and msg or ("Deleted \"" .. name .. "\""),
                })
            else
                mountNotify({
                    Title = "Config",
                    Content = type(msg) == "string" and msg or "Delete failed",
                })
            end
        end,
    })
    ConfigTab:CreateSection("Auto Load")
    AutoLoadSavedDropdown = ConfigTab:CreateDropdown({
        Name = "Config Saved",
        Options = savedConfigList,
        CurrentOption = {}, Search = true,
        Callback = function(opts)
            local value = rayfieldDropdownFirst(opts)
            autoLoadPickerSelection = (value and value ~= "") and value or nil
        end,
    })
    ConfigTab:CreateButton({
        Name = "Set",
        Callback = function()
            if not autoLoadPickerSelection or autoLoadPickerSelection == "" then
                mountNotify({
                    Title = "Auto Load",
                    Content = "Select a config in Config Saved first",
                })
                return
            end
            local cm = getConfigManager()
            if not cm then
                mountNotify({
                    Title = "Auto Load",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                })
                return
            end
            local pick = sanitizeConfigName(autoLoadPickerSelection)
            if pick == "" or not table.find(savedConfigList, pick) then
                mountNotify({
                    Title = "Auto Load",
                    Content = "Selected profile is not in the list (try Refresh Config)",
                })
                return
            end
            if not isfile or not isfile(cm.Path .. pick .. ".json") then
                mountNotify({
                    Title = "Auto Load",
                    Content = "That config file is not on disk yet (Save Config first)",
                })
                return
            end
            if not writeAutoLoadPersistedName(pick) then
                mountNotify({ Title = "Auto Load", Content = "Failed to write autoload file" })
                return
            end
            mountNotify({
                Title = "Auto Load",
                Content = "Next run will load \"" .. pick .. "\"",
            })
        end,
    })
    ConfigTab:CreateButton({
        Name = "Reset",
        Callback = function()
            writeAutoLoadPersistedName("")
            autoLoadPickerSelection = nil
            if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Select then
                AutoLoadSavedDropdown:Select(nil)
            end
            if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Set then
                AutoLoadSavedDropdown:Set({})
            end
            mountNotify({
                Title = "Auto Load",
                Content = "Auto-load on startup disabled",
            })
        end,
    })

    refreshSavedConfigDropdowns(false)
    syncPersistedAutoLoadToUi()

    task.defer(function()
        task.wait(0.45)
        runStartupAutoLoadProfile()
    end)
end
