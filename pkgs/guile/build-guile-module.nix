# A small function for easily building and wrapping Guile programs.
{ guile, stdenv, lib, pkg-config, makeWrapper }:

{ propagatedBuildInputs ? [ ], buildInputs ? [ ]
, nativeBuildInputs ? [ ], propagatedNativeBuildInputs ? [ ]
, passthru ? {}, meta ? {}, ... } @ args:

let
  modules = propagatedNativeBuildInputs ++ propagatedBuildInputs;
  guileVersion = lib.versions.majorMinor guile.version;
in
stdenv.mkDerivation (args // {
  inherit nativeBuildInputs propagatedBuildInputs guileVersion;

  setupHook = ./setup-hook.sh;
  buildInputs = [ makeWrapper ] ++ buildInputs;
  propagatedNativeBuildInputs = [ guile ] ++ propagatedNativeBuildInputs;

  passthru = passthru // { inherit guile; };

  meta = {
    platforms = lib.platforms.all;
  } // meta;
})
