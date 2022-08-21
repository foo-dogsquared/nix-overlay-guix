{ lib, newScope, guile_3_0, gnutls, guile-lib, overrides ? (self: super: { }) }:

let
  packages = self:
    let
      callPackage = newScope self;
      guile = guile_3_0;

      guile-gnutls = (gnutls.override {
        inherit guile;
        guileBindings = true;
      });

      guile3-lib = (guile-lib.override { guile = guile_3_0; }).overrideAttrs
        (attrs: {
          postConfigure = ''
            sed -i '/moddir\s*=/s%=.*%= ''${out}/share/guile/site%' Makefile;
            sed -i '/godir\s*=/s%=.*%= ''${out}/share/guile/ccache%' Makefile;
            sed -i '/moddir\s*=/s%=.*%= ''${out}/share/guile/site%' src/Makefile;
            sed -i '/godir\s*=/s%=.*%= ''${out}/share/guile/ccache%' src/Makefile;
          '';
        });
    in
    {
      inherit guile-gnutls guile3-lib;
      buildGuileModule = callPackage ./build-guile-module.nix { inherit guile; };
      bytestructures = callPackage ./bytestructures { };
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
