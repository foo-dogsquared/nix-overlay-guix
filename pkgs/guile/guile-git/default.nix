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

  doCheck = true;
  nativeBuildInputs = [ autoreconfHook pkg-config texinfo ];
  propagatedBuildInputs = [ libgit2 bytestructures ];

  # Skipping proxy tests since it requires network access.
  postPatch = ''
    sed -i -e '94i (test-skip 1)' ./tests/proxy.scm
  '';

  makeFlags = [ "GUILE_AUTO_COMPILE=0" ];

  meta = with lib; {
    description = "Bindings to Libgit2 for GNU Guile";
    homepage = "https://gitlab.com/guile-git/guile-git";

    # It's a mixed bag of modules licensed under different licenses. You'll
    # have to refer to individual modules to see the exact details.
    license = with licenses; [ gpl3Plus lgpl3Plus publicDomain ];

    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
