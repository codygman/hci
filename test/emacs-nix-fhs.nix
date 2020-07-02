let
  pkgs = import <nixpkgs> {};
in pkgs.buildFHSUserEnv {
  name = "fhs";
  targetPkgs = pkgs: [
    pkgs.emacs
  ];
}
