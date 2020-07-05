(defun return-true () t)

(defun open-simple-haskell-project-main-file ()
  (find-file (emacs-d-directory-for "testdata/simple-haskell-project/Main.hs"))
  )

(defun open-haskell-file-add-mispelling-wait-return-face ()
		 "emacs-with-window-capability"
		 (write-region "in open-haskell-file-add-mispelling-wait-return-face" nil "/tmp/entry" 'append)


		 (switch-to-buffer "*Messages*"
				   (write-region (point-min) (point-max) "/tmp/messages-output" ))


		 (write-region "\n wrote messages output" nil "/tmp/entry" 'append)


		 (open-simple-haskell-project-main-file)

		 (write-region "\n opened file" nil "/tmp/entry" 'append)

		 (flycheck-mode nil)
		 (write-region "\n flycheck nil" nil "/tmp/entry" 'append)
		 (direnv-allow)
		 (write-region "\n direnv allow" nil "/tmp/entry" 'append)
		 (direnv-update-environment)
		 (write-region "\n direnv update" nil "/tmp/entry" 'append)
		 (redisplay t)
		 (write-region "\n redisplay" nil "/tmp/entry" 'append)
		 (sit-for 2)
		 (write-region "\n sat 2" nil "/tmp/entry" 'append)

		 (flycheck-mode 1)
		 (write-region "\n flycheck on" nil "/tmp/entry" 'append)
		 (sit-for 2)
		 (write-region "\n sat 2" nil "/tmp/entry" 'append)
		 (replace-string "putStrLn" "putStrLnORAORAORA")
		 (write-region "\n replace string" nil "/tmp/entry" 'append)
		 (execute-kbd-macro (kbd "4h"))
		 (write-region "\n move back to error" nil "/tmp/entry" 'append)
		 (redisplay t)
		 (write-region "\n redisplay" nil "/tmp/entry" 'append)
		 (sit-for 5)
		 (write-region "\n sit 5" nil "/tmp/entry" 'append)


		 (message "writing out message buffer output")
		 (switch-to-buffer "*Messages*"
				   (write-region (point-min) (point-max) "/tmp/messages-output" ))

		 (princ (buffer-substring-no-properties (point-min) (point-max)))
		 
		 )
