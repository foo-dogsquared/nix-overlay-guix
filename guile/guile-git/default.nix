{ stdenv, lib, fetchFromGitLab, guile, libgit2, bytestructures, autoreconfHook
, pkg-config, texinfo }:

stdenv.mkDerivation rec {
  pname = "guile-git";
  version = "0.3.0";

  src = fetchFromGitLab {
    owner = "guile-git";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Nlj/WONwUnLZthWw6zS0MxKK+AyDYPrWgUa6/8DR5+g=";
  };

  postConfigure = ''
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile;
    sed -i '/godir\s*=/s%=.*%=''${out}/share/guile/ccache%' Makefile;
  '';

  nativeBuildInputs = [ autoreconfHook pkg-config texinfo ];
  buildInputs = [ guile ];
  propagatedBuildInputs = [ libgit2 bytestructures ];

  meta = with lib; {
    description = "Bindings to Libgit2 for GNU Guile";
    homepage = "https://gitlab.com/guile-git/guile-git";
    license = licenses.gpl3;
    maintainers = with maintainers; [ bqv ];
    platforms = platforms.all;
  };
}
