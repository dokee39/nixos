{ config, pkgs, lib, ... }:

{
  imports = [
    ./fonts.nix
    ./network.nix
    ./mihomo.nix
    ./desktop.nix
    ./user.nix
    ./maintenance.nix
    ./gpu.nix
    ./ram.nix
    ./steam.nix
    ./transmission.nix
  ];

  system.stateVersion = "25.11";

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [
      "https://cache.nixos.org?priority=10"
    ];
    auto-optimise-store = true;
    use-xdg-base-directories = true;
  };

  time.timeZone = "Asia/Shanghai";
  i18n.defaultLocale = "en_GB.UTF-8";

  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = lib.mkDefault 1;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
  };

  age.secrets.nix-github-pat.file = config.terra.nix.githubPatSecretFile;
  nix.extraOptions = ''
    !include /run/nix/access-tokens.conf
  '';
  system.activationScripts.nixAccessTokens = {
    deps = [ "agenix" ];
    text = ''
      install -d -m 0755 /run/nix
      umask 177
      token="$(tr -d '\r\n' < ${config.age.secrets.nix-github-pat.path})"
      printf 'access-tokens = github.com=%s\n' "$token" > /run/nix/access-tokens.conf
    '';
  };
}
