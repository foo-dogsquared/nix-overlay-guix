{ stdenv
, lib
, fetchgit
, avahi
, gmp
, autoreconfHook
, pkg-config
, texinfo
, guile
}:

stdenv.mkDerivation rec {
  pname = "guile-avahi";
  version = "0.4-6d43ca";

  src = fetchgit {
    url = "git://git.sv.gnu.org/guile-avahi.git";
    rev = "6d43caf64f672a9694bf6c98bbf7a734f17a51e8";
    sha256 = "sha256-qQbPmcVdafqhRntdEJvaPr2r4eyjQYBCOGx7ITpyeTs=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config texinfo ];
  buildInputs = [ guile ];
  propagatedBuildInputs = [ avahi gmp ];

  doCheck = true;
  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];

  meta = with lib; {
    description = "Bindings to Avahi for GNU Guile";
    homepage = "https://www.nongnu.org/guile-avahi/";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}

