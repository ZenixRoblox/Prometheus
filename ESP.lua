local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

print("Starting")

local ESP = {
    Enabled = false,
    BoxesEnabled = true,
    BoxColor = Color3.new(1, 0, 0),
    BoxThickness = 1,
    BoxTransparency = 1,
    MaxDistance = 1000,
    TeamCheck = false,
    ToggleKey = Enum.KeyCode.RightAlt,
    HealthBarEnabled = true,
    HealthBarWidth = 2,
    HealthBarPosition = "Left",
    DistanceLabelEnabled = true,
    DistanceMode = "Absolute", -- Absolute or Relative
    NameLabelEnabled = true,
    NameLabelTransparency = 0.8,
    ChamsEnabled = false,
    ChamsColor = Color3.new(0, 1, 1),
    ChamsTransparency = 0.5,
    ChamsOutlineColor = Color3.new(0, 0, 0),
    ChamsOutlineTransparency = 0.8,
    ChamsUseTeamColor = false,
    ChamsFlashing = false,
    ChamsFlashingSpeed = 1,
    SkeletonEnabled = false,
    SkeletonColor = Color3.new(1, 1, 1),
    SkeletonThickness = 1,
    SkeletonTransparency = 0,
}

local ESPObjects = {}

local function IsOnScreen(position)
    local _, onScreen = Camera:WorldToViewportPoint(position)
    return onScreen
end

local function GetDistanceFromCamera(position)
    return (Camera.CFrame.Position - position).Magnitude
end

local function CreateDrawing(type, properties)
    local obj = Drawing.new(type)
    for prop, value in pairs(properties) do
        obj[prop] = value
    end
    return obj
end

local function DestroyESPObject(espObject)
    for _, drawing in pairs(espObject) do
        if typeof(drawing) == "table" and drawing.Remove then
            drawing:Remove()
        elseif typeof(drawing) == "table" then
            for _, subDrawing in pairs(drawing) do
                if subDrawing.Remove then
                    subDrawing:Remove()
                end
            end
        end
    end
end

local function GetRelativeDistance(distance)
    if distance <= 10 then
        return "Very Close"
    elseif distance <= 50 then
        return "Close"
    elseif distance <= 100 then
        return "Near"
    else
        return "Far"
    end
end

local function CreateSkeleton(player)
    local skeletonParts = {
        Head = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        UpperTorso = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        LowerTorso = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        LeftShoulder = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        RightShoulder = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        LeftUpperArm = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        LeftLowerArm = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        LeftHand = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        RightUpperArm = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        RightLowerArm = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        RightHand = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        LeftUpperLeg = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        LeftLowerLeg = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        LeftFoot = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        RightUpperLeg = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        RightLowerLeg = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        RightFoot = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        -- Additional parts for R6
        Torso = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        LeftArm = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        RightArm = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        LeftLeg = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        RightLeg = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        LeftFoot = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
        RightFoot = CreateDrawing("Line", {
            Thickness = ESP.SkeletonThickness,
            Color = ESP.SkeletonColor,
            Transparency = ESP.SkeletonTransparency,
            Visible = false,
        }),
    }
    return skeletonParts
end

local function CreateESP(player)
    if player == LocalPlayer then return end
    
    local espObject = {
        Player = player,
        Box = CreateDrawing("Square", {
            Thickness = ESP.BoxThickness,
            Color = ESP.BoxColor,
            Transparency = ESP.BoxTransparency,
            Filled = false,
            Visible = false,
            ZIndex = 1
        }),
        HealthBar = CreateDrawing("Line", {
            Thickness = ESP.HealthBarWidth,
            Color = Color3.new(0, 1, 0),
            Transparency = 1,
            Visible = false,
            ZIndex = 2
        }),
        DistanceLabel = CreateDrawing("Text", {
            Font = Drawing.Fonts.UI,
            Size = 14,
            Center = true,
            Outline = true,
            Color = Color3.new(1, 1, 1),
            Transparency = 1,
            Visible = false,
            ZIndex = 3
        }),
        DisplayNameLabel = CreateDrawing("Text", {
            Font = Drawing.Fonts.UI,
            Size = 16,
            Center = true,
            Outline = true,
            Color = Color3.new(1, 1, 1),
            Transparency = ESP.NameLabelTransparency,
            Visible = false,
            ZIndex = 4
        }),
        UsernameLabel = CreateDrawing("Text", {
            Font = Drawing.Fonts.UI,
            Size = 14,
            Center = true,
            Outline = true,
            Color = Color3.new(1, 1, 1),
            Transparency = 1,
            Visible = false,
            ZIndex = 5
        }),
        Skeleton = CreateSkeleton(player)
    }
    
    ESPObjects[player] = espObject
