local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local UserService = game:GetService("UserService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace = game:GetService("Workspace")

local SempatLibrary

local baseURL = shared.sempatpanick_baseURL
assert(type(baseURL) == "string" and #baseURL > 0, "[sempatpanick] baseURL not set - load via sempatpanick.lua or sempatpanick_local.lua")

local function stripSourceBom(source)
    if type(source) == "string" and source:byte(1) == 0xEF and source:byte(2) == 0xBB and source:byte(3) == 0xBF then
        return source:sub(4)
    end
    return source
end

do
    local ok, result = pcall(function()
        return require("../../sempat_library")
    end)

    if ok then
        SempatLibrary = result
    else
        if cloneref(RunService):IsStudio() then
            SempatLibrary = require(cloneref(ReplicatedStorage):WaitForChild("sempat_library"))
        else
            local okGet, source = pcall(function()
                return game:HttpGet(baseURL .. "/sempat_library.lua")
            end)
            assert(okGet and type(source) == "string", "[sempat/others] failed to load sempat_library")
            source = stripSourceBom(source)
            SempatLibrary = (loadstring or load)(source, "sempat_library")()
        end
    end
end

local function mountNotify(opts)
    SempatLibrary:Notify({
        Title = opts.Title,
        Content = opts.Content,
        Duration = opts.Duration or 4,
    })
end

-- */  Recording Tab (module)  /* --
local RECORDING_TAB_REPO = baseURL .. "/tabs/rayfield/recording_tab.lua"
local function loadCreateRecordingTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("../../tabs/rayfield/recording_tab")
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
local LOCAL_PLAYER_TAB_REPO = baseURL .. "/tabs/rayfield/local_player_tab.lua"
local function loadCreateLocalPlayerTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("../../tabs/rayfield/local_player_tab")
    end)
    if okReq and type(mod) == "function" then
        return mod
    end

    local okHttp, source = pcall(function()
        return game:HttpGet(repoUrl)
    end)
    if not okHttp or type(source) ~= "string" or #source < 64 then
        warn("[Local Player] HttpGet failed:", tostring(source))
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
        warn("[Local Player] compile failed:", tostring(compileErr))
        return nil
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        warn("[Local Player] module execute failed:", tostring(result))
        return nil
    end
    if type(result) ~= "function" then
        warn("[Local Player] module must return a function, got", type(result))
        return nil
    end
    return result
end

local createLocalPlayerTab = loadCreateLocalPlayerTab(LOCAL_PLAYER_TAB_REPO)
if not createLocalPlayerTab then
    createLocalPlayerTab = function(_windowRef, notifyFn, _options)
        notifyFn({ Title = "Local Player", Content = "Failed to load Local Player Tab tab module", Icon = "x" })
    end
end
-- */  Objects Tab (module)  /* --
local OBJECTS_TAB_REPO = baseURL .. "/tabs/rayfield/objects_tab.lua"
local function loadCreateObjectsTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("../../tabs/rayfield/objects_tab")
    end)
    if okReq and type(mod) == "function" then
        return mod
    end

    local okHttp, source = pcall(function()
        return game:HttpGet(repoUrl)
    end)
    if not okHttp or type(source) ~= "string" or #source < 64 then
        warn("[Objects] HttpGet failed:", tostring(source))
        return nil
    end

    local chunk, compileErr
    if type(load) == "function" then
        local okLoad
        okLoad, chunk = pcall(function()
            return load(source, "objects_tab")
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
        warn("[Objects] compile failed:", tostring(compileErr))
        return nil
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        warn("[Objects] module execute failed:", tostring(result))
        return nil
    end
    if type(result) ~= "function" then
        warn("[Objects] module must return a function, got", type(result))
        return nil
    end
    return result
end

local createObjectsTab = loadCreateObjectsTab(OBJECTS_TAB_REPO)
if not createObjectsTab then
    createObjectsTab = function(_windowRef, notifyFn, _options)
        notifyFn({ Title = "Objects", Content = "Failed to load Objects Tab tab module", Icon = "x" })
    end
end
-- */  Teleport Tab (module)  /* --
local TELEPORT_TAB_REPO = baseURL .. "/tabs/rayfield/teleport_tab.lua"
local function loadCreateTeleportTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("../../tabs/rayfield/teleport_tab")
    end)
    if okReq and type(mod) == "function" then
        return mod
    end

    local okHttp, source = pcall(function()
        return game:HttpGet(repoUrl)
    end)
    if not okHttp or type(source) ~= "string" or #source < 64 then
        warn("[Teleport Tab] HttpGet failed:", tostring(source))
        return nil
    end

    local chunk, compileErr
    if type(load) == "function" then
        local okLoad
        okLoad, chunk = pcall(function()
            return load(source, "teleport_tab")
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
        warn("[Teleport Tab] compile failed:", tostring(compileErr))
        return nil
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        warn("[Teleport Tab] module execute failed:", tostring(result))
        return nil
    end
    if type(result) ~= "function" then
        warn("[Teleport Tab] module must return a function, got", type(result))
        return nil
    end
    return result
end

local createTeleportTab = loadCreateTeleportTab(TELEPORT_TAB_REPO)
if not createTeleportTab then
    createTeleportTab = function(_windowRef, notifyFn, _options)
        notifyFn({ Title = "Teleport", Content = "Failed to load Teleport Tab module", Icon = "x" })
    end
end
-- */  Config Tab (module)  /* --
local CONFIG_TAB_REPO = baseURL .. "/tabs/rayfield/config_tab.lua"
local function loadCreateConfigTab(repoUrl)
    local okReq, mod = pcall(function()
        return require("../../tabs/rayfield/config_tab")
    end)
    if okReq and type(mod) == "function" then
        return mod
    end

    local okHttp, source = pcall(function()
        return game:HttpGet(repoUrl)
    end)
    if not okHttp or type(source) ~= "string" or #source < 64 then
        warn("[Config Tab] HttpGet failed:", tostring(source))
        return nil
    end

    local chunk, compileErr
    if type(load) == "function" then
        local okLoad
        okLoad, chunk = pcall(function()
            return load(source, "config_tab")
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
        warn("[Config Tab] compile failed:", tostring(compileErr))
        return nil
    end

    local okRun, result = pcall(chunk)
    if not okRun then
        warn("[Config Tab] module execute failed:", tostring(result))
        return nil
    end
    if type(result) ~= "function" then
        warn("[Config Tab] module must return a function, got", type(result))
        return nil
    end
    return result
end

local createConfigTab = loadCreateConfigTab(CONFIG_TAB_REPO)
if not createConfigTab then
    createConfigTab = function(_windowRef, notifyFn, _options)
        notifyFn({ Title = "Config", Content = "Failed to load Config Tab module", Icon = "x" })
    end
end
-- */  Window  /* --
local Window = SempatLibrary:CreateWindow({
    Name = "sempatpanick | Others",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Sempat UI • Others",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "sempatpanick",
        FileName = "others",
    },
})


-- */  Local Player Tab  /* --
createLocalPlayerTab(Window, mountNotify)

-- */  Teleport Tab  /* --
createTeleportTab(Window, mountNotify, { flagsPrefix = "others" })

-- */  Objects Tab  /* --
createObjectsTab(Window, mountNotify, { replicatedStorage = ReplicatedStorage })

-- */  Recording Tab  /* --
createRecordingTab(Window, mountNotify, "sempatpanick/others/recordings")

-- */  Config Tab  /* --
createConfigTab(Window, mountNotify, {
    configDir = "sempatpanick/others",
    rayfieldLibrary = SempatLibrary,
})

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
    local avatarPreviewUsesImageElement = false
    local AvatarDetailsParagraph
    local AvatarOutfitParagraph
    local lastAvatarLookupUserId: number? = nil
    local activeAvatarOverlayModel: Model? = nil
    local activeAvatarOverlayRenderConn: RBXScriptConnection? = nil

    local function setAvatarPreviewDisplay(opts: {
        Image: string?,
        Title: string?,
        Description: string?,
        ImageSize: number?,
    })
        if not AvatarPreviewImage then
            return
        end
        if avatarPreviewUsesImageElement and AvatarPreviewImage.Set then
            pcall(function()
                AvatarPreviewImage:Set({
                    Image = opts.Image or "",
                    Title = opts.Title or "Avatar",
                    Description = opts.Description or "",
                    ImageSize = opts.ImageSize or 150,
                })
            end)
            return
        end
        if AvatarPreviewImage.Set then
            local content = opts.Description or ""
            if opts.Image and opts.Image ~= "" then
                if content ~= "" then
                    content = content .. "\n\n"
                end
                content = content .. "Headshot: " .. tostring(opts.Image)
            end
            pcall(function()
                AvatarPreviewImage:Set({
                    Title = opts.Title or "Avatar",
                    Content = content,
                })
            end)
        end
    end

    do
        local previewProps = {
            Name = "AvatarPreview",
            Title = "Avatar",
            Image = "",
            ImageSize = 150,
            Description = "Results appear after Search.",
        }
        if type(AvatarTab.CreateImage) == "function" then
            local okCreate, previewEl = pcall(function()
                return AvatarTab:CreateImage(previewProps)
            end)
            if okCreate and previewEl then
                AvatarPreviewImage = previewEl
                avatarPreviewUsesImageElement = true
            end
        end
        if not AvatarPreviewImage then
            AvatarPreviewImage = AvatarTab:CreateParagraph({
                Title = previewProps.Title,
                Content = previewProps.Description,
            })
        end
    end

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
                setAvatarPreviewDisplay({
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
            setAvatarPreviewDisplay({
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
