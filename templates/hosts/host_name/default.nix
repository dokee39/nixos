{ config, ... }:

{
  imports = [ ./hardware.nix ];

  profile = {
    userName = "user_name";
    codex.githubPatFile = ./path/to/secret/file.age;
    mihomo.subscriptionUrlFile = ./path/to/secret/file.age;
    authorizedSshKeys = [ ];

    desktop.enable = false;

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
  system.autoUpgrade = {
    enable = false;
    flake = "github:yourname/your-config#${config.profile.hostName}";
    operation = "boot";
    dates = "Sun 12:30";
  };

  boot.loader.timeout = 1;

  networking = {
    proxy = {
      default = "http://localhost:7890";
      noProxy = "localhost";
    };
  };
}
