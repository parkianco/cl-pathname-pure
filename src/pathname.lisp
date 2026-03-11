;;;; pathname.lisp
;;;; Cross-platform path handling implementation

(in-package #:cl-pathname-pure)

;;; Platform Detection

(defvar *platform*
  #+windows :windows
  #+unix :unix
  #-(or windows unix) :unknown
  "The current platform (:windows, :unix, or :unknown).")

(defun windows-p ()
  "Return T if running on Windows."
  (eq *platform* :windows))

(defun unix-p ()
  "Return T if running on Unix-like system."
  (eq *platform* :unix))

;;; Path Predicates

(defun pathname-directory-p (pathname)
  "Return T if PATHNAME represents a directory."
  (let ((p (pathname pathname)))
    (and (null (pathname-name p))
         (null (pathname-type p)))))

;;; Path Component Accessors

(defun pathname-name* (pathname)
  "Return the name component of PATHNAME, or NIL if none.
   Unlike CL:PATHNAME-NAME, this handles edge cases consistently."
  (let* ((p (pathname pathname))
         (name (pathname-name p)))
    (if (or (null name) (eq name :unspecific))
        nil
        name)))

(defun pathname-type* (pathname)
  "Return the type component of PATHNAME, or NIL if none.
   Unlike CL:PATHNAME-TYPE, this handles edge cases consistently."
  (let* ((p (pathname pathname))
         (type (pathname-type p)))
    (if (or (null type) (eq type :unspecific))
        nil
        type)))

;;; Path Manipulation

(defun ensure-directory-pathname (pathname)
  "Ensure PATHNAME represents a directory by adding trailing slash if needed."
  (let ((p (pathname pathname)))
    (if (pathname-directory-p p)
        p
        (make-pathname :directory (append (or (pathname-directory p) '(:relative))
                                          (list (file-namestring p)))
                       :name nil
                       :type nil
                       :defaults p))))

(defun pathname-parent (pathname)
  "Return the parent directory of PATHNAME."
  (let* ((p (ensure-directory-pathname pathname))
         (dir (pathname-directory p)))
    (cond
      ((or (null dir) (null (cdr dir)))
       ;; Already at root or relative with no components
       p)
      (t
       (make-pathname :directory (butlast dir)
                      :name nil
                      :type nil
                      :defaults p)))))

(defun merge-pathnames* (pathname &optional (defaults *default-pathname-defaults*))
  "Merge PATHNAME with DEFAULTS, handling edge cases better than CL:MERGE-PATHNAMES.
   - Empty pathname components are treated as unspecified
   - Relative paths are properly combined"
  (let ((p (pathname pathname))
        (d (pathname defaults)))
    (make-pathname
     :host (or (pathname-host p) (pathname-host d))
     :device (or (pathname-device p) (pathname-device d))
     :directory (let ((pdir (pathname-directory p))
                      (ddir (pathname-directory d)))
                  (cond
                    ((null pdir) ddir)
                    ((eq (car pdir) :absolute) pdir)
                    ((null ddir) pdir)
                    (t (append ddir (cdr pdir)))))
     :name (or (pathname-name* p) (pathname-name* d))
     :type (or (pathname-type* p) (pathname-type* d))
     :version (or (pathname-version p) (pathname-version d)))))

;;; Native Namestring Conversion

(defun native-namestring (pathname)
  "Convert PATHNAME to a native namestring for the current platform."
  (let ((p (pathname pathname)))
    (if (windows-p)
        (windows-namestring p)
        (unix-namestring p))))

(defun unix-namestring (pathname)
  "Convert PATHNAME to a Unix-style namestring."
  (let ((p (pathname pathname)))
    (with-output-to-string (s)
      (let ((dir (pathname-directory p)))
        (when dir
          (when (eq (car dir) :absolute)
            (write-char #\/ s))
          (dolist (component (cdr dir))
            (cond
              ((eq component :up) (write-string ".." s))
              ((eq component :back) (write-string ".." s))
              ((stringp component) (write-string component s)))
            (write-char #\/ s))))
      (when (pathname-name* p)
        (write-string (pathname-name p) s)
        (when (pathname-type* p)
          (write-char #\. s)
          (write-string (pathname-type p) s))))))

(defun windows-namestring (pathname)
  "Convert PATHNAME to a Windows-style namestring."
  (let ((p (pathname pathname)))
    (with-output-to-string (s)
      (let ((device (pathname-device p)))
        (when (and device (not (eq device :unspecific)))
          (write-string device s)
          (write-char #\: s)))
      (let ((dir (pathname-directory p)))
        (when dir
          (when (eq (car dir) :absolute)
            (write-char #\\ s))
          (dolist (component (cdr dir))
            (cond
              ((eq component :up) (write-string ".." s))
              ((eq component :back) (write-string ".." s))
              ((stringp component) (write-string component s)))
            (write-char #\\ s))))
      (when (pathname-name* p)
        (write-string (pathname-name p) s)
        (when (pathname-type* p)
          (write-char #\. s)
          (write-string (pathname-type p) s))))))

(defun parse-native-namestring (namestring)
  "Parse a native namestring into a pathname for the current platform."
  (if (windows-p)
      (parse-windows-namestring namestring)
      (parse-unix-namestring namestring)))

(defun parse-unix-namestring (namestring)
  "Parse a Unix-style namestring into a pathname."
  (let* ((absolute-p (and (> (length namestring) 0)
                          (char= (char namestring 0) #\/)))
         (parts (split-string namestring #\/))
         (parts (remove "" parts :test #'string=)))
    (if (null parts)
        (make-pathname :directory (if absolute-p '(:absolute) nil))
        (let ((last-part (car (last parts)))
              (dir-parts (butlast parts)))
          (multiple-value-bind (name type)
              (split-filename last-part)
            ;; Check if last part looks like a directory (ends with /)
            (if (and (> (length namestring) 0)
                     (char= (char namestring (1- (length namestring))) #\/))
                (make-pathname :directory (cons (if absolute-p :absolute :relative)
                                                parts))
                (make-pathname :directory (when (or absolute-p dir-parts)
                                            (cons (if absolute-p :absolute :relative)
                                                  dir-parts))
                               :name name
                               :type type)))))))

(defun parse-windows-namestring (namestring)
  "Parse a Windows-style namestring into a pathname."
  (let* ((device nil)
         (rest namestring))
    ;; Check for drive letter
    (when (and (>= (length namestring) 2)
               (alpha-char-p (char namestring 0))
               (char= (char namestring 1) #\:))
      (setf device (string (char namestring 0)))
      (setf rest (subseq namestring 2)))
    ;; Parse path
    (let* ((absolute-p (and (> (length rest) 0)
                            (or (char= (char rest 0) #\\)
                                (char= (char rest 0) #\/))))
           (parts (split-string rest '(#\\ #\/)))
           (parts (remove "" parts :test #'string=)))
      (if (null parts)
          (make-pathname :device device
                         :directory (if absolute-p '(:absolute) nil))
          (let ((last-part (car (last parts)))
                (dir-parts (butlast parts)))
            (multiple-value-bind (name type)
                (split-filename last-part)
              (make-pathname :device device
                             :directory (when (or absolute-p dir-parts)
                                          (cons (if absolute-p :absolute :relative)
                                                dir-parts))
                             :name name
                             :type type)))))))

;;; Helper Functions

(defun split-string (string delimiters)
  "Split STRING by any character in DELIMITERS (a character or list of characters)."
  (let ((delims (if (listp delimiters) delimiters (list delimiters)))
        (result '())
        (start 0))
    (loop for i from 0 below (length string)
          when (member (char string i) delims)
            do (push (subseq string start i) result)
               (setf start (1+ i)))
    (push (subseq string start) result)
    (nreverse result)))

(defun split-filename (filename)
  "Split FILENAME into name and type components.
   Returns (VALUES name type)."
  (let ((dot-pos (position #\. filename :from-end t)))
    (cond
      ((null dot-pos)
       (values filename nil))
      ((zerop dot-pos)
       ;; Hidden file like .bashrc
       (values filename nil))
      (t
       (values (subseq filename 0 dot-pos)
               (subseq filename (1+ dot-pos)))))))
