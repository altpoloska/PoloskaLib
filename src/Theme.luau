--!strict
-- PoloskaLib v2 per-window theme controller.
-- Eliminates global theme singletons and heuristic colour matching: every
-- surface registers explicit property bindings or repaint hooks.

local Theme = {}
Theme.__index = Theme

export type Palette = {
	Background: Color3,
	Surface: Color3,
	Sidebar: Color3,
	Card: Color3,
	Element: Color3,
	ElementHover: Color3,
	ElementActive: Color3,
	Stroke: Color3,
	StrokeBright: Color3,
	Accent: Color3,
	AccentSecondary: Color3,
	AccentSoft: Color3,
	OnAccent: Color3,
	Text: Color3,
	SubText: Color3,
	MutedText: Color3,
	Overlay: Color3,
	Success: Color3,
	Warning: Color3,
	Danger: Color3,
}

Theme.PresetOrder = {
	"Poloska",
	"Obsidian",
	"Standout Crimson",
	"Midnight Violet",
	"Classic Dark",
	"Light",
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
	["Standout Crimson"] = {
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
	["Midnight Violet"] = {
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
	["Classic Dark"] = {
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
} :: { [string]: Palette }

function Theme.new(initialName: string?)
	local name = (initialName and Theme.Presets[initialName]) and initialName or "Poloska"
	local colors = {} :: any
	for k, v in pairs(Theme.Presets[name] :: any) do
		colors[k] = v
	end
	return setmetatable({
		Name = name,
		Colors = colors :: Palette,
		_bindings = setmetatable({}, { __mode = "k" }) :: { [Instance]: { [string]: string } },
		_gradients = setmetatable({}, { __mode = "k" }) :: { [UIGradient]: { a: string, b: string } },
		_hooks = {} :: { () -> boolean? },
	}, Theme)
end

function Theme:Get(key: string): Color3
	return (self.Colors :: any)[key] or self.Colors.Text
end

function Theme:Bind(obj: Instance, property: string, key: string): Instance
	local color = (self.Colors :: any)[key]
	if color then
		pcall(function()
			(obj :: any)[property] = color
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

function Theme:BindGradient(grad: UIGradient, keyA: string, keyB: string): UIGradient
	grad.Color = ColorSequence.new(self:Get(keyA), self:Get(keyB))
	self._gradients[grad] = { a = keyA, b = keyB }
	return grad
end

function Theme:OnChange(fn: () -> boolean?)
	table.insert(self._hooks, fn)
	return fn
end

function Theme:Set(name: string): (boolean, string?)
	local preset = Theme.Presets[name]
	if not preset then
		return false, "Unknown theme: " .. tostring(name)
	end
	self.Name = name
	for k, v in pairs(preset :: any) do
		(self.Colors :: any)[k] = v
	end

	for obj, map in pairs(self._bindings) do
		if obj.Parent ~= nil then
			for prop, key in pairs(map) do
				local c = (self.Colors :: any)[key]
				if c then
					pcall(function()
						(obj :: any)[prop] = c
					end)
				end
			end
		else
			self._bindings[obj] = nil
		end
	end

	for grad, pair in pairs(self._gradients) do
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

function Theme:Names(): { string }
	local out = {}
	for _, n in ipairs(Theme.PresetOrder) do
		table.insert(out, n)
	end
	return out
end

function Theme:Destroy()
	table.clear(self._hooks)
end

return Theme
