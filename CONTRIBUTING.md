# Contributing to ml-prolog-pokemon

Thanks for taking the time. This is a research/exercise project — scope is
intentionally bounded to the Gen-I Yellow domain exercise. See README for
architectural context before contributing.

## Ways to contribute

- Bug reports via [GitHub Issues](https://github.com/denzuko/ml-prolog-pokemon/issues)
- Bug fixes via pull request
- Documentation corrections
- Security issues — see [SECURITY.md](SECURITY.md) before opening a ticket

Out of scope: gameplay accuracy improvements beyond Gen-I Yellow, GUI,
network play, or a shipping game client.

## Before you open a PR

**1. All functional tests pass:**

```sh
sbcl --noinform \
  --eval '(push #p"." asdf:*central-registry*)' \
  --eval '(push #p"../cl-gambol/" asdf:*central-registry*)' \
  --eval '(ql:quickload "pokemon-sim/test")' \
  --eval '(fiveam:run! (quote pokemon-tests::pokemon-suite))' \
  --eval '(sb-ext:exit)'
# Expected: Pass: 65 (100%)
```

**2. Performance regression suite passes:**

```sh
sbcl --noinform \
  --eval '(push #p"." asdf:*central-registry*)' \
  --eval '(push #p"../cl-gambol/" asdf:*central-registry*)' \
  --eval '(ql:quickload "pokemon-sim/perf")' \
  --eval '(pokemon-sim/perf:run-perf)' \
  --eval '(sb-ext:exit)'
# Expected: Pass: 11 (100%)
```

**3. New Prolog facts follow the keyword convention:**

All atoms in `db-assert` calls normalise to keywords automatically.
Query functions must accept both keyword and plain symbol input
(normalised internally via `%norm-goal`).

**4. New catalog entries follow existing schemas:**

- Species: `(pokemon name num :type1 :type2 base-hp base-atk base-def base-spc base-spd)`
- Move: `(move name :type :category power accuracy pp effect-keyword-or-nil)`
- Trainer: `(gym-party :gym-keyword slot "Species" level "Move1" "Move2" "Move3" "Move4")`

**5. `simulator.lisp` stays thin:**

If you add a function to `simulator.lisp` that does more than type
conversion or formatted output, move it to `types.ct` (if it's pure
computation over Coalton types) or `logic-engine.lisp` (if it's a rule
or query).

**6. Update CHANGELOG.md** under `[Unreleased]`.

## Pull request checklist

- [ ] Functional tests pass (65/65)
- [ ] Performance suite passes (11/11)
- [ ] New facts/rules follow keyword convention
- [ ] `simulator.lisp` unchanged or thinner
- [ ] `CHANGELOG.md` updated

## Code style

- CL files: `(named-readtables:in-readtable :standard)` at top of every file
- Coalton: one `coalton-toplevel` block per file, `lisp` escapes documented
- Prolog: ground facts only in `catalog.lisp`; derived rules in `logic-engine.lisp`
- No `paiprolog` or `gambol` calls outside `logic-engine.lisp`
