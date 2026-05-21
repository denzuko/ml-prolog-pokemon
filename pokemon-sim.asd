(asdf:load-system "coalton-asdf")

(defsystem "pokemon-sim"
  :description "Gen-I Yellow Pokémon battle simulator — Prolog rules, Coalton types, CL glue"
  :version "0.2.0"
  :depends-on ("coalton" "coalton-asdf" "paiprolog" "arrows" "named-readtables")
  :serial t
  :components ((:file    "package")
               (:file    "logic-engine")
               (:file    "catalog")
               (:ct-file "types")
               (:file    "simulator")))

(defsystem "pokemon-sim/test"
  :description "FiveAM test suite for pokemon-sim"
  :depends-on ("pokemon-sim" "fiveam")
  :serial t
  :components ((:file "tests")))

(defsystem "pokemon-sim/perf"
  :description "Performance regression suite for pokemon-sim"
  :depends-on ("pokemon-sim" "trivial-benchmark" "fiveam")
  :serial t
  :components ((:file "perf")))
