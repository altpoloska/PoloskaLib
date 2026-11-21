--!strict
-- PoloskaLib v2 Window shell: clean layered dark glass surface, animated
-- header accent, live cross-tab search, sidebar with status footer, responsive
-- scaling, persistent launcher, and complete Maid teardown on Gui.Destroying.

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Tokens = require("./Tokens")
local Theme = require("./Theme")
local Maid = require("./Maid")
local Animator = require("./Animator")
local Primitives = require("./Primitives")
local Overlay = require("./Overlay")
local Tab = require("./Tab")

local Window = {}
Window.__index = Window

function Window.Create(config: any)
	config = config or {}
	local theme = Theme.new(config.Theme or "Poloska")
	local maid = Maid.new()

	local self: any = setmetatable({
		Version = Tokens.Version,
		ThemeName = theme.Name,
		Tabs = {} :: { any },
		Visible = true,
		Minimized = false,
		UserScale = math.clamp(tonumber(config.Scale) or 1, UserInputService.TouchEnabled and 0.35 or 0.50, 1.25),
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

	-- Keep the ScreenGui in PlayerGui (works across executors without CoreGui perms).
	local lp = Players.LocalPlayer
	local guiParent = lp:WaitForChild("PlayerGui")
	local old = guiParent:FindFirstChild("MinimalUI")
	if old then
		old:Destroy()
	end

	local gui = Instance.new("ScreenGui")
	gui.Name = "MinimalUI"
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 2147483647
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.IgnoreGuiInset = true
	gui.Enabled = true
	-- Keep menu visible when game cutscene/HideUI listeners filter ScreenGuis.
	gui:SetAttribute("RequiredInteractionUI", true)
	gui.Parent = guiParent
	self.Gui = gui

	gui.Destroying:Connect(function()
		maid:Clean()
		theme:Destroy()
	end)

	local size: UDim2 = config.Size or UDim2.fromOffset(680, 460)
	self.WindowSize = size

	-- Main window frame (clean silhouette, crisp 1px border, no heavy stacked shadows)
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.fromOffset(size.X.Offset, 0)
	main.AnchorPoint = Vector2.new(0.5, 0)
	main.BackgroundColor3 = theme:Get("Background")
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.ZIndex = Tokens.Layer.Content
	main.Parent = gui
	Primitives.Corner(main, Tokens.Radius.Window)
	local mainStroke = Primitives.Stroke(main, theme:Get("Stroke"), 1, 0.22)
	theme:Bind(main, "BackgroundColor3", "Background")
	theme:Bind(mainStroke, "Color", "Stroke")
	self.Main = main
	self.MainStroke = mainStroke

	-- Overlay layer for dropdown popups
	local overlayLayer = Instance.new("Frame")
	overlayLayer.Name = "OverlayLayer"
	overlayLayer.Size = UDim2.fromScale(1, 1)
	overlayLayer.BackgroundTransparency = 1
	overlayLayer.BorderSizePixel = 0
	overlayLayer.ZIndex = Tokens.Layer.Popup
	overlayLayer.Parent = main
	self.Overlay = overlayLayer

	-- Responsive scale (compute BEFORE initial positioning so EffectiveScale is accurate)
	local uiScale = Instance.new("UIScale")
	uiScale.Name = "ResponsiveScale"
	uiScale.Scale = self.UserScale
	uiScale.Parent = main
	self.ScaleObject = uiScale

	local function syncActiveTabCanvas()
		for _, t in ipairs(self.Tabs) do
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

	local camConn: RBXScriptConnection? = nil
	local function applyResponsiveScale()
		if not Animator.Alive(main) or not Animator.Alive(uiScale) then
			return
		end
		local effective = self.UserScale
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize
		local mobileAuto = self.AutoScale and UserInputService.TouchEnabled and vp ~= nil
		if mobileAuto and vp then
			local fitX = (vp.X * 0.90) / math.max(size.X.Offset, 1)
			local fitY = (vp.Y * 0.74) / math.max(size.Y.Offset, 1)
			effective = math.min(effective, fitX, fitY, 0.78)
		end
		effective = math.clamp(effective, mobileAuto and 0.35 or 0.50, 1.25)
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
			camConn = cam:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportChanged)
		end
	end
	watchCamera()
	maid:Connect(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
		watchCamera()
		onViewportChanged()
	end)
	maid:Add(function()
		if camConn then
			camConn:Disconnect()
			camConn = nil
		end
	end)

	-- Animate window entry
	Animator.Tween(main, Tokens.Motion.Slow, { Size = size }, Tokens.Motion.SmoothStyle, Tokens.Motion.SmoothDir)

	--// TOPBAR (rounded top corners to match Main's UICorner; flat bottom seam)
	local TOPBAR_H = 44
	local topbar = Instance.new("Frame")
	topbar.Name = "Topbar"
	topbar.Size = UDim2.new(1, 0, 0, TOPBAR_H)
	topbar.BackgroundColor3 = theme:Get("Sidebar")
	topbar.BorderSizePixel = 0
	topbar.ZIndex = Tokens.Layer.Chrome
	topbar.Parent = main
	Primitives.Corner(topbar, Tokens.Radius.Window)
	theme:Bind(topbar, "BackgroundColor3", "Sidebar")

	local topBottomSeam = Instance.new("Frame")
	topBottomSeam.Name = "BottomSeam"
	topBottomSeam.Size = UDim2.new(1, 0, 0, Tokens.Radius.Window)
	topBottomSeam.Position = UDim2.new(0, 0, 1, -Tokens.Radius.Window)
	topBottomSeam.BackgroundColor3 = theme:Get("Sidebar")
	topBottomSeam.BorderSizePixel = 0
	topBottomSeam.ZIndex = Tokens.Layer.Chrome
	topBottomSeam.Parent = topbar
	theme:Bind(topBottomSeam, "BackgroundColor3", "Sidebar")
	self._topBottomSeam = topBottomSeam

	local topDivider = Instance.new("Frame")
	topDivider.Size = UDim2.new(1, 0, 0, 1)
	topDivider.Position = UDim2.new(0, 0, 1, -1)
	topDivider.BackgroundColor3 = theme:Get("Stroke")
	topDivider.BackgroundTransparency = 0.35
	topDivider.BorderSizePixel = 0
	topDivider.ZIndex = Tokens.Layer.Chrome + 1
	topDivider.Parent = topbar
	theme:Bind(topDivider, "BackgroundColor3", "Stroke")
	self._topDivider = topDivider

	-- Animated gradient accent line under topbar (3-point soft fade, no hard edge)
	local topAccent = Instance.new("Frame")
	topAccent.Size = UDim2.new(1, 0, 0, 2)
	topAccent.Position = UDim2.new(0, 0, 1, -2)
	topAccent.BackgroundColor3 = Color3.new(1, 1, 1)
	topAccent.BorderSizePixel = 0
	topAccent.ZIndex = Tokens.Layer.Chrome + 2
	topAccent.Parent = topbar
	local accentGrad = Primitives.Gradient(topAccent, theme:Get("Accent"), theme:Get("AccentSecondary"), 0)
	accentGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.12),
		NumberSequenceKeypoint.new(1, 1),
	})
	accentGrad.Offset = Vector2.new(-0.65, 0)
	theme:BindGradient(accentGrad, "Accent", "AccentSecondary")
	self._topAccent = topAccent

	local shimmerThread = task.spawn(function()
		while Animator.Alive(accentGrad) do
			Animator.Tween(accentGrad, 3.6, { Offset = Vector2.new(0.65, 0) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(3.6)
			if not Animator.Alive(accentGrad) then
				break
			end
			Animator.Tween(accentGrad, 3.6, { Offset = Vector2.new(-0.65, 0) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			task.wait(3.6)
		end
	end)
	maid:Add(function()
		pcall(task.cancel, shimmerThread)
	end)

	-- Brand indicator dot + Title
	local brandDot = Instance.new("Frame")
	brandDot.Size = UDim2.fromOffset(8, 8)
	brandDot.AnchorPoint = Vector2.new(0, 0.5)
	brandDot.Position = UDim2.new(0, 14, 0.5, 0)
	brandDot.BackgroundColor3 = Color3.new(1, 1, 1)
	brandDot.BorderSizePixel = 0
	brandDot.ZIndex = Tokens.Layer.Chrome + 2
	brandDot.Parent = topbar
	Primitives.Corner(brandDot, Tokens.Radius.Pill)
	local dotGrad = Primitives.Gradient(brandDot, theme:Get("Accent"), theme:Get("AccentSecondary"), 45)
	theme:BindGradient(dotGrad, "Accent", "AccentSecondary")

	local iconSize = UserInputService.TouchEnabled and 32 or 26
	local iconGap = 7
	local searchW = UserInputService.TouchEnabled and 140 or 168

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -(iconSize * 2 + iconGap * 3 + searchW + 46), 1, 0)
	title.Position = UDim2.new(0, 30, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = tostring(config.Name or "PoloskaLib")
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextTruncate = Enum.TextTruncate.AtEnd
	title.ZIndex = Tokens.Layer.Chrome + 2
	Tokens.Typeset(title, "Title", theme:Get("Text"))
	title.Parent = topbar
	theme:Bind(title, "TextColor3", "Text")

	-- Header icon buttons
	local function makeHeaderIcon(iconAsset: string, xOffset: number, hoverKey: string): ImageButton
		local b = Instance.new("ImageButton")
		b.Size = UDim2.fromOffset(iconSize, iconSize)
		b.AnchorPoint = Vector2.new(0, 0.5)
		b.Position = UDim2.new(1, xOffset, 0.5, 0)
		b.BackgroundColor3 = theme:Get("Element")
		b.BorderSizePixel = 0
		b.AutoButtonColor = false
		b.Image = Primitives.ResolveIcon(iconAsset)
		b.ImageColor3 = theme:Get("SubText")
		b.ScaleType = Enum.ScaleType.Fit
		b.ZIndex = Tokens.Layer.Chrome + 2
		b.Parent = topbar
		Primitives.Corner(b, Tokens.Radius.Chip)
		Primitives.Padding(b, math.floor(iconSize / 4))
		local bStroke = Primitives.Stroke(b, theme:Get("Stroke"), 1, 0.65)
		theme:Bind(b, "BackgroundColor3", "Element")
		theme:Bind(b, "ImageColor3", "SubText")
		theme:Bind(bStroke, "Color", "Stroke")

		b.MouseEnter:Connect(function()
			Animator.Tween(b, Tokens.Motion.Fast, {
				BackgroundColor3 = theme:Get(hoverKey),
				ImageColor3 = hoverKey == "Danger" and Color3.fromRGB(255, 255, 255) or theme:Get("Text"),
			})
			Animator.Tween(bStroke, Tokens.Motion.Fast, {
				Transparency = 0.25,
				Color = theme:Get(hoverKey == "Danger" and "Danger" or "StrokeBright"),
			})
		end)
		b.MouseLeave:Connect(function()
			Animator.Tween(b, Tokens.Motion.Base, {
				BackgroundColor3 = theme:Get("Element"),
				ImageColor3 = theme:Get("SubText"),
			})
			Animator.Tween(bStroke, Tokens.Motion.Base, {
				Transparency = 0.65,
				Color = theme:Get("Stroke"),
			})
		end)
		return b
	end

	local closeBtn = makeHeaderIcon(icons.Close, -(iconSize + 10), "Danger")
	closeBtn.MouseButton1Click:Connect(function()
		self:Confirm({
			Title = "Close menu?",
			Text = "Are you sure you want to close the UI?",
			ConfirmText = "Close",
			CancelText = "Cancel",
			Danger = true,
			OnConfirm = function()
				Animator.Tween(mainStroke, 0.16, { Transparency = 1 })
				local tw = Animator.Tween(main, 0.20, { Size = self:_collapsedSize() }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
				if tw then
					tw.Completed:Wait()
				end
				if Animator.Alive(gui) then
					gui:Destroy()
				end
			end,
		})
	end)

	local minBtn = makeHeaderIcon(icons.Minimize, -(iconSize * 2 + iconGap + 10), "ElementHover")
	self.MinimizeButton = minBtn
	self.MinimizeIcon = icons.Minimize
	self.RestoreIcon = icons.Restore
	minBtn.MouseButton1Click:Connect(function()
		self:ToggleMinimize()
	end)

	-- Live cross-tab search field (with search glyph + clear × button)
	local searchWrap = Instance.new("Frame")
	searchWrap.Name = "TopbarSearchWrap"
	searchWrap.Size = UDim2.fromOffset(searchW, iconSize)
	searchWrap.AnchorPoint = Vector2.new(0, 0.5)
	searchWrap.Position = UDim2.new(1, -(iconSize * 2 + iconGap * 2 + 10 + searchW), 0.5, 0)
	searchWrap.BackgroundColor3 = theme:Get("Element")
	searchWrap.BorderSizePixel = 0
	searchWrap.ZIndex = Tokens.Layer.Chrome + 2
	searchWrap.Parent = topbar
	Primitives.Corner(searchWrap, Tokens.Radius.Chip)
	local searchStroke = Primitives.Stroke(searchWrap, theme:Get("Stroke"), 1, 0.42)
	theme:Bind(searchWrap, "BackgroundColor3", "Element")
	theme:Bind(searchStroke, "Color", "Stroke")

	local searchGlyph = Instance.new("Frame")
	searchGlyph.Name = "SearchGlyph"
	searchGlyph.Size = UDim2.fromOffset(14, 14)
	searchGlyph.AnchorPoint = Vector2.new(0, 0.5)
	searchGlyph.Position = UDim2.new(0, 7, 0.5, 0)
	searchGlyph.BackgroundTransparency = 1
	searchGlyph.ZIndex = Tokens.Layer.Chrome + 3
	searchGlyph.Parent = searchWrap

	local glyphLens = Instance.new("Frame")
	glyphLens.Size = UDim2.fromOffset(8, 8)
	glyphLens.Position = UDim2.fromOffset(1, 1)
	glyphLens.BackgroundTransparency = 1
	glyphLens.ZIndex = Tokens.Layer.Chrome + 3
	glyphLens.Parent = searchGlyph
	Primitives.Corner(glyphLens, Tokens.Radius.Pill)
	local glyphLensStroke = Primitives.Stroke(glyphLens, theme:Get("MutedText"), 1.4, 0)
	theme:Bind(glyphLensStroke, "Color", "MutedText")

	local glyphStem = Instance.new("Frame")
	glyphStem.Size = UDim2.fromOffset(5, 2)
	glyphStem.AnchorPoint = Vector2.new(0.5, 0.5)
	glyphStem.Position = UDim2.fromOffset(10, 10)
	glyphStem.Rotation = 45
	glyphStem.BackgroundColor3 = theme:Get("MutedText")
	glyphStem.BorderSizePixel = 0
	glyphStem.ZIndex = Tokens.Layer.Chrome + 3
	glyphStem.Parent = searchGlyph
	Primitives.Corner(glyphStem, Tokens.Radius.Pill)
	theme:Bind(glyphStem, "BackgroundColor3", "MutedText")

	local searchBox = Instance.new("TextBox")
	searchBox.Name = "TopbarSearch"
	searchBox.Size = UDim2.new(1, -30, 1, 0)
	searchBox.Position = UDim2.new(0, 24, 0, 0)
	searchBox.BackgroundTransparency = 1
	searchBox.BorderSizePixel = 0
	searchBox.ClearTextOnFocus = false
	searchBox.Text = ""
	searchBox.PlaceholderText = "Search controls..."
	searchBox.TextXAlignment = Enum.TextXAlignment.Left
	searchBox.TextTruncate = Enum.TextTruncate.AtEnd
	searchBox.ZIndex = Tokens.Layer.Chrome + 3
	Tokens.Typeset(searchBox, "Body", theme:Get("Text"))
	searchBox.PlaceholderColor3 = theme:Get("MutedText")
	searchBox.Parent = searchWrap
	theme:Bind(searchBox, "TextColor3", "Text")
	theme:Bind(searchBox, "PlaceholderColor3", "MutedText")

	local clearBtn = Instance.new("TextButton")
	clearBtn.Name = "ClearSearch"
	clearBtn.Size = UDim2.fromOffset(18, 18)
	clearBtn.AnchorPoint = Vector2.new(1, 0.5)
	clearBtn.Position = UDim2.new(1, -4, 0.5, 0)
	clearBtn.BackgroundColor3 = theme:Get("ElementHover")
	clearBtn.BackgroundTransparency = 1
	clearBtn.BorderSizePixel = 0
	clearBtn.Text = "×"
	clearBtn.AutoButtonColor = false
	clearBtn.Visible = false
	clearBtn.ZIndex = Tokens.Layer.Chrome + 3
	Tokens.Typeset(clearBtn, "Label", theme:Get("MutedText"))
	clearBtn.Parent = searchWrap
	Primitives.Corner(clearBtn, Tokens.Radius.Pill)
	theme:Bind(clearBtn, "BackgroundColor3", "ElementHover")
	theme:Bind(clearBtn, "TextColor3", "MutedText")

	clearBtn.MouseEnter:Connect(function()
		Animator.Tween(clearBtn, Tokens.Motion.Fast, { BackgroundTransparency = 0.25, TextColor3 = theme:Get("Text") })
	end)
	clearBtn.MouseLeave:Connect(function()
		Animator.Tween(clearBtn, Tokens.Motion.Fast, { BackgroundTransparency = 1, TextColor3 = theme:Get("MutedText") })
	end)
	clearBtn.MouseButton1Click:Connect(function()
		searchBox.Text = ""
	end)

	Primitives.MakeDraggable(main, topbar, maid, { searchWrap, searchBox, clearBtn, minBtn, closeBtn })

	local searchSeq = 0
	local lastQuery = ""
	local function runSearch()
		local q = Animator.Alive(searchBox) and searchBox.Text or ""
		local changed = q ~= lastQuery
		lastQuery = q
		local active: any = nil
		for _, t in ipairs(self.Tabs) do
			if t._active then
				active = t
			end
			if changed then
				t._searchTabPicked = nil
			end
		end
		local firstHit: any = nil
		local activeHits = 0
		for _, t in ipairs(self.Tabs) do
			local n = t._applySearch(q)
			t._setSearchCount(q ~= "" and n or nil)
			if t == active then
				activeHits = n
			end
			if q ~= "" and n > 0 and not firstHit then
				firstHit = t
			end
		end
		if q ~= "" and activeHits == 0 and firstHit and firstHit ~= active and not (active and active._searchTabPicked) then
			firstHit._activate()
		end
	end

	searchBox:GetPropertyChangedSignal("Text"):Connect(function()
		local hasText = searchBox.Text ~= ""
		clearBtn.Visible = hasText
		searchBox.Size = hasText and UDim2.new(1, -46, 1, 0) or UDim2.new(1, -30, 1, 0)
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
		Animator.Tween(searchStroke, Tokens.Motion.Fast, { Color = theme:Get("Accent"), Transparency = 0.08 })
	end)
	searchBox.FocusLost:Connect(function()
		Animator.Tween(searchStroke, Tokens.Motion.Base, { Color = theme:Get("Stroke"), Transparency = 0.42 })
	end)
	self.SearchBox = searchBox

	--// SIDEBAR (rounded bottom-left corner to match Main's UICorner; flat top & right seams)
	local SIDEBAR_W = 156
	local FOOTER_H = 34
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -TOPBAR_H)
	sidebar.Position = UDim2.new(0, 0, 0, TOPBAR_H)
	sidebar.BackgroundColor3 = theme:Get("Sidebar")
	sidebar.BorderSizePixel = 0
	sidebar.ZIndex = Tokens.Layer.Content + 1
	sidebar.Parent = main
	Primitives.Corner(sidebar, Tokens.Radius.Window)
	theme:Bind(sidebar, "BackgroundColor3", "Sidebar")

	local sideTopSeam = Instance.new("Frame")
	sideTopSeam.Name = "TopSeam"
	sideTopSeam.Size = UDim2.new(1, 0, 0, Tokens.Radius.Window)
	sideTopSeam.Position = UDim2.new(0, 0, 0, 0)
	sideTopSeam.BackgroundColor3 = theme:Get("Sidebar")
	sideTopSeam.BorderSizePixel = 0
	sideTopSeam.ZIndex = Tokens.Layer.Content + 1
	sideTopSeam.Parent = sidebar
	theme:Bind(sideTopSeam, "BackgroundColor3", "Sidebar")

	local sideRightSeam = Instance.new("Frame")
	sideRightSeam.Name = "RightSeam"
	sideRightSeam.Size = UDim2.new(0, Tokens.Radius.Window, 1, 0)
	sideRightSeam.Position = UDim2.new(1, -Tokens.Radius.Window, 0, 0)
	sideRightSeam.BackgroundColor3 = theme:Get("Sidebar")
	sideRightSeam.BorderSizePixel = 0
	sideRightSeam.ZIndex = Tokens.Layer.Content + 1
	sideRightSeam.Parent = sidebar
	theme:Bind(sideRightSeam, "BackgroundColor3", "Sidebar")

	local sideDivider = Instance.new("Frame")
	sideDivider.Size = UDim2.new(0, 1, 1, 0)
	sideDivider.Position = UDim2.new(1, -1, 0, 0)
	sideDivider.BackgroundColor3 = theme:Get("Stroke")
	sideDivider.BackgroundTransparency = 0.4
	sideDivider.BorderSizePixel = 0
	sideDivider.ZIndex = Tokens.Layer.Content + 2
	sideDivider.Parent = sidebar
	theme:Bind(sideDivider, "BackgroundColor3", "Stroke")

	local tabList = Instance.new("ScrollingFrame")
	tabList.Name = "TabList"
	tabList.Size = UDim2.new(1, 0, 1, -FOOTER_H)
	tabList.BackgroundTransparency = 1
	tabList.BorderSizePixel = 0
	tabList.ScrollBarThickness = 0
	tabList.CanvasSize = UDim2.fromOffset(0, 0)
	tabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
	tabList.ZIndex = Tokens.Layer.Content + 1
	tabList.Parent = sidebar
	Primitives.Padding(tabList, 10, 8, 10, 8)

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.Padding = UDim.new(0, 5)
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Parent = tabList
	self.TabList = tabList

	-- Sidebar footer status pill
	local footer = Instance.new("Frame")
	footer.Name = "SidebarFooter"
	footer.Size = UDim2.new(1, 0, 0, FOOTER_H)
	footer.Position = UDim2.new(0, 0, 1, -FOOTER_H)
	footer.BackgroundTransparency = 1
	footer.ZIndex = Tokens.Layer.Content + 2
	footer.Parent = sidebar

	local footerLine = Instance.new("Frame")
	footerLine.Size = UDim2.new(1, -16, 0, 1)
	footerLine.Position = UDim2.new(0, 8, 0, 0)
	footerLine.BackgroundColor3 = theme:Get("Stroke")
	footerLine.BackgroundTransparency = 0.55
	footerLine.BorderSizePixel = 0
	footerLine.ZIndex = Tokens.Layer.Content + 2
	footerLine.Parent = footer
	theme:Bind(footerLine, "BackgroundColor3", "Stroke")

	local footerLbl = Instance.new("TextLabel")
	footerLbl.Size = UDim2.new(1, -16, 1, 0)
	footerLbl.Position = UDim2.new(0, 10, 0, 0)
	footerLbl.BackgroundTransparency = 1
	footerLbl.Text = tostring(config.Footer or ("Poloska v" .. Tokens.Version))
	footerLbl.TextXAlignment = Enum.TextXAlignment.Left
	footerLbl.TextTruncate = Enum.TextTruncate.AtEnd
	footerLbl.ZIndex = Tokens.Layer.Content + 3
	Tokens.Typeset(footerLbl, "Caption", theme:Get("MutedText"))
	footerLbl.Parent = footer
	theme:Bind(footerLbl, "TextColor3", "MutedText")
	self._footerLabel = footerLbl

	--// CONTENT CONTAINER
	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.new(1, -SIDEBAR_W, 1, -TOPBAR_H)
	container.Position = UDim2.new(0, SIDEBAR_W, 0, TOPBAR_H)
	container.BackgroundTransparency = 1
	container.ZIndex = Tokens.Layer.Content
	container.Parent = main
	self.Container = container
	self.Body = { sidebar, container }

	--// HOTKEYS (Maid-tracked — zero leak on Destroy)
	maid:Connect(UserInputService.InputBegan, function(input: InputObject, gpe: boolean)
		if gpe or self._capturingKeybind or not Animator.Alive(main) then
			return
		end
		if input.KeyCode == self.ToggleKey then
			self:Toggle()
		elseif self.MinimizeKey and input.KeyCode == self.MinimizeKey then
			self:ToggleMinimize()
		end
	end)

	--// PERSISTENT LAUNCHER BUTTON
	local topInset = Primitives.GetTopInset()
	local launcher = Instance.new("ImageButton")
	launcher.Name = "PoloskaLauncher"
	launcher.Size = UDim2.fromOffset(48, 48)
	launcher.Position = UDim2.new(0.5, -24, 0, topInset + 10)
	launcher.BackgroundColor3 = theme:Get("Card")
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
	local lStroke = Primitives.Stroke(launcher, theme:Get("Accent"), 1, 0.35)
	theme:Bind(launcher, "BackgroundColor3", "Card")
	theme:Bind(lStroke, "Color", "Accent")

	local launcherDrag = Primitives.MakeDraggable(launcher, launcher, maid)
	launcher.Activated:Connect(function()
		if launcherDrag:ConsumeClick() then
			return
		end
		self:Toggle()
	end)
	self.Launcher = launcher

	--// NOTIFICATIONS
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
		self._footerLabel.Text = tostring(text or "")
	end
end

function Window:SetTheme(name: string): (boolean, string?)
	if self._activePopupClose then
		self._activePopupClose()
	end
	local ok, err = self._theme:Set(name)
	if ok then
		self.ThemeName = name
	end
	return ok, err
end

function Window:GetThemeNames(): { string }
	return self._theme:Names()
end

function Window:SetScale(scale: number)
	self.UserScale = math.clamp(tonumber(scale) or 1, UserInputService.TouchEnabled and 0.35 or 0.50, 1.25)
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
	if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
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
	if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
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
		Animator.Tween(self.Main, Tokens.Motion.Slow, { Size = targetSize }, Tokens.Motion.SmoothStyle, Tokens.Motion.SmoothDir)
		Animator.Tween(self.MainStroke, Tokens.Motion.Base, { Transparency = 0.22 })
	else
		Animator.Tween(self.MainStroke, Tokens.Motion.Fast, { Transparency = 1 })
		local tw = Animator.Tween(self.Main, 0.22, { Size = self:_collapsedSize() }, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
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
	Animator.Tween(self.Main, Tokens.Motion.Base, { Size = targetSize }, Tokens.Motion.SmoothStyle, Tokens.Motion.SmoothDir)
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
	for _, part in ipairs(self.Body) do
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
