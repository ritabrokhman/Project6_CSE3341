; Rita Brokhman.1
; myfns.scm
; Project 6 - PLAN interpreter
; Supports: planProg, planAdd, planSub, planMul, planIf, planLet, planFunction, function calls
; Uses dynamic scoping

(define (plan expr)
  (eval-plan expr '()))

(define (eval-plan expr env)
  (cond
    ;; Entry point
    ((and (pair? expr) (equal? (car expr) 'planProg))
     (eval-plan (cadr expr) env))

    ;; planIf
    ((and (pair? expr) (equal? (car expr) 'planIf))
     (let ((cond-val (eval-plan (cadr expr) env)))
       (if (> cond-val 0)
           (eval-plan (caddr expr) env)
           (eval-plan (cadddr expr) env))))

    ;; planAdd
    ((and (pair? expr) (equal? (car expr) 'planAdd))
     (+ (eval-plan (cadr expr) env) (eval-plan (caddr expr) env)))

    ;; planSub
    ((and (pair? expr) (equal? (car expr) 'planSub))
     (- (eval-plan (cadr expr) env) (eval-plan (caddr expr) env)))

    ;; planMul
    ((and (pair? expr) (equal? (car expr) 'planMul))
     (* (eval-plan (cadr expr) env) (eval-plan (caddr expr) env)))

    ;; planLet for constant or expression
    ((and (pair? expr) (equal? (car expr) 'planLet))
     (let ((id (cadr expr))
           (val (caddr expr)))
       (if (and (pair? val) (equal? (car val) 'planFunction))
           ;; Function definition
           (eval-plan (cadddr expr) (cons (cons id val) env))
           ;; Regular let-binding
           (eval-plan (cadddr expr) (cons (cons id (eval-plan val env)) env)))))

    ;; function call (id arg)
    ((and (pair? expr)
          (symbol? (car expr))) ; possible function call
     (let ((binding (lookup-binding (car expr) env)))
       (if (and (pair? binding)
                (equal? (car binding) 'planFunction))
           (let* ((param (cadr binding))
                  (body (caddr binding))
                  (arg-val (eval-plan (cadr expr) env)))
             ;; bind parameter to argument, then evaluate body
             (eval-plan body (cons (cons param arg-val) env)))
           (error "Attempted to call non-function:" expr))))

    ;; variable lookup
    ((symbol? expr)
     (lookup-value expr env))

    ;; constants
    ((integer? expr) expr)

    (else
     (error "Unknown expression:" expr))))

;; Look up variable value in environment
(define (lookup-value id env)
  (cond
    ((null? env)
     (error "Unbound identifier:" id))
    ((equal? (car (car env)) id)
     (cdr (car env)))
    (else
     (lookup-value id (cdr env)))))

;; Look up full binding (including function body) in environment
(define (lookup-binding id env)
  (cond
    ((null? env)
     (error "Unbound identifier:" id))
    ((equal? (car (car env)) id)
     (cdr (car env)))
    (else
     (lookup-binding id (cdr env)))))
