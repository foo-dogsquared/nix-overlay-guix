{ stdenv, lib, fetchurl, guile_3_0, libgcrypt, autoreconfHook, pkgconfig, texinfo }:

stdenv.mkDerivation rec {
  pname = "guile-gcrypt";
  version = "0.3.0";

  src = fetchurl {
    url = "https://notabug.org/cwebber/${pname}/archive/v${version}.tar.gz";
    sha256 = "sha256-BzlMPeTzGjbKK2cOGZjFJt6JHZQ28S6U2IYqsIEnTWo=";
  };

  postConfigure = ''
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile;
    sed -i '/godir\s*=/s%=.*%=''${out}/share/guile/ccache%' Makefile;
  '';

  nativeBuildInputs = [ autoreconfHook pkgconfig texinfo ];
  buildInputs = [ guile_3_0 ];
  propagatedBuildInputs = [ libgcrypt ];

  meta = with lib; {
    description = "Bindings to Libgcrypt for GNU Guile";
    homepage = "https://notabug.org/cwebber/guile-gcrypt";
    license = licenses.gpl3;
    maintainers = with maintainers; [ bqv ];
    platforms = platforms.all;
  };
}

