{ config, pkgs, lib, ... }:

{
  options.terra.desktop = {
    enable = lib.mkEnableOption "desktop environment";

    monitors = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          primary = lib.mkEnableOption "primary monitor";

          resolution = lib.mkOption {
            type = lib.types.str;
            default = "highres@highrr";
            description = "Monitor resolution and refresh rate.";
          };

          position = lib.mkOption {
            type = lib.types.str;
            default = "auto";
            description = "Monitor position.";
          };

          scale = lib.mkOption {
            type = lib.types.number;
            default = 1;
            description = "Monitor scale factor.";
          };

          transform = lib.mkOption {
            type = lib.types.int;
            default = 0;
            description = "Monitor rotation transform.";
          };

          brightd.device = lib.mkOption {
            type = lib.types.str;
            default = "external";
            description = "Backlight device name, or external for external monitors.";
          };

          brightd.brightness.min = lib.mkOption {
            type = lib.types.int;
            default = 0;
            description = "Minimum brightness.";
          };

          brightd.brightness.max = lib.mkOption {
            type = lib.types.int;
            default = 100;
            description = "Maximum brightness.";
          };
        };
      });
      default = { };
      description = "Monitor settings keyed by connector name.";
    };

    wechat.scale = lib.mkOption {
      type = lib.types.nullOr lib.types.number;
      default = null;
      description = "Qt scale factor for WeChat.";
    };

    _internal.primaryName = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      readOnly = true;
      internal = true;
    };

    _internal.primary = lib.mkOption {
      type = lib.types.nullOr lib.types.attrs;
      readOnly = true;
      internal = true;
    };
  };

  config = lib.mkMerge [
    {
      terra.desktop._internal.primaryName = lib.findFirst
        (name: config.terra.desktop.monitors.${name}.primary)
        null
        (builtins.attrNames config.terra.desktop.monitors);

      terra.desktop._internal.primary =
        let
          primaryName = config.terra.desktop._internal.primaryName;
        in
        if primaryName == null then null else config.terra.desktop.monitors.${primaryName};

      terra.desktop.wechat.scale = lib.mkDefault (
        if config.terra.desktop._internal.primary == null then
          null
        else
          config.terra.desktop._internal.primary.scale
      );

      assertions = [
        {
          assertion =
            (!config.terra.desktop.enable)
            || (
              builtins.length (
                builtins.filter
                  (name: config.terra.desktop.monitors.${name}.primary)
                  (builtins.attrNames config.terra.desktop.monitors)
              ) == 1
            );
          message = "terra.desktop.monitors must have exactly one primary monitor";
        }
      ];
    }

    (lib.mkIf config.terra.desktop.enable {
      programs.hyprland.enable = true;
      programs.hyprland.withUWSM = true;

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
      };

      services.pipewire = {
        enable = true;
        alsa.enable = true;
        alsa.support32Bit = true;
        pulse.enable = true;
        wireplumber.enable = true;
      };

      programs.dconf.enable = true;
      security.rtkit.enable = true;
    })
  ];
}
