local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local themes = {
    Dark = {
        Background = Color3.fromRGB(28, 30, 38),
        Accent = Color3.fromRGB(90, 130, 255),
        Text = Color3.fromRGB(235, 235, 245),
        Button = Color3.fromRGB(38, 40, 55),
        ButtonHover = Color3.fromRGB(60, 70, 110),
        ToggleOn = Color3.fromRGB(80, 200, 120),
        ToggleOff = Color3.fromRGB(80, 80, 80),
        Slider = Color3.fromRGB(90, 130, 255),
        Dropdown = Color3.fromRGB(38, 40, 55),
        DropdownItem = Color3.fromRGB(48, 50, 65),
        MultiSelect = Color3.fromRGB(38, 40, 55),
        Border = Color3.fromRGB(50, 55, 70),
        Shadow = Color3.fromRGB(0,0,0),
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

local function roundify(obj, radius)
    local uic = Instance.new("UICorner")
    uic.CornerRadius = UDim.new(0, radius or 10)
    uic.Parent = obj
    return uic
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

    self.gui = create("ScreenGui", {Name = "UILibka", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Global})
    self.gui.Parent = game:GetService("Players").LocalPlayer.PlayerGui

    self.window = create("Frame", {
        Name = "Window",
        Size = UDim2.new(0, 500, 0, 370),
        Position = UDim2.new(0.5, -250, 0.5, -185),
        BackgroundColor3 = self.theme.Background,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Active = true,
        Draggable = false,
    })
    self.window.Parent = self.gui
    roundify(self.window, 16)

    local shadow = create("Frame", {
        Name = "Shadow",
        Size = UDim2.new(1, 24, 1, 24),
        Position = UDim2.new(0, -12, 0, -12),
        BackgroundColor3 = self.theme.Shadow,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.7,
        ZIndex = 0,
    })
    shadow.Parent = self.window
    roundify(shadow, 18)

    self.titleBar = create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = self.theme.Accent,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    self.titleBar.Parent = self.window
    roundify(self.titleBar, 16)

    local titleLabel = create("TextLabel", {
        Name = "TitleLabel",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = self.title,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextColor3 = self.theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Position = UDim2.new(0, 20, 0, 0),
        ZIndex = 3,
    })
    titleLabel.Parent = self.titleBar

    -- Drag logic (плавный)
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.drag.dragging = true
            self.drag.offset = Vector2.new(input.Position.X, input.Position.Y) - Vector2.new(self.window.AbsolutePosition.X, self.window.AbsolutePosition.Y)
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
            tween(self.window, {Position = UDim2.new(0, pos.X, 0, pos.Y)}, 0.12)
        end
    end)

    self.tabBar = create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, 38),
        Position = UDim2.new(0, 0, 0, 44),
        BackgroundColor3 = self.theme.Button,
        BorderSizePixel = 0,
        ZIndex = 2,
    })
    self.tabBar.Parent = self.window
    roundify(self.tabBar, 12)

    self.tabButtons = {}
    self.tabContent = create("Frame", {
        Name = "TabContent",
        Size = UDim2.new(1, 0, 1, -82),
        Position = UDim2.new(0, 0, 0, 82),
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
        Size = UDim2.new(0, 130, 1, 0),
        Position = UDim2.new(0, (idx-1)*134, 0, 0),
        BackgroundColor3 = self.theme.Button,
        BorderSizePixel = 0,
        Text = tabName,
        Font = Enum.Font.Gotham,
        TextSize = 17,
        TextColor3 = self.theme.Text,
        ZIndex = 3,
        AutoButtonColor = false,
    })
    roundify(btn, 10)
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
    local y = 12
    for _, el in ipairs(self.tabs[idx].Elements) do
        local ui = el()
        ui.Position = UDim2.new(0, 24, 0, y)
        ui.Parent = self.tabContent
        y = y + ui.Size.Y.Offset + 14
    end
end

function UILib:AddButton(tabIdx, text, callback)
    table.insert(self.tabs[tabIdx].Elements, function()
        local btn = create("TextButton", {
            Size = UDim2.new(0, 220, 0, 40),
            BackgroundColor3 = self.theme.Button,
            BorderSizePixel = 0,
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 17,
            TextColor3 = self.theme.Text,
            AutoButtonColor = false,
            ZIndex = 4,
        })
        roundify(btn, 10)
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
            Size = UDim2.new(0, 220, 0, 40),
            BackgroundTransparency = 1,
            ZIndex = 4,
        })
        local box = create("Frame", {
            Size = UDim2.new(0, 34, 0, 34),
            Position = UDim2.new(0, 2, 0, 3),
            BackgroundColor3 = default and self.theme.ToggleOn or self.theme.ToggleOff,
            BorderSizePixel = 0,
            ZIndex = 5,
        })
        roundify(box, 8)
        box.Parent = frame
        local txt = create("TextLabel", {
            Size = UDim2.new(1, -44, 1, 0),
            Position = UDim2.new(0, 44, 0, 0),
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
            Size = UDim2.new(0, 220, 0, 54),
            BackgroundTransparency = 1,
            ZIndex = 4,
        })
        local label = create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 20),
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
            Size = UDim2.new(1, -24, 0, 14),
            Position = UDim2.new(0, 12, 0, 28),
            BackgroundColor3 = self.theme.ToggleOff,
            BorderSizePixel = 0,
            ZIndex = 5,
        })
        roundify(bar, 7)
        bar.Parent = frame
        local fill = create("Frame", {
            Size = UDim2.new((default-min)/(max-min), 0, 1, 0),
            BackgroundColor3 = self.theme.Slider,
            BorderSizePixel = 0,
            ZIndex = 6,
        })
        roundify(fill, 7)
        fill.Parent = bar
        local knob = create("Frame", {
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new((default-min)/(max-min), -9, 0.5, -9),
            BackgroundColor3 = self.theme.Accent,
            BorderSizePixel = 0,
            ZIndex = 7,
        })
        roundify(knob, 9)
        knob.Parent = bar
        local dragging = false
        local function setSlider(rel)
            rel = math.clamp(rel, 0, 1)
            local val = math.floor((min + (max-min)*rel) + 0.5)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -9, 0.5, -9)
            label.Text = text .. ": " .. tostring(val)
            callback(val)
        end
        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
                tween(knob, {BackgroundColor3 = self.theme.Accent}, 0.1)
                setSlider(rel)
            end
        end)
        knob.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                tween(knob, {BackgroundColor3 = self.theme.Accent}, 0.1)
            end
        end)
        UIS.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
                tween(knob, {BackgroundColor3 = self.theme.Accent}, 0.1)
            end
        end)
        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local rel = (input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X
                setSlider(rel)
            end
        end)
        return frame
    end)
