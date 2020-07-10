args@{ stdenv, lib, fetchFromGitHub, buildGoPackage
# Dependencies
  ,git
  ,shared
  ,pkgs
  ,nim-status-clone
, go, androidPkgs
# metadata and status-go source
, meta, source
# build parameters
, platform ? "android"
, arch ? "386"
, api ? "23" }:
with pkgs;
let
  inherit (lib) attrNames getAttr strings concatStringsSep concatMapStrings;
  ANDROID_HOME = androidPkgs;
  ANDROID_NDK_HOME = "${androidPkgs}/ndk-bundle";
  # nimStatusSrc = fetchFromGitHub rec {
  #    repo = "nim-status";
  #    name = "nim-status";
  #    rev = "28fe902cb653def14b75ad6f709d43101eaff66a";
  #    fetchSubmodules = true;
  #    owner = "status-im";
  #    sha256 = "0xkv8a9vzg30hw556l7nk3dl3s2hrjisqa4l942jq4yy1img8kbv";
  #  };
  ldArchMap = {
    "386" = "x86";
    "arm" = "arm";
    "arm64" = "arm64";
  };

  statusGoBuild = shared.${getAttr arch ldArchMap};

  bintools = binutils.bintools;
  # Shorthands for the built phase
in stdenv.mkDerivation rec {
  name = "nim-status";
  src = nim-status-clone;
  inherit git bintools coreutils findutils gnugrep gnumake gcc nim;
  builder = pkgs.writeText "builder.sh" ''
    cd $nim-status-clone
    export PATH=$nim/bin:$gnugrep/bin:$findutils/bin:$gcc/bin:$bash/bin:$git/bin:$gnumake/bin:$coreutils/bin:$bintools/bin:$PATH
    export USE_SYSTEM_NIM=1
    export MAKE=$gnumake/bin/make
    cd nim-status
    git checkout feature/status-react-support
    nim c --app:staticLib --warnings:off --header --noMain --nimcache:nimcache/nim_status -o:build/libnim_status.a src/nim_status.nim 
		cp nimcache/nim_status/nim_status.h build/.
		mv libnim_status.a build/.
  '';
}
