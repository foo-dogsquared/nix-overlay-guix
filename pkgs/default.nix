{ pkgs }:

with pkgs;

rec {
  guix = callPackage ./guix.nix { inherit guilePackages; };
  guilePackages = callPackage ./guile { };
}
