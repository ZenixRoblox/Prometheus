local b1 = game:GetService("ReplicatedFirst"):FindFirstChild("LocalScript")
if b1 then b1:Destroy() end

local Prometheus = loadstring(game:HttpGet("https://pastebin.com/raw/R9Zivr7x"))()
local window = Prometheus.createWindow("Football Aimbot")

local mainTab = window.addTab("Main")
local settingsTab = window.addTab("Settings")

local aimbotSection = mainTab.addSection("Aimbot")

local beam, trc, targetVisual

mainTab.addToggle(aimbotSection, "Enable Aimbot", true, function(state)
    IsAimbotActive = state
    if state then
        beam = Instance.new("Beam", workspace.Terrain)
        local Attach0 = Instance.new("Attachment", workspace.Terrain)
        local Attach1 = Instance.new("Attachment", workspace.Terrain)
        
        beam.Attachment0 = Attach0
        beam.Attachment1 = Attach1
        beam.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(88, 101, 242)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,0))
        })
        beam.Segments = 5000

        local targetVisual = Instance.new("Part")
        targetVisual.Size = Vector3.new(1.2, 1.2, 1.2)
        targetVisual.Name = "TargetVis"
        targetVisual.Anchored = true
        targetVisual.Parent = workspace
        targetVisual.CanCollide = false
        targetVisual.Material = Enum.Material.Neon
        targetVisual.Color = Color3.fromRGB(0, 0, 0)

        local landPart = Instance.new("Part")
        landPart.Parent = workspace
        landPart.Size = Vector3.new(8, 8, 8)
        landPart.Name = "Landing"
        landPart.CanCollide = false
        landPart.Anchored = true
        landPart.Shape = Enum.PartType.Ball
        landPart.Color = Color3.fromRGB(255, 165, 0)

        IsLocked = false

        trc = Drawing.new("Line")
        trc.Transparency = 0.70
        trc.Thickness = 4.5
        trc.Color = Color3.fromRGB(88, 101, 242)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if input.KeyCode == Enum.KeyCode.Q and not gpe then
                IsLocked = not IsLocked
            end
        end)
    else
        if beam then beam:Destroy() end
        if targetVisual then targetVisual:Destroy() end
        if trc then trc:Remove() end
        beam, targetVisual, trc = nil, nil, nil
        for _, v in pairs(workspace:GetChildren()) do
            if v.Name == "TargetVis" or v.Name == "Landing" then
                v:Destroy()
            end
        end
        for _, v in pairs(workspace.Terrain:GetChildren()) do
            if v:IsA("Beam") or v:IsA("Attachment") then
                v:Destroy()
            end
        end
    end
end)

mainTab.addToggle(aimbotSection,"Auto Angle", false, function(state)
    AutoAngle = state
end)

mainTab.addToggle(aimbotSection,"Auto Power", false, function(state)
    AutoPower = state
end)

local visualSection = settingsTab.addSection("Visuals")
local catchSection = settingsTab.addSection("Catching")

settingsTab.addToggle(visualSection,"Show FOV Circle", true, function(state)
    Config.FOVEnabled = state
end)

settingsTab.addToggle(catchSection,"Auto Catch", false, function(state)
    Config.AutoCatch = state
    Catchy = state
    if state then
        autoCatchBalls()
    end
end)

settingsTab.addToggle(catchSection,"Mags Enabled", false, function(state)
    Config.MagsEnabled = state
end)

settingsTab.addSlider(catchSection,"Auto Catch Range", 1, 20, 6, function(value)
    AUTO_CATCH_RANGE = value
end)

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Mouse = Player:GetMouse()
local Camera = workspace.CurrentCamera

-- Constants
local GRAVITY = 28
local MAX_POWER = 95
local MIN_POWER = 40
local MAX_RANGE = 20
local AUTO_CATCH_RANGE = 6

-- States
local IsAimbotActive = true
local IsLocked = false
local LockedPlayer = nil
local ClosestPlayer = nil
local AutoAngle = true
local AutoPower = true

local Config = {
    FOVEnabled = true,
    MagsEnabled = false,
    AutoCatch = false,
    FOVCircle = {
        Radius = 145,
        Thickness = 2,
        Transparency = 0.7,
        ColorDefault = Color3.new(1, 1, 1),
        ColorInRange = Color3.new(0.5098, 0.5098, 0.7059),
        OffsetY = 35,
    },
}

local Catchy, CatchS

local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local DropShadowHolder = Instance.new("Frame")
local DropShadow = Instance.new("ImageLabel")
local ThrowType = Instance.new("Frame")
local Line = Instance.new("Frame")
local AirTime = Instance.new("Frame")
local UIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
local JusAText = Instance.new("TextLabel")
local ThrowType_2 = Instance.new("TextLabel")
local Z = Instance.new("TextLabel")
local Angle = Instance.new("Frame")
local Line_2 = Instance.new("Frame")
local UIAspectRatioConstraint_2 = Instance.new("UIAspectRatioConstraint")
local JustAText_2 = Instance.new("TextLabel")
local AngleNumber = Instance.new("TextLabel")
local R = Instance.new("TextLabel")
local F = Instance.new("TextLabel")
local UIAspectRatioConstraint_3 = Instance.new("UIAspectRatioConstraint")
local Power = Instance.new("Frame")
local Line_3 = Instance.new("Frame")
local UIAspectRatioConstraint_4 = Instance.new("UIAspectRatioConstraint")
local JustAText_3 = Instance.new("TextLabel")
local PowerNumber = Instance.new("TextLabel")
local X = Instance.new("TextLabel")
local Z_2 = Instance.new("TextLabel")
local JustAText = Instance.new("TextLabel")
local TargetPlayer = Instance.new("Frame")
local Line_4 = Instance.new("Frame")
local UIAspectRatioConstraint_5 = Instance.new("UIAspectRatioConstraint")
local JustAText_4 = Instance.new("TextLabel")
local Playerrr = Instance.new("TextLabel")
local Route = Instance.new("Frame")
local Line_5 = Instance.new("Frame")
local UIAspectRatioConstraint_6 = Instance.new("UIAspectRatioConstraint")
local JustAText_5 = Instance.new("TextLabel")
local RouteOK = Instance.new("TextLabel")
local Int = Instance.new("Frame")
local Line_6 = Instance.new("Frame")
local UIAspectRatioConstraint_7 = Instance.new("UIAspectRatioConstraint")
local JustAText_6 = Instance.new("TextLabel")
local Intable = Instance.new("TextLabel")
local Catchable = Instance.new("Frame")
local JustAText_7 = Instance.new("TextLabel")
local Intable_2 = Instance.new("TextLabel")
local AirTimeTEXT = Instance.new("TextLabel")
local UICorner_2 = Instance.new("UICorner")

-- Properties

ScreenGui.Parent = game:GetService("CoreGui")
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Enabled = false
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.new(0.156863, 0.156863, 0.156863)
MainFrame.BorderColor3 = Color3.new(0, 0, 0)
MainFrame.BorderSizePixel = 0
MainFrame.Position = UDim2.new(0.2319296, 0, 0, 0)
MainFrame.Size = UDim2.new(0.575757563, 0, 0.0843672454, 0)

UICorner.Parent = MainFrame
UICorner.CornerRadius = UDim.new(0, 3)

DropShadowHolder.Name = "DropShadowHolder"
DropShadowHolder.Parent = MainFrame
DropShadowHolder.BackgroundTransparency = 1
DropShadowHolder.BorderSizePixel = 0
DropShadowHolder.Size = UDim2.new(1, 0, 1, 0)
DropShadowHolder.ZIndex = 0

DropShadow.Name = "DropShadow"
DropShadow.Parent = DropShadowHolder
DropShadow.AnchorPoint = Vector2.new(0.5, 0.5)
DropShadow.BackgroundTransparency = 1
DropShadow.BorderSizePixel = 0
DropShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
DropShadow.Size = UDim2.new(1, 47, 1, 47)
DropShadow.ZIndex = 0
--DropShadow.Image = "rbxassetid://6015897843"--
DropShadow.ImageColor3 = Color3.new(0, 0, 0)
DropShadow.ImageTransparency = 0.5
DropShadow.ScaleType = Enum.ScaleType.Slice
DropShadow.SliceCenter = Rect.new(49, 49, 450, 450)

