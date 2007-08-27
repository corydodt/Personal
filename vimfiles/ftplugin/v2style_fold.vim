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
    let style = '^\*.*:'

    if getline(a:lnum) =~ style
        if getline(a:lnum + 1) =~ style
            return "0"
        endif
        return "1"
    endif

    if getline(nextnonblank(a:lnum)) =~ style
        return "0"
    endif

    return "1"
endfu

