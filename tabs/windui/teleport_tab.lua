--[[
  Teleport tab module for WindUI scripts.
  Reuses tabs/rayfield/teleport_tab.lua logic via windui/compat.

  Usage:
    createTeleportTab(Window, mountNotify, options)
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
local createRayfieldTeleportTab = loadRayfieldTab("teleport_tab")

local function createTeleportTab(windowRef, notifyFn, options)
	return createRayfieldTeleportTab(compatMod.wrapWindow(windowRef), notifyFn, options or {})
end

return createTeleportTab
