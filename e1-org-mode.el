;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                        Common Settings                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun org-file-path (filename)
  "Return the full path to given org file FILENAME."
  (concat *notes-path* filename))

;; Habit tracking
(require 'org-habit)
;; Do not spam my timeline with it.
(setq org-habit-show-habits-only-for-today t)
;; Show my habits no matter whether it is scheduled today.
(setq org-habit-show-all-today t)

;; Convert the source code into HTML file keeping the highlight.
;; NOTE: This plugin is necessary when using Org Mode to generate HTML file.
(require 'htmlize)

;; Org modules loaded with org mode itself
(setq org-modules
      '(org-w3m org-bbdb org-habit org-bibtex org-docview org-gnus org-info))
;; default table size
(setq org-table-default-size "2x2")

;; Mobile Org
(setq org-agenda-files '(*notes-path*))
(setq org-directory *notes-path*)
(setq org-mobile-directory (org-file-path "mobile"))
(setq org-mobile-inbox-for-pull (org-file-path "mobile.org"))

;; Automatically sync with mobile org.
(use-package org-mobile
  :config
  (org-mobile-sync-mode 1))

(defun org-mode-hook-function ()
  "Setup."
  (toggle-word-wrap 1)
  (setq truncate-lines nil)

  (make-local-variable 'company-backends)
  (setq company-backends '((company-dabbrev :with company-yasnippet)))

  (make-local-variable 'company-idle-delay)
  (setq company-idle-delay 0.5))
(add-hook 'org-mode-hook 'org-mode-hook-function)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                         Localization                             ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Display org in a bigger calendar!
(require 'calfw-org)
;; Chinese localization
(require 'cal-china-x)

;; Use Chinese month name.
(setq calendar-month-name-array
      ["一月" "二月" "三月" "四月" "五月" "六月"
       "七月" "八月" "九月" "十月" "十一月" "十二月"])
;; Use Chinese weekday name.
(setq calendar-day-name-array
      ["日" "一" "二" "三" "四" "五" "六"])
;; Use Monday as the first day of week.
(setq calendar-week-start-day 1)

;; Holidays
(setq calendar-holidays
      '(;;公历节日
        (holiday-fixed 1 1 "元旦")
        (holiday-fixed 2 14 "情人节")
        (holiday-fixed 3 8 "妇女节")
        (holiday-fixed 5 1 "劳动节")
        (holiday-float 5 0 2 "母亲节")
        (holiday-fixed 6 1 "儿童节")
        (holiday-float 6 0 3 "父亲节")
        (holiday-fixed 9 10 "教师节")
        (holiday-fixed 10 1 "国庆节")
        (holiday-fixed 12 25 "圣诞节")
        ;; 农历节日
        (holiday-lunar 12 30 "年三十" 0)
        (holiday-lunar 1 1 "春节" 0)
        (holiday-lunar 1 15 "元宵节" 0)
        (holiday-solar-term "清明" "清明节")
        (holiday-lunar 5 5 "端午节" 0)
        (holiday-lunar 8 15 "中秋节" 0)))

;; Key bindings for calendar.
(define-key calendar-mode-map (kbd "M-f") 'calendar-forward-month)
(define-key calendar-mode-map (kbd "M-b") 'calendar-backward-month)
(global-set-key (kbd "C-c O") 'calendar)
(global-set-key (kbd "C-c o") 'cfw:open-org-calendar)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                            Display                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; days to show in agenda view
(setq org-agenda-span 'month)

;; Display agenda in the other window.
(setq org-agenda-window-setup 'current-window)
;; Restore the window config after displaying agenda.
(setq org-agendaq-restore-windows-after-quit t)

;; fontify code blocks
(setq org-src-fontify-natively t)
;; don't show all the leading stars
(setq org-hide-leading-stars t)
;; show everything on startup
(setq org-startup-folded nil)
;; do indenting
(setq org-startup-indented t)
;; Enable bold, italic etc inside Chinese context.
(setf (nth 0 org-emphasis-regexp-components) " \t('\"{[:multibyte:]")
(setf (nth 1 org-emphasis-regexp-components) " \t\r\n('\"{[:multibyte:],.")
(org-set-emph-re 'org-emphasis-regexp-components org-emphasis-regexp-components)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                              Export                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Enable Markdown export.
(require 'ox-md)

(defun org-inline-style-file (exporter)
  "Embed CSS file indicated by INLINE_STYLE into generated HTML file.
EXPORTER is provided by Org Mode."
  (when (eq exporter 'html)
	(let ((content (buffer-string))
		  (start 0))
	  ;; match
	  (while (setq start
                   (string-match "^.+INLINE_STYLE.*:.*\.css$" content start))
		(incf start)
		(let ((filename (second (split-string (match-string 0 content)
                                              ":" t " "))))
		  (if (file-exists-p filename)
			  (setq org-html-head (concat
								   "<style type=\"text/css\">\n"
								   "<!--/*--><![CDATA[/*><!--*/\n"
								   (with-temp-buffer
									 (insert-file-contents filename)
									 (buffer-string))
								   "/*]]>*/-->\n"
								   "</style>\n"))
			(message "Style file \"%s\" does not exist" filename)))))))

(add-hook 'org-export-before-processing-hook 'org-inline-style-file)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;                            Workflow                              ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; keep track of done things
(setq org-log-done 'time)
;; get rid of the foot detail while generating HTML
(setq org-html-postamble nil)

(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-c k") 'org-capture)

;; Set templates:
;; (KEYS DESCRIPTION TYPE TARGET TEMPLATE PROPERTIES)
;; TYPE: entry item checkitem table-line plain
;; TARGET: file id file+headline
(setq org-capture-templates
      `(("t" "TODO" entry (file ,(org-file-path "todo.org")) "* TODO %?")
		("s" "Schedule" entry (file ,(org-file-path "todo.org")) "* %?")
		("r" "Reminder" entry (file ,(org-file-path "reminder.org")) "* REMINDER %?")
        ("j" "Journal" plain (file ,(concat "~/private/journal/"
                                            (today "%Y-%m-%d"))))))

(setq org-agenda-custom-commands
      '(("n" "Agenda"
         ((agenda "" nil)
		  (todo "PAUSE"
                ((org-agenda-overriding-header "On Hold")))
		  (todo "TODO"
				((org-agenda-overriding-header "TODO List")))
		  (todo "REMINDER"
				((org-agenda-overriding-header "Reminder")))
		  nil))))
