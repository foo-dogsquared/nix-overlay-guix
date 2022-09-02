{ lib
, guilePackages
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
  rev = "59ee837d8b11d7d688045b601e8b240ccbdbe7c7";
in
guilePackages.buildGuileModule rec {
  pname = "guix";
  version = "unstable-2022-08-22";

  src = fetchgit {
    inherit rev;
    url = "https://git.savannah.gnu.org/git/guix.git";
    sha256 = "sha256-P2VLyfE+Ft+HwCnJR6eVROgHYwlLEvHMW0ME5o2KNY0=";
  };

  preAutoreconf = ''
    ./bootstrap
  '';

  propagatedBuildInputs = with guilePackages; [
    # !!! Why disarchive can't build?
    #disarchive
    guile-lzma
    bytestructures
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
    guile3-lib
  ] ++ [
    gzip
    bzip2
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
  doCheck = true;

  doInstallCheck = true;
  installCheckPhase = ''
    runHook $preInstallCheck
    $out/bin/guix --version > /dev/null
    $out/bin/guix-daemon --version > /dev/null
    runHook $postInstallCheck
  '';

  meta = with lib; {
    description =
      "A transactional package manager for an advanced distribution of the GNU system";
    homepage = "https://guix.gnu.org/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
