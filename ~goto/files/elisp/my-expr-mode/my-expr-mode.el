(require 'kmyacconv-parser)
(require 'my-expr-rename)

;;define key map
(defvar my-expr-mode-map nil)
(setq my-expr-mode-map (make-sparse-keymap))
(define-key my-expr-mode-map "\C-xp" 'rename-variable)

(defun parse-test ()
  (interactive)
  (let ((result  (my-expr-parser)))
    (message (format "%s" result))))

(defun rename-variable ()
  (interactive)
  (let ((cursor-position (point))
	(ast (save-excursion (my-expr-parser)))
	replace-with)
    (when ast
      (let* ((vmap (make-variable-map ast))
	    (pointed-variable (get-variable-pointed-by-cursor cursor-position vmap)))
	(if (not pointed-variable)
	    (message "there is no variables pointed by cursor")
	  (setq replace-with (read-from-minibuffer (format "replace %s with:" (car pointed-variable))))
	  
	  (let* ((variables-to-replace (enumerate-variables-to-replace vmap pointed-variable)))
	    (replace-variables variables-to-replace replace-with)
	    (message "replaced")))))))

;;entry point
(defun my-expr-mode ()
  "Test Mode "
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "EXP-mode")
  (setq major-mode 'my-expr-mode)
  (message "expr!!")
  ;;キーマップの登録
  (use-local-map my-expr-mode-map)
  (run-hooks 'my-expr-mode-hook))
 
(provide 'my-expr-mode)

