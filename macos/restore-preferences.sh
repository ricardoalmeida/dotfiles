#!/bin/bash

# Restore macOS preferences and settings
# This script applies previously saved system settings

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PREFS_DIR="$SCRIPT_DIR/preferences"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}🔧${NC} $1"
}

print_success() {
    echo -e "${GREEN}✅${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠️${NC} $1"
}

print_error() {
    echo -e "${RED}❌${NC} $1"
}

# Check if preferences directory exists
if [ ! -d "$PREFS_DIR" ]; then
    print_error "Preferences directory not found at $PREFS_DIR"
    echo "Please run save-preferences.sh first to create a backup."
    exit 1
fi

echo "🔄 Restoring macOS preferences from: $PREFS_DIR"
echo ""

# Confirmation prompt
read -p "This will modify your system settings. Continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Restoration cancelled."
    exit 0
fi

# Install required tools first
print_status "Checking required tools..."

# Install dockutil if needed
if ! command -v dockutil &> /dev/null; then
    print_status "Installing dockutil..."
    brew install dockutil
fi

# Restore Homebrew packages first (many other tools depend on this)
if [ -f "$PREFS_DIR/brew-packages.txt" ] && [ -f "$PREFS_DIR/brew-casks.txt" ]; then
    print_status "Restoring Homebrew packages..."
    
    # Install formulae
    while IFS= read -r package; do
        if [ -n "$package" ]; then
            brew list "$package" &>/dev/null || {
                echo "Installing formula: $package"
                brew install "$package"
            }
        fi
    done < "$PREFS_DIR/brew-packages.txt"
    
    # Install casks
    while IFS= read -r cask; do
        if [ -n "$cask" ]; then
            brew list --cask "$cask" &>/dev/null || {
                echo "Installing cask: $cask"
                brew install --cask "$cask"
            }
        fi
    done < "$PREFS_DIR/brew-casks.txt"
    
    print_success "Homebrew packages restored"
else
    print_warning "Homebrew package lists not found, skipping..."
fi

# Restore shell configuration files
print_status "Restoring shell configuration..."
[ -f "$PREFS_DIR/zshrc.backup" ] && cp "$PREFS_DIR/zshrc.backup" ~/.zshrc && print_success "Restored .zshrc"
[ -f "$PREFS_DIR/bashrc.backup" ] && cp "$PREFS_DIR/bashrc.backup" ~/.bashrc && print_success "Restored .bashrc"
[ -f "$PREFS_DIR/bash_profile.backup" ] && cp "$PREFS_DIR/bash_profile.backup" ~/.bash_profile && print_success "Restored .bash_profile"
[ -f "$PREFS_DIR/profile.backup" ] && cp "$PREFS_DIR/profile.backup" ~/.profile && print_success "Restored .profile"

# Restore Git configuration
if [ -f "$PREFS_DIR/git-config.txt" ]; then
    print_status "Restoring Git configuration..."
    while IFS= read -r line; do
        if [[ $line == *"="* ]]; then
            key=$(echo "$line" | cut -d'=' -f1)
            value=$(echo "$line" | cut -d'=' -f2-)
            git config --global "$key" "$value" 2>/dev/null || print_warning "Could not set git config: $key"
        fi
    done < "$PREFS_DIR/git-config.txt"
    print_success "Git configuration restored"
fi

# Restore VS Code extensions
if [ -f "$PREFS_DIR/vscode-extensions.txt" ] && command -v code &> /dev/null; then
    print_status "Restoring VS Code extensions..."
    while IFS= read -r extension; do
        if [ -n "$extension" ]; then
            code --install-extension "$extension" --force
        fi
    done < "$PREFS_DIR/vscode-extensions.txt"
    print_success "VS Code extensions restored"
fi

# Restore system defaults (with user confirmation for each category)
print_status "Restoring system defaults..."

