--[[
	Sempat UI Studio gallery

	Studio setup:
	1. StarterPlayer > StarterPlayerScripts > LocalScript (paste this file)
	2. Put a ModuleScript named `sempat_library` as a CHILD of that LocalScript
	3. Paste the full contents of sempat_library.lua into that ModuleScript
	4. View > Output, then press Play (F5)

	Sempat has no CreateKeybind / CreateColorPicker widgets. Window toggle key
	is ToggleUIKeybind / SetToggleKeybind; accent is SetAccentColor.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local function findLibrary()
	local names = { "sempat_library", "sempat_library.lua", "SempatLibrary" }
	local roots = { script, script.Parent, ReplicatedStorage }
	for _, root in ipairs(roots) do
		if root then
			for _, name in ipairs(names) do
				local found = root:FindFirstChild(name)
				if found then
					return found
				end
			end
		end
	end
	return ReplicatedStorage:FindFirstChild("sempat_library", true)
end

local module = findLibrary()
if not module then
	warn("[StudioHub] Missing ModuleScript `sempat_library`. Put it as a child of this LocalScript.")
	return
end
if not module:IsA("ModuleScript") then
	warn("[StudioHub]", module:GetFullName(), "is a", module.ClassName, "- it must be a ModuleScript")
	return
end

local okRequire, SempatLibrary = pcall(require, module)
if not okRequire then
	warn("[StudioHub] require failed:", SempatLibrary)
	return
end

local function notify(title, content)
	SempatLibrary:Notify({
		Title = title or "Gallery",
		Content = tostring(content),
		Duration = 3,
	})
	print("[StudioHub]", title, content)
end

local Window = SempatLibrary:CreateWindow({
	Name = "sempatpanick | Studio Gallery",
	LoadingTitle = "sempatpanick",
	LoadingSubtitle = "Sempat UI • all widgets",
	ToggleUIKeybind = "K",
	WindowTransparency = 10,
	AccentColor = Color3.fromRGB(102, 224, 163),
	Parent = playerGui,
})

local function createElementsTab()
	local Tab = Window:CreateTab("Elements")

	Tab:CreateSection("Copy")
	local paragraph = Tab:CreateParagraph({
		Title = "Sempat UI widgets",
		Content = "Toggle, Slider, Dropdown, Input, Button, Image, and Paragraph. Sliders accept typed values.",
	})
	Tab:CreateButton({
		Name = "Update paragraph text",
		Callback = function()
			paragraph:Set({
				Title = "Paragraph updated",
				Content = "SetTitle / SetDesc / Set also work. Time " .. os.date("%H:%M:%S"),
			})
		end,
	})

	Tab:CreateSection("Toggle")
	local featureToggle = Tab:CreateToggle({
		Name = "Enable feature",
		Content = "CurrentValue is a boolean",
		CurrentValue = true,
		Flag = "gallery_feature",
		Callback = function(value)
			notify("Toggle", value)
		end,
	})
	Tab:CreateButton({
		Name = "Set toggle off",
		Callback = function()
			featureToggle:Set(false)
		end,
	})

	Tab:CreateSection("Slider")
	Tab:CreateSlider({
		Name = "Integer with suffix",
		Content = "Click the box to type a value",
		Range = { 0, 95 },
		Increment = 1,
		Suffix = "%",
		CurrentValue = 30,
		Flag = "gallery_transparency",
		Callback = function(value)
			print("[slider %]", value)
		end,
	})
	Tab:CreateSlider({
		Name = "Stepped scale",
		Range = { 50, 150 },
		Increment = 5,
		Suffix = "%",
		CurrentValue = 100,
		Callback = function(value)
			print("[slider scale]", value)
		end,
	})
	Tab:CreateSlider({
		Name = "Decimal step",
		Content = "Increment 0.1 — type 1.5 or drag",
		Range = { 0, 10 },
		Increment = 0.1,
		CurrentValue = 2.5,
		Callback = function(value)
			print("[slider decimal]", value)
		end,
	})

	Tab:CreateSection("Dropdown")
	Tab:CreateDropdown({
		Name = "Single select",
		Options = { "Spawn", "Checkpoint 1", "Checkpoint 2", "Summit" },
		CurrentOption = { "Spawn" },
		Callback = function(value)
			notify("Dropdown", type(value) == "table" and table.concat(value, ", ") or value)
		end,
	})
	Tab:CreateDropdown({
		Name = "Multi select",
		Content = "Multi = true",
		Options = { "Speed", "Jump", "Noclip", "ESP" },
		CurrentOption = { "Speed" },
		Multi = true,
		Callback = function(value)
			notify("Multi", table.concat(value or {}, ", "))
		end,
	})
	Tab:CreateDropdown({
		Name = "Searchable list",
		Content = "Search = true",
		Options = {
			"Alpha",
			"Bravo",
			"Charlie",
			"Delta",
			"Echo",
			"Foxtrot",
			"Golf",
			"Hotel",
			"India",
			"Juliet",
		},
		CurrentOption = { "Alpha" },
		Search = true,
		Callback = function(value)
			print("[search dropdown]", value)
		end,
	})

	Tab:CreateSection("Input")
	local nameInput = Tab:CreateInput({
		Name = "Display name",
		PlaceholderText = "Type here",
		CurrentValue = "Studio",
		Callback = function(text)
			print("[input]", text)
		end,
	})
	Tab:CreateButton({
		Name = "Fill input with Player name",
		Callback = function()
			nameInput:Set(player.Name)
		end,
	})

	Tab:CreateSection("Buttons")
	Tab:CreateButton({
		Name = "Default accent button",
		Callback = function()
			notify("Button", "default")
		end,
	})
	Tab:CreateButton({
		Name = "Custom color",
		Color = Color3.fromRGB(91, 156, 245),
		Callback = function()
			notify("Button", "sky")
		end,
	})
	Tab:CreateButton({
		Name = "Danger color",
		Color = Color3.fromRGB(239, 68, 68),
		Callback = function()
			notify("Button", "danger")
		end,
	})

	Tab:CreateSection("Image")
	Tab:CreateImage({
		Title = "Placeholder image",
		Description = "ImageAlign left, ImageSize 96",
		Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
		ImageSize = 96,
		ImageAlign = "left",
	})
end

local function createWindowApiTab()
	local Tab = Window:CreateTab("Window")

	Tab:CreateSection("Visibility")
	Tab:CreateParagraph({
		Title = "Toggle UI",
		Content = "Keybind starts as K. Use the gear in the header for built-in UI settings.",
	})
	Tab:CreateButton({
		Name = "Toggle window",
		Callback = function()
			Window:Toggle()
			notify("Window", Window:IsOpen() and "open" or "closed")
		end,
	})
	Tab:CreateButton({
		Name = "Open built-in settings",
		Callback = function()
			Window:OpenSettings()
		end,
	})
	Tab:CreateButton({
		Name = "Close built-in settings",
		Callback = function()
			Window:CloseSettings()
		end,
	})

	Tab:CreateSection("Transparency")
	Tab:CreateSlider({
		Name = "Window transparency",
		Range = { 0, 95 },
		Increment = 1,
		Suffix = "%",
		CurrentValue = Window:GetTransparency(),
		Callback = function(value)
			Window:SetTransparency(value)
		end,
	})

	Tab:CreateSection("Theme")
	Tab:CreateDropdown({
		Name = "Theme preset",
		Options = { "Default", "Dark", "Light", "AMOLED" },
		CurrentOption = { Window:GetThemePreset() },
		Callback = function(value)
			local name = type(value) == "table" and value[1] or value
			Window:SetThemePreset(name)
			notify("Theme", Window:GetThemePreset())
		end,
	})
	Tab:CreateDropdown({
		Name = "Accent color",
		Options = { "Mint", "Sky", "Violet", "Rose", "Amber", "Crimson" },
		CurrentOption = { "Mint" },
		Callback = function(value)
			local name = type(value) == "table" and value[1] or value
			local colors = {
				Mint = Color3.fromRGB(102, 224, 163),
				Sky = Color3.fromRGB(91, 156, 245),
				Violet = Color3.fromRGB(167, 139, 250),
				Rose = Color3.fromRGB(244, 114, 182),
				Amber = Color3.fromRGB(251, 146, 60),
				Crimson = Color3.fromRGB(239, 68, 68),
			}
			Window:SetAccentColor(colors[name])
			notify("Accent", name)
		end,
	})

	Tab:CreateSection("Keybind")
	Tab:CreateDropdown({
		Name = "Toggle UI key",
		Content = "Window:SetToggleKeybind",
		Options = { "K", "RightShift", "RightControl", "P", "LeftAlt" },
		CurrentOption = { Window:GetToggleKeybind() },
		Callback = function(value)
			local name = type(value) == "table" and value[1] or value
			Window:SetToggleKeybind(name)
			notify("Keybind", Window:GetToggleKeybind())
		end,
	})

	Tab:CreateSection("Notify")
	Tab:CreateButton({
		Name = "Show notification",
		Callback = function()
			notify("Notify", "SempatLibrary:Notify")
		end,
	})
end

local function createPopupTab()
	local Tab = Window:CreateTab("Popup")

	local popup = Window:CreatePopup({
		Title = "Example popup",
		Content = "Popups support the same widgets as tabs. Esc or overlay click closes.",
		DoneText = "Close",
		Width = 420,
		Height = 380,
		CloseOnOverlayClick = true,
		OnOpen = function()
			print("[popup] open")
		end,
		OnClose = function()
			print("[popup] close")
		end,
	})

	popup:CreateSection("Inside popup")
	popup:CreateToggle({
		Name = "Popup toggle",
		CurrentValue = false,
		Callback = function(value)
			print("[popup toggle]", value)
		end,
	})
	popup:CreateSlider({
		Name = "Popup slider",
		Range = { 1, 10 },
		Increment = 1,
		CurrentValue = 4,
		Callback = function(value)
			print("[popup slider]", value)
		end,
	})
	popup:CreateDropdown({
		Name = "Popup dropdown",
		Options = { "One", "Two", "Three" },
		CurrentOption = { "One" },
		Callback = function(value)
			print("[popup dropdown]", value)
		end,
	})
	popup:CreateInput({
		Name = "Popup input",
		PlaceholderText = "Type in the popup",
		Callback = function(text)
			print("[popup input]", text)
		end,
	})
	popup:CreateButton({
		Name = "Notify from popup",
		Callback = function()
			notify("Popup", "button")
		end,
	})

	Tab:CreateSection("Controls")
	Tab:CreateParagraph({
		Title = "CreatePopup",
		Content = "Open, Close, SetTitle, SetContent, IsOpen. Same Create* widgets as a tab.",
	})
	Tab:CreateButton({
		Name = "Open popup",
		Callback = function()
			popup:Open()
		end,
	})
	Tab:CreateButton({
		Name = "Close popup",
		Callback = function()
			popup:Close()
		end,
	})
	Tab:CreateButton({
		Name = "Rename popup title",
		Callback = function()
			popup:SetTitle("Popup " .. os.date("%H:%M:%S"))
		end,
	})
	Tab:CreateButton({
		Name = "Change popup description",
		Callback = function()
			popup:SetContent("IsOpen = " .. tostring(popup:IsOpen()))
		end,
	})
end

local function createVisibilityTab()
	local Tab = Window:CreateTab("Visibility")

	Tab:CreateSection("SetVisible")
	local hiddenSlider = Tab:CreateSlider({
		Name = "Hidden until toggled",
		Range = { 0, 100 },
		Increment = 1,
		CurrentValue = 25,
		Callback = function(value)
			print("[hidden slider]", value)
		end,
	})
	hiddenSlider:SetVisible(false)

	local showHidden = false
	Tab:CreateButton({
		Name = "Show / hide extra slider",
		Callback = function()
			showHidden = not showHidden
			hiddenSlider:SetVisible(showHidden)
		end,
	})

	Tab:CreateSection("Element Set")
	local liveToggle = Tab:CreateToggle({
		Name = "Live toggle",
		CurrentValue = false,
		Callback = function(value)
			print("[live toggle]", value)
		end,
	})
	local liveSlider = Tab:CreateSlider({
		Name = "Live slider",
		Range = { 0, 100 },
		Increment = 1,
		CurrentValue = 0,
		Callback = function(value)
			print("[live slider]", value)
		end,
	})
	Tab:CreateButton({
		Name = "Set toggle on + slider 75",
		Callback = function()
			liveToggle:Set(true)
			liveSlider:Set(75)
		end,
	})
end

local function createAboutTab()
	local Tab = Window:CreateTab("About")
	Tab:CreateSection("Library")
	Tab:CreateParagraph({
		Title = "Sempat UI v" .. tostring(SempatLibrary.Version),
		Content = "This gallery runs in Studio via require(). Executors still load with HttpGet + loadstring from port 5500.",
	})
	Tab:CreateParagraph({
		Title = "Not in Sempat",
		Content = "No CreateKeybind or CreateColorPicker widgets. Use SetToggleKeybind and SetAccentColor on the window instead.",
	})
	Tab:CreateParagraph({
		Title = "Built-in settings",
		Content = "The gear on the window header opens theme, scale, title size, transparency, and keybind pages that Sempat ships with.",
	})
end

createElementsTab()
createWindowApiTab()
createPopupTab()
createVisibilityTab()
createAboutTab()

notify("StudioHub", "Gallery ready — press K to toggle")
print("[StudioHub] ready")
