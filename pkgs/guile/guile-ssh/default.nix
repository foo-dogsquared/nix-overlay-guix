{ buildGuileModule
, lib
, fetchFromGitHub
, libssh
, autoreconfHook
, pkg-config
, texinfo
, which
}:

buildGuileModule rec {
  pname = "guile-ssh";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "artyom-poptsov";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-+BhyaBieqMwTgsSLci3HJdCrNQmfPN/jK2Od5DQs9n8=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config texinfo which ];
  propagatedBuildInputs = [ libssh ];

  configureFlags = [
    "--disable-static"
  ];

  postInstall = ''
    mv $out/bin/*.scm $out/share/guile-ssh
    rmdir $out/bin
  '';

  meta = with lib; {
    description = "Bindings to Libssh for GNU Guile";
    homepage = "https://github.com/artyom-poptsov/guile-ssh";
    license = licenses.gpl3;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}

