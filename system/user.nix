{ config, pkgs, ... }:

{
  users.users.${config.profile.userName} = {
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
    openssh.authorizedKeys.keys = config.profile.authorizedSshKeys;
  };

  programs.fish.enable = true;

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    tree
    vim
    scowl
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
