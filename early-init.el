;; this might be a nice speedup but could cause me issues if there is anything
;; I'm forgetting to load. Don't want to pull that thread now
;; (setq package-enable-at-startup nil)

(setq use-file-dialog nil
      use-dialog-box nil
      inhibit-startup-screen t
      inhibit-startup-echo-area-message t)

(push '(menu-bar-lines . 0) default-frame-alist) ;; remove mini menu
(push '(tool-bar-lines . 0) default-frame-alist) ;; remove tool icon
(push '(vertical-scroll-bars) default-frame-alist) ;; no scroll bar
