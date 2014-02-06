
(require 'cl)


;;{{{ Common settings

;;{{{ Appearance

;;}}}

;;{{{ Language

;;}}}


;; Set secret settings
(load "~/.emacs.d/secret.el" nil t)


;;}}}




;;{{{ Package manager
(require 'package)
(add-to-list 'package-archives
  '("melpa" . "http://melpa.milkbox.net/packages/") t)
(print package-archives)

(add-to-list 'load-path "~/.emacs.d/el-get/el-get")
(unless (require 'el-get nil 'noerror)
  (with-current-buffer
      (url-retrieve-synchronously
       "https://raw.github.com/dimitri/el-get/master/el-get-install.el")
    (let (el-get-master-branch)
      (goto-char (point-max))
      (eval-print-last-sexp))))
;;}}}


;;{{{ Package list
(el-get 'sync 'evil)
;; (el-get 'sync 'evil-elscreen)
(el-get 'sync 'evil-indent-textobject)
;; (el-get 'sync 'evil-leader)
(el-get 'sync 'evil-matchit)
(el-get 'sync 'evil-nerd-commenter)
(el-get 'sync 'evil-numbers)
(el-get 'sync 'evil-paredit)
(el-get 'sync 'evil-surround)
(el-get 'sync 'helm)
(el-get 'sync 'lingr)
(el-get 'sync 'folding)
(el-get 'sync 'smartrep)
(el-get 'sync 'color-theme-railscasts)
(el-get 'sync 'zenburn-theme)
;;}}}


;;{{{ Evil settings
(when (require 'evil nil t)
  (evil-mode 1)
  ;; keymap
  (define-key evil-motion-state-map (kbd ";") 'evil-ex)
  ;; specific mode
  ;; (evil-set-initial-state 'eshell-mode 'emacs)
  ;; Fix cursor color
  (setq evil-default-cursor t)
  (set-cursor-color "#DCDCCC")
  )

(when (require 'evil-nerd-commenter nil t)
  (define-key evil-normal-state-map (kbd "C-- C--") 'evilnc-comment-or-uncomment-lines))

(when (require 'surround nil t)
  (global-surround-mode 1))

(when (require 'evil-matchit nil t)
  (global-evil-matchit-mode 1))
;;}}}


;;{{{ Other packages
(when (require 'folding nil t)
  ;; (autoload 'folding-mode "folding" "Folding mode" t)
  (folding-mode-add-find-file-hook)
  (add-hook 'emacs-lisp-mode-hook 'folding-mode)
  (define-key evil-normal-state-map (kbd "z a") 'folding-toggle-show-hide)
)

(when (require 'helm nil t)
  (define-key evil-normal-state-map (kbd "SPC f") 'helm-mini)
  (define-key evil-normal-state-map (kbd "SPC b") 'helm-buffers-list)
  (define-key evil-normal-state-map (kbd "SPC SPC") 'helm-M-x)
)

(when (require 'smartrep nil t)
  (smartrep-define-key evil-normal-state-map "C-c"
		       '(("+" . 'evil-numbers/inc-at-pt)
			 ("-" . 'evil-numbers/dec-at-pt))))

(when (require 'lingr nil t)
  (setq lingr-username secret-lingr-username
	lingr-password secret-lingr-password
	lingr-icon-mode t
	lingr-image-convert-program "/usr/local/bin/convert"
	lingr-icon-fix-size 32 
)) 
;;}}}


;;{{{ Theme
;; (add-to-list 'custom-theme-load-path "~/.emacs.d/el-get/zenburn-theme/")
(add-to-list 'custom-theme-load-path "~/.emacs.d/el-get/")
(load-theme 'zenburn t)
;; (when (require 'color-theme-railscasts nil t))
;;}}}





(eshell)
