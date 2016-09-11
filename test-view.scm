;; make an so like this:
;;
;; csc test-view.scm -s -o test-view.so

(use iup)
(import (prefix iup iup:))

(define (test-view-gen commondat tabs tab-num view-name view-cfgdat mtconfig-dat)
 (iup:vbox
   (iup:button "Pushme")))

(define (test-view-updater commondat tabs tab-num view-name view-cfgdat mtconfig-dat)
   #f)
