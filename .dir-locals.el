((nil . ((compile-command . (let* ((root (vc-git-root (buffer-file-name)))
                                   (dir (expand-file-name ".emacs.d" root)))
                              (format "cd %s && emacs --batch -L %s  -l %s/init.el" (expand-file-name root) dir dir))))))
