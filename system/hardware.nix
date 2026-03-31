{ config, pkgs, ... }:

{
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelModules = [
    "nct6687"
  ];
  boot.extraModulePackages = with config.boot.kernelPackages; [
    nct6687d
  ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };

  boot.tmp.useTmpfs = false;
  boot.tmp.cleanOnBoot = true; 

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
}
