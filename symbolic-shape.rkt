#lang rosette

; import the concrete shape structure and a few useful functions

(require racket/list)
(require "shape.rkt")
(require "bound.rkt")

(provide fresh-shape set-fresh-shape-factory! cs as shape rank print-shapes)

; the procedure to create a fresh shape, set in affine-solver.rkt and constant-solver.rkt 

(define fresh-shape (λ () "to be set by solvers"))
(define (set-fresh-shape-factory! sf) (set! fresh-shape sf))

; All shapes support up to MAX-RANK dimensions.
; This user-confugrable constant is defined in bound.rkt.

; Constant shapes.
;
; Their dimensions, when solved, are constants.
; 
; Create a fresh constant symbolic shape.
(define (cs)
  (begin 
    (define (fresh-dim) (define-symbolic* _ integer?) _)
    (define-symbolic* rank integer?)
    (assert (and (< 0 rank)(<= rank MAX-RANK)))
    (shape rank (for/list ([i MAX-RANK]) (fresh-dim)))))

; Affine shapes.
;
; These shapes will be parameterize over symbolic variables listed in params.
; These symbols, typically n, m, k, are defined in affine-solver.rkt:
;
; Create a fresh affine shape:

(define (as . params)  ; params is a variable arguments parameter
  (begin 
    (define-symbolic* rank integer?)
    (define (fresh-const) (define-symbolic* c integer?) c)
    (define (term v) (* (fresh-const) v))
    (define (fresh-affine-dim) (foldr + (fresh-const) (map term params)))
    (assert (and (< 0 rank)(<= rank MAX-RANK)))
    (shape rank (for/list ([i MAX-RANK]) (fresh-affine-dim)))))

;; printing of symbolic shapes given a solution to shapes' symbolic constants
;;
;; htable maps string names of shapes (ignored by the system) to their symbolic values
;; which are used for printing

(define (print-shapes htable sol)
  (for ([pair (hash->list htable)])
    (printf "~a: ~s~n" (car pair) (evaluate (cdr pair) sol))
    ))