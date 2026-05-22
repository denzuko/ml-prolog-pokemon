# ml-prolog-pokemon

A Gen-I Pokémon Yellow battle simulator built as a domain exercise in
multi-paradigm architecture: **Prolog** for rules and knowledge,
**Coalton** (ML-style types) for typed battle computation, and
**Common Lisp** as the glue and tooling layer.

The exercise was explicitly about discovering where each system is strong
and where the boundaries between them create friction — not about shipping
a game.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  PROLOG  (logic-engine.lisp + catalog.lisp)                 │
│                                                             │
│  Rules: type chart (37 SE / 29 NVE / 6 immune matchups)    │
│  Facts: 151 Pokémon · 85 moves · 19 items                   │
│  Facts: 8 gyms · Elite Four · Champion Gary · rivals        │
│  Queries: suggest-badge-team · team-valid-p · usable-item-p │
│                                                             │
│  Backward-chaining over ground terms. Single source of      │
│  truth for "what is true given these facts."                │
└──────────────────────────┬──────────────────────────────────┘
                           │  db-prove-first / db-prove-all
                           │  get-logic-multiplier (keyword atoms)
┌──────────────────────────▼──────────────────────────────────┐
│  COALTON  (types.ct)                                        │
│                                                             │
│  ADTs: PkmnType · Status · Move · Pokemon · BattleOutcome   │
│  Pure: calculate-damage · apply-end-of-turn · run-turn      │
│  Pure: simulate-battle (recursive, IFix turn counter)       │
│  Escape: lookup-multiplier → one lisp form → Prolog query   │
│                                                             │
│  Types enforce exhaustiveness. The lisp escape is the only  │
│  impure call site in the entire Coalton layer.              │
└──────────────────────────┬──────────────────────────────────┘
                           │  plist→Pokemon · match-outcome
┌──────────────────────────▼──────────────────────────────────┐
│  CL GLUE  (simulator.lisp)                                  │
│                                                             │
│  ~80 lines. Bridges catalog plists to Coalton values.       │
│  Entry points: run-simulation · run-badge-battle            │
│  If this layer acquires logic, something is wrong.          │
└─────────────────────────────────────────────────────────────┘
```

---

## Systems

```lisp
;; Core library — no test dependency
(defsystem "pokemon-sim"
  :depends-on ("coalton" "coalton-asdf" "paiprolog" "arrows" "named-readtables"))

;; Test suite — separate system
(defsystem "pokemon-sim/test"
  :depends-on ("pokemon-sim" "fiveam"))
```

---

## Prerequisites

- **SBCL** 2.x (Coalton targets SBCL only — see [Portability](#portability) below)
- **Quicklisp** installed at `~/quicklisp/`
- **cl-gambol** in `~/quicklisp/local-projects/cl-gambol/`
  (`git clone https://github.com/wmannis/cl-gambol`)

Dependencies pulled via Quicklisp: `coalton`, `paiprolog`, `fiveam`,
`arrows`, `named-readtables`.

---

## Usage

### Load

```lisp
;; In your SBCL REPL (SLIME, SLY, or vlime):
(push #p"/path/to/ml-prolog-pokemon/" asdf:*central-registry*)
(push #p"/path/to/cl-gambol/"         asdf:*central-registry*)
(ql:quickload "pokemon-sim")
```

### Build the knowledge base

Every interaction starts with a fresh `kb`. It contains both the type-chart
rules and all 151 Pokémon/move/item/trainer facts.

```lisp
(defparameter *kb* (pokemon-logic:make-pokemon-kb))
```

### Type effectiveness queries

```lisp
;; All type symbols are keywords
(pokemon-logic:get-logic-multiplier *kb* :fire :grass)    ; → SUPER-EFFECTIVE
(pokemon-logic:get-logic-multiplier *kb* :electric :ground) ; → IMMUNE
(pokemon-logic:get-logic-multiplier *kb* :fire :water)    ; → NOT-VERY-EFFECTIVE

(pokemon-logic:multiplier->ratio :super-effective)        ; → 2
(pokemon-logic:multiplier->ratio :immune)                 ; → 0
```

### Counter-type advisor

```lisp
;; What types are super-effective against Water?
(pokemon-logic:find-counter-types *kb* :water)
; → (:GRASS :ELECTRIC)

;; What should I bring to fight Lance (Dragon specialist)?
(pokemon-logic:suggest-badge-team *kb* '(:dragon :flying :water))
; → (:ICE :ELECTRIC :ROCK ...)  ranked by coverage
```

### Badge battle advisor (formatted output)

