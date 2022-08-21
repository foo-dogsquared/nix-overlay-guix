{ lib
, guilePackages
, fetchgit
, pkg-config
, makeWrapper
, help2man
, bzip2
, autoconf-archive
, autoreconfHook
, texinfo
, locale
, perlPackages
, gettext
, glibcLocalesUtf8
, storeDir ? null
, stateDir ? "/var"
}:

guilePackages.buildGuileModule rec {
  pname = "guix";
  version = "unstable-2022-08-22";

  src = fetchgit {
    url = "https://git.savannah.gnu.org/git/guix.git";
    rev = "59ee837d8b11d7d688045b601e8b240ccbdbe7c7";
    sha256 = "sha256-P2VLyfE+Ft+HwCnJR6eVROgHYwlLEvHMW0ME5o2KNY0=";
  };

  preAutoreconf = ''
    ./bootstrap
  '';

  propagatedBuildInputs = with guilePackages; [
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
  ];

  nativeBuildInputs = [
    pkg-config
    glibcLocalesUtf8
    makeWrapper
    gettext
    autoreconfHook
  ];

  buildInputs = [
    bzip2
    help2man
    autoconf-archive
    texinfo
    locale
    perlPackages.Po4a
  ];

  GUIX_LOCPATH = "${glibcLocalesUtf8}/lib/locale";

  configureFlags = []
    ++ lib.optional (storeDir != null) "--with-store-dir=${storeDir}"
    ++ lib.optional (stateDir != null) "--localstatedir=${stateDir}";

  meta = with lib; {
    description =
      "A transactional package manager for an advanced distribution of the GNU system";
    homepage = "https://guix.gnu.org/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
