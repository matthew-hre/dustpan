{
  description = "Home Manager module for pruning old build and dependency folders";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";

  outputs = {
    self,
    nixpkgs,
    home-manager,
    ...
  }: {
    homeManagerModules.node-modules-gc = import ./modules/node-modules-gc.nix;
  };
}
