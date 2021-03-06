{pkgs}:

(pkgs.emacsPackagesNgGen pkgs.emacsGit).emacsWithPackages
  (epkgs: with epkgs; [
    async
    buttercup
    counsel
    company
    company-box
    company-lsp
    dashboard
    docker
    docker-tramp
    eshell-syntax-highlighting
    use-package
    haskell-mode
    helm-tramp
    elm-mode
    (epkgs.melpaBuild {
      pname = "explain-pause-mode";
      version = "0.1";

      src = fetchGit {
        url = "https://github.com/lastquestion/explain-pause-mode.git";
        rev = "2356c8c3639cbeeb9751744dbe737267849b4b51";
      };

      recipe = pkgs.writeText "explain-pause-mode-recipe" ''
      (explain-pause-mode :fetcher git
                  :url "https://github.com/lastquestion/explain-pause-mode.git"
                  :files (:defaults))
    '';
    })

    # TODO My package is incorrect somehow...
    # (epkgs.melpaBuild {
    #   pname = "helm-clubhouse";
    #   version = "0.1";

    #   src = fetchGit {
    #     url = "https://git.sr.ht/~codygman/helm-clubhouse";
    #     rev = "94d0845ec61716639f890b333429d6b8b7e62e5a";
    #   };

    #   recipe = pkgs.writeText "helm-clubhouse-recipe" ''
    #   (helm-clubhouse :fetcher git
    #               :url "https://git.sr.ht/~codygman/helm-clubhouse"
    #               :files (:defaults))
    # '';
    # })

    exwm
    exwm-edit
    # https://github.com/emacs-evil/evil/pull/1404
    (epkgs.melpaBuild {
      pname = "evil";
      version = "0.1";

      src = fetchGit {
        url = "https://github.com/codygman/evil.git";
        ref = "fix-obsolete-function-alias";
        rev = "f009995ba1494581ff44831086e0a8d190ca24ed";
      };

      recipe = pkgs.writeText "evil-recipe" ''
      (evil :fetcher git
                  :url "https://github.com/codygman/evil.git"
                  :files (:defaults))
    '';
    })
    evil-magit
    evil-org
    evil-collection
    ( keyfreq.override (args: {
      melpaBuild = drv: args.melpaBuild (drv // {
        src = pkgs.fetchFromGitHub {
          owner = "dacap";
          repo = "keyfreq";
          rev = "e5fe9d585ce882f1ba9afa5d894eaa82c79be4f4";
          sha256 = "12m1jy8m8i39b809qbxx9g3r066jxhqwfyf5mqbd1lzlaw63b1i7";
        };
      });
    }) )
    ( forge.override (args: {
      melpaBuild = drv: args.melpaBuild (drv // {
        src = pkgs.fetchFromGitHub {
          owner = "magit";
          repo = "forge";
          rev = "2c487465d0b78ffe34252b47fcc06e27039330c4";
          sha256 = "08c44ljvni2rr8d8ph3rzw7qrj7czx94m50bx455d8vv0snx0sv6";
        };
      });
    }) )
    helm
    helm-projectile
    ( helm-rg.override (args: {
      melpaBuild = drv: args.melpaBuild (drv // {
        src = pkgs.fetchFromGitHub {
          owner = "cosmicexplorer";
          repo = "helm-rg";
          rev = "ee0a3c09da0c843715344919400ab0a0190cc9dc";
          sha256 = "0m4l894345n0zkbgl0ar4c93v8pyrhblk9zbrjrdr9cfz40bx2kd";
        };
      });
    }) )
    helm-swoop
    ivy
    ( lsp-mode.override (args: {
      melpaBuild = drv: args.melpaBuild (drv // {
        src = pkgs.fetchFromGitHub {
          owner = "emacs-lsp";
          repo = "lsp-mode";
          rev = "3aad14064cccf530ff58ffc4263bd99de44e9fe1";
          sha256 = "0w5plh0z6x1pijw3g05lz7p69jm49yay8iw86scb7d00fsmnci3s";
        };
      });
    }) )
    ( lsp-haskell.override (args: {
      melpaBuild = drv: args.melpaBuild (drv // {
        src = pkgs.fetchFromGitHub {
          owner = "emacs-lsp";
          repo = "lsp-haskell";
          rev = "17d7d4c6615b5e6c7442828720730bfeda644af8";
          sha256 = "1kkp63ppmi3p0p6qkfpkr8p5cx8qggmsj73dwphv90mdq0nrfsx8";
        };
      });
    }) )
    ( lsp-ui.override (args: {
      melpaBuild = drv: args.melpaBuild (drv // {
        src = pkgs.fetchFromGitHub {
          owner = "emacs-lsp";
          repo = "lsp-ui";
          rev = "7d5326430eb88a58e111cb22ffa42c7d131e5052";
          sha256 = "1f2dxxajckwqvpl8cxsp019404sncllib5z2af0gzs7y0fs7b2dq";
        };
      });
    }) )
    magit
    nix-mode
    ob-async
    ob-restclient
    ox-gfm
    pdf-tools
    direnv
    doom-themes
    flycheck
    flycheck-haskell
    general
    olivetti
    org-roam
    org-reverse-datetree
    projectile

    rjsx-mode
    add-node-modules-path
    prettier-js


    unicode-fonts
    ts
    wgrep
    wgrep-helm
    with-simulated-input
    which-key
    yasnippet
  ])
