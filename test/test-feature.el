(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "GITHUB_WORKSPACE"))
      (format "~/hci/%s" path)
    (let ((github-workspace (getenv "GITHUB_WORKSPACE")))
      (progn (message (format "emacs-d-directory-for: GITHUB_WORKSPACE is %s" github-workspace)) (format "%s/%s" github-workspace path)))))


(describe
 "Codygman's hci"

 (describe "Set a baseline with simple tests"

	   (it "emacs version should be 28.0.50"
	       (expect emacs-version :to-equal "28.0.50"))

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

 (describe "Specific modes"


	   )

 (describe "Ironing out odd issues I run into"

	   ;; I think any evil tests require `tests-run` (see my-tests.el or evil repos tests)

	   )
 )

