;; $Id: .emacs,v 1.13 2006/02/08 09:51:09 simonflack Exp $

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  ######  #    #    ##     ####    ####
;;  #       ##  ##   #  #   #    #  #
;;  #####   # ## #  #    #  #        ####
;;  #       #    #  ######  #            #
;;  #       #    #  #    #  #    #  #    #
;;  ######  #    #  #    #   ####    ####


;; Are we running XEmacs or Emacs?
(defvar running-xemacs (string-match "XEmacs\\|Lucid" emacs-version))

(require 'package)
(add-to-list 'package-archives 
    '("marmalade" . "http://marmalade-repo.org/packages/"))
(add-to-list 'package-archives
    '("melpa" . "http://melpa.milkbox.net/packages/") t)
(package-initialize)

(projectile-global-mode)
(setq projectile-indexing-method 'native)

;; Set up the keyboard so the delete key on both the regular keyboard
;; and the keypad delete the character under the cursor and to the right
;; under X, instead of the default, backspace behavior.
(global-set-key [delete] 'delete-char)
(global-set-key [kp-delete] 'delete-char)

;; Make sure HOME and END take me to beginning/end of the buffer
;;(global-set-key [home] 'beginning-of-buffer)
;;(global-set-key [end] 'end-of-buffer)           ;inactive by default?
;;(global-set-key "\e[1~" 'beginning-of-buffer)
;;(global-set-key "\eOH" 'beginning-of-buffer)    ;Needed on remote xterm?
;;(global-set-key "\e[4~" 'end-of-buffer)
;;(global-set-key "\eOF" 'end-of-buffer)          ;Needed on remote xterm?

;; Keyboard remappings
;; Step 1: unbind all function keys (except F10, the menu key)
(global-unset-key [f1])
(global-unset-key [f2])
(global-unset-key [f3])
(global-unset-key [f4])
(global-unset-key [f5])
(global-unset-key [f6])
(global-unset-key [f7])
(global-unset-key [f8])
(global-unset-key [f9])
(global-unset-key [f11])
(global-unset-key [f12])
;; Bind any desired function keys.
;; Paul uses this to get around the chording limitations of the shift key on
;; his keyboard.
(global-set-key [f1] 'isearch-forward)
(global-set-key [C-f1] 'isearch-backward)
(global-set-key [f2] 'query-replace)
(global-set-key [f3] 'isearch-forward-regexp)
(global-set-key [C-f3] 'isearch-backward-regexp)
(global-set-key [f4] 'query-replace-regexp)
(global-set-key [f5] 'kmacro-start-macro)
(global-set-key [f6] 'kmacro-end-macro)
(global-set-key [f7] 'kmacro-end-and-call-macro)
(global-set-key [f8] 'delete-trailing-whitespace)
(global-set-key [f9] 'shell-command)
(when (fboundp 'projectile-global-mode)
  (global-set-key [f11] 'projectile-find-file)
)

;; Turn on font-lock mode for Emacs
(cond ((not running-xemacs)
       (global-font-lock-mode t)
))

;; Setup basic coloring
(add-to-list 'default-frame-alist '(background-color . "black"))
(add-to-list 'default-frame-alist '(foreground-color . "white"))
(add-to-list 'default-frame-alist '(cursor-color . "white"))

;; From emacs documentation: http://www.gnu.org/software/emacs/windows/faq4.html#font-lock
(when (fboundp 'global-font-lock-mode)
  ;; customize face attributes
  (setq font-lock-face-attributes
        ;; Symbol-for-Face Foreground Background Bold Italic Underline
        '(
          (font-lock-builtin-face           "RoyalBlue")
          (font-lock-comment-face           "red")
          (font-lock-comment-delimiter-face "red")
          (font-lock-constant-face          "purple")
          ;;(font-lock-doc-face               "green")
          (font-lock-function-name-face     "RoyalBlue")
          (font-lock-keyword-face           "cyan")
          ;;(font-lock-negation-char-face     "white")
          (font-lock-preprocessor-face      "RoyalBlue")
          ;;(font-lock-regexp-grouping-backslash "bold white")
          ;;(font-lock-regexp-grouping-construct "bold white")
          (font-lock-string-face            "green")
          (font-lock-type-face              "green")
          ;;(font-lock-variable-name-face     "yellow")
          (font-lock-warning-face           "Red")
          )
  )
)


(setq load-path
    (append
     (list
       (expand-file-name "~/local")
       (expand-file-name "./local")
      )
     load-path))


;; Load the STD version control stuff
;;(require 'vc)
;;(add-hook 'vc-before-checkin-hook 'sf-pre-cvscommit-check)
;;(setq vc-command-messages t)

(defun sf-lock-buffer (buffer)
  ;; Set the log to read-only
   (let ((oldbuf (current-buffer)))
     (save-current-buffer
       (set-buffer buffer)
       (setq buffer-read-only t)
       ))
)

(defun sf-pre-cvscommit-check ()
  "pre-commit cvs hook"
  (interactive)
  (message (concat "Running pre-commit check on " buffer-file-name))

  (string-match ".*[\\/]\\(.*\\)" buffer-file-name)
  (setq buffer-basename (match-string 1 buffer-file-name))

  ;; Get/Create a buffer for displaying errors/output
  (setq cvs-errors-buffer (get-buffer-create "**cvs-pre-commit-log**"))
   (let ((oldbuf (current-buffer)))
     (save-current-buffer
       (set-buffer cvs-errors-buffer)
       (setq buffer-read-only nil)
       (erase-buffer)
       ))

   ;;  (if (string-match ".p[lm]$" buffer-file-name)
      (if (not (equal 0
           (call-process "check" nil cvs-errors-buffer nil
                        "-s" "-f" buffer-file-name)))
          (progn
            (sf-lock-buffer cvs-errors-buffer)
            (select-window (display-buffer cvs-errors-buffer))
            (shrink-window (- (window-height) 6))
            (beginning-of-buffer)
            (display-buffer cvs-errors-buffer nil nil )
            (error (concat "There was an error in '" buffer-basename
                           "' see error log for details"))
          )
      )

      ;; Nothing wrong with file, allow CVS commit to continue
      (sf-lock-buffer cvs-errors-buffer)
      (message (concat buffer-basename " syntax OK"));
)





;; color-theme.el http://www.bright.net/~jonadab/emacs/color-theme.el
;;    (require 'color-theme)
(condition-case err
  (and
    (require 'color-theme)
    (if window-system
         (color-theme-raspopovic)
    )
  )
  (error
    (setq message-log-max t)
    (message "error loading color-theme: %s" (cdr err))
  )
)

;; Display the time and get rid of splash screen
(display-time)
(setq inhibit-startup-message t)

;;Don't make backup
;;(setq make-backup-files nil)
(defun make-backup-file-name (file-name)
  "Create the non-numeric backup file name for `file-name'."
  (require 'dired)
  (if (file-exists-p "~/.emacsbackups")
      (concat (expand-file-name "~/.emacsbackups/")
      (dired-replace-in-string "/" "|" file-name))
      (concat file-name "~")))
;;(setq delete-auto-save-files t) ;delete unnecessary autosave files
;;(setq delete-old-versions t)    ;delete oldversion files

;; Always end a file with a newline
(setq require-final-newline t)

;; Stop at the end of the file, not just add lines
(setq next-line-add-newlines nil)

(global-set-key "\C-x\C-b" 'buffer-menu)
(global-set-key [(control tab)] 'bury-buffer)
(global-set-key "\M-o" 'other-window)
(global-set-key "\M-g" 'goto-line)
(fset 'yes-or-no-p 'y-or-n-p)     ;; replace y-e-s with y

(defun insert-a-tab ()
  "insert a \\t"
  (interactive)
  (insert ?\t))
(global-set-key "\C-t" 'insert-a-tab)

(add-hook 'sh-mode-hook 'indent-detect)
(setq-default indent-tabs-mode nil)
( add-hook 'fundamental-mode-hook  ;; tab-mode in Makefiles
  ( function
    ( lambda ()
      ( setq indent-tabs-mode 1
) ) ) )


(defun indent-detect ()
  (interactive)
    (message "Detect indent tabstyle and set for the current document")
    (save-excursion
      (goto-char (point-min))
      (setq tabcount 0)
      (setq spacecount 0);
      ;; search through file and calculate how many are space/tab indented
      (while (re-search-forward "^[ \t]+" nil t)
        (cond
           ((string-match "^[ ]" (match-string 0))
             (setq spacecount (1+ spacecount)))
           (t (setq tabcount (1+ tabcount)))
           )
      )
      ;; now set file default to most common
      (cond
         ((> spacecount tabcount)
           (setq indent-tabs-mode nil) (message "tab-detect: using SPACES") )
         ((< spacecount tabcount)
           (setq indent-tabs-mode t)  (message "tab-detect: using TABS") )
      )
   )
)

;;Convert DOS cr-lf to UNIX newline
;; C-x [RET] f unix C-x C-s
(defun dos-unix () (interactive) (goto-char (point-min))
  (while (search-forward "\r" nil t) (replace-match "")))

;;Convert UNIX newline to DOS cr-lf
;; C-x [RET] f dos C-x C-s
(defun unix-dos () (interactive) (goto-char (point-min))
  (while (search-forward "\n" nil t) (replace-match "\r\n")))


;; Turn off auto-revert mode - ;;useful for CVS
(cond ((not running-xemacs)
     (global-auto-revert-mode nil)
))

(setq auto-mode-alist (append '(
  ("\\.tmpl$" . html-mode)
    ("\\.shtml$" . html-mode)
    ("\\.xhtml$" . sgml-mode)
) auto-mode-alist))

(cond ((not running-xemacs)
     (show-paren-mode 1)          ;; match parens
           (transient-mark-mode t)      ;; show highlight block
))



;; These two bindings make it easier to find a mismatched parenthesis:
(global-set-key "\e'" 'forward-sexp)
(global-set-key "\e;" 'backward-sexp)
(setq line-number-mode t)    ;; display line numbers
(setq column-number-mode t)  ;; display column numbers
(setq-default tab-width 4)   ;; tab width chars

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  #####   ######  #####   #
;;  #    #  #       #    #  #
;;  #    #  #####   #    #  #
;;  #####   #       #####   #
;;  #       #       #   #   #
;;  #       ######  #    #  ######

;; mode-compile
(autoload 'mode-compile "mode-compile"
  "Command to compile current buffer file based on the major mode" t)
(global-set-key "\C-cc" 'mode-compile)
(autoload 'mode-compile-kill "mode-compile"
  "Command to kill a compilation launched by `mode-compile'" t)
(global-set-key "\C-ck" 'mode-compile-kill)

;;perl syntax checking
(defun check-perl ()
  "Check the syntax of the perl script in the current buffer."
  (interactive)

  ;; Just pass the basename() of the current buffer
  (string-match ".*[\\/]\\(.*\\)" buffer-file-name)
  (setq buffer-base-name (match-string 1 buffer-file-name))

  (setq perl-run-command "perl -Mstrict -MFindLib -cw")
  (compile (concat perl-run-command " " buffer-base-name))
  )
(global-set-key "\C-cy" 'check-perl)

;; Enable cperl as default perlmode
(defalias 'perl-mode 'cperl-mode)
(setq cperl-indent-level 4
      cperl-close-paren-offset -4
      cperl-continued-statement-offset 4
      cperl-indent-parens-as-block t
      cperl-tab-always-indent t)

;;(setq cperl-hairy nil
;;   cperl-brase-offset 0
;;   cperl-continued-brace-offset -4
;;   cperl-lavel-offset -4
;;   cperl-electric-lbrace-space nil
;;   cperl-tab-always-indent t
;;   cperl-hash-face
;;)
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(cperl-array-face ((((class color) (background dark)) (:bold t :foreground "yellow")))))



(setq auto-mode-alist
     (append '(("\\.[pP][Llm]$" . perl-mode)) auto-mode-alist ))
(setq auto-mode-alist
     (append '(("\\.t$" . perl-mode)) auto-mode-alist ))
(setq auto-mode-alist
     (append '(("\\.pod$" . perl-mode)) auto-mode-alist ))
(setq interpreter-mode-alist
      (append interpreter-mode-alist '(("miniperl" . perl-mode))))


;; Auto detect (and set!) tab style:
(add-hook 'cperl-mode-hook 'indent-detect)
(add-hook 'sh-mode-hook 'indent-detect)
(add-hook 'cr-mode-hook 'indent-detect)

;; auto-fill-mode on cperl
(add-hook 'cperl-mode-hook 'turn-on-auto-fill)
(setq-default fill-column 79) ;; column limit

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; run perl on the current region, updating the region
(defun perl-replace-region (start end)
  "Apply perl command to region"
  (interactive "r")
  (shell-command-on-region start end
    (read-from-minibuffer "Replace region command: " '("perl -ple \'\'" . 12 ))
     t
     t
    )
  (exchange-point-and-mark)
)

; run perl on the current buffer, updating the buffer
(defun perl-replace-buffer ()
  "Apply perl command to buffer"
  (interactive)
  (let ((ptline (count-lines (point-min) (point)))
       (ptcol (current-column))
       (markline 0)
       (markcol  0)
       (command (read-from-minibuffer "Replace buffer command: "
                 '("perl -ple \'\'" . 12 ))))
  (exchange-point-and-mark)
  (setq markline (count-lines (point-min) (point)))
  (setq markcol  (current-column))
  (mark-whole-buffer)
  (let ((new-start (region-beginning))
        (new-end   (region-end)))
    (shell-command-on-region  new-start new-end command t t )
    )
  (goto-line markline)
  (move-to-column markcol)
  (exchange-point-and-mark)
  (goto-line ptline)
  (move-to-column ptcol)
  )
)


(add-hook 'cperl-mode-hook
          (function
           (lambda ()

             ;; prepare new files for a useful life
             (if (= (point-min) (point-max))
                 (progn
                   ;; insert boilerplate
                   (insert-string
                    (concat "#!/usr/bin/perl\n"
                            "# " (buffer-file-name) "\n\n"
                            "use strict;\n"
                            "use warnings;\n\n"))
                   (goto-char (point-max))
                   ;; make executable
                   (save-buffer)
                   (shell-command (format "chmod u+x %s" (buffer-file-name)))
                   )
               )
             )
           )
)

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(display-time-mode t)
 '(show-paren-mode t)
 '(transient-mark-mode t))


;; Load CEDET.
;; See cedet/common/cedet.info for configuration details.
(require 'cedet)


;; Enable EDE (Project Management) features
(global-ede-mode 1)

;; Enable EDE for a pre-existing C++ project
;; (ede-cpp-root-project "NAME" :file "~/myproject/Makefile")


;; Enabling Semantic (code-parsing, smart completion) features
;; Select one of the following:
;; * This enables the database and idle reparse engines
;;(semantic-load-enable-minimum-features)

;; * This enables some tools useful for coding, such as summary mode
;;   imenu support, and the semantic navigator
;;(semantic-load-enable-code-helpers)

;; * This enables even more coding tools such as intellisense mode
;;   decoration mode, and stickyfunc mode (plus regular code helpers)
;;(semantic-load-enable-gaudy-code-helpers)

;; * This enables the use of Exuberent ctags if you have it installed.
;;   If you use C++ templates or boost, you should NOT enable it.
;; (semantic-load-enable-all-exuberent-ctags-support)

;; Enable SRecode (Template management) minor-mode.
;; (global-srecode-minor-mode 1)