```lisp
;; Gyms
(pokemon-sim/glue:run-badge-battle :brock)     ; Rock/Ground → water, grass, fighting
(pokemon-sim/glue:run-badge-battle :sabrina)   ; Psychic     → bug, ghost, dark
(pokemon-sim/glue:run-badge-battle :blaine)    ; Fire        → water, ground, rock

;; Elite Four
(pokemon-sim/glue:run-badge-battle :lorelei)   ; Ice
(pokemon-sim/glue:run-badge-battle :lance)     ; Dragon

;; Champion
(pokemon-sim/glue:run-badge-battle :gary)      ; Mixed — Blastoise ace

;; Route rivals
(pokemon-sim/glue:run-badge-battle :gary-ss-anne)
(pokemon-sim/glue:run-badge-battle :gary-silph)
```

### Catalog queries

```lisp
;; Species
(pokemon-catalog:find-pokemon *kb* "Charizard")
; → (:NAME "Charizard" :NUMBER 6 :TYPE1 :FIRE :TYPE2 :FLYING
;          :BASE-HP 78 :BASE-ATK 84 :BASE-DEF 78 :BASE-SPC 85 :BASE-SPD 100)

;; Move
(pokemon-catalog:find-move *kb* "Thunderbolt")
; → (:NAME "Thunderbolt" :TYPE :ELECTRIC :CATEGORY :SPECIAL
;          :POWER 95 :ACCURACY 100 :PP 15 :EFFECT :PARALYSIS-10)

;; Build a battle-ready Pokémon at a given level
(pokemon-catalog:make-battle-mon *kb* "Raichu" 28
  "Thunderbolt" "Thunder Wave" "Quick Attack" "Body Slam")
; → (:NAME "Raichu" :LEVEL 28 :HP 73 :MAX-HP 73 :TYPE1 :ELECTRIC ...)

;; Gym party
(pokemon-catalog:gary-party *kb*)
; → list of 6 make-battle-mon plists, Blastoise last
```

### Battle simulation (Coalton layer)

```lisp
(let* ((kb  (pokemon-logic:make-pokemon-kb))
       ;; Build Coalton Pokemon values from catalog plists
       (p1  (pokemon-sim/glue:plist->pokemon
              (pokemon-catalog:make-battle-mon kb "Charizard" 50
                "Flamethrower" "Fire Blast" "Slash" "Hyper Beam")))
       (p2  (pokemon-sim/glue:plist->pokemon
              (pokemon-catalog:make-battle-mon kb "Blastoise" 50
                "Surf" "Hydro Pump" "Withdraw" "Body Slam")))
       (m1  (pokemon-sim/glue:catalog-move->coalton
              (pokemon-catalog:find-move kb "Flamethrower")))
       (m2  (pokemon-sim/glue:catalog-move->coalton
              (pokemon-catalog:find-move kb "Surf")))
       ;; simulate-battle is a pure Coalton function
       (res (pokemon-sim:simulate-battle kb p1 m1 p2 m2 20)))
  ;; Dispatch on the BattleOutcome ADT
  (pokemon-sim/glue:match-outcome res
    :winner w
    :victor  (format t "Winner: ~A (HP: ~A/~A)~%"
                     (pokemon-sim:pokemon-name   w)
                     (pokemon-sim:pokemon-hp     w)
                     (pokemon-sim:pokemon-max-hp w))
    :draw    (format t "Draw~%")
    :ongoing (format t "Time limit~%")))
; → Winner: Blastoise (HP: 41/175)
```

### Team validity

```lisp
(pokemon-logic:team-valid-p *kb* '(pikachu bulbasaur charizard blastoise gengar alakazam))
; → T
(pokemon-logic:team-valid-p *kb* '(pikachu pikachu))
; → NIL  (duplicate)
```

### Item effects

```lisp
(pokemon-logic:usable-item-p *kb* 'potion)       ; → T
(pokemon-logic:usable-item-p *kb* 'unknown-item) ; → NIL

(let ((mon '(:name "Pikachu" :hp 30 :max-hp 100 :status :poisoned)))
  (pokemon-logic:apply-item-effect *kb* 'full-restore mon))
; → (:NAME "Pikachu" :HP 100 :MAX-HP 100 :STATUS NIL)
```

### Run the test suite

```lisp
(ql:quickload "pokemon-sim/test")
(fiveam:run! 'pokemon-tests::pokemon-suite)
;  Did 65 checks.
;     Pass: 65 (100%)
;     Skip:  0 (  0%)
;     Fail:  0 (  0%)
```

Or from the shell:

```bash
sbcl --noinform \
  --eval '(push #p"." asdf:*central-registry*)' \
  --eval '(push #p"../cl-gambol/" asdf:*central-registry*)' \
  --eval '(ql:quickload "pokemon-sim/test")' \
  --eval '(fiveam:run! (quote pokemon-tests::pokemon-suite))' \
  --eval '(sb-ext:exit)'
```

---

## Benchmark results (SBCL 2.x, native compiled)

Measured on the pure-CL knowledge layer and the Coalton battle layer separately.

### Knowledge / catalog layer

