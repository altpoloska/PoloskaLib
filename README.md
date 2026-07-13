# PoloskaLib

A minimal UI library for Roblox written in Lua. It creates a draggable window with tabs, smooth animations, notifications, confirmation dialogs, and common controls.

## Features

- dark Mercury-style theme;
- mouse and touch window dragging;
- minimize to the top bar;
- hide and restore the entire interface with a hotkey;
- tabs with scrollable content;
- buttons, toggles, sliders, text boxes, dropdowns, and keybinds;
- notifications and confirmation dialogs;
- creator card with Discord link copying;
- safe tween handling for removed instances.

## Requirements

- client-side execution through a `LocalScript` or a compatible client environment;
- access to the standard Roblox services `TweenService`, `UserInputService`, `CoreGui`, and `Players`;
- the library first attempts to place the interface in `CoreGui`, then falls back to `PlayerGui`;
- clipboard copying and local image loading require the corresponding functions to be available in the environment.

### Using a Library

Get library with loadstring(game:HttpGet("raw_github_link"))() 

```lua
local PoloskaLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/altpoloska/PoloskaLib/refs/heads/main/PoloskaLib.lua"))()
```

Example with the module stored in `ReplicatedStorage`:

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PoloskaLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/altpoloska/PoloskaLib/refs/heads/main/PoloskaLib.lua"))()
```

## Quick Start

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PoloskaLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/altpoloska/PoloskaLib/refs/heads/main/PoloskaLib.lua"))()

local window = PoloskaLib:Create({
    Name = "Control Panel",
    Size = UDim2.fromOffset(620, 420),
    ToggleKey = Enum.KeyCode.RightControl,
})

local mainTab = window:Tab({
    Name = "Main",
})

mainTab:Section("Actions")

mainTab:Button({
    Name = "Show notification",
    Callback = function()
        window:Notification({
            Title = "Done",
            Text = "The action has been completed.",
            Duration = 3,
        })
    end,
})

mainTab:Toggle({
    Name = "Automatic mode",
    StartingState = false,
    Callback = function(enabled)
        print("Enabled:", enabled)
    end,
})
```

## Creating a Window

```lua
local window = PoloskaLib:Create(config)
```

### `config` fields

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | `string` | `"Minimal UI"` | Window title |
| `Size` | `UDim2` | `UDim2.fromOffset(600, 400)` | Window size |
| `ToggleKey` | `Enum.KeyCode` | `Enum.KeyCode.RightControl` | Key used to hide or show the interface |
| `Icons.Minimize` | `string` or `number` | built-in asset ID | Minimize icon |
| `Icons.Restore` | `string` or `number` | built-in asset ID | Restore icon |
| `Icons.Close` | `string` or `number` | built-in asset ID | Close icon |

An icon can be a numeric asset ID, an `rbxassetid://...` string, an `rbxthumb://...` string, an HTTP URL, or a local path supported by `getcustomasset` or `getsynasset`.

```lua
local window = PoloskaLib:Create({
    Name = "My UI",
    Size = UDim2.fromOffset(700, 460),
    ToggleKey = Enum.KeyCode.Insert,
    Icons = {
        Minimize = "rbxassetid://10734896206",
        Restore = "rbxassetid://10734886735",
        Close = "rbxassetid://10747384394",
    },
})
```

Creating a new window removes any previous `ScreenGui` named `MinimalUI`.

## Window Methods

### `window:Toggle()`

Toggles the visibility of the entire window with an animation.

```lua
window:Toggle()
```

### `window:Show()`

Shows the window if it is hidden.

```lua
window:Show()
```

### `window:Hide()`

Hides the window if it is visible.

```lua
window:Hide()
```

### `window:ToggleMinimize()`

Collapses the window to its top bar or restores its full size.

```lua
window:ToggleMinimize()
```

## Tabs

```lua
local tab = window:Tab({
    Name = "Settings",
})
```

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | `string` | `"Tab"` | Tab name |

The first tab is activated automatically.

## Tab Elements

### Section

```lua
tab:Section("Main settings")
```

Adds a text section header. Returns the created `TextLabel`.

### Button

```lua
local frame = tab:Button({
    Name = "Run",
    Callback = function()
        print("Button clicked")
    end,
})
```

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | `string` | `"Button"` | Button text |
| `Callback` | `function` | none | Called when the button is clicked |

