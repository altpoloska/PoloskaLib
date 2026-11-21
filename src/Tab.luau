--!strict
-- PoloskaLib v2 Tab: sidebar navigation item with animated pill highlight,
-- active-feature badge, responsive scrollable page, Columns, collapsible
-- glass Group cards, and live cross-tab search filtering.

local Tokens = require("./Tokens")
local Animator = require("./Animator")
local Primitives = require("./Primitives")
local Controls = require("./Controls")

local Tab = {}

function Tab.Create(window: any, config: any)
	config = config or {}
	local theme = window._theme
	local name = tostring(config.Name or "Tab")
	local tab: any = {
		Name = name,
		_active = false,
		_window = window,
	}

	-- Sidebar navigation button
	local btn = Instance.new("TextButton")
	btn.Name = "Tab_" .. name
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.BackgroundColor3 = theme:Get("Element")
	btn.BackgroundTransparency = 1
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = false
	btn.LayoutOrder = #window.Tabs + 1
	btn.ZIndex = Tokens.Layer.Content + 2
	btn.Parent = window.TabList
	Primitives.Corner(btn, Tokens.Radius.Control)
	local btnStroke = Primitives.Stroke(btn, theme:Get("Accent"), 1, 1)
	theme:Bind(btnStroke, "Color", "Accent")

	-- Animated gradient left accent pill
	local mark = Instance.new("Frame")
	mark.Name = "Mark"
	mark.AnchorPoint = Vector2.new(0, 0.5)
	mark.Position = UDim2.new(0, 5, 0.5, 0)
	mark.Size = UDim2.fromOffset(3, 0)
	mark.BackgroundColor3 = Color3.new(1, 1, 1)
	mark.BorderSizePixel = 0
	mark.ZIndex = Tokens.Layer.Content + 3
	mark.Parent = btn
	Primitives.Corner(mark, 2)
	local markGrad = Primitives.Gradient(mark, theme:Get("Accent"), theme:Get("AccentSecondary"), 90)
	theme:BindGradient(markGrad, "Accent", "AccentSecondary")

	local btnLabel = Instance.new("TextLabel")
	btnLabel.Size = UDim2.new(1, -22, 1, 0)
	btnLabel.Position = UDim2.new(0, 14, 0, 0)
	btnLabel.BackgroundTransparency = 1
	btnLabel.Text = name
	btnLabel.TextXAlignment = Enum.TextXAlignment.Left
	btnLabel.TextTruncate = Enum.TextTruncate.AtEnd
	btnLabel.ZIndex = Tokens.Layer.Content + 3
	Tokens.Typeset(btnLabel, "Label", theme:Get("SubText"))
	btnLabel.Parent = btn

	-- Right status badge (active features count or search matches)
	local badge = Instance.new("TextLabel")
	badge.Name = "Badge"
	badge.AnchorPoint = Vector2.new(1, 0.5)
	badge.Position = UDim2.new(1, -8, 0.5, 0)
	badge.Size = UDim2.fromOffset(0, 16)
	badge.AutomaticSize = Enum.AutomaticSize.X
	badge.BackgroundColor3 = theme:Get("Card")
	badge.BorderSizePixel = 0
	badge.Text = ""
	badge.Visible = false
	badge.ZIndex = Tokens.Layer.Content + 3
	Tokens.Typeset(badge, "Caption", theme:Get("Success"))
	badge.Parent = btn
	Primitives.Corner(badge, Tokens.Radius.Pill)
	Primitives.Padding(badge, 0, 5, 0, 5)
	local badgeConstraint = Instance.new("UISizeConstraint")
	badgeConstraint.MinSize = Vector2.new(18, 16)
	badgeConstraint.Parent = badge
	local badgeStroke = Primitives.Stroke(badge, theme:Get("Success"), 1, 0.45)
	theme:Bind(badge, "BackgroundColor3", "Card")
	theme:Bind(badge, "TextColor3", "Success")
	theme:Bind(badgeStroke, "Color", "Success")

	local activeBadgeCount = 0
	local searchMatchCount: number? = nil

	local function refreshBadge()
		if not Animator.Alive(badge) then
			return
		end
		if searchMatchCount ~= nil then
			badge.Visible = searchMatchCount > 0
			badge.Text = tostring(searchMatchCount)
			btnLabel.TextTransparency = searchMatchCount > 0 and 0 or 0.55
			theme:Bind(badge, "TextColor3", "Warning")
			theme:Bind(badgeStroke, "Color", "Warning")
			badgeStroke.Transparency = 0.35
		else
			btnLabel.TextTransparency = 0
			badge.Visible = activeBadgeCount > 0
			badge.Text = tostring(activeBadgeCount)
			theme:Bind(badge, "TextColor3", "Success")
			theme:Bind(badgeStroke, "Color", "Success")
			badgeStroke.Transparency = 0.45
		end
		if Animator.Alive(btnLabel) then
			btnLabel.Size = badge.Visible and UDim2.new(1, -46, 1, 0) or UDim2.new(1, -22, 1, 0)
		end
	end

	-- Content page
	local page = Instance.new("ScrollingFrame")
	page.Name = "Page_" .. name
	page.Size = UDim2.new(1, -4, 1, -8)
	page.Position = UDim2.fromOffset(0, 0)
	page.BackgroundTransparency = 1
	page.BorderSizePixel = 0
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = theme:Get("SubText")
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
	theme:Bind(page, "ScrollBarImageColor3", "SubText")

	local pageLayout = Instance.new("UIListLayout")
	pageLayout.Padding = UDim.new(0, 12)
	pageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	pageLayout.Parent = page

	local emptyState = Instance.new("TextLabel")
	emptyState.Name = "SearchEmptyState"
	emptyState.Size = UDim2.new(1, 0, 0, 56)
	emptyState.BackgroundTransparency = 1
	emptyState.Text = ""
	emptyState.TextXAlignment = Enum.TextXAlignment.Center
	emptyState.TextYAlignment = Enum.TextYAlignment.Center
	emptyState.TextWrapped = true
	emptyState.Visible = false
	emptyState.LayoutOrder = -1
	emptyState.ZIndex = Tokens.Layer.Content + 2
	Tokens.Typeset(emptyState, "Body", theme:Get("MutedText"))
	emptyState.Parent = page
	theme:Bind(emptyState, "TextColor3", "MutedText")

	local function syncCanvas()
		if not Animator.Alive(page) or not Animator.Alive(pageLayout) then
			return
		end
		local s = (window.EffectiveScale and window.EffectiveScale > 0) and window.EffectiveScale or 1
		page.CanvasSize = UDim2.fromOffset(0, math.max(0, pageLayout.AbsoluteContentSize.Y / s + 28))
	end
	pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncCanvas)
	task.defer(syncCanvas)

	local function paintTabButton(animated: boolean)
		if not Animator.Alive(btn) then
			return
		end
		local active = tab._active
		local bgColor = active and theme:Get("Element") or theme:Get("Element")
		local bgTrans = active and 0.15 or 1
		local txtColor = active and theme:Get("Text") or theme:Get("SubText")
		local stTrans = active and 0.55 or 1
		local markSize = active and UDim2.fromOffset(3, 18) or UDim2.fromOffset(3, 0)
		if animated then
			Animator.Tween(btn, Tokens.Motion.Base, { BackgroundColor3 = bgColor, BackgroundTransparency = bgTrans })
			Animator.Tween(btnLabel, Tokens.Motion.Base, { TextColor3 = txtColor })
			Animator.Tween(btnStroke, Tokens.Motion.Base, { Transparency = stTrans })
			Animator.Tween(mark, Tokens.Motion.Base, { Size = markSize })
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
		for _, other in ipairs(window.Tabs) do
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
			Animator.Tween(btn, Tokens.Motion.Fast, { BackgroundColor3 = theme:Get("ElementHover"), BackgroundTransparency = 0.35 })
			Animator.Tween(btnLabel, Tokens.Motion.Fast, { TextColor3 = theme:Get("Text") })
		end
	end)
	btn.MouseLeave:Connect(function()
		if not tab._active then
			Animator.Tween(btn, Tokens.Motion.Base, { BackgroundTransparency = 1 })
			Animator.Tween(btnLabel, Tokens.Motion.Base, { TextColor3 = theme:Get("SubText") })
		end
	end)
	btn.MouseButton1Click:Connect(function()
		tab._searchTabPicked = true
		activate()
	end)

	-- Track registered groups and columns for clean cross-tab search filtering
	local registeredGroups: {
		{
			Frame: Frame,
			Body: Frame,
			TitleLower: string,
			Collapsible: boolean,
			GetCollapsed: () -> boolean,
			SetCollapsed: (boolean) -> (),
			_wasCollapsed: boolean?,
		}
	} = {}
	local registeredColumns: { { Frame: Frame, Left: Frame, Right: Frame } } = {}

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
		local rawQuery = query or ""
		local q = string.lower(rawQuery)
		local matches = 0
		if q == "" then
			if Animator.Alive(emptyState) then
				emptyState.Visible = false
			end
			for _, c in ipairs(registeredColumns) do
				if Animator.Alive(c.Frame) then
					c.Frame.Visible = true
				end
			end
			for _, g in ipairs(registeredGroups) do
				if Animator.Alive(g.Frame) then
					g.Frame.Visible = true
				end
				if Animator.Alive(g.Body) then
					for _, child in ipairs(g.Body:GetChildren()) do
						if child:IsA("GuiObject") then
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
		for _, g in ipairs(registeredGroups) do
			if Animator.Alive(g.Frame) and Animator.Alive(g.Body) then
				local titleHit = string.find(g.TitleLower, q, 1, true) ~= nil
				local groupHits = 0
				for _, child in ipairs(g.Body:GetChildren()) do
					if child:IsA("GuiObject") then
						local s = child:GetAttribute("SearchText")
						local hit = titleHit or (typeof(s) == "string" and string.find(s, q, 1, true) ~= nil)
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

		for _, c in ipairs(registeredColumns) do
			if Animator.Alive(c.Frame) then
				local anyVisible = false
				for _, col in ipairs({ c.Left, c.Right }) do
					if Animator.Alive(col) then
						for _, child in ipairs(col:GetChildren()) do
							if child:IsA("GuiObject") and child.Visible then
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

	--// COLUMNS (2-column layout container)
	function tab:Columns(cfg: any)
		cfg = cfg or {}
		local gap = tonumber(cfg.Gap) or 12

		local row = Instance.new("Frame")
		row.Name = "Columns"
		row.Size = UDim2.new(1, 0, 0, 0)
		row.AutomaticSize = Enum.AutomaticSize.Y
		row.BackgroundTransparency = 1
		row.ZIndex = Tokens.Layer.Content
		row.Parent = page

		local function makeColumn(colName: string, posX: UDim2): Frame
			local col = Instance.new("Frame")
			col.Name = colName
			col.Size = UDim2.new(0.5, -math.floor(gap / 2), 0, 0)
			col.Position = posX
			col.AutomaticSize = Enum.AutomaticSize.Y
			col.BackgroundTransparency = 1
			col.ZIndex = Tokens.Layer.Content
			col.Parent = row

			local cl = Instance.new("UIListLayout")
			cl.Padding = UDim.new(0, 12)
			cl.SortOrder = Enum.SortOrder.LayoutOrder
			cl.Parent = col
			cl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncCanvas)
			return col
		end

		local left = makeColumn("Left", UDim2.new(0, 0, 0, 0))
		local right = makeColumn("Right", UDim2.new(0.5, math.ceil(gap / 2), 0, 0))

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

	--// GROUP (glass card container with optional collapse)
	function tab:Group(cfg: any)
		cfg = cfg or {}
		local groupName = tostring(cfg.Name or "Group")
		local targetParent = cfg.Parent or page
		local collapsible = cfg.Collapsible == true
		local collapsed = collapsible and cfg.Collapsed == true

		local card = Instance.new("Frame")
		card.Name = "Group_" .. groupName
		card.Size = UDim2.new(1, 0, 0, 0)
		card.AutomaticSize = Enum.AutomaticSize.Y
		card.BackgroundColor3 = theme:Get("Card")
		card.BorderSizePixel = 0
		card.ClipsDescendants = true
		card.ZIndex = Tokens.Layer.Content + 1
		card.Parent = targetParent
		Primitives.Corner(card, Tokens.Radius.Card)
		local cardStroke = Primitives.Stroke(card, theme:Get("Stroke"), 1, 0.58)
		theme:Bind(card, "BackgroundColor3", "Card")
		theme:Bind(cardStroke, "Color", "Stroke")

		local cardLayout = Instance.new("UIListLayout")
		cardLayout.SortOrder = Enum.SortOrder.LayoutOrder
		cardLayout.Parent = card

		local header: GuiObject
		if collapsible then
			local headerBtn = Instance.new("TextButton")
			headerBtn.Text = ""
			headerBtn.AutoButtonColor = false
			headerBtn.BackgroundColor3 = theme:Get("ElementHover")
			headerBtn.BackgroundTransparency = 1
			headerBtn.BorderSizePixel = 0
			Primitives.Corner(headerBtn, Tokens.Radius.Card)
			theme:Bind(headerBtn, "BackgroundColor3", "ElementHover")
			header = headerBtn
		else
			local headerFrame = Instance.new("Frame")
			headerFrame.BackgroundTransparency = 1
			headerFrame.BorderSizePixel = 0
			header = headerFrame
		end
		header.Name = "Header"
		header.Size = UDim2.new(1, 0, 0, 34)
		header.LayoutOrder = 1
		header.ZIndex = Tokens.Layer.Content + 2
		header.Parent = card

		local dot = Instance.new("Frame")
		dot.Size = UDim2.fromOffset(6, 6)
		dot.AnchorPoint = Vector2.new(0, 0.5)
		dot.Position = UDim2.new(0, 12, 0.5, 0)
		dot.BackgroundColor3 = theme:Get("Accent")
		dot.BorderSizePixel = 0
		dot.ZIndex = Tokens.Layer.Content + 3
		dot.Parent = header
		Primitives.Corner(dot, Tokens.Radius.Pill)
		theme:Bind(dot, "BackgroundColor3", "Accent")

		local titleLbl = Instance.new("TextLabel")
		titleLbl.Size = UDim2.new(1, collapsible and -42 or -28, 1, 0)
		titleLbl.Position = UDim2.new(0, 24, 0, 0)
		titleLbl.BackgroundTransparency = 1
		titleLbl.Text = groupName
		titleLbl.TextXAlignment = Enum.TextXAlignment.Left
		titleLbl.TextTruncate = Enum.TextTruncate.AtEnd
		titleLbl.ZIndex = Tokens.Layer.Content + 3
		Tokens.Typeset(titleLbl, "Heading", theme:Get("Text"))
		titleLbl.Parent = header
		theme:Bind(titleLbl, "TextColor3", "Text")

		local chev: TextLabel? = nil
		if collapsible then
			local c = Instance.new("TextLabel")
			c.Size = UDim2.fromOffset(18, 18)
			c.AnchorPoint = Vector2.new(1, 0.5)
			c.Position = UDim2.new(1, -10, 0.5, 0)
			c.BackgroundTransparency = 1
			c.Text = "▾"
			c.Rotation = collapsed and -90 or 0
			c.ZIndex = Tokens.Layer.Content + 3
			Tokens.Typeset(c, "Caption", theme:Get("MutedText"))
			c.Parent = header
			theme:Bind(c, "TextColor3", "MutedText")
			chev = c
		end

		local divider = Instance.new("Frame")
		divider.Size = UDim2.new(1, -20, 0, 1)
		divider.Position = UDim2.new(0, 10, 1, -1)
		divider.BackgroundColor3 = theme:Get("Stroke")
		divider.BackgroundTransparency = 0.55
		divider.BorderSizePixel = 0
		divider.Visible = not collapsed
		divider.ZIndex = Tokens.Layer.Content + 2
		divider.Parent = header
		theme:Bind(divider, "BackgroundColor3", "Stroke")

		local body = Instance.new("Frame")
		body.Name = "Body"
		body.Size = UDim2.new(1, 0, 0, 0)
		body.AutomaticSize = Enum.AutomaticSize.Y
		body.BackgroundTransparency = 1
		body.Visible = not collapsed
		body.LayoutOrder = 2
		body.ZIndex = Tokens.Layer.Content + 1
		body.Parent = card
		Primitives.Padding(body, 8, 10, 10, 10)

		local bodyLayout = Instance.new("UIListLayout")
		bodyLayout.Padding = UDim.new(0, 7)
		bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
		bodyLayout.Parent = body
		bodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(syncCanvas)

		local function setCollapsed(v: boolean)
			if not collapsible then
				return
			end
			collapsed = v == true
			body.Visible = not collapsed
			divider.Visible = not collapsed
			if chev and Animator.Alive(chev) then
				Animator.Tween(chev, Tokens.Motion.Fast, { Rotation = collapsed and -90 or 0 })
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
			local headerBtn = header :: TextButton
			headerBtn.MouseEnter:Connect(function()
				Animator.Tween(headerBtn, Tokens.Motion.Fast, { BackgroundTransparency = 0.55 })
			end)
			headerBtn.MouseLeave:Connect(function()
				Animator.Tween(headerBtn, Tokens.Motion.Base, { BackgroundTransparency = 1 })
			end)
			headerBtn.MouseButton1Click:Connect(function()
				setCollapsed(not collapsed)
			end)
		end

		local group: any = { Frame = card, Body = body }
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

	-- Direct control helpers on tab (for simple layouts without groups)
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
