" Expr-based folding for unified diff (specifically the output of
" svn diff .. regular unified diff might work, i dunno.)
setlocal foldmethod=expr
setlocal foldexpr=GetDiffFold(v:lnum)
setlocal foldtext=DiffFoldText()

function! DiffFoldText()
    if foldlevel(v:foldstart) == 1
        return foldtext()
    endif
    if foldlevel(v:foldstart) == 2
        let line = getline(v:foldstart)
        let cursor = v:foldstart + 1
        let nextline = getline(cursor)
        while nextline =~ "^ "
            let cursor = cursor + 1
            let nextline = getline(cursor)
        endwhile
        return line . " " . nextline
    endif
    return "FIXME"
endfu

function! GetDiffFold(lnum)
    let line = getline(a:lnum)
    let nextline = getline(a:lnum+1)

    let filemark = '\(^Index: \|^Property changes on: \|diff -r \)'
    let sectionmark = '^@@ .* @@$'

    " end file folds on the line before the next filename
    if nextline =~ filemark
        return "<1"
    endif
    " end region folds on the line before the next region
    if nextline =~ sectionmark
        return "<2"
    endif

    " begin a region fold at the region marker
    if line =~ sectionmark
        return "2"
    endif

    " begin a file fold at the filename marker
    if line =~ filemark
        return "1"
    endif

    return "="

endfu
