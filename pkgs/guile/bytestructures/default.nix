{ lib, buildGuileModule, fetchFromGitHub, autoreconfHook, pkg-config }:

buildGuileModule rec {
  pname = "scheme-bytestructures";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "TaylanUB";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-Wvs288K8BVjUuWvvzpDGBwOxL7mAXjVtgIwJAsQd0L4=";
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