end

local function GetCharacterParts(character)
    if not character then return nil, nil, nil end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return nil, nil, nil end
    
    local root = character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
    if not root then return nil, nil, nil end
    
    local head = character:FindFirstChild("Head")
    if not head then return nil, nil, nil end
    
    return humanoid, root, head
end

local function GetCharacterSize(character)
    local humanoid, root, head = GetCharacterParts(character)
    if not humanoid or not root or not head then return Vector3.new(5, 5, 1) end
    
    local size = root.Size
    local headOffset = head.Size.Y / 2
    
    if humanoid.RigType == Enum.HumanoidRigType.R6 then
        size = Vector3.new(4, 5, 1)  -- Adjusted size for R6 characters
    elseif humanoid.RigType == Enum.HumanoidRigType.R15 then
        local upperTorso = character:FindFirstChild("UpperTorso")
        local lowerTorso = character:FindFirstChild("LowerTorso")
        if upperTorso and lowerTorso then
            size = size + upperTorso.Size + lowerTorso.Size
        end
    end
    
    return Vector3.new(size.X, size.Y + headOffset, size.Z)
end

local function CreateChams(player)
    local character = player.Character
    if not character then return end

    local chamsFolder = CoreGui:FindFirstChild("Chams")
    if not chamsFolder then
        chamsFolder = Instance.new("Folder")
        chamsFolder.Name = "Chams"
        chamsFolder.Parent = CoreGui
    end

    local playerChamsFolder = chamsFolder:FindFirstChild(player.Name)
    if not playerChamsFolder then
        playerChamsFolder = Instance.new("Folder")
        playerChamsFolder.Name = player.Name
        playerChamsFolder.Parent = chamsFolder
    end

    local function createCham(part)
        local cham = Instance.new("BoxHandleAdornment")
        cham.Name = "Cham_" .. part.Name
        cham.Adornee = part
        cham.AlwaysOnTop = true
        cham.ZIndex = 5
        cham.Size = part.Size
        cham.Transparency = ESP.ChamsTransparency
        cham.Color3 = ESP.ChamsColor

        local outline = Instance.new("BoxHandleAdornment")
        outline.Name = "Outline_" .. part.Name
        outline.Adornee = part
        outline.AlwaysOnTop = false
        outline.ZIndex = 4
        outline.Size = part.Size + Vector3.new(0.05, 0.05, 0.05)
        outline.Transparency = ESP.ChamsOutlineTransparency
        outline.Color3 = ESP.ChamsOutlineColor

        cham.Parent = playerChamsFolder
        outline.Parent = playerChamsFolder

        return cham, outline
    end

    local function updateChams()
        for _, existingCham in pairs(playerChamsFolder:GetChildren()) do
            existingCham:Destroy()
        end

        local head = character:FindFirstChild("Head")
        if head then createCham(head) end

        local torso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
        if torso then createCham(torso) end

        local leftArm = character:FindFirstChild("LeftUpperArm") or character:FindFirstChild("Left Arm")
        if leftArm then createCham(leftArm) end

        local rightArm = character:FindFirstChild("RightUpperArm") or character:FindFirstChild("Right Arm")
        if rightArm then createCham(rightArm) end

        local leftLeg = character:FindFirstChild("LeftUpperLeg") or character:FindFirstChild("Left Leg")
        if leftLeg then createCham(leftLeg) end

        local rightLeg = character:FindFirstChild("RightUpperLeg") or character:FindFirstChild("Right Leg")
        if rightLeg then createCham(rightLeg) end

        if character:FindFirstChild("LowerTorso") then
            createCham(character.LowerTorso)
        end
    end

    updateChams()
    character.ChildAdded:Connect(updateChams)
    character.ChildRemoved:Connect(updateChams)

    return playerChamsFolder
end

