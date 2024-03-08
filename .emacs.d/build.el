;;; build.el --- site builder                        -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Nicholas Vollmer

;; Author:  Nicholas Vollmer
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:
(require 'dom)
(require 'ox-publish)
(require 'subr-x)
(require 'cl-lib)

(defun build-youtube-embed (id)
  "Return embedded video HTML from ID."
  (build-html-string
   `(div [class video]
         (iframe [ src ,(concat "https://www.youtube.com/embed/" id)
                   allow  fullscreen]))))

(defun build-article-path (file dir)
  "Return article path for FILE at DIR."
  (let ((article (concat dir (downcase
                              (file-name-as-directory
                               (file-name-sans-extension
                                (file-name-nondirectory file)))))))

    (if (string-match-p (concat (regexp-opt '("index.org" "404.org")) "\\'") file)
        dir
      (make-directory article t)
      article)))

(defun build-site ()
  "Build the site."
  (interactive))

(provide 'build)
;;; build.el ends here
