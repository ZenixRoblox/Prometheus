local b1 = game:GetService("ReplicatedFirst"):FindFirstChild("LocalScript")
if b1 then b1:Destroy() end

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
local AutoAngle = false
local AutoPower = false

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
            ColorSequenceKeypoint.new(0, Color3.new(0.266667, 1.000000, 0.121569)),
            ColorSequenceKeypoint.new(1, Color3.new(0.278431, 0.278431, 0.278431))
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
        landPart.Color = Color3.fromRGB(45, 165, 0)

        IsLocked = false

        trc = Drawing.new("Line")
        trc.Transparency = 0.70
        trc.Thickness = 4.5
        trc.Color = Color3.new(0.109804, 1.000000, 0.152941)

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

local function createCard(title, parent, keybind)
    local card = Instance.new("Frame")
    card.Name = title .. "Card"
    card.Parent = parent
    card.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    card.BorderSizePixel = 0
    card.Size = UDim2.new(0, 140, 0, 70)  -- Increased size

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 12)
    uiCorner.Parent = card

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(80, 80, 80)  -- Greyish color
    uiStroke.Thickness = 2
    uiStroke.Parent = card

    local uiGradient = Instance.new("UIGradient")
    uiGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 60, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(40, 40, 40))
    })
    uiGradient.Rotation = 90
    uiGradient.Parent = card

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Parent = card
    titleLabel.BackgroundTransparency = 1
    titleLabel.Position = UDim2.new(0, 0, 0, 5)
    titleLabel.Size = UDim2.new(1, 0, 0, 20)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.TextSize = 14

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Parent = card
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.new(0, 0, 0, 25)
    valueLabel.Size = UDim2.new(1, 0, 0, 30)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = "0"
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 20
    valueLabel.TextXAlignment = Enum.TextXAlignment.Center

    if keybind then
        local keybindLabel = Instance.new("TextLabel")
        keybindLabel.Name = "Keybind"
        keybindLabel.Parent = card
        keybindLabel.BackgroundTransparency = 1
        keybindLabel.Position = UDim2.new(0, 0, 1, -20)
        keybindLabel.Size = UDim2.new(1, 0, 0, 20)
        keybindLabel.Font = Enum.Font.GothamSemibold
        keybindLabel.Text = keybind
        keybindLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        keybindLabel.TextSize = 12
    end

    return card
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AimbotUI"
ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.AnchorPoint = Vector2.new(0.5, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0, 10)
MainFrame.BackgroundTransparency = 1
MainFrame.Size = UDim2.new(0, 750, 0, 80)

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = MainFrame
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 10)

local PlayerCard = createCard("Player", MainFrame)
local ThrowTypeCard = createCard("Throw Type", MainFrame, "C")
local PowerCard = createCard("Power", MainFrame, "X/Z")
local AngleCard = createCard("Angle", MainFrame, "R/F")
local TimeOfTravelCard = createCard("Time of Travel", MainFrame)

local function updateCardValue(card, value)
    local valueLabel = card:FindFirstChild("Value")
    if valueLabel then
        valueLabel.Text = tostring(value)
    end
end

local function truncateName(name)
    if #name > 9 then
        local player = game.Players:FindFirstChild(name)
        if player and player.DisplayName then
            name = player.DisplayName
        end
        if #name > 9 then
            name = string.sub(name, 1, 9)
        end
    end
    return name
end

local prom = game:GetService("CoreGui"):FindFirstChild("prom")

if prom then
    prom:Destroy()
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
    if window and type(window.getTabValue) == "function" then
        local throwType = window.getTabValue(mainTab, "Throw Type")
        if throwType then
            return throwType
        end
    end
    return "Dime"
