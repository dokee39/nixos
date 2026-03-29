{ ... }:

{
  wayland.windowManager.hyprland.settings = {
    monitor = [
      "HDMI-A-1,highres@highrr,auto,2"
      "DP-1,highres@highrr,auto-left,1.33,transform,1"
    ];

    workspace = [
      "r[1-10], monitor:0"
      "r[11-20], monitor:1"
      "1, monitor:HDMI-A-1, default:true"
      "11, monitor:DP-1, default:true"
    ];
  };
}
