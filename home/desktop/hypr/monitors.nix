{ lib, osConfig, ... }:

{
  wayland.windowManager.hyprland.settings = let
    monitors = osConfig.terra.desktop.monitors;
    primary = builtins.head (
      builtins.filter
        (name: monitors.${name}.primary)
        (builtins.attrNames monitors)
    );
  in {
    monitor = lib.mapAttrsToList
      (name: m: "${name},${m.resolution},${m.position},${toString m.scale},transform,${toString m.transform}")
      monitors;

    workspace = [
      "r[1-10], monitor:${primary}"
      "1, monitor:${primary}, default:true"
    ] ++ builtins.concatLists (
      lib.imap0 (i: name: [
        "r[${toString (((i + 1) * 10) + 1)}-${toString ((i + 2) * 10)}], monitor:${name}"
        "${toString (((i + 1) * 10) + 1)}, monitor:${name}, default:true"
      ]) (
        builtins.filter
          (name: !monitors.${name}.primary)
          (builtins.attrNames monitors)
      )
    );
  };
}