restore_defaults() {
    local domain=$1
    local file=$2
    local description=$3
    
    if [ -f "$PREFS_DIR/$file" ]; then
        read -p "Restore $description? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Kill affected processes first
            case $domain in
                "com.apple.dock")
                    killall Dock 2>/dev/null || true
                    ;;
                "com.apple.finder")
                    killall Finder 2>/dev/null || true
                    ;;
            esac
            
            # Import settings
            defaults import "$domain" "$PREFS_DIR/$file" 2>/dev/null && {
                print_success "Restored $description"
            } || {
                print_warning "Could not restore $description (may require manual setup)"
            }
        fi
    fi
}

restore_defaults "com.apple.dock" "dock-defaults.plist" "Dock settings"
restore_defaults "com.apple.finder" "finder-defaults.plist" "Finder settings"
restore_defaults "NSGlobalDomain" "global-defaults.plist" "Global UI settings"

# Special handling for Dock applications
if [ -f "$PREFS_DIR/dock-apps.txt" ]; then
    read -p "Restore Dock applications? This will clear your current Dock. (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_status "Restoring Dock applications..."
        
        # Clear current dock
        dockutil --remove all --no-restart
        
        # Add applications from backup
        while IFS= read -r line; do
            if [[ $line =~ ^([^[:space:]]+)[[:space:]]+(.+)$ ]]; then
                app_name="${BASH_REMATCH[1]}"
                app_path="${BASH_REMATCH[2]}"
                
                if [ -e "$app_path" ]; then
                    dockutil --add "$app_path" --no-restart
                    echo "Added to Dock: $app_name"
                else
                    print_warning "Application not found: $app_path"
                fi
            fi
        done < "$PREFS_DIR/dock-apps.txt"
        
        # Restart Dock to apply changes
        killall Dock
        print_success "Dock applications restored"
    fi
fi

# SSH keys restoration guide
if [ -f "$PREFS_DIR/ssh-public-keys.txt" ]; then
    print_status "SSH Key Information"
    echo "Your SSH public keys were backed up. To restore:"
    echo "1. Copy your private keys to ~/.ssh/"
    echo "2. Set proper permissions: chmod 600 ~/.ssh/id_*"
    echo "3. Add public keys to remote servers as needed"
    echo ""
    echo "Backed up public keys:"
    cat "$PREFS_DIR/ssh-public-keys.txt" 2>/dev/null || echo "No public keys found"
    echo ""
fi

# Login items information
if [ -f "$PREFS_DIR/login-items.txt" ]; then
    print_status "Login Items Information"
    echo "The following applications were set to launch at login:"
    cat "$PREFS_DIR/login-items.txt"
    echo ""
    echo "To restore login items:"
    echo "1. Go to System Preferences > Users & Groups > Login Items"
    echo "2. Add the applications listed above"
    echo ""
fi

# WiFi networks information
if [ -f "$PREFS_DIR/wifi-networks.txt" ]; then
    print_status "WiFi Networks Information"
    echo "You previously connected to these WiFi networks:"
    cat "$PREFS_DIR/wifi-networks.txt"
    echo ""
    echo "You'll need to reconnect and enter passwords manually."
    echo ""
fi

# Energy settings
if [ -f "$PREFS_DIR/energy-settings.txt" ]; then
    print_status "Energy Settings Information"
    echo "Your previous energy settings:"
    cat "$PREFS_DIR/energy-settings.txt"
    echo ""
    echo "To restore energy settings, use 'sudo pmset' commands or System Preferences > Energy Saver"
    echo ""
fi

print_success "macOS preferences restoration completed!"
echo ""
echo "📋 Next steps:"
echo "1. Restart your computer to ensure all settings take effect"
echo "2. Manually configure items that require passwords or permissions"
echo "3. Check System Preferences for any remaining customizations"
echo "4. Re-login to applications and services"
echo ""
echo "📄 See $PREFS_DIR/preferences-summary.md for a complete list of what was backed up."
