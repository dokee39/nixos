{ config, pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  terra = {
    userName = "user_name";
    authorizedSshKeys = [ ];
    nix.githubPatSecretFile = ./path/to/secret/file.age;
    codex.githubPatSecretFile = ./path/to/secret/file.age;
    mihomo.subscriptionUrlSecretFile = ./path/to/secret/file.age;

    transmission = {
      enable = false;
      speed = {
        up = 200;
        down = 2000;
      };
      alt-speed = {
        up = 2000;
        down = 10000;
      };
      rpcSecretFile = ./path/to/secret/file.age;
    };

    desktop = {
      enable = false;
      monitors.DP-1 = {
        primary = true;
        resolution =  "highres@highrr";
        position = "auto";
        scale = 1;
        transform = 0;
        brightd = {
          device = "external";
          brightness.min = 5;
          brightness.max = 70;
        };
      };
      wechat.scale = 1;
    };

    gpu = {
      intelIgpu.enable = false;
      nvidia = {
        enable = false;
        prime = {
          intelBusId = null;
          nvidiaBusId = null;
        };
      };
    };
  };

  # optional
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.loader.timeout = 1;

  system.autoUpgrade = {
    enable = false;
    flake = "github:yourname/your-config#${config.terra.hostName}";
    operation = "boot";
    dates = "Sun 12:30";
  };

  networking = {
    proxy = {
      default = "http://localhost:7890";
      noProxy = "localhost";
    };
  };

  programs.coolercontrol.enable = false;
  services.lact.enable = false;
}
