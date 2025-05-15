--[[
    LaunchX UI Library
    Author: Claude
    Version: 1.0.0
    
    A beautiful and elegant UI library for Roblox Luau with modern design elements
]]

local LaunchX = {}
LaunchX.__index = LaunchX

-- Services
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Constants
local PADDING = 10
local CORNER_RADIUS = UDim.new(0, 8)
local DEFAULT_ANIMATION_TIME = 0.3
local DEFAULT_EASING_STYLE = Enum.EasingStyle.Quint
local DEFAULT_EASING_DIRECTION = Enum.EasingDirection.Out

-- Color Theme
LaunchX.Theme = {
    Primary = Color3.fromRGB(0, 120, 215),    -- Blue
    Secondary = Color3.fromRGB(30, 30, 30),   -- Dark gray
    Success = Color3.fromRGB(40, 167, 69),    -- Green
    Danger = Color3.fromRGB(220, 53, 69),     -- Red
    Warning = Color3.fromRGB(255, 193, 7),    -- Yellow
    Info = Color3.fromRGB(23, 162, 184),      -- Cyan
    Light = Color3.fromRGB(240, 240, 240),    -- Light gray
    Dark = Color3.fromRGB(18, 18, 18),        -- Very dark
    TextPrimary = Color3.fromRGB(255, 255, 255), -- White
    TextSecondary = Color3.fromRGB(180, 180, 180), -- Light gray
    Shadow = Color3.fromRGB(0, 0, 0)          -- Black (for shadows)
}

-- Utility Functions

local function Create(instanceType)
    return function(properties)
        local instance = Instance.new(instanceType)
        for k, v in pairs(properties or {}) do
            if k ~= "Parent" then
                instance[k] = v
            end
        end
        if properties.Parent then
            instance.Parent = properties.Parent
        end
        return instance
    end
end

local function ApplyDefaultStyling(frame, cornerRadius)
    local uiCorner = Create("UICorner")({
        CornerRadius = cornerRadius or CORNER_RADIUS,
        Parent = frame
    })
    
    local shadow = Create("ImageLabel")({
        Name = "Shadow",
        BackgroundTransparency = 1,
        Image = "rbxassetid://6014261993",
        ImageColor3 = LaunchX.Theme.Shadow,
        ImageTransparency = 0.5,
        Position = UDim2.new(0, -15, 0, -15),
        Size = UDim2.new(1, 30, 1, 30),
        SliceCenter = Rect.new(49, 49, 450, 450),
        SliceScale = 0.1,
        ZIndex = -1,
        Parent = frame
    })
    
    return frame
end

local function CreateTween(instance, propertyTable, time, easingStyle, easingDirection)
    local tweenInfo = TweenInfo.new(
        time or DEFAULT_ANIMATION_TIME,
        easingStyle or DEFAULT_EASING_STYLE,
        easingDirection or DEFAULT_EASING_DIRECTION
    )
    
    local tween = TweenService:Create(instance, tweenInfo, propertyTable)
    return tween
end

local function Ripple(button, x, y)
    local ripple = Create("Frame")({
        Name = "Ripple",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BackgroundTransparency = 0.7,
        Position = UDim2.new(0, x - 5, 0, y - 5),
        Size = UDim2.new(0, 10, 0, 10),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = button
    })
    
    local corner = Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = ripple
    })
    
    local maxSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2
    
    local expandTween = CreateTween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1
    }, 0.5)
    
    expandTween:Play()
    expandTween.Completed:Connect(function()
        ripple:Destroy()
    end)
end

