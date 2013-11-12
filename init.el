
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
(el-get 'sync 'evil-elscreen)
(el-get 'sync 'evil-indent-textobject)
(el-get 'sync 'evil-leader)
(el-get 'sync 'evil-matchit)
(el-get 'sync 'evil-nerd-commenter)
(el-get 'sync 'evil-numbers)
(el-get 'sync 'evil-paredit)
(el-get 'sync 'evil-surround)


(when (require 'evil nil t)
  (evil-mode 1)
  (define-key evil-motion-state-map (kbd ";") 'evil-ex)
  )
