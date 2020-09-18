{ pkgs, stdenv, lib, fetchFromGitHub, buildGoPackage
# Dependencies
, git, shared, go, androidPkgs
# metadata and status-go source
, meta, source
# build parameters
, platform ? "android"
, arch ? "386"
, api ? "23" }:

let
  ldArchMap = {
    "386" = "x86";
    "arm" = "arm";
    "arm64" = "arm64";
  };

  #statusGoBuild = shared.${lib.getAttr arch ldArchMap};
in stdenv.mkDerivation rec {
  name = "nim-status"; # TODO: use pname and version

  src = fetchFromGitHub {
    owner = "status-im";
    repo = "nim-status";
    name = "nim-status";
    rev = "28fe902cb653def14b75ad6f709d43101eaff66a";
    sha256 = "1jbhq1ik67fmqqrq4mv8s3lhdn3phm2hz0f5k4dav75qrdzz6kxv";
    fetchSubmodules = true;
  };

  buildInputs = with pkgs; [ git coreutils findutils gnugrep gnumake gcc nim ];
  phases = [ "unpackPhase" "buildPhase" "installPhase" ];

  ANDROID_HOME = androidPkgs;
  ANDROID_NDK_HOME = "${androidPkgs}/ndk-bundle";
  USE_SYSTEM_NIM = 1;

  buildPhase = ''
    nim c \
      --app:staticLib \
      --warnings:off \
      --header \
      --noMain \
      --nimcache:nimcache/nim_status \
      -o:build/libnim_status.a \
      src/nim_status.nim
  '';
  installPhase = ''
    mkdir -p $out
    mv nimcache/nim_status/nim_status.h $out/
    mv libnim_status.a $out/
  '';
}
