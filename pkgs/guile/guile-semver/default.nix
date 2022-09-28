{ buildGuileModule, lib, fetchurl, guile_3_0, libgcrypt, autoreconfHook, pkg-config, texinfo }:

buildGuileModule rec {
  pname = "guile-semver";
  version = "0.1.1";

  src = fetchurl {
    url = "https://files.ngyro.com/guile-semver/${pname}-${version}.tar.gz";
    sha256 = "sha256-T3kJGTdf6yBKjqLtqSopHZu03kyOscZ3Z4RYmoYlN4E=";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config texinfo ];
  doCheck = true;

  meta = with lib; {
    description =
      "A GNU Guile library implementing Semantic Versioning 2.0.0";
    homepage = "https://ngyro.com/software/guile-semver.html";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [ foo-dogsquared ];
  };
}
