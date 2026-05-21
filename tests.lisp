;;;; tests.lisp — FiveAM test suite
;;;; Run: (pokemon-tests:run-tests)

(named-readtables:in-readtable :standard)

(in-package #:pokemon-tests)

(fiveam:def-suite pokemon-suite
  :description "Pokémon Gen-I simulator — full system tests")
(fiveam:in-suite pokemon-suite)

;;;; ─── Shared fixture ─────────────────────────────────────────────────────────

(defvar *kb* nil)
(defun kb ()
  (or *kb* (setf *kb* (logic:make-pokemon-kb))))

;;;; ─── Logic engine: rulebase ─────────────────────────────────────────────────

(fiveam:test kb-non-nil
  "make-pokemon-kb returns a non-nil rulebase."
  (fiveam:is (not (null (kb)))))

;;;; ─── Logic engine: type effectiveness ──────────────────────────────────────

(fiveam:test fire-vs-grass-super
  (fiveam:is (eq :super-effective
                 (logic:get-logic-multiplier (kb) :fire :grass))))

(fiveam:test water-vs-fire-super
  (fiveam:is (eq :super-effective
                 (logic:get-logic-multiplier (kb) :water :fire))))

(fiveam:test electric-vs-flying-super
  (fiveam:is (eq :super-effective
                 (logic:get-logic-multiplier (kb) :electric :flying))))

(fiveam:test fire-vs-water-nve
  (fiveam:is (eq :not-very-effective
                 (logic:get-logic-multiplier (kb) :fire :water))))

(fiveam:test electric-vs-ground-immune
  (fiveam:is (eq :immune
                 (logic:get-logic-multiplier (kb) :electric :ground))))

(fiveam:test normal-vs-ghost-immune
  (fiveam:is (eq :immune
                 (logic:get-logic-multiplier (kb) :normal :ghost))))

(fiveam:test normal-vs-normal-normal
  (fiveam:is (eq :normal
                 (logic:get-logic-multiplier (kb) :normal :normal))))

;; Gen I quirks
(fiveam:test bug-vs-psychic-super-gen1
  "Bug is super-effective vs Psychic in Gen I."
  (fiveam:is (eq :super-effective
                 (logic:get-logic-multiplier (kb) :bug :psychic))))

;;;; ─── Logic engine: multiplier->ratio ───────────────────────────────────────

(fiveam:test ratio-super    (fiveam:is (= 2   (logic:multiplier->ratio :super-effective))))
(fiveam:test ratio-nve      (fiveam:is (= 1/2 (logic:multiplier->ratio :not-very-effective))))
(fiveam:test ratio-immune   (fiveam:is (= 0   (logic:multiplier->ratio :immune))))
(fiveam:test ratio-normal   (fiveam:is (= 1   (logic:multiplier->ratio :normal))))

;;;; ─── Logic engine: counter types ──────────────────────────────────────────

(fiveam:test counters-water-includes-grass
  (fiveam:is (member :grass
                     (logic:find-counter-types (kb) :water))))

(fiveam:test counters-fire-includes-water-rock-ground
  (let ((c (logic:find-counter-types (kb) :fire)))
    (fiveam:is (member :water  c))
    (fiveam:is (member :rock   c))
    (fiveam:is (member :ground c))))

;;;; ─── Logic engine: team validity ──────────────────────────────────────────

(fiveam:test team-valid-single
  (fiveam:is (logic:team-valid-p (kb) '(bulbasaur))))

(fiveam:test team-valid-two-distinct
  (fiveam:is (logic:team-valid-p (kb) '(bulbasaur charmander))))

(fiveam:test team-invalid-duplicate-two
  (fiveam:is (not (logic:team-valid-p (kb) '(bulbasaur bulbasaur)))))

(fiveam:test team-valid-six
  (fiveam:is (logic:team-valid-p (kb)
                '(pikachu bulbasaur charmander squirtle eevee jigglypuff))))

(fiveam:test team-invalid-six-dup
  (fiveam:is (not (logic:team-valid-p (kb)
                    '(pikachu bulbasaur charmander squirtle eevee pikachu)))))

;;;; ─── Logic engine: items ───────────────────────────────────────────────────

(fiveam:test potion-usable
  (fiveam:is (logic:usable-item-p (kb) 'potion)))

(fiveam:test revive-usable
  (fiveam:is (logic:usable-item-p (kb) 'revive)))

(fiveam:test unknown-not-usable
  (fiveam:is (not (logic:usable-item-p (kb) 'magic-potion))))

(fiveam:test potion-restores-20
  (let* ((mon (list :name "Pika" :hp 30 :max-hp 100 :status nil))
         (r   (logic:apply-item-effect (kb) 'potion mon)))
    (fiveam:is (= 50 (getf r :hp)))))

(fiveam:test potion-capped-at-max
  (let* ((mon (list :name "Pika" :hp 95 :max-hp 100 :status nil))
         (r   (logic:apply-item-effect (kb) 'potion mon)))
    (fiveam:is (= 100 (getf r :hp)))))

(fiveam:test super-potion-restores-50
  (let* ((mon (list :name "Pika" :hp 10 :max-hp 100 :status nil))
         (r   (logic:apply-item-effect (kb) 'super-potion mon)))
    (fiveam:is (= 60 (getf r :hp)))))

(fiveam:test max-potion-full-restore
  (let* ((mon (list :name "Pika" :hp 1 :max-hp 100 :status nil))
         (r   (logic:apply-item-effect (kb) 'max-potion mon)))
    (fiveam:is (= 100 (getf r :hp)))))

(fiveam:test full-restore-clears-status
  (let* ((mon (list :name "Pika" :hp 50 :max-hp 100 :status :poisoned))
         (r   (logic:apply-item-effect (kb) 'full-restore mon)))
    (fiveam:is (null (getf r :status)))
    (fiveam:is (= 100 (getf r :hp)))))

(fiveam:test antidote-clears-poison
  (let* ((mon (list :name "Pika" :hp 50 :max-hp 100 :status :poisoned))
         (r   (logic:apply-item-effect (kb) 'antidote mon)))
    (fiveam:is (null (getf r :status)))))

(fiveam:test revive-half-hp
  (let* ((mon (list :name "Pika" :hp 0 :max-hp 100 :status nil))
         (r   (logic:apply-item-effect (kb) 'revive mon)))
    (fiveam:is (= 50 (getf r :hp)))))

(fiveam:test max-revive-full-hp
  (let* ((mon (list :name "Pika" :hp 0 :max-hp 100 :status nil))
         (r   (logic:apply-item-effect (kb) 'max-revive mon)))
    (fiveam:is (= 100 (getf r :hp)))))

;;;; ─── Logic engine: badge advisor ──────────────────────────────────────────

(fiveam:test suggest-vs-brock-includes-water-grass
  (let ((advice (logic:suggest-badge-team (kb) '(:rock :ground))))
    (fiveam:is (member :water advice))
    (fiveam:is (member :grass advice))))

(fiveam:test suggest-vs-misty-includes-grass-electric
  (let ((advice (logic:suggest-badge-team (kb) '(:water))))
    (fiveam:is (member :grass    advice))
    (fiveam:is (member :electric advice))))

(fiveam:test suggest-vs-blaine-includes-water-rock-ground
  (let ((advice (logic:suggest-badge-team (kb) '(:fire))))
    (fiveam:is (member :water  advice))
    (fiveam:is (member :rock   advice))
    (fiveam:is (member :ground advice))))

(fiveam:test suggest-returns-list
  (fiveam:is (listp (logic:suggest-badge-team (kb) '(:normal)))))

;;;; ─── Catalog: species ───────────────────────────────────────────────────────

(fiveam:test pikachu-exists
  (fiveam:is (not (null (catalog:find-pokemon (kb) "Pikachu")))))

(fiveam:test pikachu-electric
  (fiveam:is (eq :electric (catalog:species-type1 (catalog:find-pokemon (kb) "Pikachu")))))

(fiveam:test mewtwo-exists
  (fiveam:is (not (null (catalog:find-pokemon (kb) "Mewtwo")))))

(fiveam:test exactly-151-pokemon
  (fiveam:is (= 151 (length (catalog:all-pokemon (kb))))))

;;;; ─── Catalog: moves ─────────────────────────────────────────────────────────

(fiveam:test thunderbolt-exists-and-correct
  (let ((m (catalog:find-move (kb) "Thunderbolt")))
    (fiveam:is (not (null m)))
    (fiveam:is (eq  :electric (catalog:move-type m)))
    (fiveam:is (=   95 (catalog:move-power m)))))

(fiveam:test surf-exists
  (fiveam:is (not (null (catalog:find-move (kb) "Surf")))))

;;;; ─── Catalog: items ─────────────────────────────────────────────────────────

(fiveam:test potion-in-catalog
  (fiveam:is (not (null (catalog:find-item (kb) "Potion")))))

;;;; ─── Catalog: make-battle-mon ──────────────────────────────────────────────

(fiveam:test make-battle-mon-pikachu
  (let ((p (catalog:make-battle-mon (kb) "Pikachu" 5 "Thunder Shock" "Growl")))
    (fiveam:is (string= "Pikachu" (getf p :name)))
    (fiveam:is (> (getf p :hp) 0))
    (fiveam:is (= 2 (length (getf p :moves))))))

;;;; ─── Catalog: gym parties ───────────────────────────────────────────────────

(fiveam:test brock-party-2
  (fiveam:is (= 2 (length (catalog:brock-party (kb))))))

(fiveam:test misty-party-2
  (fiveam:is (= 2 (length (catalog:misty-party (kb))))))

(fiveam:test lt-surge-has-raichu
  (let ((p (catalog:lt-surge-party (kb))))
    (fiveam:is (= 1 (length p)))
    (fiveam:is (string= "Raichu" (getf (first p) :name)))))

(fiveam:test erika-party-3
  (fiveam:is (= 3 (length (catalog:erika-party (kb))))))

(fiveam:test giovanni-party-5
  (fiveam:is (= 5 (length (catalog:giovanni-party (kb))))))

(fiveam:test lorelei-party-5
  (fiveam:is (= 5 (length (catalog:lorelei-party (kb))))))

(fiveam:test lance-party-5
  (fiveam:is (= 5 (length (catalog:lance-party (kb))))))

(fiveam:test gary-party-6
  "Champion Gary has 6 Pokémon."
  (fiveam:is (= 6 (length (catalog:gary-party (kb))))))

(fiveam:test gary-party-ends-blastoise
  "Gary's ace is Blastoise (Squirtle start variant)."
  (let ((p (catalog:gary-party (kb))))
    (fiveam:is (string= "Blastoise"
                        (getf (car (last p)) :name)))))

(fiveam:test simulate-battle-blastoise-beats-charizard
  "Water beats Fire — Blastoise should win the smoke test."
  (let* ((kb   (kb))
         (c-pl (catalog:make-battle-mon kb "Charizard" 36
                 "Flamethrower" "Fire Blast" "Slash" "Hyper Beam"))
         (b-pl (catalog:make-battle-mon kb "Blastoise" 36
                 "Surf" "Hydro Pump" "Withdraw" "Body Slam"))
         (p1   (pokemon-sim/glue:plist->pokemon c-pl))
         (p2   (pokemon-sim/glue:plist->pokemon b-pl))
         (m1   (pokemon-sim/glue:catalog-move->coalton
                 (catalog:find-move kb "Flamethrower")))
         (m2   (pokemon-sim/glue:catalog-move->coalton
                 (catalog:find-move kb "Surf")))
         (res  (pokemon-sim:simulate-battle kb p1 m1 p2 m2 20)))
    ;; Extract winner name before any fiveam assertion to avoid scope issues
    (let ((winner-name
            (pokemon-sim/glue:match-outcome res
              :winner w
              :victor  (pokemon-sim:pokemon-name w)
              :draw    nil
              :ongoing nil)))
      (fiveam:is (string= "Blastoise" winner-name)))))

;;;; ─── Runner ─────────────────────────────────────────────────────────────────

(defun run-tests ()
  "Run the full Pokémon simulator test suite."
  (format t "~%Running pokemon-suite...~%")
  (let ((results (fiveam:run 'pokemon-suite)))
    (fiveam:explain! results)
    results))
