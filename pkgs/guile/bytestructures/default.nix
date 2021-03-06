{ stdenv, lib, fetchFromGitHub, guile_3_0, autoreconfHook, pkg-config }:

stdenv.mkDerivation rec {
  pname = "scheme-bytestructures";
  version = "1.0.10";

  src = fetchFromGitHub {
    owner = "TaylanUB";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-04oDvwvzTRzAVyywbcCm3Ug3p3xNbxjI7nOKYakEZZI=";
  };

  postConfigure = ''
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile;
    sed -i '/godir\s*=/s%=.*%=''${out}/share/guile/ccache%' Makefile;
  '';

  nativeBuildInputs = [ autoreconfHook pkg-config ];
  buildInputs = [ guile_3_0 ];

  meta = with lib; {
    description = "Structured access to bytevector contents";
    homepage = "https://github.com/TaylanUB/scheme-bytestructures";
    license = licenses.gpl3;
    maintainers = with maintainers; [ bqv ];
    platforms = platforms.all;
  };
}

