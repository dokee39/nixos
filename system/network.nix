{ config, lib, ... }:

{
  networking = {
    hostName = config.profile.hostName;
    useDHCP = false;
    wireless.iwd = {
      enable = true;
      settings.Settings.AutoConnect = true;
    };
    proxy = {
      default = lib.mkDefault "http://localhost:7890";
      noProxy = lib.mkDefault "localhost";
    };
  };

  systemd.network.enable = true;
  services.resolved.enable = true;
  systemd.network.networks."20-wired" = {
    matchConfig.Name = "en*";
    networkConfig.DHCP = "yes";
  };
  systemd.network.networks."30-wireless" = {
    matchConfig.Name = "wl*";
    networkConfig.DHCP = "yes";
  };

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };
}