-- Initialize UI Library
function LaunchX.new(title)
    local self = setmetatable({}, LaunchX)
    
    -- Create ScreenGui
    self.ScreenGui = Create("ScreenGui")({
        Name = "LaunchXUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = game.CoreGui
    })
    
    -- Create Main Container
    self.Container = Create("Frame")({
        Name = "MainContainer",
        BackgroundColor3 = LaunchX.Theme.Secondary,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(0, 500, 0, 350),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = self.ScreenGui
    })
    
    ApplyDefaultStyling(self.Container)
    
    -- Create Title Bar
    self.TitleBar = Create("Frame")({
        Name = "TitleBar",
        BackgroundColor3 = LaunchX.Theme.Primary,
        Size = UDim2.new(1, 0, 0, 36),
        Parent = self.Container
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 8),
        Parent = self.TitleBar
    })
    
    Create("Frame")({
        Name = "Corner",
        BackgroundColor3 = LaunchX.Theme.Primary,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        BorderSizePixel = 0,
        Parent = self.TitleBar
    })
    
    self.TitleLabel = Create("TextLabel")({
        Name = "TitleLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, PADDING, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = title or "LaunchX",
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.TitleBar
    })
    
    -- Close Button
    self.CloseButton = Create("ImageButton")({
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -30, 0, 8),
        Size = UDim2.new(0, 20, 0, 20),
        Image = "rbxassetid://6031094678",
        ImageColor3 = LaunchX.Theme.TextPrimary,
        Parent = self.TitleBar
    })
    
    self.CloseButton.MouseEnter:Connect(function()
        CreateTween(self.CloseButton, {ImageColor3 = LaunchX.Theme.Danger}):Play()
    end)
    
    self.CloseButton.MouseLeave:Connect(function()
        CreateTween(self.CloseButton, {ImageColor3 = LaunchX.Theme.TextPrimary}):Play()
    end)
    
    self.CloseButton.MouseButton1Click:Connect(function()
        CreateTween(self.Container, {Size = UDim2.new(0, self.Container.AbsoluteSize.X, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0), BackgroundTransparency = 1}, 0.3):Play()
        task.wait(0.3)
        self.ScreenGui:Destroy()
    end)
    
    -- Content Container
    self.Content = Create("ScrollingFrame")({
        Name = "Content",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, PADDING, 0, 36 + PADDING),
        Size = UDim2.new(1, -PADDING * 2, 1, -(36 + PADDING * 2)),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = LaunchX.Theme.Primary,
        BottomImage = "rbxassetid://6889812791",
        MidImage = "rbxassetid://6889812721",
        TopImage = "rbxassetid://6889812648",
        CanvasSize = UDim2.new(0, 0, 0, 0),
        BorderSizePixel = 0,
        Parent = self.Container
    })
    
    local uiListLayout = Create("UIListLayout")({
        Padding = UDim.new(0, PADDING),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.Content
    })
    
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        self.Content.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
    end)
    
    -- Make UI Draggable
    local isDragging = false
    local dragInput
    local dragStart
    local startPos
    
    self.TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            startPos = self.Container.Position
        end
    end)
    
    self.TitleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    RunService.RenderStepped:Connect(function()
        if isDragging and dragInput and dragStart then
            local delta = dragInput.Position - dragStart
            self.Container.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    -- UI Entrance Animation
    self.Container.Size = UDim2.new(0, 0, 0, 0)
    self.Container.BackgroundTransparency = 1
    
    CreateTween(self.Container, {
        Size = UDim2.new(0, 500, 0, 350),
        BackgroundTransparency = 0
    }):Play()
    
    return self
end

-- Components

-- Button
function LaunchX:CreateButton(text, callback)
    local button = Create("TextButton")({
        Name = "Button_" .. text,
        BackgroundColor3 = LaunchX.Theme.Primary,
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 14,
        ClipsDescendants = true,
        Parent = self.Content
    })
    
    ApplyDefaultStyling(button)
    
    button.MouseEnter:Connect(function()
        CreateTween(button, {BackgroundColor3 = Color3.fromRGB(
            LaunchX.Theme.Primary.R * 255 + 20,
            LaunchX.Theme.Primary.G * 255 + 20,
            LaunchX.Theme.Primary.B * 255 + 20
        )}):Play()
    end)
    
    button.MouseLeave:Connect(function()
        CreateTween(button, {BackgroundColor3 = LaunchX.Theme.Primary}):Play()
    end)
    
    button.MouseButton1Down:Connect(function()
        CreateTween(button, {BackgroundColor3 = Color3.fromRGB(
            LaunchX.Theme.Primary.R * 255 - 20,
            LaunchX.Theme.Primary.G * 255 - 20,
            LaunchX.Theme.Primary.B * 255 - 20
        )}):Play()
    end)
    
    button.MouseButton1Up:Connect(function()
        CreateTween(button, {BackgroundColor3 = LaunchX.Theme.Primary}):Play()
    end)
    
    button.MouseButton1Click:Connect(function(x, y)
        local buttonAbsolutePosition = button.AbsolutePosition
        local relativeX = x - buttonAbsolutePosition.X
        local relativeY = y - buttonAbsolutePosition.Y
        
        Ripple(button, relativeX, relativeY)
        
        if callback then
            callback()
        end
    end)
    
    return button
end

-- Toggle
function LaunchX:CreateToggle(text, default, callback)
    local toggleContainer = Create("Frame")({
        Name = "ToggleContainer_" .. text,
        BackgroundColor3 = LaunchX.Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.Content
    })
    
    ApplyDefaultStyling(toggleContainer)
    
    local toggleLabel = Create("TextLabel")({
        Name = "ToggleLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, PADDING, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = toggleContainer
    })
    
    local toggleBackground = Create("Frame")({
        Name = "ToggleBackground",
        BackgroundColor3 = default and LaunchX.Theme.Primary or LaunchX.Theme.Dark,
        Position = UDim2.new(1, -50, 0.5, 0),
        Size = UDim2.new(0, 40, 0, 20),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = toggleContainer
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = toggleBackground
    })
    
    local toggleCircle = Create("Frame")({
        Name = "ToggleCircle",
        BackgroundColor3 = LaunchX.Theme.TextPrimary,
        Position = default and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        Size = UDim2.new(0, 16, 0, 16),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = toggleBackground
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = toggleCircle
    })
    
    local toggled = default or false
    
    local function updateToggle()
        toggled = not toggled
        
        local targetPosition = toggled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        local targetColor = toggled and LaunchX.Theme.Primary or LaunchX.Theme.Dark
        
        CreateTween(toggleCircle, {Position = targetPosition}):Play()
        CreateTween(toggleBackground, {BackgroundColor3 = targetColor}):Play()
        
        if callback then
            callback(toggled)
        end
    end
    
    toggleBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateToggle()
        end
    end)
    
    toggleContainer.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            updateToggle()
        end
    end)
    
    return {
        Container = toggleContainer,
        SetValue = function(value)
            if toggled ~= value then
                updateToggle()
            end
        end,
        GetValue = function()
            return toggled
        end
    }
end

