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
    # Dock - completely hidden for tiling WM setup
    dock.autohide = true;
    dock.autohide-delay = 1000.0;  # 1000s delay = effectively hidden
    dock.autohide-time-modifier = 0.0;
    dock.mru-spaces = false;
    dock.minimize-to-application = true;
    dock.show-recents = false;
    dock.launchanim = false;
    dock.static-only = true;  # Only show running apps
    dock.tilesize = 32;

    # Menu bar - auto-hide (SketchyBar will replace it)
    NSGlobalDomain._HIHideMenuBar = true;

    # Finder
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    finder.FXEnableExtensionChangeWarning = false;
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;
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

    # Menu bar
    controlcenter.BatteryShowPercentage = true;

    # Siri
    CustomUserPreferences."com.apple.Siri".SiriPrefStashedStatusMenuVisible = false;
    CustomUserPreferences."com.apple.Siri".VoiceTriggerUserEnabled = false;

    # Screenshots
    screencapture.location = "~/Pictures/Screenshots";
    screencapture.type = "png";

    # Security
    screensaver.askForPasswordDelay = 10;
  };

  system.activationScripts.postActivation.text = ''
    mkdir -p ~/Pictures/Screenshots

    # Start window management services
    if command -v sketchybar &> /dev/null; then
      brew services start sketchybar 2>/dev/null || true
    fi
    if command -v borders &> /dev/null; then
      brew services start borders 2>/dev/null || true
    fi
  '';

  # Homebrew
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "uninstall";
    };

    taps = [
      "FelixKratz/formulae"
      "nikitabobko/tap"
    ];

    brews = [
      "sketchybar"
      "borders"
    ];

    casks = [
      # Window Management
      "nikitabobko/tap/aerospace"
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
      "notion"
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
      "font-fira-code-nerd-font"
      "font-hack-nerd-font"
    ];
  };
}