Returns the root `Frame` of the element.

### Toggle

```lua
local toggle = tab:Toggle({
    Name = "Enabled",
    StartingState = true,
    Callback = function(state)
        print(state)
    end,
})

print(toggle:Get())
toggle:Set(false)
```

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | `string` | `"Toggle"` | Toggle label |
| `StartingState` | `boolean` | `false` | Initial state |
| `Callback` | `function(state)` | none | Receives the new state |

Returned controller:

| Method | Description |
| --- | --- |
| `toggle:Get()` | Returns the current state |
| `toggle:Set(value)` | Sets the state and calls `Callback` |

When `StartingState` is `true`, `Callback` is called while the element is being created. No initial callback occurs when the starting state is `false`.

### Slider

```lua
local slider = tab:Slider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 25,
    Callback = function(value)
        print(value)
    end,
})

slider:Set(50)
```

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | `string` | `"Slider"` | Slider label |
| `Min` | `number` | `0` | Minimum value |
| `Max` | `number` | `100` | Maximum value |
| `Default` | `number` | value of `Min` | Initial value |
| `Callback` | `function(value)` | none | Called when the user moves the slider |

`slider:Set(value)` updates the value and visual fill but does not call `Callback`. Pass a value within the configured range because `Set` does not clamp it to `Min` and `Max`.

### Textbox

```lua
local frame = tab:Textbox({
    Name = "Player name",
    Placeholder = "Enter a name...",
    Callback = function(text)
        print(text)
    end,
})
```

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | `string` | `"Textbox"` | Field label |
| `Placeholder` | `string` | `"Type here..."` | Placeholder text |
| `Callback` | `function(text)` | none | Called when the text box loses focus |

Returns the root `Frame` of the element.

### Dropdown

```lua
local dropdown = tab:Dropdown({
    Name = "Mode",
    Items = {"Normal", "Fast", "Accurate"},
    StartingText = "Select a mode...",
    Callback = function(item)
        print("Selected:", item)
    end,
})

dropdown:AddItems({"Safe"})
dropdown:Clear()
```

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | `string` | `"Dropdown"` | Dropdown label |
| `Items` | `table` | `{}` | Array of items |
| `StartingText` | `string` | `"Select..."` | Text shown before the first selection |
| `Callback` | `function(item)` | none | Receives the original selected item |

An item can be a string or a table. For a table item, the value at index `1` is displayed while the complete table is passed to `Callback`.

```lua
local modes = {
    {"Normal", "normal"},
    {"Fast", "fast"},
}

local dropdown = tab:Dropdown({
    Name = "Mode",
    Items = modes,
    Callback = function(item)
        local title = item[1]
        local id = item[2]
        print(title, id)
    end,
})
```

Returned controller:

| Method | Description |
| --- | --- |
| `dropdown:AddItems(items)` | Adds an array of items |
| `dropdown:Clear()` | Removes all items |

### Keybind

```lua
local frame = tab:Keybind({
    Name = "Open menu",
    Keybind = Enum.KeyCode.F4,
    Callback = function()
        print("Assigned key pressed")
    end,
})
```

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | `string` | `"Keybind"` | Action label |
| `Keybind` | `Enum.KeyCode` | none | Initial key |
| `Callback` | `function` | none | Called when the assigned key is pressed |

To change the key, click the button displaying its name and press a new keyboard key. Returns the root `Frame` of the element.

### Creator Card

```lua
local frame = tab:Credit({
    Name = "polosa__",
    Description = "Library creator",
    Icon = "rbxassetid://123456789",
    Discord = "https://discord.gg/example",
    Callback = function(link)
        print("Discord:", link)
    end,
})
```

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Name` | `string` | `"Creator"` | Creator name |
| `Description` | `string` | value of `Role` or an empty string | Description |
| `Role` | `string` | empty string | Fallback description field |
| `Icon` | `string` or `number` | none | Creator image |
| `Discord` | `string` | none | Text or link to copy |
| `Callback` | `function(discord)` | none | Called after the Discord button is clicked |

The Discord button is only created when `Discord` is provided. The library attempts to copy the value to the clipboard and displays the result in a notification.

## Notifications

```lua
window:Notification({
    Title = "Saved",
    Text = "The settings were applied successfully.",
    Duration = 4,
})
```

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Title` | `string` | `"Notification"` | Notification title |
| `Text` | `string` | empty string | Main text |
| `Duration` | `number` | `3` | Display duration in seconds |

