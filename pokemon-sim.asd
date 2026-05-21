(asdf:load-system "coalton-asdf")

(defsystem "pokemon-sim"
  :description "Gen-I Yellow Pokémon battle simulator — Prolog rules, Coalton types, CL glue"
  :version "0.2.0"
  :depends-on ("coalton" "coalton-asdf" "paiprolog" "arrows" "named-readtables")
  :serial t
  :components ((:file    "package")
               (:file    "logic-engine")   ; Prolog: type chart, items, team rules
               (:file    "catalog")        ; Prolog: pokémon/move/item/trainer facts
               (:ct-file "types")          ; Coalton: ADTs + battle computation
               (:file    "simulator")))    ; CL: bridge, entry points

(defsystem "pokemon-sim/test"
  :description "FiveAM test suite for pokemon-sim"
  :depends-on ("pokemon-sim" "fiveam")
  :serial t
  :components ((:file "tests")))
