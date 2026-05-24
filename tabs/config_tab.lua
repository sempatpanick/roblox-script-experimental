--[[
  Config tab module for Rayfield scripts.
  Loaded from: https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/tabs/config_tab.lua
  Usage:
    createConfigTab(Window, mountNotify, options)
  options (required):
    configDir = "sempatpanick/my_game"
    rayfieldLibrary = RayfieldLibrary
  options (optional):
    gameLabel = "My Game"              -- warn() prefix; defaults from configDir slug
    autoloadFile = "my_game_autoload.json"
    namePlaceholder = "e.g. main"
    onCollectExtra = function(data) end
    onApplyFlag = function(flagName, saved) return saved end
    onApplyAfter = function(data) end
    applyLastFlags = { "flag_a", "flag_b" }
    reservedKeys = { _farm_position = true }
    onApplyReserved = function(data) end
    sequentialLoad = {                 -- mancing_indo WindUI ordered load
      flags = { "mancing_main_autoSell", ... },
      bridge = configLoadBridge,
      warnLabel = "Mancing Indo",
    }
    onAfterLoad = function(name, cfg, cm) end
]]
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
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
    if dropdown.Select then
        pcall(function()
            dropdown:Select(nil)
        end)
    end
    if type(dropdown.CurrentOption) == "table" then
        table.clear(dropdown.CurrentOption)
    end
end
local function slugFromConfigDir(configDir)
    local slug = tostring(configDir or ""):gsub("\\", "/"):match("([^/]+)$")
    return slug or "config"
