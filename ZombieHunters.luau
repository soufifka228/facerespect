if game.GameId == 5120885191 then
    local function ClonedService(name)
        local Service = (game.GetService);
        local Reference = (cloneref) or function(reference) return reference end
        return Reference(Service(game, name));
    end

    local UIS = ClonedService("UserInputService")
    local plr = ClonedService("Players").LocalPlayer
    local rs = ClonedService("RunService")
    local rep = ClonedService("ReplicatedStorage")
    local spam = false
    spamBtn = nil

    getgenv().visualizer = false

    local function protectUI(sGui)

    if sGui:IsA("ScreenGui") then
        sGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
		sGui.DisplayOrder = 999999999
		sGui.ResetOnSpawn = false
		sGui.IgnoreGuiInset = true
    end
    local cGUI = ClonedService("CoreGui")
    local lPlr = ClonedService("Players").LocalPlayer

    local function NAProtection(inst, var)
        if inst then
            if var then
                inst[var] = "\0"
                inst.Archivable = false
            else
                inst.Name = "\0"
                inst.Archivable = false
            end
        end
    end

    if gethui then
		NAProtection(sGui)
		sGui.Parent = gethui()
		return sGui
	elseif cGUI and cGUI:FindFirstChild("RobloxGui") then
		NAProtection(sGui)
		sGui.Parent = cGUI:FindFirstChild("RobloxGui")
		return sGui
	elseif cGUI then
		NAProtection(sGui)
		sGui.Parent = cGUI
		return sGui
	elseif lPlr and lPlr:FindFirstChildWhichIsA("PlayerGui") then
		NAProtection(sGui)
		sGui.Parent = lPlr:FindFirstChildWhichIsA("PlayerGui")
		sGui.ResetOnSpawn = false
		return sGui
	else
		return nil
	end
