{ buildGuileModule, lib, fetchurl, libgcrypt, autoreconfHook, pkgconfig, texinfo }:

buildGuileModule rec {
  pname = "guile-gcrypt";
  version = "0.3.0";

  src = fetchurl {
    url = "https://notabug.org/cwebber/${pname}/archive/v${version}.tar.gz";
    sha256 = "sha256-BzlMPeTzGjbKK2cOGZjFJt6JHZQ28S6U2IYqsIEnTWo=";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig texinfo ];
  propagatedBuildInputs = [ libgcrypt ];

  meta = with lib; {
    description = "Bindings to Libgcrypt for GNU Guile";
    homepage = "https://notabug.org/cwebber/guile-gcrypt";
    license = licenses.gpl3;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}

