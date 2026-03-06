local baseURL = "https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main"

local games = {
    [83369512629707] = baseURL .. "/sawah_indo.lua",
    [128070940451265] = baseURL .. "/speed_bike_escape.lua",
    [2693023319] = baseURL .. "/expedition_antartica.lua",
}

local fallbackScriptURL = baseURL .. "/others.lua"

local currentID = game.PlaceId
local scriptURL = games[currentID] or fallbackScriptURL

loadstring(game:HttpGet(scriptURL))()

