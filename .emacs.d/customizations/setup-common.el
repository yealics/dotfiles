;; makes handling lisp expressions much, much easier
;; Cheatsheet: http://www.emacswiki.org/emacs/PareditCheatsheet

(use-package paredit)

(use-package smartparens
     :config (require 'smartparens-config)
     :hook ((c++-mode c-mode python-mode
                      ruby-mode js2-mode tuareg-mode
                      go-mode rust-mode) . smartparens-mode))

(use-package flycheck
  ;; :pin melpa-stable
  :init (global-flycheck-mode)
  :config
  (setq-default flycheck-disabled-checkers '(emacs-lisp-checkdoc rust-cargo rust rust-clippy))
  (setq flycheck-python-flake8-executable "flake8")
  )

(use-package lsp-mode
  :load-path "~/.emacs.d/vendor/lsp-mode"
  ;; :load-path "~/code/misc/lsp-mode"
  :hook ((go-mode . lsp-deferred)
         (rust-mode . lsp-deferred)
         (python-mode . lsp-deferred)
         (lsp-mode . lsp-enable-which-key-integration)
         ;; (sh-mode . lsp-deferred)
         ;; (js2-mode . lsp-deferred)
         )
  :ensure-system-package
  ((gopls . "go get golang.org/x/tools/gopls@latest")
   (pyls . "pip install 'python-language-server[all]'")
   ;; (typescript-language-server . "npm install -g typescript-language-server")
   ;; (bash-language-server . "npm install -g bash-language-server")
   )
  :commands (lsp lsp-deferred)
  :init
  (setq lsp-keymap-prefix "C-c l")

  ;; https://github.com/emacs-lsp/lsp-mode/pull/1740
  (cl-defmethod lsp-clients-extract-signature-on-hover (contents (_server-id (eql rust-analyzer)))
  (-let* (((&hash "value") contents)
          (groups (--partition-by (s-blank? it) (s-lines value)))
          (sig_group (if (s-equals? "```rust" (car (-fourth-item groups)))
                         (-fourth-item groups)
                       (car groups)))
          (sig (--> sig_group
                    (--drop-while (s-equals? "```rust" it) it)
                    (--take-while (not (s-equals? "```" it)) it)
                    (s-join "" it))))
    (lsp--render-element (concat "```rust\n" sig "\n```"))))

  ;; https://github.com/emacs-lsp/lsp-mode/pull/1740/files#diff-e196a72bcbed4c56a4d30daf13708f64R725
  :config
  (require 'lsp-modeline)
  (require 'lsp-completion)
  (require 'lsp-diagnostics)
  ;; (add-hook 'before-save-hook 'lsp-format-buffer)
  (setq lsp-log-io nil
        lsp-eldoc-render-all nil
        lsp-completion-provider t
        lsp-signature-render-documentation nil
        lsp-rust-server 'rust-analyzer
        lsp-rust-analyzer-cargo-watch-enable nil
        lsp-gopls-hover-kind "NoDocumentation"
        lsp-gopls-use-placeholders t
        lsp-diagnostics-provider :none)
    (push "[/\\\\]vendor$" lsp-file-watch-ignored)
  :bind (:map lsp-mode-map
              ("M-." . lsp-find-definition)
              ("M-n" . lsp-find-references)
              ("C-c M-n" . lsp-rust-analyzer-expand-macro)
              ("C-c u" . lsp-execute-code-action)
              ("C-c d" . lsp-describe-thing-at-point)))

(use-package lsp-treemacs
  :load-path "~/.emacs.d/vendor/lsp-treemacs"
  :bind (("C-c t" . treemacs)
         :map lsp-mode-map
              ("C-c C-u" . lsp-treemacs-symbols))
  :after lsp-mode)

(use-package hideshow
  :hook (prog-mode . hs-minor-mode)
  :config
  (defun my/toggle-fold ()
    (interactive)
    (save-excursion
      (end-of-line)
      (if (hs-already-hidden-p)
          (hs-show-block)
        (hs-hide-block))))
  :bind (:map prog-mode-map
              ("C-c o" . my/toggle-fold))
  )
