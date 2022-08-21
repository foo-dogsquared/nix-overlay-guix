{ buildGuileModule, lib, fetchurl, sqlite, autoreconfHook, pkg-config, texinfo }:

buildGuileModule rec {
  pname = "guile-sqlite3";
  version = "0.1.3";

  src = fetchurl {
    url =
      "https://notabug.org/guile-sqlite3/${pname}/archive/v${version}.tar.gz";
    sha256 = "sha256-FYy4KVjGMpMZ+RFBKZnqElmA8yf1QYW/Da0nHW+PRcI=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config texinfo ];
  propagatedBuildInputs = [ sqlite ];

  meta = with lib; {
    description = "Bindings to Sqlite3 for GNU Guile";
    homepage = "https://notabug.org/guile-sqlite3/guile-sqlite3";
    license = licenses.gpl3;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}

