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
;; (require 'elpaca-installer)
;; (elpaca htmlize)

(defun build-site ()
  "Build the site."
  (interactive)
  (with-current-buffer (get-buffer-create "index.html")
    (erase-buffer)
    (let ((standard-output (current-buffer))
          print-circle print-level print-length)
      (insert "<!DOCTYPE html>\n")
      (insert "<html><head><title>(Parenthetic Dev)</title></head><body><h1>HELLO, AGAIN</h1></body></html>")
  (write-file "./index.html"))))

(provide 'build)
;;; build.el ends here
