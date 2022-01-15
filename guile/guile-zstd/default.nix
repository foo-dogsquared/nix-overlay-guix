{ stdenv, lib, fetchurl, guile, libgcrypt, autoreconfHook, pkgconfig, texinfo, zstd
}:

stdenv.mkDerivation rec {
  pname = "guile-zstd";
  version = "0.1.1";

  src = fetchurl {
    url = "https://notabug.org/guile-zstd/${pname}/archive/v${version}.tar.gz";
    sha256 = "sha256-blfvUk8gyrecpf1iNmxUNfcc9lL1gvwefWJYXpDUmcU=";
  };

  postConfigure = ''
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile;
    sed -i '/godir\s*=/s%=.*%=''${out}/share/guile/ccache%' Makefile;
  '';

  nativeBuildInputs = [ autoreconfHook pkgconfig texinfo ];
  buildInputs = [ guile zstd ];

  meta = with lib; {
    description =
      "Guile-zstd is a GNU Guile library providing bindings to zstd";
    homepage = "https://notabug.org/guile-zstd/guile-zstd";
    license = licenses.gpl3Plus;
    platforms = platforms.all;
  };
}
