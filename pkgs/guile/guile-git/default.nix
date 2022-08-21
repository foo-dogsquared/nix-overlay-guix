{ buildGuileModule
, lib
, fetchFromGitLab
, libgit2
, bytestructures
, autoreconfHook
, pkg-config
, texinfo
}:

buildGuileModule rec {
  pname = "guile-git";
  version = "0.5.2";

  src = fetchFromGitLab {
    owner = "guile-git";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-x6apF9fmwzrkyzAexKjClOTFrbE31+fVhSLyFZkKRYU=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config texinfo ];
  propagatedBuildInputs = [ libgit2 bytestructures ];

  meta = with lib; {
    description = "Bindings to Libgit2 for GNU Guile";
    homepage = "https://gitlab.com/guile-git/guile-git";
    license = licenses.gpl3;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
