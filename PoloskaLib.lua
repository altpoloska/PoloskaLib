type Palette__DARKLUA_TYPE_a = {Background: Color3, Surface: Color3, Sidebar: Color3, Card: Color3, Element: Color3, ElementHover: Color3, ElementActive: Color3, Stroke: Color3, StrokeBright: Color3, Accent: Color3, AccentSecondary: Color3, AccentSoft: Color3, OnAccent: Color3, Text: Color3, SubText: Color3, MutedText: Color3, Overlay: Color3, Success: Color3, Warning: Color3, Danger: Color3}

local __POLOSKALIB_MODULES = {
    cache = {}::any,
}

do
    do
        local function __modImpl()
            local Tokens = {}

            Tokens.Version = '2.0.0'
            Tokens.Radius = {
                Window = 14,
                Card = 10,
                Control = 8,
                Chip = 6,
                Pill = 999,
            }
            Tokens.Motion = {
                Fast = 0.12,
                Base = 0.2,
                Slow = 0.34,
                Spring = 0.26,
                SmoothStyle = Enum.EasingStyle.Quint,
                SmoothDir = Enum.EasingDirection.InOut,
            }
            Tokens.Type = {
                Title = {
                    Size = 15,
                    Font = Enum.Font.GothamBold,
                },
                Heading = {
                    Size = 13,
                    Font = Enum.Font.GothamBold,
                },
                Label = {
                    Size = 13,
                    Font = Enum.Font.GothamMedium,
                },
                Body = {
                    Size = 12,
                    Font = Enum.Font.Gotham,
                },
                Caption = {
                    Size = 11,
                    Font = Enum.Font.GothamMedium,
                },
                Mono = {
                    Size = 12,
                    Font = Enum.Font.RobotoMono,
                },
            }
            Tokens.Layer = {
                Backdrop = 0,
                Content = 2,
                Chrome = 20,
                Launcher = 50,
                Popup = 200,
                Notification = 300,
                Dialog = 400,
            }
            Tokens.DefaultIcons = {
                Minimize = 'rbxassetid://10734896206',
                Close = 'rbxassetid://10747384394',
                Restore = 'rbxassetid://10734886735',
                Launcher = 'rbxassetid://76774068789424',
            }

            function Tokens.Typeset(
                label: any,
                role: string,
                color: Color3?
            ): any
                local spec = (Tokens.Type::any)[role] or Tokens.Type.Label

                label.Font = spec.Font
                label.TextSize = spec.Size

                if color then
                    label.TextColor3 = color
                end

                return label
            end

            return Tokens
        end

        function __POLOSKALIB_MODULES.a(): typeof(__modImpl())
            local v = __POLOSKALIB_MODULES.cache.a

            if not v then
                v = {
                    c = __modImpl(),
                }
                __POLOSKALIB_MODULES.cache.a = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Theme = {}

            Theme.__index = Theme
            Theme.PresetOrder = {
                'Poloska',
                'Obsidian',
                'Standout Crimson',
                'Midnight Violet',
                'Classic Dark',
                'Light',
            }
            Theme.Presets = {
                Poloska = {
                    Background = Color3.fromRGB(9, 14, 26),
                    Surface = Color3.fromRGB(13, 21, 37),
                    Sidebar = Color3.fromRGB(11, 18, 32),
                    Card = Color3.fromRGB(15, 25, 44),
                    Element = Color3.fromRGB(20, 34, 58),
                    ElementHover = Color3.fromRGB(27, 45, 76),
                    ElementActive = Color3.fromRGB(33, 55, 92),
                    Stroke = Color3.fromRGB(36, 58, 90),
                    StrokeBright = Color3.fromRGB(64, 102, 148),
                    Accent = Color3.fromRGB(36, 206, 232),
                    AccentSecondary = Color3.fromRGB(124, 82, 255),
                    AccentSoft = Color3.fromRGB(19, 54, 78),
                    OnAccent = Color3.fromRGB(7, 16, 26),
                    Text = Color3.fromRGB(242, 247, 255),
                    SubText = Color3.fromRGB(150, 170, 200),
                    MutedText = Color3.fromRGB(124, 146, 178),
                    Overlay = Color3.fromRGB(3, 6, 14),
                    Success = Color3.fromRGB(48, 210, 144),
                    Warning = Color3.fromRGB(244, 184, 68),
                    Danger = Color3.fromRGB(238, 78, 102),
                },
                Obsidian = {
                    Background = Color3.fromRGB(11, 12, 16),
                    Surface = Color3.fromRGB(16, 18, 24),
                    Sidebar = Color3.fromRGB(13, 15, 20),
                    Card = Color3.fromRGB(19, 22, 29),
                    Element = Color3.fromRGB(26, 30, 40),
                    ElementHover = Color3.fromRGB(34, 39, 52),
                    ElementActive = Color3.fromRGB(42, 48, 64),
                    Stroke = Color3.fromRGB(44, 50, 66),
                    StrokeBright = Color3.fromRGB(74, 86, 112),
                    Accent = Color3.fromRGB(56, 218, 198),
                    AccentSecondary = Color3.fromRGB(82, 146, 255),
                    AccentSoft = Color3.fromRGB(22, 54, 56),
                    OnAccent = Color3.fromRGB(9, 14, 16),
                    Text = Color3.fromRGB(240, 243, 249),
                    SubText = Color3.fromRGB(152, 161, 179),
                    MutedText = Color3.fromRGB(130, 140, 160),
                    Overlay = Color3.fromRGB(4, 5, 8),
                    Success = Color3.fromRGB(54, 212, 142),
                    Warning = Color3.fromRGB(245, 188, 72),
                    Danger = Color3.fromRGB(236, 82, 98),
                },
                ['Standout Crimson'] = {
                    Background = Color3.fromRGB(14, 11, 16),
                    Surface = Color3.fromRGB(20, 15, 22),
                    Sidebar = Color3.fromRGB(16, 12, 19),
                    Card = Color3.fromRGB(25, 18, 28),
                    Element = Color3.fromRGB(34, 24, 38),
                    ElementHover = Color3.fromRGB(46, 32, 51),
                    ElementActive = Color3.fromRGB(58, 39, 64),
                    Stroke = Color3.fromRGB(64, 42, 68),
                    StrokeBright = Color3.fromRGB(116, 68, 108),
                    Accent = Color3.fromRGB(218, 48, 96),
                    AccentSecondary = Color3.fromRGB(244, 178, 74),
                    AccentSoft = Color3.fromRGB(68, 24, 42),
                    OnAccent = Color3.fromRGB(255, 255, 255),
                    Text = Color3.fromRGB(250, 243, 247),
                    SubText = Color3.fromRGB(184, 156, 172),
                    MutedText = Color3.fromRGB(156, 130, 146),
                    Overlay = Color3.fromRGB(6, 3, 8),
                    Success = Color3.fromRGB(62, 206, 140),
                    Warning = Color3.fromRGB(246, 186, 72),
                    Danger = Color3.fromRGB(244, 72, 94),
                },
                ['Midnight Violet'] = {
                    Background = Color3.fromRGB(12, 11, 24),
                    Surface = Color3.fromRGB(17, 16, 34),
                    Sidebar = Color3.fromRGB(14, 13, 28),
                    Card = Color3.fromRGB(22, 20, 42),
                    Element = Color3.fromRGB(30, 27, 56),
                    ElementHover = Color3.fromRGB(39, 36, 72),
                    ElementActive = Color3.fromRGB(48, 44, 88),
                    Stroke = Color3.fromRGB(56, 52, 96),
                    StrokeBright = Color3.fromRGB(98, 90, 158),
                    Accent = Color3.fromRGB(154, 112, 255),
                    AccentSecondary = Color3.fromRGB(224, 102, 236),
                    AccentSoft = Color3.fromRGB(46, 34, 84),
                    OnAccent = Color3.fromRGB(16, 12, 32),
                    Text = Color3.fromRGB(244, 242, 255),
                    SubText = Color3.fromRGB(166, 162, 202),
                    MutedText = Color3.fromRGB(140, 136, 180),
                    Overlay = Color3.fromRGB(5, 4, 12),
                    Success = Color3.fromRGB(62, 212, 150),
                    Warning = Color3.fromRGB(244, 188, 76),
                    Danger = Color3.fromRGB(238, 82, 110),
                },
                ['Classic Dark'] = {
                    Background = Color3.fromRGB(17, 17, 20),
                    Surface = Color3.fromRGB(22, 22, 26),
                    Sidebar = Color3.fromRGB(20, 20, 24),
                    Card = Color3.fromRGB(26, 26, 31),
                    Element = Color3.fromRGB(33, 33, 39),
                    ElementHover = Color3.fromRGB(42, 42, 50),
                    ElementActive = Color3.fromRGB(50, 50, 60),
                    Stroke = Color3.fromRGB(52, 52, 62),
                    StrokeBright = Color3.fromRGB(82, 84, 104),
                    Accent = Color3.fromRGB(96, 112, 242),
                    AccentSecondary = Color3.fromRGB(156, 108, 255),
                    AccentSoft = Color3.fromRGB(42, 46, 86),
                    OnAccent = Color3.fromRGB(255, 255, 255),
                    Text = Color3.fromRGB(238, 238, 244),
                    SubText = Color3.fromRGB(150, 150, 164),
                    MutedText = Color3.fromRGB(136, 136, 154),
                    Overlay = Color3.fromRGB(6, 6, 8),
                    Success = Color3.fromRGB(70, 198, 134),
                    Warning = Color3.fromRGB(230, 176, 72),
                    Danger = Color3.fromRGB(216, 68, 76),
                },
                Light = {
                    Background = Color3.fromRGB(240, 244, 250),
                    Surface = Color3.fromRGB(232, 238, 247),
                    Sidebar = Color3.fromRGB(230, 236, 246),
                    Card = Color3.fromRGB(255, 255, 255),
                    Element = Color3.fromRGB(241, 245, 251),
                    ElementHover = Color3.fromRGB(214, 225, 242),
                    ElementActive = Color3.fromRGB(214, 226, 244),
                    Stroke = Color3.fromRGB(186, 200, 220),
                    StrokeBright = Color3.fromRGB(132, 158, 192),
                    Accent = Color3.fromRGB(0, 122, 166),
                    AccentSecondary = Color3.fromRGB(104, 72, 218),
                    AccentSoft = Color3.fromRGB(206, 232, 244),
                    OnAccent = Color3.fromRGB(255, 255, 255),
                    Text = Color3.fromRGB(20, 30, 46),
                    SubText = Color3.fromRGB(78, 96, 122),
                    MutedText = Color3.fromRGB(86, 102, 126),
                    Overlay = Color3.fromRGB(18, 26, 40),
                    Success = Color3.fromRGB(18, 154, 102),
                    Warning = Color3.fromRGB(184, 124, 18),
                    Danger = Color3.fromRGB(202, 52, 76),
                },
            }::{[string]: Palette__DARKLUA_TYPE_a}

            function Theme.new(initialName: string?)
                local name = (initialName and Theme.Presets[initialName]) and initialName or 'Poloska'
                local colors = {}::any

                for k, v in pairs(Theme.Presets[name]::any)do
                    colors[k] = v
                end

                return setmetatable({
                    Name = name,
                    Colors = colors::Palette__DARKLUA_TYPE_a,
                    _bindings = setmetatable({}, {
                        __mode = 'k',
                    })::{[Instance]: {[string]: string}},
                    _gradients = setmetatable({}, {
                        __mode = 'k',
                    })::{[UIGradient]: {a: string, b: string}},
                    _hooks = {}::{() -> boolean?},
                }, Theme)
            end
            function Theme:Get(key: string): Color3
                return (self.Colors::any)[key] or self.Colors.Text
            end
            function Theme:Bind(
                obj: Instance,
                property: string,
                key: string
            ): Instance
                local color = (self.Colors::any)[key]

                if color then
                    pcall(function()
                        (obj::any)[property] = color
                    end)
                end

                local map = self._bindings[obj]

                if not map then
                    map = {}
                    self._bindings[obj] = map
                end

                map[property] = key

                return obj
            end
            function Theme:BindGradient(
                grad: UIGradient,
                keyA: string,
                keyB: string
            ): UIGradient
                grad.Color = ColorSequence.new(self:Get(keyA), self:Get(keyB))
                self._gradients[grad] = {
                    a = keyA,
                    b = keyB,
                }

                return grad
            end
            function Theme:OnChange(fn: () -> boolean?)
                table.insert(self._hooks, fn)

                return fn
            end
            function Theme:Set(name: string): (boolean,string?)
                local preset = Theme.Presets[name]

                if not preset then
                    return false, 'Unknown theme: ' .. tostring(name)
                end

                self.Name = name

                for k, v in pairs(preset::any)do
                    (self.Colors::any)[k] = v
                end
                for obj, map in pairs(self._bindings)do
                    if obj.Parent ~= nil then
                        for prop, key in pairs(map)do
                            local c = (self.Colors::any)[key]

                            if c then
                                pcall(function()
                                    (obj::any)[prop] = c
                                end)
                            end
                        end
                    else
                        self._bindings[obj] = nil
                    end
                end
                for grad, pair in pairs(self._gradients)do
                    if grad.Parent ~= nil then
                        grad.Color = ColorSequence.new(self:Get(pair.a), self:Get(pair.b))
                    else
                        self._gradients[grad] = nil
                    end
                end

                for i = #self._hooks, 1, -1 do
                    local ok, keep = pcall(self._hooks[i])

                    if not ok or keep == false then
                        table.remove(self._hooks, i)
                    end
                end

                return true, nil
            end
            function Theme:Names(): {string}
                local out = {}

                for _, n in ipairs(Theme.PresetOrder)do
                    table.insert(out, n)
                end

                return out
            end
            function Theme:Destroy()
                table.clear(self._hooks)
            end

            return Theme
        end

        function __POLOSKALIB_MODULES.b(): typeof(__modImpl())
            local v = __POLOSKALIB_MODULES.cache.b

            if not v then
                v = {
                    c = __modImpl(),
                }
                __POLOSKALIB_MODULES.cache.b = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Maid = {}

            Maid.__index = Maid

            function Maid.new()
                return setmetatable({
                    _tasks = {}::{any},
                    _cleaned = false,
                }, Maid)
            end
            function Maid:Add(taskItem: any): any
                if self._cleaned then
                    pcall(function()
                        if typeof(taskItem) == 'RBXScriptConnection' then
                            taskItem:Disconnect()
                        elseif typeof(taskItem) == 'function' then
                            taskItem()
                        elseif typeof(taskItem) == 'Instance' then
                            taskItem:Destroy()
                        elseif typeof(taskItem) == 'table' and typeof(taskItem.Disconnect) == 'function' then
                            taskItem:Disconnect()
                        end
                    end)

                    return taskItem
                end

                table.insert(self._tasks, taskItem)

                return taskItem
            end
            function Maid:Connect(signal: any, fn: (...any) -> ()): RBXScriptConnection
                local conn = signal:Connect(fn)

                return self:Add(conn)
            end
            function Maid:Clean()
                if self._cleaned then
                    return
                end

                self._cleaned = true

                local tasks = self._tasks

                self._tasks = {}

                for i = #tasks, 1, -1 do
                    local item = tasks[i]

                    pcall(function()
                        if typeof(item) == 'RBXScriptConnection' then
                            item:Disconnect()
                        elseif typeof(item) == 'function' then
                            item()
                        elseif typeof(item) == 'Instance' then
                            item:Destroy()
                        elseif typeof(item) == 'table' then
                            if typeof(item.Disconnect) == 'function' then
                                item:Disconnect()
                            elseif typeof(item.Destroy) == 'function' then
                                item:Destroy()
                            end
                        end
                    end)
                end
            end

            return Maid
        end

        function __POLOSKALIB_MODULES.c(): typeof(__modImpl())
            local v = __POLOSKALIB_MODULES.cache.c

            if not v then
                v = {
                    c = __modImpl(),
                }
                __POLOSKALIB_MODULES.cache.c = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local TweenService = game:GetService('TweenService')
            local Animator = {}
            local infoCache: {[string]: TweenInfo} = {}
            local infoCacheCount = 0

            function Animator.Alive(obj: any): boolean
                return typeof(obj) == 'Instance' and (obj.Parent ~= nil or obj:IsDescendantOf(game))
            end
            function Animator.Info(
                duration: number,
                style: Enum.EasingStyle?,
                dir: Enum.EasingDirection?
            ): TweenInfo
                local s = style or Enum.EasingStyle.Quart
                local d = dir or Enum.EasingDirection.Out
                local key = string.format('%.3f|%s|%s', duration, tostring(s), tostring(d))
                local cached = infoCache[key]

                if not cached then
                    cached = TweenInfo.new(duration, s, d)

                    if infoCacheCount < 64 then
                        infoCache[key] = cached

                        infoCacheCount += 1
                    end
                end

                return cached
            end
            function Animator.Tween(
                obj: any,
                duration: number,
                props: {[string]: any},
                style: Enum.EasingStyle?,
                dir: Enum.EasingDirection?
            ): Tween?
                if not Animator.Alive(obj) then
                    return nil
                end

                local ok, t = pcall(TweenService.Create, TweenService, obj, Animator.Info(duration, style, dir), props)

                if ok and t then
                    t:Play()

                    return t
                end

                return nil
            end

            return Animator
        end

        function __POLOSKALIB_MODULES.d(): typeof(__modImpl())
            local v = __POLOSKALIB_MODULES.cache.d

            if not v then
                v = {
                    c = __modImpl(),
                }
                __POLOSKALIB_MODULES.cache.d = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local GuiService = game:GetService('GuiService')
            local UserInputService = game:GetService('UserInputService')
            local Animator = __POLOSKALIB_MODULES.d()
            local Primitives = {}

            local function lookupGlobal(name: string): any
                local okGenv, genv = pcall(function()
                    local fn = (getfenv(0)::any).getgenv

                    if typeof(fn) == 'function' then
                        return fn()
                    end

                    return nil
                end)

                if okGenv and typeof(genv) == 'table' and genv[name] ~= nil then
                    return genv[name]
                end

                local okEnv, env = pcall(function()
                    return getfenv(0)
                end)

                if okEnv and typeof(env) == 'table' and env[name] ~= nil then
                    return env[name]
                end

                return (_G::any)[name]
            end

            function Primitives.GetTopInset(): number
                local ok, insetY = pcall(function()
                    return GuiService:GetGuiInset().Y
                end)

                if ok and type(insetY) == 'number' then
                    return math.max(0, insetY)
                end

                return 58
            end
            function Primitives.ClampToViewport(
                frame: GuiObject,
                pos: UDim2?,
                sizeOverride: Vector2?
            ): UDim2
                local targetPos = pos or frame.Position
                local cam = workspace.CurrentCamera

                if not cam then
                    return targetPos
                end

                local vp = cam.ViewportSize

                if vp.X <= 0 or vp.Y <= 0 then
                    return targetPos
                end

                local topInset = Primitives.GetTopInset()
                local margin = 8
                local w = sizeOverride and sizeOverride.X or frame.AbsoluteSize.X
                local h = sizeOverride and sizeOverride.Y or frame.AbsoluteSize.Y
                local ax = frame.AnchorPoint.X
                local ay = frame.AnchorPoint.Y
                local anchorX = vp.X * targetPos.X.Scale + targetPos.X.Offset
                local anchorY = vp.Y * targetPos.Y.Scale + targetPos.Y.Offset
                local minX = margin + w * ax
                local maxX = math.max(minX, vp.X - margin - w * (1 - ax))
                local minY = topInset + margin + h * ay
                local maxY = math.max(minY, vp.Y - margin - h * (1 - ay))

                anchorX = math.clamp(anchorX, minX, maxX)
                anchorY = math.clamp(anchorY, minY, maxY)

                return UDim2.new(targetPos.X.Scale, anchorX - vp.X * targetPos.X.Scale, targetPos.Y.Scale, anchorY - vp.Y * targetPos.Y.Scale)
            end
            function Primitives.ResolveIcon(icon: any): string
                if not icon then
                    return ''
                end
                if type(icon) == 'number' then
                    return 'rbxassetid://' .. tostring(icon)
                end

                local s = tostring(icon)

                if s:match('^rbxassetid://') or s:match('^rbxthumb://') or s:match('^http') then
                    return s
                end

                local loader = lookupGlobal('getcustomasset') or lookupGlobal('getsynasset')

                if typeof(loader) == 'function' then
                    local ok, res = pcall(loader, s)

                    if ok and typeof(res) == 'string' then
                        return res
                    end
                end

                return s
            end
            function Primitives.Corner(parent: Instance, radius: number?): UICorner
                local c = Instance.new('UICorner')

                c.CornerRadius = UDim.new(0, radius or 8)
                c.Parent = parent

                return c
            end
            function Primitives.Stroke(
                parent: Instance,
                color: Color3,
                thickness: number?,
                transparency: number?
            ): UIStroke
                local s = Instance.new('UIStroke')

                s.Color = color
                s.Thickness = thickness or 1
                s.Transparency = transparency or 0
                s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                s.Parent = parent

                return s
            end
            function Primitives.Padding(
                parent: Instance,
                top: number,
                right: number?,
                bottom: number?,
                left: number?
            ): UIPadding
                local p = Instance.new('UIPadding')

                p.PaddingTop = UDim.new(0, top)
                p.PaddingRight = UDim.new(0, right or top)
                p.PaddingBottom = UDim.new(0, bottom or top)
                p.PaddingLeft = UDim.new(0, left or right or top)
                p.Parent = parent

                return p
            end
            function Primitives.Gradient(
                parent: Instance,
                colorA: Color3,
                colorB: Color3,
                rotation: number?,
                transA: number?,
                transB: number?
            ): UIGradient
                local g = Instance.new('UIGradient')

                g.Color = ColorSequence.new(colorA, colorB)
                g.Rotation = rotation or 0

                if transA ~= nil or transB ~= nil then
                    g.Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0, transA or 0),
                        NumberSequenceKeypoint.new(1, transB or 0),
                    })
                end

                g.Parent = parent

                return g
            end
            function Primitives.RimHighlight(
                parent: GuiObject,
                theme: any,
                zIndex: number?
            ): Frame
                local rim = Instance.new('Frame')

                rim.Name = 'RimHighlight'
                rim.Size = UDim2.new(1, -16, 0, 1)
                rim.Position = UDim2.new(0, 8, 0, 0)
                rim.BackgroundColor3 = Color3.new(1, 1, 1)
                rim.BackgroundTransparency = 0.72
                rim.BorderSizePixel = 0
                rim.ZIndex = zIndex or (parent.ZIndex + 1)
                rim.Parent = parent

                local g = Instance.new('UIGradient')

                g.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.25, 0.35),
                    NumberSequenceKeypoint.new(0.5, 0),
                    NumberSequenceKeypoint.new(0.75, 0.35),
                    NumberSequenceKeypoint.new(1, 1),
                })
                g.Parent = rim

                theme:Bind(rim, 'BackgroundColor3', 'StrokeBright')

                return rim
            end
            function Primitives.DropShadow(
                target: GuiObject,
                spread: number?,
                transparency: number?,
                maid: any?
            ): Frame?
                local parent = target.Parent

                if not parent then
                    return nil
                end

                local pad = spread or 24
                local alpha = transparency or 0.62
                local shadow = Instance.new('Frame')

                shadow.Name = target.Name .. 'Shadow'
                shadow.BackgroundTransparency = 1
                shadow.BorderSizePixel = 0
                shadow.ZIndex = math.max(0, target.ZIndex - 1)
                shadow.Parent = parent

                local cornerObj = target:FindFirstChildOfClass('UICorner')
                local baseRadius = cornerObj and cornerObj.CornerRadius.Offset or 12
                local steps = 3

                for i = 1, steps do
                    local grow = math.floor(pad * (i / steps))
                    local layer = Instance.new('Frame')

                    layer.Name = 'Layer' .. i
                    layer.AnchorPoint = Vector2.new(0.5, 0.5)
                    layer.Position = UDim2.fromScale(0.5, 0.5)
                    layer.Size = UDim2.new(1, -(pad - grow) * 2, 1, -(pad - grow) * 2)
                    layer.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    layer.BackgroundTransparency = alpha + (1 - alpha) * ((i - 1) / steps)
                    layer.BorderSizePixel = 0
                    layer.ZIndex = shadow.ZIndex
                    layer.Parent = shadow

                    Primitives.Corner(layer, baseRadius + grow)
                end

                local function sync()
                    if not Animator.Alive(target) or not Animator.Alive(shadow) then
                        return
                    end

                    local anchor = target.AnchorPoint

                    shadow.AnchorPoint = anchor
                    shadow.Size = UDim2.new(target.Size.X.Scale, target.Size.X.Offset + pad * 2, target.Size.Y.Scale, target.Size.Y.Offset + pad * 2)
                    shadow.Position = UDim2.new(target.Position.X.Scale, target.Position.X.Offset + pad * (2 * anchor.X - 1), target.Position.Y.Scale, target.Position.Y.Offset + pad * (2 * anchor.Y - 1))
                    shadow.Visible = target.Visible
                end

                sync()

                local function track(conn: RBXScriptConnection)
                    if maid then
                        maid:Add(conn)
                    end
                end

                track(target:GetPropertyChangedSignal('Size'):Connect(sync))
                track(target:GetPropertyChangedSignal('Position'):Connect(sync))
                track(target:GetPropertyChangedSignal('Visible'):Connect(sync))

                return shadow
            end
            function Primitives.MakeDraggable(
                frame: GuiObject,
                handle: GuiObject,
                maid: any,
                ignoreList: {GuiObject}?
            )
                local state = {
                    Dragging = false,
                    Moved = false,
                    SuppressClick = false,
                }
                local activeInput: InputObject?
                local startPos: Vector3 = Vector3.zero
                local startFramePos: UDim2 = frame.Position
                local threshold = UserInputService.TouchEnabled and 8 or 4

                local function isPointInGui(pt: Vector3, obj: GuiObject): boolean
                    if not Animator.Alive(obj) or not obj.Visible then
                        return false
                    end

                    local p = obj.AbsolutePosition
                    local s = obj.AbsoluteSize

                    return pt.X >= p.X and pt.X <= p.X + s.X and pt.Y >= p.Y and pt.Y <= p.Y + s.Y
                end
                local function isBlockedTarget(pt: Vector3): boolean
                    if UserInputService:GetFocusedTextBox() ~= nil then
                        return true
                    end
                    if ignoreList then
                        for _, obj in ipairs(ignoreList)do
                            if isPointInGui(pt, obj) then
                                return true
                            end
                        end
                    end

                    for _, desc in ipairs(handle:GetDescendants())do
                        if desc:IsA('TextBox') or desc:IsA('GuiButton') then
                            if isPointInGui(pt, desc) then
                                return true
                            end
                        end
                    end

                    return false
                end

                maid:Connect(handle.InputBegan, function(input: InputObject)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if isBlockedTarget(input.Position) then
                            return
                        end

                        activeInput = input
                        state.Dragging = true
                        state.Moved = false
                        startPos = input.Position
                        startFramePos = frame.Position
                    end
                end)
                maid:Connect(UserInputService.InputChanged, function(
                    input: InputObject
                )
                    if not state.Dragging or not Animator.Alive(frame) then
                        return
                    end
                    if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
                        return
                    end
                    if activeInput and activeInput.UserInputType == Enum.UserInputType.Touch and input ~= activeInput then
                        return
                    end

                    local delta = input.Position - startPos

                    if not state.Moved and Vector2.new(delta.X, delta.Y).Magnitude >= threshold then
                        state.Moved = true
                    end
                    if state.Moved then
                        local target = UDim2.new(startFramePos.X.Scale, startFramePos.X.Offset + delta.X, startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y)

                        frame.Position = Primitives.ClampToViewport(frame, target)
                    end
                end)
                maid:Connect(UserInputService.InputEnded, function(
                    input: InputObject
                )
                    if not state.Dragging then
                        return
                    end
                    if input == activeInput or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        if state.Moved then
                            state.SuppressClick = true

                            task.defer(function()
                                state.SuppressClick = false
                            end)
                        end

                        state.Dragging = false
                        state.Moved = false
                        activeInput = nil
                    end
                end)

                function state:ConsumeClick(): boolean
                    if self.SuppressClick then
                        self.SuppressClick = false

                        return true
                    end

                    return false
                end

                return state
            end

            return Primitives
        end

        function __POLOSKALIB_MODULES.e(): typeof(__modImpl())
            local v = __POLOSKALIB_MODULES.cache.e

            if not v then
                v = {
                    c = __modImpl(),
                }
                __POLOSKALIB_MODULES.cache.e = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local UserInputService = game:GetService('UserInputService')
            local Tokens = __POLOSKALIB_MODULES.a()
            local Animator = __POLOSKALIB_MODULES.d()
            local Primitives = __POLOSKALIB_MODULES.e()
            local Overlay = {}
            local TYPE_COLOR_KEY: {[string]: string} = {
                info = 'Accent',
                success = 'Success',
                warn = 'Warning',
                warning = 'Warning',
                error = 'Danger',
                danger = 'Danger',
            }

            function Overlay.AttachNotificationHost(
                gui: ScreenGui,
                theme: any
            )
                local host = Instance.new('Frame')

                host.Name = 'PoloskaNotifications'
                host.AnchorPoint = Vector2.new(1, 1)
                host.Position = UDim2.new(1, -18, 1, -18)
                host.Size = UDim2.new(0, 310, 1, -36)
                host.BackgroundTransparency = 1
                host.BorderSizePixel = 0
                host.ZIndex = Tokens.Layer.Notification
                host.Parent = gui

                local layout = Instance.new('UIListLayout')

                layout.Padding = UDim.new(0, 8)
                layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
                layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Parent = host

                local nextOrder = 0
                local activeToasts: {{Dismiss: () -> ()}} = {}
                local MAX_TOASTS = 4

                return function(cfg: any)
                    if not Animator.Alive(host) then
                        return
                    end

                    cfg = cfg or {}

                    while#activeToasts >= MAX_TOASTS do
                        local oldest = table.remove(activeToasts, 1)

                        if oldest then
                            oldest.Dismiss()
                        end
                    end

                    nextOrder += 1

                    local duration = tonumber(cfg.Duration) or 3.5
                    local kind = string.lower(tostring(cfg.Type or 'info'))
                    local accentKey = TYPE_COLOR_KEY[kind] or 'Accent'
                    local wrap = Instance.new('Frame')

                    wrap.Name = 'ToastWrap'
                    wrap.Size = UDim2.new(1, 0, 0, 0)
                    wrap.AutomaticSize = Enum.AutomaticSize.Y
                    wrap.BackgroundTransparency = 1
                    wrap.ClipsDescendants = false
                    wrap.LayoutOrder = nextOrder
                    wrap.ZIndex = Tokens.Layer.Notification
                    wrap.Parent = host

                    local card = Instance.new('TextButton')

                    card.Name = 'Toast'
                    card.Size = UDim2.new(1, 0, 0, 0)
                    card.AutomaticSize = Enum.AutomaticSize.Y
                    card.Position = UDim2.fromOffset(36, 0)
                    card.BackgroundColor3 = theme:Get('Card')
                    card.BackgroundTransparency = 1
                    card.BorderSizePixel = 0
                    card.Text = ''
                    card.AutoButtonColor = false
                    card.ClipsDescendants = true
                    card.ZIndex = Tokens.Layer.Notification + 1
                    card.Parent = wrap

                    Primitives.Corner(card, Tokens.Radius.Card)

                    local cardStroke = Primitives.Stroke(card, theme:Get('Stroke'), 1, 1)

                    theme:Bind(card, 'BackgroundColor3', 'Card')
                    theme:Bind(cardStroke, 'Color', 'Stroke')

                    local stripe = Instance.new('Frame')

                    stripe.Name = 'Stripe'
                    stripe.Size = UDim2.new(0, 3, 1, -16)
                    stripe.Position = UDim2.new(0, 5, 0, 8)
                    stripe.BackgroundColor3 = theme:Get(accentKey)
                    stripe.BackgroundTransparency = 1
                    stripe.BorderSizePixel = 0
                    stripe.ZIndex = Tokens.Layer.Notification + 2
                    stripe.Parent = card

                    Primitives.Corner(stripe, 2)
                    theme:Bind(stripe, 'BackgroundColor3', accentKey)

                    local body = Instance.new('Frame')

                    body.Size = UDim2.new(1, 0, 0, 0)
                    body.AutomaticSize = Enum.AutomaticSize.Y
                    body.BackgroundTransparency = 1
                    body.ZIndex = Tokens.Layer.Notification + 2
                    body.Parent = card

                    Primitives.Padding(body, 10, 14, 12, 16)

                    local bodyLayout = Instance.new('UIListLayout')

                    bodyLayout.Padding = UDim.new(0, 3)
                    bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    bodyLayout.Parent = body

                    local title = Instance.new('TextLabel')

                    title.Size = UDim2.new(1, 0, 0, 0)
                    title.AutomaticSize = Enum.AutomaticSize.Y
                    title.BackgroundTransparency = 1
                    title.Text = tostring(cfg.Title or 'Notification')
                    title.TextTransparency = 1
                    title.TextXAlignment = Enum.TextXAlignment.Left
                    title.TextWrapped = true
                    title.LayoutOrder = 1
                    title.ZIndex = Tokens.Layer.Notification + 3

                    Tokens.Typeset(title, 'Heading', theme:Get('Text'))

                    title.Parent = body

                    theme:Bind(title, 'TextColor3', 'Text')

                    local desc: TextLabel?

                    if cfg.Text and tostring(cfg.Text) ~= '' then
                        local d = Instance.new('TextLabel')

                        d.Size = UDim2.new(1, 0, 0, 0)
                        d.AutomaticSize = Enum.AutomaticSize.Y
                        d.BackgroundTransparency = 1
                        d.Text = tostring(cfg.Text)
                        d.TextTransparency = 1
                        d.TextXAlignment = Enum.TextXAlignment.Left
                        d.TextWrapped = true
                        d.LayoutOrder = 2
                        d.ZIndex = Tokens.Layer.Notification + 3

                        Tokens.Typeset(d, 'Body', theme:Get('SubText'))

                        d.Parent = body

                        theme:Bind(d, 'TextColor3', 'SubText')

                        desc = d
                    end

                    local progTrack = Instance.new('Frame')

                    progTrack.Size = UDim2.new(1, -20, 0, 2)
                    progTrack.Position = UDim2.new(0, 10, 1, -4)
                    progTrack.BackgroundTransparency = 1
                    progTrack.BorderSizePixel = 0
                    progTrack.ClipsDescendants = true
                    progTrack.ZIndex = Tokens.Layer.Notification + 3
                    progTrack.Parent = card

                    Primitives.Corner(progTrack, 999)

                    local progFill = Instance.new('Frame')

                    progFill.Size = UDim2.fromScale(1, 1)
                    progFill.BackgroundColor3 = theme:Get(accentKey)
                    progFill.BackgroundTransparency = 1
                    progFill.BorderSizePixel = 0
                    progFill.ZIndex = Tokens.Layer.Notification + 4
                    progFill.Parent = progTrack

                    Primitives.Corner(progFill, 999)
                    theme:Bind(progFill, 'BackgroundColor3', accentKey)

                    local dismissed = false
                    local entry: {Dismiss: () -> ()}

                    local function dismiss()
                        if dismissed then
                            return
                        end

                        dismissed = true

                        local idx = table.find(activeToasts, entry)

                        if idx then
                            table.remove(activeToasts, idx)
                        end
                        if Animator.Alive(card) then
                            Animator.Tween(card, 0.18, {
                                Position = UDim2.fromOffset(36, 0),
                                BackgroundTransparency = 1,
                            })
                            Animator.Tween(cardStroke, 0.18, {Transparency = 1})
                            Animator.Tween(stripe, 0.18, {BackgroundTransparency = 1})
                            Animator.Tween(progFill, 0.18, {BackgroundTransparency = 1})
                            Animator.Tween(title, 0.18, {TextTransparency = 1})

                            if desc and Animator.Alive(desc) then
                                Animator.Tween(desc, 0.18, {TextTransparency = 1})
                            end
                        end

                        task.delay(0.2, function()
                            if Animator.Alive(wrap) then
                                wrap:Destroy()
                            end
                        end)
                    end

                    entry = {Dismiss = dismiss}

                    table.insert(activeToasts, entry)
                    card.MouseButton1Click:Connect(dismiss)
                    Animator.Tween(card, 0.22, {
                        Position = UDim2.fromOffset(0, 0),
                        BackgroundTransparency = 0.04,
                    })
                    Animator.Tween(cardStroke, 0.22, {Transparency = 0.25})
                    Animator.Tween(stripe, 0.22, {BackgroundTransparency = 0})
                    Animator.Tween(title, 0.22, {TextTransparency = 0})

                    if desc then
                        Animator.Tween(desc, 0.22, {TextTransparency = 0})
                    end

                    Animator.Tween(progFill, 0.22, {BackgroundTransparency = 0.25})
                    Animator.Tween(progFill, duration, {
                        Size = UDim2.fromScale(0, 1),
                    }, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
                    task.delay(duration, dismiss)
                end
            end
            function Overlay.Confirm(window: any, opts: any)
                opts = opts or {}

                local theme = window._theme
                local parentGui = window.Gui

                if not Animator.Alive(parentGui) then
                    return
                end

                local prev = parentGui:FindFirstChild('PoloskaConfirm')

                if prev then
                    prev:Destroy()
                end

                local wrapper = Instance.new('Frame')

                wrapper.Name = 'PoloskaConfirm'
                wrapper.Size = UDim2.fromScale(1, 1)
                wrapper.BackgroundTransparency = 1
                wrapper.BorderSizePixel = 0
                wrapper.ZIndex = Tokens.Layer.Dialog
                wrapper.Parent = parentGui

                local backdrop = Instance.new('TextButton')

                backdrop.Name = 'Backdrop'
                backdrop.Size = UDim2.fromScale(1, 1)
                backdrop.BackgroundColor3 = theme:Get('Overlay')
                backdrop.BackgroundTransparency = 1
                backdrop.BorderSizePixel = 0
                backdrop.Text = ''
                backdrop.AutoButtonColor = false
                backdrop.ZIndex = Tokens.Layer.Dialog
                backdrop.Parent = wrapper

                theme:Bind(backdrop, 'BackgroundColor3', 'Overlay')

                local modal = Instance.new('Frame')

                modal.Name = 'Modal'
                modal.AnchorPoint = Vector2.new(0.5, 0.5)
                modal.Position = UDim2.new(0.5, 0, 0.5, 10)
                modal.Size = UDim2.fromOffset(340, 0)
                modal.AutomaticSize = Enum.AutomaticSize.Y
                modal.BackgroundColor3 = theme:Get('Card')
                modal.BackgroundTransparency = 1
                modal.BorderSizePixel = 0
                modal.Active = true
                modal.ZIndex = Tokens.Layer.Dialog + 2
                modal.Parent = wrapper

                Primitives.Corner(modal, Tokens.Radius.Window)

                local modalStroke = Primitives.Stroke(modal, theme:Get('StrokeBright'), 1, 1)

                theme:Bind(modal, 'BackgroundColor3', 'Card')
                theme:Bind(modalStroke, 'Color', 'StrokeBright')

                local content = Instance.new('Frame')

                content.Size = UDim2.new(1, 0, 0, 0)
                content.AutomaticSize = Enum.AutomaticSize.Y
                content.BackgroundTransparency = 1
                content.ZIndex = Tokens.Layer.Dialog + 3
                content.Parent = modal

                Primitives.Padding(content, 18, 18, 16, 18)

                local col = Instance.new('UIListLayout')

                col.Padding = UDim.new(0, 10)
                col.SortOrder = Enum.SortOrder.LayoutOrder
                col.Parent = content

                local title = Instance.new('TextLabel')

                title.Size = UDim2.new(1, 0, 0, 0)
                title.AutomaticSize = Enum.AutomaticSize.Y
                title.BackgroundTransparency = 1
                title.Text = tostring(opts.Title or 'Confirm')
                title.TextTransparency = 1
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.TextWrapped = true
                title.LayoutOrder = 1
                title.ZIndex = Tokens.Layer.Dialog + 4

                Tokens.Typeset(title, 'Title', theme:Get('Text'))

                title.Parent = content

                theme:Bind(title, 'TextColor3', 'Text')

                local message = Instance.new('TextLabel')

                message.Size = UDim2.new(1, 0, 0, 0)
                message.AutomaticSize = Enum.AutomaticSize.Y
                message.BackgroundTransparency = 1
                message.Text = tostring(opts.Text or 'Are you sure?')
                message.TextTransparency = 1
                message.TextXAlignment = Enum.TextXAlignment.Left
                message.TextWrapped = true
                message.LayoutOrder = 2
                message.ZIndex = Tokens.Layer.Dialog + 4

                Tokens.Typeset(message, 'Body', theme:Get('SubText'))

                message.Parent = content

                theme:Bind(message, 'TextColor3', 'SubText')

                local btnRow = Instance.new('Frame')

                btnRow.Size = UDim2.new(1, 0, 0, 34)
                btnRow.BackgroundTransparency = 1
                btnRow.LayoutOrder = 3
                btnRow.ZIndex = Tokens.Layer.Dialog + 4
                btnRow.Parent = content

                local fadeButtons: {TextButton} = {}
                local closed = false
                local escConn: RBXScriptConnection?

                local function close(cb: (() -> ())?)
                    if closed then
                        return
                    end

                    closed = true

                    if escConn then
                        escConn:Disconnect()

                        escConn = nil
                    end

                    Animator.Tween(backdrop, 0.14, {BackgroundTransparency = 1})
                    Animator.Tween(modal, 0.14, {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(0.5, 0, 0.5, 10),
                    })
                    Animator.Tween(modalStroke, 0.14, {Transparency = 1})
                    Animator.Tween(title, 0.14, {TextTransparency = 1})
                    Animator.Tween(message, 0.14, {TextTransparency = 1})

                    for _, b in ipairs(fadeButtons)do
                        if Animator.Alive(b) then
                            Animator.Tween(b, 0.14, {
                                BackgroundTransparency = 1,
                                TextTransparency = 1,
                            })
                        end
                    end

                    task.delay(0.16, function()
                        if Animator.Alive(wrapper) then
                            wrapper:Destroy()
                        end
                    end)

                    if cb then
                        task.spawn(cb)
                    end
                end
                local function makeBtn(
                    text: string,
                    xPos: UDim2,
                    colorKey: string,
                    textColorKey: string?,
                    fallbackTextColor: Color3,
                    cb: (() -> ())?
                )
                    local b = Instance.new('TextButton')

                    b.Size = UDim2.new(0.5, -5, 1, 0)
                    b.Position = xPos
                    b.BackgroundColor3 = theme:Get(colorKey)
                    b.BackgroundTransparency = 1
                    b.BorderSizePixel = 0
                    b.Text = text
                    b.TextTransparency = 1
                    b.AutoButtonColor = false
                    b.ZIndex = Tokens.Layer.Dialog + 5

                    local txtColor = textColorKey and theme:Get(textColorKey) or fallbackTextColor

                    Tokens.Typeset(b, 'Label', txtColor)

                    b.Parent = btnRow

                    Primitives.Corner(b, Tokens.Radius.Control)
                    theme:Bind(b, 'BackgroundColor3', colorKey)

                    if textColorKey then
                        theme:Bind(b, 'TextColor3', textColorKey)
                    end

                    table.insert(fadeButtons, b)
                    b.MouseEnter:Connect(function()
                        if not closed then
                            Animator.Tween(b, Tokens.Motion.Fast, {BackgroundTransparency = 0.15})
                        end
                    end)
                    b.MouseLeave:Connect(function()
                        if not closed then
                            Animator.Tween(b, Tokens.Motion.Fast, {BackgroundTransparency = 0})
                        end
                    end)
                    b.MouseButton1Click:Connect(function()
                        close(cb)
                    end)
                end

                local isDanger = opts.Danger ~= false

                makeBtn(tostring(opts.CancelText or 'Cancel'), UDim2.new(0, 0, 0, 0), 'Element', 'Text', theme:Get('Text'), opts.OnCancel)
                makeBtn(tostring(opts.ConfirmText or 'Confirm'), UDim2.new(0.5, 5, 0, 0), isDanger and 'Danger' or 'Accent', isDanger and nil or 'OnAccent', Color3.fromRGB(255, 255, 255), opts.OnConfirm)
                backdrop.MouseButton1Click:Connect(function()
                    close(opts.OnCancel)
                end)

                escConn = UserInputService.InputBegan:Connect(function(
                    input: InputObject
                )
                    if input.KeyCode == Enum.KeyCode.Escape then
                        close(opts.OnCancel)
                    end
                end)

                wrapper.Destroying:Connect(function()
                    if escConn then
                        escConn:Disconnect()

                        escConn = nil
                    end
                end)
                Animator.Tween(backdrop, 0.16, {BackgroundTransparency = 0.42})
                Animator.Tween(modal, 0.2, {
                    BackgroundTransparency = 0,
                    Position = UDim2.new(0.5, 0, 0.5, 0),
                })
                Animator.Tween(modalStroke, 0.2, {Transparency = 0.35})
                Animator.Tween(title, 0.2, {TextTransparency = 0})
                Animator.Tween(message, 0.2, {TextTransparency = 0})

                for _, b in ipairs(fadeButtons)do
                    Animator.Tween(b, 0.2, {
                        BackgroundTransparency = 0,
                        TextTransparency = 0,
                    })
                end
            end

            return Overlay
        end

        function __POLOSKALIB_MODULES.f(): typeof(__modImpl())
            local v = __POLOSKALIB_MODULES.cache.f

            if not v then
                v = {
                    c = __modImpl(),
                }
                __POLOSKALIB_MODULES.cache.f = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local UserInputService = game:GetService('UserInputService')
            local Tokens = __POLOSKALIB_MODULES.a()
            local Animator = __POLOSKALIB_MODULES.d()
            local Primitives = __POLOSKALIB_MODULES.e()
            local Controls = {}

            local function makeRow(
                parent: Instance,
                height: number,
                theme: any,
                searchableText: string?
            ): Frame
                local f = Instance.new('Frame')

                f.Size = UDim2.new(1, 0, 0, height)
                f.BackgroundColor3 = theme:Get('Element')
                f.BorderSizePixel = 0
                f.ZIndex = Tokens.Layer.Content + 1
                f.Parent = parent

                Primitives.Corner(f, Tokens.Radius.Control)

                local st = Primitives.Stroke(f, theme:Get('Stroke'), 1, 0.78)

                theme:Bind(f, 'BackgroundColor3', 'Element')
                theme:Bind(st, 'Color', 'Stroke')

                if searchableText and searchableText ~= '' then
                    f:SetAttribute('SearchText', string.lower(searchableText))
                end

                return f
            end

            function Controls.Section(
                parent: Instance,
                theme: any,
                text: string,
                opts: any?
            ): TextLabel
                opts = opts or {}

                local wrap = Instance.new('Frame')

                wrap.Name = 'SectionWrap'
                wrap.Size = UDim2.new(1, 0, 0, 0)
                wrap.AutomaticSize = Enum.AutomaticSize.Y
                wrap.BackgroundTransparency = 1
                wrap.BorderSizePixel = 0
                wrap.ZIndex = Tokens.Layer.Content + 1

                if opts.Bottom then
                    wrap.LayoutOrder = 9999
                end

                wrap.Parent = parent

                Primitives.Padding(wrap, 2, 4, 4, 2)

                local label = Instance.new('TextLabel')

                label.Name = 'SectionLabel'
                label.Size = UDim2.new(1, 0, 0, 0)
                label.AutomaticSize = Enum.AutomaticSize.Y
                label.BackgroundTransparency = 1
                label.Text = tostring(text or '')
                label.TextXAlignment = Enum.TextXAlignment.Left
                label.TextYAlignment = Enum.TextYAlignment.Top
                label.TextWrapped = true
                label.LineHeight = 1.15
                label.ZIndex = Tokens.Layer.Content + 2

                Tokens.Typeset(label, opts.Bottom and 'Caption' or 'Body', theme:Get(opts.Bottom and 'MutedText' or 'SubText'))

                label.Parent = wrap

                theme:Bind(label, 'TextColor3', opts.Bottom and 'MutedText' or 'SubText')
                label:GetPropertyChangedSignal('Visible'):Connect(function()
                    if Animator.Alive(wrap) then
                        wrap.Visible = label.Visible
                    end
                end)

                return label
            end
            function Controls.Metrics(
                parent: Instance,
                theme: any,
                items: {{Key: string, Label: string, Value: string?, Accent: string?}}
            )
                local rows = math.ceil(#items / 2)
                local gridH = rows > 0 and (rows * 48 + math.max(0, rows - 1) * 8) or 0
                local grid = Instance.new('Frame')

                grid.Name = 'MetricsGrid'
                grid.Size = UDim2.new(1, 0, 0, gridH)
                grid.AutomaticSize = Enum.AutomaticSize.None
                grid.BackgroundTransparency = 1
                grid.ZIndex = Tokens.Layer.Content + 1
                grid.Parent = parent

                local layout = Instance.new('UIGridLayout')

                layout.CellSize = UDim2.new(0.5, -4, 0, 48)
                layout.CellPadding = UDim2.fromOffset(8, 8)
                layout.FillDirection = Enum.FillDirection.Horizontal
                layout.FillDirectionMaxCells = 2
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Parent = grid

                local valueLabels: {[string]: TextLabel} = {}

                for idx, item in ipairs(items)do
                    local tile = Instance.new('Frame')

                    tile.Name = 'Metric_' .. item.Key
                    tile.BackgroundColor3 = theme:Get('Element')
                    tile.BorderSizePixel = 0
                    tile.LayoutOrder = idx
                    tile.ZIndex = Tokens.Layer.Content + 2
                    tile.Parent = grid

                    Primitives.Corner(tile, Tokens.Radius.Control)

                    local st = Primitives.Stroke(tile, theme:Get('Stroke'), 1, 0.72)

                    theme:Bind(tile, 'BackgroundColor3', 'Element')
                    theme:Bind(st, 'Color', 'Stroke')
                    Primitives.Padding(tile, 6, 10, 6, 10)

                    local caption = Instance.new('TextLabel')

                    caption.Size = UDim2.new(1, 0, 0, 14)
                    caption.BackgroundTransparency = 1
                    caption.Text = string.upper(item.Label)
                    caption.TextXAlignment = Enum.TextXAlignment.Left
                    caption.TextTruncate = Enum.TextTruncate.AtEnd
                    caption.ZIndex = Tokens.Layer.Content + 3

                    Tokens.Typeset(caption, 'Caption', theme:Get('MutedText'))

                    caption.Parent = tile

                    theme:Bind(caption, 'TextColor3', 'MutedText')

                    local val = Instance.new('TextLabel')

                    val.Size = UDim2.new(1, 0, 0, 20)
                    val.Position = UDim2.new(0, 0, 0, 15)
                    val.BackgroundTransparency = 1
                    val.Text = tostring(item.Value or '-')
                    val.TextXAlignment = Enum.TextXAlignment.Left
                    val.TextTruncate = Enum.TextTruncate.AtEnd
                    val.ZIndex = Tokens.Layer.Content + 3

                    local colorKey = item.Accent or 'Text'

                    Tokens.Typeset(val, 'Heading', theme:Get(colorKey))

                    val.Parent = tile

                    theme:Bind(val, 'TextColor3', colorKey)

                    valueLabels[item.Key] = val
                end

                local handle = {Frame = grid}

                function handle:Set(
                    key: string,
                    value: any,
                    accentKey: string?
                )
                    local lbl = valueLabels[key]

                    if lbl and Animator.Alive(lbl) then
                        lbl.Text = tostring(value)

                        if accentKey then
                            theme:Bind(lbl, 'TextColor3', accentKey)
                        end
                    end
                end
                function handle:SetAll(values: {[string]: any})
                    for k, v in pairs(values)do
                        self:Set(k, v)
                    end
                end

                return handle
            end
            function Controls.Button(
                parent: Instance,
                _window: any,
                theme: any,
                cfg: any
            )
                cfg = cfg or {}

                local name = tostring(cfg.Name or 'Button')
                local style = tostring(cfg.Style or 'default')
                local bgKey = style == 'danger' and 'Danger' or (style == 'primary' and 'AccentSoft' or 'Element')
                local hoverKey = style == 'danger' and 'Danger' or (style == 'primary' and 'Accent' or 'ElementHover')
                local strokeKey = style == 'danger' and 'Danger' or (style == 'primary' and 'Accent' or 'Stroke')
                local baseStrokeTrans = style == 'default' and 0.72 or 0.25
                local btn = Instance.new('TextButton')

                btn.Name = 'Button'
                btn.Size = UDim2.new(1, 0, 0, 36)
                btn.BackgroundColor3 = theme:Get(bgKey)
                btn.BorderSizePixel = 0
                btn.Text = ''
                btn.AutoButtonColor = false
                btn.ZIndex = Tokens.Layer.Content + 2
                btn.Parent = parent

                btn:SetAttribute('SearchText', string.lower(name))
                Primitives.Corner(btn, Tokens.Radius.Control)

                local st = Primitives.Stroke(btn, theme:Get(strokeKey), 1, baseStrokeTrans)

                theme:Bind(btn, 'BackgroundColor3', bgKey)
                theme:Bind(st, 'Color', strokeKey)

                local lbl = Instance.new('TextLabel')

                lbl.Size = UDim2.new(1, -24, 1, 0)
                lbl.Position = UDim2.new(0, 12, 0, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = name
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextTruncate = Enum.TextTruncate.AtEnd
                lbl.ZIndex = Tokens.Layer.Content + 3

                Tokens.Typeset(lbl, 'Label', style == 'danger' and Color3.fromRGB(255, 255, 255) or theme:Get('Text'))

                lbl.Parent = btn

                if style ~= 'danger' then
                    theme:Bind(lbl, 'TextColor3', 'Text')
                end

                local arrow = Instance.new('TextLabel')

                arrow.Size = UDim2.fromOffset(18, 18)
                arrow.AnchorPoint = Vector2.new(1, 0.5)
                arrow.Position = UDim2.new(1, -10, 0.5, 0)
                arrow.BackgroundTransparency = 1
                arrow.Text = '\u{203a}'
                arrow.ZIndex = Tokens.Layer.Content + 3

                Tokens.Typeset(arrow, 'Caption', style == 'danger' and Color3.fromRGB(255, 255, 255) or theme:Get('MutedText'))

                arrow.Parent = btn

                if style ~= 'danger' then
                    theme:Bind(arrow, 'TextColor3', 'MutedText')
                end

                local hovered = false

                btn.MouseEnter:Connect(function()
                    hovered = true

                    Animator.Tween(btn, Tokens.Motion.Fast, {
                        BackgroundColor3 = theme:Get(hoverKey),
                        BackgroundTransparency = style == 'danger' and 0.12 or 0,
                    })
                    Animator.Tween(st, Tokens.Motion.Fast, {
                        Transparency = 0.08,
                        Color = theme:Get(style == 'danger' and 'Danger' or 'StrokeBright'),
                    })

                    if style == 'primary' then
                        local onAccent = theme:Get('OnAccent')

                        Animator.Tween(lbl, Tokens.Motion.Fast, {TextColor3 = onAccent})
                        Animator.Tween(arrow, Tokens.Motion.Fast, {TextColor3 = onAccent})
                    end
                end)
                btn.MouseLeave:Connect(function()
                    hovered = false

                    Animator.Tween(btn, Tokens.Motion.Base, {
                        BackgroundColor3 = theme:Get(bgKey),
                        BackgroundTransparency = 0,
                    })
                    Animator.Tween(st, Tokens.Motion.Base, {
                        Transparency = baseStrokeTrans,
                        Color = theme:Get(strokeKey),
                    })

                    if style == 'primary' then
                        Animator.Tween(lbl, Tokens.Motion.Base, {
                            TextColor3 = theme:Get('Text'),
                        })
                        Animator.Tween(arrow, Tokens.Motion.Base, {
                            TextColor3 = theme:Get('MutedText'),
                        })
                    end
                end)
                btn.MouseButton1Down:Connect(function()
                    if style == 'primary' then
                        Animator.Tween(btn, 0.08, {
                            BackgroundColor3 = theme:Get('Accent'),
                            BackgroundTransparency = 0.15,
                        })
                    elseif style == 'danger' then
                        Animator.Tween(btn, 0.08, {
                            BackgroundColor3 = theme:Get('Danger'),
                            BackgroundTransparency = 0.22,
                        })
                    else
                        Animator.Tween(btn, 0.08, {
                            BackgroundColor3 = theme:Get('ElementActive'),
                            BackgroundTransparency = 0,
                        })
                    end
                end)
                btn.MouseButton1Up:Connect(function()
                    if hovered then
                        Animator.Tween(btn, Tokens.Motion.Fast, {
                            BackgroundColor3 = theme:Get(hoverKey),
                            BackgroundTransparency = style == 'danger' and 0.12 or 0,
                        })
                    else
                        Animator.Tween(btn, Tokens.Motion.Fast, {
                            BackgroundColor3 = theme:Get(bgKey),
                            BackgroundTransparency = 0,
                        })
                    end
                end)
                btn.MouseButton1Click:Connect(function()
                    if cfg.Callback then
                        task.spawn(cfg.Callback)
                    end
                end)

                local handle = {Frame = btn}

                function handle:SetText(newText: string)
                    local s = tostring(newText)

                    if Animator.Alive(lbl) then
                        lbl.Text = s
                    end
                    if Animator.Alive(btn) then
                        btn:SetAttribute('SearchText', string.lower(s))
                    end
                end

                return handle
            end
            function Controls.ButtonRow(
                parent: Instance,
                _window: any,
                theme: any,
                cfg: any
            )
                local list: {any} = {}

                if type(cfg) == 'table' then
                    if type(cfg.Buttons) == 'table' then
                        list = cfg.Buttons
                    else
                        list = cfg
                    end
                end

                local count = #list
                local gap = 6
                local row = Instance.new('Frame')

                row.Name = 'ButtonRow'
                row.Size = UDim2.new(1, 0, 0, 34)
                row.BackgroundTransparency = 1
                row.BorderSizePixel = 0
                row.ZIndex = Tokens.Layer.Content + 1
                row.Parent = parent

                local layout = Instance.new('UIListLayout')

                layout.FillDirection = Enum.FillDirection.Horizontal
                layout.Padding = UDim.new(0, gap)
                layout.SortOrder = Enum.SortOrder.LayoutOrder
                layout.Parent = row

                local titles: {string} = {}
                local buttonHandles: {any} = {}

                local function refreshSearchText()
                    if Animator.Alive(row) then
                        row:SetAttribute('SearchText', string.lower(table.concat(titles, ' ')))
                    end
                end

                local scaleW = count > 0 and (1 / count) or 1
                local offsetW = count > 1 and -math.floor(((count - 1) * gap) / count + 0.5) or 0

                for idx, bCfg in ipairs(list)do
                    bCfg = bCfg or {}

                    local title = tostring(bCfg.Title or bCfg.Name or ('Action ' .. idx))

                    titles[idx] = title

                    local style = tostring(bCfg.Style or 'default')
                    local bgKey = style == 'danger' and 'Danger' or (style == 'primary' and 'AccentSoft' or 'Element')
                    local hoverKey = style == 'danger' and 'Danger' or (style == 'primary' and 'Accent' or 'ElementHover')
                    local strokeKey = style == 'danger' and 'Danger' or (style == 'primary' and 'Accent' or 'Stroke')
                    local baseStrokeTrans = style == 'default' and 0.72 or 0.25
                    local enabled = bCfg.Enabled ~= false
                    local hovered = false
                    local btn = Instance.new('TextButton')

                    btn.Name = 'RowButton_' .. idx
                    btn.Size = UDim2.new(scaleW, offsetW, 1, 0)
                    btn.BackgroundColor3 = theme:Get(bgKey)
                    btn.BackgroundTransparency = enabled and 0 or 0.45
                    btn.BorderSizePixel = 0
                    btn.Text = ''
                    btn.AutoButtonColor = false
                    btn.Active = enabled
                    btn.LayoutOrder = idx
                    btn.ZIndex = Tokens.Layer.Content + 2
                    btn.Parent = row

                    Primitives.Corner(btn, Tokens.Radius.Control)

                    local st = Primitives.Stroke(btn, theme:Get(strokeKey), 1, baseStrokeTrans)

                    theme:Bind(btn, 'BackgroundColor3', bgKey)
                    theme:Bind(st, 'Color', strokeKey)

                    local lbl = Instance.new('TextLabel')

                    lbl.Size = UDim2.new(1, -12, 1, 0)
                    lbl.Position = UDim2.new(0, 6, 0, 0)
                    lbl.BackgroundTransparency = 1
                    lbl.Text = title
                    lbl.TextTransparency = enabled and 0 or 0.45
                    lbl.TextXAlignment = Enum.TextXAlignment.Center
                    lbl.TextTruncate = Enum.TextTruncate.AtEnd
                    lbl.ZIndex = Tokens.Layer.Content + 3

                    Tokens.Typeset(lbl, 'Label', style == 'danger' and Color3.fromRGB(255, 255, 255) or theme:Get('Text'))

                    lbl.Parent = btn

                    if style ~= 'danger' then
                        theme:Bind(lbl, 'TextColor3', 'Text')
                    end

                    btn.MouseEnter:Connect(function()
                        if not enabled then
                            return
                        end

                        hovered = true

                        Animator.Tween(btn, Tokens.Motion.Fast, {
                            BackgroundColor3 = theme:Get(hoverKey),
                            BackgroundTransparency = style == 'danger' and 0.12 or 0,
                        })
                        Animator.Tween(st, Tokens.Motion.Fast, {
                            Transparency = 0.08,
                            Color = theme:Get(style == 'danger' and 'Danger' or 'StrokeBright'),
                        })

                        if style == 'primary' then
                            Animator.Tween(lbl, Tokens.Motion.Fast, {
                                TextColor3 = theme:Get('OnAccent'),
                            })
                        end
                    end)
                    btn.MouseLeave:Connect(function()
                        hovered = false

                        if not enabled then
                            return
                        end

                        Animator.Tween(btn, Tokens.Motion.Base, {
                            BackgroundColor3 = theme:Get(bgKey),
                            BackgroundTransparency = 0,
                        })
                        Animator.Tween(st, Tokens.Motion.Base, {
                            Transparency = baseStrokeTrans,
                            Color = theme:Get(strokeKey),
                        })

                        if style == 'primary' then
                            Animator.Tween(lbl, Tokens.Motion.Base, {
                                TextColor3 = theme:Get('Text'),
                            })
                        end
                    end)
                    btn.MouseButton1Down:Connect(function()
                        if not enabled then
                            return
                        end
                        if style == 'primary' then
                            Animator.Tween(btn, 0.08, {
                                BackgroundColor3 = theme:Get('Accent'),
                                BackgroundTransparency = 0.15,
                            })
                        elseif style == 'danger' then
                            Animator.Tween(btn, 0.08, {
                                BackgroundColor3 = theme:Get('Danger'),
                                BackgroundTransparency = 0.22,
                            })
                        else
                            Animator.Tween(btn, 0.08, {
                                BackgroundColor3 = theme:Get('ElementActive'),
                                BackgroundTransparency = 0,
                            })
                        end
                    end)
                    btn.MouseButton1Up:Connect(function()
                        if not enabled then
                            return
                        end
                        if hovered then
                            Animator.Tween(btn, Tokens.Motion.Fast, {
                                BackgroundColor3 = theme:Get(hoverKey),
                                BackgroundTransparency = style == 'danger' and 0.12 or 0,
                            })
                        else
                            Animator.Tween(btn, Tokens.Motion.Fast, {
                                BackgroundColor3 = theme:Get(bgKey),
                                BackgroundTransparency = 0,
                            })
                        end
                    end)
                    btn.MouseButton1Click:Connect(function()
                        if enabled and bCfg.Callback then
                            task.spawn(bCfg.Callback)
                        end
                    end)

                    local bHandle: any = {Frame = btn}

                    function bHandle:SetText(newText: string)
                        local s = tostring(newText)

                        titles[idx] = s

                        if Animator.Alive(lbl) then
                            lbl.Text = s
                        end

                        refreshSearchText()
                    end
                    function bHandle:SetEnabled(flag: boolean)
                        enabled = flag ~= false
                        hovered = false

                        if Animator.Alive(btn) then
                            btn.Active = enabled

                            Animator.Tween(btn, Tokens.Motion.Fast, {
                                BackgroundColor3 = theme:Get(bgKey),
                                BackgroundTransparency = enabled and 0 or 0.45,
                            })
                        end
                        if Animator.Alive(lbl) then
                            Animator.Tween(lbl, Tokens.Motion.Fast, {
                                TextTransparency = enabled and 0 or 0.45,
                                TextColor3 = style == 'danger' and Color3.fromRGB(255, 255, 255) or theme:Get('Text'),
                            })
                        end
                        if Animator.Alive(st) then
                            Animator.Tween(st, Tokens.Motion.Fast, {
                                Transparency = enabled and baseStrokeTrans or 0.85,
                                Color = theme:Get(strokeKey),
                            })
                        end
                    end

                    buttonHandles[idx] = bHandle
                end

                refreshSearchText()

                local handle: any = {
                    Frame = row,
                    Buttons = buttonHandles,
                }

                function handle:SetEnabled(
                    indexOrEnabled: any,
                    maybeEnabled: boolean?
                )
                    if type(indexOrEnabled) == 'number' then
                        local bh = buttonHandles[indexOrEnabled]

                        if bh then
                            bh:SetEnabled(maybeEnabled ~= false)
                        end
                    else
                        local flag = indexOrEnabled ~= false

                        for _, bh in ipairs(buttonHandles)do
                            bh:SetEnabled(flag)
                        end
                    end
                end
                function handle:SetText(index: number, newText: string)
                    local bh = buttonHandles[index]

                    if bh then
                        bh:SetText(newText)
                    end
                end

                return handle
            end
            function Controls.Toggle(
                parent: Instance,
                _window: any,
                theme: any,
                cfg: any
            )
                cfg = cfg or {}

                local name = tostring(cfg.Name or 'Toggle')
                local descText = cfg.Description and tostring(cfg.Description) or nil
                local state = cfg.StartingState == true
                local row = makeRow(parent, descText and 54 or 42, theme, name .. ' ' .. (descText or ''))

                row.Name = 'Toggle'

                local hit = Instance.new('TextButton')

                hit.Size = UDim2.fromScale(1, 1)
                hit.BackgroundTransparency = 1
                hit.Text = ''
                hit.AutoButtonColor = false
                hit.ZIndex = Tokens.Layer.Content + 4
                hit.Parent = row

                local lbl = Instance.new('TextLabel')

                lbl.Size = UDim2.new(1, -68, 0, 18)
                lbl.Position = descText and UDim2.new(0, 12, 0, 8) or UDim2.new(0, 12, 0.5, 
-9)
                lbl.BackgroundTransparency = 1
                lbl.Text = name
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextTruncate = Enum.TextTruncate.AtEnd
                lbl.ZIndex = Tokens.Layer.Content + 2

                Tokens.Typeset(lbl, 'Label', theme:Get('Text'))

                lbl.Parent = row

                theme:Bind(lbl, 'TextColor3', 'Text')

                if descText then
                    local sub = Instance.new('TextLabel')

                    sub.Size = UDim2.new(1, -68, 0, 14)
                    sub.Position = UDim2.new(0, 12, 0, 28)
                    sub.BackgroundTransparency = 1
                    sub.Text = descText
                    sub.TextXAlignment = Enum.TextXAlignment.Left
                    sub.TextTruncate = Enum.TextTruncate.AtEnd
                    sub.ZIndex = Tokens.Layer.Content + 2

                    Tokens.Typeset(sub, 'Caption', theme:Get('MutedText'))

                    sub.Parent = row

                    theme:Bind(sub, 'TextColor3', 'MutedText')
                end

                local track = Instance.new('Frame')

                track.Size = UDim2.fromOffset(40, 22)
                track.AnchorPoint = Vector2.new(1, 0.5)
                track.Position = UDim2.new(1, -12, 0.5, 0)
                track.BackgroundColor3 = state and theme:Get('Accent') or theme:Get('Stroke')
                track.BorderSizePixel = 0
                track.ZIndex = Tokens.Layer.Content + 2
                track.Parent = row

                Primitives.Corner(track, Tokens.Radius.Pill)

                local trackStroke = Primitives.Stroke(track, state and theme:Get('Accent') or theme:Get('StrokeBright'), 1, state and 0.2 or 0.5)
                local knob = Instance.new('Frame')

                knob.Size = UDim2.fromOffset(16, 16)
                knob.AnchorPoint = Vector2.new(0, 0.5)
                knob.Position = state and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                knob.BorderSizePixel = 0
                knob.ZIndex = Tokens.Layer.Content + 3
                knob.Parent = track

                Primitives.Corner(knob, Tokens.Radius.Pill)

                local function paint(animated: boolean)
                    if not Animator.Alive(track) then
                        return
                    end

                    local bg = state and theme:Get('Accent') or theme:Get('Stroke')
                    local stColor = state and theme:Get('Accent') or theme:Get('StrokeBright')
                    local stTrans = state and 0.15 or 0.55
                    local pos = state and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
                    local sz = UDim2.fromOffset(16, 16)

                    if animated then
                        Animator.Tween(track, Tokens.Motion.Base, {BackgroundColor3 = bg})
                        Animator.Tween(trackStroke, Tokens.Motion.Base, {
                            Color = stColor,
                            Transparency = stTrans,
                        })
                        Animator.Tween(knob, Tokens.Motion.Spring, {
                            Position = pos,
                            Size = sz,
                        }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
                    else
                        track.BackgroundColor3 = bg
                        trackStroke.Color = stColor
                        trackStroke.Transparency = stTrans
                        knob.Position = pos
                        knob.Size = sz
                    end
                end

                theme:OnChange(function()
                    if not Animator.Alive(track) then
                        return false
                    end

                    paint(false)

                    return true
                end)
                hit.MouseEnter:Connect(function()
                    Animator.Tween(row, Tokens.Motion.Fast, {
                        BackgroundColor3 = theme:Get('ElementHover'),
                    })
                end)
                hit.MouseLeave:Connect(function()
                    Animator.Tween(row, Tokens.Motion.Base, {
                        BackgroundColor3 = theme:Get('Element'),
                    })
                    Animator.Tween(knob, Tokens.Motion.Fast, {
                        Size = UDim2.fromOffset(16, 16),
                        Position = state and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                    })
                end)
                hit.MouseButton1Down:Connect(function()
                    Animator.Tween(knob, 0.08, {
                        Size = UDim2.fromOffset(18, 16),
                        Position = state and UDim2.new(0, 19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                    })
                end)
                hit.MouseButton1Up:Connect(function()
                    Animator.Tween(knob, Tokens.Motion.Fast, {
                        Size = UDim2.fromOffset(16, 16),
                        Position = state and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
                    })
                end)

                local function setState(newState: boolean, silent: boolean?)
                    state = newState == true

                    paint(true)

                    if not silent and cfg.Callback then
                        cfg.Callback(state)
                    end
                end

                hit.MouseButton1Click:Connect(function()
                    setState(not state, false)
                end)

                if state and cfg.Callback then
                    cfg.Callback(true)
                end

                local handle = {Frame = row}

                function handle:Set(v: boolean, silent: boolean?)
                    setState(v, silent)
                end
                function handle:Get(): boolean
                    return state
                end

                return handle
            end
            function Controls.Slider(
                parent: Instance,
                _window: any,
                theme: any,
                cfg: any
            )
                cfg = cfg or {}

                local name = tostring(cfg.Name or 'Slider')
                local minVal = tonumber(cfg.Min) or 0
                local maxVal = tonumber(cfg.Max) or 100

                if maxVal <= minVal then
                    maxVal = minVal + 1
                end

                local step = tonumber(cfg.Step) or 1
                local editable = cfg.Editable == true
                local commitOnRelease = cfg.CommitOnRelease == true
                local suffix = cfg.Suffix and tostring(cfg.Suffix) or ''

                local function clampSnap(raw: number): number
                    local clamped = math.clamp(raw, minVal, maxVal)

                    if step > 0 then
                        clamped = minVal + math.floor((clamped - minVal) / step + 0.5) * step
                        clamped = math.clamp(clamped, minVal, maxVal)
                    end

                    return clamped
                end

                local value = clampSnap(tonumber(cfg.Default) or minVal)
                local row = makeRow(parent, 56, theme, name)

                row.Name = 'Slider'

                Primitives.Padding(row, 8, 12, 10, 12)

                local header = Instance.new('Frame')

                header.Size = UDim2.new(1, 0, 0, 18)
                header.BackgroundTransparency = 1
                header.ZIndex = Tokens.Layer.Content + 2
                header.Parent = row

                local lbl = Instance.new('TextLabel')

                lbl.Size = UDim2.new(1, -68, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = name
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextTruncate = Enum.TextTruncate.AtEnd
                lbl.ZIndex = Tokens.Layer.Content + 2

                Tokens.Typeset(lbl, 'Label', theme:Get('Text'))

                lbl.Parent = header

                theme:Bind(lbl, 'TextColor3', 'Text')

                local valChip: any
                local bStroke: UIStroke?

                if editable then
                    local box = Instance.new('TextBox')

                    box.Size = UDim2.fromOffset(60, 20)
                    box.AnchorPoint = Vector2.new(1, 0.5)
                    box.Position = UDim2.new(1, 0, 0.5, 0)
                    box.BackgroundColor3 = theme:Get('Card')
                    box.BorderSizePixel = 0
                    box.Text = tostring(value)
                    box.ClearTextOnFocus = false
                    box.TextXAlignment = Enum.TextXAlignment.Center
                    box.ZIndex = Tokens.Layer.Content + 3

                    Tokens.Typeset(box, 'Mono', theme:Get('Accent'))

                    box.Parent = header

                    Primitives.Corner(box, Tokens.Radius.Chip)

                    local st = Primitives.Stroke(box, theme:Get('Stroke'), 1, 0.4)

                    theme:Bind(box, 'BackgroundColor3', 'Card')
                    theme:Bind(box, 'TextColor3', 'Accent')
                    theme:Bind(st, 'Color', 'Stroke')

                    bStroke = st
                    valChip = box
                else
                    local chip = Instance.new('TextLabel')

                    chip.Size = UDim2.fromOffset(64, 20)
                    chip.AnchorPoint = Vector2.new(1, 0.5)
                    chip.Position = UDim2.new(1, 0, 0.5, 0)
                    chip.BackgroundTransparency = 1
                    chip.Text = tostring(value) .. suffix
                    chip.TextXAlignment = Enum.TextXAlignment.Right
                    chip.ZIndex = Tokens.Layer.Content + 3

                    Tokens.Typeset(chip, 'Mono', theme:Get('Accent'))

                    chip.Parent = header

                    theme:Bind(chip, 'TextColor3', 'Accent')

                    valChip = chip
                end

                local trackHit = Instance.new('TextButton')

                trackHit.Size = UDim2.new(1, -14, 0, 18)
                trackHit.Position = UDim2.new(0, 7, 1, -18)
                trackHit.BackgroundTransparency = 1
                trackHit.Text = ''
                trackHit.AutoButtonColor = false
                trackHit.ZIndex = Tokens.Layer.Content + 3
                trackHit.Parent = row

                local track = Instance.new('Frame')

                track.Size = UDim2.new(1, 0, 0, 6)
                track.AnchorPoint = Vector2.new(0, 0.5)
                track.Position = UDim2.new(0, 0, 0.5, 0)
                track.BackgroundColor3 = theme:Get('Card')
                track.BorderSizePixel = 0
                track.ZIndex = Tokens.Layer.Content + 2
                track.Parent = trackHit

                Primitives.Corner(track, Tokens.Radius.Pill)

                local trackStroke = Primitives.Stroke(track, theme:Get('Stroke'), 1, 0.45)

                theme:Bind(track, 'BackgroundColor3', 'Card')
                theme:Bind(trackStroke, 'Color', 'Stroke')

                local fill = Instance.new('Frame')

                fill.Size = UDim2.fromScale(0, 1)
                fill.BackgroundColor3 = Color3.new(1, 1, 1)
                fill.BorderSizePixel = 0
                fill.ZIndex = Tokens.Layer.Content + 3
                fill.Parent = track

                Primitives.Corner(fill, Tokens.Radius.Pill)

                local fillGrad = Primitives.Gradient(fill, theme:Get('Accent'), theme:Get('AccentSecondary'), 0)

                theme:BindGradient(fillGrad, 'Accent', 'AccentSecondary')

                local thumb = Instance.new('Frame')

                thumb.Size = UDim2.fromOffset(14, 14)
                thumb.AnchorPoint = Vector2.new(0.5, 0.5)
                thumb.Position = UDim2.fromScale(0, 0.5)
                thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                thumb.BorderSizePixel = 0
                thumb.ZIndex = Tokens.Layer.Content + 4
                thumb.Parent = track

                Primitives.Corner(thumb, Tokens.Radius.Pill)

                local thumbStroke = Primitives.Stroke(thumb, theme:Get('Accent'), 2, 0.1)

                theme:Bind(thumbStroke, 'Color', 'Accent')

                local function render(animated: boolean)
                    local pct = math.clamp((value - minVal) / (maxVal - minVal), 0, 1)

                    if Animator.Alive(valChip) then
                        valChip.Text = editable and tostring(value) or (tostring(value) .. suffix)
                    end
                    if animated then
                        Animator.Tween(fill, 0.08, {
                            Size = UDim2.fromScale(pct, 1),
                        })
                        Animator.Tween(thumb, 0.08, {
                            Position = UDim2.fromScale(pct, 0.5),
                        })
                    else
                        fill.Size = UDim2.fromScale(pct, 1)
                        thumb.Position = UDim2.fromScale(pct, 0.5)
                    end
                end

                render(false)

                local dragging = false
                local rowHovered = false
                local trackHovered = false
                local moveConn: RBXScriptConnection?
                local endConn: RBXScriptConnection?

                local function disconnectDrag()
                    dragging = false

                    if moveConn then
                        moveConn:Disconnect()

                        moveConn = nil
                    end
                    if endConn then
                        endConn:Disconnect()

                        endConn = nil
                    end
                end

                row.Destroying:Connect(disconnectDrag)
                row.MouseEnter:Connect(function()
                    rowHovered = true

                    Animator.Tween(row, Tokens.Motion.Fast, {
                        BackgroundColor3 = theme:Get('ElementHover'),
                    })
                end)
                row.MouseLeave:Connect(function()
                    rowHovered = false

                    if not dragging then
                        Animator.Tween(row, Tokens.Motion.Base, {
                            BackgroundColor3 = theme:Get('Element'),
                        })
                    end
                end)
                trackHit.MouseEnter:Connect(function()
                    trackHovered = true

                    Animator.Tween(trackStroke, Tokens.Motion.Fast, {
                        Color = theme:Get('StrokeBright'),
                        Transparency = 0.18,
                    })

                    if not dragging then
                        Animator.Tween(thumb, Tokens.Motion.Fast, {
                            Size = UDim2.fromOffset(15, 15),
                        })
                    end
                end)
                trackHit.MouseLeave:Connect(function()
                    trackHovered = false

                    if not dragging then
                        Animator.Tween(trackStroke, Tokens.Motion.Base, {
                            Color = theme:Get('Stroke'),
                            Transparency = 0.45,
                        })
                        Animator.Tween(thumb, Tokens.Motion.Fast, {
                            Size = UDim2.fromOffset(14, 14),
                        })
                    end
                end)

                local function setFromX(absX: number, fireCallback: boolean)
                    local width = track.AbsoluteSize.X

                    if width <= 0 then
                        return
                    end

                    local pct = math.clamp((absX - track.AbsolutePosition.X) / width, 0, 1)
                    local nextVal = clampSnap(minVal + pct * (maxVal - minVal))

                    if nextVal ~= value then
                        value = nextVal

                        render(false)

                        if fireCallback and cfg.Callback then
                            cfg.Callback(value)
                        end
                    end
                end

                trackHit.InputBegan:Connect(function(input: InputObject)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        disconnectDrag()

                        dragging = true

                        Animator.Tween(thumb, Tokens.Motion.Fast, {
                            Size = UDim2.fromOffset(17, 17),
                        })
                        setFromX(input.Position.X, not commitOnRelease)

                        moveConn = UserInputService.InputChanged:Connect(function(
                            chg: InputObject
                        )
                            if not dragging then
                                return
                            end
                            if chg.UserInputType == Enum.UserInputType.MouseMovement or chg.UserInputType == Enum.UserInputType.Touch then
                                setFromX(chg.Position.X, not commitOnRelease)
                            end
                        end)
                        endConn = UserInputService.InputEnded:Connect(function(
                            ended: InputObject
                        )
                            if ended.UserInputType == Enum.UserInputType.MouseButton1 or ended.UserInputType == Enum.UserInputType.Touch then
                                disconnectDrag()
                                Animator.Tween(thumb, Tokens.Motion.Fast, {
                                    Size = UDim2.fromOffset(trackHovered and 15 or 14, trackHovered and 15 or 14),
                                })

                                if not trackHovered then
                                    Animator.Tween(trackStroke, Tokens.Motion.Base, {
                                        Color = theme:Get('Stroke'),
                                        Transparency = 0.45,
                                    })
                                end
                                if not rowHovered then
                                    Animator.Tween(row, Tokens.Motion.Base, {
                                        BackgroundColor3 = theme:Get('Element'),
                                    })
                                end
                                if commitOnRelease and cfg.Callback then
                                    cfg.Callback(value)
                                end
                            end
                        end)
                    end
                end)

                if editable and valChip:IsA('TextBox') then
                    valChip.Focused:Connect(function()
                        if bStroke then
                            Animator.Tween(bStroke, Tokens.Motion.Fast, {
                                Color = theme:Get('Accent'),
                                Transparency = 0.08,
                            })
                        end
                    end)
                    valChip.FocusLost:Connect(function()
                        if bStroke then
                            Animator.Tween(bStroke, Tokens.Motion.Base, {
                                Color = theme:Get('Stroke'),
                                Transparency = 0.4,
                            })
                        end

                        local numStr = valChip.Text:match('%-?%d+%.?%d*')
                        local parsed = numStr and tonumber(numStr) or nil

                        if parsed then
                            value = clampSnap(parsed)

                            render(true)

                            if cfg.Callback then
                                cfg.Callback(value)
                            end
                        else
                            valChip.Text = tostring(value)
                        end
                    end)
                end

                local handle = {Frame = row}

                function handle:Set(v: number, silent: boolean?)
                    value = clampSnap(tonumber(v) or value)

                    render(true)

                    if not silent and cfg.Callback then
                        cfg.Callback(value)
                    end
                end
                function handle:Get(): number
                    return value
                end

                return handle
            end
            function Controls.Dropdown(
                parent: Instance,
                window: any,
                theme: any,
                cfg: any
            )
                cfg = cfg or {}

                local name = tostring(cfg.Name or 'Dropdown')
                local items: {string} = {}

                if type(cfg.Items) == 'table' then
                    for _, it in ipairs(cfg.Items)do
                        table.insert(items, tostring(it))
                    end
                end

                local placeholder = tostring(cfg.StartingText or 'Select...')
                local emptyText = tostring(cfg.EmptyText or 'No items available')
                local stacked = cfg.Stacked == true
                local selected: string?
                local initialVal = cfg.Value

                if initialVal == nil then
                    initialVal = cfg.Default
                end
                if initialVal ~= nil then
                    selected = tostring(initialVal)
                elseif cfg.StartingText ~= nil then
                    local stStr = tostring(cfg.StartingText)

                    for _, it in ipairs(items)do
                        if it == stStr then
                            selected = stStr

                            break
                        end
                    end
                end

                local row = makeRow(parent, stacked and 64 or 42, theme, name)

                row.Name = 'Dropdown'

                Primitives.Padding(row, 6, 10, 6, 12)

                local lbl = Instance.new('TextLabel')

                lbl.Size = stacked and UDim2.new(1, 0, 0, 18) or UDim2.new(0.46, 
-6, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = name
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextTruncate = Enum.TextTruncate.AtEnd
                lbl.ZIndex = Tokens.Layer.Content + 2

                Tokens.Typeset(lbl, 'Label', theme:Get('Text'))

                lbl.Parent = row

                theme:Bind(lbl, 'TextColor3', 'Text')

                local trigger = Instance.new('TextButton')

                trigger.Size = stacked and UDim2.new(1, 0, 0, 28) or UDim2.new(0.54, 0, 0, 28)
                trigger.Position = stacked and UDim2.new(0, 0, 1, -28) or UDim2.new(0.46, 0, 0.5, 
-14)
                trigger.BackgroundColor3 = theme:Get('Card')
                trigger.BorderSizePixel = 0
                trigger.Text = ''
                trigger.AutoButtonColor = false
                trigger.ZIndex = Tokens.Layer.Content + 3
                trigger.Parent = row

                Primitives.Corner(trigger, Tokens.Radius.Chip)

                local trigStroke = Primitives.Stroke(trigger, theme:Get('Stroke'), 1, 0.35)

                theme:Bind(trigger, 'BackgroundColor3', 'Card')
                theme:Bind(trigStroke, 'Color', 'Stroke')

                local valLabel = Instance.new('TextLabel')

                valLabel.Size = UDim2.new(1, -26, 1, 0)
                valLabel.Position = UDim2.new(0, 10, 0, 0)
                valLabel.BackgroundTransparency = 1
                valLabel.Text = selected or placeholder
                valLabel.TextXAlignment = Enum.TextXAlignment.Left
                valLabel.TextTruncate = Enum.TextTruncate.AtEnd
                valLabel.ZIndex = Tokens.Layer.Content + 4

                local initColorKey = selected ~= nil and 'Text' or 'SubText'

                Tokens.Typeset(valLabel, 'Body', theme:Get(initColorKey))

                valLabel.Parent = trigger

                theme:Bind(valLabel, 'TextColor3', initColorKey)

                local chev = Instance.new('TextLabel')

                chev.Size = UDim2.fromOffset(18, 18)
                chev.AnchorPoint = Vector2.new(1, 0.5)
                chev.Position = UDim2.new(1, -6, 0.5, 0)
                chev.BackgroundTransparency = 1
                chev.Text = '\u{25be}'
                chev.ZIndex = Tokens.Layer.Content + 4

                Tokens.Typeset(chev, 'Caption', theme:Get('MutedText'))

                chev.Parent = trigger

                theme:Bind(chev, 'TextColor3', 'MutedText')

                local scrollParent: ScrollingFrame?

                do
                    local cur: Instance? = parent

                    while cur do
                        if cur:IsA('ScrollingFrame') then
                            scrollParent = cur

                            break
                        end

                        cur = cur.Parent
                    end
                end

                local open = false
                local popup: Frame?
                local popupShadow: Frame?
                local outsideConn: RBXScriptConnection?
                local scrollConn: RBXScriptConnection?
                local activeRebuild: ((string) -> ())?
                local currentFilter = ''

                local function disconnectPopupConns()
                    if outsideConn then
                        outsideConn:Disconnect()

                        outsideConn = nil
                    end
                    if scrollConn then
                        scrollConn:Disconnect()

                        scrollConn = nil
                    end
                end
                local function closePopup()
                    disconnectPopupConns()

                    activeRebuild = nil
                    currentFilter = ''

                    if not open then
                        return
                    end

                    open = false

                    if Animator.Alive(chev) then
                        Animator.Tween(chev, Tokens.Motion.Fast, {Rotation = 0})
                    end
                    if Animator.Alive(trigStroke) then
                        Animator.Tween(trigStroke, Tokens.Motion.Fast, {
                            Color = theme:Get('Stroke'),
                            Transparency = 0.35,
                        })
                    end
                    if Animator.Alive(trigger) then
                        Animator.Tween(trigger, Tokens.Motion.Fast, {
                            BackgroundColor3 = theme:Get('Card'),
                        })
                    end
                    if popupShadow and Animator.Alive(popupShadow) then
                        popupShadow:Destroy()
                    end

                    popupShadow = nil

                    if popup and Animator.Alive(popup) then
                        popup:Destroy()
                    end

                    popup = nil

                    if window._activePopupClose == closePopup then
                        window._activePopupClose = nil
                    end
                end

                row.Destroying:Connect(closePopup)
                trigger.MouseEnter:Connect(function()
                    if not open then
                        Animator.Tween(trigger, Tokens.Motion.Fast, {
                            BackgroundColor3 = theme:Get('ElementHover'),
                        })
                        Animator.Tween(trigStroke, Tokens.Motion.Fast, {
                            Color = theme:Get('StrokeBright'),
                            Transparency = 0.2,
                        })
                    end
                end)
                trigger.MouseLeave:Connect(function()
                    if not open then
                        Animator.Tween(trigger, Tokens.Motion.Base, {
                            BackgroundColor3 = theme:Get('Card'),
                        })
                        Animator.Tween(trigStroke, Tokens.Motion.Base, {
                            Color = theme:Get('Stroke'),
                            Transparency = 0.35,
                        })
                    end
                end)

                local function selectItem(choice: string?, silent: boolean?)
                    if choice == nil then
                        selected = nil

                        if Animator.Alive(valLabel) then
                            valLabel.Text = placeholder

                            theme:Bind(valLabel, 'TextColor3', 'SubText')
                        end

                        closePopup()

                        if not silent and cfg.Callback then
                            cfg.Callback(nil)
                        end

                        return
                    end

                    local choiceStr = tostring(choice)

                    selected = choiceStr

                    if Animator.Alive(valLabel) then
                        valLabel.Text = choiceStr

                        theme:Bind(valLabel, 'TextColor3', 'Text')
                    end

                    closePopup()

                    if not silent and cfg.Callback then
                        cfg.Callback(choiceStr)
                    end
                end

                local handle: any = {Frame = row}

                local function openPopup()
                    if window._activePopupClose then
                        window._activePopupClose()
                    end
                    if not Animator.Alive(window.Overlay) or not Animator.Alive(window.Main) then
                        return
                    end
                    if type(cfg.OnOpen) == 'function' then
                        pcall(cfg.OnOpen, handle)
                    end
                    if not Animator.Alive(window.Overlay) or not Animator.Alive(window.Main) then
                        return
                    end

                    open = true
                    window._activePopupClose = closePopup

                    Animator.Tween(chev, Tokens.Motion.Fast, {Rotation = 180})
                    Animator.Tween(trigStroke, Tokens.Motion.Fast, {
                        Color = theme:Get('Accent'),
                        Transparency = 0.1,
                    })

                    local scale = (window.EffectiveScale and window.EffectiveScale > 0) and window.EffectiveScale or 1
                    local mainPos = window.Main.AbsolutePosition
                    local mainSize = window.Main.AbsoluteSize / scale
                    local trigPos = (trigger.AbsolutePosition - mainPos) / scale
                    local trigSize = trigger.AbsoluteSize / scale
                    local showSearch = cfg.Searchable == true or (cfg.Searchable ~= false and #items >= 6)
                    local searchH = showSearch and 34 or 0
                    local listH = math.clamp(math.max(1, #items) * 30 + 12, 42, 180)
                    local popH = searchH + listH + 4
                    local maxPopW = math.max(180, mainSize.X - 16)
                    local popW = math.clamp(math.max(trigSize.X, 230), 180, maxPopW)
                    local x = math.clamp(trigPos.X, 8, math.max(8, mainSize.X - popW - 8))
                    local gap = 4
                    local topBarInset = 44
                    local spaceBelow = math.max(0, (mainSize.Y - 8) - (trigPos.Y + trigSize.Y + gap))
                    local spaceAbove = math.max(0, trigPos.Y - (topBarInset + 8))
                    local openUp = (popH > spaceBelow) and (spaceAbove > spaceBelow)
                    local bestSpace = openUp and spaceAbove or spaceBelow

                    popH = math.min(popH, math.max(96, bestSpace))

                    if popH > bestSpace then
                        popH = math.max(42, bestSpace)
                    end

                    local y = openUp and math.max(topBarInset + 4, trigPos.Y - gap - popH) or (trigPos.Y + trigSize.Y + gap)
                    local shadow = Instance.new('Frame')

                    shadow.Name = 'DropdownShadow'
                    shadow.Position = UDim2.fromOffset(x - 4, y - 2)
                    shadow.Size = UDim2.fromOffset(popW + 8, popH + 8)
                    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
                    shadow.BackgroundTransparency = 0.76
                    shadow.BorderSizePixel = 0
                    shadow.ZIndex = Tokens.Layer.Popup + 1
                    shadow.Parent = window.Overlay

                    Primitives.Corner(shadow, Tokens.Radius.Card + 3)

                    popupShadow = shadow

                    local bgKey = theme.Colors.Surface and 'Surface' or 'Card'
                    local p = Instance.new('Frame')

                    p.Name = 'DropdownPopup'
                    p.Position = UDim2.fromOffset(x, y)
                    p.Size = UDim2.fromOffset(popW, popH)
                    p.BackgroundColor3 = theme:Get(bgKey)
                    p.BorderSizePixel = 0
                    p.ClipsDescendants = true
                    p.Active = true
                    p.ZIndex = Tokens.Layer.Popup + 2
                    p.Parent = window.Overlay

                    Primitives.Corner(p, Tokens.Radius.Card)

                    local pStroke = Primitives.Stroke(p, theme:Get('StrokeBright'), 1, 0.12)

                    theme:Bind(p, 'BackgroundColor3', bgKey)
                    theme:Bind(pStroke, 'Color', 'StrokeBright')

                    popup = p

                    local list = Instance.new('ScrollingFrame')

                    list.Size = UDim2.new(1, -4, 1, -(searchH + 6))
                    list.Position = UDim2.fromOffset(0, searchH)
                    list.BackgroundTransparency = 1
                    list.BorderSizePixel = 0
                    list.ScrollBarThickness = 4
                    list.ScrollBarImageColor3 = theme:Get('SubText')
                    list.ScrollBarImageTransparency = 0.45
                    list.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
                    list.CanvasSize = UDim2.fromOffset(0, 0)
                    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
                    list.ZIndex = Tokens.Layer.Popup + 3
                    list.Parent = p

                    Primitives.Padding(list, 6, 6, 6, 6)
                    theme:Bind(list, 'ScrollBarImageColor3', 'SubText')

                    local ll = Instance.new('UIListLayout')

                    ll.Padding = UDim.new(0, 3)
                    ll.SortOrder = Enum.SortOrder.LayoutOrder
                    ll.Parent = list

                    local function rebuild(filter: string)
                        currentFilter = filter
                        list.CanvasPosition = Vector2.zero

                        for _, child in ipairs(list:GetChildren())do
                            if child:IsA('GuiObject') then
                                child:Destroy()
                            end
                        end

                        local q = string.lower(filter)
                        local shown = 0

                        for idx, item in ipairs(items)do
                            if q == '' or string.find(string.lower(item), q, 1, true) ~= nil then
                                shown += 1

                                local isSel = (item == selected)
                                local opt = Instance.new('TextButton')

                                opt.Size = UDim2.new(1, 0, 0, 27)
                                opt.BackgroundColor3 = isSel and theme:Get('AccentSoft') or theme:Get('Element')
                                opt.BackgroundTransparency = isSel and 0.15 or 1
                                opt.BorderSizePixel = 0
                                opt.Text = ''
                                opt.AutoButtonColor = false
                                opt.LayoutOrder = idx
                                opt.ZIndex = Tokens.Layer.Popup + 4
                                opt.Parent = list

                                Primitives.Corner(opt, Tokens.Radius.Chip)

                                local optLbl = Instance.new('TextLabel')

                                optLbl.Size = UDim2.new(1, -16, 1, 0)
                                optLbl.Position = UDim2.new(0, 8, 0, 0)
                                optLbl.BackgroundTransparency = 1
                                optLbl.Text = item
                                optLbl.TextXAlignment = Enum.TextXAlignment.Left
                                optLbl.TextTruncate = Enum.TextTruncate.AtEnd
                                optLbl.ZIndex = Tokens.Layer.Popup + 5

                                Tokens.Typeset(optLbl, 'Body', isSel and theme:Get('Accent') or theme:Get('Text'))

                                optLbl.Parent = opt

                                opt.MouseEnter:Connect(function()
                                    if not isSel then
                                        Animator.Tween(opt, Tokens.Motion.Fast, {
                                            BackgroundTransparency = 0,
                                            BackgroundColor3 = theme:Get('ElementHover'),
                                        })
                                    end
                                end)
                                opt.MouseLeave:Connect(function()
                                    if not isSel then
                                        Animator.Tween(opt, Tokens.Motion.Fast, {BackgroundTransparency = 1})
                                    end
                                end)
                                opt.MouseButton1Click:Connect(function()
                                    selectItem(item, false)
                                end)
                            end
                        end

                        if shown == 0 then
                            local empty = Instance.new('TextLabel')

                            empty.Size = UDim2.new(1, 0, 0, 28)
                            empty.BackgroundTransparency = 1
                            empty.Text = #items == 0 and emptyText or 'No matches'
                            empty.ZIndex = Tokens.Layer.Popup + 4

                            Tokens.Typeset(empty, 'Caption', theme:Get('MutedText'))

                            empty.Parent = list
                        end
                    end

                    activeRebuild = rebuild

                    if showSearch then
                        local searchWrap = Instance.new('Frame')

                        searchWrap.Size = UDim2.new(1, 0, 0, searchH)
                        searchWrap.BackgroundTransparency = 1
                        searchWrap.ZIndex = Tokens.Layer.Popup + 4
                        searchWrap.Parent = p

                        Primitives.Padding(searchWrap, 6, 6, 2, 6)

                        local box = Instance.new('TextBox')

                        box.Size = UDim2.fromScale(1, 1)
                        box.BackgroundColor3 = theme:Get('Element')
                        box.BorderSizePixel = 0
                        box.Text = ''
                        box.PlaceholderText = 'Filter...'
                        box.ClearTextOnFocus = false
                        box.TextXAlignment = Enum.TextXAlignment.Left
                        box.ZIndex = Tokens.Layer.Popup + 5

                        Tokens.Typeset(box, 'Body', theme:Get('Text'))

                        box.PlaceholderColor3 = theme:Get('MutedText')
                        box.Parent = searchWrap

                        Primitives.Corner(box, Tokens.Radius.Chip)
                        Primitives.Padding(box, 0, 8, 0, 8)

                        local boxStroke = Primitives.Stroke(box, theme:Get('Stroke'), 1, 0.45)

                        theme:Bind(box, 'BackgroundColor3', 'Element')
                        theme:Bind(box, 'TextColor3', 'Text')
                        theme:Bind(box, 'PlaceholderColor3', 'MutedText')
                        theme:Bind(boxStroke, 'Color', 'Stroke')
                        box.Focused:Connect(function()
                            Animator.Tween(boxStroke, Tokens.Motion.Fast, {
                                Color = theme:Get('Accent'),
                                Transparency = 0.1,
                            })
                        end)
                        box.FocusLost:Connect(function()
                            Animator.Tween(boxStroke, Tokens.Motion.Base, {
                                Color = theme:Get('Stroke'),
                                Transparency = 0.45,
                            })
                        end)
                        box:GetPropertyChangedSignal('Text'):Connect(function()
                            rebuild(box.Text)
                        end)
                    end

                    rebuild('')
                    p.Destroying:Connect(function()
                        disconnectPopupConns()

                        if shadow and Animator.Alive(shadow) then
                            shadow:Destroy()
                        end
                    end)

                    if scrollParent and Animator.Alive(scrollParent) then
                        scrollConn = scrollParent:GetPropertyChangedSignal('CanvasPosition'):Connect(closePopup)
                    end

                    outsideConn = UserInputService.InputBegan:Connect(function(
                        input: InputObject
                    )
                        if not open or not popup or not Animator.Alive(popup) then
                            closePopup()

                            return
                        end
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            local pos = input.Position
                            local inPopup = pos.X >= popup.AbsolutePosition.X and pos.X <= popup.AbsolutePosition.X + popup.AbsoluteSize.X and pos.Y >= popup.AbsolutePosition.Y and pos.Y <= popup.AbsolutePosition.Y + popup.AbsoluteSize.Y
                            local inTrig = pos.X >= trigger.AbsolutePosition.X and pos.X <= trigger.AbsolutePosition.X + trigger.AbsoluteSize.X and pos.Y >= trigger.AbsolutePosition.Y and pos.Y <= trigger.AbsolutePosition.Y + trigger.AbsoluteSize.Y

                            if not inPopup and not inTrig then
                                closePopup()
                            end
                        elseif input.KeyCode == Enum.KeyCode.Escape then
                            closePopup()
                        end
                    end)
                end

                trigger.MouseButton1Click:Connect(function()
                    if open then
                        closePopup()
                    else
                        openPopup()
                    end
                end)

                function handle:Clear()
                    table.clear(items)

                    selected = nil

                    if Animator.Alive(valLabel) then
                        valLabel.Text = placeholder

                        theme:Bind(valLabel, 'TextColor3', 'SubText')
                    end

                    closePopup()
                end
                function handle:AddItems(listToAdd: {any})
                    if type(listToAdd) ~= 'table' then
                        return
                    end

                    for _, it in ipairs(listToAdd)do
                        table.insert(items, tostring(it))
                    end
                end
                function handle:Refresh(
                    newItems: {any},
                    keepSelection: boolean?
                )
                    table.clear(items)

                    if type(newItems) == 'table' then
                        for _, it in ipairs(newItems)do
                            table.insert(items, tostring(it))
                        end
                    end
                    if selected ~= nil then
                        local stillExists = false

                        if keepSelection ~= false then
                            for _, it in ipairs(items)do
                                if it == selected then
                                    stillExists = true

                                    break
                                end
                            end
                        end
                        if not stillExists then
                            selected = nil

                            if Animator.Alive(valLabel) then
                                valLabel.Text = placeholder

                                theme:Bind(valLabel, 'TextColor3', 'SubText')
                            end
                        end
                    end
                    if open and activeRebuild then
                        activeRebuild(currentFilter)
                    end
                end
                function handle:Set(choice: string?, silent: boolean?)
                    selectItem(choice, silent)
                end
                function handle:Get(): string?
                    return selected
                end

                return handle
            end
            function Controls.Textbox(
                parent: Instance,
                _window: any,
                theme: any,
                cfg: any
            )
                cfg = cfg or {}

                local name = tostring(cfg.Name or 'Input')
                local stacked = cfg.Stacked == true
                local row = makeRow(parent, stacked and 64 or 42, theme, name)

                row.Name = 'Textbox'

                Primitives.Padding(row, 6, 10, 6, 12)

                local lbl = Instance.new('TextLabel')

                lbl.Size = stacked and UDim2.new(1, 0, 0, 18) or UDim2.new(0.45, 
-6, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = name
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextTruncate = Enum.TextTruncate.AtEnd
                lbl.ZIndex = Tokens.Layer.Content + 2

                Tokens.Typeset(lbl, 'Label', theme:Get('Text'))

                lbl.Parent = row

                theme:Bind(lbl, 'TextColor3', 'Text')

                local box = Instance.new('TextBox')

                box.Size = stacked and UDim2.new(1, 0, 0, 28) or UDim2.new(0.55, 0, 0, 28)
                box.Position = stacked and UDim2.new(0, 0, 1, -28) or UDim2.new(0.45, 0, 0.5, 
-14)
                box.BackgroundColor3 = theme:Get('Card')
                box.BorderSizePixel = 0
                box.Text = tostring(cfg.Default or '')
                box.PlaceholderText = tostring(cfg.Placeholder or '')
                box.ClearTextOnFocus = false
                box.TextXAlignment = Enum.TextXAlignment.Left
                box.TextTruncate = Enum.TextTruncate.AtEnd
                box.ZIndex = Tokens.Layer.Content + 3

                Tokens.Typeset(box, 'Body', theme:Get('Text'))

                box.PlaceholderColor3 = theme:Get('MutedText')
                box.Parent = row

                Primitives.Corner(box, Tokens.Radius.Chip)
                Primitives.Padding(box, 0, 8, 0, 8)

                local bStroke = Primitives.Stroke(box, theme:Get('Stroke'), 1, 0.35)

                theme:Bind(box, 'BackgroundColor3', 'Card')
                theme:Bind(box, 'TextColor3', 'Text')
                theme:Bind(box, 'PlaceholderColor3', 'MutedText')
                theme:Bind(bStroke, 'Color', 'Stroke')
                box.Focused:Connect(function()
                    Animator.Tween(bStroke, Tokens.Motion.Fast, {
                        Color = theme:Get('Accent'),
                        Transparency = 0.08,
                    })
                end)
                box.FocusLost:Connect(function()
                    Animator.Tween(bStroke, Tokens.Motion.Base, {
                        Color = theme:Get('Stroke'),
                        Transparency = 0.35,
                    })

                    if cfg.Callback then
                        cfg.Callback(box.Text)
                    end
                end)

                local handle = {
                    Frame = row,
                    Input = box,
                }

                function handle:Set(text: string, silent: boolean?)
                    if Animator.Alive(box) then
                        box.Text = tostring(text or '')
                    end
                    if not silent and cfg.Callback then
                        cfg.Callback(box.Text)
                    end
                end
                function handle:Get(): string
                    return Animator.Alive(box) and box.Text or ''
                end

                return handle
            end
            function Controls.Keybind(
                parent: Instance,
                window: any,
                theme: any,
                cfg: any
            )
                cfg = cfg or {}

                local name = tostring(cfg.Name or 'Keybind')
                local currentKey: Enum.KeyCode? = cfg.Keybind
                local allowClear = cfg.AllowClear == true
                local listening = false
                local activeToken: any
                local row = makeRow(parent, 42, theme, name)

                row.Name = 'Keybind'

                Primitives.Padding(row, 6, 10, 6, 12)

                local lbl = Instance.new('TextLabel')

                lbl.Size = UDim2.new(1, -110, 1, 0)
                lbl.BackgroundTransparency = 1
                lbl.Text = name
                lbl.TextXAlignment = Enum.TextXAlignment.Left
                lbl.TextTruncate = Enum.TextTruncate.AtEnd
                lbl.ZIndex = Tokens.Layer.Content + 2

                Tokens.Typeset(lbl, 'Label', theme:Get('Text'))

                lbl.Parent = row

                theme:Bind(lbl, 'TextColor3', 'Text')

                local chip = Instance.new('TextButton')

                chip.Size = UDim2.fromOffset(96, 26)
                chip.AnchorPoint = Vector2.new(1, 0.5)
                chip.Position = UDim2.new(1, 0, 0.5, 0)
                chip.BackgroundColor3 = theme:Get('Card')
                chip.BorderSizePixel = 0
                chip.Text = currentKey and currentKey.Name or 'None'
                chip.AutoButtonColor = false
                chip.ZIndex = Tokens.Layer.Content + 3

                Tokens.Typeset(chip, 'Mono', theme:Get('Accent'))

                chip.Parent = row

                Primitives.Corner(chip, Tokens.Radius.Chip)

                local cStroke = Primitives.Stroke(chip, theme:Get('Stroke'), 1, 0.35)

                theme:Bind(chip, 'BackgroundColor3', 'Card')
                theme:Bind(chip, 'TextColor3', 'Accent')
                theme:Bind(cStroke, 'Color', 'Stroke')

                local function refreshChip()
                    if not Animator.Alive(chip) then
                        return
                    end

                    chip.Text = listening and 'Press key...' or (currentKey and currentKey.Name or 'None')

                    Animator.Tween(cStroke, Tokens.Motion.Fast, {
                        Color = listening and theme:Get('Accent') or theme:Get('Stroke'),
                        Transparency = listening and 0.05 or 0.35,
                    })
                end

                local listenConn: RBXScriptConnection?
                local cancelSelf: () -> ()

                local function stopListening()
                    listening = false

                    if listenConn then
                        listenConn:Disconnect()

                        listenConn = nil
                    end
                    if window._cancelKeybindCapture == cancelSelf then
                        window._cancelKeybindCapture = nil
                    end

                    local tok = activeToken

                    activeToken = nil

                    if tok then
                        task.defer(function()
                            if window._capturingKeybind == tok then
                                window._capturingKeybind = false
                            end
                        end)
                    end
                end

                cancelSelf = function()
                    stopListening()
                    refreshChip()
                end

                row.Destroying:Connect(stopListening)
                chip.MouseEnter:Connect(function()
                    if not listening then
                        Animator.Tween(chip, Tokens.Motion.Fast, {
                            BackgroundColor3 = theme:Get('ElementHover'),
                        })
                    end
                end)
                chip.MouseLeave:Connect(function()
                    if not listening then
                        Animator.Tween(chip, Tokens.Motion.Base, {
                            BackgroundColor3 = theme:Get('Card'),
                        })
                    end
                end)
                chip.MouseButton1Click:Connect(function()
                    if listening then
                        stopListening()
                        refreshChip()

                        return
                    end
                    if window._cancelKeybindCapture then
                        window._cancelKeybindCapture()
                    end

                    local tok = {}

                    activeToken = tok
                    listening = true
                    window._capturingKeybind = tok
                    window._cancelKeybindCapture = cancelSelf

                    refreshChip()

                    listenConn = UserInputService.InputBegan:Connect(function(
                        input: InputObject,
                        gpe: boolean
                    )
                        if not listening then
                            return
                        end
                        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
                            stopListening()
                            refreshChip()

                            return
                        end
                        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                            local pos = input.Position
                            local inChip = Animator.Alive(chip) and pos.X >= chip.AbsolutePosition.X and pos.X <= chip.AbsolutePosition.X + chip.AbsoluteSize.X and pos.Y >= chip.AbsolutePosition.Y and pos.Y <= chip.AbsolutePosition.Y + chip.AbsoluteSize.Y

                            if not inChip then
                                stopListening()
                                refreshChip()
                            end

                            return
                        end
                        if gpe then
                            return
                        end
                        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                            stopListening()

                            if allowClear and (input.KeyCode == Enum.KeyCode.Backspace or input.KeyCode == Enum.KeyCode.Delete) then
                                currentKey = nil
                            else
                                currentKey = input.KeyCode
                            end

                            local cb = cfg.OnBind or cfg.Callback

                            if cb then
                                cb(currentKey)
                            end

                            refreshChip()
                        end
                    end)
                end)

                local handle = {Frame = row}

                function handle:Set(keyCode: Enum.KeyCode?, silent: boolean?)
                    stopListening()

                    currentKey = keyCode

                    refreshChip()

                    if not silent then
                        local cb = cfg.OnBind or cfg.Callback

                        if cb then
                            cb(currentKey)
                        end
                    end
                end
                function handle:Get(): Enum.KeyCode?
                    return currentKey
                end

                return handle
            end

            return Controls
        end

        function __POLOSKALIB_MODULES.g(): typeof(__modImpl())
            local v = __POLOSKALIB_MODULES.cache.g

            if not v then
                v = {
                    c = __modImpl(),
                }
                __POLOSKALIB_MODULES.cache.g = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Tokens = __POLOSKALIB_MODULES.a()
            local Animator = __POLOSKALIB_MODULES.d()
            local Primitives = __POLOSKALIB_MODULES.e()
            local Controls = __POLOSKALIB_MODULES.g()
            local Tab = {}

            function Tab.Create(window: any, config: any)
                config = config or {}

                local theme = window._theme
                local name = tostring(config.Name or 'Tab')
                local tab: any = {
                    Name = name,
                    _active = false,
                    _window = window,
                }
                local btn = Instance.new('TextButton')

                btn.Name = 'Tab_' .. name
                btn.Size = UDim2.new(1, 0, 0, 34)
                btn.BackgroundColor3 = theme:Get('Element')
                btn.BackgroundTransparency = 1
                btn.BorderSizePixel = 0
                btn.Text = ''
                btn.AutoButtonColor = false
                btn.LayoutOrder = #window.Tabs + 1
                btn.ZIndex = Tokens.Layer.Content + 2
                btn.Parent = window.TabList

                Primitives.Corner(btn, Tokens.Radius.Control)

                local btnStroke = Primitives.Stroke(btn, theme:Get('Accent'), 1, 1)

                theme:Bind(btnStroke, 'Color', 'Accent')

                local mark = Instance.new('Frame')

                mark.Name = 'Mark'
                mark.AnchorPoint = Vector2.new(0, 0.5)
                mark.Position = UDim2.new(0, 5, 0.5, 0)
                mark.Size = UDim2.fromOffset(3, 0)
                mark.BackgroundColor3 = Color3.new(1, 1, 1)
                mark.BorderSizePixel = 0
                mark.ZIndex = Tokens.Layer.Content + 3
                mark.Parent = btn

                Primitives.Corner(mark, 2)

                local markGrad = Primitives.Gradient(mark, theme:Get('Accent'), theme:Get('AccentSecondary'), 90)

                theme:BindGradient(markGrad, 'Accent', 'AccentSecondary')

                local btnLabel = Instance.new('TextLabel')

                btnLabel.Size = UDim2.new(1, -22, 1, 0)
                btnLabel.Position = UDim2.new(0, 14, 0, 0)
                btnLabel.BackgroundTransparency = 1
                btnLabel.Text = name
                btnLabel.TextXAlignment = Enum.TextXAlignment.Left
                btnLabel.TextTruncate = Enum.TextTruncate.AtEnd
                btnLabel.ZIndex = Tokens.Layer.Content + 3

                Tokens.Typeset(btnLabel, 'Label', theme:Get('SubText'))

                btnLabel.Parent = btn

                local badge = Instance.new('TextLabel')

                badge.Name = 'Badge'
                badge.AnchorPoint = Vector2.new(1, 0.5)
                badge.Position = UDim2.new(1, -8, 0.5, 0)
                badge.Size = UDim2.fromOffset(0, 16)
                badge.AutomaticSize = Enum.AutomaticSize.X
                badge.BackgroundColor3 = theme:Get('Card')
                badge.BorderSizePixel = 0
                badge.Text = ''
                badge.Visible = false
                badge.ZIndex = Tokens.Layer.Content + 3

                Tokens.Typeset(badge, 'Caption', theme:Get('Success'))

                badge.Parent = btn

                Primitives.Corner(badge, Tokens.Radius.Pill)
                Primitives.Padding(badge, 0, 5, 0, 5)

                local badgeConstraint = Instance.new('UISizeConstraint')

                badgeConstraint.MinSize = Vector2.new(18, 16)
                badgeConstraint.Parent = badge

                local badgeStroke = Primitives.Stroke(badge, theme:Get('Success'), 1, 0.45)

                theme:Bind(badge, 'BackgroundColor3', 'Card')
                theme:Bind(badge, 'TextColor3', 'Success')
                theme:Bind(badgeStroke, 'Color', 'Success')

                local activeBadgeCount = 0
                local searchMatchCount: number?

                local function refreshBadge()
                    if not Animator.Alive(badge) then
                        return
                    end
                    if searchMatchCount ~= nil then
                        badge.Visible = searchMatchCount > 0
                        badge.Text = tostring(searchMatchCount)
                        btnLabel.TextTransparency = searchMatchCount > 0 and 0 or 0.55

                        theme:Bind(badge, 'TextColor3', 'Warning')
                        theme:Bind(badgeStroke, 'Color', 'Warning')

                        badgeStroke.Transparency = 0.35
                    else
                        btnLabel.TextTransparency = 0
                        badge.Visible = activeBadgeCount > 0
                        badge.Text = tostring(activeBadgeCount)

                        theme:Bind(badge, 'TextColor3', 'Success')
                        theme:Bind(badgeStroke, 'Color', 'Success')

                        badgeStroke.Transparency = 0.45
                    end
                    if Animator.Alive(btnLabel) then
                        btnLabel.Size = badge.Visible and UDim2.new(1, -46, 1, 0) or UDim2.new(1, 
-22, 1, 0)
                    end
                end

                local page = Instance.new('ScrollingFrame')

                page.Name = 'Page_' .. name
                page.Size = UDim2.new(1, -4, 1, -8)
                page.Position = UDim2.fromOffset(0, 0)
                page.BackgroundTransparency = 1
                page.BorderSizePixel = 0
                page.ScrollBarThickness = 4
                page.ScrollBarImageColor3 = theme:Get('SubText')
                page.ScrollBarImageTransparency = 0.45
                page.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
                page.CanvasSize = UDim2.fromOffset(0, 0)
                page.AutomaticCanvasSize = Enum.AutomaticSize.None
                page.ScrollingDirection = Enum.ScrollingDirection.Y
                page.Active = true
                page.Visible = false
                page.ZIndex = Tokens.Layer.Content
                page.Parent = window.Container

                Primitives.Padding(page, 12, 14, 14, 14)
                theme:Bind(page, 'ScrollBarImageColor3', 'SubText')

                local pageLayout = Instance.new('UIListLayout')

                pageLayout.Padding = UDim.new(0, 12)
                pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
                pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
                pageLayout.Parent = page

                local emptyState = Instance.new('TextLabel')

                emptyState.Name = 'SearchEmptyState'
                emptyState.Size = UDim2.new(1, 0, 0, 56)
                emptyState.BackgroundTransparency = 1
                emptyState.Text = ''
                emptyState.TextXAlignment = Enum.TextXAlignment.Center
                emptyState.TextYAlignment = Enum.TextYAlignment.Center
                emptyState.TextWrapped = true
                emptyState.Visible = false
                emptyState.LayoutOrder = -1
                emptyState.ZIndex = Tokens.Layer.Content + 2

                Tokens.Typeset(emptyState, 'Body', theme:Get('MutedText'))

                emptyState.Parent = page

                theme:Bind(emptyState, 'TextColor3', 'MutedText')

                local function syncCanvas()
                    if not Animator.Alive(page) or not Animator.Alive(pageLayout) then
                        return
                    end

                    local s = (window.EffectiveScale and window.EffectiveScale > 0) and window.EffectiveScale or 1

                    page.CanvasSize = UDim2.fromOffset(0, math.max(0, pageLayout.AbsoluteContentSize.Y / s + 28))
                end

                pageLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(syncCanvas)
                task.defer(syncCanvas)

                local function paintTabButton(animated: boolean)
                    if not Animator.Alive(btn) then
                        return
                    end

                    local active = tab._active
                    local bgColor = active and theme:Get('Element') or theme:Get('Element')
                    local bgTrans = active and 0.15 or 1
                    local txtColor = active and theme:Get('Text') or theme:Get('SubText')
                    local stTrans = active and 0.55 or 1
                    local markSize = active and UDim2.fromOffset(3, 18) or UDim2.fromOffset(3, 0)

                    if animated then
                        Animator.Tween(btn, Tokens.Motion.Base, {
                            BackgroundColor3 = bgColor,
                            BackgroundTransparency = bgTrans,
                        })
                        Animator.Tween(btnLabel, Tokens.Motion.Base, {TextColor3 = txtColor})
                        Animator.Tween(btnStroke, Tokens.Motion.Base, {Transparency = stTrans})
                        Animator.Tween(mark, Tokens.Motion.Base, {Size = markSize})
                    else
                        btn.BackgroundColor3 = bgColor
                        btn.BackgroundTransparency = bgTrans
                        btnLabel.TextColor3 = txtColor
                        btnStroke.Transparency = stTrans
                        mark.Size = markSize
                    end
                end

                theme:OnChange(function()
                    if not Animator.Alive(btn) then
                        return false
                    end

                    paintTabButton(false)

                    return true
                end)

                local function activate()
                    if window._activePopupClose then
                        window._activePopupClose()
                    end

                    for _, other in ipairs(window.Tabs)do
                        if other ~= tab and other._active then
                            other._active = false
                            other._page.Visible = false

                            other._paintButton(true)
                        end
                    end

                    tab._active = true
                    page.Visible = true

                    paintTabButton(true)
                    task.defer(syncCanvas)
                end

                btn.MouseEnter:Connect(function()
                    if not tab._active then
                        Animator.Tween(btn, Tokens.Motion.Fast, {
                            BackgroundColor3 = theme:Get('ElementHover'),
                            BackgroundTransparency = 0.35,
                        })
                        Animator.Tween(btnLabel, Tokens.Motion.Fast, {
                            TextColor3 = theme:Get('Text'),
                        })
                    end
                end)
                btn.MouseLeave:Connect(function()
                    if not tab._active then
                        Animator.Tween(btn, Tokens.Motion.Base, {BackgroundTransparency = 1})
                        Animator.Tween(btnLabel, Tokens.Motion.Base, {
                            TextColor3 = theme:Get('SubText'),
                        })
                    end
                end)
                btn.MouseButton1Click:Connect(function()
                    tab._searchTabPicked = true

                    activate()
                end)

                local registeredGroups: {{Frame: Frame, Body: Frame, TitleLower: string, Collapsible: boolean, GetCollapsed: () -> boolean, SetCollapsed: (boolean) -> (), _wasCollapsed: boolean?}} = {}
                local registeredColumns: {{Frame: Frame, Left: Frame, Right: Frame}} = {}

                tab._page = page
                tab._activate = activate
                tab._paintButton = paintTabButton
                tab._syncCanvas = syncCanvas

                function tab:SetBadge(count: number)
                    activeBadgeCount = math.max(0, math.floor(count or 0))

                    refreshBadge()
                end
                function tab._setSearchCount(count: number?)
                    searchMatchCount = count

                    refreshBadge()
                end
                function tab._applySearch(query: string): number
                    local rawQuery = query or ''
                    local q = string.lower(rawQuery)
                    local matches = 0

                    if q == '' then
                        if Animator.Alive(emptyState) then
                            emptyState.Visible = false
                        end

                        for _, c in ipairs(registeredColumns)do
                            if Animator.Alive(c.Frame) then
                                c.Frame.Visible = true
                            end
                        end
                        for _, g in ipairs(registeredGroups)do
                            if Animator.Alive(g.Frame) then
                                g.Frame.Visible = true
                            end
                            if Animator.Alive(g.Body) then
                                for _, child in ipairs(g.Body:GetChildren())do
                                    if child:IsA('GuiObject') then
                                        child.Visible = true
                                    end
                                end
                            end
                            if g._wasCollapsed ~= nil then
                                local prevCollapsed = g._wasCollapsed

                                g._wasCollapsed = nil

                                g.SetCollapsed(prevCollapsed)
                            end
                        end

                        task.defer(syncCanvas)

                        return 0
                    end

                    local visibleGroups = 0

                    for _, g in ipairs(registeredGroups)do
                        if Animator.Alive(g.Frame) and Animator.Alive(g.Body) then
                            local titleHit = string.find(g.TitleLower, q, 1, true) ~= nil
                            local groupHits = 0

                            for _, child in ipairs(g.Body:GetChildren())do
                                if child:IsA('GuiObject') then
                                    local s = child:GetAttribute('SearchText')
                                    local hit = titleHit or (typeof(s) == 'string' and string.find(s, q, 1, true) ~= nil)

                                    child.Visible = hit

                                    if hit then
                                        groupHits += 1
                                    end
                                end
                            end

                            local showGroup = groupHits > 0 or titleHit

                            g.Frame.Visible = showGroup

                            if showGroup then
                                visibleGroups += 1

                                if g.Collapsible then
                                    if g._wasCollapsed == nil then
                                        g._wasCollapsed = g.GetCollapsed()
                                    end
                                    if g.GetCollapsed() then
                                        g.SetCollapsed(false)
                                    end
                                end
                            end

                            matches += groupHits
                        end
                    end
                    for _, c in ipairs(registeredColumns)do
                        if Animator.Alive(c.Frame) then
                            local anyVisible = false

                            for _, col in ipairs({
                                c.Left,
                                c.Right,
                            })do
                                if Animator.Alive(col) then
                                    for _, child in ipairs(col:GetChildren())do
                                        if child:IsA('GuiObject') and child.Visible then
                                            anyVisible = true

                                            break
                                        end
                                    end
                                end
                                if anyVisible then
                                    break
                                end
                            end

                            c.Frame.Visible = anyVisible
                        end
                    end

                    if Animator.Alive(emptyState) then
                        if matches == 0 and visibleGroups == 0 then
                            emptyState.Text = "No controls match '" .. rawQuery .. "'"
                            emptyState.Visible = true
                        else
                            emptyState.Visible = false
                        end
                    end

                    task.defer(syncCanvas)

                    return matches
                end
                function tab:Columns(cfg: any)
                    cfg = cfg or {}

                    local gap = tonumber(cfg.Gap) or 12
                    local row = Instance.new('Frame')

                    row.Name = 'Columns'
                    row.Size = UDim2.new(1, 0, 0, 0)
                    row.AutomaticSize = Enum.AutomaticSize.Y
                    row.BackgroundTransparency = 1
                    row.ZIndex = Tokens.Layer.Content
                    row.Parent = page

                    local function makeColumn(
                        colName: string,
                        posX: UDim2
                    ): Frame
                        local col = Instance.new('Frame')

                        col.Name = colName
                        col.Size = UDim2.new(0.5, -math.floor(gap / 2), 0, 0)
                        col.Position = posX
                        col.AutomaticSize = Enum.AutomaticSize.Y
                        col.BackgroundTransparency = 1
                        col.ZIndex = Tokens.Layer.Content
                        col.Parent = row

                        local cl = Instance.new('UIListLayout')

                        cl.Padding = UDim.new(0, 12)
                        cl.SortOrder = Enum.SortOrder.LayoutOrder
                        cl.Parent = col

                        cl:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(syncCanvas)

                        return col
                    end

                    local left = makeColumn('Left', UDim2.new(0, 0, 0, 0))
                    local right = makeColumn('Right', UDim2.new(0.5, math.ceil(gap / 2), 0, 0))

                    table.insert(registeredColumns, {
                        Frame = row,
                        Left = left,
                        Right = right,
                    })

                    return {
                        Frame = row,
                        Left = left,
                        Right = right,
                    }
                end
                function tab:Group(cfg: any)
                    cfg = cfg or {}

                    local groupName = tostring(cfg.Name or 'Group')
                    local targetParent = cfg.Parent or page
                    local collapsible = cfg.Collapsible == true
                    local collapsed = collapsible and cfg.Collapsed == true
                    local card = Instance.new('Frame')

                    card.Name = 'Group_' .. groupName
                    card.Size = UDim2.new(1, 0, 0, 0)
                    card.AutomaticSize = Enum.AutomaticSize.Y
                    card.BackgroundColor3 = theme:Get('Card')
                    card.BorderSizePixel = 0
                    card.ClipsDescendants = true
                    card.ZIndex = Tokens.Layer.Content + 1
                    card.Parent = targetParent

                    Primitives.Corner(card, Tokens.Radius.Card)

                    local cardStroke = Primitives.Stroke(card, theme:Get('Stroke'), 1, 0.58)

                    theme:Bind(card, 'BackgroundColor3', 'Card')
                    theme:Bind(cardStroke, 'Color', 'Stroke')

                    local cardLayout = Instance.new('UIListLayout')

                    cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    cardLayout.Parent = card

                    local header: GuiObject

                    if collapsible then
                        local headerBtn = Instance.new('TextButton')

                        headerBtn.Text = ''
                        headerBtn.AutoButtonColor = false
                        headerBtn.BackgroundColor3 = theme:Get('ElementHover')
                        headerBtn.BackgroundTransparency = 1
                        headerBtn.BorderSizePixel = 0

                        Primitives.Corner(headerBtn, Tokens.Radius.Card)
                        theme:Bind(headerBtn, 'BackgroundColor3', 'ElementHover')

                        header = headerBtn
                    else
                        local headerFrame = Instance.new('Frame')

                        headerFrame.BackgroundTransparency = 1
                        headerFrame.BorderSizePixel = 0
                        header = headerFrame
                    end

                    header.Name = 'Header'
                    header.Size = UDim2.new(1, 0, 0, 34)
                    header.LayoutOrder = 1
                    header.ZIndex = Tokens.Layer.Content + 2
                    header.Parent = card

                    local dot = Instance.new('Frame')

                    dot.Size = UDim2.fromOffset(6, 6)
                    dot.AnchorPoint = Vector2.new(0, 0.5)
                    dot.Position = UDim2.new(0, 12, 0.5, 0)
                    dot.BackgroundColor3 = theme:Get('Accent')
                    dot.BorderSizePixel = 0
                    dot.ZIndex = Tokens.Layer.Content + 3
                    dot.Parent = header

                    Primitives.Corner(dot, Tokens.Radius.Pill)
                    theme:Bind(dot, 'BackgroundColor3', 'Accent')

                    local titleLbl = Instance.new('TextLabel')

                    titleLbl.Size = UDim2.new(1, collapsible and -42 or -28, 1, 0)
                    titleLbl.Position = UDim2.new(0, 24, 0, 0)
                    titleLbl.BackgroundTransparency = 1
                    titleLbl.Text = groupName
                    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
                    titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
                    titleLbl.ZIndex = Tokens.Layer.Content + 3

                    Tokens.Typeset(titleLbl, 'Heading', theme:Get('Text'))

                    titleLbl.Parent = header

                    theme:Bind(titleLbl, 'TextColor3', 'Text')

                    local chev: TextLabel?

                    if collapsible then
                        local c = Instance.new('TextLabel')

                        c.Size = UDim2.fromOffset(18, 18)
                        c.AnchorPoint = Vector2.new(1, 0.5)
                        c.Position = UDim2.new(1, -10, 0.5, 0)
                        c.BackgroundTransparency = 1
                        c.Text = '\u{25be}'
                        c.Rotation = collapsed and -90 or 0
                        c.ZIndex = Tokens.Layer.Content + 3

                        Tokens.Typeset(c, 'Caption', theme:Get('MutedText'))

                        c.Parent = header

                        theme:Bind(c, 'TextColor3', 'MutedText')

                        chev = c
                    end

                    local divider = Instance.new('Frame')

                    divider.Size = UDim2.new(1, -20, 0, 1)
                    divider.Position = UDim2.new(0, 10, 1, -1)
                    divider.BackgroundColor3 = theme:Get('Stroke')
                    divider.BackgroundTransparency = 0.55
                    divider.BorderSizePixel = 0
                    divider.Visible = not collapsed
                    divider.ZIndex = Tokens.Layer.Content + 2
                    divider.Parent = header

                    theme:Bind(divider, 'BackgroundColor3', 'Stroke')

                    local body = Instance.new('Frame')

                    body.Name = 'Body'
                    body.Size = UDim2.new(1, 0, 0, 0)
                    body.AutomaticSize = Enum.AutomaticSize.Y
                    body.BackgroundTransparency = 1
                    body.Visible = not collapsed
                    body.LayoutOrder = 2
                    body.ZIndex = Tokens.Layer.Content + 1
                    body.Parent = card

                    Primitives.Padding(body, 8, 10, 10, 10)

                    local bodyLayout = Instance.new('UIListLayout')

                    bodyLayout.Padding = UDim.new(0, 7)
                    bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
                    bodyLayout.Parent = body

                    bodyLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(syncCanvas)

                    local function setCollapsed(v: boolean)
                        if not collapsible then
                            return
                        end

                        collapsed = v == true
                        body.Visible = not collapsed
                        divider.Visible = not collapsed

                        if chev and Animator.Alive(chev) then
                            Animator.Tween(chev, Tokens.Motion.Fast, {
                                Rotation = collapsed and -90 or 0,
                            })
                        end

                        task.defer(syncCanvas)
                    end

                    table.insert(registeredGroups, {
                        Frame = card,
                        Body = body,
                        TitleLower = string.lower(groupName),
                        Collapsible = collapsible,
                        GetCollapsed = function()
                            return collapsed
                        end,
                        SetCollapsed = setCollapsed,
                        _wasCollapsed = nil,
                    })

                    if collapsible then
                        local headerBtn = header::TextButton

                        headerBtn.MouseEnter:Connect(function()
                            Animator.Tween(headerBtn, Tokens.Motion.Fast, {BackgroundTransparency = 0.55})
                        end)
                        headerBtn.MouseLeave:Connect(function()
                            Animator.Tween(headerBtn, Tokens.Motion.Base, {BackgroundTransparency = 1})
                        end)
                        headerBtn.MouseButton1Click:Connect(function()
                            setCollapsed(not collapsed)
                        end)
                    end

                    local group: any = {
                        Frame = card,
                        Body = body,
                    }

                    function group:SetCollapsed(v: boolean)
                        setCollapsed(v)
                    end
                    function group:ToggleCollapsed()
                        setCollapsed(not collapsed)
                    end
                    function group:IsCollapsed(): boolean
                        return collapsed
                    end
                    function group:Section(text: string, opts: any?)
                        return Controls.Section(body, theme, text, opts)
                    end
                    function group:Metrics(items: any)
                        return Controls.Metrics(body, theme, items)
                    end
                    function group:Button(c: any)
                        return Controls.Button(body, window, theme, c)
                    end
                    function group:ButtonRow(c: any)
                        return Controls.ButtonRow(body, window, theme, c)
                    end
                    function group:Toggle(c: any)
                        return Controls.Toggle(body, window, theme, c)
                    end
                    function group:Slider(c: any)
                        return Controls.Slider(body, window, theme, c)
                    end
                    function group:Dropdown(c: any)
                        return Controls.Dropdown(body, window, theme, c)
                    end
                    function group:Textbox(c: any)
                        return Controls.Textbox(body, window, theme, c)
                    end
                    function group:Keybind(c: any)
                        return Controls.Keybind(body, window, theme, c)
                    end

                    return group
                end
                function tab:Section(text: string, opts: any?)
                    return Controls.Section(page, theme, text, opts)
                end
                function tab:Metrics(items: any)
                    return Controls.Metrics(page, theme, items)
                end
                function tab:Button(c: any)
                    return Controls.Button(page, window, theme, c)
                end
                function tab:ButtonRow(c: any)
                    return Controls.ButtonRow(page, window, theme, c)
                end
                function tab:Toggle(c: any)
                    return Controls.Toggle(page, window, theme, c)
                end
                function tab:Slider(c: any)
                    return Controls.Slider(page, window, theme, c)
                end
                function tab:Dropdown(c: any)
                    return Controls.Dropdown(page, window, theme, c)
                end
                function tab:Textbox(c: any)
                    return Controls.Textbox(page, window, theme, c)
                end
                function tab:Keybind(c: any)
                    return Controls.Keybind(page, window, theme, c)
                end

                table.insert(window.Tabs, tab)

                if #window.Tabs == 1 then
                    activate()
                end

                return tab
            end

            return Tab
        end

        function __POLOSKALIB_MODULES.h(): typeof(__modImpl())
            local v = __POLOSKALIB_MODULES.cache.h

            if not v then
                v = {
                    c = __modImpl(),
                }
                __POLOSKALIB_MODULES.cache.h = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Players = game:GetService('Players')
            local UserInputService = game:GetService('UserInputService')
            local Tokens = __POLOSKALIB_MODULES.a()
            local Theme = __POLOSKALIB_MODULES.b()
            local Maid = __POLOSKALIB_MODULES.c()
            local Animator = __POLOSKALIB_MODULES.d()
            local Primitives = __POLOSKALIB_MODULES.e()
            local Overlay = __POLOSKALIB_MODULES.f()
            local Tab = __POLOSKALIB_MODULES.h()
            local Window = {}

            Window.__index = Window

            function Window.Create(config: any)
                config = config or {}

                local theme = Theme.new(config.Theme or 'Poloska')
                local maid = Maid.new()
                local self: any = setmetatable({
                    Version = Tokens.Version,
                    ThemeName = theme.Name,
                    Tabs = {}::{any},
                    Visible = true,
                    Minimized = false,
                    UserScale = math.clamp(tonumber(config.Scale) or 1, UserInputService.TouchEnabled and 0.35 or 0.5, 1.25),
                    EffectiveScale = 1,
                    AutoScale = config.AutoScale ~= false,
                    ToggleButtonVisible = config.ShowToggleButton ~= false,
                    ToggleKey = config.ToggleKey or Enum.KeyCode.RightControl,
                    MinimizeKey = config.MinimizeKey,
                    _theme = theme,
                    _maid = maid,
                    _activePopupClose = nil,
                    _capturingKeybind = false,
                    _cancelKeybindCapture = nil,
                    _notificationsEnabled = config.NotificationsEnabled ~= false,
                }, Window)
                local icons = {
                    Minimize = (config.Icons and config.Icons.Minimize) or Tokens.DefaultIcons.Minimize,
                    Close = (config.Icons and config.Icons.Close) or Tokens.DefaultIcons.Close,
                    Restore = (config.Icons and config.Icons.Restore) or Tokens.DefaultIcons.Restore,
                    Launcher = config.ToggleButtonAsset or Tokens.DefaultIcons.Launcher,
                }
                local lp = Players.LocalPlayer
                local guiParent = lp:WaitForChild('PlayerGui')
                local old = guiParent:FindFirstChild('MinimalUI')

                if old then
                    old:Destroy()
                end

                local gui = Instance.new('ScreenGui')

                gui.Name = 'MinimalUI'
                gui.ResetOnSpawn = false
                gui.DisplayOrder = 2147483647
                gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
                gui.IgnoreGuiInset = true
                gui.Enabled = true

                gui:SetAttribute('RequiredInteractionUI', true)

                gui.Parent = guiParent
                self.Gui = gui

                gui.Destroying:Connect(function()
                    maid:Clean()
                    theme:Destroy()
                end)

                local size: UDim2 = config.Size or UDim2.fromOffset(680, 460)

                self.WindowSize = size

                local main = Instance.new('Frame')

                main.Name = 'Main'
                main.Size = UDim2.fromOffset(size.X.Offset, 0)
                main.AnchorPoint = Vector2.new(0.5, 0)
                main.BackgroundColor3 = theme:Get('Background')
                main.BorderSizePixel = 0
                main.ClipsDescendants = true
                main.ZIndex = Tokens.Layer.Content
                main.Parent = gui

                Primitives.Corner(main, Tokens.Radius.Window)

                local mainStroke = Primitives.Stroke(main, theme:Get('Stroke'), 1, 0.22)

                theme:Bind(main, 'BackgroundColor3', 'Background')
                theme:Bind(mainStroke, 'Color', 'Stroke')

                self.Main = main
                self.MainStroke = mainStroke

                local overlayLayer = Instance.new('Frame')

                overlayLayer.Name = 'OverlayLayer'
                overlayLayer.Size = UDim2.fromScale(1, 1)
                overlayLayer.BackgroundTransparency = 1
                overlayLayer.BorderSizePixel = 0
                overlayLayer.ZIndex = Tokens.Layer.Popup
                overlayLayer.Parent = main
                self.Overlay = overlayLayer

                local uiScale = Instance.new('UIScale')

                uiScale.Name = 'ResponsiveScale'
                uiScale.Scale = self.UserScale
                uiScale.Parent = main
                self.ScaleObject = uiScale

                local function syncActiveTabCanvas()
                    for _, t in ipairs(self.Tabs)do
                        if t._active and t._syncCanvas then
                            t._syncCanvas()
                        end
                    end
                end

                self._syncActiveTabCanvas = syncActiveTabCanvas

                local function clampMain(targetHeight: number?)
                    if not Animator.Alive(main) then
                        return
                    end

                    local h = targetHeight or (self.Minimized and 44 or size.Y.Offset)
                    local scaledSize = Vector2.new(size.X.Offset * self.EffectiveScale, h * self.EffectiveScale)

                    main.Position = Primitives.ClampToViewport(main, main.Position, scaledSize)
                end

                self._clampMain = clampMain

                local camConn: RBXScriptConnection?

                local function applyResponsiveScale()
                    if not Animator.Alive(main) or not Animator.Alive(uiScale) then
                        return
                    end

                    local effective = self.UserScale
                    local cam = workspace.CurrentCamera
                    local vp = cam and cam.ViewportSize
                    local mobileAuto = self.AutoScale and UserInputService.TouchEnabled and vp ~= nil

                    if mobileAuto and vp then
                        local fitX = (vp.X * 0.9) / math.max(size.X.Offset, 1)
                        local fitY = (vp.Y * 0.74) / math.max(size.Y.Offset, 1)

                        effective = math.min(effective, fitX, fitY, 0.78)
                    end

                    effective = math.clamp(effective, mobileAuto and 0.35 or 0.5, 1.25)
                    self.EffectiveScale = effective
                    uiScale.Scale = effective
                end

                self._applyResponsiveScale = applyResponsiveScale

                applyResponsiveScale()

                main.Position = UDim2.new(0.5, 0, 0.5, -size.Y.Offset * self.EffectiveScale / 2)

                clampMain(size.Y.Offset)

                local function onViewportChanged()
                    applyResponsiveScale()
                    clampMain()

                    if self.Launcher and Animator.Alive(self.Launcher) then
                        self.Launcher.Position = Primitives.ClampToViewport(self.Launcher, self.Launcher.Position, Vector2.new(48, 48))
                    end

                    task.defer(syncActiveTabCanvas)
                end
                local function watchCamera()
                    if camConn then
                        camConn:Disconnect()

                        camConn = nil
                    end

                    local cam = workspace.CurrentCamera

                    if cam then
                        camConn = cam:GetPropertyChangedSignal('ViewportSize'):Connect(onViewportChanged)
                    end
                end

                watchCamera()
                maid:Connect(workspace:GetPropertyChangedSignal('CurrentCamera'), function(
                )
                    watchCamera()
                    onViewportChanged()
                end)
                maid:Add(function()
                    if camConn then
                        camConn:Disconnect()

                        camConn = nil
                    end
                end)
                Animator.Tween(main, Tokens.Motion.Slow, {Size = size}, Tokens.Motion.SmoothStyle, Tokens.Motion.SmoothDir)

                local TOPBAR_H = 44
                local topbar = Instance.new('Frame')

                topbar.Name = 'Topbar'
                topbar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
                topbar.BackgroundColor3 = theme:Get('Sidebar')
                topbar.BorderSizePixel = 0
                topbar.ZIndex = Tokens.Layer.Chrome
                topbar.Parent = main

                Primitives.Corner(topbar, Tokens.Radius.Window)
                theme:Bind(topbar, 'BackgroundColor3', 'Sidebar')

                local topBottomSeam = Instance.new('Frame')

                topBottomSeam.Name = 'BottomSeam'
                topBottomSeam.Size = UDim2.new(1, 0, 0, Tokens.Radius.Window)
                topBottomSeam.Position = UDim2.new(0, 0, 1, -Tokens.Radius.Window)
                topBottomSeam.BackgroundColor3 = theme:Get('Sidebar')
                topBottomSeam.BorderSizePixel = 0
                topBottomSeam.ZIndex = Tokens.Layer.Chrome
                topBottomSeam.Parent = topbar

                theme:Bind(topBottomSeam, 'BackgroundColor3', 'Sidebar')

                self._topBottomSeam = topBottomSeam

                local topDivider = Instance.new('Frame')

                topDivider.Size = UDim2.new(1, 0, 0, 1)
                topDivider.Position = UDim2.new(0, 0, 1, -1)
                topDivider.BackgroundColor3 = theme:Get('Stroke')
                topDivider.BackgroundTransparency = 0.35
                topDivider.BorderSizePixel = 0
                topDivider.ZIndex = Tokens.Layer.Chrome + 1
                topDivider.Parent = topbar

                theme:Bind(topDivider, 'BackgroundColor3', 'Stroke')

                self._topDivider = topDivider

                local topAccent = Instance.new('Frame')

                topAccent.Size = UDim2.new(1, 0, 0, 2)
                topAccent.Position = UDim2.new(0, 0, 1, -2)
                topAccent.BackgroundColor3 = Color3.new(1, 1, 1)
                topAccent.BorderSizePixel = 0
                topAccent.ZIndex = Tokens.Layer.Chrome + 2
                topAccent.Parent = topbar

                local accentGrad = Primitives.Gradient(topAccent, theme:Get('Accent'), theme:Get('AccentSecondary'), 0)

                accentGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.5, 0.12),
                    NumberSequenceKeypoint.new(1, 1),
                })
                accentGrad.Offset = Vector2.new(-0.65, 0)

                theme:BindGradient(accentGrad, 'Accent', 'AccentSecondary')

                self._topAccent = topAccent

                local shimmerThread = task.spawn(function()
                    while Animator.Alive(accentGrad) do
                        Animator.Tween(accentGrad, 3.6, {
                            Offset = Vector2.new(0.65, 0),
                        }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                        task.wait(3.6)

                        if not Animator.Alive(accentGrad) then
                            break
                        end

                        Animator.Tween(accentGrad, 3.6, {
                            Offset = Vector2.new(-0.65, 0),
                        }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
                        task.wait(3.6)
                    end
                end)

                maid:Add(function()
                    pcall(task.cancel, shimmerThread)
                end)

                local brandDot = Instance.new('Frame')

                brandDot.Size = UDim2.fromOffset(8, 8)
                brandDot.AnchorPoint = Vector2.new(0, 0.5)
                brandDot.Position = UDim2.new(0, 14, 0.5, 0)
                brandDot.BackgroundColor3 = Color3.new(1, 1, 1)
                brandDot.BorderSizePixel = 0
                brandDot.ZIndex = Tokens.Layer.Chrome + 2
                brandDot.Parent = topbar

                Primitives.Corner(brandDot, Tokens.Radius.Pill)

                local dotGrad = Primitives.Gradient(brandDot, theme:Get('Accent'), theme:Get('AccentSecondary'), 45)

                theme:BindGradient(dotGrad, 'Accent', 'AccentSecondary')

                local iconSize = UserInputService.TouchEnabled and 32 or 26
                local iconGap = 7
                local searchW = UserInputService.TouchEnabled and 140 or 168
                local title = Instance.new('TextLabel')

                title.Size = UDim2.new(1, -(iconSize * 2 + iconGap * 3 + searchW + 46), 1, 0)
                title.Position = UDim2.new(0, 30, 0, 0)
                title.BackgroundTransparency = 1
                title.Text = tostring(config.Name or 'PoloskaLib')
                title.TextXAlignment = Enum.TextXAlignment.Left
                title.TextTruncate = Enum.TextTruncate.AtEnd
                title.ZIndex = Tokens.Layer.Chrome + 2

                Tokens.Typeset(title, 'Title', theme:Get('Text'))

                title.Parent = topbar

                theme:Bind(title, 'TextColor3', 'Text')

                local function makeHeaderIcon(
                    iconAsset: string,
                    xOffset: number,
                    hoverKey: string
                ): ImageButton
                    local b = Instance.new('ImageButton')

                    b.Size = UDim2.fromOffset(iconSize, iconSize)
                    b.AnchorPoint = Vector2.new(0, 0.5)
                    b.Position = UDim2.new(1, xOffset, 0.5, 0)
                    b.BackgroundColor3 = theme:Get('Element')
                    b.BorderSizePixel = 0
                    b.AutoButtonColor = false
                    b.Image = Primitives.ResolveIcon(iconAsset)
                    b.ImageColor3 = theme:Get('SubText')
                    b.ScaleType = Enum.ScaleType.Fit
                    b.ZIndex = Tokens.Layer.Chrome + 2
                    b.Parent = topbar

                    Primitives.Corner(b, Tokens.Radius.Chip)
                    Primitives.Padding(b, math.floor(iconSize / 4))

                    local bStroke = Primitives.Stroke(b, theme:Get('Stroke'), 1, 0.65)

                    theme:Bind(b, 'BackgroundColor3', 'Element')
                    theme:Bind(b, 'ImageColor3', 'SubText')
                    theme:Bind(bStroke, 'Color', 'Stroke')
                    b.MouseEnter:Connect(function()
                        Animator.Tween(b, Tokens.Motion.Fast, {
                            BackgroundColor3 = theme:Get(hoverKey),
                            ImageColor3 = hoverKey == 'Danger' and Color3.fromRGB(255, 255, 255) or theme:Get('Text'),
                        })
                        Animator.Tween(bStroke, Tokens.Motion.Fast, {
                            Transparency = 0.25,
                            Color = theme:Get(hoverKey == 'Danger' and 'Danger' or 'StrokeBright'),
                        })
                    end)
                    b.MouseLeave:Connect(function()
                        Animator.Tween(b, Tokens.Motion.Base, {
                            BackgroundColor3 = theme:Get('Element'),
                            ImageColor3 = theme:Get('SubText'),
                        })
                        Animator.Tween(bStroke, Tokens.Motion.Base, {
                            Transparency = 0.65,
                            Color = theme:Get('Stroke'),
                        })
                    end)

                    return b
                end

                local closeBtn = makeHeaderIcon(icons.Close, -(iconSize + 10), 'Danger')

                closeBtn.MouseButton1Click:Connect(function()
                    self:Confirm({
                        Title = 'Close menu?',
                        Text = 'Are you sure you want to close the UI?',
                        ConfirmText = 'Close',
                        CancelText = 'Cancel',
                        Danger = true,
                        OnConfirm = function()
                            Animator.Tween(mainStroke, 0.16, {Transparency = 1})

                            local tw = Animator.Tween(main, 0.2, {
                                Size = self:_collapsedSize(),
                            }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

                            if tw then
                                tw.Completed:Wait()
                            end
                            if Animator.Alive(gui) then
                                gui:Destroy()
                            end
                        end,
                    })
                end)

                local minBtn = makeHeaderIcon(icons.Minimize, -(iconSize * 2 + iconGap + 10), 'ElementHover')

                self.MinimizeButton = minBtn
                self.MinimizeIcon = icons.Minimize
                self.RestoreIcon = icons.Restore

                minBtn.MouseButton1Click:Connect(function()
                    self:ToggleMinimize()
                end)

                local searchWrap = Instance.new('Frame')

                searchWrap.Name = 'TopbarSearchWrap'
                searchWrap.Size = UDim2.fromOffset(searchW, iconSize)
                searchWrap.AnchorPoint = Vector2.new(0, 0.5)
                searchWrap.Position = UDim2.new(1, -(iconSize * 2 + iconGap * 2 + 10 + searchW), 0.5, 0)
                searchWrap.BackgroundColor3 = theme:Get('Element')
                searchWrap.BorderSizePixel = 0
                searchWrap.ZIndex = Tokens.Layer.Chrome + 2
                searchWrap.Parent = topbar

                Primitives.Corner(searchWrap, Tokens.Radius.Chip)

                local searchStroke = Primitives.Stroke(searchWrap, theme:Get('Stroke'), 1, 0.42)

                theme:Bind(searchWrap, 'BackgroundColor3', 'Element')
                theme:Bind(searchStroke, 'Color', 'Stroke')

                local searchGlyph = Instance.new('Frame')

                searchGlyph.Name = 'SearchGlyph'
                searchGlyph.Size = UDim2.fromOffset(14, 14)
                searchGlyph.AnchorPoint = Vector2.new(0, 0.5)
                searchGlyph.Position = UDim2.new(0, 7, 0.5, 0)
                searchGlyph.BackgroundTransparency = 1
                searchGlyph.ZIndex = Tokens.Layer.Chrome + 3
                searchGlyph.Parent = searchWrap

                local glyphLens = Instance.new('Frame')

                glyphLens.Size = UDim2.fromOffset(8, 8)
                glyphLens.Position = UDim2.fromOffset(1, 1)
                glyphLens.BackgroundTransparency = 1
                glyphLens.ZIndex = Tokens.Layer.Chrome + 3
                glyphLens.Parent = searchGlyph

                Primitives.Corner(glyphLens, Tokens.Radius.Pill)

                local glyphLensStroke = Primitives.Stroke(glyphLens, theme:Get('MutedText'), 1.4, 0)

                theme:Bind(glyphLensStroke, 'Color', 'MutedText')

                local glyphStem = Instance.new('Frame')

                glyphStem.Size = UDim2.fromOffset(5, 2)
                glyphStem.AnchorPoint = Vector2.new(0.5, 0.5)
                glyphStem.Position = UDim2.fromOffset(10, 10)
                glyphStem.Rotation = 45
                glyphStem.BackgroundColor3 = theme:Get('MutedText')
                glyphStem.BorderSizePixel = 0
                glyphStem.ZIndex = Tokens.Layer.Chrome + 3
                glyphStem.Parent = searchGlyph

                Primitives.Corner(glyphStem, Tokens.Radius.Pill)
                theme:Bind(glyphStem, 'BackgroundColor3', 'MutedText')

                local searchBox = Instance.new('TextBox')

                searchBox.Name = 'TopbarSearch'
                searchBox.Size = UDim2.new(1, -30, 1, 0)
                searchBox.Position = UDim2.new(0, 24, 0, 0)
                searchBox.BackgroundTransparency = 1
                searchBox.BorderSizePixel = 0
                searchBox.ClearTextOnFocus = false
                searchBox.Text = ''
                searchBox.PlaceholderText = 'Search controls...'
                searchBox.TextXAlignment = Enum.TextXAlignment.Left
                searchBox.TextTruncate = Enum.TextTruncate.AtEnd
                searchBox.ZIndex = Tokens.Layer.Chrome + 3

                Tokens.Typeset(searchBox, 'Body', theme:Get('Text'))

                searchBox.PlaceholderColor3 = theme:Get('MutedText')
                searchBox.Parent = searchWrap

                theme:Bind(searchBox, 'TextColor3', 'Text')
                theme:Bind(searchBox, 'PlaceholderColor3', 'MutedText')

                local clearBtn = Instance.new('TextButton')

                clearBtn.Name = 'ClearSearch'
                clearBtn.Size = UDim2.fromOffset(18, 18)
                clearBtn.AnchorPoint = Vector2.new(1, 0.5)
                clearBtn.Position = UDim2.new(1, -4, 0.5, 0)
                clearBtn.BackgroundColor3 = theme:Get('ElementHover')
                clearBtn.BackgroundTransparency = 1
                clearBtn.BorderSizePixel = 0
                clearBtn.Text = '\u{d7}'
                clearBtn.AutoButtonColor = false
                clearBtn.Visible = false
                clearBtn.ZIndex = Tokens.Layer.Chrome + 3

                Tokens.Typeset(clearBtn, 'Label', theme:Get('MutedText'))

                clearBtn.Parent = searchWrap

                Primitives.Corner(clearBtn, Tokens.Radius.Pill)
                theme:Bind(clearBtn, 'BackgroundColor3', 'ElementHover')
                theme:Bind(clearBtn, 'TextColor3', 'MutedText')
                clearBtn.MouseEnter:Connect(function()
                    Animator.Tween(clearBtn, Tokens.Motion.Fast, {
                        BackgroundTransparency = 0.25,
                        TextColor3 = theme:Get('Text'),
                    })
                end)
                clearBtn.MouseLeave:Connect(function()
                    Animator.Tween(clearBtn, Tokens.Motion.Fast, {
                        BackgroundTransparency = 1,
                        TextColor3 = theme:Get('MutedText'),
                    })
                end)
                clearBtn.MouseButton1Click:Connect(function()
                    searchBox.Text = ''
                end)
                Primitives.MakeDraggable(main, topbar, maid, {
                    searchWrap,
                    searchBox,
                    clearBtn,
                    minBtn,
                    closeBtn,
                })

                local searchSeq = 0
                local lastQuery = ''

                local function runSearch()
                    local q = Animator.Alive(searchBox) and searchBox.Text or ''
                    local changed = q ~= lastQuery

                    lastQuery = q

                    local active: any

                    for _, t in ipairs(self.Tabs)do
                        if t._active then
                            active = t
                        end
                        if changed then
                            t._searchTabPicked = nil
                        end
                    end

                    local firstHit: any
                    local activeHits = 0

                    for _, t in ipairs(self.Tabs)do
                        local n = t._applySearch(q)

                        t._setSearchCount(q ~= '' and n or nil)

                        if t == active then
                            activeHits = n
                        end
                        if q ~= '' and n > 0 and not firstHit then
                            firstHit = t
                        end
                    end

                    if q ~= '' and activeHits == 0 and firstHit and firstHit ~= active and not (active and active._searchTabPicked) then
                        firstHit._activate()
                    end
                end

                searchBox:GetPropertyChangedSignal('Text'):Connect(function()
                    local hasText = searchBox.Text ~= ''

                    clearBtn.Visible = hasText
                    searchBox.Size = hasText and UDim2.new(1, -46, 1, 0) or UDim2.new(1, 
-30, 1, 0)

                    searchSeq += 1

                    local seq = searchSeq

                    if not hasText then
                        runSearch()

                        return
                    end

                    task.delay(0.08, function()
                        if seq == searchSeq then
                            runSearch()
                        end
                    end)
                end)
                searchBox.Focused:Connect(function()
                    Animator.Tween(searchStroke, Tokens.Motion.Fast, {
                        Color = theme:Get('Accent'),
                        Transparency = 0.08,
                    })
                end)
                searchBox.FocusLost:Connect(function()
                    Animator.Tween(searchStroke, Tokens.Motion.Base, {
                        Color = theme:Get('Stroke'),
                        Transparency = 0.42,
                    })
                end)

                self.SearchBox = searchBox

                local SIDEBAR_W = 156
                local FOOTER_H = 34
                local sidebar = Instance.new('Frame')

                sidebar.Name = 'Sidebar'
                sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -TOPBAR_H)
                sidebar.Position = UDim2.new(0, 0, 0, TOPBAR_H)
                sidebar.BackgroundColor3 = theme:Get('Sidebar')
                sidebar.BorderSizePixel = 0
                sidebar.ZIndex = Tokens.Layer.Content + 1
                sidebar.Parent = main

                Primitives.Corner(sidebar, Tokens.Radius.Window)
                theme:Bind(sidebar, 'BackgroundColor3', 'Sidebar')

                local sideTopSeam = Instance.new('Frame')

                sideTopSeam.Name = 'TopSeam'
                sideTopSeam.Size = UDim2.new(1, 0, 0, Tokens.Radius.Window)
                sideTopSeam.Position = UDim2.new(0, 0, 0, 0)
                sideTopSeam.BackgroundColor3 = theme:Get('Sidebar')
                sideTopSeam.BorderSizePixel = 0
                sideTopSeam.ZIndex = Tokens.Layer.Content + 1
                sideTopSeam.Parent = sidebar

                theme:Bind(sideTopSeam, 'BackgroundColor3', 'Sidebar')

                local sideRightSeam = Instance.new('Frame')

                sideRightSeam.Name = 'RightSeam'
                sideRightSeam.Size = UDim2.new(0, Tokens.Radius.Window, 1, 0)
                sideRightSeam.Position = UDim2.new(1, -Tokens.Radius.Window, 0, 0)
                sideRightSeam.BackgroundColor3 = theme:Get('Sidebar')
                sideRightSeam.BorderSizePixel = 0
                sideRightSeam.ZIndex = Tokens.Layer.Content + 1
                sideRightSeam.Parent = sidebar

                theme:Bind(sideRightSeam, 'BackgroundColor3', 'Sidebar')

                local sideDivider = Instance.new('Frame')

                sideDivider.Size = UDim2.new(0, 1, 1, 0)
                sideDivider.Position = UDim2.new(1, -1, 0, 0)
                sideDivider.BackgroundColor3 = theme:Get('Stroke')
                sideDivider.BackgroundTransparency = 0.4
                sideDivider.BorderSizePixel = 0
                sideDivider.ZIndex = Tokens.Layer.Content + 2
                sideDivider.Parent = sidebar

                theme:Bind(sideDivider, 'BackgroundColor3', 'Stroke')

                local tabList = Instance.new('ScrollingFrame')

                tabList.Name = 'TabList'
                tabList.Size = UDim2.new(1, 0, 1, -FOOTER_H)
                tabList.BackgroundTransparency = 1
                tabList.BorderSizePixel = 0
                tabList.ScrollBarThickness = 0
                tabList.CanvasSize = UDim2.fromOffset(0, 0)
                tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
                tabList.ZIndex = Tokens.Layer.Content + 1
                tabList.Parent = sidebar

                Primitives.Padding(tabList, 10, 8, 10, 8)

                local tabLayout = Instance.new('UIListLayout')

                tabLayout.Padding = UDim.new(0, 5)
                tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
                tabLayout.Parent = tabList
                self.TabList = tabList

                local footer = Instance.new('Frame')

                footer.Name = 'SidebarFooter'
                footer.Size = UDim2.new(1, 0, 0, FOOTER_H)
                footer.Position = UDim2.new(0, 0, 1, -FOOTER_H)
                footer.BackgroundTransparency = 1
                footer.ZIndex = Tokens.Layer.Content + 2
                footer.Parent = sidebar

                local footerLine = Instance.new('Frame')

                footerLine.Size = UDim2.new(1, -16, 0, 1)
                footerLine.Position = UDim2.new(0, 8, 0, 0)
                footerLine.BackgroundColor3 = theme:Get('Stroke')
                footerLine.BackgroundTransparency = 0.55
                footerLine.BorderSizePixel = 0
                footerLine.ZIndex = Tokens.Layer.Content + 2
                footerLine.Parent = footer

                theme:Bind(footerLine, 'BackgroundColor3', 'Stroke')

                local footerLbl = Instance.new('TextLabel')

                footerLbl.Size = UDim2.new(1, -16, 1, 0)
                footerLbl.Position = UDim2.new(0, 10, 0, 0)
                footerLbl.BackgroundTransparency = 1
                footerLbl.Text = tostring(config.Footer or ('Poloska v' .. Tokens.Version))
                footerLbl.TextXAlignment = Enum.TextXAlignment.Left
                footerLbl.TextTruncate = Enum.TextTruncate.AtEnd
                footerLbl.ZIndex = Tokens.Layer.Content + 3

                Tokens.Typeset(footerLbl, 'Caption', theme:Get('MutedText'))

                footerLbl.Parent = footer

                theme:Bind(footerLbl, 'TextColor3', 'MutedText')

                self._footerLabel = footerLbl

                local container = Instance.new('Frame')

                container.Name = 'Container'
                container.Size = UDim2.new(1, -SIDEBAR_W, 1, -TOPBAR_H)
                container.Position = UDim2.new(0, SIDEBAR_W, 0, TOPBAR_H)
                container.BackgroundTransparency = 1
                container.ZIndex = Tokens.Layer.Content
                container.Parent = main
                self.Container = container
                self.Body = {sidebar, container}

                maid:Connect(UserInputService.InputBegan, function(
                    input: InputObject,
                    gpe: boolean
                )
                    if gpe or self._capturingKeybind or not Animator.Alive(main) then
                        return
                    end
                    if input.KeyCode == self.ToggleKey then
                        self:Toggle()
                    elseif self.MinimizeKey and input.KeyCode == self.MinimizeKey then
                        self:ToggleMinimize()
                    end
                end)

                local topInset = Primitives.GetTopInset()
                local launcher = Instance.new('ImageButton')

                launcher.Name = 'PoloskaLauncher'
                launcher.Size = UDim2.fromOffset(48, 48)
                launcher.Position = UDim2.new(0.5, -24, 0, topInset + 10)
                launcher.BackgroundColor3 = theme:Get('Card')
                launcher.BackgroundTransparency = 0.08
                launcher.BorderSizePixel = 0
                launcher.AutoButtonColor = false
                launcher.Image = Primitives.ResolveIcon(icons.Launcher)
                launcher.ImageColor3 = Color3.new(1, 1, 1)
                launcher.ScaleType = Enum.ScaleType.Fit
                launcher.Visible = self.ToggleButtonVisible
                launcher.ZIndex = Tokens.Layer.Launcher
                launcher.Parent = gui
                launcher.Position = Primitives.ClampToViewport(launcher, launcher.Position, Vector2.new(48, 48))

                Primitives.Corner(launcher, 13)
                Primitives.Padding(launcher, 5)

                local lStroke = Primitives.Stroke(launcher, theme:Get('Accent'), 1, 0.35)

                theme:Bind(launcher, 'BackgroundColor3', 'Card')
                theme:Bind(lStroke, 'Color', 'Accent')

                local launcherDrag = Primitives.MakeDraggable(launcher, launcher, maid)

                launcher.Activated:Connect(function()
                    if launcherDrag:ConsumeClick() then
                        return
                    end

                    self:Toggle()
                end)

                self.Launcher = launcher
                self._notify = Overlay.AttachNotificationHost(gui, theme)

                return self
            end
            function Window:_collapsedSize(): UDim2
                return UDim2.fromOffset(self.WindowSize.X.Offset, 0)
            end
            function Window:Tab(config: any)
                return Tab.Create(self, config)
            end
            function Window:SetFooter(text: string)
                if self._footerLabel and Animator.Alive(self._footerLabel) then
                    self._footerLabel.Text = tostring(text or '')
                end
            end
            function Window:SetTheme(name: string): (boolean,string?)
                if self._activePopupClose then
                    self._activePopupClose()
                end

                local ok, err = self._theme:Set(name)

                if ok then
                    self.ThemeName = name
                end

                return ok, err
            end
            function Window:GetThemeNames(): {string}
                return self._theme:Names()
            end
            function Window:SetScale(scale: number)
                self.UserScale = math.clamp(tonumber(scale) or 1, UserInputService.TouchEnabled and 0.35 or 0.5, 1.25)

                if self._applyResponsiveScale then
                    self._applyResponsiveScale()
                end
                if self._clampMain then
                    self._clampMain()
                end
                if self._syncActiveTabCanvas then
                    task.defer(self._syncActiveTabCanvas)
                end
            end
            function Window:SetAutoScale(enabled: boolean)
                self.AutoScale = enabled ~= false

                if self._applyResponsiveScale then
                    self._applyResponsiveScale()
                end
                if self._clampMain then
                    self._clampMain()
                end
                if self._syncActiveTabCanvas then
                    task.defer(self._syncActiveTabCanvas)
                end
            end
            function Window:SetToggleKey(key: Enum.KeyCode): boolean
                if typeof(key) == 'EnumItem' and key.EnumType == Enum.KeyCode then
                    self.ToggleKey = key

                    return true
                end

                return false
            end
            function Window:SetMinimizeKey(key: Enum.KeyCode?): boolean
                if key == nil then
                    self.MinimizeKey = nil

                    return true
                end
                if typeof(key) == 'EnumItem' and key.EnumType == Enum.KeyCode then
                    self.MinimizeKey = key

                    return true
                end

                return false
            end
            function Window:SetToggleButtonVisible(visible: boolean)
                self.ToggleButtonVisible = visible ~= false

                if self.Launcher and Animator.Alive(self.Launcher) then
                    self.Launcher.Visible = self.ToggleButtonVisible
                end
            end
            function Window:SetNotificationsEnabled(enabled: boolean)
                self._notificationsEnabled = enabled ~= false
            end
            function Window:Toggle()
                if not Animator.Alive(self.Main) then
                    return
                end
                if self._activePopupClose then
                    self._activePopupClose()
                end
                if self._cancelKeybindCapture then
                    self._cancelKeybindCapture()
                end

                self.Visible = not self.Visible

                if self.Visible then
                    self.Main.Visible = true

                    local targetSize = self.Minimized and UDim2.fromOffset(self.WindowSize.X.Offset, 44) or self.WindowSize

                    Animator.Tween(self.Main, Tokens.Motion.Slow, {Size = targetSize}, Tokens.Motion.SmoothStyle, Tokens.Motion.SmoothDir)
                    Animator.Tween(self.MainStroke, Tokens.Motion.Base, {Transparency = 0.22})
                else
                    Animator.Tween(self.MainStroke, Tokens.Motion.Fast, {Transparency = 1})

                    local tw = Animator.Tween(self.Main, 0.22, {
                        Size = self:_collapsedSize(),
                    }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

                    if tw then
                        tw.Completed:Connect(function()
                            if not self.Visible and Animator.Alive(self.Main) then
                                self.Main.Visible = false
                            end
                        end)
                    end
                end
            end
            function Window:Show()
                if not self.Visible then
                    self:Toggle()
                end
            end
            function Window:Hide()
                if self.Visible then
                    self:Toggle()
                end
            end
            function Window:ToggleMinimize()
                if not Animator.Alive(self.Main) then
                    return
                end
                if self._activePopupClose then
                    self._activePopupClose()
                end

                self.Minimized = not self.Minimized

                local targetSize = self.Minimized and UDim2.fromOffset(self.WindowSize.X.Offset, 44) or self.WindowSize

                Animator.Tween(self.Main, Tokens.Motion.Base, {Size = targetSize}, Tokens.Motion.SmoothStyle, Tokens.Motion.SmoothDir)

                if self._topBottomSeam and Animator.Alive(self._topBottomSeam) then
                    self._topBottomSeam.Visible = not self.Minimized
                end
                if self._topDivider and Animator.Alive(self._topDivider) then
                    self._topDivider.Visible = not self.Minimized
                end
                if self._topAccent and Animator.Alive(self._topAccent) then
                    self._topAccent.Visible = not self.Minimized
                end
                if self.MinimizeButton and Animator.Alive(self.MinimizeButton) then
                    self.MinimizeButton.Image = Primitives.ResolveIcon(self.Minimized and self.RestoreIcon or self.MinimizeIcon)
                end

                for _, part in ipairs(self.Body)do
                    if Animator.Alive(part) then
                        part.Visible = not self.Minimized
                    end
                end

                if not self.Minimized then
                    if self._clampMain then
                        self._clampMain(self.WindowSize.Y.Offset)
                    end
                    if self._syncActiveTabCanvas then
                        task.defer(self._syncActiveTabCanvas)
                    end
                end
            end
            function Window:Notification(cfg: any)
                if self._notificationsEnabled == false then
                    return
                end
                if self._notify then
                    self._notify(cfg)
                end
            end
            function Window:Confirm(opts: any)
                Overlay.Confirm(self, opts)
            end

            return Window
        end

        function __POLOSKALIB_MODULES.i(): typeof(__modImpl())
            local v = __POLOSKALIB_MODULES.cache.i

            if not v then
                v = {
                    c = __modImpl(),
                }
                __POLOSKALIB_MODULES.cache.i = v
            end

            return v.c
        end
    end
end

local Tokens = __POLOSKALIB_MODULES.a()
local Window = __POLOSKALIB_MODULES.i()
local PoloskaLib = {
    Version = Tokens.Version,
}

function PoloskaLib:Create(config: any)
    return Window.Create(config)
end

return PoloskaLib
