#lang rosette

;; Affine solver


; Select between bitvector and ILP solver in z3

(current-bitwidth #f)    ; ILP
; (current-bitwidth 10)   ; BV

(require "shape.rkt")
(require "symbolic-shape.rkt")
(require "symbolic-checker.rkt")
(provide (all-from-out "symbolic-checker.rkt"))

(provide sh fresh-shape print-shapes infer-shapes)
(provide n m k)

; the fresh shape will have an affine rerpesentation

(define-symbolic n m k integer?)
(define (fresh-affine-shape) (as n m k))
(set-fresh-shape-factory! fresh-affine-shape)


; the solver

; Parameters to inference are the program and a list of shapes that are program's inputs.
; The program will be called in infer-shapes so that shape asserts
; happen inside #:guarantee as required by synthesize.

(define (infer-shapes program arg-shapes)
  (synthesize
   #:forall (list n m k)
   #:assume (assert (and (> m 0) (> n 0)(> k 0)(< m 256)(< n 256)(< k 256)))
   #:guarantee (apply program arg-shapes)))

