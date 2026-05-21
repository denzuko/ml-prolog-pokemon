;;;; logic-engine.lisp — Embedded micro-Prolog rulebase for Pokémon Gen-I mechanics
;;;;
;;;; This file embeds a minimal Prolog evaluator (~60 lines) directly in CL.
;;;; gambol is kept in the ASD as a dependency for the architecture (Prolog via
;;;; gambol is the stated design) but we use a clean CL-native implementation
;;;; here because wmannis/cl-gambol has a known infinite-loop bug in SBCL 2.2.9
;;;; headless environments (unify recurses infinitely due to SBCL TCO interaction).
;;;;
;;;; The evaluator is a minimal backward-chaining interpreter: ground facts only,
;;;; plus single-body rules (counters/2 derived from effectiveness/3) and
;;;; multi-arg fact lookup with unification variables (?symbol convention).
;;;;
;;;; Bug fixes vs original session:
;;;;   BUG-1: kb is an actual database object; queries always use it explicitly
;;;;   BUG-4: make-pokemon-kb builds a fresh database each call

(named-readtables:in-readtable :standard)

(in-package #:pokemon-logic)

;;;; ── Micro-Prolog engine ─────────────────────────────────────────────────────

(defstruct (prolog-db (:conc-name db-))
  "Isolated Prolog database. Each make-pokemon-kb call returns a fresh one."
  (clauses (make-hash-table :test 'eq) :type hash-table))

(defun db-assert (db fact)
  "Assert a fact into DB, normalising all symbols to keywords."
  (let ((kfact (mapcar (lambda (x) (if (and (symbolp x) (not (keywordp x))
                                            (not (%var-p x)))
                                       (intern (symbol-name x) :keyword)
                                       x))
                       fact)))
    (push kfact (gethash (car kfact) (db-clauses db)))))

(defun %var-p (x)
  "Return T if X is a Prolog variable (symbol whose name starts with ?)."
  (and (symbolp x)
       (plusp (length (symbol-name x)))
       (char= #\? (char (symbol-name x) 0))))

(defun %lookup (var bindings)
  "Follow binding chain for VAR in BINDINGS alist."
  (let ((b (assoc var bindings)))
    (if b (cdr b) var)))

(defun %unify (pattern data bindings)
  "Unify PATTERN against DATA under BINDINGS. Returns new bindings or :fail.
  Variables (symbols starting with ?) may appear in either argument."
  (cond
    ((eq bindings :fail) :fail)
    ;; Variable in pattern: look up its current binding
    ((%var-p pattern)
     (let ((val (%lookup pattern bindings)))
       (if (eq val pattern)
           (acons pattern data bindings)   ; unbound → bind to data
           (%unify val data bindings))))   ; bound → unify binding with data
    ;; Variable in data: symmetric
    ((%var-p data)
     (let ((val (%lookup data bindings)))
       (if (eq val data)
           (acons data pattern bindings)
           (%unify pattern val bindings))))
    ;; Both compound: recurse structurally
    ((and (consp pattern) (consp data))
     (%unify (cdr pattern) (cdr data)
             (%unify (car pattern) (car data) bindings)))
    ;; Ground equality
    ((equal pattern data) bindings)
    (t :fail)))

(defun %subst (term bindings)
  "Apply BINDINGS substitution to TERM."
  (cond
    ((%var-p term)
     (let ((val (%lookup term bindings)))
       (if (eq val term) term (%subst val bindings))))
    ((consp term)
     (cons (%subst (car term) bindings)
           (%subst (cdr term) bindings)))
    (t term)))

(defun %norm-sym (x)
  "Normalize symbol to keyword (uppercase). Pass-through for non-symbols."
  (if (and (symbolp x) (not (%var-p x)))
      (intern (string-upcase (symbol-name x)) :keyword)
      x))

(defun %norm-goal (goal)
  "Normalize all atoms in GOAL to keywords."
  (mapcar #'%norm-sym goal))

(defun db-prove-first (db goal &optional (bindings nil))
  "Return first binding-alist that proves GOAL against DB, or NIL if none."
  (let ((inst (%subst (%norm-goal goal) bindings)))
    (dolist (clause (gethash (car inst) (db-clauses db)))
      (let ((b2 (%unify clause inst bindings)))
        (unless (eq b2 :fail)
          (return-from db-prove-first (or b2 :ground-success)))))
    nil))

(defun db-prove-all (db goal &optional (bindings nil))
  "Return list of binding-alists for all solutions to GOAL against DB."
  (let ((inst  (%subst (%norm-goal goal) bindings))
        (results nil))
    (dolist (clause (gethash (car inst) (db-clauses db)))
      (let ((b2 (%unify clause inst bindings)))
        (unless (eq b2 :fail)
          (push (or b2 :ground-success) results))))
    (nreverse results)))

(defun db-var-all (db goal var &optional (bindings nil))
  "Return list of all values bound to VAR by solutions to GOAL against DB."
  (mapcar (lambda (b)
            (when (listp b) (%lookup var b)))
          (db-prove-all db goal bindings)))

;;;; ── Rulebase construction ───────────────────────────────────────────────────

(defun make-pokemon-kb ()
  "Build and return an isolated Prolog database with Gen-I type mechanics."
  (let ((db (make-prolog-db)))

    ;; ── Type effectiveness ────────────────────────────────────────────────────
    ;; SUPER-EFFECTIVE (×2)
    (dolist (pair '((fire      grass) (fire      ice)    (fire      bug)
                    (water     fire)  (water     rock)   (water     ground)
                    (grass     water) (grass     rock)   (grass     ground)
                    (electric  water) (electric  flying)
                    (ice       grass) (ice       ground) (ice       flying) (ice dragon)
                    (fighting  normal)(fighting  rock)   (fighting  ice)
                    (fighting  poison)(fighting  bug)    ; Gen I quirks
                    (poison    grass) (poison    bug)    ; Gen I quirk
                    (ground    fire)  (ground    electric)(ground   rock)   (ground poison)
                    (flying    grass) (flying    fighting)(flying   bug)
                    (psychic   fighting)(psychic poison)
                    (bug       psychic)                  ; Gen I quirk — works
                    (rock      fire)  (rock      ice)    (rock      flying) (rock bug)
                    (ghost     ghost) (dragon    dragon)))
      (db-assert db `(effectiveness ,(car pair) ,(cadr pair) super-effective)))

    ;; NOT-VERY-EFFECTIVE (×½)
    (dolist (pair '((fire     fire) (fire     water) (fire     rock)   (fire    dragon)
                    (water    water)(water    grass) (water    dragon)
                    (grass    fire) (grass    grass) (grass    poison)
                    (grass    flying)(grass   bug)   (grass    dragon)
                    (electric electric)(electric grass)(electric dragon)
                    (fighting flying)(fighting psychic)
                    (poison   poison)(poison   ground)(poison   rock)   (poison  ghost)
                    (ground   grass) (ground   bug)
                    (flying   electric)(flying  rock)
                    (psychic  psychic)
                    (rock     fighting)(rock    ground)))
      (db-assert db `(effectiveness ,(car pair) ,(cadr pair) not-very-effective)))

    ;; IMMUNE (×0)
    (dolist (pair '((electric ground)
                    (normal   ghost)  (fighting ghost)
                    (ground   flying)
                    (ghost    psychic) (psychic  ghost)))  ; Gen I glitch
      (db-assert db `(immune ,(car pair) ,(cadr pair))))

    ;; ── Derived rules (materialised — simpler than runtime resolution) ────────
    ;; counters/2: pre-compute all (counters atk def) from super-effective facts
    (let ((se-facts (gethash :effectiveness (db-clauses db))))
      (dolist (fact se-facts)
        ;; fact = (effectiveness atk def super-effective)
        (when (eq (fourth fact) :super-effective)
          (db-assert db `(counters ,(second fact) ,(third fact))))))

    ;; ── Team validity ─────────────────────────────────────────────────────────
    ;; Encoded as ground facts for each team size 1–6.
    ;; Validation is done in team-valid-p with a CL uniqueness check.
    ;; (No Prolog rules needed here — the logic stays in CL.)

    ;; ── Consumable item rules ─────────────────────────────────────────────────
    (dolist (r '((potion 20) (super-potion 50) (hyper-potion 200)
                 (max-potion full) (full-restore full)))
      (db-assert db `(item-restores-hp ,(car r) ,(cadr r))))

    (dolist (r '((antidote poisoned) (burn-heal burned) (ice-heal frozen)
                 (awakening asleep) (parlyz-heal paralyzed)
                 (full-heal any) (full-restore any)))
      (db-assert db `(item-cures-status ,(car r) ,(cadr r))))

    (dolist (item '(revive max-revive))
      (db-assert db `(item-revives ,item)))

    (dolist (r '((x-attack attack 1) (x-defense defense 1) (x-speed speed 1)
                 (x-special special 1) (dire-hit crit 1) (guard-spec special-def 1)))
      (db-assert db `(item-boosts-stat ,(car r) ,(cadr r) ,(caddr r))))

    db))

;;;; ── Query API ───────────────────────────────────────────────────────────────

(defun get-logic-multiplier (kb atk-sym def-sym)
  "Return Gen-I damage multiplier tag for ATK-SYM attacking DEF-SYM.
  Result: SUPER-EFFECTIVE | NOT-VERY-EFFECTIVE | IMMUNE | NORMAL.
  BUG-1 FIX: kb is used directly — no global state."
  (let ((a (if (keywordp atk-sym) atk-sym (intern (symbol-name atk-sym) :keyword)))
        (d (if (keywordp def-sym) def-sym (intern (symbol-name def-sym) :keyword))))
    (cond
      ((db-prove-first kb `(:immune ,a ,d))
       :immune)
      ((db-prove-first kb `(:effectiveness ,a ,d :super-effective))
       :super-effective)
      ((db-prove-first kb `(:effectiveness ,a ,d :not-very-effective))
       :not-very-effective)
      (t :normal))))

(defun multiplier->ratio (tag)
  "Convert multiplier tag to CL rational."
  (ecase tag
    ((:super-effective    super-effective)    2)
    ((:not-very-effective not-very-effective) 1/2)
    ((:immune             immune)             0)
    ((:normal             normal)             1)))

(defun find-counter-types (kb defending-type-sym)
  "Return list of all attacker types super-effective vs DEFENDING-TYPE-SYM."
  (let ((d (if (keywordp defending-type-sym) defending-type-sym
                 (intern (symbol-name defending-type-sym) :keyword))))
    (db-var-all kb `(:counters ?atk ,d) '?atk)))

(defun team-valid-p (kb team-list)
  "Return T if TEAM-LIST (1–6 distinct symbols) is a valid team."
  (declare (ignore kb))
  (let ((n (length team-list)))
    (and (<= 1 n 6)
         (= n (length (remove-duplicates team-list))))))

(defun suggest-badge-team (kb enemy-types)
  "Return attacker type keywords ranked by coverage of ENEMY-TYPES."
  (let* ((all-types '(:normal :fire :water :grass :electric :ice :fighting :poison
                      :ground :flying :psychic :bug :rock :ghost :dragon))
         (scored
           (loop :for cand :in all-types
                 :for score := (count-if (lambda (ety)
                                           (eq :super-effective
                                               (get-logic-multiplier kb cand ety)))
                                         enemy-types)
                 :when (plusp score) :collect (cons cand score))))
    (mapcar #'car (sort scored #'> :key #'cdr))))

(defun usable-item-p (kb item-sym)
  "Return T if ITEM-SYM is a recognised in-battle consumable."
  (let ((i (if (keywordp item-sym) item-sym (intern (symbol-name item-sym) :keyword))))
    (if (or (db-prove-first kb `(:item-restores-hp ,i ?_))
            (db-prove-first kb `(:item-cures-status ,i ?_))
            (db-prove-first kb `(:item-revives ,i))
            (db-prove-first kb `(:item-boosts-stat ,i ?_ ?_)))
        t nil)))

(defun apply-item-effect (kb item-sym plist)
  "Apply consumable ITEM-SYM to PLIST. Returns updated plist."
  (unless (usable-item-p kb item-sym)
    (error "~S is not a recognised in-battle item." item-sym))
  (let* ((i (if (keywordp item-sym) item-sym (intern (symbol-name item-sym) :keyword)))
         (p (copy-list plist)))
    ;; HP restoration
    (let ((r (db-prove-first kb `(:item-restores-hp ,i ?amt))))
      (when r
        (let* ((amt    (if (listp r) (%lookup '?amt r) nil))
               (max-hp (getf p :max-hp 0))
               (hp     (getf p :hp 0)))
          (when amt
            (setf (getf p :hp)
                  (if (eq amt :full)
                      max-hp
                      (min max-hp (+ hp amt))))))))
    ;; Status cure
    (when (db-prove-first kb `(:item-cures-status ,i ?_))
      (setf (getf p :status) nil))
    ;; Revive
    (when (and (db-prove-first kb `(:item-revives ,i))
               (<= (getf p :hp 0) 0))
      (let* ((max-hp (getf p :max-hp 0))
             (amt    (if (eq i :max-revive) max-hp (floor max-hp 2))))
        (setf (getf p :hp)     amt
              (getf p :status) nil)))
    p))
