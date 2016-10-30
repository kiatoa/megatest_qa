;; make an so like this:
;;
;; csc test-view.scm -s -o test-view.so

(use iup)
(import (prefix iup iup:))

(define (test-view-gen commondat tabs tab-num view-name view-cfgdat mtconfig-dat)
 (let* ((term-cmd      "xterm") ;; (common:which (list "gnome-terminal" "konsole" "xterm")))
        (color-browser (iup:color-browser))
        (xterm-launch  (iup:button "Create Xterm"
                                   #:action
                                   (lambda (obj) ;; rgb:RR/GG/BB
                                     (let ((bg (conc
                                                "rgb:"
                                                (common:iup-color->rgb-hex
                                                 (iup:attribute obj "BGCOLOR"))))
                                           (fg (conc
                                                "rgb:"
                                                (common:iup-color->rgb-hex
                                                 (iup:attribute obj "FGCOLOR")))))
                                       (system (conc term-cmd
                                                     " -bg " bg
                                                     " -fg " fg
                                                     " &"))))))
        (fg-button     (iup:button "Foreground"
                                   #:action (lambda (obj)
                                              (iup:attribute-set! 
                                               xterm-launch
                                               "FGCOLOR"
                                               (iup:attribute color-browser "RGB")))))
        (bg-button     (iup:button "Background"
                                   #:action (lambda (obj)
                                              (iup:attribute-set! 
                                               xterm-launch
                                               "BGCOLOR"
                                               (iup:attribute color-browser "RGB")))))
        )
   (iup:vbox
    (iup:hbox 
     fg-button bg-button)
    color-browser
    xterm-launch)))

(define (test-view-updater commondat tabs tab-num view-name view-cfgdat mtconfig-dat)
   #f)
