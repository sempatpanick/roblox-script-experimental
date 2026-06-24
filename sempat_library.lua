--[[
	Sempat UI Library
	SempatUI-inspired layout with Rayfield + WindUI-compatible APIs.
	Built for smooth updates: no acrylic, no squircles, no per-element entrance tweens.
	Programmatic Set/Refresh updates change properties in-place (no rebuild).
]]

local SempatLibrary = {
	Version = "1.0.0",
	Flags = {},
}

local function getService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

local Players = getService("Players")
local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local RunService = getService("RunService")
local HttpService = getService("HttpService")

local LocalPlayer = Players.LocalPlayer

local function getGuiParent()
	local ok, hui = pcall(function()
		return gethui and gethui()
	end)
	if ok and typeof(hui) == "Instance" then
		return hui
	end
	if LocalPlayer then
		return LocalPlayer:WaitForChild("PlayerGui")
	end
	return nil
end

local protect = protectgui or (syn and syn.protect_gui) or function() end

local THEME = {
	window = Color3.fromRGB(18, 20, 26),
	sidebar = Color3.fromRGB(22, 24, 31),
	content = Color3.fromRGB(20, 22, 28),
	card = Color3.fromRGB(28, 30, 38),
	cardHover = Color3.fromRGB(34, 36, 46),
	stroke = Color3.fromRGB(48, 50, 62),
	accent = Color3.fromRGB(102, 224, 163),
	accentDark = Color3.fromRGB(72, 180, 130),
	text = Color3.fromRGB(245, 246, 250),
	muted = Color3.fromRGB(140, 144, 156),
	toggleOff = Color3.fromRGB(58, 60, 72),
	toggleOn = Color3.fromRGB(102, 224, 163),
	sliderTrack = Color3.fromRGB(40, 42, 52),
	sliderFill = Color3.fromRGB(102, 224, 163),
	danger = Color3.fromRGB(180, 70, 70),
	dropdownMenu = Color3.fromRGB(24, 26, 34),
	dropdownSearch = Color3.fromRGB(32, 34, 44),
	dropdownItemHover = Color3.fromRGB(44, 46, 58),
}

local appliedAccentColor = THEME.accent

local function getButtonTextColor()
	-- Match the panel behind buttons so label reads like a cutout in the accent fill.
	return THEME.content
end

local function darkenColor(color, amount)
	local hue, saturation, value = color:ToHSV()
	return Color3.fromHSV(hue, saturation, math.clamp(value * (amount or 0.88), 0, 1))
end

local function resolveElementColor(color)
	if color == nil or color == false then
		return nil
	end
	if typeof(color) == "Color3" then
		return color
	end
	if type(color) == "string" then
		local lowered = string.lower(color)
		if lowered == "accent" then
			return appliedAccentColor
		end
		if string.sub(color, 1, 1) == "#" then
			local ok, parsed = pcall(Color3.fromHex, color)
			if ok then
				return parsed
			end
		end
		if THEME[color] then
			return THEME[color]
		end
	end
	return nil
end

local function normalizeWindowTransparency(value)
	if type(value) ~= "number" then
		return 0
	end
	if value > 1 then
		return math.clamp(value / 100, 0, 0.95)
	end
	return math.clamp(value, 0, 0.95)
end

local ACCENT_PRESETS = {
	{ name = "Mint", color = Color3.fromRGB(102, 224, 163) },
	{ name = "Sky", color = Color3.fromRGB(91, 156, 245) },
	{ name = "Violet", color = Color3.fromRGB(167, 139, 250) },
	{ name = "Rose", color = Color3.fromRGB(244, 114, 182) },
	{ name = "Amber", color = Color3.fromRGB(251, 146, 60) },
	{ name = "Crimson", color = Color3.fromRGB(239, 68, 68) },
}

local function applyAccentTheme(color)
	appliedAccentColor = color
	THEME.accent = color
	THEME.toggleOn = color
	THEME.sliderFill = color
end

local accentRefreshers = {}
local activeDropdown

local function registerAccentRefresher(refresher)
	if type(refresher) ~= "function" then
		return
	end
	table.insert(accentRefreshers, refresher)
end

local function clearAccentRefreshers()
	table.clear(accentRefreshers)
end

local function runAccentRefreshers(color)
	for _, refresher in ipairs(accentRefreshers) do
		pcall(refresher, color)
	end
	if activeDropdown and activeDropdown.Parent then
		local menu = activeDropdown:FindFirstChild("DropdownMenu")
		if menu then
			local scroll = menu:FindFirstChild("OptionsScroll")
			if scroll and scroll:IsA("ScrollingFrame") then
				scroll.ScrollBarImageColor3 = color
			end
		end
	end
end

local function colorToPresetName(color)
	for _, preset in ipairs(ACCENT_PRESETS) do
		if preset.color == color then
			return preset.name
		end
	end
	return ACCENT_PRESETS[1].name
end
local DROPDOWN_ITEM_HEIGHT = 34
local DROPDOWN_SEARCH_HEIGHT = 36
local DROPDOWN_MAX_HEIGHT = 240

local ELEMENT_HEIGHT = 52
local SECTION_HEADER_HEIGHT = 36
local CORNER = 10
local CARD_CORNER = 8
local DROPDOWN_MENU_CORNER = 8
local SIDEBAR_WIDTH = 150
local PROFILE_CARD_HEIGHT = 54
local PROFILE_AVATAR_SIZE = 32
local PROFILE_PAD_X = 8
local HEADER_HEIGHT = 56
local HEADER_CONTROLS_WIDTH = 120
local CONTENT_TOPBAR_HEIGHT = 40
local DEFAULT_CONTENT_TITLE_SIZE = 18
local DEFAULT_WINDOW_SCALE = 100
local MIN_WINDOW_SCALE = 75
local MAX_WINDOW_SCALE = 125
local MIN_CONTENT_TITLE_SIZE = 14
local MAX_CONTENT_TITLE_SIZE = 24
local WINDOW_SIZE = Vector2.new(600, 440)
local GEAR_BUTTON_TEXT = "⚙"
local CHEVRON_MARK = ">"
local CHEVRON_DOWN_ROTATION = 90
local CHEVRON_RIGHT_ROTATION = 0
local MOBILE_FAB_SIZE = 52
local MOBILE_FAB_CORNER = 12
local FAB_DRAG_THRESHOLD = 8
local FAB_EDGE_INSET = 18

local function getDefaultFabPosition(parent)
	local parentSize = parent and parent.AbsoluteSize or Vector2.new(800, 600)
	return UDim2.fromOffset(
		parentSize.X - FAB_EDGE_INSET - MOBILE_FAB_SIZE / 2,
		parentSize.Y - FAB_EDGE_INSET - MOBILE_FAB_SIZE / 2
	)
end

local function clampFabPosition(parent, position)
	local parentSize = parent.AbsoluteSize
	local half = MOBILE_FAB_SIZE / 2
	local x = math.clamp(position.X.Offset, half, math.max(half, parentSize.X - half))
	local y = math.clamp(position.Y.Offset, half, math.max(half, parentSize.Y - half))
	return UDim2.fromOffset(x, y)
end

local function fabPositionFromData(data)
	if type(data) ~= "table" or type(data.x) ~= "number" or type(data.y) ~= "number" then
		return nil
	end
	return UDim2.fromOffset(data.x, data.y)
end

local layoutQueue = {}
local layoutScheduled = false

local function scheduleCanvasUpdate(scrollFrame)
	if not scrollFrame or not scrollFrame.Parent then
		return
	end
	layoutQueue[scrollFrame] = true
	if layoutScheduled then
		return
	end
	layoutScheduled = true
	task.defer(function()
		layoutScheduled = false
		local queue = layoutQueue
		layoutQueue = {}
		for frame in pairs(queue) do
			if frame.Parent then
				local layout = frame:FindFirstChildOfClass("UIListLayout")
				if layout then
					local padding = frame:FindFirstChildOfClass("UIPadding")
					local padY = 0
					if padding then
						padY = padding.PaddingTop.Offset + padding.PaddingBottom.Offset
					end
					frame.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + padY)
				end
			end
		end
	end)
end

local function new(className, props, children)
	local inst = Instance.new(className)
	for key, value in pairs(props or {}) do
		if key ~= "Parent" then
			inst[key] = value
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local function corner(parent, radius)
	return new("UICorner", {
		CornerRadius = UDim.new(0, radius or CORNER),
		Parent = parent,
	})
end

local function padding(parent, top, bottom, left, right)
	return new("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		PaddingLeft = UDim.new(0, left or 0),
		PaddingRight = UDim.new(0, right or 0),
		Parent = parent,
	})
end

local function stroke(parent, color, transparency, thickness)
	return new("UIStroke", {
		Color = color or THEME.stroke,
		Transparency = transparency or 0.35,
		Thickness = thickness or 1,
		Parent = parent,
	})
end

local function trimText(text)
	if type(text) ~= "string" then
		return ""
	end
	return (string.gsub(string.gsub(text, "^%s+", ""), "%s+$", ""))
end

local function isMobileDevice()
	return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

local function getWindowInitial(title)
	local cleaned = trimText(title)
	if cleaned == "" then
		return "S"
	end
	local pipe = string.find(cleaned, "|")
	if pipe then
		local after = trimText(string.sub(cleaned, pipe + 1))
		if after ~= "" then
			return string.sub(after, 1, 1):upper()
		end
	end
	return string.sub(cleaned, 1, 1):upper()
end

local function resolveWindowIcon(settings, title)
	local icon = settings and settings.Icon
	if type(icon) == "number" and icon > 0 then
		return "rbxassetid://" .. tostring(math.floor(icon)), "image"
	end
	if type(icon) == "string" and icon ~= "" then
		if string.find(icon, "rbxassetid://", 1, true) then
			return icon, "image"
		end
		if string.match(icon, "^%d+$") then
			return "rbxassetid://" .. icon, "image"
		end
	end
	return getWindowInitial(title), "text"
