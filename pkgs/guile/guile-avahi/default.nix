{ buildGuileModule, lib, fetchgit, avahi, gmp, autoreconfHook, pkgconfig, texinfo }:

buildGuileModule rec {
  pname = "guile-avahi";
  version = "0.4";

  src = fetchgit {
    url = "git://git.sv.gnu.org/guile-avahi.git";
    rev = "v${version}";
    sha256 = "sha256-1hlgMU71DPCBn4pZLfV8VE/4grgBsDLhdETj4d8zSNQ=";
  };

  nativeBuildInputs = [ autoreconfHook pkgconfig texinfo ];
  propagatedBuildInputs = [ avahi gmp ];

  meta = with lib; {
    description = "Bindings to Avahi for GNU Guile";
    homepage = "https://www.nongnu.org/guile-avahi/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}

