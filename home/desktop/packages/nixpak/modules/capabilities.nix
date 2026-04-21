{ config, lib, sloth, ... }:

let
  cfg = config.sandbox.capabilities;
  types = lib.types;
  inherit (config.flatpak) appId;
  appShortName = lib.lists.last (lib.strings.splitString "." appId);
  trayFallbackIds = lib.lists.range 2 63;
  accessType = types.nullOr (types.enum [ "ro" "rw" ]);
in
{
  options.sandbox.capabilities = {
    network.enable = lib.mkEnableOption "network access";

    tray.enable = lib.mkEnableOption "tray integration";
    mpris.enable = lib.mkEnableOption "MPRIS integration";
    gvfsSocket.enable = lib.mkEnableOption "gvfs daemon socket access";
    gvfsMounts.enable = lib.mkEnableOption "gvfs mount access";
    systemBus.enable = lib.mkEnableOption "system D-Bus access";

    audio.enable = lib.mkEnableOption "audio playback/recording";
    camera.enable = lib.mkEnableOption "direct camera device access";
    screencast.enable = lib.mkEnableOption "Wayland screencast support";
    screenshot.enable = lib.mkEnableOption "screenshot portal";
    print.enable = lib.mkEnableOption "print portal";
    secret.enable = lib.mkEnableOption "secret portal";
    inhibit.enable = lib.mkEnableOption "inhibit portal";

    downloads = lib.mkOption {
      type = accessType;
      default = null;
      description = "access mode for Downloads";
    };
    pictures = lib.mkOption {
      type = accessType;
      default = null;
      description = "access mode for Pictures";
    };
    videos = lib.mkOption {
      type = accessType;
      default = null;
      description = "access mode for Videos";
    };
    music = lib.mkOption {
      type = accessType;
      default = null;
      description = "access mode for Music";
    };
    documents = lib.mkOption {
      type = accessType;
      default = null;
      description = "access mode for Documents";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.network.enable {
      etc.sslCertificates.enable = true;
      bubblewrap.network = true;
    })

    (lib.mkIf cfg.tray.enable {
      dbus.policies =
        {
          "org.kde.StatusNotifierItem" = "own";
          "org.kde.StatusNotifierItem.*" = "own";
          "org.freedesktop.StatusNotifierItem" = "own";
          "org.freedesktop.StatusNotifierItem.*" = "own";
        }
        // (builtins.listToAttrs (
          map
            (id: lib.nameValuePair "org.kde.StatusNotifierItem-${toString id}-1" "own")
            trayFallbackIds
        ))
        // {
          "org.kde.StatusNotifierWatcher" = "talk";
          "org.freedesktop.StatusNotifierWatcher" = "talk";
        };
    })

    (lib.mkIf cfg.mpris.enable {
      dbus.policies = {
        "org.mpris.MediaPlayer2.${appId}" = "own";
        "org.mpris.MediaPlayer2.${appId}.*" = "own";
        "org.mpris.MediaPlayer2.${appShortName}" = "own";
        "org.mpris.MediaPlayer2.${appShortName}.*" = "own";
      };
    })

    (lib.mkIf cfg.systemBus.enable {
      bubblewrap = {
        bind.ro = [
          "/run/dbus/system_bus_socket"
        ];

        env = {
          DBUS_SYSTEM_BUS_ADDRESS = "unix:path=/run/dbus/system_bus_socket";
        };
      };
    })

    (lib.mkIf cfg.gvfsSocket.enable {
      bubblewrap.bind.rw = [
        (sloth.concat' sloth.runtimeDir "/gvfsd")
      ];
    })

    (lib.mkIf cfg.gvfsMounts.enable {
      bubblewrap.bind.rw = [
        (sloth.concat' sloth.runtimeDir "/gvfs")
      ];
    })

    (lib.mkIf cfg.audio.enable {
      bubblewrap = {
        sockets = {
          pulse = true;
        };

        env = {
          PULSE_SERVER = sloth.concat [ "unix:" sloth.runtimeDir "/pulse/native" ];
          PULSE_RUNTIME_PATH = sloth.concat' sloth.xdgCacheHome "/pulse";
        };
      };
    })

    (lib.mkIf cfg.camera.enable {
      bubblewrap.bind.dev =
        map (id: "/dev/video${toString id}") (lib.lists.range 0 9);
    })

    (lib.mkIf cfg.screencast.enable {
      bubblewrap.sockets.pipewire = true;
      dbus.rules.call."org.freedesktop.portal.Desktop" = [
        "org.freedesktop.portal.ScreenCast"
        "org.freedesktop.portal.ScreenCast.*"
      ];
    })

    (lib.mkIf cfg.screenshot.enable {
      dbus.rules.call."org.freedesktop.portal.Desktop" = [
        "org.freedesktop.portal.Screenshot"
        "org.freedesktop.portal.Screenshot.Screenshot"
      ];
    })

    (lib.mkIf cfg.print.enable {
      dbus.policies = {
        "org.freedesktop.portal.Print" = "talk";
      };
      dbus.rules.call = {
        "org.freedesktop.portal.Print" = [ "*" ];
        "org.freedesktop.portal.Desktop" = [
          "org.freedesktop.portal.Print"
          "org.freedesktop.portal.Print.*"
        ];
      };
    })

    (lib.mkIf cfg.secret.enable {
      dbus.policies = {
        "org.freedesktop.portal.Secret" = "talk";
      };
      dbus.rules.call."org.freedesktop.portal.Desktop" = [
        "org.freedesktop.portal.Secret"
        "org.freedesktop.portal.Secret.RetrieveSecret"
      ];
    })

    (lib.mkIf cfg.inhibit.enable {
      dbus.rules.call."org.freedesktop.portal.Desktop" = [
        "org.freedesktop.portal.Inhibit"
        "org.freedesktop.portal.Inhibit.*"
      ];
    })

    {
      bubblewrap = {
        bind.ro =
          lib.optionals (cfg.downloads == "ro") [ sloth.xdgDownloadDir ]
          ++ lib.optionals (cfg.pictures == "ro") [ sloth.xdgPicturesDir ]
          ++ lib.optionals (cfg.videos == "ro") [ sloth.xdgVideosDir ]
          ++ lib.optionals (cfg.music == "ro") [ sloth.xdgMusicDir ]
          ++ lib.optionals (cfg.documents == "ro") [ sloth.xdgDocumentsDir ];

        bind.rw =
          lib.optionals (cfg.downloads == "rw") [ sloth.xdgDownloadDir ]
          ++ lib.optionals (cfg.pictures == "rw") [ sloth.xdgPicturesDir ]
          ++ lib.optionals (cfg.videos == "rw") [ sloth.xdgVideosDir ]
          ++ lib.optionals (cfg.music == "rw") [ sloth.xdgMusicDir ]
          ++ lib.optionals (cfg.documents == "rw") [ sloth.xdgDocumentsDir ];
      };
    }
  ];
}
