# PoloskaLib v2

Modular Roblox Luau UI library (`v2.0.0`) with zero external dependencies, compiled into a single drop-in file (`PoloskaLib.lua`) via **darklua**.

## Features

- **6 built-in themes** (`Poloska`, `Obsidian`, `Standout Crimson`, `Midnight Violet`, `Classic Dark`, `Light`) with WCAG-checked `OnAccent` and `MutedText` contrast tokens.
- **Responsive `UIScale` & CoreGui TopBar protection:** viewport-clamped dragging and launcher positioning using `GuiService:GetGuiInset()`, automatic canvas sync on resize / scale / minimize restore.
- **Strict `ZIndexBehavior.Global` layer scale:** `Backdrop (0) < Content (2..15) < Chrome (20..30) < Launcher (50) < Popup (200) < Notification (300) < Dialog (400)`.
- **Controls:** `Section`, `Metrics` (2-column grid), `Button`, `ButtonRow` (2–3 compact equal-width buttons), `Toggle`, `Slider` (editable chip), `Dropdown` (`Searchable`, `Stacked`, `Value`/`Default`, `OnOpen`, `:Refresh`), `Textbox`, `Keybind` (`Escape` cancel, `ToggleKey` capture guard, optional `AllowClear`).
- **Overlays:** Toast notifications (capped at 4, synchronized fade, `window:SetNotificationsEnabled`), modal `Confirm` dialogs, topbar search with collapsed-group auto-expand and empty-state notice.

## Quick Start

Load the bundled `PoloskaLib.lua` (or `require("./src/init")` in a modular Luau project):

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

## Project Layout

```text
poloskalib/
├── PoloskaLib.lua      # generated single-file bundle (loadstring / require ready)
├── src/
│   ├── init.luau       # library entrypoint (Version, :Create)
│   ├── Tokens.luau     # radii, typography, motion, ZIndex layers, default icons
│   ├── Theme.luau      # 6 palettes + live reactive bindings
│   ├── Maid.luau       # deterministic connection / instance cleanup
│   ├── Animator.luau   # destroyed-instance-safe TweenService wrapper
│   ├── Primitives.luau # corners, strokes, padding, icons, top-inset clamped drag
│   ├── Overlay.luau    # Toast stack + modal Confirm dialog
│   ├── Tab.luau        # sidebar tabs, badges, 2-column layout, groups, search
│   ├── Controls.luau   # Section, Metrics, Button, ButtonRow, Toggle, Slider, Dropdown, Textbox, Keybind
│   └── Window.luau     # topbar, launcher, scale, theme switching, notifications
├── .darklua.json
└── build.ps1
```

## Build

Requires [darklua](https://darklua.com/):

```powershell
powershell -ExecutionPolicy Bypass -File .\build.ps1
```
