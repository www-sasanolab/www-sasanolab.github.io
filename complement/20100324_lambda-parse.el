;;Time-stamp: <Fri Feb 05 13:00:08 東京 (標準時) 2010>

;;lambda-parse.el version 0.06
;;

(require 'lambda-parse-table)

(defvar lambda-parse-current-variables nil)
(defvar lambda-parse-current-token nil)
(defvar expected-type nil);;期待される型
(defvar lambda-parse-last-expr-type nil)

(defvar lambda-loop-depth 20);8-

(defvar toggle-message t)

;;マクロは実行中に上書きしても大丈夫
;;
(defun toggle-message ()
  (interactive)
  (if toggle-message
      (progn
	(setq toggle-message nil)
	(defmacro my-message (mes) nil)
	(message "message off"))
    (setq toggle-message t)
    (defmacro my-message (mes)(list 'message mes))
    (message "message on")))

(toggle-message)



(defun lambda-ac-current-word ();;lambda-mode.elから移動
  (let ((word ""))
    (save-excursion
      (forward-char -1)
      (while (and (not (or (string= (char-to-string (char-after)) " ");適当な区切り文字
			   (string= (char-to-string (char-after)) "\n")
			   (string= (char-to-string (char-after)) ")")
			   (string= (char-to-string (char-after))"(")
			   (string= (char-to-string (char-after))":")
			   (string= (char-to-string (char-after))"]")
			   (string= (char-to-string (char-after))"[")
			   (string= (char-to-string (char-after)) "\t")))
		  (progn 
		    ;(my-message (format "lambda-ac-current-word:\"%c\"" (char-after)))
		    (setq word (concat (char-to-string (char-after)) word ))
		    (if (= (point) 1)
			nil
		      (forward-char -1)
		      t)))))
    word))


;;#############################################
;;#簡易tokenizer
;;############################################
(defun next-token ()
  ;;自然数のみサポート
  (if (> (point) point_)
      (progn
	(setq lambda-ac-current-word nil)
	lambda-ac-current-word)
    
    (if (and (re-search-forward "\\([][]\\|->\\|=>\\|[a-zA-Z]+\\|[-+*/;:]\\|[1-9][0-9]*\\|[0-9]\\|\)\\|\(\\|=\\)" nil t )
	     (<= (point) point_))
	(progn
	  (setq lambda-parse-current-token (match-string 0))
	  (my-message (format "next-token:%s, p:%d p_:%d " (match-string 0) (point) point_))
	  lambda-parse-current-token)
      
      (setq lambda-parse-current-token nil)
      nil)))

(defun skip-token (token)
  (if (current-token-is token)
      (next-token)
    (my-message (format "%s is expected. (unexpected token: %s.)" token lambda-parse-current-token))
    ;;(throw 'lambda-parse-error "")
    nil))

(defun current-token-is (str)
  (string= lambda-parse-current-token str))

(defun lp-print-variables (vl)
  (let ((list (copy-sequence vl)))
    (while (car list)
      (my-message (format "variables: %s: %s" (car (car list)) (car (cdr (car list)))));;name: type どうしてこうなった
      ;;(my-message (format "variables: %s: %s" (car (car list)) (cdr (car list))));;name: type
      (setq list (cdr list)))))



;;リストの表示表現で比較
;(defun list= (x y)
;  (string= (prin1-to-string x) (prin1-to-string y)))
  





;;パースして変数リストを返す
(defun lambda-parse ()
  (interactive);これないとテストめんどい

  (my-message "################################################################")
  (let (point_ ;;ここに入ってるpointまでパース
	vars
	expr
	inference-result
	var-list
	(env (var-env nil) ))
    
    (add-variable env "+" (Type (type-arrow (type-atom "int")(type-arrow (type-atom "int")(type-atom "int")))))
    (add-variable env "-" (Type (type-arrow (type-atom "int")(type-arrow (type-atom "int")(type-atom "int")))))
    (add-variable env "/" (Type (type-arrow (type-atom "int")(type-arrow (type-atom "int")(type-atom "int")))))
    (add-variable env "*" (Type (type-arrow (type-atom "int")(type-arrow (type-atom "int")(type-atom "int")))))

    ;(setq var-list (get-variable-list env))
    (setq var-list (list))

    (reset-unique-tyvar)


    (let* ((parser-output (my-parser (my-lexer)))
	   (parser-status (cdr (assoc 'status parser-output)))
	   expr)
      ;;パーサの結果によって場合分け
      ;;パース完了　パース途中　構文エラー
    
      (cond 
       ((eq parser-status 'syntax-error)
	(message "Syntax Error..")
	nil)
     
       ((eq parser-status 'reach-eof)
	(my-message "Reach to EOF or Point")
	(let* ((stack (cdr (assoc 'stack (cdr (assoc 'result parser-output)))))
	       (reduce (cdr (assoc 'reduce (cdr (assoc 'result parser-output)))))
	       (c-args (parser-stack-to-c-args stack))
	       c-result
	       result-length
	       result-ast
	       (e-dummy nil)
	       (e-unify nil)
	       (e-type nil)
	       (e-novariable nil)
	       expr)
	  (my-message (format "Stack:%s" c-args))
	  (my-message (format "Stack:'%s'" (c-args-to-string c-args)))
	  (my-message (format "Stack:%s" (parser-stack-to-string stack)))
	  (my-message (format "Reduce:%s" (parser-result-to-string reduce)))

	  (if (not (string= "" (c-args-to-string c-args)))
	      (progn
		(setq c-result (algorithm-c c-args reduce 0 (list)))))
	  
	  (if c-result
	      (progn
		;;		(my-message (format "result length:%s" (cdr (assoc 'length c-result))))
		;;		(print-rHistories c-result)
	  
		;;何通りの抽象構文木があるか
		(setq result-length (cdr (assoc 'length c-result)))

		;;抽象構文木作成
		(let ((i 0))
		  (while (< i result-length)
		    (setq result-ast (cons (cons i (make-ast (cdr (assoc (- (- result-length i) 1 ) c-result))))
					   result-ast))
		    (print-expr (cdr (assoc i result-ast))  0)
		    (setq i (+ i 1))))
	  
		(my-message (format "%s個の抽象構文木を作成" result-length))

		;;推論
		(let ((i 0)
		      var-list-
		      my-env
		      csr
		      inference-result)

		  (while (< i result-length)
		    (my-message (format "推論前の抽象構文木 (%s/%s)" i result-length))
		    (print-expr (cdr (assoc i result-ast)) 0)
		    
		    (setq my-env (catch 'reach-cursor-expr
				   (catch 'error-unexpeted-type
				     (catch 'error-variable-not-found
				       (catch 'error-unify
					 (setq inference-result (catch 'error-nil-expr
								  (inference (copy-sequence env)
									     (cdr (assoc i result-ast)))))
					 (setq e-dummy t)
					 nil)
				       (setq e-unify t)
				       nil) ;catchされなければここにくる
				     (setq e-novariable t)
				     nil)
				   (setq e-type t)
				   nil))
		    
		    (my-message (format "e-unify:%s, e-novariable:%s" e-unify e-novariable))

		    (my-message (format "my-env:%s" my-env))
		    
		    (my-message "■推論後の構文木：")
		    (print-expr (cdr (assoc i result-ast)) 0)
		    
		    (setq csr (get-cursor (cdr (assoc i result-ast))))
		    ;(my-message (format "get-cursor:%s" (get-cursor (cdr (assoc i result-ast)))))
		    ;(my-message (format "cursor: %s" csr)) 

		    (if (or e-novariable e-unify e-dummy e-type)
			(setq my-env nil))

		    (if (not my-env) 
			(progn
			  ;;nilなので、
			  (if csr 
			      (setq my-env (list (cons 'env (cdr (assoc 'map csr)))))
			    (setq my-env (var-env nil)))
			  ;(my-message (format  "new my-env: is %s" my-env))
			  ))
		    
		    ;;最終的にこのmy-env
		    ;(my-message (format "■my-env:%s" my-env))
		    ;;
		    ;;ここまでがおかしい
		    ;;ここから絞り込み
		    (my-message (format "varable-list:%s" (get-variable-list (cdr (assoc 'env my-env)))))
		    
		    (if my-env
			(let ((var-list-- (get-variable-list (cdr (assoc 'env my-env)))))
			(let ((var-list- (get-variable-list (cdr (assoc 'env my-env))))
			      (ftype (cdr (assoc 'type-inferred csr))))
			  ;(ftype (cdr (assoc 'ftype my-env))))
			  (while (car var-list-)
			    (my-message (format "current: %s variable-list:%s" (car var-list-) var-list))
			    (my-message (format "ftype: %s" (type-to-string (cdr (assoc 'ftype my-env)))))
			    (if (not (member (car var-list-) var-list))
				(progn
				  (my-message (format "%s is not in var-list" (car var-list-)))
				  ;;ここでUnify
				  (if ftype 
				      (let* ((rtype (instanciate (get-variable-type (cdr (assoc 'env my-env)) (car var-list-)))))
					(my-message (format "cursor: %s, variable:(%s :%s)" (type-to-string ftype) (car var-list-) (type-to-string rtype)))
					(catch 'error-unify
					  ;;(my-message (format "unify(%s ,%s)" (type-to-string ftype) (type-to-string rtype)))
							 
					  (unify
					   (cons (list (cons 'left (cdr (assoc 'tree (copy-sequence ftype))))
						       ;(cons 'right (type-arrow (cdr (assoc 'tree (copy-sequence rtype)))
						       (cons 'right (cdr (assoc 'tree (copy-sequence rtype)))))
										;(type-var (uniqueTyVar)))))
										
						 nil)
					   (type-map nil))
					  (setq var-list (cons (car var-list-) var-list)))
					;;
					(my-message (format "ftype:%s" (type-to-string ftype))))
				    (my-message (format "ftype is nil"))
				    (setq var-list (cons (car var-list-) var-list)))))
					 
							   
					   
								     
				
			    (setq var-list- (cdr var-list-))))
			(while (car var-list--)
			  (my-message (format "%s : %s" (car var-list--) (type-to-string (get-variable-type (cdr (assoc 'env my-env)) (car var-list--)))))
			  (setq var-list-- (cdr var-list--)))))
  

		    (setq i (+ 1 i)))))

	    (setq var-list (list)))
	  
	  ;;-----------------ここまで

	  (cond
	   ((and e-dummy
		 (not var-list)) t)
	   ((and e-unify
		 (not var-list))
	    (message "Unify error"))
	   ((and e-novariable
		 (not var-list))
	    (message "Variable not found"))
	   ((and e-type
		 (not var-list))
	    (message "Type error"))
	   (t
	    ;(message (format "variable-list:%s" var-list))
	    ))
	  ;(message (format "variable-list:%s" var-list))
	  var-list))

       ((eq parser-status 'parse-finish)
	(my-message "Parse Finished.")
	(setq expr (make-ast (cdr (assoc 'result parser-output))))
	(my-message "抽象構文木")
	(my-message (format "%s" expr))
	(print-expr expr 0)

	(setq my-env (catch 'reach-cursor-expr
		       (catch 'error-variable-not-found
			 (setq inference-result 
			       (catch 'error-nil-expr
				 (inference (copy-sequence env) expr))))
		       nil))
	
	(if my-env
	    (let ((var-list- (get-variable-list (cdr (assoc 'env my-env)))))
	      (while (car var-list-)
		(if (not (member (car var-list-) var-list))
		    (let ( (variable (car var-list-))
			   (ftype (cdr (assoc 'ftype my-env))))
		      (if ftype
			  (let* ((rtype (get-variable-type 
					 (cdr (assoc 'env my-env))
					 variable))
				 (unique-name (uniqueTyVar))
				 (new-tyvar (type-var unique-name)))
			    ;;ここでftypeと環境から変数の型を取り出してUnify
			    ;;エラーしなければ候補に追加
			    (catch 'error-unify
			      (unify 
			       (cons
				(list (cons 'left (cdr (assoc 'tree ftype)))
				      (cons 'right (type-arrow
						    (cdr (assoc 'tree rtype))
						    new-tyvar)))
				nil)
			       (type-map nil)))
			    ;;正常終了すればここにくる
			    (setq var-list (cons (car var-list-) var-list)))
			(setq var-list (cons (car var-list-) var-list)))))
		(setq var-list- (cdr var-list-)))))
	
	(print-expr expr 0)

	;;(my-message (format "inference result %s" inference-result))
	
	(my-message (format "variable-list:%s" var-list))
	

	var-list)))))
  

;; (defun get-func-list (env var-list)
;;   (let ((vl (copy-sequence var-list))
;; 	type
;; 	(result (list)))
;;     (while (car vl)
;;       (setq type (car (get-variable-type env (car vl))))
;;       ;;(my-message (format "type:%s" type))
;;       (if (eq 'arrow (cdr (assoc 'class type)))
;; 	  (progn
;; 	    (my-message (format "%s is function" (car vl)))
;; 	    (add-to-list 'result (car vl))))
;;       (setq vl (cdr vl)))
;;     result))




;;-----------------------------------------
;;構文木ここから
;;-----------------------------------------
(defun expr-let (bindName bindExpr bodyExpr)
  (let ((ret (copy-alist '((class . let)
			   (bindName . nil)
			   (bindExpr . nil)
			   (bodyExpr . nil)
			   (type-inferred . nil)
			   (bind-inferred2 . nil);not clone
			   (bind-inferred . nil)))));clone
    (setcdr (assoc 'bindName ret) bindName)
    (setcdr (assoc 'bindExpr ret) bindExpr)
    (setcdr (assoc 'bodyExpr ret) bodyExpr)
    ret))
(defun expr-let (dec bodyExpr)
  (let ((ret (copy-alist '((class . let)
			   (dec . nil)
			   (bodyExpr . nil)
			   (type-inferred . nil)))))
    (setcdr (assoc 'bodyExpr ret) bodyExpr)
    (setcdr (assoc 'dec ret) dec)
    ret))
;;rule 10
(defun val-bind (bindName bindExpr)
  (let ((ret (copy-alist '((class . val-bind)
		      (bindName . nil)
		      (bindExpr . nil)
		      (bind-inferred . nil)
		      (bind-inferred2 . nil)))))
    (setcdr (assoc 'bindName ret) bindName)
    (setcdr (assoc 'bindExpr ret) bindExpr)
    ret))

;;rule11
;;
(defun decs ()
  (let ((ret (copy-alist '((class . decs)
		      (length . 0)))))
    ret))
  

			  
(defun expr-fn (bindName bodyExpr)
  (let ((ret (copy-alist '((class . fn)
			   (bindName . nil)
			   (bodyExpr . nil)
			   (type-inferred . nil)))))
    (setcdr (assoc 'bindName ret) bindName)
    (setcdr (assoc 'bodyExpr ret) bodyExpr)
    ret))

(defun expr-var (name)
  (if name
      (let* ((ret (copy-alist '((class . var)
				(name  . nil)
				(type-inferred . nil)))))
	;;(my-message (format "var %s -> %s" (assoc 'name ret)  name))
	(setcdr (assoc 'name ret) name)
	ret)

    (let* ((ret (copy-alist '((class . cursor)
			      (map . nil)
			      (type-inferred . nil)))))
      ret)))

(defun expr-apply (left right)
  (let ((ret (copy-alist '((class . apply)
			   (left . nil)
			   (right . nil)
			   (type-inferred . nil)
			   (left-before . nil)
			   (right-before . nil)
			   (left-inferred . nil)
			   (right-inferred . nil)))))
    (setcdr (assoc 'left ret) left)
    (setcdr (assoc 'right ret) right)
    ret))

;;-----------------------------------------
;;構文木ここまで
;;-----------------------------------------
(defun set-type-inferred (expr type)
  (let ()
    (setcdr (assoc 'type-inferred expr) type)))

;;-----------------------------------------
;;型ここから
;;-----------------------------------------
(defun Type (&optional type-tree)
  (let ()
    (list (cons 'tree type-tree) 
	  (cons 'tyvar-list (list))
	  (cons 'generic nil))))

(defun type-arrow (left right)
  (list 
   (cons 'class 'arrow)
   (cons 'left left) 
   (cons 'right right)))

(defun type-atom (name)
  (list 
   (cons 'class 'atom)
   (cons 'name name)))

(defun type-var (name)
  (list 
   (cons 'class 'var)
   (cons 'name name)))

(defun clone-type (type)
  (let ()
    (list (cons 'tree (clone-type-tree (cdr (assoc 'tree type))))
	  (cons 'tyvar-list (copy-sequence (cdr (assoc 'tyvar-list type))))
	  (cons 'generic (if (cdr (assoc 'generic type)) t nil)))))

(defun clone-type-tree (tree)
  (let ((klass (cdr (assoc 'class tree))))
    (cond
     ((eq klass 'var)
      (list
       (cons 'class 'var)
       (cons 'name (substring (cdr (assoc 'name tree)) 0))))
     ((eq klass 'atom)
      (list
       (cons 'class 'atom)
       (cons 'name (substring (cdr (assoc 'name tree)) 0))))
     ((eq klass 'arrow)
      (list
       (cons 'class 'arrow)
       (cons 'left (clone-type-tree (cdr (assoc 'left tree))))
       (cons 'right (clone-type-tree (cdr (assoc 'right tree)))))))))

;;tyvarはリストではなく型変数名
(defun add-local-variable (type tyvar)
  (let* ( (tyvar-list (assoc 'tyvar-list type))
	  (temp (apply 'append 
		       (list tyvar)
		       (copy-sequence (cdr tyvar-list)) nil)))
    ;;(my-message (format "add-local-variable(%s, %s)" (type-to-string type) tyvar))
    ;;(my-message (format "local-variables: %s" (cdr tyvar-list)))

    (setcdr tyvar-list temp)
    (my-message (format "added:%s" (cdr tyvar-list)))))

;;  (let ((tyvar-list (cdr (assoc 'tyvar-list type))))
;;    (add-to-list 'tyvar-list  tyvar)))

(defun instanciate-type-clone (type)
  (let ((free-variables (cdr (assoc 'tyvar-list type)))
	
	result)
    (my-message (format "■■before %s (%s)" (type-to-string type) (cdr (assoc 'tyvar-list type))))
    (setq result (Type (instanciate-type-clone-tree (cdr (assoc 'tree type)))))
    
    (if (cdr (assoc 'generic type))
	(progn
	  (setcdr (assoc 'tyvar-list result) (copy-sequence (cdr (assoc 'tyvar-list type))))
	  (setcdr (assoc 'generic result) t)))
    ;;置換を作って同じオブジェクトを指すようにする
    
    (let ((type-map (type-map nil))
	  tyvar
	  (tyvar-list (cdr (assoc 'tyvar-list type))))
      (while (car tyvar-list)
      	;(message (format "tyvar:: %s" (car tyvar-list)))
	(setq tyvar (type-var (car tyvar-list)))
	(type-map-put type-map (type-var (car tyvar-list)) tyvar)
	(setq tyvar-list (cdr tyvar-list)))
      (print-type-map type-map)
      (type-map-reduction type-map result))
    
    (my-message (format "■■cloned %s (%s)" (type-to-string result)  (cdr (assoc 'tyvar-list type) )))
    result))

(defun instanciate-type-clone-tree (tree)
  (let ((klass (cdr (assoc 'class tree))))
    (my-message (format "　■■tree:%s @:%s" tree  klass ))
    (cond
     ((eq klass 'var)

      (if (not (member (cdr (assoc 'name tree)) free-variables))
	  (progn
	    (my-message (format "      ▼参照コピー: %s" (type-tree-to-string tree)))
	    tree)
	(my-message (format "      ▼値コピー: %s" (type-tree-to-string tree)))
	(list
	 (cons 'class 'var)
	 (cons 'name (substring (cdr (assoc 'name tree)) 0)))))
     ((eq klass 'atom)
      (list
       (cons 'class 'atom)
       (cons 'name (substring (cdr (assoc 'name tree)) 0))))
     ((eq klass 'arrow)
      (list
       (cons 'class 'arrow)
       (cons 'left (instanciate-type-clone-tree (cdr (assoc 'left tree))))
       (cons 'right (instanciate-type-clone-tree (cdr (assoc 'right tree)))))))))
    

(defun instanciate-replace (tree before after)
  (let ((klass (cdr (assoc 'class tree))))
    (cond
     ((eq klass 'arrow)
      ;;(my-message "replace: arrow")
      (instanciate-replace (cdr (assoc 'left tree)) before after)
      (instanciate-replace (cdr (assoc 'right tree)) before after))

      ((eq klass 'atom ) t)
       ;;(my-message "replace: atom"))

       ((eq klass 'var)
	
	(if (equal before (cdr (assoc 'name tree)))
	    (progn
	      ;;(my-message (format "replace: %s => %s" before after))
	      (setcdr (assoc 'name tree) after)))))))



;;型のローカルなものを置換する
(defun instanciate (type)
  (let ((type (instanciate-type-clone type))
	;(type (clone-type type))
	(new-tyvar-list (list))
	new-tyvar
	(tyvar-list (copy-sequence (cdr (assoc 'tyvar-list type)))))
    (my-message (format "instanciate: %s" (type-to-string type)))
    (my-message (format "tyvar-list: %s" tyvar-list))
    (while (car tyvar-list)
      (setq new-tyvar (uniqueTyVar))
      (instanciate-replace (cdr (assoc 'tree type))
			   (car tyvar-list)
			   new-tyvar)
      (setq new-tyvar-list (cons new-tyvar new-tyvar-list))
      (setq tyvar-list (cdr tyvar-list)))
    ;;tyvar-listを空に
    (setcdr (assoc 'tyvar-list type) (copy-sequence new-tyvar-list))
    ;;単相型に
    (setcdr (assoc 'generic type) nil)
    (my-message (format "new-tyvar-list: %s" new-tyvar-list))
    (my-message (format "instanciated: %s" (type-to-string type)))
    type))

(defun is-gneric (type)
  (cdr (assoc 'generic type)))

;;-----------------------------------------
;;型ここまで
;;-----------------------------------------

;;-----------------------------------------
;;Unifyここから
;;-----------------------------------------

(defvar stop-count 0)

(defun unify-check-cyclic (tvar tree)
  (let ((klass (cdr (assoc 'class tree))))
    (cond
     ((eq klass 'atom)
      nil)
     ((eq klass 'arrow)
      (unify-check-cyclic tvar (cdr (assoc 'left tree)))
      (unify-check-cyclic tvar (cdr (assoc 'right tree))))
     ((eq klass 'var)
      (if (equal (cdr (assoc 'name tvar))
		 (cdr (assoc 'name tree)))
	  (progn
	    (message "unify: type cyclic error")
	    (throw 'error-unify 'unify)))))))
     

(defun unify (e map)
  (let (current l r)
    ;(my-message (format "%s" (car e)))
    (catch 'return
      (if (eq nil (car e))
	  (progn
	    (my-message "return.")
	    (throw 'return "")))
      
      ;;(my-message (format "unify-stack : before e: %s " e))
      
      (setq current (car e))
      (setq e (cdr e))
      
      ;;(my-message (format "unify-stack : after e: %s " e))

      (if nil
	  (progn
	    (setq stop-count (+ stop-count 1))
	    (if (< 6 stop-count)
		(throw 'return ""))))
      
      (setq l (cdr (assoc 'left current)));;type
      (setq r (cdr (assoc 'right current)));;type

      (debug-message (format "unify: %s , %s " (type-tree-to-string l) (type-tree-to-string r)))
      ;;(throw 'return "")
      ;;Atom Atom
      (cond 
       ((and (equal (cdr (assoc 'class l)) 'atom)
	     (equal (cdr (assoc 'class r)) 'atom))
	
	(if (not (equal (cdr (assoc 'class l)) (cdr (assoc 'class r))))
	    (throw 'error-unify 'unify))
	(unify e map))

      ;;Var Type
       ((eq (cdr (assoc 'class l)) 'var)
	;;X0 ,X0 -> X1等はエラー
	(unify-check-cyclic l r)
	(if (eq (cdr (assoc 'class r)) 'var)
	    (type-map-put-eq map l r)
	  (type-map-put map l r))
	(unify (unify-replace-stack e l r)  map))

      ;;arrow
       ((and (equal (cdr (assoc 'class l)) 'arrow)
	     (equal (cdr (assoc 'class r)) 'arrow))
	
	;;(my-message (format "unify: Arrow"))
	(setq e (cons  (list (cons 'left (cdr (assoc 'right l)))
			     (cons 'right (cdr (assoc 'right r))))
		       e))
	(setq e (cons  (list (cons 'left (cdr (assoc 'left l)))
			     (cons 'right (cdr (assoc 'left r))))
		       e))
	
	;;(my-message (format "unify: e: %s" e))
	(unify e map))
      ;;any Var
       ((equal (cdr (assoc 'class r)) 'var)
	
	;;(my-message "unify: R L")
	(setq e (cons (list (cons 'left  r)
			    (cons 'right l))
		      e))
	(unify e map))
       (t
	(my-message "unify:error")
	(throw 'error-unify 'unify)))
      (debug-message (format "unify: end")))))

;;スタックに対して置換
(defun unify-replace-stack- (tree before after)
  (let ((klass (cdr (assoc 'class tree))))
    (cond
     ;;Atomはそのまま
     ((eq klass 'atom)
      t)
     ;;Allowはバラす
     ((eq klass 'allow)
      (unify-replace-stack- (cdr (assoc 'left tree)) before after)
      (unify-replace-stack- (cdr (assoc 'right tree)) before after))
     ;;var
     ((eq klass 'var)
      (if (equal tree before)
	 (progn
	   (debug-message (format "replaced :%s => %s" (type-tree-to-string before)
			    (type-tree-to-string after)))
	   (setcar tree (car after))
	   (setcdr tree (cdr after))))))))
	


;; e type type
(defun unify-replace-stack (e before after)    
  (let ((current e))
    (debug-message "call-replace")
    (while (car current)
      (unify-replace-stack- (cdr (assoc 'left (car current))) before after)
      (unify-replace-stack- (cdr (assoc 'right (car current))) before after)
      (setq current (cdr current)))
    e))

;;map map
(defun unify-map-composition (A B)
  (let ((C (type-map nil)))
	
    ;;CにBの要素数分Aをコピー
    (let ((i 0)
	  (length (type-map-length B)))
      (while (< i length)
	t))))
	
	
    

;;-----------------------------------------
;;Unifyここまで
;;-----------------------------------------

(defvar lambda-debug-inference t)
(defun debug-message (str)
  (if lambda-debug-inference
      (my-message str)))


;;-----------------------------------------
;;推論関数ここから
;;-----------------------------------------
(defvar uniqueTyVar 0)
(defun  uniqueTyVar ()
  (let ((result (format "X%d" uniqueTyVar)))
    (setq uniqueTyVar (+ uniqueTyVar 1))
    result))

(defun reset-unique-tyvar ()
  (setq uniqueTyVar 0))

(defun inference-get-tyvar-list (type)
  (let ((result nil))
;    (if (cdr (assoc 'generic type))
;	(setq type (instanciate type)))
    (inference-get-tyvar-list- (cdr (assoc 'tree type)))
    result))
    
(defun inference-get-tyvar-list- (tree)
  (let ((klass (cdr (assoc 'class tree))))
    (cond
     ((eq klass 'var)
      (if (not (member (cdr (assoc 'name tree)) result))
	  (setq result (cons (cdr (assoc 'name tree)) result))))
     ((eq klass 'atom) t)
     ((eq klass 'arrow)
      (inference-get-tyvar-list- (cdr (assoc 'left tree)))
      (inference-get-tyvar-list- (cdr (assoc 'right tree)))))))

(defun inference-tyvar-is-in (tvar type)
  (let ((result t))
    (inference-tyvar-is-in tvar (cdr (assoc 'tree type)))
    result))

(defun inference-tyvar-is-in- (tvar tree)
  (let ((klass (cdr (assoc 'class tree))))
    (cond
     ((eq klass 'atom)
      nil)
     ((eq klass 'arrow)
      (inference-tyvar-is-in- tvar (cdr (assoc 'left tree)))
      (inference-tyvar-is-in- tvar (cdr (assoc 'right tree))))
     ((eq klass 'var)
      (if (equal (cdr (assoc 'name tvar))
		 (cdr (assoc 'name tree)))
	  (setq result nil))))))
	 

(defun inference (env expr)
  (let ((tymap (type-map nil)))
    (my-message "■■推論")
    (my-message "-------------------------------)")
    (my-message (format "%s" expr))
    (my-message "-------------------------------)")
    (inference- env expr)))

(defun inference- (env expr)
  (if (not expr) 
      (throw 'error-nil-expr (list
			      (cons 'env env)
			      (cons 'status 'nil-expr))))
  (let ((klass (cdr (assoc 'class expr)))
	(is-int (lambda (x) (equal x (int-to-string (string-to-int x))))))
    (cond
     ;;Var
     ((eq klass 'var)
      ;(debug-message "#var")
      (let (result
	    (name (cdr (assoc 'name expr))))
	(if (funcall is-int name)
	    (setq result (Type (type-atom "int")))
	  (setq result (copy-sequence (get-variable-type env (cdr (assoc 'name expr))))))
	(print-Type result)
	
	(if (is-gneric result)
	    (setq result (instanciate result)))
	
	;;保存
	(set-type-inferred expr result)
	(debug-message (format "var:type:%s" (type-to-string result)))
	result))

     ;;curosr
     ((eq klass 'cursor)
      ;(debug-message "#curosr")
      (let (result
	    (cursor-type (Type (type-var (uniqueTyVar)))))
	
	;(throw 'reach-cursor-expr (list (cons 'env env)))
	;(my-message (format "%s" expr))
	(setcdr (assoc 'map expr) (copy-sequence env))

	;;保存
	(set-type-inferred expr cursor-type)
	(debug-message (format "var:type(cursor):%s" (type-to-string cursor-type)))
	(print-var-env env)
	cursor-type))



     ;;Let
     ;;
     ((eq klass 'let)
      (debug-message "#let")
      (let* (result 
	    bindType 
	    
	    ;;宣言の配列
	    (dec (cdr (assoc 'dec expr)))
	    ;;
	    (bind-types (list))
	    (bind-length (cdr (assoc 'length dec)))
	    (body-env (var-env env))
	    (i (- bind-length 1)))
	    


	;(setq bindType (inference- env (cdr (assoc 'bindExpr expr))))

	(my-message "inference all declarations.")
	;;全てのdecを推論
	(while (<= 0 i)
	  (let* ((vb (cdr (assoc i dec)))
		 (bind-name (cdr (assoc 'bindName vb)))
		 (bind-expr (cdr (assoc 'bindExpr vb)))
		 (env body-env)
		 (bind-type (inference- env bind-expr)))

	    
	    (to-generic bind-type env)
	    
	    (setq body-env (var-env env))
	    (add-variable body-env bind-name bind-type)

	    (my-message (format "variable %s : %s"
				bind-name
				(type-to-string bind-type)))
	    ;;表示用に型をval-bindに記憶
	    (setcdr (assoc 'bind-inferred vb) (clone-type bind-type))
	    (setcdr (assoc 'bind-inferred2 vb) bind-type)
	    
	    

	    (setq i (- i 1))))
	    
	    
	;;ここから移動予定：変数登録


	(setq result (inference- body-env (cdr (assoc 'bodyExpr expr))))

	  

	;;保存
	(set-type-inferred expr result)
	result))
	

     ;;fn
     ((eq klass 'fn)
      ;(debug-message "#fn")
      (let (result 
	    bind-type  
	    body-type
	    temp
	    (unique-name (uniqueTyVar))
	    (local-var (list))
	    (env (var-env env)))

	;;導入される変数の型
	(setq bind-type (Type (type-var unique-name)))
	;;
	(add-to-list 'local-var (cdr (assoc 'name (cdr (assoc 'tree bind-type)))))

	;;環境に変数を追加して本体を評価
	(add-variable env (cdr (assoc 'bindName expr)) bind-type)
	(setq body-type (inference- env (cdr (assoc 'bodyExpr expr))))

	;;make result type
	(setq result (Type
		      (type-arrow 
		       (cdr (assoc 'tree (get-variable-type env (cdr (assoc 'bindName expr)))))
		       (cdr (assoc 'tree body-type)))))
  

	;;このfnで追加された型変数をローカルに
	(add-local-variable result unique-name)
	;;(my-message (format "add-local:%s  =>%s" unique-name (type-to-string result)))
	;;body-typeからもcopy
	(setq temp (copy-sequence (cdr (assoc 'tyvar-list body-type))))
	(while (car temp)
	  (add-local-variable result (car temp))
	  (setq temp (cdr temp)))
	
	;;保存
	(set-type-inferred expr result)

	result))
	
     ;;Apply
     ((eq klass 'apply)
      ;(debug-message "#apply")
      (let (left-type 
	    right-type 
	    result 
	    (tymap (type-map nil)))

	;;関数が存在するか
	(if (not (cdr (assoc 'left expr)))
	    (progn
	      ;;引数部分のexprがnilの場合
	      (throw 'error-nil-expr (list
				      (cons 'env env)
				      (cons 'status 'apply-func)))))

	


					     
	

	;;関数
	(setq left-type  (inference- env (cdr (assoc 'left expr ))))

	(if (eq 'atom (cdr (assoc 'class (cdr (assoc 'tree left-type)))))
	    (progn
	      (my-message (format "apply:left-type is atom"))
	      (throw 'error-unexpeted-type 'left-type-is-atom)))
	
	    
	(if (cdr (assoc 'generic left-type))
	    (setq left-type (instanciate left-type)))

	;;引数
	(setq right-type (inference- env (cdr (assoc 'right expr))))
	
	

	(if (cdr (assoc 'generic right-type))
	    (setq right-type (instanciate right-type)))

	
	;Unify前の型を保存（表示用）
	(setcdr (assoc 'right-before expr) (clone-type right-type))
	(setcdr (assoc 'left-before expr) (clone-type left-type))

	(setq stop-count 0)

	(setq result (let* ((unique-name (uniqueTyVar))
			    (new-tyvar (type-var unique-name)))
		       (debug-message (format "apply:left:before redction: %s" (type-tree-to-string new-tyvar)))
		       (debug-message (format "%s" unique-name))
		       ;;Unify
		       (unify (cons
			       (list (cons 'left  (cdr (assoc 'tree left-type)))
				     (cons 'right (type-arrow 
						   (cdr (assoc 'tree right-type))
						   new-tyvar)))
			       nil)
				     
			      tymap)
		       (debug-message (format "newβ %s" new-tyvar ))
		       (print-type-map tymap)
		       (type-map-reduction tymap right-type)
		       (type-map-reduction tymap left-type)
		       (type-map-reduction tymap (Type new-tyvar))))
	
	;;(my-message (format "apply:left:after redction: %s" (type-to-string left-type)))
	
	;;(setq result (Type (cdr (assoc 'right 
	;;			       (cdr (assoc 'tree left-type))))))


	;;保存
	(set-type-inferred expr result)
	(setcdr (assoc 'left-inferred expr) (clone-type left-type))
	(setcdr (assoc 'right-inferred expr) (clone-type right-type))

	;;unify
	result))
      
     ;;error
     (t
      ;;(throw 'error-undefined-expr "")
      (let 
	  ((undef-expr-type (Type (type-var (uniqueTyVar)))))
	(set-type-inferred expr undef-expr-type)
	undef-expr-type)

      ))))

;;-----------------------------------------
;;推論関数ここまで
;;-----------------------------------------
(defun to-generic (type env)
  (let (type-variables-in-env 
	type-variables-in-bind-type 
	generic-type-variables)

    ;;環境envに含まれる型変数を列挙①
    (setq type-variables-in-env (enumerate-all-type-variable env))  
 
    ;;対象となる型に含まれる型変数を列挙②
    (setq type-variables-in-bind-type 
	  (let ((result (list)))
	    (enumerate-all-type-variable-tree (cdr (assoc 'tree type)))
	    result))

    (my-message (format "■多相型化 (bind-type:%s)" (type-to-string type)))
    (my-message (format "  ■環境に含まれる型変数: %s" type-variables-in-env))
    (my-message (format "  ■bind-typeに含まれる型変数: %s" type-variables-in-bind-type))
    
    ;;②の中で①に含まれない型変数（フリーな型変数）を列挙。    (while (car type-variables-in-bind-type)
    (my-message (format "    ▼比較: in bind-type: %s , in Env: %s => %s (eq: %s )" 
			(car type-variables-in-bind-type) 
			type-variables-in-env
			(if (member (car type-variables-in-bind-type) type-variables-in-env)
			    "単相" "多相")
			(eq (car type-variables-in-bind-type) 
			    (car (member (car type-variables-in-bind-type) type-variables-in-env)))))
    (if (not (member (car type-variables-in-bind-type) type-variables-in-env))
	(setq generic-type-variables (cons (car type-variables-in-bind-type)
					   generic-type-variables)))
    (setq type-variables-in-bind-type (cdr type-variables-in-bind-type))
    
    (my-message (format "  ■bind-typeのgenericな型変数: %s" generic-type-variables))
    


    ;;フリーな型変数を型に記憶しておく
    (setcdr (assoc 'tyvar-list type) generic-type-variables)

    ;;多相型に
    (if generic-type-variables
	(setcdr (assoc 'generic type) t))
    (my-message (format "bind-type(%S) generic is %s (tyvar:%s)" 
			(type-to-string type)
			(cdr (assoc 'generic type))
			(inference-get-tyvar-list type)))))
	


;;----------------------------------------
;;環境
;;----------------------------------------
(defun var-env (&optional parent)
  (list
   (cons 'parent parent)
   (cons 'variables (list))))

(defun add-variable (env name type)
  ;;(my-message "add-variable")
  (let ( (vars (cdr (assoc 'variables env))) )
    
    (setcdr (assoc 'variables env) (cons 
				    (cons name type) 
				    (cdr (assoc 'variables env))))
    ;;(my-message (for mat "added:%s" env))
    env))

(defun get-variable-type (env name)
  (let (var-type)
    
    ;;(my-message (format "env: %s" env))
    (if (eq env nil) 
	(throw 'error-variable-not-found nil)
      (setq var-type (assoc name (cdr (assoc 'variables env))))
      (if (eq var-type nil)
	  (get-variable-type (cdr (assoc 'parent env)) name)
	;;return Type of name in env
	(my-message (format "get-variable-type:%s: %s" 
			    name
			    (type-to-string (cdr var-type)))) 
	(cdr var-type)))))


(defun get-variable-list_ (env)
  (let ((current-list (cdr (assoc 'variables env))))
    
    (if env
	(progn
	  (while (car current-list)
	    (if (not (member (car (car current-list)) variable-list))
		  (add-to-list 'variable-list (car (car current-list))))
	    (setq current-list (cdr current-list)))
	  (if (cdr (assoc 'parent env))
	      (get-variable-list_ (cdr (assoc 'parent env))))))))
		  
		     
	      
(defun get-variable-list (env)
  (let ((variable-list (list))
	(env (copy-sequence env)))
    (get-variable-list_ env)
    variable-list))

(defun get-cursor (tree)
  (let ((result  (catch 'cursor 
		  (get-cursor- tree))))
    ;(my-message (format "■gc:%s" result))
    result))

(defun get-cursor- (tree)
  (let ((klass (cdr (assoc 'class tree))))
    ;;(my-message (format "get-curosr: %s" tree))
    (cond
     ((eq klass 'var)
      nil)

     ((eq klass 'fn)
      (get-cursor- (cdr (assoc 'bodyExpr tree))))

     ((eq klass 'let)
      (my-message "get-curosr:::")
      (let* ((dec (cdr (assoc 'dec tree)))
	    
	    (bind-types (list))
	    (bind-length (cdr (assoc 'length dec)))
	    (i (- bind-length 1)))

	(while (<= 0 i)
	  (let* ((vb (cdr (assoc i dec)))
		 (bind-expr (cdr (assoc 'bindExpr vb))))
	    (get-cursor- bind-expr)
	    (setq i (- i 1)))))
	    
      (get-cursor- (cdr (assoc 'bodyExpr tree))))
      
     ((eq klass 'apply)
      (get-cursor- (cdr (assoc 'left tree)))
      (get-cursor- (cdr (assoc 'right tree))))

     ((eq klass 'cursor)
      ;(my-message (format  "■cursor %s " tree))
      (throw 'cursor tree)
      tree)

     (t nil))))
     

;;環境に含まれている全ての型変数を列挙
;;特定の位置でアクティブな全ての変数の型変数ではない。
(defun enumerate-all-type-variable (env)
  (let ((result (list)))
    (my-message "  ■Enumerate All Type Variables")
    (enumerate-all-type-variable- env)
    ;;ここで重複を削除してもよい。
    (my-message (format "  ▼EATV: %s" result))
    result))
    
(defun enumerate-all-type-variable- (env)
  (let ((var-list (cdr (assoc 'variables env)))
	type)
    (while (car var-list)
      ;(message (format "  %s" (car var-list)))
      (setq type (cdr (car var-list)))
      (print-Type type)
      (enumerate-all-type-variable-tree (cdr (assoc 'tree type)))
      ;;
      (setq var-list (cdr var-list)))
    (if (cdr (assoc 'parent env))
	(enumerate-all-type-variable- (cdr (assoc 'parent env))))))
    
(defun enumerate-all-type-variable-tree (tree)
  (let ((klass (cdr (assoc 'class tree))))
    (cond
     ((eq klass 'var)
      ;;resultへ追加
      (if (not (member (cdr (assoc 'name tree)) result))
	  (setq result (cons (cdr (assoc 'name tree))
			     result))))
     ((eq klass 'atom)
      nil)
     ((eq klass 'arrow)
      (enumerate-all-type-variable-tree (cdr (assoc 'left tree)))
      (enumerate-all-type-variable-tree (cdr (assoc 'right tree)))))))
;;----------------------------------------
;;置換ここから
;;----------------------------------------
(defun type-map (parent)
  (list 
   (cons 'parent parent)
   (cons 'map (list))
   (cons 'map-length 0)))

(defun type-map-length (map)
  (cdr (assoc 'map-length map)))

(defun clone-type-map- (map length)
  (let (current
	(i 0)
	(result (list)))
    (while (< i length)
      (setq current (cdr (assoc i map)))
      (setq result (cons
		    (cons
		     i
		     (list
		      (cons 'key  (clone-type-tree (cdr (assoc 'key current))))
		      (cons 'type (clone-type-tree (cdr (assoc 'type current))))))
		    result))
      (setq i (+ 1 i)))
    result))
  
(defun clone-type-map (map)
  (list 
   (cons 'parent (cdr (assoc 'parent map)))
   (cons 'map (clone-type-map- (cdr (assoc map)) (type-map-length map)))
   (cons 'map-length (type-map-length map))))

(defun type-map-find (tymap label)
  (let ((i 0)
	(length (cdr (assoc 'map-length tymap)))
	(map (cdr (assoc 'map tymap)))
	(result nil))
    ;(draw-line (format "■find: search for %s" label))
    ;(my-message (format "find: len: %s" length))
    ;;(my-message (format "%s" map))
    (if (catch 'while-loop
	  (while (and
		  map
		  (< i length)
		  (assoc i map))
	    ;(my-message (format "loop: %s/%s, current label: %s" i (+ length -1)
	;		     (cdr (assoc 'name 
		;			 (cdr (assoc 'key
		;				     (cdr (assoc i map))))))))
	    ;;(my-message (format "%s" (cdr (assoc 'key (cdr (assoc i map))))))
	    (if (equal label (cdr (assoc 'name
					 (cdr (assoc 'key 
						     (cdr (assoc i map)))))))
		(progn
		  ;(my-message (format "found:%s" (type-tree-to-string (cdr (assoc 'type 
		;					  (cdr (assoc i map)))))))
		  (setq result (cdr (assoc 'type (cdr (assoc i map)))))
		  (throw 'while-loop result))
	      (setq i (+ i 1))
	      nil)))
	result
      
      (if (not result)
	  (if  (eq (cdr (assoc 'parent tymap)) nil)
	      nil
	    (type-map-find (cdr (assoc 'parent tymap)) label ))
	result))))

;; type type
(defun type-map-put (tymap key type)
  (let ()
   
    (setcdr (assoc 'map tymap)
	    (cons 
	     (cons  
	      (cdr (assoc 'map-length tymap));;index番号
	      (list ;;追加するkey,type
		      (cons 'key (clone-type-tree key))
		      (cons 'type type)))
	     (cdr (assoc 'map tymap))));;元からあるリスト

    (setcdr (assoc 'map-length tymap) (+ 1 (cdr (assoc 'map-length tymap))))
    ))

(defun type-map-put-eq (tymap left right)
  (type-map-put tymap left right)
  (type-map-put tymap right left))

;;reductionから呼ばれる
(defun type-map-replace (tree map )
  (let ((klass (cdr (assoc 'class tree))))
    ;;(draw-line (format "■type-map-replace: %s" (type-tree-to-string tree)))
    (cond
     ;;atomは置換しない
     ((eq klass 'atom)
      t)

     ;;arrowはバラす
     ((eq klass 'arrow)
      ;(message (format "■type: %s" (type-tree-to-string tree)))
      (type-map-replace (cdr (assoc 'left tree)) map)
      (type-map-replace (cdr (assoc 'right tree)) map))

     ;;型変数は置換
     ((eq klass 'var)
      (let ((r (type-map-find map (cdr (assoc 'name tree)))))
	;(message "-------------------")
	;(message (format "%s"  map))
	;(message "-------------------")
	(my-message (format "　置換: %s => %s" (type-tree-to-string tree) (type-tree-to-string r)))
	(if (not r)
	    (my-message (format "type-map-replace: %s is not is type map" (cdr (assoc 'name tree))))
	  (setq nouse (cons (cdr (assoc 'name tree)) nouse))
	  (setcar tree (car  r))
	  (setcdr tree (cdr  r))))))))
     



;;tymapを使ってtypeを具体化
(defun type-map-reduction (tymap type)
  (let (nouse (list))
    (my-message (format "  before reduction: %s" (type-to-string type)))
    (type-map-replace (cdr (assoc 'tree type)) tymap)
    ;;ここでローカル変数のコピーとか
    (my-message (format "  adter reduction: %s" (type-to-string type)))
    type))

;;----------------------------------------
;;置換ここまで
;;----------------------------------------
;;----------------------------------------
;;補助関数
;;----------------------------------------
(defun print-var-env (env &optional sp)
  (let ((temp (cdr (assoc 'variables env)))
	(sp (if sp sp "\t")))
    (while (car temp)
      (my-message (format "%s %s: %s" sp
			  (car (car temp))
			  (type-to-string (cdr (car temp)))))
      (setq temp (cdr temp)))
    (if (cdr (assoc 'parent env))
	(print-var-env (cdr (assoc 'parent env)) sp))))
	
(defun print-expr (expr depth)
  (let ((klass (cdr (assoc 'class expr)))
	(sp (make-string depth 32))
	(type-string (type-to-string (cdr (assoc 'type-inferred expr)))))
    ;;(my-message (format "klass : %s" klass))
    (cond
     ;;let
     ((eq klass 'let)
      (my-message (format "%s ■let {%s}" sp type-string))
      (print-dec (cdr (assoc 'dec expr)) depth)
;      (my-message (format "%s   bindExpr:" sp))
;      (print-expr (cdr (assoc 'bindExpr expr)) (+ depth 4))
      (my-message (format "%s   bodyExpr:" sp))
      (print-expr (cdr (assoc 'bodyExpr expr)) (+ depth 4))
      )

     ;;fn
     ((eq klass 'fn)
      (my-message (format "%s ■fn {%s}" sp type-string))
      (my-message (format "%s   bindName: %s" sp (cdr (assoc 'bindName expr))))
      (print-expr (cdr (assoc 'bodyExpr expr)) (+ depth 4)))
     ;;var
     ((eq klass 'var)
      (my-message (format "%s ■var %s {%s}" sp (cdr (assoc 'name expr)) type-string)))
     ;;cursor
     ((eq klass 'cursor)
      (my-message (format "%s ▼cursor {%s}" sp type-string))
      (print-var-env (cdr (assoc 'map expr)) sp))
     ;;apply
     ((eq klass 'apply)
      (my-message (format "%s ■apply {%s}" sp type-string))
      (my-message (format "%s   func:{%s}=>{%s}" sp 
			  (type-to-string (cdr (assoc 'left-before expr)))
			  (type-to-string (cdr (assoc 'left-inferred expr)))))
      (print-expr (cdr (assoc 'left expr)) (+ depth 4))
      (my-message (format "%s   arg :{%s}=>{%s}" sp 
			  (type-to-string (cdr (assoc 'right-before expr)))
			  (type-to-string (cdr (assoc 'right-inferred expr)))))
      (print-expr (cdr (assoc 'right expr)) (+ depth 4)))
     ;;error
     (t
      (my-message (format "%s undefined-expr " sp))))
    t))

(defun print-dec (dec depth)
  (let ((i 0)
	(sp (make-string depth 32))
	vb)
    ;;(my-message (format "length: %s "(cdr (assoc 'length dec))))
    (while (< i (cdr (assoc 'length dec)))
      (setq vb (cdr (assoc i dec)))
      (my-message (format "%s ▲ %s {%s}=>{%s} = " 
			  sp 
			  (cdr (assoc 'bindName vb))
			  (type-to-string (cdr (assoc 'bind-inferred vb)))
			  (type-to-string (cdr (assoc 'bind-inferred2 vb)))))
      (print-expr (cdr (assoc 'bindExpr vb)) (+ depth 4))
      (setq i (+ 1 i)))))

  
   

(defun print-Type (type)
  (if (cdr (assoc 'generic type))
      (my-message (format "%s.%s"
		       (cdr (assoc 'tyvar-list type))
		       (type-tree-to-string (cdr (assoc 'tree type)))))
  (my-message (format "%s" (type-tree-to-string (cdr (assoc 'tree type)))))))

(defun type-to-string (type)
  (if type
      (if (cdr (assoc 'generic type))
	  (format "%s.%s"
			   (cdr (assoc 'tyvar-list type))
			   (type-tree-to-string (cdr (assoc 'tree type))))
	(format "%s" (type-tree-to-string (cdr (assoc 'tree type)))))
    nil))
(defun type-tree-to-string (tytree)
  (let ((klass (cdr (assoc 'class tytree)))
	(fmt "%s -> %s"))
    (cond
     ((eq klass 'atom)
      (cdr (assoc 'name tytree)))
    ((eq klass 'var)
      (cdr (assoc 'name tytree)))
    ((eq klass 'arrow)
     (if (eq (cdr (assoc 'class (cdr (assoc 'left tytree)))) 'arrow)
	 (setq fmt "(%s) -> %s"))
     (format fmt
	     (type-tree-to-string (cdr (assoc 'left tytree)))
	     (type-tree-to-string (cdr (assoc 'right tytree))))))))


(defun print-type-map (map)
  (draw-line "■print-type-map")
  (let ((map-length (cdr (assoc 'map-length map)))
       
	(map-array (cdr (assoc 'map map)))
	(i 0)
	current)

    (while (< i map-length)
      (setq current (cdr (assoc i map-array)))
      (my-message (format "%s => %s" 
		       (type-tree-to-string (cdr (assoc 'key current)))
		       (type-tree-to-string (cdr (assoc 'type current)))))
      (setq i (+ 1 i)))
    (if (not (equal nil (cdr (assoc 'parent map))))
	(print-type-map (cdr (assoc 'parent map)))))
  (draw-line))
      
(defun draw-line (&optional str)
  ;;(my-message "------------------------------------------------")
  (if str 
      (my-message (format "%s" str))))



;;#################################################################################
;;Parser
;;#################################################################################






  
(defun action-to-string (action)
  (let ((i 0)
	act
	(result "") )
    (while (< i (length action))
      (setq act (aref action i))
      (setq result (format "%s %s%s" result (cdr (assoc 'action act)) (cdr (assoc 'num act))))
      (setq i (+ 1 i)))
    result))
		


;;書きなおすの面倒なので計算


(defvar token-to-column-table 
  (list
   (cons 'ID 0)
   (cons 'CONST 1)
   (cons 'FN 2)
   (cons 'ALW 3)
   (cons 'LP 4)
   (cons 'RP 5)
   (cons 'LET 6)
   (cons 'VAL 7)
   (cons 'EQ 8)
   (cons 'IN 9)
   (cons 'END 10)
   (cons 'EOF 11)))

;;Reduceの時に各構文規則でスタックから何個Popするか
(defvar reduce-pop-count
  (list
   (cons 0 1)
   (cons 1 1)
   (cons 2 1)
   (cons 3 4)
   (cons 4 1)
   (cons 5 2)
   (cons 6 1)
   (cons 7 1)
   (cons 8 3)
   (cons 9 5)
   (cons 10 4)
   (cons 11 2)))

(setq non-terminal-num-to-col-num-table
  (list
   (cons 1 12)
   (cons 2 13)
   (cons 3 13)
   (cons 4 14)
   (cons 5 14)
   (cons 6 15)
   (cons 7 15)
   (cons 8 15)
   (cons 9 15)
   (cons 10 16)
   (cons 11 16)))


  

(defun my-lexer ()
  (list
   (cons 'eof (- (point) (length (lambda-ac-current-word))))
   (cons 'current-point 1)
   (cons 'current-token nil)
   (cons 'previous-point 1)))

(defun token (sym &optional value)
  (list
   (cons 'symbol sym)
   (cons 'value value)))


(defun my-next-token (lexer)
  (interactive)
  (let ( token r)
    (save-excursion
      (setcdr (assoc 'previous-point lexer) (cdr (assoc 'current-point lexer)))
      (goto-char (cdr (assoc 'current-point lexer)))

      (setq r (re-search-forward "\\()\\|(\\|=>\\|=\\|[+-/*]\\|[a-zA-Z]+\\|[1-9][0-9]*\\|0\\)" nil t))
      (if (or (not r)
	      (< (cdr (assoc 'eof lexer)) (point)))
	  (progn
	    ;;このあとは延々nil
	    (setq token (token 'EOF))
	    (setcdr (assoc 'current-token lexer) token)
	    (setcdr (assoc 'current-point lexer) (point-max)))

	(setq token (match-string-no-properties 0))
	(setq token (cond 
		     ((equal token "fn")
		      (token 'FN "fn"))
		     ((equal token "=>")
		      (token 'ALW "=>"))
		     ((equal token "(")
		      (token 'LP "("))
		     ((equal token ")")
		      (token 'RP ")"))
		     ((equal token "let")
		      (token 'LET "let"))
		     ((equal token "val")
		      (token 'VAL "val"))
		     ((equal token "=")
		      (token 'EQ "="))
		     ((equal token "in")
		      (token 'IN "in"))
		     ((equal token "end")
		      (token 'END "end"))
		     ((string-match "[a-zA-Z]+" token)
		      (token 'ID token))
		     ((string-match "[+/-*]" token)
		      (token 'ID token))
		     ((string-match "[1-9][0-9]*" token)
		      (token 'CONST token))
		     ((equal token nil)
		      (token 'EOF))))
		   
		   

  	(setcdr (assoc 'current-token lexer) token)
	(setcdr (assoc 'current-point lexer) (point)))
      (copy-sequence token))))

;;dynamic
(defun parser-shift (stat)
  
  (let ((status- status))
    (my-message (format "Shift %s" stat))
    ;;(setq stack (cons stat stack))
    (parser-stack-push stat (cdr (assoc 'value token)))
    (setq status stat)
    (setq token (my-next-token lexer))
    
    (my-message (format "■stat:%s status- :%s" stat status-))
   
    ;;単純にCorsorをIDとして突っ込むと構文エラーになるので
    ;;状態を考えてやる必要がある。
    (my-message (format "1:%s, 2%s, 2.5:%s  3%s, 4%s, 5%s 6:%s"
		     (<= 0 stat)
		     (<= stat 5)
		     (or (and (<= 0 stat)
			      (<= stat  5))
			 (and (<= 15 stat)
			      (<= stat 21)))
		     (not (= stat 6))
		     (not (= stat 12))
		     (eq 'EOF (cdr (assoc 'symbol token)))
		     (not cursor)))
	     (not cursor)
    (if (and (or (and (<= 0 stat)
		      (<= stat  5))
		 (and (<= 15 stat)
		      (<= stat 21)))
	     nil
	     (not (= stat 6))
	     (not (= stat 12))
	     (eq 'EOF (cdr (assoc 'symbol token)))
	     (not cursor))
	(progn
	  (my-message (format "Cursor:stat:%s, status-:%s" stat status-))
	  (setq token (token 'ID));;カーソル
	  (setq cursor t)))
    (if (and
	 (eq 'EOF (cdr (assoc 'symbol token)))
	 (not cursor))
	(progn
	  (my-message (format "Cursor:stat:%s, status-:%s" stat status-))
	  (setq token (token 'ID));;カーソル
	  (setq cursor t)))
    (my-message (format "  stack: %s (%s)" 
		     (parser-stack-to-string stack)
		     (cdr (assoc 'symbol token))))))

;;dynamic
(defun parser-reduce (num)
  (my-message (format "Reduce %s" num))
  (let ((pop-count (cdr (assoc num  reduce-pop-count)))
	(i 0)
	(reduce-data (list (cons 'rule num)))
	new-stat
	new-col)
    (while (< i pop-count)
      ;;Pop
      ;;(setq stack (cdr stack))
      (setq reduce-data (cons (cons i (parser-stack-pop))
			      reduce-data))
			       
      ;;i++
      (setq i (+ i 1)))
    (setq reduce-data (cons (cons 'length i)
			    reduce-data))

    (parser-push-result reduce-data)
    ;;statusを更新
    ;;(setq status (car stack))
    (setq status (cdr (assoc 'status (car stack))))

    (setq new-col (aref parser-table status))
    
    ;;非終端記号を入力して遷移する先の状態
    (setq new-action (aref new-col  (cdr (assoc num non-terminal-num-to-col-num-table))))
    
    (let ((j 0)
	  act
	  a)
      (while (< j (length new-action))
	(setq act (aref new-action j))
	(setq a (cdr (assoc 'action act)))
	(cond
	 ((eq a 'g)
	  ;;Goto
	  (parser-goto (cdr (assoc 'num act))
		       num))
	 ((eq a 'r)
	  ;;Reduce
	  (parser-reduce (cdr (assoc 'num act)))))
	(setq j (+ 1 j)))))
  (my-message (format "  stack: %s" (parser-stack-to-string stack))))



    ;;dynamic
(defun parser-goto (stat &optional nonterminal)
  (my-message (format "Goto %s" stat))
  ;;(setq stack (cons stat stack))
  (parser-stack-push stat nonterminal)
  (setq status stat)
  (my-message (format "  stack: %s" (parser-stack-to-string stack))))

(defun parser-stack-to-string (stack)
  (let ((result "")
	(temp stack))
    (while (car temp)
      (setq result (format "%s %s" 
			   (cdr (assoc 'status (car temp))) 
			   result))
      (setq temp (cdr temp)))
    result))

(defun parser-stack-to-c-args (stack)
  (let* ((result (list))
	(temp stack)
	token)
    (while (car temp)
      (setq token (cdr (assoc 'value (car temp))))
      (my-message (format "%s ,  %s" token (car temp)))
      (setq token (if (assoc token rule-number-to-name)
		(cdr (assoc token rule-number-to-name))
	      token))

      (setq result (cons token result))
      (setq temp (cdr temp)))
    (nreverse result)))

(defvar rule-number-to-name 
  (list
   (cons 1 "start")
   (cons 2 "exp")
   (cons 3 "exp")
   (cons 4 "appexp")
   (cons 5 "appexp")
   (cons 6 "atexp")
   (cons 7 "atexp")
   (cons 8 "atexp")
   (cons 9 "atexp")
   (cons 10 "dec")
   (cons 11 "dec")))



(defun c-args-to-string (c-args)
  (let ((result "")
	(temp c-args))
    (while (car temp)

      (setq result (format "%s %s" (car temp) result))
      (setq temp (cdr temp)))
    result))

(defun parser-stack-push (num &optional token-value)
  (setq stack (cons (list 
		     (cons 'status num)
		     (cons 'value token-value))
		    stack)))

(defun parser-stack-pop ()
  (let ((result (car stack)))
    (setq stack (cdr stack))
    ;;(my-message (format "pop: %s" result)) 
    result))

(defun parser-push-result (a)
  (setq result (cons a
		     result)))

(defun parser-result-to-string (output)
  (let ((result "")
	(temp output))
    (while (car temp)
      (setq result (format "%s %s" result  (cdr (assoc 'rule (car temp)))))
      (setq temp (cdr temp)))
    result))

(setq flg t)

(defun my-parser (lexer)
  (let* ((status 0)
	 stack
	 token
	 column 
	 (result (list))
	 vector-row
	 action
	 (cursor-flg nil)
	 (cursor nil)
	 (syntax-error nil)
	 (reach-eof nil)
	 (parse-finish nil)
	 (debug-i 0)
	 (loopflg t)
	 (token (my-next-token lexer)))
    (my-message "========== Parse ==========")
    ;; (if flg
;; 	(progn
;; 	  (calc-parser-table)
;; 	  (setq flg nil)))

    (parser-stack-push status)
    (while loopflg


      (my-message (format "*** status %s ***" status))
      (my-message (format "  stack: %s" (parser-stack-to-string stack)))
      ;;トークンを読む
      ;;(setq token (next-token lexer))
      (my-message (format "  read token: %s (%s)" (cdr (assoc 'symbol token)) (cdr (assoc 'value token))))
      
      ;;テーブルの何列目になるか
      (setq column (cdr (assoc (cdr (assoc 'symbol token))
			       token-to-column-table)))
      (my-message (format "  %s column: %s" (cdr (assoc 'symbol token)) column))
      
      (setq vector-row (aref parser-table status))
      (setq action (aref vector-row column))

      (my-message (format "  %s" action))
      
      (let ((i 0)
	    act
	    a)
	
	(if (= 0 (length action))
	    (progn
	      (if (eq (cdr (assoc 'symbol token)) 'EOF)
		  (progn
		    (my-message (format "--- EOF ---"))
		    (setq reach-eof t))
		(my-message (format "--- Syntax Error ---"))
		(setq syntax-error t))
	      (setq loopflg nil))
	  
	  (while (< i (length action))

	    (setq act (aref action i))
	    (setq a (cdr (assoc 'action act)))
	    
	    (cond
	     ;;Shift
	     ((eq a 's)
	      (parser-shift (cdr (assoc 'num act))))
	     
	     ;;Reduce
	     ((eq a 'r)
	      (if (eq (cdr (assoc 'symbol token)) 'EOF)
		  (progn
		    (my-message (format "--- EOF ---"))
		    (setq reach-eof t)
		    (setq loopflg nil)))
	      (parser-reduce (cdr (assoc 'num act))))
  
	     ;;Accept
	     ((eq a 'acc)
	      (my-message "Parse finish.")
	      (setq parse-finish t)
	      (setq loopflg nil))
	     
	     ;;Error
	     (t
		(my-message (format "syntax error!"))
		(setq syntax-error t)
		(setq loopflg nil)))

	    (setq i (+ 1 i))))))
    
    (my-message (format "result: %s" (parser-result-to-string result)))

    (list (cons 'status (if syntax-error 
			    'syntax-error
			  (if parse-finish
			      'parse-finish
			    (if reach-eof 'reach-eof))))
	  (cons 'result (if parse-finish
			    result
			  (if reach-eof
			      (list 
			       (cons 'stack stack)
			       (cons 'reduce result))))))))
			  
 
(defun get-token-value (pos)
  ;;ruleの0～iには逆順で入ってるので
  (cdr (assoc 'value (cdr (assoc 
			   (- (cdr (assoc 'length rule)) (+ pos 1)) 
			   rule)))))
	

;;ここでYaccで言う各構文規則のアクションを書く
;;Action 
(defun make-ast- ()
  (my-message (format "stack: %s" (parser-result-to-string rules)))
  (let ((rule (car rules)))
    (cond
     ((eq -1 (cdr (assoc 'rule (car rules))))
      (my-message "dummy expr")
      (setq rules (cdr rules))
      nil)
    ;start -> exp
     ((eq 1 (cdr (assoc 'rule (car rules))))
      (my-message "exp")
      (setq rules (cdr rules))
      (make-ast-))
      
      ;;exp -> appexp
      ((eq 2 (cdr (assoc 'rule (car rules))))
       (my-message "appexp")
       (setq rules (cdr rules))
       (make-ast-)
       )
      
      ;;exp -> fn ID => exp
      ((eq 3 (cdr (assoc 'rule (car rules))))
       (my-message "fn ID => exp")
       (setq rules (cdr rules))

       (expr-fn (get-token-value 1)
		(make-ast-)))

      ;;appexp -> atexp
      ((eq 4 (cdr (assoc 'rule (car rules))))
       (my-message "atexp")
       (setq rules (cdr rules))
       (make-ast-)
       )
      ;;appexp -> appexp atexp
      ((eq 5 (cdr (assoc 'rule (car rules))))
       (my-message "appexp atexp")
       (setq rules (cdr rules))
       (let ((arg (make-ast-))
	     (func (make-ast-)))
	 (expr-apply func arg)))

      ;;atexp -> ID
      ((eq 6 (cdr (assoc 'rule (car rules))))
       (setq rules (cdr rules))
       (if (not (get-token-value 0))
	   (progn
	     (my-message "ID:CURSOR")
	     (expr-var nil))
	 (my-message (format "ID: %s" (get-token-value 0)))
	 (expr-var (get-token-value 0))))

      ;;atexp -> CONST
      ((eq 7 (cdr (assoc 'rule (car rules))))
       (setq rules (cdr rules))
       (my-message (format "CONST: %s" rule))
       (if (not (get-token-value 0))
	   (progn
	     (my-message "ID:CURSOR")
	     (expr-var nil))
	 (my-message (format "CONST: %s" (get-token-value 0)))
	 (expr-var (get-token-value 0))))
      
      ;;atexp -> ( exp )
      ((eq 8 (cdr (assoc 'rule (car rules))))
       ;;(my-message " ( exp )")
       (setq rules (cdr rules))
       (make-ast-))
      
      ;;atexp -> let val ID = exp in exp end
      ((eq 9 (cdr (assoc 'rule (car rules))))
       (setq rules (cdr rules))
       (let ((body (make-ast-))
	     (decs (let ((declarations (decs)))
		     (my-message "declarations!!")
		     ;;木構造のDecを並列にする
		     (make-ast-)
		     declarations)))
	     
	 ;(my-message (format "rule 9! decs : %s" decs))
	 (expr-let decs body)))


      ;必ずlet以下で呼び出される
      ((eq 10 (cdr (assoc 'rule (car rules))))
       (setq rules (cdr rules))

       (let ((bindName (get-token-value 1))
	     (bindExpr (make-ast-)))
	 (my-message (format "bindName: %s" bindName))
	 (my-message "rule 10! before cons")
	 (setq declarations (cons 
		       (cons (cdr (assoc 'length declarations))
			     (val-bind bindName bindExpr))
		       declarations))
	 (my-message "rule 10! after cons")
	 (my-message (format "declarations: %s" declarations))
	 (setcdr (assoc 'length declarations)
		 (+ 1 (cdr (assoc 'length declarations))))))


      ((eq 11 (cdr (assoc 'rule (car rules))))
       (setq rules (cdr rules))
       (make-ast-)
       (make-ast-)
      ))))
    
(defun make-ast (result)
  (my-message (format "make-ast: %s" result))
  (let ((rules result))
    (make-ast-)))

(defun algorithm-c-stack-pop ()
  (let ((result (car stack)))
    (setq stack (cdr stack))
    result))

(defun algorithm-c-stack-shift (token)
  (setq stack (cons token stack)))

;;fun parser-result-to-string (output)
;;(let ((result "")
;;	(temp output))
;;  (while (car temp)
;;    (setq result (format "%s %s" result  (cdr (assoc 'rule (car temp)))))
;;    (setq temp (cdr temp)))
;;   result))

(defun algorithm-c-push-rHistory ( a)
  (setq rHistory (cons a rHistory)))

;;length 0 1 2..

(defun top-is-start (r)
  ;(my-message (format "top-is-start:%s" (parser-result-to-string r)))
  (if (and  r
	    (= 1 (cdr (assoc 'rule (car r)))))
      (progn 
	;(my-message "top-is-start:t")
	t)
    ;(my-message "top-is-start:nil")
     nil))
      

(defun print-rHistories (r)
  (let ((len (cdr (assoc 'length r)))
	(i 0)
	temp)

    (while (< i len)
      (setq temp (cdr (assoc i r)))
      (my-message (format "[%s] %s" i (parser-result-to-string temp)))
      (setq i (+ 1 i)))))

(defun join-rHistory (a b)
  (let ((result  nil)
	(len (cdr (assoc 'length a)))
	(j 0)
	(i 0))
   ; (my-message "▼Join▼")
    ;(my-message " a =>")
    ;(print-rHistories a)
    ;(my-message " b =>")
    ;(print-rHistories b)
    (if a
	(while (< i len)
	  (if (top-is-start (cdr (assoc i a)))
	      (progn
		(setq result (cons (cons j (cdr (assoc i a)))
				   result))
		(setq j (+ 1 j))))
	  (setq i (+ 1 i))
	  ))
      
    (setq len (cdr (assoc 'length b)))
    (setq i 0)
    
    (if b
	(while (< i len)
	  (if (top-is-start (cdr (assoc i b)))
	      (progn
		(setq result (cons (cons j (cdr (assoc i b)))
				   result))
		(setq j (+ 1 j))))
	  (setq i (+ 1 i))))
      
    (setq result (cons (cons 'length j)
		       result))
    ;(my-message "Joined.")
    ;;(print-rHistories result)
    result))
    
;アルゴリズムC 構文木補完
(defun algorithm-c (stack rHistory depth used-rules)
  (my-message (format "■algorithm-c: %s" depth))
  (my-message (format "  stack: %s" (c-args-to-string stack)))
  (my-message (format "  rHistory: %s" (parser-result-to-string rHistory)))
  (my-message (format "%s " stack))
  (my-message (format "used: %s" used-rules))
  (if (< depth lambda-loop-depth);;8-

      (let ((top (algorithm-c-stack-pop))
	    (used-rules (copy-sequence used-rules)))
	(setq used-rules (list))
	(my-message (format "top:%s" top))
	(cond
	 
	 ((string= top "start")
	  (my-message top)
	  (list
	   (cons 'length 1)
	   (cons 0 rHistory)))

	 ((string= top "exp")
	  (my-message top)
	  (let ((sec (algorithm-c-stack-pop)))
	    (cond
	     ((string= sec "(")
	      (algorithm-c-stack-shift "atexp")
	      
	      (algorithm-c-push-rHistory (list (cons 'rule 8)
							(cons 'length 3)
							(cons 0 top)
							(cons 1 nil)
							(cons 2 nil)))
	      (algorithm-c stack rHistory (+ 1 depth) used-rules))
	 
	     ((string= sec "=>")

	      (algorithm-c-push-rHistory (list (cons 'rule 3)
							(cons 'length 4)
							(cons 0 top)
							(cons 1 sec)
							(cons 2 (list (cons 'value (algorithm-c-stack-pop))))
							(cons 3 (algorithm-c-stack-pop))))

	      (algorithm-c-stack-shift  "exp")
	      (algorithm-c stack rHistory  (+ 1 depth) used-rules))
	     
	     ((string= sec "=")
	      ;; = exp : dec 
	      ;rule 10
	      (algorithm-c-push-rHistory (list (cons 'rule 10)
					       (cons 'length 4)
					       (cons 0 top);exp
					       (cons 1 sec);=
					       (cons 2 (list (cons 'value (algorithm-c-stack-pop))));ID
					       (cons 3 (algorithm-c-stack-pop))));;val

	      (algorithm-c-stack-shift  "dec")
	      (algorithm-c stack rHistory  (+ 1 depth) used-rules))

	     ((string= sec "in")
	      (algorithm-c-push-rHistory (list (cons 'rule 9)
					       (cons 'length 5)
					       (cons 0 nil);end
					       (cons 1 top);exp
					       (cons 2 sec);in
					       (cons 3 (algorithm-c-stack-pop));;dec
					       (cons 4 (algorithm-c-stack-pop))));;let

	      (algorithm-c-stack-shift  "atexp")
	      (algorithm-c stack rHistory  (+ 1 depth) used-rules))
	     
	     

	     (t
	      (algorithm-c-stack-shift "start")
	      (algorithm-c-push-rHistory (list (cons 'rule 1)
							(cons 'length 1)
							(cons 0 nil)))
	      (algorithm-c stack rHistory (+ 1 depth) used-rules)))))
	      


	 ((string= top "appexp")
	  ;(my-message "appexp:分岐")
	  (let ((rHistory2 (copy-sequence rHistory))
		(stack2 (copy-sequence stack))
		(used-rules-1 (copy-sequence used-rules))
		(used-rules-2 (copy-sequence used-rules))
		r1 r2)
	    
	    (algorithm-c-push-rHistory (list
					(cons 'rule 2)
					(cons 'length 1)
					(cons 0 nil)))
	    (algorithm-c-stack-shift "exp")
	    (push 2 used-rules-1)
	    (setq r1 (if (not (member 2 used-rules))
			 (copy-sequence (algorithm-c stack rHistory (+ depth 1) used-rules-1))
		       (my-message "打ち切り：2")
		       (list (cons 'length 0))))
	    
	    ;(my-message "appexp:一つ目終了")
	    ; sasano memo: eliminate generation of application.
	    (if t
		(let*
		    ((rHistory rHistory2)
		     (stack stack2))
		  ;;dummy
		  (algorithm-c-push-rHistory (list
					      (cons 'rule -1)
					      (cons 'length 0))) ;

		  (algorithm-c-push-rHistory (list
					      (cons 'rule 5)
					      (cons 'length 2)
					      (cons 0 nil)
					      (cons 1 nil)))
		  (algorithm-c-stack-shift "appexp")
		  (push 5 used-rules-2)
		  (setq r2 (if (not (member 5 used-rules))
			       (copy-sequence(algorithm-c stack rHistory (+ depth 1) used-rules-2))
			     (my-message "打ち切り：5")
			     (list (cons 'length 0))))
					;   (my-message "appexp:二つ目終了"))
					; (my-message (format "r1:%s" r1))
					; (my-message (format "r2:%s" r2))
	      (join-rHistory r1 r2))
	      r1)))

	    

	 ((string= top "atexp")
	  (my-message top)
	  (let
	      ((sec (algorithm-c-stack-pop)))
	    (cond
	     ((string= sec "appexp")
	      (algorithm-c-stack-shift "appexp")
	      (algorithm-c-push-rHistory (list
					  (cons 'rule 5)
					  (cons 'length 2)
					  (cons 0 nil)
					  (cons 1 nil)))
	      (algorithm-c stack rHistory (+ 1 depth) used-rules))
	     (t
	      (algorithm-c-stack-shift sec)
	      (algorithm-c-stack-shift "appexp")
	      (algorithm-c-push-rHistory (list
					  (cons 'rule 4)
					  (cons 'length 1)
					  (cons 0 nil)))
	      (algorithm-c stack rHistory (+ 1 depth) used-rules)))))

	 ((string= top "fn")
	  (my-message top)
	   ;;dummy
	  (algorithm-c-push-rHistory (list
				      (cons 'rule -1)
				      (cons 'length 0)))
	  (algorithm-c-push-rHistory (list (cons 'rule 3)
					   (cons 'length 4)
					   (cons 0 nil)
					   (cons 1 nil)
					   (cons 2 (list (cons 'value nil)))
					   (cons 3 top)))
	  
	  (algorithm-c-stack-shift  "exp")
	  (algorithm-c stack rHistory  (+ 1 depth) used-rules))

	 ((string= top "=>");;FN
	  (my-message top)
	   ;;dummy
	  (algorithm-c-push-rHistory (list
				      (cons 'rule -1)
				      (cons 'length 0)))
	  (algorithm-c-push-rHistory (list (cons 'rule 3)
					   (cons 'length 4)
					   (cons 0 nil)
					   (cons 1 top)
					   (cons 2 (list (cons 'value (algorithm-c-stack-pop))))
					   (cons 3 (algorithm-c-stack-pop))))
	  
	  (algorithm-c-stack-shift  "exp")
	  (algorithm-c stack rHistory  (+ 1 depth) used-rules))


	 ((string= top "(")
	  (my-message top)
	  (algorithm-c-stack-shift "atexp")
	  (algorithm-c-push-rHistory (list (cons 'rule 8)
					   (cons 'length 3)
					   (cons 0 nil)
					   (cons 1 nil)
					   (cons 2 nil)))
	  (algorithm-c stack rHistory (+ 1 depth) used-rules))

	 
	 ((string= top ")")
	  (my-message top)
	  (algorithm-c-stack-shift "atexp")
	  (algorithm-c-push-rHistory (list (cons 'rule 8)
					       (cons 'length 3)
					       (cons 0 (algorithm-c-stack-pop))
					       (cons 1 (algorithm-c-stack-pop))
					       (cons 2 nil)))
	  (algorithm-c stack rHistory (+ 1 depth) used-rules))

	 ((string= top "let")
	  (my-message top)
	  
	  ;;dummy(exp)
	  (algorithm-c-push-rHistory (list
				      (cons 'rule -1)
				      (cons 'length 0)))
	   ;;dummy(dec)
	  (algorithm-c-push-rHistory (list
					  (cons 'rule -1)
					  (cons 'length 0)))

	  (algorithm-c-push-rHistory (list (cons 'rule 9)
					   (cons 'length 5)
					   (cons 0 nil);end
					   (cons 1 nil);exp
					   (cons 2 nil);in
					   (cons 3 nil);dec
					   (cons 4 top)));let


	  (algorithm-c-stack-shift  "atexp")
	  (algorithm-c stack rHistory  (+ 1 depth) used-rules))

	 ((string= top "val")
	  ;rule:10 val id = exp
	  (my-message top)

	  ;;dummy(exp)
	  (algorithm-c-push-rHistory (list
					  (cons 'rule -1)
					  (cons 'length 0)))

	  (algorithm-c-push-rHistory (list (cons 'rule 10)
					   (cons 'length 4)
					   (cons 0 nil);exp
					   (cons 1 nil);=
					   (cons 2 (list (cons 'value nil)));id
					   (cons 3 top)));val


	  (algorithm-c-stack-shift  "dec")
	  (algorithm-c stack rHistory  (+ 1 depth) used-rules))

	 ((string= top "=")
	  (my-message top)
	  ;;rule 10 :val id = exp
	   ;;dummy(exp)
	  (algorithm-c-push-rHistory (list
					  (cons 'rule -1)
					  (cons 'length 0)))

	  (algorithm-c-push-rHistory (list (cons 'rule 10)
					   (cons 'length 4)
					   (cons 0 nil);;exp
					   (cons 1 top);;=
					   (cons 2 (list (cons 'value (algorithm-c-stack-pop))));;id
					   (cons 3 (algorithm-c-stack-pop))));val



	  (algorithm-c-stack-shift  "dec")
	  (algorithm-c stack rHistory  (+ 1 depth) used-rules))

	 ((string= top "in")
	  ;;rule 9
	  (my-message top)
	  ;;dummy
	  (algorithm-c-push-rHistory (list
					  (cons 'rule -1)
					  (cons 'length 0)))

	  (algorithm-c-push-rHistory (list (cons 'rule 9)
					   (cons 'length 5)
					   (cons 0 nil);end
					   (cons 1 nil);exp:dummy
					   (cons 2 top);in
					   (cons 3 (algorithm-c-stack-pop));dec
					   (cons 4 (algorithm-c-stack-pop))));let


	  (algorithm-c-stack-shift  "atexp")
	  (algorithm-c stack rHistory  (+ 1 depth) used-rules))

	 ((string= top "end")
	  ;rule:9
	  (my-message top)
	  (algorithm-c-push-rHistory (list (cons 'rule 9)
					   (cons 'length 5)
					   (cons 0 top);end
					   (cons 1 (algorithm-c-stack-pop));exp
					   (cons 2 (algorithm-c-stack-pop));in
					   (cons 3 (algorithm-c-stack-pop));dec
					   (cons 4 (algorithm-c-stack-pop))));let

	  (algorithm-c-stack-shift  "atexp")
	  (algorithm-c stack rHistory  (+ 1 depth) used-rules))

	 ((string= top "dec")
	  (let ((sec (algorithm-c-stack-pop)))
	    (cond
	     ((string= sec "dec")
					;rule:9
	      (algorithm-c-push-rHistory (list (cons 'rule 11)
					       (cons 'length 2)
					       (cons 0 top) ;dec
					       (cons 1 sec)));dec

	      (algorithm-c-stack-shift  "dec")
	      (algorithm-c stack rHistory  (+ 1 depth) used-rules))
	     
	     ((string= sec "let")
	      ;;rule:9
	      	      ;dummy
	      (algorithm-c-push-rHistory (list
					  (cons 'rule -1)
					  (cons 'length 0)))
	      (algorithm-c-push-rHistory (list (cons 'rule 9)
					       (cons 'length 5)
					       (cons 0 nil) ;end
					       (cons 1 nil)	;exp
					       (cons 2 nil)	;in
					       (cons 3 top)	;dec
					       (cons 4 sec))) ;let

	      (algorithm-c-stack-shift  "atexp")
	      (algorithm-c stack rHistory  (+ 1 depth) used-rules)))))
	     
	 ((string-match "[a-zA-Z+/*-]+" top)
	  (let ((sec (algorithm-c-stack-pop)))
	    (cond
	     ((string= sec "val")
	      ;;rule 10: val id = exp
	      ;dummy
	      (algorithm-c-push-rHistory (list
					  (cons 'rule -1)
					  (cons 'length 0)))

	      (algorithm-c-push-rHistory (list (cons 'rule 10)
					       (cons 'length 4)
					   (cons 0 nil);exp
					   (cons 1 nil);=
					   (cons 2 (list (cons 'value top)));id
					   (cons 3 sec)));val


	      (algorithm-c-stack-shift  "dec")
	      (algorithm-c stack rHistory  (+ 1 depth) used-rules))

	     ((string= sec "fn")
	      (algorithm-c-push-rHistory (list
					  (cons 'rule -1)
					  (cons 'length 0)))
	      (algorithm-c-push-rHistory (list (cons 'rule 3)
					       (cons 'length 4)
					       (cons 0 nil)
					       (cons 1 nil)
					       (cons 2 (list (cons 'value top)))
					       (cons 3 nil)))
	      (algorithm-c-stack-shift  "exp")
	      (algorithm-c stack rHistory  (+ 1 depth) used-rules))

	     (t
	      (algorithm-c-push-rHistory (list (cons 'rule 6)
					       (cons 0 (list (cons 'value top)))))
	      (algorithm-c-stack-shift sec)
	      (algorithm-c-stack-shift  "atexp")
	      (algorithm-c stack rHistory  (+ 1 depth) used-rules))))
	 )))

	    
    (my-message "上限に到達")
    (list (cons 'length 0))))
  



;;パースだけする
(defun test-parser ()
  (interactive)
  (let* ((parser-output (my-parser (my-lexer)))
	 (parser-status (cdr (assoc 'status parser-output))))
    ;;パーサの結果によって場合分け
    ;;パース完了　パース途中　構文エラー
    
    (cond 
     ((eq parser-status 'syntax-error)
      (my-message "Syntax Error.."))
     
     ((eq parser-status nil)
      (my-message "Parsed to Point"))

     ((eq parser-status 'parse-finish)
      (my-message "Parse Finished.")
      (let (expr inference-result)
	(setq expr (make-ast (cdr (assoc 'result parser-output))))
	(print-expr expr 0)
	
	;;(setq inference-result (catch 'error-nil-expr
	;;			 (inference (var-env nil) expr)))
	
	;;型推論が無事終わればinference-result:type
	;;(if (cdr (assoc 'class inference-result))
	;;    (print-expr expr))
	
	
	
	)))))

    



(provide 'lambda-parse)
