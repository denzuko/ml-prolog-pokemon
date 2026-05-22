## Summary

What does this PR do? Reference any related issue with `Fixes #N`.

## Test results

```
;; Functional suite
(ql:quickload "pokemon-sim/test")
(fiveam:run! 'pokemon-tests::pokemon-suite)
;; Expected: Pass: 65 (100%)

```

```
;; Performance regression
(ql:quickload "pokemon-sim/perf")
(pokemon-sim/perf:run-perf)
;; Expected: Pass: 11 (100%)

```

## Checklist

- [ ] Functional tests pass (65/65)
- [ ] Performance suite passes (11/11)
- [ ] New Prolog facts follow keyword convention (`:fire` not `fire`)
- [ ] `simulator.lisp` unchanged or thinner
- [ ] Any new `lisp` escape in `types.ct` is documented with rationale
- [ ] `CHANGELOG.md` updated under `[Unreleased]`