-- Slider
function LaunchX:CreateSlider(text, min, max, default, callback)
    min = min or 0
    max = max or 100
    default = default or min
    
    local sliderContainer = Create("Frame")({
        Name = "SliderContainer_" .. text,
        BackgroundColor3 = LaunchX.Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 60),
        Parent = self.Content
    })
    
    ApplyDefaultStyling(sliderContainer)
    
    local sliderLabel = Create("TextLabel")({
        Name = "SliderLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, PADDING, 0, 5),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = sliderContainer
    })
    
    local valueLabel = Create("TextLabel")({
        Name = "ValueLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -50, 0, 5),
        Size = UDim2.new(0, 40, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(default),
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = sliderContainer
    })
    
    local sliderBackground = Create("Frame")({
        Name = "SliderBackground",
        BackgroundColor3 = LaunchX.Theme.Dark,
        Position = UDim2.new(0, PADDING, 0, 35),
        Size = UDim2.new(1, -PADDING*2, 0, 6),
        Parent = sliderContainer
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = sliderBackground
    })
    
    local sliderFill = Create("Frame")({
        Name = "SliderFill",
        BackgroundColor3 = LaunchX.Theme.Primary,
        Size = UDim2.new((default - min) / (max - min), 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = sliderBackground
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = sliderFill
    })
    
    local sliderCircle = Create("Frame")({
        Name = "SliderCircle",
        BackgroundColor3 = LaunchX.Theme.TextPrimary,
        Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0),
        Size = UDim2.new(0, 14, 0, 14),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Parent = sliderBackground
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = sliderCircle
    })
    
    local value = default
    
    local function updateSlider(input)
        local relativeX = math.clamp(input.Position.X - sliderBackground.AbsolutePosition.X, 0, sliderBackground.AbsoluteSize.X)
        local percent = relativeX / sliderBackground.AbsoluteSize.X
        
        value = min + (max - min) * percent
        value = math.floor(value * 10) / 10 -- Round to 1 decimal place
        
        valueLabel.Text = tostring(value)
        sliderFill.Size = UDim2.new(percent, 0, 1, 0)
        sliderCircle.Position = UDim2.new(percent, 0, 0.5, 0)
        
        if callback then
            callback(value)
        end
    end
    
    local isDragging = false
    
    sliderBackground.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateSlider(input)
        end
    end)
    
    sliderBackground.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input)
        end
    end)
    
    return {
        Container = sliderContainer,
        SetValue = function(newValue)
            value = math.clamp(newValue, min, max)
            local percent = (value - min) / (max - min)
            
            valueLabel.Text = tostring(value)
            sliderFill.Size = UDim2.new(percent, 0, 1, 0)
            sliderCircle.Position = UDim2.new(percent, 0, 0.5, 0)
            
            if callback then
                callback(value)
            end
        end,
        GetValue = function()
            return value
        end
    }
end

-- Dropdown
function LaunchX:CreateDropdown(text, options, default, callback)
    options = options or {}
    default = default or options[1]
    
    local dropdownContainer = Create("Frame")({
        Name = "DropdownContainer_" .. text,
        BackgroundColor3 = LaunchX.Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.Content
    })
    
    ApplyDefaultStyling(dropdownContainer)
    
    local dropdownLabel = Create("TextLabel")({
        Name = "DropdownLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, PADDING, 0, 0),
        Size = UDim2.new(1, -20, 0.5, 0),
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = dropdownContainer
    })
    
    local dropdownSelection = Create("TextButton")({
        Name = "DropdownSelection",
        BackgroundColor3 = LaunchX.Theme.Dark,
        Position = UDim2.new(0, PADDING, 0, 20),
        Size = UDim2.new(1, -PADDING*2, 0, 15),
        Font = Enum.Font.GothamSemibold,
        Text = default or "Select...",
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = dropdownContainer
    })
    
    Create("UIPadding")({
        PaddingLeft = UDim.new(0, 5),
        Parent = dropdownSelection
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = dropdownSelection
    })
    
    local dropdownIcon = Create("ImageLabel")({
        Name = "DropdownIcon",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -20, 0, 0),
        Size = UDim2.new(0, 15, 1, 0),
        Image = "rbxassetid://6031091004",
        Rotation = 0,
        ImageColor3 = LaunchX.Theme.TextPrimary,
        Parent = dropdownSelection
    })
    
    local dropdownContent = Create("Frame")({
        Name = "DropdownContent",
        BackgroundColor3 = LaunchX.Theme.Dark,
        Position = UDim2.new(0, PADDING, 1, 5),
        Size = UDim2.new(1, -PADDING*2, 0, 0),
        ClipsDescendants = true,
        Visible = false,
        ZIndex = 5,
        Parent = dropdownContainer
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = dropdownContent
    })
    
    local optionsList = Create("ScrollingFrame")({
        Name = "OptionsList",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = LaunchX.Theme.Primary,
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = dropdownContent
    })
    
    local uiListLayout = Create("UIListLayout")({
        Padding = UDim.new(0, 2),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = optionsList
    })
    
    local selectedOption = default or options[1]
    local isOpen = false
    
    -- Create options
    for i, option in ipairs(options) do
        local optionButton = Create("TextButton")({
            Name = "Option_" .. option,
            BackgroundColor3 = LaunchX.Theme.Dark,
            Size = UDim2.new(1, 0, 0, 25),
            Font = Enum.Font.GothamSemibold,
            Text = option,
            TextColor3 = LaunchX.Theme.TextPrimary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = optionsList
        })
        
        Create("UIPadding")({
            PaddingLeft = UDim.new(0, 5),
            Parent = optionButton
        })
        
        optionButton.MouseEnter:Connect(function()
            CreateTween(optionButton, {BackgroundColor3 = LaunchX.Theme.Primary}):Play()
        end)
        
        optionButton.MouseLeave:Connect(function()
            CreateTween(optionButton, {BackgroundColor3 = LaunchX.Theme.Dark}):Play()
        end)
        
        optionButton.MouseButton1Click:Connect(function()
            selectedOption = option
            dropdownSelection.Text = option
            
            -- Toggle dropdown
            isOpen = false
            CreateTween(dropdownIcon, {Rotation = 0}):Play()
            CreateTween(dropdownContent, {Size = UDim2.new(1, -PADDING*2, 0, 0)}):Play()
            task.wait(0.3)
            dropdownContent.Visible = false
            
            if callback then
                callback(option)
            end
        end)
    end
    
    -- Update canvas size
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        optionsList.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
    end)
    
    dropdownSelection.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            -- Open dropdown
            dropdownContent.Visible = true
            CreateTween(dropdownIcon, {Rotation = 180}):Play()
            local contentHeight = math.min(150, uiListLayout.AbsoluteContentSize.Y)
            CreateTween(dropdownContent, {Size = UDim2.new(1, -PADDING*2, 0, contentHeight)}):Play()
        else
            -- Close dropdown
            CreateTween(dropdownIcon, {Rotation = 0}):Play()
            CreateTween(dropdownContent, {Size = UDim2.new(1, -PADDING*2, 0, 0)}):Play()
            task.wait(0.3)
            dropdownContent.Visible = false
        end
    end)
    
    return {
        Container = dropdownContainer,
        SetValue = function(option)
            if table.find(options, option) then
                selectedOption = option
                dropdownSelection.Text = option
                
                if callback then
                    callback(option)
                end
            end
        end,
        GetValue = function()
            return selectedOption
        end,
        Refresh = function(newOptions, keepSelection)
            -- Clear existing options
            for _, child in ipairs(optionsList:GetChildren()) do
                if child:IsA("TextButton") then
                    child:Destroy()
                end
            end
            
            options = newOptions
            
            -- Add new options
            for i, option in ipairs(options) do
                local optionButton = Create("TextButton")({
                    Name = "Option_" .. option,
                    BackgroundColor3 = LaunchX.Theme.Dark,
                                        Size = UDim2.new(1, 0, 0, 25),
                    Font = Enum.Font.GothamSemibold,
                    Text = option,
                    TextColor3 = LaunchX.Theme.TextPrimary,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 5,
                    Parent = optionsList
                })
                
                Create("UIPadding")({
                    PaddingLeft = UDim.new(0, 5),
                    Parent = optionButton
                })
                
                optionButton.MouseEnter:Connect(function()
                    CreateTween(optionButton, {BackgroundColor3 = LaunchX.Theme.Primary}):Play()
                end)
                
                optionButton.MouseLeave:Connect(function()
                    CreateTween(optionButton, {BackgroundColor3 = LaunchX.Theme.Dark}):Play()
                end)
                
                optionButton.MouseButton1Click:Connect(function()
                    selectedOption = option
                    dropdownSelection.Text = option
                    
                    isOpen = false
                    CreateTween(dropdownIcon, {Rotation = 0}):Play()
                    CreateTween(dropdownContent, {Size = UDim2.new(1, -PADDING*2, 0, 0)}):Play()
                    task.wait(0.3)
                    dropdownContent.Visible = false
                    
                    if callback then
                        callback(option)
                    end
                end)
            end
            
            if not keepSelection or not table.find(options, selectedOption) then
                selectedOption = options[1]
                dropdownSelection.Text = selectedOption or "Select..."
            end
        end
    }
