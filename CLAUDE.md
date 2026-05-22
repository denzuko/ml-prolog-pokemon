# CLAUDE.md

This file provides context for AI coding assistants working in this repository.

## Project overview

`ml-prolog-pokemon` is a Gen-I Pokémon Yellow battle simulator built as a
domain exercise in multi-paradigm architecture. It is **not** a shipping game —
it is a deliberate stress-test of Prolog + ML-style types + Common Lisp together.

Three ASDF systems:

| System | Purpose |
|--------|---------|
| `pokemon-sim` | Core library — Prolog rules, Coalton ADTs, CL bridge |
| `pokemon-sim/test` | FiveAM functional test suite (65 checks) |
| `pokemon-sim/perf` | Performance regression suite (11 budgeted checks) |

## Architecture

```
logic-engine.lisp   Prolog rulebase — type chart, item effects, team rules
catalog.lisp        Prolog facts — 151 Pokémon, 85 moves, 19 items, all trainers
types.ct            Coalton DSL — ADTs + all battle computation
simulator.lisp      CL bridge (~80 lines) — plist→Coalton, entry points
```

The boundary is strict: Prolog owns rules and data, Coalton owns typed
computation, CL owns nothing except bridging. If `simulator.lisp` acquires
logic, the boundary is wrong.

## Workflow

**Always follow BDD order: write the test/budget first, then implement.**

```sh
# Load everything and run functional tests
sbcl --noinform \
  --eval '(push #p"." asdf:*central-registry*)' \
  --eval '(push #p"../cl-gambol/" asdf:*central-registry*)' \
  --eval '(ql:quickload "pokemon-sim/test")' \
  --eval '(fiveam:run! (quote pokemon-tests::pokemon-suite))' \
  --eval '(sb-ext:exit)'

# Run performance regression suite
sbcl --noinform \
  --eval '(push #p"." asdf:*central-registry*)' \
  --eval '(push #p"../cl-gambol/" asdf:*central-registry*)' \
  --eval '(ql:quickload "pokemon-sim/perf")' \
  --eval '(pokemon-sim/perf:run-perf)' \
  --eval '(sb-ext:exit)'
```

## Conventions

- **All Prolog fact atoms are keywords** (`:fire`, `:super-effective`).
  `db-assert` normalises to keyword on write. `db-prove-first` normalises
  on read via `%norm-goal`. Cross-package symbol collisions are avoided.

- **catalog query functions take `kb` as first argument** — no global state.
  `make-pokemon-kb` returns a fresh isolated `prolog-db` struct every call.

- **Coalton `lisp` escapes are documented at every use site** with the reason
  why pure Coalton cannot express it.

- **`simulator.lisp` must stay thin.** If a function in it does anything
  beyond type conversion or formatted output, move it to `types.ct` or
  `logic-engine.lisp`.

- **Semver**: MAJOR = public API break. MINOR = new capability. PATCH = everything
  else (fixes, docs, tests). Patch freely exceeds 100; never bump major for
  internal restructuring.

## Prerequisites

- SBCL 2.x (Coalton is SBCL-only — see README portability section)
- Quicklisp at `~/quicklisp/`
- `cl-gambol` in `~/quicklisp/local-projects/cl-gambol/`

## Known limitations

- `wmannis/cl-gambol` is listed as an ASD dependency (architecture mandate)
  but is **not used at runtime** due to a TCO infinite-loop bug in SBCL 2.x
  headless. The actual evaluator is the embedded micro-interpreter in
  `logic-engine.lisp`.

- Coalton does not load on ECL (non-portable readmacro). The pure-CL
  knowledge layer works on ECL C-native at ~3.5× SBCL performance.

- Damage formula omits STAB, critical hits, and random variance by design.
  The exercise tests architecture, not Gen-I combat accuracy.
