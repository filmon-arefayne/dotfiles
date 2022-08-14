{
  packageOverrides = pkgs: with pkgs; rec {
    myEmacsConfig = writeText "default.el" ''
      ;; initialize package

      (require 'package)
      (package-initialize 'noactivate)
      (eval-when-compile
        (require 'use-package))

      ;; load some packages
      (use-package lsp-mode
        :ensure
	:commands lsp
	:custom
	(lsp-eldoc-render-all t)
	(lsp-idle-delay 0.6)
	
	(lsp-rust-analyzer-cargo-watch-command "clippy")
	(lsp-rust-analyzer-server-display-inlay-hints t)

        :config
	(add-hook 'lsp-mode-hook 'lsp-ui-mode))

      (use-package flycheck
        :ensure t
        :config
	(setq flycheck-display-errors-function nil))

      (use-package lsp-ui
        :ensure
	:commands lsp-ui-mode
	:custom
	(lsp-signature-render-documentation nil)
	(lsp-ui-peek-always-show nil)
	(lsp-ui-sideline-enable nil)
	(lsp-ui-sideline-show-hover nil)
	(lsp-ui-doc-enable nil))

      (use-package rustic
        :ensure
	:config
	(setq lsp-eldoc-hook nil)
	(setq lsp-enable-symbol-highlighting nil)
	(setq lsp-signature-auto-activate nil)


        (defun my/rustic-save-mode-hook ()
           (when (equal major-mode 'rustic-mode)
	     (rustic-cargo-check)))

        (add-hook 'after-save-hook #'my/rustic-save-mode-hook)
      )
      	 
      (use-package magit
        :defer
        :if (executable-find "git")
        :bind (("C-x g" . magit-status)
               ("C-x G" . magit-dispatch-popup))
        :init
        (setq magit-completing-read-function 'ivy-completing-read))

    '';

    myEmacs = emacs.pkgs.withPackages (epkgs: (with epkgs.melpaStablePackages; [
      (runCommand "default.el" {} ''
         mkdir -p $out/share/emacs/site-lisp
         cp ${myEmacsConfig} $out/share/emacs/site-lisp/default.el
       '')
      magit
      rustic
      lsp-mode
      lsp-ui
      flycheck
      use-package
    ]));
  };
}