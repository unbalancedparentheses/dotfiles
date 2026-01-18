# Git configuration
{ config, pkgs, lib, gitName, gitEmail, ... }:

{
  programs.git = {
    enable = true;
    signing = {
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };
    settings = {
      user.name = gitName;
      user.email = gitEmail;
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      gpg.format = "ssh";
    };
  };

  programs.delta = {
    enable = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "TwoDark";  # Closest to Tokyo Night
    };
  };
}
