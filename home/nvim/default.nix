{ inputs, ... }:

{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  programs.nixvim = {
    enable = true;
    imports = [ 
      ./option.nix
      ./keymap.nix
      ./theme.nix
      ./plugins
    ];
    _module.args = { inherit inputs; };
  };
}
