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
    inner.horizontal = 8
    inner.vertical = 4
    outer.left = 8
    outer.bottom = 4
    outer.top = 16
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

    # Float rules - dialogs and utilities
    [[on-window-detected]]
    if.app-id = 'com.apple.systempreferences'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.SystemPreferences'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.finder'
    if.window-title-regex-substring = '(Copy|Move|Delete|Trash|Info|Connect)'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.agilebits.onepassword7'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.1password.1password'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.calculator'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.ActivityMonitor'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.DigitalColorMeter'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.ColorSyncUtility'
    run = 'layout floating'

    [[on-window-detected]]
    if.app-id = 'com.apple.ScreenSharing'
    run = 'layout floating'

    [[on-window-detected]]
    if.window-title-regex-substring = '(Preferences|Settings|About|Update)'
    run = 'layout floating'

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
      icon.padding_left=12 \
      icon.padding_right=6 \
      label.font="JetBrainsMono Nerd Font:Medium:13.0" \
      label.color=$LABEL_COLOR \
      label.padding_left=6 \
      label.padding_right=12 \
      background.color=$TRANSPARENT \
      background.height=26 \
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
      icon.padding_left=14 \
      icon.padding_right=10 \
      label.drawing=off \
      background.drawing=off \
      click_script="open -a 'System Settings'"

    # AeroSpace workspaces (dynamic visibility)
    sketchybar --add event aerospace_workspace_change

    for sid in 1 2 3 4 5 6 7 8 9; do
      sketchybar --add item space.$sid left \
        --set space.$sid \
        icon="$sid" \
        icon.font="JetBrainsMono Nerd Font:Bold:10.0" \
        icon.padding_left=8 \
        icon.padding_right=2 \
        icon.color=$GREY \
        icon.highlight_color=$ACCENT \
        label.font="sketchybar-app-font:Regular:14.0" \
        label.padding_left=2 \
        label.padding_right=8 \
        label.drawing=off \
        background.color=$TRANSPARENT \
        background.corner_radius=8 \
        background.height=24 \
        background.drawing=off \
        drawing=off \
        click_script="aerospace workspace $sid" \
        script="$CONFIG_DIR/plugins/space.sh $sid" \
        --subscribe space.$sid aerospace_workspace_change mouse.clicked
    done

    # Front app (with icon)
    sketchybar --add item front_app left \
      --set front_app \
      icon.drawing=on \
      icon.font="sketchybar-app-font:Regular:15.0" \
      icon.padding_left=8 \
      label.font="JetBrainsMono Nerd Font:Bold:13.0" \
      label.padding_left=8 \
      label.padding_right=14 \
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

    # Clock (click to open Calendar)
    sketchybar --add item clock right \
      --set clock \
      update_freq=30 \
      icon= \
      icon.color=$PINK \
      icon.padding_left=10 \
      icon.padding_right=10 \
      label.drawing=off \
      script="$CONFIG_DIR/plugins/clock.sh" \
      click_script="open -a Calendar"

    # Battery (click to open Energy settings)
    sketchybar --add item battery right \
      --set battery \
      update_freq=120 \
      icon.padding_left=10 \
      icon.padding_right=10 \
      label.drawing=off \
      script="$CONFIG_DIR/plugins/battery.sh" \
      click_script="open 'x-apple.systempreferences:com.apple.preference.battery'" \
      --subscribe battery system_woke power_source_change

    # Volume (click to open Sound settings)
    sketchybar --add item volume right \
      --set volume \
      icon.padding_left=10 \
      icon.padding_right=10 \
      label.drawing=off \
      script="$CONFIG_DIR/plugins/volume.sh" \
      click_script="open 'x-apple.systempreferences:com.apple.preference.sound'" \
      --subscribe volume volume_change

    # WiFi (click to open WiFi settings)
    sketchybar --add item wifi right \
      --set wifi \
      update_freq=5 \
      icon=󰖩 \
      icon.color=$GREEN \
      icon.padding_left=10 \
      icon.padding_right=10 \
      label.drawing=off \
      script="$CONFIG_DIR/plugins/wifi.sh" \
      click_script="open 'x-apple.systempreferences:com.apple.wifi-settings-extension'"

    # Weather
    sketchybar --add item weather right \
      --set weather \
      update_freq=900 \
      icon= \
      icon.color=$YELLOW \
      icon.padding_left=10 \
      icon.padding_right=10 \
      label.drawing=off \
      script="$CONFIG_DIR/plugins/weather.sh"

    # CPU graph (click to open Activity Monitor)
    sketchybar --add graph cpu right 40 \
      --set cpu \
      update_freq=2 \
      icon= \
      icon.color=$CYAN \
      icon.padding_left=10 \
      icon.padding_right=0 \
      label.drawing=off \
      graph.color=$CYAN \
      graph.fill_color=0x407dcfff \
      graph.line_width=1 \
      width=50 \
      script="$CONFIG_DIR/plugins/cpu.sh" \
      click_script="open -a 'Activity Monitor'"

    # Memory graph
    sketchybar --add graph memory right 40 \
      --set memory \
      update_freq=5 \
      icon=󰍛 \
      icon.color=$MAGENTA \
      icon.padding_left=10 \
      icon.padding_right=0 \
      label.drawing=off \
      graph.color=$MAGENTA \
      graph.fill_color=0x40bb9af7 \
      graph.line_width=1 \
      width=50 \
      script="$CONFIG_DIR/plugins/memory.sh" \
      click_script="open -a 'Activity Monitor'"

    # Media (in right island, click to play/pause)
    sketchybar --add item media right \
      --set media \
      icon= \
      icon.color=$GREEN \
      icon.padding_left=10 \
      label.max_chars=30 \
      label.drawing=on \
      scroll_texts=on \
      update_freq=3 \
      script="$CONFIG_DIR/plugins/media.sh" \
      click_script="$CONFIG_DIR/plugins/media_click.sh" \
      --subscribe media media_change

    # Right island bracket (system info + media)
    sketchybar --add bracket right_island media memory cpu weather wifi volume battery clock \
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

      # Get app icon for sketchybar-app-font
      get_app_icon() {
        local app="$1"
        echo ":$(echo "$app" | tr '[:upper:]' '[:lower:]' | tr ' ' '_'):"
      }

      update() {
        # Get first app in workspace for icon
        FIRST_APP=$(aerospace list-windows --workspace "$WORKSPACE_ID" --format "%{app-name}" 2>/dev/null | head -1)

        if [ -n "$FIRST_APP" ]; then
          # Show number + app icon
          ICON=$(get_app_icon "$FIRST_APP")
          sketchybar --set $NAME \
            icon="$WORKSPACE_ID" \
            icon.font="JetBrainsMono Nerd Font:Bold:10.0" \
            label="$ICON" \
            label.font="sketchybar-app-font:Regular:14.0" \
            label.drawing=on
        else
          # Empty workspace - just show number
          sketchybar --set $NAME \
            icon="$WORKSPACE_ID" \
            icon.font="JetBrainsMono Nerd Font:Bold:12.0" \
            label.drawing=off
        fi

        if [ "$FOCUSED_WORKSPACE" = "$WORKSPACE_ID" ]; then
          sketchybar --set $NAME \
            icon.highlight=on \
            icon.color=0xff7dcfff \
            label.color=0xff7dcfff \
            background.drawing=on \
            background.color=0x257dcfff \
            background.corner_radius=8 \
            background.border_width=1 \
            background.border_color=0x807dcfff
        else
          sketchybar --set $NAME \
            icon.highlight=off \
            icon.color=0xff565f89 \
            label.color=0xff565f89 \
            background.drawing=off \
            background.border_width=0
        fi
      }

      mouse_clicked() {
        aerospace workspace "$WORKSPACE_ID"
      }

      case "$SENDER" in
        mouse.clicked) mouse_clicked ;;
        *) update ;;
      esac
    '';
  };

  # Dynamic workspace visibility updater
  xdg.configFile."sketchybar/plugins/spaces_update.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      # Show only active/occupied workspaces with numbers + app icons

      get_app_icon() {
        local app="$1"
        echo ":$(echo "$app" | tr '[:upper:]' '[:lower:]' | tr ' ' '_'):"
      }

      OCCUPIED=$(aerospace list-workspaces --monitor all --empty no 2>/dev/null)
      FOCUSED=$(aerospace list-workspaces --focused 2>/dev/null || echo "1")

      for sid in 1 2 3 4 5 6 7 8 9; do
        if echo "$OCCUPIED" | grep -qw "$sid" || [ "$FOCUSED" = "$sid" ]; then
          # Get first app for icon
          FIRST_APP=$(aerospace list-windows --workspace "$sid" --format "%{app-name}" 2>/dev/null | head -1)

          if [ -n "$FIRST_APP" ]; then
            ICON=$(get_app_icon "$FIRST_APP")
            sketchybar --set space.$sid \
              drawing=on \
              icon="$sid" \
              icon.font="JetBrainsMono Nerd Font:Bold:10.0" \
              label="$ICON" \
              label.font="sketchybar-app-font:Regular:14.0" \
              label.drawing=on
          else
            sketchybar --set space.$sid \
              drawing=on \
              icon="$sid" \
              icon.font="JetBrainsMono Nerd Font:Bold:12.0" \
              label.drawing=off
          fi

          if [ "$FOCUSED" = "$sid" ]; then
            sketchybar --set space.$sid \
              icon.highlight=on \
              icon.color=0xff7dcfff \
              label.color=0xff7dcfff \
              background.drawing=on \
              background.color=0x257dcfff \
              background.corner_radius=8 \
              background.border_width=1 \
              background.border_color=0x807dcfff
          else
            sketchybar --set space.$sid \
              icon.highlight=off \
              icon.color=0xff565f89 \
              label.color=0xff565f89 \
              background.drawing=off \
              background.border_width=0
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
      # Update label (hidden, but available for potential popup)
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

      sketchybar --set $NAME icon="$ICON" icon.color=$COLOR
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

      sketchybar --set $NAME icon="$ICON" icon.color=$COLOR
    '';
  };

  xdg.configFile."sketchybar/plugins/cpu.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      CPU=$(top -l 1 -n 0 2>/dev/null | grep -E "^CPU" | grep -Eo '[0-9]+\.[0-9]+' | head -1)
      [ -z "$CPU" ] && CPU="0"
      # Push value to graph (0-100 scale, normalized to 0-1)
      CPU_INT=''${CPU%.*}
      CPU_NORMALIZED=$(echo "scale=2; $CPU_INT / 100" | bc)
      sketchybar --push $NAME $CPU_NORMALIZED
    '';
  };

  xdg.configFile."sketchybar/plugins/memory.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      # Get memory pressure (percentage of memory used)
      MEMORY=$(memory_pressure 2>/dev/null | grep "System-wide memory free percentage" | awk '{print 100-$5}')
      [ -z "$MEMORY" ] && MEMORY="0"

      # Push value to graph (normalized to 0-1)
      MEMORY_NORMALIZED=$(echo "scale=2; $MEMORY / 100" | bc)
      sketchybar --push $NAME $MEMORY_NORMALIZED
    '';
  };

  xdg.configFile."sketchybar/plugins/wifi.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      # Check if connected by looking for an IP address on en0
      IP=$(ipconfig getifaddr en0 2>/dev/null)

      if [ -z "$IP" ]; then
        sketchybar --set $NAME icon=󰖪 icon.color=0xff565f89
      else
        sketchybar --set $NAME icon=󰖩 icon.color=0xff9ece6a
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
          sketchybar --set $NAME drawing=on icon= icon.color=0xff565f89 label="$ARTIST – $TRACK"
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
          sketchybar --set $NAME drawing=on icon= icon.color=0xff565f89 label="$ARTIST – $TRACK"
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

  xdg.configFile."sketchybar/plugins/weather.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      # Fetch weather from wttr.in (no API key needed)
      WEATHER=$(curl -s "wttr.in/?format=%c%t" 2>/dev/null | head -1)

      if [ -z "$WEATHER" ] || [[ "$WEATHER" == *"Unknown"* ]]; then
        sketchybar --set $NAME icon=""
      else
        # Extract icon and temp
        ICON=$(echo "$WEATHER" | cut -c1-1)

        # Map weather emoji to nerd font icons
        case "$ICON" in
          ☀️|☀) NERD_ICON="" ;;
          🌤️|🌤|⛅) NERD_ICON="" ;;
          ☁️|☁) NERD_ICON="" ;;
          🌧️|🌧|🌦️|🌦) NERD_ICON="" ;;
          ⛈️|⛈|🌩️|🌩) NERD_ICON="" ;;
          🌨️|🌨|❄️|❄) NERD_ICON="" ;;
          🌫️|🌫) NERD_ICON="" ;;
          *) NERD_ICON="" ;;
        esac

        sketchybar --set $NAME icon="$NERD_ICON"
      fi
    '';
  };

  # JankyBorders - Window borders with glow
  xdg.configFile."borders/bordersrc" = {
    executable = true;
    text = ''
      #!/bin/bash

      borders \
        style=round \
        width=5.0 \
        hidpi=on \
        active_color=0xc07dcfff \
        inactive_color=0x00000000
    '';
  };
  };
}
