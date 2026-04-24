;;(require 'tokenizer-cursor-macro)
(require 'tokenizer-macro)

(define-tokenizer kmyacconv-sample-mode-tokenizer
  ;;status of tokenizer
  (S C)
  ;;variables (in current implementation, variables declared here are in global. )
  ((com-level 0)
   (str_start 0)
   (str ""))

  ;;Definitions of tokens (status, regexp, actions...)
  (INITIAL "[ \t]+"  (continue))
  (INITIAL "\n" (continue))
  (INITIAL "$"   (continue))
  
    ;;comment
  (INITIAL "(\\*"
	   (yybegin 'C)
	   (setq com-level 1)
	   (continue))
  (INITIAL "\\*)"
	   (tokenizer-error-message 0 (format "error: unmatched close comment"))
	   (continue))

  ;;reserved word
  (INITIAL "end" (return 'END yypos (+ yypos 3)))
  (INITIAL "fn" (return 'FN yypos (+ yypos 2)))
  (INITIAL "in" (return 'IN yypos (+ yypos 2)))  
  (INITIAL "let" (return 'LET yypos (+ yypos 3)))
  (INITIAL "val" (return 'VAL yypos (+ yypos 3)))
  (INITIAL "(" (return 'LP yypos (+ yypos 1)))
  (INITIAL ")" (return 'RP yypos (+ yypos 1)))

  ;;integer in decimal
  (INITIAL "[1-9][0-9]*" (return 'INT yypos (+ yypos (length yytext)) yytext))
  
  ;;identifier
  (INITIAL "[a-zA-Z][a-zA-Z0-9_']*" (return 'ID yypos (+ yypos (length yytext)) yytext))
  (INITIAL "[!%&$+/:#<>=@\\\\~'^\\?\\|\\*-]+"
	   (cond 
	    ((equal yytext "=")
	     (return 'EQ yypos(+ yypos (length yytext)) yytext))
	    ((equal yytext "=>")
	     (return 'EQARW yypos(+ yypos (length yytext)) yytext))
	    (t 
	     (return 'ID yypos (+ yypos (length yytext)) yytext))))
  
  ;;string
  (INITIAL "\""
	   (yybegin 'S)
	   (setq str "")
	   (setq str_start yypos)
	   (continue))

  ;;illigal token
  (INITIAL "."
	   (tokenizer-error-message (format "error: illigal token at %s ::%s" (match-end 0) yytext))
	   (continue))
  (C "(\\*"
     (setq com-level (+ 1 com-level))
     (continue))
  (C "\\*)"
     (setq com-level (- com-level 1))
     (when (eq com-level 0)
       (yybegin 'INITIAL))
     (continue))
  (C "[a-zA-Z0-9/\\-\\+\t\n\\. ,]+" (continue))
  (C "\n+" (continue))
  (C "[ \t]+" (continue))
  (C "."  (continue))
  
    (S "\""
     (yybegin 'INITIAL)
     (return  'STRING str_start yypos str))
  (S "\\\\\n"  (yybegin 'F)  (continue))
  (S "\\\\[ \t]" (yybegin 'F) (continue))
  
  (S "." (setq str (concat str yytext))  (continue))
  
  (F "\n" (continue))
  (F "[ \t]" (continue))
  (F "\\\\" (yybegin 'S) (continue))
  (F "." 
     (tokenizer-error-message (format "unclosed string at %s" yypos))
     (yybegin 'INITIAL)
     (return 'STRING str_start yypos str)))

(provide 'kmyacconv-sample-mode-tokenizer)
