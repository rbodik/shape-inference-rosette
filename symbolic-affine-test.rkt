#lang rosette

(require "affine-solver.rkt")

; some concrete shapes
(define s1 (sh (list 1 3)))
(define s2 (sh (list 4 1)))
(define s3 (sh (list 4 3)))

; some concrete affine shapes (concrete == not to-be-solved)
(define a1 (sh (list 1       n)))
(define a2 (sh (list m       1)))
(define a3 (sh (list m       n)))
(define a4 (sh (list (+ m n) n)))
(define a5 (sh (list 1       1       m)))
(define a6 (sh (list (* 2 m) (* 3 n) 4)))
(define a7 (sh (list (* 2 m) 1)))
(define a8 (sh (list 1       1       5)))

; some symbolic affine shapes over n, m, k (defined in affine-solver.rkt)
(define A1 (fresh-shape))
(define A2 (fresh-shape))
(define A3 (fresh-shape))
(define A4 (fresh-shape))
(define A5 (fresh-shape))
(define A6 (fresh-shape))

"one-dir-bcast"

(require "checker.rkt")
(require rosette/lib/synthax)

; Infer A1 such that a1 broadcasts to A1 and A1 broadcasts to a3
; A1 -> (sh 2 '(1 n))
(evaluate A1 (synthesize
              #:forall (list n m)
              #:assume (assert (and (> m 0) (> n 0)))   ; bounds for m, n.  We can easily make m,n zero, too, but currently 0 stands for empty dimension.
              #:guarantee (assert (and (one-dir-bcast a3 A1) (one-dir-bcast A1 a1)))))


; Infer A2 s.t. a4 and a5 can both broadcast into A2
; A2 -> (sh 3 '((+ n m) n m))
; (there are many legal results)
(evaluate A2 (synthesize
              #:forall (list n m)
              #:assume (assert (and (> m 0) (> n 0) (< n 128) (< m 128)))  ; need upper bound for m, n when using theory of bitvectors
              #:guarantee (assert (and (one-dir-bcast A2 a4) (one-dir-bcast A2 a5)))))

"(multi-dir-bcast a1 a2 A1)"

; infer the result of multi-dir-bcast of a4, a5
; A3 -> (sh 3 '((+ n m) n m))
(evaluate A3 (synthesize
              #:forall (list n m)
              #:assume (assert (and (> m 0) (> n 0) (< n 128) (< m 128)))
              #:guarantee (assert (multi-dir-bcast a4 a5 A3))))

; find shape that composes with a7 to get a6
; A4 -> (sh 3 '(0 (* 3 n) 4))
;; TODO: fix bug (0 is an illegal dim size).
(evaluate A4 (synthesize
              #:forall (list n m)
              #:assume (assert (and (> m 0) (> n 0)(< n 128) (< m 128)))
              #:guarantee (assert (multi-dir-bcast A4 a7 a6))))


"Add"
(define ht (make-hash))
(define-symbolic result integer?)

(define (P) 
  (let* ([T1 (Add a1 A5)]
         [T2 (Add T1 a8)])
    (hash-set*! ht "T1" T1 "T2" T2)
    T2))

(define sol (synthesize
             #:forall (list n m)
             #:assume (assert (and (> m 0) (> n 0)))
             #:guarantee (P)))

  
(evaluate A5 sol)
(evaluate (hash-ref ht "T1") sol)
(evaluate (hash-ref ht "T2") sol)



"Mul + Add"

; see example of a larger program in affine-demo.rkt






       
       

