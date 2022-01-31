{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    #nix
    #niv

    #cli
    fish
    exa
    mosh
    ranger
    ripgrep
    rsync
    tig

    tokei

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
    lua
  ];

  programs.fish = {
    enable = true;
    shellAliases = {
      ls = "exa";
    };
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    viAlias = true;

    plugins = with pkgs.vimPlugins; [
      ctrlp
      editorconfig-vim
      nerdtree
      vim-elixir
      vim-nix
      vim-markdown
    ];
  };

  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
    };
  };

  programs.direnv = {
    enable = true;
  };
}