end

-- TextBox
function LaunchX:CreateTextBox(text, placeholder, default, callback)
    local textboxContainer = Create("Frame")({
        Name = "TextBoxContainer_" .. text,
        BackgroundColor3 = LaunchX.Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 60),
        Parent = self.Content
    })
    
    ApplyDefaultStyling(textboxContainer)
    
    local textboxLabel = Create("TextLabel")({
        Name = "TextBoxLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, PADDING, 0, 5),
        Size = UDim2.new(1, -20, 0, 20),
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textboxContainer
    })
    
    local textbox = Create("TextBox")({
        Name = "TextBox",
        BackgroundColor3 = LaunchX.Theme.Dark,
        Position = UDim2.new(0, PADDING, 0, 30),
        Size = UDim2.new(1, -PADDING*2, 0, 25),
        Font = Enum.Font.GothamSemibold,
        PlaceholderText = placeholder or "",
        Text = default or "",
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = textboxContainer
    })
    
    Create("UIPadding")({
        PaddingLeft = UDim.new(0, 5),
        Parent = textbox
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = textbox
    })
    
    textbox.Focused:Connect(function()
        CreateTween(textbox, {BackgroundColor3 = Color3.fromRGB(
            LaunchX.Theme.Dark.R * 255 + 20,
            LaunchX.Theme.Dark.G * 255 + 20,
            LaunchX.Theme.Dark.B * 255 + 20
        )}):Play()
    end)
    
    textbox.FocusLost:Connect(function(enterPressed)
        CreateTween(textbox, {BackgroundColor3 = LaunchX.Theme.Dark}):Play()
        
        if callback and (enterPressed or not enterPressed) then
            callback(textbox.Text)
        end
    end)
    
    return {
        Container = textboxContainer,
        SetValue = function(value)
            textbox.Text = value or ""
        end,
        GetValue = function()
            return textbox.Text
        end
    }
end

-- Label
function LaunchX:CreateLabel(text)
    local labelContainer = Create("Frame")({
        Name = "LabelContainer_" .. text,
        BackgroundColor3 = LaunchX.Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 30),
        Parent = self.Content
    })
    
    ApplyDefaultStyling(labelContainer)
    
    local label = Create("TextLabel")({
        Name = "Label",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, PADDING, 0, 0),
        Size = UDim2.new(1, -PADDING*2, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = labelContainer
    })
    
    return {
        Container = labelContainer,
        SetText = function(newText)
            label.Text = newText
        end
    }
end

-- Separator
function LaunchX:CreateSeparator()
    local separatorContainer = Create("Frame")({
        Name = "Separator",
        BackgroundColor3 = LaunchX.Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 10),
        Parent = self.Content
    })
    
    local separator = Create("Frame")({
        Name = "SeparatorLine",
        BackgroundColor3 = LaunchX.Theme.Dark,
        Position = UDim2.new(0, PADDING, 0.5, 0),
        Size = UDim2.new(1, -PADDING*2, 0, 1),
        AnchorPoint = Vector2.new(0, 0.5),
        Parent = separatorContainer
    })
    
    return separatorContainer
end

