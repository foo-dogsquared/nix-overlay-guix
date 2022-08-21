{ lib, newScope, guile_3_0, gnutls, guile-lib, overrides ? (self: super: { }) }:

let
  packages = self:
    let
      callPackage = newScope self;

      guile-gnutls = (gnutls.override {
        guile = guile_3_0;
        guileBindings = true;
      });
    in
    {
      inherit guile-gnutls;
      buildGuileModule = callPackage ./build-guile-module.nix {
        guile = guile_3_0;
      };
      bytestructures = callPackage ./bytestructures { };
      guile3-lib = callPackage ./guile3-lib { };
      guile-avahi = callPackage ./guile-avahi { };
      guile-gcrypt = callPackage ./guile-gcrypt { };
      guile-git = callPackage ./guile-git { };
      guile-json = callPackage ./guile-json { };
      guile-lzlib = callPackage ./guile-lzlib { };
      guile-semver = callPackage ./guile-semver { };
      guile-sqlite3 = callPackage ./guile-sqlite3 { };
      guile-ssh = callPackage ./guile-ssh { };
      guile-zlib = callPackage ./guile-zlib { };
      guile-zstd = callPackage ./guile-zstd { };
    };
in
lib.fix' (lib.extends overrides packages)
