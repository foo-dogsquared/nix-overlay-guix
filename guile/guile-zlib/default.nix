{ stdenv, fetchurl, guile, libgcrypt, autoreconfHook, pkgconfig, texinfo, zlib
}:

stdenv.mkDerivation rec {
  pname = "guile-zlib";
  version = "0.0.1";

  src = fetchurl {
    url = "https://notabug.org/guile-zlib/${pname}/archive/${version}.tar.gz";
    sha256 = "sha256-8RAL5t0xsCmDz0mBVb8RFVyoM0IfmWmPKeVpQxczX7E=";
  };

  postConfigure = ''
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile;
    sed -i '/godir\s*=/s%=.*%=''${out}/share/guile/ccache%' Makefile;
  '';

  nativeBuildInputs = [ autoreconfHook pkgconfig texinfo ];
  buildInputs = [ guile zlib ];

  meta = with stdenv.lib; {
    description =
      "Guile-zlib is a GNU Guile library providing bindings to zlib";
    homepage = "https://notabug.org/guile-zlib/guile-zlib";
    # license = licenses.gpl3;
    maintainers = with maintainers; [ emiller88 ];
    platforms = platforms.all;
  };
}
