(setq user-full-name "Cody Goodman"
      user-mail-address "cody@codygman.dev"
      evil-escape-key-sequence "jf"
      doom-font (font-spec :family "Source Code Pro" :size 17)
      )


(setq
 flycheck-disabled-checkers '(haskell-stack-ghc haskell-ghc) ;; only allow lsp checker
 lsp-enable-file-watchers t ;; watch files for changes (replace ghcid functionality basically)

 ;;  see https://github.com/emacs-lsp/lsp-mode/issues/1815
 lsp-file-watch-threshold 2000          ;; This is okay hopefully?
 lsp-file-watch-ignored
 '("[/\\\\]\\.git"
   "[/\\\\]\\.hg"
   "[/\\\\]\\.bzr"
   "[/\\\\]_darcs"
   "[/\\\\]\\.svn"
   "[/\\\\]_FOSSIL_"
   "[/\\\\]\\.idea"
   "[/\\\\]\\.ensime_cache"
   "[/\\\\]\\.eunit"
   "[/\\\\]node_modules"
   "[/\\\\]\\.fslckout"
   "[/\\\\]\\.tox"
   "[/\\\\]\\.stack-work"
   "[/\\\\]\\.bloop"
   "[/\\\\]\\.metals"
   "[/\\\\]target"
   "[/\\\\]\\.ccls-cache"
   "[/\\\\]\\.deps"
   "[/\\\\]build-aux"
   "[/\\\\]autom4te.cache"
   "[/\\\\]\\.reference"

   "[/\\\\]\\.docker"
   "[/\\\\]dist-newstyle"
   "[/\\\\]dist"
   "[/\\\\]Documentation"
   "[/\\\\]containers"
   "[/\\\\]tf"
   "[/\\\\]\\.semaphore"
   "[/\\\\].*swp$"
   "\./nix/materialized"))