end

local function createMobileFab(screenGui, settings, title, onOpen, options)
	options = options or {}
	local iconValue, iconKind = resolveWindowIcon(settings, title)

	local fab = new("TextButton", {
		Name = "MobileFab",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = options.initialPosition or getDefaultFabPosition(screenGui),
		Size = UDim2.new(0, MOBILE_FAB_SIZE, 0, MOBILE_FAB_SIZE),
		BackgroundColor3 = THEME.card,
		BorderSizePixel = 0,
		Text = "",
		AutoButtonColor = false,
		Visible = false,
		ZIndex = 20,
		Parent = screenGui,
	})
	corner(fab, MOBILE_FAB_CORNER)
	stroke(fab, THEME.accent, 0.15, 1.5)

	if iconKind == "image" then
		new("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.new(0, 30, 0, 30),
			Image = iconValue,
			ScaleType = Enum.ScaleType.Fit,
			Parent = fab,
		})
	else
		new("TextLabel", {
			Name = "Initial",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Font = Enum.Font.GothamBold,
			TextSize = 22,
			TextColor3 = THEME.accent,
			Text = iconValue,
			Parent = fab,
		})
	end

	local function setFabPosition(position)
		if typeof(position) ~= "UDim2" then
			return
		end
		fab.Position = clampFabPosition(screenGui, position)
	end

	task.defer(function()
		if fab.Parent then
			setFabPosition(options.initialPosition or getDefaultFabPosition(screenGui))
		end
	end)

	local dragging = false
	local dragStart
	local startPos
	local didDrag = false

	fab.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		didDrag = false
		dragStart = input.Position
		startPos = fab.Position
	end)

	local function endFabDrag(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = false
		if didDrag then
			if type(options.onPositionChanged) == "function" then
				options.onPositionChanged(fab.Position)
			end
		else
			onOpen()
		end
	end

	UserInputService.InputEnded:Connect(endFabDrag)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType ~= Enum.UserInputType.MouseMovement
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		local delta = input.Position - dragStart
		if not didDrag and delta.Magnitude > FAB_DRAG_THRESHOLD then
			didDrag = true
		end
		if didDrag then
			setFabPosition(UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			))
		end
	end)

	screenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		if fab.Parent and fab.Visible then
			setFabPosition(fab.Position)
		end
	end)

	local mobileFab = {
		SetFabPosition = function(_, position)
			setFabPosition(position)
		end,
		GetFabPosition = function()
			return fab.Position
		end,
	}

	setmetatable(mobileFab, {
		__index = function(_, key)
			local value = fab[key]
			if type(value) == "function" then
				return function(_, ...)
					return value(fab, ...)
				end
			end
			return value
		end,
		__newindex = function(_, key, value)
			fab[key] = value
		end,
	})

	return mobileFab
end

local function safeCallback(callback, ...)
	if type(callback) ~= "function" then
		return
	end
	local ok, err = pcall(callback, ...)
	if not ok then
		warn("[SempatUI] callback error:", err)
	end
end

local function createElementCard(parent, title, desc, rightWidth)
	rightWidth = rightWidth or 140
	local hasDesc = type(desc) == "string" and desc ~= ""
	local cardPadY = 10
	local textRightGap = 12
	local textReserve = rightWidth + textRightGap
	local innerMinHeight = ELEMENT_HEIGHT - (cardPadY * 2)

	local card = new("Frame", {
		Name = "ElementCard",
		BackgroundColor3 = THEME.card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = parent,
	})
	corner(card, CARD_CORNER)
	new("UISizeConstraint", {
		MinSize = Vector2.new(0, ELEMENT_HEIGHT),
		Parent = card,
	})

	local body = new("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = card,
	})
	padding(body, cardPadY, cardPadY, 14, 14)
	new("UISizeConstraint", {
		MinSize = Vector2.new(0, innerMinHeight),
		Parent = body,
	})

	local left = new("Frame", {
		Name = "Left",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -textReserve, hasDesc and 0 or 1, 0),
		AutomaticSize = hasDesc and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
		Parent = body,
	})

	local titleLabel = new("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = THEME.text,
		Text = title or "",
		Parent = left,
	})

	local descLabel
	if hasDesc then
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
			Parent = left,
		})
		titleLabel.LayoutOrder = 1

		descLabel = new("TextLabel", {
			Name = "Desc",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextColor3 = THEME.muted,
			Text = desc,
			LayoutOrder = 2,
			Parent = left,
		})
	else
		titleLabel.AnchorPoint = Vector2.new(0, 0.5)
		titleLabel.Position = UDim2.new(0, 0, 0.5, 0)
	end

	local right = new("Frame", {
		Name = "Right",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, rightWidth, 0, innerMinHeight),
		Parent = body,
	})

	return card, titleLabel, descLabel, right
end

local function registerFlag(flagName, element)
	if type(flagName) == "string" and flagName ~= "" then
		SempatLibrary.Flags[flagName] = element
	end
end

local NotificationGui
local DropdownGui

local function ensureOverlayGuis(parent)
	if not NotificationGui then
		NotificationGui = new("ScreenGui", {
			Name = "SempatUI/Notifications",
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = 10000,
			Parent = parent,
		})
		protect(NotificationGui)
	end
	if not DropdownGui then
		DropdownGui = new("ScreenGui", {
			Name = "SempatUI/Dropdowns",
			ResetOnSpawn = false,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			DisplayOrder = 9999,
			Parent = parent,
		})
		protect(DropdownGui)
	end
end

function SempatLibrary:Notify(opts)
	opts = opts or {}
	ensureOverlayGuis(getGuiParent())

	local holder = NotificationGui:FindFirstChild("Holder")
	if not holder then
		holder = new("Frame", {
			Name = "Holder",
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -18, 1, -18),
			Size = UDim2.new(0, 320, 1, -36),
			Parent = NotificationGui,
		})
		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 8),
			Parent = holder,
		})
	end

	local toast = new("Frame", {
		BackgroundColor3 = THEME.card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = tick(),
		Parent = holder,
	})
	corner(toast, CARD_CORNER)
	stroke(toast, THEME.stroke, 0.25)
	padding(toast, 12, 12, 12, 12)

	local accentBar = new("Frame", {
		BackgroundColor3 = THEME.accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 1, 0),
		Parent = toast,
	})
	corner(accentBar, 2)

	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 0),
		Size = UDim2.new(1, -10, 0, 18),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = THEME.text,
		Text = opts.Title or "Notification",
		Parent = toast,
	})

	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 22),
		Size = UDim2.new(1, -10, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = THEME.muted,
		Text = opts.Content or "",
		Parent = toast,
	})

	task.delay(opts.Duration or 4, function()
		if toast.Parent then
			toast:Destroy()
		end
	end)

	return toast
end

local function createToggleSwitch(parent, initial)
	local track = new("TextButton", {
		Name = "ToggleTrack",
		BackgroundColor3 = THEME.toggleOff,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 44, 0, 24),
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Text = "",
		AutoButtonColor = false,
		Parent = parent,
	})
	corner(track, 12)

	local knob = new("Frame", {
		Name = "Knob",
		BackgroundColor3 = Color3.fromRGB(235, 235, 240),
		BorderSizePixel = 0,
		Size = UDim2.new(0, 18, 0, 18),
		Position = initial and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
		Parent = track,
	})
	corner(knob, 9)

	local function applyState(enabled, animate)
		track.BackgroundColor3 = enabled and THEME.toggleOn or THEME.toggleOff
		local target = enabled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
		if animate then
			TweenService:Create(knob, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = target,
			}):Play()
		else
			knob.Position = target
		end
	end

	return track, applyState
end

local function buildToggle(contentParent, props, scrollFrame)
	local card, _, _, right = createElementCard(contentParent, props.Name or props.Title, props.Content or props.Desc)
	local value = props.CurrentValue == true or props.Value == true
	local track, applyState = createToggleSwitch(right, value)
	applyState(value, false)

	local element = {
		CurrentValue = value,
		Value = value,
	}

	function element:Set(newValue, skipCallback)
		newValue = newValue == true
		if element.CurrentValue == newValue then
			return
		end
		element.CurrentValue = newValue
		element.Value = newValue
		applyState(newValue, false)
		if not skipCallback then
			safeCallback(props.Callback, newValue)
		end
	end

	function element:SetValue(newValue, ...)
		element:Set(newValue, ...)
	end

	track.MouseButton1Click:Connect(function()
		element:Set(not element.CurrentValue)
	end)

	registerAccentRefresher(function(color)
		if track.Parent then
			track.BackgroundColor3 = element.CurrentValue and color or THEME.toggleOff
		end
	end)

	if props.Flag and not props.Ext then
		registerFlag(props.Flag, element)
	end

	scheduleCanvasUpdate(scrollFrame)
	return element
end

