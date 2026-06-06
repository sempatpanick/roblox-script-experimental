local HUMANOID_INSPECT_PROPERTIES_FALLBACK = {
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

local PLAYER_INSPECT_PROPERTIES_FALLBACK = {
	"AccountAge",
	"AutoJumpEnabled",
	"CanLoadCharacterAppearance",
	"CharacterAppearanceId",
	"DataComplexity",
	"DataReady",
	"DevComputerCameraMode",
	"DevComputerMovementMode",
	"DevEnableMouseLock",
	"DevTouchCameraMode",
	"DevTouchMovementMode",
	"DisplayName",
	"FollowUserId",
	"GameplayPaused",
	"HasVerifiedBadge",
	"HealthDisplayDistance",
	"LocaleId",
	"MembershipType",
	"Name",
	"Neutral",
	"RespawnLocation",
	"SimulationRadius",
	"Team",
	"TeamColor",
	"UserId",
}

local function getReadablePropertyNames(instance, fallbackList)
	local names = {}
	local seen = {}
	local function addName(name)
		if name == "" or seen[name] then
			return
		end
		seen[name] = true
		table.insert(names, name)
	end

	local getPropertiesFn = rawget(_G, "getproperties")
	if type(getPropertiesFn) == "function" then
		pcall(function()
			local discovered = getPropertiesFn(instance)
			if type(discovered) == "table" then
				for _, name in ipairs(discovered) do
					if type(name) == "string" then
						addName(name)
					end
				end
			end
		end)
	end

	if #names == 0 then
		for _, name in ipairs(fallbackList) do
			addName(name)
		end
	end

	table.sort(names, function(a, b)
		return string.lower(a) < string.lower(b)
	end)
	return names
end

local function formatHumanoidChildLine(child, formatValueForDisplay)
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

local function buildPlayersInfoText(player, formatValueForDisplay)
	if not player then
		return "Select a player from the list."
	end
	local lines = {}
	table.insert(lines, "Username: " .. player.Name)
	local dn = player.DisplayName
	table.insert(lines, "Display name: " .. ((dn and dn ~= "") and dn or "(same as username)"))
	table.insert(lines, "")
	table.insert(lines, "Player attributes:")
	if player.Parent then
		local attrs = player:GetAttributes()
		local attrRows = {}
		for key, val in pairs(attrs) do
			table.insert(attrRows, {
				key = tostring(key),
				text = "  " .. tostring(key) .. " = " .. formatValueForDisplay(val),
			})
		end
		table.sort(attrRows, function(a, b)
			return string.lower(a.key) < string.lower(b.key)
		end)
		if #attrRows == 0 then
			table.insert(lines, "  (none)")
		else
			for _, row in ipairs(attrRows) do
				table.insert(lines, row.text)
			end
		end
	else
		table.insert(lines, "  (player left)")
	end
	table.insert(lines, "")
	table.insert(lines, "Player properties:")
	if player.Parent then
		local propRows = {}
		for _, propName in ipairs(getReadablePropertyNames(player, PLAYER_INSPECT_PROPERTIES_FALLBACK)) do
			local ok, val = pcall(function()
				return player[propName]
			end)
			if ok then
				table.insert(propRows, {
					key = propName,
					text = "  " .. propName .. " = " .. formatValueForDisplay(val),
				})
			end
		end
		table.sort(propRows, function(a, b)
			return string.lower(a.key) < string.lower(b.key)
		end)
		if #propRows == 0 then
			table.insert(lines, "  (none readable)")
		else
			for _, row in ipairs(propRows) do
				table.insert(lines, row.text)
			end
		end
	else
		table.insert(lines, "  (player left)")
	end
	local character = player.Character
	if not character then
		table.insert(lines, "Character: not loaded")
		table.insert(lines, "Location: -")
		table.insert(lines, "")
		table.insert(lines, "Humanoid properties: -")
		table.insert(lines, "Inside Humanoid (children): -")
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
	table.insert(lines, "Humanoid attributes:")
	if humanoid then
		local humAttrs = humanoid:GetAttributes()
		local humAttrRows = {}
		for key, val in pairs(humAttrs) do
			table.insert(humAttrRows, {
				key = tostring(key),
				text = "  " .. tostring(key) .. " = " .. formatValueForDisplay(val),
			})
		end
		table.sort(humAttrRows, function(a, b)
			return string.lower(a.key) < string.lower(b.key)
		end)
		if #humAttrRows == 0 then
			table.insert(lines, "  (none)")
		else
			for _, row in ipairs(humAttrRows) do
				table.insert(lines, row.text)
			end
		end
	else
		table.insert(lines, "  (no Humanoid)")
	end
	table.insert(lines, "")
	if humanoid then
		table.insert(lines, "Humanoid properties:")
		local propRows = {}
		for _, propName in ipairs(getReadablePropertyNames(humanoid, HUMANOID_INSPECT_PROPERTIES_FALLBACK)) do
			local ok, val = pcall(function()
				return humanoid[propName]
			end)
			if ok then
				table.insert(propRows, {
					key = propName,
					text = "  " .. propName .. " = " .. formatValueForDisplay(val),
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
				table.insert(lines, formatHumanoidChildLine(child, formatValueForDisplay))
			end
		end
	else
		table.insert(lines, "  (no Humanoid)")
	end
	return table.concat(lines, "\n")
end

return {
	getReadablePropertyNames = getReadablePropertyNames,
	formatHumanoidChildLine = formatHumanoidChildLine,
	buildPlayersInfoText = buildPlayersInfoText,
	HUMANOID_INSPECT_PROPERTIES_FALLBACK = HUMANOID_INSPECT_PROPERTIES_FALLBACK,
	PLAYER_INSPECT_PROPERTIES_FALLBACK = PLAYER_INSPECT_PROPERTIES_FALLBACK,
}
