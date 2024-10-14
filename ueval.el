;;; ueval.el --- Universal Evaluation Utilities  -*- lexical-binding: t; -*-

;; Copyright (C) 2024  Shen, Jen-Chieh

;; Author: Shen, Jen-Chieh <jcs090218@gmail.com>
;; Maintainer: Shen, Jen-Chieh <jcs090218@gmail.com>
;; URL: https://github.com/jcs-elpa/ueval
;; Version: 0.1.0
;; Package-Requires: ((emacs "26.1"))
;; Keywords: convenience eval

;; This file is not part of GNU Emacs.

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:
;;
;; Universal Evaluation Utilities.
;;

;;; Code:

(defgroup ueval nil
  "Universal Evaluation Utilities."
  :prefix "ueval-"
  :group 'ueval)

;;
;;; Util

(defun ueval--fboundp-apply (fnc &rest args)
  "Call FNC with ARGS if exists."
  (when (fboundp fnc) (apply fnc args)))

;;
;;; Extensions

(declare-function sly-connected-p "ext:sly.el")
(declare-function sly-eval-buffer "ext:sly.el")
(declare-function sly-eval-defun "ext:sly.el")
(declare-function sly-eval-last-expression "ext:sly.el")
(declare-function sly-eval-region "ext:sly.el")

(defun ueval--sly-p ()
  "Return non-nil if we should use `sly' evaluations instead."
  (when (and (featurep 'sly)
             (memq major-mode '(lisp-mode)))
    (ueval--fboundp-apply #'sly-connected-p)))

;;
;;; Core

;;;###autoload
(defun ueval-buffer ()
  "Universal `eval-buffer'."
  (interactive)
  (call-interactively
   (cond ((ueval--sly-p) #'sly-eval-buffer)
         (t              #'eval-buffer))))

;;;###autoload
(defun ueval-defun ()
  "Universal `eval-defun' command."
  (interactive)
  (call-interactively
   (cond ((ueval--sly-p) #'sly-eval-defun)
         (t              #'eval-defun))))

;;;###autoload
(defun ueval-expression ()
  "Universal `eval-expression' command."
  (interactive)
  (call-interactively
   (cond ((ueval--sly-p) #'sly-eval-last-expression)
         (t              #'eval-expression))))

;;;###autoload
(defun ueval-region ()
  "Universal `eval-region' command."
  (interactive)
  (call-interactively
   (cond ((ueval--sly-p) #'sly-eval-region)
         (t              #'eval-region))))

(provide 'ueval)
;;; ueval.el ends here
