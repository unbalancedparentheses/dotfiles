# macOS (nix-darwin) specific configuration
{ config, pkgs, lib, username, ... }:

{
  # Disable nix-darwin's Nix management (using Determinate Nix installer)
  nix.enable = false;

  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  users.users.${username}.shell = pkgs.fish;

  system.stateVersion = 5;

  # macOS system preferences
  system.defaults = {
    # Dock
    dock.autohide = true;
    dock.autohide-delay = 0.0;
    dock.autohide-time-modifier = 0.5;
    dock.mru-spaces = false;
    dock.minimize-to-application = true;
    dock.show-recents = false;
    dock.launchanim = true;
    dock.static-only = false;
    dock.tilesize = 48;

    # Finder
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    finder.FXEnableExtensionChangeWarning = false;
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;
    finder._FXShowPosixPathInTitle = true;
    NSGlobalDomain.AppleShowAllFiles = true;

    # Trackpad
    trackpad.Clicking = true;
    trackpad.TrackpadRightClick = true;
    trackpad.TrackpadThreeFingerDrag = true;

    # Keyboard
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.InitialKeyRepeat = 15;
    NSGlobalDomain.ApplePressAndHoldEnabled = false;
    NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
    NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
    NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
    NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
    NSGlobalDomain.NSWindowShouldDragOnGesture = true;

    # Faster animations
    NSGlobalDomain.NSWindowResizeTime = 0.001;

    # Menu bar
    NSGlobalDomain._HIHideMenuBar = false;
    controlcenter.BatteryShowPercentage = true;

    # Siri
    CustomUserPreferences."com.apple.Siri".SiriPrefStashedStatusMenuVisible = false;
    CustomUserPreferences."com.apple.Siri".VoiceTriggerUserEnabled = false;

    # Ghostty
    CustomUserPreferences."com.mitchellh.ghostty".AppleWindowTabbingMode = "manual";

    # Screenshots
    screencapture.location = "~/Pictures/Screenshots";
    screencapture.type = "png";

    # Security
    screensaver.askForPasswordDelay = 10;
  };


  system.activationScripts.postActivation.text = ''
    mkdir -p ~/Pictures/Screenshots

    # Set random wallpaper using desktoppr
    # Search multiple common locations for wallpapers
    WALLPAPER=""
    for dir in "$HOME/projects/dotfiles/wallpapers" "$HOME/dotfiles/wallpapers" "$HOME/.dotfiles/wallpapers" "$HOME/.config/wallpapers" "$HOME/Pictures/Wallpapers"; do
      if [ -d "$dir" ]; then
        WALLPAPER=$(find "$dir" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | sort -R | head -1)
        [ -n "$WALLPAPER" ] && break
      fi
    done
    if [ -f "$WALLPAPER" ] && command -v desktoppr >/dev/null; then
      desktoppr "$WALLPAPER"
    fi
  '';

  launchd.user.agents.wallpaper = {
    serviceConfig = {
      ProgramArguments = [
        "/bin/sh"
        "-c"
        ''
          # Search multiple common locations for wallpapers
          WALLPAPER=""
          for dir in "$HOME/projects/dotfiles/wallpapers" "$HOME/dotfiles/wallpapers" "$HOME/.dotfiles/wallpapers" "$HOME/.config/wallpapers" "$HOME/Pictures/Wallpapers"; do
            if [ -d "$dir" ]; then
              WALLPAPER=$(find "$dir" -maxdepth 1 -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" -o -name "*.webp" \) 2>/dev/null | sort -R | head -1)
              [ -n "$WALLPAPER" ] && break
            fi
          done
          if [ -f "$WALLPAPER" ] && command -v desktoppr >/dev/null; then
            desktoppr "$WALLPAPER"
          fi
        ''
      ];
      StartInterval = 1800;  # 30 minutes
      RunAtLoad = true;
    };
  };

  # Homebrew
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "uninstall";
    };

    taps = [];

    brews = [];
    casks = [
      # Browsers
      "brave-browser"
      "firefox"

      # Communication
      "telegram-desktop"
      "slack"
      "zoom"
      "whatsapp"
      "signal"

      # Productivity
      "1password"
      "caffeine"
      "obsidian"

      # Development
      "ghostty"
      "github"
      "zed"
      "claude"
      "claude-code"

      # Media
      "spotify"

      # Utilities
      "utm"

      # Fonts
      "font-jetbrains-mono-nerd-font"
    ];
  };
}
