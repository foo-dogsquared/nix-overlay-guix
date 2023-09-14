{
  description = "A package and module for using GNU Guix on Nix(OS)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      forAllSystems =
        nixpkgs.lib.genAttrs [ "x86_64-linux" "i686-linux" "aarch64-linux" ];

      lib = nixpkgs.lib;
    in
    {
      overlays = {
        default = final: prev:
          import ./pkgs { pkgs = prev; };
      };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = self.packages.${system}.guix;
        } // (self.overlays.default pkgs pkgs));

      nixosModules = {
        guix = import ./modules/nixos/guix.nix;
        guix-binary = import ./modules/nixos/guix-binary.nix;
      };

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in {
          default = import ./shell.nix { inherit pkgs; };
        });

      formatter = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in
        pkgs.nixpkgs-fmt);
    };
}
