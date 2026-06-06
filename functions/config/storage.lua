local function listProfiles(configDir, autoloadFile, ensureConfigFolder, sanitizeConfigName)
	local names = {}
	if type(listfiles) ~= "function" then
		return names
	end
	if ensureConfigFolder then
		ensureConfigFolder()
	end
	local ok, files = pcall(function()
		return listfiles(configDir)
	end)
	if not ok or type(files) ~= "table" then
		return names
	end
	for _, filePath in ipairs(files) do
		local normalized = tostring(filePath):gsub("\\", "/")
		local base = normalized:match("([^/]+)$")
		if base and base:sub(-5) == ".json" and base ~= autoloadFile then
			table.insert(names, base:sub(1, -6))
		end
	end
	table.sort(names)
	return names
end

local function readProfileDataTable(cmPath, profileName, sanitizeConfigName)
	local trimmed = sanitizeConfigName(profileName)
	if trimmed == "" or type(isfile) ~= "function" or type(readfile) ~= "function" then
		return nil
	end
	local HttpService = game:GetService("HttpService")
	local path = cmPath .. trimmed .. ".json"
	if not isfile(path) then
		return nil
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)
	if not ok or type(data) ~= "table" then
		return nil
	end
	if not data.__version and data.__elements == nil then
		return data
	end
	if not data.__version then
		data = { __elements = data, __custom = {} }
	end
	return data.__elements or data
end

local function getSavedElement(elements, flag)
	if type(elements) ~= "table" then
		return nil
	end
	local s = elements[flag]
	if s == nil then
		s = elements[tostring(flag)]
	end
	return s
end

local function readAutoLoadPersistedName(cmPath, autoloadFile, sanitizeConfigName)
	if type(isfile) ~= "function" or type(readfile) ~= "function" then
		return ""
	end
	local HttpService = game:GetService("HttpService")
	local path = cmPath .. autoloadFile
	if not isfile(path) then
		return ""
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(readfile(path))
	end)
	if ok and type(data) == "table" then
		return sanitizeConfigName(tostring(data.name or data.profile or ""))
	end
	return ""
end

local function writeAutoLoadPersistedName(cmPath, autoloadFile, name, sanitizeConfigName)
	if type(writefile) ~= "function" then
		return false
	end
	local HttpService = game:GetService("HttpService")
	local path = cmPath .. autoloadFile
	local trimmed = sanitizeConfigName(name)
	if trimmed == "" then
		if type(delfile) == "function" and type(isfile) == "function" and isfile(path) then
			pcall(function()
				delfile(path)
			end)
		end
		return true
	end
	local ok = pcall(function()
		writefile(path, HttpService:JSONEncode({ name = trimmed }))
	end)
	return ok
end

return {
	listProfiles = listProfiles,
	readProfileDataTable = readProfileDataTable,
	getSavedElement = getSavedElement,
	readAutoLoadPersistedName = readAutoLoadPersistedName,
	writeAutoLoadPersistedName = writeAutoLoadPersistedName,
}
