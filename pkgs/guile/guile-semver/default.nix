{ stdenv, lib, fetchurl, guile_3_0, libgcrypt, autoreconfHook, pkgconfig, texinfo }:

stdenv.mkDerivation rec {
  pname = "guile-semver";
  version = "0.1.1";

  src = fetchurl {
    url = "https://files.ngyro.com/guile-semver/${pname}-${version}.tar.gz";
    sha256 = "sha256-T3kJGTdf6yBKjqLtqSopHZu03kyOscZ3Z4RYmoYlN4E=";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig texinfo ];
  buildInputs = [ guile_3_0 ];

  postConfigure = ''
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile;
    sed -i '/ccachedir\s*=/s%=.*%=''${out}/share/guile/ccache%' Makefile;
  '';

  meta = with lib; {
    description =
      "A GNU Guile library implementing Semantic Versioning 2.0.0";
    homepage = "https://ngyro.com/software/guile-semver.html";
    license = licenses.gpl3;
    platforms = platforms.all;
  };
}
