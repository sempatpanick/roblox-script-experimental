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
    Title = "SempatPanick",
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

    -- Auto-harvest delay per crop type (from game CropConfig); used when Harvest Plant is on
    local DEFAULT_AUTO_HARVEST_DELAYS = {
        Padi = 60,
        Jagung = 90,
        Tomat = 120,
        Terong = 150,
        Strawberry = 200,
        Sawit = 600,
    }
    local FALLBACK_DELAY = 60
    local CropConfig
    do
        local ok, mod = pcall(function()
            return require(ReplicatedStorage:WaitForChild("Modules", 5):WaitForChild("CropConfig", 5))
        end)
        CropConfig = (ok and mod) and mod or nil
    end

    local function getCropAttribute(crop, key)
        local v = crop:GetAttribute(key)
        if v ~= nil then return v end
        local c = crop:FindFirstChild(key)
        if c and c:IsA("StringValue") then return c.Value end
        return nil
    end

    local function getAutoHarvestDelay(crop)
        local cropType = getCropAttribute(crop, "CropType") or crop:GetAttribute("CropType")
        if cropType and type(cropType) == "string" then
            if CropConfig and CropConfig[cropType] and type(CropConfig[cropType].AutoHarvestDelay) == "number" then
                return CropConfig[cropType].AutoHarvestDelay
            end
            if DEFAULT_AUTO_HARVEST_DELAYS[cropType] then
                return DEFAULT_AUTO_HARVEST_DELAYS[cropType]
            end
        end
        return FALLBACK_DELAY
    end

    local function isCropReadyForHarvest(crop)
        if not crop or not crop.Parent then return false end
        local harvested = crop:GetAttribute("Harvested") or getCropNumber(crop, "Harvested")
        if harvested then return false end
        if crop:GetAttribute("IsReady") == true then return true end
        local scaleEnd = getCropNumber(crop, "ScaleEnd")
        local scaleStart = getCropNumber(crop, "ScaleStart")
        return scaleEnd ~= nil and scaleStart ~= nil and scaleEnd == scaleStart
    end

    local pendingAutoHarvest = {}

    local function scheduleAutoHarvest(crop)
        if pendingAutoHarvest[crop] then return end
        if not isCropReadyForHarvest(crop) then return end
        local delay = getAutoHarvestDelay(crop)
        pendingAutoHarvest[crop] = true
        task.delay(delay, function()
            pendingAutoHarvest[crop] = nil
            if not harvestPlantRunning then return end
            if not crop.Parent then return end
            if not isCropReadyForHarvest(crop) then return end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if harvestTeleportEnabled and rootPart then
                local posX = getCropNumber(crop, "PosX") or 0
                local posZ = getCropNumber(crop, "PosZ") or 0
                local groundY = getCropNumber(crop, "GroundY") or 0
                local cropPos = Vector3.new(posX, groundY, posZ)
                rootPart.CFrame = CFrame.new(cropPos)
                task.wait(0.5)
            end
            local prompt = findHarvestPromptInCrop(crop)
            if prompt and prompt:IsA("ProximityPrompt") then
                local originalHold = prompt.HoldDuration
                prompt.HoldDuration = 0
                prompt:InputHoldBegin()
                prompt:InputHoldEnd()
                prompt.HoldDuration = originalHold
            end
        end)
    end

    local function getReadyCropsForLocalPlayer()
        refreshAllCropsByLocalPlayer()
        local list = {}
        for _, entry in ipairs(localPlayerCropsList) do
            if isCropReadyForHarvest(entry.crop) then
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

    PlantSection:Button({
        Title = "Set current position as farm position",
        Justify = "Center",
        Icon = "",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                farmPosition = rootPart.Position
                WindUI:Notify({
                    Title = "Farm position",
                    Content = string.format("Set to %.1f, %.1f, %.1f", farmPosition.X, farmPosition.Y, farmPosition.Z),
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
        Desc = "Scan ready crops every 2s + auto-harvest after delay (per crop type) if not harvested",
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
        Desc = "Scan every 2s + auto-harvest after delay (per crop type) if you don't harvest; teleport optional",
        Callback = function(enabled)
            harvestPlantRunning = enabled
            if not enabled then
                pendingAutoHarvest = {}
                return
            end
            task.spawn(function()
                while harvestPlantRunning do
                    local character = Players.LocalPlayer.Character
                    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then
                        task.wait(2)
                        continue
                    end

                    local readyCrops = getReadyCropsForLocalPlayer()
                    for _, entry in ipairs(readyCrops) do
                        scheduleAutoHarvest(entry.crop)
                    end
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
                                rootPart.CFrame = CFrame.new(pos + Vector3.new(0, 0, 3))
                                task.wait(1)
                                interactWithMandi(nearest)
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

    LocalPlayerTab:Space()

    local WalkSpeedSection = LocalPlayerTab:Section({
        Title = "Walk Speed",
        Box = true,
        BoxBorder = true,
        Opened = true,
    })

    local defaultWalkSpeed = 16
    local walkSpeedValue = tostring(defaultWalkSpeed)

    WalkSpeedSection:Input({
        Title = "Speed",
        Placeholder = "e.g. 16 or 100",
        Value = walkSpeedValue,
        Callback = function(value)
            walkSpeedValue = value
        end
    })

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