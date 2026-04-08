{ config, lib, pkgs, ... }:

{
  xdg.configFile."ddcutil/ddcutilrc".text = ''
    [ddcutil]
    options: --syslog NEVER
  '';
  xdg.configFile."brightd/config.toml".text = ''
    [HDMI-A-1]
    device = "external"
    brightness.min = 0
    brightness.max = 100

    [DP-3]
    device = "external"
    brightness.min = 5
    brightness.max = 70
  '';

  systemd.user.services.brightd = {
    Unit = {
      Description = "brightd brightness worker";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };

    Service = {
      ExecStart = "${config.home.homeDirectory}/.scripts/brightd worker";
      Restart = "on-failure";
      RestartSec = 1;
      Environment = [
        "PATH=${lib.makeBinPath [
          pkgs.python3
          pkgs.brightnessctl
          pkgs.ddcutil
          pkgs.systemd
        ]}"
      ];
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };
}
