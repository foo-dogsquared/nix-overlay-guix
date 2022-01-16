{ stdenv, lib, fetchurl, guile_3_0, texinfo, pkg-config }:

stdenv.mkDerivation rec {
  pname = "guile-json";
  version = "4.5.2";

  src = fetchurl {
    url = "mirror://savannah/guile-json/${pname}-${version}.tar.gz";
    sha256 = "sha256-GrBG7DaxxEwEGsJ1Vo2Bh4TXH6uaXZX5Eoz+iiUFGTM=";
  };

  postConfigure = ''
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile;
    sed -i '/objdir\s*=/s%=.*%=''${out}/share/guile/ccache%' Makefile;
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site/json%' json/Makefile;
    sed -i '/objdir\s*=/s%=.*%=''${out}/share/guile/ccache/json%' json/Makefile;
  '';

  nativeBuildInputs = [ pkg-config texinfo ];
  buildInputs = [ guile_3_0 ];

  meta = with lib; {
    description = "JSON Bindings for GNU Guile";
    homepage = "https://savannah.nongnu.org/projects/guile-json";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ bqv ];
    platforms = platforms.all;
  };
}

