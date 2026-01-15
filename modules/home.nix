# Shared Home Manager configuration
{ config, pkgs, lib, gitName, gitEmail, ... }:

{
  imports = [ ./emacs.nix ./neovim.nix ];

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

  # Starship prompt
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch.symbol = " ";
      git_status = {
        conflicted = "=";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = "?\${count}";
        stashed = "$\${count}";
        modified = "!\${count}";
        staged = "+\${count}";
        renamed = "»\${count}";
        deleted = "✘\${count}";
      };
      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state]($style) ";
      };
    };
  };

  # Fish shell
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      fish_add_path ~/.cargo/bin
      set -gx PYENV_ROOT $HOME/.pyenv
      fish_add_path $PYENV_ROOT/bin
      if command -v pyenv > /dev/null
        pyenv init - | source
      end
      set -gx LC_ALL en_US.UTF-8
      set -gx LANG en_US.UTF-8
    '';
    # Shell abbreviations (expand on space)
    # File listing: ls, ll (long), la (all), lt (tree)
    # Git shortcuts: g, ga, gc, gp, gpl, gs, gd, lg (lazygit)
    # Editors/tools: v (nvim), t (tmux), ta (tmux attach)
    shellAbbrs = {
      ls = "eza --icons";
      ll = "eza -l --icons";
      la = "eza -la --icons";
      lt = "eza --tree --icons";
      cat = "bat";
      cd = "z";
      g = "git";
      ga = "git add";
      gc = "git commit";
      gp = "git push";
      gpl = "git pull";
      gs = "git status";
      gd = "git diff";
      lg = "lazygit";
      v = "nvim";
      t = "tmux";
      ta = "tmux attach";
    };
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "TwoDark";
  };

  # Git
  programs.git = {
    enable = true;
    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    settings = {
      user.name = gitName;
      user.email = gitEmail;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      gpg.format = "ssh";
    };
  };

  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      side-by-side = true;
    };
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    icons = "auto";
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
