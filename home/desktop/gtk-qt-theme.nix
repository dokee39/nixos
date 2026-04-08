{ inputs, pkgs, ... }:

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

    gtk4 = {
      theme = {
        package = pkgs.orchis-theme;
        name = "Orchis-Dark";
      };
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

    style.name = "kvantum";
  };

  xdg.configFile = {
    "Kvantum/OrchisDark/OrchisDark.kvconfig".source =
      "${inputs.orchis-kde}/Kvantum/Orchis/OrchisDark.kvconfig";
    "Kvantum/OrchisDark/OrchisDark.svg".source =
      "${inputs.orchis-kde}/Kvantum/Orchis/OrchisDark.svg";

    "Kvantum/kvantum.kvconfig".text = ''
      [General]
      theme=OrchisDark
    '';
  };
}
