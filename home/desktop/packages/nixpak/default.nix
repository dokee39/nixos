{ pkgs, inputs, osConfig, ... }:

let
  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit (pkgs) lib;
    pkgs = pkgs;
  };

  desktopContext = {
    nvidiaEnabled = osConfig.terra._internal.gpu.nvidiaEnabled;
    wechatScaleFactor = osConfig.terra.desktop.wechat.scale;
  };
in
{
  qq = pkgs.callPackage ./qq.nix {
    inherit mkNixPak desktopContext;
  };

  wechat = pkgs.callPackage ./wechat.nix {
    inherit mkNixPak desktopContext;
  };
}
