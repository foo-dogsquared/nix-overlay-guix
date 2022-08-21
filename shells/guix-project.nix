# The development shell for the Guix project. Though, it assumes you have Guix
# installed since it is not present here. This is effective as of 2022-01-24.
{ mkShell
, lib
, guile3-lib
, guile-avahi
, guile-gcrypt
, guile-git
, guile-gnutls
, guile-json
, guile-lzlib
, guile-semver
, guile-sqlite3
, guile-ssh
, guile-zlib
, guile-zstd
, git
, guile_3_0
, autoconf
, automake
, autoconf-archive
, gcc
, coreutils
, pkg-config
, gettext
, sqlite
, perlPackages
, help2man
}:

let
  # Each of the Guile modules listed here should have appropriately
  # placed modules at `$out/share/guile/site` and its cache files at
  # `$out/share/guile/ccache`. See `nixpkgs#gnutls` with the Guile
  # bindings enabled for an example.
  modules = [
    guile3-lib
    guile-avahi
    guile-gcrypt
    guile-git
    guile-gnutls
    guile-json
    guile-lzlib
    guile-semver
    guile-sqlite3
    guile-ssh
    guile-zlib
    guile-zstd
  ];
in
mkShell {
  nativeBuildInputs = [ git guile_3_0 gettext pkg-config help2man ];
  buildInputs = modules;
  packages = [
    autoconf
    autoconf-archive
    automake
    coreutils
    gcc
    perlPackages.Po4a
    pkg-config
    sqlite
  ];

  # We're making as much assumptions just to make it work.
  # TODO: Reduce the possible load paths.
  #       Is it reducing the performance of the interpreter that much, though?
  GUILE_LOAD_PATH =
    let
      guilePath = lib.concatMap
        (module: [
          "${module}/share/guile/site"
          "${module}/share/guile"
          "${module}/share" # No one is making hapless packaging here (READ: just me).
        ])
        modules;
    in
    "${lib.concatStringsSep ":" guilePath}";

  GUILE_LOAD_COMPILED_PATH =
    let
      guilePath = lib.concatMap
        (module: [
          "${module}/share/guile/ccache"
          "${module}/share/guile/site" # Some Guile packages place all of the build outputs here.
          "${module}/share/guile" # This is fine. Though, I'm *THIS* close to being crazy.
          "${module}/share" # NOW I'M CRAZY!
        ])
        modules;
    in
    "${lib.concatStringsSep ":" guilePath}";
}
