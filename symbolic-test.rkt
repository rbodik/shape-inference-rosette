#lang rosette

(require "constant-solver.rkt")

"Multi-directional broadcasting: concrete"

(define s1 (sh '(1 3)))
(define s2 (sh '(2 3)))
(define s3 (sh '(2 3)))

s1
s2
s3

; this next check should hold (s1, s2 compose to give s3)
(multi-dir-bcast s1 s2 s3)

"Multi-directional broadcasting: symbolic"

(define S1 (fresh-shape))

S1 ; print the unsolved symbolic shape

(define P (multi-dir-bcast s1 S1 s3))
(evaluate S1 (solve (assert P)))

(define S2 (fresh-shape))
(define P2 (multi-dir-bcast s1 S1 S2))
(evaluate S2 (solve (assert P2)))

(define S3 (fresh-shape))
(define P3 (multi-dir-bcast (sh '(2 2))
                            S3 ; (sh '(2 1))
                            (sh '(2 2))))
(evaluate S3 (solve (assert P3)))

"Add"

(define A3 (Add (sh '(1 3)) (sh '(4 1))))
(define A4 (Add A3 (sh '(1 1 5))))
A3
A4
(define solution (solve A4))
(evaluate A3 solution)
(evaluate A4 solution)

"Gemm"

(define M3 (fresh-shape)) ; infers the input shape to the second Gemm
(define M1 (Gemm (sh '(3 4)) (sh '(4 5)) (sh '(3 5))))
(define M2 (Gemm M1 M3 (sh '(3 7))))
(define sol (solve M2))
(evaluate M1 sol)
(evaluate M2 sol)
(evaluate M3 sol)

"Mul + Add"

(define I1 (fresh-shape)) ; input shapes to be inferred
(define I2 (fresh-shape)) ;
(define I3 (fresh-shape)) ; 

; a program with two Gemm and one Add,
; with three known input shapes and three unknown input shapes,
; inout I2 is underconstrained (it's inferred as shape wiht zero rank)
;
(define T1 (Gemm          ; T1 stores the symbolic result shape
            (sh '(3 4))   ; A
            I1            ; B
            (sh '(3 5)))) ; C
(define T2 (Add T1 I2))  ;         (sh '(4 5))         
(define T3 (Gemm T2 I3 (sh '(3 7))))

(define sol2 (solve T3))  ; solve

(evaluate I1 sol2)    ; print solved shapes 
(evaluate I2 sol2)    ; if no solution, printing will crash with 
(evaluate I3 sol2)
(evaluate T1 sol2)   
(evaluate T2 sol2)   
(evaluate T3 sol2)




       
       