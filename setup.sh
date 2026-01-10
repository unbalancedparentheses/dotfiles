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

# Step 5: Build and activate nix-darwin
echo "=== Step 5: Installing nix-darwin ==="
cd "$SCRIPT_DIR"
sudo -H /nix/var/nix/profiles/default/bin/nix run nix-darwin -- switch --flake ".#default"

echo ""
echo "=== Setup Complete ==="
echo "To rebuild your configuration in the future, run:"
echo "  make switch"
echo ""
echo "To search for packages:"
echo "  make search"
