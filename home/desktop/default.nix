{ pkgs, inputs, osConfig, ... }:

let
  customPackages = import ./packages {
    inherit pkgs inputs osConfig;
  };
in

{
  _module.args = {
    inherit customPackages;
  };

  imports = [
    ./hypr
    ./ags
    ./cursor.nix
    ./clipse.nix
    ./fcitx5.nix
    ./fontconfig.nix
    ./mako.nix
    ./gtk-qt-theme.nix
    ./tofi.nix
    ./awww.nix
    ./brightd.nix
    ./polkit.nix
    ./nautilus.nix
    ./downloads-sorter.nix
    ./imv.nix
    ./mpv.nix
    ./mime.nix
  ];

  home.packages =
    (with pkgs; [
      ddcutil
      brightnessctl
      pulsemixer
      hyprpicker

      google-chrome
      osu-lazer
    ])
    ++ [
      customPackages.mikan
      customPackages.qq
      customPackages.wechat
    ];
}