ThrowType.Name = "ThrowType"
ThrowType.Parent = MainFrame
ThrowType.BackgroundColor3 = Color3.new(1, 1, 1)
ThrowType.BackgroundTransparency = 1
ThrowType.BorderColor3 = Color3.new(0, 0, 0)
ThrowType.BorderSizePixel = 0
ThrowType.Size = UDim2.new(0.155746505, 0, 1, 0)

Line.Name = "Line"
Line.Parent = ThrowType
Line.BackgroundColor3 = Color3.new(0.3451, 0.3961, 0.9490)
Line.BorderColor3 = Color3.new(0, 0, 0)
Line.BorderSizePixel = 0
Line.Position = UDim2.new(1, 0, 0, 0)
Line.Size = UDim2.new(0.0068965517, 0, 1, 0)

UIAspectRatioConstraint.Parent = Line
UIAspectRatioConstraint.AspectRatio = 0.014705882407724857

JustAText.Name = "Just A Text"
JustAText.Parent = ThrowType
JustAText.BackgroundColor3 = Color3.new(1, 1, 1)
JustAText.BackgroundTransparency = 1
JustAText.BorderColor3 = Color3.new(0, 0, 0)
JustAText.BorderSizePixel = 0
JustAText.Position = UDim2.new(0.255172402, 0, 0, 0)
JustAText.Size = UDim2.new(0, 72, 0, 22)
JustAText.Font = Enum.Font.SourceSans
JustAText.Text = "Throw Type:"
JustAText.TextColor3 = Color3.new(1, 1, 1)
JustAText.TextSize = 20

ThrowType_2.Name = "ThrowType"
ThrowType_2.Parent = ThrowType
ThrowType_2.BackgroundColor3 = Color3.new(1, 1, 1)
ThrowType_2.BackgroundTransparency = 1
ThrowType_2.BorderColor3 = Color3.new(0, 0, 0)
ThrowType_2.BorderSizePixel = 0
ThrowType_2.Position = UDim2.new(0.331034482, 0, 0.411764711, 0)
ThrowType_2.Size = UDim2.new(0, 49, 0, 24)
ThrowType_2.Font = Enum.Font.SourceSans
ThrowType_2.Text = "Mag"
ThrowType_2.TextColor3 = Color3.new(0.3451, 0.3961, 0.9490)
ThrowType_2.TextSize = 40

Z.Name = "Z"
Z.Parent = ThrowType
Z.BackgroundColor3 = Color3.new(1, 1, 1)
Z.BackgroundTransparency = 1
Z.BorderColor3 = Color3.new(0, 0, 0)
Z.BorderSizePixel = 0
Z.Position = UDim2.new(0.0620689653, 0, 0.558823526, 0)
Z.Size = UDim2.new(0, 28, 0, 23)
Z.Font = Enum.Font.SourceSans
Z.Text = "C"
Z.TextColor3 = Color3.new(0.3451, 0.3961, 0.9490)
Z.TextSize = 30

Angle.Name = "Angle"
Angle.Parent = MainFrame
Angle.BackgroundColor3 = Color3.new(1, 1, 1)
Angle.BackgroundTransparency = 1
Angle.BorderColor3 = Color3.new(0, 0, 0)
Angle.BorderSizePixel = 0
Angle.Position = UDim2.new(0.156820625, 0, 0, 0)
Angle.Size = UDim2.new(0.155746505, 0, 1, 0)

Line_2.Name = "Line"
Line_2.Parent = Angle
Line_2.BackgroundColor3 = Color3.new(0.3451, 0.3961, 0.9490)
Line_2.BorderColor3 = Color3.new(0, 0, 0)
Line_2.BorderSizePixel = 0
Line_2.Position = UDim2.new(1, 0, 0, 0)
Line_2.Size = UDim2.new(0.0068965517, 0, 1, 0)

UIAspectRatioConstraint_2.Parent = Line_2
UIAspectRatioConstraint_2.AspectRatio = 0.014705882407724857

JustAText_2.Name = "Just A Text"
JustAText_2.Parent = Angle
JustAText_2.BackgroundColor3 = Color3.new(1, 1, 1)
JustAText_2.BackgroundTransparency = 1
JustAText_2.BorderColor3 = Color3.new(0, 0, 0)
JustAText_2.BorderSizePixel = 0
JustAText_2.Position = UDim2.new(0.255172402, 0, 0, 0)
JustAText_2.Size = UDim2.new(0, 72, 0, 22)
JustAText_2.Font = Enum.Font.SourceSans
JustAText_2.Text = "Angle:"
JustAText_2.TextColor3 = Color3.new(1, 1, 1)
JustAText_2.TextSize = 20

AngleNumber.Name = "AngleNumber"
AngleNumber.Parent = Angle
AngleNumber.BackgroundColor3 = Color3.new(1, 1, 1)
AngleNumber.BackgroundTransparency = 1
AngleNumber.BorderColor3 = Color3.new(0, 0, 0)
AngleNumber.BorderSizePixel = 0
AngleNumber.Position = UDim2.new(0.331034482, 0, 0.411764711, 0)
AngleNumber.Size = UDim2.new(0, 49, 0, 24)
AngleNumber.Font = Enum.Font.SourceSans
AngleNumber.Text = "35"
AngleNumber.TextColor3 = Color3.new(0.3451, 0.3961, 0.9490)
AngleNumber.TextSize = 40

R.Name = "R"
R.Parent = Angle
R.BackgroundColor3 = Color3.new(1, 1, 1)
R.BackgroundTransparency = 1
R.BorderColor3 = Color3.new(0, 0, 0)
R.BorderSizePixel = 0
R.Position = UDim2.new(0.710344851, 0, 0.558823526, 0)
R.Size = UDim2.new(0, 28, 0, 23)
R.Font = Enum.Font.SourceSans
R.Text = "R"
R.TextColor3 = Color3.new(0.3451, 0.3961, 0.9490)
R.TextSize = 30

F.Name = "F"
F.Parent = Angle
F.BackgroundColor3 = Color3.new(1, 1, 1)
F.BackgroundTransparency = 1
F.BorderColor3 = Color3.new(0, 0, 0)
F.BorderSizePixel = 0
F.Position = UDim2.new(0.0620689653, 0, 0.558823526, 0)
F.Size = UDim2.new(0, 28, 0, 23)
F.Font = Enum.Font.SourceSans
F.Text = "F"
F.TextColor3 = Color3.new(0.3451, 0.3961, 0.9490)
F.TextSize = 30

UIAspectRatioConstraint_3.Parent = MainFrame
UIAspectRatioConstraint_3.AspectRatio = 13.691176414489746

Power.Name = "Power"
Power.Parent = MainFrame
Power.BackgroundColor3 = Color3.new(1, 1, 1)
Power.BackgroundTransparency = 1
Power.BorderColor3 = Color3.new(0, 0, 0)
Power.BorderSizePixel = 0
Power.Position = UDim2.new(0.31364125, 0, 0, 0)
Power.Size = UDim2.new(0.155746505, 0, 1, 0)

Line_3.Name = "Line"
Line_3.Parent = Power
Line_3.BackgroundColor3 = Color3.new(0.3451, 0.3961, 0.9490)
Line_3.BorderColor3 = Color3.new(0, 0, 0)
Line_3.BorderSizePixel = 0
Line_3.Position = UDim2.new(1, 0, 0, 0)
Line_3.Size = UDim2.new(0.0068965517, 0, 1, 0)

UIAspectRatioConstraint_4.Parent = Line_3
UIAspectRatioConstraint_4.AspectRatio = 0.014705882407724857

JustAText_3.Name = "Just A Text"
JustAText_3.Parent = Power
JustAText_3.BackgroundColor3 = Color3.new(1, 1, 1)
JustAText_3.BackgroundTransparency = 1
JustAText_3.BorderColor3 = Color3.new(0, 0, 0)
JustAText_3.BorderSizePixel = 0
JustAText_3.Position = UDim2.new(0.255172402, 0, 0, 0)
JustAText_3.Size = UDim2.new(0, 72, 0, 22)
JustAText_3.Font = Enum.Font.SourceSans
JustAText_3.Text = "Power:"
JustAText_3.TextColor3 = Color3.new(1, 1, 1)
JustAText_3.TextSize = 20

