{ config, lib, pkgs, ... }:

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

    system = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
    };
    shellPkg = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
    };
    shellExe = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
    };
  };

  config.terra = {
    system = pkgs.stdenv.hostPlatform.system;
    shellPkg = config.users.users.${config.terra.userName}.shell or pkgs.bashInteractive;
    shellExe = lib.getExe config.terra.shellPkg;
  };
}
