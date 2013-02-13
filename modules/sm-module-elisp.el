;;;; Module elisp
(sm-module elisp
           :unmanaged-p nil
           :require-packages '("elisp-slime-nav" "ale-fixme" "auto-complete" "hl-sexp"))

(sm-module-pre (elisp)
  ;; TODO insert your pre-package-initialization code here
  )

(sm-module-post (elisp)
  ;; Utility function to display point value on minibuffer
  (defun message-point()
    (interactive)
    (message "Point: %S" (point)))

  ;; Activate minor modes
  (add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode) ;eldoc
  (add-hook 'emacs-lisp-mode-hook (lambda () (fic-ext-mode 1))) ;fic-ext-mode
  (add-hook 'emacs-lisp-mode-hook 'ac-emacs-lisp-mode-setup)
  (add-hook 'emacs-lisp-mode-hook '(lambda () (hl-sexp-mode 1)))

  ;; (evil-define-motion evil-forward-sexp (count)
  ;;   (forward-sexp count))
  ;; (evil-define-motion evil-forward-sexp (count)
  ;;   "Moves the cursor one sexp forward."
  ;;     (dotimes (i 1)
  ;;       (when (= (char-after  (point)) ?\n)
  ;;         (re-search-forward "[^\\\\])"))
  ;;       (cond ((= (char-after) ?\))
  ;;              (goto-char (+ 2 (point))))
  ;;             (t (forward-sexp)))))

  ;; (evil-define-motion evil-backward-sexp (count)
  ;;   (backward-sexp count))

  ;; (evil-define-motion evil-backward-sexp (count)
  ;;   "Moves the cursor one sexp backward."
  ;;     (dotimes (i 1)
  ;;       (while (= (char-before) ?\n)
  ;;         (ignore-errors (re-search-backward ")"))
  ;;         (forward-char))
  ;;       (cond ((= (char-before) ?\()
  ;;              (goto-char (1- (point))))
  ;;             (t (backward-sexp)))))


  ;; (evil-define-key 'normal lisp-interaction-mode-map
  ;;   (kbd "M-j") 'down-list
  ;;   (kbd "M-k") 'up-list
  ;;   (kbd "M-l") 'evil-forward-sexp
  ;;   (kbd "M-h") 'evil-backward-sexp)
  ;; (evil-define-key 'normal emacs-lisp-mode-map
  ;;   (kbd "M-j") 'down-list
  ;;   (kbd "M-k") 'up-list
  ;;   (kbd "M-l") 'evil-forward-sexp
  ;;   (kbd "M-h") 'evil-backward-sexp)

  )

(sm-provide :module elisp)
