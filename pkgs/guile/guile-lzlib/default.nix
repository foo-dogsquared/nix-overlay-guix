{ buildGuileModule
, lib
, fetchurl
, libgcrypt
, autoreconfHook
, pkgconfig
, texinfo
, lzlib
}:

buildGuileModule rec {
  pname = "guile-lzlib";
  version = "0.0.2";

  src = fetchurl {
    url = "https://notabug.org/guile-lzlib/${pname}/archive/${version}.tar.gz";
    sha256 = "sha256-hiPbd9RH57n/v8vCiDkOcGprGomxFx2u1gh0z+x+T4c=";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig texinfo ];
  propagatedBuildInputs = [ lzlib ];

  meta = with lib; {
    description =
      "Guile-lzlib is a GNU Guile library providing bindings to lzlib";
    homepage = "https://notabug.org/guile-lzlib/guile-lzlib";
    # license = licenses.gpl3;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