AirTime.Name = "AirTime"
AirTime.Parent = MainFrame
AirTime.BackgroundColor3 = Color3.new(0.0901961, 0.0901961, 0.0901961)
AirTime.BorderColor3 = Color3.new(0, 0, 0)
AirTime.BorderSizePixel = 0
AirTime.Position = UDim2.new(-0.192266405, 0, 0, 0)
AirTime.Size = UDim2.new(0, 155, 0, 68)



AirTimeTEXT.Name = "AirTimeTEXT"
AirTimeTEXT.Parent = AirTime
AirTimeTEXT.BackgroundColor3 = Color3.new(1, 1, 1)
AirTimeTEXT.BackgroundTransparency = 1
AirTimeTEXT.BorderColor3 = Color3.new(0, 0, 0)
AirTimeTEXT.BorderSizePixel = 0
AirTimeTEXT.Position = UDim2.new(0.354838699, 0, 0.357142866, 0)
AirTimeTEXT.Size = UDim2.new(0, 45, 0, 30)
AirTimeTEXT.Font = Enum.Font.SourceSans
AirTimeTEXT.Text = "1.50"
AirTimeTEXT.TextColor3 = Color3.new(0.3451, 0.3961, 0.9490)
AirTimeTEXT.TextSize = 40


UICorner_2.Parent = AirTime
UICorner_2.CornerRadius = UDim.new(0, 2)

JusAText.Name = "JusAText"
JusAText.Parent = AirTime
JusAText.BackgroundColor3 = Color3.new(1, 1, 1)
JusAText.BackgroundTransparency = 1
JusAText.BorderColor3 = Color3.new(0, 0, 0)
JusAText.BorderSizePixel = 0
JusAText.Position = UDim2.new(-0.148387089, 0, -0.200000003, 0)
JusAText.Size = UDim2.new(0, 200, 0, 50)
JusAText.Font = Enum.Font.SourceSans
JusAText.Text = "Airtime:"
JusAText.TextColor3 = Color3.new(1, 1, 1)
JusAText.TextSize = 25


PowerNumber.Name = "PowerNumber"
PowerNumber.Parent = Power
PowerNumber.BackgroundColor3 = Color3.new(1, 1, 1)
PowerNumber.BackgroundTransparency = 1
PowerNumber.BorderColor3 = Color3.new(0, 0, 0)
PowerNumber.BorderSizePixel = 0
PowerNumber.Position = UDim2.new(0.331034482, 0, 0.411764711, 0)
PowerNumber.Size = UDim2.new(0, 49, 0, 24)
PowerNumber.Font = Enum.Font.SourceSans
PowerNumber.Text = "60"
PowerNumber.TextColor3 = Color3.new(0.3451, 0.3961, 0.9490)
PowerNumber.TextSize = 40

X.Name = "X"
X.Parent = Power
X.BackgroundColor3 = Color3.new(1, 1, 1)
X.BackgroundTransparency = 1
X.BorderColor3 = Color3.new(0, 0, 0)
X.BorderSizePixel = 0
X.Position = UDim2.new(0.751724124, 0, 0.558823526, 0)
X.Size = UDim2.new(0, 28, 0, 23)
X.Font = Enum.Font.SourceSans
X.Text = "X"
X.TextColor3 = Color3.new(0.3451, 0.3961, 0.9490)
X.TextSize = 30

Z_2.Name = "Z"
Z_2.Parent = Power
Z_2.BackgroundColor3 = Color3.new(1, 1, 1)
Z_2.BackgroundTransparency = 1
Z_2.BorderColor3 = Color3.new(0, 0, 0)
Z_2.BorderSizePixel = 0
Z_2.Position = UDim2.new(0.0620689653, 0, 0.558823526, 0)
Z_2.Size = UDim2.new(0, 28, 0, 23)
Z_2.Font = Enum.Font.SourceSans
Z_2.Text = "Z"
Z_2.TextColor3 = Color3.new(0.3451, 0.3961, 0.9490)
Z_2.TextSize = 30

TargetPlayer.Name = "TargetPlayer"
TargetPlayer.Parent = MainFrame
TargetPlayer.BackgroundColor3 = Color3.new(1, 1, 1)
TargetPlayer.BackgroundTransparency = 1
TargetPlayer.BorderColor3 = Color3.new(0, 0, 0)
TargetPlayer.BorderSizePixel = 0
TargetPlayer.Position = UDim2.new(0.46938777, 0, 0, 0)
TargetPlayer.Size = UDim2.new(0.155746505, 0, 1, 0)

Line_4.Name = "Line"
Line_4.Parent = TargetPlayer
Line_4.BackgroundColor3 = Color3.new(0.3451, 0.3961, 0.9490)
Line_4.BorderColor3 = Color3.new(0, 0, 0)
Line_4.BorderSizePixel = 0
Line_4.Position = UDim2.new(1, 0, 0, 0)
Line_4.Size = UDim2.new(0.0068965517, 0, 1, 0)

UIAspectRatioConstraint_5.Parent = Line_4
UIAspectRatioConstraint_5.AspectRatio = 0.014705882407724857

JustAText_4.Name = "Just A Text"
JustAText_4.Parent = TargetPlayer
JustAText_4.BackgroundColor3 = Color3.new(1, 1, 1)
JustAText_4.BackgroundTransparency = 1
JustAText_4.BorderColor3 = Color3.new(0, 0, 0)
JustAText_4.BorderSizePixel = 0
JustAText_4.Position = UDim2.new(0.255172402, 0, 0, 0)
JustAText_4.Size = UDim2.new(0, 72, 0, 22)
JustAText_4.Font = Enum.Font.SourceSans
JustAText_4.Text = "TargetPlayer:"
JustAText_4.TextColor3 = Color3.new(1, 1, 1)
JustAText_4.TextSize = 20

Playerrr.Name = "Player"
Playerrr.Parent = TargetPlayer
Playerrr.BackgroundColor3 = Color3.new(1, 1, 1)
Playerrr.BackgroundTransparency = 1
Playerrr.BorderColor3 = Color3.new(0, 0, 0)
Playerrr.BorderSizePixel = 0
Playerrr.Position = UDim2.new(0.331034482, 0, 0.411764711, 0)
Playerrr.Size = UDim2.new(0, 49, 0, 24)
Playerrr.Font = Enum.Font.SourceSans
Playerrr.Text = "RedX_12890"
Playerrr.TextColor3 = Color3.new(0.3451, 0.3961, 0.9490)
Playerrr.TextSize = 20

Route.Name = "Route"
Route.Parent = MainFrame
Route.BackgroundColor3 = Color3.new(1, 1, 1)
Route.BackgroundTransparency = 1
Route.BorderColor3 = Color3.new(0, 0, 0)
Route.BorderSizePixel = 0
Route.Position = UDim2.new(0.626208365, 0, 0, 0)
Route.Size = UDim2.new(0.155746505, 0, 1, 0)

Line_5.Name = "Line"
Line_5.Parent = Route
Line_5.BackgroundColor3 = Color3.new(0.3451, 0.3961, 0.9490)
Line_5.BorderColor3 = Color3.new(0, 0, 0)
Line_5.BorderSizePixel = 0
Line_5.Position = UDim2.new(1, 0, 0, 0)
Line_5.Size = UDim2.new(0.0068965517, 0, 1, 0)

UIAspectRatioConstraint_6.Parent = Line_5
UIAspectRatioConstraint_6.AspectRatio = 0.014705882407724857

