;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; cl-pathname-pure.asd
;;;; Cross-platform path handling with zero external dependencies

(asdf:defsystem #:cl-pathname-pure
  :description "Pure Common Lisp cross-platform pathname handling library"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :version "0.1.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :serial t
                :components ((:file "pathname")))))

(asdf:defsystem #:cl-pathname-pure/test
  :description "Tests for cl-pathname-pure"
  :depends-on (#:cl-pathname-pure)
  :serial t
  :components ((:module "test"
                :components ((:file "test-pathname-pure"))))
  :perform (asdf:test-op (o c)
             (let ((result (uiop:symbol-call :cl-pathname-pure.test :run-tests)))
               (unless result
                 (error "Tests failed")))))
