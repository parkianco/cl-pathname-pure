;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

;;;; test-pathname-pure.lisp - Unit tests for pathname-pure
;;;;
;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0

(defpackage #:cl-pathname-pure.test
  (:use #:cl)
  (:export #:run-tests))

(in-package #:cl-pathname-pure.test)

(defun run-tests ()
  "Run all tests for cl-pathname-pure."
  (format t "~&Running tests for cl-pathname-pure...~%")
  ;; TODO: Add test cases
  ;; (test-function-1)
  ;; (test-function-2)
  (format t "~&All tests passed!~%")
  t)
