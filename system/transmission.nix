{ lib, config, pkgs, ... }:

{
  options.terra.transmission = {
    enable = lib.mkEnableOption "Transmission";

    speed = {
      up = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 200;
        description = "Normal upload speed in kB/s.";
      };

      down = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 2000;
        description = "Normal download speed in kB/s.";
      };
    };

    alt-speed = {
      up = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 2000;
        description = "Alternative upload speed in kB/s.";
      };

      down = lib.mkOption {
        type = lib.types.ints.unsigned;
        default = 10000;
        description = "Alternative download speed in kB/s.";
      };
    };

    rpcSecretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to a secret file containing `transmission-rpc.json`.";
    };
  };

  config =
    let
      cfg = config.terra.transmission;
      userName = config.terra.userName;
    in
    lib.mkMerge [
      (lib.mkIf cfg.enable {
        users.users.${userName}.extraGroups = [ "transmission" ];
        systemd.tmpfiles.rules = [
          "L+ /home/${userName}/Downloads/transmission - - - - ${config.services.transmission.settings.download-dir}"
          "L+ /home/${userName}/Downloads/torrents - - - - ${config.services.transmission.settings.watch-dir}"
        ];
        systemd.services.transmission.serviceConfig.StateDirectoryMode = "770";
      })

      (lib.mkIf (cfg.enable && cfg.rpcSecretFile != null) {
        age.secrets.transmission-rpc.file = config.terra.transmission.rpcSecretFile;
      })

      {
        services.transmission = {
          enable = cfg.enable;
          webHome = pkgs.flood-for-transmission;
          openPeerPorts = true;
          openRPCPort = true;
          downloadDirPermissions = "770";

          settings = {
            rpc-bind-address = "0.0.0.0";
            rpc-whitelist = "127.0.0.1,192.168.*.*";
            umask = "002";

            watch-dir-enabled = true;
            trash-original-torrent-files = true;

            speed-limit-up = cfg.speed.up;
            speed-limit-up-enabled = true;
            speed-limit-down = cfg.speed.down;
            speed-limit-down-enabled = true;

            alt-speed-up = cfg.alt-speed.up;
            alt-speed-down = cfg.alt-speed.down;
            alt-speed-enabled = false;

            rpc-authentication-required = cfg.rpcSecretFile != null;
          };
        } // lib.optionalAttrs (cfg.enable && cfg.rpcSecretFile != null) {
          credentialsFile = config.age.secrets.transmission-rpc.path;
        };
      }
    ];
}
