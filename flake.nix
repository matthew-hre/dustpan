{
  description = "Home Manager module for pruning old build and dependency folders";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  }:
    builtins.warn "This flake has moved to Tangled. Update your input to: git+https://tangled.org/matthew-hre.com/dustpan"
    {
      homeManagerModules.dustpan = import ./modules/dustpan.nix;
    };
}
