{
  description = "Home Manager module for pruning old node_modules folders";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.home-manager.url = "github:nix-community/home-manager";

  outputs = {
    homeManagerModules.node-modules-gc = import ./modules/node-modules-gc.nix;
  };
}
