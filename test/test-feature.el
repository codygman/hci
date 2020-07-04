
(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "GITHUB_WORKSPACE"))
      (format "~/.emacs.d/%s" path)
    (let ((github-workspace (getenv "GITHUB_WORKSPACE")))
      (progn (message (format "emacs-d-directory-for: GITHUB_WORKSPACE is %s" github-workspace)) (format "%s/%s" github-workspace path)))))


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

	   )

 (describe "Magit Integration"

	   ;; I think any evil tests require `tests-run` (see my-tests.el or evil repos tests)
	   (it "C-d scrolls down in magit status buffer"
	       (expect
		(execute-kbd-macro (kbd "C-d"))
		:not :to-throw ))

	   )


 (describe "Window Navigation"

	   ;; I think any evil tests require `tests-run` (see my-tests.el or evil repos tests)
	   (it "split 4 windows and move through them clockwise with =SPC {h,j,k,l}="
	       (expect
		;; NOTE this test didn't work because of "window too small"
		;; I don't know if the height/width of the emacs -batch
		;; command is machine specific
		;; so if this fails in CI, on a new computer, different os, etc
		;; look here first
		(let ((split-width-threshold nil)
		      (split-height-threshold nil)
		      (window-min-height 1)
		      (window-min-width 1))
		  ;; setup
		  ;; fullscreen just so we have enough room
		  (execute-kbd-macro (kbd "SPC w v"))
		  (execute-kbd-macro (kbd "SPC w s"))
		  (execute-kbd-macro (kbd "SPC w l"))
		  (execute-kbd-macro (kbd "SPC w s"))
		  ;; return to top left
		  (execute-kbd-macro (kbd "SPC w h"))
		  ;; clockwise
		  (execute-kbd-macro (kbd "SPC w l"))
		  (execute-kbd-macro (kbd "SPC w j"))
		  (execute-kbd-macro (kbd "SPC w h"))
		  (execute-kbd-macro (kbd "SPC w k"))
		  )
		:not :to-throw ))

	   )
 (describe "Ironing out odd issues I run into"

	   ;; I think any evil tests require `tests-run` (see my-tests.el or evil repos tests)
	   (it "SPC SPC is bound in magit buffers"
	       (expect
		;; (magit "~/hci")
		;; note if anything uses helm it will need to use the tests-run function!
		(execute-kbd-macro (kbd "SPC SPC RET"))
		:not :to-throw ))

	   )

 )
 
