" tac files
au BufRead,BufNewFile *.tac setf python
" indenting
set tw=78
set sw=4 ts=4 sts=4 expandtab
filetype indent on
au BufNewFile,BufEnter * silent! exec ":cd " expand('%:p:h')
au BufNewFile,BufEnter {ChangeLog,CHANGELOG,changelog,Makefile} setlocal noet
au BufNewFile,BufEnter *.js setlocal smartindent


" reST helpers
map <Leader>- YpV:s:.:-:g<CR>  " underline a heading
map <Leader>= YpV:s:.:=:g<CR>  " underline a heading at a different level
map <Leader>` YpV:s:.:\~:g<CR>  " underline a heading at a different level
map <Leader><Leader>= YpV:s:.:=:g<CR>YkO<Esc>pjj0  " title

" tab helper
map <Leader>t :tab new<CR>

" temp files 
set virtualedit=block
set nobackup nowritebackup
" 2 path separators == use abspath in filename for uniqueness
" (see :help 'directory' ) 
set directory=/tmp//
" colors/fonts
set nohlsearch
filetype plugin on
" colorscheme koehler
" colorscheme peachpuff
colorscheme greener
set ts=4
syn on

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

fu! PutCanvassy()
    " insert Python code for displaying a Canvas
    insert
import sys

import gtk
import gnomecanvas

class Canvassy(gnomecanvas.Canvas):
    def __init__(self, *args, **kwargs):
        gnomecanvas.Canvas.__init__(self)
        self.set_center_scroll_region(False)
        self.root().add("GnomeCanvasRect", x1=0, y1=0, x2=500, y2=500,
                        fill_color="#ffffff")

def destroy(event):
    gtk.main_quit()

def run(argv=None):
    if argv is None:
        argv = sys.argv

    w = gtk.Window()
    w.connect('destroy', destroy)
    c = Canvassy()
    w.add(c)
    w.show_all()

    gtk.main()
    return 0


if __name__ == '__main__':
    sys.exit(run())
.
endfu
command! Canvasbp call PutCanvassy()



fu! PutHtml()
    " just insert the html page
    insert
<html xmlns='http://www.w3.org/1999/xhtml'>
  <!-- vi:ft=html
  -->
  <head>
    <meta http-equiv='Content-Type' content='text/html; charset=UTF-8' />
    <title>{Press 's' to type a title here}</title>
    <style type='text/css'>
      /* styles here */
    </style>
    <script type='text/javascript' language='javascript'>
      // scripts here
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
    set ft=html
    exe "norm ?{Press\<Cr>v/}\<Cr>"
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



fu! DoRunPyBuffer2()
    pclose!  " force preview window closed
    setlocal ft=python

    " copy the buffer into a new window, then run that buffer through python
    sil %y a | below new | sil put a | sil %!python -
    " indicate the output window as the current previewwindow
    setlocal previewwindow ro nomodifiable

    " back into the original window
    winc p
endfu

command! RunPyBuffer call DoRunPyBuffer2()
map <Leader>p :RunPyBuffer<CR>

