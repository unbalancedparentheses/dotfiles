# Linux-specific Home Manager configuration
# Configures: dunst, picom, rofi, GTK, Xresources
{ config, pkgs, lib, ... }:

{
  # Only apply on Linux
  config = lib.mkIf pkgs.stdenv.isLinux {

    # =========================================================================
    # Dunst - Notification daemon
    # =========================================================================
    services.dunst = {
      enable = true;
      settings = {
        global = {
          width = 300;
          height = 100;
          origin = "top-right";
          offset = "10x50";
          notification_limit = 5;
          alignment = "left";
          markup = "full";
          format = "<b>%s</b>\\n%b";
          word_wrap = true;
          ignore_newline = false;
          show_indicators = true;
          indicate_hidden = true;
          sort = true;
          shrink = false;
          transparency = 0;
          horizontal_padding = 8;
          padding = 8;
          separator_height = 2;
          separator_color = "frame";
          line_height = 0;
          corner_radius = 5;
          idle_threshold = 120;
          show_age_threshold = 60;
          history_length = 20;
          sticky_history = false;
          startup_notification = true;
          monitor = 0;
          follow = "none";
          browser = "${pkgs.firefox}/bin/firefox -new-tab";
          font = "JetBrainsMono Nerd Font 10";
        };
        # Nord theme
        frame = {
          width = 2;
          color = "#4c566a";
        };
        urgency_low = {
          background = "#2e3440";
          foreground = "#d8dee9";
          frame_color = "#4c566a";
          timeout = 10;
        };
        urgency_normal = {
          background = "#3b4252";
          foreground = "#eceff4";
          frame_color = "#88c0d0";
          timeout = 10;
        };
        urgency_critical = {
          background = "#3b4252";
          foreground = "#eceff4";
          frame_color = "#bf616a";
          timeout = 0;
        };
      };
    };

    # =========================================================================
    # Picom - Compositor
    # =========================================================================
    services.picom = {
      enable = true;
      backend = "glx";
      vSync = true;

      # Shadows
      shadow = true;
      shadowOffsets = [ (-12) (-12) ];
      shadowOpacity = 0.3;
      shadowExclude = [
        "name = 'Notification'"
        "class_g = 'Conky'"
        "class_g ?= 'Notify-osd'"
        "class_g = 'Cairo-clock'"
        "class_g = 'slop'"
        "class_g = 'Polybar'"
        "_GTK_FRAME_EXTENTS@:c"
      ];

      # Fading
      fade = true;
      fadeSteps = [ 0.03 0.03 ];
      fadeDelta = 5;

      # Opacity
      inactiveOpacity = 1.0;
      activeOpacity = 1.0;

      # Corners
      settings = {
        shadow-radius = 12;
        shadow-color = "#2e3440";
        corner-radius = 8;
        rounded-corners-exclude = [
          "window_type = 'dock'"
          "window_type = 'desktop'"
          "class_g = 'dmenu'"
          "class_g = 'dwm'"
        ];
        blur-background = false;
        blur-method = "dual_kawase";
        blur-strength = 5;
        mark-wmwin-focused = true;
        mark-ovredir-focused = true;
        detect-rounded-corners = true;
        detect-client-opacity = true;
        detect-transient = true;
        detect-client-leader = true;
        use-damage = true;
        log-level = "warn";
        glx-no-stencil = true;
        glx-copy-from-front = false;
      };
    };

    # =========================================================================
    # Rofi - Application launcher
    # =========================================================================
    programs.rofi = {
      enable = true;
      font = "JetBrainsMono Nerd Font 11";
      terminal = "${pkgs.st}/bin/st";
      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;
      in {
        "*" = {
          background = mkLiteral "#2e3440";
          background-alt = mkLiteral "#3b4252";
          foreground = mkLiteral "#d8dee9";
          selected = mkLiteral "#88c0d0";
          active = mkLiteral "#a3be8c";
          urgent = mkLiteral "#bf616a";
          background-color = mkLiteral "transparent";
          text-color = mkLiteral "@foreground";
          margin = 0;
          padding = 0;
          spacing = 0;
        };
        window = {
          location = mkLiteral "center";
          width = 600;
          border = 2;
          border-color = mkLiteral "#4c566a";
          border-radius = 8;
          background-color = mkLiteral "@background";
        };
        mainbox = {
          padding = 12;
        };
        inputbar = {
          spacing = 8;
          padding = 8;
          background-color = mkLiteral "@background-alt";
          border-radius = 6;
          children = map mkLiteral [ "prompt" "entry" ];
        };
        prompt = {
          text-color = mkLiteral "@selected";
        };
        entry = {
          placeholder = "Search...";
          placeholder-color = mkLiteral "#4c566a";
        };
        listview = {
          margin = mkLiteral "12px 0 0";
          lines = 8;
          columns = 1;
          fixed-height = false;
        };
        element = {
          padding = 8;
          spacing = 8;
          border-radius = 6;
        };
        "element selected" = {
          background-color = mkLiteral "@selected";
          text-color = mkLiteral "@background";
        };
        element-icon = {
          size = mkLiteral "1em";
          vertical-align = mkLiteral "0.5";
        };
        element-text = {
          text-color = mkLiteral "inherit";
          vertical-align = mkLiteral "0.5";
        };
      };
      extraConfig = {
        modi = "drun,run,window,ssh";
        show-icons = true;
        icon-theme = "Papirus";
        drun-display-format = "{name}";
        disable-history = false;
      };
    };

    # =========================================================================
    # GTK Theming
    # =========================================================================
    gtk = {
      enable = true;
      font = {
        name = "JetBrainsMono Nerd Font";
        size = 10;
      };
      theme = {
        name = "Nordic";
        package = pkgs.nordic;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "Adwaita";
        size = 24;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = true;
        gtk-error-bell = false;
      };
      gtk2.extraConfig = ''
        gtk-error-bell = 0
      '';
    };

    # =========================================================================
    # Xresources
    # =========================================================================
    xresources.properties = {
      # DPI (change for HiDPI: 144 or 192)
      "Xft.dpi" = 96;
      "Xft.autohint" = 0;
      "Xft.lcdfilter" = "lcddefault";
      "Xft.hintstyle" = "hintslight";
      "Xft.hinting" = 1;
      "Xft.antialias" = 1;
      "Xft.rgba" = "rgb";

      # Cursor
      "Xcursor.theme" = "Adwaita";
      "Xcursor.size" = 24;

      # Nord colors for XTerm
      "XTerm*faceName" = "JetBrainsMono Nerd Font";
      "XTerm*faceSize" = 11;
      "XTerm*termName" = "xterm-256color";
      "XTerm*selectToClipboard" = true;
      "XTerm*saveLines" = 10000;
      "XTerm*background" = "#2e3440";
      "XTerm*foreground" = "#d8dee9";
      "XTerm*cursorColor" = "#d8dee9";
      "XTerm*color0" = "#3b4252";
      "XTerm*color1" = "#bf616a";
      "XTerm*color2" = "#a3be8c";
      "XTerm*color3" = "#ebcb8b";
      "XTerm*color4" = "#81a1c1";
      "XTerm*color5" = "#b48ead";
      "XTerm*color6" = "#88c0d0";
      "XTerm*color7" = "#e5e9f0";
      "XTerm*color8" = "#4c566a";
      "XTerm*color9" = "#bf616a";
      "XTerm*color10" = "#a3be8c";
      "XTerm*color11" = "#ebcb8b";
      "XTerm*color12" = "#81a1c1";
      "XTerm*color13" = "#b48ead";
      "XTerm*color14" = "#8fbcbb";
      "XTerm*color15" = "#eceff4";
    };

    # =========================================================================
    # Redshift - Night light
    # =========================================================================
    services.redshift = {
      enable = true;
      latitude = "-34.60";
      longitude = "-58.38";
      temperature = {
        day = 6500;
        night = 3500;
      };
      tray = true;
    };

    # =========================================================================
    # Fontconfig
    # =========================================================================
    fonts.fontconfig.enable = true;

    # =========================================================================
    # X Session
    # =========================================================================
    xsession = {
      enable = true;
      initExtra = ''
        # Disable bell
        xset -b

        # Keyboard repeat rate
        xset r rate 200 50

        # Wallpaper
        DOTFILES="$HOME/Desktop/projects/dotfiles"
        [ ! -d "$DOTFILES" ] && DOTFILES="$HOME/dotfiles"
        [ ! -d "$DOTFILES" ] && DOTFILES="$HOME/.dotfiles"

        for dir in "$DOTFILES/wallpapers" "$HOME/.config/wallpapers" "$HOME/Pictures/Wallpapers"; do
          if [ -d "$dir" ]; then
            ${pkgs.feh}/bin/feh --bg-fill --randomize "$dir"/* &
            break
          fi
        done

        # SSH agent
        eval $(ssh-agent)
        ssh-add < /dev/null 2>/dev/null

        # Screen locker
        ${pkgs.xautolock}/bin/xautolock -time 5 -locker ${pkgs.slock}/bin/slock &

        # Automount
        ${pkgs.udiskie}/bin/udiskie &

        # Clipboard sync
        ${pkgs.autocutsel}/bin/autocutsel -fork -selection CLIPBOARD
        ${pkgs.autocutsel}/bin/autocutsel -fork -selection PRIMARY

        # System tray applets
        ${pkgs.networkmanagerapplet}/bin/nm-applet &
        ${pkgs.pasystray}/bin/pasystray &
        ${pkgs.cbatticon}/bin/cbatticon &

        # Status bar (build with: make suckless)
        command -v slstatus >/dev/null && slstatus &
      '';
      windowManager.command = "dwm";
    };

    # =========================================================================
    # Packages needed for the X session
    # =========================================================================
    home.packages = with pkgs; [
      # Suckless (user builds with custom config)
      # dwm slstatus st - build manually via: make suckless

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
      adwaita-icon-theme  # cursor theme
    ];
  };
}
