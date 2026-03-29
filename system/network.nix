{ ... }:

{
  networking = {
    useDHCP = false;
    wireless.iwd = {
      enable = true;
      settings.Settings.AutoConnect = true;
    };
    proxy = {
      default = "http://localhost:7890";
      noProxy = "localhost";
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
}
