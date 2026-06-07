--[[
  Config tab module for WindUI scripts.
  Reuses tabs/rayfield/config_tab.lua logic via windui/compat.

  Usage:
    createConfigTab(Window, mountNotify, options)

  options (required):
    configDir = "sempatpanick/my_game"
  options (optional):
    windUILibrary = WindUI
    gameLabel, autoloadFile, onCollectExtra, sequentialLoad, ...
]]

local loadFunctionModule
do
	local ok, loader = pcall(require, "../../functions/load_module")
	if ok and type(loader) == "function" then
		loadFunctionModule = loader
	else
		local baseURL = shared.sempatpanick_baseURL
		assert(type(baseURL) == "string", "[tabs/windui] baseURL not set")
		local okGet, source = pcall(function()
			return game:HttpGet(baseURL .. "/functions/load_module.lua")
		end)
		assert(okGet and type(source) == "string", "[tabs/windui] failed to load functions/load_module")
		if source:byte(1) == 0xEF and source:byte(2) == 0xBB and source:byte(3) == 0xBF then
			source = source:sub(4)
		end
		local chunk = (loadstring or load)(source, "functions/load_module")
		loadFunctionModule = chunk()
	end
end

local compatMod = loadFunctionModule("windui/compat")
local loadRayfieldTab = loadFunctionModule("windui/load_tab")
local createRayfieldConfigTab = loadRayfieldTab("config_tab")

local function createConfigTab(windowRef, notifyFn, options)
	options = options or {}
	options.useWindUIConfig = true
	if not options.rayfieldLibrary then
		options.rayfieldLibrary = options.windUILibrary or { Flags = {} }
	end
	return createRayfieldConfigTab(compatMod.wrapWindow(windowRef), notifyFn, options)
end

return createConfigTab
