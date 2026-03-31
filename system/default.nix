{ ... }:

{
  imports = [
    ./fonts.nix
    ./network.nix
    ./mihomo.nix
    ./desktop.nix
    ./user.nix
    ./hardware.nix
  ];

  system.stateVersion = "25.11";
  system.autoUpgrade = {
    enable = false;
    dates = "weekly";
  };

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org?priority=40"
      "https://mirrors.ustc.edu.cn/nix-channels/store?priority=30"
      "https://mirror.sjtu.edu.cn/nix-channels/store?priority=20"
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store?priority=10"
    ];
    max-jobs = "auto";
    cores = 0;
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_GB.UTF-8";
}

