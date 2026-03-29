{ pkgs, ... }:

{
  programs.btop = {
    enable = true;
    package = pkgs.btop-cuda;

    settings = {
      color_theme = "${pkgs.btop-cuda}/share/btop/themes/horizon.theme";
      theme_background = false;
      vim_keys = true;
      shown_boxes = "mem cpu net proc gpu0";
      update_ms = 200;
      proc_sorting = "cpu direct";
      net_auto = false;
    };
  };
}
