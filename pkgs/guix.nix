{ stdenv
, lib

# !!! Why disarchive can't build?
#, disarchive
, guile-lzma
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

, confDir ? "/etc"
, stateDir ? "/var"
, storeDir ? "/gnu/store"
}:

let
  rev = "987a11bc44b9b18ae02dbece01c4af8ec3e10738";
in
stdenv.mkDerivation rec {
  pname = "guix";
  version = "1.4.0";

  src = fetchgit {
    inherit rev;
    url = "https://git.savannah.gnu.org/git/guix.git";
    sha256 = "sha256-tIFU2h4R6Nsyn6fMygYi6GYXWza4vFTLYTTdJfiNVRA=";
  };

  preAutoreconf = ''
    ./bootstrap
  '';

  propagatedBuildInputs = [
    #disarchive
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
  ] ++ [
    gzip
    bzip2
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
    help2man
    autoconf-archive
    texinfo
    locale
    perlPackages.Po4a
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
