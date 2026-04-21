{ pkgs, inputs, ... }:

let
  lib = inputs.nixpkgs.lib;
  cursorSize = 24;
  xcursorName = "BreezeX-RosePine-Linux";
  hyprcursorName = "rose-pine-hyprcursor";
in
{
  home.packages = with pkgs; [
    rose-pine-cursor
    rose-pine-hyprcursor
  ];

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;

    package = pkgs.rose-pine-cursor;
    name = xcursorName;
    size = cursorSize;

    hyprcursor.enable = false;
  };

  xdg.dataFile."icons/${hyprcursorName}".source =
    "${pkgs.rose-pine-hyprcursor}/share/icons/${hyprcursorName}";

  dconf.settings."org/gnome/desktop/interface" = {
    cursor-theme = xcursorName;
    cursor-size = cursorSize;
  };

  home.sessionVariables = {
    XCURSOR_THEME=xcursorName;
    XCURSOR_SIZE=toString cursorSize;
  };

  xdg.configFile."uwsm/env-hyprland".text = lib.mkAfter ''
    export HYPRCURSOR_THEME=${hyprcursorName}
    export HYPRCURSOR_SIZE=${toString cursorSize}
  '';
}