local function UpdateChams()
    for player, espObject in pairs(ESPObjects) do
        if not player or not player.Parent then
            if espObject.Chams then
                espObject.Chams:Destroy()
                espObject.Chams = nil
            end
            continue
        end

        local character = player.Character
        if not character then
            if espObject.Chams then
                espObject.Chams:Destroy()
                espObject.Chams = nil
            end
            continue
        end

        if not espObject.Chams then
            espObject.Chams = CreateChams(player)
        end

        local chamsVisible = ESP.Enabled and ESP.ChamsEnabled
        if ESP.TeamCheck and player.Team == LocalPlayer.Team then
            chamsVisible = false
        end

        espObject.Chams.Parent = chamsVisible and CoreGui.Chams or nil

        if chamsVisible then
            local chamsColor = ESP.ChamsColor
            if ESP.ChamsUseTeamColor and player.Team then
                chamsColor = player.Team.TeamColor.Color
            end

            if ESP.ChamsFlashing then
                local flashValue = (math.sin(tick() * ESP.ChamsFlashingSpeed * math.pi) + 1) / 2
                chamsColor = chamsColor:Lerp(Color3.new(1, 1, 1), flashValue)
            end

            for _, cham in pairs(espObject.Chams:GetChildren()) do
                if cham.Name:sub(1, 5) == "Cham_" then
                    cham.Color3 = chamsColor
                    cham.Transparency = ESP.ChamsTransparency
                elseif cham.Name:sub(1, 8) == "Outline_" then
                    cham.Color3 = ESP.ChamsOutlineColor
                    cham.Transparency = ESP.ChamsOutlineTransparency
                end
            end
        end
    end
end

