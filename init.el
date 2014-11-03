
;; This sets up the load path so that we can override it
(package-initialize nil)

;; Override the package with the git version of Org and other packages
(add-to-list 'load-path "~/elisp/org-mode/lisp")
(add-to-list 'load-path "~/elisp/org-mode/contrib/lisp")

;; Load the rest of the packages
(package-initialize t)
(setq package-enable-at-startup nil)
(require 'org)
(require 'ob-tangle)
(org-babel-load-file (expand-file-name "~/.emacs.d/xyz.org"))
