local games = {
    [83369512629707] = "http://localhost:5500/sawah_indo.lua",
    [128070940451265] = "http://localhost:5500/speed_bike_escape.lua",
    [2693023319] = "http://localhost:5500/expedition_antartica.lua",
}

local fallbackScriptURL = "http://localhost:5500/others.lua"

local currentID = game.PlaceId
local scriptURL = games[currentID] or fallbackScriptURL

loadstring(game:HttpGet(scriptURL))()

