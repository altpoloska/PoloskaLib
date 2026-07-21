--[[
    Minimal UI Library  (Mercury-style)
    - Dark, minimalistic theme, smooth animations (Quint InOut), drag & drop
    - Safe tweens (protected against nil / destroyed instances)
    - Minimize into header (top stays fixed) / full hide / close-confirm

    - Made by polosa__
]]

local TweenService     = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")

local Library = { Version = "floating-dropdown-1" }
Library.__index = Library

--// THEME
local Theme = {
    Background   = Color3.fromRGB(18, 18, 20),
    Sidebar      = Color3.fromRGB(24, 24, 27),
    Element      = Color3.fromRGB(30, 30, 34),
    ElementHover = Color3.fromRGB(38, 38, 43),
    Stroke       = Color3.fromRGB(45, 45, 50),
    Accent       = Color3.fromRGB(120, 130, 255),
    Text         = Color3.fromRGB(235, 235, 240),
    SubText      = Color3.fromRGB(140, 140, 150),
    Danger       = Color3.fromRGB(200, 60, 60),
    Discord      = Color3.fromRGB(88, 101, 242),
}

--// Default icons (rbxassetid). Переопределяются через config.Icons
local DefaultIcons = {
    Minimize = "rbxassetid://10734896206",
    Close    = "rbxassetid://10747384394",
    Restore  = "rbxassetid://10734886735",
}

--// Smooth animation preset
local SMOOTH_STYLE = Enum.EasingStyle.Quint
local SMOOTH_DIR   = Enum.EasingDirection.InOut
local SMOOTH_TIME  = 0.4

--// Utils
local function alive(obj)
    return typeof(obj) == "Instance" and (obj.Parent ~= nil or obj:IsDescendantOf(game))
end

local function tween(obj, time, props, style, dir)
    if not alive(obj) then return end
    local ok, t = pcall(function()
        return TweenService:Create(
            obj,
            TweenInfo.new(time, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
            props
        )
    end)
    if ok and t then t:Play() return t end
end

local function resolveIcon(icon)
    if not icon then return "" end
    if type(icon) == "number" then
        return "rbxassetid://" .. icon
    end
    icon = tostring(icon)
    if icon:match("^rbxassetid://") or icon:match("^rbxthumb://") or icon:match("^http") then
        return icon
    end
    local loader = rawget(getfenv(), "getcustomasset") or rawget(getfenv(), "getsynasset")
    if loader then
        local ok, res = pcall(loader, icon)
        if ok and res then return res end
    end
    return icon
end

-- Copy text to clipboard (executor-safe)
local function copyText(str)
    local fn = rawget(getfenv(), "setclipboard")
        or rawget(getfenv(), "toclipboard")
        or rawget(getfenv(), "set_clipboard")
        or (syn and syn.write_clipboard)
    if fn then
        local ok = pcall(fn, tostring(str))
        return ok
    end
    return false
end

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Stroke
    s.Thickness = thickness or 1
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function padding(parent, all)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, all)
    p.PaddingBottom = UDim.new(0, all)
    p.PaddingLeft   = UDim.new(0, all)
    p.PaddingRight  = UDim.new(0, all)
    p.Parent = parent
    return p
end

--// Window dragging
local function makeDraggable(frame, handle)
    local dragging, dragInput, startPos, startFramePos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            startPos = input.Position
            startFramePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            if not alive(frame) then dragging = false return end
            local delta = input.Position - startPos
            frame.Position = UDim2.new(
                startFramePos.X.Scale, startFramePos.X.Offset + delta.X,
                startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y
            )
        end
    end)
end

