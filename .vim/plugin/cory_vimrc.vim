fu! SetCoryOptions()
    " a list of variables which the user wants to override
    if !exists("g:vtoverride")
        let g:vtoverride = []
    endif

    " " netrw
    if index(g:vtoverride, "netrw") < 0
        let g:netrw_liststyle= 3
        let g:netrw_winsize= 30
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
    au Filetype javascript call EnableJSHint()
    au FileType javascript setl fen
    augroup END
endfu

fu! SetCoryCommands()
    command! Gather call DoGather()
    command! Abspath call Copyabspath()

    " examples:
    " :Pp twisted.internet  " replace the current buffer
    " :Pp! twisted.internet  " replace the current buffer, even if modified
    " :Ppn py2exe.build_exe  " horiz-split and put file in new buffer
    " :Ppv py2exe.build_exe  " vert-split and put file in new buffer
    command! -nargs=1 -bang Pp exe ':edit<bang> '.system('. /usr/local/bin/activate.sh; cd .; pp <args>')
    command! -nargs=1 Ppn exe ':new '.system('. /usr/local/bin/activate.sh; cd .; pp <args>')
    command! -nargs=1 Ppv exe ':vs '.system('. /usr/local/bin/activate.sh; cd .; pp <args>')

    command! PrettyXML call DoPrettyXML(0)
    command! PrettyHTML call DoPrettyXML(1)
    command! RunPyBuffer call DoRunAnyBuffer("python -", "python")
    command! RunBashBuffer call DoRunAnyBuffer("bash -", "sh")
    command! RunSQLiteBuffer call DoRunAnyBuffer("sqlite3", "sql")
    command! RunMakeBM call DoRunAnyBuffer("makebm.js", "javascript")

    command! PyFlake call DoErrorCheck('pyflakes')
    command! JSHint call DoErrorCheck('make -C `hg root` jshint ARG=')

    command! VersionCory echo 'Cory''s vim scripts v2013.06'

    command! -range InsertLineNums call InsertLineNumbers(<line1>,<line2>)

    command! -nargs=1 Sav call SudoSaveAs(<f-args>)
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
    "   number lines
    map <Leader># :InsertLineNums<CR>

    " tab helpers
    map <Leader>t :tab new<CR>
    map <Leader><C-T> :tabclose!<CR>

    map <Leader>p :RunPyBuffer<CR>:winc p<cr>:set filetype=pylog<cr>:winc p<cr>
    map <Leader>b :RunBashBuffer<CR>
    map <Leader>q :RunSQLiteBuffer<CR>
    map <Leader>B :RunMakeBM<CR>

    " diffs
    map <Leader>D :call ToggleGitDiff()<CR>


    " make it easier to edit vimrc
    map <Leader>V :so ~/vimrc<CR>

    map <Leader>W :call SudoSave()<CR>

    map <Leader><Tab> :call GoIDE()<CR>

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

fu! TurnOnDiff(cmd)
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
        exe ':0r!' . a:cmd . ' "'.s:thispath.'"'
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

fu! TurnOffDiff()
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

fu! ToggleHgDiff()
    if exists("b:diffIsOn") && b:diffIsOn
        call TurnOffDiff()
    else
        call TurnOnDiff('hg cat')
    endif
endfu

fu! ToggleGitDiff()
    if exists("b:diffIsOn") && b:diffIsOn
        call TurnOffDiff()
    else
        call TurnOnDiff('git ls-tree --full-name --name-only HEAD ' . expand('%:.') . ' | xargs -i git show HEAD:{}')
    endif
endfu

fu! DoGather()
    let s:thispath = expand('%:t')
    new
    exe ':0r!gather "'.s:thispath.'" | dos2unix'
endfu

fu! SudoSaveAs(newName)
    exe 'w !sudo tee ' . a:newName . ' > /dev/null'
    exe 'sil e!  ' . a:newName
endfu

fu! SudoSave()
    sil w !SUDO_ASKPASS=/usr/bin/ssh-askpass sudo -A tee % > /dev/null
