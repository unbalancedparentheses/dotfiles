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
    dock.mru-spaces = false;
    dock.minimize-to-application = true;
    dock.show-recents = false;

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
  '';

  # Homebrew
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      cleanup = "uninstall";
    };

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
