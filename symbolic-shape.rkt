#lang rosette

; import the concrete shape structure and a few useful functions

(require racket/list)
(require "shape.rkt")
(require "bound.rkt")

(provide fs ps n m k shape rank)

; fresh constant symbolic shape (up to MAX_RANK dimensions). This constant is set in bound.rkt.
(define (fs)
  (begin 
    (define (fresh-dim) (define-symbolic* _ integer?) _)
    (define-symbolic* rank integer?)
    (assert (and (< 0 rank)(<= rank MAX-RANK)))
    (shape rank (for/list ([i MAX-RANK]) (fresh-dim)))))

; fresh affine symbolic shape
; Assume that all affine shapes are parameterize over n, m defined here:
(define-symbolic n m k integer?)

(define (ps . x)  ; x is a variable arguments parameter
  (begin 
    (define-symbolic* rank integer?)
    (define (fresh-const) (define-symbolic* c integer?) c)
    (define (term v) (* (fresh-const) v))
    (define (fresh-affine-dim) (foldr + (fresh-const) (map term x)))
    (assert (and (< 0 rank)(<= rank MAX-RANK)))
    (shape rank (for/list ([i MAX-RANK]) (fresh-affine-dim)))))

;; Try these expressions to see what symbolic values are produced by fresh symbolic shapes
;;
;(fs)
;; dimensions above the symbolic rank are mapped to 0
;(dims (fs))
;
;; an affine shape
;(ps n m)
;;
;(dims (ps n m))