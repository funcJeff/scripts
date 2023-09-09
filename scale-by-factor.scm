(define (script-fu-scale-by-factor fileglob factor)
  (let*
    (
      (files (cadr (file-glob fileglob 0)))
    )
    (do-scale-to files factor)
  )
)

(define (do-scale-to files factor)
  (while (not (null? files))
    (let*
      (
        (file (car files))
        (image (car (gimp-file-load 1 file file)))
        (width (car(gimp-image-width image)))
        (height (car(gimp-image-height image)))
        (newfile (string-append file "_.jpg"))
        (drawable (car (gimp-image-get-active-layer image)))
      )
      (gimp-image-scale image (* width factor) (* height factor))
      (gimp-file-save 1 image drawable newfile newfile)
    )
    (set! files (cdr files))
  )
)

(script-fu-register
  "script-fu-scale-by-factor"               ;func name
  "Batch Scale By Factor"                   ;menu label
  "Scale multiple images by given factor."  ;description
  "Jeffery Martin"                          ;author
  "CC0: All copyright waived."              ;copyright notice
  "2014-01-06"                              ;date created
  ""                                        ;image type that the script works on
  SF-STRING "fileglob" "/tmp/photos/image-*.jpg"
  SF-VALUE "factor" "0.5"
)

(script-fu-menu-register "script-fu-scale-by-factor" "<Image>/Image/Transform")
