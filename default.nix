with (import <nixpkgs> {}); let
  env = bundlerEnv {
    name = "DigiCARES";
    inherit ruby;
    gemfile = ./Gemfile;
    lockfile = ./Gemfile.lock;
    gemset = ./gemset.nix;
  };
in stdenv.mkDerivation {
  name = "DigiCARES";
  buildInputs = [env ruby];

  shellHook = ''
    exec ${env}/bin/jekyll serve --watch
  '';
}

