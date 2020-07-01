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

 )
