{ newScope, meta, source, shared
, stdenv
, lib }:
let
  inherit (lib) getAttr;
  callPackage = newScope { inherit meta source shared; };
  androidAbiMap = {
    "386" = "x86";
    "arm" = "armeabi-v7a";
    "arm64" = "arm64-v8a";
  };
in rec {
  android = {
    x86 = callPackage ./build.nix { platform = "android"; arch = "386"; };
    arm = callPackage ./build.nix { platform = "androideabi"; arch = "arm"; };
    arm64 = callPackage ./build.nix { platform = "android"; arch = "arm64"; };
  };

  ios = {
    x86 = callPackage ./build.nix { platform = "ios"; arch = "386"; };
    arm = callPackage ./build.nix { platform = "ios"; arch = "arm"; };
    arm64 = callPackage ./build.nix { platform = "ios"; arch = "arm64"; };
  };

  android-all = stdenv.mkDerivation {
    name = "status-go.nim-status.android-all";
    phases = [ "symlinkPhase" ];
    symlinkPhase = ''
      mkdir -p $out
      ln -s ${android.x86} $out/${getAttr "386" androidAbiMap}
      ln -s ${android.arm64} $out/${getAttr "arm64" androidAbiMap}
    '';
  };
}

