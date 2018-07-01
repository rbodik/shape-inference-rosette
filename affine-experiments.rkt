#lang rosette/safe

; Here are examples of how Rosette synthesized affine functions

(current-bitwidth #f)  ; model ints as (unbounded) Integers.  Z3 may use its ILP solver.
; (current-bitwidth 14)  ; model ints as bitvectors of specified length.  Z3 will use its bitvector solver. 

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

(evaluate J binding)
(evaluate K binding)

;; Synthesis of non-affine bounds

(current-bitwidth 16)

(define (non-affine-spec)         (+ (*  3  n) (quotient n 12 ) (modulo n  4 ) 2))
(define (gen-sym-nonaffine-dim)   (+ (* (?) n) (quotient n (?)) (modulo n (?)) (?)))

(define L (gen-sym-nonaffine-dim))

(define binding2
  (synthesize #:forall (list n m)
              #:assume (assert (and (>= m 0) (>= n 0) (< n 2048) (< m 2048)))
              #:guarantee (assert (= (non-affine-spec) L))))

(evaluate L binding2)
