{ buildGuileModule
, lib
, fetchurl
, libgcrypt
, autoreconfHook
, pkgconfig
, texinfo
, zstd
}:

buildGuileModule rec {
  pname = "guile-zstd";
  version = "0.1.1";

  src = fetchurl {
    url = "https://notabug.org/guile-zstd/${pname}/archive/v${version}.tar.gz";
    sha256 = "sha256-blfvUk8gyrecpf1iNmxUNfcc9lL1gvwefWJYXpDUmcU=";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig texinfo ];
  propagatedBuildInputs = [ zstd ];
  doCheck = true;
  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];

  meta = with lib; {
    description =
      "Guile-zstd is a GNU Guile library providing bindings to zstd";
    homepage = "https://notabug.org/guile-zstd/guile-zstd";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
