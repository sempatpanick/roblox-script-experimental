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
    Name = "sempatpanick | Speed Bike Escape",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Speed Bike Escape",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "sempatpanick",
        FileName = "speed_bike_escape",
    },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
})
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

local AutoBikeTabShared = Window:CreateTab("Auto Bike", 4483362458)

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { ext = true, notifyIcons = true, playerSearch = true, playerNoneOption = true })

-- */  Auto Bike Tab  /* --
do
    local AutoBikeTab = AutoBikeTabShared

    AutoBikeTab:CreateSection("Auto Bike")

    local bikeRouteList = {
        {
            name = "Stage 11 to Finish",
            stages = {
                { stage = "11", location = "-4252.25, 1642.51, 1374.37", tweenToLocation = "-4222.04, 1642.48, 1372.25" },
                { stage = "12", location = "-3282.64, 1642.48, 1379.90", tweenToLocation = "-3242.16, 1642.48, 1378.84" },
                { stage = "13", location = "-2091.77, 1642.48, 1376.27", tweenToLocation = "-2050.39, 1642.48, 1375.55" },
                { stage = "14", location = "-429.22, 1642.48, 1390.05", tweenToLocation = "-403.99, 1642.48, 1374.15" },
                { stage = "15", location = "1313.37, 1642.48, 1367.53", tweenToLocation = "1340.68, 1642.48, 1375.74" },
                { stage = "16", location = "3361.88, 1473.71, 195.88", tweenToLocation = "3393.59, 1473.71, 193.87" },
                { stage = "17", location = "4352.14, 1473.71, 189.29", tweenToLocation = "4386.80, 1473.71, 189.45" },
                { stage = "18", location = "5384.94, 1473.71, 187.92", tweenToLocation = "5412.26, 1474.24, 185.77" },
                { stage = "finish", location = "7081.83, 1472.93, 186.29", tweenToLocation = "7085.25, 1513.67, 214.42" },
            },
        },
    }

    local routeNames = {}
    local routeByName = {}
    for _, route in ipairs(bikeRouteList) do
        table.insert(routeNames, route.name)
        routeByName[route.name] = route
    end

    local ROUTE_NONE = "(None)"
    local function routeDropdownOptions()
        local o = { ROUTE_NONE }
        for _, n in ipairs(routeNames) do
            table.insert(o, n)
        end
        return o
    end

    local selectedRouteName = nil
    local teleportDelaySeconds = "5"
    local autoRideRunning = false

    local RouteDropdown = AutoBikeTab:CreateDropdown({
        Name = "Route",
        Flag = "bike_route_select",
        Options = routeDropdownOptions(),
        CurrentOption = { ROUTE_NONE },
        Search = true,
        Ext = true,
        Callback = function(opts)
            local value = type(opts) == "table" and opts[1] or opts
            selectedRouteName = nil
            if value and value ~= ROUTE_NONE then
                selectedRouteName = value
            end
        end,
    })

    AutoBikeTab:CreateInput({
        Name = "Delay (seconds)",
        PlaceholderText = "Seconds before each teleport",
        Flag = "bike_teleportDelaySec",
        CurrentValue = teleportDelaySeconds,
        Ext = true,
        Callback = function(value)
            teleportDelaySeconds = value
        end,
    })

    local function parsePositionStr(posStr)
        local s = posStr:gsub(",", " "):gsub("%s+", " ")
        local parts = {}
        for part in string.gmatch(s, "[%d%.%-]+") do
            table.insert(parts, tonumber(part))
        end
        if #parts < 3 then return nil end
        return Vector3.new(parts[1], parts[2], parts[3])
    end

    AutoBikeTab:CreateToggle({
        Name = "Auto Ride",
        Flag = "bike_autoRide",
        CurrentValue = false,
        Ext = true,
        Callback = function(enabled)
            autoRideRunning = enabled
            if not enabled then return end
            if not selectedRouteName or selectedRouteName == "" then
                mountNotify({ Title = "Auto Bike", Content = "Select a route first", Icon = "x" })
                return
            end
            local route = routeByName[selectedRouteName]
            if not route or not route.stages or #route.stages == 0 then
                mountNotify({ Title = "Auto Bike", Content = "Invalid route", Icon = "x" })
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Auto Bike", Content = "Character not loaded", Icon = "x" })
                return
            end
            local delaySec = tonumber(teleportDelaySeconds) or 5
            if delaySec < 0 then delaySec = 0 end
            local tweenDuration = 1
            local delayLastToFirst = 5
            task.spawn(function()
                while autoRideRunning do
                    for i, stageData in ipairs(route.stages) do
                        if not autoRideRunning then break end
                        if i > 1 then
                            task.wait(delaySec)
                            if not autoRideRunning then break end
                        end
                        local loc = parsePositionStr(stageData.location)
                        if not loc then
                            mountNotify({ Title = "Auto Bike", Content = "Invalid location at stage " .. tostring(stageData.stage), Icon = "x" })
                        else
                            rootPart.CFrame = CFrame.new(loc)
                            task.wait(0.3)
                            if not autoRideRunning then break end
                            local tweenEnd = parsePositionStr(stageData.tweenToLocation)
                            if tweenEnd then
                                local tweenInfo = TweenInfo.new(tweenDuration)
                                local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = CFrame.new(tweenEnd) })
                                tween:Play()
                                tween.Completed:Wait()
                            end
                        end
                    end
                    if autoRideRunning then
                        task.wait(delayLastToFirst)
                    end
                end
            end)
            if autoRideRunning then
                mountNotify({ Title = "Auto Bike", Content = "Auto Ride started", Icon = "check" })
            end
        end,
    })
end

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, { replicatedStorage = ReplicatedStorage })


-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/speed_bike_escape",
    rayfieldLibrary = RayfieldLibrary,
})
