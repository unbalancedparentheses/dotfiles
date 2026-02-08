# SSH configuration via Home Manager
{ config, pkgs, lib, ... }:

{
  programs.ssh = {
    enable = true;

    # Global settings
    extraConfig = ''
      AddKeysToAgent yes
      IdentitiesOnly yes
    '';

    # SSH hosts
    matchBlocks = {
      # GitHub
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };

      # GitLab
      "gitlab.com" = {
        hostname = "gitlab.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };

      # Codeberg
      "codeberg.org" = {
        hostname = "codeberg.org";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };

      # Local VMs
      "openbsd-vm" = {
        hostname = "localhost";
        port = 2222;
        user = "root";
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      };

      "nixos-vm" = {
        hostname = "localhost";
        port = 2224;
        user = "root";
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      };

      "void-vm" = {
        hostname = "localhost";
        port = 2223;
        user = "root";
        identityFile = "~/.ssh/id_ed25519";
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      };

      # Wildcard for all hosts - keep connection alive
      "*" = {
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
        compression = true;
      };

      # Example remote server (uncomment and customize)
      # "myserver" = {
      #   hostname = "192.168.1.100";
      #   user = "admin";
      #   port = 22;
      #   identityFile = "~/.ssh/id_ed25519";
      #   forwardAgent = true;
      # };

      # Example jump host (uncomment and customize)
      # "internal-server" = {
      #   hostname = "10.0.0.50";
      #   user = "admin";
      #   proxyJump = "jumphost";
      # };
    };
  };

  # SSH agent (macOS uses system keychain, Linux uses ssh-agent)
  services.ssh-agent.enable = pkgs.stdenv.isLinux;
}
