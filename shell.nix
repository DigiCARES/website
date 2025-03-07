{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.ruby
    pkgs.bundler
    pkgs.jekyll
    pkgs.rubyPackages.sass
    pkgs.nodejs
  ];

  shellHook = ''
    echo "Jekyll development environment ready!"
    echo "Ruby version: $(ruby --version)"
    echo "Bundler version: $(bundler --version)"

    exec nu
  '';
}

