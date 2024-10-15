# Prometheus UI Library

![Prometheus Logo]([https://example.com/prometheus_logo.png](https://us-east.storage.cloudconvert.com/tasks/62c5210a-fc5d-414a-bd36-1c93b1fe83e5/Terminal_Aide_0017_29.png?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Credential=cloudconvert-production%2F20241015%2Fva%2Fs3%2Faws4_request&X-Amz-Date=20241015T011719Z&X-Amz-Expires=86400&X-Amz-Signature=889ef3b47888d5f47500bb4b04027a19feef3868c825ade03d31b557dde2fb76&X-Amz-SignedHeaders=host&response-content-disposition=inline%3B%20filename%3D%22Terminal_Aide_0017_29.png%22&response-content-type=image%2Fpng&x-id=GetObject))

## Table of Contents
1. [Introduction](#introduction)
2. [Features](#features)
3. [Quick Start](#quick-start)
4. [API Reference](#api-reference)
   - [Creating a Window](#creating-a-window)
   - [Adding Tabs](#adding-tabs)
   - [Adding Sections](#adding-sections)
   - [UI Elements](#ui-elements)
     - [Buttons](#buttons)
     - [Toggles](#toggles)
     - [Sliders](#sliders)
     - [Dropdowns](#dropdowns)
     - [Multi-Select Dropdowns](#multi-select-dropdowns)
     - [Color Pickers](#color-pickers)
   - [Notifications](#notifications)
5. [Contributing](#contributing)
6. [License](#license)

## Introduction

Prometheus is a powerful and flexible UI library for Roblox, designed to create sleek and interactive user interfaces for your games and plugins. With its intuitive API and rich feature set, Prometheus empowers developers to build complex UIs with ease.

## Features

- **Modular Design**: Create windows, tabs, and sections to organize your UI elements.
- **Rich UI Elements**: Includes buttons, toggles, sliders, dropdowns, multi-select dropdowns, and color pickers.
- **Smooth Animations**: Enhances user experience with fluid transitions and effects.
- **Notification System**: Display informative pop-ups to users.
- **Keyboard Shortcuts**: Bind actions to specific key combinations for power users.
- **Scrolling Support**: Handle overflow content with built-in scrolling frames.

## Quick Start

Here's a basic example to get you started:

```lua
local Prometheus = loadstring(game:HttpGet("https://raw.githubusercontent.com/ZenixRoblox/Prometheus/refs/heads/main/Prometheus.lua"))()
local window = Prometheus.createWindow("Prometheus")
local mainTab = window.addTab("Main")
local settingsTab = window.addTab("Settings")
local generalSection = mainTab.addSection("General")
local colorSection = settingsTab.addSection("Colors")

mainTab.addButton(generalSection, "Click Me!", function()
    print("Button clicked!")
end)
mainTab.addToggle(generalSection, "Enable Feature", false, function(enabled)
    print("Feature is now: " .. (enabled and "enabled" or "disabled"))
end)

settingsTab.addColorPicker(colorSection, "Background Color", Color3.new(1, 1, 1), function(color)
    workspace.Baseplate.Color = color
end)

window.notify("Welcome! Thanks for using Prometheus UI!", "Info", 5)
```

## API Reference

### Creating a Window

To create a new window, use the `createWindow` function:

```lua
local window = Prometheus.createWindow("My Window")
```

### Adding Tabs

Tabs are used to organize different sections of your UI. You can add tabs to a window using the `addTab` method:

```lua
local mainTab = window.addTab("Main")
local settingsTab = window.addTab("Settings")
```

### Adding Sections

Sections are used to organize content within a tab. You can add sections to a tab using the `addSection` method:

```lua
local generalSection = mainTab.addSection("General")
local colorSection = settingsTab.addSection("Colors")
```

### UI Elements

#### Buttons

Buttons are used to trigger actions. You can add buttons to a section using the `addButton` method:

```lua
mainTab.addButton(generalSection, "Click Me!", function()
    print("Button clicked!")
end)
```

#### Toggles

Toggles are used to enable or disable features. You can add toggles to a section using the `addToggle` method:

```lua
mainTab.addToggle(generalSection, "Enable Feature", false, function(enabled)
    print("Feature is now: " .. (enabled and "enabled" or "disabled"))
end)
```

#### Sliders

Sliders are used to select numerical values. You can add sliders to a section using the `addSlider` method:

```lua
mainTab.addSlider(generalSection, "Volume", 0, 100, 50, function(value)
    print("Volume set to: " .. value)
end)
```

#### Dropdowns

Dropdowns are used to select options from a list. You can add dropdowns to a section using the `addDropdown` method:

```lua
mainTab.addDropdown(generalSection, "Select an Option", {"Option A", "Option B", "Option C"}, "Option A", function(selected)
    print("Selected option: " .. selected)
end)
```

#### Multi-Select Dropdowns

Multi-select dropdowns allow users to select multiple options. You can add multi-select dropdowns to a section using the `addMultiDropdown` method:

```lua
mainTab.addMultiDropdown(generalSection, "Select Multiple Options", {"Option A", "Option B", "Option C"}, {"Option A", "Option C"}, function(selected)
    print("Selected options: " .. table.concat(selected, ", "))
end)
```

#### Color Pickers

Color pickers are used to select colors. You can add color pickers to a section using the `addColorPicker` method:

```lua
settingsTab.addColorPicker(colorSection, "Background Color", Color3.new(1, 1, 1), function(color)
    workspace.Baseplate.Color = color
end)
```

### Notifications

Notifications are used to display informative pop-ups to users. You can add notifications to a window using the `notify` method:

```lua
window.notify("Welcome! Thanks for using Prometheus UI!", "Info", 5)
window.notify("Welcome! Thanks for using Prometheus UI!", "Error", 5)
window.notify("Welcome! Thanks for using Prometheus UI!", "Warning", 5)
```

## Contributing

We welcome contributions to Prometheus! If you have any ideas or suggestions, please open an issue or submit a pull request.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.


