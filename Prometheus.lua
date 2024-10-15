local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local Prometheis = {}

local function create(className, properties)
    local instance = Instance.new(className)
    for k, v in pairs(properties) do
        instance[k] = v
    end
    return instance
end

local function shortenKeyName(keyName)
    local shortNames = {
        ["MouseButton1"] = "MB1",
        ["MouseButton2"] = "MB2",
        ["MouseButton3"] = "MB3",
        ["LeftShift"] = "LShift",
        ["RightShift"] = "RShift",
        ["LeftControl"] = "LCtrl",
        ["RightControl"] = "RCtrl",
        ["LeftAlt"] = "LAlt",
        ["RightAlt"] = "RAlt",
    }
    return shortNames[keyName] or keyName
end

function Prometheis.createWindow(title)
    local existingGui = CoreGui:FindFirstChild("Prometheis")
    if existingGui then existingGui:Destroy() end

    local screenGui = create("ScreenGui", {Name = "Prometheis", Parent = CoreGui})
    local mainFrame = create("Frame", {
        Name = "MainFrame",
        Size = UDim2.new(0, 600, 0, 450),
        Position = UDim2.new(0.5, -300, 0.5, -225),
        BackgroundColor3 = Color3.fromRGB(30, 30, 30),
        BorderSizePixel = 0,
        Parent = screenGui
    })

    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = mainFrame})

    local titleBar = create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Parent = mainFrame
    })

    create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = titleBar})

    create("Frame", {
        Name = "BottomCover",
        Size = UDim2.new(1, 0, 0, 10),
        Position = UDim2.new(0, 0, 1, -10),
        BackgroundColor3 = Color3.fromRGB(40, 40, 40),
        BorderSizePixel = 0,
        Parent = titleBar
    })

    create("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 10, 0, 0),
        BackgroundTransparency = 1,
        Text = title,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 22,
        Font = Enum.Font.SourceSansBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = titleBar
    })

    local closeButton = create("TextButton", {
        Name = "CloseButton",
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(1, -35, 0, 5),
        Text = "X",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 1,
        TextSize = 18,
        Font = Enum.Font.SourceSansBold,
        Parent = titleBar
    })

    create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = closeButton})

    closeButton.MouseButton1Click:Connect(function() screenGui:Destroy() end)

    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)

    local tabFrame = create("ScrollingFrame", {
        Name = "TabFrame",
        Size = UDim2.new(0, 150, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundColor3 = Color3.fromRGB(35, 35, 35),
        BorderSizePixel = 0,
        ScrollBarThickness = 1,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = mainFrame
    })

    create("UIPadding", {
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5),
        Parent = tabFrame
    })

    local tabList = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 5),
        Parent = tabFrame
    })

    local function updateTabFrameCanvasSize()
        tabFrame.CanvasSize = UDim2.new(0, 0, 0, tabList.AbsoluteContentSize.Y + 10)
    end

    tabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateTabFrameCanvasSize)

    local contentFrame = create("Frame", {
        Name = "ContentFrame",
        Size = UDim2.new(1, -150, 1, -40),
        Position = UDim2.new(0, 150, 0, 40),
        BackgroundColor3 = Color3.fromRGB(25, 25, 25),
        BorderSizePixel = 0,
        Parent = mainFrame
    })

    local tabs = {}
    local selectedTab = nil

    local notificationFrame = create("Frame", {
        Name = "NotificationFrame",
        Size = UDim2.new(0, 250, 1, -20),
        Position = UDim2.new(1, -10, 1, -10),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundTransparency = 1,
        Parent = screenGui
    })

    local notificationList = create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 5),
        Parent = notificationFrame
    })

    local activeNotifications = {}

    local function notify(message, notificationType, duration)
        if #activeNotifications >= 6 then
            local oldestNotification = table.remove(activeNotifications, 1)
            oldestNotification.instance:Destroy()
        end
    
        local notificationColors = {
            Info = Color3.fromRGB(0, 120, 215),
            Warning = Color3.fromRGB(255, 140, 0),
            Error = Color3.fromRGB(215, 0, 0)
        }
    
        local notificationIcons = {
            Info = "rbxassetid://6031071053",
            Warning = "rbxassetid://6031071057",
            Error = "rbxassetid://11401835376"
        }
    
        local notification = create("Frame", {
            Size = UDim2.new(1, 0, 0, 65),
            BackgroundColor3 = Color3.fromRGB(40, 40, 40),
            BorderSizePixel = 0,
            Parent = notificationFrame
        })
    
        create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = notification})
    
        local iconImage = create("ImageLabel", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(0, 10, 0, 10),
            BackgroundTransparency = 1,
            Image = notificationIcons[notificationType],
            Parent = notification
        })
    
        local titleLabel = create("TextLabel", {
            Size = UDim2.new(1, -70, 0, 20),
            Position = UDim2.new(0, 40, 0, 10),
            BackgroundTransparency = 1,
            Text = notificationType,
            TextColor3 = notificationColors[notificationType],
            TextSize = 16,
            Font = Enum.Font.SourceSansBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notification
        })
    
        local closeButton = create("TextButton", {
            Size = UDim2.new(0, 20, 0, 20),
            Position = UDim2.new(1, -25, 0, 10),
            BackgroundTransparency = 1,
            Text = "×",
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 20,
            Font = Enum.Font.SourceSansBold,
            Parent = notification
        })
    
        local notificationContent = create("Frame", {
            Size = UDim2.new(1, 0, 1, -50),
            Position = UDim2.new(0, 0, 0, 35),
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Parent = notification
        })    
    
        local messageLabel = create("TextLabel", {
            Size = UDim2.new(1, -20, 0, 1000),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = message,
            TextColor3 = Color3.fromRGB(255, 255, 255),
            TextSize = 14,
            Font = Enum.Font.SourceSans,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Top,
            TextWrapped = true,
            Parent = notificationContent
        })    
    
        local textHeight = messageLabel.TextBounds.Y
        local maxNotificationHeight = 140
        local contentHeight = math.min(textHeight, maxNotificationHeight - 50) 
    
        messageLabel.Size = UDim2.new(1, -20, 0, textHeight)
        notificationContent.Size = UDim2.new(1, 0, 0, contentHeight)
        notification.Size = UDim2.new(1, 0, 0, contentHeight + 50)
    
        if textHeight > contentHeight then
            local scrollingFrame = create("ScrollingFrame", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                ScrollBarThickness = 6,
                ScrollBarImageColor3 = Color3.fromRGB(200, 200, 200),
                CanvasSize = UDim2.new(0, 0, 0, textHeight),
                Parent = notificationContent
            })
            messageLabel.Parent = scrollingFrame
        end
    
        local timerBarContainer = create("Frame", {
            Size = UDim2.new(1, -4, 0, 3),
            Position = UDim2.new(0, 2, 1, -8),
            BackgroundColor3 = Color3.fromRGB(30, 30, 30),
            BorderSizePixel = 0,
            Parent = notification
        })
    
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = timerBarContainer})
    
        local timerBar = create("Frame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = notificationColors[notificationType],
            BorderSizePixel = 0,
            Parent = timerBarContainer
        })
    
        create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = timerBar})
    
        notification.Position = UDim2.new(1, 250, 0, 0)
        local appearTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)})
        appearTween:Play()
    
        local timerTween = TweenService:Create(timerBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
        timerTween:Play()
    
        table.insert(activeNotifications, {instance = notification, timerBar = timerBar})
    
        local function removeNotification()
            local disappearTween = TweenService:Create(notification, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(1, 250, 0, 0)})
            disappearTween:Play()
            disappearTween.Completed:Connect(function()
                notification:Destroy()
                for i, v in ipairs(activeNotifications) do
                    if v.instance == notification then
                        table.remove(activeNotifications, i)
                        break
                    end
                end
            end)
        end
    
        closeButton.MouseButton1Click:Connect(removeNotification)
        task.delay(duration, removeNotification)
    end

    local function addTab(tabName)
        local tabButton = create("TextButton", {
            Name = tabName .. "Tab",
            Size = UDim2.new(1, 0, 0, 35),
            BackgroundColor3 = Color3.fromRGB(35, 35, 35),
            BorderSizePixel = 0,
            Text = tabName,
            TextColor3 = Color3.fromRGB(200, 200, 200),
            TextSize = 16,
            Font = Enum.Font.SourceSansBold,
            Parent = tabFrame
        })

        create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = tabButton})

        local activeIndicator = create("Frame", {
            Name = "ActiveIndicator",
            Size = UDim2.new(0, 4, 1, 0),
            Position = UDim2.new(1, -4, 0, 0),
            BackgroundColor3 = Color3.fromRGB(0, 162, 255),
            BorderSizePixel = 0,
            Visible = true,
            Transparency = 1,
            Parent = tabButton
        })

        create("UICorner", {CornerRadius = UDim.new(0, 2), Parent = activeIndicator})

        local tabContent = create("ScrollingFrame", {
            Name = tabName .. "Content",
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Visible = false,
            ScrollBarThickness = 1,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Parent = contentFrame
        })

        create("UIPadding", {
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            Parent = tabContent
        })

        local contentList = create("UIListLayout", {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 10),
            Parent = tabContent
        })

        local function updateCanvasSize()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentList.AbsoluteContentSize.Y + 20)
        end

        contentList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)

        local tab = {button = tabButton, content = tabContent, activeIndicator = activeIndicator}
        table.insert(tabs, tab)

        local function selectTab()
            if selectedTab then
                TweenService:Create(selectedTab.button, TweenInfo.new(0.2), {
                    BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                    TextColor3 = Color3.fromRGB(200, 200, 200)
                }):Play()
                TweenService:Create(selectedTab.activeIndicator, TweenInfo.new(0.2), {Transparency = 1}):Play()
                selectedTab.content.Visible = false
            end

            selectedTab = tab
            TweenService:Create(tabButton, TweenInfo.new(0.2), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            TweenService:Create(activeIndicator, TweenInfo.new(0.2), {Transparency = 0}):Play()
            tabContent.Visible = true
        end

        tabButton.MouseButton1Click:Connect(selectTab)

        if #tabs == 1 then selectTab() end

        updateTabFrameCanvasSize()

        local function addSection(sectionName)
            local sectionFrame = create("Frame", {
                Name = sectionName .. "Section",
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = tabContent
            })

            local sectionLabel = create("TextLabel", {
                Name = sectionName .. "Label",
                Size = UDim2.new(1, 0, 0, 30),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = sectionName,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 18,
                Font = Enum.Font.SourceSansBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sectionFrame
            })

            local sectionContent = create("Frame", {
                Name = sectionName .. "Content",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 0, 30),
                BackgroundTransparency = 1,
                AutomaticSize = Enum.AutomaticSize.Y,
                Parent = sectionFrame,
            })

            local listLayout = create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 5),
                Parent = sectionContent,
                HorizontalAlignment = Enum.HorizontalAlignment.Center
            })

            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y

            return sectionContent
        end

        local function addButton(sectionContent, buttonName, callback)
            local buttonFrame = create("Frame", {
                Name = buttonName .. "Frame",
                Size = UDim2.new(0.95, 0, 0, 30),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Parent = sectionContent
            })

            create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = buttonFrame})

            local buttonLabel = create("TextLabel", {
                Name = buttonName .. "Label",
                Size = UDim2.new(1, -30, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = buttonName,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 15,
                Font = Enum.Font.SourceSansBold,
                TextXAlignment = Enum.TextXAlignment.Center,
                Parent = buttonFrame
            })

            buttonFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    callback()
                end
            end)

            return buttonFrame
        end
        
        local function addToggle(sectionContent, toggleName, defaultState, callback, defaultBind)
            local toggleFrame = create("Frame", {
                Name = toggleName .. "Frame",
                Size = UDim2.new(0.95, 0, 0, 30),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Parent = sectionContent
            })

            create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = toggleFrame})

            local toggleLabel = create("TextLabel", {
                Name = toggleName .. "Label",
                Size = UDim2.new(1, -100, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = toggleName,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 15,
                Font = Enum.Font.SourceSansBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                Parent = toggleFrame
            })

            local bindButton = create("TextButton", {
                Name = "BindButton",
                Size = UDim2.new(0, 60, 1, 0),
                Position = UDim2.new(1, -100, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Text = defaultBind and ("[ " .. shortenKeyName(defaultBind.Name) .. " ]") or "[ ... ]",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 12,
                Font = Enum.Font.Arial,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = toggleFrame
            })

            local toggleIndicator = create("Frame", {
                Name = "Indicator",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundColor3 = Color3.fromRGB(60, 60, 60),
                BorderSizePixel = 0,
                Parent = toggleFrame
            })

            create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = toggleIndicator})

            local toggled = defaultState or false
            local currentBind = defaultBind
            local waitingForBind = false

            local function updateToggleState()
                if toggled then
                    TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(0, 162, 255)}):Play()
                else
                    TweenService:Create(toggleIndicator, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
                end
                callback(toggled)
            end

            local function updateBindText()
                local shortName = currentBind and shortenKeyName(currentBind.Name) or "..."
                bindButton.Text = "[ " .. shortName .. " ]"
            end

            toggleFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggled = not toggled
                    updateToggleState()
                end
            end)

            bindButton.MouseButton1Click:Connect(function()
                waitingForBind = true
                bindButton.Text = "[ ... ]"

                local connection
                connection = UserInputService.InputBegan:Connect(function(input)
                    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                        currentBind = input.KeyCode ~= Enum.KeyCode.Unknown and input.KeyCode or input.UserInputType
                        updateBindText()
                        waitingForBind = false
                        connection:Disconnect()
                    end
                end)
            end)

            UserInputService.InputBegan:Connect(function(input)
                if not waitingForBind and currentBind and 
                   (input.KeyCode == currentBind or input.UserInputType == currentBind) then
                    toggled = not toggled
                    updateToggleState()
                end
            end)

            updateToggleState()

            return function()
                return toggled, currentBind
            end
        end

        local function addSlider(sectionContent, sliderName, minValue, maxValue, defaultValue, callback)
            local sliderFrame = create("Frame", {
                Name = sliderName .. "Frame",
                Size = UDim2.new(0.95, 0, 0, 60),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Parent = sectionContent
            })

            create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = sliderFrame})

            local sliderLabel = create("TextLabel", {
                Name = sliderName .. "Label",
                Size = UDim2.new(1, -110, 0, 30),
                Position = UDim2.new(0, 10, 0, 5),
                BackgroundTransparency = 1,
                Text = sliderName,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 15,
                Font = Enum.Font.SourceSansBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = sliderFrame
            })

            local valueInput = create("TextBox", {
                Name = "ValueInput",
                Size = UDim2.new(0, 80, 0, 30),
                Position = UDim2.new(1, -90, 0, 5),
                BackgroundTransparency = 1,
                Text = tostring(defaultValue),
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 16,
                Font = Enum.Font.SourceSans,
                TextXAlignment = Enum.TextXAlignment.Right,
                Parent = sliderFrame
            })

            local sliderBackground = create("Frame", {
                Name = "SliderBackground",
                Size = UDim2.new(1, -20, 0, 10),
                Position = UDim2.new(0, 10, 1, -20),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                BorderSizePixel = 0,
                Parent = sliderFrame
            })

            create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = sliderBackground})

            local sliderFill = create("Frame", {
                Name = "SliderFill",
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = Color3.fromRGB(0, 162, 255),
                BorderSizePixel = 0,
                Parent = sliderBackground
            })

            create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = sliderFill})

            local function updateSlider(value, shouldTween)
                value = math.clamp(value, minValue, maxValue)
                local percent = (value - minValue) / (maxValue - minValue)
                
                if shouldTween then
                    TweenService:Create(sliderFill, TweenInfo.new(0.2), {Size = UDim2.new(percent, 0, 1, 0)}):Play()
                else
                    sliderFill.Size = UDim2.new(percent, 0, 1, 0)
                end
                
                valueInput.Text = tostring(math.round(value))
                callback(value)
            end

            local dragging = false

            sliderBackground.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local relativeX = (input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X
                    local value = minValue + (maxValue - minValue) * relativeX
                    updateSlider(value, true)
                end
            end)

            sliderBackground.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local relativeX = (input.Position.X - sliderBackground.AbsolutePosition.X) / sliderBackground.AbsoluteSize.X
                    local value = minValue + (maxValue - minValue) * relativeX
                    updateSlider(value, false)
                end
            end)

            valueInput.FocusLost:Connect(function(enterPressed)
                if enterPressed then
                    local inputValue = tonumber(valueInput.Text)
                    if inputValue then
                        updateSlider(inputValue, true)
                    else
                        valueInput.Text = tostring(math.round(minValue + (maxValue - minValue) * sliderFill.Size.X.Scale))
                    end
                end
            end)

            updateSlider(defaultValue, false)

            return function()
                return tonumber(valueInput.Text)
            end
        end

        local function addDropdown(sectionContent, dropdownName, options, defaultOption, callback)
            local dropdownContainer = create("Frame", {
                Name = dropdownName .. "Container",
                Size = UDim2.new(0.95, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = sectionContent,
                ClipsDescendants = false 
            })

            local dropdownFrame = create("Frame", {
                Name = dropdownName .. "Frame",
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Parent = dropdownContainer
            })

            create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = dropdownFrame})

            local dropdownLabel = create("TextLabel", {
                Name = dropdownName .. "Label",
                Size = UDim2.new(0, 0, 1, 0), 
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = dropdownName .. ":",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                Font = Enum.Font.SourceSansBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownFrame,
                AutomaticSize = Enum.AutomaticSize.X
            })

            local selectedOptionLabel = create("TextLabel", {
                Name = "SelectedOptionLabel",
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 0, 0, 0), 
                BackgroundTransparency = 1,
                Text = defaultOption or "Select option",
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 14,
                Font = Enum.Font.SourceSans,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownFrame
            })

            local chevron = create("ImageLabel", {
                Name = "Chevron",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -25, 0.5, -10),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6031094670",
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                Parent = dropdownFrame,
                Rotation = 180
            })

            local optionsFrame = create("Frame", {
                Name = "OptionsFrame",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, -3.2),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                BorderSizePixel = 0,
                Visible = false,
                Parent = dropdownFrame,
                ZIndex = 10,
                ClipsDescendants = true
            })

            create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = optionsFrame})

            local optionsScrollFrame = create("ScrollingFrame", {
                Name = "OptionsScrollFrame",
                Size = UDim2.new(1, -10, 1, -10),
                Position = UDim2.new(0, 5, 0, 5),
                BackgroundTransparency = 1,
                ScrollBarThickness = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Parent = optionsFrame
            })

            local optionsList = create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2),
                Parent = optionsScrollFrame
            })

            create("UIPadding", {
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                Parent = optionsFrame
            })

            local selectedOption = defaultOption
            local isOpen = false

            local function updateDropdown()
                selectedOptionLabel.Text = selectedOption or "Select option"
            end

            local function toggleDropdown()
                isOpen = not isOpen
                local chevronRotation = isOpen and 0 or 180
                local frameSize = isOpen and UDim2.new(1, 0, 0, 85) or UDim2.new(1, 0, 0, 0)
                local containerSize = isOpen 
                    and UDim2.new(0.95, 0, 0, 18 + 85 + 10)
                    or UDim2.new(0.95, 0, 0, 30)
                
                TweenService:Create(chevron, TweenInfo.new(0.2), {Rotation = chevronRotation}):Play()
                local sizeTween = TweenService:Create(optionsFrame, TweenInfo.new(0.2), {Size = frameSize})
                local containerTween = TweenService:Create(dropdownContainer, TweenInfo.new(0.2), {Size = containerSize})
                
                sizeTween:Play()
                containerTween:Play()
            
                if isOpen then
                    optionsFrame.Visible = true
                    optionsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, optionsList.AbsoluteContentSize.Y)
                else
                    sizeTween.Completed:Connect(function()
                        optionsFrame.Visible = false
                    end)
                end
            
                containerTween.Completed:Connect(function()
                    sectionContent.Parent.CanvasSize = UDim2.new(0, 0, 0, 0)
                    sectionContent.Parent.CanvasSize = UDim2.new(0, 0, 0, sectionContent.Parent.UIListLayout.AbsoluteContentSize.Y)
                end)
            end

            dropdownFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggleDropdown()
                end
            end)

            local function addOption(optionName)
                local optionButton = create("TextButton", {
                    Name = optionName .. "Button",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                    BorderSizePixel = 0,
                    Text = optionName,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    Font = Enum.Font.SourceSans,
                    Parent = optionsScrollFrame,
                    ZIndex = 11
                })

                create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = optionButton})

                optionButton.MouseButton1Click:Connect(function()
                    selectedOption = optionName
                    for _, child in pairs(optionsScrollFrame:GetChildren()) do
                        if child:IsA("TextButton") then
                            child.BackgroundColor3 = child == optionButton and Color3.fromRGB(60, 60, 60) or Color3.fromRGB(45, 45, 45)
                        end
                    end
                    toggleDropdown()
                    updateDropdown()
                    callback(selectedOption)
                end)
            end

            for _, option in ipairs(options) do
                addOption(option)
            end

            if defaultOption then
                selectedOption = defaultOption
                local optionButton = optionsScrollFrame:FindFirstChild(defaultOption .. "Button")
                if optionButton then
                    optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                end
                updateDropdown()
            end

            local function updateLabelPositions()
                local labelWidth = dropdownLabel.AbsoluteSize.X
                selectedOptionLabel.Position = UDim2.new(0, labelWidth + 15, 0, 0)
                selectedOptionLabel.Size = UDim2.new(1, -(labelWidth + 40), 1, 0)
            end

            dropdownLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLabelPositions)
            updateLabelPositions()

            return {
                addOption = addOption,
                getSelectedOption = function() return selectedOption end
            }
        end

        local function addMultiDropdown(sectionContent, dropdownName, options, defaultOptions, callback)
            local dropdownContainer = create("Frame", {
                Name = dropdownName .. "Container",
                Size = UDim2.new(0.95, 0, 0, 30),
                BackgroundTransparency = 1,
                Parent = sectionContent,
                ClipsDescendants = false 
            })

            local dropdownFrame = create("Frame", {
                Name = dropdownName .. "Frame",
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Parent = dropdownContainer
            })

            create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = dropdownFrame})

            local dropdownLabel = create("TextLabel", {
                Name = dropdownName .. "Label",
                Size = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = dropdownName .. ":",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 14,
                Font = Enum.Font.SourceSansBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownFrame,
                AutomaticSize = Enum.AutomaticSize.X
            })

            local selectedOptionsLabel = create("TextLabel", {
                Name = "SelectedOptionsLabel",
                Size = UDim2.new(1, -20, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = "Select option(s)",
                TextColor3 = Color3.fromRGB(200, 200, 200),
                TextSize = 14,
                Font = Enum.Font.SourceSans,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = dropdownFrame
            })

            local chevron = create("ImageLabel", {
                Name = "Chevron",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -25, 0.5, -10),
                BackgroundTransparency = 1,
                Image = "rbxassetid://6031094670",
                ImageColor3 = Color3.fromRGB(255, 255, 255),
                Parent = dropdownFrame,
                Rotation = 180
            })

            local optionsFrame = create("Frame", {
                Name = "OptionsFrame",
                Size = UDim2.new(1, 0, 0, 0),
                Position = UDim2.new(0, 0, 1, -3.2),
                BackgroundColor3 = Color3.fromRGB(35, 35, 35),
                BorderSizePixel = 0,
                Visible = false,
                Parent = dropdownFrame,
                ZIndex = 10,
                ClipsDescendants = true
            })

            create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = optionsFrame})

            local optionsScrollFrame = create("ScrollingFrame", {
                Name = "OptionsScrollFrame",
                Size = UDim2.new(1, -10, 1, -10),
                Position = UDim2.new(0, 5, 0, 5),
                BackgroundTransparency = 1,
                ScrollBarThickness = 0,
                CanvasSize = UDim2.new(0, 0, 0, 0),
                Parent = optionsFrame
            })

            local optionsList = create("UIListLayout", {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 2),
                Parent = optionsScrollFrame
            })

            create("UIPadding", {
                PaddingTop = UDim.new(0, 5),
                PaddingBottom = UDim.new(0, 5),
                PaddingLeft = UDim.new(0, 5),
                PaddingRight = UDim.new(0, 5),
                Parent = optionsFrame
            })

            local selectedOptions = defaultOptions or {}
            local isOpen = false

            local function updateDropdown()
                if #selectedOptions > 0 then
                    selectedOptionsLabel.Text = table.concat(selectedOptions, ", ")
                else
                    selectedOptionsLabel.Text = "Select option(s)"
                end
            end

            local function toggleDropdown()
                isOpen = not isOpen
                local chevronRotation = isOpen and 0 or 180
                local frameSize = isOpen and UDim2.new(1, 0, 0, 85) or UDim2.new(1, 0, 0, 0)
                local containerSize = isOpen 
                    and UDim2.new(0.95, 0, 0, 18 + 85 + 10)
                    or UDim2.new(0.95, 0, 0, 30)
                
                TweenService:Create(chevron, TweenInfo.new(0.2), {Rotation = chevronRotation}):Play()
                local sizeTween = TweenService:Create(optionsFrame, TweenInfo.new(0.2), {Size = frameSize})
                local containerTween = TweenService:Create(dropdownContainer, TweenInfo.new(0.2), {Size = containerSize})
                
                sizeTween:Play()
                containerTween:Play()
            
                if isOpen then
                    optionsFrame.Visible = true
                    optionsScrollFrame.CanvasSize = UDim2.new(0, 0, 0, optionsList.AbsoluteContentSize.Y)
                else
                    sizeTween.Completed:Connect(function()
                        optionsFrame.Visible = false
                    end)
                end
            
                containerTween.Completed:Connect(function()
                    sectionContent.Parent.CanvasSize = UDim2.new(0, 0, 0, 0)
                    sectionContent.Parent.CanvasSize = UDim2.new(0, 0, 0, sectionContent.Parent.UIListLayout.AbsoluteContentSize.Y)
                end)
            end

            dropdownFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    toggleDropdown()
                end
            end)

            local function addOption(optionName)
                local optionButton = create("TextButton", {
                    Name = optionName .. "Button",
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundColor3 = Color3.fromRGB(45, 45, 45),
                    BorderSizePixel = 0,
                    Text = optionName,
                    TextColor3 = Color3.fromRGB(255, 255, 255),
                    TextSize = 14,
                    Font = Enum.Font.SourceSans,
                    Parent = optionsScrollFrame,
                    ZIndex = 11
                })

                create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = optionButton})

                optionButton.MouseButton1Click:Connect(function()
                    local index = table.find(selectedOptions, optionName)
                    if index then
                        table.remove(selectedOptions, index)
                        optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                    else
                        table.insert(selectedOptions, optionName)
                        optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                    end
                    updateDropdown()
                    callback(selectedOptions)
                end)

                if table.find(selectedOptions, optionName) then
                    optionButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                end
            end

            for _, option in ipairs(options) do
                addOption(option)
            end

            updateDropdown()

            local function updateLabelPositions()
                local labelWidth = dropdownLabel.AbsoluteSize.X
                selectedOptionsLabel.Position = UDim2.new(0, labelWidth + 15, 0, 0)
                selectedOptionsLabel.Size = UDim2.new(1, -(labelWidth + 40), 1, 0)
            end

            dropdownLabel:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateLabelPositions)
            updateLabelPositions()

            return {
                addOption = addOption,
                getSelectedOptions = function() return selectedOptions end
            }
        end

        local function addColorPicker(sectionContent, colorPickerName, defaultColor, callback)
            local colorPickerFrame = create("Frame", {
                Name = colorPickerName .. "Frame",
                Size = UDim2.new(0.95, 0, 0, 30),
                BackgroundColor3 = Color3.fromRGB(40, 40, 40),
                BorderSizePixel = 0,
                Parent = sectionContent
            })
        
            create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = colorPickerFrame})
        
            local colorPickerLabel = create("TextLabel", {
                Name = colorPickerName .. "Label",
                Size = UDim2.new(1, -40, 1, 0),
                Position = UDim2.new(0, 10, 0, 0),
                BackgroundTransparency = 1,
                Text = colorPickerName,
                TextColor3 = Color3.fromRGB(255, 255, 255),
                TextSize = 15,
                Font = Enum.Font.SourceSansBold,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = colorPickerFrame
            })
        
            local colorDisplay = create("Frame", {
                Name = "ColorDisplay",
                Size = UDim2.new(0, 20, 0, 20),
                Position = UDim2.new(1, -30, 0.5, -10),
                BackgroundColor3 = defaultColor,
                BorderSizePixel = 0,
                Parent = colorPickerFrame
            })
        
            create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = colorDisplay})
        
            local colorPickerContainer = create("Frame", {
                Name = colorPickerName .. "Container",
                Size = UDim2.new(0, 200, 0, 180),
                Position = UDim2.new(1, 10, 0, 0),
                BackgroundColor3 = Color3.fromRGB(30, 30, 30),
                BorderSizePixel = 0,
                Visible = false,
                Parent = contentFrame
            })
        
            create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = colorPickerContainer})
        
            local hsvPicker = create("ImageLabel", {
                Name = "HSVPicker",
                Size = UDim2.new(0, 160, 0, 160),
                Position = UDim2.new(0, 10, 0, 10),
                Image = "rbxassetid://4155801252",
                BackgroundColor3 = Color3.fromRGB(255, 0, 0),
                BorderSizePixel = 0,
                Parent = colorPickerContainer
            })
        
            create("UICorner", {CornerRadius = UDim.new(0, 5), Parent = hsvPicker})
        
            local hsvPickerCursor = create("Frame", {
                Name = "Cursor",
                Size = UDim2.new(0, 10, 0, 10),
                BackgroundColor3 = Color3.new(1, 1, 1),
                BorderSizePixel = 0,
                Parent = hsvPicker
            })
        
            create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = hsvPickerCursor})
        
            local hueSlider = create("Frame", {
                Name = "HueSlider",
                Size = UDim2.new(0, 15, 0, 160),
                Position = UDim2.new(1, -24, 0, 10),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255),
                BorderSizePixel = 0,
                ClipsDescendants = true,
                Parent = colorPickerContainer,
                Rotation = 180
            })
        
            create("UICorner", {CornerRadius = UDim.new(0, 4), Parent = hueSlider})
        
            local hueGradient = create("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                    ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                    ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                    ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                    ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
                }),
                Rotation = 90,
                Parent = hueSlider
            })
        
            local h, s, v = defaultColor:ToHSV()
        
            local function updateColor()
                local color = Color3.fromHSV(h, s, v)
                colorDisplay.BackgroundColor3 = color
                hsvPicker.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                callback(color)
            end
        
            local function updateHueSlider(relativeY)
                h = 1 - relativeY
                updateColor()
            end
        
            local function updateHSVPicker(relativeX, relativeY)
                s = relativeX
                v = 1 - relativeY
                hsvPickerCursor.Position = UDim2.new(relativeX, -5, relativeY, -5)
                updateColor()
            end
        
            local draggingHue = false
            local draggingHSV = false
        
            hueSlider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHue = true
                    local relativeY = math.clamp((input.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
                    updateHueSlider(relativeY)
                end
            end)
        
            hueSlider.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHue = false
                end
            end)
        
            hsvPicker.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHSV = true
                    local relativeX = math.clamp((input.Position.X - hsvPicker.AbsolutePosition.X) / hsvPicker.AbsoluteSize.X, 0, 1)
                    local relativeY = math.clamp((input.Position.Y - hsvPicker.AbsolutePosition.Y) / hsvPicker.AbsoluteSize.Y, 0, 1)
                    updateHSVPicker(relativeX, relativeY)
                end
            end)
        
            hsvPicker.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    draggingHSV = false
                end
            end)
        
            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if draggingHue then
                        local relativeY = math.clamp((input.Position.Y - hueSlider.AbsolutePosition.Y) / hueSlider.AbsoluteSize.Y, 0, 1)
                        updateHueSlider(relativeY)
                    elseif draggingHSV then
                        local relativeX = math.clamp((input.Position.X - hsvPicker.AbsolutePosition.X) / hsvPicker.AbsoluteSize.X, 0, 1)
                        local relativeY = math.clamp((input.Position.Y - hsvPicker.AbsolutePosition.Y) / hsvPicker.AbsoluteSize.Y, 0, 1)
                        updateHSVPicker(relativeX, relativeY)
                    end
                end
            end)
        
            colorPickerFrame.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    colorPickerContainer.Visible = not colorPickerContainer.Visible
                end
            end)
        
            updateHueSlider(1 - h)
            updateHSVPicker(s, 1 - v)
        
            return function()
                return colorDisplay.BackgroundColor3
            end
        end

        return {
            addSection = addSection,
            addButton = addButton,
            addToggle = addToggle,
            addSlider = addSlider,
            addDropdown = addDropdown,
            addMultiDropdown = addMultiDropdown,
            addColorPicker = addColorPicker
        }
    end

    return {
        mainFrame = mainFrame,
        tabFrame = tabFrame,
        contentFrame = contentFrame,
        addTab = addTab,
        selectTab = function(index)
            if tabs[index] then tabs[index].button.MouseButton1Click:Fire() end
        end,
        notify = notify
    }
end

return Prometheis
