{ pkgs, ... }:

{
  programs.emacs = {
    enable = true;
    init = {
      enable = true;
      recommendedGcSettings = true;
      usePackageVerbose = true;

      prelude =
        let
          fontSize = if pkgs.stdenv.isDarwin then "18" else "12";
        in ''
          (require 'bind-key)

          (setq inhibit-startup-screen t)

          (when window-system
            (set-frame-font "Source Code Pro ${fontSize}")

            (dolist (mode
              '(tool-bar-mode
                tooltip-mode
                scroll-bar-mode
                menu-bar-mode
                blink-cursor-mode))
              (funcall mode 0)))
      '';

      usePackage = {
        evil = {
          enable = true;
          init = ''
            (setq evil-want-keybinding nil)
            ;; make * over a symbol look for other instances
            (setq evil-symbol-word-search t)
          '';
          config = ''
          (evil-mode 1)
          '';
        };

        evil-collection = {
          enable = false;
          init = ''
          (setq evil-collection-outline-bind-tab-p nil)
          '';
          config = ''
          (evil-collection-init)
          '';
          after = [ "evil" "company" ];
        };

      projectile = {
        enable = true;
        after = [ "ivy" ];
        diminish = [ "projectile-mode" ];
        config = ''
          (projectile-mode 1)
          (setq
            projectile-enable-caching t)
        '';
      };

        direnv = {
          enable = true;
          config = ''
            (direnv-mode)
          '';
        };

        haskell-mode = {
          enable = true;
          config = ''
          ;; not working for some reason
          ;; (add-hook 'haskell-mode-hook 'interactive-haskell-mode)
          (add-hook 'haskell-mode-hook 'haskell-indentation-mode)
          '';
        };

        company = {
          # causing company tng mode issue
          enable = false;
          diminish = [ "company-mode" ];
          config = ''
            (company-mode)
          '';
        };

        buttercup.enable = true;

        doom-themes = {
          enable = true;
          config = ''
          (load-theme 'doom-one t)
          '';
        };

        which-key = {
          enable = true;
          diminish = [ "which-key-mode" ];
          config = ''
            (which-key-mode)
            (which-key-setup-side-window-right-bottom)
            (setq which-key-sort-order 'which-key-key-order-alpha
                  which-key-side-window-max-width 0.33
                  which-key-idle-delay 0.05)
          '';
        };

        general = {
          enable = true;
          after = [ "evil" "which-key" ];
          config = ''
            (general-evil-setup)

            (general-mmap
              ";" 'evil-ex
              ":" 'evil-repeat-find-char)

            (general-create-definer my-leader-def
              :prefix "SPC")

            (general-create-definer my-local-leader-def
              :prefix "SPC m")

            (general-nmap
              :prefix "SPC"
              "b"  '(:ignore t :which-key "buffer")
              "bd" '(kill-this-buffer :which-key "kill buffer")

              "f"  '(:ignore t :which-key "file")
              "ff" '(find-file :which-key "find")
              "fs" '(save-buffer :which-key "save")

              "m"  '(:ignore t :which-key "mode")

              ;; "pc" project compile
              "pp" '(projectile-switch-project :which-key "projectile-switch-project")'

              "t"  '(:ignore t :which-key "toggle")
              "tf" '(toggle-frame-fullscreen :which-key "fullscreen")
              "wv" '(split-window-horizontally :which-key "split vertical")
              "ws" '(split-window-vertically :which-key "split horizontal")
              "wk" '(evil-window-up :which-key "up")
              "wj" '(evil-window-down :which-key "down")
              "wh" '(evil-window-left :which-key "left")
              "wl" '(evil-window-right :which-key "right")
              "wd" '(delete-window :which-key "delete")

              "q"  '(:ignore t :which-key "quit")
              "qq" '(save-buffers-kill-emacs :which-key "quit"))
          '';
        };

        ivy = {
          enable = true;
          demand = true;
          diminish = [ "ivy-mode" ];
          config = ''
            (ivy-mode 1)
          '';
          general = ''
            (general-nmap
              :prefix "SPC"
              "bb" '(ivy-switch-buffer :which-key "switch buffer")
              "fr" '(ivy-recentf :which-key "recent file"))
          '';
        };

        counsel = {
          enable = true;

          general = ''
            (general-nmap
              :prefix "SPC"
              ":" '(counsel-M-x :which-key "M-x")
              "."  '(counsel-find-file :which-key "find file")
              "iu"  '(counsel-unicode-char :which-key "find character")
              "sp"  '(counsel-rg :which-key "rg git")) ;; TODO not sure if this one will serve me as well as doom's +default/search-project
          '';
        };

      };

    };
  };
}
