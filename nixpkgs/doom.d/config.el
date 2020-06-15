(setq user-full-name "Cody Goodman"
      user-mail-address "cody@codygman.dev"
      evil-escape-key-sequence "jf"
      doom-font (font-spec :family "Source Code Pro" :size 17)
      )


(setq
 flycheck-disabled-checkers '(haskell-stack-ghc haskell-ghc) ;; only allow lsp checker
 lsp-enable-file-watchers t ;; watch files for changes (replace ghcid functionality basically)
 )
