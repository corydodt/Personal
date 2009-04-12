(custom-set-variables
 '(require-final-newline t)
 '(paren-mode (quote sexp) nil (paren))
 '(fill-column 78)
 '(column-number-mode t)
 '(line-number-mode t)
 '(user-mail-address "cory@CORY2K")
 '(modeline-3d-p nil)
 '(query-user-mail-address nil))
(custom-set-faces
 '(default ((t (:foreground "#e4e4e4" :background "black" :size "10pt" :family "Bitstream Vera Sans Mono"))) t)
 '(secondary-selection ((t (:foreground "#666666" :background "paleturquoise"))) t)
 '(widget-field-face ((((class grayscale color) (background light)) (:foreground "#666666" :background "gray85"))))
 '(font-lock-string-face ((((class color) (background light)) (:foreground "#22ff88" :background "#002000"))))
 '(custom-comment-face ((((class grayscale color) (background light)) (:foreground "black" :background "gray85"))))
 '(font-lock-variable-name-face ((((class color) (background light)) (:foreground "orange"))))
 '(paren-match ((t (:foreground "darkseagreen2" :background "#383838"))) t)
 '(font-lock-keyword-face ((((class color) (background light) (type mswindows)) (:foreground "#5588ff" :background "#151515" :bold t))))
 '(font-lock-type-face ((((class color) (background light)) (:foreground "#cc6060"))))
 '(primary-selection ((t (:foreground "#666666" :background "gray65"))) t)
 '(list-mode-item-selected ((t (:background "gray34"))) t)
 '(font-lock-comment-face ((((class color) (background light) (type mswindows)) (:foreground "#11a8a0" :italic t))))
 '(font-lock-function-name-face ((((class color) (background light) (type mswindows)) (:foreground "#d888e3"))))
 '(isearch ((t (:foreground "#333333" :background "paleturquoise"))) t)
 '(Default ((t nil)) t)
 '(highlight ((t (:foreground "black" :background "darkseagreen2"))) t)
 '(dired-face-boring ((((type x pm mswindows) (class color grayscale) (background light)) (:foreground "gray60")))))

(global-set-key "\M-j" 'join-line)
(global-set-key "\M-k" 'kill-entire-line)
(global-unset-key "\C-z")

(font-lock-mode 1)
(setq text-mode-hook
      '(lambda () (auto-fill-mode 1)))
(setq python-mode-hook
      '(lambda () (auto-fill-mode 1)))

(setq default-tab-width 4)
(setq-default indent-tabs-mode nil)

;(require 'un-define)
;(set-coding-priority-list '(utf-8))
;(set-coding-category-system 'utf-8 'utf-8)
