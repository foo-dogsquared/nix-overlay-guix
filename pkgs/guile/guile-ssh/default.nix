{ buildGuileModule
, lib
, fetchFromGitHub
, fetchpatch
, libssh
, autoreconfHook
, pkg-config
, texinfo
, which
}:

buildGuileModule rec {
  pname = "guile-ssh";
  version = "0.16.0";

  src = fetchFromGitHub {
    owner = "artyom-poptsov";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-3h4U/h6cVgHTJOyliw1gTYtgzQcatRLX6NrP87JXRc0=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config texinfo which ];
  propagatedBuildInputs = [ libssh ];
  patches = [
    (fetchpatch {
      url = "https://github.com/artyom-poptsov/guile-ssh/pull/31.patch";
      sha256 = "sha256-J+TDgdjihKoEjhbeH+BzqrHhjpVlGdscRj3L/GAFgKg=";
    })
  ];

  doCheck = true;
  postInstall = ''
    mv $out/bin/*.scm $out/share/guile-ssh
    rmdir $out/bin
  '';

  meta = with lib; {
    description = "Bindings to Libssh for GNU Guile";
    homepage = "https://github.com/artyom-poptsov/guile-ssh";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}