JustAText_5.Name = "Just A Text"
JustAText_5.Parent = Route
JustAText_5.BackgroundColor3 = Color3.new(1, 1, 1)
JustAText_5.BackgroundTransparency = 1
JustAText_5.BorderColor3 = Color3.new(0, 0, 0)
JustAText_5.BorderSizePixel = 0
JustAText_5.Position = UDim2.new(0.255172402, 0, 0, 0)
JustAText_5.Size = UDim2.new(0, 72, 0, 22)
JustAText_5.Font = Enum.Font.SourceSans
JustAText_5.Text = "Route:"
JustAText_5.TextColor3 = Color3.new(1, 1, 1)
JustAText_5.TextSize = 20

RouteOK.Name = "RouteType"
RouteOK.Parent = Route
RouteOK.BackgroundColor3 = Color3.new(1, 1, 1)
RouteOK.BackgroundTransparency = 1
RouteOK.BorderColor3 = Color3.new(0, 0, 0)
RouteOK.BorderSizePixel = 0
RouteOK.Position = UDim2.new(0.331034482, 0, 0.411764711, 0)
RouteOK.Size = UDim2.new(0, 49, 0, 24)
RouteOK.Font = Enum.Font.SourceSans
RouteOK.Text = "Slant"
RouteOK.TextColor3 = Color3.new(0.3451, 0.3961, 0.9490)
RouteOK.TextSize = 40

Int.Name = "Int"
Int.Parent = MainFrame
Int.BackgroundColor3 = Color3.new(1, 1, 1)
Int.BackgroundTransparency = 1
Int.BorderColor3 = Color3.new(0, 0, 0)
Int.BorderSizePixel = 0
Int.Position = UDim2.new(0.78302902, 0, 0, 0)
Int.Size = UDim2.new(0.111707851, 0, 1, 0)

Line_6.Name = "Line"
Line_6.Parent = Int
Line_6.BackgroundColor3 = Color3.new(0.3451, 0.3961, 0.9490)
Line_6.BorderColor3 = Color3.new(0, 0, 0)
Line_6.BorderSizePixel = 0
Line_6.Position = UDim2.new(1.00000226, 0, 0, 0)
Line_6.Size = UDim2.new(0.0742001384, 0, 1, 0)

UIAspectRatioConstraint_7.Parent = Line_6
UIAspectRatioConstraint_7.AspectRatio = 0.014705882407724857

JustAText_6.Name = "Just A Text"
JustAText_6.Parent = Int
JustAText_6.BackgroundColor3 = Color3.new(1, 1, 1)
JustAText_6.BackgroundTransparency = 1
JustAText_6.BorderColor3 = Color3.new(0, 0, 0)
JustAText_6.BorderSizePixel = 0
JustAText_6.Position = UDim2.new(0.207095787, 0, 0, 0)
JustAText_6.Size = UDim2.new(0, 72, 0, 22)
JustAText_6.Font = Enum.Font.SourceSans
JustAText_6.Text = "Intable"
JustAText_6.TextColor3 = Color3.new(1, 1, 1)
JustAText_6.TextSize = 20

Intable.Name = "Intable"
Intable.Parent = Int
Intable.BackgroundColor3 = Color3.new(1, 1, 1)
Intable.BackgroundTransparency = 1
Intable.BorderColor3 = Color3.new(0, 0, 0)
Intable.BorderSizePixel = 0
Intable.Position = UDim2.new(0.311803937, 0, 0.411764711, 0)
Intable.Size = UDim2.new(0, 49, 0, 24)
Intable.Font = Enum.Font.SourceSans
Intable.Text = "Yes"
Intable.TextColor3 = Color3.new(0.3451, 0.3961, 0.9490)
Intable.TextSize = 40

Catchable.Name = "Catchable"
Catchable.Parent = MainFrame
Catchable.BackgroundColor3 = Color3.new(1, 1, 1)
Catchable.BackgroundTransparency = 1
Catchable.BorderColor3 = Color3.new(0, 0, 0)
Catchable.BorderSizePixel = 0
Catchable.Position = UDim2.new(0.8958112, 0, 0, 0)
Catchable.Size = UDim2.new(0.14188792, 0, 1, 0)

JustAText_7.Name = "Just A Text"
JustAText_7.Parent = Catchable
JustAText_7.BackgroundColor3 = Color3.new(1, 1, 1)
JustAText_7.BackgroundTransparency = 1
JustAText_7.BorderColor3 = Color3.new(0, 0, 0)
JustAText_7.BorderSizePixel = 0
JustAText_7.Position = UDim2.new(0.076477333, 0, 0, 0)
JustAText_7.Size = UDim2.new(0, 72, 0, 22)
JustAText_7.Font = Enum.Font.SourceSans
JustAText_7.Text = "Catchable"
JustAText_7.TextColor3 = Color3.new(1, 1, 1)
JustAText_7.TextSize = 20

Intable_2.Name = "Intable"
Intable_2.Parent = Catchable
Intable_2.BackgroundColor3 = Color3.new(1, 1, 1)
Intable_2.BackgroundTransparency = 1
Intable_2.BorderColor3 = Color3.new(0, 0, 0)
Intable_2.BorderSizePixel = 0
Intable_2.Position = UDim2.new(0.111803937, 0, 0.411764711, 0)
Intable_2.Size = UDim2.new(0, 49, 0, 24)
Intable_2.Font = Enum.Font.SourceSans
Intable_2.Text = "No"
Intable_2.TextColor3 = Color3.new(0.3451, 0.3961, 0.9490)
Intable_2.TextSize = 40

local prom = game:GetService("CoreGui"):FindFirstChild("prom")

if prom then
    HASH9:Destroy()
end

local function grabMousePos()
    return UserInputService:GetMouseLocation()
end

local function isVisandPos(Pos)
    local camPos, OnScreen = workspace.CurrentCamera:WorldToViewportPoint(Pos)
    return OnScreen and camPos or nil
end

local function getNearestPlayerToMouse()
    local MousePosition = UserInputService:GetMouseLocation()
    local ClosestPlayer, ClosestDistance = nil, math.huge

    local function getScreenPosition(part)
        local ScreenPoint, onScreen = Camera:WorldToViewportPoint(part.Position)
        return Vector2.new(ScreenPoint.X, ScreenPoint.Y), onScreen
    end

    local function checkClosest(object, rootPart)
        if rootPart then
            local ScreenPosition, onScreen = getScreenPosition(rootPart)
            if onScreen then
                local Distance = (ScreenPosition - MousePosition).Magnitude
                if Distance < ClosestDistance then
                    ClosestPlayer = object
                    ClosestDistance = Distance
                end
            end
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= Player and player.Team == Player.Team then
            local Character = player.Character
            if Character then
                checkClosest(player, Character:FindFirstChild("HumanoidRootPart"))
            end
        end
    end

    for _, bot in ipairs(Workspace:GetChildren()) do
        if bot.Name == "npcwr" then
            for _, station in ipairs({"a", "b"}) do
                local stationPart = bot:FindFirstChild(station)
                if stationPart then
                    local botPart = stationPart:FindFirstChild(station == "a" and "bot 1" or "bot 3")
                    if botPart then
                        checkClosest(botPart, botPart:FindFirstChild("HumanoidRootPart"))
                    end
                end
            end
        end
    end

    return ClosestPlayer
end

--// BASIC FUNCTIONS //--
local function isMoving(entity)
    if not string.find(entity.Name, "bot 1") and not string.find(entity.Name, "bot 3") then
        local humanoid = entity.Character and entity.Character:FindFirstChild("Humanoid")
        return humanoid and humanoid.MoveDirection.Magnitude > 0
    end
    return false
end

local function beamProjectile(g, v0, x0, t1)
    local c = 0.5 * 0.5 * 0.5
    local p3 = 0.5 * g * t1 * t1 + v0 * t1 + x0
    local p2 = p3 - (g * t1 * t1 + v0 * t1) / 3
    local p1 = (c * g * t1 * t1 + 0.5 * v0 * t1 + x0 - c * (x0 + p3)) / (3 * c) - p2
    
    local curve0 = (p1 - x0).Magnitude
    local curve1 = (p2 - p3).Magnitude
    
    local b = (x0 - p3).Unit
    local r1 = (p1 - x0).Unit
    local u1 = r1:Cross(b).Unit
    local r2 = (p2 - p3).Unit
    local u2 = r2:Cross(b).Unit
    b = u1:Cross(r1).Unit
    
    local cf1 = CFrame.new(
        x0.X, x0.Y, x0.Z,
        r1.X, u1.X, b.X,
        r1.Y, u1.Y, b.Y,
        r1.Z, u1.Z, b.Z
    )
    
    local cf2 = CFrame.new(
        p3.X, p3.Y, p3.Z,
        r2.X, u2.X, b.X,
        r2.Y, u2.Y, b.Y,
        r2.Z, u2.Z, b.Z
    )
    
    return curve0, -curve1, cf1, cf2
