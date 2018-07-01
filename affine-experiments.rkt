#lang rosette/safe

; Here are examples of how Rosette synthesized affine functions

(current-bitwidth #f)  ; model ints as (unbounded) Integers.  Z3 may use its ILP solver.
; (current-bitwidth 10)  ; model ints as bitvectors of specified length.  Z3 will use its bitvector solver. 

(require rosette/lib/synthax)

(define-symbolic n m integer?)

; define a few concrete affine functions 
(define (f)     (+ (* 3 n)(* -4 m) 1 ))
(define (g)     (+ (* 3 n)(* -4 m) 4 ))

; gen-sa-dim: a generator symbolic affine dimension (symbolic == constants are to be solved)
(define (?) (begin (define-symbolic* c integer?) c))
(define (gen-sa-dim)   (+ (* (?) n)(* (?) m)(?)))

; generate a few symbolic affine functions 
(define  J  (gen-sa-dim))
(define  K  (gen-sa-dim))
  
(define binding
  (synthesize #:forall (list n m)
              #:assume (assert (and (>= m 0) (>= n 0) (< n 10) (< m 10)))
              #:guarantee (assert (and
                                   (< (f) J)
                                   (<  J  K)
                                   (<  K (g))))))

(evaluate (cons J K) binding)
