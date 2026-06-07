local baseURL = "http://127.0.0.1:5500"

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
    [92416421522960] = baseURL .. "/games/rayfield/slime_rng.lua",
    [93978595733734] = baseURL .. "/games/rayfield/violence_district.lua",
}

local fallbackScriptURL = baseURL .. "/games/rayfield/others.lua"
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
    if source:byte(1) == 0xEF and source:byte(2) == 0xBB and source:byte(3) == 0xBF then
        source = source:sub(4)
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
    shared.sempatpanick_baseURL = baseURL
    local okRun, runErr = pcall(chunk)
    if not okRun then
        warn("[sempatpanick] script error:", tostring(runErr))
    end
end

