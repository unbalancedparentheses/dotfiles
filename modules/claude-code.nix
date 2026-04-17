# Claude Code CLI configuration
{ config, pkgs, lib, ... }:

let
  username = config.home.username;
  homeDir = config.home.homeDirectory;
  # Claude Code encodes paths with dashes for project config directories
  projectDir = builtins.replaceStrings ["/"] ["-"] homeDir;

  # Claude Code needs writable settings files, so we copy instead of symlink.
  # Files are only overwritten when the Nix-managed content changes.
  settingsJson = builtins.toJSON {
    enabledPlugins = {
      "rust-analyzer-lsp@claude-plugins-official" = true;
      "frontend-design@claude-plugins-official" = true;
    };
    skipDangerousModePermissionPrompt = true;
    model = "opus";
    attribution = {
      commit = "";
      pr = "";
    };
    enableAllProjectMcpServers = true;
    statusLine = {
      type = "command";
      command = "~/.claude/statusline.sh";
    };
    hooks = {
      # Notify cmux sidebar when a prompt completes
      PostToolUse = [];
      Stop = [
        {
          matcher = "";
          hooks = [
            {
              type = "command";
              command = "if [ -n \"$CMUX_WORKSPACE_ID\" ]; then cmux notify --title 'Claude Code' --body 'Task completed'; fi";
            }
          ];
        }
      ];
    };
  };

  settingsLocalJson = builtins.toJSON {
    permissions = {
      allow = [
        "WebSearch"
        "WebFetch(domain:blog.lambdaclass.com)"
        "Bash(pbcopy:*)"
        "Bash(claude mcp add:*)"
        "Bash(CLAUDECODE= claude mcp add:*)"
        "Bash(git commit:*)"
        "Bash(gh api:*)"
        "Bash(make:*)"
        "Bash(nix:*)"
        "Bash(cargo:*)"
        "Bash(go:*)"
        "Bash(mix:*)"
        "Bash(npm:*)"
        "Bash(mise:*)"
      ];
    };
  };

  projectSettingsJson = builtins.toJSON {
    permissions = {
      additionalDirectories = [
        "${homeDir}/Library/Mobile Documents/iCloud~md~obsidian/Documents"
      ];
    };
  };

  # Helper: write Nix content to a writable file (copy, not symlink)
  # Only overwrites if the Nix-managed base content has changed.
  writableFile = path: content:
    let
      nixManaged = pkgs.writeText (builtins.replaceStrings ["/"] ["-"] path) content;
    in ''
      mkdir -p "$(dirname "${homeDir}/${path}")"
      nix_content="${nixManaged}"
      target="${homeDir}/${path}"
      marker="${homeDir}/${path}.nix-hash"
      new_hash=$(sha256sum "$nix_content" | cut -d' ' -f1)
      if [ -L "$target" ]; then
        # Replace stale symlink with writable copy
        rm "$target"
        cp "$nix_content" "$target"
        chmod 600 "$target"
        echo "$new_hash" > "$marker"
      elif [ ! -f "$target" ]; then
        cp "$nix_content" "$target"
        chmod 600 "$target"
        echo "$new_hash" > "$marker"
      elif [ ! -f "$marker" ] || [ "$(cat "$marker")" != "$new_hash" ]; then
        # Nix config changed — overwrite
        cp "$nix_content" "$target"
        chmod 600 "$target"
        echo "$new_hash" > "$marker"
      fi
    '';
in
{
  # Deploy writable Claude Code settings on activation
  home.activation.claudeCodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${writableFile ".claude/settings.json" settingsJson}
    ${writableFile ".claude/settings.local.json" settingsLocalJson}
    ${writableFile ".claude/projects/${projectDir}/settings.json" projectSettingsJson}
  '';

  # Custom slash commands
  home.file.".claude/commands/c.md".text = ''
    Review all staged and unstaged changes with `git diff` and `git status`. Write a concise commit message that focuses on the "why", stage all changes, and commit.
  '';
  home.file.".claude/commands/cp.md".text = ''
    Review all staged and unstaged changes with `git diff` and `git status`. Write a concise commit message that focuses on the "why", stage all changes, commit, and push to the current remote branch. If the branch has no upstream yet, push with `-u origin <branch>`.
  '';
  home.file.".claude/commands/ur.md".text = ''
    Update the project roadmap based on the current state of the code:
    1. Read the existing roadmap (look for ROADMAP.md, TODO.md, or a roadmap section in README.md).
    2. Check recent git history with `git log --oneline -20` to see what was done recently.
    3. Explore the codebase to verify which planned features/tasks are now implemented.
    4. Update the roadmap: mark completed items as done, remove items that are no longer relevant, and reorder remaining items by priority. Keep the existing format and style.
    5. If no roadmap file exists, ask the user where to create one.
  '';
  home.file.".claude/commands/ns.md".text = ''
    Analyze the project and suggest the next steps:
    1. Read the roadmap if one exists (ROADMAP.md, TODO.md, or README.md).
    2. Check recent git history with `git log --oneline -20` to understand recent momentum.
    3. Look at open issues with `gh issue list --limit 10` if this is a GitHub repo.
    4. Explore the codebase for TODOs, FIXMEs, and incomplete implementations.
    5. Suggest 3-5 concrete next steps, ordered by priority. For each, explain why it matters and roughly what it involves. Be specific — reference files, functions, or issues.
  '';

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
