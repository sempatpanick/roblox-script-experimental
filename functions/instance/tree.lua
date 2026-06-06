local function syncNestExpandClassSetFromDropdownValue(value)
	local classSet = {}
	if type(value) == "table" then
		for _, item in ipairs(value) do
			local name = (type(item) == "table" and item.Title) or item
			if type(name) == "string" and name ~= "" then
				classSet[name] = true
			end
		end
	elseif type(value) == "string" and value ~= "" then
		classSet[value] = true
	end
	return classSet
end

local function shouldNestChildrenInObjectsTree(inst, expandClassSet)
	if next(expandClassSet or {}) == nil then
		return false
	end
	for className, _ in pairs(expandClassSet) do
		if inst:IsA(className) then
			return true
		end
	end
	return false
end

local function buildInstancePathUnderAncestor(inst, ancestor)
	if not ancestor or not inst then
		return inst and inst.Name or ""
	end
	if not inst:IsDescendantOf(ancestor) then
		return inst.Name
	end
	local parts = {}
	local cur = inst
	while cur and cur ~= ancestor do
		table.insert(parts, 1, cur.Name)
		cur = cur.Parent
	end
	return table.concat(parts, ".")
end

local function buildObjectsServiceDropdownValues(children, formatInstanceDisplay)
	local displayCounts = {}
	local values = {}
	for _, child in ipairs(children or {}) do
		local display = formatInstanceDisplay(child, nil, true)
		local c = (displayCounts[display] or 0) + 1
		displayCounts[display] = c
		local title = display
		if c > 1 then
			title = display .. "  [" .. child:GetDebugId() .. "]"
		end
		table.insert(values, { Title = title, Instance = child })
	end
	return values
end

local function buildNestedObjectChildrenListText(root, opts)
	opts = opts or {}
	local formatInstanceDisplay = opts.formatInstanceDisplay
	local expandClassSet = opts.expandClassSet or {}
	local maxDepth = opts.maxDepth or 14
	local maxLines = opts.maxLines or 3000
	local lines = {}

	local function appendChildren(parent, depth, indentStr)
		if #lines >= maxLines or depth >= maxDepth then
			return
		end
		local childList = parent:GetChildren()
		table.sort(childList, function(a, b)
			return string.lower(a.Name) < string.lower(b.Name)
		end)
		for _, child in ipairs(childList) do
			if #lines >= maxLines then
				table.insert(lines, indentStr .. "... (truncated, max " .. maxLines .. " lines)")
				return
			end
			table.insert(lines, indentStr .. formatInstanceDisplay(child, nil, true))
			local sub = child:GetChildren()
			if #sub > 0 and shouldNestChildrenInObjectsTree(child, expandClassSet) then
				if depth + 1 < maxDepth then
					appendChildren(child, depth + 1, indentStr .. "  ")
				else
					table.insert(
						lines,
						indentStr .. "  ... (" .. #sub .. " children, max depth " .. maxDepth .. ")"
					)
				end
			end
		end
	end

	appendChildren(root, 0, "")
	if #lines == 0 then
		return "(no children)"
	end
	return table.concat(lines, "\n")
end

local function findInstancesByNameUnder(root, queryRaw)
	local raw = tostring(queryRaw or "")
	local q = string.gsub(string.gsub(raw, "^%s+", ""), "%s+$", "")
	if q == "" then
		return nil, q
	end
	local ql = string.lower(q)
	local matches = {}
	for _, d in ipairs(root:GetDescendants()) do
		if string.find(string.lower(d.Name), ql, 1, true) then
			table.insert(matches, d)
		end
	end
	table.sort(matches, function(a, b)
		return string.lower(buildInstancePathUnderAncestor(a, root))
			< string.lower(buildInstancePathUnderAncestor(b, root))
	end)
	return matches, q
end

return {
	syncNestExpandClassSetFromDropdownValue = syncNestExpandClassSetFromDropdownValue,
	shouldNestChildrenInObjectsTree = shouldNestChildrenInObjectsTree,
	buildInstancePathUnderAncestor = buildInstancePathUnderAncestor,
	buildObjectsServiceDropdownValues = buildObjectsServiceDropdownValues,
	buildNestedObjectChildrenListText = buildNestedObjectChildrenListText,
	findInstancesByNameUnder = findInstancesByNameUnder,
}
