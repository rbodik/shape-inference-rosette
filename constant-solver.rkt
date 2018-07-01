#lang rosette

;; Constant-shape solver:
;; 
;; produces shapes whose dims are constants, not parametric in n,m.
;; 


; Select between bitvector and ILP solver in z3

; (current-bitwidth #f)    ; ILP
(current-bitwidth 10)   ; BV

(require "shape.rkt")
(require "symbolic-shape.rkt")
(require "symbolic-checker.rkt")
(provide (all-from-out "symbolic-checker.rkt"))

(provide sh fresh-shape print-shapes infer-shapes)

; the fresh shape will include dimensions that are symbolic constants 

(set-fresh-shape-factory! cs)


; the solver

(define (infer-shapes program)
  (solve program))
