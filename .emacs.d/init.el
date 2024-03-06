;; -*- lexical-binding: t; -*-
(require 'elpaca-installer)
(elpaca (mel :host github :repo "progfolio/mel") (require 'mel))
(elpaca (htmlize :host github :repo "hniksic/emacs-htmlize") (require 'htmlize))
(elpaca (markdown-mode :host github :repo "jrblevin/markdown-mode") (require 'markdown-mode))
(with-timeout (60 (error "Package Installation Timeout")) (elpaca-wait))
(elpaca-test-log "#unique")

(setq user-full-name "Nicholas Vollmer"
      user-mail-address "nv@parenthetic.dev"
      make-backup-files nil)

(defun markdown-frontmatter-p ()
  "Return end position of markdown frontmatter in `current-buffer' or nil."
  (and (string-prefix-p "---" (buffer-string))
       (save-excursion (forward-line) (re-search-forward "^--- *" nil 'noerror))))

(defun parse-frontmatter ()
  "Return alist of frontmatter KEY VALs in `current-buffer'."
  (save-excursion
    (goto-char (point-min))
    (when-let ((frontmatter (markdown-frontmatter-p))
               (name (or (buffer-file-name) (buffer-name))))
      (forward-line)
      (save-restriction
        (narrow-to-region (point) frontmatter)
        (let ((data nil))
          (while (not (eobp))
            (when-let ((end (line-end-position))
                       (separator (re-search-forward ":" end 'noerror)))
              (push (cons (intern (buffer-substring-no-properties (line-beginning-position) (1- separator)))
                          (read (buffer-substring-no-properties (1+ separator) end)))
                    data))
            (forward-line))
          data)))))

(defun slug (string)
  "Return URL slug from STRING."
  (downcase
   (replace-regexp-in-string
    "," ""
    (replace-regexp-in-string "[ ]+" "-" string))))

(defun markdown-htmlize ()
  "Render all code fenced regions with syntax highlighting."
  (let ((htmlize-output-type 'css)
        (htmlize-pre-style t)
        append)
    (save-excursion
      (goto-char (point-min))
      (while-let ((fence "\\(?:^```[[:space:]]*?\\([^z-a]*?\\)$\\)")
                  ((re-search-forward fence nil 'noerror))
                  (beg (point))
                  (lang (split-string (match-string 1)))
                  (mode (intern (concat (car lang) "-mode")))
                  (end (and (re-search-forward fence nil 'noerror)
                            (re-search-backward fence)
                            (point)))
                  (block (buffer-substring-no-properties beg end))
                  (html (with-temp-buffer
                          (insert (string-trim block))
                          (goto-char (point-max))
                          (if (functionp mode)
                              (funcall mode)
                            (user-error "No mode for markdown fence lang %s" mode))
                          (font-lock-mode)
                          (font-lock-ensure)
                          (when-let ((info (nth 1 lang)))
                            (let ((result (eval (read (buffer-string)) t)))
                              (cond
                               ((equal info "replace")
                                (when-let ((mode (nth 2 lang))
                                           (modesym (intern (concat mode "-mode"))))
                                  (if (not (functionp modesym))
                                      (user-error "No mode for replacement type %s" modesym)
                                    (funcall modesym))
                                  (delete-region (point-min) (point-max))
                                  (insert result)
                                  (font-lock-mode)
                                  (font-lock-ensure)))
                               ((equal info "append") (setq append result)))))
                          (let ((htmlbuf (htmlize-region (point-min) (point-max))))
                            (unwind-protect
                                (with-current-buffer htmlbuf
                                  (buffer-substring (plist-get htmlize-buffer-places 'content-start)
                                                    (plist-get htmlize-buffer-places 'content-end)))
                              (kill-buffer htmlbuf))))))
        (delete-region (progn (goto-char beg) (line-beginning-position))
                       (progn (goto-char end) (line-end-position)))
        (insert html)
        (when append (save-excursion
                       (let ((block (format (concat "\n```%s\n"
                                                    (if (equal (nth 4 lang) "literal") "%s" "%S")
                                                    "\n```\n")
                                            (or (nth 3 lang) (car lang)) append)))
                         (if-let ((target (nth 2 lang)))
                             (and (re-search-forward target) (replace-match block 'fixed-case 'literal))
                           (insert block)))
                       (setq append nil)))))))

(defun markdown-article ()
  "Return HTML from markdown article with frontmatter.
Sets `mel-data'"
  (save-restriction
    (widen)
    (cl-loop for (k . v) in (parse-frontmatter) do (mel-set k v))
    (mel-set 'file (buffer-file-name)) (goto-char (point-max)) (re-search-backward "---" nil 'noerror)
    (forward-line)
    (narrow-to-region (point) (point-max))
    (let ((content (buffer-string))
          (f (buffer-file-name)))
      (with-temp-buffer
        (insert content)
        (message "HTMLIZING: %s" f)
        (markdown-htmlize)
        (mel-markdown)))))

(let* ((default-directory (or (getenv "BASE_DIR")
                              (and (require 'vc-git)
                                   (vc-git-root default-directory))))
       (build-dir (expand-file-name "./build/"))
       (content-dir (expand-file-name "./content"))
       (mel-readers mel-readers)
       (mel-data nil))
  (setf (alist-get "\\.md\\'" mel-readers nil nil #'equal) #'markdown-article)
  (message "BUILD:   %s" build-dir)
  (message "CONTENT: %s" content-dir)
  (unless (file-exists-p build-dir) (make-directory build-dir))
  (cl-loop for dir in '("./assets")
           do (copy-directory
               dir (expand-file-name (file-name-nondirectory dir) build-dir)
               nil 'parents 'copy-contents))
  (cl-loop
   with main = (expand-file-name "./templates/main.htmel")
   with mel-print-compact = t
   for file in (append (directory-files-recursively content-dir "index.mel" 'with-dirs)
                       (directory-files (expand-file-name "./articles" content-dir)
                                        'full "\\.md\\'"))
   for page = (expand-file-name (replace-regexp-in-string content-dir "./" file) build-dir)
   for dir = (file-name-directory page)
   for mel-data = nil
   for base = (file-name-base file)
   for dest = (progn
                (message "Building: %s" file)
                (mel-set 'content (mel-read file))
                (concat (if-let ((title (and (not (string-match-p "index\\.\\'" file))
                                             (mel-get 'title))))
                            (slug title)
                          (file-name-sans-extension page))
                        ".html"))
   do
   (mel-set 'url
            (replace-regexp-in-string
             "index.html$" ""
             (replace-regexp-in-string (regexp-quote build-dir)
                                       "https://www.parenthetic.dev/"
                                       (expand-file-name dest dir))))
   (with-temp-buffer
     (insert (mel '(:raw "<!DOCTYPE html>\n") (mel-read main)))
     (unless (file-exists-p dir) (make-directory dir 'parents))
     (message "WRITING: %s \n  @ %s" (expand-file-name dest dir) (mel-get 'url))
     (write-file (expand-file-name dest dir)))))
