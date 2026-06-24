--[[
  Native ScreenGui picker for UI library selection (Rayfield / WindUI / Sempat UI).
  Used before loading multi-library games (e.g. others.lua).
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local COLORS = {
	background = Color3.fromRGB(18, 18, 22),
	panel = Color3.fromRGB(28, 28, 34),
	panelStroke = Color3.fromRGB(58, 58, 72),
	title = Color3.fromRGB(245, 245, 250),
	subtitle = Color3.fromRGB(170, 170, 185),
	button = Color3.fromRGB(42, 42, 52),
	buttonHover = Color3.fromRGB(56, 56, 70),
	buttonText = Color3.fromRGB(240, 240, 245),
	accentRayfield = Color3.fromRGB(66, 135, 245),
	accentWindUI = Color3.fromRGB(88, 101, 242),
	accentSempat = Color3.fromRGB(102, 224, 163),
}

local function getGuiParent()
	local player = Players.LocalPlayer
	if not player then
		return nil
	end

	local ok, hui = pcall(function()
		return gethui and gethui()
	end)
	if ok and typeof(hui) == "Instance" then
		return hui
	end

	return player:WaitForChild("PlayerGui")
end

local function addCorner(inst, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = inst
	return corner
end

local function addStroke(inst, color, transparency)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 1
	stroke.Transparency = transparency or 0
	stroke.Parent = inst
	return stroke
end

local function createLibraryButton(parent, layoutOrder, accentColor, library, onPick)
	local button = Instance.new("TextButton")
	button.Name = "Library_" .. library.id
	button.Size = UDim2.new(1, 0, 0, 72)
	button.BackgroundColor3 = COLORS.button
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = ""
	button.LayoutOrder = layoutOrder
	button.Parent = parent
	addCorner(button, 10)
	addStroke(button, COLORS.panelStroke, 0.35)

	local accent = Instance.new("Frame")
	accent.Name = "Accent"
	accent.Size = UDim2.new(0, 4, 1, -16)
	accent.Position = UDim2.new(0, 8, 0, 8)
	accent.BackgroundColor3 = accentColor
	accent.BorderSizePixel = 0
	accent.Parent = button
	addCorner(accent, 4)

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Position = UDim2.new(0, 24, 0, 14)
	title.Size = UDim2.new(1, -36, 0, 22)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextColor3 = COLORS.buttonText
	title.Text = library.label or library.id
	title.Parent = button

	local desc = Instance.new("TextLabel")
	desc.Name = "Description"
	desc.BackgroundTransparency = 1
	desc.Position = UDim2.new(0, 24, 0, 38)
	desc.Size = UDim2.new(1, -36, 0, 20)
	desc.Font = Enum.Font.Gotham
	desc.TextSize = 13
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.TextColor3 = COLORS.subtitle
	desc.Text = library.description or ""
	desc.TextWrapped = true
	desc.Parent = button

	local picked = false
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.buttonHover }):Play()
	end)
	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.15), { BackgroundColor3 = COLORS.button }):Play()
	end)
	button.MouseButton1Click:Connect(function()
		if picked then
			return
		end
		picked = true
		onPick(library)
	end)

	return button
end

local function destroyPicker(gui)
	if gui and gui.Parent then
		gui:Destroy()
	end
end

local function showUiLibraryPicker(options)
	options = options or {}
	local libraries = options.libraries
	if type(libraries) ~= "table" or #libraries == 0 then
		warn("[sempatpanick] ui_library_picker: no libraries configured")
		return
	end

	local onSelect = options.onSelect
	if type(onSelect) ~= "function" then
		warn("[sempatpanick] ui_library_picker: onSelect callback required")
		return
	end

	local parent = getGuiParent()
	if not parent then
		warn("[sempatpanick] ui_library_picker: PlayerGui unavailable")
		onSelect(libraries[1])
		return
	end

	local existing = parent:FindFirstChild("sempatpanick_ui_library_picker")
	if existing then
		existing:Destroy()
	end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "sempatpanick_ui_library_picker"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 1000
	screenGui.Parent = parent

	local backdrop = Instance.new("Frame")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = Color3.new(0, 0, 0)
	backdrop.BackgroundTransparency = 0.35
	backdrop.BorderSizePixel = 0
	backdrop.Parent = screenGui

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.Size = UDim2.new(0, 360, 0, 0)
	panel.AutomaticSize = Enum.AutomaticSize.Y
	panel.BackgroundColor3 = COLORS.panel
	panel.BorderSizePixel = 0
	panel.Parent = screenGui
	addCorner(panel, 14)
	addStroke(panel, COLORS.panelStroke, 0.2)

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 22)
	padding.PaddingBottom = UDim.new(0, 22)
	padding.PaddingLeft = UDim.new(0, 22)
	padding.PaddingRight = UDim.new(0, 22)
	padding.Parent = panel

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 12)
	layout.Parent = panel

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.BackgroundTransparency = 1
	title.Size = UDim2.new(1, 0, 0, 28)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.TextColor3 = COLORS.title
	title.Text = options.title or "sempatpanick"
	title.LayoutOrder = 1
	title.Parent = panel

	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.BackgroundTransparency = 1
	subtitle.Size = UDim2.new(1, 0, 0, 40)
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 14
	subtitle.TextWrapped = true
	subtitle.TextColor3 = COLORS.subtitle
	subtitle.Text = options.subtitle or "Choose a UI library to continue"
	subtitle.LayoutOrder = 2
	subtitle.Parent = panel

	local accentById = {
		rayfield = COLORS.accentRayfield,
		windui = COLORS.accentWindUI,
		sempat = COLORS.accentSempat,
	}

	for index, library in ipairs(libraries) do
		createLibraryButton(panel, 10 + index, accentById[library.id] or COLORS.accentRayfield, library, function(selected)
			destroyPicker(screenGui)
			onSelect(selected)
		end)
	end

	panel.Size = UDim2.new(0, 360, 0, layout.AbsoluteContentSize.Y + 44)
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		panel.Size = UDim2.new(0, 360, 0, layout.AbsoluteContentSize.Y + 44)
	end)
end

return {
	show = showUiLibraryPicker,
}
