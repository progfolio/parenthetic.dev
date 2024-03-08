;; -*- lexical-binding: t; -*-
;;(require 'elpaca-installer)
(require 'build)
;;(require 'org)

(setq user-full-name "Nicholas Vollmer"
      user-mail-address "nv@parenthetic.dev"
      make-backup-files nil)

;; (org-link-set-parameters
;;  "yt"
;;  :follow (lambda (handle) (browse-url (concat "https://www.youtube.com/watch?v=" handle)))
;;  :export (lambda (path desc backend channel)
;;            (when (eq backend 'html) (build-embedded-video path))))

(message "Building from %s" (expand-file-name user-emacs-directory))
(build-site)