local function UpdateESP()
    for player, espObject in pairs(ESPObjects) do
        if not player or not player.Parent then
            DestroyESPObject(espObject)
            ESPObjects[player] = nil
            continue
        end
        
        local character = player.Character
        local humanoid, root, head = GetCharacterParts(character)
        
        if not humanoid or not root or not head then
            espObject.Box.Visible = false
            espObject.HealthBar.Visible = false
            espObject.DistanceLabel.Visible = false
            espObject.DisplayNameLabel.Visible = false
            espObject.UsernameLabel.Visible = false
            continue
        end
        
        local distance = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and 
                         (LocalPlayer.Character.HumanoidRootPart.Position - root.Position).Magnitude or 
                         GetDistanceFromCamera(root.Position)
        
        if distance > ESP.MaxDistance then
            espObject.Box.Visible = false
            espObject.HealthBar.Visible = false
            espObject.DistanceLabel.Visible = false
            espObject.DisplayNameLabel.Visible = false
            espObject.UsernameLabel.Visible = false
            continue
        end
        
        if ESP.TeamCheck and player.Team == LocalPlayer.Team then
            espObject.Box.Visible = false
            espObject.HealthBar.Visible = false
            espObject.DistanceLabel.Visible = false
            espObject.DisplayNameLabel.Visible = false
            espObject.UsernameLabel.Visible = false
            continue
        end
        
        if ESP.Enabled then
            local characterSize = GetCharacterSize(character)
            local topPosition = root.Position + Vector3.new(0, characterSize.Y / 2, 0)
            local bottomPosition = root.Position - Vector3.new(0, characterSize.Y / 2, 0)
            
            local topPoint, topVisible = Camera:WorldToViewportPoint(topPosition)
            local bottomPoint, bottomVisible = Camera:WorldToViewportPoint(bottomPosition)
            
            if topVisible and bottomVisible then
                local boxHeight = math.abs(topPoint.Y - bottomPoint.Y)
                local boxWidth = boxHeight * 0.6
                local boxCenter = Vector2.new((topPoint.X + bottomPoint.X) / 2, (topPoint.Y + bottomPoint.Y) / 2)
                
                if ESP.BoxesEnabled then
                    espObject.Box.Size = Vector2.new(boxWidth, boxHeight)
                    espObject.Box.Position = Vector2.new(boxCenter.X - boxWidth / 2, boxCenter.Y - boxHeight / 2)
                    espObject.Box.Visible = true
                else
                    espObject.Box.Visible = false
                end
                
                if ESP.HealthBarEnabled then
                    local health = humanoid.Health / humanoid.MaxHealth
                    local barHeight = boxHeight * health
                    local barPosition = ESP.HealthBarPosition == "Left" and 
                                        Vector2.new(boxCenter.X - boxWidth / 2 - ESP.HealthBarWidth - 1, boxCenter.Y + boxHeight / 2) or
                                        Vector2.new(boxCenter.X + boxWidth / 2 + 1, boxCenter.Y + boxHeight / 2)
                    
                    espObject.HealthBar.From = barPosition
                    espObject.HealthBar.To = barPosition - Vector2.new(0, barHeight)
                    espObject.HealthBar.Color = Color3.new(1 - health, health, 0)
                    espObject.HealthBar.Visible = true
                else
                    espObject.HealthBar.Visible = false
                end
                
                if ESP.DistanceLabelEnabled then
                    local distanceText = ESP.DistanceMode == "Absolute" and 
                                         string.format("%.1f m", distance) or
                                         GetRelativeDistance(distance)
                    
                    local scaleFactor = math.clamp(boxHeight / 100, 0.5, 1) 
                    espObject.DistanceLabel.Size = 14 * scaleFactor
                    espObject.DistanceLabel.Text = distanceText
                    espObject.DistanceLabel.Position = Vector2.new(boxCenter.X, bottomPoint.Y + 5)
                    espObject.DistanceLabel.Visible = true
                else
                    espObject.DistanceLabel.Visible = false
                end
                
                if ESP.NameLabelEnabled then
                    local scaleFactor = math.clamp(boxHeight / 100, 0.5, 1)
                    
                    espObject.DisplayNameLabel.Size = 16 * scaleFactor
                    espObject.DisplayNameLabel.Text = "@" .. player.DisplayName
                    espObject.DisplayNameLabel.Position = Vector2.new(boxCenter.X, topPoint.Y - 40 * scaleFactor)
                    espObject.DisplayNameLabel.Visible = true
                    
                    espObject.UsernameLabel.Size = 14 * scaleFactor
                    espObject.UsernameLabel.Text = player.Name
                    espObject.UsernameLabel.Position = Vector2.new(boxCenter.X, topPoint.Y - 20 * scaleFactor)
                    espObject.UsernameLabel.Visible = true
                else
                    espObject.DisplayNameLabel.Visible = false
                    espObject.UsernameLabel.Visible = false
                end
            else
                espObject.Box.Visible = false
                espObject.HealthBar.Visible = false
                espObject.DistanceLabel.Visible = false
                espObject.DisplayNameLabel.Visible = false
                espObject.UsernameLabel.Visible = false
            end

            if ESP.ChamsEnabled then
                if not espObject.Chams then
                    espObject.Chams = CreateChams(player)
                end
                espObject.Chams.Parent = CoreGui
            elseif espObject.Chams then
                espObject.Chams.Parent = nil
            end
        else
            espObject.Box.Visible = false
            espObject.HealthBar.Visible = false
            espObject.DistanceLabel.Visible = false
            espObject.DisplayNameLabel.Visible = false
            espObject.UsernameLabel.Visible = false

            if espObject.Chams then
                espObject.Chams.Parent = nil
            end
        end

        if ESP.Enabled and ESP.SkeletonEnabled then
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local function updateBone(bone, part1Name, part2Name)
                        local part1 = character:FindFirstChild(part1Name)
                        local part2 = character:FindFirstChild(part2Name)
                        if part1 and part2 then
                            local p1 = Camera:WorldToViewportPoint(part1.Position)
                            local p2 = Camera:WorldToViewportPoint(part2.Position)
                            bone.From = Vector2.new(p1.X, p1.Y)
                            bone.To = Vector2.new(p2.X, p2.Y)
                            bone.Visible = p1.Z > 0 and p2.Z > 0
                        else
                            bone.Visible = false
                        end
                    end

                    if humanoid.RigType == Enum.HumanoidRigType.R15 then
                        updateBone(espObject.Skeleton.Head, "Head", "UpperTorso")
                        updateBone(espObject.Skeleton.UpperTorso, "UpperTorso", "LowerTorso")
                        updateBone(espObject.Skeleton.LowerTorso, "LowerTorso", "HumanoidRootPart")
                        
                        -- Left Arm with Shoulder
                        updateBone(espObject.Skeleton.LeftShoulder, "LeftUpperArm", "UpperTorso")
                        updateBone(espObject.Skeleton.LeftUpperArm, "LeftUpperArm", "LeftLowerArm")
                        updateBone(espObject.Skeleton.LeftLowerArm, "LeftLowerArm", "LeftHand")
                        updateBone(espObject.Skeleton.LeftHand, "LeftHand", "LeftHand")
                        
                        -- Right Arm with Shoulder
                        updateBone(espObject.Skeleton.RightShoulder, "RightUpperArm", "UpperTorso")
                        updateBone(espObject.Skeleton.RightUpperArm, "RightUpperArm", "RightLowerArm")
                        updateBone(espObject.Skeleton.RightLowerArm, "RightLowerArm", "RightHand")
                        updateBone(espObject.Skeleton.RightHand, "RightHand", "RightHand")
                        
                        -- Left Leg connected to LowerTorso
                        updateBone(espObject.Skeleton.LeftUpperLeg, "LeftUpperLeg", "LowerTorso")
                        updateBone(espObject.Skeleton.LeftLowerLeg, "LeftUpperLeg", "LeftLowerLeg")
                        updateBone(espObject.Skeleton.LeftFoot, "LeftLowerLeg", "LeftFoot")
                        
                        -- Right Leg connected to LowerTorso
                        updateBone(espObject.Skeleton.RightUpperLeg, "RightUpperLeg", "LowerTorso")
                        updateBone(espObject.Skeleton.RightLowerLeg, "RightUpperLeg", "RightLowerLeg")
                        updateBone(espObject.Skeleton.RightFoot, "RightLowerLeg", "RightFoot")
                    else -- R6
                        updateBone(espObject.Skeleton.Head, "Head", "Torso")
                        updateBone(espObject.Skeleton.Torso, "Torso", "Torso")
                        
                        -- Left Arm from hand to shoulder
                        updateBone(espObject.Skeleton.LeftArm, "Left Arm", "Torso")
                        updateBone(espObject.Skeleton.LeftHand, "Left Arm", "Left Arm")
                        
                        -- Right Arm from hand to shoulder
                        updateBone(espObject.Skeleton.RightArm, "Right Arm", "Torso")
                        updateBone(espObject.Skeleton.RightHand, "Right Arm", "Right Arm")
                        
                        -- Left Leg from foot to hip
                        updateBone(espObject.Skeleton.LeftLeg, "Left Leg", "Torso")
                        updateBone(espObject.Skeleton.LeftFoot, "Left Leg", "Left Leg")
                        
                        -- Right Leg from foot to hip
                        updateBone(espObject.Skeleton.RightLeg, "Right Leg", "Torso")
                        updateBone(espObject.Skeleton.RightFoot, "Right Leg", "Right Leg")
                    end
                end
            end
        else
            for _, bone in pairs(espObject.Skeleton) do
                bone.Visible = false
            end
        end
    end

    UpdateChams()