endfu


fu! Copyabspath()
    let @+ = expand('%:p')
    echo 'Copied to clipboard:' expand('%:p')
endfu



iab htmlbp 
\<ESC>:set paste
\<CR>i<!DOCTYPE html>
\<CR><html>
\<CR>  <head>
\<CR>    <meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />
\<CR>    <title>{Press 's' to type a title here}</title>
\<CR>    <style type='text/css'>
\<CR>body, html { width: 100%; }
\<CR>body { margin: 30px;
\<CR>  padding: 0px;
\<CR>  border: 0px;
\<CR>  font-family: georgia,serif; 
\<CR>}
\<CR>h1, h2, h3 { 
\<CR>  margin: 0px 0px 8px -30px;
\<CR>  border-left: 30px solid #669;
\<CR>  color: white;
\<CR>  background-color: #669;
\<CR>  font-family: verdana,sans-serif;
\<CR>}
\<CR>    </style>
\<CR>    <script src=
\<CR>      "https://ajax.googleapis.com/ajax/libs/jquery/1.8.1/jquery.min.js"></script>
\<CR>    <script type='text/javascript' language='javascript'>
\<CR>// scripts here
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


iabbrev wsbp 
\<ESC>:setlocal nofoldenable
\<CR>:set paste
\<CR>i"""
\<CR>Simplest Webserver
\<CR>"""
\<CR>
\<CR>from twisted.web.static import File
\<CR>from twisted.internet import defer
\<CR>
\<CR>from klein import resource, route
\<CR>(resource) # for pyflakes
\<CR>
\<CR>
\<CR>@route('/')
\<CR>def index(request):
\<CR>    """
\<CR>    Return index.html as a static file
\<CR>    """
\<CR>    return File('.')
\<ESC>:set ft=python
\<CR>:set nopaste<CR>


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


iab txpluginbp 
\<ESC>:set paste
\<CR>:set nofoldenable
\<CR>i"""
\<CR>Twistd plugin to {Press s to write a module docstring!}
\<CR>"""
\<CR>from zope.interface import implements
\<CR>
\<CR>from twisted.python import usage, log, logfile
\<CR>from twisted.plugin import IPlugin
\<CR>from twisted.application.service import IServiceMaker, MultiService
\<CR>from twisted.application import strports
\<CR>
\<CR>from THINGIE import THINGIEFactory 
\<CR>
\<CR>
\<CR>LOG_WRAP = 3*10**6
\<CR>
\<CR>
\<CR>class Options(usage.Options):
\<CR>    optParameters = [['port', 'p', '17766', 'Port to run on'],
\<CR>                     ['logWrap', None, LOG_WRAP,
\<CR>                         'Number of bytes, log files will grow no larger than this'],
\<CR>                     ]
\<CR>
\<CR>    ## optFlags  = []
\<CR>
\<CR>    def postOptions(self):
\<CR>        self['logWrap'] = int(self['logWrap'])
\<CR>
\<CR>class THINGIEMaker(object):
\<CR>    """
\<CR>    Framework boilerplate class: This is used by twistd to get the service
\<CR>    class.
\<CR>
\<CR>    Basically exists to hold the IServiceMaker interface so twistd can find
\<CR>    the right makeService method to call.
\<CR>    """
\<CR>    implements(IServiceMaker, IPlugin)
\<CR>    tapname = "THINGIE"
\<CR>    description = "THINGIE description"
\<CR>    options = Options
\<CR>
\<CR>    def makeService(self, options):
\<CR>        """
\<CR>        Construct the THINGIE
\<CR>        """
\<CR>        master = MultiService()
\<CR>
\<CR>
\<CR>        factory = THINGIEFactory()
\<CR>
\<CR>
\<CR>        port = 'tcp:%s' % (options['port'],)
\<CR>        myService = strports.service(port, factory)
\<CR>        master.addService(myService)
\<CR>
\<CR>        # Handle logging ourselves so logs get rotated
\<CR>        if options.parent['logfile']:
\<CR>            raise usage.UsageError("** do not use --logfile option, it is ignored")
\<CR>        if not options.parent['nodaemon']:
\<CR>            log.startLogging(logfile.LogFile('THINGIE.log', '.',
\<CR>                rotateLength=options['logWrap'],
\<CR>                maxRotatedFiles=30))
\<CR>
\<CR>        return master
\<CR>
\<CR># Now construct an object which *provides* the relevant interfaces
\<CR>
\<CR># The name of this variable is irrelevant, as long as there is *some*
\<CR># name bound to a provider of IPlugin and IServiceMaker.
\<CR>
\<CR>serviceMaker = THINGIEMaker()
\<ESC>:set nopaste
\<CR>:set ft=python
\<CR>/{Press
\<CR>v/}<CR>h


