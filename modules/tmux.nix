# Tmux - Terminal multiplexer
# Prefix: Ctrl+a (instead of default Ctrl+b)
# Key bindings:
#   prefix + r     Reload config
#   prefix + |     Split vertical
#   prefix + -     Split horizontal
#   prefix + hjkl  Navigate panes (vim-style)
#   prefix + HJKL  Resize panes (vim-style)
#   prefix + c     New window
#   prefix + [     Enter copy mode (then v to select, y to copy, Escape to cancel)
{ config, pkgs, lib, ... }:

{
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

      # Copy mode (prefix + [ to enter, v to select, y to copy)
      bind -T copy-mode-vi v send -X begin-selection
      bind -T copy-mode-vi y send -X copy-pipe-and-cancel "pbcopy"
      bind -T copy-mode-vi Escape send -X cancel
      bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe-and-cancel "pbcopy"

      # Tokyo Night theme
      set -g status-position top
      set -g status-style 'bg=#1a1b26 fg=#c0caf5'
      set -g status-left '#[fg=#7dcfff,bold] #S '
      set -g status-right '#[fg=#565f89] %Y-%m-%d %H:%M '
      set -g status-left-length 50
      set -g window-status-current-format '#[fg=#7dcfff,bold] #I:#W '
      set -g window-status-format '#[fg=#565f89] #I:#W '
      set -g pane-border-style 'fg=#3b4261'
      set -g pane-active-border-style 'fg=#7dcfff'
      set -ag terminal-overrides ",xterm-256color:RGB"
    '';
  };
}
