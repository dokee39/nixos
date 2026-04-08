{ lib, config, ... }:

let
  gpu = config.profile._internal.gpu;
in {
  config = lib.mkMerge [
    (lib.mkIf gpu.enabled {
      hardware.graphics.enable = true;
    })

    (lib.mkIf gpu.nvidiaEnabled {
      hardware.nvidia.open = true;
      hardware.nvidia.powerManagement.enable = true;
    })

    (lib.mkIf (gpu.nvidiaEnabled && !gpu.primeOffloadEnabled) {
      services.xserver.videoDrivers = [ "nvidia" ];
    })

    (lib.mkIf gpu.primeOffloadEnabled {
      services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

      hardware.nvidia.prime = {
        offload.enable = true;
        intelBusId = config.profile.gpu.nvidia.prime.intelBusId;
        nvidiaBusId = config.profile.gpu.nvidia.prime.nvidiaBusId;
      };
    })
  ];
}
