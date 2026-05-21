;;;; simulator.lisp — CL bridge and entry points
;;;;
;;;; This file is now intentionally thin. All battle computation lives in
;;;; types.ct (Coalton). This file handles only:
;;;;   1. plist→Coalton value bridges (catalog data → battle ADTs)
;;;;   2. Entry points that call into Coalton and format output

(named-readtables:in-readtable :standard)

(in-package #:pokemon-sim/glue)

;;;; ── keyword → Coalton PkmnType ──────────────────────────────────────────────

(cl:defun kw->coalton-type (kw)
  "Map :fire → Fire etc. Nullary Coalton constructors are plain CL singletons."
  (cl:ecase kw
    (:normal   Normal)    (:fire     Fire)    (:water    Water)
    (:grass    Grass)     (:electric Electric) (:ice     Ice)
    (:fighting Fighting)  (:poison   Poison)  (:ground   Ground)
    (:flying   Flying)    (:psychic  Psychic)  (:bug     Bug)
    (:rock     Rock)      (:ghost    Ghost)   (:dragon   Dragon)))

;;;; ── catalog plist → Coalton Pokemon ────────────────────────────────────────

(cl:defun plist->pokemon (plist)
  "Convert a make-battle-mon plist to a Coalton Pokemon value."
  (sim::make-pokemon
    (cl:getf plist :name "???")
    (kw->coalton-type (cl:getf plist :type1 :normal))
    (cl:getf plist :max-hp 1)
    (cl:getf plist :hp (cl:getf plist :max-hp 1))
    (cl:getf plist :atk 1)
    (cl:getf plist :def 1)
    (cl:getf plist :spc 1)
    (cl:getf plist :spd 1)))

;;;; ── catalog move plist → Coalton Move ──────────────────────────────────────

(cl:defun catalog-move->coalton (move-plist)
  "Convert a catalog move plist to a Coalton Move value."
  (sim::make-move
    (catalog:move-name  move-plist)
    (kw->coalton-type (catalog:move-type move-plist))
    (catalog:move-power move-plist)))

;;;; ── BattleOutcome dispatch ──────────────────────────────────────────────────
;;;; Coalton ADT variants compile to CL classes; dispatch with typecase.

(cl:defmacro match-outcome (outcome &key
                                         (victor  nil victor-p)
                                         (draw    nil)
                                         (ongoing nil ongoing-p)
                                         (winner  (cl:gensym "WINNER"))
                                         (next-p1 (cl:gensym "NP1"))
                                         (next-p2 (cl:gensym "NP2")))
  "Dispatch on a BattleOutcome value.
  :VICTOR  body — WINNER is bound to winning Pokemon (rebindable via :winner var-name)
  :DRAW    body — no extra bindings
  :ONGOING body — NEXT-P1 and NEXT-P2 bound (rebindable via :next-p1/:next-p2)
  Use the :winner/:next-p1/:next-p2 keyword args to control the bound variable names
  when calling from a different package, e.g. :winner 'my-pkg::w"
  (cl:declare (cl:ignore victor-p ongoing-p))
  (cl:let ((v (cl:gensym "OUTCOME")))
    `(cl:let ((,v ,outcome))
       (cl:typecase ,v
         (sim::battleoutcome/victor
          (cl:let ((,winner (cl:slot-value ,v 'sim::|_0|)))
            (cl:declare (cl:ignorable ,winner))
            ,victor))
         (sim::battleoutcome/draw ,draw)
         (sim::battleoutcome/ongoing
          (cl:let ((,next-p1 (cl:slot-value ,v 'sim::|_0|))
                   (,next-p2 (cl:slot-value ,v 'sim::|_1|)))
            (cl:declare (cl:ignorable ,next-p1 ,next-p2))
            ,ongoing))
         (cl:t (cl:error "Unknown BattleOutcome: ~S" ,v))))))

;;;; ── Entry points ────────────────────────────────────────────────────────────

(cl:defun run-simulation ()
  "Smoke test: Charizard (Flamethrower) vs Blastoise (Surf) at level 36."
  (cl:let* ((kb   (logic:make-pokemon-kb))
             (c-pl (catalog:make-battle-mon kb "Charizard" 36
                     "Flamethrower" "Fire Blast" "Slash" "Hyper Beam"))
             (b-pl (catalog:make-battle-mon kb "Blastoise" 36
                     "Surf" "Hydro Pump" "Withdraw" "Body Slam"))
             (p1   (plist->pokemon c-pl))
             (p2   (plist->pokemon b-pl))
             (m1   (catalog-move->coalton (catalog:find-move kb "Flamethrower")))
             (m2   (catalog-move->coalton (catalog:find-move kb "Surf")))
             ;; simulate-battle is now fully in Coalton
             (res  (sim::simulate-battle kb p1 m1 p2 m2 20)))
    (cl:format cl:t "~%=== Smoke test: ~A vs ~A ===~%"
               (cl:getf c-pl :name) (cl:getf b-pl :name))
    (match-outcome res
      :winner w
      :victor  (cl:format cl:t "  Winner: ~A  HP: ~A/~A~%"
                           (sim::pokemon-name   w)
                           (sim::pokemon-hp     w)
                           (sim::pokemon-max-hp w))
      :draw    (cl:format cl:t "  Draw!~%")
      :ongoing (cl:format cl:t "  (time limit)~%"))
    res))

(cl:defun run-badge-battle (gym-name)
  "Print Prolog type advice for a battle.
  gym-name: any keyword matching a gym-party fact:
    :brock :misty :lt-surge :erika :koga :sabrina :blaine :giovanni
    :lorelei :bruno :agatha :lance :gary
    :gary-route22-early :gary-ss-anne :gary-silph"
  (cl:let* ((kb     (logic:make-pokemon-kb))
             (party  (catalog:gym-party kb gym-name))
             (etypes (cl:mapcar
                       (cl:lambda (p)
                         (cl:intern (cl:string-upcase
                                      (cl:symbol-name (cl:getf p :type1)))
                                    "KEYWORD"))
                       party))
             (advice (logic:suggest-badge-team kb etypes)))
    (cl:format cl:t "~%╔══════════════════════════════════════════╗~%")
    (cl:format cl:t "║  ~A~%" (cl:string-upcase (cl:symbol-name gym-name)))
    (cl:format cl:t "╠══════════════════════════════════════════╣~%")
    (cl:format cl:t "║  Party: ~{~A~^, ~}~%"
               (cl:mapcar (cl:lambda (p) (cl:getf p :name)) party))
    (cl:format cl:t "║  Counter advice: ~{~A~^, ~}~%" advice)
    (cl:format cl:t "╚══════════════════════════════════════════╝~%")
    (cl:values kb party advice)))
