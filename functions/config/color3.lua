local function encodeColor3(c)
	return {
		__type = "Color3",
		R = math.floor(c.R * 255 + 0.5),
		G = math.floor(c.G * 255 + 0.5),
		B = math.floor(c.B * 255 + 0.5),
	}
end

local function decodeColor3(v)
	if type(v) == "table" and v.__type == "Color3" then
		return Color3.fromRGB(tonumber(v.R) or 255, tonumber(v.G) or 255, tonumber(v.B) or 255)
	end
	return nil
end

local function isWindUIConfigObject(obj)
	return type(obj) == "table" and type(obj.Save) == "function" and type(obj.Load) == "function"
end

return {
	encodeColor3 = encodeColor3,
	decodeColor3 = decodeColor3,
	isWindUIConfigObject = isWindUIConfigObject,
}
