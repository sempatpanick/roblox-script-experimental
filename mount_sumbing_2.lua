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
-- */  Window  /* --
local Window = RayfieldLibrary:CreateWindow({
    Name = "sempatpanick | Mount Sumbing",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Mount Sumbing",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "sempatpanick",
        FileName = "mount_sumbing",
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
    -- Show position for Parts and other BaseParts (MeshPart, etc.) when requested
    if isShowLocation and inst:IsA("BasePart") then
        local p = inst.Position
        base = base .. " [" .. string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z) .. "]"
    end
    return base
end

-- */  Local Player Tab  /* --
createLocalPlayerTab(Window, mountNotify)

local QuestTabShared = Window:CreateTab("Quest", 4483362458)

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "sumbing" })
-- */  Quest Tab  /* --
do
    local QuestTab = QuestTabShared

    QuestTab:CreateSection("Deposit Cat Coin")
    local CatDataFolderParagraph
    local catCoinTokenNames = { "Cat Token (Light)", "Cat Token (Dark)" }
    local CatCoinDropdown
    local selectedCatCoin = nil
    local catCoinQty = ""

    local function refreshCatDataFolderDisplay()
        local folder = Players.LocalPlayer:FindFirstChild("CatDataFolder")
        local lines = {}
        if not folder then
            table.insert(lines, "(CatDataFolder not found)")
        else
            for _, child in ipairs(folder:GetChildren()) do
                table.insert(lines, formatInstanceDisplay(child, false))
            end
            if #lines == 0 then
                table.insert(lines, "(no children)")
            end
        end
        local text = table.concat(lines, "\n")
        if CatDataFolderParagraph and CatDataFolderParagraph.Set then
            CatDataFolderParagraph:Set({ Content = text })
        end
    end

    CatDataFolderParagraph = QuestTab:CreateParagraph({
        Title = "LocalPlayer.CatDataFolder",
        Content = "(loading...)",
    })

    local function getCatCoinDropdownValues()
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        local counts = {}
        for _, name in ipairs(catCoinTokenNames) do
            counts[name] = 0
        end
        if backpack then
            for _, child in ipairs(backpack:GetChildren()) do
                if counts[child.Name] ~= nil then
                    counts[child.Name] = counts[child.Name] + 1
                end
            end
        end
        local values = {}
        for _, name in ipairs(catCoinTokenNames) do
            table.insert(values, name .. " (" .. tostring(counts[name]) .. ")")
        end
        return values
    end

    local function refreshCatCoinDropdown()
        local values = getCatCoinDropdownValues()
        if CatCoinDropdown and CatCoinDropdown.Refresh then
            CatCoinDropdown:Refresh(values)
        end
    end

    task.defer(function()
        refreshCatDataFolderDisplay()
        refreshCatCoinDropdown()
    end)

    CatCoinDropdown = QuestTab:CreateDropdown({
        Name = "Token",
        Options = getCatCoinDropdownValues(),
        CurrentOption = {},
        Callback = function(value)
            selectedCatCoin = rayfieldDropdownFirst(value)
        end
    })

    QuestTab:CreateInput({
        Name = "Qty",
        PlaceholderText = "e.g. 1",
        CurrentValue = catCoinQty,
        Callback = function(value)
            catCoinQty = value
        end
    })

    QuestTab:CreateButton({
        Name = "Get Nearby Token",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Deposit Cat Coin", Content = "Character not loaded" })
                return
            end
            local catToken = Workspace:FindFirstChild("CatToken")
            if not catToken or not catToken:IsA("Folder") then
                mountNotify({ Title = "Deposit Cat Coin", Content = "No CatToken folder found in Workspace" })
                return
            end
            local playerPos = rootPart.Position
            local pos = nil
            local nearestChild = nil
            local bestDist = math.huge
            for _, child in ipairs(catToken:GetChildren()) do
                local childPos = nil
                if child:IsA("BasePart") then
                    childPos = child.Position
                elseif child:IsA("Model") and child.PrimaryPart then
                    childPos = child.PrimaryPart.Position
                end
                if childPos then
                    local dist = (playerPos - childPos).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        pos = childPos
                        nearestChild = child
                    end
                end
            end

            if not pos then
                mountNotify({ Title = "Deposit Cat Coin", Content = "Could not get CatToken position" })
                return
            end
            local yOffset = 3
            local teleportPos = Vector3.new(pos.X, pos.Y + yOffset, pos.Z)
            rootPart.CFrame = CFrame.new(teleportPos)
            task.wait(0.2)
            -- Trigger pickup: try ClickDetector (simulate mouse/tap) then ProximityPrompt
            local didInteract = false
            local clickDetector = nearestChild and (nearestChild:FindFirstChildOfClass("ClickDetector") or nearestChild:FindFirstChild("ClickDetector"))
            if not clickDetector and nearestChild then
                for _, d in ipairs(nearestChild:GetDescendants()) do
                    if d:IsA("ClickDetector") then
                        clickDetector = d
                        break
                    end
                end
            end
            if clickDetector and clickDetector:IsA("ClickDetector") then
                -- Simulate mouse/tap click: 3D position -> screen position -> VirtualUser click
                local clickWorldPos = pos
                local parent = clickDetector.Parent
                if parent then
                    if parent:IsA("BasePart") then
                        clickWorldPos = parent.Position
                    elseif parent:IsA("Model") and parent.PrimaryPart then
                        clickWorldPos = parent.PrimaryPart.Position
                    elseif parent:IsA("Model") then
                        local cf = parent:GetBoundingBox()
                        clickWorldPos = cf.Position
                    end
                end
                local camera = Workspace.CurrentCamera
                if camera then
                    local screenPos, onScreen = camera:WorldToScreenPoint(clickWorldPos)
                    if onScreen then
                        local okClick = pcall(function()
                            VirtualUser:ClickButton1(screenPos)
                        end)
                        if okClick then
                            didInteract = true
                        end
                    end
                end
            end
            if not didInteract then
                local prompt = nearestChild and (nearestChild:FindFirstChildOfClass("ProximityPrompt") or nearestChild:FindFirstChild("ProximityPrompt"))
                if not prompt and nearestChild then
                    for _, d in ipairs(nearestChild:GetDescendants()) do
                        if d:IsA("ProximityPrompt") then
                            prompt = d
                            break
                        end
                    end
                end
                if prompt and prompt:IsA("ProximityPrompt") then
                    local holdDuration = prompt.HoldDuration
                    prompt:InputHoldBegin()
                    task.wait(holdDuration > 0 and holdDuration or 0.5)
                    prompt:InputHoldEnd()
                    didInteract = true
                end
            end
            mountNotify({
                Title = "Deposit Cat Coin",
                Content = didInteract and string.format("Teleported and picked up token (%.1f, %.1f, %.1f)", teleportPos.X, teleportPos.Y, teleportPos.Z)
                    or string.format("Teleported to CatToken (%.1f, %.1f, %.1f)", teleportPos.X, teleportPos.Y, teleportPos.Z),
            })
        end
    })

    QuestTab:CreateButton({
        Name = "Deposit",
        Callback = function()
            if not selectedCatCoin then
                mountNotify({ Title = "Deposit Cat Coin", Content = "Select a token first" })
                return
            end
            local baseName = selectedCatCoin:match("^(.+) %(%d+%)$") or selectedCatCoin
            local qty = tonumber(catCoinQty) or 0
            if qty <= 0 then
                mountNotify({ Title = "Deposit Cat Coin", Content = "Enter a valid quantity" })
                return
            end
            local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
            local toolToEquip = nil
            if backpack then
                for _, child in ipairs(backpack:GetChildren()) do
                    if child:IsA("Tool") and child.Name == baseName then
                        toolToEquip = child
                        break
                    end
                end
            end
            if not toolToEquip then
                mountNotify({ Title = "Deposit Cat Coin", Content = "No " .. baseName .. " in Backpack to equip" })
                return
            end
            local character = Players.LocalPlayer.Character
            local humanoid = character and character:FindFirstChildOfClass("Humanoid")
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if humanoid and humanoid.EquipTool then
                humanoid:EquipTool(toolToEquip)
            end
            if not rootPart then
                mountNotify({ Title = "Deposit Cat Coin", Content = "Character not loaded" })
                return
            end
            task.wait(0.2)
            -- Tween to deposit location
            local depositPos = Vector3.new(-415.95, 5.41, 186.06)
            local tweenDuration = 3
            local tweenInfo = TweenInfo.new(tweenDuration)
            local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = CFrame.new(depositPos) })
            tween:Play()
            tween.Completed:Wait()
            task.wait(0.3)
            -- Interact with object nearby (ProximityPrompt)
            local targetPos = depositPos
            local interactRadius = 15
            local foundPrompt = nil
            for _, descendant in ipairs(Workspace:GetDescendants()) do
                if descendant:IsA("ProximityPrompt") then
                    local promptPos = descendant.Parent and descendant.Parent:IsA("BasePart") and descendant.Parent.Position
                        or (descendant.Parent and descendant.Parent:IsA("Model") and descendant.Parent.PrimaryPart and descendant.Parent.PrimaryPart.Position)
                    if promptPos and (promptPos - targetPos).Magnitude <= interactRadius then
                        foundPrompt = descendant
                        break
                    end
                end
            end
            if foundPrompt then
                local holdDuration = foundPrompt.HoldDuration
                foundPrompt:InputHoldBegin()
                task.wait(holdDuration > 0 and holdDuration or 0.5)
                foundPrompt:InputHoldEnd()
                mountNotify({ Title = "Deposit Cat Coin", Content = "Teleported and interacted" })
            else
                mountNotify({ Title = "Deposit Cat Coin", Content = "Teleported (no ProximityPrompt nearby)" })
            end
        end
    })

    QuestTab:CreateSection("Daily Reward")
    QuestTab:CreateButton({
        Name = "Claim Daily Reward",
        Callback = function()
            local function GetNil(Name, DebugId)
                for _, Object in getnilinstances() do
                    if Object.Name == Name and Object:GetDebugId() == DebugId then
                        return Object
                    end
                end
            end
            local Event = GetNil("DailyReward", "1_283461")
            if Event then
                Event:FireServer()
                mountNotify({ Title = "Daily Reward", Content = "Claimed daily reward" })
            else
                mountNotify({ Title = "Daily Reward", Content = "DailyReward event not found" })
            end
        end,
    })
end

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, { replicatedStorage = ReplicatedStorage })

createRecordingTab(Window, mountNotify, "sempatpanick/mount_sumbing/recordings")

