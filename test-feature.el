(describe
 "Codygman's hci"

 (describe "Set a baseline with simple tests"

           (it "emacs version should be 28.0.50"
               (expect emacs-version :to-equal "28.0.50"))
           )

 (describe "Haskell Integration"

           (it "haskell mode is active after opening a haskell file"
               (find-file (emacs-d-directory-for "testdata/simple-haskell-project/Main.hs"))
               (expect 'haskell-mode :to-equal (derived-mode-p 'haskell-mode))
               )

           )

 (describe "Evil Integration"
           ;; I think any evil tests require `tests-run` (see my-tests.el or evil repos tests)
           ;; (it "evil is enabled"
           ;;     (expect (fboundp 'evil-next-line) :to-be t))
           ;; )

           (it "evil collection is installed"
               (expect (fboundp 'evil-collection-init) :to-be t))

           ;; (it "evil collection is enabled"
           ;;     (expect 'evil-collection :to-equal (derived-mode-p 'evil-collection)))

           (it "evil collection is enabled"
	       (expect evil-collection-unimpaired-mode :to-be t))
           )

 )