end

local function getFieldOrientation(throwerPosition, playerPosition)
    return playerPosition.Z > 0 and 1 or -1
end

local function clampNumber(val, minimum, maximum)
    return math.min(math.max(val, minimum), maximum)
end

--// CALCULATION FUNCTIONS & MATH //--

local function RoundToHundredths(number)
    return math.floor(number * 100 + 0.5) / 100
end

local function CalculateRouteOfPlayer(player)
    if string.find(player.Name, "bot 1") or string.find(player.Name, "bot 3") then
        return "Straight"
    end

    local humanoid = player.Character:FindFirstChild("Humanoid")
    local playerRootPart = player.Character:FindFirstChild("HumanoidRootPart")
    local localRootPart = Player.Character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not playerRootPart or not localRootPart then
        return "Unknown"
    end

    local directionMoving = humanoid.MoveDirection
    local distance = playerRootPart.Position - localRootPart.Position
    local direction = distance.Unit
    local directionDot = directionMoving:Dot(distance)

    local z2 = direction * Vector3.new(0, 0, getFieldOrientation(localRootPart, directionMoving))
    local streakingRoutesDotProduct = directionMoving:Dot(z2)

    if directionDot < 0 then
        return "Comeback"
    elseif streakingRoutesDotProduct >= 0.80 or streakingRoutesDotProduct <= -0.80 then
        return "Straight"
    elseif streakingRoutesDotProduct >= 0.45 or streakingRoutesDotProduct <= -0.45 then
        return "Post"
    elseif streakingRoutesDotProduct >= 0.2 or streakingRoutesDotProduct <= -0.2 then
        return "Slant"
    elseif streakingRoutesDotProduct == 0 then
        return "Still"
    end

    return "Unknown"
end

local function HorizontalRangeOfProjectile(targetPlayer)
    local targetHead = string.find(targetPlayer.Name, "bot 1") or string.find(targetPlayer.Name, "bot 3")
        and targetPlayer:FindFirstChild("Head")
        or targetPlayer.Character.Head

    local playerRootPart = Player.Character.HumanoidRootPart

    if not targetHead or not playerRootPart then
        return 0
    end

    local projectileRange = playerRootPart.Position - targetHead.Position
    return Vector2.new(projectileRange.X, projectileRange.Z).Magnitude
end

local function CalculateHighSpeedLowAngle(gravity, speed)
    local range = HorizontalRangeOfProjectile(getNearestPlayerToMouse())
    return 0.535 * math.asin((range * gravity) / (speed ^ 2))
end
								
local function HorizontalRangeOfProjectile(targetPlayer)
    if not targetPlayer then
        warn("HorizontalRangeOfProjectile: targetPlayer is nil")
        return 0
    end

    local targetHead
    if typeof(targetPlayer) == "Instance" then
        if string.find(targetPlayer.Name, "bot 1") or string.find(targetPlayer.Name, "bot 3") then
            targetHead = targetPlayer:FindFirstChild("Head")
        elseif targetPlayer:IsA("Player") and targetPlayer.Character then
            targetHead = targetPlayer.Character:FindFirstChild("Head")
        end
    end

    if not targetHead then
        warn("HorizontalRangeOfProjectile: Could not find target head")
        return 0
    end

    local playerRootPart = Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")

    if not playerRootPart then
        warn("HorizontalRangeOfProjectile: Could not find player's HumanoidRootPart")
        return 0
    end

    local projectileRange = playerRootPart.Position - targetHead.Position
    return Vector2.new(projectileRange.X, projectileRange.Z).Magnitude
end

local function CalculateHighSpeedLowAngle(gravity, speed)
    local range = HorizontalRangeOfProjectile(getNearestPlayerToMouse())
    return 0.535 * math.asin((range * gravity) / (speed ^ 2))
end

local function CalculateLaunchAngle(gravity, footballSpeed)
    local range = HorizontalRangeOfProjectile(getNearestPlayerToMouse())
    return math.asin(gravity * range / (footballSpeed ^ 2))
end

local function CalculateInitialVelocityY(initialVelocity, angle)
    return initialVelocity * math.sin(angle)
end

local function CalculateInitialVelocityX(initialVelocity, angle)
    return initialVelocity * math.cos(angle)
end

local function GetTimeOfFlightProjectile(initialVelocity, angle, gravity)
    return (2 * initialVelocity * math.sin(angle)) / gravity
end

local function TimeOfFlight2(initialVelocity, angle, gravity)
    local verticalVelocity = CalculateInitialVelocityY(initialVelocity, angle)
    return verticalVelocity / gravity
end

local function CalculateVelocityToReachPosition(start, target, gravity, time)
    if not (typeof(start) == "Vector3" and typeof(target) == "Vector3" and typeof(gravity) == "Vector3") then
        warn("Inputs must be Vector3")
        return Vector3.new(0,0,0), Vector3.new(0,1,0), 0
    end
    
    if type(time) ~= "number" then
        warn("Time must be a number")
        return Vector3.new(0,0,0), Vector3.new(0,1,0), 0
    end

    local displacement = target - start
    local horizontalDisplacement = Vector3.new(displacement.X, 0, displacement.Z)
    
    local horizontalVelocity = horizontalDisplacement / time
    local verticalVelocity = displacement.Y / time - 0.5 * gravity.Y * time
    
    local velocity = Vector3.new(horizontalVelocity.X, verticalVelocity, horizontalVelocity.Z)
    local direction = velocity.Magnitude > 0.001 and velocity.Unit or Vector3.new(0, 1, 0)
    local power = velocity.Magnitude
    
    return velocity, direction, power
end

local function CalculateHeightDifference(start, finish)
    return (start - finish).Y
end

local function isVector3Valid(vec3)
    return not (vec3.X ~= vec3.X or vec3.Y ~= vec3.Y or vec3.Z ~= vec3.Z)
end

local function getThrowType()
    return tostring(ThrowType_2.Text)
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent or input.KeyCode ~= Enum.KeyCode.C then return end
    if not Character then return end
    
    local football = Character:FindFirstChild("Football")
    if not football then return end
    
    local throwTypes = {"Dime", "Mag", "Dot", "Dive", "Fade", "Bullet", "Jump"}
    local currentIndex = table.find(throwTypes, ThrowType_2.Text)
    
    if currentIndex then
        local nextIndex = currentIndex % #throwTypes + 1
        ThrowType_2.Text = throwTypes[nextIndex]
    end
end)

local function CalculateHorizontalAndVerticalVelocity(timeOfFlight, endPos, startPos, gravity)
    local displacement = startPos - endPos
    local horizontalDisplacement = Vector2.new(displacement.X, displacement.Z)
    local verticalDisplacement = displacement.Y

    local horizontalVelocity = horizontalDisplacement.Magnitude / timeOfFlight
    local verticalVelocity = (verticalDisplacement + 0.5 * gravity * timeOfFlight^2) / timeOfFlight

    return verticalVelocity, horizontalVelocity
end

local function CalculateHeightDifference(start, finish)
    return (start - finish).Y
end

local function isBotMoving(velocity)
    return velocity ~= Vector3.new(0, 0, 0)
end

