{ pkgs, lib, sloth, ... }:

let
  xdg-open-wrapper = pkgs.writeShellApplication {
    name = "xdg-open";
    text = ''
      exec ${pkgs.flatpak-xdg-utils}/bin/xdg-open "$@"
    '';
  };
in {
  config = {
    fonts.enable = false;
    locale.enable = true;

    bubblewrap = {
      env = {
        PATH = lib.mkDefault (
          lib.makeBinPath [
            pkgs.coreutils
            xdg-open-wrapper
          ]
        );

        # Prevent host-level NixOS portal forcing from selecting the broken
        # xdg-utils flatpak branch in nested FHS runtimes.
        NIXOS_XDG_OPEN_USE_PORTAL = lib.mkDefault "";
      };

      bind.ro = [
        "/etc/passwd"
        "/etc/group"
        "/etc/nsswitch.conf"
        "/etc/host.conf"
      ];

      bind.rw = with sloth; [
        [ (mkdir appDataDir) xdgDataHome ]
        [ (mkdir appConfigDir) xdgConfigHome ]
        [ (mkdir appCacheDir) xdgCacheHome ]

        (sloth.concat' xdgCacheHome "/fontconfig")
        (sloth.concat' xdgCacheHome "/mesa_shader_cache")
        (sloth.concat' xdgCacheHome "/mesa_shader_cache_db")
        (sloth.concat' xdgCacheHome "/radv_builtin_shaders")
      ];

      bind.dev = [ "/dev/shm" ];
    };
  };
}
