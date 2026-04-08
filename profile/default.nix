{ lib, config, ... }:

{
  options.profile = {
    userName = lib.mkOption {
      type = lib.types.str;
      description = "User name";
    };
    hostName = lib.mkOption {
      type = lib.types.str;
      description = "Host name";
    };

    authorizedSshKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "";
    };

    mihomo.subscriptionUrlSecretFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a secret file containing the Mihomo subscription URL.";
    };
    codex.githubPatSecretFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to a secret file containing the GitHub PAT.";
    };

    desktop.enable = lib.mkEnableOption "desktop environment";

    gpu = {
      intelIgpu.enable = lib.mkEnableOption "Intel integrated GPU";

      nvidia = {
        enable = lib.mkEnableOption "NVIDIA GPU";

        prime = {
          intelBusId = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "PCI:0@0:2:0";
            description = "Intel iGPU PCI bus ID used for NVIDIA PRIME offload.";
          };

          nvidiaBusId = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            example = "PCI:1@0:0:0";
            description = "NVIDIA GPU PCI bus ID used for NVIDIA PRIME offload.";
          };
        };
      };
    };

    _internal.gpu = {
      enabled = lib.mkOption {
        type = lib.types.bool;
        readOnly = true;
        internal = true;
      };

      intelIgpuEnabled = lib.mkOption {
        type = lib.types.bool;
        readOnly = true;
        internal = true;
      };

      nvidiaEnabled = lib.mkOption {
        type = lib.types.bool;
        readOnly = true;
        internal = true;
      };

      primeOffloadEnabled = lib.mkOption {
        type = lib.types.bool;
        readOnly = true;
        internal = true;
      };
    };
  };

  config = {
    profile._internal.gpu = {
      enabled =
        config.profile.gpu.intelIgpu.enable
        || config.profile.gpu.nvidia.enable;

      intelIgpuEnabled = config.profile.gpu.intelIgpu.enable;
      nvidiaEnabled = config.profile.gpu.nvidia.enable;

      primeOffloadEnabled =
        config.profile.gpu.intelIgpu.enable
        && config.profile.gpu.nvidia.enable;
    };

    assertions = [
      {
        assertion =
          (!config.profile.desktop.enable)
          || config.profile._internal.gpu.enabled;
        message = "A GPU must be enabled when profile.desktop.enable is true.";
      }
      {
        assertion =
          (!config.profile._internal.gpu.primeOffloadEnabled)
          || (
            config.profile.gpu.nvidia.prime.intelBusId != null
            && config.profile.gpu.nvidia.prime.nvidiaBusId != null
          );
        message = "Both PRIME bus IDs must be set when Intel iGPU and NVIDIA are enabled together.";
      }
    ];
  };
}
