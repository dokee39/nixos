{ pkgs, userName, ... }:

{
  users.users.${userName} = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "storage"
      "power"
      "audio"
      "video"
      "uucp"
      "input"
    ];
    shell = pkgs.fish;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOzGZRZ7Wysqq+OBEgSi6EGZ2ZXGtFeCHYBfMnKXp8PJ dokee@arch-2025-05-26"
    ];
  };

  programs.fish.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  services.fstrim.enable = true;
  services.smartd = {
    enable = true;
    notifications.systembus-notify.enable = true;
  };
  services.journald.extraConfig = ''
    SystemMaxUse=500M
    MaxRetentionSec=30day
  '';
  systemd.tmpfiles.rules = [
    "q /var/tmp - - - 30d"
    "e /var/cache - - - 30d"
  ];
  systemd.user.tmpfiles.rules = [
    "e %C - - - 30d"
  ];

  environment.wordlist.enable = true;
  environment.wordlist.lists.WORDLIST = [
    "${pkgs.scowl}/share/dict/words.txt"
    "${pkgs.scowl}/share/dict/words.variants.txt"
  ];

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
    tree
    vim
    scowl
    lm_sensors
    gnumake
    clang-tools
    gcc
    bear
  ];
}