local function buildSlider(contentParent, props, scrollFrame)
	local range = props.Range or {}
	local minValue = range[1] or (props.Value and props.Value.Min) or 0
	local maxValue = range[2] or (props.Value and props.Value.Max) or 100
	local step = props.Increment or props.Step or 1
	local current = props.CurrentValue
	if current == nil and props.Value then
		current = props.Value.Default
	end
	if current == nil then
		current = minValue
	end
	current = math.clamp(current, minValue, maxValue)

	local card, _, _, right = createElementCard(contentParent, props.Name or props.Title, props.Content or props.Desc, 180)

	local valueLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 2),
		Size = UDim2.new(0, 48, 0, 16),
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Right,
		TextColor3 = THEME.accent,
		Text = tostring(current) .. (props.Suffix and (" " .. props.Suffix) or ""),
		Parent = right,
	})

	local track = new("Frame", {
		Name = "Track",
		BackgroundColor3 = THEME.sliderTrack,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 1, -16),
		Size = UDim2.new(1, 0, 0, 6),
		Parent = right,
	})
	corner(track, 3)

	local fill = new("Frame", {
		Name = "Fill",
		BackgroundColor3 = THEME.sliderFill,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
		Parent = track,
	})
	corner(fill, 3)

	local hit = new("TextButton", {
		Name = "Hit",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 12),
		Position = UDim2.new(0, 0, 0, -6),
		Text = "",
		ZIndex = 2,
		Parent = track,
	})

	local element = {
		CurrentValue = current,
	}

	local dragging = false

	local function ratioFor(value)
		if maxValue == minValue then
			return 0
		end
		return (value - minValue) / (maxValue - minValue)
	end

	local function displayValue(value)
		local text = tostring(value)
		if props.Suffix then
			text = text .. " " .. props.Suffix
		end
		valueLabel.Text = text
	end

	local function applyVisual(value, fireCallback)
		value = math.clamp(value, minValue, maxValue)
		if step > 0 then
			value = math.floor(value / step + 0.5) * step
			value = math.clamp(value, minValue, maxValue)
		end
		if element.CurrentValue == value and not fireCallback then
			fill.Size = UDim2.new(math.clamp(ratioFor(value), 0, 1), 0, 1, 0)
			displayValue(value)
			return
		end
		element.CurrentValue = value
		fill.Size = UDim2.new(math.clamp(ratioFor(value), 0, 1), 0, 1, 0)
		displayValue(value)
		if fireCallback then
			safeCallback(props.Callback, value)
		end
	end

	local function valueFromX(x)
		local rel = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		return minValue + rel * (maxValue - minValue)
	end

	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			applyVisual(valueFromX(input.Position.X), true)
		end
	end)

	hit.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			applyVisual(valueFromX(input.Position.X), true)
		end
	end)

	applyVisual(current, false)

	function element:Set(newValue)
		applyVisual(tonumber(newValue) or minValue, true)
	end

	function element:SetValue(newValue)
		element:Set(newValue)
	end

	registerAccentRefresher(function(color)
		if fill.Parent then
			fill.BackgroundColor3 = color
		end
		if valueLabel.Parent then
			valueLabel.TextColor3 = color
		end
	end)

	function element:SetVisible(visible)
		card.Visible = visible == true
		scheduleCanvasUpdate(scrollFrame)
	end

	if props.Flag and not props.Ext then
		registerFlag(props.Flag, element)
	end

	scheduleCanvasUpdate(scrollFrame)
	return element
end

local dropdownOpening = false

local function closeActiveDropdown()
	if activeDropdown then
		activeDropdown:Destroy()
		activeDropdown = nil
	end
end

local function createDropdownOptionButton()
	local item = new("TextButton", {
		Name = "Option",
		BackgroundTransparency = 1,
		BackgroundColor3 = THEME.dropdownItemHover,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, DROPDOWN_ITEM_HEIGHT),
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = THEME.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		AutoButtonColor = false,
		Text = "",
	})
	corner(item, 8)
	padding(item, 0, 0, 12, 12)

	item.MouseEnter:Connect(function()
		item.BackgroundTransparency = 0
	end)
	item.MouseLeave:Connect(function()
		if item:GetAttribute("OptionSelected") ~= true then
			item.BackgroundTransparency = 1
		end
	end)

	return item
end

local function isDropdownMulti(props)
	return props.Multi == true or props.MultipleOptions == true
end

local function copyOptionList(list)
	local copy = {}
	for _, value in ipairs(list or {}) do
		table.insert(copy, value)
	end
	return copy
end

local function normalizeMultiSelection(raw, optionList)
	local selected = {}
	local seen = {}
	local function addValue(value)
		if value == nil or seen[value] then
			return
		end
		seen[value] = true
		table.insert(selected, value)
	end

	if type(raw) == "table" then
		for _, value in ipairs(raw) do
			addValue(value)
		end
	elseif raw ~= nil then
		addValue(raw)
	end

	if type(optionList) == "table" and #optionList > 0 then
		local filtered = {}
		for _, value in ipairs(selected) do
			if table.find(optionList, value) then
				table.insert(filtered, value)
			end
		end
		return filtered
	end

	return selected
end

local function formatMultiDropdownText(selectedList)
	if #selectedList == 0 then
		return "None"
	end
	if #selectedList == 1 then
		return tostring(selectedList[1])
	end
	return "Various"
end

local function buildDropdown(contentParent, props, scrollFrame)
	local options = props.Options or props.Values or {}
	local isMulti = isDropdownMulti(props)
	local selectedList = {}
	local selected

	if isMulti then
		local rawCurrent = props.CurrentOption
		if type(rawCurrent) == "string" then
			rawCurrent = { rawCurrent }
		end
		if type(rawCurrent) == "table" then
			selectedList = normalizeMultiSelection(rawCurrent, options)
		elseif props.Value ~= nil then
			selectedList = normalizeMultiSelection(props.Value, options)
		end
		selected = selectedList
	else
		selected = props.CurrentOption
		if type(selected) == "table" then
			selected = selected[1]
		end
		if selected == nil then
			selected = props.Value
		end
		if type(selected) == "number" and options[selected] then
			selected = options[selected]
		end
		if selected == nil and #options > 0 then
			selected = options[1]
		end
	end

	local card, _, _, right = createElementCard(contentParent, props.Name or props.Title, props.Content or props.Desc)

	local button = new("TextButton", {
		Name = "DropdownButton",
		BackgroundColor3 = THEME.dropdownSearch,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 32),
		Font = Enum.Font.GothamMedium,
		TextSize = 13,
		TextColor3 = THEME.text,
		TextXAlignment = Enum.TextXAlignment.Left,
		Text = "  "
			.. (isMulti and formatMultiDropdownText(selectedList) or tostring(selected or "Select")),
		AutoButtonColor = false,
		Parent = right,
	})
	corner(button, 8)
	stroke(button, THEME.stroke, 0.45)

	new("TextLabel", {
		Name = "Chevron",
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -10, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextColor3 = THEME.muted,
		Text = CHEVRON_MARK,
		Rotation = CHEVRON_DOWN_ROTATION,
		Parent = button,
	})

	local element = {
		Value = isMulti and copyOptionList(selectedList) or selected,
		Values = options,
	}

	local optionPool = {}
	local menuList
	local menuScroll
	local menuSearchBox
	local menuWidth = math.max(200, 220)

	local function updateButtonText()
		if isMulti then
			button.Text = "  " .. formatMultiDropdownText(selectedList)
		else
			button.Text = "  " .. tostring(element.Value or "Select")
		end
	end

	local function syncElementValue()
		if isMulti then
			element.Value = copyOptionList(selectedList)
		else
			element.Value = selected
		end
	end

	local function fireSelectionCallback()
		if isMulti then
			safeCallback(props.Callback, copyOptionList(selectedList))
		else
			safeCallback(props.Callback, element.Value)
		end
	end

	local function applyOptionVisual(item, option)
		if isMulti then
			local picked = table.find(selectedList, option) ~= nil
			item:SetAttribute("OptionSelected", picked)
			item.BackgroundTransparency = picked and 0 or 1
			item.TextColor3 = picked and appliedAccentColor or THEME.text
			item.Text = (picked and "✓ " or "  ") .. tostring(option)
			return
		end
		item:SetAttribute("OptionSelected", false)
		item.BackgroundTransparency = 1
		item.TextColor3 = THEME.text
		item.Text = "  " .. tostring(option)
	end

	local function setSelected(value, fireCallback)
		if isMulti then
			if type(value) == "table" then
				selectedList = normalizeMultiSelection(value, element.Values)
			elseif value == nil then
				table.clear(selectedList)
			else
				selectedList = { value }
			end
			syncElementValue()
			updateButtonText()
			if fireCallback then
				fireSelectionCallback()
			end
			return
		end

		selected = value
		syncElementValue()
		updateButtonText()
		if fireCallback then
			fireSelectionCallback()
		end
	end

	local function toggleMultiOption(option)
		local index = table.find(selectedList, option)
		if index then
			table.remove(selectedList, index)
		else
			table.insert(selectedList, option)
		end
		syncElementValue()
		updateButtonText()
		fireSelectionCallback()
	end

	local function populateOptions(filterText)
		if not menuList then
			return
		end

		local filter = string.lower(filterText or "")
		local order = 0

		for _, option in ipairs(element.Values) do
			local text = tostring(option)
			if filter == "" or string.find(string.lower(text), filter, 1, true) then
				order += 1
				local item = optionPool[order]
				if not item then
					item = createDropdownOptionButton()
					item.Parent = menuList
					item.Activated:Connect(function()
						local value = item:GetAttribute("OptionValue")
						if value == nil then
							return
						end
						if isMulti then
							toggleMultiOption(value)
							for _, pooled in ipairs(optionPool) do
								if pooled.Visible then
									local pooledValue = pooled:GetAttribute("OptionValue")
									if pooledValue ~= nil then
										applyOptionVisual(pooled, pooledValue)
									end
								end
							end
						else
							setSelected(value, true)
							closeActiveDropdown()
						end
					end)
					optionPool[order] = item
				end
				item:SetAttribute("OptionValue", option)
				applyOptionVisual(item, option)
				item.LayoutOrder = order
				item.Visible = true
			end
		end

		for index = order + 1, #optionPool do
			local pooled = optionPool[index]
			if pooled then
				pooled.Visible = false
			end
		end

		if menuScroll then
			task.defer(function()
				if menuList and menuList.Parent then
					local layout = menuList:FindFirstChildOfClass("UIListLayout")
					if layout then
						local contentHeight = layout.AbsoluteContentSize.Y
						menuScroll.CanvasSize = UDim2.new(0, 0, 0, contentHeight)
						menuScroll.Size = UDim2.new(
							1,
							0,
							0,
							math.min(contentHeight, DROPDOWN_MAX_HEIGHT)
						)
					end
				end
			end)
		end
	end

	local function renderMenu(filterText)
		closeActiveDropdown()
		table.clear(optionPool)
		ensureOverlayGuis(getGuiParent())

		menuWidth = math.max(button.AbsoluteSize.X, 220)
		local menuHeight = DROPDOWN_SEARCH_HEIGHT + 8

		local overlay = new("Frame", {
			Name = "DropdownOverlay",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			ZIndex = 1,
			Parent = DropdownGui,
		})
		activeDropdown = overlay

		local backdrop = new("TextButton", {
			Name = "Backdrop",
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Text = "",
			AutoButtonColor = false,
			ZIndex = 1,
			Parent = overlay,
		})
		backdrop.Activated:Connect(closeActiveDropdown)

		local menu = new("Frame", {
			Name = "DropdownMenu",
			BackgroundColor3 = THEME.dropdownMenu,
			BorderSizePixel = 0,
			Position = UDim2.fromOffset(
				button.AbsolutePosition.X,
				button.AbsolutePosition.Y + button.AbsoluteSize.Y + 6
			),
			Size = UDim2.new(0, menuWidth, 0, menuHeight),
			ClipsDescendants = true,
			ZIndex = 2,
			Parent = overlay,
		})
		corner(menu, DROPDOWN_MENU_CORNER)
		stroke(menu, THEME.stroke, 0.3)
		padding(menu, 8, 8, 8, 8)

		local menuLayout = new("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
			Parent = menu,
		})

		local searchEnabled = props.Search == true or props.SearchBarEnabled == true
		if searchEnabled then
			menuSearchBox = new("TextBox", {
				Name = "SearchBox",
				BackgroundColor3 = THEME.dropdownSearch,
				BorderSizePixel = 0,
				Size = UDim2.new(1, 0, 0, DROPDOWN_SEARCH_HEIGHT),
				Font = Enum.Font.Gotham,
				TextSize = 13,
				PlaceholderText = "Search...",
				PlaceholderColor3 = THEME.muted,
				TextColor3 = THEME.text,
				TextXAlignment = Enum.TextXAlignment.Left,
				Text = filterText or "",
				ClearTextOnFocus = false,
				LayoutOrder = 1,
				Parent = menu,
			})
			corner(menuSearchBox, 8)
			stroke(menuSearchBox, THEME.stroke, 0.55)
			padding(menuSearchBox, 0, 0, 12, 12)
		end

		menuScroll = new("ScrollingFrame", {
			Name = "OptionsScroll",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 0),
			CanvasSize = UDim2.new(),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = THEME.accent,
			AutomaticCanvasSize = Enum.AutomaticSize.None,
			LayoutOrder = 2,
			Parent = menu,
		})

		menuList = new("Frame", {
			Name = "OptionsList",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = menuScroll,
		})

		new("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 2),
			Parent = menuList,
		})

		populateOptions(filterText)

		local function syncMenuSize()
			local pad = menu:FindFirstChildOfClass("UIPadding")
			local padY = 16
			if pad then
				padY = pad.PaddingTop.Offset + pad.PaddingBottom.Offset
			end
			local searchH = searchEnabled and (DROPDOWN_SEARCH_HEIGHT + 6) or 0
			local listH = menuScroll.Size.Y.Offset
			menu.Size = UDim2.new(0, menuWidth, 0, padY + searchH + listH)
		end

		menuLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncMenuSize)
		menuScroll:GetPropertyChangedSignal("Size"):Connect(syncMenuSize)
		syncMenuSize()

		if menuSearchBox then
			menuSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
				populateOptions(menuSearchBox.Text)
			end)
			task.defer(function()
				if menuSearchBox and menuSearchBox.Parent then
					menuSearchBox:CaptureFocus()
				end
			end)
		end
	end

	button.Activated:Connect(function()
		dropdownOpening = true
		task.defer(function()
			renderMenu()
			task.defer(function()
				dropdownOpening = false
			end)
		end)
	end)

	function element:Set(value)
		if isMulti then
			if type(value) == "table" then
				setSelected(value, false)
			elseif value == nil then
				setSelected({}, false)
			else
				setSelected({ value }, false)
			end
			return
		end

		local pick = value
		if type(value) == "table" then
			pick = value[1]
		end
		setSelected(pick, false)
	end

	function element:SetValue(value)
		element:Set(value)
	end

	function element:Select(value)
		if isMulti then
			if type(value) == "table" then
				setSelected(value, true)
			elseif value == nil then
				setSelected({}, true)
			else
				local nextSelection = copyOptionList(selectedList)
				if not table.find(nextSelection, value) then
					table.insert(nextSelection, value)
				end
				setSelected(nextSelection, true)
			end
			return
		end
		setSelected(value, true)
	end

	function element:Refresh(values)
		element.Values = values or {}
		options = element.Values
		if isMulti then
			for index = #selectedList, 1, -1 do
				if not table.find(element.Values, selectedList[index]) then
					table.remove(selectedList, index)
				end
			end
			syncElementValue()
			updateButtonText()
			return
		end

		if element.Value ~= nil then
			local found = false
			for _, option in ipairs(element.Values) do
				if option == element.Value then
					found = true
					break
				end
			end
			if not found then
				setSelected(element.Values[1], false)
			end
		end
	end

	if props.Flag and not props.Ext then
		registerFlag(props.Flag, element)
	end

	registerAccentRefresher(function(color)
		for _, pooled in ipairs(optionPool) do
			if pooled.Visible and pooled.Parent then
				local pooledValue = pooled:GetAttribute("OptionValue")
				if pooledValue ~= nil then
					applyOptionVisual(pooled, pooledValue)
				end
			end
		end
	end)

	scheduleCanvasUpdate(scrollFrame)
	return element
