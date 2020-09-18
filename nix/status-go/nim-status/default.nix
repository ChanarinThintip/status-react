{ callPackage, meta, source, shared }:

{
  android = {
    x86 = callPackage ./build.nix {
      inherit meta source shared;
      platform = "android";
      arch = "386";
    };
    armeabi = callPackage ./build.nix {
      inherit meta source shared;
      platform = "androideabi";
      arch = "arm";
    };
    arm64 = callPackage ./build.nix {
      inherit meta source shared;
      platform = "android";
      arch = "arm64";
    };
  };

  ios = {
    x86 = callPackage ./build.nix {
      inherit meta source shared;
      platform = "ios";
      arch = "386";
    };
    armeabi = callPackage ./build.nix {
      inherit meta source shared;
      platform = "ios";
      arch = "arm";
    };
    arm64 = callPackage ./build.nix {
      inherit meta source shared;
      platform = "ios";
      arch = "arm64";
    };
  };
}
