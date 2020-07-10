{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  builderFile = pkgs.writeText "builder.sh" ''
    echo "Running"
    export PATH=$bash/bin:$git/bin:$PATH
    export GIT_SSL_NO_VERIFY=true
    git clone https://github.com/status-im/nim-status
    cd nim-status
    git checkout feature/status-react-support
    cd ..
    cp -r nim-status $out
  '';
in 
derivation {
  name = "nim-status-clone";
  # buildInputs = [git];
  inherit git;
  system = builtins.currentSystem;
  builder = "${bash}/bin/bash";
  args = [ "${builderFile}" ];
}
