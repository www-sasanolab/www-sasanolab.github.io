(require 'kmyacconv-sample-mode-data)
(require 'kmyacconv-sample-mode-tokenizer)

;;define key map
(defvar kmyacconv-sample-mode-map nil)
(setq kmyacconv-sample-mode-map (make-sparse-keymap))
(define-key kmyacconv-sample-mode-map "\C-xt" 'tokenize-all)
(define-key kmyacconv-sample-mode-map "\C-xp" 'parse-test)



(defun token2string (token)
  (let ((sym (cdr (assoc 'symbol token)))
	(val (cdr (assoc 'value token))))
     (when (eq sym 'ID)
      (if (eq val nil)
	  (setq val "cursor")
	(setq val (replace-regexp-in-string "%" "％" val))))
    
    (cond
     ((eq sym 'ID) (concat "ID_(" val ")"))
     ((eq sym 'INT) (concat "INT(" val ")"))
     ((eq sym 'STRING) (concat "STRING(" val ")"))
     (t (substring (format "%s" sym) 0 (length (format "%s" sym)))))))


(defun tokenize-all ()
  (interactive)
  (save-excursion
    (let ((pos (init-tokenizer))
	  (tokens ""))
      (while 
	  (let* ((token (kmyacconv-sample-mode-tokenizer pos))
		(sym (cdr (assoc 'symbol token)))
		(val (cdr (assoc 'value token))))
	    
	    ;(message (format "F3::%s" sym ))
	    
	    ;;(setq tokens (replace-regexp-in-string "%" "%%" tokens))
	    (setq tokens (format "%s %s," tokens (token2string token) ))
	    (if (eql '$EOF (cdr (assoc 'symbol token)))
		nil t)))
      (message tokens))))

(defun kmyacconv-sample-parser ()
  (let* (action
	 (tokenizer-pos (init-tokenizer))
	 (token (kmyacconv-sample-mode-tokenizer tokenizer-pos))
	 (loop-flg t)
	 (accept nil)
	 (reduce-seq nil)
	 (stack-symbol nil)
	 (stack (list 0)))
    (while loop-flg
      (message (format "ga: token:%s" token))
      (setq action (get-action (get-token-symbol token)))
 
      (print-stack-and-symbol)
      (cond 
       ((eq 'shift (car action))
	;;shift
	;(message (format "shift %s" (cdr action)))
	(stack-symbol-push token)
	(stack-push (cdr action))
	(setq token (kmyacconv-sample-mode-tokenizer tokenizer-pos)))

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
	  (stack-symbol-push (list 
			      (cons 'symbol nonterminal)
			      (cons 'value value)))
	  (stack-push (cdr action))
	  (print-stack-and-symbol)))

       ((eq 'accept (car action))
	(message "accept.")
	(setq accept t)
	(setq loop-flg nil))

       (t
	(message "syntax error.")
	(setq loop-flg nil))))
    (if accept reduce-seq nil)))

(defun get-value (args n)
  (if (eq n 1)
      (car args)
    (get-value (cdr args) (- n 1))))
  

(defun print-stack-and-symbol ()
  (message (stack-to-text  stack stack-symbol)))

(defun stack-to-text (stack stack-symbol)
  (if (cdr stack)
      (format "%s [%s] %s" 
	      (stack-to-text (cdr stack) (cdr stack-symbol))
	       (cdr (assoc 'symbol (car stack-symbol))) (car stack))
    (format "%s" (car stack))))


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

(defun parse-test ()
  (interactive)
  (let ((result  (kmyacconv-sample-parser)))
    (message (format "%s" result))))

;;entry point
(defun kmyacconv-sample-mode ()
  "Test Mode "
  (interactive)
  (kill-all-local-variables)
  (setq mode-name "Kmyacconv sample")
  (setq major-mode 'kmyacconv-sample-mode)
  (message "Kmyacconv Sample!!")
  ;;キーマップの登録
  (use-local-map kmyacconv-sample-mode-map)
  (run-hooks 'kmyacconv-sample-mode-hook))
 
(provide 'kmyacconv-sample-mode)
