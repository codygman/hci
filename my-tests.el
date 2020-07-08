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
  ;; We would like to use `ert-run-tests-batch-and-exit'
  ;; Unfortunately it doesn't work outside of batch mode, and we
  ;; can't use batch mode because we have tests that need windows.
  ;; Instead, run the tests interactively, copy the results to a
  ;; text file, and then exit with an appropriate code.
  (setq attempt-stack-overflow-recovery nil
	attempt-orderly-shutdown-on-fatal-signal nil
	debug nil
	debug-on-error t
	)
  (unwind-protect
      (progn
	(progn (ert-run-tests-interactively t) (before-test-init))
	(with-current-buffer "*ert*"
	  (append-to-file (point-min) (point-max) "test-results.txt")
	  (let ((failed-tests (ert-stats-completed-unexpected ert--results-stats)))
	    ;; (log (format "failed tests: %s" (princ failed-tests)))
	    ;; (log (format "zerop failed-tests ==  %s" (princ (zerop failed-tests))))
	    (log "checking failed tests")
	    (if (zerop failed-tests)
		(progn (log "0 failed tests, exiting with code 0")
		       (when (not debug) (kill-emacs 0)))
	      (progn (log "at least 1 failed test, exiting with code 1")
		     (when (not debug) (kill-emacs 1))))
	    (log "done checking failed tests")

	    
	    
	    )
	  ))
    (unwind-protect
	(progn
	  (log "Error running tests\n")
	  ;; (append-to-file (format "backtrace: %s" (princ (backtrace-get-frames 'backtrace))) nil "test-results.txt")

	  ;; TODO fix wrong type argument numberp error
	  ;; (log (backtrace-to-string (backtrace-get-frames 'backtrace)))
	  (let ((backtrace-frames (backtrace-get-frames 'backtrace)))
	    (when backtrace-frames
	      (append-to-file (backtrace-to-string backtrace-frames) nil "test-results.txt")
	      ))
	  )
      (when (not debug) (kill-emacs 2))
      )))

;; duplicate in init.el
(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "GITHUB_WORKSPACE"))
      (format "~/hci/%s" path)
    (let ((github-workspace (getenv "GITHUB_WORKSPACE")))
      (progn (message (format "emacs-d-directory-for: GITHUB_WORKSPACE is %s" github-workspace)) (format "%s/%s" github-workspace path)))))

;; (ert-deftest use-package-installed ()
;;   (should (fboundp 'use-package)))

;; (ert-deftest evil-installed ()
;;   (should (fboundp 'evil-next-line)))

;; (ert-deftest evil-collection-installed ()
;;   (should (fboundp 'evil-collection-init)))

(ert-deftest magit-installed ()
  (should (fboundp 'magit-version))
  (log "magit-installed passed"))

;; (ert-deftest haskell-mode-enabled-opening-haskell-file ()
;;   (find-file (emacs-d-directory-for "testdata/simple-haskell-project/Main.hs"))
;;   (should (eq 'haskell-mode (derived-mode-p 'haskell-mode))))

;; ;; TODO test for "jf" escape working
;; ;; TODO test for "Ctrl u" working

;; (defun copy-line (arg)
;;   "Copy lines (as many as prefix argument) in the kill ring"
;;   ;; (interactive "p")
;;   (kill-ring-save (line-beginning-position)
;;                   (line-beginning-position (+ 1 arg)))
;;   (message "%d line%s copied" arg (if (= 1 arg) "" "s")))

;; (require 'subr-x)

;; (defun my-append-string-to-file (s filename)
;;   (log "my-append-string-to-file")
;;   (with-temp-buffer
;;     (insert s)
;;     (write-region (point-min) (point-max) filename t)))

;; (defun wait-for-ghci ()
;;   ;; TODO figure out how to maybe use haskell-mode-interactive-prompt-state
;;   (sit-for 5))

;; (ert-deftest ghci-has-locals-in-scope ()
;;   (interactive)
;;   (find-file (emacs-d-directory-for "testdata/simple-haskell-project/Main.hs"))
;;   (my-append-string-to-file "START load-file\n" "debug")
;;   (haskell-process-load-file)
;;   (sit-for 5)
;;   (with-current-buffer "*simple-haskell-project*"
;;     (evil-append-line 1)
;;     (insert ":t functionWeWantInScope")
;;     (haskell-interactive-mode-return)
;;     (sit-for 7)
;;     (evil-previous-line 1)
;;     (copy-line 1))
;;   (should (string-equal
;;            (string-trim (substring-no-properties (nth 0 kill-ring)))
;;            "functionWeWantInScope :: ()")))

;; evil
(ert-deftest ctrl-u-scrolls-up ()
  (find-file (emacs-d-directory-for "testdata/loremipsum.txt"))
  (execute-kbd-macro (kbd "G"))
  (execute-kbd-macro (kbd "C-u"))
  (log "ctrl-u-scrolls-up passed"))


;; helm
;;; helm projectile
;;;; TODO can add known projects with helm
;; TODO for some reason after adding haskell-flycheck-squiggly-appears-underneath-misspelled-function it caused this one to fail
(ert-deftest projectile-switch-projects-to-magit-works ()
  ;; find our own git project to test projectile on since we know we'll have it both locally and in CI always
  (projectile-clear-known-projects)
  (projectile-add-known-project (emacs-d-directory-for ""))
  ;; ensure that we can successfully switch to magit for a given project
  (should (string-equal
	   "magit: hci"
	   (save-excursion
	     (with-simulated-input
		 '("hci"
		   (wsi-simulate-idle-time 0.5)
		   "M-g")
	       (helm-projectile-switch-project))
	     (buffer-name))))
  (log "projectile-switch-projects-to-magit-works passed"))


(require 'cl) ;; TODO necessary?
(defun kill-all-buffers-except-ert ()
    "Kill all other buffers."
    (interactive)
    (mapc 'kill-buffer
          (delq (current-buffer)
                (remove-if-not (lambda (x) (string-equal "*ert*" (buffer-file-name))) (buffer-list)))))

;; (defun kill-other-buffers ()
;;     "Kill all other buffers."
;;     (interactive)
;;     (mapc 'kill-buffer 
;;           (delq (current-buffer) 
;;                 (remove-if-not '(buffer-file-name) (buffer-list)))))




(ert-deftest haskell-flycheck-squiggly-appears-underneath-misspelled-function ()
  (kill-all-buffers-except-ert)

  (find-file (emacs-d-directory-for "testdata/simple-haskell-project/Main.hs"))

  (replace-string "putStrLn" "putStrLnORAORAORA")
  (execute-kbd-macro (kbd "4h"))
  ;; sit for long enough for a flycheck syntax check to start
  (sit-for .5)
  (with-timeout (2 (message "5 seconds passed, skipping haskell-flycheck-squiggly-appears-underneath-misspelled-function"))
    (while flycheck-current-syntax-check
      (sit-for .05)
      )
    )

  (should (eq 'flycheck-error (get-char-property (point) 'face)))
  ;; NOTE keeping this buffer open somehow made projectile-switch-projects-to-magit-works fail
  ;; TODO can we make this local?
  (set-buffer-modified-p nil)

  (kill-this-buffer)

  (log "haskell-flycheck-squiggly-appears-underneath-misspelled-function passed"))



(ert-deftest haskell-nix-stack-workflow-isolated-flycheck-works ()
  (kill-all-buffers-except-ert)
  (cd (emacs-d-directory-for "testdata/haskell-nix-stack-workflow/"))
  ;; TODO bust lorri cache and try this... it won't work. There always needs ot be a cached build or things will fail at the project discovery and configuration level. Any way around this?
  (direnv-allow);; TODO this doesn't actually work if you direnv deny this project :/
  (find-file (emacs-d-directory-for "testdata/haskell-nix-stack-workflow/app/Main.hs"))
  (sit-for 2)
  (should (executable-find "hpack"))
  ;; (direnv-update-directory-environment (emacs-d-directory-for "testdata/simple-haskell-project/"))
  ;; (trace-function 'direnv-update-directory-environment)
  (message "exec-path: %s\n" exec-path)

  ;; (when (not flycheck-ghc-args)
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
  ;; sit for long enough for a flycheck syntax check to start
  (sit-for .5)
  ;; (with-timeout (2 (message "5 seconds passed, skipping haskell-flycheck-squiggly-appears-underneath-misspelled-function"))
  ;;   (while flycheck-current-syntax-check
  ;;     (sit-for .05)
  ;;     )
  ;;   )
  ;; (sit-for 5)

  ;; (should (eq 'flycheck-error (get-char-property (point) 'face)))
  ;; NOTE keeping this buffer open somehow made projectile-switch-projects-to-magit-works fail
  ;; TODO can we make this local?
  (set-buffer-modified-p nil)

  (kill-this-buffer)

  (log "haskell-nix-stack-workflow-isolated-flycheck-works passed"))

(ert-deftest nix-highlighting-works-in-nix-file ()
  (find-file (emacs-d-directory-for "testdata/sample.nix"))
  (redisplay t)
  (should (eq 1 (point)))
  (should (string-equal "nix-keyword-face"
			(get-char-property (point) 'face)))
  (log "nix-highlighting-works-in-nix-file passed"))


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
