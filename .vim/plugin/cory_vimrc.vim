" indenting
set tw=78
set sw=4 ts=4 sts=4 expandtab
set modeline
filetype indent on
au BufReadPost,BufNewFile,BufEnter * silent! exec ":cd " expand('%:p:h')
au BufReadPost,BufNewFile,BufEnter {ChangeLog,CHANGELOG,changelog,Makefile} setlocal noet
au Filetype javascript setlocal smartindent

" so ~/autocmddebug.vim

let g:yankring_history_file='.yankring_history'

" taglist.vim
map <Leader>T :TlistToggle<CR>

" clipboard helpers
map <Leader>c "+y
map <Leader>v "+p
map <Leader>x "+x

" make error helpers
map <Leader>] :cn
map <Leader>[ :cp


" reST helpers
"   underline a heading
map <Leader>- Yp:.,.s:.:-:g<CR>
"   underline a heading at a different level
map <Leader>= Yp:.,.s:.:=:g<CR>
"   underline a heading at a different level
map <Leader>` Yp:.,.s:.:\~:g<CR>
"   title
map <Leader><Leader>= Yp:.,.s:.:=:g<CR>YkPjj0

" tab helpers
map <Leader>t :tab new<CR>
map <Leader><Leader><Leader>t :tabclose!<CR>

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


" Helpers for some VCS systems
fu! DoSvnDiff()
    let s:thispath = expand('%:t')
    new
    exe ':0r!svn diff "'.s:thispath.'" | dos2unix'
    setlocal ft=diff
endfu
command! SvnDiff call DoSvnDiff()

fu! DoHgDiff()
    let s:thispath = expand('%:t')
    new
    exe ':0r!hg diff "'.s:thispath.'" | dos2unix'
    setlocal ft=diff
endfu
command! HgDiff call DoHgDiff()

fu! DoGather()
    let s:thispath = expand('%:t')
    new
    exe ':0r!gather "'.s:thispath.'" | dos2unix'
endfu
command! Gather call DoGather()



fu! Copyabspath()
    let @+ = expand('%:p')
    echo 'Copied to clipboard:' expand('%:p')
endfu
command! Abspath call Copyabspath()



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

command! Htmlbp call DoHtmlBP()

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

fu! DoTacBP()
    " insert the tac file boiler plate
    call PutTac()
    set ft=python
    let s:orighls = &hls

    set hls
    exe "/FIXME"
    redraw
    let s:replacement = input('App name: ', 'FIXME')
    exe ":1,$s/FIXME/".s:replacement."/g"
    exe "/LOADER"
    redraw
    let s:loader = input('Loader (stan, xmlstr, or xmlfile): ', 'stan')
    if s:loader == 'xmlstr'
        let s:loaderrep = 'docFactory = loaders.xmlstr('."'''".'<html xmlns:n="http:\/\/nevow.com\/ns\/nevow\/0.1">'."\r".'..<\/html>'."'''".')'
    elseif s:loader == 'xmlfile'
        let s:loaderrep = 'docFactory = loaders.xmlfile("{Press s and type a new filename}")'
    else
        let s:loaderrep = 'docFactory = loaders.stan(T.html["Put something here."])'
    endif

    exe ":1,$s/LOADER/".s:loaderrep."/g"
    redraw

    if s:loader == 'xmlfile'
        exe "norm /{Press s\<Cr>zAv/}\<Cr>"
    endif


    if s:orighls
        set hls
    else
        set nohls
    endif
endfu

command! Tacbp call DoTacBP()

" examples: 
" :Pp twisted.internet  " replace the current buffer
" :Pp! twisted.internet  " replace the current buffer, even if modified
" :Ppn py2exe.build_exe  " horiz-split and put file in new buffer
" :Ppv py2exe.build_exe  " vert-split and put file in new buffer
command! -nargs=1 -bang Pp exe ':edit<bang> '.system('pp <args>')
command! -nargs=1 Ppn exe ':new '.system('pp <args>')
command! -nargs=1 Ppv exe ':vs '.system('pp <args>')


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

command! Survey call DoPutSurvey()

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


def run(argv=None):
    if argv is None:
        argv = sys.argv
    o = Options()
    try:
        o.parseOptions(argv[1:])
    except usage.UsageError, e:
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

command! Usage call DoPutUsage()

fu! DoPrettyXML()
    " save the filetype so we can restore it later
    let l:origft = &ft
    " Blank the filetype.  Certain xml filetypes have auto-closing behavior
    " that interferes with inserting the fake tags (see below).
    set ft=

    " search for <?xml?> header or DOCTYPE.  If neither of these is present,
    " the document *might* be fragment.
    silent echo cursor(1,1)
    let l:notfragment = search('^<!DOCTYPE\|^<?xml', "w")
    if l:notfragment == 0
        " Insert fake tags around the entire document in case it is a fragment
        " with more than one top-level node.  (Such documents are not
        " parseable without this workaround.)
        1
        exe "norm! O<PrettyXML>"
        exe "norm! Go</PrettyXML>"
    endif


    silent %!xmllint --format -

    " xmllint will insert an <?xml?> header.  it's easy enough to delete
    " if you don't want it.


    if l:notfragment == 0
        " delete the fake tags
        2
        exe "norm ddGdd"

        " restore the 'normal' indentation, which is one extra level
        " too deep due to the extra tags we wrapped around the document.
        silent %<
    endif

    " back to home
    1

    " restore the filetype
    exe "set ft=" . l:origft
endfu

command! PrettyXML call DoPrettyXML()

set tags=./tags,tags,../tags,../../tags,../../../tags,../../../../tags



fu! DoRunAnyBuffer(interpreter, syntax)
    pclose!
    exe "setlocal ft=" . a:syntax
    exe "sil %y a | below new | sil put a | sil %!" . a:interpreter
    setlocal previewwindow ro nomodifiable nomodified
    winc p
endfu

command! RunPyBuffer call DoRunAnyBuffer("python -", "python")
map <Leader>p :RunPyBuffer<CR>
command! RunBashBuffer call DoRunAnyBuffer("bash -", "sh")
map <Leader>b :RunBashBuffer<CR>


" make it easier to edit vimrc
map <Leader>V :so ~/.vimrc<CR>

" js static checking with :make
fu! EnableJsLint()
    setlocal makeprg=rhino\ ~/wc/Personal/jslint.js\ %:p
    setlocal errorformat=%l:%c:%m
endfu
au BufNewFile,BufEnter *.js call EnableJsLint()
