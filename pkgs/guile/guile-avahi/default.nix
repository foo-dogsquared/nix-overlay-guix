{ stdenv, lib, fetchgit, guile_3_0, avahi, gmp, autoreconfHook, pkgconfig, texinfo }:

stdenv.mkDerivation rec {
  pname = "guile-avahi";
  version = "0.4";

  src = fetchgit {
    url = "git://git.sv.gnu.org/guile-avahi.git";
    rev = "v${version}";
    sha256 = "sha256-1hlgMU71DPCBn4pZLfV8VE/4grgBsDLhdETj4d8zSNQ=";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig texinfo ];
  buildInputs = [ guile_3_0 ];
  propagatedBuildInputs = [ avahi gmp ];

  configureFlags = [
    "--with-guilemoduledir=\${out}/share/guile/site"
  ];

  postFixup = ''
    # Replace the references to the library file with our specific library objects.
    for f in $(find $out/share/guile/site -name '*.scm'); do \
      substituteInPlace $f \
        --replace "libguile-avahi" "$out/lib/libguile-avahi"; \
    done
  '';

  meta = with lib; {
    description = "Bindings to Avahi for GNU Guile";
    homepage = "https://www.nongnu.org/guile-avahi/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ bqv ];
    platforms = platforms.all;
  };
}

