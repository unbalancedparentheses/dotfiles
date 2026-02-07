# Terminal and editor configurations (Ghostty, Alacritty, Zed)
{ config, pkgs, lib, ... }:

{
  # Alacritty terminal
  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";

      window = {
        padding = { x = 16; y = 12; };
        decorations = "buttonless";
        opacity = 0.92;
        blur = true;
        option_as_alt = "Both";
      };

      font = {
        normal.family = "JetBrainsMono Nerd Font";
        size = 20;
      };

      cursor = {
        style.shape = "Block";
        style.blinking = "Never";
      };

      mouse.hide_when_typing = true;

      scrolling.history = 100000;

      selection.save_to_clipboard = true;

      # Tokyo Night color scheme
      colors = {
        primary = {
          background = "#1a1b26";
          foreground = "#c0caf5";
        };
        cursor = {
          text = "#1a1b26";
          cursor = "#7dcfff";
        };
        selection = {
          text = "#c0caf5";
          background = "#292e42";
        };
        normal = {
          black = "#15161e";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#a9b1d6";
        };
        bright = {
          black = "#414868";
          red = "#f7768e";
          green = "#9ece6a";
          yellow = "#e0af68";
          blue = "#7aa2f7";
          magenta = "#bb9af7";
          cyan = "#7dcfff";
          white = "#c0caf5";
        };
      };

      keyboard.bindings = [
        # tmux prefix shortcuts (Ctrl+b equivalents using Cmd)
        { key = "T"; mods = "Command"; chars = "\\u0002c"; }  # new window
        { key = "W"; mods = "Command"; chars = "\\u0002x"; }  # close pane
        { key = "D"; mods = "Command"; chars = "\\u0002%"; }  # split vertical
        { key = "D"; mods = "Command|Shift"; chars = "\\u0002\""; }  # split horizontal
        { key = "Left"; mods = "Command"; chars = "\\u0002p"; }   # prev window
        { key = "Right"; mods = "Command"; chars = "\\u0002n"; }  # next window
        { key = "Key1"; mods = "Command"; chars = "\\u00021"; }
        { key = "Key2"; mods = "Command"; chars = "\\u00022"; }
        { key = "Key3"; mods = "Command"; chars = "\\u00023"; }
        { key = "Key4"; mods = "Command"; chars = "\\u00024"; }
        { key = "Key5"; mods = "Command"; chars = "\\u00025"; }
      ];
    };
  };

  # Ghostty terminal
  xdg.configFile."ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    font-size = 20
    cursor-style = block
    cursor-style-blink = false
    mouse-hide-while-typing = true
    window-padding-x = 16
    window-padding-y = 12
    window-padding-balance = true
    window-decoration = true
    copy-on-select = clipboard
    confirm-close-surface = false
    shell-integration = fish
    command = ${pkgs.tmux}/bin/tmux new-session

    # Scrollback
    scrollback-limit = 1000000

    # Transparency and blur
    background-opacity = 0.92
    background-blur-radius = 40

    # Unfocused state
    unfocused-split-opacity = 0.85

    # Tokyo Night color scheme
    background = 1a1b26
    foreground = c0caf5
    cursor-color = 7dcfff
    cursor-text = 1a1b26
    selection-background = 292e42
    selection-foreground = c0caf5

    # Normal colors
    palette = 0=#15161e
    palette = 1=#f7768e
    palette = 2=#9ece6a
    palette = 3=#e0af68
    palette = 4=#7aa2f7
    palette = 5=#bb9af7
    palette = 6=#7dcfff
    palette = 7=#a9b1d6

    # Bright colors
    palette = 8=#414868
    palette = 9=#f7768e
    palette = 10=#9ece6a
    palette = 11=#e0af68
    palette = 12=#7aa2f7
    palette = 13=#bb9af7
    palette = 14=#7dcfff
    palette = 15=#c0caf5
  '';

  # Zed editor
  xdg.configFile."zed/settings.json".text = builtins.toJSON {
    theme = "Tokyo Night";
    ui_font_size = 16;
    buffer_font_size = 14;
    buffer_font_family = "JetBrainsMono Nerd Font";
    tab_size = 2;
    vim_mode = true;
    cursor_blink = false;
    relative_line_numbers = true;
    scrollbar = { show = "never"; };
    vertical_scroll_margin = 8;
    git = { inline_blame = { enabled = true; }; };
    terminal = {
      shell = { program = "fish"; };
      font_size = 14;
      font_family = "JetBrainsMono Nerd Font";
    };
    autosave = "on_focus_change";
    format_on_save = "on";
    inlay_hints = { enabled = true; };
  };
}
