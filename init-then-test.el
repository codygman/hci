(message (format "we are in %s" (pwd)))
(load (format "%s/init.el" (getenv "TRAVIS_BUILD_DIR")))
(message (format "now we are in %s" (pwd)))
(require 'buttercup)
(buttercup-run-discover)

;; old tests I want to add some of
;; (defun tests-run ()
;;   "Run Evil tests."
;;   (interactive '(nil t))
;;   ;; We would like to use `ert-run-tests-batch-and-exit'
;;   ;; Unfortunately it doesn't work outside of batch mode, and we
;;   ;; can't use batch mode because we have tests that need windows.
;;   ;; Instead, run the tests interactively, copy the results to a
;;   ;; text file, and then exit with an appropriate code.
;;   (setq attempt-stack-overflow-recovery nil
;; 	attempt-orderly-shutdown-on-fatal-signal nil)
;;   (unwind-protect
;;       (progn
;; 	(ert-run-tests-interactively t)
;; 	(with-current-buffer "*ert*"
;; 	  (append-to-file (point-min) (point-max) "test-results.txt")
;; 	  (when (not (getenv "DEBUG_TESTS")) (kill-emacs (if (zerop (ert-stats-completed-unexpected ert--results-stats)) 0 1))))
;;     (unwind-protect
;; 	(progn
;; 	  (append-to-file "Error running tests\n" nil "test-results.txt")
;; 	  (append-to-file (backtrace-to-string (backtrace-get-frames 'backtrace)) nil "test-results.txt"))
;;       (when (not (getenv "DEBUG_TESTS")) (kill-emacs 2))))))

;; ;; duplicate in init.el
;; (defun my-emacs-everywhere-directory ()
;;   (if (eq nil (getenv "TRAVIS_OS_NAME"))
;;       "~/.emacs.d/"
;;     "~/build/codygman/my-emacs-everywhere/"))
;; (ert-deftest version-check ()
;;   (should (string-equal "27.0.50" emacs-version)))

;; (ert-deftest straight-el-installed ()
;;   (should (fboundp 'straight-use-package)))

;; (ert-deftest org-mode-installed ()
;;   (should (string-equal "9.2.6" org-version)))

;; ;; more specific tests
;; (ert-deftest searching-works-as-expected ()
;;   (should (not (eq nil (executable-find "rg"))))
;;   (should (string-equal "rg --color=always --smart-case --no-heading --line-number %s %s %s" helm-grep-ag-command))
;;   (require 'helm-grep)
;;   ;; (should (string-equal "helm-do-grep-ag"
;;   ;; 			(key-binding (kbd "SPC g g"))))
;;   )

;; (ert-deftest trivial-helm-example-works-as-expected ()
;;   (should (string-equal
;; 	   "john"
;; 	   (with-simulated-input
;; 	       '("jo"
;; 		 (wsi-simulate-idle-time 0.5)
;; 		 "RET")
;; 	     (car (helm :sources
;; 			`((name . "Simple helm names example")
;; 			  (candidates . ,(list "jane" "john"))
;; 			  (action . (lambda (candidate) (helm-marked-candidates)))))))
;; 	   )))

;; (ert-deftest haskell-mode-enabled-opening-haskell-file ()
;;   (find-file (format "%s/testdata/simple-haskell-project/Main.hs" (my-emacs-everywhere-directory)))
;;   (should (eq 'haskell-mode (derived-mode-p 'haskell-mode))))

;; (defun get-substring-from-line ()
;;   "Copy the whole line that point is on and move to the beginning of the next line.
;;     Consecutive calls to this command append each line to the
;;     kill-ring."
;;   (interactive)
;;   (let ((beg (line-beginning-position 1))
;; 	(end (line-beginning-position 2)))
;;     (string-trim (substring-no-properties (buffer-substring beg end)))))

;; (defun load-simple-hs-file-and-return-ghci-evald-main ()
;;   (save-excursion
;;     (find-file (format "%s/testdata/simple-haskell-project/Main.hs" (my-emacs-everywhere-directory)))
;;     (haskell-process-load-file)
;;     (switch-to-buffer "*simple-haskell-project*")
;;     (sit-for 2)
;;     (goto-char (point-max))
;;     (evil-append-line 1)
;;     (insert "main")
;;     (haskell-interactive-mode-return)
;;     (sit-for 3)
;;     (evil-previous-line)
;;     (get-substring-from-line)))

;; (ert-deftest haskell-mode-ghci-loads-file-and-can-execute ()
;;   (should (string-equal
;; 	   "Hello, Haskell!"
;; 	   (load-simple-hs-file-and-return-ghci-evald-main))))

