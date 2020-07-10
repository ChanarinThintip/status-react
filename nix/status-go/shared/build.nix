{ stdenv, lib, fetchFromGitHub, buildGoPackage
# Dependencies
, go, androidPkgs
# metadata and status-go source
, meta, source
# build parameters
, platform ? "android"
, arch ? "386"
, api ? "23" }:

let
  inherit (lib) attrNames getAttr strings concatStringsSep concatMapStrings;

  removeReferences = [ go ];
  removeExpr = refs: ''remove-references-to ${concatMapStrings (ref: " -t ${ref}") refs}'';

  targetArchMap = rec {
    "386" = "i686";
    "arm" = "armv7a";
    "arm64" = "aarch64";
  };
  ldArchMap = {
    "386" = "x86";
    "arm" = "arm";
    "arm64" = "arm64";
  };

  # Shorthands for the built phase
  targetArch = getAttr arch targetArchMap;
  ldArch = getAttr arch ldArchMap;

in buildGoPackage rec {
  pname = source.repo;
  version = "${source.cleanVersion}-${source.shortRev}-${platform}-${arch}";

  inherit meta;
  inherit (source) src goPackagePath;

  nativeBuildInputs = [ go ];

  ANDROID_HOME = androidPkgs;
  ANDROID_NDK_HOME = "${androidPkgs}/ndk-bundle";

  preBuildPhase = ''
    cd go/src/${goPackagePath}
    mkdir -p ./statusgo-lib
    go run cmd/library/*.go > ./statusgo-lib/main.go
  '';

  buildPhase = ''
    runHook preBuildPhase
    echo "Building shared library..."

    # This can be done with stdenv.hostPlatform.system
    SYS_ARCH=$(echo $system | tr '-' '\n' | head -n1)
    SYS_NAME=$(echo $system | tr '-' '\n' | tail -n1)
    HOST_OS="$SYS_NAME-$SYS_ARCH"

    export GOOS=android GOARCH=${arch} API=${api}
    export TARGET=${targetArch}-linux-${platform}

    export ANDROID_LLVM_PREBUILT="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt"
    export CC=$ANDROID_LLVM_PREBUILT/$HOST_OS/bin/clang

    #export LIBRARY_PATH=$ANDROID_NDK_HOME/platforms/android-$API/arch-${ldArch}/usr/lib
    export CGO_CFLAGS="-isysroot $ANDROID_NDK_HOME/toolchains/llvm/prebuilt/$HOST_OS/sysroot -target $TARGET$API"
    export CGO_LDFLAGS="--sysroot $ANDROID_NDK_HOME/platforms/android-$API/arch-${ldArch} -target $TARGET -v -Wl,-soname,libstatus.so"
    export CGO_ENABLED=1

    echo "Building for target: $TARGET"
    go build \
      -buildmode=c-shared \
      -o ./libstatus.so \
      $BUILD_FLAGS \
      ./statusgo-lib

    echo "Shared library built:"
    ls -la ./libstatus.*
  '';

  fixupPhase = ''
    find $out -type f -exec ${removeExpr removeReferences} '{}' + || true
  '';

  installPhase = ''
    mkdir -p $out
    cp ./libstatus.* $out/
  '';

  outputs = [ "out" ];
}
