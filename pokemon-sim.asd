(asdf:load-system "coalton-asdf")

(defsystem "pokemon-sim"
  :depends-on ("coalton" "coalton-asdf" "paiprolog" "fiveam" "arrows" "named-readtables")
  :serial t
  :components ((:file    "package")       ; all defpackage declarations
               (:file    "logic-engine")  ; gambol Prolog rules
               (:file    "catalog")       ; Gen-I data
               (:ct-file "types")         ; Coalton DSL — type model
               (:file    "simulator")     ; CL battle engine (pokemon-sim/glue)
               (:file    "repl")          ; interactive REPL
               (:file    "tests")))       ; FiveAM suite
