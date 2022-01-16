{ stdenv, lib, fetchurl, guile_3_0, libgcrypt, autoreconfHook, pkgconfig, texinfo, lzlib
}:

stdenv.mkDerivation rec {
  pname = "guile-lzlib";
  version = "0.0.2";

  src = fetchurl {
    url = "https://notabug.org/guile-lzlib/${pname}/archive/${version}.tar.gz";
    sha256 = "sha256-hiPbd9RH57n/v8vCiDkOcGprGomxFx2u1gh0z+x+T4c=";
  };

  postConfigure = ''
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile;
    sed -i '/godir\s*=/s%=.*%=''${out}/share/guile/ccache%' Makefile;
  '';

  nativeBuildInputs = [ autoreconfHook pkgconfig texinfo ];
  buildInputs = [ guile_3_0 ];
  propagatedBuildInputs = [ lzlib ];

  meta = with lib; {
    description =
      "Guile-lzlib is a GNU Guile library providing bindings to lzlib";
    homepage = "https://notabug.org/guile-lzlib/guile-lzlib";
    # license = licenses.gpl3;
    maintainers = with maintainers; [ emiller88 ];
    platforms = platforms.all;
  };
}
