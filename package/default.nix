{ stdenv, pkgs, lib, fetchurl, pkg-config, makeWrapper, zlib, bzip2, guile
, guilePackages, storeDir ? null, stateDir ? null }:

stdenv.mkDerivation rec {
  pname = "guix";
  version = "1.2.0";

  src = fetchurl {
    url = "mirror://gnu/guix/${pname}-${version}.tar.gz";
    sha256 = "sha256-Xs33ztJbH7DKfFfnlLe2DIp63LFSYd7CrzeSXIOMbXQ=";
  };

  postConfigure = ''
    sed -i '/guilemoduledir\s*=/s%=.*%=''${out}/share/guile/site%' Makefile;
    sed -i '/guileobjectdir\s*=/s%=.*%=''${out}/share/guile/ccache%' Makefile;
  '';

  modules = with guilePackages;
    lib.forEach [
      guile-gcrypt
      guile-git
      guile-json
      guile-lzlib
      guile-sqlite3
      guile-ssh
      guile-gnutls
      guile-zlib
      bytestructures
    ] (m: (m.override { inherit guile; }).out);

  nativeBuildInputs = [ pkg-config makeWrapper ];
  buildInputs = [ zlib bzip2 ] ++ modules;
  propagatedBuildInputs = [ guile ];

  GUILE_LOAD_PATH = let
    guilePath = [
      "\${out}/share/guile/site"
      "${guilePackages.guile-gnutls.out}/lib/guile/extensions"
    ] ++ (lib.concatMap (module: [ "${module}/share/guile/site" ]) modules);
  in "${lib.concatStringsSep ":" guilePath}";
  GUILE_LOAD_COMPILED_PATH = let
    guilePath = [
      "\${out}/share/guile/ccache"
      "${guilePackages.guile-gnutls.out}/lib/guile/extensions"
    ] ++ (lib.concatMap (module: [ "${module}/share/guile/ccache" ]) modules);
  in "${lib.concatStringsSep ":" guilePath}";

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

  passthru = { inherit guile; };

  meta = with lib; {
    description =
      "A transactional package manager for an advanced distribution of the GNU system";
    homepage = "https://guix.gnu.org/";
    license = licenses.gpl3;
    maintainers = with maintainers; [ bqv ];
    platforms = platforms.linux;
  };
}
