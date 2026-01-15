# Emacs configuration
{ config, pkgs, lib, ... }:

{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      # Completion
      ivy
      counsel
      swiper
      company
      prescient
      ivy-prescient
      company-prescient

      # Navigation
      projectile
      counsel-projectile
      dumb-jump
      avy

      # Git
      magit
      git-timemachine
      git-gutter

      # Editing
      expand-region
      multiple-cursors
      undo-tree
      which-key

      # Visual
      rainbow-delimiters
      highlight-parentheses
      doom-modeline
      doom-themes
      all-the-icons

      # Syntax/Linting
      flycheck

      # macOS
      exec-path-from-shell

      # Org
      org-bullets
    ];

    extraConfig = ''
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
      (setq scroll-margin 8)
      (setq scroll-conservatively 101)
      (global-hl-line-mode t)
      (setq make-backup-files nil)
      (setq auto-save-default nil)
      (setq create-lockfiles nil)
      (fset 'yes-or-no-p 'y-or-n-p)
      (setq-default fill-column 100)
      (global-auto-revert-mode t)

      ;; Font
      (set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 140)

      ;; Theme
      (require 'doom-themes)
      (load-theme 'doom-one t)
      (doom-themes-org-config)

      ;; Doom modeline
      (require 'doom-modeline)
      (doom-modeline-mode 1)

      ;; macOS path
      (when (memq window-system '(mac ns x))
        (exec-path-from-shell-initialize))

      ;; Ivy/Counsel/Swiper
      (ivy-mode 1)
      (setq ivy-use-virtual-buffers t)
      (setq ivy-count-format "(%d/%d) ")
      (global-set-key (kbd "C-s") 'swiper)
      (global-set-key (kbd "M-x") 'counsel-M-x)
      (global-set-key (kbd "C-x C-f") 'counsel-find-file)
      (global-set-key (kbd "C-x b") 'ivy-switch-buffer)

      ;; Prescient (better sorting)
      (ivy-prescient-mode 1)
      (company-prescient-mode 1)
      (prescient-persist-mode 1)

      ;; Company
      (global-company-mode t)
      (setq company-idle-delay 0.1)
      (setq company-minimum-prefix-length 1)

      ;; Projectile
      (projectile-mode +1)
      (setq projectile-completion-system 'ivy)
      (define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
      (counsel-projectile-mode 1)

      ;; Which-key
      (which-key-mode)
      (setq which-key-idle-delay 0.5)

      ;; Magit
      (global-set-key (kbd "C-x g") 'magit-status)

      ;; Git gutter
      (global-git-gutter-mode +1)

      ;; Expand region
      (global-set-key (kbd "C-=") 'er/expand-region)

      ;; Multiple cursors
      (global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
      (global-set-key (kbd "C->") 'mc/mark-next-like-this)
      (global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
      (global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

      ;; Undo tree
      (global-undo-tree-mode)
      (setq undo-tree-history-directory-alist '(("." . "~/.emacs.d/undo")))

      ;; Avy (jump to char)
      (global-set-key (kbd "C-;") 'avy-goto-char-timer)

      ;; Dumb jump
      (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)

      ;; Rainbow delimiters
      (add-hook 'prog-mode-hook #'rainbow-delimiters-mode)

      ;; Highlight parentheses
      (add-hook 'prog-mode-hook #'highlight-parentheses-mode)

      ;; Flycheck
      (global-flycheck-mode)

      ;; Org mode
      (require 'org-bullets)
      (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
      (setq org-hide-leading-stars t)
      (setq org-startup-indented t)

      ;; Electric pair
      (electric-pair-mode 1)

      ;; Delete trailing whitespace on save
      (add-hook 'before-save-hook 'delete-trailing-whitespace)
    '';
  };
}
