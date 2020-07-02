(load "~/.emacs.d/init.el")
(require 'buttercup)

(let* ((default-directory "~/hci/test")
       ;; hack to ensure that relative filepath handling of buttercup doesn't mess up our expectations
       (command-line-args-left '("~/hci/test"))
       ) (buttercup-run-discover))
