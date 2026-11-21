--!strict
-- PoloskaLib v2 Overlay: Confirm modal dialog + stacked toast Notifications
-- with semantic colour stripe and animated lifetime progress bar.

local UserInputService = game:GetService("UserInputService")
local Tokens = require("./Tokens")
local Animator = require("./Animator")
local Primitives = require("./Primitives")

local Overlay = {}

local TYPE_COLOR_KEY: { [string]: string } = {
	info = "Accent",
	success = "Success",
	warn = "Warning",
	warning = "Warning",
	error = "Danger",
	danger = "Danger",
}

function Overlay.AttachNotificationHost(gui: ScreenGui, theme: any)
	local host = Instance.new("Frame")
	host.Name = "PoloskaNotifications"
	host.AnchorPoint = Vector2.new(1, 1)
	host.Position = UDim2.new(1, -18, 1, -18)
	host.Size = UDim2.new(0, 310, 1, -36)
	host.BackgroundTransparency = 1
	host.BorderSizePixel = 0
	host.ZIndex = Tokens.Layer.Notification
	host.Parent = gui

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = host

	local nextOrder = 0
	local activeToasts: { { Dismiss: () -> () } } = {}
	local MAX_TOASTS = 4

	return function(cfg: any)
		if not Animator.Alive(host) then
			return
		end
		cfg = cfg or {}
		while #activeToasts >= MAX_TOASTS do
			local oldest = table.remove(activeToasts, 1)
			if oldest then
				oldest.Dismiss()
			end
		end

		nextOrder += 1
		local duration = tonumber(cfg.Duration) or 3.5
		local kind = string.lower(tostring(cfg.Type or "info"))
		local accentKey = TYPE_COLOR_KEY[kind] or "Accent"

		local wrap = Instance.new("Frame")
		wrap.Name = "ToastWrap"
		wrap.Size = UDim2.new(1, 0, 0, 0)
		wrap.AutomaticSize = Enum.AutomaticSize.Y
		wrap.BackgroundTransparency = 1
		wrap.ClipsDescendants = false
		wrap.LayoutOrder = nextOrder
		wrap.ZIndex = Tokens.Layer.Notification
		wrap.Parent = host

		local card = Instance.new("TextButton")
		card.Name = "Toast"
		card.Size = UDim2.new(1, 0, 0, 0)
		card.AutomaticSize = Enum.AutomaticSize.Y
		card.Position = UDim2.fromOffset(36, 0)
		card.BackgroundColor3 = theme:Get("Card")
		card.BackgroundTransparency = 1
		card.BorderSizePixel = 0
		card.Text = ""
		card.AutoButtonColor = false
		card.ClipsDescendants = true
		card.ZIndex = Tokens.Layer.Notification + 1
		card.Parent = wrap
		Primitives.Corner(card, Tokens.Radius.Card)
		local cardStroke = Primitives.Stroke(card, theme:Get("Stroke"), 1, 1)
		theme:Bind(card, "BackgroundColor3", "Card")
		theme:Bind(cardStroke, "Color", "Stroke")

		-- Semantic left accent bar (inset clear of rounded corners)
		local stripe = Instance.new("Frame")
		stripe.Name = "Stripe"
		stripe.Size = UDim2.new(0, 3, 1, -16)
		stripe.Position = UDim2.new(0, 5, 0, 8)
		stripe.BackgroundColor3 = theme:Get(accentKey)
		stripe.BackgroundTransparency = 1
		stripe.BorderSizePixel = 0
		stripe.ZIndex = Tokens.Layer.Notification + 2
		stripe.Parent = card
		Primitives.Corner(stripe, 2)
		theme:Bind(stripe, "BackgroundColor3", accentKey)

		local body = Instance.new("Frame")
		body.Size = UDim2.new(1, 0, 0, 0)
		body.AutomaticSize = Enum.AutomaticSize.Y
		body.BackgroundTransparency = 1
		body.ZIndex = Tokens.Layer.Notification + 2
		body.Parent = card
		Primitives.Padding(body, 10, 14, 12, 16)

		local bodyLayout = Instance.new("UIListLayout")
		bodyLayout.Padding = UDim.new(0, 3)
		bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
		bodyLayout.Parent = body

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, 0, 0, 0)
		title.AutomaticSize = Enum.AutomaticSize.Y
		title.BackgroundTransparency = 1
		title.Text = tostring(cfg.Title or "Notification")
		title.TextTransparency = 1
		title.TextXAlignment = Enum.TextXAlignment.Left
		title.TextWrapped = true
		title.LayoutOrder = 1
		title.ZIndex = Tokens.Layer.Notification + 3
		Tokens.Typeset(title, "Heading", theme:Get("Text"))
		title.Parent = body
		theme:Bind(title, "TextColor3", "Text")

		local desc: TextLabel? = nil
		if cfg.Text and tostring(cfg.Text) ~= "" then
			local d = Instance.new("TextLabel")
			d.Size = UDim2.new(1, 0, 0, 0)
			d.AutomaticSize = Enum.AutomaticSize.Y
			d.BackgroundTransparency = 1
			d.Text = tostring(cfg.Text)
			d.TextTransparency = 1
			d.TextXAlignment = Enum.TextXAlignment.Left
			d.TextWrapped = true
			d.LayoutOrder = 2
			d.ZIndex = Tokens.Layer.Notification + 3
			Tokens.Typeset(d, "Body", theme:Get("SubText"))
			d.Parent = body
			theme:Bind(d, "TextColor3", "SubText")
			desc = d
		end

		-- Animated lifetime progress bar (inset & rounded clear of card corner)
		local progTrack = Instance.new("Frame")
		progTrack.Size = UDim2.new(1, -20, 0, 2)
		progTrack.Position = UDim2.new(0, 10, 1, -4)
		progTrack.BackgroundTransparency = 1
		progTrack.BorderSizePixel = 0
		progTrack.ClipsDescendants = true
		progTrack.ZIndex = Tokens.Layer.Notification + 3
		progTrack.Parent = card
		Primitives.Corner(progTrack, 999)

		local progFill = Instance.new("Frame")
		progFill.Size = UDim2.fromScale(1, 1)
		progFill.BackgroundColor3 = theme:Get(accentKey)
		progFill.BackgroundTransparency = 1
		progFill.BorderSizePixel = 0
		progFill.ZIndex = Tokens.Layer.Notification + 4
		progFill.Parent = progTrack
		Primitives.Corner(progFill, 999)
		theme:Bind(progFill, "BackgroundColor3", accentKey)

		local dismissed = false
		local entry: { Dismiss: () -> () }
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
				Animator.Tween(cardStroke, 0.18, { Transparency = 1 })
				Animator.Tween(stripe, 0.18, { BackgroundTransparency = 1 })
				Animator.Tween(progFill, 0.18, { BackgroundTransparency = 1 })
				Animator.Tween(title, 0.18, { TextTransparency = 1 })
				if desc and Animator.Alive(desc) then
					Animator.Tween(desc, 0.18, { TextTransparency = 1 })
				end
			end
			task.delay(0.20, function()
				if Animator.Alive(wrap) then
					wrap:Destroy()
				end
			end)
		end

		entry = { Dismiss = dismiss }
		table.insert(activeToasts, entry)

		card.MouseButton1Click:Connect(dismiss)

		Animator.Tween(card, 0.22, {
			Position = UDim2.fromOffset(0, 0),
			BackgroundTransparency = 0.04,
		})
		Animator.Tween(cardStroke, 0.22, { Transparency = 0.25 })
		Animator.Tween(stripe, 0.22, { BackgroundTransparency = 0 })
		Animator.Tween(title, 0.22, { TextTransparency = 0 })
		if desc then
			Animator.Tween(desc, 0.22, { TextTransparency = 0 })
		end
		Animator.Tween(progFill, 0.22, { BackgroundTransparency = 0.25 })
		Animator.Tween(progFill, duration, { Size = UDim2.fromScale(0, 1) }, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)

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

	-- Remove any existing confirm overlay
	local prev = parentGui:FindFirstChild("PoloskaConfirm")
	if prev then
		prev:Destroy()
	end

	-- Sibling wrapper so clicks inside modal NEVER bubble to backdrop cancel
	local wrapper = Instance.new("Frame")
	wrapper.Name = "PoloskaConfirm"
	wrapper.Size = UDim2.fromScale(1, 1)
	wrapper.BackgroundTransparency = 1
	wrapper.BorderSizePixel = 0
	wrapper.ZIndex = Tokens.Layer.Dialog
	wrapper.Parent = parentGui

	local backdrop = Instance.new("TextButton")
	backdrop.Name = "Backdrop"
	backdrop.Size = UDim2.fromScale(1, 1)
	backdrop.BackgroundColor3 = theme:Get("Overlay")
	backdrop.BackgroundTransparency = 1
	backdrop.BorderSizePixel = 0
	backdrop.Text = ""
	backdrop.AutoButtonColor = false
	backdrop.ZIndex = Tokens.Layer.Dialog
	backdrop.Parent = wrapper
	theme:Bind(backdrop, "BackgroundColor3", "Overlay")

	local modal = Instance.new("Frame")
	modal.Name = "Modal"
	modal.AnchorPoint = Vector2.new(0.5, 0.5)
	modal.Position = UDim2.new(0.5, 0, 0.5, 10)
	modal.Size = UDim2.fromOffset(340, 0)
	modal.AutomaticSize = Enum.AutomaticSize.Y
	modal.BackgroundColor3 = theme:Get("Card")
	modal.BackgroundTransparency = 1
	modal.BorderSizePixel = 0
	modal.Active = true
	modal.ZIndex = Tokens.Layer.Dialog + 2
	modal.Parent = wrapper
	Primitives.Corner(modal, Tokens.Radius.Window)
	local modalStroke = Primitives.Stroke(modal, theme:Get("StrokeBright"), 1, 1)
	theme:Bind(modal, "BackgroundColor3", "Card")
	theme:Bind(modalStroke, "Color", "StrokeBright")

	local content = Instance.new("Frame")
	content.Size = UDim2.new(1, 0, 0, 0)
	content.AutomaticSize = Enum.AutomaticSize.Y
	content.BackgroundTransparency = 1
	content.ZIndex = Tokens.Layer.Dialog + 3
	content.Parent = modal
	Primitives.Padding(content, 18, 18, 16, 18)

	local col = Instance.new("UIListLayout")
	col.Padding = UDim.new(0, 10)
	col.SortOrder = Enum.SortOrder.LayoutOrder
	col.Parent = content

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 0)
	title.AutomaticSize = Enum.AutomaticSize.Y
	title.BackgroundTransparency = 1
	title.Text = tostring(opts.Title or "Confirm")
	title.TextTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.TextWrapped = true
	title.LayoutOrder = 1
	title.ZIndex = Tokens.Layer.Dialog + 4
	Tokens.Typeset(title, "Title", theme:Get("Text"))
	title.Parent = content
	theme:Bind(title, "TextColor3", "Text")

	local message = Instance.new("TextLabel")
	message.Size = UDim2.new(1, 0, 0, 0)
	message.AutomaticSize = Enum.AutomaticSize.Y
	message.BackgroundTransparency = 1
	message.Text = tostring(opts.Text or "Are you sure?")
	message.TextTransparency = 1
	message.TextXAlignment = Enum.TextXAlignment.Left
	message.TextWrapped = true
	message.LayoutOrder = 2
	message.ZIndex = Tokens.Layer.Dialog + 4
	Tokens.Typeset(message, "Body", theme:Get("SubText"))
	message.Parent = content
	theme:Bind(message, "TextColor3", "SubText")

	local btnRow = Instance.new("Frame")
	btnRow.Size = UDim2.new(1, 0, 0, 34)
	btnRow.BackgroundTransparency = 1
	btnRow.LayoutOrder = 3
	btnRow.ZIndex = Tokens.Layer.Dialog + 4
	btnRow.Parent = content

	local fadeButtons: { TextButton } = {}
	local closed = false
	local escConn: RBXScriptConnection? = nil
	local function close(cb: (() -> ())?)
		if closed then
			return
		end
		closed = true
		if escConn then
			escConn:Disconnect()
			escConn = nil
		end
		Animator.Tween(backdrop, 0.14, { BackgroundTransparency = 1 })
		Animator.Tween(modal, 0.14, { BackgroundTransparency = 1, Position = UDim2.new(0.5, 0, 0.5, 10) })
		Animator.Tween(modalStroke, 0.14, { Transparency = 1 })
		Animator.Tween(title, 0.14, { TextTransparency = 1 })
		Animator.Tween(message, 0.14, { TextTransparency = 1 })
		for _, b in ipairs(fadeButtons) do
			if Animator.Alive(b) then
				Animator.Tween(b, 0.14, { BackgroundTransparency = 1, TextTransparency = 1 })
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

	local function makeBtn(text: string, xPos: UDim2, colorKey: string, textColorKey: string?, fallbackTextColor: Color3, cb: (() -> ())?)
		local b = Instance.new("TextButton")
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
		Tokens.Typeset(b, "Label", txtColor)
		b.Parent = btnRow
		Primitives.Corner(b, Tokens.Radius.Control)
		theme:Bind(b, "BackgroundColor3", colorKey)
		if textColorKey then
			theme:Bind(b, "TextColor3", textColorKey)
		end
		table.insert(fadeButtons, b)
		b.MouseEnter:Connect(function()
			if not closed then
				Animator.Tween(b, Tokens.Motion.Fast, { BackgroundTransparency = 0.15 })
			end
		end)
		b.MouseLeave:Connect(function()
			if not closed then
				Animator.Tween(b, Tokens.Motion.Fast, { BackgroundTransparency = 0 })
			end
		end)
		b.MouseButton1Click:Connect(function()
			close(cb)
		end)
	end

	local isDanger = opts.Danger ~= false
	makeBtn(tostring(opts.CancelText or "Cancel"), UDim2.new(0, 0, 0, 0), "Element", "Text", theme:Get("Text"), opts.OnCancel)
	makeBtn(
		tostring(opts.ConfirmText or "Confirm"),
		UDim2.new(0.5, 5, 0, 0),
		isDanger and "Danger" or "Accent",
		isDanger and nil or "OnAccent",
		Color3.fromRGB(255, 255, 255),
		opts.OnConfirm
	)

	backdrop.MouseButton1Click:Connect(function()
		close(opts.OnCancel)
	end)

	escConn = UserInputService.InputBegan:Connect(function(input: InputObject)
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

	Animator.Tween(backdrop, 0.16, { BackgroundTransparency = 0.42 })
	Animator.Tween(modal, 0.20, { BackgroundTransparency = 0, Position = UDim2.new(0.5, 0, 0.5, 0) })
	Animator.Tween(modalStroke, 0.20, { Transparency = 0.35 })
	Animator.Tween(title, 0.20, { TextTransparency = 0 })
	Animator.Tween(message, 0.20, { TextTransparency = 0 })
	for _, b in ipairs(fadeButtons) do
		Animator.Tween(b, 0.20, { BackgroundTransparency = 0, TextTransparency = 0 })
	end
end

return Overlay
