(define-param wave 1.93)				;define wavelength
(define-param freq (/ 1 wave))			;define freq, 1/lambda
(define-param xdim 10.0)   			;define x dimension
(define-param ydim 10.0)				;define y dimension
(define-param zdim 12.0)				;define z dimension
(define-param NA 1.35)
(define-param eps_sub 1)
(define-param sigmax 0.1)
(define-param sigmay 0.1)
(define-param kx (/ (* sigmax NA) 4))
(define-param ky (/ (* sigmay NA) 4))
(define-param k_p2 (+ (* kx kx) (* ky ky)))
(define-param kz (sqrt (- eps_sub k_p2 ) ) )
(define-param ex_TE (/ (- ky) (sqrt k_p2))) 
(define-param ey_TE (/ kx (sqrt k_p2))) 
(define-param ez_TE 0) 
(define-param ex_TM (/ (* (/ kz (sqrt eps_sub)) kx) (sqrt k_p2))) 
(define-param ey_TM (/ (* (/ kz (sqrt eps_sub)) ky) (sqrt k_p2))) 
(define-param ez_TM (- (sqrt (/ k_p2 eps_sub)))) 
(define (pw r) (exp (* pi 0+2i freq (+ (* kx (vector3-x r)) (* ky (vector3-y r))))))
(define-param rs 15)				;define resolution
(define-param pml_thick 0.8)			;define pml thickness
(define-param w 1.8)

;create simulation domain
(set! geometry-lattice (make lattice (size xdim ydim zdim)))

;build geometry
(set! geometry 
      (list
                (make block (center 0 0 3.0) (size infinity infinity 6.0)
                      (material (make medium (epsilon eps_sub) ) )
                )

;                (make block (center 0 0 -3.6) (size infinity infinity 7.2)
;                      (material (make medium (epsilon 5.146)(D-conductivity (/ (* 2 pi freq 2.746) 5.146)) ) )
;                )

;                (make block (center 0 0 -3.6) (size w infinity 7.2)
;                      (material (make medium (epsilon 1) ) )
;                )

      )
)


;create planewave
(set! sources (list
               (make source
                   (src (make continuous-src (frequency freq)))
                   (component Ex)
                   (center 0 0 (- (/ zdim 2) (* pml_thick 1.1)))
                   (size xdim ydim 0)
		           (amplitude ex_TE)
                   (amp-func pw)
               )
               (make source
                   (src (make continuous-src (frequency freq)))
                   (component Ey)
                   (center 0 0 (- (/ zdim 2) (* pml_thick 1.1)))
                   (size xdim ydim 0)
		           (amplitude ey_TE)
                   (amp-func pw)
               ) 
               ;(make source
               ;    (src (make continuous-src (frequency freq)))
               ;    (component Ez)
               ;    (center 0 0 (- (/ zdim 2) (* pml_thick 1.1)))
               ;    (size xdim ydim 0)
		       ;    (amplitude ez_TE)
               ;    (amp-func pw)
               ;) 
              )
)

;set perfect matching boundary
(set! pml-layers (list (make pml (direction Z) (thickness pml_thick))))

;set bloch boundary condition
(set-param! k-point (vector3 (* freq kx) (* freq ky) 0))

;set resolution
(set! resolution rs)

;set complex field
(set! force-complex-fields? true)

;run the simulation
(run-until 5000
           (at-beginning output-epsilon)
;           (at-end (output-png Ez "-Zc dkbluered"))
	   (at-end output-efield-x)
	   (at-end output-efield-y)
	   (at-end output-efield-z)
)

