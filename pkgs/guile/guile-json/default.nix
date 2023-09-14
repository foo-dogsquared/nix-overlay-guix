{ stdenv
, lib
, fetchurl
, texinfo
, pkg-config
, guile
}:

stdenv.mkDerivation rec {
  pname = "guile-json";
  version = "4.7.3";

  src = fetchurl {
    url = "mirror://savannah/guile-json/${pname}-${version}.tar.gz";
    sha256 = "sha256-OLoEjtKdEvBbMsWy+3pReVxEi0HkA6Kxty/wA1gX84g=";
  };

  nativeBuildInputs = [ pkg-config texinfo ];
  buildInputs = [ guile ];
  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];

  doCheck = true;

  meta = with lib; {
    description = "JSON Bindings for GNU Guile";
    homepage = "https://savannah.nongnu.org/projects/guile-json";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}