Notifications appear in the bottom-right corner and are removed automatically.

## Confirmation Dialog

```lua
window:Confirm({
    Title = "Delete settings?",
    Text = "This action cannot be undone.",
    ConfirmText = "Delete",
    CancelText = "Cancel",
    OnConfirm = function()
        print("Confirmed")
    end,
    OnCancel = function()
        print("Cancelled")
    end,
})
```

| Field | Type | Default | Description |
| --- | --- | --- | --- |
| `Title` | `string` | `"Are you sure?"` | Dialog title |
| `Text` | `string` | empty string | Action description |
| `ConfirmText` | `string` | `"Confirm"` | Confirm button text |
| `CancelText` | `string` | `"Cancel"` | Cancel button text |
| `OnConfirm` | `function` | none | Called after confirmation |
| `OnCancel` | `function` | none | Called after cancellation |

The close button in the main window uses this dialog. Confirming the close action destroys the interface.

## Complete Example

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PoloskaLib = loadstring(game:HttpGet("https://raw.githubusercontent.com/altpoloska/PoloskaLib/refs/heads/main/PoloskaLib.lua"))()

local window = PoloskaLib:Create({
    Name = "PoloskaLib Demo",
    Size = UDim2.fromOffset(640, 430),
    ToggleKey = Enum.KeyCode.RightControl,
})

local playerTab = window:Tab({Name = "Player"})
local settingsTab = window:Tab({Name = "Settings"})

playerTab:Section("Parameters")

local enabledToggle = playerTab:Toggle({
    Name = "Enabled",
    StartingState = false,
    Callback = function(state)
        window:Notification({
            Title = "State changed",
            Text = state and "Feature enabled" or "Feature disabled",
            Duration = 2,
        })
    end,
})

local speedSlider = playerTab:Slider({
    Name = "Speed",
    Min = 0,
    Max = 100,
    Default = 20,
    Callback = function(value)
        print("Speed:", value)
    end,
})

playerTab:Dropdown({
    Name = "Profile",
    Items = {
        {"Default", "default"},
        {"Fast", "fast"},
        {"Accurate", "accurate"},
    },
    StartingText = "Select a profile...",
    Callback = function(item)
        print("Profile:", item[2])
    end,
})

playerTab:Textbox({
    Name = "Comment",
    Placeholder = "Enter text...",
    Callback = function(text)
        print("Comment:", text)
    end,
})

settingsTab:Section("Interface")

settingsTab:Keybind({
    Name = "Toggle window",
    Keybind = Enum.KeyCode.F4,
    Callback = function()
        window:Toggle()
    end,
})

settingsTab:Button({
    Name = "Reset values",
    Callback = function()
        enabledToggle:Set(false)
        speedSlider:Set(20)
    end,
})

settingsTab:Credit({
    Name = "polosa__",
    Description = "PoloskaLib creator",
})
```

## Behavior Notes

- The library is designed for one interface named `MinimalUI`. Calling `Create` again removes the previous window.
- Closing the window through its top-bar button permanently destroys the created `ScreenGui`. Call `Create` again and rebuild the tabs to reopen it.
- `ToggleKey` is ignored when the input has already been handled by the game through `gameProcessedEvent`.
- The slider supports mouse dragging. Dedicated touch input is not implemented for the slider.
- The theme is stored inside the module and is not exposed through the public configuration.
- There is no public destroy method. Use `window.Gui:Destroy()` when required.
- Roblox event connections remain active until their related objects are destroyed or the client session ends.

## API Reference

```text
PoloskaLib:Create(config) -> window

window:Tab(config) -> tab
window:Toggle()
window:Show()
window:Hide()
window:ToggleMinimize()
window:Notification(config)
window:Confirm(config)

tab:Section(text) -> TextLabel
tab:Button(config) -> Frame
tab:Toggle(config) -> { Set, Get }
tab:Slider(config) -> { Set }
tab:Textbox(config) -> Frame
tab:Dropdown(config) -> { AddItems, Clear }
tab:Keybind(config) -> Frame
tab:Credit(config) -> Frame
```

## Author

Created by `polosa__`.
