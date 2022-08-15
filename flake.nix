{
  description = "A package and module for using GNU Guix on Nix(OS)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/22.05";

  outputs = { self, nixpkgs }:
    let
      forAllSystems =
        nixpkgs.lib.genAttrs [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
    in {
      overlays = {
        default = final: prev:
          let guilePackages = prev.callPackages ./pkgs/guile { };
          in rec {
            inherit (guilePackages)
              guile-gnutls guile-gcrypt guile-git guile-json guile-sqlite3
              guile-lzlib guile-zlib guile-ssh guile-zstd guile-semver
              guile-avahi guile3-lib;
            scheme-bytestructures = guilePackages.bytestructures;

            # Guix that comes in all flavors.
            guix = prev.callPackage ./pkgs/guix.nix { inherit guilePackages; };
            guix_binary_1_3_0 =
              prev.callPackage ./pkgs/guix-binary/default.nix { };
          };
      };

      packages = forAllSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        in {
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
        } // (import ./shells { inherit pkgs; }));

      formatter = forAllSystems (system:
        let
          pkgs = import nixpkgs {
            inherit system;
            overlays = [ self.overlays.default ];
          };
        in pkgs.nixpkgs-fmt);
    };
}
