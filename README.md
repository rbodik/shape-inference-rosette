# shape-inference-rosette
Shape inference for free with Rosette

Shape inference for ONNX, with one-directional and multi-directional boradcasting.

We implement a checker that assumes a program whose nodes are fully annotated with shapes of inputs and outputs.  We then turn this shape checker into a shape inferencer using Rosette.  Specifically, we can leave some shapes unknown (i.e., symbolic) and Rosette solves these shapes.  The solving involves translating the checker + unknown shapoes into SMT constraints that are passed to Z3. 

Example ONNX program encoded in our "IR".  The program has 2 Gemm operations and 1 Add operation.  It has three known input shapes and three unknown input shapes. The input I2 is underconstrained; it's inferred as shape wiht zero rank, but other solutions are valid. This program is at the end of symbolic-test.rkt.

```
(define T1 (Gemm               ; T1 stores the symbolic result shape
            (shape 2 '(3 4))   ; A
            I1                 ; B
            (shape 2 '(3 5)))) ; C
(define T2 (Add T1 I2))  ;         (shape 2 '(4 5))         
(define T3 (Gemm T2 I3 (shape 2 '(3 7))))
```

The solutions for I1, I2, I3, T1, T2, T3 are:
```
(shape 4 5)
(shape)
(shape 5 7)
(shape 3 5)
(shape 3 5)
(shape 3 7)
```
What works:
* one-directional broadcast
* multi-directional broadcast
* Gemm, as an example of an operator with one-directional broadcast
* Add, as an example of an operator with multi-directional broadcast
* composition of these operators
* unknown input, intermediate, and output shapes. 
* (update) affine shapes now work, see affine-demo.rkt.

What is missing from ONNX:
* other operators (should be trivial to add)
* transpose flags in Gemm (also should be trivial)

What may be useful to add, but it's not clear ONNX itself demands it:
* add tiling operators and others that produce new shapes. 

The semantics of broadcast is defined in checker.rkt.  For example, this is all we need to say about multi-directional brodcast rules.  The inference happens for free.  The broadcast semantics should be easy to modify to other languages. 
```
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
```
Finally, here are the shape rules for Gemm. The rules mimic the OINNX spec copied below.  
Note that the rules invoke the one-directional brodcasting checker. Again, the code below is a concrete checker that is turned into an inferencer for free.  Before it was turned into an inferencer, this checker was debugged using plain testing; you can see how it is tested on concrete values in test.rkt.
```
; General Matrix multiplication: https://en.wikipedia.org/wiki/Basic_Linear_Algebra_Subprograms#Level_3
;
; A' = transpose(A) if transA else A
; 
; B' = transpose(B) if transB else B
; 
; Compute Y = alpha * A' * B' + beta * C, where
; input tensor A has shape (M, K) or (K, M),
; input tensor B has shape (K, N) or (N, K),
; input tensor C is broadcastable to shape (M, N),
; and output tensor Y has shape (M, N).
; A will be transposed before doing the computation if
; attribute transA is non-zero, same for B and transB.
; 
; This operator supports unidirectional broadcasting
; (tensor C should be unidirectional broadcastable to tensor A * B);
; for more details please check the doc on broadcasting

; shape x shape x shape x shape -> Unit (adds an assert)
(define (onnx/gemm a b c y) ; TODO add transpose flags
    (let ([M (dim a 0)]
          [K (dim a 1)]
          [BK (dim b 0)]
          [N  (dim b 1)]
          [YM (dim y 0)]
          [YN (dim y 1)])
      (assert
       (and (= K BK)            ; A and B match in K dimension 
            (= YM M)(= YN N)    ; the result has the right shape
            (one-dir-bcast y c) ; C is one-dir brodcastable to result
            (= (rank a) 2)
            (= (rank b) 2)
            (= (rank y) 2)
            ))))
```

