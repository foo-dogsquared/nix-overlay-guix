{ lib, newScope, overrides ? (self: super: { }) }:

let
  packages = self:
    let
      callPackage = newScope self;
    in
    lib.recurseIntoAttrs {
      bytestructures = callPackage ./bytestructures { };
      guile-disarchive = callPackage ./disarchive { };
      guile-avahi = callPackage ./guile-avahi { };
      guile-gcrypt = callPackage ./guile-gcrypt { };
      guile-git = callPackage ./guile-git { };
      guile-json = callPackage ./guile-json { };
      guile-lzlib = callPackage ./guile-lzlib { };
      guile-lzma = callPackage ./guile-lzma { };
      guile-semver = callPackage ./guile-semver { };
      guile-sqlite3 = callPackage ./guile-sqlite3 { };
      guile-quickcheck = callPackage ./guile-quickcheck { };
      guile-ssh = callPackage ./guile-ssh { };
      guile-zlib = callPackage ./guile-zlib { };
      guile-zstd = callPackage ./guile-zstd { };
    };
in
lib.fix' (lib.extends overrides packages)
