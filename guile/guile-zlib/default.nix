{ stdenv, lib, fetchurl, guile, libgcrypt, autoreconfHook, pkgconfig, texinfo, zlib
}:

stdenv.mkDerivation rec {
  pname = "guile-zlib";
  version = "0.1.0";

  src = fetchurl {
    url = "https://notabug.org/guile-zlib/${pname}/archive/v${version}.tar.gz";
    sha256 = "sha256-JccmtXCgbSG8b9fsYJPzd8dJzi790dFRasG1lfP5Tuk=";
  };

  postConfigure = ''
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile;
    sed -i '/godir\s*=/s%=.*%=''${out}/share/guile/ccache%' Makefile;
  '';

  nativeBuildInputs = [ autoreconfHook pkgconfig texinfo ];
  buildInputs = [ guile zlib ];

  meta = with lib; {
    description =
      "Guile-zlib is a GNU Guile library providing bindings to zlib";
    homepage = "https://notabug.org/guile-zlib/guile-zlib";
    # license = licenses.gpl3;
    maintainers = with maintainers; [ emiller88 ];
    platforms = platforms.all;
  };
}