iab mochabp 
\<ESC>:set paste
\<CR>:set nofoldenable
\<CR>i/*
\<CR> * Test behavior of .....
\<CR> */
\<CR>"use strict";
\<CR>
\<CR>describe("{path/to/file.js}", function _a_queueTest() {
\<CR>    // beforeEach(function _beforeEach() {
\<CR>    // });
\<CR>
\<CR>    // afterEach(function _beforeEach() {
\<CR>    // });
\<CR>
\<CR>    // it('should foo', function _test_foo() {
\<CR>    //     expect('x').to.be['y'];
\<CR>    // });
\<CR>
\<CR>});
\<ESC>:set nopaste
\<CR>:set ft=javascript
\<CR>/{path\/to
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
fu! EnableJSHint()
    setlocal makeprg=make\ -s\ -C\ `hg\ root`\ jshintvim\ ARG=%:p
    setlocal errorformat=%f:\ line\ %l\\,\ col\ %c\\,\ %m
endfu

fu! EnableReST()
    setlocal makeprg=vimrst2html\ %
    setlocal errorformat=%f:%l:\ %m
endfu

fu! DoErrorCheck(interpreter)
    let l:tmp = tempname()
    exe 'sil !' . a:interpreter . ' %:p > ' . l:tmp
    exe 'cfile ' . l:tmp
    call delete(l:tmp)
endfu


call SetCoryOptions()
call SetCoryAutoCommands()
call SetCoryCommands()
call SetCoryMappings()


" add a line number prefix to every line in the range, skipping indented lines
function! InsertLineNumbers(l1, l2)
    let ln1 = a:l1
    let ln2 = a:l2
    let lineToInsert = 1
    let lineLen = ln2 - ln1
    let cellSize = len(string(lineLen))
    while ln1 <= ln2
        let currLine = getline(ln1)
        let renumberWidth = NumberedCellSize(currLine)
        if currLine[renumberWidth :] =~ '^\S'
            let currLine = currLine[renumberWidth :]
            let padding = repeat(' ', cellSize - len(string(lineToInsert)) + 1)
            let newLine = ' '.lineToInsert.".".padding.currLine
            let lineToInsert = lineToInsert + 1
        else
            let padding = repeat(' ', cellSize + 3)
            let _currLine = substitute(currLine, '^\s*', '', '')
            let newLine = padding._currLine
        endif
        call setline(ln1, newLine)
        let ln1 = ln1 + 1
    endwhile
endfunction

" return the maximum text width of the line numbers in a range of lines
fu! NumberedCellSize(currLine)
    let lastCellSize = 0
    let numMatch = matchlist(a:currLine, '^\( \+\d\+\. *\)')
    if len(numMatch) > 0
        return len(numMatch[1])
    endif
    return 0
endfu

command! Jsyntax call DoJsyntax()

fu! DoJsyntax()
    sil %y j
    sil below new _js_
    sil pu j
    sil %s,^import ,//// &,g
    sil exe '%!nodejs'
    set nomodified
endfu

fu! GoIDE() 
    if exists("$VIRTUAL_ENV")
        exe ':30vnew ' . $VIRTUAL_ENV
    else
        exe ':30vnew .'
    endif
endfu

" vim:set foldmethod=indent:
