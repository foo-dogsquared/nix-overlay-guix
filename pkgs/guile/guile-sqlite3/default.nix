{ stdenv, lib, fetchurl, guile_3_0, sqlite, autoreconfHook, pkg-config, texinfo }:

stdenv.mkDerivation rec {
  pname = "guile-sqlite3";
  version = "0.1.3";

  src = fetchurl {
    url =
      "https://notabug.org/guile-sqlite3/${pname}/archive/v${version}.tar.gz";
    sha256 = "sha256-FYy4KVjGMpMZ+RFBKZnqElmA8yf1QYW/Da0nHW+PRcI=";
  };

  postConfigure = ''
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile;
    sed -i '/godir\s*=/s%=.*%=''${out}/share/guile/ccache%' Makefile;
  '';

  nativeBuildInputs = [ autoreconfHook pkg-config texinfo ];
  buildInputs = [ guile_3_0 ];
  propagatedBuildInputs = [ sqlite ];

  meta = with lib; {
    description = "Bindings to Sqlite3 for GNU Guile";
    homepage = "https://notabug.org/guile-gcrypt/guile-gcrypt";
    license = licenses.gpl3;
    maintainers = with maintainers; [ bqv ];
    platforms = platforms.all;
  };
}

