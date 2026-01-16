# Shared theme configuration - Nord
# https://www.nordtheme.com/
{
  # Nord color palette
  colors = {
    # Polar Night (dark)
    nord0 = "#2e3440";  # background
    nord1 = "#3b4252";  # elevated background
    nord2 = "#434c5e";  # selection
    nord3 = "#4c566a";  # comments, subtle

    # Snow Storm (light)
    nord4 = "#d8dee9";  # foreground
    nord5 = "#e5e9f0";  # light foreground
    nord6 = "#eceff4";  # bright foreground

    # Frost (accent blues)
    nord7 = "#8fbcbb";  # teal
    nord8 = "#88c0d0";  # cyan (primary accent)
    nord9 = "#81a1c1";  # blue
    nord10 = "#5e81ac"; # deep blue

    # Aurora (semantic)
    nord11 = "#bf616a"; # red (error)
    nord12 = "#d08770"; # orange (warning)
    nord13 = "#ebcb8b"; # yellow (caution)
    nord14 = "#a3be8c"; # green (success)
    nord15 = "#b48ead"; # purple (special)
  };

  # Semantic aliases
  background = "#2e3440";
  backgroundAlt = "#3b4252";
  foreground = "#d8dee9";
  foregroundBright = "#eceff4";
  accent = "#88c0d0";
  border = "#4c566a";
  error = "#bf616a";
  warning = "#d08770";
  success = "#a3be8c";

  # Font
  font = {
    family = "JetBrainsMono Nerd Font";
    mono = "JetBrainsMono Nerd Font";
    size = 11;
    sizeSmall = 10;
  };

  # Bar colors (for SketchyBar/slstatus)
  bar = {
    background = "0xff2e3440";
    foreground = "0xffd8dee9";
    accent = "0xff88c0d0";
    item = "0xff3b4252";
  };
}
