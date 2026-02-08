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
    bottom     # Beautiful system monitor (btm)
    dust       # Better du
    tree       # Directory tree
    wget       # Download files
    tmux       # Terminal multiplexer
    mosh       # Mobile shell (better SSH)
    tig        # Git TUI
    glow       # Markdown renderer
    # Rust managed by mise (see .mise.toml)
    # atuin and mise configured via programs.* in shell.nix

    # Secrets
    _1password-cli  # op command for secrets in scripts

    # Extra utilities
    just       # Modern command runner (Makefile alternative)
    watchexec  # Run commands on file changes
    difftastic # Structural diff (syntax-aware)
    sd         # Simpler sed
    hyperfine  # Command benchmarking
    tokei      # Code statistics
  ];

  # macOS only
  darwin = with pkgs; [
    qemu       # VM emulation
    expect     # For automated VM installation
  ];

  # Linux only (X11 desktop utilities)
  linux = with pkgs; [
    # X utilities
    xorg.xsetroot
    xorg.xrdb
    xorg.xset
    xclip
    xsel

    # Desktop utilities
    feh            # wallpaper
    slock          # screen lock
    xautolock      # auto lock
    udiskie        # automount
    autocutsel     # clipboard sync
    cbatticon      # battery icon
    pasystray      # audio systray
    networkmanagerapplet

    # Theming
    nordic         # GTK theme
    papirus-icon-theme
    adwaita-icon-theme
  ];

  # Linux only (fonts via nix)
  linuxFonts = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.hack
  ];
}
