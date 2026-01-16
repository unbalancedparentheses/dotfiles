# Shared LSP servers and development tools
{ pkgs }:

{
  servers = with pkgs; [
    # Core
    lua-language-server
    nil                    # Nix
    yaml-language-server
    nodePackages.vscode-langservers-extracted  # HTML/CSS/JSON

    # Systems
    rust-analyzer
    zls                    # Zig

    # Backend
    gopls
    erlang-ls
    elixir-ls
    # gleam has built-in LSP (gleam lsp)

    # Scripting
    pyright

    # Frontend
    typescript-language-server
  ];

  tools = with pkgs; [
    ripgrep
    fd
    direnv
  ];
}
