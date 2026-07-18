local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local TweenService = game:GetService("TweenService")

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
        Content = opts.Content or "",
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

local function stripSourceBom(source)
    if type(source) == "string" and source:byte(1) == 0xEF and source:byte(2) == 0xBB and source:byte(3) == 0xBF then
        return source:sub(4)
    end
    return source
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
    source = stripSourceBom(source)

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
    source = stripSourceBom(source)

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
    source = stripSourceBom(source)

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
    source = stripSourceBom(source)

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
    Name = "sempatpanick | Expedition Antartica",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Expedition Antartica",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "sempatpanick",
        FileName = "expedition_antartica",
    },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
})

-- */  Game module + shared helpers  /* --
local loadFunctionModule
do
    local ok, loader = pcall(require, "../../functions/load_module")
    if ok and type(loader) == "function" then
        loadFunctionModule = loader
    else
        local okGet, source = pcall(function()
            return game:HttpGet(baseURL .. "/functions/load_module.lua")
        end)
        assert(okGet and type(source) == "string", "[expedition_antartica] failed to load functions/load_module")
        source = stripSourceBom(source)
        local chunk = (loadstring or load)(source, "functions/load_module")
        loadFunctionModule = chunk()
    end
end

local playerMod = loadFunctionModule("player/character")
local formatMod = loadFunctionModule("instance/format")
local coordsMod = loadFunctionModule("string/coords")
local gameMod = loadFunctionModule("games/expedition_antartica")

local getLocalCharacterParts = playerMod.getLocalCharacterParts
local getLocalRootPart = function()
    return playerMod.getLocalRootPart(Players)
end
local parsePositionString = coordsMod.parsePositionString

local function notify(title, content, icon)
    mountNotify({ Title = title, Content = content or "", Icon = icon or "check" })
end

function formatValueForDisplay(val)
    return formatMod.formatValueForDisplay(val)
end

function formatGuiInstanceTextForDisplay(inst)
    return formatMod.formatGuiInstanceTextForDisplay(inst)
end

function formatInstanceDisplay(inst, isShowDataType, isShowLocation)
    return formatMod.formatInstanceDisplay(inst, isShowDataType, isShowLocation)
end

-- */  Local Player Tab  /* --
createLocalPlayerTab(Window, mountNotify)

-- */  Automation Tab  /* --
do
    local AutomationTab = Window:CreateTab("Automation", 4483362458)
    local campNames = gameMod.getCampNames()
    local checkpoint = gameMod.checkpoint

    AutomationTab:CreateSection("Auto Camp")
    local selectedCampName = (#campNames > 0) and campNames[1] or nil
    local tweenDurationSeconds = gameMod.getDefaultDurationForCamp(selectedCampName or campNames[1])
    local autoCampTweenRef = { tween = nil }
    local autoCampCancelRequested = false

    local DurationInput = AutomationTab:CreateInput({
        Ext = true,
        Name = "Tween Duration (seconds)",
        PlaceholderText = "e.g. 5",
        Flag = "expedition_auto_camp_duration",
        CurrentValue = tweenDurationSeconds,
        Callback = function(value)
            tweenDurationSeconds = value
        end,
    })

    AutomationTab:CreateDropdown({
        Ext = true,
        Name = "Camp",
        Flag = "expedition_auto_camp_select",
        Options = campNames,
        CurrentOption = { selectedCampName },
        Callback = function(opts)
            local value = type(opts) == "table" and opts[1] or opts
            selectedCampName = value
            local defaultDur = gameMod.getDefaultDurationForCamp(value)
            tweenDurationSeconds = defaultDur
            if DurationInput then
                if DurationInput.Set then DurationInput:Set(defaultDur) end
                if DurationInput.SetValue then DurationInput:SetValue(defaultDur) end
            end
        end,
    })

    AutomationTab:CreateButton({
        Name = "Auto Teleport",
        Ext = true,
        Callback = function()
            local _, rootPart = getLocalCharacterParts()
            if not rootPart then
                notify("Auto Camp", "Character not loaded", "x")
                return
            end
            if not selectedCampName then
                notify("Auto Camp", "Select a camp first", "x")
                return
            end
            local selectedCamp = gameMod.findCampByName(selectedCampName)
            if not selectedCamp then
                notify("Auto Camp", "Camp not found", "x")
                return
            end
            autoCampCancelRequested = false
            notify("Auto Camp", "Moving to " .. selectedCampName .. "...")
            task.spawn(function()
                gameMod.runCampRoute(
                    selectedCamp,
                    rootPart,
                    tonumber(tweenDurationSeconds) or 5,
                    function()
                        return autoCampCancelRequested
                    end,
                    autoCampTweenRef
                )
            end)
        end,
    })

    AutomationTab:CreateButton({
        Name = "Stop Auto Camp",
        Ext = true,
        Callback = function()
            autoCampCancelRequested = true
            if autoCampTweenRef.tween then
                autoCampTweenRef.tween:Cancel()
                autoCampTweenRef.tween = nil
            end
            notify("Auto Camp", "Stopped", "x")
        end,
    })

    AutomationTab:CreateSection("Teleport to Camp")
    local teleportCampNames = {}
    for _, camp in ipairs(gameMod.teleportCamps) do
        table.insert(teleportCampNames, camp.name)
    end
    local selectedTeleportCamp = teleportCampNames[1]

    AutomationTab:CreateDropdown({
        Ext = true,
        Name = "Camp",
        Flag = "expedition_teleport_camp_select",
        Options = teleportCampNames,
        CurrentOption = { selectedTeleportCamp },
        Callback = function(opts)
            local value = type(opts) == "table" and opts[1] or opts
            selectedTeleportCamp = value
        end,
    })

    AutomationTab:CreateButton({
        Name = "Teleport",
        Ext = true,
        Callback = function()
            local rootPart = getLocalRootPart()
            if not rootPart then
                notify("Teleport to Camp", "Character not loaded", "x")
                return
            end
            if not selectedTeleportCamp then
                notify("Teleport to Camp", "Select a camp first", "x")
                return
            end
            local posStr = nil
            for _, camp in ipairs(gameMod.teleportCamps) do
                if camp.name == selectedTeleportCamp then
                    posStr = camp.position
                    break
                end
            end
            if not posStr then
                notify("Teleport to Camp", "Camp not found", "x")
                return
            end
            local targetPos = parsePositionString(posStr)
            if not targetPos then
                notify("Teleport to Camp", "Invalid position", "x")
                return
            end
            rootPart.CFrame = CFrame.new(targetPos)
            notify("Teleport to Camp", "Teleported to " .. selectedTeleportCamp)
        end,
    })

    local AutoSummitCpParagraph
    local function updateAutoSummitCpParagraph()
        if not AutoSummitCpParagraph then
            return
        end
        if AutoSummitCpParagraph.Set then
            AutoSummitCpParagraph:Set({
                Title = "Current camp / checkpoint",
                Content = checkpoint.getStatusDescription(Players.LocalPlayer),
            })
        end
    end

    checkpoint.attachListeners(updateAutoSummitCpParagraph)

    local autoSummit = gameMod.createAutoSummit({
        notify = notify,
        onCheckpointUpdate = updateAutoSummitCpParagraph,
    })

    AutomationTab:CreateSection("Auto Summit")
    AutoSummitCpParagraph = AutomationTab:CreateParagraph({
        Title = "Current camp / checkpoint",
        Content = "CHECKPOINT: -\nProgress #0 - Next leg: Camp 1",
    })
    task.defer(updateAutoSummitCpParagraph)

    local SummitQtyInput = AutomationTab:CreateInput({
        Ext = true,
        Name = "Qty of summit",
        PlaceholderText = "Empty = unlimited",
        Flag = "expedition_auto_summit_qty",
        CurrentValue = "",
        Callback = function(value)
            autoSummit.setQty(value)
        end,
    })

    AutomationTab:CreateToggle({
        Ext = true,
        Name = "Auto Summit",
        Flag = "expedition_auto_summit",
        CurrentValue = false,
        Callback = function(enabled)
            if enabled then
                autoSummit.start(SummitQtyInput and SummitQtyInput.CurrentValue or "", function(qtyStr)
                    if SummitQtyInput then
                        if SummitQtyInput.Set then SummitQtyInput:Set(qtyStr) end
                        if SummitQtyInput.SetValue then SummitQtyInput:SetValue(qtyStr) end
                    end
                end)
            else
                autoSummit.stop()
            end
        end,
    })

    AutomationTab:CreateSection("Auto Drink")
    local autoDrink = gameMod.createAutoDrink()

    AutomationTab:CreateInput({
        Ext = true,
        Name = "Minimum Hydration",
        PlaceholderText = "50",
        Flag = "expedition_auto_drink_minHydration",
        CurrentValue = "50",
        Callback = function(value)
            autoDrink.setMinHydration(value)
        end,
    })

    AutomationTab:CreateToggle({
        Ext = true,
        Name = "Auto Drink",
        Flag = "expedition_auto_drink",
        CurrentValue = false,
        Callback = function(enabled)
            if enabled then
                autoDrink.start()
            else
                autoDrink.stop()
            end
        end,
    })
end

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, {
    ext = true,
    notifyIcons = true,
    walkToLocation = true,
    playerSearch = true,
    playerNoneOption = true,
})

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, { replicatedStorage = ReplicatedStorage })


-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, {
    gamePath = "sempatpanick/expedition_antartica",
})

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/expedition_antartica",
    rayfieldLibrary = RayfieldLibrary,
})
