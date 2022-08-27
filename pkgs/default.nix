{ pkgs ? import <nixpkgs> { } }:

let
  inherit (pkgs) callPackage;
  guilePackages = callPackage ./guile { };
in {
  inherit guilePackages;
  guix = callPackage ./guix.nix { inherit guilePackages; };
  guix_binary_1_3_0 = callPackage ./guix-binary { };
}