end

    function getRoot(char)
        return char:FindFirstChild('HumanoidRootPart') or char:FindFirstChild('Torso') or char:FindFirstChild('UpperTorso')
    end

    function rndStr()
        local len = math.random(10, 20)
        local arr = {}
        for i = 1, len do
            arr[i] = string.char(math.random(32, 126))
        end
        return table.concat(arr)
    end

    function parry()
        rep.Framework.RemoteFunction:InvokeServer("SwordService", "Block", {-0.2588194012641907})
    end

    loadstring(game:HttpGet("https://raw.githubusercontent.com/1f0yt/community/main/RedCircleBlock"))()

    ClonedService("Workspace").Effects.ChildAdded:Connect(function(j)
        task.wait()
        j:Destroy()
    end)

    task.wait(0.5)

    local gui = Instance.new("ScreenGui")
    gui.IgnoreGuiInset = true
    protectUI(gui)
    gui.ResetOnSpawn = false
    gui.Name = rndStr()

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 250, 0, 200)
    frame.Position = UDim2.new(0.5, -125, 0.2, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 2
    frame.BorderColor3 = Color3.fromRGB(60, 60, 60)
    frame.Active = true
    frame.Draggable = true
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -50, 0, 30)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    title.BackgroundTransparency = 0.2
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 18
    title.Font = Enum.Font.SourceSansBold
    title.Text = "Ball Script"
    title.Parent = frame

    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Text = "X"
    closeBtn.Size = UDim2.new(0, 25, 0, 25)
    closeBtn.Position = UDim2.new(1, -25, 0, 0)
    closeBtn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 16
    closeBtn.Font = Enum.Font.SourceSansBold
    closeBtn.Parent = frame
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)

    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Name = "MinimizeBtn"
    minimizeBtn.Text = "-"
    minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
    minimizeBtn.Position = UDim2.new(1, -50, 0, 0)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    minimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minimizeBtn.TextSize = 16
    minimizeBtn.Font = Enum.Font.SourceSansBold
    minimizeBtn.Parent = frame

    function mkBtn(name, text, posX, posY, callback)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Text = text
        btn.Size = UDim2.new(0, 110, 0, 35)
        btn.Position = UDim2.new(posX, 0, posY, 0)
        btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        btn.BackgroundTransparency = 0.2
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.TextSize = 16
        btn.Font = Enum.Font.SourceSans
        btn.BorderSizePixel = 1
        btn.BorderColor3 = Color3.fromRGB(100, 100, 100)
        btn.Parent = frame
        btn.MouseButton1Click:Connect(callback)
        return btn
    end

    function toggleSpam()
        spam = not spam
        pcall(function()
            spamBtn.Text = "Spam: " .. (spam and "ON" or "OFF")
            spamBtn.BackgroundColor3 = spam and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 60)
        end)
    end

    local parryBtn = mkBtn("ParryBtn", "Parry", 0.05, 0.2, function()
        task.spawn(parry)
    end)

    spamBtn = mkBtn("SpamBtn", "Spam: OFF", 0.55, 0.2, function()
        task.spawn(toggleSpam)
    end)

    local freezeBtn = mkBtn("FreezeBtn", "Freeze", 0.05, 0.4, function()
        getRoot(plr.Character).Anchored = true
    end)

    local unfreezeBtn = mkBtn("UnfreezeBtn", "Unfreeze", 0.55, 0.4, function()
        getRoot(plr.Character).Anchored = false
    end)

    local toggleVisBtn = mkBtn("ToggleVisBtn", "Toggle Effects", 0.05, 0.6, function()
        getgenv().visualizer = not getgenv().visualizer
        toggleVisBtn.BackgroundColor3 = getgenv().visualizer and Color3.fromRGB(0, 120, 0) or Color3.fromRGB(60, 60, 60)
    end)

    local statusLbl = Instance.new("TextLabel")
    statusLbl.Name = "Status"
    statusLbl.Size = UDim2.new(1, -20, 0, 30)
    statusLbl.Position = UDim2.new(0, 10, 0.8, 0)
    statusLbl.BackgroundTransparency = 1
    statusLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    statusLbl.TextSize = 14
    statusLbl.Font = Enum.Font.SourceSans
    statusLbl.Text = "Press R to toggle spam"
    statusLbl.TextXAlignment = Enum.TextXAlignment.Left
    statusLbl.Parent = frame

    local minimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        for _, v in pairs(frame:GetChildren()) do
            if v ~= title and v ~= closeBtn and v ~= minimizeBtn then
                v.Visible = not minimized
            end
        end
        frame.Size = minimized and UDim2.new(0, 250, 0, 30) or UDim2.new(0, 250, 0, 200)
    end)

    UIS.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == Enum.KeyCode.R then
            task.spawn(toggleSpam)
        end
    end)

    function handleBall(ball)
        task.wait(0.1)
        for _, v in ipairs(ball:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Beam") or v:IsA("Trail") or v:IsA("Attachment") then
                task.wait()
                v:Destroy()
            end
        end

        ball.Transparency = 0
        local balls = ClonedService("ReplicatedStorage").Storage.Balls

        local highlight = Instance.new("SelectionBox")
        highlight.Adornee = ball
        highlight.Parent = ball

        if ball.Color == balls.Ball1.Color then
            highlight.Color3 = ball.Color
            highlight.Name = "ball1"
            ClonedService("StarterGui"):SetCore("SendNotification", {
                Title = "Ball Spawned",
                Text = ball.Name,
                Duration = 0.64,
            })
        elseif ball.Color == balls.UltimateBall1.Color then
            ball.Parent = ClonedService("Workspace")
            highlight.Color3 = ball.Color
            highlight.Name = "ultimateball1"
            ClonedService("StarterGui"):SetCore("SendNotification", {
                Title = "Ultimate Ball Spawned",
                Text = ball.Name,
                Duration = 1,
            })
        end
    end

    workspace.Balls.ChildAdded:Connect(handleBall)

    rs.RenderStepped:Connect(function()
        pcall(function()
            local ui = plr.PlayerGui.HUD
            ui.MobileLarge.Visible = UIS.TouchEnabled
            ui.MobileSmall.Visible = false
            ui.Actions.Visible = not UIS.TouchEnabled
            ui.MobileLarge.Block.Visible = false
        end)
    end)

    rs.RenderStepped:Connect(function()
        if spam then
            task.spawn(parry)
        end
    end)
end