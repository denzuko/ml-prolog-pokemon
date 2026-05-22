# Changelog

All notable changes to this project will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
This project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] — 2026-05-22

### Added
- `pokemon-sim/perf` ASDF system — 11 performance regression tests with
  median wall-clock budgets across all three layers
- `pokemon-sim/test` ASDF system — functional tests separated from core
- Elite Four parties: Lorelei, Bruno, Agatha, Lance
- Champion Gary (Squirtle start, 6-member, Blastoise ace)
- Route rival encounters: Gary Route 22, SS Anne, Silph Co
- `CLAUDE.md`, `CONTRIBUTING.md`, `SECURITY.md`, `DIAGRAM.md`
- `CODEOWNERS`, `CHANGELOG.md`, `LICENSE.txt`
- CycloneDX SBOM (`sbom.cdx.json`)
- SARIF static analysis report (`ml-prolog-pokemon.sarif`)

### Changed
- Battle computation moved entirely into Coalton (`types.ct`):
  `calculate-damage`, `apply-end-of-turn`, `run-turn`, `simulate-battle`
- `simulator.lisp` reduced to pure bridge (~80 lines, no logic)
- `match-outcome` macro accepts `:winner`/`:next-p1`/`:next-p2` keyword
  args to avoid cross-package symbol resolution issues
- All catalog query functions now take `kb` as first argument

### Fixed
- `lookup-multiplier` codegen bug: Coalton mangled `def-type` variable
  name; fixed by passing strings into the `lisp` escape rather than
  PkmnType values

## [0.1.0] — 2026-05-21

### Added
- Initial simulator: Prolog type chart, catalog as Prolog facts,
  Coalton ADTs, CL bridge
- 151 Gen-I Yellow Pokémon with base stats, 85 moves, 19 consumables
- 8 gym leader parties (Brock through Giovanni, Yellow versions)
- 60 FiveAM functional tests (100% pass)
- Embedded 60-line micro-Prolog evaluator replacing wmannis/cl-gambol
  (known TCO infinite-loop bug in SBCL 2.x headless)
