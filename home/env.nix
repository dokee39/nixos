{ config, lib, osConfig, ... }:

{
  home.file.".local/bin" = {
    source = ./scripts;
    recursive = true;
  };

  home.sessionVariables = {
    NIXPKGS_ALLOW_UNFREE = "1";

    PAGER = "less";
    EDITOR = "nvim";
    VISUAL = "nvim";

    RANGER_LOAD_DEFAULT_RC = "FALSE";

    SCONSFLAGS = "-j8";
    MAKEFLAGS = "-j";
  } // lib.optionalAttrs (osConfig.terra.desktop.enable && osConfig.terra._internal.gpu.nvidiaEnabled) {
    # NVIDIA
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    GBM_BACKEND = "nvidia-drm";
    LIBVA_DRIVER_NAME = "nvidia";
    NVD_BACKEND = "direct";
  } // lib.optionalAttrs osConfig.terra.desktop.enable {
    # toolkit
    GDK_BACKEND = "wayland,x11,*";
    SDL_VIDEODRIVER = "wayland,x11";
    CLUTTER_BACKEND = "wayland";

    # NixOS Electron/Chromium
    NIXOS_OZONE_WL = "1";
  };

  xdg.configFile = lib.mkIf osConfig.terra.desktop.enable {
    "uwsm/env".source =
      "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
  };
}