end

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if gameProcessedEvent or input.KeyCode ~= Enum.KeyCode.C then return end
    if not Character then return end
    
    local football = Character:FindFirstChild("Football")
    if not football then return end
    
    local throwTypes = {"Dime", "Mag", "Dot", "Dive", "Fade", "Bullet", "Jump"}
    local currentThrowType = getThrowType()
    local currentIndex = table.find(throwTypes, currentThrowType)
    
    if currentIndex then
        local nextIndex = currentIndex % #throwTypes + 1
        local nextThrowType = throwTypes[nextIndex]

        updateCardValue(ThrowTypeCard, nextThrowType)
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

Data = {
    Direction = Vector3.new(0, 0, 0),
    NormalPower = 75,		
    BulletModeAngle = 5,
    FadeModeAngle = 55,
    DimeModeAngle = 45,
    MagModeAngle = 45,
    DiveModeAngle = 45,
    DotModeAngle = 45,
    JumpModeAngle = 45,
    Angle = 45,
    LowestPower = 5,
    MaxPower = 95,
    MaxAngle = 80,
    LowestAngle = 10
}

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if AutoAngle or gameProcessedEvent then return end
    
    local throwType = getThrowType()
    local angleData = {
        Bullet = {field = "BulletModeAngle"},
        Fade = {field = "FadeModeAngle"},
        Dime = {field = "DimeModeAngle"},
        Mag = {field = "MagModeAngle"},
        Dive = {field = "DiveModeAngle"},
        Dot = {field = "DotModeAngle"},
        Jump = {field = "JumpModeAngle"},
        Default = {field = "Angle"}
    }
    
    local angleInfo = angleData[throwType] or angleData.Default
    local currentAngle = Data[angleInfo.field]
    
    if input.KeyCode == Enum.KeyCode.R then
        Data[angleInfo.field] = math.min(currentAngle + 5, 95)
        updateCardValue(AngleCard, Data[angleInfo.field])
    elseif input.KeyCode == Enum.KeyCode.F then
        Data[angleInfo.field] = math.max(currentAngle - 5, 5)
        updateCardValue(AngleCard, Data[angleInfo.field])
    end
    
    if Data[angleInfo.field] == 95 and input.KeyCode == Enum.KeyCode.R then
        warn("Max angle reached (95)")
    elseif Data[angleInfo.field] == 5 and input.KeyCode == Enum.KeyCode.F then
        warn("Min angle reached (5)")
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if AutoPower or gameProcessedEvent then return end
    
    if input.KeyCode == Enum.KeyCode.Z then
        if Data.NormalPower < Data.MaxPower then
            Data.NormalPower = Data.NormalPower + 5
            updateCardValue(PowerCard, Data.NormalPower)
        else
            warn("Max Power, Cannot Adjust Any Higher")
        end
    elseif input.KeyCode == Enum.KeyCode.X then
        if Data.NormalPower > Data.LowestPower then
            Data.NormalPower = Data.NormalPower - 5
            updateCardValue(PowerCard, Data.NormalPower)
        else
            warn("Lowest Possible Power, Cannot Adjust Any Lower")
        end
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
        updateCardValue(TimeOfTravelCard, string.format("%.2f", TOF))
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
        Highlight.FillColor = Color3.fromRGB(0, 255, 0)
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
        updateCardValue(TimeOfTravelCard, string.format("%.2f", TOF))
        TargetPosition = isBot and BotEstimatedVel(TOF, ClosestPlayer) or GetTargetPositionForWR(TOF, ClosestPlayer)
        
        local velocity, direction, power = CalculateVelocityToReachPosition(Start, TargetPosition, Vector3.new(0, -GRAVITY, 0), TOF)
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
            
            updateCardValue(PlayerCard, truncateName(ClosestPlayer and ClosestPlayer.Name or ""))
            updateCardValue(PowerCard, math.floor(POWAA * 2 + 0.5) / 2)
            updateCardValue(AngleCard, AutoAngle and (Throwtype == "Fade" and "75" or tostring(math.floor(math.deg(LaunchAngle) * 2 + 0.5) / 2)) or tostring(WhichOne))
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
