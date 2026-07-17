{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    kwm.url = "github:srcres258/kwm/v0.3.0.2";
  };

  outputs = {
    self,
    nixpkgs,
    kwm,
  }: let
    forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
  in {
    legacyPackages = forAllSystems (system: import ./default.nix {
      pkgs = import nixpkgs { inherit system; };
      inherit kwm;
    });
    packages = forAllSystems (system: nixpkgs.lib.filterAttrs (_: v:
      nixpkgs.lib.isDerivation v) self.legacyPackages.${system});
  };
}
