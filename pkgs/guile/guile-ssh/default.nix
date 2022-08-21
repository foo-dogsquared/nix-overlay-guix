{ stdenv
, lib
, fetchFromGitHub
, guile_3_0
, libssh
, autoreconfHook
, pkg-config
, texinfo
, which
}:

stdenv.mkDerivation rec {
  pname = "guile-ssh";
  version = "0.15.1";

  src = fetchFromGitHub {
    owner = "artyom-poptsov";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-+BhyaBieqMwTgsSLci3HJdCrNQmfPN/jK2Od5DQs9n8=";
  };

  configureFlags = [
    "--with-guilesitedir=\${out}/share/guile/site/ssh"
  ];

  postConfigure = ''
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site/ssh%' modules/ssh/Makefile;
    sed -i '/godir\s*=/s%=.*%=''${out}/share/guile/ccache/ssh%' modules/ssh/Makefile;
    sed -i '/moddir\s*=/s%=.*%=''${out}/share/guile/site/ssh/dist%' modules/ssh/dist/Makefile;
    sed -i '/godir\s*=/s%=.*%=''${out}/share/guile/ccache/ssh/dist%' modules/ssh/dist/Makefile;
    sed -i '/ccachedir\s*=/s%=.*%=''${out}/share/guile/ccache/ssh%' tests/Makefile;
  '';

  postFixup = ''
    for f in $(find $out/share/guile/site -name '*.scm'); do \
      substituteInPlace $f \
        --replace "libguile-ssh" "$out/lib/libguile-ssh"; \
    done
  '';

  nativeBuildInputs = [ autoreconfHook pkg-config texinfo which ];
  buildInputs = [ guile_3_0 ];
  propagatedBuildInputs = [ libssh ];

  meta = with lib; {
    description = "Bindings to Libssh for GNU Guile";
    homepage = "https://github.com/artyom-poptsov/guile-ssh";
    license = licenses.gpl3;
    maintainers = with maintainers; [ bqv ];
    platforms = platforms.all;
  };
}

