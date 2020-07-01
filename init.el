(require 'org)
(require 'use-package)
(org-babel-load-file (format "%s/.emacs.d/readme.org" (getenv "HOME")))
