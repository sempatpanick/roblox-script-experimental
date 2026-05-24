--[[
  Teleport tab module for Rayfield scripts.
  Loaded from: https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/tabs/teleport_tab.lua

  Usage:
    createTeleportTab(Window, mountNotify, options)

  options (optional table):
    ext = true                         -- Ext = true on UI elements
    notifyIcons = true                 -- pass Icon in mountNotify calls
    coordSectionTitle = "Teleport"     -- sawah_indo uses "Coordinates"
    flagsPrefix = "sumbing"            -- -> sumbing_tp_location, sumbing_tp_lookDirection, ...
    flags = { location = "...", ... }  -- explicit Rayfield flags (overrides prefix)
    walkToLocation = true              -- Humanoid:MoveTo button (expedition_antartica)
    playerSearch = true                -- Search on player dropdown
    playerNoneOption = true            -- "(None)" entry in player dropdown
    campTeleport = {                   -- optional camp section before players
      sectionTitle = "Teleport to Camp",
      mode = "dropdown" | "buttons",
      camps = { { name = "Camp 1", position = "x, y, z" } }  -- dropdown
           or { { label = "Camp 1", x = 0, y = 0, z = 0 } } -- buttons
    }
    afterCoords = function(teleportTab) end  -- game-specific UI (e.g. sawah object teleport)
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local function rayfieldDropdownFirst(valueOrTable)
    if type(valueOrTable) == "table" then
        return valueOrTable[1]
    end
    return valueOrTable
end

local function createTeleportTab(windowRef, notifyFn, options)
    options = options or {}
    local mountNotify = notifyFn

    local function tpNotify(title, content, icon)
        if options.notifyIcons then
            mountNotify({ Title = title, Content = content, Icon = icon or "check" })
        else
            mountNotify({ Title = title, Content = content })
        end
    end

    local function tpFlag(key)
        local flags = options.flags
        if type(flags) == "table" and type(flags[key]) == "string" and flags[key] ~= "" then
            return flags[key]
        end
        local prefix = options.flagsPrefix
        if type(prefix) ~= "string" or prefix == "" then
            return nil
        end
        local suffixMap = {
            location = "location",
            lookDirection = "lookDirection",
            tweenDuration = "tweenDuration",
            playerPick = "playerPick",
            getCurrentLocation = "getCurrentLocation",
            teleportCoords = "teleportCoords",
            tweenToLocation = "tweenToLocation",
        }
        local suffix = suffixMap[key] or key
        if key == "tweenDuration" and prefix == "mancing" then
            return prefix .. "_tp_tweenDurationSec"
        end
        return prefix .. "_tp_" .. suffix
    end

    local function withUiFlag(props, key)
        local flag = tpFlag(key)
        if flag then
            props.Flag = flag
        end
        return props
    end

    local function withExt(props)
        if options.ext then
            props.Ext = true
        end
        return props
    end

    local function parseNumberTriple(str)
        local s = (str or ""):gsub(",", " "):gsub("%s+", " ")
        local parts = {}
        for part in string.gmatch(s, "[%d%.%-]+") do
            table.insert(parts, tonumber(part))
        end
        return parts
    end

    local function parsePositionString(str)
        local parts = parseNumberTriple(str)
        if #parts < 3 then
            return nil
        end
        return Vector3.new(parts[1], parts[2], parts[3])
    end

    local function getLocalRootPart()
        local character = Players.LocalPlayer.Character
        return character and character:FindFirstChild("HumanoidRootPart")
    end

    local function getLocalCharacterParts()
        local character = Players.LocalPlayer.Character
        if not character then
            return nil, nil, nil
        end
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        return character, rootPart, humanoid
    end

    local function cframeFromInputs(posStr, lookStr)
        local posParts = parseNumberTriple(posStr)
        if #posParts < 3 then
            return nil
        end
        local pos = Vector3.new(posParts[1], posParts[2], posParts[3])
        local lookParts = parseNumberTriple(lookStr)
        if #lookParts < 3 then
            return CFrame.new(pos)
        end
        local dir = Vector3.new(lookParts[1], lookParts[2], lookParts[3])
        if dir.Magnitude < 1e-5 then
            return CFrame.new(pos)
        end
        return CFrame.lookAt(pos, pos + dir.Unit)
    end

    local TeleportTab = windowRef:CreateTab("Teleport", 4483362458)
    TeleportTab:CreateSection(options.coordSectionTitle or "Teleport")

    local teleportInputValue = ""
    local teleportLookInputValue = ""

    local TeleportInput = TeleportTab:CreateInput(withExt(withUiFlag({
        Name = "Location",
        PlaceholderText = "e.g. 100, 5, 200 or 100 5 200",
        CurrentValue = teleportInputValue,
        Callback = function(value)
            teleportInputValue = value
        end,
    }, "location")))

    local TeleportLookInput = TeleportTab:CreateInput(withExt(withUiFlag({
        Name = "Look direction",
        PlaceholderText = "e.g. 0, 0, -1 or leave empty for position only",
        CurrentValue = teleportLookInputValue,
        Callback = function(value)
            teleportLookInputValue = value
        end,
    }, "lookDirection")))

    TeleportTab:CreateButton(withExt(withUiFlag({
        Name = "Get Current Location",
        Callback = function()
            local rootPart = getLocalRootPart()
            if not rootPart then
                tpNotify("Teleport", "Character not loaded", "x")
                return
            end
            local pos = rootPart.Position
            local text = string.format("%.2f, %.2f, %.2f", pos.X, pos.Y, pos.Z)
            teleportInputValue = text
            if TeleportInput and TeleportInput.Set then
                TeleportInput:Set(text)
            elseif TeleportInput and TeleportInput.SetValue then
                TeleportInput:SetValue(text)
            end
            local look = rootPart.CFrame.LookVector
            local lookText = string.format("%.4f, %.4f, %.4f", look.X, look.Y, look.Z)
            teleportLookInputValue = lookText
            if TeleportLookInput and TeleportLookInput.Set then
                TeleportLookInput:Set(lookText)
            elseif TeleportLookInput and TeleportLookInput.SetValue then
                TeleportLookInput:SetValue(lookText)
            end
            tpNotify("Location", "Position: " .. text .. " · Look: " .. lookText)
        end,
    }, "getCurrentLocation")))

    TeleportTab:CreateButton(withExt(withUiFlag({
        Name = "Teleport",
        Callback = function()
            local rootPart = getLocalRootPart()
            if not rootPart then
                tpNotify("Teleport", "Character not loaded", "x")
                return
            end
            local cf = cframeFromInputs(teleportInputValue, teleportLookInputValue)
            if not cf then
                tpNotify("Teleport", "Enter position as X, Y, Z (e.g. 100, 5, 200)", "x")
                return
            end
            rootPart.CFrame = cf
            local p = cf.Position
            tpNotify("Teleport", string.format("Teleported to %.1f, %.1f, %.1f", p.X, p.Y, p.Z))
        end,
    }, "teleportCoords")))

    local tweenDurationValue = "5"
    TeleportTab:CreateInput(withExt(withUiFlag({
        Name = "Tween Duration",
        PlaceholderText = "e.g. 5",
        CurrentValue = tweenDurationValue,
        Callback = function(value)
            tweenDurationValue = value
        end,
    }, "tweenDuration")))

    TeleportTab:CreateButton(withExt(withUiFlag({
        Name = "Tween to Location",
        Callback = function()
            local rootPart = getLocalRootPart()
            if not rootPart then
                tpNotify("Teleport", "Character not loaded", "x")
                return
            end
            local targetCf = cframeFromInputs(teleportInputValue, teleportLookInputValue)
            if not targetCf then
                tpNotify("Teleport", "Enter position as X, Y, Z (e.g. 100, 5, 200)", "x")
                return
            end
            local duration = tonumber(tweenDurationValue) or 5
            if duration < 0.1 then
                duration = 0.1
            end
            local tweenInfo = TweenInfo.new(duration)
            local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = targetCf })
            tween:Play()
            local p = targetCf.Position
            tpNotify("Teleport", string.format("Tweening to %.1f, %.1f, %.1f (%.1fs)", p.X, p.Y, p.Z, duration))
        end,
    }, "tweenToLocation")))

    if options.walkToLocation then
        TeleportTab:CreateButton(withExt({
            Name = "Walk to Location",
            Callback = function()
                local _, rootPart, humanoid = getLocalCharacterParts()
                if not rootPart or not humanoid then
                    tpNotify("Teleport", "Character not loaded", "x")
                    return
                end
                local targetPos = parsePositionString(teleportInputValue)
                if not targetPos then
                    tpNotify("Teleport", "Enter position as X, Y, Z (e.g. 100, 5, 200)", "x")
                    return
                end
                humanoid:MoveTo(targetPos)
                tpNotify("Teleport", string.format("Walking to %.1f, %.1f, %.1f", targetPos.X, targetPos.Y, targetPos.Z))
            end,
        }))
    end

    if type(options.afterCoords) == "function" then
        options.afterCoords(TeleportTab)
    end

    local campCfg = options.campTeleport
    if type(campCfg) == "table" and type(campCfg.camps) == "table" and #campCfg.camps > 0 then
        TeleportTab:CreateSection(campCfg.sectionTitle or "Teleport to Camp")
        local mode = campCfg.mode or "buttons"

        if mode == "dropdown" then
            local campNames = {}
            for _, camp in ipairs(campCfg.camps) do
                table.insert(campNames, camp.name)
            end
            local selectedCamp = campNames[1]

            TeleportTab:CreateDropdown(withExt({
                Name = "Camp",
                Options = campNames,
                CurrentOption = { selectedCamp },
                Callback = function(opts)
                    local value = type(opts) == "table" and opts[1] or opts
                    selectedCamp = value
                end,
            }))

            TeleportTab:CreateButton(withExt({
                Name = "Teleport",
                Callback = function()
                    local rootPart = getLocalRootPart()
                    if not rootPart then
                        tpNotify("Teleport to Camp", "Character not loaded", "x")
                        return
                    end
                    if not selectedCamp then
                        tpNotify("Teleport to Camp", "Select a camp first", "x")
                        return
                    end
                    local posStr = nil
                    for _, camp in ipairs(campCfg.camps) do
                        if camp.name == selectedCamp then
                            posStr = camp.position
                            break
                        end
                    end
                    if not posStr then
                        tpNotify("Teleport to Camp", "Camp not found", "x")
                        return
                    end
                    local targetPos = parsePositionString(posStr)
                    if not targetPos then
                        tpNotify("Teleport to Camp", "Invalid position", "x")
                        return
                    end
                    rootPart.CFrame = CFrame.new(targetPos)
                    tpNotify("Teleport to Camp", "Teleported to " .. selectedCamp)
                end,
            }))
        else
            local function teleportToCampCoords(x, y, z, placeName)
                local rootPart = getLocalRootPart()
                if not rootPart then
                    tpNotify("Teleport", "Character not loaded", "x")
                    return
                end
                rootPart.CFrame = CFrame.new(x, y, z)
                tpNotify("Teleport", "Teleported to " .. placeName)
            end

            for _, loc in ipairs(campCfg.camps) do
                local label = loc.label or loc.name
                local cx, cy, cz = loc.x, loc.y, loc.z
                TeleportTab:CreateButton(withExt({
                    Name = label,
                    Callback = function()
                        teleportToCampCoords(cx, cy, cz, label)
                    end,
                }))
            end
        end
    end

    TeleportTab:CreateSection("Teleport to Players")

    local TELEPORT_PLAYER_NONE = "(None)"
    local playerDisplayNames = {}
    local playerList = {}
    local selectedTeleportPlayer = nil
    local PlayerTeleportDropdown

    local function teleportPlayerDropdownOptions()
        if not options.playerNoneOption then
            return playerDisplayNames
        end
        local opts = { TELEPORT_PLAYER_NONE }
        for _, n in ipairs(playerDisplayNames) do
            table.insert(opts, n)
        end
        return opts
    end

    local function refreshPlayerList(showNotify)
        playerList = {}
        playerDisplayNames = {}
        local localPlayer = Players.LocalPlayer
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.ClassName == "Player" then
                table.insert(playerList, player)
                table.insert(playerDisplayNames, player.DisplayName or player.Name)
            end
        end
        if PlayerTeleportDropdown and PlayerTeleportDropdown.Refresh then
            PlayerTeleportDropdown:Refresh(teleportPlayerDropdownOptions())
        end
        if selectedTeleportPlayer then
            if not table.find(playerList, selectedTeleportPlayer) then
                selectedTeleportPlayer = nil
                if PlayerTeleportDropdown and PlayerTeleportDropdown.Select then
                    PlayerTeleportDropdown:Select(nil)
                end
                if PlayerTeleportDropdown and PlayerTeleportDropdown.Set then
                    if options.playerNoneOption then
                        PlayerTeleportDropdown:Set(TELEPORT_PLAYER_NONE)
                    else
                        PlayerTeleportDropdown:Set({})
                    end
                end
            end
        end
        if showNotify then
            tpNotify("Teleport", "Player list refreshed (" .. #playerList .. " players)")
        end
    end

    local dropdownProps = withExt(withUiFlag({
        Name = "Player",
        Options = teleportPlayerDropdownOptions(),
        CurrentOption = options.playerNoneOption and { TELEPORT_PLAYER_NONE } or {},
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            selectedTeleportPlayer = nil
            if options.playerNoneOption then
                if picked and picked ~= TELEPORT_PLAYER_NONE then
                    local idx = table.find(playerDisplayNames, picked)
                    if idx and playerList[idx] then
                        selectedTeleportPlayer = playerList[idx]
                    end
                end
            elseif picked then
                local idx = table.find(playerDisplayNames, picked)
                if idx and playerList[idx] then
                    selectedTeleportPlayer = playerList[idx]
                end
            end
        end,
    }, "playerPick"))

    if options.playerSearch then
        dropdownProps.Search = true
    end

    PlayerTeleportDropdown = TeleportTab:CreateDropdown(dropdownProps)

    TeleportTab:CreateButton(withExt({
        Name = "Refresh",
        Callback = function()
            refreshPlayerList(true)
        end,
    }))

    TeleportTab:CreateButton(withExt({
        Name = "Teleport",
        Callback = function()
            if not selectedTeleportPlayer then
                tpNotify("Teleport", "Select a player first", "x")
                return
            end
            local rootPart = getLocalRootPart()
            if not rootPart then
                tpNotify("Teleport", "Character not loaded", "x")
                return
            end
            local targetChar = selectedTeleportPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then
                tpNotify("Teleport", "Target player has no character", "x")
                return
            end
            rootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0, 3))
            tpNotify(
                "Teleport",
                "Teleported to " .. (selectedTeleportPlayer.DisplayName or selectedTeleportPlayer.Name)
            )
        end,
    }))
end

return createTeleportTab
