{ lib, ... }:

{
  options.terra = {
    userName = lib.mkOption {
      type = lib.types.str;
      description = "User name";
    };

    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Host name";
    };

    authorizedSshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH public keys authorized for the primary user.";
    };

    nix.githubPatSecretFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a secret file containing the GitHub PAT for nix.";
    };

    codex.githubPatSecretFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a secret file containing the GitHub PAT for codex.";
    };
  };
}