end

local function buildButton(contentParent, props, scrollFrame)
	local title = props.Name or props.Title or "Button"
	local bgColor = resolveElementColor(props.Color) or appliedAccentColor
	local hoverColor = resolveElementColor(props.HoverColor) or darkenColor(bgColor, 0.88)
	local textColor = resolveElementColor(props.TextColor) or getButtonTextColor()

	local button = new("TextButton", {
		Name = "Button",
		BackgroundColor3 = bgColor,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 40),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = textColor,
		Text = title,
		AutoButtonColor = false,
		Parent = contentParent,
	})
	corner(button, CARD_CORNER)

	local element = {
		_color = bgColor,
		_hoverColor = hoverColor,
	}

	local function applyButtonColor(color)
		element._color = color
		element._hoverColor = resolveElementColor(props.HoverColor) or darkenColor(color, 0.88)
		button.BackgroundColor3 = color
		button.TextColor3 = resolveElementColor(props.TextColor) or getButtonTextColor()
	end

	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = element._hoverColor
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = element._color
	end)

	button.Activated:Connect(function()
		safeCallback(props.Callback)
	end)

	function element:Set(data)
		if type(data) ~= "table" then
			return
		end
		if data.Name or data.Title then
			button.Text = data.Name or data.Title
		end
		if data.Color ~= nil then
			applyButtonColor(resolveElementColor(data.Color) or appliedAccentColor)
		end
	end

	local usesThemeAccent = props.Color == nil
		or (type(props.Color) == "string" and string.lower(props.Color) == "accent")
	if usesThemeAccent then
		registerAccentRefresher(function(color)
			if button.Parent then
				applyButtonColor(color)
			end
		end)
	end

	scheduleCanvasUpdate(scrollFrame)
	return element
end

local function buildInput(contentParent, props, scrollFrame)
	local card, _, _, right = createElementCard(contentParent, props.Name or props.Title, props.Content or props.Desc)

	local box = new("TextBox", {
		Name = "Input",
		BackgroundColor3 = THEME.sidebar,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 30),
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextColor3 = THEME.text,
		PlaceholderColor3 = THEME.muted,
		PlaceholderText = props.PlaceholderText or props.Placeholder or "",
		Text = props.CurrentValue or props.Value or "",
		ClearTextOnFocus = false,
		Parent = right,
	})
	corner(box, 6)
	stroke(box, THEME.stroke, 0.4)

	local element = {
		CurrentValue = box.Text,
		Value = box.Text,
	}

	box:GetPropertyChangedSignal("Text"):Connect(function()
		element.CurrentValue = box.Text
		element.Value = box.Text
		safeCallback(props.Callback, box.Text)
	end)

	function element:GetValue()
		return box.Text
	end

	function element:Set(text)
		box.Text = tostring(text or "")
		element.CurrentValue = box.Text
		element.Value = box.Text
	end

	function element:SetValue(text)
		element:Set(text)
	end

	if props.Flag and not props.Ext then
		registerFlag(props.Flag, element)
	end

	scheduleCanvasUpdate(scrollFrame)
	return element
end

local function buildParagraph(contentParent, props, scrollFrame)
	local frame = new("Frame", {
		Name = "Paragraph",
		BackgroundColor3 = THEME.card,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = contentParent,
	})
	corner(frame, CARD_CORNER)
	padding(frame, 12, 12, 12, 12)

	local titleLabel = new("TextLabel", {
		Name = "Title",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 18),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = THEME.text,
		Text = props.Title or props.Name or "Paragraph",
		Parent = frame,
	})

	local contentLabel = new("TextLabel", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 22),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Enum.Font.Gotham,
		TextSize = 13,
		TextWrapped = true,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextColor3 = THEME.muted,
		Text = props.Content or props.Desc or "",
		Parent = frame,
	})

	local element = {}

	function element:Set(data)
		if type(data) ~= "table" then
			return
		end
		if data.Title ~= nil then
			titleLabel.Text = data.Title
		end
		if data.Content ~= nil then
			contentLabel.Text = data.Content
		elseif data.Desc ~= nil then
			contentLabel.Text = data.Desc
		end
		scheduleCanvasUpdate(scrollFrame)
	end

	function element:SetTitle(title)
		titleLabel.Text = title or ""
		scheduleCanvasUpdate(scrollFrame)
	end

	function element:SetDesc(desc)
		contentLabel.Text = desc or ""
		scheduleCanvasUpdate(scrollFrame)
	end

	function element:SetValue(data)
		element:Set(data)
	end

	scheduleCanvasUpdate(scrollFrame)
	return element
