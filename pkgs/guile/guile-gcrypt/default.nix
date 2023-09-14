{ stdenv
, lib
, fetchurl
, libgcrypt
, autoreconfHook
, pkg-config
, texinfo
, guile
}:

stdenv.mkDerivation rec {
  pname = "guile-gcrypt";
  version = "0.4.0";

  src = fetchurl {
    url = "https://notabug.org/cwebber/${pname}/archive/v${version}.tar.gz";
    sha256 = "sha256-NfBoHgHe+rCqoqgyJ8C+g2sKEwPdH3J5SXp23RJVsX4=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config texinfo ];
  buildInputs = [ guile ];
  propagatedBuildInputs = [ libgcrypt ];
  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];

  doCheck = true;

  meta = with lib; {
    description = "Bindings to Libgcrypt for GNU Guile";
    homepage = "https://notabug.org/cwebber/guile-gcrypt";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}

