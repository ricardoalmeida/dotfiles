#!/bin/bash

# Save macOS preferences and settings
# This script captures current system settings that can be restored later

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFS_DIR="$SCRIPT_DIR/preferences"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# Create preferences directory if it doesn't exist
mkdir -p "$PREFS_DIR"

echo "🔧 Saving macOS preferences..."

# Save Dock preferences
echo "📱 Saving Dock configuration..."
dockutil --list > "$PREFS_DIR/dock-apps.txt" 2>/dev/null || {
    echo "⚠️  dockutil not found. Installing via brew..."
    brew install dockutil
    dockutil --list > "$PREFS_DIR/dock-apps.txt"
}

# Save Dock plist (contains position, size, autohide settings, etc.)
cp ~/Library/Preferences/com.apple.dock.plist "$PREFS_DIR/com.apple.dock.plist.backup"

# Save system defaults
echo "⚙️  Saving system defaults..."

# Dock settings
defaults read com.apple.dock > "$PREFS_DIR/dock-defaults.plist"

# Finder settings
defaults read com.apple.finder > "$PREFS_DIR/finder-defaults.plist"

# System UI preferences
defaults read NSGlobalDomain > "$PREFS_DIR/global-defaults.plist"

# Mission Control settings
defaults read com.apple.spaces > "$PREFS_DIR/spaces-defaults.plist" 2>/dev/null || echo "No Mission Control settings found"

# Trackpad settings
defaults read com.apple.AppleMultitouchTrackpad > "$PREFS_DIR/trackpad-defaults.plist" 2>/dev/null || echo "No trackpad settings found"
defaults read com.apple.driver.AppleBluetoothMultitouch.trackpad > "$PREFS_DIR/bluetooth-trackpad-defaults.plist" 2>/dev/null || echo "No Bluetooth trackpad settings found"

# Keyboard settings
defaults read com.apple.HIToolbox > "$PREFS_DIR/keyboard-defaults.plist" 2>/dev/null || echo "No keyboard settings found"

# Menu bar settings
defaults read com.apple.menuextra.clock > "$PREFS_DIR/menubar-clock-defaults.plist" 2>/dev/null || echo "No clock settings found"
defaults read com.apple.controlcenter > "$PREFS_DIR/control-center-defaults.plist" 2>/dev/null || echo "No Control Center settings found"

# Sound settings
defaults read com.apple.sound.beep > "$PREFS_DIR/sound-defaults.plist" 2>/dev/null || echo "No sound settings found"

# Desktop and screensaver
defaults read com.apple.desktop > "$PREFS_DIR/desktop-defaults.plist" 2>/dev/null || echo "No desktop settings found"
defaults read com.apple.screensaver > "$PREFS_DIR/screensaver-defaults.plist" 2>/dev/null || echo "No screensaver settings found"

# Security settings (what can be read without sudo)
defaults read com.apple.screensecurity > "$PREFS_DIR/screen-security-defaults.plist" 2>/dev/null || echo "No screen security settings found"

# Energy settings
pmset -g > "$PREFS_DIR/energy-settings.txt"

# WiFi networks (only names, not passwords)
echo "🌐 Saving WiFi network names..."
networksetup -listpreferredwirelessnetworks en0 > "$PREFS_DIR/wifi-networks.txt" 2>/dev/null || echo "Could not read WiFi networks"

# Installed fonts
echo "🔤 Saving font list..."
ls /Library/Fonts/ > "$PREFS_DIR/system-fonts.txt"
ls ~/Library/Fonts/ > "$PREFS_DIR/user-fonts.txt" 2>/dev/null || echo "No user fonts directory"

# Login items
echo "🚀 Saving login items..."
osascript -e 'tell application "System Events" to get the name of every login item' > "$PREFS_DIR/login-items.txt" 2>/dev/null || echo "Could not read login items"

# SSH keys (just list them, don't copy private keys)
echo "🔑 Saving SSH key information..."
if [ -d ~/.ssh ]; then
    ls -la ~/.ssh/*.pub > "$PREFS_DIR/ssh-public-keys.txt" 2>/dev/null || echo "No SSH public keys found"
fi

# Git configuration
echo "📝 Saving Git configuration..."
if command -v git &> /dev/null; then
    git config --global --list > "$PREFS_DIR/git-config.txt" 2>/dev/null || echo "No global Git config found"
fi

# Shell configuration files
echo "🐚 Saving shell configuration..."
[ -f ~/.zshrc ] && cp ~/.zshrc "$PREFS_DIR/zshrc.backup"
[ -f ~/.bashrc ] && cp ~/.bashrc "$PREFS_DIR/bashrc.backup"
[ -f ~/.bash_profile ] && cp ~/.bash_profile "$PREFS_DIR/bash_profile.backup"
[ -f ~/.profile ] && cp ~/.profile "$PREFS_DIR/profile.backup"

# VS Code extensions (if VS Code is installed)
if command -v code &> /dev/null; then
    echo "💻 Saving VS Code extensions..."
    code --list-extensions > "$PREFS_DIR/vscode-extensions.txt"
fi

# Homebrew packages and casks
if command -v brew &> /dev/null; then
    echo "🍺 Saving Homebrew packages..."
    brew list --formula > "$PREFS_DIR/brew-packages.txt"
    brew list --cask > "$PREFS_DIR/brew-casks.txt"
fi

# Create a summary file
echo "📋 Creating summary..."
cat > "$PREFS_DIR/preferences-summary.md" << EOF
# macOS Preferences Backup

Generated on: $(date)
System: $(sw_vers -productName) $(sw_vers -productVersion)
Computer: $(scutil --get ComputerName)

## Files Saved

- **dock-apps.txt**: List of Dock applications
- **dock-defaults.plist**: Dock settings and preferences
- **finder-defaults.plist**: Finder preferences
- **global-defaults.plist**: System-wide UI preferences
- **energy-settings.txt**: Power management settings
- **wifi-networks.txt**: Known WiFi network names
- **login-items.txt**: Applications that start at login
- **ssh-public-keys.txt**: List of SSH public keys
- **git-config.txt**: Global Git configuration
- **shell configuration files**: .zshrc, .bashrc, etc.
- **vscode-extensions.txt**: VS Code extensions (if installed)
- **brew packages**: Homebrew formulae and casks

## Restoration

To restore these settings, use the companion restore script or manually apply them using:
- \`defaults write\` commands for plist files
- \`dockutil\` for Dock configuration
- Manual reconfiguration for system settings

EOF

echo "✅ macOS preferences saved to: $PREFS_DIR"
echo "📄 Summary available at: $PREFS_DIR/preferences-summary.md"
echo ""
echo "💡 Tip: You can create a restore script to automatically apply these settings on a new system."
