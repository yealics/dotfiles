;; These customizations change the way emacs looks and disable/enable
;; some user interface elements. Some useful customizations are
;; commented out, and begin with the line "CUSTOMIZE". These are more
;; a matter of preference and may require some fiddling to match your
;; preferences

;; Turn off the menu bar at the top of each frame because it's distracting
(menu-bar-mode -1)

;; You can uncomment this to remove the graphical toolbar at the top. After
;; awhile, you won't need the toolbar.
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))

;; Don't show native OS scroll bars for buffers because they're redundant
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;; Color Themes
;; Read http://batsov.com/articles/2012/02/19/color-theming-in-emacs-reloaded/
;; for a great explanation of emacs color themes.
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Custom-Themes.html
;; for a more technical explanation.
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")
(add-to-list 'load-path "~/.emacs.d/themes")

(when (display-graphic-p)
  (set-frame-font "Hack-15" nil t)
  (add-to-list 'initial-frame-alist '(fullscreen . maximized)))

;; full path in title bar
(setq-default frame-title-format "%b (%f)")

;; don't pop up font menu
(global-set-key (kbd "s-t") '(lambda () (interactive)))

;; no bell
(setq ring-bell-function 'ignore)

(use-package all-the-icons
  :defer t)

(use-package dashboard
  :config
  (dashboard-setup-startup-hook)

  (defun my/goto-dashboard ()
    (interactive)
    (switch-to-buffer (get-buffer "*dashboard*")))

  (global-set-key (kbd "C-c d d") 'my/goto-dashboard)
  (global-set-key (kbd "<f10>") 'my/goto-dashboard)
  (add-hook 'dashboard-mode-hook 'hl-line-mode)
  (setq initial-buffer-choice (lambda () (get-buffer "*dashboard*"))
        dashboard-projects-backend 'projectile
        dashboard-items '((projects . 5)
                          (recents . 10)
                          (bookmarks . 5)
                          )
        dashboard-set-heading-icons t
        dashboard-set-file-icons t
        dashboard-center-content t
        dashboard-startup-banner 'logo))

(defun my/dark-theme-config ()
  (load-theme 'wombat t)
  ;; https://stackoverflow.com/a/2718543/2163429
  (custom-set-faces '(hl-line ((t (:foreground nil :underline t :background "#111"))))
                    '(region ((t (:background "blue")))))
  (set-cursor-color "green")
  (global-hl-line-mode 1)
  )

(defun my/light-theme-config ()
  (if (display-graphic-p)
      (progn
        ;; https://github.com/DarwinAwardWinner/dotemacs#dont-use-ns_selection_fg_color-and-ns_selection_bg_color
        (when (and (equal (face-attribute 'region :distant-foreground)
                          "ns_selection_fg_color")
                   (equal (face-attribute 'region :background)
                          "ns_selection_bg_color"))
          (set-face-attribute
           'region nil
           :distant-foreground 'unspecified
           :background "#BAD6FC"))
        )
    (progn
      ;; (custom-set-faces '(hl-line ((t (:foreground nil :underline nil :background "grey"))))
      ;;                   '(region ((t (:background "Light Salmon")))))
      )))

(if (string= (getenv "MY_THEME") "light")
    (my/light-theme-config)
  (my/dark-theme-config))

;; No cursor blinking, it's distracting
(blink-cursor-mode 0)
(setq-default cursor-type 't)
(global-display-line-numbers-mode 1)
;; https://www.gnu.org/software/emacs/manual/html_node/elisp/Time-Parsing.html
(display-time-mode 1)
(setq display-time-format "[%H:%M %a, %d/%m]")
;; remove minor mode from mode-line
;; https://emacs.stackexchange.com/a/41135
(setq mode-line-modes
      (mapcar (lambda (elem)
                (pcase elem
                  (`(:propertize (,_ minor-mode-alist . ,_) . ,_)
                   "")
                  (_ elem)))
              mode-line-modes))
