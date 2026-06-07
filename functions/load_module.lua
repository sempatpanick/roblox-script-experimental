--[[
  Load a function module from functions/ (local require or HttpGet via shared.sempatpanick_baseURL).
  Usage from tabs/games:
    local loadFunctionModule = require("../../functions/load_module")
    local dropdown = loadFunctionModule("rayfield/dropdown")
]]

local function loadFunctionModule(subpath)
	subpath = string.gsub(subpath or "", "%.lua$", "")

	local okReq, mod = pcall(require, "../" .. subpath)
	if okReq then
		return mod
	end

	okReq, mod = pcall(require, "../../functions/" .. subpath)
	if okReq then
		return mod
	end

	local baseURL = shared.sempatpanick_baseURL
	if type(baseURL) ~= "string" or baseURL == "" then
		error("[functions] baseURL not set; cannot load " .. subpath)
	end

	local url = baseURL .. "/functions/" .. subpath .. ".lua"
	local okGet, source = pcall(function()
		return game:HttpGet(url)
	end)
	if not okGet or type(source) ~= "string" or #source < 8 then
		error("[functions] HttpGet failed for " .. url .. ": " .. tostring(source))
	end

	if source:byte(1) == 0xEF and source:byte(2) == 0xBB and source:byte(3) == 0xBF then
		source = source:sub(4)
	end

	local compile = loadstring or load
	if type(compile) ~= "function" then
		error("[functions] loadstring/load unavailable")
	end

	local chunk, compileErr = compile(source, "functions/" .. subpath)
	if type(chunk) ~= "function" then
		error("[functions] compile failed for " .. subpath .. ": " .. tostring(compileErr))
	end

	local okRun, result = pcall(chunk)
	if not okRun then
		error("[functions] run failed for " .. subpath .. ": " .. tostring(result))
	end

	return result
end

-- HttpGet-loaded chunks cannot require() sibling modules; expose loader globally.
shared.__sempatpanick_load_function_module = loadFunctionModule

return loadFunctionModule
