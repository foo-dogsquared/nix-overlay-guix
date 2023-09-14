{ stdenv
, lib
, fetchurl
, guile
, xz
, gnutar
, gzip
, guile-gcrypt
, guile-lzma
, pkg-config
, zlib
}:

stdenv.mkDerivation rec {
  pname = "guile-disarchive";
  version = "0.5.0";

  src = fetchurl {
    url = "https://files.ngyro.com/disarchive/disarchive-${version}.tar.gz";
    hash = "sha256-Agt7v5HTpaskXuYmMdGDRIolaqCHUpwd/CfbZCe9Ups=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ guile zlib guile-gcrypt guile-lzma ];
  runtimeDependencies = [ xz gnutar gzip ];

  meta = with lib; {
    description = "Disassemble software into data and metadata";
    homepage = "https://ngyro.com/software/disarchive.html";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
