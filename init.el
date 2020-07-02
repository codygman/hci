(require 'org)
(require 'use-package)

(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "GITHUB_WORKSPACE"))
      (format "~/.emacs.d/%s" path)
    (getenv "GITHUB_WORKSPACE")))

(org-babel-load-file (emacs-d-directory-for "readme.org"))
