#lang rosette

; import the concrete checker
; and make it symbolic, ie turn it into an shape inferencer

(require "checker.rkt")
(require "operators.rkt")
(require "symbolic-shape.rkt")

(provide multi-dir-bcast Add Gemm)

; symbolic shape x symbolic shape --> a new symbolic shape of result
(define (Add a b [r (fresh-shape)])
  (begin (onnx/add a b r)
         r))
    
; symbolic shape x symbolic shape x symbolic shape --> a new symbolic shape of result
(define (Gemm a b c [y (fresh-shape)])
  (begin (onnx/gemm a b c y)
         y))
    