local function BotEstimatedVel(time, bot)
    local rootPart = bot:FindFirstChild("HumanoidRootPart")
    if not rootPart then return bot.Position end

    local velocity = rootPart.Velocity
    local throwType = getThrowType()
    local isMoving = isBotMoving(velocity)

    local leadNumbers = {
        bot3 = {
            moving = {
                Dime = Vector3.new(-1, 1.25, -6),
                Mag = Vector3.new(-2, 2, -11),
                Dive = Vector3.new(-1.25, 1.5, -9),
                Dot = Vector3.new(-0.09, 0.09, -4),
                Fade = Vector3.new(0, 0, 0),
                Bullet = Vector3.new(-5, -1, -1.25),
                Jump = Vector3.new(-1, 2.25, -5)
            },
            still = {
                Dime = Vector3.new(0, 0, 0),
                Mag = Vector3.new(0, 0, 0),
                Dive = Vector3.new(0, 0, 0),
                Dot = Vector3.new(0, 0, 0),
                Fade = Vector3.new(0, 0, 0),
                Bullet = Vector3.new(0, 0, 0),
                Jump = Vector3.new(0, 4, 0)
            }
        },
        bot1 = {
            moving = {
                Dime = Vector3.new(1, 1.25, 6),
                Mag = Vector3.new(2, 2, 11),
                Dive = Vector3.new(1.25, 1.5, 9),
                Dot = Vector3.new(0.09, 0.09, 4),
                Fade = Vector3.new(0, 0, 0),
                Bullet = Vector3.new(5, 1, 1.25),
                Jump = Vector3.new(1, 2, 5)
            },
            still = {
                Dime = Vector3.new(0, 0, 0),
                Mag = Vector3.new(0, 0, 0),
                Dive = Vector3.new(0, 0, 0),
                Dot = Vector3.new(0, 0, 0),
                Fade = Vector3.new(0, 0, 0),
                Bullet = Vector3.new(0, 0, 0),
                Jump = Vector3.new(0, 5, 0)
            }
        }
    }

    local botType = bot.Name == "bot 3" and "bot3" or "bot1"
    local movementState = isMoving and "moving" or "still"
    local leadOffset = leadNumbers[botType][movementState][throwType]

    if isMoving then
        return rootPart.Position + (velocity * time) + leadOffset
    else
        return rootPart.Position + leadOffset
    end
end

local function calculateThrowDirection(horizontalVelocity, verticalVelocity, startPos, endPos)
    local displacement = startPos - endPos
    local horizontalDisplacement = Vector3.new(displacement.X, 0, displacement.Z)
    
    local horizontalDirection = horizontalDisplacement.Unit
    local horizontalSpeed = horizontalVelocity * horizontalDirection
    
    local verticalComponent = Vector3.new(0, verticalVelocity, 0)
    
    return horizontalSpeed + verticalComponent
end
                 
--// PREDICTION FUNCTIONS //--

local function getOffsetPredictionBasedOnRouteAndThrowType(route, throwType)
    if not QBAIMtab.OffSetBased then return end

    local closestPlayerToMouse = getNearestPlayerToMouse()
    local calculatedRoute = CalculateRouteOfPlayer(closestPlayerToMouse)
    
    local offsets = {
        LeftRight = {
            Dime = {x = 0.28, z = 0.25},
            Dive = {x = 0.45, z = 0.35}
        },
        Forward = {
            Dime = {x = 0.27, z = 0.35}
        },
        Backward = {
            Dime = {x = 0.015, z = 0.2}
        }
    }

    local routeOffsets = offsets[route]
    if routeOffsets then
        local throwOffsets = routeOffsets[throwType]
        if throwOffsets then
            return throwOffsets.x, throwOffsets.z
        end
    end

    return 0, 0
end

local function predictLand(velocity, gravity, start, power, timeOfFlight) -- Importante
    local vel = power * velocity
    return start + vel * timeOfFlight + 0.5 * gravity * timeOfFlight * timeOfFlight
end

--// HIGHLIGHT FUNCTIONS //--

local Highlight = Instance.new("Highlight")
Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop

local function updateHighlight(nearest)
    if not nearest then
        Highlight.Parent = nil
        return
    end

    local isBot = nearest.Name == "bot 1" or nearest.Name == "bot 3"
    local targetPart

    if isBot then
        targetPart = nearest:FindFirstChild("HumanoidRootPart")
        Highlight.Parent = nearest
    else
        local character = nearest.Character
        targetPart = character and character:FindFirstChild("HumanoidRootPart")
        if targetPart then
            Highlight.Parent = targetPart
        else
            Highlight.Parent = nil
        end
    end

    if targetPart then
        Highlight.Adornee = isBot and nearest or nearest.Character
    else
        Highlight.Parent = nil
    end
end
							
--// INTERCEPTABLE FUNCTION //--

local function getPeopleGuardingClosestToMouse(WR)
    local ClosestCB, MaxDistance = nil, math.huge

    local function checkPlayer(CB)
        if CB ~= WR and CB ~= Player and CB:IsA("Player") and CB.Character then
            local wrRoot = WR.Character and WR.Character:FindFirstChild("HumanoidRootPart")
            local cbRoot = CB.Character:FindFirstChild("HumanoidRootPart")
            if wrRoot and cbRoot then
                local dist = (cbRoot.Position - wrRoot.Position).Magnitude
                if dist < MaxDistance then
                    ClosestCB = CB
                    MaxDistance = dist
                end
            end
        end
    end

    if game.PlaceId == 8206123457 then
        for _, CB in ipairs(Players:GetPlayers()) do
            if not (string.find(WR.Name, "bot 1") or string.find(WR.Name, "bot 3")) then
                checkPlayer(CB)
            end
        end
    else
        for _, CB in ipairs(Players:GetPlayers()) do
            if CB.Team ~= Player.Team then
                checkPlayer(CB)
            end
        end
    end

    return ClosestCB
end

local function Interceptable(Corner, LandingPos, t)
    if Corner and Corner.Character then
        local rootPart = Corner.Character:FindFirstChild("HumanoidRootPart")
        local humanoid = Corner.Character:FindFirstChild("Humanoid")
        if rootPart and humanoid then
            local Dist = (rootPart.Position - LandingPos).Magnitude
            local WalkSpeed = humanoid.WalkSpeed
            local DivingTimeAdjustment = 0.31
            local TimeToReach = (Dist / WalkSpeed) - DivingTimeAdjustment
            
            return TimeToReach <= t or Dist == 0
        end
    end
    return false
end

local function getClosestCBtoBot(BotHere)
    if game.PlaceId ~= 8206123457 then return end

    for _, CBBot in ipairs(workspace:GetChildren()) do
        if CBBot.Name == "npcwr" then
            local A, B = CBBot:FindFirstChild("a"), CBBot:FindFirstChild("b")
            if A and B then
                if BotHere.Name == "bot 1" then
                    return A:FindFirstChild("bot 2")
                elseif BotHere.Name == "bot 3" then
                    return B:FindFirstChild("bot 4")
                end
            end
        end
    end
end

local function botInterceptable(Corna, LandingEstimatedPos, t)
    local rootPart = Corna:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    local BotDist = (rootPart.Position - LandingEstimatedPos).Magnitude
    local WalkSpeed = 20
    local DivingTimeAdjustment = 0.31
    local TimeToReach = (BotDist / WalkSpeed) - DivingTimeAdjustment

    return TimeToReach <= t or BotDist == 0
end

--// CATCHABLE FUNCTIONS //--
local function Catchable(wr, LandingPos, TimeOfProjectileFlight)
    if not (wr and wr.Character) then return false end
    
    local rootPart = wr.Character:FindFirstChild("HumanoidRootPart")
    local humanoid = wr.Character:FindFirstChild("Humanoid")
    if not (rootPart and humanoid) then return false end

    local Dist = (rootPart.Position - LandingPos).Magnitude
    local WalkSpeed = humanoid.WalkSpeed
    local DivingTimeAdjustment = 0.31
    local TimeToReach = (Dist / WalkSpeed) - DivingTimeAdjustment

    return TimeToReach <= TimeOfProjectileFlight or Dist == 0
end

local function botCatchable(Wr, LandingEstimatedPos)
    local rootPart = Wr:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end

    local BotDist = (rootPart.Position - LandingEstimatedPos).Magnitude
    local CatchThreshold = BotDist * 0.3  -- 30% of the distance

    return BotDist <= CatchThreshold or BotDist == 0
end

