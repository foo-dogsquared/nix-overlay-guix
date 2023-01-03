{ buildGuileModule, lib, fetchurl, xz, gnutar, gzip, guile-gcrypt, guile-lzma, pkg-config, zlib }:

buildGuileModule rec {
  pname = "disarchive";
  version = "0.5.0";

  src = fetchurl {
    url = "https://files.ngyro.com/disarchive/disarchive-${version}.tar.gz";
    sha256 = "sha256-Agt7v5HTpaskXuYmMdGDRIolaqCHUpwd/CfbZCe9Ups=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ zlib ];
  runtimeDependencies = [ xz gnutar gzip ];

  propagatedBuildInputs = [
    guile-gcrypt
    guile-lzma
  ];

  meta = with lib; {
    description = "Disassemble software into data and metadata";
    homepage = "https://ngyro.com/software/disarchive.html";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
