local baseURL = "http://127.0.0.1:5500"

local games = {
    [83369512629707] = baseURL .. "/sawah_indo.lua",
    [128070940451265] = baseURL .. "/speed_bike_escape.lua",
    [2693023319] = baseURL .. "/expedition_antartica.lua",
    [14963184269] = baseURL .. "/mount_sumbing.lua",
    [76964310785698] = baseURL .. "/mount_yahayuk.lua",
    [118098747383977] = baseURL .. "/mancing_indo.lua",
    [78404864377525] = baseURL .. "/mancing_indo_galatama.lua",
}

local fallbackScriptURL = baseURL .. "/others.lua"
local excludedGameIds = {
    [121864768012064] = true,
}

local currentID = game.PlaceId
if excludedGameIds[currentID] then
    return
end
local scriptURL = games[currentID] or fallbackScriptURL

loadstring(game:HttpGet(scriptURL))()

