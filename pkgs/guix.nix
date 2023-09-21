{ stdenv
, lib

, guile
, guile-lzma
, guile-disarchive
, scheme-bytestructures
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
, guile-lib

, fetchgit
, pkg-config
, makeWrapper
, help2man
, bzip2
, gzip
, autoconf-archive
, autoreconfHook
, texinfo
, locale
, perlPackages
, gettext
, glibcLocales
, util-linux

, confDir ? "/etc"
, stateDir ? "/var"
, storeDir ? "/gnu/store"
}:

let
  rev = "4dfdd822102690b5687acf28365ab707b68d9476";
in
stdenv.mkDerivation rec {
  pname = "guix";
  version = "1.4.0-${lib.strings.substring 0 6 rev}";

  src = fetchgit {
    inherit rev;
    url = "https://git.savannah.gnu.org/git/guix.git";
    hash = "sha256-nRHdHqApTyysm6WFMffPAQhOQBZzoBpU3TieTMV/Qdw=";
  };

  preAutoreconf = ''
    ./bootstrap
  '';

  propagatedBuildInputs = [
    # !!! Why disarchive can't build?
    #guile-disarchive
    guile-lzma
    scheme-bytestructures
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
    guile-lib
  ];

  nativeBuildInputs = [
    pkg-config
    glibcLocales
    makeWrapper
    gettext
    autoreconfHook
  ];

  buildInputs = [
    autoconf-archive
    bzip2
    gzip
    guile
    help2man
    locale
    perlPackages.Po4a
    texinfo
  ];

  checkInputs = [
    util-linux
  ];

  configureFlags = [
    "--with-store-dir=${storeDir}"
    "--localstatedir=${stateDir}"
    "--with-channel-commit=${rev}"
    "--sysconfdir=${confDir}"
    "--with-bash-completion-dir=${placeholder "out"}/etc/bash_completion.d"
  ];

  postPatch = ''
    sed nix/local.mk -i -E \
      -e 's|^sysvinitservicedir = .*$|sysvinitservicedir = ${placeholder "out"}/etc/init.d|' \
      -e 's|^openrcservicedir = .*$|openrcservicedir = ${placeholder "out"}/etc/openrc|'
  '';

  # We will start to look into checking once the dependencies are properly installed.
  #doCheck = true;

  meta = with lib; {
    description =
      "A transactional package manager for an advanced distribution of the GNU system";
    homepage = "https://guix.gnu.org/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
