--[[
  Expedition Antarctica game logic (UI-agnostic).
  Load via: loadFunctionModule("games/expedition_antartica")
]]

local function loadSubModule(name)
	local ok, mod = pcall(require, script and script.Parent and script.Parent[name])
	if ok then
		return mod
	end

	ok, mod = pcall(require, "../games/expedition_antartica/" .. name)
	if ok then
		return mod
	end

	local loadFunctionModule
	ok, loadFunctionModule = pcall(require, "../../load_module")
	if not ok then
		ok, loadFunctionModule = pcall(require, "../load_module")
	end
	if ok then
		return loadFunctionModule("games/expedition_antartica/" .. name)
	end

	error("[games/expedition_antartica] failed to load submodule: " .. name)
end

local campsMod = loadSubModule("camps")
local routesMod = loadSubModule("routes")
local checkpointMod = loadSubModule("checkpoint")
local hydrationMod = loadSubModule("hydration")
local summitMod = loadSubModule("summit")

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
