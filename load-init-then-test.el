(defun emacs-d-directory-for (path)
  (if (eq nil (getenv "GITHUB_WORKSPACE"))
      (format "~/.emacs.d/%s" path)
    (let ((github-workspace (getenv "GITHUB_WORKSPACE")))
      (progn (message (format "emacs-d-directory-for: GITHUB_WORKSPACE is %s" github-workspace)) (format "%s/%s" github-workspace path)))))

(load (emacs-d-directory-for "init.el"))
(require 'buttercup)

(message "loaded init")
(let* ( (test-directory (emacs-d-directory-for "test"))
	(default-directory test-directory)
       ;; hack to ensure that relative filepath handling of buttercup doesn't mess up our expectations
	(command-line-args-left (push test-directory command-line-args-left)))
  (message "running buttercup discover")
  (buttercup-run-discover))
