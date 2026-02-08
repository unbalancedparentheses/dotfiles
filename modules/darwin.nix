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
    dock.wvous-bl-corner = 1;  # Bottom left: disabled
    dock.wvous-br-corner = 1;  # Bottom right: disabled
    dock.wvous-tl-corner = 1;  # Top left: disabled
    dock.wvous-tr-corner = 1;  # Top right: disabled
    dock.expose-group-apps = true;  # Group windows by app in Mission Control

    # Finder
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    finder.FXEnableExtensionChangeWarning = false;
    finder.ShowPathbar = true;
    finder.ShowStatusBar = true;
    finder._FXShowPosixPathInTitle = true;
    finder.FXDefaultSearchScope = "SCcf";  # Search current folder by default
    finder.NewWindowTarget = "Home";  # New windows open home
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

    # Interface
    NSGlobalDomain.AppleInterfaceStyleSwitchesAutomatically = false;  # Don't auto switch dark/light
    NSGlobalDomain."com.apple.swipescrolldirection" = true;  # Natural scrolling

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
    screencapture.disable-shadow = true;  # No window shadows in screenshots

    # Security
    screensaver.askForPasswordDelay = 10;

    # Spaces
    spaces.spans-displays = false;  # Displays have separate spaces

    # Login window
    loginwindow.GuestEnabled = false;

    # Activity Monitor
    ActivityMonitor.ShowCategory = 100;  # Show all processes
    ActivityMonitor.SortColumn = "CPUUsage";
    ActivityMonitor.SortDirection = 0;  # Descending

    # Misc app settings
    CustomUserPreferences."com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;  # No .DS_Store on network volumes
      DSDontWriteUSBStores = true;  # No .DS_Store on USB drives
    };
    CustomUserPreferences."com.apple.AdLib".allowApplePersonalizedAdvertising = false;
    CustomUserPreferences."com.apple.ImageCapture".disableHotPlug = true;  # Don't open Photos when device connected
  };


  system.activationScripts.postActivation.text = ''
    mkdir -p ~/Pictures/Screenshots

    # Additional defaults not supported by nix-darwin
    # Expand save/print panels by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Save to disk (not iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Disable "Are you sure you want to open this application?"
    defaults write com.apple.LaunchServices LSQuarantine -bool false

    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticTextCompletionEnabled -bool false

    # Enable full keyboard access for all controls (tab through dialogs)
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

    # Reduce transparency
    defaults write NSGlobalDomain AppleReduceDesktopTinting -bool true

    # Disable press-and-hold for keys in favor of key repeat
    defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    # Finder: show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true

    # Finder: disable window animations
    defaults write com.apple.finder DisableAllAnimations -bool true

    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Disable disk image verification
    defaults write com.apple.frameworks.diskimages skip-verify -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
    defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

    # Use column view in all Finder windows by default
    defaults write com.apple.finder FXPreferredViewStyle -string "clmv"

    # Show the ~/Library folder
    chflags nohidden ~/Library 2>/dev/null || true

    # Disable automatic termination of inactive apps
    defaults write NSGlobalDomain NSDisableAutomaticTermination -bool true

    # Disable the crash reporter
    defaults write com.apple.CrashReporter DialogType -string "none"

    # Set Help Viewer windows to non-floating mode
    defaults write com.apple.helpviewer DevMode -bool true

    # Disable Notification Center and remove from menu bar (requires restart)
    # launchctl unload -w /System/Library/LaunchAgents/com.apple.notificationcenterui.plist 2>/dev/null || true

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
      "chatgpt"
      "claude"
      "claude-code"

      # Media
      "spotify"

      # Utilities
      "utm"
      "tailscale"

      # Fonts
      "font-jetbrains-mono-nerd-font"
    ];
  };
}
