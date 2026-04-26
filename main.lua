-- OrionLibを読み込む（複数のURLから試行）
local OrionLib = nil
local urls = {
    "https://raw.githubusercontent.com/shlexware/Orion/main/source",
    "https://raw.githubusercontent.com/OrionHub/Orion/main/source",
    "https://raw.githubusercontent.com/jadpy/suki/refs/heads/main/orion"
}

for _, url in pairs(urls) do
    if not OrionLib then
        local success, result = pcall(function()
            return loadstring(game:HttpGet(url))()
        end)
        if success and result then
            OrionLib = result
        end
    end
end

if not OrionLib then
    -- OrionLib読み込み失敗時の通知
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "ANAN HUB",
        Text = "OrionLibの読み込みに失敗しました",
        Duration = 5
    })
    return
end

-- ============================================
-- ANAN HUB 設定
-- ============================================
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- 変数
_G.NoSelfDamage = true
_G.InfiniteJump = false
_G.AutoBlast = false
_G.GravityField = false
_G.RepulsionField = false
_G.BlowPower = 500

-- 自分だけダメージ無効
local function setupNoDamage(char)
    local hum = char:WaitForChild("Humanoid")
    local lastHealth = hum.Health
    hum.HealthChanged:Connect(function()
        if hum.Health < lastHealth and _G.NoSelfDamage then
            hum.Health = lastHealth
        end
        lastHealth = hum.Health
    end)
end

if LocalPlayer.Character then
    setupNoDamage(LocalPlayer.Character)
end
LocalPlayer.CharacterAdded:Connect(setupNoDamage)

-- 無限ジャンプ
UserInputService.JumpRequest:Connect(function()
    if _G.InfiniteJump and LocalPlayer.Character then
        LocalPlayer.Character.Humanoid:ChangeState("Jumping")
    end
end)

-- ============================================
-- UI作成
-- ============================================
local Window = OrionLib:MakeWindow({
    Name = "🔥 ANAN HUB - BLOW EVERYTHING 🔥",
    HidePremium = true,
    SaveConfig = false,
    ConfigFolder = "AnanHub",
    IntroEnabled = false
})

-- ============================================
-- MAINタブ
-- ============================================
local MainTab = Window:MakeTab({
    Name = "🔥 MAIN",
    Icon = "rbxassetid://4483345998"
})

MainTab:AddSection({Name = "一撃吹き飛ばし"})

MainTab:AddButton({
    Name = "💥 メガトンパンチ（全員大吹き飛ばし）",
    Callback = function()
        if not LocalPlayer.Character then return end
        local exp = Instance.new("Explosion")
        exp.Position = LocalPlayer.Character.HumanoidRootPart.Position
        exp.BlastRadius = 300
        exp.BlastPressure = 2000000
        exp.Parent = Workspace
        
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dir = (hrp.Position - exp.Position).Unit
                    hrp.Velocity = dir * 800 + Vector3.new(0, 250, 0)
                end
            end
        end
        
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Parent ~= LocalPlayer.Character and not obj.Anchored then
                if (obj.Position - exp.Position).Magnitude < 200 then
                    local dir = (obj.Position - exp.Position).Unit
                    obj.Velocity = dir * 600 + Vector3.new(0, 150, 0)
                end
            end
        end
    end
})

MainTab:AddButton({
    Name = "👊 衝撃波（半径50m内吹き飛ばし）",
    Callback = function()
        if not LocalPlayer.Character then return end
        local center = LocalPlayer.Character.HumanoidRootPart.Position
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (hrp.Position - center).Magnitude < 50 then
                    local dir = (hrp.Position - center).Unit
                    hrp.Velocity = dir * 500 + Vector3.new(0, 100, 0)
                end
            end
        end
    end
})

