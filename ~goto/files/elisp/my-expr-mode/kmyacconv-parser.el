(require 'my-expr-tokenizer)
(require 'my-expr-parser-data)

(defun my-expr-parser ()
  (let* (action
	 (tokenizer-pos (init-tokenizer))
	 (token (my-expr-tokenizer tokenizer-pos))
	 (loop-flg t)
	 (accept nil)
	 result
	 (stack-symbol nil)
	 (stack (list 0)))
    (while loop-flg
      (setq action (get-action (get-token-symbol token)))
 
      (cond 
       ((eq 'shift (car action))
	;;shift
	;(message (format "shift %s" (cdr action)))
	(stack-symbol-push token)
	(stack-push (cdr action))
	(setq token (my-expr-tokenizer tokenizer-pos)))

       ((eq 'reduce (car action))
	;;reduce
	;(message (format "reduce with %s" (cdr action)))
	
	(let ((nonterminal (aref rule-to-nonterminal
				 (cdr action)))
	      (value (let ((i 0)
			   (poped nil))
		       (while (< i (aref pop-count (cdr action)))
			 (setq poped (cons (car stack-symbol) poped))
			 (setq stack-symbol (cdr stack-symbol))
			 (setq stack (cdr stack))
			 (setq i (+ 1 i)))
		       (do-action (cdr action) poped))))
	  (setq action (get-action nonterminal))
	  (stack-symbol-push value)
	  (setq result value)
	  (stack-push (cdr action))))

       ((eq 'accept (car action))
	(message "accept.")
	(setq accept t)
	(setq loop-flg nil))

       (t
	(message "syntax error.")
	(setq loop-flg nil))))
    (if accept result nil)))

(defun get-value (args n)
  (if (eq n 1)
      (car args)
    (get-value (cdr args) (- n 1))))

(defun get-action (token-symbol)
  (aref (aref parser-table (car stack))
	(token-to-index token-symbol)))

(defun token-to-index (token-symbol)
  (cdr (assoc token-symbol token-to-index)))

(defun stack-push (state)
  (setq stack (cons state stack)))

(defun stack-symbol-push (symbol)
  (setq stack-symbol (cons symbol stack-symbol)))

(defun get-token-symbol (token)
  (cdr (car token)))

(provide 'kmyacconv-parser)