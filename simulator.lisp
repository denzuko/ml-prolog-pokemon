;;;; simulator.lisp — CL battle engine (package: pokemon-sim/glue)
;;;;
;;;; Uses :cl, not :coalton — defmacro/let/defun are all CL.
;;;; Calls into types.ct via direct Coalton function calls.
;;;; Prolog queries go through pokemon-logic.
;;;; cl-arrows:-> threads multi-step pipelines.

(named-readtables:in-readtable :standard)

(in-package #:pokemon-sim/glue)

;;;; ─── ADT dispatch macro ─────────────────────────────────────────────────────
;;;; BattleOutcome variants compile to CL classes:
;;;;   BattleOutcome/Victor  — slot |_0| = winning Pokemon
;;;;   BattleOutcome/Draw    — no payload
;;;;   BattleOutcome/Ongoing — slot |_0| = p1, |_1| = p2

(cl:defmacro match-outcome (outcome &key victor draw ongoing)
  "Dispatch on a BattleOutcome value.
  VICTOR  — body with WINNER bound to the winning Pokemon
  DRAW    — body with no bindings
  ONGOING — body with NEXT-P1 and NEXT-P2 bound to surviving Pokemon"
  (cl:let ((v (cl:gensym "OUTCOME")))
    `(cl:let ((,v ,outcome))
       (cl:typecase ,v
         (sim::battleoutcome/victor
          (cl:let ((winner (cl:slot-value ,v 'sim::|_0|)))
            (cl:declare (cl:ignorable winner))
            ,victor))
         (sim::battleoutcome/draw
          ,draw)
         (sim::battleoutcome/ongoing
          (cl:let ((next-p1 (cl:slot-value ,v 'sim::|_0|))
                   (next-p2 (cl:slot-value ,v 'sim::|_1|)))
            (cl:declare (cl:ignorable next-p1 next-p2))
            ,ongoing))
         (cl:t (cl:error "Unknown BattleOutcome: ~S" ,v))))))

;;;; ─── Type keyword → Coalton PkmnType ───────────────────────────────────────

(cl:defun kw->coalton-type (kw)
  "Map :fire → Fire etc. Coalton nullary constructors are plain CL singletons."
  (cl:ecase kw
    (:normal   Normal)    (:fire     Fire)    (:water    Water)
    (:grass    Grass)     (:electric Electric) (:ice     Ice)
    (:fighting Fighting)  (:poison   Poison)  (:ground   Ground)
    (:flying   Flying)    (:psychic  Psychic)  (:bug     Bug)
    (:rock     Rock)      (:ghost    Ghost)   (:dragon   Dragon)))

;;;; ─── Coalton PkmnType → POKEMON-LOGIC symbol ───────────────────────────────

(cl:defun coalton-type->logic-sym (ct-val)
  (cl:intern
     (sim::type->string ct-val)
     "KEYWORD"))

;;;; ─── catalog plist → Coalton Pokemon ──────────────────────────────────────

(cl:defun plist->pokemon (plist)
  "Convert a make-battle-mon plist to a Coalton Pokemon value."
  (cl:let ((nm  (cl:getf plist :name "???"))
           (t1  (kw->coalton-type (cl:getf plist :type1 :normal)))
           (mhp (cl:getf plist :max-hp 1))
           (hp  (cl:getf plist :hp (cl:getf plist :max-hp 1)))
           (atk (cl:getf plist :atk 1))
           (def (cl:getf plist :def 1))
           (spc (cl:getf plist :spc 1))
           (spd (cl:getf plist :spd 1)))
    (sim::make-pokemon nm t1 mhp hp atk def spc spd)))

;;;; ─── catalog pkmn-move → Coalton Move ─────────────────────────────────────

(cl:defun catalog-move->coalton (move-struct)
  "Convert a catalog pkmn-move struct to a Coalton Move value."
  (sim::make-move
    (catalog:move-name  move-struct)
    (kw->coalton-type (catalog:move-type move-struct))
    (catalog:move-power move-struct)))

;;;; ─── Status DoT ─────────────────────────────────────────────────────────────

(cl:defun status-dot (pkmn-val)
  "Return HP to subtract for end-of-turn status damage (0 if none)."
  (cl:let* ((status (sim::pokemon-status pkmn-val))
             (hp     (sim::pokemon-hp     pkmn-val)))
    (cl:cond
      ((cl:typep status 'sim::status/poisoned) (cl:max 1 (cl:floor hp 8)))
      ((cl:typep status 'sim::status/burned)   (cl:max 1 (cl:floor hp 16)))
      (cl:t 0))))

(cl:defun apply-end-of-turn (pkmn-val)
  "Apply DoT; return updated Pokemon (unchanged if no status)."
  (cl:let ((dot (status-dot pkmn-val)))
    (cl:if (cl:zerop dot)
        pkmn-val
        (sim::take-damage pkmn-val dot))))

;;;; ─── Damage calculation ─────────────────────────────────────────────────────

(cl:defun damage-multiplier (kb move-val defender-val)
  "Prolog lookup: multiplier tag for move-type vs defender type1. BUG-1 FIX."
  (logic:get-logic-multiplier
    kb
    (coalton-type->logic-sym (sim::move-type move-val))
    (coalton-type->logic-sym (sim::pokemon-type1 defender-val))))

(cl:defun calculate-damage (kb move-val attacker-val defender-val)
  "Return (values damage-amount multiplier-tag).
  Gen I: base = floor(atk*power / (50*def)) + 2, then × multiplier."
  (cl:let* ((power (sim::move-power  move-val))
             (atk   (sim::pokemon-atk attacker-val))
             (def   (cl:max 1 (sim::pokemon-def defender-val)))
             (tag   (damage-multiplier kb move-val defender-val))
             (mult  (logic:multiplier->ratio tag))
             (base  (cl:+ (cl:floor (cl:* atk power) (cl:* 50 def)) 2)))
    (cl:values (cl:max 0 (cl:floor (cl:* base mult))) tag)))

;;;; ─── Turn / battle resolution ──────────────────────────────────────────────

(cl:defun run-turn (kb p1 m1 p2 m2)
  "Resolve one simultaneous turn. Returns a BattleOutcome."
  (cl:multiple-value-bind (d2 _t2) (calculate-damage kb m1 p1 p2)
    (cl:declare (cl:ignore _t2))
    (cl:multiple-value-bind (d1 _t1) (calculate-damage kb m2 p2 p1)
      (cl:declare (cl:ignore _t1))
      ;; BUG-3 FIX: p1*/p2* are fresh bindings, no shadowing
      (cl:let* ((p1* (apply-end-of-turn
                         (sim::take-damage p1 d1)))
                (p2* (apply-end-of-turn
                         (sim::take-damage p2 d2)))
                (p1f (sim::fainted? p1*))
                (p2f (sim::fainted? p2*)))
        (cl:cond
          ((cl:and p1f p2f) sim::Draw)
          (p2f              (sim::make-victor p1*))
          (p1f              (sim::make-victor p2*))
          (cl:t             (sim::make-ongoing p1* p2*)))))))

(cl:defun simulate-battle (kb p1 m1 p2 m2 &optional (max-turns 30))
  "Simulate up to MAX-TURNS turns. Returns a BattleOutcome."
  (cl:loop :repeat max-turns :do
    (cl:let ((outcome (run-turn kb p1 m1 p2 m2)))
      (match-outcome outcome
        :victor  (cl:return-from simulate-battle outcome)
        :draw    (cl:return-from simulate-battle outcome)
        :ongoing (cl:setf p1 next-p1 p2 next-p2)))
  :finally
    (cl:let ((hp1 (sim::pokemon-hp p1))
             (hp2 (sim::pokemon-hp p2)))
      (cl:return
        (cl:cond ((cl:> hp1 hp2) (sim::make-victor p1))
                 ((cl:> hp2 hp1) (sim::make-victor p2))
                 (cl:t sim::Draw))))))

;;;; ─── Entry points ───────────────────────────────────────────────────────────

(cl:defun run-simulation ()
  "Smoke test: Charizard (Flamethrower) vs Blastoise (Surf) at level 36."
  (cl:let* ((kb   (logic:make-pokemon-kb))
             (c-pl (catalog:make-battle-mon "Charizard" 36
                     "Flamethrower" "Fire Blast" "Slash" "Hyper Beam"))
             (b-pl (catalog:make-battle-mon "Blastoise" 36
                     "Surf" "Hydro Pump" "Withdraw" "Body Slam"))
             (p1   (plist->pokemon c-pl))
             (p2   (plist->pokemon b-pl))
             (m1   (catalog-move->coalton (catalog:find-move "Flamethrower")))
             (m2   (catalog-move->coalton (catalog:find-move "Surf")))
             (res  (simulate-battle kb p1 m1 p2 m2 20)))
    (cl:format cl:t "~%=== Smoke test: ~A vs ~A ===~%"
               (cl:getf c-pl :name) (cl:getf b-pl :name))
    (match-outcome res
      :victor  (cl:format cl:t "  Winner: ~A  HP: ~A/~A~%"
                           (sim::pokemon-name   winner)
                           (sim::pokemon-hp     winner)
                           (sim::pokemon-max-hp winner))
      :draw    (cl:format cl:t "  Draw!~%")
      :ongoing (cl:format cl:t "  (time limit)~%"))
    res))

(cl:defun run-badge-battle (gym-name)
  "Print Prolog type advice for a badge battle.
  GYM-NAME: :brock :misty :lt-surge :erika :koga :sabrina :blaine :giovanni"
  (cl:let* ((kb    (logic:make-pokemon-kb))
             (party (cl:ecase gym-name
                      (:brock    (catalog:brock-party))
                      (:misty    (catalog:misty-party))
                      (:lt-surge (catalog:lt-surge-party))
                      (:erika    (catalog:erika-party))
                      (:koga     (catalog:koga-party))
                      (:sabrina  (catalog:sabrina-party))
                      (:blaine   (catalog:blaine-party))
                      (:giovanni (catalog:giovanni-party))))
             (etypes (cl:mapcar
                       (cl:lambda (p)
                         (cl:intern
                           (cl:string-upcase
                             (cl:symbol-name (cl:getf p :type1)))
                           "KEYWORD"))
                       party))
             (advice (logic:suggest-badge-team kb etypes)))
    (cl:format cl:t "~%╔══════════════════════════════════════════╗~%")
    (cl:format cl:t "║  ~A GYM~%" (cl:string-upcase (cl:symbol-name gym-name)))
    (cl:format cl:t "╠══════════════════════════════════════════╣~%")
    (cl:format cl:t "║  Party: ~{~A~^, ~}~%"
               (cl:mapcar (cl:lambda (p) (cl:getf p :name)) party))
    (cl:format cl:t "║  Counter advice: ~{~A~^, ~}~%" advice)
    (cl:format cl:t "╚══════════════════════════════════════════╝~%")
    (cl:values kb party advice)))
