;; run with clj -M -i blink.clj

(ns blink
  (:require [charbel.core :as c]))

(def blink-module
  (c/module blink
          [[:out kled 3]
           [:out aled 3]
           [:out F25]]
          (register const_1 1)
          (register const_0 0)
          (instance SB_HFOSC inthosc ([CLKHFPU const_1] [CLKHFEN const_1] [CLKHF clk]))
          (register counter 
                    (width 22 
                      (inc counter)))

          (register led_on (width 1 
                            (if (= 0 counter)
                              (if (= 0 led_on) 1 0)
                              led_on)))))  
                                      
                              
                           
           

(println (c/build blink-module))

