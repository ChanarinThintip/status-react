{ newScope, meta, source, shared }:

let
  callPackage = newScope { inherit meta source shared; };
in {
  android = {
    x86 = callPackage ./build.nix { platform = "android"; arch = "386"; };
    armeabi = callPackage ./build.nix { platform = "androideabi"; arch = "arm"; };
    arm64 = callPackage ./build.nix { platform = "android"; arch = "arm64"; };
  };

  ios = {
    x86 = callPackage ./build.nix { platform = "ios"; arch = "386"; };
    armeabi = callPackage ./build.nix { platform = "ios"; arch = "arm"; };
    arm64 = callPackage ./build.nix { platform = "ios"; arch = "arm64"; };
  };
}
