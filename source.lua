local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local themes = {
    Dark = {
        Background = Color3.fromRGB(30, 32, 40),
        Accent = Color3.fromRGB(80, 120, 255),
        Text = Color3.fromRGB(230, 230, 240),
        Button = Color3.fromRGB(40, 42, 55),
        ButtonHover = Color3.fromRGB(60, 65, 90),
        ToggleOn = Color3.fromRGB(80, 200, 120),
        ToggleOff = Color3.fromRGB(80, 80, 80),
        Slider = Color3.fromRGB(80, 120, 255),
    },
    Light = {
        Background = Color3.fromRGB(240, 240, 255),
        Accent = Color3.fromRGB(80, 120, 255),
        Text = Color3.fromRGB(30, 32, 40),
        Button = Color3.fromRGB(220, 220, 240),
        ButtonHover = Color3.fromRGB(200, 210, 240),
        ToggleOn = Color3.fromRGB(80, 200, 120),
        ToggleOff = Color3.fromRGB(180, 180, 180),
        Slider = Color3.fromRGB(80, 120, 255),
    }
}

local function create(class, props)
    local inst = Instance.new(class)
    for k, v in pairs(props or {}) do
        inst[k] = v
    end
    return inst
end

local function tween(obj, props, time, style)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
end

local UILib = {}
UILib.__index = UILib

function UILib.new(config)
    local self = setmetatable({}, UILib)
    self.theme = themes[config and config.Theme or "Dark"] or themes.Dark
    self.title = config and config.Title or "UI Library"
    self.tabs = {}
    self.activeTab = nil
    self.drag = {dragging = false, offset = Vector2.new()}

    -- Main ScreenGui
    self.gui = create("ScreenGui", {Name = "UILibka", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Global})
    self.gui.Parent = game:GetService("Players").LocalPlayer.PlayerGui

    -- Main Window
    self.window = create("Frame", {
        Name = "Window",
        Size = UDim2.new(0, 480, 0, 340),
        Position = UDim2.new(0.5, -240, 0.5, -170),
        BackgroundColor3 = self.theme.Background,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Active = true,
        Draggable = false,
    })
    self.window.Parent = self.gui

    -- Shadow
    local shadow = create("ImageLabel", {
        Name = "Shadow",
        Size = UDim2.new(1, 40, 1, 40),
        Position = UDim2.new(0, -20, 0, -20),
        BackgroundTransparency = 1,
        Image = "rbxassetid://1316045217",
        ImageTransparency = 0.7,
        ZIndex = 0,
    })
    shadow.Parent = self.window

    -- TitleBar
    self.titleBar = create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundColor3 = self.theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    self.titleBar.Parent = self.window

    local titleLabel = create("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = self.title,
        Font = Enum.Font.GothamBold,
        TextSize = 20,
        TextColor3 = self.theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 16, 0, 0),
        ZIndex = 3,
    })
    titleLabel.Parent = self.titleBar

    -- Drag logic
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.drag.dragging = true
            self.drag.offset = Vector2.new(input.Position.X, input.Position.Y) - Vector2.new(self.window.Position.X.Offset, self.window.Position.Y.Offset)
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.drag.dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if self.drag.dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = Vector2.new(input.Position.X, input.Position.Y) - self.drag.offset
            self.window.Position = UDim2.new(0, pos.X, 0, pos.Y)
        end
    end)

    -- TabBar
    self.tabBar = create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, 36),
        Position = UDim2.new(0, 0, 0, 38),
        BackgroundColor3 = self.theme.Button,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    self.tabBar.Parent = self.window

    self.tabButtons = {}
    self.tabContent = create("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, 0, 1, -74),
        Position = UDim2.new(0, 0, 0, 74),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    self.tabContent.Parent = self.window

    return self
end

function UILib:AddTab(tabName)
    local tab = {Name = tabName, Elements = {}}
    table.insert(self.tabs, tab)
    local idx = #self.tabs
    local btn = create("TextButton", {
        Name = "TabButton" .. idx,
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, (idx-1)*122, 0, 0),
        BackgroundColor3 = self.theme.Button,
        BorderSizePixel = 0,
        Text = tabName,
        Font = Enum.Font.Gotham,
        TextSize = 16,
        TextColor3 = self.theme.Text,
        ZIndex = 3,
        AutoButtonColor = false,
    })
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = self.theme.ButtonHover}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = self.theme.Button}, 0.15)
    end)
    btn.MouseButton1Click:Connect(function()
        self:SelectTab(idx)
    end)
    btn.Parent = self.tabBar
    self.tabButtons[idx] = btn
    if not self.activeTab then
        self:SelectTab(idx)
    end
    return setmetatable({lib = self, tab = tab}, {
        __index = function(t, k)
            return function(_, ...)
                return self[k](self, idx, ...)
            end
        end
    })
