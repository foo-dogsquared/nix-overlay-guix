{ guile-lib, guile_3_0, pkg-config, autoreconfHook }:

(guile-lib.override { guile = guile_3_0; }).overrideAttrs (prev: {
  nativeBuildInputs = prev.nativeBuildInputs ++ [ pkg-config guile_3_0 autoreconfHook ];
  postPatch = ''
    sed -e '95s|$datadir/guile-lib|$datadir/guile/site|' \
        -e '96s|$libdir/guile-lib/guile|$libdir/guile|' \
        -i configure.ac
  '';
})
