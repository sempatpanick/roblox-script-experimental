local function slugFromConfigDir(configDir)
	local slug = tostring(configDir or ""):gsub("\\", "/"):match("([^/]+)$")
	return slug or "config"
end

local function sanitizeConfigName(raw)
	local s = tostring(raw or ""):gsub("^%s+", ""):gsub("%s+$", "")
	s = s:gsub("[/\\]", "")
	return s
end

local function splitPathSegments(path)
	local segments = {}
	for piece in string.gmatch(path or "", "[^/]+") do
		if piece ~= "" and piece ~= "." then
			table.insert(segments, piece)
		end
	end
	return segments
end

local function normalizePath(path)
	return string.gsub(path or "", "\\", "/")
end

local function baseNameFromPath(path)
	local normalized = normalizePath(path)
	local idx = string.match(normalized, "^.*()/")
	if idx then
		return string.sub(normalized, idx + 1)
	end
	return normalized
end

local function isJsonPath(path)
	return string.sub(string.lower(path or ""), -5) == ".json"
end

local function profilePath(configDir, name)
	return configDir .. "/" .. sanitizeConfigName(name) .. ".json"
end

return {
	slugFromConfigDir = slugFromConfigDir,
	sanitizeConfigName = sanitizeConfigName,
	splitPathSegments = splitPathSegments,
	normalizePath = normalizePath,
	baseNameFromPath = baseNameFromPath,
	isJsonPath = isJsonPath,
	profilePath = profilePath,
}
