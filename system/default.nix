{ pkgs, lib, ... }:

{
  imports = [
    ./fonts.nix
    ./network.nix
    ./mihomo.nix
    ./desktop.nix
    ./user.nix
    ./maintenance.nix
    ./gpu.nix
  ];

  system.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org?priority=10"
      "https://mirrors.ustc.edu.cn/nix-channels/store?priority=20"
      "https://mirror.sjtu.edu.cn/nix-channels/store?priority=30"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=40"
    ];
    auto-optimise-store = true;
  };

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_GB.UTF-8";

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = lib.mkDefault 1;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };

  boot.tmp.useTmpfs = false;
  boot.tmp.cleanOnBoot = true;

  hardware.i2c.enable = true;
}
