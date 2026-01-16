# Linux-specific Home Manager configuration
# Configures: dunst, picom, rofi, GTK, Xresources, xsession
{ config, pkgs, lib, location ? { latitude = "0"; longitude = "0"; }, theme ? {}, ... }:

let
  # Fallback theme values if not provided
  t = theme // {
    background = theme.background or "#2e3440";
    backgroundAlt = theme.backgroundAlt or "#3b4252";
    foreground = theme.foreground or "#d8dee9";
    foregroundBright = theme.foregroundBright or "#eceff4";
    accent = theme.accent or "#88c0d0";
    border = theme.border or "#4c566a";
    error = theme.error or "#bf616a";
    success = theme.success or "#a3be8c";
    warning = theme.warning or "#d08770";
    font = theme.font or { family = "JetBrainsMono Nerd Font"; size = 11; sizeSmall = 10; };
    colors = theme.colors or {};
  };
  c = t.colors // {
    nord0 = t.colors.nord0 or "#2e3440";
    nord1 = t.colors.nord1 or "#3b4252";
    nord3 = t.colors.nord3 or "#4c566a";
    nord4 = t.colors.nord4 or "#d8dee9";
    nord5 = t.colors.nord5 or "#e5e9f0";
    nord6 = t.colors.nord6 or "#eceff4";
    nord7 = t.colors.nord7 or "#8fbcbb";
    nord8 = t.colors.nord8 or "#88c0d0";
    nord9 = t.colors.nord9 or "#81a1c1";
    nord11 = t.colors.nord11 or "#bf616a";
    nord13 = t.colors.nord13 or "#ebcb8b";
    nord14 = t.colors.nord14 or "#a3be8c";
    nord15 = t.colors.nord15 or "#b48ead";
  };
in
{
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
          font = "${t.font.family} ${toString t.font.sizeSmall}";
        };
        frame = {
          width = 2;
          color = t.border;
        };
        urgency_low = {
          background = t.background;
          foreground = t.foreground;
          frame_color = t.border;
          timeout = 10;
        };
        urgency_normal = {
          background = t.backgroundAlt;
          foreground = t.foregroundBright;
          frame_color = t.accent;
          timeout = 10;
        };
        urgency_critical = {
          background = t.backgroundAlt;
          foreground = t.foregroundBright;
          frame_color = t.error;
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
      fade = true;
      fadeSteps = [ 0.03 0.03 ];
      fadeDelta = 5;
      inactiveOpacity = 1.0;
      activeOpacity = 1.0;
      settings = {
        shadow-radius = 12;
        shadow-color = t.background;
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
      font = "${t.font.family} ${toString t.font.size}";
      terminal = "${pkgs.xterm}/bin/xterm";  # fallback; st is built manually
      theme = let
        inherit (config.lib.formats.rasi) mkLiteral;
      in {
        "*" = {
          background = mkLiteral t.background;
          background-alt = mkLiteral t.backgroundAlt;
          foreground = mkLiteral t.foreground;
          selected = mkLiteral t.accent;
          active = mkLiteral t.success;
          urgent = mkLiteral t.error;
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
          border-color = mkLiteral t.border;
          border-radius = 8;
          background-color = mkLiteral "@background";
        };
        mainbox.padding = 12;
        inputbar = {
          spacing = 8;
          padding = 8;
          background-color = mkLiteral "@background-alt";
          border-radius = 6;
          children = map mkLiteral [ "prompt" "entry" ];
        };
        prompt.text-color = mkLiteral "@selected";
        entry = {
          placeholder = "Search...";
          placeholder-color = mkLiteral t.border;
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
        name = t.font.family;
        size = t.font.sizeSmall;
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
      gtk2.extraConfig = "gtk-error-bell = 0";
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
      "Xcursor.theme" = "Adwaita";
      "Xcursor.size" = 24;

      # XTerm with Nord colors
      "XTerm*faceName" = t.font.family;
      "XTerm*faceSize" = t.font.size;
      "XTerm*termName" = "xterm-256color";
      "XTerm*selectToClipboard" = true;
      "XTerm*saveLines" = 10000;
      "XTerm*background" = c.nord0;
      "XTerm*foreground" = c.nord4;
      "XTerm*cursorColor" = c.nord4;
      "XTerm*color0" = c.nord1;
      "XTerm*color1" = c.nord11;
      "XTerm*color2" = c.nord14;
      "XTerm*color3" = c.nord13;
      "XTerm*color4" = c.nord9;
      "XTerm*color5" = c.nord15;
      "XTerm*color6" = c.nord8;
      "XTerm*color7" = c.nord5;
      "XTerm*color8" = c.nord3;
      "XTerm*color9" = c.nord11;
      "XTerm*color10" = c.nord14;
      "XTerm*color11" = c.nord13;
      "XTerm*color12" = c.nord9;
      "XTerm*color13" = c.nord15;
      "XTerm*color14" = c.nord7;
      "XTerm*color15" = c.nord6;
    };

    # =========================================================================
    # Redshift - Night light
    # =========================================================================
    services.redshift = {
      enable = true;
      latitude = location.latitude;
      longitude = location.longitude;
      temperature = {
        day = 6500;
        night = 3500;
      };
      tray = true;
    };

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
  };
}