-- Keybind
function LaunchX:CreateKeybind(text, default, callback)
    default = default or Enum.KeyCode.Unknown
    
    local keybindContainer = Create("Frame")({
        Name = "KeybindContainer_" .. text,
        BackgroundColor3 = LaunchX.Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.Content
    })
    
    ApplyDefaultStyling(keybindContainer)
    
    local keybindLabel = Create("TextLabel")({
        Name = "KeybindLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, PADDING, 0, 0),
        Size = UDim2.new(1, -100, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = keybindContainer
    })
    
    local keybindButton = Create("TextButton")({
        Name = "KeybindButton",
        BackgroundColor3 = LaunchX.Theme.Dark,
        Position = UDim2.new(1, -80, 0.5, 0),
        Size = UDim2.new(0, 70, 0, 25),
        AnchorPoint = Vector2.new(1, 0.5),
        Font = Enum.Font.GothamSemibold,
        Text = tostring(default.Name),
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 12,
        Parent = keybindContainer
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = keybindButton
    })
    
    local listening = false
    local currentKey = default
    
    local function updateKeybind(key)
        currentKey = key
        keybindButton.Text = tostring(key.Name)
        listening = false
        
        if callback then
            callback(key)
        end
    end
    
    keybindButton.MouseButton1Click:Connect(function()
        listening = true
        keybindButton.Text = "..."
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if listening and not gameProcessed then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                updateKeybind(input.KeyCode)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 then
                updateKeybind(Enum.KeyCode.MouseButton1)
            elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
                updateKeybind(Enum.KeyCode.MouseButton2)
            elseif input.UserInputType == Enum.UserInputType.MouseButton3 then
                updateKeybind(Enum.KeyCode.MouseButton3)
            end
        end
    end)
    
    return {
        Container = keybindContainer,
        SetKey = function(key)
            updateKeybind(key)
        end,
        GetKey = function()
            return currentKey
        end
    }
end

-- Color Picker
function LaunchX:CreateColorPicker(text, default, callback)
    default = default or LaunchX.Theme.Primary
    
    local colorPickerContainer = Create("Frame")({
        Name = "ColorPickerContainer_" .. text,
        BackgroundColor3 = LaunchX.Theme.Secondary,
        Size = UDim2.new(1, 0, 0, 40),
        Parent = self.Content
    })
    
    ApplyDefaultStyling(colorPickerContainer)
    
    local colorPickerLabel = Create("TextLabel")({
        Name = "ColorPickerLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, PADDING, 0, 0),
        Size = UDim2.new(1, -60, 1, 0),
        Font = Enum.Font.GothamSemibold,
        Text = text,
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = colorPickerContainer
    })
    
    local colorPreview = Create("Frame")({
        Name = "ColorPreview",
        BackgroundColor3 = default,
        Position = UDim2.new(1, -40, 0.5, 0),
        Size = UDim2.new(0, 30, 0, 20),
        AnchorPoint = Vector2.new(1, 0.5),
        Parent = colorPickerContainer
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = colorPreview
    })
    
    local colorPickerFrame = Create("Frame")({
        Name = "ColorPickerFrame",
        BackgroundColor3 = LaunchX.Theme.Dark,
        Position = UDim2.new(0, PADDING, 1, 5),
        Size = UDim2.new(1, -PADDING*2, 0, 150),
        Visible = false,
        ZIndex = 5,
        Parent = colorPickerContainer
    })
    
    ApplyDefaultStyling(colorPickerFrame)
    
    local hueSlider = Create("Frame")({
        Name = "HueSlider",
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 0, 10),
        ZIndex = 5,
        Parent = colorPickerFrame
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = hueSlider
    })
    
    local hueGradient = Create("UIGradient")({
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
            ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 0, 255)),
            ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 0, 255)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
            ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 255, 0)),
            ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 255, 0)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
        },
        Parent = hueSlider
    })
    
    local hueSelector = Create("Frame")({
        Name = "HueSelector",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 6, 1, 4),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 6,
        Parent = hueSlider
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = hueSelector
    })
    
    local saturationValueBox = Create("ImageLabel")({
        Name = "SaturationValueBox",
        BackgroundColor3 = Color3.fromRGB(255, 0, 0),
        Position = UDim2.new(0, 10, 0, 30),
        Size = UDim2.new(1, -20, 1, -50),
        Image = "rbxassetid://4155801252",
        ScaleType = Enum.ScaleType.Stretch,
        ZIndex = 5,
        Parent = colorPickerFrame
    })
    
    local svSelector = Create("Frame")({
        Name = "SVSelector",
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 8, 0, 8),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = 6,
        Parent = saturationValueBox
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(1, 0),
        Parent = svSelector
    })
    
    local rgbInputs = Create("Frame")({
        Name = "RGBInputs",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 1, -30),
        Size = UDim2.new(1, -20, 0, 20),
        ZIndex = 5,
        Parent = colorPickerFrame
    })
    
    local rgbLabels = {"R:", "G:", "B:"}
    local rgbTextboxes = {}
    
    for i = 1, 3 do
        Create("TextLabel")({
            Name = "Label_" .. rgbLabels[i],
            BackgroundTransparency = 1,
            Position = UDim2.new((i-1)/3, 0, 0, 0),
            Size = UDim2.new(0, 15, 1, 0),
            Font = Enum.Font.GothamSemibold,
            Text = rgbLabels[i],
            TextColor3 = LaunchX.Theme.TextPrimary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
            Parent = rgbInputs
        })
        
        local textbox = Create("TextBox")({
            Name = "TextBox_" .. rgbLabels[i],
            BackgroundColor3 = LaunchX.Theme.Dark,
            Position = UDim2.new((i-1)/3 + 0.1, 0, 0, 0),
            Size = UDim2.new(0.25, 0, 1, 0),
            Font = Enum.Font.GothamSemibold,
            Text = "0",
            TextColor3 = LaunchX.Theme.TextPrimary,
            TextSize = 12,
            ZIndex = 5,
            Parent = rgbInputs
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(0, 2),
            Parent = textbox
        })
        
        rgbTextboxes[i] = textbox
        
        textbox.FocusLost:Connect(function()
            local num = tonumber(textbox.Text) or 0
            num = math.clamp(num, 0, 255)
            textbox.Text = tostring(num)
            
            local r = tonumber(rgbTextboxes[1].Text) or 0
            local g = tonumber(rgbTextboxes[2].Text) or 0
            local b = tonumber(rgbTextboxes[3].Text) or 0
            
            local newColor = Color3.fromRGB(r, g, b)
            colorPreview.BackgroundColor3 = newColor
            
            if callback then
                callback(newColor)
            end
        end)
    end
    
    local isOpen = false
    local currentColor = default
    
    local function updateColor(newColor)
        currentColor = newColor
        colorPreview.BackgroundColor3 = newColor
        
        -- Update RGB textboxes
        local r, g, b = math.floor(newColor.R * 255), math.floor(newColor.G * 255), math.floor(newColor.B * 255)
        rgbTextboxes[1].Text = tostring(r)
        rgbTextboxes[2].Text = tostring(g)
        rgbTextboxes[3].Text = tostring(b)
        
        if callback then
            callback(newColor)
        end
    end
    
    local function hsvToRgb(h, s, v)
        local r, g, b
        
        local i = math.floor(h * 6)
        local f = h * 6 - i
        local p = v * (1 - s)
        local q = v * (1 - f * s)
        local t = v * (1 - (1 - f) * s)
        
        i = i % 6
        
        if i == 0 then
            r, g, b = v, t, p
        elseif i == 1 then
            r, g, b = q, v, p
        elseif i == 2 then
            r, g, b = p, v, t
        elseif i == 3 then
            r, g, b = p, q, v
        elseif i == 4 then
            r, g, b = t, p, v
        elseif i == 5 then
            r, g, b = v, p, q
        end
        
        return Color3.new(r, g, b)
    end
    
    local function rgbToHsv(color)
        local r, g, b = color.R, color.G, color.B
        local max, min = math.max(r, g, b), math.min(r, g, b)
        local h, s, v
        
        v = max
        
        local d = max - min
        if max == 0 then
            s = 0
        else
            s = d / max
        end
        
        if max == min then
            h = 0
        else
            if max == r then
                h = (g - b) / d
                if g < b then
                    h = h + 6
                end
            elseif max == g then
                h = (b - r) / d + 2
            elseif max == b then
                h = (r - g) / d + 4
            end
            h = h / 6
        end
        
        return h, s, v
    end
    
    -- Initialize with default color
    local h, s, v = rgbToHsv(default)
    hueSelector.Position = UDim2.new(h, 0, 0.5, 0)
    svSelector.Position = UDim2.new(s, 0, 1 - v, 0)
    saturationValueBox.BackgroundColor3 = hsvToRgb(h, 1, 1)
    
    -- Hue slider interaction
    local hueDragging = false
    
    hueSlider.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = true
            
            local relativeX = math.clamp(input.Position.X - hueSlider.AbsolutePosition.X, 0, hueSlider.AbsoluteSize.X)
            local percent = relativeX / hueSlider.AbsoluteSize.X
            
            hueSelector.Position = UDim2.new(percent, 0, 0.5, 0)
            
            h = percent
            saturationValueBox.BackgroundColor3 = hsvToRgb(h, 1, 1)
            
            local newColor = hsvToRgb(h, s, v)
            updateColor(newColor)
        end
    end)
    
    hueSlider.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            hueDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if hueDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp(input.Position.X - hueSlider.AbsolutePosition.X, 0, hueSlider.AbsoluteSize.X)
            local percent = relativeX / hueSlider.AbsoluteSize.X
            
            hueSelector.Position = UDim2.new(percent, 0, 0.5, 0)
            
            h = percent
            saturationValueBox.BackgroundColor3 = hsvToRgb(h, 1, 1)
            
            local newColor = hsvToRgb(h, s, v)
            updateColor(newColor)
        end
    end)
    
    -- Saturation/Value box interaction
    local svDragging = false
    
    saturationValueBox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = true
            
            local relativeX = math.clamp(input.Position.X - saturationValueBox.AbsolutePosition.X, 0, saturationValueBox.AbsoluteSize.X)
            local relativeY = math.clamp(input.Position.Y - saturationValueBox.AbsolutePosition.Y, 0, saturationValueBox.AbsoluteSize.Y)
            
            local percentX = relativeX / saturationValueBox.AbsoluteSize.X
            local percentY = relativeY / saturationValueBox.AbsoluteSize.Y
            
            svSelector.Position = UDim2.new(percentX, 0, percentY, 0)
            
            s = percentX
            v = 1 - percentY
            
            local newColor = hsvToRgb(h, s, v)
            updateColor(newColor)
        end
    end)
    
    saturationValueBox.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            svDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if svDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = math.clamp(input.Position.X - saturationValueBox.AbsolutePosition.X, 0, saturationValueBox.AbsoluteSize.X)
            local relativeY = math.clamp(input.Position.Y - saturationValueBox.AbsolutePosition.Y, 0, saturationValueBox.AbsoluteSize.Y)
            
            local percentX = relativeX / saturationValueBox.AbsoluteSize.X
            local percentY = relativeY / saturationValueBox.AbsoluteSize.Y
            
            svSelector.Position = UDim2.new(percentX, 0, percentY, 0)
            
            s = percentX
            v = 1 - percentY
            
            local newColor = hsvToRgb(h, s, v)
            updateColor(newColor)
        end
    end)
    
    colorPreview.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            colorPickerFrame.Visible = true
            CreateTween(colorPickerFrame, {Size = UDim2.new(1, -PADDING*2, 0, 150)}):Play()
        else
            CreateTween(colorPickerFrame, {Size = UDim2.new(1, -PADDING*2, 0, 0)}):Play()
            task.wait(0.3)
            colorPickerFrame.Visible = false
        end
    end)
    
    return {
        Container = colorPickerContainer,
        SetColor = function(color)
            updateColor(color)
            
            -- Update HSV selectors
            h, s, v = rgbToHsv(color)
            hueSelector.Position = UDim2.new(h, 0, 0.5, 0)
            svSelector.Position = UDim2.new(s, 0, 1 - v, 0)
            saturationValueBox.BackgroundColor3 = hsvToRgb(h, 1, 1)
        end,
        GetColor = function()
            return currentColor
        end
    }
