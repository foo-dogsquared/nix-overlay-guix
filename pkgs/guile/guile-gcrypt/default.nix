{ buildGuileModule, lib, fetchurl, libgcrypt, autoreconfHook, pkg-config, texinfo }:

buildGuileModule rec {
  pname = "guile-gcrypt";
  version = "0.3.0";

  src = fetchurl {
    url = "https://notabug.org/cwebber/${pname}/archive/v${version}.tar.gz";
    sha256 = "sha256-BzlMPeTzGjbKK2cOGZjFJt6JHZQ28S6U2IYqsIEnTWo=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config texinfo ];
  propagatedBuildInputs = [ libgcrypt ];
  doCheck = true;
  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];

  meta = with lib; {
    description = "Bindings to Libgcrypt for GNU Guile";
    homepage = "https://notabug.org/cwebber/guile-gcrypt";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}

