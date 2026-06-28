;;;; src/matrix-id.lisp — net.matrix CMDB identity strings
;;;;
;;;; Baked into the binary at compile time via defparameter constants.
;;;; Version resolved at compile time from pokemon-sim.asd via #.
;;;;
;;;; SPDX-License-Identifier: BSD-2-Clause
;;;; Da Planet Security / denzuko <denzuko@dapla.net>

(defpackage #:pokemon-sim/matrix-id
  (:use #:cl)
  (:export #:*matrix-labels* #:matrix-label))

(in-package #:pokemon-sim/matrix-id)

(defparameter *matrix-labels*
  `(("net.matrix.organization" . "daplanet")
    ("net.matrix.orgunit"      . "dps")
    ("net.matrix.owner"        . "FC13F74B@matrix.net")
    ("net.matrix.oid"          . "iso.org.dod.internet.42387")
    ("net.matrix.duns"         . "iso.org.duns.039271257")
    ("net.matrix.customer"     . "PVT-01")
    ("net.matrix.costcenter"   . "INT-01")
    ("net.matrix.application"  . "ml-prolog-pokemon")
    ("net.matrix.role"         . "architecture-study")
    ("net.matrix.environment"  . "development")
    ("net.matrix.version"      . ,(asdf:component-version
                                   (asdf:find-system :pokemon-sim))))
  "net.matrix CMDB identity labels.")

(defun matrix-label (key)
  (cdr (assoc key *matrix-labels* :test #'string=)))
