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
    window-padding-x = 10
    window-padding-y = 10
    window-decoration = false
    copy-on-select = clipboard
    confirm-close-surface = false
    shell-integration = fish
    command = ${pkgs.fish}/bin/fish

    # Transparency and blur
    background-opacity = 0.95
    background-blur-radius = 20

    # Nord color scheme
    background = 2e3440
    foreground = d8dee9
    cursor-color = d8dee9
    selection-background = 4c566a
    selection-foreground = d8dee9

    # Normal colors
    palette = 0=#3b4252
    palette = 1=#bf616a
    palette = 2=#a3be8c
    palette = 3=#ebcb8b
    palette = 4=#81a1c1
    palette = 5=#b48ead
    palette = 6=#88c0d0
    palette = 7=#e5e9f0

    # Bright colors
    palette = 8=#4c566a
    palette = 9=#bf616a
    palette = 10=#a3be8c
    palette = 11=#ebcb8b
    palette = 12=#81a1c1
    palette = 13=#b48ead
    palette = 14=#8fbcbb
    palette = 15=#eceff4
  '';

  # Zed editor
  xdg.configFile."zed/settings.json".text = builtins.toJSON {
    theme = "One Dark";
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
