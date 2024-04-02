;; -*- lexical-binding: t; -*-
(require 'elpaca-installer)
(elpaca (mel :host github :repo "progfolio/mel") (require 'mel))
(elpaca-wait)
;;(require 'org)
;; (org-link-set-parameters
;;  "yt"
;;  :follow (lambda (handle) (browse-url (concat "https://www.youtube.com/watch?v=" handle)))
;;  :export (lambda (path desc backend channel)
;;            (when (eq backend 'html) (build-embedded-video path))))


(setq user-full-name "Nicholas Vollmer"
      user-mail-address "nv@parenthetic.dev"
      make-backup-files nil)

(message "Building from %s" (expand-file-name user-emacs-directory))

(with-temp-buffer
  (let* ((mel-data '((content . "./landing-page.mel")))
         (mel-print-compact t))
    (insert (mel '(:raw "<!DOCTYPE html>\n")
                 (mel-read "./assets/main.htmel")))
    (write-file "./index.html")))
