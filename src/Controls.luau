--!strict
-- PoloskaLib v2 Controls: Section, Button, Toggle, Slider, Dropdown (with
-- live search filter), Textbox, Keybind, and Metrics dashboard grid.
-- Every control uses explicit theme bindings and window._maid for zero leaks.

local UserInputService = game:GetService("UserInputService")
local Tokens = require("./Tokens")
local Animator = require("./Animator")
local Primitives = require("./Primitives")

local Controls = {}

local function makeRow(parent: Instance, height: number, theme: any, searchableText: string?): Frame
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, 0, 0, height)
	f.BackgroundColor3 = theme:Get("Element")
	f.BorderSizePixel = 0
	f.ZIndex = Tokens.Layer.Content + 1
	f.Parent = parent
	Primitives.Corner(f, Tokens.Radius.Control)
	local st = Primitives.Stroke(f, theme:Get("Stroke"), 1, 0.78)
	theme:Bind(f, "BackgroundColor3", "Element")
	theme:Bind(st, "Color", "Stroke")
	if searchableText and searchableText ~= "" then
		f:SetAttribute("SearchText", string.lower(searchableText))
	end
	return f
end

--// SECTION (read-only status/note label)
function Controls.Section(parent: Instance, theme: any, text: string, opts: any?): TextLabel
	opts = opts or {}
	local wrap = Instance.new("Frame")
	wrap.Name = "SectionWrap"
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

	local label = Instance.new("TextLabel")
	label.Name = "SectionLabel"
	label.Size = UDim2.new(1, 0, 0, 0)
	label.AutomaticSize = Enum.AutomaticSize.Y
	label.BackgroundTransparency = 1
	label.Text = tostring(text or "")
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Top
	label.TextWrapped = true
	label.LineHeight = 1.15
	label.ZIndex = Tokens.Layer.Content + 2
	Tokens.Typeset(label, opts.Bottom and "Caption" or "Body", theme:Get(opts.Bottom and "MutedText" or "SubText"))
	label.Parent = wrap
	theme:Bind(label, "TextColor3", opts.Bottom and "MutedText" or "SubText")

	label:GetPropertyChangedSignal("Visible"):Connect(function()
		if Animator.Alive(wrap) then
			wrap.Visible = label.Visible
		end
	end)
	return label
end

