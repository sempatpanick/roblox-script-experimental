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

local WindUI

do
    local ok, result = pcall(function()
        return require("./src/Init")
    end)
    
    if ok then
        WindUI = result
    else 
        if cloneref(RunService):IsStudio() then
            WindUI = require(cloneref(ReplicatedStorage:WaitForChild("WindUI"):WaitForChild("Init")))
        else
            WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
        end
    end
end

-- */  Window  /* --
local Window = WindUI:CreateWindow({
    Title = "sempatpanick | Mancing Indo",
    Folder = "sempatpanick_mancing_indo",
    Icon = "solar:folder-2-bold-duotone",
    NewElements = true,
    HideSearchBar = false,
    OpenButton = {
        Title = "Open SempatPanick UI",
        CornerRadius = UDim.new(1,0),
        StrokeThickness = 3,
        Enabled = true,
        Draggable = true,
        OnlyMobile = false,
        Scale = 0.5,
        Color = ColorSequence.new(
            Color3.fromHex("#30FF6A"), 
            Color3.fromHex("#e7ff2f")
        )
    },
    Topbar = {
        Height = 44,
        ButtonsType = "Mac",
    },
})

-- */  Colors  /* --
local Green = Color3.fromHex("#10C550")
-- Shared across tabs so Backpack features can validate fishing automation state.
local fishingAutomationState = {
    instantFishingEnabled = false,
}

-- Limited Event (Event tab) ↔ Main: location pin vs Auto Sell priority.
local limitedEventState = {
    pausedForAutoSell = false,
    blocksLocationHold = false,
    -- When frozen at the limited-event spot, Auto Sell tweens back here (5s) then refreezes; cleared when the LE session ends.
    returnFromSellTweenCf = nil :: CFrame?,
}
local limitedEventBridge: {
    stopLocationHold: (() -> ())?,
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

-- Distance-based tween duration (shared: Main "Go to Location", other features). Tune speed lower for stricter anti-cheat pacing.
local MANCING_LOCATION_ARRIVAL_SPEED_STUDS_PER_SEC = 38
local MANCING_LOCATION_ARRIVAL_MIN_TWEEN_SEC = 2.5
local MANCING_LOCATION_ARRIVAL_MAX_TWEEN_SEC = 240

function computeLocationArrivalDurationSec(startPos: Vector3, endPos: Vector3): number
    local d = (endPos - startPos).Magnitude
    if d < 0.05 then
        return MANCING_LOCATION_ARRIVAL_MIN_TWEEN_SEC
    end
    local t = d / MANCING_LOCATION_ARRIVAL_SPEED_STUDS_PER_SEC
    return math.clamp(t, MANCING_LOCATION_ARRIVAL_MIN_TWEEN_SEC, MANCING_LOCATION_ARRIVAL_MAX_TWEEN_SEC)
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

-- */  Elements Section  /* --
local ElementsSection = Window:Section({
    Title = "Elements",
    Opened = true,
})

-- Bridged from Local Player tab: temporary fly + no clip for underground auto-sell (Main tab).
local autoSellTripAssist = {}

-- */  Local Player Tab  /* --
do
    local LocalPlayerTab = ElementsSection:Tab({
        Title = "Local Player",
        Icon = "solar:folder-2-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    local MiscSection = LocalPlayerTab:Section({
        Title = "Misc",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local infiniteJumpConnection = nil
    local antiAfkConnection = nil
    local noClipEnabled = false
    local noClipConnection = nil
    local cameraPenetrateEnabled = false
    local defaultCameraOcclusionMode = Players.LocalPlayer.DevCameraOcclusionMode
    local flyEnabled = false
    local flySpeed = 50
    local flyBV, flyBG = nil, nil
    local flyConnection = nil
    local flyKeys = {}
    local freeCameraEnabled = false
    local freeCameraConnection = nil
    local freeCameraDragBeganConn = nil
    local freeCameraDragEndedConn = nil
    local freeCameraDragging = false
    local freeCameraSpeed = 50
    local freeCameraSensitivity = 0.5
    local freeCameraCf = nil

    local function stopFly()
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
        local character = Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
    end

    local function startFly()
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not rootPart or not humanoid then return end
        stopFly()
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.Parent = rootPart
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.P = 9e4
        flyBG.D = 500
        flyBG.Parent = rootPart
        humanoid.PlatformStand = true
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not rootPart or not rootPart.Parent then
                stopFly()
                return
            end
            local cam = Workspace.CurrentCamera
            if not cam then return end
            local look = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            local move = Vector3.new(0, 0, 0)
            if flyKeys[Enum.KeyCode.W] then move = move + look end
            if flyKeys[Enum.KeyCode.S] then move = move - look end
            if flyKeys[Enum.KeyCode.D] then move = move + right end
            if flyKeys[Enum.KeyCode.A] then move = move - right end
            if flyKeys[Enum.KeyCode.Space] then move = move + Vector3.new(0, 1, 0) end
            if flyKeys[Enum.KeyCode.LeftControl] or flyKeys[Enum.KeyCode.RightControl] then move = move - Vector3.new(0, 1, 0) end
            if move.Magnitude > 0 then
                move = move.Unit * flySpeed
            end
            flyBV.Velocity = move
            flyBG.CFrame = cam.CFrame
        end)
    end

    local function applyNoClip(character, enabled)
        if not character then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
    end

    local function setNoClipActive(enabled)
        noClipEnabled = enabled
        if noClipConnection then
            noClipConnection:Disconnect()
            noClipConnection = nil
        end
        local character = Players.LocalPlayer.Character
        applyNoClip(character, enabled)
        if enabled then
            noClipConnection = RunService.Stepped:Connect(function()
                if not noClipEnabled then
                    return
                end
                local ch = Players.LocalPlayer.Character
                if ch then
                    applyNoClip(ch, true)
                end
            end)
        end
    end

    local function startAntiAfk()
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
        local localPlayer = Players.LocalPlayer
        antiAfkConnection = localPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end

    local function stopAntiAfk()
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
    end

    startAntiAfk()

    MiscSection:Toggle({
        Title = "Anti AFK",
        Desc = "Prevent kick for inactivity (resets idle when Roblox detects AFK)",
        Value = true,
        Callback = function(enabled)
            if enabled then
                startAntiAfk()
            else
                stopAntiAfk()
            end
        end
    })

    MiscSection:Toggle({
        Title = "Infinite Jump",
        Callback = function(enabled)
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
            if enabled then
                infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                    local character = Players.LocalPlayer.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end)
            end
        end
    })

    MiscSection:Toggle({
        Title = "No Clip",
        Desc = "Pass through walls (disables character collision)",
        Callback = function(enabled)
            setNoClipActive(enabled)
        end
    })

    do
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
                flyKeys[input.KeyCode] = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
                flyKeys[input.KeyCode] = false
            end
        end)
    end

    MiscSection:Toggle({
        Title = "Fly",
        Desc = "WASD + Space (up) / Ctrl (down), camera direction",
        Callback = function(enabled)
            flyEnabled = enabled
            if enabled then
                startFly()
            else
                stopFly()
            end
        end
    })

    local savedMouseBehavior = nil
    local savedMouseIconEnabled = nil

    local function stopFreeCamera()
        if freeCameraConnection then
            freeCameraConnection:Disconnect()
            freeCameraConnection = nil
        end
        if freeCameraDragBeganConn then
            freeCameraDragBeganConn:Disconnect()
            freeCameraDragBeganConn = nil
        end
        if freeCameraDragEndedConn then
            freeCameraDragEndedConn:Disconnect()
            freeCameraDragEndedConn = nil
        end
        freeCameraDragging = false
        if savedMouseBehavior ~= nil then
            UserInputService.MouseBehavior = savedMouseBehavior
            savedMouseBehavior = nil
        end
        if savedMouseIconEnabled ~= nil then
            UserInputService.MouseIconEnabled = savedMouseIconEnabled
            savedMouseIconEnabled = nil
        end
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then rootPart.Anchored = false end
        local cam = Workspace.CurrentCamera
        if cam then
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = character and character:FindFirstChildOfClass("Humanoid")
        end
    end

    local function startFreeCamera()
        stopFreeCamera()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then rootPart.Anchored = true end
        savedMouseBehavior = UserInputService.MouseBehavior
        savedMouseIconEnabled = UserInputService.MouseIconEnabled
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        freeCameraCf = cam.CFrame
        cam.CameraType = Enum.CameraType.Scriptable
        freeCameraDragBeganConn = UserInputService.InputBegan:Connect(function(input)
            if freeCameraEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2) then
                freeCameraDragging = true
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                UserInputService.MouseIconEnabled = false
            end
        end)
        freeCameraDragEndedConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                freeCameraDragging = false
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                UserInputService.MouseIconEnabled = true
            end
        end)
        freeCameraConnection = RunService.RenderStepped:Connect(function()
            if not freeCameraEnabled or not freeCameraCf then
                stopFreeCamera()
                return
            end
            if freeCameraDragging then
                local delta = UserInputService:GetMouseDelta()
                local pos = freeCameraCf.Position
                local look = freeCameraCf.LookVector
                local right = freeCameraCf.RightVector
                -- Yaw: rotate around world Y so horizontal mouse is level
                local yaw = math.rad(delta.X * freeCameraSensitivity)
                local cy, sy = math.cos(yaw), math.sin(yaw)
                look = Vector3.new(look.X * cy - look.Z * sy, look.Y, look.X * sy + look.Z * cy).Unit
                right = Vector3.new(right.X * cy - right.Z * sy, right.Y, right.X * sy + right.Z * cy).Unit
                -- Pitch: rotate look around right so vertical mouse is straight up/down
                local up = right:Cross(look).Unit
                local pitch = math.rad(-delta.Y * freeCameraSensitivity)
                look = (look * math.cos(pitch) + up * math.sin(pitch)).Unit
                freeCameraCf = CFrame.fromMatrix(pos, right, right:Cross(look))
            end
            local look = freeCameraCf.LookVector
            local right = freeCameraCf.RightVector
            local move = Vector3.new(0, 0, 0)
            if flyKeys[Enum.KeyCode.W] then move = move + look end
            if flyKeys[Enum.KeyCode.S] then move = move - look end
            if flyKeys[Enum.KeyCode.D] then move = move + right end
            if flyKeys[Enum.KeyCode.A] then move = move - right end
            if flyKeys[Enum.KeyCode.Space] then move = move + Vector3.new(0, 1, 0) end
            if flyKeys[Enum.KeyCode.LeftControl] or flyKeys[Enum.KeyCode.RightControl] then move = move - Vector3.new(0, 1, 0) end
            if move.Magnitude > 0 then
                move = move.Unit * freeCameraSpeed * 0.016
            end
            freeCameraCf = freeCameraCf + move
            cam.CFrame = freeCameraCf
        end)
    end

    MiscSection:Toggle({
        Title = "Free Camera",
        Desc = "Detach camera. Hold LMB/RMB + drag to look; WASD + Space/Ctrl to move. Character stays in place; cursor visible when not dragging.",
        Callback = function(enabled)
            freeCameraEnabled = enabled
            if enabled then
                startFreeCamera()
            else
                stopFreeCamera()
            end
        end
    })

    MiscSection:Toggle({
        Title = "Camera Penetrate",
        Desc = "Allow camera zoom to pass objects",
        Callback = function(enabled)
            cameraPenetrateEnabled = enabled
            local lp = Players.LocalPlayer
            if cameraPenetrateEnabled then
                lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
            else
                lp.DevCameraOcclusionMode = defaultCameraOcclusionMode
            end
        end
    })

    do
        Players.LocalPlayer.CharacterAdded:Connect(function(character)
            if flyEnabled then
                task.defer(function() startFly() end)
            end
            if noClipEnabled then
                task.defer(function()
                    applyNoClip(character, true)
                end)
            end
        end)
        if noClipEnabled and Players.LocalPlayer.Character then
            applyNoClip(Players.LocalPlayer.Character, true)
        end
    end

    LocalPlayerTab:Space()

    local WalkSpeedSection = LocalPlayerTab:Section({
        Title = "Walk Speed",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local defaultWalkSpeed = 16

    local function getCurrentCharacterWalkSpeed()
        local character = Players.LocalPlayer.Character
        if not character then
            return nil, "Character not loaded"
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return nil, "Humanoid not found"
        end
        return humanoid.WalkSpeed
    end

    local currentWalkSpeed = getCurrentCharacterWalkSpeed()
    local walkSpeedValue = tostring(currentWalkSpeed or defaultWalkSpeed)

    local WalkSpeedInput = WalkSpeedSection:Input({
        Title = "Speed",
        Placeholder = "e.g. 16 or 100",
        Value = walkSpeedValue,
        Callback = function(value)
            walkSpeedValue = value
        end
    })

    local function syncWalkSpeedInputFromCharacter(showNotify)
        local speed, errMessage = getCurrentCharacterWalkSpeed()
        if not speed then
            if showNotify then
                WindUI:Notify({ Title = "Walk Speed", Content = errMessage, Icon = "x" })
            end
            return false
        end

        local speedText = tostring(speed)
        walkSpeedValue = speedText
        if WalkSpeedInput and WalkSpeedInput.Set then
            WalkSpeedInput:Set(speedText)
        elseif WalkSpeedInput and WalkSpeedInput.SetValue then
            WalkSpeedInput:SetValue(speedText)
        end

        if showNotify then
            WindUI:Notify({ Title = "Walk Speed", Content = "Current speed: " .. speedText, Icon = "check" })
        end
        return true
    end

    WalkSpeedSection:Space()

    WalkSpeedSection:Button({
        Title = "Get Current Walk Speed",
        Justify = "Center",
        Icon = "",
        Callback = function()
            syncWalkSpeedInputFromCharacter(true)
        end
    })

    -- Keep the input defaulted to current character speed when available.
    syncWalkSpeedInputFromCharacter(false)

    WalkSpeedSection:Space()

    WalkSpeedSection:Button({
        Title = "Apply",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                WindUI:Notify({ Title = "Walk Speed", Content = "Character not loaded", Icon = "x" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                WindUI:Notify({ Title = "Walk Speed", Content = "Humanoid not found", Icon = "x" })
                return
            end
            local speed = tonumber(walkSpeedValue) or defaultWalkSpeed
            humanoid.WalkSpeed = math.max(0, speed)
            WindUI:Notify({ Title = "Walk Speed", Content = "Set to " .. tostring(humanoid.WalkSpeed), Icon = "check" })
        end
    })

    WalkSpeedSection:Space()

    WalkSpeedSection:Button({
        Title = "Reset",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                WindUI:Notify({ Title = "Walk Speed", Content = "Character not loaded", Icon = "x" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                WindUI:Notify({ Title = "Walk Speed", Content = "Humanoid not found", Icon = "x" })
                return
            end
            humanoid.WalkSpeed = defaultWalkSpeed
            walkSpeedValue = tostring(defaultWalkSpeed)
            WindUI:Notify({ Title = "Walk Speed", Content = "Reset to " .. tostring(defaultWalkSpeed), Icon = "check" })
        end
    })

    LocalPlayerTab:Space()

    local JumpHeightSection = LocalPlayerTab:Section({
        Title = "Jump Height",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local defaultJumpHeight = 7.2

    local function getCurrentCharacterJumpHeight()
        local character = Players.LocalPlayer.Character
        if not character then
            return nil, "Character not loaded"
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return nil, "Humanoid not found"
        end
        return humanoid.JumpHeight
    end

    local currentJumpHeight = getCurrentCharacterJumpHeight()
    local jumpHeightValue = tostring(currentJumpHeight or defaultJumpHeight)

    local JumpHeightInput = JumpHeightSection:Input({
        Title = "Height",
        Placeholder = "e.g. 7.2 or 50",
        Value = jumpHeightValue,
        Callback = function(value)
            jumpHeightValue = value
        end
    })

    local function syncJumpHeightInputFromCharacter(showNotify)
        local jumpHeight, errMessage = getCurrentCharacterJumpHeight()
        if not jumpHeight then
            if showNotify then
                WindUI:Notify({ Title = "Jump Height", Content = errMessage, Icon = "x" })
            end
            return false
        end

        local jumpHeightText = tostring(jumpHeight)
        jumpHeightValue = jumpHeightText
        if JumpHeightInput and JumpHeightInput.Set then
            JumpHeightInput:Set(jumpHeightText)
        elseif JumpHeightInput and JumpHeightInput.SetValue then
            JumpHeightInput:SetValue(jumpHeightText)
        end

        if showNotify then
            WindUI:Notify({ Title = "Jump Height", Content = "Current jump height: " .. jumpHeightText, Icon = "check" })
        end
        return true
    end

    JumpHeightSection:Space()

    JumpHeightSection:Button({
        Title = "Get Current Jump Height",
        Justify = "Center",
        Icon = "",
        Callback = function()
            syncJumpHeightInputFromCharacter(true)
        end
    })

    -- Keep the input defaulted to current character jump height when available.
    syncJumpHeightInputFromCharacter(false)

    JumpHeightSection:Space()

    JumpHeightSection:Button({
        Title = "Apply",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                WindUI:Notify({ Title = "Jump Height", Content = "Character not loaded", Icon = "x" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                WindUI:Notify({ Title = "Jump Height", Content = "Humanoid not found", Icon = "x" })
                return
            end
            local jumpHeight = tonumber(jumpHeightValue) or defaultJumpHeight
            humanoid.JumpHeight = math.max(0, jumpHeight)
            WindUI:Notify({ Title = "Jump Height", Content = "Set to " .. tostring(humanoid.JumpHeight), Icon = "check" })
        end
    })

    LocalPlayerTab:Space()

    local ESPSection = LocalPlayerTab:Section({
        Title = "ESP",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local espNamesEnabled = false
    local espDistanceEnabled = false
    local espCharacterEnabled = false
    local espLinesEnabled = false
    local espMaxDistance = 10000
    local espPlayerState: { [Player]: { highlight: Highlight?, nameGui: BillboardGui?, lineBeam: Beam?, lineFrom: Attachment?, lineTo: Attachment? } } = {}
    local espPlayerAddedConn: RBXScriptConnection? = nil
    local espPlayerRemovingConn: RBXScriptConnection? = nil
    local espLocalCharacterConn: RBXScriptConnection? = nil
    local espRenderStepConn: RBXScriptConnection? = nil

    local function espGetPlayerRoot(player: Player): BasePart?
        local character = player.Character
        if not character then
            return nil
        end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then
            return root
        end
        return nil
    end

    local function espGetState(player: Player)
        local state = espPlayerState[player]
        if not state then
            state = {}
            espPlayerState[player] = state
        end
        return state
    end

    local function espClearVisualsForPlayer(player: Player)
        local state = espPlayerState[player]
        if not state then
            return
        end
        if state.highlight then
            state.highlight:Destroy()
            state.highlight = nil
        end
        if state.nameGui then
            state.nameGui:Destroy()
            state.nameGui = nil
        end
        if state.lineBeam then
            state.lineBeam:Destroy()
            state.lineBeam = nil
        end
        if state.lineFrom then
            state.lineFrom:Destroy()
            state.lineFrom = nil
        end
        if state.lineTo then
            state.lineTo:Destroy()
            state.lineTo = nil
        end
    end

    local function espApplyForPlayer(player: Player)
        if player == Players.LocalPlayer then
            return
        end
        local character = player.Character
        local root = espGetPlayerRoot(player)
        if not character or not root then
            espClearVisualsForPlayer(player)
            return
        end
        local state = espGetState(player)
        local localRoot = espGetPlayerRoot(Players.LocalPlayer)
        local distToLocal: number? = nil
        if localRoot then
            distToLocal = (localRoot.Position - root.Position).Magnitude
        end
        local withinMaxDistance = (espMaxDistance <= 0) or (distToLocal ~= nil and distToLocal <= espMaxDistance)

        if espCharacterEnabled and withinMaxDistance then
            if not state.highlight then
                local h = Instance.new("Highlight")
                h.Name = "SempatPanickESPHighlight"
                h.FillColor = Color3.fromRGB(16, 197, 80)
                h.FillTransparency = 0.7
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.OutlineTransparency = 0
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = character
                state.highlight = h
            end
            state.highlight.Adornee = character
            state.highlight.Enabled = true
        elseif state.highlight then
            state.highlight:Destroy()
            state.highlight = nil
        end

        if (espNamesEnabled or espDistanceEnabled) and withinMaxDistance then
            if not state.nameGui then
                local nameGui = Instance.new("BillboardGui")
                nameGui.Name = "SempatPanickESPName"
                nameGui.Size = UDim2.fromOffset(220, 44)
                nameGui.StudsOffset = Vector3.new(0, 3.5, 0)
                nameGui.AlwaysOnTop = true
                nameGui.MaxDistance = espMaxDistance

                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.BackgroundTransparency = 1
                label.Size = UDim2.fromScale(1, 1)
                label.Font = Enum.Font.GothamBold
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextStrokeTransparency = 0
                label.TextScaled = true
                label.TextWrapped = true
                label.Parent = nameGui

                state.nameGui = nameGui
            end
            state.nameGui.MaxDistance = espMaxDistance
            local label = state.nameGui:FindFirstChild("Label")
            if label and label:IsA("TextLabel") then
                local baseName = player.DisplayName and player.DisplayName ~= "" and player.DisplayName or player.Name
                if espDistanceEnabled then
                    if distToLocal then
                        label.Text = string.format("%s\n[%.0fm]", baseName, distToLocal)
                    else
                        label.Text = baseName
                    end
                else
                    label.Text = baseName
                end
            end
            state.nameGui.Adornee = root
            state.nameGui.Parent = root
            state.nameGui.Enabled = true
        elseif state.nameGui then
            state.nameGui:Destroy()
            state.nameGui = nil
        end

        if espLinesEnabled then
            if localRoot then
                if not state.lineFrom then
                    local a0 = Instance.new("Attachment")
                    a0.Name = "SempatPanickESPFrom"
                    a0.Parent = localRoot
                    state.lineFrom = a0
                elseif state.lineFrom.Parent ~= localRoot then
                    state.lineFrom.Parent = localRoot
                end

                if not state.lineTo then
                    local a1 = Instance.new("Attachment")
                    a1.Name = "SempatPanickESPTo"
                    a1.Parent = root
                    state.lineTo = a1
                elseif state.lineTo.Parent ~= root then
                    state.lineTo.Parent = root
                end

                if not state.lineBeam then
                    local beam = Instance.new("Beam")
                    beam.Name = "SempatPanickESPLine"
                    beam.FaceCamera = true
                    beam.Width0 = 0.06
                    beam.Width1 = 0.06
                    beam.Color = ColorSequence.new(Color3.fromRGB(16, 197, 80))
                    beam.Transparency = NumberSequence.new(0.2)
                    beam.LightEmission = 1
                    beam.Parent = Workspace.Terrain
                    state.lineBeam = beam
                end

                if withinMaxDistance then
                    state.lineBeam.Attachment0 = state.lineFrom
                    state.lineBeam.Attachment1 = state.lineTo
                    state.lineBeam.Enabled = true
                else
                    state.lineBeam.Enabled = false
                end
            elseif state.lineBeam then
                state.lineBeam.Enabled = false
            end
        else
            if state.lineBeam then
                state.lineBeam:Destroy()
                state.lineBeam = nil
            end
            if state.lineFrom then
                state.lineFrom:Destroy()
                state.lineFrom = nil
            end
            if state.lineTo then
                state.lineTo:Destroy()
                state.lineTo = nil
            end
        end
    end

    local function espApplyForAllPlayers()
        for _, p in ipairs(Players:GetPlayers()) do
            espApplyForPlayer(p)
        end
    end

    local function espAnyEnabled(): boolean
        return espNamesEnabled or espDistanceEnabled or espCharacterEnabled or espLinesEnabled
    end

    ESPSection:Input({
        Title = "ESP Max Distance",
        Placeholder = "0 = unlimited, e.g. 10000",
        Value = tostring(espMaxDistance),
        Callback = function(value)
            local n = tonumber(value)
            if not n then
                return
            end
            espMaxDistance = math.max(0, n)
            if espAnyEnabled() then
                espApplyForAllPlayers()
            end
        end
    })

    ESPSection:Space()

    local function espOnRenderStep()
        if not espAnyEnabled() then
            return
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Players.LocalPlayer then
                espApplyForPlayer(p)
            end
        end
    end

    local function espSetRuntimeEnabled(enabled: boolean)
        if enabled then
            if not espPlayerAddedConn then
                espPlayerAddedConn = Players.PlayerAdded:Connect(function(player)
                    player.CharacterAdded:Connect(function()
                        task.wait(0.15)
                        espApplyForPlayer(player)
                    end)
                    espApplyForPlayer(player)
                end)
            end
            if not espPlayerRemovingConn then
                espPlayerRemovingConn = Players.PlayerRemoving:Connect(function(player)
                    espClearVisualsForPlayer(player)
                    espPlayerState[player] = nil
                end)
            end
            if not espLocalCharacterConn then
                espLocalCharacterConn = Players.LocalPlayer.CharacterAdded:Connect(function()
                    task.wait(0.2)
                    espApplyForAllPlayers()
                end)
            end
            if not espRenderStepConn then
                espRenderStepConn = RunService.RenderStepped:Connect(espOnRenderStep)
            end
            espApplyForAllPlayers()
            return
        end

        if espPlayerAddedConn then
            espPlayerAddedConn:Disconnect()
            espPlayerAddedConn = nil
        end
        if espPlayerRemovingConn then
            espPlayerRemovingConn:Disconnect()
            espPlayerRemovingConn = nil
        end
        if espLocalCharacterConn then
            espLocalCharacterConn:Disconnect()
            espLocalCharacterConn = nil
        end
        if espRenderStepConn then
            espRenderStepConn:Disconnect()
            espRenderStepConn = nil
        end
        for player in pairs(espPlayerState) do
            espClearVisualsForPlayer(player)
            espPlayerState[player] = nil
        end
    end

    ESPSection:Toggle({
        Title = "ESP Player Names",
        Desc = "Show player name above character",
        Value = false,
        Callback = function(enabled)
            espNamesEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then
                espApplyForAllPlayers()
            end
        end
    })

    ESPSection:Toggle({
        Title = "ESP Player Distance",
        Desc = "Show player distance in meters (below name)",
        Value = false,
        Callback = function(enabled)
            espDistanceEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then
                espApplyForAllPlayers()
            end
        end
    })

    ESPSection:Toggle({
        Title = "ESP Player Character",
        Desc = "Highlight player character",
        Value = false,
        Callback = function(enabled)
            espCharacterEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then
                espApplyForAllPlayers()
            end
        end
    })

    ESPSection:Toggle({
        Title = "ESP Player Lines",
        Desc = "Draw line from your character to players",
        Value = false,
        Callback = function(enabled)
            espLinesEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then
                espApplyForAllPlayers()
            end
        end
    })

    LocalPlayerTab:Space()

    local PlayersInfoSection = LocalPlayerTab:Section({
        Title = "Players Info",
        Desc = "Pick a player to view username, display name, speed, location, Humanoid properties, and Humanoid children",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local infoPlayerList = {}
    local infoPlayerDisplayNames = {}
    local selectedInfoPlayer = nil
    local PlayersInfoDropdown
    local PlayersInfoParagraph

    local function playerInfoLabel(player)
        if not player then return "" end
        local dn = player.DisplayName
        if dn and dn ~= "" and dn ~= player.Name then
            return string.format("%s (@%s)", dn, player.Name)
        end
        return player.Name
    end

    local function formatHumanoidChildLine(child)
        if child:IsA("ValueBase") then
            local ok, val = pcall(function()
                return child.Value
            end)
            if not ok then
                return "  " .. child.Name .. " (" .. child.ClassName .. ") = ?"
            end
            return "  " .. child.Name .. " (" .. child.ClassName .. ") = " .. formatValueForDisplay(val)
        end
        return "  " .. child.Name .. " = " .. child.ClassName
    end

    -- Fallback fields if runtime property discovery is unavailable.
    local HUMANOID_INSPECT_PROPERTIES_FALLBACK = {
        "AutoJumpEnabled",
        "AutoRotate",
        "BreakJointsOnDeath",
        "CameraOffset",
        "DisplayDistanceType",
        "EvaluateStateMachine",
        "FloorMaterial",
        "Health",
        "HealthDisplayType",
        "HipHeight",
        "Jump",
        "JumpHeight",
        "JumpPower",
        "MaxHealth",
        "MaxSlopeAngle",
        "MeshHeadScale",
        "MoveDirection",
        "NameDisplayDistance",
        "RequiresNeck",
        "RigType",
        "RootPart",
        "SeatPart",
        "Sit",
        "TargetPoint",
        "UseJumpPower",
        "WalkSpeed",
        "WalkToPart",
        "WalkToPoint",
    }

    local PLAYER_INSPECT_PROPERTIES_FALLBACK = {
        "AccountAge",
        "AutoJumpEnabled",
        "CanLoadCharacterAppearance",
        "CharacterAppearanceId",
        "DataComplexity",
        "DataReady",
        "DevComputerCameraMode",
        "DevComputerMovementMode",
        "DevEnableMouseLock",
        "DevTouchCameraMode",
        "DevTouchMovementMode",
        "DisplayName",
        "FollowUserId",
        "GameplayPaused",
        "HasVerifiedBadge",
        "HealthDisplayDistance",
        "LocaleId",
        "MembershipType",
        "Name",
        "Neutral",
        "RespawnLocation",
        "SimulationRadius",
        "Team",
        "TeamColor",
        "UserId",
    }

    local function getReadablePropertyNames(instance: Instance, fallbackList: { string }): { string }
        local names = {}
        local seen = {}
        local function addName(name: string)
            if name == "" or seen[name] then
                return
            end
            seen[name] = true
            table.insert(names, name)
        end

        -- Executor-provided reflection API (if available).
        local getPropertiesFn = rawget(_G, "getproperties")
        if type(getPropertiesFn) == "function" then
            local ok = pcall(function()
                local discovered = getPropertiesFn(instance)
                if type(discovered) == "table" then
                    for _, name in ipairs(discovered) do
                        if type(name) == "string" then
                            addName(name)
                        end
                    end
                end
            end)
            if not ok then
                -- Ignore and fall back to static property lists below.
            end
        end

        if #names == 0 then
            for _, name in ipairs(fallbackList) do
                addName(name)
            end
        end

        table.sort(names, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return names
    end

    local function buildPlayersInfoText(player)
        if not player then
            return "Select a player from the list."
        end
        local lines = {}
        table.insert(lines, "Username: " .. player.Name)
        local dn = player.DisplayName
        table.insert(lines, "Display name: " .. ((dn and dn ~= "") and dn or "(same as username)"))
        table.insert(lines, "")
        table.insert(lines, "LocalPlayer attributes:")
        local localPlayer = Players.LocalPlayer
        if localPlayer then
            local attrs = localPlayer:GetAttributes()
            local attrRows = {}
            for key, val in pairs(attrs) do
                table.insert(attrRows, {
                    key = tostring(key),
                    text = "  " .. tostring(key) .. " = " .. formatValueForDisplay(val),
                })
            end
            table.sort(attrRows, function(a, b)
                return string.lower(a.key) < string.lower(b.key)
            end)
            if #attrRows == 0 then
                table.insert(lines, "  (none)")
            else
                for _, row in ipairs(attrRows) do
                    table.insert(lines, row.text)
                end
            end
        else
            table.insert(lines, "  (LocalPlayer not found)")
        end
        table.insert(lines, "")
        table.insert(lines, "LocalPlayer properties:")
        if localPlayer then
            local propRows = {}
            for _, propName in ipairs(getReadablePropertyNames(localPlayer, PLAYER_INSPECT_PROPERTIES_FALLBACK)) do
                local ok, val = pcall(function()
                    return localPlayer[propName]
                end)
                if ok then
                    table.insert(propRows, {
                        key = propName,
                        text = "  " .. propName .. " = " .. formatValueForDisplay(val),
                    })
                end
            end
            table.sort(propRows, function(a, b)
                return string.lower(a.key) < string.lower(b.key)
            end)
            if #propRows == 0 then
                table.insert(lines, "  (none readable)")
            else
                for _, row in ipairs(propRows) do
                    table.insert(lines, row.text)
                end
            end
        else
            table.insert(lines, "  (LocalPlayer not found)")
        end
        local character = player.Character
        if not character then
            table.insert(lines, "Character: not loaded")
            table.insert(lines, "Location: —")
            table.insert(lines, "")
            table.insert(lines, "Humanoid properties: —")
            table.insert(lines, "Inside Humanoid (children): —")
            return table.concat(lines, "\n")
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
        if root then
            local p = root.Position
            table.insert(lines, string.format("Location: %.2f, %.2f, %.2f", p.X, p.Y, p.Z))
            local okVel, velMag = pcall(function()
                return root.AssemblyLinearVelocity.Magnitude
            end)
            if okVel and velMag then
                table.insert(lines, string.format("Velocity (mag): %.2f", velMag))
            end
        else
            table.insert(lines, "Location: (no HumanoidRootPart / PrimaryPart)")
        end
        table.insert(lines, "")
        table.insert(lines, "Humanoid attributes:")
        if humanoid then
            local humAttrs = humanoid:GetAttributes()
            local humAttrRows = {}
            for key, val in pairs(humAttrs) do
                table.insert(humAttrRows, {
                    key = tostring(key),
                    text = "  " .. tostring(key) .. " = " .. formatValueForDisplay(val),
                })
            end
            table.sort(humAttrRows, function(a, b)
                return string.lower(a.key) < string.lower(b.key)
            end)
            if #humAttrRows == 0 then
                table.insert(lines, "  (none)")
            else
                for _, row in ipairs(humAttrRows) do
                    table.insert(lines, row.text)
                end
            end
        else
            table.insert(lines, "  (no Humanoid)")
        end
        table.insert(lines, "")
        if humanoid then
            table.insert(lines, "Humanoid properties:")
            local propRows = {}
            for _, propName in ipairs(getReadablePropertyNames(humanoid, HUMANOID_INSPECT_PROPERTIES_FALLBACK)) do
                local ok, val = pcall(function()
                    return humanoid[propName]
                end)
                if ok then
                    table.insert(propRows, {
                        key = propName,
                        text = "  "
                            .. propName
                            .. " = "
                            .. formatValueForDisplay(val),
                    })
                end
            end
            table.sort(propRows, function(a, b)
                return string.lower(a.key) < string.lower(b.key)
            end)
            for _, row in ipairs(propRows) do
                table.insert(lines, row.text)
            end
        else
            table.insert(lines, "Humanoid properties: (no Humanoid)")
        end
        table.insert(lines, "")
        table.insert(lines, "Inside Humanoid (children):")
        if humanoid then
            local children = humanoid:GetChildren()
            table.sort(children, function(a, b)
                return string.lower(a.Name) < string.lower(b.Name)
            end)
            if #children == 0 then
                table.insert(lines, "  (none)")
            else
                for _, child in ipairs(children) do
                    table.insert(lines, formatHumanoidChildLine(child))
                end
            end
        else
            table.insert(lines, "  (no Humanoid)")
        end
        return table.concat(lines, "\n")
    end

    local function updatePlayersInfoParagraph()
        if PlayersInfoParagraph and PlayersInfoParagraph.SetDesc then
            PlayersInfoParagraph:SetDesc(buildPlayersInfoText(selectedInfoPlayer))
        end
    end

    local function refreshPlayersInfoList(showNotify)
        infoPlayerList = {}
        infoPlayerDisplayNames = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.ClassName == "Player" then
                table.insert(infoPlayerList, plr)
                table.insert(infoPlayerDisplayNames, playerInfoLabel(plr))
            end
        end
        if PlayersInfoDropdown and PlayersInfoDropdown.Refresh then
            PlayersInfoDropdown:Refresh(infoPlayerDisplayNames)
        end
        if selectedInfoPlayer then
            if not table.find(infoPlayerList, selectedInfoPlayer) then
                selectedInfoPlayer = nil
                if PlayersInfoDropdown and PlayersInfoDropdown.Select then PlayersInfoDropdown:Select(nil) end
                if PlayersInfoDropdown and PlayersInfoDropdown.Set then PlayersInfoDropdown:Set(nil) end
            end
        end
        updatePlayersInfoParagraph()
        if showNotify then
            WindUI:Notify({ Title = "Players Info", Content = "Player list refreshed (" .. #infoPlayerList .. ")", Icon = "check" })
        end
    end

    PlayersInfoDropdown = PlayersInfoSection:Dropdown({
        Title = "Player",
        Desc = "All players in this server",
        Values = infoPlayerDisplayNames,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(value)
            selectedInfoPlayer = nil
            if value then
                local idx = table.find(infoPlayerDisplayNames, value)
                if idx and infoPlayerList[idx] then
                    selectedInfoPlayer = infoPlayerList[idx]
                end
            end
            updatePlayersInfoParagraph()
        end,
    })

    PlayersInfoParagraph = PlayersInfoSection:Paragraph({
        Title = "Details",
        Desc = "Select a player from the list.",
    })

    PlayersInfoSection:Button({
        Title = "Refresh list",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshPlayersInfoList(true)
        end,
    })

    PlayersInfoSection:Space()

    PlayersInfoSection:Button({
        Title = "Refresh details",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedInfoPlayer then
                WindUI:Notify({ Title = "Players Info", Content = "Select a player first", Icon = "x" })
                return
            end
            updatePlayersInfoParagraph()
            WindUI:Notify({ Title = "Players Info", Content = "Details updated", Icon = "check" })
        end,
    })

    refreshPlayersInfoList(false)

    Players.PlayerAdded:Connect(function()
        refreshPlayersInfoList(false)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(function()
            refreshPlayersInfoList(false)
        end)
    end)

    LocalPlayerTab:Space()

    local ServerSection = LocalPlayerTab:Section({
        Title = "Server",
        Desc = "Server-related actions",
        Box = true,
        BoxBorder = true,
    })

    ServerSection:Button({
        Title = "Rejoin server",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local TeleportService = game:GetService("TeleportService")
            local placeId = game.PlaceId
            local jobId = game.JobId
            if placeId and jobId and #jobId > 0 then
                local ok, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, jobId)
                end)
                if not ok then
                    WindUI:Notify({
                        Title = "Rejoin",
                        Content = "Failed: " .. tostring(err),
                        Icon = "close",
                    })
                end
            else
                WindUI:Notify({
                    Title = "Rejoin",
                    Content = "Cannot rejoin (missing PlaceId or JobId)",
                    Icon = "close",
                })
            end
        end,
    })

    ServerSection:Button({
        Title = "Copy game ID",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local paste = setclipboard or toclipboard
            if not paste then
                WindUI:Notify({
                    Title = "Server",
                    Content = "Clipboard not supported in this environment",
                    Icon = "x",
                })
                return
            end
            local id = tostring(game.PlaceId)
            paste(id)
            WindUI:Notify({
                Title = "Server",
                Content = "Copied PlaceId " .. id,
                Icon = "check",
            })
        end,
    })

    local animationOptions = { "Hair Grab (R6)" }
    local selectedAnimationName = animationOptions[1]
    local animationRunning = false

    local function findHairAccessory(character: Model)
        local accessories = {}
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Accessory") then
                table.insert(accessories, child)
            end
        end

        for _, accessory in ipairs(accessories) do
            local okType, accType = pcall(function()
                return accessory.AccessoryType
            end)
            if okType and accType == Enum.AccessoryType.Hair then
                local handle = accessory:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    return accessory, handle
                end
            end
        end

        for _, accessory in ipairs(accessories) do
            if string.find(string.lower(accessory.Name), "hair", 1, true) then
                local handle = accessory:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then
                    return accessory, handle
                end
            end
        end

        return nil, nil
    end

    local function playHairGrabAnimationR6()
        if animationRunning then
            return
        end
        animationRunning = true

        local player = Players.LocalPlayer
        local character = player.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local torso = character and character:FindFirstChild("Torso")
        local rightArm = character and character:FindFirstChild("Right Arm")
        local head = character and character:FindFirstChild("Head")
        if not character or not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 or not torso or not rightArm or not head then
            animationRunning = false
            WindUI:Notify({ Title = "Animation", Content = "R6 character parts not ready", Icon = "x" })
            return
        end

        local rightShoulder = torso:FindFirstChild("Right Shoulder")
        local neck = torso:FindFirstChild("Neck")
        if not (rightShoulder and rightShoulder:IsA("Motor6D") and neck and neck:IsA("Motor6D")) then
            animationRunning = false
            WindUI:Notify({ Title = "Animation", Content = "R6 joints not found", Icon = "x" })
            return
        end

        local accessory, hairHandle = findHairAccessory(character)
        if not accessory or not hairHandle then
            animationRunning = false
            WindUI:Notify({ Title = "Animation", Content = "No hair accessory found", Icon = "x" })
            return
        end

        local originalShoulderC0 = rightShoulder.C0
        local originalNeckC0 = neck.C0
        local originalHairCFrame = hairHandle.CFrame
        local originalWeld = hairHandle:FindFirstChild("AccessoryWeld")
        if not (originalWeld and originalWeld:IsA("JointInstance")) then
            originalWeld = hairHandle:FindFirstChildOfClass("JointInstance")
        end

        local grabWeld = nil
        local restoreDone = false
        local function restoreAll()
            if restoreDone then
                return
            end
            restoreDone = true
            pcall(function()
                if grabWeld then
                    grabWeld:Destroy()
                    grabWeld = nil
                end
                hairHandle.CFrame = originalHairCFrame
                if originalWeld and originalWeld.Parent then
                    originalWeld.Enabled = true
                end
                rightShoulder.C0 = originalShoulderC0
                neck.C0 = originalNeckC0
            end)
            animationRunning = false
        end

        local moveInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local backInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        local targetShoulderC0 = originalShoulderC0
            * CFrame.Angles(math.rad(-95), math.rad(8), math.rad(28))
        local targetNeckC0 = originalNeckC0
            * CFrame.Angles(math.rad(8), math.rad(-16), 0)

        local shoulderTween = TweenService:Create(rightShoulder, moveInfo, { C0 = targetShoulderC0 })
        local neckTween = TweenService:Create(neck, moveInfo, { C0 = targetNeckC0 })

        pcall(function()
            if originalWeld and originalWeld.Parent then
                originalWeld.Enabled = false
            end
            hairHandle.CanCollide = false
            hairHandle.Massless = true
            grabWeld = Instance.new("Weld")
            grabWeld.Name = "HairGrabWeld"
            grabWeld.Part0 = rightArm
            grabWeld.Part1 = hairHandle
            grabWeld.C0 = CFrame.new(0, -1.05, -0.1) * CFrame.Angles(math.rad(80), math.rad(0), math.rad(6))
            grabWeld.Parent = rightArm
        end)

        shoulderTween:Play()
        neckTween:Play()

        task.spawn(function()
            task.wait(0.95)
            if not character.Parent then
                restoreAll()
                return
            end
            local shoulderBack = TweenService:Create(rightShoulder, backInfo, { C0 = originalShoulderC0 })
            local neckBack = TweenService:Create(neck, backInfo, { C0 = originalNeckC0 })
            shoulderBack:Play()
            neckBack:Play()
            task.wait(0.24)
            restoreAll()
        end)
    end

    LocalPlayerTab:Space()

    local AnimationSection = LocalPlayerTab:Section({
        Title = "Animation",
        Desc = "R6 local animations with accessory interaction",
        Box = true,
        BoxBorder = true,
    })

    AnimationSection:Dropdown({
        Title = "Animation list",
        Desc = "Select one animation",
        Values = animationOptions,
        Value = selectedAnimationName,
        AllowNone = false,
        SearchBarEnabled = false,
        Callback = function(value)
            if value then
                selectedAnimationName = value
            end
        end,
    })

    AnimationSection:Button({
        Title = "Animate",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if selectedAnimationName == "Hair Grab (R6)" then
                playHairGrabAnimationR6()
                return
            end
            WindUI:Notify({ Title = "Animation", Content = "Unknown animation selected", Icon = "x" })
        end,
    })

    LocalPlayerTab:Space()

    LocalPlayerTab:Button({
        Title = "Clear Console",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local cleared = false
            local clearFn = rawget(_G, "clearconsole") or rawget(_G, "rconsoleclear")
            if type(clearFn) == "function" then
                clearFn()
                cleared = true
            end
            WindUI:Notify({
                Title = "Console",
                Content = cleared and "Console cleared" or "Clear not available (try clearconsole)",
                Icon = cleared and "check" or "x",
            })
        end
    })

    autoSellTripAssist.begin = function()
        local savedFly = flyEnabled
        local savedNoClip = noClipEnabled
        local savedOcclusionMode = Players.LocalPlayer.DevCameraOcclusionMode
        flyEnabled = true
        local lp = Players.LocalPlayer
        local ch = lp.Character
        local tripNoClipConnection = nil
        lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
        if ch then
            applyNoClip(ch, true)
        end
        if not savedNoClip then
            tripNoClipConnection = RunService.Stepped:Connect(function()
                local chNow = lp.Character
                if chNow then
                    applyNoClip(chNow, true)
                end
            end)
        end
        startFly()
        return function()
            flyEnabled = savedFly
            if tripNoClipConnection then
                tripNoClipConnection:Disconnect()
                tripNoClipConnection = nil
            end
            if cameraPenetrateEnabled then
                lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
            elseif savedOcclusionMode ~= nil then
                lp.DevCameraOcclusionMode = savedOcclusionMode
            else
                lp.DevCameraOcclusionMode = defaultCameraOcclusionMode
            end
            local ch2 = lp.Character
            if ch2 then
                if savedNoClip then
                    applyNoClip(ch2, true)
                else
                    applyNoClip(ch2, false)
                end
            end
            if savedFly then
                task.defer(function()
                    startFly()
                end)
            else
                stopFly()
            end
        end
    end
end

-- */  Main Tab  /* --
do
    local MainTab = ElementsSection:Tab({
        Title = "Main",
        Icon = "solar:home-2-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

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

    local InstantFishingSection = MainTab:Section({
        Title = "Instant fishing",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    InstantFishingSection:Input({
        Title = "Delay (seconds)",
        Placeholder = "e.g. 0.5",
        Flag = "mancing_main_instantFishingDelaySec",
        Value = tostring(instantFishingDelaySec),
        Callback = function(value)
            local n = tonumber(value)
            if n and n >= 0 then
                instantFishingDelaySec = n
            end
        end,
    })

    RandomCastCmgrToggleInstant = InstantFishingSection:Toggle({
        Title = "Random Cast",
        Desc = "CMGR Result strength random between 0.5 and 1 (off = always 1).",
        Flag = "mancing_main_randomCastCmgr",
        Value = false,
        Callback = function(enabled)
            if randomCastCmgrSync then
                randomCastCmgrEnabled = enabled
                return
            end
            setRandomCastCmgrToggleInstant(enabled, RandomCastCmgrToggleInstant)
        end,
    })

    InstantFishingSection:Toggle({
        Title = "Instant fishing",
        Desc = "If minigame is not Reel, switches to Reel first; then fast cast/reel loop. Delay is the wait after each minigame.",
        Flag = "mancing_main_instantFishing",
        Value = false,
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
    
    MainTab:Space()

    local SellSection = MainTab:Section({
        Title = "Sell",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local sellMode = "Loop"
    local sellIntervalSeconds = 60
    local sellIntervalRevision = 0
    local autoSellEnabled = false
    local autoSellLoopRunning = false
    local autoSellLoopToken = 0
    local SELL_TELEPORT_CFRAME = CFrame.new(2621.24, -0.11, -911.08)
    local AUTO_SELL_LIMITED_EVENT_RETURN_TWEEN_SEC = 5
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

    -- Filled in by Location section: pause/resume pin while Auto Sell teleports.
    local locationHoldApi: { pauseForAutoSell: (() -> boolean)?, resumeAfterAutoSell: ((boolean) -> ())? } = {}

    local function runAutoSellTeleportSellAndReturn()
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
            if root then
                previousCFrame = root.CFrame
                root.CFrame = SELL_TELEPORT_CFRAME
                waitWithGameplayPauseDetect(0)
            end
            local tripDeadline = os.clock() + AUTO_SELL_TRIP_TIMEOUT_SEC
            local soldOk = fireSellFishAllUntilBackpackRemove(tripDeadline)
            if soldOk then
                root = getCurrentRoot()
                local leTweenCf = limitedEventState.returnFromSellTweenCf
                if root and root.Parent and leTweenCf then
                    local tweenOk, tweenErr = pcall(function()
                        local ti = TweenInfo.new(
                            AUTO_SELL_LIMITED_EVENT_RETURN_TWEEN_SEC,
                            Enum.EasingStyle.Quad,
                            Enum.EasingDirection.Out
                        )
                        local tw = TweenService:Create(root, ti, { CFrame = leTweenCf })
                        tw:Play()
                        tw.Completed:Wait()
                    end)
                    if not tweenOk then
                        WindUI:Notify({
                            Title = "Auto Sell",
                            Content = "Limited event return tween failed: " .. tostring(tweenErr),
                            Icon = "x",
                        })
                        root.CFrame = leTweenCf
                    end
                    if limitedEventBridge.restartLimitedEventFreezeAfterSell then
                        pcall(limitedEventBridge.restartLimitedEventFreezeAfterSell, leTweenCf)
                    end
                elseif root and previousCFrame and root.Parent then
                    root.CFrame = previousCFrame
                elseif previousCFrame then
                    WindUI:Notify({
                        Title = "Auto Sell",
                        Content = "Could not return to previous position (character/root changed after pause)",
                        Icon = "x",
                    })
                end
            else
                root = getCurrentRoot()
                if root and previousCFrame and root.Parent then
                    root.CFrame = previousCFrame
                elseif previousCFrame then
                    WindUI:Notify({
                        Title = "Auto Sell",
                        Content = "Could not return to previous position (character/root changed after pause)",
                        Icon = "x",
                    })
                end
                local leCf = limitedEventState.returnFromSellTweenCf
                if leCf and limitedEventBridge.restartLimitedEventFreezeAfterSell then
                    pcall(limitedEventBridge.restartLimitedEventFreezeAfterSell, leCf)
                end
                if autoSellEnabled and os.clock() >= tripDeadline then
                    WindUI:Notify({
                        Title = "Auto Sell",
                        Content = "Sell timed out after "
                            .. tostring(AUTO_SELL_TRIP_TIMEOUT_SEC)
                            .. "s — returned from buyer.",
                        Icon = "x",
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
        runAutoSellTeleportSellAndReturn()
        if pauseRequested then
            task.wait(1)
            autoFishingPausedForSell = false
        end
    end

    SellSection:Dropdown({
        Title = "Sell type",
        Desc = "More modes can be added later",
        Flag = "mancing_main_sellType",
        Values = { "Loop" },
        Value = "Loop",
        Callback = function(value)
            sellMode = value or "Loop"
        end,
    })

    SellSection:Input({
        Title = "Duration (seconds)",
        Placeholder = "e.g. 60",
        Flag = "mancing_main_sellIntervalSec",
        Value = tostring(sellIntervalSeconds),
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

    SellSection:Toggle({
        Title = "Auto Sell",
        Desc = "If Backpack has no fish (fish Tool with UID), skips. Else enables fly + no clip for the trip, teleports underground to sell, SellFish \"All\", returns and restores prior fly/no clip. Instant fishing: waits for minigame, pauses, sells, 1s after return resumes",
        Flag = "mancing_main_autoSell",
        Value = false,
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

    MainTab:Space()

    local LocationSection = MainTab:Section({
        Title = "Location",
        Desc = "Preset spots with facing. Go to Location tweens over a duration from distance (~"
            .. tostring(MANCING_LOCATION_ARRIVAL_SPEED_STUDS_PER_SEC)
            .. " studs/s cap), not instant snap. Ocean uses one invisible floor part to stand on water.",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    MainTab:Space()

    local SpawnBoatSection = MainTab:Section({
        Title = "Spawn Boat",
        Desc = "Owned boats: shop rows with Price = Owned. Spawn: Remotes.SpawnBoat. Top speed: BoatUI label + best-effort ReplicatedStorage.BoatShared.BoatConfig.",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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
                SpawnBoatDropdown:Set(nil)
            end
        end
    end

    SpawnBoatDropdown = SpawnBoatSection:Dropdown({
        Title = "Owned boat",
        Desc = "Only boats whose shop row Price is Owned (BoatUI Body.ScrollingFrame)",
        Flag = "mancing_main_spawnBoatPick",
        Values = spawnBoatDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
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

    SpawnBoatSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshSpawnBoatDropdown()
            local n = #spawnBoatIdList
            WindUI:Notify({
                Title = "Spawn Boat",
                Content = (n == 0) and "No rows with Price = Owned (open BoatUI shop so templates load, then Refresh)"
                    or ("Updated list (" .. n .. " owned)"),
                Icon = (n == 0) and "x" or "check",
            })
        end,
    })

    SpawnBoatSection:Button({
        Title = "Spawn",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedSpawnBoatId or selectedSpawnBoatId == "" then
                WindUI:Notify({ Title = "Spawn Boat", Content = "Select an owned boat from the dropdown first", Icon = "x" })
                return
            end
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if not remotes then
                WindUI:Notify({ Title = "Spawn Boat", Content = "Remotes folder not found", Icon = "x" })
                return
            end
            local spawnBoat = remotes:FindFirstChild("SpawnBoat")
            if not (spawnBoat and spawnBoat:IsA("RemoteFunction")) then
                WindUI:Notify({ Title = "Spawn Boat", Content = "Remotes.SpawnBoat not found", Icon = "x" })
                return
            end
            local ok, success, errMsg = pcall(function()
                return spawnBoat:InvokeServer(selectedSpawnBoatId)
            end)
            if not ok then
                WindUI:Notify({ Title = "Spawn Boat", Content = "Invoke failed: " .. tostring(success), Icon = "x" })
                return
            end
            if success then
                WindUI:Notify({ Title = "Spawn Boat", Content = "Spawn requested", Icon = "check" })
            else
                WindUI:Notify({
                    Title = "Spawn Boat",
                    Content = (typeof(errMsg) == "string" and errMsg ~= "" and errMsg) or "Spawn failed",
                    Icon = "x",
                })
            end
        end,
    })

    local locationPresetRows = {
        { name = "Pulau Raja Kepiting", pos = Vector3.new(2212.17, 11.65, -669.38), look = Vector3.new(-0.8572, -0.0000, -0.5150) },
        { name = "Bagang Teluk Dalam", pos = Vector3.new(967.70, 7.95, 1269.47), look = Vector3.new(-0.8870, -0.0000, -0.4618) },
        { name = "Bagang Teluk Tengah", pos = Vector3.new(3324.97, 7.95, -4416.49), look = Vector3.new(-0.3504, -0.0000, 0.9366) },
        { name = "Bagang Teluk Luar", pos = Vector3.new(-1901.70, 7.95, -1312.37), look = Vector3.new(-0.9483, -0.0000, -0.3174) },
        { name = "Bagang Ujung", pos = Vector3.new(-2927.68, 7.95, 4303.74), look = Vector3.new(0.3254, -0.0000, -0.9456) },
        { name = "Pulau Seribu", pos = Vector3.new(1219.55, 2.15, 3283.45), look = Vector3.new(-0.1478, -0.0000, -0.9890) },
        { name = "Pulau Boomerang", pos = Vector3.new(-1474.06, 2.06, 101.86), look = Vector3.new(-0.0348, -0.0000, -0.9994) },
        { name = "Pulau Batu Karang", pos = Vector3.new(-798.19, 11.92, -3331.46), look = Vector3.new(0.3664, -0.0000, 0.9304) },
        { name = "Ocean", pos = Vector3.new(-3832.58, 5, -2252.42), look = Vector3.new(0.7629, 0.0000, 0.6465) },
    }

    local locationDisplayList: { string } = {}
    local locationHoldCfByName: { [string]: CFrame } = {}
    for _, row in ipairs(locationPresetRows) do
        table.insert(locationDisplayList, row.name)
        local look = row.look
        if typeof(look) == "Vector3" and look.Magnitude >= 1e-5 then
            locationHoldCfByName[row.name] = CFrame.lookAt(row.pos, row.pos + look.Unit)
        else
            locationHoldCfByName[row.name] = CFrame.new(row.pos)
        end
    end

    local selectedLocationName: string? = nil
    local teleportToLocationEnabled = false
    local lastLocationArrivalTweenSec: number? = nil
    local locationArrivalTweenToken = 0
    local locationArrivalTweenActive: Tween? = nil

    local OCEAN_LOCATION_NAME = "Ocean"

    local locationAssistFolder: Folder? = nil
    local oceanStandPart: Part? = nil

    local function ensureOceanStandPart(): Part
        local existing = oceanStandPart
        if existing and existing.Parent then
            return existing
        end
        local folder = locationAssistFolder
        if not folder or not folder.Parent then
            local f = Instance.new("Folder")
            f.Name = "MancingIndoLocationAssist"
            f.Parent = Workspace
            locationAssistFolder = f
            folder = f
        end
        local p = Instance.new("Part")
        p.Name = "OceanStand"
        p.Anchored = true
        p.CanCollide = true
        p.Transparency = 1
        p.CastShadow = false
        p.CanQuery = false
        p.Material = Enum.Material.SmoothPlastic
        p.Size = Vector3.new(96, 1, 96)
        p.CFrame = CFrame.new(0, -5000, 0)
        p.Parent = folder
        oceanStandPart = p
        return p
    end

    local function setOceanStandForTargetCf(targetCf: CFrame)
        local p = ensureOceanStandPart()
        local pos = targetCf.Position
        local halfY = p.Size.Y / 2
        p.CanCollide = true
        p.CFrame = CFrame.new(pos.X, pos.Y - halfY, pos.Z)
    end

    local function hideOceanStand()
        local p = oceanStandPart
        if p and p.Parent then
            p.CanCollide = false
            p.CFrame = CFrame.new(0, -5000, 0)
        end
    end

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
        hideOceanStand()
    end

    local function startLocationArrivalTween(): boolean
        if not teleportToLocationEnabled then
            return false
        end
        if limitedEventState.blocksLocationHold then
            cancelLocationArrivalTween()
            hideOceanStand()
            return false
        end
        if not selectedLocationName or selectedLocationName == "" then
            cancelLocationArrivalTween()
            hideOceanStand()
            return false
        end
        local holdCf = locationHoldCfByName[selectedLocationName]
        if not holdCf then
            cancelLocationArrivalTween()
            hideOceanStand()
            return false
        end
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart or not rootPart:IsA("BasePart") then
            hideOceanStand()
            return false
        end

        cancelLocationArrivalTween()
        local myToken = locationArrivalTweenToken
        if selectedLocationName == OCEAN_LOCATION_NAME then
            setOceanStandForTargetCf(holdCf)
        else
            hideOceanStand()
        end

        rootPart.AssemblyLinearVelocity = Vector3.zero
        rootPart.AssemblyAngularVelocity = Vector3.zero

        local durSec = computeLocationArrivalDurationSec(rootPart.Position, holdCf.Position)
        lastLocationArrivalTweenSec = durSec

        local ti = TweenInfo.new(durSec, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local tw = TweenService:Create(rootPart, ti, { CFrame = holdCf })
        locationArrivalTweenActive = tw
        tw.Completed:Connect(function()
            if myToken ~= locationArrivalTweenToken then
                return
            end
            locationArrivalTweenActive = nil
        end)
        tw:Play()
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
                WindUI:Notify({ Title = "Location", Content = "Select a location first", Icon = "x" })
            end
            return false
        end
        if not locationHoldCfByName[selectedLocationName] then
            stopLocationHold()
            if showFailureNotify then
                WindUI:Notify({ Title = "Location", Content = "Unknown location", Icon = "x" })
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

    LocationSection:Dropdown({
        Title = "Location",
        Desc = "Preset world positions",
        Flag = "mancing_main_locationPick",
        Values = locationDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(value)
            selectedLocationName = (value and value ~= "") and value or nil
            if teleportToLocationEnabled then
                tryActivateLocationHold(false)
            end
        end,
    })

    local TeleportLocationToggle
    TeleportLocationToggle = LocationSection:Toggle({
        Title = "Go to Location",
        Desc = "When on, tweens to the preset over time from distance (speed capped ~"
            .. tostring(MANCING_LOCATION_ARRIVAL_SPEED_STUDS_PER_SEC)
            .. " studs/s; min/max duration clamped). Re-tweens if you change the dropdown.",
        Flag = "mancing_main_teleportToLocation",
        Value = false,
        Callback = function(enabled)
            teleportToLocationEnabled = enabled
            if not enabled then
                stopLocationHold()
                return
            end
            if tryActivateLocationHold(true) then
                local sec = lastLocationArrivalTweenSec
                local durText = (typeof(sec) == "number") and string.format("%.1f", sec) or "?"
                WindUI:Notify({
                    Title = "Location",
                    Content = "Tweening to "
                        .. tostring(selectedLocationName)
                        .. " (~"
                        .. durText
                        .. "s for this distance)",
                    Icon = "check",
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
    local BackpackTab = ElementsSection:Tab({
        Title = "Backpack",
        Icon = "solar:backpack-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

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

    local FavoriteSection = BackpackTab:Section({
        Title = "Favorite",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local FavoriteByRarityDropdown
    FavoriteByRarityDropdown = FavoriteSection:Dropdown({
        Title = "By Rarity",
        Desc = "Multi-select. Auto Favorite runs ToggleLock(UID) when fish Rarity matches any selected tier.",
        Flag = "mancing_backpack_favoriteByRarity",
        Values = copyStringArray(MANCING_DEFAULT_RARITY_ORDER),
        Value = {},
        Multi = true,
        AllowNone = true,
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

    FavoriteSection:Toggle({
        Title = "Auto Favorite",
        Desc = "BackpackAdd: if Rarity is one of the selected tiers → ToggleLock(UID). Skips IsLocked.",
        Flag = "mancing_backpack_autoFavorite",
        Value = false,
        Callback = function(enabled)
            autoFavoriteEnabled = enabled
        end,
    })

    BackpackTab:Space()

    local FishInformationSection = BackpackTab:Section({
        Title = "Fish Information",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local FishInformationParagraph = FishInformationSection:Paragraph({
        Title = "Fish Description",
        Desc = "Select a fish to show details from GetBestiary.",
    })

    BackpackTab:Space()

    local FishByPlaceSection = BackpackTab:Section({
        Title = "Fish by Place",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local FishByPlaceParagraph = FishByPlaceSection:Paragraph({
        Title = "Fish List",
        Desc = "Select a location to see fish from that biome.",
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
                FishInformationDropdown:Set(nil)
            end
        end
        if FishInformationParagraph and FishInformationParagraph.SetDesc then
            FishInformationParagraph:SetDesc(fishInfoDescriptionForName(fishInfoSelectedName))
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
                FishByPlaceDropdown:Set(nil)
            end
        end
        if FishByPlaceParagraph and FishByPlaceParagraph.SetDesc then
            FishByPlaceParagraph:SetDesc(fishListByBiomeDescription(fishByPlaceSelectedBiome))
        end
        return changed
    end

    FishInformationDropdown = FishInformationSection:Dropdown({
        Title = "Fish",
        Desc = "List sourced from Remotes.GetBestiary",
        Flag = "mancing_backpack_fishInfoPick",
        Values = {},
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(value)
            fishInfoSelectedName = (type(value) == "string" and fishInfoNameByDisplay[value]) or nil
            if FishInformationParagraph and FishInformationParagraph.SetDesc then
                FishInformationParagraph:SetDesc(fishInfoDescriptionForName(fishInfoSelectedName))
            end
        end,
    })

    FishByPlaceDropdown = FishByPlaceSection:Dropdown({
        Title = "Location",
        Desc = "Distinct biome values from bestiary",
        Flag = "mancing_backpack_fishByPlaceBiome",
        Values = {},
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(value)
            fishByPlaceSelectedBiome = (type(value) == "string" and value ~= "") and value or nil
            if FishByPlaceParagraph and FishByPlaceParagraph.SetDesc then
                FishByPlaceParagraph:SetDesc(fishListByBiomeDescription(fishByPlaceSelectedBiome))
            end
        end,
    })

    FishByPlaceSection:Dropdown({
        Title = "Order By",
        Desc = "Sort fish list by Name or Rarity",
        Flag = "mancing_backpack_fishByPlaceOrderBy",
        Values = { "Name", "Rarity" },
        Value = "Rarity",
        AllowNone = false,
        Callback = function(value)
            if value == "Name" or value == "Rarity" then
                fishByPlaceOrderBy = value
            else
                fishByPlaceOrderBy = "Rarity"
            end
            if FishByPlaceParagraph and FishByPlaceParagraph.SetDesc then
                FishByPlaceParagraph:SetDesc(fishListByBiomeDescription(fishByPlaceSelectedBiome))
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
    local EventTab = ElementsSection:Tab({
        Title = "Event",
        Icon = "solar:calendar-mark-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    -- Limited Event: hourly :30 (+5s delay) staging at Bagang Teluk Tengah, optional teleport to
    -- Workspace.BiomeRegion.LimitedEvent.LimitedEvent (Y forced to 5), freeze until :50, then return.
    local LIMITED_EVENT_STAGING_CF = CFrame.lookAt(
        Vector3.new(3324.97, 7.95, -4416.49),
        Vector3.new(3324.97, 7.95, -4416.49) + Vector3.new(-0.3504, 0, 0.9366).Unit
    )
    local LIMITED_EVENT_STAGING_DELAY_SEC = 5
    -- After teleporting to staging (Bagang Teluk Tengah), only wait this long for LimitedEvent to appear; then return home.
    local LIMITED_EVENT_STAGING_WAIT_FOR_EVENT_SEC = 5
    local LIMITED_EVENT_CLOCK_POLL_SEC = 0.5
    -- Full-rate Heartbeat freeze + fish-catch UI spikes can starve the frame; snap ~20–25 Hz is enough to hold position.
    local LIMITED_EVENT_FREEZE_APPLY_INTERVAL_SEC = 1 / 22

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
    local limitedEventFreezeConn: RBXScriptConnection? = nil
    local limitedEventFreezeCf: CFrame? = nil
    local limitedEventSavedReturnCf: CFrame? = nil
    local limitedEventSessionBusy = false
    local limitedEventLastHourlyBucket = -1
    local limitedEventCachedRootForFreeze: BasePart? = nil
    local limitedEventLastFreezeApplyAt = 0

    local function limitedEventClearFreezeRootCache()
        limitedEventCachedRootForFreeze = nil
    end

    local function limitedEventGetRootForFreeze(): BasePart?
        local c = limitedEventCachedRootForFreeze
        if c and c.Parent then
            return c
        end
        c = limitedEventGetHumanoidRootPart()
        limitedEventCachedRootForFreeze = c
        return c
    end

    Players.LocalPlayer.CharacterAdded:Connect(function()
        limitedEventClearFreezeRootCache()
    end)

    local function limitedEventStopFreeze()
        if limitedEventFreezeConn then
            limitedEventFreezeConn:Disconnect()
            limitedEventFreezeConn = nil
        end
        limitedEventFreezeCf = nil
        limitedEventLastFreezeApplyAt = 0
        limitedEventClearFreezeRootCache()
    end

    function limitedEventBridge.stopLimitedEventFreezeForAutoSell()
        limitedEventStopFreeze()
        limitedEventState.blocksLocationHold = false
    end

    local function limitedEventApplyFreezeStep()
        if not autoLimitedTeleportEnabled or limitedEventState.pausedForAutoSell then
            return
        end
        local cf = limitedEventFreezeCf
        if not cf then
            return
        end
        local now = os.clock()
        if now - limitedEventLastFreezeApplyAt < LIMITED_EVENT_FREEZE_APPLY_INTERVAL_SEC then
            return
        end
        limitedEventLastFreezeApplyAt = now
        local root = limitedEventGetRootForFreeze()
        if not root then
            return
        end
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = cf
    end

    local function limitedEventStartFreezeAt(cf: CFrame)
        limitedEventStopFreeze()
        limitedEventFreezeCf = cf
        limitedEventState.returnFromSellTweenCf = cf
        limitedEventState.blocksLocationHold = true
        if limitedEventBridge.stopLocationHold then
            pcall(limitedEventBridge.stopLocationHold)
        end
        limitedEventLastFreezeApplyAt = 0
        limitedEventApplyFreezeStep()
        limitedEventFreezeConn = RunService.Heartbeat:Connect(limitedEventApplyFreezeStep)
    end

    function limitedEventBridge.restartLimitedEventFreezeAfterSell(cf: CFrame)
        if not autoLimitedTeleportEnabled then
            return
        end
        limitedEventStopFreeze()
        limitedEventFreezeCf = cf
        limitedEventState.returnFromSellTweenCf = cf
        limitedEventState.blocksLocationHold = true
        if limitedEventBridge.stopLocationHold then
            pcall(limitedEventBridge.stopLocationHold)
        end
        limitedEventLastFreezeApplyAt = 0
        limitedEventApplyFreezeStep()
        limitedEventFreezeConn = RunService.Heartbeat:Connect(limitedEventApplyFreezeStep)
    end

    local function limitedEventTeleportRootToCf(cf: CFrame)
        local root = limitedEventGetHumanoidRootPart()
        if not root then
            return false
        end
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
        root.CFrame = cf
        return true
    end

    local function limitedEventReturnToSavedAndRelease()
        limitedEventStopFreeze()
        limitedEventState.returnFromSellTweenCf = nil
        local root = limitedEventGetHumanoidRootPart()
        local back = limitedEventSavedReturnCf
        limitedEventSavedReturnCf = nil
        limitedEventState.blocksLocationHold = false
        if root and back then
            root.AssemblyLinearVelocity = Vector3.zero
            root.AssemblyAngularVelocity = Vector3.zero
            root.CFrame = back
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
            limitedEventTeleportRootToCf(LIMITED_EVENT_STAGING_CF)

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
            limitedEventTeleportRootToCf(atCf)
            limitedEventStartFreezeAt(atCf)

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

    local LimitedEventSection = EventTab:Section({
        Title = "Limited Event",
        Desc = "When enabled: runs immediately, and again each hour at :"
            .. tostring(30)
            .. " + "
            .. tostring(LIMITED_EVENT_STAGING_DELAY_SEC)
            .. "s (local clock). Teleport to Bagang Teluk Tengah, wait up to "
            .. tostring(LIMITED_EVENT_STAGING_WAIT_FOR_EVENT_SEC)
            .. "s for LimitedEvent; if it never appears, return home. If it appears, teleport with Y=5 and freeze until :50, then return. Pauses Teleport to Location while active. Auto Sell pauses this feature.",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    LimitedEventSection:Toggle({
        Title = "Auto Teleport",
        Desc = "Priority with Main tab: Auto Sell > Limited Event > Teleport to Location",
        Flag = "mancing_event_limitedAutoTeleport",
        Value = false,
        Callback = function(enabled)
            autoLimitedTeleportEnabled = enabled
            limitedEventLoopToken += 1
            limitedEventLastHourlyBucket = -1
            if not enabled then
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

    EventTab:Space()

    local GalatamaSection = EventTab:Section({
        Title = "Galatama",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local GALATAMA_QUEUE_MIN_X = 2557
    local GALATAMA_QUEUE_MAX_X = 2577.50
    local GALATAMA_QUEUE_MIN_Y = 2.7
    local GALATAMA_QUEUE_MAX_Y = 8.00
    local GALATAMA_QUEUE_MIN_Z = -801
    local GALATAMA_QUEUE_MAX_Z = -775
    local GALATAMA_SERVER_PLACE_ID = 78404864377525

    local GalatamaQueueStatusParagraph = GalatamaSection:Paragraph({
        Title = "Status",
        Desc = "Queue: Checking...",
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
        if not (GalatamaQueueStatusParagraph and GalatamaQueueStatusParagraph.SetDesc) then
            return
        end
        local root = getLocalPlayerRootPart()
        if not root then
            GalatamaQueueStatusParagraph:SetDesc("Queue: Unknown (character/root not ready)")
            return
        end
        local inQueue = isInsideGalatamaQueueArea(root.Position)
        if inQueue then
            GalatamaQueueStatusParagraph:SetDesc("Queue: In queue")
        else
            GalatamaQueueStatusParagraph:SetDesc("Queue: Not in queue")
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
            WindUI:Notify({
                Title = "Galatama",
                Content = "Teleport failed: " .. tostring(err),
                Icon = "x",
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
                        WindUI:Notify({ Title = "Galatama", Content = tostring(err), Icon = "x" })
                    end
                    task.defer(updateGalatamaQueueStatus)
                end
                task.wait(AUTO_JOIN_GALATAMA_RETRY_SEC)
            end
            autoJoinGalatamaQueueLoopRunning = false
        end)
    end

    task.defer(updateGalatamaQueueStatus)

    GalatamaSection:Button({
        Title = "Join Queue",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local ok, err = fireJoinGalatamaQueue()
            if not ok then
                WindUI:Notify({ Title = "Galatama", Content = tostring(err), Icon = "x" })
            else
                task.defer(updateGalatamaQueueStatus)
            end
        end,
    })

    GalatamaSection:Button({
        Title = "Leave Queue",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            if not remotes then
                WindUI:Notify({ Title = "Galatama", Content = "Remotes folder not found", Icon = "x" })
                return
            end
            local evt = remotes:FindFirstChild("LeaveGalatamaQueue")
            if not (evt and evt:IsA("RemoteEvent")) then
                WindUI:Notify({ Title = "Galatama", Content = "LeaveGalatamaQueue remote not found", Icon = "x" })
                return
            end
            local ok, err = pcall(function()
                evt:FireServer()
            end)
            if not ok then
                WindUI:Notify({ Title = "Galatama", Content = "FireServer failed: " .. tostring(err), Icon = "x" })
            else
                task.defer(updateGalatamaQueueStatus)
            end
        end,
    })

    GalatamaSection:Space()

    GalatamaSection:Toggle({
        Title = "Auto Join Queue",
        Desc = "Automatically calls Join Queue when status is Not in queue",
        Flag = "mancing_event_autoJoinGalatamaQueue",
        Value = false,
        Callback = function(enabled)
            autoJoinGalatamaQueueEnabled = enabled
            if enabled then
                ensureAutoJoinGalatamaQueueLoop()
            end
        end,
    })

    GalatamaSection:Space()

    GalatamaSection:Button({
        Title = "Join Galatama Server",
        Justify = "Center",
        Icon = "",
        Callback = function()
            tryTeleportToGalatamaServer()
        end,
    })

    GalatamaSection:Toggle({
        Title = "Auto Join Galatama Server",
        Desc = "While on, retries teleport to the Galatama place every "
            .. tostring(AUTO_JOIN_GALATAMA_SERVER_RETRY_SEC)
            .. "s until you leave this game or arrive (same place id).",
        Flag = "mancing_event_autoJoinGalatamaServer",
        Value = false,
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
    local ShopTab = ElementsSection:Tab({
        Title = "Shop",
        Icon = "solar:shop-2-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    local BuyRodSection = ShopTab:Section({
        Title = "Buy Rod",
        Desc = "Rods are read from FishingRodShopGui. Use Refresh if the list is empty.",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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
        if BuyRodDetailParagraph and BuyRodDetailParagraph.SetDesc then
            BuyRodDetailParagraph:SetDesc(buildRodDetailText(selectedRodId))
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
                BuyRodDropdown:Set(nil)
            end
        end
        updateBuyRodDetailParagraph()
        if showNotify then
            WindUI:Notify({
                Title = "Buy Rod",
                Content = (#rodIdList == 0) and "No rods found (open the in-game rod shop once or wait for UI to load)" or ("Found " .. #rodIdList .. " rod(s)"),
                Icon = (#rodIdList == 0) and "x" or "check",
            })
        end
    end

    BuyRodDropdown = BuyRodSection:Dropdown({
        Title = "Rod",
        Desc = "Name and price from the rod shop row (PriceLabel or button text)",
        Flag = "mancing_shop_rodPick",
        Values = rodDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
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

    BuyRodDetailParagraph = BuyRodSection:Paragraph({
        Title = "Rod details",
        Desc = "Select a rod from the dropdown to see name, price, and statistics.",
    })

    BuyRodSection:Button({
        Title = "Buy",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedRodId or selectedRodId == "" then
                WindUI:Notify({ Title = "Buy Rod", Content = "Select a rod from the dropdown first", Icon = "x" })
                return
            end
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local purchaseRod = remotes and remotes:FindFirstChild("PurchaseRod")
            if not (purchaseRod and purchaseRod:IsA("RemoteFunction")) then
                WindUI:Notify({ Title = "Buy Rod", Content = "Remotes.PurchaseRod not found", Icon = "x" })
                return
            end
            local ok, result = pcall(function()
                return purchaseRod:InvokeServer(selectedRodId)
            end)
            if not ok then
                WindUI:Notify({ Title = "Buy Rod", Content = "Invoke failed: " .. tostring(result), Icon = "x" })
                return
            end
            if result and result.IsGamepass and result.GamepassId then
                pcall(function()
                    MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, result.GamepassId)
                end)
                WindUI:Notify({ Title = "Buy Rod", Content = "Game pass purchase prompted", Icon = "check" })
            elseif result and result.Success then
                WindUI:Notify({ Title = "Buy Rod", Content = "Purchase successful", Icon = "check" })
            else
                WindUI:Notify({
                    Title = "Buy Rod",
                    Content = (result and result.Message) or "Purchase failed",
                    Icon = "x",
                })
            end
            task.defer(updateBuyRodDetailParagraph)
        end,
    })

    BuyRodSection:Space()

    BuyRodSection:Button({
        Title = "Refresh rod list",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshRodList(true)
        end,
    })

    ShopTab:Space()

    local BuyBoatSection = ShopTab:Section({
        Title = "Buy Boat",
        Desc = "Boats are read from BoatUI (Body.ScrollingFrame). Use Refresh if the list is empty.",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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
        if BuyBoatDetailParagraph and BuyBoatDetailParagraph.SetDesc then
            BuyBoatDetailParagraph:SetDesc(buildBoatDetailText(selectedBoatId))
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
                BuyBoatDropdown:Set(nil)
            end
        end
        updateBuyBoatDetailParagraph()
        if showNotify then
            WindUI:Notify({
                Title = "Buy Boat",
                Content = (#boatIdList == 0) and "No boats found (open the in-game boat shop once or wait for UI to load)" or ("Found " .. #boatIdList .. " boat(s)"),
                Icon = (#boatIdList == 0) and "x" or "check",
            })
        end
    end

    BuyBoatDropdown = BuyBoatSection:Dropdown({
        Title = "Boat",
        Desc = "Display name, id, and price from the boat shop row (BoatName / Price labels)",
        Flag = "mancing_shop_boatPick",
        Values = boatDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(value)
            selectedBoatId = nil
            if value then
                local idx = table.find(boatDisplayList, value)
                if idx and boatIdList[idx] then
                    selectedBoatId = boatIdList[idx]
                end
            end
            updateBuyBoatDetailParagraph()
        end,
    })

    BuyBoatDetailParagraph = BuyBoatSection:Paragraph({
        Title = "Boat details",
        Desc = "Select a boat from the dropdown to see name, price, and statistics.",
    })

    BuyBoatSection:Button({
        Title = "Buy",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedBoatId or selectedBoatId == "" then
                WindUI:Notify({ Title = "Buy Boat", Content = "Select a boat from the dropdown first", Icon = "x" })
                return
            end
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local purchaseBoat = remotes and remotes:FindFirstChild("PurchaseBoat")
            if not (purchaseBoat and purchaseBoat:IsA("RemoteFunction")) then
                WindUI:Notify({ Title = "Buy Boat", Content = "Remotes.PurchaseBoat not found", Icon = "x" })
                return
            end
            local ok, result = pcall(function()
                return purchaseBoat:InvokeServer(selectedBoatId)
            end)
            if not ok then
                WindUI:Notify({ Title = "Buy Boat", Content = "Invoke failed: " .. tostring(result), Icon = "x" })
                return
            end
            if result and result.IsGamepass and result.GamepassId then
                pcall(function()
                    MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, result.GamepassId)
                end)
                WindUI:Notify({ Title = "Buy Boat", Content = "Game pass purchase prompted", Icon = "check" })
            elseif result and result.Success then
                WindUI:Notify({ Title = "Buy Boat", Content = "Purchase successful", Icon = "check" })
            else
                WindUI:Notify({
                    Title = "Buy Boat",
                    Content = (result and result.Message) or "Purchase failed",
                    Icon = "x",
                })
            end
            task.defer(updateBuyBoatDetailParagraph)
        end,
    })

    BuyBoatSection:Space()

    BuyBoatSection:Button({
        Title = "Refresh boat list",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshBoatList(true)
        end,
    })

    refreshRodList(false)
    refreshBoatList(false)
end

-- */  Teleport Tab  /* --
do
    local TeleportTab = ElementsSection:Tab({
        Title = "Teleport",
        Icon = "solar:folder-2-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    local TeleportSection = TeleportTab:Section({
        Title = "Teleport",
        Desc = "Location = X, Y, Z. Look direction = root LookVector (X, Y, Z); leave blank or 0,0,0 to ignore facing. Get fills both.",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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

    local function teleportCFrameFromInputs(posStr, lookStr): CFrame?
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

    local TeleportInput = TeleportSection:Input({
        Title = "Location",
        Placeholder = "e.g. 100, 5, 200 or 100 5 200",
        Flag = "mancing_tp_location",
        Value = teleportInputValue,
        Callback = function(value)
            teleportInputValue = value
        end
    })

    local TeleportLookInput = TeleportSection:Input({
        Title = "Look direction",
        Desc = "HumanoidRootPart look vector (X, Y, Z). Used with Teleport / Tween / Get.",
        Placeholder = "e.g. 0, 0, -1 or leave empty for position only",
        Flag = "mancing_tp_lookDirection",
        Value = teleportLookInputValue,
        Callback = function(value)
            teleportLookInputValue = value
        end,
    })

    TeleportSection:Button({
        Title = "Get Current Location",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                WindUI:Notify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
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
            WindUI:Notify({
                Title = "Location",
                Content = "Position: " .. text .. " · Look: " .. lookText,
                Icon = "check",
            })
        end
    })

    TeleportSection:Space()

    TeleportSection:Button({
        Title = "Teleport",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                WindUI:Notify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local cf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not cf then
                WindUI:Notify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                    Icon = "x",
                })
                return
            end
            rootPart.CFrame = cf
            local p = cf.Position
            WindUI:Notify({
                Title = "Teleport",
                Content = string.format("Teleported to %.1f, %.1f, %.1f", p.X, p.Y, p.Z),
                Icon = "check",
            })
        end
    })

    TeleportSection:Space()

    local tweenDurationValue = "5"
    TeleportSection:Input({
        Title = "Tween Duration",
        Placeholder = "e.g. 5",
        Flag = "mancing_tp_tweenDurationSec",
        Value = tweenDurationValue,
        Callback = function(value)
            tweenDurationValue = value
        end
    })

    TeleportSection:Button({
        Title = "Tween to Location",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                WindUI:Notify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local targetCf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not targetCf then
                WindUI:Notify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                    Icon = "x",
                })
                return
            end
            local duration = tonumber(tweenDurationValue) or 5
            if duration < 0.1 then duration = 0.1 end
            local tweenInfo = TweenInfo.new(duration)
            local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = targetCf })
            tween:Play()
            local p = targetCf.Position
            WindUI:Notify({
                Title = "Teleport",
                Content = string.format("Tweening to %.1f, %.1f, %.1f (%.1fs)", p.X, p.Y, p.Z, duration),
                Icon = "check",
            })
        end
    })

    -- */  Teleport to Players  /* --
    TeleportTab:Space()

    local TeleportToPlayersSection = TeleportTab:Section({
        Title = "Teleport to Players",
        Desc = "Select a player and teleport to their character",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

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
                if PlayerTeleportDropdown and PlayerTeleportDropdown.Set then PlayerTeleportDropdown:Set(nil) end
            end
        end
        if showNotify then
            WindUI:Notify({ Title = "Teleport", Content = "Player list refreshed (" .. #playerList .. " players)", Icon = "check" })
        end
    end

    PlayerTeleportDropdown = TeleportToPlayersSection:Dropdown({
        Title = "Player",
        Desc = "Select player to teleport to",
        Flag = "mancing_tp_playerPick",
        Values = playerDisplayNames,
        Value = nil,
        AllowNone = true,
        Callback = function(value)
            selectedTeleportPlayer = nil
            if value then
                local idx = table.find(playerDisplayNames, value)
                if idx and playerList[idx] then
                    selectedTeleportPlayer = playerList[idx]
                end
            end
        end
    })

    TeleportToPlayersSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshPlayerList(true)
        end
    })

    TeleportToPlayersSection:Space()

    TeleportToPlayersSection:Button({
        Title = "Teleport",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedTeleportPlayer then
                WindUI:Notify({ Title = "Teleport", Content = "Select a player first", Icon = "x" })
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                WindUI:Notify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local targetChar = selectedTeleportPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then
                WindUI:Notify({ Title = "Teleport", Content = "Target player has no character", Icon = "x" })
                return
            end
            rootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0, 3))
            WindUI:Notify({ Title = "Teleport", Content = "Teleported to " .. (selectedTeleportPlayer.DisplayName or selectedTeleportPlayer.Name), Icon = "check" })
        end
    })
end

-- */  Objects Tab  /* --
do
    local ObjectsTab = ElementsSection:Tab({
        Title = "Objects",
        Icon = "solar:folder-2-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    -- Nested tree: only under Instance types selected in Show Children (see section at top of this tab).
    local OBJECTS_TREE_MAX_DEPTH = 14
    local OBJECTS_TREE_MAX_LINES = 3000
    -- WindUI / Roblox TextLabel can clip very long descriptions; split across extra Paragraphs.
    local OBJECTS_CHILDREN_DESC_MAX_CHARS = 4000
    local OBJECTS_CHILDREN_PARAGRAPH_DESC = "Nested under the types you enable in Show Children (name sort; max depth "
        .. OBJECTS_TREE_MAX_DEPTH
        .. ", max "
        .. OBJECTS_TREE_MAX_LINES
        .. " lines). Long output splits into extra paragraphs (~"
        .. OBJECTS_CHILDREN_DESC_MAX_CHARS
        .. " chars each)."

    -- Multi-select: which ClassNames recurse when listing children (IsA match).
    local OBJECTS_NEST_CLASS_OPTIONS: { string } = {
        "Accessory",
        "Actor",
        "Attachment",
        "Backpack",
        "BillboardGui",
        "BodyColors",
        "Camera",
        "CanvasGroup",
        "Configuration",
        "CornerWedgePart",
        "Folder",
        "Frame",
        "Humanoid",
        "ImageButton",
        "ImageLabel",
        "MeshPart",
        "Model",
        "ModuleScript",
        "Part",
        "PlayerGui",
        "ProximityPrompt",
        "ScreenGui",
        "ScrollingFrame",
        "StarterGear",
        "StarterPack",
        "SurfaceGui",
        "Terrain",
        "TextBox",
        "TextButton",
        "TextLabel",
        "Tool",
        "TrussPart",
        "UnionOperation",
        "VehicleSeat",
        "WedgePart",
    }
    local OBJECTS_NEST_EXPAND_DEFAULT: { string } = {
        "Backpack",
        "BillboardGui",
        "Frame",
        "Folder",
        "PlayerGui",
        "ScreenGui",
    }
    local objectsNestExpandClassSet: { [string]: boolean } = {}

    local function syncObjectsNestExpandClassSetFromDropdownValue(value: any)
        local s: { [string]: boolean } = {}
        if type(value) == "table" then
            for _, item in ipairs(value) do
                local name = (type(item) == "table" and item.Title) or item
                if type(name) == "string" and name ~= "" then
                    s[name] = true
                end
            end
        elseif type(value) == "string" and value ~= "" then
            s[value] = true
        end
        objectsNestExpandClassSet = s
    end

    syncObjectsNestExpandClassSetFromDropdownValue(OBJECTS_NEST_EXPAND_DEFAULT)

    local function splitStringForParagraphChunks(s: string, maxChunk: number): { string }
        if maxChunk < 256 then
            maxChunk = 256
        end
        if s == nil or s == "" then
            return { "" }
        end
        if #s <= maxChunk then
            return { s }
        end
        local chunks: { string } = {}
        local pos = 1
        local n = #s
        while pos <= n do
            local endPos = math.min(pos + maxChunk - 1, n)
            if endPos < n then
                local searchStart = math.max(pos, endPos - 500)
                local cut = 0
                for i = endPos, searchStart, -1 do
                    if string.byte(s, i) == 10 then
                        cut = i
                        break
                    end
                end
                if cut > pos then
                    endPos = cut
                end
            end
            table.insert(chunks, string.sub(s, pos, endPos))
            pos = endPos + 1
        end
        if #chunks == 0 then
            return { s }
        end
        return chunks
    end

    local function clearObjectsTabOverflowParagraphs(refs: { any })
        for i = #refs, 1, -1 do
            local p = refs[i]
            if p and p.Destroy then
                pcall(function()
                    p:Destroy()
                end)
            end
            refs[i] = nil
        end
    end

    local function setNestedChildrenParagraphsWithOverflow(
        section,
        primaryParagraph,
        overflowParagraphRefs: { any },
        text: string?,
        continuationTitleBase: string,
        emptyPlaceholder: string
    )
        clearObjectsTabOverflowParagraphs(overflowParagraphRefs)
        if not (primaryParagraph and primaryParagraph.SetDesc) then
            return
        end
        local body = (text and text ~= "") and text or emptyPlaceholder
        local chunks = splitStringForParagraphChunks(body, OBJECTS_CHILDREN_DESC_MAX_CHARS)
        primaryParagraph:SetDesc(chunks[1] or body)
        for ci = 2, #chunks do
            local newP = section:Paragraph({
                Title = continuationTitleBase .. " (part " .. tostring(ci) .. ")",
                Desc = chunks[ci],
            })
            table.insert(overflowParagraphRefs, newP)
        end
    end

    local function shouldNestChildrenInObjectsTree(inst: Instance): boolean
        if next(objectsNestExpandClassSet) == nil then
            return false
        end
        for className, _ in pairs(objectsNestExpandClassSet) do
            if inst:IsA(className) then
                return true
            end
        end
        return false
    end

    local function buildNestedObjectChildrenListText(root: Instance): string
        local lines = {}

        local function appendChildren(parent: Instance, depth: number, indentStr: string)
            if #lines >= OBJECTS_TREE_MAX_LINES or depth >= OBJECTS_TREE_MAX_DEPTH then
                return
            end
            local children = parent:GetChildren()
            table.sort(children, function(a, b)
                return string.lower(a.Name) < string.lower(b.Name)
            end)
            for _, child in ipairs(children) do
                if #lines >= OBJECTS_TREE_MAX_LINES then
                    table.insert(lines, indentStr .. "... (truncated, max " .. OBJECTS_TREE_MAX_LINES .. " lines)")
                    return
                end
                table.insert(lines, indentStr .. formatInstanceDisplay(child, nil, true))
                local sub = child:GetChildren()
                if #sub > 0 and shouldNestChildrenInObjectsTree(child) then
                    if depth + 1 < OBJECTS_TREE_MAX_DEPTH then
                        appendChildren(child, depth + 1, indentStr .. "  ")
                    else
                        table.insert(lines, indentStr .. "  ... (" .. #sub .. " children, max depth " .. OBJECTS_TREE_MAX_DEPTH .. ")")
                    end
                end
            end
        end

        appendChildren(root, 0, "")
        if #lines == 0 then
            return "(no children)"
        end
        return table.concat(lines, "\n")
    end

    -- WindUI passes the selected entry from Values as-is. Duplicate display strings
    -- would collide on a string-keyed map and break selection; use { Title, Instance }.
    local function buildObjectsServiceDropdownValues(children: { Instance }): { any }
        local displayCounts: { [string]: number } = {}
        local values: { any } = {}
        for _, child in ipairs(children) do
            local display = formatInstanceDisplay(child, nil, true)
            local c = (displayCounts[display] or 0) + 1
            displayCounts[display] = c
            local title = display
            if c > 1 then
                title = display .. "  [" .. child:GetDebugId() .. "]"
            end
            table.insert(values, { Title = title, Instance = child })
        end
        return values
    end

    local function objectsDropdownSelectedInstance(selected: any): Instance?
        if typeof(selected) == "table" then
            local inst = (selected :: any).Instance
            if inst ~= nil and typeof(inst) == "Instance" then
                return inst :: Instance
            end
        end
        return nil
    end

    local ShowChildrenSection = ObjectsTab:Section({
        Title = "Show Children",
        Desc = "Multi-select Instance class names. The nested children list expands one level under any child that matches any selected type (Roblox IsA). Default: Backpack, Folder, PlayerGui, ScreenGui, BillboardGui.",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local ObjectsNestClassesDropdown
    do
        local nestDefaultCopy: { string } = {}
        for _, v in ipairs(OBJECTS_NEST_EXPAND_DEFAULT) do
            table.insert(nestDefaultCopy, v)
        end
        ObjectsNestClassesDropdown = ShowChildrenSection:Dropdown({
            Title = "Types to expand in nested tree",
            Desc = "Applies to all Children (nested) views in this tab.",
            Flag = "mancing_objects_showChildrenTypes",
            Values = OBJECTS_NEST_CLASS_OPTIONS,
            Value = nestDefaultCopy,
            Multi = true,
            AllowNone = true,
            SearchBarEnabled = true,
            Callback = function(value)
                syncObjectsNestExpandClassSetFromDropdownValue(value)
            end,
        })
    end
    if ObjectsNestClassesDropdown and ObjectsNestClassesDropdown.Value ~= nil then
        syncObjectsNestExpandClassSetFromDropdownValue(ObjectsNestClassesDropdown.Value)
    end

    ObjectsTab:Space()

    local ReplicatedStorageSection = ObjectsTab:Section({
        Title = "ReplicatedStorage",
        Desc = "All direct children of ReplicatedStorage (key = Name, value = ClassName)",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local rsDisplayList = {}
    local ReplicatedStorageDropdown
    local ReplicatedStorageChildrenParagraph
    local rsChildrenOverflowParagraphs = {}

    local function refreshReplicatedStorageList()
        rsDisplayList = buildObjectsServiceDropdownValues(ReplicatedStorage:GetChildren())
        if ReplicatedStorageDropdown and ReplicatedStorageDropdown.Refresh then
            ReplicatedStorageDropdown:Refresh(rsDisplayList)
        end
        WindUI:Notify({ Title = "ReplicatedStorage", Content = "Listed " .. #rsDisplayList .. " objects", Icon = "check" })
    end

    ReplicatedStorageDropdown = ReplicatedStorageSection:Dropdown({
        Title = "ReplicatedStorage (key = value)",
        Desc = "Select an object to see its children listed below",
        Values = rsDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(selected)
            if not selected then
                setNestedChildrenParagraphsWithOverflow(
                    ReplicatedStorageSection,
                    ReplicatedStorageChildrenParagraph,
                    rsChildrenOverflowParagraphs,
                    nil,
                    "Children (nested)",
                    "Select an object above to list its children"
                )
                return
            end
            local inst = objectsDropdownSelectedInstance(selected)
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                ReplicatedStorageSection,
                ReplicatedStorageChildrenParagraph,
                rsChildrenOverflowParagraphs,
                text,
                "Children (nested)",
                "Select an object above to list its children"
            )
        end
    })

    ReplicatedStorageChildrenParagraph = ReplicatedStorageSection:Paragraph({
        Title = "Children (nested)",
        Desc = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    ReplicatedStorageSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshReplicatedStorageList()
        end
    })

    ObjectsTab:Space()

    local PlayersServiceSection = ObjectsTab:Section({
        Title = "Players",
        Desc = "Players service: all Player instances (key = Name, value = ClassName)",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local plrsDisplayList = {}
    local PlayersServiceDropdown
    local PlayersServiceChildrenParagraph
    local plrsChildrenOverflowParagraphs = {}

    local function refreshPlayersServiceList()
        plrsDisplayList = buildObjectsServiceDropdownValues(Players:GetChildren())
        if PlayersServiceDropdown and PlayersServiceDropdown.Refresh then
            PlayersServiceDropdown:Refresh(plrsDisplayList)
        end
        WindUI:Notify({ Title = "Players", Content = "Listed " .. #plrsDisplayList .. " players", Icon = "check" })
    end

    PlayersServiceDropdown = PlayersServiceSection:Dropdown({
        Title = "Players (key = value)",
        Desc = "Select a player to see their top-level children listed below",
        Values = plrsDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(selected)
            if not selected then
                setNestedChildrenParagraphsWithOverflow(
                    PlayersServiceSection,
                    PlayersServiceChildrenParagraph,
                    plrsChildrenOverflowParagraphs,
                    nil,
                    "Children (nested)",
                    "Select a player above to list their children"
                )
                return
            end
            local inst = objectsDropdownSelectedInstance(selected)
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                PlayersServiceSection,
                PlayersServiceChildrenParagraph,
                plrsChildrenOverflowParagraphs,
                text,
                "Children (nested)",
                "Select a player above to list their children"
            )
        end
    })

    PlayersServiceChildrenParagraph = PlayersServiceSection:Paragraph({
        Title = "Children (nested)",
        Desc = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    PlayersServiceSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshPlayersServiceList()
        end
    })

    ObjectsTab:Space()

    local LocalPlayerSection = ObjectsTab:Section({
        Title = "Local Player",
        Desc = "All direct children of Players.LocalPlayer (key = Name, value = ClassName)",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local lpDisplayList = {}
    local LocalPlayerDropdown
    local LocalPlayerChildrenParagraph
    local lpChildrenOverflowParagraphs = {}

    local function refreshLocalPlayerList()
        local localPlayer = Players.LocalPlayer
        lpDisplayList = buildObjectsServiceDropdownValues(localPlayer:GetChildren())
        if LocalPlayerDropdown and LocalPlayerDropdown.Refresh then
            LocalPlayerDropdown:Refresh(lpDisplayList)
        end
        WindUI:Notify({ Title = "Local Player", Content = "Listed " .. #lpDisplayList .. " objects", Icon = "check" })
    end

    LocalPlayerDropdown = LocalPlayerSection:Dropdown({
        Title = "Local Player (key = value)",
        Desc = "Select an object to see its children listed below",
        Values = lpDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(selected)
            if not selected then
                setNestedChildrenParagraphsWithOverflow(
                    LocalPlayerSection,
                    LocalPlayerChildrenParagraph,
                    lpChildrenOverflowParagraphs,
                    nil,
                    "Children (nested)",
                    "Select an object above to list its children"
                )
                return
            end
            local inst = objectsDropdownSelectedInstance(selected)
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                LocalPlayerSection,
                LocalPlayerChildrenParagraph,
                lpChildrenOverflowParagraphs,
                text,
                "Children (nested)",
                "Select an object above to list their children"
            )
        end
    })

    LocalPlayerChildrenParagraph = LocalPlayerSection:Paragraph({
        Title = "Children (nested)",
        Desc = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    LocalPlayerSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshLocalPlayerList()
        end
    })

    ObjectsTab:Space()

    local WorkspaceSection = ObjectsTab:Section({
        Title = "Workspace",
        Desc = "All direct children of Workspace (key = Name, value = ClassName)",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local wsDisplayList = {}
    local WorkspaceDropdown
    local WorkspaceChildrenParagraph
    local wsChildrenOverflowParagraphs = {}

    local function refreshWorkspaceList()
        wsDisplayList = buildObjectsServiceDropdownValues(Workspace:GetChildren())
        if WorkspaceDropdown and WorkspaceDropdown.Refresh then
            WorkspaceDropdown:Refresh(wsDisplayList)
        end
        WindUI:Notify({ Title = "Workspace", Content = "Listed " .. #wsDisplayList .. " objects", Icon = "check" })
    end

    WorkspaceDropdown = WorkspaceSection:Dropdown({
        Title = "Workspace (key = value)",
        Desc = "Select an object to see its children listed below",
        Values = wsDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(selected)
            if not selected then
                setNestedChildrenParagraphsWithOverflow(
                    WorkspaceSection,
                    WorkspaceChildrenParagraph,
                    wsChildrenOverflowParagraphs,
                    nil,
                    "Children (nested)",
                    "Select an object above to list its children"
                )
                return
            end
            local inst = objectsDropdownSelectedInstance(selected)
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                WorkspaceSection,
                WorkspaceChildrenParagraph,
                wsChildrenOverflowParagraphs,
                text,
                "Children (nested)",
                "Select an object above to list its children"
            )
        end
    })

    WorkspaceChildrenParagraph = WorkspaceSection:Paragraph({
        Title = "Children (nested)",
        Desc = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    WorkspaceSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshWorkspaceList()
        end
    })

    ObjectsTab:Space()

    local RunServiceSection = ObjectsTab:Section({
        Title = "RunService",
        Desc = "All direct children of RunService (key = Name, value = ClassName)",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local runServiceDisplayList = {}
    local RunServiceDropdown
    local RunServiceChildrenParagraph
    local runServiceChildrenOverflowParagraphs = {}

    local RUNSERVICE_SIGNAL_NAMES = {
        "Heartbeat",
        "Stepped",
        "RenderStepped",
        "PreSimulation",
        "PostSimulation",
        "PreAnimation",
        "PreRender",
        "Misprediction",
    }

    local RUNSERVICE_METHOD_NAMES = {
        "BindToRenderStep(name, priority, function)",
        "UnbindFromRenderStep(name)",
        "IsServer()",
        "IsClient()",
        "IsStudio()",
        "Pause()",
        "Run()",
        "Stop()",
        "GetCoreScriptVersion()",
        "GetRobloxVersion()",
        "Set3dRenderingEnabled(bool)",
    }

    local function refreshRunServiceList()
        runServiceDisplayList = buildObjectsServiceDropdownValues(RunService:GetChildren())
        if RunServiceDropdown and RunServiceDropdown.Refresh then
            RunServiceDropdown:Refresh(runServiceDisplayList)
        end
        WindUI:Notify({ Title = "RunService", Content = "Listed " .. #runServiceDisplayList .. " objects", Icon = "check" })
    end

    RunServiceDropdown = RunServiceSection:Dropdown({
        Title = "RunService (key = value)",
        Desc = "Select an object to see its children listed below",
        Values = runServiceDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(selected)
            if not selected then
                setNestedChildrenParagraphsWithOverflow(
                    RunServiceSection,
                    RunServiceChildrenParagraph,
                    runServiceChildrenOverflowParagraphs,
                    nil,
                    "Children (nested)",
                    "Select an object above to list its children"
                )
                return
            end
            local inst = objectsDropdownSelectedInstance(selected)
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                RunServiceSection,
                RunServiceChildrenParagraph,
                runServiceChildrenOverflowParagraphs,
                text,
                "Children (nested)",
                "Select an object above to list its children"
            )
        end
    })

    RunServiceChildrenParagraph = RunServiceSection:Paragraph({
        Title = "Children (nested)",
        Desc = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    RunServiceSection:Paragraph({
        Title = "Signals (events, not children)",
        Desc = table.concat(RUNSERVICE_SIGNAL_NAMES, "\n"),
    })

    RunServiceSection:Paragraph({
        Title = "Useful API methods",
        Desc = table.concat(RUNSERVICE_METHOD_NAMES, "\n"),
    })

    RunServiceSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshRunServiceList()
        end
    })

    ObjectsTab:Space()

    local MarketplaceServiceSection = ObjectsTab:Section({
        Title = "MarketplaceService",
        Desc = "All direct children of MarketplaceService (key = Name, value = ClassName)",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local marketplaceServiceDisplayList = {}
    local MarketplaceServiceDropdown
    local MarketplaceServiceChildrenParagraph
    local marketplaceChildrenOverflowParagraphs = {}

    local MARKETPLACE_SIGNAL_NAMES = {
        "PromptProductPurchaseFinished(userId, productId, isPurchased)",
        "PromptPurchaseFinished(player, assetId, isPurchased)",
        "PromptGamePassPurchaseFinished(player, gamePassId, wasPurchased)",
        "PromptBundlePurchaseFinished(player, bundleId, wasPurchased)",
        "PromptSubscriptionPurchaseFinished(player, subscriptionId, wasPurchased)",
        "PromptPremiumPurchaseFinished()",
        "ClientLuaDialogRequested()",
    }

    local MARKETPLACE_METHOD_NAMES = {
        "PromptProductPurchase(player, productId, equipIfPurchased?)",
        "PromptPurchase(player, assetId, equipIfPurchased?)",
        "PromptGamePassPurchase(player, gamePassId)",
        "PromptBundlePurchase(player, bundleId)",
        "PromptPremiumPurchase(player)",
        "GetProductInfo(assetId, infoType?)",
        "UserOwnsGamePassAsync(userId, gamePassId)",
        "PlayerOwnsAsset(player, assetId)",
    }

    local function refreshMarketplaceServiceList()
        marketplaceServiceDisplayList = buildObjectsServiceDropdownValues(MarketplaceService:GetChildren())
        if MarketplaceServiceDropdown and MarketplaceServiceDropdown.Refresh then
            MarketplaceServiceDropdown:Refresh(marketplaceServiceDisplayList)
        end
        WindUI:Notify({
            Title = "MarketplaceService",
            Content = "Listed " .. #marketplaceServiceDisplayList .. " objects",
            Icon = "check",
        })
    end

    MarketplaceServiceDropdown = MarketplaceServiceSection:Dropdown({
        Title = "MarketplaceService (key = value)",
        Desc = "Select an object to see its children listed below",
        Values = marketplaceServiceDisplayList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(selected)
            if not selected then
                setNestedChildrenParagraphsWithOverflow(
                    MarketplaceServiceSection,
                    MarketplaceServiceChildrenParagraph,
                    marketplaceChildrenOverflowParagraphs,
                    nil,
                    "Children (nested)",
                    "Select an object above to list its children"
                )
                return
            end
            local inst = objectsDropdownSelectedInstance(selected)
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                MarketplaceServiceSection,
                MarketplaceServiceChildrenParagraph,
                marketplaceChildrenOverflowParagraphs,
                text,
                "Children (nested)",
                "Select an object above to list its children"
            )
        end
    })

    MarketplaceServiceChildrenParagraph = MarketplaceServiceSection:Paragraph({
        Title = "Children (nested)",
        Desc = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    MarketplaceServiceSection:Paragraph({
        Title = "Signals (events, not children)",
        Desc = table.concat(MARKETPLACE_SIGNAL_NAMES, "\n"),
    })

    MarketplaceServiceSection:Paragraph({
        Title = "Useful API methods",
        Desc = table.concat(MARKETPLACE_METHOD_NAMES, "\n"),
    })

    MarketplaceServiceSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshMarketplaceServiceList()
        end
    })

end

-- */  Config Tab  /* --
do
    local ConfigTab = ElementsSection:Tab({
        Title = "Config",
        Icon = "solar:file-text-bold",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    local ConfigManagementSection = ConfigTab:Section({
        Title = "Config management",
        Desc = "Named profiles in WindUI/" .. tostring(Window.Folder or "sempatpanick") .. "/config (executor file APIs). Main, Shop, and Teleport options use Flags. Event tab: Limited Event Auto Teleport uses a Flag; Galatama actions are not saved.",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local configMgmtName = ""
    local savedConfigList = {}
    local selectedSavedConfigName = nil
    local SavedConfigsDropdown
    local ConfigNameInput
    local autoLoadPickerSelection = nil
    local AutoLoadSavedDropdown

    local function sanitizeConfigName(raw)
        local s = tostring(raw or ""):gsub("^%s+", ""):gsub("%s+$", "")
        s = s:gsub("[/\\]", "")
        return s
    end

    local function getConfigManager()
        local cm = Window.ConfigManager
        if cm == false or cm == nil then
            return nil
        end
        return cm
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
                WindUI:Notify({
                    Title = "Config",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                    Icon = "x",
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
                AutoLoadSavedDropdown:Set(nil)
            end
        end
        if selectedSavedConfigName and not table.find(savedConfigList, selectedSavedConfigName) then
            selectedSavedConfigName = nil
            if SavedConfigsDropdown and SavedConfigsDropdown.Select then
                SavedConfigsDropdown:Select(nil)
            end
            if SavedConfigsDropdown and SavedConfigsDropdown.Set then
                SavedConfigsDropdown:Set(nil)
            end
        end
        if showNotify then
            WindUI:Notify({
                Title = "Config",
                Content = "Found " .. tostring(#savedConfigList) .. " saved profile(s).",
                Icon = "check",
            })
        end
    end

    ConfigNameInput = ConfigManagementSection:Input({
        Title = "Config name",
        Desc = "File name without .json",
        Placeholder = "e.g. main or pvp",
        Value = configMgmtName,
        Callback = function(value)
            configMgmtName = sanitizeConfigName(value)
        end,
    })

    SavedConfigsDropdown = ConfigManagementSection:Dropdown({
        Title = "Config Saved",
        Desc = "Profiles on disk; choosing one fills Config name. Delete Config removes the selected entry.",
        Values = savedConfigList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(value)
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
    local CONFIG_SEQ_FLAG_AUTO_SELL = "mancing_main_autoSell"
    local CONFIG_SEQ_FLAG_TELEPORT = "mancing_main_teleportToLocation"
    local CONFIG_SEQ_FLAG_LIMITED = "mancing_event_limitedAutoTeleport"

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
            AutoLoadSavedDropdown:Set(persisted)
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
        Window:SetCurrentConfig(cfg)
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
        WindUI:Notify({
            Title = "Config",
            Content = "Auto-loaded \"" .. name .. "\"",
            Icon = "check",
        })
    end

    ConfigManagementSection:Space()

    local ConfigSaveRefreshGroup = ConfigManagementSection:Group({})
    ConfigSaveRefreshGroup:Button({
        Title = "Refresh Config",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshSavedConfigDropdowns(true)
        end,
    })
    ConfigSaveRefreshGroup:Space()
    ConfigSaveRefreshGroup:Button({
        Title = "Save Config",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local cm = getConfigManager()
            if not cm then
                WindUI:Notify({
                    Title = "Config",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                    Icon = "x",
                })
                return
            end
            local name = sanitizeConfigName(configMgmtName)
            if name == "" then
                WindUI:Notify({ Title = "Config", Content = "Enter a config name first", Icon = "x" })
                return
            end
            local cfg = getConfigObject(cm, name)
            Window:SetCurrentConfig(cfg)
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
                WindUI:Notify({ Title = "Config", Content = "Save failed: " .. tostring(err), Icon = "x" })
                return
            end
            refreshSavedConfigDropdowns(false)
            WindUI:Notify({ Title = "Config", Content = "Saved \"" .. name .. "\"", Icon = "check" })
        end,
    })

    local ConfigLoadDeleteGroup = ConfigManagementSection:Group({})
    ConfigLoadDeleteGroup:Button({
        Title = "Load Config",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local cm = getConfigManager()
            if not cm then
                WindUI:Notify({
                    Title = "Config",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                    Icon = "x",
                })
                return
            end
            local name = sanitizeConfigName(configMgmtName)
            if name == "" then
                WindUI:Notify({ Title = "Config", Content = "Enter or select a config name first", Icon = "x" })
                return
            end
            local cfg = getConfigObject(cm, name)
            Window:SetCurrentConfig(cfg)
            local pok, loadResult, loadErr = pcall(function()
                return cfg:Load()
            end)
            if not pok then
                WindUI:Notify({ Title = "Config", Content = "Load failed: " .. tostring(loadResult), Icon = "x" })
                return
            end
            if loadResult == false then
                WindUI:Notify({
                    Title = "Config",
                    Content = type(loadErr) == "string" and loadErr or "Config file not found or invalid",
                    Icon = "x",
                })
                return
            end
            scheduleSequentialConfigLoadAfterProfile(cm, cfg, name)
            WindUI:Notify({ Title = "Config", Content = "Loaded \"" .. name .. "\"", Icon = "check" })
        end,
    })
    ConfigLoadDeleteGroup:Space()
    ConfigLoadDeleteGroup:Button({
        Title = "Delete Config",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local cm = getConfigManager()
            if not cm then
                WindUI:Notify({
                    Title = "Config",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                    Icon = "x",
                })
                return
            end
            if not selectedSavedConfigName or selectedSavedConfigName == "" then
                WindUI:Notify({
                    Title = "Config",
                    Content = "Select a config to delete",
                    Icon = "x",
                })
                return
            end
            local name = sanitizeConfigName(selectedSavedConfigName)
            if name == "" then
                WindUI:Notify({
                    Title = "Config",
                    Content = "Select a config to delete",
                    Icon = "x",
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
                        AutoLoadSavedDropdown:Set(nil)
                    end
                end
                selectedSavedConfigName = nil
                if SavedConfigsDropdown and SavedConfigsDropdown.Select then
                    SavedConfigsDropdown:Select(nil)
                end
                if SavedConfigsDropdown and SavedConfigsDropdown.Set then
                    SavedConfigsDropdown:Set(nil)
                end
                if sanitizeConfigName(configMgmtName) == name then
                    configMgmtName = ""
                    if ConfigNameInput and ConfigNameInput.Set then
                        ConfigNameInput:Set("")
                    elseif ConfigNameInput and ConfigNameInput.SetValue then
                        ConfigNameInput:SetValue("")
                    end
                end
                WindUI:Notify({
                    Title = "Config",
                    Content = type(msg) == "string" and msg or ("Deleted \"" .. name .. "\""),
                    Icon = "check",
                })
            else
                WindUI:Notify({
                    Title = "Config",
                    Content = type(msg) == "string" and msg or "Delete failed",
                    Icon = "x",
                })
            end
        end,
    })

    ConfigTab:Space()

    local AutoLoadSection = ConfigTab:Section({
        Title = "Auto Load",
        Desc = "Set stores which profile loads automatically on the next script run (mancing_indo_autoload.json next to your WindUI configs).",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    AutoLoadSavedDropdown = AutoLoadSection:Dropdown({
        Title = "Config Saved",
        Desc = "Choose a profile, then Set. Refresh lists from Config management if empty.",
        Values = savedConfigList,
        Value = nil,
        AllowNone = true,
        SearchBarEnabled = true,
        Callback = function(value)
            autoLoadPickerSelection = (value and value ~= "") and value or nil
        end,
    })

    AutoLoadSection:Space()

    local AutoLoadSetResetGroup = AutoLoadSection:Group({})
    AutoLoadSetResetGroup:Button({
        Title = "Set",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not autoLoadPickerSelection or autoLoadPickerSelection == "" then
                WindUI:Notify({
                    Title = "Auto Load",
                    Content = "Select a config in Config Saved first",
                    Icon = "x",
                })
                return
            end
            local cm = getConfigManager()
            if not cm then
                WindUI:Notify({
                    Title = "Auto Load",
                    Content = "Config system unavailable (Studio or missing file APIs).",
                    Icon = "x",
                })
                return
            end
            local pick = sanitizeConfigName(autoLoadPickerSelection)
            if pick == "" or not table.find(savedConfigList, pick) then
                WindUI:Notify({
                    Title = "Auto Load",
                    Content = "Selected profile is not in the list (try Refresh Config)",
                    Icon = "x",
                })
                return
            end
            if not isfile or not isfile(cm.Path .. pick .. ".json") then
                WindUI:Notify({
                    Title = "Auto Load",
                    Content = "That config file is not on disk yet (Save Config first)",
                    Icon = "x",
                })
                return
            end
            if not writeAutoLoadPersistedName(pick) then
                WindUI:Notify({ Title = "Auto Load", Content = "Failed to write autoload file", Icon = "x" })
                return
            end
            WindUI:Notify({
                Title = "Auto Load",
                Content = "Next run will load \"" .. pick .. "\"",
                Icon = "check",
            })
        end,
    })
    AutoLoadSetResetGroup:Space()
    AutoLoadSetResetGroup:Button({
        Title = "Reset",
        Justify = "Center",
        Icon = "",
        Callback = function()
            writeAutoLoadPersistedName("")
            autoLoadPickerSelection = nil
            if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Select then
                AutoLoadSavedDropdown:Select(nil)
            end
            if AutoLoadSavedDropdown and AutoLoadSavedDropdown.Set then
                AutoLoadSavedDropdown:Set(nil)
            end
            WindUI:Notify({
                Title = "Auto Load",
                Content = "Auto-load on startup disabled",
                Icon = "check",
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