end
local function createConfigTab(windowRef, notifyFn, options)
    options = options or {}
    local mountNotify = notifyFn
    local RayfieldLibrary = options.rayfieldLibrary
    local CONFIG_DIR = options.configDir
    if type(CONFIG_DIR) ~= "string" or CONFIG_DIR == "" then
        warn("[Config Tab] configDir is required")
        return
    end
    if not RayfieldLibrary then
        warn("[Config Tab] rayfieldLibrary is required")
        return
    end
    local slug = slugFromConfigDir(CONFIG_DIR)
    local gameLabel = options.gameLabel or slug:gsub("_", " ")
    local AUTOLOAD_FILE = options.autoloadFile or (slug .. "_autoload.json")
    local namePlaceholder = options.namePlaceholder or "e.g. main"
    local reservedKeys = options.reservedKeys or {}
    local applyLastFlags = options.applyLastFlags
    local applyLastSet = {}
    if type(applyLastFlags) == "table" then
        for _, flagName in ipairs(applyLastFlags) do
            applyLastSet[flagName] = true
        end
    end
    local ConfigTab = windowRef:CreateTab("Config", 4483362458)
    ConfigTab:CreateSection("Config management")
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
                if value == nil then
                    value = flagObj.CurrentKeybind
                end
                if value == nil then
                    value = flagObj.CurrentOption
                end
                if value == nil then
                    value = flagObj.Color
                end
                if typeof(value) == "Color3" then
                    value = encodeColor3(value)
                end
            end
            data[flagName] = value
        end
        if type(options.onCollectExtra) == "function" then
            options.onCollectExtra(data)
        end
        return data
    end
    local function applySingleFlag(flagName, saved)
        if reservedKeys[flagName] then
            return
        end
        local flagObj = RayfieldLibrary.Flags and RayfieldLibrary.Flags[flagName]
        if not flagObj or type(flagObj.Set) ~= "function" or saved == nil then
            return
        end
        if type(options.onApplyFlag) == "function" then
            saved = options.onApplyFlag(flagName, saved)
            if saved == nil then
                return
            end
        end
        local c = decodeColor3(saved)
        pcall(function()
            flagObj:Set(c or saved)
        end)
    end
    local function applyConfigData(data)
        if type(data) ~= "table" then
            return false
        end
        for flagName, _ in pairs(data) do
            if not reservedKeys[flagName] and not applyLastSet[flagName] then
                applySingleFlag(flagName, data[flagName])
            end
        end
        if type(applyLastFlags) == "table" then
            for _, flagName in ipairs(applyLastFlags) do
                applySingleFlag(flagName, data[flagName])
            end
        end
        if type(options.onApplyReserved) == "function" then
            options.onApplyReserved(data)
        end
        if type(options.onApplyAfter) == "function" then
            options.onApplyAfter(data)
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
            if base and base:sub(-5) == ".json" and base ~= AUTOLOAD_FILE then
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
                return true, 'Deleted "' .. sanitizeConfigName(name) .. '"'
            end,
        }
    end
    local function autoLoadMetaPath(cm)
        return (cm.Path or "") .. AUTOLOAD_FILE
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
            clearRayfieldDropdown(AutoLoadSavedDropdown)
        end
        if selectedSavedConfigName and not table.find(savedConfigList, selectedSavedConfigName) then
            selectedSavedConfigName = nil
            clearRayfieldDropdown(SavedConfigsDropdown)
        end
        if showNotify then
            mountNotify({
                Title = "Config",
                Content = "Found " .. tostring(#savedConfigList) .. " saved profile(s).",
            })
        end
    end
    local function readProfileDataTable(cm, profileName)
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
        if not data.__version and data.__elements == nil then
            return data
        end
        if not data.__version then
            data = { __elements = data, __custom = {} }
        end
        return data.__elements or data
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
        local seq = options.sequentialLoad
        if not seq or type(seq.flags) ~= "table" or #seq.flags == 0 then
            return
        end
        local elements = readProfileDataTable(cm, profileName)
        if type(elements) ~= "table" then
            return
        end
        local parser = cm.Parser
        local br = seq.bridge or {}
        local warnLabel = seq.warnLabel or gameLabel
        if type(br.bumpAutoSellLoopToken) == "function" then
            br.bumpAutoSellLoopToken()
        end
        for index, flagName in ipairs(seq.flags) do
            local saved = getSavedElement(elements, flagName)
            if saved ~= nil then
                local elem = cfg and cfg.Elements and cfg.Elements[flagName]
                if parser and elem and type(saved) == "table" and saved.__type and parser[saved.__type] and parser[saved.__type].Load then
                    if index == 1 then
                        local wantSell = saved.value == true
                        if wantSell then
                            br.suppressNextAutoSellLoopSpawn = true
                        end
                        local pok, err = pcall(function()
                            parser[saved.__type].Load(elem, saved)
                        end)
                        br.suppressNextAutoSellLoopSpawn = false
                        if not pok then
                            warn("[" .. warnLabel .. "] Config sequential load (" .. tostring(flagName) .. "): " .. tostring(err))
                        elseif wantSell then
                            if type(br.runAutoSellWithFishingCoordination) == "function" then
                                pcall(br.runAutoSellWithFishingCoordination)
                            end
                            if type(br.startAutoSellSellLoop) == "function" then
                                br.startAutoSellSellLoop(true)
                            end
                        end
                    else
                        local pok, err = pcall(function()
                            parser[saved.__type].Load(elem, saved)
                        end)
                        if not pok then
                            warn("[" .. warnLabel .. "] Config sequential load (" .. tostring(flagName) .. "): " .. tostring(err))
                        end
                    end
                else
                    if index == 1 then
                        local wantSell = (type(saved) == "table" and saved.value == true) or saved == true
                        if wantSell then
                            br.suppressNextAutoSellLoopSpawn = true
                        end
                        applySingleFlag(flagName, saved)
                        br.suppressNextAutoSellLoopSpawn = false
                        if wantSell then
                            if type(br.runAutoSellWithFishingCoordination) == "function" then
                                pcall(br.runAutoSellWithFishingCoordination)
                            end
                            if type(br.startAutoSellSellLoop) == "function" then
                                br.startAutoSellSellLoop(true)
                            end
                        end
                    else
                        applySingleFlag(flagName, saved)
                    end
                end
            end
        end
    end
    local function scheduleSequentialConfigLoadAfterProfile(cm, cfg, profileName)
        if not options.sequentialLoad then
            return
        end
        task.defer(function()
            for _ = 1, 2 do
                RunService.Heartbeat:Wait()
            end
            applyConfigLoadSequentialSellTeleportLimited(cm, cfg, profileName)
        end)
    end
    local function runAfterSuccessfulLoad(cm, cfg, name)
        scheduleSequentialConfigLoadAfterProfile(cm, cfg, name)
        if type(options.onAfterLoad) == "function" then
            pcall(function()
                options.onAfterLoad(name, cfg, cm)
            end)
        end
    end
    ConfigNameInput = ConfigTab:CreateInput({
        Name = "Config name",
        PlaceholderText = namePlaceholder,
        CurrentValue = configMgmtName,
        Callback = function(value)
            configMgmtName = sanitizeConfigName(value)
        end,
    })
    SavedConfigsDropdown = ConfigTab:CreateDropdown({
        Name = "Config Saved",
        Options = savedConfigList,
        CurrentOption = {},
        Search = true,
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
        if windowRef.SetCurrentConfig then
            windowRef:SetCurrentConfig(cfg)
        end
        local pok, loadResult, loadErr = pcall(function()
            return cfg:Load()
        end)
        if not pok then
            warn("[" .. gameLabel .. "] Auto-load failed: ", loadResult)
            return
        end
        if loadResult == false then
            warn("[" .. gameLabel .. "] Auto-load: ", loadErr)
            return
        end
        runAfterSuccessfulLoad(cm, cfg, name)
        mountNotify({
            Title = "Config",
            Content = 'Auto-loaded "' .. name .. '"',
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
            if windowRef.SetCurrentConfig then
                windowRef:SetCurrentConfig(cfg)
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
            mountNotify({ Title = "Config", Content = 'Saved "' .. name .. '"' })
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
            if windowRef.SetCurrentConfig then
                windowRef:SetCurrentConfig(cfg)
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
            runAfterSuccessfulLoad(cm, cfg, name)
            mountNotify({ Title = "Config", Content = 'Loaded "' .. name .. '"' })
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
                    clearRayfieldDropdown(AutoLoadSavedDropdown)
                end
                selectedSavedConfigName = nil
                clearRayfieldDropdown(SavedConfigsDropdown)
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
                    Content = type(msg) == "string" and msg or ('Deleted "' .. name .. '"'),
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
        CurrentOption = {},
        Search = true,
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
                Content = 'Next run will load "' .. pick .. '"',
            })
        end,
    })
    ConfigTab:CreateButton({
        Name = "Reset",
        Callback = function()
            writeAutoLoadPersistedName("")
            autoLoadPickerSelection = nil
            clearRayfieldDropdown(AutoLoadSavedDropdown)
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
return createConfigTab
