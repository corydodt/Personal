fu! SetCoryOptions()
    " indenting
    set tw=78
    set sw=4 ts=4 sts=4 expandtab
    set modeline
    filetype indent on
    let g:yankring_history_file='.yankring_history'

    set virtualedit=block

    " temp files 
    set nobackup nowritebackup
    " 2 path separators == use abspath in filename for uniqueness
    "   (see :help 'directory' ) 
    set directory=/tmp//
    " colors/fonts
    set nohlsearch
    filetype plugin on
    syn on
    " colorscheme koehler
    " colorscheme peachpuff
    colorscheme greener

    " misc
    set visualbell
    set backspace=eol,indent,start
    set whichwrap=b,s,<,>,h,l,~,[,] " these movements permit line wrapping
    set nu " line numbers
    set laststatus=2 " always show status
    set stl=%F\ %y\ %l/%L@%c\ %m%r
    set tags=./tags,tags,../tags,../../tags,../../../tags,../../../../tags

    set guitablabel=%M\ %N\ %t
endfu

fu! SetCoryAutoCommands()
    augroup Cory
    " clear this group
    au!
    au BufWinEnter,BufReadPost,BufNewFile,BufEnter * silent! exec ":cd " expand('%:p:h')
    " set noacd - autochdir is weird on blank buffers.  prefer my hook, which leaves
    " you in the same directory when you are editing a new blank tab with \t

    au Filetype changelog,Makefile setlocal noet
    au Filetype javascript setlocal smartindent
    au Filetype rst call EnableReST()
    au Filetype javascript call EnableJsLint()
    au FileType javascript setl fen
    augroup END
endfu

fu! SetCoryCommands()
    command! SvnDiff call DoSvnDiff()
    command! HgDiff2 call TurnOnHgDiff2()
    command! HgDiff call DoHgDiff()
    command! Gather call DoGather()
    command! Abspath call Copyabspath()
    command! Htmlbp call DoHtmlBP()

    " examples: 
    " :Pp twisted.internet  " replace the current buffer
    " :Pp! twisted.internet  " replace the current buffer, even if modified
    " :Ppn py2exe.build_exe  " horiz-split and put file in new buffer
    " :Ppv py2exe.build_exe  " vert-split and put file in new buffer
    command! -nargs=1 -bang Pp exe ':edit<bang> '.system('pp <args>')
    command! -nargs=1 Ppn exe ':new '.system('pp <args>')
    command! -nargs=1 Ppv exe ':vs '.system('pp <args>')

    command! Survey call DoPutSurvey()
    command! Usage call DoPutUsage()
    command! PrettyXML call DoPrettyXML(0)
    command! PrettyHTML call DoPrettyXML(1)
    command! RunPyBuffer call DoRunAnyBuffer("python -", "python")
    command! RunBashBuffer call DoRunAnyBuffer("bash -", "sh")
    command! RunLuaBuffer call DoRunAnyBuffer("lua -", "lua")
    command! RunSQLiteBuffer call DoRunAnyBuffer("sqlite3", "sql")

    command! PyFlake call DoPyFlakes()

    command! VersionCory echo 'Cory''s vim scripts v1.1'
endfu

