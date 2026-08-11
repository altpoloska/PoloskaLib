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

local Library = { Version = "test-design-1", TestDesign = true }
Library.__index = Library

--// THEME
local ThemePresets = {
    -- Current blue/cyan Poloska palette remains the default.
    Poloska = {
        Background = Color3.fromRGB(8, 15, 29), Sidebar = Color3.fromRGB(12, 22, 40),
        Success = Color3.fromRGB(46, 204, 137), Warning = Color3.fromRGB(240, 178, 62),
        Overlay = Color3.fromRGB(2, 6, 14), AccentSoft = Color3.fromRGB(20, 64, 88),
        Element = Color3.fromRGB(17, 31, 52), ElementHover = Color3.fromRGB(24, 44, 70),
        Stroke = Color3.fromRGB(38, 61, 91), Accent = Color3.fromRGB(31, 196, 224),
        AccentViolet = Color3.fromRGB(117, 65, 246), Text = Color3.fromRGB(242, 248, 255),
        SubText = Color3.fromRGB(146, 166, 194), Danger = Color3.fromRGB(232, 75, 96),
        Discord = Color3.fromRGB(88, 101, 242),
    },
    -- Palette recovered from an earlier PoloskaLib commit.
    ["Classic Dark"] = {
        Background = Color3.fromRGB(18, 18, 20), Sidebar = Color3.fromRGB(24, 24, 27),
        Success = Color3.fromRGB(70, 190, 130), Warning = Color3.fromRGB(225, 170, 70),
        Overlay = Color3.fromRGB(6, 6, 8), AccentSoft = Color3.fromRGB(48, 52, 92),
        Element = Color3.fromRGB(30, 30, 34), ElementHover = Color3.fromRGB(38, 38, 43),
        Stroke = Color3.fromRGB(45, 45, 50), Accent = Color3.fromRGB(120, 130, 255),
        AccentViolet = Color3.fromRGB(150, 100, 255), Text = Color3.fromRGB(235, 235, 240),
        SubText = Color3.fromRGB(140, 140, 150), Danger = Color3.fromRGB(200, 60, 60),
        Discord = Color3.fromRGB(88, 101, 242),
    },
    Light = {
        Background = Color3.fromRGB(242, 246, 252), Sidebar = Color3.fromRGB(226, 234, 245),
        Success = Color3.fromRGB(18, 150, 100), Warning = Color3.fromRGB(176, 120, 20),
        Overlay = Color3.fromRGB(20, 31, 48), AccentSoft = Color3.fromRGB(197, 225, 240),
        Element = Color3.fromRGB(255, 255, 255), ElementHover = Color3.fromRGB(211, 225, 242),
        Stroke = Color3.fromRGB(171, 190, 214), Accent = Color3.fromRGB(0, 145, 184),
        AccentViolet = Color3.fromRGB(101, 72, 210), Text = Color3.fromRGB(20, 31, 48),
        SubText = Color3.fromRGB(75, 94, 119), Danger = Color3.fromRGB(196, 54, 76),
        Discord = Color3.fromRGB(88, 101, 242),
    },
}
local Theme = {}
local CurrentThemeName = "Poloska"
for key, color in pairs(ThemePresets.Poloska) do Theme[key] = color end

local function selectTheme(name)
    local preset = ThemePresets[name]
    if not preset then return false end
    CurrentThemeName = name
    for key, color in pairs(preset) do Theme[key] = color end
    return true
end

--// Theme plumbing. Colours used to be recovered by comparing the old palette
-- against every descendant, which broke as soon as two keys shared a colour or
-- a control was sitting in a hover / mid-tween state. Every themed property is
-- registered explicitly now and simply re-applied on a theme switch.
local ThemeKeyOrder = {
    "Background", "Sidebar", "Overlay", "Element", "ElementHover", "Stroke",
    "Accent", "AccentViolet", "AccentSoft", "Text", "SubText",
    "Danger", "Success", "Warning", "Discord",
}

local ThemeBindings = setmetatable({}, { __mode = "k" })
local ThemeHooks = {}

-- Binds object[property] to a theme key and applies the current colour now.
local function bind(object, property, key)
    if typeof(object) ~= "Instance" then return object end
    local color = Theme[key]
    if color then pcall(function() object[property] = color end) end
    local map = ThemeBindings[object]
    if not map then
        map = {}
        ThemeBindings[object] = map
    end
    map[property] = key
    return object
end

-- Registers a repaint callback for stateful controls (hovered/selected rows,
-- open popups, captured keybinds). Returning false unregisters the callback.
local function onThemeChanged(fn)
    table.insert(ThemeHooks, fn)
    return fn
end

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

--// Design tokens. One radius scale and one motion scale keep every control
-- visually consistent instead of each widget picking its own numbers.
local Radius = {
    Window  = 14,
    Card    = 10,
    Control = 8,
    Chip    = 6,
}

local Motion = {
    Fast = 0.12,
    Base = 0.18,
    Slow = 0.32,
}

--// Typography scale. Four roles replace the ad-hoc 11..16px sizes so every
-- screen keeps the same rhythm: Title for headers, Label for control names,
-- Body for secondary text, Caption for hints and counters.
local Type = {
    Title   = { Size = 15, Font = Enum.Font.GothamBold },
    Label   = { Size = 13, Font = Enum.Font.GothamMedium },
    Body    = { Size = 12, Font = Enum.Font.Gotham },
    Caption = { Size = 11, Font = Enum.Font.Gotham },
}

--// Layer scale. Every floating surface takes its depth from here instead of
-- inventing magic ZIndex numbers such as 10001.
local Layer = {
    Backdrop     = 0,
    Content      = 2,
    Chrome       = 4,
    Notification = 90,
    Dialog       = 100,
    Popup        = 200,
    Launcher     = 20000,
}

-- Applies a typography role (and optionally a colour) in a single call.
local function typeset(label, role, color)
    local spec = Type[role] or Type.Label
    label.Font = spec.Font
    label.TextSize = spec.Size
    if color then label.TextColor3 = color end
    return label
end

--// Utils
local function alive(obj)
    return typeof(obj) == "Instance" and (obj.Parent ~= nil or obj:IsDescendantOf(game))
end

-- Every hover, press and toggle allocates a TweenInfo, and the same handful of
-- (time, style, direction) combinations are reused thousands of times, so they
-- are cached instead of rebuilt on each interaction.
local TweenInfoCache = {}
local function tweenInfo(time, style, dir)
    local key = tostring(time) .. "|" .. tostring(style) .. "|" .. tostring(dir)
    local info = TweenInfoCache[key]
    if not info then
        info = TweenInfo.new(time, style, dir)
        TweenInfoCache[key] = info
    end
    return info
end

local function tween(obj, time, props, style, dir)
    if not alive(obj) then return end
    local info = tweenInfo(time, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    local ok, t = pcall(TweenService.Create, TweenService, obj, info, props)
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

-- A UIGradient multiplies its parent's colour, so gradients are only applied to
-- white surfaces (accent bars) where the keypoints define the final colour.
local function gradient(parent, colorA, colorB, rotation, transparencyA, transparencyB)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new(colorA, colorB)
    g.Rotation = rotation or 90
    if transparencyA or transparencyB then
        g.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, transparencyA or 0),
            NumberSequenceKeypoint.new(1, transparencyB or 0),
        })
    end
    g.Parent = parent
    return g
end

-- Soft vertical light band over a solid surface. It lives on its own overlay
-- frame so the surface colour itself stays exactly as the theme defines it.
local function sheen(parent, color, topTransparency, bottomTransparency, height)
    local overlay = Instance.new("Frame")
    overlay.Name = "Sheen"
    overlay.BackgroundColor3 = color
    overlay.BorderSizePixel = 0
    overlay.Size = height and UDim2.new(1, 0, 0, height) or UDim2.fromScale(1, 1)
    overlay.ZIndex = parent.ZIndex
    overlay.Parent = parent
    local g = Instance.new("UIGradient")
    g.Rotation = 90
    g.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, topTransparency or 0.85),
        NumberSequenceKeypoint.new(1, bottomTransparency or 1),
    })
    g.Parent = overlay
    return overlay
end

-- Ambient shadow. It used to be a 9-slice glow image, but that asset has an
-- opaque centre: the window itself has rounded corners, so the square centre
-- showed through around them and read as dark square corners on a rounded
-- window. Concentric rounded frames keep the same falloff while following the
-- window radius, so the corners stay round. Windows and cards clip their
-- descendants, so the shadow is created as a sibling that mirrors the owner's
-- size, position and visibility.
-- Falloff layers are tracked per shadow so glows can be tinted and faded
-- without touching the individual frames from call sites.
local ShadowLayers = setmetatable({}, { __mode = "k" })

local function dropShadow(target, spread, transparency)
    if not alive(target) or not target.Parent then return nil end
    local pad = spread or 28
    local s = Instance.new("Frame")
    s.Name = target.Name .. "Shadow"
    s.BackgroundTransparency = 1
    s.BorderSizePixel = 0
    s.ZIndex = math.max(0, target.ZIndex - 1)
    s:SetAttribute("PreserveThemeColors", true)
    s.Parent = target.Parent

    -- All layers share ONE transparency and simply stack on top of each other.
    -- A point close to the window is covered by every layer, a point far out by
    -- only the largest one, so the alpha ramps up on its own. Giving each layer
    -- its own dark value instead made them multiply into two or three visible
    -- plates. n stacked layers reach `inner` when each one is inner^(1/n).
    local layers = 6
    local inner = math.clamp(transparency or 0.62, 0.02, 0.99)
    local step = inner ^ (1 / layers)
    local built = {}
    for i = 1, layers do
        local grow = pad * i / layers
        local layer = Instance.new("Frame")
        layer.Name = "Falloff" .. i
        layer.AnchorPoint = Vector2.new(0.5, 0.5)
        layer.Position = UDim2.fromScale(0.5, 0.5)
        layer.Size = UDim2.new(1, -(pad - grow) * 2, 1, -(pad - grow) * 2)
        layer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        layer.BackgroundTransparency = step
        layer.BorderSizePixel = 0
        layer.ZIndex = 0
        layer:SetAttribute("PreserveThemeColors", true)
        layer.Parent = s
        corner(layer, Radius.Window + grow)
        built[i] = { instance = layer, base = step }
    end
    ShadowLayers[s] = built

    local function sync()
        if not alive(target) or not alive(s) then return end
        local anchor = target.AnchorPoint
        s.AnchorPoint = anchor
        s.Size = UDim2.new(
            target.Size.X.Scale, target.Size.X.Offset + pad * 2,
            target.Size.Y.Scale, target.Size.Y.Offset + pad * 2
        )
        s.Position = UDim2.new(
            target.Position.X.Scale, target.Position.X.Offset + pad * (2 * anchor.X - 1),
            target.Position.Y.Scale, target.Position.Y.Offset + pad * (2 * anchor.Y - 1)
        )
        s.Visible = target.Visible
    end

    sync()
    for _, property in ipairs({ "Size", "Position", "AnchorPoint", "Visible" }) do
        target:GetPropertyChangedSignal(property):Connect(sync)
    end
    return s
end

-- Recolours every falloff layer of a shadow (used for accent glows).
local function shadowTint(shadowFrame, color)
    local layers = ShadowLayers[shadowFrame]
    if not layers or not color then return end
    for _, entry in ipairs(layers) do
        if alive(entry.instance) then
            entry.instance.BackgroundColor3 = color
            -- Tinted glows should follow a theme switch, unlike plain shadows.
            entry.instance:SetAttribute("PreserveThemeColors", false)
        end
    end
end

-- alpha 0 = shadow at full strength, 1 = fully hidden. The relative falloff
-- between layers is preserved, so a glow fades as one soft shape.
local function shadowFade(shadowFrame, alpha, time)
    local layers = ShadowLayers[shadowFrame]
    if not layers then return end
    alpha = math.clamp(tonumber(alpha) or 0, 0, 1)
    for _, entry in ipairs(layers) do
        local target = entry.base + (1 - entry.base) * alpha
        if time and time > 0 then
            tween(entry.instance, time, { BackgroundTransparency = target })
        elseif alive(entry.instance) then
            entry.instance.BackgroundTransparency = target
        end
    end
end

-- Momentary press feedback: a control should react to the press itself, not
-- only to hover. That is most of what makes an interface feel responsive.
local function pressFeedback(button, target, pressedColor, restColor)
    button.MouseButton1Down:Connect(function()
        tween(target, Motion.Fast, { BackgroundColor3 = pressedColor })
    end)
    button.MouseButton1Up:Connect(function()
        tween(target, Motion.Base, { BackgroundColor3 = restColor })
    end)
end

--// Window dragging
local function makeDraggable(frame, handle)
    local state = { Moved = false, SuppressClick = false }
    local dragging = false
    local activeInput = nil
    local inputKind = nil
    local startPos = nil
    local startFramePos = nil
    local DRAG_THRESHOLD = 6

    local function clampToViewport(position)
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize
        if not viewport or frame.AbsoluteSize.X <= 0 or frame.AbsoluteSize.Y <= 0 then
            return position
        end

        local margin = 8
        local width = frame.AbsoluteSize.X
        local height = frame.AbsoluteSize.Y
        local anchor = frame.AnchorPoint
        local anchorX = viewport.X * position.X.Scale + position.X.Offset
        local anchorY = viewport.Y * position.Y.Scale + position.Y.Offset
        local minX = margin + width * anchor.X
        local maxX = viewport.X - margin - width * (1 - anchor.X)
        local minY = margin + height * anchor.Y
        local maxY = viewport.Y - margin - height * (1 - anchor.Y)

        if minX <= maxX then anchorX = math.clamp(anchorX, minX, maxX) end
        if minY <= maxY then anchorY = math.clamp(anchorY, minY, maxY) end

        return UDim2.new(
            position.X.Scale, anchorX - viewport.X * position.X.Scale,
            position.Y.Scale, anchorY - viewport.Y * position.Y.Scale
        )
    end

    local function finish(input)
        if not dragging or (activeInput and input and input ~= activeInput) then return end
        if state.Moved then state.SuppressClick = true end
        dragging = false
        activeInput = nil
        inputKind = nil
        startPos = nil
        startFramePos = nil
    end

    handle.InputBegan:Connect(function(input)
        local kind = input.UserInputType
        if kind ~= Enum.UserInputType.MouseButton1
            and kind ~= Enum.UserInputType.Touch then return end

        dragging = true
        activeInput = input
        inputKind = kind
        startPos = input.Position
        startFramePos = frame.Position
        state.Moved = false
        state.SuppressClick = false

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End
                or input.UserInputState == Enum.UserInputState.Cancel then
                finish(input)
            end
        end)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not dragging or not alive(frame) or not startPos or not startFramePos then return end

        local matchesTouch = inputKind == Enum.UserInputType.Touch and input == activeInput
        local matchesMouse = inputKind == Enum.UserInputType.MouseButton1
            and input.UserInputType == Enum.UserInputType.MouseMovement
        if not matchesTouch and not matchesMouse then return end

        local rawDelta = input.Position - startPos
        if math.max(math.abs(rawDelta.X), math.abs(rawDelta.Y)) >= DRAG_THRESHOLD then
            state.Moved = true
        end
        if not state.Moved then return end

        -- Main's Position offsets live in its parent's unscaled space; the
        -- UIScale shrinks the frame around its anchor without rescaling that
        -- space, so screen-pixel drag deltas must be applied 1:1.
        local deltaX = rawDelta.X
        local deltaY = rawDelta.Y
        local target = UDim2.new(
            startFramePos.X.Scale, startFramePos.X.Offset + deltaX,
            startFramePos.Y.Scale, startFramePos.Y.Offset + deltaY
        )
        frame.Position = clampToViewport(target)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input == activeInput
            or (inputKind == Enum.UserInputType.MouseButton1
                and input.UserInputType == Enum.UserInputType.MouseButton1) then
            finish(activeInput)
        end
    end)

    function state:ConsumeClick()
        if not self.SuppressClick then return false end
        self.SuppressClick = false
        return true
    end

    return state
