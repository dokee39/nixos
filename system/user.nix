{ config, pkgs, inputs, ... }:

{
  users.users.${config.terra.userName} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "storage"
      "power"
      "audio"
      "video"
      "uucp"
      "input"
      "i2c"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = config.terra.authorizedSshKeys;
  };

  programs.fish.enable = true;
  programs.nix-ld.enable = true;

  hardware.enableRedistributableFirmware = true;
  hardware.i2c.enable = true;

  hardware.bluetooth.enable = true;
  hardware.xpadneo = {
    enable = true;
    settings.disabled_deadzones = 1;
  };
  hardware.bluetooth.settings = {
    LE = {
      MinConnectionInterval = 7;
      MaxConnectionInterval = 9;
      ConnectionLatency = 0;
    };
  };

  services.gvfs.enable = true;
  services.udisks2 = {
    enable = true;
    settings."mount_options.conf" = {
      defaults = {
        "ntfs:ntfs3_defaults" =
          "uid=$UID,gid=$GID,fmask=0133,dmask=0022,windows_names,prealloc,force";
        "ntfs:ntfs3_allow" =
          "uid=$UID,gid=$GID,umask,dmask,fmask,iocharset,discard,nodiscard,sparse,nosparse,hidden,nohidden,sys_immutable,nosys_immutable,showmeta,noshowmeta,prealloc,noprealloc,hide_dot_files,nohide_dot_files,windows_names,nocase,case,force";
        ntfs_drivers = "ntfs3";
      };
    };
  };

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget

    tree
    vim

    scowl

    bluetui

    p7zip
    _7zz-rar
    unar
    atool

    ffmpeg

    python3

    ripgrep
    jq
    fd
  ] ++ [
    inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien
  ];

  environment.wordlist.enable = true;
  environment.etc."codex/config.toml".text = ''
    [tui]
    status_line = ["model-with-reasoning", "context-remaining", "current-dir", "five-hour-limit", "weekly-limit"]

    [mcp_servers.github]
    url = "https://api.githubcopilot.com/mcp"
    bearer_token_env_var = "GITHUB_PAT_TOKEN"
  '';
}
