(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "GITHUB_WORKSPACE"))
      (format "~/.emacs.d/%s" path)
    (getenv "GITHUB_WORKSPACE")))

(load (emacs-d-directory-for "init.el"))
(require 'buttercup)

(let* ((default-directory "~/hci/test")
       ;; hack to ensure that relative filepath handling of buttercup doesn't mess up our expectations
       (command-line-args-left '("~/hci/test"))
       ) (buttercup-run-discover))
