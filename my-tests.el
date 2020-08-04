(require 'ert)

;; duplicate in init.el
(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "GITHUB_WORKSPACE"))
      (format "~/hci/%s" path)
    (let ((github-workspace (getenv "GITHUB_WORKSPACE")))
      (progn (message (format "emacs-d-directory-for: GITHUB_WORKSPACE is %s" github-workspace)) (format "%s/%s" github-workspace path)))))

(defun log (msg)
  (append-to-file (format "%s\n" msg) nil "test-results.txt"))

(defun tests-run ()
  (setq attempt-stack-overflow-recovery nil
	attempt-orderly-shutdown-on-fatal-signal nil
	debug nil
	)
  (unwind-protect
      (progn
	(ert-run-tests-interactively t)
	(with-current-buffer "*ert*"
	  (append-to-file (point-min) (point-max) "test-results.txt")
	  (when (not debug) (kill-emacs (if (zerop (ert-stats-completed-unexpected ert--results-stats)) 0 1)))))
    (unwind-protect
	(progn
	  (append-to-file "Error running tests\n" nil "test-results.txt")
	  (append-to-file (backtrace-to-string (backtrace-get-frames 'backtrace)) nil "test-results.txt"))
      (when (not debug) (kill-emacs 2))))

  )
(ert-deftest use-package-installed ()
  (should (fboundp 'use-package)))

(ert-deftest evil-installed ()
  (should (fboundp 'evil-next-line)))

(ert-deftest evil-collection-installed ()
  (should (fboundp 'evil-collection-init)))

;; evil
(ert-deftest ctrl-u-scrolls-up ()
  (find-file (emacs-d-directory-for "testdata/loremipsum.txt"))
  (execute-kbd-macro (kbd "G"))
  (execute-kbd-macro (kbd "C-u"))
  (log "ctrl-u-scrolls-up passed"))
