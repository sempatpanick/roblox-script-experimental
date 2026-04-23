local cloneref = (cloneref or clonereference or function(instance) return instance end)

-- ====================================================================
--                        CORE SERVICES
-- ====================================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")

local RayfieldLibrary

local baseURL = "https://raw.githubusercontent.com/sempatpanick/roblox-script-experimental/refs/heads/main"

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
            RayfieldLibrary = loadstring(game:HttpGet(baseURL .. "/rayfield_library.lua"))()
        end
    end
end

-- HehAdmin panel (PlayerGui.HehAdminUI): inlined from place decompile; runs when game's LocalScript is absent.
if not _G.__HehAdminUIMountYahayukClient then
    _G.__HehAdminUIMountYahayukClient = true
    local v1 = game:GetService("Players")
    local v2 = game:GetService("ReplicatedStorage")
    local u3 = game:GetService("UserInputService")
    local u4 = game:GetService("RunService")
    game:GetService("TweenService")
    local u5 = v1.LocalPlayer
    local v6 = v2:WaitForChild("HehAdmin_Open")
    local u7 = v2:WaitForChild("HehAdmin_Do")
    local u8 = Color3.fromRGB(16, 16, 20)
    local u9 = Color3.fromRGB(36, 36, 42)
    local u10 = Color3.fromRGB(38, 90, 64)
    local u11 = Color3.fromRGB(255, 255, 255)
    local u12 = Color3.fromRGB(28, 114, 62)
    local function u15(p13) --[[ Line: 36 ]]
        --[[
        Upvalues:
            [1] = u11
        --]]
        local v14 = Instance.new("TextLabel")
        v14.BackgroundTransparency = 1
        v14.Size = UDim2.new(1, 0, 0, 22)
        v14.Font = Enum.Font.GothamBold
        v14.TextSize = 15
        v14.TextXAlignment = Enum.TextXAlignment.Left
        v14.TextColor3 = u11
        v14.Text = p13
        return v14
    end
    local function u21(p16, u17, p18) --[[ Line: 46 ]]
        --[[
        Upvalues:
            [1] = u9
            [2] = u11
        --]]
        local v19 = Instance.new("TextButton")
        v19.Text = p16
        v19.Font = Enum.Font.GothamBold
        v19.TextSize = 13
        v19.BackgroundColor3 = u9
        v19.TextColor3 = u11
        v19.Size = UDim2.new(1, 0, 0, p18 or 28)
        local v20 = Instance.new("UICorner")
        v20.CornerRadius = UDim.new(0, 10)
        v20.Parent = v19
        if typeof(u17) == "function" then
            v19.MouseButton1Click:Connect(function() --[[ Line: 53 ]]
                --[[
                Upvalues:
                    [1] = u17
                --]]
                u17()
            end)
        end
        return v19
    end
    local function u27(p22) --[[ Line: 63 ]]
        --[[
        Upvalues:
            [1] = u11
        --]]
        local v23 = Instance.new("Frame")
        v23.Size = UDim2.new(1, 0, 0, 30)
        v23.BackgroundColor3 = Color3.fromRGB(26, 26, 32)
        local v24 = Instance.new("UICorner")
        v24.CornerRadius = UDim.new(0, 10)
        v24.Parent = v23
        local v25 = Instance.new("UIPadding")
        v25.PaddingLeft = UDim.new(0, 10)
        v25.PaddingRight = UDim.new(0, 10)
        v25.Parent = v23
        local v26 = Instance.new("TextBox")
        v26.BackgroundTransparency = 1
        v26.Size = UDim2.new(1, 0, 1, 0)
        v26.Font = Enum.Font.Gotham
        v26.TextSize = 14
        v26.TextColor3 = u11
        v26.PlaceholderText = p22 or ""
        v26.Parent = v23
        return v23, v26
    end
    local function u53(p28, p29) --[[ Line: 71 ]]
        --[[
        Upvalues:
            [1] = u5
            [2] = u3
            [3] = u15
            [4] = u21
            [5] = u12
        --]]
        local v30 = u5:WaitForChild("PlayerGui")
        local v31 = v30:FindFirstChild("HehAdminUI")
        if not v31 then
            v31 = Instance.new("ScreenGui")
            v31.Name = "HehAdminUI"
            v31.IgnoreGuiInset = true
            v31.DisplayOrder = 9999
            v31.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            v31.ResetOnSpawn = false
            v31.Parent = v30
        end
        local u32 = Instance.new("TextButton")
        u32.AutoButtonColor = false
        u32.Text = ""
        u32.Size = UDim2.fromScale(1, 1)
        u32.BackgroundColor3 = Color3.new(0, 0, 0)
        u32.BackgroundTransparency = 0.45
        u32.Parent = v31
        local v33 = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
        local v34 = v33.X * 0.88
        local v35 = math.floor(v34)
        local v36 = math.min(300, v35)
        local v37 = v33.Y * (u3.TouchEnabled and 0.5 or 0.42)
        local v38 = math.floor(v37)
        local v39 = math.min(220, v38)
        local v40 = Instance.new("Frame")
        v40.AnchorPoint = Vector2.new(0.5, 0.5)
        v40.Position = UDim2.fromScale(0.5, 0.5)
        v40.Size = UDim2.new(0, v36, 0, v39)
        v40.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
        local v41 = Instance.new("UICorner")
        v41.CornerRadius = UDim.new(0, 10)
        v41.Parent = v40
        v40.Parent = u32
        local v42 = Instance.new("UIPadding")
        v42.PaddingTop = UDim.new(0, 10)
        v42.PaddingLeft = UDim.new(0, 10)
        v42.PaddingRight = UDim.new(0, 10)
        v42.Parent = v40
        local v43 = Instance.new("Frame")
        v43.BackgroundTransparency = 1
        v43.Size = UDim2.new(1, 0, 1, 0)
        local v44 = Instance.new("UIListLayout")
        v44.Padding = UDim.new(0, 6)
        v44.SortOrder = Enum.SortOrder.LayoutOrder
        v44.Parent = v43
        v43.Parent = v40
        u15(p28).Parent = v43
        local v45 = Instance.new("Frame")
        v45.BackgroundTransparency = 1
        v45.Size = UDim2.new(1, 0, 1, -72)
        local v46 = Instance.new("UIListLayout")
        v46.Padding = UDim.new(0, 6)
        v46.SortOrder = Enum.SortOrder.LayoutOrder
        v46.Parent = v45
        v45.Parent = v43
        local v47 = Instance.new("Frame")
        v47.BackgroundTransparency = 1
        v47.Size = UDim2.new(1, 0, 0, 28)
        local v48 = Instance.new("UIListLayout")
        v48.FillDirection = Enum.FillDirection.Horizontal
        v48.Padding = UDim.new(0, 6)
        v48.SortOrder = Enum.SortOrder.LayoutOrder
        v48.Parent = v47
        v47.Parent = v43
        local v49 = u21("Cancel", function() --[[ Line: 89 ]]
            --[[
            Upvalues:
                [1] = u32
            --]]
            u32:Destroy()
        end, 28)
        v49.Size = UDim2.new(0.5, -3, 1, 0)
        v49.Parent = v47
        local u50 = u21("Confirm", function() --[[ Line: 90 ]] end, 28)
        u50.BackgroundColor3 = u12
        u50.Size = UDim2.new(0.5, -3, 1, 0)
        u50.Parent = v47
        if typeof(p29) == "function" then
            p29(v45, function(u51) --[[ Line: 93 ]]
                --[[
                Upvalues:
                    [1] = u50
                    [2] = u32
                --]]
                u50.MouseButton1Click:Connect(function() --[[ Line: 94 ]]
                    --[[
                    Upvalues:
                        [1] = u51
                        [2] = u32
                    --]]
                    local v52 = u51
                    if typeof(v52) == "function" then
                        u51()
                    end
                    u32:Destroy()
                end)
            end)
        end
        u32.MouseButton1Click:Connect(function() --[[ Line: 97 ]]
            --[[
            Upvalues:
                [1] = u32
            --]]
            u32:Destroy()
        end)
        return u32
    end
    local function u147() --[[ Line: 102 ]]
        --[[
        Upvalues:
            [1] = u5
            [2] = u8
            [3] = u3
            [4] = u4
            [5] = u15
            [6] = u21
            [7] = u10
            [8] = u9
            [9] = u53
            [10] = u27
            [11] = u7
        --]]
        local v54 = u5:WaitForChild("PlayerGui")
        local v55 = v54:FindFirstChild("HehAdminUI")
        if not v55 then
            v55 = Instance.new("ScreenGui")
            v55.Name = "HehAdminUI"
            v55.IgnoreGuiInset = true
            v55.DisplayOrder = 9999
            v55.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            v55.ResetOnSpawn = false
            v55.Parent = v54
        end
        local v56 = v55:FindFirstChild("Root")
        if v56 then
            return v56
        end
        local u57 = Instance.new("Frame")
        u57.Name = "Root"
        u57.AnchorPoint = Vector2.new(0.5, 0.5)
        u57.Position = UDim2.fromScale(0.5, 0.5)
        u57.BackgroundColor3 = u8
        local v58 = u57
        local v59 = Instance.new("UICorner")
        v59.CornerRadius = UDim.new(0, 10)
        v59.Parent = v58
        local function v67() --[[ Line: 112 ]]
            --[[
            Upvalues:
                [1] = u3
                [2] = u57
            --]]
            local v60 = workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280, 720)
            local v61 = v60.X * 0.9
            local v62 = math.floor(v61)
            local v63 = math.min(340, v62)
            local v64 = v60.Y * (u3.TouchEnabled and 0.58 or 0.46)
            local v65 = math.floor(v64)
            local v66 = math.min(260, v65)
            u57.Size = UDim2.new(0, v63, 0, v66)
        end
        v67()
        u4.RenderStepped:Connect(v67)
        local v68 = Instance.new("UIPadding")
        v68.PaddingTop = UDim.new(0, 8)
        v68.PaddingLeft = UDim.new(0, 8)
        v68.PaddingRight = UDim.new(0, 8)
        v68.Parent = u57
        local v69 = Instance.new("Frame")
        v69.BackgroundTransparency = 1
        v69.Size = UDim2.new(1, 0, 1, 0)
        local v70 = Instance.new("UIListLayout")
        v70.Padding = UDim.new(0, 6)
        v70.SortOrder = Enum.SortOrder.LayoutOrder
        v70.Parent = v69
        v69.Parent = u57
        local v71 = Instance.new("Frame")
        v71.BackgroundTransparency = 1
        v71.Size = UDim2.new(1, 0, 0, 22)
        v71.Parent = v69
        local v72 = u15("Admin Panel")
        v72.Size = UDim2.new(1, -28, 1, 0)
        v72.Parent = v71
        local v73 = u21("X", function() --[[ Line: 126 ]]
            --[[
            Upvalues:
                [1] = u57
            --]]
            u57.Visible = false
        end, 22)
        v73.Size = UDim2.new(0, 22, 1, 0)
        v73.Position = UDim2.new(1, -22, 0, 0)
        v73.TextSize = 12
        v73.Parent = v71
        local v74 = Instance.new("Frame")
        v74.BackgroundTransparency = 1
        v74.Size = UDim2.new(1, 0, 0, 28)
        local v75 = Instance.new("UIListLayout")
        v75.FillDirection = Enum.FillDirection.Horizontal
        v75.Padding = UDim.new(0, 6)
        v75.SortOrder = Enum.SortOrder.LayoutOrder
        v75.Parent = v74
        v74.Parent = v69
        local v76 = Instance.new("Frame")
        v76.BackgroundTransparency = 1
        v76.Size = UDim2.new(1, 0, 1, -62)
        v76.Parent = v69
        local u77 = Instance.new("Frame")
        u77.BackgroundTransparency = 1
        u77.Size = UDim2.new(1, 0, 1, 0)
        local v78 = Instance.new("UIListLayout")
        v78.Padding = UDim.new(0, 6)
        v78.SortOrder = Enum.SortOrder.LayoutOrder
        v78.Parent = u77
        u77.Visible = false
        u77.Parent = v76
        local u79 = Instance.new("Frame")
        u79.BackgroundTransparency = 1
        u79.Size = UDim2.new(1, 0, 1, 0)
        local v80 = Instance.new("UIListLayout")
        v80.Padding = UDim.new(0, 6)
        v80.SortOrder = Enum.SortOrder.LayoutOrder
        v80.Parent = u79
        u79.Visible = false
        u79.Parent = v76
        local u81 = u21("LINTAS SERVER", function() --[[ Line: 138 ]] end, 28)
        local u82 = u21("BUKAN LINTAS SERVER", function() --[[ Line: 139 ]] end, 28)
        u81.Size = UDim2.new(0.5, -3, 1, 0)
        u82.Size = UDim2.new(0.5, -3, 1, 0)
        u81.Parent = v74
        u82.Parent = v74
        u81.MouseButton1Click:Connect(function() --[[ Line: 147 ]]
            --[[
            Upvalues:
                [1] = u77
                [2] = u79
                [3] = u81
                [4] = u10
                [5] = u9
                [6] = u82
            --]]
            local v83 = u77
            u77.Visible = v83 == u77
            u79.Visible = v83 == u79
            u81.BackgroundColor3 = v83 == u77 and u10 or u9
            u82.BackgroundColor3 = v83 == u79 and u10 or u9
        end)
        u82.MouseButton1Click:Connect(function() --[[ Line: 148 ]]
            --[[
            Upvalues:
                [1] = u79
                [2] = u77
                [3] = u81
                [4] = u10
                [5] = u9
                [6] = u82
            --]]
            local v84 = u79
            u77.Visible = v84 == u77
            u79.Visible = v84 == u79
            u81.BackgroundColor3 = v84 == u77 and u10 or u9
            u82.BackgroundColor3 = v84 == u79 and u10 or u9
        end)
        u77.Visible = u77 == u77
        u79.Visible = u77 == u79
        u81.BackgroundColor3 = u77 == u77 and u10 or u9
        u82.BackgroundColor3 = u77 == u79 and u10 or u9
        local v85 = Instance.new("Frame")
        v85.BackgroundTransparency = 1
        v85.Size = UDim2.new(1, 0, 0, 28)
        local v86 = Instance.new("UIListLayout")
        v86.FillDirection = Enum.FillDirection.Horizontal
        v86.Padding = UDim.new(0, 6)
        v86.SortOrder = Enum.SortOrder.LayoutOrder
        v86.Parent = v85
        v85.Parent = u77
        local v98 = u21("RESET", function() --[[ Line: 155 ]]
            --[[
            Upvalues:
                [1] = u53
                [2] = u21
                [3] = u10
                [4] = u9
                [5] = u27
                [6] = u7
            --]]
            u53("Reset (Global)", function(p87, p88) --[[ Line: 156 ]]
                --[[
                Upvalues:
                    [1] = u21
                    [2] = u10
                    [3] = u9
                    [4] = u27
                    [5] = u7
                --]]
                local u89 = {
                    ["field"] = nil
                }
                local v90 = Instance.new("Frame")
                v90.BackgroundTransparency = 1
                v90.Size = UDim2.new(1, 0, 0, 28)
                local v91 = Instance.new("UIListLayout")
                v91.FillDirection = Enum.FillDirection.Horizontal
                v91.Padding = UDim.new(0, 6)
                v91.SortOrder = Enum.SortOrder.LayoutOrder
                v91.Parent = v90
                v90.Parent = p87
                local u92 = nil
                local u93 = nil
                local u94 = nil
                u92 = u21("Summit", function() --[[ Line: 162 ]]
                    --[[
                    Upvalues:
                        [1] = u89
                        [2] = u92
                        [3] = u10
                        [4] = u9
                        [5] = u93
                        [6] = u94
                    --]]
                    u89.field = "summit"
                    u92.BackgroundColor3 = u10 or u9
                    u93.BackgroundColor3 = u9
                    u94.BackgroundColor3 = u9
                end, 28)
                u93 = u21("BestTime", function() --[[ Line: 163 ]]
                    --[[
                    Upvalues:
                        [1] = u89
                        [2] = u92
                        [3] = u9
                        [4] = u93
                        [5] = u10
                        [6] = u94
                    --]]
                    u89.field = "besttime"
                    u92.BackgroundColor3 = u9
                    u93.BackgroundColor3 = u10 or u9
                    u94.BackgroundColor3 = u9
                end, 28)
                u94 = u21("Cash", function() --[[ Line: 164 ]]
                    --[[
                    Upvalues:
                        [1] = u89
                        [2] = u92
                        [3] = u9
                        [4] = u93
                        [5] = u94
                        [6] = u10
                    --]]
                    u89.field = "cash"
                    u92.BackgroundColor3 = u9
                    u93.BackgroundColor3 = u9
                    u94.BackgroundColor3 = u10 or u9
                end, 28)
                u92.Size = UDim2.new(0.3333333333333333, -4, 1, 0)
                u93.Size = u92.Size
                u94.Size = u92.Size
                u92.Parent = v90
                u93.Parent = v90
                u94.Parent = v90
                local v95, u96 = u27("Username")
                v95.Parent = p87
                p88(function() --[[ Line: 171 ]]
                    --[[
                    Upvalues:
                        [1] = u89
                        [2] = u96
                        [3] = u7
                    --]]
                    if u89.field == nil then
                        return
                    else
                        local v97 = u96.Text
                        if v97 ~= "" then
                            u7:FireServer({
                                ["scope"] = "global",
                                ["action"] = "reset",
                                ["field"] = u89.field,
                                ["username"] = v97
                            })
                        end
                    end
                end)
            end)
        end, 28)
        v98.Size = UDim2.new(0.5, -3, 1, 0)
        v98.Parent = v85
        local v113 = u21("SET", function() --[[ Line: 180 ]]
            --[[
            Upvalues:
                [1] = u53
                [2] = u27
                [3] = u21
                [4] = u10
                [5] = u9
                [6] = u7
            --]]
            u53("Set (Global)", function(p99, p100) --[[ Line: 181 ]]
                --[[
                Upvalues:
                    [1] = u27
                    [2] = u21
                    [3] = u10
                    [4] = u9
                    [5] = u7
                --]]
                local u101 = {
                    ["field"] = nil
                }
                local v102 = Instance.new("Frame")
                v102.BackgroundTransparency = 1
                v102.Size = UDim2.new(1, 0, 0, 28)
                local v103 = Instance.new("UIListLayout")
                v103.FillDirection = Enum.FillDirection.Horizontal
                v103.Padding = UDim.new(0, 6)
                v103.SortOrder = Enum.SortOrder.LayoutOrder
                v103.Parent = v102
                v102.Parent = p99
                local u104 = nil
                local u105 = nil
                local u106 = nil
                local v107, u108 = u27("Username")
                v107.Parent = p99
                local v109, u110 = u27("Pilih jenis di atas terlebih dulu")
                v109.Parent = p99
                u104 = u21("Summit", function() --[[ Line: 201 ]]
                    --[[
                    Upvalues:
                        [1] = u101
                        [2] = u104
                        [3] = u10
                        [4] = u9
                        [5] = u105
                        [6] = u106
                        [7] = u110
                    --]]
                    u101.field = "summit"
                    u104.BackgroundColor3 = u10 or u9
                    u105.BackgroundColor3 = u9
                    u106.BackgroundColor3 = u9
                    if u101.field == "summit" then
                        u110.PlaceholderText = "Value Summit (angka total, mis. 25)"
                        return
                    elseif u101.field == "besttime" then
                        u110.PlaceholderText = "BestTime (detik atau mm:ss, mis. 95 atau 01:35)"
                        return
                    elseif u101.field == "cash" then
                        u110.PlaceholderText = "Value Cash (angka total, mis. 5000)"
                    else
                        u110.PlaceholderText = "Pilih jenis di atas terlebih dulu"
                    end
                end, 28)
                u105 = u21("BestTime", function() --[[ Line: 204 ]]
                    --[[
                    Upvalues:
                        [1] = u101
                        [2] = u104
                        [3] = u9
                        [4] = u105
                        [5] = u10
                        [6] = u106
                        [7] = u110
                    --]]
                    u101.field = "besttime"
                    u104.BackgroundColor3 = u9
                    u105.BackgroundColor3 = u10 or u9
                    u106.BackgroundColor3 = u9
                    if u101.field == "summit" then
                        u110.PlaceholderText = "Value Summit (angka total, mis. 25)"
                        return
                    elseif u101.field == "besttime" then
                        u110.PlaceholderText = "BestTime (detik atau mm:ss, mis. 95 atau 01:35)"
                        return
                    elseif u101.field == "cash" then
                        u110.PlaceholderText = "Value Cash (angka total, mis. 5000)"
                    else
                        u110.PlaceholderText = "Pilih jenis di atas terlebih dulu"
                    end
                end, 28)
                u106 = u21("Cash", function() --[[ Line: 207 ]]
                    --[[
                    Upvalues:
                        [1] = u101
                        [2] = u104
                        [3] = u9
                        [4] = u105
                        [5] = u106
                        [6] = u10
                        [7] = u110
                    --]]
                    u101.field = "cash"
                    u104.BackgroundColor3 = u9
                    u105.BackgroundColor3 = u9
                    u106.BackgroundColor3 = u10 or u9
                    if u101.field == "summit" then
                        u110.PlaceholderText = "Value Summit (angka total, mis. 25)"
                        return
                    elseif u101.field == "besttime" then
                        u110.PlaceholderText = "BestTime (detik atau mm:ss, mis. 95 atau 01:35)"
                        return
                    elseif u101.field == "cash" then
                        u110.PlaceholderText = "Value Cash (angka total, mis. 5000)"
                    else
                        u110.PlaceholderText = "Pilih jenis di atas terlebih dulu"
                    end
                end, 28)
                u104.Size = UDim2.new(0.3333333333333333, -4, 1, 0)
                u105.Size = u104.Size
                u106.Size = u104.Size
                u104.Parent = v102
                u105.Parent = v102
                u106.Parent = v102
                if u101.field == "summit" then
                    u110.PlaceholderText = "Value Summit (angka total, mis. 25)"
                elseif u101.field == "besttime" then
                    u110.PlaceholderText = "BestTime (detik atau mm:ss, mis. 95 atau 01:35)"
                elseif u101.field == "cash" then
                    u110.PlaceholderText = "Value Cash (angka total, mis. 5000)"
                else
                    u110.PlaceholderText = "Pilih jenis di atas terlebih dulu"
                end
                p100(function() --[[ Line: 215 ]]
                    --[[
                    Upvalues:
                        [1] = u101
                        [2] = u108
                        [3] = u110
                        [4] = u7
                    --]]
                    if u101.field == nil then
                        return
                    else
                        local v111 = u108.Text
                        local v112 = u110.Text
                        if v111 ~= "" and v112 ~= "" then
                            u7:FireServer({
                                ["scope"] = "global",
                                ["action"] = "set",
                                ["field"] = u101.field,
                                ["username"] = v111,
                                ["value"] = v112
                            })
                        end
                    end
                end)
            end)
        end, 28)
        v113.Size = UDim2.new(0.5, -3, 1, 0)
        v113.Parent = v85
        v113.Size = UDim2.new(0.5, -3, 1, 0)
        v113.Parent = v85
        local v114 = u15("Custom hanya server ini (username bisa \'all\').")
        v114.TextSize = 12
        v114.Parent = u79
        local v115 = Instance.new("Frame")
        v115.BackgroundTransparency = 1
        v115.Size = UDim2.new(1, 0, 0, 28)
        local v116 = Instance.new("UIListLayout")
        v116.FillDirection = Enum.FillDirection.Horizontal
        v116.Padding = UDim.new(0, 6)
        v116.SortOrder = Enum.SortOrder.LayoutOrder
        v116.Parent = v115
        v115.Parent = u79
        local v126 = u21("Custom Summit", function() --[[ Line: 251 ]]
            --[[
            Upvalues:
                [1] = u53
                [2] = u27
                [3] = u7
            --]]
            local u117 = "summit"
            u53("Custom (summit)", function(p118, p119) --[[ Line: 232 ]]
                --[[
                Upvalues:
                    [1] = u27
                    [2] = u117
                    [3] = u7
                --]]
                local v120, u121 = u27("Username / \'all\'")
                v120.Parent = p118
                local v122, u123 = u27("Value")
                v122.Parent = p118
                if u117 == "summit" then
                    u123.PlaceholderText = "Value Summit (+/\226\136\146 angka, mis. 10 atau \226\136\1465)"
                elseif u117 == "besttime" then
                    u123.PlaceholderText = "BestTime (+/\226\136\146 detik, mis. 30 atau \226\136\14615)"
                elseif u117 == "cash" then
                    u123.PlaceholderText = "Value Cash (+/\226\136\146 angka, mis. 500 atau \226\136\146100)"
                end
                p119(function() --[[ Line: 245 ]]
                    --[[
                    Upvalues:
                        [1] = u121
                        [2] = u123
                        [3] = u7
                        [4] = u117
                    --]]
                    local v124 = u121.Text
                    local v125 = u123.Text
                    if v124 ~= "" and v125 ~= "" then
                        u7:FireServer({
                            ["scope"] = "local",
                            ["action"] = "custom",
                            ["field"] = u117,
                            ["username"] = v124,
                            ["value"] = v125
                        })
                    end
                end)
            end)
        end, 28)
        local v136 = u21("Custom BestTime", function() --[[ Line: 252 ]]
            --[[
            Upvalues:
                [1] = u53
                [2] = u27
                [3] = u7
            --]]
            local u127 = "besttime"
            u53("Custom (besttime)", function(p128, p129) --[[ Line: 232 ]]
                --[[
                Upvalues:
                    [1] = u27
                    [2] = u127
                    [3] = u7
                --]]
                local v130, u131 = u27("Username / \'all\'")
                v130.Parent = p128
                local v132, u133 = u27("Value")
                v132.Parent = p128
                if u127 == "summit" then
                    u133.PlaceholderText = "Value Summit (+/\226\136\146 angka, mis. 10 atau \226\136\1465)"
                elseif u127 == "besttime" then
                    u133.PlaceholderText = "BestTime (+/\226\136\146 detik, mis. 30 atau \226\136\14615)"
                elseif u127 == "cash" then
                    u133.PlaceholderText = "Value Cash (+/\226\136\146 angka, mis. 500 atau \226\136\146100)"
                end
                p129(function() --[[ Line: 245 ]]
                    --[[
                    Upvalues:
                        [1] = u131
                        [2] = u133
                        [3] = u7
                        [4] = u127
                    --]]
                    local v134 = u131.Text
                    local v135 = u133.Text
                    if v134 ~= "" and v135 ~= "" then
                        u7:FireServer({
                            ["scope"] = "local",
                            ["action"] = "custom",
                            ["field"] = u127,
                            ["username"] = v134,
                            ["value"] = v135
                        })
                    end
                end)
            end)
        end, 28)
        local v146 = u21("Custom Cash", function() --[[ Line: 253 ]]
            --[[
            Upvalues:
                [1] = u53
                [2] = u27
                [3] = u7
            --]]
            local u137 = "cash"
            u53("Custom (cash)", function(p138, p139) --[[ Line: 232 ]]
                --[[
                Upvalues:
                    [1] = u27
                    [2] = u137
                    [3] = u7
                --]]
                local v140, u141 = u27("Username / \'all\'")
                v140.Parent = p138
                local v142, u143 = u27("Value")
                v142.Parent = p138
                if u137 == "summit" then
                    u143.PlaceholderText = "Value Summit (+/\226\136\146 angka, mis. 10 atau \226\136\1465)"
                elseif u137 == "besttime" then
                    u143.PlaceholderText = "BestTime (+/\226\136\146 detik, mis. 30 atau \226\136\14615)"
                elseif u137 == "cash" then
                    u143.PlaceholderText = "Value Cash (+/\226\136\146 angka, mis. 500 atau \226\136\146100)"
                end
                p139(function() --[[ Line: 245 ]]
                    --[[
                    Upvalues:
                        [1] = u141
                        [2] = u143
                        [3] = u7
                        [4] = u137
                    --]]
                    local v144 = u141.Text
                    local v145 = u143.Text
                    if v144 ~= "" and v145 ~= "" then
                        u7:FireServer({
                            ["scope"] = "local",
                            ["action"] = "custom",
                            ["field"] = u137,
                            ["username"] = v144,
                            ["value"] = v145
                        })
                    end
                end)
            end)
        end, 28)
        v126.Size = UDim2.new(0.3333333333333333, -4, 1, 0)
        v136.Size = v126.Size
        v146.Size = v126.Size
        v126.Parent = v115
        v136.Parent = v115
        v146.Parent = v115
        u57.Visible = false
        u57.Parent = v55
        return u57
    end
    v6.OnClientEvent:Connect(function() --[[ Name: show, Line 262 ]]
        --[[
        Upvalues:
            [1] = u147
        --]]
        u147().Visible = true
    end)
    u3.InputBegan:Connect(function(p148, p149) --[[ Line: 270 ]]
        --[[
        Upvalues:
            [1] = u5
        --]]
        if not p149 then
            if p148.KeyCode == Enum.KeyCode.Escape then
                local v150 = u5:FindFirstChildOfClass("PlayerGui")
                if not v150 then
                    return
                end
                local v151 = v150:FindFirstChild("HehAdminUI")
                if not v151 then
                    return
                end
                local v152 = v151:FindFirstChild("Root")
                if v152 then
                    v152.Visible = false
                end
            end
        end
    end)
    
    -- Ensure hierarchy exists even if server never fires HehAdmin_Open (executor / no server signal).
    do
        local root = u147()
        root.Visible = false
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

