;;;; cl-pathname-pure.asd
;;;; Cross-platform path handling with zero external dependencies

(asdf:defsystem #:cl-pathname-pure
  :description "Pure Common Lisp cross-platform pathname handling library"
  :author "Parkian Company LLC"
  :license "BSD-3-Clause"
  :version "1.0.0"
  :serial t
  :components ((:file "package")
               (:module "src"
                :serial t
                :components ((:file "pathname")))))
