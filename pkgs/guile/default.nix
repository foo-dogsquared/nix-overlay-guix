{ lib, newScope, overrides ? (self: super: { }) }:

let
  packages = self:
    let
      callPackage = newScope self;
    in
    lib.recurseIntoAttrs {
    };
in
lib.fix' (lib.extends overrides packages)
