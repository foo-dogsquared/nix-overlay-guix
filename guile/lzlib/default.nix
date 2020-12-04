{ stdenv, fetchurl, guile, libgcrypt, autoreconfHook, pkgconfig, texinfo, }:
# https://git.savannah.gnu.org/cgit/guix.git/tree/gnu/packages/compression.scm#n1816
stdenv.mkDerivation rec {
  pname = "lzlib";
  version = "1.11";

  src = fetchurl {
    url =
      "https://download.savannah.gnu.org/releases/lzip/${pname}/${pname}-${version}.tar.gz";
    sha256 = "sha256-bFxfh1nRq3xMPFN4jqLZ2q0Ert3PM4ImiT+P8TSRTTY=";
  };

  # nativeBuildInputs = [ pkgconfig ];
  # buildInputs = [ ];

  meta = with stdenv.lib; {
    description = "lzlib is a GNU Guile library providing bindings to lzlib";
    homepage = "https://notabug.org/guile-lzlib/guile-lzlib";
    # license = licenses.bsd-2;
    maintainers = with maintainers; [ emiller88 ];
    platforms = platforms.all;
  };
}
