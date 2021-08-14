{ config, pkgs, ... }:

{
  home.stateVersion = "21.11";
  programs.home-manager.enable = true;

  home.username = "unbalanced";
  home.homeDirectory = "/home/unbalanced";

  home.packages = with pkgs; [
    exa
    mosh
    ranger
    ripgrep
    rsync

    # networking
    curl
    aria2
    bandwhich
    htop
    netcat
    nmap
    prettyping
    wget
    youtube-dl
  ];

  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
    };
  };

  programs.direnv = {
    enable = true;
    enableFishIntegration = true;
  };
}
