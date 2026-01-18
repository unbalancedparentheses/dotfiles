# macOS (nix-darwin) specific configuration
{ config, pkgs, lib, username, ... }:

let
  brewPrefix = if pkgs.stdenv.hostPlatform.isAarch64 then "/opt/homebrew" else "/usr/local";
in
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

    # Faster animations
    NSGlobalDomain.NSWindowResizeTime = 0.001;

    # Menu bar
    controlcenter.BatteryShowPercentage = true;

    # Siri
    CustomUserPreferences."com.apple.Siri".SiriPrefStashedStatusMenuVisible = false;
    CustomUserPreferences."com.apple.Siri".VoiceTriggerUserEnabled = false;

    # Ghostty - disable macOS tabbing (conflicts with tiling WM)
    CustomUserPreferences."com.mitchellh.ghostty".AppleWindowTabbingMode = "manual";

    # Screenshots
    screencapture.location = "~/Pictures/Screenshots";
    screencapture.type = "png";

    # Security
    screensaver.askForPasswordDelay = 10;
  };


  system.activationScripts.postActivation.text = ''
    mkdir -p ~/Pictures/Screenshots
    # Disable window shadows for cleaner tiling look
    defaults write com.apple.WindowManager HideDesktop -bool true
    defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true
  '';

  # LaunchAgents for window management services
  launchd.user.agents.sketchybar = {
    serviceConfig = {
      ProgramArguments = [ "${brewPrefix}/bin/sketchybar" ];
      KeepAlive = true;
      RunAtLoad = true;
      EnvironmentVariables = {
        PATH = "${brewPrefix}/bin:/usr/local/bin:/usr/bin:/bin";
      };
    };
  };

  launchd.user.agents.borders = {
    serviceConfig = {
      ProgramArguments = [ "${brewPrefix}/bin/borders" ];
      KeepAlive = true;
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

    taps = [
      "FelixKratz/formulae"
      "nikitabobko/tap"
    ];

    brews = [
      "FelixKratz/formulae/sketchybar"
      "FelixKratz/formulae/borders"
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
      "font-sketchybar-app-font"
    ];
  };
}
