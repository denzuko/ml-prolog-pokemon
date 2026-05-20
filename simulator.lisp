(in-package #:pokemon-sim)

(named-readtables:in-readtable coalton:coalton)

(coalton-toplevel
  ;; Core Type Definitions
  (define-type PkmnType Fire Water Grass)

  (define-type Move
    (Move String PkmnType U32))

  (define-type Pokemon
    (Pokemon String PkmnType U32 U32)) ; Name, Type, Max HP, Current HP

  ;; Variant type to track battle turn states cleanly
  (define-type BattleOutcome
    (Victor Pokemon)
    (Draw))

  ;; Map Coalton types down to pure Lisp symbols at runtime via interning
  (declare type->symbol (PkmnType -> Lisp-Object))
  (define (type->symbol t)
    (match t
      ((Fire)  (cl:lisp Lisp-Object () (cl:intern "FIRE" "POKEMON-LOGIC")))
      ((Water) (cl:lisp Lisp-Object () (cl:intern "WATER" "POKEMON-LOGIC")))
      ((Grass) (cl:lisp Lisp-Object () (cl:intern "GRASS" "POKEMON-LOGIC")))))

  ;; Core damage calculation integrating the Lisp/Prolog rulebase multiplier
  (declare calculate-damage (Lisp-Object -> Move -> Pokemon -> U32))
  (define (calculate-damage kb (Move _ move-type power) (Pokemon _ def-type _ _))
    (let atk-sym = (type->symbol move-type))
    (let def-sym = (type->symbol def-type))
    (let mult = (cl:lisp Fraction (kb atk-sym def-sym)
                  (pokemon-logic:get-logic-multiplier atk-sym def-sym)))
    (let raw-damage = (floor (* (into power) mult)))
    (into raw-damage))

  ;; Pure automated turn simulation tracking state modifications
  (declare run-turn (Lisp-Object -> Pokemon -> Move -> Pokemon -> Move -> BattleOutcome))
  (define (run-turn kb p1 m1 p2 m2)
    (let dmg-to-p2 = (calculate-damage kb m1 p2))
    (let dmg-to-p1 = (calculate-damage kb m2 p1))
    
    (match (Tuple p1 p2)
      ((Tuple (Pokemon n1 t1 m1 curr-hp1) (Pokemon n2 t2 m2 curr-hp2))
       (let new-hp1 = (if (> dmg-to-p1 curr-hp1) 0 (- curr-hp1 dmg-to-p1)))
       (let new-hp2 = (if (> dmg-to-p2 curr-hp2) 0 (- curr-hp2 dmg-to-p2)))
       
       (cond
         ((and (== new-hp1 0) (== new-hp2 0)) (Draw))
         ((== new-hp2 0) (Victor (Pokemon n1 t1 m1 new-hp1)))
         ((== new-hp1 0) (Victor (Pokemon n2 t2 m2 new-hp2)))
         (t (if (> new-hp1 new-hp2) 
                (Victor (Pokemon n1 t1 m1 new-hp1))
                (Victor (Pokemon n2 t2 m2 new-hp2))))))))

  ;; Interop bridge pulling structural lists back out from the Prolog solver
  (declare suggest-counter-squad (Lisp-Object -> (List PkmnType) -> (List Lisp-Object)))
  (define (suggest-counter-squad kb enemy-types)
    (let lisp-types = (cl:mapcar (cl:lambda (x) (type->symbol x)) 
                                 (into-list enemy-types)))
    (cl:lisp (List Lisp-Object) (kb lisp-types)
      (cl:into (pokemon-logic:find-optimal-counters kb lisp-types)))))

;; Restore standard environment readtable immediately after the definitions block
(named-readtables:in-readtable :standard)

;; Harness function to execute the simulation passes
(defun run-simulation ()
  (let* ((kb (pokemon-logic:make-pokemon-kb))
         ;; 1. TEST THE PROLOG TEAM RECOMMENDATION LOGIC
         (enemy-lineup (coalton (make-list Fire Grass Water)))
         (recommended-types (coalton (suggest-counter-squad kb enemy-lineup))))
    
    (format t "--- AI TEAM ADVISOR ---~%")
    (format t "Opponent Lineup Types: (FIRE GRASS WATER)~%")
    (format t "Prolog Recommended Counter Composition: ~A~%~%" recommended-types)

    ;; 2. TEST ACTIVE COMBAT SIMULATION LOOP
    (format t "--- SIMULATING ACTIVE MATCHUP ---~%")
    (let* ((charizard (coalton (Pokemon "Charizard" Fire 314 314)))
           (flame-m   (coalton (Move "Flamethrower" Fire 90)))
           (blastoise (coalton (Pokemon "Blastoise" Water 362 362)))
           (hydro-m   (coalton (Move "Hydro Pump" Water 110)))
           
           (outcome   (coalton (run-turn kb charizard flame-m blastoise hydro-m))))
      
      (match outcome
        ((coalton:Victor pkmn) 
         (format t "Match Outcome: Winner is ~A!~%" pkmn))
        ((coalton:Draw) 
         (format t "Match Outcome: Mutual Knockout!~%")))
      (values))))
