;; pslm-mode
;;
;; Emacs mode with syntax-highlighting for our psalm files

(require 'generic-x)

(define-generic-mode 
  'pslm-mode                    ;; name of the mode
  '()                           ;; comments delimiter
  '()                           ;; some keywords
  '(("\\(# .*\\)" 1 'font-lock-comment-face) ;; comments
    ("\\[[^\\[]*\\]" . 'font-lock-function-name-face)                ;; accents
    ("[/*+]" . 'font-lock-builtin-face)      ;; syllable division, *, +
    )
  '("\\.pslm$")                     ;; files that trigger this mode
   nil                              ;; any other functions to call
  "Generic mode for syntax highlighting in psalm files"     ;; doc string
)
