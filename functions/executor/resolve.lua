local function resolveExecutorFn(name)
	local v = rawget(_G, name)
	if type(v) == "function" then
		return v
	end
	local getGenvFn = rawget(_G, "getgenv")
	local okGenv, genv = pcall(function()
		return type(getGenvFn) == "function" and getGenvFn() or nil
	end)
	if okGenv and type(genv) == "table" then
		local gv = rawget(genv, name) or genv[name]
		if type(gv) == "function" then
			return gv
		end
	end
	local okFenv, fenv = pcall(function()
		return getfenv and getfenv()
	end)
	if okFenv and type(fenv) == "table" then
		local fv = rawget(fenv, name) or fenv[name]
		if type(fv) == "function" then
			return fv
		end
	end
	return nil
end

local function ensureFolderPath(dirPath, makeFolderFn, isFolderFn)
	makeFolderFn = makeFolderFn or resolveExecutorFn("makefolder")
	isFolderFn = isFolderFn or resolveExecutorFn("isfolder")
	if type(makeFolderFn) ~= "function" then
		return false, "makefolder() is not available in this executor"
	end

	local segments = {}
	for piece in string.gmatch(dirPath or "", "[^/]+") do
		if piece ~= "" and piece ~= "." then
			table.insert(segments, piece)
		end
	end

	local current = ""
	for _, seg in ipairs(segments) do
		current = (current == "") and seg or (current .. "/" .. seg)
		local exists = false
		if type(isFolderFn) == "function" then
			local okExists, result = pcall(function()
				return isFolderFn(current)
			end)
			exists = okExists and result or false
		end
		if not exists then
			local okMake, errMake = pcall(function()
				makeFolderFn(current)
			end)
			if not okMake then
				if type(isFolderFn) == "function" then
					local okRetry, retryExists = pcall(function()
						return isFolderFn(current)
					end)
					if okRetry and retryExists then
						exists = true
					else
						return false, tostring(errMake)
					end
				else
					return false, tostring(errMake)
				end
			end
		end
	end
	return true, nil
end

return {
	resolveExecutorFn = resolveExecutorFn,
	ensureFolderPath = ensureFolderPath,
}
