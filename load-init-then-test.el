(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "GITHUB_WORKSPACE"))
      (format "~/.emacs.d/%s" path)
    (format "%s/%s" (getenv "GITHUB_WORKSPACE") path)))

(load (emacs-d-directory-for "init.el"))
(require 'buttercup)

(let* ((default-directory (emacs-d-directory-for "test"))
       ;; hack to ensure that relative filepath handling of buttercup doesn't mess up our expectations
       (command-line-args-left '((emacs-d-directory-for "test"))
       ) (buttercup-run-discover))
