#lang rosette

; import the concrete shape structure and a few useful functions

(require racket/list)
(require "shape.rkt")
(require "bound.rkt")

(provide fs shape rank)

; fresh symbolic shape (up to 6 dimensions)
(define (fs)
  (begin 
    (define (fresh-dim) (define-symbolic* _ integer?) _)
    (define-symbolic* rank integer?)
    (>= rank (+ rank 1))
    (shape rank (for/list ([i MAX-RANK]) (fresh-dim)))))

; FYI, observe the sybolic values created
;
; (fs)
; (dims (fs)) 