end

--============================================================
--  CREATE WINDOW
--============================================================
function Library:Create(config)
    config = config or {}
    selectTheme(config.Theme or "Poloska")
    local window = setmetatable({}, Library)
    window.ThemeName = CurrentThemeName
    window.Tabs = {}
    window.Visible = true
    window.Minimized = false
    window.UserScale = math.clamp(tonumber(config.Scale) or 1, UserInputService.TouchEnabled and 0.35 or 0.50, 1.25)
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
    corner(main, Radius.Window)
    local mainStroke = stroke(main, Theme.Stroke, 1)
    mainStroke.Transparency = 0.15
    window.MainStroke = mainStroke

    -- One dedicated layer for floating surfaces (dropdown popups). Keeping them
    -- in a single container means their depth comes from Layer.Popup instead of
    -- ad-hoc ZIndex numbers scattered across every control.
    local overlayLayer = Instance.new("Frame")
    overlayLayer.Name = "OverlayLayer"
    overlayLayer.Size = UDim2.fromScale(1, 1)
    overlayLayer.BackgroundTransparency = 1
    overlayLayer.BorderSizePixel = 0
    overlayLayer.ZIndex = Layer.Popup
    overlayLayer.Parent = main
    window.Overlay = overlayLayer
    -- Light falloff from the header downwards gives the flat window depth.
    sheen(main, Theme.Sidebar, 0.72, 1, 220)

    -- Subtle code-native brand backdrop inspired by the Poloska pencil icon.
    -- It uses ordinary Roblox primitives, so consumers still load only this
    -- library from GitHub and never depend on a bundled image file.
    local backdrop = Instance.new("Frame")
    backdrop.Name = "PoloskaBackdrop"
    backdrop.Size = UDim2.fromScale(1, 1)
    backdrop.BackgroundTransparency = 1
    backdrop.BorderSizePixel = 0
    backdrop.ZIndex = 0
    backdrop.Parent = main

    local ring = Instance.new("Frame")
    ring.Name = "BrandRing"
    ring.Size = UDim2.fromOffset(330, 330)
    ring.Position = UDim2.new(1, -255, 0.5, -145)
    ring.BackgroundTransparency = 1
    ring.BorderSizePixel = 0
    ring.ZIndex = 0
    ring.Parent = backdrop
    corner(ring, 165)
    local ringStroke = stroke(ring, Theme.AccentViolet, 2)
    ringStroke.Transparency = 0.88

    local function brandStick(name, position, rotation, color, length)
        local shadow = Instance.new("Frame")
        shadow.Name = name .. "Shadow"
        shadow.AnchorPoint = Vector2.new(0.5, 0.5)
        shadow.Position = position + UDim2.fromOffset(4, 5)
        shadow.Size = UDim2.fromOffset(length, 18)
        shadow.Rotation = rotation
        shadow.BackgroundColor3 = Color3.fromRGB(2, 7, 16)
        shadow.BackgroundTransparency = 0.74
        shadow.BorderSizePixel = 0
        shadow.ZIndex = 0
        shadow.Parent = backdrop
        corner(shadow, 9)
        local stick = Instance.new("Frame")
        stick.Name = name
        stick.AnchorPoint = Vector2.new(0.5, 0.5)
        stick.Position = position
        stick.Size = UDim2.fromOffset(length, 12)
        stick.Rotation = rotation
        stick.BackgroundColor3 = color
        stick.BackgroundTransparency = 0.82
        stick.BorderSizePixel = 0
        stick.ZIndex = 0
        stick.Parent = backdrop
        corner(stick, 6)
        local gradient = Instance.new("UIGradient")
        gradient.Color = ColorSequence.new(Theme.Accent, Theme.AccentViolet)
        gradient.Transparency = NumberSequence.new({ NumberSequenceKeypoint.new(0, 0.15), NumberSequenceKeypoint.new(1, 0.45) })
        gradient.Parent = stick
    end
    brandStick("PencilA", UDim2.new(0.79, 0, 0.72, 0), -47, Theme.Accent, 280)
    brandStick("PencilB", UDim2.new(0.69, 0, 0.28, 0), -47, Theme.AccentViolet, 190)

    local uiScale = Instance.new("UIScale")
    uiScale.Name = "ResponsiveScale"
    uiScale.Scale = window.UserScale
    uiScale.Parent = main
    window.ScaleObject = uiScale

    -- Ambient shadow behind the window. Main clips its descendants, so the
    -- shadow is a sibling and follows Main's geometry and responsive scale.
    local windowShadow = dropShadow(main, 32, 0.62)
    local shadowScale = nil
    if windowShadow then
        shadowScale = Instance.new("UIScale")
        shadowScale.Scale = uiScale.Scale
        shadowScale.Parent = windowShadow
    end

    local cameraConnection
    local function applyResponsiveScale()
        if not alive(main) or not alive(uiScale) then return end
        local effective = window.UserScale
        local camera = workspace.CurrentCamera
        local viewport = camera and camera.ViewportSize
        local mobileAutoScale = window.AutoScale
            and UserInputService.TouchEnabled and viewport ~= nil
        if mobileAutoScale then
            -- Target at most 90% of the screen width and 72% of its height.
            -- Height is the limiting dimension on short landscape phones such
            -- as 1024x503, while portrait phones naturally shrink by width.
            local fitX = (viewport.X * 0.90) / math.max(size.X.Offset, 1)
            local fitY = (viewport.Y * 0.72) / math.max(size.Y.Offset, 1)
            effective = math.min(effective, fitX, fitY, 0.75)
        end
        effective = math.clamp(effective, mobileAutoScale and 0.35 or 0.50, 1.25)
        uiScale.Scale = effective
        if shadowScale then shadowScale.Scale = effective end
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
    corner(topbar, Radius.Window)
    sheen(topbar, Theme.ElementHover, 0.82, 1)

    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 12)
    topFix.Position = UDim2.new(0, 0, 1, -12)
    topFix.BackgroundColor3 = Theme.Sidebar
    topFix.BorderSizePixel = 0
    topFix.Parent = topbar

    -- Hairline divider between header and body, plus an accent line that fades
    -- out to the right, so the header reads as a real title bar.
    local topDivider = Instance.new("Frame")
    topDivider.Name = "TopbarDivider"
    topDivider.Size = UDim2.new(1, 0, 0, 1)
    topDivider.Position = UDim2.new(0, 0, 1, -1)
    topDivider.BackgroundColor3 = Theme.Stroke
    topDivider.BackgroundTransparency = 0.35
    topDivider.BorderSizePixel = 0
    topDivider.ZIndex = 3
    topDivider.Parent = topbar

    local topAccent = Instance.new("Frame")
    topAccent.Name = "TopbarAccent"
    topAccent.Size = UDim2.new(0.5, 0, 0, 2)
    topAccent.Position = UDim2.new(0, 0, 1, -2)
    topAccent.BackgroundColor3 = Color3.new(1, 1, 1)
    topAccent.BorderSizePixel = 0
    topAccent.ZIndex = 4
    topAccent.Parent = topbar
    local topAccentGradient = gradient(topAccent, Theme.Accent, Theme.AccentViolet, 0, 0.1, 1)
    -- The header accent slowly "breathes": one long-lived shimmer glides across
    -- the gradient offset and back, so the title bar never reads as a static
    -- stripe. tween() already guards against a destroyed UIGradient, and the
    -- alive() check ends the thread once the window closes.
    task.spawn(function()
        while alive(topAccentGradient) do
            tween(topAccentGradient, 3.4, { Offset = Vector2.new(-1, -0.5) },
                Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(3.4)
            if not alive(topAccentGradient) then break end
            tween(topAccentGradient, 3.4, { Offset = Vector2.new(1, 0) },
                Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            task.wait(3.4)
        end
    end)

    -- Touch devices get noticeably bigger hit targets in the header.
    local iconSize = UserInputService.TouchEnabled and 34 or 28
    local iconGap = 8

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -(iconSize * 2 + iconGap + 56), 1, 0)
    -- The accent tick that used to sit in front of the title is gone, so the
    -- text starts at the normal header inset.
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = config.Name or "Minimal UI"
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = Layer.Chrome
    typeset(title, "Title", Theme.Text)
    title.Parent = topbar

    makeDraggable(main, topbar)

    local function makeIconButton(iconId, xOffset, hoverKey)
        local b = Instance.new("ImageButton")
        b.Size = UDim2.fromOffset(iconSize, iconSize)
        b.Position = UDim2.new(1, xOffset, 0.5, 0)
        b.AnchorPoint = Vector2.new(0, 0.5)
        b.BackgroundColor3 = Theme.Element
        b.AutoButtonColor = false
        b.Image = resolveIcon(iconId)
        -- The glyphs used to be locked to white, which made them disappear on
        -- light themes. They follow the theme text colour instead.
        b.ImageColor3 = Theme.Text
        b:SetAttribute("PreserveImageColor", false)
        b.ScaleType = Enum.ScaleType.Fit
        b.Parent = topbar
        bind(b, "BackgroundColor3", "Element")
        bind(b, "ImageColor3", "Text")
        corner(b, Radius.Chip)
        local ic = Instance.new("UIPadding")
        local iconInset = math.floor(iconSize / 4)
        ic.PaddingTop = UDim.new(0, iconInset); ic.PaddingBottom = UDim.new(0, iconInset)
        ic.PaddingLeft = UDim.new(0, iconInset); ic.PaddingRight = UDim.new(0, iconInset)
        ic.Parent = b
        b.MouseEnter:Connect(function()
            tween(b, .15, {BackgroundColor3 = Theme[hoverKey] or Theme.ElementHover})
        end)
        b.MouseLeave:Connect(function()
            tween(b, .15, {BackgroundColor3 = Theme.Element})
        end)
        b.MouseButton1Down:Connect(function()
            tween(b, Motion.Fast, {BackgroundTransparency = 0.4})
        end)
        b.MouseButton1Up:Connect(function()
            tween(b, Motion.Base, {BackgroundTransparency = 0})
        end)
        -- A hover/press tween that is still playing when the palette changes
        -- keeps writing the old colours over the theme binding, which is how the
        -- close and minimize glyphs ended up invisible against the new topbar.
        -- Repainting from a theme hook lands after those tweens and also covers
        -- the minimize/restore icon swap.
        onThemeChanged(function()
            if not alive(b) then return false end
            b.BackgroundColor3 = Theme.Element
            b.BackgroundTransparency = 0
            b.ImageColor3 = Theme.Text
        end)
        return b
    end

    -- Close button -> confirm dialog
    local closeBtn = makeIconButton(icons.Close, -(iconSize + iconGap), "Danger")
    closeBtn.MouseButton1Click:Connect(function()
        window:Confirm{
            Title = "Close menu?",
            Text = "Are you sure you want to close the UI?",
            ConfirmText = "Close",
            CancelText = "Cancel",
            OnConfirm = function()
                if alive(mainStroke) then tween(mainStroke, 0.18, {Transparency = 1}) end
                local t = tween(main, 0.22, {Size = window:_collapsedSize()}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                if t then t.Completed:Wait() end
                if alive(gui) then gui:Destroy() end
            end
        }
    end)

    -- Minimize button -> collapse into header
    local minBtn = makeIconButton(icons.Minimize, -(iconSize * 2 + iconGap + 6), "ElementHover")
    window.MinimizeButton = minBtn
    window.MinimizeIcon = icons.Minimize
    window.RestoreIcon  = icons.Restore
    minBtn.MouseButton1Click:Connect(function()
        window:ToggleMinimize()
    end)

    -- Search chip: filters the controls of the active tab while typing. It sits
    -- between the title and the window buttons and folds away on narrow windows.
    local searchWidth = UserInputService.TouchEnabled and 150 or 170
    local searchBox = Instance.new("TextBox")
    searchBox.Name = "TopbarSearch"
    searchBox.Size = UDim2.fromOffset(searchWidth, iconSize)
    searchBox.Position = UDim2.new(1, -(iconSize * 2 + iconGap * 2 + 6 + searchWidth), 0.5, 0)
    searchBox.AnchorPoint = Vector2.new(0, 0.5)
    searchBox.BackgroundColor3 = Theme.Element
    searchBox.BorderSizePixel = 0
    searchBox.ClearTextOnFocus = false
    searchBox.Text = ""
    searchBox.PlaceholderText = "Search"
    searchBox.PlaceholderColor3 = Theme.SubText
    searchBox.TextColor3 = Theme.Text
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = Type.Body.Size
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.TextTruncate = Enum.TextTruncate.AtEnd
    searchBox.ZIndex = Layer.Chrome
    searchBox.Parent = topbar
    corner(searchBox, Radius.Chip)
    local searchStroke = stroke(searchBox, Theme.Stroke, 1)
    searchStroke.Transparency = 0.45
    bind(searchBox, "BackgroundColor3", "Element")
    bind(searchBox, "TextColor3", "Text")
    bind(searchBox, "PlaceholderColor3", "SubText")

    local searchPad = Instance.new("UIPadding")
    searchPad.PaddingLeft = UDim.new(0, 26)
    searchPad.PaddingRight = UDim.new(0, 10)
    searchPad.Parent = searchBox

    -- Vector magnifier, so the chip reads as a search field without an asset.
    local lens = Instance.new("Frame")
    lens.Name = "Lens"
    lens.AnchorPoint = Vector2.new(0, 0.5)
    lens.Position = UDim2.new(0, -18, 0.5, -1)
    lens.Size = UDim2.fromOffset(9, 9)
    lens.BackgroundTransparency = 1
    lens.ZIndex = Layer.Chrome + 1
    lens.Parent = searchBox
    corner(lens, 999)
    local lensStroke = stroke(lens, Theme.SubText, 1.5)

    local lensHandle = Instance.new("Frame")
    lensHandle.Name = "Handle"
    lensHandle.AnchorPoint = Vector2.new(0, 0.5)
    lensHandle.Position = UDim2.new(1, -1, 1, -1)
    lensHandle.Size = UDim2.fromOffset(5, 2)
    lensHandle.Rotation = 45
    lensHandle.BackgroundColor3 = Theme.SubText
    lensHandle.BorderSizePixel = 0
    lensHandle.ZIndex = Layer.Chrome + 1
    lensHandle.Parent = lens
    corner(lensHandle, 1)
    bind(lensHandle, "BackgroundColor3", "SubText")

    local function activeTab()
        for _, t in pairs(window.Tabs) do
            if t._active then return t end
        end
        return window.Tabs[1]
    end

    -- The query covers every tab, not only the visible one: each tab filters
    -- itself and reports its match count, and tabs with no results are dimmed
    -- in the sidebar. When the tab on screen has nothing left the search moves
    -- to the first tab that does, but a tab the user picked by hand stays put
    -- for that query, so navigation is never locked.
    local searchToken = 0
    local searchLastQuery = nil

    local function runSearch()
        local query = (alive(searchBox) and searchBox.Visible) and searchBox.Text or ""
        local queryChanged = query ~= searchLastQuery
        searchLastQuery = query
        local current = activeTab()
        if queryChanged then
            for _, t in ipairs(window.Tabs) do t._searchTabPicked = nil end
        end
        local firstMatch, currentMatches = nil, 0
        for _, t in ipairs(window.Tabs) do
            local matches = 0
            if t._applySearch then
                local ok, count = pcall(t._applySearch, query)
                matches = (ok and tonumber(count)) or 0
            end
            if t._setSearchCount then pcall(t._setSearchCount, query ~= "" and matches or nil) end
            if t == current then currentMatches = matches end
            if query ~= "" and matches > 0 and not firstMatch then firstMatch = t end
        end
        if alive(lensStroke) then
            lensStroke.Color = query ~= "" and Theme.Accent or Theme.SubText
        end
        local picked = current ~= nil and current._searchTabPicked == true
        if query ~= "" and currentMatches == 0 and not picked and firstMatch and firstMatch ~= current and firstMatch._activate then
            pcall(firstMatch._activate)
        end
    end
    -- Typing is debounced: one filter pass per short pause instead of one per
    -- character, so long queries stay smooth on crowded tabs.
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        searchToken = searchToken + 1
        local token = searchToken
        if not alive(searchBox) or searchBox.Text == "" then
            runSearch()
            return
        end
        task.delay(0.08, function()
            if token == searchToken then runSearch() end
        end)
    end)
    searchBox.Focused:Connect(function()
        tween(searchStroke, Motion.Fast, { Color = Theme.Accent, Transparency = 0.1 })
    end)
    searchBox.FocusLost:Connect(function()
        tween(searchStroke, Motion.Base, { Color = Theme.Stroke, Transparency = 0.45 })
    end)
    window.SearchBox = searchBox
    window._runSearch = runSearch

    -- The header only has room for the field on reasonably wide windows; below
    -- that the title takes the space back and any active filter is dropped.
    local function syncSearchChip()
        if not alive(searchBox) or not alive(main) or not alive(title) then return end
        local scaleObject = window.ScaleObject
        local scale = (scaleObject and alive(scaleObject) and tonumber(scaleObject.Scale)) or 1
        if scale <= 0 then scale = 1 end
        local width = main.AbsoluteSize.X / scale
        local show = width >= (searchWidth + iconSize * 2 + iconGap * 3 + 190)
        if searchBox.Visible ~= show then
            searchBox.Visible = show
            if not show and searchBox.Text ~= "" then
                searchBox.Text = ""
            else
                runSearch()
            end
        end
        local reserved = iconSize * 2 + iconGap + 56
        if show then reserved = reserved + searchWidth + iconGap end
        title.Size = UDim2.new(1, -reserved, 1, 0)
    end
    main:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncSearchChip)
    task.defer(syncSearchChip)

    -- Sidebar
    local sidebar = Instance.new("Frame")
    sidebar.Name = "Sidebar"
    sidebar.Size = UDim2.new(0, 150, 1, -42)
    sidebar.Position = UDim2.new(0, 0, 0, 42)
    sidebar.BackgroundColor3 = Theme.Sidebar
    sidebar.BorderSizePixel = 0
    sidebar.Parent = main
    sheen(sidebar, Theme.Background, 1, 0.55)

    -- Vertical hairline that separates navigation from content.
    local sidebarDivider = Instance.new("Frame")
    sidebarDivider.Name = "SidebarDivider"
    sidebarDivider.Size = UDim2.new(0, 1, 1, 0)
    sidebarDivider.Position = UDim2.new(1, -1, 0, 0)
    sidebarDivider.BackgroundColor3 = Theme.Stroke
    sidebarDivider.BackgroundTransparency = 0.4
    sidebarDivider.BorderSizePixel = 0
    sidebarDivider.ZIndex = 3
    sidebarDivider.Parent = sidebar

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
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
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
    -- Separate collapse key. Nil means "not bound", so a host script that never
    -- assigns one keeps exactly the previous behaviour.
    window.MinimizeKey = config.MinimizeKey
    UserInputService.InputBegan:Connect(function(input, gpe)
        if gpe then return end
        if not alive(main) then return end
        if input.KeyCode == window.ToggleKey then
            window:Toggle()
        elseif window.MinimizeKey and input.KeyCode == window.MinimizeKey then
            window:ToggleMinimize()
        end
    end)

    -- Persistent launcher for both touch and desktop. It remains outside Main,
    -- so it can restore the menu after the menu itself has been hidden.
    local launcher = Instance.new("ImageButton")
    launcher.Name = "PoloskaLauncher"
    launcher.Size = UDim2.fromOffset(54, 54)
    -- Start the draggable launcher centered at the top on every device,
    -- with a small offset below Roblox's top bar.
    launcher.Position = UDim2.new(0.5, -27, 0, 14)
    launcher.BackgroundColor3 = Color3.fromRGB(8, 15, 29)
    launcher.BackgroundTransparency = 0.08
    launcher.BorderSizePixel = 0
    launcher.AutoButtonColor = false
    launcher.Image = resolveIcon(config.ToggleButtonAsset or "rbxassetid://76774068789424")
    launcher.ImageColor3 = Color3.new(1, 1, 1)
    launcher:SetAttribute("PreserveImageColor", true)
    launcher:SetAttribute("PreserveThemeColors", true)
    launcher.ScaleType = Enum.ScaleType.Fit
    launcher.Visible = window.ToggleButtonVisible
    launcher.ZIndex = Layer.Launcher
    launcher.Parent = gui
    corner(launcher, 14)
    local launcherStroke = stroke(launcher, Color3.fromRGB(38, 61, 91), 1)
    launcherStroke:SetAttribute("PreserveThemeColors", true)
    local launcherPadding = Instance.new("UIPadding")
    launcherPadding.PaddingTop = UDim.new(0, 5)
    launcherPadding.PaddingBottom = UDim.new(0, 5)
    launcherPadding.PaddingLeft = UDim.new(0, 5)
    launcherPadding.PaddingRight = UDim.new(0, 5)
    launcherPadding.Parent = launcher
    local launcherDrag = makeDraggable(launcher, launcher)
    launcher.Activated:Connect(function()
        if launcherDrag:ConsumeClick() then return end
        window:Toggle()
    end)
    window.Launcher = launcher

    return window
