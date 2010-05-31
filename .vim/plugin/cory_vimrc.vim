fu! SetCoryOptions()
    " a list of variables which the user wants to override
    if !exists("g:vtoverride")
        let g:vtoverride = []
    endif

    " indenting
    if index(g:vtoverride, "indent") < 0
        set tw=78
        set sw=4 ts=4 sts=4 expandtab
        filetype indent on
    endif

    " cursor movement/selection
    if index(g:vtoverride, "cursor") < 0
        set virtualedit=block
        set backspace=eol,indent,start
        set whichwrap=b,s,<,>,h,l,~,[,] " these movements permit line wrapping
    endif

    " temp files
    if index(g:vtoverride, "temp") < 0
        set nobackup nowritebackup
        " 2 path separators == use abspath in filename for uniqueness
        "   (see :help 'directory' )
        set directory=/tmp//
    endif

    " syntax highlighting
    if index(g:vtoverride, "syntax") < 0
        filetype plugin on
        syn on
    endif

    " ui appearance
    if index(g:vtoverride, "appearance") < 0
        set visualbell
        set nohlsearch
        set nu " line numbers
        set guitablabel=%M\ %N\ %t
    endif

    " color scheme
    if index(g:vtoverride, "colorscheme") < 0
        colorscheme greener
    endif

    " status line
    if index(g:vtoverride, "status") < 0
        set laststatus=2 " always show status
        set stl=%F\ %y\ %l/%L@%c\ %m%r
    endif

    " misc - very little reason to change any of these
    if index(g:vtoverride, "misc") < 0
        set tags=./tags,tags,../tags,../../tags,../../../tags,../../../../tags
        set modeline
        let g:yankring_history_file='.yankring_history'
    endif

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

    " examples:
    " :Pp twisted.internet  " replace the current buffer
    " :Pp! twisted.internet  " replace the current buffer, even if modified
    " :Ppn py2exe.build_exe  " horiz-split and put file in new buffer
    " :Ppv py2exe.build_exe  " vert-split and put file in new buffer
    command! -nargs=1 -bang Pp exe ':edit<bang> '.system('pp <args>')
    command! -nargs=1 Ppn exe ':new '.system('pp <args>')
    command! -nargs=1 Ppv exe ':vs '.system('pp <args>')

    command! PrettyXML call DoPrettyXML(0)
    command! PrettyHTML call DoPrettyXML(1)
    command! RunPyBuffer call DoRunAnyBuffer("python -", "python")
    command! RunJythonBuffer call DoRunAnyBuffer("jython -", "python")
    command! RunBashBuffer call DoRunAnyBuffer("bash -", "sh")
    command! RunLuaBuffer call DoRunAnyBuffer("lua -", "lua")
    command! RunSQLiteBuffer call DoRunAnyBuffer("sqlite3", "sql")

    command! PyFlake call DoPyFlakes()

    command! VersionCory echo 'Cory''s vim scripts v2010.05'
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
    map <Leader>j :RunJythonBuffer<CR>

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
        exe 'sil below vnew DIFF-'.s:thispath
        exe ':0r!hg cat "'.s:thispath.'"'
        " open all folds - workaround bug that catches last folded section
        " in the diff
        norm zR
        $,$d  " hg cat adds a final newline
        setlocal previewwindow nomodified
        diffthis
        norm zM
        winc p
        norm zM
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



iab htmlbp 
\<ESC>:set paste
\<CR>i<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
\<CR><!-- <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> -->
\<CR><html xmlns='http://www.w3.org/1999/xhtml'>
\<CR>  <!-- vi:set ft=html: -->
\<CR>  <head>
\<CR>    <meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />
\<CR>    <title>{Press 's' to type a title here}</title>
\<CR>    <style type='text/css'>
\<CR>/* styles here */
\<CR>    </style>
\<CR>    <script type='text/javascript' language='javascript'>
\<CR>// <![CDATA[
\<CR>// scripts here
\<CR>// ]]>
\<CR>    </script>
\<CR>  </head>
\<CR>  <body>
\<CR>    <!-- stuff here -->
\<CR>  </body>
\<CR></html>
\<ESC>:set nopaste
\<CR>:set ft=html
\<CR>?{Press
\<CR>v/}
\<CR>h


