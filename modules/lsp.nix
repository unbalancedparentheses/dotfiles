# Shared LSP servers and development tools
{ pkgs }:

{
  servers = with pkgs; [
    lua-language-server
    nil # Nix
    rust-analyzer
    gopls
    pyright
    typescript-language-server
    nodePackages.vscode-langservers-extracted # HTML/CSS/JSON
    yaml-language-server
  ];

  tools = with pkgs; [
    ripgrep
    fd
    direnv
  ];
}