end

function UILib:AddDropdown(tabIdx, text, items, default, callback)
    table.insert(self.tabs[tabIdx].Elements, function()
        local frame = create("Frame", {
            Size = UDim2.new(0, 220, 0, 44),
            BackgroundTransparency = 1,
            ZIndex = 4,
        })
        local label = create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 15,
            TextColor3 = self.theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 0, 0, 0),
            ZIndex = 5,
        })
        label.Parent = frame
        local box = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 22),
            Position = UDim2.new(0, 0, 0, 22),
            BackgroundColor3 = self.theme.Dropdown,
            BorderSizePixel = 0,
            Text = default or items[1],
            Font = Enum.Font.Gotham,
            TextSize = 15,
            TextColor3 = self.theme.Text,
            ZIndex = 6,
            AutoButtonColor = false,
        })
        roundify(box, 8)
        box.Parent = frame
        local open = false
        local dropdownFrame
        box.MouseButton1Click:Connect(function()
            if open then
                if dropdownFrame then dropdownFrame:Destroy() end
                open = false
                return
            end
            open = true
            dropdownFrame = create("Frame", {
                Size = UDim2.new(1, 0, 0, #items*24),
                Position = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = self.theme.Dropdown,
                BorderSizePixel = 0,
                ZIndex = 10,
                Parent = box,
            })
            roundify(dropdownFrame, 8)
            for i, v in ipairs(items) do
                local item = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 22),
                    Position = UDim2.new(0, 0, 0, (i-1)*24),
                    BackgroundColor3 = self.theme.DropdownItem,
                    BorderSizePixel = 0,
                    Text = v,
                    Font = Enum.Font.Gotham,
                    TextSize = 15,
                    TextColor3 = self.theme.Text,
                    ZIndex = 11,
                    AutoButtonColor = false,
                    Parent = dropdownFrame,
                })
                roundify(item, 6)
                item.MouseButton1Click:Connect(function()
                    box.Text = v
                    callback(v)
                    dropdownFrame:Destroy()
                    open = false
                end)
            end
        end)
        return frame
    end)
end

function UILib:AddMultiSelect(tabIdx, text, items, defaults, callback)
    table.insert(self.tabs[tabIdx].Elements, function()
        local frame = create("Frame", {
            Size = UDim2.new(0, 220, 0, 54),
            BackgroundTransparency = 1,
            ZIndex = 4,
        })
        local label = create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = text,
            Font = Enum.Font.Gotham,
            TextSize = 15,
            TextColor3 = self.theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Position = UDim2.new(0, 0, 0, 0),
            ZIndex = 5,
        })
        label.Parent = frame
        local box = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, 22),
            BackgroundColor3 = self.theme.MultiSelect,
            BorderSizePixel = 0,
            Text = table.concat(defaults or {}, ", "),
            Font = Enum.Font.Gotham,
            TextSize = 15,
            TextColor3 = self.theme.Text,
            ZIndex = 6,
            AutoButtonColor = false,
        })
        roundify(box, 8)
        box.Parent = frame
        local open = false
        local dropdownFrame
        local selected = {}
        for _, v in ipairs(defaults or {}) do selected[v] = true end
        local function updateText()
            local t = {}
            for _, v in ipairs(items) do if selected[v] then table.insert(t, v) end end
            box.Text = #t > 0 and table.concat(t, ", ") or "Выбрать..."
            callback(t)
        end
        box.MouseButton1Click:Connect(function()
            if open then
                if dropdownFrame then dropdownFrame:Destroy() end
                open = false
                return
            end
            open = true
            dropdownFrame = create("Frame", {
                Size = UDim2.new(1, 0, 0, #items*24),
                Position = UDim2.new(0, 0, 1, 2),
                BackgroundColor3 = self.theme.Dropdown,
                BorderSizePixel = 0,
                ZIndex = 10,
                Parent = box,
            })
            roundify(dropdownFrame, 8)
            for i, v in ipairs(items) do
                local item = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 22),
                    Position = UDim2.new(0, 0, 0, (i-1)*24),
                    BackgroundColor3 = self.theme.DropdownItem,
                    BorderSizePixel = 0,
                    Text = v .. (selected[v] and " ✓" or ""),
                    Font = Enum.Font.Gotham,
                    TextSize = 15,
                    TextColor3 = self.theme.Text,
                    ZIndex = 11,
                    AutoButtonColor = false,
                    Parent = dropdownFrame,
                })
                roundify(item, 6)
                item.MouseButton1Click:Connect(function()
                    selected[v] = not selected[v]
                    item.Text = v .. (selected[v] and " ✓" or "")
                    updateText()
                end)
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
