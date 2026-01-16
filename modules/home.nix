# Shared Home Manager configuration
{ config, pkgs, lib, gitName, gitEmail, ... }:

{
  imports = [
    ./emacs.nix
    ./neovim.nix
    ./shell.nix
    ./starship.nix
    ./git.nix
  ];

  home.stateVersion = "24.05";

  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;

  # Ghostty terminal
  xdg.configFile."ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    font-size = 14
    theme = catppuccin-mocha
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

  # Tmux - Terminal multiplexer
  # Prefix: Ctrl+a (instead of default Ctrl+b)
  # Key bindings:
  #   prefix + r     Reload config
  #   prefix + |     Split vertical
  #   prefix + -     Split horizontal
  #   prefix + hjkl  Navigate panes (vim-style)
  #   prefix + HJKL  Resize panes (vim-style)
  #   prefix + c     New window
  programs.tmux = {
    enable = true;
    terminal = "tmux-256color";
    prefix = "C-a";
    baseIndex = 1;
    escapeTime = 0;
    historyLimit = 50000;
    mouse = true;
    keyMode = "vi";
    extraConfig = ''
      bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      unbind '"'
      unbind %

      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      bind c new-window -c "#{pane_current_path}"

      # Catppuccin Mocha theme
      set -g status-position top
      set -g status-style 'bg=#1e1e2e fg=#cdd6f4'
      set -g status-left '#[fg=#89b4fa,bold] #S '
      set -g status-right '#[fg=#a6adc8] %Y-%m-%d %H:%M '
      set -g status-left-length 50
      set -g window-status-current-format '#[fg=#89b4fa,bold] #I:#W '
      set -g window-status-format '#[fg=#6c7086] #I:#W '
      set -g pane-border-style 'fg=#313244'
      set -g pane-active-border-style 'fg=#89b4fa'
      set -ag terminal-overrides ",xterm-256color:RGB"
    '';
  };
}
