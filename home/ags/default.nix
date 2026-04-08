{ pkgs, inputs, ... }: let
  system = pkgs.stdenv.hostPlatform.system;
in {

  imports = [ inputs.ags.homeManagerModules.default ];

  programs.ags = {
    enable = true;
    configDir = ./.;

    extraPackages = with inputs.ags.packages.${system}; [
      hyprland
      wireplumber
    ];
  };
}
