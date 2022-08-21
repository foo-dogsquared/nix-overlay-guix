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
, glibcLocales
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
    glibcLocales
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

  configureFlags = [
    "--localstatedir=/var"
  ];

  meta = with lib; {
    description =
      "A transactional package manager for an advanced distribution of the GNU system";
    homepage = "https://guix.gnu.org/";
    license = licenses.gpl3;
    platforms = platforms.linux;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
