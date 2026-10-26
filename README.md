# GNOME → macOS Keyboard Remap for Wayland

This keyboard remap is based on the [Xremap](https://github.com/k0kubun/xremap) functionality and works with Wayland and Xorg.

![Gnome macOS Remap Icon](./resources/gnome-macos-remap-wayland.png#gh-light-mode-only)
![Gnome macOS Remap Icon](./resources/gnome-macos-remap-wayland-dark.png#gh-dark-mode-only)

## What changed in this fork

- disabled global replace of cmd/ctrl
- only add essentials remaps
- work nicely with macos's emac style line editing
- exclude vscode(try this instead [MacOS Default Key Bindings](https://marketplace.visualstudio.com/items?itemName=MikeCunneen.default-keys-macos))

## How does it work?
The script downloads the latest version of `xremap` for your architecture. [config.yml](config.yml) maps specific shortcuts without swapping Ctrl and Meta globally. A systemd user service runs the remapper. On Wayland, the Xremap GNOME extension identifies the active application.

Cmd means the Meta/Super key (the Command key on an Apple keyboard). Unlisted combinations keep their native behavior. Tapping Super opens GNOME's overview.

| Shortcut | Action |
| --- | --- |
| Cmd+A/C/V/X | Select all / copy / paste / cut |
| Cmd+W/Q/T | Close tab / quit / new tab |
| Cmd+N/F/L | New window / find / focus address bar |
| Cmd+Z / Cmd+Shift+Z | Undo / redo |
| Cmd+Shift+T | Reopen closed tab |
| Ctrl+A / Ctrl+E | Previous / next word |
| Ctrl+Shift+A / Ctrl+Shift+E | Select to previous / next word |
| Ctrl+Left / Ctrl+Right | Native previous / next word |
| Cmd+Left / Cmd+Right | Beginning / end of line (add Shift to select) |
| Alt+Backspace | Delete previous word |
| Cmd+Alt+V | GNOME notifications |
| Cmd+Alt+S | GNOME quick settings |

The application shortcuts include Firefox. Ctrl+A/E intentionally replace the application's native actions; use Cmd+A for select all. Xremap does not remap its generated Ctrl+A again, so Cmd+A still selects all.

GNOME Terminal, Console, and Ptyxis use Cmd+C/V for Ctrl+Shift+C/V and corresponding terminal shortcuts for Cmd+N/Q/T/W/F. Cmd+A sends the terminal's native Ctrl+A; physical Ctrl combinations, including Ctrl+C, Ctrl+D and Ctrl+A/E, remain unchanged for shells and terminal editors. Terminal select-all support depends on the terminal application.

## Updating an existing installation

Run `./install.sh` again from this checkout, then log out and back in if needed. It replaces the installed config and restarts the user service. It also restores GNOME and GNOME Terminal shortcut defaults changed by the old installer, including the Super overview key. Custom values for those settings will be reset; review the script before rerunning if you customized them. Existing XKB options are left untouched.

This update uses GNOME's default shell shortcuts instead of the old Ctrl-based app switching, workspace, screenshot, and application-grid overrides. Notifications and quick settings move to Cmd+Alt+V and Cmd+Alt+S, leaving Cmd+V/S available to applications. It no longer disables the lock-screen shortcut. Uninstalling restores the default notification and quick-settings shortcuts.

## Prerequisities
* Install Git and GNOME extensions `sudo <your-package-manager> install git gnome-shell-extensions`.

## Installation
1. Make sure you are running **Wayland** display server. Logout from your session. On the GNOME login screen click ⚙ icon on the bottom right. Select `GNOME` (defaults to Wayland). Log in.
2. Check out this repository run `install.sh` script in Terminal. Script will ask for administrator password.

```
cd ~/Downloads
git clone https://github.com/petrstepanov/gnome-macos-remap-wayland
cd gnome-macos-remap-wayland
chmod +x ./install.sh
./install.sh
```

3. Install and enable [this GNOME extension](https://extensions.gnome.org/extension/5060/xremap/).
4. Restart your computer.

## How to uninstall

1. If repository was removed, check it out again. Navigate into the program directory in Terminal and run:
```
chmod +x ./uninstall.sh
./uninstall.sh
```

2. Restart your computer.

## Logbook

`Nov 29, 2025` • Tweaks. [Fixed install](https://github.com/xremap/xremap/discussions/496) on Debian Trixie.

`May 24, 2024` • Added keybindings for the [GNOME Console](https://apps.gnome.org/Console/) app.

`Oct 01, 2023` • [Blocker issue](https://github.com/k0kubun/xremap/issues/100) is resolved. Repository is ready for testing.

`May 23, 2021` • Moving to [Xremap](https://github.com/k0kubun/xremap) functionality instead.

`Dec 13, 2021` • First commit, testing out the [Key Mapper](https://github.com/sezanzeb/key-mapper).
