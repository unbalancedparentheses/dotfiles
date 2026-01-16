#!/bin/bash
# nix-darwin setup script for macOS
# Run each section manually or execute the whole script

set -e

USERNAME=$(whoami)
echo "Setting up nix-darwin for user: $USERNAME"

# Step 1: Install Xcode Command Line Tools
echo "=== Step 1: Installing Xcode Command Line Tools ==="
if ! xcode-select -p &>/dev/null; then
    xcode-select --install
    echo "Please wait for Xcode CLI tools to finish installing, then re-run this script."
    exit 0
else
    echo "Xcode CLI tools already installed."
fi

# Step 2: Install Nix (Determinate Systems installer)
echo "=== Step 2: Installing Nix ==="
if ! command -v nix &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
    echo "Nix installed. Please restart your terminal and re-run this script."
    exit 0
else
    echo "Nix already installed."
fi

# Step 3: Install Homebrew
echo "=== Step 3: Installing Homebrew ==="
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add brew to PATH
    echo >> "$HOME/.zprofile"
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew already installed."
fi

# Step 4: Update username in flake.nix
echo "=== Step 4: Configuring flake.nix ==="
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FLAKE_PATH="$SCRIPT_DIR/flake.nix"

if [ -f "$FLAKE_PATH" ]; then
    # Update username in flake.nix
    sed -i '' "s/username = \"[^\"]*\";/username = \"$USERNAME\";/" "$FLAKE_PATH"
    echo "Updated flake.nix: username=$USERNAME"
else
    echo "ERROR: flake.nix not found at $FLAKE_PATH"
    exit 1
fi

# Step 5: Backup conflicting system files
echo "=== Step 5: Backing up conflicting system files ==="
BACKUP_DIR="/etc/nix-darwin-backup-$(date +%Y%m%d-%H%M%S)"
CONFLICTING_FILES=(
    "/etc/zshenv"
    "/etc/zshrc"
    "/etc/bashrc"
    "/etc/bash.bashrc"
)

backup_needed=false
for file in "${CONFLICTING_FILES[@]}"; do
    if [ -f "$file" ] && [ ! -L "$file" ]; then
        backup_needed=true
        break
    fi
done

if [ "$backup_needed" = true ]; then
    echo "Found system files that may conflict with nix-darwin."
    echo "Backing up to: $BACKUP_DIR"
    sudo mkdir -p "$BACKUP_DIR"

    for file in "${CONFLICTING_FILES[@]}"; do
        if [ -f "$file" ] && [ ! -L "$file" ]; then
            filename=$(basename "$file")
            echo "  Moving $file -> $BACKUP_DIR/$filename"
            sudo mv "$file" "$BACKUP_DIR/$filename"
        fi
    done
    echo "Backup complete."
else
    echo "No conflicting files found (or already symlinks)."
fi

# Step 6: Build and activate everything
echo "=== Step 6: Installing everything ==="
cd "$SCRIPT_DIR"
make

echo ""
echo "=== Setup Complete ==="
echo "Run 'make' anytime to update"
echo ""
echo "Note: If system files were backed up, they are in /etc/nix-darwin-backup-*"
