#lang rosette

(require rosette/lib/synthax)
(require "shape.rkt")
(require (only-in racket/base [equal? racket/equal?]))

(provide (all-defined-out))

; Broadcasting (https://github.com/onnx/onnx/blob/master/docs/Broadcasting.md)

; In ONNX, a set of tensors are multidirectional broadcastable
; to the same shape if one of the following is true:
; (1) The tensors all have exactly the same shape.
; (2) The tensors all have the same number of dimensions and
;     the length of each dimensions is either a common length or 1.
; (3) The tensors that have too few dimensions can have their shapes
;     prepended with a dimension of length 1 to satisfy property 2.

(define (multi-dir-bcast a b r)
  (and
   ; at most one of the arguments has its dimensions filled in  
   (= (rank r) (max (rank a) (rank b)))
   ; the respective dimensions obey the rules spelled out below
   (andmap multi-dir-rules (dims a) (dims b) (dims r))
   ; and the result must have no leading useless (missing dimensions)
   (> (dim r (- (rank r) 1)) 0)  
   ))

(define (multi-dir-rules a b r)
  (cond
    [(and (= 0 a)(= 0 b)(= 0 r)) #t]
    [(and (= 1 a)(= 1 b)(= 1 r)) #t]
    [(and (= 1 a)(< 1 b)(= b r)) #t]
    [(and (< 1 a)(= 1 b)(= a r)) #t]
    [(and (< 1 a)(= a b)(= b r)) #t]
    [(and (= 0 a)(< 0 b)(= b r)) #t]
    [(and (< 0 a)(= 0 b)(= a r)) #t]
    [else #f]))
  
; Reference implementation of ONNX multi-directional broadcast rules.
; These are rewritten above to use Racket's 'cond' which Rosette
; automatically translates to SMT constraints. 
; 
(define (multi-dir-rules-ref a b r)
  (match (list a b r)
    [(list 1 1 1) #t]
    [(list 0 0 0) #t]
    [(list 1 k k) (> k 0)]
    [(list k 1 k) (> k 0)]
    [(list k k k) (> k 0)]
    [(list 0 k k) (> k 0)]
    [(list k 0 k) (> k 0)]
    [_ #f]))


; In ONNX, tensor B is unidirectional broadcastable to tensor A
; if one of the following is true:
; 
; 1) Tensor A and B both have exactly the same shape.
; 2) Tensor A and B all have the same number of dimensions and
;    the length of each dimensions is either a common length or B's
;    length is 1.
; 3) Tensor B has too few dimensions, and B can have its shapes
;    prepended with a dimension of length 1 to satisfy property 2.
;
; When unidirectional broadcasting happens, the output's shape is
; the same as the shape of A (i.e., the larger shape of two input tensors).

(define (one-dir-bcast a b)
  (and
   ; B's rank is not more than A's rank
   (>= (rank a) (rank b))
   ; the respective dimensions obey the rules spelled out below
   (andmap one-dir-rules (dims a) (dims b))
   ; and the result's shape (which is A) must have no leading useless (missing dimensions)
   (> (dim a (- (rank a) 1)) 0)  
   ))

(define (one-dir-rules a b)
  (cond
    [(and (= 0 a)(= 0 b)) #t]   ; [(list 0 0) #t]         ; both A and B lack this dimension 
    [(and (= 1 a)(= 1 b)) #t]   ; [(list 1 1) #t]         ; common length in this dimension
    [(and (> a 1)(= b 1)) #t]   ; [(list k 1) (> k 1)]    ; B broadasts this dimension to A 
    [(and (> a 1)(= a b)) #t]   ; [(list k k) (> k 1)]    ; common length in this dimension 
    [(and (> a 0)(= b 0)) #t]   ; [(list k 0) (> k 0)]    ; B's dimension will be added and broiadcast to A
    [else #f]))

; reference solution, using Racket matching.

(define (one-dir-rules-ref a b)
  (match (list a b)
    [(list 0 0) #t]         ; both A and B lack this dimension 
    [(list 1 1) #t]         ; common length in this dimension
    [(list k 1) (> k 1)]    ; B broadasts this dimension to A 
    [(list k k) (> k 1)]    ; common length in this dimension 
    [(list k 0) (> k 0)]    ; B's dimension will be added and broiadcast to A
    [_ #f]))

; Test the 'cond-based rules against the reference implementation 
(define (one-dir-rules-test a b)
  (let* ([r (one-dir-rules a b)]
         [ref (one-dir-rules-ref a b)]
         [ignored (assert (racket/equal? r ref))]
         )
    r))

