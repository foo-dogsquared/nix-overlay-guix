{ stdenv
, lib
, fetchurl
, sqlite
, autoreconfHook
, pkg-config
, texinfo
, guile
}:

stdenv.mkDerivation rec {
  pname = "guile-sqlite3";
  version = "0.1.3";

  src = fetchurl {
    url =
      "https://notabug.org/guile-sqlite3/${pname}/archive/v${version}.tar.gz";
    sha256 = "sha256-FYy4KVjGMpMZ+RFBKZnqElmA8yf1QYW/Da0nHW+PRcI=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config texinfo ];
  buildInputs = [ guile ];
  propagatedBuildInputs = [ sqlite ];
  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];

  doCheck = true;

  meta = with lib; {
    description = "Bindings to Sqlite3 for GNU Guile";
    homepage = "https://notabug.org/guile-sqlite3/guile-sqlite3";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}

