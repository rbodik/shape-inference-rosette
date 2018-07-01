#lang rosette

(require "checker.rkt")
(require "shape.rkt")

"concrete tests"

(define c1 (shape 2 '(2 3)))
(define c2 (shape 2 '(1 3)))

(multi-dir-bcast c1 c2 c2)
(multi-dir-bcast c1 c2 c1)

