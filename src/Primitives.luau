--!strict
-- Reusable UI primitives (corner, stroke, padding, rim highlight, ambient
-- shadow, icon resolution, Maid-tracked viewport-clamped drag handler).

local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Animator = require("./Animator")

local Primitives = {}

local function lookupGlobal(name: string): any
	local okGenv, genv = pcall(function()
		local fn = (getfenv(0) :: any).getgenv
		if typeof(fn) == "function" then
			return fn()
		end
		return nil
	end)
	if okGenv and typeof(genv) == "table" and genv[name] ~= nil then
		return genv[name]
	end
	local okEnv, env = pcall(function()
		return getfenv(0)
	end)
	if okEnv and typeof(env) == "table" and env[name] ~= nil then
		return env[name]
	end
	return (_G :: any)[name]
end

function Primitives.GetTopInset(): number
	local ok, insetY = pcall(function()
		return GuiService:GetGuiInset().Y
	end)
	if ok and type(insetY) == "number" then
		return math.max(0, insetY)
	end
	return 58
end

function Primitives.ClampToViewport(frame: GuiObject, pos: UDim2?, sizeOverride: Vector2?): UDim2
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
	return UDim2.new(
		targetPos.X.Scale,
		anchorX - vp.X * targetPos.X.Scale,
		targetPos.Y.Scale,
		anchorY - vp.Y * targetPos.Y.Scale
	)
end

function Primitives.ResolveIcon(icon: any): string
	if not icon then
		return ""
	end
	if type(icon) == "number" then
		return "rbxassetid://" .. tostring(icon)
	end
	local s = tostring(icon)
	if s:match("^rbxassetid://") or s:match("^rbxthumb://") or s:match("^http") then
		return s
	end
	local loader = lookupGlobal("getcustomasset") or lookupGlobal("getsynasset")
	if typeof(loader) == "function" then
		local ok, res = pcall(loader, s)
		if ok and typeof(res) == "string" then
			return res
		end
	end
	return s
end

function Primitives.Corner(parent: Instance, radius: number?): UICorner
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 8)
	c.Parent = parent
	return c
end

function Primitives.Stroke(parent: Instance, color: Color3, thickness: number?, transparency: number?): UIStroke
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = parent
	return s
end

function Primitives.Padding(parent: Instance, top: number, right: number?, bottom: number?, left: number?): UIPadding
	local p = Instance.new("UIPadding")
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
	local g = Instance.new("UIGradient")
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

-- Crisp 1px top highlight along a card or window for subtle glass depth.
function Primitives.RimHighlight(parent: GuiObject, theme: any, zIndex: number?): Frame
	local rim = Instance.new("Frame")
	rim.Name = "RimHighlight"
	rim.Size = UDim2.new(1, -16, 0, 1)
	rim.Position = UDim2.new(0, 8, 0, 0)
	rim.BackgroundColor3 = Color3.new(1, 1, 1)
	rim.BackgroundTransparency = 0.72
	rim.BorderSizePixel = 0
	rim.ZIndex = zIndex or (parent.ZIndex + 1)
	rim.Parent = parent
	local g = Instance.new("UIGradient")
	g.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.25, 0.35),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(0.75, 0.35),
		NumberSequenceKeypoint.new(1, 1),
	})
	g.Parent = rim
	theme:Bind(rim, "BackgroundColor3", "StrokeBright")
	return rim
end

-- Soft ambient drop shadow sibling synced to target's geometry.
function Primitives.DropShadow(target: GuiObject, spread: number?, transparency: number?, maid: any?): Frame?
	local parent = target.Parent
	if not parent then
		return nil
	end
	local pad = spread or 24
	local alpha = transparency or 0.62
	local shadow = Instance.new("Frame")
	shadow.Name = target.Name .. "Shadow"
	shadow.BackgroundTransparency = 1
	shadow.BorderSizePixel = 0
	shadow.ZIndex = math.max(0, target.ZIndex - 1)
	shadow.Parent = parent

	local cornerObj = target:FindFirstChildOfClass("UICorner")
	local baseRadius = cornerObj and cornerObj.CornerRadius.Offset or 12
	local steps = 3
	for i = 1, steps do
		local grow = math.floor(pad * (i / steps))
		local layer = Instance.new("Frame")
		layer.Name = "Layer" .. i
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
		shadow.Size = UDim2.new(
			target.Size.X.Scale, target.Size.X.Offset + pad * 2,
			target.Size.Y.Scale, target.Size.Y.Offset + pad * 2
		)
		shadow.Position = UDim2.new(
			target.Position.X.Scale, target.Position.X.Offset + pad * (2 * anchor.X - 1),
			target.Position.Y.Scale, target.Position.Y.Offset + pad * (2 * anchor.Y - 1)
		)
		shadow.Visible = target.Visible
	end
	sync()

	local function track(conn: RBXScriptConnection)
		if maid then
			maid:Add(conn)
		end
	end
	track(target:GetPropertyChangedSignal("Size"):Connect(sync))
	track(target:GetPropertyChangedSignal("Position"):Connect(sync))
	track(target:GetPropertyChangedSignal("Visible"):Connect(sync))
	return shadow
end

-- Maid-tracked drag controller clamped to viewport bounds (respecting TopBar inset).
function Primitives.MakeDraggable(frame: GuiObject, handle: GuiObject, maid: any, ignoreList: { GuiObject }?)
	local state = {
		Dragging = false,
		Moved = false,
		SuppressClick = false,
	}
	local activeInput: InputObject? = nil
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
			for _, obj in ipairs(ignoreList) do
				if isPointInGui(pt, obj) then
					return true
				end
			end
		end
		for _, desc in ipairs(handle:GetDescendants()) do
			if desc:IsA("TextBox") or desc:IsA("GuiButton") then
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

	maid:Connect(UserInputService.InputChanged, function(input: InputObject)
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
			local target = UDim2.new(
				startFramePos.X.Scale, startFramePos.X.Offset + delta.X,
				startFramePos.Y.Scale, startFramePos.Y.Offset + delta.Y
			)
			frame.Position = Primitives.ClampToViewport(frame, target)
		end
	end)

	maid:Connect(UserInputService.InputEnded, function(input: InputObject)
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
