(use json)

(let (
  (my_filename (get-environment-variable "MY_FILENAME"))
  (my_format   (get-environment-variable "MY_FORMAT")))

  (print (conc "INFO: Verify filename=" my_filename " has format=" my_format))

  (if 
    (cond
      ((string=? my_format "json")
        (handle-exceptions exn #f
          (with-input-from-file my_filename json-read))
        )
    
      ;((string=? my_format "ini")  #f)
      (else   #f)) 
    (print (conc "INFO: " my_filename " is valid " my_format))
    (print (conc "ERROR: " my_filename " is not valid " my_format))
    )

)
