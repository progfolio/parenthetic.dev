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

(with-current-buffer (get-buffer-create "index.html")
  (erase-buffer)
  (let ((standard-output (current-buffer))
        print-circle print-level print-length)
    (insert
     "<!DOCTYPE html>\n"
     (apply #'mel (mel-read "./.emacs.d/parking-page.mel")))
    (write-file "./index.html")))
