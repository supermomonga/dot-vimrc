;; Kanari sugoi init.el (kanari)

(require 'cl)

;;{{{ -Common settings

;;{{{ --Appearance

;;{{{ CUI

(setq whitespace-style '(spaces tabs space-mark tab-mark))
(setq whitespace-display-mappings
      '(
       ;; (space-mark 32 [183] [46]) ; normal space, ·
        (space-mark 160 [164] [95])
        (space-mark 2208 [2212] [95])
        (space-mark 2336 [2340] [95])
        (space-mark 3616 [3620] [95])
        (space-mark 3872 [3876] [95])
        (space-mark ?\x3000 [?\□]) ;; Zenkaku space
        (tab-mark 9 [9655 9] [92 9]) ; tab, ▷
        ))

;; Show trailing whitespaces
(setq-default show-trailing-whitespace t)

;; Highlight current line
(global-hl-line-mode)

;; Disable startup message
(setq inhibit-startup-message t)

;;}}}


;;{{{ GUI

;; Open file when grag and frop files from another applications
(define-key global-map [ns-drag-file] 'ns-find-file)

;; Transparent window
(set-frame-parameter (selected-frame) 'alpha '(100 100))

;; Hide toolbar
(tool-bar-mode 0)

;; Hide scrollbar
(set-scroll-bar-mode nil)

;; (column-number-mode t)

;; Show line number
(global-linum-mode t)

;;}}}

;;}}}


;;{{{ --Language

;; Use japanese
(set-language-environment 'Japanese)

;; Use UTF-8 as possible as can
(prefer-coding-system 'utf-8)

;;}}}

;;{{{ --Edit

;; Save cursor position
(when (require 'saveplace nil t)
  (setq-default save-place t))

;; Automatically insert newline
(setq require-final-newline t)

;;}}}

;;{{{ --Font

(when (fboundp 'global-font-lock-mode)
  (global-font-lock-mode t)
  (setq font-lock-support-mode 'jit-lock-mode))

(create-fontset-from-ascii-font "September-15:weight=normal:slant=normal" nil "september")
(set-fontset-font "fontset-september" 'japanese-jisx0208 (font-spec :family "September" :size 15) nil 'append)
(add-to-list 'default-frame-alist '(font . "fontset-september"))

;; (when (find-font (font-spec :family "September"))
;;   (set-frame-font "September-15")
;;   (set-face-attribute 'default nil :family "September" :height 150)
;;   (set-fontset-font nil 'unicode (font-spec :family "September") nil 'append)
;;   (set-fontset-font nil '( #x3000 .  #x30ff) (font-spec :family "September") nil 'prepend)
;;   (set-fontset-font nil '( #xff00 .  #xffef) (font-spec :family "September") nil 'prepend)
;;   (add-to-list 'default-frame-alist '(font . "September"))
;; )

;;}}}


;;{{{ --Others

;; Set secret settings
(load "~/.emacs.d/secret.el" nil t)

;;}}}

;;}}}


;;{{{ -Functions

;; Notification center
(defun notif (title message)
  (shell-command
   (concat
    "echo 'display notification \"'"
    message
    "'\" with title \""
    title
    "\"' | osascript"))
  )

;;}}}

;;{{{ -Package manager

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

;;{{{ -Package list

(el-get 'sync 'evil)
;; (el-get 'sync 'elscreen)
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
(el-get 'sync 'tabbar)
(el-get 'sync 'popwin)
(el-get 'sync 'color-theme-railscasts)

;;}}}


;;{{{ -Evil settings

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

(when (require 'evil-elscreen nil t))

;;}}}


;;{{{ -Other packages

;;{{{ --folding.el
(when (require 'folding nil t)
  ;; (autoload 'folding-mode "folding" "Folding mode" t)
  (folding-mode-add-find-file-hook)
  (add-hook 'emacs-lisp-mode-hook 'folding-mode)
  (define-key evil-normal-state-map (kbd "z a") 'folding-toggle-show-hide)
)
;;}}}

;;{{{ --helm
(when (require 'helm nil t)
  (define-key evil-normal-state-map (kbd "SPC f") 'helm-mini)
  (define-key evil-normal-state-map (kbd "SPC b") 'helm-buffers-list)
  (define-key evil-normal-state-map (kbd "SPC SPC") 'helm-M-x)
)
;;}}}

;;{{{ --smartrep
(when (require 'smartrep nil t)
  (smartrep-define-key evil-normal-state-map "C-c"
		       '(("+" . 'evil-numbers/inc-at-pt)
			 ("-" . 'evil-numbers/dec-at-pt)))
  (when (require 'tabbar nil t)
    (smartrep-define-key evil-normal-state-map "g"
      '(("t" . 'tabbar-forward-tab)
	("T" . 'tabbar-backward-tab)))
    )
)
;;}}}

;;{{{ --tabbar

(when (require 'tabbar nil t)
  (tabbar-mode 1)
  (tabbar-mwheel-mode -1)
  (setq tabbar-buffer-groups-function nil)
  (dolist (btn '(tabbar-buffer-home-button tabbar-scroll-left-button tabbar-scroll-right-button))
    (set btn (cons (cons "" nil) (cons "" nil))))
  ;; (setq tabbar-auto-scroll-flag nil)
  (setq tabbar-separator '(1.5))
  (set-face-attribute 'tabbar-default nil :family "September" :background "black" :foreground "gray72" :height 0.9)
  (set-face-attribute 'tabbar-unselected nil :background "black" :foreground "grey72" :box nil)
  (set-face-attribute 'tabbar-selected nil :background "black" :foreground "#c82829" :box nil)
  (set-face-attribute 'tabbar-button nil :box nil)
  (set-face-attribute 'tabbar-separator nil :height 1.2)
  (defvar my-tabbar-show-buffers
    '("*scratch*" "*Messages*" "*Backtrace*" "*Colors*" "*Faces*" "*vc-" "*eshell*" "*Lingr Status*"))
  (defvar my-tabbar-hide-buffers
    '("*" "Lingr["))
  (defun my-tabbar-buffer-list ()
    ;; (let* ((hides (list ?\  ?\*))
    (let* ((hides (regexp-opt my-tabbar-hide-buffers))
	   (shows (regexp-opt my-tabbar-show-buffers))
	   (cur-buf (current-buffer))
	   (tabs (delq
		  nil
		  (mapcar (lambda (buf)
			    (let ((name (buffer-name buf)))
			      (when (or (string-match shows name)
					(not (string-match hides name)))
				buf)))
			  (buffer-list)))))
      (if (memq cur-buf tabs) tabs (cons cur-buf tabs))))
  (setq tabbar-buffer-list-function 'my-tabbar-buffer-list)
)

;;}}}


;;{{{ --lingr

(when (require 'lingr nil t)
  (setq lingr-username secret-lingr-username
	lingr-password secret-lingr-password
	lingr-icon-mode t
	lingr-image-convert-program "/usr/local/bin/convert"
	lingr-icon-fix-size 24
	)
  (evil-define-key 'normal lingr-room-map (kbd "j") 'lingr-room-next-nick)
  (evil-define-key 'normal lingr-room-map (kbd "k") 'lingr-room-previous-nick)
  (evil-define-key 'normal lingr-room-map (kbd "s") 'lingr-say-command)
  (evil-define-key 'normal lingr-room-map (kbd "r") 'lingr-refresh-room)
  (evil-define-key 'normal lingr-room-map (kbd "S-s") 'lingr-show-status)
  (evil-define-key 'normal lingr-room-map (kbd "C-j") 'lingr-room-next-message)
  (evil-define-key 'normal lingr-room-map (kbd "C-k") 'lingr-room-previous-message)
  (evil-define-key 'normal lingr-status-buffer-map (kbd "C-RET") 'lingr-status-switch-room)
  (evil-define-key 'normal lingr-status-buffer-map (kbd "RET") 'lingr-status-switch-room-other-window)
  (evil-define-key 'normal lingr-status-buffer-map (kbd "n") 'lingr-room-next-message)
  (evil-define-key 'normal lingr-status-buffer-map (kbd "p") 'lingr-room-previous-message)
  (evil-define-key 'normal lingr-status-buffer-map (kbd "j") 'lingr-status-next-room)
  (evil-define-key 'normal lingr-status-buffer-map (kbd "k") 'lingr-status-previous-room)
  (evil-define-key 'normal lingr-status-buffer-map (kbd "f") 'lingr-status-jump-message)
  ;; (evil-define-key 'insert lingr-status-buffer-map (kbd "C-RET") ')
  ;; (print lingr-say-buffer-map)
  (defun lingr-notif-message (message)
    (notif (concat "Lingr " (lingr-message-room message))
    	   (concat (lingr-message-nick message) ":" (lingr-message-text message))))
  (add-hook 'lingr-message-hook 'lingr-notif-message)
)

;;}}}


;;}}}


;;{{{ -Theme

(add-to-list 'custom-theme-load-path "~/.emacs.d/el-get/")
;; (load-theme 'zenburn t)
(when (require 'color-theme-railscasts nil t))

;;}}}


(eshell)
