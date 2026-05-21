;;;; catalog.lisp — Gen-I Yellow Pokédex as Prolog facts
;;;;
;;;; All data lives in the shared prolog-db returned by pokemon-logic:make-pokemon-kb.
;;;; This file defines:
;;;;   assert-catalog-facts — asserts pokemon/move/item/gym-party facts into a db
;;;;   Query API             — find-pokemon, find-move, find-item, make-battle-mon,
;;;;                           gym party accessors, *gen1-yellow-roster* compat list
;;;;
;;;; Prolog fact schemas:
;;;;   (pokemon   name num type1 type2 base-hp base-atk base-def base-spc base-spd)
;;;;   (learnset  name level move-name)
;;;;   (move      name type category power accuracy pp effect)
;;;;   (item      name item-symbol description)
;;;;   (gym-party gym  slot species-name level move1 move2 move3 move4)

(named-readtables:in-readtable :standard)

(in-package #:pokemon-catalog)

;;;; ── Fact assertion ──────────────────────────────────────────────────────────

(defun assert-catalog-facts (db)
  "Assert all Gen-I Yellow catalog facts into DB (a pokemon-logic::prolog-db)."
  (flet ((pf (&rest fact)
           (pokemon-logic::db-assert db fact)))

    ;; ── Moves ─────────────────────────────────────────────────────────────────
    ;; (move name type category power accuracy pp effect)
    (pf 'move "Tackle"        :normal   :physical  35  95 35 nil)
    (pf 'move "Scratch"       :normal   :physical  40 100 35 nil)
    (pf 'move "Pound"         :normal   :physical  40 100 35 nil)
    (pf 'move "Quick Attack"  :normal   :physical  40 100 30 :always-first)
    (pf 'move "Body Slam"     :normal   :physical  85 100 15 :paralysis-30)
    (pf 'move "Hyper Beam"    :normal   :physical 150  90  5 :recharge)
    (pf 'move "Growl"         :normal   :physical   0 100 40 :lower-atk)
    (pf 'move "Tail Whip"     :normal   :physical   0 100 30 :lower-def)
    (pf 'move "Leer"          :normal   :physical   0 100 30 :lower-def)
    (pf 'move "Sing"          :normal   :physical   0  55 15 :sleep)
    (pf 'move "Slam"          :normal   :physical  80  75 20 nil)
    (pf 'move "Slash"         :normal   :physical  70 100 20 :high-crit)
    (pf 'move "Swords Dance"  :normal   :physical   0 100 30 :raise-atk-2)
    (pf 'move "Harden"        :normal   :physical   0 100 30 :raise-def)
    (pf 'move "Defense Curl"  :normal   :physical   0 100 40 :raise-def)
    (pf 'move "Bind"          :normal   :physical  15  75 20 :trapping)
    (pf 'move "Bide"          :normal   :physical   0 100 10 :bide)
    (pf 'move "Screech"       :normal   :physical   0  85 40 :lower-def-2)
    (pf 'move "Disable"       :normal   :physical   0  55 20 :disable)
    (pf 'move "Ember"         :fire     :special   40 100 25 :burn-10)
    (pf 'move "Flamethrower"  :fire     :special   95 100 15 :burn-10)
    (pf 'move "Fire Blast"    :fire     :special  120  85  5 :burn-30)
    (pf 'move "Water Gun"     :water    :special   40 100 25 nil)
    (pf 'move "Surf"          :water    :special   95 100 15 nil)
    (pf 'move "Hydro Pump"    :water    :special  120  80  5 nil)
    (pf 'move "Bubble"        :water    :special   20 100 30 :lower-spd-10)
    (pf 'move "Bubblebeam"    :water    :special   65 100 20 :lower-spd-33)
    (pf 'move "Withdraw"      :water    :physical   0 100 40 :raise-def)
    (pf 'move "Vine Whip"     :grass    :special   35 100 10 nil)
    (pf 'move "Razor Leaf"    :grass    :special   55  95 25 :high-crit)
    (pf 'move "Solar Beam"    :grass    :special  120 100 10 :charge-turn)
    (pf 'move "Petal Dance"   :grass    :special   70 100 20 :confuse-self)
    (pf 'move "Thunder Shock" :electric :special   40 100 30 :paralysis-10)
    (pf 'move "Thunderbolt"   :electric :special   95 100 15 :paralysis-10)
    (pf 'move "Thunder"       :electric :special  120  70 10 :paralysis-10)
    (pf 'move "Thunder Wave"  :electric :physical   0 100 20 :paralysis)
    (pf 'move "Ice Beam"      :ice      :special   95 100 10 :freeze-10)
    (pf 'move "Blizzard"      :ice      :special  120  90  5 :freeze-10)
    (pf 'move "Karate Chop"   :fighting :physical  50 100 25 :high-crit)
    (pf 'move "Low Kick"      :fighting :physical  50  90 20 :flinch-30)
    (pf 'move "Seismic Toss"  :fighting :physical   0 100 20 :level-damage)
    (pf 'move "Submission"    :fighting :physical  80  80 25 :recoil-25)
    (pf 'move "Poison Sting"  :poison   :physical  15 100 35 :poison-20)
    (pf 'move "Acid"          :poison   :special   40 100 30 :lower-def-33)
    (pf 'move "Toxic"         :poison   :physical   0  85 10 :bad-poison)
    (pf 'move "Earthquake"    :ground   :physical 100 100 10 nil)
    (pf 'move "Dig"           :ground   :physical 100 100 10 :charge-turn)
    (pf 'move "Gust"          :flying   :special   40 100 35 nil)
    (pf 'move "Wing Attack"   :flying   :physical  35 100 35 nil)
    (pf 'move "Agility"       :psychic  :physical   0 100 30 :raise-spd-2)
    (pf 'move "Confusion"     :psychic  :special   50 100 25 :confuse-10)
    (pf 'move "Psybeam"       :psychic  :special   65 100 20 :confuse-10)
    (pf 'move "Psychic"       :psychic  :special   90 100 10 :lower-spc-33)
    (pf 'move "Recover"       :psychic  :physical   0 100 20 :restore-half)
    (pf 'move "Barrier"       :psychic  :physical   0 100 30 :raise-def-2)
    (pf 'move "Amnesia"       :psychic  :physical   0 100 20 :raise-spc-2)
    (pf 'move "String Shot"   :bug      :physical   0  95 40 :lower-spd)
    (pf 'move "Leech Life"    :bug      :physical  20 100 15 :drain-half)
    (pf 'move "Pin Missile"   :bug      :physical  14  85 20 :multi-hit)
    (pf 'move "Rock Throw"    :rock     :physical  50  65 15 nil)
    (pf 'move "Rock Slide"    :rock     :physical  75  90 10 :flinch-30)
    (pf 'move "Lick"          :ghost    :physical  20 100 30 :paralysis-30)
    (pf 'move "Night Shade"   :ghost    :special    0 100 15 :level-damage)
    (pf 'move "Confuse Ray"   :ghost    :physical   0 100 10 :confuse)
    (pf 'move "Wrap"          :normal   :physical  15  85 20 :trapping)
    (pf 'move "Peck"          :flying   :physical  35 100 35 nil)
    (pf 'move "Fury Attack"   :normal   :physical  15  85 20 :multi-hit)
    (pf 'move "Stomp"         :normal   :physical  65 100 20 :flinch-30)
    (pf 'move "Horn Attack"   :normal   :physical  65 100 25 nil)
    (pf 'move "Horn Drill"    :normal   :physical   0  30  5 :ohko)
    (pf 'move "Double Kick"   :fighting :physical  30 100 30 :two-hit)
    (pf 'move "Meditate"      :psychic  :physical   0 100 40 :raise-atk)
    (pf 'move "Supersonic"    :normal   :physical   0  55 20 :confuse)
    (pf 'move "Spore"         :grass    :physical   0 100 15 :sleep)
    (pf 'move "Stun Spore"    :grass    :physical   0  75 30 :paralysis)
    (pf 'move "Poison Powder" :poison   :physical   0  75 35 :poison)
    (pf 'move "Absorb"        :grass    :special   20 100 25 :drain-half)
    (pf 'move "Bone Club"     :ground   :physical  65  85 20 :flinch-10)
    (pf 'move "Bonemerang"    :ground   :physical  50  90 10 :two-hit)
    (pf 'move "Teleport"      :psychic  :physical   0 100 20 :escape)
    (pf 'move "Comet Punch"   :normal   :physical  18  85 15 :multi-hit)
    (pf 'move "Headbutt"      :normal   :physical  70 100 15 :flinch-30)
    (pf 'move "Vicegrip"      :normal   :physical  55 100 30 nil)
    (pf 'move "Tri Attack"    :normal   :special   80 100 10 :tri-effect)
    (pf 'move "Super Fang"    :normal   :physical   0  90 10 :half-hp)
    (pf 'move "Smokescreen"   :normal   :physical   0 100 20 :lower-acc)
    (pf 'move "Transform"     :normal   :physical   0 100 10 :transform)
    (pf 'move "Splash"        :normal   :physical   0 100 40 nil)
    (pf 'move "Sharpen"       :normal   :physical   0 100 30 :raise-atk)
    (pf 'move "Focus Energy"  :normal   :physical   0 100 30 :crit-up)

    ;; ── Items ──────────────────────────────────────────────────────────────────
    ;; (item name symbol description)
    (pf 'item "Potion"       'potion       "Restores 20 HP")
    (pf 'item "Super Potion" 'super-potion "Restores 50 HP")
    (pf 'item "Hyper Potion" 'hyper-potion "Restores 200 HP")
    (pf 'item "Max Potion"   'max-potion   "Fully restores HP")
    (pf 'item "Full Restore" 'full-restore "Fully restores HP and cures status")
    (pf 'item "Revive"       'revive       "Revives to half HP")
    (pf 'item "Max Revive"   'max-revive   "Revives to full HP")
    (pf 'item "Antidote"     'antidote     "Cures poison")
    (pf 'item "Burn Heal"    'burn-heal    "Cures burn")
    (pf 'item "Ice Heal"     'ice-heal     "Cures freeze")
    (pf 'item "Awakening"    'awakening    "Cures sleep")
    (pf 'item "Parlyz Heal"  'parlyz-heal  "Cures paralysis")
    (pf 'item "Full Heal"    'full-heal    "Cures any status")
    (pf 'item "X Attack"     'x-attack     "Raises Attack 1 stage")
    (pf 'item "X Defense"    'x-defense    "Raises Defense 1 stage")
    (pf 'item "X Speed"      'x-speed      "Raises Speed 1 stage")
    (pf 'item "X Special"    'x-special    "Raises Special 1 stage")
    (pf 'item "Dire Hit"     'dire-hit     "Raises critical-hit ratio")
    (pf 'item "Guard Spec."  'guard-spec   "Prevents stat reduction")

    ;; ── Pokémon — (pokemon name num type1 type2 hp atk def spc spd) ───────────
    ;; type2 = :none when single-typed
    (dolist (r '(
      ("Bulbasaur"  1  :grass    :poison  45  49  49  65  45
       ("Tackle" "Growl" "Vine Whip" "Razor Leaf"))
      ("Ivysaur"   2  :grass    :poison  60  62  63  80  60
       ("Vine Whip" "Razor Leaf" "Toxic" "Solar Beam"))
      ("Venusaur"  3  :grass    :poison  80  82  83 100  80
       ("Vine Whip" "Solar Beam" "Razor Leaf" "Hyper Beam"))
      ("Charmander" 4 :fire     :none    39  52  43  50  65
       ("Scratch" "Growl" "Ember" "Slash"))
      ("Charmeleon" 5 :fire     :none    58  64  58  65  80
       ("Scratch" "Ember" "Flamethrower" "Fire Blast"))
      ("Charizard"  6 :fire     :flying  78  84  78  85 100
       ("Ember" "Flamethrower" "Fire Blast" "Hyper Beam"))
      ("Squirtle"   7 :water    :none    44  48  65  50  43
       ("Tackle" "Tail Whip" "Bubble" "Water Gun"))
      ("Wartortle"  8 :water    :none    59  63  80  65  58
       ("Water Gun" "Withdraw" "Surf" "Hydro Pump"))
      ("Blastoise"  9 :water    :none    79  83 100  85  78
       ("Water Gun" "Surf" "Hydro Pump" "Hyper Beam"))
      ("Caterpie"  10 :bug      :none    45  30  35  20  45
       ("Tackle" "String Shot"))
      ("Metapod"   11 :bug      :none    50  20  55  25  30
       ("Harden"))
      ("Butterfree" 12 :bug     :flying  60  45  50  80  70
       ("Confusion" "Psybeam" "Stun Spore" "Psychic"))
      ("Weedle"    13 :bug      :poison  40  35  30  20  50
       ("Poison Sting" "String Shot"))
      ("Kakuna"    14 :bug      :poison  45  25  50  25  35
       ("Harden"))
      ("Beedrill"  15 :bug      :poison  65  80  40  45  75
       ("Poison Sting" "Toxic" "Pin Missile" "Agility"))
      ("Pidgey"    16 :normal   :flying  40  45  40  35  56
       ("Gust" "Tackle" "Wing Attack" "Quick Attack"))
      ("Pidgeotto" 17 :normal   :flying  63  60  55  50  71
       ("Gust" "Wing Attack" "Agility" "Hyper Beam"))
      ("Pidgeot"   18 :normal   :flying  83  80  75  70  91
       ("Wing Attack" "Agility" "Hyper Beam" "Gust"))
      ("Rattata"   19 :normal   :none    30  56  35  25  72
       ("Tackle" "Tail Whip" "Quick Attack" "Body Slam"))
      ("Raticate"  20 :normal   :none    55  81  60  50  97
       ("Quick Attack" "Body Slam" "Hyper Beam" "Super Fang"))
      ("Spearow"   21 :normal   :flying  40  60  30  31  70
       ("Peck" "Growl" "Leer" "Fury Attack"))
      ("Fearow"    22 :normal   :flying  65  90  65  61 100
       ("Peck" "Leer" "Fury Attack" "Hyper Beam"))
      ("Ekans"     23 :poison   :none    35  60  44  40  55
       ("Wrap" "Leer" "Poison Sting" "Acid"))
      ("Arbok"     24 :poison   :none    60  85  69  65  80
       ("Poison Sting" "Acid" "Toxic" "Hyper Beam"))
      ("Pikachu"   25 :electric :none    35  55  30  50  90
       ("Thunder Shock" "Growl" "Thunderbolt" "Thunder Wave"))
      ("Raichu"    26 :electric :none    60  90  55  90 110
       ("Thunderbolt" "Thunder Wave" "Quick Attack" "Thunder"))
      ("Sandshrew" 27 :ground   :none    50  75  85  30  40
       ("Scratch" "Sand Attack" "Dig" "Earthquake"))
      ("Sandslash" 28 :ground   :none    75 100 110  55  65
       ("Scratch" "Dig" "Earthquake" "Slash"))
      ("Nidoran-F" 29 :poison   :none    55  47  52  40  41
       ("Growl" "Tackle" "Poison Sting" "Body Slam"))
      ("Nidorina"  30 :poison   :none    70  62  67  55  56
       ("Tackle" "Body Slam" "Toxic" "Blizzard"))
      ("Nidoqueen" 31 :poison   :ground  90  82  87  75  76
       ("Tackle" "Earthquake" "Body Slam" "Hyper Beam"))
      ("Nidoran-M" 32 :poison   :none    46  57  40  40  50
       ("Leer" "Tackle" "Poison Sting" "Focus Energy"))
      ("Nidorino"  33 :poison   :none    61  72  57  55  65
       ("Tackle" "Focus Energy" "Toxic" "Blizzard"))
      ("Nidoking"  34 :poison   :ground  81  92  77  75  85
       ("Tackle" "Earthquake" "Toxic" "Hyper Beam"))
      ("Clefairy"  35 :normal   :none    70  45  48  60  35
       ("Pound" "Growl" "Sing" "Body Slam"))
      ("Clefable"  36 :normal   :none    95  70  73  85  60
       ("Pound" "Sing" "Body Slam" "Hyper Beam"))
      ("Vulpix"    37 :fire     :none    38  41  40  65  65
       ("Ember" "Quick Attack" "Flamethrower" "Fire Blast"))
      ("Ninetales" 38 :fire     :none    73  76  75 100 100
       ("Ember" "Quick Attack" "Flamethrower" "Fire Blast"))
      ("Jigglypuff" 39 :normal  :none   115  45  20  25  20
       ("Pound" "Sing" "Body Slam" "Slam"))
      ("Wigglytuff" 40 :normal  :none   140  70  45  50  45
       ("Pound" "Sing" "Body Slam" "Hyper Beam"))
      ("Zubat"     41 :poison   :flying  40  45  35  40  55
       ("Leech Life" "Supersonic" "Wing Attack" "Toxic"))
      ("Golbat"    42 :poison   :flying  75  80  70  75  90
       ("Leech Life" "Wing Attack" "Toxic" "Hyper Beam"))
      ("Oddish"    43 :grass    :poison  45  50  55  75  30
       ("Absorb" "Acid" "Poison Powder" "Solar Beam"))
      ("Gloom"     44 :grass    :poison  60  65  70  85  40
       ("Acid" "Solar Beam" "Toxic" "Petal Dance"))
      ("Vileplume" 45 :grass    :poison  75  80  85 100  50
       ("Acid" "Solar Beam" "Toxic" "Petal Dance"))
      ("Paras"     46 :bug      :grass   35  70  55  55  25
       ("Scratch" "Stun Spore" "Acid" "Slash"))
      ("Parasect"  47 :bug      :grass   60  95  80  80  30
       ("Scratch" "Slash" "Spore" "Leech Life"))
      ("Venonat"   48 :bug      :poison  60  55  50  40  45
       ("Tackle" "Disable" "Psybeam" "Psychic"))
      ("Venomoth"  49 :bug      :poison  70  65  60  90  90
       ("Psybeam" "Psychic" "Leech Life" "Hyper Beam"))
      ("Diglett"   50 :ground   :none    10  55  25  45  95
       ("Scratch" "Growl" "Dig" "Earthquake"))
      ("Dugtrio"   51 :ground   :none    35  80  50  70 120
       ("Scratch" "Dig" "Earthquake" "Slash"))
      ("Meowth"    52 :normal   :none    40  45  35  40  90
       ("Scratch" "Growl" "Bite" "Screech"))
      ("Persian"   53 :normal   :none    65  70  60  65 115
       ("Scratch" "Growl" "Slash" "Hyper Beam"))
      ("Psyduck"   54 :water    :none    50  52  48  50  55
       ("Scratch" "Tail Whip" "Psybeam" "Confusion"))
      ("Golduck"   55 :water    :none    80  82  78  80  85
       ("Scratch" "Psybeam" "Surf" "Hyper Beam"))
      ("Mankey"    56 :fighting :none    40  80  35  35  70
       ("Scratch" "Leer" "Karate Chop" "Seismic Toss"))
      ("Primeape"  57 :fighting :none    65 105  60  60  95
       ("Karate Chop" "Seismic Toss" "Low Kick" "Hyper Beam"))
      ("Growlithe" 58 :fire     :none    55  70  45  50  60
       ("Ember" "Bite" "Flamethrower" "Fire Blast"))
      ("Arcanine"  59 :fire     :none    90 110  80  80  95
       ("Ember" "Flamethrower" "Fire Blast" "Hyper Beam"))
      ("Poliwag"   60 :water    :none    40  50  40  40  90
       ("Bubble" "Bubblebeam" "Surf" "Body Slam"))
      ("Poliwhirl" 61 :water    :none    65  65  65  50  90
       ("Bubblebeam" "Body Slam" "Surf" "Amnesia"))
      ("Poliwrath" 62 :water    :fighting 90 85  95  70  70
       ("Body Slam" "Surf" "Seismic Toss" "Hyper Beam"))
      ("Abra"      63 :psychic  :none    25  20  15 105  90
       ("Teleport"))
      ("Kadabra"   64 :psychic  :none    40  35  30 120 105
       ("Confusion" "Psybeam" "Recover" "Psychic"))
      ("Alakazam"  65 :psychic  :none    55  50  45 135 120
       ("Confusion" "Psychic" "Recover" "Hyper Beam"))
      ("Machop"    66 :fighting :none    70  80  50  35  35
       ("Karate Chop" "Low Kick" "Seismic Toss" "Submission"))
      ("Machoke"   67 :fighting :none    80 100  70  50  45
       ("Karate Chop" "Seismic Toss" "Submission" "Hyper Beam"))
      ("Machamp"   68 :fighting :none    90 130  80  65  55
       ("Karate Chop" "Seismic Toss" "Submission" "Hyper Beam"))
      ("Bellsprout" 69 :grass   :poison  50  75  35  70  40
       ("Vine Whip" "Acid" "Razor Leaf" "Solar Beam"))
      ("Weepinbell" 70 :grass   :poison  65  90  50  85  55
       ("Vine Whip" "Solar Beam" "Toxic" "Razor Leaf"))
      ("Victreebel" 71 :grass   :poison  80 105  65 100  70
       ("Vine Whip" "Solar Beam" "Razor Leaf" "Hyper Beam"))
      ("Tentacool" 72 :water    :poison  40  40  35 100  70
       ("Acid" "Poison Sting" "Bubblebeam" "Surf"))
      ("Tentacruel" 73 :water   :poison  80  70  65 120 100
       ("Acid" "Bubblebeam" "Surf" "Hyper Beam"))
      ("Geodude"   74 :rock     :ground  40  80 100  30  20
       ("Tackle" "Defense Curl" "Rock Throw" "Earthquake"))
      ("Graveler"  75 :rock     :ground  55  95 115  45  35
       ("Tackle" "Rock Throw" "Earthquake" "Rock Slide"))
      ("Golem"     76 :rock     :ground  80 110 130  55  45
       ("Tackle" "Earthquake" "Rock Slide" "Hyper Beam"))
      ("Ponyta"    77 :fire     :none    50  85  55  65  90
       ("Ember" "Flamethrower" "Fire Blast" "Stomp"))
      ("Rapidash"  78 :fire     :none    65 100  70  80 105
       ("Ember" "Flamethrower" "Fire Blast" "Hyper Beam"))
      ("Slowpoke"  79 :water    :psychic 90  65  65  40  15
       ("Tackle" "Confusion" "Water Gun" "Psychic"))
      ("Slowbro"   80 :water    :psychic 95  75 110  80  30
       ("Confusion" "Psychic" "Surf" "Hyper Beam"))
      ("Magnemite" 81 :electric :none    25  35  70  95  45
       ("Thunder Shock" "Thunderbolt" "Thunder Wave" "Thunder"))
      ("Magneton"  82 :electric :none    50  60  95 120  70
       ("Thunder Shock" "Thunderbolt" "Thunder" "Hyper Beam"))
      ("Farfetch'd" 83 :normal  :flying  52  65  55  58  60
       ("Peck" "Leer" "Gust" "Slash"))
      ("Doduo"     84 :normal   :flying  35  85  45  35  75
       ("Peck" "Growl" "Fury Attack" "Hyper Beam"))
      ("Dodrio"    85 :normal   :flying  60 110  70  60 100
       ("Peck" "Fury Attack" "Hyper Beam" "Agility"))
      ("Seel"      86 :water    :none    65  45  55  70  45
       ("Headbutt" "Ice Beam" "Blizzard" "Surf"))
      ("Dewgong"   87 :water    :ice     90  70  80  95  70
       ("Headbutt" "Ice Beam" "Blizzard" "Surf"))
      ("Grimer"    88 :poison   :none    80  80  50  40  25
       ("Pound" "Disable" "Acid" "Toxic"))
      ("Muk"       89 :poison   :none   105 105  75  65  50
       ("Pound" "Acid" "Toxic" "Hyper Beam"))
      ("Shellder"  90 :water    :none    30  65 100  45  40
       ("Tackle" "Withdraw" "Ice Beam" "Blizzard"))
      ("Cloyster"  91 :water    :ice     50  95 180  85  70
       ("Surf" "Ice Beam" "Blizzard" "Hyper Beam"))
      ("Gastly"    92 :ghost    :poison  30  35  30 100  80
       ("Lick" "Night Shade" "Confuse Ray" "Psychic"))
      ("Haunter"   93 :ghost    :poison  45  50  45 115  95
       ("Lick" "Night Shade" "Confuse Ray" "Psychic"))
      ("Gengar"    94 :ghost    :poison  60  65  60 130 110
       ("Lick" "Night Shade" "Confuse Ray" "Hyper Beam"))
      ("Onix"      95 :rock     :ground  35  45 160  30  70
       ("Tackle" "Screech" "Rock Throw" "Earthquake"))
      ("Drowzee"   96 :psychic  :none    60  48  45  90  42
       ("Pound" "Disable" "Confusion" "Psychic"))
      ("Hypno"     97 :psychic  :none    85  73  70 115  67
       ("Confusion" "Psychic" "Disable" "Hyper Beam"))
      ("Krabby"    98 :water    :none    30 105  90  25  50
       ("Bubble" "Vicegrip" "Surf" "Slash"))
      ("Kingler"   99 :water    :none    55 130 115  50  75
       ("Bubble" "Surf" "Slash" "Hyper Beam"))
      ("Voltorb"  100 :electric :none    40  30  50  55 100
       ("Tackle" "Thunderbolt" "Thunder Wave" "Thunder"))
      ("Electrode" 101 :electric :none   60  50  70  80 140
       ("Thunderbolt" "Thunder Wave" "Thunder" "Hyper Beam"))
      ("Exeggcute" 102 :grass   :psychic 60  40  80  60  40
       ("Absorb" "Confusion" "Solar Beam" "Psychic"))
      ("Exeggutor" 103 :grass   :psychic 95  95  85 125  55
       ("Confusion" "Solar Beam" "Psychic" "Hyper Beam"))
      ("Cubone"   104 :ground   :none    50  50  95  40  35
       ("Growl" "Bone Club" "Leer" "Earthquake"))
      ("Marowak"  105 :ground   :none    60  80 110  50  45
       ("Bone Club" "Earthquake" "Bonemerang" "Hyper Beam"))
      ("Hitmonlee" 106 :fighting :none   50 120  53  35  87
       ("Double Kick" "Meditate" "Low Kick" "Seismic Toss"))
      ("Hitmonchan" 107 :fighting :none  50 105  79  35  76
       ("Comet Punch" "Karate Chop" "Seismic Toss" "Hyper Beam"))
      ("Lickitung" 108 :normal  :none    90  55  75  60  30
       ("Pound" "Lick" "Body Slam" "Slam"))
      ("Koffing"  109 :poison   :none    40  65  95  60  35
       ("Pound" "Tackle" "Acid" "Toxic"))
      ("Weezing"  110 :poison   :none    65  90 120  85  60
       ("Pound" "Acid" "Toxic" "Hyper Beam"))
      ("Rhyhorn"  111 :ground   :rock    80  85  95  30  25
       ("Horn Attack" "Leer" "Earthquake" "Rock Slide"))
      ("Rhydon"   112 :ground   :rock   105 130 120  45  40
       ("Horn Attack" "Earthquake" "Rock Slide" "Hyper Beam"))
      ("Chansey"  113 :normal   :none   250   5   5 105  50
       ("Pound" "Growl" "Sing" "Egg Bomb"))
      ("Tangela"  114 :grass    :none    65  55 115 100  60
       ("Bind" "Vine Whip" "Razor Leaf" "Solar Beam"))
      ("Kangaskhan" 115 :normal :none   105  95  80  40  90
       ("Pound" "Growl" "Body Slam" "Hyper Beam"))
      ("Horsea"   116 :water    :none    30  40  70  70  60
       ("Bubble" "Bubblebeam" "Surf" "Hydro Pump"))
      ("Seadra"   117 :water    :none    55  65  95  95  85
       ("Bubblebeam" "Surf" "Hydro Pump" "Hyper Beam"))
      ("Goldeen"  118 :water    :none    45  67  60  50  63
       ("Peck" "Tail Whip" "Surf" "Horn Drill"))
      ("Seaking"  119 :water    :none    80  92  65  80  68
       ("Peck" "Surf" "Hyper Beam" "Horn Drill"))
      ("Staryu"   120 :water    :none    30  45  55  70  85
       ("Tackle" "Water Gun" "Bubblebeam" "Surf"))
      ("Starmie"  121 :water    :psychic 60  75  85 100 115
       ("Water Gun" "Bubblebeam" "Surf" "Psychic"))
      ("Mr. Mime" 122 :psychic  :none    40  45  65 100  90
       ("Confusion" "Barrier" "Psybeam" "Psychic"))
      ("Scyther"  123 :bug      :flying  70 110  80  55 105
       ("Quick Attack" "Leer" "Wing Attack" "Slash"))
      ("Jynx"     124 :ice      :psychic 65  50  35  95  95
       ("Pound" "Sing" "Ice Beam" "Blizzard"))
      ("Electabuzz" 125 :electric :none  65  83  57  95 105
       ("Thunder Shock" "Thunderbolt" "Thunder Wave" "Thunder"))
      ("Magmar"   126 :fire     :none    65  95  57  85  93
       ("Ember" "Flamethrower" "Fire Blast" "Hyper Beam"))
      ("Pinsir"   127 :bug      :none    65 125 100  55  85
       ("Vicegrip" "Bind" "Seismic Toss" "Hyper Beam"))
      ("Tauros"   128 :normal   :none    75 100  95  70 110
       ("Tackle" "Leer" "Body Slam" "Hyper Beam"))
      ("Magikarp" 129 :water    :none    20  10  55  20  80
       ("Splash" "Tackle"))
      ("Gyarados" 130 :water    :flying  95 125  79 100  81
       ("Surf" "Body Slam" "Bite" "Hyper Beam"))
      ("Lapras"   131 :water    :ice    130  85  80  95  60
       ("Water Gun" "Ice Beam" "Blizzard" "Surf"))
      ("Ditto"    132 :normal   :none    48  48  48  48  48
       ("Transform"))
      ("Eevee"    133 :normal   :none    55  55  50  65  55
       ("Tackle" "Tail Whip" "Quick Attack" "Body Slam"))
      ("Vaporeon" 134 :water    :none   130  65  60 110  65
       ("Tackle" "Water Gun" "Surf" "Hydro Pump"))
      ("Jolteon"  135 :electric :none    65  65  60 110 130
       ("Tackle" "Thunder Shock" "Thunderbolt" "Thunder"))
      ("Flareon"  136 :fire     :none    65 130  60 110  65
       ("Tackle" "Ember" "Flamethrower" "Fire Blast"))
      ("Porygon"  137 :normal   :none    65  60  70  75  40
       ("Tackle" "Sharpen" "Psybeam" "Tri Attack"))
      ("Omanyte"  138 :rock     :water   35  40 100  90  35
       ("Water Gun" "Bubblebeam" "Surf" "Hydro Pump"))
      ("Omastar"  139 :rock     :water   70  60 125 115  55
       ("Water Gun" "Surf" "Hydro Pump" "Hyper Beam"))
      ("Kabuto"   140 :rock     :water   30  80  90  55  55
       ("Scratch" "Bubblebeam" "Surf" "Hydro Pump"))
      ("Kabutops" 141 :rock     :water   60 115 105  70  80
       ("Scratch" "Surf" "Hydro Pump" "Hyper Beam"))
      ("Aerodactyl" 142 :rock   :flying  80 105  65  60 130
       ("Wing Attack" "Hyper Beam" "Agility" "Rock Slide"))
      ("Snorlax"  143 :normal   :none   160 110  65  65  30
       ("Tackle" "Body Slam" "Hyper Beam" "Amnesia"))
      ("Articuno" 144 :ice      :flying  90  85 100 125  85
       ("Ice Beam" "Blizzard" "Hyper Beam" "Agility"))
      ("Zapdos"   145 :electric :flying  90  90  85 125 100
       ("Thunderbolt" "Thunder" "Hyper Beam" "Agility"))
      ("Moltres"  146 :fire     :flying  90 100  90 125  90
       ("Fire Blast" "Flamethrower" "Hyper Beam" "Agility"))
      ("Dratini"  147 :dragon   :none    41  64  45  50  50
       ("Wrap" "Leer" "Thunder Wave" "Slam"))
      ("Dragonair" 148 :dragon  :none    61  84  65  70  70
       ("Wrap" "Slam" "Hyper Beam" "Agility"))
      ("Dragonite" 149 :dragon  :flying  91 134  95 100  80
       ("Slam" "Hyper Beam" "Agility" "Blizzard"))
      ("Mewtwo"   150 :psychic  :none   106 110  90 154 130
       ("Confusion" "Psychic" "Recover" "Hyper Beam"))
      ("Mew"      151 :psychic  :none   100 100 100 100 100
       ("Pound" "Psychic" "Hyper Beam" "Blizzard"))))
      (destructuring-bind (name num type1 type2 hp atk def spc spd moves) r
        (pf 'pokemon name num type1 type2 hp atk def spc spd)
        (dolist (mv moves)
          (pf 'learnset name mv))))

    ;; ── Gym parties — (gym-party gym slot name level m1 m2 m3 m4) ─────────────
    ;; slot = 1-based position in party; nil move slots = :none
    (dolist (party
      '((:brock
         (1 "Geodude"   12 "Tackle"       "Defense Curl" "Rock Throw"  :none)
         (2 "Onix"      14 "Tackle"        "Screech"     "Rock Throw"  "Bind"))
        (:misty
         (1 "Staryu"    18 "Tackle"        "Water Gun"   "Bubblebeam"  :none)
         (2 "Starmie"   21 "Bubblebeam"    "Water Gun"   "Surf"       "Psychic"))
        (:lt-surge
         (1 "Raichu"    28 "Thunderbolt"   "Thunder Wave" "Quick Attack" "Body Slam"))
        (:erika
         (1 "Victreebel" 29 "Razor Leaf"   "Acid"        "Solar Beam"  "Toxic")
         (2 "Tangela"    24 "Bind"         "Vine Whip"   "Razor Leaf"  :none)
         (3 "Vileplume"  29 "Acid"         "Petal Dance" "Solar Beam"  "Toxic"))
        (:koga
         (1 "Koffing"   37 "Tackle"        "Acid"        "Toxic"      "Smokescreen")
         (2 "Muk"       39 "Pound"         "Acid"        "Toxic"      "Body Slam")
         (3 "Koffing"   37 "Tackle"        "Acid"        "Toxic"      "Smokescreen")
         (4 "Weezing"   43 "Pound"         "Acid"        "Toxic"      "Hyper Beam"))
        (:sabrina
         (1 "Kadabra"   38 "Confusion"     "Psybeam"     "Recover"    "Psychic")
         (2 "Mr. Mime"  37 "Confusion"     "Psybeam"     "Barrier"    "Psychic")
         (3 "Venomoth"  38 "Psybeam"       "Psychic"     "Leech Life" :none)
         (4 "Alakazam"  43 "Confusion"     "Psybeam"     "Recover"    "Psychic"))
        (:blaine
         (1 "Growlithe" 42 "Ember"         "Flamethrower" "Bite"      :none)
         (2 "Ponyta"    40 "Ember"         "Flamethrower" "Fire Blast" :none)
         (3 "Rapidash"  42 "Ember"         "Flamethrower" "Fire Blast" :none)
         (4 "Arcanine"  47 "Ember"         "Flamethrower" "Fire Blast" "Hyper Beam"))
        (:giovanni
         (1 "Rhyhorn"   45 "Horn Attack"   "Leer"        "Earthquake" "Rock Slide")
         (2 "Dugtrio"   42 "Scratch"       "Dig"         "Earthquake" :none)
         (3 "Nidoqueen" 44 "Tackle"        "Earthquake"  "Body Slam"  "Toxic")
         (4 "Nidoking"  45 "Tackle"        "Earthquake"  "Toxic"      "Hyper Beam")
         (5 "Rhydon"    50 "Horn Attack"   "Earthquake"  "Rock Slide" "Hyper Beam"))

        ;; ── Elite Four ────────────────────────────────────────────────────────
        (:lorelei
         (1 "Dewgong"   54 "Surf"          "Ice Beam"    "Blizzard"   "Body Slam")
         (2 "Cloyster"  53 "Surf"          "Ice Beam"    "Blizzard"   "Hyper Beam")
         (3 "Slowbro"   54 "Surf"          "Psychic"     "Ice Beam"   "Amnesia")
         (4 "Jynx"      56 "Ice Beam"      "Blizzard"    "Psychic"    "Sing")
         (5 "Lapras"    60 "Surf"          "Ice Beam"    "Blizzard"   "Body Slam"))
        (:bruno
         (1 "Onix"      53 "Tackle"        "Screech"     "Rock Throw" "Bind")
         (2 "Hitmonchan" 55 "Comet Punch"  "Karate Chop" "Seismic Toss" "Hyper Beam")
         (3 "Hitmonlee" 55 "Double Kick"   "Low Kick"    "Seismic Toss" "Hyper Beam")
         (4 "Onix"      56 "Tackle"        "Screech"     "Rock Throw" "Earthquake")
         (5 "Machamp"   58 "Karate Chop"   "Seismic Toss" "Submission" "Hyper Beam"))
        (:agatha
         (1 "Gengar"    54 "Night Shade"   "Confuse Ray" "Toxic"      "Hyper Beam")
         (2 "Haunter"   54 "Night Shade"   "Confuse Ray" "Toxic"      "Lick")
         (3 "Gengar"    58 "Night Shade"   "Confuse Ray" "Toxic"      "Hyper Beam")
         (4 "Arbok"     58 "Acid"          "Toxic"       "Wrap"       "Body Slam")
         (5 "Gengar"    60 "Night Shade"   "Confuse Ray" "Toxic"      "Hyper Beam"))
        (:lance
         (1 "Gyarados"  58 "Surf"          "Body Slam"   "Bite"       "Hyper Beam")
         (2 "Dragonair" 56 "Wrap"          "Slam"        "Agility"    "Hyper Beam")
         (3 "Dragonair" 56 "Wrap"          "Slam"        "Agility"    "Hyper Beam")
         (4 "Aerodactyl" 60 "Wing Attack"  "Rock Slide"  "Hyper Beam" "Agility")
         (5 "Dragonite" 62 "Slam"          "Hyper Beam"  "Blizzard"   "Agility"))

        ;; ── Champion Gary (Squirtle start — hardest variant) ─────────────────
        (:gary
         (1 "Pidgeot"   61 "Wing Attack"   "Agility"     "Hyper Beam" "Gust")
         (2 "Alakazam"  59 "Psychic"       "Recover"     "Psybeam"    "Hyper Beam")
         (3 "Rhydon"    61 "Earthquake"    "Rock Slide"  "Horn Attack" "Hyper Beam")
         (4 "Arcanine"  61 "Fire Blast"    "Flamethrower" "Body Slam"  "Hyper Beam")
         (5 "Exeggutor" 61 "Solar Beam"    "Psychic"     "Hyper Beam" "Egg Bomb")
         (6 "Blastoise" 65 "Surf"          "Hydro Pump"  "Withdraw"   "Hyper Beam"))

        ;; ── Route / dungeon rivals ────────────────────────────────────────────
        ;; Gary Route 22 (pre-Boulder Badge)
        (:gary-route22-early
         (1 "Pidgey"    9  "Gust"          "Tackle"      :none        :none)
         (2 "Squirtle"  9  "Tackle"        "Tail Whip"   :none        :none))
        ;; Gary SS Anne (mid-game)
        (:gary-ss-anne
         (1 "Pidgeotto" 18 "Gust"          "Wing Attack" :none        :none)
         (2 "Raticate"  19 "Quick Attack"  "Bite"        :none        :none)
         (3 "Kadabra"   18 "Confusion"     "Psybeam"     :none        :none)
         (4 "Wartortle" 20 "Water Gun"     "Withdraw"    :none        :none))
        ;; Gary Silph Co
        (:gary-silph
         (1 "Pidgeotto" 37 "Wing Attack"   "Agility"     "Hyper Beam" :none)
         (2 "Gyarados"  38 "Surf"          "Body Slam"   "Bite"       :none)
         (3 "Growlithe" 35 "Flamethrower"  "Bite"        :none        :none)
         (4 "Alakazam"  38 "Psychic"       "Recover"     :none        :none)
         (5 "Wartortle" 40 "Surf"          "Withdraw"    "Hydro Pump" :none))))
      (let ((gym (car party)))
        (dolist (slot (cdr party))
          (apply #'pf 'gym-party gym slot))))

    db))

;;;; ── HP formula ─────────────────────────────────────────────────────────────

(defun calc-hp (base level)
  (max 1 (floor (+ (* 2 base level) level 10) 100)))

(defun calc-stat (base level)
  (floor (+ (* 2 base level) 5) 100))

;;;; ── Query API ───────────────────────────────────────────────────────────────
;;; All queries use the kb returned by pokemon-logic:make-pokemon-kb.
;;; The kb is passed explicitly — no global state.

(defun find-pokemon (kb name)
  "Return a plist for species NAME from KB, or NIL."
  (let ((r (pokemon-logic::db-prove-first kb `(pokemon ,name ?num ?t1 ?t2 ?hp ?atk ?def ?spc ?spd))))
    (when r
      (list :name name
            :number  (pokemon-logic::%lookup '?num r)
            :type1   (pokemon-logic::%lookup '?t1  r)
            :type2   (let ((t2 (pokemon-logic::%lookup '?t2 r)))
                       (if (eq t2 :none) nil t2))
            :base-hp  (pokemon-logic::%lookup '?hp  r)
            :base-atk (pokemon-logic::%lookup '?atk r)
            :base-def (pokemon-logic::%lookup '?def r)
            :base-spc (pokemon-logic::%lookup '?spc r)
            :base-spd (pokemon-logic::%lookup '?spd r)))))

(defun species-type1 (species-plist)
  (getf species-plist :type1))

(defun find-move (kb name)
  "Return a plist for move NAME from KB, or NIL."
  (let ((r (pokemon-logic::db-prove-first kb `(move ,name ?type ?cat ?pow ?acc ?pp ?eff))))
    (when r
      (list :name     name
            :type     (pokemon-logic::%lookup '?type r)
            :category (pokemon-logic::%lookup '?cat  r)
            :power    (pokemon-logic::%lookup '?pow  r)
            :accuracy (pokemon-logic::%lookup '?acc  r)
            :pp       (pokemon-logic::%lookup '?pp   r)
            :effect   (pokemon-logic::%lookup '?eff  r)))))

(defun move-name     (m) (getf m :name))
(defun move-type     (m) (getf m :type))
(defun move-category (m) (getf m :category))
(defun move-power    (m) (getf m :power))

(defun find-item (kb name)
  "Return a plist for item NAME from KB, or NIL."
  (let ((r (pokemon-logic::db-prove-first kb `(item ,name ?sym ?desc))))
    (when r
      (list :name   name
            :symbol (pokemon-logic::%lookup '?sym  r)
            :desc   (pokemon-logic::%lookup '?desc r)))))

(defun make-battle-mon (kb name level &rest move-names)
  "Build a battle-ready plist from Prolog facts for NAME at LEVEL."
  (let ((sp (find-pokemon kb name)))
    (unless sp (error "Unknown species: ~S" name))
    (let* ((max-hp (calc-hp  (getf sp :base-hp)  level))
           (moves  (remove nil (mapcar (lambda (mn) (find-move kb mn)) move-names))))
      (list :name    name
            :species sp
            :level   level
            :hp      max-hp
            :max-hp  max-hp
            :type1   (getf sp :type1)
            :type2   (getf sp :type2)
            :atk     (calc-stat (getf sp :base-atk) level)
            :def     (calc-stat (getf sp :base-def) level)
            :spc     (calc-stat (getf sp :base-spc) level)
            :spd     (calc-stat (getf sp :base-spd) level)
            :moves   moves
            :status  nil))))

(defun gym-party (kb gym-keyword)
  "Return the list of battle-mon plists for GYM-KEYWORD's party."
  (let ((slots (pokemon-logic::db-prove-all
                 kb `(gym-party ,gym-keyword ?slot ?name ?lvl ?m1 ?m2 ?m3 ?m4))))
    (mapcar (lambda (b)
              (let ((name  (pokemon-logic::%lookup '?name b))
                    (level (pokemon-logic::%lookup '?lvl  b))
                    (moves (remove :none
                             (list (pokemon-logic::%lookup '?m1 b)
                                   (pokemon-logic::%lookup '?m2 b)
                                   (pokemon-logic::%lookup '?m3 b)
                                   (pokemon-logic::%lookup '?m4 b)))))
                (apply #'make-battle-mon kb name level moves)))
            (sort slots #'< :key (lambda (b) (pokemon-logic::%lookup '?slot b))))))

(defun brock-party    (kb) (gym-party kb :brock))
(defun misty-party    (kb) (gym-party kb :misty))
(defun lt-surge-party (kb) (gym-party kb :lt-surge))
(defun erika-party    (kb) (gym-party kb :erika))
(defun koga-party     (kb) (gym-party kb :koga))
(defun sabrina-party  (kb) (gym-party kb :sabrina))
(defun blaine-party   (kb) (gym-party kb :blaine))
(defun giovanni-party (kb) (gym-party kb :giovanni))

(defun starter-pikachu (kb)
  (make-battle-mon kb "Pikachu" 5 "Thunder Shock" "Growl"))

;; Elite Four
(defun lorelei-party  (kb) (gym-party kb :lorelei))
(defun bruno-party    (kb) (gym-party kb :bruno))
(defun agatha-party   (kb) (gym-party kb :agatha))
(defun lance-party    (kb) (gym-party kb :lance))
;; Champion
(defun gary-party     (kb) (gym-party kb :gary))
;; Route rivals
(defun gary-route22-early-party (kb) (gym-party kb :gary-route22-early))
(defun gary-ss-anne-party       (kb) (gym-party kb :gary-ss-anne))
(defun gary-silph-party         (kb) (gym-party kb :gary-silph))

(defun all-pokemon (kb)
  "Return list of all 151 species name strings."
  (mapcar (lambda (b) (pokemon-logic::%lookup '?name b))
          (pokemon-logic::db-prove-all kb '(pokemon ?name ?num ?t1 ?t2 ?hp ?atk ?def ?spc ?spd))))

;;; ── Extended trainer catalog ─────────────────────────────────────────────────
;;; Called from assert-catalog-facts via the same (pf 'gym-party ...) pattern.
;;; These are appended here; assert-catalog-facts already iterates the full list.
