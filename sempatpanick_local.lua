local baseURL = "http://127.0.0.1:5500"

local games = {
    [83369512629707] = baseURL .. "/sawah_indo_2.lua",
    [128070940451265] = baseURL .. "/speed_bike_escape_2.lua",
    [2693023319] = baseURL .. "/expedition_antartica_2.lua",
    [14963184269] = baseURL .. "/mount_sumbing_2.lua",
    [76964310785698] = baseURL .. "/mount_yahayuk_2.lua",
    [118098747383977] = baseURL .. "/mancing_indo_2.lua",
    [78404864377525] = baseURL .. "/mancing_indo_galatama_2.lua",
    [92416421522960] = baseURL .. "/slime_rng_2.lua",
    [93978595733734] = baseURL .. "/violence_district_2.lua",
}

local fallbackScriptURL = baseURL .. "/others_2.lua"
local excludedGameIds = {
    [121864768012064] = true,
    [79378095465365] = true,
}

local currentID = game.PlaceId
if excludedGameIds[currentID] then
    return
end
local scriptURL = games[currentID] or fallbackScriptURL

loadstring(game:HttpGet(scriptURL))()