--// METRICS (2-column dashboard stat tiles)
function Controls.Metrics(parent: Instance, theme: any, items: { { Key: string, Label: string, Value: string?, Accent: string? } })
	local rows = math.ceil(#items / 2)
	local gridH = rows > 0 and (rows * 48 + math.max(0, rows - 1) * 8) or 0

	local grid = Instance.new("Frame")
	grid.Name = "MetricsGrid"
	grid.Size = UDim2.new(1, 0, 0, gridH)
	grid.AutomaticSize = Enum.AutomaticSize.None
	grid.BackgroundTransparency = 1
	grid.ZIndex = Tokens.Layer.Content + 1
	grid.Parent = parent

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(0.5, -4, 0, 48)
	layout.CellPadding = UDim2.fromOffset(8, 8)
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.FillDirectionMaxCells = 2
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = grid

	local valueLabels: { [string]: TextLabel } = {}

	for idx, item in ipairs(items) do
		local tile = Instance.new("Frame")
		tile.Name = "Metric_" .. item.Key
		tile.BackgroundColor3 = theme:Get("Element")
		tile.BorderSizePixel = 0
		tile.LayoutOrder = idx
		tile.ZIndex = Tokens.Layer.Content + 2
		tile.Parent = grid
		Primitives.Corner(tile, Tokens.Radius.Control)
		local st = Primitives.Stroke(tile, theme:Get("Stroke"), 1, 0.72)
		theme:Bind(tile, "BackgroundColor3", "Element")
		theme:Bind(st, "Color", "Stroke")
		Primitives.Padding(tile, 6, 10, 6, 10)

		local caption = Instance.new("TextLabel")
		caption.Size = UDim2.new(1, 0, 0, 14)
		caption.BackgroundTransparency = 1
		caption.Text = string.upper(item.Label)
		caption.TextXAlignment = Enum.TextXAlignment.Left
		caption.TextTruncate = Enum.TextTruncate.AtEnd
		caption.ZIndex = Tokens.Layer.Content + 3
		Tokens.Typeset(caption, "Caption", theme:Get("MutedText"))
		caption.Parent = tile
		theme:Bind(caption, "TextColor3", "MutedText")

		local val = Instance.new("TextLabel")
		val.Size = UDim2.new(1, 0, 0, 20)
		val.Position = UDim2.new(0, 0, 0, 15)
		val.BackgroundTransparency = 1
		val.Text = tostring(item.Value or "-")
		val.TextXAlignment = Enum.TextXAlignment.Left
		val.TextTruncate = Enum.TextTruncate.AtEnd
		val.ZIndex = Tokens.Layer.Content + 3
		local colorKey = item.Accent or "Text"
		Tokens.Typeset(val, "Heading", theme:Get(colorKey))
		val.Parent = tile
		theme:Bind(val, "TextColor3", colorKey)

		valueLabels[item.Key] = val
	end

	local handle = { Frame = grid }
	function handle:Set(key: string, value: any, accentKey: string?)
		local lbl = valueLabels[key]
		if lbl and Animator.Alive(lbl) then
			lbl.Text = tostring(value)
			if accentKey then
				theme:Bind(lbl, "TextColor3", accentKey)
			end
		end
	end
	function handle:SetAll(values: { [string]: any })
		for k, v in pairs(values) do
			self:Set(k, v)
		end
	end
	return handle
end

--// BUTTON
function Controls.Button(parent: Instance, _window: any, theme: any, cfg: any)
	cfg = cfg or {}
	local name = tostring(cfg.Name or "Button")
	local style = tostring(cfg.Style or "default")
	local bgKey = style == "danger" and "Danger" or (style == "primary" and "AccentSoft" or "Element")
	local hoverKey = style == "danger" and "Danger" or (style == "primary" and "Accent" or "ElementHover")
	local strokeKey = style == "danger" and "Danger" or (style == "primary" and "Accent" or "Stroke")
	local baseStrokeTrans = style == "default" and 0.72 or 0.25

	local btn = Instance.new("TextButton")
	btn.Name = "Button"
	btn.Size = UDim2.new(1, 0, 0, 36)
	btn.BackgroundColor3 = theme:Get(bgKey)
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.ZIndex = Tokens.Layer.Content + 2
	btn.Parent = parent
	btn:SetAttribute("SearchText", string.lower(name))
	Primitives.Corner(btn, Tokens.Radius.Control)
	local st = Primitives.Stroke(btn, theme:Get(strokeKey), 1, baseStrokeTrans)
	theme:Bind(btn, "BackgroundColor3", bgKey)
	theme:Bind(st, "Color", strokeKey)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -24, 1, 0)
	lbl.Position = UDim2.new(0, 12, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.ZIndex = Tokens.Layer.Content + 3
	Tokens.Typeset(lbl, "Label", style == "danger" and Color3.fromRGB(255, 255, 255) or theme:Get("Text"))
	lbl.Parent = btn
	if style ~= "danger" then
		theme:Bind(lbl, "TextColor3", "Text")
	end

	-- Subtle right chevron
	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.fromOffset(18, 18)
	arrow.AnchorPoint = Vector2.new(1, 0.5)
	arrow.Position = UDim2.new(1, -10, 0.5, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "›"
	arrow.ZIndex = Tokens.Layer.Content + 3
	Tokens.Typeset(arrow, "Caption", style == "danger" and Color3.fromRGB(255, 255, 255) or theme:Get("MutedText"))
	arrow.Parent = btn
	if style ~= "danger" then
		theme:Bind(arrow, "TextColor3", "MutedText")
	end

	local hovered = false
	btn.MouseEnter:Connect(function()
		hovered = true
		Animator.Tween(btn, Tokens.Motion.Fast, {
			BackgroundColor3 = theme:Get(hoverKey),
			BackgroundTransparency = style == "danger" and 0.12 or 0,
		})
		Animator.Tween(st, Tokens.Motion.Fast, {
			Transparency = 0.08,
			Color = theme:Get(style == "danger" and "Danger" or "StrokeBright"),
		})
		if style == "primary" then
			local onAccent = theme:Get("OnAccent")
			Animator.Tween(lbl, Tokens.Motion.Fast, { TextColor3 = onAccent })
			Animator.Tween(arrow, Tokens.Motion.Fast, { TextColor3 = onAccent })
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
		if style == "primary" then
			Animator.Tween(lbl, Tokens.Motion.Base, { TextColor3 = theme:Get("Text") })
			Animator.Tween(arrow, Tokens.Motion.Base, { TextColor3 = theme:Get("MutedText") })
		end
	end)
	btn.MouseButton1Down:Connect(function()
		if style == "primary" then
			Animator.Tween(btn, 0.08, { BackgroundColor3 = theme:Get("Accent"), BackgroundTransparency = 0.15 })
		elseif style == "danger" then
			Animator.Tween(btn, 0.08, { BackgroundColor3 = theme:Get("Danger"), BackgroundTransparency = 0.22 })
		else
			Animator.Tween(btn, 0.08, { BackgroundColor3 = theme:Get("ElementActive"), BackgroundTransparency = 0 })
		end
	end)
	btn.MouseButton1Up:Connect(function()
		if hovered then
			Animator.Tween(btn, Tokens.Motion.Fast, {
				BackgroundColor3 = theme:Get(hoverKey),
				BackgroundTransparency = style == "danger" and 0.12 or 0,
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

	local handle = { Frame = btn }
	function handle:SetText(newText: string)
		local s = tostring(newText)
		if Animator.Alive(lbl) then
			lbl.Text = s
		end
		if Animator.Alive(btn) then
			btn:SetAttribute("SearchText", string.lower(s))
		end
	end
	return handle
end

--// BUTTON ROW (2-3 compact horizontal equal-width buttons)
function Controls.ButtonRow(parent: Instance, _window: any, theme: any, cfg: any)
	local list: { any } = {}
	if type(cfg) == "table" then
		if type(cfg.Buttons) == "table" then
			list = cfg.Buttons
		else
			list = cfg
		end
	end
	local count = #list
	local gap = 6

	local row = Instance.new("Frame")
	row.Name = "ButtonRow"
	row.Size = UDim2.new(1, 0, 0, 34)
	row.BackgroundTransparency = 1
	row.BorderSizePixel = 0
	row.ZIndex = Tokens.Layer.Content + 1
	row.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, gap)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = row

	local titles: { string } = {}
	local buttonHandles: { any } = {}

	local function refreshSearchText()
		if Animator.Alive(row) then
			row:SetAttribute("SearchText", string.lower(table.concat(titles, " ")))
		end
	end

	local scaleW = count > 0 and (1 / count) or 1
	local offsetW = count > 1 and -math.floor(((count - 1) * gap) / count + 0.5) or 0

	for idx, bCfg in ipairs(list) do
		bCfg = bCfg or {}
		local title = tostring(bCfg.Title or bCfg.Name or ("Action " .. idx))
		titles[idx] = title
		local style = tostring(bCfg.Style or "default")
		local bgKey = style == "danger" and "Danger" or (style == "primary" and "AccentSoft" or "Element")
		local hoverKey = style == "danger" and "Danger" or (style == "primary" and "Accent" or "ElementHover")
		local strokeKey = style == "danger" and "Danger" or (style == "primary" and "Accent" or "Stroke")
		local baseStrokeTrans = style == "default" and 0.72 or 0.25

		local enabled = bCfg.Enabled ~= false
		local hovered = false

		local btn = Instance.new("TextButton")
		btn.Name = "RowButton_" .. idx
		btn.Size = UDim2.new(scaleW, offsetW, 1, 0)
		btn.BackgroundColor3 = theme:Get(bgKey)
		btn.BackgroundTransparency = enabled and 0 or 0.45
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.Active = enabled
		btn.LayoutOrder = idx
		btn.ZIndex = Tokens.Layer.Content + 2
		btn.Parent = row
		Primitives.Corner(btn, Tokens.Radius.Control)
		local st = Primitives.Stroke(btn, theme:Get(strokeKey), 1, baseStrokeTrans)
		theme:Bind(btn, "BackgroundColor3", bgKey)
		theme:Bind(st, "Color", strokeKey)

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -12, 1, 0)
		lbl.Position = UDim2.new(0, 6, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.Text = title
		lbl.TextTransparency = enabled and 0 or 0.45
		lbl.TextXAlignment = Enum.TextXAlignment.Center
		lbl.TextTruncate = Enum.TextTruncate.AtEnd
		lbl.ZIndex = Tokens.Layer.Content + 3
		Tokens.Typeset(lbl, "Label", style == "danger" and Color3.fromRGB(255, 255, 255) or theme:Get("Text"))
		lbl.Parent = btn
		if style ~= "danger" then
			theme:Bind(lbl, "TextColor3", "Text")
		end

		btn.MouseEnter:Connect(function()
			if not enabled then
				return
			end
			hovered = true
			Animator.Tween(btn, Tokens.Motion.Fast, {
				BackgroundColor3 = theme:Get(hoverKey),
				BackgroundTransparency = style == "danger" and 0.12 or 0,
			})
			Animator.Tween(st, Tokens.Motion.Fast, {
				Transparency = 0.08,
				Color = theme:Get(style == "danger" and "Danger" or "StrokeBright"),
			})
			if style == "primary" then
				Animator.Tween(lbl, Tokens.Motion.Fast, { TextColor3 = theme:Get("OnAccent") })
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
			if style == "primary" then
				Animator.Tween(lbl, Tokens.Motion.Base, { TextColor3 = theme:Get("Text") })
			end
		end)
		btn.MouseButton1Down:Connect(function()
			if not enabled then
				return
			end
			if style == "primary" then
				Animator.Tween(btn, 0.08, { BackgroundColor3 = theme:Get("Accent"), BackgroundTransparency = 0.15 })
			elseif style == "danger" then
				Animator.Tween(btn, 0.08, { BackgroundColor3 = theme:Get("Danger"), BackgroundTransparency = 0.22 })
			else
				Animator.Tween(btn, 0.08, { BackgroundColor3 = theme:Get("ElementActive"), BackgroundTransparency = 0 })
			end
		end)
		btn.MouseButton1Up:Connect(function()
			if not enabled then
				return
			end
			if hovered then
				Animator.Tween(btn, Tokens.Motion.Fast, {
					BackgroundColor3 = theme:Get(hoverKey),
					BackgroundTransparency = style == "danger" and 0.12 or 0,
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

		local bHandle: any = { Frame = btn }
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
					TextColor3 = style == "danger" and Color3.fromRGB(255, 255, 255) or theme:Get("Text"),
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
	function handle:SetEnabled(indexOrEnabled: any, maybeEnabled: boolean?)
		if type(indexOrEnabled) == "number" then
			local bh = buttonHandles[indexOrEnabled]
			if bh then
				bh:SetEnabled(maybeEnabled ~= false)
			end
		else
			local flag = indexOrEnabled ~= false
			for _, bh in ipairs(buttonHandles) do
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

--// TOGGLE
function Controls.Toggle(parent: Instance, _window: any, theme: any, cfg: any)
	cfg = cfg or {}
	local name = tostring(cfg.Name or "Toggle")
	local descText = cfg.Description and tostring(cfg.Description) or nil
	local state = cfg.StartingState == true

	local row = makeRow(parent, descText and 54 or 42, theme, name .. " " .. (descText or ""))
	row.Name = "Toggle"

	local hit = Instance.new("TextButton")
	hit.Size = UDim2.fromScale(1, 1)
	hit.BackgroundTransparency = 1
	hit.Text = ""
	hit.AutoButtonColor = false
	hit.ZIndex = Tokens.Layer.Content + 4
	hit.Parent = row

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -68, 0, 18)
	lbl.Position = descText and UDim2.new(0, 12, 0, 8) or UDim2.new(0, 12, 0.5, -9)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.ZIndex = Tokens.Layer.Content + 2
	Tokens.Typeset(lbl, "Label", theme:Get("Text"))
	lbl.Parent = row
	theme:Bind(lbl, "TextColor3", "Text")

	if descText then
		local sub = Instance.new("TextLabel")
		sub.Size = UDim2.new(1, -68, 0, 14)
		sub.Position = UDim2.new(0, 12, 0, 28)
		sub.BackgroundTransparency = 1
		sub.Text = descText
		sub.TextXAlignment = Enum.TextXAlignment.Left
		sub.TextTruncate = Enum.TextTruncate.AtEnd
		sub.ZIndex = Tokens.Layer.Content + 2
		Tokens.Typeset(sub, "Caption", theme:Get("MutedText"))
		sub.Parent = row
		theme:Bind(sub, "TextColor3", "MutedText")
	end

	local track = Instance.new("Frame")
	track.Size = UDim2.fromOffset(40, 22)
	track.AnchorPoint = Vector2.new(1, 0.5)
	track.Position = UDim2.new(1, -12, 0.5, 0)
	track.BackgroundColor3 = state and theme:Get("Accent") or theme:Get("Stroke")
	track.BorderSizePixel = 0
	track.ZIndex = Tokens.Layer.Content + 2
	track.Parent = row
	Primitives.Corner(track, Tokens.Radius.Pill)
	local trackStroke = Primitives.Stroke(track, state and theme:Get("Accent") or theme:Get("StrokeBright"), 1, state and 0.2 or 0.5)

	local knob = Instance.new("Frame")
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
		local bg = state and theme:Get("Accent") or theme:Get("Stroke")
		local stColor = state and theme:Get("Accent") or theme:Get("StrokeBright")
		local stTrans = state and 0.15 or 0.55
		local pos = state and UDim2.new(0, 21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
		local sz = UDim2.fromOffset(16, 16)
		if animated then
			Animator.Tween(track, Tokens.Motion.Base, { BackgroundColor3 = bg })
			Animator.Tween(trackStroke, Tokens.Motion.Base, { Color = stColor, Transparency = stTrans })
			Animator.Tween(knob, Tokens.Motion.Spring, { Position = pos, Size = sz }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
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
		Animator.Tween(row, Tokens.Motion.Fast, { BackgroundColor3 = theme:Get("ElementHover") })
	end)
	hit.MouseLeave:Connect(function()
		Animator.Tween(row, Tokens.Motion.Base, { BackgroundColor3 = theme:Get("Element") })
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

	local handle = { Frame = row }
	function handle:Set(v: boolean, silent: boolean?)
		setState(v, silent)
	end
	function handle:Get(): boolean
		return state
	end
	return handle
end

--// SLIDER
function Controls.Slider(parent: Instance, _window: any, theme: any, cfg: any)
	cfg = cfg or {}
	local name = tostring(cfg.Name or "Slider")
	local minVal = tonumber(cfg.Min) or 0
	local maxVal = tonumber(cfg.Max) or 100
	if maxVal <= minVal then
		maxVal = minVal + 1
	end
	local step = tonumber(cfg.Step) or 1
	local editable = cfg.Editable == true
	local commitOnRelease = cfg.CommitOnRelease == true
	local suffix = cfg.Suffix and tostring(cfg.Suffix) or ""

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
	row.Name = "Slider"
	Primitives.Padding(row, 8, 12, 10, 12)

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 18)
	header.BackgroundTransparency = 1
	header.ZIndex = Tokens.Layer.Content + 2
	header.Parent = row

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -68, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.ZIndex = Tokens.Layer.Content + 2
	Tokens.Typeset(lbl, "Label", theme:Get("Text"))
	lbl.Parent = header
	theme:Bind(lbl, "TextColor3", "Text")

	local valChip: any
	local bStroke: UIStroke? = nil
	if editable then
		local box = Instance.new("TextBox")
		box.Size = UDim2.fromOffset(60, 20)
		box.AnchorPoint = Vector2.new(1, 0.5)
		box.Position = UDim2.new(1, 0, 0.5, 0)
		box.BackgroundColor3 = theme:Get("Card")
		box.BorderSizePixel = 0
		box.Text = tostring(value)
		box.ClearTextOnFocus = false
		box.TextXAlignment = Enum.TextXAlignment.Center
		box.ZIndex = Tokens.Layer.Content + 3
		Tokens.Typeset(box, "Mono", theme:Get("Accent"))
		box.Parent = header
		Primitives.Corner(box, Tokens.Radius.Chip)
		local st = Primitives.Stroke(box, theme:Get("Stroke"), 1, 0.4)
		theme:Bind(box, "BackgroundColor3", "Card")
		theme:Bind(box, "TextColor3", "Accent")
		theme:Bind(st, "Color", "Stroke")
		bStroke = st
		valChip = box
	else
		local chip = Instance.new("TextLabel")
		chip.Size = UDim2.fromOffset(64, 20)
		chip.AnchorPoint = Vector2.new(1, 0.5)
		chip.Position = UDim2.new(1, 0, 0.5, 0)
		chip.BackgroundTransparency = 1
		chip.Text = tostring(value) .. suffix
		chip.TextXAlignment = Enum.TextXAlignment.Right
		chip.ZIndex = Tokens.Layer.Content + 3
		Tokens.Typeset(chip, "Mono", theme:Get("Accent"))
		chip.Parent = header
		theme:Bind(chip, "TextColor3", "Accent")
		valChip = chip
	end

	local trackHit = Instance.new("TextButton")
	trackHit.Size = UDim2.new(1, -14, 0, 18)
	trackHit.Position = UDim2.new(0, 7, 1, -18)
	trackHit.BackgroundTransparency = 1
	trackHit.Text = ""
	trackHit.AutoButtonColor = false
	trackHit.ZIndex = Tokens.Layer.Content + 3
	trackHit.Parent = row

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, 0, 0, 6)
	track.AnchorPoint = Vector2.new(0, 0.5)
	track.Position = UDim2.new(0, 0, 0.5, 0)
	track.BackgroundColor3 = theme:Get("Card")
	track.BorderSizePixel = 0
	track.ZIndex = Tokens.Layer.Content + 2
	track.Parent = trackHit
	Primitives.Corner(track, Tokens.Radius.Pill)
	local trackStroke = Primitives.Stroke(track, theme:Get("Stroke"), 1, 0.45)
	theme:Bind(track, "BackgroundColor3", "Card")
	theme:Bind(trackStroke, "Color", "Stroke")

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(0, 1)
	fill.BackgroundColor3 = Color3.new(1, 1, 1)
	fill.BorderSizePixel = 0
	fill.ZIndex = Tokens.Layer.Content + 3
	fill.Parent = track
	Primitives.Corner(fill, Tokens.Radius.Pill)
	local fillGrad = Primitives.Gradient(fill, theme:Get("Accent"), theme:Get("AccentSecondary"), 0)
	theme:BindGradient(fillGrad, "Accent", "AccentSecondary")

	local thumb = Instance.new("Frame")
	thumb.Size = UDim2.fromOffset(14, 14)
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.Position = UDim2.fromScale(0, 0.5)
	thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	thumb.BorderSizePixel = 0
	thumb.ZIndex = Tokens.Layer.Content + 4
	thumb.Parent = track
	Primitives.Corner(thumb, Tokens.Radius.Pill)
	local thumbStroke = Primitives.Stroke(thumb, theme:Get("Accent"), 2, 0.1)
	theme:Bind(thumbStroke, "Color", "Accent")

	local function render(animated: boolean)
		local pct = math.clamp((value - minVal) / (maxVal - minVal), 0, 1)
		if Animator.Alive(valChip) then
			valChip.Text = editable and tostring(value) or (tostring(value) .. suffix)
		end
		if animated then
			Animator.Tween(fill, 0.08, { Size = UDim2.fromScale(pct, 1) })
			Animator.Tween(thumb, 0.08, { Position = UDim2.fromScale(pct, 0.5) })
		else
			fill.Size = UDim2.fromScale(pct, 1)
			thumb.Position = UDim2.fromScale(pct, 0.5)
		end
	end
	render(false)

	local dragging = false
	local rowHovered = false
	local trackHovered = false
	local moveConn: RBXScriptConnection? = nil
	local endConn: RBXScriptConnection? = nil
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
		Animator.Tween(row, Tokens.Motion.Fast, { BackgroundColor3 = theme:Get("ElementHover") })
	end)
	row.MouseLeave:Connect(function()
		rowHovered = false
		if not dragging then
			Animator.Tween(row, Tokens.Motion.Base, { BackgroundColor3 = theme:Get("Element") })
		end
	end)
	trackHit.MouseEnter:Connect(function()
		trackHovered = true
		Animator.Tween(trackStroke, Tokens.Motion.Fast, { Color = theme:Get("StrokeBright"), Transparency = 0.18 })
		if not dragging then
			Animator.Tween(thumb, Tokens.Motion.Fast, { Size = UDim2.fromOffset(15, 15) })
		end
	end)
	trackHit.MouseLeave:Connect(function()
		trackHovered = false
		if not dragging then
			Animator.Tween(trackStroke, Tokens.Motion.Base, { Color = theme:Get("Stroke"), Transparency = 0.45 })
			Animator.Tween(thumb, Tokens.Motion.Fast, { Size = UDim2.fromOffset(14, 14) })
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
			Animator.Tween(thumb, Tokens.Motion.Fast, { Size = UDim2.fromOffset(17, 17) })
			setFromX(input.Position.X, not commitOnRelease)
			moveConn = UserInputService.InputChanged:Connect(function(chg: InputObject)
				if not dragging then
					return
				end
				if chg.UserInputType == Enum.UserInputType.MouseMovement or chg.UserInputType == Enum.UserInputType.Touch then
					setFromX(chg.Position.X, not commitOnRelease)
				end
			end)
			endConn = UserInputService.InputEnded:Connect(function(ended: InputObject)
				if ended.UserInputType == Enum.UserInputType.MouseButton1 or ended.UserInputType == Enum.UserInputType.Touch then
					disconnectDrag()
					Animator.Tween(thumb, Tokens.Motion.Fast, { Size = UDim2.fromOffset(trackHovered and 15 or 14, trackHovered and 15 or 14) })
					if not trackHovered then
						Animator.Tween(trackStroke, Tokens.Motion.Base, { Color = theme:Get("Stroke"), Transparency = 0.45 })
					end
					if not rowHovered then
						Animator.Tween(row, Tokens.Motion.Base, { BackgroundColor3 = theme:Get("Element") })
					end
					if commitOnRelease and cfg.Callback then
						cfg.Callback(value)
					end
				end
			end)
		end
	end)

	if editable and valChip:IsA("TextBox") then
		valChip.Focused:Connect(function()
			if bStroke then
				Animator.Tween(bStroke, Tokens.Motion.Fast, { Color = theme:Get("Accent"), Transparency = 0.08 })
			end
		end)
		valChip.FocusLost:Connect(function()
			if bStroke then
				Animator.Tween(bStroke, Tokens.Motion.Base, { Color = theme:Get("Stroke"), Transparency = 0.4 })
			end
			local numStr = valChip.Text:match("%-?%d+%.?%d*")
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

	local handle = { Frame = row }
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

--// DROPDOWN (overlay popup with built-in live search)
function Controls.Dropdown(parent: Instance, window: any, theme: any, cfg: any)
	cfg = cfg or {}
	local name = tostring(cfg.Name or "Dropdown")
	local items: { string } = {}
	if type(cfg.Items) == "table" then
		for _, it in ipairs(cfg.Items) do
			table.insert(items, tostring(it))
		end
	end
	local placeholder = tostring(cfg.StartingText or "Select...")
	local emptyText = tostring(cfg.EmptyText or "No items available")
	local stacked = cfg.Stacked == true

	local selected: string? = nil
	local initialVal = cfg.Value
	if initialVal == nil then
		initialVal = cfg.Default
	end
	if initialVal ~= nil then
		selected = tostring(initialVal)
	elseif cfg.StartingText ~= nil then
		local stStr = tostring(cfg.StartingText)
		for _, it in ipairs(items) do
			if it == stStr then
				selected = stStr
				break
			end
		end
	end

	local row = makeRow(parent, stacked and 64 or 42, theme, name)
	row.Name = "Dropdown"
	Primitives.Padding(row, 6, 10, 6, 12)

	local lbl = Instance.new("TextLabel")
	lbl.Size = stacked and UDim2.new(1, 0, 0, 18) or UDim2.new(0.46, -6, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.ZIndex = Tokens.Layer.Content + 2
	Tokens.Typeset(lbl, "Label", theme:Get("Text"))
	lbl.Parent = row
	theme:Bind(lbl, "TextColor3", "Text")

	local trigger = Instance.new("TextButton")
	trigger.Size = stacked and UDim2.new(1, 0, 0, 28) or UDim2.new(0.54, 0, 0, 28)
	trigger.Position = stacked and UDim2.new(0, 0, 1, -28) or UDim2.new(0.46, 0, 0.5, -14)
	trigger.BackgroundColor3 = theme:Get("Card")
	trigger.BorderSizePixel = 0
	trigger.Text = ""
	trigger.AutoButtonColor = false
	trigger.ZIndex = Tokens.Layer.Content + 3
	trigger.Parent = row
	Primitives.Corner(trigger, Tokens.Radius.Chip)
	local trigStroke = Primitives.Stroke(trigger, theme:Get("Stroke"), 1, 0.35)
	theme:Bind(trigger, "BackgroundColor3", "Card")
	theme:Bind(trigStroke, "Color", "Stroke")

	local valLabel = Instance.new("TextLabel")
	valLabel.Size = UDim2.new(1, -26, 1, 0)
	valLabel.Position = UDim2.new(0, 10, 0, 0)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = selected or placeholder
	valLabel.TextXAlignment = Enum.TextXAlignment.Left
	valLabel.TextTruncate = Enum.TextTruncate.AtEnd
	valLabel.ZIndex = Tokens.Layer.Content + 4
	local initColorKey = selected ~= nil and "Text" or "SubText"
	Tokens.Typeset(valLabel, "Body", theme:Get(initColorKey))
	valLabel.Parent = trigger
	theme:Bind(valLabel, "TextColor3", initColorKey)

	local chev = Instance.new("TextLabel")
	chev.Size = UDim2.fromOffset(18, 18)
	chev.AnchorPoint = Vector2.new(1, 0.5)
	chev.Position = UDim2.new(1, -6, 0.5, 0)
	chev.BackgroundTransparency = 1
	chev.Text = "▾"
	chev.ZIndex = Tokens.Layer.Content + 4
	Tokens.Typeset(chev, "Caption", theme:Get("MutedText"))
	chev.Parent = trigger
	theme:Bind(chev, "TextColor3", "MutedText")

	local scrollParent: ScrollingFrame? = nil
	do
		local cur: Instance? = parent
		while cur do
			if cur:IsA("ScrollingFrame") then
				scrollParent = cur
				break
			end
			cur = cur.Parent
		end
	end

	local open = false
	local popup: Frame? = nil
	local popupShadow: Frame? = nil
	local outsideConn: RBXScriptConnection? = nil
	local scrollConn: RBXScriptConnection? = nil
	local activeRebuild: ((string) -> ())? = nil
	local currentFilter = ""

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
		currentFilter = ""
		if not open then
			return
		end
		open = false
		if Animator.Alive(chev) then
			Animator.Tween(chev, Tokens.Motion.Fast, { Rotation = 0 })
		end
		if Animator.Alive(trigStroke) then
			Animator.Tween(trigStroke, Tokens.Motion.Fast, { Color = theme:Get("Stroke"), Transparency = 0.35 })
		end
		if Animator.Alive(trigger) then
			Animator.Tween(trigger, Tokens.Motion.Fast, { BackgroundColor3 = theme:Get("Card") })
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
			Animator.Tween(trigger, Tokens.Motion.Fast, { BackgroundColor3 = theme:Get("ElementHover") })
			Animator.Tween(trigStroke, Tokens.Motion.Fast, { Color = theme:Get("StrokeBright"), Transparency = 0.2 })
		end
	end)
	trigger.MouseLeave:Connect(function()
		if not open then
			Animator.Tween(trigger, Tokens.Motion.Base, { BackgroundColor3 = theme:Get("Card") })
			Animator.Tween(trigStroke, Tokens.Motion.Base, { Color = theme:Get("Stroke"), Transparency = 0.35 })
		end
	end)

	local function selectItem(choice: string?, silent: boolean?)
		if choice == nil then
			selected = nil
			if Animator.Alive(valLabel) then
				valLabel.Text = placeholder
				theme:Bind(valLabel, "TextColor3", "SubText")
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
			theme:Bind(valLabel, "TextColor3", "Text")
		end
		closePopup()
		if not silent and cfg.Callback then
			cfg.Callback(choiceStr)
		end
	end

	local handle: any = { Frame = row }

	local function openPopup()
		if window._activePopupClose then
			window._activePopupClose()
		end
		if not Animator.Alive(window.Overlay) or not Animator.Alive(window.Main) then
			return
		end
		if type(cfg.OnOpen) == "function" then
			pcall(cfg.OnOpen, handle)
		end
		if not Animator.Alive(window.Overlay) or not Animator.Alive(window.Main) then
			return
		end

		open = true
		window._activePopupClose = closePopup
		Animator.Tween(chev, Tokens.Motion.Fast, { Rotation = 180 })
		Animator.Tween(trigStroke, Tokens.Motion.Fast, { Color = theme:Get("Accent"), Transparency = 0.1 })

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
		local y = openUp
			and math.max(topBarInset + 4, trigPos.Y - gap - popH)
			or (trigPos.Y + trigSize.Y + gap)

		-- Subtle drop shadow behind popup for visual separation
		local shadow = Instance.new("Frame")
		shadow.Name = "DropdownShadow"
		shadow.Position = UDim2.fromOffset(x - 4, y - 2)
		shadow.Size = UDim2.fromOffset(popW + 8, popH + 8)
		shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		shadow.BackgroundTransparency = 0.76
		shadow.BorderSizePixel = 0
		shadow.ZIndex = Tokens.Layer.Popup + 1
		shadow.Parent = window.Overlay
		Primitives.Corner(shadow, Tokens.Radius.Card + 3)
		popupShadow = shadow

		local bgKey = theme.Colors.Surface and "Surface" or "Card"
		local p = Instance.new("Frame")
		p.Name = "DropdownPopup"
		p.Position = UDim2.fromOffset(x, y)
		p.Size = UDim2.fromOffset(popW, popH)
		p.BackgroundColor3 = theme:Get(bgKey)
		p.BorderSizePixel = 0
		p.ClipsDescendants = true
		p.Active = true
		p.ZIndex = Tokens.Layer.Popup + 2
		p.Parent = window.Overlay
		Primitives.Corner(p, Tokens.Radius.Card)
		local pStroke = Primitives.Stroke(p, theme:Get("StrokeBright"), 1, 0.12)
		theme:Bind(p, "BackgroundColor3", bgKey)
		theme:Bind(pStroke, "Color", "StrokeBright")
		popup = p

		local list = Instance.new("ScrollingFrame")
		list.Size = UDim2.new(1, -4, 1, -(searchH + 6))
		list.Position = UDim2.fromOffset(0, searchH)
		list.BackgroundTransparency = 1
		list.BorderSizePixel = 0
		list.ScrollBarThickness = 4
		list.ScrollBarImageColor3 = theme:Get("SubText")
		list.ScrollBarImageTransparency = 0.45
		list.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
		list.CanvasSize = UDim2.fromOffset(0, 0)
		list.AutomaticCanvasSize = Enum.AutomaticSize.Y
		list.ZIndex = Tokens.Layer.Popup + 3
		list.Parent = p
		Primitives.Padding(list, 6, 6, 6, 6)
		theme:Bind(list, "ScrollBarImageColor3", "SubText")

		local ll = Instance.new("UIListLayout")
		ll.Padding = UDim.new(0, 3)
		ll.SortOrder = Enum.SortOrder.LayoutOrder
		ll.Parent = list

		local function rebuild(filter: string)
			currentFilter = filter
			list.CanvasPosition = Vector2.zero
			for _, child in ipairs(list:GetChildren()) do
				if child:IsA("GuiObject") then
					child:Destroy()
				end
			end
			local q = string.lower(filter)
			local shown = 0
			for idx, item in ipairs(items) do
				if q == "" or string.find(string.lower(item), q, 1, true) ~= nil then
					shown += 1
					local isSel = (item == selected)
					local opt = Instance.new("TextButton")
					opt.Size = UDim2.new(1, 0, 0, 27)
					opt.BackgroundColor3 = isSel and theme:Get("AccentSoft") or theme:Get("Element")
					opt.BackgroundTransparency = isSel and 0.15 or 1
					opt.BorderSizePixel = 0
					opt.Text = ""
					opt.AutoButtonColor = false
					opt.LayoutOrder = idx
					opt.ZIndex = Tokens.Layer.Popup + 4
					opt.Parent = list
					Primitives.Corner(opt, Tokens.Radius.Chip)

					local optLbl = Instance.new("TextLabel")
					optLbl.Size = UDim2.new(1, -16, 1, 0)
					optLbl.Position = UDim2.new(0, 8, 0, 0)
					optLbl.BackgroundTransparency = 1
					optLbl.Text = item
					optLbl.TextXAlignment = Enum.TextXAlignment.Left
					optLbl.TextTruncate = Enum.TextTruncate.AtEnd
					optLbl.ZIndex = Tokens.Layer.Popup + 5
					Tokens.Typeset(optLbl, "Body", isSel and theme:Get("Accent") or theme:Get("Text"))
					optLbl.Parent = opt

					opt.MouseEnter:Connect(function()
						if not isSel then
							Animator.Tween(opt, Tokens.Motion.Fast, { BackgroundTransparency = 0, BackgroundColor3 = theme:Get("ElementHover") })
						end
					end)
					opt.MouseLeave:Connect(function()
						if not isSel then
							Animator.Tween(opt, Tokens.Motion.Fast, { BackgroundTransparency = 1 })
						end
					end)
					opt.MouseButton1Click:Connect(function()
						selectItem(item, false)
					end)
				end
			end

			if shown == 0 then
				local empty = Instance.new("TextLabel")
				empty.Size = UDim2.new(1, 0, 0, 28)
				empty.BackgroundTransparency = 1
				empty.Text = #items == 0 and emptyText or "No matches"
				empty.ZIndex = Tokens.Layer.Popup + 4
				Tokens.Typeset(empty, "Caption", theme:Get("MutedText"))
				empty.Parent = list
			end
		end
		activeRebuild = rebuild

		if showSearch then
			local searchWrap = Instance.new("Frame")
			searchWrap.Size = UDim2.new(1, 0, 0, searchH)
			searchWrap.BackgroundTransparency = 1
			searchWrap.ZIndex = Tokens.Layer.Popup + 4
			searchWrap.Parent = p
			Primitives.Padding(searchWrap, 6, 6, 2, 6)

			local box = Instance.new("TextBox")
			box.Size = UDim2.fromScale(1, 1)
			box.BackgroundColor3 = theme:Get("Element")
			box.BorderSizePixel = 0
			box.Text = ""
			box.PlaceholderText = "Filter..."
			box.ClearTextOnFocus = false
			box.TextXAlignment = Enum.TextXAlignment.Left
			box.ZIndex = Tokens.Layer.Popup + 5
			Tokens.Typeset(box, "Body", theme:Get("Text"))
			box.PlaceholderColor3 = theme:Get("MutedText")
			box.Parent = searchWrap
			Primitives.Corner(box, Tokens.Radius.Chip)
			Primitives.Padding(box, 0, 8, 0, 8)
			local boxStroke = Primitives.Stroke(box, theme:Get("Stroke"), 1, 0.45)
			theme:Bind(box, "BackgroundColor3", "Element")
			theme:Bind(box, "TextColor3", "Text")
			theme:Bind(box, "PlaceholderColor3", "MutedText")
			theme:Bind(boxStroke, "Color", "Stroke")

			box.Focused:Connect(function()
				Animator.Tween(boxStroke, Tokens.Motion.Fast, { Color = theme:Get("Accent"), Transparency = 0.1 })
			end)
			box.FocusLost:Connect(function()
				Animator.Tween(boxStroke, Tokens.Motion.Base, { Color = theme:Get("Stroke"), Transparency = 0.45 })
			end)
			box:GetPropertyChangedSignal("Text"):Connect(function()
				rebuild(box.Text)
			end)
		end

		rebuild("")

		p.Destroying:Connect(function()
			disconnectPopupConns()
			if shadow and Animator.Alive(shadow) then
				shadow:Destroy()
			end
		end)
		if scrollParent and Animator.Alive(scrollParent) then
			scrollConn = scrollParent:GetPropertyChangedSignal("CanvasPosition"):Connect(closePopup)
		end
		outsideConn = UserInputService.InputBegan:Connect(function(input: InputObject)
			if not open or not popup or not Animator.Alive(popup) then
				closePopup()
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local pos = input.Position
				local inPopup = pos.X >= popup.AbsolutePosition.X and pos.X <= popup.AbsolutePosition.X + popup.AbsoluteSize.X
					and pos.Y >= popup.AbsolutePosition.Y and pos.Y <= popup.AbsolutePosition.Y + popup.AbsoluteSize.Y
				local inTrig = pos.X >= trigger.AbsolutePosition.X and pos.X <= trigger.AbsolutePosition.X + trigger.AbsoluteSize.X
					and pos.Y >= trigger.AbsolutePosition.Y and pos.Y <= trigger.AbsolutePosition.Y + trigger.AbsoluteSize.Y
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
			theme:Bind(valLabel, "TextColor3", "SubText")
		end
		closePopup()
	end
	function handle:AddItems(listToAdd: { any })
		if type(listToAdd) ~= "table" then
			return
		end
		for _, it in ipairs(listToAdd) do
			table.insert(items, tostring(it))
		end
	end
	function handle:Refresh(newItems: { any }, keepSelection: boolean?)
		table.clear(items)
		if type(newItems) == "table" then
			for _, it in ipairs(newItems) do
				table.insert(items, tostring(it))
			end
		end
		if selected ~= nil then
			local stillExists = false
			if keepSelection ~= false then
				for _, it in ipairs(items) do
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
					theme:Bind(valLabel, "TextColor3", "SubText")
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

--// TEXTBOX
function Controls.Textbox(parent: Instance, _window: any, theme: any, cfg: any)
	cfg = cfg or {}
	local name = tostring(cfg.Name or "Input")
	local stacked = cfg.Stacked == true

	local row = makeRow(parent, stacked and 64 or 42, theme, name)
	row.Name = "Textbox"
	Primitives.Padding(row, 6, 10, 6, 12)

	local lbl = Instance.new("TextLabel")
	lbl.Size = stacked and UDim2.new(1, 0, 0, 18) or UDim2.new(0.45, -6, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.ZIndex = Tokens.Layer.Content + 2
	Tokens.Typeset(lbl, "Label", theme:Get("Text"))
	lbl.Parent = row
	theme:Bind(lbl, "TextColor3", "Text")

	local box = Instance.new("TextBox")
	box.Size = stacked and UDim2.new(1, 0, 0, 28) or UDim2.new(0.55, 0, 0, 28)
	box.Position = stacked and UDim2.new(0, 0, 1, -28) or UDim2.new(0.45, 0, 0.5, -14)
	box.BackgroundColor3 = theme:Get("Card")
	box.BorderSizePixel = 0
	box.Text = tostring(cfg.Default or "")
	box.PlaceholderText = tostring(cfg.Placeholder or "")
	box.ClearTextOnFocus = false
	box.TextXAlignment = Enum.TextXAlignment.Left
	box.TextTruncate = Enum.TextTruncate.AtEnd
	box.ZIndex = Tokens.Layer.Content + 3
	Tokens.Typeset(box, "Body", theme:Get("Text"))
	box.PlaceholderColor3 = theme:Get("MutedText")
	box.Parent = row
	Primitives.Corner(box, Tokens.Radius.Chip)
	Primitives.Padding(box, 0, 8, 0, 8)
	local bStroke = Primitives.Stroke(box, theme:Get("Stroke"), 1, 0.35)
	theme:Bind(box, "BackgroundColor3", "Card")
	theme:Bind(box, "TextColor3", "Text")
	theme:Bind(box, "PlaceholderColor3", "MutedText")
	theme:Bind(bStroke, "Color", "Stroke")

	box.Focused:Connect(function()
		Animator.Tween(bStroke, Tokens.Motion.Fast, { Color = theme:Get("Accent"), Transparency = 0.08 })
	end)
	box.FocusLost:Connect(function()
		Animator.Tween(bStroke, Tokens.Motion.Base, { Color = theme:Get("Stroke"), Transparency = 0.35 })
		if cfg.Callback then
			cfg.Callback(box.Text)
		end
	end)

	local handle = { Frame = row, Input = box }
	function handle:Set(text: string, silent: boolean?)
		if Animator.Alive(box) then
			box.Text = tostring(text or "")
		end
		if not silent and cfg.Callback then
			cfg.Callback(box.Text)
		end
	end
	function handle:Get(): string
		return Animator.Alive(box) and box.Text or ""
	end
	return handle
end

--// KEYBIND
function Controls.Keybind(parent: Instance, window: any, theme: any, cfg: any)
	cfg = cfg or {}
	local name = tostring(cfg.Name or "Keybind")
	local currentKey: Enum.KeyCode? = cfg.Keybind
	local allowClear = cfg.AllowClear == true
	local listening = false
	local activeToken: any = nil

	local row = makeRow(parent, 42, theme, name)
	row.Name = "Keybind"
	Primitives.Padding(row, 6, 10, 6, 12)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -110, 1, 0)
	lbl.BackgroundTransparency = 1
	lbl.Text = name
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextTruncate = Enum.TextTruncate.AtEnd
	lbl.ZIndex = Tokens.Layer.Content + 2
	Tokens.Typeset(lbl, "Label", theme:Get("Text"))
	lbl.Parent = row
	theme:Bind(lbl, "TextColor3", "Text")

	local chip = Instance.new("TextButton")
	chip.Size = UDim2.fromOffset(96, 26)
	chip.AnchorPoint = Vector2.new(1, 0.5)
	chip.Position = UDim2.new(1, 0, 0.5, 0)
	chip.BackgroundColor3 = theme:Get("Card")
	chip.BorderSizePixel = 0
	chip.Text = currentKey and currentKey.Name or "None"
	chip.AutoButtonColor = false
	chip.ZIndex = Tokens.Layer.Content + 3
	Tokens.Typeset(chip, "Mono", theme:Get("Accent"))
	chip.Parent = row
	Primitives.Corner(chip, Tokens.Radius.Chip)
	local cStroke = Primitives.Stroke(chip, theme:Get("Stroke"), 1, 0.35)
	theme:Bind(chip, "BackgroundColor3", "Card")
	theme:Bind(chip, "TextColor3", "Accent")
	theme:Bind(cStroke, "Color", "Stroke")

	local function refreshChip()
		if not Animator.Alive(chip) then
			return
		end
		chip.Text = listening and "Press key..." or (currentKey and currentKey.Name or "None")
		Animator.Tween(cStroke, Tokens.Motion.Fast, {
			Color = listening and theme:Get("Accent") or theme:Get("Stroke"),
			Transparency = listening and 0.05 or 0.35,
		})
	end

	local listenConn: RBXScriptConnection? = nil
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
			Animator.Tween(chip, Tokens.Motion.Fast, { BackgroundColor3 = theme:Get("ElementHover") })
		end
	end)
	chip.MouseLeave:Connect(function()
		if not listening then
			Animator.Tween(chip, Tokens.Motion.Base, { BackgroundColor3 = theme:Get("Card") })
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

		listenConn = UserInputService.InputBegan:Connect(function(input: InputObject, gpe: boolean)
			if not listening then
				return
			end
			-- Escape cancels BEFORE gpe check so Roblox menu/gpe cannot trap listening mode
			if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Escape then
				stopListening()
				refreshChip()
				return
			end
			-- Clicking/tapping outside the chip cancels listening cleanly
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				local pos = input.Position
				local inChip = Animator.Alive(chip)
					and pos.X >= chip.AbsolutePosition.X and pos.X <= chip.AbsolutePosition.X + chip.AbsoluteSize.X
					and pos.Y >= chip.AbsolutePosition.Y and pos.Y <= chip.AbsolutePosition.Y + chip.AbsoluteSize.Y
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

	local handle = { Frame = row }
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
