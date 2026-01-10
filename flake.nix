{
  description = "Cross-platform Nix configuration (macOS + Linux)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
  let
    # =========================================================================
    # User configuration - edit these values
    # =========================================================================
    username = "federicocarrone";
    gitName = "Federico Carrone";
    gitEmail = "mail@fcarrone.com";

    # Supported systems
    darwinSystem = "aarch64-darwin"; # aarch64-darwin (Apple Silicon) or x86_64-darwin (Intel)
    linuxSystem = "x86_64-linux";    # x86_64-linux or aarch64-linux

    # =========================================================================
    # Shared packages - installed on both macOS and Linux
    # =========================================================================
    sharedPackages = pkgs: with pkgs; [
      neovim
      git

      # Modern CLI tools
      eza        # Modern ls
      bat        # Modern cat
      jq         # JSON processor
      htop       # Process viewer
      lazygit    # Git TUI
      delta      # Better git diff
      gh         # GitHub CLI
      zoxide     # Smart cd
      fzf        # Fuzzy finder
      ripgrep    # Fast grep
      fd         # Fast find
      tldr       # Simplified man pages
      btop       # Better htop
      dust       # Better du
      tree       # Directory tree
      wget       # Download files
      tmux       # Terminal multiplexer
      tig        # Git TUI
      glow       # Markdown renderer
      rustup     # Rust toolchain manager
    ];

    # macOS-only packages
    darwinPackages = pkgs: with pkgs; [
      qemu       # VM emulation (for OpenBSD VM)
      expect     # For automated VM installation
    ];

    # Linux-only fonts (nix packages)
    linuxFonts = pkgs: with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
    ];

    # =========================================================================
    # Shared Home Manager configuration
    # =========================================================================
    sharedHomeConfig = { pkgs, lib, ... }: {
      home.stateVersion = "24.05";

      # Disable documentation generation (fixes builtins.toFile warning)
      manual.manpages.enable = false;
      manual.html.enable = false;
      manual.json.enable = false;

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
          git_branch = {
            symbol = " ";
          };
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

      # Fish shell configuration
      programs.fish = {
        enable = true;
        interactiveShellInit = ''
          set -g fish_greeting

          # Cargo/Rust
          fish_add_path ~/.cargo/bin

          # Pyenv
          set -gx PYENV_ROOT $HOME/.pyenv
          fish_add_path $PYENV_ROOT/bin
          if command -v pyenv > /dev/null
            pyenv init - | source
          end

          # Locale
          set -gx LC_ALL en_US.UTF-8
          set -gx LANG en_US.UTF-8
        '';
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

      # Zoxide
      programs.zoxide = {
        enable = true;
        enableFishIntegration = true;
      };

      # Bat configuration
      programs.bat = {
        enable = true;
        config = {
          theme = "TwoDark";
        };
      };

      # Git configuration
      programs.git = {
        enable = true;
        settings = {
          user.name = gitName;
          user.email = gitEmail;
          init.defaultBranch = "main";
          push.autoSetupRemote = true;
          pull.rebase = true;
        };
      };

      # Delta (git diff viewer)
      programs.delta = {
        enable = true;
        options = {
          navigate = true;
          side-by-side = true;
        };
      };

      # FZF
      programs.fzf = {
        enable = true;
        enableFishIntegration = true;
      };

      # Eza
      programs.eza = {
        enable = true;
        enableFishIntegration = true;
        icons = "auto";
      };

      # Tmux
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
          # Reload config
          bind r source-file ~/.config/tmux/tmux.conf \; display "Reloaded!"

          # Split panes with | and -
          bind | split-window -h -c "#{pane_current_path}"
          bind - split-window -v -c "#{pane_current_path}"
          unbind '"'
          unbind %

          # Navigate panes with vim keys
          bind h select-pane -L
          bind j select-pane -D
          bind k select-pane -U
          bind l select-pane -R

          # Resize panes with vim keys
          bind -r H resize-pane -L 5
          bind -r J resize-pane -D 5
          bind -r K resize-pane -U 5
          bind -r L resize-pane -R 5

          # New window in current path
          bind c new-window -c "#{pane_current_path}"

          # Status bar
          set -g status-position top
          set -g status-style 'bg=#1e1e2e fg=#cdd6f4'
          set -g status-left '#[fg=#89b4fa,bold] #S '
          set -g status-right '#[fg=#a6adc8] %Y-%m-%d %H:%M '
          set -g status-left-length 50
          set -g window-status-current-format '#[fg=#89b4fa,bold] #I:#W '
          set -g window-status-format '#[fg=#6c7086] #I:#W '

          # Pane borders
          set -g pane-border-style 'fg=#313244'
          set -g pane-active-border-style 'fg=#89b4fa'

          # Enable true color
          set -ag terminal-overrides ",xterm-256color:RGB"
        '';
      };
    };

    # =========================================================================
    # macOS (nix-darwin) configuration
    # =========================================================================
    darwinConfiguration = { pkgs, ... }: {
      environment.systemPackages = (sharedPackages pkgs) ++ (darwinPackages pkgs);

      # Disable nix-darwin's Nix management (using Determinate Nix installer)
      nix.enable = false;

      # Enable Fish shell
      programs.fish.enable = true;
      environment.shells = [ pkgs.fish ];

      # Set Fish as default shell for user
      users.users.${username} = {
        shell = pkgs.fish;
      };

      # System settings
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 5;
      system.primaryUser = username;
      nixpkgs.hostPlatform = darwinSystem;

      # macOS system preferences
      system.defaults = {
        # Dock
        dock.autohide = true;
        dock.mru-spaces = false;
        dock.minimize-to-application = true;
        dock.show-recents = false;

        # Finder
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        finder.FXEnableExtensionChangeWarning = false;
        finder.ShowPathbar = true;
        finder.ShowStatusBar = true;
        NSGlobalDomain.AppleShowAllFiles = true;

        # Trackpad
        trackpad.Clicking = true;
        trackpad.TrackpadRightClick = true;
        trackpad.TrackpadThreeFingerDrag = true;

        # Keyboard
        NSGlobalDomain.KeyRepeat = 2;
        NSGlobalDomain.InitialKeyRepeat = 15;
        NSGlobalDomain.ApplePressAndHoldEnabled = false;
        NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
        NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
        NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;

        # Menu bar
        controlcenter.BatteryShowPercentage = true;

        # Siri
        CustomUserPreferences."com.apple.Siri".SiriPrefStashedStatusMenuVisible = false;
        CustomUserPreferences."com.apple.Siri".VoiceTriggerUserEnabled = false;

        # Screenshots
        screencapture.location = "~/Pictures/Screenshots";
        screencapture.type = "png";

        # Security
        screensaver.askForPasswordDelay = 10;
      };

      # Create Screenshots directory
      system.activationScripts.postActivation.text = ''
        mkdir -p ~/Pictures/Screenshots
      '';

      # Homebrew
      homebrew = {
        enable = true;
        onActivation = {
          autoUpdate = false;
          cleanup = "uninstall";  # Less aggressive than "zap"
        };

        casks = [
          # Browsers
          "brave-browser"
          "firefox"

          # Communication
          "telegram-desktop"
          "slack"
          "zoom"
          "whatsapp"
          "signal"

          # Productivity
          "1password"
          "notion"
          "caffeine"
          "obsidian"

          # Development
          "ghostty"
          "github"
          # "docker-desktop"
          "zed"
          "claude"
          "claude-code"

          # Media
          "spotify"

          # Utilities
          "utm"

          # Fonts
          "font-jetbrains-mono-nerd-font"
          "font-fira-code-nerd-font"
          "font-hack-nerd-font"
        ];
      };
    };

    # macOS Home Manager configuration
    darwinHomeConfig = { pkgs, lib, ... }: {
      imports = [ sharedHomeConfig ];
      home.username = username;
      home.homeDirectory = lib.mkForce "/Users/${username}";
    };

    # =========================================================================
    # Linux Home Manager configuration (standalone)
    # =========================================================================
    linuxHomeConfig = { pkgs, lib, ... }: {
      imports = [ sharedHomeConfig ];
      home.username = username;
      home.homeDirectory = "/home/${username}";

      # Install packages via Home Manager on Linux
      home.packages = (sharedPackages pkgs) ++ (linuxFonts pkgs);

      # Enable fontconfig for user fonts
      fonts.fontconfig.enable = true;
    };

  in
  {
    # =========================================================================
    # macOS (nix-darwin) configuration
    # Usage: darwin-rebuild switch --flake .#default
    # =========================================================================
    darwinConfigurations.default = nix-darwin.lib.darwinSystem {
      modules = [
        darwinConfiguration
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.${username} = darwinHomeConfig;
        }
      ];
    };

    # =========================================================================
    # Linux Home Manager configuration (standalone)
    # Usage: home-manager switch --flake .#linux
    # =========================================================================
    homeConfigurations."linux" = home-manager.lib.homeManagerConfiguration {
      pkgs = nixpkgs.legacyPackages.${linuxSystem};
      modules = [ linuxHomeConfig ];
    };
  };
}
