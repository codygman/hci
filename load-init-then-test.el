(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "GITHUB_WORKSPACE"))
      (format "~/.emacs.d/%s" path)
    (format "%s/%s" (getenv "GITHUB_WORKSPACE") path)))

(load (emacs-d-directory-for "init.el"))
(require 'buttercup)

(let* ( (test-directory (emacs-d-directory-for "test"))
	(default-directory test-directory)
       ;; hack to ensure that relative filepath handling of buttercup doesn't mess up our expectations
	(command-line-args-left (push test-directory command-line-args-left)))
  (buttercup-run-discover))
