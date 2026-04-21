{ pkgs, lib, osConfig, ... }:

{
  imports = [
    ./fish.nix
    ./kitty.nix
    ./env.nix
    ./btop.nix
    ./codex.nix
    ./yazi
    ./nvim
  ] ++ lib.optionals osConfig.terra.desktop.enable [
    ./desktop
  ];

  home.stateVersion = "25.11";

  home.username = osConfig.terra.userName;
  home.homeDirectory = "/home/${osConfig.terra.userName}";

  xdg.enable = true;
  xdg.localBinInPath = true;
  home.preferXdgDirectories = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "*" = {
        addKeysToAgent = "yes";
        hashKnownHosts = true;
      };
    };
  };

  programs.git = {
    enable = true;
    settings = {
      user.name = "dokee";
      user.email = "dokee.39@gmail.com";
      init.defaultBranch = "main";
    };
  };

  services.udiskie.enable = true;

  home.packages = with pkgs; [
    fzf
    eza

    bat
    hexyl
    glow

    nix-output-monitor

    rmpc

    tldr
  ];
}
