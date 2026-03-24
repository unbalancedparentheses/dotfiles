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
      set -gx LC_ALL en_US.UTF-8
      set -gx LANG en_US.UTF-8

      # Auto-attach tmux (including inside cmux for stable scrollback/copy)
      if not set -q TMUX; and status is-interactive
        exec ${pkgs.tmux}/bin/tmux new-session
      end
    '';
    functions = {
      cmux-layout = ''
        # Bootstrap cmux workspaces for common projects
        set -l projects rust-chat fatcrash jepa-rs learning_luxury
        for project in $projects
          set -l dir ~/projects/$project
          if test -d $dir
            cmux new-workspace --cwd $dir
          end
        end
      '';
      cmux-agents = ''
        # Set up an agent workspace for a project
        # Usage: cmux-agents ~/projects/rust-chat [watch-cmd]
        set -l dir $argv[1]
        set -l watch_cmd $argv[2]

        if not test -d "$dir"
          echo "Usage: cmux-agents <project-dir> [watch-cmd]"
          return 1
        end

        set -l name (basename $dir)

        # Main workspace — Claude Code
        cmux new-workspace --cwd $dir
        cmux send "claude"

        # Right split — second agent or shell
        cmux new-split right --cwd $dir

        # Bottom-right split — watcher
        cmux new-split down --cwd $dir
        if test -n "$watch_cmd"
          cmux send "$watch_cmd"
        else if test -f $dir/Cargo.toml
          cmux send "cargo watch -x check"
        else if test -f $dir/package.json
          cmux send "npm run dev"
        else if test -f $dir/Makefile
          cmux send "make"
        end
      '';
      __cmux_preexec = {
        onEvent = "fish_preexec";
        body = ''
          set -g __cmux_cmd_start (date +%s)
          set -g __cmux_cmd_name $argv[1]
        '';
      };
      __cmux_postexec = {
        onEvent = "fish_postexec";
        body = ''
          set -l st $status
          if set -q CMUX_WORKSPACE_ID; and set -q __cmux_cmd_start
            set -l elapsed (math (date +%s) - $__cmux_cmd_start)
            if test $elapsed -ge 30
              if test $st -eq 0
                cmux notify --title "Done ($elapsed""s)" --body "$__cmux_cmd_name"
              else
                cmux notify --title "Failed ($elapsed""s)" --body "$__cmux_cmd_name exited $st"
              end
            end
          end
          set -e __cmux_cmd_start
          set -e __cmux_cmd_name
        '';
      };
    };
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
