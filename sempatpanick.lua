local baseURL = "https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main"

local games = {
	[83369512629707] = baseURL .. "/games/rayfield/sawah_indo.lua",
	[128070940451265] = baseURL .. "/games/rayfield/speed_bike_escape.lua",
	[2693023319] = baseURL .. "/games/rayfield/expedition_antartica.lua",
	[103593441753340] = baseURL .. "/games/rayfield/find_the_button.lua",
	[82775216869079] = baseURL .. "/games/rayfield/find_the_button.lua",
	[14963184269] = baseURL .. "/games/rayfield/mount_sumbing.lua",
	[76964310785698] = baseURL .. "/games/rayfield/mount_yahayuk.lua",
	[118098747383977] = baseURL .. "/games/rayfield/mancing_indo.lua",
	[78404864377525] = baseURL .. "/games/rayfield/mancing_indo_galatama.lua",
	[79268393072444] = baseURL .. "/games/rayfield/sell_lemons.lua",
	[92416421522960] = baseURL .. "/games/rayfield/slime_rng.lua",
	[93978595733734] = baseURL .. "/games/rayfield/violence_district.lua",
}

local excludedGameIds = {
	[121864768012064] = true,
	[79378095465365] = true,
}

local function stripSourceBom(source)
	if type(source) ~= "string" then
		return source
	end
	if source:byte(1) == 0xEF and source:byte(2) == 0xBB and source:byte(3) == 0xBF then
		return source:sub(4)
	end
	return source
end

local function loadBootstrap()
	local okReq, mod = pcall(require, "functions/loader/bootstrap")
	if okReq and type(mod) == "table" and type(mod.start) == "function" then
		return mod
	end

	local url = baseURL .. "/functions/loader/bootstrap.lua"
	local okGet, source = pcall(function()
		return game:HttpGet(url)
	end)
	if not okGet or type(source) ~= "string" or #source < 32 then
		error("[sempatpanick] failed to load bootstrap: " .. tostring(source))
	end

	source = stripSourceBom(source)

	local compile = loadstring or load
	local chunk, err = compile(source, "functions/loader/bootstrap")
	if type(chunk) ~= "function" then
		error("[sempatpanick] bootstrap compile failed: " .. tostring(err))
	end

	local okRun, result = pcall(chunk)
	if not okRun or type(result) ~= "table" or type(result.start) ~= "function" then
		error("[sempatpanick] bootstrap run failed: " .. tostring(result))
	end

	return result
end

local bootstrap = loadBootstrap()
bootstrap.start(baseURL, games, excludedGameIds)
