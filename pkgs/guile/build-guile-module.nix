# A small function for easily building and wrapping Guile programs.
{ guile, stdenv, lib, pkg-config, makeWrapper }:

{ propagatedBuildInputs ? [ ], buildInputs ? [ ]
, nativeBuildInputs ? [ ], propagatedNativeBuildInputs ? [ ]
, passthru ? {}, meta ? {}, ... } @ args:

let
  guileVersion = lib.versions.majorMinor guile.version;
in
stdenv.mkDerivation (args // {
  inherit propagatedNativeBuildInputs propagatedBuildInputs guileVersion;

  setupHook = ./setup-hook.sh;
  buildInputs = [ makeWrapper ] ++ buildInputs;
  nativeBuildInputs = [ guile ] ++ nativeBuildInputs;

  passthru = passthru // { inherit guile; };

  meta = {
    platforms = lib.platforms.all;
  } // meta;
})
