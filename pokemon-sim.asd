(defsystem "pokemon-sim"
  :depends-on ("coalton" "gambol")
  :serial t
  :components ((:file "package")
               (:file "logic-engine")
               (:file "simulator")))
