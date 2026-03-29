{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mmdb = {
      url = "github:alecthw/mmdb_china_ip_list?ref=release";
      flake = false;
    };

    lxgw-bright = {
      url = "github:lxgw/LxgwBright";
      flake = false;
    };
    awww = {
      url = "git+https://codeberg.org/LGFae/awww";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    beacon = {
      url = "github:DanilaMihailov/beacon.nvim";
      flake = false;
    };
    search-replace = {
      url = "github:roobert/search-replace.nvim";
      flake = false;
    };
    navbuddy = {
      url = "github:hasansujon786/nvim-navbuddy";
      flake = false;
    };
    im-select = {
      url = "github:keaising/im-select.nvim";
      flake = false;
    };

    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.astal.follows = "astal";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, agenix, ... }:
    let
      lib = nixpkgs.lib;

      hosts = map (lib.strings.removeSuffix ".nix") (builtins.attrNames (builtins.readDir ./hosts));
      userName = "dokee";

      mkHost = hostName:
      let
        specialArgs = { inherit inputs hostName userName; };
      in 
        lib.nixosSystem {
          inherit specialArgs;
          modules = [
            ./system
            ./hosts/${hostName}.nix

            { networking.hostName = hostName; }

            agenix.nixosModules.default

            home-manager.nixosModules.home-manager {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = specialArgs;
              home-manager.sharedModules = [
                agenix.homeManagerModules.default
              ];
              home-manager.users.${userName} = import ./home;
            }
          ];
        };
    in {
      nixosConfigurations = lib.genAttrs hosts mkHost;
    };
}

