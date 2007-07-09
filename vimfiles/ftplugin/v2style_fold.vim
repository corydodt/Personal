" Expr-based folding for v2 styles files 

setlocal foldmethod=expr
setlocal foldexpr=GetV2StyleFold(v:lnum)
setlocal foldtext=V2StyleFoldText()

function! V2StyleFoldText()
    if foldlevel(v:foldstart) == 1
        return foldtext()
    endif
    return "FIXME"
endfu

function! GetV2StyleFold(lnum)
    let line = getline(a:lnum)
    let nextline = getline(a:lnum+1)

    let styleMark = '^\*.*:$'

    " end file folds on the line before the next style begins
    if nextline =~ styleMark
        return "<1"
    endif

    " begin a file fold at the filename marker
    if line =~ styleMark
        return "1"
    endif

    " this has to be evaluated last -- any line that is not a diff line or other
    " marker is some kind of comment.
    if line =~ commentmark && line !~ svndiffdecoration
        return "0"
    endif

    return "="

endfu
