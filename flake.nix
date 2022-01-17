{
  description = "A package and module for using GNU Guix on Nix(OS)";

  outputs = { self, nixpkgs }:
    let
      forAllSystems =
        nixpkgs.lib.genAttrs [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
    in {

      overlay = final: prev:
        let guilePackages = prev.callPackages ./pkgs/guile { };
        in rec {
          guix = prev.callPackage ./pkgs/guix.nix { inherit guilePackages; };
          inherit (guilePackages)
            guile-gnutls guile-gcrypt guile-git guile-json guile-sqlite3 guile-lzlib guile-zlib
            guile-ssh guile-zstd guile-semver guile-avahi guile3-lib;
          scheme-bytestructures = guilePackages.bytestructures;
        };

      packages = forAllSystems (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in self.overlay pkgs pkgs);

      defaultPackage = forAllSystems (system: self.packages.${system}.guix);

      nixosModules = { guix = import ./modules/nixos/guix.nix; };

      devShell = forAllSystems (system: import ./shell.nix { pkgs = import nixpkgs { inherit system; }; });
    };
}
