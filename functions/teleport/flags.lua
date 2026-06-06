local function resolveTeleportFlag(options, key)
	local flags = options and options.flags
	if type(flags) == "table" and type(flags[key]) == "string" and flags[key] ~= "" then
		return flags[key]
	end
	local prefix = options and options.flagsPrefix
	if type(prefix) ~= "string" or prefix == "" then
		return nil
	end
	local suffixMap = {
		location = "location",
		lookDirection = "lookDirection",
		tweenDuration = "tweenDuration",
		playerPick = "playerPick",
		getCurrentLocation = "getCurrentLocation",
		teleportCoords = "teleportCoords",
		tweenToLocation = "tweenToLocation",
	}
	local suffix = suffixMap[key] or key
	if key == "tweenDuration" and prefix == "mancing" then
		return prefix .. "_tp_tweenDurationSec"
	end
	return prefix .. "_tp_" .. suffix
end

local function resolveUiFlagPrefix(options, suffix)
	local prefix = options and options.flagsPrefix
	if type(prefix) ~= "string" or prefix == "" then
		return nil
	end
	return prefix .. "_" .. suffix
end

local function withExtOption(props, options)
	if options and options.ext then
		props.Ext = true
	end
	return props
end

return {
	resolveTeleportFlag = resolveTeleportFlag,
	resolveUiFlagPrefix = resolveUiFlagPrefix,
	withExtOption = withExtOption,
}
