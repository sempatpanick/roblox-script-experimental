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
    Title = "sempatpanick | Sawah Indo",
    Folder = "ftgshub",
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

-- */  Elements Section  /* --
local ElementsSection = Window:Section({
    Title = "Elements",
    Opened = true, -- start expanded so all element tabs are visible
})

-- */  Farm Tab  /* --
do
    local FarmTab = ElementsSection:Tab({
        Title = "Farm",
        Icon = "solar:folder-2-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    local Workspace = game:GetService("Workspace")
    local localPlayerCropsList = {}

    local function getCropNumber(crop, key)
        local v = crop:GetAttribute(key)
        if v ~= nil and type(v) == "number" then return v end
        local c = crop:FindFirstChild(key)
        if c and (c:IsA("NumberValue") or c:IsA("IntValue") or c:IsA("DoubleConstrainedValue")) then return c.Value end
        return nil
    end

    local function refreshAllCropsByLocalPlayer()
        local list = {}
        local activeCrops = Workspace:FindFirstChild("ActiveCrops")
        if not activeCrops then
            localPlayerCropsList = list
            return list
        end
        local myUserId = Players.LocalPlayer.UserId
        for _, crop in ipairs(activeCrops:GetChildren()) do
            local ownerId = getCropNumber(crop, "OwnerId")
            if ownerId == nil then ownerId = crop:GetAttribute("OwnerId") end
            if type(ownerId) ~= "number" or ownerId ~= myUserId then continue end
            local posX = getCropNumber(crop, "PosX")
            local posZ = getCropNumber(crop, "PosZ")
            local groundY = getCropNumber(crop, "GroundY")
            table.insert(list, {
                crop = crop,
                position = Vector3.new(posX or 0, groundY or 0, posZ or 0),
            })
        end
        localPlayerCropsList = list
        return list
    end

    local function getAllCropsByLocalPlayer()
        refreshAllCropsByLocalPlayer()
        return localPlayerCropsList
    end

    local function getReadyCropsForLocalPlayer()
        refreshAllCropsByLocalPlayer()
        local list = {}
        for _, entry in ipairs(localPlayerCropsList) do
            local scaleEnd = getCropNumber(entry.crop, "ScaleEnd")
            local scaleStart = getCropNumber(entry.crop, "ScaleStart")
            if scaleEnd ~= nil and scaleStart ~= nil and scaleEnd == scaleStart then
                table.insert(list, entry)
            end
        end
        return list
    end

    do
        local activeCrops = Workspace:FindFirstChild("ActiveCrops")
        if activeCrops then
            activeCrops.ChildAdded:Connect(function() refreshAllCropsByLocalPlayer() end)
            activeCrops.ChildRemoved:Connect(function() refreshAllCropsByLocalPlayer() end)
        end
        refreshAllCropsByLocalPlayer()
    end

    local PlantSection = FarmTab:Section({
        Title = "Plant Crops",
        Desc = "Select plant, set quantity and start planting",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    -- Farm position: default until user sets current position
    local DEFAULT_FARM_POSITION = Vector3.new(-169.41416931152, 39.296875, -287.59017944336)
    local farmPosition = DEFAULT_FARM_POSITION

    local function getFarmPosition()
        return farmPosition
    end

    local function farmPositionLabelText()
        return string.format("Current farm position: %.1f, %.1f, %.1f", farmPosition.X, farmPosition.Y, farmPosition.Z)
    end

    local FarmPositionLabel = PlantSection:Section({
        Title = farmPositionLabelText(),
        Desc = "Ground position used for Start Farm and Auto Farm",
        TextSize = 13,
    })

    PlantSection:Button({
        Title = "Set current position as farm position",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                local origin = rootPart.Position
                local rayDir = Vector3.new(0, -1, 0)
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = { character }
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                local result = Workspace:Raycast(origin, rayDir * 20, raycastParams)
                if result and result.Position then
                    farmPosition = result.Position
                else
                    local humanoid = character:FindFirstChildOfClass("Humanoid")
                    local footYOffset = (humanoid and (humanoid.HipHeight + rootPart.Size.Y * 0.5) or 3)
                    farmPosition = origin - Vector3.new(0, footYOffset, 0)
                end
                local text = farmPositionLabelText()
                if FarmPositionLabel and FarmPositionLabel.Set then
                    FarmPositionLabel:Set(text)
                elseif FarmPositionLabel and FarmPositionLabel.SetTitle then
                    FarmPositionLabel:SetTitle(text)
                end
                WindUI:Notify({
                    Title = "Farm position",
                    Content = string.format("Set to ground: %.1f, %.1f, %.1f", farmPosition.X, farmPosition.Y, farmPosition.Z),
                    Icon = "check",
                })
            else
                WindUI:Notify({
                    Title = "Farm position",
                    Content = "No character. Respawn or wait and try again.",
                    Icon = "close",
                })
            end
        end,
    })

    PlantSection:Space()

    local function getBackpackToolsForPlants()
        local tools = {}
        local seen = {}
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            for _, child in ipairs(backpack:GetChildren()) do
                if child:IsA("Tool") then
                    table.insert(tools, child)
                    seen[child.Name] = true
                end
            end
        end
        local character = Players.LocalPlayer.Character
        if character then
            for _, child in ipairs(character:GetChildren()) do
                if child:IsA("Tool") and not seen[child.Name] then
                    table.insert(tools, child)
                    seen[child.Name] = true
                end
            end
        end
        return tools
    end

    local plantItems = {}
    local selectedPlant = nil

    local PlantDropdown = PlantSection:Dropdown({
        Title = "Plant",
        Desc = "Select plant from backpack",
        Values = plantItems,
        Value = nil,
        AllowNone = true,
        Callback = function(value)
            selectedPlant = value
        end
    })

    local function refreshPlantList()
        local tools = getBackpackToolsForPlants()
        plantItems = {}
        for _, tool in ipairs(tools) do
            table.insert(plantItems, tool.Name)
        end
        PlantDropdown:Refresh(plantItems)
        if selectedPlant and not table.find(plantItems, selectedPlant) then
            selectedPlant = nil
            if PlantDropdown.Select then PlantDropdown:Select(nil) end
            if PlantDropdown.Set then PlantDropdown:Set(nil) end
        end
    end

    refreshPlantList()

    do
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            backpack.ChildAdded:Connect(function(c)
                if c:IsA("Tool") then refreshPlantList() end
            end)
            backpack.ChildRemoved:Connect(function(c)
                if c:IsA("Tool") then refreshPlantList() end
            end)
        end
        local function onCharChanged(char)
            if not char then return end
            char.ChildAdded:Connect(function(c)
                if c:IsA("Tool") then refreshPlantList() end
            end)
            char.ChildRemoved:Connect(function(c)
                if c:IsA("Tool") then refreshPlantList() end
            end)
            refreshPlantList()
        end
        Players.LocalPlayer.CharacterAdded:Connect(onCharChanged)
        if Players.LocalPlayer.Character then
            onCharChanged(Players.LocalPlayer.Character)
        end
    end

    PlantSection:Space()

    local FarmQuantity = "1"

    PlantSection:Input({
        Title = "Quantity",
        Placeholder = "Enter quantity",
        Value = FarmQuantity,
        Callback = function(value)
            FarmQuantity = value
        end
    })

    PlantSection:Button({
        Title = "Start Farm",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if selectedPlant and selectedPlant ~= "" then
                local character = Players.LocalPlayer.Character
                local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
                if character and backpack then
                    local tool = backpack:FindFirstChild(selectedPlant)
                    if not tool or not tool:IsA("Tool") then
                        tool = character:FindFirstChild(selectedPlant)
                    end
                    if tool and tool:IsA("Tool") and tool.Parent == backpack then
                        for _, c in ipairs(character:GetChildren()) do
                            if c:IsA("Tool") then
                                c.Parent = backpack
                                break
                            end
                        end
                        tool.Parent = character
                    end
                end
            end

            local qty = tonumber(FarmQuantity) or 1
            local PlantCropEvent = ReplicatedStorage.Remotes.TutorialRemotes.PlantCrop
            local NotificationEvent = ReplicatedStorage.Remotes.TutorialRemotes.Notification
            local position = getFarmPosition()

            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(position)
                task.wait(0.5)
            end

            local stopRequested = false
            local connection = NotificationEvent.OnClientEvent:Connect(function(message)
                if message == "Maximum 15 crops!" then
                    stopRequested = true
                end
            end)

            local planted = 0
            for i = 1, qty do
                if stopRequested then break end
                print("Planting crop " .. i .. " of " .. qty)
                PlantCropEvent:FireServer(position)
                planted = i
                task.wait(1)
            end

            connection:Disconnect()

            WindUI:Notify({
                Title = "Farm",
                Content = "Planted " .. tostring(planted) .. " crop(s)" .. (stopRequested and " (stopped: max crops)" or ""),
                Icon = "check",
            })
        end
    })

    PlantSection:Space()

    local autoFarmRunning = false
    local autoFarmConnection = nil
    local autoFarmTeleportEnabled = false

    PlantSection:Toggle({
        Title = "Teleport",
        Desc = "Teleport to farm position when out of range",
        Callback = function(enabled)
            autoFarmTeleportEnabled = enabled
        end
    })

    PlantSection:Toggle({
        Title = "Auto Farm",
        Desc = "Continuously plant at farm position (ignores quantity); 10s delay on max crops",
        Callback = function(enabled)
            autoFarmRunning = enabled
            if autoFarmConnection then
                autoFarmConnection:Disconnect()
                autoFarmConnection = nil
            end
            if not enabled then return end

            local PlantCropEvent = ReplicatedStorage.Remotes.TutorialRemotes.PlantCrop
            local NotificationEvent = ReplicatedStorage.Remotes.TutorialRemotes.Notification
            local position = getFarmPosition()
            local gotMaxCrops = false

            autoFarmConnection = NotificationEvent.OnClientEvent:Connect(function(message)
                if message == "Maximum 15 crops!" then
                    gotMaxCrops = true
                end
            end)

            task.spawn(function()
                while autoFarmRunning do
                    if selectedPlant and selectedPlant ~= "" then
                        local character = Players.LocalPlayer.Character
                        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
                        if character and backpack then
                            local plantTool = backpack:FindFirstChild(selectedPlant) or character:FindFirstChild(selectedPlant)
                            if plantTool and plantTool:IsA("Tool") then
                                local currentTool = nil
                                for _, c in ipairs(character:GetChildren()) do
                                    if c:IsA("Tool") then
                                        currentTool = c
                                        break
                                    end
                                end
                                if currentTool ~= plantTool then
                                    if currentTool then
                                        currentTool.Parent = backpack
                                        task.wait()
                                    end
                                    plantTool.Parent = character
                                end
                            end
                        end
                    end

                    if autoFarmTeleportEnabled then
                        local char = Players.LocalPlayer.Character
                        local root = char and char:FindFirstChild("HumanoidRootPart")
                        if root and (root.Position - position).Magnitude > 5 then
                            root.CFrame = CFrame.new(position)
                            task.wait(0.5)
                        end
                    end
                    local cropCount = #getAllCropsByLocalPlayer()
                    if cropCount >= 15 then
                        task.wait(1)
                    else
                        PlantCropEvent:FireServer(position)
                        task.wait(1)
                    end
                    if gotMaxCrops then
                        gotMaxCrops = false
                        task.wait(9)
                    end
                end
            end)
        end
    })

    FarmTab:Space()

    local HarvestSection = FarmTab:Section({
        Title = "Harvest Plant",
        Desc = "Scan ActiveCrops (OwnerId + ScaleEnd==ScaleStart), teleport and harvest",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local harvestPlantRunning = false
    local harvestTeleportEnabled = false

    local function findHarvestPromptInCrop(crop)
        for _, d in ipairs(crop:GetDescendants()) do
            if d:IsA("ProximityPrompt") then return d end
        end
        return nil
    end

    HarvestSection:Toggle({
        Title = "Teleport",
        Desc = "Teleport to crop when out of range (skip if distance < 5)",
        Callback = function(enabled)
            harvestTeleportEnabled = enabled
        end
    })

    HarvestSection:Toggle({
        Title = "Harvest Plant",
        Desc = "Scan ActiveCrops every 2s; harvest ready crops (ScaleEnd==ScaleStart) owned by you",
        Callback = function(enabled)
            harvestPlantRunning = enabled
            if not enabled then return end
            task.spawn(function()
                while harvestPlantRunning do
                    local character = Players.LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then
                        task.wait(2)
                        continue
                    end

                    local readyCrops = getReadyCropsForLocalPlayer()
                    if #readyCrops == 0 then
                        task.wait(2)
                        continue
                    end

                    local playerPos = rootPart.Position
                    local nearest = nil
                    local nearestDist = math.huge
                    for _, entry in ipairs(readyCrops) do
                        local dist = (entry.position - playerPos).Magnitude
                        if dist < nearestDist then
                            nearestDist = dist
                            nearest = entry
                        end
                    end

                    if not nearest then
                        task.wait(2)
                        continue
                    end

                    local cropPos = nearest.position
                    local maxDist = 5
                    if nearestDist >= maxDist then
                        if harvestTeleportEnabled then
                            rootPart.CFrame = CFrame.new(cropPos)
                            task.wait(0.5)
                        else
                            task.wait(2)
                            continue
                        end
                    end

                    local prompt = findHarvestPromptInCrop(nearest.crop)
                    if prompt and prompt:IsA("ProximityPrompt") then
                        local originalHold = prompt.HoldDuration
                        prompt.HoldDuration = 0
                        prompt:InputHoldBegin()
                        prompt:InputHoldEnd()
                        prompt.HoldDuration = originalHold
                    end

                    task.wait(2)
                end
            end)
        end
    })

    FarmTab:Space()

    -- Palm land (owned) – LahanConfig.AreaPrefix = "AreaTanamBesar", areas in Workspace
    local LahanConfig
    do
        local ok, mod = pcall(function()
            return require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("LahanConfig", 5))
        end)
        LahanConfig = (ok and mod) and mod or nil
    end
    local areaPrefix = (LahanConfig and LahanConfig.AreaPrefix) or "AreaTanamBesar"

    local function getOwnerIdFromInstance(obj)
        local v = obj:GetAttribute("OwnerId")
        if v ~= nil and type(v) == "number" then return v end
        local c = obj:FindFirstChild("OwnerId")
        if c and (c:IsA("NumberValue") or c:IsA("IntValue") or c:IsA("DoubleConstrainedValue")) then
            return c.Value
        end
        return nil
    end

    local function getPalmLandMapText()
        local myUserId = Players.LocalPlayer.UserId
        local lines = {}
        local function add(s)
            table.insert(lines, s)
        end
        add("Palm land (prefix: " .. areaPrefix .. ")")
        add("")
        local allList = {}
        for _, child in ipairs(Workspace:GetChildren()) do
            local name = child.Name
            if name and (string.sub(name, 1, #areaPrefix) == areaPrefix or string.sub(name, 1, 9) == "AreaTanam") then
                table.insert(allList, { name = name, obj = child })
            end
        end
        table.sort(allList, function(a, b) return a.name < b.name end)
        if #allList == 0 then
            add("  (no AreaTanam* found in Workspace)")
        else
            for _, entry in ipairs(allList) do
                local ownerId = getOwnerIdFromInstance(entry.obj)
                local ownerStr = ownerId ~= nil and tostring(ownerId) or "(none)"
                local youTag = (ownerId == myUserId) and "  [you]" or ""
                add("  " .. entry.name .. "  OwnerId: " .. ownerStr .. youTag)
            end
            add("")
            local ownedCount = 0
            for _, entry in ipairs(allList) do
                if getOwnerIdFromInstance(entry.obj) == myUserId then
                    ownedCount = ownedCount + 1
                end
            end
            add("Owned by you: " .. ownedCount .. " / " .. #allList)
        end
        return table.concat(lines, "\n")
    end

    local PalmLandSection = FarmTab:Section({
        Title = "Palm land",
        Desc = "Map of all palm land and OwnerId (tap Refresh to update)",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local palmLandResultLabel = PalmLandSection:Section({
        Title = "Result: (tap Refresh to load)",
        TextSize = 12,
    })

    PalmLandSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local text = getPalmLandMapText()
            if palmLandResultLabel and palmLandResultLabel.Set then
                palmLandResultLabel:Set(text)
            elseif palmLandResultLabel and palmLandResultLabel.SetTitle then
                palmLandResultLabel:SetTitle(text)
            end
        end,
    })

    FarmTab:Space()

    local GrowthDurationTestSection = FarmTab:Section({
        Title = "Plant Growth Duration (Test)",
        Desc = "Inspect where growth duration might be stored",
        Box = true,
        BoxBorder = true,
        Opened = false,
    })

    local lp = Players.LocalPlayer
    GrowthDurationTestSection:Section({
        Title = "Owner ID: " .. tostring(lp.UserId),
        Desc = "Name: " .. tostring(lp.Name),
        TextSize = 14,
    })

    local growthDurationResultLabel = GrowthDurationTestSection:Section({
        Title = "Result: (not run)",
        TextSize = 12,
    })

    local function tryGetGrowthDurationInfo()
        local out = {}
        local function add(line)
            table.insert(out, line)
        end

        local TutorialRemotes = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("TutorialRemotes")
        if not TutorialRemotes then
            add("TutorialRemotes not found")
        else
            add("TutorialRemotes children:")
            for _, child in ipairs(TutorialRemotes:GetChildren()) do
                local nameLower = child.Name:lower()
                if nameLower:find("plant") or nameLower:find("crop") or nameLower:find("growth") or nameLower:find("farm") then
                    add("  " .. child.Name .. " [" .. child.ClassName .. "]")
                end
                if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
                    local ok, ret = pcall(function()
                        if child:IsA("RemoteFunction") and (nameLower:find("plant") or nameLower:find("crop") or nameLower:find("get")) then
                            return child:InvokeServer()
                        end
                    end)
                    if ok and ret ~= nil then
                        add("    InvokeServer() -> " .. tostring(ret))
                        if type(ret) == "table" then
                            for k, v in pairs(ret) do
                                add("      " .. tostring(k) .. " = " .. tostring(v))
                            end
                        end
                    end
                end
            end
        end

        local function scanForValues(parent, depth, path)
            if depth > 3 then return end
            path = path or "ReplicatedStorage"
            for _, child in ipairs(parent:GetChildren()) do
                local nameLower = child.Name:lower()
                if child:IsA("NumberValue") or child:IsA("IntValue") or child:IsA("DoubleConstrainedValue") then
                    if nameLower:find("growth") or nameLower:find("duration") or nameLower:find("time") or nameLower:find("plant") then
                        add(path .. "/" .. child.Name .. " = " .. tostring(child.Value))
                    end
                end
                if child:IsA("Configuration") or child:IsA("Folder") then
                    if nameLower:find("plant") or nameLower:find("crop") or nameLower:find("farm") or nameLower:find("config") or depth == 0 then
                        scanForValues(child, depth + 1, path .. "/" .. child.Name)
                    end
                end
            end
        end
        add("")
        add("ReplicatedStorage values (growth/duration/time/plant):")
        scanForValues(ReplicatedStorage, 0)

        local Workspace = game:GetService("Workspace")
        add("")
        add("Workspace models (root/plant/crop) attributes:")
        for _, desc in ipairs(Workspace:GetDescendants()) do
            if desc:IsA("Model") then
                local nameLower = desc.Name:lower()
                if nameLower:find("root") or nameLower:find("plant") or nameLower:find("crop") then
                    local attrs = desc:GetAttributes()
                    if next(attrs) then
                        add("  " .. desc:GetFullName() .. ":")
                        for k, v in pairs(attrs) do
                            if type(k) == "string" and (k:lower():find("growth") or k:lower():find("duration") or k:lower():find("time")) or type(v) == "number" then
                                add("    " .. tostring(k) .. " = " .. tostring(v))
                            end
                        end
                    end
                end
            end
        end

        if #out == 0 then
            add("No obvious growth/duration keys found in scan.")
        end
        return table.concat(out, "\n")
    end

    GrowthDurationTestSection:Button({
        Title = "Inspect for growth duration",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local text = tryGetGrowthDurationInfo()
            if growthDurationResultLabel and growthDurationResultLabel.Set then
                growthDurationResultLabel:Set(text)
            elseif growthDurationResultLabel and growthDurationResultLabel.SetTitle then
                growthDurationResultLabel:SetTitle(text)
            end
            WindUI:Notify({
                Title = "Growth Duration (Test)",
                Content = #text > 200 and (text:sub(1, 200) .. "...") or text,
                Icon = "check",
            })
        end
    })
end

-- */  Automation Tab  /* --
do
    local AutomationTab = ElementsSection:Tab({
        Title = "Automation",
        Icon = "solar:play-circle-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    local AutoPayungSection = AutomationTab:Section({
        Title = "Auto Payung",
        Desc = "Auto equip Payung when raining",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local isRaining = false
    local autoPayungRunning = false

    local function equipPayung()
        local character = Players.LocalPlayer.Character
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        if not character or not backpack then return false end
        local payung = backpack:FindFirstChild("Payung")
        if not payung or not payung:IsA("Tool") then return false end
        for _, c in ipairs(character:GetChildren()) do
            if c:IsA("Tool") then
                c.Parent = backpack
                break
            end
        end
        payung.Parent = character
        return true
    end

    do
        local RainSync = ReplicatedStorage.Remotes.TutorialRemotes:FindFirstChild("RainSync")
        if RainSync then
            rainSyncConnection = RainSync.OnClientEvent:Connect(function(raining, _)
                isRaining = (raining == true)
            end)
        end
    end

    AutoPayungSection:Toggle({
        Title = "Auto equip Payung when raining",
        Callback = function(enabled)
            autoPayungRunning = enabled
            if not enabled then return end
            task.spawn(function()
                while autoPayungRunning do
                    if isRaining then
                        equipPayung()
                    end
                    local elapsed = 0
                    while elapsed < 2 and autoPayungRunning do
                        task.wait(1)
                        elapsed = elapsed + 1
                    end
                end
            end)
        end
    })

    AutoPayungSection:Space()

    AutomationTab:Space()

    local AutoShowerSection = AutomationTab:Section({
        Title = "Auto Shower",
        Desc = "When hygiene <= 50, teleport to nearest Mandi and interact",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local hygieneSyncConnection = nil

    local function findMandiObjects()
        local list = {}
        local function scan(parent)
            for _, child in ipairs(parent:GetDescendants()) do
                if child:IsA("ProximityPrompt") then
                    local name = (child.Parent and child.Parent.Name or ""):lower()
                    if name:find("mandi") then
                        table.insert(list, child)
                    end
                end
            end
        end
        scan(game:GetService("Workspace"))
        return list
    end

    local function getPosition(obj)
        if obj:IsA("BasePart") then
            return obj.Position
        end
        if obj:IsA("Model") and obj.PrimaryPart then
            return obj.PrimaryPart.Position
        end
        if obj:IsA("Model") then
            local p, _ = obj:GetBoundingBox()
            return p.Position
        end
        if obj.Parent and obj.Parent:IsA("BasePart") then
            return obj.Parent.Position
        end
        if obj.Parent and obj.Parent:IsA("Model") and obj.Parent.PrimaryPart then
            return obj.Parent.PrimaryPart.Position
        end
        return nil
    end

    local function interactWithMandi(promptOrObj)
        local prompt = promptOrObj:IsA("ProximityPrompt") and promptOrObj or nil
        if not prompt then
            prompt = promptOrObj:FindFirstChildOfClass("ProximityPrompt") or promptOrObj:FindFirstChild("ProximityPrompt")
        end
        if not prompt then
            for _, d in ipairs(promptOrObj:GetDescendants()) do
                if d:IsA("ProximityPrompt") then
                    prompt = d
                    break
                end
            end
        end
        if prompt and prompt:IsA("ProximityPrompt") then
            local originalHold = prompt.HoldDuration
            prompt.HoldDuration = 0
            prompt:InputHoldBegin()
            prompt:InputHoldEnd()
            prompt.HoldDuration = originalHold
            return true
        end
        return false
    end

    AutoShowerSection:Toggle({
        Title = "Auto Shower (hygiene <= 50)",
        Callback = function(enabled)
            if hygieneSyncConnection then
                hygieneSyncConnection:Disconnect()
                hygieneSyncConnection = nil
            end
            if enabled then
                local HygieneSync = ReplicatedStorage.Remotes.TutorialRemotes:FindFirstChild("HygieneSync")
                if HygieneSync then
                    hygieneSyncConnection = HygieneSync.OnClientEvent:Connect(function(value)
                        local hygiene = type(value) == "number" and value or tonumber(value)
                        if hygiene ~= nil and hygiene <= 50 then
                            local character = Players.LocalPlayer.Character
                            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                            if not rootPart then return end
                            local mandiList = findMandiObjects()
                            if #mandiList == 0 then return end
                            local playerPos = rootPart.Position
                            local nearest, nearestDist = nil, math.huge
                            for _, obj in ipairs(mandiList) do
                                local pos = getPosition(obj)
                                if pos then
                                    local dist = (pos - playerPos).Magnitude
                                    if dist < nearestDist then
                                        nearestDist = dist
                                        nearest = obj
                                    end
                                end
                            end
                            if not nearest then return end
                            local pos = getPosition(nearest)
                            if pos then
                                local positionBeforeShower = rootPart.CFrame
                                rootPart.CFrame = CFrame.new(pos + Vector3.new(0, 0, 3))
                                task.wait(1)
                                interactWithMandi(nearest)
                                task.wait(3)
                                if rootPart and rootPart.Parent then
                                    rootPart.CFrame = positionBeforeShower
                                end
                            end
                        end
                    end)
                end
            end
        end
    })
end

-- */  Teleport Tab  /* --
do
    local TeleportTab = ElementsSection:Tab({
        Title = "Teleport",
        Icon = "solar:map-point-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    local TeleportToObjectSection = TeleportTab:Section({
        Title = "Teleport to Object",
        Desc = "Select a ProximityPrompt object and teleport to it",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local promptDisplayNames = {}
    local promptList = {}
    local selectedTeleportPrompt = nil
    local TeleportDropdown

    local function getPromptPosition(prompt)
        if prompt.Parent and prompt.Parent:IsA("BasePart") then
            return prompt.Parent.Position
        end
        if prompt.Parent and prompt.Parent:IsA("Model") and prompt.Parent.PrimaryPart then
            return prompt.Parent.PrimaryPart.Position
        end
        if prompt.Parent and prompt.Parent:IsA("Model") then
            local p, _ = prompt.Parent:GetBoundingBox()
            return p.Position
        end
        return nil
    end

    local function refreshTeleportList(showNotify)
        local prompts = {}
        for _, child in ipairs(game:GetService("Workspace"):GetDescendants()) do
            if child:IsA("ProximityPrompt") then
                table.insert(prompts, child)
            end
        end
        promptList = prompts
        promptDisplayNames = {}
        local count = {}
        for _, p in ipairs(prompts) do
            local label = (p.ObjectText and #p.ObjectText > 0) and p.ObjectText or (p.Parent and p.Parent.Name or "ProximityPrompt")
            count[label] = (count[label] or 0) + 1
            local display = count[label] > 1 and (label .. " (" .. count[label] .. ")") or label
            table.insert(promptDisplayNames, display)
        end
        TeleportDropdown:Refresh(promptDisplayNames)
        if selectedTeleportPrompt then
            local idx = table.find(promptList, selectedTeleportPrompt)
            if not idx then
                selectedTeleportPrompt = nil
                if TeleportDropdown.Select then TeleportDropdown:Select(nil) end
                if TeleportDropdown.Set then TeleportDropdown:Set(nil) end
            end
        end
        if showNotify then
            WindUI:Notify({ Title = "Teleport", Content = "List refreshed (" .. #promptList .. " objects)", Icon = "check" })
        end
    end

    TeleportDropdown = TeleportToObjectSection:Dropdown({
        Title = "Object",
        Desc = "Select object to teleport to",
        Values = promptDisplayNames,
        Value = nil,
        AllowNone = true,
        Callback = function(value)
            selectedTeleportPrompt = nil
            if value then
                local idx = table.find(promptDisplayNames, value)
                if idx and promptList[idx] then
                    selectedTeleportPrompt = promptList[idx]
                end
            end
        end
    })

    TeleportToObjectSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshTeleportList(true)
        end
    })

    TeleportToObjectSection:Space()

    TeleportToObjectSection:Button({
        Title = "Teleport",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedTeleportPrompt then
                WindUI:Notify({ Title = "Teleport", Content = "Select an object first", Icon = "x" })
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                WindUI:Notify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local pos = getPromptPosition(selectedTeleportPrompt)
            if not pos then
                WindUI:Notify({ Title = "Teleport", Content = "Could not get object position", Icon = "x" })
                return
            end
            rootPart.CFrame = CFrame.new(pos + Vector3.new(0, 0, 3))
            WindUI:Notify({ Title = "Teleport", Content = "Teleported to object", Icon = "check" })
        end
    })

    TeleportToObjectSection:Space()

    local tweenDurationValue = "5"
    TeleportToObjectSection:Input({
        Title = "Tween Duration",
        Placeholder = "e.g. 5",
        Value = tweenDurationValue,
        Callback = function(value)
            tweenDurationValue = value
        end
    })

    TeleportToObjectSection:Button({
        Title = "Tween to Location",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedTeleportPrompt then
                WindUI:Notify({ Title = "Teleport", Content = "Select an object first", Icon = "x" })
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                WindUI:Notify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local pos = getPromptPosition(selectedTeleportPrompt)
            if not pos then
                WindUI:Notify({ Title = "Teleport", Content = "Could not get object position", Icon = "x" })
                return
            end
            local targetPos = pos + Vector3.new(0, 0, 3)
            local duration = tonumber(tweenDurationValue) or 5
            if duration < 0.1 then duration = 0.1 end
            local tweenInfo = TweenInfo.new(duration)
            local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = CFrame.new(targetPos) })
            tween:Play()
            WindUI:Notify({ Title = "Teleport", Content = "Tweening to object (" .. tostring(duration) .. "s)", Icon = "check" })
        end
    })

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
        PlayerTeleportDropdown:Refresh(playerDisplayNames)
        if selectedTeleportPlayer then
            if not table.find(playerList, selectedTeleportPlayer) then
                selectedTeleportPlayer = nil
                if PlayerTeleportDropdown.Select then PlayerTeleportDropdown:Select(nil) end
                if PlayerTeleportDropdown.Set then PlayerTeleportDropdown:Set(nil) end
            end
        end
        if showNotify then
            WindUI:Notify({ Title = "Teleport", Content = "Player list refreshed (" .. #playerList .. " players)", Icon = "check" })
        end
    end

    PlayerTeleportDropdown = TeleportToPlayersSection:Dropdown({
        Title = "Player",
        Desc = "Select player to teleport to",
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
            noClipEnabled = enabled
            local character = Players.LocalPlayer.Character
            applyNoClip(character, enabled)
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

    do
        Players.LocalPlayer.CharacterAdded:Connect(function(character)
            if flyEnabled then
                task.defer(function() startFly() end)
            end
            if noClipEnabled then
                applyNoClip(character, true)
                character.DescendantAdded:Connect(function(part)
                    if noClipEnabled and part:IsA("BasePart") then
                        part.CanCollide = false
                    end
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

    -- Humanoid fields to read via pcall (some may not exist on older clients).
    local HUMANOID_INSPECT_PROPERTIES = {
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

    local function buildPlayersInfoText(player)
        if not player then
            return "Select a player from the list."
        end
        local lines = {}
        table.insert(lines, "Username: " .. player.Name)
        local dn = player.DisplayName
        table.insert(lines, "Display name: " .. ((dn and dn ~= "") and dn or "(same as username)"))
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
        if humanoid then
            table.insert(lines, "Humanoid properties:")
            local propRows = {}
            for _, propName in ipairs(HUMANOID_INSPECT_PROPERTIES) do
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

    --[[ Equipment section: dropdown of Backpack tools + Equip button (commented out)
    local function getBackpackToolsInOrder()
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return {} end
        local tools = {}
        for _, child in ipairs(backpack:GetChildren()) do
            if child:IsA("Tool") then
                table.insert(tools, child)
            end
        end
        return tools
    end

    local EquipmentSection = LocalPlayerTab:Section({
        Title = "Equipment",
        Desc = "Select an item and equip it",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local function getEquippedToolName()
        local character = Players.LocalPlayer.Character
        if not character then return nil end
        for _, c in ipairs(character:GetChildren()) do
            if c:IsA("Tool") then return c.Name end
        end
        return nil
    end

    local EquippedLabel = EquipmentSection:Section({
        Title = "Equipped: (none)",
        TextSize = 14,
    })

    local function updateEquippedLabel()
        local name = getEquippedToolName()
        local text = "Equipped: " .. (name or "(none)")
        if EquippedLabel and EquippedLabel.Set then
            EquippedLabel:Set(text)
        elseif EquippedLabel and EquippedLabel.SetTitle then
            EquippedLabel:SetTitle(text)
        end
    end

    local equipmentItems = {}
    local selectedEquipment = nil

    local EquipmentDropdown = EquipmentSection:Dropdown({
        Title = "Item",
        Desc = "Select item to equip",
        Values = equipmentItems,
        Value = nil,
        AllowNone = true,
        Callback = function(value)
            selectedEquipment = value
        end
    })

    local function refreshEquipmentList(showNotify)
        local tools = getBackpackToolsInOrder()
        equipmentItems = {}
        for _, tool in ipairs(tools) do
            table.insert(equipmentItems, tool.Name)
        end
        EquipmentDropdown:Refresh(equipmentItems)
        if selectedEquipment and not table.find(equipmentItems, selectedEquipment) then
            selectedEquipment = nil
            if EquipmentDropdown.Select then
                EquipmentDropdown:Select(nil)
            elseif EquipmentDropdown.Set then
                EquipmentDropdown:Set(nil)
            end
        end
        updateEquippedLabel()
        if showNotify then
            WindUI:Notify({ Title = "Equipment", Content = "List refreshed (" .. #equipmentItems .. " items)", Icon = "check" })
        end
    end

    refreshEquipmentList(false)

    local function onCharacterToolChanged()
        updateEquippedLabel()
    end
    local function onCharacterChanged(character)
        if character then
            character.ChildAdded:Connect(function(c) if c:IsA("Tool") then onCharacterToolChanged() end end)
            character.ChildRemoved:Connect(function(c) if c:IsA("Tool") then onCharacterToolChanged() end end)
            onCharacterToolChanged()
        end
    end
    Players.LocalPlayer.CharacterAdded:Connect(onCharacterChanged)
    if Players.LocalPlayer.Character then
        onCharacterChanged(Players.LocalPlayer.Character)
    end

    do
        local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            backpack.ChildAdded:Connect(function(c)
                if c:IsA("Tool") then refreshEquipmentList(false) end
            end)
            backpack.ChildRemoved:Connect(function(c)
                if c:IsA("Tool") then refreshEquipmentList(false) end
            end)
        end
    end

    EquipmentSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshEquipmentList(true)
        end
    })

    EquipmentSection:Space()

    EquipmentSection:Button({
        Title = "Equip",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedEquipment or selectedEquipment == "" then
                WindUI:Notify({ Title = "Equipment", Content = "No item selected", Icon = "x" })
                return
            end
            local character = Players.LocalPlayer.Character
            if not character then
                WindUI:Notify({ Title = "Equipment", Content = "Character not loaded", Icon = "x" })
                return
            end
            local backpack = Players.LocalPlayer:FindFirstChild("Backpack")
            if not backpack then
                WindUI:Notify({ Title = "Equipment", Content = "Backpack not found", Icon = "x" })
                return
            end
            local tool = backpack:FindFirstChild(selectedEquipment)
            if not tool or not tool:IsA("Tool") then
                WindUI:Notify({ Title = "Equipment", Content = "Item not in backpack: " .. tostring(selectedEquipment), Icon = "x" })
                return
            end
            for _, c in ipairs(character:GetChildren()) do
                if c:IsA("Tool") then
                    c.Parent = backpack
                    break
                end
            end
            tool.Parent = character
            selectedEquipment = nil
            refreshEquipmentList(false)
            if EquipmentDropdown.Select then
                EquipmentDropdown:Select(nil)
            end
            WindUI:Notify({ Title = "Equipment", Content = "Equipped: " .. tostring(tool.Name), Icon = "check" })
        end
    })

    LocalPlayerTab:Space()
    --]]

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
end

-- */  Shop Tab  /* --
do
    local ShopTab = ElementsSection:Tab({
        Title = "Shop",
        Icon = "solar:folder-2-bold-duotone",
        IconColor = Green,
        IconShape = "Square",
        Border = true,
    })

    -- */  Buy Section  /* --
    local BuySection = ShopTab:Section({
        Title = "Buy",
        Desc = "Select item and quantity to buy",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local buyItems = {}
    local buyItemData = {}
    local selectedBuyItem = nil
    local buyQty = "1"
    local buyDelaySeconds = "1"
    local autoBuyRunning = false

    local BuyDropdown = BuySection:Dropdown({
        Title = "Item",
        Desc = "Select item to buy",
        Values = buyItems,
        Value = nil,
        AllowNone = true,
        Callback = function(value)
            selectedBuyItem = value
        end
    })

    BuySection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestShop
            local Result = Event:InvokeServer("GET_LIST")
            local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
            if ExpectedResult and ExpectedResult.Seeds and type(ExpectedResult.Seeds) == "table" then
                buyItemData = {}
                buyItems = {}
                for _, item in ipairs(ExpectedResult.Seeds) do
                    if not item.Locked then
                        table.insert(buyItemData, item)
                        table.insert(buyItems, item.DisplayName or item.Name or tostring(item))
                    end
                end
                BuyDropdown:Refresh(buyItems)
            end
            WindUI:Notify({
                Title = "Buy",
                Content = ExpectedResult and ExpectedResult.Success and ("List refreshed" .. (ExpectedResult.Coins and (" • Coins: " .. tostring(ExpectedResult.Coins)) or "")) or "List refreshed",
                Icon = "check",
            })
        end
    })

    BuySection:Space()

    BuySection:Input({
        Title = "Quantity",
        Placeholder = "Enter quantity",
        Value = buyQty,
        Callback = function(value)
            buyQty = value
        end
    })

    BuySection:Space()

    BuySection:Button({
        Title = "Buy",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if selectedBuyItem == nil then
                WindUI:Notify({ Title = "Buy", Content = "No item selected", Icon = "x" })
                return
            end
            local selectedData = nil
            for _, item in ipairs(buyItemData) do
                if (item.DisplayName or item.Name) == selectedBuyItem then
                    selectedData = item
                    break
                end
            end
            if not selectedData then
                WindUI:Notify({ Title = "Buy", Content = "Item not found", Icon = "x" })
                return
            end
            local name = selectedData.Name
            local qty = tonumber(buyQty) or 1
            local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestShop
            local Result = Event:InvokeServer("BUY", name, qty)
            local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
            WindUI:Notify({
                Title = ExpectedResult and ExpectedResult.Success and "Success" or "Failed",
                Content = ExpectedResult and ExpectedResult.Message or "Unknown error",
                Icon = ExpectedResult and ExpectedResult.Success and "check" or "x",
            })
        end
    })

    BuySection:Space()

    BuySection:Input({
        Title = "Delay (seconds)",
        Placeholder = "Seconds between auto buys",
        Value = buyDelaySeconds,
        Callback = function(value)
            buyDelaySeconds = value
        end
    })

    BuySection:Toggle({
        Title = "Auto Buy",
        Desc = "Repeatedly buy selected item; depends on quantity (uses quantity above for each buy) and delay between each buy",
        Callback = function(enabled)
            autoBuyRunning = enabled
            if not enabled then return end
            task.spawn(function()
                local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestShop
                while autoBuyRunning do
                    if selectedBuyItem then
                        local selectedData = nil
                        for _, item in ipairs(buyItemData) do
                            if (item.DisplayName or item.Name) == selectedBuyItem then
                                selectedData = item
                                break
                            end
                        end
                        if selectedData then
                            local name = selectedData.Name
                            local qty = tonumber(buyQty) or 1
                            local Result = Event:InvokeServer("BUY", name, qty)
                            local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
                            WindUI:Notify({
                                Title = ExpectedResult and ExpectedResult.Success and "Auto Buy" or "Auto Buy Failed",
                                Content = ExpectedResult and ExpectedResult.Message or "Unknown error",
                                Icon = ExpectedResult and ExpectedResult.Success and "check" or "x",
                            })
                        end
                    end
                    local delay = tonumber(buyDelaySeconds) or 1
                    delay = math.max(0.1, delay)
                    task.wait(delay)
                end
            end)
        end
    })

    BuySection:Space()

    ShopTab:Space()

    -- */  Sell Section  /* --
    local SellSection = ShopTab:Section({
        Title = "Sell",
        Desc = "Select item and sell",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local sellItems = {}
    local sellItemData = {}
    local selectedSellItems = {}

    local SelectedLabel = SellSection:Section({
        Title = "Selected: (none)",
        TextSize = 14,
    })

    local SellDropdown = SellSection:Dropdown({
        Title = "Item",
        Desc = "Select item(s) to sell",
        Values = sellItems,
        Value = {},
        AllowNone = true,
        Multi = true,
        Callback = function(selected)
            selectedSellItems = type(selected) == "table" and selected or (selected and { selected } or {})
            local text = #selectedSellItems == 0 and "(none)" or table.concat(selectedSellItems, ", ")
            if SelectedLabel and SelectedLabel.Set then
                SelectedLabel:Set("Selected: " .. text)
            elseif SelectedLabel and SelectedLabel.SetTitle then
                SelectedLabel:SetTitle("Selected: " .. text)
            end
        end
    })

    SellSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
            local Result = Event:InvokeServer("GET_LIST")
            local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
            if ExpectedResult and ExpectedResult.Items and type(ExpectedResult.Items) == "table" then
                sellItemData = {}
                sellItems = {}
                for _, item in ipairs(ExpectedResult.Items) do
                    local owned = type(item.Owned) == "number" and item.Owned or 0
                    if owned > 0 then
                        table.insert(sellItemData, item)
                        table.insert(sellItems, (item.DisplayName or item.Name or tostring(item)) .. " (x" .. tostring(owned) .. ")")
                    end
                end
                SellDropdown:Refresh(sellItems)
            end
            WindUI:Notify({
                Title = "Sell",
                Content = ExpectedResult and ExpectedResult.Success and ("List refreshed" .. (ExpectedResult.Coins and (" • Coins: " .. tostring(ExpectedResult.Coins)) or "")) or "List refreshed",
                Icon = "check",
            })
        end
    })

    SellSection:Space()

    SellSection:Button({
        Title = "Sell",
        Justify = "Center",
        Icon = "",
        Callback = function()
            if not selectedSellItems or #selectedSellItems == 0 then
                WindUI:Notify({ Title = "Sell", Content = "No item selected", Icon = "x" })
                return
            end
            local selectedDataList = {}
            for _, item in ipairs(sellItemData) do
                local owned = type(item.Owned) == "number" and item.Owned or 0
                local displayStr = (item.DisplayName or item.Name or tostring(item)) .. " (x" .. tostring(owned) .. ")"
                for _, sel in ipairs(selectedSellItems) do
                    if displayStr == sel then
                        table.insert(selectedDataList, item)
                        break
                    end
                end
            end

            local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
            for i, item in ipairs(selectedDataList) do
                local name = item.Name
                local qty = type(item.Owned) == "number" and item.Owned or 0
                local Result = Event:InvokeServer("SELL", name, qty)
                local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
                if ExpectedResult and ExpectedResult.Message then
                    WindUI:Notify({
                        Title = "Sell",
                        Content = ExpectedResult.Message,
                        Icon = ExpectedResult.Success and "check" or "x",
                    })
                    if ExpectedResult.Success then
                        local owned = type(item.Owned) == "number" and item.Owned or 0
                        local displayStr = (item.DisplayName or item.Name or tostring(item)) .. " (x" .. tostring(owned) .. ")"
                        for j = #sellItems, 1, -1 do
                            if sellItems[j] == displayStr then
                                table.remove(sellItems, j)
                                break
                            end
                        end
                        for j = #sellItemData, 1, -1 do
                            if sellItemData[j].Name == item.Name then
                                table.remove(sellItemData, j)
                                break
                            end
                        end
                        for j = #selectedSellItems, 1, -1 do
                            if selectedSellItems[j] == displayStr then
                                table.remove(selectedSellItems, j)
                                break
                            end
                        end
                        SellDropdown:Refresh(sellItems)
                        if SellDropdown.Select then
                            SellDropdown:Select(selectedSellItems)
                        end
                        local text = #selectedSellItems == 0 and "(none)" or table.concat(selectedSellItems, ", ")
                        if SelectedLabel and SelectedLabel.Set then
                            SelectedLabel:Set("Selected: " .. text)
                        elseif SelectedLabel and SelectedLabel.SetTitle then
                            SelectedLabel:SetTitle("Selected: " .. text)
                        end
                    end
                end
                if i < #selectedDataList then
                    task.wait(1)
                end
            end
        end
    })

    SellSection:Space()

    -- */  Auto Sell Section  /* --
    ShopTab:Space()
    local AutoSellSection = ShopTab:Section({
        Title = "Auto Sell",
        Desc = "Repeatedly sell selected items with a delay",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local autoSellItems = {}
    local autoSellItemData = {}
    local selectedAutoSellItems = {}
    local AutoSellSelectedLabel = AutoSellSection:Section({
        Title = "Selected: (none)",
        TextSize = 14,
    })

    local AutoSellDropdown = AutoSellSection:Dropdown({
        Title = "Item",
        Desc = "Select item(s) to auto sell",
        Values = autoSellItems,
        Value = {},
        AllowNone = true,
        Multi = true,
        Callback = function(selected)
            selectedAutoSellItems = type(selected) == "table" and selected or (selected and { selected } or {})
            local parts = {}
            for _, s in ipairs(selectedAutoSellItems) do
                parts[#parts + 1] = s:match("^(.+) %(x%d+%)$") or s
            end
            local text = #parts == 0 and "(none)" or table.concat(parts, ", ")
            if AutoSellSelectedLabel and AutoSellSelectedLabel.Set then
                AutoSellSelectedLabel:Set("Selected: " .. text)
            elseif AutoSellSelectedLabel and AutoSellSelectedLabel.SetTitle then
                AutoSellSelectedLabel:SetTitle("Selected: " .. text)
            end
        end
    })

    local function getAutoSellItemBaseName(item)
        return item.DisplayName or item.Name or tostring(item)
    end

    -- Reusable refresh: updates autoSellItemData and autoSellItems. Returns true if refresh succeeded.
    local function refreshAutoSellList(showNotify)
        local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
        local Result = Event:InvokeServer("GET_LIST")
        local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
        if not (ExpectedResult and ExpectedResult.Items and type(ExpectedResult.Items) == "table") then
            if showNotify then
                WindUI:Notify({ Title = "Auto Sell", Content = "List refreshed", Icon = "check" })
            end
            return false
        end
        local refreshByName = {}
        for _, item in ipairs(ExpectedResult.Items) do
            if item.Name then
                refreshByName[item.Name] = item
            end
        end
        for _, item in ipairs(autoSellItemData) do
            local fromRefresh = item.Name and refreshByName[item.Name]
            if fromRefresh then
                item.Owned = type(fromRefresh.Owned) == "number" and fromRefresh.Owned or 0
            else
                item.Owned = 0
            end
        end
        local existingNames = {}
        for _, item in ipairs(autoSellItemData) do
            existingNames[item.Name] = true
        end
        for _, item in ipairs(ExpectedResult.Items) do
            if item.Name and not existingNames[item.Name] then
                existingNames[item.Name] = true
                table.insert(autoSellItemData, item)
                table.insert(autoSellItems, getAutoSellItemBaseName(item))
            end
        end
        AutoSellDropdown:Refresh(autoSellItems)
        if showNotify then
            WindUI:Notify({
                Title = "Auto Sell",
                Content = ExpectedResult and ExpectedResult.Success and ("List refreshed" .. (ExpectedResult.Coins and (" • Coins: " .. tostring(ExpectedResult.Coins)) or "")) or "List refreshed",
                Icon = "check",
            })
        end
        return true
    end

    AutoSellSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshAutoSellList(true)
        end
    })

    AutoSellSection:Space()

    local autoSellDelaySeconds = "1"
    local autoSellRunning = false

    AutoSellSection:Input({
        Title = "Delay (seconds)",
        Placeholder = "Seconds between auto sell actions",
        Value = autoSellDelaySeconds,
        Callback = function(value)
            autoSellDelaySeconds = value
        end
    })

    AutoSellSection:Toggle({
        Title = "Auto Sell",
        Desc = "Repeatedly sell all selected items; delay between each sell action",
        Callback = function(enabled)
            autoSellRunning = enabled
            if not enabled then return end
            task.spawn(function()
                local Event = ReplicatedStorage.Remotes.TutorialRemotes.RequestSell
                while autoSellRunning do
                    refreshAutoSellList(false)
                    local toSell = {}
                    for _, displayStr in ipairs(selectedAutoSellItems) do
                        local baseName = displayStr:match("^(.+) %(x%d+%)$") or displayStr
                        for _, item in ipairs(autoSellItemData) do
                            if getAutoSellItemBaseName(item) == baseName then
                                local owned = type(item.Owned) == "number" and item.Owned or 0
                                if owned > 0 then
                                    table.insert(toSell, { name = item.Name, owned = owned, item = item })
                                end
                                break
                            end
                        end
                    end
                    for _, entry in ipairs(toSell) do
                        if not autoSellRunning then break end
                        local Result = Event:InvokeServer("SELL", entry.name, entry.owned)
                        local ExpectedResult = type(Result) == "table" and Result or (select(1, Result))
                        local success = ExpectedResult and ExpectedResult.Success
                        local message = (ExpectedResult and ExpectedResult.Message) or (success and "Sold" or "Failed")
                        WindUI:Notify({
                            Title = "Auto Sell",
                            Content = message,
                            Icon = success and "check" or "x",
                        })
                        if ExpectedResult and ExpectedResult.Success and entry.item then
                            entry.item.Owned = 0
                            for i, dataItem in ipairs(autoSellItemData) do
                                if dataItem == entry.item and autoSellItems[i] then
                                    autoSellItems[i] = getAutoSellItemBaseName(entry.item)
                                    AutoSellDropdown:Refresh(autoSellItems)
                                    break
                                end
                            end
                        end
                        if autoSellRunning and entry ~= toSell[#toSell] then
                            task.wait(1)
                        end
                    end
                    local delay = math.max(0.1, tonumber(autoSellDelaySeconds) or 1)
                    task.wait(delay)
                end
            end)
        end
    })

    AutoSellSection:Space()
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

    local function shouldNestOneLevelInObjectsList(inst)
        return inst:IsA("Folder") or inst:IsA("Backpack") or inst:IsA("StarterGear")
    end

    local ReplicatedStorageSection = ObjectsTab:Section({
        Title = "ReplicatedStorage",
        Desc = "All direct children of ReplicatedStorage (key = Name, value = ClassName)",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local rsDisplayList = {}
    local rsKeyValueList = {}
    local ReplicatedStorageDropdown
    local ReplicatedStorageChildrenParagraph

    local function refreshReplicatedStorageList()
        rsDisplayList = {}
        rsKeyValueList = {}
        for _, child in ipairs(ReplicatedStorage:GetChildren()) do
            local display = formatInstanceDisplay(child, nil, true)
            table.insert(rsDisplayList, display)
            rsKeyValueList[display] = { key = child.Name, value = child.ClassName, instance = child }
        end
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
        Callback = function(selectedDisplay)
            if not selectedDisplay then
                if ReplicatedStorageChildrenParagraph and ReplicatedStorageChildrenParagraph.SetDesc then
                    ReplicatedStorageChildrenParagraph:SetDesc("Select an object above to list its children")
                end
                return
            end
            local entry = rsKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local lines = {}
            for _, child in ipairs(entry.instance:GetChildren()) do
                table.insert(lines, formatInstanceDisplay(child, nil, true))
                if shouldNestOneLevelInObjectsList(child) then
                    for _, sub in ipairs(child:GetChildren()) do
                        table.insert(lines, "  " .. formatInstanceDisplay(sub, nil, true))
                    end
                end
            end
            local text = table.concat(lines, "\n")
            if #lines == 0 then
                text = "(no children)"
            end
            if ReplicatedStorageChildrenParagraph and ReplicatedStorageChildrenParagraph.SetDesc then
                ReplicatedStorageChildrenParagraph:SetDesc(text)
            end
        end
    })

    ReplicatedStorageChildrenParagraph = ReplicatedStorageSection:Paragraph({
        Title = "Children (key = value)",
        Desc = "Select an object above to list its children",
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
    local plrsKeyValueList = {}
    local PlayersServiceDropdown
    local PlayersServiceChildrenParagraph

    local function refreshPlayersServiceList()
        plrsDisplayList = {}
        plrsKeyValueList = {}
        for _, child in ipairs(Players:GetChildren()) do
            local display = formatInstanceDisplay(child, nil, true)
            table.insert(plrsDisplayList, display)
            plrsKeyValueList[display] = { key = child.Name, value = child.ClassName, instance = child }
        end
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
        Callback = function(selectedDisplay)
            if not selectedDisplay then
                if PlayersServiceChildrenParagraph and PlayersServiceChildrenParagraph.SetDesc then
                    PlayersServiceChildrenParagraph:SetDesc("Select a player above to list their children")
                end
                return
            end
            local entry = plrsKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local lines = {}
            for _, child in ipairs(entry.instance:GetChildren()) do
                table.insert(lines, formatInstanceDisplay(child, nil, true))
                if shouldNestOneLevelInObjectsList(child) then
                    for _, sub in ipairs(child:GetChildren()) do
                        table.insert(lines, "  " .. formatInstanceDisplay(sub, nil, true))
                    end
                end
            end
            local text = table.concat(lines, "\n")
            if #lines == 0 then
                text = "(no children)"
            end
            if PlayersServiceChildrenParagraph and PlayersServiceChildrenParagraph.SetDesc then
                PlayersServiceChildrenParagraph:SetDesc(text)
            end
        end
    })

    PlayersServiceChildrenParagraph = PlayersServiceSection:Paragraph({
        Title = "Children (key = value)",
        Desc = "Select a player above to list their children",
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
    local lpKeyValueList = {}
    local LocalPlayerDropdown
    local LocalPlayerChildrenParagraph

    local function refreshLocalPlayerList()
        lpDisplayList = {}
        lpKeyValueList = {}
        local localPlayer = Players.LocalPlayer
        for _, child in ipairs(localPlayer:GetChildren()) do
            local display = formatInstanceDisplay(child, nil, true)
            table.insert(lpDisplayList, display)
            lpKeyValueList[display] = { key = child.Name, value = child.ClassName, instance = child }
        end
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
        Callback = function(selectedDisplay)
            if not selectedDisplay then
                if LocalPlayerChildrenParagraph and LocalPlayerChildrenParagraph.SetDesc then
                    LocalPlayerChildrenParagraph:SetDesc("Select an object above to list its children")
                end
                return
            end
            local entry = lpKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local lines = {}
            for _, child in ipairs(entry.instance:GetChildren()) do
                table.insert(lines, formatInstanceDisplay(child, nil, true))
                if shouldNestOneLevelInObjectsList(child) then
                    for _, sub in ipairs(child:GetChildren()) do
                        table.insert(lines, "  " .. formatInstanceDisplay(sub, nil, true))
                    end
                end
            end
            local text = table.concat(lines, "\n")
            if #lines == 0 then
                text = "(no children)"
            end
            if LocalPlayerChildrenParagraph and LocalPlayerChildrenParagraph.SetDesc then
                LocalPlayerChildrenParagraph:SetDesc(text)
            end
        end
    })

    LocalPlayerChildrenParagraph = LocalPlayerSection:Paragraph({
        Title = "Children (key = value)",
        Desc = "Select an object above to list its children",
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
    local wsKeyValueList = {}
    local WorkspaceDropdown
    local WorkspaceChildrenParagraph

    local function refreshWorkspaceList()
        wsDisplayList = {}
        wsKeyValueList = {}
        for _, child in ipairs(Workspace:GetChildren()) do
            local display = formatInstanceDisplay(child, nil, true)
            table.insert(wsDisplayList, display)
            wsKeyValueList[display] = { key = child.Name, value = child.ClassName, instance = child }
        end
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
        Callback = function(selectedDisplay)
            if not selectedDisplay then
                if WorkspaceChildrenParagraph and WorkspaceChildrenParagraph.SetDesc then
                    WorkspaceChildrenParagraph:SetDesc("Select an object above to list its children")
                end
                return
            end
            local entry = wsKeyValueList[selectedDisplay]
            if not entry or not entry.instance then return end
            local lines = {}
            for _, child in ipairs(entry.instance:GetChildren()) do
                table.insert(lines, formatInstanceDisplay(child, nil, true))
                if shouldNestOneLevelInObjectsList(child) then
                    for _, sub in ipairs(child:GetChildren()) do
                        table.insert(lines, "  " .. formatInstanceDisplay(sub, nil, true))
                    end
                end
            end
            local text = table.concat(lines, "\n")
            if #lines == 0 then
                text = "(no children)"
            end
            if WorkspaceChildrenParagraph and WorkspaceChildrenParagraph.SetDesc then
                WorkspaceChildrenParagraph:SetDesc(text)
            end
        end
    })

    WorkspaceChildrenParagraph = WorkspaceSection:Paragraph({
        Title = "Children (key = value)",
        Desc = "Select an object above to list its children",
    })

    WorkspaceSection:Button({
        Title = "Refresh",
        Justify = "Center",
        Icon = "",
        Callback = function()
            refreshWorkspaceList()
        end
    })

end