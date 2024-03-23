{ pkgs , unstable }:

let
  gitbutler-ui = pkgs.callPackage ./gitbutler-ui/package.nix { };
  gitbutler = pkgs.callPackage ./gitbutler/package.nix { inherit gitbutler-ui unstable; };
in
  gitbutler
