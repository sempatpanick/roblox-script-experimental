local HttpService = game:GetService("HttpService")

local META_FIELD_ORDER = {
	"recorderName",
	"playerName",
	"avatarProfile",
	"totalEvents",
	"durationSeconds",
	"movementSampleHz",
	"startedAtUtc",
	"gameId",
	"placeId",
	"jobId",
}

local function isSequentialArray(tbl)
	local maxIndex = 0
	local count = 0
	for k, _ in pairs(tbl) do
		if type(k) ~= "number" or k < 1 or k % 1 ~= 0 then
			return false
		end
		if k > maxIndex then
			maxIndex = k
		end
		count = count + 1
	end
	return maxIndex == count
end

local function orderedObjectKeys(tbl, parentKey)
	local keys = {}
	for k, _ in pairs(tbl) do
		if type(k) == "string" then
			table.insert(keys, k)
		end
	end

	local ordered = {}
	local used = {}
	local preferredOrder = {}

	if tbl.meta ~= nil and tbl.events ~= nil then
		preferredOrder = { "meta", "events" }
	elseif tbl.t ~= nil and tbl.kind ~= nil and tbl.data ~= nil then
		preferredOrder = { "t", "kind", "data" }
	elseif tbl.isGrounded ~= nil
		and tbl.walkSpeed ~= nil
		and tbl.jumpHeight ~= nil
		and tbl.jumpPower ~= nil
		and tbl.position ~= nil
		and tbl.lookDirection ~= nil
		and tbl.moveDirection ~= nil
		and tbl.velocity ~= nil
	then
		preferredOrder = {
			"isGrounded",
			"walkSpeed",
			"jumpHeight",
			"jumpPower",
			"position",
			"lookDirection",
			"moveDirection",
			"velocity",
		}
	elseif parentKey == "meta" then
		preferredOrder = META_FIELD_ORDER
	elseif tbl.x ~= nil and tbl.y ~= nil and tbl.z ~= nil then
		preferredOrder = { "x", "y", "z" }
	end

	for _, k in ipairs(preferredOrder) do
		if tbl[k] ~= nil and not used[k] then
			table.insert(ordered, k)
			used[k] = true
		end
	end

	local remaining = {}
	for _, k in ipairs(keys) do
		if not used[k] then
			table.insert(remaining, k)
		end
	end
	table.sort(remaining, function(a, b)
		return a < b
	end)
	for _, k in ipairs(remaining) do
		table.insert(ordered, k)
	end
	return ordered
end

local function encodeRecordingJsonValue(value, parentKey, pretty, depth)
	local level = depth or 0
	local valueType = type(value)
	if value == nil then
		return "null"
	elseif valueType == "string" then
		return HttpService:JSONEncode(value)
	elseif valueType == "boolean" then
		return value and "true" or "false"
	elseif valueType == "number" then
		if value ~= value or value == math.huge or value == -math.huge then
			return "null"
		end
		return tostring(value)
	elseif valueType ~= "table" then
		return HttpService:JSONEncode(tostring(value))
	end

	if isSequentialArray(value) then
		local parts = {}
		for i = 1, #value do
			local encoded = encodeRecordingJsonValue(value[i], nil, pretty, level + 1)
			if pretty then
				local indent = string.rep("  ", level + 1)
				parts[i] = indent .. encoded
			else
				parts[i] = encoded
			end
		end
		if pretty then
			if #parts == 0 then
				return "[]"
			end
			local closingIndent = string.rep("  ", level)
			return "[\n" .. table.concat(parts, ",\n") .. "\n" .. closingIndent .. "]"
		end
		return "[" .. table.concat(parts, ",") .. "]"
	end

	local objectParts = {}
	local keys = orderedObjectKeys(value, parentKey)
	for _, k in ipairs(keys) do
		local encodedKey = HttpService:JSONEncode(k)
		local encodedValue = encodeRecordingJsonValue(value[k], k, pretty, level + 1)
		if pretty then
			local indent = string.rep("  ", level + 1)
			table.insert(objectParts, indent .. encodedKey .. ": " .. encodedValue)
		else
			table.insert(objectParts, encodedKey .. ":" .. encodedValue)
		end
	end
	if pretty then
		if #objectParts == 0 then
			return "{}"
		end
		local closingIndent = string.rep("  ", level)
		return "{\n" .. table.concat(objectParts, ",\n") .. "\n" .. closingIndent .. "}"
	end
	return "{" .. table.concat(objectParts, ",") .. "}"
end

return {
	isSequentialArray = isSequentialArray,
	orderedObjectKeys = orderedObjectKeys,
	encodeRecordingJsonValue = encodeRecordingJsonValue,
}
