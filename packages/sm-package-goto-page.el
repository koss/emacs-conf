;;;; Package goto-page
(sm-package goto-page
            :package-manager nil
            :unmanaged-p t)

(defun next-page (&optional count)
  (forward-page count)
  (and (/= (point) (point-max))
       (point)))

(defmacro* dopage ((page-identifier &optional index) &body body)
  (let ((page-id-beg (gensym))
        (page-id-end (gensym))
        (buffer-end (gensym))
        (idx (or index (gensym)))
        (next-page-pos (gensym))
        (next-page (gensym)))
    `(flet ((,next-page (&optional count)
                        (forward-page count)
                        (and (/= (point) (point-max))
                             (point))))
       (save-excursion
         (goto-char (point-min))
         (do* ((,next-page-pos (next-page) (next-page))
               (,idx 0 (1+ ,idx)))
             ((not ,next-page-pos))
           (let* ((,page-id-beg (line-beginning-position 2))
                  (,page-id-end (line-end-position 2))
                  (,page-identifier (buffer-substring-no-properties ,page-id-beg ,page-id-end)))
             ,@body))))))

(defun find-page-if (page-id matchp)
  (block foo
    (dopage (pid)
            (when (funcall matchp page-id pid)
              (return-from foo (line-beginning-position 2))))
    nil))


(setq goto-page-bob-identifier (propertize "BEGINNING" 'goto-page-pos 'point-min 'face 'success))

(setq goto-page-eob-identifier (propertize "END" 'goto-page-pos 'point-max 'face 'error))

(defun page-start-pos (page-id matchp)
  (let ((pos (get-text-property 0 'goto-page-pos page-id)))
    (cond ((number-or-marker-p pos)
           pos)
          ((functionp pos)
           (funcall pos)))))

(defun* buffer-page-identifiers (&optional buffer)
  (let ((buf (or buffer (current-buffer)))
        id-list)
    (with-current-buffer buf
      (push goto-page-bob-identifier id-list)
      (dopage (page-id idx)
              (let ((pos (line-beginning-position 2)))
                (push (propertize page-id 'goto-page-pos pos)
                      id-list)))
      (push goto-page-eob-identifier id-list))
    (reverse id-list)))


(defun only-alphanum (str)
  (let ((pos (get-text-property 0 'goto-page-pos str)))
    (replace-regexp-in-string "[^[:alnum:]]+"
                              (propertize " " 'goto-page-pos pos)
                              str)))

(setq goto-page-page-id-format-fn 'only-alphanum)

(defun* goto-page (page-id &optional (matchp 'string-match-p) (format-page-id-fn 'only-alphanum))
  (interactive  (list (let ((bpi (mapcar goto-page-page-id-format-fn
                                         (buffer-page-identifiers))))
                        (let ((pid (ido-completing-read "Goto Page: " bpi nil t)))
                          (or (find-if (lambda (id)
                                         (string-match pid id))
                                       bpi)
                              (error "No pages on this buffer"))))))
  (let* ((pos (page-start-pos page-id matchp)))
    (when pos
      (goto-char pos))))

(sm-provide :package goto-page)
