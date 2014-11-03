
(setq user-full-name "xyz"
  user-mail-address "xyzlxw@gmail.com")

(add-to-list 'load-path "~/.emacs.d")
(add-to-list 'load-path "~/elisp")
(add-to-list 'load-path "~/elisp/artbollocks-mode")

(add-to-list 'package-archives '("org" . "http://orgmode.org/elpa/") t)
(add-to-list 'package-archives '("melpa" . "http://melpa.milkbox.net/packages/") t)
(add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/") t)

(load "~/.emacs.secrets" t)

(defun xyz/byte-recompile ()
  (interactive)
  (byte-recompile-directory "~/.emacs.d" 0)
  (byte-recompile-directory "~/elisp" 0))

(defun xyz/package-install (package &optional repository)
  "Install PACKAGE if it has not yet been installed.
If REPOSITORY is specified, use that."
  (unless (package-installed-p package)
    (let ((package-archives (if repository
                                (list (assoc repository package-archives))
                              package-archives)))
    (package-install package))))

(xyz/package-install 'use-package)
(require 'use-package)

(defun xyz/org-share-emacs ()
    "Share my Emacs configuration."
    (interactive)
    (let* ((destination-dir "~/baiduyun/public/")
           (destination-filename "xyz-emacs.org"))
      (save-restriction
        (save-excursion
          (widen)
          (write-region (point-min) (point-max) 
            (expand-file-name destination-filename destination-dir))
          (with-current-buffer (find-file-noselect (expand-file-name
                                                    destination-filename destination-dir))
            (org-babel-tangle-file buffer-file-name 
                                   (expand-file-name
                                    "xyz-emacs.el" destination-dir) "emacs-lisp")
            (org-html-export-to-html))))))

(global-set-key (kbd "S-<SPC>") 'set-mark-command)

(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

(setq delete-old-versions -1)
(setq version-control t)
(setq vc-make-backup-files t)
(setq auto-save-file-name-transforms '((".*" "~/.emacs.d/auto-save-list/" t)))

(setq savehist-file "~/.emacs.d/savehist")
(savehist-mode 1)
(setq history-length t)
(setq history-delete-duplicates t)
(setq savehist-save-minibuffer-history 1)
(setq savehist-additional-variables
      '(kill-ring
        search-ring
        regexp-search-ring))

(when window-system
  (tooltip-mode -1)
  (tool-bar-mode -1)
  (menu-bar-mode -1)
  (scroll-bar-mode -1))

(xyz/package-install 'winner)
(use-package winner
  :config (winner-mode 1))

(fset 'yes-or-no-p 'y-or-n-p)

(use-package helm
  :init
  (progn 
    (require 'helm-config) 
    (setq helm-candidate-number-limit 10)
    ;; From https://gist.github.com/antifuchs/9238468
    (setq helm-idle-delay 0.0 ; update fast sources immediately (doesn't).
          helm-input-idle-delay 0.01  ; this actually updates things
                                        ; reeeelatively quickly.
          helm-quick-update t
          helm-M-x-requires-pattern nil
          helm-ff-skip-boring-files t)
    (helm-mode))
  :config
  (progn
    ;; I don't like the way switch-to-buffer uses history, since
    ;; that confuses me when it comes to buffers I've already
    ;; killed. Let's use ido instead.
    (add-to-list 'helm-completing-read-handlers-alist '(switch-to-buffer . ido)))
  :bind (("C-c h" . helm-mini)))
(ido-mode -1) ;; Turn off ido mode in case I enabled it accidentally

(defadvice color-theme-alist (around xyz activate)
  (if (ad-get-arg 0)
      ad-do-it
    nil))
(xyz/package-install 'color-theme)
(xyz/package-install 'color-theme-solarized)
(defun xyz/setup-color-theme ()
  (interactive)
  (color-theme-solarized 'dark)
  (set-face-foreground 'secondary-selection "darkblue")
  (set-face-background 'secondary-selection "lightblue")
  (set-face-background 'font-lock-doc-face "black")
  (set-face-foreground 'font-lock-doc-face "wheat")
  (set-face-background 'font-lock-string-face "black")
  (set-face-foreground 'org-todo "green")
  (set-face-background 'org-todo "black"))
 
(use-package color-theme
  :init
  (when window-system
    (xyz/setup-color-theme)))

(use-package undo-tree
  :init
  (progn
    (global-undo-tree-mode)
    (setq undo-tree-visualizer-timestamps t)
    (setq undo-tree-visualizer-diff t)))

(use-package guide-key
  :init
  (setq guide-key/guide-key-sequence '("C-x r" "C-x 4" "C-c"))
  (guide-key-mode 1))  ; Enable guide-key-mode

(prefer-coding-system 'utf-8)
(when (display-graphic-p)
  (setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING)))

(mapcar
 (lambda (r)
   (set-register (car r) (cons 'file (cdr r))))
 '((?b . "~/baiduyun/public/personal/books.org")
   (?m . "~/mstar/management.org")
   (?l . "~/baiduyun/public/personal/learning.org")
   (?o . "~/baiduyun/public/personal/organizer.org")
   (?p . "~/mstar/projects.org")
   (?r . "~/baiduyun/public/personal/routines.org")
   (?x . "~/.emacs.d/xyz.org")))

(use-package help-swoop
  :bind (("C-S-s" . help-swoop)))

(use-package windmove
  :bind
  (("<f2> <right>" . windmove-right)
   ("<f2> <left>" . windmove-left)
   ("<f2> <up>" . windmove-up)
   ("<f2> <down>" . windmove-down)))

(defun xyz/vsplit-last-buffer (prefix)
  "Split the window vertically and display the previous buffer."
  (interactive "p")
  (split-window-vertically)
  (other-window 1 nil)
  (unless prefix
    (switch-to-next-buffer)))
(defun xyz/hsplit-last-buffer (prefix)
  "Split the window horizontally and display the previous buffer."
  (interactive "p")
  (split-window-horizontally)
  (other-window 1 nil)
  (unless prefix (switch-to-next-buffer)))
(bind-key "C-x 2" 'xyz/vsplit-last-buffer)
(bind-key "C-x 3" 'xyz/hsplit-last-buffer)

(require 'find-dired)
(setq find-ls-option '("-print0 | xargs -0 ls -ld" . "-ld"))

(require 'recentf)
(setq recentf-max-saved-items 200
      recentf-max-menu-items 15)
(recentf-mode)

(bind-key "C-c c" 'org-capture)
(bind-key "C-c a" 'org-agenda)
(bind-key "C-c l" 'org-store-link)
(bind-key "C-c L" 'org-insert-link-global)
(bind-key "C-c O" 'org-open-at-point-global)
(bind-key "<f9> <f9>" 'org-agenda-list)
(bind-key "<f9> <f8>" (lambda () (interactive) (org-capture nil "c")))
(bind-key "C-TAB" 'org-cycle org-mode-map)
(bind-key "C-c v" 'org-show-todo-tree org-mode-map)
(bind-key "C-c C-r" 'org-refile org-mode-map)
(bind-key "C-c r" 'org-reveal org-mode-map)

(setq org-modules '(org-bbdb 
                      org-gnus
                      org-drill
                      org-info
                      org-jsinfo
                      org-habit
                      org-irc
                      org-mouse
                      org-annotate-file
                      org-eval
                      org-expiry
                      org-interactive-query
                      org-man
                      org-panel
                      org-screen
                      org-toc))
(org-load-modules-maybe t)
(setq org-expiry-inactive-timestamps t)

(setq org-directory "~/baiduyun/public/personal")
(setq org-default-notes-file "~/baiduyun/public/personal/organizer.org")

(setq org-capture-templates
  `(("o" "Tasks" entry (file+headline "~/baiduyun/public/personal/organizer.org" "Tasks") "* TODO %?\n %i\n %a")
    ("p" "Projects" entry (file+headline "~/mstar/projects.org" "Tasks") "* TODO %?\n %i\n %a")
    ("do" "Done - Task" entry (file+headline "~/baiduyun/public/personal/organizer.org" "Tasks") "* DONE %?\nSCHEDULED: %^t\n")
    ("dp" "Done - Project" entry (file+headline "~/mstar/projects.org" "Tasks") "* DONE %?\nSCHEDULED: %^t\n")
    ("b" "Book" entry (file+datetree "~/baiduyun/public/personal/books.org" "Inbox") "* %^{Title} %^g\n%i\n%?\nREVIEW: %^t\n %a" :clock-in :clock-resume)
    ("n" "Notes" item (file+datetree "~/baiduyun/public/personal/organizer.org" "Notes"))))

(setq org-todo-keywords
  '((sequence "TODO(t)" "TOBLOG(b)")
    (sequence "STARTED(s)" "WAITING(w@/!)")
    (sequence "SOMEDAY(.)" "|" "DONE(x!)" "CANCELLED(c@)")
    (sequence "TODELEGATE(-)" "DELEGATED(d)")))

(setq org-tag-alist '(("@work" . ?b)
                      ("@home" . ?h)
                      ("@writing" . ?w)
                      ("@errands" . ?e)
                      ("@drawing" . ?d)
                      ("@coding" . ?c)
                      ("@phone" . ?p)
                      ("@reading" . ?r)
                      ("@computer" . ?l)
                      ("@quantified" . ?q)))
