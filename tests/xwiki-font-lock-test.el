;;; xwiki-font-lock-test.el --- Tests for font-lock-keywords in xwiki -*- lexical-binding: t; -*-

;; Copyright (C) 2021 Ackerley Tng

;; Author: Ackerley Tng <ackerleytng@gmail.com>
;; Maintainer: Ackerley Tng <ackerleytng@gmail.com>
;; Created: Oct 15, 2021
;; Version: 0.0.1
;; Package-Requires: ((emacs "27.1"))
;; Keywords: XWiki
;; URL: https://github.com/ackerleytng/xwiki-mode

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the Free
;; Software Foundation, either version 3 of the License, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;; more details.

;; You should have received a copy of the GNU General Public License along with
;; this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; See README.md for details

;;; Code:

(require 'ert)
(require 'xwiki-mode)

(defmacro xwiki-test-string-mode (mode string &rest body)
  "Run BODY in a temporary buffer containing STRING in MODE."
  (declare (indent 2))
  `(let ((win (selected-window)))
     (unwind-protect
         (with-temp-buffer
           (set-window-buffer win (current-buffer) t)
           (erase-buffer)
           (insert ,string)
           (funcall ,mode)
           (setq-default indent-tabs-mode nil)
           (goto-char (point-min))
           (font-lock-ensure)
           (prog1 ,@body (kill-buffer))))))

(defmacro xwiki-test-string (string &rest body)
  "Run BODY in a temporary buffer containing STRING in `xwiki-mode'."
  (declare (indent 1))
  `(xwiki-test-string-mode 'xwiki-mode ,string ,@body))

(defun xwiki-test-report-property-range (begin end prop)
  "Report buffer substring and property PROP from BEGIN to END."
  (message "Buffer substring: %s" (buffer-substring begin (1+ end)))
  (message "Properties in range are as follows:")
  (dolist (loc (number-sequence begin end))
    (message "%d: %s" loc (get-char-property loc prop))))

(defun xwiki-test-range-has-property (begin end prop value)
  "Verify that range BEGIN to END has PROP equal to or containing VALUE."
  (let (vals fail-loc)
    (setq fail-loc
          (catch 'fail
            (dolist (loc (number-sequence begin end))
              (setq vals (get-char-property loc prop))
              (if (and vals (listp vals))
                  (unless (memq value vals)
                    (throw 'fail loc))
                (unless (eq vals value)
                  (throw 'fail loc))))))
    (when fail-loc
      (message "Testing range (%d,%d) for property %s equal to %s."
               begin end prop value)
      (message "Expected value (%s) not found in property (%s) at location %d" value prop fail-loc)
      (xwiki-test-report-property-range begin end prop))
    (should-not fail-loc)))

(defun xwiki-test-range-has-face (begin end face)
  "Verify that the range from BEGIN to END has face FACE."
  (xwiki-test-range-has-property begin end 'face face))

;;; Tests ============================================================

(ert-deftest test-xwiki-view-mode/xwiki-underline-face ()
  "Basic test for `xwiki-underline-face' of `xwiki-view-mode'."
  (let ((test-string "regular __underline__ regular"))
    (xwiki-test-string
        test-string
      (xwiki-test-range-has-face 1 8 nil)
      (xwiki-test-range-has-face 9 10 'xwiki-markup-face)
      (xwiki-test-range-has-face 11 19 'xwiki-underline-face)
      (xwiki-test-range-has-face 20 21 'xwiki-markup-face)
      (xwiki-test-range-has-face 22 30 nil))))

;; TODO don't underline the \n character
(ert-deftest test-xwiki-view-mode/xwiki-underline-face-multiline ()
  "Test `xwiki-underline-face' of `xwiki-view-mode'."
  (let ((test-string "__underline

second line__"))
    (xwiki-test-string
        test-string
      (xwiki-test-range-has-face 1 2 'xwiki-markup-face)
      (xwiki-test-range-has-face 3 24 'xwiki-underline-face)
      (xwiki-test-range-has-face 25 26 'xwiki-markup-face))))

(ert-deftest test-xwiki-view-mode/xwiki-bold-face ()
  "Basic test for `xwiki-bold-face' of `xwiki-view-mode'."
  (let ((test-string "regular **bold** regular"))
    (xwiki-test-string
        test-string
      (xwiki-test-range-has-face 1 8 nil)
      (xwiki-test-range-has-face 9 10 'xwiki-markup-face)
      (xwiki-test-range-has-face 11 14 'xwiki-bold-face)
      (xwiki-test-range-has-face 15 16 'xwiki-markup-face)
      (xwiki-test-range-has-face 17 24 nil))))

(provide 'xwiki-font-lock-test)
;;; xwiki-font-lock-test.el ends here