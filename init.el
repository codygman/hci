(use-package general
  :config
  (general-auto-unbind-keys) ;; NOTE not sure this works?
  (general-evil-setup t)
  (general-create-definer my-leader-def
    :prefix "C")
  (my-leader-def
    :states '(normal visual emacs motion)
    :prefix "SPC"
    :non-normal-prefix "M-SPC"
    "u"   '(universal-argument :which-key "Universal Argument")
    "hf" '(describe-function :which-key "Describe Function")
    "hk" '(describe-key :which-key "Describe Key")
    "ha" '(apropos-command :which-key "Apropos Command")
    )
  )

(use-package evil
  :init 
  (setq evil-want-keybinding nil
	evil-want-C-d-scroll t
	evil-want-C-u-scroll t
	evil-want-integration t
	)
  :config
  (evil-mode 1)
  :general
  (general-nmap
    :prefix "SPC"
    "wd"  delete-window
    )
  )

(use-package evil-collection
  :after evil
  :custom (evil-collection-setup-minibuffer t)
  :config
  (evil-collection-init))