iabbrev surveybp 
\<ESC>:setlocal nofoldenable
\<CR>:set paste
\<CR>i<survey name="Blank Survey" state="dev">
\<CR>
\<CR>    <radio label="q1" title="Choose your favorite fruit">
\<CR>        <comment>Choose one</comment>
\<CR>        <row label="r1">Orange</row>
\<CR>        <row label="r2">Banana</row>
\<CR>        <row label="r3">Apple</row>
\<CR>    </radio>
\<CR>
\<CR>    <exec>
\<CR>setMarker("qualified")
\<CR></exec>
\<CR>
\<CR></survey>
\<ESC>:set ft=xml
\<CR>:set nopaste<CR>


iab usagebp 
\<ESC>:setlocal nofoldenable
\<CR>:set paste
\<CR>i# vi:ft=python
\<CR>import sys, os
\<CR>
\<CR>from twisted.python import usage
\<CR>
\<CR>
\<CR>class Options(usage.Options):
\<CR>    synopsis = "{Press 's' and type a new synopsis}"
\<CR>    optParameters = [[long, short, default, help], ...]
\<CR>
\<CR>    # def parseArgs(self, ...):
\<CR>
\<CR>    # def postOptions(self):
\<CR>    #     """Recommended if there are subcommands:"""
\<CR>    #     if self.subCommand is None:
\<CR>    #         self.synopsis = "{replace} <subcommand>"
\<CR>    #         raise usage.UsageError("** Please specify a subcommand (see \"Commands\").")
\<CR>
\<CR>
\<CR>def run(argv=None):
\<CR>    if argv is None:
\<CR>        argv = sys.argv
\<CR>    o = Options()
\<CR>    try:
\<CR>        o.parseOptions(argv[1:])
\<CR>    except usage.UsageError, e:
\<CR>        if hasattr(o, 'subOptions'):
\<CR>            print str(o.subOptions)
\<CR>        else:
\<CR>            print str(o)
\<CR>        print str(e)
\<CR>        return 1
\<CR>
\<CR>    ...
\<CR>
\<CR>    return 0
\<CR>
\<CR>
\<CR>if __name__ == '__main__': sys.exit(run())
\<ESC>:set nopaste
\<CR>:set ft=python
\<CR>?{Press
\<CR>v/}<CR>

iab pluginbp 
\<ESC>:set paste
\<CR>:set nofoldenable
\<CR>i"""
\<CR>{Press s to write a module docstring!}
\<CR>"""
\<CR>from hermes.plugins.plugutil import PluginHandler
\<CR>from hermes.ajax import json, ajaxJSON
\<CR>
\<CR>
\<CR>class YourPluginApp(PluginHandler):
\<CR>    name = 'yourplugin'
\<CR>
\<CR>    def getFilters(self):
\<CR>        return {
\<CR>            }
\<CR>
\<CR>    def getRequestHandler(self):
\<CR>        return self
\<CR>
\<CR>    def getAjaxFunctions(self):
\<CR>        return [('someAJAXFunction', self.someAJAXFunction)]
\<CR>
\<CR>    def reloadMe(self):
\<CR>        from hermes.plugins import timetrack as me
\<CR>        reload(me)
\<CR>
\<CR># create an instance of your plugin application
\<CR>yourPluginApp = YourPluginApp()
\<ESC>:set nopaste
\<CR>:set ft=python
\<CR>/{Press
\<CR>v/}<CR>h


iab unittestbp 
\<ESC>:set paste
\<CR>:set nofoldenable
\<CR>i"""
\<CR>{Press s to write a module docstring!}
\<CR>"""
\<CR>from twisted.trial import unittest
\<CR>
\<CR>class FOOTest(unittest.TestCase):
\<CR>    """DOCSTRING HERE PLS"""
\<CR>    # def setUp(self):
\<CR>
\<CR>    # def test_...
\<ESC>:set nopaste
\<CR>:set ft=python
\<CR>/{Press
\<CR>v/}<CR>h


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
        let l:flags = '--html --format --nocompact'
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
    setlocal previewwindow ro nomodified
    winc p
endfu

" js static checking with :make
fu! EnableJsLint()
    setlocal makeprg=rhino\ -f\ ~/wc/Personal/fulljslint.js\ ~/wc/Personal/rhino.js\ %:p
    setlocal errorformat=%l:%c:%m
endfu

fu! EnableReST()
    setlocal makeprg=vimrst2html\ %
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
