{ config, pkgs, lib, ... }:

let
  cfg = config.terra.ai.mongodb;
in {
  options.terra.ai.mongodb = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.services.librechat.enable;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 27017;
    };
  };

  config = lib.mkIf cfg.enable {
    services.mongodb = {
      enable = true;
      package = pkgs.mongodb-ce;
      extraConfig = ''
        net:
          port: ${toString cfg.port}
      '';
    };
  };
}
