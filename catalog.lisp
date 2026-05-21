;;; catalog.lisp — Gen I Yellow Pokédex, move, item, and badge-battle data
;;; All data is pure CL (no Coalton dependency).
(named-readtables:in-readtable :standard)

(in-package #:pokemon-catalog)

;;;; ── Pokémon record ────────────────────────────────────────────────────────

(defstruct (pkmn-species (:conc-name species-))
  name        ; string
  number      ; dex #
  type1       ; keyword symbol
  type2       ; keyword symbol or nil
  base-hp
  base-atk
  base-def
  base-spc
  base-spd
  learnset)   ; list of (level . move-name-string)

(defstruct (pkmn-move (:conc-name move-))
  name
  type        ; keyword symbol
  category    ; :physical or :special (Gen I split = stat-based, not type-based)
  power       ; 0 for status
  accuracy    ; 0-100
  pp
  effect)     ; keyword or nil

(defstruct (pkmn-item (:conc-name item-))
  name
  symbol      ; keyword used by logic engine
  description)

;;;; ── Move table (curated Gen I Yellow set) ─────────────────────────────────

(defparameter *gen1-moves*
  (list
   ;; Normal
   (make-pkmn-move :name "Tackle"       :type :normal   :category :physical :power 35  :accuracy 95 :pp 35)
   (make-pkmn-move :name "Scratch"      :type :normal   :category :physical :power 40  :accuracy 100 :pp 35)
   (make-pkmn-move :name "Pound"        :type :normal   :category :physical :power 40  :accuracy 100 :pp 35)
   (make-pkmn-move :name "Quick Attack" :type :normal   :category :physical :power 40  :accuracy 100 :pp 30 :effect :always-first)
   (make-pkmn-move :name "Body Slam"    :type :normal   :category :physical :power 85  :accuracy 100 :pp 15 :effect :paralysis-30)
   (make-pkmn-move :name "Hyper Beam"   :type :normal   :category :physical :power 150 :accuracy 90  :pp 5  :effect :recharge)
   (make-pkmn-move :name "Growl"        :type :normal   :category :physical :power 0   :accuracy 100 :pp 40 :effect :lower-atk)
   (make-pkmn-move :name "Tail Whip"    :type :normal   :category :physical :power 0   :accuracy 100 :pp 30 :effect :lower-def)
   (make-pkmn-move :name "Leer"         :type :normal   :category :physical :power 0   :accuracy 100 :pp 30 :effect :lower-def)
   (make-pkmn-move :name "Sing"         :type :normal   :category :physical :power 0   :accuracy 55  :pp 15 :effect :sleep)
   ;; Fire
   (make-pkmn-move :name "Ember"        :type :fire     :category :special  :power 40  :accuracy 100 :pp 25 :effect :burn-10)
   (make-pkmn-move :name "Flamethrower" :type :fire     :category :special  :power 95  :accuracy 100 :pp 15 :effect :burn-10)
   (make-pkmn-move :name "Fire Blast"   :type :fire     :category :special  :power 120 :accuracy 85  :pp 5  :effect :burn-30)
   ;; Water
   (make-pkmn-move :name "Water Gun"    :type :water    :category :special  :power 40  :accuracy 100 :pp 25)
   (make-pkmn-move :name "Surf"         :type :water    :category :special  :power 95  :accuracy 100 :pp 15)
   (make-pkmn-move :name "Hydro Pump"   :type :water    :category :special  :power 120 :accuracy 80  :pp 5)
   (make-pkmn-move :name "Bubble"       :type :water    :category :special  :power 20  :accuracy 100 :pp 30 :effect :lower-spd-10)
   (make-pkmn-move :name "Bubblebeam"   :type :water    :category :special  :power 65  :accuracy 100 :pp 20 :effect :lower-spd-33)
   ;; Grass
   (make-pkmn-move :name "Vine Whip"    :type :grass    :category :special  :power 35  :accuracy 100 :pp 10)
   (make-pkmn-move :name "Razor Leaf"   :type :grass    :category :special  :power 55  :accuracy 95  :pp 25 :effect :high-crit)
   (make-pkmn-move :name "Solar Beam"   :type :grass    :category :special  :power 120 :accuracy 100 :pp 10 :effect :charge-turn)
   ;; Electric
   (make-pkmn-move :name "Thunder Shock":type :electric :category :special  :power 40  :accuracy 100 :pp 30 :effect :paralysis-10)
   (make-pkmn-move :name "Thunderbolt"  :type :electric :category :special  :power 95  :accuracy 100 :pp 15 :effect :paralysis-10)
   (make-pkmn-move :name "Thunder"      :type :electric :category :special  :power 120 :accuracy 70  :pp 10 :effect :paralysis-10)
   (make-pkmn-move :name "Thunder Wave" :type :electric :category :physical :power 0   :accuracy 100 :pp 20 :effect :paralysis)
   ;; Ice
   (make-pkmn-move :name "Ice Beam"     :type :ice      :category :special  :power 95  :accuracy 100 :pp 10 :effect :freeze-10)
   (make-pkmn-move :name "Blizzard"     :type :ice      :category :special  :power 120 :accuracy 90  :pp 5  :effect :freeze-10)
   ;; Fighting
   (make-pkmn-move :name "Karate Chop"  :type :fighting :category :physical :power 50  :accuracy 100 :pp 25 :effect :high-crit)
   (make-pkmn-move :name "Low Kick"     :type :fighting :category :physical :power 50  :accuracy 90  :pp 20 :effect :flinch-30)
   (make-pkmn-move :name "Seismic Toss" :type :fighting :category :physical :power 0   :accuracy 100 :pp 20 :effect :level-damage)
   ;; Poison
   (make-pkmn-move :name "Poison Sting" :type :poison   :category :physical :power 15  :accuracy 100 :pp 35 :effect :poison-20)
   (make-pkmn-move :name "Acid"         :type :poison   :category :special  :power 40  :accuracy 100 :pp 30 :effect :lower-def-33)
   (make-pkmn-move :name "Toxic"        :type :poison   :category :physical :power 0   :accuracy 85  :pp 10 :effect :bad-poison)
   ;; Ground
   (make-pkmn-move :name "Earthquake"   :type :ground   :category :physical :power 100 :accuracy 100 :pp 10)
   (make-pkmn-move :name "Dig"          :type :ground   :category :physical :power 100 :accuracy 100 :pp 10 :effect :charge-turn)
   ;; Flying
   (make-pkmn-move :name "Gust"         :type :flying   :category :special  :power 40  :accuracy 100 :pp 35)
   (make-pkmn-move :name "Wing Attack"  :type :flying   :category :physical :power 35  :accuracy 100 :pp 35)
   ;; Psychic
   (make-pkmn-move :name "Confusion"    :type :psychic  :category :special  :power 50  :accuracy 100 :pp 25 :effect :confuse-10)
   (make-pkmn-move :name "Psybeam"      :type :psychic  :category :special  :power 65  :accuracy 100 :pp 20 :effect :confuse-10)
   (make-pkmn-move :name "Psychic"      :type :psychic  :category :special  :power 90  :accuracy 100 :pp 10 :effect :lower-spc-33)
   ;; Bug
   (make-pkmn-move :name "String Shot"  :type :bug      :category :physical :power 0   :accuracy 95  :pp 40 :effect :lower-spd)
   (make-pkmn-move :name "Leech Life"   :type :bug      :category :physical :power 20  :accuracy 100 :pp 15 :effect :drain-half)
   ;; Rock
   (make-pkmn-move :name "Rock Throw"   :type :rock     :category :physical :power 50  :accuracy 65  :pp 15)
   (make-pkmn-move :name "Rock Slide"   :type :rock     :category :physical :power 75  :accuracy 90  :pp 10 :effect :flinch-30)
   ;; Ghost
   (make-pkmn-move :name "Lick"         :type :ghost    :category :physical :power 20  :accuracy 100 :pp 30 :effect :paralysis-30)
   (make-pkmn-move :name "Night Shade"  :type :ghost    :category :special  :power 0   :accuracy 100 :pp 15 :effect :level-damage)
   ;; Misc / TMs
   (make-pkmn-move :name "Swords Dance"     :type :normal   :category :physical :power 0 :accuracy 100 :pp 30 :effect :raise-atk-2)
   (make-pkmn-move :name "Harden"           :type :normal   :category :physical :power 0 :accuracy 100 :pp 30 :effect :raise-def)
   (make-pkmn-move :name "Withdraw"         :type :water    :category :physical :power 0 :accuracy 100 :pp 40 :effect :raise-def)
   (make-pkmn-move :name "Defense Curl"     :type :normal   :category :physical :power 0 :accuracy 100 :pp 40 :effect :raise-def)
   (make-pkmn-move :name "Bide"             :type :normal   :category :physical :power 0 :accuracy 100 :pp 10 :effect :bide)
   (make-pkmn-move :name "Bind"             :type :normal   :category :physical :power 15 :accuracy 75  :pp 20 :effect :trapping)
   (make-pkmn-move :name "Slam"             :type :normal   :category :physical :power 80 :accuracy 75  :pp 20)))

(defun find-move (name)
  "Look up a move by name string. Returns nil if not found."
  (find name *gen1-moves* :key #'move-name :test #'string-equal))

;;;; ── Item table ────────────────────────────────────────────────────────────

(defparameter *gen1-items*
  (list
   (make-pkmn-item :name "Potion"       :symbol 'potion       :description "Restores 20 HP.")
   (make-pkmn-item :name "Super Potion" :symbol 'super-potion :description "Restores 50 HP.")
   (make-pkmn-item :name "Hyper Potion" :symbol 'hyper-potion :description "Restores 200 HP.")
   (make-pkmn-item :name "Max Potion"   :symbol 'max-potion   :description "Fully restores HP.")
   (make-pkmn-item :name "Full Restore" :symbol 'full-restore :description "Fully restores HP and cures status.")
   (make-pkmn-item :name "Revive"       :symbol 'revive       :description "Revives fainted Pokémon to half HP.")
   (make-pkmn-item :name "Max Revive"   :symbol 'max-revive   :description "Revives fainted Pokémon to full HP.")
   (make-pkmn-item :name "Antidote"     :symbol 'antidote     :description "Cures poison.")
   (make-pkmn-item :name "Burn Heal"    :symbol 'burn-heal    :description "Cures burn.")
   (make-pkmn-item :name "Ice Heal"     :symbol 'ice-heal     :description "Cures freeze.")
   (make-pkmn-item :name "Awakening"    :symbol 'awakening    :description "Cures sleep.")
   (make-pkmn-item :name "Parlyz Heal"  :symbol 'parlyz-heal  :description "Cures paralysis.")
   (make-pkmn-item :name "Full Heal"    :symbol 'full-heal    :description "Cures any status condition.")
   (make-pkmn-item :name "X Attack"     :symbol 'x-attack     :description "Raises Attack 1 stage.")
   (make-pkmn-item :name "X Defense"    :symbol 'x-defense    :description "Raises Defense 1 stage.")
   (make-pkmn-item :name "X Speed"      :symbol 'x-speed      :description "Raises Speed 1 stage.")
   (make-pkmn-item :name "X Special"    :symbol 'x-special    :description "Raises Special 1 stage.")
   (make-pkmn-item :name "Dire Hit"     :symbol 'dire-hit     :description "Raises critical-hit ratio.")
   (make-pkmn-item :name "Guard Spec."  :symbol 'guard-spec   :description "Prevents stat reduction.")))

(defun find-item (name-or-sym)
  "Look up an item by name string or keyword symbol."
  (or (find name-or-sym *gen1-items* :key #'item-name   :test #'string-equal)
      (find name-or-sym *gen1-items* :key #'item-symbol :test #'eq)))

;;;; ── Gen I Yellow Pokédex (complete 151) ───────────────────────────────────
;;; Format: (number name type1 type2 hp atk def spc spd)
;;; Moveset is abbreviated to the 4 most representative/level-up moves.

(defparameter *gen1-yellow-roster*
  ;; ── Starters ──────────────────────────────────────────────────────────────
  (list
   ;; Pikachu — Yellow's special starter
   (make-pkmn-species :name "Pikachu"   :number 25  :type1 :electric :type2 nil
                      :base-hp 35 :base-atk 55 :base-def 30 :base-spc 50 :base-spd 90
                      :learnset '((1 . "Thunder Shock")(1 . "Growl")(9 . "Thunderbolt")
                                  (26 . "Quick Attack")(33 . "Thunder Wave")(43 . "Thunder")))
   (make-pkmn-species :name "Raichu"    :number 26  :type1 :electric :type2 nil
                      :base-hp 60 :base-atk 90 :base-def 55 :base-spc 90 :base-spd 110
                      :learnset '((1 . "Thunderbolt")(1 . "Thunder Wave")(1 . "Quick Attack")(1 . "Thunder")))
   (make-pkmn-species :name "Bulbasaur" :number 1   :type1 :grass :type2 :poison
                      :base-hp 45 :base-atk 49 :base-def 49 :base-spc 65 :base-spd 45
                      :learnset '((1 . "Tackle")(1 . "Growl")(7 . "Vine Whip")(22 . "Razor Leaf")))
   (make-pkmn-species :name "Ivysaur"   :number 2   :type1 :grass :type2 :poison
                      :base-hp 60 :base-atk 62 :base-def 63 :base-spc 80 :base-spd 60
                      :learnset '((1 . "Vine Whip")(22 . "Razor Leaf")(30 . "Toxic")(32 . "Solar Beam")))
   (make-pkmn-species :name "Venusaur"  :number 3   :type1 :grass :type2 :poison
                      :base-hp 80 :base-atk 82 :base-def 83 :base-spc 100 :base-spd 80
                      :learnset '((1 . "Vine Whip")(32 . "Solar Beam")(43 . "Razor Leaf")(55 . "Hyper Beam")))
   (make-pkmn-species :name "Charmander":number 4   :type1 :fire  :type2 nil
                      :base-hp 39 :base-atk 52 :base-def 43 :base-spc 50 :base-spd 65
                      :learnset '((1 . "Scratch")(1 . "Growl")(9 . "Ember")(23 . "Slash")))
   (make-pkmn-species :name "Charmeleon":number 5   :type1 :fire  :type2 nil
                      :base-hp 58 :base-atk 64 :base-def 58 :base-spc 65 :base-spd 80
                      :learnset '((1 . "Scratch")(1 . "Ember")(36 . "Flamethrower")(46 . "Fire Blast")))
   (make-pkmn-species :name "Charizard" :number 6   :type1 :fire  :type2 :flying
                      :base-hp 78 :base-atk 84 :base-def 78 :base-spc 85 :base-spd 100
                      :learnset '((1 . "Ember")(36 . "Flamethrower")(46 . "Fire Blast")(56 . "Hyper Beam")))
   (make-pkmn-species :name "Squirtle"  :number 7   :type1 :water :type2 nil
                      :base-hp 44 :base-atk 48 :base-def 65 :base-spc 50 :base-spd 43
                      :learnset '((1 . "Tackle")(1 . "Tail Whip")(13 . "Bubble")(22 . "Water Gun")))
   (make-pkmn-species :name "Wartortle" :number 8   :type1 :water :type2 nil
                      :base-hp 59 :base-atk 63 :base-def 80 :base-spc 65 :base-spd 58
                      :learnset '((1 . "Water Gun")(31 . "Withdraw")(39 . "Surf")(47 . "Hydro Pump")))
   (make-pkmn-species :name "Blastoise" :number 9   :type1 :water :type2 nil
                      :base-hp 79 :base-atk 83 :base-def 100 :base-spc 85 :base-spd 78
                      :learnset '((1 . "Water Gun")(39 . "Surf")(47 . "Hydro Pump")(56 . "Hyper Beam")))
   ;; ── Caterpie line ─────────────────────────────────────────────────────────
   (make-pkmn-species :name "Caterpie"  :number 10  :type1 :bug   :type2 nil
                      :base-hp 45 :base-atk 30 :base-def 35 :base-spc 20 :base-spd 45
                      :learnset '((1 . "Tackle")(1 . "String Shot")))
   (make-pkmn-species :name "Metapod"   :number 11  :type1 :bug   :type2 nil
                      :base-hp 50 :base-atk 20 :base-def 55 :base-spc 25 :base-spd 30
                      :learnset '((1 . "Harden")))
   (make-pkmn-species :name "Butterfree":number 12  :type1 :bug   :type2 :flying
                      :base-hp 60 :base-atk 45 :base-def 50 :base-spc 80 :base-spd 70
                      :learnset '((1 . "Confusion")(12 . "Psybeam")(21 . "Sleep Powder")(26 . "Psychic")))
   ;; ── Weedle line ───────────────────────────────────────────────────────────
   (make-pkmn-species :name "Weedle"    :number 13  :type1 :bug   :type2 :poison
                      :base-hp 40 :base-atk 35 :base-def 30 :base-spc 20 :base-spd 50
                      :learnset '((1 . "Poison Sting")(1 . "String Shot")))
   (make-pkmn-species :name "Kakuna"    :number 14  :type1 :bug   :type2 :poison
                      :base-hp 45 :base-atk 25 :base-def 50 :base-spc 25 :base-spd 35
                      :learnset '((1 . "Harden")))
   (make-pkmn-species :name "Beedrill"  :number 15  :type1 :bug   :type2 :poison
                      :base-hp 65 :base-atk 80 :base-def 40 :base-spc 45 :base-spd 75
                      :learnset '((1 . "Poison Sting")(20 . "Toxic")(35 . "Agility")(38 . "Pin Missile")))
   ;; ── Pidgey line ───────────────────────────────────────────────────────────
   (make-pkmn-species :name "Pidgey"    :number 16  :type1 :normal :type2 :flying
                      :base-hp 40 :base-atk 45 :base-def 40 :base-spc 35 :base-spd 56
                      :learnset '((1 . "Gust")(1 . "Tackle")(21 . "Wing Attack")(28 . "Quick Attack")))
   (make-pkmn-species :name "Pidgeotto" :number 17  :type1 :normal :type2 :flying
                      :base-hp 63 :base-atk 60 :base-def 55 :base-spc 50 :base-spd 71
                      :learnset '((1 . "Gust")(21 . "Wing Attack")(31 . "Hyper Beam")(36 . "Agility")))
   (make-pkmn-species :name "Pidgeot"   :number 18  :type1 :normal :type2 :flying
                      :base-hp 83 :base-atk 80 :base-def 75 :base-spc 70 :base-spd 91
                      :learnset '((1 . "Wing Attack")(36 . "Hyper Beam")(38 . "Agility")(44 . "Gust")))
   ;; ── Rattata / Raticate ────────────────────────────────────────────────────
   (make-pkmn-species :name "Rattata"   :number 19  :type1 :normal :type2 nil
                      :base-hp 30 :base-atk 56 :base-def 35 :base-spc 25 :base-spd 72
                      :learnset '((1 . "Tackle")(1 . "Tail Whip")(14 . "Quick Attack")(27 . "Body Slam")))
   (make-pkmn-species :name "Raticate"  :number 20  :type1 :normal :type2 nil
                      :base-hp 55 :base-atk 81 :base-def 60 :base-spc 50 :base-spd 97
                      :learnset '((1 . "Quick Attack")(28 . "Body Slam")(34 . "Hyper Beam")(48 . "Super Fang")))
   ;; ── Spearow / Fearow ──────────────────────────────────────────────────────
   (make-pkmn-species :name "Spearow"   :number 21  :type1 :normal :type2 :flying
                      :base-hp 40 :base-atk 60 :base-def 30 :base-spc 31 :base-spd 70
                      :learnset '((1 . "Peck")(1 . "Growl")(9 . "Leer")(22 . "Fury Attack")))
   (make-pkmn-species :name "Fearow"    :number 22  :type1 :normal :type2 :flying
                      :base-hp 65 :base-atk 90 :base-def 65 :base-spc 61 :base-spd 100
                      :learnset '((1 . "Peck")(20 . "Leer")(29 . "Fury Attack")(34 . "Hyper Beam")))
   ;; ── Ekans / Arbok ─────────────────────────────────────────────────────────
   (make-pkmn-species :name "Ekans"     :number 23  :type1 :poison :type2 nil
                      :base-hp 35 :base-atk 60 :base-def 44 :base-spc 40 :base-spd 55
                      :learnset '((1 . "Wrap")(1 . "Leer")(17 . "Poison Sting")(27 . "Acid")))
   (make-pkmn-species :name "Arbok"     :number 24  :type1 :poison :type2 nil
                      :base-hp 60 :base-atk 85 :base-def 69 :base-spc 65 :base-spd 80
                      :learnset '((1 . "Poison Sting")(27 . "Acid")(34 . "Toxic")(40 . "Hyper Beam")))
   ;; ── Sandshrew / Sandslash ─────────────────────────────────────────────────
   (make-pkmn-species :name "Sandshrew" :number 27  :type1 :ground :type2 nil
                      :base-hp 50 :base-atk 75 :base-def 85 :base-spc 30 :base-spd 40
                      :learnset '((1 . "Scratch")(17 . "Sand Attack")(27 . "Dig")(40 . "Earthquake")))
   (make-pkmn-species :name "Sandslash" :number 28  :type1 :ground :type2 nil
                      :base-hp 75 :base-atk 100 :base-def 110 :base-spc 55 :base-spd 65
                      :learnset '((1 . "Scratch")(27 . "Dig")(40 . "Earthquake")(54 . "Slash")))
   ;; ── Nidoran family ────────────────────────────────────────────────────────
   (make-pkmn-species :name "Nidoran-F" :number 29  :type1 :poison :type2 nil
                      :base-hp 55 :base-atk 47 :base-def 52 :base-spc 40 :base-spd 41
                      :learnset '((1 . "Growl")(1 . "Tackle")(14 . "Poison Sting")(23 . "Body Slam")))
   (make-pkmn-species :name "Nidorina"  :number 30  :type1 :poison :type2 nil
                      :base-hp 70 :base-atk 62 :base-def 67 :base-spc 55 :base-spd 56
                      :learnset '((1 . "Tackle")(23 . "Body Slam")(38 . "Toxic")(44 . "Blizzard")))
   (make-pkmn-species :name "Nidoqueen" :number 31  :type1 :poison :type2 :ground
                      :base-hp 90 :base-atk 82 :base-def 87 :base-spc 75 :base-spd 76
                      :learnset '((1 . "Tackle")(1 . "Earthquake")(1 . "Body Slam")(1 . "Hyper Beam")))
   (make-pkmn-species :name "Nidoran-M" :number 32  :type1 :poison :type2 nil
                      :base-hp 46 :base-atk 57 :base-def 40 :base-spc 40 :base-spd 50
                      :learnset '((1 . "Leer")(1 . "Tackle")(16 . "Poison Sting")(25 . "Focus Energy")))
   (make-pkmn-species :name "Nidorino"  :number 33  :type1 :poison :type2 nil
                      :base-hp 61 :base-atk 72 :base-def 57 :base-spc 55 :base-spd 65
                      :learnset '((1 . "Tackle")(25 . "Focus Energy")(38 . "Toxic")(43 . "Blizzard")))
   (make-pkmn-species :name "Nidoking"  :number 34  :type1 :poison :type2 :ground
                      :base-hp 81 :base-atk 92 :base-def 77 :base-spc 75 :base-spd 85
                      :learnset '((1 . "Tackle")(1 . "Earthquake")(1 . "Toxic")(1 . "Hyper Beam")))
   ;; ── Clefairy / Clefable ───────────────────────────────────────────────────
   (make-pkmn-species :name "Clefairy"  :number 35  :type1 :normal :type2 nil
                      :base-hp 70 :base-atk 45 :base-def 48 :base-spc 60 :base-spd 35
                      :learnset '((1 . "Pound")(1 . "Growl")(13 . "Sing")(19 . "Body Slam")))
   (make-pkmn-species :name "Clefable"  :number 36  :type1 :normal :type2 nil
                      :base-hp 95 :base-atk 70 :base-def 73 :base-spc 85 :base-spd 60
                      :learnset '((1 . "Pound")(1 . "Sing")(1 . "Body Slam")(1 . "Hyper Beam")))
   ;; ── Vulpix / Ninetales ────────────────────────────────────────────────────
   (make-pkmn-species :name "Vulpix"    :number 37  :type1 :fire  :type2 nil
                      :base-hp 38 :base-atk 41 :base-def 40 :base-spc 65 :base-spd 65
                      :learnset '((1 . "Ember")(16 . "Quick Attack")(28 . "Flamethrower")(35 . "Fire Blast")))
   (make-pkmn-species :name "Ninetales" :number 38  :type1 :fire  :type2 nil
                      :base-hp 73 :base-atk 76 :base-def 75 :base-spc 100 :base-spd 100
                      :learnset '((1 . "Ember")(1 . "Quick Attack")(1 . "Flamethrower")(1 . "Fire Blast")))
   ;; ── Jigglypuff / Wigglytuff ───────────────────────────────────────────────
   (make-pkmn-species :name "Jigglypuff":number 39  :type1 :normal :type2 nil
                      :base-hp 115 :base-atk 45 :base-def 20 :base-spc 25 :base-spd 20
                      :learnset '((1 . "Pound")(1 . "Sing")(9 . "Body Slam")(14 . "Slam")))
   (make-pkmn-species :name "Wigglytuff":number 40  :type1 :normal :type2 nil
                      :base-hp 140 :base-atk 70 :base-def 45 :base-spc 50 :base-spd 45
                      :learnset '((1 . "Pound")(1 . "Sing")(1 . "Body Slam")(1 . "Hyper Beam")))
   ;; ── Zubat / Golbat ────────────────────────────────────────────────────────
   (make-pkmn-species :name "Zubat"     :number 41  :type1 :poison :type2 :flying
                      :base-hp 40 :base-atk 45 :base-def 35 :base-spc 40 :base-spd 55
                      :learnset '((1 . "Leech Life")(1 . "Supersonic")(21 . "Wing Attack")(32 . "Toxic")))
   (make-pkmn-species :name "Golbat"    :number 42  :type1 :poison :type2 :flying
                      :base-hp 75 :base-atk 80 :base-def 70 :base-spc 75 :base-spd 90
                      :learnset '((1 . "Leech Life")(1 . "Wing Attack")(32 . "Toxic")(48 . "Hyper Beam")))
   ;; ── Oddish line ───────────────────────────────────────────────────────────
   (make-pkmn-species :name "Oddish"    :number 43  :type1 :grass :type2 :poison
                      :base-hp 45 :base-atk 50 :base-def 55 :base-spc 75 :base-spd 30
                      :learnset '((1 . "Absorb")(15 . "Acid")(19 . "Poison Powder")(24 . "Solar Beam")))
   (make-pkmn-species :name "Gloom"     :number 44  :type1 :grass :type2 :poison
                      :base-hp 60 :base-atk 65 :base-def 70 :base-spc 85 :base-spd 40
                      :learnset '((1 . "Acid")(28 . "Solar Beam")(38 . "Toxic")(44 . "Petal Dance")))
   (make-pkmn-species :name "Vileplume" :number 45  :type1 :grass :type2 :poison
                      :base-hp 75 :base-atk 80 :base-def 85 :base-spc 100 :base-spd 50
                      :learnset '((1 . "Acid")(1 . "Solar Beam")(1 . "Toxic")(1 . "Petal Dance")))
   ;; ── Paras / Parasect ──────────────────────────────────────────────────────
   (make-pkmn-species :name "Paras"     :number 46  :type1 :bug  :type2 :grass
                      :base-hp 35 :base-atk 70 :base-def 55 :base-spc 55 :base-spd 25
                      :learnset '((1 . "Scratch")(1 . "Stun Spore")(13 . "Acid")(30 . "Slash")))
   (make-pkmn-species :name "Parasect"  :number 47  :type1 :bug  :type2 :grass
                      :base-hp 60 :base-atk 95 :base-def 80 :base-spc 80 :base-spd 30
                      :learnset '((1 . "Scratch")(1 . "Slash")(30 . "Spore")(1 . "Leech Life")))
   ;; ── Venonat / Venomoth ────────────────────────────────────────────────────
   (make-pkmn-species :name "Venonat"   :number 48  :type1 :bug  :type2 :poison
                      :base-hp 60 :base-atk 55 :base-def 50 :base-spc 40 :base-spd 45
                      :learnset '((1 . "Tackle")(1 . "Disable")(19 . "Psybeam")(31 . "Psychic")))
   (make-pkmn-species :name "Venomoth"  :number 49  :type1 :bug  :type2 :poison
                      :base-hp 70 :base-atk 65 :base-def 60 :base-spc 90 :base-spd 90
                      :learnset '((1 . "Psybeam")(31 . "Psychic")(38 . "Leech Life")(43 . "Hyper Beam")))
   ;; ── Diglett / Dugtrio ─────────────────────────────────────────────────────
   (make-pkmn-species :name "Diglett"   :number 50  :type1 :ground :type2 nil
                      :base-hp 10 :base-atk 55 :base-def 25 :base-spc 45 :base-spd 95
                      :learnset '((1 . "Scratch")(15 . "Growl")(19 . "Dig")(26 . "Earthquake")))
   (make-pkmn-species :name "Dugtrio"   :number 51  :type1 :ground :type2 nil
                      :base-hp 35 :base-atk 80 :base-def 50 :base-spc 70 :base-spd 120
                      :learnset '((1 . "Scratch")(19 . "Dig")(26 . "Earthquake")(35 . "Fissure")))
   ;; ── Meowth / Persian ──────────────────────────────────────────────────────
   (make-pkmn-species :name "Meowth"    :number 52  :type1 :normal :type2 nil
                      :base-hp 40 :base-atk 45 :base-def 35 :base-spc 40 :base-spd 90
                      :learnset '((1 . "Scratch")(1 . "Growl")(12 . "Bite")(21 . "Screech")))
   (make-pkmn-species :name "Persian"   :number 53  :type1 :normal :type2 nil
                      :base-hp 65 :base-atk 70 :base-def 60 :base-spc 65 :base-spd 115
                      :learnset '((1 . "Scratch")(1 . "Growl")(30 . "Slash")(38 . "Hyper Beam")))
   ;; ── Psyduck / Golduck ─────────────────────────────────────────────────────
   (make-pkmn-species :name "Psyduck"   :number 54  :type1 :water :type2 nil
                      :base-hp 50 :base-atk 52 :base-def 48 :base-spc 50 :base-spd 55
                      :learnset '((1 . "Scratch")(1 . "Tail Whip")(28 . "Psybeam")(33 . "Confusion")))
   (make-pkmn-species :name "Golduck"   :number 55  :type1 :water :type2 nil
                      :base-hp 80 :base-atk 82 :base-def 78 :base-spc 80 :base-spd 85
                      :learnset '((1 . "Scratch")(33 . "Psybeam")(39 . "Surf")(48 . "Hyper Beam")))
   ;; ── Mankey / Primeape ─────────────────────────────────────────────────────
   (make-pkmn-species :name "Mankey"    :number 56  :type1 :fighting :type2 nil
                      :base-hp 40 :base-atk 80 :base-def 35 :base-spc 35 :base-spd 70
                      :learnset '((1 . "Scratch")(1 . "Leer")(15 . "Karate Chop")(25 . "Seismic Toss")))
   (make-pkmn-species :name "Primeape"  :number 57  :type1 :fighting :type2 nil
                      :base-hp 65 :base-atk 105 :base-def 60 :base-spc 60 :base-spd 95
                      :learnset '((1 . "Karate Chop")(25 . "Seismic Toss")(35 . "Low Kick")(46 . "Hyper Beam")))
   ;; ── Growlithe / Arcanine ──────────────────────────────────────────────────
   (make-pkmn-species :name "Growlithe" :number 58  :type1 :fire  :type2 nil
                      :base-hp 55 :base-atk 70 :base-def 45 :base-spc 50 :base-spd 60
                      :learnset '((1 . "Ember")(1 . "Bite")(18 . "Flamethrower")(30 . "Fire Blast")))
   (make-pkmn-species :name "Arcanine"  :number 59  :type1 :fire  :type2 nil
                      :base-hp 90 :base-atk 110 :base-def 80 :base-spc 80 :base-spd 95
                      :learnset '((1 . "Ember")(1 . "Flamethrower")(1 . "Fire Blast")(1 . "Hyper Beam")))
   ;; ── Poliwag line ──────────────────────────────────────────────────────────
   (make-pkmn-species :name "Poliwag"   :number 60  :type1 :water :type2 nil
                      :base-hp 40 :base-atk 50 :base-def 40 :base-spc 40 :base-spd 90
                      :learnset '((1 . "Bubble")(16 . "Bubblebeam")(19 . "Surf")(31 . "Body Slam")))
   (make-pkmn-species :name "Poliwhirl" :number 61  :type1 :water :type2 nil
                      :base-hp 65 :base-atk 65 :base-def 65 :base-spc 50 :base-spd 90
                      :learnset '((1 . "Bubblebeam")(31 . "Body Slam")(38 . "Surf")(45 . "Amnesia")))
   (make-pkmn-species :name "Poliwrath" :number 62  :type1 :water :type2 :fighting
                      :base-hp 90 :base-atk 85 :base-def 95 :base-spc 70 :base-spd 70
                      :learnset '((1 . "Body Slam")(1 . "Surf")(1 . "Seismic Toss")(1 . "Hyper Beam")))
   ;; ── Abra line ─────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Abra"      :number 63  :type1 :psychic :type2 nil
                      :base-hp 25 :base-atk 20 :base-def 15 :base-spc 105 :base-spd 90
                      :learnset '((1 . "Teleport")))
   (make-pkmn-species :name "Kadabra"   :number 64  :type1 :psychic :type2 nil
                      :base-hp 40 :base-atk 35 :base-def 30 :base-spc 120 :base-spd 105
                      :learnset '((1 . "Confusion")(16 . "Psybeam")(20 . "Recover")(27 . "Psychic")))
   (make-pkmn-species :name "Alakazam"  :number 65  :type1 :psychic :type2 nil
                      :base-hp 55 :base-atk 50 :base-def 45 :base-spc 135 :base-spd 120
                      :learnset '((1 . "Confusion")(27 . "Psychic")(33 . "Recover")(38 . "Hyper Beam")))
   ;; ── Machop line ───────────────────────────────────────────────────────────
   (make-pkmn-species :name "Machop"    :number 66  :type1 :fighting :type2 nil
                      :base-hp 70 :base-atk 80 :base-def 50 :base-spc 35 :base-spd 35
                      :learnset '((1 . "Karate Chop")(20 . "Low Kick")(29 . "Seismic Toss")(36 . "Submission")))
   (make-pkmn-species :name "Machoke"   :number 67  :type1 :fighting :type2 nil
                      :base-hp 80 :base-atk 100 :base-def 70 :base-spc 50 :base-spd 45
                      :learnset '((1 . "Karate Chop")(29 . "Seismic Toss")(36 . "Submission")(44 . "Hyper Beam")))
   (make-pkmn-species :name "Machamp"   :number 68  :type1 :fighting :type2 nil
                      :base-hp 90 :base-atk 130 :base-def 80 :base-spc 65 :base-spd 55
                      :learnset '((1 . "Karate Chop")(1 . "Seismic Toss")(1 . "Submission")(1 . "Hyper Beam")))
   ;; ── Bellsprout line ───────────────────────────────────────────────────────
   (make-pkmn-species :name "Bellsprout":number 69  :type1 :grass :type2 :poison
                      :base-hp 50 :base-atk 75 :base-def 35 :base-spc 70 :base-spd 40
                      :learnset '((1 . "Vine Whip")(13 . "Acid")(21 . "Razor Leaf")(26 . "Solar Beam")))
   (make-pkmn-species :name "Weepinbell":number 70  :type1 :grass :type2 :poison
                      :base-hp 65 :base-atk 90 :base-def 50 :base-spc 85 :base-spd 55
                      :learnset '((1 . "Vine Whip")(26 . "Solar Beam")(38 . "Toxic")(43 . "Razor Leaf")))
   (make-pkmn-species :name "Victreebel":number 71  :type1 :grass :type2 :poison
                      :base-hp 80 :base-atk 105 :base-def 65 :base-spc 100 :base-spd 70
                      :learnset '((1 . "Vine Whip")(1 . "Solar Beam")(1 . "Razor Leaf")(1 . "Hyper Beam")))
   ;; ── Tentacool / Tentacruel ────────────────────────────────────────────────
   (make-pkmn-species :name "Tentacool" :number 72  :type1 :water :type2 :poison
                      :base-hp 40 :base-atk 40 :base-def 35 :base-spc 100 :base-spd 70
                      :learnset '((1 . "Acid")(1 . "Poison Sting")(19 . "Bubblebeam")(30 . "Surf")))
   (make-pkmn-species :name "Tentacruel":number 73  :type1 :water :type2 :poison
                      :base-hp 80 :base-atk 70 :base-def 65 :base-spc 120 :base-spd 100
                      :learnset '((1 . "Acid")(1 . "Bubblebeam")(40 . "Surf")(48 . "Hyper Beam")))
   ;; ── Geodude line ──────────────────────────────────────────────────────────
   (make-pkmn-species :name "Geodude"   :number 74  :type1 :rock  :type2 :ground
                      :base-hp 40 :base-atk 80 :base-def 100 :base-spc 30 :base-spd 20
                      :learnset '((1 . "Tackle")(11 . "Defense Curl")(16 . "Rock Throw")(21 . "Earthquake")))
   (make-pkmn-species :name "Graveler"  :number 75  :type1 :rock  :type2 :ground
                      :base-hp 55 :base-atk 95 :base-def 115 :base-spc 45 :base-spd 35
                      :learnset '((1 . "Tackle")(21 . "Rock Throw")(36 . "Earthquake")(40 . "Rock Slide")))
   (make-pkmn-species :name "Golem"     :number 76  :type1 :rock  :type2 :ground
                      :base-hp 80 :base-atk 110 :base-def 130 :base-spc 55 :base-spd 45
                      :learnset '((1 . "Tackle")(36 . "Earthquake")(40 . "Rock Slide")(48 . "Hyper Beam")))
   ;; ── Ponyta / Rapidash ─────────────────────────────────────────────────────
   (make-pkmn-species :name "Ponyta"    :number 77  :type1 :fire  :type2 nil
                      :base-hp 50 :base-atk 85 :base-def 55 :base-spc 65 :base-spd 90
                      :learnset '((1 . "Ember")(26 . "Flamethrower")(32 . "Fire Blast")(38 . "Stomp")))
   (make-pkmn-species :name "Rapidash"  :number 78  :type1 :fire  :type2 nil
                      :base-hp 65 :base-atk 100 :base-def 70 :base-spc 80 :base-spd 105
                      :learnset '((1 . "Ember")(1 . "Flamethrower")(1 . "Fire Blast")(1 . "Hyper Beam")))
   ;; ── Slowpoke / Slowbro ────────────────────────────────────────────────────
   (make-pkmn-species :name "Slowpoke"  :number 79  :type1 :water :type2 :psychic
                      :base-hp 90 :base-atk 65 :base-def 65 :base-spc 40 :base-spd 15
                      :learnset '((1 . "Tackle")(18 . "Confusion")(22 . "Water Gun")(33 . "Psychic")))
   (make-pkmn-species :name "Slowbro"   :number 80  :type1 :water :type2 :psychic
                      :base-hp 95 :base-atk 75 :base-def 110 :base-spc 80 :base-spd 30
                      :learnset '((1 . "Confusion")(33 . "Psychic")(37 . "Surf")(44 . "Hyper Beam")))
   ;; ── Magnemite / Magneton ──────────────────────────────────────────────────
   (make-pkmn-species :name "Magnemite" :number 81  :type1 :electric :type2 nil
                      :base-hp 25 :base-atk 35 :base-def 70 :base-spc 95 :base-spd 45
                      :learnset '((1 . "Thunder Shock")(21 . "Thunderbolt")(28 . "Thunder Wave")(38 . "Thunder")))
   (make-pkmn-species :name "Magneton"  :number 82  :type1 :electric :type2 nil
                      :base-hp 50 :base-atk 60 :base-def 95 :base-spc 120 :base-spd 70
                      :learnset '((1 . "Thunder Shock")(21 . "Thunderbolt")(38 . "Thunder")(46 . "Hyper Beam")))
   ;; ── Farfetch'd ────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Farfetch'd":number 83  :type1 :normal :type2 :flying
                      :base-hp 52 :base-atk 65 :base-def 55 :base-spc 58 :base-spd 60
                      :learnset '((1 . "Peck")(1 . "Leer")(1 . "Gust")(1 . "Slash")))
   ;; ── Doduo / Dodrio ────────────────────────────────────────────────────────
   (make-pkmn-species :name "Doduo"     :number 84  :type1 :normal :type2 :flying
                      :base-hp 35 :base-atk 85 :base-def 45 :base-spc 35 :base-spd 75
                      :learnset '((1 . "Peck")(20 . "Growl")(27 . "Fury Attack")(37 . "Hyper Beam")))
   (make-pkmn-species :name "Dodrio"    :number 85  :type1 :normal :type2 :flying
                      :base-hp 60 :base-atk 110 :base-def 70 :base-spc 60 :base-spd 100
                      :learnset '((1 . "Peck")(1 . "Fury Attack")(37 . "Hyper Beam")(44 . "Agility")))
   ;; ── Seel / Dewgong ────────────────────────────────────────────────────────
   (make-pkmn-species :name "Seel"      :number 86  :type1 :water :type2 nil
                      :base-hp 65 :base-atk 45 :base-def 55 :base-spc 70 :base-spd 45
                      :learnset '((1 . "Headbutt")(30 . "Ice Beam")(35 . "Blizzard")(40 . "Surf")))
   (make-pkmn-species :name "Dewgong"   :number 87  :type1 :water :type2 :ice
                      :base-hp 90 :base-atk 70 :base-def 80 :base-spc 95 :base-spd 70
                      :learnset '((1 . "Headbutt")(35 . "Ice Beam")(44 . "Blizzard")(50 . "Surf")))
   ;; ── Grimer / Muk ──────────────────────────────────────────────────────────
   (make-pkmn-species :name "Grimer"    :number 88  :type1 :poison :type2 nil
                      :base-hp 80 :base-atk 80 :base-def 50 :base-spc 40 :base-spd 25
                      :learnset '((1 . "Pound")(1 . "Disable")(30 . "Acid")(38 . "Toxic")))
   (make-pkmn-species :name "Muk"       :number 89  :type1 :poison :type2 nil
                      :base-hp 105 :base-atk 105 :base-def 75 :base-spc 65 :base-spd 50
                      :learnset '((1 . "Pound")(38 . "Acid")(45 . "Toxic")(48 . "Hyper Beam")))
   ;; ── Shellder / Cloyster ───────────────────────────────────────────────────
   (make-pkmn-species :name "Shellder"  :number 90  :type1 :water :type2 nil
                      :base-hp 30 :base-atk 65 :base-def 100 :base-spc 45 :base-spd 40
                      :learnset '((1 . "Tackle")(1 . "Withdraw")(18 . "Ice Beam")(26 . "Blizzard")))
   (make-pkmn-species :name "Cloyster"  :number 91  :type1 :water :type2 :ice
                      :base-hp 50 :base-atk 95 :base-def 180 :base-spc 85 :base-spd 70
                      :learnset '((1 . "Surf")(1 . "Ice Beam")(1 . "Blizzard")(1 . "Hyper Beam")))
   ;; ── Gastly line ───────────────────────────────────────────────────────────
   (make-pkmn-species :name "Gastly"    :number 92  :type1 :ghost :type2 :poison
                      :base-hp 30 :base-atk 35 :base-def 30 :base-spc 100 :base-spd 80
                      :learnset '((1 . "Lick")(1 . "Night Shade")(27 . "Confuse Ray")(35 . "Psychic")))
   (make-pkmn-species :name "Haunter"   :number 93  :type1 :ghost :type2 :poison
                      :base-hp 45 :base-atk 50 :base-def 45 :base-spc 115 :base-spd 95
                      :learnset '((1 . "Lick")(1 . "Night Shade")(29 . "Confuse Ray")(38 . "Psychic")))
   (make-pkmn-species :name "Gengar"    :number 94  :type1 :ghost :type2 :poison
                      :base-hp 60 :base-atk 65 :base-def 60 :base-spc 130 :base-spd 110
                      :learnset '((1 . "Lick")(1 . "Night Shade")(38 . "Confuse Ray")(45 . "Hyper Beam")))
   ;; ── Onix ──────────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Onix"      :number 95  :type1 :rock  :type2 :ground
                      :base-hp 35 :base-atk 45 :base-def 160 :base-spc 30 :base-spd 70
                      :learnset '((1 . "Tackle")(1 . "Screech")(15 . "Rock Throw")(34 . "Earthquake")))
   ;; ── Drowzee / Hypno ───────────────────────────────────────────────────────
   (make-pkmn-species :name "Drowzee"   :number 96  :type1 :psychic :type2 nil
                      :base-hp 60 :base-atk 48 :base-def 45 :base-spc 90 :base-spd 42
                      :learnset '((1 . "Pound")(1 . "Disable")(12 . "Confusion")(24 . "Psychic")))
   (make-pkmn-species :name "Hypno"     :number 97  :type1 :psychic :type2 nil
                      :base-hp 85 :base-atk 73 :base-def 70 :base-spc 115 :base-spd 67
                      :learnset '((1 . "Confusion")(24 . "Psychic")(33 . "Psychic")(37 . "Hyper Beam")))
   ;; ── Krabby / Kingler ──────────────────────────────────────────────────────
   (make-pkmn-species :name "Krabby"    :number 98  :type1 :water :type2 nil
                      :base-hp 30 :base-atk 105 :base-def 90 :base-spc 25 :base-spd 50
                      :learnset '((1 . "Bubble")(20 . "Vicegrip")(25 . "Surf")(30 . "Slash")))
   (make-pkmn-species :name "Kingler"   :number 99  :type1 :water :type2 nil
                      :base-hp 55 :base-atk 130 :base-def 115 :base-spc 50 :base-spd 75
                      :learnset '((1 . "Bubble")(1 . "Surf")(1 . "Slash")(1 . "Hyper Beam")))
   ;; ── Voltorb / Electrode ───────────────────────────────────────────────────
   (make-pkmn-species :name "Voltorb"   :number 100 :type1 :electric :type2 nil
                      :base-hp 40 :base-atk 30 :base-def 50 :base-spc 55 :base-spd 100
                      :learnset '((1 . "Tackle")(17 . "Thunderbolt")(22 . "Thunder Wave")(29 . "Thunder")))
   (make-pkmn-species :name "Electrode" :number 101 :type1 :electric :type2 nil
                      :base-hp 60 :base-atk 50 :base-def 70 :base-spc 80 :base-spd 140
                      :learnset '((1 . "Thunderbolt")(29 . "Thunder Wave")(40 . "Thunder")(50 . "Hyper Beam")))
   ;; ── Exeggcute / Exeggutor ─────────────────────────────────────────────────
   (make-pkmn-species :name "Exeggcute" :number 102 :type1 :grass :type2 :psychic
                      :base-hp 60 :base-atk 40 :base-def 80 :base-spc 60 :base-spd 40
                      :learnset '((1 . "Absorb")(25 . "Confusion")(28 . "Solar Beam")(32 . "Psychic")))
   (make-pkmn-species :name "Exeggutor" :number 103 :type1 :grass :type2 :psychic
                      :base-hp 95 :base-atk 95 :base-def 85 :base-spc 125 :base-spd 55
                      :learnset '((1 . "Confusion")(1 . "Solar Beam")(1 . "Psychic")(1 . "Hyper Beam")))
   ;; ── Cubone / Marowak ──────────────────────────────────────────────────────
   (make-pkmn-species :name "Cubone"    :number 104 :type1 :ground :type2 nil
                      :base-hp 50 :base-atk 50 :base-def 95 :base-spc 40 :base-spd 35
                      :learnset '((1 . "Growl")(1 . "Bone Club")(18 . "Leer")(25 . "Earthquake")))
   (make-pkmn-species :name "Marowak"   :number 105 :type1 :ground :type2 nil
                      :base-hp 60 :base-atk 80 :base-def 110 :base-spc 50 :base-spd 45
                      :learnset '((1 . "Bone Club")(25 . "Earthquake")(33 . "Bonemerang")(41 . "Hyper Beam")))
   ;; ── Hitmonlee / Hitmonchan ────────────────────────────────────────────────
   (make-pkmn-species :name "Hitmonlee" :number 106 :type1 :fighting :type2 nil
                      :base-hp 50 :base-atk 120 :base-def 53 :base-spc 35 :base-spd 87
                      :learnset '((1 . "Double Kick")(1 . "Meditate")(33 . "Low Kick")(38 . "Seismic Toss")))
   (make-pkmn-species :name "Hitmonchan":number 107 :type1 :fighting :type2 nil
                      :base-hp 50 :base-atk 105 :base-def 79 :base-spc 35 :base-spd 76
                      :learnset '((1 . "Comet Punch")(33 . "Karate Chop")(38 . "Seismic Toss")(44 . "Hyper Beam")))
   ;; ── Lickitung ─────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Lickitung" :number 108 :type1 :normal :type2 nil
                      :base-hp 90 :base-atk 55 :base-def 75 :base-spc 60 :base-spd 30
                      :learnset '((1 . "Pound")(1 . "Lick")(7 . "Body Slam")(15 . "Slam")))
   ;; ── Koffing / Weezing ─────────────────────────────────────────────────────
   (make-pkmn-species :name "Koffing"   :number 109 :type1 :poison :type2 nil
                      :base-hp 40 :base-atk 65 :base-def 95 :base-spc 60 :base-spd 35
                      :learnset '((1 . "Pound")(1 . "Tackle")(32 . "Acid")(40 . "Toxic")))
   (make-pkmn-species :name "Weezing"   :number 110 :type1 :poison :type2 nil
                      :base-hp 65 :base-atk 90 :base-def 120 :base-spc 85 :base-spd 60
                      :learnset '((1 . "Pound")(40 . "Acid")(48 . "Toxic")(53 . "Hyper Beam")))
   ;; ── Rhyhorn / Rhydon ──────────────────────────────────────────────────────
   (make-pkmn-species :name "Rhyhorn"   :number 111 :type1 :ground :type2 :rock
                      :base-hp 80 :base-atk 85 :base-def 95 :base-spc 30 :base-spd 25
                      :learnset '((1 . "Horn Attack")(30 . "Leer")(35 . "Earthquake")(48 . "Rock Slide")))
   (make-pkmn-species :name "Rhydon"    :number 112 :type1 :ground :type2 :rock
                      :base-hp 105 :base-atk 130 :base-def 120 :base-spc 45 :base-spd 40
                      :learnset '((1 . "Horn Attack")(35 . "Earthquake")(48 . "Rock Slide")(58 . "Hyper Beam")))
   ;; ── Chansey ───────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Chansey"   :number 113 :type1 :normal :type2 nil
                      :base-hp 250 :base-atk 5 :base-def 5 :base-spc 105 :base-spd 50
                      :learnset '((1 . "Pound")(1 . "Growl")(23 . "Sing")(33 . "Egg Bomb")))
   ;; ── Tangela ───────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Tangela"   :number 114 :type1 :grass :type2 nil
                      :base-hp 65 :base-atk 55 :base-def 115 :base-spc 100 :base-spd 60
                      :learnset '((1 . "Bind")(29 . "Vine Whip")(32 . "Razor Leaf")(37 . "Solar Beam")))
   ;; ── Kangaskhan ────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Kangaskhan":number 115 :type1 :normal :type2 nil
                      :base-hp 105 :base-atk 95 :base-def 80 :base-spc 40 :base-spd 90
                      :learnset '((1 . "Pound")(1 . "Growl")(26 . "Body Slam")(32 . "Hyper Beam")))
   ;; ── Horsea / Seadra ───────────────────────────────────────────────────────
   (make-pkmn-species :name "Horsea"    :number 116 :type1 :water :type2 nil
                      :base-hp 30 :base-atk 40 :base-def 70 :base-spc 70 :base-spd 60
                      :learnset '((1 . "Bubble")(19 . "Bubblebeam")(24 . "Surf")(30 . "Hydro Pump")))
   (make-pkmn-species :name "Seadra"    :number 117 :type1 :water :type2 nil
                      :base-hp 55 :base-atk 65 :base-def 95 :base-spc 95 :base-spd 85
                      :learnset '((1 . "Bubblebeam")(32 . "Surf")(41 . "Hydro Pump")(48 . "Hyper Beam")))
   ;; ── Goldeen / Seaking ─────────────────────────────────────────────────────
   (make-pkmn-species :name "Goldeen"   :number 118 :type1 :water :type2 nil
                      :base-hp 45 :base-atk 67 :base-def 60 :base-spc 50 :base-spd 63
                      :learnset '((1 . "Peck")(1 . "Tail Whip")(19 . "Surf")(24 . "Horn Drill")))
   (make-pkmn-species :name "Seaking"   :number 119 :type1 :water :type2 nil
                      :base-hp 80 :base-atk 92 :base-def 65 :base-spc 80 :base-spd 68
                      :learnset '((1 . "Peck")(27 . "Surf")(40 . "Hyper Beam")(48 . "Horn Drill")))
   ;; ── Staryu / Starmie ──────────────────────────────────────────────────────
   (make-pkmn-species :name "Staryu"    :number 120 :type1 :water :type2 nil
                      :base-hp 30 :base-atk 45 :base-def 55 :base-spc 70 :base-spd 85
                      :learnset '((1 . "Tackle")(1 . "Water Gun")(17 . "Bubblebeam")(22 . "Surf")))
   (make-pkmn-species :name "Starmie"   :number 121 :type1 :water :type2 :psychic
                      :base-hp 60 :base-atk 75 :base-def 85 :base-spc 100 :base-spd 115
                      :learnset '((1 . "Water Gun")(1 . "Bubblebeam")(1 . "Surf")(1 . "Psychic")))
   ;; ── Mr. Mime ──────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Mr. Mime"  :number 122 :type1 :psychic :type2 nil
                      :base-hp 40 :base-atk 45 :base-def 65 :base-spc 100 :base-spd 90
                      :learnset '((1 . "Confusion")(1 . "Barrier")(23 . "Psybeam")(33 . "Psychic")))
   ;; ── Scyther ───────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Scyther"   :number 123 :type1 :bug  :type2 :flying
                      :base-hp 70 :base-atk 110 :base-def 80 :base-spc 55 :base-spd 105
                      :learnset '((1 . "Quick Attack")(17 . "Leer")(20 . "Wing Attack")(32 . "Slash")))
   ;; ── Jynx ──────────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Jynx"      :number 124 :type1 :ice   :type2 :psychic
                      :base-hp 65 :base-atk 50 :base-def 35 :base-spc 95 :base-spd 95
                      :learnset '((1 . "Pound")(1 . "Sing")(18 . "Ice Beam")(26 . "Blizzard")))
   ;; ── Electabuzz ────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Electabuzz":number 125 :type1 :electric :type2 nil
                      :base-hp 65 :base-atk 83 :base-def 57 :base-spc 95 :base-spd 105
                      :learnset '((1 . "Thunder Shock")(34 . "Thunderbolt")(37 . "Thunder Wave")(42 . "Thunder")))
   ;; ── Magmar ────────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Magmar"    :number 126 :type1 :fire  :type2 nil
                      :base-hp 65 :base-atk 95 :base-def 57 :base-spc 85 :base-spd 93
                      :learnset '((1 . "Ember")(36 . "Flamethrower")(39 . "Fire Blast")(42 . "Hyper Beam")))
   ;; ── Pinsir ────────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Pinsir"    :number 127 :type1 :bug   :type2 nil
                      :base-hp 65 :base-atk 125 :base-def 100 :base-spc 55 :base-spd 85
                      :learnset '((1 . "Vicegrip")(1 . "Bind")(25 . "Seismic Toss")(40 . "Hyper Beam")))
   ;; ── Tauros ────────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Tauros"    :number 128 :type1 :normal :type2 nil
                      :base-hp 75 :base-atk 100 :base-def 95 :base-spc 70 :base-spd 110
                      :learnset '((1 . "Tackle")(21 . "Leer")(28 . "Body Slam")(35 . "Hyper Beam")))
   ;; ── Magikarp / Gyarados ───────────────────────────────────────────────────
   (make-pkmn-species :name "Magikarp"  :number 129 :type1 :water :type2 nil
                      :base-hp 20 :base-atk 10 :base-def 55 :base-spc 20 :base-spd 80
                      :learnset '((1 . "Splash")(15 . "Tackle")))
   (make-pkmn-species :name "Gyarados"  :number 130 :type1 :water :type2 :flying
                      :base-hp 95 :base-atk 125 :base-def 79 :base-spc 100 :base-spd 81
                      :learnset '((1 . "Surf")(1 . "Body Slam")(1 . "Bite")(1 . "Hyper Beam")))
   ;; ── Lapras ────────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Lapras"    :number 131 :type1 :water :type2 :ice
                      :base-hp 130 :base-atk 85 :base-def 80 :base-spc 95 :base-spd 60
                      :learnset '((1 . "Water Gun")(21 . "Ice Beam")(25 . "Blizzard")(31 . "Surf")))
   ;; ── Ditto ─────────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Ditto"     :number 132 :type1 :normal :type2 nil
                      :base-hp 48 :base-atk 48 :base-def 48 :base-spc 48 :base-spd 48
                      :learnset '((1 . "Transform")))
   ;; ── Eevee evolutions ──────────────────────────────────────────────────────
   (make-pkmn-species :name "Eevee"     :number 133 :type1 :normal :type2 nil
                      :base-hp 55 :base-atk 55 :base-def 50 :base-spc 65 :base-spd 55
                      :learnset '((1 . "Tackle")(1 . "Tail Whip")(27 . "Quick Attack")(31 . "Body Slam")))
   (make-pkmn-species :name "Vaporeon"  :number 134 :type1 :water :type2 nil
                      :base-hp 130 :base-atk 65 :base-def 60 :base-spc 110 :base-spd 65
                      :learnset '((1 . "Tackle")(1 . "Water Gun")(36 . "Surf")(42 . "Hydro Pump")))
   (make-pkmn-species :name "Jolteon"   :number 135 :type1 :electric :type2 nil
                      :base-hp 65 :base-atk 65 :base-def 60 :base-spc 110 :base-spd 130
                      :learnset '((1 . "Tackle")(1 . "Thunder Shock")(36 . "Thunderbolt")(42 . "Thunder")))
   (make-pkmn-species :name "Flareon"   :number 136 :type1 :fire :type2 nil
                      :base-hp 65 :base-atk 130 :base-def 60 :base-spc 110 :base-spd 65
                      :learnset '((1 . "Tackle")(1 . "Ember")(36 . "Flamethrower")(42 . "Fire Blast")))
   ;; ── Porygon ───────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Porygon"   :number 137 :type1 :normal :type2 nil
                      :base-hp 65 :base-atk 60 :base-def 70 :base-spc 75 :base-spd 40
                      :learnset '((1 . "Tackle")(1 . "Sharpen")(1 . "Psybeam")(23 . "Tri Attack")))
   ;; ── Omanyte / Omastar ─────────────────────────────────────────────────────
   (make-pkmn-species :name "Omanyte"   :number 138 :type1 :rock  :type2 :water
                      :base-hp 35 :base-atk 40 :base-def 100 :base-spc 90 :base-spd 35
                      :learnset '((1 . "Water Gun")(34 . "Bubblebeam")(39 . "Surf")(46 . "Hydro Pump")))
   (make-pkmn-species :name "Omastar"   :number 139 :type1 :rock  :type2 :water
                      :base-hp 70 :base-atk 60 :base-def 125 :base-spc 115 :base-spd 55
                      :learnset '((1 . "Water Gun")(39 . "Surf")(46 . "Hydro Pump")(53 . "Hyper Beam")))
   ;; ── Kabuto / Kabutops ─────────────────────────────────────────────────────
   (make-pkmn-species :name "Kabuto"    :number 140 :type1 :rock  :type2 :water
                      :base-hp 30 :base-atk 80 :base-def 90 :base-spc 55 :base-spd 55
                      :learnset '((1 . "Scratch")(34 . "Bubblebeam")(39 . "Surf")(46 . "Hydro Pump")))
   (make-pkmn-species :name "Kabutops"  :number 141 :type1 :rock  :type2 :water
                      :base-hp 60 :base-atk 115 :base-def 105 :base-spc 70 :base-spd 80
                      :learnset '((1 . "Scratch")(46 . "Surf")(52 . "Hydro Pump")(59 . "Hyper Beam")))
   ;; ── Aerodactyl ────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Aerodactyl":number 142 :type1 :rock  :type2 :flying
                      :base-hp 80 :base-atk 105 :base-def 65 :base-spc 60 :base-spd 130
                      :learnset '((1 . "Wing Attack")(33 . "Hyper Beam")(38 . "Agility")(48 . "Rock Slide")))
   ;; ── Snorlax ───────────────────────────────────────────────────────────────
   (make-pkmn-species :name "Snorlax"   :number 143 :type1 :normal :type2 nil
                      :base-hp 160 :base-atk 110 :base-def 65 :base-spc 65 :base-spd 30
                      :learnset '((1 . "Tackle")(1 . "Body Slam")(35 . "Hyper Beam")(41 . "Amnesia")))
   ;; ── Articuno / Zapdos / Moltres ───────────────────────────────────────────
   (make-pkmn-species :name "Articuno"  :number 144 :type1 :ice   :type2 :flying
                      :base-hp 90 :base-atk 85 :base-def 100 :base-spc 125 :base-spd 85
                      :learnset '((1 . "Ice Beam")(51 . "Blizzard")(55 . "Hyper Beam")(1 . "Agility")))
   (make-pkmn-species :name "Zapdos"    :number 145 :type1 :electric :type2 :flying
                      :base-hp 90 :base-atk 90 :base-def 85 :base-spc 125 :base-spd 100
                      :learnset '((1 . "Thunderbolt")(51 . "Thunder")(55 . "Hyper Beam")(1 . "Agility")))
   (make-pkmn-species :name "Moltres"   :number 146 :type1 :fire  :type2 :flying
                      :base-hp 90 :base-atk 100 :base-def 90 :base-spc 125 :base-spd 90
                      :learnset '((1 . "Fire Blast")(51 . "Flamethrower")(55 . "Hyper Beam")(1 . "Agility")))
   ;; ── Dratini / Dragonair / Dragonite ───────────────────────────────────────
   (make-pkmn-species :name "Dratini"   :number 147 :type1 :dragon :type2 nil
                      :base-hp 41 :base-atk 64 :base-def 45 :base-spc 50 :base-spd 50
                      :learnset '((1 . "Wrap")(1 . "Leer")(10 . "Thunder Wave")(20 . "Slam")))
   (make-pkmn-species :name "Dragonair" :number 148 :type1 :dragon :type2 nil
                      :base-hp 61 :base-atk 84 :base-def 65 :base-spc 70 :base-spd 70
                      :learnset '((1 . "Wrap")(1 . "Slam")(35 . "Hyper Beam")(38 . "Agility")))
   (make-pkmn-species :name "Dragonite" :number 149 :type1 :dragon :type2 :flying
                      :base-hp 91 :base-atk 134 :base-def 95 :base-spc 100 :base-spd 80
                      :learnset '((1 . "Slam")(1 . "Hyper Beam")(1 . "Agility")(1 . "Blizzard")))
   ;; ── Legendary trio ────────────────────────────────────────────────────────
   (make-pkmn-species :name "Mewtwo"    :number 150 :type1 :psychic :type2 nil
                      :base-hp 106 :base-atk 110 :base-def 90 :base-spc 154 :base-spd 130
                      :learnset '((1 . "Confusion")(1 . "Psychic")(63 . "Recover")(66 . "Hyper Beam")))
   (make-pkmn-species :name "Mew"       :number 151 :type1 :psychic :type2 nil
                      :base-hp 100 :base-atk 100 :base-def 100 :base-spc 100 :base-spd 100
                      :learnset '((1 . "Pound")(1 . "Psychic")(1 . "Hyper Beam")(1 . "Blizzard")))))

(defun find-pokemon (name)
  "Look up a species by name string. Returns nil if not found."
  (find name *gen1-yellow-roster* :key #'species-name :test #'string-equal))

;;;; ── Badge-battle party presets ────────────────────────────────────────────
;;; Each entry: (species-name level move1 move2 move3 move4)

(defun make-battle-mon (species-name level &rest move-names)
  "Construct a battle-ready plist from catalog data and a level."
  (let* ((species (or (find-pokemon species-name)
                      (error "Unknown species: ~S" species-name)))
         (max-hp  (max 1 (floor (+ (* 2 (species-base-hp species) level) level 10) 100)))
         (moves   (remove nil (mapcar #'find-move move-names))))
    (list :name      (species-name species)
          :species   species
          :level     level
          :hp        max-hp
          :max-hp    max-hp
          :type1     (species-type1 species)
          :type2     (species-type2 species)
          :atk       (floor (+ (* 2 (species-base-atk species) level) 5) 100)
          :def       (floor (+ (* 2 (species-base-def species) level) 5) 100)
          :spc       (floor (+ (* 2 (species-base-spc species) level) 5) 100)
          :spd       (floor (+ (* 2 (species-base-spd species) level) 5) 100)
          :moves     moves
          :status    nil
          :stages    (list :atk 0 :def 0 :spc 0 :spd 0)
          :items     nil)))

;;; ── Gym leader parties (Yellow version) ─────────────────────────────────────

(defun brock-party ()
  "Pewter City — Brock, Rock/Ground specialist."
  (list (make-battle-mon "Geodude"  12 "Tackle" "Defense Curl" "Rock Throw")
        (make-battle-mon "Onix"     14 "Tackle" "Screech" "Rock Throw" "Bind")))

(defun misty-party ()
  "Cerulean City — Misty, Water specialist."
  (list (make-battle-mon "Staryu"   18 "Tackle" "Water Gun" "Bubblebeam")
        (make-battle-mon "Starmie"  21 "Bubblebeam" "Water Gun" "Surf" "Psychic")))

(defun lt-surge-party ()
  "Vermilion City — Lt. Surge, Electric specialist."
  (list (make-battle-mon "Raichu"   28 "Thunderbolt" "Thunder Wave" "Quick Attack" "Body Slam")))

(defun erika-party ()
  "Celadon City — Erika, Grass specialist."
  (list (make-battle-mon "Victreebel" 29 "Razor Leaf" "Acid" "Solar Beam" "Toxic")
        (make-battle-mon "Tangela"    24 "Bind" "Vine Whip" "Razor Leaf")
        (make-battle-mon "Vileplume"  29 "Acid" "Petal Dance" "Solar Beam" "Toxic")))

(defun koga-party ()
  "Fuchsia City — Koga, Poison specialist."
  (list (make-battle-mon "Koffing"   37 "Tackle" "Acid" "Toxic" "Smokescreen")
        (make-battle-mon "Muk"       39 "Pound" "Acid" "Toxic" "Body Slam")
        (make-battle-mon "Koffing"   37 "Tackle" "Acid" "Toxic" "Smokescreen")
        (make-battle-mon "Weezing"   43 "Pound" "Acid" "Toxic" "Hyper Beam")))

(defun sabrina-party ()
  "Saffron City — Sabrina, Psychic specialist."
  (list (make-battle-mon "Kadabra"   38 "Confusion" "Psybeam" "Recover" "Psychic")
        (make-battle-mon "Mr. Mime"  37 "Confusion" "Psybeam" "Barrier" "Psychic")
        (make-battle-mon "Venomoth"  38 "Psybeam" "Psychic" "Leech Life")
        (make-battle-mon "Alakazam"  43 "Confusion" "Psybeam" "Recover" "Psychic")))

(defun blaine-party ()
  "Cinnabar Island — Blaine, Fire specialist."
  (list (make-battle-mon "Growlithe" 42 "Ember" "Flamethrower" "Bite")
        (make-battle-mon "Ponyta"    40 "Ember" "Flamethrower" "Fire Blast")
        (make-battle-mon "Rapidash"  42 "Ember" "Flamethrower" "Fire Blast")
        (make-battle-mon "Arcanine"  47 "Ember" "Flamethrower" "Fire Blast" "Hyper Beam")))

(defun giovanni-party ()
  "Viridian City — Giovanni, Ground specialist."
  (list (make-battle-mon "Rhyhorn"   45 "Horn Attack" "Leer" "Earthquake" "Rock Slide")
        (make-battle-mon "Dugtrio"   42 "Scratch" "Dig" "Earthquake")
        (make-battle-mon "Nidoqueen" 44 "Tackle" "Earthquake" "Body Slam" "Toxic")
        (make-battle-mon "Nidoking"  45 "Tackle" "Earthquake" "Toxic" "Hyper Beam")
        (make-battle-mon "Rhydon"    50 "Horn Attack" "Earthquake" "Rock Slide" "Hyper Beam")))

;;; ── Starter ──────────────────────────────────────────────────────────────────

(defun starter-pikachu ()
  "Yellow's special starter — level 5 Pikachu."
  (make-battle-mon "Pikachu" 5 "Thunder Shock" "Growl"))
