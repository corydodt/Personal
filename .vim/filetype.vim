augroup filetypedetect
    au BufNewFile,BufRead *.style   setf v2style
    au BufNewFile,BufRead styles   setf v2style
    au BufNewFile,BufRead *.n3     setf n3
    au BufNewFile,BufRead *.jst    setf javascript
augroup END
