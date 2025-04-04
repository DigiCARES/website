{ pkgs ? import <nixpkgs> {} }:

let
  gems = pkgs.bundlerEnv {
    ruby = pkgs.ruby;
    name = "shell";
    gemdir = ./.;
  };
in
pkgs.mkShell {
  buildInputs = [
    gems
    pkgs.ruby
  ];

  shellHook = ''
    echo "Jekyll development environment ready!"
    echo "Ruby version: $(ruby --version)"
    echo "Bundle version: $(bundle --version)"

    exec nu
  '';
}

