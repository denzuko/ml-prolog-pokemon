(in-package #:cl-user)

(defpackage #:pokemon-logic
  (:use #:cl)
  (:local-nicknames (#:g #:gambol))
  (:export #:make-pokemon-kb
           #:get-logic-multiplier
           #:find-counter-types
           #:team-valid-p))

(defpackage #:pokemon-sim
  (:use #:coalton #:coalton-prelude)
  (:local-nicknames (#:logic #:pokemon-logic))
  (:export #:run-simulation))
