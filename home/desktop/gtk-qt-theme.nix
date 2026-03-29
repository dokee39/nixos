{ lib, pkgs, ... }:

{
  gtk = {
    enable = true;

    theme = {
      package = pkgs.orchis-theme;
      name = "Orchis-Dark";
    };

    iconTheme = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "Orchis-Dark";
    icon-theme = "Adwaita";
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";

    style.name = lib.mkForce null;
    style.package = lib.mkForce null;
    qt5ctSettings = lib.mkForce null;
    qt6ctSettings = lib.mkForce null;
  };
}
