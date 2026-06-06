local function formatValueForDisplay(val)
	if val == nil then
		return "nil"
	end
	if typeof(val) == "Instance" then
		return val.Name or tostring(val)
	end
	return tostring(val)
end

local function formatGuiInstanceTextForDisplay(inst)
	if not (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then
		return nil
	end
	local okT, txt = pcall(function()
		return inst.Text
	end)
	local display = (okT and type(txt) == "string") and txt or ""
	if display == "" then
		local okC, ct = pcall(function()
			return inst.ContentText
		end)
		if okC and type(ct) == "string" then
			display = ct
		end
	end
	if display == "" then
		return nil
	end
	display = string.gsub(display, "\r\n", " ")
	display = string.gsub(display, "\n", " ")
	if #display > 120 then
		display = string.sub(display, 1, 120) .. "..."
	end
	display = string.gsub(display, '"', "'")
	return display
end

local function formatInstanceDisplay(inst, isShowDataType, isShowLocation)
	if isShowDataType == false then
		local ok, val = pcall(function()
			return inst.Value
		end)
		if ok and val ~= nil then
			return inst.Name .. " = " .. formatValueForDisplay(val)
		end
		local guiText = formatGuiInstanceTextForDisplay(inst)
		if guiText then
			return inst.Name .. ' = "' .. guiText .. '"'
		end
		return inst.Name .. " = "
	end
	local base = inst.Name .. " = " .. inst.ClassName
	local ok, val = pcall(function()
		return inst.Value
	end)
	if ok and val ~= nil then
		base = base .. " (" .. formatValueForDisplay(val) .. ")"
	end
	local guiText = formatGuiInstanceTextForDisplay(inst)
	if guiText then
		base = base .. ' ("' .. guiText .. '")'
	end
	if isShowLocation and inst:IsA("BasePart") then
		local p = inst.Position
		base = base .. " [" .. string.format("%.1f, %.1f, %.1f", p.X, p.Y, p.Z) .. "]"
	end
	return base
end

return {
	formatValueForDisplay = formatValueForDisplay,
	formatGuiInstanceTextForDisplay = formatGuiInstanceTextForDisplay,
	formatInstanceDisplay = formatInstanceDisplay,
}