end

function Library:SetTheme(name)
    local preset = ThemePresets[name]
    if not preset then return false, "Unknown theme" end
    local previous = {}
    for key, color in pairs(Theme) do previous[key] = color end
    selectTheme(name)
    self.ThemeName = name

    -- 1) Explicit bindings win: they cannot mis-resolve, and they repaint
    --    controls that are hovered, selected or mid-tween right now.
    for object, map in pairs(ThemeBindings) do
        if typeof(object) == "Instance" and object.Parent ~= nil then
            for property, key in pairs(map) do
                local color = Theme[key]
                if color then pcall(function() object[property] = color end) end
            end
        else
            ThemeBindings[object] = nil
        end
    end

    local colorProperties = {
        "BackgroundColor3", "TextColor3", "ImageColor3",
        "ScrollBarImageColor3", "PlaceholderColor3",
    }
    -- 2) Fallback for everything not bound yet. The lookup walks a fixed key
    --    order, so repeated theme switches always resolve the same way instead
    --    of depending on pairs() iteration order (that is what made text stop
    --    following the palette after several switches).
    local function translated(color)
        for _, key in ipairs(ThemeKeyOrder) do
            if previous[key] == color then return Theme[key] end
        end
        for key, oldColor in pairs(previous) do
            if color == oldColor then return Theme[key] end
        end
        return nil
    end
    local function isBound(object, property)
        local map = ThemeBindings[object]
        return map ~= nil and map[property] ~= nil
    end
    for _, object in ipairs(self.Gui:GetDescendants()) do
        if object:GetAttribute("PreserveThemeColors") == true then
            -- Branded/full-color images keep their original presentation.
        elseif object:IsA("UIStroke") then
            if not isBound(object, "Color") then
                local color = translated(object.Color)
                if color then object.Color = color end
            end
        elseif object:IsA("UIGradient") then
            -- Translate every keypoint so accent bars, sheens and any future
            -- gradient follow a theme switch, not just the accent pair.
            local rebuilt = {}
            local changed = false
            for index, point in ipairs(object.Color.Keypoints) do
                local color = translated(point.Value)
                if color then changed = true end
                rebuilt[index] = ColorSequenceKeypoint.new(point.Time, color or point.Value)
            end
            if changed then object.Color = ColorSequence.new(rebuilt) end
        else
            for _, property in ipairs(colorProperties) do
                pcall(function()
                    if property == "ImageColor3" and object:GetAttribute("PreserveImageColor") == true then return end
                    if isBound(object, property) then return end
                    local color = translated(object[property])
                    if color then object[property] = color end
                end)
            end
        end
    end

    -- 3) Stateful controls repaint themselves last.
    for index = #ThemeHooks, 1, -1 do
        local ok, keep = pcall(ThemeHooks[index])
        if not ok or keep == false then table.remove(ThemeHooks, index) end
    end
    return true
end

function Library:GetThemeNames()
    return { "Poloska", "Classic Dark", "Light" }
end

function Library:SetToggleKey(key)
    if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
        self.ToggleKey = key
        return true
    end
    return false
end

-- Collapse-into-header key. Passing nil clears the bind; a key equal to the
-- hide/show key is rejected so one press cannot fire both actions at once.
function Library:SetMinimizeKey(key)
    if key == nil then
        self.MinimizeKey = nil
        return true
    end
    if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
        if key == self.ToggleKey then return false, "Key already used for hide / show" end
        self.MinimizeKey = key
        return true
    end
    return false
end

function Library:SetScale(scale)
    self.UserScale = math.clamp(tonumber(scale) or 1, UserInputService.TouchEnabled and 0.35 or 0.50, 1.25)
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
-- Opening and closing share one motion: the window unrolls from the header at
-- almost full width while its outline fades in, instead of being sucked into a
-- 0x0 point in the middle of the screen.
function Library:_collapsedSize()
    local width = math.floor(self.WindowSize.X.Offset * 0.94)
    return UDim2.new(self.WindowSize.X.Scale, width, 0, 0)
end

