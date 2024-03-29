{ buildGuileModule
, lib
, fetchurl
, libgcrypt
, autoreconfHook
, pkg-config
, texinfo
, zlib
}:

buildGuileModule rec {
  pname = "guile-zlib";
  version = "0.1.0";

  src = fetchurl {
    url = "https://notabug.org/guile-zlib/${pname}/archive/v${version}.tar.gz";
    sha256 = "sha256-JccmtXCgbSG8b9fsYJPzd8dJzi790dFRasG1lfP5Tuk=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config texinfo ];
  propagatedBuildInputs = [ zlib ];
  doCheck = true;
  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];

  meta = with lib; {
    description =
      "Guile-zlib is a GNU Guile library providing bindings to zlib";
    homepage = "https://notabug.org/guile-zlib/guile-zlib";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
