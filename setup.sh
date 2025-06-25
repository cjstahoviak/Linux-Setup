#!/bin/bash

# Linux Setup Script
# Run this after cloning the repository on a fresh Ubuntu installation

set -e  # Exit on error, but we'll handle errors manually for each section

echo "Starting Linux setup..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print status
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Track failed operations
FAILED_OPERATIONS=()

#=============================================================================
# 1. Install required packages
#=============================================================================
echo -e "\n[INFO] Installing required packages..."

# List of packages to install (command_name:package_name)
PACKAGES=(
    "pygmentize:python3-pygments"
    "snapd:snapd"
)

# List of snap packages to install (command_name:snap_name:options)
SNAP_PACKAGES=(
    "code:code:--classic"
)

# Ask user if they want to update package list
echo -n "Update package list? (y/N): "
read -r update_response
if [[ "$update_response" =~ ^[Yy]$ ]]; then
    echo "Updating package list..."
    if sudo apt update; then
        print_status "Package list updated"
    else
        print_error "Failed to update package list"
        FAILED_OPERATIONS+=("Package list update")
    fi
else
    print_status "Skipped package list update"
fi

# Install each package
for package_entry in "${PACKAGES[@]}"; do
    IFS=':' read -r command_name package_name <<< "$package_entry"
    
    if ! command -v "$command_name" &> /dev/null; then
        if sudo apt install -y "$package_name"; then
            print_status "Installed $package_name ($command_name)"
        else
            print_error "Failed to install $package_name"
            FAILED_OPERATIONS+=("Package installation: $package_name")
        fi
    else
        print_status "$command_name already installed"
    fi
done

# Install snap packages
for snap_entry in "${SNAP_PACKAGES[@]}"; do
    IFS=':' read -r command_name snap_name options <<< "$snap_entry"
    
    if ! command -v "$command_name" &> /dev/null; then
        if sudo snap install "$snap_name" $options; then
            print_status "Installed snap: $snap_name ($command_name)"
        else
            print_error "Failed to install snap: $snap_name"
            FAILED_OPERATIONS+=("Snap installation: $snap_name")
        fi
    else
        print_status "$command_name already installed"
    fi
done

#=============================================================================
# 2. Configure case-insensitive tab completion
#=============================================================================
echo -e "\n[INFO] Configuring tab completion..."

# Create .inputrc if it doesn't exist
if [ ! -f ~/.inputrc ]; then
    if echo '$include /etc/inputrc' > ~/.inputrc; then
        print_status "Created ~/.inputrc"
    else
        print_error "Failed to create ~/.inputrc"
        FAILED_OPERATIONS+=("Creating .inputrc file")
    fi
else
    print_status "~/.inputrc already exists"
fi

# Add case-insensitive completion if not already present
if ! grep -q "set completion-ignore-case On" ~/.inputrc 2>/dev/null; then
    if echo 'set completion-ignore-case On' >> ~/.inputrc; then
        print_status "Added case-insensitive tab completion"
    else
        print_error "Failed to configure tab completion"
        FAILED_OPERATIONS+=("Configuring tab completion")
    fi
else
    print_status "Case-insensitive tab completion already configured"
fi

#=============================================================================
# 3. Add aliases to .bashrc
#=============================================================================
echo -e "\n[INFO] Adding aliases to .bashrc..."

ALIASES=(
    "alias ccat='pygmentize -g'"
    "alias killgazebo=\"killall -9 gazebo & killall -9 gzserver & killall -9 gzclient\""
    "alias c='clear'"
)

for alias_line in "${ALIASES[@]}"; do
    if ! grep -Fq "$alias_line" ~/.bashrc 2>/dev/null; then
        if echo "$alias_line" >> ~/.bashrc; then
            print_status "Added: $alias_line"
        else
            print_error "Failed to add: $alias_line"
            FAILED_OPERATIONS+=("Adding alias: $alias_line")
        fi
    else
        print_status "Already exists: $alias_line"
    fi
done

#=============================================================================
# 4. Configure GNOME click-to-minimize
#=============================================================================
echo -e "\n[INFO] Configuring GNOME click-to-minimize..."

# Check if we're in a GNOME session
if [ "$XDG_CURRENT_DESKTOP" = "ubuntu:GNOME" ] || [ "$XDG_CURRENT_DESKTOP" = "GNOME" ]; then
    if gsettings set org.gnome.shell.extensions.dash-to-dock click-action 'minimize' 2>/dev/null; then
        print_status "Configured click-to-minimize for dash-to-dock"
    else
        print_error "Failed to configure GNOME click-to-minimize (dash-to-dock extension may not be installed)"
        FAILED_OPERATIONS+=("GNOME click-to-minimize configuration")
    fi
else
    print_warning "Not running GNOME desktop, skipping click-to-minimize configuration"
fi

#=============================================================================
# Summary
#=============================================================================
echo -e "\n[INFO] Setup Summary"
echo "=================="

if [ ${#FAILED_OPERATIONS[@]} -eq 0 ]; then
    echo -e "${GREEN}[SUCCESS]${NC} All operations completed successfully!"
    echo -e "\n[NOTE] You may need to restart your terminal or run 'source ~/.bashrc' to use the new aliases."
else
    echo -e "${YELLOW}[WARNING]${NC} Setup completed with some issues:"
    for operation in "${FAILED_OPERATIONS[@]}"; do
        echo -e "   ${RED}*${NC} $operation"
    done
    echo -e "\n[NOTE] You may need to manually address the failed operations above."
fi

# Source .bashrc to apply changes
echo -e "\n[INFO] Sourcing ~/.bashrc to apply changes..."
if source ~/.bashrc 2>/dev/null; then
    print_status "~/.bashrc sourced successfully"
else
    print_warning "Could not source ~/.bashrc (this is normal in some environments)"
fi

echo -e "\n[INFO] Setup script finished!"
