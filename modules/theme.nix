# Shared theme configuration - Tokyo Night
# https://github.com/enkia/tokyo-night-vscode-theme
{
  # Tokyo Night color palette
  colors = {
    # Background shades
    bg = "#1a1b26";        # main background
    bgDark = "#16161e";    # darker background
    bgHighlight = "#292e42"; # selection/highlight
    bgAlt = "#24283b";     # elevated surfaces

    # Foreground shades
    fg = "#c0caf5";        # main foreground
    fgDark = "#a9b1d6";    # dimmed foreground
    fgGutter = "#3b4261";  # line numbers, subtle

    # Terminal colors
    black = "#15161e";
    red = "#f7768e";
    green = "#9ece6a";
    yellow = "#e0af68";
    blue = "#7aa2f7";
    magenta = "#bb9af7";
    cyan = "#7dcfff";
    white = "#a9b1d6";

    # Bright variants
    brightBlack = "#414868";
    brightRed = "#f7768e";
    brightGreen = "#9ece6a";
    brightYellow = "#e0af68";
    brightBlue = "#7aa2f7";
    brightMagenta = "#bb9af7";
    brightCyan = "#7dcfff";
    brightWhite = "#c0caf5";

    # Accents
    orange = "#ff9e64";
    pink = "#ff007c";
    teal = "#1abc9c";
    purple = "#9d7cd8";
  };

  # Semantic aliases
  background = "#1a1b26";
  backgroundAlt = "#24283b";
  foreground = "#c0caf5";
  foregroundBright = "#c0caf5";
  accent = "#7dcfff";
  border = "#3b4261";
  error = "#f7768e";
  warning = "#ff9e64";
  success = "#9ece6a";

  # Font
  font = {
    family = "JetBrainsMono Nerd Font";
    mono = "JetBrainsMono Nerd Font";
    size = 11;
    sizeSmall = 10;
  };

  # Bar colors (for SketchyBar/slstatus)
  bar = {
    background = "0xff1a1b26";
    foreground = "0xffc0caf5";
    accent = "0xff7dcfff";
    item = "0xff24283b";
  };
}
