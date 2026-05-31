local baseURL = "http://127.0.0.1:5500"

local games = {
    [83369512629707] = baseURL .. "/sawah_indo.lua",
    [128070940451265] = baseURL .. "/speed_bike_escape.lua",
    [2693023319] = baseURL .. "/expedition_antartica.lua",
    [103593441753340] = baseURL .. "/find_the_button.lua",
    [82775216869079] = baseURL .. "/find_the_button.lua",
    [14963184269] = baseURL .. "/mount_sumbing.lua",
    [76964310785698] = baseURL .. "/mount_yahayuk.lua",
    [118098747383977] = baseURL .. "/mancing_indo.lua",
    [78404864377525] = baseURL .. "/mancing_indo_galatama.lua",
    [92416421522960] = baseURL .. "/slime_rng.lua",
    [93978595733734] = baseURL .. "/violence_district.lua",
}

local fallbackScriptURL = baseURL .. "/others.lua"
local excludedGameIds = {
    [121864768012064] = true,
    [79378095465365] = true,
}

local currentID = game.PlaceId
if excludedGameIds[currentID] then
    return
end
local scriptURL = games[currentID] or fallbackScriptURL

do
    local okGet, source = pcall(function()
        return game:HttpGet(scriptURL)
    end)
    if not okGet or type(source) ~= "string" or #source < 64 then
        warn("[sempatpanick] HttpGet failed for", scriptURL, tostring(source))
        return
    end
    local compile = loadstring or load
    if type(compile) ~= "function" then
        warn("[sempatpanick] loadstring/load unavailable")
        return
    end
    local chunk, err = compile(source, "sempatpanick_game_script")
    if type(chunk) ~= "function" then
        warn("[sempatpanick] compile failed:", tostring(err))
        return
    end
    local okRun, runErr = pcall(chunk)
    if not okRun then
        warn("[sempatpanick] script error:", tostring(runErr))
    end
end

