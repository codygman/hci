(require 'ert)

;; duplicate in init.el
(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "GITHUB_WORKSPACE"))
      (format "~/hci/%s" path)
    (let ((github-workspace (getenv "GITHUB_WORKSPACE")))
      (progn (message (format "emacs-d-directory-for: GITHUB_WORKSPACE is %s" github-workspace)) (format "%s/%s" github-workspace path)))))


(defun log (msg)
  (append-to-file (format "%s\n" msg) nil "test-results.txt"))

(defun before-tests-init ()
  ;; add any lsp folders to workspace or tests will hang
   (lsp-workspace-folders-add (emacs-d-directory-for "testdata/haskell-nix-stack-workflow/"))
  )

(defun tests-run ()
  (setq attempt-stack-overflow-recovery nil
	attempt-orderly-shutdown-on-fatal-signal nil
	debug nil
	)
  (unwind-protect
      (progn
	(progn (before-tests-init) (ert-run-tests-interactively t))
	(with-current-buffer "*ert*"
	  (append-to-file (point-min) (point-max) "test-results.txt")
	  (when (not debug) (kill-emacs (if (zerop (ert-stats-completed-unexpected ert--results-stats)) 0 1)))))
    (unwind-protect
	(progn
	  (append-to-file "Error running tests\n" nil "test-results.txt")
	  (append-to-file (backtrace-to-string (backtrace-get-frames 'backtrace)) nil "test-results.txt"))
      (when (not debug) (kill-emacs 2))))

  )
  ;; We would like to use `ert-run-tests-batch-and-exit'
  ;; Unfortunately it doesn't work outside of batch mode, and we
  ;; can't use batch mode because we have tests that need windows.
  ;; Instead, run the tests interactively, copy the results to a
  ;; text file, and then exit with an appropriate code.
  ;; (setq elp-use-standard-output t
  ;; 	attempt-stack-overflow-recovery nil
  ;; 	attempt-orderly-shutdown-on-fatal-signal nil
  ;; 	debug t
  ;; 	debug-on-error t
  ;; 	)
  ;; (unwind-protect
  ;;     (progn
  ;; 	(progn (ert-run-tests-interactively t) (before-test-init))
  ;; 	(with-current-buffer "*ert*"
  ;; 	  (append-to-file (point-min) (point-max) "test-results.txt")
  ;; 	  (let ((failed-tests (ert-stats-completed-unexpected ert--results-stats)))
  ;; 	    ;; (log (format "failed tests: %s" (princ failed-tests)))
  ;; 	    ;; (log (format "zerop failed-tests ==  %s" (princ (zerop failed-tests))))
  ;; 	    (log "checking failed tests")
  ;; 	    (if (zerop failed-tests)
  ;; 		(progn (log "0 failed tests, exiting with code 0")
  ;; 		       (when (not debug) (kill-emacs 0)))
  ;; 	      (progn (log "at least 1 failed test, exiting with code 1")
  ;; 		     (when (not debug) (kill-emacs 1))))
  ;; 	    (log "done checking failed tests")

	    
	    
  ;; 	    )
  ;; 	  ))
  ;;   ;; (when (not debug) (kill-emacs 2))
  ;;   ;; TODO fix error reporting stuff
  ;;   (unwind-protect
  ;; 	(progn
  ;; 	  (log "Error running tests\n")
  ;; 	  (with-current-buffer "*ert*"
  ;; 	    (append-to-file
  ;; 	     (format "backtrace oo: %s"
  ;; 		     (princ (backtrace-get-frames 'backtrace))) nil
  ;; 		     "test-results.txt")

  ;; 	    ;; TODO fix wrong type argument numberp error
  ;; 	    ;; (log (backtrace-to-string (backtrace-get-frames 'backtrace)))
  ;; 	    (let ((backtrace-frames (backtrace-get-frames 'backtrace)))
  ;; 	      (when backtrace-frames
  ;; 		(append-to-file (princ backtrace-frames) nil "test-results.txt")
  ;; 		(append-to-file (backtrace-to-string backtrace-frames) nil "test-results.txt")
  ;; 		))
  ;; 	    )
  ;; 	  )
  ;;     (when (not debug) (kill-emacs 2))
  ;;     )
    ;; ))

(ert-deftest use-package-installed ()
  (should (fboundp 'use-package)))

(ert-deftest evil-installed ()
  (should (fboundp 'evil-next-line)))

(ert-deftest evil-collection-installed ()
  (should (fboundp 'evil-collection-init)))

(ert-deftest magit-installed ()
  (should (fboundp 'magit-version))
  (log "magit-installed passed"))

;;; haskell
(ert-deftest haskell-mode-enabled-opening-haskell-file ()
  (find-file (emacs-d-directory-for "testdata/simple-haskell-project/Main.hs"))
  (should (eq 'haskell-mode (derived-mode-p 'haskell-mode))))

;; ;; TODO test for "jf" escape working
;; ;; TODO test for "Ctrl u" working

(defun copy-line (arg)
  "Copy lines (as many as prefix argument) in the kill ring"
  ;; (interactive "p")
  (kill-ring-save (line-beginning-position)
                  (line-beginning-position (+ 1 arg)))
  (message "%d line%s copied" arg (if (= 1 arg) "" "s")))

;; (require 'subr-x)

;; (defun my-append-string-to-file (s filename)
;;   (log "my-append-string-to-file")
;;   (with-temp-buffer
;;     (insert s)
;;     (write-region (point-min) (point-max) filename t)))

(defun wait-for-ghci (action expected-output-rgx max-ghci-wait)
  ;; TODO figure out how to maybe use haskell-mode-interactive-prompt-state 
  (log (format "start waiting for ghci at %s" (current-time-string)))
  (goto-char (point-max))
  (evil-append-line 1)
  (insert "1")
  (haskell-interactive-mode-return)
  (log (format "max timeout for %s is %d" action max-ghci-wait))
  (with-timeout (max-ghci-wait (error "action '%s' took more than %.1f seconds in ghci '%s'" action max-ghci-wait (buffer-name)))
    (while (not (re-search-backward expected-output-rgx nil t))
      (goto-char (point-max))
      (sit-for 0.1)
      )
    ) 
  (log (format "ghci ready at %s" (current-time-string)))
  (sit-for 3)
  (goto-char (point-max))
  
  )

(ert-deftest ghci-has-locals-in-scope ()
  (interactive)
  (find-file (emacs-d-directory-for "testdata/simple-haskell-project/Main.hs"))
  ;; (my-append-string-to-file "START load-file\n" "debug")
  (haskell-process-load-file)
  (with-current-buffer "*simple-haskell-project*"
    (wait-for-ghci "initial load" "^1$" 15)
    (evil-append-line 1)
    (insert ":t functionWeWantInScope")
    (haskell-interactive-mode-return)
    (wait-for-ghci ":t functionWeWantInScope" "^func.+)$" 5)
    (evil-previous-line 1)
    (copy-line 1))
  (should (string-equal
           (string-trim (substring-no-properties (nth 0 kill-ring)))
           "functionWeWantInScope :: ()")))

;; evil
(ert-deftest ctrl-u-scrolls-up ()
  (find-file (emacs-d-directory-for "testdata/loremipsum.txt"))
  (execute-kbd-macro (kbd "G"))
  (execute-kbd-macro (kbd "C-u"))
  (log "ctrl-u-scrolls-up passed"))


(require 'cl) ;; TODO necessary?
(defun kill-all-buffers-except-ert ()
    "Kill all other buffers."
    (interactive)
    (mapc 'kill-buffer
          (delq (current-buffer)
                (remove-if-not (lambda (x) (string-equal "*ert*" (buffer-file-name))) (buffer-list)))))

(defun kill-other-buffers ()
    "Kill all other buffers."
    (interactive)
    (mapc 'kill-buffer 
          (delq (current-buffer) 
                (remove-if-not '(buffer-file-name) (buffer-list)))))

(ert-deftest haskell-flycheck-squiggly-appears-underneath-misspelled-function ()
  (kill-all-buffers-except-ert)

  (find-file (emacs-d-directory-for "testdata/simple-haskell-project/Main.hs"))

  (progn (search-forward "putStrLn") (replace-match "putStrLnORAORAORA"))

  (execute-kbd-macro (kbd "4h"))

  ;; if not already started, sit for long enough for a flycheck syntax check to start
  ;; (message "value of flycheck-current-syntax-check: %s" flycheck-current-syntax-check)
  (when (not flycheck-current-syntax-check)
    (log "flycheck syntax hasn't started yet, waiting up to 2 seconds for it")
    (with-timeout (5 (error "2 seconds passed and flycheck syntax check still hasn't started, error"))
      (while (not flycheck-current-syntax-check)
	(sit-for 0.1))))
  ;; TODO ideally we'd use the above or something like it but it can sometimes go into an infinite loop somehow
  ;; (sit-for 2)

  (with-timeout (10 (message "5 seconds passed, skipping haskell-flycheck-squiggly-appears-underneath-misspelled-function"))
    (while flycheck-current-syntax-check
      (sit-for 1)
      )
    )

  (should (eq 'flycheck-error (get-char-property (point) 'face)))
  ;; NOTE keeping this buffer open somehow made projectile-switch-projects-to-magit-works fail
  ;; TODO can we make this local?
  (set-buffer-modified-p nil)

  (kill-this-buffer)

  (log "haskell-flycheck-squiggly-appears-underneath-misspelled-function passed"))

(ert-deftest aggressive-indent-fixes-old-wrong-indentation-after-creating-newline ()
  (find-file (emacs-d-directory-for "testdata/aggressive-indent.org"))
  (execute-kbd-macro (kbd "gg")) ;; top of file
  (execute-kbd-macro (kbd "j")) ;; move down to text
  (call-interactively 'aggressive-indent-indent-region-and-on)
  ;; (execute-kbd-macro (kbd "o")) ;; start insert newline after text
  (let ((file-contents
	 (buffer-substring-no-properties (point-min) (point-max)))
	(correctly-indented-file-contents "***** TODO The text above isn't aligned properly! 
Aggressive indent mode or something fixes this I think?")
	)
    (should (string-equal correctly-indented-file-contents file-contents)))
  )


(ert-deftest dont-create-autosave-file-in-same-directory ()
  (find-file (emacs-d-directory-for "testdata/loremipsum.txt"))
  (let ((litter-file-exists (file-exists-p (emacs-d-directory-for "testdata/#loremipsum.txt#"))))
    (should (not litter-file-exists))
    ))

;; (ert-deftest haskell-nix-stack-workflow-isolated-flycheck-works () )
;; (kill-all-buffers-except-ert)
;; (cd (emacs-d-directory-for "testdata/haskell-nix-stack-workflow/"))
;; TODO bust lorri cache and try this... it won't work. There always needs ot be a cached build or things will fail at the project discovery and configuration level. Any way around this?
;; (direnv-allow);; TODO this doesn't actually work if you direnv deny this project :/
;; (find-file (emacs-d-directory-for "testdata/haskell-nix-stack-workflow/app/Main.hs"))
;; (sit-for 2)
;; (should (executable-find "hpack"))
;; (direnv-update-directory-environment (emacs-d-directory-for "testdata/simple-haskell-project/"))
;; (trace-function 'direnv-update-directory-environment)
;; (message "exec-path: %s\n" exec-path)

;; (when (not flycheck-ghc-args)
;;   (log "no flycheck ghc args set, killing and re-opening buffer")
;;   (set-buffer-modified-p nil)
;;   (kill-this-buffer)
;;   (flycheck-haskell-clear-config-cache)
;;   (flycheck-haskell-configure)
;;   (sit-for 1)
;;   (find-file (emacs-d-directory-for "testdata/haskell-nix-stack-workflow/app/Main.hs")))

;; (flycheck-mode nil)
;; (flycheck-haskell-clear-config-cache)
;; (funcall-interactively (flycheck-haskell-configure))
;; (flycheck-mode 1)

;; (replace-string "someFunc" "someFuncooooo")
;; (execute-kbd-macro (kbd "4h"))
;; ;; sit for long enough for a flycheck syntax check to start
;; (sit-for .5)
;; (with-timeout (2 (message "5 seconds passed, skipping haskell-flycheck-squiggly-appears-underneath-misspelled-function"))
;;   (while flycheck-current-syntax-check
;;     (sit-for 1)
;;     )
;;   )
;; (sit-for 5)

;; (should (eq 'flycheck-error (get-char-property (point) 'face)))
;; ;; NOTE keeping this buffer open somehow made projectile-switch-projects-to-magit-works fail
;; ;; TODO can we make this local?
;; (set-buffer-modified-p nil)

;; (kill-this-buffer)

;; (log "haskell-nix-stack-workflow-isolated-flycheck-works passed"))

;; (ert-deftest nix-highlighting-works-in-nix-file ()
;;   (find-file (emacs-d-directory-for "testdata/sample.nix"))
;;   (redisplay t)
;;   (should (eq 1 (point)))
;;   (should (string-equal "nix-keyword-face"
;; 			(get-char-property (point) 'face)))
;;   (log "nix-highlighting-works-in-nix-file passed"))


;; NOTE this isn't perfectly accurate because for some reason emacs on command line when run with tests-run seems to scroll up a different number for.

;;   (should (eq nil (executable-find "hello"))) 

;;   (shell-command "systemctl --user start lorri.socket")
;;   (shell-command
;;    (format "cd %s; direnv allow"
;; 	   (emacs-d-directory-for "testdata/direnv/hello")))
;;   (find-file (emacs-d-directory-for "testdata/direnv/hello/.envrc"))
;;   (should (derived-mode-p 'direnv-envrc-mode))
;;   (should (string-equal "/home/cody/.emacs.d/testdata/direnv/hello/" default-directory))
;;   (direnv-allow)
;;   (should (executable-find "hello"))

;;   (find-file (emacs-d-directory-for ""))
;;   (should (eq nil (executable-find "hello")))
;;   )

;; TODO add ghcide (or hls or hie) and lsp, lsp-ui tests
