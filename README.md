# cl-pathname-pure

Pure Common Lisp cross-platform path handling library with zero external dependencies.

## Installation

```lisp
(asdf:load-system :cl-pathname-pure)
```

## Usage

```lisp
(use-package :cl-pathname-pure)

;; Merge pathnames with better edge-case handling
(merge-pathnames* "file.txt" "/home/user/")

;; Get parent directory
(pathname-parent "/home/user/docs/")
;; => #P"/home/user/"

;; Ensure directory pathname
(ensure-directory-pathname "/home/user/docs")
;; => #P"/home/user/docs/"

;; Check if path is directory
(pathname-directory-p "/home/user/")  ; => T

;; Native namestring conversion
(native-namestring #P"/home/user/file.txt")
;; => "/home/user/file.txt" (Unix) or "C:\\Users\\file.txt" (Windows)

;; Parse native namestring
(parse-native-namestring "/home/user/file.txt")
```

## API

- `merge-pathnames*` - Enhanced pathname merging
- `pathname-directory-p` - Check if pathname is a directory
- `pathname-name*` - Get name component (handles edge cases)
- `pathname-type*` - Get type component (handles edge cases)
- `pathname-parent` - Get parent directory
- `ensure-directory-pathname` - Ensure path ends with /
- `native-namestring` - Convert to platform-native string
- `parse-native-namestring` - Parse platform-native string

## License

BSD-3-Clause. Copyright (c) 2024-2026 Parkian Company LLC.
