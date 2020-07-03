;; (require 'org)
;; (require 'use-package)

;; duplicate in init.el
(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "GITHUB_WORKSPACE"))
      (format "~/.emacs.d/%s" path)
    (let ((github-workspace (getenv "GITHUB_WORKSPACE")))
      (progn (message (format "emacs-d-directory-for: GITHUB_WORKSPACE is %s" github-workspace)) (format "%s/%s" github-workspace path)))))

(use-package general
  :after evil
  :config
  (general-auto-unbind-keys) ;; NOTE not sure this works?
  (general-evil-setup t)
  (general-imap "j"
    (general-key-dispatch 'self-insert-command
      :timeout 0.25
      ;; TODO make this work so jf writes the file when I enter normal mode
      ;; "j" '(my-write-then-normal-state)
      "f" 'evil-normal-state))
  (general-create-definer my-leader-def
    :prefix "C")
  (my-leader-def
    :states '(normal visual emacs motion)
    :prefix "SPC"
    :non-normal-prefix "M-SPC"
    "u"   '(universal-argument :which-key "Universal Argument")
    "tf" '(toggle-frame-fullscreen :which-key "Toggle Fullscreen")

    "hf" '(describe-function :which-key "Describe Function")
    "hk" '(describe-key :which-key "Describe Key")
    "ha" '(apropos-command :which-key "Apropos Command")
    )
  )

(setq evil-want-keybinding nil
      evil-want-C-d-scroll t
      evil-want-C-u-scroll t
      evil-want-integration t
      )

(use-package evil
  :config
  (evil-mode 1)
  ;; :general
  ;; (general-nmap
  ;;   ;; :prefix "SPC"
  ;;   ;; "wd"  delete-window
  ;;   ;; "wd"  '(delete-window :which-key "delete window")
  ;;   )
  )

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))
