with import <nixpkgs> {};

stdenv.lib.overrideDerivation (pkgs.emacs.override {
  srcRepo = true;
  withXwidgets = if (stdenv.isDarwin || "TRAVIS_OS_NAME" != "") then false else true;
}) (attrs: rec {
  name = "emacs-${version}${versionModifier}";
  imagemagick = if (builtins.getEnv "TRAVIS_OS_NAME" == "") then pkgs.imagemagickBig else null;
  version = "27.0";
  versionModifier = ".50";

  doCheck = false;

  patches = null;

  configureflags = attrs.configureFlags ++ [
    "--with-harfbuzz"
    "--with-json"
  ];

  buildInputs = attrs.buildInputs ++ [
    harfbuzz
    jansson
  ];

  src = fetchFromGitHub {
    owner = "emacs-mirror";
    repo = "emacs";
    rev = "9cd3b50ca869e6a91668eb8bbc2a44617294b85c";
    sha256 = "0xdpyy04mik1bsib0x894gi1ib1w40s019kzqfvjjmqgsbvi7a9a";
  };
})
