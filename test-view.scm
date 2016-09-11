(use iup)
(import (prefix iup iup:))

(define (test-view-gen tabs tab-num view-name view-cfgdat mtconfig-dat)
 (iup:vbox
   (iup:button "Pushme")))

(define (test-view-updater tabs tab-num view-name view-cfgdat mtconfig-dat)
   #f)
