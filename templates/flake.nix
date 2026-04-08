{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos = {
      url = "github:dokee39/nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nixos, ... }: let
    lib = nixpkgs.lib;
    hosts = builtins.attrNames (builtins.readDir ./hosts);
    mkHost = hostName: lib.nixosSystem {
      modules = [
        ./hosts/${hostName}
        nixos.nixosModules.default
        { profile.hostName = hostName; }
      ];
    };
  in {
    nixosConfigurations = lib.genAttrs hosts mkHost;
  };
}
