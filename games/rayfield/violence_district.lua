local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

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
local Window = RayfieldLibrary:CreateWindow({
    Name = "sempatpanick | Violence District",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Violence District",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "sempatpanick",
        FileName = "violence_district",
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

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", 4483362458)

    MainTab:CreateSection("Cursor")

    local MOVE_CURSOR_RENDER_STEP = "SempatPanickViolenceDistrictMoveCursor"
    local moveCursorEnabled = false
    local moveCursorToggle: any = nil

    local function stopMoveCursor()
        moveCursorEnabled = false
        RunService:UnbindFromRenderStep(MOVE_CURSOR_RENDER_STEP)
    end

    local function startMoveCursor()
        stopMoveCursor()
        moveCursorEnabled = true
        RunService:BindToRenderStep(MOVE_CURSOR_RENDER_STEP, Enum.RenderPriority.Last.Value, function()
            if not moveCursorEnabled then
                return
            end
            pcall(function()
                RunService:UnbindFromRenderStep("ShiftLock")
            end)
            UserInputService.MouseBehavior = Enum.MouseBehavior.Default
            UserInputService.MouseIconEnabled = true
        end)
    end

    local function setMoveCursorEnabled(enabled)
        if enabled then
            startMoveCursor()
        else
            stopMoveCursor()
        end
    end

    moveCursorToggle = MainTab:CreateToggle({
        Name = "Move Cursor",
        Flag = "main_move_cursor",
        CurrentValue = false,
        Callback = function(enabled)
            setMoveCursorEnabled(enabled == true)
        end,
    })

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if UserInputService:GetFocusedTextBox() then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.Keyboard or input.KeyCode ~= Enum.KeyCode.L then
            return
        end
        local nextEnabled = not moveCursorEnabled
        if moveCursorToggle and moveCursorToggle.Set then
            pcall(function()
                moveCursorToggle:Set(nextEnabled)
            end)
        else
            setMoveCursorEnabled(nextEnabled)
        end
    end)

    MainTab:CreateSection("Generators")

    local GENERATOR_NONE = "(No generators)"
    local generatorDisplayToInstance = {}
    local generatorDropdownOptions = { GENERATOR_NONE }
    local selectedGeneratorLabel = GENERATOR_NONE
    local generatorDropdown: any = nil

    local function getGeneratorWorldPosition(inst)
        if not inst then
            return nil
        end
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
            local okBb, cf = pcall(function()
                return inst:GetBoundingBox()
            end)
            if okBb and cf then
                return cf.Position
            end
        end
        local part = inst:FindFirstChildWhichIsA("BasePart", true)
        if part then
            return part.Position
        end
        return nil
    end

    local function getGeneratorFolderNameForLocalPlayer()
        local lp = Players.LocalPlayer
        if lp and lp.Team then
            local teamName = string.lower(lp.Team.Name)
            if string.find(teamName, "killer", 1, true) then
                return "Gens"
            end
        end
        return "Generators"
    end

    local function getGeneratorListFolder()
        local folderName = getGeneratorFolderNameForLocalPlayer()
        local folder = Workspace:FindFirstChild(folderName)
        if folder and (folder:IsA("Folder") or folder:IsA("Model")) then
            return folder, folderName
        end
        return nil, folderName
    end

    local generatorFolderWatchConnections = {}
    local refreshGeneratorDropdown

    local function clearGeneratorFolderWatchers()
        for _, conn in ipairs(generatorFolderWatchConnections) do
            pcall(function()
                conn:Disconnect()
            end)
        end
        table.clear(generatorFolderWatchConnections)
    end

    local function watchGeneratorFolder(folder)
        clearGeneratorFolderWatchers()
        if not folder then
            return
        end
        table.insert(generatorFolderWatchConnections, folder.ChildAdded:Connect(function()
            refreshGeneratorDropdown(false)
        end))
        table.insert(generatorFolderWatchConnections, folder.ChildRemoved:Connect(function()
            refreshGeneratorDropdown(false)
        end))
    end

    local function setupGeneratorFolderWatchers()
        clearGeneratorFolderWatchers()
        local folder, folderName = getGeneratorListFolder()
        if folder then
            watchGeneratorFolder(folder)
            return
        end
        local waitConn
        waitConn = Workspace.ChildAdded:Connect(function(child)
            if child.Name ~= folderName then
                return
            end
            if waitConn then
                pcall(function()
                    waitConn:Disconnect()
                end)
                waitConn = nil
            end
            watchGeneratorFolder(child)
            refreshGeneratorDropdown(true)
        end)
        table.insert(generatorFolderWatchConnections, waitConn)
    end

    local function buildGeneratorDropdownData()
        table.clear(generatorDisplayToInstance)
        local options = {}
        local gensFolder = getGeneratorListFolder()
        if not gensFolder then
            table.insert(options, GENERATOR_NONE)
            generatorDisplayToInstance[GENERATOR_NONE] = nil
            return options
        end

        local children = gensFolder:GetChildren()
        table.sort(children, function(a, b)
            return a.Name < b.Name or (a.Name == b.Name and a:GetFullName() < b:GetFullName())
        end)

        local nameCounts = {}
        for _, child in ipairs(children) do
            nameCounts[child.Name] = (nameCounts[child.Name] or 0) + 1
        end

        local nameIndex = {}
        for _, child in ipairs(children) do
            local label = child.Name
            if nameCounts[child.Name] > 1 then
                nameIndex[child.Name] = (nameIndex[child.Name] or 0) + 1
                local pos = getGeneratorWorldPosition(child)
                if pos then
                    label = string.format(
                        "%s #%d (%.0f, %.0f, %.0f)",
                        child.Name,
                        nameIndex[child.Name],
                        pos.X,
                        pos.Y,
                        pos.Z
                    )
                else
                    label = string.format("%s #%d", child.Name, nameIndex[child.Name])
                end
            end
            generatorDisplayToInstance[label] = child
            table.insert(options, label)
        end

        if #options == 0 then
            table.insert(options, GENERATOR_NONE)
            generatorDisplayToInstance[GENERATOR_NONE] = nil
        end
        return options
    end

    refreshGeneratorDropdown = function(selectFirst)
        generatorDropdownOptions = buildGeneratorDropdownData()
        if generatorDropdown and generatorDropdown.Refresh then
            generatorDropdown:Refresh(generatorDropdownOptions)
        end
        local pick = selectedGeneratorLabel
        if selectFirst or not table.find(generatorDropdownOptions, pick) then
            pick = generatorDropdownOptions[1] or GENERATOR_NONE
        end
        selectedGeneratorLabel = pick
        if generatorDropdown and generatorDropdown.Set then
            pcall(function()
                generatorDropdown:Set(pick)
            end)
        end
    end

    generatorDropdown = MainTab:CreateDropdown({
        Name = "Generators",
        Flag = "main_generator_pick",
        Options = generatorDropdownOptions,
        CurrentOption = { generatorDropdownOptions[1] },
        Callback = function(value)
            selectedGeneratorLabel = rayfieldDropdownFirst(value) or GENERATOR_NONE
        end,
    })

    task.defer(function()
        refreshGeneratorDropdown(true)
        setupGeneratorFolderWatchers()
        local lp = Players.LocalPlayer
        if lp then
            lp:GetPropertyChangedSignal("Team"):Connect(function()
                refreshGeneratorDropdown(true)
                setupGeneratorFolderWatchers()
            end)
        end
    end)

    MainTab:CreateButton({
        Name = "Teleport to Generator",
        Callback = function()
            local rootPart = Players.LocalPlayer.Character
                and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Generators", Content = "Character not loaded", Icon = "x" })
                return
            end
            local target = generatorDisplayToInstance[selectedGeneratorLabel]
            if not target then
                mountNotify({ Title = "Generators", Content = "Select a generator first", Icon = "x" })
                return
            end
            local pos = getGeneratorWorldPosition(target)
            if not pos then
                mountNotify({ Title = "Generators", Content = "Could not get generator position", Icon = "x" })
                return
            end
            rootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
            mountNotify({
                Title = "Generators",
                Content = "Teleported to " .. selectedGeneratorLabel,
                Icon = "check",
            })
        end,
    })
end

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "violence_district" })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, { replicatedStorage = ReplicatedStorage })


-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, {
    gamePath = "sempatpanick/violence_district",
})

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/violence_district",
    rayfieldLibrary = RayfieldLibrary,
})