--============================================================
--  CREATE WINDOW
--============================================================
function Library:Create(config)
    config = config or {}
    local window = setmetatable({}, Library)
    window.Tabs = {}
    window.Visible = true
    window.Minimized = false
    window.UserScale = math.clamp(tonumber(config.Scale) or 1, 0.50, 1.25)
    window.AutoScale = config.AutoScale ~= false
    window.ToggleButtonVisible = config.ShowToggleButton ~= false

    local icons = {}
    for k, v in pairs(DefaultIcons) do icons[k] = v end
    if config.Icons then
        for k, v in pairs(config.Icons) do icons[k] = v end
    end

    -- This executor requires Plugin capability for descendants of CoreGui/gethui.
    -- Keep the whole UI in PlayerGui so tabs, groups, notifications, and controls
    -- can be created later from ordinary callback threads without permission errors.
    local guiParent = Players.LocalPlayer:WaitForChild("PlayerGui")
    local old = guiParent:FindFirstChild("MinimalUI")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui")
    gui.Name = "MinimalUI"
    gui.ResetOnSpawn = false
    -- Keep this ScreenGui above ordinary PlayerGui interfaces without using CoreGui.
    gui.DisplayOrder = 2147483647
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    gui.IgnoreGuiInset = true
    gui.Enabled = true
    gui.Parent = guiParent
    window.Gui = gui

    -- Main window
    local size = config.Size or UDim2.fromOffset(600, 400)
    window.WindowSize = size

    local main = Instance.new("Frame")
    main.Name = "Main"
    main.Size = UDim2.fromOffset(0, 0)
    main.Position = UDim2.new(0.5, 0, 0.5, -size.Y.Offset/2)
    main.AnchorPoint = Vector2.new(0.5, 0)   -- верх фиксирован
    main.BackgroundColor3 = Theme.Background
    main.BorderSizePixel = 0
    main.ClipsDescendants = true
    main.Parent = gui
    corner(main, 12)
    stroke(main, Theme.Stroke, 1)

    local uiScale = Instance.new("UIScale")
    uiScale.Name = "ResponsiveScale"
    uiScale.Scale = window.UserScale
    uiScale.Parent = main
    window.ScaleObject = uiScale

    local cameraConnection
    local function applyResponsiveScale()
        if not alive(main) or not alive(uiScale) then return end
        local effective = window.UserScale
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize
        if window.AutoScale and UserInputService.TouchEnabled and viewport then
            local fitX = math.max(0.50, (viewport.X - 24) / math.max(size.X.Offset, 1))
            local fitY = math.max(0.50, (viewport.Y - 54) / math.max(size.Y.Offset, 1))
            -- Automatic mobile scaling may shrink the desktop layout to fit,
            -- but must never enlarge it above the 75% mobile cap after
            -- viewport/orientation changes.
            effective = math.min(effective, fitX, fitY, 0.75)
        end
        effective = math.clamp(effective, 0.50, 1.25)
        uiScale.Scale = effective
        window.EffectiveScale = effective
        -- Keep the top edge vertically centered exactly as before, now using
        -- the rendered height rather than the unscaled desktop height.
        main.Position = UDim2.new(0.5, 0, 0.5, -(size.Y.Offset * effective) / 2)
    end
    window._applyResponsiveScale = applyResponsiveScale
    applyResponsiveScale()
    if workspace.CurrentCamera then
        cameraConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveScale)
    end
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        if cameraConnection then cameraConnection:Disconnect() end
        if workspace.CurrentCamera then
            cameraConnection = workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(applyResponsiveScale)
        end
        applyResponsiveScale()
    end)

    tween(main, 0.35, {Size = size}, SMOOTH_STYLE, SMOOTH_DIR)

    -- Topbar
    local topbar = Instance.new("Frame")
    topbar.Name = "Topbar"
    topbar.Size = UDim2.new(1, 0, 0, 42)
    topbar.BackgroundColor3 = Theme.Sidebar
    topbar.BorderSizePixel = 0
    topbar.Parent = main
    corner(topbar, 12)

    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 12)
    topFix.Position = UDim2.new(0, 0, 1, -12)
    topFix.BackgroundColor3 = Theme.Sidebar
    topFix.BorderSizePixel = 0
    topFix.Parent = topbar

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -120, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamMedium
    title.Text = config.Name or "Minimal UI"
    title.TextColor3 = Theme.Text
    title.TextSize = 15
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = topbar

    makeDraggable(main, topbar)

    local function makeIconButton(iconId, xOffset, hoverColor)
        local b = Instance.new("ImageButton")
        b.Size = UDim2.fromOffset(28, 28)
        b.Position = UDim2.new(1, xOffset, 0.5, 0)
        b.AnchorPoint = Vector2.new(0, 0.5)
        b.BackgroundColor3 = Theme.Element
        b.AutoButtonColor = false
        b.Image = resolveIcon(iconId)
        b.ImageColor3 = Theme.SubText
        b.ScaleType = Enum.ScaleType.Fit
        b.Parent = topbar
        corner(b, 6)
        local ic = Instance.new("UIPadding")
        ic.PaddingTop = UDim.new(0,7); ic.PaddingBottom = UDim.new(0,7)
        ic.PaddingLeft = UDim.new(0,7); ic.PaddingRight = UDim.new(0,7)
        ic.Parent = b
        b.MouseEnter:Connect(function()
            tween(b, .15, {BackgroundColor3 = hoverColor, ImageColor3 = Theme.Text})
        end)
        b.MouseLeave:Connect(function()
            tween(b, .15, {BackgroundColor3 = Theme.Element, ImageColor3 = Theme.SubText})
        end)
        return b
    end

    -- Close button -> confirm dialog
    local closeBtn = makeIconButton(icons.Close, -36, Theme.Danger)
    closeBtn.MouseButton1Click:Connect(function()
        window:Confirm{
            Title = "Close menu?",
            Text = "Are you sure you want to close the UI?",
            ConfirmText = "Close",
            CancelText = "Cancel",
            OnConfirm = function()
                local t = tween(main, SMOOTH_TIME, {Size = UDim2.fromOffset(0,0)}, SMOOTH_STYLE, SMOOTH_DIR)
                if t then t.Completed:Wait() end
                if alive(gui) then gui:Destroy() end
            end
        }
    end)

    -- Minimize button -> collapse into header
    local minBtn = makeIconButton(icons.Minimize, -70, Theme.ElementHover)
    window.MinimizeButton = minBtn
    window.MinimizeIcon = icons.Minimize
    window.RestoreIcon  = icons.Restore
    minBtn.MouseButton1Click:Connect(function()
        window:ToggleMinimize()
    end)

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 150, 1, -42)
    sidebar.Position = UDim2.new(0, 0, 0, 42)
    sidebar.BackgroundColor3 = Theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main

    local tabList = Instance.new("ScrollingFrame")
    tabList.Size = UDim2.new(1, 0, 1, 0)
    tabList.BackgroundTransparency = 1
    tabList.BorderSizePixel = 0
    tabList.ScrollBarThickness = 0
    tabList.CanvasSize = UDim2.new(0,0,0,0)
    tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
    tabList.Parent = sidebar
    padding(tabList, 10)
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.Padding = UDim.new(0, 6)
    tabLayout.Parent = tabList

    -- Content container
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(1, -150, 1, -42)
    container.Position = UDim2.new(0, 150, 0, 42)
    container.BackgroundTransparency = 1
    container.Parent = main

    window.Container = container
    window.TabList = tabList
    window.Main = main
    window.Body = { sidebar, container }

    -- Toggle key: press to hide / show whole UI
    window.ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not alive(main) then return end
        if input.KeyCode == window.ToggleKey then
            window:Toggle()
        end
    end)

    -- Persistent launcher for both touch and desktop. It remains outside Main,
    -- so it can restore the menu after the menu itself has been hidden.
    local launcher = Instance.new("ImageButton")
    launcher.Name = "PoloskaLauncher"
    launcher.Size = UDim2.fromOffset(54, 54)
    launcher.Position = UDim2.new(0, 16, 0.5, -27)
    launcher.BackgroundColor3 = Theme.Background
    launcher.BackgroundTransparency = 0.08
    launcher.BorderSizePixel = 0
    launcher.AutoButtonColor = false
    launcher.Image = resolveIcon(config.ToggleButtonAsset or "rbxassetid://76774068789424")
    launcher.ScaleType = Enum.ScaleType.Fit
    launcher.Visible = window.ToggleButtonVisible
    launcher.ZIndex = 20000
    launcher.Parent = gui
    corner(launcher, 14)
    stroke(launcher, Theme.Stroke, 1)
    local launcherPadding = Instance.new("UIPadding")
    launcherPadding.PaddingTop = UDim.new(0, 5)
    launcherPadding.PaddingBottom = UDim.new(0, 5)
    launcherPadding.PaddingLeft = UDim.new(0, 5)
    launcherPadding.PaddingRight = UDim.new(0, 5)
    launcherPadding.Parent = launcher
    launcher.Activated:Connect(function()
        window:Toggle()
    end)
    makeDraggable(launcher, launcher)
    window.Launcher = launcher

    return window
end

function Library:SetToggleKey(key)
    if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
        self.ToggleKey = key
        return true
    end
    return false
end

function Library:SetScale(scale)
    self.UserScale = math.clamp(tonumber(scale) or 1, 0.50, 1.25)
    if self._applyResponsiveScale then self._applyResponsiveScale() end
end

function Library:SetAutoScale(enabled)
    self.AutoScale = enabled == true
    if self._applyResponsiveScale then self._applyResponsiveScale() end
end

function Library:SetToggleButtonVisible(visible)
    self.ToggleButtonVisible = visible == true
    if alive(self.Launcher) then self.Launcher.Visible = self.ToggleButtonVisible end
end

--============================================================
--  SHOW / HIDE (полностью прячет UI)
--============================================================
function Library:Toggle()
    if not alive(self.Main) then return end
    self.Visible = not self.Visible
    if self.Visible then
        self.Main.Visible = true
        local target = self.Minimized
            and UDim2.new(self.WindowSize.X.Scale, self.WindowSize.X.Offset, 0, 42)
            or self.WindowSize
        tween(self.Main, SMOOTH_TIME, {Size = target}, SMOOTH_STYLE, SMOOTH_DIR)
    else
        local t = tween(self.Main, SMOOTH_TIME, {Size = UDim2.fromOffset(0, 0)}, SMOOTH_STYLE, SMOOTH_DIR)
        if t then
            t.Completed:Connect(function()
                if (not self.Visible) and alive(self.Main) then
                    self.Main.Visible = false
                end
            end)
        else
            self.Main.Visible = false
        end
    end
