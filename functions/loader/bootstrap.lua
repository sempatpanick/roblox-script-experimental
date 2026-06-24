--[[
  Shared bootstrap for sempatpanick.lua / sempatpanick_local.lua
]]

local function stripSourceBom(source)
	if type(source) ~= "string" then
		return source
	end
	if source:byte(1) == 0xEF and source:byte(2) == 0xBB and source:byte(3) == 0xBF then
		return source:sub(4)
	end
	return source
end

local function loadModule(baseURL, subpath)
	subpath = string.gsub(subpath or "", "%.lua$", "")

	local okReq, mod = pcall(require, "../" .. subpath)
	if okReq then
		return mod
	end

	okReq, mod = pcall(require, "../../functions/" .. subpath)
	if okReq then
		return mod
	end

	if type(baseURL) ~= "string" or baseURL == "" then
		error("[sempatpanick] baseURL not set; cannot load " .. subpath)
	end

	local url = baseURL .. "/functions/" .. subpath .. ".lua"
	local okGet, source = pcall(function()
		return game:HttpGet(url)
	end)
	if not okGet or type(source) ~= "string" or #source < 8 then
		error("[sempatpanick] HttpGet failed for " .. url .. ": " .. tostring(source))
	end

	source = stripSourceBom(source)

	local compile = loadstring or load
	local chunk, compileErr = compile(source, "functions/" .. subpath)
	if type(chunk) ~= "function" then
		error("[sempatpanick] compile failed for " .. subpath .. ": " .. tostring(compileErr))
	end

	local okRun, result = pcall(chunk)
	if not okRun then
		error("[sempatpanick] run failed for " .. subpath .. ": " .. tostring(result))
	end

	return result
end

local OTHERS_UI_LIBRARIES = {
	{
		id = "rayfield",
		label = "Rayfield UI",
		description = "Classic Rayfield interface and config flags",
		path = "/games/rayfield/others.lua",
	},
	{
		id = "windui",
		label = "WindUI",
		description = "Modern WindUI hub layout and config manager",
		path = "/games/windui/others.lua",
	},
	{
		id = "sempat",
		label = "Sempat UI",
		description = "SempatUI-style layout optimized for smooth updates",
		path = "/games/sempat/others.lua",
	},
}

local function start(baseURL, games, excludedGameIds)
	shared.sempatpanick_baseURL = baseURL

	local runGameScript = loadModule(baseURL, "loader/run_game_script")
	local uiLibraryPicker = loadModule(baseURL, "loader/ui_library_picker")

	local currentID = game.PlaceId
	if type(excludedGameIds) == "table" and excludedGameIds[currentID] then
		return
	end

	local scriptURL = games and games[currentID]
	if scriptURL then
		runGameScript.run(scriptURL, baseURL)
		return
	end

	uiLibraryPicker.show({
		title = "sempatpanick",
		subtitle = "This game uses the shared Others script.\nChoose a UI library to continue.",
		libraries = OTHERS_UI_LIBRARIES,
		onSelect = function(library)
			shared.sempatpanick_ui_library = library.id
			runGameScript.run(baseURL .. library.path, baseURL)
		end,
	})
end

return {
	start = start,
	loadModule = loadModule,
	OTHERS_UI_LIBRARIES = OTHERS_UI_LIBRARIES,
}
