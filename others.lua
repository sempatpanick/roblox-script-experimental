local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local RayfieldLibrary

do
    local ok, result = pcall(function()
        return require("./rayfield_library")
    end)

    if ok then
        RayfieldLibrary = result
    else
        if cloneref(RunService):IsStudio() then
            RayfieldLibrary = require(cloneref(ReplicatedStorage):WaitForChild("rayfield_library"))
        else
            RayfieldLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/rayfield_library.lua"))()
        end
    end
end

local function mountNotify(opts)
    local img
    local ic = opts.Icon
    if ic == "check" then
        img = 4483362748
    elseif ic == "x" or ic == "close" then
        img = 4384402990
    end
    RayfieldLibrary:Notify({
        Title = opts.Title,
        Content = opts.Content,
        Image = img,
        Duration = opts.Duration or 4,
    })
end

local function rayfieldDropdownFirst(valueOrTable)
    if type(valueOrTable) == "table" then
        return valueOrTable[1]
    end
    return valueOrTable
end

-- */  Recording Tab (module)  /* --
local RECORDING_TAB_REPO = "https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/tabs/recording_tab.lua"
local function loadCreateRecordingTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("./tabs/recording_tab")
    end)
    if okReq and type(mod) == "function" then
        return mod
    end

    local okHttp, source = pcall(function()
        return game:HttpGet(repoUrl)
    end)
    if not okHttp or type(source) ~= "string" or #source < 64 then
        warn("[Recording Tab] HttpGet failed:", tostring(source))
        return nil
    end

    local chunk, compileErr
    if type(load) == "function" then
        local okLoad
        okLoad, chunk = pcall(function()
            return load(source, "recording_tab")
        end)
        if not okLoad then
            compileErr = chunk
            chunk = nil
        end
    end
    if type(chunk) ~= "function" and type(loadstring) == "function" then
        chunk, compileErr = loadstring(source)
    end
    if type(chunk) ~= "function" then
        warn("[Recording Tab] compile failed:", tostring(compileErr))
        return nil
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        warn("[Recording Tab] module execute failed:", tostring(result))
        return nil
    end
    if type(result) ~= "function" then
        warn("[Recording Tab] module must return a function, got", type(result))
        return nil
    end
    return result
end

local createRecordingTab = loadCreateRecordingTab(RECORDING_TAB_REPO)
if not createRecordingTab then
    createRecordingTab = function(_windowRef, notifyFn, _recordingsDir)
        notifyFn({ Title = "Recording", Content = "Failed to load recording tab module", Icon = "x" })
    end
end

-- */  Local Player Tab (module)  /* --

local LOCAL_PLAYER_TAB_REPO = "https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main/tabs/local_player_tab.lua"

local function loadCreateLocalPlayerTab(repoUrl)

    local okReq, mod = pcall(function()

        return require("./tabs/local_player_tab")

    end)

    if okReq and type(mod) == "function" then

        return mod

    end



    local okHttp, source = pcall(function()

        return game:HttpGet(repoUrl)

    end)

    if not okHttp or type(source) ~= "string" or #source < 64 then

        warn("[Local Player Tab] HttpGet failed:", tostring(source))

        return nil

    end



    local chunk, compileErr

    if type(load) == "function" then

        local okLoad

        okLoad, chunk = pcall(function()

            return load(source, "local_player_tab")

        end)

        if not okLoad then

            compileErr = chunk

            chunk = nil

        end

    end

    if type(chunk) ~= "function" and type(loadstring) == "function" then

        chunk, compileErr = loadstring(source)

    end

    if type(chunk) ~= "function" then

        warn("[Local Player Tab] compile failed:", tostring(compileErr))

        return nil

    end



    local okRun, result = pcall(chunk)

    if not okRun then

        warn("[Local Player Tab] module execute failed:", tostring(result))

        return nil

    end

    if type(result) ~= "function" then

        warn("[Local Player Tab] module must return a function, got", type(result))

        return nil

    end

    return result

end



local createLocalPlayerTab = loadCreateLocalPlayerTab(LOCAL_PLAYER_TAB_REPO)

if not createLocalPlayerTab then

    createLocalPlayerTab = function(_windowRef, notifyFn, _options)

        notifyFn({ Title = "Local Player", Content = "Failed to load local player tab module", Icon = "x" })

    end

end


-- */  Window  /* --
local Window = RayfieldLibrary:CreateWindow({
    Name = "sempatpanick | Others",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Others",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "sempatpanick",
        FileName = "others",
    },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
})

-- */  Window  /* --
-- */  Global: format any Luau value for inspector text (Instance uses Name, same as ValueBase lines in formatInstanceDisplay)  /* --
function formatValueForDisplay(val)
    if val == nil then
        return "nil"
    end
    if typeof(val) == "Instance" then
        return val.Name or tostring(val)
    end
    return tostring(val)
end

-- */  Text from TextLabel / TextButton / TextBox for inspector lines (truncated, single-line)  /* --
function formatGuiInstanceTextForDisplay(inst)
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

-- */  Global: format instance for display (Key = Value); isShowDataType == false => Name = Value only; isShowLocation => show Position for BaseParts  /* --
function formatInstanceDisplay(inst, isShowDataType, isShowLocation)
    if isShowDataType == false then
        local ok, val = pcall(function() return inst.Value end)
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
    local ok, val = pcall(function() return inst.Value end)
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

-- */  Local Player Tab  /* --
createLocalPlayerTab(Window, mountNotify)

-- */  Teleport Tab  /* --
do
    local TeleportTab = Window:CreateTab("Teleport", 4483362458)

    TeleportTab:CreateSection("Teleport")
    local teleportInputValue = ""
    local teleportLookInputValue = ""

    local function teleportParseNumberTriple(str)
        local s = str:gsub(",", " "):gsub("%s+", " ")
        local parts = {}
        for part in string.gmatch(s, "[%d%.%-]+") do
            table.insert(parts, tonumber(part))
        end
        return parts
    end

    local function teleportCFrameFromInputs(posStr, lookStr)
        local posParts = teleportParseNumberTriple(posStr)
        if #posParts < 3 then
            return nil
        end
        local pos = Vector3.new(posParts[1], posParts[2], posParts[3])
        local lookParts = teleportParseNumberTriple(lookStr)
        if #lookParts < 3 then
            return CFrame.new(pos)
        end
        local dir = Vector3.new(lookParts[1], lookParts[2], lookParts[3])
        if dir.Magnitude < 1e-5 then
            return CFrame.new(pos)
        end
        return CFrame.lookAt(pos, pos + dir.Unit)
    end

    local TeleportInput = TeleportTab:CreateInput({
        Name = "Location",
        PlaceholderText = "e.g. 100, 5, 200 or 100 5 200",
        Flag = "others_tp_location",
        CurrentValue = teleportInputValue,
        Callback = function(value)
            teleportInputValue = value
        end,
    })

    local TeleportLookInput = TeleportTab:CreateInput({
        Name = "Look direction",
        PlaceholderText = "e.g. 0, 0, -1 or leave empty for position only",
        Flag = "others_tp_lookDirection",
        CurrentValue = teleportLookInputValue,
        Callback = function(value)
            teleportLookInputValue = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Get Current Location",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
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
            mountNotify({
                Title = "Location",
                Content = "Position: " .. text .. " · Look: " .. lookText,
            })
        end,
    })
    TeleportTab:CreateButton({
        Name = "Teleport",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
                return
            end
            local cf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not cf then
                mountNotify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                })
                return
            end
            rootPart.CFrame = cf
            local p = cf.Position
            mountNotify({
                Title = "Teleport",
                Content = string.format("Teleported to %.1f, %.1f, %.1f", p.X, p.Y, p.Z),
            })
        end,
    })
    local tweenDurationValue = "5"
    TeleportTab:CreateInput({
        Name = "Tween Duration",
        PlaceholderText = "e.g. 5",
        CurrentValue = tweenDurationValue,
        Callback = function(value)
            tweenDurationValue = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Tween to Location",
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
                return
            end
            local targetCf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not targetCf then
                mountNotify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                })
                return
            end
            local duration = tonumber(tweenDurationValue) or 5
            if duration < 0.1 then duration = 0.1 end
            local tweenInfo = TweenInfo.new(duration)
            local tween = TweenService:Create(rootPart, tweenInfo, { CFrame = targetCf })
            tween:Play()
            local p = targetCf.Position
            mountNotify({
                Title = "Teleport",
                Content = string.format("Tweening to %.1f, %.1f, %.1f (%.1fs)", p.X, p.Y, p.Z, duration),
            })
        end,
    })

    -- */  Teleport to Players  /* --
    TeleportTab:CreateSection("Teleport to Players")
    local playerDisplayNames = {}
    local playerList = {}
    local selectedTeleportPlayer = nil
    local PlayerTeleportDropdown

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
            PlayerTeleportDropdown:Refresh(playerDisplayNames)
        end
        if selectedTeleportPlayer then
            if not table.find(playerList, selectedTeleportPlayer) then
                selectedTeleportPlayer = nil
                if PlayerTeleportDropdown and PlayerTeleportDropdown.Select then PlayerTeleportDropdown:Select(nil) end
                if PlayerTeleportDropdown and PlayerTeleportDropdown.Set then PlayerTeleportDropdown:Set({}) end
            end
        end
        if showNotify then
            mountNotify({ Title = "Teleport", Content = "Player list refreshed (" .. #playerList .. " players)" })
        end
    end

    PlayerTeleportDropdown = TeleportTab:CreateDropdown({
        Name = "Player",
        Options = playerDisplayNames,
        CurrentOption = {},
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            selectedTeleportPlayer = nil
            if picked then
                local idx = table.find(playerDisplayNames, picked)
                if idx and playerList[idx] then
                    selectedTeleportPlayer = playerList[idx]
                end
            end
        end
    })

    TeleportTab:CreateButton({
        Name = "Refresh",
        Callback = function()
            refreshPlayerList(true)
        end
    })
    TeleportTab:CreateButton({
        Name = "Teleport",
        Callback = function()
            if not selectedTeleportPlayer then
                mountNotify({ Title = "Teleport", Content = "Select a player first" })
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded" })
                return
            end
            local targetChar = selectedTeleportPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then
                mountNotify({ Title = "Teleport", Content = "Target player has no character" })
                return
            end
            rootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0, 3))
            mountNotify({ Title = "Teleport", Content = "Teleported to " .. (selectedTeleportPlayer.DisplayName or selectedTeleportPlayer.Name) })
        end
    })
end

-- */  Objects Tab  /* --
do
    local ObjectsTab = Window:CreateTab("Objects", 4483362458)

    -- Nested tree: only under Instance types selected in Show Children (see section at top of this tab).
    local OBJECTS_TREE_MAX_DEPTH = 14
    local OBJECTS_TREE_MAX_LINES = 3000
    -- WindUI / Roblox TextLabel can clip very long descriptions; split across extra Paragraphs.
    local OBJECTS_CHILDREN_DESC_MAX_CHARS = 4000
    local OBJECTS_CHILDREN_PARAGRAPH_DESC = "Nested under the types you enable in Show Children (name sort; max depth "
        .. OBJECTS_TREE_MAX_DEPTH
        .. ", max "
        .. OBJECTS_TREE_MAX_LINES
        .. " lines). Long output splits into extra paragraphs (~"
        .. OBJECTS_CHILDREN_DESC_MAX_CHARS
        .. " chars each)."

    -- Multi-select: which ClassNames recurse when listing children (IsA match).
    local OBJECTS_NEST_CLASS_OPTIONS: { string } = {
        "Accessory",
        "Actor",
        "Attachment",
        "Backpack",
        "BillboardGui",
        "BodyColors",
        "Camera",
        "CanvasGroup",
        "Configuration",
        "CornerWedgePart",
        "Folder",
        "Frame",
        "Humanoid",
        "ImageButton",
        "ImageLabel",
        "MeshPart",
        "Model",
        "ModuleScript",
        "Part",
        "PlayerGui",
        "ProximityPrompt",
        "ScreenGui",
        "ScrollingFrame",
        "StarterGear",
        "StarterPack",
        "SurfaceGui",
        "Terrain",
        "TextBox",
        "TextButton",
        "TextLabel",
        "Tool",
        "TrussPart",
        "UnionOperation",
        "VehicleSeat",
        "WedgePart",
    }
    local OBJECTS_NEST_EXPAND_DEFAULT: { string } = {
        "Backpack",
        "BillboardGui",
        "Frame",
        "Folder",
        "PlayerGui",
        "ScreenGui",
    }
    local objectsNestExpandClassSet: { [string]: boolean } = {}

    local function syncObjectsNestExpandClassSetFromDropdownValue(value: any)
        local s: { [string]: boolean } = {}
        if type(value) == "table" then
            for _, item in ipairs(value) do
                local name = (type(item) == "table" and item.Title) or item
                if type(name) == "string" and name ~= "" then
                    s[name] = true
                end
            end
        elseif type(value) == "string" and value ~= "" then
            s[value] = true
        end
        objectsNestExpandClassSet = s
    end

    syncObjectsNestExpandClassSetFromDropdownValue(OBJECTS_NEST_EXPAND_DEFAULT)
    local OBJECTS_NONE = "(None)"
    local NESTED_CHILDREN_TITLE = "Children (nested)"

    local function objectDropdownOptions(items)
        local o = { OBJECTS_NONE }
        for _, x in ipairs(items) do
            table.insert(o, x)
        end
        return o
    end


    local function splitStringForParagraphChunks(s: string, maxChunk: number): { string }
        if maxChunk < 256 then
            maxChunk = 256
        end
        if s == nil or s == "" then
            return { "" }
        end
        if #s <= maxChunk then
            return { s }
        end
        local chunks: { string } = {}
        local pos = 1
        local n = #s
        while pos <= n do
            local endPos = math.min(pos + maxChunk - 1, n)
            if endPos < n then
                local searchStart = math.max(pos, endPos - 500)
                local cut = 0
                for i = endPos, searchStart, -1 do
                    if string.byte(s, i) == 10 then
                        cut = i
                        break
                    end
                end
                if cut > pos then
                    endPos = cut
                end
            end
            table.insert(chunks, string.sub(s, pos, endPos))
            pos = endPos + 1
        end
        if #chunks == 0 then
            return { s }
        end
        return chunks
    end

    local function clearObjectsTabOverflowParagraphs(refs: { any })
        for i = #refs, 1, -1 do
            local p = refs[i]
            if p then
                pcall(function()
                    if type(p.Destroy) == "function" then
                        p:Destroy()
                    end
                end)
            end
            table.remove(refs, i)
        end
    end

    local function setNestedChildrenParagraphsWithOverflow(
        section,
        primaryParagraph,
        overflowParagraphRefs: { any },
        text: string?,
        continuationTitleBase: string,
        emptyPlaceholder: string
    )
        clearObjectsTabOverflowParagraphs(overflowParagraphRefs)
        if not (primaryParagraph and primaryParagraph.Set) then
            return
        end
        local body = (text and text ~= "") and text or emptyPlaceholder
        local chunks = splitStringForParagraphChunks(body, OBJECTS_CHILDREN_DESC_MAX_CHARS)
        primaryParagraph:Set({
            Title = continuationTitleBase,
            Content = chunks[1] or body,
        })
        for ci = 2, #chunks do
            local newP = section:CreateParagraph({
                Title = continuationTitleBase .. " (part " .. tostring(ci) .. ")",
                Content = chunks[ci],
            })
            table.insert(overflowParagraphRefs, newP)
        end
    end

    local function shouldNestChildrenInObjectsTree(inst: Instance): boolean
        if next(objectsNestExpandClassSet) == nil then
            return false
        end
        for className, _ in pairs(objectsNestExpandClassSet) do
            if inst:IsA(className) then
                return true
            end
        end
        return false
    end

    local function buildNestedObjectChildrenListText(root: Instance): string
        local lines = {}

        local function appendChildren(parent: Instance, depth: number, indentStr: string)
            if #lines >= OBJECTS_TREE_MAX_LINES or depth >= OBJECTS_TREE_MAX_DEPTH then
                return
            end
            local children = parent:GetChildren()
            table.sort(children, function(a, b)
                return string.lower(a.Name) < string.lower(b.Name)
            end)
            for _, child in ipairs(children) do
                if #lines >= OBJECTS_TREE_MAX_LINES then
                    table.insert(lines, indentStr .. "... (truncated, max " .. OBJECTS_TREE_MAX_LINES .. " lines)")
                    return
                end
                table.insert(lines, indentStr .. formatInstanceDisplay(child, nil, true))
                local sub = child:GetChildren()
                if #sub > 0 and shouldNestChildrenInObjectsTree(child) then
                    if depth + 1 < OBJECTS_TREE_MAX_DEPTH then
                        appendChildren(child, depth + 1, indentStr .. "  ")
                    else
                        table.insert(lines, indentStr .. "  ... (" .. #sub .. " children, max depth " .. OBJECTS_TREE_MAX_DEPTH .. ")")
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

    -- WindUI passes the selected entry from Values as-is. Duplicate display strings
    -- would collide on a string-keyed map and break selection; use { Title, Instance }.
    local function buildObjectsServiceDropdownValues(children: { Instance }): { any }
        local displayCounts: { [string]: number } = {}
        local values: { any } = {}
        for _, child in ipairs(children) do
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

    local function buildInstancePathUnderAncestor(inst: Instance, ancestor: Instance): string
        if not ancestor or not inst then
            return inst and inst.Name or ""
        end
        if not inst:IsDescendantOf(ancestor) then
            return inst.Name
        end
        local parts = {}
        local cur: Instance? = inst
        while cur and cur ~= ancestor do
            table.insert(parts, 1, cur.Name)
            cur = cur.Parent
        end
        return table.concat(parts, ".")
    end

    local function runObjectsTabFindInstanceByName(
        root: Instance?,
        primaryParagraph: any,
        overflowParagraphRefs: { any },
        emptyPlaceholder: string,
        queryRaw: string,
        underDescription: string
    )
        if not root then
            mountNotify({ Title = underDescription, Content = "Root not available.", Icon = "x" })
            return
        end
        local raw = tostring(queryRaw or "")
        local q = string.gsub(string.gsub(raw, "^%s+", ""), "%s+$", "")
        if q == "" then
            mountNotify({
                Title = "Find (" .. underDescription .. ")",
                Content = "Enter text to match Instance.Name.",
                Icon = "x",
            })
            return
        end
        local ql = string.lower(q)
        local matches: { Instance } = {}
        for _, d in ipairs(root:GetDescendants()) do
            if string.find(string.lower(d.Name), ql, 1, true) then
                table.insert(matches, d)
            end
        end
        table.sort(matches, function(a, b)
            return string.lower(buildInstancePathUnderAncestor(a, root))
                < string.lower(buildInstancePathUnderAncestor(b, root))
        end)
        if #matches == 0 then
            setNestedChildrenParagraphsWithOverflow(
                ObjectsTab,
                primaryParagraph,
                overflowParagraphRefs,
                "No matches for \"" .. q .. "\" under " .. underDescription .. ".",
                NESTED_CHILDREN_TITLE,
                emptyPlaceholder
            )
            mountNotify({
                Title = "Find (" .. underDescription .. ")",
                Content = "No matching instances.",
                Icon = "x",
            })
            return
        end
        local pathLines: { string } = {}
        for _, m in ipairs(matches) do
            table.insert(pathLines, buildInstancePathUnderAncestor(m, root))
        end
        local pathsBlock = (#matches == 1) and ("Found:\n" .. pathLines[1])
            or ("Matches (" .. tostring(#matches) .. "):\n" .. table.concat(pathLines, "\n"))
        local target = matches[1]
        local tree = buildNestedObjectChildrenListText(target)
        local note = (#matches > 1) and "\n\n(Showing nested children for the first match; narrow the name to disambiguate.)\n\n" or "\n\n"
        local combined = pathsBlock .. note .. tree
        setNestedChildrenParagraphsWithOverflow(
            ObjectsTab,
            primaryParagraph,
            overflowParagraphRefs,
            combined,
            NESTED_CHILDREN_TITLE,
            emptyPlaceholder
        )
        mountNotify({
            Title = "Find (" .. underDescription .. ")",
            Content = (#matches == 1) and "1 match."
                or (tostring(#matches) .. " matches; nested tree is for the first."),
            Icon = "check",
        })
    end

    ObjectsTab:CreateSection("Show Children")
    local ObjectsNestClassesDropdown
    do
        local nestDefaultCopy: { string } = {}
        for _, v in ipairs(OBJECTS_NEST_EXPAND_DEFAULT) do
            table.insert(nestDefaultCopy, v)
        end
        ObjectsNestClassesDropdown = ObjectsTab:CreateDropdown({
            Name = "Types to expand in nested tree",
            Options = OBJECTS_NEST_CLASS_OPTIONS,
            CurrentOption = nestDefaultCopy,
            MultipleOptions = true, Search = true, Ext = true,
            Callback = function(value)
                syncObjectsNestExpandClassSetFromDropdownValue(value)
            end,
        })
    end
    if ObjectsNestClassesDropdown and ObjectsNestClassesDropdown.Value ~= nil then
        syncObjectsNestExpandClassSetFromDropdownValue(ObjectsNestClassesDropdown.Value)
    end
    ObjectsTab:CreateParagraph({
        Title = "Why some rows have no nested lines",
        Content = "Indented children only continue under ClassNames enabled in the dropdown (IsA match). Defaults include Frame and ScreenGui but not ImageLabel or ImageButton, so those nodes appear as one line until you enable those types—on purpose, so large PlayerGui dumps stay smaller.",
    })
    ObjectsTab:CreateSection("ReplicatedStorage")
    local ReplicatedStorageDropdown
    local ReplicatedStorageChildrenParagraph
    local rsChildrenOverflowParagraphs = {}
    local rsFindByNameQuery = ""

    local rsTitleList = {}
    local rsTitleToInstance = {}

    local function refreshReplicatedStorageList()
        local rows = buildObjectsServiceDropdownValues(ReplicatedStorage:GetChildren())
        rsTitleList = {}
        rsTitleToInstance = {}
        for _, row in ipairs(rows) do
            table.insert(rsTitleList, row.Title)
            rsTitleToInstance[row.Title] = row.Instance
        end
        if ReplicatedStorageDropdown and ReplicatedStorageDropdown.Refresh then
            ReplicatedStorageDropdown:Refresh(objectDropdownOptions(rsTitleList))
        end
        mountNotify({ Title = "ReplicatedStorage", Content = "Listed " .. #rsTitleList .. " objects", Icon = "check" })
    end

    ReplicatedStorageDropdown = ObjectsTab:CreateDropdown({
        Name = "ReplicatedStorage (key = value)",
        Options = objectDropdownOptions(rsTitleList),
        CurrentOption = { OBJECTS_NONE },
        Search = true,
        Ext = true,
        Callback = function(opts)
            local selectedDisplay = type(opts) == "table" and opts[1] or opts
            if not selectedDisplay or selectedDisplay == OBJECTS_NONE then
                setNestedChildrenParagraphsWithOverflow(
                    ObjectsTab,
                    ReplicatedStorageChildrenParagraph,
                    rsChildrenOverflowParagraphs,
                    nil,
                    NESTED_CHILDREN_TITLE,
                    "Select an object above to list its children"
                )
                return
            end
            local inst = rsTitleToInstance[selectedDisplay]
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                ObjectsTab,
                ReplicatedStorageChildrenParagraph,
                rsChildrenOverflowParagraphs,
                text,
                NESTED_CHILDREN_TITLE,
                "Select an object above to list its children"
            )
        end,
    })

    ReplicatedStorageChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = NESTED_CHILDREN_TITLE,
        Content = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Ext = true,
        Callback = function()
            refreshReplicatedStorageList()
        end,
    })

    ObjectsTab:CreateInput({
        Name = "Find instance by name (under ReplicatedStorage)",
        PlaceholderText = "Substring match on Instance.Name",
        Ext = true,
        CurrentValue = rsFindByNameQuery,
        Callback = function(value)
            rsFindByNameQuery = value
        end,
    })

    ObjectsTab:CreateButton({
        Name = "Find",
        Ext = true,
        Callback = function()
            runObjectsTabFindInstanceByName(
                ReplicatedStorage,
                ReplicatedStorageChildrenParagraph,
                rsChildrenOverflowParagraphs,
                "Select an object above to list its children",
                rsFindByNameQuery,
                "ReplicatedStorage"
            )
        end,
    })

    ObjectsTab:CreateSection("Players")
    local PlayersServiceDropdown
    local PlayersServiceChildrenParagraph
    local plrsChildrenOverflowParagraphs = {}
    local plrsFindByNameQuery = ""

    local plrsTitleList = {}
    local plrsTitleToInstance = {}

    local function refreshPlayersServiceList()
        local rows = buildObjectsServiceDropdownValues(Players:GetChildren())
        plrsTitleList = {}
        plrsTitleToInstance = {}
        for _, row in ipairs(rows) do
            table.insert(plrsTitleList, row.Title)
            plrsTitleToInstance[row.Title] = row.Instance
        end
        if PlayersServiceDropdown and PlayersServiceDropdown.Refresh then
            PlayersServiceDropdown:Refresh(objectDropdownOptions(plrsTitleList))
        end
        mountNotify({ Title = "Players", Content = "Listed " .. #plrsTitleList .. " players", Icon = "check" })
    end

    PlayersServiceDropdown = ObjectsTab:CreateDropdown({
        Name = "Players (key = value)",
        Options = objectDropdownOptions(plrsTitleList),
        CurrentOption = { OBJECTS_NONE },
        Search = true,
        Ext = true,
        Callback = function(opts)
            local selectedDisplay = type(opts) == "table" and opts[1] or opts
            if not selectedDisplay or selectedDisplay == OBJECTS_NONE then
                setNestedChildrenParagraphsWithOverflow(
                    ObjectsTab,
                    PlayersServiceChildrenParagraph,
                    plrsChildrenOverflowParagraphs,
                    nil,
                    NESTED_CHILDREN_TITLE,
                    "Select a player above to list their children"
                )
                return
            end
            local inst = plrsTitleToInstance[selectedDisplay]
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                ObjectsTab,
                PlayersServiceChildrenParagraph,
                plrsChildrenOverflowParagraphs,
                text,
                NESTED_CHILDREN_TITLE,
                "Select a player above to list their children"
            )
        end,
    })

    PlayersServiceChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = NESTED_CHILDREN_TITLE,
        Content = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Ext = true,
        Callback = function()
            refreshPlayersServiceList()
        end,
    })

    ObjectsTab:CreateInput({
        Name = "Find instance by name (under Players)",
        PlaceholderText = "Substring match on Instance.Name",
        Ext = true,
        CurrentValue = plrsFindByNameQuery,
        Callback = function(value)
            plrsFindByNameQuery = value
        end,
    })

    ObjectsTab:CreateButton({
        Name = "Find",
        Ext = true,
        Callback = function()
            runObjectsTabFindInstanceByName(
                Players,
                PlayersServiceChildrenParagraph,
                plrsChildrenOverflowParagraphs,
                "Select a player above to list their children",
                plrsFindByNameQuery,
                "Players"
            )
        end,
    })

    ObjectsTab:CreateSection("Local Player")
    local LocalPlayerDropdown
    local LocalPlayerChildrenParagraph
    local lpChildrenOverflowParagraphs = {}
    local localPlayerFindByNameQuery = ""

    local lpTitleList = {}
    local lpTitleToInstance = {}

    local function refreshLocalPlayerList()
        local localPlayer = Players.LocalPlayer
        local rows = buildObjectsServiceDropdownValues(localPlayer:GetChildren())
        lpTitleList = {}
        lpTitleToInstance = {}
        for _, row in ipairs(rows) do
            table.insert(lpTitleList, row.Title)
            lpTitleToInstance[row.Title] = row.Instance
        end
        if LocalPlayerDropdown and LocalPlayerDropdown.Refresh then
            LocalPlayerDropdown:Refresh(objectDropdownOptions(lpTitleList))
        end
        mountNotify({ Title = "Local Player", Content = "Listed " .. #lpTitleList .. " objects", Icon = "check" })
    end

    LocalPlayerDropdown = ObjectsTab:CreateDropdown({
        Name = "Local Player (key = value)",
        Options = objectDropdownOptions(lpTitleList),
        CurrentOption = { OBJECTS_NONE },
        Search = true,
        Ext = true,
        Callback = function(opts)
            local selectedDisplay = type(opts) == "table" and opts[1] or opts
            if not selectedDisplay or selectedDisplay == OBJECTS_NONE then
                setNestedChildrenParagraphsWithOverflow(
                    ObjectsTab,
                    LocalPlayerChildrenParagraph,
                    lpChildrenOverflowParagraphs,
                    nil,
                    NESTED_CHILDREN_TITLE,
                    "Select an object above to list its children"
                )
                return
            end
            local inst = lpTitleToInstance[selectedDisplay]
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                ObjectsTab,
                LocalPlayerChildrenParagraph,
                lpChildrenOverflowParagraphs,
                text,
                NESTED_CHILDREN_TITLE,
                "Select an object above to list its children"
            )
        end,
    })

    LocalPlayerChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = NESTED_CHILDREN_TITLE,
        Content = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Ext = true,
        Callback = function()
            refreshLocalPlayerList()
        end,
    })

    ObjectsTab:CreateInput({
        Name = "Find instance by name (under LocalPlayer)",
        PlaceholderText = "Substring match on Instance.Name",
        Ext = true,
        CurrentValue = localPlayerFindByNameQuery,
        Callback = function(value)
            localPlayerFindByNameQuery = value
        end,
    })

    ObjectsTab:CreateButton({
        Name = "Find",
        Ext = true,
        Callback = function()
            runObjectsTabFindInstanceByName(
                Players.LocalPlayer,
                LocalPlayerChildrenParagraph,
                lpChildrenOverflowParagraphs,
                "Select an object above to list its children",
                localPlayerFindByNameQuery,
                "LocalPlayer"
            )
        end,
    })

    ObjectsTab:CreateSection("Workspace")
    local WorkspaceDropdown
    local WorkspaceChildrenParagraph
    local wsChildrenOverflowParagraphs = {}
    local wsFindByNameQuery = ""

    local wsTitleList = {}
    local wsTitleToInstance = {}

    local function refreshWorkspaceList()
        local rows = buildObjectsServiceDropdownValues(Workspace:GetChildren())
        wsTitleList = {}
        wsTitleToInstance = {}
        for _, row in ipairs(rows) do
            table.insert(wsTitleList, row.Title)
            wsTitleToInstance[row.Title] = row.Instance
        end
        if WorkspaceDropdown and WorkspaceDropdown.Refresh then
            WorkspaceDropdown:Refresh(objectDropdownOptions(wsTitleList))
        end
        mountNotify({ Title = "Workspace", Content = "Listed " .. #wsTitleList .. " objects", Icon = "check" })
    end

    WorkspaceDropdown = ObjectsTab:CreateDropdown({
        Name = "Workspace (key = value)",
        Options = objectDropdownOptions(wsTitleList),
        CurrentOption = { OBJECTS_NONE },
        Search = true,
        Ext = true,
        Callback = function(opts)
            local selectedDisplay = type(opts) == "table" and opts[1] or opts
            if not selectedDisplay or selectedDisplay == OBJECTS_NONE then
                setNestedChildrenParagraphsWithOverflow(
                    ObjectsTab,
                    WorkspaceChildrenParagraph,
                    wsChildrenOverflowParagraphs,
                    nil,
                    NESTED_CHILDREN_TITLE,
                    "Select an object above to list its children"
                )
                return
            end
            local inst = wsTitleToInstance[selectedDisplay]
            if not inst then
                return
            end
            local text = buildNestedObjectChildrenListText(inst)
            setNestedChildrenParagraphsWithOverflow(
                ObjectsTab,
                WorkspaceChildrenParagraph,
                wsChildrenOverflowParagraphs,
                text,
                NESTED_CHILDREN_TITLE,
                "Select an object above to list its children"
            )
        end,
    })

    WorkspaceChildrenParagraph = ObjectsTab:CreateParagraph({
        Title = NESTED_CHILDREN_TITLE,
        Content = OBJECTS_CHILDREN_PARAGRAPH_DESC,
    })

    ObjectsTab:CreateButton({
        Name = "Refresh",
        Ext = true,
        Callback = function()
            refreshWorkspaceList()
        end,
    })

    ObjectsTab:CreateInput({
        Name = "Find instance by name (under Workspace)",
        PlaceholderText = "Substring match on Instance.Name",
        Ext = true,
        CurrentValue = wsFindByNameQuery,
        Callback = function(value)
            wsFindByNameQuery = value
        end,
    })

    ObjectsTab:CreateButton({
        Name = "Find",
        Ext = true,
        Callback = function()
            runObjectsTabFindInstanceByName(
                Workspace,
                WorkspaceChildrenParagraph,
                wsChildrenOverflowParagraphs,
                "Select an object above to list its children",
                wsFindByNameQuery,
                "Workspace"
            )
        end,
    })

    ObjectsTab:CreateButton({
        Name = "Clear overflow paragraphs",
        Ext = true,
        Callback = function()
            clearObjectsTabOverflowParagraphs(rsChildrenOverflowParagraphs)
            clearObjectsTabOverflowParagraphs(plrsChildrenOverflowParagraphs)
            clearObjectsTabOverflowParagraphs(lpChildrenOverflowParagraphs)
            clearObjectsTabOverflowParagraphs(wsChildrenOverflowParagraphs)
            mountNotify({ Title = "Objects", Content = "Removed extra child-list paragraphs (part 2+).", Icon = "check" })
        end,
    })

end

createRecordingTab(Window, mountNotify, "sempatpanick/others/recordings")


-- */  Avatar Tab  /* --
do
    local AvatarTab = Window:CreateTab("Avatar", 7076763398)

    AvatarTab:CreateSection("Look Up Player")

    local avatarLookupInputValue = ""
    local AvatarLookupInput = AvatarTab:CreateInput({
        Name = "Username / Player Id",
        PlaceholderText = "e.g. Roblox or 261",
        Ext = true,
        CurrentValue = avatarLookupInputValue,
        Callback = function(value)
            avatarLookupInputValue = value
        end,
    })

    local AvatarPreviewImage
    local AvatarDetailsParagraph
    local AvatarOutfitParagraph
    local lastAvatarLookupUserId: number? = nil
    local activeAvatarOverlayModel: Model? = nil
    local activeAvatarOverlayRenderConn: RBXScriptConnection? = nil

    local function trimLookupText(s: string): string
        local t = string.gsub(s or "", "^%s+", "")
        t = string.gsub(t, "%s+$", "")
        return t
    end

    local function resolveUserIdFromLookupInput(raw: string): (number?, string?)
        local s = trimLookupText(raw)
        if s == "" then
            return nil, "empty"
        end
        if string.match(s, "^%d+$") then
            local n = tonumber(s)
            if n and n > 0 and n == math.floor(n) then
                return n, nil
            end
            return nil, "invalid"
        end
        local ok, uid = pcall(function()
            return Players:GetUserIdFromNameAsync(s)
        end)
        if ok and type(uid) == "number" and uid > 0 then
            return uid, nil
        end
        return nil, "notfound"
    end

    local function fetchUserFields(userId: number): (string?, string?, string?)
        local ok, infos = pcall(function()
            return UserService:GetUserInfosByUserIdsAsync({ userId })
        end)
        if ok and type(infos) == "table" and infos[1] then
            local row = infos[1]
            local disp = row.DisplayName
            local uname = row.Username
            if type(disp) == "string" and type(uname) == "string" then
                return disp, uname, nil
            end
        end
        local ok2, nameFromId = pcall(function()
            return Players:GetNameFromUserIdAsync(userId)
        end)
        if ok2 and type(nameFromId) == "string" and nameFromId ~= "" then
            return nameFromId, nameFromId, "partial"
        end
        return nil, nil, "profile"
    end

    local OUTFIT_TEXT_MAX_CHARS = 10000

    local function readHumanoidDescriptionProp(hd: HumanoidDescription, propName: string): any
        local ok, v = pcall(function()
            return (hd :: any)[propName]
        end)
        if ok then
            return v
        end
        return nil
    end

    local function formatHumanoidDescriptionOutfit(hd: HumanoidDescription): string
        local lines: { string } = {}

        local function pushLine(s: string)
            table.insert(lines, s)
        end

        local function pushAssetIdLine(label: string, id: any)
            if type(id) == "number" and id > 0 then
                pushLine(label .. ": " .. tostring(math.floor(id)))
            end
        end

        local function pushNonEmptyStringLine(label: string, s: any)
            if type(s) ~= "string" then
                return
            end
            local t = trimLookupText(s)
            if t == "" then
                return
            end
            pushLine(label .. ": " .. t)
        end

        pushLine("— Body meshes (classic / R15 asset ids) —")
        for _, limb in ipairs({ "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }) do
            pushAssetIdLine(limb, readHumanoidDescriptionProp(hd, limb))
        end
        pushAssetIdLine("Face (decal id)", readHumanoidDescriptionProp(hd, "Face"))

        pushLine("")
        pushLine("— Body colors (BrickColor) —")
        for _, colorName in ipairs({
            "HeadColor",
            "TorsoColor",
            "LeftArmColor",
            "RightArmColor",
            "LeftLegColor",
            "RightLegColor",
        }) do
            local bc = readHumanoidDescriptionProp(hd, colorName)
            if bc ~= nil then
                local okS, txt = pcall(function()
                    return tostring(bc)
                end)
                if okS and txt and txt ~= "" then
                    pushLine(colorName .. ": " .. txt)
                end
            end
        end

        pushLine("")
        pushLine("— Scales —")
        local scaleProps = {
            "BodyTypeScale",
            "ProportionScale",
            "HeightScale",
            "WidthScale",
            "DepthScale",
            "HeadScale",
        }
        for _, pname in ipairs(scaleProps) do
            local v = readHumanoidDescriptionProp(hd, pname)
            if type(v) == "number" then
                pushLine(pname .. ": " .. string.format("%.4g", v))
            end
        end

        local staticFace = readHumanoidDescriptionProp(hd, "StaticFacialAnimation")
        if type(staticFace) == "boolean" then
            pushLine("StaticFacialAnimation: " .. tostring(staticFace))
        end

        pushLine("")
        pushLine("— Clothing templates —")
        pushAssetIdLine("Shirt", readHumanoidDescriptionProp(hd, "Shirt"))
        pushAssetIdLine("Pants", readHumanoidDescriptionProp(hd, "Pants"))
        pushAssetIdLine("GraphicTShirt", readHumanoidDescriptionProp(hd, "GraphicTShirt"))

        pushLine("")
        pushLine("— Rigid accessory slots (comma-separated asset ids) —")
        for _, slot in ipairs({
            "HatAccessory",
            "HairAccessory",
            "FaceAccessory",
            "NeckAccessory",
            "ShouldersAccessory",
            "FrontAccessory",
            "BackAccessory",
            "WaistAccessory",
        }) do
            pushNonEmptyStringLine(slot, readHumanoidDescriptionProp(hd, slot))
        end

        local okAcc, accList = pcall(function()
            return hd:GetAccessories(true)
        end)
        if okAcc and type(accList) == "table" and #accList > 0 then
            pushLine("")
            pushLine("— GetAccessories(true): layered + rigid —")
            local maxAcc = math.min(#accList, 48)
            for i = 1, maxAcc do
                local ad = accList[i]
                if type(ad) == "userdata" or type(ad) == "table" then
                    local aid = (ad :: any).AssetId
                    local aty = (ad :: any).AccessoryType
                    local lay = (ad :: any).IsLayered
                    pushLine(
                        string.format(
                            "  #%d id=%s type=%s layered=%s",
                            i,
                            tostring(aid),
                            tostring(aty),
                            tostring(lay)
                        )
                    )
                end
            end
            if #accList > maxAcc then
                pushLine("  ... +" .. tostring(#accList - maxAcc) .. " more")
            end
        end

        pushLine("")
        pushLine("— Default movement / mood animations (asset ids) —")
        for _, aname in ipairs({
            "IdleAnimation",
            "RunAnimation",
            "WalkAnimation",
            "JumpAnimation",
            "SwimAnimation",
            "ClimbAnimation",
            "FallAnimation",
            "MoodAnimation",
        }) do
            pushAssetIdLine(aname, readHumanoidDescriptionProp(hd, aname))
        end

        local okEm, emotes = pcall(function()
            return hd:GetEmotes()
        end)
        if okEm and type(emotes) == "table" and next(emotes) ~= nil then
            pushLine("")
            pushLine("— Saved emotes (name = animation asset id) —")
            local n = 0
            for name, assetId in pairs(emotes) do
                n = n + 1
                if n > 36 then
                    pushLine("  ... (more emotes not shown)")
                    break
                end
                pushLine("  " .. tostring(name) .. " = " .. tostring(assetId))
            end
        end

        local okEq, equipped = pcall(function()
            return hd:GetEquippedEmotes()
        end)
        if okEq and type(equipped) == "table" and #equipped > 0 then
            pushLine("")
            pushLine("— Equipped emote slots —")
            for i, slot in ipairs(equipped) do
                if i > 8 then
                    pushLine("  ...")
                    break
                end
                if type(slot) == "table" then
                    pushLine(
                        "  slot "
                            .. tostring((slot :: any).Slot)
                            .. " → "
                            .. tostring((slot :: any).Name)
                    )
                else
                    pushLine("  " .. tostring(slot))
                end
            end
        end

        local body = table.concat(lines, "\n")
        if #body > OUTFIT_TEXT_MAX_CHARS then
            body = string.sub(body, 1, OUTFIT_TEXT_MAX_CHARS)
                .. "\n\n... (truncated; HumanoidDescription dump capped at "
                .. tostring(OUTFIT_TEXT_MAX_CHARS)
                .. " chars)"
        end
        return body
    end

    local function destroyActiveAvatarOverlay()
        if activeAvatarOverlayRenderConn then
            activeAvatarOverlayRenderConn:Disconnect()
            activeAvatarOverlayRenderConn = nil
        end
        if activeAvatarOverlayModel then
            pcall(function()
                activeAvatarOverlayModel:Destroy()
            end)
            activeAvatarOverlayModel = nil
        end
    end

    local function setDescendantNonInteractive(inst: Instance)
        if inst:IsA("BasePart") then
            inst.CanCollide = false
            inst.CanTouch = false
            inst.CanQuery = false
            inst.Massless = true
            inst.CastShadow = false
        elseif inst:IsA("TouchTransmitter") then
            inst:Destroy()
        end
    end

    local function collectMotorsByName(root: Instance): { [string]: Motor6D }
        local out: { [string]: Motor6D } = {}
        for _, d in ipairs(root:GetDescendants()) do
            if d:IsA("Motor6D") then
                out[d.Name] = d
            end
        end
        return out
    end

    local function buildAvatarOverlayFromUserId(userId: number): (Model?, string?)
        local localCharacter = Players.LocalPlayer.Character
        local localHumanoid = localCharacter and localCharacter:FindFirstChildOfClass("Humanoid")
        local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
        if not (localCharacter and localHumanoid and localRoot and localRoot:IsA("BasePart")) then
            return nil, "Local character is not ready."
        end

        local okModel, overlayModel = pcall(function()
            return Players:CreateHumanoidModelFromUserId(userId)
        end)
        if not okModel or not overlayModel then
            return nil, "Could not create overlay model from user id."
        end

        local overlayHumanoid = overlayModel:FindFirstChildOfClass("Humanoid")
        local overlayRoot = overlayModel:FindFirstChild("HumanoidRootPart")
        if not (overlayHumanoid and overlayRoot and overlayRoot:IsA("BasePart")) then
            pcall(function()
                overlayModel:Destroy()
            end)
            return nil, "Overlay model is missing humanoid root."
        end

        overlayModel.Name = "AvatarCopyOverlay_" .. tostring(userId)
        overlayModel.Parent = Workspace
        overlayModel:PivotTo(localRoot.CFrame)

        for _, d in ipairs(overlayModel:GetDescendants()) do
            if d:IsA("Script") or d:IsA("LocalScript") then
                pcall(function()
                    d:Destroy()
                end)
            else
                setDescendantNonInteractive(d)
            end
        end

        overlayHumanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
        overlayHumanoid.HealthDisplayDistance = 0
        overlayHumanoid.NameDisplayDistance = 0
        overlayHumanoid.BreakJointsOnDeath = false

        local rootWeld = Instance.new("WeldConstraint")
        rootWeld.Name = "AvatarCopyFollowWeld"
        rootWeld.Part0 = localRoot
        rootWeld.Part1 = overlayRoot
        rootWeld.Parent = overlayRoot

        local srcMotors = collectMotorsByName(localCharacter)
        local dstMotors = collectMotorsByName(overlayModel)

        activeAvatarOverlayRenderConn = RunService.RenderStepped:Connect(function()
            if not (localRoot.Parent and overlayRoot.Parent and overlayModel.Parent) then
                destroyActiveAvatarOverlay()
                return
            end
            for motorName, srcMotor in pairs(srcMotors) do
                local dstMotor = dstMotors[motorName]
                if dstMotor and srcMotor.Parent and dstMotor.Parent then
                    dstMotor.Transform = srcMotor.Transform
                end
            end
        end)

        return overlayModel, nil
    end

    AvatarTab:CreateButton({
        Name = "Search",
        Callback = function()
            local raw = AvatarLookupInput and AvatarLookupInput.GetValue and AvatarLookupInput:GetValue()
                or avatarLookupInputValue
            local userId, err = resolveUserIdFromLookupInput(raw)
            if err == "empty" then
                lastAvatarLookupUserId = nil
                mountNotify({ Title = "Avatar lookup", Content = "Enter a username or user id.", Icon = "x" })
                AvatarOutfitParagraph:Set({
                    Title = "Outfit, body & animations",
                    Content = "Run Search after entering a username or user id.",
                })
                return
            end
            if not userId then
                lastAvatarLookupUserId = nil
                mountNotify({
                    Title = "Avatar lookup",
                    Content = "Could not resolve that username or id.",
                    Icon = "x",
                })
                AvatarOutfitParagraph:Set({
                    Title = "Outfit, body & animations",
                    Content = "No HumanoidDescription loaded (lookup failed).",
                })
                return
            end
            lastAvatarLookupUserId = userId
            local displayName, username, fetchErr = fetchUserFields(userId)
            if not username then
                mountNotify({
                    Title = "Avatar lookup",
                    Content = "User id "
                        .. tostring(userId)
                        .. " exists but profile details could not be loaded.",
                    Icon = "x",
                })
                AvatarPreviewImage:Set({
                    Image = "",
                    Description = "Profile unavailable for this id.",
                })
                AvatarDetailsParagraph:Set({
                    Title = "Player details",
                    Content = "User ID: " .. tostring(userId),
                })
                AvatarOutfitParagraph:Set({
                    Title = "Outfit, body & animations",
                    Content = "Outfit data not loaded.",
                })
                return
            end
            local thumb = string.format(
                "rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150",
                userId
            )
            AvatarPreviewImage:Set({
                Image = thumb,
                Title = "Avatar",
                Description = "",
                ImageSize = 150,
            })
            local detailLines = {
                "Display name: " .. (displayName or username),
                "Username: " .. username,
                "User ID: " .. tostring(userId),
            }
            if fetchErr == "partial" then
                table.insert(detailLines, "(Display name from username fallback)")
            end
            AvatarDetailsParagraph:Set({
                Title = "Player details",
                Content = table.concat(detailLines, "\n"),
            })

            local outfitContent = "Outfit / body data could not be loaded."
            local okHd, hd = pcall(function()
                return Players:GetHumanoidDescriptionFromUserIdAsync(userId)
            end)
            if okHd and hd then
                outfitContent = formatHumanoidDescriptionOutfit(hd)
            end
            AvatarOutfitParagraph:Set({
                Title = "Outfit, body & animations",
                Content = outfitContent,
            })
        end,
    })

    AvatarPreviewImage = AvatarTab:CreateImage({
        Name = "AvatarPreview",
        Title = "Avatar",
        Image = "",
        ImageSize = 150,
        Description = "Results appear after Search.",
    })

    AvatarDetailsParagraph = AvatarTab:CreateParagraph({
        Title = "Player details",
        Content = "Enter a Roblox username or numeric user id, then tap Search.\n\nNote: lookup uses account username, not always the same as display name search on the website.",
    })

    AvatarOutfitParagraph = AvatarTab:CreateParagraph({
        Title = "Outfit, body & animations",
        Content = "After Search, this shows HumanoidDescription: body part and face ids, body colors, scales, shirt / pants / t-shirt, rigid accessory strings, GetAccessories(true), default animations, emotes, and equipped emote slots.",
    })

    AvatarTab:CreateButton({
        Name = "Copy Avatar",
        Callback = function()
            if not lastAvatarLookupUserId then
                mountNotify({
                    Title = "Copy Avatar",
                    Content = "Search a username or user id first.",
                    Icon = "x",
                })
                return
            end

            destroyActiveAvatarOverlay()
            local overlay, copyErr = buildAvatarOverlayFromUserId(lastAvatarLookupUserId)
            if not overlay then
                mountNotify({
                    Title = "Copy Avatar",
                    Content = copyErr or "Failed to copy avatar.",
                    Icon = "x",
                })
                return
            end
            activeAvatarOverlayModel = overlay
            mountNotify({
                Title = "Copy Avatar",
                Content = "Avatar overlay copied and mirroring live pose.",
                Icon = "check",
            })
        end,
    })
end
