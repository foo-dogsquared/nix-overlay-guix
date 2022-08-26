{ buildGuileModule, lib, fetchurl, texinfo, pkg-config }:

buildGuileModule rec {
  pname = "guile-json";
  version = "4.5.2";

  src = fetchurl {
    url = "mirror://savannah/guile-json/${pname}-${version}.tar.gz";
    sha256 = "sha256-GrBG7DaxxEwEGsJ1Vo2Bh4TXH6uaXZX5Eoz+iiUFGTM=";
  };

  nativeBuildInputs = [ pkg-config texinfo ];
  doCheck = true;
  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];

  meta = with lib; {
    description = "JSON Bindings for GNU Guile";
    homepage = "https://savannah.nongnu.org/projects/guile-json";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}

