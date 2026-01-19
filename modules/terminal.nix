# Terminal and editor configurations (Ghostty, Zed)
{ config, pkgs, lib, ... }:

{
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
    window-decoration = false
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
