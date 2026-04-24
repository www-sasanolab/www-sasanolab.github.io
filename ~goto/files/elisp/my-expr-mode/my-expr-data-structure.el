(defun variable-name (name s e)
  (list name s e))

(defun exp-let (var bind-expr body)
  (list 'let var bind-expr body))

(defun exp-abs (var body)
  (list 'abs var body))

(defun exp-app (fun arg)
  (list 'app fun arg))

(defun exp-var (var)
  (list 'var var))

(defun exp-int (value)
  (list 'int value))

(defun exp-str (str)
  (list 'str str))

(provide 'my-expr-data-structure)