-- */  Recording Tab  /* --
local function createRecordingTab(windowRef, notifyFn)
    local RecordingTab = windowRef:CreateTab("Recording", 4483362458)

    RecordingTab:CreateSection("Record Roblox Activities")

    local RECORDINGS_DIR = "sempatpanick/mount_yahayuk/recordings"
    local RECORDING_SAMPLE_INTERVAL = 0.1
    local function resolveExecutorFn(name: string)
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

    local makeFolderFn = resolveExecutorFn("makefolder")
    local isFolderFn = resolveExecutorFn("isfolder")
    local writeFileFn = resolveExecutorFn("writefile")
    local listFilesFn = resolveExecutorFn("listfiles")
    local readFileFn = resolveExecutorFn("readfile")
    local delFileFn = resolveExecutorFn("delfile")
    local isFileFn = resolveExecutorFn("isfile")
    local setClipboardFn = resolveExecutorFn("setclipboard") or resolveExecutorFn("toclipboard")

    local recordingStatusParagraph
    local recordingInProgress = false
    local recordingToggleControl
    local recordingHotkeyConnection = nil
    local recordingToggleHotkey = Enum.KeyCode.Q
    local recordingStartedAt = 0
    local recordingEvents = {}
    local recordingConnections = {}
    local lastMovementSignature = nil
    local lastMovementCaptureAt = 0
    local lastSavedRecordingPath = ""
    local recordingPlayersDropdown
    local RECORDING_PLAYER_NONE = "(Select player)"
    local recordingPlayerOptions = { RECORDING_PLAYER_NONE }
    local recordingPlayerDisplayToUserId: { [string]: number } = {}
    local selectedRecordingPlayerUserId: number? = nil
    local selectedRecordingPlayerName: string? = nil
    local savedRecordingsDropdown
    local savedRecordingStatusParagraph
    local selectedSavedRecordingPath = nil
    local playbackToken = 0
    local playbackInProgress = false
    local playbackStartedAt = 0
    local playbackHumanoid = nil
    local playbackAutoRotateRestore = nil
    local playbackKeysDown: { [Enum.KeyCode]: boolean } = {}
    local SAVED_RECORDING_NONE = "(None)"
    local refreshRecordingPlayersDropdown = function() end
    local refreshSavedRecordingsDropdown = function(_showNotify: boolean?) end

    local VirtualInputManager = nil
    pcall(function()
        VirtualInputManager = game:GetService("VirtualInputManager")
    end)

    local function disconnectRecordingConnections()
        for i = #recordingConnections, 1, -1 do
            local conn = recordingConnections[i]
            if conn then
                pcall(function()
                    conn:Disconnect()
                end)
            end
            recordingConnections[i] = nil
        end
    end

    local function recordingNow()
        return math.max(0, os.clock() - recordingStartedAt)
    end

    local function updateRecordingParagraph(extraLine: string?)
        if not (recordingStatusParagraph and recordingStatusParagraph.Set) then
            return
        end
        local stateText = recordingInProgress and "Recording: ON" or "Recording: OFF"
        local targetText = selectedRecordingPlayerName or "(not selected)"
        local content = stateText
            .. "\nTarget: " .. targetText
            .. "\nEvents: " .. tostring(#recordingEvents)
            .. "\nLast file: " .. (lastSavedRecordingPath ~= "" and lastSavedRecordingPath or "(none)")
        if extraLine and extraLine ~= "" then
            content = content .. "\n" .. extraLine
        end
        recordingStatusParagraph:Set({
            Title = "Status",
            Content = content,
        })
    end

    local function appendRecordingEvent(kind: string, data: { [string]: any }?)
        if not recordingInProgress then
            return
        end
        table.insert(recordingEvents, {
            t = tonumber(string.format("%.3f", recordingNow())),
            kind = kind,
            data = data or {},
        })
    end

    local function splitPathSegments(path: string): { string }
        local segments = {}
        for piece in string.gmatch(path, "[^/]+") do
            if piece ~= "" and piece ~= "." then
                table.insert(segments, piece)
            end
        end
        return segments
    end

    local function normalizePath(path: string): string
        return string.gsub(path or "", "\\", "/")
    end

    local function baseNameFromPath(path: string): string
        local normalized = normalizePath(path)
        local idx = string.match(normalized, "^.*()/")
        if idx then
            return string.sub(normalized, idx + 1)
        end
        return normalized
    end

    local function isJsonPath(path: string): boolean
        return string.sub(string.lower(path), -5) == ".json"
    end

    local function updateSavedRecordingStatus(text: string)
        if not (savedRecordingStatusParagraph and savedRecordingStatusParagraph.Set) then
            return
        end
        savedRecordingStatusParagraph:Set({
            Title = "Saved Recording Status",
            Content = text,
        })
    end

    -- Release virtual keys, clear walk intent, and kill residual momentum (key_up alone does not).
    local function releaseSavedRecordingInputAndMotion()
        if VirtualInputManager then
            for keyCode, isDown in pairs(playbackKeysDown) do
                if isDown then
                    pcall(function()
                        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                    end)
                end
                playbackKeysDown[keyCode] = nil
            end
        else
            playbackKeysDown = {}
        end

        if playbackHumanoid then
            pcall(function()
                playbackHumanoid:Move(Vector3.new(0, 0, 0))
            end)
        end

        local localChar = Players.LocalPlayer and Players.LocalPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")
        if localRoot then
            pcall(function()
                localRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                localRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end)
        end
    end

    local function stopSavedRecordingPlayback(reason: string?, shouldNotify: boolean?)
        releaseSavedRecordingInputAndMotion()

        if playbackHumanoid and playbackAutoRotateRestore ~= nil then
            pcall(function()
                playbackHumanoid.AutoRotate = playbackAutoRotateRestore
            end)
        end
        playbackHumanoid = nil
        playbackAutoRotateRestore = nil
        playbackToken = playbackToken + 1
        if playbackInProgress then
            playbackInProgress = false
            local elapsed = math.max(0, os.clock() - playbackStartedAt)
            local elapsedText = string.format("%.2fs", elapsed)
            local note = reason or ("Stopped after " .. elapsedText)
            updateSavedRecordingStatus(note)
            if shouldNotify then
                notifyFn({ Title = "Recording Playback", Content = note, Icon = "info" })
            end
        elseif shouldNotify then
            notifyFn({ Title = "Recording Playback", Content = "No playback is running", Icon = "info" })
        end
    end

    local function refreshSelectionFromDropdownValue(value: any, pathMap: { [string]: string })
        local picked = (type(value) == "table" and value[1]) or value
        if type(picked) ~= "string" or picked == "" or picked == SAVED_RECORDING_NONE then
            selectedSavedRecordingPath = nil
            return
        end
        selectedSavedRecordingPath = pathMap[picked]
    end

    local function getSelectedRecordingPlayer(): Player?
        if type(selectedRecordingPlayerUserId) ~= "number" then
            return nil
        end
        for _, player in ipairs(Players:GetPlayers()) do
            if player.UserId == selectedRecordingPlayerUserId then
                return player
            end
        end
        return nil
    end

    local function ensureRecordingsDirectory()
        makeFolderFn = makeFolderFn or resolveExecutorFn("makefolder")
        isFolderFn = isFolderFn or resolveExecutorFn("isfolder")
        if type(makeFolderFn) ~= "function" then
            return false, "makefolder() is not available in this executor"
        end
        local segments = splitPathSegments(RECORDINGS_DIR)
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

    local function saveRecordingAsJson()
        writeFileFn = writeFileFn or resolveExecutorFn("writefile")
        if type(writeFileFn) ~= "function" then
            return nil, "writefile() is not available in this executor"
        end
        local okDir, dirErr = ensureRecordingsDirectory()
        if not okDir then
            return nil, dirErr or "Unable to create recordings folder"
        end

        local fileName = string.format(
            "recording_%s_%s.json",
            tostring(game.PlaceId or 0),
            os.date("!%Y%m%d_%H%M%S")
        )
        local path = RECORDINGS_DIR .. "/" .. fileName
        local payload = {
            meta = {
                placeId = game.PlaceId,
                gameId = game.GameId,
                jobId = game.JobId,
                playerName = selectedRecordingPlayerName or "unknown",
                recorderName = Players.LocalPlayer and Players.LocalPlayer.Name or "unknown",
                startedAtUtc = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                durationSeconds = tonumber(string.format("%.3f", math.max(0, recordingNow()))),
                totalEvents = #recordingEvents,
            },
            events = recordingEvents,
        }
        local okEncode, jsonText = pcall(function()
            return HttpService:JSONEncode(payload)
        end)
        if not okEncode then
            return nil, "JSON encode failed"
        end
        local okWrite, writeErr = pcall(function()
            writeFileFn(path, jsonText)
        end)
        if not okWrite then
            return nil, tostring(writeErr)
        end
        return path, nil
    end

    local function getCharacterHumanoidAndRoot(character: Model?)
        if not character then
            return nil, nil
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        return humanoid, rootPart
    end

    local function recordMovementSample(targetPlayer: Player?)
        local character = targetPlayer and targetPlayer.Character
        local humanoid, rootPart = getCharacterHumanoidAndRoot(character)
        if not humanoid or not rootPart then
            return
        end
        local moveDir = humanoid.MoveDirection
        local pos = rootPart.Position
        local vel = rootPart.AssemblyLinearVelocity
        local look = rootPart.CFrame.LookVector
        local grounded = humanoid.FloorMaterial ~= Enum.Material.Air
        local signature = string.format(
            "%.2f|%.2f|%.2f|%.2f|%.2f|%.2f|%.2f|%.2f|%.2f|%.2f|%.2f|%.2f|%s",
            moveDir.X, moveDir.Y, moveDir.Z,
            pos.X, pos.Y, pos.Z,
            vel.X, vel.Y, vel.Z,
            look.X, look.Y, look.Z,
            grounded and "1" or "0"
        )
        if signature == lastMovementSignature then
            return
        end
        lastMovementSignature = signature
        appendRecordingEvent("movement", {
            moveDirection = {
                x = tonumber(string.format("%.3f", moveDir.X)),
                y = tonumber(string.format("%.3f", moveDir.Y)),
                z = tonumber(string.format("%.3f", moveDir.Z)),
            },
            position = {
                x = tonumber(string.format("%.3f", pos.X)),
                y = tonumber(string.format("%.3f", pos.Y)),
                z = tonumber(string.format("%.3f", pos.Z)),
            },
            velocity = {
                x = tonumber(string.format("%.3f", vel.X)),
                y = tonumber(string.format("%.3f", vel.Y)),
                z = tonumber(string.format("%.3f", vel.Z)),
            },
            lookDirection = {
                x = tonumber(string.format("%.3f", look.X)),
                y = tonumber(string.format("%.3f", look.Y)),
                z = tonumber(string.format("%.3f", look.Z)),
            },
            isGrounded = grounded,
            walkSpeed = tonumber(string.format("%.3f", humanoid.WalkSpeed)),
            jumpPower = tonumber(string.format("%.3f", humanoid.JumpPower)),
            jumpHeight = tonumber(string.format("%.3f", humanoid.JumpHeight)),
        })
    end

    local function attachCharacterRecordingHooks(character: Model?)
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            appendRecordingEvent("character_missing_humanoid", {})
            return
        end
        appendRecordingEvent("character_hooked", {
            characterName = (character and character.Name) or "unknown",
        })
        table.insert(recordingConnections, humanoid.StateChanged:Connect(function(_, newState)
            if not recordingInProgress then
                return
            end
            if newState == Enum.HumanoidStateType.Jumping
                or newState == Enum.HumanoidStateType.Freefall
                or newState == Enum.HumanoidStateType.Landed
            then
                appendRecordingEvent("humanoid_state", {
                    state = tostring(newState),
                })
            end
        end))
    end

    local function startRecording()
        if recordingInProgress then
            notifyFn({ Title = "Recording", Content = "Already recording", Icon = "info" })
            return false
        end

        local targetPlayer = getSelectedRecordingPlayer()
        if not targetPlayer then
            updateRecordingParagraph("Select a player first")
            notifyFn({ Title = "Recording", Content = "Select a player before recording", Icon = "x" })
            return false
        end
        local recordLocalInputs = targetPlayer == Players.LocalPlayer

        disconnectRecordingConnections()
        recordingEvents = {}
        recordingStartedAt = os.clock()
        lastMovementSignature = nil
        lastMovementCaptureAt = 0
        recordingInProgress = true

        appendRecordingEvent("recording_started", {
            placeId = game.PlaceId,
            playerName = targetPlayer.Name,
            playerUserId = targetPlayer.UserId,
            recorderName = Players.LocalPlayer and Players.LocalPlayer.Name or "unknown",
            recordKeyboardInputs = recordLocalInputs,
        })

        table.insert(recordingConnections, UserInputService.InputBegan:Connect(function(input, gameProcessed)
            if not recordingInProgress then
                return
            end
            if not recordLocalInputs then
                return
            end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                if input.KeyCode == recordingToggleHotkey then
                    return
                end
                appendRecordingEvent("key_down", {
                    keyCode = tostring(input.KeyCode),
                    gameProcessed = gameProcessed == true,
                })
            end
        end))

        table.insert(recordingConnections, UserInputService.InputEnded:Connect(function(input, gameProcessed)
            if not recordingInProgress then
                return
            end
            if not recordLocalInputs then
                return
            end
            if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                if input.KeyCode == recordingToggleHotkey then
                    return
                end
                appendRecordingEvent("key_up", {
                    keyCode = tostring(input.KeyCode),
                    gameProcessed = gameProcessed == true,
                })
            end
        end))

        table.insert(recordingConnections, UserInputService.JumpRequest:Connect(function()
            if not recordLocalInputs then
                return
            end
            appendRecordingEvent("jump_request", {})
        end))

        table.insert(recordingConnections, targetPlayer.CharacterAdded:Connect(function(newCharacter)
            appendRecordingEvent("character_added", {
                characterName = newCharacter and newCharacter.Name or "unknown",
            })
            attachCharacterRecordingHooks(newCharacter)
        end))

        attachCharacterRecordingHooks(targetPlayer.Character)

        table.insert(recordingConnections, RunService.Heartbeat:Connect(function()
            if not recordingInProgress then
                return
            end
            local now = recordingNow()
            if (now - lastMovementCaptureAt) < RECORDING_SAMPLE_INTERVAL then
                return
            end
            lastMovementCaptureAt = now
            recordMovementSample(targetPlayer)
        end))

        updateRecordingParagraph("Capture started")
        notifyFn({ Title = "Recording", Content = "Recording started for " .. targetPlayer.Name, Icon = "check" })
        return true
    end

    local function stopRecording()
        if not recordingInProgress then
            notifyFn({ Title = "Recording", Content = "No active recording", Icon = "info" })
            return
        end

        appendRecordingEvent("recording_stopped", {
            totalEvents = #recordingEvents,
        })

        recordingInProgress = false
        disconnectRecordingConnections()

        local savedPath, saveErr = saveRecordingAsJson()
        if savedPath then
            lastSavedRecordingPath = savedPath
            notifyFn({
                Title = "Recording",
                Content = "Saved " .. tostring(#recordingEvents) .. " events to " .. savedPath,
                Icon = "check",
            })
            updateRecordingParagraph("Saved to " .. savedPath)
            refreshSavedRecordingsDropdown(false)
        else
            notifyFn({
                Title = "Recording",
                Content = "Failed to save: " .. tostring(saveErr),
                Icon = "x",
            })
            updateRecordingParagraph("Save failed: " .. tostring(saveErr))
        end
    end

    recordingStatusParagraph = RecordingTab:CreateParagraph({
        Title = "Status",
        Content = "Recording: OFF\nTarget: (not selected)\nEvents: 0\nLast file: (none)",
    })

    refreshRecordingPlayersDropdown = function()
        recordingPlayerOptions = { RECORDING_PLAYER_NONE }
        recordingPlayerDisplayToUserId = {}

        local localPlayer = Players.LocalPlayer
        local playersList = Players:GetPlayers()
        table.sort(playersList, function(a, b)
            local aDisplay = string.lower(a.DisplayName or a.Name or "")
            local bDisplay = string.lower(b.DisplayName or b.Name or "")
            if aDisplay == bDisplay then
                return string.lower(a.Name) < string.lower(b.Name)
            end
            return aDisplay < bDisplay
        end)
        local displayLabelCount: { [string]: number } = {}

        for _, player in ipairs(playersList) do
            local displayName = player.DisplayName or player.Name
            if localPlayer and player == localPlayer then
                displayName = displayName .. " (me)"
            end
            local count = (displayLabelCount[displayName] or 0) + 1
            displayLabelCount[displayName] = count
            if count > 1 then
                displayName = displayName .. " [" .. tostring(count) .. "]"
            end
            table.insert(recordingPlayerOptions, displayName)
            recordingPlayerDisplayToUserId[displayName] = player.UserId
        end

        if recordingPlayersDropdown and recordingPlayersDropdown.Refresh then
            recordingPlayersDropdown:Refresh(recordingPlayerOptions)
        end

        if type(selectedRecordingPlayerUserId) == "number" then
            local selectedStillExists = false
            for _, player in ipairs(playersList) do
                if player.UserId == selectedRecordingPlayerUserId then
                    selectedStillExists = true
                    selectedRecordingPlayerName = player.Name
                    break
                end
            end
            if not selectedStillExists then
                selectedRecordingPlayerUserId = nil
                selectedRecordingPlayerName = nil
                if recordingPlayersDropdown and recordingPlayersDropdown.Set then
                    recordingPlayersDropdown:Set({ RECORDING_PLAYER_NONE })
                end
            end
        end

        updateRecordingParagraph()
    end

    recordingPlayersDropdown = RecordingTab:CreateDropdown({
        Name = "Players",
        Options = recordingPlayerOptions,
        CurrentOption = { RECORDING_PLAYER_NONE },
        Search = true,
        Callback = function(value)
            local picked = (type(value) == "table" and value[1]) or value
            if type(picked) ~= "string" or picked == "" or picked == RECORDING_PLAYER_NONE then
                selectedRecordingPlayerUserId = nil
                selectedRecordingPlayerName = nil
                updateRecordingParagraph("Select a player to start recording")
                return
            end
            local pickedUserId = recordingPlayerDisplayToUserId[picked]
            if type(pickedUserId) == "number" then
                selectedRecordingPlayerUserId = pickedUserId
                local selectedPlayer = getSelectedRecordingPlayer()
                selectedRecordingPlayerName = selectedPlayer and selectedPlayer.Name or nil
                updateRecordingParagraph()
            else
                selectedRecordingPlayerUserId = nil
                selectedRecordingPlayerName = nil
                updateRecordingParagraph("Selected player is unavailable")
            end
        end,
    })
    refreshRecordingPlayersDropdown()
    Players.PlayerAdded:Connect(function()
        refreshRecordingPlayersDropdown()
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(function()
            refreshRecordingPlayersDropdown()
        end)
    end)

    local function setRecordingEnabled(enabled: boolean): boolean
        if enabled then
            if not recordingInProgress then
                return startRecording()
            end
            return true
        else
            if recordingInProgress then
                stopRecording()
            end
            return true
        end
    end

    local function syncRecordingToggleUi(enabled: boolean)
        if not recordingToggleControl then
            return
        end
        if recordingToggleControl.Set then
            pcall(function()
                recordingToggleControl:Set(enabled)
            end)
            return
        end
        if recordingToggleControl.SetValue then
            pcall(function()
                recordingToggleControl:SetValue(enabled)
            end)
        end
    end

    RecordingTab:CreateParagraph({
        Title = "Keybind",
        Content = "Press Q to toggle recording ON/OFF",
    })

    recordingToggleControl = RecordingTab:CreateToggle({
        Name = "Recording (toggle ON/OFF)",
        CurrentValue = false,
        Callback = function(enabled)
            local shouldEnable = enabled == true
            local ok = setRecordingEnabled(shouldEnable)
            if shouldEnable and not ok then
                syncRecordingToggleUi(false)
            end
        end,
    })

    if recordingHotkeyConnection then
        pcall(function()
            recordingHotkeyConnection:Disconnect()
        end)
    end
    recordingHotkeyConnection = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then
            return
        end
        if UserInputService:GetFocusedTextBox() then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.Keyboard or input.KeyCode ~= recordingToggleHotkey then
            return
        end
        local nextEnabled = not recordingInProgress
        local ok = setRecordingEnabled(nextEnabled)
        if nextEnabled and not ok then
            nextEnabled = false
        end
        syncRecordingToggleUi(nextEnabled)
    end)

    RecordingTab:CreateSection("Saved Recording")

    local savedDisplayToPath = {}
    local savedDisplayOptions = { SAVED_RECORDING_NONE }

    refreshSavedRecordingsDropdown = function(showNotify: boolean?)
        selectedSavedRecordingPath = nil
        savedDisplayToPath = {}
        savedDisplayOptions = { SAVED_RECORDING_NONE }

        if type(listFilesFn) ~= "function" then
            listFilesFn = listFilesFn or resolveExecutorFn("listfiles")
        end
        if type(listFilesFn) ~= "function" then
            updateSavedRecordingStatus("listfiles() is not available in this executor")
            if showNotify then
                notifyFn({ Title = "Saved Recording", Content = "listfiles() is not available", Icon = "x" })
            end
            if savedRecordingsDropdown and savedRecordingsDropdown.Refresh then
                savedRecordingsDropdown:Refresh(savedDisplayOptions)
            end
            return
        end

        ensureRecordingsDirectory()
        local okList, filesOrErr = pcall(function()
            return listFilesFn(RECORDINGS_DIR)
        end)
        if not okList or type(filesOrErr) ~= "table" then
            updateSavedRecordingStatus("Failed to list recordings")
            if showNotify then
                notifyFn({
                    Title = "Saved Recording",
                    Content = "Failed to list recordings: " .. tostring(filesOrErr),
                    Icon = "x",
                })
            end
            if savedRecordingsDropdown and savedRecordingsDropdown.Refresh then
                savedRecordingsDropdown:Refresh(savedDisplayOptions)
            end
            return
        end

        local candidates = {}
        for _, item in ipairs(filesOrErr) do
            if type(item) == "string" then
                local normalized = normalizePath(item)
                if isJsonPath(normalized) then
                    table.insert(candidates, item)
                end
            end
        end
        table.sort(candidates, function(a, b)
            return string.lower(normalizePath(a)) > string.lower(normalizePath(b))
        end)

        local displayCount = {}
        for _, path in ipairs(candidates) do
            local display = baseNameFromPath(path)
            local count = (displayCount[display] or 0) + 1
            displayCount[display] = count
            if count > 1 then
                display = display .. " [" .. tostring(count) .. "]"
            end
            table.insert(savedDisplayOptions, display)
            savedDisplayToPath[display] = path
        end

        if savedRecordingsDropdown and savedRecordingsDropdown.Refresh then
            savedRecordingsDropdown:Refresh(savedDisplayOptions)
        end

        updateSavedRecordingStatus("Loaded " .. tostring(#candidates) .. " recording file(s)")
        if showNotify then
            notifyFn({
                Title = "Saved Recording",
                Content = "Loaded " .. tostring(#candidates) .. " recording file(s)",
                Icon = "check",
            })
        end
    end

    savedRecordingsDropdown = RecordingTab:CreateDropdown({
        Name = "Saved recordings",
        Options = savedDisplayOptions,
        CurrentOption = { SAVED_RECORDING_NONE },
        Search = true,
        Ext = true,
        Callback = function(value)
            refreshSelectionFromDropdownValue(value, savedDisplayToPath)
            if selectedSavedRecordingPath then
                updateSavedRecordingStatus("Selected: " .. baseNameFromPath(selectedSavedRecordingPath))
            else
                updateSavedRecordingStatus("Select a recording file")
            end
        end,
    })

    savedRecordingStatusParagraph = RecordingTab:CreateParagraph({
        Title = "Saved Recording Status",
        Content = "Select a recording file",
    })

    RecordingTab:CreateButton({
        Name = "Play",
        Ext = true,
        Callback = function()
            if not selectedSavedRecordingPath then
                notifyFn({ Title = "Recording Playback", Content = "Select a saved recording first", Icon = "x" })
                return
            end
            readFileFn = readFileFn or resolveExecutorFn("readfile")
            isFileFn = isFileFn or resolveExecutorFn("isfile")
            if type(readFileFn) ~= "function" then
                notifyFn({ Title = "Recording Playback", Content = "readfile() is not available", Icon = "x" })
                return
            end
            if type(isFileFn) == "function" then
                local okFile, exists = pcall(function()
                    return isFileFn(selectedSavedRecordingPath)
                end)
                if okFile and not exists then
                    notifyFn({ Title = "Recording Playback", Content = "Selected file no longer exists", Icon = "x" })
                    refreshSavedRecordingsDropdown(false)
                    return
                end
            end

            local okRead, jsonText = pcall(function()
                return readFileFn(selectedSavedRecordingPath)
            end)
            if not okRead then
                notifyFn({ Title = "Recording Playback", Content = "Failed to read file", Icon = "x" })
                return
            end
            local okDecode, payload = pcall(function()
                return HttpService:JSONDecode(jsonText)
            end)
            if not okDecode or type(payload) ~= "table" then
                notifyFn({ Title = "Recording Playback", Content = "Invalid recording JSON", Icon = "x" })
                return
            end
            local events = payload.events
            if type(events) ~= "table" or #events == 0 then
                notifyFn({ Title = "Recording Playback", Content = "Recording has no events", Icon = "x" })
                return
            end

            stopSavedRecordingPlayback(nil, false)
            playbackToken = playbackToken + 1
            local token = playbackToken
            playbackInProgress = true
            playbackStartedAt = os.clock()
            playbackHumanoid = nil
            playbackAutoRotateRestore = nil
            playbackKeysDown = {}

            local nextMovementDeltaByIndex = {}
            local nextMovementTime = nil
            for i = #events, 1, -1 do
                local ev = events[i]
                local evTime = tonumber(ev.t) or 0
                if ev.kind == "movement" then
                    nextMovementDeltaByIndex[i] = nextMovementTime and math.max(0, nextMovementTime - evTime) or nil
                    nextMovementTime = evTime
                else
                    nextMovementDeltaByIndex[i] = nil
                end
            end

            local selectedName = baseNameFromPath(selectedSavedRecordingPath)
            updateSavedRecordingStatus("Playing: " .. selectedName)
            notifyFn({
                Title = "Recording Playback",
                Content = "Playing " .. selectedName .. " (" .. tostring(#events) .. " events)",
                Icon = "check",
            })

            task.spawn(function()
                local function buildMovementTargetCFrame(rootPart, dataTable)
                    local pos = dataTable.position
                    if not rootPart or type(pos) ~= "table" then
                        return nil
                    end
                    local x = tonumber(pos.x)
                    local y = tonumber(pos.y)
                    local z = tonumber(pos.z)
                    if not (x and y and z) then
                        return nil
                    end

                    local basePos = Vector3.new(x, y, z)
                    local lookData = dataTable.lookDirection
                    local lx, ly, lz = nil, nil, nil
                    if type(lookData) == "table" then
                        lx = tonumber(lookData.x)
                        ly = tonumber(lookData.y)
                        lz = tonumber(lookData.z)
                    end
                    if lx and ly and lz then
                        local lookVec = Vector3.new(lx, ly, lz)
                        if lookVec.Magnitude > 1e-4 then
                            local planar = Vector3.new(lookVec.X, 0, lookVec.Z)
                            if planar.Magnitude > 1e-4 then
                                return CFrame.lookAt(basePos, basePos + planar.Unit)
                            end
                        end
                    end

                    local fallback = rootPart.CFrame.LookVector
                    local fallbackPlanar = Vector3.new(fallback.X, 0, fallback.Z)
                    if fallbackPlanar.Magnitude > 1e-4 then
                        return CFrame.lookAt(basePos, basePos + fallbackPlanar.Unit)
                    end
                    return CFrame.new(basePos)
                end

                local function applySmoothRootCFrame(rootPart, targetCf, durationSec)
                    if durationSec <= 0.015 then
                        rootPart.CFrame = targetCf
                        return
                    end
                    local startCf = rootPart.CFrame
                    local t0 = os.clock()
                    while token == playbackToken do
                        local alpha = (os.clock() - t0) / durationSec
                        if alpha >= 1 then
                            break
                        end
                        rootPart.CFrame = startCf:Lerp(targetCf, math.clamp(alpha, 0, 1))
                        task.wait()
                    end
                    if token == playbackToken then
                        rootPart.CFrame = targetCf
                    end
                end

                local started = os.clock()
                for i, event in ipairs(events) do
                    if token ~= playbackToken then
                        return
                    end

                    local targetT = tonumber(event.t) or 0
                    while token == playbackToken and (os.clock() - started) < targetT do
                        task.wait(0.01)
                    end
                    if token ~= playbackToken then
                        return
                    end

                    local kind = event.kind
                    local data = type(event.data) == "table" and event.data or {}
                    local character = Players.LocalPlayer and Players.LocalPlayer.Character
                    local humanoid, rootPart = getCharacterHumanoidAndRoot(character)

                    if humanoid and playbackHumanoid ~= humanoid then
                        if playbackHumanoid and playbackAutoRotateRestore ~= nil then
                            pcall(function()
                                playbackHumanoid.AutoRotate = playbackAutoRotateRestore
                            end)
                        end
                        playbackHumanoid = humanoid
                        playbackAutoRotateRestore = humanoid.AutoRotate
                        pcall(function()
                            humanoid.AutoRotate = false
                        end)
                    end

                    if kind == "movement" then
                        local targetCf = buildMovementTargetCFrame(rootPart, data)
                        if rootPart and targetCf then
                            local nextDelta = nextMovementDeltaByIndex[i]
                            local smoothDuration = nextDelta and math.clamp(nextDelta * 0.8, 0.03, 0.14) or 0.07
                            pcall(function()
                                applySmoothRootCFrame(rootPart, targetCf, smoothDuration)
                            end)
                        end
                    elseif kind == "jump_request" then
                        if humanoid then
                            pcall(function()
                                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                            end)
                        end
                    elseif (kind == "key_down" or kind == "key_up") and VirtualInputManager then
                        local keyCodeName = type(data.keyCode) == "string" and data.keyCode or ""
                        local enumName = string.match(keyCodeName, "Enum%.KeyCode%.(.+)")
                        local keyCode = enumName and Enum.KeyCode[enumName]
                        if keyCode then
                            local isDown = kind == "key_down"
                            pcall(function()
                                VirtualInputManager:SendKeyEvent(isDown, keyCode, false, game)
                            end)
                            playbackKeysDown[keyCode] = isDown or nil
                        end
                    end
                end

                if token == playbackToken then
                    releaseSavedRecordingInputAndMotion()
                    if playbackHumanoid and playbackAutoRotateRestore ~= nil then
                        pcall(function()
                            playbackHumanoid.AutoRotate = playbackAutoRotateRestore
                        end)
                    end
                    playbackHumanoid = nil
                    playbackAutoRotateRestore = nil
                    playbackInProgress = false
                    updateSavedRecordingStatus("Playback finished: " .. selectedName)
                    notifyFn({
                        Title = "Recording Playback",
                        Content = "Finished " .. selectedName,
                        Icon = "check",
                    })
                end
            end)
        end,
    })

    RecordingTab:CreateButton({
        Name = "Stop",
        Ext = true,
        Callback = function()
            stopSavedRecordingPlayback("Playback stopped", true)
        end,
    })

    RecordingTab:CreateButton({
        Name = "Export",
        Ext = true,
        Callback = function()
            if not selectedSavedRecordingPath then
                notifyFn({ Title = "Saved Recording", Content = "Select a saved recording first", Icon = "x" })
                return
            end
            readFileFn = readFileFn or resolveExecutorFn("readfile")
            setClipboardFn = setClipboardFn or resolveExecutorFn("setclipboard") or resolveExecutorFn("toclipboard")
            if type(readFileFn) ~= "function" then
                notifyFn({ Title = "Saved Recording", Content = "readfile() is not available", Icon = "x" })
                return
            end
            if type(setClipboardFn) ~= "function" then
                notifyFn({ Title = "Saved Recording", Content = "Clipboard is not available", Icon = "x" })
                return
            end

            local okRead, jsonText = pcall(function()
                return readFileFn(selectedSavedRecordingPath)
            end)
            if not okRead then
                notifyFn({ Title = "Saved Recording", Content = "Failed to read selected file", Icon = "x" })
                return
            end

            local okCopy, copyErr = pcall(function()
                setClipboardFn(jsonText)
            end)
            if not okCopy then
                notifyFn({
                    Title = "Saved Recording",
                    Content = "Failed to copy JSON: " .. tostring(copyErr),
                    Icon = "x",
                })
                return
            end

            notifyFn({
                Title = "Saved Recording",
                Content = "JSON copied from " .. baseNameFromPath(selectedSavedRecordingPath),
                Icon = "check",
            })
            updateSavedRecordingStatus("Exported JSON to clipboard")
        end,
    })

    RecordingTab:CreateButton({
        Name = "Remove",
        Ext = true,
        Callback = function()
            if not selectedSavedRecordingPath then
                notifyFn({ Title = "Saved Recording", Content = "Select a saved recording first", Icon = "x" })
                return
            end
            delFileFn = delFileFn or resolveExecutorFn("delfile")
            if type(delFileFn) ~= "function" then
                notifyFn({ Title = "Saved Recording", Content = "delfile() is not available", Icon = "x" })
                return
            end

            stopSavedRecordingPlayback(nil, false)
            local removedName = baseNameFromPath(selectedSavedRecordingPath)
            local okDelete, deleteErr = pcall(function()
                delFileFn(selectedSavedRecordingPath)
            end)
            if not okDelete then
                notifyFn({
                    Title = "Saved Recording",
                    Content = "Failed to remove file: " .. tostring(deleteErr),
                    Icon = "x",
                })
                return
            end

            notifyFn({
                Title = "Saved Recording",
                Content = "Removed " .. removedName,
                Icon = "check",
            })
            refreshSavedRecordingsDropdown(false)
            updateSavedRecordingStatus("Removed " .. removedName)
        end,
    })

    RecordingTab:CreateButton({
        Name = "Refresh Saved List",
        Ext = true,
        Callback = function()
            refreshSavedRecordingsDropdown(true)
        end,
    })

    refreshSavedRecordingsDropdown(false)
end

local function rayfieldDropdownFirst(valueOrTable)
    if type(valueOrTable) == "table" then
        return valueOrTable[1]
    end
    return valueOrTable
end

-- */  Window  /* --
local Window = RayfieldLibrary:CreateWindow({
    Name = "sempatpanick | Mount Yahayuk",
    LoadingTitle = "sempatpanick",
    LoadingSubtitle = "Mount Yahayuk",
    Icon = 4483362458,
    ConfigurationSaving = {
        Enabled = false,
        FolderName = "sempatpanick",
        FileName = "mount_yahayuk",
    },
    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,
})

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
do
    local LocalPlayerTab = Window:CreateTab("Local Player", 4483362458)

    LocalPlayerTab:CreateSection("Misc")

    local infiniteJumpConnection = nil
    local antiAfkConnection = nil
    local noClipEnabled = false
    local cameraPenetrateEnabled = false
    local defaultCameraOcclusionMode = Players.LocalPlayer.DevCameraOcclusionMode
    local flyEnabled = false
    local flySpeed = 50
    local flyBV, flyBG = nil, nil
    local flyConnection = nil
    local flyKeys = {}
    local freeCameraEnabled = false
    local freeCameraConnection = nil
    local freeCameraDragBeganConn = nil
    local freeCameraDragEndedConn = nil
    local freeCameraDragging = false
    local freeCameraSpeed = 50
    local freeCameraSensitivity = 0.5
    local freeCameraCf = nil

    local function stopFly()
        if flyConnection then
            flyConnection:Disconnect()
            flyConnection = nil
        end
        if flyBV then flyBV:Destroy() flyBV = nil end
        if flyBG then flyBG:Destroy() flyBG = nil end
        local character = Players.LocalPlayer.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then humanoid.PlatformStand = false end
        end
    end

    local function startFly()
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not rootPart or not humanoid then return end
        stopFly()
        flyBV = Instance.new("BodyVelocity")
        flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        flyBV.Velocity = Vector3.new(0, 0, 0)
        flyBV.Parent = rootPart
        flyBG = Instance.new("BodyGyro")
        flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        flyBG.P = 9e4
        flyBG.D = 500
        flyBG.Parent = rootPart
        humanoid.PlatformStand = true
        flyConnection = RunService.Heartbeat:Connect(function()
            if not flyEnabled or not rootPart or not rootPart.Parent then
                stopFly()
                return
            end
            local cam = Workspace.CurrentCamera
            if not cam then return end
            local look = cam.CFrame.LookVector
            local right = cam.CFrame.RightVector
            local move = Vector3.new(0, 0, 0)
            if flyKeys[Enum.KeyCode.W] then move = move + look end
            if flyKeys[Enum.KeyCode.S] then move = move - look end
            if flyKeys[Enum.KeyCode.D] then move = move + right end
            if flyKeys[Enum.KeyCode.A] then move = move - right end
            if flyKeys[Enum.KeyCode.Space] then move = move + Vector3.new(0, 1, 0) end
            if flyKeys[Enum.KeyCode.LeftControl] or flyKeys[Enum.KeyCode.RightControl] then move = move - Vector3.new(0, 1, 0) end
            if move.Magnitude > 0 then
                move = move.Unit * flySpeed
            end
            flyBV.Velocity = move
            flyBG.CFrame = cam.CFrame
        end)
    end

    local function applyNoClip(character, enabled)
        if not character then return end
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = not enabled
            end
        end
    end

    local function startAntiAfk()
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
        local localPlayer = Players.LocalPlayer
        antiAfkConnection = localPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end

    local function stopAntiAfk()
        if antiAfkConnection then
            antiAfkConnection:Disconnect()
            antiAfkConnection = nil
        end
    end

    startAntiAfk()

    LocalPlayerTab:CreateToggle({
        Name = "Anti AFK",
        CurrentValue = true,
        Callback = function(enabled)
            if enabled then
                startAntiAfk()
            else
                stopAntiAfk()
            end
        end
    })

    LocalPlayerTab:CreateToggle({
        Name = "Infinite Jump",
        CurrentValue = false,
        Callback = function(enabled)
            if infiniteJumpConnection then
                infiniteJumpConnection:Disconnect()
                infiniteJumpConnection = nil
            end
            if enabled then
                infiniteJumpConnection = UserInputService.JumpRequest:Connect(function()
                    local character = Players.LocalPlayer.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid then
                            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                        end
                    end
                end)
            end
        end
    })

    LocalPlayerTab:CreateToggle({
        Name = "No Clip",
        CurrentValue = false,
        Callback = function(enabled)
            noClipEnabled = enabled
            local character = Players.LocalPlayer.Character
            applyNoClip(character, enabled)
        end
    })

    do
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
                flyKeys[input.KeyCode] = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.W or input.KeyCode == Enum.KeyCode.S or input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Space or input.KeyCode == Enum.KeyCode.LeftControl or input.KeyCode == Enum.KeyCode.RightControl then
                flyKeys[input.KeyCode] = false
            end
        end)
    end

    LocalPlayerTab:CreateToggle({
        Name = "Fly",
        CurrentValue = false,
        Callback = function(enabled)
            flyEnabled = enabled
            if enabled then
                startFly()
            else
                stopFly()
            end
        end
    })

    local savedMouseBehavior = nil
    local savedMouseIconEnabled = nil

    local function stopFreeCamera()
        if freeCameraConnection then
            freeCameraConnection:Disconnect()
            freeCameraConnection = nil
        end
        if freeCameraDragBeganConn then
            freeCameraDragBeganConn:Disconnect()
            freeCameraDragBeganConn = nil
        end
        if freeCameraDragEndedConn then
            freeCameraDragEndedConn:Disconnect()
            freeCameraDragEndedConn = nil
        end
        freeCameraDragging = false
        if savedMouseBehavior ~= nil then
            UserInputService.MouseBehavior = savedMouseBehavior
            savedMouseBehavior = nil
        end
        if savedMouseIconEnabled ~= nil then
            UserInputService.MouseIconEnabled = savedMouseIconEnabled
            savedMouseIconEnabled = nil
        end
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then rootPart.Anchored = false end
        local cam = Workspace.CurrentCamera
        if cam then
            cam.CameraType = Enum.CameraType.Custom
            cam.CameraSubject = character and character:FindFirstChildOfClass("Humanoid")
        end
    end

    local function startFreeCamera()
        stopFreeCamera()
        local cam = Workspace.CurrentCamera
        if not cam then return end
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if rootPart then rootPart.Anchored = true end
        savedMouseBehavior = UserInputService.MouseBehavior
        savedMouseIconEnabled = UserInputService.MouseIconEnabled
        UserInputService.MouseBehavior = Enum.MouseBehavior.Default
        UserInputService.MouseIconEnabled = true
        freeCameraCf = cam.CFrame
        cam.CameraType = Enum.CameraType.Scriptable
        freeCameraDragBeganConn = UserInputService.InputBegan:Connect(function(input)
            if freeCameraEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2) then
                freeCameraDragging = true
                UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
                UserInputService.MouseIconEnabled = false
            end
        end)
        freeCameraDragEndedConn = UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
                freeCameraDragging = false
                UserInputService.MouseBehavior = Enum.MouseBehavior.Default
                UserInputService.MouseIconEnabled = true
            end
        end)
        freeCameraConnection = RunService.RenderStepped:Connect(function()
            if not freeCameraEnabled or not freeCameraCf then
                stopFreeCamera()
                return
            end
            if freeCameraDragging then
                local delta = UserInputService:GetMouseDelta()
                local pos = freeCameraCf.Position
                local look = freeCameraCf.LookVector
                local right = freeCameraCf.RightVector
                -- Yaw: rotate around world Y so horizontal mouse is level
                local yaw = math.rad(delta.X * freeCameraSensitivity)
                local cy, sy = math.cos(yaw), math.sin(yaw)
                look = Vector3.new(look.X * cy - look.Z * sy, look.Y, look.X * sy + look.Z * cy).Unit
                right = Vector3.new(right.X * cy - right.Z * sy, right.Y, right.X * sy + right.Z * cy).Unit
                -- Pitch: rotate look around right so vertical mouse is straight up/down
                local up = right:Cross(look).Unit
                local pitch = math.rad(-delta.Y * freeCameraSensitivity)
                look = (look * math.cos(pitch) + up * math.sin(pitch)).Unit
                freeCameraCf = CFrame.fromMatrix(pos, right, right:Cross(look))
            end
            local look = freeCameraCf.LookVector
            local right = freeCameraCf.RightVector
            local move = Vector3.new(0, 0, 0)
            if flyKeys[Enum.KeyCode.W] then move = move + look end
            if flyKeys[Enum.KeyCode.S] then move = move - look end
            if flyKeys[Enum.KeyCode.D] then move = move + right end
            if flyKeys[Enum.KeyCode.A] then move = move - right end
            if flyKeys[Enum.KeyCode.Space] then move = move + Vector3.new(0, 1, 0) end
            if flyKeys[Enum.KeyCode.LeftControl] or flyKeys[Enum.KeyCode.RightControl] then move = move - Vector3.new(0, 1, 0) end
            if move.Magnitude > 0 then
                move = move.Unit * freeCameraSpeed * 0.016
            end
            freeCameraCf = freeCameraCf + move
            cam.CFrame = freeCameraCf
        end)
    end

    LocalPlayerTab:CreateToggle({
        Name = "Free Camera",
        CurrentValue = false,
        Callback = function(enabled)
            freeCameraEnabled = enabled
            if enabled then
                startFreeCamera()
            else
                stopFreeCamera()
            end
        end
    })

    LocalPlayerTab:CreateToggle({
        Name = "Camera Penetrate",
        CurrentValue = false,
        Callback = function(enabled)
            cameraPenetrateEnabled = enabled
            local lp = Players.LocalPlayer
            if cameraPenetrateEnabled then
                lp.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
            else
                lp.DevCameraOcclusionMode = defaultCameraOcclusionMode
            end
        end
    })

    do
        Players.LocalPlayer.CharacterAdded:Connect(function(character)
            if flyEnabled then
                task.defer(function() startFly() end)
            end
            if noClipEnabled then
                applyNoClip(character, true)
                character.DescendantAdded:Connect(function(part)
                    if noClipEnabled and part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end)
            end
        end)
        if noClipEnabled and Players.LocalPlayer.Character then
            applyNoClip(Players.LocalPlayer.Character, true)
        end
    end

    LocalPlayerTab:CreateSection("Walk Speed")

    local defaultWalkSpeed = 16

    local function getCurrentCharacterWalkSpeed()
        local character = Players.LocalPlayer.Character
        if not character then
            return nil, "Character not loaded"
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return nil, "Humanoid not found"
        end
        return humanoid.WalkSpeed
    end

    local currentWalkSpeed = getCurrentCharacterWalkSpeed()
    local walkSpeedValue = tostring(currentWalkSpeed or defaultWalkSpeed)

    local WalkSpeedInput = LocalPlayerTab:CreateInput({
        Name = "Speed",
        PlaceholderText = "e.g. 16 or 100",
        CurrentValue = walkSpeedValue,
        Ext = true,
        Callback = function(value)
            walkSpeedValue = value
        end,
    })

    local function syncWalkSpeedInputFromCharacter(showNotify)
        local speed, errMessage = getCurrentCharacterWalkSpeed()
        if not speed then
            if showNotify then
                mountNotify({ Title = "Walk Speed", Content = errMessage, Icon = "x" })
            end
            return false
        end

        local speedText = tostring(speed)
        walkSpeedValue = speedText
        if WalkSpeedInput and WalkSpeedInput.Set then
            WalkSpeedInput:Set(speedText)
        elseif WalkSpeedInput and WalkSpeedInput.SetValue then
            WalkSpeedInput:SetValue(speedText)
        end

        if showNotify then
            mountNotify({ Title = "Walk Speed", Content = "Current speed: " .. speedText, Icon = "check" })
        end
        return true
    end

    LocalPlayerTab:CreateButton({
        Name = "Get Current Walk Speed",
        Ext = true,
        Callback = function()
            syncWalkSpeedInputFromCharacter(true)
        end,
    })

    -- Keep the input defaulted to current character speed when available.
    syncWalkSpeedInputFromCharacter(false)

    LocalPlayerTab:CreateButton({
        Name = "Apply",
        Ext = true,
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                mountNotify({ Title = "Walk Speed", Content = "Character not loaded", Icon = "x" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                mountNotify({ Title = "Walk Speed", Content = "Humanoid not found", Icon = "x" })
                return
            end
            local speed = tonumber(walkSpeedValue) or defaultWalkSpeed
            humanoid.WalkSpeed = math.max(0, speed)
            mountNotify({ Title = "Walk Speed", Content = "Set to " .. tostring(humanoid.WalkSpeed), Icon = "check" })
        end
    })

    LocalPlayerTab:CreateButton({
        Name = "Reset",
        Ext = true,
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                mountNotify({ Title = "Walk Speed", Content = "Character not loaded", Icon = "x" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                mountNotify({ Title = "Walk Speed", Content = "Humanoid not found", Icon = "x" })
                return
            end
            humanoid.WalkSpeed = defaultWalkSpeed
            walkSpeedValue = tostring(defaultWalkSpeed)
            mountNotify({ Title = "Walk Speed", Content = "Reset to " .. tostring(defaultWalkSpeed), Icon = "check" })
        end,
    })

    LocalPlayerTab:CreateSection("Jump Height")

    local defaultJumpHeight = 7.2

    local function getCurrentCharacterJumpHeight()
        local character = Players.LocalPlayer.Character
        if not character then
            return nil, "Character not loaded"
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return nil, "Humanoid not found"
        end
        return humanoid.JumpHeight
    end

    local currentJumpHeight = getCurrentCharacterJumpHeight()
    local jumpHeightValue = tostring(currentJumpHeight or defaultJumpHeight)

    local JumpHeightInput = LocalPlayerTab:CreateInput({
        Name = "Height",
        PlaceholderText = "e.g. 7.2 or 50",
        CurrentValue = jumpHeightValue,
        Ext = true,
        Callback = function(value)
            jumpHeightValue = value
        end,
    })

    local function syncJumpHeightInputFromCharacter(showNotify)
        local jumpHeight, errMessage = getCurrentCharacterJumpHeight()
        if not jumpHeight then
            if showNotify then
                mountNotify({ Title = "Jump Height", Content = errMessage, Icon = "x" })
            end
            return false
        end

        local jumpHeightText = tostring(jumpHeight)
        jumpHeightValue = jumpHeightText
        if JumpHeightInput and JumpHeightInput.Set then
            JumpHeightInput:Set(jumpHeightText)
        elseif JumpHeightInput and JumpHeightInput.SetValue then
            JumpHeightInput:SetValue(jumpHeightText)
        end

        if showNotify then
            mountNotify({ Title = "Jump Height", Content = "Current jump height: " .. jumpHeightText, Icon = "check" })
        end
        return true
    end

    LocalPlayerTab:CreateButton({
        Name = "Get Current Jump Height",
        Ext = true,
        Callback = function()
            syncJumpHeightInputFromCharacter(true)
        end,
    })

    -- Keep the input defaulted to current character jump height when available.
    syncJumpHeightInputFromCharacter(false)

    LocalPlayerTab:CreateButton({
        Name = "Apply",
        Ext = true,
        Callback = function()
            local character = Players.LocalPlayer.Character
            if not character then
                mountNotify({ Title = "Jump Height", Content = "Character not loaded", Icon = "x" })
                return
            end
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not humanoid then
                mountNotify({ Title = "Jump Height", Content = "Humanoid not found", Icon = "x" })
                return
            end
            local jumpHeight = tonumber(jumpHeightValue) or defaultJumpHeight
            humanoid.JumpHeight = math.max(0, jumpHeight)
            mountNotify({ Title = "Jump Height", Content = "Set to " .. tostring(humanoid.JumpHeight), Icon = "check" })
        end,
    })

    LocalPlayerTab:CreateSection("ESP")

    local espNamesEnabled = false
    local espDistanceEnabled = false
    local espCharacterEnabled = false
    local espLinesEnabled = false
    local espAllObjectsEnabled = false
    local espMaxDistance = 10000
    local espPlayerState: { [Player]: { highlight: Highlight?, nameGui: BillboardGui?, lineBeam: Beam?, lineFrom: Attachment?, lineTo: Attachment? } } = {}
    local espObjectState: { [Instance]: BillboardGui } = {}
    local espPlayerAddedConn: RBXScriptConnection? = nil
    local espPlayerRemovingConn: RBXScriptConnection? = nil
    local espLocalCharacterConn: RBXScriptConnection? = nil
    local espRenderStepConn: RBXScriptConnection? = nil
    local espObjectAddedConn: RBXScriptConnection? = nil
    local espObjectRemovingConn: RBXScriptConnection? = nil

    local function espGetPlayerRoot(player: Player): BasePart?
        local character = player.Character
        if not character then return nil end
        local root = character:FindFirstChild("HumanoidRootPart")
        if root and root:IsA("BasePart") then return root end
        return nil
    end

    local function espGetState(player: Player)
        local state = espPlayerState[player]
        if not state then state = {} espPlayerState[player] = state end
        return state
    end

    local function espClearVisualsForPlayer(player: Player)
        local state = espPlayerState[player]
        if not state then return end
        if state.highlight then state.highlight:Destroy() state.highlight = nil end
        if state.nameGui then state.nameGui:Destroy() state.nameGui = nil end
        if state.lineBeam then state.lineBeam:Destroy() state.lineBeam = nil end
        if state.lineFrom then state.lineFrom:Destroy() state.lineFrom = nil end
        if state.lineTo then state.lineTo:Destroy() state.lineTo = nil end
    end

    local function espApplyForPlayer(player: Player)
        if player == Players.LocalPlayer then return end
        local character = player.Character
        local root = espGetPlayerRoot(player)
        if not character or not root then
            espClearVisualsForPlayer(player)
            return
        end
        local state = espGetState(player)
        local localRoot = espGetPlayerRoot(Players.LocalPlayer)
        local distToLocal: number? = nil
        if localRoot then distToLocal = (localRoot.Position - root.Position).Magnitude end
        local withinMaxDistance = (espMaxDistance <= 0) or (distToLocal ~= nil and distToLocal <= espMaxDistance)

        if espCharacterEnabled and withinMaxDistance then
            if not state.highlight then
                local h = Instance.new("Highlight")
                h.Name = "SempatPanickESPHighlight"
                h.FillColor = Color3.fromRGB(16, 197, 80)
                h.FillTransparency = 0.7
                h.OutlineColor = Color3.fromRGB(255, 255, 255)
                h.OutlineTransparency = 0
                h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                h.Parent = character
                state.highlight = h
            end
            state.highlight.Adornee = character
            state.highlight.Enabled = true
        elseif state.highlight then
            state.highlight:Destroy()
            state.highlight = nil
        end

        if (espNamesEnabled or espDistanceEnabled) and withinMaxDistance then
            if not state.nameGui then
                local nameGui = Instance.new("BillboardGui")
                nameGui.Name = "SempatPanickESPName"
                nameGui.Size = UDim2.fromOffset(220, 44)
                nameGui.StudsOffset = Vector3.new(0, 3.5, 0)
                nameGui.AlwaysOnTop = true
                nameGui.MaxDistance = espMaxDistance
                local label = Instance.new("TextLabel")
                label.Name = "Label"
                label.BackgroundTransparency = 1
                label.Size = UDim2.fromScale(1, 1)
                label.Font = Enum.Font.GothamBold
                label.TextColor3 = Color3.fromRGB(255, 255, 255)
                label.TextStrokeTransparency = 0
                label.TextScaled = true
                label.TextWrapped = true
                label.Parent = nameGui
                state.nameGui = nameGui
            end
            state.nameGui.MaxDistance = espMaxDistance
            local label = state.nameGui:FindFirstChild("Label")
            if label and label:IsA("TextLabel") then
                local baseName = player.DisplayName and player.DisplayName ~= "" and player.DisplayName or player.Name
                if espDistanceEnabled and distToLocal then
                    label.Text = string.format("%s\n[%.0fm]", baseName, distToLocal)
                else
                    label.Text = baseName
                end
            end
            state.nameGui.Adornee = root
            state.nameGui.Parent = root
            state.nameGui.Enabled = true
        elseif state.nameGui then
            state.nameGui:Destroy()
            state.nameGui = nil
        end

        if espLinesEnabled then
            if localRoot then
                if not state.lineFrom then
                    local a0 = Instance.new("Attachment")
                    a0.Name = "SempatPanickESPFrom"
                    a0.Parent = localRoot
                    state.lineFrom = a0
                elseif state.lineFrom.Parent ~= localRoot then
                    state.lineFrom.Parent = localRoot
                end
                if not state.lineTo then
                    local a1 = Instance.new("Attachment")
                    a1.Name = "SempatPanickESPTo"
                    a1.Parent = root
                    state.lineTo = a1
                elseif state.lineTo.Parent ~= root then
                    state.lineTo.Parent = root
                end
                if not state.lineBeam then
                    local beam = Instance.new("Beam")
                    beam.Name = "SempatPanickESPLine"
                    beam.FaceCamera = true
                    beam.Width0 = 0.06
                    beam.Width1 = 0.06
                    beam.Color = ColorSequence.new(Color3.fromRGB(16, 197, 80))
                    beam.Transparency = NumberSequence.new(0.2)
                    beam.LightEmission = 1
                    beam.Parent = Workspace.Terrain
                    state.lineBeam = beam
                end
                if withinMaxDistance then
                    state.lineBeam.Attachment0 = state.lineFrom
                    state.lineBeam.Attachment1 = state.lineTo
                    state.lineBeam.Enabled = true
                else
                    state.lineBeam.Enabled = false
                end
            elseif state.lineBeam then
                state.lineBeam.Enabled = false
            end
        else
            if state.lineBeam then state.lineBeam:Destroy() state.lineBeam = nil end
            if state.lineFrom then state.lineFrom:Destroy() state.lineFrom = nil end
            if state.lineTo then state.lineTo:Destroy() state.lineTo = nil end
        end
    end

    local function espApplyForAllPlayers()
        for _, p in ipairs(Players:GetPlayers()) do espApplyForPlayer(p) end
    end

    local function espObjectDebugId(inst: Instance): string
        local ok, id = pcall(function()
            return inst:GetDebugId(0)
        end)
        if ok and type(id) == "string" and id ~= "" then
            return id
        end
        return tostring(inst)
    end

    local function espObjectIsPlayerCharacterDescendant(inst: Instance): boolean
        local current = inst
        while current and current ~= Workspace do
            if current:IsA("Model") then
                local plr = Players:GetPlayerFromCharacter(current)
                if plr then
                    return true
                end
            end
            current = current.Parent
        end
        return false
    end

    local function espObjectGetAdornee(inst: Instance): BasePart?
        if inst:IsA("BasePart") then
            return inst
        end
        if inst:IsA("Model") then
            local root = inst.PrimaryPart
            if root then
                return root
            end
            return inst:FindFirstChildWhichIsA("BasePart", true)
        end
        return nil
    end

    local function espClearVisualForObject(inst: Instance)
        local gui = espObjectState[inst]
        if gui then
            gui:Destroy()
            espObjectState[inst] = nil
        end
    end

    local function espApplyForObject(inst: Instance)
        if not espAllObjectsEnabled then
            espClearVisualForObject(inst)
            return
        end
        if not inst.Parent then
            espClearVisualForObject(inst)
            return
        end
        if not (inst:IsA("BasePart") or inst:IsA("Model")) then
            espClearVisualForObject(inst)
            return
        end
        if espObjectIsPlayerCharacterDescendant(inst) then
            espClearVisualForObject(inst)
            return
        end

        local adornee = espObjectGetAdornee(inst)
        if not adornee then
            espClearVisualForObject(inst)
            return
        end

        local gui = espObjectState[inst]
        if not gui then
            gui = Instance.new("BillboardGui")
            gui.Name = "SempatPanickESPObject"
            gui.Size = UDim2.fromOffset(320, 58)
            gui.StudsOffset = Vector3.new(0, 3, 0)
            gui.AlwaysOnTop = true
            local label = Instance.new("TextLabel")
            label.Name = "Label"
            label.BackgroundTransparency = 1
            label.Size = UDim2.fromScale(1, 1)
            label.Font = Enum.Font.GothamBold
            label.TextColor3 = Color3.fromRGB(255, 230, 120)
            label.TextStrokeTransparency = 0
            label.TextScaled = true
            label.TextWrapped = true
            label.Parent = gui
            espObjectState[inst] = gui
        end

        gui.Adornee = adornee
        gui.MaxDistance = espMaxDistance
        gui.Parent = adornee
        gui.Enabled = true

        local label = gui:FindFirstChild("Label")
        if label and label:IsA("TextLabel") then
            label.Text = string.format("%s\n%s", espObjectDebugId(inst), inst.Name)
        end
    end

    local function espApplyForAllObjects()
        for _, inst in ipairs(Workspace:GetDescendants()) do
            if inst:IsA("BasePart") or inst:IsA("Model") then
                espApplyForObject(inst)
            end
        end
    end

    local function espClearAllObjects()
        for inst, gui in pairs(espObjectState) do
            if gui then
                gui:Destroy()
            end
            espObjectState[inst] = nil
        end
    end

    local function espAnyEnabled(): boolean
        return espNamesEnabled or espDistanceEnabled or espCharacterEnabled or espLinesEnabled or espAllObjectsEnabled
    end

    LocalPlayerTab:CreateInput({
        Name = "ESP Max Distance",
        PlaceholderText = "0 = unlimited, e.g. 10000",
        CurrentValue = tostring(espMaxDistance),
        Ext = true,
        Callback = function(value)
            local n = tonumber(value)
            if not n then return end
            espMaxDistance = math.max(0, n)
            if espAnyEnabled() then espApplyForAllPlayers() end
        end,
    })

    local function espOnRenderStep()
        if not espAnyEnabled() then return end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= Players.LocalPlayer then espApplyForPlayer(p) end
        end
    end

    local function espSetRuntimeEnabled(enabled: boolean)
        if enabled then
            if not espPlayerAddedConn then
                espPlayerAddedConn = Players.PlayerAdded:Connect(function(player)
                    player.CharacterAdded:Connect(function() task.wait(0.15) espApplyForPlayer(player) end)
                    espApplyForPlayer(player)
                end)
            end
            if not espPlayerRemovingConn then
                espPlayerRemovingConn = Players.PlayerRemoving:Connect(function(player)
                    espClearVisualsForPlayer(player)
                    espPlayerState[player] = nil
                end)
            end
            if not espLocalCharacterConn then
                espLocalCharacterConn = Players.LocalPlayer.CharacterAdded:Connect(function()
                    task.wait(0.2)
                    espApplyForAllPlayers()
                end)
            end
            if not espRenderStepConn then
                espRenderStepConn = RunService.RenderStepped:Connect(espOnRenderStep)
            end
            if espAllObjectsEnabled and not espObjectAddedConn then
                espObjectAddedConn = Workspace.DescendantAdded:Connect(function(inst)
                    if inst:IsA("BasePart") or inst:IsA("Model") then
                        task.defer(function()
                            espApplyForObject(inst)
                        end)
                    end
                end)
            end
            if espAllObjectsEnabled and not espObjectRemovingConn then
                espObjectRemovingConn = Workspace.DescendantRemoving:Connect(function(inst)
                    espClearVisualForObject(inst)
                end)
            end
            espApplyForAllPlayers()
            if espAllObjectsEnabled then
                espApplyForAllObjects()
            else
                espClearAllObjects()
            end
            return
        end
        if espPlayerAddedConn then espPlayerAddedConn:Disconnect() espPlayerAddedConn = nil end
        if espPlayerRemovingConn then espPlayerRemovingConn:Disconnect() espPlayerRemovingConn = nil end
        if espLocalCharacterConn then espLocalCharacterConn:Disconnect() espLocalCharacterConn = nil end
        if espRenderStepConn then espRenderStepConn:Disconnect() espRenderStepConn = nil end
        if espObjectAddedConn then espObjectAddedConn:Disconnect() espObjectAddedConn = nil end
        if espObjectRemovingConn then espObjectRemovingConn:Disconnect() espObjectRemovingConn = nil end
        for player in pairs(espPlayerState) do espClearVisualsForPlayer(player) espPlayerState[player] = nil end
        espClearAllObjects()
    end

    LocalPlayerTab:CreateToggle({
        Name = "ESP Player Names",
        CurrentValue = false,
        Callback = function(enabled)
            espNamesEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })
    LocalPlayerTab:CreateToggle({
        Name = "ESP Player Distance",
        CurrentValue = false,
        Callback = function(enabled)
            espDistanceEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })
    LocalPlayerTab:CreateToggle({
        Name = "ESP Player Character",
        CurrentValue = false,
        Callback = function(enabled)
            espCharacterEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })
    LocalPlayerTab:CreateToggle({
        Name = "ESP Player Lines",
        CurrentValue = false,
        Callback = function(enabled)
            espLinesEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAnyEnabled() then espApplyForAllPlayers() end
        end
    })
    LocalPlayerTab:CreateToggle({
        Name = "ESP All Object",
        CurrentValue = false,
        Callback = function(enabled)
            espAllObjectsEnabled = enabled
            espSetRuntimeEnabled(espAnyEnabled())
            if espAllObjectsEnabled then
                espApplyForAllObjects()
            else
                espClearAllObjects()
            end
        end
    })

    local infoPlayerList = {}
    local infoPlayerDisplayNames = {}
    local selectedInfoPlayer = nil
    local PlayersInfoDropdown
    local PlayersInfoParagraph

    local function playerInfoLabel(player)
        if not player then return "" end
        local dn = player.DisplayName
        if dn and dn ~= "" and dn ~= player.Name then
            return string.format("%s (@%s)", dn, player.Name)
        end
        return player.Name
    end

    local function formatHumanoidChildLine(child)
        if child:IsA("ValueBase") then
            local ok, val = pcall(function()
                return child.Value
            end)
            if not ok then
                return "  " .. child.Name .. " (" .. child.ClassName .. ") = ?"
            end
            return "  " .. child.Name .. " (" .. child.ClassName .. ") = " .. formatValueForDisplay(val)
        end
        return "  " .. child.Name .. " = " .. child.ClassName
    end

    -- Fallback fields if runtime property discovery is unavailable.
    local HUMANOID_INSPECT_PROPERTIES_FALLBACK = {
        "AutoJumpEnabled",
        "AutoRotate",
        "BreakJointsOnDeath",
        "CameraOffset",
        "DisplayDistanceType",
        "EvaluateStateMachine",
        "FloorMaterial",
        "Health",
        "HealthDisplayType",
        "HipHeight",
        "Jump",
        "JumpHeight",
        "JumpPower",
        "MaxHealth",
        "MaxSlopeAngle",
        "MeshHeadScale",
        "MoveDirection",
        "NameDisplayDistance",
        "RequiresNeck",
        "RigType",
        "RootPart",
        "SeatPart",
        "Sit",
        "TargetPoint",
        "UseJumpPower",
        "WalkSpeed",
        "WalkToPart",
        "WalkToPoint",
    }

    local PLAYER_INSPECT_PROPERTIES_FALLBACK = {
        "AccountAge",
        "AutoJumpEnabled",
        "CanLoadCharacterAppearance",
        "CharacterAppearanceId",
        "DataComplexity",
        "DataReady",
        "DevComputerCameraMode",
        "DevComputerMovementMode",
        "DevEnableMouseLock",
        "DevTouchCameraMode",
        "DevTouchMovementMode",
        "DisplayName",
        "FollowUserId",
        "GameplayPaused",
        "HasVerifiedBadge",
        "HealthDisplayDistance",
        "LocaleId",
        "MembershipType",
        "Name",
        "Neutral",
        "RespawnLocation",
        "SimulationRadius",
        "Team",
        "TeamColor",
        "UserId",
    }

    local function getReadablePropertyNames(instance: Instance, fallbackList: { string }): { string }
        local names = {}
        local seen = {}
        local function addName(name: string)
            if name == "" or seen[name] then
                return
            end
            seen[name] = true
            table.insert(names, name)
        end

        local getPropertiesFn = rawget(_G, "getproperties")
        if type(getPropertiesFn) == "function" then
            local ok = pcall(function()
                local discovered = getPropertiesFn(instance)
                if type(discovered) == "table" then
                    for _, name in ipairs(discovered) do
                        if type(name) == "string" then
                            addName(name)
                        end
                    end
                end
            end)
            if not ok then
                -- Ignore and fall back to static property lists below.
            end
        end

        if #names == 0 then
            for _, name in ipairs(fallbackList) do
                addName(name)
            end
        end

        table.sort(names, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return names
    end

    local function buildPlayersInfoText(player)
        if not player then
            return "Select a player from the list."
        end
        local lines = {}
        table.insert(lines, "Username: " .. player.Name)
        local dn = player.DisplayName
        table.insert(lines, "Display name: " .. ((dn and dn ~= "") and dn or "(same as username)"))
        table.insert(lines, "")
        table.insert(lines, "LocalPlayer attributes:")
        local localPlayer = Players.LocalPlayer
        if localPlayer then
            local attrs = localPlayer:GetAttributes()
            local attrRows = {}
            for key, val in pairs(attrs) do
                table.insert(attrRows, {
                    key = tostring(key),
                    text = "  " .. tostring(key) .. " = " .. formatValueForDisplay(val),
                })
            end
            table.sort(attrRows, function(a, b)
                return string.lower(a.key) < string.lower(b.key)
            end)
            if #attrRows == 0 then
                table.insert(lines, "  (none)")
            else
                for _, row in ipairs(attrRows) do
                    table.insert(lines, row.text)
                end
            end
        else
            table.insert(lines, "  (LocalPlayer not found)")
        end
        table.insert(lines, "")
        table.insert(lines, "LocalPlayer properties:")
        if localPlayer then
            local propRows = {}
            for _, propName in ipairs(getReadablePropertyNames(localPlayer, PLAYER_INSPECT_PROPERTIES_FALLBACK)) do
                local ok, val = pcall(function()
                    return localPlayer[propName]
                end)
                if ok then
                    table.insert(propRows, {
                        key = propName,
                        text = "  " .. propName .. " = " .. formatValueForDisplay(val),
                    })
                end
            end
            table.sort(propRows, function(a, b)
                return string.lower(a.key) < string.lower(b.key)
            end)
            if #propRows == 0 then
                table.insert(lines, "  (none readable)")
            else
                for _, row in ipairs(propRows) do
                    table.insert(lines, row.text)
                end
            end
        else
            table.insert(lines, "  (LocalPlayer not found)")
        end
        local character = player.Character
        if not character then
            table.insert(lines, "Character: not loaded")
            table.insert(lines, "Location: â€”")
            table.insert(lines, "")
            table.insert(lines, "Humanoid properties: â€”")
            table.insert(lines, "Inside Humanoid (children): â€”")
            return table.concat(lines, "\n")
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local root = character:FindFirstChild("HumanoidRootPart") or character.PrimaryPart
        if root then
            local p = root.Position
            table.insert(lines, string.format("Location: %.2f, %.2f, %.2f", p.X, p.Y, p.Z))
            local okVel, velMag = pcall(function()
                return root.AssemblyLinearVelocity.Magnitude
            end)
            if okVel and velMag then
                table.insert(lines, string.format("Velocity (mag): %.2f", velMag))
            end
        else
            table.insert(lines, "Location: (no HumanoidRootPart / PrimaryPart)")
        end
        table.insert(lines, "")
        table.insert(lines, "Humanoid attributes:")
        if humanoid then
            local humAttrs = humanoid:GetAttributes()
            local humAttrRows = {}
            for key, val in pairs(humAttrs) do
                table.insert(humAttrRows, {
                    key = tostring(key),
                    text = "  " .. tostring(key) .. " = " .. formatValueForDisplay(val),
                })
            end
            table.sort(humAttrRows, function(a, b)
                return string.lower(a.key) < string.lower(b.key)
            end)
            if #humAttrRows == 0 then
                table.insert(lines, "  (none)")
            else
                for _, row in ipairs(humAttrRows) do
                    table.insert(lines, row.text)
                end
            end
        else
            table.insert(lines, "  (no Humanoid)")
        end
        table.insert(lines, "")
        if humanoid then
            table.insert(lines, "Humanoid properties:")
            local propRows = {}
            for _, propName in ipairs(getReadablePropertyNames(humanoid, HUMANOID_INSPECT_PROPERTIES_FALLBACK)) do
                local ok, val = pcall(function()
                    return humanoid[propName]
                end)
                if ok then
                    table.insert(propRows, {
                        key = propName,
                        text = "  "
                            .. propName
                            .. " = "
                            .. formatValueForDisplay(val),
                    })
                end
            end
            table.sort(propRows, function(a, b)
                return string.lower(a.key) < string.lower(b.key)
            end)
            for _, row in ipairs(propRows) do
                table.insert(lines, row.text)
            end
        else
            table.insert(lines, "Humanoid properties: (no Humanoid)")
        end
        table.insert(lines, "")
        table.insert(lines, "Inside Humanoid (children):")
        if humanoid then
            local children = humanoid:GetChildren()
            table.sort(children, function(a, b)
                return string.lower(a.Name) < string.lower(b.Name)
            end)
            if #children == 0 then
                table.insert(lines, "  (none)")
            else
                for _, child in ipairs(children) do
                    table.insert(lines, formatHumanoidChildLine(child))
                end
            end
        else
            table.insert(lines, "  (no Humanoid)")
        end
        return table.concat(lines, "\n")
    end

    local PLAYERS_INFO_PAR_TITLE = "Details"
    local INFO_PLAYER_NONE = "(None)"

    local function playersInfoDropdownOptions()
        local opts = { INFO_PLAYER_NONE }
        for _, n in ipairs(infoPlayerDisplayNames) do
            table.insert(opts, n)
        end
        return opts
    end

    local function updatePlayersInfoParagraph()
        if PlayersInfoParagraph and PlayersInfoParagraph.Set then
            PlayersInfoParagraph:Set({
                Title = PLAYERS_INFO_PAR_TITLE,
                Content = buildPlayersInfoText(selectedInfoPlayer),
            })
        end
    end

    local function refreshPlayersInfoList(showNotify)
        infoPlayerList = {}
        infoPlayerDisplayNames = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.ClassName == "Player" then
                table.insert(infoPlayerList, plr)
                table.insert(infoPlayerDisplayNames, playerInfoLabel(plr))
            end
        end
        if PlayersInfoDropdown and PlayersInfoDropdown.Refresh then
            PlayersInfoDropdown:Refresh(playersInfoDropdownOptions())
        end
        if selectedInfoPlayer then
            if not table.find(infoPlayerList, selectedInfoPlayer) then
                selectedInfoPlayer = nil
                if PlayersInfoDropdown and PlayersInfoDropdown.Set then
                    PlayersInfoDropdown:Set(INFO_PLAYER_NONE)
                end
            end
        end
        updatePlayersInfoParagraph()
        if showNotify then
            mountNotify({ Title = "Players Info", Content = "Player list refreshed (" .. #infoPlayerList .. ")", Icon = "check" })
        end
    end

    LocalPlayerTab:CreateSection("Players Info")

    PlayersInfoDropdown = LocalPlayerTab:CreateDropdown({
        Name = "Player",
        Search = true,
        Options = playersInfoDropdownOptions(),
        CurrentOption = { INFO_PLAYER_NONE },
        Ext = true,
        Callback = function(opts)
            local value = type(opts) == "table" and opts[1] or opts
            selectedInfoPlayer = nil
            if value and value ~= INFO_PLAYER_NONE then
                local idx = table.find(infoPlayerDisplayNames, value)
                if idx and infoPlayerList[idx] then
                    selectedInfoPlayer = infoPlayerList[idx]
                end
            end
            updatePlayersInfoParagraph()
        end,
    })

    PlayersInfoParagraph = LocalPlayerTab:CreateParagraph({
        Title = PLAYERS_INFO_PAR_TITLE,
        Content = "Select a player from the list.",
    })

    LocalPlayerTab:CreateButton({
        Name = "Refresh list",
        Ext = true,
        Callback = function()
            refreshPlayersInfoList(true)
        end,
    })

    LocalPlayerTab:CreateButton({
        Name = "Refresh details",
        Ext = true,
        Callback = function()
            if not selectedInfoPlayer then
                mountNotify({ Title = "Players Info", Content = "Select a player first", Icon = "x" })
                return
            end
            updatePlayersInfoParagraph()
            mountNotify({ Title = "Players Info", Content = "Details updated", Icon = "check" })
        end,
    })

    refreshPlayersInfoList(false)

    Players.PlayerAdded:Connect(function()
        refreshPlayersInfoList(false)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(function()
            refreshPlayersInfoList(false)
        end)
    end)

    LocalPlayerTab:CreateSection("Carry")
    local CARRY_NONE = "(None)"
    local carryPlayerNames = {}
    local selectedCarryPlayerName = nil
    local CarryPlayerDropdown
    local carryEnabled = false
    local carryLoopToken = 0
    local CARRY_NEARBY_DISTANCE = 20

    local function carryDropdownOptions()
        local opts = { CARRY_NONE }
        for _, n in ipairs(carryPlayerNames) do
            table.insert(opts, n)
        end
        return opts
    end

    local function refreshCarryPlayers()
        carryPlayerNames = {}
        local localPlayer = Players.LocalPlayer
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= localPlayer and player.ClassName == "Player" then
                table.insert(carryPlayerNames, player.Name)
            end
        end
        table.sort(carryPlayerNames, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        if CarryPlayerDropdown and CarryPlayerDropdown.Refresh then
            CarryPlayerDropdown:Refresh(carryDropdownOptions())
        end
        if selectedCarryPlayerName and not table.find(carryPlayerNames, selectedCarryPlayerName) then
            selectedCarryPlayerName = nil
            if CarryPlayerDropdown and CarryPlayerDropdown.Set then
                CarryPlayerDropdown:Set({ CARRY_NONE })
            end
        end
    end

    CarryPlayerDropdown = LocalPlayerTab:CreateDropdown({
        Name = "Player",
        Options = carryDropdownOptions(),
        CurrentOption = { CARRY_NONE },
        Search = true,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            if picked and picked ~= CARRY_NONE then
                selectedCarryPlayerName = picked
            else
                selectedCarryPlayerName = nil
            end
        end,
    })

    LocalPlayerTab:CreateToggle({
        Name = "Carry nearby selected player",
        CurrentValue = false,
        Callback = function(enabled)
            carryEnabled = enabled == true
            carryLoopToken = carryLoopToken + 1
            local myToken = carryLoopToken

            if not carryEnabled then
                mountNotify({
                    Title = "Carry",
                    Content = "Carry disabled",
                })
                return
            end

            mountNotify({
                Title = "Carry",
                Content = "Carry enabled",
            })

            task.spawn(function()
                while carryEnabled and myToken == carryLoopToken do
                    if selectedCarryPlayerName and selectedCarryPlayerName ~= "" then
                        local localCharacter = Players.LocalPlayer.Character
                        local localRoot = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
                        local targetPlayer = Players:FindFirstChild(selectedCarryPlayerName)
                        local targetCharacter = targetPlayer and targetPlayer.Character
                        local targetRoot = targetCharacter and targetCharacter:FindFirstChild("HumanoidRootPart")

                        if localRoot and targetRoot then
                            local dist = (localRoot.Position - targetRoot.Position).Magnitude
                            if dist <= CARRY_NEARBY_DISTANCE then
                                pcall(function()
                                    targetRoot.CFrame = localRoot.CFrame * CFrame.new(1.8, 0, 0)
                                end)
                            end
                        end
                    end
                    task.wait(0.12)
                end
            end)
        end,
    })

    refreshCarryPlayers()
    Players.PlayerAdded:Connect(refreshCarryPlayers)
    Players.PlayerRemoving:Connect(function()
        task.defer(refreshCarryPlayers)
    end)

    LocalPlayerTab:CreateSection("Server")

    LocalPlayerTab:CreateButton({
        Name = "Rejoin server",
        Ext = true,
        Callback = function()
            local TeleportService = game:GetService("TeleportService")
            local placeId = game.PlaceId
            local jobId = game.JobId
            if placeId and jobId and #jobId > 0 then
                local ok, err = pcall(function()
                    TeleportService:TeleportToPlaceInstance(placeId, jobId)
                end)
                if not ok then
                    mountNotify({
                        Title = "Rejoin",
                        Content = "Failed: " .. tostring(err),
                        Icon = "close",
                    })
                end
            else
                mountNotify({
                    Title = "Rejoin",
                    Content = "Cannot rejoin (missing PlaceId or JobId)",
                    Icon = "close",
                })
            end
        end,
    })

    LocalPlayerTab:CreateButton({
        Name = "Copy game ID",
        Ext = true,
        Callback = function()
            local paste = setclipboard or toclipboard
            if not paste then
                mountNotify({
                    Title = "Server",
                    Content = "Clipboard not supported in this environment",
                    Icon = "x",
                })
                return
            end
            local id = tostring(game.PlaceId)
            paste(id)
            mountNotify({
                Title = "Server",
                Content = "Copied PlaceId " .. id,
                Icon = "check",
            })
        end,
    })

    local animationOptions = { "Hair Grab (R6)" }
    local selectedAnimationName = animationOptions[1]
    local animationRunning = false
    local function findHairAccessory(character)
        local accessories = {}
        for _, child in ipairs(character:GetChildren()) do
            if child:IsA("Accessory") then table.insert(accessories, child) end
        end
        for _, accessory in ipairs(accessories) do
            local okType, accType = pcall(function() return accessory.AccessoryType end)
            if okType and accType == Enum.AccessoryType.Hair then
                local handle = accessory:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then return accessory, handle end
            end
        end
        for _, accessory in ipairs(accessories) do
            if string.find(string.lower(accessory.Name), "hair", 1, true) then
                local handle = accessory:FindFirstChild("Handle")
                if handle and handle:IsA("BasePart") then return accessory, handle end
            end
        end
        return nil, nil
    end
    local function playHairGrabAnimationR6()
        if animationRunning then return end
        animationRunning = true
        local character = Players.LocalPlayer.Character
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        local torso = character and character:FindFirstChild("Torso")
        local rightArm = character and character:FindFirstChild("Right Arm")
        local head = character and character:FindFirstChild("Head")
        if not character or not humanoid or humanoid.RigType ~= Enum.HumanoidRigType.R6 or not torso or not rightArm or not head then
            animationRunning = false
            mountNotify({ Title = "Animation", Content = "R6 character parts not ready", Icon = "x" })
            return
        end
        local rightShoulder = torso:FindFirstChild("Right Shoulder")
        local neck = torso:FindFirstChild("Neck")
        if not (rightShoulder and rightShoulder:IsA("Motor6D") and neck and neck:IsA("Motor6D")) then
            animationRunning = false
            mountNotify({ Title = "Animation", Content = "R6 joints not found", Icon = "x" })
            return
        end
        local _, hairHandle = findHairAccessory(character)
        if not hairHandle then
            animationRunning = false
            mountNotify({ Title = "Animation", Content = "No hair accessory found", Icon = "x" })
            return
        end
        local originalShoulderC0, originalNeckC0 = rightShoulder.C0, neck.C0
        local originalHairCFrame = hairHandle.CFrame
        local originalWeld = hairHandle:FindFirstChild("AccessoryWeld")
        if not (originalWeld and originalWeld:IsA("JointInstance")) then originalWeld = hairHandle:FindFirstChildOfClass("JointInstance") end
        local grabWeld
        local function restoreAll()
            pcall(function()
                if grabWeld then grabWeld:Destroy() end
                hairHandle.CFrame = originalHairCFrame
                if originalWeld and originalWeld.Parent then originalWeld.Enabled = true end
                rightShoulder.C0 = originalShoulderC0
                neck.C0 = originalNeckC0
            end)
            animationRunning = false
        end
        local moveInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        local backInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        TweenService:Create(rightShoulder, moveInfo, { C0 = originalShoulderC0 * CFrame.Angles(math.rad(-95), math.rad(8), math.rad(28)) }):Play()
        TweenService:Create(neck, moveInfo, { C0 = originalNeckC0 * CFrame.Angles(math.rad(8), math.rad(-16), 0) }):Play()
        pcall(function()
            if originalWeld and originalWeld.Parent then originalWeld.Enabled = false end
            hairHandle.CanCollide = false
            hairHandle.Massless = true
            grabWeld = Instance.new("Weld")
            grabWeld.Name = "HairGrabWeld"
            grabWeld.Part0 = rightArm
            grabWeld.Part1 = hairHandle
            grabWeld.C0 = CFrame.new(0, -1.05, -0.1) * CFrame.Angles(math.rad(80), 0, math.rad(6))
            grabWeld.Parent = rightArm
        end)
        task.spawn(function()
            task.wait(0.95)
            if not character.Parent then restoreAll() return end
            TweenService:Create(rightShoulder, backInfo, { C0 = originalShoulderC0 }):Play()
            TweenService:Create(neck, backInfo, { C0 = originalNeckC0 }):Play()
            task.wait(0.24)
            restoreAll()
        end)
    end
    LocalPlayerTab:CreateSection("Animation")

    LocalPlayerTab:CreateDropdown({
        Name = "Animation list",
        Options = animationOptions,
        CurrentOption = { selectedAnimationName },
        Ext = true,
        Callback = function(opts)
            local value = type(opts) == "table" and opts[1] or opts
            if value then
                selectedAnimationName = value
            end
        end,
    })
    LocalPlayerTab:CreateButton({
        Name = "Animate",
        Ext = true,
        Callback = function()
            if selectedAnimationName == "Hair Grab (R6)" then
                playHairGrabAnimationR6()
                return
            end
            mountNotify({ Title = "Animation", Content = "Unknown animation selected", Icon = "x" })
        end,
    })

    LocalPlayerTab:CreateButton({
        Name = "Clear Console",
        Ext = true,
        Callback = function()
            local cleared = false
            local clearFn = rawget(_G, "clearconsole") or rawget(_G, "rconsoleclear")
            if type(clearFn) == "function" then
                clearFn()
                cleared = true
            end
            mountNotify({
                Title = "Console",
                Content = cleared and "Console cleared" or "Clear not available (try clearconsole)",
                Icon = cleared and "check" or "x",
            })
        end
    })
end

-- */  Main Tab  /* --
do
    local MainTab = Window:CreateTab("Main", 4483362458)

    local autoSummitEnabled = false
    local autoSummitMainToggle: any = nil
    local autoSummitSkipFinalStoppedNotify = false
    local summitQty = ""
    local autoSummitRandomizeTeleportDuration = false
    local autoSummitIncludeFailedRoute = false
    local autoSummitRestartFromDeath = false
    local autoSummitWalkKeysDown: { [Enum.KeyCode]: boolean } = {}
    local autoSummitWalkPlaybackHumanoid: Humanoid? = nil
    local autoSummitWalkPlaybackAutoRotateRestore: boolean? = nil
    local autoSummitMode = "Walk"
    local AUTO_SUMMIT_MODE_OPTIONS = { "Teleport", "Walk" }
    local updateAutoSummitRouteModeParagraph: () -> ()
    local BETWEEN_RUN_DELAY = 10

    local MOUNT_ROUTES_DIR = "sempatpanick/mount_yahayuk/routes"
    local MOUNT_ROUTES_INDEX_JSON = MOUNT_ROUTES_DIR .. "/index.json"
    local MOUNT_ROUTES_REMOTE = baseURL .. "/mount_yahayuk/routes/"
    local MOUNT_FALLSPAWNS_JSON = "sempatpanick/mount_yahayuk/fallspawns.json"
    local MOUNT_FALLSPAWNS_REMOTE = baseURL .. "/mount_yahayuk/fallspawns.json"

    local DEFAULT_MOUNT_ROUTE_INDEX_FILES = {
        "index.json",
        "start-cp1_success_1.json",
        "cp1-2_success_1.json",
        "cp1-2_success_2.json",
        "cp2-3_success_1.json",
        "cp3-4_success_1.json",
        "cp4-5_success_1.json",
        "cp5-summit_success_1.json",
    }

    -- Next leg toward summit: route JSON basename prefix (matches files like cp1-2_success_1.json).
    local WALK_LEG_PREFIX_BY_CP: { [number]: string } = {
        [0] = "start-cp1",
        [1] = "cp1-2",
        [2] = "cp2-3",
        [3] = "cp3-4",
        [4] = "cp4-5",
        [5] = "cp5-summit",
        [6] = "summit-start",
    }

    local function resolveExecutorFnForMain(name: string): any
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

    local function normalizePathMain(path: string): string
        return string.gsub(path or "", "\\", "/")
    end

    local function baseNameFromPathMain(path: string): string
        local normalized = normalizePathMain(path)
        local base = string.match(normalized, "([^/]+)$")
        return base or normalized
    end

    local function isJsonPathMain(path: string): boolean
        return string.sub(string.lower(path), -5) == ".json"
    end

    local mountRouteProbabilitiesByPrefixCache: { [string]: { [string]: number } }? = nil
    local mountRouteProbabilitiesLoadAttempted = false
    local mountFallSpawnRowsCache: { any }? = nil
    local mountFallSpawnRowsLoadAttempted = false

    local function syncMountYahayukRoutesFromRemote()
        local writeFn = resolveExecutorFnForMain("writefile")
        local makeFolderFn = resolveExecutorFnForMain("makefolder")
        local delFn = resolveExecutorFnForMain("delfile")
        local isFileFn = resolveExecutorFnForMain("isfile")
        if type(writeFn) ~= "function" then
            return false, "writefile() not available"
        end
        if type(makeFolderFn) == "function" then
            pcall(function()
                makeFolderFn("sempatpanick")
                makeFolderFn("sempatpanick/mount_yahayuk")
                makeFolderFn(MOUNT_ROUTES_DIR)
            end)
        end
        local indexUrl = MOUNT_ROUTES_REMOTE .. "index.json"
        local okIndex, indexBody = pcall(function()
            return game:HttpGet(indexUrl, true)
        end)
        local fileNames: { string } = {}
        if okIndex and type(indexBody) == "string" and #indexBody > 2 then
            local okDecode, decoded = pcall(function()
                return HttpService:JSONDecode(indexBody)
            end)
            if okDecode and type(decoded) == "table" and type(decoded.files) == "table" then
                fileNames = decoded.files
            end
        end
        if #fileNames == 0 then
            fileNames = DEFAULT_MOUNT_ROUTE_INDEX_FILES
        end
        local hasIndexJson = false
        for _, fname in ipairs(fileNames) do
            if type(fname) == "string" and string.lower(fname) == "index.json" then
                hasIndexJson = true
                break
            end
        end
        if not hasIndexJson then
            table.insert(fileNames, 1, "index.json")
        end
        for _, fname in ipairs(fileNames) do
            if type(fname) == "string" and isJsonPathMain(fname) then
                local fullPath = MOUNT_ROUTES_DIR .. "/" .. fname
                if type(delFn) == "function" then
                    local shouldTryDelete = true
                    if type(isFileFn) == "function" then
                        local okExist, exists = pcall(function()
                            return isFileFn(fullPath)
                        end)
                        shouldTryDelete = okExist and exists == true
                    end
                    if shouldTryDelete then
                        pcall(function()
                            delFn(fullPath)
                        end)
                    end
                end
                local url = MOUNT_ROUTES_REMOTE .. fname
                local okGet, content = pcall(function()
                    return game:HttpGet(url, true)
                end)
                if okGet and type(content) == "string" and #content > 2 then
                    pcall(function()
                        writeFn(fullPath, content)
                    end)
                end
            end
        end
        -- fallspawns.json lives beside routes/; re-fetch same as route files (delete then write).
        do
            local fallPath = MOUNT_FALLSPAWNS_JSON
            if type(delFn) == "function" then
                local shouldTryDeleteFall = true
                if type(isFileFn) == "function" then
                    local okExistFall, existsFall = pcall(function()
                        return isFileFn(fallPath)
                    end)
                    shouldTryDeleteFall = okExistFall and existsFall == true
                end
                if shouldTryDeleteFall then
                    pcall(function()
                        delFn(fallPath)
                    end)
                end
            end
            local okFallGet, fallContent = pcall(function()
                return game:HttpGet(MOUNT_FALLSPAWNS_REMOTE, true)
            end)
            if okFallGet and type(fallContent) == "string" and #fallContent > 2 then
                pcall(function()
                    writeFn(fallPath, fallContent)
                end)
            end
        end
        mountRouteProbabilitiesLoadAttempted = false
        mountRouteProbabilitiesByPrefixCache = nil
        mountFallSpawnRowsLoadAttempted = false
        mountFallSpawnRowsCache = nil
        return true, nil
    end

    task.defer(function()
        pcall(syncMountYahayukRoutesFromRemote)
    end)

    local WalkVirtualInputManager = nil
    pcall(function()
        WalkVirtualInputManager = game:GetService("VirtualInputManager")
    end)
    local walkRouteRng = Random.new()

    local function listRouteJsonPathsInDir(): { string }
        local listFilesFn = resolveExecutorFnForMain("listfiles")
        if type(listFilesFn) ~= "function" then
            return {}
        end
        local ok, filesOrErr = pcall(function()
            return listFilesFn(MOUNT_ROUTES_DIR)
        end)
        if not ok or type(filesOrErr) ~= "table" then
            return {}
        end
        local out: { string } = {}
        for _, item in ipairs(filesOrErr) do
            if type(item) == "string" and isJsonPathMain(item) then
                table.insert(out, item)
            end
        end
        return out
    end

    local function listRouteJsonPathsForLegPrefix(prefix: string): { string }
        local all = listRouteJsonPathsInDir()
        local matches: { string } = {}
        local prefLower = string.lower(prefix .. "_")
        for _, p in ipairs(all) do
            local bn = string.lower(baseNameFromPathMain(p))
            if string.sub(bn, 1, #prefLower) == prefLower then
                table.insert(matches, p)
            end
        end
        table.sort(matches, function(a, b)
            return string.lower(baseNameFromPathMain(a)) < string.lower(baseNameFromPathMain(b))
        end)
        return matches
    end

    local function getMountRouteProbabilitiesByPrefix(readFileFn: any): { [string]: { [string]: number } }
        if mountRouteProbabilitiesLoadAttempted then
            return mountRouteProbabilitiesByPrefixCache or {}
        end
        mountRouteProbabilitiesLoadAttempted = true
        mountRouteProbabilitiesByPrefixCache = {}
        if type(readFileFn) ~= "function" then
            return {}
        end
        local okRead, jsonText = pcall(function()
            return readFileFn(MOUNT_ROUTES_INDEX_JSON)
        end)
        if not okRead or type(jsonText) ~= "string" or #jsonText < 2 then
            return {}
        end
        local okDec, decoded = pcall(function()
            return HttpService:JSONDecode(jsonText)
        end)
        if not okDec or type(decoded) ~= "table" then
            return {}
        end
        local rawByPrefix =
            decoded.routeProbabilitiesByPrefix or decoded.route_weights_by_prefix or decoded.routeWeightsByPrefix
        if type(rawByPrefix) ~= "table" then
            return {}
        end
        local out: { [string]: { [string]: number } } = {}
        for prefixKey, mapAny in pairs(rawByPrefix) do
            if type(prefixKey) == "string" and type(mapAny) == "table" then
                local pfx = string.lower(prefixKey)
                local m: { [string]: number } = {}
                for fileKey, wAny in pairs(mapAny) do
                    local fileName = type(fileKey) == "string" and string.lower(fileKey) or nil
                    local w = tonumber(wAny)
                    if fileName and w and w >= 0 then
                        m[fileName] = w
                    end
                end
                out[pfx] = m
            end
        end
        mountRouteProbabilitiesByPrefixCache = out
        return out
    end

    local function buildWeightedRouteOrder(
        candidates: { string },
        prefix: string,
        routeProbabilitiesByPrefix: { [string]: { [string]: number } }
    ): { string }
        local remaining: { string } = {}
        for i = 1, #candidates do
            remaining[i] = candidates[i]
        end

        local out: { string } = {}
        local pfx = string.lower(prefix or "")
        local pfxWeights = routeProbabilitiesByPrefix[pfx]

        while #remaining > 0 do
            local totalW = 0
            local weights: { number } = {}
            for i, p in ipairs(remaining) do
                local bn = string.lower(baseNameFromPathMain(p))
                local w = 1
                if type(pfxWeights) == "table" and type(pfxWeights[bn]) == "number" then
                    w = math.max(0, pfxWeights[bn])
                end
                weights[i] = w
                totalW = totalW + w
            end

            local pickIdx = 1
            if totalW > 0 then
                local roll = walkRouteRng:NextNumber(0, totalW)
                local acc = 0
                for i = 1, #remaining do
                    acc = acc + weights[i]
                    if roll <= acc then
                        pickIdx = i
                        break
                    end
                end
            else
                pickIdx = walkRouteRng:NextInteger(1, #remaining)
            end

            table.insert(out, remaining[pickIdx])
            table.remove(remaining, pickIdx)
        end

        return out
    end

    local function walkRouteFileIsFailedVariant(path: string): boolean
        local bn = string.lower(baseNameFromPathMain(path))
        return string.find(bn, "_failed_", 1, true) ~= nil
    end

    -- fallspawns.json: campName + position for each camp's FallSpawn / Start SpawnLocation.
    local FALL_SPAWN_MATCH_RADIUS_STUDS = 40

    local function campNameForWalkCheckpoint(cp: number): string?
        if cp <= 0 then
            return "Start"
        end
        if cp >= 6 then
            return nil
        end
        return "Camp " .. tostring(cp)
    end

    local function parseFallSpawnRowPosition(row: any): Vector3?
        if type(row) ~= "table" then
            return nil
        end
        local pos = row.position
        if type(pos) ~= "table" then
            return nil
        end
        local x = tonumber(pos.x)
        local y = tonumber(pos.y)
        local z = tonumber(pos.z)
        if not (x and y and z) then
            return nil
        end
        return Vector3.new(x, y, z)
    end

    local function fallSpawnWorldPositionForCamp(rows: { any }, campName: string): Vector3?
        if type(campName) ~= "string" or campName == "" then
            return nil
        end
        for _, row in ipairs(rows) do
            if type(row) == "table" and row.campName == campName then
                return parseFallSpawnRowPosition(row)
            end
        end
        return nil
    end

    local function rootPartNearWorldPosition(rootPart: BasePart, worldPos: Vector3, radius: number): boolean
        return (rootPart.Position - worldPos).Magnitude <= radius
    end

    local function getMountFallSpawnRows(readFileFn: any): { any }
        if mountFallSpawnRowsLoadAttempted then
            return mountFallSpawnRowsCache or {}
        end
        mountFallSpawnRowsLoadAttempted = true
        mountFallSpawnRowsCache = {}
        if type(readFileFn) ~= "function" then
            return {}
        end
        local okRead, jsonText = pcall(function()
            return readFileFn(MOUNT_FALLSPAWNS_JSON)
        end)
        if not okRead or type(jsonText) ~= "string" or #jsonText < 2 then
            return {}
        end
        local okDec, decoded = pcall(function()
            return HttpService:JSONDecode(jsonText)
        end)
        if not okDec or type(decoded) ~= "table" then
            return {}
        end
        local list = decoded.fallSpawns or decoded.fallspawns
        if type(list) ~= "table" then
            return {}
        end
        mountFallSpawnRowsCache = list
        return list
    end

    local function findFirstMovementWorldPosition(events: { any }): Vector3?
        for _, ev in ipairs(events) do
            if type(ev) == "table" and ev.kind == "movement" and type(ev.data) == "table" then
                local pos = ev.data.position
                if type(pos) == "table" then
                    local x, y, z = tonumber(pos.x), tonumber(pos.y), tonumber(pos.z)
                    if x and y and z then
                        return Vector3.new(x, y, z)
                    end
                end
            end
        end
        return nil
    end

    local function getCharacterHumanoidAndRootWalk(character: Model?): (Humanoid?, BasePart?)
        if not character then
            return nil, nil
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        return humanoid, rootPart
    end

    local function humanoidWalkToWorldPosition(
        humanoid: Humanoid,
        rootPart: BasePart,
        targetPos: Vector3,
        shouldCancel: () -> boolean,
        arrivalDist: number?
    ): boolean
        local thresh = arrivalDist or 8
        humanoid:MoveTo(targetPos)
        local dist0 = (rootPart.Position - targetPos).Magnitude
        local timeout = math.clamp(dist0 / math.max(4, humanoid.WalkSpeed) * 2.8, 15, 200)
        local start = os.clock()
        local moveDone = false
        local conn = humanoid.MoveToFinished:Connect(function()
            moveDone = true
        end)
        while not shouldCancel() do
            if (rootPart.Position - targetPos).Magnitude <= thresh then
                conn:Disconnect()
                return true
            end
            if moveDone then
                conn:Disconnect()
                return (rootPart.Position - targetPos).Magnitude <= thresh + 10
            end
            if os.clock() - start >= timeout then
                conn:Disconnect()
                return (rootPart.Position - targetPos).Magnitude <= thresh + 12
            end
            task.wait(0.1)
        end
        conn:Disconnect()
        pcall(function()
            humanoid:Move(Vector3.new(0, 0, 0))
        end)
        return false
    end

    local summitTeleportRoute = {
        { name = "Start", position = "-922.94, 169.22, 856.29", delay = 20 },
        { name = "Camp 1", position = "-407.77, 248.20, 794.09", delay = 20 },
        { name = "Camp 2", position = "-337.77, 388.27, 522.16", delay = 20 },
        { name = "Camp 3", position = "294.19, 430.33, 494.17", delay = 20 },
        { name = "Camp 4", position = "323.46, 490.24, 348.33", delay = 28 },
        { name = "Camp 5", position = "226.70, 314.21, -143.64", delay = 45 },
        { name = "Summit", position = "-613.51, 905.28, -533.45", delay = 1 },
    }

    local function parsePositionString(positionText)
        if typeof(positionText) ~= "string" then
            return nil
        end
        local xStr, yStr, zStr = string.match(positionText, "^%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*,%s*([%-%d%.]+)%s*$")
        local x, y, z = tonumber(xStr), tonumber(yStr), tonumber(zStr)
        if not x or not y or not z then
            return nil
        end
        return Vector3.new(x, y, z)
    end

    local function notifyAutoSummit(content, icon)
        mountNotify({ Title = "Auto Summit", Content = content, Icon = icon or "check" })
    end

    local function waitWithCancel(seconds, shouldCancel)
        local elapsed = 0
        local step = 0.25
        while elapsed < seconds do
            if shouldCancel() then
                return false
            end
            task.wait(math.min(step, seconds - elapsed))
            elapsed = elapsed + step
        end
        return true
    end

    MainTab:CreateSection("Auto Summit")

    MainTab:CreateButton({
        Name = "Refresh Routes (mode Walk)",
        Ext = true,
        Callback = function()
            task.spawn(function()
                notifyAutoSummit("Refreshing walk routes from remote...")
                local okSync, syncErr = syncMountYahayukRoutesFromRemote()
                if okSync then
                    notifyAutoSummit("Routes and fallspawns.json refreshed (delete + re-fetch + write)")
                else
                    notifyAutoSummit("Failed to refresh routes: " .. tostring(syncErr), "x")
                end
            end)
        end,
    })

    MainTab:CreateDropdown({
        Name = "Mode",
        Options = AUTO_SUMMIT_MODE_OPTIONS,
        CurrentOption = { autoSummitMode },
        Ext = true,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            if picked and table.find(AUTO_SUMMIT_MODE_OPTIONS, picked) then
                autoSummitMode = picked
                task.defer(updateAutoSummitRouteModeParagraph)
            end
        end,
    })

    local lpAutoSummit = Players.LocalPlayer

    local function releaseAutoSummitWalkVirtualKeys()
        if WalkVirtualInputManager then
            for keyCode, isDown in pairs(autoSummitWalkKeysDown) do
                if isDown then
                    pcall(function()
                        WalkVirtualInputManager:SendKeyEvent(false, keyCode, false, game)
                    end)
                end
                autoSummitWalkKeysDown[keyCode] = nil
            end
        else
            for k in pairs(autoSummitWalkKeysDown) do
                autoSummitWalkKeysDown[k] = nil
            end
        end
    end

    local function stopAutoSummitWalkCharacter()
        releaseAutoSummitWalkVirtualKeys()

        local char = lpAutoSummit.Character
        local humToStop = autoSummitWalkPlaybackHumanoid
        if not humToStop and char then
            humToStop = char:FindFirstChildOfClass("Humanoid")
        end
        if humToStop then
            pcall(function()
                humToStop:Move(Vector3.new(0, 0, 0))
            end)
        end

        local localRoot = char and char:FindFirstChild("HumanoidRootPart")
        if localRoot then
            pcall(function()
                localRoot.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
                localRoot.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
            end)
        end

        if autoSummitWalkPlaybackHumanoid and autoSummitWalkPlaybackAutoRotateRestore ~= nil then
            pcall(function()
                autoSummitWalkPlaybackHumanoid.AutoRotate = autoSummitWalkPlaybackAutoRotateRestore
            end)
        end
        autoSummitWalkPlaybackHumanoid = nil
        autoSummitWalkPlaybackAutoRotateRestore = nil
    end

    local function getCheckpointIndexFromPlayer(player)
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            local n = ls:FindFirstChild("LastCheckpoint")
            if n and n:IsA("IntValue") then
                return n.Value
            end
            local s = ls:FindFirstChild("Checkpoint")
            if s and s:IsA("StringValue") then
                local v = s.Value
                if v and v ~= "" then
                    if v:lower() == "start" then
                        return 0
                    end
                    local d = string.match(v, "%d+")
                    return (d and tonumber(d)) or 0
                end
            end
        end
        local a = player:GetAttribute("LastCheckpoint")
        if typeof(a) == "number" then
            return a
        end
        if typeof(a) == "string" and a ~= "" then
            if a:lower() == "start" then
                return 0
            end
            local d = string.match(a, "%d+")
            return (d and tonumber(d)) or 0
        end
        return 0
    end

    local function getCheckpointLabelString(player)
        local attr = player:GetAttribute("LastCheckpoint")
        if typeof(attr) == "string" and attr ~= "" then
            return attr
        end
        if typeof(attr) == "number" then
            return tostring(attr)
        end
        local ls = player:FindFirstChild("leaderstats")
        if ls then
            local iv = ls:FindFirstChild("LastCheckpoint")
            if iv and iv:IsA("IntValue") then
                return tostring(iv.Value)
            end
            local sv = ls:FindFirstChild("Checkpoint")
            if sv and sv:IsA("StringValue") and sv.Value ~= "" then
                return sv.Value
            end
        end
        return "Start"
    end

    local function checkpointLabelLooksLikeSummit(labelValue: any): boolean
        if typeof(labelValue) ~= "string" or labelValue == "" then
            return false
        end
        local low = string.lower(labelValue)
        return string.find(low, "summit", 1, true) ~= nil
    end

    local function getCheckpointIndexForWalkRouting(player, summitCpIndex: number): number
        local cp = getCheckpointIndexFromPlayer(player)
        -- In this place, Summit can be reported as CP 0 (same as Start) in some states.
        -- Use label text to disambiguate so routing can choose summit-start_* correctly.
        if cp == 0 and checkpointLabelLooksLikeSummit(getCheckpointLabelString(player)) then
            return summitCpIndex
        end
        return cp
    end

    local function playRouteRecordingEvents(events: { any }, shouldCancel: () -> boolean): boolean
        local nextMovementDeltaByIndex: { [number]: number? } = {}
        local nextMovementTime: number? = nil
        for i = #events, 1, -1 do
            local ev = events[i]
            local evTime = tonumber(ev.t) or 0
            if ev.kind == "movement" then
                nextMovementDeltaByIndex[i] = nextMovementTime and math.max(0, nextMovementTime - evTime) or nil
                nextMovementTime = evTime
            else
                nextMovementDeltaByIndex[i] = nil
            end
        end

        local function buildMovementTargetCFrame(rootPart: BasePart?, dataTable: { [string]: any }): CFrame?
            local pos = dataTable.position
            if not rootPart or type(pos) ~= "table" then
                return nil
            end
            local x = tonumber(pos.x)
            local y = tonumber(pos.y)
            local z = tonumber(pos.z)
            if not (x and y and z) then
                return nil
            end
            local basePos = Vector3.new(x, y, z)
            local lookData = dataTable.lookDirection
            local lx, ly, lz = nil, nil, nil
            if type(lookData) == "table" then
                lx = tonumber(lookData.x)
                ly = tonumber(lookData.y)
                lz = tonumber(lookData.z)
            end
            if lx and ly and lz then
                local lookVec = Vector3.new(lx, ly, lz)
                if lookVec.Magnitude > 1e-4 then
                    local planar = Vector3.new(lookVec.X, 0, lookVec.Z)
                    if planar.Magnitude > 1e-4 then
                        return CFrame.lookAt(basePos, basePos + planar.Unit)
                    end
                end
            end
            local fallback = rootPart.CFrame.LookVector
            local fallbackPlanar = Vector3.new(fallback.X, 0, fallback.Z)
            if fallbackPlanar.Magnitude > 1e-4 then
                return CFrame.lookAt(basePos, basePos + fallbackPlanar.Unit)
            end
            return CFrame.new(basePos)
        end

        local function applySmoothRootCFrame(rootPart: BasePart, targetCf: CFrame, durationSec: number)
            if durationSec <= 0.015 then
                rootPart.CFrame = targetCf
                return
            end
            local startCf = rootPart.CFrame
            local t0 = os.clock()
            while not shouldCancel() do
                local alpha = (os.clock() - t0) / durationSec
                if alpha >= 1 then
                    break
                end
                rootPart.CFrame = startCf:Lerp(targetCf, math.clamp(alpha, 0, 1))
                task.wait()
            end
            if not shouldCancel() then
                rootPart.CFrame = targetCf
            end
        end

        local started = os.clock()

        for i, event in ipairs(events) do
            if shouldCancel() then
                if autoSummitWalkPlaybackHumanoid and autoSummitWalkPlaybackAutoRotateRestore ~= nil then
                    pcall(function()
                        autoSummitWalkPlaybackHumanoid.AutoRotate = autoSummitWalkPlaybackAutoRotateRestore
                    end)
                end
                autoSummitWalkPlaybackHumanoid = nil
                autoSummitWalkPlaybackAutoRotateRestore = nil
                releaseAutoSummitWalkVirtualKeys()
                return false
            end
            local targetT = tonumber(event.t) or 0
            while not shouldCancel() and (os.clock() - started) < targetT do
                task.wait(0.01)
            end
            if shouldCancel() then
                if autoSummitWalkPlaybackHumanoid and autoSummitWalkPlaybackAutoRotateRestore ~= nil then
                    pcall(function()
                        autoSummitWalkPlaybackHumanoid.AutoRotate = autoSummitWalkPlaybackAutoRotateRestore
                    end)
                end
                autoSummitWalkPlaybackHumanoid = nil
                autoSummitWalkPlaybackAutoRotateRestore = nil
                releaseAutoSummitWalkVirtualKeys()
                return false
            end
            local kind = event.kind
            local data = type(event.data) == "table" and event.data or {}
            local character = lpAutoSummit.Character
            local humanoid, rootPart = getCharacterHumanoidAndRootWalk(character)

            if humanoid and autoSummitWalkPlaybackHumanoid ~= humanoid then
                if autoSummitWalkPlaybackHumanoid and autoSummitWalkPlaybackAutoRotateRestore ~= nil then
                    pcall(function()
                        autoSummitWalkPlaybackHumanoid.AutoRotate = autoSummitWalkPlaybackAutoRotateRestore
                    end)
                end
                autoSummitWalkPlaybackHumanoid = humanoid
                autoSummitWalkPlaybackAutoRotateRestore = humanoid.AutoRotate
                pcall(function()
                    humanoid.AutoRotate = false
                end)
            end

            if kind == "movement" then
                local targetCf = buildMovementTargetCFrame(rootPart, data)
                if rootPart and targetCf then
                    local nextDelta = nextMovementDeltaByIndex[i]
                    local smoothDuration = nextDelta and math.clamp(nextDelta * 0.8, 0.03, 0.14) or 0.07
                    pcall(function()
                        applySmoothRootCFrame(rootPart, targetCf, smoothDuration)
                    end)
                    local vel = data.velocity
                    if type(vel) == "table" then
                        local vx, vy, vz = tonumber(vel.x), tonumber(vel.y), tonumber(vel.z)
                        if vx and vy and vz then
                            pcall(function()
                                rootPart.AssemblyLinearVelocity = Vector3.new(vx, vy, vz)
                            end)
                        end
                    end
                end
            elseif kind == "jump_request" then
                if humanoid then
                    pcall(function()
                        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end)
                end
            elseif (kind == "key_down" or kind == "key_up") and WalkVirtualInputManager then
                local keyCodeName = type(data.keyCode) == "string" and data.keyCode or ""
                local enumName = string.match(keyCodeName, "Enum%.KeyCode%.(.+)")
                local keyCode = enumName and Enum.KeyCode[enumName]
                if keyCode then
                    local isDown = kind == "key_down"
                    pcall(function()
                        WalkVirtualInputManager:SendKeyEvent(isDown, keyCode, false, game)
                    end)
                    autoSummitWalkKeysDown[keyCode] = isDown or nil
                end
            end
        end

        if autoSummitWalkPlaybackHumanoid and autoSummitWalkPlaybackAutoRotateRestore ~= nil then
            pcall(function()
                autoSummitWalkPlaybackHumanoid.AutoRotate = autoSummitWalkPlaybackAutoRotateRestore
            end)
        end
        autoSummitWalkPlaybackHumanoid = nil
        autoSummitWalkPlaybackAutoRotateRestore = nil
        releaseAutoSummitWalkVirtualKeys()
        return true
    end

    local autoSummitDeathCheckConn: any = nil

    -- Auto Summit UI: route file (walk) or teleport leg + delay (teleport)
    local autoSummitWalkRouteFileDisplay = "—"
    local autoSummitTeleportCurrentLeg = "—"
    local autoSummitTeleportNextLeg = "—"
    local autoSummitTeleportDelayText = "—"

    local AutoSummitRouteModeParagraph: any = nil
    updateAutoSummitRouteModeParagraph = function()
        if not AutoSummitRouteModeParagraph or not AutoSummitRouteModeParagraph.Set then
            return
        end
        if not autoSummitEnabled then
            AutoSummitRouteModeParagraph:Set({
                Title = "Active route / teleport",
                Content = "Auto Summit is off.",
            })
            return
        end
        if autoSummitMode == "Walk" then
            AutoSummitRouteModeParagraph:Set({
                Title = "Active route / teleport",
                Content = "Walk mode\nCurrent: " .. autoSummitWalkRouteFileDisplay,
            })
            return
        end
        AutoSummitRouteModeParagraph:Set({
            Title = "Active route / teleport",
            Content = string.format(
                "Teleport mode\nCurrent: %s\nNext: %s\nDelay (this stop): %s",
                autoSummitTeleportCurrentLeg,
                autoSummitTeleportNextLeg,
                autoSummitTeleportDelayText
            ),
        })
    end

    local function disableAutoSummitDueToWalkFailure(reason: string)
        autoSummitSkipFinalStoppedNotify = true
        autoSummitEnabled = false
        stopAutoSummitWalkCharacter()
        notifyAutoSummit(reason, "x")
        local tgl = autoSummitMainToggle
        if tgl then
            pcall(function()
                if tgl.Set then
                    tgl:Set(false)
                elseif tgl.SetValue then
                    tgl:SetValue(false)
                end
            end)
        end
        if autoSummitDeathCheckConn then
            autoSummitDeathCheckConn:Disconnect()
            autoSummitDeathCheckConn = nil
        end
    end

    -- After a *_failed_* recording finishes and CP is unchanged, retry using other JSONs for this leg,
    -- excluding failed files recorded in excludePaths (prefer non-failed routes first).
    -- excludePaths is reset at the start of each new leg (outer loop) in runWalkSummitLegsFromCurrentCp.
    local function rebuildWalkLegPathsAfterFailedAttempts(
        allCandidates: { string },
        excludePaths: { [string]: boolean },
        prefix: string,
        routeProbabilitiesByPrefix: { [string]: { [string]: number } }
    ): { string }
        local rest: { string } = {}
        for _, p in ipairs(allCandidates) do
            if not excludePaths[p] then
                table.insert(rest, p)
            end
        end
        local successPaths: { string } = {}
        local failedPaths: { string } = {}
        for _, p in ipairs(rest) do
            if walkRouteFileIsFailedVariant(p) then
                table.insert(failedPaths, p)
            else
                table.insert(successPaths, p)
            end
        end
        successPaths = buildWeightedRouteOrder(successPaths, prefix, routeProbabilitiesByPrefix)
        failedPaths = buildWeightedRouteOrder(failedPaths, prefix, routeProbabilitiesByPrefix)
        local out: { string } = {}
        for _, p in ipairs(successPaths) do
            table.insert(out, p)
        end
        for _, p in ipairs(failedPaths) do
            table.insert(out, p)
        end
        return out
    end

    local function tryLoadWalkRouteRecording(
        readFileFn: any,
        pickedPath: string,
        tryIdx: number,
        totalTries: number
    ): ({ any }?, Vector3?, string?, string?)
        local baseName = baseNameFromPathMain(pickedPath)
        local label = ("(%d/%d)"):format(tryIdx, totalTries)
        local okRead, jsonText = pcall(function()
            return readFileFn(pickedPath)
        end)
        if not okRead or type(jsonText) ~= "string" then
            return nil, nil, baseName, "read failed " .. label
        end
        local okDecode, payload = pcall(function()
            return HttpService:JSONDecode(jsonText)
        end)
        if not okDecode or type(payload) ~= "table" then
            return nil, nil, baseName, "invalid JSON " .. label
        end
        local events = payload.events
        if type(events) ~= "table" or #events == 0 then
            return nil, nil, baseName, "no events " .. label
        end
        local firstPos = findFirstMovementWorldPosition(events)
        if not firstPos then
            return nil, nil, baseName, "no movement samples " .. label
        end
        return events, firstPos, baseName, nil
    end

    local function runWalkSummitLegsFromCurrentCp(
        shouldCancel: () -> boolean,
        getRootPart: (number?) -> BasePart?
    ): (boolean, boolean)
        local readFileFn = resolveExecutorFnForMain("readfile")
        if type(readFileFn) ~= "function" then
            disableAutoSummitDueToWalkFailure("Walk mode needs readfile() from your executor")
            return false, false
        end
        if type(resolveExecutorFnForMain("listfiles")) ~= "function" then
            disableAutoSummitDueToWalkFailure("Walk mode needs listfiles() from your executor")
            return false, false
        end

        local routeProbabilitiesByPrefix = getMountRouteProbabilitiesByPrefix(readFileFn)
        local fallSpawnRows = getMountFallSpawnRows(readFileFn)

        autoSummitWalkRouteFileDisplay = "—"
        task.defer(updateAutoSummitRouteModeParagraph)

        local routeN = #summitTeleportRoute
        local summitCpIndex = routeN - 1
        local reachedSummitInThisCycle = false

        while autoSummitEnabled and not shouldCancel() do
            local cpLegRaw = getCheckpointIndexForWalkRouting(lpAutoSummit, summitCpIndex)
            -- Some servers can report a CP value above summit; treat it as summit
            -- so walk mode still runs summit-start_* instead of exiting early.
            local cpLeg = cpLegRaw > summitCpIndex and summitCpIndex or cpLegRaw
            local prefix = WALK_LEG_PREFIX_BY_CP[cpLeg]
            local runSingleLegOnly = cpLeg >= summitCpIndex
            if not prefix then
                if cpLeg >= summitCpIndex then
                    return true, reachedSummitInThisCycle
                end
                disableAutoSummitDueToWalkFailure("No walk route mapping for CP #" .. tostring(cpLeg))
                return false, reachedSummitInThisCycle
            end
            if cpLeg == 0 then
                local startCpDelaySec = walkRouteRng:NextNumber(0, 0.5)
                if not waitWithCancel(startCpDelaySec, shouldCancel) then
                    return false, reachedSummitInThisCycle
                end
            end

            local candidates = listRouteJsonPathsForLegPrefix(prefix)
            if not autoSummitIncludeFailedRoute then
                local filtered: { string } = {}
                for _, p in ipairs(candidates) do
                    if not walkRouteFileIsFailedVariant(p) then
                        table.insert(filtered, p)
                    end
                end
                candidates = filtered
            end
            if #candidates == 0 then
                disableAutoSummitDueToWalkFailure(
                    "No JSON in " .. MOUNT_ROUTES_DIR .. " for leg " .. prefix .. "_* — Auto Summit off"
                )
                return false, reachedSummitInThisCycle
            end

            -- Cleared each outer loop: failed-route exclusions must not carry to the next camp/leg.
            local legExcludedPaths: { [string]: boolean } = {}

            local pathsToTry: { string } = {}
            for i = 1, #candidates do
                pathsToTry[i] = candidates[i]
            end
            pathsToTry = buildWeightedRouteOrder(pathsToTry, prefix, routeProbabilitiesByPrefix)

            local legAdvanced = false
            local retryLegWithFreshCandidates = false
            local tryIdx = 1
            while tryIdx <= #pathsToTry do
                if not autoSummitEnabled or shouldCancel() then
                    return false, reachedSummitInThisCycle
                end

                local pickedPath = pathsToTry[tryIdx]

                local events, firstPos, baseName, loadErr = tryLoadWalkRouteRecording(
                    readFileFn,
                    pickedPath,
                    tryIdx,
                    #pathsToTry
                )
                if not events or not firstPos then
                    notifyAutoSummit(
                        ("Skip %s: %s"):format(baseName or baseNameFromPathMain(pickedPath), tostring(loadErr)),
                        "x"
                    )
                    tryIdx = tryIdx + 1
                else
                    notifyAutoSummit(
                        ("Walk leg CP%d -> %s (try %s/%s: %s)"):format(
                            cpLeg,
                            prefix,
                            tostring(tryIdx),
                            tostring(#pathsToTry),
                            baseName
                        )
                    )

                    autoSummitWalkRouteFileDisplay = baseName
                    task.defer(updateAutoSummitRouteModeParagraph)

                    local rootPart = getRootPart()
                    if not rootPart then
                        return false, reachedSummitInThisCycle
                    end
                    local character = lpAutoSummit.Character
                    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
                    if not humanoid then
                        return false, reachedSummitInThisCycle
                    end
                    humanoidWalkToWorldPosition(humanoid, rootPart, firstPos, shouldCancel, 7)
                    if shouldCancel() then
                        return false, reachedSummitInThisCycle
                    end

                    if not playRouteRecordingEvents(events, shouldCancel) then
                        return false, reachedSummitInThisCycle
                    end

                    local isFailedLegRoute = walkRouteFileIsFailedVariant(pickedPath)
                    if isFailedLegRoute then
                        notifyAutoSummit(
                            ("Playback finished (%s) — watching CP / fall spawn (up to ~12s)..."):format(baseName),
                            "check"
                        )
                    end

                    -- CP can update shortly after playback. For *_failed_* routes, CP often stays the same;
                    -- fallspawns.json (campName + position) detects respawn at this leg's camp so we can continue.
                    local cpBeforeLeg = cpLeg
                    local advanced = false
                    local atFallSpawnForLeg = false
                    local cpPollMax = 50
                    for pollI = 1, cpPollMax do
                        if shouldCancel() then
                            return false, reachedSummitInThisCycle
                        end
                        local cpNow = getCheckpointIndexForWalkRouting(lpAutoSummit, summitCpIndex)
                        if cpNow ~= cpBeforeLeg then
                            advanced = true
                            break
                        end
                        if isFailedLegRoute and #fallSpawnRows > 0 then
                            local campNm = campNameForWalkCheckpoint(cpBeforeLeg)
                            local spawnPos = campNm and fallSpawnWorldPositionForCamp(fallSpawnRows, campNm)
                            local charPoll = lpAutoSummit.Character
                            local rootPoll = charPoll and charPoll:FindFirstChild("HumanoidRootPart")
                            if
                                spawnPos
                                and rootPoll
                                and rootPoll:IsA("BasePart")
                                and rootPartNearWorldPosition(rootPoll, spawnPos, FALL_SPAWN_MATCH_RADIUS_STUDS)
                            then
                                atFallSpawnForLeg = true
                                break
                            end
                        end
                        if pollI < cpPollMax then
                            task.wait(0.25)
                        end
                    end
                    if advanced then
                        local cpAfterLeg = getCheckpointIndexForWalkRouting(lpAutoSummit, summitCpIndex)
                        if cpBeforeLeg < summitCpIndex and cpAfterLeg >= summitCpIndex then
                            reachedSummitInThisCycle = true
                        end
                        if cpAfterLeg < summitCpIndex then
                            local nextPrefix = WALK_LEG_PREFIX_BY_CP[cpAfterLeg] or "unknown"
                            notifyAutoSummit(
                                ("Leg done at CP #%d -> next route %s_*"):format(
                                    cpAfterLeg,
                                    tostring(nextPrefix)
                                )
                            )
                        end
                        legAdvanced = true
                        break
                    end

                    if isFailedLegRoute then
                        legExcludedPaths[pickedPath] = true
                        local rest = rebuildWalkLegPathsAfterFailedAttempts(
                            candidates,
                            legExcludedPaths,
                            prefix,
                            routeProbabilitiesByPrefix
                        )
                        if #rest == 0 then
                            retryLegWithFreshCandidates = true
                            notifyAutoSummit(
                                ("No remaining routes for %s after %s — rechecking route list for this camp..."):format(
                                    prefix,
                                    baseName
                                ),
                                "x"
                            )
                            break
                        else
                            if atFallSpawnForLeg then
                                local cn = campNameForWalkCheckpoint(cpBeforeLeg) or ("CP " .. tostring(cpBeforeLeg))
                                notifyAutoSummit(
                                    ("At %s fall spawn (still CP #%d) after %s — retrying other routes (skipped this file)."):format(
                                        cn,
                                        cpLeg,
                                        baseName
                                    ),
                                    "x"
                                )
                            else
                                notifyAutoSummit(
                                    ("Still at CP #%d after failed route %s — retrying other routes (skipped this file)."):format(
                                        cpLeg,
                                        baseName
                                    ),
                                    "x"
                                )
                            end
                            pathsToTry = rest
                            tryIdx = 1
                        end
                    else
                        notifyAutoSummit(
                            ("CP did not change after %s — trying next route (%s/%s)"):format(
                                baseName,
                                tostring(tryIdx),
                                tostring(#pathsToTry)
                            ),
                            "x"
                        )
                        tryIdx = tryIdx + 1
                    end
                end
            end

            if not legAdvanced then
                if retryLegWithFreshCandidates then
                    task.wait(0.25)
                else
                    disableAutoSummitDueToWalkFailure(
                        "All "
                            .. tostring(#pathsToTry)
                            .. " route file(s) failed for leg "
                            .. prefix
                            .. " — Auto Summit off"
                    )
                    return false, reachedSummitInThisCycle
                end
            end
            if runSingleLegOnly then
                return true, reachedSummitInThisCycle
            end
        end

        if not autoSummitEnabled or shouldCancel() then
            return false, reachedSummitInThisCycle
        end
        return getCheckpointIndexForWalkRouting(lpAutoSummit, summitCpIndex) >= summitCpIndex, reachedSummitInThisCycle
    end

    local function routeLabelForCpIndex(idx)
        local wp = summitTeleportRoute[idx + 1]
        if wp then
            return wp.name
        end
        return "CP " .. tostring(idx)
    end

    -- CP 0 = Start â€¦ CP (#route-1) = Summit. Next teleport is route[cp+2] (1-based); at/past Summit nothing to skip.
    local function getFirstSummitRouteIndexFromCp(cpIdx)
        local routeN = #summitTeleportRoute
        local summitCpIndex = routeN - 1
        local cp = cpIdx
        if typeof(cp) ~= "number" then
            cp = 0
        end
        cp = math.floor(cp)
        if cp < 0 then
            cp = 0
        end
        if cp >= summitCpIndex then
            return nil, cp
        end
        local first = cp + 2
        if first < 1 then
            first = 1
        end
        if first > routeN then
            return nil, cp
        end
        return first, cp
    end

    local autoSummitRunTimes = {}

    local function formatAutoSummitDuration(sec)
        if typeof(sec) ~= "number" or sec ~= sec or sec < 0 then
            return "—"
        end
        if sec < 60 then
            return string.format("%.1fs", sec)
        end
        local m = math.floor(sec / 60)
        local s = sec - m * 60
        return string.format("%dm %.1fs", m, s)
    end

    local AUTO_SUMMIT_TIMES_TITLE = "Time per summit (this session)"
    local AutoSummitTimesParagraph
    local function updateAutoSummitTimesParagraph()
        if not AutoSummitTimesParagraph then
            return
        end
        local lines = {}
        local n = #autoSummitRunTimes
        local startIdx = 1
        local maxLines = 20
        if n > maxLines then
            startIdx = n - maxLines + 1
            table.insert(lines, "(Showing last " .. maxLines .. " runs)")
        end
        for i = startIdx, n do
            table.insert(
                lines,
                string.format("Run %d: %s", i, formatAutoSummitDuration(autoSummitRunTimes[i]))
            )
        end
        local desc = #lines > 0 and table.concat(lines, "\n") or "No completed runs yet."
        if AutoSummitTimesParagraph.Set then
            AutoSummitTimesParagraph:Set({
                Title = AUTO_SUMMIT_TIMES_TITLE,
                Content = desc,
            })
        end
    end

    local AUTO_SUMMIT_CP_TITLE = "Current camp / CP"
    local AutoSummitCpParagraph
    local function updateAutoSummitCpParagraph()
        if not autoSummitEnabled then
            return
        end
        if not AutoSummitCpParagraph then
            return
        end
        local posisi = getCheckpointLabelString(lpAutoSummit)
        local idx = getCheckpointIndexFromPlayer(lpAutoSummit)
        local routeName = routeLabelForCpIndex(idx)
        local desc = string.format("POSISI: %s\nCP #%d Â· %s", string.upper(posisi), idx, routeName)
        if AutoSummitCpParagraph.Set then
            AutoSummitCpParagraph:Set({
                Title = AUTO_SUMMIT_CP_TITLE,
                Content = desc,
            })
        end
    end

    AutoSummitCpParagraph = MainTab:CreateParagraph({
        Title = AUTO_SUMMIT_CP_TITLE,
        Content = "POSISI: â€”\nCP #0 Â· Start",
    })

    AutoSummitRouteModeParagraph = MainTab:CreateParagraph({
        Title = "Active route / teleport",
        Content = "Auto Summit is off.",
    })
    task.defer(updateAutoSummitRouteModeParagraph)

    AutoSummitTimesParagraph = MainTab:CreateParagraph({
        Title = AUTO_SUMMIT_TIMES_TITLE,
        Content = "No completed runs yet.",
    })

    local function attachLeaderstatsForCp(ls)
        local function onCheckpointValueChanged()
            updateAutoSummitCpParagraph()
        end
        local n = ls:FindFirstChild("LastCheckpoint")
        if n and n:IsA("IntValue") then
            n:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
        end
        local s = ls:FindFirstChild("Checkpoint")
        if s and s:IsA("StringValue") then
            s:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
        end
        ls.ChildAdded:Connect(function(ch)
            if ch.Name == "LastCheckpoint" and ch:IsA("IntValue") then
                ch:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
                onCheckpointValueChanged()
            elseif ch.Name == "Checkpoint" and ch:IsA("StringValue") then
                ch:GetPropertyChangedSignal("Value"):Connect(onCheckpointValueChanged)
                onCheckpointValueChanged()
            end
        end)
    end

    lpAutoSummit:GetAttributeChangedSignal("LastCheckpoint"):Connect(updateAutoSummitCpParagraph)
    local lsSummitCp = lpAutoSummit:FindFirstChild("leaderstats")
    if lsSummitCp then
        attachLeaderstatsForCp(lsSummitCp)
    end
    lpAutoSummit.ChildAdded:Connect(function(ch)
        if ch.Name == "leaderstats" then
            attachLeaderstatsForCp(ch)
            updateAutoSummitCpParagraph()
        end
    end)
    task.defer(updateAutoSummitCpParagraph)

    local SummitQtyInput = MainTab:CreateInput({
        Name = "Qty of summit",
        PlaceholderText = "Empty = unlimited",
        CurrentValue = "",
        Ext = true,
        Callback = function(value)
            summitQty = value
        end,
    })

    MainTab:CreateToggle({
        Name = "Randomize duration (teleport mode)",
        CurrentValue = false,
        Ext = true,
        Callback = function(enabled)
            autoSummitRandomizeTeleportDuration = enabled
        end,
    })

    MainTab:CreateToggle({
        Name = "Include Failed Route",
        CurrentValue = false,
        Ext = true,
        Callback = function(enabled)
            autoSummitIncludeFailedRoute = enabled
        end,
    })

    local function onAutoSummitDeath()
        autoSummitRestartFromDeath = true
    end

    local function connectAutoSummitCharacterDied(character)
        if not character then
            return
        end
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if not humanoid then
            return
        end
        humanoid.Died:Connect(onAutoSummitDeath)
        humanoid.HealthChanged:Connect(function(health)
            if health <= 0 then
                onAutoSummitDeath()
            end
        end)
    end

    if lpAutoSummit.Character then
        connectAutoSummitCharacterDied(lpAutoSummit.Character)
    end
    lpAutoSummit.CharacterAdded:Connect(connectAutoSummitCharacterDied)

    autoSummitMainToggle = MainTab:CreateToggle({
        Name = "Auto Summit",
        CurrentValue = false,
        Ext = true,
        Callback = function(enabled)
            autoSummitEnabled = enabled
            if not enabled then
                if autoSummitDeathCheckConn then
                    autoSummitDeathCheckConn:Disconnect()
                    autoSummitDeathCheckConn = nil
                end
                stopAutoSummitWalkCharacter()
                autoSummitWalkRouteFileDisplay = "—"
                autoSummitTeleportCurrentLeg = "—"
                autoSummitTeleportNextLeg = "—"
                autoSummitTeleportDelayText = "—"
                task.defer(updateAutoSummitRouteModeParagraph)
                return
            end

            autoSummitRestartFromDeath = false
            autoSummitRunTimes = {}
            updateAutoSummitTimesParagraph()
            updateAutoSummitCpParagraph()
            updateAutoSummitRouteModeParagraph()

            if autoSummitDeathCheckConn then
                autoSummitDeathCheckConn:Disconnect()
            end
            autoSummitDeathCheckConn = RunService.Heartbeat:Connect(function()
                if not autoSummitEnabled then
                    return
                end
                local char = lpAutoSummit.Character
                if not char then
                    return
                end
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum and hum.Health <= 0 then
                    onAutoSummitDeath()
                end
            end)

            local function getRootPart(timeoutSec)
                local char = lpAutoSummit.Character
                if not char then
                    char = lpAutoSummit.CharacterAdded:Wait()
                end
                return char:WaitForChild("HumanoidRootPart", timeoutSec or 15)
            end

            local rootPart = getRootPart()
            if not rootPart then
                notifyAutoSummit("Character not loaded", "x")
                return
            end

            local function shouldAbort()
                return not autoSummitEnabled or autoSummitRestartFromDeath
            end

            task.spawn(function()
                local qtyNum = tonumber(summitQty and summitQty:gsub("%s+", "") or "")
                local runCount = 0
                local remaining = qtyNum
                local skipNextCpResumeNotify = false
                repeat
                    if not autoSummitEnabled then
                        break
                    end
                    if autoSummitMode == "Teleport" then
                        autoSummitTeleportCurrentLeg = "—"
                        autoSummitTeleportNextLeg = "—"
                        autoSummitTeleportDelayText = "—"
                    else
                        autoSummitWalkRouteFileDisplay = "—"
                    end
                    task.defer(updateAutoSummitRouteModeParagraph)
                    local runStartTime = os.clock()
                    rootPart = getRootPart()
                    if not rootPart then
                        local char = lpAutoSummit.Character
                        if char then
                            char:WaitForChild("HumanoidRootPart", 10)
                        else
                            char = lpAutoSummit.CharacterAdded:Wait()
                            char:WaitForChild("HumanoidRootPart", 10)
                        end
                        task.wait(1)
                        rootPart = getRootPart()
                        if not rootPart then
                            notifyAutoSummit("Could not get character after respawn", "x")
                            break
                        end
                    end

                    local routeCompleted = true
                    local cpNow = getCheckpointIndexFromPlayer(lpAutoSummit)
                    local cpAtRunStart = cpNow
                    local summitCpIndexNow = #summitTeleportRoute - 1
                    local walkReachedSummitThisCycle = false
                    local firstWpIndex, cpClamped = getFirstSummitRouteIndexFromCp(cpNow)
                    local skippedSummitTeleports = firstWpIndex == nil
                    if autoSummitMode == "Walk" then
                        skippedSummitTeleports = WALK_LEG_PREFIX_BY_CP[cpNow] == nil
                        cpClamped = cpNow
                        if skippedSummitTeleports then
                            skipNextCpResumeNotify = false
                        elseif not skipNextCpResumeNotify then
                            notifyAutoSummit(
                                ("CP #%d (%s) â€” walk mode from next legâ€¦"):format(
                                    cpClamped,
                                    routeLabelForCpIndex(cpClamped)
                                )
                            )
                        else
                            skipNextCpResumeNotify = false
                        end
                        if not skippedSummitTeleports then
                            local okWalk, reachedWalkSummit = runWalkSummitLegsFromCurrentCp(shouldAbort, getRootPart)
                            walkReachedSummitThisCycle = reachedWalkSummit == true
                            if not okWalk then
                                routeCompleted = false
                            end
                        end
                    else
                        if skippedSummitTeleports then
                            skipNextCpResumeNotify = false
                        elseif not skipNextCpResumeNotify then
                            notifyAutoSummit(
                                ("CP #%d (%s) â€” continuing from %sâ€¦"):format(
                                    cpClamped,
                                    routeLabelForCpIndex(cpClamped),
                                    summitTeleportRoute[firstWpIndex].name
                                )
                            )
                        else
                            skipNextCpResumeNotify = false
                        end
                        if not skippedSummitTeleports then
                            for wi = firstWpIndex, #summitTeleportRoute do
                                local wp = summitTeleportRoute[wi]
                                if not autoSummitEnabled or autoSummitRestartFromDeath then
                                    routeCompleted = false
                                    break
                                end
                                rootPart = getRootPart()
                                if not rootPart then
                                    routeCompleted = false
                                    break
                                end
                                local targetPosition = parsePositionString(wp.position)
                                if not targetPosition then
                                    routeCompleted = false
                                    notifyAutoSummit("Invalid position for " .. wp.name, "x")
                                    break
                                end
                                rootPart.CFrame = CFrame.new(targetPosition)
                                notifyAutoSummit("Teleported to " .. wp.name .. "â€¦")
                                local waitSec = wp.delay
                                local delayRandomized = false
                                if
                                    autoSummitMode == "Teleport"
                                    and autoSummitRandomizeTeleportDuration
                                    and wp.name ~= "Summit"
                                then
                                    waitSec = math.max(0.5, wp.delay + math.random(-15, 15))
                                    delayRandomized = true
                                end
                                local nextWp = summitTeleportRoute[wi + 1]
                                autoSummitTeleportCurrentLeg = wp.name
                                autoSummitTeleportNextLeg = nextWp and nextWp.name or "—"
                                if delayRandomized then
                                    autoSummitTeleportDelayText = string.format("%.1fs (randomized)", waitSec)
                                else
                                    autoSummitTeleportDelayText = string.format("%.1fs", waitSec)
                                end
                                task.defer(updateAutoSummitRouteModeParagraph)
                                if not waitWithCancel(waitSec, shouldAbort) then
                                    routeCompleted = false
                                    break
                                end
                            end
                        end
                    end

                    if autoSummitRestartFromDeath then
                        notifyAutoSummit("Character died â€” waiting for respawnâ€¦")
                        local char = lpAutoSummit.Character
                        if not char then
                            char = lpAutoSummit.CharacterAdded:Wait()
                        else
                            local hum = char:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health <= 0 then
                                char = lpAutoSummit.CharacterAdded:Wait()
                            end
                        end
                        if char then
                            char:WaitForChild("HumanoidRootPart", 15)
                            task.wait(0.5)
                        end
                        for _ = 1, 15 do
                            if lpAutoSummit:FindFirstChild("leaderstats") then
                                break
                            end
                            task.wait(0.1)
                        end
                        task.wait(0.35)
                        local cpRespawn = getCheckpointIndexFromPlayer(lpAutoSummit)
                        local firstRespawn, cpRespawnClamped = getFirstSummitRouteIndexFromCp(cpRespawn)
                        task.defer(updateAutoSummitCpParagraph)
                        autoSummitRestartFromDeath = false
                        skipNextCpResumeNotify = true
                        if firstRespawn == nil then
                            notifyAutoSummit(
                                ("Respawned â€” CP #%d (%s). Next leg: Summit / count run (no teleports)."):format(
                                    cpRespawnClamped,
                                    routeLabelForCpIndex(cpRespawnClamped)
                                )
                            )
                        else
                            notifyAutoSummit(
                                ("Respawned â€” CP #%d (%s); resuming from %s."):format(
                                    cpRespawnClamped,
                                    routeLabelForCpIndex(cpRespawnClamped),
                                    summitTeleportRoute[firstRespawn].name
                                )
                            )
                        end
                    elseif routeCompleted and autoSummitEnabled then
                        local cpAfterRun = getCheckpointIndexFromPlayer(lpAutoSummit)
                        local atSummitNow = cpAfterRun >= summitCpIndexNow
                        local reachedSummitThisRun = false
                        if autoSummitMode == "Walk" then
                            reachedSummitThisRun = walkReachedSummitThisCycle
                        else
                            reachedSummitThisRun = cpAtRunStart < summitCpIndexNow and atSummitNow
                        end

                        if reachedSummitThisRun then
                            notifyAutoSummit("Reached Summit! (Run " .. (runCount + 1) .. ")")
                            local elapsedRun = os.clock() - runStartTime
                            table.insert(autoSummitRunTimes, elapsedRun)
                            task.defer(updateAutoSummitTimesParagraph)
                            runCount = runCount + 1
                            if remaining then
                                remaining = remaining - 1
                                summitQty = tostring(remaining)
                                task.defer(function()
                                    if SummitQtyInput then
                                        if SummitQtyInput.Set then
                                            SummitQtyInput:Set(summitQty)
                                        end
                                        if SummitQtyInput.SetValue then
                                            SummitQtyInput:SetValue(summitQty)
                                        end
                                    end
                                end)
                            end
                            if autoSummitEnabled and (not qtyNum or remaining > 0) then
                                if not waitWithCancel(BETWEEN_RUN_DELAY, function()
                                    return not autoSummitEnabled
                                end) then
                                    break
                                end
                            end
                        elseif atSummitNow then
                            notifyAutoSummit(
                                ("At Summit (CP #%d), waiting for camp change before counting next run."):format(
                                    cpAfterRun
                                )
                            )
                            if not waitWithCancel(1, function()
                                return not autoSummitEnabled
                            end) then
                                break
                            end
                        else
                            notifyAutoSummit(
                                ("Route ended at CP #%d (%s) — continuing from current camp."):format(
                                    cpAfterRun,
                                    routeLabelForCpIndex(cpAfterRun)
                                )
                            )
                        end
                    end
                until not autoSummitEnabled or (qtyNum and remaining and remaining <= 0)

                if autoSummitEnabled and qtyNum and remaining and remaining <= 0 then
                    notifyAutoSummit("All runs completed (" .. runCount .. " run(s))")
                elseif not autoSummitEnabled then
                    if autoSummitSkipFinalStoppedNotify then
                        autoSummitSkipFinalStoppedNotify = false
                    else
                        notifyAutoSummit("Stopped", "x")
                    end
                end

                if autoSummitDeathCheckConn then
                    autoSummitDeathCheckConn:Disconnect()
                    autoSummitDeathCheckConn = nil
                end
            end)
        end,
    })

    MainTab:CreateSection("Send Request Carry")

    MainTab:CreateParagraph({
        Title = "How it works",
        Content = "Pick players from the list and/or type additional names (comma, semicolon, or line — same visible name as in-game / dropdown). Before each send, names are matched to players currently in the server; unmatched names are skipped. A request is only sent if your character and the target’s HumanoidRootPart are within 18 studs.\n\nCarryRemote.OnClientEvent: \"CarrierList\" keeps current carriers — those user ids are skipped; \"RequestExpired\" notifies; \"Declined\" excludes that targetId for 5 minutes.",
    })

    local SendRequestCarryCarrierListParagraph
    local sendRequestCarryUpdateCarrierListParagraph

    SendRequestCarryCarrierListParagraph = MainTab:CreateParagraph({
        Title = "Carrier list",
        Content = "(no data yet — updates when the server sends CarrierList)",
    })

    local sendRequestCarrySelected = {}
    local sendRequestCarryAdditionalPlayersText = ""
    local SendRequestCarryPlayersDropdown
    local sendRequestCarryAutoLoopToken = 0

    local SEND_REQUEST_CARRY_DELAY_PER_TARGET = 4
    local SEND_REQUEST_CARRY_CYCLE_GAP = 6
    local SEND_REQUEST_CARRY_MAX_DISTANCE_STUDS = 18
    local SEND_REQUEST_CARRY_DECLINED_COOLDOWN_SEC = 5 * 60
    local sendRequestCarryDeclinedUntilByUserId = {}
    local sendRequestCarryCarrierListIds = {}
    local sendRequestCarryCarrierListEntries = {}

    local function sendRequestCarryApplyCarrierList(data)
        local newSet = {}
        local entries = {}
        if type(data) == "table" then
            local list = data.list
            if type(list) == "table" then
                for _, entry in ipairs(list) do
                    if type(entry) == "table" then
                        local eid = entry.id
                        if typeof(eid) ~= "number" then
                            eid = tonumber(tostring(eid))
                        end
                        local ename = entry.name
                        if typeof(ename) ~= "string" then
                            ename = ename ~= nil and tostring(ename) or ""
                        end
                        if eid and eid > 0 then
                            newSet[eid] = true
                            local ufrom = entry.username
                            if typeof(ufrom) ~= "string" or ufrom == "" then
                                ufrom = entry.userName
                            end
                            if typeof(ufrom) ~= "string" then
                                ufrom = nil
                            elseif ufrom == "" then
                                ufrom = nil
                            end
                            table.insert(entries, {
                                name = ename,
                                id = eid,
                                username = ufrom,
                            })
                        end
                    end
                end
            end
        end
        sendRequestCarryCarrierListIds = newSet
        sendRequestCarryCarrierListEntries = entries
        if sendRequestCarryUpdateCarrierListParagraph then
            sendRequestCarryUpdateCarrierListParagraph()
        end
    end

    sendRequestCarryUpdateCarrierListParagraph = function()
        if not SendRequestCarryCarrierListParagraph then
            return
        end
        local content
        if #sendRequestCarryCarrierListEntries == 0 then
            content = "(empty)"
        else
            local lines = {}
            for _, e in ipairs(sendRequestCarryCarrierListEntries) do
                local nm = e.name
                if not nm or nm == "" then
                    nm = "?"
                end
                local usernameStr = e.username
                local plr = Players:GetPlayerByUserId(e.id)
                if plr then
                    usernameStr = plr.Name
                elseif typeof(usernameStr) ~= "string" or usernameStr == "" then
                    usernameStr = nil
                end
                local line = "• " .. nm
                if usernameStr then
                    line = line .. "  [" .. usernameStr .. "]"
                end
                line = line .. "  [" .. tostring(e.id) .. "]"
                table.insert(lines, line)
            end
            content = table.concat(lines, "\n")
        end
        if SendRequestCarryCarrierListParagraph.Set then
            SendRequestCarryCarrierListParagraph:Set({
                Title = "Carrier list",
                Content = content,
            })
        end
    end

    local function sendRequestCarryIsOnCarrierList(userId)
        if typeof(userId) ~= "number" then
            userId = tonumber(tostring(userId))
        end
        if not userId then
            return false
        end
        return sendRequestCarryCarrierListIds[userId] == true
    end

    local function sendRequestCarryIsDeclinedCooldownActive(userId)
        if typeof(userId) ~= "number" then
            userId = tonumber(tostring(userId))
        end
        if not userId then
            return false
        end
        local untilT = sendRequestCarryDeclinedUntilByUserId[userId]
        if not untilT then
            return false
        end
        if tick() >= untilT then
            sendRequestCarryDeclinedUntilByUserId[userId] = nil
            return false
        end
        return true
    end

    local function sendRequestCarryMarkDeclined(userId)
        if typeof(userId) ~= "number" then
            userId = tonumber(tostring(userId))
        end
        if not userId then
            return
        end
        sendRequestCarryDeclinedUntilByUserId[userId] = tick() + SEND_REQUEST_CARRY_DECLINED_COOLDOWN_SEC
    end

    local function sendRequestCarryGetRootPart(character)
        if not character then
            return nil
        end
        local r = character:FindFirstChild("HumanoidRootPart")
        if r and r:IsA("BasePart") then
            return r
        end
        local pp = character.PrimaryPart
        if pp and pp:IsA("BasePart") then
            return pp
        end
        return nil
    end

    local function sendRequestCarryIsTargetWithinRange(targetUserId, maxDist)
        if typeof(targetUserId) ~= "number" then
            targetUserId = tonumber(tostring(targetUserId))
        end
        if not targetUserId then
            return false
        end
        local lp = lpAutoSummit
        local myRoot = sendRequestCarryGetRootPart(lp.Character)
        if not myRoot then
            return false
        end
        local tgtPlr = Players:GetPlayerByUserId(targetUserId)
        if not tgtPlr or tgtPlr == lp then
            return false
        end
        local tRoot = sendRequestCarryGetRootPart(tgtPlr.Character)
        if not tRoot then
            return false
        end
        return (myRoot.Position - tRoot.Position).Magnitude <= maxDist
    end

    local function sendRequestCarryOtherPlayerLabel(player)
        if not player then
            return ""
        end
        local dn = player.DisplayName
        if dn and dn ~= "" then
            return dn
        end
        return player.Name
    end

    local function sendRequestCarryDropdownOptions()
        local opts = {}
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.ClassName == "Player" then
                table.insert(opts, sendRequestCarryOtherPlayerLabel(plr))
            end
        end
        table.sort(opts, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return opts
    end

    local function sendRequestCarryFindPlayerByLabel(label)
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and sendRequestCarryOtherPlayerLabel(plr) == label then
                return plr
            end
        end
        return nil
    end

    local function sendRequestCarryTrim(s)
        if typeof(s) ~= "string" then
            return ""
        end
        return (s:gsub("^%s+", ""):gsub("%s+$", ""))
    end

    local function sendRequestCarryFindOtherPlayerByVisibleName(nameQuery)
        local q = sendRequestCarryTrim(nameQuery)
        if q == "" then
            return nil
        end
        local lowerQ = string.lower(q)
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.ClassName == "Player" then
                local label = sendRequestCarryOtherPlayerLabel(plr)
                if label == q or string.lower(label) == lowerQ then
                    return plr
                end
            end
        end
        return nil
    end

    local function sendRequestCarryResolveAdditionalPlayersToUserIds(str)
        local out = {}
        local seen = {}
        if typeof(str) ~= "string" or str == "" then
            return out
        end
        for segment in string.gmatch(str, "([^,;\n]+)") do
            local plr = sendRequestCarryFindOtherPlayerByVisibleName(segment)
            if plr then
                local uid = plr.UserId
                if typeof(uid) == "number" and uid > 0 and not seen[uid] then
                    seen[uid] = true
                    table.insert(out, uid)
                end
            end
        end
        return out
    end

    local function sendRequestCarryCollectTargetIds()
        local ids = {}
        local seen = {}
        local function addId(id)
            if typeof(id) == "number" and id > 0 and not seen[id] then
                seen[id] = true
                table.insert(ids, id)
            end
        end
        for _, label in ipairs(sendRequestCarrySelected) do
            local plr = sendRequestCarryFindPlayerByLabel(label)
            if plr then
                addId(plr.UserId)
            end
        end
        for _, n in ipairs(sendRequestCarryResolveAdditionalPlayersToUserIds(sendRequestCarryAdditionalPlayersText)) do
            addId(n)
        end
        local filtered = {}
        for _, id in ipairs(ids) do
            if not sendRequestCarryIsDeclinedCooldownActive(id) and not sendRequestCarryIsOnCarrierList(id) then
                table.insert(filtered, id)
            end
        end
        return filtered
    end

    local function sendRequestCarryPurgeStaleSelections()
        local opts = sendRequestCarryDropdownOptions()
        local valid = {}
        for _, sel in ipairs(sendRequestCarrySelected) do
            if table.find(opts, sel) then
                table.insert(valid, sel)
            end
        end
        local removed = #valid ~= #sendRequestCarrySelected
        sendRequestCarrySelected = valid
        if removed and SendRequestCarryPlayersDropdown and SendRequestCarryPlayersDropdown.Set then
            SendRequestCarryPlayersDropdown:Set(valid)
        end
    end

    local function sendRequestCarryRefreshList()
        local opts = sendRequestCarryDropdownOptions()
        if SendRequestCarryPlayersDropdown and SendRequestCarryPlayersDropdown.Refresh then
            SendRequestCarryPlayersDropdown:Refresh(opts)
        end
        sendRequestCarryPurgeStaleSelections()
    end

    SendRequestCarryPlayersDropdown = MainTab:CreateDropdown({
        Name = "Players (multi-select)",
        Options = sendRequestCarryDropdownOptions(),
        CurrentOption = {},
        MultipleOptions = true,
        Search = true,
        Ext = true,
        Callback = function(selected)
            if type(selected) == "table" then
                sendRequestCarrySelected = selected
            elseif selected then
                sendRequestCarrySelected = { selected }
            else
                sendRequestCarrySelected = {}
            end
        end,
    })

    MainTab:CreateInput({
        Name = "Additional players",
        PlaceholderText = "Display names, e.g. kyazuramoe, FriendName",
        CurrentValue = "",
        Ext = true,
        Callback = function(value)
            sendRequestCarryAdditionalPlayersText = value or ""
        end,
    })

    local SendRequestCarryAutoToggle
    SendRequestCarryAutoToggle = MainTab:CreateToggle({
        Name = "Auto Send Request",
        CurrentValue = false,
        Ext = true,
        Callback = function(enabled)
            sendRequestCarryAutoLoopToken = sendRequestCarryAutoLoopToken + 1
            if not enabled then
                return
            end

            local ok, carryRemote = pcall(function()
                return ReplicatedStorage:WaitForChild("CarryRemote", 10)
            end)
            if not ok or not carryRemote then
                mountNotify({
                    Title = "Send Request Carry",
                    Content = "CarryRemote not found in ReplicatedStorage",
                    Icon = "x",
                })
                if SendRequestCarryAutoToggle and SendRequestCarryAutoToggle.Set then
                    SendRequestCarryAutoToggle:Set(false)
                end
                return
            end

            local loopId = sendRequestCarryAutoLoopToken
            local warnedNoTargets = false

            task.spawn(function()
                while loopId == sendRequestCarryAutoLoopToken do
                    local targets = sendRequestCarryCollectTargetIds()
                    if #targets == 0 then
                        if not warnedNoTargets then
                            warnedNoTargets = true
                            mountNotify({
                                Title = "Send Request Carry",
                                Content = "No targets — select players and/or add names that match someone in the server",
                                Icon = "x",
                            })
                        end
                        task.wait(5)
                    else
                        warnedNoTargets = false
                        for _, targetId in ipairs(targets) do
                            if loopId ~= sendRequestCarryAutoLoopToken then
                                break
                            end
                            if sendRequestCarryIsTargetWithinRange(targetId, SEND_REQUEST_CARRY_MAX_DISTANCE_STUDS) then
                                pcall(function()
                                    carryRemote:FireServer("Request", {
                                        targetId = targetId,
                                    })
                                end)
                                task.wait(SEND_REQUEST_CARRY_DELAY_PER_TARGET)
                            end
                        end
                        task.wait(SEND_REQUEST_CARRY_CYCLE_GAP)
                    end
                end
            end)

            mountNotify({
                Title = "Send Request Carry",
                Content = "Auto send started",
                Icon = "check",
            })
        end,
    })

    Players.PlayerAdded:Connect(function()
        task.defer(sendRequestCarryRefreshList)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(sendRequestCarryRefreshList)
    end)
    task.defer(sendRequestCarryRefreshList)

    task.defer(function()
        local ok, carryRemote = pcall(function()
            return ReplicatedStorage:WaitForChild("CarryRemote", 60)
        end)
        if not ok or not carryRemote then
            return
        end
        carryRemote.OnClientEvent:Connect(function(kind, data)
            if type(data) ~= "table" then
                return
            end
            local tid = data.targetId
            if typeof(tid) ~= "number" then
                tid = tonumber(tostring(tid))
            end
            if kind == "RequestExpired" then
                mountNotify({
                    Title = "Carry request",
                    Content = "RequestExpired for targetId " .. tostring(tid),
                    Icon = "x",
                })
            elseif kind == "Declined" and tid then
                sendRequestCarryMarkDeclined(tid)
                mountNotify({
                    Title = "Carry request",
                    Content = "Declined — targetId "
                        .. tostring(tid)
                        .. " excluded from auto-send for "
                        .. tostring(SEND_REQUEST_CARRY_DECLINED_COOLDOWN_SEC / 60)
                        .. " min",
                    Icon = "x",
                })
            elseif kind == "CarrierList" then
                sendRequestCarryApplyCarrierList(data)
            end
        end)
    end)

    MainTab:CreateSection("Accept Incoming Carry")

    MainTab:CreateParagraph({
        Title = "How it works",
        Content = "If you select specific players below, only carry requests from those players are accepted. If nothing is selected, requests from everyone are accepted.\n\nUse the toggle to listen on ReplicatedStorage.CarryRemote for the \"Prompt\" action and reply with \"Response\" (accept = true).",
    })

    local acceptIncomingCarrySelected = {}
    local AcceptIncomingCarryPlayersDropdown
    local acceptIncomingCarryRemoteConn = nil

    local function acceptIncomingCarryOtherPlayerLabel(player)
        if not player then
            return ""
        end
        local dn = player.DisplayName
        if dn and dn ~= "" then
            return dn
        end
        return player.Name
    end

    local function acceptIncomingCarryDropdownOptions()
        local opts = {}
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and plr.ClassName == "Player" then
                table.insert(opts, acceptIncomingCarryOtherPlayerLabel(plr))
            end
        end
        table.sort(opts, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return opts
    end

    local function acceptIncomingCarryFindPlayerByLabel(label)
        local lp = lpAutoSummit
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= lp and acceptIncomingCarryOtherPlayerLabel(plr) == label then
                return plr
            end
        end
        return nil
    end

    local function acceptIncomingCarryFromNameMatchesOption(fromName, optionLabel)
        if fromName == optionLabel then
            return true
        end
        local plr = acceptIncomingCarryFindPlayerByLabel(optionLabel)
        if plr then
            if fromName == plr.Name or (plr.DisplayName and fromName == plr.DisplayName) then
                return true
            end
        end
        return false
    end

    local function acceptIncomingCarryShouldAccept(fromName)
        if not acceptIncomingCarrySelected or #acceptIncomingCarrySelected == 0 then
            return true
        end
        for _, opt in ipairs(acceptIncomingCarrySelected) do
            if acceptIncomingCarryFromNameMatchesOption(fromName, opt) then
                return true
            end
        end
        return false
    end

    local function acceptIncomingCarryPurgeStaleSelections()
        local opts = acceptIncomingCarryDropdownOptions()
        local valid = {}
        for _, sel in ipairs(acceptIncomingCarrySelected) do
            if table.find(opts, sel) then
                table.insert(valid, sel)
            end
        end
        local removed = #valid ~= #acceptIncomingCarrySelected
        acceptIncomingCarrySelected = valid
        if removed and AcceptIncomingCarryPlayersDropdown and AcceptIncomingCarryPlayersDropdown.Set then
            AcceptIncomingCarryPlayersDropdown:Set(valid)
        end
    end

    local function acceptIncomingCarryRefreshList()
        local opts = acceptIncomingCarryDropdownOptions()
        if AcceptIncomingCarryPlayersDropdown and AcceptIncomingCarryPlayersDropdown.Refresh then
            AcceptIncomingCarryPlayersDropdown:Refresh(opts)
        end
        acceptIncomingCarryPurgeStaleSelections()
    end

    AcceptIncomingCarryPlayersDropdown = MainTab:CreateDropdown({
        Name = "Other players (display name)",
        Options = acceptIncomingCarryDropdownOptions(),
        CurrentOption = {},
        MultipleOptions = true,
        Search = true,
        Ext = true,
        Callback = function(selected)
            if type(selected) == "table" then
                acceptIncomingCarrySelected = selected
            elseif selected then
                acceptIncomingCarrySelected = { selected }
            else
                acceptIncomingCarrySelected = {}
            end
        end,
    })

    local AcceptIncomingCarryListenToggle
    AcceptIncomingCarryListenToggle = MainTab:CreateToggle({
        Name = "Listen for \"Prompt\" (auto-accept incoming carry)",
        CurrentValue = false,
        Ext = true,
        Callback = function(enabled)
            if acceptIncomingCarryRemoteConn then
                acceptIncomingCarryRemoteConn:Disconnect()
                acceptIncomingCarryRemoteConn = nil
            end
            if not enabled then
                return
            end
            local ok, carryRemote = pcall(function()
                return ReplicatedStorage:WaitForChild("CarryRemote", 10)
            end)
            if not ok or not carryRemote then
                mountNotify({
                    Title = "Accept Incoming Carry",
                    Content = "CarryRemote not found in ReplicatedStorage",
                    Icon = "x",
                })
                if AcceptIncomingCarryListenToggle and AcceptIncomingCarryListenToggle.Set then
                    AcceptIncomingCarryListenToggle:Set(false)
                end
                return
            end
            acceptIncomingCarryRemoteConn = carryRemote.OnClientEvent:Connect(function(kind, data)
                if kind ~= "Prompt" or type(data) ~= "table" then
                    return
                end
                local fromName = data.fromName
                local fromId = data.fromId
                if fromName == nil or fromId == nil then
                    return
                end
                fromName = tostring(fromName)
                if typeof(fromId) ~= "number" then
                    fromId = tonumber(tostring(fromId))
                end
                if not fromId then
                    return
                end
                if not acceptIncomingCarryShouldAccept(fromName) then
                    return
                end
                pcall(function()
                    carryRemote:FireServer("Response", {
                        requesterId = fromId,
                        accept = true,
                    })
                end)
            end)
            mountNotify({
                Title = "Accept Incoming Carry",
                Content = "Listening for carry prompts",
                Icon = "check",
            })
        end,
    })

    Players.PlayerAdded:Connect(function()
        task.defer(acceptIncomingCarryRefreshList)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(acceptIncomingCarryRefreshList)
    end)
    task.defer(acceptIncomingCarryRefreshList)

    MainTab:CreateSection("Transfer Cash")

    local transferCashAmountText = ""
    local transferCashSelectedPlayer: Player? = nil
    local TransferCashPlayersDropdown

    local function transferCashPlayerLabel(player: Player)
        local lp = Players.LocalPlayer
        local dn = player.DisplayName
        local base: string
        if dn and dn ~= "" and dn ~= player.Name then
            base = string.format("%s (@%s)", dn, player.Name)
        else
            base = player.Name
        end
        if player == lp then
            return base .. " (you)"
        end
        return base
    end

    local function transferCashDropdownOptions()
        local opts = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.ClassName == "Player" then
                table.insert(opts, transferCashPlayerLabel(plr))
            end
        end
        table.sort(opts, function(a, b)
            return string.lower(a) < string.lower(b)
        end)
        return opts
    end

    local function transferCashFindPlayerByLabel(label: string)
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.ClassName == "Player" and transferCashPlayerLabel(plr) == label then
                return plr
            end
        end
        return nil
    end

    local function transferCashRefreshList()
        local opts = transferCashDropdownOptions()
        if transferCashSelectedPlayer then
            if Players:GetPlayerByUserId(transferCashSelectedPlayer.UserId) ~= transferCashSelectedPlayer then
                transferCashSelectedPlayer = nil
            end
        end
        if TransferCashPlayersDropdown and TransferCashPlayersDropdown.Refresh then
            TransferCashPlayersDropdown:Refresh(opts)
        end
        if transferCashSelectedPlayer then
            local lbl = transferCashPlayerLabel(transferCashSelectedPlayer)
            if table.find(opts, lbl) and TransferCashPlayersDropdown and TransferCashPlayersDropdown.Set then
                TransferCashPlayersDropdown:Set({ lbl })
            end
        end
    end

    local transferCashInitialOpts = transferCashDropdownOptions()
    local transferCashInitialCurrent = {}
    if #transferCashInitialOpts > 0 then
        transferCashInitialCurrent = { transferCashInitialOpts[1] }
        transferCashSelectedPlayer = transferCashFindPlayerByLabel(transferCashInitialOpts[1])
    end

    TransferCashPlayersDropdown = MainTab:CreateDropdown({
        Name = "Player",
        Options = transferCashInitialOpts,
        CurrentOption = transferCashInitialCurrent,
        Search = true,
        Ext = true,
        Callback = function(value)
            local picked = rayfieldDropdownFirst(value)
            transferCashSelectedPlayer = picked and transferCashFindPlayerByLabel(picked) or nil
        end,
    })

    MainTab:CreateInput({
        Name = "Amount",
        PlaceholderText = "e.g. 100",
        CurrentValue = "",
        Ext = true,
        Callback = function(value)
            transferCashAmountText = value or ""
        end,
    })

    MainTab:CreateButton({
        Name = "Give Cash",
        Ext = true,
        Callback = function()
            if not transferCashSelectedPlayer then
                mountNotify({ Title = "Transfer Cash", Content = "Select a player first", Icon = "x" })
                return
            end
            local amtStr = (transferCashAmountText or ""):gsub(",", ""):gsub("%s+", "")
            local amountNum = tonumber(amtStr)
            local amountPayload
            if amountNum ~= nil then
                amountPayload = amountNum
            else
                amountPayload = amtStr
            end
            local targetId = transferCashSelectedPlayer.UserId
            local okFire, errFire = pcall(function()
                local tax = ReplicatedStorage:FindFirstChild("CashTransferTax")
                if not tax then
                    tax = ReplicatedStorage:WaitForChild("CashTransferTax", 5)
                end
                if tax then
                    if tax:IsA("IntValue") or tax:IsA("NumberValue") then
                        tax.Value = 0
                    elseif tax:IsA("StringValue") then
                        tax.Value = "0"
                    end
                end
                local ev = ReplicatedStorage:FindFirstChild("CashTransferRemote")
                if not ev then
                    ev = ReplicatedStorage:WaitForChild("CashTransferRemote", 10)
                end
                if not ev then
                    error("CashTransferRemote not found in ReplicatedStorage")
                end
                ev:FireServer("RequestTransfer", {
                    targetId = targetId,
                    amount = amountPayload,
                })
            end)
            if not okFire then
                mountNotify({
                    Title = "Transfer Cash",
                    Content = tostring(errFire),
                    Icon = "x",
                })
            end
        end,
    })

    task.defer(function()
        local ok, ackRemote = pcall(function()
            return ReplicatedStorage:WaitForChild("CashTransferAck", 60)
        end)
        if not ok or not ackRemote or not ackRemote:IsA("RemoteEvent") then
            return
        end
        ackRemote.OnClientEvent:Connect(function(data)
            local msg: string?
            local okFlag: boolean?
            if type(data) == "table" then
                local m = data.message
                msg = typeof(m) == "string" and m or nil
                okFlag = data.ok
            elseif type(data) == "string" then
                msg = data
                okFlag = true
            else
                return
            end
            if not msg or msg == "" then
                msg = okFlag == false and "Transfer failed." or "Transfer acknowledged."
            end
            mountNotify({
                Title = "Transfer Cash",
                Content = msg,
                Icon = okFlag == false and "x" or "check",
            })
        end)
    end)

    Players.PlayerAdded:Connect(function()
        task.defer(transferCashRefreshList)
    end)
    Players.PlayerRemoving:Connect(function()
        task.defer(transferCashRefreshList)
    end)
    task.defer(transferCashRefreshList)

    -- AdminMiniBtn (PlayerGui): game's LocalScript only sets Container.Visible for whitelisted UserIds;
    -- HehAdmin_RequestOpen fires from Btn click when allowed. This toggle forces Container visibility.
    -- HehAdminUI (PlayerGui): game's client sets Root.Visible = true when ReplicatedStorage.HehAdmin_Open
    -- fires; same Root is hidden with Escape. This toggle mirrors that visibility.
    MainTab:CreateSection("Admin mini (HehAdmin)")

    local adminMiniBtnShow = false
    local function applyAdminMiniBtnVisibility()
        local lp = Players.LocalPlayer
        local pg = lp:FindFirstChild("PlayerGui")
        if not pg then
            return
        end
        local miniGui = pg:FindFirstChild("AdminMiniBtn")
        if miniGui then
            local container = miniGui:FindFirstChild("Container")
            if container then
                container.Visible = adminMiniBtnShow
            end
        end
        local hehGui = pg:FindFirstChild("HehAdminUI")
        if hehGui then
            local root = hehGui:FindFirstChild("Root")
            if root then
                root.Visible = adminMiniBtnShow
            end
        end
    end

    MainTab:CreateToggle({
        Name = "Show AdminMiniBtn + HehAdmin UI",
        CurrentValue = false,
        Ext = true,
        Callback = function(enabled)
            adminMiniBtnShow = enabled
            applyAdminMiniBtnVisibility()
            if enabled then
                for _ = 1, 30 do
                    task.wait(0.2)
                    applyAdminMiniBtnVisibility()
                    local pg = Players.LocalPlayer:FindFirstChild("PlayerGui")
                    local g = pg and pg:FindFirstChild("AdminMiniBtn")
                    local c = g and g:FindFirstChild("Container")
                    if c then
                        break
                    end
                end
            end
        end,
    })

    MainTab:CreateSection("HehAdmin remotes")

    local HehAdminRemotesParagraph = MainTab:CreateParagraph({
        Title = "Discovered",
        Content = "Scanning ReplicatedStorage for HehAdmin_* RemoteEvents…",
    })

    local function hehAdminCollectRemoteEvents()
        local list = {}
        for _, ch in ipairs(ReplicatedStorage:GetChildren()) do
            if ch:IsA("RemoteEvent") and string.sub(ch.Name, 1, 9) == "HehAdmin_" then
                table.insert(list, ch)
            end
        end
        table.sort(list, function(a, b)
            return a.Name < b.Name
        end)
        return list
    end

    local function hehAdminNotifyFireResult(remoteName, ok, err)
        if ok then
            mountNotify({
                Title = "HehAdmin",
                Content = remoteName .. ":FireServer() sent",
                Icon = "check",
            })
        else
            mountNotify({ Title = "HehAdmin", Content = remoteName .. ": " .. tostring(err), Icon = "x" })
        end
    end

    task.defer(function()
        local deadline = tick() + 12
        local remotes = {}
        repeat
            remotes = hehAdminCollectRemoteEvents()
            if #remotes > 0 then
                break
            end
            task.wait(0.25)
        until tick() >= deadline

        local lines = {}
        for _, ev in ipairs(remotes) do
            table.insert(lines, ev.Name .. " (" .. ev.ClassName .. ")")
        end
        if #lines == 0 then
            HehAdminRemotesParagraph:Set({
                Title = "Discovered",
                Content = "No HehAdmin_* RemoteEvents found under ReplicatedStorage (try rejoin or wait for replication).",
            })
            return
        end
        HehAdminRemotesParagraph:Set({
            Title = "Discovered",
            Content = table.concat(lines, "\n")
                .. "\n\nHehAdmin_Open is normally fired by the server to your client (show UI). "
                .. "FireServer below is experimental and may be ignored.",
        })

        for _, ev in ipairs(remotes) do
            if ev.Name ~= "HehAdmin_Do" then
                MainTab:CreateButton({
                    Name = "FireServer: " .. ev.Name,
                    Ext = true,
                    Callback = function()
                        local ok, err = pcall(function()
                            ev:FireServer()
                        end)
                        hehAdminNotifyFireResult(ev.Name, ok, err)
                    end,
                })
            end
        end
    end)

    MainTab:CreateSection("HehAdmin_Do (payload)")

    local hehDoAction = "reset"
    local hehDoField = "summit"
    local hehDoUsername = ""
    local hehDoValue = ""

    MainTab:CreateDropdown({
        Name = "Action",
        Options = { "reset", "set", "custom" },
        CurrentOption = hehDoAction,
        Ext = true,
        Callback = function(value)
            hehDoAction = rayfieldDropdownFirst(value) or "reset"
        end,
    })

    MainTab:CreateDropdown({
        Name = "Field",
        Options = { "summit", "besttime", "cash" },
        CurrentOption = hehDoField,
        Ext = true,
        Callback = function(value)
            hehDoField = rayfieldDropdownFirst(value) or "summit"
        end,
    })

    MainTab:CreateInput({
        Name = "Username",
        PlaceholderText = "Roblox username, or all (custom)",
        CurrentValue = "",
        Ext = true,
        Callback = function(value)
            hehDoUsername = value or ""
        end,
    })

    MainTab:CreateInput({
        Name = "Value",
        PlaceholderText = "set/custom only (summit / besttime / cash text)",
        CurrentValue = "",
        Ext = true,
        Callback = function(value)
            hehDoValue = value or ""
        end,
    })

    MainTab:CreateButton({
        Name = "HehAdmin_Do: FireServer (payload)",
        Ext = true,
        Callback = function()
            local user = (hehDoUsername or ""):gsub("^%s+", ""):gsub("%s+$", "")
            local val = (hehDoValue or ""):gsub("^%s+", ""):gsub("%s+$", "")
            if user == "" then
                mountNotify({ Title = "HehAdmin_Do", Content = "Enter a username", Icon = "x" })
                return
            end
            local payload
            if hehDoAction == "reset" then
                payload = {
                    scope = "global",
                    action = "reset",
                    field = hehDoField,
                    username = user,
                }
            elseif hehDoAction == "set" then
                if val == "" then
                    mountNotify({ Title = "HehAdmin_Do", Content = "set requires a value", Icon = "x" })
                    return
                end
                payload = {
                    scope = "global",
                    action = "set",
                    field = hehDoField,
                    username = user,
                    value = val,
                }
            elseif hehDoAction == "custom" then
                if val == "" then
                    mountNotify({ Title = "HehAdmin_Do", Content = "custom requires a value", Icon = "x" })
                    return
                end
                payload = {
                    scope = "local",
                    action = "custom",
                    field = hehDoField,
                    username = user,
                    value = val,
                }
            else
                mountNotify({ Title = "HehAdmin_Do", Content = "Unknown action", Icon = "x" })
                return
            end
            local ok, err = pcall(function()
                local ev = ReplicatedStorage:FindFirstChild("HehAdmin_Do")
                if not ev then
                    ev = ReplicatedStorage:WaitForChild("HehAdmin_Do", 10)
                end
                if not ev then
                    error("HehAdmin_Do not found")
                end
                ev:FireServer(payload)
            end)
            if ok then
                local enc
                local okEnc, jsonStr = pcall(function()
                    return HttpService:JSONEncode(payload)
                end)
                enc = okEnc and jsonStr or "(encode failed)"
                mountNotify({
                    Title = "HehAdmin_Do",
                    Content = "Sent: " .. enc,
                    Icon = "check",
                })
            else
                mountNotify({ Title = "HehAdmin_Do", Content = tostring(err), Icon = "x" })
            end
        end,
    })

    do
        local lpGui = Players.LocalPlayer
        local pg = lpGui:FindFirstChild("PlayerGui") or lpGui:WaitForChild("PlayerGui", 30)
        if pg then
            pg.ChildAdded:Connect(function(ch)
                if ch.Name == "AdminMiniBtn" or ch.Name == "HehAdminUI" then
                    task.defer(applyAdminMiniBtnVisibility)
                end
            end)
        end
        task.defer(applyAdminMiniBtnVisibility)
    end
end
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
        CurrentValue = teleportInputValue,
        Ext = true,
        Callback = function(value)
            teleportInputValue = value
        end,
    })

    local TeleportLookInput = TeleportTab:CreateInput({
        Name = "Look direction",
        PlaceholderText = "e.g. 0, 0, -1 or leave empty for position only",
        CurrentValue = teleportLookInputValue,
        Ext = true,
        Callback = function(value)
            teleportLookInputValue = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Get Current Location",
        Ext = true,
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
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
                Content = "Position: " .. text .. " Â· Look: " .. lookText,
                Icon = "check",
            })
        end,
    })

    TeleportTab:CreateButton({
        Name = "Teleport",
        Ext = true,
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local cf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not cf then
                mountNotify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                    Icon = "x",
                })
                return
            end
            rootPart.CFrame = cf
            local p = cf.Position
            mountNotify({
                Title = "Teleport",
                Content = string.format("Teleported to %.1f, %.1f, %.1f", p.X, p.Y, p.Z),
                Icon = "check",
            })
        end,
    })

    local tweenDurationValue = "5"
    TeleportTab:CreateInput({
        Name = "Tween Duration",
        PlaceholderText = "e.g. 5",
        CurrentValue = tweenDurationValue,
        Ext = true,
        Callback = function(value)
            tweenDurationValue = value
        end,
    })

    TeleportTab:CreateButton({
        Name = "Tween to Location",
        Ext = true,
        Callback = function()
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local targetCf = teleportCFrameFromInputs(teleportInputValue, teleportLookInputValue)
            if not targetCf then
                mountNotify({
                    Title = "Teleport",
                    Content = "Enter position as X, Y, Z (e.g. 100, 5, 200)",
                    Icon = "x",
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
                Icon = "check",
            })
        end,
    })

    TeleportTab:CreateSection("Teleport to camp")

    local function teleportToCampCoords(x, y, z, placeName)
        local character = Players.LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            mountNotify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
            return
        end
        rootPart.CFrame = CFrame.new(x, y, z)
        mountNotify({
            Title = "Teleport",
            Content = "Teleported to " .. placeName,
            Icon = "check",
        })
    end

    local campLocations = {
        { label = "Camp 1", x = -407.77, y = 248.20, z = 794.09 },
        { label = "Camp 2", x = -337.77, y = 388.27, z = 522.16 },
        { label = "Camp 3", x = 294.19, y = 430.33, z = 494.17 },
        { label = "Camp 4", x = 323.46, y = 490.24, z = 348.33 },
        { label = "Camp 5", x = 226.70, y = 314.21, z = -143.64 },
        { label = "Summit", x = -613.51, y = 905.28, z = -533.45 },
    }

    for _, loc in ipairs(campLocations) do
        local label, cx, cy, cz = loc.label, loc.x, loc.y, loc.z
        TeleportTab:CreateButton({
            Name = label,
            Ext = true,
            Callback = function()
                teleportToCampCoords(cx, cy, cz, label)
            end,
        })
    end

    -- */  Teleport to Players  /* --
    TeleportTab:CreateSection("Teleport to Players")

    local TELEPORT_PLAYER_NONE = "(None)"
    local playerDisplayNames = {}
    local playerList = {}
    local selectedTeleportPlayer = nil
    local PlayerTeleportDropdown

    local function teleportPlayerDropdownOptions()
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
                if PlayerTeleportDropdown and PlayerTeleportDropdown.Set then
                    PlayerTeleportDropdown:Set(TELEPORT_PLAYER_NONE)
                end
            end
        end
        if showNotify then
            mountNotify({ Title = "Teleport", Content = "Player list refreshed (" .. #playerList .. " players)", Icon = "check" })
        end
    end

    PlayerTeleportDropdown = TeleportTab:CreateDropdown({
        Name = "Player",
        Search = true,
        Options = teleportPlayerDropdownOptions(),
        CurrentOption = { TELEPORT_PLAYER_NONE },
        Ext = true,
        Callback = function(opts)
            local value = type(opts) == "table" and opts[1] or opts
            selectedTeleportPlayer = nil
            if value and value ~= TELEPORT_PLAYER_NONE then
                local idx = table.find(playerDisplayNames, value)
                if idx and playerList[idx] then
                    selectedTeleportPlayer = playerList[idx]
                end
            end
        end,
    })

    TeleportTab:CreateButton({
        Name = "Refresh",
        Ext = true,
        Callback = function()
            refreshPlayerList(true)
        end,
    })

    TeleportTab:CreateButton({
        Name = "Teleport",
        Ext = true,
        Callback = function()
            if not selectedTeleportPlayer then
                mountNotify({ Title = "Teleport", Content = "Select a player first", Icon = "x" })
                return
            end
            local character = Players.LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            if not rootPart then
                mountNotify({ Title = "Teleport", Content = "Character not loaded", Icon = "x" })
                return
            end
            local targetChar = selectedTeleportPlayer.Character
            local targetRoot = targetChar and targetChar:FindFirstChild("HumanoidRootPart")
            if not targetRoot then
                mountNotify({ Title = "Teleport", Content = "Target player has no character", Icon = "x" })
                return
            end
            rootPart.CFrame = CFrame.new(targetRoot.Position + Vector3.new(0, 0, 3))
            mountNotify({ Title = "Teleport", Content = "Teleported to " .. (selectedTeleportPlayer.DisplayName or selectedTeleportPlayer.Name), Icon = "check" })
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
            if p and p.Destroy then
                pcall(function()
                    p:Destroy()
                end)
            end
            refs[i] = nil
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
    ObjectsTab:CreateSection("ReplicatedStorage")
    local ReplicatedStorageDropdown
    local ReplicatedStorageChildrenParagraph
    local rsChildrenOverflowParagraphs = {}

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

    ObjectsTab:CreateSection("Players")
    local PlayersServiceDropdown
    local PlayersServiceChildrenParagraph
    local plrsChildrenOverflowParagraphs = {}

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

    ObjectsTab:CreateSection("Local Player")
    local LocalPlayerDropdown
    local LocalPlayerChildrenParagraph
    local lpChildrenOverflowParagraphs = {}

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

    ObjectsTab:CreateSection("Workspace")
    local WorkspaceDropdown
    local WorkspaceChildrenParagraph
    local wsChildrenOverflowParagraphs = {}

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

end

createRecordingTab(Window, mountNotify)
