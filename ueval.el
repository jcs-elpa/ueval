;;; ueval.el --- Universal Evaluation Utilities  -*- lexical-binding: t; -*-

;; Copyright (C) 2024-2025  Shen, Jen-Chieh

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

(declare-function sly "ext:sly.el")
(declare-function sly-connected-p "ext:sly.el")
(declare-function sly-eval-buffer "ext:sly.el")
(declare-function sly-eval-defun "ext:sly.el")
(declare-function sly-eval-last-expression "ext:sly.el")
(declare-function sly-eval-region "ext:sly.el")

(defun ueval--sly-p ()
  "Return non-nil if `sly' evluations is valid."
  (and (featurep 'sly)
       (memq major-mode '( lisp-mode))))

(defun ueval--sly-connected-p ()
  "Return non-nil; use `sly' evaluations instead."
  (when (ueval--sly-p)
    (ueval--fboundp-apply #'sly-connected-p)))

(declare-function cider "ext:cider.el")
(declare-function cider-connected-p "ext:cider.el")
(declare-function cider-eval-buffer "ext:cider.el")
(declare-function cider-eval-defun-at-point "ext:cider.el")
(declare-function cider-eval-sexp-at-point "ext:cider.el")
(declare-function cider-eval-region "ext:cider.el")

(defun ueval--cider-p ()
  "Return non-nil if `cider' evluations is valid."
  (and (featurep 'cider)
       (memq major-mode '( clojure-mode clojurescript-mode))))

(defun ueval--cider-connected-p ()
  "Return non-nil; use `cider' evaluations instead."
  (when (ueval--cider-p)
    (ueval--fboundp-apply #'cider-connected-p)))

(declare-function geiser "ext:geiser.el")
(declare-function geiser-eval-buffer "ext:geiser.el")
(declare-function geiser-eval-definition "ext:geiser.el")
(declare-function geiser-eval-last-sexp "ext:geiser.el")
(declare-function geiser-eval-region "ext:geiser.el")
(declare-function geiser-repl--connection "ext:geiser.el")

(defun ueval--geiser-p ()
  "Return non-nil if `geiser' evluations is valid."
  (and (featurep 'geiser)
       (memq major-mode '( scheme-mode))))

(defun ueval--geiser-connected-p ()
  "Return non-nil; use `geiser' evaluations instead."
  (when (ueval--geiser-p)
    (ueval--fboundp-apply #'geiser-repl--connection)))

(declare-function racket-run "ext:racket-mode.el")
(declare-function racket-send-definition "ext:racket-mode.el")
(declare-function racket-send-last-sexp "ext:racket-mode.el")
(declare-function racket-send-region "ext:racket-mode.el")

(defun ueval--racket-p ()
  "Return non-nil if `racket' evluations is valid."
  (and (featurep 'racket-mode)
       (memq major-mode '( racket-mode racket-hash-lang-mode))))

(defun ueval--racket-connected-p ()
  "Return non-nil; use `racket' evaluations instead."
  (when (ueval--racket-p)
    t))

;;
;;; Core

;;;###autoload
(defun ueval ()
  "Universal start."
  (interactive)
  (cond ((ueval--sly-p)    (call-interactively #'sly))
        ((ueval--cider-p)  (call-interactively #'cider))
        ((ueval--geiser-p) (call-interactively #'geiser))
        ((ueval--racket-p) (call-interactively #'racket-run))
        (t
         (user-error "[ERROR] No universal start in this major-mode: %s" major-mode))))

;;;###autoload
(defun ueval-buffer ()
  "Universal `eval-buffer'."
  (interactive)
  (call-interactively
   (cond ((ueval--sly-connected-p)    #'sly-eval-buffer)
         ((ueval--cider-connected-p)  #'cider-eval-buffer)
         ((ueval--geiser-connected-p) #'geiser-eval-buffer)
         ((ueval--racket-connected-p) (lambda ()
                                        (interactive)
                                        (racket-send-region (point-min) (point-max))))
         (t                           #'eval-buffer))))

;;;###autoload
(defun ueval-defun ()
  "Universal `eval-defun' command."
  (interactive)
  (call-interactively
   (cond ((ueval--sly-connected-p)    #'sly-eval-defun)
         ((ueval--cider-connected-p)  #'cider-eval-defun-at-point)
         ((ueval--geiser-connected-p) #'geiser-eval-definition)
         ((ueval--racket-connected-p) #'racket-send-definition)
         (t                           #'eval-defun))))

;;;###autoload
(defun ueval-expression ()
  "Universal `eval-expression' command."
  (interactive)
  (call-interactively
   (cond ((ueval--sly-connected-p)    #'sly-eval-last-expression)
         ((ueval--cider-connected-p)  #'cider-eval-sexp-at-point)
         ((ueval--geiser-connected-p) #'geiser-eval-last-sexp)
         ((ueval--racket-connected-p) #'racket-send-last-sexp)
         (t                           #'eval-expression))))

;;;###autoload
(defun ueval-region ()
  "Universal `eval-region' command."
  (interactive)
  (call-interactively
   (cond ((ueval--sly-connected-p)    #'sly-eval-region)
         ((ueval--cider-connected-p)  #'cider-eval-region)
         ((ueval--geiser-connected-p) #'geiser-eval-region)
         ((ueval--racket-connected-p) #'racket-send-region)
         (t                           #'eval-region))))

(provide 'ueval)
;;; ueval.el ends here
