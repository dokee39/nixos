{ config, ... }:

{

  home.sessionVariables = {
    # NVIDIA
    __GLX_VENDOR_LIBRARY_NAME="nvidia";
    GBM_BACKEND="nvidia-drm";
    LIBVA_DRIVER_NAME="nvidia";
    NVD_BACKEND="direct";
    
    # toolkit
    GDK_BACKEND="wayland,x11,*";
    SDL_VIDEODRIVER="wayland,x11";
    CLUTTER_BACKEND="wayland";
    
    # NixOS Electron/Chromium
    NIXOS_OZONE_WL="1";
  };

  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
}