end

function Library:Show() if not self.Visible then self:Toggle() end end
function Library:Hide() if self.Visible then self:Toggle() end end

--============================================================
--  MINIMIZE / RESTORE (сворачивает в шапку, верх фиксирован)
--============================================================
function Library:ToggleMinimize()
    if not alive(self.Main) then return end
    self.Minimized = not self.Minimized
    if self.Minimized then
        for _, obj in ipairs(self.Body) do
            if alive(obj) then obj.Visible = false end
        end
        tween(self.Main, SMOOTH_TIME, {
            Size = UDim2.new(self.WindowSize.X.Scale, self.WindowSize.X.Offset, 0, 42)
        }, SMOOTH_STYLE, SMOOTH_DIR)
        if alive(self.MinimizeButton) then
            self.MinimizeButton.Image = resolveIcon(self.RestoreIcon)
        end
    else
        for _, obj in ipairs(self.Body) do
            if alive(obj) then obj.Visible = true end
        end
        tween(self.Main, SMOOTH_TIME, {Size = self.WindowSize}, SMOOTH_STYLE, SMOOTH_DIR)
        if alive(self.MinimizeButton) then
            self.MinimizeButton.Image = resolveIcon(self.MinimizeIcon)
        end
    end
end

--============================================================
--  CONFIRM DIALOG
--============================================================
function Library:Confirm(opts)
    opts = opts or {}
    if not alive(self.Gui) then return end

    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    overlay.BackgroundTransparency = 1
    overlay.ZIndex = 100
    overlay.Parent = self.Gui
    tween(overlay, .2, {BackgroundTransparency = 0.5})

    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(300, 150)
    box.Position = UDim2.new(0.5, 0, 0.5, 0)
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.BackgroundColor3 = Theme.Background
    box.BackgroundTransparency = 1
    box.ZIndex = 101
    box.Parent = overlay
    corner(box, 12)
    stroke(box, Theme.Stroke, 1)
    tween(box, .25, {BackgroundTransparency = 0}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -32, 0, 24)
    title.Position = UDim2.new(0, 16, 0, 18)
    title.BackgroundTransparency = 1
    title.Text = opts.Title or "Are you sure?"
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 102
    title.Parent = box

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -32, 0, 40)
    desc.Position = UDim2.new(0, 16, 0, 48)
    desc.BackgroundTransparency = 1
    desc.Text = opts.Text or ""
    desc.TextColor3 = Theme.SubText
    desc.Font = Enum.Font.Gotham
    desc.TextSize = 13
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.ZIndex = 102
    desc.Parent = box

    local function close()
        local t = tween(overlay, .2, {BackgroundTransparency = 1})
        tween(box, .2, {BackgroundTransparency = 1})
        if t then
            t.Completed:Connect(function() if alive(overlay) then overlay:Destroy() end end)
        elseif alive(overlay) then
            overlay:Destroy()
        end
    end

    local function makeBtn(text, xScale, danger, cb)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(0.5, -22, 0, 34)
        b.Position = UDim2.new(xScale, xScale == 0 and 16 or 6, 1, -50)
        b.BackgroundColor3 = danger and Theme.Danger or Theme.Element
        b.Text = text
        b.TextColor3 = Theme.Text
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 14
        b.AutoButtonColor = false
        b.ZIndex = 102
        b.Parent = box
        corner(b, 8)
        b.MouseButton1Click:Connect(function()
            close()
            if cb then cb() end
        end)
        return b
    end

    makeBtn(opts.CancelText or "Cancel", 0, false, opts.OnCancel)
    makeBtn(opts.ConfirmText or "Confirm", 0.5, true, opts.OnConfirm)
end

--============================================================
--  NOTIFICATIONS
--============================================================
function Library:Notification(cfg)
    cfg = cfg or {}
    local gui = self.Gui
    if not alive(gui) then return end

    local holder = gui:FindFirstChild("NotifHolder")
    if not holder then
        holder = Instance.new("Frame")
        holder.Name = "NotifHolder"
        holder.Size = UDim2.new(0, 300, 1, -20)
        holder.Position = UDim2.new(1, -310, 0, 10)
        holder.BackgroundTransparency = 1
        holder.ZIndex = 90
        holder.Parent = gui
        local l = Instance.new("UIListLayout")
        l.VerticalAlignment = Enum.VerticalAlignment.Bottom
        l.HorizontalAlignment = Enum.HorizontalAlignment.Right
        l.Padding = UDim.new(0, 8)
        l.Parent = holder
    end

    local notif = Instance.new("Frame")
    notif.Size = UDim2.new(0, 300, 0, 0)
    notif.BackgroundColor3 = Theme.Element
    notif.BorderSizePixel = 0
    notif.ClipsDescendants = true
    notif.ZIndex = 91
    notif.Parent = holder
    corner(notif, 8)
    stroke(notif, Theme.Stroke, 1)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 20)
    title.Position = UDim2.new(0, 12, 0, 10)
    title.BackgroundTransparency = 1
    title.Text = cfg.Title or "Notification"
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = 14
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = 92
    title.Parent = notif

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -20, 0, 30)
    text.Position = UDim2.new(0, 12, 0, 30)
    text.BackgroundTransparency = 1
    text.Text = cfg.Text or ""
    text.TextColor3 = Theme.SubText
    text.Font = Enum.Font.Gotham
    text.TextSize = 12
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.ZIndex = 92
    text.Parent = notif

    tween(notif, .3, {Size = UDim2.new(0, 300, 0, 70)})
    task.delay(cfg.Duration or 3, function()
        local t = tween(notif, .3, {Size = UDim2.new(0, 300, 0, 0)})
        if t then t.Completed:Wait() end
        if alive(notif) then notif:Destroy() end
    end)
end

