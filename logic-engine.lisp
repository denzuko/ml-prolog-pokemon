(in-package #:pokemon-logic)

(defun make-pokemon-kb ()
  "Instantiates an isolated cl-gambol rulebase with Pokémon mechanics."
  (let ((rb (g:make-rulebase)))
    (g:with-rulebase rb
      ;; --- TYPE EFFECTIVENESS GRAPH ---
      (g:*- (effectiveness fire grass super-effective))
      (g:*- (effectiveness grass water super-effective))
      (g:*- (effectiveness water fire super-effective))
      (g:*- (effectiveness fire water not-very-effective))
      (g:*- (effectiveness water grass not-very-effective))
      (g:*- (effectiveness grass fire not-very-effective))
      
      (g:*- (counters ?a ?b) (effectiveness ?a ?b super-effective))

      ;; --- TEAM CONSTRUCTION RULES ---
      ;; Instead of full list recursion which cl-gambol's engine struggles to unify,
      ;; we define team sizes explicitly using positional arguments.
      (g:*- (valid-team ?p1) 
            (g:lop t))
      (g:*- (valid-team ?p1 ?p2) 
            (g:lop (not (eq ?p1 ?p2))))
      (g:*- (valid-team ?p1 ?p2 ?p3) 
            (g:lop (and (not (eq ?p1 ?p2))
                        (not (eq ?p2 ?p3))
                        (not (eq ?p1 ?p3)))))))
    rb))

(defun get-logic-multiplier (kb atk-sym def-sym)
  "Queries the rulebase for explicit damage multipliers."
  (g:with-rulebase kb
    ;; cl-gambol uses pl-solve-all to evaluate terms dynamically
    (cond
      ((g:pl-solve-all `((effectiveness ,atk-sym ,def-sym super-effective))) 2/1)
      ((g:pl-solve-all `((effectiveness ,atk-sym ,def-sym not-very-effective))) 1/2)
      (t 1/1))))

(defun find-counter-types (kb defending-type-sym)
  "Returns a list of all types that are super-effective against the target."
  (let ((solutions nil))
    (g:with-rulebase kb
      (g:do-solve-all (?counter) `((counters ?counter ,defending-type-sym))
        (push ?counter solutions)))
    solutions))

(defun team-valid-p (kb team-list)
  "Returns true if the list of species strings passes legal-lineup constraints."
  (g:with-rulebase kb
    (let ((len (length team-list)))
      (cond
        ((= len 1) 
         (if (g:pl-solve-all `((valid-team ,(first team-list)))) t nil))
        ((= len 2) 
         (if (g:pl-solve-all `((valid-team ,(first team-list) ,(second team-list)))) t nil))
        ((= len 3) 
         (if (g:pl-solve-all `((valid-team ,(first team-list) ,(second team-list) ,(third team-list)))) t nil))
        (t nil)))))
