(defvar redmine2org-ticket-list-prog
  (let ((current (or load-file-name (buffer-file-name))))
    (expand-file-name "ticket-list.py" (file-name-directory current)))
  "Path to the ticket-list.py.")

(defvar redmine2org-ticket-view-prog
  (let ((current (or load-file-name (buffer-file-name))))
    (expand-file-name "ticket-view.py" (file-name-directory current)))
  "Path to the ticket-view.py.")

(defun open-redmine-ticket-list ()
  (interactive)
  (if (get-buffer "redmine2org:ticket-list")
      (switch-to-buffer "redmine2org:ticket-list")
    (progn 
      (let (buffer)
        (setq buffer (get-buffer-create "redmine2org:ticket-list"))
        (call-process-shell-command (concat "python3 " redmine2org-ticket-list-prog) () buffer t)
        (switch-to-buffer buffer)
        (goto-char 0)
        (redmine2org-mode)
        (read-only-mode)))))

(defun view-ticket (ticket-num) ""
  (interactive)
  (let (buffer)
    (if (get-buffer-create "ticket-view") (kill-buffer "ticket-view"))
    (setq buffer (get-buffer-create "ticket-view"))
    (call-process-shell-command (concat "python3 " redmine2org-ticket-view-prog " " ticket-num) () buffer t)
    (save-current-buffer
      (set-buffer buffer)
      (goto-char 0))
    (set-window-buffer (split-window nil 10) buffer)
    (setq redmine2org-ticket-view-id ticket-num)))

(defun view-ticket-at-point ()
  (interactive)
  (let (position)
    (save-excursion
      (beginning-of-line)
      (setq position (point)))
    (view-ticket
     (buffer-substring-no-properties (+ position 1) (+ position 5)))))

(defun toggle-ticket-view ()
  (interactive)
  (let (window)
    (if (setq window (and (get-buffer "ticket-view") (get-buffer-window "ticket-view")))
        (delete-window window)
      (view-ticket-at-point))))

(defun scroll-ticket-view ()
  (interactive)
  (if (get-buffer-window "ticket-view")
      (progn
        (setq other-window-scroll-buffer (get-buffer "ticket-view"))
        (scroll-other-window)
        (setq other-window-scroll-buffer nil))
    nil))

(defun scroll-down-ticket-view ()
  (interactive)
  (if (get-buffer-window "ticket-view")
      (progn
        (setq other-window-scroll-buffer (get-buffer "ticket-view"))
        (scroll-other-window (* -1 (window-height (get-buffer-window "ticket-view"))))
        (setq other-window-scroll-buffer nil))
    nil))

(defun redmine2org-space-key ()
  (interactive)
  (if (and (get-buffer "ticket-view") (get-buffer-window "ticket-view"))
      (let (ticket-id)
          (save-excursion
            (beginning-of-line)
            (setq ticket-id (buffer-substring-no-properties (+ (point) 1) (+ (point) 5))))
        (if (equal ticket-id redmine2org-ticket-view-id)
            (scroll-ticket-view)
          (view-ticket-at-point)))
    (view-ticket-at-point)))

(defun redmine2org-shift-space-key ()
  (interactive)
  (if (and (get-buffer "ticket-view") (get-buffer-window "ticket-view"))
      (let (ticket-id)
          (save-excursion
            (beginning-of-line)
            (setq ticket-id (buffer-substring-no-properties (+ (point) 1) (+ (point) 5))))
        (if (equal ticket-id redmine2org-ticket-view-id)
            (scroll-down-ticket-view)
          (view-ticket-at-point)))
    (view-ticket-at-point)))
  
(defvar redmine2org-mode-map nil)
(unless redmine2org-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "v" 'toggle-ticket-view)
    (define-key map (kbd "SPC") 'redmine2org-space-key)
    (define-key map (kbd "S-SPC") 'redmine2org-shift-space-key)
    (setq redmine2org-mode-map map)))

(defun redmine2org-mode ()
  (interactive)
  (use-local-map redmine2org-mode-map)
  (setq major-mode 'redmine2org-mode)
  (setq mode-name "redmine2org")
  (run-hooks 'redmine2org-mode-hook))

