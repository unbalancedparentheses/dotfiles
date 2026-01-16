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
    ./wm.nix
    ./linux.nix
  ];

  home.stateVersion = "24.05";

  manual.manpages.enable = false;
  manual.html.enable = false;
  manual.json.enable = false;
}