end

local function createSection(contentParent, title, scrollFrame)
	local section = new("Frame", {
		Name = "Section_" .. (title or "Section"),
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Parent = contentParent,
	})

	local layout = new("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = section,
	})

	local header = new("TextButton", {
		Name = "Header",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, SECTION_HEADER_HEIGHT),
		Font = Enum.Font.GothamBold,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = THEME.muted,
		Text = string.upper(title or "Section"),
		AutoButtonColor = false,
		LayoutOrder = 1,
		Parent = section,
	})

	local accent = new("Frame", {
		BackgroundColor3 = THEME.accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 0, 14),
		Position = UDim2.new(0, 0, 0.5, -7),
		Parent = header,
	})
	corner(accent, 2)
	header.Text = "   " .. string.upper(title or "Section")

	registerAccentRefresher(function(color)
		if accent.Parent then
			accent.BackgroundColor3 = color
		end
	end)

	local chevron = new("TextLabel", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		Font = Enum.Font.GothamBold,
		TextSize = 14,
		TextColor3 = THEME.muted,
		Text = CHEVRON_MARK,
		Rotation = CHEVRON_DOWN_ROTATION,
		Parent = header,
	})

	local body = new("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Visible = true,
		LayoutOrder = 2,
		Parent = section,
	})

	local function setSectionExpanded(isExpanded)
		body.Visible = isExpanded
		chevron.Rotation = isExpanded and CHEVRON_DOWN_ROTATION or CHEVRON_RIGHT_ROTATION
		scheduleCanvasUpdate(scrollFrame)
	end

	local bodyLayout = new("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		Parent = body,
	})

	local expanded = true
	header.MouseButton1Click:Connect(function()
		expanded = not expanded
		setSectionExpanded(expanded)
	end)
	setSectionExpanded(expanded)

	local sectionApi = {
		_body = body,
		_scroll = scrollFrame,
	}

	function sectionApi:CreateToggle(props)
		return buildToggle(body, props, scrollFrame)
	end
	sectionApi.Toggle = sectionApi.CreateToggle

	function sectionApi:CreateSlider(props)
		return buildSlider(body, props, scrollFrame)
	end
	sectionApi.Slider = sectionApi.CreateSlider

	function sectionApi:CreateDropdown(props)
		return buildDropdown(body, props, scrollFrame)
	end
	sectionApi.Dropdown = sectionApi.CreateDropdown

	function sectionApi:CreateButton(props)
		return buildButton(body, props, scrollFrame)
	end
	sectionApi.Button = sectionApi.CreateButton

	function sectionApi:CreateInput(props)
		return buildInput(body, props, scrollFrame)
	end
	sectionApi.Input = sectionApi.CreateInput

	function sectionApi:CreateParagraph(props)
		return buildParagraph(body, props, scrollFrame)
	end
	sectionApi.Paragraph = sectionApi.CreateParagraph

	bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scheduleCanvasUpdate(scrollFrame)
	end)

	scheduleCanvasUpdate(scrollFrame)
	return sectionApi
end

local function createTabApi(tabFrame, scrollFrame, contentTitle)
	local contentParent = scrollFrame
	local currentSectionBody = scrollFrame

	local function targetParent()
		return currentSectionBody
	end

	local tab = {
		_frame = tabFrame,
		_scroll = scrollFrame,
	}

	function tab:CreateSection(title)
		local section = createSection(scrollFrame, title, scrollFrame)
		currentSectionBody = section._body
		return section
	end

	function tab:Section(props)
		props = props or {}
		return tab:CreateSection(props.Title or props.Name or "Section")
	end

	function tab:CreateToggle(props)
		return buildToggle(targetParent(), props, scrollFrame)
	end
	tab.Toggle = tab.CreateToggle

	function tab:CreateSlider(props)
		return buildSlider(targetParent(), props, scrollFrame)
	end
	tab.Slider = tab.CreateSlider

	function tab:CreateDropdown(props)
		return buildDropdown(targetParent(), props, scrollFrame)
	end
	tab.Dropdown = tab.CreateDropdown

	function tab:CreateButton(props)
		return buildButton(targetParent(), props, scrollFrame)
	end
	tab.Button = tab.CreateButton

	function tab:CreateInput(props)
		return buildInput(targetParent(), props, scrollFrame)
	end
	tab.Input = tab.CreateInput

	function tab:CreateParagraph(props)
		return buildParagraph(targetParent(), props, scrollFrame)
	end
	tab.Paragraph = tab.CreateParagraph

	function tab:CreateImage(props)
		return buildParagraph(targetParent(), {
			Title = props.Title or props.Name or "Image",
			Content = props.Image or "",
		}, scrollFrame)
	end
	tab.Image = tab.CreateImage

	if contentTitle then
		tab._titleLabel = contentTitle
	end

	return tab
end

local function createSidebarButton(sidebarList, windowState, tabData, accentIndicators)
	local button = new("TextButton", {
		Name = "Tab_" .. tabData.id,
		BackgroundColor3 = THEME.content,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 36),
		Font = Enum.Font.GothamMedium,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = THEME.muted,
		Text = "   " .. tabData.title,
		AutoButtonColor = false,
		LayoutOrder = tabData.order,
		Parent = sidebarList,
	})
	corner(button, 8)

	local indicator = new("Frame", {
		Name = "Indicator",
		BackgroundColor3 = THEME.accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 3, 0, 18),
		Position = UDim2.new(0, 4, 0.5, -9),
		Visible = false,
		Parent = button,
	})
	corner(indicator, 2)

	if type(accentIndicators) == "table" then
		table.insert(accentIndicators, indicator)
	end

	local function setSelected(selected)
		button.BackgroundColor3 = selected and THEME.card or THEME.content
		button.TextColor3 = selected and THEME.text or THEME.muted
		indicator.Visible = selected
		tabData.frame.Visible = selected
	end

	button.MouseButton1Click:Connect(function()
		windowState.selectTab(tabData.id)
	end)

	return setSelected
end

local function createUiSettingsPage(pagesContainer, config)
	local page = new("Frame", {
		Name = "UiSettings",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
		Parent = pagesContainer,
	})

	local scroll = new("ScrollingFrame", {
		Name = "Scroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -10, 1, 0),
		Position = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = appliedAccentColor,
		CanvasSize = UDim2.new(),
		Parent = page,
	})
	if type(config.accentScrollbars) == "table" then
		table.insert(config.accentScrollbars, scroll)
	end
	padding(scroll, 0, 16, 20, 16)

	local list = new("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 10),
		Parent = scroll,
	})

	list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		scheduleCanvasUpdate(scroll)
	end)

	local presetNames = {}
	for _, preset in ipairs(ACCENT_PRESETS) do
		table.insert(presetNames, preset.name)
	end

	local appearance = createSection(scroll, "Appearance", scroll)
	local transparencySlider = appearance:CreateSlider({
		Name = "Window Transparency",
		Content = "How see-through the window panels are",
		Range = { 0, 95 },
		Increment = 1,
		Suffix = "%",
		CurrentValue = config.getTransparencyPercent(),
		Callback = function(value)
			config.setTransparencyPercent(value)
		end,
	})
	local accentDropdown = appearance:CreateDropdown({
		Name = "Accent Color",
		Content = "Theme highlight color for buttons and accents",
		Options = presetNames,
		CurrentOption = { colorToPresetName(config.getAccentColor()) },
		Callback = function(value)
			local picked = type(value) == "table" and value[1] or value
			for _, preset in ipairs(ACCENT_PRESETS) do
				if preset.name == picked then
					config.setAccentColor(preset.color)
					break
				end
			end
		end,
	})
	local scaleSlider = appearance:CreateSlider({
		Name = "UI Scale",
		Content = "Overall menu size as a percentage",
		Range = { MIN_WINDOW_SCALE, MAX_WINDOW_SCALE },
		Increment = 5,
		Suffix = "%",
		CurrentValue = config.getWindowScale(),
		Callback = function(value)
			config.setWindowScale(value)
		end,
	})
	local titleSizeSlider = appearance:CreateSlider({
		Name = "Content Title Size",
		Content = "Tab title text size at the top of the page",
		Range = { MIN_CONTENT_TITLE_SIZE, MAX_CONTENT_TITLE_SIZE },
		Increment = 1,
		Suffix = "px",
		CurrentValue = config.getContentTitleSize(),
		Callback = function(value)
			config.setContentTitleSize(value)
		end,
	})

	local controls = createSection(scroll, "Controls", scroll)
	local keybindInput
	if not config.isMobile then
		keybindInput = controls:CreateInput({
			Name = "Toggle UI Key",
			Content = "Keyboard key to show or hide the menu",
			PlaceholderText = "e.g. K",
			CurrentValue = config.getToggleKeyName(),
			Callback = function(value)
				config.setToggleKeyName(value)
			end,
		})
	end
	local mobileFabToggle
	if config.isMobile then
		mobileFabToggle = controls:CreateToggle({
			Name = "Show Mobile Button",
			Content = "Floating button to reopen the menu when hidden",
			CurrentValue = config.getShowMobileFab(),
			Callback = function(value)
				config.setShowMobileFab(value)
			end,
		})
	end

	local windowSection = createSection(scroll, "Window", scroll)
	local rememberPositionToggle = windowSection:CreateToggle({
		Name = "Remember Position",
		Content = "Save menu position between sessions",
		CurrentValue = config.getRememberPosition(),
		Callback = function(value)
			config.setRememberPosition(value)
		end,
	})
	windowSection:CreateButton({
		Name = "Reset Window Position",
		Callback = function()
			config.resetWindowPosition()
			SempatLibrary:Notify({
				Title = "UI Configuration",
				Content = "Window position reset to center.",
			})
		end,
	})

	local function refreshControls()
		transparencySlider:Set(config.getTransparencyPercent())
		accentDropdown:Set(colorToPresetName(config.getAccentColor()))
		scaleSlider:Set(config.getWindowScale())
		titleSizeSlider:Set(config.getContentTitleSize())
		if keybindInput then
			keybindInput:Set(config.getToggleKeyName())
		end
		if mobileFabToggle then
			mobileFabToggle:Set(config.getShowMobileFab())
		end
		rememberPositionToggle:Set(config.getRememberPosition())
	end

	local actions = createSection(scroll, "Actions", scroll)
	actions:CreateButton({
		Name = "Reset to Defaults",
		Callback = function()
			config.resetToDefaults()
			refreshControls()
			SempatLibrary:Notify({
				Title = "UI Configuration",
				Content = "Settings restored to defaults.",
			})
		end,
	})
	actions:CreateButton({
		Name = "Clear Saved UI Settings",
		Callback = function()
			config.clearSavedUiSettings()
			refreshControls()
			SempatLibrary:Notify({
				Title = "UI Configuration",
				Content = "Saved UI settings file removed.",
			})
		end,
	})

	buildParagraph(scroll, {
		Title = "About",
		Content = config.getAboutText(),
	}, scroll)

	scheduleCanvasUpdate(scroll)

	local isOpen = false

	local function closePage()
		if not isOpen then
			return
		end
		isOpen = false
		page.Visible = false
		closeActiveDropdown()
	end

	local function openPage()
		closeActiveDropdown()
		refreshControls()
		isOpen = true
		page.Visible = true
	end

	return {
		Open = openPage,
		Close = closePage,
		IsOpen = function()
			return isOpen
		end,
		Refresh = refreshControls,
		page = page,
	}
