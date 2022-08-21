{ pkgs ? import <nixpkgs> { } }:

with pkgs;

rec {
  guilePackages = callPackages ./pkgs/guile { };
  guix = callPackage ./pkgs/guix.nix { inherit guilePackages; };
}
