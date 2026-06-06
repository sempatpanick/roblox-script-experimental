local function parseNumberTriple(str)
	local s = (str or ""):gsub(",", " "):gsub("%s+", " ")
	local parts = {}
	for part in string.gmatch(s, "[%d%.%-]+") do
		table.insert(parts, tonumber(part))
	end
	return parts
end

local function parsePositionString(str)
	local parts = parseNumberTriple(str)
	if #parts < 3 then
		return nil
	end
	return Vector3.new(parts[1], parts[2], parts[3])
end

local function cframeFromInputs(posStr, lookStr)
	local posParts = parseNumberTriple(posStr)
	if #posParts < 3 then
		return nil
	end
	local pos = Vector3.new(posParts[1], posParts[2], posParts[3])
	local lookParts = parseNumberTriple(lookStr)
	if #lookParts < 3 then
		return CFrame.new(pos)
	end
	local dir = Vector3.new(lookParts[1], lookParts[2], lookParts[3])
	if dir.Magnitude < 1e-5 then
		return CFrame.new(pos)
	end
	return CFrame.lookAt(pos, pos + dir.Unit)
end

return {
	parseNumberTriple = parseNumberTriple,
	parsePositionString = parsePositionString,
	cframeFromInputs = cframeFromInputs,
}