end

function SempatLibrary:CreateWindow(settings)
	settings = settings or {}
	local parent = settings.Parent or getGuiParent()
	ensureOverlayGuis(parent)

	local title = settings.Name or settings.Title or "Sempat UI"
	local subtitle = settings.LoadingSubtitle or settings.SubTitle or "SempatUI • Dev Version"
	local folderName = settings.Folder
		or (settings.ConfigurationSaving and settings.ConfigurationSaving.FolderName)
		or "SempatUI"
	local isMobile = isMobileDevice()

	if typeof(settings.AccentColor) == "Color3" then
		appliedAccentColor = settings.AccentColor
	elseif type(settings.Accent) == "string" then
		local accentColor = resolveElementColor(settings.Accent)
		if accentColor then
			appliedAccentColor = accentColor
		end
	else
		appliedAccentColor = THEME.accent
	end
	applyAccentTheme(appliedAccentColor)

	local defaultAccentColor = appliedAccentColor

	local screenGui = new("ScreenGui", {
		Name = "SempatUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 500,
		Parent = parent,
	})
	protect(screenGui)

	local root = new("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0, WINDOW_SIZE.X, 0, WINDOW_SIZE.Y),
		BackgroundColor3 = THEME.window,
		BorderSizePixel = 0,
		Parent = screenGui,
	})
	corner(root, CORNER)
	local rootStroke = stroke(root, THEME.stroke, 0.25)

	local headerBar = new("Frame", {
		Name = "Header",
		BackgroundColor3 = THEME.sidebar,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, HEADER_HEIGHT),
		Parent = root,
	})
	padding(headerBar, 12, 12, 16, 16)

	local headerBrand = new("Frame", {
		Name = "Brand",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -HEADER_CONTROLS_WIDTH, 1, 0),
		Parent = headerBar,
	})

	local accentTargets = {}
	local accentIndicators = {}
	local accentScrollbars = {}

	local logo = new("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(0, 28, 0, 28),
		Font = Enum.Font.GothamBlack,
		TextSize = 22,
		TextColor3 = appliedAccentColor,
		Text = "L",
		Parent = headerBrand,
	})
	table.insert(accentTargets, logo)

	local titleLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 34, 0, 2),
		Size = UDim2.new(1, -34, 0, 18),
		Font = Enum.Font.GothamBold,
		TextSize = 15,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = THEME.text,
		Text = title,
		Parent = headerBrand,
	})

	local subtitleLabel = new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 34, 0, 22),
		Size = UDim2.new(1, -34, 0, 14),
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = appliedAccentColor,
		Text = subtitle,
		Active = false,
		Parent = headerBrand,
	})
	table.insert(accentTargets, subtitleLabel)

	local headerDragHandle = new("Frame", {
		Name = "DragHandle",
		BackgroundTransparency = 1,
		Active = true,
		Size = UDim2.new(1, -HEADER_CONTROLS_WIDTH, 1, 0),
		ZIndex = 2,
		Parent = headerBar,
	})

	local function windowButton(buttonName, text, xOffset, onClick)
		local btn = new("TextButton", {
			Name = buttonName,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, xOffset, 0.5, 0),
			Size = UDim2.new(0, 32, 0, 32),
			Font = Enum.Font.GothamBold,
			TextSize = 18,
			TextColor3 = THEME.muted,
			Text = text,
			AutoButtonColor = false,
			ZIndex = 5,
			Parent = headerBar,
		})
		btn.Activated:Connect(onClick)
		return btn
	end

	local function windowIconButton(buttonName, text, xOffset, onClick)
		local highlight = new("Frame", {
			Name = "Highlight",
			BackgroundColor3 = THEME.card,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, xOffset, 0.5, 0),
			Size = UDim2.new(0, 32, 0, 32),
			Visible = false,
			ZIndex = 4,
			Parent = headerBar,
		})
		corner(highlight, 8)

		local btn = new("TextButton", {
			Name = buttonName,
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, xOffset, 0.5, 0),
			Size = UDim2.new(0, 32, 0, 32),
			Font = Enum.Font.GothamBold,
			TextSize = 16,
			TextColor3 = THEME.muted,
			Text = text,
			AutoButtonColor = false,
			ZIndex = 5,
			Parent = headerBar,
		})

		local active = false

		local function refreshIconColor()
			btn.TextColor3 = active and appliedAccentColor or THEME.muted
		end

		local function setActive(isActive)
			active = isActive == true
			highlight.Visible = active
			refreshIconColor()
		end

		btn.MouseEnter:Connect(function()
			if not active then
				btn.TextColor3 = THEME.text
			end
		end)
		btn.MouseLeave:Connect(function()
			refreshIconColor()
		end)
		btn.Activated:Connect(onClick)

		return {
			button = btn,
			SetActive = setActive,
			IsActive = function()
				return active
			end,
			RefreshAccent = refreshIconColor,
		}
	end

	local sidebar = new("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = THEME.content,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, HEADER_HEIGHT),
		Size = UDim2.new(0, SIDEBAR_WIDTH, 1, -HEADER_HEIGHT),
		Parent = root,
	})

	local sidebarCover = new("Frame", {
		BackgroundColor3 = THEME.content,
		BorderSizePixel = 0,
		Position = UDim2.new(1, -CORNER, 0, 0),
		Size = UDim2.new(0, CORNER, 1, 0),
		Parent = sidebar,
	})

	padding(sidebar, 16, 0, 0, 0)

	local tabList = new("Frame", {
		Name = "TabList",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, -PROFILE_CARD_HEIGHT),
		Parent = sidebar,
	})
	padding(tabList, 0, 10, 10, 10)

	new("UIListLayout", {
		FillDirection = Enum.FillDirection.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
		Parent = tabList,
	})

	local profileCard = new("Frame", {
		Name = "Profile",
		BackgroundColor3 = THEME.card,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, PROFILE_CARD_HEIGHT),
		Parent = sidebar,
	})
	corner(profileCard, 10)

	local profileTextLeft = PROFILE_PAD_X + PROFILE_AVATAR_SIZE + 8
	local profileTextRight = PROFILE_PAD_X

	local avatar = new("ImageLabel", {
		BackgroundColor3 = THEME.content,
		BorderSizePixel = 0,
		Position = UDim2.new(0, PROFILE_PAD_X, 0.5, -PROFILE_AVATAR_SIZE / 2),
		Size = UDim2.new(0, PROFILE_AVATAR_SIZE, 0, PROFILE_AVATAR_SIZE),
		Parent = profileCard,
	})
	corner(avatar, PROFILE_AVATAR_SIZE / 2)

	local displayName = "Anonymous"
	local userName = "@anonymous"
	if LocalPlayer then
		displayName = LocalPlayer.DisplayName
		userName = "@" .. LocalPlayer.Name
		task.spawn(function()
			local ok, content = pcall(function()
				return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			end)
			if ok then
				avatar.Image = content
			end
		end)
	end

	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, profileTextLeft, 0, 10),
		Size = UDim2.new(1, -(profileTextLeft + profileTextRight), 0, 16),
		Font = Enum.Font.GothamBold,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = THEME.text,
		Text = displayName,
		Parent = profileCard,
	})

	new("TextLabel", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, profileTextLeft, 0, 28),
		Size = UDim2.new(1, -(profileTextLeft + profileTextRight), 0, 14),
		Font = Enum.Font.Gotham,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = THEME.muted,
		Text = userName,
		Parent = profileCard,
	})

	local content = new("Frame", {
		Name = "Content",
		BackgroundColor3 = THEME.content,
		BorderSizePixel = 0,
		Position = UDim2.new(0, SIDEBAR_WIDTH - 1, 0, HEADER_HEIGHT),
		Size = UDim2.new(1, -(SIDEBAR_WIDTH - 1), 1, -HEADER_HEIGHT),
		Parent = root,
	})

	local contentCover = new("Frame", {
		BackgroundColor3 = THEME.content,
		BorderSizePixel = 0,
		Size = UDim2.new(0, CORNER, 1, 0),
		Parent = content,
	})

	local windowTransparency = 0
	if settings.WindowTransparency ~= nil then
		windowTransparency = normalizeWindowTransparency(settings.WindowTransparency)
	elseif settings.Transparency ~= nil then
		windowTransparency = normalizeWindowTransparency(settings.Transparency)
	end
	local defaultWindowTransparency = windowTransparency

	local windowPanels = { root, headerBar, sidebar, sidebarCover, content, contentCover }
	local settingsGearButton

	local function applyWindowTransparency(transparency)
		for _, panel in ipairs(windowPanels) do
			panel.BackgroundTransparency = transparency
		end
		if rootStroke then
			rootStroke.Transparency = 0.25 + (transparency * 0.5)
		end
	end

	local function applyWindowAccent(color)
		applyAccentTheme(color)
		for _, target in ipairs(accentTargets) do
			if target:IsA("TextLabel") then
				target.TextColor3 = color
			elseif target:IsA("Frame") then
				target.BackgroundColor3 = color
			elseif target:IsA("ScrollingFrame") then
				target.ScrollBarImageColor3 = color
			elseif target:IsA("UIStroke") then
				target.Color = color
			elseif target:IsA("ImageLabel") then
				target.ImageColor3 = color
			end
		end
		for _, indicator in ipairs(accentIndicators) do
			if indicator.Parent then
				indicator.BackgroundColor3 = color
			end
		end
		for _, scrollbar in ipairs(accentScrollbars) do
			if scrollbar.Parent then
				scrollbar.ScrollBarImageColor3 = color
			end
		end
		if settingsGearButton and settingsGearButton.IsActive() then
			settingsGearButton.RefreshAccent()
		end
		runAccentRefreshers(color)
	end

	applyWindowTransparency(windowTransparency)
	applyWindowAccent(appliedAccentColor)

	local topBar = new("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, CONTENT_TOPBAR_HEIGHT),
		Parent = content,
	})

	local pageTitle = new("TextLabel", {
		Name = "PageTitle",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 20, 0, 10),
		Size = UDim2.new(1, -40, 0, 22),
		Font = Enum.Font.GothamBold,
		TextSize = DEFAULT_CONTENT_TITLE_SIZE,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextColor3 = THEME.text,
		Text = title,
		Active = false,
		Parent = topBar,
	})

	local defaultContentTitleSize = DEFAULT_CONTENT_TITLE_SIZE
	local contentTitleSize = defaultContentTitleSize
	local defaultWindowScale = DEFAULT_WINDOW_SCALE
	local windowScale = defaultWindowScale
	local defaultRememberPosition = false
	local rememberPosition = defaultRememberPosition
	local defaultShowMobileFab = true
	local showMobileFab = defaultShowMobileFab
	local initialFabPosition = nil
	local CENTER_WINDOW_POSITION = UDim2.fromScale(0.5, 0.5)

	local function applyWindowScale(scalePercent)
		local scale = math.clamp(scalePercent or defaultWindowScale, MIN_WINDOW_SCALE, MAX_WINDOW_SCALE) / 100
		root.Size = UDim2.new(0, math.floor(WINDOW_SIZE.X * scale + 0.5), 0, math.floor(WINDOW_SIZE.Y * scale + 0.5))
	end

	local function applyContentTitleSize(size)
		contentTitleSize = math.clamp(math.floor(size or defaultContentTitleSize), MIN_CONTENT_TITLE_SIZE, MAX_CONTENT_TITLE_SIZE)
		pageTitle.TextSize = contentTitleSize
	end

	local function applySavedWindowPosition(positionData)
		if type(positionData) ~= "table" then
			return
		end
		if type(positionData.xScale) ~= "number" or type(positionData.yScale) ~= "number" then
			return
		end
		root.Position = UDim2.new(
			positionData.xScale,
			tonumber(positionData.xOffset) or 0,
			positionData.yScale,
			tonumber(positionData.yOffset) or 0
		)
	end

	applyWindowScale(windowScale)
	applyContentTitleSize(contentTitleSize)

	local function resolveToggleKeyName(keybindSetting)
		if keybindSetting ~= nil then
			if type(keybindSetting) == "string" then
				return string.upper(keybindSetting)
			elseif typeof(keybindSetting) == "EnumItem" and keybindSetting.EnumType == Enum.KeyCode then
				return keybindSetting.Name
			end
		end
		return "K"
	end

	local function resolveToggleKeyCode(keyName)
		if type(keyName) ~= "string" or keyName == "" then
			return nil
		end
		return Enum.KeyCode[string.upper(keyName)]
	end

	local defaultToggleKeyName = resolveToggleKeyName(settings.ToggleUIKeybind)
	local toggleKeyName = defaultToggleKeyName
	local toggleKeyCode = resolveToggleKeyCode(toggleKeyName)
	local toggleKeyConnection
	local windowVisible = true
	local mobileFab
	local uiSettingsPage
	local lastSelectedTabId

	local function persistUiSettings()
		if not (writefile and isfolder and makefolder) then
			return
		end
		pcall(function()
			if not isfolder(folderName) then
				makefolder(folderName)
			end
			local payload = {
				transparency = math.floor(windowTransparency * 100 + 0.5),
				toggleKey = toggleKeyName,
				accentPreset = colorToPresetName(appliedAccentColor),
				windowScale = windowScale,
				contentTitleSize = contentTitleSize,
				rememberPosition = rememberPosition,
				showMobileFab = showMobileFab,
			}
			if rememberPosition then
				payload.position = {
					xScale = root.Position.X.Scale,
					xOffset = root.Position.X.Offset,
					yScale = root.Position.Y.Scale,
					yOffset = root.Position.Y.Offset,
				}
			end
			if mobileFab then
				payload.fabPosition = {
					x = mobileFab.Position.X.Offset,
					y = mobileFab.Position.Y.Offset,
				}
			end
			writefile(folderName .. "/ui_settings.json", HttpService:JSONEncode(payload))
		end)
	end

	local function loadUiSettings()
		if not (readfile and isfile) then
			return
		end
		local ok, decoded = pcall(function()
			local path = folderName .. "/ui_settings.json"
			if not isfile(path) then
				return nil
			end
			return HttpService:JSONDecode(readfile(path))
		end)
		if not ok or type(decoded) ~= "table" then
			return
		end
		if type(decoded.transparency) == "number" then
			windowTransparency = normalizeWindowTransparency(decoded.transparency)
			applyWindowTransparency(windowTransparency)
		end
		if type(decoded.accentPreset) == "string" then
			for _, preset in ipairs(ACCENT_PRESETS) do
				if preset.name == decoded.accentPreset then
					applyWindowAccent(preset.color)
					break
				end
			end
		end
		if type(decoded.toggleKey) == "string" and decoded.toggleKey ~= "" then
			toggleKeyName = string.upper(decoded.toggleKey)
			toggleKeyCode = resolveToggleKeyCode(toggleKeyName)
		end
		if type(decoded.windowScale) == "number" then
			windowScale = math.clamp(math.floor(decoded.windowScale), MIN_WINDOW_SCALE, MAX_WINDOW_SCALE)
			applyWindowScale(windowScale)
		end
		if type(decoded.contentTitleSize) == "number" then
			applyContentTitleSize(decoded.contentTitleSize)
		end
		if decoded.rememberPosition == true then
			rememberPosition = true
			applySavedWindowPosition(decoded.position)
		end
		if type(decoded.showMobileFab) == "boolean" then
			showMobileFab = decoded.showMobileFab
		end
		initialFabPosition = fabPositionFromData(decoded.fabPosition)
	end

	loadUiSettings()

	local function disconnectToggleKey()
		if toggleKeyConnection then
			toggleKeyConnection:Disconnect()
			toggleKeyConnection = nil
		end
	end

	local function setWindowVisible(isVisible)
		windowVisible = isVisible == true
		root.Visible = windowVisible
		mobileFab.Visible = isMobile and showMobileFab and not windowVisible
		screenGui.Enabled = true
	end

	local function toggleWindowVisible()
		setWindowVisible(not windowVisible)
	end

	local function connectToggleKey(keyCode)
		disconnectToggleKey()
		toggleKeyCode = keyCode
		if keyCode and not isMobile then
			toggleKeyConnection = UserInputService.InputBegan:Connect(function(input, processed)
				if processed then
					return
				end
				if input.UserInputType ~= Enum.UserInputType.Keyboard then
					return
				end
				if input.KeyCode == keyCode then
					toggleWindowVisible()
				end
			end)
		end
	end

	mobileFab = createMobileFab(screenGui, settings, title, function()
		setWindowVisible(true)
	end, {
		initialPosition = initialFabPosition,
		onPositionChanged = function()
			persistUiSettings()
		end,
	})
	mobileFab.Visible = false

	local mobileFabStroke = mobileFab:FindFirstChildOfClass("UIStroke")
	if mobileFabStroke then
		table.insert(accentTargets, mobileFabStroke)
	end
	local mobileFabInitial = mobileFab:FindFirstChild("Initial")
	if mobileFabInitial then
		table.insert(accentTargets, mobileFabInitial)
	end

	windowButton("MinimizeButton", "—", -44, toggleWindowVisible)

	windowButton("CloseButton", "×", -12, function()
		setWindowVisible(false)
	end)

	local pages = new("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, CONTENT_TOPBAR_HEIGHT),
		Size = UDim2.new(1, 0, 1, -CONTENT_TOPBAR_HEIGHT),
		Parent = content,
	})

	local window = {
		_screenGui = screenGui,
		_root = root,
		_pages = pages,
		_tabs = {},
		_tabOrder = 0,
		_selected = nil,
		_setSelected = nil,
		Folder = folderName,
		ConfigManager = nil,
	}

	local function closeUiSettings()
		if not uiSettingsPage or not uiSettingsPage.IsOpen() then
			return false
		end
		uiSettingsPage.Close()
		if settingsGearButton then
			settingsGearButton.SetActive(false)
		end
		return true
	end

	local function selectTab(tabId)
		closeUiSettings()
		for id, tabInfo in pairs(window._tabs) do
			tabInfo.setSelected(id == tabId)
			if id == tabId then
				pageTitle.Text = tabInfo.title
			end
		end
		window._selected = tabId
		lastSelectedTabId = tabId
	end

	local function selectSettings()
		closeActiveDropdown()
		for _, tabInfo in pairs(window._tabs) do
			tabInfo.setSelected(false)
		end
		window._selected = nil
		pageTitle.Text = "UI Configuration"
		if uiSettingsPage then
			uiSettingsPage.Open()
		end
		if settingsGearButton then
			settingsGearButton.SetActive(true)
		end
	end

	window.selectTab = selectTab
	window.selectSettings = selectSettings

	local function resetUiSettingsToDefaults()
		windowTransparency = defaultWindowTransparency
		applyWindowTransparency(windowTransparency)
		applyWindowAccent(defaultAccentColor)
		toggleKeyName = defaultToggleKeyName
		connectToggleKey(resolveToggleKeyCode(toggleKeyName))
		windowScale = defaultWindowScale
		applyWindowScale(windowScale)
		applyContentTitleSize(defaultContentTitleSize)
		rememberPosition = defaultRememberPosition
		showMobileFab = defaultShowMobileFab
		root.Position = CENTER_WINDOW_POSITION
		if mobileFab and mobileFab.SetFabPosition then
			mobileFab:SetFabPosition(getDefaultFabPosition(screenGui))
		end
		setWindowVisible(windowVisible)
		persistUiSettings()
	end

	local uiSettingsConfig = {
		isMobile = isMobile,
		accentScrollbars = accentScrollbars,
		getTransparencyPercent = function()
			return math.floor(windowTransparency * 100 + 0.5)
		end,
		setTransparencyPercent = function(value)
			windowTransparency = normalizeWindowTransparency(value)
			applyWindowTransparency(windowTransparency)
			persistUiSettings()
		end,
		getToggleKeyName = function()
			return toggleKeyName
		end,
		setToggleKeyName = function(value)
			local cleaned = trimText(tostring(value or ""))
			if cleaned == "" then
				return
			end
			cleaned = string.upper(cleaned)
			local keyCode = resolveToggleKeyCode(cleaned)
			if not keyCode then
				SempatLibrary:Notify({
					Title = "UI Configuration",
					Content = "Invalid key: " .. cleaned,
				})
				return
			end
			toggleKeyName = cleaned
			connectToggleKey(keyCode)
			persistUiSettings()
		end,
		getAccentColor = function()
			return appliedAccentColor
		end,
		setAccentColor = function(color)
			applyWindowAccent(color)
			persistUiSettings()
		end,
		resetToDefaults = resetUiSettingsToDefaults,
		clearSavedUiSettings = function()
			if delfile and isfile then
				local path = folderName .. "/ui_settings.json"
				if isfile(path) then
					pcall(delfile, path)
				end
			end
			resetUiSettingsToDefaults()
		end,
		getWindowScale = function()
			return windowScale
		end,
		setWindowScale = function(value)
			windowScale = math.clamp(math.floor(tonumber(value) or defaultWindowScale), MIN_WINDOW_SCALE, MAX_WINDOW_SCALE)
			applyWindowScale(windowScale)
			persistUiSettings()
		end,
		getContentTitleSize = function()
			return contentTitleSize
		end,
		setContentTitleSize = function(value)
			applyContentTitleSize(value)
			persistUiSettings()
		end,
		getRememberPosition = function()
			return rememberPosition
		end,
		setRememberPosition = function(value)
			rememberPosition = value == true
			persistUiSettings()
		end,
		getShowMobileFab = function()
			return showMobileFab
		end,
		setShowMobileFab = function(value)
			showMobileFab = value == true
			setWindowVisible(windowVisible)
			persistUiSettings()
		end,
		resetWindowPosition = function()
			root.Position = CENTER_WINDOW_POSITION
			persistUiSettings()
		end,
		getAboutText = function()
			return string.format(
				"Sempat UI v%s\nConfig folder: %s",
				tostring(SempatLibrary.Version),
				tostring(folderName)
			)
		end,
	}

	uiSettingsPage = createUiSettingsPage(pages, uiSettingsConfig)

	settingsGearButton = windowIconButton("SettingsButton", GEAR_BUTTON_TEXT, -76, function()
		if uiSettingsPage.IsOpen() then
			uiSettingsPage.Close()
			settingsGearButton.SetActive(false)
			if lastSelectedTabId and window._tabs[lastSelectedTabId] then
				selectTab(lastSelectedTabId)
			end
		else
			lastSelectedTabId = window._selected
			selectSettings()
		end
	end)

	function window:CreateTab(tabTitle, _iconId)
		self._tabOrder += 1
		local tabId = "tab_" .. self._tabOrder

		local page = new("Frame", {
			Name = tabId,
			BackgroundTransparency = 1,
			Size = UDim2.fromScale(1, 1),
			Visible = false,
			Parent = pages,
		})

		local scroll = new("ScrollingFrame", {
			Name = "Scroll",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -10, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = appliedAccentColor,
			CanvasSize = UDim2.new(),
			Parent = page,
		})
		table.insert(accentScrollbars, scroll)
		padding(scroll, 0, 16, 20, 16)

		local list = new("UIListLayout", {
			FillDirection = Enum.FillDirection.Vertical,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 10),
			Parent = scroll,
		})

		list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			scheduleCanvasUpdate(scroll)
		end)

		local setSelected = createSidebarButton(tabList, window, {
			id = tabId,
			title = tabTitle or "Tab",
			order = self._tabOrder,
			frame = page,
		}, accentIndicators)

		local tabApi = createTabApi(page, scroll, pageTitle)
		tabApi._title = tabTitle

		self._tabs[tabId] = {
			id = tabId,
			title = tabTitle or "Tab",
			frame = page,
			api = tabApi,
			setSelected = setSelected,
		}

		if not self._selected then
			selectTab(tabId)
		end

		return tabApi
	end

	function window:Tab(props)
		props = props or {}
		return self:CreateTab(props.Title or props.Name or "Tab", props.Icon)
	end

	function window:SetCurrentConfig(_cfg)
		return nil
	end

	function window:Toggle(state)
		if state == nil then
			toggleWindowVisible()
			return windowVisible
		end
		setWindowVisible(state ~= false)
		return windowVisible
	end

	function window:IsOpen()
		return windowVisible
	end

	function window:SetTransparency(value)
		if type(value) ~= "number" then
			return windowTransparency
		end
		windowTransparency = normalizeWindowTransparency(value)
		applyWindowTransparency(windowTransparency)
		return windowTransparency
	end

	function window:GetTransparency()
		return math.floor(windowTransparency * 100 + 0.5)
	end

	function window:SetAccentColor(color)
		if typeof(color) ~= "Color3" then
			return appliedAccentColor
		end
		applyWindowAccent(color)
		persistUiSettings()
		return appliedAccentColor
	end

	function window:GetAccentColor()
		return appliedAccentColor
	end

	function window:SetToggleKeybind(keyName)
		if type(keyName) ~= "string" or trimText(keyName) == "" then
			return toggleKeyName
		end
		local cleaned = string.upper(trimText(keyName))
		local keyCode = resolveToggleKeyCode(cleaned)
		if not keyCode then
			return toggleKeyName
		end
		toggleKeyName = cleaned
		connectToggleKey(keyCode)
		persistUiSettings()
		return toggleKeyName
	end

	function window:GetToggleKeybind()
		return toggleKeyName
	end

	function window:OpenSettings()
		lastSelectedTabId = window._selected
		selectSettings()
	end

	function window:CloseSettings()
		if not closeUiSettings() then
			return
		end
		if lastSelectedTabId and window._tabs[lastSelectedTabId] then
			selectTab(lastSelectedTabId)
		end
	end

	function window:Destroy()
		disconnectToggleKey()
		clearAccentRefreshers()
		screenGui:Destroy()
	end

	-- Simple config manager stub for WindUI config tab compatibility.
	if folderName and writefile and makefolder and isfolder then
		local configManager = {
			_folder = folderName,
			_path = folderName,
		}

		function configManager:Save(name, data)
			if type(name) ~= "string" or type(data) ~= "table" then
				return false
			end
			pcall(function()
				if not isfolder(folderName) then
					makefolder(folderName)
				end
				local fileName = folderName .. "/" .. name .. ".json"
				writefile(fileName, HttpService:JSONEncode(data))
			end)
			return true
		end

		function configManager:Load(name)
			if type(name) ~= "string" then
				return nil
			end
			local ok, data = pcall(function()
				local fileName = folderName .. "/" .. name .. ".json"
				if isfile and isfile(fileName) and readfile then
					return HttpService:JSONDecode(readfile(fileName))
				end
				return nil
			end)
			if ok then
				return data
			end
			return nil
		end

		function configManager:Delete(name)
			if delfile and isfile then
				local fileName = folderName .. "/" .. name .. ".json"
				if isfile(fileName) then
					pcall(delfile, fileName)
				end
			end
		end

		function configManager:AllConfigs()
			if listfiles and isfolder and isfolder(folderName) then
				local files = {}
				for _, path in ipairs(listfiles(folderName)) do
					local name = string.match(path, "([^/\\]+)%.json$")
					if name then
						table.insert(files, name)
					end
				end
				return files
			end
			return {}
		end

		window.ConfigManager = configManager
	end

	connectToggleKey(toggleKeyCode)

	-- Drag support (dedicated handles; min/close buttons stay clickable)
	local dragging = false
	local dragStart
	local startPos

	local function beginWindowDrag(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1
			and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end
		dragging = true
		dragStart = input.Position
		startPos = root.Position
	end

	local function endWindowDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			if rememberPosition then
				persistUiSettings()
			end
		end
	end

	headerDragHandle.InputBegan:Connect(beginWindowDrag)

	UserInputService.InputEnded:Connect(endWindowDrag)

	UserInputService.InputChanged:Connect(function(input)
		if not dragging or not windowVisible then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch then
			local delta = input.Position - dragStart
			root.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	return window
end

return SempatLibrary
