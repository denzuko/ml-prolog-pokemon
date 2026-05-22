;;;; perf.lisp — Performance regression suite for pokemon-sim
;;;;
;;;; System: pokemon-sim/perf
;;;; Run:
;;;;   (asdf:load-system "pokemon-sim/perf")
;;;;   (pokemon-sim/perf:run-perf)
;;;;
;;;; Each test asserts that the MEDIAN wall-clock time across N iterations
;;;; stays under a generous budget (10-100× typical, to catch catastrophic
;;;; regressions without GC jitter false-positives).
;;;;
;;;; Budgets are conservative enough that a Raspberry Pi 4 running ECL
;;;; (C-compiled, not bytecode) passes them for the pure-CL layer.

(named-readtables:in-readtable :standard)

(in-package #:pokemon-sim/perf)

;;;; ── Minimal timer ───────────────────────────────────────────────────────────

(defun %collect-times (n thunk)
  "Run THUNK N times, return sorted vector of elapsed microseconds."
  (let ((results (make-array n :element-type 'double-float)))
    (dotimes (i n)
      (let ((start (get-internal-real-time)))
        (funcall thunk)
        (setf (aref results i)
              (* 1d6 (/ (- (get-internal-real-time) start)
                        (float internal-time-units-per-second 1d0))))))
    (sort results #'<)))

(defun %median (sorted-vec)
  (let ((n (length sorted-vec)))
    (if (zerop n) 0d0
        (if (oddp n)
            (aref sorted-vec (floor n 2))
            (* 0.5d0 (+ (aref sorted-vec (1- (floor n 2)))
                        (aref sorted-vec (floor n 2))))))))

(defun %p95 (sorted-vec)
  (if (zerop (length sorted-vec)) 0d0
      (aref sorted-vec (min (1- (length sorted-vec))
                            (floor (* 0.95 (length sorted-vec)))))))

(defmacro with-budget ((n budget-us label &key (warm-up 5)) &body body)
  "Run BODY N+WARM-UP times. Emit a FiveAM check that median ≤ BUDGET-US us."
  (let ((thunk (gensym "THUNK"))
        (times (gensym "TIMES"))
        (med   (gensym "MED"))
        (p95   (gensym "P95")))
    `(let ((,thunk (lambda () ,@body)))
       ;; warm-up: let SBCL compile + GC settle
       (dotimes (_ ,warm-up) (funcall ,thunk))
       (let* ((,times (%collect-times ,n ,thunk))
              (,med   (%median ,times))
              (,p95   (%p95    ,times)))
         (format t "  ~40A  median ~8,1Fus  p95 ~8,1Fus~%"
                 ,label ,med ,p95)
         (fiveam:is (<= ,med ,budget-us)
                    "~A: median ~,1fus exceeds budget ~Aus"
                    ,label ,med ,budget-us)))))

;;;; ── Suite ───────────────────────────────────────────────────────────────────

(fiveam:def-suite perf-suite
  :description "Performance regression — median wall-clock budgets (us)")
(fiveam:in-suite perf-suite)

;;;; ── Shared fixtures ─────────────────────────────────────────────────────────

(defvar *kb*   nil)
(defvar *c-pl* nil)
(defvar *b-pl* nil)

(defun ensure-fixtures ()
  (unless *kb*
    (setf *kb*   (logic:make-pokemon-kb)
          *c-pl* (cat:make-battle-mon *kb* "Charizard" 36
                   "Flamethrower" "Fire Blast" "Slash" "Hyper Beam")
          *b-pl* (cat:make-battle-mon *kb* "Blastoise" 36
                   "Surf" "Hydro Pump" "Withdraw" "Body Slam"))))

;;;; ── Knowledge layer ─────────────────────────────────────────────────────────

(fiveam:test perf/make-pokemon-kb
  "make-pokemon-kb (assert ~800 Prolog facts) ≤ 50 ms."
  (with-budget (20 50000 "make-pokemon-kb" :warm-up 2)
    (logic:make-pokemon-kb)))

(fiveam:test perf/get-logic-multiplier
  "get-logic-multiplier (4 calls) ≤ 500 us."
  (ensure-fixtures)
  (with-budget (2000 500 "get-logic-multiplier ×4" :warm-up 10)
    (logic:get-logic-multiplier *kb* :fire     :grass)
    (logic:get-logic-multiplier *kb* :water    :fire)
    (logic:get-logic-multiplier *kb* :electric :ground)
    (logic:get-logic-multiplier *kb* :normal   :normal)))

(fiveam:test perf/suggest-badge-team
  "suggest-badge-team (3 calls) ≤ 10 ms."
  (ensure-fixtures)
  (with-budget (500 10000 "suggest-badge-team ×3" :warm-up 5)
    (logic:suggest-badge-team *kb* '(:rock :ground))
    (logic:suggest-badge-team *kb* '(:fire))
    (logic:suggest-badge-team *kb* '(:water :psychic :normal))))

;;;; ── Catalog layer ───────────────────────────────────────────────────────────

(fiveam:test perf/find-pokemon
  "find-pokemon (3 lookups) ≤ 500 us."
  (ensure-fixtures)
  (with-budget (2000 500 "find-pokemon ×3" :warm-up 10)
    (cat:find-pokemon *kb* "Pikachu")
    (cat:find-pokemon *kb* "Mewtwo")
    (cat:find-pokemon *kb* "Gengar")))

(fiveam:test perf/find-move
  "find-move (3 lookups) ≤ 500 us."
  (ensure-fixtures)
  (with-budget (2000 500 "find-move ×3" :warm-up 10)
    (cat:find-move *kb* "Thunderbolt")
    (cat:find-move *kb* "Surf")
    (cat:find-move *kb* "Earthquake")))

(fiveam:test perf/make-battle-mon
  "make-battle-mon (4 moves) ≤ 2 ms."
  (ensure-fixtures)
  (with-budget (1000 2000 "make-battle-mon" :warm-up 10)
    (cat:make-battle-mon *kb* "Charizard" 50
      "Flamethrower" "Fire Blast" "Slash" "Hyper Beam")))

(fiveam:test perf/gary-party
  "gary-party (6 mons) ≤ 10 ms."
  (ensure-fixtures)
  (with-budget (200 10000 "gary-party (6 mons)" :warm-up 5)
    (cat:gary-party *kb*)))

;;;; ── Coalton battle layer ────────────────────────────────────────────────────

(fiveam:test perf/calculate-damage
  "calculate-damage (2 calls) ≤ 500 us."
  (ensure-fixtures)
  (let* ((p1 (glue:plist->pokemon *c-pl*))
         (p2 (glue:plist->pokemon *b-pl*))
         (m1 (glue:catalog-move->coalton (cat:find-move *kb* "Flamethrower")))
         (m2 (glue:catalog-move->coalton (cat:find-move *kb* "Surf"))))
    (with-budget (5000 500 "calculate-damage ×2" :warm-up 20)
      (sim:calculate-damage *kb* m1 p1 p2)
      (sim:calculate-damage *kb* m2 p2 p1))))

(fiveam:test perf/run-turn
  "run-turn (1 simultaneous turn) ≤ 1 ms."
  (ensure-fixtures)
  (let* ((p1 (glue:plist->pokemon *c-pl*))
         (p2 (glue:plist->pokemon *b-pl*))
         (m1 (glue:catalog-move->coalton (cat:find-move *kb* "Flamethrower")))
         (m2 (glue:catalog-move->coalton (cat:find-move *kb* "Surf"))))
    (with-budget (5000 1000 "run-turn" :warm-up 20)
      (sim:run-turn *kb* p1 m1 p2 m2))))

(fiveam:test perf/simulate-battle
  "simulate-battle (20-turn cap) ≤ 50 ms."
  (ensure-fixtures)
  (let* ((p1 (glue:plist->pokemon *c-pl*))
         (p2 (glue:plist->pokemon *b-pl*))
         (m1 (glue:catalog-move->coalton (cat:find-move *kb* "Flamethrower")))
         (m2 (glue:catalog-move->coalton (cat:find-move *kb* "Surf"))))
    (with-budget (1000 50000 "simulate-battle (20 turns)" :warm-up 10)
      (sim:simulate-battle *kb* p1 m1 p2 m2 20))))

;;;; ── Throughput (informational) ──────────────────────────────────────────────

(fiveam:test perf/throughput
  "Informational: battles per second. Minimum 10/sec on any platform."
  (ensure-fixtures)
  (let* ((p1  (glue:plist->pokemon *c-pl*))
         (p2  (glue:plist->pokemon *b-pl*))
         (m1  (glue:catalog-move->coalton (cat:find-move *kb* "Flamethrower")))
         (m2  (glue:catalog-move->coalton (cat:find-move *kb* "Surf")))
         (n   500))
    ;; warm-up
    (dotimes (_ 10) (sim:simulate-battle *kb* p1 m1 p2 m2 20))
    (let* ((times (%collect-times n
                    (lambda () (sim:simulate-battle *kb* p1 m1 p2 m2 20))))
           (total-us (reduce #'+ times))
           (bps (if (plusp total-us)
                    (round (* n 1d6) total-us) 0)))
      (format t "  ~40A  ~:D battles/sec~%" "throughput" bps)
      (fiveam:is (>= bps 10)
                 "Throughput ~D battles/sec below minimum 10" bps))))

;;;; ── Entry point ──────────────────────────────────────────────────────────────

(defun run-perf ()
  "Run the performance regression suite. Returns FiveAM result list."
  (format t "~%~A~%SBCL ~A~%~V,,,'-<~>~%~%"
          "pokemon-sim/perf" (lisp-implementation-version) 50 "")
  (format t "  ~40A  ~7A  ~7A~%~V,,,'-<~>~%"
          "operation" "median" "p95" 50 "")
  (let ((results (fiveam:run 'perf-suite)))
    (format t "~V,,,'-<~>~%" 50 "")
    (fiveam:explain! results)
    results))
