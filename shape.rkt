#lang rosette

(require racket/struct)
(require racket/list)
(require "bound.rkt")

(provide (struct-out shape) rank dim dims dims-fill)

(struct shape (rank dims) #:transparent
  #:methods gen:custom-write
    [(define write-proc
       (make-constructor-style-printer
        (lambda (obj) 'shape)
        (lambda (obj) (if (term? (rank obj))
                          (shape-dims obj)
                          (take (shape-dims obj) (rank obj))))))])

; access the rank of shape 's'
(define (rank s)
  (shape-rank s))

; access the length of dimension 'd' in shape 's'; return 0 if missing dim
(define (dim s d)
  (if (>= d (rank s))
      0
      (list-ref (shape-dims s) d)))

(define (dims s)
  (for/list ([i MAX-RANK])
    (dim s i)))

; give the list of first k dimensions, filling with zero at
; the end if the shape has fewer dimensions.  Zero means 'empty dimension
(define (dims-fill s k)
  (take (append (shape-dims s) (make-list k 0)) k))