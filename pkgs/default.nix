{ pkgs ? import <nixpkgs> { } }:

with pkgs;

lib.fix (self: let
  callPackage = newScope self;
  guilePackages = callPackage ./guile { };
in
  rec {
    inherit (guilePackages)
      disarchive guile-gnutls guile-gcrypt guile-git guile-json guile-sqlite3
      guile-lzlib guile-lzma guile-zlib guile-ssh guile-zstd guile-semver
      guile-avahi guile3-lib guile-quickcheck;
    scheme-bytestructures = guilePackages.bytestructures;

    guix = callPackage ./guix.nix { buildGuileModule = guilePackages.buildGuileModule; };
    guix_binary_1_3_0 = callPackage ./guix-binary { };
  }
)
