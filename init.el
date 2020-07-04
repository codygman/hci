
(require 'org)
(require 'use-package)

;; duplicate in init.el
(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "GITHUB_WORKSPACE"))
      (format "~/hci/%s" path)
    (let ((github-workspace (getenv "GITHUB_WORKSPACE")))
      (progn (message (format "emacs-d-directory-for: GITHUB_WORKSPACE is %s" github-workspace)) (format "%s/%s" github-workspace path)))))

(org-babel-load-file (emacs-d-directory-for "readme.org"))


;; (use-package general
;;   :init
;;   (setq evil-want-keybinding nil
;; 	evil-want-C-d-scroll t
;; 	evil-want-C-u-scroll t
;; 	evil-want-integration t
;; 	)
;;   :config
;;   (general-create-definer my-leader-def
;;     :prefix "C")
;;   (my-leader-def
;;     :states '(normal visual emacs motion)
;;     :prefix "SPC"
;;     :keymaps 'override
;;     :non-normal-prefix "M-SPC"
;;     "u"   '(universal-argument :which-key "Universal Argument")
;;     "tf" '(toggle-frame-fullscreen :which-key "Toggle Fullscreen")
;;     "wd" '(delete-window :which-key "Delete Window")
;;     "wm"  '(toggle-maximize-buffer :which-key "maximize buffer")

;;     "hf" '(describe-function :which-key "Describe Function")
;;     "hk" '(describe-key :which-key "Describe Key")
;;     "ha" '(apropos-command :which-key "Apropos Command")
;;     )
;;   )

;; (use-package evil
;;   :after general
;;   :config
;;   (evil-mode 1)
;;   :general
;;   (nmap
;;     :prefix "SPC"
;;     ;; TODO uncommenting any of these causes an error where evil isn't loaded
;;     "oo"  emacs-version
;;     )
;;   )

;; (use-package evil-collection
;;   :after evil
;;   :config
;;   (evil-collection-init))
