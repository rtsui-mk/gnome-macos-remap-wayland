#!/bin/bash

# Create temporary install directory
BASE_DIR=`pwd`
mkdir -p ~/Downloads && cd ~/Downloads

# Remove previously downloaded archives (if any)
rm -rf ./xremap*

# Detect architecture
ARCH=`uname -m`
echo "INFO: Detected ${ARCH} PC architecture."

# Exit if unsupported architecture
if [ "${ARCH}" != "x86_64" ] && [ "${ARCH}" != "aarch64" ]; then
  echo "ERROR: Unsupported architecture. Please compile and install Xremap manually:"
  echo "       https://github.com/k0kubun/xremap"
  exit 1
fi

# Detect compositor type (X11 or Wayland)
if [ "${XDG_SESSION_TYPE}" == "x11" ]; then
  echo "INFO: Detected X11 compositor."
  ARCHIVE_NAME="xremap-linux-${ARCH}-x11.zip"
elif [ "${XDG_SESSION_TYPE}" == "wayland" ]; then
  echo "INFO: Detected Wayland compositor."
  ARCHIVE_NAME="xremap-linux-${ARCH}-gnome.zip"
else
  echo "ERROR: Unsupported compositor."
  exit 1
fi

# Always download latest xremap release from GitHub
wget https://github.com/xremap/xremap/releases/latest/download/$ARCHIVE_NAME

# Extract the archive
echo "INFO: Extracting the archive..."
if ! command -v unzip &> /dev/null; then
  echo "ERROR: Command \"unzip\" not found."
  exit 0
fi
unzip -o ./xremap-linux-${ARCH}-*.zip

# Remove old binary (if any)
if command -v gnome-terminal &> /dev/null ; then
    echo "INFO: Removing old binary..."
    sudo rm -rf /usr/local/bin/xremap
fi

# Install new binary (if any)
echo "INFO: Installing the binary..."
sudo cp ./xremap /usr/local/bin

# Tweaking server access control for X11
# https://github.com/k0kubun/xremap#x11
if [ "${XDG_SESSION_TYPE}" == "x11" ]; then
  xhost +SI:localuser:root
fi

# Copy Xremap config file with macOS bindings
CONFIG_DIR=~/.config/gnome-macos-remap/
echo "INFO: Copying the xremap config file..."
mkdir -p $CONFIG_DIR
cp $BASE_DIR/config.yml $CONFIG_DIR

# Stop and disable service if already running
if systemctl is-active --user --quiet gnome-macos-remap ; then
  echo "INFO: Stopping and disabling systemd gnome-macos-remap service..."
  systemctl --user stop gnome-macos-remap
  systemctl --user disable gnome-macos-remap
fi

# Copy systemd service file
SERVICE_DIR=~/.local/share/systemd/user/
echo "INFO: Installing systemd service..."
mkdir -p $SERVICE_DIR
cp $BASE_DIR/gnome-macos-remap.service $SERVICE_DIR

# Copy bash scripts
BIN_DIR=~/.local/bin/
echo "INFO: Copying bash scripts..."
mkdir -p $BIN_DIR
cp $BASE_DIR/bin/*.sh $BIN_DIR

# Run Xremap without sudo
# https://github.com/xremap/xremap?tab=readme-ov-file#running-xremap-without-sudo

# User should be able to use `evdev` witout sudo
echo 'KERNEL=="uinput", GROUP="input", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/input.rules
# User should be able to use `uinput` without sudo
sudo gpasswd -a ${USER} input
# Load uinput module at the startup (Debian issue)
echo uinput | sudo tee /etc/modules-load.d/uinput.conf

# Instantiate the service
systemctl --user daemon-reload
systemctl --user enable gnome-macos-remap
systemctl --user start gnome-macos-remap

echo "INFO: Restoring GNOME keybinding defaults changed by older installs..."

gsettings reset org.gnome.mutter overlay-key

for binding in minimize show-desktop switch-applications switch-applications-backward \
    switch-group switch-group-backward switch-input-source switch-input-source-backward \
    switch-to-workspace-left switch-to-workspace-right; do
  gsettings reset org.gnome.desktop.wm.keybindings "$binding"
done

for binding in toggle-tiled-left toggle-tiled-right; do
  gsettings reset org.gnome.mutter.keybindings "$binding"
done

for binding in toggle-overview toggle-application-view \
    screenshot show-screenshot-ui screenshot-window; do
  gsettings reset org.gnome.shell.keybindings "$binding"
done

gsettings set org.gnome.shell.keybindings toggle-message-tray "['<Super><Alt>v']"
gsettings set org.gnome.shell.keybindings toggle-quick-settings "['<Super><Alt>s']"

gsettings reset org.gnome.settings-daemon.plugins.media-keys screensaver

if command -v gnome-terminal &> /dev/null ; then
  echo "INFO: Restoring GNOME Terminal shortcut defaults..."
  for binding in copy paste new-tab new-window close-tab close-window find; do
    gsettings reset org.gnome.Terminal.Legacy.Keybindings:/org/gnome/terminal/legacy/keybindings/ "$binding"
  done
fi

# Restart is required in order for the changes in the `/usr/share/dbus-1/session.conf` to take place
# Therefore cannot launch service right away


# Download and enable Xremap GNOME extension (for Wayland only)
# systemctl --user status gnome-macos-remap
if [ "${XDG_SESSION_TYPE}" == "wayland" ]; then
  # Check if xremap extension is enabled
  if gnome-extensions list | grep -q "xremap@k0kubun.com"; then
    echo "INFO: The xremap extension is already enabled."
  else
    RED=`tput setaf 1`
    RESET=`tput sgr0`
    echo "INFO: ${RED}Action Required${RESET}. Install the xremap extension and restart your PC."
    echo "      https://extensions.gnome.org/extension/5060/xremap/"
  fi
else
  gnome-extensions disable xremap@k0kubun.com
fi

echo "INFO: Computer restart may be required."