end

-- Tab System
function LaunchX:CreateTabs(tabNames)
    tabNames = tabNames or {"Main"}
    
    -- Create Tab Bar
    local tabBar = Create("Frame")({
        Name = "TabBar",
        BackgroundColor3 = LaunchX.Theme.Secondary,
        Position = UDim2.new(0, PADDING, 0, 36 + PADDING),
        Size = UDim2.new(1, -PADDING*2, 0, 30),
        Parent = self.Container
    })
    
    Create("UICorner")({
        CornerRadius = UDim.new(0, 4),
        Parent = tabBar
    })
    
    -- Create Tab Buttons
    local tabButtons = {}
    local tabContents = {}
    
    local tabContentContainer = Create("ScrollingFrame")({
        Name = "TabContentContainer",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, PADDING, 0, 36 + PADDING + 30 + PADDING),
        Size = UDim2.new(1, -PADDING*2, 1, -(36 + PADDING*2 + 30 + PADDING)),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = LaunchX.Theme.Primary,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.Container
    })
    
    local uiListLayout = Create("UIListLayout")({
        Padding = UDim.new(0, PADDING),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabContentContainer
    })
    
    uiListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tabContentContainer.CanvasSize = UDim2.new(0, 0, 0, uiListLayout.AbsoluteContentSize.Y)
    end)
    
    -- Adjust original content position and visibility
    self.Content.Visible = false
    
    local function createTabContent(tabName)
        local content = Create("Frame")({
            Name = "TabContent_" .. tabName,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 0),
            Visible = false,
            Parent = tabContentContainer
        })
        
        local listLayout = Create("UIListLayout")({
            Padding = UDim.new(0, PADDING),
            SortOrder = Enum.SortOrder.LayoutOrder,
            Parent = content
        })
        
        listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            content.Size = UDim2.new(1, 0, 0, listLayout.AbsoluteContentSize.Y)
        end)
        
        return content
    end
    
    local function switchTab(tabIndex)
        for i, button in ipairs(tabButtons) do
            if i == tabIndex then
                CreateTween(button, {BackgroundColor3 = LaunchX.Theme.Primary}):Play()
                CreateTween(button.TextLabel, {TextColor3 = LaunchX.Theme.TextPrimary}):Play()
                tabContents[i].Visible = true
            else
                CreateTween(button, {BackgroundColor3 = LaunchX.Theme.Dark}):Play()
                CreateTween(button.TextLabel, {TextColor3 = LaunchX.Theme.TextSecondary}):Play()
                tabContents[i].Visible = false
            end
        end
    end
    
    for i, tabName in ipairs(tabNames) do
        local tabButton = Create("TextButton")({
            Name = "TabButton_" .. tabName,
            BackgroundColor3 = i == 1 and LaunchX.Theme.Primary or LaunchX.Theme.Dark,
            Position = UDim2.new((i-1)/#tabNames, 0, 0, 0),
            Size = UDim2.new(1/#tabNames, 0, 1, 0),
            AutoButtonColor = false,
            Text = "",
            Parent = tabBar
        })
        
        Create("UICorner")({
            CornerRadius = UDim.new(0, 4),
            Parent = tabButton
        })
        
        local tabLabel = Create("TextLabel")({
            Name = "TabLabel",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Font = Enum.Font.GothamSemibold,
            Text = tabName,
            TextColor3 = i == 1 and LaunchX.Theme.TextPrimary or LaunchX.Theme.TextSecondary,
            TextSize = 12,
            Parent = tabButton
        })
        
        tabButton.MouseButton1Click:Connect(function()
            switchTab(i)
        end)
        
        table.insert(tabButtons, tabButton)
        
        local content = createTabContent(tabName)
        content.Visible = i == 1
        table.insert(tabContents, content)
    end
    
    -- Return a function to add elements to specific tabs
    return function(tabName)
        local tabIndex = table.find(tabNames, tabName)
        if not tabIndex then return end
        
        local tabContent = tabContents[tabIndex]
        
        return {
            CreateButton = function(text, callback)
                local button = self:CreateButton(text, callback)
                button.Parent = tabContent
                return button
            end,
            CreateToggle = function(text, default, callback)
                local toggle = self:CreateToggle(text, default, callback)
                toggle.Container.Parent = tabContent
                return toggle
            end,
            CreateSlider = function(text, min, max, default, callback)
                local slider = self:CreateSlider(text, min, max, default, callback)
                slider.Container.Parent = tabContent
                return slider
            end,
            CreateDropdown = function(text, options, default, callback)
                local dropdown = self:CreateDropdown(text, options, default, callback)
                dropdown.Container.Parent = tabContent
                return dropdown
            end,
            CreateTextBox = function(text, placeholder, default, callback)
                local textbox = self:CreateTextBox(text, placeholder, default, callback)
                textbox.Container.Parent = tabContent
                return textbox
            end,
            CreateLabel = function(text)
                local label = self:CreateLabel(text)
                label.Container.Parent = tabContent
                return label
            end,
            CreateSeparator = function()
                local separator = self:CreateSeparator()
                separator.Parent = tabContent
                return separator
            end,
            CreateKeybind = function(text, default, callback)
                local keybind = self:CreateKeybind(text, default, callback)
                keybind.Container.Parent = tabContent
                return keybind
            end,
            CreateColorPicker = function(text, default, callback)
                local colorPicker = self:CreateColorPicker(text, default, callback)
                colorPicker.Container.Parent = tabContent
                return colorPicker
            end
        }
    end
end

-- Notification System
function LaunchX:Notify(title, message, duration, notificationType)
    duration = duration or 5
    notificationType = notificationType or "Info"
    
    local typeColors = {
        Info = LaunchX.Theme.Info,
        Success = LaunchX.Theme.Success,
        Warning = LaunchX.Theme.Warning,
        Error = LaunchX.Theme.Danger
    }
    
    local accentColor = typeColors[notificationType] or LaunchX.Theme.Primary
    
    local notification = Create("Frame")({
        Name = "Notification",
        BackgroundColor3 = LaunchX.Theme.Secondary,
        Position = UDim2.new(1, 10, 1, -50),
        Size = UDim2.new(0, 300, 0, 0),
        AnchorPoint = Vector2.new(1, 1),
        Parent = self.ScreenGui
    })
    
    ApplyDefaultStyling(notification)
    
    local accentBar = Create("Frame")({
        Name = "AccentBar",
        BackgroundColor3 = accentColor,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 5, 1, 0),
        Parent = notification
    })
    
    local titleLabel = Create("TextLabel")({
        Name = "TitleLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 10),
        Size = UDim2.new(1, -15, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = title,
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notification
    })
    
    local messageLabel = Create("TextLabel")({
        Name = "MessageLabel",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 15, 0, 30),
        Size = UDim2.new(1, -15, 1, -40),
        Font = Enum.Font.Gotham,
        Text = message,
        TextColor3 = LaunchX.Theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextWrapped = true,
        Parent = notification
    })
    
    local closeButton = Create("ImageButton")({
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 10),
        Size = UDim2.new(0, 15, 0, 15),
        Image = "rbxassetid://6031094678",
        ImageColor3 = LaunchX.Theme.TextPrimary,
        Parent = notification
    })
    
    -- Calculate required height
    local textBounds = messageLabel.TextBounds
    local requiredHeight = math.min(200, math.max(80, textBounds.Y + 50))
    
    -- Animation
    notification.Size = UDim2.new(0, 300, 0, 0)
    notification.Position = UDim2.new(1, 10, 1, -50)
    
    CreateTween(notification, {
        Size = UDim2.new(0, 300, 0, requiredHeight)
    }):Play()
    
    local function closeNotification()
        CreateTween(notification, {
            Size = UDim2.new(0, 300, 0, 0),
            Position = UDim2.new(1, 10, 1, -50)
        }):Play()
        
        task.wait(0.3)
        notification:Destroy()
    end
    
    closeButton.MouseButton1Click:Connect(closeNotification)
    
    task.spawn(function()
        task.wait(duration)
        if notification and notification.Parent then
            closeNotification()
        end
    end)
    
    return {
        Close = closeNotification
    }
