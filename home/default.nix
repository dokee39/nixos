{ pkgs, osConfig, ... }:

{
  imports = [
    ./desktop
    ./git.nix
    ./fish.nix
    ./kitty.nix
    ./env.nix
    ./programs.nix
    ./btop.nix
    ./codex.nix
    ./yazi.nix
    ./nvim
    ./ags
  ];

  home.username = osConfig.profile.userName;
  home.homeDirectory = "/home/${osConfig.profile.userName}";

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
    p7zip
    _7zz-rar
    unar

    ripgrep
    jq
    fzf
    fd

    eza
    bat
    hexyl
    glow

    nix-output-monitor

    rmpc
    ffmpeg

    python3
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
