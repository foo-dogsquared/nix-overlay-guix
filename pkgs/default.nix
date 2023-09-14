{ pkgs ? import <nixpkgs> { } }:

with pkgs;

lib.fix (self: let
  callPackage = newScope self;
  guilePackages = callPackage ./guile { };
in
  rec {
    inherit (guilePackages)
      guile-disarchive guile-gcrypt guile-git guile-json guile-sqlite3
      guile-lzlib guile-lzma guile-zlib guile-ssh guile-zstd guile-semver
      guile-avahi guile-quickcheck;
    scheme-bytestructures = guilePackages.bytestructures;

    guix = callPackage ./guix.nix { };
    guix_binary_1_3_0 = callPackage ./guix-binary { };
  }
)