end

function UILib:SelectTab(idx)
    self.activeTab = idx
    for i, btn in ipairs(self.tabButtons) do
        btn.BackgroundColor3 = (i == idx) and self.theme.Accent or self.theme.Button
    end
    for _, child in ipairs(self.tabContent:GetChildren()) do
        child:Destroy()
    end
    local y = 10
    for _, el in ipairs(self.tabs[idx].Elements) do
        local ui = el()
        ui.Position = UDim2.new(0, 20, 0, y)
        ui.Parent = self.tabContent
        y = y + ui.Size.Y.Offset + 10
    end
end

function UILib:AddButton(tabIdx, text, callback)
    table.insert(self.tabs[tabIdx].Elements, function()
        local btn = create("TextButton", {
            Size = UDim2.new(0, 200, 0, 36),
            BackgroundColor3 = self.theme.Button,
            BorderSizePixel = 0,
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 16,
            TextColor3 = self.theme.Text,
            AutoButtonColor = false,
            ZIndex = 4,
        })
        btn.MouseEnter:Connect(function()
            tween(btn, {BackgroundColor3 = self.theme.ButtonHover}, 0.15)
        end)
        btn.MouseLeave:Connect(function()
            tween(btn, {BackgroundColor3 = self.theme.Button}, 0.15)
        end)
        btn.MouseButton1Click:Connect(callback)
        return btn
    end)
end

function UILib:AddToggle(tabIdx, text, default, callback)
    table.insert(self.tabs[tabIdx].Elements, function()
        local frame = create("Frame", {
            Size = UDim2.new(0, 200, 0, 36),
            BackgroundTransparency = 1,
            ZIndex = 4,
        })
        local box = create("Frame", {
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(0, 0, 0, 2),
            BackgroundColor3 = default and self.theme.ToggleOn or self.theme.ToggleOff,
            BorderSizePixel = 0,
            ZIndex = 5,
        })
        box.Parent = frame
        local txt = create("TextLabel", {
            Size = UDim2.new(1, -40, 1, 0),
            Position = UDim2.new(0, 40, 0, 0),
            BackgroundTransparency = 1,
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 16,
            TextColor3 = self.theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 5,
        })
        txt.Parent = frame
        local state = default
        frame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                state = not state
                tween(box, {BackgroundColor3 = state and self.theme.ToggleOn or self.theme.ToggleOff}, 0.15)
                callback(state)
            end
        end)
        return frame
    end)
end

function UILib:AddSlider(tabIdx, text, min, max, default, callback)
    table.insert(self.tabs[tabIdx].Elements, function()
        local frame = create("Frame", {
            Size = UDim2.new(0, 200, 0, 44),
            BackgroundTransparency = 1,
            ZIndex = 4,
        })
        local label = create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = text .. ": " .. tostring(default),
            Font = Enum.Font.Gotham,
            TextSize = 15,
            TextColor3 = self.theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 0, 0, 0),
            ZIndex = 5,
        })
        label.Parent = frame
        local bar = create("Frame", {
            Size = UDim2.new(1, 0, 0, 10),
            Position = UDim2.new(0, 0, 0, 24),
            BackgroundColor3 = self.theme.ToggleOff,
            BorderSizePixel = 0,
            ZIndex = 5,
        })
        bar.Parent = frame
        local fill = create("Frame", {
            Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
            BackgroundColor3 = self.theme.Slider,
            BorderSizePixel = 0,
            ZIndex = 6,
        })
        fill.Parent = bar
        local dragging = false
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
                rel = math.clamp(rel, 0, 1)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                local val = math.floor((min + (max-min)*rel) + 0.5)
                label.Text = text .. ": " .. tostring(val)
                callback(val)
            end
        end)
        return frame
    end)
end

function UILib:SetTheme(themeName)
    if themes[themeName] then
        self.theme = themes[themeName]
        self.window.BackgroundColor3 = self.theme.Background
        self.titleBar.BackgroundColor3 = self.theme.Accent
        self.tabBar.BackgroundColor3 = self.theme.Button
        for i, btn in ipairs(self.tabButtons) do
            btn.BackgroundColor3 = (i == self.activeTab) and self.theme.Accent or self.theme.Button
            btn.TextColor3 = self.theme.Text
        end
        for _, child in ipairs(self.tabContent:GetChildren()) do
            if child:IsA("TextButton") or child:IsA("TextLabel") then
                child.TextColor3 = self.theme.Text
            end
        end
    end
end

return UILib 
