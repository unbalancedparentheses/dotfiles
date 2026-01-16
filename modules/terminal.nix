# Terminal and editor configurations (Ghostty, Zed)
{ config, pkgs, lib, ... }:

{
  # Ghostty terminal
  xdg.configFile."ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    font-size = 14
    cursor-style = block
    cursor-style-blink = false
    mouse-hide-while-typing = true
    window-padding-x = 10
    window-padding-y = 10
    window-decoration = true
    copy-on-select = clipboard
    confirm-close-surface = false
    shell-integration = fish
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