end

-- Tooltip System
function LaunchX:AddTooltip(element, text)
    local tooltip = Create("Frame")({
        Name = "Tooltip",
        BackgroundColor3 = LaunchX.Theme.Dark,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 10,
        Parent = self.ScreenGui
    })
    
    ApplyDefaultStyling(tooltip)
    
    local tooltipText = Create("TextLabel")({
        Name = "TooltipText",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, PADDING, 0, PADDING),
        Size = UDim2.new(1, -PADDING*2, 1, -PADDING*2),
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = LaunchX.Theme.TextPrimary,
        TextSize = 12,
        TextWrapped = true,
        Parent = tooltip
    })
    
    local function calculateSize()
        local textBounds = tooltipText.TextBounds
        tooltip.Size = UDim2.new(0, textBounds.X + PADDING*2, 0, textBounds.Y + PADDING*2)
    end
    
    calculateSize()
    
    local connection1
    local connection2
    
    connection1 = element.MouseEnter:Connect(function()
        tooltip.Visible = true
        calculateSize()
        
        local mouse = UserInputService:GetMouseLocation()
        local position = UDim2.new(0, mouse.X + 15, 0, mouse.Y + 15)
        
        -- Adjust position if tooltip goes off screen
        local viewportSize = workspace.CurrentCamera.ViewportSize
        
        if position.X.Offset + tooltip.AbsoluteSize.X > viewportSize.X then
            position = UDim2.new(0, mouse.X - 15 - tooltip.AbsoluteSize.X, position.Y.Scale, position.Y.Offset)
        end
        
        if position.Y.Offset + tooltip.AbsoluteSize.Y > viewportSize.Y then
            position = UDim2.new(position.X.Scale, position.X.Offset, 0, mouse.Y - 15 - tooltip.AbsoluteSize.Y)
        end
        
        tooltip.Position = position
    end)
    
    connection2 = element.MouseLeave:Connect(function()
        tooltip.Visible = false
    end)
    
    return {
        Destroy = function()
            connection1:Disconnect()
            connection2:Disconnect()
            tooltip:Destroy()
        end,
        UpdateText = function(newText)
            tooltipText.Text = newText
            calculateSize()
        end
    }
end

-- Destroy UI
function LaunchX:Destroy()
    if self.ScreenGui and self.ScreenGui.Parent then
        self.ScreenGui:Destroy()
    end
end

return LaunchX
