;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

;;;; package.lisp
;;;; Package definition for cl-pathname-pure

(defpackage #:cl-pathname-pure
  (:use #:cl)
  (:export
   ;; Path merging and manipulation
   #:merge-pathnames*
   #:pathname-parent
   #:ensure-directory-pathname
   ;; Path predicates
   #:pathname-directory-p
   ;; Path component accessors
   #:pathname-name*
   #:pathname-type*
   ;; Native namestring conversion
   #:native-namestring
   #:parse-native-namestring
   ;; Platform detection
   #:*platform*
   #:windows-p
   #:unix-p))
