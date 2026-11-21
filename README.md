# PoloskaLib v2

Minimal, self-contained Roblox Luau UI library (`v2.0.0`) designed to be loaded directly from a single file.

## Features

- **6 built-in themes** (`Poloska`, `Obsidian`, `Standout Crimson`, `Midnight Violet`, `Classic Dark`, `Light`) with WCAG-checked `OnAccent` and `MutedText` contrast tokens.
- **Responsive `UIScale` & CoreGui TopBar protection:** viewport-clamped dragging and launcher positioning using `GuiService:GetGuiInset()`, automatic canvas sync on resize / scale / minimize restore.
- **Strict `ZIndexBehavior.Global` layers:** `Backdrop (0) < Content (2..15) < Chrome (20..30) < Launcher (50) < Popup (200) < Notification (300) < Dialog (400)`.
- **Controls:** `Section`, `Metrics`, `Button`, `ButtonRow` (2–3 compact equal-width buttons), `Toggle`, `Slider` (editable), `Dropdown` (`Searchable`, `Stacked`, `Value`/`Default`, `OnOpen`, `:Refresh`), `Textbox`, `Keybind` (`Escape` cancel, `ToggleKey` capture guard, optional `AllowClear`).
- **Overlays:** Toast notifications (max 4 stacked, synchronized fade, `window:SetNotificationsEnabled`), modal `Confirm` dialogs, and topbar search with collapsed-group auto-expand.

## Usage

```lua
local PoloskaLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/altpoloska/PoloskaLib/refs/heads/main/PoloskaLib.lua"))()

local window = PoloskaLib:Create({
	Name = "My App",
	Footer = "v2.0.0",
	Theme = "Poloska",
	Scale = 1,
	ToggleKey = Enum.KeyCode.RightControl,
	Size = UDim2.fromOffset(700, 470),
})

local tab = window:Tab({ Name = "Main" })
local cols = tab:Columns({ Gap = 12 })
local group = tab:Group({ Name = "Controls", Parent = cols.Left, Collapsible = false })

group:Toggle({
	Name = "Enable Feature",
	StartingState = false,
	Callback = function(state)
		print("Feature:", state)
	end,
})

group:ButtonRow({
	{ Title = "Run", Style = "primary", Callback = function() end },
	{ Title = "Reset", Style = "danger", Callback = function() end },
})
```
