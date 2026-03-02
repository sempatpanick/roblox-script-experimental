--[[
  Auto-Harvest script for SAWAH Indo Voice Chat (Roblox)
  When a crop is ready to harvest, if the player does not harvest within
  the configured delay (AutoHarvestDelay per crop type), it will automatically
  trigger harvest via the crop's ProximityPrompt.

  Based on the place file:
  - Crops live in Workspace.ActiveCrops
  - CropConfig (ReplicatedStorage.Modules.CropConfig) has per-crop: AutoHarvestDelay
  - Ready = GetAttribute("IsReady") or (ScaleEnd == ScaleStart)
  - Harvest is performed by triggering the ProximityPrompt on the crop
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local myUserId = LocalPlayer.UserId

-- Default delays (seconds) if CropConfig is missing a type; from place file CropConfig
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

local function getCropNumber(crop, key)
	local v = crop:GetAttribute(key)
	if v ~= nil and type(v) == "number" then return v end
	local c = crop:FindFirstChild(key)
	if c and (c:IsA("NumberValue") or c:IsA("IntValue") or c:IsA("DoubleConstrainedValue")) then
		return c.Value
	end
	return nil
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

local function isCropReady(crop)
	if not crop or not crop.Parent then return false end
	local harvested = crop:GetAttribute("Harvested") or getCropNumber(crop, "Harvested")
	if harvested then return false end
	local ready = crop:GetAttribute("IsReady")
	if ready == true then return true end
	local scaleEnd = getCropNumber(crop, "ScaleEnd")
	local scaleStart = getCropNumber(crop, "ScaleStart")
	if scaleEnd ~= nil and scaleStart ~= nil and scaleEnd == scaleStart then
		return true
	end
	return false
end

local function isOwnedByMe(crop)
	local ownerId = getCropNumber(crop, "OwnerId")
	if ownerId == nil then ownerId = crop:GetAttribute("OwnerId") end
	if type(ownerId) ~= "number" then return false end
	return ownerId == myUserId
end

local function getCropPosition(crop)
	local posX = getCropNumber(crop, "PosX") or 0
	local posZ = getCropNumber(crop, "PosZ") or 0
	local groundY = getCropNumber(crop, "GroundY") or 0
	return Vector3.new(posX, groundY, posZ)
end

local function findHarvestPrompt(crop)
	for _, d in ipairs(crop:GetDescendants()) do
		if d:IsA("ProximityPrompt") then return d end
	end
	return nil
end

-- Try to harvest from anywhere: remote (FireServer) and/or expand ProximityPrompt range
local function triggerHarvest(crop)
	local cropPos = getCropPosition(crop)
	local TutorialRemotes = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("TutorialRemotes")
	local HarvestCropRemote = TutorialRemotes and TutorialRemotes:FindFirstChild("HarvestCrop")
	if HarvestCropRemote and HarvestCropRemote:IsA("RemoteEvent") then
		pcall(function() HarvestCropRemote:FireServer(cropPos) end)
		task.wait(0.1)
		pcall(function() HarvestCropRemote:FireServer(crop) end)
		task.wait(0.1)
	end
	local prompt = findHarvestPrompt(crop)
	if not prompt or not prompt:IsA("ProximityPrompt") then return false end
	local origDist = prompt.MaxActivationDistance
	prompt.MaxActivationDistance = 10000
	local originalHold = prompt.HoldDuration
	prompt.HoldDuration = 0
	pcall(function()
		prompt:InputHoldBegin()
		prompt:InputHoldEnd()
	end)
	prompt.HoldDuration = originalHold
	prompt.MaxActivationDistance = origDist
	return true
end

-- Tracks which crops we already started a timer for (ready at time T)
local pendingAutoHarvest = {}

local function scheduleAutoHarvest(crop)
	if pendingAutoHarvest[crop] then return end
	if not isOwnedByMe(crop) or not isCropReady(crop) then return end

	local delay = getAutoHarvestDelay(crop)
	pendingAutoHarvest[crop] = true

	task.delay(delay, function()
		pendingAutoHarvest[crop] = nil
		if not crop.Parent then return end
		if not isCropReady(crop) then return end
		if not isOwnedByMe(crop) then return end
		triggerHarvest(crop)
	end)
end

local function scanAndScheduleReadyCrops()
	local activeCrops = Workspace:FindFirstChild("ActiveCrops")
	if not activeCrops then return end
	for _, crop in ipairs(activeCrops:GetChildren()) do
		if isOwnedByMe(crop) and isCropReady(crop) then
			scheduleAutoHarvest(crop)
		end
	end
end

-- When a crop becomes ready (e.g. IsReady attribute set), schedule auto-harvest
local function onCropReady(crop)
	if not isOwnedByMe(crop) then return end
	if isCropReady(crop) then
		scheduleAutoHarvest(crop)
	end
end

local function setupCropListeners()
	local activeCrops = Workspace:FindFirstChild("ActiveCrops")
	if not activeCrops then return end

	for _, crop in ipairs(activeCrops:GetChildren()) do
		local conn
		conn = crop:GetAttributeChangedSignal("IsReady"):Connect(function()
			onCropReady(crop)
		end)
		crop.AncestryChanged:Connect(function()
			if not crop.Parent then
				pendingAutoHarvest[crop] = nil
			end
		end)
		onCropReady(crop)
	end

	activeCrops.ChildAdded:Connect(function(crop)
		crop:GetAttributeChangedSignal("IsReady"):Connect(function()
			onCropReady(crop)
		end)
		crop.AncestryChanged:Connect(function()
			if not crop.Parent then pendingAutoHarvest[crop] = nil end
		end)
		onCropReady(crop)
	end)
end

-- Optional: periodic scan for ready crops (in case IsReady isn't set and we rely on ScaleEnd==ScaleStart)
local SCAN_INTERVAL = 5
local lastScan = 0
RunService.Heartbeat:Connect(function()
	local t = tick()
	if t - lastScan >= SCAN_INTERVAL then
		lastScan = t
		scanAndScheduleReadyCrops()
	end
end)

-- Initial setup when workspace is ready
local function init()
	scanAndScheduleReadyCrops()
	setupCropListeners()
end

if Workspace:FindFirstChild("ActiveCrops") then
	init()
else
	Workspace.ChildAdded:Connect(function(child)
		if child.Name == "ActiveCrops" then init() end
	end)
end

return {
	scanAndScheduleReadyCrops = scanAndScheduleReadyCrops,
	triggerHarvest = triggerHarvest,
	isCropReady = isCropReady,
	getAutoHarvestDelay = getAutoHarvestDelay,
}
