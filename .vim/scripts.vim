" Detection for pylog type
"
if did_filetype()
    finish
endif

" detect hg out -p by looking at the first line
if getline(1) =~ '^searching for changes$\|^changeset: \|^# HG changeset patch$'
    setfiletype diff
elseif getline(1) =~ '^comparing with ' && getline(2) =~ '^searching for changes$'
    setfiletype diff
endif

" To detect pylog, we're going to look for a log timestamp pattern 
" somewhere in the first 10 lines.
let s:lineno = 1
while s:lineno <= 10
    if getline(s:lineno) =~ '^\d\{4}\/\d\{2}\/\d\{2} \d\{,2}:\d\{2} \([A-Z]*\|[-+]\d\{4}\) \[-] '
        setfiletype pylog
        break
    endif
    let s:lineno = s:lineno + 1
endwhile

