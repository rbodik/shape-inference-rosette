#lang rosette

(require "shape.rkt")
(require "checker.rkt")
(require "operators.rkt")

(define s1 (shape 2 '(4 5)))
(define s1same (shape 2 '(4 5)))
(define s2 (shape 2 '(5 6)))

; false cases
(list
 (multi-dir-rules 1 1 3)
 (multi-dir-rules 1 2 3)
 (multi-dir-rules 0 0 2)
 (multi-dir-rules 1 2 1)
 (multi-dir-rules 2 3 3)
 (multi-dir-rules 2 2 1)
 (multi-dir-rules 0 2 3)
 (multi-dir-rules 1 0 0)
 )

; true cases
(list
 (multi-dir-rules 1 1 1)
 (multi-dir-rules 1 2 2)
 (multi-dir-rules 2 2 2)
 (multi-dir-rules 2 1 2)
 (multi-dir-rules 0 3 3)
 (multi-dir-rules 3 0 3)
 (multi-dir-rules 0 0 0)
 )

"Multi-directional broadcasting"

"true cases"

(multi-dir-bcast (shape 2 '(2 2))
                 (shape 2 '(2 1))
                 (shape 2 '(2 2)))

(multi-dir-bcast (shape 1 '(2))
                 (shape 2 '(2 3))
                 (shape 2 '(2 3)))

(multi-dir-bcast (shape 0 '())
                 (shape 2 '(2 3))
                 (shape 2 '(2 3)))

(displayln "false cases")

(multi-dir-bcast (shape 2 '(2 2))
                 (shape 2 '(2 2))
                 (shape 2 '(2 1)))

(multi-dir-bcast (shape 1 '(2))
                 (shape 2 '(2 1))
                 (shape 2 '(2 2)))

(multi-dir-bcast (shape 2 '(2 2))
                 (shape 2 '(2 1))
                 (shape 0 '(2)))

(multi-dir-bcast (shape 2 '(2 2))
                 (shape 2 '(2 1))
                 (shape 3 '(2 2 1)))

"One-directional rules"

"true cases"

(one-dir-rules-test 0 0)
(one-dir-rules-test 1 1)
(one-dir-rules-test 1 0)
(one-dir-rules-test 2 1)
(one-dir-rules-test 2 0)
(one-dir-rules-test 2 2)

"false cases"

(one-dir-rules-test 0 1)
(one-dir-rules-test 1 2)
(one-dir-rules-test 0 2)
(one-dir-rules-test 2 3)


"One-directional broadcasting"

"true cases"

(one-dir-bcast (shape 2 '(2 2))
               (shape 2 '(2 1)))

(one-dir-bcast (shape 2 '(2 3))
               (shape 1 '(2)))

(one-dir-bcast (shape 2 '(2 3))
               (shape 0 '()))

"false cases"

(one-dir-bcast (shape 2 '(2 1))
               (shape 2 '(2 2)))

(one-dir-bcast (shape 1 '(2))
               (shape 2 '(2 1)))

(one-dir-bcast (shape 1 '(2))
               (shape 2 '(2 1)))

"Gemm"

"true cases"

(onnx/gemm (shape 2 '(2 3))  ; A
           (shape 2 '(3 4))  ; B
           (shape 2 '(2 4))  ; C
           (shape 2 '(2 4))) ; Y

(onnx/gemm (shape 2 '(2 3))  ; A
           (shape 2 '(3 4))  ; B
           (shape 0 '())     ; C
           (shape 2 '(2 4))) ; Y

"false cases"

(onnx/gemm (shape 2 '(2 5))  ; A  (mismatch in K dimension)
           (shape 2 '(3 4))  ; B
           (shape 2 '(2 4))  ; C
           (shape 2 '(2 4))) ; Y

(onnx/gemm (shape 2 '(2 3))  ; A  (mismatch in K dimension)
           (shape 2 '(3 4))  ; B
           (shape 2 '(2 3))  ; C
           (shape 2 '(2 4))) ; Y



