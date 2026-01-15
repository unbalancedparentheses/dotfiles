# Shared and platform-specific packages
{ pkgs }:

{
  # Installed on both macOS and Linux
  shared = with pkgs; [
    neovim
    git

    # Modern CLI tools
    eza        # Modern ls
    bat        # Modern cat
    jq         # JSON processor
    htop       # Process viewer
    lazygit    # Git TUI
    delta      # Better git diff
    gh         # GitHub CLI
    zoxide     # Smart cd
    fzf        # Fuzzy finder
    ripgrep    # Fast grep
    fd         # Fast find
    tldr       # Simplified man pages
    btop       # Better htop
    dust       # Better du
    tree       # Directory tree
    wget       # Download files
    tmux       # Terminal multiplexer
    tig        # Git TUI
    glow       # Markdown renderer
    rustup     # Rust toolchain manager
  ];

  # macOS only
  darwin = with pkgs; [
    qemu       # VM emulation
    expect     # For automated VM installation
  ];

  # Linux only (fonts via nix)
  linuxFonts = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
  ];
}
