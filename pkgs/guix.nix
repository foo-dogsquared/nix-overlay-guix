{ stdenv
, pkgs
, lib
, fetchgit
, pkg-config
, makeWrapper
, guile_3_0
, guile-lib
, git
, guilePackages
, help2man
, zlib
, bzip2
, autoconf-archive
, autoreconfHook
, graphviz
, texinfo
, locale
, perlPackages
, gettext
, glibcLocalesUtf8
, storeDir ? null
, stateDir ? "/var"
}:

# We're using Guile 3.0 especially that 1.4.0 is nearing as of updating this
# package definition.
stdenv.mkDerivation rec {
  pname = "guix";
  version = "2022-08-10";

  src = fetchgit {
    url = "https://git.savannah.gnu.org/git/guix.git";
    rev = "59ee837d8b11d7d688045b601e8b240ccbdbe7c7";
    sha256 = "sha256-P2VLyfE+Ft+HwCnJR6eVROgHYwlLEvHMW0ME5o2KNY0=";
  };

  preAutoreconf = ''
    ./bootstrap
    sed -i '/guilemoduledir\s*=/s%=.*%=''${out}/share/guile/site%' configure.ac
    sed -i '/guileobjectdir\s*=/s%=.*%=''${out}/share/guile/ccache%' configure.ac
  '';

  # Take note all of the modules here should have Guile 3.x. If it's compiled
  # with Guile 2.x, override the package to use the updated version.
  modules = with guilePackages;
    lib.forEach [
      bytestructures
      guile-avahi
      guile-gcrypt
      guile-git
      guile-gnutls
      guile-json
      guile-lzlib
      guile-semver
      guile-sqlite3
      guile-ssh
      guile-zlib
      guile-zstd
      guile3-lib
    ]
      (m: m.out);

  nativeBuildInputs = [
    pkg-config
    glibcLocalesUtf8
    makeWrapper
    gettext
    autoreconfHook
  ];

  buildInputs = [
    zlib
    bzip2
    git
    help2man
    autoconf-archive
    graphviz
    texinfo
    locale
    perlPackages.Po4a
  ] ++ modules;

  propagatedBuildInputs = [ guile_3_0 ];

  # For more information, see the respective manual for Guile modules. We're
  # also going to use this later on to wrap Guix with the resulting
  # environment.
  GUIX_LOCPATH = "${glibcLocalesUtf8}/lib/locale";
  GUILE_LOAD_PATH =
    let
      guilePath = [
        "\${out}/share/guile/site"
      ] ++ (lib.concatMap
        (module: [
          "${module}/share/guile/site"
          "${module}/share/guile"
          "${module}/share"
        ])
        modules);
    in
    "${lib.concatStringsSep ":" guilePath}";

  GUILE_LOAD_COMPILED_PATH =
    let
      guilePath = [
        "\${out}/share/guile/ccache"
      ] ++ (lib.concatMap
        (module: [
          "${module}/share/guile/ccache"
          "${module}/share/guile/site" # Some Nix packages with Guile modules simply combine all of the outputs.
          "${module}/share/guile" # If ever they put it there, I'm close to being crazy.
          "${module}/share" # NOW, I'M CRAZY!
        ])
        modules);
    in
    "${lib.concatStringsSep ":" guilePath}";

  configureFlags = [ ]
    ++ lib.optional (storeDir != null) "--with-store-dir=${storeDir}"
    ++ lib.optional (stateDir != null) "--localstatedir=${stateDir}";

  postInstall = ''
    wrapProgram $out/bin/guix \
      --prefix GUILE_LOAD_PATH : "${GUILE_LOAD_PATH}" \
      --prefix GUILE_LOAD_COMPILED_PATH : "${GUILE_LOAD_COMPILED_PATH}"

    wrapProgram $out/bin/guix-daemon \
      --prefix GUILE_LOAD_PATH : "${GUILE_LOAD_PATH}" \
      --prefix GUILE_LOAD_COMPILED_PATH : "${GUILE_LOAD_COMPILED_PATH}"
  '';

  passthru = { inherit guile_3_0; };

  meta = with lib; {
    description =
      "A transactional package manager for an advanced distribution of the GNU system";
    homepage = "https://guix.gnu.org/";
    license = licenses.gpl3;
    platforms = platforms.linux;
  };
}
