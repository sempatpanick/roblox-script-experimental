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
    Name = "sempatpanick | Find The Button",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Find The Button",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "sempatpanick",
        FileName = "find_the_button",
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
    local LocalPlayer = Players.LocalPlayer

    MainTab:CreateSection("Button")

    local buttonEspEnabled = false
    local buttonEspHighlights: { Highlight } = {}
    local buttonEspLabels: { BillboardGui } = {}
    local buttonEspLevelConn: RBXScriptConnection? = nil
    local buttonEspRenderConn: RBXScriptConnection? = nil

    local function getLocalLevelValue(): number?
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if not leaderstats then
            return nil
        end
        local level = leaderstats:FindFirstChild("Level")
        if not level then
            return nil
        end
        local ok, val = pcall(function()
            return level.Value
        end)
        if not ok or val == nil then
            return nil
        end
        if type(val) == "number" then
            return val
        end
        return tonumber(val)
    end

    local function getLevelFolder(levelNum: number): Instance?
        local levels = Workspace:FindFirstChild("Levels")
        if not levels then
            return nil
        end
        local folder = levels:FindFirstChild(tostring(levelNum))
        if folder then
            return folder
        end
        for _, child in ipairs(levels:GetChildren()) do
            if tonumber(child.Name) == levelNum then
                return child
            end
        end
        return nil
    end

    local function getButtonModel(): Instance?
        local levelNum = getLocalLevelValue()
        if not levelNum then
            return nil
        end
        local levelFolder = getLevelFolder(levelNum)
        if not levelFolder then
            return nil
        end
        return levelFolder:FindFirstChild("ButtonModel")
    end

    local function getInstanceWorldPosition(inst: Instance): Vector3?
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

    local TELEPORT_NEAR_BUTTON_STUDS = 3

    local function getCFrameNearButton(buttonModel: Instance, rootPart: BasePart): CFrame?
        local buttonPos = getInstanceWorldPosition(buttonModel)
        if not buttonPos then
            return nil
        end
        local playerPos = rootPart.Position
        local horizontalDir = Vector3.new(playerPos.X - buttonPos.X, 0, playerPos.Z - buttonPos.Z)
        if horizontalDir.Magnitude < 0.5 then
            if buttonModel:IsA("Model") then
                local okPivot, pivot = pcall(function()
                    return buttonModel:GetPivot()
                end)
                if okPivot and pivot then
                    local look = pivot.LookVector
                    horizontalDir = Vector3.new(-look.X, 0, -look.Z)
                end
            elseif buttonModel:IsA("BasePart") then
                local look = buttonModel.CFrame.LookVector
                horizontalDir = Vector3.new(-look.X, 0, -look.Z)
            end
            if horizontalDir.Magnitude < 0.5 then
                horizontalDir = Vector3.new(0, 0, TELEPORT_NEAR_BUTTON_STUDS)
            end
        end
        local nearPos = buttonPos + horizontalDir.Unit * TELEPORT_NEAR_BUTTON_STUDS
        return CFrame.lookAt(nearPos, buttonPos)
    end

    local function getButtonClickDetector(buttonModel: Instance): ClickDetector?
        local buttonPart = buttonModel:FindFirstChild("Button")
        if buttonPart then
            local detector = buttonPart:FindFirstChildOfClass("ClickDetector")
            if detector then
                return detector
            end
        end
        for _, descendant in ipairs(buttonModel:GetDescendants()) do
            if descendant:IsA("ClickDetector") then
                return descendant
            end
        end
        return nil
    end

    local function fireButtonClickDetector(clickDetector: ClickDetector, buttonPart: BasePart): boolean
        local lp = LocalPlayer
        if type(fireclickdetector) == "function" then
            local ok = pcall(function()
                fireclickdetector(clickDetector, 0, lp)
            end)
            if ok then
                return true
            end
        end
        local camera = Workspace.CurrentCamera
        if not camera then
            return false
        end
        local screenPos, onScreen = camera:WorldToScreenPoint(buttonPart.Position)
        if not onScreen then
            return false
        end
        local okClick = pcall(function()
            VirtualUser:ClickButton1(screenPos)
        end)
        return okClick
    end

    local function clickCurrentLevelButton(): boolean
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart or not rootPart:IsA("BasePart") then
            mountNotify({ Title = "Button", Content = "Character not loaded", Icon = "x" })
            return false
        end
        local levelNum = getLocalLevelValue()
        if not levelNum then
            mountNotify({ Title = "Button", Content = "Could not read leaderstats Level", Icon = "x" })
            return false
        end
        local buttonModel = getButtonModel()
        if not buttonModel then
            mountNotify({
                Title = "Button",
                Content = "ButtonModel not found for level " .. tostring(levelNum),
                Icon = "x",
            })
            return false
        end
        local clickDetector = getButtonClickDetector(buttonModel)
        local buttonPart = buttonModel:FindFirstChild("Button")
        if not clickDetector or not (buttonPart and buttonPart:IsA("BasePart")) then
            mountNotify({ Title = "Button", Content = "ClickDetector not found on button", Icon = "x" })
            return false
        end
        local nearCFrame = getCFrameNearButton(buttonModel, rootPart)
        if nearCFrame then
            rootPart.CFrame = nearCFrame
            task.wait(0.15)
        end
        local clicked = fireButtonClickDetector(clickDetector, buttonPart)
        if clicked then
            mountNotify({ Title = "Button", Content = "Clicked level " .. tostring(levelNum) .. " button", Icon = "check" })
        else
            mountNotify({ Title = "Button", Content = "Could not simulate click (move closer or click manually)", Icon = "x" })
        end
        return clicked
    end

    local function getButtonEspTargets(buttonModel: Instance): { Instance }
        local targets: { Instance } = {}
        if buttonModel:IsA("BasePart") or buttonModel:IsA("Model") then
            table.insert(targets, buttonModel)
            return targets
        end
        for _, child in ipairs(buttonModel:GetChildren()) do
            if child:IsA("BasePart") or child:IsA("Model") then
                table.insert(targets, child)
            end
        end
        if #targets == 0 then
            table.insert(targets, buttonModel)
        end
        return targets
    end

    local function getEspAdorneePart(target: Instance): BasePart?
        if target:IsA("BasePart") then
            return target
        end
        if target:IsA("Model") then
            if target.PrimaryPart then
                return target.PrimaryPart
            end
            return target:FindFirstChildWhichIsA("BasePart", true)
        end
        return nil
    end

    local function getButtonEspLabelText(adornee: BasePart): string
        local levelNum = getLocalLevelValue()
        local title = "Button"
        local levelText = levelNum and ("Level " .. tostring(levelNum)) or "Level ?"
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart and rootPart:IsA("BasePart") then
            local dist = (rootPart.Position - adornee.Position).Magnitude
            return string.format("%s\n%s · %.0fm", title, levelText, dist)
        end
        return string.format("%s\n%s", title, levelText)
    end

    local function createButtonEspLabel(adornee: BasePart): BillboardGui
        local gui = Instance.new("BillboardGui")
        gui.Name = "SempatPanickButtonESPLabel"
        gui.Size = UDim2.fromOffset(220, 48)
        gui.StudsOffset = Vector3.new(0, 2.5, 0)
        gui.AlwaysOnTop = true
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromScale(1, 1)
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = Color3.fromRGB(255, 220, 80)
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.TextWrapped = true
        label.Text = getButtonEspLabelText(adornee)
        label.Parent = gui
        gui.Adornee = adornee
        gui.Parent = adornee
        return gui
    end

    local function updateButtonEspLabels()
        if not buttonEspEnabled then
            return
        end
        for _, gui in ipairs(buttonEspLabels) do
            local adornee = gui.Adornee
            if adornee and adornee:IsA("BasePart") then
                local label = gui:FindFirstChild("Label")
                if label and label:IsA("TextLabel") then
                    label.Text = getButtonEspLabelText(adornee)
                end
            end
        end
    end

    local function clearButtonEsp()
        for _, highlight in ipairs(buttonEspHighlights) do
            pcall(function()
                highlight:Destroy()
            end)
        end
        table.clear(buttonEspHighlights)
        for _, gui in ipairs(buttonEspLabels) do
            pcall(function()
                gui:Destroy()
            end)
        end
        table.clear(buttonEspLabels)
    end

    local function stopButtonEspRender()
        if buttonEspRenderConn then
            buttonEspRenderConn:Disconnect()
            buttonEspRenderConn = nil
        end
    end

    local function startButtonEspRender()
        stopButtonEspRender()
        buttonEspRenderConn = RunService.RenderStepped:Connect(updateButtonEspLabels)
    end

    local function applyButtonEsp()
        clearButtonEsp()
        if not buttonEspEnabled then
            return
        end
        local buttonModel = getButtonModel()
        if not buttonModel then
            return
        end
        for _, target in ipairs(getButtonEspTargets(buttonModel)) do
            if not (target:IsA("Model") or target:IsA("BasePart")) then
                continue
            end
            local highlight = Instance.new("Highlight")
            highlight.Name = "SempatPanickButtonESP"
            highlight.FillColor = Color3.fromRGB(255, 196, 0)
            highlight.FillTransparency = 0.45
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = target
            highlight.Parent = target
            table.insert(buttonEspHighlights, highlight)

            local adornee = getEspAdorneePart(target)
            if adornee then
                table.insert(buttonEspLabels, createButtonEspLabel(adornee))
            end
        end
        updateButtonEspLabels()
    end

    local function bindButtonEspLevelWatch()
        if buttonEspLevelConn then
            return
        end
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if not leaderstats then
            return
        end
        local level = leaderstats:FindFirstChild("Level")
        if not level then
            return
        end
        buttonEspLevelConn = level:GetPropertyChangedSignal("Value"):Connect(function()
            applyButtonEsp()
        end)
    end

    local function unbindButtonEspLevelWatch()
        if buttonEspLevelConn then
            buttonEspLevelConn:Disconnect()
            buttonEspLevelConn = nil
        end
    end

    local function setButtonEspEnabled(enabled: boolean)
        buttonEspEnabled = enabled
        if enabled then
            bindButtonEspLevelWatch()
            applyButtonEsp()
            startButtonEspRender()
            local levelNum = getLocalLevelValue()
            if not getButtonModel() then
                mountNotify({
                    Title = "Button ESP",
                    Content = levelNum
                        and ("No ButtonModel found for level " .. tostring(levelNum))
                        or "Could not read leaderstats Level",
                    Icon = "x",
                })
            end
            return
        end
        clearButtonEsp()
        stopButtonEspRender()
        unbindButtonEspLevelWatch()
    end

    MainTab:CreateToggle({
        Name = "ESP Button",
        Flag = "ftb_main_esp_button",
        CurrentValue = false,
        Callback = function(enabled)
            setButtonEspEnabled(enabled == true)
        end,
    })

    MainTab:CreateButton({
        Name = "Teleport to Button",
        Callback = function()
            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Button", Content = "Character not loaded", Icon = "x" })
                return
            end
            local levelNum = getLocalLevelValue()
            if not levelNum then
                mountNotify({ Title = "Button", Content = "Could not read leaderstats Level", Icon = "x" })
                return
            end
            local buttonModel = getButtonModel()
            if not buttonModel then
                mountNotify({
                    Title = "Button",
                    Content = "ButtonModel not found for level " .. tostring(levelNum),
                    Icon = "x",
                })
                return
            end
            local nearCFrame = getCFrameNearButton(buttonModel, rootPart)
            if not nearCFrame then
                mountNotify({ Title = "Button", Content = "Could not get button position", Icon = "x" })
                return
            end
            rootPart.CFrame = nearCFrame
            mountNotify({ Title = "Button", Content = "Teleported to level " .. tostring(levelNum) .. " button", Icon = "check" })
        end,
    })

    MainTab:CreateButton({
        Name = "Click Button",
        Callback = function()
            clickCurrentLevelButton()
        end,
    })

    MainTab:CreateKeybind({
        Name = "Click Button",
        CurrentKeybind = "E",
        HoldToInteract = false,
        Flag = "ftb_main_click_button_keybind",
        Callback = function()
            clickCurrentLevelButton()
        end,
    })

    MainTab:CreateSection("Auto Collect Word")

    local LetterTouched = ReplicatedStorage:WaitForChild("FE"):WaitForChild("LetterTouched")
    local GetDailyNumberRange = ReplicatedStorage.FE:WaitForChild("GetDailyNumberRange")
    local GetRequestedLetter = ReplicatedStorage.FE:WaitForChild("GetRequestedLetter")

    local autoCollectWordEnabled = false
    local autoCollectWordBusy = false
    local autoCollectWordLevelConn: RBXScriptConnection? = nil
    local autoCollectPendingLetter: string? = nil
    local collectedWordEntries: { { level: number, letter: string } } = {}
    local collectedWordsParagraph: any = nil

    GetRequestedLetter.OnClientInvoke = function()
        if autoCollectPendingLetter then
            return autoCollectPendingLetter
        end
        return nil
    end

    local function formatCollectedWordEntry(levelNum: number, letter: string): string
        return string.format("Level %s - %s", tostring(levelNum), string.upper(letter))
    end

    local function formatCollectedWordsDisplay(): string
        if #collectedWordEntries == 0 then
            return "(none)"
        end
        local parts: { string } = {}
        for _, entry in ipairs(collectedWordEntries) do
            table.insert(parts, formatCollectedWordEntry(entry.level, entry.letter))
        end
        return table.concat(parts, ", ")
    end

    local function refreshCollectedWordsParagraph()
        if collectedWordsParagraph and collectedWordsParagraph.Set then
            collectedWordsParagraph:Set({
                Title = "Collected Word",
                Content = formatCollectedWordsDisplay(),
            })
        end
    end

    local function addCollectedWordLetter(letter: string, levelNum: number)
        local normalized = string.upper(tostring(letter))
        if normalized == "" or not levelNum then
            return
        end
        for _, existing in ipairs(collectedWordEntries) do
            if existing.level == levelNum and existing.letter == normalized then
                return
            end
        end
        table.insert(collectedWordEntries, { level = levelNum, letter = normalized })
        refreshCollectedWordsParagraph()
    end

    local function getLevelWordCollectTargets(levelFolder: Instance): { Instance }
        local targets: { Instance } = {}
        local wordNode = levelFolder:FindFirstChild("WordNode")
        if wordNode then
            table.insert(targets, wordNode)
        end
        local halloweenNode = levelFolder:FindFirstChild("HalloweenNode")
        if halloweenNode then
            local innerNode = halloweenNode:FindFirstChild("HalloweenNode")
            if innerNode then
                table.insert(targets, innerNode)
            else
                table.insert(targets, halloweenNode)
            end
        end
        return targets
    end

    local AUTO_COLLECT_WORD_VISIBLE_TIMEOUT = 15
    local AUTO_COLLECT_WORD_VISIBLE_POLL = 0.25

    local function isGuiVisible(gui: GuiObject): boolean
        if not gui.Visible then
            return false
        end
        local parent = gui.Parent
        while parent do
            if parent:IsA("GuiObject") and not parent.Visible then
                return false
            end
            if parent:IsA("LayerCollector") and not parent.Enabled then
                return false
            end
            parent = parent.Parent
        end
        return true
    end

    local function isBasePartVisible(part: BasePart): boolean
        if part.Transparency >= 0.999 then
            return false
        end
        if part.LocalTransparencyModifier >= 0.999 then
            return false
        end
        return true
    end

    local function isWordCollectTargetVisible(wordTarget: Instance): boolean
        if not wordTarget or not wordTarget.Parent then
            return false
        end
        if wordTarget:IsA("GuiObject") then
            return isGuiVisible(wordTarget)
        end
        if wordTarget:IsA("BasePart") then
            return isBasePartVisible(wordTarget)
        end

        local foundPart = false
        local foundVisiblePart = false
        for _, descendant in ipairs(wordTarget:GetDescendants()) do
            if descendant:IsA("GuiObject") then
                if isGuiVisible(descendant) then
                    return true
                end
            elseif descendant:IsA("BasePart") then
                foundPart = true
                if isBasePartVisible(descendant) then
                    foundVisiblePart = true
                end
            end
        end
        if foundPart then
            return foundVisiblePart
        end
        return false
    end

    local wordEspEnabled = false
    local wordEspLevelConn: RBXScriptConnection? = nil
    local wordEspRenderConn: RBXScriptConnection? = nil
    local lastWordEspApplyAt = 0

    local function getWordEspAdornee(target: Instance): BasePart?
        if target:IsA("BasePart") then
            return target
        end
        if target:IsA("Model") then
            if target.PrimaryPart then
                return target.PrimaryPart
            end
            return target:FindFirstChildWhichIsA("BasePart", true)
        end
        return nil
    end

    local function getWordEspLabelText(adornee: BasePart, nodeName: string): string
        local levelNum = getLocalLevelValue()
        local levelText = levelNum and ("Level " .. tostring(levelNum)) or "Level ?"
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart and rootPart:IsA("BasePart") then
            local dist = (rootPart.Position - adornee.Position).Magnitude
            return string.format("%s\n%s · %.0fm", nodeName, levelText, dist)
        end
        return string.format("%s\n%s", nodeName, levelText)
    end

    local function createWordEspLabel(adornee: BasePart, nodeName: string): BillboardGui
        local gui = Instance.new("BillboardGui")
        gui.Name = "SempatPanickWordESPLabel"
        gui.Size = UDim2.fromOffset(220, 48)
        gui.StudsOffset = Vector3.new(0, 2.5, 0)
        gui.AlwaysOnTop = true
        local label = Instance.new("TextLabel")
        label.Name = "Label"
        label.BackgroundTransparency = 1
        label.Size = UDim2.fromScale(1, 1)
        label.Font = Enum.Font.GothamBold
        label.TextColor3 = Color3.fromRGB(180, 140, 255)
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        label.TextWrapped = true
        label.Text = getWordEspLabelText(adornee, nodeName)
        label.Parent = gui
        gui.Adornee = adornee
        gui.Parent = adornee
        return gui
    end

    local wordEspState: { [Instance]: { highlight: Highlight, labelGui: BillboardGui? } } = {}

    local function clearWordEspForTarget(target: Instance)
        local state = wordEspState[target]
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
        wordEspState[target] = nil
    end

    local function clearWordEsp()
        for target in pairs(wordEspState) do
            clearWordEspForTarget(target)
        end
    end

    local function updateWordEspLabels()
        if not wordEspEnabled then
            return
        end
        for _, state in pairs(wordEspState) do
            local gui = state.labelGui
            if not gui then
                continue
            end
            local adornee = gui.Adornee
            if adornee and adornee:IsA("BasePart") then
                local label = gui:FindFirstChild("Label")
                if label and label:IsA("TextLabel") then
                    label.Text = getWordEspLabelText(adornee, gui:GetAttribute("NodeName") or "Word")
                end
            end
        end
    end

    local function ensureWordEspForTarget(target: Instance)
        local state = wordEspState[target]
        if not state then
            local highlight = Instance.new("Highlight")
            highlight.Name = "SempatPanickWordESP"
            highlight.FillColor = Color3.fromRGB(140, 90, 255)
            highlight.FillTransparency = 0.45
            highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
            highlight.OutlineTransparency = 0
            highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            highlight.Adornee = target
            highlight.Parent = target

            local labelGui: BillboardGui? = nil
            local adornee = getWordEspAdornee(target)
            if adornee then
                labelGui = createWordEspLabel(adornee, target.Name)
                labelGui:SetAttribute("NodeName", target.Name)
            end

            state = {
                highlight = highlight,
                labelGui = labelGui,
            }
            wordEspState[target] = state
        end

        if state.labelGui then
            local adornee = state.labelGui.Adornee
            if adornee and adornee:IsA("BasePart") then
                local label = state.labelGui:FindFirstChild("Label")
                if label and label:IsA("TextLabel") then
                    label.Text = getWordEspLabelText(adornee, state.labelGui:GetAttribute("NodeName") or target.Name)
                end
            end
        end
    end

    local function syncWordEsp()
        if not wordEspEnabled then
            clearWordEsp()
            return
        end
        local levelNum = getLocalLevelValue()
        if not levelNum then
            clearWordEsp()
            return
        end
        local levelFolder = getLevelFolder(levelNum)
        if not levelFolder then
            clearWordEsp()
            return
        end

        local activeTargets: { [Instance]: boolean } = {}
        for _, target in ipairs(getLevelWordCollectTargets(levelFolder)) do
            if not (target:IsA("Model") or target:IsA("BasePart")) then
                continue
            end
            if not isWordCollectTargetVisible(target) then
                continue
            end
            activeTargets[target] = true
            ensureWordEspForTarget(target)
        end

        for target in pairs(wordEspState) do
            if not activeTargets[target] then
                clearWordEspForTarget(target)
            end
        end
    end

    local function stopWordEspRender()
        if wordEspRenderConn then
            wordEspRenderConn:Disconnect()
            wordEspRenderConn = nil
        end
    end

    local function startWordEspRender()
        stopWordEspRender()
        lastWordEspApplyAt = 0
        wordEspRenderConn = RunService.RenderStepped:Connect(function()
            if not wordEspEnabled then
                return
            end
            updateWordEspLabels()
            local now = os.clock()
            if now - lastWordEspApplyAt >= AUTO_COLLECT_WORD_VISIBLE_POLL then
                lastWordEspApplyAt = now
                syncWordEsp()
            end
        end)
    end

    local function bindWordEspLevelWatch()
        if wordEspLevelConn then
            return
        end
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if not leaderstats then
            return
        end
        local level = leaderstats:FindFirstChild("Level")
        if not level then
            return
        end
        wordEspLevelConn = level:GetPropertyChangedSignal("Value"):Connect(function()
            syncWordEsp()
        end)
    end

    local function unbindWordEspLevelWatch()
        if wordEspLevelConn then
            wordEspLevelConn:Disconnect()
            wordEspLevelConn = nil
        end
    end

    local function setWordEspEnabled(enabled: boolean)
        wordEspEnabled = enabled
        if enabled then
            bindWordEspLevelWatch()
            syncWordEsp()
            startWordEspRender()
            return
        end
        clearWordEsp()
        stopWordEspRender()
        unbindWordEspLevelWatch()
    end

    local function waitForWordCollectTargetVisible(wordTarget: Instance, timeoutSec: number): boolean
        local deadline = os.clock() + timeoutSec
        while os.clock() < deadline do
            if not autoCollectWordEnabled then
                return false
            end
            if isWordCollectTargetVisible(wordTarget) then
                return true
            end
            task.wait(AUTO_COLLECT_WORD_VISIBLE_POLL)
        end
        return isWordCollectTargetVisible(wordTarget)
    end

    local function getLetterFromInstance(inst: Instance): string?
        local okAttr, letterAttr = pcall(function()
            return inst:GetAttribute("Letter")
        end)
        if okAttr and letterAttr ~= nil and tostring(letterAttr) ~= "" then
            return string.upper(tostring(letterAttr))
        end
        if inst:IsA("BasePart") and #inst.Name == 1 and inst.Name:match("%a") then
            return string.upper(inst.Name)
        end
        for _, descendant in ipairs(inst:GetDescendants()) do
            if descendant:IsA("BasePart") then
                local okDesc, descLetter = pcall(function()
                    return descendant:GetAttribute("Letter")
                end)
                if okDesc and descLetter ~= nil and tostring(descLetter) ~= "" then
                    return string.upper(tostring(descLetter))
                end
                if #descendant.Name == 1 and descendant.Name:match("%a") then
                    return string.upper(descendant.Name)
                end
            end
        end
        return nil
    end

    local function getLetterFromWordTouchFolder(): string?
        local wordTouchFolder = Workspace:FindFirstChild("WordTouchFolder")
        if not wordTouchFolder then
            return nil
        end
        for _, child in ipairs(wordTouchFolder:GetChildren()) do
            if child:IsA("BasePart") then
                local letter = getLetterFromInstance(child)
                if letter then
                    return letter
                end
            end
        end
        return nil
    end

    local function getLetterForLevel(levelNum: number, wordTarget: Instance?): string?
        if wordTarget then
            local directLetter = getLetterFromInstance(wordTarget)
            if directLetter then
                return directLetter
            end
        end
        local folderLetter = getLetterFromWordTouchFolder()
        if folderLetter then
            return folderLetter
        end
        local dailyWord = Workspace:GetAttribute("DailyWord")
        if type(dailyWord) ~= "string" or dailyWord == "" then
            return nil
        end
        local okRange, _hints, levelReqs = pcall(function()
            return GetDailyNumberRange:InvokeServer()
        end)
        if not okRange or type(levelReqs) ~= "table" then
            return nil
        end
        for index, reqLevel in ipairs(levelReqs) do
            if tonumber(reqLevel) == levelNum then
                local letter = dailyWord:sub(index, index)
                if letter ~= "" then
                    return string.upper(letter)
                end
            end
        end
        return nil
    end

    local function invokeLetterTouched(letter: string): boolean
        autoCollectPendingLetter = letter
        local okInvoke, result = pcall(function()
            return LetterTouched:InvokeServer(letter)
        end)
        autoCollectPendingLetter = nil
        return okInvoke and result == true
    end

    local function tryAutoCollectWordForLevel(levelNum: number?, showFailureNotify: boolean?)
        if not autoCollectWordEnabled or autoCollectWordBusy then
            return
        end
        levelNum = levelNum or getLocalLevelValue()
        if not levelNum then
            if showFailureNotify then
                mountNotify({ Title = "Auto Collect Word", Content = "Could not read leaderstats Level", Icon = "x" })
            end
            return
        end
        local levelFolder = getLevelFolder(levelNum)
        if not levelFolder then
            if showFailureNotify then
                mountNotify({ Title = "Auto Collect Word", Content = "Level folder not found for " .. tostring(levelNum), Icon = "x" })
            end
            return
        end
        local wordTargets = getLevelWordCollectTargets(levelFolder)
        if #wordTargets == 0 then
            return
        end

        autoCollectWordBusy = true
        task.spawn(function()
            local visibleTargets: { Instance } = {}
            for _, wordTarget in ipairs(wordTargets) do
                if waitForWordCollectTargetVisible(wordTarget, AUTO_COLLECT_WORD_VISIBLE_TIMEOUT) then
                    table.insert(visibleTargets, wordTarget)
                end
            end
            if #visibleTargets == 0 then
                autoCollectWordBusy = false
                if showFailureNotify then
                    mountNotify({
                        Title = "Auto Collect Word",
                        Content = "No visible word nodes on level " .. tostring(levelNum),
                        Icon = "x",
                    })
                end
                return
            end

            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart or not rootPart:IsA("BasePart") then
                autoCollectWordBusy = false
                if showFailureNotify then
                    mountNotify({ Title = "Auto Collect Word", Content = "Character not loaded", Icon = "x" })
                end
                return
            end

            local savedCFrame = rootPart.CFrame
            local function restoreSavedPosition()
                local currentCharacter = LocalPlayer.Character
                local currentRoot = currentCharacter and currentCharacter:FindFirstChild("HumanoidRootPart")
                if currentRoot and currentRoot:IsA("BasePart") then
                    currentRoot.CFrame = savedCFrame
                end
            end

            local collectedCount = 0
            local lastCollectedLetter: string? = nil

            for _, wordTarget in ipairs(visibleTargets) do
                if not autoCollectWordEnabled then
                    break
                end

                local nearCFrame = getCFrameNearButton(wordTarget, rootPart)
                if nearCFrame then
                    rootPart.CFrame = nearCFrame
                end
                task.wait(0.2)

                local letter = getLetterForLevel(levelNum, wordTarget)
                if letter and invokeLetterTouched(letter) then
                    addCollectedWordLetter(letter, levelNum)
                    collectedCount += 1
                    lastCollectedLetter = letter
                end
            end

            restoreSavedPosition()

            if collectedCount > 0 then
                mountNotify({
                    Title = "Auto Collect Word",
                    Content = string.format(
                        "Collected %d letter(s) on level %s%s",
                        collectedCount,
                        tostring(levelNum),
                        lastCollectedLetter and (" (last: " .. lastCollectedLetter .. ")") or ""
                    ),
                    Icon = "check",
                })
            elseif showFailureNotify then
                mountNotify({
                    Title = "Auto Collect Word",
                    Content = "LetterTouched failed on level " .. tostring(levelNum),
                    Icon = "x",
                })
            end
            autoCollectWordBusy = false
        end)
    end

    local function bindAutoCollectWordLevelWatch()
        if autoCollectWordLevelConn then
            return
        end
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if not leaderstats then
            return
        end
        local level = leaderstats:FindFirstChild("Level")
        if not level then
            return
        end
        autoCollectWordLevelConn = level:GetPropertyChangedSignal("Value"):Connect(function()
            tryAutoCollectWordForLevel(getLocalLevelValue(), false)
        end)
    end

    local function unbindAutoCollectWordLevelWatch()
        if autoCollectWordLevelConn then
            autoCollectWordLevelConn:Disconnect()
            autoCollectWordLevelConn = nil
        end
    end

    local function setAutoCollectWordEnabled(enabled: boolean)
        autoCollectWordEnabled = enabled
        if enabled then
            bindAutoCollectWordLevelWatch()
            tryAutoCollectWordForLevel(getLocalLevelValue(), false)
            return
        end
        unbindAutoCollectWordLevelWatch()
    end

    collectedWordsParagraph = MainTab:CreateParagraph({
        Title = "Collected Word",
        Content = formatCollectedWordsDisplay(),
    })

    MainTab:CreateToggle({
        Name = "ESP Word",
        Flag = "ftb_main_esp_word",
        CurrentValue = false,
        Callback = function(enabled)
            setWordEspEnabled(enabled == true)
        end,
    })

    MainTab:CreateToggle({
        Name = "Auto Collect",
        Flag = "ftb_main_auto_collect_word",
        CurrentValue = false,
        Callback = function(enabled)
            setAutoCollectWordEnabled(enabled == true)
        end,
    })
end

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "find_the_button" })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, { replicatedStorage = ReplicatedStorage })

-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, "sempatpanick/find_the_button/recordings")

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/find_the_button",
    rayfieldLibrary = RayfieldLibrary,
})
