;;;; Package evil
(sm-package evil
            :package-manager nil
            :unmanaged-p t)

;;; Initialization
(add-to-list 'load-path (concat user-emacs-directory "site-lisp/evil"))
(require 'evil)
(evil-mode 1)

;;; Basic bindings
(evil-define-key 'motion Info-mode-map
  (kbd "<XF86Back>") 'Info-history-back
  (kbd "<XF86Forward>") 'Info-history-forward)

(define-key evil-insert-state-map [remap newline] 'evil-ret)
(define-key evil-insert-state-map (kbd "C-k") 'kill-line)
(define-key evil-insert-state-map (kbd "C-S-k") 'evil-insert-digraph)
(define-key evil-insert-state-map (kbd "\C-e") nil)
(define-key evil-insert-state-map (kbd "\C-y") nil)
(evil-define-key 'normal emacs-lisp-mode-map (kbd "M-.") 'find-function)
(define-key evil-normal-state-map (kbd "M-.") nil)
(define-key evil-insert-state-map (kbd "C-d") 'delete-char)

(evil-define-motion evil-ret (count)
  "Move the cursor COUNT lines down.
If point is on a widget or a button, click on it.
In Insert state, insert a newline."
  :type line
  (evil-ret-gen count evil-auto-indent))

;;; Integrations

(sm-integrate-with (:package slime)
  (evil-define-key 'normal lisp-mode-map (kbd "M-.") 'slime-edit-definition))

(sm-integrate-with (:package browse-kill-ring)
  (defadvice evil-paste-pop (around evil-kill-ring-browse-maybe (arg) activate)
    "If last action was not a yank, run `browse-kill-ring' instead."
    ;; yank-pop has an (interactive "*p") form which does not allow
    ;; it to run in a read-only buffer.  We want browse-kill-ring to
    ;; be allowed to run in a read only buffer, so we change the
    ;; interactive form here.  In that case, we need to
    ;; barf-if-buffer-read-only if we're going to call yank-pop with
    ;; ad-do-it
    (interactive "p")
    (if (not (memq last-command '(evil-paste-after evil-paste-before yank)))
        (browse-kill-ring)
      (barf-if-buffer-read-only)
      ad-do-it)))

(sm-integrate-with (:package ace-jump-mode)
  (mapc (lambda (state)
          (evil-global-set-key state (kbd "SPC") 'evil-ace-jump-char-mode)
          (evil-global-set-key state (kbd "C-SPC") 'evil-ace-jump-line-mode)
          (evil-global-set-key state (kbd "M-SPC")  'evil-ace-jump-word-mode))
        '(normal motion))
  (defadvice evil-visual-line (before spc-for-line-jump activate)
    (define-key evil-motion-state-map (kbd "SPC") #'evil-ace-jump-line-mode))
  (defadvice evil-visual-char (before spc-for-char-jump activate)
    (define-key evil-motion-state-map (kbd "SPC") #'evil-ace-jump-char-mode))
  (defadvice evil-visual-block (before spc-for-char-jump activate)
    (define-key evil-motion-state-map (kbd "SPC") #'evil-ace-jump-char-mode)))

(sm-integrate-with (:package auto-complete)
  (define-key ac-completing-map (kbd "C-[")
    (lambda () (interactive) (ac-stop) (evil-normal-state))))

(sm-integrate-with (:package direx)
  (evil-global-set-key 'normal (kbd "C-d") 'popwin:direx))

(sm-integrate-with (:package ipa)
  (evil-global-set-key 'normal (kbd "M-i M-i") 'ipa-toggle)
  (evil-global-set-key 'normal (kbd "M-i i") 'ipa-insert)
  (evil-global-set-key 'normal (kbd "M-i e") 'ipa-edit)
  (evil-global-set-key 'normal (kbd "M-i m") 'ipa-move))

(sm-integrate-with (:package woman)
  (evil-global-set-key 'normal (kbd "K") 'woman-other-window)
  (add-hook 'Man-mode-hook '(lambda ()
                              (evil-change-state 'motion)
                              (evil-local-set-key 'motion (kbd "RET") 'woman-follow)
                              )))

(sm-integrate-with (:package zencoding-mode)
  (evil-define-key 'insert 'html-mode-map (kbd "<C-return>") 'zencoding-expand-line))

(sm-integrate-with (:package dired-efap)
  (evil-define-key 'normal dired-mode-map (kbd "C-c C-c") 'dired-efap))

(sm-integrate-with expand-region
  (evil-global-set-key 'visual (kbd "M-]") 'er/expand-region)
  (evil-global-set-key 'visual (kbd "M-[") 'er/contract-region))


;;; Temporary kludge

(defun evil-read-key (&optional prompt)
  "Read a key from the keyboard.
Translates it according to the input method."
  (let ((old-global-map (current-global-map))
        (new-global-map (make-sparse-keymap))
        ;;(overridinïg-terminal-local-map evil-read-key-map)
        (overriding-local-map evil-read-key-map)
        seq char cmd)
    (unwind-protect
        (condition-case nil
            (progn
              (define-key new-global-map [menu-bar]
                (lookup-key global-map [menu-bar]))
              (define-key new-global-map [tool-bar]
                (lookup-key global-map [tool-bar]))
              (add-to-list 'new-global-map
                           (make-char-table 'display-table
                                            'self-insert-command) t)
              (use-global-map new-global-map)
              (setq seq (read-key-sequence prompt nil t)
                    char (aref seq 0)
                    cmd (key-binding seq))
              (while (arrayp cmd)
                (setq char (aref cmd 0)
                      cmd (key-binding cmd)))
              (cond
               ((eq cmd 'self-insert-command)
                char)
               (cmd
                (call-interactively cmd))
               (t
                (error "No replacement character typed"))))
          (quit
           (when (fboundp 'evil-repeat-abort)
             (evil-repeat-abort))
           (signal 'quit nil)))
      (use-global-map old-global-map))))

(define-key evil-ex-completion-map (kbd "C-p") 'previous-complete-history-element)
(define-key evil-ex-completion-map (kbd "M-p") 'previous-complete-history-element)
(define-key evil-ex-completion-map (kbd "M-n") 'next-complete-history-element)

(sm-provide :package evil)