end

local function OnPlayerAdded(player)
    CreateESP(player)
end

local function OnPlayerRemoving(player)
    if ESPObjects[player] then
        DestroyESPObject(ESPObjects[player])
        ESPObjects[player] = nil
    end
    
    local chamsFolder = CoreGui:FindFirstChild("Chams")
    if chamsFolder then
        local playerChamsFolder = chamsFolder:FindFirstChild(player.Name)
        if playerChamsFolder then
            playerChamsFolder:Destroy()
        end
    end
end

local function InitializeESP()
    for _, player in ipairs(Players:GetPlayers()) do
        OnPlayerAdded(player)
    end
    
    Players.PlayerAdded:Connect(OnPlayerAdded)
    Players.PlayerRemoving:Connect(OnPlayerRemoving)
    
    RunService:BindToRenderStep("ESP", Enum.RenderPriority.Camera.Value, UpdateESP)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == ESP.ToggleKey then
            ESP.Enabled = not ESP.Enabled
        end
    end)
end

local function CleanupESP()
    RunService:UnbindFromRenderStep("ESP")
    
    for _, espObject in pairs(ESPObjects) do
        DestroyESPObject(espObject)
    end
    
    ESPObjects = {}
    
    local chamsFolder = CoreGui:FindFirstChild("Chams")
    if chamsFolder then
        chamsFolder:Destroy()
    end
    
    local success, error = pcall(function()
        for _, object in ipairs(CoreGui.Drawing:GetChildren()) do
            if object then
                object:Remove()
            end
        end
    end)
    
    if not success then
        warn("Error while cleaning up Drawing objects:", error)
    end
end

local function OnGuiRemoved(descendant)
    if descendant:IsA("ScreenGui") and descendant.Name:find("Prometheus") then
        CleanupESP()
    end
end

CoreGui.ChildRemoved:Connect(OnGuiRemoved)

LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.Started then
        CleanupESP()
    end
end)

local Prometheus = loadstring(game:HttpGet("https://pastebin.com/raw/R9Zivr7x"))()
local window = Prometheus.createWindow("Enhanced ESP")