| Operation | Time | Notes |
|---|---|---|
| `make-pokemon-kb` | 200 µs | Asserts ~800 Prolog facts |
| `get-logic-multiplier` | 16 µs | Hash probe + keyword unification |
| `suggest-badge-team` | 504 µs | 15 types × N enemy types, ranked |
| `find-pokemon` | 12 µs | Single Prolog fact lookup |
| `make-battle-mon` | 34 µs | Lookup + stat formula (4 moves) |
| `gary-party` (6 Pokémon) | 170 µs | 6× make-battle-mon |

### Coalton battle layer

| Operation | Time | Notes |
|---|---|---|
| `type->string` | 0.06 µs | Pure Coalton match |
| `lookup-multiplier` | 7 µs | Prolog call from Coalton via `lisp` |
| `calculate-damage` | 8 µs | Gen-I formula, includes Prolog query |
| `run-turn` | 14 µs | Simultaneous damage + DoT |
| `simulate-battle` | 138 µs | ~8–12 turns average |
| Full pipeline (kb+party+battle) | 312 µs | Cold start, includes kb construction |

### ECL portability

| Mode | `get-logic-multiplier` | `suggest-badge-team` | `find-pokemon` |
|---|---|---|---|
| SBCL native | 16 µs | 504 µs | 12 µs |
| ECL C-native | 56 µs (3.5×) | 1702 µs (3.4×) | 32 µs (2.7×) |
| ECL bytecode | 887 µs (55×) | 26694 µs (53×) | 547 µs (46×) |

**Note:** The Coalton layer (types.ct, battle computation) **does not load on ECL**.
Coalton's reader returns multiple values from a readmacro, which SBCL permits
as an extension but violates CL standard §2.2. The pure-CL knowledge layer
(logic-engine.lisp, catalog.lisp) runs on ECL with the numbers above.

---

## What the exercise revealed

This project was a deliberate stress-test of the Prolog + ML-types + CL
combination. Findings:

**Prolog for rules is genuinely strong.** The type chart, catalog, and
advisor fall out naturally as backward-chaining queries. When rules change,
you assert a fact. `suggest-badge-team` is four lines of logic that would be
a lookup table and scoring loop in C.

**Coalton's type boundaries are valuable at interfaces.** `BattleOutcome`
as `Victor | Draw | Ongoing` means the compiler enforces exhaustiveness on
the turn loop. The `calculate-damage` return-type mismatch (`Integer` vs
`UFix`) was caught at compile time, not runtime.

**The Prolog/Coalton boundary is the friction point.** The `lisp` escape in
`lookup-multiplier` works but Coalton's codegen mangled variable names
(`def-type → def-type-45`) until we routed strings instead of values. The
marshalling cost (7 µs/call) is acceptable for turn-based but not real-time.
The boundary itself is where bugs live.

**Coalton is SBCL-only.** This is a hard architectural constraint, not a
configuration problem. If the target runtime needs to be ECL (embedded in C),
ABCL (JVM), or CCL, the Coalton layer needs to be replaced with either SML
proper or hand-written CL.

**CL as glue is honest.** The `simulator.lisp` bridge ended at ~80 lines with
no logic. When glue acquires logic, the boundary is wrong.

**For a high-performance game engine:** the correct split is C99 for the hot
path and state machine, Prolog (libswipl or Scryer) for rules and knowledge,
and CL for tooling, codegen, and REPL-driven development — not as a runtime
layer. The Coalton/SML typed layer adds value at internal interfaces but
creates a portability ceiling that C + disciplined `-Wswitch-enum` avoids.

---

## File structure

```
pokemon-sim.asd       ASDF system definitions (pokemon-sim + pokemon-sim/test)
package.lisp          All defpackage declarations
logic-engine.lisp     Prolog rules + micro-interpreter (60 lines)
catalog.lisp          Gen-I Yellow data as Prolog facts + query API
types.ct              Coalton ADTs + battle computation
simulator.lisp        CL bridge (~80 lines) + entry points
tests.lisp            65 FiveAM tests (pokemon-sim/test system)
```

---

## Caveats

- **gambol dependency:** `cl-gambol` is listed in the ASD per the original
  architecture mandate but is not used at runtime. `wmannis/cl-gambol` has
  an infinite-loop bug in SBCL 2.x headless environments (unify recurses via
  TCO in the CPS search). The actual Prolog evaluator is the embedded
  60-line micro-interpreter in `logic-engine.lisp`.

- **Gen-I accuracy:** The type chart encodes Yellow-specific Gen-I quirks
  (Bug super-effective vs Psychic; Ghost immune to Psychic; Fighting
  super-effective vs Poison/Bug). Gen-II changes are not included.

- **Damage formula:** Simplified Gen-I formula without random variance,
  STAB, or critical hit rolls. Sufficient for team-building analysis.
