{ config, pkgs, userName, ... }:

{

  imports = [
    ./fonts.nix
    ./network.nix
    ./mihomo.nix
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.11";
  system.autoUpgrade = { 
    enable = false;
    dates = "weekly";
  };

  # Nix / flakes
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

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [
    "nct6687"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    nct6687d
  ];

  # Bootloader: UEFI + GRUB
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };
  boot.loader.timeout = 1;

  # SSH
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.fstrim.enable = true;
  services.smartd = {
    enable = true;
    notifications.systembus-notify.enable = true;
  };
  boot.tmp.useTmpfs = false;
  boot.tmp.cleanOnBoot = true; 
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=30day
  '';
  systemd.tmpfiles.rules = [
    "q /var/tmp - - - 30d"
    "e /var/cache - - - 30d"
  ];
  systemd.user.tmpfiles.rules = [
    "e %C - - - 30d"
  ];

  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "storage"
      "power"
      "audio"
      "video"
      "uucp"
      "input"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzGZRZ7Wysqq+OBEgSi6EGZ2ZXGtFeCHYBfMnKXp8PJ dokee@arch-2025-05-26"
    ];
  };

  programs.fish.enable = true;

  programs.hyprland.enable = true;
  programs.hyprland.withUWSM = true;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      libva-utils
    ];
  };
  hardware.nvidia.open = true;
  hardware.nvidia.powerManagement.enable = true;
  services.xserver.videoDrivers = [ "nvidia" ];

  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
  environment.wordlist.enable = true;
  environment.wordlist.lists.WORDLIST = [
    "${pkgs.scowl}/share/dict/words.txt"
    "${pkgs.scowl}/share/dict/words.variants.txt"
  ];

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    tree
    vim
    scowl
    lm_sensors
  gnumake
  clang-tools
  gcc
  bear
  ];

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_GB.UTF-8";
}

