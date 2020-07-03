(use-package general)

(use-package evil
  :after general
  :config
  (evil-mode 1)
  :general
  )

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))
