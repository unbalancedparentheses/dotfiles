# Shared Home Manager configuration
{ config, pkgs, lib, gitName, gitEmail, ... }:

{
  imports = [
    ./emacs.nix
    ./neovim.nix
    ./shell.nix
    ./starship.nix
    ./git.nix
    ./tmux.nix
    ./terminal.nix
    ./linux.nix
  ];

  # State version for Home Manager (do not change after initial setup)
  # Note: NixOS VMs use 24.11 as they are fresh installs
  home.stateVersion = "24.05";

  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;
}
