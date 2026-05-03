{ inputs, ... }:

{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    _module.args = { inherit inputs; };
    imports = [
      { nixpkgs.config.allowUnfree = true; }
      ./option.nix
      ./keymap.nix
      ./theme.nix
      ./plugins
    ];
  };
}
