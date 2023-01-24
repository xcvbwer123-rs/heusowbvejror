-- << SERVICES >>
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

-- << LIBRARYS >>
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))() if game.PlaceId ~= 5720801512 then OrionLib:MakeNotification({Name = "오류", Content = "이 스크립트는 \"한국 머더\"에서만 사용되도록 제작되었습니다.", Time = 5}) return end
local SilentAim = loadstring(game:HttpGetAsync("https://pastebin.com/raw/pavCCfAt"))()
local CoinCollect = loadstring(game:HttpGetAsync("https://pastebin.com/raw/0mpcgykG"))()
local GameEsp = loadstring(game:HttpGetAsync("https://pastebin.com/raw/zV9uJtws"))()
local KillAura = loadstring(game:HttpGetAsync("https://pastebin.com/raw/aG6FydaX"))()
local PlayerModule = loadstring(game:HttpGetAsync("https://pastebin.com/raw/y1v0VbMJ"))()
local SheriffModule = loadstring(game:HttpGetAsync("https://pastebin.com/raw/zHZdi1FP"))()
local Discord = loadstring(game:HttpGetAsync("https://pastebin.com/raw/9S91AeyX"))()

-- << PLAYER INSTANCE >>
local LocalPlayer = Players.LocalPlayer

-- << GAME INSTANCE VALUABLES >>
local GameFolder = workspace:WaitForChild("Game")
local Map = GameFolder:WaitForChild("Map")
local Debris = GameFolder:WaitForChild("Debris")

-- << EXTRA VALUABLES >>
local DropNotice = false
local AutoGunCollect = false
local IsInRound = false
local OldNameCall
local Folder = CoreGui:FindFirstChild("Humanoids") or Instance.new("Folder")

-- << UTILITY FUNCTIONS >>
local function IsPlayerInMap(Player: Player)
    local Model = Map:FindFirstChildOfClass("Model")
    local Humanoid = Player.Character and Player.Character:FindFirstChildOfClass("Humanoid")
    if Model and Humanoid and Humanoid.Health > 0 then
        local OverlapParam = OverlapParams.new()
        local Location, Size = Model:GetBoundingBox()

        OverlapParam.FilterDescendantsInstances = {Player.Character}
        OverlapParam.FilterType = Enum.RaycastFilterType.Whitelist

        return #workspace:GetPartBoundsInBox(Location, Size, OverlapParam) > 0 and true or false
    end
    return false
end

local function GetPlayerJob(Player: Player)
    local Character = Player.Character or Player.CharacterAdded:Wait()
    if Character:FindFirstChild("RequestStab", true) or Player:FindFirstChild("RequestStab", true) then
        return "Murderer" 
    elseif Character:FindFirstChild("RequestFire", true) or Player:FindFirstChild("RequestFire", true) then
        return "Sheriff"
    else
        return "None"
    end
end

