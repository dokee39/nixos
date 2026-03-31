{ pkgs, userName, ... }:

{

  imports = [
    ./desktop
    ./git.nix
    ./fish.nix
    ./kitty.nix
    ./env.nix
    ./programs.nix
    ./btop.nix
    ./nvim
    ./ags
  ];

  home.username = userName;
  home.homeDirectory = "/home/${userName}";

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

  home.packages = with pkgs;[
    ranger

    zip
    xz
    unzip
    p7zip

    ripgrep
    jq
    eza
    fzf

    nix-output-monitor

    glow

    rmpc
  ];

  home.file.".scripts" = {
    source = ./scripts;
    recursive = true;
  };
  home.sessionPath = [
    "$HOME/.scripts"
  ];

  home.sessionVariables = {
    PAGER = "less";
    EDITOR = "nvim";
    VISUAL = "nvim";

    RANGER_LOAD_DEFAULT_RC = "FALSE";

    SCONSFLAGS = "-j8";
    MAKEFLAGS = "-j";
  };

  home.stateVersion = "25.11";
}
