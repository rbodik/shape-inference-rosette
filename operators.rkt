#lang rosette

(require "checker.rkt")
(require "shape.rkt")

(provide onnx/add onnx/gemm)

(define (onnx/add a b r)
  (assert (multi-dir-bcast a b r)))

; General Matrix multiplication: https://en.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms#Level_3
;
; A' = transpose(A) if transA else A
; 
; B' = transpose(B) if transB else B
; 
; Compute Y = alpha * A' * B' + beta * C, where
; input tensor A has shape (M, K) or (K, M),
; input tensor B has shape (K, N) or (N, K),
; input tensor C is broadcastable to shape (M, N),
; and output tensor Y has shape (M, N).
; A will be transposed before doing the computation if
; attribute transA is non-zero, same for B and transB.
; 
; This operator supports unidirectional broadcasting
; (tensor C should be unidirectional broadcastable to tensor A * B);
; for more details please check the doc on broadcasting

; shape x shape x shape x shape -> Unit (adds an assert)
(define (onnx/gemm a b c y) ; TODO add transpose flags
    (let ([M (dim a 0)]
          [K (dim a 1)]
          [BK (dim b 0)]
          [N  (dim b 1)]
          [YM (dim y 0)]
          [YN (dim y 1)])
      (assert
       (and (= K BK)            ; A and B match in K dimension 
            (= YM M)(= YN N)    ; the result has the right shape
            (one-dir-bcast y c) ; C is one-dir brodcastable to result
            (= (rank a) 2)
            (= (rank b) 2)
            (= (rank y) 2)
;            ))))
           
        