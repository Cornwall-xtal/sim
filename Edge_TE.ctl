(define-param wave 19.3)				;define wavelength
(define-param xdim 2000.0)   			;define x dimension
(define-param ydim 120.0)				;define y dimension
(define-param sigmax 0.2)
(define-param NA 1.35)
;(define-param theta 0)  			;define incident angle
;(define-param kx (sin (* (/ theta 180) pi)))	;kx
;(define-param ky (cos (* (/ theta 180) pi)))	;kx
(define-param kx (/ (* sigmax NA) 4))	;kx
(define-param ky (sqrt (- 1 (* kx kx))))	;ky
(define-param freq (/ 1 wave))			;define freq, 1/lambda
(define-param rs 5)				;define resolution
(define-param pml_thick 4)			;define pml thickness


;create simulation domain
(set! geometry-lattice (make lattice (size xdim ydim no-size)))

;build geometry
(set! geometry (list
                (make block (center 0 30.0) (size infinity 60.0 infinity)
                      (material (make medium (epsilon 2.25))))

;                (make block (center 0 -3.6) (size 40 7.2 infinity)
;                      (material (make medium (epsilon 5.146)(D-conductivity (/ (* 2 pi freq 2.746) 5.146)))))

		(make block (center (/ xdim -4) -3.6) (size (/ xdim 2) 7.2 infinity)
                      (material (make medium (epsilon 5.146)(D-conductivity (/ (* 2 pi freq 2.746) 5.146)))))
)
)


;create planewave
(do ((x (- 0 (/ xdim 2)) (+ x (/ 1 rs))))((> x (/ xdim 2)))
(set! sources(append sources 
(list
               (make source
                 (src (make continuous-src (frequency freq)))
                 (component Ez)
                 (center x (- (/ ydim 2) (* pml_thick 1.1)))
		 (amplitude (exp (* pi 0+2i x freq kx ))))
		)
)))

;set perfect matching boundary
(set! pml-layers (list (make pml (direction Y) (thickness pml_thick))))

;set bloch boundary condition
(set-param! k-point (vector3 (* freq kx) (* freq ky)))

;set resolution
(set! resolution rs)

;set complex field
(set! force-complex-fields? true)

;run the simulation
(run-until 5000
           (at-beginning output-epsilon)
;           (at-end (output-png Ez "-Zc dkbluered"))
	   (at-end output-efield-z)
)

