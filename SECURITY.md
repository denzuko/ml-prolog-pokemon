# Security Policy

## Supported Versions

| Version | Supported |
|---------|-----------|
| 0.2.x   | ✅ Yes    |

Only the latest tagged release on `feat/gen1-yellow-simulator` receives fixes.

## Threat Model

`ml-prolog-pokemon` is a **research library with no network surface**.

It does not:
- open network sockets
- read from or write to the filesystem outside SBCL's FASL cache
- execute shell commands
- accept external input at runtime

The attack surface is limited to:
- **Prolog fact injection via `db-assert`** — `db-assert` accepts a plain
  list; callers must validate inputs before asserting. The micro-interpreter
  has no `assert` or `retract` in query position; only `db-assert` (called
  from `make-pokemon-kb`) modifies the database.
- **Coalton `lisp` escape** — `lookup-multiplier` calls
  `pokemon-logic:get-logic-multiplier` and `multiplier->ratio` via a `lisp`
  form. These functions are pure and read-only against the kb.
- **SBCL-specific behaviour** — Coalton targets SBCL only. Code should not
  be loaded in a security-sensitive SBCL instance without reviewing the
  Coalton-generated CL output (`types.fasl`).

## Reporting a Vulnerability

**Do not open a public GitHub Issue for security vulnerabilities.**

Report by email: **denzuko@dapla.net**

Include:
- Description of the vulnerability
- Reproduction steps
- Impact assessment
- Suggested fix if known

Expected response time: 5 business days.
