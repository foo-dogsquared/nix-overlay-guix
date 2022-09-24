{ buildGuileModule, lib, fetchurl, pkg-config }:

buildGuileModule rec {
  pname = "guile-quickcheck";
  version = "0.1.0";

  src = fetchurl {
    url = "https://files.ngyro.com/guile-quickcheck/guile-quickcheck-0.1.0.tar.gz";
    sha256 = "03mwi1l3354x52nar0zwhcm0x29yai9xjln4p4gbchwvx5dsr6fb";
  };

  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    homepage = "https://ngyro.com/software/guile-quickcheck.html";
    description = "Guile library providing tools for randomized, property-based testing";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
