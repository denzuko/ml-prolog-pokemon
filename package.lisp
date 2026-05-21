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
   #:suggest-badge-team
   ;; db internals exposed for catalog
   #:db-assert #:db-prove-first #:db-prove-all #:db-var-all
   #:%var-p #:%lookup #:%unify #:%subst #:%norm-goal #:db-clauses))

;;; ── Gen-I catalog — Prolog facts + thin CL query API ────────────────────────
(defpackage #:pokemon-catalog
  (:use #:cl)
  (:local-nicknames (#:logic #:pokemon-logic))
  (:export
   #:assert-catalog-facts
   ;; species
   #:find-pokemon #:species-type1 #:all-pokemon
   ;; moves
   #:find-move #:move-name #:move-type #:move-category #:move-power
   ;; items
   #:find-item
   ;; battle-mon builder
   #:make-battle-mon
   ;; gym parties (all take kb as first arg)
   #:gym-party
   #:brock-party #:misty-party #:lt-surge-party #:erika-party
   #:koga-party   #:sabrina-party #:blaine-party  #:giovanni-party
   #:starter-pikachu))

;;; ── Coalton type layer ───────────────────────────────────────────────────────
(defpackage #:pokemon-sim
  (:use #:coalton #:coalton-prelude #:coalton-library/math/integral)
  (:export
   #:PkmnType #:Move #:Pokemon #:BattleOutcome #:Status
   #:Normal #:Fire #:Water #:Grass #:Electric #:Ice #:Fighting #:Poison
   #:Ground #:Flying #:Psychic #:Bug #:Rock #:Ghost #:Dragon
   #:Healthy #:Poisoned #:Burned #:Paralyzed #:Asleep #:Frozen
   #:Victor #:Draw #:Ongoing
   #:type->string
   #:pokemon-name #:pokemon-hp #:pokemon-max-hp #:pokemon-type1
   #:pokemon-atk  #:pokemon-def #:pokemon-spc   #:pokemon-spd
   #:pokemon-status #:move-type #:move-power
   #:fainted? #:take-damage
   #:make-pokemon #:make-move #:make-victor #:make-ongoing))

;;; ── CL glue layer ────────────────────────────────────────────────────────────
(defpackage #:pokemon-sim/glue
  (:use #:cl)
  (:local-nicknames
   (#:logic   #:pokemon-logic)
   (#:catalog #:pokemon-catalog)
   (#:sim     #:pokemon-sim))
  (:import-from #:pokemon-sim
   #:Normal #:Fire #:Water #:Grass #:Electric #:Ice #:Fighting #:Poison
   #:Ground #:Flying #:Psychic #:Bug #:Rock #:Ghost #:Dragon
   #:Healthy #:Poisoned #:Burned #:Paralyzed #:Asleep #:Frozen #:Draw)
  (:export
   #:match-outcome
   #:kw->coalton-type
   #:plist->pokemon
   #:catalog-move->coalton
   #:status-dot #:apply-end-of-turn
   #:calculate-damage #:run-turn #:simulate-battle
   #:run-simulation #:run-badge-battle))

;;; ── Test suite ───────────────────────────────────────────────────────────────
(defpackage #:pokemon-tests
  (:use #:cl #:fiveam)
  (:local-nicknames
   (#:logic   #:pokemon-logic)
   (#:catalog #:pokemon-catalog))
  (:export #:run-tests #:pokemon-suite))
