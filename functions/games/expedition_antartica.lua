--[[
  Expedition Antarctica game logic (UI-agnostic).
  Load via: loadFunctionModule("games/expedition_antartica")
]]

local loadFunctionModule = shared.__sempatpanick_load_function_module
if type(loadFunctionModule) ~= "function" then
	local ok, mod = pcall(require, "../load_module")
	if ok and type(mod) == "function" then
		loadFunctionModule = mod
	else
		ok, mod = pcall(require, "../../load_module")
		if ok and type(mod) == "function" then
			loadFunctionModule = mod
		end
	end
end

if type(loadFunctionModule) ~= "function" then
	error("[games/expedition_antartica] load_module unavailable")
end

local campsMod = loadFunctionModule("games/expedition_antartica/camps")
local routesMod = loadFunctionModule("games/expedition_antartica/routes")
local checkpointMod = loadFunctionModule("games/expedition_antartica/checkpoint")
local hydrationMod = loadFunctionModule("games/expedition_antartica/hydration")
local summitMod = loadFunctionModule("games/expedition_antartica/summit")

local campList = campsMod.CAMP_LIST
local checkpoint = checkpointMod.createCheckpointTracker(campList)

return {
	id = "expedition_antartica",
	displayName = "Expedition Antartica",

	campList = campList,
	teleportCamps = campsMod.TELEPORT_CAMPS,
	getCampNames = campsMod.getCampNames,
	getDefaultDurationForCamp = campsMod.getDefaultDurationForCamp,
	findCampByName = campsMod.findCampByName,

	runCampRoute = routesMod.runCampRoute,

	checkpoint = checkpoint,
	createAutoDrink = hydrationMod.createAutoDrink,
	createAutoSummit = function(opts)
		opts = opts or {}
		opts.campList = campList
		opts.runCampRoute = routesMod.runCampRoute
		opts.checkpoint = checkpoint
		return summitMod.createAutoSummit(opts)
	end,
}
