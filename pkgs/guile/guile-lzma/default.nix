{ stdenv
, lib
, fetchurl
, xz
, pkg-config
, guile
, bytestructures
}:

stdenv.mkDerivation rec {
  pname = "guile-lzma";
  version = "0.1.1";

  src = fetchurl {
    url = "https://files.ngyro.com/guile-lzma/guile-lzma-${version}.tar.gz";
    sha256 = "sha256-K4ZoltZy7U05AI9LUzZ1DXiXVgoGZ4Nl9cWnK9L8zl4=";
  };

  nativeBuildInputs = [
    pkg-config
    bytestructures
  ];
  buildInputs = [ guile ];
  propagatedBuildInputs = [ xz ];

  doCheck = true;

  meta = with lib; {
    homepage = "https://ngyro.com/software/guile-lzma.html";
    description = "Guile wrapper for lzma library";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
