# Window management configuration (AeroSpace, SketchyBar, JankyBorders)
# macOS tiling WM setup - Dynamic Islands style
{ config, pkgs, lib, ... }:

let
  brewPrefix = if pkgs.stdenv.hostPlatform.isAarch64 then "/opt/homebrew" else "/usr/local";
in
{
  # Only apply on macOS
  config = lib.mkIf pkgs.stdenv.isDarwin {
  # AeroSpace - Tiling window manager
  # Keybindings: alt + hjkl (focus), alt + shift + hjkl (move)
  # Workspaces: alt + 1-9, alt + shift + 1-9 (move to workspace)
  xdg.configFile."aerospace/aerospace.toml".text = ''
    # Start AeroSpace at login
    start-at-login = true

    # Mouse follows focus
    on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
    on-focus-changed = ['move-mouse window-lazy-center']

    # Notify SketchyBar on workspace change
    exec-on-workspace-change = ['/bin/bash', '-c',
      '${brewPrefix}/bin/sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE && ~/.config/sketchybar/plugins/spaces_update.sh'
    ]

    # Gaps and padding (48px top for floating bar + gap)
    [gaps]
    inner.horizontal = 8
    inner.vertical = 8
    outer.left = 8
    outer.bottom = 8
    outer.top = 42
    outer.right = 8

    # Main keybindings (alt as modifier)
    [mode.main.binding]
    # Focus windows (vim-style)
    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

    # Move windows
    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    # Resize windows
    alt-minus = 'resize smart -50'
    alt-equal = 'resize smart +50'

    # Layout
    alt-slash = 'layout tiles horizontal vertical'
    alt-comma = 'layout accordion horizontal vertical'
    alt-f = 'fullscreen'
    alt-shift-space = 'layout floating tiling'

    # Close window
    alt-q = 'close'

    # Open terminal
    alt-enter = 'exec-and-forget open -na Ghostty'

    # Workspaces (alt + number)
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'
    alt-7 = 'workspace 7'
    alt-8 = 'workspace 8'
    alt-9 = 'workspace 9'

    # Move window to workspace
    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'
    alt-shift-5 = 'move-node-to-workspace 5'
    alt-shift-6 = 'move-node-to-workspace 6'
    alt-shift-7 = 'move-node-to-workspace 7'
    alt-shift-8 = 'move-node-to-workspace 8'
    alt-shift-9 = 'move-node-to-workspace 9'

    # Focus monitors
    alt-tab = 'workspace-back-and-forth'
    alt-shift-tab = 'move-workspace-to-monitor --wrap-around next'

    # Service mode (alt + shift + semicolon)
    alt-shift-semicolon = 'mode service'

    [mode.service.binding]
    esc = ['reload-config', 'mode main']
    r = ['flatten-workspace-tree', 'mode main']
    backspace = ['close-all-windows-but-current', 'mode main']

    # Workspace assignments (optional - uncomment to use)
    # [[on-window-detected]]
    # if.app-id = 'com.brave.Browser'
    # run = 'move-node-to-workspace 1'

  '';

  # SketchyBar - Status bar (Dynamic Islands style)
  xdg.configFile."sketchybar/sketchybarrc" = {
    executable = true;
    text = ''
    #!/bin/bash

    # Colors (Catppuccin Macchiato)
    export BLACK=0xff181926
    export WHITE=0xffcad3f5
    export RED=0xffed8796
    export GREEN=0xffa6da95
    export BLUE=0xff8aadf4
    export YELLOW=0xffeed49f
    export ORANGE=0xfff5a97f
    export MAGENTA=0xffc6a0f6
    export GREY=0xff939ab7
    export TRANSPARENT=0x00000000

    export BAR_COLOR=0x00000000
    export ICON_COLOR=$WHITE
    export LABEL_COLOR=$WHITE
    export ISLAND_BG=0xff24273a
    export ISLAND_BORDER=0xff363a4f
    export POPUP_BG=0xff24273a
    export ACCENT=$BLUE

    # Transparent bar with offset for floating islands
    sketchybar --bar \
      height=32 \
      position=top \
      sticky=on \
      y_offset=8 \
      margin=8 \
      padding_left=8 \
      padding_right=8 \
      color=$BAR_COLOR \
      shadow=off

    # Default item properties
    sketchybar --default \
      icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
      icon.color=$ICON_COLOR \
      icon.padding_left=8 \
      icon.padding_right=4 \
      label.font="JetBrainsMono Nerd Font:Medium:13.0" \
      label.color=$LABEL_COLOR \
      label.padding_left=4 \
      label.padding_right=8 \
      background.color=$TRANSPARENT \
      background.height=28 \
      popup.background.color=$POPUP_BG \
      popup.background.corner_radius=12 \
      popup.background.border_width=2 \
      popup.background.border_color=$ISLAND_BORDER

    # === LEFT ISLAND ===

    # Apple logo
    sketchybar --add item apple left \
      --set apple \
      icon= \
      icon.font="JetBrainsMono Nerd Font:Bold:16.0" \
      icon.color=$ACCENT \
      icon.padding_left=12 \
      icon.padding_right=8 \
      label.drawing=off \
      background.drawing=off

    # AeroSpace workspaces (dynamic visibility)
    sketchybar --add event aerospace_workspace_change

    for sid in 1 2 3 4 5 6 7 8 9; do
      sketchybar --add item space.$sid left \
        --set space.$sid \
        icon="$sid" \
        icon.padding_left=10 \
        icon.padding_right=10 \
        icon.color=$GREY \
        icon.highlight_color=$ACCENT \
        label.drawing=off \
        background.color=$TRANSPARENT \
        background.corner_radius=6 \
        background.height=22 \
        background.drawing=off \
        drawing=off \
        click_script="aerospace workspace $sid" \
        script="$CONFIG_DIR/plugins/space.sh $sid" \
        --subscribe space.$sid aerospace_workspace_change mouse.clicked mouse.entered mouse.exited
    done

    # Front app (with icon)
    sketchybar --add item front_app left \
      --set front_app \
      icon.drawing=on \
      icon.font="sketchybar-app-font:Regular:14.0" \
      label.font="JetBrainsMono Nerd Font:Bold:13.0" \
      label.padding_right=12 \
      script="$CONFIG_DIR/plugins/front_app.sh" \
      --subscribe front_app front_app_switched

    # Left island bracket
    sketchybar --add bracket left_island apple '/space\..*/' front_app \
      --set left_island \
      background.color=$ISLAND_BG \
      background.corner_radius=12 \
      background.height=32 \
      background.border_width=1 \
      background.border_color=$ISLAND_BORDER

    # === RIGHT ISLAND ===

    # Clock
    sketchybar --add item clock right \
      --set clock \
      update_freq=30 \
      icon= \
      icon.color=$ACCENT \
      icon.padding_left=12 \
      script="$CONFIG_DIR/plugins/clock.sh"

    # Battery
    sketchybar --add item battery right \
      --set battery \
      update_freq=120 \
      script="$CONFIG_DIR/plugins/battery.sh" \
      --subscribe battery system_woke power_source_change

    # Volume
    sketchybar --add item volume right \
      --set volume \
      script="$CONFIG_DIR/plugins/volume.sh" \
      --subscribe volume volume_change

    # WiFi
    sketchybar --add item wifi right \
      --set wifi \
      update_freq=5 \
      icon=󰖩 \
      icon.color=$GREEN \
      label.drawing=on \
      script="$CONFIG_DIR/plugins/wifi.sh"

    # CPU
    sketchybar --add item cpu right \
      --set cpu \
      update_freq=5 \
      icon= \
      icon.color=$YELLOW \
      label.padding_right=12 \
      script="$CONFIG_DIR/plugins/cpu.sh"

    # Right island bracket
    sketchybar --add bracket right_island cpu wifi volume battery clock \
      --set right_island \
      background.color=$ISLAND_BG \
      background.corner_radius=12 \
      background.height=32 \
      background.border_width=1 \
      background.border_color=$ISLAND_BORDER

    # Update workspaces visibility on startup
    $CONFIG_DIR/plugins/spaces_update.sh

    # Initialize
    sketchybar --update
  '';
  };

  # SketchyBar plugins
  xdg.configFile."sketchybar/plugins/space.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      WORKSPACE_ID="$1"

      update() {
        if [ "$FOCUSED_WORKSPACE" = "$WORKSPACE_ID" ]; then
          sketchybar --set $NAME \
            icon.highlight=on \
            background.drawing=on \
            background.color=0x40ffffff
        else
          sketchybar --set $NAME \
            icon.highlight=off \
            background.drawing=off
        fi
      }

      mouse_clicked() {
        aerospace workspace "$WORKSPACE_ID"
      }

      show_apps() {
        APPS=$(aerospace list-windows --workspace "$WORKSPACE_ID" --format "%{app-name}" 2>/dev/null)
        if [ -z "$APPS" ]; then
          sketchybar --set $NAME popup.drawing=on
          sketchybar --add item popup.empty popup.$NAME \
            --set popup.empty label="Empty" label.color=0xff939ab7 icon.drawing=off
        else
          sketchybar --set $NAME popup.drawing=on
          COUNT=0
          echo "$APPS" | while read -r APP; do
            [ -z "$APP" ] && continue
            COUNT=$((COUNT + 1))
            sketchybar --add item popup.$NAME.$COUNT popup.$NAME \
              --set popup.$NAME.$COUNT \
              label="$APP" \
              icon.drawing=off \
              click_script="open -a \"$APP\""
          done
        fi
      }

      hide_apps() {
        sketchybar --set $NAME popup.drawing=off
        sketchybar --remove '/popup\.'"$NAME"'\..*/' 2>/dev/null
        sketchybar --remove popup.empty 2>/dev/null
      }

      case "$SENDER" in
        mouse.clicked) mouse_clicked ;;
        mouse.entered) show_apps ;;
        mouse.exited) hide_apps ;;
        *) update ;;
      esac
    '';
  };

  # Dynamic workspace visibility updater
  xdg.configFile."sketchybar/plugins/spaces_update.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      # Show only active/occupied workspaces

      OCCUPIED=$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)
      FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null || echo "1")

      for sid in 1 2 3 4 5 6 7 8 9; do
        if echo "$OCCUPIED" | grep -qw "$sid" || [ "$FOCUSED" = "$sid" ]; then
          sketchybar --set space.$sid drawing=on
          if [ "$FOCUSED" = "$sid" ]; then
            sketchybar --set space.$sid icon.highlight=on background.drawing=on background.color=0x40ffffff
          else
            sketchybar --set space.$sid icon.highlight=off background.drawing=off
          fi
        else
          sketchybar --set space.$sid drawing=off
        fi
      done
    '';
  };

  xdg.configFile."sketchybar/plugins/front_app.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      if [ "$SENDER" = "front_app_switched" ]; then
        sketchybar --set $NAME label="$INFO" icon=":$(echo "$INFO" | tr '[:upper:]' '[:lower:]' | tr ' ' '_'):"
        # Update workspace visibility when app switches
        $CONFIG_DIR/plugins/spaces_update.sh
      fi
    '';
  };

  xdg.configFile."sketchybar/plugins/clock.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      sketchybar --set $NAME label="$(date '+%a %d %b  %H:%M')"
    '';
  };

  xdg.configFile."sketchybar/plugins/battery.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
      CHARGING=$(pmset -g batt | grep 'AC Power')

      if [ "$CHARGING" != "" ]; then
        ICON="󰂄"
        COLOR=0xffa6da95  # green
      elif [ "$PERCENTAGE" -gt 80 ]; then
        ICON="󰁹"
        COLOR=0xffcad3f5  # white
      elif [ "$PERCENTAGE" -gt 60 ]; then
        ICON="󰂀"
        COLOR=0xffcad3f5
      elif [ "$PERCENTAGE" -gt 40 ]; then
        ICON="󰁾"
        COLOR=0xffcad3f5
      elif [ "$PERCENTAGE" -gt 20 ]; then
        ICON="󰁻"
        COLOR=0xffeed49f  # yellow
      else
        ICON="󰁺"
        COLOR=0xffed8796  # red
      fi

      sketchybar --set $NAME icon="$ICON" icon.color=$COLOR label="''${PERCENTAGE}%"
    '';
  };

  xdg.configFile."sketchybar/plugins/volume.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      VOLUME=$(osascript -e "output volume of (get volume settings)")

      if [ "$VOLUME" -eq 0 ]; then
        ICON="󰝟"
        COLOR=0xff939ab7  # grey
      elif [ "$VOLUME" -lt 33 ]; then
        ICON="󰕿"
        COLOR=0xffc6a0f6  # magenta
      elif [ "$VOLUME" -lt 66 ]; then
        ICON="󰖀"
        COLOR=0xffc6a0f6
      else
        ICON="󰕾"
        COLOR=0xffc6a0f6
      fi

      sketchybar --set $NAME icon="$ICON" icon.color=$COLOR label="''${VOLUME}%"
    '';
  };

  xdg.configFile."sketchybar/plugins/cpu.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      CPU=$(top -l 1 -n 0 2>/dev/null | grep -E "^CPU" | grep -Eo '[0-9]+\.[0-9]+' | head -1)
      [ -z "$CPU" ] && CPU="0"
      sketchybar --set $NAME label="''${CPU}%"
    '';
  };

  xdg.configFile."sketchybar/plugins/wifi.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | grep -o "SSID: .*" | sed 's/SSID: //')
      if [ -z "$SSID" ]; then
        sketchybar --set $NAME icon=󰖪 icon.color=0xff939ab7 label=""
      else
        sketchybar --set $NAME icon=󰖩 icon.color=0xffa6da95 label="$SSID"
      fi
    '';
  };

  # JankyBorders - Window borders (Catppuccin accent)
  xdg.configFile."borders/bordersrc" = {
    executable = true;
    text = ''
      #!/bin/bash

      options=(
        style=round
        width=5.0
        hidpi=on
        active_color=0xff8aadf4
        inactive_color=0x00000000
      )

      borders "''${options[@]}"
    '';
  };
  };
}