fu! SetCoryMappings()
    " taglist.vim
    map <Leader>T :TlistToggle<CR>

    " clipboard helpers
    map <Leader>c "+y
    map <Leader>v "+p
    map <Leader>x "+x

    " make error helpers
    map <Leader>] :cn<CR>
    map <Leader>[ :cp<CR>

    " very useful shortcut
    map <Leader>. :normal .


    " reST helpers
    "   underline a heading
    map <Leader>- :.s:^\s*::<CR>Ypv$r-
    "   underline a heading at a different level
    map <Leader>= :.s:^\s*::<CR>Ypv$r=
    "   underline a heading at a different level
    map <Leader>` :.s:^\s*::<CR>Ypv$r~
    "   title
    map <Leader><Leader>= :.s:^\s*::<CR>Ypv$r=YkPjj0
    "   table-header-ize
    map <Leader>! :call TableHeaderize()<CR>

    " tab helpers
    map <Leader>t :tab new<CR>
    map <Leader><C-T> :tabclose!<CR>

    map <Leader>p :RunPyBuffer<CR>:winc p<cr>:set filetype=pylog<cr>:winc p<cr>
    map <Leader>b :RunBashBuffer<CR>
    map <Leader>l :RunLuaBuffer<CR>
    map <Leader>q :RunSQLiteBuffer<CR>

    " diffs
    map <Leader>D :call ToggleHgDiff2()<CR>


    " make it easier to edit vimrc
    map <Leader>V :so ~/vimrc<CR>

    " Q enters ex-mode which is annoying. kill that.
    map Q <Nop>
endfu

" insert 3 border lines at the top and bottom of a block, and right below the
" header row, for making an rst table.
fu! TableHeaderize() range
    let orig = getpos('.')
    setl tw=0

    try
        let p1 = '' + a:firstline
        let p2 = '' + a:lastline

        " save off the line indent because the border function needs
        " everything left-edge-aligned
        let indent = matchstr(getline(p1), '^\s*')
        
        let cmd1 = printf("%d,%ds/^\\s*//", p1, p2)
        exe cmd1

        " get the border then paste it in three places
        let borderline = GetTableBorder(p1)
        exe "norm o" . borderline
        exe 'norm "bY'
        exe 'norm k"bP'
        call cursor(p2+2, 0)

        exe 'norm "bp'

        " redent.
        let cmd2 = printf("%d,%ds/^/%s/", p1, p2+3, indent)
        sil exe cmd2
    finally
        call cursor(orig)
        setl tw<

    endtry

endfu

" convert a bunch of space-separated words into a row of several column
" borders
fu! GetTableBorder(where)
    call cursor(a:where, 0)
    let line = getline('.')
    let pos = 0
    let lline = len(line)
    let tmp = []

    while pos < lline
        let rest = line[pos : lline]
        let matched = matchstr(rest, '\(.\{-}\s*\)\($\|\s\s\S\@=\)')
        let pos = pos + len(matched)
        call add(tmp, repeat('=', len(matched)-1))
    endwhile

    let tmp[-1] = tmp[-1] . '=========='

    return join(tmp, ' ')
endfu

" Helpers for some VCS systems
fu! DoSvnDiff()
    let s:thispath = expand('%:t')
    new
    exe ':0r!svn diff "'.s:thispath.'" | dos2unix'
    setlocal ft=diff
endfu

fu! TurnOnHgDiff2()
    if !exists("b:diffIsOn") || !b:diffIsOn
        pclose!

        let b:prevfoldmethod = &foldmethod
        let b:prevfoldexpr = &foldexpr
        let b:prevfoldlevel = &foldlevel
        let b:prevfoldlevelstart = &foldlevelstart
        let b:prevfoldcolumn = &foldcolumn
        let b:prevfoldminlines = &foldminlines
        let b:prevfoldnestmax = &foldnestmax
        let s:thispath = expand('%:t')
        below vnew
        exe ':0r!hg cat "'.s:thispath.'"'
        $d " hg cat adds a final newline
        setlocal previewwindow nomodified
        diffthis
        winc p
        diffthis
        let b:diffIsOn = 1
    endif
endfu

fu! TurnOffHgDiff2()
    if exists("b:diffIsOn") && b:diffIsOn
        diffoff!
        pclose!
        let b:diffIsOn = 0
        let &foldmethod = b:prevfoldmethod
        let &foldexpr = b:prevfoldexpr
        let &foldlevel = b:prevfoldlevel
        let &foldlevelstart = b:prevfoldlevelstart 
        let &foldcolumn = b:prevfoldcolumn 
        let &foldminlines = b:prevfoldminlines 
        let &foldnestmax = b:prevfoldnestmax 
    endif
endfu

fu! ToggleHgDiff2()
    if exists("b:diffIsOn") && b:diffIsOn
        call TurnOffHgDiff2()
    else
        call TurnOnHgDiff2()
    endif
endfu

fu! DoHgDiff()
    let s:thispath = expand('%:t')
    new
    exe ':0r!hg diff "'.s:thispath.'" | dos2unix'
    setlocal ft=diff
endfu

fu! DoGather()
    let s:thispath = expand('%:t')
    new
    exe ':0r!gather "'.s:thispath.'" | dos2unix'
endfu



fu! Copyabspath()
    let @+ = expand('%:p')
    echo 'Copied to clipboard:' expand('%:p')
endfu



fu! PutHtml()
    " just insert the html page
    insert
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<!-- <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> -->
<html xmlns='http://www.w3.org/1999/xhtml'>
  <!-- vi:set ft=html: -->
  <head>
    <meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />
    <title>{Press 's' to type a title here}</title>
    <style type='text/css'>
/* styles here */
    </style>
    <script type='text/javascript' language='javascript'>
// <![CDATA[
// scripts here
// ]]>
    </script>
  </head>
  <body>
    <!-- stuff here -->
  </body>
</html>
.
endfu

fu! DoHtmlBP()
    " insert the HTML page then select the title interactively
    call PutHtml()
    exe "norm ?{Press\<Cr>v/}\<Cr>"
    set ft=html
endfu

fu! PutTac()
    insert
# vi:ft=python
from twisted.application import service, internet
from nevow import tags as T, rend, loaders, appserver

class FIXMEPage(rend.Page):
    LOADER

application = service.Application('FIXME')
svc = internet.TCPServer(8080, appserver.NevowSite(FIXMEPage()))
svc.setServiceParent(application)
.
endfu


fu! PutSurvey()
    insert
<survey name="Blank Survey" state="dev">

    <radio label="q1" title="Choose your favorite fruit">
        <comment>Choose one</comment>
        <row label="r1">Orange</row>
        <row label="r2">Banana</row>
        <row label="r3">Apple</row>
    </radio>

    <exec>
setMarker("qualified")
</exec>

</survey>
.
endfu

fu! DoPutSurvey()
    setlocal nofoldenable
    call PutSurvey()
    set ft=xml
endfu


fu! PutUsage()
    insert
# vi:ft=python
import sys, os

from twisted.python import usage


class Options(usage.Options):
    synopsis = "{Press 's' and type a new synopsis}"
    optParameters = [[long, short, default, help], ...]

    # def parseArgs(self, ...):

    # def postOptions(self):
    #     """Recommended if there are subcommands:"""
    #     if self.subCommand is None:
    #         self.synopsis = "{replace} <subcommand>"
    #         raise usage.UsageError("** Please specify a subcommand (see \"Commands\").")


def run(argv=None):
    if argv is None:
        argv = sys.argv
    o = Options()
    try:
        o.parseOptions(argv[1:])
    except usage.UsageError, e:
        if hasattr(o, 'subOptions'):
            print str(o.subOptions)
        else:
            print str(o)
        print str(e)
        return 1

    ...

    return 0


if __name__ == '__main__': sys.exit(run())
.
endfu

fu! DoPutUsage()
    setlocal nofoldenable
    call PutUsage()
    set ft=python
    exe "norm ?{Press\<Cr>v/}\<Cr>"
endfu


fu! DoPrettyXML(htmlFlag)
    let l:notfragment = search('^<!DOCTYPE\|^<?xml', "w")
    let l:hasxmlheader = search('^<?xml', "w")

    " write errors to one temp file and output to another.  decide whether to
    " keep the output based on whether the error file has output
    let l:tmpb = tempname()
    let l:tmpe = tempname()
    let l:tmpf = tempname()
    let l:lines = getline(1,'$')

    call writefile(l:lines, l:tmpb)

    if a:htmlFlag
        let l:flags = '--html --format'
    else
        let l:flags = '--format'
    endif

    " run xmllint, routing errors and output to two separate files, and
    " cleaning up error list on the way through
    exe 'silent !xmllint '. l:flags . ' ' . l:tmpb . ' 2>&1  > ' . l:tmpf . ' | egrep -o ":[0-9]+:.*" > ' l:tmpe
    call delete(l:tmpb)

    if getfsize(l:tmpf) > 0
        exe 'sil %!cat ' . l:tmpf
    else
        " we stripped out the filename column of the the error file, now read from
        " it with only two error fields because we munged the filename.
        let l:origformat = &errorformat
        setl efm=:%l:%m
        exe 'cf ' . l:tmpe
        setl efm=l:origformat
    endif
    call delete(l:tmpf)
    call delete(l:tmpe)

endfu


fu! DoRunAnyBuffer(interpreter, syntax)
    pclose!
    exe "setlocal ft=" . a:syntax
    exe "sil %y a | below new | sil put a | sil %!" . a:interpreter
    setlocal previewwindow ro nomodifiable nomodified
    winc p
endfu

" js static checking with :make
fu! EnableJsLint()
    setlocal makeprg=rhino\ -f\ ~/wc/Personal/fulljslint.js\ ~/wc/Personal/rhino.js\ %:p
    setlocal errorformat=%l:%c:%m
endfu

fu! EnableReST()
    let l:rstCSS = expand('%:p:h') . '/rst.css'

    " check for the existence of rst.css in the same directory; if it exists,
    " pass it to rst2html as an option.
    if len(glob(l:rstCSS)) | let $RSTOPTS='--stylesheet-path=rst.css'
    else | let $RSTOPTS=''
    endif

    setlocal makeprg=rst2html\ $RSTOPTS\ %:p\ %:p.html
    setlocal errorformat=%f:%l:\ %m
endfu

fu! DoPyFlakes()
    let l:tmp = tempname()
    exe 'sil !pyflakes %:p > ' . l:tmp
    exe 'cfile ' . l:tmp
    call delete(l:tmp)
endfu


call SetCoryOptions()
call SetCoryAutoCommands()
call SetCoryCommands()
call SetCoryMappings()

" vim:set foldmethod=indent:
