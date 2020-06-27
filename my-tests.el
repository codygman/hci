;; TODO checkout ert-expectations https://github.com/emacsorphanage/ert-expectations/blob/aed70e002c4305b66aed7f6d0d48e9addd2dc1e6/ert-expectations.el#L68
(defun tests-run ()
  "Run Evil tests."
  (interactive '(nil t))
  ;; We would like to use `ert-run-tests-batch-and-exit'
  ;; Unfortunately it doesn't work outside of batch mode, and we
  ;; can't use batch mode because we have tests that need windows.
  ;; Instead, run the tests interactively, copy the results to a
  ;; text file, and then exit with an appropriate code.
  (setq attempt-stack-overflow-recovery nil
        attempt-orderly-shutdown-on-fatal-signal nil)
  (unwind-protect
      (progn
        (ert-run-tests-interactively t)
        (with-current-buffer "*ert*"
          (append-to-file (point-min) (point-max) "test-results.txt")
          (kill-emacs (if (zerop (ert-stats-completed-unexpected ert--results-stats)) 0 1)))
        (unwind-protect
            (progn
              (append-to-file "Error running tests\n" nil "test-results.txt")
              (append-to-file (backtrace-to-string (backtrace-get-frames 'backtrace)) nil "test-results.txt"))
          (kill-emacs 2)))))

;; duplicate in init.el
(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "TRAVIS_OS_NAME"))
      (format "~/.emacs.d/%s" path)
    (getenv "TRAVIS_BUILD_DIR")))

(ert-deftest true-is-true ()
  (should t))

(ert-deftest version-check ()
  (should (string-equal "26.3" emacs-version)))

(ert-deftest use-package-installed ()
  (should (fboundp 'use-package)))

(ert-deftest evil-installed ()
  (should (fboundp 'evil-next-line)))

(ert-deftest evil-collection-installed ()
  (should (fboundp 'evil-collection-init)))

(ert-deftest magit-installed ()
  (should (fboundp 'magit-version)))

(ert-deftest haskell-mode-enabled-opening-haskell-file ()
  (find-file (emacs-d-directory-for "testdata/simple-haskell-project/Main.hs"))
  (should (eq 'haskell-mode (derived-mode-p 'haskell-mode))))
