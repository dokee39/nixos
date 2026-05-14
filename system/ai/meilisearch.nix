{ config, lib, ... }:

let
  cfg = config.terra.ai.meilisearch;
in {
  options.terra.ai.meilisearch = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = config.services.librechat.enable;
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = 7700;
    };
    masterKey_secretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = ''
        Path to a secret file containing the meilisearch master key.
        > $ openssl rand -base64 36
        ```
          xxx
        ```
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    age.secrets.meilisearch-master-key.file = cfg.masterKey_secretFile;
    services.meilisearch = {
      enable = true;
      listenPort = cfg.port;
      masterKeyFile = config.age.secrets.meilisearch-master-key.path;
    };
  };
}
