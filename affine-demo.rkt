#lang rosette

(require "affine-solver.rkt")

; Affine demo
;
; See other examples in symbolic-affine-test.rkt

; Some fixed (ie, not to be solved) affine shapes

(define a (sh (list (+ n m)   (+ 1 k) ))) 
(define b (sh (list (+ 1 k)   (+ n k) ))) 
(define c (sh (list (+ n m)   (+ n k) ))) 
(define d (sh (list (+ n m)           )))
(define e (sh (list (+ n k)   m       ))) 
(define f (sh (list 1         m       ))) 


; Here is how you create input shapes to be inferred
; 
; When inferred, these will be shapes where each dimension is an affine bound
; over parameters n, m, k.  These bounds are defined in symbolic-shape.rkt.
;
; Here we create two, for input a and input b

(define ua (fresh-shape))   ; ua -- unknown a
(define ub (fresh-shape))  

; this symbol table stores symbolic shapes for later printing
(define symbol-table (make-hash))


; A program P with two Gemms and one Add.  It has six input shapes a to f.
; Note that onnx Gemm seems to require that a and b are exactly 2D, so this is
; what we encode in onnx/gemm.
;
;    def P(a, b, c, d, e, f) =
;       val T1 = GEMM(a, b, c)
;       val T2 = ADD(T1, d)
;       GEMM(T2, e, f)

(define (P a b c d e f) 
  (let* ([t1 (Gemm a b c)]      ; t1, t2, t3 store the symbolic result shape
         [t2 (Add  t1 d)]
         [t3 (Gemm t2 e f)]
         ) 

    ; this recording of symbolic shapes should be software-engineered better 
    (hash-set*! symbol-table
                "t1" t1    "a" a   "b" b   "c" c 
                "t2" t2    "d" d 
                "e"  e     "f" f  "t3" t3
                ))
    )

; Infer the output shape t3 and the intermediate shapes t1, t2.
; Also feel free to make any input shapes unknown and observe the result. 
;
; Parameters to inference are the program P2 and a list of shapes that are its inputs

(define solution (infer-shapes P (list  ; replace any inputs with unknown/fresh shapes
                                  a 
                                  (fresh-shape) ; b
                                  c; (fresh-shape) ; c
                                  (fresh-shape) ; d
                                  (fresh-shape) ; e
                                  f
                                  )))

; Print the solved shapes. If no solution was found, then sol == unsat and
; printing will crash with ... (unsat) ...

(print-shapes symbol-table solution)

; Notes: 
;
; 1) Deending on what inputs you make unknown (aka, fresh, symbolic)
;    the system may be underconstrained, allowing various solutions.
;    As an example, the system is underconstrained when b,c,e are unknown.
; 2) Currently, we don't infer the smallest shape.  It could be done if we believe
;    that input programs should be allowed to be underconstrained.
; 3) It may be interesting to determine whether the system is underconstrained,
;    whether it allows multiple solutions. 
