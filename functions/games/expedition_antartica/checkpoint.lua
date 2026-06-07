local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local EXPEDITION_ROUTE_LOCATION_PROGRESS = {
	["base camp"] = 0,
	["camp 1"] = 1,
	["waterfall"] = 1,
	["broken bridges"] = 1,
	["mount kirkpatrick"] = 1,
	["beardmore glacier"] = 1,
	["ross ice shelf"] = 1,
	["camp 2"] = 2,
	["vertical ladder jump"] = 2,
	["mount vinson"] = 2,
	["icy ladder"] = 2,
	["ellsworth mountains"] = 2,
	["death wall"] = 2,
	["camp 3"] = 3,
	["cracking ice"] = 3,
	["canada glacier"] = 3,
	["camp 4"] = 4,
	["shackleton glacier"] = 4,
	["south pole"] = 5,
}

local function createCheckpointTracker(campList)
	local cachedRejoinCheckpointStr = nil

	local function readGameModesPreviousSessionSpawn(player)
		if not player then
			return nil, nil
		end
		local ok, info = pcall(function()
			local ps = player:FindFirstChild("PlayerScripts")
			if not ps then
				return nil
			end
			local mods = ps:FindFirstChild("Modules")
			if not mods then
				return nil
			end
			local gmScript = mods:FindFirstChild("Game_Modes")
			if not gmScript then
				return nil
			end
			local gm = require(gmScript)
			return gm and gm.playerGameModesInfo
		end)
		if not ok or type(info) ~= "table" then
			return nil, nil
		end
		local loc = info.PreviousSessionSpawnLocation
		local mode = info.PreviousSessionMode
		if typeof(loc) == "string" and loc ~= "" then
			return loc, mode
		end
		return nil, mode
	end

	local function checkpointStringToProgress(s)
		if not s or type(s) ~= "string" then
			return nil
		end
		local low = string.lower((string.gsub(s, "^%s*(.-)%s*$", "%1")))
		local direct = EXPEDITION_ROUTE_LOCATION_PROGRESS[low]
		if direct ~= nil then
			return direct
		end
		local bestLen = 0
		local bestK = nil
		for k in pairs(EXPEDITION_ROUTE_LOCATION_PROGRESS) do
			if #k > bestLen and low:find(k, 1, true) then
				bestK, bestLen = k, #k
			end
		end
		if bestK then
			return EXPEDITION_ROUTE_LOCATION_PROGRESS[bestK]
		end
		if low:find("south pole", 1, true) or low:find("southpole", 1, true) or low == "sp" then
			return 5
		end
		if low:find("camp 4", 1, true) or low:find("camp4", 1, true) then
			return 4
		end
		if low:find("camp 3", 1, true) or low:find("camp3", 1, true) or low:find("mount vinson", 1, true) then
			return 3
		end
		if low:find("camp 2", 1, true) or low:find("camp2", 1, true) then
			return 2
		end
		if low:find("camp 1", 1, true) or low:find("camp1", 1, true) then
			return 1
		end
		if low:find("basecamp", 1, true) or low:find("base camp", 1, true) then
			return 0
		end
		if low == "base" then
			return 0
		end
		if low:find("practice", 1, true) or low:find("practise", 1, true) then
			return 0
		end
		local d = string.match(s, "(%d+)")
		if d then
			local n = tonumber(d)
			if n and n >= 1 and n <= 4 then
				return n
			end
		end
		return nil
	end

	local function valueToProgress(v)
		if v == nil then
			return nil
		end
		if typeof(v) == "number" then
			local n = math.floor(v)
			if n < 0 then
				n = 0
			end
			if n > #campList then
				n = #campList
			end
			return n
		end
		if typeof(v) == "string" then
			return checkpointStringToProgress(v)
		end
		return nil
	end

	local function readValueBaseProgress(inst)
		if not inst or not inst:IsA("ValueBase") then
			return nil
		end
		local ok, val = pcall(function()
			return inst.Value
		end)
		if not ok then
			return nil
		end
		return valueToProgress(val)
	end

	local function getCheckpointProgressFromPlayer(player)
		local ls = player:FindFirstChild("leaderstats")
		if ls then
			local n = ls:FindFirstChild("LastCheckpoint")
			if n and n:IsA("IntValue") then
				local p = valueToProgress(n.Value)
				if p ~= nil then
					return p
				end
			end
			local s = ls:FindFirstChild("Checkpoint")
			if s and (s:IsA("StringValue") or s:IsA("IntValue")) then
				local p = readValueBaseProgress(s)
				if p ~= nil then
					return p
				end
			end
		end
		local a = player:GetAttribute("LastCheckpoint")
		if a ~= nil then
			local p = valueToProgress(a)
			if p ~= nil then
				return p
			end
		end
		local gmLoc = select(1, readGameModesPreviousSessionSpawn(player))
		if gmLoc then
			local p = checkpointStringToProgress(gmLoc)
			if p ~= nil then
				return p
			end
		end
		local ed = player:FindFirstChild("Expedition Data")
		if ed then
			for _, name in ipairs({ "LastCheckpoint", "Checkpoint", "CurrentCheckpoint", "SpawnCheckpoint", "RespawnCheckpoint" }) do
				local ch = ed:FindFirstChild(name)
				if ch then
					local p = readValueBaseProgress(ch)
					if p ~= nil then
						return p
					end
				end
			end
		end
		if cachedRejoinCheckpointStr then
			local p = checkpointStringToProgress(cachedRejoinCheckpointStr)
			if p ~= nil then
				return p
			end
		end
		return 0
	end

	local function getCheckpointLabelString(player)
		local gmLoc, gmMode = readGameModesPreviousSessionSpawn(player)
		if gmLoc then
			if typeof(gmMode) == "string" and gmMode ~= "" then
				return gmLoc .. " (" .. gmMode .. ")"
			end
			return gmLoc
		end
		local ls = player:FindFirstChild("leaderstats")
		if ls then
			local sv = ls:FindFirstChild("Checkpoint")
			if sv and sv:IsA("StringValue") and sv.Value ~= "" then
				return sv.Value
			end
			local iv = ls:FindFirstChild("LastCheckpoint")
			if iv and iv:IsA("IntValue") then
				return tostring(iv.Value)
			end
		end
		local attr = player:GetAttribute("LastCheckpoint")
		if attr ~= nil and tostring(attr) ~= "" then
			return tostring(attr)
		end
		local ed = player:FindFirstChild("Expedition Data")
		if ed then
			for _, name in ipairs({ "Checkpoint", "LastCheckpoint", "CurrentCheckpoint" }) do
				local ch = ed:FindFirstChild(name)
				if ch and ch:IsA("StringValue") and ch.Value ~= "" then
					return ch.Value
				end
			end
		end
		if cachedRejoinCheckpointStr and cachedRejoinCheckpointStr ~= "" then
			return cachedRejoinCheckpointStr
		end
		return "Start / Basecamp"
	end

	local function routeLabelForProgress(idx)
		local n = #campList
		if idx <= 0 then
			return "Start → " .. (campList[1] and campList[1].name or "Camp 1")
		end
		if idx >= n then
			return campList[n] and campList[n].name or "South Pole"
		end
		return campList[idx + 1] and campList[idx + 1].name or ("Leg " .. tostring(idx + 1))
	end

	local function getFirstCampListIndexFromProgress(progress)
		local routeN = #campList
		local p = math.floor(tonumber(progress) or 0)
		if p < 0 then
			p = 0
		end
		if p >= routeN then
			return nil, p
		end
		return p + 1, p
	end

	local function getStatusDescription(player)
		local label = getCheckpointLabelString(player)
		local idx = getCheckpointProgressFromPlayer(player)
		local nextName = routeLabelForProgress(idx)
		return string.format("CHECKPOINT: %s\nProgress #%d · Next leg: %s", string.upper(label), idx, nextName)
	end

	local function attachLeaderstatsForCp(ls, onUpdate)
		local function onCheckpointValueChanged()
			onUpdate()
		end
		local n = ls:FindFirstChild("LastCheckpoint")
		if n and n:IsA("IntValue") then
			n:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
		end
		local s = ls:FindFirstChild("Checkpoint")
		if s and s:IsA("StringValue") then
			s:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
		end
		ls.ChildAdded:Connect(function(ch)
			if ch.Name == "LastCheckpoint" and ch:IsA("IntValue") then
				ch:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
				onCheckpointValueChanged()
			elseif ch.Name == "Checkpoint" and ch:IsA("StringValue") then
				ch:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
				onCheckpointValueChanged()
			end
		end)
	end

	local function attachExpeditionDataForCp(ed, onUpdate)
		local function onCheckpointValueChanged()
			onUpdate()
		end
		for _, name in ipairs({ "LastCheckpoint", "Checkpoint", "CurrentCheckpoint", "SpawnCheckpoint", "RespawnCheckpoint" }) do
			local ch = ed:FindFirstChild(name)
			if ch and ch:IsA("ValueBase") then
				ch:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
			end
		end
		ed.ChildAdded:Connect(function(ch)
			if ch:IsA("ValueBase") then
				for _, name in ipairs({ "LastCheckpoint", "Checkpoint", "CurrentCheckpoint", "SpawnCheckpoint", "RespawnCheckpoint" }) do
					if ch.Name == name then
						ch:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
						onCheckpointValueChanged()
						break
					end
				end
			end
		end)
	end

	local function attachListeners(onUpdate, player)
		player = player or Players.LocalPlayer
		player:GetAttributeChangedSignal("LastCheckpoint"):Connect(onUpdate)
		local lsCp = player:FindFirstChild("leaderstats")
		if lsCp then
			attachLeaderstatsForCp(lsCp, onUpdate)
		end
		player.ChildAdded:Connect(function(ch)
			if ch.Name == "leaderstats" then
				attachLeaderstatsForCp(ch, onUpdate)
				onUpdate()
			elseif ch.Name == "Expedition Data" then
				attachExpeditionDataForCp(ch, onUpdate)
				onUpdate()
			end
		end)
		local edCp = player:FindFirstChild("Expedition Data")
		if edCp then
			attachExpeditionDataForCp(edCp, onUpdate)
		end
		pcall(function()
			local evFolder = ReplicatedStorage:FindFirstChild("Events")
			local cmd = evFolder and evFolder:FindFirstChild("ClientModuleCommander")
			if cmd and (cmd:IsA("RemoteEvent") or cmd:IsA("UnreliableRemoteEvent")) then
				cmd.OnClientEvent:Connect(function(kind, _)
					if kind == "Games_Modes_updatePlayerGameModesInfo" then
						task.defer(onUpdate)
					end
				end)
			end
		end)
	end

	local function initRejoinListener()
		pcall(function()
			local ev = ReplicatedStorage:FindFirstChild("Events")
			ev = ev and ev:FindFirstChild("LivesHealth")
			if ev and ev:IsA("RemoteEvent") then
				ev.OnClientEvent:Connect(function(msg, ...)
					if msg == "Display_Rejoin_Message" then
						local _, _, c = ...
						if typeof(c) == "string" and c ~= "" then
							cachedRejoinCheckpointStr = c
						end
					end
				end)
			end
		end)
	end

	initRejoinListener()

	return {
		getCheckpointProgressFromPlayer = getCheckpointProgressFromPlayer,
		getCheckpointLabelString = getCheckpointLabelString,
		routeLabelForProgress = routeLabelForProgress,
		getFirstCampListIndexFromProgress = getFirstCampListIndexFromProgress,
		getStatusDescription = getStatusDescription,
		attachListeners = attachListeners,
	}
end

return {
	createCheckpointTracker = createCheckpointTracker,
}
