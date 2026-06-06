local function extractRecordedAvatarProfile(payloadTable, eventsTable)
	if type(payloadTable) == "table" and type(payloadTable.meta) == "table" and type(payloadTable.meta.avatarProfile) == "table" then
		return payloadTable.meta.avatarProfile
	end
	if type(eventsTable) == "table" then
		for _, ev in ipairs(eventsTable) do
			if type(ev) == "table"
				and ev.kind == "recording_started"
				and type(ev.data) == "table"
				and type(ev.data.avatarProfile) == "table"
			then
				return ev.data.avatarProfile
			end
		end
	end
	return nil
end

local function buildPlaybackAvatarAdjustment(recordedAvatarProfile, currentAvatarProfile)
	if type(recordedAvatarProfile) ~= "table" then
		return {
			yOffset = 0,
			detail = "No avatar profile in recording",
		}
	end
	local recordedRootToFeet = tonumber(recordedAvatarProfile.rootToFeetHeight)
	local currentRootToFeet = tonumber(currentAvatarProfile and currentAvatarProfile.rootToFeetHeight)
	if not (recordedRootToFeet and currentRootToFeet) then
		return {
			yOffset = 0,
			detail = "Avatar profile missing root height",
		}
	end
	local yOffset = currentRootToFeet - recordedRootToFeet
	return {
		yOffset = yOffset,
		detail = string.format(
			"Avatar-adjusted Y %.2f (recorded %.2f -> current %.2f)",
			yOffset,
			recordedRootToFeet,
			currentRootToFeet
		),
	}
end

local function buildMovementTargetCFrame(rootPart, dataTable, playbackAvatarAdjust)
	local pos = dataTable.position
	if not rootPart or type(pos) ~= "table" then
		return nil
	end
	local x = tonumber(pos.x)
	local y = tonumber(pos.y)
	local z = tonumber(pos.z)
	if not (x and y and z) then
		return nil
	end

	local basePos = Vector3.new(x, y, z)
	if type(playbackAvatarAdjust) == "table" and type(playbackAvatarAdjust.yOffset) == "number" then
		basePos = basePos + Vector3.new(0, playbackAvatarAdjust.yOffset, 0)
	end
	local lookData = dataTable.lookDirection
	local lx, ly, lz = nil, nil, nil
	if type(lookData) == "table" then
		lx = tonumber(lookData.x)
		ly = tonumber(lookData.y)
		lz = tonumber(lookData.z)
	end
	if lx and ly and lz then
		local lookVec = Vector3.new(lx, ly, lz)
		if lookVec.Magnitude > 1e-4 then
			local planar = Vector3.new(lookVec.X, 0, lookVec.Z)
			if planar.Magnitude > 1e-4 then
				return CFrame.lookAt(basePos, basePos + planar.Unit)
			end
		end
	end

	local fallback = rootPart.CFrame.LookVector
	local fallbackPlanar = Vector3.new(fallback.X, 0, fallback.Z)
	if fallbackPlanar.Magnitude > 1e-4 then
		return CFrame.lookAt(basePos, basePos + fallbackPlanar.Unit)
	end
	return CFrame.new(basePos)
end

local function findMovementSegmentIndex(track, elapsed)
	if #track == 0 then
		return nil
	end
	local idx = 1
	while idx < #track do
		local nextT = tonumber(track[idx + 1].t) or 0
		if nextT > elapsed then
			break
		end
		idx = idx + 1
	end
	return idx
end

local function refreshSelectionFromDropdownValue(value, noneLabel, pathMap)
	local picked = (type(value) == "table" and value[1]) or value
	if type(picked) ~= "string" or picked == "" or picked == noneLabel then
		return nil
	end
	return pathMap[picked]
end

return {
	extractRecordedAvatarProfile = extractRecordedAvatarProfile,
	buildPlaybackAvatarAdjustment = buildPlaybackAvatarAdjustment,
	buildMovementTargetCFrame = buildMovementTargetCFrame,
	findMovementSegmentIndex = findMovementSegmentIndex,
	refreshSelectionFromDropdownValue = refreshSelectionFromDropdownValue,
}
