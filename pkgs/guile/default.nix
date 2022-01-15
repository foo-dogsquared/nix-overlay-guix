{ lib, newScope, guile, gnutls, overrides ? (self: super: { }) }:

let
  packages = self:
    let
      callPackage = newScope self;

      guile-gnutls = (gnutls.override {
        inherit guile;
        guileBindings = true;
      }).overrideAttrs (attrs: {
        configureFlags = [
          "--with-guile-site-dir=\${out}/share/guile/site"
          "--with-guile-site-ccache-dir=\${out}/share/guile/ccache"
          "--with-guile-extension-dir=\${out}/lib/guile/extensions"
        ];
      });
    in {
      inherit guile-gnutls;

      guile-gcrypt = callPackage ./guile-gcrypt { };

      bytestructures = callPackage ./bytestructures { };

      lzlib = callPackage ./lzlib { };

      guile-git = callPackage ./guile-git { };

      guile-json = callPackage ./guile-json { };

      guile-lzlib = callPackage ./guile-lzlib { };

      guile-sqlite3 = callPackage ./guile-sqlite3 { };

      guile-semver = callPackage ./guile-semver { };

      guile-ssh = callPackage ./guile-ssh { };

      guile-zlib = callPackage ./guile-zlib { };

      guile-zstd = callPackage ./guile-zstd { };
    };
in lib.fix' (lib.extends overrides packages)
