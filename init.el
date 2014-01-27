
(require 'cl)

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (let (el-get-master-branch)
      (goto-char (point-max))
      (eval-print-last-sexp))))
(package-initialize)

(el-get 'sync 'evil)
;; (el-get 'sync 'evil-elscreen)
(el-get 'sync 'evil-indent-textobject)
;; (el-get 'sync 'evil-leader)
(el-get 'sync 'evil-matchit)
(el-get 'sync 'evil-nerd-commenter)
(el-get 'sync 'evil-numbers)
(el-get 'sync 'evil-paredit)
(el-get 'sync 'evil-surround)

;; TODO: improve el-get recipe
;; (el-get 'sync 'folding)

(el-get 'sync 'smartrep)


;; Evil settings

(when (require 'evil nil t)
  (evil-mode 1)
  ;; keymap
  (define-key evil-motion-state-map (kbd ";") 'evil-ex)
  ;; specific mode
  ;; (evil-set-initial-state 'eshell-mode 'emacs)
  )

(when (require 'evil-nerd-commenter nil t)
  (define-key evil-normal-state-map (kbd "C-- C--") 'evilnc-comment-or-uncomment-lines))

(when (require 'surround nil t)
  (global-surround-mode 1))

(when (require 'evil-matchit nil t)
  (global-evil-matchit-mode 1))


;; Other packages

(when (require 'folding nil t)
  (folding-mode-add-find-file-hook)
  (folding-add-to-marks-list 'emacs-lisp-mode "#{{{" "#}}}" nil t))

(when (require 'smartrep nil t)
  (smartrep-define-key evil-normal-state-map "C-c"
		       '(("+" . 'evil-numbers/inc-at-pt)
			 ("-" . 'evil-numbers/dec-at-pt))))


(eshell)
