{ config, lib, pkgs, ... }:

{
  environment.systemPackages = [ pkgs.impala ];

  networking = {
    hostName = config.terra.hostName;
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

  systemd.network = {
    enable = true;
    wait-online.enable = false;
  };
  services.resolved.enable = true;
  systemd.network.networks."20-wired" = {
    matchConfig.Name = "en*";
    networkConfig.DHCP = "yes";
    dhcpV4Config.RouteMetric = 100;
    ipv6AcceptRAConfig.RouteMetric = 100;
  };
  systemd.network.networks."30-wireless" = {
    matchConfig.Name = "wl*";
    networkConfig.DHCP = "yes";
    dhcpV4Config.RouteMetric = 600;
    ipv6AcceptRAConfig.RouteMetric = 600;
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
