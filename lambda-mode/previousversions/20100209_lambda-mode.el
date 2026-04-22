;;Time-stamp: <Thu Jan 28 15:00:00 東京 (標準時) 2010>

;;lambda-mode.el version 0.02 
;;


(require 'auto-complete)
(require 'lambda-parse)

(defvar lambda-parse-calc-every-time t)
(defvar lambda-variable-list nil)

;シンタックステーブルの定義
(defvar lambda-mode-syntax-table
  (let ((st (make-syntax-table (standard-syntax-table))))
	;コメント
    (modify-syntax-entry ?\n ">" st)
    ;;(modify-syntax-entry ?; "<" st)
	
    (modify-syntax-entry ?\' "\"" st)
    (modify-syntax-entry ?= "." st)
    (modify-syntax-entry ?\\ "\\" st)
    (modify-syntax-entry ?` "\"" st)



    st)
  "Syntax table in use in `lambda-mode' buffers.")

;省略テーブルの定義
(defvar lambda-mode-abbrev-table nil
	"Abbrev table used while in lambda mode.")

(define-abbrev-table 'lambda-mode-abbrev-table ())

;キーマップの定義
(defvar lambda-mode-map nil)
(if lambda-mode-map
    ()
  (setq lambda-mode-map (make-sparse-keymap))
  (define-key lambda-mode-map "\t" 'indent-according-to-mode);ここ
  (define-key lambda-mode-map [f1] 'test);correspondのテスト
  (define-key lambda-mode-map [f2] 'lambda-autocompletion)
  (define-key lambda-mode-map [f3] 'lambda-ac-update)
  (define-key lambda-mode-map [f4] 'lambda-calc-variable-list)
  (define-key lambda-mode-map [f5] 'toggle-message))

(defvar lambda-ac-sources '(lambda-ac-keywords))

(ac-define-dictionary-source lambda-ac-keywords
			     '("fn" "let" "in" "end"))

(defun lambda-ac-setup ()
  (setq ac-sources lambda-ac-sources))




(defun test ()
  (interactive)
  (correspond "in" "let")
)

;Lambdaモード本体の定義
(defun lambda-mode ()
  "Major mode for editing lambda calculus"
  (interactive)
  (kill-all-local-variables) ;お約束
  (use-local-map lambda-mode-map)
  (setq local-abbrev-table lambda-mode-abbrev-table)
  (set-syntax-table lambda-mode-syntax-table)
  
  ;Lambdaと表示する
  (setq mode-name "Lambda")
  (setq major-mode 'lambda-mode)

  (setq tab-width 1);回避策
  
  ;インデント関数をとりあえずLispのやつで。
  (make-local-variable 'indent-line-function)	
  (setq indent-line-function 'lambda-indent-line-2)

  ;(add-hook 'lambda-mode-hook 'lambda-ac-setup)

  (setq ac-sources '(lambda-ac-update))

  ;;hookを呼ぶ
  (run-hooks 'lambda-mode-hook)
)
(defvar lambda-debug-buffer nil)

(defun lambda-debug-setup ()
  (setq lambda-debug-buffer (get-buffer-create "lambda debug")))
  

(defun lambda-point-bol ()
  (interactive)
  (let ((bol 0))
    (save-excursion
      (beginning-of-line)
      (setq bol (point)))
    (message (format "lambda-point-bol:final: result: %d" bol))
    bol))



(defun lambda-autocompletion ()
  (interactive)
  (let ((current-word (lambda-ac-current-word)))
    (if (not (string= word ""))
	(progn
	  (message (format "lambda-ac:point:%d,word:%s" (point) (current-word)))
	  )
      (message "lambda-ac:---")
    )))



(defun current-time-to-microsec (time)
  (let ((result 0)
	(high (car time))
	(low (car (cdr time)))
	(mil (car (cdr (cdr time)))))
    (setq result (+ (* (+ (* high 2 (* 16 16)) low) 1000) (/ mil 1000)))
    
    result))

(defun time-diff (before after)
  (- (current-time-to-microsec after)
     (current-time-to-microsec before)))
 
(defvar lambda-ac-list
  (list))

(defun lambda-calc-variable-list ()
  (interactive)
  (setq lambda-variable-list (lambda-parse))
  lambda-variable-list)

(defun lambda-parse- ()
  (interactive)
  (my-parser (my-lexer))
  (message ""))

;;ACに表示するリストを作る
(defun lambda-ac-update ()
  (interactive)
  (let ((cp (point))
	(p -1)
	;;(variable-list (lambda-parse))
	variable-list
	candidate 
	candidates
	temp
	(inputing-word (lambda-ac-current-word))
	end-of-current-word
	vl-temp
	(temp-bind max-specpdl-size)
	(temp-depth max-lisp-eval-depth)
	(before-time (current-time))
	after-time)

    (message "ac-update : begin")

    (setq max-specpdl-size 12000000)
    (setq max-lisp-eval-depth 7777777)

    (setq variable-list (if lambda-parse-calc-every-time 
			    (lambda-parse)
			  lambda-variable-list))
	
    (setq vl-temp variable-list)
    (setq max-specpdl-size temp-bind)
    (setq max-lisp-eval-depth temp-depth)
    
    ;(if variable-list
	
    (if variable-list
	(message (format "variable-list: %s " variable-list)))
    ;(message (format "ac-update: inputing-word:%s" inputing-word))

    ;;(lp-print-variables variable-list);;変数一覧

    (setq end-of-current-word (- (point) (length inputing-word)))
    
    (while (car variable-list)
      (setq temp (car variable-list))
      ;;(message (format "v::%s" temp))
      (unless (member temp candidates)
	(if (string-match (format "^%s" inputing-word) temp)
	    (progn
	     
	      (if (and lambda-parse-last-expr-type
		       (get-variable-type (copy-sequence variable-list) temp))
		  (progn
		    ;;(message (format "ac: expect:%s , %s:%s" lambda-parse-last-expr-type
		    ;;(car t emp)  (get-variable-type (copy-sequence variable-list) (car temp))))
		    (if (list= lambda-parse-last-expr-type (get-variable-type (copy-sequence variable-list)  temp))
			(push temp candidates)))
		(push temp candidates)))))
       (setq variable-list (cdr variable-list)))
    

    (setq after-time (current-time))
    
    (message (format "variables:(%s), %s microsec." vl-temp  (time-diff before-time after-time)))

    ;;(message (format "list::%s" candidates))
    (nreverse candidates)))

(defvar lambda-ac-update 
  '((candidates . lambda-ac-update))
  "Source for completing variables")

;***********************************************************
;-----------------------------------------------------------
;現在の行からもっとも近い"let"を探す
;-----------------------------------------------------------
(defun lambda-search-nearest-let ()
  "Function used to search nearest 'let'"
  (interactive)
  (save-excursion
    (save-excursion
      (message (format "search let :%d" (lambda-search-backward "let"))))))

;-----------------------------------------------------------
;現在の行中にwordがあるか。あれば行中最後ののwordの位置を返す
;-----------------------------------------------------------
(defun lambda-current-line-contain (word);結果はインデント数
  (let ((result -1)
	(bol 0))
    (save-excursion
      ;(setq bol (lambda-point-bol))
      (beginning-of-line);
      (setq bol (point))
      (back-to-indentation);とりあえず
      (while (not (looking-at "$"))
	(if (not (looking-at word))
	    (forward-char 1)
	  (setq result (point))
	  (forward-char 1))))
    (message (format "lambda-current-line-contain(%s):final:result: %d, bol: %s" word result bol))
    (- result bol)))

;-----------------------------------------------------------
;ポイントのある行がwordから始まっていればwordまでの文字数を返す
;-----------------------------------------------------------
(defun lambda-current-line-begin (word);結果はインデント数
  (let ((result -1)
	(bol 0))
    (save-excursion
      ;(setq bol (lambda-point-bol))
      (beginning-of-line)
      (setq bol (point))
      (back-to-indentation)
      (if (looking-at word)
	  (setq result (point))))
    (message (format "lambda-current-line-begin(%s):result:%d, bol: %d" word result bol))
    (- result bol)))

;-----------------------------------------------------------
;直前のwordを探して行頭からwordまでの文字数を返す
;-----------------------------------------------------------
(defun lambda-search-backward (word)
  (let ((result -1))
    (save-excursion
      (while (and (= (forward-line -1) 0)
		  (if (looking-at "\\s *\\\\?$")
		      t
		    (if (< (lambda-current-line-contain word) 0)
			t
		      (setq result (lambda-current-line-contain word));インデント数
		      nil)))))
    (message (format "lambda-search-backward(%s): %d" word result))
    result))


(defun lambda-move-to-nearest-line ()
  (while (and (= (forward-line -1) 0)
	      (if (looking-at "\\s *\\\\?$")
		  t
		nil))))
  

;最寄りの空白でない行にwordが含まれるか
(defun lambda-search-backward-from-nearest-line (word)
  (let ((result -1)
	bol)
    (save-excursion
      (lambda-move-to-nearest-line)
      (beginning-of-line)
      (setq bol (point))
      (while (and (not (looking-at "$"))
		  (if (not (looking-at word))
		      (progn
			(forward-char 1)
			t)
		    (setq result (point))
		    (message (format "lambda-serach-backward-from-nearest-line(%s): macth!!" word))
		    (forward-char 1)
		    t))))
    (message (format "lambda-search-backward-from-nearest-line(%s): result: %d, bol: %d" word  result bol))
    (- result bol)))

(defun point-bol (where)
  (let ((bol -1))
    (save-excursion
      (goto-char where)
      (beginning-of-line)
      (setq bol (point)))
    (message (format "point-bol:where:%d, bol:%d " where bol))
    bol))

(defun to-indent (where)
  (message (format "to-indent: where:%d, indent:%d" where (- where (point-bol where))))
  (- where (point-bol where)))

(defun correspond  (keyword-r keyword-l &optional part)
  (message (format "correspond(L:\"%s\" ,R:\"%s\")" keyword-l keyword-r))
  (let ((count-l 0)
	(count-r 0)
	(indent -1)
	(last -1)
	(first -1))
    (save-excursion
      (forward-line -1)
      (end-of-line)
      (while (and (not (= (point) 0))
		  (progn
		    (cond ((looking-at keyword-l)
			   (setq count-l (+ count-l 1)))
			  ((looking-at keyword-r)
			   (setq count-r (+ count-r 1))))
			  
		    (message (format "correspond:L: %d, R: %d , point:%d" count-l count-r (point)))
		    (cond ((> count-l count-r);どっちにしろ左が多ければ終わり。
			   (setq indent (point))
			   nil)
			  ((and (not (= count-l 0))
				(= count-l count-r))
			   (if (= first -1)
			       (setq first (point))
			     (setq last (point)))
			   (if (not (= (point) 1))
			       (progn
				 (forward-char -1)
				 t)
			     nil))
			  
			  ((= (point) 1)
			   nil)
			  (t
			   (forward-char -1)
			   t))))))
    (message (format "correspond(\"%s\",\"%s\"): indent:%d, first:%d, last:%d" keyword-l keyword-r indent first last))

    (cond ((and (symbolp part)
		(string= "first" (symbol-name part)))
	  first)
	  ((and (symbolp part)
		(string= "last" (symbol-name part)))
	   last)
	  ((and (symbolp part)
		(string= "indent" (symbol-name part)))
	   indent)
	  ((not (= indent -1))
	   indent)
	  ((not (= last -1))
	   last)
	  ((not (= first -1))
	   first)
	  (t
	   -1))))
      

(defun lambda-paren ()
  (interactive)
  (message "lambda-paren")
  (let ((paren-r 0)
	(paren-l 0)
	(bol 0)
	(result -1)
	(result2 -1))
    
    (save-excursion
      (if  (= (forward-line -1) 0)
	  (progn
	    (end-of-line)
	    (while (and (not (= (point) 0))
			(progn
			  (message (format "lambda-paren: char-after: %c" (char-after)))
			  (cond ((looking-at "(")
				 (setq paren-l (+ paren-l 1)))
				 
				 ((looking-at ")")
				 (setq paren-r (+ paren-r 1))))
			  (message (format "lambda-paren: L: %d, R: %d" paren-l paren-r))
			  
			  (cond ((> paren-l paren-r)
				 (setq result (point))
				 nil)
				((and (not (= paren-r 0))
				     (= paren-r paren-l))
				(setq result2 (point)))
				((= (point) 1)
				 nil)
				(t
				 (forward-char -1)
				 t)) ))))))
    (if (= result -1)
	(setq result (- result2 1)))
    
    (save-excursion
      (goto-char result)
      (beginning-of-line)
      (setq bol (point)))
    (message (format "lambda-paren: result: %d, bol: %d" result bol))
    (- result bol)))
	
	
	  
;-----------------------------------------------------------
;インデント数を決める関数
;-----------------------------------------------------------

(defun lambda-indent-line-2 ()
  (let ( shift-amt
	 (indent 0))
    ;デフォのインデント数を取得
    (save-excursion
      (while (and (= (forward-line -1) 0)
		  (if (looking-at "\\s *\\\\?$")
		      t
		    (setq indent (current-indentation))
		    nil))))
    (message (format "lambda-indent-line: default indent: %d" indent))
    ;まず現在の行を見て出来ること
    
    
   
   (setq indent (cond 
		 ((and (>= (lambda-current-line-begin "val") 0);ok
		       (>= (correspond "in" "let" 'first) 0))
		  (+ (to-indent (correspond "in" "let" 'first)) 4))


		 ((>= (lambda-current-line-begin "in") 0);ok
		  (to-indent (correspond "in" "let")))
		 
		 ((>= (lambda-current-line-begin "end") 0);ok
		  (to-indent (correspond "end" "in")))



		 ;以下緩い条件
		 ( (and (>= (correspond "end" "let" 'indent) 0);対応しないletがあって
			(< (correspond "end" "let" 'first) 0));対応したlet endがひとつもないとき
		  (+ (to-indent (correspond "end" "let" 'indent)) 4))

		 ((>= (correspond "end" "let" 'first) 0);対応したlet endがあるとき
		  (+ (to-indent (correspond "end" "let" 'first)) 0));一つ目に対応したletにインデント

		 ((and (>= (correspond "in" "let" 'indent) 0);let inについて対応しないletがあって
			(< (correspond "in" "let" 'first) 0));対応したlet inがひとつもないとき
		   (+ (to-indent (correspond "in" "let" 'indent)) 4))
		 
		 ((>= (correspond "end" "in") 0);in endについて、対応しないinがあるとき
		  (+ (to-indent (correspond "end" "in")) 4))
		 



		 
		 ;((>= (lambda-search-backward-from-nearest-line "let") 0)
		 ; (+ (lambda-search-backward-from-nearest-line "let") 4))
		 
		 ;((>= (lambda-search-backward-from-nearest-line "in") 0)
		 ; (+ (lambda-search-backward-from-nearest-line "in") 4))
		 

		 ((and (>= (lambda-search-backward-from-nearest-line "->") 0)
		       (>= (lambda-search-backward-from-nearest-line "->") (lambda-search-backward-from-nearest-line "(")))
		  (+ (lambda-search-backward-from-nearest-line "->") 2))
		 
		 ;((and (>= (lambda-search-backward-from-nearest-line "(") 0)
		 ;      (>= (lambda-search-backward-from-nearest-line "(") (lambda-search-backward-from-nearest-line "->")))
		 ; (+ (lambda-search-backward-from-nearest-line "(") 1))
		 
		 ((and (or (>= (lambda-search-backward-from-nearest-line "(") 0)
			   (>= (lambda-search-backward-from-nearest-line ")") 0))
		       (>= (lambda-paren) 0))
		  (+ (lambda-paren) 0))
		 (t
		  indent)))
      
    (message (format "lambda-indent-line: final :indent: %d" indent))
    (lambda-shift-line-indentation indent)
    ))
    

;-----------------------------------------------------------
;
;-----------------------------------------------------------
;インデントする数を決める関数
(defun lambda-indent-line () 
  (let (shift-amt 
	(indent 0)
	(last-arrow-point -1))
    
    (save-excursion
      (while (and (= (forward-line -1) 0)
		  (if (looking-at "\\s *\\\\?$")
		      t)))

      (setq indent (current-indentation));空行でないならその行のインデント数を記憶
   
      (let ()
	(back-to-indentation)
	(while (not (looking-at "$"))
	  (if (not (looking-at "->"))
	      (forward-char 1)
	    (message (format "arrow!%d" (point)) )
	    (setq last-arrow-point (point))
	    (forward-char 1))))
      
      (if (not (= last-arrow-point -1))
	  (let ()
	    (beginning-of-line)
	    (setq indent (+ (- last-arrow-point (point)) 2)))
	
	(back-to-indentation)
	(let ((paren-r 0);
	      (paren-l 0)
	      (c ""))
	  (while (not (looking-at "$"))
	    (if (= (char-after) ?\( )
		(setq paren-l (+ paren-l 1)))
	    (if (= (char-after) ?\) )
		(setq paren-r (+ paren-r 1)))
	    
	    (setq c (format "%s %d" c (char-after)))
	    (message (format "L:%d, R:%d %s" paren-l paren-r c))
	    
	    (forward-char 1))
	  
	  ;(setq indent (+ indent (- paren-l paren-r))))))
	  (if (> paren-l paren-r)
	      (setq indent (+ indent (- paren-l paren-r)))
	    (let ((point-of-paren-l 0)
		  (boi -1))
	      (while (and (= (forward-line -1) 0)
			  (if (looking-at "\\s *\\\\?$")
			      t)))
	      (beginning-of-line)
	      (setq boi (point))
	      (while (not (looking-at "$"))
		(if (not (= (char-after) ?\( ))
		    (forward-char 1)
		  (setq point-of-paren-l (point))
		  (forward-char 1)))
	      
	      (setq indent (- point-of-paren-l boi)))))))
	    
    					;(setq shift-amt (- indent (current-indentation)));C-modeではこうやってる
      (setq shift-amt indent);これで今のところ動く
      (lambda-shift-line-indentation shift-amt)))
    
;実際にインデントする関数
(defun lambda-shift-line-indentation (shift-amt)
  (let (return-point)
    
    (setq return-point (- (point-max) (point)))
	
	
      (if (<= 0 shift-amt);インデント数が0なら何もしない
	  (let (point-bol 
		point-boi) 
	
	    (save-excursion
	      (beginning-of-line)
	      (setq point-bol (point)))

	    (save-excursion
	      (back-to-indentation)
	      (setq point-boi (point)))
	
					;(message (format "shift-amt: %d, bol:%d, boi:%d" shift-amt point-bol point-boi))

	    (delete-region point-bol point-boi)

	    (beginning-of-line)
	    (indent-to shift-amt)
	    (goto-char (- (point-max) return-point))
	    ))))



;hook
(add-hook 'lambda-mode-hook
	'(lambda ()
		(font-lock-mode 1)
		(set-face-foreground 'font-lock-comment-face "blue")
		(set-face-background 'font-lock-comment-face "white")
		(set-face-foreground 'font-lock-string-face "red")
		(set-face-background 'font-lock-string-face "white")


		

		;Face
		(make-face 'lambda-mode-font-lock-string-face)
		(set-face-foreground 'lambda-mode-font-lock-string-face "red")
		;(setq font-lock-keywords '(("lambda|a" 0 lambda-mode-font-lock-string-face)))
		;(font-lock-add-keywords 'lambda-mode
		;	'(("lambda|a" 0 lambda-mode-font-lock-string-face)))
		;(message "hook!!")
		(font-lock-fontify-buffer)
	)
)

(provide 'lambda-mode)
