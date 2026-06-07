-- Expedition Antarctica camp routes and teleport destinations (UI-agnostic).

local CAMP_LIST = {
	{
		id = "Camp1",
		name = "Camp 1",
		defaultDuration = 110,
		waterRefillObject = "WaterRefill_Camp1",
		positions = {
			{ position = "-4007.86, 55.13, -575.04", mode = "tween", isDelay = true },
			{ position = "-3747.10, 215.14, -6.94", mode = "tween", isDelay = true },
			{ position = "-3718.86, 240.00, 235.13", mode = "tween", isDelay = true },
		},
	},
	{
		id = "Camp2",
		name = "Camp 2",
		defaultDuration = 180,
		waterRefillObject = "WaterRefill_Camp2",
		positions = {
			{ position = "-3041.40, 312.49, 2.24", mode = "tween", isDelay = true },
			{ position = "-2740.04, 268.76, -341.26", mode = "tween", isDelay = true },
			{ position = "-2591.64, 244.66, -329.08", mode = "tween", isDelay = true },
			{ position = "-2472.79, 193.05, -368.09", mode = "walk", isDelay = true },
			{ position = "-2361.14, 167.89, -283.53", mode = "walk", isDelay = true },
			{ position = "-2319.45, 120.66, -157.36", mode = "walk", isDelay = true },
			{ position = "-2278.87, 101.00, -71.63", mode = "walk", isDelay = true },
			{ position = "-1394.26, 111.32, -77.06", mode = "tween", isDelay = true },
			{ position = "-578.56, 86.65, -167.99", mode = "tween", isDelay = true },
			{ position = "882.79, 77.73, -266.99", mode = "tween", isDelay = true },
			{ position = "1534.47, 75.19, -170.83", mode = "tween", isDelay = true },
			{ position = "1685.07, 105.46, -112.99", mode = "walk", isDelay = true },
			{ position = "1789.92, 110.44, -137.28", mode = "walk", isDelay = true },
		},
	},
	{
		id = "Camp3",
		name = "Camp 3",
		defaultDuration = 250,
		waterRefillObject = "WaterRefill_Camp3",
		positions = {
			{ position = "3136.70, 850.61, -201.02", mode = "tween", isDelay = true, walkWithJump = false },
			{ position = "3231.51, 992.40, 5.27", mode = "tween", isDelay = true, walkWithJump = false },
			{ position = "3349.81, 1025.13, 279.19", mode = "teleport", isDelay = true, walkWithJump = false },
			{ position = "3338.75, 1030.70, 337.18", mode = "tween", isDelay = true, walkWithJump = false },
			{ position = "3365.01, 1036.87, 395.82", mode = "walk", isDelay = true, walkWithJump = false },
			{ position = "3389.80, 1132.63, 359.09", mode = "tween", isDelay = true, walkWithJump = false },
			{ position = "3631.94, 1366.45, 192.92", mode = "tween", isDelay = true, walkWithJump = false },
			{ position = "3732.79, 1508.77, -183.32", mode = "tween", isDelay = true, walkWithJump = false },
			{ position = "3829.39, 1419.69, -339.77", mode = "walk", isDelay = true, walkWithJump = false },
			{ position = "3908.43, 1361.83, -404.79", mode = "walk", isDelay = true, walkWithJump = false },
			{ position = "4069.67, 1203.41, -376.51", mode = "walk", isDelay = true, walkWithJump = false },
			{ position = "4079.11, 1197.26, -372.15", mode = "walk", isDelay = true, walkWithJump = false },
			{ position = "4185.05, 1169.44, -330.00", mode = "tween", isDelay = true, walkWithJump = false },
			{ position = "4328.11, 1164.36, -211.04", mode = "walk", isDelay = true, walkWithJump = false },
			{ position = "4463.34, 1127.75, -98.33", mode = "walk", isDelay = true, walkWithJump = false },
			{ position = "4485.26, 1114.58, -81.75", mode = "walk", isDelay = true, walkWithJump = false },
			{ position = "4529.68, 1107.42, -63.48", mode = "tween", isDelay = true, walkWithJump = false },
			{ position = "4570.83, 1097.78, -6.35", mode = "tween", isDelay = true, walkWithJump = false },
			{ position = "4633.24, 1101.93, 130.08", mode = "tween", isDelay = true, walkWithJump = false },
			{ position = "4661.15, 1004.77, 218.85", mode = "walk", isDelay = false, walkWithJump = false },
			{ position = "4669.85, 968.70, 246.51", mode = "walk", isDelay = false, walkWithJump = false },
			{ position = "4710.12, 890.76, 270.32", mode = "walk", isDelay = false, walkWithJump = false },
			{ position = "4703.68, 837.62, 334.12", mode = "walk", isDelay = false, walkWithJump = false },
			{ position = "5021.11, 770.58, 295.28", mode = "tween", isDelay = true, walkWithJump = false },
			{ position = "5123.25, 739.04, 249.49", mode = "teleport", isDelay = true, walkWithJump = false },
			{ position = "5384.25, 753.53, 9.69", mode = "tween", isDelay = true, walkWithJump = false },
			{ position = "5425.06, 435.53, -3.71", mode = "teleport", isDelay = false, walkWithJump = false },
			{ position = "5500.40, 342.59, -57.53", mode = "walk", isDelay = true, walkWithJump = false },
			{ position = "5636.13, 341.10, -51.81", mode = "walk", isDelay = true, walkWithJump = false },
			{ position = "5767.25, 321.00, -46.29", mode = "walk", isDelay = true, walkWithJump = false },
			{ position = "5864.60, 321.00, -42.19", mode = "walk", isDelay = true, walkWithJump = false },
			{ position = "5892.31, 320.00, -19.92", mode = "walk", isDelay = true, walkWithJump = false },
		},
	},
	{
		id = "Camp4",
		name = "Camp 4",
		defaultDuration = 160,
		waterRefillObject = "WaterRefill_Camp4",
		positions = {
			{ position = "6424.29, 377.47, 223.09", mode = "tween", isDelay = true },
			{ position = "6480.56, 358.37, 261.93", mode = "tween", isDelay = true },
			{ position = "6567.11, 332.93, 284.24", mode = "tween", isDelay = true },
			{ position = "6643.09, 352.60, 296.53", mode = "tween", isDelay = true },
			{ position = "6735.76, 346.51, 337.65", mode = "tween", isDelay = true },
			{ position = "6857.57, 354.17, 350.07", mode = "tween", isDelay = true },
			{ position = "6882.65, 333.54, 335.85", mode = "tween", isDelay = true },
			{ position = "7205.48, 322.91, 330.44", mode = "teleport", isDelay = true },
			{ position = "7598.63, 334.01, 190.40", mode = "teleport", isDelay = true },
			{ position = "8202.02, 365.93, 802.10", mode = "teleport", isDelay = true },
			{ position = "8210.81, 420.96, 997.76", mode = "tween", isDelay = true },
			{ position = "8418.93, 495.82, 1016.79", mode = "tween", isDelay = true },
			{ position = "8991.70, 600.60, 103.15", mode = "tween", isDelay = true },
		},
	},
	{
		id = "SouthPole",
		name = "South Pole",
		defaultDuration = 90,
		waterRefillObject = nil,
		positions = {
			{ position = "9378.94, 591.41, 29.68", mode = "tween", isDelay = true },
			{ position = "9488.41, 595.76, 92.29", mode = "tween", isDelay = true },
			{ position = "9568.12, 596.17, 116.95", mode = "tween", isDelay = true },
			{ position = "9627.23, 597.33, 70.38", mode = "tween", isDelay = true },
			{ position = "9674.66, 591.93, 17.96", mode = "tween", isDelay = true },
			{ position = "9867.68, 592.70, 41.00", mode = "tween", isDelay = true },
			{ position = "9917.79, 598.46, -27.52", mode = "tween", isDelay = true },
			{ position = "10048.08, 583.07, -20.66", mode = "tween", isDelay = true },
			{ position = "10066.99, 563.36, -16.42", mode = "teleport", isDelay = false },
			{ position = "10097.70, 549.33, -15.57", mode = "teleport", isDelay = false },
			{ position = "10989.81, 569.12, 106.85", mode = "tween", isDelay = true },
		},
	},
}

