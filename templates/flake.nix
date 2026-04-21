{
  inputs = {
    nixos.url = "github:dokee39/nixos";
    nixpkgs.follows = "nixos/nixpkgs";
  };

  outputs = { nixpkgs, nixos, ... }: let
    lib = nixpkgs.lib;
    hosts = builtins.attrNames (builtins.readDir ./hosts);
    mkHost = hostName: lib.nixosSystem {
      modules = [
        ./hosts/${hostName}
        nixos.nixosModules.default
        { terra.hostName = hostName; }
      ];
    };
  in {
    nixosConfigurations = lib.genAttrs hosts mkHost;
  };
}
