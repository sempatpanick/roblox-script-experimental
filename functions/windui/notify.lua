--[[
  WindUI notification helper matching mountNotify({ Title, Content, Icon }) shape.
]]

local ICONS = {
	check = "circle-check",
	x = "circle-x",
	close = "circle-x",
}

local function createNotifyFn(windUILibrary)
	return function(opts)
		opts = opts or {}
		local icon = opts.Icon
		if type(icon) == "number" then
			icon = nil
		elseif type(icon) == "string" then
			icon = ICONS[icon] or icon
		end
		windUILibrary:Notify({
			Title = opts.Title or "Notification",
			Content = opts.Content or "",
			Icon = icon,
			Duration = opts.Duration or 4,
		})
	end
end

return {
	create = createNotifyFn,
	ICONS = ICONS,
}
