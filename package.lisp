;;;; package.lisp
(in-package #:cl-user)

;;; ── Prolog / logic layer ─────────────────────────────────────────────────────
(defpackage #:pokemon-logic
  (:use #:cl)
  (:export
   #:make-pokemon-kb
   #:get-logic-multiplier
   #:multiplier->ratio
   #:find-counter-types
   #:team-valid-p
   #:usable-item-p
   #:apply-item-effect
   #:suggest-badge-team))

;;; ── Gen-I catalog ─────────────────────────────────────────────────────────────
(defpackage #:pokemon-catalog
  (:use #:cl)
  (:export
   #:*gen1-yellow-roster*
   #:find-pokemon
   #:species-name #:species-number #:species-type1 #:species-type2
   #:species-base-hp #:species-base-atk #:species-base-def
   #:species-base-spc #:species-base-spd #:species-learnset
   #:find-move
   #:move-name #:move-type #:move-category #:move-power
   #:move-accuracy #:move-pp #:move-effect
   #:find-item #:item-name #:item-symbol #:item-description
   #:make-battle-mon
   #:brock-party #:misty-party #:lt-surge-party #:erika-party
   #:koga-party  #:sabrina-party #:blaine-party  #:giovanni-party
   #:starter-pikachu))

;;; ── Coalton type layer ────────────────────────────────────────────────────────
;;; types.ct lives here. Only Coalton DSL code uses this package directly.
(defpackage #:pokemon-sim
  (:use #:coalton #:coalton-prelude #:coalton-library/math/integral)
  (:export
   ;; ADT types
   #:PkmnType #:Move #:Pokemon #:BattleOutcome #:Status
   ;; PkmnType constructors
   #:Normal #:Fire #:Water #:Grass #:Electric #:Ice #:Fighting #:Poison
   #:Ground #:Flying #:Psychic #:Bug #:Rock #:Ghost #:Dragon
   ;; Status constructors
   #:Healthy #:Poisoned #:Burned #:Paralyzed #:Asleep #:Frozen
   ;; BattleOutcome constructors (nullary Draw exported for CL use)
   #:Victor #:Draw #:Ongoing
   ;; Coalton functions (called via call-coalton-function from CL)
   #:type->string
   #:pokemon-name #:pokemon-hp #:pokemon-max-hp #:pokemon-type1
   #:pokemon-atk  #:pokemon-def #:pokemon-spc   #:pokemon-spd
   #:pokemon-status
   #:move-type #:move-power
   #:fainted? #:take-damage))

;;; ── CL glue layer — battle engine ───────────────────────────────────────────
;;; Uses #:cl so defmacro/let/defun are the CL versions, not Coalton's.
(defpackage #:pokemon-sim/glue
  (:use #:cl)
  (:local-nicknames
   (#:logic   #:pokemon-logic)
   (#:catalog #:pokemon-catalog)
   (#:sim     #:pokemon-sim))
  ;; Import Coalton singleton values for use as CL objects
  (:import-from #:pokemon-sim
   #:Normal #:Fire #:Water #:Grass #:Electric #:Ice #:Fighting #:Poison
   #:Ground #:Flying #:Psychic #:Bug #:Rock #:Ghost #:Dragon
   #:Healthy #:Poisoned #:Burned #:Paralyzed #:Asleep #:Frozen
   #:Draw)
  (:export
   #:match-outcome
   #:kw->coalton-type
   #:plist->pokemon
   #:catalog-move->coalton
   #:status-dot
   #:apply-end-of-turn
   #:calculate-damage
   #:run-turn
   #:simulate-battle
   #:run-simulation
   #:run-badge-battle))

;;; ── Interactive REPL ─────────────────────────────────────────────────────────
(defpackage #:pokemon-repl
  (:use #:cl)
  (:local-nicknames
   (#:logic   #:pokemon-logic)
   (#:catalog #:pokemon-catalog)
   (#:glue    #:pokemon-sim/glue))
  (:export
   #:start-battle
   #:print-battle-state
   #:player-use-move
   #:player-use-item
   #:ai-take-turn))

;;; ── Test suite ───────────────────────────────────────────────────────────────
(defpackage #:pokemon-tests
  (:use #:cl #:fiveam)
  (:local-nicknames
   (#:logic   #:pokemon-logic)
   (#:catalog #:pokemon-catalog)
   (#:glue    #:pokemon-sim/glue))
  (:export #:run-tests #:pokemon-suite))
