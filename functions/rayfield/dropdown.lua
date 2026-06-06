local function rayfieldDropdownFirst(valueOrTable)
	if type(valueOrTable) == "table" then
		return valueOrTable[1]
	end
	return valueOrTable
end

local function prependNoneOption(items, noneLabel)
	noneLabel = noneLabel or "(None)"
	local options = { noneLabel }
	for _, item in ipairs(items or {}) do
		table.insert(options, item)
	end
	return options
end

return {
	rayfieldDropdownFirst = rayfieldDropdownFirst,
	prependNoneOption = prependNoneOption,
}