local TELEPORT_CAMPS = {
	{ name = "Camp 1", position = "-3718.86, 240.00, 235.13" },
	{ name = "Camp 2", position = "1789.92, 110.44, -137.28" },
	{ name = "Camp 3", position = "5892.31, 320.00, -19.92" },
	{ name = "Camp 4", position = "8991.70, 600.60, 103.15" },
	{ name = "South Pole", position = "10989.81, 569.12, 106.85" },
}

local function getCampNames(campList)
	local names = {}
	for _, camp in ipairs(campList or CAMP_LIST) do
		table.insert(names, camp.name)
	end
	return names
end

local function getDefaultDurationForCamp(campName, campList)
	for _, camp in ipairs(campList or CAMP_LIST) do
		if camp.name == campName then
			return tostring(camp.defaultDuration or 5)
		end
	end
	return "5"
end

local function findCampByName(campName, campList)
	for _, camp in ipairs(campList or CAMP_LIST) do
		if camp.name == campName then
			return camp
		end
	end
	return nil
end

return {
	CAMP_LIST = CAMP_LIST,
	TELEPORT_CAMPS = TELEPORT_CAMPS,
	getCampNames = getCampNames,
	getDefaultDurationForCamp = getDefaultDurationForCamp,
	findCampByName = findCampByName,
}