local function GetTargetPositionForWR(Time, WideReceiver)
    if WideReceiver.Character and WideReceiver.Character:FindFirstChild("HumanoidRootPart") then
        local WRMovingVelocity = WideReceiver.Character:FindFirstChild("Humanoid").MoveDirection
        local TypeThrow = getThrowType()
        
        local fieldOrientation = getFieldOrientation(Player.Character:FindFirstChild("HumanoidRootPart").Position, WRMovingVelocity)
        local LeadNumtab = {
            moving = {
                [1] = {
                    Dime = Vector3.new(1, 1.65, 9),   
                    Mag = Vector3.new(2, 2, 11),
                    Dive = Vector3.new(1.25, 1.86, 9.5),
                    Dot = Vector3.new(1, 1.2, 7),
                    Fade = Vector3.new(0, 0, 0),
                    Bullet = Vector3.new(5, 1, 1),
                    Jump = Vector3.new(1, 2.25, 7.5)
                },
                [-1] = {
                    Dime = Vector3.new(1, 1.65, -9),   
                    Mag = Vector3.new(2, 2, -11),
                    Dive = Vector3.new(1.25, 1.86, -9.5),
                    Dot = Vector3.new(1, 1.2, -7),
                    Fade = Vector3.new(0, 0, 0),
                    Bullet = Vector3.new(-5, 1, -1),
                    Jump = Vector3.new(1, 2.25, -7.5)
                }
            },
            still = {
                Dime = Vector3.new(0, 0, 0),   
                Mag = Vector3.new(0, 0, 0),
                Dive = Vector3.new(0, 0, 0),
                Dot = Vector3.new(0, 0, 0),
                Fade = Vector3.new(0, 0, 0),
                Bullet = Vector3.new(0, 0, 0),
                Jump = Vector3.new(0, 5, 0)
            }
        }

        local throwTypeMultipliers = {
            Dot = 17.5,
            Bullet = 20.02,
            Jump = 18.5,
            Dime = 18.9,
            Dive = 19.3,
            Mag = 19.7,
            Fade = 0
        }

        local ThrowTypeAccountability = WRMovingVelocity * (throwTypeMultipliers[TypeThrow] or 0) * Time
        if TypeThrow == "Bullet" then
            ThrowTypeAccountability = Vector3.new(ThrowTypeAccountability.X, 0, ThrowTypeAccountability.Z)
        end

        local Equation
        if isMoving(WideReceiver) then
            local leadOffset = LeadNumtab.moving[fieldOrientation][TypeThrow]
            Equation = WideReceiver.Character.Head.Position + ThrowTypeAccountability + leadOffset
        elseif not isMoving(WideReceiver) and TypeThrow == "Jump" then
            Equation = WideReceiver.Character.Head.Position + ThrowTypeAccountability + Vector3.new(0, 6, 0)
        else
            Equation = WideReceiver.Character.Head.Position 
        end

        return Equation
    else
        warn("Wide Receiver or HumanoidRootPart not found")
        return Vector3.new(0, 0, 0)
    end
end

local Data = {
    Direction = Vector3.new(0, 0, 0),
    NormalPower = 55,		
    BulletModeAngle = 5,
    FadeModeAngle = 55,
    LowestPower = 40,
    MaxPower = 95,
    Angle = 45,
    MaxAngle = 55,
    LowestAngle = 10
}

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if AutoAngle or gameProcessedEvent then return end
    
    local throwType = getThrowType()
    local angleData = {
        Bullet = {field = "BulletModeAngle", min = 5, max = 20},
        Fade = {field = "FadeModeAngle", min = 55, max = 75},
        Default = {field = "Angle", min = 10, max = 55}
    }
    
    local angleInfo = angleData[throwType] or angleData.Default
    local currentAngle = Data[angleInfo.field]
    
    if input.KeyCode == Enum.KeyCode.R and currentAngle < angleInfo.max then
        Data[angleInfo.field] = currentAngle + 5
    elseif input.KeyCode == Enum.KeyCode.F and currentAngle > angleInfo.min then
        Data[angleInfo.field] = currentAngle - 5
    elseif input.KeyCode == Enum.KeyCode.R and currentAngle == angleInfo.max then
        warn(string.format("Cannot increase angle any more, Max Angle is %d", angleInfo.max))
    elseif input.KeyCode == Enum.KeyCode.F and currentAngle == angleInfo.min then
        warn(string.format("Cannot decrease angle any more, Lowest Angle is %d", angleInfo.min))
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if AutoPower or gameProcessedEvent then return end
    
    if input.KeyCode == Enum.KeyCode.Z and Data.NormalPower < Data.MaxPower then
        Data.NormalPower = Data.NormalPower + 5
    elseif input.KeyCode == Enum.KeyCode.X and Data.NormalPower > Data.LowestPower then
        Data.NormalPower = Data.NormalPower - 5
    elseif input.KeyCode == Enum.KeyCode.Z and Data.NormalPower == Data.MaxPower then
        warn("Max Power, Cannot Adjust Any Higher")
    elseif input.KeyCode == Enum.KeyCode.X and Data.NormalPower == Data.LowestPower then
        warn("Lowest Possible Power, Cannot Adjust Any Lower")
    end
end)

local ThrowingTab = {
    Direction = Vector3.new(0, 0, 0)
}

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.Q and not gameProcessedEvent then
        local nearestPlayer = getNearestPlayerToMouse()
        if nearestPlayer then
            IsLocked = not IsLocked
            if IsLocked then
                LockedPlayer = nearestPlayer
            else
                LockedPlayer = nil
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.UserInputType == Enum.UserInputType.MouseButton1 and not gameProcessedEvent then
        if not Character then print("Character not found.") return end
        
        local Football = Character:FindFirstChildOfClass("Tool")
        if not Football then print("No Tool found in character.") return end
        
        if not IsAimbotActive then print("Aimbot not active") return end

        local start = Player.Character:FindFirstChild("Head").Position
        
        ClosestPlayer = IsLocked and LockedPlayer or getNearestPlayerToMouse()
        if not ClosestPlayer then print("No target found.") return end
        
        local Throwtype = getThrowType()
        local Initial = AutoPower and 95 or Data.NormalPower
        
        local WhichOne2 = Throwtype == "Fade" and Data.FadeModeAngle or
                          Throwtype == "Bullet" and Data.BulletModeAngle or
                          Data.Angle
        
        local toLaunchAngle
        if AutoAngle then
            if Throwtype == "Fade" then
                toLaunchAngle = math.rad(75)
            elseif Throwtype == "Bullet" then
                toLaunchAngle = clampNumber(CalculateHighSpeedLowAngle(GRAVITY, Initial), 0, 0.296706)
            else
                toLaunchAngle = clampNumber(CalculateLaunchAngle(GRAVITY, Initial), 0, 0.975)
            end
        else
            toLaunchAngle = math.rad(WhichOne2)
        end
        
        local TOF = GetTimeOfFlightProjectile(Initial, toLaunchAngle, GRAVITY)
        local YesEnd = string.find(ClosestPlayer.Name, "bot [13]") and BotEstimatedVel(TOF, ClosestPlayer) or GetTargetPositionForWR(TOF, ClosestPlayer)
        
        local vel, toThrowToDirection, pow = CalculateVelocityToReachPosition(start, YesEnd, Vector3.new(0, -GRAVITY, 0), TOF)
                
        local PowerSir
        if AutoPower then
            PowerSir = Throwtype == "Fade" and 95 or
                       Throwtype == "Bullet" and clampNumber(pow, 90, 95) or
                       pow
        else
            PowerSir = Data.NormalPower
        end
        
        local neworigin = start + (ThrowingTab.Direction * 5)
        local throwingpar = Instance.new("Part")
        throwingpar.Size = Vector3.new(2, 2, 2)
        throwingpar.Color = Color3.fromRGB(255, 165, 0)

        local RemoteEvent = Football.Handle:FindFirstChild("RemoteEvent")
        if RemoteEvent then
            local ThrowAnimation = Character.Humanoid:LoadAnimation(game:GetService("ReplicatedStorage").Animations.Throw)
            ThrowAnimation.Name = "Throw"
            ThrowAnimation:Play()
            RemoteEvent:FireServer("Clicked", start, neworigin + ThrowingTab.Direction * 10000, (game.PlaceId == 8206123457 and PowerSir) or 95, PowerSir)
            throwingpar.Parent = workspace
            throwingpar.Velocity = vel
            task.wait(TOF)
            throwingpar:Destroy()
        else
            warn("RemoteEvent not found on Football's Handle")
        end
    end
