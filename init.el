(require 'org)
(require 'use-package)
(message (format "buffer file name is: %s" buffer-file-name))
(org-babel-load-file (format "%s/.emacs.d/readme.org" (getenv "HOME")))