MainTab:AddButton({
    Name = "🦶 キック（目の前のプレイヤー）",
    Callback = function()
        if not LocalPlayer.Character then return end
        local closest = nil
        local closestDist = 15
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                    if dist < closestDist then
                        closestDist = dist
                        closest = v
                    end
                end
            end
        end
        if closest and closest.Character then
            local dir = (closest.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Unit
            closest.Character.HumanoidRootPart.Velocity = dir * 400 + Vector3.new(0, 80, 0)
        end
    end
})

MainTab:AddSection({Name = "設定"})

MainTab:AddSlider({
    Name = "💪 吹き飛ばし強度",
    Min = 100,
    Max = 1000,
    Default = 500,
    Color = Color3.fromRGB(255, 100, 100),
    Increment = 10,
    Callback = function(v)
        _G.BlowPower = v
    end
})

-- ============================================
-- PLAYERタブ
-- ============================================
local PlayerTab = Window:MakeTab({
    Name = "👥 PLAYER",
    Icon = "rbxassetid://4483345998"
})

PlayerTab:AddSection({Name = "プレイヤー吹き飛ばし"})

PlayerTab:AddButton({
    Name = "💥 全プレイヤー大爆発",
    Callback = function()
        if not LocalPlayer.Character then return end
        local exp = Instance.new("Explosion")
        exp.Position = LocalPlayer.Character.HumanoidRootPart.Position
        exp.BlastRadius = 200
        exp.BlastPressure = 1000000
        exp.Parent = Workspace
        
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dir = (hrp.Position - exp.Position).Unit
                    hrp.Velocity = dir * 500 + Vector3.new(0, 150, 0)
                end
            end
        end
    end
})

-- プレイヤー選択ドロップダウン
local playerOptions = {}
for _, v in pairs(Players:GetPlayers()) do
    if v ~= LocalPlayer then
        table.insert(playerOptions, v.Name)
    end
end

PlayerTab:AddDropdown({
    Name = "🎯 プレイヤーを選択して飛ばす",
    Default = "",
    Options = playerOptions,
    Callback = function(v)
        if v ~= "" then
            for _, player in pairs(Players:GetPlayers()) do
                if player.Name == v and player.Character then
                    local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp and LocalPlayer.Character then
                        local dir = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Unit
                        hrp.Velocity = dir * _G.BlowPower + Vector3.new(0, 100, 0)
                    end
                end
            end
        end
    end
})

PlayerTab:AddButton({
    Name = "🚀 全プレイヤー打ち上げ",
    Callback = function()
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.new(0, _G.BlowPower, 0)
                end
            end
        end
    end
})

PlayerTab:AddButton({
    Name = "🌀 全プレイヤー横方向に飛ばす",
    Callback = function()
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local randomDir = Vector3.new(math.random(-1, 1), 0, math.random(-1, 1)).Unit
                    hrp.Velocity = randomDir * _G.BlowPower
                end
            end
        end
    end
})

PlayerTab:AddButton({
    Name = "👇 地面に叩きつけ",
    Callback = function()
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Velocity = Vector3.new(0, -400, 0)
                end
            end
        end
    end
})

PlayerTab:AddButton({
    Name = "💢 吹き飛ばし＋ダメージ",
    Callback = function()
        if not LocalPlayer.Character then return end
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character then
                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dir = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Unit
                    hrp.Velocity = dir * 400 + Vector3.new(0, 150, 0)
                    local hum = v.Character:FindFirstChild("Humanoid")
                    if hum then
                        hum.Health = hum.Health - 50
                    end
                end
            end
        end
    end
})

-- プレイヤーリスト更新
Players.PlayerAdded:Connect(function()
    local newOptions = {}
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            table.insert(newOptions, v.Name)
        end
    end
    PlayerTab:RefreshDropdown("プレイヤーを選択して飛ばす", newOptions)
end)

Players.PlayerRemoving:Connect(function()
    local newOptions = {}
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer then
            table.insert(newOptions, v.Name)
        end
    end
    PlayerTab:RefreshDropdown("プレイヤーを選択して飛ばす", newOptions)
end)

-- ============================================
-- OBJECTタブ
-- ============================================
local ObjectTab = Window:MakeTab({
    Name = "📦 OBJECT",
    Icon = "rbxassetid://4483345998"
})

ObjectTab:AddSection({Name = "物吹き飛ばし"})

ObjectTab:AddButton({
    Name = "📦 近くの全物を吹き飛ばし",
    Callback = function()
        if not LocalPlayer.Character then return end
        local center = LocalPlayer.Character.HumanoidRootPart.Position
        local count = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Parent ~= LocalPlayer.Character and not obj.Anchored then
                if (obj.Position - center).Magnitude < 50 then
                    local dir = (obj.Position - center).Unit
                    obj.Velocity = dir * _G.BlowPower + Vector3.new(0, 100, 0)
                    count = count + 1
                end
            end
        end
        OrionLib:MakeNotification({
            Name = "吹き飛ばし完了",
            Content = count .. "個のオブジェクトを吹き飛ばしました",
            Time = 2
        })
    end
})

ObjectTab:AddButton({
    Name = "⚠️ マップ全物吹き飛ばし",
    Callback = function()
        local count = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name ~= "Baseplate" and not obj.Anchored then
                if obj.Parent ~= LocalPlayer.Character then
                    local dir = (obj.Position - Vector3.new(0, 0, 0)).Unit
                    obj.Velocity = dir * 800 + Vector3.new(0, 200, 0)
                    count = count + 1
                    task.wait(0.01)
                end
            end
        end
        OrionLib:MakeNotification({
            Name = "大吹き飛ばし完了",
            Content = count .. "個のオブジェクトを吹き飛ばしました",
            Time = 2
        })
    end
})

ObjectTab:AddTextbox({
    Name = "🏷️ 物体名を指定",
    Default = "Part",
    Callback = function(v)
        _G.TargetObjectName = v
    end
})

ObjectTab:AddButton({
    Name = "🎯 指定した物体を飛ばす",
    Callback = function()
        local count = 0
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower() == (_G.TargetObjectName or "part"):lower() then
                local dir = Vector3.new(math.random(-1, 1), math.random(0, 1), math.random(-1, 1)).Unit
                obj.Velocity = dir * _G.BlowPower
                count = count + 1
            end
        end
        OrionLib:MakeNotification({
            Name = "物体飛ばし完了",
            Content = count .. "個の物体を飛ばしました",
            Time = 2
        })
    end
})

-- ============================================
-- FIELDタブ
-- ============================================
local FieldTab = Window:MakeTab({
    Name = "🌀 FIELD",
    Icon = "rbxassetid://4483345998"
})

FieldTab:AddSection({Name = "フィールド効果"})

FieldTab:AddToggle({
    Name = "💣 連続爆発モード",
    Default = false,
    Callback = function(v)
        _G.AutoBlast = v
        if v then
            task.spawn(function()
                while _G.AutoBlast and RunService.RenderStepped:Wait() do
                    if LocalPlayer.Character then
                        local exp = Instance.new("Explosion")
                        exp.Position = LocalPlayer.Character.HumanoidRootPart.Position
                        exp.BlastRadius = 50
                        exp.BlastPressure = 300000
                        exp.Parent = Workspace
                    end
                    task.wait(0.5)
                end
            end)
        end
    end
})

FieldTab:AddToggle({
    Name = "🕳️ 引力場（全て引き寄せる）",
    Default = false,
    Callback = function(v)
        _G.GravityField = v
        if v then
            task.spawn(function()
                while _G.GravityField and RunService.RenderStepped:Wait() do
                    if LocalPlayer.Character then
                        local center = LocalPlayer.Character.HumanoidRootPart
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and obj ~= center and not obj.Anchored then
                                if obj.Parent ~= LocalPlayer.Character then
                                    local dir = (center.Position - obj.Position).Unit
                                    obj.Velocity = dir * 150
                                end
                            end
                        end
                        for _, v in pairs(Players:GetPlayers()) do
                            if v ~= LocalPlayer and v.Character then
                                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local dir = (center.Position - hrp.Position).Unit
                                    hrp.Velocity = dir * 100
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

FieldTab:AddToggle({
    Name = "🌀 斥力場（全て弾き飛ばす）",
    Default = false,
    Callback = function(v)
        _G.RepulsionField = v
        if v then
            task.spawn(function()
                while _G.RepulsionField and RunService.RenderStepped:Wait() do
                    if LocalPlayer.Character then
                        local center = LocalPlayer.Character.HumanoidRootPart
                        for _, obj in pairs(Workspace:GetDescendants()) do
                            if obj:IsA("BasePart") and obj ~= center and not obj.Anchored then
                                if obj.Parent ~= LocalPlayer.Character then
                                    local dir = (obj.Position - center.Position).Unit
                                    obj.Velocity = dir * 250
                                end
                            end
                        end
                        for _, v in pairs(Players:GetPlayers()) do
                            if v ~= LocalPlayer and v.Character then
                                local hrp = v.Character:FindFirstChild("HumanoidRootPart")
                                if hrp then
                                    local dir = (hrp.Position - center.Position).Unit
                                    hrp.Velocity = dir * 200
                                end
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

-- ============================================
-- ANTIタブ
-- ============================================
local AntiTab = Window:MakeTab({
    Name = "🛡️ ANTI",
    Icon = "rbxassetid://4483345998"
})

AntiTab:AddSection({Name = "自分保護"})

AntiTab:AddToggle({
    Name = "🛡️ 自分だけダメージ無効",
    Default = true,
    Callback = function(v)
        _G.NoSelfDamage = v
    end
})

AntiTab:AddToggle({
    Name = "💨 自分にノックバック無効",
    Default = false,
    Callback = function(v)
        _G.NoKnockback = v
        if v then
            task.spawn(function()
                while _G.NoKnockback and RunService.RenderStepped:Wait() do
                    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        local vel = LocalPlayer.Character.HumanoidRootPart.Velocity
                        LocalPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, vel.Y, 0)
                    end
                    task.wait(0.1)
                end
            end)
        end
    end
})

AntiTab:AddToggle({
    Name = "⚡ アンチラグ",
    Default = false,
    Callback = function(v)
        if v then
            Workspace.Lighting.GlobalShadows = false
            Workspace.Lighting.FogEnd = 100
            Workspace.Lighting.Technology = Enum.Technology.Compatibility
        else
            Workspace.Lighting.GlobalShadows = true
            Workspace.Lighting.FogEnd = 1000
            Workspace.Lighting.Technology = Enum.Technology.ShadowMap
        end
    end
})

AntiTab:AddButton({
    Name = "🧹 メモリ最適化",
    Callback = function()
        collectgarbage("collect")
        OrionLib:MakeNotification({
            Name = "最適化完了",
            Content = "メモリを開放しました",
            Time = 2
        })
    end
})

-- ============================================
-- MISCタブ
-- ============================================
local MiscTab = Window:MakeTab({
    Name = "🎮 MISC",
    Icon = "rbxassetid://4483345998"
})

MiscTab:AddSection({Name = "基本設定"})

MiscTab:AddSlider({
    Name = "歩行速度",
    Min = 16,
    Max = 350,
    Default = 16,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 1,
    Callback = function(v)
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.WalkSpeed = v
        end
    end
})

MiscTab:AddSlider({
    Name = "ジャンプ力",
    Min = 50,
    Max = 500,
    Default = 50,
    Color = Color3.fromRGB(0, 255, 255),
    Increment = 1,
    Callback = function(v)
        if LocalPlayer.Character then
            LocalPlayer.Character.Humanoid.JumpPower = v
        end
    end
})

MiscTab:AddToggle({
    Name = "無限ジャンプ",
    Default = false,
    Callback = function(v)
        _G.InfiniteJump = v
    end
})

MiscTab:AddSection({Name = "テレポート"})

MiscTab:AddButton({
    Name = "🌍 スポーン地点へ",
    Callback = function()
        local spawn = Workspace:FindFirstChild("SpawnLocation")
        if spawn and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = spawn.CFrame
        end
    end
})

MiscTab:AddButton({
    Name = "💾 現在地を保存",
    Callback = function()
        if LocalPlayer.Character then
            _G.SavedPosition = LocalPlayer.Character.HumanoidRootPart.CFrame
            OrionLib:MakeNotification({
                Name = "保存完了",
                Content = "位置を保存しました",
                Time = 2
            })
        end
    end
})

MiscTab:AddButton({
    Name = "🔙 保存地点に戻る",
    Callback = function()
        if _G.SavedPosition and LocalPlayer.Character then
            LocalPlayer.Character.HumanoidRootPart.CFrame = _G.SavedPosition
        end
    end
})

MiscTab:AddButton({
    Name = "💨 自分を飛ばす（緊急回避）",
    Callback = function()
        if LocalPlayer.Character then
            local dir = LocalPlayer.Character.HumanoidRootPart.CFrame.LookVector
            LocalPlayer.Character.HumanoidRootPart.Velocity = dir * 300 + Vector3.new(0, 100, 0)
        end
    end
})

-- ============================================
-- 初期化
-- ============================================
OrionLib:Init()

-- 完了通知
OrionLib:MakeNotification({
    Name = "ANAN HUB",
    Content = "読み込み完了！自分だけダメージ無効は常時ONです",
    Time = 5
})