;; (defvar expected-flycheck-buffer-output-for-simple-nix-haskell-project ()
;; " Main.hs     6  18 error           error:
;;      • Couldn't match expected type ‘Int’ with actual type ‘[Char]’
;;      • In the second argument of ‘(+)’, namely ‘\"s\"’
;;        In the expression: (1 :: Int) + \"s\"
;;        In an equation for ‘f’: f = (1 :: Int) + \"s\" (haskell-dante)
;; ")

;; (ert-deftest flycheck-works-as-expected-in-simple-nix-haskell-project ()
;;   (let ((haskell-process-suggest-overloaded-strings))
;;     (find-file (format "%s/testdata/simple-haskell-project/Main.hs" (my-emacs-everywhere-directory)))
;;     (sit-for 2)
;;     (goto-char (point-max))
;;     (insert "f = (1 :: Int) + \"s\"")
;;     (flycheck-list-errors)
;;     (let ((flycheck-buffer-error-string
;; 	   (progn (switch-to-buffer flycheck-error-list-buffer)
;; 		  (buffer-substring-no-properties (point-min) (point-max)))))
;;       (should (eq flycheck-buffer-error-string expected-flycheck-buffer-output-for-simple-nix-haskell-project)))))

;; (require 'ert)
;; (require 'ert-x)

;; (defun simulate-expand-yasnippet (key code)
;;   (save-excursion
;;     (let ((generated-buffer-name (generate-new-buffer (format "test-%s-yasnippet" key))))
;;       (with-current-buffer generated-buffer-name
;; 	(org-mode)
;; 	(erase-buffer)
;; 	(insert key)
;; 	(evil-append-line nil)
;; 	(ert-simulate-command '(yas-expand))
;; 	(should (eq (key-binding (yas--read-keybinding "<tab>")) 'yas-next-field-or-maybe-expand))
;; 	(ert-simulate-command '(yas-next-field-or-maybe-expand))
;; 	(when code (insert code))
;; 	`( :expanded-contents ,(buffer-substring-no-properties (point-min) (point-max))
;; 	  :the-buffer-name ,generated-buffer-name )
;; 	))))

;; (defun simulate-execute-src-block-in-buffer (buffer-name)
;;   (save-excursion
;;     (with-current-buffer buffer-name
;;       ;; (ert-simulate-command '(org-babel-next-src-block))
;;       (ert-simulate-command '(org-ctrl-c-ctrl-c))
;;       (buffer-substring-no-properties (point-min) (point-max)))))

;; (ert-deftest yas-general-source-block-expands-correctly ()
;;   (should (string-equal (plist-get (simulate-expand-yasnippet "src" nil) :expanded-contents)
;; 		  "#+begin_src

;; #+end_src")))

;; (ert-deftest yas-elisp-source-block-gives-expected-output ()
;;   (require 'yasnippet)
;;   (yas-load-directory "~/.emacs.d/snippets")
;;   (should (not (eq nil (yas-lookup-snippet "Elisp Org Source Block" 'org-mode t))))
;;   (let ((buffer-name (plist-get
;; 		      (simulate-expand-yasnippet "elisp" "(+ 1 1)")
;; 		      :the-buffer-name)))
;;     (string-equal (simulate-execute-src-block-in-buffer buffer-name)
;; 		  "#+begin_src emacs-lisp
;; (+ 1 1)
;; #+end_src

;; #+RESULTS:
;; : 2
;; ")))

;; (defun clone-projects-projectile-test ()
;;   (shell-command-to-string "cd /tmp && git clone https://github.com/jgm/pandoc.git")
;;   (shell-command-to-string "cd /tmp && git clone --depth 1 git://git-annex.branchable.com/ git-annex")
;;   (shell-command-to-string "cd /tmp && git clone --depth 1 https://github.com/haskell/haskell-ide-engine.git")
;;   (should (file-directory-p "/tmp/pandoc"))
;;   (should (file-directory-p "/tmp/git-annex"))
;;   (should (file-directory-p "/tmp/haskell-ide-engine")))

;; (ert-deftest projectile-switch-projects-to-magit-works ()
;;   (clone-projects-projectile-test)
;;   ;; find git-annex,haskell-ide-engine, and pandoc projects cloned to /tmp
;;   (projectile-discover-projects-in-directory "/tmp")
;;   ;; ensure that we can successfully switch to magit for a given project
;;   (should (string-equal
;;    "magit: pandoc"
;;    (save-excursion
;;      (with-simulated-input
;; 	 '("pan"
;; 	   (wsi-simulate-idle-time 0.5)
;; 	   "RET")
;;        (helm-projectile-switch-project))
;;      (buffer-name))))
;;   )

;; (ert-deftest evil-collection-installed-and-initialized ()
;;   (funcall helpful-switch-buffer-function (helpful--buffer 'defun t))
;;   (helpful-update)
;;   (key-binding "TAB")
;;   (should (equal 'forward-button (key-binding (kbd "<tab>")))))
