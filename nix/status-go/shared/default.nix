{ callPackage
, meta, source }:

{
  x86 = callPackage ./build.nix {
    inherit meta source;
    platform = "android";
    arch = "386";
  };
  armeabi = callPackage ./build.nix {
    inherit meta source;
    platform = "androideabi";
    arch = "arm";
  };
  arm64 = callPackage ./build.nix {
    inherit meta source;
    platform = "android";
    arch = "arm64";
  };
}