local function TeleportToMap()
    local Map = Map:FindFirstChildOfClass("Model")
    local Spawns = Map and Map:FindFirstChild("PlayerSpawners"):GetChildren()
    if LocalPlayer.Character then
        LocalPlayer.Character:MoveTo(Spawns[math.random(1, #Spawns)].Position)
    end
end

local function AutoCollect()
    if Debris:FindFirstChild("RevolverPickUp") == nil then
        OrionLib:MakeNotification({
            Name = "총이 드롭되있지 않음",
            Content = "보안관이 아직 사망하지 않았습니다.",
            Image = "http://www.roblox.com/asset/?id=6023426941",
            Time = 5,
        })
        return
    end
    if not IsInRound then
        OrionLib:MakeNotification({
            Name = "총을 주울수 없음",
            Content = "게임이 진행중이지 않거나 게임이 진행중일때 들어오셨습니다.",
            Image = "http://www.roblox.com/asset/?id=6023426941",
            Time = 5,
        })
        return
    end
    if IsPlayerInMap(LocalPlayer) and GetPlayerJob(LocalPlayer) == "None" then
        local Pivot = LocalPlayer.Character:GetPivot()
        local PPart = LocalPlayer.Character.PrimaryPart
        task.wait(1)
        LocalPlayer.Character:PivotTo(Debris.RevolverPickUp.Orb.CFrame)
        firetouchinterest(Debris.RevolverPickUp.Orb, PPart, 0)
        firetouchinterest(Debris.RevolverPickUp.Orb, PPart, 1)
        LocalPlayer.Character:PivotTo(Pivot)
    end
end

local function OnChildAdded(Child: Instance)
    if Child:IsA("Model") and Child.Name == "RevolverPickUp" and IsPlayerInMap(LocalPlayer) and IsInRound then
        if DropNotice then
            OrionLib:MakeNotification({
                Name = "총 드롭 안내",
                Content = "보안관이 사망하여 총이 드롭되었습니다.",
                Image = "http://www.roblox.com/asset/?id=6023426941",
                Time = 5,
            })
        end
        if AutoGunCollect then
            AutoCollect()
        end
    end
end

local function CA2(Child: Instance)
    if Child:IsA("Sound") and Child.Name == "RoundSound" then
        IsInRound = false
    end
end

local function GodMode()
    local Assets = {}
    Folder.Name = "Humanoids"
    Folder.Parent = workspace
    local Humanoid: Humanoid
    for _, Asset in ipairs(LocalPlayer.Character:GetChildren()) do
        if Asset:IsA("Accessory") then
            table.insert(Assets, Asset:Clone())
        elseif Asset:IsA("Humanoid") then
            Humanoid = Asset
        end
    end
    local Animate = LocalPlayer.Character:FindFirstChild("Animate")
    local NewHumanoid = Humanoid:Clone()
    Humanoid.Parent = Folder
    NewHumanoid.Parent = LocalPlayer.Character
    NewHumanoid.HipHeight = Humanoid.HipHeight
    NewHumanoid.Name = "Humanoid"
    local Connection
    Connection = Humanoid.Jumping:Connect(function()
        NewHumanoid.Jump = Humanoid.Jump
    end)
    NewHumanoid.Destroying:Once(function()
        Connection:Disconnect()
    end)
    Humanoid.Destroying:Once(function()
        Connection:Disconnect()
    end)
    for _, Asset in ipairs(Assets) do
        NewHumanoid:AddAccessory(Asset)
    end
    Animate.Disabled = true
    task.wait()
    Animate.Disabled = false
    OrionLib:MakeNotification({
        Name = "주의",
        Content = "무적 상테에서는 일부 기능이 작동하지 않을수도 있습니다.",
        Time = 6
    })
end

-- << GUI TABS >>
local Window = OrionLib:MakeWindow({IntroText = "머더 GUI V1.0", IntroIcon = "http://www.roblox.com/asset/?id=6022668911", Name = "한국머더 GUI V1.0", Icon = "http://www.roblox.com/asset/?id=6022668911", HidePremium = false, SaveConfig = false})

local VisualizeTab = Window:MakeTab({
    Name = "ESP 및 시각",
    Icon = "http://www.roblox.com/asset/?id=6031075931",
    PremiumOnly = false,
})

local MurdererTab = Window:MakeTab({
    Name = "머더 기능",
    Icon = "http://www.roblox.com/asset/?id=6022668887",
    PremiumOnly = false,
})

local SheriffTab = Window:MakeTab({
    Name = "보안관 기능",
    Icon = "http://www.roblox.com/asset/?id=6034513895",
    PremiumOnly = false,
})

local SilentAimTab = Window:MakeTab({
    Name = "자동 에임 기능",
    Icon = "http://www.roblox.com/asset/?id=6022668911",
    PremiumOnly = false,
})

local PlayerTab = Window:MakeTab({
    Name = "로컬 플레이어",
    Icon = "http://www.roblox.com/asset/?id=6022668898",
    PremiumOnly = false,
})

local ExtraTab = Window:MakeTab({
    Name = "기타 기능",
    Icon = "http://www.roblox.com/asset/?id=6022668907",
    PremiumOnly = false,
})

local CreditTab = Window:MakeTab({
    Name = "크레딧",
    Icon = "http://www.roblox.com/asset/?id=6026568189",
    PremiumOnly = false,
})

-- << VISUALIZE TAB >>
VisualizeTab:AddSection({Name = "플레이어 관련"})

VisualizeTab:AddToggle({
    Name = "머더 표시",
    Default = false,
    Callback = function(Value)
        GameEsp:Edit("MurdererEsp", Value)
    end
})

VisualizeTab:AddToggle({
    Name = "보안관 표시",
    Default = false,
    Callback = function(Value)
        GameEsp:Edit("SheriffEsp", Value)
    end
})

VisualizeTab:AddToggle({
    Name = "기타 플레이어 표시",
    Default = false,
    Callback = function(Value)
        GameEsp:Edit("OthersEsp", Value)
    end
})

VisualizeTab:AddSection({Name = "디버그 관련"})

VisualizeTab:AddToggle({
    Name = "에임봇 타겟 위치 표시",
    Default = false,
    Callback = function(Value)
        SilentAim:EditSettings("Debug", Value)
    end
})

VisualizeTab:AddToggle({
    Name = "머더 킬 범위 표시",
    Default = false,
    Callback = function(Value)
        KillAura:SetDebug(Value)
    end
})

-- << MURDERER TAB >>
MurdererTab:AddToggle({
    Name = "킬 범위 수정",
    Default = false,
    Callback = function(Value)
        if Value then
            KillAura:Enable()
        else
            KillAura:Disable()
        end
    end
})

MurdererTab:AddSlider({
    Name = "킬 범위",
	Min = 1,
	Max = 20,
	Default = 15,
	Color = Color3.fromRGB(80, 135, 255),
	Increment = 1,
	ValueName = "스터드",
	Callback = function(Value)
		KillAura:Range(Value)
	end
})

MurdererTab:AddToggle({
    Name = "범위 내의 사람들을 자동으로 죽이기",
    Default = false,
    Callback = function(Value)
        KillAura:SetAutoKill(Value)
    end
})

MurdererTab:AddButton({
    Name = "모두 죽이기",
    Callback = KillAura.KillAll
})

-- << SHERIFF TAB >>
SheriffTab:AddToggle({
    Name = "머더 자동 사격",
    Default = false,
    Callback = function(Value)
        SheriffModule:SetAutoShoot(Value)
    end
})

SheriffTab:AddSlider({
    Name = "사격 범위",
	Min = 1,
	Max = 70,
	Default = 100,
	Color = Color3.fromRGB(80, 135, 255),
	Increment = 1,
	ValueName = "스터드",
	Callback = function(Value)
		SheriffModule:SetRange(Value)
	end
})

SheriffTab:AddToggle({
    Name = "화면에서 보일때만 쏘기",
    Default = true,
    Callback = function(Value)
        SheriffModule:SetVisible(Value)
    end
})

-- << SILENT AIM TAB >>
SilentAimTab:AddToggle({
    Name = "자동 에임 사용",
    Default = false,
    Callback = function(Value)
        if Value then
            SilentAim:Enable()
        else
            SilentAim:Disable()
        end
    end
})

SilentAimTab:AddSlider({
    Name = "칼 자동에임 타겟 속도 고려율",
	Min = 0,
	Max = 100,
	Default = 50,
	Color = Color3.fromRGB(80, 135, 255),
	Increment = 5,
	ValueName = "%",
	Callback = function(Value)
		SilentAim:EditSettings("KnifeAccuracy", Value)
	end
})

SilentAimTab:AddSlider({
    Name = "총 자동에임 타겟 속도 고려율",
	Min = 0,
	Max = 100,
	Default = 25,
	Color = Color3.fromRGB(80, 135, 255),
	Increment = 5,
	ValueName = "%",
	Callback = function(Value)
		SilentAim:EditSettings("GunAccuracy", Value)
	end
})

-- << PLAYER TAB >>
PlayerTab:AddSlider({
    Name = "이동속도",
	Min = 0,
	Max = 100,
	Default = 16,
	Color = Color3.fromRGB(80, 135, 255),
	Increment = 1,
	ValueName = "",
	Callback = function(Value)
		PlayerModule:Edit("WalkSpeed", Value)
	end
})

PlayerTab:AddSlider({
    Name = "점프 파워",
	Min = 0,
	Max = 300,
	Default = 50,
	Color = Color3.fromRGB(80, 135, 255),
	Increment = 1,
	ValueName = "",
	Callback = function(Value)
		PlayerModule:Edit("JumpPower", Value)
	end
})

PlayerTab:AddButton({
    Name = "리스폰",
    Callback = function()
        LocalPlayer.Character.Humanoid.Health = -1972
        LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Dead)
        Folder:ClearAllChildren()
    end
})

PlayerTab:AddButton({
    Name = "무적",
    Callback = GodMode
})

-- << EXTRA TAB >>
ExtraTab:AddSection({Name = "코인 관련"})

ExtraTab:AddToggle({
    Name = "코인 자석",
    Default = false,
    Callback = function(Value)
        if Value then
            CoinCollect:Enable()
        else
            CoinCollect:Disable()
        end
    end
})

ExtraTab:AddSlider({
    Name = "코인 자석 범위",
    Min = 1,
	Max = 12.5,
	Default = 10,
	Color = Color3.fromRGB(80, 135, 255),
	Increment = 0.5,
	ValueName = "스터드",
	Callback = function(Value)
        CoinCollect:Range(Value)
	end
})

ExtraTab:AddSection({Name = "총 관련"})

ExtraTab:AddToggle({
    Name = "총 드롭 알림",
    Default = false,
    Callback = function(Value)
        DropNotice = Value
    end
})

ExtraTab:AddToggle({
    Name = "총 자동 얻기",
    Default = false,
    Callback = function(Value)
        AutoGunCollect = Value
    end
})

ExtraTab:AddButton({
    Name = "총 줍기",
    Callback = AutoCollect
})

ExtraTab:AddSection({Name = "텔레포트"})

ExtraTab:AddButton({
    Name = "맵으로 이동",
    Callback = TeleportToMap
})

ExtraTab:AddButton({
    Name = "로비로 이동",
    Callback = function()
        LocalPlayer.Character:MoveTo(workspace.Lobby.MapVote.VotePart2.Position)
    end
})

ExtraTab:AddSection({Name = "서버 및 맵"})

ExtraTab:AddButton({
    Name = "무기 스케너 제거",
    Callback = function()
        while true do
            local Trash = Map:FindFirstChild("Metal Detector1", true)
            if Trash then
                Trash:Destroy()
            else
                break
            end
            task.wait()
        end
    end
})

ExtraTab:AddButton({
    Name = "서버 제접속",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
    end
})

-- << COMMUNITY & CREDIT >>
local Orion
if gethui then
	Orion = gethui():WaitForChild("Orion")
else
	Orion = CoreGui:WaitForChild("Orion")
end

local Window
for _, Frame in ipairs(Orion:GetChildren()) do
	if Frame:FindFirstChildOfClass("UICorner") then
		Window = Frame
		break
	end
end

local LastContainer
for _, Container in ipairs(Window:GetChildren()) do
	if Container:IsA("ScrollingFrame") then
		LastContainer = Container
	end
end

local Frame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local ImageLabel = Instance.new("ImageLabel")
local UICorner_2 = Instance.new("UICorner")
local TextLabel = Instance.new("TextLabel")
local TextLabel_2 = Instance.new("TextLabel")
local UIStroke = Instance.new("UIStroke")

Frame.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
Frame.BorderSizePixel = 0
Frame.Size = UDim2.new(1, 0, 0, 80)

UICorner.CornerRadius = UDim.new(0, 5)
UICorner.Parent = Frame

ImageLabel.Parent = Frame
ImageLabel.AnchorPoint = Vector2.new(0, 0.5)
ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ImageLabel.BackgroundTransparency = 1.000
ImageLabel.Position = UDim2.new(0, 12, 0.5, 0)
ImageLabel.Size = UDim2.new(0.800000012, 0, 0.800000012, 0)
ImageLabel.SizeConstraint = Enum.SizeConstraint.RelativeYY
ImageLabel.Image = "http://www.roblox.com/asset/?id=12247177291"

UICorner_2.CornerRadius = UDim.new(1, 0)
UICorner_2.Parent = ImageLabel

TextLabel.Parent = Frame
TextLabel.AnchorPoint = Vector2.new(1, 0)
TextLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.BackgroundTransparency = 1.000
TextLabel.Position = UDim2.new(1, -12, 0, 12)
TextLabel.Size = UDim2.new(1, -104, 0.400000006, 0)
TextLabel.Font = Enum.Font.Unknown
TextLabel.Text = "Script by DC"
TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TextLabel.TextScaled = true
TextLabel.TextSize = 14.000
TextLabel.TextWrapped = true
TextLabel.TextXAlignment = Enum.TextXAlignment.Left

TextLabel_2.Parent = Frame
TextLabel_2.AnchorPoint = Vector2.new(1, 1)
TextLabel_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TextLabel_2.BackgroundTransparency = 1.000
TextLabel_2.Position = UDim2.new(1, -11, 1, -12)
TextLabel_2.Size = UDim2.new(1, -104, 0.25, 0)
TextLabel_2.Font = Enum.Font.Unknown
TextLabel_2.Text = "Discord: DC#1071"
TextLabel_2.TextColor3 = Color3.fromRGB(167, 167, 167)
TextLabel_2.TextScaled = true
TextLabel_2.TextSize = 14.000
TextLabel_2.TextWrapped = true
TextLabel_2.TextXAlignment = Enum.TextXAlignment.Left

UIStroke.Parent = Frame
UIStroke.Color = Color3.fromRGB(60, 60, 60)
UIStroke.Thickness = 1

Frame.Parent = LastContainer

CreditTab:AddButton({
    Name = "로컬X 커뮤니티",
    Callback = function()
        Discord:RequestJoin("54G7hdrwMj")
    end
})

-- << RUN >>
Debris.ChildAdded:Connect(OnChildAdded)

OldNameCall = hookmetamethod(game, "__namecall", function(Self, ...)
    local Args = {...}
    local NamecallMethod = getnamecallmethod()

    if not checkcaller() and Self.Name == "MapCheck" and NamecallMethod == "FireServer" then
        IsInRound = true
    end

    return OldNameCall(Self, ...)
end)

workspace.ChildAdded:Connect(CA2)

LocalPlayer.CharacterAdded:Connect(function()
    Folder:ClearAllChildren()
end)
