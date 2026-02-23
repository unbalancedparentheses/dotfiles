# Claude Code CLI configuration
{ config, pkgs, lib, ... }:

let
  username = config.home.username;
  homeDir = config.home.homeDirectory;
  # Claude Code encodes paths with dashes for project config directories
  projectDir = builtins.replaceStrings ["/"] ["-"] homeDir;
in
{
  # Global settings
  home.file.".claude/settings.json".text = builtins.toJSON {
    enabledPlugins = {
      "rust-analyzer-lsp@claude-plugins-official" = true;
      "frontend-design@claude-plugins-official" = true;
    };
    skipDangerousModePermissionPrompt = true;
    model = "opus[1m]";
    statusLine = {
      type = "command";
      command = "~/.claude/statusline.sh";
    };
  };

  # Permission allowlist
  home.file.".claude/settings.local.json".text = builtins.toJSON {
    permissions = {
      allow = [
        "WebSearch"
        "WebFetch(domain:blog.lambdaclass.com)"
        "Bash(pbcopy:*)"
        "Bash(claude mcp add:*)"
        "Bash(CLAUDECODE= claude mcp add:*)"
        "Bash(git commit:*)"
        "Bash(gh api:*)"
      ];
    };
  };

  # Global project settings (Obsidian vault access)
  home.file.".claude/projects/${projectDir}/settings.json".text = builtins.toJSON {
    permissions = {
      additionalDirectories = [
        "${homeDir}/Library/Mobile Documents/iCloud~md~obsidian/Documents"
      ];
    };
  };

  # Custom agent: suckless/OpenBSD Rust simplifier
  home.file.".claude/agents/simplify.md".source = ../agents/simplify.md;

  # Status line script
  home.file.".claude/statusline.sh" = {
    executable = true;
    text = ''
      #!/bin/bash
      input=$(cat)

      MODEL=$(echo "$input" | jq -r '.model.display_name // "unknown"')
      PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
      COST=$(echo "$input" | jq -r '.cost.total_cost_usd // 0')
      DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

      # Format cost
      COST_FMT=$(printf '$%.2f' "$COST")

      # Format duration as minutes
      MINS=$(( ''${DURATION_MS%.*} / 60000 ))
      if [ "$MINS" -lt 1 ]; then
          DUR="<1min"
      else
          DUR="''${MINS}min"
      fi

      # Git info
      if git rev-parse --git-dir > /dev/null 2>&1; then
          REPO=$(basename "$(git rev-parse --show-toplevel)")
          BRANCH=$(git branch --show-current 2>/dev/null)
          DIRTY=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
          GIT="$REPO ($BRANCH)"
          if [ "$DIRTY" -gt 0 ]; then
              GIT="$GIT *$DIRTY"
          fi
          echo "$MODEL | $GIT | $COST_FMT | $DUR | ''${PCT}% ctx"
      else
          echo "$MODEL | $COST_FMT | $DUR | ''${PCT}% ctx"
      fi
    '';
  };
}
