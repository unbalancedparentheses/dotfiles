# Window management configuration (AeroSpace, SketchyBar, JankyBorders)
# macOS tiling WM setup inspired by i3/bspwm
{ config, pkgs, lib, ... }:

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

    # Gaps and padding
    [gaps]
    inner.horizontal = 8
    inner.vertical = 8
    outer.left = 8
    outer.bottom = 8
    outer.top = 40  # Space for SketchyBar
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

  # SketchyBar - Status bar
  xdg.configFile."sketchybar/sketchybarrc".text = ''
    #!/bin/bash

    # Colors (Catppuccin Mocha)
    BAR_COLOR=0xff1e1e2e
    ITEM_BG_COLOR=0xff313244
    ACCENT_COLOR=0xff89b4fa
    TEXT_COLOR=0xffcdd6f4
    SUBTEXT_COLOR=0xffa6adc8

    # Bar appearance
    sketchybar --bar \
      height=32 \
      blur_radius=30 \
      position=top \
      sticky=on \
      padding_left=10 \
      padding_right=10 \
      color=$BAR_COLOR

    # Default item properties
    sketchybar --default \
      icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
      icon.color=$TEXT_COLOR \
      label.font="JetBrainsMono Nerd Font:Medium:13.0" \
      label.color=$TEXT_COLOR \
      background.color=$ITEM_BG_COLOR \
      background.corner_radius=5 \
      background.height=24 \
      padding_left=5 \
      padding_right=5

    # Left side - Spaces/workspaces
    SPACE_ICONS=("1" "2" "3" "4" "5" "6" "7" "8" "9")
    for i in "''${!SPACE_ICONS[@]}"; do
      sid=$((i+1))
      sketchybar --add space space.$sid left \
        --set space.$sid space=$sid \
        icon="''${SPACE_ICONS[i]}" \
        background.color=0x00000000 \
        background.drawing=off \
        icon.highlight_color=$ACCENT_COLOR \
        script="$CONFIG_DIR/plugins/space.sh" \
        --subscribe space.$sid space_change
    done

    # Left side - Front app
    sketchybar --add item front_app left \
      --set front_app \
      background.drawing=on \
      icon.drawing=off \
      script="$CONFIG_DIR/plugins/front_app.sh" \
      --subscribe front_app front_app_switched

    # Right side - Date/time
    sketchybar --add item clock right \
      --set clock \
      update_freq=10 \
      icon= \
      script="$CONFIG_DIR/plugins/clock.sh"

    # Right side - Battery
    sketchybar --add item battery right \
      --set battery \
      update_freq=120 \
      script="$CONFIG_DIR/plugins/battery.sh" \
      --subscribe battery system_woke power_source_change

    # Right side - Volume
    sketchybar --add item volume right \
      --set volume \
      script="$CONFIG_DIR/plugins/volume.sh" \
      --subscribe volume volume_change

    # Initialize
    sketchybar --update
  '';

  # SketchyBar plugins
  xdg.configFile."sketchybar/plugins/space.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      if [ "$SELECTED" = "true" ]; then
        sketchybar --set $NAME background.drawing=on icon.highlight=on
      else
        sketchybar --set $NAME background.drawing=off icon.highlight=off
      fi
    '';
  };

  xdg.configFile."sketchybar/plugins/front_app.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      sketchybar --set $NAME label="$INFO"
    '';
  };

  xdg.configFile."sketchybar/plugins/clock.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      sketchybar --set $NAME label="$(date '+%a %d %b %H:%M')"
    '';
  };

  xdg.configFile."sketchybar/plugins/battery.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
      CHARGING=$(pmset -g batt | grep 'AC Power')

      if [ "$CHARGING" != "" ]; then
        ICON=""
      elif [ "$PERCENTAGE" -gt 80 ]; then
        ICON=""
      elif [ "$PERCENTAGE" -gt 60 ]; then
        ICON=""
      elif [ "$PERCENTAGE" -gt 40 ]; then
        ICON=""
      elif [ "$PERCENTAGE" -gt 20 ]; then
        ICON=""
      else
        ICON=""
      fi

      sketchybar --set $NAME icon="$ICON" label="''${PERCENTAGE}%"
    '';
  };

  xdg.configFile."sketchybar/plugins/volume.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      VOLUME=$(osascript -e "output volume of (get volume settings)")

      if [ "$VOLUME" -eq 0 ]; then
        ICON="󰝟"
      elif [ "$VOLUME" -lt 33 ]; then
        ICON="󰕿"
      elif [ "$VOLUME" -lt 66 ]; then
        ICON="󰖀"
      else
        ICON="󰕾"
      fi

      sketchybar --set $NAME icon="$ICON" label="''${VOLUME}%"
    '';
  };

  # JankyBorders - Window borders
  xdg.configFile."borders/bordersrc".text = ''
    #!/bin/bash

    options=(
      style=round
      width=4.0
      hidpi=on
      active_color=0xff89b4fa
      inactive_color=0xff313244
    )

    borders "''${options[@]}"
  '';
  };
}
