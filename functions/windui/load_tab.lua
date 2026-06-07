--[[
  Load a shared tab module from tabs/rayfield/ (local require or HttpGet).
]]

local function stripSourceBom(source)
	if type(source) == "string" and source:byte(1) == 0xEF and source:byte(2) == 0xBB and source:byte(3) == 0xBF then
		return source:sub(4)
	end
	return source
end

local function loadRayfieldTabModule(name)
	name = string.gsub(name or "", "%.lua$", "")

	local okReq, mod = pcall(require, "../../tabs/rayfield/" .. name)
	if okReq and type(mod) == "function" then
		return mod
	end

	okReq, mod = pcall(require, "../rayfield/" .. name)
	if okReq and type(mod) == "function" then
		return mod
	end

	local baseURL = shared.sempatpanick_baseURL
	if type(baseURL) ~= "string" or baseURL == "" then
		error("[windui/load_tab] baseURL not set; cannot load tabs/rayfield/" .. name)
	end

	local url = baseURL .. "/tabs/rayfield/" .. name .. ".lua"
	local okGet, source = pcall(function()
		return game:HttpGet(url)
	end)
	if not okGet or type(source) ~= "string" or #source < 64 then
		error("[windui/load_tab] HttpGet failed for " .. url .. ": " .. tostring(source))
	end

	source = stripSourceBom(source)

	local compile = loadstring or load
	if type(compile) ~= "function" then
		error("[windui/load_tab] loadstring/load unavailable")
	end

	local chunk, compileErr = compile(source, "tabs/rayfield/" .. name)
	if type(chunk) ~= "function" then
		error("[windui/load_tab] compile failed for " .. name .. ": " .. tostring(compileErr))
	end

	local okRun, result = pcall(chunk)
	if not okRun then
		error("[windui/load_tab] run failed for " .. name .. ": " .. tostring(result))
	end

	if type(result) ~= "function" then
		error("[windui/load_tab] module must return a function, got " .. type(result))
	end

	return result
end

return loadRayfieldTabModule
