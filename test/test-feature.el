
(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "TRAVIS_OS_NAME"))
      (format "~/.emacs.d/%s" path)
    (getenv "TRAVIS_BUILD_DIR")))


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
	   (it "evil is enabled"
	       (expect (fboundp 'evil-next-line) :to-be t))

	   (it "evil collection is installed"
	       (expect (fboundp 'evil-collection-init) :to-be t))

	   (it "evil collection is enabled"
	       (expect global-evil-collection-unimpaired-mode :to-be-truthy))

	   (it "ctrl-u scrolls up"

	       (find-file (emacs-d-directory-for "testdata/loremipsum.txt"))
	       (execute-kbd-macro (kbd "G"))
	       (execute-kbd-macro (kbd "C-u"))
	       ;; NOTE this isn't perfectly accurate because for some reason emacs on command line when run with tests-run seems to scroll up a different number for.
	       ;; however, this test is proven by the position of the line number changing at all
	       ;; TODO figure out how to make this more exact
	       (expect (line-number-at-pos) :to-equal 13)
	       )

	   )

 )
