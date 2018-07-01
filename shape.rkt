#lang rosette

(require racket/struct)
(require racket/list)
(require "bound.rkt")

(provide (struct-out shape) (rename-out [shape-constructor sh]) rank dim dims)

(struct shape (rank dims) #:transparent
  #:property prop:custom-write
  (lambda (shape port write?)
    (if (term? (shape-rank shape))
        ; the rank is a symbolic variable
        (fprintf port (if write? "~s:[~s]" "~a:[~a]")
                 (rank shape)
                 (shape-dims shape))
        ; rank is concrete
        (fprintf port (if write? "[~s]" "[~a]")
                 (take (shape-dims shape) (shape-rank shape)))
        )))

(define (shape-constructor lst) (shape (length lst) lst))

; access the rank of shape 's'
(define (rank s)
  (shape-rank s))

; access the length of dimension 'd' in shape 's'; return 0 if missing dim
(define (dim s d)
  (if (>= d (rank s))
      0
      (list-ref (shape-dims s) d)))

; return exactly MAX-RANK dimensions of s, filling in zeros for missing dimensions 
(define (dims s)
  (for/list ([i MAX-RANK])
    (dim s i)))

; give the list of first k dimensions, filling with zero at
; the end if the shape has fewer dimensions.  Zero means 'empty dimension
(define (dims-fill s k)
  (take (append (shape-dims s) (make-list k 0)) k))