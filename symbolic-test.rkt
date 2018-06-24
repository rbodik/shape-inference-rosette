#lang rosette

(require "operators.rkt")
(require "symbolic-shape.rkt")
(require "symbolic-checker.rkt")


(define s1 (shape 2 '(1 3)))
(define s2 (shape 2 '(2 3)))
(define s3 (shape 2 '(2 3)))

; this next check should hold (s1, s2 compose to give s3)
(assert (multi-dir-bcast s1 s2 s3))

"Multi-directional broadcasting"

(define S1 (fs))
(define P (multi-dir-bcast s1 S1 s3))
(evaluate S1 (solve (assert P)))

(define S2 (fs))
(define P2 (multi-dir-bcast s1 S1 S2))
(evaluate S2 (solve (assert P2)))

(define S3 (fs))
(define P3 (multi-dir-bcast (shape 2 '(2 2))
                            S3 ; (shape 2 '(2 1))
                            (shape 2 '(2 2))))
(evaluate S3 (solve (assert P3)))

"Add"

(define A3 (Add (shape 2 '(1 3)) (shape 2 '(4 1))))
(define A4 (Add A3 (shape 3 '(1 1 5))))
(define solution (solve A4))
(evaluate A3 solution)
(evaluate A4 solution)

"Gemm"

(define M3 (fs)) ; infers the input shape to the second Gemm
(define M1 (Gemm (shape 2 '(3 4)) (shape 2 '(4 5)) (shape 2 '(3 5))))
(define M2 (Gemm M1 M3 (shape 2 '(3 7))))
(define sol (solve M2))
(evaluate M1 sol)
(evaluate M2 sol)
(evaluate M3 sol)

"Mul + Add"

(define I1 (fs)) ; input shapes to be inferred
(define I2 (fs)) ;
(define I3 (fs)) ; 

; a program with two Gemm and one Add,
; with three known input shapes and three unknown input shapes,
; inout I2 is underconstrained (it's inferred as shape wiht zero rank)
;
(define T1 (Gemm               ; T1 stores the symbolic result shape
            (shape 2 '(3 4))   ; A
            I1                 ; B
            (shape 2 '(3 5)))) ; C
(define T2 (Add T1 I2))  ;         (shape 2 '(4 5))         
(define T3 (Gemm T2 I3 (shape 2 '(3 7))))

(define sol2 (solve T3))  ; solve

(evaluate I1 sol2)    ; print solved shapes 
(evaluate I2 sol2)    ; if no solution, printing will crash with 
(evaluate I3 sol2)
(evaluate T1 sol2)   
(evaluate T2 sol2)   
(evaluate T3 sol2)




       
       