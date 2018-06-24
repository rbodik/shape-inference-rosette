#lang rosette

; import the concrete checker
; and make it symbolic, ie turn it into an shape inferencer

(require "checker.rkt")
(require "operators.rkt")
(require "symbolic-shape.rkt")

(provide multi-dir-bcast Add Gemm)

; symbolic shape x symbolic shape --> a new symbolic shape of result
(define (Add a b)
  (let* ([r (fs)]
         [ignored (onnx/add a b r)])
    r))
    
; symbolic shape x symbolic shape x symbolic shape --> a new symbolic shape of result
(define (Gemm a b c)
  (let* ([y (fs)]
         [ignored (onnx/gemm a b c y)])
    y))
    

; for convenience, wrap around some standard Rosette functions
;
; None here yet.

; Lessons:
;
; 1) test symbolic evaluation outside (solve) because failures
; during symbolic evaluation result in hard to explain (unsat).
; Example: (make-list k v) needs concrete value k)

;(define (multi-dir-bcast-old a b r)
;  (let ([max-rank (max (rank a) (rank b) (rank r))])
;    (andmap rules
;            (dims-fill a max-rank)
;            (dims-fill b max-rank)
;            (dims-fill r max-rank))))
