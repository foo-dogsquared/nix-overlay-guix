{ lib, buildGuileModule, fetchFromGitHub, autoreconfHook, pkg-config }:

buildGuileModule rec {
  pname = "scheme-bytestructures";
  version = "1.0.10";

  src = fetchFromGitHub {
    owner = "TaylanUB";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-04oDvwvzTRzAVyywbcCm3Ug3p3xNbxjI7nOKYakEZZI=";
  };

  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];

  doCheck = true;
  nativeBuildInputs = [ autoreconfHook pkg-config ];

  meta = with lib; {
    description = "Structured access to bytevector contents";
    homepage = "https://github.com/TaylanUB/scheme-bytestructures";
    license = licenses.gpl3;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}

