;; Kanari sugoi init.el (kanari)

(require 'cl)


;; macros
;; bundle macro
(defmacro bundle (name &rest body)
  `(when (require ,name nil t) ,@body))


;; PATH
(defun append-path (path)
  (setenv "PATH" (concat (file-truename path)":" (getenv "PATH")))
  (setq eshell-path-env (getenv "PATH"))
  (setq exec-path (split-string (getenv "PATH") ":"))
  (print exec-path)
)

;; Add some pathes
(append-path "~/.rbenv/bin/")
(append-path "~/.rbenv/shims/")
(append-path "/usr/local/bin")


;; Emacsclient
(bundle 'server
	(unless (server-running-p)
	  (server-start))
)

;; Emacs lisp
(show-paren-mode t)

;; --CUI

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



;; --GUI

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
;; (global-linum-mode t)



;; --Language

;; Use japanese
(set-language-environment 'Japanese)

;; Use UTF-8 as possible as can
(prefer-coding-system 'utf-8)

;;

;; --Edit

;; Save cursor position
(bundle 'saveplace
	    (setq-default save-place t))

;; Automatically insert newline
(setq require-final-newline t)

;;

;; --Font

(when (fboundp 'global-font-lock-mode)
  (global-font-lock-mode t)
  (setq font-lock-support-mode 'jit-lock-mode))

(create-fontset-from-ascii-font "September-15:weight=normal:slant=normal" nil "september")
(set-fontset-font "fontset-september" 'japanese-jisx0208 (font-spec :family "September" :size 15) nil 'append)
(set-fontset-font "fontset-september" 'katakana-jisx0201 (font-spec :family "September" :size 15) nil 'append) ;; hankaku kana
(add-to-list 'default-frame-alist '(font . "fontset-september"))


;; --Others

;; Set secret settings
(load "~/.emacs.d/secret.el" nil t)

;;



;; -Functions

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



;; -Package manager

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
(el-get 'sync 'helm-descbinds)
(el-get 'sync 'auto-complete)
(el-get 'sync 'pos-tip)
(el-get 'sync 'lingr)
(el-get 'sync 'folding)
(el-get 'sync 'smartrep)
(el-get 'sync 'tabbar)
(el-get 'sync 'popwin)
(el-get 'sync 'color-theme-railscasts)
(el-get 'sync 'rbenv)
(el-get 'sync 'Enhanced-Ruby-Mode)
(el-get 'sync 'robe)
(el-get 'sync 'ruby-end)
(el-get 'sync 'ruby-block)
(el-get 'sync 'twittering-mode)



;; -Evil settings

(bundle 'evil
	    (evil-mode 1)
	    ;; keymap
	    (define-key evil-motion-state-map (kbd ";") 'evil-ex)
	    (define-key evil-insert-state-map (kbd "C-k") 'kill-line)
	    (define-key evil-insert-state-map (kbd "C-e") 'end-of-line)
	    ;; specific mode
	    ;; (evil-set-initial-state 'eshell-mode 'emacs)
	    ;; Fix cursor color
	    (setq evil-default-cursor t)
	    (set-cursor-color "#DCDCCC")
	    )

(when (require 'evil-nerd-commenter nil t)
  (define-key evil-normal-state-map (kbd "C-- C--") 'evilnc-comment-or-uncomment-lines))

(bundle 'surround
	    (global-surround-mode 1))

(when (require 'evil-matchit nil t)
  (global-evil-matchit-mode 1))

(when (require 'evil-elscreen nil t))

;;


;; -Other packages

;; --folding.el
(bundle 'folding
	    ;; (autoload 'folding-mode "folding" "Folding mode" t)
	    (folding-mode-add-find-file-hook)
	    (add-hook 'emacs-lisp-mode-hook 'folding-mode)
	    (define-key evil-normal-state-map (kbd "z a") 'folding-toggle-show-hide)
	    )
;;

;; --helm
(bundle 'helm
	    (define-key evil-normal-state-map (kbd "SPC f") 'helm-mini)
	    (define-key evil-normal-state-map (kbd "SPC b") 'helm-buffers-list)
	    (define-key evil-normal-state-map (kbd "SPC SPC") 'helm-M-x)
	    )

(when (require 'helm-descbinds nil t))



;; --smartrep
(bundle 'smartrep
	    (smartrep-define-key evil-normal-state-map "C-c"
	      '(("+" . 'evil-numbers/inc-at-pt)
		("-" . 'evil-numbers/dec-at-pt)))
	    (bundle 'tabbar
			(smartrep-define-key evil-normal-state-map "g"
			  '(("t" . 'tabbar-forward-tab)
			    ("T" . 'tabbar-backward-tab)))
			)
	    )
;;

;; --tabbar

(bundle 'tabbar
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
	      '("*Faces*" "*vc-" "*eshell*" "*Lingr Status*"))
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

;;


;; --lingr

(bundle 'lingr
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
	    ;; (evil-define-key 'normal lingr-status-buffer-map (kbd "C-RET") 'lingr-status-switch-room)
	    (evil-define-key 'normal lingr-status-buffer-map (kbd "RET") 'lingr-status-switch-room)
	    ;; (evil-define-key 'normal lingr-status-buffer-map (kbd "RET") 'lingr-status-switch-room-other-window)
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


(bundle 'twittering-mode
	(require 'epa-file nil t)
	(setq twittering-use-master-password t)
	(setq twittering-icon-mode t)
	(setq twittering-timer-interval 300)
)

;; --eshell


(evil-define-key 'normal eshell-mode-map (kbd "C-k") 'eshell-previous-prompt)
(evil-define-key 'normal eshell-mode-map (kbd "C-j") 'eshell-next-prompt)
(evil-define-key 'normal eshell-mode-map (kbd "C-p") 'eshell-previous-prompt)
(evil-define-key 'normal eshell-mode-map (kbd "C-n") 'eshell-next-prompt)

(evil-define-key 'insert eshell-mode-map (kbd "C-p") 'eshell-previous-matching-input-from-input)
(evil-define-key 'insert eshell-mode-map (kbd "C-n") 'eshell-next-matching-input-from-input)

;; popwin
(bundle 'popwin
	(popwin-mode 1)
	(push '("*helm*") popwin:special-display-config)
	(push '("*ruby*") popwin:special-display-config)
)

;; --auto-complete

;; (bundle 'pos-tip)
(bundle 'auto-complete
	(require 'auto-complete-config)
	(add-to-list 'ac-dictionary-directories "~/.emacs.d/ac-dict")
	(ac-config-default)
	(setq ac-use-menu-map t)
	(setq ac-menu-height 20)
	;; (print ac-modes)
	;; (set-face-background 'ac-candidate-face "lightgray")
	;; (set-face-underline 'ac-candidate-face "darkgray")
	;; (set-face-background 'ac-selection-face "steelblue")
	;; (print ac-use-quick-help)
	(setq ac-quick-help-delay 0.1)
	(add-to-list 'ac-modes 'enh-ruby-mode)
	)

(bundle 'rbenv)

(bundle 'inf-ruby
	(add-hook 'after-init-hook 'inf-ruby-switch-setup)
	(add-hook 'enh-ruby-mode-hook 'inf-ruby-minor-mode)
)

;; (print exec-path)

(bundle 'Enhanced-Ruby-Mode
	(add-to-list 'auto-mode-alist '("\\.rb$" . enh-ruby-mode))
	(add-to-list 'auto-mode-alist '("Gemfile$" . enh-ruby-mode))
	(add-to-list 'interpreter-mode-alist '("ruby" . enh-ruby-mode))
	)

(bundle 'ruby-block
	(ruby-block-mode t)
	(setq ruby-block-highlight-toggle t)
)

(bundle 'robe
	(require 'robe-ac)
	(add-hook 'enh-ruby-mode-hook 'robe-mode)
	(add-hook 'robe-mode-hook 'robe-ac-setup)
	;; (add-hook 'robe-mode-hook (lambda ()
	;;   (inf-ruby)
	;;   (robe-start)
	;;   (robe-ac-setup)
	;;   ))
	)


;; -Theme

(add-to-list 'custom-theme-load-path "~/.emacs.d/el-get/")
;; (load-theme 'zenburn t)
(when (require 'color-theme-railscasts nil t))

;;


(eshell)
