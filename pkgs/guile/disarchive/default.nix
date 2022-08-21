{ buildGuileModule, lib, fetchurl, xz, gnutar, gzip, guile-gcrypt, guile-lzma, pkg-config, zlib }:

buildGuileModule rec {
  pname = "disarchive";
  version = "0.4.0";

  src = fetchurl {
    url = "https://files.ngyro.com/disarchive/disarchive-${version}.tar.gz";
    sha256 = "sha256-GllADhZH0cRPC7nXIjdZ2WwdbY7Q98EvQ913fTVDFN8=";
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
