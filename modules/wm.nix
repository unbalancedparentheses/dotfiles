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

    # Gaps and padding
    [gaps]
    inner.horizontal = 6
    inner.vertical = 2
    outer.left = 6
    outer.bottom = 2
    outer.top = 32
    outer.right = 6

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

    # Workspace assignments
    # 1 = browsers, 2 = terminals/code, 3 = communication, 4 = notes, 5 = music
    [[on-window-detected]]
    if.app-id = 'com.brave.Browser'
    run = 'move-node-to-workspace 1'

    [[on-window-detected]]
    if.app-id = 'org.mozilla.firefox'
    run = 'move-node-to-workspace 1'

    [[on-window-detected]]
    if.app-id = 'dev.zed.Zed'
    run = 'move-node-to-workspace 2'

    [[on-window-detected]]
    if.app-id = 'com.tinyspeck.slackmacgap'
    run = 'move-node-to-workspace 3'

    [[on-window-detected]]
    if.app-id = 'org.telegram.desktop'
    run = 'move-node-to-workspace 3'

    [[on-window-detected]]
    if.app-id = 'net.whatsapp.WhatsApp'
    run = 'move-node-to-workspace 3'

    [[on-window-detected]]
    if.app-id = 'md.obsidian'
    run = 'move-node-to-workspace 4'

    [[on-window-detected]]
    if.app-id = 'com.spotify.client'
    run = 'move-node-to-workspace 5'

  '';

  # SketchyBar - Status bar (Dynamic Islands style)
  xdg.configFile."sketchybar/sketchybarrc" = {
    executable = true;
    text = ''
    #!/bin/bash

    # Colors (Tokyo Night - vibrant)
    export BLACK=0xff1a1b26
    export WHITE=0xffc0caf5
    export RED=0xfff7768e
    export GREEN=0xff9ece6a
    export BLUE=0xff7aa2f7
    export CYAN=0xff7dcfff
    export YELLOW=0xffe0af68
    export ORANGE=0xffff9e64
    export MAGENTA=0xffbb9af7
    export PINK=0xffff007c
    export GREY=0xff565f89
    export TRANSPARENT=0x00000000

    export BAR_COLOR=0x00000000
    export ICON_COLOR=$WHITE
    export LABEL_COLOR=$WHITE
    export ISLAND_BG=0xd91a1b26
    export ISLAND_BORDER=0xff3b4261
    export POPUP_BG=0xff1a1b26
    export ACCENT=$CYAN

    # Transparent bar with offset for floating islands
    sketchybar --bar \
      height=28 \
      position=top \
      sticky=on \
      y_offset=2 \
      margin=6 \
      padding_left=6 \
      padding_right=6 \
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
      background.height=24 \
      popup.background.color=$POPUP_BG \
      popup.background.corner_radius=12 \
      popup.background.border_width=2 \
      popup.background.border_color=$ISLAND_BORDER

    # === LEFT ISLAND ===

    # Apple logo (click to open System Settings)
    sketchybar --add item apple left \
      --set apple \
      icon= \
      icon.font="JetBrainsMono Nerd Font:Bold:16.0" \
      icon.color=$ACCENT \
      icon.padding_left=12 \
      icon.padding_right=8 \
      label.drawing=off \
      background.drawing=off \
      click_script="open -a 'System Settings'"

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
      background.corner_radius=10 \
      background.height=28 \
      background.border_width=1 \
      background.border_color=$ISLAND_BORDER

    # === RIGHT ISLAND ===

    # Clock (click to open Calendar)
    sketchybar --add item clock right \
      --set clock \
      update_freq=30 \
      icon= \
      icon.color=$PINK \
      icon.padding_left=12 \
      script="$CONFIG_DIR/plugins/clock.sh" \
      click_script="open -a Calendar"

    # Battery (click to open Energy settings)
    sketchybar --add item battery right \
      --set battery \
      update_freq=120 \
      script="$CONFIG_DIR/plugins/battery.sh" \
      click_script="open 'x-apple.systempreferences:com.apple.preference.battery'" \
      --subscribe battery system_woke power_source_change

    # Volume (click to open Sound settings)
    sketchybar --add item volume right \
      --set volume \
      script="$CONFIG_DIR/plugins/volume.sh" \
      click_script="open 'x-apple.systempreferences:com.apple.preference.sound'" \
      --subscribe volume volume_change

    # WiFi (click to open WiFi settings)
    sketchybar --add item wifi right \
      --set wifi \
      update_freq=5 \
      icon=󰖩 \
      icon.color=$GREEN \
      label.drawing=on \
      script="$CONFIG_DIR/plugins/wifi.sh" \
      click_script="open 'x-apple.systempreferences:com.apple.wifi-settings-extension'"

    # CPU (click to open Activity Monitor)
    sketchybar --add item cpu right \
      --set cpu \
      update_freq=5 \
      icon= \
      icon.color=$CYAN \
      label.padding_right=12 \
      script="$CONFIG_DIR/plugins/cpu.sh" \
      click_script="open -a 'Activity Monitor'"

    # Media (in right island, click to play/pause)
    sketchybar --add item media right \
      --set media \
      icon= \
      icon.color=$GREEN \
      icon.padding_left=12 \
      label.max_chars=30 \
      scroll_texts=on \
      update_freq=3 \
      script="$CONFIG_DIR/plugins/media.sh" \
      click_script="$CONFIG_DIR/plugins/media_click.sh" \
      --subscribe media media_change

    # Right island bracket
    sketchybar --add bracket right_island media cpu wifi volume battery clock \
      --set right_island \
      background.color=$ISLAND_BG \
      background.corner_radius=10 \
      background.height=28 \
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
        COLOR=0xff9ece6a  # green
      elif [ "$PERCENTAGE" -gt 80 ]; then
        ICON="󰁹"
        COLOR=0xff9ece6a  # green
      elif [ "$PERCENTAGE" -gt 60 ]; then
        ICON="󰂀"
        COLOR=0xff7dcfff  # cyan
      elif [ "$PERCENTAGE" -gt 40 ]; then
        ICON="󰁾"
        COLOR=0xffe0af68  # yellow
      elif [ "$PERCENTAGE" -gt 20 ]; then
        ICON="󰁻"
        COLOR=0xffff9e64  # orange
      else
        ICON="󰁺"
        COLOR=0xfff7768e  # red
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
        COLOR=0xff565f89  # grey
      elif [ "$VOLUME" -lt 33 ]; then
        ICON="󰕿"
        COLOR=0xffbb9af7  # magenta
      elif [ "$VOLUME" -lt 66 ]; then
        ICON="󰖀"
        COLOR=0xffbb9af7
      else
        ICON="󰕾"
        COLOR=0xffbb9af7
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
      SSID=$(networksetup -getairportnetwork en0 2>/dev/null | sed 's/Current Wi-Fi Network: //')
      if [ -z "$SSID" ] || [ "$SSID" = "You are not associated with an AirPort network." ]; then
        sketchybar --set $NAME icon=󰖪 icon.color=0xff565f89 label=""
      else
        sketchybar --set $NAME icon=󰖩 icon.color=0xff9ece6a label="$SSID"
      fi
    '';
  };

  xdg.configFile."sketchybar/plugins/media.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      # Try Spotify first, then Apple Music
      SPOTIFY_RUNNING=$(pgrep -x "Spotify" >/dev/null && echo "true" || echo "false")
      MUSIC_RUNNING=$(pgrep -x "Music" >/dev/null && echo "true" || echo "false")

      if [ "$SPOTIFY_RUNNING" = "true" ]; then
        STATE=$(osascript -e 'tell application "Spotify" to player state as string' 2>/dev/null)
        if [ "$STATE" = "playing" ]; then
          TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
          ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
          sketchybar --set $NAME drawing=on icon= icon.color=0xff1db954 label="$ARTIST – $TRACK"
        elif [ "$STATE" = "paused" ]; then
          TRACK=$(osascript -e 'tell application "Spotify" to name of current track as string' 2>/dev/null)
          ARTIST=$(osascript -e 'tell application "Spotify" to artist of current track as string' 2>/dev/null)
          sketchybar --set $NAME drawing=on icon= icon.color=0xff939ab7 label="$ARTIST – $TRACK"
        else
          sketchybar --set $NAME drawing=off
        fi
      elif [ "$MUSIC_RUNNING" = "true" ]; then
        STATE=$(osascript -e 'tell application "Music" to player state as string' 2>/dev/null)
        if [ "$STATE" = "playing" ]; then
          TRACK=$(osascript -e 'tell application "Music" to name of current track as string' 2>/dev/null)
          ARTIST=$(osascript -e 'tell application "Music" to artist of current track as string' 2>/dev/null)
          sketchybar --set $NAME drawing=on icon=󰎆 icon.color=0xfffc3c44 label="$ARTIST – $TRACK"
        elif [ "$STATE" = "paused" ]; then
          TRACK=$(osascript -e 'tell application "Music" to name of current track as string' 2>/dev/null)
          ARTIST=$(osascript -e 'tell application "Music" to artist of current track as string' 2>/dev/null)
          sketchybar --set $NAME drawing=on icon= icon.color=0xff939ab7 label="$ARTIST – $TRACK"
        else
          sketchybar --set $NAME drawing=off
        fi
      else
        sketchybar --set $NAME drawing=off
      fi
    '';
  };

  xdg.configFile."sketchybar/plugins/media_click.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      # Toggle play/pause for Spotify or Apple Music
      SPOTIFY_RUNNING=$(pgrep -x "Spotify" >/dev/null && echo "true" || echo "false")
      MUSIC_RUNNING=$(pgrep -x "Music" >/dev/null && echo "true" || echo "false")

      if [ "$SPOTIFY_RUNNING" = "true" ]; then
        osascript -e 'tell application "Spotify" to playpause'
      elif [ "$MUSIC_RUNNING" = "true" ]; then
        osascript -e 'tell application "Music" to playpause'
      fi
    '';
  };

  # JankyBorders - Window borders (Tokyo Night cyan)
  xdg.configFile."borders/bordersrc" = {
    executable = true;
    text = ''
      #!/bin/bash

      options=(
        style=round
        width=5.0
        hidpi=on
        active_color=0xff7dcfff
        inactive_color=0x00000000
      )

      borders "''${options[@]}"
    '';
  };
  };
}