local espTab = window.addTab("ESP Settings")
local espSection = espTab.addSection("ESP Controls")

espTab.addToggle(espSection, "Enable ESP", false, function(toggled)
    ESP.Enabled = toggled
end)

espTab.addToggle(espSection, "Enable Box", true, function(toggled)
    ESP.BoxesEnabled = toggled
end)

espTab.addToggle(espSection, "Team Check", false, function(toggled)
    ESP.TeamCheck = toggled
end)

espTab.addSlider(espSection, "Max Distance", 100, 2000, 1000, function(value)
    ESP.MaxDistance = value
end)

espTab.addColorPicker(espSection, "Box Color", Color3.new(1, 0, 0), function(color)
    ESP.BoxColor = color
    for _, espObject in pairs(ESPObjects) do
        espObject.Box.Color = color
    end
end)

espTab.addToggle(espSection, "Enable Health Bar", true, function(toggled)
    ESP.HealthBarEnabled = toggled
end)

espTab.addDropdown(espSection, "Health Bar Position", {"Left", "Right"}, "Left", function(option)
    ESP.HealthBarPosition = option
end)

espTab.addToggle(espSection, "Enable Distance Label", true, function(toggled)
    ESP.DistanceLabelEnabled = toggled
end)

espTab.addDropdown(espSection, "Distance Mode", {"Absolute", "Relative"}, "Absolute", function(option)
    ESP.DistanceMode = option
end)

espTab.addToggle(espSection, "Enable Name Labels", true, function(toggled)
    ESP.NameLabelEnabled = toggled
end)

espTab.addSlider(espSection, "Name Label Transparency", 0, 1, 0.8, function(value)
    ESP.NameLabelTransparency = value
    for _, espObject in pairs(ESPObjects) do
        espObject.DisplayNameLabel.Transparency = value
    end
end)

local chamsSection = espTab.addSection("Chams Settings")

espTab.addToggle(chamsSection, "Enable Chams", false, function(toggled)
    ESP.ChamsEnabled = toggled
end)

espTab.addColorPicker(chamsSection, "Chams Color", Color3.new(0, 1, 1), function(color)
    ESP.ChamsColor = color
end)

espTab.addSlider(chamsSection, "Chams Transparency", 0, 1, 0.5, function(value)
    ESP.ChamsTransparency = value
end)

espTab.addColorPicker(chamsSection, "Chams Outline Color", Color3.new(0, 0, 0), function(color)
    ESP.ChamsOutlineColor = color
end)

espTab.addSlider(chamsSection, "Chams Outline Transparency", 0, 1, 0.8, function(value)
    ESP.ChamsOutlineTransparency = value
end)

espTab.addToggle(chamsSection, "Use Team Color", false, function(toggled)
    ESP.ChamsUseTeamColor = toggled
end)

espTab.addToggle(chamsSection, "Flashing Chams", false, function(toggled)
    ESP.ChamsFlashing = toggled
end)

espTab.addSlider(chamsSection, "Flashing Speed", 0.1, 5, 1, function(value)
    ESP.ChamsFlashingSpeed = value
end)

local skeletonSection = espTab.addSection("Skeleton Settings")

espTab.addToggle(skeletonSection, "Enable Skeleton", false, function(toggled)
    ESP.SkeletonEnabled = toggled
end)

espTab.addColorPicker(skeletonSection, "Skeleton Color", Color3.new(1, 1, 1), function(color)
    ESP.SkeletonColor = color
    for _, espObject in pairs(ESPObjects) do
        for _, bone in pairs(espObject.Skeleton) do
            bone.Color = color
        end
    end
end)

espTab.addSlider(skeletonSection, "Skeleton Thickness", 1, 5, 1, function(value)
    ESP.SkeletonThickness = value
    for _, espObject in pairs(ESPObjects) do
        for _, bone in pairs(espObject.Skeleton) do
            bone.Thickness = value
        end
    end
end)

espTab.addSlider(skeletonSection, "Skeleton Transparency", 0, 1, 1, function(value)
    ESP.SkeletonTransparency = value
    for _, espObject in pairs(ESPObjects) do
        for _, bone in pairs(espObject.Skeleton) do
            bone.Transparency = value
        end
    end
end)

InitializeESP()

window.notify("Enhanced ESP loaded successfully!", "Info", 5)
