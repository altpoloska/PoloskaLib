--!strict
-- PoloskaLib v2 design tokens: single source of truth for radii, motion,
-- typography roles, z-layers, and default icons.

local Tokens = {}

Tokens.Version = "2.0.0"

Tokens.Radius = {
	Window = 14,
	Card = 10,
	Control = 8,
	Chip = 6,
	Pill = 999,
}

Tokens.Motion = {
	Fast = 0.12,
	Base = 0.20,
	Slow = 0.34,
	Spring = 0.26,
	SmoothStyle = Enum.EasingStyle.Quint,
	SmoothDir = Enum.EasingDirection.InOut,
}

Tokens.Type = {
	Title = { Size = 15, Font = Enum.Font.GothamBold },
	Heading = { Size = 13, Font = Enum.Font.GothamBold },
	Label = { Size = 13, Font = Enum.Font.GothamMedium },
	Body = { Size = 12, Font = Enum.Font.Gotham },
	Caption = { Size = 11, Font = Enum.Font.GothamMedium },
	Mono = { Size = 12, Font = Enum.Font.RobotoMono },
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
	Minimize = "rbxassetid://10734896206",
	Close = "rbxassetid://10747384394",
	Restore = "rbxassetid://10734886735",
	Launcher = "rbxassetid://76774068789424",
}

function Tokens.Typeset(label: any, role: string, color: Color3?): any
	local spec = (Tokens.Type :: any)[role] or Tokens.Type.Label
	label.Font = spec.Font
	label.TextSize = spec.Size
	if color then
		label.TextColor3 = color
	end
	return label
end

return Tokens
