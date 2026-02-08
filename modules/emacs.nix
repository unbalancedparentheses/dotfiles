# Emacs configuration with LSP, Treesitter, and modern packages
{ config, pkgs, lib, ... }:

let
  lsp = import ./lsp.nix { inherit pkgs; };
in
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs30;

    extraPackages = epkgs: with epkgs; [
      # Evil (Vim keybindings)
      evil
      evil-collection
      evil-surround
      evil-commentary

      # Completion (modern stack)
      vertico
      consult
      marginalia
      orderless
      corfu
      cape
      kind-icon

      # Navigation
      projectile
      consult-projectile
      avy
      ace-window
      treemacs
      treemacs-evil
      treemacs-projectile
      treemacs-magit

      # Git
      magit
      git-timemachine
      diff-hl

      # LSP
      eglot
      consult-eglot

      # Languages
      rust-mode
      go-mode
      nix-mode
      typescript-mode
      lua-mode
      yaml-mode
      json-mode
      markdown-mode
      web-mode
      dockerfile-mode
      erlang
      elixir-mode
      zig-mode

      # Treesitter
      treesit-grammars.with-all-grammars

      # Editing
      expand-region
      multiple-cursors
      undo-tree
      which-key
      general

      # Visual
      rainbow-delimiters
      doom-modeline
      doom-themes
      nerd-icons
      nerd-icons-completion
      nerd-icons-corfu
      nerd-icons-dired

      # Utilities
      helpful
      vterm
      envrc
      gcmh
      restart-emacs

      # Org
      org-bullets
      org-roam

      # Syntax/Linting
      flycheck
      flycheck-eglot

      # macOS
      exec-path-from-shell
    ];

    extraConfig = ''
      ;; Performance - early init
      (setq gc-cons-threshold 100000000)
      (setq read-process-output-max (* 1024 1024))

      ;; Native compilation
      (when (featurep 'native-compile)
        (setq native-comp-async-report-warnings-errors nil)
        (setq native-comp-deferred-compilation t))

      ;; Basic settings
      (setq inhibit-startup-message t)
      (setq initial-scratch-message nil)
      (menu-bar-mode -1)
      (tool-bar-mode -1)
      (scroll-bar-mode -1)
      (setq ring-bell-function 'ignore)
      (setq-default indent-tabs-mode nil)
      (setq-default tab-width 2)
      (global-display-line-numbers-mode t)
      (column-number-mode t)
      (setq display-line-numbers-type 'relative)
      (global-hl-line-mode t)
      (setq create-lockfiles nil)
      (setq use-short-answers t)
      (setq-default fill-column 100)
      (global-auto-revert-mode t)
      (setq load-prefer-newer t)

      ;; Usability
      (setq confirm-kill-emacs 'y-or-n-p)
      (setq require-final-newline t)
      (setq sentence-end-double-space nil)
      (setq kill-whole-line t)
      (winner-mode 1)
      (global-so-long-mode 1)

      ;; Uniquify buffer names
      (setq uniquify-buffer-name-style 'forward)
      (setq uniquify-separator "/")
      (setq uniquify-after-kill-buffer-p t)

      ;; Scrolling
      (setq scroll-margin 8)
      (setq scroll-conservatively 101)
      (setq mouse-wheel-progressive-speed nil)
      (setq mouse-wheel-scroll-amount '(3 ((shift) . 1)))
      (pixel-scroll-precision-mode 1)

      ;; Undo
      (setq undo-limit 80000000)
      (setq undo-strong-limit 120000000)
      (setq undo-outer-limit 360000000)

      ;; Auto-save to central directory (safer than disabling)
      (setq auto-save-default t)
      (setq make-backup-files t)
      (setq backup-by-copying t)
      (setq delete-old-versions t)
      (setq kept-new-versions 6)
      (setq kept-old-versions 2)
      (setq version-control t)
      (let ((backup-dir "~/.emacs.d/backups/")
            (auto-save-dir "~/.emacs.d/auto-saves/"))
        (unless (file-exists-p backup-dir) (make-directory backup-dir t))
        (unless (file-exists-p auto-save-dir) (make-directory auto-save-dir t))
        (setq backup-directory-alist `(("." . ,backup-dir)))
        (setq auto-save-file-name-transforms `((".*" ,auto-save-dir t))))

      ;; Dired (use BSD-compatible flags on macOS)
      (setq dired-listing-switches
            (if (eq system-type 'darwin) "-alh" "-alh --group-directories-first"))
      (setq dired-dwim-target t)
      (setq dired-kill-when-opening-new-dired-buffer t)
      (add-hook 'dired-mode-hook #'nerd-icons-dired-mode)

      ;; Ediff side-by-side
      (setq ediff-window-setup-function 'ediff-setup-windows-plain)
      (setq ediff-split-window-function 'split-window-horizontally)

      ;; Xref with completing-read (integrates with vertico)
      (setq xref-show-definitions-function #'xref-show-definitions-completing-read)
      (setq xref-show-xrefs-function #'xref-show-definitions-completing-read)

      ;; Better zap-to-char
      (global-set-key (kbd "M-z") 'zap-up-to-char)

      ;; Minibuffer
      (setq enable-recursive-minibuffers t)
      (minibuffer-depth-indicate-mode 1)

      ;; Compilation
      (setq compilation-scroll-output t)
      (setq compilation-ask-about-save nil)

      ;; Font
      (set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 140)

      ;; Theme
      (require 'doom-themes)
      (load-theme 'doom-tokyo-night t)
      (doom-themes-org-config)
      (doom-themes-treemacs-config)

      ;; Nerd icons
      (require 'nerd-icons)

      ;; Doom modeline
      (require 'doom-modeline)
      (setq doom-modeline-icon t)
      (doom-modeline-mode 1)

      ;; GCMH - Garbage Collection Magic Hack
      (require 'gcmh)
      (gcmh-mode 1)

      ;; macOS path
      (when (memq window-system '(mac ns x))
        (exec-path-from-shell-initialize))

      ;; Evil mode
      (setq evil-want-integration t)
      (setq evil-want-keybinding nil)
      (setq evil-want-C-u-scroll t)
      (setq evil-want-Y-yank-to-eol t)
      (require 'evil)
      (evil-mode 1)
      (evil-collection-init)
      (global-evil-surround-mode 1)
      (evil-commentary-mode 1)

      ;; Vertico (vertical completion)
      (require 'vertico)
      (vertico-mode 1)
      (setq vertico-cycle t)
      (setq vertico-count 15)

      ;; Marginalia (annotations)
      (require 'marginalia)
      (marginalia-mode 1)

      ;; Orderless (fuzzy matching)
      (require 'orderless)
      (setq completion-styles '(orderless basic))
      (setq completion-category-overrides '((file (styles partial-completion))))

      ;; Consult (search/navigation)
      (require 'consult)
      (global-set-key (kbd "C-s") 'consult-line)
      (global-set-key (kbd "C-x b") 'consult-buffer)
      (global-set-key (kbd "M-g g") 'consult-goto-line)
      (global-set-key (kbd "M-g M-g") 'consult-goto-line)
      (global-set-key (kbd "M-s r") 'consult-ripgrep)
      (global-set-key (kbd "M-s f") 'consult-find)

      ;; Corfu (completion at point)
      (require 'corfu)
      (global-corfu-mode 1)
      (setq corfu-auto t)
      (setq corfu-auto-delay 0.1)
      (setq corfu-auto-prefix 1)
      (setq corfu-cycle t)
      (setq corfu-preselect 'prompt)

      ;; Cape (completion backends)
      (require 'cape)
      (add-to-list 'completion-at-point-functions #'cape-file)
      (add-to-list 'completion-at-point-functions #'cape-dabbrev)

      ;; Nerd icons for corfu
      (require 'nerd-icons-corfu)
      (add-to-list 'corfu-margin-formatters #'nerd-icons-corfu-formatter)

      ;; Nerd icons for completion
      (require 'nerd-icons-completion)
      (nerd-icons-completion-mode 1)
      (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup)

      ;; Projectile
      (require 'projectile)
      (projectile-mode +1)
      (setq projectile-completion-system 'default)
      (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

      ;; Consult-projectile
      (require 'consult-projectile)

      ;; Which-key
      (require 'which-key)
      (which-key-mode)
      (setq which-key-idle-delay 0.3)

      ;; General (keybinding)
      (require 'general)
      (general-create-definer my-leader-def
        :keymaps '(normal visual emacs)
        :prefix "SPC"
        :global-prefix "C-SPC")

      (my-leader-def
        ;; Files
        "f"  '(:ignore t :which-key "files")
        "ff" '(find-file :which-key "find file")
        "fr" '(consult-recent-file :which-key "recent files")
        "fp" '(consult-projectile :which-key "project files")
        "fs" '(save-buffer :which-key "save")

        ;; Buffers
        "b"  '(:ignore t :which-key "buffers")
        "bb" '(consult-buffer :which-key "switch buffer")
        "bd" '(kill-current-buffer :which-key "kill buffer")
        "bi" '(ibuffer :which-key "ibuffer")

        ;; Search
        "s"  '(:ignore t :which-key "search")
        "ss" '(consult-line :which-key "search line")
        "sp" '(consult-ripgrep :which-key "ripgrep project")
        "si" '(consult-imenu :which-key "imenu")

        ;; Project
        "p"  '(:ignore t :which-key "project")
        "pp" '(projectile-switch-project :which-key "switch project")
        "pf" '(consult-projectile :which-key "find file")
        "ps" '(consult-ripgrep :which-key "search")
        "pb" '(consult-project-buffer :which-key "buffers")

        ;; Git
        "g"  '(:ignore t :which-key "git")
        "gg" '(magit-status :which-key "status")
        "gb" '(magit-blame :which-key "blame")
        "gl" '(magit-log-current :which-key "log")
        "gt" '(git-timemachine :which-key "timemachine")

        ;; Code/LSP
        "c"  '(:ignore t :which-key "code")
        "ca" '(eglot-code-actions :which-key "actions")
        "cr" '(eglot-rename :which-key "rename")
        "cf" '(eglot-format :which-key "format")
        "cd" '(xref-find-definitions :which-key "definition")
        "cR" '(xref-find-references :which-key "references")

        ;; Window
        "w"  '(:ignore t :which-key "window")
        "ww" '(ace-window :which-key "switch")
        "wd" '(delete-window :which-key "delete")
        "ws" '(split-window-below :which-key "split horizontal")
        "wv" '(split-window-right :which-key "split vertical")
        "wm" '(delete-other-windows :which-key "maximize")

        ;; Toggle
        "t"  '(:ignore t :which-key "toggle")
        "tt" '(treemacs :which-key "treemacs")
        "tv" '(vterm :which-key "terminal")
        "tn" '(display-line-numbers-mode :which-key "line numbers")

        ;; Quit
        "q"  '(:ignore t :which-key "quit")
        "qq" '(save-buffers-kill-terminal :which-key "quit")
        "qr" '(restart-emacs :which-key "restart"))

      ;; Magit
      (global-set-key (kbd "C-x g") 'magit-status)

      ;; Diff-hl (git gutter)
      (require 'diff-hl)
      (global-diff-hl-mode 1)
      (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
      (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh)

      ;; Ace-window
      (require 'ace-window)
      (global-set-key (kbd "M-o") 'ace-window)
      (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))

      ;; Expand region
      (global-set-key (kbd "C-=") 'er/expand-region)

      ;; Multiple cursors
      (global-set-key (kbd "C->") 'mc/mark-next-like-this)
      (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
      (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

      ;; Undo tree
      (require 'undo-tree)
      (global-undo-tree-mode)
      (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))
      (evil-set-undo-system 'undo-tree)

      ;; Avy (jump to char)
      (global-set-key (kbd "C-;") 'avy-goto-char-timer)
      (global-set-key (kbd "M-g w") 'avy-goto-word-1)

      ;; Treemacs
      (require 'treemacs)
      (require 'treemacs-evil)
      (require 'treemacs-projectile)
      (require 'treemacs-magit)
      (setq treemacs-width 35)
      (global-set-key (kbd "C-x t t") 'treemacs)

      ;; Rainbow delimiters
      (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

      ;; Helpful
      (require 'helpful)
      (global-set-key (kbd "C-h f") #'helpful-callable)
      (global-set-key (kbd "C-h v") #'helpful-variable)
      (global-set-key (kbd "C-h k") #'helpful-key)
      (global-set-key (kbd "C-h x") #'helpful-command)

      ;; Vterm
      (require 'vterm)
      (setq vterm-max-scrollback 10000)
      (global-set-key (kbd "C-c t") 'vterm)

      ;; Envrc (direnv integration)
      (require 'envrc)
      (envrc-global-mode 1)

      ;; Eglot (LSP)
      (require 'eglot)
      (add-hook 'rust-mode-hook 'eglot-ensure)
      (add-hook 'go-mode-hook 'eglot-ensure)
      (add-hook 'nix-mode-hook 'eglot-ensure)
      (add-hook 'typescript-mode-hook 'eglot-ensure)
      (add-hook 'python-mode-hook 'eglot-ensure)
      (add-hook 'lua-mode-hook 'eglot-ensure)
      (add-hook 'web-mode-hook 'eglot-ensure)
      (add-hook 'erlang-mode-hook 'eglot-ensure)
      (add-hook 'elixir-mode-hook 'eglot-ensure)
      (add-hook 'zig-mode-hook 'eglot-ensure)

      (setq eglot-autoshutdown t)
      (setq eglot-confirm-server-initiated-edits nil)

      ;; Eglot + Corfu integration
      (setq eglot-stay-out-of '(company))

      ;; Flycheck + Eglot
      (require 'flycheck)
      (require 'flycheck-eglot)
      (global-flycheck-eglot-mode 1)

      ;; Treesitter - grammars installed via Nix (treesit-grammars.with-all-grammars)
      ;; Map to treesitter modes when available
      (setq major-mode-remap-alist
            '((bash-mode . bash-ts-mode)
              (sh-mode . bash-ts-mode)
              (c-mode . c-ts-mode)
              (c++-mode . c++-ts-mode)
              (css-mode . css-ts-mode)
              (go-mode . go-ts-mode)
              (java-mode . java-ts-mode)
              (js-mode . js-ts-mode)
              (javascript-mode . js-ts-mode)
              (json-mode . json-ts-mode)
              (python-mode . python-ts-mode)
              (ruby-mode . ruby-ts-mode)
              (rust-mode . rust-ts-mode)
              (toml-mode . toml-ts-mode)
              (typescript-mode . typescript-ts-mode)
              (yaml-mode . yaml-ts-mode)))

      ;; Org mode
      (require 'org-bullets)
      (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
      (setq org-hide-leading-stars t)
      (setq org-startup-indented t)
      (setq org-return-follows-link t)
      (setq org-startup-with-inline-images t)

      ;; Org-roam (only if directory exists)
      (require 'org-roam)
      (setq org-roam-directory "~/org-roam")
      (setq org-roam-completion-everywhere t)
      (when (file-directory-p org-roam-directory)
        (org-roam-db-autosync-mode 1))
      (global-set-key (kbd "C-c n f") 'org-roam-node-find)
      (global-set-key (kbd "C-c n i") 'org-roam-node-insert)
      (global-set-key (kbd "C-c n l") 'org-roam-buffer-toggle)

      ;; Electric pair
      (electric-pair-mode 1)

      ;; Delete trailing whitespace on save
      (add-hook 'before-save-hook 'delete-trailing-whitespace)

      ;; Save minibuffer history
      (savehist-mode 1)

      ;; Remember cursor position
      (save-place-mode 1)

      ;; Recent files
      (recentf-mode 1)
      (setq recentf-max-saved-items 100)
    '';
  };

  # LSP servers and tools (shared with Neovim)
  home.packages = lsp.servers ++ lsp.tools;
}
