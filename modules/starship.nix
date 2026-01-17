# Starship prompt configuration
{ config, pkgs, lib, ... }:

{
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
      git_status.disabled = true;
      nix_shell = {
        symbol = " ";
        format = "via [$symbol$state]($style) ";
      };
    };
  };
}
