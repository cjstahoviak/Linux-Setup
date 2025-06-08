# Linux-Setup

A simple shell script to quickly configure a fresh Ubuntu installation with my preferred settings and packages.

## What it does

This setup script automatically:

- **Installs packages**: Installs essential packages via apt and snap
- **Configures tab completion**: Sets up case-insensitive tab completion
- **Adds useful aliases**: Includes shortcuts for common commands
- **Configures GNOME**: Enables click-to-minimize for the dash-to-dock

## Quick Start

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/linux-setup.git
   cd linux-setup
   ```

2. Make the script executable and run it:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

3. Follow the prompts and let the script do its work!

## What gets installed

**APT Packages:**
- `python3-pygments` (for the `pygmentize` command)
- `snapd-xdg-open` (for snap application integration)

**Snap Packages:**
- `code` (Visual Studio Code)

## Configuration Details

**Tab Completion:**
- Creates `~/.inputrc` if it doesn't exist
- Enables case-insensitive tab completion

**Aliases added to `~/.bashrc`:**
- `ccat='pygmentize -g'` - Syntax-highlighted file viewing
- `killgazebo` - Kills all Gazebo processes (useful for robotics development)

**GNOME Settings:**
- Configures dash-to-dock to minimize windows when clicking on running applications

## Features

- **Safe to run multiple times**: The script checks existing configurations and won't duplicate settings
- **Error resilient**: Continues running even if individual steps fail, with a summary at the end
- **Interactive**: Asks before updating package lists
- **Clear feedback**: Shows success/failure status for each operation with colored output

## Requirements

- Ubuntu (tested on recent versions)
- GNOME desktop environment (for the click-to-minimize feature)
- `sudo` access for package installation

## Customization

To add more packages, edit the arrays in `setup.sh`:

```bash
# Regular apt packages
PACKAGES=(
    "command_name:package_name"
)

# Snap packages  
SNAP_PACKAGES=(
    "command_name:snap_name:options"
)
```

To add more aliases, edit the `ALIASES` array:

```bash
ALIASES=(
    "alias name='command'"
)
```

## License

This project is open source and available under the [MIT License](LICENSE).