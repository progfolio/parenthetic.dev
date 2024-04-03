;; -*- lexical-binding: t; -*-
(require 'elpaca-installer)
(elpaca (mel :host github :repo "progfolio/mel") (require 'mel))
(elpaca-wait)

(setq user-full-name "Nicholas Vollmer"
      user-mail-address "nv@parenthetic.dev"
      make-backup-files nil)

(let* ((default-directory (or (getenv "BASE_DIR") (expand-file-name "../")))
       (build-dir (expand-file-name "./build/"))
       (content-dir (expand-file-name "./content")))
  (message "BUILD-DIR: %s" build-dir)
  (message "CONTENT-DIR: %s" content-dir)
  (unless (file-exists-p build-dir) (make-directory build-dir))
  (cl-loop for dir in '("./assets")
           do (copy-directory
               dir (expand-file-name (file-name-nondirectory dir) build-dir)
               nil 'parents 'copy-contents))
  (cl-loop
   with main = "./templates/main.htmel"
   with mel-print-compact = t
   for file in (append (directory-files-recursively content-dir "index.mel" 'with-dirs)
                       (directory-files (expand-file-name "./articles" content-dir)
                                        'full "\\.md\\'"))
   for mel-data = `((content . ,file))
   for page = (expand-file-name (replace-regexp-in-string content-dir "./" file) build-dir)
   for dir = (file-name-directory page)
   do (message "Building: %s" file)
   (with-temp-buffer
     (insert (mel '(:raw "<!DOCTYPE html>\n") (mel-read main))) (unless (file-exists-p dir) (make-directory dir 'parents))
     (write-file (concat (file-name-sans-extension page) ".html")))))

;; Local Variables:
;; compile-command: "emacs --batch -L . -l init.el"
;; End:
