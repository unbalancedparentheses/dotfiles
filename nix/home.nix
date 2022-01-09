{ config, pkgs, ... }:

{
  home.stateVersion = "21.11";
  programs.home-manager.enable = true;

  home.username = "unbalanced";
  home.homeDirectory = "/home/unbalanced";

  home.allowUnfree = true;
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
    lua
  ];

  programs.neovim = {
    enable = true;
    vimAlias = true;
          viAlias = true;

    plugins = with pkgs.vimPlugins; [
      # Appearance
      vim-table-mode # vimscript
      indentLine  # vimscript
      indent-blankline-nvim
      nvim-tree-lua
      nvim-web-devicons
      one-nvim

      # Programming
      vim-which-key          # vimscript
      vim-nix                # vimscript
      lspkind-nvim
      nvim-treesitter
      nvim-treesitter-refactor
      nvim-treesitter-textobjects
      nvim-lspconfig
      nvim-compe
      vim-vsnip
      vim-vsnip-integ

      # Text objects
      tcomment_vim    # vimscript
      vim-surround    # vimscript
      vim-repeat      # vimscript
      nvim-autopairs

      # Git
      vim-fugitive  # vimscript
      vim-gitgutter # vimscript

      # DAP
      vimspector # vimscript

      # Fuzzy Finder
	#      telescope-nvim
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
    enableFishIntegration = true;
  };
}