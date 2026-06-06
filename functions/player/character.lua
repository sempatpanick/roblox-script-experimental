local function getLocalRootPart(players)
	players = players or game:GetService("Players")
	local character = players.LocalPlayer.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function getLocalCharacterParts(players)
	players = players or game:GetService("Players")
	local character = players.LocalPlayer.Character
	if not character then
		return nil, nil, nil
	end
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	return character, rootPart, humanoid
end

local function getCharacterHumanoidAndRoot(character)
	if not character then
		return nil, nil
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local rootPart = character:FindFirstChild("HumanoidRootPart")
	return humanoid, rootPart
end

local function getCurrentCharacterWalkSpeed(players, defaultWalkSpeed)
	players = players or game:GetService("Players")
	defaultWalkSpeed = defaultWalkSpeed or 16
	local character = players.LocalPlayer.Character
	if not character then
		return defaultWalkSpeed
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return defaultWalkSpeed
	end
	return humanoid.WalkSpeed
end

local function getCurrentCharacterJumpHeight(players, defaultJumpHeight)
	players = players or game:GetService("Players")
	defaultJumpHeight = defaultJumpHeight or 7.2
	local character = players.LocalPlayer.Character
	if not character then
		return defaultJumpHeight
	end
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return defaultJumpHeight
	end
	return humanoid.JumpHeight
end

local function playerInfoLabel(player)
	if not player then
		return ""
	end
	local dn = player.DisplayName
	if dn and dn ~= "" and dn ~= player.Name then
		return string.format("%s (@%s)", dn, player.Name)
	end
	return player.Name
end

local function buildPlayerNameList(players, excludeLocalPlayer)
	players = players or game:GetService("Players")
	local names = {}
	local localPlayer = players.LocalPlayer
	for _, player in ipairs(players:GetPlayers()) do
		if player.ClassName == "Player" and (not excludeLocalPlayer or player ~= localPlayer) then
			table.insert(names, player.Name)
		end
	end
	table.sort(names, function(a, b)
		return string.lower(a) < string.lower(b)
	end)
	return names
end

local function buildTeleportPlayerDropdownOptions(players, noneLabel, excludeLocalPlayer)
	noneLabel = noneLabel or "(None)"
	local opts = { noneLabel }
	for _, name in ipairs(buildPlayerNameList(players, excludeLocalPlayer)) do
		table.insert(opts, name)
	end
	return opts
end

return {
	getLocalRootPart = getLocalRootPart,
	getLocalCharacterParts = getLocalCharacterParts,
	getCharacterHumanoidAndRoot = getCharacterHumanoidAndRoot,
	getCurrentCharacterWalkSpeed = getCurrentCharacterWalkSpeed,
	getCurrentCharacterJumpHeight = getCurrentCharacterJumpHeight,
	playerInfoLabel = playerInfoLabel,
	buildPlayerNameList = buildPlayerNameList,
	buildTeleportPlayerDropdownOptions = buildTeleportPlayerDropdownOptions,
}
