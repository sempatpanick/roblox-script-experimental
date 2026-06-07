--[[
  Rayfield-like UI API on top of WindUI Window / Tab.
  Used by tabs/windui/* to reuse tabs/rayfield/* logic unchanged.
]]

local TAB_ICONS = {
	["Local Player"] = "user",
	["Teleport"] = "map-pin",
	["Objects"] = "box",
	["Recording"] = "video",
	["Config"] = "settings",
	["Automation"] = "bot",
	["Avatar"] = "scan-face",
}

local function isEmptyRayfieldCurrentOption(currentOption)
	return type(currentOption) == "table" and currentOption[1] == nil and next(currentOption) == nil
end

local function dropdownValueFromCurrentOption(options, currentOption, allowNone)
	options = options or {}

	if type(currentOption) == "table" and currentOption[1] ~= nil then
		local selected = currentOption[1]
		for index, name in ipairs(options) do
			if name == selected then
				return index
			end
		end
		return selected
	end

	if isEmptyRayfieldCurrentOption(currentOption) then
		return allowNone and nil or ((#options > 0) and 1 or nil)
	end

	if type(currentOption) == "string" then
		for index, name in ipairs(options) do
			if name == currentOption then
				return index
			end
		end
		return currentOption
	end

	if currentOption ~= nil then
		return currentOption
	end

	return allowNone and nil or ((#options > 0) and 1 or nil)
end

local function wrapDropdownCallback(callback)
	if type(callback) ~= "function" then
		return nil
	end
	return function(selected)
		if type(selected) == "table" then
			callback(selected)
		elseif selected == nil then
			callback({})
		else
			callback({ selected })
		end
	end
end

local function createWindUIElement(factory, props)
	local result = factory(props)
	if type(result) == "table" then
		return result
	end
	return nil
end

local function wrapElement(elem, kind)
	if not elem then
		return nil
	end

	local wrapped = {
		_elem = elem,
	}

	if kind == "paragraph" then
		function wrapped.SetTitle(_, title)
			if elem.SetTitle then
				elem:SetTitle(title)
			end
		end

		function wrapped.SetDesc(_, desc)
			if elem.SetDesc then
				elem:SetDesc(desc)
			end
		end

		function wrapped.Set(_, data)
			if type(data) ~= "table" then
				return
			end
			if data.Title ~= nil then
				wrapped:SetTitle(data.Title)
			end
			if data.Content ~= nil then
				wrapped:SetDesc(data.Content)
			elseif data.Desc ~= nil then
				wrapped:SetDesc(data.Desc)
			end
		end

		wrapped.SetValue = wrapped.Set
		return wrapped
	end

	if kind == "input" then
		wrapped.CurrentValue = elem.Value
		function wrapped.GetValue(_)
			return elem.Value
		end
	elseif kind == "toggle" then
		wrapped.CurrentValue = elem.Value
	end

	if kind == "image" then
		function wrapped.Set(_, data)
			if type(data) ~= "table" then
				return
			end
			if data.Image and elem.SetImage then
				elem:SetImage(data.Image)
			end
		end
		return wrapped
	end

	if kind == "dropdown" then
		function wrapped.Refresh(_, values)
			if type(elem.Refresh) == "function" then
				elem:Refresh(values or {})
			end
		end

		function wrapped.Select(_, value)
			if type(elem.Select) == "function" then
				elem:Select(value)
			end
		end

		function wrapped.Set(_, value)
			local pick = value
			if type(value) == "table" then
				pick = value[1]
			end
			wrapped:Select(pick)
		end

		wrapped.SetValue = wrapped.Set
		return wrapped
	elseif kind == "input" or kind == "toggle" or kind == "slider" then
		function wrapped.Set(_, value, ...)
			if elem.Set then
				elem:Set(value, ...)
			end
			if kind == "input" or kind == "toggle" then
				wrapped.CurrentValue = value
			end
		end
	end

	wrapped.SetValue = wrapped.Set

	return wrapped
end

local function mapProps(props, kind)
	local mapped = {
		Title = props.Name or props.Title,
		Desc = props.Content or props.Desc,
		Flag = props.Flag,
		Callback = props.Callback,
		Icon = props.Icon,
		Locked = props.Locked,
		LockedTitle = props.LockedTitle,
	}

	if kind == "toggle" then
		mapped.Value = props.CurrentValue
		mapped.Type = props.Type
	elseif kind == "input" then
		mapped.Placeholder = props.PlaceholderText or props.Placeholder
		mapped.Value = props.CurrentValue or props.Value or ""
		mapped.Type = props.Type
	elseif kind == "dropdown" then
		mapped.Values = props.Options or props.Values or {}
		local currentOption = props.CurrentOption
		if currentOption == nil then
			currentOption = props.Value
		end
		mapped.AllowNone = props.AllowNone == true or isEmptyRayfieldCurrentOption(currentOption)
		mapped.Value = dropdownValueFromCurrentOption(mapped.Values, currentOption, mapped.AllowNone)
		mapped.Multi = props.Multi == true
		mapped.SearchBarEnabled = props.Search == true
		mapped.Callback = wrapDropdownCallback(props.Callback)
	elseif kind == "slider" then
		local range = props.Range or {}
		mapped.Step = props.Increment or props.Step or 1
		mapped.Value = {
			Min = range[1] or (props.Value and props.Value.Min) or 0,
			Max = range[2] or (props.Value and props.Value.Max) or 100,
			Default = props.CurrentValue or (props.Value and props.Value.Default) or range[1] or 0,
		}
	elseif kind == "paragraph" then
		mapped.Title = props.Title or props.Name or "Paragraph"
		mapped.Desc = props.Content or props.Desc
		mapped.Callback = nil
	elseif kind == "button" then
		mapped.Callback = props.Callback
	end

	return mapped
end

local function createTabWrapper(winduiTab)
	local tab = {}

	function tab.CreateSection(_, title)
		local _, section = winduiTab:Section({ Title = title or "Section" })
		return section
	end

	function tab.CreateButton(_, props)
		props = props or {}
		return wrapElement(createWindUIElement(function(mapped)
			return winduiTab:Button(mapped)
		end, mapProps(props, "button")), "button")
	end

	function tab.CreateToggle(_, props)
		props = props or {}
		return wrapElement(createWindUIElement(function(mapped)
			return winduiTab:Toggle(mapped)
		end, mapProps(props, "toggle")), "toggle")
	end

	function tab.CreateInput(_, props)
		props = props or {}
		return wrapElement(createWindUIElement(function(mapped)
			return winduiTab:Input(mapped)
		end, mapProps(props, "input")), "input")
	end

	function tab.CreateDropdown(_, props)
		props = props or {}
		return wrapElement(createWindUIElement(function(mapped)
			return winduiTab:Dropdown(mapped)
		end, mapProps(props, "dropdown")), "dropdown")
	end

	function tab.CreateParagraph(_, props)
		props = props or {}
		return wrapElement(createWindUIElement(function(mapped)
			return winduiTab:Paragraph(mapped)
		end, mapProps(props, "paragraph")), "paragraph")
	end

	function tab.CreateSlider(_, props)
		props = props or {}
		return wrapElement(createWindUIElement(function(mapped)
			return winduiTab:Slider(mapped)
		end, mapProps(props, "slider")), "slider")
	end

	function tab.CreateImage(_, props)
		props = props or {}
		if type(winduiTab.Image) ~= "function" then
			return nil
		end
		return wrapElement(createWindUIElement(function()
			return winduiTab:Image({
				Image = props.Image or "",
				AspectRatio = props.AspectRatio or "1:1",
			})
		end), "image")
	end

	tab._winduiTab = winduiTab
	return tab
end

local function wrapWindow(winduiWindow)
	local window = {
		_winduiWindow = winduiWindow,
	}

	function window.CreateTab(_, title, _iconId)
		local icon = TAB_ICONS[title] or "circle"
		local winduiTab = winduiWindow:Tab({
			Title = title or "Tab",
			Icon = icon,
		})
		return createTabWrapper(winduiTab)
	end

	if winduiWindow.SetCurrentConfig then
		window.SetCurrentConfig = function(_, cfg)
			return winduiWindow:SetCurrentConfig(cfg)
		end
	end

	setmetatable(window, {
		__index = function(_, key)
			if key == "ConfigManager" then
				return winduiWindow.ConfigManager
			end
			return nil
		end,
	})

	return window
end

return {
	wrapWindow = wrapWindow,
	wrapTab = createTabWrapper,
	TAB_ICONS = TAB_ICONS,
}
