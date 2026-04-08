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
    orchis-kde = {
      url = "github:vinceliuice/Orchis-kde";
      flake = false;
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

  outputs = inputs: {
    templates.default = {
      path = ./templates;
      description = "flake.nix for new computers";
      welcomeText = ''
        Welcome to NixOS!
      '';
    };
    nixosModules.default = { config, ... }: {
      imports = [
        ./system
        ./profile
        inputs.agenix.nixosModules.default
        inputs.home-manager.nixosModules.home-manager
      ];

      config = {
        _module.args = { inherit inputs; };
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit inputs;
          };
          sharedModules = [
            inputs.agenix.homeManagerModules.default
          ];
          users.${config.profile.userName} = import ./home;
        };
      };
    };
  };
}

