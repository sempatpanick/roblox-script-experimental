local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local HYDRATION_MAX = 100

local function createAutoDrink()
	local minHydration = 50
	local autoDrinkEnabled = false
	local autoDrinkConnection = nil
	local refillingHydration = false

	local function getHydration()
		local lp = Players.LocalPlayer
		local v = lp:GetAttribute("Hydration")
		if v == nil then
			return nil
		end
		return tonumber(v) or v
	end

	local function fireDrink()
		local lp = Players.LocalPlayer
		local backpack = lp:FindFirstChild("Backpack")
		local character = lp:FindFirstChild("Character")
		local waterBottle = (backpack and backpack:FindFirstChild("Water Bottle"))
			or (character and character:FindFirstChild("Water Bottle"))
		if not waterBottle then
			return false
		end
		local event = waterBottle:FindFirstChild("RemoteEvent")
		if not event then
			return false
		end
		pcall(function()
			event:FireServer()
		end)
		return true
	end

	local function stop()
		if autoDrinkConnection then
			autoDrinkConnection:Disconnect()
			autoDrinkConnection = nil
		end
		autoDrinkEnabled = false
	end

	local function start()
		stop()
		autoDrinkEnabled = true
		refillingHydration = false
		local lastDrinkTime = 0
		local DRINK_INTERVAL = 1.0
		autoDrinkConnection = RunService.Heartbeat:Connect(function()
			if not autoDrinkEnabled then
				return
			end
			local hydration = getHydration()
			if hydration == nil then
				return
			end
			local minVal = tonumber(minHydration) or 50
			local targetMax = HYDRATION_MAX - 10
			if hydration <= minVal then
				refillingHydration = true
			end
			if hydration >= targetMax then
				refillingHydration = false
			end
			if refillingHydration and hydration < targetMax then
				local now = tick()
				if now - lastDrinkTime >= DRINK_INTERVAL then
					if fireDrink() then
						lastDrinkTime = now
					end
				end
			end
		end)
	end

	return {
		start = start,
		stop = stop,
		setMinHydration = function(value)
			minHydration = value
		end,
		isEnabled = function()
			return autoDrinkEnabled
		end,
	}
end

return {
	createAutoDrink = createAutoDrink,
	HYDRATION_MAX = HYDRATION_MAX,
}
