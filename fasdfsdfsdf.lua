-- << SERVICES >>
local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")

-- << LIBRARYS >>
local OrionLib = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))() if game.PlaceId ~= 5720801512 then OrionLib:MakeNotification({Name = "오류", Content = "이 스크립트는 \"한국 머더\"에서만 사용되도록 제작되었습니다.", Time = 5}) return end
local SilentAim = loadstring(game:HttpGetAsync("https://pastebin.com/raw/pavCCfAt"))()
local CoinCollect = loadstring(game:HttpGetAsync("https://pastebin.com/raw/0mpcgykG"))()
local GameEsp = loadstring(game:HttpGetAsync("https://pastebin.com/raw/zV9uJtws"))()
local KillAura = loadstring(game:HttpGetAsync("https://pastebin.com/raw/aG6FydaX"))()
local PlayerModule = loadstring(game:HttpGetAsync("https://pastebin.com/raw/y1v0VbMJ"))()
local SheriffModule = loadstring(game:HttpGetAsync("https://pastebin.com/raw/zHZdi1FP"))()

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

-- << VISUALIZE TAB >>
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

SheriffTab:AddButton({
    Name = "머더 바로 죽이기 (개발중)",
    Callback = SheriffModule.EndRound
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
        LocalPlayer.Character.Humanoid.Health = 0
    end
})

-- << EXTRA TAB >>
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
    Name = "맵으로 이동",
    Callback = TeleportToMap
})

ExtraTab:AddButton({
    Name = "로비로 이동",
    Callback = function()
        LocalPlayer.Character:MoveTo(workspace.Lobby.MapVote.VotePart2.Position)
    end
})

ExtraTab:AddButton({
    Name = "서버 제접속",
    Callback = function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId)
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
