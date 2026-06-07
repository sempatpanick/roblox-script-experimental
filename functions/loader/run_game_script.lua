--[[
  Fetch and execute a remote game script URL.
  Sets shared.sempatpanick_baseURL when baseURL is provided.
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

local function runGameScript(scriptURL, baseURL)
	if type(baseURL) == "string" and baseURL ~= "" then
		shared.sempatpanick_baseURL = baseURL
	end

	local okGet, source = pcall(function()
		return game:HttpGet(scriptURL)
	end)
	if not okGet or type(source) ~= "string" or #source < 64 then
		warn("[sempatpanick] HttpGet failed for", scriptURL, tostring(source))
		return false, "HttpGet failed"
	end

	source = stripSourceBom(source)

	local compile = loadstring or load
	if type(compile) ~= "function" then
		warn("[sempatpanick] loadstring/load unavailable")
		return false, "load unavailable"
	end

	local chunk, err = compile(source, "sempatpanick_game_script")
	if type(chunk) ~= "function" then
		warn("[sempatpanick] compile failed:", tostring(err))
		return false, tostring(err)
	end

	local okRun, runErr = pcall(chunk)
	if not okRun then
		warn("[sempatpanick] script error:", tostring(runErr))
		return false, tostring(runErr)
	end

	return true
end

return {
	run = runGameScript,
	stripSourceBom = stripSourceBom,
}