--============================================================
--  TAB
--============================================================
function Library:Tab(config)
    config = config or {}
    local tab = {}
    local win = self   -- ссылка на окно (для уведомлений из элементов)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 34)
    btn.BackgroundColor3 = Theme.Element
    btn.BackgroundTransparency = 1
    btn.Text = "  " .. (config.Name or "Tab")
    btn.TextColor3 = Theme.SubText
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 14
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.Parent = self.TabList
    corner(btn, 7)

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = Theme.Stroke
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = self.Container
    padding(page, 14)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.Parent = page

    tab.TabButton = btn
    tab.Page = page
    tab._popups = {}
    tab._popupClosers = {}

    local function closeAllPopups()
        for _, closePopup in ipairs(tab._popupClosers) do pcall(closePopup) end
    end
    page:GetPropertyChangedSignal("CanvasPosition"):Connect(closeAllPopups)

    local function activate()
        -- These assignments intentionally do not tween. A hover tween can still
        -- be running when a tab changes; direct values guarantee that inactive
        -- tabs immediately return to their transparent, muted state.
        for _, t in pairs(self.Tabs) do
            if t.Page then t.Page.Visible = false end
            t._active = false
            if t._popups then
                for _, popup in ipairs(t._popups) do
                    if alive(popup) then popup.Visible = false end
                end
            end
            if t.TabButton then
                t.TabButton.BackgroundTransparency = 1
                t.TabButton.BackgroundColor3 = Theme.Element
                t.TabButton.TextColor3 = Theme.SubText
            end
        end
        page.Visible = true
        tab._active = true
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Theme.ElementHover
        btn.TextColor3 = Theme.Text
    end

    btn.MouseButton1Click:Connect(activate)
    btn.MouseEnter:Connect(function()
        if not tab._active then
            btn.BackgroundTransparency = 0
            btn.BackgroundColor3 = Theme.Element
            btn.TextColor3 = Theme.Text
        end
    end)
    btn.MouseLeave:Connect(function()
        if not tab._active then
            btn.BackgroundTransparency = 1
            btn.BackgroundColor3 = Theme.Element
            btn.TextColor3 = Theme.SubText
        end
    end)

    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then activate() end

    local function baseElement(height)
        local f = Instance.new("Frame")
        local target = tab._target or page
        f.Size = target == page
            and UDim2.new(0.8, 0, 0, height or 40)
            or UDim2.new(1, 0, 0, height or 40)
        f.BackgroundColor3 = Theme.Element
        f.BorderSizePixel = 0
        f.Parent = target
        corner(f, 8)
        stroke(f, Theme.Stroke, 1)
        return f
    end

    -- Group: a titled card that accepts the same controls as a tab.
    -- Existing tab:Toggle/Slider/etc. calls remain fully compatible.
    function tab:Group(cfg)
        cfg = cfg or {}
        local host = cfg.Parent or page
        local collapsible = cfg.Collapsible ~= false
        local collapsed = collapsible and cfg.Collapsed == true or false
        local card = Instance.new("Frame")
        card.Name = "Group_" .. tostring(cfg.Name or "Section")
        card.Size = host == page
            and UDim2.new(0.8, 0, 0, 0)
            or UDim2.new(1, 0, 0, 0)
        card.AutomaticSize = Enum.AutomaticSize.Y
        card.BackgroundColor3 = Theme.Element
        card.BorderSizePixel = 0
        card.ClipsDescendants = true
        card.Parent = host
        corner(card, 10)
        stroke(card, Theme.Stroke, 1)
        padding(card, 12)

        local cardLayout = Instance.new("UIListLayout")
        cardLayout.Padding = UDim.new(0, 8)
        cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
        cardLayout.Parent = card

        local header = Instance.new("Frame")
        header.Name = "Header"
        header.Size = UDim2.new(1, 0, 0, 20)
        header.BackgroundTransparency = 1
        header.Parent = card

        local title = Instance.new("TextLabel")
        title.Name = "Title"
        title.Size = UDim2.new(1, collapsible and -26 or 0, 1, 0)
        title.BackgroundTransparency = 1
        title.Text = cfg.Name or "Section"
        title.TextColor3 = Theme.Text
        title.Font = Enum.Font.GothamBold
        title.TextSize = 15
        title.TextXAlignment = Enum.TextXAlignment.Left
        title.Parent = header

        local chevron
        if collapsible then
            chevron = Instance.new("Frame")
            chevron.Name = "CollapseChevron"
            chevron.Size = UDim2.fromOffset(16, 16)
            chevron.AnchorPoint = Vector2.new(0.5, 0.5)
            chevron.Position = UDim2.new(1, -8, 0.5, 0)
            chevron.BackgroundTransparency = 1
            chevron.Parent = header

            local left = Instance.new("Frame")
            left.Size = UDim2.fromOffset(7, 2)
            left.AnchorPoint = Vector2.new(1, 0.5)
            left.Position = UDim2.fromOffset(8, 8)
            left.Rotation = 45
            left.BackgroundColor3 = Theme.SubText
            left.BorderSizePixel = 0
            left.Parent = chevron
            corner(left, 2)

            local right = Instance.new("Frame")
            right.Size = UDim2.fromOffset(7, 2)
            right.AnchorPoint = Vector2.new(0, 0.5)
            right.Position = UDim2.fromOffset(8, 8)
            right.Rotation = -45
            right.BackgroundColor3 = Theme.SubText
            right.BorderSizePixel = 0
            right.Parent = chevron
            corner(right, 2)
        end

        local description
        if cfg.Description and cfg.Description ~= "" then
            description = Instance.new("TextLabel")
            description.Name = "Description"
            description.Size = UDim2.new(1, 0, 0, 0)
            description.AutomaticSize = Enum.AutomaticSize.Y
            description.BackgroundTransparency = 1
            description.Text = cfg.Description
            description.TextColor3 = Theme.SubText
            description.Font = Enum.Font.Gotham
            description.TextSize = 12
            description.TextWrapped = true
            description.TextXAlignment = Enum.TextXAlignment.Left
            description.TextYAlignment = Enum.TextYAlignment.Top
            description.Parent = card
        end

        local content = Instance.new("Frame")
        content.Name = "Content"
        content.Size = UDim2.new(1, 0, 0, 0)
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.BackgroundTransparency = 1
        content.Parent = card
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.Padding = UDim.new(0, 6)
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Parent = content

        local function setCollapsed(value)
            if not collapsible then value = false end
            collapsed = value == true
            content.Visible = not collapsed
            if description then description.Visible = not collapsed end
            if chevron then chevron.Rotation = collapsed and -90 or 0 end
        end

        if collapsible then
            local trigger = Instance.new("TextButton")
            trigger.Name = "CollapseButton"
            trigger.Size = UDim2.new(1, 0, 1, 0)
            trigger.BackgroundTransparency = 1
            trigger.Text = ""
            trigger.AutoButtonColor = false
            trigger.ZIndex = 2
            trigger.Parent = header
            trigger.MouseButton1Click:Connect(function() setCollapsed(not collapsed) end)
        end

        local group = { Frame = card, Content = content, Header = header }
        function group:SetCollapsed(value) setCollapsed(value) end
        function group:ToggleCollapsed() setCollapsed(not collapsed) end
        function group:IsCollapsed() return collapsed end

        local function callInGroup(method, arg)
            local previous = tab._target
            tab._target = content
            local result = tab[method](tab, arg)
            tab._target = previous
            return result
        end
        for _, method in ipairs({ "Button", "Toggle", "Slider", "Textbox", "Dropdown", "MultiDropdown", "Keybind", "Credit", "Section" }) do
            group[method] = function(_, arg)
                return callInGroup(method, arg)
            end
        end
        setCollapsed(collapsed)
        return group
    end

    tab.Card = tab.Group

    -- Columns creates equal-width, self-sizing columns. Put Group cards in
    -- Columns.Left / Columns.Right to avoid one long vertical settings list.
    function tab:Columns(cfg)
        cfg = cfg or {}
        local host = cfg.Parent or page
        local gap = cfg.Gap or 8
        local row = Instance.new("Frame")
        row.Name = "Columns"
        row.Size = UDim2.new(1, 0, 0, 0)
        row.BackgroundTransparency = 1
        row.Parent = host

        local left = Instance.new("Frame")
        left.Name = "Left"
        left.Size = UDim2.new(0.5, -gap / 2, 0, 0)
        left.AutomaticSize = Enum.AutomaticSize.Y
        left.BackgroundTransparency = 1
        left.Parent = row
        local leftLayout = Instance.new("UIListLayout")
        leftLayout.Padding = UDim.new(0, gap)
        leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        leftLayout.Parent = left

        local right = Instance.new("Frame")
        right.Name = "Right"
        right.Size = UDim2.new(0.5, -gap / 2, 0, 0)
        right.Position = UDim2.new(0.5, gap / 2, 0, 0)
        right.AutomaticSize = Enum.AutomaticSize.Y
        right.BackgroundTransparency = 1
        right.Parent = row
        local rightLayout = Instance.new("UIListLayout")
        rightLayout.Padding = UDim.new(0, gap)
        rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        rightLayout.Parent = right

        local function syncHeight()
            if alive(row) then
                row.Size = UDim2.new(1, 0, 0, math.max(leftLayout.AbsoluteContentSize.Y, rightLayout.AbsoluteContentSize.Y))
            end
        end
        leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncHeight)
        rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncHeight)
        task.defer(syncHeight)
        return { Frame = row, Left = left, Right = right }
    end

    --// BUTTON
    function tab:Button(cfg)
        cfg = cfg or {}
        local f = baseElement(40)
        local b = Instance.new("TextButton")
        b.Size = UDim2.new(1, 0, 1, 0)
        b.BackgroundTransparency = 1
        b.Text = cfg.Name or "Button"
        b.TextColor3 = Theme.Text
        b.Font = Enum.Font.GothamMedium
        b.TextSize = 14
        b.Parent = f
        b.MouseEnter:Connect(function() tween(f, .15, {BackgroundColor3 = Theme.ElementHover}) end)
        b.MouseLeave:Connect(function() tween(f, .15, {BackgroundColor3 = Theme.Element}) end)
        b.MouseButton1Click:Connect(function()
            if cfg.Callback then cfg.Callback() end
        end)
        return f
    end

    --// TOGGLE
    function tab:Toggle(cfg)
        cfg = cfg or {}
        local state = cfg.StartingState or false
        local f = baseElement(48)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -82, 1, -8)
        label.Position = UDim2.new(0, 14, 0, 4)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Toggle"
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.TextWrapped = true
        label.TextYAlignment = Enum.TextYAlignment.Center
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = f

        local switch = Instance.new("TextButton")
        switch.Size = UDim2.fromOffset(40, 22)
        switch.Position = UDim2.new(1, -54, 0.5, 0)
        switch.AnchorPoint = Vector2.new(0, 0.5)
        switch.BackgroundColor3 = Theme.Stroke
        switch.Text = ""
        switch.AutoButtonColor = false
        switch.Parent = f
        corner(switch, 11)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(16, 16)
        knob.Position = UDim2.new(0, 3, 0.5, 0)
        knob.AnchorPoint = Vector2.new(0, 0.5)
        knob.BackgroundColor3 = Theme.Text
        knob.BorderSizePixel = 0
        knob.Parent = switch
        corner(knob, 8)

        local function update()
            if state then
                tween(switch, .2, {BackgroundColor3 = Theme.Accent})
                tween(knob, .2, {Position = UDim2.new(0, 21, 0.5, 0)})
            else
                tween(switch, .2, {BackgroundColor3 = Theme.Stroke})
                tween(knob, .2, {Position = UDim2.new(0, 3, 0.5, 0)})
            end
            if cfg.Callback then cfg.Callback(state) end
        end
        switch.MouseButton1Click:Connect(function()
            state = not state
            update()
        end)
        if state then update() end
        return {
            Set = function(_, v) state = v; update() end,
            Get = function() return state end
        }
    end

    --// SLIDER
    function tab:Slider(cfg)
        cfg = cfg or {}
        local min, max = cfg.Min or 0, cfg.Max or 100
        local value = cfg.Default or min
        local f = baseElement(54)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -60, 0, 20)
        label.Position = UDim2.new(0, 14, 0, 8)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Slider"
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = f

        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0, 50, 0, 20)
        valLabel.Position = UDim2.new(1, -60, 0, 8)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(value)
        valLabel.TextColor3 = Theme.SubText
        valLabel.Font = Enum.Font.GothamMedium
        valLabel.TextSize = 13
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent = f

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -28, 0, 6)
        bar.Position = UDim2.new(0, 14, 1, -16)
        bar.BackgroundColor3 = Theme.Stroke
        bar.BorderSizePixel = 0
        bar.Parent = f
        corner(bar, 3)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
        fill.BackgroundColor3 = Theme.Accent
        fill.BorderSizePixel = 0
        fill.Parent = bar
        corner(fill, 3)

        local dragging = false
        local activeTouch = nil
        local touchStart = nil
        local touchCommitted = false
        local function set(x)
            if not alive(bar) then dragging = false return end
            local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * rel + 0.5)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valLabel.Text = tostring(value)
            if cfg.Callback then cfg.Callback(value) end
        end
        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                set(i.Position.X)
            elseif i.UserInputType == Enum.UserInputType.Touch then
                -- Do not change a slider on touch-down: that gesture may be a
                -- vertical page scroll which merely started over the bar.
                activeTouch = i
                touchStart = i.Position
                touchCommitted = false
                dragging = false
            end
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            elseif i.UserInputType == Enum.UserInputType.Touch and i == activeTouch then
                -- A stationary tap is intentional. A vertical gesture clears
                -- activeTouch below and therefore never changes the value.
                if not touchCommitted and touchStart then set(i.Position.X) end
                dragging = false
                activeTouch = nil
                touchStart = nil
                touchCommitted = false
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseMovement and dragging
                and activeTouch == nil then
                set(i.Position.X)
            elseif i.UserInputType == Enum.UserInputType.Touch and i == activeTouch
                and touchStart then
                local delta = i.Position - touchStart
                if not touchCommitted then
                    if math.max(math.abs(delta.X), math.abs(delta.Y)) < 8 then return end
                    if math.abs(delta.Y) > math.abs(delta.X) then
                        -- Hand the gesture back to the ScrollingFrame.
                        dragging = false
                        activeTouch = nil
                        touchStart = nil
                        return
                    end
                    touchCommitted = true
                    dragging = true
                end
                if dragging then set(i.Position.X) end
            end
        end)
        return {
            Set = function(_, v)
                value = v
                local rel = (v-min)/(max-min)
                if alive(fill) then fill.Size = UDim2.new(rel,0,1,0) end
                if alive(valLabel) then valLabel.Text = tostring(v) end
            end
        }
    end

    --// TEXTBOX
    function tab:Textbox(cfg)
        cfg = cfg or {}
        local stacked = cfg.Stacked == true
        local f = baseElement(stacked and 72 or 40)
        local label = Instance.new("TextLabel")
        label.Size = stacked
            and UDim2.new(1, -28, 0, 24)
            or UDim2.new(0.5, -14, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Textbox"
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 14
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = f

        local boxFrame = Instance.new("Frame")
        boxFrame.Size = stacked
            and UDim2.new(1, -28, 0, 30)
            or UDim2.new(0.5, -14, 0, 26)
        boxFrame.Position = stacked
            and UDim2.new(0, 14, 0, 34)
            or UDim2.new(0.5, 0, 0.5, 0)
        boxFrame.AnchorPoint = stacked and Vector2.new(0, 0) or Vector2.new(0, 0.5)
        boxFrame.BackgroundColor3 = Theme.Background
        boxFrame.BorderSizePixel = 0
        -- Long values (notably Discord webhook URLs) must stay inside the
        -- rounded input frame instead of rendering over adjacent UI/gameplay.
        boxFrame.ClipsDescendants = true
        boxFrame.Parent = f
        corner(boxFrame, 6)
        stroke(boxFrame, Theme.Stroke, 1)

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -12, 1, 0)
        box.Position = UDim2.new(0, 6, 0, 0)
        box.BackgroundTransparency = 1
        box.Text = cfg.Default or ""
        box.PlaceholderText = cfg.Placeholder or "Type here..."
        box.PlaceholderColor3 = Theme.SubText
        box.TextColor3 = Theme.Text
        box.Font = Enum.Font.Gotham
        box.TextSize = 13
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.TextTruncate = Enum.TextTruncate.AtEnd
        box.ClipsDescendants = true
        box.ClearTextOnFocus = false
        box.Parent = boxFrame
        box.FocusLost:Connect(function()
            if cfg.Callback then cfg.Callback(box.Text) end
        end)
        return f
    end

    --// DROPDOWN (overlay popup: it never resizes the page/card)
    function tab:Dropdown(cfg)
        cfg = cfg or {}
        local items = cfg.Items or {}
        local open = false
        local f = baseElement(44)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -190, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Dropdown"
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = f

        local selected = Instance.new("TextLabel")
        selected.Size = UDim2.new(0, 150, 1, 0)
        selected.Position = UDim2.new(1, -176, 0, 0)
        selected.BackgroundTransparency = 1
        selected.Text = cfg.StartingText or "Select..."
        selected.TextColor3 = Theme.SubText
        selected.Font = Enum.Font.Gotham
        selected.TextSize = 13
        selected.TextTruncate = Enum.TextTruncate.AtEnd
        selected.TextXAlignment = Enum.TextXAlignment.Right
        selected.Parent = f

        -- Font-independent vector chevron. The old Unicode glyph rendered as
        -- a missing-character square on clients whose Roblox font lacked it.
        local arrow = Instance.new("Frame")
        arrow.Name = "Chevron"
        arrow.Size = UDim2.fromOffset(16, 16)
        arrow.AnchorPoint = Vector2.new(0.5, 0.5)
        arrow.Position = UDim2.new(1, -17, 0.5, 0)
        arrow.BackgroundTransparency = 1
        arrow.ZIndex = 103
        arrow.Parent = f

        local arrowLeft = Instance.new("Frame")
        arrowLeft.Size = UDim2.fromOffset(7, 2)
        arrowLeft.AnchorPoint = Vector2.new(1, 0.5)
        arrowLeft.Position = UDim2.fromOffset(8, 8)
        arrowLeft.Rotation = 45
        arrowLeft.BackgroundColor3 = Theme.SubText
        arrowLeft.BorderSizePixel = 0
        arrowLeft.ZIndex = 104
        arrowLeft.Parent = arrow
        corner(arrowLeft, 2)

        local arrowRight = Instance.new("Frame")
        arrowRight.Size = UDim2.fromOffset(7, 2)
        arrowRight.AnchorPoint = Vector2.new(0, 0.5)
        arrowRight.Position = UDim2.fromOffset(8, 8)
        arrowRight.Rotation = -45
        arrowRight.BackgroundColor3 = Theme.SubText
        arrowRight.BorderSizePixel = 0
        arrowRight.ZIndex = 104
        arrowRight.Parent = arrow
        corner(arrowRight, 2)

        local trigger = Instance.new("TextButton")
        trigger.Size = UDim2.new(1, 0, 1, 0)
        trigger.BackgroundTransparency = 1
        trigger.Text = ""
        trigger.ZIndex = 102
        trigger.Parent = f

        local popup = Instance.new("ScrollingFrame")
        popup.Name = "DropdownOverlay"
        popup.Visible = false
        popup.BackgroundColor3 = Theme.Element
        popup.BorderSizePixel = 0
        popup.ScrollBarThickness = 3
        popup.ScrollBarImageColor3 = Theme.Stroke
        popup.CanvasSize = UDim2.new(0, 0, 0, 0)
        popup.AutomaticCanvasSize = Enum.AutomaticSize.Y
        popup.ZIndex = 10000
        popup.Parent = win.Main
        corner(popup, 8)
        stroke(popup, Theme.Stroke, 1)
        padding(popup, 6)
        local popupLayout = Instance.new("UIListLayout")
        popupLayout.Padding = UDim.new(0, 4)
        popupLayout.SortOrder = Enum.SortOrder.LayoutOrder
        popupLayout.Parent = popup
        table.insert(tab._popups, popup)

        local function close()
            open = false
            if alive(popup) then popup.Visible = false end
            if alive(arrow) then arrow.Rotation = 0 end
        end

        table.insert(tab._popupClosers, close)

        local function rebuild()
            for _, child in ipairs(popup:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for _, item in ipairs(items) do
                local itemName = type(item) == "table" and item[1] or tostring(item)
                local itemButton = Instance.new("TextButton")
                itemButton.Size = UDim2.new(1, 0, 0, 30)
                itemButton.BackgroundColor3 = Theme.Background
                itemButton.BorderSizePixel = 0
                itemButton.Text = itemName
                itemButton.TextColor3 = Theme.SubText
                itemButton.Font = Enum.Font.Gotham
                itemButton.TextSize = 13
                itemButton.TextXAlignment = Enum.TextXAlignment.Left
                itemButton.AutoButtonColor = false
                itemButton.ZIndex = 10001
                itemButton.Parent = popup
                corner(itemButton, 6)
                local itemPadding = Instance.new("UIPadding")
                itemPadding.PaddingLeft = UDim.new(0, 10)
                itemPadding.Parent = itemButton
                itemButton.MouseEnter:Connect(function()
                    tween(itemButton, .1, {BackgroundColor3 = Theme.ElementHover, TextColor3 = Theme.Text})
                end)
                itemButton.MouseLeave:Connect(function()
                    tween(itemButton, .1, {BackgroundColor3 = Theme.Background, TextColor3 = Theme.SubText})
                end)
                itemButton.MouseButton1Click:Connect(function()
                    selected.Text = itemName
                    close()
                    if cfg.Callback then cfg.Callback(item) end
                end)
            end
        end
        rebuild()

        local function show()
            for _, other in ipairs(tab._popups) do
                if other ~= popup and alive(other) then other.Visible = false end
            end
            -- Dropdown rows have a fixed 44px height. Anchor with that fixed
            -- height instead of an automatic-layout AbsoluteSize, which can be
            -- reported as zero for one frame and place the first option on top
            -- of the trigger button.
            local height = math.min(196, (#items * 34) + 12)
            popup.Size = UDim2.fromOffset(math.max(180, f.AbsoluteSize.X), height)
            -- f.AbsolutePosition is screen-relative. Convert it to the local
            -- coordinate system of the draggable main window / portal parent.
            popup.Position = UDim2.fromOffset(
                f.AbsolutePosition.X - win.Main.AbsolutePosition.X,
                f.AbsolutePosition.Y - win.Main.AbsolutePosition.Y + f.AbsoluteSize.Y + 8
            )
            popup.Visible = true
            open = true
            arrow.Rotation = 180
        end

        trigger.MouseButton1Click:Connect(function()
            if open then close() else show() end
        end)
        return {
            Frame = f,
            Destroy = function()
                close()
                if alive(popup) then popup:Destroy() end
                if alive(f) then f:Destroy() end
            end,
            AddItems = function(_, newItems)
                for _, item in ipairs(newItems) do table.insert(items, item) end
                rebuild()
            end,
            Clear = function()
                items = {}
                close()
                rebuild()
            end,
            Set = function(_, value, invokeCallback)
                local itemName = type(value) == "table" and value[1] or tostring(value)
                selected.Text = itemName
                close()
                if invokeCallback == true and cfg.Callback then cfg.Callback(value) end
            end,
            Get = function()
                return selected.Text
            end,
        }
    end

    --// MULTI DROPDOWN (keeps the popup open and toggles many values)
    function tab:MultiDropdown(cfg)
        cfg = cfg or {}
        local items = cfg.Items or {}
        local selectedValues = {}
        local selectedLookup = {}
        local open = false
        local f = baseElement(44)

        local function normalize(value)
            return type(value) == "table" and value[1] or tostring(value)
        end
        local function selectedList()
            local result = {}
            for _, item in ipairs(items) do
                local name = normalize(item)
                if selectedLookup[name] then result[#result + 1] = name end
            end
            return result
        end
        local function setSelection(values)
            selectedLookup = {}
            if type(values) == "table" then
                for _, value in ipairs(values) do selectedLookup[normalize(value)] = true end
            end
            selectedValues = selectedList()
        end
        setSelection(cfg.Default or cfg.StartingValues or {})

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -190, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Multi Dropdown"
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = f

        local selected = Instance.new("TextLabel")
        selected.Size = UDim2.new(0, 150, 1, 0)
        selected.Position = UDim2.new(1, -176, 0, 0)
        selected.BackgroundTransparency = 1
        selected.TextColor3 = Theme.SubText
        selected.Font = Enum.Font.Gotham
        selected.TextSize = 13
        selected.TextTruncate = Enum.TextTruncate.AtEnd
        selected.TextXAlignment = Enum.TextXAlignment.Right
        selected.Parent = f

        -- Font-independent vector chevron. The old Unicode glyph rendered as
        -- a missing-character square on clients whose Roblox font lacked it.
        local arrow = Instance.new("Frame")
        arrow.Name = "Chevron"
        arrow.Size = UDim2.fromOffset(16, 16)
        arrow.AnchorPoint = Vector2.new(0.5, 0.5)
        arrow.Position = UDim2.new(1, -17, 0.5, 0)
        arrow.BackgroundTransparency = 1
        arrow.ZIndex = 103
        arrow.Parent = f

        local arrowLeft = Instance.new("Frame")
        arrowLeft.Size = UDim2.fromOffset(7, 2)
        arrowLeft.AnchorPoint = Vector2.new(1, 0.5)
        arrowLeft.Position = UDim2.fromOffset(8, 8)
        arrowLeft.Rotation = 45
        arrowLeft.BackgroundColor3 = Theme.SubText
        arrowLeft.BorderSizePixel = 0
        arrowLeft.ZIndex = 104
        arrowLeft.Parent = arrow
        corner(arrowLeft, 2)

        local arrowRight = Instance.new("Frame")
        arrowRight.Size = UDim2.fromOffset(7, 2)
        arrowRight.AnchorPoint = Vector2.new(0, 0.5)
        arrowRight.Position = UDim2.fromOffset(8, 8)
        arrowRight.Rotation = -45
        arrowRight.BackgroundColor3 = Theme.SubText
        arrowRight.BorderSizePixel = 0
        arrowRight.ZIndex = 104
        arrowRight.Parent = arrow
        corner(arrowRight, 2)

        local trigger = Instance.new("TextButton")
        trigger.Size = UDim2.new(1, 0, 1, 0)
        trigger.BackgroundTransparency = 1
        trigger.Text = ""
        trigger.ZIndex = 102
        trigger.Parent = f

        local popup = Instance.new("ScrollingFrame")
        popup.Name = "DropdownOverlay"
        popup.Visible = false
        popup.BackgroundColor3 = Theme.Element
        popup.BorderSizePixel = 0
        popup.ScrollBarThickness = 3
        popup.ScrollBarImageColor3 = Theme.Stroke
        popup.AutomaticCanvasSize = Enum.AutomaticSize.Y
        popup.ZIndex = 10000
        popup.Parent = win.Main
        corner(popup, 8)
        stroke(popup, Theme.Stroke, 1)
        padding(popup, 6)
        local popupLayout = Instance.new("UIListLayout")
        popupLayout.Padding = UDim.new(0, 4)
        popupLayout.SortOrder = Enum.SortOrder.LayoutOrder
        popupLayout.Parent = popup
        table.insert(tab._popups, popup)

        local function updateText()
            selectedValues = selectedList()
            if #selectedValues == 0 then
                selected.Text = cfg.StartingText or "Select..."
            elseif #selectedValues <= 2 then
                selected.Text = table.concat(selectedValues, ", ")
            else
                selected.Text = tostring(#selectedValues) .. " selected"
            end
        end
        local function close()
            open = false
            if alive(popup) then popup.Visible = false end
            if alive(arrow) then arrow.Rotation = 0 end
        end
        table.insert(tab._popupClosers, close)
        local rebuild
        rebuild = function()
            for _, child in ipairs(popup:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            for _, item in ipairs(items) do
                local itemName = normalize(item)
                local itemButton = Instance.new("TextButton")
                itemButton.Size = UDim2.new(1, 0, 0, 30)
                itemButton.BackgroundColor3 = selectedLookup[itemName] and Theme.Accent or Theme.Background
                itemButton.BorderSizePixel = 0
                itemButton.Text = (selectedLookup[itemName] and "✓  " or "    ") .. itemName
                itemButton.TextColor3 = selectedLookup[itemName] and Theme.Text or Theme.SubText
                itemButton.Font = Enum.Font.Gotham
                itemButton.TextSize = 13
                itemButton.TextXAlignment = Enum.TextXAlignment.Left
                itemButton.AutoButtonColor = false
                itemButton.ZIndex = 10001
                itemButton.Parent = popup
                corner(itemButton, 6)
                local itemPadding = Instance.new("UIPadding")
                itemPadding.PaddingLeft = UDim.new(0, 10)
                itemPadding.Parent = itemButton
                local clickLocked = false
                local function paintSelection()
                    local isSelected = selectedLookup[itemName] == true
                    itemButton.BackgroundColor3 = isSelected and Theme.Accent or Theme.Background
                    itemButton.Text = (isSelected and "✓  " or "    ") .. itemName
                    itemButton.TextColor3 = isSelected and Theme.Text or Theme.SubText
                end
                paintSelection()
                itemButton.Activated:Connect(function()
                    if clickLocked then return end
                    clickLocked = true
                    selectedLookup[itemName] = not selectedLookup[itemName] or nil
                    updateText()
                    paintSelection()
                    if cfg.Callback then cfg.Callback(selectedList(), item, selectedLookup[itemName] == true) end
                    task.delay(0.08, function() clickLocked = false end)
                end)
            end
        end
        updateText()
        rebuild()

        local function show()
            for _, other in ipairs(tab._popups) do
                if other ~= popup and alive(other) then other.Visible = false end
            end
            local height = math.min(230, (#items * 34) + 12)
            popup.Size = UDim2.fromOffset(math.max(180, f.AbsoluteSize.X), height)
            popup.Position = UDim2.fromOffset(
                f.AbsolutePosition.X - win.Main.AbsolutePosition.X,
                f.AbsolutePosition.Y - win.Main.AbsolutePosition.Y + f.AbsoluteSize.Y + 8
            )
            popup.Visible = true
            open = true
            arrow.Rotation = 180
        end
        trigger.MouseButton1Click:Connect(function()
            if open then close() else show() end
        end)

        return {
            Frame = f,
            Destroy = function()
                close()
                if alive(popup) then popup:Destroy() end
                if alive(f) then f:Destroy() end
            end,
            AddItems = function(_, newItems)
                for _, item in ipairs(newItems) do items[#items + 1] = item end
                updateText()
                rebuild()
            end,
            Clear = function()
                items = {}
                selectedLookup = {}
                selectedValues = {}
                close()
                updateText()
                rebuild()
            end,
            Set = function(_, values, invokeCallback)
                setSelection(values)
                close()
                updateText()
                rebuild()
                if invokeCallback == true and cfg.Callback then cfg.Callback(selectedList()) end
            end,
            Get = function() return selectedList() end,
        }
    end

    --// KEYBIND
    function tab:Keybind(cfg)
        cfg = cfg or {}
        local key = cfg.Keybind
        local binding = false
        local f = baseElement(40)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -100, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Keybind"
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = f

        local kb = Instance.new("TextButton")
        kb.Size = UDim2.fromOffset(70, 26)
        kb.Position = UDim2.new(1, -84, 0.5, 0)
        kb.AnchorPoint = Vector2.new(0, 0.5)
        kb.BackgroundColor3 = Theme.Background
        kb.Text = key and key.Name or "None"
        kb.TextColor3 = Theme.SubText
        kb.Font = Enum.Font.GothamMedium
        kb.TextSize = 12
        kb.AutoButtonColor = false
        kb.Parent = f
        corner(kb, 6)
        stroke(kb, Theme.Stroke, 1)

        kb.MouseButton1Click:Connect(function()
            binding = true
            kb.Text = "..."
            kb.TextColor3 = Theme.Accent
        end)
        UserInputService.InputBegan:Connect(function(input, gpe)
            if not alive(kb) then return end
            if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                kb.Text = key.Name
                kb.TextColor3 = Theme.SubText
                binding = false
            elseif not gpe and key and input.KeyCode == key then
                if cfg.Callback then cfg.Callback() end
            end
        end)
        return f
    end

    --// CREDIT (создатель + Discord)
    function tab:Credit(cfg)
        cfg = cfg or {}
        local hasIcon = cfg.Icon ~= nil
        local hasDiscord = cfg.Discord ~= nil
        local f = baseElement(64)

        if hasIcon then
            local av = Instance.new("ImageLabel")
            av.Size = UDim2.fromOffset(40, 40)
            av.Position = UDim2.new(0, 12, 0.5, 0)
            av.AnchorPoint = Vector2.new(0, 0.5)
            av.BackgroundColor3 = Theme.Background
            av.Image = resolveIcon(cfg.Icon)
            av.ScaleType = Enum.ScaleType.Crop
            av.Parent = f
            corner(av, 20)
            stroke(av, Theme.Stroke, 1)
        end

        local textX = hasIcon and 62 or 14
        local rightPad = hasDiscord and 118 or 20

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -(textX + rightPad), 0, 20)
        nameLbl.Position = UDim2.new(0, textX, 0, 13)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = cfg.Name or "Creator"
        nameLbl.TextColor3 = Theme.Text
        nameLbl.Font = Enum.Font.GothamBold
        nameLbl.TextSize = 14
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nameLbl.Parent = f

        local roleLbl = Instance.new("TextLabel")
        roleLbl.Size = UDim2.new(1, -(textX + rightPad), 0, 18)
        roleLbl.Position = UDim2.new(0, textX, 0, 33)
        roleLbl.BackgroundTransparency = 1
        roleLbl.Text = cfg.Description or cfg.Role or ""
        roleLbl.TextColor3 = Theme.SubText
        roleLbl.Font = Enum.Font.Gotham
        roleLbl.TextSize = 12
        roleLbl.TextXAlignment = Enum.TextXAlignment.Left
        roleLbl.TextTruncate = Enum.TextTruncate.AtEnd
        roleLbl.Parent = f

        if hasDiscord then
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.fromOffset(96, 32)
            btn.Position = UDim2.new(1, -108, 0.5, 0)
            btn.AnchorPoint = Vector2.new(0, 0.5)
            btn.BackgroundColor3 = Theme.Discord
            btn.Text = "Discord"
            btn.TextColor3 = Theme.Text
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = 13
            btn.AutoButtonColor = false
            btn.Parent = f
            corner(btn, 7)

            btn.MouseEnter:Connect(function()
                tween(btn, .15, {BackgroundColor3 = Color3.fromRGB(108, 121, 255)})
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, .15, {BackgroundColor3 = Theme.Discord})
            end)
            btn.MouseButton1Click:Connect(function()
                local ok = copyText(cfg.Discord)
                if win and win.Notification then
                    win:Notification{
                        Title = ok and "Copied!" or "Discord",
                        Text  = ok and "Invite link copied to clipboard."
                                    or ("Copy manually: " .. tostring(cfg.Discord)),
                        Duration = 3,
                    }
                end
                if cfg.Callback then cfg.Callback(cfg.Discord) end
            end)
        end

        return f
    end

    --// SECTION HEADER
    function tab:Section(text)
        local l = Instance.new("TextLabel")
        l.Size = (tab._target or page) == page
            and UDim2.new(0.8, 0, 0, 0)
            or UDim2.new(1, 0, 0, 0)
        l.AutomaticSize = Enum.AutomaticSize.Y
        l.BackgroundTransparency = 1
        l.Text = text or "Section"
        l.TextColor3 = Theme.SubText
        l.Font = Enum.Font.GothamBold
        l.TextSize = 12
        l.TextWrapped = true
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Top
        local sectionPadding = Instance.new("UIPadding")
        sectionPadding.PaddingTop = UDim.new(0, 4)
        sectionPadding.PaddingBottom = UDim.new(0, 4)
        sectionPadding.Parent = l
        l.Parent = tab._target or page
        return l
    end

    return tab
end

return Library