function Library:Toggle()
    if not alive(self.Main) then return end
    self.Visible = not self.Visible
    if self.Visible then
        self.Main.Visible = true
        self.Main.Size = self:_collapsedSize()
        local target = self.Minimized
            and UDim2.new(self.WindowSize.X.Scale, self.WindowSize.X.Offset, 0, 42)
            or self.WindowSize
        tween(self.Main, 0.34, {Size = target}, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        if alive(self.MainStroke) then
            self.MainStroke.Transparency = 1
            tween(self.MainStroke, 0.34, {Transparency = 0.15})
        end
    else
        local t = tween(self.Main, 0.22, {Size = self:_collapsedSize()}, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
        if alive(self.MainStroke) then
            tween(self.MainStroke, 0.18, {Transparency = 1})
        end
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
    overlay.ZIndex = Layer.Dialog
    overlay.Parent = self.Gui
    tween(overlay, .2, {BackgroundTransparency = 0.5})

    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(300, 150)
    box.Position = UDim2.new(0.5, 0, 0.5, 0)
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.BackgroundColor3 = Theme.Background
    box.BackgroundTransparency = 1
    box.ZIndex = Layer.Dialog + 1
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
    title.TextSize = Type.Title.Size
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = Layer.Dialog + 2
    title.Parent = box

    local desc = Instance.new("TextLabel")
    desc.Size = UDim2.new(1, -32, 0, 40)
    desc.Position = UDim2.new(0, 16, 0, 48)
    desc.BackgroundTransparency = 1
    desc.Text = opts.Text or ""
    desc.TextColor3 = Theme.SubText
    desc.Font = Enum.Font.Gotham
    desc.TextSize = Type.Body.Size
    desc.TextWrapped = true
    desc.TextXAlignment = Enum.TextXAlignment.Left
    desc.TextYAlignment = Enum.TextYAlignment.Top
    desc.ZIndex = Layer.Dialog + 2
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
        b.TextSize = Type.Label.Size
        b.AutoButtonColor = false
        b.ZIndex = Layer.Dialog + 2
        b.Parent = box
        corner(b, Radius.Control)
        local dialogStroke = stroke(b, danger and Theme.Danger or Theme.Stroke, 1)
        dialogStroke.Transparency = danger and 0.55 or 0.35
        -- Subtle vertical shade so the action buttons are not flat fills.
        gradient(b, Color3.new(1, 1, 1), Color3.fromRGB(214, 214, 214), 90)
        local restColor = danger and Theme.Danger or Theme.Element
        local hoverColor = danger and Theme.Danger:Lerp(Color3.new(1, 1, 1), 0.12) or Theme.ElementHover
        b.MouseEnter:Connect(function() tween(b, Motion.Base, { BackgroundColor3 = hoverColor }) end)
        b.MouseLeave:Connect(function() tween(b, Motion.Base, { BackgroundColor3 = restColor }) end)
        pressFeedback(b, b, restColor:Lerp(Color3.new(0, 0, 0), 0.18), hoverColor)
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
        holder.ZIndex = Layer.Notification
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
    notif.ZIndex = Layer.Notification + 1
    notif.Parent = holder
    corner(notif, Radius.Card)
    local notifStroke = stroke(notif, Theme.Stroke, 1)
    notifStroke.Transparency = 0.25

    -- Colour-coded edge: informational toasts use the accent, failures the
    -- danger colour, so the kind of message reads before the text does.
    local kind = tostring(cfg.Type or cfg.Kind or ""):lower()
    local accentColor = Theme.Accent
    if kind == "error" or kind == "danger" or kind == "fail" or kind == "warn" or kind == "warning" then
        accentColor = Theme.Danger
    end

    -- The edge is a floating pill; glued to the rounded left side of the card it
    -- fought the corner radius. It starts at the title top inset and its height
    -- is assigned below, once the body text has been measured, so it spans the
    -- whole text block down to the very last line.
    local edge = Instance.new("Frame")
    edge.Name = "Edge"
    edge.Position = UDim2.new(0, 9, 0, 12)
    edge.Size = UDim2.new(0, 3, 0, 36)
    edge.BackgroundColor3 = accentColor
    edge.BorderSizePixel = 0
    edge.ZIndex = Layer.Notification + 3
    edge.Parent = notif
    corner(edge, 2)

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -38, 0, 20)
    title.Position = UDim2.new(0, 22, 0, 12)
    title.BackgroundTransparency = 1
    title.Text = cfg.Title or "Notification"
    title.TextColor3 = Theme.Text
    title.Font = Enum.Font.GothamBold
    title.TextSize = Type.Label.Size
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.ZIndex = Layer.Notification + 2
    title.Parent = notif

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, -38, 0, 26)
    text.Position = UDim2.new(0, 22, 0, 32)
    text.BackgroundTransparency = 1
    text.Text = cfg.Text or ""
    text.TextColor3 = Theme.SubText
    text.Font = Enum.Font.Gotham
    text.TextSize = Type.Body.Size
    text.TextWrapped = true
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Top
    text.ZIndex = Layer.Notification + 2
    text.Parent = notif

    -- The card used to be a fixed 70px box with a fixed-height body label, so a
    -- wrapped message ran out of the card and the accent pill could never match
    -- the real text block. Measure the body once, then derive the label height,
    -- the card height and the pill height from that single number.
    local bodyWidth = 262
    local measuredHeight = 0
    if text.Text ~= "" then
        local measureOk, measured = pcall(function()
            return game:GetService("TextService"):GetTextSize(
                text.Text, text.TextSize, text.Font, Vector2.new(bodyWidth, 100000)).Y
        end)
        if measureOk and type(measured) == "number" then measuredHeight = measured end
    end
    local bodyHeight = math.max(math.ceil(measuredHeight), 16)
    text.Size = UDim2.new(0, bodyWidth, 0, bodyHeight)
    -- Title occupies 12..32 and the body 32..32+bodyHeight, so 20+bodyHeight is
    -- exactly the text block: from the top of the title to the last body line.
    edge.Size = UDim2.new(0, 3, 0, 20 + bodyHeight)
    -- 14px of bottom padding instead of 12: the 2px progress bar lives there.
    local cardHeight = 32 + bodyHeight + 14

    -- Thin progress bar that drains over the lifetime of the toast.
    local duration = tonumber(cfg.Duration) or 3
    local progress = Instance.new("Frame")
    progress.Name = "Progress"
    progress.AnchorPoint = Vector2.new(0, 1)
    progress.Position = UDim2.new(0, 0, 1, 0)
    progress.Size = UDim2.new(1, 0, 0, 2)
    progress.BackgroundColor3 = accentColor
    progress.BackgroundTransparency = 0.25
    progress.BorderSizePixel = 0
    progress.ZIndex = Layer.Notification + 3
    progress.Parent = notif

    notif.BackgroundTransparency = 1
    tween(notif, Motion.Slow, { Size = UDim2.new(0, 300, 0, cardHeight), BackgroundTransparency = 0 },
        Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    tween(progress, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
    task.delay(duration, function()
        local t = tween(notif, 0.28, { Size = UDim2.new(0, 300, 0, 0), BackgroundTransparency = 1 })
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
    btn.Text = "    " .. (config.Name or "Tab")
    btn.TextColor3 = Theme.SubText
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = Type.Label.Size
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.AutoButtonColor = false
    btn.LayoutOrder = #self.Tabs + 1
    btn.Parent = self.TabList
    corner(btn, Radius.Control)

    -- Soft accent edge on the ACTIVE tab, so the whole button reads as
    -- "selected", not just the mark in front of it. Theme-bound through the
    -- shared binder so a palette switch repaints it like every other control.
    local tabStroke = stroke(btn, Theme.Accent, 1)
    tabStroke.Transparency = 1
    bind(tabStroke, "Color", "Accent")
    tab.TabButtonStroke = tabStroke

    -- Per-tab accent indicator. It grows in on activation and collapses on the
    -- previous tab, which reads as the selection moving between tabs without
    -- any absolute-position math that could fight the scrolling tab list.
    local mark = Instance.new("Frame")
    mark.Name = "TabMark"
    mark.AnchorPoint = Vector2.new(0, 0.5)
    mark.Position = UDim2.new(0, 5, 0.5, 0)
    mark.Size = UDim2.fromOffset(3, 0)
    mark.BackgroundColor3 = Color3.new(1, 1, 1)
    mark.BorderSizePixel = 0
    mark.ZIndex = 3
    mark.Parent = btn
    corner(mark, 2)
    gradient(mark, Theme.Accent, Theme.AccentViolet, 90)
    tab.TabMark = mark

    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 4
    page.ScrollBarImageColor3 = Theme.SubText
    page.ScrollBarImageTransparency = 0.45
    page.Active = true
    page.ScrollingEnabled = true
    page.ScrollingDirection = Enum.ScrollingDirection.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.None
    page.Visible = false
    page.Parent = self.Container
    padding(page, 14)
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 12)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = page

    -- AutomaticCanvasSize can miss delayed height changes from nested Columns
    -- and AutomaticSize groups, leaving touch devices with no scroll range even
    -- though the last card is visibly clipped. Drive the vertical canvas from
    -- the page's direct layout and include the 14 px top/bottom page padding.
    -- Convert post-UIScale absolute pixel measurements back into the window's
    -- pre-scale local units. Offsets of Main's descendants are multiplied by
    -- ResponsiveScale at render time, so absolute values must be divided first.
    local function windowScale()
        local scaleObject = win and win.ScaleObject
        local scale = (scaleObject and alive(scaleObject) and tonumber(scaleObject.Scale)) or 1
        if scale <= 0 then scale = 1 end
        return scale
    end

    local function syncPageCanvas()
        if not alive(page) or not alive(layout) then return end
        page.CanvasSize = UDim2.new(0, 0, 0, math.max(0, layout.AbsoluteContentSize.Y / windowScale() + 28))
    end
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncPageCanvas)
    task.defer(syncPageCanvas)

    local dropdownScrollReserve = Instance.new("Frame")
    dropdownScrollReserve.Name = "DropdownScrollReserve"
    dropdownScrollReserve.Size = UDim2.new(0.8, 0, 0, 0)
    dropdownScrollReserve.BackgroundTransparency = 1
    dropdownScrollReserve.BorderSizePixel = 0
    dropdownScrollReserve.LayoutOrder = 1000000
    dropdownScrollReserve.Parent = page

    -- Empty state. A tab without controls used to render as a blank panel;
    -- now it explains itself and hides the moment the first control, section
    -- or group is added.
    local emptyState = Instance.new("Frame")
    emptyState.Name = "TabEmptyState"
    emptyState.Size = UDim2.new(0.8, 0, 0, 98)
    emptyState.BackgroundColor3 = Theme.Element
    emptyState.BackgroundTransparency = 0.3
    emptyState.BorderSizePixel = 0
    emptyState.LayoutOrder = -1000000
    emptyState.Visible = false
    emptyState.Parent = page
    corner(emptyState, Radius.Card)
    local emptyStroke = stroke(emptyState, Theme.Stroke, 1)
    emptyStroke.Transparency = 0.55
    bind(emptyState, "BackgroundColor3", "Element")

    local emptyMark = Instance.new("Frame")
    emptyMark.Name = "Mark"
    emptyMark.AnchorPoint = Vector2.new(0, 0)
    emptyMark.Position = UDim2.new(0, 14, 0, 20)
    emptyMark.Size = UDim2.fromOffset(26, 3)
    emptyMark.BackgroundColor3 = Color3.new(1, 1, 1)
    emptyMark.BorderSizePixel = 0
    emptyMark.Parent = emptyState
    corner(emptyMark, 2)
    gradient(emptyMark, Theme.Accent, Theme.AccentViolet, 0)

    local emptyTitle = Instance.new("TextLabel")
    emptyTitle.Name = "Title"
    emptyTitle.Size = UDim2.new(1, -28, 0, 18)
    emptyTitle.Position = UDim2.new(0, 14, 0, 34)
    emptyTitle.BackgroundTransparency = 1
    emptyTitle.Text = config.EmptyTitle or "Nothing here yet"
    emptyTitle.TextColor3 = Theme.Text
    emptyTitle.Font = Enum.Font.GothamBold
    emptyTitle.TextSize = Type.Label.Size
    emptyTitle.TextTruncate = Enum.TextTruncate.AtEnd
    emptyTitle.TextXAlignment = Enum.TextXAlignment.Left
    emptyTitle.Parent = emptyState
    bind(emptyTitle, "TextColor3", "Text")

    local emptyHint = Instance.new("TextLabel")
    emptyHint.Name = "Hint"
    emptyHint.Size = UDim2.new(1, -28, 0, 34)
    emptyHint.Position = UDim2.new(0, 14, 0, 56)
    emptyHint.BackgroundTransparency = 1
    emptyHint.Text = config.EmptyText or "This tab has no controls yet."
    emptyHint.TextColor3 = Theme.SubText
    emptyHint.Font = Enum.Font.Gotham
    emptyHint.TextSize = Type.Caption.Size
    emptyHint.TextWrapped = true
    emptyHint.TextXAlignment = Enum.TextXAlignment.Left
    emptyHint.TextYAlignment = Enum.TextYAlignment.Top
    emptyHint.Parent = emptyState
    bind(emptyHint, "TextColor3", "SubText")

    local function syncEmptyState()
        if not alive(page) or not alive(emptyState) then return end
        local hasContent = false
        for _, child in ipairs(page:GetChildren()) do
            if child ~= emptyState and child ~= dropdownScrollReserve and child:IsA("GuiObject") then
                hasContent = true
                break
            end
        end
        emptyState.Visible = not hasContent
    end
    page.ChildAdded:Connect(function() task.defer(syncEmptyState) end)
    page.ChildRemoved:Connect(function() task.defer(syncEmptyState) end)
    task.defer(syncEmptyState)
    tab.EmptyState = emptyState
    tab._syncEmptyState = syncEmptyState

    -- Topbar search. Matching runs over every label inside a row or card, so a
    -- group stays on screen while any of its controls matches the query.
    local searchQuery = ""
    local emptyDefaults = { title = emptyTitle.Text, hint = emptyHint.Text }

    -- The searchable text of a card is cached: every keystroke re-filters all
    -- tabs, and walking each card's descendants again would be wasteful. The
    -- cache is dropped when the page changes or after a moment, so labels that
    -- update in place stay searchable.
    local searchCache = setmetatable({}, { __mode = "k" })
    local searchCacheGen = 0

    local function searchText(child)
        local cached = searchCache[child]
        if cached and cached.gen == searchCacheGen and (os.clock() - cached.at) < 1.5 then
            return cached.text
        end
        local parts = { (tostring(child.Name):gsub("^Group_", "")) }
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            table.insert(parts, child.Text)
        end
        for _, d in ipairs(child:GetDescendants()) do
            if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
                table.insert(parts, d.Text)
            end
        end
        local text = string.lower(table.concat(parts, " "))
        searchCache[child] = { gen = searchCacheGen, at = os.clock(), text = text }
        return text
    end

    -- Words are matched one by one, so "join villain" also finds
    -- "Villain invasion auto joiner" regardless of word order or spacing.
    local searchTokens = {}
    local function matchesSearch(child)
        local text = searchText(child)
        for _, token in ipairs(searchTokens) do
            if not string.find(text, token, 1, true) then return false end
        end
        return true
    end

    local function applySearch(query)
        searchQuery = string.lower(tostring(query or ""))
        searchTokens = {}
        for word in string.gmatch(searchQuery, "[^%s]+") do
            table.insert(searchTokens, word)
        end
        if not alive(page) or not alive(emptyState) then return 0 end
        local matches = 0
        for _, child in ipairs(page:GetChildren()) do
            if child ~= emptyState and child ~= dropdownScrollReserve and child:IsA("GuiObject") then
                if searchQuery == "" then
                    if child:GetAttribute("PoloskaSearchHidden") == true then
                        child:SetAttribute("PoloskaSearchHidden", nil)
                        child.Visible = true
                    end
                    matches = matches + 1
                elseif matchesSearch(child) then
                    if child:GetAttribute("PoloskaSearchHidden") == true then
                        child:SetAttribute("PoloskaSearchHidden", nil)
                        child.Visible = true
                    end
                    matches = matches + 1
                else
                    child:SetAttribute("PoloskaSearchHidden", true)
                    child.Visible = false
                end
            end
        end
        if searchQuery ~= "" then
            if matches == 0 then
                emptyTitle.Text = "No matches"
                emptyHint.Text = "Nothing here matches the search."
                emptyState.Visible = true
            else
                emptyState.Visible = false
            end
        else
            emptyTitle.Text = emptyDefaults.title
            emptyHint.Text = emptyDefaults.hint
            syncEmptyState()
        end
        return matches
    end

    -- Content added while a filter is active has to be filtered too. These run
    -- after the empty-state handlers above, so the search wins.
    page.ChildAdded:Connect(function()
        searchCacheGen = searchCacheGen + 1
        task.defer(function() if searchQuery ~= "" then applySearch(searchQuery) end end)
    end)
    page.ChildRemoved:Connect(function()
        searchCacheGen = searchCacheGen + 1
        task.defer(function() if searchQuery ~= "" then applySearch(searchQuery) end end)
    end)
    tab._applySearch = applySearch

    -- Sidebar hint for the cross-tab search: a tab whose cards were all
    -- filtered out is dimmed, everything else keeps its normal look. The label
    -- itself is never rewritten, so no counters appear next to the name.
    local function setSearchCount(count)
        if not alive(btn) then return end
        if count == nil then
            btn.TextTransparency = 0
            return
        end
        btn.TextTransparency = (tonumber(count) or 0) > 0 and 0 or 0.55
    end
    tab._setSearchCount = setSearchCount

    tab.TabButton = btn
    tab.Page = page
    tab._popups = {}
    tab._popupClosers = {}
    tab._popupRefreshers = {}

    local function setDropdownScrollReserve(_height)
        -- An open popup no longer follows the page and is always clamped inside
        -- the window, so the page needs no extra scroll room underneath it.
        dropdownScrollReserve.Size = UDim2.new(0.8, 0, 0, 0)
    end
    local function closeAllPopups()
        for _, closePopup in ipairs(tab._popupClosers) do pcall(closePopup) end
    end
    -- A floating popup does not stop MouseEnter on the controls it covers, so
    -- hover paint has to ask whether an open popup is currently in front of it.
    -- Without this the element sitting behind an open dropdown lit up together
    -- with the hovered row.
    local function popupCovering(object)
        for _, popup in ipairs(tab._popups) do
            if alive(popup) and popup.Visible and not (object and object:IsDescendantOf(popup)) then
                return true
            end
        end
        return false
    end
    local function refreshOpenPopups()
        for _, refreshPopup in ipairs(tab._popupRefreshers) do pcall(refreshPopup) end
    end
    -- Scrolling the page must not drag an open popup with it; the popup stays
    -- exactly where it was opened. Only a window resize needs a re-anchor.
    if win and win.Main and alive(win.Main) then
        win.Main:GetPropertyChangedSignal("AbsoluteSize"):Connect(refreshOpenPopups)
    end

    local function activate()
        -- These assignments intentionally do not tween. A hover tween can still
        -- be running when a tab changes; direct values guarantee that inactive
        -- tabs immediately return to their transparent, muted state.
        for _, t in pairs(self.Tabs) do
            if t.Page then t.Page.Visible = false end
            t._active = false
            if t._popupClosers then
                for _, closePopup in ipairs(t._popupClosers) do pcall(closePopup) end
            elseif t._popups then
                for _, popup in ipairs(t._popups) do
                    if alive(popup) then popup.Visible = false end
                end
            end
            if t.TabButton then
                t.TabButton.BackgroundTransparency = 1
                t.TabButton.BackgroundColor3 = Theme.Element
                t.TabButton.TextColor3 = Theme.SubText
            end
            if t.TabButtonStroke and alive(t.TabButtonStroke) then
                t.TabButtonStroke.Transparency = 1
            end
            if t.TabMark and alive(t.TabMark) then
                tween(t.TabMark, Motion.Base, { Size = UDim2.fromOffset(3, 0) })
            end
        end
        page.Visible = true
        tab._active = true
        btn.BackgroundTransparency = 0
        btn.BackgroundColor3 = Theme.ElementHover
        btn.TextColor3 = Theme.Text
        if alive(tabStroke) then tabStroke.Transparency = 0.4 end
        if alive(mark) then
            mark.Size = UDim2.fromOffset(3, 0)
            tween(mark, 0.3, { Size = UDim2.fromOffset(3, 18) }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        end
        -- Keep the topbar filter applied to whichever tab is now on screen.
        if self._runSearch then task.defer(self._runSearch) end
    end

    btn.MouseButton1Click:Connect(function()
        -- Picking a tab by hand beats the search: it stops the filter from
        -- pulling the user away from this tab for the current query.
        tab._searchTabPicked = true
        activate()
    end)
    -- Lets the topbar search bring a matching tab to the front.
    tab._activate = activate
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
        corner(f, Radius.Control)
        local elementStroke = stroke(f, Theme.Stroke, 1)
        elementStroke.Transparency = 0.35
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
        card.BackgroundColor3 = Theme.ElementHover
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
        title.TextTruncate = Enum.TextTruncate.AtEnd
        title.TextColor3 = Theme.Text
        title.Font = Enum.Font.GothamBold
        title.TextSize = Type.Title.Size
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
            left.Size = UDim2.fromOffset(8, 2)
            left.AnchorPoint = Vector2.new(1, 0.5)
            left.Position = UDim2.fromOffset(8, 9)
            left.Rotation = 45
            left.BackgroundColor3 = Theme.SubText
            left.BorderSizePixel = 0
            left.Parent = chevron
            corner(left, 1)

            local right = Instance.new("Frame")
            right.Size = UDim2.fromOffset(8, 2)
            right.AnchorPoint = Vector2.new(0, 0.5)
            right.Position = UDim2.fromOffset(8, 9)
            right.Rotation = -45
            right.BackgroundColor3 = Theme.SubText
            right.BorderSizePixel = 0
            right.Parent = chevron
            corner(right, 1)
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
            description.TextSize = Type.Body.Size
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
        local gap = cfg.Gap or 12
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
                -- AbsoluteContentSize is post-UIScale; convert to local units so
                -- scaled mobile windows don't clip or overlap column content.
                row.Size = UDim2.new(1, 0, 0, math.max(leftLayout.AbsoluteContentSize.Y, rightLayout.AbsoluteContentSize.Y) / windowScale())
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
        b.TextTruncate = Enum.TextTruncate.AtEnd
        b.TextColor3 = Theme.Text
        b.Font = Enum.Font.GothamMedium
        b.TextSize = Type.Label.Size
        b.Parent = f
        b.MouseEnter:Connect(function() tween(f, Motion.Base, {BackgroundColor3 = Theme.ElementHover}) end)
        b.MouseLeave:Connect(function() tween(f, Motion.Base, {BackgroundColor3 = Theme.Element}) end)
        pressFeedback(b, f, Theme.Stroke, Theme.ElementHover)
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
        label.Size = UDim2.new(1, -82, 0, 0)
        label.AutomaticSize = Enum.AutomaticSize.Y
        label.Position = UDim2.new(0, 14, 0, 15)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Toggle"
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = Type.Label.Size
        label.TextWrapped = true
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = f

        -- A long name is never cut off and never painted over the switch: the
        -- label wraps and the row grows from its 48px minimum instead.
        local function syncToggleHeight()
            if not alive(f) or not alive(label) then return end
            local height = math.max(48, label.AbsoluteSize.Y + 30)
            f.Size = UDim2.new(f.Size.X.Scale, f.Size.X.Offset, 0, height)
        end
        label:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncToggleHeight)
        syncToggleHeight()

        local switch = Instance.new("TextButton")
        switch.Size = UDim2.fromOffset(40, 22)
        switch.Position = UDim2.new(1, -54, 0.5, 0)
        switch.AnchorPoint = Vector2.new(0, 0.5)
        switch.BackgroundColor3 = Theme.Stroke
        switch.Text = ""
        switch.AutoButtonColor = false
        switch.Parent = f
        corner(switch, 11)
        local switchStroke = stroke(switch, Theme.Stroke, 1)
        switchStroke.Transparency = 0.45
        -- Accent glow that fades in together with the on state.
        local glow = dropShadow(switch, 12, 0.6)
        if glow then
            shadowTint(glow, Theme.Accent)
            glow:SetAttribute("PreserveThemeColors", false)
            -- Hidden until the toggle is switched on.
            shadowFade(glow, 1)
        end

        local knob = Instance.new("Frame")
        knob.Size = UDim2.fromOffset(16, 16)
        knob.Position = UDim2.new(0, 3, 0.5, 0)
        knob.AnchorPoint = Vector2.new(0, 0.5)
        knob.BackgroundColor3 = Theme.Text
        knob.BorderSizePixel = 0
        knob.Parent = switch
        corner(knob, 8)
        switch.MouseButton1Down:Connect(function()
            tween(knob, Motion.Fast, { Size = UDim2.fromOffset(18, 18) })
        end)
        switch.MouseButton1Up:Connect(function()
            tween(knob, Motion.Base, { Size = UDim2.fromOffset(16, 16) })
        end)

        local function update()
            if state then
                tween(switch, Motion.Base, {BackgroundColor3 = Theme.Accent})
                tween(knob, 0.28, {Position = UDim2.new(0, 21, 0.5, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                tween(switchStroke, Motion.Base, {Transparency = 0.1})
                if glow then shadowFade(glow, 0.55, Motion.Base) end
            else
                tween(switch, Motion.Base, {BackgroundColor3 = Theme.Stroke})
                tween(knob, 0.28, {Position = UDim2.new(0, 3, 0.5, 0)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                tween(switchStroke, Motion.Base, {Transparency = 0.45})
                if glow then shadowFade(glow, 1, Motion.Base) end
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
        local min, max = tonumber(cfg.Min) or 0, tonumber(cfg.Max) or 100
        local editable = cfg.Editable == true
        local commitOnRelease = cfg.CommitOnRelease == true

        local function normalizeValue(candidate)
            local number = tonumber(candidate)
            if not number then return nil end
            return math.clamp(math.floor(number + 0.5), min, max)
        end

        local value = normalizeValue(cfg.Default) or min
        local f = baseElement(54)

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -78, 0, 20)
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.Position = UDim2.new(0, 14, 0, 8)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Slider"
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = Type.Label.Size
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = f

        local valLabel = Instance.new(editable and "TextBox" or "TextLabel")
        valLabel.Size = UDim2.new(0, 58, 0, editable and 24 or 20)
        valLabel.Position = UDim2.new(1, -70, 0, editable and 6 or 8)
        valLabel.BackgroundTransparency = editable and 0 or 1
        valLabel.BackgroundColor3 = Theme.Background
        valLabel.BorderSizePixel = 0
        valLabel.Text = tostring(value)
        valLabel.TextColor3 = editable and Theme.Text or Theme.SubText
        valLabel.Font = Enum.Font.GothamMedium
        valLabel.TextSize = Type.Label.Size
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        if editable then
            valLabel.PlaceholderColor3 = Theme.SubText
            valLabel.ClearTextOnFocus = false
            valLabel.TextEditable = true
            corner(valLabel, Radius.Chip)
            local valueStroke = stroke(valLabel, Theme.Stroke, 1)
            valueStroke.Transparency = 0.35
            -- Focus ring: the editable value field shows where typing goes.
            valLabel.Focused:Connect(function()
                tween(valueStroke, Motion.Base, { Color = Theme.Accent, Transparency = 0 })
            end)
            valLabel.FocusLost:Connect(function()
                tween(valueStroke, Motion.Base, { Color = Theme.Stroke, Transparency = 0.35 })
            end)
            local valuePadding = Instance.new("UIPadding")
            valuePadding.PaddingLeft = UDim.new(0, 6)
            valuePadding.PaddingRight = UDim.new(0, 6)
            valuePadding.Parent = valLabel
        end
        valLabel.Parent = f

        local bar = Instance.new("Frame")
        bar.Size = UDim2.new(1, -28, 0, 6)
        bar.Position = UDim2.new(0, 14, 1, -16)
        bar.BackgroundColor3 = Theme.Stroke
        bar.BorderSizePixel = 0
        bar.Parent = f
        corner(bar, 3)

        local fill = Instance.new("Frame")
        fill.BackgroundColor3 = Color3.new(1, 1, 1)
        fill.BorderSizePixel = 0
        fill.Parent = bar
        corner(fill, 3)
        gradient(fill, Theme.Accent, Theme.AccentViolet, 0)

        -- Thumb at the end of the filled part: the current value stays readable
        -- at a glance and the drag gets a visible grip.
        local thumb = Instance.new("Frame")
        thumb.Name = "Thumb"
        thumb.AnchorPoint = Vector2.new(0.5, 0.5)
        thumb.Position = UDim2.new(0, 0, 0.5, 0)
        thumb.Size = UDim2.fromOffset(12, 12)
        thumb.BackgroundColor3 = Theme.Text
        thumb.BorderSizePixel = 0
        thumb.ZIndex = 3
        thumb.Parent = bar
        corner(thumb, 6)
        local thumbStroke = stroke(thumb, Theme.Accent, 2)
        thumbStroke.Transparency = 0.2

        local function render()
            local range = math.max(max - min, 1)
            local rel = math.clamp((value - min) / range, 0, 1)
            if alive(fill) then tween(fill, Motion.Fast, { Size = UDim2.new(rel, 0, 1, 0) }) end
            if alive(thumb) then tween(thumb, Motion.Fast, { Position = UDim2.new(rel, 0, 0.5, 0) }) end
            if alive(valLabel) then valLabel.Text = tostring(value) end
        end

        local function emitLive()
            if cfg.LiveCallback then
                cfg.LiveCallback(value)
            elseif not commitOnRelease and cfg.Callback then
                cfg.Callback(value)
            end
        end

        local function commit()
            if cfg.Callback then cfg.Callback(value) end
        end

        local function assign(candidate, live)
            local normalized = normalizeValue(candidate)
            if normalized == nil then return false end
            local changed = normalized ~= value
            value = normalized
            render()
            if live and (changed or cfg.EmitUnchanged == true) then emitLive() end
            return changed
        end

        local dragging = false
        local dragChanged = false
        local activeTouch = nil
        local touchStart = nil
        local touchCommitted = false

        local function setFromX(x)
            if not alive(bar) or bar.AbsoluteSize.X <= 0 then
                dragging = false
                return false
            end
            local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            return assign(min + (max - min) * rel, true)
        end

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                tween(thumb, Motion.Fast, { Size = UDim2.fromOffset(15, 15) })
                dragChanged = setFromX(input.Position.X)
            elseif input.UserInputType == Enum.UserInputType.Touch then
                -- Wait for horizontal intent so a vertical page scroll which
                -- starts over the slider never changes its value.
                activeTouch = input
                touchStart = input.Position
                touchCommitted = false
                dragChanged = false
                dragging = false
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 and dragging
                and activeTouch == nil then
                dragging = false
                tween(thumb, Motion.Base, { Size = UDim2.fromOffset(12, 12) })
                if commitOnRelease and dragChanged then commit() end
                dragChanged = false
            elseif input.UserInputType == Enum.UserInputType.Touch and input == activeTouch then
                if not touchCommitted and touchStart then
                    dragChanged = setFromX(input.Position.X) or dragChanged
                end
                if commitOnRelease and dragChanged then commit() end
                dragging = false
                activeTouch = nil
                touchStart = nil
                touchCommitted = false
                dragChanged = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and dragging
                and activeTouch == nil then
                dragChanged = setFromX(input.Position.X) or dragChanged
            elseif input.UserInputType == Enum.UserInputType.Touch and input == activeTouch
                and touchStart then
                local delta = input.Position - touchStart
                if not touchCommitted then
                    if math.max(math.abs(delta.X), math.abs(delta.Y)) < 8 then return end
                    if math.abs(delta.Y) > math.abs(delta.X) then
                        dragging = false
                        activeTouch = nil
                        touchStart = nil
                        return
                    end
                    touchCommitted = true
                    dragging = true
                end
                if dragging then
                    dragChanged = setFromX(input.Position.X) or dragChanged
                end
            end
        end)

        if editable then
            valLabel.FocusLost:Connect(function()
                local parsed = tonumber((valLabel.Text or ""):gsub("%%", ""):gsub(",", "."))
                if parsed == nil then
                    render()
                    return
                end
                local changed = assign(parsed, true)
                if commitOnRelease and changed then commit() end
            end)
        end

        render()
        return {
            Frame = f,
            Input = editable and valLabel or nil,
            Set = function(_, candidate)
                assign(candidate, false)
            end,
            Get = function()
                return value
            end,
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
        label.TextSize = Type.Label.Size
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
        corner(boxFrame, Radius.Chip)
        local boxStroke = stroke(boxFrame, Theme.Stroke, 1)
        boxStroke.Transparency = 0.35

        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -12, 1, 0)
        box.Position = UDim2.new(0, 6, 0, 0)
        box.BackgroundTransparency = 1
        box.Text = cfg.Default or ""
        box.PlaceholderText = cfg.Placeholder or "Type here..."
        box.PlaceholderColor3 = Theme.SubText
        box.TextColor3 = Theme.Text
        box.Font = Enum.Font.Gotham
        box.TextSize = Type.Label.Size
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.TextTruncate = Enum.TextTruncate.AtEnd
        box.ClipsDescendants = true
        box.ClearTextOnFocus = false
        box.Parent = boxFrame
        -- Focus state: accent ring plus a slightly lifted field background.
        box.Focused:Connect(function()
            tween(boxStroke, Motion.Base, { Color = Theme.Accent, Transparency = 0 })
            tween(boxFrame, Motion.Base, { BackgroundColor3 = Theme.Element })
        end)
        box.FocusLost:Connect(function()
            tween(boxStroke, Motion.Base, { Color = Theme.Stroke, Transparency = 0.35 })
            tween(boxFrame, Motion.Base, { BackgroundColor3 = Theme.Background })
            if cfg.Callback then cfg.Callback(box.Text) end
        end)
        return f
    end

    --// DROPDOWN (overlay popup: it never resizes the page/card)
    function tab:Dropdown(cfg)
        cfg = cfg or {}
        local items = cfg.Items or {}
        local open = false
        local stacked = cfg.Stacked == true
        local f = baseElement(stacked and 72 or 44)

        local label = Instance.new("TextLabel")
        label.Size = stacked
            and UDim2.new(1, -28, 0, 24)
            or UDim2.new(1, -190, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Dropdown"
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = Type.Label.Size
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = f

        -- Stacked mode renders the value inside a rounded field (same style
        -- as the Textbox input) instead of a bare floating text line.
        local fieldBox
        if stacked then
            fieldBox = Instance.new("Frame")
            fieldBox.Name = "FieldBox"
            fieldBox.Size = UDim2.new(1, -28, 0, 30)
            fieldBox.Position = UDim2.new(0, 14, 0, 34)
            fieldBox.BackgroundColor3 = Theme.Background
            fieldBox.BorderSizePixel = 0
            fieldBox.ClipsDescendants = true
            fieldBox.Parent = f
            corner(fieldBox, Radius.Chip)
            local fieldStroke = stroke(fieldBox, Theme.Stroke, 1)
            fieldStroke.Transparency = 0.35
        end

        local selected = Instance.new("TextLabel")
        selected.Size = stacked
            and UDim2.new(1, -46, 1, 0)
            or UDim2.new(0, 150, 1, 0)
        selected.Position = stacked
            and UDim2.new(0, 10, 0, 0)
            or UDim2.new(1, -188, 0, 0)
        selected.BackgroundTransparency = 1
        selected.Text = cfg.StartingText or "Select..."
        selected.TextColor3 = Theme.SubText
        selected.Font = Enum.Font.Gotham
        selected.TextSize = Type.Label.Size
        selected.TextTruncate = Enum.TextTruncate.AtEnd
        selected.TextXAlignment = stacked and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
        selected.Parent = stacked and fieldBox or f

        -- Font-independent vector chevron. The old Unicode glyph rendered as
        -- a missing-character square on clients whose Roblox font lacked it.
        local arrow = Instance.new("Frame")
        arrow.Name = "Chevron"
        arrow.Size = UDim2.fromOffset(16, 16)
        arrow.AnchorPoint = Vector2.new(0.5, 0.5)
        arrow.Position = stacked
            and UDim2.new(1, -15, 0.5, 0)
            or UDim2.new(1, -17, 0.5, 0)
        arrow.BackgroundTransparency = 1
        arrow.ZIndex = Layer.Content + 1
        arrow.Parent = stacked and fieldBox or f

        local arrowLeft = Instance.new("Frame")
        arrowLeft.Size = UDim2.fromOffset(8, 2)
        arrowLeft.AnchorPoint = Vector2.new(1, 0.5)
        arrowLeft.Position = UDim2.fromOffset(8, 9)
        arrowLeft.Rotation = 45
        arrowLeft.BackgroundColor3 = Theme.SubText
        arrowLeft.BorderSizePixel = 0
        arrowLeft.ZIndex = Layer.Content + 2
        arrowLeft.Parent = arrow
        corner(arrowLeft, 1)

        local arrowRight = Instance.new("Frame")
        arrowRight.Size = UDim2.fromOffset(8, 2)
        arrowRight.AnchorPoint = Vector2.new(0, 0.5)
        arrowRight.Position = UDim2.fromOffset(8, 9)
        arrowRight.Rotation = -45
        arrowRight.BackgroundColor3 = Theme.SubText
        arrowRight.BorderSizePixel = 0
        arrowRight.ZIndex = Layer.Content + 2
        arrowRight.Parent = arrow
        corner(arrowRight, 1)

        local trigger = Instance.new("TextButton")
        trigger.Size = UDim2.new(1, 0, 1, 0)
        trigger.BackgroundTransparency = 1
        trigger.Text = ""
        trigger.ZIndex = Layer.Content
        trigger.Parent = f

        local popup = Instance.new("ScrollingFrame")
        popup.Name = "DropdownOverlay"
        popup.Visible = false
        -- Same input guard as the multi-select list: the floating popup must
        -- sink pointer input so the control underneath stops receiving hover.
        popup.Active = true
        popup.BackgroundColor3 = Theme.Element
        popup.BorderSizePixel = 0
        popup.ScrollBarThickness = 4
        popup.ScrollBarImageColor3 = Theme.SubText
        popup.ScrollBarImageTransparency = 0.45
        popup.CanvasSize = UDim2.new(0, 0, 0, 0)
        popup.AutomaticCanvasSize = Enum.AutomaticSize.Y
        popup.ZIndex = Layer.Popup
        popup.Parent = win.Overlay or win.Main
        corner(popup, Radius.Card)
        local popupStroke = stroke(popup, Theme.Stroke, 1)
        popupStroke.Transparency = 0.15
        padding(popup, 6)
        local popupLayout = Instance.new("UIListLayout")
        popupLayout.Padding = UDim.new(0, 4)
        popupLayout.SortOrder = Enum.SortOrder.LayoutOrder
        popupLayout.Parent = popup
        table.insert(tab._popups, popup)

        local popupFlipped = false
        local function positionPopup(reanchor)
            if not open or not alive(popup) or not alive(f) then return end
            -- Absolute pixel deltas must be converted into the pre-UIScale
            -- local space of Main, otherwise popups drift on scaled windows.
            -- The popup lives in the window overlay, so it has to be moved on
            -- every scroll to stay glued under the field that opened it.
            local scale = windowScale()
            local main = win.Main
            local fieldX = (f.AbsolutePosition.X - main.AbsolutePosition.X) / scale
            local fieldY = (f.AbsolutePosition.Y - main.AbsolutePosition.Y) / scale
            local fieldHeight = f.AbsoluteSize.Y / scale
            local mainWidth = main.AbsoluteSize.X / scale
            local mainHeight = main.AbsoluteSize.Y / scale
            local popupWidth = popup.Size.X.Offset
            local popupHeight = popup.Size.Y.Offset
            -- The below/above decision is taken once, when the list opens, so
            -- the popup never jumps to the other side of the field mid-scroll.
            if reanchor then
                local fitsBelow = (fieldY + fieldHeight + 8 + popupHeight) <= (mainHeight - 8)
                local fitsAbove = (fieldY - popupHeight - 8) >= 8
                popupFlipped = (not fitsBelow) and fitsAbove
            end
            local x = math.clamp(fieldX, 8, math.max(8, mainWidth - popupWidth - 8))
            local y
            if popupFlipped then
                y = fieldY - popupHeight - 8
            else
                y = fieldY + fieldHeight + 8
            end
            popup.Position = UDim2.fromOffset(x, y)
            -- Hide the list as soon as its field is scrolled out of the page.
            if page and alive(page) then
                local pageTop = (page.AbsolutePosition.Y - main.AbsolutePosition.Y) / scale
                local pageBottom = pageTop + page.AbsoluteSize.Y / scale
                popup.Visible = ((fieldY + fieldHeight) > pageTop) and (fieldY < pageBottom)
            end
        end
        table.insert(tab._popupRefreshers, positionPopup)
        if alive(f) then
            f:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() positionPopup() end)
        end

        -- Selection state is drawn on the rows themselves, so an open list
        -- always shows which value is currently active.
        local itemButtons = {}
        local function refreshSelection()
            for name, button in pairs(itemButtons) do
                if alive(button) then
                    local isActive = selected.Text == name
                    tween(button, Motion.Fast, {
                        BackgroundColor3 = isActive and Theme.ElementHover or Theme.Background,
                        TextColor3 = isActive and Theme.Text or Theme.SubText,
                    })
                    local activeMark = button:FindFirstChild("ActiveMark")
                    if activeMark then
                        tween(activeMark, Motion.Fast, { BackgroundTransparency = isActive and 0 or 1 })
                    end
                end
            end
        end

        local function close()
            open = false
            if alive(popup) then popup.Visible = false end
            if alive(arrow) then tween(arrow, Motion.Base, { Rotation = 0 }) end
            if alive(arrowLeft) then tween(arrowLeft, Motion.Base, { BackgroundColor3 = Theme.SubText }) end
            if alive(arrowRight) then tween(arrowRight, Motion.Base, { BackgroundColor3 = Theme.SubText }) end
            setDropdownScrollReserve(0)
        end

        table.insert(tab._popupClosers, close)

        local function rebuild()
            for _, child in ipairs(popup:GetChildren()) do
                if child:IsA("TextButton") or child.Name == "EmptyState" then child:Destroy() end
            end
            itemButtons = {}
            if #items == 0 then
                -- Without this an empty list opened as a bare 12 px sliver.
                local empty = Instance.new("TextLabel")
                empty.Name = "EmptyState"
                empty.Size = UDim2.new(1, 0, 0, 34)
                empty.BackgroundTransparency = 1
                empty.Text = cfg.EmptyText or "No options available"
                empty.TextColor3 = Theme.SubText
                empty.Font = Enum.Font.Gotham
                empty.TextSize = Type.Caption.Size
                empty.TextWrapped = true
                empty.ZIndex = Layer.Popup + 1
                empty.Parent = popup
                bind(empty, "TextColor3", "SubText")
                return
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
                itemButton.TextSize = Type.Label.Size
                itemButton.TextXAlignment = Enum.TextXAlignment.Left
                itemButton.TextTruncate = Enum.TextTruncate.AtEnd
                itemButton.AutoButtonColor = false
                itemButton.ZIndex = Layer.Popup + 1
                itemButton.Parent = popup
                corner(itemButton, Radius.Chip)
                local itemPadding = Instance.new("UIPadding")
                itemPadding.PaddingLeft = UDim.new(0, 14)
                itemPadding.Parent = itemButton
                -- Accent mark lives in the padding gutter, so it never collides
                -- with the row label.
                local activeMark = Instance.new("Frame")
                activeMark.Name = "ActiveMark"
                activeMark.AnchorPoint = Vector2.new(0, 0.5)
                activeMark.Position = UDim2.new(0, -9, 0.5, 0)
                activeMark.Size = UDim2.fromOffset(3, 14)
                activeMark.BackgroundColor3 = Theme.Accent
                activeMark.BackgroundTransparency = 1
                activeMark.BorderSizePixel = 0
                activeMark.ZIndex = Layer.Popup + 2
                activeMark.Parent = itemButton
                corner(activeMark, 2)
                itemButtons[itemName] = itemButton
                itemButton.MouseEnter:Connect(function()
                    tween(itemButton, Motion.Fast, {BackgroundColor3 = Theme.ElementHover, TextColor3 = Theme.Text})
                end)
                itemButton.MouseLeave:Connect(function()
                    if selected.Text == itemName then return end
                    tween(itemButton, Motion.Fast, {BackgroundColor3 = Theme.Background, TextColor3 = Theme.SubText})
                end)
                itemButton.MouseButton1Click:Connect(function()
                    selected.Text = itemName
                    selected.TextColor3 = Theme.Text
                    refreshSelection()
                    close()
                    if cfg.Callback then cfg.Callback(item) end
                end)
            end
            refreshSelection()
        end
        rebuild()

        local function show()
            closeAllPopups()
            -- Room for eight rows before the list starts scrolling.
            -- An empty list keeps enough room for its placeholder row.
            local wanted = math.max(46, math.min((8 * 34) + 12, (#items * 34) + 12))
            local width = math.max(180, f.AbsoluteSize.X / windowScale())
            -- Downwards is the default direction. The list flips above the
            -- field only when the space below is too small to be usable;
            -- otherwise it is trimmed to the free space and scrolls inside.
            local scale = windowScale()
            local main = win.Main
            local fieldY = (f.AbsolutePosition.Y - main.AbsolutePosition.Y) / scale
            local fieldHeight = f.AbsoluteSize.Y / scale
            local mainHeight = main.AbsoluteSize.Y / scale
            local spaceBelow = mainHeight - 16 - (fieldY + fieldHeight)
            local spaceAbove = fieldY - 16
            popupFlipped = (spaceBelow < math.min(wanted, 92)) and (spaceAbove > spaceBelow)
            local room = popupFlipped and spaceAbove or spaceBelow
            local height = math.max(46, math.min(wanted, math.floor(room)))
            popup.Size = UDim2.fromOffset(width, height)
            open = true
            setDropdownScrollReserve(height + 28)
            positionPopup(false)
            popup.Visible = true
            -- Grow the overlay out of the field instead of snapping it open.
            popup.Size = UDim2.fromOffset(width, 0)
            popup.BackgroundTransparency = 1
            tween(popup, Motion.Base, { Size = UDim2.fromOffset(width, height), BackgroundTransparency = 0 })
            tween(arrow, Motion.Base, { Rotation = 180 })
            tween(arrowLeft, Motion.Base, { BackgroundColor3 = Theme.Accent })
            tween(arrowRight, Motion.Base, { BackgroundColor3 = Theme.Accent })
        end
        trigger.MouseButton1Click:Connect(function()
            if open then close() else show() end
        end)
        -- Field, popup and rows carry hover/selected state, so a palette switch
        -- has to repaint them instead of waiting for the next mouse hover.
        onThemeChanged(function()
            if not alive(f) then return false end
            f.BackgroundColor3 = Theme.Element
            if fieldBox and alive(fieldBox) then fieldBox.BackgroundColor3 = Theme.Background end
            if alive(popup) then
                popup.BackgroundColor3 = Theme.Element
                popup.ScrollBarImageColor3 = Theme.SubText
            end
            if alive(popupStroke) then popupStroke.Color = Theme.Stroke end
            local placeholder = cfg.StartingText or "Select..."
            selected.TextColor3 = selected.Text ~= placeholder and Theme.Text or Theme.SubText
            local arrowColor = open and Theme.Accent or Theme.SubText
            if alive(arrowLeft) then arrowLeft.BackgroundColor3 = arrowColor end
            if alive(arrowRight) then arrowRight.BackgroundColor3 = arrowColor end
            for _, button in pairs(itemButtons) do
                if alive(button) then
                    local activeMark = button:FindFirstChild("ActiveMark")
                    if activeMark then activeMark.BackgroundColor3 = Theme.Accent end
                end
            end
            refreshSelection()
        end)
        trigger.MouseEnter:Connect(function()
            if popupCovering(f) then return end
            tween(f, Motion.Base, { BackgroundColor3 = Theme.ElementHover })
        end)
        trigger.MouseLeave:Connect(function() tween(f, Motion.Base, { BackgroundColor3 = Theme.Element }) end)
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
                selected.TextColor3 = Theme.Text
                refreshSelection()
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
        local stacked = cfg.Stacked == true
        local f = baseElement(stacked and 72 or 44)

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
        label.Size = stacked
            and UDim2.new(1, -28, 0, 24)
            or UDim2.new(1, -190, 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Multi Dropdown"
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = Type.Label.Size
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = f

        -- Stacked mode renders the value inside a rounded field (same style
        -- as the Textbox input) instead of a bare floating text line.
        local fieldBox
        if stacked then
            fieldBox = Instance.new("Frame")
            fieldBox.Name = "FieldBox"
            fieldBox.Size = UDim2.new(1, -28, 0, 30)
            fieldBox.Position = UDim2.new(0, 14, 0, 34)
            fieldBox.BackgroundColor3 = Theme.Background
            fieldBox.BorderSizePixel = 0
            fieldBox.ClipsDescendants = true
            fieldBox.Parent = f
            corner(fieldBox, Radius.Chip)
            local fieldStroke = stroke(fieldBox, Theme.Stroke, 1)
            fieldStroke.Transparency = 0.35
        end

        local selected = Instance.new("TextLabel")
        selected.Size = stacked
            and UDim2.new(1, -46, 1, 0)
            or UDim2.new(0, 150, 1, 0)
        selected.Position = stacked
            and UDim2.new(0, 10, 0, 0)
            or UDim2.new(1, -188, 0, 0)
        selected.BackgroundTransparency = 1
        selected.TextColor3 = Theme.SubText
        selected.Font = Enum.Font.Gotham
        selected.TextSize = Type.Label.Size
        selected.TextTruncate = Enum.TextTruncate.AtEnd
        selected.TextXAlignment = stacked and Enum.TextXAlignment.Left or Enum.TextXAlignment.Right
        selected.Parent = stacked and fieldBox or f

        -- Font-independent vector chevron. The old Unicode glyph rendered as
        -- a missing-character square on clients whose Roblox font lacked it.
        local arrow = Instance.new("Frame")
        arrow.Name = "Chevron"
        arrow.Size = UDim2.fromOffset(16, 16)
        arrow.AnchorPoint = Vector2.new(0.5, 0.5)
        arrow.Position = stacked
            and UDim2.new(1, -15, 0.5, 0)
            or UDim2.new(1, -17, 0.5, 0)
        arrow.BackgroundTransparency = 1
        arrow.ZIndex = Layer.Content + 1
        arrow.Parent = stacked and fieldBox or f

        local arrowLeft = Instance.new("Frame")
        arrowLeft.Size = UDim2.fromOffset(8, 2)
        arrowLeft.AnchorPoint = Vector2.new(1, 0.5)
        arrowLeft.Position = UDim2.fromOffset(8, 9)
        arrowLeft.Rotation = 45
        arrowLeft.BackgroundColor3 = Theme.SubText
        arrowLeft.BorderSizePixel = 0
        arrowLeft.ZIndex = Layer.Content + 2
        arrowLeft.Parent = arrow
        corner(arrowLeft, 1)

        local arrowRight = Instance.new("Frame")
        arrowRight.Size = UDim2.fromOffset(8, 2)
        arrowRight.AnchorPoint = Vector2.new(0, 0.5)
        arrowRight.Position = UDim2.fromOffset(8, 9)
        arrowRight.Rotation = -45
        arrowRight.BackgroundColor3 = Theme.SubText
        arrowRight.BorderSizePixel = 0
        arrowRight.ZIndex = Layer.Content + 2
        arrowRight.Parent = arrow
        corner(arrowRight, 1)

        local trigger = Instance.new("TextButton")
        trigger.Size = UDim2.new(1, 0, 1, 0)
        trigger.BackgroundTransparency = 1
        trigger.Text = ""
        trigger.ZIndex = Layer.Content
        trigger.Parent = f

        local popup = Instance.new("ScrollingFrame")
        popup.Name = "DropdownOverlay"
        popup.Visible = false
        -- Multi-select popups float above the tab page. Without Active the
        -- ScrollingFrame does not sink pointer input, so the control sitting
        -- underneath keeps receiving MouseEnter and lights up behind the rows.
        popup.Active = true
        popup.BackgroundColor3 = Theme.Element
        popup.BorderSizePixel = 0
        popup.ScrollBarThickness = 4
        popup.ScrollBarImageColor3 = Theme.SubText
        popup.ScrollBarImageTransparency = 0.45
        popup.CanvasSize = UDim2.new(0, 0, 0, 0)
        popup.AutomaticCanvasSize = Enum.AutomaticSize.Y
        popup.ZIndex = Layer.Popup
        popup.Parent = win.Overlay or win.Main
        corner(popup, Radius.Card)
        local popupStroke = stroke(popup, Theme.Stroke, 1)
        popupStroke.Transparency = 0.15
        padding(popup, 6)
        local popupLayout = Instance.new("UIListLayout")
        popupLayout.Padding = UDim.new(0, 4)
        popupLayout.SortOrder = Enum.SortOrder.LayoutOrder
        popupLayout.Parent = popup
        table.insert(tab._popups, popup)

        local function updateText()
            selectedValues = selectedList()
            local count = #selectedValues
            -- A single value reads best as its own name; two or more collapse
            -- into a counter instead of a comma list that gets truncated
            -- mid-word inside the narrow field.
            if count == 0 then
                selected.Text = cfg.StartingText or "Select..."
                selected.TextColor3 = Theme.SubText
            elseif count == 1 then
                selected.Text = selectedValues[1]
                selected.TextColor3 = Theme.Text
            else
                selected.Text = count .. " selected"
                selected.TextColor3 = Theme.Text
            end
        end
        local popupFlipped = false
        local function positionPopup(reanchor)
            if not open or not alive(popup) or not alive(f) then return end
            -- Absolute pixel deltas must be converted into the pre-UIScale
            -- local space of Main, otherwise popups drift on scaled windows.
            -- The popup lives in the window overlay, so it has to be moved on
            -- every scroll to stay glued under the field that opened it.
            local scale = windowScale()
            local main = win.Main
            local fieldX = (f.AbsolutePosition.X - main.AbsolutePosition.X) / scale
            local fieldY = (f.AbsolutePosition.Y - main.AbsolutePosition.Y) / scale
            local fieldHeight = f.AbsoluteSize.Y / scale
            local mainWidth = main.AbsoluteSize.X / scale
            local mainHeight = main.AbsoluteSize.Y / scale
            local popupWidth = popup.Size.X.Offset
            local popupHeight = popup.Size.Y.Offset
            -- The below/above decision is taken once, when the list opens, so
            -- the popup never jumps to the other side of the field mid-scroll.
            if reanchor then
                local fitsBelow = (fieldY + fieldHeight + 8 + popupHeight) <= (mainHeight - 8)
                local fitsAbove = (fieldY - popupHeight - 8) >= 8
                popupFlipped = (not fitsBelow) and fitsAbove
            end
            local x = math.clamp(fieldX, 8, math.max(8, mainWidth - popupWidth - 8))
            local y
            if popupFlipped then
                y = fieldY - popupHeight - 8
            else
                y = fieldY + fieldHeight + 8
            end
            popup.Position = UDim2.fromOffset(x, y)
            -- Hide the list as soon as its field is scrolled out of the page.
            if page and alive(page) then
                local pageTop = (page.AbsolutePosition.Y - main.AbsolutePosition.Y) / scale
                local pageBottom = pageTop + page.AbsoluteSize.Y / scale
                popup.Visible = ((fieldY + fieldHeight) > pageTop) and (fieldY < pageBottom)
            end
        end
        table.insert(tab._popupRefreshers, positionPopup)
        if alive(f) then
            f:GetPropertyChangedSignal("AbsolutePosition"):Connect(function() positionPopup() end)
        end

        local function close()
            open = false
            if alive(popup) then popup.Visible = false end
            if alive(arrow) then tween(arrow, Motion.Base, { Rotation = 0 }) end
            if alive(arrowLeft) then tween(arrowLeft, Motion.Base, { BackgroundColor3 = Theme.SubText }) end
            if alive(arrowRight) then tween(arrowRight, Motion.Base, { BackgroundColor3 = Theme.SubText }) end
            setDropdownScrollReserve(0)
        end
        table.insert(tab._popupClosers, close)
        local rebuild
        -- Every row registers its own repaint here, so a palette switch
        -- recolours checked and unchecked rows immediately instead of waiting
        -- for the pointer to hover them again.
        local rowPainters = {}
        rebuild = function()
            for _, child in ipairs(popup:GetChildren()) do
                if child:IsA("TextButton") or child.Name == "EmptyState" then child:Destroy() end
            end
            rowPainters = {}
            if #items == 0 then
                local empty = Instance.new("TextLabel")
                empty.Name = "EmptyState"
                empty.Size = UDim2.new(1, 0, 0, 34)
                empty.BackgroundTransparency = 1
                empty.Text = cfg.EmptyText or "No options available"
                empty.TextColor3 = Theme.SubText
                empty.Font = Enum.Font.Gotham
                empty.TextSize = Type.Caption.Size
                empty.TextWrapped = true
                empty.ZIndex = Layer.Popup + 1
                empty.Parent = popup
                bind(empty, "TextColor3", "SubText")
                return
            end
            for _, item in ipairs(items) do
                local itemName = normalize(item)
                local itemButton = Instance.new("TextButton")
                itemButton.Size = UDim2.new(1, 0, 0, 30)
                itemButton.BackgroundColor3 = Theme.Background
                itemButton.BorderSizePixel = 0
                itemButton.Text = itemName
                itemButton.TextColor3 = Theme.SubText
                itemButton.Font = Enum.Font.Gotham
                itemButton.TextSize = Type.Label.Size
                itemButton.TextXAlignment = Enum.TextXAlignment.Left
                itemButton.TextTruncate = Enum.TextTruncate.AtEnd
                itemButton.AutoButtonColor = false
                itemButton.ZIndex = Layer.Popup + 1
                itemButton.Parent = popup
                corner(itemButton, Radius.Chip)
                local itemPadding = Instance.new("UIPadding")
                itemPadding.PaddingLeft = UDim.new(0, 36)
                itemPadding.PaddingRight = UDim.new(0, 10)
                itemPadding.Parent = itemButton
                -- A real checkbox instead of a text tick. The box keeps its own
                -- slot in the padding gutter, so the label no longer shifts by
                -- two spaces when a row is toggled, and the tick is drawn from
                -- two rotated bars for the same reason the chevron is: the
                -- glyph is missing in some clients' fonts.
                local box = Instance.new("Frame")
                box.Name = "Check"
                box.AnchorPoint = Vector2.new(0, 0.5)
                box.Position = UDim2.new(0, -26, 0.5, 0)
                box.Size = UDim2.fromOffset(16, 16)
                box.BackgroundColor3 = Theme.Element
                box.BorderSizePixel = 0
                box.ZIndex = Layer.Popup + 2
                box.Parent = itemButton
                corner(box, 5)
                local boxStroke = stroke(box, Theme.Stroke, 1)
                boxStroke.Transparency = 0.2
                local tickShort = Instance.new("Frame")
                tickShort.Name = "TickShort"
                tickShort.AnchorPoint = Vector2.new(0.5, 0.5)
                tickShort.Position = UDim2.new(0.5, -3, 0.5, 2)
                tickShort.Size = UDim2.fromOffset(6, 2)
                tickShort.Rotation = 45
                tickShort.BackgroundColor3 = Theme.Text
                tickShort.BackgroundTransparency = 1
                tickShort.BorderSizePixel = 0
                tickShort.ZIndex = Layer.Popup + 3
                tickShort.Parent = box
                corner(tickShort, 1)
                local tickLong = Instance.new("Frame")
                tickLong.Name = "TickLong"
                tickLong.AnchorPoint = Vector2.new(0.5, 0.5)
                tickLong.Position = UDim2.new(0.5, 1, 0.5, 0)
                tickLong.Size = UDim2.fromOffset(10, 2)
                tickLong.Rotation = -45
                tickLong.BackgroundColor3 = Theme.Text
                tickLong.BackgroundTransparency = 1
                tickLong.BorderSizePixel = 0
                tickLong.ZIndex = Layer.Popup + 3
                tickLong.Parent = box
                corner(tickLong, 1)
                local clickLocked = false
                local hovered = false
                local function paintSelection()
                    local isSelected = selectedLookup[itemName] == true
                    local lit = isSelected or hovered
                    tween(itemButton, Motion.Fast, {
                        BackgroundColor3 = lit and Theme.ElementHover or Theme.Background,
                        TextColor3 = lit and Theme.Text or Theme.SubText,
                    })
                    tween(box, Motion.Fast, { BackgroundColor3 = isSelected and Theme.Accent or Theme.Element })
                    tween(boxStroke, Motion.Fast, { Color = isSelected and Theme.Accent or Theme.Stroke })
                    tween(tickShort, Motion.Fast, { BackgroundTransparency = isSelected and 0 or 1 })
                    tween(tickLong, Motion.Fast, { BackgroundTransparency = isSelected and 0 or 1 })
                end
                paintSelection()
                table.insert(rowPainters, paintSelection)
                itemButton.MouseEnter:Connect(function()
                    hovered = true
                    paintSelection()
                end)
                itemButton.MouseLeave:Connect(function()
                    hovered = false
                    paintSelection()
                end)
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
            closeAllPopups()
            -- Room for eight rows before the list starts scrolling.
            -- An empty list keeps enough room for its placeholder row.
            local wanted = math.max(46, math.min((8 * 34) + 12, (#items * 34) + 12))
            local width = math.max(180, f.AbsoluteSize.X / windowScale())
            -- Downwards is the default direction. The list flips above the
            -- field only when the space below is too small to be usable;
            -- otherwise it is trimmed to the free space and scrolls inside.
            local scale = windowScale()
            local main = win.Main
            local fieldY = (f.AbsolutePosition.Y - main.AbsolutePosition.Y) / scale
            local fieldHeight = f.AbsoluteSize.Y / scale
            local mainHeight = main.AbsoluteSize.Y / scale
            local spaceBelow = mainHeight - 16 - (fieldY + fieldHeight)
            local spaceAbove = fieldY - 16
            popupFlipped = (spaceBelow < math.min(wanted, 92)) and (spaceAbove > spaceBelow)
            local room = popupFlipped and spaceAbove or spaceBelow
            local height = math.max(46, math.min(wanted, math.floor(room)))
            popup.Size = UDim2.fromOffset(width, height)
            open = true
            setDropdownScrollReserve(height + 28)
            positionPopup(false)
            popup.Visible = true
            -- Grow the overlay out of the field instead of snapping it open.
            popup.Size = UDim2.fromOffset(width, 0)
            popup.BackgroundTransparency = 1
            tween(popup, Motion.Base, { Size = UDim2.fromOffset(width, height), BackgroundTransparency = 0 })
            tween(arrow, Motion.Base, { Rotation = 180 })
            tween(arrowLeft, Motion.Base, { BackgroundColor3 = Theme.Accent })
            tween(arrowRight, Motion.Base, { BackgroundColor3 = Theme.Accent })
        end
        trigger.MouseButton1Click:Connect(function()
            if open then close() else show() end
        end)
        trigger.MouseEnter:Connect(function()
            if popupCovering(f) then return end
            tween(f, Motion.Base, { BackgroundColor3 = Theme.ElementHover })
        end)
        trigger.MouseLeave:Connect(function() tween(f, Motion.Base, { BackgroundColor3 = Theme.Element }) end)

        onThemeChanged(function()
            if not alive(f) then return false end
            f.BackgroundColor3 = Theme.Element
            if fieldBox and alive(fieldBox) then fieldBox.BackgroundColor3 = Theme.Background end
            if alive(popup) then
                popup.BackgroundColor3 = Theme.Element
                popup.ScrollBarImageColor3 = Theme.SubText
            end
            if alive(popupStroke) then popupStroke.Color = Theme.Stroke end
            local arrowColor = open and Theme.Accent or Theme.SubText
            if alive(arrowLeft) then arrowLeft.BackgroundColor3 = arrowColor end
            if alive(arrowRight) then arrowRight.BackgroundColor3 = arrowColor end
            updateText()
            for _, paint in ipairs(rowPainters) do pcall(paint) end
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
        -- A bound key can be long ("RightControl"), and the fixed 78px cap
        -- truncated it mid-name. The width is per-control configurable and
        -- defaults a bit wider; the label reserve follows the same value.
        local keycapWidth = tonumber(cfg.KeycapWidth) or 94

        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, -(keycapWidth + 22), 1, 0)
        label.Position = UDim2.new(0, 14, 0, 0)
        label.BackgroundTransparency = 1
        label.Text = cfg.Name or "Keybind"
        label.TextTruncate = Enum.TextTruncate.AtEnd
        label.TextColor3 = Theme.Text
        label.Font = Enum.Font.GothamMedium
        label.TextSize = Type.Label.Size
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = f

        -- The bound key is drawn as a physical key cap: monospaced glyphs, its
        -- own outline and a soft shadow, so it reads as a key and not as text.
        local kb = Instance.new("TextButton")
        kb.Name = "KeyCap"
        kb.Size = UDim2.fromOffset(keycapWidth, 28)
        kb.Position = UDim2.new(1, -(keycapWidth + 14), 0.5, 0)
        kb.AnchorPoint = Vector2.new(0, 0.5)
        kb.BackgroundColor3 = Theme.Background
        kb.BorderSizePixel = 0
        kb.Text = key and key.Name or "None"
        -- Bound key text stays in the muted palette so the cap reads as part
        -- of the UI instead of a bright white chip; the cap itself and the
        -- key name still tell a bound key from "None".
        kb.TextColor3 = Theme.SubText
        kb.Font = Enum.Font.Code
        kb.TextSize = Type.Label.Size
        kb.TextTruncate = Enum.TextTruncate.AtEnd
        kb.AutoButtonColor = false
        kb.Parent = f
        corner(kb, Radius.Chip)
        local kbStroke = stroke(kb, Theme.Stroke, 1)
        kbStroke.Transparency = 0.25
        dropShadow(kb, 10, 0.88)

        -- While the control waits for a key its outline pulses in the accent
        -- colour, so the capturing state is impossible to miss.
        local pulse = TweenService:Create(
            kbStroke,
            TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
            { Transparency = 0.7 }
        )

        local function paint()
            if binding then
                kb.Text = "Press key"
                kb.TextColor3 = Theme.Accent
                kbStroke.Color = Theme.Accent
                tween(kb, Motion.Fast, { BackgroundColor3 = Theme.ElementHover })
            else
                kb.Text = key and key.Name or "None"
                kb.TextColor3 = Theme.SubText
                kbStroke.Color = Theme.Stroke
                kbStroke.Transparency = 0.25
                tween(kb, Motion.Fast, { BackgroundColor3 = Theme.Background })
            end
        end

        local function setBinding(state)
            binding = state
            if state then
                kbStroke.Transparency = 0
                pulse:Play()
            else
                pulse:Cancel()
            end
            paint()
        end
        paint()

        kb.MouseButton1Click:Connect(function()
            setBinding(not binding)
        end)
        kb.MouseEnter:Connect(function()
            if not binding then tween(kb, Motion.Fast, { BackgroundColor3 = Theme.ElementHover }) end
        end)
        kb.MouseLeave:Connect(function()
            if not binding then tween(kb, Motion.Fast, { BackgroundColor3 = Theme.Background }) end
        end)

        UserInputService.InputBegan:Connect(function(input, gpe)
            if not alive(kb) then return end
            if binding and input.UserInputType == Enum.UserInputType.Keyboard then
                -- Escape cancels the capture and keeps the previous bind;
                -- Backspace and Delete clear it.
                if input.KeyCode == Enum.KeyCode.Escape then
                    setBinding(false)
                    return
                end
                if input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete then
                    key = nil
                    setBinding(false)
                    if cfg.OnBind then cfg.OnBind(nil) end
                    return
                end
                key = input.KeyCode
                setBinding(false)
                if cfg.OnBind then cfg.OnBind(key) end
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
            -- Accent ring around the avatar, gradient-filled like every other
            -- accent surface in the library.
            local avRing = stroke(av, Theme.Accent, 2)
            gradient(avRing, Theme.Accent, Theme.AccentViolet, 45)
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
        nameLbl.TextSize = Type.Label.Size
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
        roleLbl.TextSize = Type.Body.Size
        roleLbl.TextXAlignment = Enum.TextXAlignment.Left
        roleLbl.TextTruncate = Enum.TextTruncate.AtEnd
        roleLbl.Parent = f

        if hasDiscord then
            local btn = Instance.new("TextButton")
            btn.Name = "DiscordButton"
            btn.Size = UDim2.fromOffset(96, 32)
            btn.Position = UDim2.new(1, -108, 0.5, 0)
            btn.AnchorPoint = Vector2.new(0, 0.5)
            btn.BackgroundColor3 = Theme.Discord
            btn.BorderSizePixel = 0
            btn.Text = "Discord"
            btn.TextColor3 = Theme.Text
            btn.Font = Enum.Font.GothamMedium
            btn.TextSize = Type.Label.Size
            btn.AutoButtonColor = false
            btn.Parent = f
            corner(btn, Radius.Control)
            local btnStroke = stroke(btn, Theme.Discord, 1)
            btnStroke.Transparency = 0.4
            dropShadow(btn, 12, 0.86)

            -- Same hover and press language as every other button.
            local discordHover = Theme.Discord:Lerp(Color3.new(1, 1, 1), 0.12)
            local discordPress = Theme.Discord:Lerp(Color3.new(0, 0, 0), 0.16)
            btn.MouseEnter:Connect(function()
                tween(btn, Motion.Fast, { BackgroundColor3 = discordHover })
                tween(btnStroke, Motion.Fast, { Transparency = 0.1 })
            end)
            btn.MouseLeave:Connect(function()
                tween(btn, Motion.Base, { BackgroundColor3 = Theme.Discord })
                tween(btnStroke, Motion.Base, { Transparency = 0.4 })
            end)
            pressFeedback(btn, btn, discordPress, Theme.Discord)
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
    function tab:Section(text, cfg)
        -- A section is a labelled rule now: accent tick, compact label, and a
        -- hairline that fades out across the remaining width.
        local host = tab._target or page
        local row = Instance.new("Frame")
        row.Name = "SectionHeader"
        row.Size = host == page
            and UDim2.new(0.8, 0, 0, 26)
            or UDim2.new(1, 0, 0, 26)
        row.BackgroundTransparency = 1
        row.Parent = host

        -- Status lines reuse Section, and those texts are often multi-line, so
        -- the row has to grow with its label instead of letting the text spill
        -- over the neighbouring controls.
        row.AutomaticSize = Enum.AutomaticSize.Y

        local rowPad = Instance.new("UIPadding")
        rowPad.PaddingBottom = UDim.new(0, 4)
        rowPad.Parent = row

        local rowMin = Instance.new("UISizeConstraint")
        rowMin.MinSize = Vector2.new(0, 26)
        rowMin.Parent = row

        local mark = Instance.new("Frame")
        mark.Name = "Mark"
        mark.AnchorPoint = Vector2.new(0, 0.5)
        mark.Position = UDim2.new(0, 0, 0.5, 0)
        mark.Size = UDim2.fromOffset(3, 12)
        mark.BackgroundColor3 = Color3.new(1, 1, 1)
        mark.BorderSizePixel = 0
        mark.Parent = row
        corner(mark, 2)
        gradient(mark, Theme.Accent, Theme.AccentViolet, 90)

        local l = Instance.new("TextLabel")
        l.Name = "SectionLabel"
        l.AutomaticSize = Enum.AutomaticSize.X
        l.Size = UDim2.new(0, 0, 0, 18)
        l.Position = UDim2.new(0, 11, 0, 4)
        l.BackgroundTransparency = 1
        l.Text = tostring(text or "Section")
        l.TextColor3 = Theme.SubText
        l.Font = Enum.Font.GothamBold
        l.TextSize = Type.Body.Size
        l.TextXAlignment = Enum.TextXAlignment.Left
        l.TextYAlignment = Enum.TextYAlignment.Top
        l.TextTruncate = Enum.TextTruncate.None
        l.Parent = row
        bind(l, "TextColor3", "SubText")

        -- AutomaticSize.X on its own lets a long section title grow straight
        -- past the window edge, so the label width is capped to the row.
        local labelClamp = Instance.new("UISizeConstraint")
        labelClamp.MaxSize = Vector2.new(math.huge, math.huge)
        labelClamp.Parent = l

        local rule = Instance.new("Frame")
        rule.Name = "Rule"
        rule.AnchorPoint = Vector2.new(1, 0.5)
        rule.Position = UDim2.new(1, 0, 0.5, 0)
        rule.Size = UDim2.new(0, 0, 0, 1)
        rule.BackgroundColor3 = Theme.Stroke
        rule.BorderSizePixel = 0
        rule.Parent = row
        bind(rule, "BackgroundColor3", "Stroke")
        gradient(rule, Color3.new(1, 1, 1), Color3.new(1, 1, 1), 0, 0.2, 1)

        -- Two looks share one API: a compact header (tick + rule) for short
        -- single-line titles, and a wrapped block for long or multi-line status
        -- text, where nothing is ever cut off.
        local textService = game:GetService("TextService")
        local wrapped = nil

        local function naturalWidth()
            local ok, size = pcall(function()
                return textService:GetTextSize(l.Text, l.TextSize, l.Font, Vector2.new(100000, 100000))
            end)
            if ok and size then return size.X end
            return #l.Text * (l.TextSize * 0.55)
        end

        local function setWrapped(state)
            if wrapped == state then return end
            wrapped = state
            if state then
                l.AutomaticSize = Enum.AutomaticSize.Y
                l.TextWrapped = true
                l.Size = UDim2.new(1, -15, 0, 0)
                labelClamp.MaxSize = Vector2.new(math.huge, math.huge)
                mark.AnchorPoint = Vector2.new(0, 0)
                mark.Position = UDim2.new(0, 0, 0, 5)
                mark.Size = UDim2.new(0, 3, 1, -14)
                rule.Visible = false
            else
                l.AutomaticSize = Enum.AutomaticSize.X
                l.TextWrapped = false
                l.Size = UDim2.new(0, 0, 0, 18)
                mark.AnchorPoint = Vector2.new(0, 0.5)
                mark.Position = UDim2.new(0, 0, 0.5, 0)
                mark.Size = UDim2.fromOffset(3, 12)
            end
        end

        -- Absolute sizes are post-UIScale, so convert back into local space
        -- before sizing the rule or it drifts on scaled (mobile) windows.
        local function syncRule()
            if not alive(rule) or not alive(l) or not alive(row) then return end
            local scale = math.max(windowScale(), 0.01)
            local rowWidth = row.AbsoluteSize.X / scale
            local maxLabel = math.max(rowWidth - 23, 40)
            local multiline = string.find(l.Text, "\n", 1, true) ~= nil
            setWrapped(multiline or (rowWidth > 0 and naturalWidth() > maxLabel))
            if wrapped then
                rule.Visible = false
                return
            end
            if rowWidth > 0 and math.abs(labelClamp.MaxSize.X - maxLabel) > 0.5 then
                labelClamp.MaxSize = Vector2.new(maxLabel, math.huge)
            end
            local remaining = rowWidth - (l.AbsoluteSize.X / scale) - 23
            rule.Visible = remaining > 12
            rule.Size = UDim2.new(0, math.max(remaining, 0), 0, 1)
        end
        -- Section returns the label, but the list layout sorts the ROW, so a
        -- caller doing `status.LayoutOrder = 1000` to pin a status line to the
        -- bottom of its group had no effect at all. The row now follows the
        -- label's order, and `Section(text, { Bottom = true })` does it for you.
        if type(cfg) == "table" then
            if tonumber(cfg.LayoutOrder) then
                l.LayoutOrder = tonumber(cfg.LayoutOrder)
            elseif cfg.Bottom then
                l.LayoutOrder = 1000000
            end
        end
        row.LayoutOrder = l.LayoutOrder
        l:GetPropertyChangedSignal("LayoutOrder"):Connect(function()
            if alive(row) then row.LayoutOrder = l.LayoutOrder end
        end)

        setWrapped(false)
        l:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncRule)
        l:GetPropertyChangedSignal("Text"):Connect(syncRule)
        row:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncRule)
        syncRule()

        return l
    end

    return tab
end

return Library
