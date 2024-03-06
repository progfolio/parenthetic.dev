---
title: "Creating static websites with Elisp"
date:  "2020-04-10"
description: "A simple test of my elisp-based static site generator."
---

I'm writing this site using a custom static site generator written in elisp.
HTML is generated via my templating library [Mel](https://www.github.com/progfolio/mel).
Mel transforms a sexp-based syntax into a syntax Emacs's built-in dom.el can interpret.
e.g.

```mel append OUTPUT
(mel-node '(p@identified.classy [:data t] "A classy paragraph with an ID and attributes."))
```

Which produces:

OUTPUT

There's also the `mel` function which converts directly to a printed representation:

```mel append OUTPUT html literal
(let ((mel-print-compact nil))
  (mel '(.example (p "Hello, World."))))
```

OUTPUT

### Code blocks

The site generator implements a custom mel file reader for markdown files which parses markdown frontmatter so it can be injected into mel's templates. This article's frontmatter:

```emacs-lisp replace markdown
  (with-temp-buffer (insert-file-contents "./testing.md")
    (narrow-to-region (point-min) (goto-line 6))
    (buffer-string))
```

provides the pages title, and metadata.
Which is bound to `mel-data` and accessible via `mel-get` and `mel-set` in templates.
The main template makes use of this information:

```emacs-lisp replace mel
(with-temp-buffer
  (insert-file-contents "../../templates/main.htmel")
  (buffer-string))
```
