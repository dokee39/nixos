{ ... }:

{
  programs.tofi = {
    enable = true;
    settings = {
      font = "LXGW Bright";
      font-size = 14;

      text-color = "#C2FFDF";
      prompt-color = "#E6C000";
      input-color = "#FECD5E";
      default-result-background-padding = "4, 10";
      selection-color = "#000000";
      selection-background = "#C2FFFF";
      selection-background-padding = "3, 8";
      selection-background-corner-radius = 6;

      placeholder-text = "...";
      result-spacing = 8;

      width = 800;
      height = 360;
      background-color = "#1D19299F";
      outline-width = 0;
      border-width = 3;
      border-color = "#BBA0F0";
      corner-radius = 24;
      padding-top = 6;
      padding-bottom = 6;
      padding-left = 12;
      padding-right = 12;

      text-cursor = true;
    };
  };
}
