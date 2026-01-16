# Fish shell configuration
{ config, pkgs, lib, ... }:

{
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

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    icons = "auto";
  };
}
