# Fish shell configuration
{ config, pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      # Homebrew paths (needed for fish since it doesn't use /etc/paths.d)
      fish_add_path /opt/homebrew/bin /opt/homebrew/sbin
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
    config.theme = "tokyonight";
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    colors = {
      # Tokyo Night theme
      fg = "#c0caf5";
      bg = "#1a1b26";
      hl = "#7dcfff";
      "fg+" = "#c0caf5";
      "bg+" = "#292e42";
      "hl+" = "#7dcfff";
      info = "#7aa2f7";
      prompt = "#7dcfff";
      pointer = "#f7768e";
      marker = "#9ece6a";
      spinner = "#bb9af7";
      header = "#7dcfff";
    };
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    icons = "auto";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    flags = [ "--disable-up-arrow" ];  # Keep up arrow for normal history
    settings = {
      auto_sync = false;        # Enable if you want cloud sync
      sync_frequency = "5m";
      search_mode = "fuzzy";
      filter_mode = "global";
      style = "compact";
    };
  };

  programs.mise = {
    enable = true;
    enableFishIntegration = true;
    globalConfig = {
      tools = {
        rust = "latest";
        go = "latest";
        python = "latest";
        node = "latest";
        erlang = "latest";
        elixir = "latest";
        zig = "latest";
        gleam = "latest";
      };
      settings = {
        auto_install = true;
      };
    };
  };
}
