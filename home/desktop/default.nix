{ pkgs, ... }:

{
  imports = [
    ./clipse.nix
    ./cursor.nix
    ./hypr
    ./fcitx5.nix
    ./fontconfig.nix
    ./mako.nix
    ./gtk-qt-theme.nix
    ./tofi.nix
    ./awww.nix
  ];

  home.packages = with pkgs; [
    nautilus
    brightnessctl
    pulsemixer
  ];
}
