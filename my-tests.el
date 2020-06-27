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

;; TODO test for "jf" escape working
;; TODO test for "Ctrl u" working

(defun copy-line (arg)
  "Copy lines (as many as prefix argument) in the kill ring"
  ;; (interactive "p")
  (kill-ring-save (line-beginning-position)
                  (line-beginning-position (+ 1 arg)))
  (message "%d line%s copied" arg (if (= 1 arg) "" "s")))

(require 'subr-x)

(defun my-append-string-to-file (s filename)
  (with-temp-buffer
    (insert s)
    (write-region (point-min) (point-max) filename t)))

(defun wait-for-ghci ()
  ;; TODO figure out how to maybe use haskell-mode-interactive-prompt-state
  (sit-for 2))

(ert-deftest ghci-has-locals-in-scope ()
  (interactive)
  (find-file (emacs-d-directory-for "testdata/simple-haskell-project/Main.hs"))
  (my-append-string-to-file "START load-file\n" "debug")
  (haskell-process-load-file)
  (wait-for-ghci)
  ;; (sit-for 5)
  ;; (sleep-for 5)
  (with-current-buffer "*simple-haskell-project*"
    (evil-append-line 1)
    (insert ":t functionWeWantInScope")
    (haskell-interactive-mode-return)
    (sleep-for 3)
    ;; (wait-for-ghci)
    (evil-previous-line 1)
    (copy-line 1))
  (should (string-equal
           (string-trim (substring-no-properties (nth 0 kill-ring)))
           "functionWeWantInScope :: ()")))