end)

local TargetPosition
local PredictedRoute

Character.ChildAdded:Connect(function(v)
    if v.Name == "Football" and Character then
        local handle = v:FindFirstChild("Handle")
        if handle then
            local localScript = handle:FindFirstChild("LocalScript")
            if localScript then
                localScript:Destroy()
            end
        end
    end
end)

task.spawn(function()
    RunService.Heartbeat:Connect(function()
		if not IsAimbotActive then return end

        task.wait()
        
        if not IsLocked then
            ClosestPlayer = getNearestPlayerToMouse()
        end
        
        if not (Player.Character and Player.Character:FindFirstChild("Football") and ClosestPlayer) then
            ScreenGui.Enabled = false
            Highlight.Enabled = false
            if trc then trc.Visible = false end
            return
        end
        
        if trc then trc.Visible = true end
        local Throwtype = getThrowType()
        
        Highlight.Enabled = true
        Highlight.OutlineTransparency = 0
        Highlight.FillColor = Color3.new(0.5098, 0.5098, 0.7059)
        Highlight.OutlineColor = Color3.new(0, 0, 0)
        
        local isBot = string.find(ClosestPlayer.Name, "bot [13]")
        PredictedRoute = isBot and "Straight" or CalculateRouteOfPlayer(ClosestPlayer)
        
        Highlight.Parent = isBot and ClosestPlayer or ClosestPlayer.Character
        ScreenGui.Enabled = true
        
        local WhichOne = Throwtype == "Fade" and Data.FadeModeAngle or
                         Throwtype == "Bullet" and Data.BulletModeAngle or
                         Data.Angle

        local GRAVITY = 28
        local Start = Player.Character:FindFirstChild("Head").Position
        local Initial = AutoPower and 95 or Data.NormalPower
        
        local LaunchAngle
        if AutoAngle then
            if Throwtype == "Fade" then
                LaunchAngle = math.rad(75)
            elseif Throwtype == "Bullet" then
                LaunchAngle = clampNumber(CalculateHighSpeedLowAngle(GRAVITY, Initial), 0, 0.296706)
            else
                LaunchAngle = clampNumber(CalculateLaunchAngle(GRAVITY, Initial), 0, 0.975)
            end
        else
            LaunchAngle = math.rad(WhichOne)
        end
        
        local TOF = GetTimeOfFlightProjectile(Initial, LaunchAngle, GRAVITY)
        TargetPosition = isBot and BotEstimatedVel(TOF, ClosestPlayer) or GetTargetPositionForWR(TOF, ClosestPlayer)
        
        local velocity, direction, power = CalculateVelocityToReachPosition(Start, TargetPosition, Vector3.new(0, -GRAVITY, 0), TOF)
		Initial = power
        local POWAA = AutoPower and (Throwtype == "Fade" and 95 or Throwtype == "Bullet" and clampNumber(power, 90, 95) or power) or Data.NormalPower
                
        if isVector3Valid(direction) and isVector3Valid(TargetPosition) then
            ThrowingTab.Direction = direction
            
            local startAdjusted = Start + (ThrowingTab.Direction * 5)
            
            local curve0, curve1, cf0, cf1 = beamProjectile(Vector3.new(0, -GRAVITY, 0), POWAA * direction, startAdjusted, TOF)
            
			if beam and beam.Attachment0 and beam.Attachment1 then
				beam.CurveSize0, beam.CurveSize1 = curve0, curve1
				beam.Attachment0.CFrame = beam.Attachment0.Parent.CFrame:inverse() * cf0
				beam.Attachment1.CFrame = beam.Attachment1.Parent.CFrame:inverse() * cf1
				beam.Width0, beam.Width1 = 0.5, 0.5
				
				local sum = (beam.Attachment1.CFrame - beam.Attachment1.Position):Inverse()
				if targetVisual and targetVisual.Parent then
					targetVisual.CFrame = beam.Attachment1.CFrame * sum * CFrame.Angles(math.rad(0), 0, 0)
					
					local CamPo, OnScren = isVisandPos(targetVisual.Position)
					local CamPo2, OnS = isVisandPos(beam.Attachment0.Position)
					if OnScren and OnS and trc then
						trc.From = Vector2.new(CamPo2.X, CamPo2.Y)
						trc.To = Vector2.new(CamPo.X, CamPo.Y)
					end
				end
			end
			
			if Playerrr then Playerrr.Text = ClosestPlayer and ClosestPlayer.Name or "" end
			if PowerNumber then PowerNumber.Text = tostring(math.floor(POWAA * 2 + 0.5) / 2) end
			if RouteOK then RouteOK.Text = PredictedRoute or "" end
			
			local interceptor = isBot and getClosestCBtoBot(ClosestPlayer) or getPeopleGuardingClosestToMouse(ClosestPlayer)
			if Intable and targetVisual and targetVisual.Parent then
				Intable.Text = (isBot and botInterceptable or Interceptable)(interceptor, targetVisual.Position, TOF) and "Yes" or "No"
			end
			
            local catcher = getNearestPlayerToMouse()
			if Intable_2 and targetVisual and targetVisual.Parent then
				local catcher = getNearestPlayerToMouse()
				if catcher then
					local catcherFunction = isBot and botCatchable or Catchable
					Intable_2.Text = catcherFunction(catcher, targetVisual.Position, TOF) and "Yes" or "No"
				else
					Intable_2.Text = "N/A"
				end
			else
				if Intable_2 then
					Intable_2.Text = "N/A"
				end
			end            
            AirTimeTEXT.Text = tostring(RoundToHundredths(TOF)).."s"
            
            AngleNumber.Text = AutoAngle and (Throwtype == "Fade" and "75" or tostring(math.floor(math.deg(LaunchAngle) * 2 + 0.5) / 2)) or tostring(WhichOne)
        end
    end)
end)

task.spawn(function()
    while not state do
        task.wait()
        ScreenGui.Enabled = false
        if beam then
            beam.Width0, beam.Width1 = 0, 0
        end
    end
end)

local function magBall(ball)
    if not (ball and Player.Character) then return end
    
    local leftArm = Player.Character:FindFirstChild("Left Arm")
    local rightArm = Player.Character:FindFirstChild("Right Arm")
    
    if leftArm and rightArm then
        local function touchBall(arm, part, toggle)
            firetouchinterest(arm, part, toggle)
        end
        
        touchBall(leftArm, ball, 0)
        touchBall(rightArm, ball, 0)
        task.wait()
        touchBall(leftArm, ball, 1)
        touchBall(rightArm, ball, 1)
    end
end

RunService.Stepped:Connect(function()
    if not Catchy then return end
    
    for _, v in ipairs(workspace:GetChildren()) do
        if v.Name == "Football" and v:IsA("BasePart") then
            local mag = (Player.Character.HumanoidRootPart.Position - v.Position).Magnitude
            if mag <= AUTO_CATCH_RANGE then
                magBall(v)
            end
        end
    end
end)

local hrp = Character:FindFirstChild("HumanoidRootPart")
local max = magRangeS

local function autoCatchBalls()
    while CatchS do
        task.wait()
        for _, child in ipairs(workspace:GetChildren()) do
            if child.Name == "Football" and child:IsA("BasePart") then
                local D = (child.Position - hrp.Position).Magnitude
                if D < max then
                    child.CanCollide = false
                    child.CFrame = hrp.CFrame + Vector3.new(0.5, 0.3, 0.5)
                end
            end
        end
    end
end

local function setCollision(enabled)
    for _, player in ipairs(Players:GetPlayers()) do
        if player and player.Character and player ~= LocalPlayer then
            for _, bodypart in ipairs(player.Character:GetChildren()) do
                if (bodypart:IsA("BasePart") or bodypart:IsA("MeshPart")) and bodypart.CanCollide then
                    bodypart.CanCollide = enabled
                end
            end
        end
    end
end
